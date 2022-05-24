#--Init
$Private:public = @()
$Private:private = @()
$Private:classes = @()
#-

# Load assemblies
$Private:public += Get-ChildItem -Path "$PSScriptRoot\public\" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue
$Private:private += Get-ChildItem -Path "$PSScriptRoot\private\" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue

# We need to manually (zzzzzz) specify the class loading order
$Private:classes += @(
    (Get-Item -Path "$PSScriptRoot\classes\Value.ps1"),
    (Get-Item -Path "$PSScriptRoot\classes\Operation.ps1"),
    (Get-Item -Path "$PSScriptRoot\classes\OperationGroup.ps1"),
    (Get-Item -Path "$PSScriptRoot\classes\Variable.ps1")
)

foreach ($import in @($Private:public + $Private:private + $Private:classes)) {
    Try {
        . $import.fullname
    }
    Catch {
        Throw "Failed to import function $($import.fullname): $_"
    }
}

#Export to shell usage
Export-ModuleMember -Function $Private:public.BaseName
Export-ModuleMember -Function $Private:classes.BaseName

#-- Strict
Set-StrictMode -Version 2.0
$Global:ErrorActionPreference = "Stop"
#--
