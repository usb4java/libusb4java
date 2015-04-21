# ======================================================================
# Build script for Linux.
#
# The script automatically compiles the binary for the corresponding 
# platform and creates the JAR file in the target folder.
#
# Dependencies: cmake, make, curl
# ======================================================================

set -e


# ----------------------------------------------------------------------
# Setup variables
# ----------------------------------------------------------------------

LIBUSB_VERSION=1.0.19
EUDEV_VERSION=3.0

CURRENT=$(realpath $(dirname $0))
PROJECT_DIR="$CURRENT/.."
OS=linux
if [ "$(arch)" == "x86_64" ]
then
    ARCH=x86_64
elif [ "$(arch)" == "armv7l" ]
then
    ARCH=arm    
else
    ARCH=x86
fi
TARGET_DIR="$PROJECT_DIR/target"
BUILD_DIR="$TARGET_DIR/build"
DEPS_DIR="$TARGET_DIR/deps"

mkdir -p "$DEPS_DIR"


# ----------------------------------------------------------------------
# Download and build eudev
# ----------------------------------------------------------------------

EUDEV_NAME="eudev-$EUDEV_VERSION"
EUDEV_ARCHIVE="$EUDEV_NAME.tar.gz"
EUDEV_URL="http://dev.gentoo.org/~blueness/eudev/$EUDEV_ARCHIVE"
cd "$DEPS_DIR"
curl -L "$EUDEV_URL" | tar xvz
cd "$EUDEV_NAME"
./configure --disable-shared --enable-static --with-pic --prefix="" \
    --enable-split-usr --disable-manpages --disable-kmod \
    --disable-gudev --disable-selinux --disable-blkid
make
make install-strip DESTDIR="$DEPS_DIR"


# ----------------------------------------------------------------------
# Download and build libusb
# ----------------------------------------------------------------------

LIBUSB_NAME="libusb-$LIBUSB_VERSION"
LIBUSB_ARCHIVE="$LIBUSB_NAME.tar.bz2"
LIBUSB_URL="http://downloads.sf.net/project/libusb/libusb-1.0/$LIBUSB_NAME/$LIBUSB_ARCHIVE"
cd "$DEPS_DIR"
curl -L "$LIBUSB_URL" | tar xvj
cd "$LIBUSB_NAME"
CFLAGS="-I$DEPS_DIR/include" \
LDFLAGS="-L$DEPS_DIR/lib" \
./configure --disable-shared --enable-static --with-pic --prefix=""
make
make install-strip DESTDIR="$DEPS_DIR"


# ----------------------------------------------------------------------
# Build libusb4java
# ----------------------------------------------------------------------

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
cmake "$PROJECT_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="" \
    -DLibUsb_INCLUDE_DIR="$DEPS_DIR/include" \
    -DLibUsb_LIBRARY="$DEPS_DIR/lib/libusb-1.0.a" \
    -DLibUdev_INCLUDE_DIR="$DEPS_DIR/include" \
    -DLibUdev_LIBRARY="$DEPS_DIR/lib/libudev.a"
make
make install/strip DESTDIR="$DEPS_DIR"


# ----------------------------------------------------------------------
# Create the JAR file
# ----------------------------------------------------------------------

mkdir -p "classes/org/usb4java/$OS-$ARCH"
cp src/libusb4java.so classes/org/usb4java/$OS-$ARCH/
jar cf "$TARGET_DIR/libusb4java-$OS-$ARCH.jar" -C classes org


# ----------------------------------------------------------------------
# Clean up and go back to original directory
# ----------------------------------------------------------------------

cd $CURRENT
rm -rf "$BUILD_DIR"
rm -rf "$DEPS_DIR"
