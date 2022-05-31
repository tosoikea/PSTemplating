function Get-NodeValues {
    [OutputType([Value[]])]
    param(
        [Parameter(Mandatory)]
        [SchemaNode]
        $Node,
        [Parameter(Mandatory)]
        [System.Collections.Generic.Dictionary[String, String]]
        $Bindings
    )

    $res = [System.Collections.Generic.List[Value]]::new()

    # A) Calculate the paths possible for the variable. This could in general be done once in a pre-processing step.
    [Tuple[bool, Operation[]][]] $paths = Get-OperationPaths -Node $Node
    
    # B) Generate values based on the paths.
    foreach ($path in $paths) {
        $values = [System.Collections.Generic.List[Value]]::new()
        $values.Add(
            # Value is failover given that the path is failover
            [Value]::new($path.Item1, $Node.Bind($Bindings))
        )

        # C) Evaluate the operation in a chained fashion
        foreach ($pNode in $path.Item2) {
            $nEntries = [System.Collections.Generic.List[Value[]]]::new()

            foreach ($value in $values) {
                foreach($entry in $pNode.Execute($value.GetValue())){
                    $nEntries.Add(
                        [Value]::new(
                            $value.IsFailover(),
                            $entry
                        )
                    )
                }
            }

            $values = [System.Collections.Generic.List[Value]]::new()
            foreach ($nValues in $nEntries) {
                foreach ($nValue in $nValues) {
                    $values.Add($nValue)
                }
            }
        }

        foreach ($value in $values) {
            $res.Add($value)
        }
    }

    # https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-arrays?view=powershell-7.2
    Write-Output -NoEnumerate $res.ToArray()
}