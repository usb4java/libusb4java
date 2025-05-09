@echo off

rem Variables - General
for %%I in ("%~dp0.") do set "SCRIPT_DIR=%%~fI"
set "BUILD_BAT=%SCRIPT_DIR%\build.bat"

rem Variables - Visual Studio
set "VSWHERE_EXE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "VSWHERE_OPTIONS=-latest -property installationPath -format value"
for /f "delims=" %%i in ('"%VSWHERE_EXE%" %VSWHERE_OPTIONS%') do set "VS_PATH=%%i"
set "VSDEVCMD_BAT=%VS_PATH%\Common7\Tools\VsDevCmd.bat"

rem Main
cmd /c ""%VSDEVCMD_BAT%" && "%BUILD_BAT%""
cmd /c ""%VSDEVCMD_BAT%" -host_arch=amd64 -arch=amd64 && set "PLATFORM=x64" && "%BUILD_BAT%""