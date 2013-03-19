/*
 * ppmx.c
 *
 *  Created on: 18/03/2013
 *      Author: Y. Damerdji
 */
#include "ppmx.h"

static char *ppxZoneNames[] = {"0000", "0730", "1500", "2230", "3000", "3730",
		"4500", "5230", "6000", "6730", "7500", "8230" };

static char outputLogChar[STRING_COMMON_LENGTH];
static char binaryHeader[PPMX_HEADER_LENGTH];

/**
 * Cone search on PPMX catalog
 */
int cmd_tcl_csppmx(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	int indexOfFile;
	int resultOfFunction;
	searchZonePPMX mySearchZonePPMX;
	char binaryFileName[STRING_COMMON_LENGTH];
	Tcl_DString dsptr;

	/* Decode inputs */
	resultOfFunction = decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMin);
	if(resultOfFunction) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Define the search zone */
	mySearchZonePPMX = findSearchZonePPMX(ra,dec,radius,magMin,magMax);
	if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* No we loop over the binary files to be opened, we process them one by one */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { PPMX { } { ID RAJ2000 DECJ2000 pmRA pmDE Cmag Rmag Jmag Hmag Kmag Nobs P sub } } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	for(indexOfFile = 0; indexOfFile < mySearchZonePPMX.numberOfBinaryFiles; indexOfFile++) {
		sprintf(binaryFileName,"%s%s",pathToCatalog,mySearchZonePPMX.binaryFileNames[indexOfFile]);
		resultOfFunction = processOneFilePPMX(&dsptr,&mySearchZonePPMX,binaryFileName);
		if(resultOfFunction) {
			Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
			return (TCL_ERROR);
		}
	}

	// end of sources list
	Tcl_DStringAppend(&dsptr,"}",-1); // end of main list
	Tcl_DStringResult(interp,&dsptr);

	/* Release memory */
	Tcl_DStringFree(&dsptr);
	releaseDoubleArray((void**)mySearchZonePPMX.binaryFileNames,mySearchZonePPMX.numberOfBinaryFiles);

	return (TCL_OK);
}

/**
 * Process one binary file
 */
int processOneFilePPMX(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX,
		const char* const binaryFileName) {

	int resultOfFunction;
	headerInformationPPMX headerInformation;;
	const int chunkStart     = mySearchZonePPMX->raStartInMas >> CHUNK_SHIFT_RA;
	const int chunkEnd       = mySearchZonePPMX->raEndInMas >> CHUNK_SHIFT_RA;
	FILE* const inputStream  = fopen(binaryFileName,"rb");
	if(inputStream == NULL) {
		sprintf(outputLogChar,"File %s not found",binaryFileName);
		return(1);
	}

	resultOfFunction = readHeaderPPMX(inputStream, &headerInformation, binaryFileName);
	if(resultOfFunction) {
		return(1);
	}






	/* Close all and release memory */
	fclose(inputStream);
	releaseSimpleArray(headerInformation.extraValues2);
	releaseSimpleArray(headerInformation.extraValues4);
	releaseSimpleArray(headerInformation.chunkOffsets);
	releaseSimpleArray(headerInformation.chunkNumberOfStars);

	return (0);
}

/**
 * Read the header information in the binary file
 */
int readHeaderPPMX(FILE* const inputStream, headerInformationPPMX* const headerInformation,
		const char* const binaryFileName) {

	int index;
	int indexPlusOne;
	int sumOfStar;
	int lastIndex;
	char fileNameInHeader[PPMX_HEADER_LENGTH];
	int totalNumberOfStars;
	int resultOfFunction = fread(binaryHeader,sizeof(char),PPMX_HEADER_LENGTH,inputStream);

	if(resultOfFunction != PPMX_HEADER_LENGTH) {
		sprintf(outputLogChar,"Error when reading the header from the binary file %s",binaryFileName);
		return(1);
	}

	sscanf(binaryHeader,PPMX_HEADER_FORMAT,fileNameInHeader,&totalNumberOfStars,
			&(headerInformation->lengthOfAcceleratorTable),&(headerInformation->numberOfExtra4),
			&(headerInformation->numberOfExtra2),&(headerInformation->decStartInMas));

	if(DEBUG) {
		printf("binaryHeader                                = %s\n",binaryHeader);
		printf("totalNumberOfStars                          = %d\n",totalNumberOfStars);
		printf("headerInformation->lengthOfAcceleratorTable = %d\n",headerInformation->lengthOfAcceleratorTable);
		printf("headerInformation->numberOfExtra4           = %d\n",headerInformation->numberOfExtra4);
		printf("headerInformation->numberOfExtra2           = %d\n",headerInformation->numberOfExtra2);
		printf("headerInformation->decStartInMas            = %d\n",headerInformation->decStartInMas);
	}

	/* Allocate memory */
	headerInformation->chunkOffsets = (int*)malloc(headerInformation->lengthOfAcceleratorTable * sizeof(int));
	if(headerInformation->chunkOffsets == NULL) {
		sprintf(outputLogChar,"headerInformation->chunkOffsets = %d(int) out of memory",headerInformation->lengthOfAcceleratorTable);
		return(1);
	}
	headerInformation->chunkNumberOfStars = (int*)malloc(headerInformation->lengthOfAcceleratorTable * sizeof(int));
	if(headerInformation->chunkNumberOfStars == NULL) {
		sprintf(outputLogChar,"headerInformation->chunkNumberOfStars = %d(int) out of memory",headerInformation->lengthOfAcceleratorTable);
		return(1);
	}
	headerInformation->extraValues2 = (short*)malloc(headerInformation->numberOfExtra2 * sizeof(short));
	if(headerInformation->extraValues2 == NULL) {
		sprintf(outputLogChar,"headerInformation->extraValues2 = %d(short) out of memory",headerInformation->numberOfExtra2);
		return(1);
	}
	headerInformation->extraValues4 = (int*)malloc(headerInformation->numberOfExtra4 * sizeof(int));
	if(headerInformation->extraValues4 == NULL) {
		sprintf(outputLogChar,"headerInformation->extraValues4 = %d(int) out of memory",headerInformation->numberOfExtra4);
		return(1);
	}

	/* Read from file */
	resultOfFunction = fread(headerInformation->chunkOffsets,sizeof(int),headerInformation->lengthOfAcceleratorTable,inputStream);
	if(resultOfFunction != headerInformation->lengthOfAcceleratorTable) {
		sprintf(outputLogChar,"Error when reading headerInformation->chunkOffsets from the binary file %s",binaryFileName);
		return(1);
	}
	resultOfFunction = fread(headerInformation->extraValues2,sizeof(short),headerInformation->numberOfExtra2,inputStream);
	if(resultOfFunction != headerInformation->numberOfExtra2) {
		sprintf(outputLogChar,"Error when reading headerInformation->extraValues2 from the binary file %s",binaryFileName);
		return(1);
	}
	resultOfFunction = fread(headerInformation->extraValues4,sizeof(int),headerInformation->numberOfExtra4,inputStream);
	if(resultOfFunction != headerInformation->numberOfExtra4) {
		sprintf(outputLogChar,"Error when reading headerInformation->extraValues4 from the binary file %s",binaryFileName);
		return(1);
	}

	/* Swap values because data is written in Big_endian */
	convertBig2LittleEndianForArrayOfInteger(headerInformation->chunkOffsets,headerInformation->lengthOfAcceleratorTable);
	convertBig2LittleEndianForArrayOfInteger(headerInformation->extraValues4,headerInformation->numberOfExtra4);
	convertBig2LittleEndianForArrayOfShort(headerInformation->extraValues2,headerInformation->numberOfExtra2);

	lastIndex      = headerInformation->lengthOfAcceleratorTable - 1;
	sumOfStar      = 0;
	index          = 0;
	indexPlusOne   = 1;
	while(index    < lastIndex) {
		headerInformation->chunkNumberOfStars[index] =
				(headerInformation->chunkOffsets[indexPlusOne] - headerInformation->chunkOffsets[index]) / PPMX_RECORD_LENGTH;
		sumOfStar += headerInformation->chunkNumberOfStars[index];
		index      = indexPlusOne;
		indexPlusOne++;
	}

	headerInformation->chunkNumberOfStars[lastIndex] = totalNumberOfStars - sumOfStar;
	if(headerInformation->chunkNumberOfStars[lastIndex] < 0) {
		sprintf(outputLogChar,"The number of stars is not coherent in %s",binaryFileName);
		releaseSimpleArray(headerInformation->extraValues2);
		releaseSimpleArray(headerInformation->extraValues4);
		releaseSimpleArray(headerInformation->chunkOffsets);
		releaseSimpleArray(headerInformation->chunkNumberOfStars);
		return(1);
	}

	return (0);
}

/**
 * Find the search zone having its center on (ra,dec) with a radius of radius
 */
const searchZonePPMX findSearchZonePPMX(const double raInDeg,const double decInDeg,
		const double radiusInArcMin,const double magMin, const double magMax) {

	searchZonePPMX mySearchZonePPMX;
	const double radiusInDeg                    = radiusInArcMin / DEG2ARCMIN;
	double ratio;
	double tmpValue;
	double radiusRa;
	int indexStarDec;
	int indexEndDec;
	int indexDec;
	int counter;

	mySearchZonePPMX.declinationStartInMas      = (int)(DEG2MAS * (decInDeg - radiusInDeg));
	mySearchZonePPMX.declinationEndInMas        = (int)(DEG2MAS * (decInDeg + radiusInDeg));
	mySearchZonePPMX.magnitudeStartInMilliMag   = (int)(MAG2MILLIMAG * magMin);
	mySearchZonePPMX.magnitudeEndInMilliMag     = (int)(MAG2MILLIMAG * magMax);

	if((mySearchZonePPMX.declinationStartInMas <= DEC_SOUTH_POLE_MAS) && (mySearchZonePPMX.declinationEndInMas >= DEC_NORTH_POLE_MAS)) {

		mySearchZonePPMX.declinationStartInMas  = DEC_SOUTH_POLE_MAS;
		mySearchZonePPMX.declinationEndInMas    = DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS;
		mySearchZonePPMX.raStartInMas           = START_RA_MAS;
		mySearchZonePPMX.raEndInMas             = COMPLETE_RA_MAS;
		mySearchZonePPMX.isArroundZeroRa        = 0;

	} else if(mySearchZonePPMX.declinationStartInMas <= DEC_SOUTH_POLE_MAS) {

		mySearchZonePPMX.declinationStartInMas        = DEC_SOUTH_POLE_MAS;
		mySearchZonePPMX.raStartInMas                 = START_RA_MAS;
		mySearchZonePPMX.raEndInMas                   = COMPLETE_RA_MAS;
		mySearchZonePPMX.isArroundZeroRa              = 0;

	} else if(mySearchZonePPMX.declinationEndInMas   >= DEC_NORTH_POLE_MAS) {

		mySearchZonePPMX.declinationEndInMas          = DEC_NORTH_POLE_MAS;
		mySearchZonePPMX.raStartInMas                 = START_RA_MAS;
		mySearchZonePPMX.raEndInMas                   = COMPLETE_RA_MAS;
		mySearchZonePPMX.isArroundZeroRa              = 0;

	} else {

		radiusRa                        = radiusInDeg / cos(decInDeg * DEC2RAD);
		tmpValue                        = DEG2MAS * (raInDeg  - radiusRa);
		ratio                           = tmpValue / COMPLETE_RA_MAS;
		ratio                           = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                       -= ratio;
		mySearchZonePPMX.raStartInMas   = (int)tmpValue;

		tmpValue                        = DEG2MAS * (raInDeg  + radiusRa);
		ratio                           = tmpValue / COMPLETE_RA_MAS;
		ratio                           = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                       -= ratio;
		mySearchZonePPMX.raEndInMas     = (int)tmpValue;

		mySearchZonePPMX.isArroundZeroRa      = 0;

		if(mySearchZonePPMX.raStartInMas      >  mySearchZonePPMX.raEndInMas) {
			mySearchZonePPMX.isArroundZeroRa  = 1;
		}
	}

	/* Now we find the binary files which will opened during this process */
	if ((mySearchZonePPMX.declinationStartInMas < 0) && (mySearchZonePPMX.declinationEndInMas > 0)) {

		/* (declinationStartInMas < 0) & (declinationEndInMas > 0) */
		indexStarDec = -mySearchZonePPMX.declinationStartInMas / PPMX_DECLINATION_STEP;
		indexEndDec  = mySearchZonePPMX.declinationEndInMas / PPMX_DECLINATION_STEP;
		mySearchZonePPMX.numberOfBinaryFiles = indexStarDec + indexEndDec + 2;
		allocateMemoryForSearchZonePPMX(&mySearchZonePPMX);
		if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
			return(mySearchZonePPMX);
		}
		counter      = 0;
		/* South */
		for(indexDec = indexStarDec; indexDec >= 0; indexDec--) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],BINARY_FILE_NAME_FORMAT_SOUTH,ppxZoneNames[indexDec]);
			counter++;
		}
		/* North */
		for(indexDec = 0; indexDec <= indexEndDec; indexDec++) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],BINARY_FILE_NAME_FORMAT_NORTH,ppxZoneNames[indexDec]);
			counter++;
		}

	} else if (mySearchZonePPMX.declinationStartInMas < 0) {

		/* (declinationStartInMas < 0) & (declinationEndInMas < 0) */
		indexStarDec = -mySearchZonePPMX.declinationStartInMas / PPMX_DECLINATION_STEP;
		indexEndDec  = -mySearchZonePPMX.declinationEndInMas / PPMX_DECLINATION_STEP;
		mySearchZonePPMX.numberOfBinaryFiles = indexStarDec - indexEndDec + 1;
		allocateMemoryForSearchZonePPMX(&mySearchZonePPMX);
		if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
			return(mySearchZonePPMX);
		}
		counter      = 0;
		for(indexDec = indexStarDec; indexDec >= indexEndDec; indexDec--) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],BINARY_FILE_NAME_FORMAT_SOUTH,ppxZoneNames[indexDec]);
			counter++;
		}

	} else {

		/* (declinationStartInMas > 0) & (declinationEndInMas > 0) */
		indexStarDec = mySearchZonePPMX.declinationStartInMas / PPMX_DECLINATION_STEP;
		indexEndDec  = mySearchZonePPMX.declinationEndInMas / PPMX_DECLINATION_STEP;
		mySearchZonePPMX.numberOfBinaryFiles = indexEndDec - indexStarDec + 1;
		allocateMemoryForSearchZonePPMX(&mySearchZonePPMX);
		if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
			return(mySearchZonePPMX);
		}
		counter      = 0;
		for(indexDec = indexStarDec; indexDec <= indexEndDec; indexDec++) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],BINARY_FILE_NAME_FORMAT_NORTH,ppxZoneNames[indexDec]);
			counter++;
		}
	}

	if(DEBUG) {
		printf("mySearchZonePPMX.decStart            = %d\n",mySearchZonePPMX.declinationStartInMas);
		printf("mySearchZonePPMX.decEnd              = %d\n",mySearchZonePPMX.declinationEndInMas);
		printf("mySearchZonePPMX.raStart             = %d\n",mySearchZonePPMX.raStartInMas);
		printf("mySearchZonePPMX.raEnd               = %d\n",mySearchZonePPMX.raEndInMas);
		printf("mySearchZonePPMX.isArroundZeroRa     = %d\n",mySearchZonePPMX.isArroundZeroRa);
		printf("mySearchZonePPMX.magnitudeStart      = %d\n",mySearchZonePPMX.magnitudeStartInMilliMag);
		printf("mySearchZonePPMX.magnitudeEnd        = %d\n",mySearchZonePPMX.magnitudeEndInMilliMag);
		printf("mySearchZonePPMX.numberOfBinaryFiles = %d\n",mySearchZonePPMX.numberOfBinaryFiles);
		for(counter = 0; counter < mySearchZonePPMX.numberOfBinaryFiles; counter++) {
			printf("mySearchZonePPMX.binaryFileNames[%d] = %s\n",counter,mySearchZonePPMX.binaryFileNames[counter]);
		}
	}

	return (mySearchZonePPMX);
}

/**
 * Allocate file names in searchZonePPMX
 */
void allocateMemoryForSearchZonePPMX(searchZonePPMX* const mySearchZonePPMX) {

	int index;

	mySearchZonePPMX->binaryFileNames = (char**)malloc(mySearchZonePPMX->numberOfBinaryFiles * sizeof(char*));
	if(mySearchZonePPMX->binaryFileNames == NULL) {
		sprintf(outputLogChar,"Error : mySearchZonePPMX.binaryFileNames[%d] out of memory\n",mySearchZonePPMX->numberOfBinaryFiles);
		mySearchZonePPMX->numberOfBinaryFiles = -1;
		return;
	}

	for(index = 0; index < mySearchZonePPMX->numberOfBinaryFiles; index++) {
		mySearchZonePPMX->binaryFileNames[index] = (char*)malloc(BINARY_FILE_NAME_LENGTH * sizeof(char));
		if(mySearchZonePPMX->binaryFileNames[index] == NULL) {
			sprintf(outputLogChar,"Error : mySearchZonePPMX.binaryFileNames[%d] = %d (char) out of memory\n",index,BINARY_FILE_NAME_LENGTH);
			mySearchZonePPMX->numberOfBinaryFiles = -1;
			return;
		}
	}
}




