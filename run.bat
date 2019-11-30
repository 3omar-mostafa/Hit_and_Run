@echo off

if not exist masm.exe echo Microsoft (R) Macro Assembler is Not Found
if not exist masm.exe echo Please download it and make sure it is masm.exe

if not exist link.exe echo Microsoft (R) Segmented Executable Linker is Not Found
if not exist link.exe echo Please download it and make sure it is link.exe

if exist main.obj erase main.obj

if exist game.exe erase game.exe

masm main.asm /z /Zi /Zd /v > main.log ,main ;
If not exist main.obj echo Assembling Failed , Check main.log for errors
If not exist main.obj goto end

link  main.obj > link.log ,game.exe,nul;
If not exist game.exe echo Linking Failed , Check link.log for errors
If not exist game.exe goto end

game.exe

:end