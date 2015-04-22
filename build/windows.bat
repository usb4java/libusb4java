@echo off
rem ======================================================================
rem Build script for Windows.
rem
rem Execute the script inside the Visual Studio Command line prompt for
rem 64 bit or 32 bit. The script automatically compiles the binary for
rem the corresponding platform and creates the JAR file in the target
rem folder.
rem
rem Dependencies: cmake, nmake and jar must be callable via PATH.
rem ======================================================================

rem ----------------------------------------------------------------------
rem Setup variables
rem ----------------------------------------------------------------------

set LIBUSB_VERSION=1.0.19
set LIBUSB_RC=-rc1
set CURRENT=%cd%
set PROJECT_DIR=%~dp0..
set OS=windows
if /i "%Platform%" == "x64" (
    set ARCH=x86_64
    set LIBUSB_ARCH=MS64
) else (
    set ARCH=x86
    set LIBUSB_ARCH=MS32
)
set TARGET_DIR=%PROJECT_DIR%\target
set BUILD_DIR=%TARGET_DIR%\build
set ROOT_DIR=%TARGET_DIR%\root


rem
rem Download and unpack libusb
rem

set LIBUSB_NAME=libusb-%LIBUSB_VERSION%
set LIBUSB_ARCHIVE=%LIBUSB_NAME%%LIBUSB_RC%-win.7z
mkdir "%ROOT_DIR%"
cd "%ROOT_DIR%
curl -L -o "%LIBUSB_ARCHIVE%" ftp://ftp.heanet.ie/pub/download.sourceforge.net/pub/sourceforge/l/li/libusb/libusb-1.0/%LIBUSB_NAME%/%LIBUSB_ARCHIVE% || goto :error
7z -y x "%LIBUSB_ARCHIVE%" || goto :error


rem ----------------------------------------------------------------------
rem Build libusb4java
rem ----------------------------------------------------------------------

mkdir "%BUILD_DIR%"
cd "%BUILD_DIR%"

cmake "%PROJECT_DIR%" -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="" ^
    -DLibUsb_INCLUDE_DIR="%ROOT_DIR%\include" ^
    -DLibUsb_LIBRARY="%ROOT_DIR%\%LIBUSB_ARCH%\static\libusb-1.0.lib" || goto :error
nmake || goto :error
nmake install DESTDIR="%ROOT_DIR%" || goto :error


rem ----------------------------------------------------------------------
rem Create the JAR file
rem ----------------------------------------------------------------------

mkdir "classes\org\usb4java\%OS%-%ARCH%"
copy "%ROOT_DIR%\lib\usb4java.dll" classes\org\usb4java\%OS%-%ARCH%\libusb4java.dll || goto :error
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
