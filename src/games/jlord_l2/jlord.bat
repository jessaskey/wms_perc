@echo off

echo Assembling Game Code...
tasmx -68 -b -y -s jlord.asm > jlord.err

echo Assembling Sound Code...
tasmx -68 -b -y -s -f20 jl_snd.asm > jl_snd.err

copy jlord.obj jlord_x.obj
split jlord_x.obj 2048
copy jlord_x.1 ic26a.716
copy jlord_x.2 ic14a.716

del jlord_x.*

echo Dumping ROM to EMU...

@echo on
norom -com1=115 -size=32 -load=8000 -top jl_snd.obj






