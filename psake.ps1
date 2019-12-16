properties {
    # These settings overwrite values supplied from the PowerShellBuild
    # module and govern how those tasks are executed
    $PSBPreference.Test.ScriptAnalysisEnabled = $true
    $PSBPreference.Test.CodeCoverage.Enabled  = $true
}

task default -depends Build

task Clean -FromModule "PowerShellBuild" -minimumVersion '0.3.0'
task Build -FromModule "PowerShellBuild" -minimumVersion '0.3.0'
task Publish -FromModule "PowerShellBuild" -minimumVersion '0.3.0'
task Test -FromModule "PowerShellBuild" -minimumVersion '0.3.0'
task Analyze -FromModule "PowerShellBuild" -minimumVersion '0.3.0'