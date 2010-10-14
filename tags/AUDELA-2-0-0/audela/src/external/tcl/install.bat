set TCL=tcl
mkdir ..\include
mkdir ..\lib
mkdir ..\include\win
copy %TCL%\bin\*.* ..\..\..\bin
copy %TCL%\include\*.* ..\include\win
mkdir ..\include\win\x11
copy %TCL%\include\x11\*.* ..\include\win\x11
copy %TCL%\lib\*.* ..\lib
