param (
    [string]$tokenPattern
)

Write-Verbose 'Entering tokenmanager.ps1'
Write-Verbose "tokenPattern = $tokenPattern"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

if(!$tokenPattern)
{
    throw (Get-LocalizedString -Key "Token pattern parameter is not set")
}

if ($tokenPattern.Contains("*") -or $tokenPattern.Contains("?"))
{
    Write-Verbose "Pattern found in tokenPattern parameter."
    Write-Verbose "Find-Files -SearchPattern $tokenPattern"
    $tokenPatternFiles = Find-Files -SearchPattern $tokenPattern
    Write-Verbose "solutionFiles = $tokenPatternFiles"
}


$tokenPatternFiles | % { 
    $nonTokenized = $_.Replace('.token', '')
    if (test-path $nonTokenized) {
        remove-item $nonTokenized -Force
        Write-Output "Renaming $nonTokenized"
    }
    Write-Output "Renaming $_ to $nonTokenized"
    rename-item $_ $nonTokenized -force 
 } 

