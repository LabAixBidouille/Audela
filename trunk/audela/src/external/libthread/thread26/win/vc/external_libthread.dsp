# Microsoft Developer Studio Project File - Name="external_libthread" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=external_libthread - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "external_libthread.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "external_libthread.mak" CFG="external_libthread - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "external_libthread - Win32 Release" (based on "Win32 (x86) External Target")
!MESSAGE "external_libthread - Win32 Debug" (based on "Win32 (x86) External Target")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "external_libthread - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Cmd_Line "NMAKE /f external_libthread.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "external_libthread.exe"
# PROP BASE Bsc_Name "external_libthread.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Cmd_Line "nmake -nologo -f makefile.vc TCLDIR=..\..\..\..  INSTALLDIR=..\..\..\..\..\.. MSVCDIR=IDE OPTS=thread  DOTVERSION=2.6.5.1"
# PROP Rebuild_Opt "-a"
# PROP Target_File "Release\libthread2651.dll"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ELSEIF  "$(CFG)" == "external_libthread - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Cmd_Line "NMAKE /f external_libthread.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "external_libthread.exe"
# PROP BASE Bsc_Name "external_libthread.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Cmd_Line "nmake -nologo -f makefile.vc OPTS=symbols TCLDIR=..\..\..\tk8.4.12 MSVCDIR=IDE"
# PROP Rebuild_Opt "-a"
# PROP Target_File "Debug\external_libthread26d.dll"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ENDIF 

# Begin Target

# Name "external_libthread - Win32 Release"
# Name "external_libthread - Win32 Debug"

!IF  "$(CFG)" == "external_libthread - Win32 Release"

!ELSEIF  "$(CFG)" == "external_libthread - Win32 Debug"

!ENDIF 

# Begin Group "generic"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\generic\aolstub.cpp
# End Source File
# Begin Source File

SOURCE=..\..\generic\psGdbm.c
# End Source File
# Begin Source File

SOURCE=..\..\generic\psGdbm.h
# End Source File
# Begin Source File

SOURCE=..\..\generic\tclThread.h
# End Source File
# Begin Source File

SOURCE=..\..\generic\tclXkeylist.c
# End Source File
# Begin Source File

SOURCE=..\..\generic\tclXkeylist.h
# End Source File
# Begin Source File

SOURCE=..\..\generic\threadCmd.c
# End Source File
# Begin Source File

SOURCE=..\..\generic\threadPoolCmd.c
# End Source File
# Begin Source File

SOURCE=..\..\generic\threadSpCmd.c
# End Source File
# Begin Source File

SOURCE=..\..\generic\threadSvCmd.c
# End Source File
# Begin Source File

SOURCE=..\..\generic\threadSvCmd.h
# End Source File
# Begin Source File

SOURCE=..\..\generic\threadSvKeylistCmd.c
# End Source File
# Begin Source File

SOURCE=..\..\generic\threadSvKeylistCmd.h
# End Source File
# Begin Source File

SOURCE=..\..\generic\threadSvListCmd.c
# End Source File
# Begin Source File

SOURCE=..\..\generic\threadSvListCmd.h
# End Source File
# End Group
# Begin Group "doc"

# PROP Default_Filter ""
# Begin Group "html"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\doc\html\thread.html
# End Source File
# Begin Source File

SOURCE=..\..\doc\html\tpool.html
# End Source File
# Begin Source File

SOURCE=..\..\doc\html\tsv.html
# End Source File
# Begin Source File

SOURCE=..\..\doc\html\ttrace.html
# End Source File
# End Group
# Begin Group "man"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\doc\man\thread.n
# End Source File
# Begin Source File

SOURCE=..\..\doc\man\tpool.n
# End Source File
# Begin Source File

SOURCE=..\..\doc\man\tsv.n
# End Source File
# Begin Source File

SOURCE=..\..\doc\man\ttrace.n
# End Source File
# End Group
# Begin Source File

SOURCE=..\..\doc\format.tcl
# End Source File
# Begin Source File

SOURCE=..\..\doc\man.macros
# End Source File
# Begin Source File

SOURCE=..\..\doc\thread.man
# End Source File
# Begin Source File

SOURCE=..\..\doc\tpool.man
# End Source File
# Begin Source File

SOURCE=..\..\doc\tsv.man
# End Source File
# Begin Source File

SOURCE=..\..\doc\ttrace.man
# End Source File
# End Group
# Begin Group "win"

# PROP Default_Filter ""
# Begin Group "vc"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\makefile.vc
# End Source File
# Begin Source File

SOURCE=.\nmakehlp.c
# End Source File
# Begin Source File

SOURCE=.\pkg.vc
# End Source File
# Begin Source File

SOURCE=.\pkgIndex.tcl
# End Source File
# Begin Source File

SOURCE=.\README.txt
# End Source File
# Begin Source File

SOURCE=.\rules.vc
# End Source File
# End Group
# Begin Source File

SOURCE=..\README.txt
# End Source File
# Begin Source File

SOURCE=..\thread.rc
# End Source File
# Begin Source File

SOURCE=..\threadWin.c
# End Source File
# End Group
# Begin Source File

SOURCE=..\..\ChangeLog
# End Source File
# Begin Source File

SOURCE=..\..\license.terms
# End Source File
# Begin Source File

SOURCE=..\..\README
# End Source File
# End Target
# End Project
