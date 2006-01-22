// Fichier : parallel_tcl.cpp
// Auteur  : Michel PUJOL
// Description : Point d'entree TCL de la librairie
// ============================================

#include <sysexp.h>
#include <tcl.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {			/* Assume C declarations for C++ */
#endif				/* __cplusplus */


#include "link.h"

#ifdef __cplusplus
}			/* Assume C declarations for C++ */
#endif				/* __cplusplus */

   
int cmdParallelChar(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   
   int result = TCL_OK;
   char *ligne;
   int c;
   CParallel * parallel = (CParallel*)clientData;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=2)&&(argc!=3)) {
      sprintf(ligne,"Usage: %s %s ?0...255?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else if(argc==2) {
      if( parallel->getChar((char *)&c) == LINK_OK) {
         sprintf(ligne, "%d", c); 
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_OK;
      } else {
         parallel->getLastError(ligne);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);      
         result = TCL_ERROR;
      }
   } else {
      int i;
      if(Tcl_GetInt(interp,argv[2],&i)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?num?\nnum = must be an integer 0 to 255",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {
         if( parallel->setChar((char)i) == LINK_OK) {
            sprintf(ligne, "%d", i); 
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            result = TCL_OK;
         } else {
            parallel->getLastError(ligne);
            Tcl_SetResult(interp,ligne,TCL_VOLATILE);      
            result = TCL_ERROR;
         }
      }
   }
   free(ligne);
   return result;
}
   

int cmdParallelBit(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   int result = TCL_OK;
   char *ligne;
   int bit;
   int value;
   CParallel * parallel = (CParallel*)clientData;

   ligne = (char*)calloc(200,sizeof(char));
   if((argc!=3)&&(argc!=4)) {
      sprintf(ligne,"Usage: %s %s bit ?value?",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      if(Tcl_GetInt(interp,argv[2],&bit)!=TCL_OK) {
         sprintf(ligne,"Usage: %s %s ?bit?\nbit = must be an integer 0 to 7",argv[0],argv[1]);
         Tcl_SetResult(interp,ligne,TCL_VOLATILE);
         result = TCL_ERROR;
      } else {         
         if(argc==3) {
            // get bit 
            if( parallel->getBit(bit, &value) == LINK_OK) {
               sprintf(ligne, "%d", value); 
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_OK;
            } else {
               parallel->getLastError(ligne);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);      
               result = TCL_ERROR;
            }
         } else {
            // set bit 
            if(Tcl_GetInt(interp,argv[3],&value)!=TCL_OK) {
               sprintf(ligne,"Usage: %s %s ?value?\nvalue = must be an integer 0 or 1",argv[0],argv[1]);
               Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               result = TCL_ERROR;
            } else {
               if( parallel->setBit(bit, value) == LINK_OK) {
                  Tcl_SetResult(interp,"",TCL_VOLATILE);
                  result = TCL_OK;
               } else {
                  parallel->getLastError(ligne);
                  Tcl_SetResult(interp,ligne,TCL_VOLATILE);      
                  result = TCL_ERROR;
               }
            }
         }
      }
   }
   free(ligne);
   return result;
}
   
int cmdParallelIndex(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   
   int result ;
   char message[256];
   CParallel * parallel = (CParallel*)clientData;
   int index;

   result = parallel->getIndex(&index);
   if (result == LINK_OK) {
      sprintf(message,"%d", index);
      Tcl_SetResult(interp,message,TCL_VOLATILE);      
      return TCL_OK;
   } else {
      parallel->getLastError(message);
      Tcl_SetResult(interp,message,TCL_VOLATILE);      
      return TCL_ERROR;
   }
}
   
int cmdParallelAddress(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
   
   int result ;
   char message[256];
   CParallel * parallel = (CParallel*)clientData;
   int address;

   result = parallel->getAddress(&address);
   if (result == LINK_OK) {
      sprintf(message, "%X", address);
      Tcl_SetResult(interp,message,TCL_VOLATILE);      
      return TCL_OK;
   } else {
      parallel->getLastError(message);
      Tcl_SetResult(interp,message,TCL_VOLATILE);      
      return TCL_ERROR;
   }
}
   




