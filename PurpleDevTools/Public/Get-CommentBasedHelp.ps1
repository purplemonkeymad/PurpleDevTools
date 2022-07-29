
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
                        $_.Code -replace '^PS C:\\>',''
                        $_.remarks.Text -join $DoubleNewLine
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