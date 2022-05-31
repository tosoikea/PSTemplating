$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
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
}