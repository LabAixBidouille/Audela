mkdir ..\include
mkdir ..\include\win
mkdir ..\include\win\gsl
@echo
copy include\*.* ..\include\win\gsl
copy lib\*.* ..\lib
copy bin\*.* ..\..\..\bin
