function ConvertTo-NormalizedXMLItem {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject,
        [switch]$NoFrames
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

            return (
                New-XMLElement -Name Text -InnerText $InputObject
            )
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
                    New-XMLElement -Name Text -InnerText $InputObject.Text
                )
            }

            if ($InputObject.containsKey('Frame')) {

                if ($NoFrames) {
                    Write-Error "Frames in the custom style cannot be nested." -TargetObject $InputObject -ErrorAction Stop
                }

                $children = $(
                    foreach ($property in 'LeftIndent','RightIndent','FirstLineHanging','FirstLineIndent') {
                        if ($InputObject.containsKey($property)) {
                            New-XMLElement -Name $property -InnerText ([int]$InputObject.$property)
                        }
                    }
                    New-XMLElement -Name CustomItem -Children $(
                        # frames cannot be nested so make sure we don't create one in the recursion.
                        $InputObject.Frame | ConvertTo-NormalizedXMLItem -NoFrames
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
                    New-XMLElement -Name ScriptBlock -InnerText $InputObject
                )
            )
        }

        # we don't know just ignore?
        Write-Error "Can't determine custom control: $InputObject." -TargetObject $InputObject
    }
}