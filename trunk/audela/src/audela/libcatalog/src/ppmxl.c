/*
 * ppmxl.c
 *
 *  Created on: 18/03/2013
 *      Author: Y. Damerdji
 */
#include "ppmx.h"

static char outputLogChar[STRING_COMMON_LENGTH];
static char binaryHeader[PPMX_HEADER_LENGTH];
static char ppmxlFileNameSuffix[] = "abcd";

/**
 * Cone search on PPMX catalog
 */
int cmd_tcl_csppmxl(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

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
	resultOfFunction = decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax);
	if(resultOfFunction) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Define the search zone */
	mySearchZonePPMX = findSearchZonePPMXL(ra,dec,radius,magMin,magMax);
	if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* No we loop over the binary files to be opened, we process them one by one */
	Tcl_DStringInit(&dsptr);
	//TODO please fill correctly, use Aladin
	Tcl_DStringAppend(&dsptr,"{ { PPMXL { } { ID RAJ2000 DECJ2000 errRa errDec pmRA pmDE errPmRa errPmDec Cmag Rmag Bmag errBmag Vmag ErrVmag Jmag ErrJmag Hmag ErrHmag Kmag ErrKmag Nobs P sub refCatalog} } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	for(indexOfFile = 0; indexOfFile < mySearchZonePPMX.numberOfBinaryFiles; indexOfFile++) {
		sprintf(binaryFileName,"%s%s",pathToCatalog,mySearchZonePPMX.binaryFileNames[indexOfFile]);
		resultOfFunction = processOneFilePPMXL(&dsptr,&mySearchZonePPMX,binaryFileName);
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
int processOneFilePPMXL(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX,
		const char* const binaryFileName) {

	//TODO recode please
	int resultOfFunction;
	headerInformationPPMXL headerInformation;
	const int chunkStart    = mySearchZonePPMX->subSearchZone.raStartInMas >> CHUNK_SHIFT_RA;
	const int chunkEnd      = mySearchZonePPMX->subSearchZone.raEndInMas >> CHUNK_SHIFT_RA;
	FILE* const inputStream = fopen(binaryFileName,"rb");

	if(inputStream == NULL) {
		sprintf(outputLogChar,"File %s not found",binaryFileName);
		return(1);
	}

	resultOfFunction = readHeaderPPMXL(inputStream, &headerInformation, binaryFileName);
	if(resultOfFunction) {
		return(1);
	}

	if(mySearchZonePPMX->subSearchZone.isArroundZeroRa) {

		/* From chunkStart to end */
		if(processChunksPPMXL(dsptr,mySearchZonePPMX,inputStream,&headerInformation,chunkStart,headerInformation.lengthOfAcceleratorTable - 1, binaryFileName)) {
			return (1);
		}

		/* From 0 to chunkEnd */
		if(processChunksPPMXL(dsptr,mySearchZonePPMX,inputStream,&headerInformation,0,chunkEnd, binaryFileName)) {
			return (1);
		}

	} else {

		/* From chunkStart to chunkEnd */
		if(processChunksPPMXL(dsptr,mySearchZonePPMX,inputStream,&headerInformation,chunkStart,chunkEnd, binaryFileName)) {
			return (1);
		}
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
 * Process a series of successive chunks of data
 */
int processChunksPPMXL(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX,FILE* const inputStream,
		const headerInformationPPMXL* const headerInformation,const int chunkStart,const int chunkEnd, const char* const binaryFileName) {

	//TODO recode please
	unsigned char* buffer;
	unsigned char* pointerToBuffer;
	int resultOfFunction;
	int indexOfChunk;
	int indexOfStar;
	int raStart;
	int numberOfStars;
	int totalNumberOfStars;
	int sizeOfBuffer;

	/* We read all merged chunks to optimise access time to disk */
	totalNumberOfStars = sumNumberOfElements(headerInformation->chunkNumberOfStars,chunkStart,chunkEnd);
	sizeOfBuffer       = totalNumberOfStars * PPMX_RECORD_LENGTH;
	buffer             = (unsigned char*)malloc(sizeOfBuffer * sizeof(unsigned char));
	if(buffer == NULL) {
		sprintf(outputLogChar,"Buffer = %d (unsigned char) out of memory",sizeOfBuffer);
		return(1);
	}
	fseek(inputStream,headerInformation->chunkOffsets[chunkStart],SEEK_SET);
	resultOfFunction = fread(buffer,sizeof(unsigned char),sizeOfBuffer,inputStream);
	if(resultOfFunction != sizeOfBuffer) {
		sprintf(outputLogChar,"Can not read %d (char) from %s",sizeOfBuffer,binaryFileName);
		return(1);
	}

	pointerToBuffer = buffer;

	for(indexOfChunk = chunkStart; indexOfChunk <= chunkEnd; indexOfChunk++) {

		numberOfStars = headerInformation->chunkNumberOfStars[indexOfChunk];
		raStart       = indexOfChunk << CHUNK_SHIFT_RA;

		/* Loop over stars */
		for(indexOfStar = 0; indexOfStar <= numberOfStars; indexOfStar++) {
			processBufferedDataPPMXL(dsptr,mySearchZonePPMX,pointerToBuffer,headerInformation,raStart);
			/* Move the buffer to read the next star */
			pointerToBuffer += PPMX_RECORD_LENGTH;
		}
	}

	releaseSimpleArray(buffer);

	return (0);
}

/**
 * Process stars in an allocated buffer
 * This method contains the method ed_rec from Francois's code
 */
void processBufferedDataPPMXL(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX, unsigned char* buffer,
		const headerInformationPPMXL* const headerInformation, const int raStart) {

	//TODO recode please
}

/**
 * Read the header information in the binary file
 */
int readHeaderPPMXL(FILE* const inputStream, headerInformationPPMXL* const headerInformation,
		const char* const binaryFileName) {

	//TODO recode please
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

	sscanf(binaryHeader,PPMXL_HEADER_FORMAT,fileNameInHeader,&totalNumberOfStars,
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
const searchZonePPMX findSearchZonePPMXL(const double raInDeg,const double decInDeg,
		const double radiusInArcMin,const double magMin, const double magMax) {

	searchZonePPMX mySearchZonePPMX;
	int indexStarDec;
	int indexEndDec;
	int indexStarDec2;
	int indexEndDec2;
	int rest;
	int indexDec;
	int indexDec2;
	int counter;
	const int numberOfCatalogPerZone = strlen(ppmxlFileNameSuffix);

	fillSearchZoneRaDecMas(&(mySearchZonePPMX.subSearchZone), raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMilliMag(&(mySearchZonePPMX.magnitudeBox), magMin, magMax);

	/* Now we find the binary files which will opened during this process */
	if ((mySearchZonePPMX.subSearchZone.decStartInMas < 0) && (mySearchZonePPMX.subSearchZone.decEndInMas > 0)) {

		/* (declinationStartInMas < 0) & (declinationEndInMas > 0) */
		indexStarDec  = -mySearchZonePPMX.subSearchZone.decStartInMas / PPMXL_DECLINATION_FIRST_STEP;
		indexEndDec   = mySearchZonePPMX.subSearchZone.decEndInMas / PPMXL_DECLINATION_FIRST_STEP;

		rest          = -mySearchZonePPMX.subSearchZone.decStartInMas - indexStarDec * PPMXL_DECLINATION_FIRST_STEP;
		indexStarDec2 = rest / PPMXL_DECLINATION_SECOND_STEP;
		rest          = mySearchZonePPMX.subSearchZone.decEndInMas - indexEndDec * PPMXL_DECLINATION_FIRST_STEP;
		indexEndDec2  = rest / PPMXL_DECLINATION_SECOND_STEP;

		mySearchZonePPMX.numberOfBinaryFiles = (indexStarDec + indexEndDec) * numberOfCatalogPerZone + indexStarDec2 + indexEndDec2 + 2;

		allocateMemoryForSearchZonePPMX(&mySearchZonePPMX,PPMXL_BINARY_FILE_NAME_LENGTH);
		if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
			return(mySearchZonePPMX);
		}
		counter      = 0;
		/* South at indexStarDec from 0 to indexStarDec2 */
		for(indexDec2 = indexStarDec2; indexDec2 >= 0; indexDec2--) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMXL_BINARY_FILE_NAME_FORMAT_SOUTH,indexStarDec,ppmxlFileNameSuffix[indexDec2]);
			counter++;
		}

		/* South form indexStarDec to 0 */
		for(indexDec = indexStarDec - 1; indexDec >= 0; indexDec--) {
			for(indexDec2 = numberOfCatalogPerZone - 1; indexDec2 >= 0; indexDec2--) {
				sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMXL_BINARY_FILE_NAME_FORMAT_SOUTH,indexDec,ppmxlFileNameSuffix[indexDec2]);
				counter++;
			}
		}
		/* North from 0 to indexEndDec */
		for(indexDec = 0; indexDec < indexEndDec; indexDec++) {
			for(indexDec2 = 0; indexDec2 < numberOfCatalogPerZone; indexDec2++) {
				sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMXL_BINARY_FILE_NAME_FORMAT_NORTH, indexDec,ppmxlFileNameSuffix[indexDec2]);
				counter++;
			}
		}

		/* North at indexEndDec from 0 to indexEndDec2 */
		indexDec++;
		for(indexDec2 = 0; indexDec2 <= indexEndDec2; indexDec2++) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMXL_BINARY_FILE_NAME_FORMAT_NORTH,indexEndDec,ppmxlFileNameSuffix[indexDec2]);
			counter++;
		}

	} else if (mySearchZonePPMX.subSearchZone.decStartInMas < 0) {

		/* (declinationStartInMas < 0) & (declinationEndInMas < 0) */
		indexStarDec  = -mySearchZonePPMX.subSearchZone.decStartInMas / PPMXL_DECLINATION_FIRST_STEP;
		indexEndDec   = -mySearchZonePPMX.subSearchZone.decEndInMas / PPMXL_DECLINATION_FIRST_STEP;

		rest          = -mySearchZonePPMX.subSearchZone.decStartInMas - indexStarDec * PPMXL_DECLINATION_FIRST_STEP;
		indexStarDec2 = rest / PPMXL_DECLINATION_SECOND_STEP;
		rest          = -mySearchZonePPMX.subSearchZone.decEndInMas - indexEndDec * PPMXL_DECLINATION_FIRST_STEP;
		indexEndDec2  = rest / PPMXL_DECLINATION_SECOND_STEP;

		mySearchZonePPMX.numberOfBinaryFiles = (indexStarDec -indexEndDec) * numberOfCatalogPerZone + indexStarDec2 - indexEndDec2 + 1;

		allocateMemoryForSearchZonePPMX(&mySearchZonePPMX,PPMXL_BINARY_FILE_NAME_LENGTH);
		if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
			return(mySearchZonePPMX);
		}

		counter      = 0;
		/* South at indexStarDec from 0 to indexStarDec2 */
		for(indexDec2 = indexStarDec2; indexDec2 >= 0; indexDec2--) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMXL_BINARY_FILE_NAME_FORMAT_SOUTH,indexStarDec,ppmxlFileNameSuffix[indexDec2]);
			counter++;
		}

		/* South form indexStarDec to indexEndDec */
		for(indexDec = indexStarDec - 1; indexDec > indexEndDec; indexDec--) {
			for(indexDec2 = numberOfCatalogPerZone - 1; indexDec2 >= 0; indexDec2--) {
				sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMXL_BINARY_FILE_NAME_FORMAT_SOUTH,indexDec,ppmxlFileNameSuffix[indexDec2]);
				counter++;
			}
		}

		/* South at indexEndDec from numberOfCatalogPerZone to indexEndDec2 */
		indexDec++;
		for(indexDec2 = numberOfCatalogPerZone - 1; indexDec2 >= indexEndDec2; indexDec2--) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMXL_BINARY_FILE_NAME_FORMAT_SOUTH,indexEndDec,ppmxlFileNameSuffix[indexDec2]);
			counter++;
		}

	} else {

		/* (declinationStartInMas > 0) & (declinationEndInMas > 0) */
		indexStarDec  = mySearchZonePPMX.subSearchZone.decStartInMas / PPMXL_DECLINATION_FIRST_STEP;
		indexEndDec   = mySearchZonePPMX.subSearchZone.decEndInMas / PPMXL_DECLINATION_FIRST_STEP;

		rest          = mySearchZonePPMX.subSearchZone.decStartInMas - indexStarDec * PPMXL_DECLINATION_FIRST_STEP;
		indexStarDec2 = rest / PPMXL_DECLINATION_SECOND_STEP;
		rest          = mySearchZonePPMX.subSearchZone.decEndInMas - indexEndDec * PPMXL_DECLINATION_FIRST_STEP;
		indexEndDec2  = rest / PPMXL_DECLINATION_SECOND_STEP;

		mySearchZonePPMX.numberOfBinaryFiles = (indexEndDec - indexStarDec) * numberOfCatalogPerZone + indexEndDec2 - indexStarDec2 + 1;

		allocateMemoryForSearchZonePPMX(&mySearchZonePPMX,PPMXL_BINARY_FILE_NAME_LENGTH);
		if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
			return(mySearchZonePPMX);
		}

		counter      = 0;
		/* North at indexStarDec from indexStarDec2 to numberOfCatalogPerZone */
		for(indexDec2 = indexStarDec2; indexDec2 < numberOfCatalogPerZone; indexDec2++) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMXL_BINARY_FILE_NAME_FORMAT_NORTH,indexStarDec,ppmxlFileNameSuffix[indexDec2]);
			counter++;
		}

		/* North form indexStarDec to indexEndDec */
		for(indexDec = indexStarDec + 1; indexDec < indexEndDec; indexDec++) {
			for(indexDec2 = 0; indexDec2 < numberOfCatalogPerZone; indexDec2++) {
				sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMXL_BINARY_FILE_NAME_FORMAT_NORTH,indexDec,ppmxlFileNameSuffix[indexDec2]);
				counter++;
			}
		}

		/* North at indexEndDec from 0 to indexEndDec2 */
		for(indexDec2 = 0; indexDec2 <= indexEndDec2; indexDec2++) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMXL_BINARY_FILE_NAME_FORMAT_NORTH,indexEndDec,ppmxlFileNameSuffix[indexDec2]);
			counter++;
		}
	}

	if(DEBUG) {
		printf("mySearchZonePPMX.numberOfBinaryFiles = %d\n",mySearchZonePPMX.numberOfBinaryFiles);
		for(counter = 0; counter < mySearchZonePPMX.numberOfBinaryFiles; counter++) {
			printf("mySearchZonePPMX.binaryFileNames[%d] = %s\n",counter,mySearchZonePPMX.binaryFileNames[counter]);
		}
	}

	return (mySearchZonePPMX);
}
