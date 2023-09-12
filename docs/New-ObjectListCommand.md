# New-ObjectListCommand

Create a set of command to manage a saved list for a set class.

|Skip To|
|-------|
|[Syntax](#syntax) [Description](#description) [Parameters](#parameters) [Examples](#examples)|

## Syntax

```powershell
New-ObjectListCommand [-Type] <Type> [-Path] <String> [[-ListPath] <String>] [[-Noun] <String>] [[-IdentityPropertyName] <String>]
```

## Description

Takes a class file/name and creates get/add/set/new/remove verbs for the class. The list will be saved to either a 
Specified path or a variable name for a path.

## Parameters

This command provides the following parameters: [Type](#type) [Path](#path) [ListPath](#listpath) [Noun](#noun) [IdentityPropertyName](#identitypropertyname)

### Type

     -Type <Type>

Class to use as the base of the template. This can either be the type object or the full name of the type as a
string.

Supported classes should have a 0 argument constructor or support casting from a hashtable. ie [type]@{property=value}

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|Type|true|false|1||

### Path

     -Path <String>

A folder path for the output files of the template.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|true|false|2||

### ListPath

     -ListPath <String>

A code snippit, or script block to get the file used to serialize the list of objects. If you supply a path
you should wrap it in quotes ie: {"$env:programdata\example.clixml"}

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|false|false|3||

### Noun

     -Noun <String>

Use a custom Noun for the command names, if unspecified the type's base name will be used instead.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|false|false|4||

### IdentityPropertyName

     -IdentityPropertyName <String>

Specify which property is used as the identity. It will be treated as unique and will be required on
any parameters.

If this is unspecified, command that require a unique identity to change an object will not be generated.
ie remove- and set- will not exist if unspecified.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|false|false|5||

## Examples

### -------------------------- EXAMPLE 1 --------------------------

    New-ObjectListCommand -Class [test] -Path .\ -ListPath '$env:programdata\test.json'

Uses the loaded type test as the base of the command templates. Function files will be saved to '.\',
and the list save location will be '$env:programdata\test.json'.

