# Testing FFMpeg video encoding

Testing FFMpeg video encoding on Centmin Mod LEMP stack based servers using test source mp4 videos.

# videojs player tests

Tests using [VideoJS](https://videojs.com/)

Download source videos to test `/videos` directory for your Nginx vhost `/home/nginx/domains/yourdomain.com/public/videos` which is web accessible at `yourdomain.com/videos/`

```
domain=yourdomain.com
cd /home/nginx/domains/$domain
mkdir -p /home/nginx/domains/$domain/public/videos
git clone -depth=1 https://github.com/centminmod/ffmpeg-tests
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
  sendfile_max_chunk 1m;
  location ~ \.mp4$ {
    mp4;
    mp4_buffer_size       1m;
    mp4_max_buffer_size   5m;
  }
  location ~ \.flv$ {
    flv;
  }
}
```

# Optimizations - Nginx Sliced Byte Range Caching

You can further optimize video delivery by implementing [Nginx Sliced Byte-Range Caching](https://www.nginx.com/blog/smart-efficient-byte-range-caching-nginx/) in Centmin Mod Nginx as the Nginx server will be built with all required modules outlined [here](https://community.centminmod.com/threads/add-nginx_video-control-variable-in-123-09beta01.15540/).