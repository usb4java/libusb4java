#1/bin/bash
# ============================================================================
# Build script for Mac OS X.
#
# The script automatically compiles the binary x86_64 and
# creates the corresponding JAR file in the target folder.
#
# Requirements: cmake, make, curl, jar
# ============================================================================

if [ $# -ne 1 ]
then
    echo "Syntax: $0 <ARCH>"
    exit 1
fi

# Fail on all errors
set -e

# Software versions
LIBUSB_VERSION=1.0.22

# Determine directories
cd "$(dirname $0)/.."
PROJECT_DIR="$(pwd)"
TARGET_DIR="$PROJECT_DIR/target"
BUILD_DIR="$TARGET_DIR/build"
DOWNLOAD_DIR="$TARGET_DIR/downloads"
ROOT_DIR="$BUILD_DIR/root"

# Clean up target directory
rm -rf "$BUILD_DIR"

# Create download directory if not already present
mkdir -p "$DOWNLOAD_DIR"

# Determine OS and architecture
OS=osx
OSX_ARCH=x86_64
echo "Building for platform $OS-$ARCH"

# Standard compiler and linker flags
CFLAGS="-I$ROOT_DIR/include -arch $OSX_ARCH"
LDFLAGS="-L$ROOT_DIR/lib"

# Export compiler and linker flags
export CFLAGS LDFLAGS

# Download and build libusb
LIBUSB_TARBALL="libusb-$LIBUSB_VERSION.tar.bz2"
LIBUSB_SOURCE="http://downloads.sf.net/project/libusb/libusb-1.0/libusb-$LIBUSB_VERSION/$LIBUSB_TARBALL"
LIBUSB_TARGET="$DOWNLOAD_DIR/$LIBUSB_TARBALL"
if [ ! -f "$LIBUSB_TARGET" ]
then
    curl -C - -o "$LIBUSB_TARGET.download" -L "$LIBUSB_SOURCE"
    mv -f "$LIBUSB_TARGET.download" "$LIBUSB_TARGET"
fi
mkdir -p "$BUILD_DIR/libusb"
cd "$BUILD_DIR/libusb"
tar xvf "$LIBUSB_TARGET" --strip-components=1
./configure --disable-shared --enable-static --with-pic --prefix="$ROOT_DIR"
make install-strip

# Build libusb4java
mkdir -p "$BUILD_DIR/libusb4java"
cd "$BUILD_DIR/libusb4java"
PKG_CONFIG_PATH="$ROOT_DIR/lib/pkgconfig" cmake "$PROJECT_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="" \
    -DCMAKE_OSX_ARCHITECTURES=$OSX_ARCH \
    -DLibUsb_USE_STATIC_LIBS=true
make install/strip DESTDIR="$ROOT_DIR"

# Create the JAR file
mkdir -p "$BUILD_DIR/classes/org/usb4java/$OS-$ARCH"
cp "$ROOT_DIR/lib/libusb4java.dylib" "$BUILD_DIR/classes/org/usb4java/$OS-$ARCH"
jar cf "$BUILD_DIR/libusb4java-$OS-$ARCH.jar" -C "$BUILD_DIR/classes" org
