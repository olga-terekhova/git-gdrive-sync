
# --- CONFIGURATION ---

# Set a path to parameters
param (
    [Alias("p")][string]$paramPath
)

# Change the Windows console code page to 65001 (UTF-8)
chcp 65001

# Default to ./Params.ps1 if not provided
if (-not $paramPath) {
    $paramPath = Join-Path -Path $PSScriptRoot -ChildPath "_Params.ps1"
}

# Check if parameter file exists
if (-not (Test-Path $paramPath)) {
    Write-Error "Parameter file not found at: $paramPath"
    exit 1
}


# Source the parameter file to get $SourcePath, $DestInput
. $paramPath


# Ensure variables are set
if (-not ($SourcePath -and $DestInput)) {
    Write-Error "One or more required parameters are missing in $paramPath"
    exit 1
}


# --- EXECUTION ---
#Write-Host "Checking for changes in Google Drive..." -ForegroundColor Cyan


# Resolve Destination to Absolute Path
Write-Host "User-provided Destination Input: $DestInput"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DestinationPath = if ([System.IO.Path]::IsPathRooted($DestInput)) { $DestInput } 
                   else { [System.IO.Path]::GetFullPath((Join-Path $ScriptDir $DestInput)) }
Write-Host "Full Destination Path: $DestinationPath"              

Write-Host "Source Path: $SourcePath"

# Robocopy Switches:
# /MIR  : Mirrors the directory (Source is the boss). 
# /XO   : Exclude Older (Don't overwrite a newer local file with an older Drive file).
# /Z    : Restartable mode (safe for network interruptions).
# /W:5  : Wait 5 seconds on failure.
# /R:2  : Retry twice.
# /XD   : Exclude Directories (optional, e.g., .ipynb_checkpoints).



#robocopy "$SourcePath" "$DestinationPath" *.ipynb /MIR /XO /Z /W:5 /R:2 /XD ".ipynb_checkpoints"
##robocopy "$SourcePath" "$DestinationPath" *.ipynb /XO /Z /W:5 /R:2 /XD ".ipynb_checkpoints"


#if ($LASTEXITCODE -le 3) {
#    Write-Host "Sync Successful! Ready to commit." -ForegroundColor Green
#} elseif ($LASTEXITCODE -eq 0) {
#    Write-Host "No changes detected." -ForegroundColor Yellow
#} else {
#    Write-Host "Robocopy encountered an issue. Check the logs." -ForegroundColor Red
#}

Write-Host "Build finished"