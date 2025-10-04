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

start "%~n0" /min "%BIN%winws.exe" --wf-tcp=80,443,853,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,1400,3478-3482,3484,3488,3489,3491-3493,3495-3497,19294-19344,50000-50032,%GameFilter%,0-65535 ^

--comment Telegram (WebRTC) --filter-udp=1400 --filter-l7=stun --dpi-desync=fake --dpi-desync-fake-stun=0x00 --new ^

--comment WhatsApp (WebRTC) [W.I.P.] --filter-udp=3478-3482,3484,3488,3489,3491-3493,3495-3497 --filter-l7=stun --dpi-desync=fake --dpi-desync-fake-stun=0x00 --dpi-desync-repeats=6 --new ^

--comment Discord (WebRTC) --filter-udp=19294-19344,50000-50032 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord=0x00 --dpi-desync-fake-stun=0x00 --dpi-desync-repeats=6 --new ^

--comment Discord --filter-tcp=443,2053,2083,2087,2096,8443 --hostlist-domains=dis.gd,discord-attachments-uploads-prd.storage.googleapis.com,discord.app,discord.co,discord.com,discord.design,discord.dev,discord.gift,discord.gifts,discord.gg,discord.media,discord.new,discord.store,discord.status,discord-activities.com,discordactivities.com,discordapp.com,cdn.discordapp.com,discordapp.net,media.discordapp.net,images-ext-1.discordapp.net,updates.discord.com,stable.dl2.discordapp.net,discordcdn.com,discordmerch.com,discordpartygames.com,discordsays.com,discordsez.com --hostlist-exclude-domains=gateway.discord.gg --dpi-desync=fake --dpi-desync-fake-tls-mod=rnd,dupsid --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=0 --new ^

--comment Discord (Gateway) --filter-tcp=443 --hostlist-domains=gateway.discord.gg --dpi-desync=fake --dpi-desync-fake-tls-mod=rnd,dupsid,sni=yandex.ru --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=0 --new ^

--comment YouTube QUIC/QUIC --filter-udp=443 --hostlist="%LISTS%list-general.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^

--comment YouTube Streaming/HTTP --filter-tcp=80 --hostlist="%LISTS%list-general.txt" --dpi-desync=fake,multisplit --dpi-desync-fake-tls-mod=rnd,dupsid,sni=yandex.ru --dpi-desync-fooling=badseq --new ^

--comment YouTube --filter-tcp=443 --hostlist-domains=yt3.ggpht.com,yt4.ggpht.com,yt3.googleusercontent.com,googlevideo.com,jnn-pa.googleapis.com,wide-youtube.l.google.com,youtube-nocookie.com,youtube-ui.l.google.com,youtube.com,youtubeembeddedplayer.googleapis.com,youtubekids.com,youtubei.googleapis.com,youtu.be,yt-video-upload.l.google.com,ytimg.com,ytimg.l.google.com --dpi-desync=multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1,midsld --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment list-general+Extra --filter-tcp=443 --hostlist-exclude-domains=dis.gd,discord-attachments-uploads-prd.storage.googleapis.com,discord.app,discord.co,discord.com,discord.design,discord.dev,discord.gift,discord.gifts,discord.gg,gateway.discord.gg,discord.media,discord.new,discord.store,discord.status,discord-activities.com,discordactivities.com,discordapp.com,cdn.discordapp.com,discordapp.net,media.discordapp.net,images-ext-1.discordapp.net,updates.discord.com,stable.dl2.discordapp.net,discordcdn.com,discordmerch.com,discordpartygames.com,discordsays.com,discordsez.com,yt3.ggpht.com,yt4.ggpht.com,yt3.googleusercontent.com,googlevideo.com,jnn-pa.googleapis.com,wide-youtube.l.google.com,youtube-nocookie.com,youtube-ui.l.google.com,youtube.com,youtubeembeddedplayer.googleapis.com,youtubekids.com,youtubei.googleapis.com,youtu.be,yt-video-upload.l.google.com,ytimg.com,ytimg.l.google.com --hostlist="%LISTS%list-general.txt" --hostlist-domains=adguard.com,adguard-vpn.com,totallyacdn.com,whiskergalaxy.com,windscribe.com,windscribe.net,cloudflareclient.com,soundcloud.com,sndcdn.com,soundcloud.cloud,nexusmods.com,nexus-cdn.com,prostovpn.org,html-classic.itch.zone,speedtest.net,softportal.com,githubusercontent.com,githubassets.com --dpi-desync=fake,multisplit --dpi-desync-fake-tls-mod=rnd,dupsid,sni=yandex.ru --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=2 --new ^

--comment Cloudflare WARP Gateway(1.1.1.1, 1.0.0.1) --filter-tcp=443,853 --ipset-ip=162.159.36.1,162.159.46.1,2606:4700:4700::1111,2606:4700:4700::1001 --dpi-desync=syndata,fake --dpi-desync-cutoff=n3 --dpi-desync-fooling=badseq --new ^

--comment WireGuard handshake --filter-udp=0-65535 --filter-l7=wireguard --dpi-desync=fake --dpi-desync-fake-wireguard=0x00 --dpi-desync-repeats=4 --dpi-desync-cutoff=n2 --new ^

--comment IP set(TCP 80) --filter-tcp=80 --ipset="%LISTS%ipset-all.txt" --dpi-desync=fake,multisplit --dpi-desync-fake-tls-mod=rnd,dupsid,sni=yandex.ru --dpi-desync-fooling=badseq --new ^

--comment IP set(TCP 443) --filter-tcp=443 --ipset="%LISTS%ipset-all.txt" --dpi-desync=multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment IP set(UDP 443) --filter-udp=443 --ipset="%LISTS%ipset-all.txt" --dpi-desync=fake --dpi-desync-repeats=6 --new ^

--comment Games(TCP) --filter-tcp=%GameFilterTCP% --ipset="%LISTS%ipset-all.txt" --dpi-desync=syndata,fake,fakedsplit --dpi-desync-any-protocol --dpi-desync-split-pos=1 --dpi-desync-fakedsplit-pattern=0x00 --dpi-desync-cutoff=n3 --dpi-desync-autottl --dpi-desync-fooling=badseq --dpi-desync-badseq-increment=2 --new ^

--comment Games(UDP) --filter-udp=%GameFilter% --ipset="%LISTS%ipset-all.txt" --dpi-desync=fake --dpi-desync-repeats=12 --dpi-desync-any-protocol --dpi-desync-cutoff=n3
