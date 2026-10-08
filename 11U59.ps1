# Auto-Elevate to Administrator
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);
if (-not $IsAdmin) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"& { $([scriptblock]::Create($MyInvocation.MyCommand.Definition)) }`"" -Verb RunAs;
    Exit;
}

# Set Background to Black
$Host.UI.RawUI.BackgroundColor = "Black";
Clear-Host;

# Force Window Size
try {
    $Width = 62;
    $Height = 46;
    $Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size($Width, 9999);
    $Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size($Width, $Height);
} catch {}
Write-Host "$([char]27)[8;46;62t";

function Get-WelcomeName {
    $RegisteredUser = $null;
    try {
        $RegisteredUser = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).RegisteredUser;
    } catch {}

    if ($RegisteredUser -and $RegisteredUser.Trim() -ne "" -and $RegisteredUser -notmatch "^(Windows User|User|Owner)$") {
        return $RegisteredUser.Trim();
    }

    if ($env:USERNAME -and $env:USERNAME.Trim() -ne "") {
        return $env:USERNAME.Trim();
    }

    return "User";
}

function Show-WelcomeBanner {
    $Name = Get-WelcomeName;
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "              === Izzeldeen Dradkh ===             " -ForegroundColor Gray;
    Write-Host "              SYSTEM MAINTENANCE SUITE              " -ForegroundColor Gray;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "";
    Write-Host "   Welcome, $env:COMPUTERNAME" -ForegroundColor Cyan;
    Write-Host "";
    Write-Host "---------------------------------------------------" -ForegroundColor Gray;
    Start-Sleep -Seconds 2;
}

function Invoke-UniversalClean {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        QuantumClean Deep-Purge                    " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;

    $KnownTargets = @(
        "$env:TEMP", "$env:SystemRoot\Temp", "$env:SystemRoot\Prefetch",
        "$env:LocalAppData\Google\Chrome\User Data\*\Cache",
        "$env:LocalAppData\Microsoft\Edge\User Data\*\Cache",
        "$env:LocalAppData\BraveSoftware\Brave-Browser\User Data\*\Cache",
        "$env:AppData\Mozilla\Firefox\Profiles\*\cache2",
        "$env:AppData\Adobe\Common\Media Cache Files",
        "$env:LocalAppData\Adobe\DXMediaCache", "$env:LocalAppData\CapCut\User Data\Cache",
        "$env:LocalAppData\Steam\htmlcache", "$env:LocalAppData\EpicGamesLauncher\Saved\Webcache",
        "$env:LocalAppData\NVIDIA\DXCache", "$env:LocalAppData\AMD\DxCache", "$env:LocalAppData\D3DSCache"
    );

    Write-Host "[1/3] Scanning system for known and unknown app caches..." -ForegroundColor Gray;
    $DiscoveredPaths = [System.Collections.Generic.List[string]]::new();

    foreach ( $Target in $KnownTargets ) {
        $Resolved = Resolve-Path -Path $Target -ErrorAction SilentlyContinue;
        if ($Resolved) {
            foreach ( $Res in $Resolved ) {
                $DiscoveredPaths.Add($Res.Path);
            }
        }
    }

    $SearchRoots = @($env:LocalAppData, $env:AppData);
    foreach ( $Root in $SearchRoots ) {
        if (Test-Path $Root) {
            $GenericCaches = Get-ChildItem -Path $Root -Recurse -Depth 3 -Directory -Filter "*Cache*" -ErrorAction SilentlyContinue;
            foreach ( $Folder in $GenericCaches ) {
                if ($Folder.FullName -notmatch "Microsoft\\Windows") {
                    if (-not $DiscoveredPaths.Contains($Folder.FullName)) {
                        $DiscoveredPaths.Add($Folder.FullName);
                    }
                }
            }
        }
    }

    Write-Host "    [+] Discovered $($DiscoveredPaths.Count) total cache locations.`n" -ForegroundColor Green;

    Write-Host "[2/3] Executing High-Speed Purge with Live Timer..." -ForegroundColor Gray;
    $PurgeBlock = [scriptblock]::Create("
        param(`$Targets);
        foreach ( `$t in `$Targets ) { [void](Remove-Item -Path `"`$t`*`" -Recurse -Force -ErrorAction SilentlyContinue); };
    ");

    $Job = Start-Job -ScriptBlock $PurgeBlock -ArgumentList (,$DiscoveredPaths);
    $StageSw = [System.Diagnostics.Stopwatch]::StartNew();

    while ($Job.State -eq "Running") {
        $Elapsed = $StageSw.Elapsed;
        $TimeString = "{0:D2}:{1:D2}:{2:D2}" -f $Elapsed.Hours, $Elapsed.Minutes, $Elapsed.Seconds;
        Write-Host "`r    -> Purging... Active Time: $TimeString" -NoNewline -ForegroundColor Gray;
        Start-Sleep -Seconds 1;
    }

    $StageSw.Stop();
    $FinalElapsed = "{0:D2}:{1:D2}:{2:D2}" -f $StageSw.Elapsed.Hours, $StageSw.Elapsed.Minutes, $StageSw.Elapsed.Seconds;
    Write-Host "`r    [+] Deep Purge Completed in: $FinalElapsed                    " -ForegroundColor Green;
    Remove-Job $Job;

    Write-Host "`n[3/3] Flushing DNS Cache..." -ForegroundColor Gray;
    Clear-DnsClientCache;
    Write-Host "    [+] DNS Cache Cleared.`n" -ForegroundColor Green;
    Start-Sleep -Seconds 3;
}

function Invoke-PerformanceOptimization {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        NexusPrime Core-Optimizer                  " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;

    $Stages = @(
        @{ Name = "[1/5] Flushing DNS & Resetting Network"; Script = { [void](ipconfig /flushdns); [void](netsh winsock reset); } },
        @{ Name = "[2/5] Repairing System Files (DISM & SFC)"; Script = { [void](DISM.exe /Online /Cleanup-Image /RestoreHealth /LimitAccess); [void](sfc /scannow); } },
        @{ Name = "[3/5] Cleaning Component Store (WinSxS)"; Script = { [void](DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase); } },
        @{ Name = "[4/5] Optimizing Storage Drives"; Script = { [void](defrag /C /O); } },
        @{ Name = "[5/5] Rebuilding Search Index Cache"; Script = { Stop-Service "Windows Search" -Force -ErrorAction SilentlyContinue; [void](Remove-Item "$env:ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb" -Force -ErrorAction SilentlyContinue); Start-Service "Windows Search" -ErrorAction SilentlyContinue; } }
    );

    $TotalSw = [System.Diagnostics.Stopwatch]::StartNew();

    foreach ( $Stage in $Stages ) {
        Write-Host "$($Stage.Name)..." -ForegroundColor Gray;

        $Job = Start-Job -ScriptBlock $Stage.Script;
        $StageSw = [System.Diagnostics.Stopwatch]::StartNew();

        while ($Job.State -eq "Running") {
            $Elapsed = $StageSw.Elapsed;
            $TimeString = "{0:D2}:{1:D2}:{2:D2}" -f $Elapsed.Hours, $Elapsed.Minutes, $Elapsed.Seconds;
            Write-Host "`r    -> Running time: $TimeString" -NoNewline -ForegroundColor Gray;
            Start-Sleep -Seconds 1;
        }

        $StageSw.Stop();
        $FinalElapsed = "{0:D2}:{1:D2}:{2:D2}" -f $StageSw.Elapsed.Hours, $StageSw.Elapsed.Minutes, $StageSw.Elapsed.Seconds;
        Write-Host "`r    [+] Finished in: $FinalElapsed                    " -ForegroundColor Green;
        Remove-Job $Job;
        Write-Host "";
    }

    $TotalSw.Stop();
    $TotalElapsed = "{0:D2}:{1:D2}:{2:D2}" -f $TotalSw.Elapsed.Hours, $TotalSw.Elapsed.Minutes, $TotalSw.Elapsed.Seconds;
    Write-Host "---------------------------------------------------" -ForegroundColor Gray;
    Write-Host "Done! Total Optimization Time: $TotalElapsed" -ForegroundColor Gray;
    Start-Sleep -Seconds 3;
}

# Hardware Dashboard (full specs + real health metrics)
function Invoke-HardwareDashboard {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        AetherHealth Hardware Dashboard             " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;

    # 1. CPU
    $cpus = Get-CimInstance Win32_Processor;
    $cpuTotal = 0;
    foreach ( $c in $cpus ) { $cpuTotal += $c.LoadPercentage; }
    $cpuLoad = if ($cpus.Count -gt 0) { [math]::Round($cpuTotal / $cpus.Count, 1); } else { 0; };

    Write-Host " [CPU]" -ForegroundColor Cyan;
    foreach ( $c in $cpus ) {
        Write-Host "   -> Model        : $($c.Name.Trim())" -ForegroundColor DarkGray;
        Write-Host "   -> Cores/Threads: $($c.NumberOfCores) cores / $($c.NumberOfLogicalProcessors) threads" -ForegroundColor DarkGray;
        Write-Host "   -> Max Clock    : $($c.MaxClockSpeed) MHz" -ForegroundColor DarkGray;
    }
    Write-Host "   -> Current Load : ${cpuLoad}% (this is usage, not a wear/health metric  CPUs have no meaningful 'health %')`n" -ForegroundColor Green;

    # 2. RAM
    $os = Get-CimInstance Win32_OperatingSystem;
    $totalRamGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2);
    $freeRamGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2);
    $usedRamGB = $totalRamGB - $freeRamGB;
    $ramUsagePercent = [math]::Round(($usedRamGB / $totalRamGB) * 100, 1);
    $ramModules = Get-CimInstance Win32_PhysicalMemory;

    Write-Host " [MEMORY (RAM)]" -ForegroundColor Cyan;
    $slotIndex = 1;
    foreach ( $mod in $ramModules ) {
        $modGB = [math]::Round($mod.Capacity / 1GB, 1);
        Write-Host "   -> Stick $slotIndex       : $modGB GB @ $($mod.Speed) MHz ($($mod.Manufacturer))" -ForegroundColor DarkGray;
        $slotIndex++;
    }
    Write-Host "   -> Usage        : $usedRamGB GB / $totalRamGB GB (${ramUsagePercent}%)`n" -ForegroundColor Green;

    # 3. Storage  split into physical drive HEALTH and logical volume FREE SPACE (these are not the same thing)
    Write-Host " [STORAGE - PHYSICAL DRIVES]" -ForegroundColor Cyan;
    $physicalDisks = Get-PhysicalDisk -ErrorAction SilentlyContinue;
    if ($physicalDisks) {
        foreach ( $pd in $physicalDisks ) {
            $sizeGB = [math]::Round($pd.Size / 1GB, 1);
            $mediaType = $pd.MediaType;
            $healthStatus = $pd.HealthStatus;
            $wearInfo = "N/A";
            try {
                $counter = Get-StorageReliabilityCounter -PhysicalDisk $pd -ErrorAction SilentlyContinue;
                if ($counter -and $counter.Wear -ne $null) {
                    $wearInfo = "$($counter.Wear)% used (lower is better)";
                }
            } catch {}
            Write-Host "   -> $($pd.FriendlyName)" -ForegroundColor DarkGray;
            Write-Host "      Type       : $mediaType | Capacity: $sizeGB GB" -ForegroundColor DarkGray;
            Write-Host "      SMART/Health: $healthStatus | Wear: $wearInfo" -ForegroundColor Green;
        }
    } else {
        Write-Host "   -> Get-PhysicalDisk unavailable on this system." -ForegroundColor DarkGray;
    }

    Write-Host "`n [STORAGE - VOLUME FREE SPACE]" -ForegroundColor Cyan;
    Write-Host "   (Free space % is NOT drive health  a full but healthy drive shows low free space here)" -ForegroundColor DarkGray;
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3";
    foreach ( $disk in $disks ) {
        $sizeGB = [math]::Round($disk.Size / 1GB, 1);
        $freeGB = [math]::Round($disk.FreeSpace / 1GB, 1);
        $usedPct = if ($disk.Size -gt 0) { [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 1); } else { 0; };
        Write-Host "   -> Drive $($disk.DeviceID)  : Free $freeGB GB of $sizeGB GB ($usedPct% used)" -ForegroundColor DarkGray;
    }
    Write-Host "";

    # 4. GPU
    Write-Host " [GPU]" -ForegroundColor Cyan;
    $gpus = Get-CimInstance Win32_VideoController;
    foreach ( $gpu in $gpus ) {
        $vramGB = if ($gpu.AdapterRAM -gt 0) { [math]::Round($gpu.AdapterRAM / 1GB, 2); } else { "Unknown"; };
        Write-Host "   -> $($gpu.Name)" -ForegroundColor DarkGray;
        Write-Host "      VRAM       : $vramGB GB | Driver: $($gpu.DriverVersion) ($($gpu.DriverDate))" -ForegroundColor DarkGray;
        Write-Host "      Resolution : $($gpu.CurrentHorizontalResolution)x$($gpu.CurrentVerticalResolution) @ $($gpu.CurrentRefreshRate)Hz" -ForegroundColor Green;
    }
    Write-Host "";

    # 5. Battery
    $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue;
    Write-Host " [BATTERY]" -ForegroundColor Cyan;
    if ($battery) {
        $fullCharge = $battery.FullChargedCapacity;
        $designCap = $battery.DesignCapacity;
        $batteryHealth = "Unknown";
        if ($fullCharge -and $designCap -and $designCap -gt 0) {
            $batteryHealth = [math]::Min(100, [math]::Round(($fullCharge / $designCap) * 100, 1));
        }
        Write-Host "   -> Design Capacity : $designCap mWh" -ForegroundColor DarkGray;
        Write-Host "   -> Full Charge Cap : $fullCharge mWh" -ForegroundColor DarkGray;
        Write-Host "   -> Wear Health     : ${batteryHealth}% of original design capacity`n" -ForegroundColor Green;
    } else {
        Write-Host "   -> Desktop PC / No Battery Detected`n" -ForegroundColor DarkGray;
    }

    Write-Host "---------------------------------------------------" -ForegroundColor Gray;
    Write-Host " Press any key to return to menu..." -ForegroundColor Gray;
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
}

# Device Timeline (creation date / first sign-in estimates)
function Invoke-DeviceTimeline {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        AetherOrigin Device Timeline                " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;
    Write-Host "   None of these is a single 'true' answer  each measures" -ForegroundColor DarkGray;
    Write-Host "   something different, and reimaging/resets can reset them." -ForegroundColor DarkGray;
    Write-Host "";

    # 1. OS Install Date
    Write-Host " [OS INSTALL DATE]" -ForegroundColor Cyan;
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop;
        $installDate = $os.InstallDate;
        Write-Host "   -> $installDate" -ForegroundColor Green;
        Write-Host "      (When this copy of Windows was installed/imaged  not" -ForegroundColor DarkGray;
        Write-Host "       necessarily when you first used the device.)`n" -ForegroundColor DarkGray;
    } catch {
        Write-Host "   -> Unable to retrieve.`n" -ForegroundColor DarkRed;
    }

    # 2. OOBE / First Boot Completion
    Write-Host " [FIRST BOOT / OOBE COMPLETION]" -ForegroundColor Cyan;
    try {
        $OobeKey = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OOBE" -Name InstallTime -ErrorAction Stop;
        $FileTime = $OobeKey.InstallTime;
        $HighPart = [BitConverter]::ToInt64($FileTime, 0);
        $OobeDate = [DateTime]::FromFileTimeUtc($HighPart);
        Write-Host "   -> $OobeDate (UTC)" -ForegroundColor Green;
        Write-Host "      (When the initial out-of-box setup finished  often close" -ForegroundColor DarkGray;
        Write-Host "       to the real 'first power-on' moment.)`n" -ForegroundColor DarkGray;
    } catch {
        Write-Host "   -> Not available on this system/Windows build.`n" -ForegroundColor DarkRed;
    }

    # 3. First User Sign-In (profile folder creation)
    Write-Host " [USER PROFILE CREATION (sign-in proxy)]" -ForegroundColor Cyan;
    try {
        $Profiles = Get-ChildItem "$env:SystemDrive\Users" -Directory -ErrorAction Stop |
            Where-Object { $_.Name -notmatch "^(Public|Default.*|All Users)$" };
        foreach ( $p in $Profiles ) {
            Write-Host "   -> $($p.Name)  : $($p.CreationTime)" -ForegroundColor Green;
        }
        Write-Host "      (Approximates when each account first signed in  resets" -ForegroundColor DarkGray;
        Write-Host "       if the profile was ever deleted/recreated.)`n" -ForegroundColor DarkGray;
    } catch {
        Write-Host "   -> Unable to retrieve.`n" -ForegroundColor DarkRed;
    }

    # 4. BIOS / Hardware Manufacture Info
    Write-Host " [BIOS / HARDWARE INFO]" -ForegroundColor Cyan;
    try {
        $bios = Get-CimInstance Win32_BIOS -ErrorAction Stop;
        Write-Host "   -> Manufacturer : $($bios.Manufacturer)" -ForegroundColor Green;
        Write-Host "   -> Release Date : $($bios.ReleaseDate)" -ForegroundColor Green;
        Write-Host "   -> Serial No.   : $($bios.SerialNumber)" -ForegroundColor Green;
        Write-Host "      (Closest thing to actual hardware age  unaffected by" -ForegroundColor DarkGray;
        Write-Host "       Windows reinstalls.)`n" -ForegroundColor DarkGray;
    } catch {
        Write-Host "   -> Unable to retrieve.`n" -ForegroundColor DarkRed;
    }

    Write-Host "---------------------------------------------------" -ForegroundColor Gray;
    Write-Host " Press any key to return to menu..." -ForegroundColor Gray;
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
}

# Diagnostic Reports Functions
function Fix-HtmlReport {
    param ([string]$ReportPath)
    if (Test-Path $ReportPath) {
        try {
            $Content = Get-Content -Path $ReportPath -Raw -ErrorAction Stop;
            [System.IO.File]::WriteAllText($ReportPath, $Content, [System.Text.Encoding]::UTF8);
            return $true;
        } catch {
            return $false;
        }
    }
    return $false;
}

function Invoke-PowerReport {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        AetherPulse Power & Battery Report          " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;
    Write-Host "Analyzing power efficiency and hardware states (60s)..." -ForegroundColor Gray;

    $OutputPath = "$env:TEMP\energy-report.html";
    [void](cmd.exe /c "powercfg /energy /output `"$OutputPath`"");

    if (Test-Path $OutputPath) {
        [void](Fix-HtmlReport -ReportPath $OutputPath);
        Write-Host "`n[+] Report Generated Successfully!" -ForegroundColor Green;
        Write-Host "    Saved to: $OutputPath" -ForegroundColor DarkGray;
        Write-Host "    Opening energy-report.html in default browser..." -ForegroundColor DarkGray;
        Start-Process $OutputPath;
    } else {
        Write-Host "`n[!] Failed to locate generated energy report." -ForegroundColor DarkRed;
    }
    Start-Sleep -Seconds 3;
}

function Invoke-SystemReport {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        NexusDiag Full System Health Report         " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;
    Write-Host "Initiating System Diagnostics trace (60s)..." -ForegroundColor Gray;
    Write-Host "Report dashboard will open automatically upon completion.`n" -ForegroundColor DarkGray;

    perfmon /report;

    Write-Host "[+] Diagnostic collection triggered!" -ForegroundColor Green;
    Start-Sleep -Seconds 3;
}

function Invoke-ReliabilityMonitor {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        AetherLog Reliability History Monitor       " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;
    Write-Host "Launching Reliability Monitor dashboard..." -ForegroundColor Gray;

    perfmon /rel;

    Write-Host "`n[+] Reliability Monitor Launched!" -ForegroundColor Green;
    Start-Sleep -Seconds 3;
}

function Invoke-BatteryReport {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        AetherCell Battery Health Dashboard         " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;

    $HasBattery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue;

    if (-not $HasBattery) {
        Write-Host "[!] Desktop PC or VM Detected." -ForegroundColor Yellow;
        Write-Host "    Battery Health reports are only available on laptops/mobile devices." -ForegroundColor DarkGray;
        Start-Sleep -Seconds 4;
        return;
    }

    Write-Host "Generating battery health and cycle history..." -ForegroundColor Gray;

    $TargetPaths = @(
        "$env:USERPROFILE\Desktop\battery-report.html",
        "$env:TEMP\battery-report.html",
        "C:\battery-report.html"
    );

    $SuccessfulReport = $null;

    foreach ( $Path in $TargetPaths ) {
        if (-not $SuccessfulReport) {
            [void](cmd.exe /c "powercfg /batteryreport /output `"$Path`"" 2>&1);
            if (Test-Path $Path) {
                $SuccessfulReport = $Path;
            }
        }
    }

    if ($SuccessfulReport) {
        [void](Fix-HtmlReport -ReportPath $SuccessfulReport);
        Write-Host "`n[+] Battery Report Generated Successfully!" -ForegroundColor Green;
        Write-Host "    Saved to: $SuccessfulReport" -ForegroundColor DarkGray;
        Write-Host "    Opening in default browser..." -ForegroundColor DarkGray;
        Start-Process $SuccessfulReport;
    } else {
        Write-Host "`n[!] Battery driver error or ACPI interface restricted." -ForegroundColor DarkRed;
        Write-Host "    Try disabling and re-enabling 'Microsoft ACPI-Compliant Control" -ForegroundColor Yellow;
        Write-Host "    Method Battery' in Device Manager." -ForegroundColor Yellow;
    }
    Start-Sleep -Seconds 4;
}

function Invoke-SleepStudyReport {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        AetherSleep Standby Battery Analysis        " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;
    Write-Host "Generating Modern Standby sleep drain telemetry..." -ForegroundColor Gray;

    $Path = "$env:TEMP\sleep-study.html";
    [void](cmd.exe /c "powercfg /sleepstudy /output `"$Path`"" 2>&1);

    if (Test-Path $Path) {
        [void](Fix-HtmlReport -ReportPath $Path);
        Write-Host "`n[+] Sleep Study Generated Successfully!" -ForegroundColor Green;
        Write-Host "    Saved to: $Path" -ForegroundColor DarkGray;
        Write-Host "    Opening in default browser..." -ForegroundColor DarkGray;
        Start-Process $Path;
    } else {
        Write-Host "`n[!] Failed to generate Sleep Study report." -ForegroundColor DarkRed;
    }
    Start-Sleep -Seconds 3;
}

function Invoke-WlanReport {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        AetherNet Wi-Fi Diagnostic Timeline         " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;

    $WlanService = Get-Service -Name "WlanSvc" -ErrorAction SilentlyContinue;
    if ($WlanService -and $WlanService.Status -ne "Running") {
        Write-Host "Starting WLAN AutoConfig service..." -ForegroundColor DarkGray;
        Start-Service -Name "WlanSvc" -ErrorAction SilentlyContinue;
    }

    $NetshCheck = [string](netsh wlan show interfaces 2>&1);
    if ($NetshCheck -match "There is no wireless interface on the system") {
        Write-Host "[!] No active Wi-Fi adapter detected on this system." -ForegroundColor Yellow;
        Write-Host "    Wi-Fi reports require an operational wireless interface." -ForegroundColor DarkGray;
        Start-Sleep -Seconds 4;
        return;
    }

    [void](wevtutil sl "Microsoft-Windows-WLAN-AutoConfig/Operational" /e:true 2>&1);
    [void](wevtutil sl "Microsoft-Windows-Nwifi/Diagnostic" /e:true 2>&1);

    Write-Host "Analyzing wireless adapters and connection history..." -ForegroundColor Gray;

    $ProgramDataDir = "$env:ProgramData\Microsoft\Windows\WlanReport";
    if (-not (Test-Path $ProgramDataDir)) {
        [void](New-Item -ItemType Directory -Path $ProgramDataDir -Force);
    }

    $NetshResult = [string](cmd.exe /c "netsh wlan show wlanreport" 2>&1);

    $ReportFiles = Get-ChildItem -Path $ProgramDataDir -Filter "*.html" -ErrorAction SilentlyContinue;
    $ReportFile = $null;
    if ($ReportFiles) {
        $newest = $ReportFiles[0];
        foreach ( $f in $ReportFiles ) {
            if ($f.LastWriteTime -gt $newest.LastWriteTime) { $newest = $f; }
        }
        $ReportFile = $newest;
    }

    $TargetCopy = "$env:TEMP\wlan-report-latest.html";

    if ($ReportFile -and (Test-Path $ReportFile.FullName)) {
        [void](Copy-Item -Path $ReportFile.FullName -Destination $TargetCopy -Force -ErrorAction SilentlyContinue);
        $FinalOutput = if (Test-Path $TargetCopy) { $TargetCopy } else { $ReportFile.FullName };

        [void](Fix-HtmlReport -ReportPath $FinalOutput);

        Write-Host "`n[+] Wi-Fi Diagnostic Report Generated Successfully!" -ForegroundColor Green;
        Write-Host "    Saved to: $FinalOutput" -ForegroundColor DarkGray;
        Write-Host "    Opening in default browser..." -ForegroundColor DarkGray;
        Start-Process $FinalOutput;
    } else {
        $FallbackTxt = "$env:USERPROFILE\Desktop\wlan-diagnostic-log.txt";
        cmd.exe /c "netsh wlan show all" > $FallbackTxt 2>&1;

        if (Test-Path $FallbackTxt) {
            Write-Host "`n[!] Event Log trace failed (0x2 Error). Generated Fallback Log!" -ForegroundColor Yellow;
            Write-Host "    Saved raw Wi-Fi analysis to: $FallbackTxt" -ForegroundColor DarkGray;
            Write-Host "    Opening text log..." -ForegroundColor DarkGray;
            Start-Process $FallbackTxt;
        } else {
            Write-Host "`n[!] Wi-Fi interface detected, but netsh failed to output trace." -ForegroundColor DarkRed;
            Write-Host "    Diagnostic Log: $NetshResult" -ForegroundColor DarkGray;
        }
    }
    Start-Sleep -Seconds 4;
}

function Invoke-ResourceMonitor {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        NexusMon Real-Time Resource Inspector       " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;
    Write-Host "Launching Windows Resource Monitor..." -ForegroundColor Gray;

    resmon;

    Write-Host "`n[+] Resource Monitor Launched!" -ForegroundColor Green;
    Start-Sleep -Seconds 3;
}

function Invoke-DriverBackup {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        AetherDriver Backup & Export                " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;

    $BackupPath = "$env:USERPROFILE\Desktop\DriverBackup";
    if (-not (Test-Path $BackupPath)) {
        [void](New-Item -ItemType Directory -Path $BackupPath);
    }

    Write-Host "Exporting third-party drivers to Desktop\DriverBackup..." -ForegroundColor Gray;
    [void](pnputil /export-driver * $BackupPath);

    Write-Host "`n[+] Third-Party Drivers Backed Up Successfully!" -ForegroundColor Green;
    Write-Host "    Location: $BackupPath" -ForegroundColor DarkGray;
    Start-Sleep -Seconds 3;
}

function Invoke-GodMode {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "        NexusVault Master Control                   " -ForegroundColor Gray;
    Write-Host "===================================================`n" -ForegroundColor Gray;
    Write-Host "Launching Unified Windows God Mode Control Panel..." -ForegroundColor Gray;

    explorer.exe "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}";

    Write-Host "`n[+] Master Control Panel Launched!" -ForegroundColor Green;
    Start-Sleep -Seconds 3;
}


# Show welcome banner once at startup
Show-WelcomeBanner;

# Interactive Menu Loop
do {
    Clear-Host;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "              === Izzeldeen Dradkh ===             " -ForegroundColor Gray;
    Write-Host "              SYSTEM MAINTENANCE SUITE              " -ForegroundColor Gray;
    Write-Host "===================================================" -ForegroundColor Gray;

    # --- GENERAL SECTION ---
    Write-Host "`n --- [ GENERAL / MOST USED ] ----------------------" -ForegroundColor DarkGreen;
    Write-Host " [1] QuantumClean Deep-Purge" -ForegroundColor Gray;
    Write-Host "     (Universal Dynamic Cache Discovery & Purge)" -ForegroundColor DarkGray;
    Write-Host " [2] NexusPrime Core-Optimizer" -ForegroundColor Gray;
    Write-Host "     (Windows Performance & Repair Suite)" -ForegroundColor DarkGray;
    Write-Host " [3] AetherHealth Hardware Dashboard" -ForegroundColor Gray;
    Write-Host "     (Full CPU/RAM/Disk/GPU/Battery Specs & Health)" -ForegroundColor DarkGray;
    Write-Host " [4] AetherFlush Network-Reset" -ForegroundColor Gray;
    Write-Host "     (Flush Network & DNS Cache Only)" -ForegroundColor DarkGray;

    # --- ADVANCED SECTION ---
    Write-Host "`n --- [ ADVANCED & DIAGNOSTICS ] -------------------" -ForegroundColor DarkGreen;
    Write-Host " [7] AetherCell Battery Health Dashboard" -ForegroundColor Gray;
    Write-Host "     (Detailed Battery Capacity & Life Cycles)" -ForegroundColor DarkGray;
    Write-Host " [8] AetherSleep Standby Battery Analysis" -ForegroundColor Gray;
    Write-Host "     (Track Background Battery Drain in Sleep)" -ForegroundColor DarkGray;
    Write-Host " [9] AetherNet Wi-Fi Diagnostic Timeline" -ForegroundColor Gray;
    Write-Host "     (Wireless Session Drops & Signal Graph)" -ForegroundColor DarkGray;
    Write-Host " [A] AetherPulse Power Report" -ForegroundColor Gray;
    Write-Host "     (60s Power & Battery Efficiency Trace)" -ForegroundColor DarkGray;
    Write-Host " [B] NexusDiag System Health Report" -ForegroundColor Gray;
    Write-Host "     (Full Hardware & System Diagnostics)" -ForegroundColor DarkGray;
    Write-Host " [C] NexusMon Real-Time Resource Inspector" -ForegroundColor Gray;
    Write-Host "     (Live CPU/RAM/Disk/Network Process Monitor)" -ForegroundColor DarkGray;
    Write-Host " [D] AetherLog Reliability Monitor" -ForegroundColor Gray;
    Write-Host "     (System Crash & Software Stability History)" -ForegroundColor DarkGray;
    Write-Host " [E] AetherDriver Backup & Export" -ForegroundColor Gray;
    Write-Host "     (Export All Third-Party Drivers to Desktop)" -ForegroundColor DarkGray;
    Write-Host " [F] NexusVault Master Control" -ForegroundColor Gray;
    Write-Host "     (Open Unified God Mode Control Panel)" -ForegroundColor DarkGray;
    Write-Host " [G] AetherOrigin Device Timeline" -ForegroundColor Gray;
    Write-Host "     (OS Install / First Boot / Sign-In / BIOS Dates)" -ForegroundColor DarkGray;

    Write-Host "`n [Q] Quit" -ForegroundColor DarkRed;
    Write-Host "===================================================" -ForegroundColor Gray;
    Write-Host "Choose an option using your keyboard [1-9, A-G, Q] : " -NoNewline;

    $Key = [System.Console]::ReadKey($true);
    $Selection = [string]$Key.KeyChar;
    Write-Host $Selection;
    Start-Sleep -Milliseconds 300;

    switch ($Selection.ToUpper()) {
        # General Options
        "1" { Invoke-UniversalClean }
        "2" { Invoke-PerformanceOptimization }
        "3" { Invoke-HardwareDashboard }
        "4" {
            Clear-DnsClientCache;
            Write-Host "`nAetherFlush: DNS Cache Cleared!" -ForegroundColor Green;
            Start-Sleep -Seconds 3;
        }
        # Advanced Options
        "7" { Invoke-BatteryReport }
        "8" { Invoke-SleepStudyReport }
        "9" { Invoke-WlanReport }
        "A" { Invoke-PowerReport }
        "B" { Invoke-SystemReport }
        "C" { Invoke-ResourceMonitor }
        "D" { Invoke-ReliabilityMonitor }
        "E" { Invoke-DriverBackup }
        "F" { Invoke-GodMode }
        "G" { Invoke-DeviceTimeline }

        "Q" { Write-Host "`nExiting..."; Exit }

        # Invalid Input Error Handling
        default {
            Write-Host "`n`n[!] Invalid Selection: '$Selection'" -ForegroundColor Red;
            Write-Host "    Please enter a valid option symbol from the menu [1-9, A-G, Q]." -ForegroundColor Red;
            Start-Sleep -Seconds 3;
        }
    }
} while ($true)
