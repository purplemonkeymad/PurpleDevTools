using namespace System.XML
# I'm aware the irony of this command not using xml help.

<#
.SYNOPSIS
    Save the help for a command to a file in XML help format.
.DESCRIPTION
    This will save the current help information for a command in a format that can be used for XML Help.
    It's good for writting help for a command with dynamic parameters as they do not work with the comment based help system.
    Existing help is not required as PS generates help for any command automatically, this command will fill it out with some example text if that is the case.

.PARAMETER Command
    The command that help will be retrived for, either as a command object or the name of the command.

.PARAMETER Path
    File path to save the help to. This can be an existing path. If the file exists the new xml elements will be merged into the existing file.

.PARAMETER Module
    Specifies a module to use as the source of command names. All commands exported by the module will be attempted to be saved to the file.

.PARAMETER Force
    Normally the function will not overrride existing help elements in an existing file. Specifiy this to delete existing conflicting elements when a conflict heppends.

.EXAMPLE
    Save-XMLHelp -Command Get-Content -Path .\mymodule-help.xml
    
    This will save the current help for the command Get-Content to the given file.

.EXAMPLE
    Save-XMLHelp -Module MyModule -Path .\mymodule-help.xml

    This will save the help for all commands in the loaded module MyModule to the file. If the file is saved into the module, it should act as a valid Helpfile.
#>
function Save-XMLHelp {
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
        [Parameter(Mandatory,Position=1)][ValidateScript({
            if (Test-Path -Path $_ -IsValid -PathType Leaf){
                $true
            } else {
                throw "The value supplied to Path does not appear to be a valid path."
            }
        })][string]$Path,
        [switch]$Force
    )
    
    begin {
        if (Test-Path -Path $Path -PathType Leaf) {
            $Content = Get-Content -Path $Path
        } else {
            $Content = Set-Content -Path $Path -Value @'
<?xml version="1.0" encoding="utf-8"?>
<helpItems schema="maml">
</helpItems>
'@ -PassThru
        }

        try {
            $XML = [xml]$Content

        } catch {
            # we do this odd try as conversion errors are terminating but
            # also not. this means it's a proper terminating error.
            throw $_
        }

        if (-not $xml.helpItems) {
            $PSCmdlet.ThrowTerminatingError(
                ( New-Object System.Management.Automation.ErrorRecord -ArgumentList @(
                    [System.Management.Automation.RuntimeException]'XML file does not appear to be of correct format, root node "HelpItems" appears to be missing.',
                    'SaveXMLHelp.WrongExistingXML',
                    [System.Management.Automation.ErrorCategory]::InvalidData,
                    $xml
                    )
                )
            )
        }

        # This should create a list of all functions in the module
        if ($PSCmdlet.ParameterSetName -eq "Module"){
            $Command = Get-Command -Module $Module
        }

        $commandNS = "http://schemas.microsoft.com/maml/dev/command/2004/10"
        $mamlNS = "http://schemas.microsoft.com/maml/2004/10"
        $devNS = "http://schemas.microsoft.com/maml/dev/2004/10"
        
    }
    
    process {
        foreach ($SingleCommand in $Command) {

            if ($SingleCommand -is [System.Management.Automation.FunctionInfo]){
                $ThisCommand = [pscustomobject]@{ Command = $SingleCommand; Help = Get-Help $SingleCommand }
            } else {
                $ThisCommand = [pscustomobject]@{ Command = Get-Command ([string]$SingleCommand); Help = Get-Help ([string]$SingleCommand) }
            }

            # need to check if this command already exists

            $currentHelpItems = $xml.helpItems.ChildNodes
            $conflictItems = $currentHelpItems | Where-Object { $_.details.name -eq $ThisCommand.Command.name }
            if ($conflictItems) {
                if ($Force){
                    $conflictItems | ForEach-Object { [void]$xml.HelpItems.RemoveChild($_) }
                } else {
                    Write-Warning "Skipping command $($ThisCommand.Command.name) as it already exists at destination."
                    continue
                }
            }

            # create a blank required node.
            $commandNode = $xml.CreateNode([xmlnodetype]::element,'command','command',$commandNS)
            $commandNode.setAttribute('xmlns:maml',$mamlNS)
            $commandNode.setAttribute('xmlns:dev', $devNS)
            $commandNode.setAttribute('xmlns:MSHelp',"http://msdn.microsoft.com/mshelp")
            [void]$Xml.helpItems.AppendChild($commandNode)


            # details about command

            $details = New-XMLElement -Document $xml -Name details -prefix command -namespace $commandNS -children $(
                New-XMLElement -Document $xml -Name name -prefix command -innertext $ThisCommand.help.details.name -namespace $commandNS
                if ($ThisCommand.help.details.verb) {
                    $verb = $ThisCommand.help.details.verb
                    $noun = $ThisCommand.help.details.noun
                } else {
                    $verb,$noun = $ThisCommand.help.details.name -split '-'
                }
                New-XMLElement -Document $xml -Name verb -prefix command -innertext $verb -namespace $commandNS
                New-XMLElement -Document $xml -Name noun -prefix command -innertext $noun -namespace $commandNS
                New-XMLElement -Document $xml -Name description -prefix maml -namespace $mamlNS -Children $(
                    $SynopsisText = if ($ThisCommand.help.details.description.text) { $ThisCommand.help.details.description.text } else { "$($ThisCommand.help.details.name) Synopsis." }
                    $SynopsisText | ForEach-Object { 
                        New-XMLElement -Document $xml -Name para -prefix maml -namespace $mamlNS -innertext $_ 
                    }
                )
            )
            [void]$commandNode.AppendChild($details)

            
            # main description

            $DescriptionText = if ($ThisCommand.help.description.text) { $ThisCommand.help.description.text } else { "$($ThisCommand.help.details.name) Description." }
            $DescriptionItems = New-XMLElement -Document $xml -Name description -prefix maml -namespace $mamlNS -Children $(
                $DescriptionText | ForEach-Object { 
                    New-XMLElement -Document $xml -Name para -prefix maml -namespace $mamlNS -innertext $_ 
                }
            )

            [void]$commandNode.AppendChild($DescriptionItems)

            # find all parameters
            $ParameterObjects = @{} # keyed by para name
            $ThisCommand.Help.Parameters | Foreach-Object Parameter | ForEach-Object {
                if (([bool]$_.name) -and (-not $ParameterObjects[$_.name])){
                    $ParameterObjects[$_.name] = New-XMLElement -Document $xml -Name parameter -prefix command -namespace $commandNS -Children $(
                        New-XMLElement -Document $xml -Name name -prefix maml -namespace $mamlNS -innertext $_.name
                        New-XMLElement -Document $xml -Name Description -prefix maml -namespace $mamlNS -Children $(
                            $(if ($_.Description.Text) {$_.Description.Text} else { "Description for $($_.name)" }) | ForEach-Object {
                                New-XMLElement -Document $xml -Name para -prefix maml -namespace $mamlNS -innertext $_
                            }
                        )
                        if ($_.parameterValue) {
                            New-XMLElement -Document $xml -Name parameterValue -prefix command -namespace $commandNS -attributes @{
                                Required = [bool]($_.parameterValue.required)
                                variableLength = [bool]($_.parameterValue.variableLength)
                            } -innertext $_.parameterValue.toString()
                        }
                        New-XMLElement -Document $xml -Name type -prefix dev -namespace $devNS -Children $(
                            New-XMLElement -Document $xml -Name name -prefix maml -namespace $mamlNS -innertext $_.type.Name
                            New-XMLElement -Document $xml -Name uri -prefix maml -namespace $mamlNS -innertext $_.type.uri
                        )
                    ) -attributes @{
                        required=$_.required
                        variableLength=$_.variableLength
                        globbing=$_.globbing
                        pipelineInput=$_.pipelineInput
                        position=$_.position
                        aliases=$_.aliases
                    }
                }
            }
            $ThisCommand.Command.Parameters.getEnumerator() | Where-Object {$_.Value.IsDynamic} | ForEach-Object {
                if (-not $ParameterObjects[$_.Key]){
                    $ParameterObjects[$_.Key] = New-XMLElement -Document $xml -Name parameter -prefix command -namespace $commandNS -Children $(
                        New-XMLElement -Document $xml -Name name -prefix maml -namespace $mamlNS -innertext $_.Key
                        New-XMLElement -Document $xml -Name Description -prefix maml -namespace $mamlNS -Children $(
                            New-XMLElement -Document $xml -Name para -prefix maml -namespace $mamlNS -innertext $(
                                if ($_key.Attributes.HelpMessage){ $_key.Attributes.HelpMessage } else { "Description for $($_.Key)" }
                            )
                        )
                        New-XMLElement -Document $xml -Name parameterValue -prefix command -namespace $commandNS -attributes @{
                            required = [bool]$_.Key.Attributes.Mandatory
                        } -innertext ([string]$_.key.ParameterType)
                        New-XMLElement -Document $xml -Name type -prefix dev -namespace $devNS -Children $(
                            New-XMLElement -Document $xml -Name name -prefix maml -namespace $mamlNS -innertext ([string]$_.key.ParameterType)
                            New-XMLElement -Document $xml -Name uri -prefix maml -namespace $mamlNS -innertext ""
                        )
                    ) -attributes @{
                        required=[bool]$_.Key.Attributes.Mandatory
                        variableLength="false"
                        globbing=[bool]$_.Key.Attributes.ValueFromRemainingArguments
                        pipelineInput=$(
                            if ($_.Key.Attributes.ValueFromPipeline) { "true (ByValue)" } 
                            elseif ($_.Key.Attributes.ValueFromPipelineByPropertyName )  { "true (byProperty)" }
                            else { "false" }
                        )
                        position=[bool]$_.Key.Attributes.Position
                        aliases=""
                    }
                }
            }

            # usage

            $Syntax = New-XMLElement -Document $xml -Name syntax -prefix command -namespace $commandNS -Children $(
                $ThisCommand.help.syntax.SyntaxItem | ForEach-Object {
                    New-XMLElement -Document $xml -Name SyntaxItem -prefix command -namespace $commandNS -Children $(
                        New-XMLElement -Document $xml -Name name -prefix maml -namespace $mamlNS -innertext $_.name
                        $_.parameter.name | ForEach-Object {
                            if (([bool]$_) -and $ParameterObjects.ContainsKey($_) ) {
                                $ParameterObjects.$_.clone()
                            }
                        }
                    )
                }
            )

            [void]$commandNode.AppendChild($Syntax)

            #params 

            [void]$commandNode.AppendChild($(
                New-XMLElement -Document $xml -Name 'Parameters' -Prefix command -Namespace $commandNS -Children $(
                    # loop over found parameters
                    $ParameterObjects.GetEnumerator() | ForEach-Object {
                        $_.Value
                    }
                )
            ))

            # input types

            [void]$commandNode.AppendChild($(
                New-XMLElement -Document $xml -Name inputTypes -Prefix command -Namespace $commandNS -Children $(
                    $ThisCommand.help.InputTypes.InputType | ForEach-Object {
                        New-XMLElement -Name inputType -Prefix command -Namespace $commandNS -Children $(
                            New-XMLElement -Name type -Prefix dev -Namespace $devNS -Children $(
                                New-XMLElement -Name name -Prefix maml -Namespace $mamlNS -Innertext $_.type.name.trim()
                            )
                        )
                        $DescriptionText = if ($_.description) { 
                            $_.description
                        } elseif ($_.type.name -match 'None\s+') {
                            'This cmdlet does not accept any input.'
                        } elseif (-not $_.type.name) {
                            'This cmdlet does not accept any input.'
                        } else {
                            'InputType description'
                        }
                        New-XMLElement -Name description -Prefix maml -Namespace $mamlNS -Children $(
                            $DescriptionText | ForEach-Object {
                                New-XMLElement -Name para -Prefix maml -Namespace $mamlNS -Innertext $_
                            }
                        )
                    }
                )
            ))

            # output types

            [void]$commandNode.AppendChild($(
                New-XMLElement -Document $xml -Name returnValues -Prefix command -Namespace $commandNS -Children $(
                    $ThisCommand.help.returnValues.returnValue | ForEach-Object {
                        New-XMLElement -Name returnValue -Prefix command -Namespace $commandNS -Children $(
                            New-XMLElement -Name type -Prefix dev -Namespace $devNS -Children $(
                                New-XMLElement -Name name -Prefix maml -Namespace $mamlNS -Innertext $_.type.name
                            )
                        )
                        $DescriptionText = if ($_.description) { 
                            $_.description
                        } elseif ($_.type.name -match 'None\s+') {
                            'This cmdlet does not generate any output.'
                        } elseif (-not $_.type.name) {
                            'This cmdlet does not generate any output.'
                        } else {
                            'Output Type description'
                        }
                        New-XMLElement -Name description -Prefix maml -Namespace $mamlNS -Children $(
                            $DescriptionText | ForEach-Object {
                                New-XMLElement -Name para -Prefix maml -Namespace $mamlNS -Innertext $_
                            }
                        )
                    }
                )
            ))

            # command remarks

            [void]$commandNode.AppendChild($(
                New-XMLElement -Document $XML -Name alertSet -Prefix maml -Namespace $mamlNS -Children $(
                    # if not set this should not generate any nodes
                    if ($ThisCommand.help.alertSet.alert) {
                        $ThisCommand.help.alertSet.alert | ForEach-Object {
                            New-XMLElement -Name alert -Prefix maml -Namespace $mamlNS -Children $(
                                $_.Text | ForEach-Object {
                                    New-XMLElement -Name para -Prefix maml -Namespace $mamlNS -Innertext $_
                                }
                            )
                        }
                    }
                )
            ))

            # examples

            [void]$commandNode.AppendChild($(
                New-XMLElement -Document $xml -Name examples -Prefix command -Namespace $commandNS -Children $(
                    if ($ThisCommand.help.examples.example) {
                        # copy from help instead.
                        $ThisCommand.help.examples.example | ForEach-Object {
                            New-XMLElement -Name example -Prefix command -Namespace $commandNS -Children $(
                                New-XMLElement -Name title -Prefix maml -Namespace $mamlNS -Innertext $_.title
                                New-XMLElement -Name code -Prefix dev -Namespace $devNS -Innertext $_.code
                                New-XMLElement -Name remarks -Prefix dev -Namespace $devNS -Children $(
                                    $_.remarks.text | ForEach-Object {
                                        New-XMLElement -name para -Prefix maml -Namespace $mamlNS -Innertext $_
                                    }
                                )
                            )
                        }
                    } else {
                        $ThisCommand.Command.ParameterSets | ForEach-Object -Begin { $i = 0 } {
                            $i++
                            New-XMLElement -Name example -Prefix command -Namespace $commandNS -Children $(
                                New-XMLElement -Name title -Prefix maml -Namespace $mamlNS -Innertext "Example ${i}: $($_.name)"
                                New-XMLElement -Name remarks -Prefix dev -Namespace $devNS -Children $(
                                    New-XMLElement -name para -Prefix maml -Namespace $mamlNS -Innertext "Explanation of parameter set."
                                )
                                $code = $(
                                    $ThisCommand.help.details.name
                                    $_.Parameters | Where-Object IsMandatory -eq $true | ForEach-Object {
                                        "-$($_.Name)"
                                        "<$($_.ParameterType.name)>"
                                    }
                                ) -join ' '
                                New-XMLElement -Name code -Prefix dev -Namespace $devNS -Innertext $code
                            )
                        }
                    }
                )
            ))

            # related info

            [void]$commandNode.AppendChild($(
                New-XMLElement -Document $xml -Name relatedLinks -Prefix command -Namespace $commandNS -Children $(
                    if ($ThisCommand.help.relatedLinks.navigationLink) {
                        New-XMLElement -Name navigationLink -Prefix maml -Namespace $mamlNS -Children $(
                            New-XMLElement -Name linkText -Prefix maml -Namespace $mamlNS -Innertext $ThisCommand.help.relatedLinks.navigationLink.linkText
                            New-XMLElement -Name uri -Prefix maml -Namespace $mamlNS -Innertext $ThisCommand.help.relatedLinks.navigationLink.uri
                        )
                    }
                )
            ))

        }
        
    }
    
    end {
        $xml.Save((Get-ExpandedPath $Path))
    }
}