#Requires -Version 5.0
class Variable {
    # The operations associated with this variable.
    # They are held in a chained form, as the initial value goes through the "chain" of operation groups.
    hidden [OperationGroup[]] $Operations
    # If a variable is failover, there can be values generated where its value is not included.
    hidden [boolean] $Failover
    # Name of the variable, used during the substitution process.
    hidden [string] $Name

    [boolean] IsFailover() {
        return $this.Failover
    }

    [string] GetName() {
        return $this.Name
    }

    # Uses the supplied value to evaluate this variable.
    [Value[]] Evaluate([string] $value) {
        return @()
    }

    [string] ToString() {
        return "Variable(isFailOver={0},name={1},operations=[{2}])" -f $this.GetName(), $this.IsFailover(), [system.String]::Join(",", $this.Operations)
    }

    Variable([boolean] $failover, [string] $name, [OperationGroup[]] $operations) {
        $this.Failover = $failover
        $this.Name = $name
        $this.Operations = $operations
    }
}