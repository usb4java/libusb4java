cd "$(dirname $0)"
SRCDIR="$(pwd)/.."
TARGETDIR="$SRCDIR/target"
TMPDIR="$TARGETDIR/tmp"
DOWNLOADS="$TARGETDIR/downloads"

UDEV_VERSION="2.1.1"

LIBUSB="stable"
LIBUSB_STABLE_VERSION="1.0.19"
LIBUSB_STABLE_RC=""
LIBUSB_BETA_VERSION="1.0.20"
LIBUSB_BETA_RC="-rc1"

build()
{
    UDEV_NAME="eudev-$UDEV_VERSION"
    UDEV_ARCHIVE="$UDEV_NAME.tar.gz"
    UDEV_URL="http://dev.gentoo.org/~blueness/eudev/$UDEV_ARCHIVE"

    if [ "$LIBUSB" = "stable" ]
    then
        LIBUSB_NAME="libusb-$LIBUSB_STABLE_VERSION$LIBUSB_STABLE_RC"
        LIBUSB_ARCHIVE="$LIBUSB_NAME.tar.bz2"
        LIBUSB_URL="http://downloads.sf.net/project/libusb/libusb-1.0/$LIBUSB_NAME/$LIBUSB_ARCHIVE"
    else
        LIBUSB_NAME="libusb-$LIBUSB_BETA_VERSION$LIBUSB_BETA_RC"
        LIBUSB_ARCHIVE="$LIBUSB_NAME.tar.bz2"
        LIBUSB_URL="http://downloads.sf.net/project/libusb/libusb-1.0/$LIBUSB_NAME/$LIBUSB_ARCHIVE"
    fi

    JAR="$TARGETDIR/libusb4java-$OS-$ARCH.jar"
    CLASSESDIR="$TARGETDIR/classes"
    PACKAGE="org/usb4java/$OS-$ARCH"
    DISTDIR="$CLASSESDIR/$PACKAGE"

    # Only Windows needs the shared library, the others want static ones.
    if [ "$OS" = "windows"  ]
    then
        LIB_CONFIG="--disable-static --enable-shared"
    else
        LIB_CONFIG="--enable-static --disable-shared"
    fi

    # Clean up
    rm -rf "$TMPDIR"
    rm -rf "$DISTDIR"

    # Udev available only on Linux
    if [ "$OS" = "linux"  ]
    then

    if  [ "$UDEV_SUPPORT" = "yes" ]
    then
        # Download udev if necessary
        mkdir -p "$DOWNLOADS"
        if [ ! -e "$DOWNLOADS/$UDEV_ARCHIVE" ]
        then
            if type curl >/dev/null 2>&1
            then
                curl -L -o "$DOWNLOADS/$UDEV_ARCHIVE" "$UDEV_URL"
            else
                wget -O "$DOWNLOADS/$UDEV_ARCHIVE" "$UDEV_URL"
            fi
        fi

        UDEV_CONFIG="--enable-split-usr --disable-gtk-doc --disable-manpages --disable-gudev \
            --disable-introspection --disable-keymap --disable-libkmod --disable-modules \
            --disable-selinux --disable-rule-generator --disable-blkid $UDEV_CONFIG"

        # Unpack and compile udev
        mkdir -p "$TMPDIR"
        cd "$TMPDIR"
        tar xfz "$DOWNLOADS/$UDEV_ARCHIVE"
        cd "$UDEV_NAME"
        CC="$CC" \
        LIBS="$UDEV_LIBS" \
        CFLAGS="$CFLAGS $UDEV_CFLAGS" \
        ./configure --prefix="$TMPDIR" --host="$HOST" --with-pic $LIB_CONFIG $UDEV_CONFIG
        make clean install-strip V=1

        # Enable udev support if selected
        LIBUSB_CONFIG="--enable-udev $LIBUSB_CONFIG"
        USB4JAVA_LIBS="$USB4JAVA_LIBS -ludev -lrt"
    else
        # Disable udev support if not selected
        LIBUSB_CONFIG="--disable-udev $LIBUSB_CONFIG"
    fi

    fi

    # Download libusb if necessary
    mkdir -p "$DOWNLOADS"
    if [ ! -e "$DOWNLOADS/$LIBUSB_ARCHIVE" ]
    then
        if type curl >/dev/null 2>&1
        then
            curl -L -o "$DOWNLOADS/$LIBUSB_ARCHIVE" "$LIBUSB_URL"
        else
            wget -O "$DOWNLOADS/$LIBUSB_ARCHIVE" "$LIBUSB_URL"
        fi
    fi

    # Unpack and compile libusb
    mkdir -p "$TMPDIR"
    cd "$TMPDIR"
    tar xfj "$DOWNLOADS/$LIBUSB_ARCHIVE"
    cd "$LIBUSB_NAME"
    CC="$CC" \
    PKG_CONFIG_PATH="$TMPDIR/lib/pkgconfig" \
    LIBS="$LIBUSB_LIBS" \
    CFLAGS="$CFLAGS $LIBUSB_CFLAGS" \
    CPPFLAGS="$CPPFLAGS -I$TMPDIR/include" \
    LDFLAGS="$LDFLAGS -L$TMPDIR/lib" \
    ./configure --prefix="$TMPDIR" --host="$HOST" --with-pic $LIB_CONFIG $LIBUSB_CONFIG
    make clean install-strip V=1

    # Build autoconf stuff of usb4java if needed
    cd "$SRCDIR"
    if [ ! -e configure ]
    then
        ./autogen.sh
    fi

    # Build libusb4java
    CC="$CC" \
    PKG_CONFIG_PATH="$TMPDIR/lib/pkgconfig" \
    LIBS="$USB4JAVA_LIBS" \
    CFLAGS="$CFLAGS $USB4JAVA_CFLAGS" \
    CPPFLAGS="$CPPFLAGS -I$TMPDIR/include" \
    LDFLAGS="$LDFLAGS -L$TMPDIR/lib" \
    ./configure --prefix=/ --host="$HOST" $USB4JAVA_CONFIG
    make clean install-strip DESTDIR="$TMPDIR" V=1

    # Copy dist files to java resources directory
    mkdir -p "$DISTDIR"
    cp -faL 2>/dev/null \
        "$TMPDIR/lib/libusb4java.so" \
        "$TMPDIR/bin/libusb-1.0.dll" \
        "$DISTDIR" || true
    cp -faL 2>/dev/null \
        "$TMPDIR/bin/libusb4java-1.dll" \
        "$DISTDIR/libusb4java.dll" || true
    cp -faL 2>/dev/null \
        "$TMPDIR/lib/libusb4java.dylib" \
        "$DISTDIR/libusb4java.dylib" || true
        
    # Remove executable flag from dist files
    chmod -x "$DISTDIR/"*

    # Create the JAR file
    jar cf "$JAR" -C "$CLASSESDIR" "$PACKAGE"

    # Cleanup
    rm -rf "$TMPDIR"
}
