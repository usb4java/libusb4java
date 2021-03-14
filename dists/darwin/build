#1/bin/bash
# ============================================================================
# Build script for Mac OS X.
#
# The script automatically compiles the binary for x86-64 and aarch64.
# Then it creates the corresponding JAR file in the target folder containing 
# both architecture builds.
# The libusb sources are pulled from the GitHub tag matching the configured 
# version.
#
# Requirements: cmake, make, curl, jar
# ============================================================================

# Fail on all errors
set -e

# Software versions
LIBUSB_VERSION=1.0.24

# Determine OS
OS=darwin

# Determine directories
cd "$(dirname $0)/../.."
PROJECT_DIR="$(pwd)"
TARGET_DIR="$PROJECT_DIR/target"
JAR_FILE=$TARGET_DIR/libusb4java-$OS.jar

# Download libusb from GitHub and unzip
DOWNLOAD_DIR="$TARGET_DIR/downloads"

# Clean up target directory
rm -rf "$TARGET_DIR"

# Create download directory if not already present
mkdir -p "$DOWNLOAD_DIR"

LIBUSB_TARBALL="v$LIBUSB_VERSION.zip"
LIBUSB_SOURCE=https://github.com/libusb/libusb/archive/$LIBUSB_TARBALL
LIBUSB_TARGET="$DOWNLOAD_DIR/$LIBUSB_TARBALL"
if [ ! -f "$LIBUSB_TARGET" ]
then
    curl -C - -o "$LIBUSB_TARGET.download" -L "$LIBUSB_SOURCE"
    mv -f "$LIBUSB_TARGET.download" "$LIBUSB_TARGET"
fi

build_architecture () {
  
    local ARCH_ID=$1
    local ARCH=$2
    echo "Building for platform $OS-$ARCH"
    local BUILD_DIR="$TARGET_DIR/build/darwin-$ARCH"
    local ROOT_DIR="$BUILD_DIR/root"

    # Standard compiler and linker flags
    local CFLAGS="-I$ROOT_DIR/include -arch $ARCH"
    local LDFLAGS="-L$ROOT_DIR/lib"

    # Export compiler and linker flags
    export CFLAGS LDFLAGS

    # Unzip libusb
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    unzip "$LIBUSB_TARGET"
    mv "$BUILD_DIR/libusb-$LIBUSB_VERSION" "$BUILD_DIR/libusb"
    cd "$BUILD_DIR/libusb"

    # Build libusb
    autoreconf -i
    ./configure --disable-shared --enable-static --with-pic --prefix="$ROOT_DIR" --host=$ARCH
    make install-strip

    # Build libusb4java
    mkdir -p "$BUILD_DIR/libusb4java"
    cd "$BUILD_DIR/libusb4java"
    PKG_CONFIG_PATH="$ROOT_DIR/lib/pkgconfig" cmake "$PROJECT_DIR" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="" \
        -DCMAKE_OSX_ARCHITECTURES=$ARCH \
        -DLibUsb_USE_STATIC_LIBS=true
    make install/strip DESTDIR="$ROOT_DIR"

    # Create the JAR file
    mkdir -p "$BUILD_DIR/classes/org/usb4java/$OS-$ARCH_ID"
    cp "$ROOT_DIR/lib/libusb4java.dylib" "$BUILD_DIR/classes/org/usb4java/$OS-$ARCH_ID"

    if [ -f "$JAR_FILE" ]; then
        jar uf "$JAR_FILE" -C "$BUILD_DIR/classes" org
    else 
        jar cf "$JAR_FILE" -C "$BUILD_DIR/classes" org
    fi
}

build_architecture x86-64 x86_64
build_architecture aarch64 arm64
