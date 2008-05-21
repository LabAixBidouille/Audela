set ANDOR=andor
mkdir ..\include
mkdir ..\lib
copy %ANDOR%\include\Atmcd32d.h ..\include
copy %ANDOR%\include\Atmcd32d.h ..\include\win
copy %ANDOR%\lib\atmcd32m.lib ..\lib
copy %ANDOR%\bin\*.* ..\..\..\bin
