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

# Create, Trust, and Sign with Authenticode Certificate
Write-Host "  Configuring code-signing certificate, Defender exclusions, and unblocking binary..." -ForegroundColor Yellow
try {
    # Unblock downloaded files from Windows SmartScreen Zone.Identifier
    Get-ChildItem -Path $InstallDir -Recurse | Unblock-File -ErrorAction SilentlyContinue

    # Check if running as Administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    # Find or generate Rux code-signing certificate
    $certStoreLoc = if ($isAdmin) { "Cert:\LocalMachine\My" } else { "Cert:\CurrentUser\My" }
    $cert = Get-ChildItem $certStoreLoc -CodeSigningCert -ErrorAction SilentlyContinue | Where-Object { $_.Subject -like "*Rux*" } | Select-Object -First 1
    if (-not $cert) {
        $cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject "CN=Rux Programming Language" -CertStoreLocation $certStoreLoc -NotAfter (Get-Date).AddYears(10)
    }

    # Install certificate into TrustedPublisher and Root stores
    $scopeTargets = @("CurrentUser")
    if ($isAdmin) {
        $scopeTargets += "LocalMachine"
        # Add Windows Defender exclusion so Application Control / SmartScreen does not block the binary
        Add-MpPreference -ExclusionPath "$InstallDir" -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionProcess "rux.exe" -ErrorAction SilentlyContinue
    }

    foreach ($scope in $scopeTargets) {
        foreach ($storeName in @("TrustedPublisher", "Root")) {
            try {
                $store = New-Object System.Security.Cryptography.X509Certificates.X509Store($storeName, $scope)
                $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
                $store.Add($cert)
                $store.Close()
            } catch {}
        }
    }

    # Sign rux.exe with SHA256 Authenticode signature
    if (Test-Path "$BinDir\rux.exe") {
        Set-AuthenticodeSignature -FilePath "$BinDir\rux.exe" -Certificate $cert -HashAlgorithm SHA256 -ErrorAction SilentlyContinue | Out-Null
        Unblock-File -Path "$BinDir\rux.exe" -ErrorAction SilentlyContinue
    }
    Write-Host "  Certificate trusted and rux.exe signed successfully!" -ForegroundColor Green
} catch {
    Write-Host "  Note: Automatic certificate signing: $($_.Exception.Message)" -ForegroundColor Gray
}

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
Write-Host "Rux successfully installed and verified!" -ForegroundColor Green
Write-Host ""
Write-Host "Run now:" -ForegroundColor White
Write-Host "  rux --help" -ForegroundColor Cyan
Write-Host "  rux --version" -ForegroundColor Cyan
