#Requires -Version 5.0

Enum OperationGroupType {
    Conjunctive = 1
    Disjunctive = 2
}

<#
    This class bundles operations into a single group.
    Within an operation group at most the first operation can be non failover.
#>
class OperationGroup {
    # Operations included in the group.
    hidden [Operation[]] $Operations
    # Defines if the group is conjunctive or disjunctive
    hidden [OperationGroupType] $Type
    # Defines if the group is failover or not
    hidden [bool] $Failover

    [Operation[]] GetOperations() {
        return $this.Operations
    }

    [OperationGroupType] GetType() {
        return $this.Type
    }

    [boolean] IsFailover() {
        return $this.Failover
    }

    [boolean] Equals($obj) {
        #Check for null and compare run-time types.
        if (($null -eq $obj) -or -not $this.GetType().Equals($obj.GetType())) {
            return $false;
        }
        else {
            $other = $obj -as [OperationGroup]

            $isEqual = ($this.Type -eq $other.Type) -and ($this.Failover -eq $other.Failover) -and ($this.Operations.Length -eq $other.Operations.Length)
            
            for ([int] $i = 0; $i -lt $this.Operations.Length -and $isEqual; $i++) {
                $isEqual = $this.Operations[$i] -eq $other.Operations[$i]
            }

            return $isEqual
        }
    }

    [string] ToString() {
        return "OperationGroup(failover={0},type={1},operations=[{2}])" -f $this.IsFailover(), $this.GetType(), [system.String]::Join(",", $this.Operations)
    }

    # Generates paths from this group.
    # The first item indicates failover characteristic.
    [Tuple[bool, Operation[]][]] GetPaths() {
        # A) Conjunctive => Execute all
        if ($this.GetType() -eq [OperationGroupType]::Conjunctive) {
            if ($this.IsFailover()) {
                $res = [Tuple[bool, Operation[]][]]::new(2)
                # If this operation group is a failover group, there has to be an evaluation without evaluation of any contained operations.
                $res[0] = [Tuple[bool, Operation[]]]::new(
                    $false,
                    @(
                        [NoOp]::new()
                    )
                )
            }
            else {
                $res = [Tuple[bool, Operation[]][]]::new(1)
            }

            # Chain operations
            $res[$res.Length - 1] = [Tuple[bool, Operation[]]]::new(
                $this.IsFailover(),
                $this.GetOperations()
            )
        }
        # B) Disjunctive => Execute one
        elseif ($this.GetType() -eq [OperationGroupType]::Disjunctive) {
            if ($this.IsFailover()) {
                $res = [Tuple[bool, Operation[]][]]::new($this.Operations.Length + 1)
                # If this operation group is a failover group, there has to be an evaluation without evaluation of any contained operations.
                $res[0] = [Tuple[bool, Operation[]]]::new(
                    $false,
                    @(
                        [NoOp]::new()
                    )
                )
            }
            else {
                $res = [Tuple[bool, Operation[]][]]::new($this.Operations.Length)
            }

            # Split operations
            for ([int] $i = 0; $i -lt $this.Operations.Length; $i++) {
                $res[$res.Length - 1 - $i] = [Tuple[bool, Operation[]]]::new(
                    $this.IsFailover(),
                    $this.GetOperations()[$this.Operations.Length - 1 - $i]
                )
            }
        }
        else {
            throw [System.NotImplementedException]::new($this.GetType())
        }
        
        return $res
    }

    OperationGroup([Operation[]] $operations, [boolean] $failover, [OperationGroupType] $type) {
        $this.Operations = $operations
        $this.Failover = $failover
        $this.Type = $type
    }

    OperationGroup([Operation[]] $operations, [boolean] $failover) {
        $this.Operations = $operations
        $this.Failover = $failover
        $this.Type = [OperationGroupType]::Conjunctive
    }
}