echo OFF

set STXSourcePath=D:\ST\Developpement\STGFXEngine_V01\asm
set STXOut=D:\ST\Developpement\STGFXEngine_V01\bin

echo ASSEMBLE STX_LIB.s
vc -v -c "%STXSourcePath%\STGFXLIB.S" -o "%STXOut%\STGFXLIB.o"

pause

