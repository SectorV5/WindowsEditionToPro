[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, HelpMessage = "Specify the ISO language (e.g., en-US). Use 'List' to see all options.")]
    [string]$Language = (Get-Culture).Name
)

function Show-Progress {
    param (
        [string]$Activity,
        [int]$Percent
    )
    Write-Progress -Activity $Activity -Status "$Percent% Complete" -PercentComplete $Percent
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$logFile = "$env:USERPROFILE\Desktop\Win11_Conversion.log"
Start-Transcript -Path $logFile -Force

try {
    Write-Host "▶️ Starting Windows to Pro Conversion Script..." -ForegroundColor Cyan

    # Check if running as administrator
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Script must be run as an Administrator. Please restart PowerShell with 'Run as Administrator'."
    }

    # Check disk space
    $systemDrive = $env:SystemDrive.TrimEnd(':')
    $freeGB = (Get-Volume -DriveLetter $systemDrive).SizeRemaining / 1GB
    if ($freeGB -lt 25) {
        throw "Insufficient disk space. At least 25 GB of free space is required on the $systemDrive`: drive."
    }
    Write-Host "✅ Prereqs OK: Running as Admin with $([math]::Round($freeGB, 1)) GB free on $systemDrive`:" -ForegroundColor Green

    # ISO handling
    $isoPath = $null
    $tempIsoPath = Join-Path $env:TEMP "Win11.iso"
    $localIsoDir = Join-Path $env:SystemDrive "Win11_ISO"
    $userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"

    Write-Host "🔎 Searching for existing Windows 11 ISO..." -ForegroundColor Cyan
    Show-Progress -Activity "Checking for existing ISO" -Percent 10
    if (Test-Path $tempIsoPath) {
        $isoPath = $tempIsoPath
        Write-Host "✅ Found ISO at '$isoPath'" -ForegroundColor Green
    }
    elseif (Test-Path $localIsoDir) {
        $isoFile = Get-ChildItem -Path $localIsoDir -Filter "*.iso" -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($isoFile) {
            $isoPath = $isoFile.FullName
            Write-Host "✅ Found ISO at '$isoPath'" -ForegroundColor Green
        }
    }

    if (-not $isoPath) {
        Write-Host "ℹ️ No local ISO found. Attempting to download from Microsoft..." -ForegroundColor Cyan
        Show-Progress -Activity "Downloading ISO" -Percent 20
        $fidoScriptPath = Join-Path $env:TEMP "Fido.ps1"
        try {
            Write-Host "  - Downloading Fido script from GitHub..."
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/pbatard/Fido/master/Fido.ps1" -OutFile $fidoScriptPath -UseBasicParsing -ErrorAction Stop -UserAgent $userAgent
        }
        catch {
            throw "Failed to download the Fido helper script. Please check your internet connection or firewall settings."
        }

        if ($Language -eq 'List') {
            Write-Host "📋 Available languages from Microsoft:" -ForegroundColor Cyan
            & $fidoScriptPath -Product Windows -Version 11 -Arch x64 -Lang List
            throw "Language list displayed. Please re-run the script with a specific language using the -Language parameter."
        }

        Write-Host "  - Using Fido to get download URL for Windows 11 (Language: $Language)..."
        $isoUrl = & $fidoScriptPath -Product Windows -Version 11 -Arch x64 -Lang $Language -Destination $env:TEMP -GetUrl -ErrorAction Stop

        if ($isoUrl -and ($isoUrl -match '^https?://')) {
            Write-Host "  - URL obtained successfully. Starting download (this may take a while)..."
            Invoke-WebRequest -Uri $isoUrl -OutFile $tempIsoPath -UseBasicParsing -UserAgent $userAgent
            $isoPath = $tempIsoPath
            Write-Host "✅ ISO downloaded successfully to '$isoPath'" -ForegroundColor Green
        }
        else {
            throw "Fido script did not return a valid download URL."
        }
    }

    # Mount ISO
    Write-Host "💿 Mounting ISO image..." -ForegroundColor Cyan
    Show-Progress -Activity "Mounting ISO" -Percent 30
    $mount = Mount-DiskImage -ImagePath $isoPath -PassThru -ErrorAction Stop

    $isoVolume = $null
    $timeout = 15
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    while ($timer.Elapsed.TotalSeconds -lt $timeout) {
        $isoVolume = Get-DiskImage -ImagePath $isoPath | Get-Volume
        if ($isoVolume.DriveLetter) { break }
        Start-Sleep -Seconds 1
    }
    $timer.Stop()

    if (-not $isoVolume.DriveLetter) {
        Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
        throw "Failed to mount the ISO or retrieve its drive letter in time."
    }
    $isoDrive = "$($isoVolume.DriveLetter):"
    Write-Host "✅ ISO mounted successfully at drive $isoDrive" -ForegroundColor Green

    # Extract ISO contents
    $extractDir = Join-Path $env:SystemDrive "Win11_Work"
    Write-Host "📦 Extracting ISO contents to '$extractDir'..." -ForegroundColor Cyan
    Show-Progress -Activity "Extracting ISO" -Percent 40
    if (Test-Path $extractDir) {
        Write-Host "  - Removing old working directory..."
        Remove-Item -Path $extractDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Path $extractDir | Out-Null
    Copy-Item -Path "$isoDrive\*" -Destination $extractDir -Recurse -Force -ErrorAction Stop

    Write-Host "  - Unmounting ISO..."
    Dismount-DiskImage -ImagePath $isoPath

    # Inject configuration files
    Write-Host "⚙️ Injecting edition configuration files..." -ForegroundColor Cyan
    Show-Progress -Activity "Injecting config" -Percent 50
    $sourcesDir = Join-Path $extractDir "sources"

    @"
[PID]
Value=VK7JG-NPHTM-C97JM-9MPGT-3V66T
"@ | Out-File -FilePath (Join-Path $sourcesDir "PID.txt") -Encoding ASCII

    @"
[EditionID]
Professional
[Channel]
Retail
[VL]
0
"@ | Out-File -FilePath (Join-Path $sourcesDir "ei.cfg") -Encoding ASCII
    Write-Host "✅ Configuration injected successfully." -ForegroundColor Green

    # Launch Windows Setup
    $setupPath = Join-Path $extractDir "setup.exe"
    if (-not (Test-Path $setupPath)) {
        throw "Could not find setup.exe in the extracted directory. The ISO may be corrupt."
    }

    Write-Host "🚀 Launching Windows Setup for in-place upgrade..." -ForegroundColor Cyan
    Show-Progress -Activity "Launching Setup" -Percent 90
    Write-Host "   The setup process will now begin. Please wait while Windows 11 is installed."
    Write-Host "   Your PC will restart automatically when the installation is complete."
    Start-Process -FilePath $setupPath -ArgumentList "/auto upgrade /eula accept" -Wait

    # Final message (may not be seen due to reboot)
    Write-Host "✅ In-place upgrade has been initiated. Your PC will restart soon to complete the installation." -ForegroundColor Green
    Show-Progress -Activity "Done" -Percent 100

}
catch {
    Write-Warning "An error occurred: $($_.Exception.Message)"
    if ($_.Exception.Message -like "*download*") {
        Write-Host "`nPlease manually download a Windows 11 Pro ISO and place it in one of these locations:"
        Write-Host "  - Official Microsoft Link: https://www.microsoft.com/software-download/windows11"
        Write-Host "  - Alternative Source Info: https://massgrave.dev/genuine-installation-media"
        Write-Host "Then place the downloaded ISO file at '$tempIsoPath' or in the folder 'C:\Win11_ISO\' and run this script again."
    }
    exit 1
}
finally {
    Write-Host "▶️ Stopping transcript..." -ForegroundColor Cyan
    Stop-Transcript
}
