
rem  parametre %1 = Release ou Debug
rem Si pas de parametre , la valeur par defaut est Release
if not "%1" == "" set CONFIG=%1
if "%1" == ""     set CONFIG=Release

rem definition de la commande copy
rem
set COPY = xcopy /D /Y /L

rem copie des entetes des sources *.h
set sourceDir=..\..\gsl-1.8\gsl
set include_dir= ..\..\..\include\win\gsl

rem copie des entetes des librairies
set lib_dir=..\..\..\lib
%COPY% %CONFIG%\libgsl.lib          %lib_dir%
%COPY% %CONFIG%\libgslcblas.lib     %lib_dir%

rem copie des entetes des librairies *.dll
set bin_dir=..\..\..\..\..\bin
%COPY% %CONFIG%\libgsl.dll          %bin_dir%
%COPY% %CONFIG%\libgslcblas.dll     %bin_dir%