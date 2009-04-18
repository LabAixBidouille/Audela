set FLI=fli-dist-1.71\libfli
mkdir ..\include
mkdir ..\lib
copy %FLI%\windows\release\libfli.dll ..\..\..\bin
copy %FLI%\windows\release\libfli.lib ..\lib
copy %FLI%\libfli.h ..\include
