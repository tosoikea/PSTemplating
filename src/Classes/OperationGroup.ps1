#Requires -Version 5.0
<#
    This class bundles operations into a single group.
    Within an operation group at most the first operation can be non failover.
#>
class OperationGroup {
    # Operations included in the group.
    hidden [Operation[]] $Operations

    [string] ToString() {
        return "OperationGroup(operations=[{0}])" -f [system.String]::Join(",", $this.Operations)
    }

    [Operation[]] GetOperations() {
        return $this.Operations
    }

    OperationGroup([Operation[]] $operations) {
        for ([int] $i = 1; $i -lt $operations.Length; $i++) {
            if (-not $operations[$i].IsFailover()) {
                Write-Error -Message ("{0} is not allowed to be non failover. This is because it is included in an operation group." -f $operations[$i])
            }
        }

        $this.Operations = $operations
    }
}