# Save-MarkdownHelp

Save help text to a markdown format for display in github etc.

|Skip To|
|-------|
|[Syntax](#syntax) [Description](#description) [Parameters](#parameters) [Examples](#examples)|

## Syntax

```powershell
Save-MarkdownHelp [-Command] <Object> [[-Path] <String>] [-UseReadmeAsIndexName <>]
```

```powershell
Save-MarkdownHelp -Module <String> [[-Path] <String>] [-UseReadmeAsIndexName <>]
```

## Description

Converts the help system from Get-Help into a prettier markdown format.
Help for commands need to already be written in a way get help can see them,
either comment based or xml comments.

## Parameters

This command provides the following parameters: [Command](#command) [Module](#module) [Path](#path) [UseReadmeAsIndexName](#usereadmeasindexname)

### Command

     -Command <Object>

Command to get/save help for. Should take either a command object or name.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|Object|true|true (ByValue)|1||

### Module

     -Module <String>

Get all command help for the specified module.
This is better than piping in as if you specifiy Path then you will also get a module index.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|true|false|named||

### Path

     -Path <String>

Directory to save the markdown text to. File will be created as the command name.

If using module option, then an index will also be created.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|false|false|2||

### UseReadmeAsIndexName

     -UseReadmeAsIndexName <SwitchParameter>

By default index is the module name, use this to use "Readme.md" as the same instead.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|SwitchParameter|false|false|named||

## Examples

### -------------------------- EXAMPLE 1 --------------------------

    Save-MarkdownHelp -Command Get-Help

Outputs a string for each command that contains the markdown contents of the specified
command's help.

### -------------------------- EXAMPLE 2 --------------------------

    Save-MarkdownHelp -Command Get-Help -Path ./docs/

Exports the specified command's help infromation to the specified folder.
It will create a single file called "Get-Help.md" containing the help.

### -------------------------- EXAMPLE 3 --------------------------

    Save-MarkdownHelp -Module MyModule -Path ./docs/

Exports all help from the specified module into the folder docs under the current folder.
This will be a collection of individual command helps, and a single MyModule.md with an index
and description of the module.

