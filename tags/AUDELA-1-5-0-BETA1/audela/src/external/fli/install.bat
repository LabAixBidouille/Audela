set FLI=libfli
mkdir ..\include
mkdir ..\lib
copy %FLI%\lib\windows\release\libfli.dll ..\..\..\bin
copy %FLI%\lib\windows\release\libfli.lib ..\lib
copy %FLI%\lib\libfli.h ..\include

