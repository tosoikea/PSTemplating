#Requires -Version 5.0
## 
class Plain : SchemaNode {
    hidden [string] $Value

    [string] GetValue() {
        return $this.Value
    }

    [boolean] Equals($obj) {
        #Check for null and compare run-time types.
        if (($null -eq $obj) -or -not $this.GetType().Equals($obj.GetType())) {
            return $false;
        }
        else {
            $other = $obj -as [Plain]
            return ($this.Value -eq $other.Value)
        }
    }

    [string] ToString() {
        return "Plain(value={0}" -f $this.GetValue()
    }
    
    [String] Bind([System.Collections.Generic.Dictionary[String, String]] $bindings) {
        return $this.GetValue()
    }

    [boolean] IsFailover() {
        return $false
    }

    Plain([string] $value) {
        $this.Value = $value
    }
}