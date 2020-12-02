
echo off

echo Compiling Spellbinder...

tasmx.exe -68 -b -y -s splbn_l0.asm  > splbn_l0.err

echo ...splitting files
rem main output is 32K
split splbn_l0.obj 4096

md roms
del /Q roms

echo ...cleaning files
move splbn_l0.obj.1 roms\ic20.532
move splbn_l0.obj.2 roms\ic14.532
move splbn_l0.obj.3 roms\ic17.532

echo ...copying files to Visual Pinball
copy .\roms\ic20.532 "C:\Program Files (x86)\Visual Pinball\VPinMame\roms\splbn_l0\ic20.532"
copy .\roms\ic14.532 "C:\Program Files (x86)\Visual Pinball\VPinMame\roms\splbn_l0\ic14.532"
copy .\roms\ic17.532 "C:\Program Files (x86)\Visual Pinball\VPinMame\roms\splbn_l0\ic17.532"

pause