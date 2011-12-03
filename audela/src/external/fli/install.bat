rem  parametre %1 = Release ou Debug
echo on

rem Si pas de parametre , la valeur par defaut est Release
if not "%1" == "" set CONFIG=%1
if "%1" == "" set CONFIG=Release

set FLI=fli-dist-1.71\libfli
mkdir ..\include
mkdir ..\lib
copy %FLI%\windows\%CONFIG%\libfli.lib ..\lib
copy %FLI%\libfli.h ..\include
