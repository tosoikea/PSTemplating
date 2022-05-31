$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "CountUpOp <Value>[<From>,<To>]" -ForEach @(
        @{
            Value    = "Test";
            From     = "0";
            To       = "3";
            Expected = @(
                "Test0",
                "Test1",
                "Test2",
                "Test3"
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
            From     = "0";
            To       = "-1";
            Expected = @()
        },
        @{
            Value    = "Test";
            From     = "-3";
            To       = "-1";
            Expected = @(
                "Test-3",
                "Test-2",
                "Test-1"
            )
        }
    ) {
        It "Valid Evaluation" {
            # A) Setup
            $op = [CountUpOp]::new(
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