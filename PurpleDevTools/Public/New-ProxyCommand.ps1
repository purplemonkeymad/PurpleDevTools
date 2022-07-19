<#
.SYNOPSIS
    Creates a new function that proxies another command.
.DESCRIPTION
    Creates a new function that proxies another command, using the ProxyCommand class. The functions can be edited after the fact to create a function with only minor behavour changes to the original command.
.NOTES
    The functrion is only created as-is, if the proxied command is changed then the new function may fail to work correctly.
.EXAMPLE
    New-ProxyCommand -ProxiedCommand Get-Content
    Will output to the console the code for to proxy the command Get-Content and no more.

.EXAMPLE
    New-ProxyCommand -ProxiedCommand Get-Content -Name Get-ModifiedContent
    Will output to the console the function definition to proxy the command Get-Content. The name of the function in the definition is Get-ModifiedContent.

.EXAMPLE
    New-ProxyCommand -ProxiedCommand Get-Content -Name Get-ModifiedContent -OutFile .\myfile.ps1
    Will save to the specified file the function definition to proxy the command Get-Content. The name of the function in the definition is Get-ModifiedContent.

.PARAMETER ProxiedCommand
    The comand to create a proxy function for, either as a string name or a command object.
.PARAMETER Name
    The name for the new function.
.PARAMETER OutFile
    A destination file for saving the proxy function to. Will do nothing if Name is not specified.

#>
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