$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "Substitution <Name>" -ForEach @(
        @{
            Name     = "{x} with x=A"
            Schema   = [Schema]::new(
                @(
                    [Variable]::new(
                        $false,
                        "x"
                    )
                )
            )
            Binding  = @{
                "x" = "A"
            }
            Expected = @(
                [Value]::new($false, "A")
            )
        },
        @{
            Name     = "{x} with x=A;z=8";
            Schema   = [Schema]::new(
                @(
                    [Variable]::new(
                        $false,
                        "x"
                    )
                )
            )
            Binding  = @{
                "x" = "A"
                "z" = 8
            }
            Expected = @(
                [Value]::new($false, "A")
            )
        },
        @{
            Name     = "{x}.{y} with x=A;y=B"
            Schema   = [Schema]::new(
                @(
                    [Variable]::new(
                        $false,
                        "x"
                    ),
                    [Plain]::new("."),
                    [Variable]::new(
                        $false,
                        "y"
                    )
                )
            )
            Binding  = @{
                "x" = "A"
                "y" = "B"
            }
            Expected = @(
                [Value]::new($false, "A.B")
            )
        },
        @{
            Name     = "{x}.{y} with x=A;y=B;z=C"
            Schema   = [Schema]::new(
                @(
                    [Variable]::new(
                        $false,
                        "x"
                    ),
                    [Plain]::new("."),
                    [Variable]::new(
                        $false,
                        "y"
                    )
                )
            )
            Binding  = @{
                "x" = "A"
                "y" = "B"
                "z" = "C"
            }
            Expected = @(
                [Value]::new($false, "A.B")
            )
        }
    ) {
        It "Correct Values" {
            # A) Setup
            $bindings = [System.Collections.Generic.Dictionary[String, String]]::new()
            for ($bindingEnum = $binding.GetEnumerator(); $bindingEnum.MoveNext(); ) {
                $bindings[$bindingEnum.Current.Key] = $bindingEnum.Current.Value
            }

            # B) Operation
            $values = Use-Schema -Schema $schema -Bindings $bindings

            # C) Assertion
            $values | Should -HaveCount $expected.Count
            $values | Should -Be $expected
        }
    }
}