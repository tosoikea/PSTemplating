$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    # Valid Schemas
    Describe "ConvertFrom-SchemaText -Schema <Schema>" -ForEach @(
        @{
            Schema   = "{?x}.{y}";
            Expected = [Schema]::new(
                @(
                    [Variable]::new(
                        $true,
                        "x"
                    ),
                    [Plain]::new(
                        "."
                    ),
                    [Variable]::new(
                        $false,
                        "y"
                    )
                )
            )
        },
        @{
            Schema   = "{x(lower)(?sel[0])(?countUp[1,3])}";
            Expected = [Schema]::new(
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
                                    [SelectionOp]::new(@("0"))
                                ),
                                $true
                            ),
                            [OperationGroup]::new(
                                @(
                                    [CountUpOp]::new(@("1", "3"))
                                ),
                                $true
                            )
                        )
                    )
                )
            )
        },
        @{
            Schema   = "{x(lower)(?sel[0]|countUp[1,3])}";
            Expected = [Schema]::new(
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
                                    [SelectionOp]::new(@("0")),
                                    [CountUpOp]::new(@("1", "3"))
                                ),
                                $true,
                                [OperationGroupType]::Disjunctive
                            )
                        )
                    )
                )
            )
        },
        @{
            Schema   = "{x(lower)(?sel[0]&countUp[1,3])}";
            Expected = [Schema]::new(
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
                                    [SelectionOp]::new(@("0")),
                                    [CountUpOp]::new(@("1", "3"))
                                ),
                                $true,
                                [OperationGroupType]::Conjunctive
                            )
                        )
                    )
                )
            )
        },
        @{
            Schema   = "ext-{firstName(lower)}.{lastName(lower)(?countUp[1,9])}@{principalName(lower)}";
            Expected = [Schema]::new(
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
                                    [CountUpOp]::new(@("1", "9"))
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
            )
        },
        @{
            Schema   = "ext-{firstName(lower)(sel[0]|sel[0,1]|sel[0,2]|sel[0,1,2])}.{lastName(lower)(?split)}";
            Expected = [Schema]::new(
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
                                    [SelectionOp]::new(@("0", "1", "2"))
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
                            ),
                            [OperationGroup]::new(
                                @(
                                    [SplitOp]::new()
                                ),
                                $true
                            )
                        )
                    )
                )
            )
        },
        @{
            Schema   = "{lastName(?replace[$, ]&countUp)}, {firstName} (extern)";
            Expected = [Schema]::new(
                @(
                    [Variable]::new(
                        $false,
                        "lastName",
                        @(
                            [OperationGroup]::new(
                                @(
                                    [ReplaceOp]::new(@("$", " ")),
                                    [CountUpOp]::new(@())
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
                    ),
                    [Plain]::new(" (extern)")
                )
            )
        },
        @{
            Schema   = "{?firstName(lower)(sel[0]|sel[0,1]|sel[0,2]|sel[0,1,2])}{lastName(lower)(?split)}"
            Expected = [Schema]::new(
                @(
                    [Variable]::new(
                        $true,
                        "firstName",
                        @(
                            [OperationGroup]::new(
                                @(
                                    [ToLowerOp]::new()
                                )
                            ),
                            [OperationGroup]::new(
                                @(
                                    [SelectionOp]::new(@("0")),
                                    [SelectionOp]::new(@("0", "1")),
                                    [SelectionOp]::new(@("0", "2")),
                                    [SelectionOp]::new(@("0", "1", "2"))
                                ),
                                $false,
                                [OperationGroupType]::Disjunctive
                            )
                        )
                    ),
                    [Variable]::new(
                        $false,
                        "lastName",
                        @(
                            [OperationGroup]::new(
                                @(
                                    [ToLowerOp]::new()
                                )
                            ),
                            [OperationGroup]::new(
                                @(
                                    [SplitOp]::new()
                                ),
                                $true
                            )
                        )
                    )
                )
            )
        },
        @{
            Schema   = "<p>Hallo {firstName},<\/p>";
            Expected = [Schema]::new(
                @(
                    [Plain]::new("<p>Hallo ")
                    [Variable]::new(
                        $false,
                        "firstName"
                    ),
                    [Plain]::new(",<\/p>")
                )
            )
        },
        @{
            Schema   = "user account created for {givenName} {surName} in {city} ({company})";
            Expected = [Schema]::new(
                @(
                    [Plain]::new("user account created for ")
                    [Variable]::new(
                        $false,
                        "givenName"
                    ),
                    [Plain]::new(" "),
                    [Variable]::new(
                        $false,
                        "surName"
                    ),
                    [Plain]::new(" in "),
                    [Variable]::new(
                        $false,
                        "city"
                    ),
                    [Plain]::new(" ("),
                    [Variable]::new(
                        $false,
                        "company"
                    ),
                    [Plain]::new(")")
                )
            )
        }
    ) {
        It "Valid Parsing" {
            # B) Operation
            $parsed = ConvertFrom-SchemaText -Schema $Schema

            # C) Assertion
            $parsed | Should -Be $Expected
        }
    }
}