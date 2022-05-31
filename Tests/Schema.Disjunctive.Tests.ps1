$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "Disjunctive <Name>" -ForEach @(
        @{
            Name     = "ext-{firstName(lower)(sel[0]|sel[0,1]|sel[0,2]|sel[0,3]|sel[0,1,2]|sel[0,1,2,3])}.{lastName(lower)} with firstName=Max;lastName=Mustermann"
            Schema   = [Schema]::new(
                @(
                    [Plain]::new("ext-"),
                    [Variable]::new(
                        $false,
                        "firstName",
                        @(
                            [OperationGroup]::new(
                                @(
                                    [ToLowerOp]::new()
                                ),
                                $false
                            ),
                            [OperationGroup]::new(
                                @(
                                    [SelectionOp]::new(@("0")),
                                    [SelectionOp]::new(@("0", "1")),
                                    [SelectionOp]::new(@("0", "2")),
                                    [SelectionOp]::new(@("0", "3")),
                                    [SelectionOp]::new(@("0", "1", "2")),
                                    [SelectionOp]::new(@("0", "1", "2", "3"))
                                ),
                                $false,
                                [OperationGroupType]::Disjunctive
                            )
                        )
                    ),
                    [Plain]::new("."),
                    [Variable]::new(
                        $false,
                        "lastName",
                        @(
                            [OperationGroup]::new(
                                @(
                                    [ToLowerOp]::new()
                                ),
                                $false
                            )
                        )
                    )
                )
            )
            Binding  = @{
                "firstName" = "Max"
                "lastName"  = "Mustermann"
            }
            Expected = @(
                [Value]::new($false, "ext-m.mustermann"),
                [Value]::new($false, "ext-ma.mustermann"),
                [Value]::new($false, "ext-mx.mustermann"),
                [Value]::new($false, "ext-m.mustermann"),
                [Value]::new($false, "ext-max.mustermann"),
                [Value]::new($false, "ext-max.mustermann")
            )
        },
        @{
            Name     = "{x(lower|countUp[1,3])}.{y(lower)} with x=AB;y=CD";
            Schema   = [Schema]::new(
                @(
                    [Variable]::new(
                        $false,
                        "x",
                        @(
                            [OperationGroup]::new(
                                @(
                                    [ToLowerOp]::new(),
                                    [CountUpOp]::new(@("1", "3"))
                                ),
                                $false,
                                [OperationGroupType]::Disjunctive
                            )
                        )
                    ),
                    [Plain]::new("."),
                    [Variable]::new(
                        $false,
                        "y",
                        @(
                            [OperationGroup]::new(
                                @(
                                    [ToLowerOp]::new()
                                ),
                                $false
                            )
                        )
                    )
                )
            );
            Binding  = @{
                "x" = "AB"
                "y" = "CD"
            };
            Expected = @(
                [Value]::new($false, "ab.cd"),
                [Value]::new($false, "AB1.cd"),
                [Value]::new($false, "AB2.cd"),
                [Value]::new($false, "AB3.cd")
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