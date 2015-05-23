@echo off
rem ======================================================================
rem Build script for Windows.
rem
rem This script automatically compiles the windows binary for the local
rem platform and creates the JAR file in the target folder.
rem
rem Dependencies: cmake, mingw-64 tools, curl and jar must be callable
rem via PATH.
rem ======================================================================

rem ----------------------------------------------------------------------
rem Setup variables
rem ----------------------------------------------------------------------

set LIBUSB_VERSION=1.0.19
set CURRENT=%cd%
set PROJECT_DIR=%~dp0..
set OS=windows
if /i "%PROCESSOR_ARCHITECTURE%" == "amd64" (
    set ARCH=x86_64
    set LIBUSB_ARCH=MinGW64
) else (
    set ARCH=x86
    set LIBUSB_ARCH=MinGW32
)
set TARGET_DIR=%PROJECT_DIR%\target
set BUILD_DIR=%TARGET_DIR%\build
set ROOT_DIR=%TARGET_DIR%\root


rem
rem Download and unpack libusb
rem

set LIBUSB_NAME=libusb-%LIBUSB_VERSION%
set LIBUSB_ARCHIVE=%LIBUSB_NAME%.7z
mkdir "%ROOT_DIR%"
cd "%ROOT_DIR%
curl -L -o "%LIBUSB_ARCHIVE%" http://downloads.sourceforge.net/project/libusb/libusb-1.0/%LIBUSB_NAME%/%LIBUSB_ARCHIVE% || goto :error
7z -y x "%LIBUSB_ARCHIVE%" || goto :error


rem ----------------------------------------------------------------------
rem Build libusb4java
rem ----------------------------------------------------------------------

mkdir "%BUILD_DIR%"
cd "%BUILD_DIR%"

cmake "%PROJECT_DIR%" -G "MinGW Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="" ^
    -DLibUsb_INCLUDE_DIRS="%ROOT_DIR%\include\libusb-1.0" ^
    -DLibUsb_LIBRARIES="%ROOT_DIR%\%LIBUSB_ARCH%\static\libusb-1.0.a" || goto :error
make || goto :error
make install DESTDIR="%ROOT_DIR%" || goto :error


rem ----------------------------------------------------------------------
rem Create the JAR file
rem ----------------------------------------------------------------------

mkdir "classes\org\usb4java\%OS%-%ARCH%"
copy "%ROOT_DIR%\lib\libusb4java.dll" classes\org\usb4java\%OS%-%ARCH%\libusb4java.dll || goto :error
jar cf "%TARGET_DIR%\libusb4java-%OS%-%ARCH%.jar" -C classes org || goto :error


rem ----------------------------------------------------------------------
rem Clean up and go back to original directory
rem ----------------------------------------------------------------------

cd "%CURRENT%"
rmdir /s /q "%BUILD_DIR%"
rmdir /s /q "%ROOT_DIR%"
goto :EOF

:error
set ERRORCODE=%errorlevel%
echo Failed with error #%ERRORCODE%
cd "%CURRENT%"
exit /b %ERRORCODE%
