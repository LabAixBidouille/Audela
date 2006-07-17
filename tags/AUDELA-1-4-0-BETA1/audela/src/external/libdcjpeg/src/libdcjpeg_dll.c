// libjpeg.cpp : Defines the entry point for the DLL application.
//


#include "jinclude.h"
#include "jpeglib.h"
#include "jerror.h"

#include "jpegmemscr.h"
#include "malloc.h"


#ifdef WIN32

#include <windows.h>

BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
    switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
			break;
    }
    return TRUE;
}

#endif

int libdcjpeg_decodeBuffer(char * inputData, long inputSize, char **outputData, long *outputSize, int *width, int *height)
{
 
  struct jpeg_decompress_struct cinfo; 
  struct jpeg_error_mgr jerr; 
  int i, rowSize;
  JSAMPROW rowData[1];

  cinfo.err = jpeg_std_error(&jerr); 
  jpeg_create_decompress(&cinfo); 
  jpeg_mem_src(&cinfo, (unsigned char *) inputData, inputSize);  
  jpeg_read_header(&cinfo, TRUE); 
  jpeg_start_decompress(&cinfo);

  rowSize= cinfo.output_width * cinfo.output_components;
  *outputSize=cinfo.output_width * cinfo.output_height * cinfo.output_components;
  *outputData=(char*)malloc(*outputSize);

  for (i=cinfo.output_height-1; i>=0; i--) {
    rowData[0] = (JSAMPROW)(*outputData + i*rowSize);
    jpeg_read_scanlines(&cinfo, rowData, 1);
  }
  jpeg_finish_decompress(&cinfo);
  jpeg_destroy_decompress(&cinfo);

  *width = cinfo.output_width;
  *height = cinfo.output_height;

  return 0;
}



void libdcjpeg_freeBuffer(char * data) {

   if( data != 0 ) {
      free( data);
   }
}
