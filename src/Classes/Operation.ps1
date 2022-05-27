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
    [Value[]] Evaluate([Value] $value) {
        $res = $this.Execute($value.GetValue())
        $vals = [Value[]]::new($res.Count);

        for ([int] $i = 0; $i -lt $vals.Length; $i++) {
            $vals[$i] = [Value]::new($this.Failover -or $value.IsFailover(), $res[$i])
        }

        return $vals
    }

    # Internal method for generating string values.
    [string[]] Execute([string] $value) {
        return @("")
    }
    
    [boolean] Equals($obj) {
        #Check for null and compare run-time types.
        if (($null -eq $obj) -or -not $this.GetType().Equals($obj.GetType())) {
            return $false;
        }
        else {
            $other = $obj -as [Operation]
            return ($this.IsFailover() -eq $other.IsFailover())
        }
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
    This class defines the operation replacing search regex with desired values.
#>
class ReplaceOp : Operation {
    hidden [regex] $Search
    hidden [String] $Replacement
    
    [string[]] Execute([string] $value) {
        throw [System.NotImplementedException]::new()
    }

    ReplaceOp([boolean] $failover, [string[]] $parameters) : base($failover, $parameters) {
        if ($parameters.Length -gt 0) {
            $this.Search = [regex]::new($parameters[0])
        }

        if ($parameters.Length -gt 1) {
            $this.Replacement = $parameters[1]
        }
    }
}

<#
    This class defines the operation splitting a value based on white spaces and hyphens.
#>
class SplitOp : Operation {
    [string[]] Execute([string] $value) {
        throw [System.NotImplementedException]::new()
    }

    SplitOp([boolean] $failover) : base($failover, @()) {
        
    }
}

<#
    This class defines the operation indexing into the supplied value.
#>
class SelectionOp : Operation {
    hidden [int[]] $Indexes

    [string[]] Execute([string] $value) {
        $res = ""

        foreach ($index in $this.Indexes) {
            if ($index -ge 0 -and $index -lt $value.Length) {
                $res += $value[$index]
            }
        }

        return @($res)
    }
    
    [boolean] Equals($obj) {
        $isEqual = ([Operation]$this).Equals($obj)

        if ($isEqual) {
            $other = $obj -as [SelectionOp]
            
            $isEqual = ($this.Indexes.Length -eq $other.Indexes.Length)
            
            for ([int] $i = 0; $i -lt $this.Indexes.Length -and $isEqual; $i++) {
                $isEqual = $this.Indexes[$i] -eq $other.Indexes[$i]
            }
        }

        return $isEqual
    }

    SelectionOp([boolean] $failover, [string[]] $parameters) : base($failover, $parameters) {
        $this.Indexes = @()

        foreach ($parameter in $parameters) {
            $this.Indexes += [Int]::Parse($parameter)
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

    [boolean] Equals($obj) {
        $isEqual = ([Operation]$this).Equals($obj)

        if ($isEqual) {
            $other = $obj -as [CountOp]
            $isEqual = ($this.From -eq $other.From) -and ($this.To -eq $other.To)
        }

        return $isEqual
    }

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
        $amount = [System.Math]::Max($this.From - $this.To + 1, 0)

        $values = [string[]]::new($amount)
        for ($i = $this.From; $i -ge $this.To; $i--) {
            $values[$this.From - $i] = "{0}{1}" -f $value, $i
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
    static [Operation] GetOperation([boolean] $isFailover, [String] $name, [string[]] $parameters) {
        switch ($name.ToLower()) {
            "upper" {
                return [ToUpperOp]::new($isFailover)
            }
            "lower" {
                return [ToLowerOp]::new($isFailover)
            }
            "countdown" {
                return [CountDownOp]::new($isFailover, $parameters)
            }
            "countup" {
                return [CountUpOp]::new($isFailover, $parameters)
            }
            "sel" {
                return [SelectionOp]::new($isFailover, $parameters)
            }
            "split" {
                return [SplitOp]::new($isFailover)
            }
            "replace" {
                return [ReplaceOp]::new($isFailover, $parameters)
            }
        }

        throw [System.NotImplementedException]::new($name)
    }
}