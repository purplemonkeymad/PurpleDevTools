# New-TypeFormatData

Create a new Format Data View for a class.

|Skip To|
|-------|
|[Syntax](#syntax) [Description](#description) [Parameters](#parameters) [Examples](#examples)|

## Syntax

```powershell
New-TypeFormatData [-TypeName] <String[]> [-View] <String> [-Properties] <Object> [[-Group] <Object>] [[-Path] <Object>] [-ViewOptions <Object>]
```

## Description

Creates the xml for a new FormatData file for a given class. Can also target an existing Format File to add to it.

## Parameters

This command provides the following parameters: [TypeName](#typename) [View](#view) [Properties](#properties) [Group](#group) [Path](#path) [ViewOptions](#viewoptions)

### TypeName

     -TypeName <String[]>

Specify the TypeName(s) for this view, if more that one type is spcified, then a single view is created to target all types.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String[]|true|true (ByPropertyName)|1||

### View

     -View <String>

Specify the Formatting view that will be used. Table, List, Wide or Custom.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|String|true|true (ByPropertyName)|2||

### Properties

     -Properties <Object>

A list of the properties that will be visible by default in the View specified.

The Properties can be specified as a list of strings. This will use the default settings for the property and use the Name as the Display Name.

Alternatively the Property can be specified as a object with a specific set of properties. If this is used one of the properties PropertyName or ScriptBlock are required. The list of properties that can be used are:

* DisplayName  : The shown name of the property, this will be the column header in table views.
* PropertyName : Property name that the property should use as the source of the value. (Cannot, be used at the same time as ScriptBlock.)
* ScriptBlock  : A Script that is used to evaluate the property at dispaly time. Use $_ or $PSItem to refer to the current object being displayed. (Cannot, be used at the same time as PropertyName.)
* Width        : The width in charaters for the specified Column (Table Only.)
* Alignment    : The alignment of the Value in the specified Column, eg Left, Right (Table Only.)
* Condition    : A script block to determine if the List property should be shown, return true to show the property (List Only.)
* Format       : Formats the property value using the given format string. (Wide Only.)

Custom format has it's own list of properties, but support strings as exact text and scriptblocks:

* Text    : Alternative Text format specifier. (Must be only property.)
* NewLine : New line Character, does not need to have a value but must exist to be detected (Must be only property.)
* Frame   : A section that can contain more items, specified as the value.
* LeftIndent : Indentation of the Frame block in number of characters.
* RightIndent : Indentation of the Frame block in number of characters.
* FirstLineIndent : Indentation of the first line of the frame block in number of characters.
* FirstLineHanging : Right Indentation of the first line of the frame block in number of characters.

If the View type was set to Wide, then only first property is used. If you want multiple properties in a Wide view, use a script block to produce the string you want to see.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|Object|true|true (ByPropertyName)|3||

### Group

     -Group <Object>

Specifiy the Grouping property. This can be either a string of the name of the property to group on, or an object with a specific set of properties.

The Properties that can be used for grouping are:

* PropertyName  : Required, The name of the property to group on.
* DisplayName   : Use a custom label to use for the grouping value display.
* CustomDisplay : A Script block that should return a string. Used to create custom formatting for the grouping header. (DisplayName is ignored if specified.)

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|Object|false|true (ByPropertyName)|4||

### Path

     -Path <Object>

Path to save the View to. If an existing file is specified, then the view will be added to the existing xml tree in the file. If it does not exist a new file will be created.

If not specified, then an XML document will instead by returned with the view added.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|Object|false|false|100||

### ViewOptions

     -ViewOptions <Object>

Specify view options that apply to the whole view not just a single propertry of an object. Current options are:

* [string] NoAutoSize    : Disables autosize for Wide view, if specified the formatting engine uses only the first row for sizing info instead of all items.
* [property] Widecolumns : Sets the number of columns for Wide view. This also disables autosize, but allows display after the first row of items.

|Type|required|pipelineInput|position|Aliases|
|---|---|---|---|---|
|Object|false|false|named||

## Examples

### -------------------------- EXAMPLE 1 --------------------------

    New-ClassFormatData -Path myfile.ps1xml -TypeName MyClass -View Table -Properties Prop1,Prop2,Prop3

Creates the file myfile.ps1xml if it does not exist and populates it with the specified XML view. In the example, this is a table view with 3 properties for the class MyClass.

### -------------------------- EXAMPLE 2 --------------------------

    New-ClassFormatData -Path myfile.ps1xml -TypeName MyClass -View Wide -Properties Prop1 -ViewOptions @{WideColumns = 4}

Creates the file myfile.ps1xml if it does not exist and populates it with the specified XML view. In the example, this is a Wide view with a single property for the class MyClass. It will alwasy show 4 objects per row.

