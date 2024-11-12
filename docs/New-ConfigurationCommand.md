# New-ConfigurationCommand

Create new commands to save and update settings based on a class.

|Skip To|
|-------|
|[Syntax](#syntax) [Description](#description) [Parameters](#parameters) [Examples](#examples)|

## Syntax

```powershell
New-ConfigurationCommand [-Type] <Type> [-Path] <String> [[-SettingPath] <Object>] [[-Noun] <String>]
```

## Description

Creates new commands that will save, update, and load configuration values.

The command is based around a single type, it's properties are used as the possible configuration values.
It's best to use a quite basic type, a constructor with 0 arguments is required for the configuration.

The type definition is not included by the commands, so make sure your module imports/creates it.

## Parameters

This command provides the following parameters: [Type](#type) [Path](#path) [SettingPath](#settingpath) [Noun](#noun)

### Type

     -Type <Type>

The type object of the type to use (or a string that will be recognised as a type.)

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|Type|true|false|1||

### Path

     -Path <String>

Output path for the function files, one for each command.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|true|false|2||

### SettingPath

     -SettingPath <Object>

Path to store the configuration data in. By default uses roaming appdata & the non.

You can specify either a string (which will be used as is,) or you can provide
a scriptblock that should output the path.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|Object|false|false|3||

### Noun

     -Noun <String>

Noun to use for new commands (part after the dash [-].)

If not specified, will use the type's short name.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|false|false|4||

## Examples

### -------------------------- EXAMPLE 1 --------------------------

    class MyConfiguration {
        [string]$Identity
        [int]$Value
    }
    PS > New-ConfigurationCommand -Type [MyConfiguration] -Path ./

Will create the commands in the current directory. The names will be Get-MyConfiguration
and Set-MyConfiguration. The default path to store the settings will be at
$env:appdata/MyConfiguration.xml. The Parameters on the set command will be
Identity and Value.

### -------------------------- EXAMPLE 2 --------------------------

    New-ConfigurationCommand -Type [MyConfiguration] -Path ./ -Noun ModuleConfigruation -SettingsPath { [MyConfiguration]::GetPath($IsLinux) }

Will create the commands in the current directory. The names will be Get-ModuleConfigruation
and Set-ModuleConfigruation. The path to store the setting will be the result of the static
method on the configration object.

