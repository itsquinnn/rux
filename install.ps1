# Rux Windows PowerShell Universal Installer
# Run with: irm https://raw.githubusercontent.com/itsquinnn/rux/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "itsquinnn/rux"
$Version = if (-not [string]::IsNullOrWhiteSpace($env:RUX_VERSION)) { $env:RUX_VERSION } else { "latest" }
$InstallDir = if (-not [string]::IsNullOrWhiteSpace($env:RUX_INSTALL)) { $env:RUX_INSTALL } else { "$env:USERPROFILE\.rux" }

$BinDir = "$InstallDir\bin"
$LibDir = "$InstallDir\lib"

Write-Host @"
  ____            
 |  _ \ _   ___  __
 | |_) | | | \ \/ /
 |  _ <| |_| |>  < 
 |_| \_\\__,_/_/\_\
 The Sovereign Systems Programming Language
"@ -ForegroundColor Cyan

Write-Host "Installing Rux ($Version) on Windows (x86_64)..." -ForegroundColor Green
Write-Host "  Destination: $InstallDir"

New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
New-Item -ItemType Directory -Path $LibDir -Force | Out-Null

$Target = "x86_64-pc-windows-msvc"
if ($Version -eq "latest") {
    $ZipName = "rux-$Target.zip"
    $DownloadUrl = "https://github.com/$Repo/releases/latest/download/$ZipName"
} else {
    $ZipName = "rux-$Version-$Target.zip"
    $DownloadUrl = "https://github.com/$Repo/releases/download/$Version/$ZipName"
}

$TempZip = Join-Path $env:TEMP "rux_download_$PID.zip"
$ExtractTemp = Join-Path $env:TEMP "rux_extract_$PID"

if (Test-Path ".\bin\rux.exe") {
    Write-Host "  Installing from local repository checkout..." -ForegroundColor Yellow
    Copy-Item -Force ".\bin\rux.exe" "$BinDir\rux.exe"
    if (Test-Path ".\bin\ruxc.exe") {
        Copy-Item -Force ".\bin\ruxc.exe" "$BinDir\ruxc.exe"
    }
    if (Test-Path ".\lib") {
        Copy-Item -Recurse -Force ".\lib\*" "$LibDir\"
    }
} elseif (Test-Path ".\dist\$ZipName") {
    Write-Host "  Installing from local dist package .\dist\$ZipName..." -ForegroundColor Yellow
    if (Test-Path $ExtractTemp) { Remove-Item -Recurse -Force $ExtractTemp }
    Expand-Archive -Path ".\dist\$ZipName" -DestinationPath $ExtractTemp -Force
    $ExtractedRoot = (Get-ChildItem -Path $ExtractTemp -Directory | Select-Object -First 1).FullName
    if (Test-Path "$ExtractedRoot\bin") {
        Copy-Item -Recurse -Force "$ExtractedRoot\bin\*" "$BinDir\"
    }
    if (Test-Path "$ExtractedRoot\lib") {
        Copy-Item -Recurse -Force "$ExtractedRoot\lib\*" "$LibDir\"
    }
    Remove-Item -Recurse -Force $ExtractTemp -ErrorAction SilentlyContinue
} else {
    Write-Host "  Downloading native Windows package from GitHub Releases..." -ForegroundColor Yellow
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 12288
        } catch {}
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempZip -UseBasicParsing
    } catch {
        Write-Host "  Retrying download via WebClient..." -ForegroundColor Yellow
        (New-Object System.Net.WebClient).DownloadFile($DownloadUrl, $TempZip)
    }

    Write-Host "  Extracting package contents..." -ForegroundColor Yellow
    if (Test-Path $ExtractTemp) { Remove-Item -Recurse -Force $ExtractTemp }
    Expand-Archive -Path $TempZip -DestinationPath $ExtractTemp -Force

    $ExtractedRoot = (Get-ChildItem -Path $ExtractTemp -Directory | Select-Object -First 1).FullName
    if (-not $ExtractedRoot -or -not (Test-Path "$ExtractedRoot\bin\rux.exe")) {
        throw "Downloaded archive did not contain bin\rux.exe"
    }
    Copy-Item -Recurse -Force "$ExtractedRoot\bin\*" "$BinDir\"
    if (Test-Path "$ExtractedRoot\lib") {
        Copy-Item -Recurse -Force "$ExtractedRoot\lib\*" "$LibDir\"
    }

    Remove-Item -Recurse -Force $ExtractTemp -ErrorAction SilentlyContinue
    Remove-Item -Force $TempZip -ErrorAction SilentlyContinue
}

# Ensure rux.cmd exists for Windows CMD and PowerShell interoperability
$CmdWrapper = "@echo off`r`n`"%~dp0rux.exe`" %*"
Set-Content -Path "$BinDir\rux.cmd" -Value $CmdWrapper -Encoding ASCII -Force

# Remove NTFS Zone.Identifier ADS without mutating PE / EIA sealed binary bytes
Write-Host "  Unblocking downloaded binaries..." -ForegroundColor Yellow
try {
    Get-ChildItem -Path $InstallDir -Recurse | Unblock-File -ErrorAction SilentlyContinue
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        Add-MpPreference -ExclusionPath "$InstallDir" -ErrorAction SilentlyContinue
    }
    Write-Host "  Binaries unblocked!" -ForegroundColor Green
} catch {
    Write-Host "  Note: $($_.Exception.Message)" -ForegroundColor Gray
}

# Update User PATH permanently
$UserPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
if (-not $UserPath) { $UserPath = "" }
if ($UserPath -notlike "*$BinDir*") {
    Write-Host "  Adding $BinDir to User PATH..." -ForegroundColor Cyan
    if ([string]::IsNullOrWhiteSpace($UserPath)) {
        [Environment]::SetEnvironmentVariable("Path", "$BinDir", [EnvironmentVariableTarget]::User)
    } else {
        [Environment]::SetEnvironmentVariable("Path", "$BinDir;$UserPath", [EnvironmentVariableTarget]::User)
    }
}

# Update current session PATH so rux is immediately executable
if ($env:Path -notlike "*$BinDir*") {
    $env:Path = "$BinDir;$env:Path"
}

# Verify binary execution and EIA integrity
Write-Host "  Verifying installed binary..." -ForegroundColor Yellow
$RuxVer = & "$BinDir\rux.exe" --version
& "$BinDir\rux.exe" eia-check "$BinDir\rux.exe" | Out-Null

Write-Host ""
Write-Host "Rux successfully installed and verified! ($RuxVer)" -ForegroundColor Green
Write-Host ""
Write-Host "Run now:" -ForegroundColor White
Write-Host "  rux --version" -ForegroundColor Cyan
Write-Host "  rux -e 'println(""Hello, Rux!"");'" -ForegroundColor Cyan
