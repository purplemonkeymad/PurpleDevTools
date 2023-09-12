function ConvertTo-MarkdownTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [object]
        $InputObject
    )
    
    begin {
        # use first object to determine headers
        $firstObject = $true
        $headers = @()
        $output = [System.Text.StringBuilder]::new()
    }
    
    process {
        if ($firstObject) {
            $headers = $InputObject.psobject.properties.Name
            $firstObject = $false

            #header row
            $null=$output.Append('|').Append((
                $headers -join '|'
            )).AppendLine('|')

            # line row
            $null=$output.Append('|').Append((
                '---|' * $headers.count
            )).AppendLine()

        }

        # we must read the properties in the same order as the header,
        # as it's possible they might have a different order.

        $null=$output.Append('|')
        foreach ($headersItem in $headers) {
            $null=$output.Append($( 
                if ($InputObject.psobject.properties[$headersItem].Value) {
                    $InputObject.psobject.properties[$headersItem].Value.toString() + '|'
                } else {'|'} 
            ))
        }
        $null=$output.AppendLine()

    }
    
    end {
        $output.ToString()
    }
}