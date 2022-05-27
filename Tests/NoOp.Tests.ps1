$manifestPath = '{0}\..\src\PSTemplating.psd1' -f $PSScriptRoot
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "NoOp <Value>" -ForEach @(
        @{
            Value    = "TEsT";
            Expected = @(
                [Value]::new(
                    $false,
                    "TEsT"
                )
            )
        },
        @{
            Value    = "Vaasdasd";
            Expected = @(
                [Value]::new(
                    $false,
                    "Vaasdasd"
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
                    "ADSDED"
                )
            )
        }
    ) {
        It "Valid Evaluation" {
            # A) Setup
            $op = [NoOp]::new()

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