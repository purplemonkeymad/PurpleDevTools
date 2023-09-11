function New-MarkdownCodeBlock {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string[]]$Content,
        [Parameter()]
        [ValidateSet('Indentation','Fences')]
        [string]$Style,
        [string]$FenceLanguage
    )
    
    begin {
        
    }
    
    process {
        
        $Output=$null

        if ($Style -eq 'Fences') {
            $Output = $(
                if ($FenceLanguage) {
                    '' # blank line for ln around fences
                    '```' + $FenceLanguage
                } else {
                    '```'
                }
                $Content
                '```'
                ''
            )
        } else {
            $Output = $Content -split '\r?\n' | 
                ForEach-Object -Begin {""} -Process { "    " + $_ } #begin add a blank line to start of code area
        }

        $Output -join "`n"

    }
    
    end {
        
    }
}