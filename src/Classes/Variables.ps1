#Requires -Version 5.0
using module .\OperationChain.ps1

class Variable {
    hidden [OperationChain] $Operations
    hidden [string] $Name
    hidden [string] $Value

    [string] GetName() {
        return $this.Name
    }

    [string] GetValue() {
        return $this.Value
    }

    [string[]] Resolve([boolean] $isFailover) {
        return @()
    }

    Variable([string] $name, [Operation[]] $operations) {
        $this.Name = $name
        $this.Operations = [OperationChain]::new($operations)
    }
}

class FailoverVariable : Variable {

}