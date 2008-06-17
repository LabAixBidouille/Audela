/* sexttcl_1.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/***************************************************************************/
/* Ce fichier contient du C melange avec des fonctions de l'interpreteur   */
/* Tcl.                                                                    */
/* Ainsi, ce fichier fait le lien entre Tcl et les fonctions en C pur qui  */
/* sont disponibles dans les fichiers sext_*.c.                            */
/***************************************************************************/
/* Le include ectcl.h ne contient des infos concernant Tcl.                */
/***************************************************************************/
#include "sexttcl.h"
#include <string.h>


int Cmd_sexttcl_sexexe(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Appel a sextractor executable                                            */
/****************************************************************************/
/****************************************************************************/
{
   int result=TCL_ERROR;
   char s[100];
   int k;
   char exe_file[1000];
   char cmdline[1000];
   char signal[]="signal.sex";
#if defined OS_WIN
   HWND hwnd;
   int r;
#endif

   if(argc<2) {
      sprintf(s,"Usage: %s image ?options?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	   strcpy(cmdline,"");
	   for (k=1;k<argc;k++) {
		   strcat(cmdline,argv[k]);
		   strcat(cmdline," ");
	   }
      /* --- decode les parametres obligatoires ---*/
      sprintf(s,"catch {file delete %s}",signal);
      Tcl_Eval(interp,s);
#if defined OS_WIN
      hwnd=GetDesktopWindow();
	   strcpy(exe_file,"../bin/sex.exe");
      r=(int)ShellExecute(hwnd,"open",exe_file,cmdline,NULL,SW_HIDE);
      if (r<=32) {
	      strcpy(exe_file,"../bin/sextractor.exe");
         r=(int)ShellExecute(hwnd,"open",exe_file,cmdline,NULL,SW_HIDE);
         if (r<=32) {
            Tcl_SetResult(interp,"ShellExecute Error",TCL_VOLATILE);
            return TCL_ERROR;
         }
      }
      do {
         Tcl_Eval(interp,"after 500");
         sprintf(s,"file exists %s",signal);
         Tcl_Eval(interp,s);
         strcpy(s,Tcl_GetStringResult(interp));
		} while (strcmp(s,"0")==0);
		result = TCL_OK;
#endif
#if defined OS_LIN
	   sprintf(exe_file,"exec ../bin/sex %s",cmdline);
      Tcl_Eval(interp,exe_file);
         do {
            Tcl_Eval(interp,"after 500");
            sprintf(s,"file exists %s",signal);
            Tcl_Eval(interp,s);
            strcpy(s,Tcl_GetStringResult(interp));
		   } while (strcmp(s,"0")==0);
         Tcl_SetResult(interp,"",TCL_VOLATILE);
		   result = TCL_OK;
#endif
   }
   sprintf(s,"catch {file delete %s}",signal);
   Tcl_Eval(interp,s);
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

