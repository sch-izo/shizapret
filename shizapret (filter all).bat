:: shizapret.bat + filter all domains (excluding list-exclude and ipset-exclude and strategies for specific services)

:: https://github.com/Flowseal/zapret-discord-youtube
:: https://github.com/Flowseal/zapret-discord-youtube/discussions/3279
:: https://github.com/bol-van/rulist

@echo off
title %~n0
cd /d "%~dp0"

set "BIN=%~dp0bin\"
set "LISTS=%~dp0lists\"

call service.bat status_zapret
call service.bat load_game_filter

if not exist "%BIN%cygwin1.dll" call service.bat bin
if not exist "%LISTS%ipset-all.txt" call service.bat ips

call service.bat check_updates
call service.bat load_user_lists

cls
chcp 65001 >nul
:: 65001 - UTF-8

cd /d %BIN%
start "%~n0" /min "%BIN%winws.exe" --wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50100,%GameFilterUDP% ^

--comment QUIC --filter-l7=quic --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment Discord Voice --filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun,unknown --dpi-desync-any-protocol=1 --dpi-desync=fake --dpi-desync-fake-discord="%BIN%quic_initial_www_google_com.bin" --dpi-desync-fake-discord="%BIN%ACTIVE_DISCORD_UDP.bin" --dpi-desync-fake-stun="%BIN%ACTIVE_DISCORD_UDP.bin" --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin" --dpi-desync-fake-unknown-udp="%BIN%ACTIVE_DISCORD_UDP.bin" --dpi-desync-repeats=4 --new ^

--comment Discord --filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment Youtube --filter-tcp=443 --hostlist="%LISTS%list-google.txt" --ip-id=zero --dpi-desync=hostfakesplit --dpi-desync-fooling=ts --dpi-desync-hostfakesplit-mod=host=www.google.com --new ^

--comment List+extra domains (TCP 80, 443) --filter-tcp=80,443 --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=480 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=4 --dpi-desync-split-seqovl-pattern="%BIN%stun2.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin" --new ^

--comment ipset (UDP 443) --filter-udp=443 --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment ipset (TCP 80, 443, 8443) --filter-tcp=80,443,8443 --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --hostlist-exclude-domains=fonts.googleapis.com --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=480 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=4 --dpi-desync-split-seqovl-pattern="%BIN%stun2.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin" --new ^

--comment Game Filter (TCP) --filter-tcp=%GameFilterTCP% --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake,multisplit --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="%BIN%stun2.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin" --new ^

--comment Game Filter (UDP) --filter-udp=%GameFilterUDP% --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=5 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_4pda.to.bin" --dpi-desync-fake-unknown-udp="%BIN%ACTIVE_GAME_UDP.bin" --dpi-desync-cutoff=n4
