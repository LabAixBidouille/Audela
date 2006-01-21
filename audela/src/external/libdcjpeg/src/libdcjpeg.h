
// File   :jpegdecompress.h .
// Date   :05/08/2005
// Author :Michel Pujol

#ifndef __JPEG_MEM_SRC_H__
#define __JPEG_MEM_SRC_H__

#ifdef __cplusplus
extern "C" {
#endif

int  libdcjpeg_decodeBuffer(char * inputData, long inputSize, char **outputData, long *outputSize, int *width, int *height);
void libdcjpeg_freeBuffer( char *data);

#ifdef __cplusplus
}
#endif

#endif

