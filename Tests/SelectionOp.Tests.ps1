$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
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
        },
        @{
            Value     = "Ci";
            Parameter = "-1";
            Expected  = @(
                [Value]::new(
                    $false,
                    ""
                )
            )
        },
        @{
            Value     = "Ci";
            Parameter = "1";
            Expected  = @(
                [Value]::new(
                    $false,
                    "i"
                )
            )
        }
    ) {
        It "Valid Evaluation" {
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