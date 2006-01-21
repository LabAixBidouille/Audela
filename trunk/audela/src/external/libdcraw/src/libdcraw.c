// File   :libdcraw.c .
// Date   :05/08/2005
// Author :Michel Pujol

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <math.h>

#include "dcraw.h"

#ifdef WIN32
#include <windows.h>
#include <io.h>

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

/*
Write the image to an 8-bit buffer.
*/
void CLASS writeMemoryBuffer8 (unsigned char *pixels)
{
   unsigned char lut[0x10000];
   int perc, c, val, total, i, row, col;
   float white=0, r;
   
   perc = (int) (width * height * 0.01);	
   if (fuji_width) perc /= 2;
   for (c=0; c < 3; c++) {
      for (val=0x2000, total=0; --val > 32; )
         if ((total += histogram[c][val]) > perc) break;
         if (white < val) white = (float) val;
   }
   white *= 8 / bright;
   for (i=0; i < 0x10000; i++) {
      r = i / white;
      val = 256 * ( !use_gamma ? r :
      r <= 0.018 ? r*4.5 : (pow(r,0.45)*1.099-0.099) );
      if (val > 255) val = 255;
      lut[i] = val;
   }
   for (row=trim; row < height-trim; row++) {
      for (col=trim; col < width-trim; col++)
         for (c=0; c < 3; c++) 
            for (i=0; i < xmag; i++)
               *(pixels + (row-trim)*(width-trim*2)*3 + (col-trim)*3 + c)  =  lut[image[row*width+col][c]];
               
   }
}

/*
Write the image to an 16-bit buffer.
*/
void CLASS writeMemoryBuffer16 (unsigned short *pixels)
{
   unsigned short lut[0x10000];
   int perc, c, val, total, i, row, col;
   float white=0, r;
   long position;

   perc = (int) (width * height * 0.01);	
   if (fuji_width) perc /= 2;
   for (c=0; c < 3; c++) {
      for (val=0x2000, total=0; --val > 32; )
         if ((total += histogram[c][val]) > perc) break;
         if (white < val) white = (float) val;
   }
   white *= 8 / bright;
   for (i=0; i < 0x10000; i++) {
      r = i / white;
      val = 128 * 256 * ( !use_gamma ? r :
      r <= 0.018 ? r*4.5 : (pow(r,0.45)*1.099-0.099) );
      if (val > 32767) val = 32767;
      lut[i] = val;
   }
   for (row=trim; row < height-trim; row++) {
      for (col=trim; col < width-trim; col++)
         for (c=0; c < 3; c++) {
            pixels[(row-trim)*(width-trim*2)*3  +  (col-trim)*3 + c]  = lut[image[row*width+col][c]];
         }
         
   }
}

int libdcraw_getTypeFromFile (char * inputFileName, char *vendorName, char *productName) {
   int status=0;
      
   ifname = inputFileName;
   
   if( ifname == NULL) {
      return -1;
   }
   
   
#if defined(WIN32) || defined(DJGPP) || defined(__CYGWIN__)
   if (setmode(1,O_BINARY) < 0) {
      perror("setmode()");
      return -1;
   }
#endif
   
   image = NULL;
   if (!(ifp = fopen (ifname, "rb"))) {
      perror (ifname);
      return -1;
   }
   
   if ((status = identify(1))) {
      fclose(ifp);
      return -1;
   }      

   strcpy (vendorName, make); 
   strcpy (productName, model); 
   fclose(ifp);
   return 0;
}

int libdcraw_getTypeFromBuffer (char * imageData, unsigned long imageSize, char *vendorName, char *productName) {
   char tempFileName[] ="tempfilename2.tmp";
   int result;
   size_t sizeWritten;
   FILE * ofp;
   
   ofp = fopen (tempFileName, "wb");
   if (ofp) {
      sizeWritten = fwrite (imageData, imageSize, 1, ofp);
      fclose(ofp);
      if( sizeWritten == 1 ) { 
         result = libdcraw_getTypeFromFile(tempFileName, vendorName, productName);
      } 
      remove(tempFileName);
      result = 0;
   } else {
      result = -1;
   }
   
   return result;
}


int libdcraw_decodeFile (char * inputFileName, int *pwidth, int *pheight, char **ppixels)
{
   int status=0, user_flip=-1;
   int identify_only=0;
   int half_size=0, use_fuji_rotate=1;
   long outputSize;
      
   ifname = inputFileName;
   
   if( ifname == NULL) {
      return -1;
   }
   
   
#if defined(WIN32) || defined(DJGPP) || defined(__CYGWIN__)
   if (setmode(1,O_BINARY) < 0) {
      perror("setmode()");
      return -1;
   }
#endif
   
   verbose = 0;
   status = 1;
   image = NULL;
   if (!(ifp = fopen (ifname, "rb"))) {
      perror (ifname);
      return -1;
   }
   
   if ((status = identify(1))) {
      fprintf (stderr, "%s is a %s %s image.\n", ifname, make, model);
      fclose(ifp);
      return -1;
   }      
   if (user_flip >= 0) {
      flip = user_flip;
   }

   switch ((flip+3600) % 360) {
      case 270:  flip = 5;  break;
      case 180:  flip = 3;  break;
      case  90:  flip = 6;
   }
   
   if (identify_only) {
      fprintf (stderr, "%s is a %s %s image.\n", ifname, make, model);
      fclose(ifp);
      return -1;
   }
   
   shrink = half_size && filters;
   iheight = (height + shrink) >> shrink;
   iwidth  = (width  + shrink) >> shrink;
   image = calloc (iheight*iwidth*sizeof *image + meta_length, 1);
   merror (image, "main()");
   meta_data = (char *) (image + iheight*iwidth);
   if (verbose)
      fprintf (stderr,
      "Loading %s %s image from %s...\n", make, model, ifname);
   (*load_raw)();
   bad_pixels();
   height = iheight;
   width  = iwidth;
   if (is_foveon) {
      if (verbose)
         fprintf (stderr, "Foveon interpolation...\n");
      foveon_interpolate();
   } else {
#ifdef COLORCHECK
      colorcheck();
#endif
      scale_colors();
   }
   if (shrink) filters = 0;
   trim = 0;
   if (filters && !document_mode) {
      trim = 1;
      if (verbose)
         fprintf (stderr, "%s interpolation...\n",
         quick_interpolate ? "Bilinear":"VNG");
      vng_interpolate();
   }
   if (use_fuji_rotate) fuji_rotate();
   if (verbose)
      fprintf (stderr, "Converting to RGB colorspace...\n");
   convert_to_rgb();

   if (flip) {
      if (verbose)
         fprintf (stderr, "Flipping image %c:%c:%c...\n",
         flip & 1 ? 'H':'0', flip & 2 ? 'V':'0', flip & 4 ? 'T':'0');
      flip_image();
   }
   fclose(ifp);

  
   *pwidth  = xmag*(width-trim*2);
   *pheight = ymag*(height-trim*2);     

   //outputSize = ((*pwidth)) *  ((*pheight)) *3  *sizeof(unsigned char);
   outputSize = ((*pwidth)) *  ((*pheight)) *3  *sizeof(unsigned short);
   *ppixels = malloc(outputSize);
   if( *ppixels == NULL) {
     fprintf(stderr,"insufficient memory.\n");
      return -1;
   }
   

   //write_fun = writeMemoryBuffer;
   //(*write_fun)(ofp);

   //writeMemoryBuffer8 (*ppixels);
   writeMemoryBuffer16 ((unsigned short *) *ppixels);

   free (image);
   
   return status;
      
}

int libdcraw_decodeBuffer (char * imageData, unsigned long imageSize, int *pwidth, int *pheight, char **ppixels)
{

   char tempFileName[] ="tempfilename2.tmp";
   int result;
   size_t sizeWritten;
   FILE * ofp;
   
   ofp = fopen (tempFileName, "wb");
   if (ofp) {
      sizeWritten = fwrite (imageData, imageSize, 1, ofp);
      fclose(ofp);
      if( sizeWritten == 1 ) { 
         result = libdcraw_decodeFile(tempFileName, pwidth, pheight, ppixels);
      } 
      remove(tempFileName);
      result = 0;
   } else {
      result = -1;
   }
   
   return result;
}

void libdcraw_freeBuffer (char * data) 
{
   if( data != NULL) {
      free(data);
   }
}


