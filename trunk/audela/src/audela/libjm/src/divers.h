/* jm_c_tcl.h
 *
 * This file is part of the libjm libfrary for AudeLA project.
 *
 * Initial author : Jacques MICHELET <jacques.michelet@laposte.net>
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

/*
 * Projet      : AudeLA
 * Librairie   : LIBJM
 * Fichier     : JM_C_TCL.H
 * Description : Prototype des fonctions interfaces Tcl et le C
 * ============================================================
*/

#ifndef __LIBJM_DIVERS_H__
#define __LIBJM_DIVERS_H__

namespace LibJM
{

class Divers
{
public :
	static int CmdDms2deg(ClientData clientData,Tcl_Interp *interp, int argc,char *argv[]);

	static int DecodeListeInt(Tcl_Interp *interp, char *list, int *valeurs, int *n);
	static int DecodeListeDouble(Tcl_Interp *interp, char *list, double *valeurs, int *n);
	static int CmdInitTamponImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
	static int CmdInfoImage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]);
	static int dms2deg(int d,int m,double s,double *angle);
};

}

#endif //__LIBJM_DIVERS_H__ 
