function Convert-HelpExampleToMarkdown {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [Object]$InputObject
    )
    
    begin {
        
    }
    
    process {
        # check type as types are not classes
        if ($InputObject.pstypenames -notcontains 'MamlCommandHelpInfo#example' -and 
            $InputObject.pstypenames -notcontains 'ExtendedCmdletHelpInfo#example') {
            Write-Error "Input object is not a parameter from help, Instead got types: $($InputObject.pstypenames -join ', ')"
            return
        }
        
        $output = $(
            New-MarkdownSection -Name $InputObject.title -Content $(
                if ($InputObject.Code) {
                    New-MarkdownCodeBlock -Content $InputObject.Code
                    ""
                }
                $InputObject.remarks | Convert-HelpDescriptionToMarkdown
            ) 
        )

        $output -join [System.Environment]::NewLine
    }
    
    end {
        
    }
}