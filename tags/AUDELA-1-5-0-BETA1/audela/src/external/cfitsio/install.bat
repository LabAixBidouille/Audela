set FITSIO=cfitsio2510
mkdir ..\include
mkdir ..\lib
copy %FITSIO%\cfitsio.dll ..\..\..\bin
copy %FITSIO%\cfitsio.lib ..\lib
copy %FITSIO%\fitsio.h ..\include
copy %FITSIO%\longnam.h ..\include
