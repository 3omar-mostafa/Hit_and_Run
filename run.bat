@echo off

if not exist masm.exe echo Microsoft (R) Macro Assembler is Not Found
if not exist masm.exe echo Please download it and make sure it is masm.exe

if not exist link.exe echo Microsoft (R) Segmented Executable Linker is Not Found
if not exist link.exe echo Please download it and make sure it is link.exe

if exist graphics.obj erase graphics.obj
if exist inout.obj erase inout.obj

if exist game.exe erase game.exe

masm graphics.asm /z /Zi /Zd /v    > graphics.log ,%graphics ;
If not exist graphics.obj echo Assembling Failed , Check graphics.log for errors
If not exist graphics.obj goto end

masm inout.asm /z /Zi /Zd /v    > inout.log ,%inout ;
If not exist inout.obj echo Assembling Failed , Check inout.log for errors
If not exist inout.obj goto end


link  graphics.obj inout.obj > link.log ,game.exe,nul;
If not exist game.exe echo Linking Failed , Check link.log for errors
If not exist game.exe goto end

game.exe

:end