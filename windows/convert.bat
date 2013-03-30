@echo off

for %%f in (*) do ( 

verify >nul
echo.
echo Proceed?

choice /t 3 /d y
if errorlevel 2 exit /b

echo %%f - M:\Converted Files\%%~nf.mp4
HandBrakeCLI.exe -i "%%f" -o "M:\Converted Files\%%~nf.mp4" -C 4 -e x264 -q 20.0 -a 1 -E faac -B 128 -6 dpl2 -R Auto -D 0.0 -f mp4 -X 480 -m -x cabac=0:ref=2:me=umh:bframes=0:weightp=0:subme=6:8x8dct=0:trellis=0

echo.
)