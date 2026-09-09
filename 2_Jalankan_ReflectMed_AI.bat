@echo off
title REFLECTMED AI - Flutter Native Runner
color 0A
echo ================================================================
echo              MENJALANKAN APLIKASI REFLECTMED AI
echo ================================================================
echo.
set "ANDROID_SDK_ROOT=C:\Users\Administrator\AppData\Local\Android\Sdk"
set "PATH=C:\flutter\bin;C:\Users\Administrator\AppData\Local\Android\Sdk\platform-tools;C:\Users\Administrator\AppData\Local\Android\Sdk\emulator;%PATH%"

cd /d "%~dp0"
echo Mengompilasi dan memasang aplikasi ke Android Emulator...
echo.
flutter run
echo.
pause
