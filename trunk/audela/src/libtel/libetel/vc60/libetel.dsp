# Microsoft Developer Studio Project File - Name="libetel" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=libetel - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE
!MESSAGE NMAKE /f "libetel.mak".
!MESSAGE
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE
!MESSAGE NMAKE /f "libetel.mak" CFG="libetel - Win32 Debug"
!MESSAGE
!MESSAGE Possible choices for configuration are:
!MESSAGE
!MESSAGE "libetel - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "libetel - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "libetel - Win32 Release"

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
F90=df.exe
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "LIBetel_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /I "..\src" /I "..\..\..\include" /I "..\..\..\external\include\win" /I "..\..\..\external\include" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "USE_TCL_STUBS" /D "USE_TK_STUBS" /D "_CRT_SECURE_NO_WARNINGS" /D "USE_COMPAT_CONST" /FR"" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "NDEBUG"
# ADD RSC /l 0x40c /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib tclstub85.lib dsa20c.lib /nologo /dll /machine:I386 /out:"..\..\..\..\bin\libetel.dll" /libpath:"..\..\..\external\lib"

!ELSEIF  "$(CFG)" == "libetel - Win32 Debug"

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
F90=df.exe
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "LIBetel_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /GX /ZI /Od /I "..\src" /I "..\..\..\include" /I "..\..\..\external\include\win" /I "..\..\..\external\include" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "USE_TCL_STUBS" /D "USE_TK_STUBS" /D "_CRT_SECURE_NO_WARNINGS" /D "USE_COMPAT_CONST" /FR".\Debug/" /Fo".\Debug/" /Fd".\Debug/" /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "_DEBUG"
# ADD RSC /l 0x40c /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib tclstub85.lib dsa20c.lib /nologo /subsystem:windows /dll /pdb:".\Debug/libetel.pdb" /debug /machine:I386 /nodefaultlib:"msvcrt.lib" /out:"..\..\..\..\bin\libetel.dll" /implib:".\Debug/libetel.lib" /libpath:"..\..\..\external\lib"
# SUBTRACT LINK32 /pdb:none

!ENDIF

# Begin Target

# Name "libetel - Win32 Release"
# Name "libetel - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\libetel.def
# End Source File
# Begin Source File

SOURCE=..\..\libtel.cpp
# End Source File
# Begin Source File

SOURCE=..\src\telescop.c
# End Source File
# Begin Source File

SOURCE=..\src\teltcl.c
# End Source File
# Begin Source File

SOURCE=..\..\util.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\src\libname.h
# End Source File
# Begin Source File

SOURCE=..\src\telcmd.h
# End Source File
# Begin Source File

SOURCE=..\src\telescop.h
# End Source File
# Begin Source File

SOURCE=..\src\teltcl.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project