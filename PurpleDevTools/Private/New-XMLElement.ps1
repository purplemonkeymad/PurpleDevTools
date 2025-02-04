function New-XMLElement {
    [CmdletBinding()]
    [outputtype([System.xml.XmlElement])]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$Prefix = '',
        [string]$Namespace = '',
        [hashtable]$Attributes,
        [string]$Innertext,
        [XMLChildrenTransformer()]
        [System.xml.XmlElement[]]$Children,
        [xml]$Document
    )
    
    begin {
        
    }
    
    process {
        
    }
    
    end {
        $emptyDoc = $false
        if ($null -eq $Document) {
            $Document = [xml]''
            $emptyDoc = $true
        }

        try {
            $Node = $Document.CreateNode([System.Xml.XmlNodeType]::Element, $prefix, $name, $namespace)
            if ($emptyDoc){
                [void]$Document.AppendChild($Node)
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError(
                ( New-Object System.Management.Automation.ErrorRecord -ArgumentList @(
                    [System.Management.Automation.RuntimeException]"XML Error: $($_.Exception.Message)",
                    'NewXMLElement.InnerError',
                    [System.Management.Automation.ErrorCategory]::OperationStopped,
                    "$prefix, $name, $namespace"
                    )
                )
            )
            return
        }

        if ($attributes) {
            foreach ($_ in $attributes.GetEnumerator()) {
                # we want to support both @{ name = value } and @{ name = @{ Prefix = 'Prefix'; Value = 'Value'} }
                # otherwise it would be fiddley to set the prefix.
                if ($_.value.value) {
                    $attName = if ($_.value.prefix) { "$($_.value.prefix):$($_.key)" } else { $_.Key }
                    [void]$Node.SetAttribute($attName, $_.value.value)
                }
                else {
                    [void]$Node.SetAttribute($_.key, $_.value)
                }
            }
        }
        
        if ($Children) {
            foreach ($ChildNode in $Children) {
                # You can't add a node from another document, so import it into this one.
                if ($ChildNode.OwnerDocument -ne $Document) {
                    [void]$node.AppendChild( $Document.ImportNode($ChildNode , $true) )
                }
                else {
                    [void]$node.AppendChild($ChildNode)
                }
                
            }
        }

        if ($innertext) {
            $Node.InnerText = $innertext
        }

        return $Node
    }
}