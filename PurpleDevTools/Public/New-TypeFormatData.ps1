<#
.SYNOPSIS
    Create a new Format Data View for a class.
.DESCRIPTION
    Creates the xml for a new FormatData file for a given class. Can also target an existing Format File to add to it.
.EXAMPLE
    New-ClassFormatData -Path myfile.ps1xml -TypeName MyClass -View Table -Properties Prop1,Prop2,Prop3

    Creates the file myfile.ps1xml if it does not exist and populates it with the specified XML view. In the example, this is a table view with 3 properties for the class MyClass.

.PARAMETER TypeName

    Specify the TypeName(s) for this view, if more that one type is spcified, then a single view is created to target all types.

.PARAMETER View

    Specify the Formatting view that will be used. Table or List.

.PARAMETER Properties

    A list of the properties that will be visible by default in the View specified.

    The Properties can be specified as a list of strings. This will use the default settings for the property and use the Name as the Display Name.

    Alternatively the Property can be specified as a object with a specific set of properties. If this is used one of the properties PropertyName or ScriptBlock are required. The list of properties that can be used are:
    
    * DisplayName  : The shown name of the property, this will be the column header in table views.
    * PropertyName : Property name that the property should use as the source of the value. (Cannot, be used at the same time as ScriptBlock.)
    * ScriptBlock  : A Script that is used to evaluate the property at dispaly time. Use $_ or $PSItem to refer to the current object being displayed. (Cannot, be used at the same time as PropertyName.)
    * Width        : The width in charaters for the specified Column (Table Only.)
    * Alignment    : The alignment of the Value in the specified Column, eg Left, Right (Table Only.)
    * Condition    : A script block to determine if the List property should be shown, return true to show the property (List Only.)

.PARAMETER Group

    Specifiy the Grouping property. This can be either a string of the name of the property to group on, or an object with a specific set of properties.

    The Properties that can be used for grouping are:

    * PropertyName  : Required, The name of the property to group on.
    * DisplayName   : Use a custom label to use for the grouping value display.
    * CustomDisplay : A Script block that should return a string. Used to create custom formatting for the grouping header. (DisplayName is ignored if specified.) 

.PARAMETER Path

    Path to save the View to. If an existing file is specified, then the view will be added to the existing xml tree in the file. If it does not exist a new file will be created.

    If not specified, then an XML document will instead by returned with the view added.

#>
function New-TypeFormatData {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string[]]$TypeName,

        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [validateset('Table','List')]
        [string]$View,

        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        $Properties,

        [Parameter(ValueFromPipelineByPropertyName)]
        $Group,

        $Path
    )
    
    begin {
        $XML = if ($Path -and (Test-Path $Path -PathType Leaf) ){
            try {
                [xml](Get-Content $Path -Raw)
            } catch {
                throw $_
            }
        } else {
            # no xml lets get a new one.
            (New-XMLElement -Name Configuration -Children $(
                New-XMLElement -Name ViewDefinitions
            )).OwnerDocument
        }
        # if we don't have view defs then we need a new xml doc.
        if ($XML -and (-not $XML.SelectNodes('//Configuration/ViewDefinitions'))){
            # we have xml but not a valid schema
            $PSCmdlet.ThrowTerminatingError(
                ( New-Object System.Management.Automation.ErrorRecord -ArgumentList @(
                    [System.Management.Automation.RuntimeException]'Existing XML document does not appear to be a format data view file.',
                    'PurpleDevTools.FormatDataView.IncorrectSchema',
                    [System.Management.Automation.ErrorCategory]::InvalidData,
                    $XML
                    )
                )
            )
        }
    }
    
    process {
        # check for an existing view for the class
        foreach ($SingleClassName in $TypeName) { 
            foreach ($Node in $XML.SelectSingleNode("//View/ViewSelectedBy[TypeName='$SingleClassName']")) {
                Write-Error "A view for the given class already exists." -TargetObject $SingleClassName -Category ResourceExists -ErrorId 'PurpleDevTools.FormatDataView.Exists'
                return
            }
        }

        # we have one.
        $viewElement = New-XMLElement -Document $XML -Name View -Children $(
            New-XMLElement -Name Name -Innertext ($TypeName | Select-Object -First 1)
            New-XMLElement -Name ViewSelectedBy -Children $(
                # class
                $TypeName | ForEach-Object {
                    New-XMLElement -Name TypeName -Innertext $_
                }
            )
            
        )

        # normalise properties, you can give a string or a hashtable
        # so strings needs to be updated to hashtables.

        $normalProperties = $Properties | ForEach-Object {
            if ($_ -is [string]){
                @{
                    PropertyName = $_
                    DisplayName = $_
                }
            } else {
                $_
            }
        }

        $normalGroup = $(
            if ($Group -is [string]){
                @{
                    PropertyName = $Group
                    DisplayName = $Group
                }
            } else {
                $Group
            }
        )

        $newNodes = $(

            # grouping controls

            if ($Group) {
                New-XMLElement -Document $XML -Name GroupBy -Children $(
                    if ( $normalGroup.PropertyName ) {
                        New-XMLElement -Name PropertyName -Innertext $normalGroup.PropertyName
                    } else {
                        Write-Error -Message "PropertyName for a group is required." -ErrorAction Stop -TargetObject $Group
                    }
                    # it does not make sense to use a label if you set a custom script.
                    if ( $_.CustomDisplay ) {
                        # this is the way psreadline does a custom group, so I'm going to copy it.
                        New-XMLElement -Name CustomControl -Children $(
                            New-XMLElement -Name CustomEntries -Children $(
                                New-XMLElement -Name CustomEntry -Children $(
                                    New-XMLElement -Name CustomItem -Children $(
                                        New-XMLElement -Name ExpressionBinding -Children $(
                                            New-XMLElement -Name ScriptBlock -Innertext $normalGroup.ScriptBlock.tostring()
                                        )
                                    )
                                )
                            )
                        )
                    } elseif (-not [string]::IsNullOrEmpty($normalGroup.DisplayName) ) {
                        New-XMLElement -Name Label -Innertext $normalGroup.DisplayName
                    }
                )
            }

            # type
            switch ($View) {
                'table' {
                    New-XMLElement -Document $XML -Name TableControl -Children $(
                        New-XMLElement -Name TableHeaders -Children $(
                            # Header settings
                            $normalProperties | ForEach-Object {
                                New-XMLElement -Name TableColumnHeader -Children $(
                                    if (-not [string]::IsNullOrEmpty($_.DisplayName) ) {
                                        New-XMLElement -Name Label -Innertext $_.DisplayName
                                    }
                                    if ($_.Width) {
                                        # width must be an int.
                                        if ($_.Width -as [int]) {
                                            New-XMLElement -Name Width -Innertext $_.Width
                                        }
                                    }
                                )
                            }
                        )
                        New-XMLElement -Name TableRowEntries -Children $(
                            # Column data values
                            New-XMLElement -Name TableRowEntry -Children $(
                                New-XMLElement -Name TableColumnItems -Children $(
                                    $normalProperties | ForEach-Object {
                                        New-XMLElement -Name TableColumnItem -Children $(
                                            if ($_.Alignment) {
                                                New-XMLElement -Name Alignment -Innertext $_.Alignment
                                            }
                                            if ( (-not $_.PropertyName) -and (-not $_.ScriptBlock) ) {
                                                Write-Error -Message "Either PropertyName or ScriptBlock is required." -ErrorAction Stop -TargetObject $_
                                            }
                                            if ( $_.PropertyName ) {
                                                New-XMLElement -Name PropertyName -Innertext $_.PropertyName
                                            }
                                            if ( $_.ScriptBlock ) {
                                                New-XMLElement -Name ScriptBlock -Innertext $_.ScriptBlock.tostring()
                                            }
                                        )
                                    }
                                )
                            )
                        )
                    )
                }
                'list' {
                    New-XMLElement -Document $XML -Name ListControl -Children $(
                        New-XMLElement -Name ListEntries -Children $(
                            New-XMLElement -Name ListEntry -Children $(
                                New-XMLElement -Name ListItems -Children $(
                                    foreach ($_ in $normalProperties) {
                                        New-XMLElement -Name ListItem -Children $(
                                            if (-not [string]::IsNullOrEmpty($_.DisplayName) ) {
                                                New-XMLElement -Name Label -Innertext $_.DisplayName
                                            }
                                            if ( (-not $_.PropertyName) -and (-not $_.ScriptBlock) ) {
                                                Write-Error -Message "Either PropertyName or ScriptBlock is required." -ErrorAction Stop -TargetObject $_
                                            }
                                            if ( $_.PropertyName ) {
                                                New-XMLElement -Name PropertyName -Innertext $_.PropertyName
                                            }
                                            if ( $_.ScriptBlock ) {
                                                New-XMLElement -Name ScriptBlock -Innertext $_.ScriptBlock.tostring()
                                            }
                                            if ( $_.Condition ) {
                                                New-XMLElement -Name ItemSelectionCondition -Children $(
                                                    New-XMLElement -Name ScriptBlock -Innertext $_.Condition.toString()
                                                )
                                            }
                                        )
                                    }
                                )
                            )
                        )
                    )
                }
            }
        )

        $newNodes | ForEach-Object { [void]$viewElement.AppendChild($_) }

        [void]$XML.SelectNodes('//Configuration/ViewDefinitions').AppendChild( $XML.ImportNode($viewElement , $true) )
    }
    
    end {
        
        # write file if needed
        if ($Path){
            $truePath = $Path -replace '^\.(\\|\/)',"$pwd\"
            $XML.Save($truePath)
        } else {
            $XML
        }
    }
}