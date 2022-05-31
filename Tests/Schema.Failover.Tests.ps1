$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "Basic Failover <Name>" -ForEach @(
        @{
            Name     = "{?x}.{y} with x=A;y=B"
            Schema   = [Schema]::new(
                @(
                    [Variable]::new(
                        $true,
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
                [Value]::new($false, ".B"),
                [Value]::new($true, "A.B")
            )
        },
        @{
            Name     = "{x(lower)(?countUp[1,3])}.{y(lower)} with x=AB;y=CD";
            Schema   = [Schema]::new(
                @(
                    [Variable]::new(
                        $false,
                        "x",
                        @(
                            [OperationGroup]::new(
                                @(
                                    [ToLowerOp]::new()
                                ),
                                $false
                            ),
                            [OperationGroup]::new(
                                @(
                                    [CountUpOp]::new(@("1", "3"))
                                ),
                                $true
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
            )
            Binding  = @{
                "x" = "AB"
                "y" = "CD"
            }
            Expected = @(
                [Value]::new($false, "ab.cd"),
                [Value]::new($true, "ab1.cd"),
                [Value]::new($true, "ab2.cd"),
                [Value]::new($true, "ab3.cd")
            )
        },
        @{
            Name     = "ext-{firstName(lower)}.{lastName(lower)(?countUP)}@{principalName(lower)} with firstName=Max;lastName=Mustermann;principalName=test.local";
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
                            ),
                            [OperationGroup]::new(
                                @(
                                    [CountUpOp]::new(@("1", "5"))
                                ),
                                $true
                            )
                        )
                    ),
                    [Plain]::new("@"),
                    [Variable]::new(
                        $false,
                        "principalName",
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
                "firstName"     = "Max"
                "lastName"      = "Mustermann"
                "principalName" = "test.local"
            };
            Expected = @(
                [Value]::new($false, "ext-max.mustermann@test.local"),
                [Value]::new($true, "ext-max.mustermann1@test.local"),
                [Value]::new($true, "ext-max.mustermann2@test.local"),
                [Value]::new($true, "ext-max.mustermann3@test.local"),
                [Value]::new($true, "ext-max.mustermann4@test.local"),
                [Value]::new($true, "ext-max.mustermann5@test.local")
            )
        },
        @{
            Name     = "{firstName(lower)(split)(?countUp[1,3])}.{lastName(lower)} with firstName=Max-Test;lastName=Mustermann"
            Schema   = [Schema]::new(
                @(
                    [Variable]::new(
                        $false,
                        "firstName",
                        @(
                            [OperationGroup]::new(
                                @(
                                    [ToLowerOp]::new()
                                )
                            ),
                            [OperationGroup]::new(
                                @(
                                    [SplitOp]::new()
                                )
                            ),
                            [OperationGroup]::new(
                                @(
                                    [CountUpOp]::new(@("1", "3"))
                                ),
                                $true
                            )
                        )
                    ),
                    [Plain]::new("."),
                    [Variable]::new(
                        $false,
                        "lastName",
                        @(
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
                [Value]::new($false, "test.mustermann"),
                [Value]::new($true, "max1.mustermann"),
                [Value]::new($true, "max2.mustermann"),
                [Value]::new($true, "max3.mustermann"),
                [Value]::new($true, "test1.mustermann"),
                [Value]::new($true, "test2.mustermann"),
                [Value]::new($true, "test3.mustermann")
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