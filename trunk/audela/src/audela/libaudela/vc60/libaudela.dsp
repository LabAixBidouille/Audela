# Microsoft Developer Studio Project File - Name="libaudela" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=libaudela - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "libaudela.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "libaudela.mak" CFG="libaudela - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "libaudela - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "libaudela - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "libaudela - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "LIBAUDELA_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /I "..\src" /I "..\..\..\include" /I "..\..\..\external\include" /I "..\..\..\external\include\win" /I "..\..\..\external\porttalk" /D "WIN32" /D "_WINDOWS" /D "USE_TCL_STUBS" /D "USE_TK_STUBS" /D "USE_COMPOSITELESS_PHOTO_PUT_BLOCK" /D "USE_COMPAT_CONST" /D "LIBAUDELA_EXPORTS" /D "TCL_THREADS" /FR /Fo".\Release/" /Fd".\Release/" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "NDEBUG"
# ADD RSC /l 0x40c /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib tkstub85.lib tclstub85.lib wsock32.lib version.lib libdcjpeg.lib libdcraw.lib pthread.lib /nologo /dll /machine:I386 /nodefaultlib:"msvcrt.lib" /out:"..\..\..\..\bin\libaudela.dll" /libpath:"..\..\..\external\lib"
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds=echo on	if not exist ..\..\lib (mkdir ..\..\lib)	copy release\libaudela.lib ..\..\lib	if not exist ..\..\include (mkdir ..\..\include)	copy ..\src\audela.h ..\..\include	copy ..\src\cbuffer.h ..\..\include	copy ..\src\cdevice.h ..\..\include	copy ..\src\cerror.h ..\..\include	copy ..\src\cpixels.h ..\..\include	copy ..\src\cpool.h ..\..\include	copy ..\src\fitskw.h ..\..\include	copy ..\src\libstd.h ..\..\include	copy ..\src\libtt.h ..\..\include	copy ..\src\palette.h ..\..\include	copy ..\src\cpixelsgray.h ..\..\include	copy ..\src\cpixelsrgb.h ..\..\include
# End Special Build Tool

!ELSEIF  "$(CFG)" == "libaudela - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "LIBAUDELA_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /GX /Zi /I "..\src" /I "..\..\..\include" /I "..\..\..\external\include\win" /I "..\..\..\external\porttalk" /I "..\..\..\external\include" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "USE_TCL_STUBS" /D "USE_COMPAT_CONST" /D "LIBAUDELA_EXPORTS" /D "TCL_THREADS" /FR /Fo".\Debug/" /Fd".\Debug/" /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "_DEBUG"
# ADD RSC /l 0x40c /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib advapi32.lib wsock32.lib tclstub85.lib version.lib libdcraw.lib libdcjpeg.lib pthread.lib /nologo /dll /debug /machine:I386 /nodefaultlib:"msvcrt" /out:"..\..\..\..\bin\libaudela.dll " /pdbtype:sept /libpath:"..\..\..\external\lib"
# SUBTRACT LINK32 /pdb:none /nodefaultlib
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds=echo on	if not exist ..\..\lib (mkdir ..\..\lib)	copy debug\libaudela.lib ..\..\lib	if not exist ..\..\include (mkdir ..\..\include)	copy ..\src\audela.h ..\..\include	copy ..\src\cbuffer.h ..\..\include	copy ..\src\cdevice.h ..\..\include	copy ..\src\cerror.h ..\..\include	copy ..\src\cpixels.h ..\..\include	copy ..\src\cpool.h ..\..\include	copy ..\src\fitskw.h ..\..\include	copy ..\src\libstd.h ..\..\include	copy ..\src\libtt.h ..\..\include	copy ..\src\palette.h ..\..\include	copy ..\src\cpixelsgray.h ..\..\include	copy ..\src\cpixelsrgb.h ..\..\include
# End Special Build Tool

!ENDIF 

# Begin Target

# Name "libaudela - Win32 Release"
# Name "libaudela - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\src\buf_tcl.cpp
# End Source File
# Begin Source File

SOURCE=..\src\cam_tcl.cpp
# End Source File
# Begin Source File

SOURCE=..\src\cbuffer.cpp
# End Source File
# Begin Source File

SOURCE=..\src\cdevice.cpp
# End Source File
# Begin Source File

SOURCE=..\src\cerror.cpp
# End Source File
# Begin Source File

SOURCE=..\src\cfile.cpp
# End Source File
# Begin Source File

SOURCE=..\src\cpixels.cpp
# End Source File
# Begin Source File

SOURCE=..\src\cpixelsgray.cpp
# End Source File
# Begin Source File

SOURCE=..\src\cpixelsrgb.cpp
# End Source File
# Begin Source File

SOURCE=..\src\cpool.cpp
# End Source File
# Begin Source File

SOURCE=..\src\file_tcl.cpp
# End Source File
# Begin Source File

SOURCE=..\src\fitskw.cpp
# End Source File
# Begin Source File

SOURCE=..\src\history.cpp
# End Source File
# Begin Source File

SOURCE=.\libaudela.def
# End Source File
# Begin Source File

SOURCE=..\src\libstd.cpp
# End Source File
# Begin Source File

SOURCE=..\src\link_tcl.cpp
# End Source File
# Begin Source File

SOURCE=..\src\ping.cpp
# End Source File
# Begin Source File

SOURCE=..\src\pool_tcl.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\external\porttalk\porttalk_interface.cpp
# End Source File
# Begin Source File

SOURCE=..\src\stats.cpp
# End Source File
# Begin Source File

SOURCE=..\src\tel_tcl.cpp
# End Source File
# Begin Source File

SOURCE=..\src\thread.cpp
# End Source File
# Begin Source File

SOURCE=..\src\tt.cpp
# End Source File
# Begin Source File

SOURCE=..\src\utils.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\src\audela.h
# End Source File
# Begin Source File

SOURCE=..\src\cbuffer.h
# End Source File
# Begin Source File

SOURCE=..\src\cdevice.h
# End Source File
# Begin Source File

SOURCE=..\src\cerror.h
# End Source File
# Begin Source File

SOURCE=..\src\cfile.h
# End Source File
# Begin Source File

SOURCE=..\src\cpixels.h
# End Source File
# Begin Source File

SOURCE=..\src\cpixelsgray.h
# End Source File
# Begin Source File

SOURCE=..\src\cpixelsrgb.h
# End Source File
# Begin Source File

SOURCE=..\src\cpool.h
# End Source File
# Begin Source File

SOURCE=..\src\fitskw.h
# End Source File
# Begin Source File

SOURCE=..\src\history.h
# End Source File
# Begin Source File

SOURCE=..\src\jpegmemscr.h
# End Source File
# Begin Source File

SOURCE=..\..\..\external\include\libdcjpeg.h
# End Source File
# Begin Source File

SOURCE=..\..\..\external\include\libdcraw.h
# End Source File
# Begin Source File

SOURCE=..\src\libstd.h
# End Source File
# Begin Source File

SOURCE=..\src\libtt.h
# End Source File
# Begin Source File

SOURCE=..\src\palette.h
# End Source File
# Begin Source File

SOURCE=..\src\stats.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
