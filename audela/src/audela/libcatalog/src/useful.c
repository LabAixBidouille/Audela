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
		double* const magBright, double* const magFaint) {


	if((argc == 2) && (strcmp(argv[1],"-h") == 0)) {
		sprintf(outputLogChar,"Help usage: %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) ?magnitudeBright(mag)? ?magnitudeFaint(mag)?",
				argv[0]);
		return (1);
	}

	if((argc != 5) && (argc != 6) && (argc != 7)) {
		sprintf(outputLogChar,"usage: %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) ?magnitudeBright(mag)? ?magnitudeFaint(mag)?",
				argv[0]);
		return (1);
	}

	/* Read inputs */
	sprintf(pathToCatalog,"%s",argv[1]);
	*ra             = atof(argv[2]);
	*dec            = atof(argv[3]);
	*radius         = atof(argv[4]);
	if(argc == 6) {
		*magBright  = atof(argv[5]);
		*magFaint   = 99.999;
	} else if(argc == 7) {
		*magBright  = atof(argv[5]);
		*magFaint   = atof(argv[6]);
	} else {
		*magBright  = -99.999;
		*magFaint   = 99.999;
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
 * PURPOSE  Get a value made of 'length' bits
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
 * PURPOSE  Get a value made of 'length' bits,
 * extra values being in a dedicate array
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
 * PURPOSE  Get a value made of 'length' bits,
 * extra values being in a dedicate array
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

/**
 * Fill the search zone {RA,DEC} in MAS
 */
void fillSearchZoneRaDecMas(searchZoneRaDecMas* const theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin) {

	const double radiusInDeg           = radiusInArcMin / DEG2ARCMIN;
	double ratio;
	double tmpValue;
	double radiusRa;

	theSearchZone->decStartInMas       = (int)(DEG2MAS * (decInDeg - radiusInDeg));
	theSearchZone->decEndInMas         = (int)(DEG2MAS * (decInDeg + radiusInDeg));

	if((theSearchZone->decStartInMas  <= DEC_SOUTH_POLE_MAS) && (theSearchZone->decEndInMas >= DEC_NORTH_POLE_MAS)) {

		theSearchZone->decStartInMas   = DEC_SOUTH_POLE_MAS + 1;
		theSearchZone->decEndInMas     = DEC_NORTH_POLE_MAS - 1;
		theSearchZone->raStartInMas    = START_RA_MAS;
		theSearchZone->raEndInMas      = COMPLETE_RA_MAS;
		theSearchZone->isArroundZeroRa = 0;

	} else if(theSearchZone->decStartInMas <= DEC_SOUTH_POLE_MAS) {

		theSearchZone->decStartInMas        = DEC_SOUTH_POLE_MAS + 1;
		theSearchZone->raStartInMas         = START_RA_MAS;
		theSearchZone->raEndInMas           = COMPLETE_RA_MAS;
		theSearchZone->isArroundZeroRa      = 0;

	} else if(theSearchZone->decEndInMas   >= DEC_NORTH_POLE_MAS) {

		theSearchZone->decEndInMas          = DEC_NORTH_POLE_MAS - 1;
		theSearchZone->raStartInMas         = START_RA_MAS;
		theSearchZone->raEndInMas           = COMPLETE_RA_MAS;
		theSearchZone->isArroundZeroRa      = 0;

	} else {

		radiusRa                           = radiusInDeg / cos(decInDeg * DEC2RAD);
		tmpValue                           = DEG2MAS * (raInDeg  - radiusRa);
		ratio                              = tmpValue / COMPLETE_RA_MAS;
		ratio                              = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                          -= ratio;
		theSearchZone->raStartInMas        = (int)tmpValue;

		tmpValue                           = DEG2MAS * (raInDeg  + radiusRa);
		ratio                              = tmpValue / COMPLETE_RA_MAS;
		ratio                              = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                          -= ratio;
		theSearchZone->raEndInMas          = (int)tmpValue;

		theSearchZone->isArroundZeroRa     = 0;

		if(theSearchZone->raStartInMas     >  theSearchZone->raEndInMas) {
			theSearchZone->isArroundZeroRa = 1;
		}
	}

	if(DEBUG) {
		printf("mySearchZonePPMX.decStart            = %d\n",theSearchZone->decStartInMas);
		printf("mySearchZonePPMX.decEnd              = %d\n",theSearchZone->decEndInMas);
		printf("mySearchZonePPMX.raStart             = %d\n",theSearchZone->raStartInMas);
		printf("mySearchZonePPMX.raEnd               = %d\n",theSearchZone->raEndInMas);
		printf("mySearchZonePPMX.isArroundZeroRa     = %d\n",theSearchZone->isArroundZeroRa);
	}
}

/**
 * Fill the search zone {RA,SPD} in MAS
 */
void fillSearchZoneRaSpdMas(searchZoneRaSpdMas* const theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin) {

	const double radiusInDeg     = radiusInArcMin / DEG2ARCMIN;
	double ratio;
	double tmpValue;
	double radiusRa;

	theSearchZone->spdStartInMas = (int)(DEG2MAS * (decInDeg - DEC_SOUTH_POLE_DEG - radiusInDeg));
	theSearchZone->spdEndInMas   = (int)(DEG2MAS * (decInDeg - DEC_SOUTH_POLE_DEG + radiusInDeg));

	if((theSearchZone->spdStartInMas  <= DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) && (theSearchZone->spdEndInMas >= DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS)) {

		theSearchZone->spdStartInMas        = 0;
		theSearchZone->spdEndInMas          = DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS - 1;
		theSearchZone->raStartInMas         = START_RA_MAS;
		theSearchZone->raEndInMas           = COMPLETE_RA_MAS;
		theSearchZone->isArroundZeroRa      = 0;

	} else if(theSearchZone->spdStartInMas <= DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) {

		theSearchZone->spdStartInMas        = 0;
		theSearchZone->raStartInMas         = START_RA_MAS;
		theSearchZone->raEndInMas           = COMPLETE_RA_MAS;
		theSearchZone->isArroundZeroRa      = 0;

	} else if(theSearchZone->spdEndInMas   >= DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS) {

		theSearchZone->spdEndInMas          = DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS - 1;
		theSearchZone->raStartInMas         = START_RA_MAS;
		theSearchZone->raEndInMas           = COMPLETE_RA_MAS;
		theSearchZone->isArroundZeroRa      = 0;

	} else {

		radiusRa                        = radiusInDeg / cos(decInDeg * DEC2RAD);
		tmpValue                        = DEG2MAS * (raInDeg  - radiusRa);
		ratio                           = tmpValue / COMPLETE_RA_MAS;
		ratio                           = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                       -= ratio;
		theSearchZone->raStartInMas  = (int)tmpValue;

		tmpValue                        = DEG2MAS * (raInDeg  + radiusRa);
		ratio                           = tmpValue / COMPLETE_RA_MAS;
		ratio                           = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                       -= ratio;
		theSearchZone->raEndInMas    = (int)tmpValue;

		theSearchZone->isArroundZeroRa      = 0;

		if(theSearchZone->raStartInMas      >  theSearchZone->raEndInMas) {
			theSearchZone->isArroundZeroRa  = 1;
		}
	}

	if(DEBUG) {
		printf("theSearchZone->spdStart        = %d\n",theSearchZone->spdStartInMas);
		printf("theSearchZone->spdEnd          = %d\n",theSearchZone->spdEndInMas);
		printf("theSearchZone->raStart         = %d\n",theSearchZone->raStartInMas);
		printf("theSearchZone->raEnd           = %d\n",theSearchZone->raEndInMas);
		printf("theSearchZone->isArroundZeroRa = %d\n",theSearchZone->isArroundZeroRa);
	}
}

/**
 * Fill the search zone {RA,DEC} in Micro DEG
 */
void fillSearchZoneRaDecMicroDeg(searchZoneRaDecMicroDeg* const theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin) {

	const double radiusInDeg                = radiusInArcMin / DEG2ARCMIN;
	double ratio;
	double tmpValue;
	double radiusRa;

	const int decNorthPoleInMicroDegree     = (int) (DEG2MICRODEG * DEC_NORTH_POLE_DEG);
	const int decSouthPoleInMicroDegree     = (int) (DEG2MICRODEG * DEC_SOUTH_POLE_DEG);

	theSearchZone->decStartInMicroDegree    = (int)(DEG2MICRODEG * (decInDeg - radiusInDeg));
	theSearchZone->decEndInMicroDegree      = (int)(DEG2MICRODEG * (decInDeg + radiusInDeg));

	if((theSearchZone->decStartInMicroDegree  <= decSouthPoleInMicroDegree) &&
			(theSearchZone->decEndInMicroDegree >= decNorthPoleInMicroDegree)) {

		theSearchZone->decStartInMicroDegree      = decSouthPoleInMicroDegree + 1;
		theSearchZone->decEndInMicroDegree        = decNorthPoleInMicroDegree - 1;
		theSearchZone->raStartInMicroDegree       = (int) (DEG2MICRODEG * START_RA_DEG);
		theSearchZone->raEndInMicroDegree         = (int) (DEG2MICRODEG * COMPLETE_RA_DEG);
		theSearchZone->isArroundZeroRa            = 0;

	} else if(theSearchZone->decStartInMicroDegree <= decSouthPoleInMicroDegree) {

		theSearchZone->decStartInMicroDegree      = decSouthPoleInMicroDegree + 1;
		theSearchZone->raStartInMicroDegree       = (int) (DEG2MICRODEG * START_RA_DEG);
		theSearchZone->raEndInMicroDegree         = (int) (DEG2MICRODEG * COMPLETE_RA_DEG);
		theSearchZone->isArroundZeroRa            = 0;

	} else if(theSearchZone->decEndInMicroDegree >= decNorthPoleInMicroDegree) {

		theSearchZone->decEndInMicroDegree        = decNorthPoleInMicroDegree - 1;
		theSearchZone->raStartInMicroDegree       = (int) (DEG2MICRODEG * START_RA_DEG);
		theSearchZone->raEndInMicroDegree         = (int) (DEG2MICRODEG * COMPLETE_RA_DEG);
		theSearchZone->isArroundZeroRa            = 0;

	} else {

		radiusRa                                = radiusInDeg / cos(decInDeg * DEC2RAD);
		tmpValue                                = raInDeg  - radiusRa;
		ratio                                   = tmpValue / COMPLETE_RA_DEG;
		ratio                                   = floor(ratio) * COMPLETE_RA_DEG;
		tmpValue                               -= ratio;
		theSearchZone->raStartInMicroDegree     = (int)floor(DEG2MICRODEG * tmpValue);

		tmpValue                                = raInDeg  + radiusRa;
		ratio                                   = tmpValue / COMPLETE_RA_DEG;
		ratio                                   = floor(ratio) * COMPLETE_RA_DEG;
		tmpValue                               -= ratio;
		theSearchZone->raEndInMicroDegree       = (int)ceil(DEG2MICRODEG * tmpValue);

		theSearchZone->isArroundZeroRa         = 0;

		if(theSearchZone->raStartInMicroDegree >  theSearchZone->raEndInMicroDegree) {
			theSearchZone->isArroundZeroRa     = 1;
		}
	}

	if(DEBUG) {
		printf("mySearchZoneUcac3.decStart        = %d\n",theSearchZone->decStartInMicroDegree);
		printf("mySearchZoneUcac3.spdEnd          = %d\n",theSearchZone->decEndInMicroDegree);
		printf("mySearchZoneUcac3.raStart         = %d\n",theSearchZone->raStartInMicroDegree);
		printf("mySearchZoneUcac3.raEnd           = %d\n",theSearchZone->raEndInMicroDegree);
		printf("mySearchZoneUcac3.isArroundZeroRa = %d\n",theSearchZone->isArroundZeroRa);
	}

}

/**
 * Fill the search zone {RA,SPD} in CAS
 */
void fillSearchZoneRaSpdCas(searchZoneRaSpdCas* const theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin) {

	double ratio;
	double tmpValue;
	double radiusRa;

	const double radiusInDeg     = radiusInArcMin / DEG2ARCMIN;
	theSearchZone->spdStartInCas = (int)(DEG2CAS * (decInDeg - DEC_SOUTH_POLE_DEG - radiusInDeg));
	theSearchZone->spdEndInCas   = (int)(DEG2CAS * (decInDeg - DEC_SOUTH_POLE_DEG + radiusInDeg));

	if((theSearchZone->spdStartInCas  <= DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_CAS) && (theSearchZone->spdEndInCas >= DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_CAS)) {

		theSearchZone->spdStartInCas   = 0;
		theSearchZone->spdEndInCas     = DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_CAS - 1;
		theSearchZone->raStartInCas               = START_RA_CAS;
		theSearchZone->raEndInCas                 = COMPLETE_RA_CAS;
		theSearchZone->isArroundZeroRa            = 0;

	} else if(theSearchZone->spdStartInCas <= DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_CAS) {

		theSearchZone->spdStartInCas        = 0;
		theSearchZone->raStartInCas                    = START_RA_CAS;
		theSearchZone->raEndInCas                      = COMPLETE_RA_CAS;
		theSearchZone->isArroundZeroRa                 = 0;

	} else if(theSearchZone->spdEndInCas >= DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_CAS) {

		theSearchZone->spdEndInCas        = DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_CAS;
		theSearchZone->raStartInCas                  = START_RA_CAS;
		theSearchZone->raEndInCas                    = COMPLETE_RA_CAS;
		theSearchZone->isArroundZeroRa               = 0;

	} else {

		radiusRa                               = radiusInDeg / cos(decInDeg * DEC2RAD);
		tmpValue                               = DEG2CAS * (raInDeg  - radiusRa);
		ratio                                  = tmpValue / COMPLETE_RA_CAS;
		ratio                                  = floor(ratio) * COMPLETE_RA_CAS;
		tmpValue                              -= ratio;
		theSearchZone->raStartInCas        = (int)tmpValue;

		tmpValue                               = DEG2CAS * (raInDeg  + radiusRa);
		ratio                                  = tmpValue / COMPLETE_RA_CAS;
		ratio                                  = floor(ratio) * COMPLETE_RA_CAS;
		tmpValue                              -= ratio;
		theSearchZone->raEndInCas          = (int)tmpValue;

		theSearchZone->isArroundZeroRa     = 0;

		if(theSearchZone->raStartInCas     >  theSearchZone->raEndInCas) {
			theSearchZone->isArroundZeroRa = 1;
		}
	}

	if(DEBUG) {
		printf("mySearchZoneUsnoa2.spdStart                         = %d\n",theSearchZone->spdStartInCas);
		printf("mySearchZoneUsnoa2.spdEnd                           = %d\n",theSearchZone->spdEndInCas);
		printf("mySearchZoneUsnoa2.raStart                          = %d\n",theSearchZone->raStartInCas);
		printf("mySearchZoneUsnoa2.raEnd                            = %d\n",theSearchZone->raEndInCas);
		printf("mySearchZoneUsnoa2.isArroundZeroRa                  = %d\n",theSearchZone->isArroundZeroRa);
	}
}

/**
 * Fill the magnitude box in milli magnitude
 */
void fillMagnitudeBoxMilliMag(magnitudeBoxMilliMag* const magnitudeBox, const double magMin, const double magMax) {

	magnitudeBox->magnitudeStartInMilliMag = (int)(MAG2MILLIMAG * magMin);
	magnitudeBox->magnitudeEndInMilliMag   = (int)(MAG2MILLIMAG * magMax);

	if(DEBUG) {
		printf("mySearchZonePPMX.magnitudeStart      = %d\n",magnitudeBox->magnitudeStartInMilliMag);
		printf("mySearchZonePPMX.magnitudeEnd        = %d\n",magnitudeBox->magnitudeEndInMilliMag);
	}
}

/**
 * Fill the magnitude box in Centi magnitude
 */
void fillMagnitudeBoxCentiMag(magnitudeBoxCentiMag* const magnitudeBox, const double magMin, const double magMax) {

	magnitudeBox->magnitudeStartInCentiMag = (short int)(MAG2CENTIMAG * magMin);
	magnitudeBox->magnitudeEndInCentiMag   = (short int)(MAG2CENTIMAG * magMax);

	if(DEBUG) {
		printf("mySearchZonePPMX.magnitudeStart      = %d\n",magnitudeBox->magnitudeStartInCentiMag);
		printf("mySearchZonePPMX.magnitudeEnd        = %d\n",magnitudeBox->magnitudeEndInCentiMag);
	}
}

/**
 * Fill the magnitude box in Deci magnitude
 */
void fillMagnitudeBoxDeciMag(magnitudeBoxDeciMag* const magnitudeBox, const double magMin, const double magMax) {

	magnitudeBox->magnitudeStartInDeciMag = (short int)(MAG2DECIMAG * magMin);
	magnitudeBox->magnitudeEndInDeciMag   = (short int)(MAG2DECIMAG * magMax);

	if(DEBUG) {
		printf("mySearchZonePPMX.magnitudeStart      = %d\n",magnitudeBox->magnitudeStartInDeciMag);
		printf("mySearchZonePPMX.magnitudeEnd        = %d\n",magnitudeBox->magnitudeEndInDeciMag);
	}
}

/**
 * Find the component in sortedArrayOfValues for which value is in [array(component),array(component+1)] by dichotomy
 * Adapted from Francois Ochsenbein's method : binloc
 */
int findComponentNumber(const int* const sortedArrayOfValues, const int lengthOfArray, const int value) {

	int lowerIndex      = 0;
	const int lastIndex = lengthOfArray - 1;
	int higherIndex     = lastIndex;
	int medianValue;
	int medianIndex;
	int deltaIndex;

	if (value < sortedArrayOfValues[lowerIndex]) {
		return(-1);
	}

	if (value >= sortedArrayOfValues[lastIndex]) {
		return(lastIndex);
	}

	deltaIndex = higherIndex - lowerIndex;

	while (deltaIndex > 1) {

		medianIndex     = lowerIndex + deltaIndex / 2 ;
		medianValue     = sortedArrayOfValues[medianIndex];

		if (value       < medianValue) {
			higherIndex = medianIndex;
		} else {
			lowerIndex  = medianIndex ;
		}

		deltaIndex      = higherIndex - lowerIndex;
	}

	return (lowerIndex) ;
}

/*
 * Francois Ochsenbein's method
 * PURPOSE  Locate specified character
 * RETURNS  Index of located char
*/
int strloc(char * const text, const int c) {

	char *s;
	for (s = text; *s; s++) {
		if (*s == c) {
			break;
		}
	}
	return(s-text);
}
