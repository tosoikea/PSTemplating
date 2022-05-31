$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    # Valid Schemas
    Describe "Operation Equality <Left> <Right>" -ForEach @(
        ## == TO LOWER ==
        @{
            Left     = [ToLowerOp]::new();
            Right    = [ToLowerOp]::new();
            Expected = $true
        },
        ## == TO UPPER ==
        @{
            Left     = [ToUpperOP]::new();
            Right    = [ToUpperOP]::new();
            Expected = $true
        },
        ## == SELECTION ==
        @{
            Left     = [SelectionOp]::new(@("1"));
            Right    = [SelectionOp]::new(@("1"));
            Expected = $true
        },
        @{
            Left     = [SelectionOp]::new(@("1"));
            Right    = [SelectionOp]::new(@("2"));
            Expected = $false
        },
        ## == COUNT DOWN ==
        @{
            Left     = [CountDownOp]::new(@("1", "2"));
            Right    = [CountDownOp]::new(@("1", "2"));
            Expected = $true
        },
        @{
            Left     = [CountDownOp]::new(@("1", "2"));
            Right    = [CountDownOp]::new(@("1", "3"));
            Expected = $false
        },
        @{
            Left     = [CountDownOp]::new(@("1", "2"));
            Right    = [CountDownOp]::new(@("3", "2"));
            Expected = $false
        },
        ## == COUNT UP ==
        @{
            Left     = [CountUpOp]::new(@("1", "2"));
            Right    = [CountUpOp]::new(@("1", "2"));
            Expected = $true
        },
        @{
            Left     = [CountUpOp]::new(@("1", "2"));
            Right    = [CountUpOp]::new(@("1", "3"));
            Expected = $false
        },
        @{
            Left     = [CountUpOp]::new(@("1", "2"));
            Right    = [CountUpOp]::new(@("3", "2"));
            Expected = $false
        }
    ) {
        It "Valid Equality" {
            # B) Operation
            $isEqual = $Left -eq $Right

            # C) Assertion
            $isEqual | Should -Be $Expected
        }
    }
    
    Describe "Variable Equality <Left> <Right>" -ForEach @(
        # == EQUAL ==
        @{
            Left     = [Variable]::new(
                $false,
                "x"
            );
            Right    = [Variable]::new(
                $false,
                "x"
            );
            Expected = $true
        },
        @{
            Left     = [Variable]::new(
                $false,
                "x",
                @(
                    [OperationGroup]::new(
                        @([ToLowerOp]::new()),
                        $true,
                        [OperationGroupType]::Conjunctive
                    )
                )
            );
            Right    = [Variable]::new(
                $false,
                "x",
                @(
                    [OperationGroup]::new(
                        @([ToLowerOp]::new()),
                        $true,
                        [OperationGroupType]::Conjunctive
                    )
                )
            );
            Expected = $true
        },
        @{
            Left     = [Variable]::new(
                $false,
                "x",
                @(
                    [OperationGroup]::new(
                        @([ToLowerOp]::new()),
                        $false
                    ),
                    [OperationGroup]::new(
                        @([SelectionOp]::new(@("0"))),
                        $true
                    ),
                    [OperationGroup]::new(
                        @([CountUpOp]::new(@("1", "3"))),
                        $true
                    )
                )
            );
            Right    = [Variable]::new(
                $false,
                "x",
                @(
                    [OperationGroup]::new(
                        @([ToLowerOp]::new()),
                        $false
                    ),
                    [OperationGroup]::new(
                        @([SelectionOp]::new(@("0"))),
                        $true
                    ),
                    [OperationGroup]::new(
                        @([CountUpOp]::new(@("1", "3"))),
                        $true
                    )
                )
            );
            Expected = $true
        },
        # == NOT EQUAL ==
        @{
            Left     = [Variable]::new(
                $true,
                "x"
            );
            Right    = [Variable]::new(
                $false,
                "x"
            );
            Expected = $false
        },
        @{
            Left     = [Variable]::new(
                $false,
                "y"
            );
            Right    = [Variable]::new(
                $false,
                "x"
            );
            Expected = $false
        }
    ) {
        It "Valid Equality" {
            # B) Operation
            $isEqual = $Left -eq $Right

            # C) Assertion
            $isEqual | Should -Be $Expected
        }
    }
}