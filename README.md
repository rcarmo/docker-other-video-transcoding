# rcarmo/other-video-transcoding

[![Docker Stars](https://img.shields.io/docker/stars/rcarmo/other-video-transcoding.svg)](https://hub.docker.com/r/rcarmo/other-video-transcoding)
[![Docker Pulls](https://img.shields.io/docker/pulls/rcarmo/other-video-transcoding.svg)](https://hub.docker.com/r/rcarmo/other-video-transcoding)
[![](https://images.microbadger.com/badges/image/rcarmo/other-video-transcoding.svg)](https://microbadger.com/images/rcarmo/other-video-transcoding "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/rcarmo/other-video-transcoding.svg)](https://microbadger.com/images/rcarmo/other-video-transcoding "Get your own version badge on microbadger.com")
[![Build Status](https://travis-ci.org/rcarmo/docker-other-video-transcoding.svg?branch=master)](https://travis-ci.org/rcarmo/docker-other-video-transcoding)

This is a container for running [Don Melton's most excellent `other-video-transcoding` scripts](https://github.com/donmelton/other_video_transcoding), based on my own [`handbrake` container](https://github.com/rcarmo/docker-handbrake).

Unlike the `handbrake` version, which is based off battle-tested packages in Ubuntu LTS, this is largely untested (container-wise, that is--the transcoding logic in itself is very well tuned) and is based on the Debian Buster `ruby` image, which has a relatively up to date `ffmpeg` build but may not be ideal.

In short, your mileage may vary, and feedback/pull requests are welcome.

## Usage

```bash
docker run -it \
  -e PUID=1001 \
  -e PGID=1001 \
  -v "$PWD:/data" \
  --device /dev/dri \
  --cpuset-cpus 8-15 \
  rcarmo/other-video-transcoding
```

This will go over all `*.mkv` files in the current working directory and transcode them to an `.mp4` envelope with EAC3 5.1 audio, ignoring subtitles and using only the specified CPU cores.

Like the original container, _this was designed to be used in a batch/service context_, and will skip any file that has a companion with a `.lock` extension. It will (optionally) copy the original file to a scratch folder for working in, and try to clean up the original files and `.log` files after it's done.

Also like the original, this downloads and adds `libdvdcss`, which is essential for DVD ripping--however, I have not tested encoding DVDs with this container (yet).

## Using Hardware Acceleration

My intent in building this container was to try out `ffmpeg` with hardware acceleration, but I only have Intel machines with QuickSync and `vaapi` support, so the amount of testing I was able to conduct has been limited so far.

For `vaapi` support, all that is necessary is to run the container with `--device /dev/dri`. Other encoders may require running it as `--privileged` (which I don't recommend).

See `transcode.sh` for details.
