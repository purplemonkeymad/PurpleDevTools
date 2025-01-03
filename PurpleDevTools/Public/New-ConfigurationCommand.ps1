function New-ConfigurationCommand {
    <#

    .Synopsis
    Create new commands to save and update settings based on a class.

    .Description
    Creates new commands that will save, update, and load configuration values.

    The command is based around a single type, it's properties are used as the possible configuration values.
    It's best to use a quite basic type, a constructor with 0 arguments is required for the configuration.

    The type definition is not included by the commands, so make sure your module imports/creates it.

    .Parameter Noun
    Noun to use for new commands (part after the dash [-].)

    If not specified, will use the type's short name.

    .Parameter Path
    Output path for the function files, one for each command.

    .Parameter SettingPath
    Path to store the configuration data in. By default uses roaming appdata & the non.

    You can specify either a string (which will be used as is,) or you can provide
    a scriptblock that should output the path. 

    .Parameter Type
    The type object of the type to use (or a string that will be recognised as a type.)

    .Example
    class MyConfiguration {
        [string]$Identity
        [int]$Value
    }
    PS > New-ConfigurationCommand -Type [MyConfiguration] -Path ./

    Will create the commands in the current directory. The names will be Get-MyConfiguration
    and Set-MyConfiguration. The default path to store the settings will be at
    $env:appdata/MyConfiguration.xml. The Parameters on the set command will be
    Identity and Value.

    .Example
    New-ConfigurationCommand -Type [MyConfiguration] -Path ./ -Noun ModuleConfigruation -SettingsPath { [MyConfiguration]::GetPath($IsLinux) }

    Will create the commands in the current directory. The names will be Get-ModuleConfigruation
    and Set-ModuleConfigruation. The path to store the setting will be the result of the static
    method on the configration object.

    .link
    https://github.com/purplemonkeymad/PurpleDevTools/blob/master/docs/New-ConfigurationCommand.md
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Alias('Class')]
        [type]
        $Type,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('OutPath')]
        [string]
        $Path,

        [Parameter()]
        $SettingPath,

        [Parameter()]
        [string]
        $Noun
    )
    end {
        
        ## check for eps module, if not error out.

        if ( -not ( Get-Command -Name Invoke-EpsTemplate -ErrorAction SilentlyContinue ) ) {
            Write-Error -Message "The EPS (Embbeded Powershell) module is needed for this template. Please install it with: Install-Module EPS" -ErrorAction Stop -TargetObject 'Invoke-EpsTemplate' -ErrorId 'PurpleDevTools.MissingEPSModule' -Category ResourceUnavailable
        }
        
        # type should exist at this point so not doing any checks.

        $PropertyList = $Type.GetProperties()
        
        $ModulePath = $MyInvocation.MyCommand.Module.Path | split-path -Parent
        $TemplatePath = Join-Path $ModulePath (join-path 'Templates' 'ConfigurationCommand')

        # parameter fallback logic

        $templateList = 'Get','Set'

        if (-not $Noun) {
            $Noun = $Type.Name
        }

        if (-not $SettingPath) {
            $SettingPath = '$env:APPDATA',"$Noun.xml" -join '/'
        }

        ## check what type we were given as a path to the settings.
        ## scriptblocks need to be wrapped in a sub-expression
        ## while anything else is probably a string so needs quotes

        $SettingPath = if ($SettingPath -is [scriptblock]) {
            '$(' + $SettingPath.ToString() + ')'
        } else {
            "'" + $SettingPath + "'"
        }

        # now we need to generate the variables for the templates

        $templateProperties = @{
            typename = $Type.FullName
            SettingPath = $SettingPath
            parameters = $PropertyList
            noun = $Noun
        }

        foreach($template in $templateList) {
            $templateProperties.($template+'functionname') = ($template+'-'+$Noun)
        }

        # save templates to files

        foreach($template in $templateList) {
            $contents = Invoke-EpsTemplate -Template (Get-Content -raw ("$TemplatePath/$template")) -Binding $templateProperties
            $contents | Set-Content -LiteralPath (Join-Path $Path ($template+'-'+$Noun+'.ps1'))
        }

    }
}