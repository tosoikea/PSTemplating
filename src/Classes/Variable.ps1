#Requires -Version 5.0

class Variable : SchemaNode {
    # The operations associated with this variable.
    # They are held in a chained form, as the initial value goes through the "chain" of operation groups.
    hidden [OperationGroup[]] $Operations
    # If a variable is failover, there can be values generated where its value is not included.
    hidden [boolean] $Failover
    # Name of the variable, used during the substitution process.
    hidden [string] $Name

    [string] GetName() {
        return $this.Name
    }

    [OperationGroup[]] GetOperations() {
        return $this.Operations
    }

    [boolean] Equals($obj) {
        #Check for null and compare run-time types.
        if (($null -eq $obj) -or -not $this.GetType().Equals($obj.GetType())) {
            return $false;
        }
        else {
            $other = $obj -as [Variable]
            return ($this.Failover -eq $other.Failover) -and ($this.Name -eq $other.Name) -and ($this.Operations -eq $other.Operations)
        }
    }

    [string] ToString() {
        return "Variable(isFailOver={0},name={1},operations=[{2}])" -f $this.GetName(), $this.IsFailover(), [system.String]::Join(",", $this.Operations)
    }

    [String] Bind([System.Collections.Generic.Dictionary[String, String]] $bindings) {
        if (-not $bindings.ContainsKey($this.GetName())) {
            Write-Error -Message ("{0} is not included in the bindings." -f $this.GetName())
        }

        return $bindings[$this.GetName()]
    }
    
    [boolean] IsFailover() {
        return $this.Failover
    }

    Variable([boolean] $failover, [string] $name) {
        $this.Failover = $failover
        $this.Name = $name
        $this.Operations = [OperationGroup[]]::new(0)
    }
    
    Variable([boolean] $failover, [string] $name, [OperationGroup[]] $operations) {
        $this.Failover = $failover
        $this.Name = $name
        $this.Operations = $operations
    }
}