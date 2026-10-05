@echo off
setlocal
set "TARGET=%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp"
if not exist "%TARGET%" mkdir "%TARGET%"
copy /Y "%~dp0Scripts\Comp\MotionAI_29YURO.lua" "%TARGET%\MotionAI_29YURO.lua" >nul
if errorlevel 1 (
  echo.
  echo INSTALLATION FEHLGESCHLAGEN.
  echo Kopiere Scripts\Comp\MotionAI_29YURO.lua manuell nach:
  echo %TARGET%
  pause
  exit /b 1
)
echo.
echo Motion AI by 29YURO wurde installiert.
echo Starte DaVinci Resolve jetzt komplett neu.
echo Danach: Fusion-Seite ^> Workspace/Scripts bzw. Scripts ^> Comp ^> MotionAI_29YURO
pause
