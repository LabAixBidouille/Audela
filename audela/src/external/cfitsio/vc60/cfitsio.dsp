# Microsoft Developer Studio Project File - Name="external_cfitsio" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=external_cfitsio - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "cfitsio.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "cfitsio.mak" CFG="external_cfitsio - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "external_cfitsio - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "external_cfitsio - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "external_cfitsio - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CFITSIO_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W1 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CFITSIO_EXPORTS" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "NDEBUG"
# ADD RSC /l 0x40c /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 /nologo /dll /machine:I386
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds=../install.bat Release
# End Special Build Tool

!ELSEIF  "$(CFG)" == "external_cfitsio - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CFITSIO_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CFITSIO_EXPORTS" /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "_DEBUG"
# ADD RSC /l 0x40c /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds=../install.bat Debug
# End Special Build Tool

!ENDIF 

# Begin Target

# Name "external_cfitsio - Win32 Release"
# Name "external_cfitsio - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\cfitsio3090\buffers.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\cfileio.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio.def
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\checksum.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\compress.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\drvrfile.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\drvrmem.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\editcol.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\edithdu.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\eval_f.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\eval_l.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\eval_y.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\f77_wrap1.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\f77_wrap2.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\f77_wrap3.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\f77_wrap4.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\fits_hcompress.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\fits_hdecompress.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\fitscore.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcol.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcolb.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcold.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcole.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcoli.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcolj.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcolk.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcoll.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcols.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcolsb.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcolui.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcoluj.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getcoluk.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\getkey.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\group.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\grparser.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\histo.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\imcompress.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\iraffits.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\modkey.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\pliocomp.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcol.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcolb.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcold.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcole.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcoli.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcolj.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcolk.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcoll.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcols.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcolsb.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcolu.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcolui.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcoluj.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putcoluk.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\putkey.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\quantize.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\region.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\ricecomp.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\scalnull.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\swapproc.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\wcssub.c
# End Source File
# Begin Source File

SOURCE=..\cfitsio3090\wcsutil.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
