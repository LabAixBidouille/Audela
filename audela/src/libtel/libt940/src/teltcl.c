/* teltcl.c
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

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "telescop.h"
#include <libtel/libtel.h>
#include "teltcl.h"
#include <libtel/util.h>


/*
 *   structure pour les fonctions étendues
 */

int cmdTelLoopEval(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char s[2048];
   struct telprop *tel;
   tel = (struct telprop*)clientData;
   if (argc<3) {
   	sprintf(s,"usage: %s %s tcl_command_line",argv[0],argv[1]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
	} else {
		my_pthread_mutex_lock(&mutex);
		// --- The CmdThreadMcmt_loopeval will start a Tcl_Eval just after the current loop action
		sprintf(s,"::thread::send %s { CmdThreadMcmt_loopeval \"%s\"}",tel->loopThreadId,argv[2]);
		mytel_tcleval(tel,s);
		my_pthread_mutex_unlock(&mutex);
	}
	return TCL_OK;
}

int cmdTelAllCoord(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	char list[2048],elem[1024];
   my_pthread_mutex_lock(&mutex);
	strcpy(list,"");
	sprintf(elem,"{cat_cod_deg %f %f} ",telthread->coord_cat_cod_deg_ra,telthread->coord_cat_cod_deg_dec);
	strcat(list,elem);
	sprintf(elem,"{app_cod_deg %f %f %f %f %f %f} ",telthread->coord_app_cod_deg_ra,telthread->coord_app_cod_deg_dec,telthread->coord_app_cod_deg_ha,telthread->coord_app_cod_deg_elev,telthread->coord_app_cod_deg_az,telthread->coord_app_cod_deg_rot);
	strcat(list,elem);
	sprintf(elem,"{cat_sim_deg %f %f} ",telthread->coord_cat_sim_deg_ra,telthread->coord_cat_sim_deg_dec);
	strcat(list,elem);
	sprintf(elem,"{app_sim_deg %f %f %f %f %f %f} ",telthread->coord_app_sim_deg_ra,telthread->coord_app_sim_deg_dec,telthread->coord_app_sim_deg_ha,telthread->coord_app_sim_deg_elev,telthread->coord_app_sim_deg_az,telthread->coord_app_sim_deg_rot);
	strcat(list,elem);
	Tcl_SetResult(interp,list,TCL_VOLATILE);
	my_pthread_mutex_unlock(&mutex);
	return TCL_OK;
}

int cmdTelAllCoordJd(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/* --- Tcl code to generate automatically the C code of this function
set textes ""
set f [open $audace(rep_install)/src/libtel/libmcmt/src/telescop.h r]
set lignes [split [read $f] \n]
close $f
set n [llength $lignes]
for {set k 0} {$k<$n} {incr k} {
	set ligne [lindex $lignes $k]
	set f [string first "START OF COORDSYS" $ligne]
	if {$f>=0} { break }
}
set k1 [expr $k+1]
for {set k $k1} {$k<$n} {incr k} {
	set f [string first "END OF COORDSYS" $ligne]
	if {$f>=0} { break }
	set ligne [lindex $lignes $k]
	set type [lindex $ligne 0]
	if {[string length $type]<3} { continue }
	set varname [string range [lindex $ligne 1] 0 end-1]
	set comment [lrange $ligne 3 end]
	::console::affiche_resultat "$type $varname \{$comment\}\n"
	if {$type=="int"} { set symbtype "%d" } else { set symbtype "%f" }
	set texte "sprintf(elem,\"{$varname $symbtype \{${comment}\}} \",telthread->${varname});"
	append textes "   $texte\n"
	append textes "   strcat(list,elem);\n"
}
*/
	/* --- To read these coordinates:
	set res [tel1 allcoordjd]
	foreach re $res {
		::console::affiche_resultat "$re\n"
	}
	*/
	char list[12048],elem[1024];
   my_pthread_mutex_lock(&mutex);
	strcpy(list,"");
	/* --- beginning of automatically generated C code ---*/
    sprintf(elem,"{coord_cat_cod_deg_ra %f {current catalog coordinates computed from coders}} ",telthread->coord_cat_cod_deg_ra);
   strcat(list,elem);
   sprintf(elem,"{coord_cat_cod_deg_dec %f {current catalog coordinates computed from coders}} ",telthread->coord_cat_cod_deg_dec);
   strcat(list,elem);
   sprintf(elem,"{utcjd_cat_cod_deg_ra %f {date of catalog coordinates computed from coders}} ",telthread->utcjd_cat_cod_deg_ra);
   strcat(list,elem);
   sprintf(elem,"{utcjd_cat_cod_deg_dec %f {date of catalog coordinates computed from coders}} ",telthread->utcjd_cat_cod_deg_dec);
   strcat(list,elem);
   sprintf(elem,"{coord_cat_cod_deg_ra0 %f {initial catalog coordinates computed from coders}} ",telthread->coord_cat_cod_deg_ra0);
   strcat(list,elem);
   sprintf(elem,"{coord_cat_cod_deg_dec0 %f {initial catalog coordinates computed from coders}} ",telthread->coord_cat_cod_deg_dec0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_cat_cod_deg_ra0 %f {date of initial catalog coordinates computed from coders}} ",telthread->utcjd_cat_cod_deg_ra0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_cat_cod_deg_dec0 %f {date of initial catalog coordinates computed from coders}} ",telthread->utcjd_cat_cod_deg_dec0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_deg_ha %f {current apparent coordinates computed from coders}} ",telthread->coord_app_cod_deg_ha);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_deg_dec %f {current apparent coordinates computed from coders}} ",telthread->coord_app_cod_deg_dec);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_deg_ra %f {current apparent coordinates computed from coders}} ",telthread->coord_app_cod_deg_ra);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_deg_az %f {current apparent coordinates computed from coders}} ",telthread->coord_app_cod_deg_az);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_deg_elev %f {current apparent coordinates computed from coders}} ",telthread->coord_app_cod_deg_elev);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_deg_rot %f {current apparent coordinates computed from coders}} ",telthread->coord_app_cod_deg_rot);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_deg_ha %f {date of current apparent coordinates computed from coders}} ",telthread->utcjd_app_cod_deg_ha);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_deg_dec %f {date of current apparent coordinates computed from coders}} ",telthread->utcjd_app_cod_deg_dec);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_deg_ra %f {date of current apparent coordinates computed from coders}} ",telthread->utcjd_app_cod_deg_ra);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_deg_az %f {date of current apparent coordinates computed from coders}} ",telthread->utcjd_app_cod_deg_az);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_deg_elev %f {date of current apparent coordinates computed from coders}} ",telthread->utcjd_app_cod_deg_elev);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_deg_rot %f {date of current apparent coordinates computed from coders}} ",telthread->utcjd_app_cod_deg_rot);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_deg_ha0 %f {initial apparent coordinates computed from coders}} ",telthread->coord_app_cod_deg_ha0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_deg_dec0 %f {initial apparent coordinates computed from coders}} ",telthread->coord_app_cod_deg_dec0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_deg_ra0 %f {initial apparent coordinates computed from coders}} ",telthread->coord_app_cod_deg_ra0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_deg_az0 %f {initial apparent coordinates computed from coders}} ",telthread->coord_app_cod_deg_az0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_deg_elev0 %f {initial apparent coordinates computed from coders}} ",telthread->coord_app_cod_deg_elev0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_deg_rot0 %f {initial apparent coordinates computed from coders}} ",telthread->coord_app_cod_deg_rot0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_deg_ha0 %f {date of initial apparent coordinates computed from coders}} ",telthread->utcjd_app_cod_deg_ha0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_deg_dec0 %f {date of initial apparent coordinates computed from coders}} ",telthread->utcjd_app_cod_deg_dec0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_deg_ra0 %f {date of initial apparent coordinates computed from coders}} ",telthread->utcjd_app_cod_deg_ra0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_deg_az0 %f {date of initial apparent coordinates computed from coders}} ",telthread->utcjd_app_cod_deg_az0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_deg_elev0 %f {date of initial apparent coordinates computed from coders}} ",telthread->utcjd_app_cod_deg_elev0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_deg_rot0 %f {date of initial apparent coordinates computed from coders}} ",telthread->utcjd_app_cod_deg_rot0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_ha %f {current ADU from/to coder}} ",telthread->coord_app_cod_adu_ha);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_dec %f {current ADU from/to coder}} ",telthread->coord_app_cod_adu_dec);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_az %f {current ADU from/to coder}} ",telthread->coord_app_cod_adu_az);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_elev %f {current ADU from/to coder}} ",telthread->coord_app_cod_adu_elev);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_rot %f {current ADU from/to coder}} ",telthread->coord_app_cod_adu_rot);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_hapec %f {current ADU from/to coder}} ",telthread->coord_app_cod_adu_hapec);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_adu_ha %f {date of current ADU from/to coder}} ",telthread->utcjd_app_cod_adu_ha);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_adu_dec %f {date of current ADU from/to coder}} ",telthread->utcjd_app_cod_adu_dec);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_adu_az %f {current ADU from/to coder}} ",telthread->utcjd_app_cod_adu_az);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_adu_elev %f {current ADU from/to coder}} ",telthread->utcjd_app_cod_adu_elev);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_adu_rot %f {current ADU from/to coder}} ",telthread->utcjd_app_cod_adu_rot);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_adu_hapec %f {current ADU from/to coder}} ",telthread->utcjd_app_cod_adu_hapec);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_ha0 %f {initial ADU from/to coder}} ",telthread->coord_app_cod_adu_ha0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_dec0 %f {initial ADU from/to coder}} ",telthread->coord_app_cod_adu_dec0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_az0 %f {initial ADU from/to coder}} ",telthread->coord_app_cod_adu_az0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_elev0 %f {initial ADU from/to coder}} ",telthread->coord_app_cod_adu_elev0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_rot0 %f {initial ADU from/to coder}} ",telthread->coord_app_cod_adu_rot0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_adu_ha0 %f {date of initial ADU from/to coder}} ",telthread->utcjd_app_cod_adu_ha0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_adu_dec0 %f {date of initial ADU from/to coder}} ",telthread->utcjd_app_cod_adu_dec0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_adu_az0 %f {date of initial ADU from/to coder}} ",telthread->utcjd_app_cod_adu_az0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_adu_elev0 %f {date of initial ADU from/to coder}} ",telthread->utcjd_app_cod_adu_elev0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_cod_adu_rot0 %f {date of initial ADU from/to coder}} ",telthread->utcjd_app_cod_adu_rot0);
   strcat(list,elem);
   sprintf(elem,"{coord_cat_sim_deg_ra %f {current catalog coordinates computed from coders}} ",telthread->coord_cat_sim_deg_ra);
   strcat(list,elem);
   sprintf(elem,"{coord_cat_sim_deg_dec %f {current catalog coordinates computed from coders}} ",telthread->coord_cat_sim_deg_dec);
   strcat(list,elem);
   sprintf(elem,"{utcjd_cat_sim_deg_ra %f {date of catalog coordinates computed from coders}} ",telthread->utcjd_cat_sim_deg_ra);
   strcat(list,elem);
   sprintf(elem,"{utcjd_cat_sim_deg_dec %f {date of catalog coordinates computed from coders}} ",telthread->utcjd_cat_sim_deg_dec);
   strcat(list,elem);
   sprintf(elem,"{coord_cat_sim_deg_ra0 %f {initial catalog coordinates computed from coders}} ",telthread->coord_cat_sim_deg_ra0);
   strcat(list,elem);
   sprintf(elem,"{coord_cat_sim_deg_dec0 %f {initial catalog coordinates computed from coders}} ",telthread->coord_cat_sim_deg_dec0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_cat_sim_deg_ra0 %f {date of initial catalog coordinates computed from coders}} ",telthread->utcjd_cat_sim_deg_ra0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_cat_sim_deg_dec0 %f {date of initial catalog coordinates computed from coders}} ",telthread->utcjd_cat_sim_deg_dec0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_deg_ha %f {current apparent coordinates computed from coders}} ",telthread->coord_app_sim_deg_ha);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_deg_dec %f {current apparent coordinates computed from coders}} ",telthread->coord_app_sim_deg_dec);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_deg_ra %f {current apparent coordinates computed from coders}} ",telthread->coord_app_sim_deg_ra);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_deg_az %f {current apparent coordinates computed from coders}} ",telthread->coord_app_sim_deg_az);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_deg_elev %f {current apparent coordinates computed from coders}} ",telthread->coord_app_sim_deg_elev);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_deg_rot %f {current apparent coordinates computed from coders}} ",telthread->coord_app_sim_deg_rot);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_deg_ha %f {date of current apparent coordinates computed from coders}} ",telthread->utcjd_app_sim_deg_ha);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_deg_dec %f {date of current apparent coordinates computed from coders}} ",telthread->utcjd_app_sim_deg_dec);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_deg_ra %f {date of current apparent coordinates computed from coders}} ",telthread->utcjd_app_sim_deg_ra);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_deg_az %f {date of current apparent coordinates computed from coders}} ",telthread->utcjd_app_sim_deg_az);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_deg_elev %f {date of current apparent coordinates computed from coders}} ",telthread->utcjd_app_sim_deg_elev);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_deg_rot %f {date of current apparent coordinates computed from coders}} ",telthread->utcjd_app_sim_deg_rot);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_deg_ha0 %f {initial apparent coordinates computed from coders}} ",telthread->coord_app_sim_deg_ha0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_deg_dec0 %f {initial apparent coordinates computed from coders}} ",telthread->coord_app_sim_deg_dec0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_deg_ra0 %f {initial apparent coordinates computed from coders}} ",telthread->coord_app_sim_deg_ra0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_deg_az0 %f {initial apparent coordinates computed from coders}} ",telthread->coord_app_sim_deg_az0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_deg_elev0 %f {initial apparent coordinates computed from coders}} ",telthread->coord_app_sim_deg_elev0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_deg_rot0 %f {initial apparent coordinates computed from coders}} ",telthread->coord_app_sim_deg_rot0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_deg_ha0 %f {date of initial apparent coordinates computed from coders}} ",telthread->utcjd_app_sim_deg_ha0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_deg_dec0 %f {date of initial apparent coordinates computed from coders}} ",telthread->utcjd_app_sim_deg_dec0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_deg_ra0 %f {date of initial apparent coordinates computed from coders}} ",telthread->utcjd_app_sim_deg_ra0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_deg_az0 %f {date of initial apparent coordinates computed from coders}} ",telthread->utcjd_app_sim_deg_az0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_deg_elev0 %f {date of initial apparent coordinates computed from coders}} ",telthread->utcjd_app_sim_deg_elev0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_deg_rot0 %f {date of initial apparent coordinates computed from coders}} ",telthread->utcjd_app_sim_deg_rot0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_ha %f {current ADU from/to coder}} ",telthread->coord_app_sim_adu_ha);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_dec %f {current ADU from/to coder}} ",telthread->coord_app_sim_adu_dec);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_az %f {current ADU from/to coder}} ",telthread->coord_app_sim_adu_az);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_elev %f {current ADU from/to coder}} ",telthread->coord_app_sim_adu_elev);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_rot %f {current ADU from/to coder}} ",telthread->coord_app_sim_adu_rot);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_hapec %f {current ADU from/to coder}} ",telthread->coord_app_sim_adu_hapec);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_adu_ha %f {date of current ADU from/to coder}} ",telthread->utcjd_app_sim_adu_ha);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_adu_dec %f {date of current ADU from/to coder}} ",telthread->utcjd_app_sim_adu_dec);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_adu_az %f {current ADU from/to coder}} ",telthread->utcjd_app_sim_adu_az);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_adu_elev %f {current ADU from/to coder}} ",telthread->utcjd_app_sim_adu_elev);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_adu_rot %f {current ADU from/to coder}} ",telthread->utcjd_app_sim_adu_rot);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_adu_hapec %f {current ADU from/to coder}} ",telthread->utcjd_app_sim_adu_hapec);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_ha0 %f {initial ADU from/to coder}} ",telthread->coord_app_sim_adu_ha0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_dec0 %f {initial ADU from/to coder}} ",telthread->coord_app_sim_adu_dec0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_az0 %f {initial ADU from/to coder}} ",telthread->coord_app_sim_adu_az0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_elev0 %f {initial ADU from/to coder}} ",telthread->coord_app_sim_adu_elev0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_rot0 %f {initial ADU from/to coder}} ",telthread->coord_app_sim_adu_rot0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_hapec0 %f {initial ADU from/to coder}} ",telthread->coord_app_sim_adu_hapec0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_adu_ha0 %f {date of initial ADU from/to coder}} ",telthread->utcjd_app_sim_adu_ha0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_adu_dec0 %f {date of initial ADU from/to coder}} ",telthread->utcjd_app_sim_adu_dec0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_adu_az0 %f {date of initial ADU from/to coder}} ",telthread->utcjd_app_sim_adu_az0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_adu_elev0 %f {date of initial ADU from/to coder}} ",telthread->utcjd_app_sim_adu_elev0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_adu_rot0 %f {date of initial ADU from/to coder}} ",telthread->utcjd_app_sim_adu_rot0);
   strcat(list,elem);
   sprintf(elem,"{utcjd_app_sim_adu_hapec0 %f {date of initial ADU from/to coder}} ",telthread->utcjd_app_sim_adu_hapec0);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_dha %f {next goto ADU from/to coder}} ",telthread->coord_app_cod_adu_dha);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_ddec %f {next goto ADU from/to coder}} ",telthread->coord_app_cod_adu_ddec);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_daz %f {next goto ADU from/to coder}} ",telthread->coord_app_cod_adu_daz);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_delev %f {next goto ADU from/to coder}} ",telthread->coord_app_cod_adu_delev);
   strcat(list,elem);
   sprintf(elem,"{coord_app_cod_adu_drot %f {next goto ADU from/to coder}} ",telthread->coord_app_cod_adu_drot);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_dha %f {next goto ADU from/to coder}} ",telthread->coord_app_sim_adu_dha);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_ddec %f {next goto ADU from/to coder}} ",telthread->coord_app_sim_adu_ddec);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_daz %f {next goto ADU from/to coder}} ",telthread->coord_app_sim_adu_daz);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_delev %f {next goto ADU from/to coder}} ",telthread->coord_app_sim_adu_delev);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_drot %f {next goto ADU from/to coder}} ",telthread->coord_app_sim_adu_drot);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_cumdha %f {cumulative gotos ADU from/to coder}} ",telthread->coord_app_sim_adu_cumdha);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_cumddec %f {cumulative gotos ADU from/to coder}} ",telthread->coord_app_sim_adu_cumddec);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_cumdaz %f {cumulative gotos ADU from/to coder}} ",telthread->coord_app_sim_adu_cumdaz);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_cumdelev %f {cumulative gotos ADU from/to coder}} ",telthread->coord_app_sim_adu_cumdelev);
   strcat(list,elem);
   sprintf(elem,"{coord_app_sim_adu_cumdrot %f {cumulative gotos ADU from/to coder}} ",telthread->coord_app_sim_adu_cumdrot);
   strcat(list,elem);
	/* --- end of automatically generated C code ---*/
	Tcl_SetResult(interp,list,TCL_VOLATILE);
	my_pthread_mutex_unlock(&mutex);
	return TCL_OK;
}

int cmdTelAction(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   if (argc<2) {
   	sprintf(ligne,"usage: %s %s action",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   my_pthread_mutex_lock(&mutex);
	if (argc==2) {
		sprintf(ligne,"%s %d",telthread->action_cur,telthread->compteur);
		Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	} else {
		strcpy(telthread->action_next,argv[2]);
		Tcl_SetResult(interp,telthread->action_next,TCL_VOLATILE);
	}
	my_pthread_mutex_unlock(&mutex);
	return TCL_OK;
}

int cmdTelHaDec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2256],ligne2[2256];
   int result = TCL_OK;
   struct telprop *tel;
   char comment[]="Usage: %s %s ?goto|stop|move|coord|motor|init|state|?";
   if (argc<3) {
      sprintf(ligne,comment,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if (strcmp(argv[2],"init")==0) {
         /* --- init ---*/
         if (argc>=4) {
				sprintf(ligne2,"mc_angle2deg [lindex {%s} 0]",argv[3]);
				Tcl_Eval(interp,ligne2);
				tel->ha0=atof(interp->result);
				sprintf(ligne2,"mc_angle2deg [lindex {%s} 1] 90",argv[3]);
				Tcl_Eval(interp,ligne2);
				tel->dec0=atof(interp->result);
				result=mytel_hadec_init(tel);
				Tcl_SetResult(interp,"",TCL_VOLATILE);
            result = TCL_OK;
         } else {
            sprintf(ligne,"Usage: %s %s %s {angle_ra angle_dec}",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"coord")==0) {
			result=mytel_hadec_coord(tel,ligne);
			if ( result == TCL_OK) {                     
            sprintf(ligne2,"list [mc_angle2hms [lindex {%s} 0] 360 zero 2 auto string] [mc_angle2dms [lindex {%s} 1] 90 zero 1 + string]",ligne,ligne); 
				Tcl_Eval(interp,ligne2);
            Tcl_SetResult(interp,interp->result,TCL_VOLATILE);
            result = TCL_OK;
         }
      } else if (strcmp(argv[2],"goto")==0) {
         /* --- goto ---*/
         if (argc>=4) {
				sprintf(ligne2,"mc_angle2deg [lindex {%s} 0]",argv[3]);
				Tcl_Eval(interp,ligne2);
				tel->ha0=atof(interp->result);
				sprintf(ligne2,"mc_angle2deg [lindex {%s} 1] 90",argv[3]);
				Tcl_Eval(interp,ligne2);
				tel->dec0=atof(interp->result);
				result=mytel_hadec_goto(tel);
				Tcl_SetResult(interp,"",TCL_VOLATILE);
            result = TCL_OK;
         } else {
            sprintf(ligne,"Usage: %s %s %s {angle_ra angle_dec}",argv[0],argv[1],argv[2]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else {
         /* --- sub command not found ---*/
         sprintf(ligne,comment,argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

int cmdTelAdu(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2256];
   int result = TCL_OK;
   struct telprop *tel;
   char comment[]="Usage: %s %s ?goto|stop|move|coord|motor|init|state|?";
   if (argc<3) {
      sprintf(ligne,comment,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if (strcmp(argv[2],"coord")==0) {
			result=mytel_adu_coord(tel,ligne);
			if ( result == TCL_OK) {                     
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_OK;
         }
      } else if (strcmp(argv[2],"goto")==0) {
			/*
			result=mytel_adu_coord(tel,ligne);
			if ( result == TCL_OK) {                     
				// je convertis les angles en HMS et DMS
            sprintf(ligne,"list [mc_angle2hms [lindex {%s} 0] 360 zero 2 auto string] [mc_angle2dms [lindex {%s} 1] 90 zero 1 + string]",ligne,ligne); 
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_OK;
         }
			*/
      } else {
         /* --- sub command not found ---*/
         sprintf(ligne,comment,argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}

int cmdTelExtradrift(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   if ((argc>=3)&&(argc<5)) {
   	sprintf(ligne,"usage: %s %s altaz|radec arcsec/sec arcsec/sec",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	if (argc>=5) {
		if (strcmp(argv[2],"altaz")==0) {
			strcpy(telthread->extradrift_type,"altaz");
		} else if (strcmp(argv[2],"radec")==0) {
			strcpy(telthread->extradrift_type,"radec");
		} else {
			Tcl_SetResult(interp,"type must be only altaz or radec",TCL_VOLATILE);
			return TCL_ERROR;
		}
		telthread->extradrift_axis0=atof(argv[3]);
		telthread->extradrift_axis1=atof(argv[4]);
	}
	sprintf(ligne,"%s %f %f",telthread->extradrift_type,telthread->extradrift_axis0,telthread->extradrift_axis1);
	Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	return TCL_OK;
}


int cmdTelStatus(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256],s[256];
   int result = TCL_OK,err=0,k;
   struct telprop *tel;
	DSA_STATUS sta = {sizeof(DSA_STATUS)};
   tel = telthread;
	/* getting status */
	/* --- boucle sur les axes ---*/
	strcpy(s,"");
	for (k=0;k<3;k++) {
		if (tel->mode==MODE_REEL) {
			if (err = dsa_get_status(tel->drv[k], &sta)) {
				mytel_error(tel,k,err);
   			sprintf(ligne,"%s",tel->msg);
				Tcl_SetResult(interp,ligne,TCL_VOLATILE);
				return TCL_ERROR;
			}
			sprintf(ligne,"{%x %x} ", sta.raw.sw1, sta.raw.sw2);
		} else {
			sprintf(ligne,"{%x %x} ", 0, 0);
		}
		strcat(s,ligne);
	}
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return result;
}

int cmdTelExecuteCommandXS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0;
	DSA_COMMAND_PARAM params[] = { {0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0} };
   struct telprop *tel;
	int cmd, nparams,k,kk;
   int axisno;

   tel = telthread;
   if (argc<4) {
   	sprintf(ligne,"usage: %s %s axisno cmd nparams ?typ1 conv1 par1? ?type2 conv2 par2? ...",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}

   axisno=atoi(argv[2]);

	if (argc>=4) {
   	cmd=atoi(argv[3]);
	}
	if (argc>=5) {
   	nparams=atoi(argv[4]);
	}
	for (k=5;k<argc-2;k+=3) {
		kk=(k-4)/3;
		if (kk>4) {
			break;
		}
		params[kk].typ=atoi(argv[k]); // =0 in general
		params[kk].conv=atoi(argv[k+1]); // =0 if digital units
		if (params[kk].conv==0) {
		   params[kk].val.i=atoi(argv[k+2]);
		} else {
		   params[kk].val.d=atof(argv[k+1]);
		}
	}
	if (tel->mode==MODE_REEL) {
		if (err = dsa_execute_command_x_s(tel->drv[axisno],cmd,params,nparams,FALSE,FALSE,DSA_DEF_TIMEOUT)) {
			mytel_error(tel,k,err);
   		sprintf(ligne,"%s",tel->msg);
			Tcl_SetResult(interp,ligne,TCL_VOLATILE);
			return TCL_ERROR;
		}
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

int cmdTelGetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0,axisno;
   struct telprop *tel;
	int typ,idx,sidx=0,val;
   tel = telthread;
   if (argc<5) {
   	sprintf(ligne,"usage: %s %s axisno typ(X|K|M) idx ?sidx?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   axisno=atoi(argv[2]);
	if (strcmp(argv[3],"X")==0) {
		typ=ETEL_X;
	} else if (strcmp(argv[3],"K")==0) {
		typ=ETEL_K;
	} else if (strcmp(argv[3],"M")==0) {
		typ=ETEL_M;
	} else {
   	typ=atoi(argv[3]);
	}
	idx=atoi(argv[4]);
	if (argc>=6) {
   	sidx=atoi(argv[5]);
	}
	if (tel->mode==MODE_REEL) {
		if (err = dsa_get_register_s(tel->drv[axisno],typ,idx,sidx,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
			mytel_error(tel,axisno,err);
   		sprintf(ligne,"%s",tel->msg);
			Tcl_SetResult(interp,ligne,TCL_VOLATILE);
			return TCL_ERROR;
		}
	} else {
		val=0;
	}
  	sprintf(ligne,"%d",val);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int cmdTelSetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0,axisno;
   struct telprop *tel;
	int typ,idx,sidx=0,val;
   tel = telthread;
   if (argc<7) {
   	sprintf(ligne,"usage: %s %s axisno typ(X|K|M) idx sidx value",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   axisno=atoi(argv[2]);
	if (strcmp(argv[3],"X")==0) {
		typ=ETEL_X;
	} else if (strcmp(argv[3],"K")==0) {
		typ=ETEL_K;
	} else if (strcmp(argv[3],"M")==0) {
		typ=ETEL_M;
	} else {
   	typ=atoi(argv[3]);
	}
	idx=atoi(argv[4]);
  	sidx=atoi(argv[5]);
  	val=atoi(argv[6]);
	if (tel->mode==MODE_REEL) {
		if (err = dsa_set_register_s(tel->drv[axisno],typ,idx,sidx,val,DSA_DEF_TIMEOUT)) {
			mytel_error(tel,axisno,err);
   		sprintf(ligne,"%s",tel->msg);
			Tcl_SetResult(interp,ligne,TCL_VOLATILE);
			return TCL_ERROR;
		}
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

int cmdTelTypeAxes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0;
   struct telprop *tel;
   tel = telthread;
   if (tel->type_mount==MOUNT_EQUATORIAL) {
      strcpy(ligne,"{0 ha} {1 dec}");
   } else {
      strcpy(ligne,"{0 azimut} {1 elevation} {2 parallactic}");
   }
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	return TCL_OK;
}

int cmdTelTypeMount(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0;
   struct telprop *tel;
   char mounttype[50];
   tel = telthread;
   if (argc>2) {
   	if (strcmp(argv[2],"equatorial")==0) {
         tel->type_mount=MOUNT_EQUATORIAL;
      } else if (strcmp(argv[2],"altaz")==0) {
         tel->type_mount=MOUNT_ALTAZ;
      } else {
      	strcpy(ligne,"mount must be equatorial|altaz");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		   return TCL_ERROR;
      }
   }
   if (tel->type_mount==MOUNT_EQUATORIAL) {
      strcpy(mounttype,"equatorial");
   } else if (tel->type_mount==MOUNT_ALTAZ) {
      strcpy(mounttype,"altaz");
   } else {
      strcpy(mounttype,"unknown");
   }
 	sprintf(ligne,"%s",mounttype);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	return TCL_OK;
}

int cmdTelIncAxis(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024],ligne[4096];
   int result = TCL_OK,err=0;
   struct telprop *tel;
   int axisno,val;
   char axistype[50];
   int traits,interpo,pos,spd,acc;
   tel = telthread;
   /* --- boucle sur les axes valides ---*/
   strcpy(ligne,"");
   for (axisno=0;axisno<3;axisno++) {
      if (tel->axis_param[axisno].type==AXIS_NOTDEFINED) {
         continue;
      }
      if (tel->axis_param[axisno].type==AXIS_HA) {
         strcpy(axistype,"ha");
      } else if (tel->axis_param[axisno].type==AXIS_DEC) {
         strcpy(axistype,"dec");
      } else if (tel->axis_param[axisno].type==AXIS_AZ) {
         strcpy(axistype,"az");
      } else if (tel->axis_param[axisno].type==AXIS_ELEV) {
         strcpy(axistype,"elev");
      } else if (tel->axis_param[axisno].type==AXIS_PARALLACTIC) {
         strcpy(axistype,"parallactic");
      } else {
         strcpy(axistype,"notdefined");
      }
		if (tel->mode==MODE_REEL) {
   		if (err = dsa_get_register_s(tel->drv[axisno],ETEL_M,239,0,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
				mytel_error(tel,axisno,err);
   			sprintf(ligne,"%s",tel->msg);
				Tcl_SetResult(interp,ligne,TCL_VOLATILE);
				return TCL_ERROR;
			}
			traits=val;
   		if (err = dsa_get_register_s(tel->drv[axisno],ETEL_M,241,0,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
				mytel_error(tel,axisno,err);
   			sprintf(ligne,"%s",tel->msg);
				Tcl_SetResult(interp,ligne,TCL_VOLATILE);
				return TCL_ERROR;
   		}
			interpo=val;
   		if (err = dsa_get_register_s(tel->drv[axisno],ETEL_M,7,0,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
				mytel_error(tel,axisno,err);
   			sprintf(ligne,"%s",tel->msg);
				Tcl_SetResult(interp,ligne,TCL_VOLATILE);
				return TCL_ERROR;
   		}
			pos=val;
   		if (err = dsa_get_register_s(tel->drv[axisno],ETEL_M,11,0,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
				mytel_error(tel,axisno,err);
   			sprintf(ligne,"%s",tel->msg);
				Tcl_SetResult(interp,ligne,TCL_VOLATILE);
				return TCL_ERROR;
   		}
			spd=val;
   		if (err = dsa_get_register_s(tel->drv[axisno],ETEL_M,15,0,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
				mytel_error(tel,axisno,err);
   			sprintf(ligne,"%s",tel->msg);
				Tcl_SetResult(interp,ligne,TCL_VOLATILE);
				return TCL_ERROR;
   		}
			acc=val;
 			sprintf(s,"{{axisno %d} {designation %s} {pos %d} {spd %d} {acc %d} {pos0 %d} {angle0 %10f} {sens %d} ",
				axisno,axistype,
				pos,spd,acc,
				tel->axis_param[axisno].posinit,
				tel->axis_param[axisno].angleinit,
				tel->axis_param[axisno].sens);
			strcat(ligne,s);
		}
   }
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	return TCL_OK;
}

int cmdTelTemperature(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024],ligne[4096];
   int result = TCL_OK,err=0;
   struct telprop *tel;
   int kaxisno,axisno,val;
   tel = telthread;
   /* --- boucle sur les axes valides ---*/
   strcpy(ligne,"");
	for (kaxisno=0;kaxisno<tel->nb_axis;kaxisno++) {
		axisno=tel->axes[kaxisno];
		if (tel->mode==MODE_REEL) {
			// M90.0 temperature du controleur
			if (err=mytel_get_register(tel,axisno,ETEL_M,90,0,&val)) { mytel_error(tel,axisno,err); return 1; }
			tel->axis_param[axisno].temperature=val;
		} else {
			val=22;
		}
		printf(s,"%f ",val);
		strcat(ligne,s);
	}
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	return TCL_OK;
}

int cmdTelParams(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024],ligne[4096],method[20];
   int result = TCL_OK,err=0;
   struct telprop *tel;
   int kaxisno,axisno;
	double val;
   Tcl_DString res;
   tel = telthread;
	if (argc<4) {
    	sprintf(ligne,"usage: %s %s load|get|set|save axisno ?key value?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
	}
   /* ---  ---*/
	Tcl_DStringInit(&res);
	strcpy(method,argv[2]);
	kaxisno=(int)atoi(argv[3]);
	if (kaxisno<0) {kaxisno=0;}
	if (kaxisno>2) {kaxisno=2;}
	axisno=tel->axes[kaxisno];
	if (strcmp(method,"set")==0) {
		if (argc>=6) {
			strcpy(s,argv[4]);
			val=atof(argv[5]);
			if (strcmp(s,"angleinit")==0) { tel->axis_param[axisno].angleinit=val; }
			if (strcmp(s,"angleturnback")==0) { tel->axis_param[axisno].angleturnback=val; }
			if (strcmp(s,"angleover")==0) { tel->axis_param[axisno].angleover=val; }
			if (strcmp(s,"coef_vsm")==0) { tel->axis_param[axisno].coef_vsm=val; }
			if (strcmp(s,"coef_vsp")==0) { tel->axis_param[axisno].coef_vsp=val; }
			if (strcmp(s,"coef_xsm")==0) { tel->axis_param[axisno].coef_xsm=val; }
			if (strcmp(s,"coef_xsp")==0) { tel->axis_param[axisno].coef_xsp=val; }
			strcpy(method,"get");
		} else {
    		strcpy(ligne,"Arguments must be: key value");
			Tcl_SetResult(interp,ligne,TCL_VOLATILE);
			Tcl_DStringFree(&res);
			return TCL_ERROR;
		}
	}
	if (strcmp(method,"load")==0) {
		mytel_loadparams(tel,axisno);
	}
	if (strcmp(method,"get")==0) {
		sprintf(s,"{type %d} ",tel->axis_param[axisno].type); Tcl_DStringAppend(&res,s,-1);
		sprintf(s,"{angleinit %f} ",tel->axis_param[axisno].angleinit); Tcl_DStringAppend(&res,s,-1);
		sprintf(s,"{angleturnback %f} ",tel->axis_param[axisno].angleturnback); Tcl_DStringAppend(&res,s,-1);
		sprintf(s,"{angleover %f} ",tel->axis_param[axisno].angleover); Tcl_DStringAppend(&res,s,-1);
		sprintf(s,"{angleovered %d} ",tel->axis_param[axisno].angleovered); Tcl_DStringAppend(&res,s,-1);
		sprintf(s,"{coef_vsm %f} ",tel->axis_param[axisno].coef_vsm); Tcl_DStringAppend(&res,s,-1);
		sprintf(s,"{coef_vsp %f} ",tel->axis_param[axisno].coef_vsp); Tcl_DStringAppend(&res,s,-1);
		sprintf(s,"{coef_xsm %f} ",tel->axis_param[axisno].coef_xsm); Tcl_DStringAppend(&res,s,-1);
		sprintf(s,"{coef_xsp %f} ",tel->axis_param[axisno].coef_xsp); Tcl_DStringAppend(&res,s,-1);
		sprintf(s,"{temperature %f} ",tel->axis_param[axisno].temperature); Tcl_DStringAppend(&res,s,-1);
	}
	Tcl_DStringResult(interp,&res);
	Tcl_DStringFree(&res);
	return TCL_OK;
}
