/*
 * ppmx.c
 *
 *  Created on: 18/03/2013
 *      Author: Y. Damerdji
 */
#include "ppmx.h"

static char *ppxZoneNames[] = {"0000", "0730", "1500", "2230", "3000", "3730",
		"4500", "5230", "6000", "6730", "7500", "8230" };
static char referenceCatalog[] = "AGHPST";
static char ppmxSet[] = "HOS";

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
	resultOfFunction = decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax);
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
	Tcl_DStringAppend(&dsptr,"{ { PPMX { } { ID RAJ2000 DECJ2000 errRa errDec pmRA pmDE errPmRa errPmDec Cmag Rmag Bmag ErrBmag Vmag ErrVmag Jmag ErrJmag Hmag ErrHmag Kmag ErrKmag Nobs P sub refCatalog} } } ",-1);
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
	headerInformationPPMX headerInformation;
	const int chunkStart    = mySearchZonePPMX->subSearchZone.raStartInMas >> PPMX_CHUNK_SHIFT_RA;
	const int chunkEnd      = mySearchZonePPMX->subSearchZone.raEndInMas >> PPMX_CHUNK_SHIFT_RA;
	FILE* const inputStream = fopen(binaryFileName,"rb");

	if(inputStream == NULL) {
		sprintf(outputLogChar,"File %s not found",binaryFileName);
		return(1);
	}

	resultOfFunction = readHeaderPPMX(inputStream, &headerInformation, binaryFileName);
	if(resultOfFunction) {
		return(1);
	}

	if(mySearchZonePPMX->subSearchZone.isArroundZeroRa) {

		/* From chunkStart to end */
		if(processChunksPPMX(dsptr,mySearchZonePPMX,inputStream,&headerInformation,chunkStart,headerInformation.lengthOfAcceleratorTable - 1, binaryFileName)) {
			return (1);
		}

		/* From 0 to chunkEnd */
		if(processChunksPPMX(dsptr,mySearchZonePPMX,inputStream,&headerInformation,0,chunkEnd, binaryFileName)) {
			return (1);
		}

	} else {

		/* From chunkStart to chunkEnd */
		if(processChunksPPMX(dsptr,mySearchZonePPMX,inputStream,&headerInformation,chunkStart,chunkEnd, binaryFileName)) {
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
int processChunksPPMX(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX,FILE* const inputStream,
		const headerInformationPPMX* const headerInformation,const int chunkStart,const int chunkEnd, const char* const binaryFileName) {

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
		raStart       = indexOfChunk << PPMX_CHUNK_SHIFT_RA;

		/* Loop over stars */
		for(indexOfStar = 0; indexOfStar <= numberOfStars; indexOfStar++) {
			processBufferedDataPPMX(dsptr,mySearchZonePPMX,pointerToBuffer,headerInformation,raStart);
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
void processBufferedDataPPMX(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX, unsigned char* buffer,
		const headerInformationPPMX* const headerInformation, const int raStart) {

	int o = 0, i;
	char jName[15]; /* IAU name HHMMSS.S+ddmmss	*/ /*=ID */
	int raInMas;
	int decInMas;
	short int errorRa, errorDec;
	short int errorPmRa, errorPmDec;
	int epRa, epDec;
	int pmRa, pmDec;
	unsigned char nObs; /* Number of observations	*/
	short int magnitudes[7];	/* (mmag) B V J H K C r mags	*/
	short int errorMagnitudes[5];	/* (mmag) Error on magnitudes   */
	char subsetFlag;	/* subset flag			*/
	char fitFlag;		/* Bad fit flag [P]		*/
	char src;		/* source catalog  		*/

	const searchZoneRaDecMas* const subSearchZone = &(mySearchZonePPMX->subSearchZone);

	/* Convert the compacted record */
	raInMas = getBits(buffer, 0, 23) + raStart; o += 23;
	if(
			(subSearchZone->isArroundZeroRa && (raInMas < subSearchZone->raStartInMas) && (raInMas > subSearchZone->raEndInMas)) ||
			(!subSearchZone->isArroundZeroRa && ((raInMas < subSearchZone->raStartInMas) || (raInMas > subSearchZone->raEndInMas)))
	) {
		/* The star is not accepted for output */
		return;
	}

	decInMas = getBits(buffer, o, 25) + headerInformation->decStartInMas; o += 25;
	if((decInMas  < subSearchZone->decStartInMas) || (decInMas > subSearchZone->decEndInMas)) {
		/* The star is not accepted for output */
		return;
	}

	errorRa    = getBits(buffer, o, 10); o += 10;
	errorDec   = getBits(buffer, o, 10); o += 10;
	epRa       = getBits(buffer, o, 14); o += 14;  epRa  += 190000;
	epDec      = getBits(buffer, o, 14); o += 14;  epDec += 190000;
	pmRa       = xget4(buffer, o, 20, 1000000, headerInformation->extraValues4)-500000; o += 20;
	pmDec      = xget4(buffer, o, 20, 1000000, headerInformation->extraValues4)-500000; o += 20;
	errorPmRa  = getBits(buffer, o, 10); o += 10;
	errorPmDec = getBits(buffer, o, 10); o += 10;

	subsetFlag = ppmxSet[getBits(buffer, o, 2)]; o += 2;
	fitFlag    = getBits(buffer, o, 1) ? 'P' : 'G'; o += 1;

	o += 1 /* +UNUSED */ + 4 /* Naming problems */;

	/* Magnitudes (mmag) B V J H K C R mags	*/
	magnitudes[5] = xget2(buffer, o, 14, 16000, headerInformation->extraValues2)+2000; o += 14;
	magnitudes[6] = xget2(buffer, o, 14, 16000, headerInformation->extraValues2)+2000; o += 14;

	/* We consider Rmag = magnitudes[6] for selection */
	if((magnitudes[6] < mySearchZonePPMX->magnitudeBox.magnitudeStartInMilliMag) || (magnitudes[6] > mySearchZonePPMX->magnitudeBox.magnitudeEndInMilliMag)) {
		/* The star is not accepted for output */
		return;
	}

	for (i=0; i<5; i++) {
		magnitudes[i]      = xget2(buffer, o, 14, 16000, headerInformation->extraValues2)+2000; o += 14;
		errorMagnitudes[i] = getBits(buffer, o, 10); o += 10;
		if (errorMagnitudes[i] == (1 << 10) - 1 ) {
			magnitudes[i]      = BAD_MAGNITUDE;
			errorMagnitudes[i] = BAD_MAGNITUDE;
		}
	}
	nObs = getBits(buffer, o, 5); o += 5;
	src  = referenceCatalog[getBits(buffer, o, 3)]; //o += 3;

	/* Write out the Declination part of Jname */
	sJname(jName, raInMas, decInMas, (buffer[20] & 0xc0) >> 6);

	/* Add the result to TCL output */
	Tcl_DStringAppend(dsptr,"{ { PPMX { } {",-1);

	sprintf(outputLogChar,"%12s %.8f %+.8f %.8f %.8f %+.8f %+.8f %.8f %.8f "
			"%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f "
			"%d %c %c %c",
			jName, // the ID %03d-%06d
			(double)raInMas/DEG2MAS,
			(double)decInMas / DEG2MAS,
			(double)errorRa / DEG2MAS,
			(double)errorDec / DEG2MAS,
			(double)pmRa / DEG2MAS,
			(double)pmDec / DEG2MAS,
			(double)errorPmRa / DEG2MAS,
			(double)errorPmDec / DEG2MAS,
			(double)magnitudes[5] / MAG2MILLIMAG,
			(double)magnitudes[6] / MAG2MILLIMAG,
			(double)magnitudes[0] / MAG2MILLIMAG, (double)errorMagnitudes[0] / MAG2MILLIMAG,
			(double)magnitudes[1] / MAG2MILLIMAG, (double)errorMagnitudes[1] / MAG2MILLIMAG,
			(double)magnitudes[2] / MAG2MILLIMAG, (double)errorMagnitudes[2] / MAG2MILLIMAG,
			(double)magnitudes[3] / MAG2MILLIMAG, (double)errorMagnitudes[3] / MAG2MILLIMAG,
			(double)magnitudes[4] / MAG2MILLIMAG, (double)errorMagnitudes[4] / MAG2MILLIMAG,
			nObs,fitFlag,subsetFlag,src);

	Tcl_DStringAppend(dsptr,outputLogChar,-1);
	Tcl_DStringAppend(dsptr,"} } } ",-1);
}

/*============================================================
 * Francois Ochsenbein's method (sJname)
 * PURPOSE  Convert a RA and Dec into J-name for PPMX
 * RETURNS  [0,max] = standard; >max => saved in header
 * REMARKS  modJ&1 ==> add 1 unit to DE ;
 *          modJ&2 ==> add 1 unit to RA ;
 *============================================================*/
void sJname(char * const str, const int ra, const int de, const int modJ) {

	int val;
	val = de;
	if (val<0) val = -val;
	val = val/1000;	   /* Value in arcsec */
	if (modJ&1) {
		val++;
	}
	str[14] = '0' + val%10;
	val /= 10;   str[13] = '0' + val%6;
	val /=  6;   str[12] = '0' + val%10;
	val /= 10;   str[11] = '0' + val%6;
	val /=  6;   str[10] = '0' + val%10;
	val /= 10;   str[ 9] = '0' + val;
	str[ 8] = de<0 ? '-' : '+';

	/* Write out the RA part of Jname */
	val  = ra - (ra/3);     /* RA in 1/10000s */
	val /= 1000;
	if (modJ&2) {
		val++;
	}
	str[7] = '0' + val%10;
	str[6] = '.';
	val /= 10;   str[5] = '0' + val%10;
	val /= 10;   str[4] = '0' + val%6;
	val /=  6;   str[3] = '0' + val%10;
	val /= 10;   str[2] = '0' + val%6;
	val /=  6;   str[1] = '0' + val%10;
	val /= 10;   str[0] = '0' + val;
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

	/* Check that this file is PPMX */
	index = strloc(PPMX_HEADER_FORMAT, '(');
	if (strncmp(binaryHeader, PPMX_HEADER_FORMAT, index+1) != 0) {
		sprintf(outputLogChar, "File %s is not PPMX", binaryFileName);
		return (1);
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
	int indexStarDec;
	int indexEndDec;
	int indexDec;
	int counter;

	fillSearchZoneRaDecMas(&(mySearchZonePPMX.subSearchZone), raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMilliMag(&(mySearchZonePPMX.magnitudeBox), magMin, magMax);

	/* Now we find the binary files which will opened during this process */
	if ((mySearchZonePPMX.subSearchZone.decStartInMas < 0) && (mySearchZonePPMX.subSearchZone.decEndInMas > 0)) {

		/* (declinationStartInMas < 0) & (declinationEndInMas > 0) */
		indexStarDec = -mySearchZonePPMX.subSearchZone.decStartInMas / PPMX_DECLINATION_STEP;
		indexEndDec  = mySearchZonePPMX.subSearchZone.decEndInMas / PPMX_DECLINATION_STEP;
		mySearchZonePPMX.numberOfBinaryFiles = indexStarDec + indexEndDec + 2;
		allocateMemoryForSearchZonePPMX(&mySearchZonePPMX, PPMX_BINARY_FILE_NAME_LENGTH);
		if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
			return(mySearchZonePPMX);
		}
		counter      = 0;
		/* South */
		for(indexDec = indexStarDec; indexDec >= 0; indexDec--) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMX_BINARY_FILE_NAME_FORMAT_SOUTH,ppxZoneNames[indexDec]);
			counter++;
		}
		/* North */
		for(indexDec = 0; indexDec <= indexEndDec; indexDec++) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMX_BINARY_FILE_NAME_FORMAT_NORTH,ppxZoneNames[indexDec]);
			counter++;
		}

	} else if (mySearchZonePPMX.subSearchZone.decStartInMas < 0) {

		/* (declinationStartInMas < 0) & (declinationEndInMas < 0) */
		indexStarDec = -mySearchZonePPMX.subSearchZone.decStartInMas / PPMX_DECLINATION_STEP;
		indexEndDec  = -mySearchZonePPMX.subSearchZone.decEndInMas / PPMX_DECLINATION_STEP;
		mySearchZonePPMX.numberOfBinaryFiles = indexStarDec - indexEndDec + 1;
		allocateMemoryForSearchZonePPMX(&mySearchZonePPMX, PPMX_BINARY_FILE_NAME_LENGTH);
		if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
			return(mySearchZonePPMX);
		}
		counter      = 0;
		for(indexDec = indexStarDec; indexDec >= indexEndDec; indexDec--) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMX_BINARY_FILE_NAME_FORMAT_SOUTH,ppxZoneNames[indexDec]);
			counter++;
		}

	} else {

		/* (declinationStartInMas > 0) & (declinationEndInMas > 0) */
		indexStarDec = mySearchZonePPMX.subSearchZone.decStartInMas / PPMX_DECLINATION_STEP;
		indexEndDec  = mySearchZonePPMX.subSearchZone.decEndInMas / PPMX_DECLINATION_STEP;
		mySearchZonePPMX.numberOfBinaryFiles = indexEndDec - indexStarDec + 1;
		allocateMemoryForSearchZonePPMX(&mySearchZonePPMX, PPMX_BINARY_FILE_NAME_LENGTH);
		if(mySearchZonePPMX.numberOfBinaryFiles < 0) {
			return(mySearchZonePPMX);
		}
		counter      = 0;
		for(indexDec = indexStarDec; indexDec <= indexEndDec; indexDec++) {
			sprintf(mySearchZonePPMX.binaryFileNames[counter],PPMX_BINARY_FILE_NAME_FORMAT_NORTH,ppxZoneNames[indexDec]);
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

/**
 * Allocate file names in searchZonePPMX
 */
void allocateMemoryForSearchZonePPMX(searchZonePPMX* const mySearchZonePPMX, const size_t fileNameLength) {

	int index;

	mySearchZonePPMX->binaryFileNames = (char**)malloc(mySearchZonePPMX->numberOfBinaryFiles * sizeof(char*));
	if(mySearchZonePPMX->binaryFileNames == NULL) {
		sprintf(outputLogChar,"Error : mySearchZonePPMX.binaryFileNames[%d] out of memory\n",mySearchZonePPMX->numberOfBinaryFiles);
		mySearchZonePPMX->numberOfBinaryFiles = -1;
		return;
	}

	for(index = 0; index < mySearchZonePPMX->numberOfBinaryFiles; index++) {
		mySearchZonePPMX->binaryFileNames[index] = (char*)malloc(fileNameLength * sizeof(char));
		if(mySearchZonePPMX->binaryFileNames[index] == NULL) {
			sprintf(outputLogChar,"Error : mySearchZonePPMX.binaryFileNames[%d] = %ld (char) out of memory\n",index,fileNameLength);
			mySearchZonePPMX->numberOfBinaryFiles = -1;
			return;
		}
	}
}
