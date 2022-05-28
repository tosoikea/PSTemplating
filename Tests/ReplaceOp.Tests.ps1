$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "ReplaceOp <Value>[<Parameter>]" -ForEach @(
        @{
            Value     = "A B";
            Parameter = @(" ", "-");
            Expected  = @(
                [Value]::new(
                    $false,
                    "A-B"
                )
            )
        },
        @{
            Value     = "AB";
            Parameter = @("$", " ");
            Expected  = @(
                [Value]::new(
                    $false,
                    "AB "
                )
            )
        },
        @{
            Value     = "AB";
            Parameter = @("^", " ");
            Expected  = @(
                [Value]::new(
                    $false,
                    " AB"
                )
            )
        }
    ) {
        It "Valid Evaluation" {
            # A) Setup
            $op = [ReplaceOp]::new(
                $false, 
                $Parameter
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