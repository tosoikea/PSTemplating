$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "ReplaceOp <Value>[<Parameter>]" -ForEach @(
        @{
            Value     = "A B";
            Parameter = @(" ", "-");
            Expected  = @(
                "A-B"
            )
        },
        @{
            Value     = "AB";
            Parameter = @("$", " ");
            Expected  = @(
                "AB "
            )
        },
        @{
            Value     = "AB";
            Parameter = @("^", " ");
            Expected  = @(
                " AB"
            )
        }
    ) {
        It "Valid Evaluation" {
            # A) Setup
            $op = [ReplaceOp]::new(
                $Parameter
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