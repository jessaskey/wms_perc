
echo off

echo Compiling Spellbinder...

tasmx.exe -68 -b -wtext.tab -y -s splbn_l0.asm  > splbn_l0.err
tasmx.exe -68 -b -y -s splbnsnd.asm  > splbnsnd.err 2>&1

echo ...splitting files
rem main output is 32K
split splbn_l0.obj 4096

split splbnsnd.obj 4096

md roms
del /Q roms

echo ...cleaning files
move splbn_l0.obj.1 roms\ic20.532
move splbn_l0.obj.2 roms\ic14.532
move splbn_l0.obj.3 roms\ic17.532

copy splbnsnd.obj.1 roms\speech7.532
copy splbnsnd.obj.2 roms\speech5.532
copy splbnsnd.obj.3 roms\speech6.532
copy splbnsnd.obj.4 roms\speech4.532
copy splbnsnd.obj.5 roms\sound12.532

echo ...copying files to Visual Pinball
copy roms\ic20.532 "C:\Visual Pinball\VPinMAME\roms\splbn_l0\ic20.532"
copy .\roms\ic14.532 "C:\Visual Pinball\VPinMAME\roms\splbn_l0\ic14.532"
copy .\roms\ic17.532 "C:\Visual Pinball\VPinMAME\roms\splbn_l0\ic17.532"
copy .\roms\speech7.532 "C:\Visual Pinball\VPinMAME\roms\splbn_l0\speech7.532"
copy .\roms\speech5.532 "C:\Visual Pinball\VPinMAME\roms\splbn_l0\speech5.532"
copy .\roms\speech6.532 "C:\Visual Pinball\VPinMAME\roms\splbn_l0\speech6.532"
copy .\roms\speech4.532 "C:\Visual Pinball\VPinMAME\roms\splbn_l0\speech4.532"
copy .\roms\sound12.532 "C:\Visual Pinball\VPinMAME\roms\splbn_l0\sound12.532"

pause