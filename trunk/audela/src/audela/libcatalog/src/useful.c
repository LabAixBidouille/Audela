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
		sprintf(outputLogChar,"Help usage: %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) magnitudeMin(mag)? magnitudeMax(mag)?",
				argv[0]);
		return (1);
	}

	if((argc != 5) && (argc != 7)) {
		sprintf(outputLogChar,"usage: %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) magnitudeMax(mag)? magnitudeMin(mag)?",
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
		*magMin   = -99.999;
		*magMax   = 99.999;
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
short convertBig2LittleEndianForShort(short int l) {

	return ((((l)&0xff)<<8) | (((l)&0xff00)>>8));
}

/*============================================================*/
/* Transform array of Big to Little Endian (and vice versa ). */
/*============================================================*/
void convertBig2LittleEndianForArrayOfShort(short int* const inputArray, const int length) {

	int index;
	for(index = 0; index < length; index++) {
		inputArray[index] = convertBig2LittleEndianForShort(inputArray[index]);
	}
}

/*============================================================*/
/* Sum components of an integer array */
/*============================================================*/
int sumNumberOfElements(const int* const inputArray,const int indexStart,const int indexEnd) {

	int sumOfElements = 0;
	int index;

	for(index = indexStart; index <= indexEnd; index++) {
		sumOfElements += inputArray[index];
	}

	return (sumOfElements);
}

/*============================================================
 * Francois Ochsenbein's method (get_bits)
 * PURPOSE  Get a value made of 'len' bits
 * starting from byte position 'a', bit offset 'b'.
 * RETURNS  The value
 * REMARKS  Independent of the architecture.
 *============================================================*/
int getBits(unsigned char * const a, const int b, const int length) {

	static unsigned int mask[] = {
			0x00      , 0x01      , 0x03      , 0x07      ,
			0x0f      , 0x1f      , 0x3f      , 0x7f      ,
			0x00ff    , 0x01ff    , 0x03ff    , 0x07ff    ,
			0x0fff    , 0x1fff    , 0x3fff    , 0x7fff    ,
			0x00ffff  , 0x01ffff  , 0x03ffff  , 0x07ffff  ,
			0x0fffff  , 0x1fffff  , 0x3fffff  , 0x7fffff  ,
			0x00ffffff, 0x01ffffff, 0x03ffffff, 0x07ffffff,
			0x0fffffff, 0x1fffffff, 0x3fffffff, 0x7fffffff,
			0xffffffff } ;
	int value;
	unsigned char *ac;
	int nb ;      /* remaining bits to get */

	ac    = a + (b>>3);    /* Byte position  */
	value = *(ac++);       /* Initialisation */
	nb    = length;           /* Bits to read.  */
	nb   -= 8 - (b&7);     /* Useful bits    */

	/* We don't care about the leftmost bits,
       these will be removed at the end
       (we assume that len <= 32...)
	 */

	while (nb >= 8) {
		value = (value<<8) | *(ac++);
		nb   -= 8;
	}
	if (nb < 0) {         /* I've read too much */
		value >>= (-nb);
	} else if (nb) {        /* Remainder bits  */
		value = (value<<nb) | (*ac >> (8-nb));
	}

	return (value & mask[length]);
}

/*============================================================
 * Francois Ochsenbein's method
 * PURPOSE  Get a value made of 'len' bits, extra values being in a dedicate array
 * RETURNS  The value
 *============================================================*/
int xget4(unsigned char * const a, const int b, const int length, const int max, const int * const xtra4) {

	int value;
	value = getBits(a, b, length);
	if (value <= max) {
		return(value);
	}
	value = xtra4[value-(max+1)];

	return(value);
}

/*============================================================
 * Francois Ochsenbein's method
 * PURPOSE  Get a value made of 'len' bits, extra values being in a dedicate array
 * RETURNS  The value
 *============================================================*/
int xget2(unsigned char * const a, const int b, const int length, const int max, const short int* const xtra2) {

	int value;
	value = getBits(a, b, length);

	if (value <= max) {
		return(value);
	}
	value = xtra2[value-(max+1)];

	return(value);
}
