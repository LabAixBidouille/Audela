echo copy libdcraw.dll to bin directory
copy Release\*.dll     ..\..\..\..\bin

echo copy libdcraw.lib to lib directory
copy Release\*.lib     ..\..\lib

echo copy libdcraw.h to include directory
copy ..\src\libdcraw.h ..\..\include
