# ============================================================================
# Build script for Linux.
#
# The script automatically compiles the binary for the local architecture and
# creates the corresponding JAR file in the target folder.
#
# Requirements: cmake, make, curl, jar
# ============================================================================

# Fail on all errors
set -e

# Software versions
LIBUSB_VERSION=1.0.20
EUDEV_VERSION=3.1.4

# Determine directories
cd "$(dirname $0)/.."
PROJECT_DIR="$(pwd)"
TARGET_DIR="$PROJECT_DIR/target"
ROOT_DIR="$TARGET_DIR/root"

# Clean up target directory
rm -rf "$TARGET_DIR"

# Determine OS and architecture
OS=linux
case "$(arch)" in
    "x86_64")
        ARCH=x86_64
        ;;
    "i"[3456]"86")
        ARCH=x86
        ;;
    "armv"*)
        ARCH=arm
        ;;
    *)
        echo "Unknown platform: $(arch)"
        exit 1
esac
echo "Building for platform $OS-$ARCH"

# Download and build eudev
mkdir -p "$TARGET_DIR/eudev"
cd "$TARGET_DIR/eudev"
curl -L "https://github.com/gentoo/eudev/archive/v$EUDEV_VERSION.tar.gz" \
    | tar xvz --strip-components=1
./autogen.sh
./configure --disable-shared --enable-static --with-pic --prefix="" \
    --enable-split-usr --disable-manpages --disable-kmod \
    --disable-gudev --disable-selinux --disable-blkid
make install-strip DESTDIR="$ROOT_DIR"

# Download and build libusb
mkdir -p "$TARGET_DIR/libusb"
cd "$TARGET_DIR/libusb"
curl -L "http://downloads.sf.net/project/libusb/libusb-1.0/libusb-$LIBUSB_VERSION/libusb-$LIBUSB_VERSION.tar.bz2" \
    | tar xvj --strip-components=1
CFLAGS="-I$ROOT_DIR/include" \
LDFLAGS="-L$ROOT_DIR/lib" \
./configure --disable-shared --enable-static --with-pic --prefix=""
make install-strip DESTDIR="$ROOT_DIR"

# Build libusb4java
mkdir -p "$TARGET_DIR/libusb4java"
cd "$TARGET_DIR/libusb4java"
cmake "$PROJECT_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="" \
    -DLibUsb_INCLUDE_DIRS="$ROOT_DIR/include/libusb-1.0" \
    -DLibUsb_LIBRARIES="$ROOT_DIR/lib/libusb-1.0.a;$ROOT_DIR/lib/libudev.a" \
    -DLibUsb_LDFLAGS="-pthread -lrt"
make install/strip DESTDIR="$ROOT_DIR"

# Create the JAR file
mkdir -p "$TARGET_DIR/classes/org/usb4java/$OS-$ARCH"
cp "$ROOT_DIR/lib/libusb4java.so" "$TARGET_DIR/classes/org/usb4java/$OS-$ARCH"
jar cf "$TARGET_DIR/libusb4java-$OS-$ARCH.jar" -C "$TARGET_DIR/classes" org
