mkdir ..\include
mkdir ..\include\win
mkdir ..\include\win\gsl
@echo on
copy include\*.* ..\include\win\gsl
copy lib\*.* ..\lib
copy bin\*.* ..\..\..\bin
