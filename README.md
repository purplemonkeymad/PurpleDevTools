# PurpleDevTools

Powershell Development tools for module production.
These are to help with creation of module itself or for fleshing out features on functions.

## About

I found that there was not much in the way of default features with powershell that assisted with the creation of modules.
Some features didn't really have tools to create, you just had to manually create and edit the dependent files.
The commands from this module, are to make or template those features in a simpler fashion.

## Commands

### New-TypeFormatData

For creating new .format.ps1xml files for the formatting engine.
This allows you to easily create table or list formats with specific properties, and even set scripted properties.
You can point it to a new file or an existing file to add to the existing typenames.

### New-ProxyCommand

Creates a new function form an existing command.
The function will have the same parameters as the target command, and call the target using a steppable pipeline.
This is good for creating functions that extend another function, eg rate limiting Invoke-RestMethod or modifying the return values of a command.

## Author

Purple Monkey Mad  
github.com/purplemonkeymad  
/u/purplemonkemad
