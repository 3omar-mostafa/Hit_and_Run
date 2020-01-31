@echo off

if not exist masm.exe echo Microsoft (R) Macro Assembler is Not Found
if not exist masm.exe echo Please download it and make sure it is masm.exe

if not exist link.exe echo Microsoft (R) Segmented Executable Linker is Not Found
if not exist link.exe echo Please download it and make sure it is link.exe

if exist main.obj erase main.obj
if exist draw.obj erase draw.obj
if exist welcome.obj erase welcome.obj
if exist inout.obj erase inout.obj
if exist menu.obj erase menu.obj

if exist game.exe erase game.exe

masm main.asm /z /Zi /Zd /v > main.log ,main ;
If not exist main.obj echo Assembling Failed , Check main.log for errors
If not exist main.obj goto end

masm draw.asm /z /Zi /Zd /v > draw.log ,draw ;
If not exist draw.obj echo Assembling Failed , Check draw.log for errors
If not exist draw.obj goto end

masm welcome.asm /z /Zi /Zd /v > welcome.log ,welcome ;
If not exist welcome.obj echo Assembling Failed , Check welcome.log for errors
If not exist welcome.obj goto end

masm inout.asm /z /Zi /Zd /v > inout.log ,inout ;
If not exist inout.obj echo Assembling Failed , Check inout.log for errors
If not exist inout.obj goto end

masm menu.asm /z /Zi /Zd /v > menu.log ,menu ;
If not exist menu.obj echo Assembling Failed , Check menu.log for errors
If not exist menu.obj goto end

link main.obj draw.obj welcome.obj inout.obj menu.obj > link.log ,game.exe,nul;
If not exist game.exe echo Linking Failed , Check link.log for errors
If not exist game.exe goto end

game.exe

:end