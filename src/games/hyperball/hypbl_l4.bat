@echo off

tasmx -68 -b -y -s hypbl_l4.asm > hypbl_l4.err

rem main output is 32K
split hypbl_l4.obj 4096


copy hypbl_l4.1 ic20.532
copy hypbl_l4.2 ic14.532
copy hypbl_l4.3 ic17.532

copy ic20.532 "D:\Program Files (x86)\Visual Pinball\VPinMame\roms\hypbl_l4\ic20.532"
copy ic14.532 "D:\Program Files (x86)\Visual Pinball\VPinMame\roms\hypbl_l4\ic14.532"
copy ic17.532 "D:\Program Files (x86)\Visual Pinball\VPinMame\roms\hypbl_l4\ic17.532"



