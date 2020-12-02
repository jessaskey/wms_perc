@echo off

echo Assembling Game Code...
tasmx -68 -b -y -s cbafgpd.asm > template.err

echo Dumping ROM to EMU...

@echo on
norom -com1=115 -size=32 -load=8000 -top cbafgpd.obj








