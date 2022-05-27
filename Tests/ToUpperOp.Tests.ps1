$manifestPath = '{0}\..\src\PSTemplating.psd1' -f $PSScriptRoot
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "ToUpperOp <Value>" -ForEach @(
        @{
            Value    = "TEsT";
            Expected = @(
                [Value]::new(
                    $false,
                    "TEST"
                )
            )
        },
        @{
            Value    = "Vaasdasd";
            Expected = @(
                [Value]::new(
                    $false,
                    "VAASDASD"
                )
            )
        },
        @{
            Value    = "vasdasd";
            Expected = @(
                [Value]::new(
                    $false,
                    "VASDASD"
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
            $op = [ToUpperOp]::new(
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