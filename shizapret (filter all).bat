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

call service.bat check_updates
call service.bat load_user_lists

cls
chcp 65001 >nul
:: 65001 - UTF-8

cd /d %BIN%
start "%~n0" /min "%BIN%winws.exe" --wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,49152-65535,50000-50100,%GameFilterUDP% ^

--comment QUIC --filter-udp=443 --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment Discord Voice --filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="%BIN%quic_initial_dbankcloud_ru.bin" --dpi-desync-fake-stun="%BIN%quic_initial_dbankcloud_ru.bin" --dpi-desync-repeats=6 --new ^

--comment Discord --filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=hostfakesplit --dpi-desync-repeats=4 --dpi-desync-fooling=ts --dpi-desync-hostfakesplit-mod=host=www.google.com --new ^

--comment YouTube --filter-tcp=443 --hostlist="%LISTS%list-google.txt" --ip-id=zero --dpi-desync=hostfakesplit --dpi-desync-repeats=4 --dpi-desync-fooling=ts --dpi-desync-hostfakesplit-mod=host=www.google.com --new ^

--comment List+extra domains (TCP 80, 443) --filter-tcp=80,443 --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=hostfakesplit --dpi-desync-repeats=4 --dpi-desync-fooling=ts,md5sig --dpi-desync-hostfakesplit-mod=host=ozon.ru --new ^

--comment ipset (UDP 443) --filter-udp=443 --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment ipset (TCP 80, 443, 8443) --filter-tcp=80,443,8443 --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=hostfakesplit --dpi-desync-repeats=4 --dpi-desync-fooling=ts --dpi-desync-hostfakesplit-mod=host=ozon.ru --new ^

--comment Game Filter (TCP) --filter-tcp=80,443,%GameFilterTCP% --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=hostfakesplit --dpi-desync-repeats=4 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n3 --dpi-desync-fooling=ts --dpi-desync-hostfakesplit-mod=host=ozon.ru --new ^

--comment Game Filter (UDP) + Roblox (UDP) --filter-udp=49152-65535,%GameFilterUDP% --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --ipset-ip=103.140.28.0/23,128.116.0.0/17,141.193.3.0/24,205.201.62.0/24,2620:2b:e000::/48,2620:135:6000::/40,2620:135:6004::/48,2620:135:6007::/48,2620:135:6008::/48,2620:135:6009::/48,2620:135:600a::/48,2620:135:600b::/48,2620:135:600c::/48,2620:135:600d::/48,2620:135:600e::/48,2620:135:6041::/48 --dpi-desync=fake --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_dbankcloud_ru.bin" --dpi-desync-cutoff=n2