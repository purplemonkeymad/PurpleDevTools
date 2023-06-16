<#
.SYNOPSIS
    Create a set of command to manage a saved list for a set class.
.DESCRIPTION
    Takes a class file/name and creates get/add/set/new/remove verbs for the class. The list will be saved to either a 
    Specified path or a variable name for a path.
.NOTES
    
.LINK
    
.EXAMPLE
    New-ObjectListCommand -Class [test] -Path .\ -ListPath '$env:programdata\test.json'
    Uses the loaded type test as the base of the command templates. Function files will be saved to '.\',
    and the list save location will be '$env:programdata\test.json'.
#>
function New-ObjectListCommand {
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
        $ListPath,

        [Parameter()]
        [string]
        $Noun,

        [Parameter()]
        [string]
        $IdentityPropertyName
    )
    
    end {
        
        # type should exist at this point so not doing any checks.

        $PropertyList = $Type.GetProperties()
        
        $ModulePath = $MyInvocation.MyCommand.Module.Path | split-path -Parent
        $TemplatePath = Join-Path $ModulePath (join-path 'Templates' 'ObjectListCommand')

        # parameter fallback logic

        $templateList = if($IdentityPropertyName) {
            'New','Save','Get','Add','Set','Remove'
        } else {
            'New','Save','Get','Add'
        }

        if (-not $Noun) {
            $Noun = $Type.Name
        }

        if (-not $ListPath) {
            $ListPath = "'" + (Join-Path $env:APPDATA $Noun) + "'"
        }

        # now we need to generate the variables for the templates

        $templateProperties = @{
            typename = $Type.FullName
            listpath = $ListPath
            parameters = $PropertyList
            noun = $Noun
            IdentityPropertyName = $IdentityPropertyName
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

