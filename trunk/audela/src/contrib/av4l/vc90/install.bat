rem  parametre %1 = Release ou Debug

rem Si pas de parametre , la valeur par defaut est Release
if not "%1" == "" set CONFIG=%1
if "%1" == "" set CONFIG=Release

set sourceDir=..\src
set destDir=..\..\..\..\bin

mkdir %destDir%

echo on
copy %CONFIG%\libavi.dll   %destDir%
rem je supprime la dll du repertoire intermediaire pour forcer un nouveau link si on change de mode de compilation Debug/Release
del  %CONFIG%\libavi.dll
