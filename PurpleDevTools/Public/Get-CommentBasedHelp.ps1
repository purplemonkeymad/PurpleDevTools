<#

.SYNOPSIS
Generates a Comment Based Help template from a existing command.

.description
Generates a template that can be used as a comment based help. It will pull the information from the current session so templates for help-less commands can be created. If help already exists it will try to use that.

.Parameter Name
The name of the command to generate help for.

.EXAMPLE
Get-CommentBasedHelp -Name <String>
Get the help comment for the command specified by the Name parameter.

#>
function Get-CommentBasedHelp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('CommandName')]
        [String]$Name
    )
    
    begin {
        
    }
    
    process {
        $help = Get-Help -Name $Name
        $command = Get-Command -Name $Name
        if (-not $help -or -not $command) {
            Write-Error -Message "Command or Help for command '$name' was not found." -TargetObject $Name
            return
        }

        $NewLine = [System.Environment]::NewLine
        $DoubleNewLine = $NewLine + $NewLine

        $HelpParts = $(
            '<#' # start comment
            # Synopsis should always be in the output
            $(
                '.SYNOPSIS'
                if ($help.Synopsis -and $help.Synopsis -notmatch "^\r?\n") {
                    $help.Synopsis
                } else {
                    'A Brief description of the command.'
                }
            ) -join $NewLine

            # Description should always be in the output
            $(
                '.description'
                if ($help.description) {
                    # multiple paras possible so join with double newlines.
                    $help.description.Text -join $DoubleNewLine
                } else {
                    'A Longer description of the command.'
                }
            ) -join $NewLine

            # params are optional
            if ($help.parameters) {
                $help.parameters.parameter | ForEach-Object {
                    $(
                        ".Parameter $($_.Name)"
                        $_.description.Text -join $DoubleNewLine
                    ) -join $NewLine
                }
            }

            # if we have examples, then show them, else generate a template from the parameter sets.
            if ($help.examples) {
                $help.Examples.Example | ForEach-Object {
                    $(
                        '.EXAMPLE'
                        if ($_.Code){
                            $_.Code -replace '^PS C:\\>',''
                        }
                        if ($_.introduction){
                            $_.introduction.Text -join $DoubleNewLine
                        }
                        ($_.remarks.Text | where-Object {-not [string]::IsNullOrWhiteSpace($_) }) -join $DoubleNewLine
                    ) -join $NewLine
                }
            } else {
                $command.ParameterSets | ForEach-Object {
                    $(
                        '.EXAMPLE'
                        # we can create the code line from the parameter sets
                        $(
                            $help.Name
                            $_.Parameters | Where-Object IsMandatory -eq $true | ForEach-Object {
                                "-$($_.Name)"
                                "<$($_.ParameterType.name)>"
                            }
                        ) -join ' '
                        "A description of how to use parameter set $($_.Name)"
                    ) -join $NewLine
                }
            }

            # help links
            if ($help.relatedLinks.navigationlink) {
                $(
                    '.Links'
                    $help.relatedLinks.navigationlink | ForEach-Object {
                        $_.uri
                    }
                ) -join $NewLine
            }

            '#>' # end comment
        )

        $HelpParts -Join $DoubleNewLine
    }
    
    end {
        
    }
}