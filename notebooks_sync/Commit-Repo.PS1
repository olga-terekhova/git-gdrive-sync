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

Write-Host "`n-------- locating repo -------`n"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$FullRepoPath = if ([System.IO.Path]::IsPathRooted($RepoPath)) { $RepoPath } 
                   else { [System.IO.Path]::GetFullPath((Join-Path $ScriptDir $RepoPath)) }
Write-Host "Full Path to Repo: $FullRepoPath"              

Set-Location $FullRepoPath


# --------------------------------------
# --- Execute git commands
# -----------------------------------

# Function: Git Add
function Invoke-GitAdd {

    $gitAddCommand = "add -A"
    $fullCommand = "git $gitAddCommand"
    Write-Host "`n-------- $fullCommand -------`n"
    Invoke-Expression $fullCommand | Out-Default
    Write-Host "Changes added to stage.`n"
}

# Function: Git Commit
function Invoke-GitCommit {
    Write-Host "Enter commit message: " -NoNewline
    $commitMessage = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($commitMessage)) {
        Write-Host "Commit message cannot be empty. Operation cancelled."
        return $false
    }
    
    $gitCommitCommand = "commit -m `"$commitMessage`""
    $fullCommand = "git $gitCommitCommand"
    Write-Host "`n-------- $fullCommand -------`n"
    Invoke-Expression $fullCommand | Out-Default
    return $true
}

# Function: Git Push
function Invoke-GitPush {
    $fullCommand = "git $PushCommand"
    Write-Host "`n-------- $fullCommand -------`n"
    Invoke-Expression $fullCommand | Out-Default
}

# Function: Ask for confirmation
function Get-Confirmation {
    param (
        [string]$Message
    )
    Write-Host "`n$Message (Y/N): " -NoNewline
    $response = Read-Host
    return ($response -eq "Y" -or $response -eq "y")
}

# Function: Show status and handle user choice
function Invoke-GitWorkflow {
    $gitStatusCommand = "status"
    $fullCommand = "git $gitStatusCommand"
    Write-Host "`n-------- $fullCommand -------`n"
    Invoke-Expression $fullCommand | Out-Default

    Write-Host "`nChoose an option:"
    Write-Host "  S - Check status"
    Write-Host "  A - Add all changes to stage"
    Write-Host "  C - Commit"
    Write-Host "  P - Push"
    Write-Host "  Q - Quit"
    Write-Host "Enter your choice (A/C/P/Q): " -NoNewline
    $response = Read-Host

    switch ($response.ToUpper()) {
        "Q" {
            Write-Host "Quitting..."
            return $false
	}
        "A" {
            Invoke-GitAdd
            
            if (-not (Get-Confirmation "Proceed with committing?")) {
                Write-Host "Operation cancelled."
                return $true
            }
            
            if (-not (Invoke-GitCommit)) {
                return $true
            }
            
            if (-not (Get-Confirmation "Proceed with pushing?")) {
                Write-Host "Operation cancelled."
                return $true
            }
            
            Invoke-GitPush
            Write-Host "`nAll operations completed successfully!"
        }
        "C" {
            if (-not (Invoke-GitCommit)) {
                return $true
            }
            
            if (-not (Get-Confirmation "Proceed with pushing?")) {
                Write-Host "Operation cancelled."
                return $true
            }
            
            Invoke-GitPush
            Write-Host "`nAll operations completed successfully!"
        }
        "P" {
            Invoke-GitPush
            Write-Host "`nPush completed successfully!"
        }
        default {
            Write-Host "Invalid option."
            return $true
        }
    }
    
    return $true
}

# Main loop
while ($true) {
    $continue = Invoke-GitWorkflow
    
    if (-not $continue) {
        break
    }
    
    if (-not (Get-Confirmation "Check git status again?")) {
        Write-Host "Done!"
        break
    }

}

# --------------------
# --- Post processing
# --------------------

# Return to the initial location

Set-Location $ScriptDir