#Requires -Version 5.0

<#
    This "abstract" class defines the general structure of an operation in the context of this module.
#>
class Operation {
    hidden [string[]] $Parameters

    # Method for generating string values.
    [string[]] Execute([string] $value) {
        return @("")
    }
    
    [boolean] Equals($obj) {
        #Check for null and compare run-time types.
        if (($null -eq $obj) -or -not $this.GetType().Equals($obj.GetType())) {
            return $false;
        }
        else {
            return $true
        }
    }

    [string] ToString() {
        return "{0}(parameters=[{1}])" -f $this.GetType(), [system.String]::Join(",", $this.Parameters)
    }

    Operation([string[]] $parameters) {
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

    NoOp() : base(@()) {        
    }
}

<#
    This class defines the operation replacing search regex with desired values.
#>
class ReplaceOp : Operation {
    hidden [regex] $Search
    hidden [String] $Replacement
    
    [string[]] Execute([string] $value) {
        $updated = ""
        if (-not [String]::IsNullOrEmpty($this.Replacement)) {
            $updated = $this.Replacement
        }

        return $this.Search.Replace($value, $updated)
    }

    ReplaceOp([string[]] $parameters) : base($parameters) {
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
        [string[]] $wValues = $value -split " "

        [string[]] $res = @()
        foreach ($wValue in $wValues) {
            $res += $wValue -split "-"
        }

        return $res
    }

    SplitOp() : base(@()) {
        
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

    SelectionOp([string[]] $parameters) : base($parameters) {
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

    ToLowerOp() : base(@()) {
    }
}

<#
    This class defines the toUpper() operation.
#>
class ToUpperOp : Operation {
    [string[]] Execute([string] $value) {
        return @($value.ToUpper())
    }

    ToUpperOp() : base(@()) {
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

    CountOp([string[]] $parameters) : base($parameters) {
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

    CountUpOp([string[]] $parameters) : base($parameters) {
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

    CountDownOp([string[]] $parameters) : base($parameters) {
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
            "sel" {
                return [SelectionOp]::new($parameters)
            }
            "split" {
                return [SplitOp]::new()
            }
            "replace" {
                return [ReplaceOp]::new($parameters)
            }
        }

        throw [System.NotImplementedException]::new($name)
    }
}