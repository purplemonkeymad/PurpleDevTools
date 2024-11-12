# PurpleDevTools

Powershell Development tools for module production.
These are to help with creation of module itself or for fleshing out features on functions.

## About

I found that there was not much in the way of default features with powershell that assisted with the creation of modules.
Some features didn't really have tools to create, you just had to manually create and edit the dependent files.
The commands from this module, are to make or template those features in a simpler fashion.

## Commands

Full help for all commands can be found in the [docs folder](docs/Readme.md).

### New-TypeFormatData

For creating new `.format.ps1xml` files for the formatting engine.
This allows you to easily create table or list formats with specific properties, and even set scripted properties.
You can point it to a new file or an existing file to add to the existing typenames.

### New-ProxyCommand

Creates a new function form an existing command.
The function will have the same parameters as the target command, and call the target using a steppable pipeline.
This is good for creating functions that extend another function, eg rate limiting Invoke-RestMethod or modifying the return values of a command.

### Save-XMLHelp

Creates correctly structured xml help file from the existing function help information.
XML Help is not checked against a function, so often does not required the module to be imported.
This speeds up help but also allows all features to be visible on a help page.
Comment based help does not work with dynamic parameters, so using XML help can solve that issue.
This exists so that an existing comment based help can be used to generate the xml help, or to just generate a template for you to fill out.

### Get-CommentBasedHelp

Create a template for comment based help from a loaded command.
Good for post-testing, when you still have a command in a session.
Run the command and then copy the output to the top of that function.

### New-ObjectListCommand

Template for managing a list of some specified type.
Often in configuration you might want to create a list of items, and need commands to add/remove/set the values of these objects.
This command creates a templated set of commands from the type and a code snip-it for storing the list to disk.

Best types to use for this command are basic powershell classes that only have properties defined.
These objects can be created by casing a hashtable to the given type.
You can use more complex classes, but you will want to update the New verb command to create a constructor,
and the Get verb command will expect a Deserialized.Typename to cast to the Type.

### New-ConfigurationCommand

Template for creating a configuration commands from a specified type.
This is a way to get a static configuration that is saved to disk.

Works best on basic powershell classes, with only properties.
Each property on the target class will be a parameter on the set command.

Remember to include your class definition in your module if needed.

## Notes on Dependencies

Some commands require the EPS (Embedded Powershell) module for the template system.
You can install it with the following command:

    Install-Module EPS

## Author

Purple Monkey Mad  
github.com/purplemonkeymad  
/u/purplemonkemad
