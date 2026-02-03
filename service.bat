@echo off
set "LOCAL_VERSION=1.8.5"

:: External commands
if "%~1"=="status_zapret" (
    call :test_service zapret soft
    call :tcp_enable
    exit /b
)

if "%~1"=="check_updates" (
    if exist "%~dp0utils\check_updates.enabled" (
        if not "%~2"=="soft" (
            start /b service check_updates soft
        ) else (
            call :service_check_updates soft
        )
    )

    exit /b
)


if "%~1"=="load_game_filter" (
    call :game_switch_status
    exit /b
)

if "%~1"=="list" (
    call :list ext
    exit /b
)

if "%~1"=="ips" (
    call :ips ext
    exit /b
)

if "%~1"=="bin" (
    call :bin ext
    exit /b
)

if "%~1"=="et" (
    call :et ext
    exit /b
)

if "%1"=="admin" (
    call :check_command chcp
    call :check_command find
    call :check_command findstr
    call :check_command netsh
    echo Started with admin rights
) else (
    call :check_extracted
    call :check_command powershell
    echo Requesting admin rights...
    powershell -NoProfile -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"' -Verb RunAs"
    exit
)

set "defaultlistsource=https://raw.githubusercontent.com/bol-van/rulist/refs/heads/main/reestr_hostname.txt"
set "defaultipsetsource=https://raw.githubusercontent.com/bol-van/rulist/refs/heads/main/reestr_smart4.txt"

:: MENU ================================
setlocal EnableDelayedExpansion
:menu
cls

call :ipset_switch_status
call :game_switch_status
call :check_updates_switch_status
call :getsources
call :getalgorithm

if "!IPSET_SOURCE!"=="%defaultipsetsource%" (
    set "ipsetdefault=[default]"
) else set "ipsetdefault="
if "!LIST_SOURCE!"=="%defaultlistsource%" (
    set "listdefault=[default]"
) else set "listdefault="

if not exist "%~dp0utils\VerifyFiles" (
    set "param_verify_when_updating=disabled"
) else (
    set "param_verify_when_updating=enabled"
)

set "menu_choice=null"

echo.
echo   MENU v!LOCAL_VERSION!
echo   --------------------------------------------------------------------------
echo.
echo   :: SERVICE                 :: SETTINGS
echo      1. Install Service         21. Switch Game Filter (UDP)  [!GameFilterStatus!]
echo      2. Remove Services         22. Switch Game Filter (TCP)  [!GameFilterTCPStatus!]
echo      3. Check Status            23. Switch Check Updates      [!CheckUpdatesStatus!]
echo                                 24. Switch ipset              [!IPsetStatus!]
echo   :: UPDATES                    25. list-general Source       !listdefault!
echo      4. Update bin\ Folder      26. ipset-all Source          !ipsetdefault!
echo      5. Update list-general     27. Verify files on update    [!param_verify_when_updating!]
echo      6. Update ipset-all        28. Verifier Hash Algorithm   [!ALG!]
echo      7. Update Everything
echo      8. Update hosts File
echo      9. Check for Updates
echo.
echo   :: TOOLS
echo      10. Run Diagnostics
echo      11. Run Tests
echo      12. Verify All Files
echo.
echo  --------------------------------------------------------------------------
echo      0. Exit
echo.

set /p menu_choice=Enter choice (0-28): 

:: Service
if "%menu_choice%"=="1" goto service_install
if "%menu_choice%"=="2" goto service_remove
if "%menu_choice%"=="3" goto service_status

:: Updates
if "%menu_choice%"=="4" goto bin
if "%menu_choice%"=="5" goto list
if "%menu_choice%"=="6" goto ips
if "%menu_choice%"=="7" goto et
if "%menu_choice%"=="8" goto hosts_update
if "%menu_choice%"=="9" goto service_check_updates

:: Tools
if "%menu_choice%"=="10" goto service_diagnostics
if "%menu_choice%"=="11" goto run_tests
if "%menu_choice%"=="12" goto verifyall

:: Settings
if "%menu_choice%"=="21" goto game_switch
if "%menu_choice%"=="22" goto game_switch_tcp
if "%menu_choice%"=="23" goto check_updates_switch
if "%menu_choice%"=="24" goto ipset_switch
if "%menu_choice%"=="25" goto setlistsource
if "%menu_choice%"=="26" goto setipsetsource
if "%menu_choice%"=="27" goto verifyfilesparam
if "%menu_choice%"=="28" goto setalgorithm

if "%menu_choice%"=="0" exit /b

goto menu

:: TCP ENABLE ==========================
:tcp_enable
netsh interface tcp show global | findstr /i "timestamps" | findstr /i "enabled" > nul || netsh interface tcp set global timestamps=enabled > nul 2>&1
exit /b


:: STATUS ==============================
:service_status
cls
chcp 437 > nul

sc query "zapret" >nul 2>&1
if !errorlevel!==0 (
    for /f "tokens=2*" %%A in ('reg query "HKLM\System\CurrentControlSet\Services\zapret" /v shizapret 2^>nul') do echo Service strategy installed from '%%B'
    if !errorlevel!==0 (
        for /f "tokens=2*" %%A in ('reg query "HKLM\System\CurrentControlSet\Services\zapret" /v zapret-discord-youtube 2^>nul') do call :PrintYellow "Service strategy installed from '%%B' using zapret-discord-youtube or an older version of shizapret."
    )
)

call :test_service zapret
call :test_service WinDivert

set "BIN_PATH=%~dp0bin\"
if not exist "%BIN_PATH%\*.sys" (
    call :PrintRed "WinDivert64.sys file NOT found."
)
pause
echo:

tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
if !errorlevel!==0 (
    call :PrintGreen "Bypass (winws.exe) is RUNNING"
) else (
    call :PrintRed "Bypass (winws.exe) is NOT running"
)

pause
goto menu

:test_service
set "ServiceName=%~1"
set "ServiceStatus="

for /f "tokens=3 delims=: " %%A in ('sc query "%ServiceName%" ^| findstr /i "STATE"') do set "ServiceStatus=%%A"
set "ServiceStatus=%ServiceStatus: =%"

if "%ServiceStatus%"=="RUNNING" (
    if "%~2"=="soft" (
        echo "%ServiceName%" is ALREADY RUNNING as service, use "service.bat" and choose "Remove Services" first if you want to run standalone bat.
        pause
        exit /b
    ) else (
        echo "%ServiceName%" service is RUNNING.
    )
) else if "%ServiceStatus%"=="STOP_PENDING" (
    call :PrintYellow "!ServiceName! is STOP_PENDING. This may be caused by a conflict with another bypass. Run Diagnostics to try to fix conflicts"
) else if not "%~2"=="soft" (
    echo "%ServiceName%" service is NOT running.
)

exit /b


:: REMOVE ==============================
:service_remove
cls
chcp 65001 > nul

set SRVCNAME=zapret
sc query "!SRVCNAME!" >nul 2>&1
if !errorlevel!==0 (
    net stop %SRVCNAME%
    sc delete %SRVCNAME%
) else (
    echo Service "%SRVCNAME%" is not installed.
)

sc query "WinDivert" >nul 2>&1
if !errorlevel!==0 (
    net stop "WinDivert"

    sc query "WinDivert" >nul 2>&1
    if !errorlevel!==0 (
        sc delete "WinDivert"
    )
)

net stop "WinDivert14" >nul 2>&1
sc delete "WinDivert14" >nul 2>&1
if "%1"=="shizapret" exit /b

pause
goto menu


:: INSTALL =============================
:service_install
cls
chcp 437 > nul

:: Main
cd /d "%~dp0"
set "BIN_PATH=%~dp0bin\"
set "LISTS_PATH=%~dp0lists\"

if not exist "bin/cygwin1.dll" (
    call bin
)
if not exist "lists/list-general.txt" (
    call list
)
if not exist "lists/ipset-all.txt" (
    call ips
)

cls

:: Searching for .bat files in current folder, except for files that start with "service" and "calls"
echo Pick one of the options:
set "count=0"
for /f "delims=" %%F in ('powershell -NoProfile -Command "Get-ChildItem -LiteralPath '.' -Filter '*.bat' | Where-Object { $_.Name -notlike 'service*' } | Sort-Object { [Regex]::Replace($_.Name, '(\d+)', { $args[0].Value.PadLeft(8, '0') }) } | ForEach-Object { $_.Name }"') do (
    set /a count+=1
    echo !count!. %%F
    set "file!count!=%%F"
)

:: Choosing file
set "choice="
set /p "choice=Input file index (number): "
if "!choice!"=="" (
    echo The choice is empty, exiting...
    pause
    goto menu
)

set "selectedFile=!file%choice%!"
if not defined selectedFile (
    echo Invalid choice, exiting...
    pause
    goto menu
)

:: Args that should be followed by value
set "args_with_value=sni host altorder"

:: Parsing args (mergeargs: 2=start param|3=arg with value|1=params args|0=default)
set "args="
set "capture=0"
set "mergeargs=0"
set QUOTE="

for /f "tokens=*" %%a in ('type "!selectedFile!"') do (
    set "line=%%a"
    call set "line=%%line:^!=EXCL_MARK%%"

    echo !line! | findstr /i "%BIN%winws.exe" >nul
    if not errorlevel 1 (
        set "capture=1"
    )

    if !capture!==1 (
        if not defined args (
            set "line=!line:*%BIN%winws.exe"=!"
        )

        set "temp_args="
        for %%i in (!line!) do (
            set "arg=%%i"

            if not "!arg!"=="^" (
                if "!arg:~0,2!" EQU "--" if not !mergeargs!==0 (
                    set "mergeargs=0"
                )

                if "!arg:~0,1!" EQU "!QUOTE!" (
                    set "arg=!arg:~1,-1!"

                    echo !arg! | findstr ":" >nul
                    if !errorlevel!==0 (
                        set "arg=\!QUOTE!!arg!\!QUOTE!"
                    ) else if "!arg:~0,1!"=="@" (
                        set "arg=\!QUOTE!@%~dp0!arg:~1!\!QUOTE!"
                    ) else if "!arg:~0,5!"=="%%BIN%%" (
                        set "arg=\!QUOTE!!BIN_PATH!!arg:~5!\!QUOTE!"
                    ) else if "!arg:~0,7!"=="%%LISTS%%" (
                        set "arg=\!QUOTE!!LISTS_PATH!!arg:~7!\!QUOTE!"
                    ) else (
                        set "arg=\!QUOTE!%~dp0!arg!\!QUOTE!"
                    )
                ) else if "!arg:~0,12!" EQU "%%GameFilter%%" (
                    set "arg=%GameFilter%"
                ) else if "!arg:~0,16!" EQU "%%GameFilterTCP%%" (
                    set "arg=%GameFilterTCP%"
                ) 

                if !mergeargs!==1 (
                    set "temp_args=!temp_args!,!arg!"
                ) else if !mergeargs!==3 (
                    set "temp_args=!temp_args!=!arg!"
                    set "mergeargs=1"
                ) else (
                    set "temp_args=!temp_args! !arg!"
                )

                if "!arg:~0,2!" EQU "--" (
                    set "mergeargs=2"
                ) else if !mergeargs! GEQ 1 (
                    if !mergeargs!==2 set "mergeargs=1"

                    for %%x in (!args_with_value!) do (
                        if /i "%%x"=="!arg!" (
                            set "mergeargs=3"
                        )
                    )
                )
            )
        )

        if not "!temp_args!"=="" (
            set "args=!args! !temp_args!"
        )
    )
)

:: Creating service with parsed args
call :tcp_enable

set ARGS=%args%
call set "ARGS=%%ARGS:EXCL_MARK=^!%%"
echo Final args: !ARGS!
set SRVCNAME=zapret

net stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1
sc create %SRVCNAME% binPath= "\"%BIN_PATH%winws.exe\" !ARGS!" DisplayName= "zapret" start= auto
sc description %SRVCNAME% "Zapret DPI bypass software"
sc start %SRVCNAME%
for %%F in ("!file%choice%!") do (
    set "filename=%%~nF"
)
reg add "HKLM\System\CurrentControlSet\Services\zapret" /v shizapret /t REG_SZ /d "!filename!" /f

pause
goto menu


:: CHECK UPDATES =======================
:service_check_updates
chcp 437 > nul
cls

:: Set current version and URLs
set "GITHUB_VERSION_URL=https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/version.txt"
set "GITHUB_RELEASE_URL=https://github.com/sch-izo/shizapret/releases/tag/"
set "GITHUB_DOWNLOAD_URL=https://github.com/sch-izo/shizapret/releases/latest"

:: Get the latest version from GitHub
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Invoke-WebRequest -Uri \"%GITHUB_VERSION_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -UseBasicParsing -TimeoutSec 5).Content.Trim()" 2^>nul') do set "GITHUB_VERSION=%%A"

:: Error handling
if not defined GITHUB_VERSION (
    echo Failed to fetch the latest version. This does not affect the operation of shizapret.
    timeout /T 9
    if "%1"=="soft" exit 
    goto menu
)

:: Version comparison
if "%LOCAL_VERSION%"=="%GITHUB_VERSION%" (
    echo Latest version installed: %LOCAL_VERSION%
    
    if "%1"=="soft" exit
    pause
    goto menu
) 

echo New version available: %GITHUB_VERSION%
echo Release page: %GITHUB_RELEASE_URL%%GITHUB_VERSION%

echo Opening the download page...
start "" "%GITHUB_DOWNLOAD_URL%"


if "%1"=="soft" exit
cls
pause
goto menu



:: DIAGNOSTICS =========================
:service_diagnostics
chcp 437 > nul
cls

:: Base Filtering Engine
sc query BFE | findstr /I "RUNNING" > nul
if !errorlevel!==0 (
    call :PrintGreen "Base Filtering Engine check passed"
) else (
    call :PrintRed "[X] Base Filtering Engine is not running. This service is required for zapret to work"
)
echo:

:: Proxy check
set "proxyEnabled=0"
set "proxyServer="

for /f "tokens=2*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable 2^>nul ^| findstr /i "ProxyEnable"') do (
    if "%%B"=="0x1" set "proxyEnabled=1"
)

if !proxyEnabled!==1 (
    for /f "tokens=2*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer 2^>nul ^| findstr /i "ProxyServer"') do (
        set "proxyServer=%%B"
    )

    call :PrintYellow "[?] System proxy is enabled: !proxyServer!"
    call :PrintYellow "Make sure it's valid or disable it if you don't use a proxy"
) else (
    call :PrintGreen "Proxy check passed"
)
echo:

:: TCP timestamps check
netsh interface tcp show global | findstr /i "timestamps" | findstr /i "enabled" > nul
if !errorlevel!==0 (
    call :PrintGreen "TCP timestamps check passed"
) else (
    call :PrintYellow "[?] TCP timestamps are disabled. Enabling timestamps..."
    netsh interface tcp set global timestamps=enabled > nul 2>&1
    if !errorlevel!==0 (
        call :PrintGreen "TCP timestamps successfully enabled"
    ) else (
        call :PrintRed "[X] Failed to enable TCP timestamps"
    )
)
echo:

:: AdguardSvc.exe
tasklist /FI "IMAGENAME eq AdguardSvc.exe" | find /I "AdguardSvc.exe" > nul
if !errorlevel!==0 (
    call :PrintRed "[X] Adguard process found. Adguard may cause problems with Discord"
    call :PrintRed "https://github.com/Flowseal/zapret-discord-youtube/issues/417"
) else (
    call :PrintGreen "Adguard check passed"
)
echo:

:: Killer
sc query | findstr /I "Killer" > nul
if !errorlevel!==0 (
    call :PrintRed "[X] Killer services found. Killer conflicts with zapret"
    call :PrintRed "https://github.com/Flowseal/zapret-discord-youtube/issues/2512#issuecomment-2821119513"
) else (
    call :PrintGreen "Killer check passed"
)
echo:

:: Intel Connectivity Network Service
sc query | findstr /I "Intel" | findstr /I "Connectivity" | findstr /I "Network" > nul
if !errorlevel!==0 (
    call :PrintRed "[X] Intel Connectivity Network Service found. It conflicts with zapret"
    call :PrintRed "https://github.com/ValdikSS/GoodbyeDPI/issues/541#issuecomment-2661670982"
) else (
    call :PrintGreen "Intel Connectivity check passed"
)
echo:

:: Check Point
set "checkpointFound=0"
sc query | findstr /I "TracSrvWrapper" > nul
if !errorlevel!==0 (
    set "checkpointFound=1"
)

sc query | findstr /I "EPWD" > nul
if !errorlevel!==0 (
    set "checkpointFound=1"
)

if !checkpointFound!==1 (
    call :PrintRed "[X] Check Point services found. Check Point conflicts with zapret"
    call :PrintRed "Try to uninstall Check Point"
) else (
    call :PrintGreen "Check Point check passed"
)
echo:

:: SmartByte
sc query | findstr /I "SmartByte" > nul
if !errorlevel!==0 (
    call :PrintRed "[X] SmartByte services found. SmartByte conflicts with zapret"
    call :PrintRed "Try to uninstall or disable SmartByte through services.msc"
) else (
    call :PrintGreen "SmartByte check passed"
)
echo:

:: WinDivert64.sys file
set "BIN_PATH=%~dp0bin\"
if not exist "%BIN_PATH%\*.sys" (
    call :PrintRed "WinDivert64.sys file NOT found."
    echo:
)

:: VPN
set "VPN_SERVICES="
sc query | findstr /I "VPN" > nul
if !errorlevel!==0 (
    for /f "tokens=2 delims=:" %%A in ('sc query ^| findstr /I "VPN"') do (
        if not defined VPN_SERVICES (
            set "VPN_SERVICES=!VPN_SERVICES!%%A"
        ) else (
            set "VPN_SERVICES=!VPN_SERVICES!,%%A"
        )
    )
    call :PrintYellow "[?] VPN services found:!VPN_SERVICES!. Some VPNs can conflict with zapret"
    call :PrintYellow "Make sure that all VPNs are disabled"
) else (
    call :PrintGreen "VPN check passed"
)
echo:

:: DNS
set "dnsfound=0"
for /f "delims=" %%a in ('powershell -NoProfile -Command "Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $true} | ForEach-Object {$_.DNSServerSearchOrder} | Where-Object {$_ -match '^192\.168\.'} | Measure-Object | Select-Object -ExpandProperty Count"') do (
    if %%a gtr 0 (
        set "dnsfound=1"
    )
)
if !dnsfound!==1 (
    call :PrintYellow "[?] DNS servers are probably not specified."
    call :PrintYellow "Provider's DNS servers are probably automatically used, which may affect zapret. It is recommended to install well-known DNS servers and setup DoH"
) else (
    call :PrintGreen "DNS check passed"
)
echo:

:: Secure DNS
set "dohfound=0"
for /f "delims=" %%a in ('powershell -NoProfile -Command "Get-ChildItem -Recurse -Path 'HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\' | Get-ItemProperty | Where-Object { $_.DohFlags -gt 0 } | Measure-Object | Select-Object -ExpandProperty Count"') do (
    if %%a gtr 0 (
        set "dohfound=1"
    )
)
if !dohfound!==0 (
    call :PrintYellow "[?] Make sure you have configured secure DNS in a browser with a non-default DNS service provider."
    call :PrintYellow "If you use Windows 11, you can configure encrypted DNS in the Settings to hide this warning"
) else (
    call :PrintGreen "Secure DNS check passed"
)
echo:

:: WinDivert conflict
tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
set "winws_running=!errorlevel!"

sc query "WinDivert" | findstr /I "RUNNING STOP_PENDING" > nul
set "windivert_running=!errorlevel!"

if !winws_running! neq 0 if !windivert_running!==0 (
    call :PrintYellow "[?] winws.exe is not running but WinDivert service is active. Attempting to delete WinDivert..."
    
    net stop "WinDivert" >nul 2>&1
    sc delete "WinDivert" >nul 2>&1
    sc query "WinDivert" >nul 2>&1
    if !errorlevel!==0 (
        call :PrintRed "[X] Failed to delete WinDivert. Checking for conflicting services..."
        
        set "conflicting_services=GoodbyeDPI"
        set "found_conflict=0"
        
        for %%s in (!conflicting_services!) do (
            sc query "%%s" >nul 2>&1
            if !errorlevel!==0 (
                call :PrintYellow "[?] Found conflicting service: %%s. Stopping and removing..."
                net stop "%%s" >nul 2>&1
                sc delete "%%s" >nul 2>&1
                if !errorlevel!==0 (
                    call :PrintGreen "Successfully removed service: %%s"
                ) else (
                    call :PrintRed "[X] Failed to remove service: %%s"
                )
                set "found_conflict=1"
            )
        )
        
        if !found_conflict!==0 (
            call :PrintRed "[X] No conflicting services found. Check manually if any other bypass is using WinDivert."
        ) else (
            call :PrintYellow "[?] Attempting to delete WinDivert again..."

            net stop "WinDivert" >nul 2>&1
            sc delete "WinDivert" >nul 2>&1
            sc query "WinDivert" >nul 2>&1
            if !errorlevel! neq 0 (
                call :PrintGreen "WinDivert successfully deleted after removing conflicting services"
            ) else (
                call :PrintRed "[X] WinDivert still cannot be deleted. Check manually if any other bypass is using WinDivert."
            )
        )
    ) else (
        call :PrintGreen "WinDivert successfully removed"
    )
    
    echo:
)

:: Conflicting bypasses
set "conflicting_services=GoodbyeDPI discordfix_zapret winws1 winws2"
set "found_any_conflict=0"
set "found_conflicts="

for %%s in (!conflicting_services!) do (
    sc query "%%s" >nul 2>&1
    if !errorlevel!==0 (
        if "!found_conflicts!"=="" (
            set "found_conflicts=%%s"
        ) else (
            set "found_conflicts=!found_conflicts! %%s"
        )
        set "found_any_conflict=1"
    )
)

if !found_any_conflict!==1 (
    call :PrintRed "[X] Conflicting bypass services found: !found_conflicts!"
    
    set "CHOICE="
    set /p "CHOICE=Do you want to remove these conflicting services? (Y/N) (default: N) "
    if "!CHOICE!"=="" set "CHOICE=N"
    if "!CHOICE!"=="y" set "CHOICE=Y"
    
    if /i "!CHOICE!"=="Y" (
        for %%s in (!found_conflicts!) do (
            call :PrintYellow "Stopping and removing service: %%s"
            net stop "%%s" >nul 2>&1
            sc delete "%%s" >nul 2>&1
            if !errorlevel!==0 (
                call :PrintGreen "Successfully removed service: %%s"
            ) else (
                call :PrintRed "[X] Failed to remove service: %%s"
            )
        )

        net stop "WinDivert" >nul 2>&1
        sc delete "WinDivert" >nul 2>&1
        net stop "WinDivert14" >nul 2>&1
        sc delete "WinDivert14" >nul 2>&1
    )
    
    echo:
)

:: Discord cache clearing
set "CHOICE="
set /p "CHOICE=Do you want to clear the Discord cache? (Y/N) (default: Y)  "
if "!CHOICE!"=="" set "CHOICE=Y"
if "!CHOICE!"=="y" set "CHOICE=Y"

if /i "!CHOICE!"=="Y" (
    for %%i in ("Discord.exe" "DiscordPTB.exe" "DiscordCanary.exe") do (
        tasklist /FI "IMAGENAME eq %%i" | findstr /I "%%i" > nul
        if !errorlevel!==0 (
            echo %%i is running, closing...
            taskkill /IM %%i /F > nul
            if !errorlevel! == 0 (
                call :PrintGreen "%%i was successfully closed"
            ) else (
                call :PrintRed "Unable to close %%i"
            )
        )
    )

    set "discordCacheDir=%appdata%\discord"
    set "discordPTBCacheDir=%appdata%\discordptb"
    set "discordCanaryCacheDir=%appdata%\discordcanary"

    echo Cleaning Discord cache...
    for %%d in ("Cache" "Code Cache" "GPUCache") do (
        set "dirPath=!discordCacheDir!\%%~d"
        if exist "!dirPath!" (
            rd /s /q "!dirPath!"
            if !errorlevel!==0 (
                call :PrintGreen "Successfully deleted !dirPath!"
            ) else (
                call :PrintRed "Failed to delete !dirPath!"
            )
        ) else (
            call :PrintRed "!dirPath! does not exist"
        )
    )
    
    if exist "!discordPTBCacheDir!\" (
        echo Cleaning Discord PTB cache...
        for %%d in ("Cache" "Code Cache" "GPUCache") do (
            set "dirPath=!discordPTBCacheDir!\%%~d"
            if exist "!dirPath!" (
                rd /s /q "!dirPath!"
                if !errorlevel!==0 (
                    call :PrintGreen "Successfully deleted !dirPath!"
                ) else (
                    call :PrintRed "Failed to delete !dirPath!"
                )
            ) else (
                call :PrintRed "!dirPath! does not exist"
            )
        )
    )

    if exist "!discordCanaryCacheDir!\" (
        echo Cleaning Discord Canary cache...
        for %%d in ("Cache" "Code Cache" "GPUCache") do (
            set "dirPath=!discordCanaryCacheDir!\%%~d"
            if exist "!dirPath!" (
                rd /s /q "!dirPath!"
                if !errorlevel!==0 (
                    call :PrintGreen "Successfully deleted !dirPath!"
                ) else (
                    call :PrintRed "Failed to delete !dirPath!"
                )
            ) else (
                call :PrintRed "!dirPath! does not exist"
            )
        )
    )
)
echo:

pause
goto menu


:: GAME SWITCH ========================
:game_switch_status
chcp 437 > nul

set "gameFlagFile=%~dp0utils\game_filter.enabled"

if exist "%gameFlagFile%" (
    set "GameFilterStatus=enabled"
    set "GameFilter=1024-65535"
) else (
    set "GameFilterStatus=disabled"
    set "GameFilter=12"
)

set "gameTCPFlagFile=%~dp0utils\game_filtertcp.enabled"

if exist "%gameTCPFlagFile%" (
    set "GameFilterTCPStatus=enabled"
    set "GameFilterTCP=1024-65535"
) else (
    set "GameFilterTCPStatus=disabled"
    set "GameFilterTCP=12"
)
exit /b


:game_switch
chcp 437 > nul
cls

if not exist "%gameFlagFile%" (
    echo Enabling game filter...
    echo ENABLED > "%gameFlagFile%"
    call :PrintYellow "Restart shizapret to apply the changes."
) else (
    echo Disabling game filter...
    del /f /q "%gameFlagFile%"
    call :PrintYellow "Restart shizapret to apply the changes."
)

pause
goto menu

:game_switch_tcp
chcp 437 > nul
cls

if not exist "%gameTCPFlagFile%" (
    echo Enabling game filter for TCP...
    echo ENABLED > "%gameTCPFlagFile%"
    call :PrintYellow "Restart shizapret to apply the changes."
) else (
    echo Disabling game filter for TCP...
    del /f /q "%gameTCPFlagFile%"
    call :PrintYellow "Restart shizapret to apply the changes."
)

pause
goto menu

:: CHECK UPDATES SWITCH =================
:check_updates_switch_status
chcp 437 > nul

set "checkUpdatesFlag=%~dp0utils\check_updates.enabled"

if exist "%checkUpdatesFlag%" (
    set "CheckUpdatesStatus=enabled"
) else (
    set "CheckUpdatesStatus=disabled"
)
exit /b


:check_updates_switch
chcp 437 > nul
cls

if not exist "%checkUpdatesFlag%" (
    echo Enabling check updates...
    echo ENABLED > "%checkUpdatesFlag%"
) else (
    echo Disabling check updates...
    del /f /q "%checkUpdatesFlag%"
)

pause
goto menu


:: IPSET SWITCH =======================
:ipset_switch_status
chcp 437 > nul

set "listFile=%~dp0lists\ipset-all.txt"
for /f %%i in ('type "%listFile%" 2^>nul ^| find /c /v ""') do set "lineCount=%%i"

if !lineCount!==0 (
    set "IPsetStatus=any"
) else (
    findstr /R "^203\.0\.113\.113/32$" "%listFile%" >nul
    if !errorlevel!==0 (
        set "IPsetStatus=none"
    ) else (
        set "IPsetStatus=loaded"
    )
)
exit /b


:ipset_switch
chcp 437 > nul
cls
set "listFile=%~dp0lists\ipset-all.txt"
if not exist "%listFile%" (
  call :PrintRed "ipset is not downloaded."
  pause
  goto menu
)
set "backupFile=%listFile%.backup"


if "%IPsetStatus%"=="loaded" (
    echo Switching to none mode...
    
    if not exist "%backupFile%" (
        ren "%listFile%" "ipset-all.txt.backup"
    ) else (
        del /f /q "%backupFile%"
        ren "%listFile%" "ipset-all.txt.backup"
    )
    
    >"%listFile%" (
        echo 203.0.113.113/32
    )
    
) else if "%IPsetStatus%"=="none" (
    echo Switching to any mode...
    
    >"%listFile%" (
        rem Creating empty file
    )
    
) else if "%IPsetStatus%"=="any" (
    echo Switching to loaded mode...
    
    if exist "%backupFile%" (
        del /f /q "%listFile%"
        ren "%backupFile%" "ipset-all.txt"
    ) else (
        echo Error: no backup to restore. Update list from service menu first
        pause
        goto menu
    )
    
)

pause
goto menu


:: HOSTS UPDATE =======================
:hosts_update
chcp 437 > nul
cls

set "hostsFile=%SystemRoot%\System32\drivers\etc\hosts"
set "hostsUrl=https://raw.githubusercontent.com/Flowseal/zapret-discord-youtube/refs/heads/main/.service/hosts"
set "tempFile=%TEMP%\zapret_hosts.txt"
set "needsUpdate=0"

echo Checking hosts file...

if exist "%SystemRoot%\System32\curl.exe" (
    curl -L -s -o "%tempFile%" "%hostsUrl%"
) else (
    powershell -NoProfile -Command ^
        "$url = '%hostsUrl%';" ^
        "$out = '%tempFile%';" ^
        "$res = Invoke-WebRequest -Uri $url -TimeoutSec 10 -UseBasicParsing;" ^
        "if ($res.StatusCode -eq 200) { $res.Content | Out-File -FilePath $out -Encoding UTF8 } else { exit 1 }"
)

if not exist "%tempFile%" (
    call :PrintRed "Failed to download hosts file from repository"
    call :PrintYellow "Copy hosts file manually from %hostsUrl%"
    pause
    goto menu
)

set "firstLine="
set "lastLine="
for /f "usebackq delims=" %%a in ("%tempFile%") do (
    if not defined firstLine (
        set "firstLine=%%a"
    )
    set "lastLine=%%a"
)

findstr /C:"!firstLine!" "%hostsFile%" >nul 2>&1
if !errorlevel! neq 0 (
    echo First line from repository not found in hosts file
    set "needsUpdate=1"
)

findstr /C:"!lastLine!" "%hostsFile%" >nul 2>&1
if !errorlevel! neq 0 (
    echo Last line from repository not found in hosts file
    set "needsUpdate=1"
)

if "%needsUpdate%"=="1" (
    echo:
    call :PrintYellow "Hosts file needs to be updated"
    call :PrintYellow "Please manually copy the content from the downloaded file to your hosts file"
    
    start notepad "%tempFile%"
    explorer /select,"%hostsFile%"
) else (
    call :PrintGreen "Hosts file is up to date"
    if exist "%tempFile%" del /f /q "%tempFile%"
)

echo:
pause
goto menu


:: RUN TESTS =============================
:run_tests
chcp 65001 >nul
cls

echo Starting configuration tests...
echo.
start "" powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0utils\test_zapret.ps1"
pause
goto menu


:: Utility functions

:PrintGreen
powershell -NoProfile -Command "Write-Host \"%~1\" -ForegroundColor Green"
exit /b

:PrintRed
powershell -NoProfile -Command "Write-Host \"%~1\" -ForegroundColor Red"
exit /b

:PrintYellow
powershell -NoProfile -Command "Write-Host \"%~1\" -ForegroundColor Yellow"
exit /b

:check_command
where %1 >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] %1 not found in PATH
    echo Fix your PATH variable with instructions here https://github.com/Flowseal/zapret-discord-youtube/issues/7490
    pause
    exit /b 1
)
exit /b 0

:check_extracted
set "extracted=1"

if not exist "%~dp0bin\" set "extracted=0"

if "%extracted%"=="0" (
    echo shizapret must be extracted from archive first or bin folder not found for some reason
    pause
    exit
)
exit /b 0

:: ===== shizapret =====

:: ===== updater: ipset =====

:ips
cd /d "%~dp0"
call :getsources
cls
call :downloadfile "%IPSET_SOURCE%" "%~dp0lists/ipset-all.txt" "ipset-all.txt"
if "%~1"=="ext" exit /b
pause
goto menu

:: ===== updater: bin =====

:bin
cd /d "%~dp0"
call :getalgorithm

cls
call :downloadfile "https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/winws.exe" "%~dp0bin" "winws.exe"
if exist %~dp0utils\VerifyFiles (
    call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/winws.%ALG%" "%~dp0bin/winws.exe" "winws.exe"
)

cls
call :downloadfile "https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/WinDivert.dll" "%~dp0bin" "WinDivert.dll"
if exist %~dp0utils\VerifyFiles (
    call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/windivert.%ALG%" "%~dp0bin/WinDivert.dll" "WinDivert.dll"
)

cls
call :downloadfile "https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/WinDivert64.sys" "%~dp0bin" "WinDivert64.sys"
if exist %~dp0utils\VerifyFiles (
    call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/windivert64.%ALG%" "%~dp0bin/WinDivert64.sys" "WinDivert64.sys"
)

cls
call :downloadfile "https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/cygwin1.dll" "%~dp0bin" "cygwin1.dll"
if exist %~dp0utils\VerifyFiles (
    call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/cygwin1.%ALG%" "%~dp0bin/cygwin1.dll" "cygwin1.dll"
)

if "%~1"=="ext" exit /b
pause
goto menu

:: ===== updater: list =====

:list
cd /d "%~dp0"
call :getsources
cls
call :downloadfile "%LIST_SOURCE%" "%~dp0lists\list-general.txt" "list-general.txt"
>>"lists/list-general.txt" (
    echo encryptedsni.com
    echo adblockplus.org
)
if "%~1"=="ext" exit /b
pause
goto menu

:: ===== updater: everything =====

:et
cd /d "%~dp0"
cls
call :bin ext
call :ips ext
call :list ext

pause
goto menu

:: ===== set ipset source =====

:setipsetsource

cls
echo Current source: %IPSET_SOURCE% %ipsetdefault%
echo ==============================
echo Enter 0 to go back
echo Enter 1 to reset to default
echo ==============================

set "IPSET_SOURCE_INPUT=0"
set /p IPSET_SOURCE_INPUT=Enter the new ipset-all.txt source (link, starts with http(s)://): 

:: static commands

if "%IPSET_SOURCE_INPUT%"=="0" goto menu
if "%IPSET_SOURCE_INPUT%"=="1" set "IPSET_SOURCE_INPUT=%defaultipsetsource%"

:: set source

echo %IPSET_SOURCE_INPUT%> %~dp0\utils\IPSetSource
set "IPSET_SOURCE=%IPSET_SOURCE_INPUT%"

goto menu

:: ===== set list source =====

:setlistsource

cls
echo Current source: %LIST_SOURCE% %listdefault%
echo ==============================
echo Enter 0 to go back
echo Enter 1 to reset to default
echo ==============================

set "LIST_SOURCE_INPUT=0"
set /p LIST_SOURCE_INPUT=Enter the new list-general.txt source (link, starts with http(s)://): 

:: static commands

if "%LIST_SOURCE_INPUT%"=="0" goto menu
if "%LIST_SOURCE_INPUT%"=="1" set "LIST_SOURCE_INPUT=%defaultlistsource%"

:: set source

echo %LIST_SOURCE_INPUT%> %~dp0\utils\ListSource
set "LIST_SOURCE=%LIST_SOURCE_INPUT%"

goto menu

:: ===== set algorithm =====

:setalgorithm

cls
echo Current algorithm: %ALG%, default: SHA512
echo ==============================
echo Enter 0 to go back
echo 1. SHA1 (160-bit)
echo 2. SHA256 (256-bit)
echo 3. SHA384 (384-bit)
echo 4. SHA512 (512-bit)
echo 5. MD5 (128-bit)
echo ==============================

set "IPSET_SOURCE_INPUT=0"
set /p IPSET_SOURCE_INPUT=Enter the new algorithm: 

:: static commands

if "%IPSET_SOURCE_INPUT%"=="0" goto menu
if "%IPSET_SOURCE_INPUT%"=="1" call :switchalgorithm "SHA1"
if "%IPSET_SOURCE_INPUT%"=="2" call :switchalgorithm "SHA256"
if "%IPSET_SOURCE_INPUT%"=="3" call :switchalgorithm "SHA384"
if "%IPSET_SOURCE_INPUT%"=="4" call :switchalgorithm "SHA512"
if "%IPSET_SOURCE_INPUT%"=="5" call :switchalgorithm "MD5"

:switchalgorithm
echo %~1> %~dp0utils\HashAlgorithm
goto menu

:: ===== verify all files =====

:verifyall

cls
call :getalgorithm
if exist "%~dp0bin/winws.exe" (
    call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/winws.%ALG%" "%~dp0bin/winws.exe" "winws.exe"
)
if exist "%~dp0bin/WinDivert64.sys" (
    call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/windivert64.%ALG%" "%~dp0bin/WinDivert64.sys" "WinDivert64.sys"
)
if exist "%~dp0bin/WinDivert.dll" (
    call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/windivert.%ALG%" "%~dp0bin/WinDivert.dll" "WinDivert.dll"
)
if exist "%~dp0bin/cygwin1.dll" (
    call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/cygwin1.%ALG%" "%~dp0bin/cygwin1.dll" "cygwin1.dll"
)
pause
goto menu

:: switch verify files

:verifyfilesparam

cls
if not exist "%~dp0utils\VerifyFiles" (
    echo Enabling...
    echo ENABLED > "%~dp0utils\VerifyFiles"
) else (
    echo Disabling...
    del /f /q "%~dp0utils\VerifyFiles"
)
pause
goto menu

:: ===== function: get download sources =====

:getsources

set /p IPSET_SOURCE=<%~dp0\utils\IPSetSource
set /p LIST_SOURCE=<%~dp0\utils\ListSource
exit /b

:: ===== function: get hash algorithm =====

:getalgorithm

set /p ALG=<%~dp0\utils\HashAlgorithm
exit/b

:: ===== function: download file =====

:downloadfile

:: call :downloadfile (uri) (destination) (name)
:: call :downloadfile "github.com/example.txt" "bin/example.bin" "Example" 

echo Downloading %~3...
echo Source: %~1
powershell -NoProfile -Command "Start-BitsTransfer -Source \"%~1\" -Destination \"%~2\" -DisplayName \"%~3\" -Description \" \""
exit /b

:: ===== function: verify file hash =====

:verifyfile

:: call :verifyfile (hash uri) (file to verify) (name)
:: call :verifyfile "github.com/example.%ALG%" "bin/example.bin" "Example"

echo Verifying %~3...
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Invoke-WebRequest -Uri \"%~1\" -Headers @{\"Cache-Control\"=\"no-cache\"} -UseBasicParsing -TimeoutSec 5).Content.Trim()" 2^>nul') do set "CORRECTHASH=%%A"

for /f "tokens=2 delims=: " %%A in ('powershell -NoProfile -Command "Get-FileHash %~2 -Algorithm %ALG% | Format-List -Property Hash"') do set "LOCALHASH=%%A"
if not defined CORRECTHASH (
    call :PrintYellow "Could not reach %~1 to verify %~3. Your hash: %LOCALHASH%"
    exit /b
)
if "%LOCALHASH%"=="%CORRECTHASH%" (
    call :PrintGreen "%~3 successfully verified. Hash: %LOCALHASH%"
) else (
    call :PrintRed "%~3 failed the verification. File might be damaged or the correct hash has not been updated yet. Your hash: %LOCALHASH%, Correct hash: %CORRECTHASH%"
    pause
)
exit /b
