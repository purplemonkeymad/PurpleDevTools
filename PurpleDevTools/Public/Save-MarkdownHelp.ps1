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
        })][string]$Path,
        [switch]$Force
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

                    # syntax
                    New-MarkdownSection -Name Syntax -Content $(
                        $CommandHelp.Syntax.syntaxItem | Convert-HelpSyntaxToMarkdown
                    )

                    # longer description
                    New-MarkdownSection -Name Description -Content ($CommandHelp.Description | Convert-HelpDescriptionToMarkdown)

                    # parameters
                    New-MarkdownSection -Name Parameters -Content $(
                        # list of parameters than can be hotlinked:

                        "This command provides the following parameters: $(
                            foreach ($ParamName in $CommandHelp.parameters.parameter.name) {
                                "[${ParamName}](#${ParamName})"
                            }
                        )"
                        "" # new line

                        $CommandHelp.Parameters.Parameter | Convert-HelpParameterToMarkdown
                    )

                )
            )

            if (-not $Path) {
                Write-Output $NewFileContent
                continue
            }

            if (-not $NewFileContent) {
                Write-Error "No output generated unable to write file."
                continue
            }

            $NewFileContent | Set-Content "${SingleCommand}.md"
        }
    }
    
    end {
        
    }
}