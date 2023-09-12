function Convert-HelpParameterToMarkdown {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [Object]$InputObject
    )
    
    begin {
        
    }
    
    process {
        # check type as types are not classes
        if ($InputObject.pstypenames -notcontains 'ExtendedCmdletHelpInfo#parameter' -and
            $InputObject.pstypenames -notcontains 'MamlCommandHelpInfo#parameter') {
            Write-Error "Input object is not a parameter from help, Instead got types: $($InputObject.pstypenames -join ', ')"
            return
        }

        $output = [System.Text.StringBuilder]::new()

        # param name is a header of sorts
        $null = $output.AppendLine((
            "# " + $InputObject.name
        )).AppendLine() # blank line after header

        # syntax section

        $null = $output.AppendLine((
            New-MarkdownCodeBlock -Content @"
 -$($InputObject.name)$(if ($InputObject.parameterValue){ ' <'+$InputObject.parameterValue+'>' })
"@
        ))

        # description
        $null = $output.AppendLine()
        foreach ($Paragraph in $InputObject.description) {
            if ($Paragraph.Text) {
                $null=$output.AppendLine($Paragraph.Text).AppendLine() ## double line for each end of paragraph
            }
        }

        # add technical values as a table

        $properties = $InputObject | 
            Select-Object @{n='Type';e={$_.type.name}},Required,PipelineInput,Position,Aliases |
            ConvertTo-MarkdownTable

        $null=$output.AppendLine($properties)

        $output.ToString()
    }
    
    end {
        
    }
}