set VotreProgPath=D:\ST\Developpement\Monprog
set STXPath=D:\ST\STX_Engine\librairie
set OutPath=D:\

vc -v -I%STXPath% %VotreProgPath%\main.c %STXPath%\STGFXLIB.o -o %OutPath%\MonProg.PRG

pause