# Rux Windows PowerShell Universal Installer
# Run with: irm https://raw.githubusercontent.com/bishwaxyz/ru/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "bishwaxyz/ru"
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

Write-Host "Installing Rux ($Version) for Windows (x86_64)..." -ForegroundColor Green
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

if (Test-Path ".\bin\rux") {
    Write-Host "  Installing from local repository..." -ForegroundColor Yellow
    Copy-Item ".\bin\rux" "$BinDir\rux.exe" -Force
    if (Test-Path ".\lib") {
        Copy-Item -Recurse ".\lib\*" "$LibDir\" -Force
    }
} else {
    Write-Host "  Downloading from GitHub Releases: $DownloadUrl..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempZip
    Expand-Archive -Path $TempZip -DestinationPath $ExtractTemp -Force
    
    $ExtractedRoot = "$ExtractTemp\rux-$Version-x86_64-pc-windows-msvc"
    Copy-Item "$ExtractedRoot\bin\*" "$BinDir\" -Force
    if (Test-Path "$ExtractedRoot\lib") {
        Copy-Item -Recurse "$ExtractedRoot\lib\*" "$LibDir\" -Force
    }
    Remove-Item -Recurse -Force $ExtractTemp -ErrorAction SilentlyContinue
    Remove-Item -Force $TempZip -ErrorAction SilentlyContinue
}

# Update User PATH
$UserPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
if ($UserPath -notlike "*$BinDir*") {
    Write-Host "  Adding $BinDir to User PATH..." -ForegroundColor Cyan
    [Environment]::SetEnvironmentVariable("Path", "$BinDir;$UserPath", [EnvironmentVariableTarget]::User)
    $env:Path = "$BinDir;$env:Path"
}

Write-Host ""
Write-Host "Rux successfully installed!" -ForegroundColor Green
Write-Host "Verify installation by opening a new PowerShell window and running:"
Write-Host "  rux --help" -ForegroundColor White
Write-Host "  rux -e 'println(\"Hello, Rux!\");'" -ForegroundColor White

