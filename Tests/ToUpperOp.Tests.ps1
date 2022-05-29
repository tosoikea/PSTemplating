$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "ToUpperOp <Value>" -ForEach @(
        @{
            Value    = "TEsT";
            Expected = @(
                "TEST"
            )
        },
        @{
            Value    = "Vaasdasd";
            Expected = @(
                "VAASDASD"
            )
        },
        @{
            Value    = "vasdasd";
            Expected = @(
                "VASDASD"
            )
        },
        @{
            Value    = "ADSDED";
            Expected = @(
                "ADSDED"
            )
        }
    ) {
        It "Valid Evaluation" {
            # A) Setup
            $op = [ToUpperOp]::new()

            # B) Operation
            $values = $op.Execute(
                $Value
            )

            # C) Assertion
            $values | Should -Be $Expected
        }
    }
}