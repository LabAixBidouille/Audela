rem installation des librairies de ffmpeg

set srcDir=..\ffmpeg-0.8.5-win\bin
set destDir=..\..\..\..\bin

rem je cree le repertoire destination s'il n'existe pas deja
mkdir %destDir%

@echo on
copy %srcDir%\*.dll   %destDir%

