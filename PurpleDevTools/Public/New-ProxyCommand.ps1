function New-ProxyCommand {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Name,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        $ProxiedCommand,
        $OutFile
    )
    
    begin {
        
    }
    
    process {
        try { 
            $command = Get-Command $ProxiedCommand -ErrorAction Stop
            $proxyText = [System.Management.Automation.ProxyCommand]::Create($command)
            if (-not $Name) {
                return $proxyText
            }
            $commandText = $(
                "function $name {"
                $proxyText -split [System.Environment]::NewLine | ForEach-Object{ "`t$_"}
                "}"
            )
            if (-not $OutFile) {
                return ($commandText -join [System.Environment]::NewLine)
            }
            $commandText | Set-Content $OutFile
        } catch {
            Write-Error $_
        }
    }
    
    end {
        
    }
}