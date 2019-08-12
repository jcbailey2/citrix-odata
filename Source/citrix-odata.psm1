#
# Script module for module 'citrix-odata'
# Generated by: Kilian Arjona
#
# Generated on: 2019-08-12T17:54:29
#

# Get public and private function definition files
$PSModule = $ExecutionContext.SessionState.Module
$PSModuleRoot = $PSModule.ModuleBase

$Public = @(Get-ChildItem -Path $PSModuleRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSModuleRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
foreach($import in @($Public + $Private)) {
    try {
        . $import.fullname
    } catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Make the cmdlets available
Export-ModuleMember -Function $Public.Basename
