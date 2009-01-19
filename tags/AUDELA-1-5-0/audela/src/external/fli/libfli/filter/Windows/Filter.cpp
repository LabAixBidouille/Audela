// Filter.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "conio.h"
#include "stdafx.h"
#include "E:/dev/Software/libfli/lib/libfli.h"


/**
	This simply forces the user to press a key to close the program
*/
void _cdecl end(void)
{
	printf("\nPress any key to exit.\n");
	while(!kbhit());
	return;
}
int main(int argc, char* argv[])
{
	char version[1024];
	flidev_t dev;
	long domain;
	long cont = 0;
	char* device_name = new char[30];
	char* device_type = new char[30];

	domain = FLIDEVICE_FILTERWHEEL;

	printf("Hello World!\n");

	printf("/*************** Filter test Program*****************\\\n\n");
	
	//Initial Camera Information
	//This displays sets the Debug to the highest level then reads and displays the version of the fli-lib
	printf("Debug level set to FLIDEBUG_ALL\n");
	printf("Debug is sending informaiton to be logged at  C:\\flidebug.txt\n");
	FLISetDebugLevel("C:\\flidebug.txt", FLIDEBUG_ALL);	
	FLIGetLibVersion(version, 1023);
	printf("%s\n", version);

	//This creates an FLI Device List within the fli API 
	//this list contains all of the FLI items that match the type
	//give in domain. In this case the type is USB Camera
	cont = FLICreateList(domain);
	if(cont != 0){
		printf("FLIFilter CreateList failed ");
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
		printf("ListFirst Failed");
		i++;
	 	cont =FLIListNext(&domain,device_type, 25,device_name,25);

	}
	// this prints the proper name of the current device to the screen
	printf("Found USB FilterWheel: %s \n", device_name);
	
	cont = FLIOpen( &dev, device_type, domain);
	if(cont == 0){
		FLISetFilterPos (dev,0);
		printf("pos 0\n");
		FLISetFilterPos (dev,1);
		printf("pos 1\n");
		FLISetFilterPos (dev,2);
		printf("pos 2\n");
		FLISetFilterPos (dev,3);
		printf("pos 3\n");
		FLISetFilterPos (dev,4);
		printf("pos 4\n");
	}





	return 0;
}

