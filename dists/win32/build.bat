@echo off
rem ======================================================================
rem Build script for Windows.
rem
rem Execute the script inside the Visual Studio Command line prompt for
rem 64 bit or 32 bit. The script automatically compiles the binary for
rem the corresponding platform and creates the JAR file in the target
rem folder.
rem
rem Dependencies: cmake, curl, jar and 7z must be callable via PATH.
rem Visual Studio 2017 Build Tools must be installed.
rem ======================================================================

rem ----------------------------------------------------------------------
rem Setup variables
rem ----------------------------------------------------------------------

set LIBUSB_VERSION=1.0.22
set CURRENT=%cd%
set PROJECT_DIR=%~dp0..\..
set OS=win32
if /i "%Platform%" == "x64" (
    set ARCH=x86-64
    set LIBUSB_ARCH=MS64
) else (
    set ARCH=x86
    set LIBUSB_ARCH=MS32
)
set TARGET_DIR=%PROJECT_DIR%\target
set BUILD_DIR=%TARGET_DIR%\build\%OS%-%ARCH%
set ROOT_DIR=%TARGET_DIR%\root


rem
rem Compile libusb.
rem We do this manually because we need the /MT option and the provided
rem build script unfortunately only works with an old Windows DDK instead
rem of using Visual Studio.
rem

set LIBUSB_NAME=libusb-%LIBUSB_VERSION%
set LIBUSB_COMPRESSED_ARCHIVE=%LIBUSB_NAME%.tar.bz2
set LIBUSB_ARCHIVE=%LIBUSB_NAME%.tar
mkdir "%ROOT_DIR%"
cd "%ROOT_DIR%
curl -L -o "%LIBUSB_COMPRESSED_ARCHIVE%" http://downloads.sourceforge.net/project/libusb/libusb-1.0/%LIBUSB_NAME%/%LIBUSB_COMPRESSED_ARCHIVE% || goto :error
7z -y x "%LIBUSB_COMPRESSED_ARCHIVE%" || goto :error
7z -y x "%LIBUSB_ARCHIVE%" || goto :error
cd "%LIBUSB_NAME%"
mkdir build
cd build
cl /DHAVE_STRUCT_TIMESPEC /nologo /c /MT /I..\libusb /I..\msvc ..\libusb\*.c ..\libusb\os\windows*.c ..\libusb\os\*windows.c
lib /nologo /out:libusb.lib *.obj


rem ----------------------------------------------------------------------
rem Build libusb4java
rem ----------------------------------------------------------------------

mkdir "%BUILD_DIR%"
cd "%BUILD_DIR%"

cmake "%PROJECT_DIR%" -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="" ^
    -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /D NDEBUG" ^
    -DLibUsb_INCLUDE_DIRS="%ROOT_DIR%\%LIBUSB_NAME%\libusb" ^
    -DLibUsb_LIBRARIES="%ROOT_DIR%\%LIBUSB_NAME%\build\libusb.lib" || goto :error
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

:end
echo Finished
