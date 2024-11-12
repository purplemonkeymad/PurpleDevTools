function New-ConfigurationCommand {
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
        [string]
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
            $SettingPath = "'" + (Join-Path $env:APPDATA $Noun) + "'"
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