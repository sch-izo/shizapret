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
start "%~n0" /min "%BIN%winws.exe" --wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,1400,3478-3482,3484,3488,3489,3491-3493,3495-3497,19294-19344,50000-50100,49152-65535,%GameFilterUDP% ^

--comment QUIC --filter-udp=443 --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment Discord Voice --filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="%BIN%quic_initial_dbankcloud_ru.bin" --dpi-desync-fake-stun="%BIN%quic_initial_dbankcloud_ru.bin" --dpi-desync-repeats=6 --new ^

--comment Discord --filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake,fakedsplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment YouTube --filter-tcp=443 --hostlist="%LISTS%list-google.txt" --ip-id=zero --dpi-desync=fake,fakedsplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment List+extra domains (TCP 80, 443) --filter-tcp=80,443 --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake,fakedsplit --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="%BIN%stun.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin" --new ^

--comment ipset (UDP 443) --filter-udp=443 --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment ipset (TCP 80, 443, 8443) --filter-tcp=80,443,8443 --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake,fakedsplit --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="%BIN%stun.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin" --new ^

--comment Game Filter (TCP) --filter-tcp=80,443,%GameFilterTCP% --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake,fakedsplit --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="%BIN%stun.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin" --new ^

--comment Game Filter (UDP) + Roblox (UDP) --filter-udp=49152-65535,%GameFilterUDP% --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_dbankcloud_ru.bin" --dpi-desync-cutoff=d8 --new ^

--comment WhatsApp + Telegram (WebRTC) [untested] --filter-udp=1400,3478-3482,3484,3488,3489,3491-3493,3495-3497 --dpi-desync=fake --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_dbankcloud_ru.bin" --dpi-desync-cutoff=d8