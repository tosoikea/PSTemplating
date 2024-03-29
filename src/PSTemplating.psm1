#--Init
$Private:public = @()
$Private:private = @()
$Private:classes = @()
#-

# Load assemblies
$Private:public += Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "Public") -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue
$Private:private += Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "Private") -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue

# We need to manually (zzzzzz) specify the class loading order
$Private:classPath = (Join-Path -Path $PSScriptRoot -ChildPath "Classes")
$Private:classes += @(
    (Get-Item -Path (Join-Path -Path $Private:classPath -ChildPath "SchemaNode.ps1")),
    (Get-Item -Path (Join-Path -Path $Private:classPath -ChildPath "Schema.ps1")),
    (Get-Item -Path (Join-Path -Path $Private:classPath -ChildPath "Plain.ps1")),
    (Get-Item -Path (Join-Path -Path $Private:classPath -ChildPath "Value.ps1")),
    (Get-Item -Path (Join-Path -Path $Private:classPath -ChildPath "Operation.ps1")),
    (Get-Item -Path (Join-Path -Path $Private:classPath -ChildPath "OperationGroup.ps1")),
    (Get-Item -Path (Join-Path -Path $Private:classPath -ChildPath "Variable.ps1"))
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
Set-StrictMode -Version Latest
$Global:ErrorActionPreference = "Stop"
#--
