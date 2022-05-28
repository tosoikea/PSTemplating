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
}