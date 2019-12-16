[cmdletbinding(DefaultParameterSetName = 'Task')]
param(
    # Build task(s) to execute
    [parameter(ParameterSetName = 'task', position = 0)]
    [string] $Task = 'default',
    # Bootstrap dependencies
    [switch] $Bootstrap,
    # List available build tasks
    [switch] $Help,
    [switch] $NoBuild,
    [switch] $LocalDeploy
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'
$BasePath = $PSScriptRoot

[string] $requiremensPath = Join-Path -Path $BasePath -ChildPath 'requirements.psd1'
[string] $psakeFile = Join-Path -Path $BasePath -ChildPath 'psake.ps1'

[string] $outputPath = Join-Path -Path $BasePath -ChildPath "Output"
[string] $deployPath = "C:\Program Files\PowerShell\Modules"
$shouldDeploy = $LocalDeploy.IsPresent

# Bootstrap dependencies
if ($Bootstrap.IsPresent) {
    Get-PackageProvider -Name Nuget -ForceBootstrap | Out-Null
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

    if (-not (Get-Module -Name PSDepend -ListAvailable)) {
        Write-Information "Installing PSDepend"
        Install-Module -Name PSDepend -Repository PSGallery
    }

    Import-Module -Name PSDepend -Verbose:$false
    Write-Information "Installing Dependencies"
    Invoke-PSDepend -Path $requiremensPath -Install -Import -Force
}

# Execute psake task(s)

if ($Help.IsPresent) {
    Get-PSakeScriptTasks -buildFile $psakeFile |
    Format-Table -Property Name, Description, Alias, DependsOn
} 
elseif (-not $NoBuild.IsPresent) {

    if (-not $Bootstrap.IsPresent) {
        Write-Information "Installing Dependencies"
        Write-Verbose -Message ("{0} :: Importing Dependencies" -f $MyInvocation.MyCommand)
        Invoke-PSDepend -Path $requiremensPath -Import -Force
    }

    Write-Verbose -Message ("{0} :: Starting PSake" -f $MyInvocation.MyCommand)
    Invoke-psake -buildFile $psakeFile -taskList $Task -nologo

    #Deploy output locally
    if ($shouldDeploy) {
        Write-Information -MessageData ("{0} :: Deploying locally" -f $MyInvocation.MyCommand)
        Copy-Item -Path (Join-Path -Path $outputPath -ChildPath "*") -Destination $deployPath -Force -Recurse
    }

    exit ( [int]( -not $psake.build_success ) )
}