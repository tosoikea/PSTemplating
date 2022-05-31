$manifestPath = Join-Path -Path (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "src") -ChildPath "PSTemplating.psd1" 
Import-Module $manifestPath -Force -ErrorAction Stop

InModuleScope PSTemplating {
    Describe "Conjunctive <Name>" -ForEach @(
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