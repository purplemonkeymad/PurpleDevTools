# Save-XMLHelp

Save the help for a command to a file in XML help format.

|Skip To|
|-------|
|[Syntax](#syntax) [Description](#description) [Parameters](#parameters) [Examples](#examples)|

## Syntax

```powershell
Save-XMLHelp [-Command] <Object> [-Path] <String> [-Force <>]
```

```powershell
Save-XMLHelp -Module <String> [-Path] <String> [-Force <>]
```

## Description

This will save the current help information for a command in a format that can be used for XML Help.
It's good for writting help for a command with dynamic parameters as they do not work with the comment based help system.
Existing help is not required as PS generates help for any command automatically, this command will fill it out with some example text if that is the case.

## Parameters

This command provides the following parameters: [Command](#command) [Module](#module) [Path](#path) [Force](#force)

### Command

     -Command <Object>

The command that help will be retrived for, either as a command object or the name of the command.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|Object|true|true (ByValue)|1||

### Module

     -Module <String>

Specifies a module to use as the source of command names. All commands exported by the module will be attempted to be saved to the file.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|true|false|named||

### Path

     -Path <String>

File path to save the help to. This can be an existing path. If the file exists the new xml elements will be merged into the existing file.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|true|false|2||

### Force

     -Force <SwitchParameter>

Normally the function will not overrride existing help elements in an existing file. Specifiy this to delete existing conflicting elements when a conflict heppends.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|SwitchParameter|false|false|named||

## Examples

### -------------------------- EXAMPLE 1 --------------------------

    Save-XMLHelp -Command Get-Content -Path .\mymodule-help.xml

This will save the current help for the command Get-Content to the given file.

### -------------------------- EXAMPLE 2 --------------------------

    Save-XMLHelp -Module MyModule -Path .\mymodule-help.xml

This will save the help for all commands in the loaded module MyModule to the file. If the file is saved into the module, it should act as a valid Helpfile.

