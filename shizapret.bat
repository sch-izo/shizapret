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

start "%~n0" /min "%BIN%winws.exe" --wf-tcp=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50032,%GameFilter%,0-65535 ^

--comment Discord (RTC) --filter-udp=19294-19344,50000-50032 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord=0x00 --dpi-desync-fake-stun=0x00 --dpi-desync-repeats=6 --new ^

--comment Discord --filter-tcp=443,2053,2083,2087,2096,8443 --hostlist-domains=dis.gd,discord-attachments-uploads-prd.storage.googleapis.com,discord.app,discord.co,discord.com,discord.design,discord.dev,discord.gift,discord.gifts,discord.gg,discord.media,discord.new,discord.store,discord.status,discord-activities.com,discordactivities.com,discordapp.com,cdn.discordapp.com,discordapp.net,media.discordapp.net,images-ext-1.discordapp.net,updates.discord.com,stable.dl2.discordapp.net,discordcdn.com,discordmerch.com,discordpartygames.com,discordsays.com,discordsez.com --hostlist-exclude-domains=gateway.discord.gg --dpi-desync=fake --dpi-desync-fake-tls-mod=rnd,dupsid --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=0 --new ^

--comment Discord (Gateway) --filter-tcp=443 --hostlist-domains=gateway.discord.gg --dpi-desync=fake --dpi-desync-fake-tls-mod=rnd,dupsid,sni=yandex.ru --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=0 --new ^

--comment YouTube QUIC/QUIC --filter-udp=443 --hostlist="%LISTS%list-general.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment YouTube Streaming/HTTP --filter-tcp=80 --hostlist="%LISTS%list-general.txt" --dpi-desync=fake,multisplit --dpi-desync-fake-tls-mod=rnd,dupsid,sni=yandex.ru --dpi-desync-fooling=badseq --new ^

--comment YouTube --filter-tcp=443 --hostlist-domains=yt3.ggpht.com,yt4.ggpht.com,yt3.googleusercontent.com,googlevideo.com,jnn-pa.googleapis.com,wide-youtube.l.google.com,youtube-nocookie.com,youtube-ui.l.google.com,youtube.com,youtubeembeddedplayer.googleapis.com,youtubekids.com,youtubei.googleapis.com,youtu.be,yt-video-upload.l.google.com,ytimg.com,ytimg.l.google.com --dpi-desync=multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1,midsld --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment list-general+Extra --filter-tcp=443 --hostlist-exclude-domains=dis.gd,discord-attachments-uploads-prd.storage.googleapis.com,discord.app,discord.co,discord.com,discord.design,discord.dev,discord.gift,discord.gifts,discord.gg,gateway.discord.gg,discord.media,discord.new,discord.store,discord.status,discord-activities.com,discordactivities.com,discordapp.com,cdn.discordapp.com,discordapp.net,media.discordapp.net,images-ext-1.discordapp.net,updates.discord.com,stable.dl2.discordapp.net,discordcdn.com,discordmerch.com,discordpartygames.com,discordsays.com,discordsez.com,yt3.ggpht.com,yt4.ggpht.com,yt3.googleusercontent.com,googlevideo.com,jnn-pa.googleapis.com,wide-youtube.l.google.com,youtube-nocookie.com,youtube-ui.l.google.com,youtube.com,youtubeembeddedplayer.googleapis.com,youtubekids.com,youtubei.googleapis.com,youtu.be,yt-video-upload.l.google.com,ytimg.com,ytimg.l.google.com --hostlist="%LISTS%list-general.txt" --hostlist-domains=adguard.com,adguard-vpn.com,totallyacdn.com,whiskergalaxy.com,windscribe.com,windscribe.net,cloudflareclient.com,soundcloud.com,sndcdn.com,soundcloud.cloud,nexusmods.com,nexus-cdn.com,supporter-files.nexus-cdn.com,prostovpn.org,html-classic.itch.zone --dpi-desync=fake,multisplit --dpi-desync-fake-tls-mod=rnd,dupsid,sni=yandex.ru --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=0 --new ^

--comment Cloudflare WARP Gateway(1.1.1.1, 1.0.0.1) --filter-tcp=443 --ipset-ip=162.159.36.1,162.159.46.1,2606:4700:4700::1111,2606:4700:4700::1001 --filter-l7=tls --dpi-desync=fake --dpi-desync-fake-tls=0x00 --dpi-desync-start=n2 --dpi-desync-cutoff=n3 --dpi-desync-fooling=badseq --new ^

--comment WireGuard handshake --filter-udp=0-65535 --filter-l7=wireguard --dpi-desync=fake --dpi-desync-repeats=4 --dpi-desync-fake-wireguard=0x00 --dpi-desync-cutoff=n2 --new ^

--comment OVHcloud --filter-tcp=80,443 --ipset-ip=45.43.142.0/24,151.127.0.0/16,5.196.0.0/16,5.144.179.0/24,5.135.0.0/16,5.39.0.0/17,8.7.244.0/24,8.18.128.0/24,8.18.172.0/24,8.20.110.0/24,8.21.41.0/24,8.24.8.0/21,8.26.94.0/24,8.29.224.0/24,8.30.208.0/21,8.33.96.0/21,8.33.128.0/21,8.33.136.0/23,15.204.0.0/14,15.235.0.0/16,23.92.224.0/19,37.59.0.0/16,37.60.48.0/20,37.187.0.0/16,40.160.0.0/17,40.160.224.0/24,45.66.83.0/24,45.92.60.0/22,46.28.236.0/24,46.105.0.0/16,46.244.32.0/20,51.38.0.0/16,51.68.0.0/16,51.75.0.0/16,51.77.0.0/16,51.79.0.0/16,51.81.0.0/16,51.83.0.0/16,51.89.0.0/16,51.91.0.0/16,51.161.0.0/16,51.178.0.0/16,51.195.0.0/16,51.210.0.0/16,51.222.0.0/16,51.254.0.0/15,54.36.0.0/14,57.128.0.0/16,57.129.0.0/17,57.130.0.0/16,63.251.117.0/24,64.94.92.0/23,64.95.150.0/23,64.225.244.0/23,66.70.128.0/17,66.179.22.0/24,66.179.218.0/23,69.72.31.0/24,72.251.0.0/17,79.137.0.0/17,80.71.226.0/24,82.117.230.0/23,83.143.16.0/21,85.217.144.0/23,86.38.156.0/24,87.98.128.0/17,91.90.90.0/24,91.121.0.0/16,91.134.0.0/16,91.198.19.0/24,92.222.0.0/16,92.242.186.0/24,92.246.224.0/19,94.23.0.0/16,103.5.12.0/22,104.167.16.0/24,104.225.253.0/24,107.189.64.0/18,123.100.227.0/24,135.125.0.0/16,135.148.0.0/16,137.74.0.0/16,137.83.50.0/24,139.99.0.0/16,141.94.0.0/15,141.227.128.0/24,141.227.136.0/24,142.4.192.0/19,142.44.128.0/17,144.2.32.0/19,144.217.0.0/16,145.239.0.0/16,146.19.9.0/24,146.59.0.0/16,147.135.0.0/16,148.113.0.0/18,148.113.128.0/17,148.222.40.0/22,149.56.0.0/16,149.202.0.0/16,151.80.0.0/16,152.228.128.0/17,158.69.0.0/16,162.19.0.0/16,164.132.0.0/16,164.153.186.0/24,167.114.0.0/16,167.234.38.0/24,168.245.185.0/24,172.83.201.0/24,176.31.0.0/16,178.32.0.0/15,185.12.32.0/23,185.15.68.0/22,185.45.160.0/22,185.101.104.0/24,185.135.188.0/24,185.228.207.0/24,185.255.28.0/24,188.68.164.0/22,188.165.0.0/16,191.96.204.0/24,192.70.246.0/23,192.95.0.0/18,192.99.0.0/16,192.124.170.0/24,192.152.126.0/24,192.240.152.0/21,193.33.176.0/23,193.43.104.0/24,193.57.33.0/24,193.70.0.0/17,193.149.28.0/22,193.243.147.0/24,194.50.111.0/24,194.59.183.0/24,194.76.36.0/23,198.27.64.0/18,198.49.103.0/24,198.50.128.0/17,198.100.144.0/20,198.101.27.0/24,198.244.128.0/17,198.245.48.0/20,199.195.140.0/23,203.5.184.0/24,206.168.174.0/23,209.71.36.0/24,209.126.71.0/24,212.192.253.0/24,213.32.0.0/17,213.186.32.0/19,213.251.128.0/18,216.183.120.0/24,216.203.15.0/24,217.182.0.0/16 --dpi-desync=fake,fakedsplit --dpi-desync-fake-tls-mod=sni=none --dpi-desync-split-seqovl=681 --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=2

--comment IP set(TCP 80) --filter-tcp=80 --ipset="%LISTS%ipset-all.txt" --dpi-desync=fake,multisplit --dpi-desync-fake-tls-mod=rnd,dupsid,sni=yandex.ru --dpi-desync-fooling=badseq --new ^

--comment IP set(TCP 443) --ipset="%LISTS%ipset-all.txt" --dpi-desync=multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment IP set(UDP 443) --filter-udp=443 --ipset="%LISTS%ipset-all.txt" --dpi-desync=fake --dpi-desync-repeats=6 --new ^

--comment Games(TCP) --filter-tcp=%GameFilterTCP% --ipset="%LISTS%ipset-all.txt" --dpi-desync=syndata,fake,fakedsplit --dpi-desync-any-protocol --dpi-desync-split-pos=1 --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-cutoff=n3 --dpi-desync-autottl --dpi-desync-fooling=badseq --new ^

--comment Games(UDP) --filter-udp=%GameFilter% --ipset="%LISTS%ipset-all.txt" --dpi-desync=fake --dpi-desync-repeats=12 --dpi-desync-any-protocol --dpi-desync-cutoff=n3
