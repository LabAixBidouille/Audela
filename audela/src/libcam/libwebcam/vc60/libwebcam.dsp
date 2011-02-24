# Microsoft Developer Studio Project File - Name="libwebcam" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=libwebcam - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE
!MESSAGE NMAKE /f "libwebcam.mak".
!MESSAGE
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE
!MESSAGE NMAKE /f "libwebcam.mak" CFG="libwebcam - Win32 Release"
!MESSAGE
!MESSAGE Possible choices for configuration are:
!MESSAGE
!MESSAGE "libwebcam - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "libwebcam - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "libwebcam - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\Release"
# PROP BASE Intermediate_Dir ".\Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ".\Release"
# PROP Intermediate_Dir ".\Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /MT /W3 /GX /O2 /I "..\src" /I "..\..\..\include" /I "..\..\..\external\include\win" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "USE_TCL_STUBS" /D "USE_TK_STUBS" /FR /FD /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "NDEBUG"
# ADD RSC /l 0x40c /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib gdi32.lib user32.lib winspool.lib comdlg32.lib shell32.lib uuid.lib tclstub85.lib vfw32.lib /nologo /subsystem:windows /dll /machine:I386 /nodefaultlib:"msvcrt.lib" /out:"..\..\..\..\bin\libwebcam.dll" /libpath:"..\..\..\external\lib"
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "libwebcam - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\Debug"
# PROP BASE Intermediate_Dir ".\Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ".\Debug"
# PROP Intermediate_Dir ".\Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\src" /I "..\..\..\include" /I "..\..\..\external\include\win" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "USE_TCL_STUBS" /D "USE_TK_STUBS" /FR /FD /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "_DEBUG"
# ADD RSC /l 0x40c /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib tclstub85.lib vfw32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /nodefaultlib:"msvcrt.lib" /out:"..\..\..\..\bin\libwebcam.dll" /libpath:"..\..\..\external\lib"

!ENDIF

# Begin Target

# Name "libwebcam - Win32 Release"
# Name "libwebcam - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat;for;f90"
# Begin Source File

SOURCE=..\src\camera.cpp
# End Source File
# Begin Source File

SOURCE=..\src\camtcl.cpp
# End Source File
# Begin Source File

SOURCE=..\src\Capture.cpp
# End Source File
# Begin Source File

SOURCE=..\src\CaptureListener.cpp
# End Source File
# Begin Source File

SOURCE=..\src\CaptureWinVfw.cpp
# End Source File
# Begin Source File

SOURCE=..\src\CropCapture.cpp
# End Source File
# Begin Source File

SOURCE=..\src\CropConfig.cpp
# End Source File
# Begin Source File

SOURCE=..\..\libcam.c
# End Source File
# Begin Source File

SOURCE=.\libwebcam.def
# End Source File
# Begin Source File

SOURCE=..\..\util.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# Begin Source File

SOURCE=..\src\camera.h
# End Source File
# Begin Source File

SOURCE=..\src\camtcl.h
# End Source File
# Begin Source File

SOURCE=..\src\Capture.h
# End Source File
# Begin Source File

SOURCE=..\src\CaptureListener.h
# End Source File
# Begin Source File

SOURCE=..\src\CaptureWinVfw.h
# End Source File
# Begin Source File

SOURCE=..\..\..\include\libcam\libcam.h
# End Source File
# Begin Source File

SOURCE=..\src\libname.h
# End Source File
# Begin Source File

SOURCE=..\..\..\include\libcam\libstruc.h
# End Source File
# Begin Source File

SOURCE="..\src\pwc-ioctl.h"
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
