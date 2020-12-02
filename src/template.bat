@echo off

tasmx -68 -b -y -s games\template\gamerom.asm > games\template\gamerom.err

tasmx -68 -b -y -s level7.asm > level7.err

copy games\template\gamerom.err+level7.err template.err > copy.err
del games\template\gamerom.err
del level7.err
del copy.err




