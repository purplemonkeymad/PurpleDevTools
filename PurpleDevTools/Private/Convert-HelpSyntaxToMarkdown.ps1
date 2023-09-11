function Convert-HelpSyntaxToMarkdown {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [Object]$InputObject
    )
    
    begin {
        
    }
    
    process {
        # check type as types are not classes
        if ($InputObject.pstypenames -notcontains 'MamlCommandHelpInfo#syntaxItem' -and 
            $InputObject.pstypenames -notcontains 'ExtendedCmdletHelpInfo#syntaxItem') {
            Write-Error "Input object is not a parameter from help, Instead got types: $($InputObject.pstypenames -join ', ')"
            return
        }

        $output = $(
            $InputObject.name
            foreach ($param in $InputObject.Parameter) {
                $namesection = '-' + $Param.Name
                if ($param.position -ne 'Named'){
                    $namesection = "[$namesection]"
                }
                $paramsection = $(
                    $namesection
                    if ($param.type.name -ne 'switch'){
                        '<' + $param.parameterValue + '>'
                    }
                )
                if ($Param.required -eq $false) {
                    $paramsection = "[$paramsection]"
                }
                $paramsection
            }
        )

        $output = New-MarkdownCodeBlock -Content ($output -join ' ') -Style Fences -FenceLanguage powershell
        $output
    }
    
    end {
        
    }
}