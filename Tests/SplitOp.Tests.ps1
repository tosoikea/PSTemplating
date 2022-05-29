$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "SplitOp <Value>" -ForEach @(
        @{
            Value    = "Test";
            Expected = @(
                "test"
            )
        },
        @{
            Value    = "A B";
            Expected = @(
                "A", "B"
            )
        },
        @{
            Value    = "A B C";
            Expected = @(
                "A", "B", "C"
            )
        },
        @{
            Value    = "A B-C";
            Expected = @(
                "A", "B", "C"
            )
        },
        @{
            Value    = "A-B-C";
            Expected = @(
                "A", "B", "C"
            )
        }
        @{
            Value    = "A-B C-D";
            Expected = @(
                "A", "B", "C", "D"
            )
        }
    ) {
        It "Valid Evaluation" {
            # A) Setup
            $op = [SplitOp]::new()

            # B) Operation
            $values = $op.Execute(
                $Value
            )

            # C) Assertion
            $values | Should -Be $Expected
        }
    }
}