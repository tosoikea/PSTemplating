$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "Basic Failover <Name>" -ForEach @(
        @{
            Name     = "{?x}.{y} with x=A;y=B";
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
            );
            Binding  = @{
                "x" = "A"
                "y" = "B"
            };
            Expected = @(
                [Value]::new($false, ".B"),
                [Value]::new($true, "A.B")
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


    Describe "Operation Failover Paths for <Name>" -ForEach @(
        @{
            Name     = "{x(lower)}"
            Node     = [Variable]::new(
                $false,
                "x",
                @(
                    [OperationGroup]::new(
                        @(
                            [ToLowerOp]::new()
                        ),
                        $false
                    )
                )
            )
            Expected = @(
                # https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-arrays?view=powershell-7.2
                , [Tuple[bool, Operation[]]]::new(
                    $false,
                    @(
                        [NoOp]::new(),
                        [ToLowerOp]::new()
                    )
                ) 
            )
        },
        @{
            Name     = "{x(?lower)}"
            Node     = [Variable]::new(
                $false,
                "x",
                @(
                    [OperationGroup]::new(
                        @(
                            [ToLowerOp]::new()
                        ),
                        $true
                    )
                )
            )
            Expected = @(
                [Tuple[bool, Operation[]]]::new(
                    $false,
                    @(
                        [NoOp]::new(),
                        [NoOp]::new()
                    )
                ),
                [Tuple[bool, Operation[]]]::new(
                    $true,
                    @(
                        [NoOp]::new(),
                        [ToLowerOp]::new()
                    )
                )
            )
        },
        @{
            Name     = "{x(?replaceOp[$, ]&countUp[1,3])}"
            Node     = [Variable]::new(
                $false,
                "x",
                @(
                    [OperationGroup]::new(
                        @(
                            [ReplaceOp]::new(@("$", " ")),
                            [CountUpOp]::new(@("1", "3"))
                        ),
                        $true,
                        [OperationGroupType]::Conjunctive
                    )
                )
            )
            Expected = @(
                [Tuple[bool, Operation[]]]::new(
                    $false,
                    @(
                        [NoOp]::new(),
                        [NoOp]::new()
                    )
                ),
                [Tuple[bool, Operation[]]]::new(
                    $true,
                    @(
                        [NoOp]::new(),
                        [ReplaceOp]::new(@("$", " ")),
                        [CountUpOp]::new(@("1", "3"))
                    )
                )
            )
        }
    ) {
        It "Correct Path Generation" {
            # A) Setup
 
            # B) Operation
            $paths = Get-OperationPaths -Node $Node
 
            # C) Assertion
            $paths | Should -HaveCount $expected.Count
            for ([int] $i = 0; $i -lt $paths.Count; $i++) {
                $paths[$i].Item1 | Should -Be $expected[$i].Item1
                $paths[$i].Item2 | Should -Be $expected[$i].Item2
            } 
        }
    }
    
    Describe "Operation Failover <Name>" -ForEach @(
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
            );
            Binding  = @{
                "x" = "AB"
                "y" = "CD"
            };
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
            Name     = "ext-{firstName(lower)(sel[0]|sel[0,1]|sel[0,2]|sel[0,3]|sel[0,1,2]|sel[0,1,2,3])}.{lastName(lower)} with firstName=Max;lastName=Mustermann";
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
            );
            Binding  = @{
                "firstName" = "Max"
                "lastName"  = "Mustermann"
            };
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
            Name     = "{lastName(?replace[$, ]&countUp[1,3])}, {firstname} with firstName=Max;lastName=Mustermann";
            Schema   = [Schema]::new(
                @(
                    [Variable]::new(
                        $false,
                        "lastName",
                        @(
                            [OperationGroup]::new(
                                @(
                                    [ReplaceOp]::new(@("$", " ")),
                                    [CountUpOp]::new(@("1", "3"))
                                ),
                                $true,
                                [OperationGroupType]::Conjunctive
                            )
                        )
                    ),
                    [Plain]::new(", "),
                    [Variable]::new(
                        $false,
                        "firstName"
                    )
                )
            );
            Binding  = @{
                "firstName" = "Max"
                "lastName"  = "Mustermann"
            };
            Expected = @(
                [Value]::new($false, "Mustermann, Max"),
                [Value]::new($true, "Mustermann 1, Max"),
                [Value]::new($true, "Mustermann 2, Max"),
                [Value]::new($true, "Mustermann 3, Max")
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