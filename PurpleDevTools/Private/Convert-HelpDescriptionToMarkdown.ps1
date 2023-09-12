function Convert-HelpDescriptionToMarkdown {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [Object]$InputObject
    )
    
    begin {
        
    }
    
    process {
        switch ($InputObject.pstypenames) {
            MamlParaTextItem {
                $InputObject.Text
                break;
            }
            Default {
                "$InputObject"
            }
        }
    }
    
    end {
        
    }
}