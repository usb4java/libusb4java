#
# Copyright (C) 2018 Klaus Reimer <k@ailis.de>
# See LICENSE.md for licensing information.
#

ARG DOCKER_ARCH
FROM $DOCKER_ARCH/debian:bullseye

ARG OS_ARCH
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-$OS_ARCH

ENV LIBUSB_VERSION=1.0.24
ENV EUDEV_VERSION=3.2.14

# Copy optional qemu binaries
ARG ARCH
COPY target/build/linux-$ARCH/qemu* /usr/bin/

# Install debian updates
RUN apt update && apt upgrade -y

# Install required debian packages
RUN apt install -y gnome-icon-theme gcc cmake curl gperf bzip2 openjdk-11-jdk

# Install eudev
RUN mkdir -p /tmp/eudev; \
    cd /tmp/eudev; \
    curl -L https://github.com/eudev-project/eudev/releases/download/v$EUDEV_VERSION/eudev-$EUDEV_VERSION.tar.gz | tar xvz --strip-components 1; \
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
