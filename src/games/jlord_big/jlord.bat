@echo off

echo Assembling Game Code...
tasmx -68 -b -y -s jlord.asm > jlord.err

echo Assembling Sound Code...
tasmx -68 -b -y -s -f20 jl_snd.asm > jl_snd.err






