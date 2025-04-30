# Current uv version
# Setup args
param(
    [Alias("f")][switch]$forces,
    [Alias("v")][switch]$verbose
)

$verbose_args = if ($verbose) {
    "--verbose"
}
else {
    "--quiet"
}
cls

# Check uv version
$uv_version = uv self version 
# Update uv
Write-Host "Updating uv..." -ForegroundColor Green
& uv self update $verbose_args

Write-Host
$uv_update_version = uv self version

if (-not $forces -and $uv_version -eq $uv_update_version) {
    Write-Host "uv version was the same as before. Exiting." -ForegroundColor Yellow
    Write-Host
    exit 0
}
else {
    Write-Host "uv version has been updated."
    Write-Host "Old version: $uv_version" -ForegroundColor Yellow
    Write-Host "New version: $uv_update_version" -ForegroundColor Green
}

Write-Host
try {
    Write-Host "Removing old packages in .venv folder..." -ForegroundColor Green
    # Remove the .venv folder
    if (Test-Path ".venv") {
        Write-Host "Found .venv folder. Removing..." -ForegroundColor Green
        $ProgressPreference = "SilentlyContinue"
        rm -r .venv -Force
        Write-Host "Old packages removed." -ForegroundColor Green
    }
    else {
        Write-Host "No .venv folder found." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Error checking for .venv folder: $_" -ForegroundColor Red
    exit 1
}

Write-Host
try {
    # Remove the uv.lock file
    Write-Host "Removing uv.lock file" -ForegroundColor Green
    if (Test-Path "uv.lock") {
        Write-Host "Found uv.lock file. Removing..." -ForegroundColor Green
        rm uv.lock
        Write-Host "uv.lock file removed." -ForegroundColor Green
    }
    else {
        Write-Host "No uv.lock file found." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Error checking for uv.lock file: $_" -ForegroundColor Red
    exit 1
}

Write-Host
try {
    Write-Host "Installing new packages..." -ForegroundColor Green
    # uv sync
    uv sync --extra cu124
    Write-Host "New packages installed." -ForegroundColor Green
}

catch {
    Write-Host "Error installing new packages: $_" -ForegroundColor Red
    exit 1
}

Write-Host
cls
uv self version
try {
    Write-Host "Running tests..." -ForegroundColor Green
    uv run main.py
}
catch {
    Write-Host "Error running tests: $_" -ForegroundColor Red
    exit 1
}

Write-Host
try {
    uv pip list | ForEach-Object {
        " " * 4 + $_
    } | Clip
    Write-Host "Package list copied to clipboard." -ForegroundColor Green 

}
catch {
    Write-Host "A terminating exception occurred: $_" -ForegroundColor Red
}
finally {
    Write-Host "Script completed." -ForegroundColor Green
}
