/* libmc_angles.c
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

#include "libmc.h"

int Cmd_mctcl_xy2lonlat(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* conversion d'un pixel (x,y) vers les coordonnees sur la planete          */
/* mc_xy2lonlat 0 0 0 0.1 100 100 50 100 100                                */
/* mc_xy2lonlat 0 0 0 0.5 100 100 50 100 111.1803                           */
/****************************************************************************/
   char s[100];
   double lc,bc,p,f,xc,yc,rc,i,j,pui,ls,bs;
   double lon,lat,visibility;

   if(argc<=8) {
      sprintf(s,"Usage: %s lc bc P f xc yc req x y ?ls bs power?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
      /* --- decode ---*/
      mctcl_decode_angle(interp,argv[1],&lc);
      mctcl_decode_angle(interp,argv[2],&bc);
      mctcl_decode_angle(interp,argv[3],&p);
      f=(double)atof(argv[4]);
      xc=(double)atof(argv[5]);
      yc=(double)atof(argv[6]);
      rc=(double)atof(argv[7]);
      i=(double)atof(argv[8]);
      j=(double)atof(argv[9]);
      ls=lc;
      if (argc>=11) {
         mctcl_decode_angle(interp,argv[10],&ls);
      }
      bs=bc;
      if (argc>=12) {
         mctcl_decode_angle(interp,argv[11],&bs);
      }
      pui=0.11;
      if (argc>=13) {
         pui=(double)atof(argv[12]);
      }
      /* --- --*/
      p*=(DR);
      lc*=(DR);
      bc*=(DR);
      ls*=(DR);
      bs*=(DR);
      mc_map_xy2lonlat(lc,bc,p,f,xc,yc,rc,ls,bs,pui,i,j,&lon,&lat,&visibility);
      sprintf(s,"%12f %12f %12f",lon/(DR),lat/(DR),visibility);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_mctcl_lonlat2xy(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* conversion des coordonnees sur la planete vers un pixel (x,y)            */
/* mc_lonlat2xy 0 0 0 0 100 100 50 0 0                                      */
/****************************************************************************/
   char s[100];
   double lc,bc,p,f,xc,yc,rc,pui,ls,bs,lon,lat;
   double i,j,visibility;

   if(argc<=8) {
      sprintf(s,"Usage: %s lc bc P f xc yc req lon lat ?ls bs power?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
      /* --- decode ---*/
      mctcl_decode_angle(interp,argv[1],&lc);
      mctcl_decode_angle(interp,argv[2],&bc);
      mctcl_decode_angle(interp,argv[3],&p);
      f=(double)atof(argv[4]);
      xc=(double)atof(argv[5]);
      yc=(double)atof(argv[6]);
      rc=(double)atof(argv[7]);
      lon=(double)atof(argv[8]);
      lat=(double)atof(argv[9]);
      ls=lc;
      if (argc>=11) {
         mctcl_decode_angle(interp,argv[10],&ls);
      }
      bs=bc;
      if (argc>=12) {
         mctcl_decode_angle(interp,argv[11],&bs);
      }
      pui=0.11;
      if (argc>=13) {
         pui=(double)atof(argv[12]);
      }
      /* --- --*/
      p*=(DR);
      lc*=(DR);
      bc*=(DR);
      ls*=(DR);
      bs*=(DR);
      lon*=(DR);
      lat*=(DR);
      mc_map_lonlat2xy(lc,bc,p,f,xc,yc,rc,ls,bs,pui,lon,lat,&i,&j,&visibility);
      sprintf(s,"%12f %12f %12f",i,j,visibility);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_mctcl_baryvel(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit des coordonn�es Home en divers rep�res g�od�siques             */
/****************************************************************************/
/* Entrees :                                                                */
/* mc_baryvel Date Ra Dec ?Home?                                            */
/* Ra,dec sont les coordonnees a la date                                    */
/*                                                                          */
/* Sortie (toutes les coordonnees sont a la date)                           */
/* v {x y z vx vy vz}                                                       */
/* v  : velocity toward the star (km/s)                                     */
/* (x,y,z) : (UA)                                                           */
/* (vx,vy,vz) : km/s                                                        */
/*                                                                          */
/****************************************************************************/

   double longi,rhocosphip,rhosinphip,asd2,dec2;
   char s[100];
   int planete;
   double v,x,y,z,vx,vy,vz,jj,asd,dec,equinox;

   if(argc<=4) {
      sprintf(s,"Usage: %s Date Angle_Ra Angle_Dec Equinox ?Home?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
 	   /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[1],&jj);
      /* --- decode l'angle RA ---*/
      mctcl_decode_angle(interp,argv[2],&asd);
      asd*=(DR);
      /* --- decode l'angle DEC ---*/
      mctcl_decode_angle(interp,argv[3],&dec);
      dec*=(DR);
 	   /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[4],&equinox);
      /* --- decode le Home ---*/
      longi=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      if (argc>=6) {
         mctcl_decode_topo(interp,argv[5],&longi,&rhocosphip,&rhosinphip);
      }
      planete=SOLEIL;
      /* --- calcul de la precession equinox -> a la date ---*/
      mc_precad(equinox,asd,dec,jj,&asd2,&dec2);
      /* --- calcul --- */
      mc_baryvel(jj,planete,longi,rhocosphip,rhosinphip,asd2,dec2,&x,&y,&z,&vx,&vy,&vz,&v);
      sprintf(s,"%12f {%12f %12f %12f %12f %12f %12f}",v*(UA)/86400000.,x,y,z,vx*(UA)/86400000.,vy*(UA)/86400000.,vz*(UA)/86400000.);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_mctcl_rvcor(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Calcule la correction de vitesse radiale / a un referentiel              */
/****************************************************************************/
/* Entrees :                                                                */
/* mc_rvcor {Ra Dec} Equinox frame                                          */
/* frame=KLSR (Kinetic local standard of rest)                              */
/* frame=DLSR (Dynamic local standard of rest)                              */
/* frame=GALC (Galactocentric)                                              */
/* frame=LOG (Local Group)                                                  */
/* frame=COSM (Cosmic)                                                      */
/*                                                                          */
/* Sortie                                                                   */
/* v a ajouter                                                              */
/****************************************************************************/
   double jjfrom=0.,asd2=0.,dec2=0.,radeg,decdeg,v;
   int result=TCL_ERROR;
   char s[1000];
   char **argvv=NULL;
   int argcc,method;
   char usage[]="Usage: %s ListRaDec Equinox KLSR|DLSR|GALC|LOG|COSM";

   if(argc<4) {
      sprintf(s,usage, argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decode la date de l'equinoxe ---*/
      mctcl_decode_date(interp,argv[2],&jjfrom);
      /*--- Calcul des coordonnees Ra,Dec */
      if (Tcl_SplitList(interp,argv[1],&argcc,&argvv)==TCL_OK) {
		   if (argcc>=2) {
            mctcl_decode_angle(interp,argvv[0],&radeg);
            mctcl_decode_angle(interp,argvv[1],&decdeg);
            Tcl_Free((char *) argvv);
         } else {
            Tcl_Free((char *) argvv);
            sprintf(s,usage, argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
		   }
	   }
      /* --- ---*/
      mc_strupr(argv[3],s);
      strcpy(s,"KLSR");
      method=-1;
      if (strcmp(s,"KLSR")==0) { method=RV_KLSR; }
      else if (strcmp(s,"DLSR")==0) { method=RV_DLSR; }
      else if (strcmp(s,"GALC")==0) { method=RV_GALC; }
      else if (strcmp(s,"LOG")==0) { method=RV_LOG; }
      else if (strcmp(s,"COSM")==0) { method=RV_COSM; }
      if (method==-1) {
         sprintf(s,usage, argv[0]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* - */
      asd2=radeg*(DR);
      dec2=decdeg*(DR);
      /* --- calcul ---*/
      mc_rvcor(asd2,dec2,jjfrom,method,&v);
      /* --- sortie des r�sultats ---*/
	   sprintf(s,"%12f",v);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;

   }
   return result;
}

int Cmd_mctcl_home2geosys(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit des coordonn�es Home en divers rep�res g�od�siques             */
/****************************************************************************/
/* Entrees :                                                                */
/* mc_home2geosys Home geosysin geosysout                                   */
/*                                                                          */
/* Sortie                                                                   */
/* long lat alt                                                             */
/*                                                                          */
/****************************************************************************/
   double latitude,altitude,longi,rhocosphip,rhosinphip;
   char geosysin[100],geosysout[100];
   int in=0,out=0,k,compute_h;
   char s[100];
   double a_wgs84,f_wgs84,a_ed50,f_ed50,a1,f1,a2,f2,a,f,ee,b;
   double dX,dY,dZ,X1,Y1,Z1,X2,Y2,Z2;
   double sinphi,cosphi,sinlon,coslon,h,W,N,rho,r,phi0,phi2,delta;

   if(argc<=3) {
      sprintf(s,"Usage: %s Home ED50|WGS84 WGS84|ED50 ?-height?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
      /* --- decode le Home ---*/
      mctcl_decode_topo(interp,argv[1],&longi,&rhocosphip,&rhosinphip);
      mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
      latitude*=(DR);
      /* - */
 	   strcpy(geosysin,argv[2]);
	   mc_strupr(geosysin,geosysin);
      /* - */
 	   strcpy(geosysout,argv[3]);
	   mc_strupr(geosysout,geosysout);
       /* - */
       compute_h=0;
       if (argc>=5) {
          for (k=4;k<argc;k++) {
             if (strcmp(argv[k],"-height")==0) {
                compute_h=1;
             }
          }
      }
      /* - */
      a_wgs84=6378137.0;
      f_wgs84=1./298.257223563;
      a_ed50=6378388.0;
      f_ed50=1./297.;
      /* - */
      in=0;
      a1=a_wgs84;
      f1=f_wgs84;
      if (strcmp(geosysin,"ED50")==0) {
         in=1;
         a1=a_ed50;
         f1=f_ed50;
      }
      out=0;
      a2=a_wgs84;
      f2=f_wgs84;
      if (strcmp(geosysout,"ED50")==0) {
         out=1;
         a2=a_ed50;
         f2=f_ed50;
      }
      /* - */
      if (in==out) {
         /* latitude,altitude,longi*/
         longi=longi/(DR);
         latitude=latitude/(DR);
	      sprintf(s,"%12f %12f %12f",longi,latitude,altitude);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_OK;
      }
      dX=0.;
      dY=0.;
      dZ=0.;
      if ((in==1)&&(out==0)) {
         dX=-84.;
         dY=-97.;
         dZ=-117.;
      }
      if ((in==0)&&(out==1)) {
         dX=84.;
         dY=97.;
         dZ=117.;
      }
      /* - spheric to cartesian - */
      a=a1;
      f=f1;
      b=a*(1-f);
      ee=(a*a-b*b)/(a*a);
      sinphi=sin(latitude);
      cosphi=cos(latitude);
      coslon=cos(longi);
      sinlon=sin(longi);
      h=altitude;
      W=sqrt(1-ee*sinphi*sinphi);
      N=a/W;
      rho=a*(1-ee)/(W*W*W);
      r=N*cosphi;
      X1=(N+h)*cosphi*coslon;
      Y1=(N+h)*cosphi*sinlon;
      Z1=(N*(1-ee)+h)*sinphi;
      /* - translation - */
      X2=X1+dX;
      Y2=Y1+dY;
      Z2=Z1+dZ;
      /* - spheric to cartesian - */
      a=a2;
      f=f2;
      b=a*(1-f);
      ee=(a*a-b*b)/(a*a);
      longi=2*atan2(Y2,X2+sqrt(X2*X2+Y2*Y2));
      phi0=atan2(Z2,sqrt(X2*X2+Y2*Y2)*(1-a*ee/sqrt(X2*X2+Y2*Y2+Z2*Z2)));
      do {
         cosphi=cos(phi0);
         sinphi=sin(phi0);
         phi2=atan((Z2/sqrt(X2*X2+Y2*Y2))/(1-a*ee*cosphi/(sqrt(X2*X2+Y2*Y2)*sqrt(1-ee*sinphi*sinphi))));
         delta=fabs(phi2-phi0)/(DR)*3600.;
         phi0=phi2;
      } while (delta<0.1);
      cosphi=cos(phi2);
      sinphi=sin(phi2);
      h=sqrt(X2*X2+Y2*Y2)/cosphi-a/sqrt(1-ee*sinphi*sinphi);
      /* - */
      longi=longi/(DR);
      latitude=phi2/(DR);
      if (compute_h==0) {
         sprintf(s,"%12f %12f %12f",longi,latitude,altitude);
      } else {
         sprintf(s,"%12f %12f %12f %12f",longi,latitude,altitude,h);
      }
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}
/* mc_home2geosys {gps 1.3780 e 43.6609 142} ED50 WGS84 -height */

int Cmd_mctcl_dms2deg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit un angle dms en degres                                         */
/****************************************************************************/
/* Entrees :                 												             */
/* d m s.s																	                */
/*																			                   */
/* Sorties :																                */
/* degres																	                */
/****************************************************************************/
   double dd=0.,mm=0.,ss=0.,d;
   int result,retour;
   char s[100];

   if(argc<=1) {
      sprintf(s,"Usage: %s Dd ?Mm? ?Ss?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      retour = Tcl_GetDouble(interp, argv[1], &dd);
      if(retour!=TCL_OK) return retour;
	  if (argc>=3) {
         retour = Tcl_GetDouble(interp, argv[2], &mm);
         if(retour!=TCL_OK) return retour;
	  }
	  if (argc>=4) {
         retour = Tcl_GetDouble(interp, argv[3], &ss);
         if(retour!=TCL_OK) return retour;
	  }
	  d=fabs(dd)+(fabs(mm)+(fabs(ss)/60.))/60.;
     if (strstr(argv[1],"-")!=NULL) {
        d=-d;
     }
	  sprintf(s,"%12f",d);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mctcl_hms2deg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit un angle dms en degres                                         */
/****************************************************************************/
/* Entrees :                 												*/
/* h m s.s																	*/
/*																			*/
/* Sorties :																*/
/* degres																	*/
/****************************************************************************/
   double dd=0.,mm=0.,ss=0.,d;
   int result,retour;
   char s[100];

   if(argc<=1) {
      sprintf(s,"Usage: %s Hh ?Mm? ?Ss?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      retour = Tcl_GetDouble(interp, argv[1], &dd);
      if(retour!=TCL_OK) return retour;
	  if (argc>=3) {
         retour = Tcl_GetDouble(interp, argv[2], &mm);
         if(retour!=TCL_OK) return retour;
	  }
	  if (argc>=4) {
         retour = Tcl_GetDouble(interp, argv[3], &ss);
         if(retour!=TCL_OK) return retour;
	  }
	  d=fabs(dd)+(fabs(mm)+(fabs(ss)/60.))/60.;
     if (strstr(argv[1],"-")!=NULL) {
        d=-d;
     }
     d=d*15.;
	  sprintf(s,"%12f",d);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}


int Cmd_mctcl_deg2dms(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit un angle degres en dms                                         */
/****************************************************************************/
/* Entrees :                 												*/
/* degres																	*/
/*																			*/
/* Sorties :																*/
/* d m s.s																	*/
/****************************************************************************/
   double ss=0.,d=0.;
   int dd=0,mm=0;
   int result,retour;
   char s[100],charsigne[2];

   if(argc<=1) {
      sprintf(s,"Usage: %s Degrees", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      retour = Tcl_GetDouble(interp, argv[1], &d);
      if(retour!=TCL_OK) return retour;
	  /* --- conversion radian vers hms ---*/
	  mc_deg2d_m_s(d,charsigne,&dd,&mm,&ss);
	  /* --- sortie des resultats ---*/
      sprintf(s,"%s%d %d %f",charsigne,dd,mm,ss);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mctcl_deg2hms(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit un angle degres en hms                                         */
/****************************************************************************/
/* Entrees :                 												*/
/* degres																	*/
/*																			*/
/* Sorties :																*/
/* h m s.s																	*/
/****************************************************************************/
   double ss=0.,d=0.;
   int dd=0,mm=0;
   int result,retour;
   char s[100];

   if(argc<=1) {
      sprintf(s,"Usage: %s Degrees", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      retour = Tcl_GetDouble(interp, argv[1], &d);
      if(retour!=TCL_OK) return retour;
	  /* --- conversion radian vers hms ---*/
	  mc_deg2h_m_s(d,&dd,&mm,&ss);
	  /* --- sortie des resultats ---*/
      sprintf(s,"%d %d %f",dd,mm,ss);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}
int mctcl_listfield2mc_astrom(Tcl_Interp *interp, char *listfield, mc_ASTROM *p)
/****************************************************************************/
/* Convertit une liste de definition de champ dans la structure mc_astrom   */
/****************************************************************************/
/* {ListField}                                                              */
/*   Le 1er argument contient le type de definition de champ.               */
/*    BUFFER : pour un buffer de Audela (lecture de l'entete d'image).      */
/*             Le deuxieme argument contient le numero de buffer.           */
/*    OPTIC : pour entrer manuellement les valeurs avec les parametres      */
/*           optiques instrumentaux (focale, etc.)                          */
/*           Les arguments suivants definissent le champ :                  */
/*           NAXIS1 nombre de pixels sur x                                  */
/*           NAXIS2 nombre de pixels sur y                                  */
/*           FOCLEN focale de l'objectif (en m)                             */
/*           PIXSIZE1 taille du pixel sur x (en m/pixel)                    */
/*                    n�gatif si RA croissant avec x decroissant.           */
/*           PIXSIZE2 taille du pixel sur y (en m/pixel)                    */
/*                    n�gatif si DEC croissant avec y decroissant.          */
/*           CROTA2 angle de rotation du champ (degres partir du nord->est) */
/*           RA Ascension droite du centre (degres)                         */
/*           DEC Declinaison du centre (degres)                             */
/****************************************************************************/
{
   char s[524];
   int inputdatatype,nbinputdatas;
   char **inputdatas=NULL,*pres=NULL;
   Tcl_DString res;
   int code,k;

	code=Tcl_SplitList(interp,listfield,&nbinputdatas,&inputdatas);
	strcpy(s,inputdatas[0]);
	mc_strupr(s,s);
	if (strcmp(s,"BUFFER")==0) {
	   inputdatatype=0;
	} else {
	   inputdatatype=1;
	}
	p->naxis1=200;
	p->naxis2=150;
	p->foclen=1.;
	p->px=9.e-6;
	p->py=9.e-6;
	p->crota2=0.;
	p->ra0=0.;
	p->dec0=0.;
   p->cd11=0.;p->cd12=0.;p->cd21=0.;p->cd22=0.;
	p->crval1=0.;p->crval2=0.;
	p->cdelta1=0.;p->cdelta2=0.;
	p->crpix1=0.;p->crpix2=0.;
	if (inputdatatype==1) {
	   for (k=0;k<nbinputdatas-1;k++) {
	      strcpy(s,inputdatas[k]);
		   mc_strupr(s,s);
		   if (strcmp(s,"FOCLEN")==0) { p->foclen=atof(inputdatas[k+1]); }
		   else if (strcmp(s,"NAXIS1")==0) { p->naxis1=atoi(inputdatas[k+1]); }
		   else if (strcmp(s,"NAXIS2")==0) { p->naxis2=atoi(inputdatas[k+1]); }
		   else if (strcmp(s,"PIXSIZE1")==0) { p->px=atof(inputdatas[k+1]); }
		   else if (strcmp(s,"PIXSIZE2")==0) { p->py=atof(inputdatas[k+1]); }
		   else if (strcmp(s,"CROTA2")==0) { p->crota2=atof(inputdatas[k+1])*(DR); }
		   else if (strcmp(s,"RA")==0) { p->ra0=atof(inputdatas[k+1])*(DR); p->crval1=p->ra0; }
		   else if (strcmp(s,"DEC")==0) { p->dec0=atof(inputdatas[k+1])*(DR); p->crval2=p->dec0; }
      }
      p->crpix1=p->naxis1/2.;
      p->crpix2=p->naxis2/2.;
   } else if (inputdatatype==0) {
      /*--- On recopie les mots-cles du buffer temporaire dans le buffer */
      sprintf(s,"buf%d getkwds",atoi(inputdatas[1]));
      Tcl_ResetResult(interp);
      if(Tcl_Eval(interp,s)==TCL_ERROR) {
         if (inputdatas!=NULL) { Tcl_Free((char *) inputdatas); }
         return(TCL_ERROR);
      }
		Tcl_DStringInit(&res);
		Tcl_DStringAppend(&res,Tcl_GetStringResult(interp),-1);
      pres=Tcl_DStringValue(&res);
      if (pres==NULL) {
		} else {
         mctcl_util_getkey_astrometry(interp,atoi(inputdatas[1]),p);
		}
   }
   if (inputdatas!=NULL) { Tcl_Free((char *) inputdatas); }
	/* --- complete le tableau de projections de ListField ---*/
	if ((p->cd11*p->cd12)==0.) {
	   if ((p->cdelta1==0.)||(p->cdelta2==0.)) {
		   if (p->foclen==0.) {p->foclen=1.;}
			if (p->px==0.) {p->px=9e-6;}
			if (p->py==0.) {p->py=9e-6;}
			p->cdelta1=-2*atan(p->px/2./p->foclen);
         p->cdelta2=2*atan(p->py/2./p->foclen);
		}
	   p->cd11=p->cdelta1*cos(p->crota2);
      p->cd12=fabs(p->cdelta2)*p->cdelta1/fabs(p->cdelta1)*sin(p->crota2);
      p->cd21=-fabs(p->cdelta1)*p->cdelta2/fabs(p->cdelta2)*sin(p->crota2);
      p->cd22=p->cdelta2*cos(p->crota2);
	} else if ((p->cdelta1==0.)||(p->cdelta2==0.)) {
      mc_util_cd2cdelt_old(p->cd11,p->cd12,p->cd21,p->cd22,&p->cdelta1,&p->cdelta2,&p->crota2);
	}
   return(TCL_OK);
}

int Cmd_mctcl_xy2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* conversion x,y -> ra,dec                                                 */
/****************************************************************************/
/* paramastrom x y ListField                                                */
/*                                                                          */
/* Entrees :                 												             */
/*                                                                          */
/****************************************************************************/
{
   mc_ASTROM p;
   char s[524];
   int result,retour;
   double x,y,asd,dec;

   if(argc<=3) {
      sprintf(s,"Usage: %s x y Field", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	  return(result);
   } else {
	  result=TCL_OK;
     retour = Tcl_GetDouble(interp, argv[1], &x);
     if(retour!=TCL_OK) return retour;
     retour = Tcl_GetDouble(interp, argv[2], &y);
     if(retour!=TCL_OK) return retour;
     mctcl_listfield2mc_astrom(interp,argv[3],&p);
     mc_util_astrom_xy2radec(&p,x-1.,y-1.,&asd,&dec);
     sprintf(s,"%12f %12f",asd/(DR),dec/(DR));
     Tcl_SetResult(interp,s,TCL_VOLATILE);
     result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_radec2altaz(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* conversion ra,dec -> az,h,HA,parallactic                                 */
/****************************************************************************/
/*                                                                          */
/* Entrees :                 												             */
/*                                                                          */
/****************************************************************************/
{
   char s[524];
   int result;
   double ra,dec,longi,rhocosphip,rhosinphip,jj;
   double ha,latitude,altitude,az,h,parallactic;
   /*double xaz,xh,xp,xhr;*/

   if(argc<=4) {
      sprintf(s,"Usage: %s Angle_ra Angle_dec Home Date", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
 	   return(result);
   } else {
	   result=TCL_OK;
      /* --- decode l'angle RA ---*/
      mctcl_decode_angle(interp,argv[1],&ra);
      ra*=(DR);
      /* --- decode l'angle DEC ---*/
      mctcl_decode_angle(interp,argv[2],&dec);
      dec*=(DR);
      /* --- decode le Home ---*/
      mctcl_decode_topo(interp,argv[3],&longi,&rhocosphip,&rhosinphip);
      mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
      latitude*=(DR);
      /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[4],&jj);
      /* --- calcul de conversion ---*/
      mc_ad2hd(jj,longi,ra,&ha);
      mc_hd2ah(ha,dec,latitude,&az,&h);
      mc_hd2parallactic(ha,dec,latitude,&parallactic);
      /* --- test ---*/
      /*mc_equat2altaz(2000,9,22.,longi,latitude,ra,dec,&xaz,&xh,&xhr,&xp);*/
	   /* --- sortie des resultats ---*/
      sprintf(s,"%.12g %.12g %.12g %.12g",az/(DR),h/(DR),ha/(DR),parallactic/(DR));
      /*sprintf(s,"%lf %lf %lf %lf (%lf %lf %lf %lf)",az/(DR),h/(DR),ha/(DR),parallactic/(DR),xaz/(DR),xh/(DR),xhr/(DR),xp/(DR));*/
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_altaz2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* conversion az,h -> ra,dec,HA,parallactic                                 */
/****************************************************************************/
/*                                                                          */
/* Entrees :                 												             */
/*                                                                          */
/****************************************************************************/
{
   char s[524];
   int result;
   double ra,dec,longi,rhocosphip,rhosinphip,jj;
   double ha,latitude,altitude,az,h,parallactic;
   /*double xaz,xh,xp,xhr;*/

   if(argc<=4) {
      sprintf(s,"Usage: %s Angle_az Angle_alt Home Date", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
 	   return(result);
   } else {
	   result=TCL_OK;
      /* --- decode l'angle AZ ---*/
      mctcl_decode_angle(interp,argv[1],&az);
      az*=(DR);
      /* --- decode l'angle H ---*/
      mctcl_decode_angle(interp,argv[2],&h);
      h*=(DR);
      /* --- decode le Home ---*/
      mctcl_decode_topo(interp,argv[3],&longi,&rhocosphip,&rhosinphip);
      mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
      latitude*=(DR);
      /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[4],&jj);
      /* --- calcul de conversion ---*/
      mc_ah2hd(az,h,latitude,&ha,&dec);
      mc_hd2ad(jj,longi,ha,&ra);
      mc_hd2parallactic(ha,dec,latitude,&parallactic);
      /* --- test ---*/
      /*mc_equat2altaz(2000,9,22.,longi,latitude,ra,dec,&xaz,&xh,&xhr,&xp);*/
	   /* --- sortie des resultats ---*/
      sprintf(s,"%.12g %.12g %.12g %.12g",ra/(DR),dec/(DR),ha/(DR),parallactic/(DR));
      /*sprintf(s,"%lf %lf %lf %lf (%lf %lf %lf %lf)",az/(DR),h/(DR),ha/(DR),parallactic/(DR),xaz/(DR),xh/(DR),xhr/(DR),xp/(DR));*/
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_hadec2altaz(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* conversion HA,dec -> az,h,HA,parallactic                                 */
/****************************************************************************/
/*                                                                          */
/* Entrees :                 												             */
/*                                                                          */
/****************************************************************************/
{
   char s[524];
   int result;
   double dec,longi,rhocosphip,rhosinphip;
   double ha,latitude,altitude,az,h,parallactic;
   /*double xaz,xh,xp,xhr;*/

   if(argc<=3) {
      sprintf(s,"Usage: %s Angle_HA Angle_dec Home", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
 	   return(result);
   } else {
	   result=TCL_OK;
      /* --- decode l'angle HA ---*/
      mctcl_decode_angle(interp,argv[1],&ha);
      ha*=(DR);
      /* --- decode l'angle DEC ---*/
      mctcl_decode_angle(interp,argv[2],&dec);
      dec*=(DR);
      /* --- decode le Home ---*/
      mctcl_decode_topo(interp,argv[3],&longi,&rhocosphip,&rhosinphip);
      mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
      latitude*=(DR);
      /* --- calcul de conversion ---*/
      mc_hd2ah(ha,dec,latitude,&az,&h);
      mc_hd2parallactic(ha,dec,latitude,&parallactic);
      /* --- test ---*/
      /*mc_equat2altaz(2000,9,22.,longi,latitude,ra,dec,&xaz,&xh,&xhr,&xp);*/
	   /* --- sortie des resultats ---*/
      sprintf(s,"%.12g %.12g %.12g %.12g",az/(DR),h/(DR),ha/(DR),parallactic/(DR));
// mc_hadec2altaz 12.34567 45.67889 {gps 4. e 43 1230} now0
      /*sprintf(s,"%lf %lf %lf %lf (%lf %lf %lf %lf)",az/(DR),h/(DR),ha/(DR),parallactic/(DR),xaz/(DR),xh/(DR),xhr/(DR),xp/(DR));*/
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_altaz2hadec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* conversion az,h -> HA,dec,HA,parallactic                                 */
/****************************************************************************/
/*                                                                          */
/* Entrees :                 												             */
/*                                                                          */
/****************************************************************************/
{
   char s[524];
   int result;
   double dec,longi,rhocosphip,rhosinphip;
   double ha,latitude,altitude,az,h,parallactic;
   /*double xaz,xh,xp,xhr;*/

   if(argc<=3) {
      sprintf(s,"Usage: %s Angle_az Angle_alt Home", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
 	   return(result);
   } else {
	   result=TCL_OK;
      /* --- decode l'angle az ---*/
      mctcl_decode_angle(interp,argv[1],&az);
      az*=(DR);
      /* --- decode l'angle DEC ---*/
      mctcl_decode_angle(interp,argv[2],&h);
      h*=(DR);
      /* --- decode le Home ---*/
      mctcl_decode_topo(interp,argv[3],&longi,&rhocosphip,&rhosinphip);
      mc_rhophi2latalt(rhosinphip,rhocosphip,&latitude,&altitude);
      latitude*=(DR);
      /* --- calcul de conversion ---*/
      mc_ah2hd(az,h,latitude,&ha,&dec);
      mc_hd2parallactic(ha,dec,latitude,&parallactic);
      /* --- test ---*/
      /*mc_equat2altaz(2000,9,22.,longi,latitude,ra,dec,&xaz,&xh,&xhr,&xp);*/	   
      /* --- sortie des resultats ---*/
      sprintf(s,"%.12g %.12g %.12g",ha/(DR),dec/(DR),parallactic/(DR));
      /*sprintf(s,"%lf %lf %lf %lf (%lf %lf %lf %lf)",az/(DR),h/(DR),ha/(DR),parallactic/(DR),xaz/(DR),xh/(DR),xhr/(DR),xp/(DR));*/
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_refraction(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Calcul de la refraction                                                  */
/****************************************************************************/
/*                                                                          */
/* Entrees :                 												             */
/*                                                                          */
/****************************************************************************/
{
   char s[524];
   int result,inout;
   double h,pressure,temperature,refraction;

   if(argc<=2) {
      sprintf(s,"Usage: %s altitude out2in|in2out ?temperature? ?pressure?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
 	   return(result);
   } else {
	   result=TCL_OK;
      /* --- decode l'angle h ---*/
      mctcl_decode_angle(interp,argv[1],&h);
      h*=(DR);
      /* --- decode out2in|in2out ---*/
		strcpy(s,argv[2]);
		mc_strupr(s,s);
		if (strcmp(s,"IN2OUT")==0) {
         inout=-1;
		} else {
			inout=1;
		}
      /* --- decode la temperature (K) ---*/
		temperature=283.;
		if (argc>=4) {
         temperature=atof(argv[3]);
		}
      /* --- decode la temperature (Pa) ---*/
		pressure=101000.;
		if (argc>=5) {
         pressure=atof(argv[4]);
		}
      /* --- calcul de conversion ---*/
      mc_refraction(h,inout,temperature,pressure,&refraction);
	   /* --- sortie des resultats ---*/
      sprintf(s,"%.12g",refraction/(DR));
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_radec2xy(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* conversion ra,dec -> x,y                                                 */
/****************************************************************************/
/* paramastrom ra dec ListField                                             */
/*                                                                          */
/* Entrees :                 												             */
/*                                                                          */
/****************************************************************************/
{
   mc_ASTROM p;
   char s[524];
   int result,retour;
   double x,y,asd,dec;

   if(argc<=3) {
      sprintf(s,"Usage: %s ra dec Field", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	  return(result);
   } else {
	  result=TCL_OK;
     retour = Tcl_GetDouble(interp, argv[1], &asd);
     if(retour!=TCL_OK) return retour;
     retour = Tcl_GetDouble(interp, argv[2], &dec);
     if(retour!=TCL_OK) return retour;
     mctcl_listfield2mc_astrom(interp,argv[3],&p);
     mc_util_astrom_radec2xy(&p,asd*(DR),dec*(DR),&x,&y);
     sprintf(s,"%12f %12f",x+1.,y+1.);
     Tcl_SetResult(interp,s,TCL_VOLATILE);
     result = TCL_OK;
   }
   return(result);
}


int Cmd_mctcl_paramastrom(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Lit les parametres astrometriques d'une image.                           */
/****************************************************************************/
/* paramastrom Numbuffer                                                    */
/*                                                                          */
/* Entrees :                 												             */
/* {Numbuffer}                                                              */
/*   Numero du buffer                                                       */
/*                                                                          */
/****************************************************************************/
{
   mc_ASTROM p;
   Tcl_DString dsptr;
   char s[524];
   int result,numbuf,retour;

   if(argc<=1) {
      sprintf(s,"Usage: %s Numbuffer", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	  return(result);
   } else {
	  result=TCL_OK;
     retour = Tcl_GetInt(interp, argv[1], &numbuf);
     if(retour!=TCL_OK) return retour;
     mctcl_util_getkey_astrometry(interp,numbuf,&p);
     if (p.valid==YES) {
	     Tcl_DStringInit(&dsptr);
        /*Tcl_DStringAppend(&dsptr,"{",-1);*/
        sprintf(s,"NAXIS1 %d NAXIS2 %d ",p.naxis1,p.naxis2);
        Tcl_DStringAppend(&dsptr,s,-1);
        sprintf(s,"CRPIX1 %g CRPIX2 %g ",p.crpix1,p.crpix2);
        Tcl_DStringAppend(&dsptr,s,-1);
        sprintf(s,"CRVAL1 %9g CRVAL2 %9g ",p.crval1/(DR),p.crval2/(DR));
        Tcl_DStringAppend(&dsptr,s,-1);
        sprintf(s,"CDELT1 %g CDELT2 %g ",p.cdelta1/(DR),p.cdelta2/(DR));
        Tcl_DStringAppend(&dsptr,s,-1);
        sprintf(s,"CROTA2 %g ",p.crota2/(DR));
        Tcl_DStringAppend(&dsptr,s,-1);
        sprintf(s,"CD11 %g CD12 %g CD21 %g CD22 %g",p.cd11/(DR),p.cd12/(DR),p.cd21/(DR),p.cd22/(DR));
        Tcl_DStringAppend(&dsptr,s,-1);
        /*Tcl_DStringAppend(&dsptr,"}",-1);*/
        Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
     }
   }
   return(result);
}

int mctcl_util_getkey_astrometry(Tcl_Interp *interp,int numbuf,mc_ASTROM *p_ast)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int msg,valid=NO;

   if ((msg=mctcl_util_getkey0_astrometry(interp,numbuf,p_ast,&valid))!=TCL_OK) {
      return(msg);
   }

   p_ast->valid=YES;
   if (valid==NO) {
      p_ast->valid=NO;
      /* --- valeurs par defaut ---*/
      p_ast->px=18.e-6;
      p_ast->py=18.e-6;
      p_ast->foclen=1.;
      p_ast->ra0=0.;
      p_ast->dec0=0.;
      p_ast->crval1=0.;
      p_ast->crval2=0.;
      p_ast->cdelta1=0.;
      p_ast->cdelta2=0.;
      p_ast->crota2=0.;
      p_ast->crpix1=0;
      p_ast->naxis1=0;
      p_ast->crpix2=0;
      p_ast->naxis2=0;
   }
   return(TCL_OK);
}

int mctcl_util_getkey0_astrometry(Tcl_Interp *interp,int numbuf,mc_ASTROM *p_ast,int *valid)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   char keyname[10],s[50],lignetcl[50],lignetclu[50],value_char[100];
   char unit[50];
   int datatype,v;
   int crval1found=NO,crval2found=NO,crota2found=NO;
   int crpix1found=NO,crpix2found=NO;
   int valid_optic=0,valid_crvp=0,valid_cd=0;
   double dvalue;

   p_ast->crota2=0.;

   p_ast->foclen=0.; /* focale en m*/
   p_ast->px=0.;     /* pixel en m */
   p_ast->py=0.;
   p_ast->crota2=0.;
   p_ast->cd11=0.;
   p_ast->cd12=0.;
   p_ast->cd21=0.;
   p_ast->cd22=0.;
   p_ast->crpix1=0.;
   p_ast->crpix2=0.;
   p_ast->crval1=0.;
   p_ast->crval2=0.;
   p_ast->cdelta1=0.;
   p_ast->cdelta2=0.;
   p_ast->dec0=-100.;
   p_ast->ra0=-100.;

   strcpy(lignetcl,"lindex [buf%ld getkwd %s] 1");
   strcpy(lignetclu,"lindex [buf%ld getkwd %s] 4");

   /* -- recherche des mots cles naxis1 et naxis2 dans l'entete FITS --*/
   strcpy(keyname,"NAXIS1");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
   } else {
      p_ast->naxis1=atoi(value_char);
   }
   if (p_ast->naxis1==0) {
      return 0;
   }
   strcpy(keyname,"NAXIS2");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
   } else {
      p_ast->naxis2=atoi(value_char);
   }

   /* -- recherche des mots cles d'astrometrie '_optic' dans l'entete FITS --*/
   strcpy(keyname,"FOCLEN");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
   } else {
      valid_optic++;
      dvalue=atof(value_char);
      if (dvalue>0) { p_ast->foclen=dvalue; }
   }
   strcpy(keyname,"PIXSIZE1");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
   } else {
      sprintf(s,lignetclu,numbuf,keyname);Tcl_Eval(interp,s);strcpy(unit,Tcl_GetStringResult(interp));
      valid_optic++;
      dvalue=atof(value_char);
      if (dvalue>0) { p_ast->px=dvalue; }
      if (strcmp(unit,"m")==0) { p_ast->px*=1.; }
      else if (strcmp(unit,"mm")==0) { p_ast->px*=1e-3; }
      else { p_ast->px*=1e-6;}
   }
   strcpy(keyname,"PIXSIZE2");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
   } else {
      sprintf(s,lignetclu,numbuf,keyname);Tcl_Eval(interp,s);strcpy(unit,Tcl_GetStringResult(interp));
      valid_optic++;
      dvalue=atof(value_char);
      if (dvalue>0) { p_ast->py=dvalue; }
      if (strcmp(unit,"m")==0) { p_ast->py*=1.; }
      else if (strcmp(unit,"mm")==0) { p_ast->py*=1e-3; }
      else { p_ast->py*=1e-6;}
   }
   strcpy(keyname,"RA");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
   } else {
      sprintf(s,lignetclu,numbuf,keyname);Tcl_Eval(interp,s);strcpy(unit,Tcl_GetStringResult(interp));
      valid_optic++;
      dvalue=atof(value_char);
      if (dvalue>0) { p_ast->ra0=dvalue; }
      if ((strcmp(unit,"deg")==0)||(strcmp(unit,"degrees")==0)) { p_ast->ra0*=(PI/180.); }
      else if (strcmp(unit,"h")==0) { p_ast->ra0*=(15.*(PI)/180.); }
      else { p_ast->ra0*=(PI/180.);}
      p_ast->crval1=p_ast->ra0;
      crval1found=YES;
   }
   strcpy(keyname,"DEC");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
   } else {
      sprintf(s,lignetclu,numbuf,keyname);Tcl_Eval(interp,s);strcpy(unit,Tcl_GetStringResult(interp));
      valid_optic++;
      dvalue=atof(value_char);
      if ((dvalue>=-90)&&(dvalue<=90)) { p_ast->dec0=dvalue; }
      if ((strcmp(unit,"deg")==0)||(strcmp(unit,"degrees")==0)) { p_ast->dec0*=(PI/180.); }
      else { p_ast->dec0*=(PI/180.);}
      p_ast->crval2=p_ast->dec0;
      crval2found=YES;
   }

   /* -- recherche des mots cles d'astrometrie '_cd' dans l'entete FITS --*/
   strcpy(keyname,"CD1_1");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype!=0) {
      valid_cd++;
      p_ast->cd11=atof(value_char)*(PI)/180.;
      strcpy(keyname,"CD1_2");
      sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
      if (datatype!=0) {
        valid_cd++;
	     p_ast->cd12=atof(value_char)*(PI)/180.;
      }
      strcpy(keyname,"CD2_1");
      sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
      if (datatype!=0) {
        valid_cd++;
	     p_ast->cd21=atof(value_char)*(PI)/180.;
      }
      strcpy(keyname,"CD2_2");
      sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
      if (datatype!=0) {
        valid_cd++;
	     p_ast->cd22=atof(value_char)*(PI)/180.;
      }
   }

   /* -- recherche des mots cles d'astrometrie '_crvp' dans l'entete FITS --*/
   strcpy(keyname,"CDELT1");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
   } else {
      sprintf(s,lignetclu,numbuf,keyname);Tcl_Eval(interp,s);strcpy(unit,Tcl_GetStringResult(interp));
      valid_crvp++;
      dvalue=atof(value_char);
      p_ast->cdelta1=dvalue;
      if (strcmp(unit,"deg/pixel")==0) { p_ast->cdelta1*=(PI/180.); }
      else { p_ast->cdelta1*=(PI/180.);}
   }
   strcpy(keyname,"CDELT2");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
   } else {
      sprintf(s,lignetclu,numbuf,keyname);Tcl_Eval(interp,s);strcpy(unit,Tcl_GetStringResult(interp));
      valid_crvp++;
      dvalue=atof(value_char);
      p_ast->cdelta2=dvalue;
      if (strcmp(unit,"deg/pixel")==0) { p_ast->cdelta2*=(PI/180.); }
      else { p_ast->cdelta2*=(PI/180.);}
   }
   strcpy(keyname,"CROTA2");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
   } else {
      sprintf(s,lignetclu,numbuf,keyname);Tcl_Eval(interp,s);strcpy(unit,Tcl_GetStringResult(interp));
      crota2found=YES;
      valid_crvp++;
      valid_optic++;
      dvalue=atof(value_char);
      p_ast->crota2=dvalue;
      if (strcmp(unit,"deg")==0) { p_ast->crota2*=(PI/180.); }
      else if (strcmp(unit,"radian")==0) { p_ast->crota2*=(1.); }
      else { p_ast->crota2*=(PI/180.);}
   }

   /* -- recherche des mots cles d'astrometrie '_crvp' '_cd' '_optic' dans l'entete FITS --*/
   strcpy(keyname,"CRPIX1");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
   } else {
      crpix1found=YES;
      valid_crvp++;
      valid_cd++;
      valid_optic++;
      p_ast->crpix1=atof(value_char);
   }
   strcpy(keyname,"CRPIX2");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
   } else {
      crpix2found=YES;
      valid_crvp++;
      valid_cd++;
      valid_optic++;
      p_ast->crpix2=atof(value_char);
   }
   strcpy(keyname,"CRVAL1");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
      p_ast->crval1=p_ast->ra0;
   } else {
      sprintf(s,lignetclu,numbuf,keyname);Tcl_Eval(interp,s);strcpy(unit,Tcl_GetStringResult(interp));
      valid_crvp++;
      valid_cd++;
      if (crval1found==NO) { valid_optic++; }
      dvalue=atof(value_char);
      if (dvalue>0) { p_ast->crval1=dvalue; }
      if ((strcmp(unit,"deg")==0)||(strcmp(unit,"degrees")==0)) { p_ast->crval1*=(PI/180.); }
      else if (strcmp(unit,"h")==0) { p_ast->crval1*=(15.*(PI)/180.); }
      else { p_ast->crval1*=(PI/180.);}
      if (dvalue<=0) {p_ast->crval1=p_ast->ra0;}
   }
   strcpy(keyname,"CRVAL2");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
      p_ast->crval2=p_ast->dec0;
   } else {
      sprintf(s,lignetclu,numbuf,keyname);Tcl_Eval(interp,s);strcpy(unit,Tcl_GetStringResult(interp));
      valid_crvp++;
      valid_cd++;
      if (crval2found==NO) { valid_optic++; }
      dvalue=atof(value_char);
      if ((dvalue>=-90)&&(dvalue<=90)) { p_ast->crval2=dvalue; }
      if ((strcmp(unit,"deg")==0)||(strcmp(unit,"degrees")==0)) { p_ast->crval2*=(PI/180.); }
      else { p_ast->crval2*=(PI/180.);}
   }

   /* --- complete les validites --- */
   if (crota2found==NO) {
      p_ast->crota2=0.;
      valid_optic++;
      valid_crvp++;
   }
   if ((crpix1found==NO)) {
      p_ast->crpix1=p_ast->naxis1/2.;
      valid_optic++;
   }
   if ((crpix2found==NO)) {
      p_ast->crpix2=p_ast->naxis2/2.;
      valid_optic++;
   }

   /* -- condition de validite --- */
   if ((valid_optic>=8)||(valid_cd>=8)||(valid_crvp>=7)) {
      v=YES;
   } else {
      v=NO;
   }
   *valid=v;

   /* --- transcodage --- */
   if ((valid_optic>=8)&&(valid_crvp<7)) {
      if ((p_ast->foclen!=0)&&(p_ast->px!=0)&&(p_ast->py!=0)) {
         p_ast->cdelta1=-2*atan(p_ast->px/2./p_ast->foclen);
         p_ast->cdelta2=2*atan(p_ast->py/2./p_ast->foclen);
      }
   }

   if (valid_cd>=8) {
      mc_util_cd2cdelt_old(p_ast->cd11,p_ast->cd12,p_ast->cd21,p_ast->cd22,&p_ast->cdelta1,&p_ast->cdelta2,&p_ast->crota2);
      return(0);
   }

   if ((valid_optic>=8)||(valid_crvp>=7)) {
      p_ast->cd11=p_ast->cdelta1*cos(p_ast->crota2);
      p_ast->cd12=fabs(p_ast->cdelta2)*p_ast->cdelta1/fabs(p_ast->cdelta1)*sin(p_ast->crota2);
      p_ast->cd21=-fabs(p_ast->cdelta1)*p_ast->cdelta2/fabs(p_ast->cdelta2)*sin(p_ast->crota2);
      p_ast->cd22=p_ast->cdelta2*cos(p_ast->crota2);
   }

   if ((p_ast->foclen==0.)&&(p_ast->px!=0.)&&(p_ast->py!=0.)&&(p_ast->cdelta1!=0.)&&(p_ast->cdelta2!=0.)) {
      p_ast->foclen=fabs(p_ast->px/2./tan(p_ast->cdelta1/2.));
      p_ast->foclen+=fabs(p_ast->py/2./tan(p_ast->cdelta2/2.));
      p_ast->foclen/=2.;
   }

   return(0);
}


int Cmd_mctcl_listradec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne une liste {{ra1 dec1} {ra2 dec2} ...} a partir d'un champ de    */
/* depart et d'une fonction de mosaique.                                    */
/****************************************************************************/
/* mc_listradec                                                             */
/*  Field Mosaic ComPix                                                     */
/*                                                                          */
/* Entrees :                 												             */
/*  Field : definition du champ de d�part (dimension et coordonnes).        */
/*  Mosaic : methode de mosaique                                            */
/*  ComPix : nombre de pixels communs entre deux images                     */
/*                                                                          */
/****************************************************************************/
{
   mc_ASTROM p;
   Tcl_DString dsptr;
   char s[524];
   int result,retour,code;
   double compix,ra,ra0,dec,dec0,x,x0,y,y0,shiftx,shifty,dx,dy;
   char **mosaics=NULL;
   int nbmosaics,method,nbfields=0,sens=1,k,jump=0;
   double xmin=0., xmax=0.,ymin=0.,ymax=0.;

   if(argc<=3) {
      sprintf(s,"Usage: %s Field Method ComPix", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	   return(result);
   } else {
      /* --- parametres du champ ---*/
      mctcl_listfield2mc_astrom(interp,argv[1],&p);
      /* --- definition de la mosaique ---*/
      code=Tcl_SplitList(interp,argv[2],&nbmosaics,&mosaics);
      strcpy(s,mosaics[0]);
      mc_strupr(s,s);
      method=LIBMC_MOSAIC_FREE;
      if (strcmp(s,"FREE")==0) { method=LIBMC_MOSAIC_FREE; nbfields=(int)(floor((nbmosaics-1)/2)); }
      if (strcmp(s,"ROLL")==0) { method=LIBMC_MOSAIC_ROLLRIGHT; if (nbmosaics>1) { nbfields=(int)(fabs(atof(mosaics[1])));} if (nbmosaics>2) { jump=(int)(fabs(atof(mosaics[2]))); } }
      if (strcmp(s,"NAXIS1")==0) { method=LIBMC_MOSAIC_NAXIS1; if (nbmosaics>1) { nbfields=(int)(fabs(atof(mosaics[1]))); sens=(int)mc_sgn(atof(mosaics[1])); } }
      if (strcmp(s,"NAXIS2")==0) { method=LIBMC_MOSAIC_NAXIS2; if (nbmosaics>1) { nbfields=(int)(fabs(atof(mosaics[1]))); sens=(int)mc_sgn(atof(mosaics[1])); } }
      if (strcmp(s,"RANDOM")==0) { method=LIBMC_MOSAIC_RANDOM; if (nbmosaics>1) { nbfields=(int)(fabs(atof(mosaics[1]))); } }
      /* --- recouvrement en pixels ---*/
	   result=TCL_OK;
      retour = Tcl_GetDouble(interp, argv[3],&compix);
      if(retour!=TCL_OK) return retour;
      /* ------- calculs ------*/
	   Tcl_DStringInit(&dsptr);
      x0=p.naxis1/2;
      y0=p.naxis2/2;
      mc_util_astrom_xy2radec(&p,x0,y0,&ra0,&dec0);
      x=x0;
      y=y0;
      shiftx=p.naxis1-compix;
      shifty=p.naxis2-compix;
      dx=0.;
      dy=0.;
      xmin=x0;
      xmax=x0;
      ymin=y0;
      ymax=y0;
      srand((unsigned) time(NULL));
      if (jump!=0) { nbfields*=2; }
      for (k=0;k<nbfields;k++) {
         if (method==LIBMC_MOSAIC_NAXIS1) { x=x0+1.*k*shiftx*sens; y=y0; }
         if (method==LIBMC_MOSAIC_NAXIS2) { y=y0+1.*k*shifty*sens; x=x0; }
         if (method==LIBMC_MOSAIC_FREE) { x=x+atof(mosaics[1+2*k]); y=y+atof(mosaics[2+2*k]); }
         x=x+dx; y=y+dy;
         mc_util_astrom_xy2radec(&p,x,y,&ra,&dec);
	      sprintf(s,"{%.12g %.12g %.12g %.12g} ",ra/(DR),dec/(DR),x,y);
         if (jump==0) {
	         Tcl_DStringAppend(&dsptr,s,-1);
         }
         if ((jump==1)&&(k%2==0)) {
	         Tcl_DStringAppend(&dsptr,s,-1);
         }
         if ((jump==2)&&((k+1)%2==0)) {
	         Tcl_DStringAppend(&dsptr,s,-1);
         }
         if (method==LIBMC_MOSAIC_ROLLRIGHT) {
            if (k==0) {
               dx=0.; dy=shifty;
            } else {
               if      ((dy>0.)&&(y>ymax)) { dx=shiftx; dy=0.; }
               else if ((dx>0.)&&(x>xmax)) { dx=0.; dy=-shifty; }
               else if ((dy<0.)&&(y<ymin)) { dx=-shiftx; dy=0.; }
               else if ((dx<0.)&&(x<xmin)) { dx=0.; dy=shifty; }
               if (x>xmax) {xmax=x;}
               if (y>ymax) {ymax=y;}
               /*
               if (x>xmax) {xmin=x;}
               if (y>ymax) {ymin=y;}
               */
               if (x<xmin) {xmin=x;}
               if (y<ymin) {ymin=y;}
            }
         }
         if (method==LIBMC_MOSAIC_RANDOM) {
            x=x0+compix*((rand()%10000)/10000.-.5);
            y=y0+compix*((rand()%10000)/10000.-.5);
         }
      }
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
      result=TCL_OK;
   }
   if (mosaics!=NULL) {
      Tcl_Free((char *) mosaics);
   }
   return result;

}

int Cmd_mctcl_sepangle(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Calcul l'angle de separation entre deux coordonnees.                     */
/****************************************************************************/
/* mc_sepangle                                                              */
/*  Ra1 Dec1 Ra2 Dec2 ?Units?                                               */
/*                                                                          */
/* Si Units=D alors les entrees et les sorties sont en degres.              */
/****************************************************************************/
{
   char s[524];
   int result,retour;
   double ra1,dec1,ra2,dec2,dist,posangle;
   char units[50];

   if(argc<=4) {
      sprintf(s,"Usage: %s Ra1 Dec1 Ra2 Dec2 ?Units?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	   return(result);
   } else {
     retour = Tcl_GetDouble(interp, argv[1], &ra1);
     if(retour!=TCL_OK) return retour;
     retour = Tcl_GetDouble(interp, argv[2], &dec1);
     if(retour!=TCL_OK) return retour;
     retour = Tcl_GetDouble(interp, argv[3], &ra2);
     if(retour!=TCL_OK) return retour;
     retour = Tcl_GetDouble(interp, argv[4], &dec2);
     if(retour!=TCL_OK) return retour;
     if (argc==6) {
        strcpy(units,argv[5]);
        mc_strupr(units,units);
     } else {
        strcpy(units,"D");
     }
     if (units[0]=='D') {
        ra1*=(DR);
        dec1*=(DR);
        ra2*=(DR);
        dec2*=(DR);
     }
     mc_sepangle(ra1,ra2,dec1,dec2,&dist,&posangle);
     if (units[0]=='D') {
        dist/=(DR);
        posangle/=(DR);
     }
     sprintf(s,"%12f %12f",dist,posangle);
     Tcl_SetResult(interp,s,TCL_VOLATILE);
     result=TCL_OK;
   }
   return result;

}

int Cmd_mctcl_angle2deg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit un type Angle en degres                                        */
/****************************************************************************/
/* mc_angle2deg                                                             */
/*  Angle                                                                   */
/****************************************************************************/
{
   char s[524];
   int result;
   double angle;

   if(argc<=1) {
      sprintf(s,"Usage: %s Angle", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	  /* --- decode l'angle ---*/
      mctcl_decode_angle(interp,argv[1],&angle);
      sprintf(s,"%12f",angle);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_angle2rad(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit un type Angle en radians                                       */
/****************************************************************************/
/* mc_angle2rad                                                             */
/*  Angle                                                                   */
/****************************************************************************/
{
   char s[524];
   int result;
   double angle;

   if(argc<=1) {
      sprintf(s,"Usage: %s Angle", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	  /* --- decode l'angle ---*/
      mctcl_decode_angle(interp,argv[1],&angle);
      sprintf(s,"%12f",angle*(DR));
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_angle2dms(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit un type Angle en dms                                           */
/****************************************************************************/
/* mc_angle2dms                                                             */
/*  Angle ?limit? ?nozero|zero? ?subsecdigits? ?auto|+? ?list|string?       */
/****************************************************************************/
{
   char s[524],form[524],charsigne[2];
   int result,format;
   double angle,ss,limit=360.;
   int dd,mm;
	int subsecdigits=2,zero=0,plus=0,s1,s2;
	int ndig;
	char charndig[10];
   if(argc<=1) {
      sprintf(s,"Usage: %s Angle ?limit? ?nozero|zero? ?subsecdigits? ?auto|+? ?list|string?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	  /* --- decode l'angle ---*/
      mctcl_decode_angle(interp,argv[1],&angle);
      angle=fmod(angle,360.);
      angle=fmod(angle+360.,360.);
		/* --- limit ---*/
      if (argc>=3) {
		   strcpy(s,argv[2]);
		   mc_strupr(s,s);
         if ((s[0]=='D')) {
		      limit=90.;
         } else {
            limit=atof(s);
			}
			if ((limit>0.)&&(limit<=180.)) {
			   if ((angle>limit)&&(angle<=180.)) { angle=limit; }
			   if ((angle>180)&&(angle<(360.-limit))) { angle=-limit; }
			   if ((angle>=(360.-limit))) { angle-=360.; }
			}
      }
		/* --- nozero|zero ---*/
      if (argc>=4) {
		   strcpy(s,argv[3]);
		   mc_strupr(s,s);
         if (strcmp(s,"ZERO")==0) {
				zero=1;
			}
		}
		/* --- subsecdigits ---*/
      if (argc>=5) {
			subsecdigits=(int)atoi(argv[4]);
		}
		/* --- auto|+ ---*/
      if (argc>=6) {
		   strcpy(s,argv[5]);
		   mc_strupr(s,s);
         if (strcmp(s,"+")==0) {
				plus=1;
			}
		}
		/* --- output format ---*/
		format=0;
      if (argc>=7) {
		   strcpy(s,argv[6]);
		   mc_strupr(s,s);
			if (strcmp(s,"STRING")==0) {
				format=1;
			}
		}
		/* --- mise en forme ---*/
		mc_deg2d_m_s(angle,charsigne,&dd,&mm,&ss);
      if (argc<=3) {
			if (format==0) {
            sprintf(s,"%s%d %d %f",charsigne,dd,mm,ss);
			} else {
            sprintf(s,"%s%dd%dm%fs",charsigne,dd,mm,ss);
			}
		} else {
			s1=(int)floor(ss);
			if (subsecdigits<0) {subsecdigits=0;}
			if (subsecdigits>10) {subsecdigits=10;}
			s2=(int)floor(pow(10,subsecdigits)*(ss-(double)s1));
			if ((plus==0)&&(strcmp(charsigne,"+")==0)) {strcpy(charsigne,"");}
			if (zero==1) {
				ndig=1+(int)floor(log(limit)/log(10));
				sprintf(charndig,"%%0%dd",ndig);
				if (format==0) {
               if (subsecdigits==0) {
				      sprintf(form,"%s%s %s %s","%s",charndig,"%02d","%02d");
                  sprintf(s,form,charsigne,dd,mm,s1);
               } else {
				      sprintf(form,"%s%s %s %s.%s%d%s","%s",charndig,"%02d","%02d","%0",subsecdigits,"d");
                  sprintf(s,form,charsigne,dd,mm,s1,s2);
               }
				} else {
               if (subsecdigits==0) {
				      sprintf(form,"%s%sd%sm%ss","%s",charndig,"%02d","%02d");
                  sprintf(s,form,charsigne,dd,mm,s1);
               } else {
				      sprintf(form,"%s%sd%sm%ss%s%d%s","%s",charndig,"%02d","%02d","%0",subsecdigits,"d");
                  sprintf(s,form,charsigne,dd,mm,s1,s2);
               }
				}
			} else {
            /*
				if (format==0) {
				   sprintf(s,"%s%d %d %f",charsigne,dd,mm,ss);
				} else {
				   sprintf(form,"%s%sd%sm%ss%s%d%s","%s","%d","%d","%d","%0",subsecdigits,"d");
               sprintf(s,form,charsigne,dd,mm,s1,s2);
				}
            */
				strcpy(charndig,"%d");
				if (format==0) {
               if (subsecdigits==0) {
				      sprintf(form,"%s%s %s %s","%s",charndig,"%d","%d");
                  sprintf(s,form,charsigne,dd,mm,s1);
               } else {
				      sprintf(form,"%s%s %s %s.%s%d%s","%s",charndig,"%d","%d","%0",subsecdigits,"d");
                  sprintf(s,form,charsigne,dd,mm,s1,s2);
               }
				} else {
               if (subsecdigits==0) {
				      sprintf(form,"%s%sd%sm%ss","%s",charndig,"%d","%d");
                  sprintf(s,form,charsigne,dd,mm,s1);
               } else {
				      sprintf(form,"%s%sd%sm%ss%s%d%s","%s",charndig,"%d","%d","%0",subsecdigits,"d");
                  sprintf(s,form,charsigne,dd,mm,s1,s2);
               }
				}
			}
		}
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_angle2hms(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit un type Angle en hms                                           */
/****************************************************************************/
/* mc_angle2hms                                                             */
/*  Angle ?limit? ?nozero|zero? ?subsecdigits? ?list|string?                */
/****************************************************************************/
{
   char s[524],form[524],charsigne[2];
   int result,format=0;
   double angle,ss,limit=360.;
   int hh,mm;
	int subsecdigits=2,zero=0,plus=0,s1,s2;
	int ndig;
	char charndig[10];

   if(argc<=1) {
      sprintf(s,"Usage: %s Angle ?limit? ?nozero|zero? ?subsecdigits? ?auto|+? ?list|string?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	  /* --- decode l'angle ---*/
      mctcl_decode_angle(interp,argv[1],&angle);
      angle=fmod(angle,360.);
      angle=fmod(angle+360.,360.);
      if (argc>=3) {
         limit=atof(argv[2]);
			if ((limit>0.)&&(limit<=180.)) {
			   if ((angle>limit)&&(angle<=180.)) { angle=limit; }
			   if ((angle>180)&&(angle<(360.-limit))) { angle=-limit; }
			   if ((angle>=(360.-limit))) { angle-=360.; }
			}
      }
		if (angle<0) {
			strcpy(charsigne,"-");
			angle=fabs(angle);
		} else {
			strcpy(charsigne,"+");
		}
		/* --- nozero|zero ---*/
      if (argc>=4) {
		   strcpy(s,argv[3]);
		   mc_strupr(s,s);
         if (strcmp(s,"ZERO")==0) {
				zero=1;
			}
		}
		/* --- subsecdigits ---*/
      if (argc>=5) {
			subsecdigits=(int)atoi(argv[4]);
		}
		/* --- auto|+ ---*/
      if (argc>=6) {
		   strcpy(s,argv[5]);
		   mc_strupr(s,s);
         if (strcmp(s,"+")==0) {
				plus=1;
			}
		}
		/* --- output format ---*/
		format=0;
      if (argc>=7) {
		   strcpy(s,argv[6]);
		   mc_strupr(s,s);
			if (strcmp(s,"STRING")==0) {
				format=1;
			}
		}
		/* --- mise en forme ---*/
		mc_deg2h_m_s(angle,&hh,&mm,&ss);
      if (argc<=3) {
			if (format==0) {
            sprintf(s,"%d %d %f",hh,mm,ss);
			} else {
            sprintf(s,"%dh%dm%fs",hh,mm,ss);
			}
		} else {
			s1=(int)floor(ss);
			if (subsecdigits<0) {subsecdigits=0;}
			if (subsecdigits>10) {subsecdigits=10;}
			s2=(int)floor(pow(10,subsecdigits)*(ss-(double)s1));
			if ((plus==0)&&(strcmp(charsigne,"+")==0)) {strcpy(charsigne,"");}
			if (zero==1) {
				ndig=1+(int)floor(log(limit/15)/log(10));
				sprintf(charndig,"%%0%dd",ndig);
				if (format==0) {
               if (subsecdigits==0) {
				      sprintf(form,"%s%s %s %s","%s",charndig,"%02d","%02d");
                  sprintf(s,form,charsigne,hh,mm,s1);
               } else {
				      sprintf(form,"%s%s %s %s.%s%d%s","%s",charndig,"%02d","%02d","%0",subsecdigits,"d");
                  sprintf(s,form,charsigne,hh,mm,s1,s2);
               }
				} else {
               if (subsecdigits==0) {
				      sprintf(form,"%s%sh%sm%ss","%s",charndig,"%02d","%02d");
                  sprintf(s,form,charsigne,hh,mm,s1);
               } else {
				      sprintf(form,"%s%sh%sm%ss%s%d%s","%s",charndig,"%02d","%02d","%0",subsecdigits,"d");
                  sprintf(s,form,charsigne,hh,mm,s1,s2);
               }
				}
			} else {
				strcpy(charndig,"%d");
				if (format==0) {
               if (subsecdigits==0) {
				      sprintf(form,"%s%s %s %s","%s",charndig,"%d","%d");
                  sprintf(s,form,charsigne,hh,mm,s1);
               } else {
				      sprintf(form,"%s%s %s %s.%s%d%s","%s",charndig,"%d","%d","%0",subsecdigits,"d");
                  sprintf(s,form,charsigne,hh,mm,s1,s2);
               }
				} else {
               if (subsecdigits==0) {
				      sprintf(form,"%s%sh%sm%ss","%s",charndig,"%d","%d");
                  sprintf(s,form,charsigne,hh,mm,s1);
               } else {
				      sprintf(form,"%s%sh%sm%ss%s%d%s","%s",charndig,"%d","%d","%0",subsecdigits,"d");
                  sprintf(s,form,charsigne,hh,mm,s1,s2);
               }
				}
			}
		}
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_anglescomp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Calcul sur les Angles                                                    */
/****************************************************************************/
/* mc_anglescomp                                                            */
/*  Angle1 Operande Angle2                                                  */
/****************************************************************************/
{
   char s[524];
   int result,op;
   double angle1,angle2,angle12,a;

   if(argc<4) {
      sprintf(s,"Usage: %s Angle1 Operand Angle2", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	   /* --- decode l'angle 1 ---*/
      mctcl_decode_angle(interp,argv[1],&angle1);
	   /* --- decode l'operande ---*/
		strcpy(s,argv[2]);
		if (strcmp(s,"*")==0) {op=2;}
		else if (strcmp(s,"/")==0) {op=-2;}
		else if (strcmp(s,"-")==0) {op=-1;}
		else if (strcmp(s,"modulo")==0) {op=3;}
		else if (strcmp(s,"+")==0) {op=1;}
		else {
         strcpy(s,"Operand should be +|-|*|/|modulo");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         result = TCL_ERROR;
			return result;
		}
		angle12=0.;
      if (fabs(op)<=1.) {
	      /* --- decode l'angle 2 ---*/
         mctcl_decode_angle(interp,argv[3],&angle2);
			if (op>0) {
			   angle12=angle1+angle2;
			} else {
			   angle12=angle1-angle2;
			}
		} else {
	      /* --- decode la constante 2 ---*/
         a=atof(argv[3]);
			if (op==2) {
			   angle12=angle1*a;
			} else if (op==-2) {
			   angle12=angle1/a;
			} else {
			   angle12=fmod(angle1,a);
			}
		}
		sprintf(s,"%12f",angle12);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
	}
	return result;
}

int Cmd_mctcl_angle2lx200ra(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit un type Angle en RA LX200                                      */
/****************************************************************************/
/* mc_angle2lx200ra                                                         */
/*  Angle                                                                   */
/*  -format long|short   (long par defaut)                                  */
/****************************************************************************/
{
   char s[524];
   int result;
   double angle,ss;
   int hh,mm;

   if(argc<=1) {
      sprintf(s,"Usage: %s Angle ?-format long|short?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	  /* --- decode l'angle ---*/
      mctcl_decode_angle(interp,argv[1],&angle);
      angle=fmod(angle,360.);
      angle=fmod(angle+360.,360.);
	   mc_deg2h_m_s(angle,&hh,&mm,&ss);
	  /* --- selectionne le format de sortie ---*/
      if (argc>=4) {
         if ((strcmp(argv[2],"-format")==0)&&(strcmp(argv[3],"short")==0)) {
				ss=ss/6.;
				if (ss>9) { ss=9.; }
            sprintf(s,"%02d:%02d.%1d",(int)hh,(int)mm,(int)floor(ss));
			} else {
            sprintf(s,"%02d:%02d:%02d",(int)hh,(int)mm,(int)floor(ss));
			}
		} else {
         sprintf(s,"%02d:%02d:%02d",(int)hh,(int)mm,(int)floor(ss));
		}
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_angle2lx200dec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit un type Angle en DEC LX200                                     */
/****************************************************************************/
/* mc_angle2lx200dec                                                        */
/*  Angle                                                                   */
/****************************************************************************/
{
   char s[524],charsigne[2];
   int result;
   double angle,ss;
   int dd,mm;
   char signe;
   unsigned char separat;

   if(argc<=1) {
      sprintf(s,"Usage: %s Angle ?-format long|short?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	  /* --- decode la date ---*/
      mctcl_decode_angle(interp,argv[1],&angle);
      angle=fmod(angle,360.);
      angle=fmod(angle+360.,360.);
      if ((angle>90.)&&(angle<=180.)) { angle=90.; }
      if ((angle>180.)&&(angle<270.)) { angle=-90.; }
      if (angle>=270.) { angle-=360.; }
      if (angle<0) { signe='-'; angle=fabs(angle); } else { signe='+';}
	   mc_deg2d_m_s(angle,charsigne,&dd,&mm,&ss);
      separat=223;
	  /* --- selectionne le format de sortie ---*/
      if (argc>=4) {
         if ((strcmp(argv[2],"-format")==0)&&(strcmp(argv[3],"short")==0)) {
				if (ss>30) { mm+=1; }
				if (mm>59) { dd+=1; }
            sprintf(s,"%c%02d%c%02d",signe,(int)dd,separat,(int)mm);
			} else {
            sprintf(s,"%c%02d%c%02d:%02d",signe,(int)dd,separat,(int)mm,(int)floor(ss));
			}
		} else {
         sprintf(s,"%c%02d%c%02d:%02d",signe,(int)dd,separat,(int)mm,(int)floor(ss));
		}
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}

int Cmd_mctcl_angles2ultima2000(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit un type Angle en RADEC Ultima2000                              */
/****************************************************************************/
/* mc_angles2ultima2000                                                     */
/*  Angle Angle                                                             */
/****************************************************************************/
{
   char s[524],aa[5];
   int result,a[4];
   double angle,x;
   int k,kk;

   if(argc<=2) {
      sprintf(s,"Usage: %s Angle_ra Angle_dec", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	  /* --- decode l'angle ---*/
      result = TCL_OK;
      for (kk=1;kk<=2;kk++) {
         mctcl_decode_angle(interp,argv[kk],&angle);
         angle=fmod(angle,360.);
         angle=fmod(angle+360.,360.);
         x=angle*65536./360.;
         a[0]=(int)floor(x/4096.);
         x=x-4096*(double)a[0];
         a[1]=(int)floor(x/256.);
         x=x-256*(double)a[1];
         a[2]=(int)floor(x/16.);
         x=x-16*(double)a[2];
         a[3]=(int)floor(x);
         for (k=0;k<4;k++) {
            if      (a[k]== 0) { aa[k]='0'; }
            else if (a[k]== 1) { aa[k]='1'; }
            else if (a[k]== 2) { aa[k]='2'; }
            else if (a[k]== 3) { aa[k]='3'; }
            else if (a[k]== 4) { aa[k]='4'; }
            else if (a[k]== 5) { aa[k]='5'; }
            else if (a[k]== 6) { aa[k]='6'; }
            else if (a[k]== 7) { aa[k]='7'; }
            else if (a[k]== 8) { aa[k]='8'; }
            else if (a[k]== 9) { aa[k]='9'; }
            else if (a[k]==10) { aa[k]='A'; }
            else if (a[k]==11) { aa[k]='B'; }
            else if (a[k]==12) { aa[k]='C'; }
            else if (a[k]==13) { aa[k]='D'; }
            else if (a[k]==14) { aa[k]='E'; }
            else if (a[k]==15) { aa[k]='F'; }
         }
         aa[4]='\0';
         s[4]=',';
         s[9]='\0';
         for (k=0;k<4;k++) {
            if (kk==1) {
               s[k]=aa[k];
            } else {
               s[k+5]=aa[k];
            }
         }
      }
   }
   Tcl_SetResult(interp,s,TCL_VOLATILE);
   return(result);
}

int Cmd_mctcl_ultima20002angles(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Convertit RADEC Ultima2000 en un type Angle                              */
/****************************************************************************/
/* mc_angles2ultima2000                                                     */
/*  string                                                                  */
/****************************************************************************/
{
   char s[524],ultima[15],aa[5];
   int result,a[4];
   double x,ra=0.,dec=0.;
   int k,kk;

   if(argc<=1) {
      sprintf(s,"Usage: %s Ultima200_string", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      strcpy(ultima,argv[1]);
      if ((int)strlen(ultima)<9) {
         sprintf(s,"Ultima2000_string %s non long enough",ultima);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
  	      /* --- decode l'angle ---*/
         for (kk=1;kk<=2;kk++) {
           if (kk==1) {
              aa[0]=ultima[0];
              aa[1]=ultima[1];
              aa[2]=ultima[2];
              aa[3]=ultima[3];
           } else {
              aa[0]=ultima[5];
              aa[1]=ultima[6];
              aa[2]=ultima[7];
              aa[3]=ultima[8];
           }
           for (k=0;k<4;k++) {
              if      (aa[k]=='0') { a[k]=0; }
              else if (aa[k]=='1') { a[k]=1; }
              else if (aa[k]=='2') { a[k]=2; }
              else if (aa[k]=='3') { a[k]=3; }
              else if (aa[k]=='4') { a[k]=4; }
              else if (aa[k]=='5') { a[k]=5; }
              else if (aa[k]=='6') { a[k]=6; }
              else if (aa[k]=='7') { a[k]=7; }
              else if (aa[k]=='8') { a[k]=8; }
              else if (aa[k]=='9') { a[k]=9; }
              else if (aa[k]=='A') { a[k]=10; }
              else if (aa[k]=='B') { a[k]=11; }
              else if (aa[k]=='C') { a[k]=12; }
              else if (aa[k]=='D') { a[k]=13; }
              else if (aa[k]=='E') { a[k]=14; }
              else if (aa[k]=='F') { a[k]=15; }
           }
           x=4096*a[0]+256*a[1]+16*a[2]+a[3];
           if (kk==1) {
              ra=x/65536*360.;
           } else {
              dec=x/65536*360.;
              if (dec>180) { dec=dec-360.; }
           }
         }
      }
      sprintf(s,"%12f %12f",ra,dec);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return(result);
}


int Cmd_mctcl_anglesep(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Calcul l'angle de separation entre deux coordonnees.                     */
/****************************************************************************/
/* mc_anglesep                                                              */
/*  Listangles ?Units?                                                      */
/*                                                                          */
/* Si Units=D alors les entrees et les sorties sont en degres.              */
/* Si Units=R alors les entrees et les sorties sont en radians.             */
/****************************************************************************/
{
   char s[524];
   int result,argcc,code;
   char **argvv=NULL;
   double ra1=0.,dec1=0.,ra2=0.,dec2=0.,dist,posangle;
   char units[50];

   if(argc<=1) {
      sprintf(s,"Usage: %s ListAngles ?Units?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	   return(result);
   } else {
      code=Tcl_SplitList(interp,argv[1],&argcc,&argvv);
      if (argcc>=1) {mctcl_decode_angle(interp,argvv[0],&ra1);}
      if (argcc>=2) {mctcl_decode_angle(interp,argvv[1],&dec1);}
      if (argcc>=3) {mctcl_decode_angle(interp,argvv[2],&ra2);}
      if (argcc>=4) {mctcl_decode_angle(interp,argvv[3],&dec2);}
      mc_sepangle(ra1*(DR),ra2*(DR),dec1*(DR),dec2*(DR),&dist,&posangle);
      if (argc>=3) {
         strcpy(units,argv[2]);
         mc_strupr(units,units);
      } else {
         strcpy(units,"D");
      }
      if (units[0]=='D') {
         dist/=(DR);
         posangle/=(DR);
      }
      sprintf(s,"%.12g %.12g",dist,posangle);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result=TCL_OK;
   }
   if (argvv!=NULL) { Tcl_Free((char *) argvv); }
   return result;
}

int mctcl_decode_angle(Tcl_Interp *interp, char *argv0,double *angledeg)
/****************************************************************************/
/* Decode automatiquement des angles entree sous des formats differents.	 */
/* Retourne des degres.                                                     */
/****************************************************************************/
/* 45 : 45 degres decimaux                                                  */
/* 45d : 45 degres decimaux                                                 */
/* 45.5d : 45 degres et 30 arcmin                                           */
/* 45d38m : 45 degres et 38 arcmin                                          */
/* 45d38  : 45 degres et 38 arcmin                                          */
/* 45d56.50m : 45 degres 56 arcmin et 30 arcsec                             */
/* 45d56m30s : 45 degres 56 arcmin et 30 arcsec                             */
/* 45d56m30s99 : 45 degres 56 arcmin 30 arcsec et 99 centiemes d'arcsec     */
/* 5h38 : 5 heures 38 minutes                                               */
/* 1.567843r : 1.567843 radians                                             */
/* -45 38 56 : -45 degres 38 arcmin 56 arcsec                               */
/* 4 32 13.5 h : 4 heures 3� min 13.5 sec                                   */
/* 1.567843 r : 1.567843 radians                                            */
/****************************************************************************/
{
   int code;
   char **argvv=NULL;
   int argcc,khd,kd,kh,km,ks,k,kk,ksigne,klen,kr;
   double angle,hd=0.,m=0.,s=0.,signe;
   char text[50],chiffres[50],car;

   code=Tcl_SplitList(interp,argv0,&argcc,&argvv);
   if (code==TCL_OK) {
      angle=0.;
      signe=1.;
      ksigne=0;
      kh=0;
      kd=0;
      km=0;
      ks=0;
      khd=0;
      kr=0;
      if (argcc==1) {
		   /* Un seul element dans la liste */
		   strcpy(text,argvv[0]);
		   mc_strupr(text,text);
         klen=(int)strlen(text);
         strcpy(chiffres,"");
         for (kk=0,k=0;k<klen;k++) {
            car=text[k];
            if ((car=='-')&&(ksigne==0)) { signe=-1.; ksigne=1; }
            if (((car<'0')||(car>'9'))&&(car!='E')&&(car!='.')&&(car!='-')&&(car!='+')) {
               if (kk!=0) {
                  if ((car=='R')&&(kh==0)&&(kd==0)) { hd=fabs(atof(chiffres)); kr=1; kk=0; break; }
                  else if ((car=='H')&&(kh==0)&&(kd==0)) { hd=fabs(atof(chiffres)); kh=1; kk=0; }
                  else if ((kh==0)&&(kd==0)) { hd=fabs(atof(chiffres)); kd=1; kk=0; }
                  else if (((kh==1)||(kd==1))&&(km==0)) { m=fabs(atof(chiffres)); hd=floor(hd); km=1; kk=0; }
                  else if (((kh==1)||(kd==1))&&(km==1)&&(ks==0)) { s=fabs(atof(chiffres)); m=floor(m); ks=1; kk=0; }
               }
               strcpy(chiffres,"");
               kk=0;
            } else {
               chiffres[kk]=text[k];
               kk++;
               chiffres[kk]='\0';
            }
         }
         if (kk!=0) {
            if ((kh==0)&&(kd==0)&&(kr==0)) {
               kd=1;
               hd=fabs(atof(chiffres));
            }
            else if (((kh==1)||(kd==1))&&(km==0)) { m=fabs(atof(chiffres)); hd=floor(hd); km=1; kk=0; }
            else if (((kh==1)||(kd==1))&&(km==1)&&(ks==0)) { s=fabs(atof(chiffres)); m=floor(m); ks=1; kk=0; }
            else if (((kh==1)||(kd==1))&&(km==1)&&(ks==1)) {
               sprintf(text,".%s",chiffres);
               s+=fabs(atof(text)); m=floor(m); ks=1; kk=0;
            }
         }
      } else {
		   /* Plusieurs elements dans la liste */
         for (k=1;k<=argcc;k++) {
            strcpy(text,argvv[k-1]);
   		   mc_strupr(text,text);
            kd=1;
            if (text[0]=='H') { kh=1; kd=0; }
            else if (text[0]=='R') { kr=1; m=0.; s=0.; break; }
 	         else if (khd==0) { hd=atof(argvv[k-1]); if (hd<0) {signe=-1.;} else { signe=1.;} hd=fabs(hd); khd=1; }
 	         else if ((khd==1)&&(km==0)) { m=fabs(atof(argvv[k-1])); hd=floor(hd); km=1; }
 	         else if ((khd==1)&&(km==1)&&(ks==0)) { s=fabs(atof(argvv[k-1])); m=floor(m); ks=1; }
         }
      }
      angle=hd+(s/60.+m)/60.;
      angle*=signe;
      if (kh==1) { angle*=15.; }
      else if (kr==1) { angle/=(DR); }
      *angledeg=angle;
   }
   if (argvv!=NULL) { Tcl_Free((char *) argvv); }
   return(TCL_OK);
}

int Cmd_mctcl_precessradec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Effectue la correction de precession pour changer equinoxe.              */
/****************************************************************************/
/* Entrees :                 		     					                */
/* ListRaDec                 												*/
/* Date_from                 												*/
/* Date_to                 												    */
/*																			*/
/* Sorties :																*/
/* ListRaDec en degres.                 									*/
/****************************************************************************/
   double jjfrom=0.,jjto=0.,asd2=0.,dec2=0.,radeg,decdeg,pradeg,pdecdeg;
   int result=TCL_ERROR;
   char s[100];
   char **argvv=NULL;
   int argcc;

   if(argc<4) {
      sprintf(s,"Usage: %s ListRaDec Date_from Date_to ?ProperMotions_ListRaDec?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode les dates ---*/
      mctcl_decode_date(interp,argv[2],&jjfrom);
      mctcl_decode_date(interp,argv[3],&jjto);
      /*--- Calcul des coordonnees Ra,Dec */
      if (Tcl_SplitList(interp,argv[1],&argcc,&argvv)==TCL_OK) {
		 if (argcc>=2) {
            mctcl_decode_angle(interp,argvv[0],&radeg);
            mctcl_decode_angle(interp,argvv[1],&decdeg);
            Tcl_Free((char *) argvv);
			pradeg=0.;
			pdecdeg=0.;
			if (argc>=5) {
               if (Tcl_SplitList(interp,argv[4],&argcc,&argvv)==TCL_OK) {
		          if (argcc>=2) {
                     mctcl_decode_angle(interp,argvv[0],&pradeg);
                     mctcl_decode_angle(interp,argvv[1],&pdecdeg);
				  }
                  Tcl_Free((char *) argvv);
               }
			}
			/* --- calcul de mouvement propre ---*/
			radeg+=(jjto-jjfrom)/365.25*pradeg;
			decdeg+=(jjto-jjfrom)/365.25*pdecdeg;
            /* --- calcul de la precession ---*/
            mc_precad(jjfrom,radeg*DR,decdeg*DR,jjto,&asd2,&dec2);
            /* --- sortie des r�sultats ---*/
	        sprintf(s,"%12f %12f",asd2/(DR),dec2/(DR));
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_OK;
         } else {
            Tcl_Free((char *) argvv);
            sprintf(s,"Usage: %s ListRaDec Date_from Date_to ?ProperMotions_ListRaDec?", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_ERROR;
		 }
	  }
   }
   return result;
}

int Cmd_mctcl_nutationradec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Effectue la correction de nutation.                                      */
/****************************************************************************/
/* Entrees :                 												*/
/* ListRaDec                 												*/
/* Date_from                 												*/
/*																			*/
/* Sorties :																*/
/* ListRaDec en degres.                 									*/
/****************************************************************************/
   double jjfrom=0.,asd2=0.,dec2=0.,radeg,decdeg;
   int result=TCL_ERROR;
   char s[100];
   char **argvv=NULL;
   int argcc,k,sens=1;

   if(argc<3) {
      sprintf(s,"Usage: %s ListRaDec Date ?-reverse?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode les dates ---*/
      mctcl_decode_date(interp,argv[2],&jjfrom);
      /*--- decode les arguments optionels ---*/
      for (k=3;k<argc;k++) {
         if (strcmp(argv[k],"-reverse")==0) { sens=-1; }
      }
      /*--- Calcul des coordonnees Ra,Dec */
      if (Tcl_SplitList(interp,argv[1],&argcc,&argvv)==TCL_OK) {
		 if (argcc>=2) {
            mctcl_decode_angle(interp,argvv[0],&radeg);
            mctcl_decode_angle(interp,argvv[1],&decdeg);
            Tcl_Free((char *) argvv);
            /* --- calcul de la nutation ---*/
            mc_nutradec(jjfrom,radeg*DR,decdeg*DR,&asd2,&dec2,sens);
            /* --- sortie des r�sultats ---*/
	        sprintf(s,"%12f %12f",asd2/(DR),dec2/(DR));
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_OK;
         } else {
            Tcl_Free((char *) argvv);
            sprintf(s,"Usage: %s ListRaDec Date ?-reverse?", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_ERROR;
		 }
	  }
   }
   return result;
}

int Cmd_mctcl_aberrationradec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Effectue une des corrections d'abberration.                              */
/****************************************************************************/
/* Entrees :                 												*/
/* annual|diurnal|eterms                                                    */
/* ListRaDec                 												*/
/* Date_from                 												*/
/*																			*/
/* Sorties :																*/
/* ListRaDec en degres.                 									*/
/****************************************************************************/
   double jjfrom=0.,asd2=0.,dec2=0.,radeg,decdeg;
   int result=TCL_ERROR;
   char s[100];
   char **argvv=NULL;
   int argcc,choix=0,k,sens=1;
   double longi=0.,rhocosphip=0.,rhosinphip=0.;

   if(argc<4) {
      sprintf(s,"Usage: %s annual|diurnal|eterms ListRaDec Date ?Home? ?-reverse?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	   /* --- decode le type d'aberration ---*/
	   if (strcmp(argv[1],"annual")==0) { choix=0;}
	   if (strcmp(argv[1],"diurnal")==0) { choix=1;}
	   if (strcmp(argv[1],"eterms")==0) { choix=2;}
      /* --- decode les dates ---*/
      mctcl_decode_date(interp,argv[3],&jjfrom);
      /* --- decode le Home ---*/
	  /* mc_aberrationradec diurnal {0h 0d} 2000-01-12T18:00 {gps 2 E 43 148} */
	  if (choix==1) {
		  if (argc>=5) {
             mctcl_decode_topo(interp,argv[4],&longi,&rhocosphip,&rhosinphip);
          }
	  }
      /*--- decode les arguments optionels ---*/
      for (k=4;k<argc;k++) {
         if (strcmp(argv[k],"-reverse")==0) { sens=-1; }
      }
      /*--- Calcul des coordonnees Ra,Dec */
      if (Tcl_SplitList(interp,argv[2],&argcc,&argvv)==TCL_OK) {
		 if (argcc>=2) {
            mctcl_decode_angle(interp,argvv[0],&radeg);
            mctcl_decode_angle(interp,argvv[1],&decdeg);
            Tcl_Free((char *) argvv);
			if (choix==0) {
               /* --- calcul de l'aberration annuelle ---*/
               mc_aberration_annuelle(jjfrom,radeg*DR,decdeg*DR,&asd2,&dec2,sens);
			}
			if (choix==1) {
               /* --- calcul de l'aberration diurne ---*/
               mc_aberration_diurne(jjfrom,radeg*DR,decdeg*DR,longi,rhocosphip,rhosinphip,&asd2,&dec2,sens);
			}
			if (choix==2) {
               /* --- calcul de l'aberration eterms ---*/
               mc_aberration_eterms(jjfrom,radeg*DR,decdeg*DR,&asd2,&dec2,sens);
			}
            /* --- sortie des r�sultats ---*/
	        sprintf(s,"%12f %12f",asd2/(DR),dec2/(DR));
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_OK;
         } else {
            Tcl_Free((char *) argvv);
            sprintf(s,"Usage: %s annual|diurnal|eterms ListRaDec Date ?Home? ?-reverse?", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_ERROR;
		 }
	  }
   }
   return result;
}

int Cmd_mctcl_radec2galactic(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Conversion Ra,Dec vers le systeme de coordonnees galactiques.            */
/****************************************************************************/
/* Entrees :                 		     					                         */
/* ListRaDec                 												             */
/* Equinox                              												 */
/*                                                                          */
/* Sorties :																                */
/* ListLonLat en degres.                									          */
/****************************************************************************/
   double jjfrom=0.,jjto,asd2=0.,dec2=0.,radeg,decdeg,lon,lat;
   int result=TCL_ERROR;
   char s[100];
   char **argvv=NULL;
   int argcc;

   if(argc<3) {
      sprintf(s,"Usage: %s ListRaDec Equinox", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode la date de l'equinoxe ---*/
      mctcl_decode_date(interp,argv[2],&jjfrom);
      jjto=J2000;
      /*--- Calcul des coordonnees Ra,Dec */
      if (Tcl_SplitList(interp,argv[1],&argcc,&argvv)==TCL_OK) {
		   if (argcc>=2) {
            mctcl_decode_angle(interp,argvv[0],&radeg);
            mctcl_decode_angle(interp,argvv[1],&decdeg);
            Tcl_Free((char *) argvv);
            asd2=radeg*(DR);
            dec2=decdeg*(DR);
            /* --- calcul de la precession ---*/
            mc_precad(jjfrom,asd2,dec2,jjto,&asd2,&dec2);
            /* --- (ra,dec)2000 -> galactic  ---*/
            mc_radec2galactic(asd2,dec2,&lon,&lat);
            /* --- sortie des r�sultats ---*/
	         sprintf(s,"%12f %12f",lon/(DR),lat/(DR));
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_OK;
         } else {
            Tcl_Free((char *) argvv);
            sprintf(s,"Usage: %s ListRaDec Equinox", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_ERROR;
		   }
	   }
   }
   return result;
}

int Cmd_mctcl_galactic2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Conversion du systeme de coordonnees galactiques vers Ra,Dec.            */
/****************************************************************************/
/* Entrees :                 		     					                         */
/* ListLonLat en degres.                									          */
/* Equinox de sortie pour ra,dec         												 */
/*                                                                          */
/* Sorties :																                */
/* ListRaDec                 												             */
/****************************************************************************/
   double jjfrom=0.,jjto=0.,asd2=0.,dec2=0.,ra,dec,lon,lat;
   int result=TCL_ERROR;
   char s[100];
   char **argvv=NULL;
   int argcc;

   if(argc<3) {
      sprintf(s,"Usage: %s ListLonLat Equinox", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode la date de l'auinoxe ---*/
      mctcl_decode_date(interp,argv[2],&jjto);
      jjfrom=J2000;
      /*--- Calcul des coordonnees Ra,Dec */
      if (Tcl_SplitList(interp,argv[1],&argcc,&argvv)==TCL_OK) {
		   if (argcc>=2) {
            mctcl_decode_angle(interp,argvv[0],&lon);
            mctcl_decode_angle(interp,argvv[1],&lat);
            lon=lon*(DR);
            lat=lat*(DR);
            Tcl_Free((char *) argvv);
            /* --- galactic -> (ra,dec)2000 ---*/
            mc_galactic2radec(lon,lat,&ra,&dec);
            /* --- calcul de la precession ---*/
            mc_precad(jjfrom,ra,dec,jjto,&asd2,&dec2);
            /* --- sortie des r�sultats ---*/
	         sprintf(s,"%12f %12f",asd2/(DR),dec2/(DR));
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_OK;
         } else {
            Tcl_Free((char *) argvv);
            sprintf(s,"Usage: %s ListLonLat Equinox", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_ERROR;
		   }
	   }
   }
   return result;
}

int Cmd_mctcl_radec2ecliptic(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Conversion Ra,Dec vers le systeme de coordonnees ecliptiques.            */
/****************************************************************************/
/* Entrees :                 		     					                         */
/* ListRaDec                 												             */
/* Equinox                              												 */
/*                                                                          */
/* Sorties :																                */
/* ListLonLat en degres.                									          */
/****************************************************************************/
   double jjfrom=0.,jjto=0.,asd2=0.,dec2=0.,radeg,decdeg,lon,lat;
   int result=TCL_ERROR;
   char s[100];
   char **argvv=NULL;
   int argcc;
   double eps,r,x,y,z;

   if(argc<3) {
      sprintf(s,"Usage: %s ListRaDec Equinox", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode la date de l'equinoxe ---*/
      mctcl_decode_date(interp,argv[2],&jjfrom);
      jjto=J2000;
      /*--- Calcul des coordonnees Ra,Dec */
      if (Tcl_SplitList(interp,argv[1],&argcc,&argvv)==TCL_OK) {
		   if (argcc>=2) {
            mctcl_decode_angle(interp,argvv[0],&radeg);
            mctcl_decode_angle(interp,argvv[1],&decdeg);
            Tcl_Free((char *) argvv);
            asd2=radeg*(DR);
            dec2=decdeg*(DR);
            /* --- calcul de la precession ---*/
            /* mc_precad(jjfrom,radeg*DR,decdeg*DR,jjto,&asd2,&dec2); */
            /*--- constantes equatoriales ---*/
            mc_obliqmoy(jjfrom,&eps);
            mc_lbr2xyz(asd2,dec2,1,&x,&y,&z);
            mc_xyzeq2ec(x,y,z,eps,&x,&y,&z); /* equatoriale a la date */
            mc_xyz2lbr(x,y,z,&lon,&lat,&r);
            lon=fmod(lon+4*PI,(2*PI));
            /* --- sortie des r�sultats ---*/
	         sprintf(s,"%12f %12f",lon/(DR),lat/(DR));
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_OK;
         } else {
            Tcl_Free((char *) argvv);
            sprintf(s,"Usage: %s ListRaDec Equinox", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_ERROR;
		   }
	   }
   }
   return result;
}

int Cmd_mctcl_ecliptic2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Conversion du systeme de coordonnees ecliptique vers Ra,Dec.             */
/****************************************************************************/
/* Entrees :                 		     					                         */
/* ListLonLat en degres.                									          */
/* Equinox de sortie pour ra,dec         												 */
/*                                                                          */
/* Sorties :																                */
/* ListRaDec                 												             */
/****************************************************************************/
   double jjfrom=0.,jjto=0.,asd2=0.,dec2=0.,lon,lat;
   int result=TCL_ERROR;
   char s[100];
   char **argvv=NULL;
   int argcc;
   double eps,r,x,y,z;

   if(argc<3) {
      sprintf(s,"Usage: %s ListLonLat Equinox", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode la date de l'auinoxe ---*/
      mctcl_decode_date(interp,argv[2],&jjto);
      jjfrom=J2000;
      /*--- Calcul des coordonnees Ra,Dec */
      if (Tcl_SplitList(interp,argv[1],&argcc,&argvv)==TCL_OK) {
		   if (argcc>=2) {
            mctcl_decode_angle(interp,argvv[0],&lon);
            mctcl_decode_angle(interp,argvv[1],&lat);
            lon=lon*(DR);
            lat=lat*(DR);
            Tcl_Free((char *) argvv);
            /* --- calcul de la precession ---*/
            /* mc_precad(jjfrom,radeg,decdeg,jjto,&asd2,&dec2); */
            /*--- constantes equatoriales ---*/
            mc_obliqmoy(jjfrom,&eps);
            mc_lbr2xyz(lon,lat,1,&x,&y,&z);
            mc_xyzec2eq(x,y,z,eps,&x,&y,&z); /* equatoriale a la date */
            mc_xyz2lbr(x,y,z,&asd2,&dec2,&r);
            asd2=fmod(asd2+4*PI,(2*PI));
            /* --- sortie des r�sultats ---*/
	         sprintf(s,"%12f %12f",asd2/(DR),dec2/(DR));
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_OK;
         } else {
            Tcl_Free((char *) argvv);
            sprintf(s,"Usage: %s ListLonLat Equinox", argv[0]);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            result = TCL_ERROR;
		   }
	   }
   }
   return result;
}
