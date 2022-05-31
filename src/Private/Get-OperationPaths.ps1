function Get-OperationPaths {
    [OutputType([Tuple[bool, Operation[]][]])]
    param(
        [Parameter(Mandatory)]
        [SchemaNode]
        $Node
    )

    $paths = [Tuple[bool, Operation[]][]]::new(1)

    # Basic path is non failover with return of value
    $paths[0] = [Tuple[bool, Operation[]]]::new(
        $false,
        @(
            [NoOp]::new()
        )
    )

    if ($Node -is [Plain]) {
        # https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-arrays?view=powershell-7.2
        Write-Output -NoEnumerate $paths
    }
    elseif ($Node -is [Variable]) {
        $Variable = $Node -as [Variable]
        
        foreach ($group in $Variable.GetOperations()) {
            $nPaths = [System.Collections.Generic.List[Tuple[bool, Operation[]]]]::new()
            [Tuple[bool, Operation[]][]] $gPaths = $group.GetPaths()
    
            foreach ($path in $paths) {
                # Setup paths from known nodes and newly found group paths
                foreach ($gPath in $gPaths) {
                    $nodes = [Operation[]]::new($path.Item2.Length + $gPath.Item2.Length)
    
                    # A) Copy nodes from known path
                    for ([int] $i = 0; $i -lt $path.Item2.Length; $i++) {
                        $nodes[$i] = $path.Item2[$i]
                    }
                    
                    # B) Extend path
                    for ([int] $i = 0; $i -lt $gPath.Item2.Length; $i++) {
                        $nodes[$path.Item2.Length + $i] = $gPath.Item2[$i]
                    }
    
                    # C) Append newly constructed path to next path iteration
                    $nPaths.Add(
                        [Tuple[bool, Operation[]]]::new(
                            $path.Item1 -or $gPath.Item1,
                            $nodes
                        )
                    )
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