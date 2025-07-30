:: https://github.com/Flowseal/zapret-discord-youtube
:: https://github.com/V3nilla/IPSets-For-Bypass-in-Russia
:: https://github.com/Flowseal/zapret-discord-youtube/discussions/3279
:: https://github.com/bol-van/rulist
:: https://steamcommunity.com/sharedfiles/filedetails/?id=3496724173

@echo off
title shizapret

cd /d "%~dp0"

call service.bat status_zapret

call service.bat load_game_filter

if not exist "bin/cygwin1.dll" (
    call calls.bat bin
)

if not exist "lists/list-general.txt" (
    call calls.bat list
)

if not exist "lists/ipset-all.txt" (
    call calls.bat ips
)

if exist "params/AutoUpdater/AutoUpdate1" (
    call calls.bat et
)

cls

call service.bat check_updates

chcp 65001 >nul
echo Требуются права администратора...

set "BIN=%~dp0bin\"
set "LISTS=%~dp0lists\"
cd /d %BIN%

start "shizapret: alt" /min "%BIN%winws.exe" --wf-tcp=80,443 --wf-udp=443,50000-50099,0-65535,%GameFilter% ^

--comment Discord(Calls) --filter-udp=50000-50099 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord=0x00 --dpi-desync-fake-stun=0x00 --dpi-desync-repeats=6 --new ^

--comment Discord --filter-tcp=443 --hostlist="%LISTS%list-discord.txt" --hostlist-domains=cdn.discordapp.com,gateway.discord.gg,images-ext-1.discordapp.net,media.discordapp.net --dpi-desync=fake --dpi-desync-fake-tls-mod=none --dpi-desync-repeats=6 --dpi-desync-fooling=md5sig,hopbyhop2 --new ^

--comment QUIC --filter-udp=443 --hostlist="%LISTS%list-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment YouTube(Streaming) --filter-tcp=80 --hostlist="%LISTS%list-general.txt" --dpi-desync=fake,multisplit --dpi-desync-fooling=md5sig,hopbyhop2 --new ^

--filter-tcp=443 --hostlist="%LISTS%list-general.txt" --hostlist-exclude="%LISTS%list-discord.txt" --dpi-desync=multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-repeats=2 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment Cloudflare WARP(1.1.1.1, 1.0.0.1) --filter-tcp=443 --ipset-ip=162.159.36.1,162.159.46.1,2606:4700:4700::1111,2606:4700:4700::1001 --filter-l7=tls --dpi-desync=fake --dpi-desync-fake-tls=0x00 --dpi-desync-start=n2 --dpi-desync-cutoff=n3 --dpi-desync-fooling=md5sig,hopbyhop2 --new ^

--comment WireGuard --filter-udp=0-65535 --filter-l7=wireguard --dpi-desync=fake --dpi-desync-fake-wireguard=0x00 --dpi-desync-cutoff=n2 --new ^

--filter-udp=50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6 --new ^

--filter-udp=443 --ipset="%LISTS%ipset-all.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--filter-tcp=80 --ipset="%LISTS%ipset-all.txt" --dpi-desync=fake,multisplit --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^

--filter-tcp=443,%GameFilter% --ipset="%LISTS%ipset-all.txt" --dpi-desync=fake,multidisorder --dpi-desync-split-pos=1,midsld --dpi-desync-repeats=11 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls-mod=rnd,dupsid,sni=www.google.com --new ^

--filter-udp=%GameFilter% --ipset="%LISTS%ipset-all.txt" --dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=10 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin" --dpi-desync-cutoff=n2

