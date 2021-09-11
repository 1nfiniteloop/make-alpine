ARG ARCH=amd64
FROM --platform="linux/${ARCH}" alpine:3.14

RUN sed -i 's|dl-cdn.alpinelinux.org/alpine|ftp.acc.umu.se/mirror/alpinelinux.org|g' /etc/apk/repositories

RUN apk update \
    && apk add --no-cache \
      bash \
      dosfstools \
      e2fsprogs \
      git \
      mtools \
      sfdisk \
    && rm -r /var/cache/apk/*

RUN adduser \
      -G abuild \
      -D \
      build \
    && addgroup sudo \
    && adduser build sudo \
    && echo -e "\n# Allow sudo without password\n%sudo ALL=(ALL) NOPASSWD:ALL\n" >> /etc/sudoers

ADD make-alpine /usr/local/bin
ADD config /usr/local/lib/make-alpine/config
ADD tools /usr/local/lib/make-alpine/tools

USER build
ENV USER=build
