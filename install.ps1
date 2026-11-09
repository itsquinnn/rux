# Rux Windows PowerShell Universal Installer
# Run with: irm https://raw.githubusercontent.com/itsquinnn/rux/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "itsquinnn/rux"
$Version = "v1.0.0"
$InstallDir = "$env:USERPROFILE\.rux"
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

if (-not (Test-Path $BinDir)) {
    New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
}
if (-not (Test-Path $LibDir)) {
    New-Item -ItemType Directory -Path $LibDir -Force | Out-Null
}

$ZipName = "rux-$Version-x86_64-pc-windows-msvc.zip"
$DownloadUrl = "https://github.com/$Repo/releases/download/$Version/$ZipName"
$TempZip = "$env:TEMP\$ZipName"
$ExtractTemp = "$env:TEMP\rux_extract"

Write-Host "  Downloading native Windows package from GitHub Releases..." -ForegroundColor Yellow
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempZip -UseBasicParsing
} catch {
    Write-Host "  Retrying download via WebClient..." -ForegroundColor Yellow
    (New-Object System.Net.WebClient).DownloadFile($DownloadUrl, $TempZip)
}

Write-Host "  Extracting package contents..." -ForegroundColor Yellow
Expand-Archive -Path $TempZip -DestinationPath $ExtractTemp -Force

$ExtractedRoot = "$ExtractTemp\rux-$Version-x86_64-pc-windows-msvc"
if (Test-Path "$ExtractedRoot\bin") {
    Copy-Item -Recurse -Force "$ExtractedRoot\bin\*" "$BinDir\"
}
if (Test-Path "$ExtractedRoot\lib") {
    Copy-Item -Recurse -Force "$ExtractedRoot\lib\*" "$LibDir\"
}

Remove-Item -Recurse -Force $ExtractTemp -ErrorAction SilentlyContinue
Remove-Item -Force $TempZip -ErrorAction SilentlyContinue

# Ensure rux.cmd exists for Windows CMD and PowerShell interoperability
$CmdWrapper = "@echo off`r`n`"%~dp0rux.exe`" %*"
Set-Content -Path "$BinDir\rux.cmd" -Value $CmdWrapper -Encoding ASCII -Force

# Update User PATH permanently
$UserPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
if ($UserPath -notlike "*$BinDir*") {
    Write-Host "  Adding $BinDir to User PATH..." -ForegroundColor Cyan
    [Environment]::SetEnvironmentVariable("Path", "$BinDir;$UserPath", [EnvironmentVariableTarget]::User)
}

# Update current session PATH so rux is immediately executable
if ($env:Path -notlike "*$BinDir*") {
    $env:Path = "$BinDir;$env:Path"
}

Write-Host ""
Write-Host "Rux successfully installed!" -ForegroundColor Green
Write-Host ""
Write-Host "Try running:" -ForegroundColor White
Write-Host "  rux --help" -ForegroundColor Cyan
Write-Host "  rux --version" -ForegroundColor Cyan
