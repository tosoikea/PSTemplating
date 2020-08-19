#Requires -Version 5.0
using module .\Operation.ps1

class OperationGroup {
    hidden [OperationChain[]] $Group

    [OperationChain[]] GetOperations() {
        return $this.Group
    }

    OperationGroup([Operation[]] $operations) {
        $this.Group = [OperationChain[]]::new($operations.Length)

        for ($i = 0; $i -lt $this.Group.Length; $i++){
            $this.Group[$i] = [OperationChain]::new($operations[$i])
        }
    }
}

class OperationChain {
    [Operation] $Operation
    [OperationChain[]] $Next
    

    hidden [string[]] GetChildrenResult([string[]] $values, [boolean] $isFailover) {
        if ($this.Next.Length -eq 0 -or ($isFailover -and $this.Next.Length -eq 1)) {
            Write-Verbose -Message ("{0} :: No more operations following. Returning.")
            return $values
        }

        [string[]] $res = @()
        if ($isFailover) {
            Write-Verbose -Message ("{0} :: Evaluating {1} failover branches." -f $MyInvocation.MyCommand, ($this.Next.Length - 1))
            for ($i = 1; $i -lt $this.Next.Length; $i++) {
                foreach ($v in $this.$values) {
                    $res += $this.Next[$i].Evaluate($v, $isFailover)
                }
            }
        }
        else {
            foreach ($v in $this.$values) {
                $res += $this.Next[0].Evaluate($v, $isFailover)
            }
        }

        return $res
    }

    [string[]] Evaluate([string] $value, [boolean] $isFailover) {
        $values = $this.Operation.Evaluate($value)
        return GetChildrenResult($values, $isFailover)
    }

    static [OperationChain] GetChain([OperationGroup[]] $Operations) {
        if ($Operations.Length -eq 0) {
            return [OperationChainDummy]::new()
        }

        $head = [OperationChainDummy]::new($Operations[0]) 
        [OperationChain[]] $current = @( $head )

        for ( $oI = 1; $oI -lt $Operations.Length; $oI++ ) {
            foreach ($n in $current.Next) {
                $n.Next = $Operations[$oI].GetOperations()
            }

            $current = $current.Next
        }

        return $head
    }

    hidden OperationChain() {
        $this.Next = @()
    }

    OperationChain([Operation] $operation) {
        $this.Operation = $operation
        $this.Next = @()
    }
}

class OperationChainDummy : OperationChain {
    [string[]] Evaluate([string] $value, [boolean] $isFailover) {
        return $this.GetChildrenResult(@($value), $isFailover)
    }

    OperationChainDummy() {
    }

    OperationChainDummy([OperationGroup] $Operations) : base(){
        $this.Next = $Operations.GetOperations()
    }
}
