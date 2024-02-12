FROM debian:stable-slim

ARG BUILD_DATE 
ARG COMMIT_SHA

RUN apt-get update && apt-get install -y --no-install-recommends \
  bash \
  devscripts \
  equivs \
  rsync \
  locales \
  wget gcc build-essential fakeroot git tar grep sed libncurses5-dev \
  libssl-dev libelf-dev bison flex time \
  dh-make nasm yasm \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

VOLUME /usr/src
WORKDIR /usr/src

ENTRYPOINT [ "/bin/bash", "build.sh" ]

# https://github.com/opencontainers/image-spec/blob/master/spec.md
LABEL org.opencontainers.image.title='docker-deb-build' \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.description='Generic debian image to build deb packages' \
      org.opencontainers.image.documentation='https://github.com/jesusdf/docker-deb-build/blob/master/README.md' \
      org.opencontainers.image.version='1.0' \
      org.opencontainers.image.source='https://github.com/jesusdf/docker-deb-build' \
      org.opencontainers.image.revision="${COMMIT_SHA}"