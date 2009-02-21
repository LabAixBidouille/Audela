# Microsoft Developer Studio Project File - Name="external_blt" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=external_blt - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "external_blt.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "external_blt.mak" CFG="external_blt - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "external_blt - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "external_blt - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "external_blt - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "BLT_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /w /W0 /O2 /I "../blt2.4z/src" /I "../../include/win" /D "WIN32" /D "_WINDOWS" /D "TCL_THREADS" /D "__STDC__" /YX /FD /GD /GD /c
# SUBTRACT CPP /Fr
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "NDEBUG"
# ADD RSC /l 0x40c /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib tcl85t.lib tk85t.lib /nologo /dll /machine:I386 /out:"Release/blt24.dll" /libpath:"../../lib"
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds=install.bat Release
# End Special Build Tool

!ELSEIF  "$(CFG)" == "external_blt - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "BLT_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /w /W0 /Od /I "../blt2.4z/src" /I "../../include/win" /D "WIN32" /D "CONSOLE" /D "TCL_THREADS" /D "__STDC__" /FR /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "_DEBUG"
# ADD RSC /l 0x40c /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib tk85t.lib tcl85t.lib /nologo /dll /debug /machine:I386 /out:"Debug/blt24.dll" /pdbtype:sept /libpath:"../../lib"
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds=install.bat Debug
# End Special Build Tool

!ENDIF 

# Begin Target

# Name "external_blt - Win32 Release"
# Name "external_blt - Win32 Debug"
# Begin Group "Source Graph"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\blt2.4z\src\bltGraph.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltGrAxis.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltGrBar.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltGrElem.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltGrGrid.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltGrHairs.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltGrLegd.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltGrLine.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltGrMarker.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltGrMisc.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltGrPen.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltGrPs.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# End Group
# Begin Group "Source Tcl"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\blt2.4z\src\bltAlloc.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltArrayObj.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltBgexec.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltChain.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltDebug.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltHash.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltInit.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltList.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltNsUtil.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltParse.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltPool.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltSpline.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltSwitch.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltTree.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltTreeCmd.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltUtil.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltVecCmd.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltVecMath.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltVecObjCmd.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltVector.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltWatch.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltWinDde.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltWinPipe.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltWinUtil.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\pure_api.c
# End Source File
# End Group
# Begin Group "Source"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\blt2.4z\src\bltBeep.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltBind.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltBitmap.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltBusy.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltCanvEps.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltConfig.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltContainer.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltDragdrop.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltHierbox.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltHtext.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltImage.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltObjConfig.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltPs.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltTable.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltTabnotebook.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltTabset.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltText.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltTile.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltTreeView.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltTreeViewCmd.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltTreeViewColumn.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltTreeViewEdit.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltTreeViewStyle.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltWindow.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltWinDraw.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltWinImage.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltWinop.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\bltWinPrnt.c
# End Source File
# End Group
# Begin Group "Source Tk"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\blt2.4z\src\bltTed.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\tkButton.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\tkFrame.c
# End Source File
# Begin Source File

SOURCE=..\blt2.4z\src\tkScrollbar.c
# End Source File
# End Group
# End Target
# End Project
