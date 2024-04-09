#
# Copyright (C) 2018 Klaus Reimer <k@ailis.de>
# See LICENSE.md for licensing information.
#

ARG DOCKER_ARCH
FROM $DOCKER_ARCH/debian:bullseye

ARG OS_ARCH
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-$OS_ARCH

ENV LIBUSB_VERSION=1.0.24

# Copy optional qemu binaries
ARG ARCH
COPY target/build/linux-$ARCH/qemu* /usr/bin/

# Install debian updates
RUN apt update && apt upgrade -y

# Workaround for armhf architecture: This package can't be installed later as a
# dependency of gcj-6-jdk (Corrupt tarball error messages) but for some reason
# it works when it is installed beforehand
RUN apt install -y gnome-icon-theme

# Install required debian packages
RUN apt install -y gcc cmake curl gperf bzip2 openjdk-11-jdk

# Install eudev
RUN mkdir -p /tmp/eudev; \
    cd /tmp/eudev; \
    curl -L http://dev.gentoo.org/~blueness/eudev/eudev-3.2.6.tar.gz | tar xvz --strip-components 1; \
    ./configure \
        --disable-shared \
        --enable-static \
        --with-pic \
        --enable-split-usr \
        --disable-manpages \
        --disable-kmod \
        --disable-selinux \
        --disable-blkid \
        --prefix=/usr/local; \
    make install-strip; \
    rm -rf /tmp/eudev

# Install libusb
RUN mkdir -p /tmp/libusb; \
    cd /tmp/libusb; \
    curl -L https://github.com/libusb/libusb/releases/download/v$LIBUSB_VERSION/libusb-$LIBUSB_VERSION.tar.bz2 | tar xvj --strip-components 1; \
    ./configure \
        --disable-shared \
        --enable-static \
        --with-pic \
        --prefix=/usr/local; \
    make install-strip; \
    rm -rf /tmp/libusb
