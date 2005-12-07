/* tt.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

#if defined(OS_LIN)
#   include <stdlib.h>
#   include <string.h>
#endif
#include <math.h>
#include "libstd.h"

#define NB_TT_PARAMS 7

#define TT_DIR_IN    0
#define TT_DIR_OUT   1
#define TT_EXT_IN    2
#define TT_EXT_OUT   3
#define TT_START_IN  4
#define TT_END_IN    5
#define TT_START_OUT 6

#define CMD_NGAIN2    1
#define CMD_SUB2      2
#define CMD_NOFFSET2  3
#define CMD_DIV2      4
#define CMD_OPT2      5
#define CMD_TRANS2    6
#define CMD_REGISTER  7
#define CMD_REGISTER2 8
#define CMD_SMEDIAN   9
#define CMD_SADD      10
#define CMD_SMEAN     11

#define CMD_OFFSET2   12
#define CMD_ADD2      13

class Ctt_params {
      protected:
   char *current_dir;
   void allocate(char**,char*);
      public:
   char *parametres[NB_TT_PARAMS];
   Ctt_params(Tcl_Interp*);
   ~Ctt_params();
   char* Get(int);
   void Set(int,char*);
};

Ctt_params::Ctt_params(Tcl_Interp*interp)
{
   char *tmp;
   int i;

   for(i=0;i<NB_TT_PARAMS;i++) {
      *(parametres+i) = 0;
   }
   current_dir = 0;

   if((tmp=(char*)Tcl_GetVar(interp,"tt(dir_in)",TCL_GLOBAL_ONLY))==0) {
      Tcl_Eval(interp,"pwd");
      allocate(&current_dir,interp->result);
      allocate(parametres+TT_DIR_IN,interp->result);
   } else {
      allocate(parametres+TT_DIR_IN,tmp);
   }
   if((tmp=(char*)Tcl_GetVar(interp,"tt(dir_out)",TCL_GLOBAL_ONLY))==0) {
      if(current_dir==0) {
         Tcl_Eval(interp,"pwd");
         allocate(&current_dir,interp->result);
      }
      allocate(parametres+TT_DIR_OUT,current_dir);
   } else {
      allocate(parametres+TT_DIR_OUT,tmp);
   }
   if((tmp=(char*)Tcl_GetVar(interp,"tt(ext_in)",TCL_GLOBAL_ONLY))==0) {
      allocate(parametres+TT_EXT_IN,".fit");
   } else {
      allocate(parametres+TT_EXT_IN,tmp);
   }
   if((tmp=(char*)Tcl_GetVar(interp,"tt(ext_out)",TCL_GLOBAL_ONLY))==0) {
      allocate(parametres+TT_EXT_OUT,".fit");
   } else {
      allocate(parametres+TT_EXT_OUT,tmp);
   }
   if((tmp=(char*)Tcl_GetVar(interp,"tt(start_in)",TCL_GLOBAL_ONLY))==0) {
      allocate(parametres+TT_START_IN,"1");
   } else {
      allocate(parametres+TT_START_IN,tmp);
   }
   if((tmp=(char*)Tcl_GetVar(interp,"tt(start_out)",TCL_GLOBAL_ONLY))==0) {
      allocate(parametres+TT_START_OUT,"1");
   } else {
      allocate(parametres+TT_START_OUT,tmp);
   }
}

Ctt_params::~Ctt_params()
{
   int i;
   for(i=0;i<NB_TT_PARAMS;i++) {
      if(*(parametres+i)) free(*(parametres+i));
   }
   if(current_dir) free(current_dir);
}

void Ctt_params::allocate(char**s_to,char*s_from)
{
   if(s_from==0) {
      if(*s_to) {
         free(*s_to);
         *s_to = 0;
      }
   } else {
      if(*s_to==0) {
         free(*s_to);
      }
      *s_to = (char*)calloc(strlen(s_from)+1,1);
      strcpy(*s_to,s_from);
   }
}

void Ctt_params::Set(int n,char*s)
{
   if((n>=0)&&(n<NB_TT_PARAMS)) {
      allocate(parametres+n,s);
   }
}

char* Ctt_params::Get(int n)
{
   return *(parametres+n);
}


//-------------------------------------------------------------------------
// CmdTtScript --
// Permet d'appeler (bientot) toutes les fonctions du mode script de libtt.
// Fonctions disponible :
// SUB         -> SUB2 [IN] [OPERAND] [OUT] [OFFSET] [NUMBER]
// NORMGAIN    -> NGAIN2 [ENTREE] [SORTIE] [NORME] [NOMBRE]
// NORMOFFSET  -> NOFFSET2 [ENTREE] [SORTIE] [NORME] [NOMBRE]

// DIV         -> DIV2 IN OPERAND OUT COEF NUMBER
// OPT         -> OPT2 IN DARK OFFSET OUT NUMBER               (!DARK=THERM+OFS)
// TRANS       -> TRANS2 IN OUT NUMBER DX DY
// REGISTER    -> REGISTER IN OUT NUMBER
//
int CmdTtScript(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char tmp[10];
   char *fail_msg = "";
   int msg;
   int cmd = 0;
   int nb_params = 0;
   int retour;

   // Decodage du mot-cle.
   if(audela_strcasecmp(argv[0],"NGAIN2")==0) {
      cmd = CMD_NGAIN2;
      nb_params = 5;
      fail_msg = "ngain2 in out norm number";
   } else if(audela_strcasecmp(argv[0],"NOFFSET2")==0) {
      cmd = CMD_NOFFSET2;
      nb_params = 5;
      fail_msg = "noffset2 in out norm number";
   } else if(audela_strcasecmp(argv[0],"OFFSET2")==0) {    // tout nouveau
      cmd = CMD_OFFSET2;
      nb_params = 5;
      fail_msg = "offset2 in out const number";
   } else if(audela_strcasecmp(argv[0],"ADD2")==0) {       // tout nouveau
      cmd = CMD_ADD2;
      nb_params = 5;
      fail_msg = "add2 in operand out const number";
   } else if(audela_strcasecmp(argv[0],"SUB2")==0) {
      cmd = CMD_SUB2;
      nb_params = 6;
      fail_msg = "sub2 in operand out offset number";
   } else if(audela_strcasecmp(argv[0],"DIV2")==0) {
      cmd = CMD_DIV2;
      nb_params = 6;
      fail_msg = "div2 in operand out coef number";
   } else if(audela_strcasecmp(argv[0],"OPT2")==0) {
      cmd = CMD_OPT2;
      nb_params = 6;
      fail_msg = "opt2 in dark offset out number";
   } else if(audela_strcasecmp(argv[0],"TRANS2")==0) {
      cmd = CMD_TRANS2;
      nb_params = 6;
      fail_msg = "trans2 in out number dx dy";
   } else if(audela_strcasecmp(argv[0],"REGISTER")==0) {
      cmd = CMD_REGISTER;
      nb_params = 4;
      fail_msg = "register in out number";
   } else if(audela_strcasecmp(argv[0],"REGISTER2")==0) {
      cmd = CMD_REGISTER2;
      nb_params = 4;
      fail_msg = "register2 in out number";
   } else if(audela_strcasecmp(argv[0],"SMEDIAN")==0) {
      cmd = CMD_SMEDIAN;
      nb_params = 4;
      fail_msg = "smedian in out number";
   } else if(audela_strcasecmp(argv[0],"SADD")==0) {
      cmd = CMD_SADD;
      nb_params = 4;
      fail_msg = "sadd in out number";
   } else if(audela_strcasecmp(argv[0],"SMEAN")==0) {
      cmd = CMD_SMEAN;
      nb_params = 4;
      fail_msg = "smean in out number";
   }

   // Erreur s'il y a eu un probleme au decodage du mot-cle
   // (ne doit jamais arriver).
   if(cmd==0) {
      Tcl_SetResult(interp,"Fonction inconnue <- Erreur ne devant pas arriver",TCL_VOLATILE);
      return TCL_ERROR;
   }

   // Erreur si le nombre d'arguments est insuffisant.
   if(argc<nb_params) {
      Tcl_SetResult(interp,fail_msg,TCL_VOLATILE);
      return TCL_ERROR;
   }


   // Analyse des options.
   Ctt_params *params = new Ctt_params(interp);
   if(argc>nb_params) {
      for(int i=nb_params;i<argc;i++) {
         if(audela_strcasecmp(argv[i],"-START_IN")==0) {
            i=i++;
            params->Set(TT_START_IN,argv[i]);
         } else if(audela_strcasecmp(argv[i],"-START_OUT")==0) {
            i=i++;
            params->Set(TT_START_OUT,argv[i]);
         } else if(audela_strcasecmp(argv[i],"-DIR_IN")==0) {
            i=i++;
            params->Set(TT_DIR_IN,argv[i]);
         } else if(audela_strcasecmp(argv[i],"-DIR_OUT")==0) {
            i=i++;
            params->Set(TT_DIR_OUT,argv[i]);
         } else if(audela_strcasecmp(argv[i],"-EXT_IN")==0) {
            i=i++;
            params->Set(TT_EXT_IN,argv[i]);
         } else if(audela_strcasecmp(argv[i],"-EXT_OUT")==0) {
            i=i++;
            params->Set(TT_EXT_OUT,argv[i]);
         }
      }
   }

   // Construction de la ligne de commande.
   char *s;
   s = (char*)calloc(1000,1);
   switch(cmd) {
      case CMD_NGAIN2 : {
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[4])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s NORMGAIN normgain_value=%s",
         params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[2],                   // nom de sortie
               params->Get(TT_START_OUT), // indice debut sortie
               params->Get(TT_EXT_OUT),   // extension des fichiers de sortie
               argv[3]);                  // specifique : valeur de normalisation
         }; break;

      case CMD_OFFSET2 : {
         // fail_msg = "offset2 in out const number";
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[4])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s OFFSET offset=%s",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[2],                   // nom de sortie
               params->Get(TT_START_OUT), // indice debut sortie
               params->Get(TT_EXT_OUT),   // extension des fichiers de sortie
               argv[3]);                  // specifique : valeur de l'offset
         }; break;

      case CMD_NOFFSET2 : {
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[4])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s NORMOFFSET normoffset_value=%s",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[2],                   // nom de sortie
               params->Get(TT_START_OUT), // indice debut sortie
               params->Get(TT_EXT_OUT),   // extension des fichiers de sortie
               argv[3]);                  // specifique : valeur de normalisation
         }; break;

      case CMD_ADD2 : {
         // fail_msg = "add2 in operand out const number";
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[5])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s ADD file=%s offset=%s",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[3],                   // nom de sortie
               params->Get(TT_START_OUT), // indice debut sortie
               params->Get(TT_EXT_OUT),   // extension des fichiers de sortie
               argv[2],                   // specifique : nom de l'image operande
               argv[4]);                  // specifique : constante a ajouter aux images
         }; break;

      case CMD_SUB2 : {
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[5])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s SUB file=%s offset=%s",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[3],                   // nom de sortie
               params->Get(TT_START_OUT), // indice debut sortie
               params->Get(TT_EXT_OUT),   // extension des fichiers de sortie
               argv[2],                   // specifique : nom de l'image operande
               argv[4]);                  // specifique : constante a ajouter aux images
         }; break;

      case CMD_DIV2 : { // DIV2 IN OPERAND OUT COEF NUMBER
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[5])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s DIV file=%s constant=%s",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[3],                   // nom de sortie
               params->Get(TT_START_OUT), // indice debut sortie
               params->Get(TT_EXT_OUT),   // extension des fichiers de sortie
               argv[2],                   // specifique : nom de l'image operande
               argv[4]);                  // specifique : constante a ajouter aux images
         }; break;

      case CMD_OPT2 : { // OPT2 IN DARK OFFSET OUT NUMBER
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[5])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s OPT dark=%s bias=%s therm_kappa=-10",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[4],                   // nom de sortie
               params->Get(TT_START_OUT), // indice debut sortie
               params->Get(TT_EXT_OUT),   // extension des fichiers de sortie
               argv[2],                   // specifique : nom du dark
               argv[3]);                  // specifique : nom du bias
         }; break;

      case CMD_TRANS2 : { // TRANS2 IN OUT NUMBER DX DY
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[3])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s TRANS trans_x=%s trans_y=%s",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[2],                   // nom de sortie
               params->Get(TT_START_OUT), // indice debut sortie
               params->Get(TT_EXT_OUT),   // extension des fichiers de sortie
               argv[4],                   // specifique : compos. x de la trans.
               argv[5]);                  // specifique : compos. y de la trans.
         }; break;

      case CMD_REGISTER : { // REGISTER IN OUT NUMBER
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[3])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(tmp,"__%s__",argv[1]);
         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s STAT objefile",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               tmp,                       // nom de sortie
               params->Get(TT_START_OUT), // indice debut sortie
               params->Get(TT_EXT_OUT));  // extension des fichiers de sortie
         msg = Libtt_main(TT_SCRIPT_2,1,s);

         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s REGISTER translate=only",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               tmp,                       // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[2],                   // nom de sortie
               params->Get(TT_START_OUT), // indice debut sortie
               params->Get(TT_EXT_OUT));  // extension des fichiers de sortie
         msg = Libtt_main(TT_SCRIPT_2,1,s);

         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s DELETE",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               tmp,                       // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               ".",                       // nom de sortie
               ".",                       // indice debut sortie
               params->Get(TT_EXT_OUT));  // extension des fichiers de sortie
         }; break;

      case CMD_REGISTER2 : { // REGISTER IN OUT NUMBER
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[3])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(tmp,"__%s__",argv[1]);
         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s STAT objefile",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               tmp,                       // nom de sortie
               params->Get(TT_START_OUT), // indice debut sortie
               params->Get(TT_EXT_OUT));  // extension des fichiers de sortie
         msg = Libtt_main(TT_SCRIPT_2,1,s);

         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s REGISTER translate=never",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               tmp,                       // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[2],                   // nom de sortie
               params->Get(TT_START_OUT), // indice debut sortie
               params->Get(TT_EXT_OUT));  // extension des fichiers de sortie
         msg = Libtt_main(TT_SCRIPT_2,1,s);

         sprintf(s,"IMA/SERIES %s %s %s %s %s %s %s %s %s DELETE",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               tmp,                       // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               ".",                       // nom de sortie
               ".",                       // indice debut sortie
               params->Get(TT_EXT_OUT));  // extension des fichiers de sortie
         }; break;

      case CMD_SMEDIAN : { // SMEDIAN IN OUT NUMBER
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[3])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(s,"IMA/STACK %s %s %s %s %s %s %s %s %s MED",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[2],                   // nom de sortie
               ".",                       // indice debut sortie
               params->Get(TT_EXT_OUT));  // extension des fichiers de sortie
         }; break;

      case CMD_SADD : { // SADD IN OUT NUMBER
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[3])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(s,"IMA/STACK %s %s %s %s %s %s %s %s %s ADD",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[2],                   // nom de sortie
               ".",                       // indice debut sortie
               params->Get(TT_EXT_OUT));  // extension des fichiers de sortie
         }; break;

      case CMD_SMEAN : { // SMEAN IN OUT NUMBER
         // Calcul du dernier index de l'image a traiter en entree
         sprintf(tmp,"%d",atoi(argv[3])+atoi(params->Get(TT_START_IN))-1);
         params->Set(TT_END_IN,tmp);
         sprintf(s,"IMA/STACK %s %s %s %s %s %s %s %s %s MEAN",
               params->Get(TT_DIR_IN),    // repertoire d'entree
               argv[1],                   // nom d'entree
               params->Get(TT_START_IN),  // indice debut entree
               params->Get(TT_END_IN),    // indice fin entree
               params->Get(TT_EXT_IN),    // extension des fichiers d'entree
               params->Get(TT_DIR_OUT),   // repertoire de sortie
               argv[2],                   // nom de sortie
               ".",                       // indice debut sortie
               params->Get(TT_EXT_OUT));  // extension des fichiers de sortie
         }; break;

   }

   // Appel a libtt
   msg = Libtt_main(TT_SCRIPT_2,1,s);
   if(msg) {
      char *ligne;
      ligne = new char[256];
      Libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
      sprintf(ligne,"Libtt (%d) : %s",msg,s);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      retour = TCL_ERROR;
      delete ligne;
   } else {
      Tcl_SetResult(interp,"",TCL_STATIC);
      retour = TCL_OK;
   }

   // Liberation de la memoire.
   free(s);
   delete params;

   return retour;
}

//-------------------------------------------------------------------------
// CmdFits2ColorJpg --
// Charge trois fichiers FITS en memoire et les sauve en Jpeg Couleur.
//
// fits2colorjpg filenamergb filenamejpg ?quality? ?locutr hicutr locutg hicutg locutb hicutb?
// autorises : 3,4,10
// fits2colorjpg filenamer filenameg filenameb filenamejpg ?quality? ?locutr hicutr locutg hicutg locutb hicutb?
// autorises : 5,6,12
//-------------------------------------------------------------------------
int CmdFits2ColorJpg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char *name, *ext, *path2, *nom_fichier_r, *nom_fichier_g, *nom_fichier_b, *nom_fichier_jpg;
   char *ligne;
   char *s;
   int msg;
   int retour;
   int quality,sbsh,mode,indexr=0,indexg=0,indexb=0,indexjpg=0;
   double sbr,shr,sbg,shg,sbb,shb;
   int nb_keys,kkey;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   int datatype;                    // Type du pointeur de l'image
   int naxis1,naxis2,naxis10,naxis20;
   float *pr=NULL,*pg=NULL,*pb=NULL;

   ligne = new char[256];
   datatype=TFLOAT;

   mode=0;
   if ((argc==3)||(argc==4)||(argc==10)) {
      mode=1;
      indexr=indexg=indexb=1;
      indexjpg=2;
   }
   if ((argc==5)||(argc==6)||(argc==12)) {
      mode=2;
      indexr=1;
      indexg=2;
      indexb=3;
      indexjpg=4;
   }
   if (mode==0) {
      sprintf(ligne,"Usage: %s filenamer filenameg filenameb filenamejpg ?quality? ?locutr hicutr locutg hicutg locutb hicutb?",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {
      name = (char*)calloc(64,sizeof(char));
      ext = (char*)calloc(10,sizeof(char));
      path2 = (char*)calloc(256,sizeof(char));
      nom_fichier_r = (char*)calloc(1000,sizeof(char));
      nom_fichier_g = (char*)calloc(1000,sizeof(char));
      nom_fichier_b = (char*)calloc(1000,sizeof(char));
      nom_fichier_jpg = (char*)calloc(1000,sizeof(char));

      // Decodage du nom de fichier : chemin, nom du fichier, etc.
      // fichier r
      sprintf(ligne,"file dirname {%s}",argv[indexr]); Tcl_Eval(interp,ligne); strcpy(path2,interp->result);
      sprintf(ligne,"file tail {%s}",argv[indexr]); Tcl_Eval(interp,ligne); strcpy(name,interp->result);
      sprintf(ligne,"file extension {%s}",argv[indexr]); Tcl_Eval(interp,ligne);
      if(strcmp(interp->result,"")==0) strcpy(ext,".fit"); else strcpy(ext,"");
      sprintf(ligne,"file join {%s} {%s%s}",path2,name,ext); Tcl_Eval(interp,ligne); strcpy(nom_fichier_r,interp->result);

      if (mode==2) {
      	// Decodage du nom de fichier : chemin, nom du fichier, etc.
      	// fichier g
      	sprintf(ligne,"file dirname {%s}",argv[indexg]); Tcl_Eval(interp,ligne); strcpy(path2,interp->result);
      	sprintf(ligne,"file tail {%s}",argv[indexg]); Tcl_Eval(interp,ligne); strcpy(name,interp->result);
      	sprintf(ligne,"file extension {%s}",argv[indexg]); Tcl_Eval(interp,ligne);
      	if(strcmp(interp->result,"")==0) strcpy(ext,".fit"); else strcpy(ext,"");
      	sprintf(ligne,"file join {%s} {%s%s}",path2,name,ext); Tcl_Eval(interp,ligne); strcpy(nom_fichier_g,interp->result);
      	// Decodage du nom de fichier : chemin, nom du fichier, etc.
      	// fichier b
      	sprintf(ligne,"file dirname {%s}",argv[indexb]); Tcl_Eval(interp,ligne); strcpy(path2,interp->result);
      	sprintf(ligne,"file tail {%s}",argv[indexb]); Tcl_Eval(interp,ligne); strcpy(name,interp->result);
      	sprintf(ligne,"file extension {%s}",argv[indexb]); Tcl_Eval(interp,ligne);
      	if(strcmp(interp->result,"")==0) strcpy(ext,".fit"); else strcpy(ext,"");
      	sprintf(ligne,"file join {%s} {%s%s}",path2,name,ext); Tcl_Eval(interp,ligne); strcpy(nom_fichier_b,interp->result);
      } else {
         sprintf(nom_fichier_g,"%s;2",nom_fichier_r);
         sprintf(nom_fichier_b,"%s;3",nom_fichier_r);
      }

      // Decodage du nom de fichier : chemin, nom du fichier, etc.
      // fichier jpg
      sprintf(ligne,"file dirname {%s}",argv[indexjpg]); Tcl_Eval(interp,ligne); strcpy(path2,interp->result);
      sprintf(ligne,"file tail {%s}",argv[indexjpg]); Tcl_Eval(interp,ligne); strcpy(name,interp->result);
      sprintf(ligne,"file extension {%s}",argv[indexjpg]); Tcl_Eval(interp,ligne);
      if(strcmp(interp->result,"")==0) strcpy(ext,".jpg"); else strcpy(ext,"");
      sprintf(ligne,"file join {%s} {%s%s}",path2,name,ext); Tcl_Eval(interp,ligne); strcpy(nom_fichier_jpg,interp->result);

      // decodage du critere de qualite
      quality=75;
      if (((mode==1)&&(argc>=4))||((mode==2)&&(argc>=6))) {
         quality=(int)(fabs(atof(argv[indexjpg+1])));
      }
      if (quality<5) {quality=5;}
      if (quality>100) {quality=100;}

      // decodage des seuils
      sbsh=0;
      sbr=shr=sbg=shg=sbb=shb=0.0;
      if (((mode==1)&&(argc>=10))||((mode==2)&&(argc>=12))) {
         sbr=(double)atof(argv[indexjpg+2]);
         shr=(double)atof(argv[indexjpg+3]);
         sbg=(double)atof(argv[indexjpg+4]);
         shg=(double)atof(argv[indexjpg+5]);
         sbb=(double)atof(argv[indexjpg+6]);
         shb=(double)atof(argv[indexjpg+7]);
         sbsh=1;
      }

      // Charge l'image rouge
      msg = Libtt_main(TT_PTR_LOADIMA,11,nom_fichier_r,&datatype,&pr,&naxis10,&naxis20,
   	   &nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         if(msg>0) {
            s = new char[256];
            Libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
            sprintf(ligne,"Error while loading %s : %s",nom_fichier_r,s);
            delete s;
         } else {
            sprintf(ligne,"Error while loading %s : %s",nom_fichier_r,CError::message(msg));
         }
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
         free(name);
      	free(ext);
      	free(path2);
      	free(nom_fichier_r);
      	free(nom_fichier_g);
      	free(nom_fichier_b);
      	free(nom_fichier_jpg);
         delete ligne;
         return retour;
		}
      // Decode les seuils rouges
      if (sbsh==0) {
         for (kkey=0;kkey<nb_keys;kkey++) {
            if (strcmp(keynames[kkey],"MIPS-LO")==0) {
               sbr=(double)atof(values[kkey]);
            }
            if (strcmp(keynames[kkey],"MIPS-HI")==0) {
               shr=(double)atof(values[kkey]);
            }
         }
      }
      // Liberation de la memoire allouee par libtt
      Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);

      // Charge l'image verte
      msg = Libtt_main(TT_PTR_LOADIMA,11,nom_fichier_g,&datatype,&pg,&naxis1,&naxis2,
   	   &nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         if(msg>0) {
            s = new char[256];
            Libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
            sprintf(ligne,"Error while loading %s : %s",nom_fichier_g,s);
            delete s;
         } else {
            sprintf(ligne,"Error while loading %s : %s",nom_fichier_g,CError::message(msg));
         }
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
         Libtt_main(TT_PTR_FREEPTR,1,&pr);
         free(name);
      	free(ext);
      	free(path2);
      	free(nom_fichier_r);
      	free(nom_fichier_g);
      	free(nom_fichier_b);
      	free(nom_fichier_jpg);
         delete ligne;
         return retour;
		}
      // verifie les dimensions
      if ((naxis1!=naxis10)||(naxis2!=naxis20)) {
      	sprintf(ligne,"Error image formats are not the same");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
         Libtt_main(TT_PTR_FREEPTR,1,&pr);
         Libtt_main(TT_PTR_FREEPTR,1,&pg);
         Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
         free(name);
      	free(ext);
      	free(path2);
      	free(nom_fichier_r);
      	free(nom_fichier_g);
      	free(nom_fichier_b);
      	free(nom_fichier_jpg);
         delete ligne;
         return retour;
      }
      // Decode les seuils verts
      if (sbsh==0) {
         for (kkey=0;kkey<nb_keys;kkey++) {
            if (strcmp(keynames[kkey],"MIPS-LO")==0) {
               sbg=(double)atof(values[kkey]);
            }
            if (strcmp(keynames[kkey],"MIPS-HI")==0) {
               shg=(double)atof(values[kkey]);
            }
         }
      }
      // Liberation de la memoire allouee par libtt
      Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);

      // Charge l'image bleue
      msg = Libtt_main(TT_PTR_LOADIMA,11,nom_fichier_b,&datatype,&pb,&naxis1,&naxis2,
   	   &nb_keys,&keynames,&values,&comments,&units,&datatypes);
      if(msg) {
         if(msg>0) {
            s = new char[256];
            Libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
            sprintf(ligne,"Error while loading %s : %s",nom_fichier_b,s);
            delete s;
         } else {
            sprintf(ligne,"Error while loading %s : %s",nom_fichier_b,CError::message(msg));
         }
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
         Libtt_main(TT_PTR_FREEPTR,1,&pr);
         Libtt_main(TT_PTR_FREEPTR,1,&pg);
         free(name);
      	free(ext);
      	free(path2);
      	free(nom_fichier_r);
      	free(nom_fichier_g);
      	free(nom_fichier_b);
      	free(nom_fichier_jpg);
         delete ligne;
         return retour;
		}
      // verifie les dimensions
      if ((naxis1!=naxis10)||(naxis2!=naxis20)) {
      	sprintf(ligne,"Error image formats are not the same");
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
         Libtt_main(TT_PTR_FREEPTR,1,&pr);
         Libtt_main(TT_PTR_FREEPTR,1,&pg);
         Libtt_main(TT_PTR_FREEPTR,1,&pb);
         Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
         free(name);
      	free(ext);
      	free(path2);
      	free(nom_fichier_r);
      	free(nom_fichier_g);
      	free(nom_fichier_b);
      	free(nom_fichier_jpg);
         delete ligne;
         return retour;
      }
      // Decode les seuils bleus
      if (sbsh==0) {
         for (kkey=0;kkey<nb_keys;kkey++) {
            if (strcmp(keynames[kkey],"MIPS-LO")==0) {
               sbb=(double)atof(values[kkey]);
            }
            if (strcmp(keynames[kkey],"MIPS-HI")==0) {
               shb=(double)atof(values[kkey]);
            }
         }
      }
      // Liberation de la memoire allouee par libtt
      Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);

      // Sauvegarde de l'image jpeg couleur
      msg=Libtt_main(TT_PTR_SAVEJPGCOLOR,14,nom_fichier_jpg,pr,pg,pb,&datatype,
            &naxis1,&naxis2,&sbr,&shr,&sbg,&shg,&sbb,&shb,&quality);
      if(msg) {
         if(msg>0) {
            s = new char[256];
            Libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
            sprintf(ligne,"Error while saveing %s : %s",nom_fichier_jpg,s);
            delete s;
         } else {
            sprintf(ligne,"Error while saveing %s : %s",nom_fichier_jpg,CError::message(msg));
         }
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         retour = TCL_ERROR;
         Libtt_main(TT_PTR_FREEPTR,1,&pr);
         Libtt_main(TT_PTR_FREEPTR,1,&pg);
         free(name);
      	free(ext);
      	free(path2);
      	free(nom_fichier_r);
      	free(nom_fichier_g);
      	free(nom_fichier_b);
      	free(nom_fichier_jpg);
         delete ligne;
         return retour;
		}

      Tcl_SetResult(interp,"",TCL_VOLATILE);
      retour = TCL_OK;

      Libtt_main(TT_PTR_FREEPTR,1,&pr);
      Libtt_main(TT_PTR_FREEPTR,1,&pg);
      Libtt_main(TT_PTR_FREEPTR,1,&pb);

      free(name);
      free(ext);
      free(path2);
      free(nom_fichier_r);
      free(nom_fichier_g);
      free(nom_fichier_b);
      free(nom_fichier_jpg);
   }

   delete ligne;
   return retour;
}

int CmdTtScript2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int msg;
   char *ligne, *s;
   int nb_arg_min = 2;        // Nombre minimal d'arguments

   if(argc<nb_arg_min) {
      ligne = (char*)calloc(100,sizeof(char));
      sprintf(ligne,"Usage: %s ttscript_line",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   }

   msg = Libtt_main(TT_SCRIPT_2,1,argv[1]);
   if(msg) {
      s = (char*)calloc(100,sizeof(char));
      ligne = (char*)calloc(100,sizeof(char));
      Libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
      sprintf(ligne,"Erreur dans libtt : %s.",s);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(s);
      free(ligne);
      return TCL_ERROR;
   }

   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}


int CmdTtScript3(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int msg;
   char *ligne, *s;
   int nb_arg_min = 2;        // Nombre minimal d'arguments

   if(argc<nb_arg_min) {
      ligne = (char*)calloc(100,sizeof(char));
      sprintf(ligne,"Usage: %s ttscript_filename",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   }

   msg = Libtt_main(TT_SCRIPT_3,1,argv[1]);
   if(msg) {
      s = (char*)calloc(100,sizeof(char));
      ligne = (char*)calloc(100,sizeof(char));
      Libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
      sprintf(ligne,"Error while performing tt_script_3 : %s.",s);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(s);
      free(ligne);
      return TCL_ERROR;
   }

   Tcl_SetResult(interp,"",TCL_VOLATILE);
   return TCL_OK;
}

int CmdFitsHeader(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int msg;                         // Code erreur de libtt
   int nbkeys,k;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   Tcl_DString dsptr;

   char *ligne, *ligne2, *s;
   int nb_arg_min = 2;        // Nombre minimal d'arguments

   if(argc<nb_arg_min) {
      ligne = (char*)calloc(100,sizeof(char));
      sprintf(ligne,"Usage: %s filename",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_ERROR;
   }
   msg=Libtt_main(TT_PTR_LOADKEYS,7,argv[1],&nbkeys,&keynames,&values,
      &comments,&units,&datatypes);
   if(msg) {
      s = (char*)calloc(100,sizeof(char));
      ligne = (char*)calloc(100,sizeof(char));
      Libtt_main(TT_ERROR_MESSAGE,2,&msg,s);
      sprintf(ligne,"Error while loading header: %s.",s);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(s);
      free(ligne);
      return TCL_ERROR;
   }
   ligne = (char*)calloc(300,sizeof(char));
   ligne2 = (char*)calloc(300,sizeof(char));
	Tcl_DStringInit(&dsptr);
   for (k=0;k<nbkeys;k++) {
	   Tcl_DStringAppend(&dsptr,"{",-1);
      sprintf(ligne," \"%s\" ",keynames[k]);
	   Tcl_DStringAppend(&dsptr,ligne,-1);
      sprintf(ligne,"string trim \"%s\" \" \"",values[k]);
      Tcl_Eval(interp,ligne);
      sprintf(ligne,"\"%s\"",interp->result);
	   Tcl_DStringAppend(&dsptr,ligne,-1);
      if (datatypes[k]==TBIT) {
         strcat(ligne," bit ");
      } else if (datatypes[k]==TBYTE) {
         strcat(ligne," byte ");
      } else if (datatypes[k]==TLOGICAL) {
         strcat(ligne," logical ");
      } else if (datatypes[k]==TSTRING) {
         strcat(ligne," string ");
      } else if (datatypes[k]==TUSHORT) {
         strcat(ligne," ushort ");
      } else if (datatypes[k]==TINT) {
         strcat(ligne," int ");
      } else if (datatypes[k]==TULONG) {
         strcat(ligne," ulong ");
      } else if (datatypes[k]==TLONG) {
         strcat(ligne," long ");
      } else if (datatypes[k]==TFLOAT) {
         strcat(ligne," float ");
      } else if (datatypes[k]==TDOUBLE) {
         strcat(ligne," double ");
      } else if (datatypes[k]==TCOMPLEX) {
         strcat(ligne," complex ");
      } else if (datatypes[k]==TDBLCOMPLEX) {
         strcat(ligne," dlbcomplex ");
      }
	   Tcl_DStringAppend(&dsptr,ligne,-1);
      sprintf(ligne," \"%s\" ",comments[k]);
	   Tcl_DStringAppend(&dsptr,ligne,-1);
      sprintf(ligne," \"%s\" ",units[k]);
	   Tcl_DStringAppend(&dsptr,ligne,-1);
	   Tcl_DStringAppend(&dsptr,"} ",-1);
   }
   free(ligne);
   free(ligne2);
   Tcl_DStringResult(interp,&dsptr);
   Tcl_DStringFree(&dsptr);
   msg=Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,
      &comments,&units,&datatypes);
   return TCL_OK;
}

int CmdFitsConvert3d(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   int msg;                         // Code erreur de libtt
   int nbkeys,nbkeys0,kk,k;
   char **keynames0=NULL;
   char **values0=NULL;
   char **comments0=NULL;
   char **units0=NULL;
   int *datatypes0=NULL;
   char **keynames=NULL;
   char **values=NULL;
   char **comments=NULL;
   char **units=NULL;
   int *datatypes=NULL;
   char ligne[1000];
   char ligne2[1000];
   char filein[1000];
   char fileout[1000];
   int nb,naxis3;
   int naxis1,naxis2,naxis10,naxis20,datatype;
   int bitpix,bzero;
   float *ptot=NULL,*p=NULL;
   int nelem;
 
   int nb_arg_min = 5;        // Nombre minimal d'arguments

   if(argc<nb_arg_min) {
      sprintf(ligne,"Usage: %s genericname nb extension filename3d",argv[0]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      free(ligne);
      return TCL_OK;
   }
   nb=atoi(argv[2]);
   if (nb<=0) {
      Tcl_SetResult(interp,"number of images must be positive",TCL_VOLATILE);
      return TCL_ERROR;
   }
   naxis10=1;
   naxis20=1;
   bzero=0;
   for (k=1;k<=nb;k++) {
      sprintf(filein,"%s%d%s",argv[1],k,argv[3]);
      if (k==1) {
         msg=Libtt_main(TT_PTR_LOADKEYS,7,filein,&nbkeys0,&keynames0,&values0,
            &comments0,&units0,&datatypes0);
         if (msg) {
            Libtt_main(TT_ERROR_MESSAGE,2,&msg,ligne2);
            sprintf(ligne,"Error while loading %s: %s.",filein,ligne2);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            return TCL_ERROR;
         }
         for (kk=0;kk<nbkeys0;kk++) {
            if (strcmp(keynames0[kk],"NAXIS1")==0) { naxis10=atoi(values0[kk]); }
            if (strcmp(keynames0[kk],"NAXIS2")==0) { naxis20=atoi(values0[kk]); }
            if (strcmp(keynames0[kk],"BITPIX")==0) { bitpix=atoi(values0[kk]); }
            if (strcmp(keynames0[kk],"BZERO")==0) { bzero=atoi(values0[kk]); }
         }
         ptot=(float*)calloc((unsigned int)sizeof(double),naxis10*naxis20*nb);
         if (ptot==NULL) {
            sprintf(ligne,"Not enough memory for a cubic image of %dx%dx%d pixels",naxis1,naxis2,nb);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            Libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
            return TCL_ERROR;
         }
      } else {
         msg=Libtt_main(TT_PTR_LOADKEYS,7,filein,&nbkeys,&keynames,&values,
            &comments,&units,&datatypes);
         if (msg) {
            Libtt_main(TT_ERROR_MESSAGE,2,&msg,ligne2);
            sprintf(ligne,"Error while loading %s: %s.",filein,ligne2);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            Libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
            Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
            return TCL_ERROR;
         }
         for (kk=0;kk<nbkeys;kk++) {
            if (strcmp(keynames[kk],"NAXIS1")==0) { naxis1=atoi(values[kk]); }
            if (strcmp(keynames[kk],"NAXIS2")==0) { naxis2=atoi(values[kk]); }
         }
         if ((naxis1!=naxis10)) {
            sprintf(ligne,"Uncompatible format for %s: NAXIS1=%d instead of %d",filein,naxis1,naxis10);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            Libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
            Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
            return TCL_ERROR;
         }
         if ((naxis2!=naxis20)) {
            sprintf(ligne,"Uncompatible format for %s: NAXIS2=%d instead of %d",filein,naxis2,naxis20);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            Libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
            Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
            return TCL_ERROR;
         }
      }
      datatype=TFLOAT;
      msg=Libtt_main(TT_PTR_LOADIMA,5,filein,&datatype,&p,&naxis1,&naxis2);
      nelem=naxis10*naxis20;
      for (kk=0;kk<nelem;kk++) {
         ptot[(k-1)*nelem+kk]=p[kk];
      }
   }
   datatype=TFLOAT;
   if ((bitpix==SHORT_IMG)&&(bzero==32768)) {
      bitpix=USHORT_IMG;
   } else if ((bitpix==LONG_IMG)&&(bzero==-2e31)) {
      bitpix=ULONG_IMG;
   }
   naxis3=nb;
   sprintf(fileout,"%s%s",argv[4],argv[3]);
   msg=Libtt_main(TT_PTR_SAVEIMA3D,13,fileout,ptot,&datatype,&naxis1,
      &naxis2,&naxis3,&bitpix,&nbkeys0,keynames0,values0,
      comments0,units0,datatypes0);
   if (msg) {
      Libtt_main(TT_ERROR_MESSAGE,2,&msg,ligne2);
      sprintf(ligne,"Error while saving %s: %s.",filein,ligne2);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      Libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
      Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
      return TCL_ERROR;
   }
   Libtt_main(TT_PTR_FREEKEYS,5,&keynames0,&values0,&comments0,&units0,&datatypes0);
   Libtt_main(TT_PTR_FREEKEYS,5,&keynames,&values,&comments,&units,&datatypes);
   return TCL_OK;
   /*
fitsconvert3d d:/audela/images/j 10 .fit d:/audela/images/alain
*/
}
