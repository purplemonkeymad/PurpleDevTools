<#
.SYNOPSIS
    An alternative to resolve-path but when the target might not exist
.DESCRIPTION
    An alternative to resolve-path but when the target might not exist
.NOTES
    
.LINK
    
.EXAMPLE  
#>
function Get-ExpandedPath {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory)]
        $Path
    )
    
    begin {
        
    }
    
    process {
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    }
    
    end {
        
    }
}