@echo off

tasmx -68 -b -y -s hy_game.asm > hy_game.err

tasmx -68 -b -y -s hy_sys.asm > hy_sys.err

copy hy_game.err+hy_sys.err hyperball.err > copy.err
del hy_game.err
del hy_sys.err
del copy.err




