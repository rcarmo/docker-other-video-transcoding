ARG BASE
FROM ${BASE} as base

MAINTAINER Rui Carmo https://github.com/rcarmo

# transcoder image based on https://github.com/donmelton/other_video_transcoding

# The current official Ruby image is Debian buster, so we need to:
# * Enable contrib (and non-free, for good measure)
# * freshen it up a little
# * add ffmpeg/ffprobe and mkvtoolnix/mkvpropedit
# * rebuild libdvdcss so we can actually read DVDs

ENV DEBIAN_FRONTEND noninteractive

COPY rootfs /
ADD init.sh /init
ADD transcode.sh /transcode

RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y \
     libdvd-pkg \
     ffmpeg \
     mkvtoolnix \
     sudo \
 && dpkg-reconfigure libdvd-pkg \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && sudo gem install other_video_transcoding \
 && chmod +x /init /transcode
 
# Allow user to set uid/gid for Docker process
ENV PGID=1000
ENV PUID=1000
ENV EXTENSION=mkv
ENV PAUSES="false"
ENV AUDIO_CODEC="EAAC"
ENV SCRATCH_FOLDER=""
ENV RANDOM_PICK="false"
ENV HOSTNAME="other-video-transcoder"

WORKDIR /data
VOLUME /data
CMD ["/init"]

ARG VCS_REF
ARG VCS_URL
ARG BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.build-date=$BUILD_DATE
