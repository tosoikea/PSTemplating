function Get-OperationPaths {
    [OutputType([Operation[][]])]
    param(
        [Parameter(Mandatory)]
        [SchemaNode]
        $Node
    )

    $paths = [Operation[][]]::new(1)
    $paths[0] = [NoOp]::new()

    if ($Node -is [Plain]) {
        # https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-arrays?view=powershell-7.2
        Write-Output -NoEnumerate $paths
    }
    elseif ($Node -is [Variable]) {
        $Variable = $Node -as [Variable]
        
        foreach ($group in $Variable.GetOperations()) {
            $groupOps = $group.GetOperations();
            $nPaths = [System.Collections.Generic.List[Operation[]]]::new()
    
            foreach ($path in $paths) {
                [Operation[]] $leafs = @()
    
                for ([int] $i = 0; $i -lt $groupOps.Length; $i++) {
                    # First Failover? -> Add additional NoOp
                    if ($i -eq 0 -and $groupOps[$i].IsFailover()) {
                        $leafs += [NoOp]::new()
                    }
    
                    # Add operation of group as distinct leaf (they are not chained!)
                    $leafs += $groupOps[$i]
                }

    
                # Setup paths from known nodes and newly found leafs
                foreach ($leaf in $leafs) {
                    $nPath = [Operation[]]::new($path.Length + 1)
    
                    # A) Copy nodes from known path
                    for ([int] $i = 0; $i -lt $path.Length; $i++) {
                        $nPath[$i] = $path[$i]
                    }
                    # B) Extend path
                    $nPath[$nPath.Length - 1] = $leaf
    
                    # C) Append newly constructed path to next path iteration
                    $nPaths.Add($nPath)
                }
            }
            
            $paths = $nPaths.ToArray()
        }
    
        # https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-arrays?view=powershell-7.2
        Write-Output -NoEnumerate $paths
    }
    else {
        throw [System.NotImplementedException]::new()
    }
}