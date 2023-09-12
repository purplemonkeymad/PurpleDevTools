function Convert-AboutFileToMarkdown {
    [CmdletBinding(DefaultParameterSetName="Input")]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName="Input")]
        [string]
        $InputObject,
        [Parameter(Mandatory,ParameterSetName="File")]
        [string]
        $Path
    )
    
    begin {
        
    }
    
    process {
        # read file if using path option
        if ($Path) {
            $InputObject = Get-Content -Raw -LiteralPath $Path
        }

        # bail if not given anything or if get-content fails.
        if (-not $InputObject) {
            return
        }

        $Lines = $InputObject -split "\r?\n"

        # add header
        if ($Path) {
            "# " + ((Split-Path $Path -Leaf) -replace "^About_",'' -replace "\.help\.txt$")
            ""
        }

        foreach ($AboutLine in $Lines) {
            # all caps left aligned
            if ($AboutLine -cmatch '^[A-Z]' -and $AboutLine -cnotmatch '[a-z]') {
                "## " + $AboutLine.Trim()
                ""
            # left aligned and title case
            } elseif ($AboutLine -cmatch '^[A-Z]' -and $AboutLine -cmatch '[a-z]') {
                "### " + $AboutLine.Trim()
                ""
            } else {
                $AboutLine.trim()
            }
        }

    }
    
    end {
        
    }
}