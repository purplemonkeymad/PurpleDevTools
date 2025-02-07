<#

Converts inputs for New-XMLElement's Children parameter, this
should allow arrays or a script block that will be resolved
to an array.

#>
class XMLChildrenTransformer : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform( [System.Management.Automation.EngineIntrinsics]$EngineIntrinsics, [object]$inputData ) {
        <#
            check for a script block first as it may output any
            of the other supported types
        #>
        $inputObjects = $inputData
        if ($inputData -is [scriptblock]) {
            ## this looks strange but should do the caller's
            ## scope for the sb, this way it works as "expected"
            ## we don't need any pipeline input in this context
            ## so I don't think that will be an issue.
            ## https://stackoverflow.com/a/48697830
            $pipe = { ForEach-Object $inputData }.GetSteppablePipeline()

            $inputObjects = $(
                $pipe.Begin($false)
                $pipe.Process()
                $pipe.End()
            )
        }

        $Output = foreach ($SingleObject in $inputObjects) {
            if ($SingleObject -is [System.xml.XmlElement]) {
                Write-Output $SingleObject
            } else {
                throw [System.Management.Automation.ArgumentTransformationMetadataException]::new(
                    "Parameter can only access XmlElement objects."
                )
            }
        }
        return $Output
    }
}