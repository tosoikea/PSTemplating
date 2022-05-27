$manifestPath = '{0}\..\src\PSTemplating.psd1' -f $PSScriptRoot
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "SelectionOp <Value>[<Parameter>]" -ForEach @(
        @{
            Value     = "Test";
            Parameter = "0";
            Expected  = @(
                [Value]::new(
                    $false,
                    "T"
                )
            )
        },
        @{
            Value     = "Ci";
            Parameter = "2";
            Expected  = @(
                [Value]::new(
                    $false,
                    ""
                )
            )
        }
    ) {
        It "Correct Values" {
            # A) Setup
            $op = [SelectionOp]::new(
                $false, 
                @(
                    $Parameter
                )
            )

            # B) Operation
            $values = $op.Evaluate(
                [Value]::new(
                    $false,
                    $Value
                )
            )

            # C) Assertion
            $values | Should -Be $Expected
        }
    }
}