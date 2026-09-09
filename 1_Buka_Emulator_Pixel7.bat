@echo off
title REFLECTMED AI - Android Emulator
color 0B
echo ================================================================
echo           MENYALAKAN ANDROID EMULATOR (PIXEL 7)
echo ================================================================
echo.
set "ANDROID_SDK_ROOT=C:\Users\Administrator\AppData\Local\Android\Sdk"
set "PATH=C:\flutter\bin;C:\Users\Administrator\AppData\Local\Android\Sdk\platform-tools;C:\Users\Administrator\AppData\Local\Android\Sdk\emulator;%PATH%"

echo Membuka jendela emulator ke layar Anda...
start "" "C:\Users\Administrator\AppData\Local\Android\Sdk\emulator\emulator.exe" -avd Pixel_7_API_34 -gpu host -dns-server 8.8.8.8
echo.
echo [SUKSES] Jendela Android Emulator Pixel 7 sedang dibuka di layar Anda!
echo Tunggu sebentar hingga layar smartphone Android muncul.
echo.
pause
