$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "SelectionOp <Value>[<Parameter>]" -ForEach @(
        @{
            Value     = "Test";
            Parameter = @("0");
            Expected  = @(
                "T"
            )
        },
        @{
            Value     = "Ci";
            Parameter = @("2");
            Expected  = @(
                ""
            )
        },
        @{
            Value     = "Ci";
            Parameter = @("-1");
            Expected  = @(
                ""
            )
        },
        @{
            Value     = "Ci";
            Parameter = @("1");
            Expected  = @(
                "i"
            )
        },
        @{
            Value     = "Ci";
            Parameter = @("1", "0");
            Expected  = @(
                "iC"
            )
        }
    ) {
        It "Valid Evaluation" {
            # A) Setup
            $op = [SelectionOp]::new(
                $Parameter
            )

            # B) Operation
            $values = $op.Execute(
                $Value
            )

            # C) Assertion
            $values | Should -Be $Expected
        }
    }
}