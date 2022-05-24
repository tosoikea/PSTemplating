#Requires -Version 5.0

<#
    This "abstract" class defines the general structure of an operation in the context of this module.
#>
class Operation {
    hidden [string[]] $Parameters
    hidden [boolean] $Failover

    [boolean] IsFailover() {
        return $this.Failover
    }

    # Generates the results from the supplied value.
    [Value[]] Evaluate([string] $value) {
        $res = $this.Execute($value)
        $vals = [Value[]]::new($res.Count);

        for ([int] $i = 0; $i -lt $vals.Length; $i++) {
            $vals[$i] = [Value]::new($this.Failover, $res[$i])
        }

        return $vals
    }

    # Internal method for generating string values.
    [string[]] Execute([string] $value) {
        return @("")
    }

    [string] ToString() {
        return "{0}(isFailOver={1},parameters=[{2}])" -f $this.GetType(), $this.IsFailover(), [system.String]::Join(",", $this.Parameters)
    }

    Operation([boolean] $failover, [string[]] $parameters) {
        $this.Failover = $failover
        $this.Parameters = $parameters
    }
}

<#
    This special class defines no operation.
    It is used for realizing failovers.
#>
class NoOp : Operation {
    # Internal method for generating string values.
    [string[]] Execute([string] $value) {
        return @($value)
    }

    NoOp() : base($false, @()) {
        
    }
}

<#
    This class defines the operation indexing into the supplied value.
#>
class SelectionOp : Operation {
    hidden [int] $Index = 0

    [string[]] Execute([string] $value) {
        if ($value.Length -le $this.Index) {
            return @("")
        }
        else {
            return @($value[$this.Index])
        }
    }

    SelectionOp([boolean] $failover, [string[]] $parameters) : base($failover, $parameters) {
        if ($parameters.Length -gt 0) {
            $this.Index = [Int]::Parse($parameters[0])
        }
    }
}



<#
    This class defines the toLower() operation.
#>
class ToLowerOp : Operation {
    [string[]] Execute([string] $value) {
        return @($value.ToLower())
    }

    ToLowerOp([boolean] $failover) : base($failover, @()) {
    }
}

<#
    This class defines the toUpper() operation.
#>
class ToUpperOp : Operation {
    [string[]] Execute([string] $value) {
        return @($value.ToUpper())
    }

    ToUpperOp([boolean] $failover) : base($failover, @()) {
    }
}


<#
    This "abstract" class defines the general count operations (up, down) of this module.
#>
class CountOp : Operation {
    hidden [int] $From = 1
    hidden [int] $To = 10

    CountOp([boolean] $failover, [string[]] $parameters) : base($failover, $parameters) {
        if ($parameters.Length -gt 0) {
            $this.From = [Int]::Parse($parameters[0])
        }

        if ($parameters.Length -gt 1) {
            $this.To = [Int]::Parse($parameters[1])
        }
    }
}

class CountUpOp : CountOp {
    [string[]] Execute([string] $value) {
        $amount = [System.Math]::Max($this.To - $this.From + 1, 0)

        $values = [string[]]::new($amount)
        for ($i = $this.From; $i -le $this.To; $i++) {
            $values[$i - $this.From] = "{0}{1}" -f $value, $i
        }

        return $values
    }

    CountUpOp([boolean] $failover, [string[]] $parameters) : base($failover, $parameters) {
    }
}

class CountDownOp : CountOp {    
    [string[]] Execute([string] $value) {
        $amount = [System.Math]::Max($this.To - $this.From + 1, 0)

        $values = [string[]]::new($amount)
        for ($i = $this.To; $i -ge $this.From; $i--) {
            $values[$this.To - $i] = "{0}{1}" -f $value, $i
        }

        return $values
    }

    CountDownOp([boolean] $failover, [string[]] $parameters) : base($failover, $parameters) {
    }
}


<#
    This "factory" generates a concise operation from the supplied name.
#>
class OperationFactory {
    static [Operation] GetOperation([String] $name, [string[]] $parameters) {
        switch ($name.ToLower()) {
            "upper" {
                return [ToUpperOp]::new()
            }
            "lower" {
                return [ToLowerOp]::new()
            }
            "countdown" {
                return [CountDownOp]::new($parameters)
            }
            "countup" {
                return [CountUpOp]::new($parameters)
            }
        }

        throw [System.NotImplementedException]::new()
    }
}