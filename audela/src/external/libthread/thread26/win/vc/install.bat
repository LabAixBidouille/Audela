rem  parametre %1 = Release ou Debug

rem Si pas de parametre , la valeur par defaut est Release
if not "%1" == "" set CONFIG=%1
if "%1" == "" set CONFIG=Release

set sourceDir=..\blt2.4z
set destDir=..\..\..\..\lib\thread2.6

mkdir %destDir%
copy %CONFIG%\thread2651.dll  %destDir%
