:: general (EXP) (from Flowseal/zapret-discord-youtube) + added hosts from general (Dronatar) (by Dronatar)

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
if not exist "%LISTS%list-general.txt" call service.bat list
if not exist "%LISTS%ipset-all.txt" call service.bat ips

call service.bat check_updates
call service.bat load_user_lists

cls
chcp 65001 >nul
:: 65001 - UTF-8

cd /d %BIN%
start "%~n0" /min "%BIN%winws.exe" --wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50100,%GameFilterUDP% ^

--comment QUIC --filter-l7=quic --hostlist="%LISTS%list-general.txt" --hostlist="%LISTS%list-general-user.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment Discord Voice --filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun,unknown --dpi-desync=fake --dpi-desync-fake-discord="%BIN%quic_initial_www_google_com.bin" --dpi-desync-fake-discord="%BIN%ACTIVE_DISCORD_UDP.bin" --dpi-desync-fake-stun="%BIN%ACTIVE_DISCORD_UDP.bin" --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin" --dpi-desync-fake-unknown-udp="%BIN%ACTIVE_DISCORD_UDP.bin" --dpi-desync-repeats=4 --new ^

--comment Discord --filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment YouTube --filter-tcp=443 --hostlist="%LISTS%list-google.txt" --ip-id=zero --dpi-desync=hostfakesplit --dpi-desync-fooling=ts --dpi-desync-hostfakesplit-mod=host=www.google.com --new ^

--comment List+extra domains (TCP 80, 443) --filter-tcp=80,443 --hostlist="%LISTS%list-general.txt" --hostlist="%LISTS%list-general-user.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --hostlist-domains=adguard.com,amazon.com,amazonaws.com,anydesk.my.site.com,awsapps.com,awsstatic.com,cloudflare-gateway.com,cloudflare.com,cloudflare.dev,cloudfront.net,cobalt.tools,essential.gg,forgecdn.net,github-api.arkoselabs.com,githubstatus.com,imagedelivery.net,itch.io,itch.zone,klipy.com,malw.link,mega.co.nz,minecraftforge.net,modrinth.com,neoforged.net,nexus-cdn.com,nexusmods.com,ntc.party,githubusercontent.com,prostovpn.org,quora.com,roskomsvoboda.org,sndcdn.com,soundcloud.cloud,soundcloud.com,speedtest.net,tampermonkey.net,tesera.io,totalcommander.ch,totallyacdn.com,uploads.ungrounded.net,whatsapp.com,whatsapp.net,whiskergalaxy.com,windscribe.com,windscribe.net,wireguard.com --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=480 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=4 --dpi-desync-split-seqovl-pattern="%BIN%stun2.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin" --new ^

--comment ipset (UDP 443) --filter-udp=443 --ipset="%LISTS%ipset-all.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment ipset (TCP 80, 443, 8443) --filter-tcp=80,443,8443 --ipset="%LISTS%ipset-all.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --hostlist-exclude-domains=fonts.googleapis.com --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=480 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=4 --dpi-desync-split-seqovl-pattern="%BIN%stun2.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin" --new ^

--comment Game Filter (TCP) --filter-tcp=%GameFilterTCP% --ipset="%LISTS%ipset-all.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake,multisplit --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="%BIN%stun2.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin" --new ^

--comment Game Filter (UDP) --filter-udp=%GameFilterUDP% --ipset="%LISTS%ipset-all.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=5 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_4pda.to.bin" --dpi-desync-fake-unknown-udp="%BIN%ACTIVE_GAME_UDP.bin" --dpi-desync-cutoff=n4
