
// File   :libdcraw.h .
// Date   :05/08/2005
// Author :Michel Pujol

#ifndef __LIBDCRAW_SRC_H__
#define __LIBDCRAW_SRC_H__

#include <time.h>

#ifdef __cplusplus
extern "C" {
#endif


struct DataInfo {
  // information indispensables pour la conversion CFA->RGB
  int width;
  int height;
  unsigned int filters;
  int colors;
  int black;               // niveau de noir
  int maximum;             // niveau maximum
  int top_margin;
  int left_margin;

  // autres informations
  time_t timestamp;        // date en nombre de secondes depuis le 01/01/1970
  char make[64];           // fabriquant de la camera
  char model[72];          // modele de la camera
  float flash_used;        // flash utilisé
  float iso_speed;         // sensibilité en ISO
  float shutter;           // durée de la pose
  float aperture;          // ouverture en millimetre
  float focal_len;      

} dataInfo;


/**---------------------------------------------------------------
 * libdcraw_fileRaw2Cfa
 *
 * copie un fichier RAW dans un buffer CFA 
 * Cette fonction cree le buffer dataOut. 
 * le programme appelant doit detruire le buffer dataOut avec la fonction libdcraw_freeBuffer.
 * 
 * parametres 
 *   inputFileName (IN) nom du fichier RAW
 *   dataInfo      (OUT) information de l'image
 *   dataOut      (OUT) pointeur du buffer de sortie
 * return 
 *   0   OK
 *   -1  Erreur fichier incorrect
 *---------------------------------------------------------------
 */
int libdcraw_fileRaw2Cfa (char * inputFileName, struct DataInfo *dataInfo, unsigned short ** dataOut);


/**---------------------------------------------------------------
 * libdcraw_bufferRaw2Cfa
 *
 * Copie un buffer RAW dans un buffer CFA 
 * Cette fonction cree le buffer de sortie dataOut. 
 * Le programme appelant doit detruire le buffer dataOut avec la fonction libdcraw_freeBuffer.
 * 
 * parametres 
 *   dataIn       (IN)  pointer du buffer RAW
 *   dataInSize   (IN)  taille du buffer en octets 
 *   dataInfo     (OUT) information de l'image
 *   dataOut      (OUT) pointeur du buffer de sortie
 * return 
 *   0   OK
 *   -1  Erreur fichier incorrect
 *---------------------------------------------------------------
 */
int libdcraw_bufferRaw2Cfa (unsigned short * dataIn, unsigned long dataInSize, struct DataInfo *dataInfo, unsigned short ** dataOut);


/**---------------------------------------------------------------
 * libdcraw_fileRaw2Rgb
 *
 * decode et copie un fichier RAW dans un buffer RGB
 * Cette fonction cree le buffer dataOut. 
 * le programme appelant doit detruire le buffer dataOut avec la fonction libdcraw_freeBuffer.
 * 
 * parametres 
 *   inputFileName (IN) nom du fichier RAW
 *   dataInfo      (OUT) information de l'image
 *   dataOut       (OUT) pointeur du buffer de sortie RGB
 * return 
 *   0   OK
 *   -1  Erreur fichier incorrect
 *---------------------------------------------------------------
 */
int libdcraw_fileRaw2Rgb (char * inputFileName, struct DataInfo *dataInfo, unsigned short ** dataOut);


/**---------------------------------------------------------------
 * libdcraw_bufferRaw2Rgb
 *
 * decode et copie un buffer RAW dans un buffer RGB
 * Cette fonction cree le buffer dataOut. 
 * le programme appelant doit detruire le buffer dataOut avec la fonction libdcraw_freeBuffer.
 * 
 * parametres 
 *   dataIn       (IN)  pointer du buffer RAW
 *   dataInSize   (IN)  taille du buffer en octets 
 *   dataInfo     (OUT) information de l'image
 *   dataOut      (OUT) pointeur du buffer de sortie RGB
 * return 
 *   0   OK
 *   -1  Erreur fichier incorrect
 *---------------------------------------------------------------
 */
int libdcraw_bufferRaw2Rgb (unsigned short * dataIn, unsigned long dataInSize, struct DataInfo *dataInfo, unsigned short ** dataOut);


/**---------------------------------------------------------------
 * libdcraw_bufferRaw2Rgb
 *
 * decode et copie un buffer RAW dans un buffer RGB
 * Cette fonction cree le buffer dataOut. 
 * le programme appelant doit detruire le buffer dataOut avec la fonction libdcraw_freeBuffer.
 * 
 * parametres 
 *   dataIn       (IN)  pointer du buffer RAW
 *   dataInfo     (IN)  information de l'image 
 *   dataOut      (OUT) pointeur du buffer de sortie RGB
 * return 
 *   0   OK
 *   -1  Erreur fichier incorrect
 *---------------------------------------------------------------
 */
int libdcraw_bufferCfa2Rgb (unsigned short * dataIn, struct DataInfo *dataInfo, unsigned short **dataOut);

/**---------------------------------------------------------------
 * libdcraw_freeBuffer
 *
 * supprime un buffer alloue par une fonction de cette librairie
 * 
 * parametres 
 *   data       (IN)  pointer du buffer a supprimer
 * return 
 *   none
 *---------------------------------------------------------------
 */
void libdcraw_freeBuffer (unsigned short * data);

#ifdef __cplusplus
}
#endif

#endif 
