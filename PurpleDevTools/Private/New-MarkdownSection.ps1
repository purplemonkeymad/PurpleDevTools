function New-MarkdownSection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [String]$Name,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Content
    )
    
    begin {
        
    }
    
    process {
        $output = $Content -split '\r?\n' | 
            ForEach-Object -Begin {
                "# $Name"
                "" # new line after header
            } -Process {
                # we need to check if there is a section header inthe contents
                # if there is we need to "reduce" the section header by adding a new #

                if ($_ -match '^#') {
                    '#'+$_
                } else { $_ }
            }
        $output -join "`n"
    }
    
    end {
        
    }
}