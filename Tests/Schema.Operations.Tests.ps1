$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "Substitution <Name>" -ForEach @(
        @{
            Name     = "{x(lower)} with x=A"
            Schema   = [Schema]::new(
                @(
                    [Variable]::new(
                        $false,
                        "x", @(
                            [OperationGroup]::new(
                                @(
                                    [ToLowerOp]::new()
                                )
                            )
                        )
                    )
                )
            )
            Binding  = @{
                "x" = "A"
            }
            Expected = @(
                [Value]::new($false, "a")
            )
        },
        @{
            Name     = "{firstName(lower)(split)}.{lastName(lower)} with firstName=Max-Test;lastName=Mustermann"
            Schema   = [Schema]::new(
                @(
                    [Variable]::new(
                        $false,
                        "firstName", @(
                            [OperationGroup]::new(
                                @(
                                    [ToLowerOp]::new()
                                )
                            ),
                            [OperationGroup]::new(
                                @(
                                    [SplitOp]::new()
                                )
                            )
                        )
                    ),
                    [Plain]::new("."),
                    [Variable]::new(
                        $false,
                        "lastName", @(
                            , [OperationGroup]::new(
                                @(
                                    [ToLowerOp]::new()
                                )
                            )
                        )

                    )
                )
            )
            Binding  = @{
                "firstName" = "Max-Test"
                "lastName"  = "Mustermann"
            }
            Expected = @(
                [Value]::new($false, "max.mustermann"),
                [Value]::new($false, "test.mustermann")
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