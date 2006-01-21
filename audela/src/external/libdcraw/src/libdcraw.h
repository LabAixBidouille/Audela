
// File   :libdcraw.h .
// Date   :05/08/2005
// Author :Michel Pujol


#ifdef __cplusplus
extern "C" {
#endif

int libdcraw_getTypeFromFile (char * inputFileName, char *vendorName, char *productName);
int libdcraw_getTypeFromBuffer (char * imageData, unsigned long imageSize, char *vendorName, char *productName);

int libdcraw_decodeFile (char * ifname, int *pwidth, int *pheight, char **ppixels);
int libdcraw_decodeBuffer (char * imageData, unsigned long imageSize, int *pwidth, int *pheight, char **ppixels);
void libdcraw_freeBuffer (char * data);

#ifdef __cplusplus
}
#endif
