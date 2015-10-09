# ============================================================================
# Build script for Mac OS X.
#
# The script automatically compiles the multi-binary for x86 and x86_64 and
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
LIBUSB_VERSION=1.0.20

# Determine directories
cd "$(dirname $0)/.."
PROJECT_DIR="$(pwd)"
TARGET_DIR="$PROJECT_DIR/target"
ROOT_DIR="$TARGET_DIR/root"

# Clean up target directory
rm -rf "$TARGET_DIR"

# Determine OS and architecture
OS=osx
ARCH="$1"
case "$ARCH" in
    x86)
        OSX_ARCH=i386
        ;;
    *)
        OSX_ARCH="$ARCH"
esac
echo "Building for platform $OS-$ARCH"

# Download and build libusb
mkdir -p "$TARGET_DIR/libusb"
cd "$TARGET_DIR/libusb"
curl -L "http://downloads.sf.net/project/libusb/libusb-1.0/libusb-$LIBUSB_VERSION/libusb-$LIBUSB_VERSION.tar.bz2" \
    | tar xvj --strip-components=1
CFLAGS="-I$ROOT_DIR/include -arch $OSX_ARCH" \
LDFLAGS="-L$ROOT_DIR/lib" \
./configure --disable-shared --enable-static --with-pic --prefix="$ROOT_DIR"
make install-strip

# Build libusb4java
mkdir -p "$TARGET_DIR/libusb4java"
cd "$TARGET_DIR/libusb4java"
PKG_CONFIG_PATH="$ROOT_DIR/lib/pkgconfig" cmake "$PROJECT_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="" \
    -DCMAKE_OSX_ARCHITECTURES=$OSX_ARCH \
    -DLibUsb_USE_STATIC_LIBS=true
make install/strip DESTDIR="$ROOT_DIR"

# Create the JAR file
OS=osx
mkdir -p "$TARGET_DIR/classes/org/usb4java/$OS-$ARCH"
cp "$ROOT_DIR/lib/libusb4java.dylib" "$TARGET_DIR/classes/org/usb4java/$OS-$ARCH"
jar cf "$TARGET_DIR/libusb4java-$OS-$ARCH.jar" -C "$TARGET_DIR/classes" org
