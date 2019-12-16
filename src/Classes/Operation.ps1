#Requires -Version 5.0

class Operation {
    hidden [string[]] $Parameters
    hidden [boolean] $IsFailover

    [boolean] IsFailover() {
        return $this.IsFailover
    }

    [string[]] Evaluate([string] $value) {
        return ""
    }

    Operation([boolean] $isFailover, [string[]] $parameters) {
        $this.IsFailover = $isFailover
        $this.Parameters = $parameters
    }
}

class CountUp : Operation {
    hidden [int] $Count = 10

    [string[]] Evaluate([string] $value) {
        $values = [string[]]::new($this.Count)

        for ($i = 0; $i -lt $this.Count; $i++) {
            $values[$i] = "{0}{1}" -f $value, $i
        }

        return $values
    }

    CountUp([boolean] $isFailover, [string[]] $parameters) : base($isFailover, $parameters) {
        if ($parameters.Length -eq 0) {
            return
        }
        
        $this.Count = [Int]::Parse($parameters[0])
    }
}


class OperationFactory {
    static [Operation] GetOperation([String] $name, [string[]] $parameters) {
        switch ($name) {
            "countUp" {
                return [CountUp]::new($parameters)
            }
        }

        throw [System.NotImplementedException]::new()
    }
}