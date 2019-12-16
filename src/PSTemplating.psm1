#--Init
$Private:public = @()
$Private:private = @()
$Private:classes = @()
#-

#Load assemblies
$Private:public += Get-ChildItem -Path "$PSScriptRoot\public\" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue
$Private:private += Get-ChildItem -Path "$PSScriptRoot\private\" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue
$Private:classes += Get-ChildItem -Path "$PSScriptRoot\classes\" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue

foreach ($import in @($Private:public + $Private:private + $Private:classes)) {
    Try {
        . $import.fullname
        Write-Host $import.fullname
    }
    Catch {
        Throw "Failed to import function $($import.fullname): $_"
    }
}

#Export to shell usage
Export-ModuleMember -Function $Private:public.BaseName
Export-ModuleMember -Function $Private:classes.Basename

#-- Strict
Set-StrictMode -Version 2.0
$Global:ErrorActionPreference = "Stop"
#--
