Remove-Module PSUnidecode -Force -ErrorAction SilentlyContinue

$ManifestPath = '{0}\..\src\PSUnidecode.psd1' -f $PSScriptRoot

Import-Module $ManifestPath -Force

Describe "Help tests for $moduleName" -Tags Build {

    $Functions = Get-Command -Module PSUnidecode -CommandType Function

    foreach ($Function in $Functions) {
        $help = Get-Help $Function.name
        Context $help.name {
            It "Has a description" {
                $help.description | Should Not BeNullOrEmpty
            }

            It "Has an example" {
                $help.examples | Should Not BeNullOrEmpty
            }

            foreach ($parameter in $help.parameters.parameter) {
                if ($parameter -notmatch 'whatif|confirm') {
                    It "Has a Parameter description for '$($parameter.name)'" {
                        $parameter.Description.text | Should Not BeNullOrEmpty
                    }
                }
            }
        }
    }
}