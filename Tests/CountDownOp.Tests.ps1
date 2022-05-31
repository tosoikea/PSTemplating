$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "CountDownOp <Value>[<From>,<To>]" -ForEach @(
        @{
            Value    = "Test";
            From     = "3";
            To       = "0";
            Expected = @(
                "Test3",
                "Test2",
                "Test1",
                "Test0"
            )
        },
        @{
            Value    = "Test";
            From     = "0";
            To       = "0";
            Expected = @(
                "Test0"
            )
        },
        @{
            Value    = "Test";
            From     = "-1";
            To       = "0";
            Expected = @()
        },
        @{
            Value    = "Test";
            From     = "-1";
            To       = "-3";
            Expected = @(
                "Test-1",
                "Test-2",
                "Test-3"
            )
        }
    ) {
        It "Valid Evaluation" {
            # A) Setup
            $op = [CountDownOp]::new(
                @(
                    $From,
                    $To
                )
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