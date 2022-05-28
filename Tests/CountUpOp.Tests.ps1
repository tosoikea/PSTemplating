$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "CountUpOp <Value>[<From>,<To>]" -ForEach @(
        @{
            Value    = "Test";
            From     = "0";
            To       = "3";
            Expected = @(
                [Value]::new(
                    $false,
                    "Test0"
                ),
                [Value]::new(
                    $false,
                    "Test1"
                ),
                [Value]::new(
                    $false,
                    "Test2"
                ),
                [Value]::new(
                    $false,
                    "Test3"
                )
            )
        },
        @{
            Value    = "Test";
            From     = "0";
            To       = "0";
            Expected = @(
                [Value]::new(
                    $false,
                    "Test0"
                )
            )
        },
        @{
            Value    = "Test";
            From     = "0";
            To       = "-1";
            Expected = @()
        },
        @{
            Value    = "Test";
            From     = "-3";
            To       = "-1";
            Expected = @(
                [Value]::new(
                    $false,
                    "Test-3"
                ),
                [Value]::new(
                    $false,
                    "Test-2"
                ),
                [Value]::new(
                    $false,
                    "Test-1"
                )
            )
        }
    ) {
        It "Valid Evaluation" {
            # A) Setup
            $op = [CountUpOp]::new(
                $false, 
                @(
                    $From,
                    $To
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