function New-MarkdownCodeBlock {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string[]]$Content
    )
    
    begin {
        
    }
    
    process {
        
        $Output = $Content -split '\r?\n' | 
            ForEach-Object -Begin {""} -Process { "    " + $_ } #begin add a blank line to start of code area
        $Output -join "`n"

    }
    
    end {
        
    }
}