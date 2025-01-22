function ConvertTo-NormalizedXMLItem {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    process {
        # if we have a string that should be a text component
        if ($InputObject -is [string]) {
            # if we have only a newline, then we should swap it out
            if ($InputObject -match '^\r?\n$') {
                return (
                    New-XMLElement -Name NewLine
                )
            }
        }

        # check for a hashtable with the name in it ie
        # @{newline=$null}

        if ($InputObject -is [System.Collections.IDictionary]) {
            if ($InputObject.containsKey('NewLine')){
                return (
                    New-XMLElement -Name NewLine
                )
            }

            if ($InputObject.containsKey('Text')) {
                return (
                    New-XMLElement -Name Text -Value $InputObject.Text
                )
            }

            if ($InputObject.containsKey('Frame')) {

                $children = $(
                    foreach ($property in 'LeftIndent','RightIndent','FirstLineHanging','FirstLineIndent') {
                        if ($InputObject.containsKey($property)) {
                            New-XMLElement -Name $property -Value ([int]$InputObject.$property)
                        }
                    }
                    New-XMLElement -Name CustomItem -Children $(
                        $InputObject.Frame | ConvertTo-NormalizedXMLItem
                    )
                )
                
                return (
                    New-XMLElement -Name Frame -Children $children
                )
            }
        }

        if ($InputObject -is [scriptblock]){
            return (
                New-XMLElement -Name ExpressionBinding -Children $(
                    New-XMLElement -Name ScriptBlock -Value $InputObject
                )
            )
        }

        # we don't know just ignore?
        Write-Error "Can't determine custom control: $InputObject." -TargetObject $InputObject
    }
}