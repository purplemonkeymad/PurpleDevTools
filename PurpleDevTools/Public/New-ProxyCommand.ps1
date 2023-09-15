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

.PARAMETER Command
    The comand to create a proxy function for, either as a string name or a command object.
.PARAMETER Name
    The name for the new function. Required to save the function to a file.
.PARAMETER Path
    A destination file for saving the proxy function to.

.INPUTS
    System.String
    System.Management.Automation.CmdletInfo
    System.Management.Automation.FunctionInfo
.OUTPUTS
    System.String

.LINK
https://github.com/purplemonkeymad/PurpleDevTools/blob/master/docs/New-ProxyCommand.md

#>
function New-ProxyCommand {
    [CmdletBinding(DefaultParameterSetName="TextOut")]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        $Command,

        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName="Name")]
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="File")]
        [string]$Name,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="File")]
        [string]$Path
    )
    
    begin {
        
    }
    
    process {
        try { 
            $command = Get-Command $Command -ErrorAction Stop
            $proxyText = [System.Management.Automation.ProxyCommand]::Create($command)
            if (-not $Name) {
                return $proxyText
            }
            $commandText = $(
                "function $name {"
                $proxyText -split [System.Environment]::NewLine | ForEach-Object{ "    $_"}
                "}"
            )
            if (-not $Path) {
                return ($commandText -join [System.Environment]::NewLine)
            }
            $commandText | Set-Content $Path
        } catch {
            Write-Error $_
        }
    }
    
    end {
        
    }
}