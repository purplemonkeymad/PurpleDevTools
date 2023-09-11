<#

Save help text to a markdown format for display in github etc.

#>
function Save-MarkdownHelp {
    [CmdletBinding(DefaultParameterSetName="Command")]
    param (
        [parameter(Mandatory,ValueFromPipeline,ParameterSetName="Command",Position=0)]$Command,
        [Parameter(Mandatory,ParameterSetName="Module")][string]$Module,
        [Parameter(Position=1)][ValidateScript({
            if (Test-Path -Path $_ -IsValid){
                $true
            } else {
                throw "The value supplied to Path does not appear to be a valid path."
            }
        })][string]$Path
    )
    
    begin {

        # This should create a list of all functions in the module
        if ($PSCmdlet.ParameterSetName -eq "Module"){
            $Command = Get-Command -Module $Module

            if (Test-Path -Path $Path -PathType Leaf) {
                # target if a file, but should be a folder
                Write-Error -ErrorAction Stop "Provided Path should be a folder and not a file when using the module option."
            }
        }

        $null = New-Item $Path -ItemType Directory -Force

    }
    
    process {
        foreach ($SingleCommand in $Command) {
            $CommandHelp = Get-Help $SingleCommand
            $NewFileContent = $(
                # start with a root header with the name of the command:
                New-MarkdownSection -Name "$SingleCommand" -Content $(

                    # start with synopsis
                    $CommandHelp.Synopsis
                    "" ## nl

                    # add a toc style section to skip to headers:
                    "|Skip To|"
                    "|-------|"
                    $TocItems = $(
                        "[Syntax](#syntax)"
                        if ($CommandHelp.Description){ "[Description](#description)" }
                        "[Parameters](#parameters)"
                        if ($CommandHelp.examples.example) {"[Examples](#examples)" }
                        if ($CommandHelp.relatedLinks.navigationlink.uri) { "[Links](#links)" }
                    )
                    "|$($TocItems -join ' ')|"
                    ""

                    # syntax
                    New-MarkdownSection -Name Syntax -Content $(
                        $CommandHelp.Syntax.syntaxItem | Convert-HelpSyntaxToMarkdown
                    )

                    # longer description
                    if ($CommandHelp.Description){
                        New-MarkdownSection -Name Description -Content ($CommandHelp.Description | Convert-HelpDescriptionToMarkdown)
                    }

                    # parameters
                    New-MarkdownSection -Name Parameters -Content $(
                        # list of parameters than can be hotlinked:

                        "This command provides the following parameters: $(
                            foreach ($ParamName in $CommandHelp.parameters.parameter.name) {
                                "[${ParamName}](#$($ParamName.ToLower()))"
                            }
                        )"
                        "" # new line

                        $CommandHelp.Parameters.Parameter | Convert-HelpParameterToMarkdown
                    )

                    #examples

                    if ($CommandHelp.examples.example) {
                        New-MarkdownSection -Name Examples -Content $(
                            $CommandHelp.examples.example | Convert-HelpExampleToMarkdown
                        )
                    }

                    # links

                    if ($CommandHelp.relatedLinks.navigationlink.uri) {
                        New-MarkdownSection -Name Links -Content $(
                            $CommandHelp.relatedLinks.navigationlink.uri
                        )
                    }

                )
            )

            # flatten new content
            $NewFileContent = $NewFileContent -Join "`n"

            # check for markdown double blank lines an remove them
            while ($NewFileContent -match '(\r?\n){3}') {
                $NewFileContent = $NewFileContent -replace '(\r?\n){3}','$1$1'
            }

            if (-not $Path) {
                Write-Output $NewFileContent
                continue
            }

            if (-not $NewFileContent) {
                Write-Error "No output generated unable to write file."
                continue
            }

            $NewFileContent | Set-Content (Join-Path $Path "${SingleCommand}.md") -NoNewline
        }
    }
    
    end {
        
    }
}