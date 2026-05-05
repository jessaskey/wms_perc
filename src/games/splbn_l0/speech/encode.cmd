@echo off
setlocal

set "INPUT_DIR=C:\Users\jess\Documents\GitHub\wms_perc\src\games\splbn_l0\speech\mp3"
set "OUTPUT_DIR=C:\Users\jess\Documents\GitHub\wms_perc\src\games\splbn_l0\speech\wav"
set "ENCODE_DIR=C:\Users\jess\Documents\GitHub\wms_perc\src\games\splbn_l0\speech\cvsd"
set "DECODE_DIR=C:\Users\jess\Documents\GitHub\wms_perc\src\games\splbn_l0\speech\decode"
set "SOURCE_DIR=C:\Users\jess\Documents\GitHub\wms_perc\src\games\splbn_l0\speech\asm"
set "SPEECH_DIR=C:\Users\jess\Documents\GitHub\wms_perc\src\games\splbn_l0\speech"

REM Create output directory if it doesn't exist
if not exist "%SPEECH_DIR%" mkdir "%SPEECH_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%ENCODE_DIR%" mkdir "%ENCODE_DIR%"
if not exist "%DECODE_DIR%" mkdir "%DECODE_DIR%"

del "%SPEECH_DIR%\speechdata.asm"

REM Loop through all MP3 files
for %%F in ("%INPUT_DIR%\*.mp3") do (
    echo Processing: %%~nxF

    rem ffmpeg -i "%%F" -acodec pcm_u8 -af "highpass=f=100,lowpass=f=3000,volume=volume=10dB:precision=fixed,arnndn=model=cb.rnnn" -ac 1 -sample_fmt u8 -ar 8000 -y "%OUTPUT_DIR%\%%~nF.wav"
    ffmpeg -i "%%F" -acodec pcm_u8 -af "highpass=f=140,lowpass=f=2000,acompressor=threshold=-18dB:ratio=2:attack=5:release=50:makeup=4,alimiter=limit=0.85" -ac 1 -sample_fmt u8 -ar 8000 -y "%OUTPUT_DIR%\%%~nF.wav"
    
    python cvsd-encoder.py  "%OUTPUT_DIR%\%%~nF.wav" "%ENCODE_DIR%\%%~nF.cvsd"
    python cvsd-decoder.py  "%ENCODE_DIR%\%%~nF.cvsd" 8000 "%DECODE_DIR%\%%~nF.wav"
    python formatter.py "%ENCODE_DIR%\%%~nF.cvsd" "%SOURCE_DIR%\%%~nF.asm"
)

echo Done!
pause

