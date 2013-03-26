/* eteltcl_1.c
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
/* sont disponibles dans les fichiers eteltcl_*.c.                         */
/***************************************************************************/
/* Le include eteltcltcl.h ne contient des infos concernant Tcl.           */
/***************************************************************************/
#include "eteltcltcl.h"

/*
load libeteltcl.dll
etel_open -driver DSTEB3 -axis 0 -axis 2
etel_close

etel_open -driver DSTEB3 -axis 0 -axis 1
etel_status
etel_get_register_s 0 M 7

etel_set_register_s

etel_execute_command_x_s
*/
//#define MOUCHARD

int Cmd_eteltcltcl_open(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char s[200],ss[200];
	int k,kk,kkk,err;
   if(argc<3) {
      sprintf(s,"Usage: %s ?-driver name? ?-axis axisno? ?-axis axisno? ...", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
#if defined(MOUCHARD)
		FILE *f;
		f=fopen("mouchard_etel.txt","wt");
		fprintf(f,"Open the driver\n");
		fclose(f);
#endif
		for (k=0;k<ETEL_NAXIS_MAXI;k++) {
			etel.axis[k]=AXIS_STATE_CLOSED;
			etel.drv[k]=NULL;
		}
		strcpy(etel.etel_driver,"DSTEB3");
		if (argc >= 1) {
			kkk=0;
			for (kk = 0; kk < argc-1; kk++) {
				if (strcmp(argv[kk], "-driver") == 0) {
					strcpy(etel.etel_driver,argv[kk + 1]);
				}
				if (strcmp(argv[kk], "-axis") == 0) {
					if (kkk<ETEL_NAXIS_MAXI) {
						etel.axis[kkk]=AXIS_STATE_TO_BE_OPENED;
						etel.axisno[kkk]=atoi(argv[kk + 1]);
						kkk++;
					}
				}
			}
		}
		/* --- boucle de creation des axes ---*/
		for (k=0;k<ETEL_NAXIS_MAXI;k++) {
			if (etel.axis[k]!=AXIS_STATE_TO_BE_OPENED) {
				continue;
			}
			etel.drv[k]=NULL;
			/* create drive */
			if (err = dsa_create_drive(&etel.drv[k])) {
				sprintf(s,"Error axis=%d dsa_create_drive error=%d",k,err);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			sprintf(ss,"etb:%s:%d",etel.etel_driver,etel.axisno[k]);
			if (err = dsa_open_u(etel.drv[k],ss)) {
				sprintf(s,"Error axis=%d dsa_open_u(%s) error=%d",etel.axisno[k],ss,err);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			/* Reset error */
			if (err = dsa_reset_error_s(etel.drv[k], 1000)) {
				sprintf(s,"Error axis=%d dsa_reset_error_s error=%d",k,err);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			/* power on */
			if (err = dsa_power_on_s(etel.drv[k], 10000)) {
				sprintf(s,"Error axis=%d dsa_power_on_s error=%d",k,err);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			etel.axis[k]=AXIS_STATE_OPENED;
		}
   }
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int Cmd_eteltcltcl_close(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
	int k,err;
#if defined(MOUCHARD)
	FILE *f;
	f=fopen("mouchard_etel.txt","wt");
	fprintf(f,"Close the driver\n");
	fclose(f);
#endif
	for (k=0;k<ETEL_NAXIS_MAXI;k++) {
		if (etel.axis[k]==AXIS_STATE_OPENED) {
			/* power off */
			if (err = dsa_power_off_s(etel.drv[k], 10000)) {
				sprintf(s,"Error axis=%d dsa_power_off_s error=%d",k,err);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			/* close and destroy */
			if (err = dsa_close(etel.drv[k])) {
				sprintf(s,"Error axis=%d dsa_close error=%d",k,err);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			if (err = dsa_destroy(&etel.drv[k])) {
				sprintf(s,"Error axis=%d dsa_destroy error=%d",k,err);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			etel.axis[k]=AXIS_STATE_CLOSED;
		}
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int Cmd_eteltcltcl_status(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char ligne[256],s[256];
   int result = TCL_OK,err=0,k;
	DSA_STATUS sta = {sizeof(DSA_STATUS)};
	/* getting status */
	/* --- boucle sur les axes ---*/
	strcpy(s,"");
	for (k=0;k<ETEL_NAXIS_MAXI;k++) {
		if (etel.axis[k]==AXIS_STATE_OPENED) {
			if (err = dsa_get_status(etel.drv[k], &sta)) {
				etel_error(k,err);
   			sprintf(ligne,"%s",etel.msg);
				Tcl_SetResult(interp,ligne,TCL_VOLATILE);
				return TCL_ERROR;
			}
			sprintf(ligne,"{%x %x} ", sta.raw.sw1, sta.raw.sw2);
			strcat(s,ligne);
		}
	}
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return result;
}

int Cmd_eteltcltcl_ExecuteCommandXS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char ligne[256];
   int result = TCL_OK,err=0;
	DSA_COMMAND_PARAM params[] = { {0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0} };
	int cmd, nparams,k,kk;
   int axisno;
#if defined(MOUCHARD)
	FILE *f;
#endif

   if (argc<3) {
   	sprintf(ligne,"usage: %s axisno cmd nparams ?typ1 conv1 par1? ?type2 conv2 par2? ...",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}

   axisno=atoi(argv[1]);

	if (argc>=3) {
   	cmd=atoi(argv[2]);
	}
	if (argc>=4) {
   	nparams=atoi(argv[3]);
	}
	for (k=4;k<argc-2;k+=3) {
		kk=(k-3)/3;
		if (kk>4) {
			break;
		}
		params[kk].typ=atoi(argv[k]); // =0 in general
		params[kk].conv=atoi(argv[k+1]); // =0 if digital units
		if (params[kk].conv==0) {
		   params[kk].val.i=atoi(argv[k+2]);
		} else {
		   params[kk].val.d=atof(argv[k+2]);
		}
	}
#if defined(MOUCHARD)
   f=fopen("mouchard_etel1.txt","at");
   fprintf(f,"dsa_execute_command_x_s(%d=>axe%d,%d,%d,%d)\n",etel.drv[axisno],axisno,cmd,params[kk].val.i,nparams);
	fclose(f);
#endif
	if (err = dsa_execute_command_x_s(etel.drv[axisno],cmd,params,nparams,FALSE,FALSE,DSA_DEF_TIMEOUT)) {
		etel_error(k,err);
   	sprintf(ligne,"%s",etel.msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

int Cmd_eteltcltcl_GetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char ligne[256];
   int result = TCL_OK,err=0,axisno;
	int typ,idx,sidx=0,val;
/*
#if defined(MOUCHARD)
	FILE *f;
#endif
*/
   if (argc<4) {
   	sprintf(ligne,"usage: %s axisno typ(X|K|M) idx ?sidx?",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   axisno=atoi(argv[1]);
	if (strcmp(argv[2],"X")==0) {
		typ=ETEL_X;
	} else if (strcmp(argv[2],"K")==0) {
		typ=ETEL_K;
	} else if (strcmp(argv[2],"M")==0) {
		typ=ETEL_M;
	} else {
   	typ=atoi(argv[2]);
	}
	idx=atoi(argv[3]);
	if (argc>=5) {
   	sidx=atoi(argv[4]);
	}
	if (err = dsa_get_register_s(etel.drv[axisno],typ,idx,sidx,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
		etel_error(axisno,err);
   	sprintf(ligne,"%s",etel.msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	/*
#if defined(MOUCHARD)
   f=fopen("mouchard_etel.txt","at");
   fprintf(f,"dsa_get_register_s(%d=>axe%d,%d,%d,%d) => %d\n",etel.drv[axisno],axisno,typ,idx,sidx,val);
	fclose(f);
#endif
	*/
  	sprintf(ligne,"%d",val);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int Cmd_eteltcltcl_SetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char ligne[256];
   int result = TCL_OK,err=0,axisno;
	int typ,idx,sidx=0,val;
#if defined(MOUCHARD)
	FILE *f;
#endif
   if (argc<6) {
   	sprintf(ligne,"usage: %s axisno typ(X|K|M) idx sidx value",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   axisno=atoi(argv[1]);
	if (strcmp(argv[2],"X")==0) {
		typ=ETEL_X;
	} else if (strcmp(argv[2],"K")==0) {
		typ=ETEL_K;
	} else if (strcmp(argv[2],"M")==0) {
		typ=ETEL_M;
	} else {
   	typ=atoi(argv[2]);
	}
	idx=atoi(argv[3]);
  	sidx=atoi(argv[4]);
  	val=atoi(argv[5]);
#if defined(MOUCHARD)
   f=fopen("mouchard_etel.txt","at");
   fprintf(f,"dsa_set_register_s(%d=>axe%d,%d,%d,%d,%d)\n",etel.drv[axisno],axisno,typ,idx,sidx,val);
	fclose(f);
#endif
	if (err = dsa_set_register_s(etel.drv[axisno],typ,idx,sidx,val,DSA_DEF_TIMEOUT)) {
		etel_error(axisno,err);
   	sprintf(ligne,"%s",etel.msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}
