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
   char ligne[256],s[256];
   int result = TCL_OK,err=0,k;
   struct telprop *tel;
	DSA_STATUS sta = {sizeof(DSA_STATUS)};
   tel = (struct telprop *)clientData;
	/* getting status */
	/* --- boucle sur les axes ---*/
	strcpy(s,"");
	for (k=0;k<3;k++) {
		if (err = dsa_get_status(tel->drv[k], &sta)) {
			mytel_error(tel,k,err);
   		sprintf(ligne,"%s",tel->msg);
			Tcl_SetResult(interp,ligne,TCL_VOLATILE);
			return TCL_ERROR;
		}
		sprintf(ligne,"{%x %x} ", sta.raw.sw1, sta.raw.sw2);
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
#if defined(MOUCHARD)
	FILE *f;
#endif
	FILE *f;

   tel = (struct telprop *)clientData;
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
		   params[kk].val.d=atof(argv[k+2]);
		}
	}
#if defined(MOUCHARD)
   f=fopen("mouchard_etel.txt","at");
   fprintf(f,"dsa_execute_command_x_s(%d=>axe%d,%d,%d,%d)\n",tel->drv[axisno],axisno,cmd,params[kk].val.i,nparams);
	fclose(f);
#endif
   f=fopen("mouchard_etel0.txt","at");
   fprintf(f,"dsa_execute_command_x_s(%d=>axe%d,%d,%d,%d)\n",tel->drv[axisno],axisno,cmd,params[kk].val.i,nparams);
	fclose(f);
	if (err = dsa_execute_command_x_s(tel->drv[axisno],cmd,params,nparams,FALSE,FALSE,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,k,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

int cmdTelGetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0,axisno;
   struct telprop *tel;
	int typ,idx,sidx=0,val;
#if defined(MOUCHARD)
	FILE *f;
#endif
   tel = (struct telprop *)clientData;
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
	if (err = dsa_get_register_s(tel->drv[axisno],typ,idx,sidx,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,axisno,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
#if defined(MOUCHARD)
   f=fopen("mouchard_etel.txt","at");
   fprintf(f,"dsa_get_register_s(%d=>axe%d,%d,%d,%d) => %d\n",tel->drv[axisno],axisno,typ,idx,sidx,val);
	fclose(f);
#endif
  	sprintf(ligne,"%d",val);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return result;
}

int cmdTelSetRegisterS(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0,axisno;
   struct telprop *tel;
	int typ,idx,sidx=0,val;
#if defined(MOUCHARD)
	FILE *f;
#endif
   tel = (struct telprop *)clientData;
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
#if defined(MOUCHARD)
   f=fopen("mouchard_etel.txt","at");
   fprintf(f,"dsa_set_register_s(%d=>axe%d,%d,%d,%d,%d)\n",tel->drv[axisno],axisno,typ,idx,sidx,val);
	fclose(f);
#endif
	if (err = dsa_set_register_s(tel->drv[axisno],typ,idx,sidx,val,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,axisno,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}

int cmdTelDsa_quick_stop_s(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/****************************************************************************/
{
   char ligne[256];
   int result = TCL_OK,err=0,axisno;
	int sidx=0;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<2) {
   	sprintf(ligne,"usage: %s %s axisno",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   axisno=atoi(argv[2]);
	if (err = dsa_quick_stop_s(tel->drv[axisno],DSA_QS_PROGRAMMED_DEC,DSA_QS_BYPASS | DSA_QS_STOP_SEQUENCE, DSA_DEF_TIMEOUT)) {
		mytel_error(tel,axisno,err);
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
   int traits,interpo,sens=1;
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
    	sprintf(ligne,"usage: %s %s axisno ha|dec|az|elev|parallactic ?teeth_per_turn? ?sens?",argv[0],argv[1]);
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
   if (argc>5) {
      val=(int)atoi(argv[5]);
		if (val>=0) {
			sens=1;
		} else {
			sens=-1;
      }
   }
   tel->axis_param[axisno].sens=sens;
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
   typ=ETEL_M;
   idx=239;
   sidx=0;
	if (err = dsa_get_register_s(tel->drv[axisno],typ,idx,sidx,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,axisno,err);
   	sprintf(ligne,"%s",tel->msg);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   traits=val;
   typ=ETEL_M;
   idx=241;
   sidx=0;
	if (err = dsa_get_register_s(tel->drv[axisno],typ,idx,sidx,&val,DSA_GET_CURRENT,DSA_DEF_TIMEOUT)) {
		mytel_error(tel,axisno,err);
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

int cmdTelIncAxis(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char s[1024],ligne[4096];
   int result = TCL_OK,err=0;
   struct telprop *tel;
   int axisno,val;
   char axistype[50];
   int traits,interpo,pos,spd,acc;
   long int uc_per_tooth;
   tel = (struct telprop *)clientData;
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
      uc_per_tooth=traits*interpo;
 	   sprintf(s,"{{axisno %d} {designation %s} {pos %d} {spd %d} {acc %d} {teeth_per_turn %d} {uc_per_tooth %ld} {pos0 %d} {angle0 %10f} {sens %d} ",
         axisno,axistype,
         pos,spd,acc,
         tel->axis_param[axisno].teeth_per_turn,uc_per_tooth,
			tel->axis_param[axisno].posinit,
			tel->axis_param[axisno].angleinit,
			tel->axis_param[axisno].sens);
      strcat(ligne,s);
   }
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
	return TCL_OK;
}

int cmdTelHaDec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[2256],texte[256];
   int result = TCL_OK,k;
   struct telprop *tel;
   char comment[]="Usage: %s %s ?goto|stop|move|coord|motor|init|state? ?options?";
   if (argc<3) {
      sprintf(ligne,comment,argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      tel = (struct telprop*)clientData;
      if (strcmp(argv[2],"init")==0) {
         /* --- init ---*/
         if (argc>=4) {
			 /* - call the pointing model if exists -*/
				/*
            sprintf(ligne,"set libtel(radec) {%s}",argv[3]);
            Tcl_Eval(interp,ligne);
			if (strcmp(tel->model_cat2tel,"")!=0) {
               sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_cat2tel,argv[3]);
               Tcl_Eval(interp,ligne);
			}
            Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
            strcpy(ligne,interp->result);
				*/
			 /* - end of pointing model-*/
            libtel_Getradec(interp,argv[3],&tel->ra0,&tel->dec0);
            mytel_hadec_init(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s init {angle_ha angle_dec}",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"coord")==0) {
         /* --- coord ---*/
			mytel_hadec_coord(tel,ligne);
			 /* - call the pointing model if exists -*/
			/*
         sprintf(ligne,"set libtel(radec) {%s}",texte);
         Tcl_Eval(interp,ligne);
         sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_tel2cat,texte);
         Tcl_Eval(interp,ligne);
            Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
            strcpy(ligne,interp->result);
				*/
			 /* - end of pointing model-*/
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      } else if (strcmp(argv[2],"state")==0) {
         /* --- state ---*/
			tel_radec_state(tel,texte);
            Tcl_SetResult(interp,texte,TCL_VOLATILE);
      } else if (strcmp(argv[2],"goto")==0) {
         /* --- goto ---*/
         if (argc>=4) {
			 /* - call the pointing model if exists -*/
				/*
            sprintf(ligne,"set libtel(radec) {%s}",argv[3]);
            Tcl_Eval(interp,ligne);
			if (strcmp(tel->model_cat2tel,"")!=0) {
               sprintf(ligne,"catch {set libtel(radec) [%s {%s}]}",tel->model_cat2tel,argv[3]);
               Tcl_Eval(interp,ligne);
			}
            Tcl_Eval(interp,"set libtel(radec) $libtel(radec)");
            strcpy(ligne,interp->result);
				*/
			 /* - end of pointing model-*/
            libtel_Getradec(interp,ligne,&tel->ra0,&tel->dec0);
            if (argc>=5) {
               for (k=4;k<=argc-1;k++) {
                  if (strcmp(argv[k],"-rate")==0) {
                     tel->radec_goto_rate=atof(argv[k+1]);
                  }
                  if (strcmp(argv[k],"-blocking")==0) {
                     tel->radec_goto_blocking=atoi(argv[k+1]);
                  }
               }
            }
            mytel_hadec_goto(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s goto {angle_ha angle_dec} ?-rate value? ?-blocking boolean?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"move")==0) {
         /* --- move ---*/
         if (argc>=4) {
            if (argc>=5) {
               tel->radec_move_rate=atof(argv[4]);
            }
            tel_radec_move(tel,argv[3]);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s move n|s|e|w ?rate?",argv[0],argv[1]);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_ERROR;
         }
      } else if (strcmp(argv[2],"stop")==0) {
         /* --- stop ---*/
         if (argc>=4) {
            tel_radec_stop(tel,argv[3]);
         } else {
            tel_radec_stop(tel,"");
         }
      } else if (strcmp(argv[2],"motor")==0) {
         /* --- motor ---*/
         if (argc>=4) {
            tel->radec_motor=0;
            if ((strcmp(argv[3],"off")==0)||(strcmp(argv[3],"0")==0)) {
               tel->radec_motor=1;
            }
            tel_radec_motor(tel);
            Tcl_SetResult(interp,"",TCL_VOLATILE);
         } else {
            sprintf(ligne,"Usage: %s %s motor on|off",argv[0],argv[1]);
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

int cmdTelInitDefault(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   char ligne[256];
   int result = TCL_OK,err=0,mountno;
   struct telprop *tel;
   tel = (struct telprop *)clientData;
   if (argc<3) {
   	sprintf(ligne,"usage: %s %s mountNo",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
		return TCL_ERROR;
	}
   mountno=atoi(argv[2]);
	mytel_init_mount_default(tel,mountno);
   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return result;
}
