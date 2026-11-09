# Rux Windows PowerShell Universal Installer
# Run with: irm https://raw.githubusercontent.com/itsquinnn/rux/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host @"
  ____            
 |  _ \ _   ___  __
 | |_) | | | \ \/ /
 |  _ <| |_| |>  < 
 |_| \_\\__,_/_/\_\
 The Sovereign Systems Programming Language
"@ -ForegroundColor Cyan

Write-Host "Rux is a freestanding systems compiler built with direct-syscall zero-libc architecture." -ForegroundColor White
Write-Host "On Windows, Rux runs natively with maximum performance inside WSL2 (Windows Subsystem for Linux)." -ForegroundColor Green
Write-Host ""

$wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue

if ($wsl) {
    Write-Host "WSL detected on your system!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To install and use Rux, open your terminal and run:" -ForegroundColor Yellow
    Write-Host "  wsl" -ForegroundColor White
    Write-Host "  curl -fsSL https://raw.githubusercontent.com/itsquinnn/rux/main/install.sh | bash" -ForegroundColor Cyan
    Write-Host "  rux --help" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "WSL is not yet installed on this machine." -ForegroundColor Yellow
    Write-Host "To enable WSL2 on Windows, open an Administrator PowerShell and run:" -ForegroundColor White
    Write-Host "  wsl --install" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "After restarting, run:" -ForegroundColor White
    Write-Host "  wsl" -ForegroundColor White
    Write-Host "  curl -fsSL https://raw.githubusercontent.com/itsquinnn/rux/main/install.sh | bash" -ForegroundColor Cyan
}
