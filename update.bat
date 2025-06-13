:: shizapret

@echo off
cd /d "%~dp0"

:: external calls
if "%~1"=="list" (
    call :list
    exit /b
)

if "%~1"=="cf" (
    call :cf
    exit /b
)

if "%~1"=="bin" (
    call :bin
    exit /b
)

:menu
cls
echo 0. Everything
echo 1. IP Set
echo 2. List
echo 3. Bin Folder
set /p upd=Update (0-3):

if "%upd%"=="0" goto et
if "%upd%"=="1" goto cf
if "%upd%"=="2" goto list
if "%upd%"=="3" goto bin
:cf
cls
echo Downloading ipset-cloudflare.txt...
powershell -Command "Start-BitsTransfer -Source https://raw.githubusercontent.com/V3nilla/IPSets-For-Bypass-in-Russia/refs/heads/main/ipset-cloudflare.txt -Destination lists"
exit /b

:bin
cls
echo Downloading winws.exe...
powershell -Command "Start-BitsTransfer -Source https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/winws.exe -Destination bin"
cls
echo Downloading WinDivert.dll...
powershell -Command "Start-BitsTransfer -Source https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/WinDivert.dll -Destination bin"
cls
echo Downloading WinDivert64.sys...
powershell -Command "Start-BitsTransfer -Source https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/WinDivert64.sys -Destination bin"
cls
echo Downloading cygwin1.dll...
powershell -Command "Start-BitsTransfer -Source https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/cygwin1.dll -Destination bin"
exit /b

:list
cls
echo Downloading list-general.txt...
powershell -Command "Start-BitsTransfer -Source https://p.thenewone.lol/domains-export.txt -Destination lists/list-general.txt"
echo cloudflare-ech.com>> lists/list-general.txt
echo dis.gd>> lists/list-general.txt
echo discord-attachments-uploads-prd.storage.googleapis.com>> lists/list-general.txt
echo discord.app>> lists/list-general.txt
echo discord.co>> lists/list-general.txt
echo discord.com>> lists/list-general.txt
echo discord.design>> lists/list-general.txt
echo discord.dev>> lists/list-general.txt
echo discord.gift>> lists/list-general.txt
echo discord.gifts>> lists/list-general.txt
echo discord.gg>> lists/list-general.txt
echo discord.media>> lists/list-general.txt
echo discord.new>> lists/list-general.txt
echo discord.store>> lists/list-general.txt
echo discord.status>> lists/list-general.txt
echo discord-activities.com>> lists/list-general.txt
echo discordactivities.com>> lists/list-general.txt
echo discordapp.com>> lists/list-general.txt
echo discordapp.net>> lists/list-general.txt
echo discordcdn.com>> lists/list-general.txt
echo discordmerch.com>> lists/list-general.txt
echo discordpartygames.com>> lists/list-general.txt
echo discordsays.com>> lists/list-general.txt
echo discordsez.com>> lists/list-general.txt
echo ggpht.com>> lists/list-general.txt
echo googlevideo.com>> lists/list-general.txt
echo jnn-pa.googleapis.com>> lists/list-general.txt
echo stable.dl2.discordapp.net>> lists/list-general.txt
echo wide-youtube.l.google.com>> lists/list-general.txt
echo youtube-nocookie.com>> lists/list-general.txt
echo youtube-ui.l.google.com>> lists/list-general.txt
echo youtube.com>> lists/list-general.txt
echo youtubeembeddedplayer.googleapis.com>> lists/list-general.txt
echo youtubekids.com>> lists/list-general.txt
echo youtubei.googleapis.com>> lists/list-general.txt
echo youtu.be>> lists/list-general.txt
echo yt-video-upload.l.google.com>> lists/list-general.txt
echo ytimg.com>> lists/list-general.txt
echo ytimg.l.google.com>> lists/list-general.txt
echo frankerfacez.com>> lists/list-general.txt
echo ffzap.com>> lists/list-general.txt
echo betterttv.net>> lists/list-general.txt
echo 7tv.app>> lists/list-general.txt
echo 7tv.io>> lists/list-general.txt
exit /b

:et
cls
echo Downloading winws.exe...
powershell -Command "Start-BitsTransfer -Source https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/winws.exe -Destination bin"
cls
echo Downloading WinDivert.dll...
powershell -Command "Start-BitsTransfer -Source https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/WinDivert.dll -Destination bin"
cls
echo Downloading WinDivert64.sys...
powershell -Command "Start-BitsTransfer -Source https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/WinDivert64.sys -Destination bin"
cls
echo Downloading cygwin1.dll...
powershell -Command "Start-BitsTransfer -Source https://github.com/bol-van/zapret-win-bundle/raw/refs/heads/master/zapret-winws/cygwin1.dll -Destination bin"
cls
echo Downloading ipset-cloudflare.txt...
powershell -Command "Start-BitsTransfer -Source https://raw.githubusercontent.com/V3nilla/IPSets-For-Bypass-in-Russia/refs/heads/main/ipset-cloudflare.txt -Destination lists"
cls
echo Downloading list-general.txt...
powershell -Command "Start-BitsTransfer -Source https://p.thenewone.lol/domains-export.txt -Destination lists/list-general.txt"
echo cloudflare-ech.com>> lists/list-general.txt
echo dis.gd>> lists/list-general.txt
echo discord-attachments-uploads-prd.storage.googleapis.com>> lists/list-general.txt
echo discord.app>> lists/list-general.txt
echo discord.co>> lists/list-general.txt
echo discord.com>> lists/list-general.txt
echo discord.design>> lists/list-general.txt
echo discord.dev>> lists/list-general.txt
echo discord.gift>> lists/list-general.txt
echo discord.gifts>> lists/list-general.txt
echo discord.gg>> lists/list-general.txt
echo discord.media>> lists/list-general.txt
echo discord.new>> lists/list-general.txt
echo discord.store>> lists/list-general.txt
echo discord.status>> lists/list-general.txt
echo discord-activities.com>> lists/list-general.txt
echo discordactivities.com>> lists/list-general.txt
echo discordapp.com>> lists/list-general.txt
echo discordapp.net>> lists/list-general.txt
echo discordcdn.com>> lists/list-general.txt
echo discordmerch.com>> lists/list-general.txt
echo discordpartygames.com>> lists/list-general.txt
echo discordsays.com>> lists/list-general.txt
echo discordsez.com>> lists/list-general.txt
echo ggpht.com>> lists/list-general.txt
echo googlevideo.com>> lists/list-general.txt
echo jnn-pa.googleapis.com>> lists/list-general.txt
echo stable.dl2.discordapp.net>> lists/list-general.txt
echo wide-youtube.l.google.com>> lists/list-general.txt
echo youtube-nocookie.com>> lists/list-general.txt
echo youtube-ui.l.google.com>> lists/list-general.txt
echo youtube.com>> lists/list-general.txt
echo youtubeembeddedplayer.googleapis.com>> lists/list-general.txt
echo youtubekids.com>> lists/list-general.txt
echo youtubei.googleapis.com>> lists/list-general.txt
echo youtu.be>> lists/list-general.txt
echo yt-video-upload.l.google.com>> lists/list-general.txt
echo ytimg.com>> lists/list-general.txt
echo ytimg.l.google.com>> lists/list-general.txt
echo frankerfacez.com>> lists/list-general.txt
echo ffzap.com>> lists/list-general.txt
echo betterttv.net>> lists/list-general.txt
echo 7tv.app>> lists/list-general.txt
echo 7tv.io>> lists/list-general.txt
exit /b
