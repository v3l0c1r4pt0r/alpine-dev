FROM alpine:3.21 AS build

RUN apk update
RUN apk add gcc make wget git curl alpine-sdk doas

RUN adduser -D admin
USER admin

WORKDIR /home/admin
RUN git clone git://git.alpinelinux.org/aports

USER root
RUN adduser admin abuild
RUN adduser admin wheel
RUN echo 'permit nopass :wheel' >/etc/doas.d/wheel.conf
USER admin

RUN mkdir -p $HOME/.abuild
RUN abuild-keygen -a -n -i

RUN cd /home/admin/aports/main/fortify-headers && abuild fetch verify
RUN cd /home/admin/aports/main/linux-headers && abuild fetch verify
RUN cd /home/admin/aports/main/musl && abuild fetch verify
RUN cd /home/admin/aports/main/pkgconf && abuild fetch verify
RUN cd /home/admin/aports/main/zlib && abuild fetch verify
RUN cd /home/admin/aports/main/openssl && abuild fetch verify
RUN cd /home/admin/aports/main/ca-certificates && abuild fetch verify
RUN cd /home/admin/aports/main/libmd && abuild fetch verify
RUN cd /home/admin/aports/main/gmp && abuild fetch verify
RUN cd /home/admin/aports/main/mpfr4 && abuild fetch verify
RUN cd /home/admin/aports/main/mpc1 && abuild fetch verify
RUN cd /home/admin/aports/main/isl26 && abuild fetch verify
RUN cd /home/admin/aports/main/libucontext && abuild fetch verify
RUN cd /home/admin/aports/main/zstd && abuild fetch verify
RUN cd /home/admin/aports/main/binutils && abuild fetch verify
RUN cd /home/admin/aports/main/gcc && abuild fetch verify
RUN cd /home/admin/aports/main/bsd-compat-headers && abuild fetch verify
RUN cd /home/admin/aports/main/libbsd && abuild fetch verify
RUN cd /home/admin/aports/main/busybox && abuild fetch verify
RUN cd /home/admin/aports/main/make && abuild fetch verify
RUN cd /home/admin/aports/main/apk-tools && abuild fetch verify
RUN cd /home/admin/aports/main/file && abuild fetch verify
RUN cd /home/admin/aports/main/libcap && abuild fetch verify
RUN cd /home/admin/aports/main/openrc && abuild fetch verify
RUN cd /home/admin/aports/main/alpine-conf && abuild fetch verify
RUN cd /home/admin/aports/main/alpine-baselayout && abuild fetch verify
RUN cd /home/admin/aports/main/alpine-keys && abuild fetch verify
RUN cd /home/admin/aports/main/alpine-base && abuild fetch verify
RUN cd /home/admin/aports/main/patch && abuild fetch verify
RUN cd /home/admin/aports/main/build-base && abuild fetch verify
RUN cd /home/admin/aports/main/attr && abuild fetch verify
RUN cd /home/admin/aports/main/acl && abuild fetch verify
RUN cd /home/admin/aports/main/fakeroot && abuild fetch verify
RUN cd /home/admin/aports/main/tar && abuild fetch verify
RUN cd /home/admin/aports/main/lzip && abuild fetch verify
RUN cd /home/admin/aports/main/abuild && abuild fetch verify
RUN cd /home/admin/aports/main/sqlite && abuild fetch verify
RUN cd /home/admin/aports/main/lddtree && abuild fetch verify

WORKDIR /home/admin/aports/main/gcc
RUN abuild -r

RUN echo '/home/admin/packages/main' | cat - /etc/apk/repositories | doas tee /etc/apk/repositories
RUN doas apk update
RUN doas apk add gcc

# patch meson to avoid problem with ignoring default pkg-config
WORKDIR /home/admin/aports
COPY meson.patch /tmp/meson.patch
RUN patch -p1 </tmp/meson.patch

# rebuild patched meson
WORKDIR /home/admin/aports/main/meson
RUN abuild checksum
RUN abuild -r

RUN doas apk add meson

RUN sh -c 'RC=0; while true; do /home/admin/aports/scripts/bootstrap.sh -k aarch64 && break; done'
ENV CHOST aarch64
