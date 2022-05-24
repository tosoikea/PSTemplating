function Get-Example {
    param()

    $var = [Variable]::new(
        $false,
        "x",
        @(
            [OperationGroup]::new(
                [Operation[]] @( 
                    [ToLowerOp]::new($false)
                )
            ),
            [OperationGroup]::new(
                [Operation[]] @(
                    [SelectionOp]::new($false, @("0")),
                    [CountUpOp]::new($true, @("1", "3"))
                )
            )
        )
    )

    return $var
}