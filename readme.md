# Testing FFMpeg video encoding

Testing FFMpeg video encoding on Centmin Mod LEMP stack based servers using test source mp4 videos.

# videojs player tests

Tests using [VideoJS](https://videojs.com/)

Download source videos to test `/videos` directory for your Nginx vhost `/home/nginx/domains/yourdomain.com/public/videos` which is web accessible at `yourdomain.com/videos/`

```
domain=yourdomain.com
cd /home/nginx/domains/$domain
mkdir -p /home/nginx/domains/$domain/public/videos
git clone https://github.com/centminmod/ffmpeg-tests
cd ffmpeg-tests
cp source/* /home/nginx/domains/$domain/public/videos
cp players/videojs/index.html /home/nginx/domains/$domain/public/videos
chown -R nginx:nginx /home/nginx/domains/$domain/public/videos
```

At this stage VP9 (webm) version and poster thumbnail has yet to be created from the source videos, so that can be done via FFMpeg command line.

1. Install FFMpeg if not installed yet via `addons/ffmpeg.sh` installer which will source compile latest version and set command aliases due to source compiled version being located at `/opt/bin`

```
cmupdate
cd /usr/local/src/centminmod
addons/ffmpeg.sh install
alias ffmpeg='/opt/bin/ffmpeg'
alias ffprobe='/opt/bin/ffprobe'
```

Also add these alias into `/root/.bashrc`

```
alias ffmpeg='/opt/bin/ffmpeg'
alias ffprobe='/opt/bin/ffprobe'
```

There maybe other binaries you would want to alias to

```
ls -lah /opt/bin 
total 11M
drwxr-xr-x   2 root root   98 Sep  1 06:49 .
drwxr-xr-x. 16 root root  269 Sep  1 06:41 ..
-rwxr-xr-x   1 root root 242K Sep  1 06:49 ffmpeg
-rwxr-xr-x   1 root root 141K Sep  1 06:49 ffprobe
-rwxr-xr-x   1 root root 474K Sep  1 06:44 lame
-rwxr-xr-x   1 root root 2.5M Sep  1 06:41 vsyasm
-rwxr-xr-x   1 root root 2.4M Sep  1 06:41 x264
-rwxr-xr-x   1 root root 2.5M Sep  1 06:41 yasm
-rwxr-xr-x   1 root root 2.5M Sep  1 06:41 ytasm
```

check FFMpeg vesion

```
ffmpeg -version
ffmpeg version git-2018-08-31-aeb73c7 Copyright (c) 2000-2018 the FFmpeg developers
built with gcc 4.8.5 (GCC) 20150623 (Red Hat 4.8.5-28)
configuration: --prefix=/opt/ffmpeg --extra-cflags=-I/opt/ffmpeg/include --extra-ldflags=-L/opt/ffmpeg/lib --bindir=/opt/bin --pkg-config-flags=--static --extra-libs=-lpthread --extra-libs=-lm --enable-gpl --enable-nonfree --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-swscale --enable-shared
libavutil      56. 19.100 / 56. 19.100
libavcodec     58. 27.100 / 58. 27.100
libavformat    58. 17.103 / 58. 17.103
libavdevice    58.  4.101 / 58.  4.101
libavfilter     7. 26.100 /  7. 26.100
libswscale      5.  2.100 /  5.  2.100
libswresample   3.  2.100 /  3.  2.100
libpostproc    55.  2.100 / 55.  2.100
```

2. Create webm versions and their poster thumbnails

FFMpeg settings for conversion on Intel Xeon E3-1270v1 where there are 4 cpu cores + 4 cpu threads = 8 cpu threads total.

* `-threads` - Indicates the number of threads to use during encoding.
* `-quality` -  May be set to good, best, or realtime
* `-speed` - This parameter has different meanings depending upon whether quality is set to good or realtime. Speed settings 0-4 apply for VoD in good and best, with 0 being the highest quality and 4 being the lowest. Realtime valid values are 5-8; lower numbers mean higher quality
* `-tile-columns` - Tiling splits the video into rectangular regions, which allows multi-threading for encoding and decoding. The number of tiles is always a power of two. 0=1 tile, 1=2, 2=4, 3=8, 4=16, 5=32.


For FFMpeg with [VP9 based webm format](https://trac.ffmpeg.org/wiki/Encode/VP9)

```
domain=yourdomain.com
cd /home/nginx/domains/$domain/public/videos
# poster images
for f in *.mp4; do ffmpeg -y -ss 4 -i "$f" -f image2 -vframes 1 -q:v 2 -an "${f%.mp4}.jpg"; done
# video
time ffmpeg -i cmm-centmin.sh-menu.mp4 -c:v libvpx-vp9 -c:a libopus -quality good -speed 2 -tile-columns 4 -threads 4 cmm-centmin.sh-menu.webm
time ffmpeg -i cmm-add-nginx-vhost.mp4 -c:v libvpx-vp9 -c:a libopus -quality good -speed 2 -tile-columns 4 -threads 4 cmm-add-nginx-vhost.webm
time ffmpeg -i cmm-betainstall.mp4 -c:v libvpx-vp9 -c:a libopus -quality good -speed 2 -tile-columns 4 -threads 4 cmm-betainstall.webm
```

```
ls -lah | egrep '.mp4|.webm|.jpg'
-rw-r--r-- 1 root  nginx  35K Sep  1 08:18 cmm-add-nginx-vhost.jpg
-rw-r--r-- 1 root  nginx  34M Sep  1 05:32 cmm-add-nginx-vhost.mp4
-rw-r--r-- 1 root  nginx  22M Sep  1 07:57 cmm-add-nginx-vhost.webm
-rw-r--r-- 1 root  nginx  35K Sep  1 08:18 cmm-betainstall.jpg
-rw-r--r-- 1 root  nginx  38M Sep  1 05:28 cmm-betainstall.mp4
-rw-r--r-- 1 root  nginx  19M Sep  1 07:54 cmm-betainstall.webm
-rw-r--r-- 1 root  nginx  32K Sep  1 08:18 cmm-centmin.sh-menu.jpg
-rw-r--r-- 1 root  nginx 9.3M Sep  1 05:32 cmm-centmin.sh-menu.mp4
-rw-r--r-- 1 root  nginx 6.9M Sep  1 07:44 cmm-centmin.sh-menu.webm
```

For FFMpeg with [VP8 based webm format](https://trac.ffmpeg.org/wiki/Encode/VP8)

```
domain=yourdomain.com
cd /home/nginx/domains/$domain/public/videos
# poster images
for f in *.mp4; do ffmpeg -y -ss 4 -i "$f" -f image2 -vframes 1 -q:v 2 -an "${f%.mp4}.jpg"; done
# video
time ffmpeg -i cmm-centmin.sh-menu.mp4 -c:v libvpx -crf 10 -b:v 512K -c:a libopus -quality good -speed 2 -threads 4 cmm-centmin.sh-menu.webm
time ffmpeg -i cmm-add-nginx-vhost.mp4 -c:v libvpx -crf 10 -b:v 512K -c:a libopus -quality good -speed 2 -threads 4 cmm-add-nginx-vhost.webm
time ffmpeg -i cmm-betainstall.mp4 -c:v libvpx -crf 10 -b:v 512K -c:a libopus -quality good -speed 2 -threads 4 cmm-betainstall.webm
```

listing with `-vp8` suffix compared to `vp9` webm encoded files

```
ls -lah | egrep '.mp4|.webm|.jpg'
-rw-r--r-- 1 root  nginx  35K Sep  1 08:18 cmm-add-nginx-vhost.jpg
-rw-r--r-- 1 root  nginx  34M Sep  1 05:32 cmm-add-nginx-vhost.mp4
-rw-r--r-- 1 root  nginx  17M Sep  2 07:44 cmm-add-nginx-vhost-vp8.webm
-rw-r--r-- 1 root  nginx  22M Sep  1 07:57 cmm-add-nginx-vhost.webm
-rw-r--r-- 1 root  nginx  35K Sep  1 08:18 cmm-betainstall.jpg
-rw-r--r-- 1 root  nginx  38M Sep  1 05:28 cmm-betainstall.mp4
-rw-r--r-- 1 root  nginx  14M Sep  2 07:54 cmm-betainstall-vp8.webm
-rw-r--r-- 1 root  nginx  19M Sep  1 07:54 cmm-betainstall.webm
-rw-r--r-- 1 root  nginx  32K Sep  1 08:18 cmm-centmin.sh-menu.jpg
-rw-r--r-- 1 root  nginx 9.3M Sep  1 05:32 cmm-centmin.sh-menu.mp4
-rw-r--r-- 1 root  nginx 8.1M Sep  2 07:35 cmm-centmin.sh-menu-vp8.webm
-rw-r--r-- 1 root  nginx 8.1M Sep  2 07:38 cmm-centmin.sh-menu.webm
```

3. Visual Check

In your web browser go to `yourdomain.com/videos/`

# Centmin Mod Nginx mp4, flv, rtmp and slice modules

Centmin Mod Nginx optionally supports enabling nginx modules for mp4, flv, rtmp and slice outlined [here](https://community.centminmod.com/threads/add-nginx_video-control-variable-in-123-09beta01.15540/)

* https://nginx.org/en/docs/http/ngx_http_mp4_module.html
* https://nginx.org/en/docs/http/ngx_http_flv_module.html
* https://github.com/arut/nginx-rtmp-module
* https://nginx.org/en/docs/http/ngx_http_slice_module.html

Then for your mp4 videos, you can set inside your Nginx vhost config file for mp4 and flv videos. Also Centmin Mod Nginx supports [Nginx Thread Pooling](https://www.nginx.com/blog/thread-pools-boost-performance-9x/).

```
location /videos/ {
  aio threads;
  sendfile_max_chunk 2m;
  location ~ \.(webm)$ {
    add_header   backend-webm 1;
  }
  location ~ \.(mp4|m4a|m4v|mov)$ {
    keepalive_timeout 0;
    add_header   backend-mp4 1;
    mp4;
    mp4_buffer_size       2m;
    mp4_max_buffer_size   8m;
  }
  location ~ \.(flv)$ {
    add_header   backend-flv 1;
    flv;
  }
}
```

or

```
location /videos/ {
  aio threads;
  sendfile_max_chunk 2m;
  add_header   backend-media 0;
  location ~* ^/videos/(.+\.webm)$ {
    add_header   backend-webm 1;
  }
  location ~* ^/videos/(.+\.mp4)$ {
    keepalive_timeout 0;
    add_header   backend-mp4 1;
    mp4;
    mp4_buffer_size       2m;
    mp4_max_buffer_size   8m;
  }
  location ~* ^/videos/(.+\.flv)$ {
    add_header   backend-flv 1;
    flv;
  }
}
```

# Optimizations - Nginx Sliced Byte Range Caching

You can further optimize video delivery by implementing [Nginx Sliced Byte-Range Caching](https://www.nginx.com/blog/smart-efficient-byte-range-caching-nginx/) in Centmin Mod Nginx as the Nginx server will be built with all required modules outlined [here](https://community.centminmod.com/threads/add-nginx_video-control-variable-in-123-09beta01.15540/).

```
location /videos/ {
  location ~ \.(mp4|m4a|m4v|mov|webm|flv)$ {
    proxy_cache mycache;
    slice              2m;
    proxy_cache_key    $host$uri$is_args$args$slice_range;
    proxy_set_header   Range $slice_range;
    add_header         Sliced-Cache $upstream_cache_status;
    add_header         Sliced 1;
    proxy_http_version 1.1;
    proxy_cache_valid  200 206 24h;
    proxy_pass         http://video_upstream;
    # https://nginx.org/en/docs/http/ngx_http_core_module.html#postpone_output
    postpone_output 0;
    proxy_buffer_size 8m;
    proxy_buffers 32 8m;
  }
}
```

```
curl -I https://domain.com/videos/cmm-centmin.sh-menu.webm
HTTP/1.1 200 OK
Date: Wed, 05 Sep 2018 08:54:42 GMT
Content-Type: video/webm
Content-Length: 8421399
Connection: keep-alive
Last-Modified: Sun, 02 Sep 2018 07:38:31 GMT
ETag: "5b8b9377-808017"
X-Powered-By: centminmod
backend-webm: 1
Server: nginx centminmod
Sliced-Cache: HIT
Sliced: 1
Accept-Ranges: bytes
```

```
curl -I https://domain.com/videos/cmm-centmin.sh-menu.mp4
HTTP/1.1 200 OK
Date: Wed, 05 Sep 2018 08:54:53 GMT
Content-Type: video/mp4
Content-Length: 9730773
Connection: keep-alive
Last-Modified: Sat, 01 Sep 2018 05:32:09 GMT
ETag: "5b8a2459-947ad5"
X-Powered-By: centminmod
backend-mp4: 1
Server: nginx centminmod
Sliced-Cache: MISS
Sliced: 1
Accept-Ranges: bytes
```

## Rate Limiting Speeds

[Nginx Rate limiting](https://nginx.org/en/docs/http/ngx_http_core_module.html#limit_rate_after)

```
location /videos/ {
  aio threads;
  sendfile_max_chunk 2m;
  location ~ \.(webm)$ {
    add_header   backend-webm 1;
    limit_rate_after 2500k;
    limit_rate       350k;
  }
  location ~ \.(mp4|m4a|m4v|mov)$ {
    keepalive_timeout 0;
    add_header   backend-mp4 1;
    mp4;
    mp4_buffer_size       2m;
    mp4_max_buffer_size   8m;
    limit_rate_after 2500k;
    limit_rate       350k;
  }
  location ~ \.(flv)$ {
    add_header   backend-flv 1;
    flv;
    limit_rate_after 2500k;
    limit_rate       350k;
  }
}
```

```
location /videos/ {
  location ~ \.(mp4|m4a|m4v|mov|webm|flv)$ {
    proxy_cache mycache;
    slice              2m;
    proxy_cache_key    $host$uri$is_args$args$slice_range;
    proxy_set_header   Range $slice_range;
    add_header         Sliced-Cache $upstream_cache_status;
    add_header         Sliced 1;
    proxy_http_version 1.1;
    proxy_cache_valid  200 206 24h;
    proxy_pass         http://video_upstream;
    # https://nginx.org/en/docs/http/ngx_http_core_module.html#postpone_output
    postpone_output 0;
    proxy_buffer_size 8m;
    proxy_buffers 32 8m;
    limit_rate_after 2500k;
    limit_rate       350k;
  }
}
```

# Inspecting Nginx Byte Range Sliced Cached Files

If you setup proxy_cache to save files to `/tmp/mycache`, you can inspect the cached files using a while read loop to inspect the first 8 lines of each cached file. Then check output for log saved at `inspect-cache.txt`.

```
ls -rt /tmp/mycache | while read f; do echo $f;head -n8 /tmp/mycache/$f; done > inspect-cache.txt
```

Example for time reverse ascending order listing of `/tmp/mycache` cached files where 2MB sliced cached chunks were used.

```
ls -lAhRrt /tmp/mycache
/tmp/mycache:
total 52M
-rw------- 1 nginx nginx 2.1M Oct 24 04:33 478425de7a4472f74e54fee2f456e38c
-rw------- 1 nginx nginx 2.1M Oct 24 04:37 e6fc23d32836f59515773cb1dc2507a6
-rw------- 1 nginx nginx 2.1M Oct 24 04:37 a5190baefd6425df4731d8a54fdfdce0
-rw------- 1 nginx nginx 2.1M Oct 24 04:37 17c1532da0b6ef9316acdba6de987552
-rw------- 1 nginx nginx 2.1M Oct 24 04:38 e5b502a3ffcd17b30b9224a54a8911af
-rw------- 1 nginx nginx 2.1M Oct 24 04:38 ffee1c1bba98e2014fb4d7bc195b5bb5
-rw------- 1 nginx nginx 2.1M Oct 24 04:38 9935e066408a231b4647d1475569908e
-rw------- 1 nginx nginx 2.1M Oct 24 04:38 10752e5e616fdf6cec214ecca4938d7e
-rw------- 1 nginx nginx 2.1M Oct 24 04:38 ee88451e088ed4a2f425947bb3cb2627
-rw------- 1 nginx nginx 2.1M Oct 24 04:38 9c6922c1bcee1d17ae0af583aa599ffd
-rw------- 1 nginx nginx 2.1M Oct 24 04:38 368526299d4b2d25c810d1f442f58e6c
-rw------- 1 nginx nginx 2.1M Oct 24 04:38 f95854a97f8d9c327af77b87bc5f15f4
-rw------- 1 nginx nginx 2.1M Oct 24 04:38 7ef80e307c6db579b2a1a318e623ad8b
-rw------- 1 nginx nginx 2.1M Oct 24 04:38 40c6f06296afd6e7570c2d4eadcd0a3c
-rw------- 1 nginx nginx 2.1M Oct 24 04:39 ca501834ae0e4d8ed4323a4705aef1ee
-rw------- 1 nginx nginx 2.1M Oct 24 04:39 65a5a9078b0b5a58516923a8239904fa
-rw------- 1 nginx nginx 2.1M Oct 24 04:39 2a5787d729ff0980aff26c39ebe2aa1d
-rw------- 1 nginx nginx 2.1M Oct 24 04:39 d266a8b6964c76bc0f73128395df436b
-rw------- 1 nginx nginx 2.1M Oct 24 04:39 ce86f8955c563103ac9c894d1f011b90
-rw------- 1 nginx nginx 1.9M Oct 24 04:39 3bde254597f06c5159c2bdb3ead50657
-rw------- 1 nginx nginx 2.1M Oct 24 05:57 61bcc5a92e49be7ed1c7e5e50632d149
-rw------- 1 nginx nginx 2.1M Oct 24 05:57 90cee2d67eddae74af38458014b92761
-rw------- 1 nginx nginx 2.1M Oct 24 05:57 cc99d3c8b69f9bc5f4550f6af346a6d4
-rw------- 1 nginx nginx 2.1M Oct 24 06:00 d0765f8f6ca207699fc814ee62e36971
-rw------- 1 nginx nginx 2.1M Oct 24 06:01 049aa0dc42ec04cf36938549b7d6cf1a
-rw------- 1 nginx nginx 1.3M Oct 24 06:01 0f7f37eeebde5b4a335f2f9da21ba016
```

Using the while read loop to inspect headers, the excerpt of last 3 cached files inspections

```
ls -rt /tmp/mycache | while read f; do echo $f;head -n8 /tmp/mycache/$f; done > inspect-cache.txt

"5b8a2459-947ad5"
KEY: domain.com/videos/cmm-centmin.sh-menu.mp4bytes=4194304-6291455
HTTP/1.1 206 Partial Content
Date: Wed, 24 Oct 2018 06:00:59 GMT
Content-Type: video/mp4
Content-Length: 2097152
Last-Modified: Sat, 01 Sep 2018 05:32:09 GMT

"5b8a2459-947ad5"
KEY: domain.com/videos/cmm-centmin.sh-menu.mp4bytes=6291456-8388607
HTTP/1.1 206 Partial Content
Date: Wed, 24 Oct 2018 06:01:05 GMT
Content-Type: video/mp4
Content-Length: 2097152
Last-Modified: Sat, 01 Sep 2018 05:32:09 GMT

"5b8a2459-947ad5"
KEY: domain.com/videos/cmm-centmin.sh-menu.mp4bytes=8388608-10485759
HTTP/1.1 206 Partial Content
Date: Wed, 24 Oct 2018 06:01:11 GMT
Content-Type: video/mp4
Content-Length: 1342165
Last-Modified: Sat, 01 Sep 2018 05:32:09 GMT
```

Then check output for log saved at `inspect-cache.txt` using grep with `-a` flag to treat binary files as text.

To check all slicked cached chunked byte ranges for `cmm-centmin.sh-menu.mp4` video file

```
grep -a 'cmm-centmin.sh-menu.mp4' inspect-cache.txt 
KEY: domain.com/videos/cmm-centmin.sh-menu.mp4bytes=0-2097151
KEY: domain.com/videos/cmm-centmin.sh-menu.mp4bytes=2097152-4194303
KEY: domain.com/videos/cmm-centmin.sh-menu.mp4bytes=4194304-6291455
KEY: domain.com/videos/cmm-centmin.sh-menu.mp4bytes=6291456-8388607
KEY: domain.com/videos/cmm-centmin.sh-menu.mp4bytes=8388608-10485759
```

for `cmm-betainstall.mp4`

```
grep -a 'cmm-betainstall.mp4' inspect-cache.txt                   
KEY: domain.com/videos/cmm-betainstall.mp4bytes=0-2097151
KEY: domain.com/videos/cmm-betainstall.mp4bytes=2097152-4194303
KEY: domain.com/videos/cmm-betainstall.mp4bytes=4194304-6291455
KEY: domain.com/videos/cmm-betainstall.mp4bytes=6291456-8388607
KEY: domain.com/videos/cmm-betainstall.mp4bytes=8388608-10485759
KEY: domain.com/videos/cmm-betainstall.mp4bytes=10485760-12582911
KEY: domain.com/videos/cmm-betainstall.mp4bytes=12582912-14680063
KEY: domain.com/videos/cmm-betainstall.mp4bytes=14680064-16777215
KEY: domain.com/videos/cmm-betainstall.mp4bytes=16777216-18874367
KEY: domain.com/videos/cmm-betainstall.mp4bytes=18874368-20971519
KEY: domain.com/videos/cmm-betainstall.mp4bytes=20971520-23068671
KEY: domain.com/videos/cmm-betainstall.mp4bytes=23068672-25165823
KEY: domain.com/videos/cmm-betainstall.mp4bytes=25165824-27262975
KEY: domain.com/videos/cmm-betainstall.mp4bytes=27262976-29360127
KEY: domain.com/videos/cmm-betainstall.mp4bytes=29360128-31457279
KEY: domain.com/videos/cmm-betainstall.mp4bytes=31457280-33554431
KEY: domain.com/videos/cmm-betainstall.mp4bytes=33554432-35651583
KEY: domain.com/videos/cmm-betainstall.mp4bytes=35651584-37748735
KEY: domain.com/videos/cmm-betainstall.mp4bytes=37748736-39845887
```

for `cmm-add-nginx-vhost.mp4`

```
grep -a 'cmm-add-nginx-vhost.mp4' inspect-cache.txt
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=0-2097151
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=2097152-4194303
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=4194304-6291455
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=6291456-8388607
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=8388608-10485759
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=10485760-12582911
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=12582912-14680063
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=14680064-16777215
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=16777216-18874367
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=18874368-20971519
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=20971520-23068671
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=23068672-25165823
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=25165824-27262975
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=27262976-29360127
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=29360128-31457279
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=31457280-33554431
KEY: domain.com/videos/cmm-add-nginx-vhost.mp4bytes=33554432-35651583
```

Checking header for byte range request (2097152-4194303) for `https://domain.com/videos/cmm-add-nginx-vhost.mp4`

```
curl -I -r 2097152-4194303 https://domain.com/videos/cmm-add-nginx-vhost.mp4
HTTP/1.1 206 Partial Content
Date: Wed, 24 Oct 2018 07:05:38 GMT
Content-Type: video/mp4
Content-Length: 2097152
Connection: keep-alive
Last-Modified: Sat, 01 Sep 2018 05:32:58 GMT
ETag: "5b8a248a-21c5057"
X-Powered-By: centminmod
backend-mp4: 1
Server: nginx centminmod
Sliced-Cache: HIT
Sliced: 1
Content-Range: bytes 2097152-4194303/35410007
```