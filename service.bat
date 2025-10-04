@echo off
set "LOCAL_VERSION=1.7.1"

:: External commands
if "%~1"=="status_zapret" (
    call :test_service zapret soft
    call :tcp_enable
    exit /b
)

if "%~1"=="check_updates" (
    if not "%~2"=="soft" (
        start /b service check_updates soft
    ) else (
        call :service_check_updates soft
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
    echo Started with admin rights
) else (
    echo Requesting admin rights...
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"' -Verb RunAs"
    exit
)

:: MENU ================================
setlocal EnableDelayedExpansion
:menu
cls
call :ipset_switch_status
call :game_switch_status

set "menu_choice=null"

if "%~1"=="settings" (
    call :settings
    exit /b
)
echo =======================
echo =       v!LOCAL_VERSION!        =
echo =========Menu==========
echo 1. Install Service
echo 2. Remove Services
echo 3. Check Status
echo 4. Run Diagnostics
echo 5. Check Updates
echo 6. Switch Game Filter (%GameFilterStatus%)
echo 7. Switch ipset (%IPsetStatus%)
echo 0. Exit
echo ======shizapret========
echo 11. Update /bin/ Folder
echo 12. Update /lists/list-general.txt
echo 13. Update /lists/ipset-all.txt
echo 14. Update Everything
echo 15. Change Settings
echo 16. Switch Game Filter for TCP (Chats, Profile Pictures, etc.) (%GameFilterTCPStatus%)
echo 17. Verify All Files
set /p menu_choice=Enter choice (0-17): 

if "%menu_choice%"=="1" goto service_install
if "%menu_choice%"=="2" goto service_remove
if "%menu_choice%"=="3" goto service_status
if "%menu_choice%"=="4" goto service_diagnostics
if "%menu_choice%"=="5" goto service_check_updates
if "%menu_choice%"=="6" goto game_switch
if "%menu_choice%"=="7" goto ipset_switch
if "%menu_choice%"=="0" exit /b
if "%menu_choice%"=="11" goto bin
if "%menu_choice%"=="12" goto list
if "%menu_choice%"=="13" goto ips
if "%menu_choice%"=="14" goto et
if "%menu_choice%"=="15" goto settings
if "%menu_choice%"=="16" goto game_switch_tcp
if "%menu_choice%"=="17" goto verifyall
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
echo:

tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
if !errorlevel!==0 (
    call :PrintGreen "Bypass (winws.exe) is ACTIVE"
) else (
    call :PrintRed "Bypass (winws.exe) NOT FOUND"
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
chcp 65001 > nul

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
for %%f in (*.bat) do (
    set "filename=%%~nxf"
    if /i not "!filename:~0,7!"=="service" (
          set /a count+=1
          echo !count!. %%f
          set "file!count!=%%f"
    )
)

:: Choosing file
set "choice="
set /p "choice=Input file index (number): "
if "!choice!"=="" goto :eof

set "selectedFile=!file%choice%!"
if not defined selectedFile (
    echo Invalid choice, exiting...
    pause
    goto menu
)

:: Args that should be followed by value
set "args_with_value=sni"

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
set "GITHUB_DOWNLOAD_URL=https://github.com/sch-izo/shizapret/releases/latest/download/shizapret-"

:: Get the latest version from GitHub
for /f "delims=" %%A in ('powershell -command "(Invoke-WebRequest -Uri \"%GITHUB_VERSION_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -TimeoutSec 5).Content.Trim()" 2^>nul') do set "GITHUB_VERSION=%%A"

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

set "CHOICE="
set /p "CHOICE=Do you want to install the new version? (Y/N) (default: Y) "
if "%CHOICE%"=="" set "CHOICE=Y"
if /i "%CHOICE%"=="y" set "CHOICE=Y"

if /i "%CHOICE%"=="Y" (
    cd /d "%~dp0"
    cls
    call :downloadfile "%GITHUB_DOWNLOAD_URL%%GITHUB_VERSION%.zip" "%~dp0" "shizapret-%GITHUB_VERSION%.zip"
    cls
    echo Extracting shizapret-%GITHUB_VERSION%.zip...
    powershell -Command "Expand-Archive 'shizapret-%GITHUB_VERSION%.zip' '%GITHUB_VERSION%'"
    del shizapret-%GITHUB_VERSION%.zip
    cls
    if exist "%GITHUB_VERSION%\shizapret.bat" (
    echo Update installed into "%~dp0%GITHUB_VERSION%".
    set "SERVICE_CHOICE="
    set /p "SERVICE_CHOICE=Do you want to automatically remove service? (Y/N) (default: Y) "
    if "%SERVICE_CHOICE%"=="" set "SERVICE_CHOICE=Y"
    if /i "%SERVICE_CHOICE%"=="y" set "SERVICE_CHOICE=Y"
    if /i "%SERVICE_CHOICE%"=="Y" (
        call :service_remove shizapret
    )
    ) else (
    call :PrintRed "Update was not installed."
    )
)


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

:: VPN
sc query | findstr /I "VPN" > nul
if !errorlevel!==0 (
    call :PrintYellow "[?] Some VPN services found. Some VPNs can conflict with zapret"
    call :PrintYellow "Make sure that all VPNs are disabled"
) else (
    call :PrintGreen "VPN check passed"
)
echo:

:: DNS
set "dnsfound=0"
for /f "delims=" %%a in ('powershell -Command "Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $true} | ForEach-Object {$_.DNSServerSearchOrder} | Where-Object {$_ -match '^192\.168\.'} | Measure-Object | Select-Object -ExpandProperty Count"') do (
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
for /f "delims=" %%a in ('powershell -Command "Get-ChildItem -Recurse -Path 'HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\' | Get-ItemProperty | Where-Object { $_.DohFlags -gt 0 } | Measure-Object | Select-Object -ExpandProperty Count"') do (
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
    if !errorlevel! neq 0 (
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

set "gameFlagFile=%~dp0bin\game_filter.enabled"

if exist "%gameFlagFile%" (
    set "GameFilterStatus=enabled"
    set "GameFilter=1024-65535"
) else (
    set "GameFilterStatus=disabled"
    set "GameFilter=12"
)

set "gameTCPFlagFile=%~dp0bin\game_filtertcp.enabled"

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


:: IPSET SWITCH =======================
:ipset_switch_status
chcp 437 > nul

findstr /R "^203\.0\.113\.113/32$" "%~dp0lists\ipset-all.txt" >nul
if !errorlevel!==0 (
    set "IPsetStatus=empty"
) else (
    set "IPsetStatus=loaded"
)
exit /b


:ipset_switch
chcp 437 > nul
cls

set "listFile=%~dp0lists\ipset-all.txt"
set "backupFile=%listFile%.backup"

findstr /R "^203\.0\.113\.113/32$" "%listFile%" >nul
if !errorlevel!==0 (
    echo Enabling ipset based bypass...

    if exist "%backupFile%" (
        del /f /q "%listFile%"
        ren "%backupFile%" "ipset-all.txt"
    ) else (
        echo Error: no backup to restore. Update list from service menu by yourself
    )

) else (
    echo Disabling ipset based bypass...

    if not exist "%backupFile%" (
        ren "%listFile%" "ipset-all.txt.backup"
    ) else (
        del /f /q "%backupFile%"
        ren "%listFile%" "ipset-all.txt.backup"
    )

    >"%listFile%" (
        echo 203.0.113.113/32
    )
)

pause
goto menu

:: Utility functions

:PrintGreen
powershell -Command "Write-Host \"%~1\" -ForegroundColor Green"
exit /b

:PrintRed
powershell -Command "Write-Host \"%~1\" -ForegroundColor Red"
exit /b

:PrintYellow
powershell -Command "Write-Host \"%~1\" -ForegroundColor Yellow"
exit /b

:: ===== shizapret =====

:: ===== updater: ipset =====

:ips
cd /d "%~dp0"
call :getsources
cls
call :downloadfile "%IPSET_SOURCE%" "lists/ipset-all.txt" "ipset-all.txt"
if "%~1"=="ext" exit /b
pause
goto menu

:: ===== updater: bin =====

:bin
cd /d "%~dp0"
if exist "params/Updater/EverythingWinws1" (
    cls
    call :downloadfile "https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/winws.exe" "bin" "winws.exe"
    if exist params/Updater/VerifyFiles1 (
        call :getalgorithm
        call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/winws.%ALG%" "%~dp0bin/winws.exe" "winws.exe"
    )
)
if exist "params/Updater/EverythingWinDivert1" (
    cls
    call :downloadfile "https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/WinDivert.dll" "bin" "WinDivert.dll"
    if exist params/Updater/VerifyFiles1 (
        call :getalgorithm
        call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/windivert64.%ALG%" "%~dp0bin/WinDivert64.sys" "WinDivert64.sys"
    )
)
if exist "params/Updater/EverythingWinDivert641" (
    cls
    call :downloadfile "https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/WinDivert64.sys" "bin" "WinDivert64.sys"
    if exist params/Updater/VerifyFiles1 (
        call :getalgorithm
        call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/windivert.%ALG%" "%~dp0bin/WinDivert.dll" "WinDivert.dll"
    )
)
if exist "params/Updater/EverythingCygwin11" (
    cls
    call :downloadfile "https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/cygwin1.dll" "bin" "cygwin1.dll"
    if exist params/Updater/VerifyFiles1 (
        call :getalgorithm
        call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/cygwin1.%ALG%" "%~dp0bin/cygwin1.dll" "cygwin1.dll"    )
)
if "%~1"=="ext" exit /b
pause
goto menu

:: ===== updater: list =====

:list
cd /d "%~dp0"
call :getsources
cls
call :downloadfile "%LIST_SOURCE%" "lists\list-general.txt" "list-general.txt"
if "%~1"=="ext" exit /b
pause
goto menu

:: ===== updater: everything =====

:et
cd /d "%~dp0"
cls
call :bin
if exist "params/Updater/EverythingIPSet1" (
    cls
    call :ips
)
if exist "params/Updater/EverythingList1" (
    cls
    call :list
)
pause
goto menu

:: ===== settings =====

:settings
setlocal EnableDelayedExpansion
cd /d "%~dp0"
cls

:: check settings

call :getsources

if not exist "params/AutoUpdater/AutoUpdate1" (
    set "autoupdate=Disabled"
) else (
    set "autoupdate=Enabled"
)

if not exist "params/Updater/EverythingCygwin11" (
    set "cygwin1=Disabled"
) else (
    set "cygwin1=Enabled"
)

if not exist "params/Updater/EverythingWinDivert1" (
    set "windivert=Disabled"
) else (
    set "windivert=Enabled"
)

if not exist "params/Updater/EverythingWinDivert641" (
    set "windivert64=Disabled"
) else (
    set "windivert64=Enabled"
)

if not exist "params/Updater/EverythingWinws1" (
    set "winws=Disabled"
) else (
    set "winws=Enabled"
)

if not exist "params/Updater/EverythingIPSet1" (
    set "ipset=Disabled"
) else (
    set "ipset=Enabled"
)

if not exist "params/Updater/EverythingList1" (
    set "general=Disabled"
) else (
    set "general=Enabled"
)

if not exist "params/Updater/VerifyFiles1" (
    set "verifywhenupdate=Disabled"
) else (
    set "verifywhenupdate=Enabled"
)


echo Receiving default download sources...

if not defined defaultipsetsource (
for /f "delims=" %%A in ('powershell -command "(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/params/DownloadSources/IPSetSource" -TimeoutSec 5).Content.Trim()" 2^>nul') do set "defaultipsetsource=%%A"
)

if not defined defaultlistsource (
for /f "delims=" %%A in ('powershell -command "(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/params/DownloadSources/ListSource" -TimeoutSec 5).Content.Trim()" 2^>nul') do set "defaultlistsource=%%A"
)

call :getalgorithm

cls

set "listdefault="
if "%LIST_SOURCE%"=="%defaultlistsource%" set "listdefault=(Default)"

set "ipsetdefault="
if "%IPSET_SOURCE%"=="%defaultipsetsource%" set "ipsetdefault=(Default)"

set "settings_choice=null"
if not defined defaultipsetsource (
    set "defaultipsetsource=https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/ipset-all.txt"
    echo Could not receive the default IP Set source! Fell back to "%defaultipsetsource%".
)
if not defined defaultlistsource (
    set "defaultlistsource=https://raw.githubusercontent.com/bol-van/rulist/refs/heads/main/reestr_hostname.txt"
    echo Could not receive the default list source! Fell back to "%defaultlistsource%".
)
echo =======Settings========
echo 1. Update on start: %autoupdate%
echo 2. Update cygwin1.dll: %cygwin1%
echo 3. Update WinDivert.dll: %windivert%
echo 4. Update WinDivert64.sys: %windivert64%
echo 5. Update winws.exe: %winws%
echo 6. Update ipset-all.txt: %ipset%
echo 7. Update list-general.txt: %general%
echo 8. Verify files when updating: %verifywhenupdate%
echo 9. list-general.txt Source: %LIST_SOURCE% %listdefault%
echo 10. ipset-all Source: %IPSET_SOURCE% %ipsetdefault%
echo 11. Verifier Hash Algorithm: %ALG%
echo 0. Back
set /p settings_choice=Change Setting: 

if "%settings_choice%"=="1" call :switchsetting "params\AutoUpdater\AutoUpdate1"
if "%settings_choice%"=="2" call :switchsetting "params\Updater\EverythingCygwin11"
if "%settings_choice%"=="3" call :switchsetting "params\Updater\EverythingWinDivert1"
if "%settings_choice%"=="4" call :switchsetting "params\Updater\EverythingWinDivert641"
if "%settings_choice%"=="5" call :switchsetting "params\Updater\EverythingWinws1"
if "%settings_choice%"=="6" call :switchsetting "params\Updater\EverythingIPSet1"
if "%settings_choice%"=="7" call :switchsetting "params\Updater\EverythingList1"
if "%settings_choice%"=="8" call :switchsetting "params\Updater\VerifyFiles1"
if "%settings_choice%"=="9" goto setlistsource
if "%settings_choice%"=="10" goto setipsetsource
if "%settings_choice%"=="11" goto setalgorithm
if "%settings_choice%"=="0" goto menu
goto settings

:switchsetting
if not exist "%~1" (
    echo ENABLED > "%~1"
) else (
    del /f /q "%~1"
)
goto settings

:: ===== set ipset source =====

:setipsetsource

echo Receiving the default IP Set download source...

if not defined defaultipsetsource (
for /f "delims=" %%A in ('powershell -command "(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/params/DownloadSources/IPSetSource" -TimeoutSec 5).Content.Trim()" 2^>nul') do set "defaultipsetsource=%%A"
)

if not defined defaultipsetsource (
    set "defaultipsetsource=https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/ipset-all.txt"
    echo Could not receive the default IP Set source! Fell back to "%defaultipsetsource%".
)

cls
echo Current source: %IPSET_SOURCE% %ipsetdefault%
echo ==============================
echo Enter 0 to go back
echo Enter 1 to reset to default
echo ==============================

set "IPSET_SOURCE_INPUT=0"
set /p IPSET_SOURCE_INPUT=Enter the new ipset-all.txt source (link, starts with http(s)://): 

:: static commands

if "%IPSET_SOURCE_INPUT%"=="0" goto settings
if "%IPSET_SOURCE_INPUT%"=="1" set "IPSET_SOURCE_INPUT=%defaultipsetsource%"

:: set source

echo %IPSET_SOURCE_INPUT%> params/DownloadSources/IPSetSource
set "IPSET_SOURCE=%IPSET_SOURCE_INPUT%"

goto settings

:: ===== set list source =====

:setlistsource

echo Receiving the default list download source...

if not defined defaultlistsource (
for /f "delims=" %%A in ('powershell -command "(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/params/DownloadSources/ListSource" -TimeoutSec 5).Content.Trim()" 2^>nul') do set "defaultlistsource=%%A"
)

if not defined defaultlistsource (
    set "defaultlistsource=https://raw.githubusercontent.com/bol-van/rulist/refs/heads/main/reestr_hostname.txt"
    echo Could not receive the default list source! Fell back to "%defaultlistsource%".
)

cls
echo Current source: %LIST_SOURCE% %listdefault%
echo ==============================
echo Enter 0 to go back
echo Enter 1 to reset to default
echo ==============================

set "LIST_SOURCE_INPUT=0"
set /p LIST_SOURCE_INPUT=Enter the new list-general.txt source (link, starts with http(s)://): 

:: static commands

if "%LIST_SOURCE_INPUT%"=="0" goto settings
if "%LIST_SOURCE_INPUT%"=="1" set "LIST_SOURCE_INPUT=%defaultlistsource%"

:: set source

echo %LIST_SOURCE_INPUT%> params/DownloadSources/ListSource
set "LIST_SOURCE=%LIST_SOURCE_INPUT%"

goto settings

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

if "%IPSET_SOURCE_INPUT%"=="0" goto settings
if "%IPSET_SOURCE_INPUT%"=="1" call :switchalgorithm "SHA1"
if "%IPSET_SOURCE_INPUT%"=="2" call :switchalgorithm "SHA256"
if "%IPSET_SOURCE_INPUT%"=="3" call :switchalgorithm "SHA384"
if "%IPSET_SOURCE_INPUT%"=="4" call :switchalgorithm "SHA512"
if "%IPSET_SOURCE_INPUT%"=="5" call :switchalgorithm "MD5"

:switchalgorithm
echo %~1> %~dp0params/Verifier/HashAlgorithm
goto settings
:: ===== verify all files =====

:verifyall

cls
call :getalgorithm
call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/winws.%ALG%" "%~dp0bin/winws.exe" "winws.exe"
call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/windivert64.%ALG%" "%~dp0bin/WinDivert64.sys" "WinDivert64.sys"
call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/windivert.%ALG%" "%~dp0bin/WinDivert.dll" "WinDivert.dll"
call :verifyfile "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/.service/hashes/cygwin1.%ALG%" "%~dp0bin/cygwin1.dll" "cygwin1.dll"
pause
goto menu

:: ===== function: get download sources =====

:getsources

set /p IPSET_SOURCE=<%~dp0params/DownloadSources/IPSetSource
set /p LIST_SOURCE=<%~dp0params/DownloadSources/ListSource
exit /b

:: ===== function: get hash algorithm =====

:getalgorithm

set /p ALG=<%~dp0params/Verifier/HashAlgorithm
exit/b

:: ===== function: download file =====

:downloadfile

:: call :downloadfile (uri) (destination) (name)
:: call :downloadfile "github.com/example.txt" "bin/example.bin" "Example" 

echo Downloading %~3...
echo Source: %~1
powershell -Command "Start-BitsTransfer -Source \"%~1\" -Destination \"%~2\""
exit /b

:: ===== function: verify file hash =====

:verifyfile

:: call :verifyfile (hash uri) (file to verify) (name)
:: call :verifyfile "github.com/example.%ALG%" "bin/example.bin" "Example"

echo Verifying %~3...
for /f "delims=" %%A in ('powershell -Command "(Invoke-WebRequest -Uri \"%~1\" -Headers @{\"Cache-Control\"=\"no-cache\"} -TimeoutSec 5).Content.Trim()" 2^>nul') do set "CORRECTHASH=%%A"

for /f "tokens=2 delims=: " %%A in ('powershell -Command "Get-FileHash %~2 -Algorithm %ALG% | Format-List -Property Hash"') do set "LOCALHASH=%%A"
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
