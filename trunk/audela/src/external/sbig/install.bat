set SBIG=sbig
mkdir ..\include
copy %SBIG%\include\sbigudrv.h ..\include
copy %SBIG%\lib\SBIGUDrv.lib ..\lib
copy %SBIG%\bin\sbigudrv.dll ..\..\..\bin
