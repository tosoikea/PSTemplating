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
                            [ToLowerOp]::new($false)
                        )
                    )
                )
            )
            Expected = [Operation[][]] @(
                # https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-arrays?view=powershell-7.2
                , [Operation[]] @(
                    [NoOp]::new(),
                    [ToLowerOp]::new($false)
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
                            [ToLowerOp]::new($true)
                        )
                    )
                )
            )
            Expected = [Operation[][]] @(
                [Operation[]] @(
                    [NoOp]::new(), 
                    [NoOp]::new()
                ),
                [Operation[]] @(
                    [NoOp]::new(),
                    [ToLowerOp]::new($true)
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
            $paths | Should -Be $expected
        }
    }
    
    Describe "Operation Failover <Name>" -ForEach @(
        @{
            Name     = "{x(lower?countUp[1,3])}.{y(lower)} with x=AB;y=CD";
            Schema   = [Schema]::new(
                @(
                    [Variable]::new(
                        $false,
                        "x",
                        @(
                            [OperationGroup]::new(
                                @(
                                    [ToLowerOp]::new($false),
                                    [CountUpOp]::new($true, @("1", "3"))
                                )
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
                                    [ToLowerOp]::new($false)
                                )
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
                [Value]::new($true, "AB1.cd"),
                [Value]::new($true, "AB2.cd"),
                [Value]::new($true, "AB3.cd")
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
                                    [ToLowerOp]::new($false),
                                    [CountUpOp]::new($true, @("1", "3"))
                                )
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
                                    [ToLowerOp]::new($false)
                                )
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