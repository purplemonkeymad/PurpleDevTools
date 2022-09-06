# PurpleDevTools

Powershell Development tools for module production.
These are to help with creation of module itself or for fleshing out features on functions.

## About

I found that there was not much in the way of default features with powershell that assisted with the creation of modules.
Some features didn't really have tools to create, you just had to manually create and edit the dependent files.
The commands from this module, are to make or template those features in a simpler fashion.

## Commands

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

## Author

Purple Monkey Mad  
github.com/purplemonkeymad  
/u/purplemonkemad
