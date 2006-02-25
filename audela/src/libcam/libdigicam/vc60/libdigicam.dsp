# Microsoft Developer Studio Project File - Name="libdigicam" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=libdigicam - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "libdigicam.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "libdigicam.mak" CFG="libdigicam - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "libdigicam - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "libdigicam - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "libdigicam - Win32 Release"

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
# ADD CPP /nologo /W3 /GX /O2 /I "..\src" /I "..\..\..\include" /I "..\..\..\audela\libaudela\src" /I "..\..\..\external\include\win" /I "..\..\..\external\include" /D "WIN32" /D "_WINDOWS" /D "USE_TCL_STUBS" /D "USE_TK_STUBS" /FR /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "NDEBUG"
# ADD RSC /l 0x40c /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 advapi32.lib tclstub84.lib tkstub84.lib libgphoto2.lib libgphoto2_port.lib libusb.lib /nologo /subsystem:windows /dll /machine:I386 /nodefaultlib:"msvcrt.lib" /out:"..\..\..\..\bin\libdigicam.dll" /libpath:"..\..\..\external\lib"

!ELSEIF  "$(CFG)" == "libdigicam - Win32 Debug"

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
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /I "..\src" /I "..\..\..\include" /I "..\..\..\audela\libaudela\src" /I "..\..\..\external\include\win" /I "..\..\..\external\tcl\tcl\include" /I "..\..\..\external\libftd2xx\include" /I "..\..\..\external\libgphoto2\include" /I "..\..\..\external\libusb\include" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "USE_TCL_STUBS" /D "USE_TK_STUBS" /FR /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "_DEBUG"
# ADD RSC /l 0x40c /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib ..\..\..\external\tcl\tcl\lib\tclstub84.lib ..\..\..\external\tcl\tcl\lib\tkstub84.lib ftd2xx.lib libgphoto2.lib libgphoto2_port.lib libusb.lib /nologo /subsystem:windows /dll /debug /machine:I386 /nodefaultlib:"msvcrt.lib" /out:"..\..\..\..\bin\libdigicam.dll" /libpath:"..\..\..\external\libftd2xx\lib" /libpath:"..\..\..\external\libgphoto2\lib" /libpath:"..\..\..\external\libusb\lib"

!ENDIF 

# Begin Target

# Name "libdigicam - Win32 Release"
# Name "libdigicam - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat;for;f90"
# Begin Source File

SOURCE=..\src\camera.c
# End Source File
# Begin Source File

SOURCE=..\src\camtcl.c
# End Source File
# Begin Source File

SOURCE=..\src\gp_api.c
# End Source File
# Begin Source File

SOURCE=..\..\libcam.c
# End Source File
# Begin Source File

SOURCE=.\libdigicam.def
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

SOURCE=..\src\gp_api.h
# End Source File
# Begin Source File

SOURCE=..\src\libname.h
# End Source File
# Begin Source File

SOURCE=..\src\quickremote.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
