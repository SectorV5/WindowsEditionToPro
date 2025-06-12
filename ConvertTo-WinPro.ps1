[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, HelpMessage = "Specify the ISO language (e.g., en-US). Use 'List' to see all options.")]
    [string]$Language = (Get-Culture).Name
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$logFile = "$env:USERPROFILE\Desktop\Win11_Conversion.log"
Start-Transcript -Path $logFile -Force

function Show-Progress {
    param (
        [string]$Activity,
        [int]$Percent
    )
    Write-Progress -Activity $Activity -PercentComplete $Percent
}

try {
    Write-Host "▶️ Starting Windows to Pro Conversion Script..." -ForegroundColor Cyan

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Script must be run as an Administrator."
    }

    $systemDrive = $env:SystemDrive.TrimEnd(':')
    $freeGB = (Get-Volume -DriveLetter $systemDrive).SizeRemaining / 1GB
    if ($freeGB -lt 25) {
        throw "Insufficient disk space."
    }
    Write-Host "✅ Prereqs OK: Running as Admin with $([math]::Round($freeGB, 1)) GB free on $systemDrive`:" -ForegroundColor Green

    $isoPath = $null
    $tempIsoPath = Join-Path $env:TEMP "Win11.iso"
    $localIsoDir = Join-Path $env:SystemDrive "Win11_ISO"
    $userAgent = "Mozilla/5.0"

    Show-Progress -Activity "Checking for ISO..." -Percent 5
    if (Test-Path $tempIsoPath) {
        $isoPath = $tempIsoPath
    }
    elseif (Test-Path $localIsoDir) {
        $isoFile = Get-ChildItem -Path $localIsoDir -Filter "*.iso" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($isoFile) { $isoPath = $isoFile.FullName }
    }

    if (-not $isoPath) {
        throw "ISO not found. Download manually or provide valid path."
    }

    Show-Progress -Activity "Mounting ISO..." -Percent 15
    $mount = Mount-DiskImage -ImagePath $isoPath -PassThru
    $isoVolume = $null
    $timeout = 15
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    while ($timer.Elapsed.TotalSeconds -lt $timeout) {
        $isoVolume = Get-DiskImage -ImagePath $isoPath | Get-Volume
        if ($isoVolume.DriveLetter) { break }
        Start-Sleep -Seconds 1
    }

    if (-not $isoVolume.DriveLetter) {
        Dismount-DiskImage -ImagePath $isoPath
        throw "Failed to mount ISO."
    }
    $isoDrive = "$($isoVolume.DriveLetter):"

    Show-Progress -Activity "Extracting ISO..." -Percent 30
    $extractDir = Join-Path $env:SystemDrive "Win11_Work"
    if (Test-Path $extractDir) { Remove-Item -Path $extractDir -Recurse -Force }
    New-Item -ItemType Directory -Path $extractDir | Out-Null
    Copy-Item -Path "$isoDrive\*" -Destination $extractDir -Recurse -Force

    Dismount-DiskImage -ImagePath $isoPath

    Show-Progress -Activity "Injecting config files..." -Percent 60
    $sourcesDir = Join-Path $extractDir "sources"
    "[PID]
Value=VK7JG-NPHTM-C97JM-9MPGT-3V66T" | Out-File (Join-Path $sourcesDir "PID.txt")
    "[EditionID]
Professional
[Channel]
Retail
[VL]
0" | Out-File (Join-Path $sourcesDir "ei.cfg")

    $setupPath = Join-Path $extractDir "setup.exe"
    if (-not (Test-Path $setupPath)) {
        throw "setup.exe not found."
    }

    Show-Progress -Activity "Launching Setup..." -Percent 90

    # Launch setup.exe interactively (no quiet, no noreboot)
    Start-Process -FilePath $setupPath -ArgumentList "/auto upgrade /eula accept"

    Show-Progress -Activity "Upgrade launched." -Percent 100
    Write-Host "✅ Upgrade process launched. You should see the Windows Setup GUI now." -ForegroundColor Green
}
catch {
    Write-Warning "Error: $($_.Exception.Message)"
}
finally {
    Write-Host "▶️ Stopping transcript..." -ForegroundColor Cyan
    Stop-Transcript
}
