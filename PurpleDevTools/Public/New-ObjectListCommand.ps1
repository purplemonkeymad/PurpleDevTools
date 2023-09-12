<#

.Synopsis
Create a set of command to manage a saved list for a set class.

.Description
Takes a class file/name and creates get/add/set/new/remove verbs for the class. The list will be saved to either a 
Specified path or a variable name for a path.

.Parameter Type
Class to use as the base of the template. This can either be the type object or the full name of the type as a
string.

Supported classes should have a 0 argument constructor or support casting from a hashtable. ie [type]@{property=value}

.Parameter Path
A folder path for the output files of the template.


.Parameter ListPath
A code snippit, or script block to get the file used to serialize the list of objects. If you supply a path
you should wrap it in quotes ie: {"$env:programdata\example.clixml"}

.Parameter Noun
Use a custom Noun for the command names, if unspecified the type's base name will be used instead.


.Parameter IdentityPropertyName
Specify which property is used as the identity. It will be treated as unique and will be required on
any parameters.

If this is unspecified, command that require a unique identity to change an object will not be generated.
ie remove- and set- will not exist if unspecified.


.Example
New-ObjectListCommand -Class [test] -Path .\ -ListPath '$env:programdata\test.json'

Uses the loaded type test as the base of the command templates. Function files will be saved to '.\',
and the list save location will be '$env:programdata\test.json'.

.Links

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

        ## check for eps module, if not error out.

        if ( -not ( Get-Command -Name Invoke-EpsTemplate -ErrorAction SilentlyContinue ) ) {
            Write-Error -Message "The EPS (Embbeded Powershell) module is needed for this template. Please install it with: Install-Module EPS" -ErrorAction Stop -TargetObject 'Invoke-EpsTemplate' -ErrorId 'PurpleDevTools.MissingEPSModule' -Category ResourceUnavailable
        }
        
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

