<#

.Synopsis
Save help text to a markdown format for display in github etc.

.Description
Converts the help system from Get-Help into a prettier markdown format.
Help for commands need to already be written in a way get help can see them,
either comment based or xml comments.

.Parameter Command
Command to get/save help for. Should take either a command object or name.

.Parameter Module
Get all command help for the specified module.
This is better than piping in as if you specifiy Path then you will also get a module index.

.Parameter Path
Directory to save the markdown text to. File will be created as the command name.

If using module option, then an index will also be created.

.Parameter UseReadmeAsIndexName
By default index is the module name, use this to use "Readme.md" as the same instead.

.Example
Save-MarkdownHelp -Command Get-Help

Outputs a string for each command that contains the markdown contents of the specified
command's help.

.EXAMPLE
Save-MarkdownHelp -Command Get-Help -Path ./docs/

Exports the specified command's help infromation to the specified folder.
It will create a single file called "Get-Help.md" containing the help.

.Example
Save-MarkdownHelp -Module MyModule -Path ./docs/

Exports all help from the specified module into the folder docs under the current folder.
This will be a collection of individual command helps, and a single MyModule.md with an index
and description of the module.

.LINK
https://github.com/purplemonkeymad/PurpleDevTools/blob/master/docs/Save-MarkdownHelp.md
#>
function Save-MarkdownHelp {
    [CmdletBinding(DefaultParameterSetName="Command")]
    param (
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            
            $CommandList = Get-Command "$wordToComplete*"
            
            return $CommandList.Name
        })]
        [parameter(Mandatory,ValueFromPipeline,ParameterSetName="Command",Position=0)]$Command,
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            
            $ModuleList = Get-Module "$wordToComplete*"
            
            return $ModuleList.Name
        })]
        [Parameter(Mandatory,ParameterSetName="Module")][string]$Module,
        [Parameter(Position=1)][ValidateScript({
            if (Test-Path -Path $_ -IsValid){
                $true
            } else {
                throw "The value supplied to Path does not appear to be a valid path."
            }
        })][string]$Path,
        [switch]$UseReadmeAsIndexName
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


        $fullCommandList = [System.Collections.Generic.List[psobject]]@()
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

            $fullCommandList.add(
                [pscustomobject]@{
                    Name = $CommandHelp.Name
                    FileName = $CommandHelp.Name + '.md'
                    HelpObject = $CommandHelp
                }
            )

            $NewFileContent | Set-Content (Join-Path $Path "${SingleCommand}.md") -NoNewline
        }
    }
    
    end {
        
        # only do the index if we have a path to save to
        if (-not $Path){
            return
        }

        # look for about_ pages in the module folder.

        $ModuleObject = Get-Module $Module -ErrorAction SilentlyContinue
        $aboutList = if ($ModuleObject) {
            Get-ChildItem $ModuleObject.ModuleBase |
                Where-Object Name -like "About_*.help.txt" | 
                ForEach-Object {
                    # trim the .help from the filename.
                    $helpName = ($_.BaseName -replace '\.help$','')

                    Convert-AboutFileToMarkdown -Path $_.FullName | 
                        Set-Content (Join-Path $Path "${helpName}.md")
                    
                    [pscustomobject]@{
                        Name = $helpName
                        FileName = $helpName + '.md'
                    }
                }
        }

        # create a module index file in readme.md so
        # that you get a bit of a home page for it.

        $IndexContent = $(
            New-MarkdownSection -Name $Module -Content $(

                if ($ModuleObject) {
                    # if we have module info we can add description etc.
                    if ($ModuleObject.Description) {
                        $ModuleObject.Description
                    }

                    if ($ModuleObject.PrivateData.PSData.ReleaseNotes) {
                        New-MarkdownSection -Name ReleaseNotes -Content $ModuleObject.PrivateData.PSData.ReleaseNotes
                    }
                }

                New-MarkdownSection -Name Commands -Content $(
                    "This Module contains the following commands: "
                    ""
                    foreach ($ListItem in $fullCommandList) {
                        "* [$($ListItem.Name)]($($ListItem.Filename))"
                    }
                    ""
                )

                # if any about topics found, list them in a new section
                if ($aboutList) {
                    New-MarkdownSection -Name MiscPages -Content $(
                        "This Module contains the following generic help topics:"
                        ""
                        foreach ($ListItem in $aboutList) {
                            "* [$($ListItem.Name)]($($ListItem.Filename))"
                        }
                        ""
                    )
                }

            )
        )

        # flatten new content
        $IndexContent = $IndexContent -Join "`n"

        # check for markdown double blank lines an remove them
        while ($IndexContent -match '(\r?\n){3}') {
            $IndexContent = $IndexContent -replace '(\r?\n){3}','$1$1'
        }

        $IndexName = if ($UseReadmeAsIndexName) {
            "Readme.md"
        } else {
            "${Module}.md"
        }

        $IndexContent | Set-Content (Join-Path $Path $IndexName) -NoNewline

    }
}