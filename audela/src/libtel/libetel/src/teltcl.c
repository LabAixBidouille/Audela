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
int cmdTelStatus(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0;
   struct telprop *tel;
	DSA_STATUS sta = {sizeof(DSA_STATUS)};
   tel = (struct telprop *)clientData;
	/* getting status */
	if (err = dsa_get_status(tel->drv, &sta)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	sprintf(ligne,"%x %x", sta.raw.sw1, sta.raw.sw2);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int cmdTelHoming(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   /* homing */
	if (err = dsa_homing_start_s(tel->drv, 10000)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	/* wait end of homing */
	if (err = dsa_wait_movement_s(tel->drv, 10000)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

int cmdTelTest(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0;
	int typ,idx,sidx,value;
	int cmd;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   /* set register */
	typ=2; // X=1 K=2 M=3
	idx=210; // POS=210
	sidx=0;
	value=240000;
	if (argc>=3) {
   	value=atoi(argv[2]);
	}
	if (err = dsa_set_register_s(tel->drv,typ,idx,sidx,value,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	/* send command */
	cmd=119;
	if (err = dsa_execute_command_s(tel->drv,cmd,FALSE,FALSE,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	/* wait end of homing */
	if (err = dsa_wait_movement_s(tel->drv, 10000)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   Tcl_SetResult(interp,"OK",TCL_VOLATILE);
   return result;
}

int cmdTelTargetPosition(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0;
	int value;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
	value=240000;
	if (argc>=3) {
   	value=atoi(argv[2]);
	}
	if (err = dsa_set_target_position_s(tel->drv,0,value,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	if (err = dsa_wait_movement_s(tel->drv, 10000)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   Tcl_SetResult(interp,"OK",TCL_VOLATILE);
   return result;
}

int cmdTelExecuteCommandXS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0;
	DSA_COMMAND_PARAM params[] = { {0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0} };
   struct telprop *tel;
	int cmd, nparams,k,kk;
   tel = (struct telprop *)clientData;
   if (argc<4) {
   	sprintf(ligne,"usage: %s %s cmd nparams ?typ1 conv1 par1? ?type2 conv2 par2? ...",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	if (argc>=3) {
   	cmd=atoi(argv[2]);
	}
	if (argc>=4) {
   	nparams=atoi(argv[3]);
	}
	for (k=4;k<argc-2;k+=3) {
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
	if (err = dsa_execute_command_x_s(tel->drv,cmd,params,nparams,FALSE,FALSE,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

int cmdTelGetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0;
   struct telprop *tel;
	int typ,idx,sidx=0,val;
   tel = (struct telprop *)clientData;
   if (argc<4) {
   	sprintf(ligne,"usage: %s %s typ(X|K|M) idx ?sidx?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	if (strcmp(argv[2],"X")==0) {
		typ=1;
	} else if (strcmp(argv[2],"K")==0) {
		typ=2;
	} else if (strcmp(argv[2],"M")==0) {
		typ=3;
	} else {
   	typ=atoi(argv[2]);
	}
	idx=atoi(argv[3]);
	if (argc>=5) {
   	sidx=atoi(argv[4]);
	}
	if (err = dsa_get_register_s(tel->drv,typ,idx,sidx,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
  	sprintf(ligne,"%d",val);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int cmdTelSetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0;
   struct telprop *tel;
	int typ,idx,sidx=0,val;
   tel = (struct telprop *)clientData;
   if (argc<6) {
   	sprintf(ligne,"usage: %s %s typ(X|K|M) idx sidx value",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
	if (strcmp(argv[2],"X")==0) {
		typ=1;
	} else if (strcmp(argv[2],"K")==0) {
		typ=2;
	} else if (strcmp(argv[2],"M")==0) {
		typ=3;
	} else {
   	typ=atoi(argv[2]);
	}
	idx=atoi(argv[3]);
  	sidx=atoi(argv[4]);
  	val=atoi(argv[5]);
	if (err = dsa_set_register_s(tel->drv,typ,idx,sidx,val,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

int cmdTelTypeAxis(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0;
   struct telprop *tel;
   int axisno,val,typ,idx,sidx;
   char axistype[50];
   int traits,interpo;
   long int uc_per_tooth;
   tel = (struct telprop *)clientData;
   if (argc>2) {
      axisno=(int)atoi(argv[2]);
      if ((axisno<0)||(axisno>2)) {
      	strcpy(ligne,"axisNo must lie between 0 and 2");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		   return TCL_ERROR;
      }
   } else {
    	sprintf(ligne,"usage: %s %s axisNo ha|dec|az|elev|parallactic ?teeth_per_turn?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }
   if (argc>3) {
   	if (strcmp(argv[3],"ha")==0) {
         tel->axis_param[axisno].type=AXIS_HA;
      } else if (strcmp(argv[3],"dec")==0) {
         tel->axis_param[axisno].type=AXIS_DEC;
      } else if (strcmp(argv[3],"az")==0) {
         tel->axis_param[axisno].type=AXIS_AZ;
      } else if (strcmp(argv[3],"elev")==0) {
         tel->axis_param[axisno].type=AXIS_ELEV;
      } else if (strcmp(argv[3],"parallactic")==0) {
         tel->axis_param[axisno].type=AXIS_PARALLACTIC;
      } else {
      	strcpy(ligne,"axis_type must be ha|dec|az|elev|parallactic");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		   return TCL_ERROR;
      }
   }
   if (argc>4) {
      val=(int)atoi(argv[4]);
      if (val<1) {
      	strcpy(ligne,"teeth_per_turn must be > 1");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		   return TCL_ERROR;
      } else {
         tel->axis_param[axisno].teeth_per_turn=val;
      }
   }
   if (tel->axis_param[axisno].type=AXIS_HA) {
      strcpy(axistype,"ha");
   } else if (tel->axis_param[axisno].type=AXIS_DEC) {
      strcpy(axistype,"dec");
   } else if (tel->axis_param[axisno].type=AXIS_AZ) {
      strcpy(axistype,"az");
   } else if (tel->axis_param[axisno].type=AXIS_ELEV) {
      strcpy(axistype,"elev");
   } else if (tel->axis_param[axisno].type=AXIS_PARALLACTIC) {
      strcpy(axistype,"parallactic");
   } else {
      strcpy(axistype,"notdefined");
   }
   typ=3;
   idx=239;
   sidx=axisno;
	if (err = dsa_get_register_s(tel->drv,typ,idx,sidx,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   traits=val;
   typ=3;
   idx=241;
   sidx=axisno;
	if (err = dsa_get_register_s(tel->drv,typ,idx,sidx,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   interpo=val;
   uc_per_tooth=traits*interpo;
 	sprintf(ligne,"%d %s %d %ld",axisno,axistype,tel->axis_param[axisno].teeth_per_turn,uc_per_tooth);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	return TCL_OK;
}

int cmdTelTypeMount(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0;
   struct telprop *tel;
   char mounttype[50];
   tel = (struct telprop *)clientData;
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
   if (tel->type_mount=MOUNT_EQUATORIAL) {
      strcpy(mounttype,"equatorial");
   } else if (tel->type_mount=MOUNT_ALTAZ) {
      strcpy(mounttype,"altaz");
   } else {
      strcpy(mounttype,"unknown");
   }
 	sprintf(ligne,"%s",mounttype);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	return TCL_OK;
}
