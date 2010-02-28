
echo copy libdcjpeg.dll to bin directory
copy Release\libdcjpeg.dll     ..\..\..\..\bin

echo copy libdcjpeg.lib to lib directory
copy Release\libdcjpeg.lib     ..\..\..\external\lib

echo copy libdcjpeg.h to include directory
copy ..\src\libdcjpeg.h ..\..\..\external\include
