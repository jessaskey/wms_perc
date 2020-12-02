@echo off

echo Assembling Game Code...
tasmx -68 -b -y -s cbafgpd.asm > cbafgpd.err

split cbafgpd.obj 2048
copy cbafgpd.1 ic26.716
copy cbafgpd.2 ic14.716

del cbafgpd.1
del cbafgpd.2

echo Dumping ROM to EMU...

@echo on
norom -com1=115 -size=8 -load=e000 -top cbafgpd.obj

copy ic14.716 "E:\jess\Desktop\Jess' Stuff\Pinball\vpinmame\roms\jngld_l2\"







