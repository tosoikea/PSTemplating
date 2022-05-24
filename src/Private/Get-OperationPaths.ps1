function Get-OperationPaths {
    param(
        [Parameter(Mandatory)]
        [Variable]
        $Variable
    )

    $paths = @(
        [NoOp]::new()
    )

    return $paths
}