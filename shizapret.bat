:: general (ALT 11) (from Flowseal/zapret-discord-youtube) + added ports/IPs/hosts from general (Dronatar) (by Dronatar)

:: https://github.com/Flowseal/zapret-discord-youtube
:: https://github.com/V3nilla/IPSets-For-Bypass-in-Russia
:: https://github.com/Flowseal/zapret-discord-youtube/discussions/3279
:: https://github.com/bol-van/rulist
:: https://steamcommunity.com/sharedfiles/filedetails/?id=3496724173

@echo off
title %~n0

cd /d "%~dp0"

call service.bat status_zapret

call service.bat load_game_filter

if not exist "bin/cygwin1.dll" (
    call service.bat bin
)

if not exist "lists/list-general.txt" (
    call service.bat list
)

if not exist "lists/ipset-all.txt" (
    call service.bat ips
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

start "%~n0" /min "%BIN%winws.exe" --wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,1400,3478-3482,3484,3488,3489,3491-3493,3495-3497,19294-19344,50000-50100,49152-65535,%GameFilter% ^

--comment QUIC --filter-udp=443 --hostlist="%LISTS%list-general.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment Discord Voice --filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="%BIN%quic_initial_www_google_com.bin" --dpi-desync-fake-stun="%BIN%quic_initial_www_google_com.bin" --dpi-desync-repeats=6 --new ^

--comment Discord --filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=654 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --new ^

--comment YouTube --filter-tcp=443 --hostlist="%LISTS%list-google.txt" --ip-id=zero --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment List+extra domains (UDP 80, 443) --filter-tcp=80,443 --hostlist="%LISTS%list-general.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --hostlist-domains=adguard.com,adguard-vpn.com,totallyacdn.com,whiskergalaxy.com,windscribe.com,windscribe.net,soundcloud.com,sndcdn.com,soundcloud.cloud,nexusmods.com,nexus-cdn.com,prostovpn.org,html-classic.itch.zone,speedtest.net,softportal.com,ntc.party,mega.nz,mega.co.nz,modrinth.com,forgecdn.net,minecraftforge.net,neoforged.net,essential.gg,imagedelivery.net,dns.malw.link,cloudflare-gateway.com,quora.com,amazon.com,awsstatic.com,amazonaws.com,awsapps.com,roblox.com,rbxcdn.com,whatsapp.com,whatsapp.net --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=654 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --new ^

--comment ipset (UDP 443) --filter-udp=443 --ipset="%LISTS%ipset-all.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment Game Filter (TCP) --filter-tcp=80,443,%GameFilterTCP% --ipset="%LISTS%ipset-all.txt" --hostlist-exclude="%LISTS%list-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=654 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --new ^

--comment Game Filter (UDP) + Roblox (UDP) --filter-udp=49152-65535,%GameFilter% --ipset="%LISTS%ipset-all.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-ip=103.140.28.0/23,128.116.0.0/17,141.193.3.0/24,205.201.62.0/24,2620:2b:e000::/48,2620:135:6000::/40,2620:135:6004::/48,2620:135:6007::/48,2620:135:6008::/48,2620:135:6009::/48,2620:135:600a::/48,2620:135:600b::/48,2620:135:600c::/48,2620:135:600d::/48,2620:135:600e::/48,2620:135:6041::/48 --dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=10 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin" --dpi-desync-cutoff=n2 --new ^

--comment WhatsApp + Telegram (WebRTC) [untested] --filter-udp=1400,3478-3482,3484,3488,3489,3491-3493,3495-3497 --ipset-exclude="%LISTS%ipset-exclude.txt" --dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=10 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin" --dpi-desync-cutoff=n2 --new ^
