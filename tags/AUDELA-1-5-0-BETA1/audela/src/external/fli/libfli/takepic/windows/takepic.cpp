//
// takepic.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <time.h>
#include "windows.h"
#include <malloc.h>
#include "conio.h"
#include "../../lib/libfli.h"


/**
	This simply forces the user to press a key to close the program
*/
void _cdecl end(void)
{
	printf("\nPress any key to exit.\n");
	while(!kbhit());
	return;
}


/**
	This is the main program
*/
int main(int argc, char* argv[])
{
	atexit(end);



	long sum_max_area =0;
	short maxX =0;
	short maxY=0;
	short maxVal =0;



	//Variable Creation
	int image_size_x,image_size_y;
	long visible_ul_y,visible_ul_x,visible_lr_y,visible_lr_x;
	long cont = 0;
	char version[1024];
	char *device_name;
	char *device_type;
	flidev_t dev;
	long domain;


	//Variable Initalization
	image_size_x=image_size_y =0;
	visible_ul_y=visible_ul_x=visible_lr_y=visible_lr_x =0;
	domain= FLIDOMAIN_USB| FLIDEVICE_CAMERA;
	device_name = new char[25];
	device_type = new char[25];


	printf("/*************** Take Pic test Program*****************\\\n\n");
	
	//Initial Camera Information
	//This displays sets the Debug to the highest level then reads and displays the version of the fli-lib
	printf("Debug level set to FLIDEBUG_ALL\n");
	FLISetDebugLevel("C:\\flidebug.txt", FLIDEBUG_ALL);	
	FLIGetLibVersion(version, 1023);
	printf("%s\n", version);

	//This creates an FLI Device List within the fli API 
	//this list contains all of the FLI items that match the type
	//give in domain. In this case the type is USB Camera
	cont = FLICreateList(domain);
	if(cont != 0){
		printf("FLICreateList read failed");
		return 0;
	}



	/**
		While there are still devices in the FLI list, 
		this section fetches the name and type of that item,
		opens a connection to that device, and saves an image from that device
	*/
	int i =0;
	cont =FLIListFirst(&domain,device_type, 25,device_name,25);
	if(cont != 0){
		printf("TakePic:FLIListFirst error");
		i++;
 	cont =FLIListNext(&domain,device_type, 25,device_name,25);

	}
	while(cont == 0 ){

		// this prints the proper name of the current device to the screen
		printf("Found USB Camera: %s \n", device_name);

	
		// this code opens the current device based on it's type, 
		//displays a message for failure or success in opening that device
		cont = FLIOpen(&dev, device_type, domain);
		if(cont != 0 ){
			printf("FLIOpen failed");
			return 0;
		}
		printf("USB Camera opened successfully, dev# %d \n", dev);
		

	//sets exposure time
//	FLISetExposureTime(dev, 12000);
		FLISetExposureTime(dev, 120);

		//this code retrieves the visable area from the API, 
		//and displays a failure message if it fails.
		cont = FLIGetVisibleArea(dev,&visible_ul_x,&visible_ul_y,&visible_lr_x,&visible_lr_y);
		if(cont != 0){
			printf("FLIGetVisibleArea failed");
			return 0;
		}

		//this section of code calculates the size of the image based on the 
		//GetVisibleArea query above. It also allocates the proper amount of memory 
		//for storing the image.  NOTE: 16 bit= pixel size = sizeof(unsigned short)
		image_size_x = (int)visible_lr_x -(int)visible_ul_x;
		image_size_y = (int)visible_lr_y -(int)visible_ul_y;
		unsigned short* img_ptr = (unsigned short*)malloc(2*image_size_x*image_size_y);
		printf("Camera array area is found from %u, %u to %u, %u \n",visible_ul_x,visible_ul_y,visible_lr_x,visible_lr_y );
		printf("Image Size is: %i, %i \n",image_size_x,image_size_y );
		printf("size of malloc in bytes = %i\n",2*image_size_x*image_size_y);

		//this section of code creates a new file name,and a handle to the file
		//for the current device to store it's image in  If the file cannot be created or
		//opened, it prints out a failure message
		char* fileName = new char[15];
		sprintf(fileName,"rawImage%d.raw",i);
		HANDLE hFile = CreateFile(fileName,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,NULL,NULL);
		if(hFile == INVALID_HANDLE_VALUE){
			printf("File Creation Failed");
			printf("%d",GetLastError());
			return 0;
		}
		printf("file for RAW image created \n");


		//this flushes the camera's CCD before exposing it/
		cont = FLIFlushRow(dev,visible_lr_y,1);


		//this section of code exposes the CCD, 
		//and returns an error message of the exposure failed.
		cont = FLIExposeFrame(dev);

		if(cont != 0){
			printf("FLIExposeFrame failed");
			return 0;
		}
		FLISetHBin(dev,2);
		FLISetVBin(dev,2);

		//in order to avoid exposure errors, this code waits to gaurentee that the 
		//shutter is closed before data is fetched from the camera.
		long timeleft=100;
		while(timeleft != 0){
			FLIGetExposureStatus(dev,&timeleft);
			printf(".");
		}
		
		//This section of code retrieves the data from the camera row by row
		//and stores that information directly into the buffer.
	
		printf("\nimage started\n");
		time_t time1,time2;
		time( &time1 );
		for(int row = 0; row < image_size_y; row++){
			cont = FLIGrabRow(dev, &img_ptr[row*image_size_x],image_size_x);
			if(cont != 0){
				printf("Image error: %d\n", cont);
			}
			printf(".");
		}
		time(&time2);


		printf("image ended\n");


			//calculate brightest pixel
		for( row =0; row < image_size_y; row++){
			for(int col = 0; col < image_size_x; col++){
				if (img_ptr[(row*image_size_y)+col] > maxVal){
					maxVal = img_ptr[(row*image_size_y)+col];
					maxX = col;
					maxY = row;
				}
			}
		}

		int offset1 = ((maxY-2)*image_size_y)+maxX-2;
		for(i = 0; i < 4;i++){
			sum_max_area += img_ptr[offset1+i];
		}
		offset1 = ((maxY-1)*image_size_y)+maxX-2;
		for(i = 0; i < 4;i++){
			sum_max_area += img_ptr[offset1+i];
		}
		offset1 = (maxY*image_size_y)+maxX-2;
		for(i = 0; i < 4;i++){
			sum_max_area += img_ptr[offset1+i];
		}
		offset1 = ((maxY+1)*image_size_y)+maxX-2;
		for(i = 0; i < 4;i++){
			sum_max_area += img_ptr[offset1+i];
		}

		offset1 = ((maxY+2)*image_size_y)+maxX-2;
		for(i = 0; i < 4;i++){
			sum_max_area += img_ptr[offset1+i];
		}
		offset1 = ((maxY+3)*image_size_y)+maxX-2;
		for(i = 0; i < 4;i++){
			sum_max_area += img_ptr[offset1+i];
		}

		sum_max_area /= 24;
		
		printf("***************\n");
		printf("***************\n");
		printf("***************\n");
		printf("***************\n");
		printf("maxX,Y %d ,%d \n", maxX, maxY);
		printf("Regional analysis\n");
		printf(" sum_max_area  = %d\n", sum_max_area);


		//this section of code writes the buffered image into a file.
		//in case of failure, the last error message is printed to screen
		//in case of write success, the number of bytes written is displayed
		unsigned long num_written = 0;
		if(!WriteFile(hFile,img_ptr,2*image_size_x*image_size_y,&num_written,NULL)){
			printf("Last Error %d \n",GetLastError());
			return 0;
		}
		printf("bytes written: %u \n",num_written);
		printf("started  %s\n", ctime( &time1 ) );
		printf("ended  %s\n", ctime( &time2 ) );

		i++;
		//this prepares the next item for running through the while loop
		cont = FLIListNext(&domain,device_type, 25,device_name,25);
	}

	//this deletes the FLI List to avoid memory leaks,
	//and returns 0
	FLIDeleteList();
	return 0;
}
