function Use-Schema {
    [OutputType([Value[]])]
    param(
        [Parameter(Mandatory)]
        [Schema]
        $Schema,
        [Parameter(Mandatory)]
        [System.Collections.Generic.Dictionary[String, String]]
        $Bindings
    )

    $res = [System.Collections.Generic.List[Value]]::new()
    $res.Add(
        [Value]::new($false, "")
    )

    foreach ($node in $Schema.GetNodes()) {
        # Goal :
        # Combine values of previous node evaluation with current node evaluation.
        # A failover node adds both pass-through and combination.
        
        $nRes = [System.Collections.Generic.List[Value]]::new()
        $nValues = Get-NodeValues -Node $node -Bindings $Bindings

        foreach ($value in $res) {
            # A) Pass-Through
            if ($node.IsFailover()) {
                $nRes.Add($value)
            }

            # B) Combination
            foreach ($nValue in $nValues) {
                $nRes.Add(
                    [Value]::new(
                        $value.IsFailover() -or $node.IsFailover() -or $nValue.IsFailover(),
                        ("{0}{1}" -f $value.GetValue(), $nValue.GetValue())
                    )
                )
            }
        }

        $res = $nRes
    }

    return $res.ToArray()
}