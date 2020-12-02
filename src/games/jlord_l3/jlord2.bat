@echo off

echo Assembling Game Code...
tasmx -68 -b -y -s jlord2.asm > jlord2.err

rem main output is 32K
split jlord2.obj 4096

copy JLORD2.6 ic20.532
copy JLORD2.7 ic14.532
copy JLORD2.8 ic17.532

rem copy jlord2_x.1 ic20.532
rem copy jlord2_x.2 ic14.tmp
rem split ic14.tmp 2048
rem copy ic14a.732 ic20.532
rem copy /B ic14.1+ic20.716 ic14.532
rem del ic26a.1
rem del ic26a.2

rem del jlord2_x.*

copy ic20.532 "W:\files\Pinball\Visual Pinball\PinMame_src\roms\jngld_l3\ic20.532"
copy ic14.532 "W:\files\Pinball\Visual Pinball\PinMame_src\roms\jngld_l3\ic14.532"
copy ic17.532 "W:\files\Pinball\Visual Pinball\PinMame_src\roms\jngld_l3\ic17.532"

echo Dumping ROM to EMU...

@echo on
rem norom -com1=115 -size=32 -load=8000 -top -pause jlord2.obj






