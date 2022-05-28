$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "ToLowerOp <Value>" -ForEach @(
        @{
            Value    = "TEsT";
            Expected = @(
                [Value]::new(
                    $false,
                    "test"
                )
            )
        },
        @{
            Value    = "Vaasdasd";
            Expected = @(
                [Value]::new(
                    $false,
                    "vaasdasd"
                )
            )
        },
        @{
            Value    = "vasdasd";
            Expected = @(
                [Value]::new(
                    $false,
                    "vasdasd"
                )
            )
        },
        @{
            Value    = "ADSDED";
            Expected = @(
                [Value]::new(
                    $false,
                    "adsded"
                )
            )
        }
    ) {
        It "Valid Evaluation" {
            # A) Setup
            $op = [ToLowerOp]::new(
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