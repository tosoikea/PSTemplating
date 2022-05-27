$manifestPath = '{0}\..\src\PSTemplating.psd1' -f $PSScriptRoot
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    # Valid Schemas
    Describe "Operation Equality <Left> <Right>" -ForEach @(
        ## == TO LOWER ==
        @{
            Left     = [ToLowerOp]::new($false);
            Right    = [ToLowerOp]::new($false);
            Expected = $true
        },
        @{
            Left     = [ToLowerOp]::new($true);
            Right    = [ToLowerOp]::new($false);
            Expected = $false
        },
        @{
            Left     = [ToLowerOp]::new($false);
            Right    = [ToUpperOP]::new($false);
            Expected = $false
        },
        ## == TO UPPER ==
        @{
            Left     = [ToUpperOP]::new($false);
            Right    = [ToUpperOP]::new($false);
            Expected = $true
        },
        @{
            Left     = [ToUpperOP]::new($true);
            Right    = [ToUpperOP]::new($false);
            Expected = $false
        },
        @{
            Left     = [ToUpperOP]::new($false);
            Right    = [ToLowerOp]::new($false);
            Expected = $false
        },
        ## == SELECTION ==
        @{
            Left     = [SelectionOp]::new($false, @("1"));
            Right    = [SelectionOp]::new($false, @("1"));
            Expected = $true
        },
        @{
            Left     = [SelectionOp]::new($true, @("1"));
            Right    = [SelectionOp]::new($false, @("1"));
            Expected = $false
        },
        @{
            Left     = [SelectionOp]::new($false, @("1"));
            Right    = [SelectionOp]::new($false, @("2"));
            Expected = $false
        },
        ## == COUNT DOWN ==
        @{
            Left     = [CountDownOp]::new($false, @("1", "2"));
            Right    = [CountDownOp]::new($false, @("1", "2"));
            Expected = $true
        },
        @{
            Left     = [CountDownOp]::new($true, @("1", "2"));
            Right    = [CountDownOp]::new($false, @("1", "2"));
            Expected = $false
        },
        @{
            Left     = [CountDownOp]::new($false, @("1", "2"));
            Right    = [CountDownOp]::new($false, @("1", "3"));
            Expected = $false
        },
        @{
            Left     = [CountDownOp]::new($false, @("1", "2"));
            Right    = [CountDownOp]::new($false, @("3", "2"));
            Expected = $false
        },
        ## == COUNT UP ==
        @{
            Left     = [CountUpOp]::new($false, @("1", "2"));
            Right    = [CountUpOp]::new($false, @("1", "2"));
            Expected = $true
        },
        @{
            Left     = [CountUpOp]::new($true, @("1", "2"));
            Right    = [CountUpOp]::new($false, @("1", "2"));
            Expected = $false
        },
        @{
            Left     = [CountUpOp]::new($false, @("1", "2"));
            Right    = [CountUpOp]::new($false, @("1", "3"));
            Expected = $false
        },
        @{
            Left     = [CountUpOp]::new($false, @("1", "2"));
            Right    = [CountUpOp]::new($false, @("3", "2"));
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
                        @([ToLowerOp]::new($false))
                    )
                )
            );
            Right    = [Variable]::new(
                $false,
                "x",
                @(
                    [OperationGroup]::new(
                        @([ToLowerOp]::new($false))
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