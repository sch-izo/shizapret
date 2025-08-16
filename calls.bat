@echo off
:: shizapret
cd /d "%~dp0"

if "%~1"=="list" (
    call :list
    exit /b
)

if "%~1"=="ips" (
    call :ips
    exit /b
)

if "%~1"=="bin" (
    call :bin
    exit /b
)

if "%~1"=="et" (
    call :et
    exit /b
)

if "%~1"=="settings" (
    call :settings
    exit /b
)

powershell -Command "Write-Host "This file is used for external commands only." -ForegroundColor Red"
pause >nul
exit /b

:: ===== updater: ipset =====

:ips
call :getsources
cls
echo Downloading ipset-cloudflare.txt...
powershell -Command "Start-BitsTransfer -Source %IPSET_SOURCE% -Destination lists/ipset-all.txt"
exit /b

:: ===== updater: bin =====

:bin
if exist "params/Updater/EverythingWinws1" (
    cls
    echo Downloading winws.exe...
    powershell -Command "Start-BitsTransfer -Source https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/winws.exe -Destination bin"
)
if exist "params/Updater/EverythingWinDivert1" (
    cls
    echo Downloading WinDivert.dll...
    powershell -Command "Start-BitsTransfer -Source https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/WinDivert.dll -Destination bin"
)
if exist "params/Updater/EverythingWinDivert641" (
    cls
    echo Downloading WinDivert64.sys...
    powershell -Command "Start-BitsTransfer -Source https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/WinDivert64.sys -Destination bin"
)
if exist "params/Updater/EverythingCygwin11" (
    cls
    echo Downloading cygwin1.dll...
    powershell -Command "Start-BitsTransfer -Source https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/cygwin1.dll -Destination bin"
)
exit /b

:: ===== updater: list =====

:list
call :getsources
cls
echo Downloading list-general.txt...
powershell -Command "Start-BitsTransfer -Source %LIST_SOURCE% -Destination lists/list-general.txt"
>>"lists/list-general.txt" (
    echo discord.app
    echo discord.co
    echo discord.com
    echo discord.design
    echo discord.dev
    echo discord.gift
    echo discord.gifts
    echo discord.gg
    echo discord.media
    echo discord.new
    echo discord.store
    echo discord.status
    echo discord-activities.com
    echo discordactivities.com
    echo discordapp.com
    echo discordapp.net
    echo discordcdn.com
    echo discordmerch.com
    echo discordpartygames.com
    echo discordsays.com
    echo discordsez.com
    echo ggpht.com
    echo googlevideo.com
    echo jnn-pa.googleapis.com
    echo stable.dl2.discordapp.net
    echo wide-youtube.l.google.com
    echo youtube-nocookie.com
    echo youtube-ui.l.google.com
    echo youtube.com
    echo youtubeembeddedplayer.googleapis.com
    echo youtubekids.com
    echo youtubei.googleapis.com
    echo youtu.be
    echo yt-video-upload.l.google.com
    echo ytimg.com
    echo ytimg.l.google.com
    echo frankerfacez.com
    echo ffzap.com
    echo betterttv.net
    echo 7tv.app
    echo 7tv.io
    echo signin.aws.amazon.com
    echo cloudfront.net
    echo s3.amazonaws.com
    echo awsstatic.com
    echo console.aws.a2z.com
    echo amazonaws.com
    echo awsapps.com
    echo sso.amazonaws.com
    echo cloudfront.net
    echo deadbydaylight.com
    echo deadbydaylight.fandom.com
    echo argotunnel.com
    echo ipsargotunnel.com
    echo ipsl.re
    echo cloudflare-dns.com
    echo cloudflare-ech.com
    echo cloudflare-esni.com
    echo cloudflare-gateway.com
    echo cloudflare-quic.com
    echo cloudflare.com
    echo cloudflare.net
    echo cloudflare.tv
    echo cloudflareaccess.com
    echo cloudflareapps.com
    echo cloudflarebolt.com
    echo cloudflareclient.com
    echo cloudflareinsights.com
    echo cloudflareok.com
    echo cloudflarepartners.com
    echo cloudflareportal.com
    echo cloudflarepreview.com
    echo cloudflareresolve.com
    echo cloudflaressl.com
    echo cloudflarestatus.com
    echo cloudflarestorage.com
    echo cloudflarestream.com
    echo cloudflaretest.com
    echo cloudflarewarp.com
    echo every1dns.net
    echo isbgpsafeyet.com
    echo one.one.one.one
    echo one.one.one
    echo pacloudflare.com
    echo pages.dev
    echo trycloudflare.com
    echo videodelivery.net
    echo warp.plus
    echo workers.dev
    echo yt4.ggpht.com
    echo yt3.googleusercontent.com
    echo cdnjs.cloudflare.com
    echo newgrounds.com
    echo ngcdn.com
    echo adguard.com
    echo adguard-vpn.com
    echo totallyacdn.com
    echo whiskergalaxy.com
    echo windscribe.com
    echo windscribe.net
    echo cloudflareclient.com
    echo sndcdn.com
    echo soundcloud.cloud
    echo nexusmods.com
    echo nexus-cdn.com
    echo supporter-files.nexus-cdn.com
    echo prostovpn.org
    echo hitmotop.com
)
exit /b

:: ===== updater: everything =====

:et
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
exit /b

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

echo Receiving default download sources...

if not defined defaultipsetsource (
for /f "delims=" %%A in ('powershell -command "(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/params/DownloadSources/IPSetSource" -TimeoutSec 5).Content.Trim()" 2^>nul') do set "defaultipsetsource=%%A"
)

if not defined defaultlistsource (
for /f "delims=" %%A in ('powershell -command "(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/params/DownloadSources/ListSource" -TimeoutSec 5).Content.Trim()" 2^>nul') do set "defaultlistsource=%%A"
)

cls

set "listdefault="
if "%LIST_SOURCE%"=="%defaultlistsource%" set "listdefault=(Default)"

set "ipsetdefault="
if "%IPSET_SOURCE%"=="%defaultipsetsource%" set "ipsetdefault=(Default)"

set "settings_choice=null"
if not defined defaultipsetsource (
    set "defaultipsetsource=https://raw.githubusercontent.com/V3nilla/IPSets-For-Bypass-in-Russia/refs/heads/main/ipset-cloudflare.txt"
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
echo 7. Update list-general.txt %general%
echo 8. list-general.txt Source: %LIST_SOURCE% %listdefault%
echo 9. ipset-all Source: %IPSET_SOURCE% %ipsetdefault%
echo 0. Back
set /p settings_choice=Change Setting: 

if "%settings_choice%"=="1" goto autoupdate
if "%settings_choice%"=="2" goto cygwin1
if "%settings_choice%"=="3" goto windivert
if "%settings_choice%"=="4" goto windivert64
if "%settings_choice%"=="5" goto winws
if "%settings_choice%"=="6" goto ipset
if "%settings_choice%"=="7" goto general
if "%settings_choice%"=="8" goto setlistsource
if "%settings_choice%"=="9" goto setipsetsource
if "%settings_choice%"=="0" exit /b
goto settings

:autoupdate

if not exist "params/AutoUpdater/AutoUpdate1" (
    echo ENABLED > "params/AutoUpdater/AutoUpdate1"
) else (
    del /f /q "params\AutoUpdater\AutoUpdate1"
)

goto settings

:cygwin1

if not exist "params/Updater/EverythingCygwin11" (
    echo ENABLED > "params/Updater/EverythingCygwin11"
) else (
    del /f /q "params\Updater\EverythingCygwin11"
)

goto settings

:windivert

if not exist "params/Updater/EverythingWinDivert1" (
    echo ENABLED > "params/Updater/EverythingWinDivert1"
) else (
    del /f /q "params\Updater\EverythingWinDivert1"
)

goto settings

:windivert64

if not exist "params/Updater/EverythingWinDivert641" (
    echo ENABLED > "params/Updater/EverythingWinDivert641"
) else (
    del /f /q "params\Updater\EverythingWinDivert641"
)

goto settings

:winws

if not exist "params/Updater/EverythingWinws1" (
    echo ENABLED > "params/Updater/EverythingWinws1"
) else (
    del /f /q "params\Updater\EverythingWinws1"
)

goto settings

:ipset

if not exist "params/Updater/EverythingIPSet1" (
    echo ENABLED > "params/Updater/EverythingIPSet1"
) else (
    del /f /q "params\Updater\EverythingIPSet1"
)

goto settings

:general

if not exist "params/Updater/EverythingList1" (
    echo ENABLED > "params/Updater/EverythingList1"
) else (
    del /f /q "params\Updater\EverythingList1"
)

goto settings

:setipsetsource

echo Receiving the default IP Set download source...

if not defined defaultipsetsource (
for /f "delims=" %%A in ('powershell -command "(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/sch-izo/shizapret/refs/heads/main/params/DownloadSources/IPSetSource" -TimeoutSec 5).Content.Trim()" 2^>nul') do set "defaultipsetsource=%%A"
)

if not defined defaultipsetsource (
    set "defaultipsetsource=https://raw.githubusercontent.com/V3nilla/IPSets-For-Bypass-in-Russia/refs/heads/main/ipset-cloudflare.txt"
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

:: ===== function: get download source =====

:getsources

set /p IPSET_SOURCE=<%~dp0params/DownloadSources/IPSetSource
set /p LIST_SOURCE=<%~dp0params/DownloadSources/ListSource
exit /b
