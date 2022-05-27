#Requires -Version 5.0
<#
    This class bundles operations into a single group.
    Within an operation group at most the first operation can be non failover.
#>
class OperationGroup {
    # Operations included in the group.
    hidden [Operation[]] $Operations

    [Operation[]] GetOperations() {
        return $this.Operations
    }

    [boolean] Equals($obj) {
        #Check for null and compare run-time types.
        if (($null -eq $obj) -or -not $this.GetType().Equals($obj.GetType())) {
            return $false;
        }
        else {
            $other = $obj -as [OperationGroup]

            $isEqual = ($this.Operations.Length -eq $other.Operations.Length)
            
            for ([int] $i = 0; $i -lt $this.Operations.Length -and $isEqual; $i++) {
                $isEqual = $this.Operations[$i] -eq $other.Operations[$i]
            }

            return $isEqual
        }
    }

    [string] ToString() {
        return "OperationGroup(operations=[{0}])" -f [system.String]::Join(",", $this.Operations)
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