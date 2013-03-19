/*
 * useful.c
 *
 *  Created on: Dec 19, 2011
 *      Author: Y. Damerdji
 */

#include "useful.h"

/*=========================================================*/
/* Decode inputs */
/*=========================================================*/
int decodeInputs(char* const outputLogChar, const int argc, char* const argv[],
		char* const pathToCatalog, double* const ra, double* const dec, double* const radius,
		double* const magMin, double* const magMax) {


	if((argc == 2) && (strcmp(argv[1],"-h") == 0)) {
		sprintf(outputLogChar,"Help usage : %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) magnitudeMin(mag)? magnitudeMax(mag)?",
				argv[0]);
		return (1);
	}

	if((argc != 5) && (argc != 7)) {
		sprintf(outputLogChar,"usage : %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) magnitudeMax(mag)? magnitudeMin(mag)?",
				argv[0]);
		return (1);
	}

	/* Read inputs */
	sprintf(pathToCatalog,"%s",argv[1]);
	*ra            = atof(argv[2]);
	*dec           = atof(argv[3]);
	*radius        = atof(argv[4]);
	if(argc == 7) {
		*magMin   = atof(argv[5]);
		*magMax   = atof(argv[6]);
	} else {
		*magMin   = -99.99;
		*magMax   = 99.99;
	}

	/* Add slash to the end of the path if not exist*/
	addLastSlashToPath(pathToCatalog);

	return (0);
}

/*=========================================================*/
/* Free memory of a double pointer array                   */
/*=========================================================*/
void releaseDoubleArray(void** theTwoDArray, const int firstDimension) {

	int index;

	if(theTwoDArray != NULL) {

		index = 0;

		while(index < firstDimension) {

			if(theTwoDArray[index] != NULL) {
				releaseSimpleArray(theTwoDArray[index]);
			}

			index++;
		}

		free(theTwoDArray);
		theTwoDArray = NULL;
	}
}

/*=========================================================*/
/* Free memory of a simple array                           */
/*=========================================================*/
void releaseSimpleArray(void* theOneDArray) {

	if(theOneDArray != NULL) {
		free(theOneDArray);
		theOneDArray = NULL;
	}
}

/*=========================================================*/
/* Add a slash to the end of a path if not exist           */
/*=========================================================*/
void addLastSlashToPath(char* onePath) {

	char slash[3];

#if defined(LIBRARY_DLL)
	sprintf(slash,"\\");
#else
	sprintf(slash,"/");
#endif

	if (strlen(onePath) > 0) {
		if (onePath[strlen(onePath)-1] != slash[0] ) {
			strcat(onePath,slash);
		}
	}
}

/*=========================================================*/
/* Transform Big to Little Endian (and vice versa ).       */
/*=========================================================*/
int convertBig2LittleEndianForInteger(int l) {

	return ((l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF));
}

/*===========================================================*/
/* Transform array of Big to Little Endian (and vice versa ) */
/*===========================================================*/
void convertBig2LittleEndianForArrayOfInteger(int* const inputArray, const int length) {

	int index;
	for(index = 0; index < length; index++) {
		inputArray[index] = convertBig2LittleEndianForInteger(inputArray[index]);
	}
}

/*=========================================================*/
/* Transform Big to Little Endian (and vice versa ).       */
/*=========================================================*/
short convertBig2LittleEndianForShort(short l) {

	return ((((l)&0xff)<<8) | (((l)&0xff00)>>8));
}

/*============================================================*/
/* Transform array of Big to Little Endian (and vice versa ). */
/*============================================================*/
void convertBig2LittleForArrayOfShort(short* const inputArray, const int length) {

	int index;
	for(index = 0; index < length; index++) {
		inputArray[index] = convertBig2LittleEndianForShort(inputArray[index]);
	}
}


