/*
 * nomad1.c
 *
 *  Created on: 27/03/2013
 *      Author: Y. Damerdji
 */
#include "nomad1.h"

static char outputLogChar[STRING_COMMON_LENGTH];
static char binaryHeader[NOMAD1_HEADER_LENGTH];

/**
 * Cone search on PPMX catalog
 */
int cmd_tcl_csnomad1(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	int indexOfFile;
	int resultOfFunction;
	searchZoneNOMAD1 mySearchZoneNOMAD1;
	char binaryFileName[STRING_COMMON_LENGTH];
	Tcl_DString dsptr;

	/* Decode inputs */
	resultOfFunction = decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax);
	if(resultOfFunction) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Define the search zone */
	mySearchZoneNOMAD1 = findSearchZoneNOMAD1(ra,dec,radius,magMin,magMax);
	if(mySearchZoneNOMAD1.numberOfBinaryFiles < 0) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* No we loop over the binary files to be opened, we process them one by one */
	Tcl_DStringInit(&dsptr);
	//TODO fill correctly
	Tcl_DStringAppend(&dsptr,"{ { NOMAD1 { } { ID RAJ2000 DECJ2000 errRa errDec pmRA pmDE errPmRa errPmDec epochRa epochDec magB1 magB2 magR1 magR2 magI magJ errMagJ magH errMagH magK errMagK Nobs} } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	for(indexOfFile = 0; indexOfFile < mySearchZoneNOMAD1.numberOfBinaryFiles; indexOfFile++) {
		sprintf(binaryFileName,"%s%s",pathToCatalog,mySearchZoneNOMAD1.binaryFileNames[indexOfFile]);
		resultOfFunction = processOneFileNOMAD1(&dsptr,&mySearchZoneNOMAD1,binaryFileName);
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
	releaseDoubleArray((void**)mySearchZoneNOMAD1.binaryFileNames,mySearchZoneNOMAD1.numberOfBinaryFiles);

	return (TCL_OK);
}

/**
 * Process one binary file
 */
int processOneFileNOMAD1(Tcl_DString* const dsptr,const searchZoneNOMAD1* const mySearchZoneNOMAD1,
		const char* const binaryFileName) {

	int chunkNumber;
	int resultOfFunction;
	headerInformationNOMAD1 headerInformation;
	int chunkStart;
	int chunkEnd;
	FILE* const inputStream = fopen(binaryFileName,"rb");

	if(inputStream == NULL) {
		sprintf(outputLogChar,"File %s not found",binaryFileName);
		return(1);
	}

	resultOfFunction = readHeaderNOMAD1(inputStream, &headerInformation, binaryFileName);
	if(resultOfFunction) {
		return(1);
	}

	if(headerInformation.numberOfChunks == 1) {
		/* For regions near the poles, only one chunk in binary file : we process chunk 0, it contains all 360deg of RA */
		resultOfFunction = processChunksNOMAD1(dsptr,mySearchZoneNOMAD1,inputStream,&headerInformation,0, binaryFileName);
		if(resultOfFunction) {
			return (1);
		}

	} else {

		/* Chunk number = ra >> 24 */
		chunkStart = mySearchZoneNOMAD1->subSearchZone.raStartInMas >> NOMAD1_CHUNK_SHIFT_RA;
		chunkEnd   = mySearchZoneNOMAD1->subSearchZone.raEndInMas >> NOMAD1_CHUNK_SHIFT_RA;

		if(mySearchZoneNOMAD1->subSearchZone.isArroundZeroRa) {

			/* From chunkStart to end */
			for(chunkNumber = chunkStart; chunkNumber <= headerInformation.numberOfChunks; chunkNumber++) {
				resultOfFunction = processChunksNOMAD1(dsptr,mySearchZoneNOMAD1,inputStream,&headerInformation,chunkNumber, binaryFileName);
				if(resultOfFunction) {
					return (1);
				}
			}

			/* From 0 to chunkEnd */
			for(chunkNumber = 0; chunkNumber <= chunkEnd; chunkNumber++) {
				resultOfFunction = processChunksNOMAD1(dsptr,mySearchZoneNOMAD1,inputStream,&headerInformation,chunkNumber, binaryFileName);
				if(resultOfFunction) {
					return (1);
				}
			}

		} else {

			/* From chunkStart to chunkEnd */
			for(chunkNumber = chunkStart; chunkNumber <= chunkEnd; chunkNumber++) {
				resultOfFunction = processChunksNOMAD1(dsptr,mySearchZoneNOMAD1,inputStream,&headerInformation,chunkNumber, binaryFileName);
				if(resultOfFunction) {
					return (1);
				}
			}
		}
	}

	/* Close all and release memory */
	fclose(inputStream);

	return (0);
}

/**
 * Process a series of successive chunks of data
 */
int processChunksNOMAD1(Tcl_DString* const dsptr,const searchZoneNOMAD1* const mySearchZoneNOMAD1, FILE* const inputStream,
		const headerInformationNOMAD1* const headerInformation,const int chunkNumber, const char* const binaryFileName) {

	unsigned char* buffer;
	unsigned char* pointerToBuffer;
	int resultOfFunction;
	int lengthOfRecord;
	const int indexInTable = chunkNumber << 1;
	const int sizeOfBuffer = headerInformation->chunkTable[indexInTable + 2] - headerInformation->chunkTable[indexInTable];

	if(sizeOfBuffer <= 0) {
		sprintf(outputLogChar,"sizeOfBuffer = %d is not valid",sizeOfBuffer);
		return(1);
	}

	buffer    = (unsigned char*)malloc(sizeOfBuffer * sizeof(unsigned char));
	if(buffer == NULL) {
		sprintf(outputLogChar,"Buffer = %d (unsigned char) out of memory",sizeOfBuffer);
		return(1);
	}
	fseek(inputStream,headerInformation->chunkTable[indexInTable],SEEK_SET);
	resultOfFunction = fread(buffer,sizeof(unsigned char),sizeOfBuffer,inputStream);
	if(resultOfFunction != sizeOfBuffer) {
		sprintf(outputLogChar,"Can not read %d (char) from %s",sizeOfBuffer,binaryFileName);
		return(1);
	}

	//TODO recode please
	/* Loop over stars */
	pointerToBuffer = buffer;

	while(sizeOfBuffer > 0) {

		processBufferedDataNOMAD1(dsptr,mySearchZoneNOMAD1,pointerToBuffer,headerInformation,&lengthOfRecord);
		/* Move the buffer to read the next star */
		pointerToBuffer += lengthOfRecord;
		//sizeOfBuffer    -= lengthOfRecord;
	}

	releaseSimpleArray(buffer);

	// sizeOfBuffer should be equal to 0 at the end of this loop
	if(sizeOfBuffer != 0) {
		sprintf(outputLogChar,"Buffer = %d (unsigned char) : error when reading records",sizeOfBuffer);
		return(1);
	}

	return (0);
}

/**
 * Process stars in an allocated buffer
 * This method contains the method ed_rec from Francois's code
 */
void processBufferedDataNOMAD1(Tcl_DString* const dsptr,const searchZoneNOMAD1* const mySearchZoneNOMAD1, unsigned char* buffer,
		const headerInformationNOMAD1* const headerInformation, int* const lengthOfRecord) {

}

/**
 * Read the header information in the binary file
 */
int readHeaderNOMAD1(FILE* const inputStream, headerInformationNOMAD1* const headerInformation,
		const char* const binaryFileName) {

	int index;
	int resultOfFunction = fread(binaryHeader,sizeof(char),NOMAD1_HEADER_LENGTH,inputStream);
	int temp;

	if(resultOfFunction != NOMAD1_HEADER_LENGTH) {
		sprintf(outputLogChar,"Error when reading the header from the binary file %s",binaryFileName);
		return(1);
	}

	/* Check that this file is NOMAD-1.0 */
	index = strloc(NOMAD1_HEADER_FORMAT, '(');
	if (strncmp(binaryHeader, NOMAD1_HEADER_FORMAT, index+1) != 0) {
		sprintf(outputLogChar, "File %s is not NOMAD-1.0", binaryFileName);
		return (1);
	}

	sscanf(binaryHeader,NOMAD1_HEADER_FORMAT,&temp,&temp,&temp,&temp,&temp,
			&(headerInformation->pm),&(headerInformation->mag),&(headerInformation->ep),
			&temp,&temp,&temp,&temp,&temp,&temp);

	/* Read from file */
	resultOfFunction = fread(headerInformation->chunkTable,sizeof(int),NOMAD1_LENTGH_ACCELERATOR_TABLE,inputStream);
	if(resultOfFunction != NOMAD1_LENTGH_ACCELERATOR_TABLE) {
		sprintf(outputLogChar,"Error when reading headerInformation->chunkTable from the binary file %s",binaryFileName);
		return(1);
	}

	/* Swap values because data is written in Big_endian */
	convertBig2LittleEndianForArrayOfInteger(headerInformation->chunkTable,NOMAD1_LENTGH_ACCELERATOR_TABLE);

	/* Find the actual end of Chunks -- there may be zeroes */
	for (index = 2; (index  < NOMAD1_LENTGH_ACCELERATOR_TABLE) && (headerInformation->chunkTable[index]); index += 2) ;
	headerInformation->numberOfChunks = index >> 1;		/* 2 numbers (o,ID) per chunk   */
	headerInformation->numberOfChunks--;			/* Actually, last indicates EOF */

	if(DEBUG) {
		printf("binaryFileName                              = %s\n",binaryFileName);
		printf("binaryHeader                                = %s\n",binaryHeader);
		printf("headerInformation->pm                       = %d\n",headerInformation->pm);
		printf("headerInformation->mag                      = %d\n",headerInformation->mag);
		printf("headerInformation->ep                       = %d\n",headerInformation->ep);
		printf("headerInformation->numberOfChunks           = %d\n",headerInformation->numberOfChunks);
	}

	return (0);
}

/**
 * Find the search zone having its center on (ra,dec) with a radius of radius
 */
const searchZoneNOMAD1 findSearchZoneNOMAD1(const double raInDeg,const double decInDeg,
		const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneNOMAD1 mySearchZoneNOMAD1;
	int indexStartSpd;
	int indexEndSpd;
	int indexSpd;
	int indexBigSpd;
	int counter;

	fillSearchZoneRaSpdMas(&(mySearchZoneNOMAD1.subSearchZone), raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMilliMag(&(mySearchZoneNOMAD1.magnitudeBox), magMin, magMax);

	indexStartSpd = mySearchZoneNOMAD1.subSearchZone.spdStartInMas / NOMAD1_SPD_STEP;
	indexEndSpd   = mySearchZoneNOMAD1.subSearchZone.spdEndInMas / NOMAD1_SPD_STEP;

	mySearchZoneNOMAD1.numberOfBinaryFiles = indexEndSpd - indexStartSpd + 1;

	allocateMemoryForSearchZoneNOMAD1(&mySearchZoneNOMAD1, NOMAD1_BINARY_FILE_NAME_LENGTH);
	if(mySearchZoneNOMAD1.numberOfBinaryFiles < 0) {
		return(mySearchZoneNOMAD1);
	}

	counter      = 0;
	for(indexSpd = indexStartSpd; indexSpd <= indexEndSpd; indexSpd++) {
		indexBigSpd = indexSpd / NOMAD1_NUMBER_OF_FILES_PER_SUBDIRECTORY;
		sprintf(mySearchZoneNOMAD1.binaryFileNames[counter],NOMAD1_BINARY_FILE_NAME_FORMAT,indexBigSpd,indexSpd);
		counter++;
	}

	if(DEBUG) {
		printf("mySearchZoneNOMAD1.numberOfBinaryFiles = %d\n",mySearchZoneNOMAD1.numberOfBinaryFiles);
		for(counter = 0; counter < mySearchZoneNOMAD1.numberOfBinaryFiles; counter++) {
			printf("mySearchZoneNOMAD1.binaryFileNames[%d] = %s\n",counter,mySearchZoneNOMAD1.binaryFileNames[counter]);
		}
	}

	return (mySearchZoneNOMAD1);
}

/**
 * Allocate file names in searchZoneNOMAD1
 */
void allocateMemoryForSearchZoneNOMAD1(searchZoneNOMAD1* const mySearchZoneNOMAD1, const size_t fileNameLength) {

	int index;

	mySearchZoneNOMAD1->binaryFileNames = (char**)malloc(mySearchZoneNOMAD1->numberOfBinaryFiles * sizeof(char*));
	if(mySearchZoneNOMAD1->binaryFileNames == NULL) {
		sprintf(outputLogChar,"Error : mySearchZoneNOMAD1.binaryFileNames[%d] out of memory\n",mySearchZoneNOMAD1->numberOfBinaryFiles);
		mySearchZoneNOMAD1->numberOfBinaryFiles = -1;
		return;
	}

	for(index = 0; index < mySearchZoneNOMAD1->numberOfBinaryFiles; index++) {
		mySearchZoneNOMAD1->binaryFileNames[index] = (char*)malloc(fileNameLength * sizeof(char));
		if(mySearchZoneNOMAD1->binaryFileNames[index] == NULL) {
			sprintf(outputLogChar,"Error : mySearchZoneNOMAD1.binaryFileNames[%d] = %ld (char) out of memory\n",index,fileNameLength);
			mySearchZoneNOMAD1->numberOfBinaryFiles = -1;
			return;
		}
	}
}

