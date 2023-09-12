# New-ProxyCommand

Creates a new function that proxies another command.

|Skip To|
|-------|
|[Syntax](#syntax) [Description](#description) [Parameters](#parameters) [Examples](#examples)|

## Syntax

```powershell
New-ProxyCommand -Command <Object>
```

```powershell
New-ProxyCommand -Command <Object> -Name <String> -Path <String>
```

```powershell
New-ProxyCommand -Command <Object> [-Name <String>]
```

## Description

Creates a new function that proxies another command, using the ProxyCommand class. The functions can be edited after the fact to create a function with only minor behavour changes to the original command.

## Parameters

This command provides the following parameters: [Command](#command) [Name](#name) [Path](#path)

### Command

     -Command <Object>

The comand to create a proxy function for, either as a string name or a command object.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|Object|true|true (ByPropertyName)|named||

### Name

     -Name <String>

The name for the new function. Required to save the function to a file.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|true|true (ByPropertyName)|named||

### Path

     -Path <String>

A destination file for saving the proxy function to.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|true|true (ByPropertyName)|named||

## Examples

### -------------------------- EXAMPLE 1 --------------------------

    New-ProxyCommand -ProxiedCommand Get-Content
    Will output to the console the code for to proxy the command Get-Content and no more.

### -------------------------- EXAMPLE 2 --------------------------

    New-ProxyCommand -ProxiedCommand Get-Content -Name Get-ModifiedContent

Will output to the console the function definition to proxy the command Get-Content. The name of the function in the definition is Get-ModifiedContent.

### -------------------------- EXAMPLE 3 --------------------------

    New-ProxyCommand -ProxiedCommand Get-Content -Name Get-ModifiedContent -OutFile .\myfile.ps1

Will save to the specified file the function definition to proxy the command Get-Content. The name of the function in the definition is Get-ModifiedContent.

