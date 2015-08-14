param (
    $targetStage
)

Write-Verbose 'Entering agentrelease.ps1'


# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

# Find the RM client binaries
$registrykeys = @(
"HKLM:\Software\Microsoft\ReleaseManagement\14.0\Client\",
"HKLM:\Software\WOW6432Node\Microsoft\ReleaseManagement\14.0\Client\"
)

$registrykey = @($registrykeys | where { Test-Path $_ })

if ($registrykey.Count -eq 0) {
    Write-Error "The Release Management Client is not installed"
    exit 1
}

$binaryLocation = join-path (Get-ItemProperty $registrykey[0]).InstallDir "bin\ReleaseManagementBuild.exe"

# Call Release Management Build
$params = "release -tfs $($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI) -tp $($env:SYSTEM_TEAMPROJECT) -bd $($env:BUILD_DEFINITIONNAME) -bn $($env:BUILD_BUILDNUMBER)"
if ($targetStage) {
    &"$binaryLocation" release -tfs "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)" -tp "$($env:SYSTEM_TEAMPROJECT)" -bd "$($env:BUILD_DEFINITIONNAME)" -bn "$($env:BUILD_BUILDNUMBER)" -ts "$($targetStage)"    
}
else {
    &"$binaryLocation" release -tfs "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)" -tp "$($env:SYSTEM_TEAMPROJECT)" -bd "$($env:BUILD_DEFINITIONNAME)" -bn "$($env:BUILD_BUILDNUMBER)"
}

if ($LastExitCode -ne 0) {
    Write-Error "Release failed with an exit code of $LastExitCode"
}