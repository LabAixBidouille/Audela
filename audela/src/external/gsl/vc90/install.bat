@echo off
rem  parametre %1 = Release ou Debug
rem Si pas de parametre , la valeur par defaut est Release
if not "%1" == "" set CONFIG=%1
if "%1" == ""     set CONFIG=Release

set sourceDir=..\gsl-1.8\gsl
set include_dir=..\..\include\win\gsl

set lib_dir=..\..\lib
set bin_dir=..\..\..\..\bin

if %CONFIG% == clean  goto target_clean

rem definition de la commande copy
rem
set COPY=xcopy /D /Y /I

rem copie des entetes des sources *.h
%COPY% %sourceDir%\*.h                          %include_dir%

rem copie des entetes des librairies
%COPY% libgsl\%CONFIG%\libgsl.lib               %lib_dir%
%COPY% libgslcblas\%CONFIG%\libgslcblas.lib     %lib_dir%

rem copie des entetes des librairies *.dll
%COPY% libgsl\%CONFIG%\libgsl.dll               %bin_dir%
%COPY% libgslcblas\%CONFIG%\libgslcblas.dll     %bin_dir%

goto target_end

:target_clean
@del /Q /s %include_dir%

del /Q %lib_dir%\libgsl.lib
del /Q %lib_dir%\libgslcblas.lib

del /Q %bin_dir%\libgsl.dll
del /Q %bin_dir%\libgslcblas.dll

:target_end

