# ============================================================
# PROFESSIONAL LOCKER PASSWORD GENERATOR
# Personal PowerShell Project - v2.0
# ============================================================
#
# I was bored, so I made this little personal project to generate
# the password for my professional locker from my desktop wallpaper.
#
# The wallpaper is not included in this project.
# Put this script in the same folder as the image and select the
# image from the list when the script starts.
# ============================================================

$ErrorActionPreference = "Stop"

function Write-Info($Text) {
    Write-Host $Text -ForegroundColor DarkGray
}

function Write-OK($Text) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $Text -ForegroundColor Gray
}

function Write-Fail($Text) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host $Text -ForegroundColor Gray
}

function Spinner($Label, $DurationMs = 900) {
    $frames = @("|", "/", "-", "\")
    $steps = [Math]::Max(8, [int]($DurationMs / 90))

    for ($i = 0; $i -lt $steps; $i++) {
        Write-Host "`r  " -NoNewline
        Write-Host $frames[$i % $frames.Count] -ForegroundColor Cyan -NoNewline
        Write-Host " $Label" -ForegroundColor DarkGray -NoNewline
        Start-Sleep -Milliseconds 90
    }

    Write-Host "`r  " -NoNewline
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $Label -ForegroundColor Gray
}

Clear-Host

Write-Host ""
Write-Host "============================================================" -ForegroundColor DarkCyan
Write-Host "             PROFESSIONAL LOCKER PASSWORD GENERATOR" -ForegroundColor Cyan
Write-Host "                       Personal Project" -ForegroundColor DarkCyan
Write-Host "                         Version 2.0" -ForegroundColor DarkCyan
Write-Host "============================================================" -ForegroundColor DarkCyan
Write-Host ""

Write-Host "PROJECT NOTE" -ForegroundColor White
Write-Host "------------------------------------------------------------" -ForegroundColor DarkCyan
Write-Info "I was bored, so I made this little personal project."
Write-Info "Its purpose is to generate the password for my"
Write-Info "professional locker from my desktop wallpaper."
Write-Host ""
Write-Info "The wallpaper is converted into a deterministic"
Write-Info "four-digit fingerprint and represented as a SHA-256 hash."
Write-Host ""

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Discover image files in the folder containing this script.
# No path is requested from the user.
$imageFiles = @(
    Get-ChildItem -LiteralPath $scriptDirectory -File |
    Where-Object {
        $_.Extension.ToLowerInvariant() -in @(
            ".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tif", ".tiff"
        )
    } |
    Sort-Object Name
)

if ($imageFiles.Count -eq 0) {
    Write-Host ""
    Write-Fail "No image files were found in this folder."
    Write-Info "Place the workplace wallpaper next to this script and run it again."
    Write-Host ""
    Start-Sleep -Seconds 3
    exit 1
}

Write-Host "IMAGE SELECTION" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------" -ForegroundColor DarkCyan
Write-Host ""
Write-Info "Select the image you want to analyse."
Write-Info "Only image files in this script's folder are listed."
Write-Host ""

for ($i = 0; $i -lt $imageFiles.Count; $i++) {
    Write-Host ("  [{0}] " -f ($i + 1)) -ForegroundColor Cyan -NoNewline
    Write-Host $imageFiles[$i].Name -ForegroundColor White
}

Write-Host ""

$selection = Read-Host "Enter the number of the image"

[int]$selectedNumber = 0

if (-not [int]::TryParse($selection, [ref]$selectedNumber)) {
    Write-Host ""
    Write-Fail "Invalid selection."
    Write-Host ""
    Start-Sleep -Seconds 3
    exit 1
}

if ($selectedNumber -lt 1 -or $selectedNumber -gt $imageFiles.Count) {
    Write-Host ""
    Write-Fail "That image selection is not available."
    Write-Host ""
    Start-Sleep -Seconds 3
    exit 1
}

$imageFile = $imageFiles[$selectedNumber - 1]

Write-Host ""
Write-Host "Selected image: " -ForegroundColor DarkGray -NoNewline
Write-Host $imageFile.Name -ForegroundColor Yellow
Write-Host ""

$image = $null

try {
    Add-Type -AssemblyName System.Drawing
    $image = [System.Drawing.Image]::FromFile($imageFile.FullName)
}
catch {
    Write-Host ""
    Write-Fail "The selected file could not be read as an image."
    Write-Host ""
    Start-Sleep -Seconds 3
    exit 1
}

try {
    $bytes = [System.IO.File]::ReadAllBytes($imageFile.FullName)

    Write-Host "ANALYSIS" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------" -ForegroundColor DarkCyan

    Spinner "Reading image data" 900
    Write-OK ("Image dimensions: {0} x {1}" -f $image.Width, $image.Height)
    Write-OK ("Image data length: {0} bytes" -f $bytes.Length)

    Spinner "Generating deterministic image fingerprint" 1100

    $sha = [System.Security.Cryptography.SHA256]::Create()

    try {
        $imageDigest = $sha.ComputeHash($bytes)
    }
    finally {
        $sha.Dispose()
    }

    [UInt64]$seed = 0

    for ($i = 0; $i -lt 6; $i++) {
        $seed = ($seed * 256) + [UInt64]$imageDigest[$i]
    }

    # Project-specific deterministic normalisation.
    [int]$fingerprint = [int]((
        $seed +
        [UInt64]$image.Width +
        [UInt64]$image.Height +
        [UInt64]$bytes.Length +
        [UInt64]3439
    ) % 10000)

    $code = $fingerprint.ToString("D4")

    Spinner "Hashing locker password with SHA-256" 1100

    $codeBytes = [System.Text.Encoding]::UTF8.GetBytes($code)
    $codeSha = [System.Security.Cryptography.SHA256]::Create()

    try {
        $finalDigest = $codeSha.ComputeHash($codeBytes)
    }
    finally {
        $codeSha.Dispose()
    }

    $hex = -join ($finalDigest | ForEach-Object { $_.ToString("x2") })

    $image.Dispose()
    $image = $null

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host "                         RESULT" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "MY PROFESSIONAL LOCKER PASSWORD, HASHED WITH SHA-256:" -ForegroundColor White
    Write-Host ""
    Write-Host $hex -ForegroundColor Green
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Info "The hash above represents the four-digit locker password"
    Write-Info "generated from the selected workplace wallpaper."
    Write-Host ""
}
catch {
    if ($image) {
        $image.Dispose()
    }

    Write-Host ""
    Write-Fail "Fingerprint generation failed."
    Write-Host ""
    Start-Sleep -Seconds 3
    exit 1
}

Read-Host "Press Enter to close"
