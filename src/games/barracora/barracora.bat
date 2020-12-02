@echo off

echo Assembling Game Code...
..\..\tasmx -68 -b -y -s barracora.asm > barracora.err

rename barracora.obj bar_x.obj
split bar_x.obj 2048
copy bar_x.1 ic26.716
copy bar_x.2 ic14.716

del bar_x.*

pause





