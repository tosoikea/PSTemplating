$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "SplitOp <Value>" -ForEach @(
        @{
            Value    = "Test";
            Expected = @(
                [Value]::new(
                    $false,
                    "test"
                )
            )
        },
        @{
            Value    = "A B";
            Expected = @(
                [Value]::new(
                    $false,
                    "A"
                ),
                [Value]::new(
                    $false,
                    "B"
                )
            )
        },
        @{
            Value    = "A B C";
            Expected = @(
                [Value]::new(
                    $false,
                    "A"
                ),
                [Value]::new(
                    $false,
                    "B"
                ),
                [Value]::new(
                    $false,
                    "C"
                )
            )
        },
        @{
            Value    = "A B-C";
            Expected = @(
                [Value]::new(
                    $false,
                    "A"
                ),
                [Value]::new(
                    $false,
                    "B"
                ),
                [Value]::new(
                    $false,
                    "C"
                )
            )
        },
        @{
            Value    = "A-B-C";
            Expected = @(
                [Value]::new(
                    $false,
                    "A"
                ),
                [Value]::new(
                    $false,
                    "B"
                ),
                [Value]::new(
                    $false,
                    "C"
                )
            )
        }
        @{
            Value    = "A-B C-D";
            Expected = @(
                [Value]::new(
                    $false,
                    "A"
                ),
                [Value]::new(
                    $false,
                    "B"
                ),
                [Value]::new(
                    $false,
                    "C"
                ),
                [Value]::new(
                    $false,
                    "D"
                )
            )
        }
    ) {
        It "Valid Evaluation" {
            # A) Setup
            $op = [SplitOp]::new(
                $false
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