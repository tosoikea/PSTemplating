#Requires -Version 5.0
class Value {
    # Generated value.
    hidden [string] $Value
    # Determines if the value was obtained from a path including any failover node.
    hidden [boolean] $Failover

    [boolean] IsFailover() {
        return $this.Failover
    }

    [string] GetValue() {
        return $this.Value
    }

    [string] ToString() {
       return "Value(value={0},isFailOver={1})" -f $this.GetValue(), $this.IsFailover()
    }

    Value([boolean] $failover, [string] $value) {
        $this.Failover = $failover
        $this.Value = $value
    }
}