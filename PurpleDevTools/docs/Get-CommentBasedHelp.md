# Get-CommentBasedHelp

Generates a Comment Based Help template from a existing command.

|Skip To|
|-------|
|[Syntax](#syntax) [Description](#description) [Parameters](#parameters) [Examples](#examples)|

## Syntax

```powershell
Get-CommentBasedHelp [-Name] <String>
```

## Description

Generates a template that can be used as a comment based help. It will pull the information from the current session so templates for help-less commands can be created. If help already exists it will try to use that.

## Parameters

This command provides the following parameters: [Name](#name)

### Name

     -Name <String>

The name of the command to generate help for.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|true|true (ByValue, ByPropertyName)|1||

## Examples

### -------------------------- EXAMPLE 1 --------------------------

Get the help comment for the command specified by the Name parameter.

