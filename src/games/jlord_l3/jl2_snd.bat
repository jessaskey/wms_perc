echo Assembling Sound Code...
tasmx -68 -b -y -s -f20 jl2_snd.asm > jl2_snd.err

copy jl2_snd.obj "W:\files\Pinball\Visual Pinball\PinMame_src\roms\jlordb_l3\sound.rom"
copy jl2_snd.obj jl2sndx.obj
split jl2sndx.obj 4096
copy jl2sndx.1 speech7.532
copy jl2sndx.2 speech5.532
copy jl2sndx.3 speech6.532
copy jl2sndx.4 speech4.532
copy jl2sndx.5 soundjl3.532

copy jl2sndx.5 jl2sndx.tmp
split jl2sndx.tmp 2048
copy jl2sndx.2 sound3.716

copy speech7.532 "W:\files\Pinball\Visual Pinball\PinMame_src\roms\jngld_l3\"
copy speech6.532 "W:\files\Pinball\Visual Pinball\PinMame_src\roms\jngld_l3\"
copy speech5.532 "W:\files\Pinball\Visual Pinball\PinMame_src\roms\jngld_l3\"
copy speech4.532 "W:\files\Pinball\Visual Pinball\PinMame_src\roms\jngld_l3\"
copy soundjl3.532 "W:\files\Pinball\Visual Pinball\PinMame_src\roms\jngld_l3\"


del jl2sndx.*

echo Dumping ROM to EMU...

@echo on
norom -com1=115 -size=32 -load=8000 -top jl2_snd.obj

