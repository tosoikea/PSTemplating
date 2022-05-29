$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "ToLowerOp <Value>" -ForEach @(
        @{
            Value    = "TEsT";
            Expected = @(
                "test"
            )
        },
        @{
            Value    = "Vaasdasd";
            Expected = @(
                "vaasdasd"
            )
        },
        @{
            Value    = "vasdasd";
            Expected = @(
                "vasdasd"
            )
        },
        @{
            Value    = "ADSDED";
            Expected = @(
                "adsded"
            )
        }
    ) {
        It "Valid Evaluation" {
            # A) Setup
            $op = [ToLowerOp]::new()

            # B) Operation
            $values = $op.Execute(
                $Value
            )

            # C) Assertion
            $values | Should -Be $Expected
        }
    }
}