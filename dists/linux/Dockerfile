#
# Copyright (C) 2018 Klaus Reimer <k@ailis.de>
# See LICENSE.md for licensing information.
#

ARG DEBARCH
FROM $DEBARCH/debian:stretch

# Copy optional qemu binaries
ARG ARCH
COPY target/build/linux-$ARCH/qemu* /usr/bin/

# Install debian updates
RUN apt-get update && apt-get upgrade -y

# Workaround for armhf architecture: This package can't be installed later as a
# dependency of gcj-6-jdk (Corrupt tarball error messages) but for some reason
# it works when it is installed beforehand
RUN apt-get install -y gnome-icon-theme

# Install required debian packages
RUN apt-get install -y gcc cmake curl gperf bzip2 gcj-6-jdk

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
    curl -L http://downloads.sf.net/project/libusb/libusb-1.0/libusb-1.0.22/libusb-1.0.22.tar.bz2 | tar xvj --strip-components 1; \
    ./configure \
        --disable-shared \
        --enable-static \
        --with-pic \
        --prefix=/usr/local; \
    make install-strip; \
    rm -rf /tmp/libusb
