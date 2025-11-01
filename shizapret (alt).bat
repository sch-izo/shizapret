:: general (Dronatar)v4.3 (by Dronatar) + general (global-fix) (by V3nilla)

:: https://github.com/Flowseal/zapret-discord-youtube
:: https://github.com/V3nilla/IPSets-For-Bypass-in-Russia
:: https://github.com/Flowseal/zapret-discord-youtube/discussions/3279
:: https://github.com/bol-van/rulist
:: https://steamcommunity.com/sharedfiles/filedetails/?id=3496724173
:: https://github.com/Flowseal/zapret-discord-youtube/issues/5704

@echo off
title %~n0

cd /d "%~dp0"

call service.bat status_zapret

call service.bat load_game_filter

if not exist "bin/cygwin1.dll" (
    call service.bat bin
)

if exist "params/AutoUpdater/AutoUpdate1" (
    call service.bat et
)

cls

call service.bat check_updates

chcp 65001 >nul

set "BIN=%~dp0bin\"
set "LISTS=%~dp0lists\"
cd /d %BIN%

start "%~n0" /min "%BIN%winws.exe" --wf-tcp=80,443,853,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,1400,3478-3482,3484,3488,3489,3491-3493,3495-3497,19294-19344,50000-50100,%GameFilter%,0-65535 ^

--comment Telegram (WebRTC) --filter-udp=1400 --filter-l7=stun --dpi-desync=fake --dpi-desync-fake-stun=0x00 --new ^

--comment WhatsApp (WebRTC) [W.I.P.] --filter-udp=3478-3482,3484,3488,3489,3491-3493,3495-3497 --filter-l7=stun --dpi-desync=fake --dpi-desync-fake-stun=0x00 --dpi-desync-repeats=6 --new ^

--comment Cloudflare WARP Gateway(1.1.1.1, 1.0.0.1) --filter-tcp=443,853 --ipset-ip=162.159.36.1,162.159.46.1,2606:4700:4700::1111,2606:4700:4700::1001 --dpi-desync=syndata,fake --dpi-desync-cutoff=n3 --dpi-desync-fooling=badseq --new ^

--comment WireGuard handshake --filter-udp=0-65535 --filter-l7=wireguard --dpi-desync=fake --dpi-desync-fake-wireguard=0x00 --dpi-desync-repeats=4 --dpi-desync-cutoff=n2 --new ^

--filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6 --new ^

--filter-tcp=80 --dpi-desync=fake,multisplit --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^

--filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_4pda_to.bin" --new ^

--filter-tcp=443 --dpi-desync=multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_4pda_to.bin" --new ^

--filter-udp=443 --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--filter-tcp=%GameFilterTCP% --dpi-desync=multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_4pda_to.bin" --new ^

--filter-udp=%GameFilter% --dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin" --dpi-desync-cutoff=n2
