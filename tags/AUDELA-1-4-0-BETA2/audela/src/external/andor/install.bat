set ANDOR=andor
mkdir ..\include
mkdir ..\lib
copy %ANDOR%\include\atmcd32d.h ..\include
copy %ANDOR%\lib\atmcd32m.lib ..\lib
copy %ANDOR%\bin\*.* ..\..\..\bin
