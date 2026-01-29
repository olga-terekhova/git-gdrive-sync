#
# --- CONFIGURATION ---
#

# Set a path to parameters
param (
    [Alias("p")][string]$paramPath
)

# Default to ./Params.ps1 if not provided
if (-not $paramPath) {
    $paramPath = Join-Path -Path $PSScriptRoot -ChildPath "_Params.ps1"
}

# Check if parameter file exists
if (-not (Test-Path $paramPath)) {
    Write-Error "Parameter file not found at: $paramPath"
    exit 1
}

# Source the parameter file to get $RepoPath and $PushCommand
. $paramPath

# Ensure variables are set
if (-not ($RepoPath -and $PushCommand)) {
    Write-Error "One or more required parameters are missing in $paramPath"
    exit 1
}


#
# --- EXECUTION ---
#


# -----------------------------------
# --- Resolve path to repo
# -----------------------------------


$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$FullRepoPath = if ([System.IO.Path]::IsPathRooted($RepoPath)) { $RepoPath } 
                   else { [System.IO.Path]::GetFullPath((Join-Path $ScriptDir $RepoPath)) }
Write-Host "Full Path to Repo: $FullRepoPath"              

Set-Location $FullRepoPath


# --------------------------------------
# --- Execute git commands
# -----------------------------------

# Step 1: Show git status

$gitStatusCommand = "status"
$fullCommand = "git $gitStatusCommand"
Invoke-Expression $fullCommand

Write-Host "`nProceed with adding all changes to the stage and committing? (Y/N): " -NoNewline
$response = Read-Host

if ($response -ne "Y" -and $response -ne "y") {
    Write-Host "Operation cancelled."
    exit
}

# Step 2: Git add

$gitAddCommand = "add -A"
$fullCommand = "git $gitAddCommand"
Invoke-Expression $fullCommand
Write-Host "Changes added to stage.`n"

Write-Host "Proceed with committing? (Y/N): " -NoNewline
$response = Read-Host

if ($response -ne "Y" -and $response -ne "y") {
    Write-Host "Operation cancelled."
    exit
}

# Step 3: Get commit message and commit

Write-Host "Enter commit message: " -NoNewline
$commitMessage = Read-Host

if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    Write-Host "Commit message cannot be empty. Operation cancelled."
    exit
}

$gitCommitCommand = "commit -m `"$commitMessage`""
$fullCommand = "git $gitCommitCommand"
Invoke-Expression $fullCommand

Write-Host "`nProceed with pushing? (Y/N): " -NoNewline
$response = Read-Host

if ($response -ne "Y" -and $response -ne "y") {
    Write-Host "Operation cancelled."
    exit
}

# Step 4: Git push
# Push command is sourced from the parameters file

$gitPushCommand = $PushCommand 
$fullCommand = "git $gitPushCommand"
Invoke-Expression $fullCommand

Write-Host "`nAll operations completed successfully!"

# Return to the initial location

Set-Location $ScriptDir