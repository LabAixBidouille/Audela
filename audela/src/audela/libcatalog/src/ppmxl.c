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
	Tcl_DStringAppend(&dsptr,"{ { PPMXL { } { ID RAJ2000 DECJ2000 errRa errDec pmRA pmDE errPmRa errPmDec epochRa epochDec magB1 magB2 magR1 magR2 magI magJ errMagJ magH errMagH magK errMagK Nobs} } } ",-1);
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

	int resultOfFunction;
	headerInformationPPMXL headerInformation;
	int chunkStart;
	int chunkEnd;
	FILE* const inputStream = fopen(binaryFileName,"rb");

	if(inputStream == NULL) {
		sprintf(outputLogChar,"File %s not found",binaryFileName);
		return(1);
	}

	resultOfFunction = readHeaderPPMXL(inputStream, &headerInformation, binaryFileName);
	if(resultOfFunction) {
		return(1);
	}

	/* Find chunk numbers */
	chunkStart    = findComponentNumber(headerInformation.chunkOffRa,headerInformation.lengthOfAcceleratorTable,
			mySearchZonePPMX->subSearchZone.raStartInMas);
	if(chunkStart < 0) {
		sprintf(outputLogChar,"Can not find a valid chunk number for ra = %d",mySearchZonePPMX->subSearchZone.raStartInMas);
		return (1);
	}

	chunkEnd    = findComponentNumber(headerInformation.chunkOffRa,headerInformation.lengthOfAcceleratorTable,
			mySearchZonePPMX->subSearchZone.raEndInMas);
	if(chunkEnd < 0) {
		sprintf(outputLogChar,"Can not find a valid chunk number for ra = %d",mySearchZonePPMX->subSearchZone.raEndInMas);
		return (1);
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
	releaseSimpleArray(headerInformation.extraValues4);
	releaseSimpleArray(headerInformation.chunkOffsets);
	releaseSimpleArray(headerInformation.chunkOffRa);
	releaseSimpleArray(headerInformation.chunkSizes);

	return (0);
}

/**
 * Process a series of successive chunks of data
 */
int processChunksPPMXL(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX, FILE* const inputStream,
		const headerInformationPPMXL* const headerInformation,const int chunkStart,const int chunkEnd, const char* const binaryFileName) {

	unsigned char* buffer;
	unsigned char* pointerToBuffer;
	int resultOfFunction;
	int lengthOfRecord;
	int sizeOfBuffer;

	/* We read all merged chunks to optimise access time to disk */
	sizeOfBuffer = sumNumberOfElements(headerInformation->chunkSizes,chunkStart,chunkEnd);
	buffer       = (unsigned char*)malloc(sizeOfBuffer * sizeof(unsigned char));
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

	/* Loop over stars */
	pointerToBuffer = buffer;

	while(sizeOfBuffer > 0) {

		processBufferedDataPPMXL(dsptr,mySearchZonePPMX,pointerToBuffer,headerInformation,&lengthOfRecord);
		/* Move the buffer to read the next star */
		pointerToBuffer += lengthOfRecord;
		sizeOfBuffer    -= lengthOfRecord;
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
void processBufferedDataPPMXL(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX, unsigned char* buffer,
		const headerInformationPPMXL* const headerInformation, int* const lengthOfRecord) {

	unsigned int val4;
	int indexOfMagnitude, m, m0, val;
	long long idOfStar;
	int raInMas;
	int decInMas;
	short int flags;
	short int errorRa, errorDec;
	short int errorPmRa, errorPmDec;
	short int nObs;
	int pmRa, pmDec;
	int epochRa, epochDec;
	short int magJHK[NUMBER_OF_2MASS_MAGNITUDES], errorMagJHK[NUMBER_OF_2MASS_MAGNITUDES]; /*unit = milli mag*/
	short int magUsno[NUMBER_OF_USNO_MAGNITUDES];	/*=b1mag,b2mag,r1mag,r2mag,imag : unit = centi mag*/
	//char survey[NUMBER_OF_USNO_MAGNITUDES];	/* 5 digits for b1 b2 r1 r2 i   */
	const int lengthOf2MassRecord = 3;
	const int lengthOfUsnoRecord  = 2;
	const searchZoneRaDecMas* const subSearchZone = &(mySearchZonePPMX->subSearchZone);

	m0         = buffer[0];
	if (buffer[1] & 0x80) {
		m0    |= 0x100;
	}
	/* ID */
	idOfStar   = ((buffer[1]&0x7f)<<24) | (buffer[2]<<16) | (buffer[3]<<8) | buffer[4];
	idOfStar <<= 32;
	val4       = (buffer[5]<<24) | (buffer[6]<<16) | (buffer[7]<<8) | buffer[8];
	idOfStar  |= val4;

	/* Ra */
	raInMas    = binRA(buffer);

	/* Dec */
	decInMas   = getBits(buffer + 9, 4, 20) + headerInformation->decStartInMas;

	/* Flags */
	flags      = getBits(buffer + 9, 0, 4);

	/* sigmaRa and sigmaDec */
	errorRa    = buffer[16];
	errorDec   = buffer[17];

	/* Nobs */
	nObs       = getBits(buffer+18, 1, 5);

	/* Proper motion RA and DEC */
	pmRa       = xget4(buffer + 18, 6, 17, 130000, headerInformation->extraValues4) - 65000;
	pmDec      = xget4(buffer + 20, 7, 17, 130000, headerInformation->extraValues4) - 65000;

	/* error on pmRa and pmDec and epochs */
	errorPmRa  = getBits(buffer + 23, 0, 10);
	epochRa    = getBits(buffer + 23,10, 14) + 190000;
	errorPmDec = getBits(buffer + 26, 0, 10);
	epochDec   = getBits(buffer + 26,10, 14) + 190000;

	/* Get magnitudes; error is stored as (val+1) */
	*lengthOfRecord  = PPMXL_SHORT_RECORD_LENGTH;
	buffer          += PPMXL_SHORT_RECORD_LENGTH;
	m                = 0x80;
	for (indexOfMagnitude = 0; indexOfMagnitude < NUMBER_OF_2MASS_MAGNITUDES; indexOfMagnitude++, m>>=1) {
		if (m0 & m) { 	/* Yes, value is present */
			magJHK[indexOfMagnitude]      = getBits(buffer, 0, 15) - 5000;
			errorMagJHK[indexOfMagnitude] = getBits(buffer, 15, 9) -1;
			if (m0 & 0x100) { /* Large JHK error */
				errorMagJHK[indexOfMagnitude] = getBits(buffer, 15, 17) -1;
				buffer++;
			}
			buffer            += lengthOf2MassRecord;
			*lengthOfRecord   += lengthOf2MassRecord;
			if (errorMagJHK[indexOfMagnitude] < 0) {
				errorMagJHK[indexOfMagnitude] = BAD_MAGNITUDE;
			}
		} else {
			magJHK[indexOfMagnitude]          = BAD_MAGNITUDE;
			errorMagJHK[indexOfMagnitude]     = BAD_MAGNITUDE;
		}
	}

	for (indexOfMagnitude = 0; indexOfMagnitude < NUMBER_OF_USNO_MAGNITUDES; indexOfMagnitude++, m>>=1) {
		if (m0&m) {	/* Yes, value is present */
			/*val = get_bits(bin, 0, 16); -- V1.2: not useful */
			val =  xget4(buffer, 0, 16, 65000, headerInformation->extraValues4);
			//			survey[indexOfMagnitude] = (val%10) | '0';
			//			if (survey[indexOfMagnitude] == '9') {
			//				survey[indexOfMagnitude] = '-';
			//			}
			val                        = ((val/10) - 1000);	/* Convert cmag (Mod. V1.2) */
			magUsno[indexOfMagnitude]  = MAG2DECIMAG * val; /*<=30000 ? val : NULL2, magUsno are in centi mag not in milli mag*/
			*lengthOfRecord           += lengthOfUsnoRecord;
			buffer                    += lengthOfUsnoRecord;
		} else {
			//			survey[indexOfMagnitude]  = '-';
			magUsno[indexOfMagnitude]  = BAD_MAGNITUDE;
		}
	}

	/* V1.2: Negative "b1" magnitudes, in case of flag '2' set,
	 * and no 2MASS mag., must be blanked.
	 * (see message by S. Roeser in "History" file) */
	if ((flags&2) && ((m0 & 0xe0) == 0)) {
		magUsno[2] = BAD_MAGNITUDE;
	}

	/* Unfortunately the conditions have to be after decoding all argument : we need to output the total record length ! */
	if(
			(subSearchZone->isArroundZeroRa && (raInMas < subSearchZone->raStartInMas) && (raInMas > subSearchZone->raEndInMas)) ||
			(!subSearchZone->isArroundZeroRa && ((raInMas < subSearchZone->raStartInMas) || (raInMas > subSearchZone->raEndInMas)))
	) {
		/* The star is not accepted for output */
		return;
	}

	if((decInMas  < subSearchZone->decStartInMas) || (decInMas > subSearchZone->decEndInMas)) {
		/* The star is not accepted for output */
		return;
	}

	/* We consider Rmag2 = magUsno[3] for selection */
	if((magUsno[3] < mySearchZonePPMX->magnitudeBox.magnitudeStartInMilliMag) || (magUsno[3] > mySearchZonePPMX->magnitudeBox.magnitudeEndInMilliMag)) {
		/* The star is not accepted for output */
		return;
	}

	/* Add the result to TCL output */
	Tcl_DStringAppend(dsptr,"{ { PPMX { } {",-1);

	sprintf(outputLogChar,"%lld %.8f %+.8f %.8f %.8f %+.8f %+.8f %.8f %.8f %.2f %.2f "
			"%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f "
			"%d",
			idOfStar,
			(double)raInMas/DEG2MAS,
			(double)decInMas / DEG2MAS,
			(double)errorRa / DEG2MAS,
			(double)errorDec / DEG2MAS,
			(double)pmRa / DEG2DECIMAS,
			(double)pmDec / DEG2DECIMAS,
			(double)errorPmRa / DEG2DECIMAS,
			(double)errorPmDec / DEG2DECIMAS,
			epochRa / 100., epochDec / 100.,
			(double)magUsno[0] / MAG2MILLIMAG,
			(double)magUsno[1] / MAG2MILLIMAG,
			(double)magUsno[2] / MAG2MILLIMAG,
			(double)magUsno[3] / MAG2MILLIMAG,
			(double)magUsno[4] / MAG2MILLIMAG,
			(double)magJHK[0] / MAG2MILLIMAG, (double)errorMagJHK[0] / MAG2MILLIMAG,
			(double)magJHK[1] / MAG2MILLIMAG, (double)errorMagJHK[1] / MAG2MILLIMAG,
			(double)magJHK[2] / MAG2MILLIMAG, (double)errorMagJHK[2] / MAG2MILLIMAG,
			nObs);

	Tcl_DStringAppend(dsptr,outputLogChar,-1);
	Tcl_DStringAppend(dsptr,"} } } ",-1);
}

/**
 * Read the header information in the binary file
 */
int readHeaderPPMXL(FILE* const inputStream, headerInformationPPMXL* const headerInformation,
		const char* const binaryFileName) {

	int index;
	int indexPlusOne;
	int lastIndex;
	const char* newBinaryHeader = binaryHeader + PPMXL_HEADER_UNUSEFUL_LENGTH;
	int totalNumberOfStars;
	int fileSize;
	int resultOfFunction = fread(binaryHeader,sizeof(char),PPMX_HEADER_LENGTH,inputStream);

	if(resultOfFunction != PPMX_HEADER_LENGTH) {
		sprintf(outputLogChar,"Error when reading the header from the binary file %s",binaryFileName);
		return(1);
	}

	/* Check that this file is PPMX */
	index = strloc(PPMXL_HEADER_START, '(');
	if (strncmp(binaryHeader, PPMXL_HEADER_START, index+1) != 0) {
		sprintf(outputLogChar, "File %s is not PPMXL", binaryFileName);
		return (1);
	}

	sscanf(newBinaryHeader,PPMXL_HEADER_FORMAT,&totalNumberOfStars,
			&(headerInformation->numberOfExtra4),&(headerInformation->lengthOfAcceleratorTable),
			&(headerInformation->decStartInMas));

	if(DEBUG) {
		printf("binaryFileName                              = %s\n",binaryFileName);
		printf("binaryHeader                                = %s\n",binaryHeader);
		printf("totalNumberOfStars                          = %d\n",totalNumberOfStars);
		printf("headerInformation->lengthOfAcceleratorTable = %d\n",headerInformation->lengthOfAcceleratorTable);
		printf("headerInformation->numberOfExtra4           = %d\n",headerInformation->numberOfExtra4);
		printf("headerInformation->decStartInMas            = %d\n",headerInformation->decStartInMas);
	}

	/* Allocate memory */
	headerInformation->extraValues4 = (int*)malloc(headerInformation->numberOfExtra4 * sizeof(int));
	if(headerInformation->extraValues4 == NULL) {
		sprintf(outputLogChar,"headerInformation->extraValues4 = %d(int) out of memory",headerInformation->numberOfExtra4);
		return(1);
	}
	headerInformation->chunkOffsets = (int*)malloc(headerInformation->lengthOfAcceleratorTable * sizeof(int));
	if(headerInformation->chunkOffsets == NULL) {
		sprintf(outputLogChar,"headerInformation->chunkOffsets = %d(int) out of memory",headerInformation->lengthOfAcceleratorTable);
		return(1);
	}
	headerInformation->chunkOffRa = (int*)malloc(headerInformation->lengthOfAcceleratorTable * sizeof(int));
	if(headerInformation->chunkOffsets == NULL) {
		sprintf(outputLogChar,"headerInformation->chunkOffsets = %d(int) out of memory",headerInformation->lengthOfAcceleratorTable);
		return(1);
	}
	headerInformation->chunkSizes = (int*)malloc(headerInformation->lengthOfAcceleratorTable * sizeof(int));
	if(headerInformation->chunkSizes == NULL) {
		sprintf(outputLogChar,"headerInformation->chunkSizes = %d(int) out of memory",headerInformation->lengthOfAcceleratorTable);
		return(1);
	}

	/* Read from file */
	resultOfFunction = fread(headerInformation->extraValues4,sizeof(int),headerInformation->numberOfExtra4,inputStream);
	if(resultOfFunction != headerInformation->numberOfExtra4) {
		sprintf(outputLogChar,"Error when reading headerInformation->extraValues4 from the binary file %s",binaryFileName);
		return(1);
	}

	resultOfFunction = fread(headerInformation->chunkOffsets,sizeof(int),headerInformation->lengthOfAcceleratorTable,inputStream);
	if(resultOfFunction != headerInformation->lengthOfAcceleratorTable) {
		sprintf(outputLogChar,"Error when reading headerInformation->chunkOffsets from the binary file %s",binaryFileName);
		return(1);
	}

	resultOfFunction = fread(headerInformation->chunkOffRa,sizeof(int),headerInformation->lengthOfAcceleratorTable,inputStream);
	if(resultOfFunction != headerInformation->lengthOfAcceleratorTable) {
		sprintf(outputLogChar,"Error when reading headerInformation->chunkOffRa from the binary file %s",binaryFileName);
		return(1);
	}

	/* Swap values because data is written in Big_endian */
	convertBig2LittleEndianForArrayOfInteger(headerInformation->chunkOffsets,headerInformation->lengthOfAcceleratorTable);
	convertBig2LittleEndianForArrayOfInteger(headerInformation->chunkOffRa,headerInformation->lengthOfAcceleratorTable);
	convertBig2LittleEndianForArrayOfInteger(headerInformation->extraValues4,headerInformation->numberOfExtra4);

	lastIndex      = headerInformation->lengthOfAcceleratorTable - 1;
	index          = 0;
	indexPlusOne   = 1;
	while(index    < lastIndex) {
		headerInformation->chunkSizes[index] =
				headerInformation->chunkOffsets[indexPlusOne] - headerInformation->chunkOffsets[index];
		index      = indexPlusOne;
		indexPlusOne++;
	}

	/* The size of the last chunk */
	fseek(inputStream,0,SEEK_END);
	fileSize = ftell(inputStream);

	headerInformation->chunkSizes[lastIndex] = fileSize - headerInformation->chunkOffsets[lastIndex];
	//printf("last size = %d\n",headerInformation->chunkSizes[lastIndex]);
	if(headerInformation->chunkSizes[lastIndex] < 0) {
		sprintf(outputLogChar,"The number of stars is not coherent in %s",binaryFileName);
		releaseSimpleArray(headerInformation->extraValues4);
		releaseSimpleArray(headerInformation->chunkOffsets);
		releaseSimpleArray(headerInformation->chunkOffRa);
		releaseSimpleArray(headerInformation->chunkSizes);
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
