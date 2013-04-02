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
			for(chunkNumber = chunkStart; chunkNumber < headerInformation.numberOfChunks; chunkNumber++) {
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
		headerInformationNOMAD1* const headerInformation,const int chunkNumber, const char* const binaryFileName) {

	unsigned char* buffer;
	unsigned char* pointerToBuffer;
	int resultOfFunction;
	int firstOffsetInChunk;
	int lengthOfRecord;
	int raStartSubChunk;
	int raEndSubChunk;
	int* acceleratorTable;
	int lengthOfAcceleratorTable;
	int sizeOfSubChunk;
	int indexOfSubChunk;
	int index;
	int numberOfSubChunks;
	int* arrayOfIntegers;
	short int* arrayOfShorts;
	const int indexInTable = chunkNumber << 1;
	const int sizeOfBuffer = headerInformation->chunkTable[indexInTable + 2] - headerInformation->chunkTable[indexInTable];

	if(sizeOfBuffer <= 0) {
		sprintf(outputLogChar,"chunk %d : sizeOfBuffer = %d is not valid",indexInTable,sizeOfBuffer);
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

	/* Read the preface of the chunk */
	pointerToBuffer  = buffer;
	arrayOfIntegers  = (int*) pointerToBuffer;
	convertBig2LittleEndianForArrayOfInteger(arrayOfIntegers,NOMAD1_CHUNK_HEADER_NUMBER_OF_INTEGERS);
	/* prefaceLength */
	headerInformation->theChunkHeader.prefaceLength = arrayOfIntegers[0];
	/* id0 */
	headerInformation->theChunkHeader.id0           = arrayOfIntegers[1];
	/* ra0 */
	headerInformation->theChunkHeader.ra0           = arrayOfIntegers[2];
	/* spd0 */
	headerInformation->theChunkHeader.spd0          = arrayOfIntegers[3];
	/* id1 */
	headerInformation->theChunkHeader.id1           = arrayOfIntegers[4];
	/* ra1 */
	headerInformation->theChunkHeader.ra1           = arrayOfIntegers[5];
	/* spd1 */
	headerInformation->theChunkHeader.spd1          = arrayOfIntegers[6];

	pointerToBuffer += NOMAD1_CHUNK_HEADER_NUMBER_OF_INTEGERS * sizeof(int);
	arrayOfShorts    = (short int*) pointerToBuffer;
	convertBig2LittleEndianForArrayOfShort(arrayOfShorts,NOMAD1_CHUNK_HEADER_NUMBER_OF_SHORTS);
	/* numberOfExtra2 */
	headerInformation->theChunkHeader.numberOfExtra2 = arrayOfShorts[0];
	/* numberOfExtra4 */
	headerInformation->theChunkHeader.numberOfExtra4 = arrayOfShorts[1];
	pointerToBuffer += NOMAD1_CHUNK_HEADER_NUMBER_OF_SHORTS * sizeof(short int);
	/* extra values 4 */
	headerInformation->theChunkHeader.extraValues4  = (int*) pointerToBuffer;
	convertBig2LittleEndianForArrayOfInteger(headerInformation->theChunkHeader.extraValues4,
			(int)headerInformation->theChunkHeader.numberOfExtra4);
	/* extra values 2 */
	pointerToBuffer += headerInformation->theChunkHeader.numberOfExtra4 * sizeof(int);
	headerInformation->theChunkHeader.extraValues2  = (short int*) pointerToBuffer;
	convertBig2LittleEndianForArrayOfShort(headerInformation->theChunkHeader.extraValues2,
			(int)headerInformation->theChunkHeader.numberOfExtra2);

	/* Now we read the accelerator table of the chunk
	 * Note that we have to move by at most 3 bytes after extraValues3 (multiple of 4bytes) */
	pointerToBuffer    = buffer + headerInformation->theChunkHeader.prefaceLength;
	acceleratorTable   = (int*)pointerToBuffer;
	firstOffsetInChunk = acceleratorTable[0];
	firstOffsetInChunk = convertBig2LittleEndianForInteger(firstOffsetInChunk);

	lengthOfAcceleratorTable = (firstOffsetInChunk - headerInformation->theChunkHeader.prefaceLength) / sizeof(int);
	numberOfSubChunks        = lengthOfAcceleratorTable / NOMAD1_CHUNK_ACCELERATOR_TABLE_DIMENSION;
	convertBig2LittleEndianForArrayOfInteger(acceleratorTable, lengthOfAcceleratorTable);

	if(DEBUG) {
		printf("binaryFileName           = %s\n",binaryFileName);
		printf("chunkNumber              = %d\n",chunkNumber);
		printf("chunk offset             = %d\n",headerInformation->chunkTable[indexInTable]);
		printf("prefaceLength            = %d\n",headerInformation->theChunkHeader.prefaceLength);
		printf("numberOfExtra2           = %d\n",headerInformation->theChunkHeader.numberOfExtra2);
		printf("numberOfExtra4           = %d\n",headerInformation->theChunkHeader.numberOfExtra4);
		printf("firstOffsetInChunk       = %d\n",firstOffsetInChunk);
		printf("numberOfSubChunks        = %d\n",numberOfSubChunks);
		for(indexOfSubChunk = 0; indexOfSubChunk < numberOfSubChunks; indexOfSubChunk++) {
			index = NOMAD1_CHUNK_ACCELERATOR_TABLE_DIMENSION * indexOfSubChunk;
			printf("offset[%d] = %d - id[%d] = %d - ra[%d] = %d\n",
					indexOfSubChunk,acceleratorTable[index],
					indexOfSubChunk,acceleratorTable[index + 1],
					indexOfSubChunk,acceleratorTable[index + 2]);
		}
	}

	/* We use the accelerator table : since it is a small table, we do not use dichotomy */
	for(indexOfSubChunk = 0; indexOfSubChunk < numberOfSubChunks - 1; indexOfSubChunk++) {
		/* Check if there is an intersection between what we search and the available */
		index           = NOMAD1_CHUNK_ACCELERATOR_TABLE_DIMENSION * indexOfSubChunk;
		raStartSubChunk = acceleratorTable[index + 2];
		raEndSubChunk   = acceleratorTable[index + 2 + NOMAD1_CHUNK_ACCELERATOR_TABLE_DIMENSION];

		if(
				((mySearchZoneNOMAD1->subSearchZone.raStartInMas >= raStartSubChunk) && (mySearchZoneNOMAD1->subSearchZone.raStartInMas <= raEndSubChunk))
				||
				((mySearchZoneNOMAD1->subSearchZone.raEndInMas >= raStartSubChunk) && (mySearchZoneNOMAD1->subSearchZone.raEndInMas <= raEndSubChunk))
		) {

			/* We process this sub-chunk : there is a common region of RA to explore */
			pointerToBuffer  = buffer + acceleratorTable[index];
			sizeOfSubChunk   = acceleratorTable[index + NOMAD1_CHUNK_ACCELERATOR_TABLE_DIMENSION] - acceleratorTable[index];
			headerInformation->theChunkHeader.id = acceleratorTable[index + 1];

			while(sizeOfSubChunk > 0) {

				processBufferedDataNOMAD1(dsptr,mySearchZoneNOMAD1,pointerToBuffer,headerInformation,&lengthOfRecord);
				/* Move the buffer to read the next star */
				pointerToBuffer += lengthOfRecord;
				sizeOfSubChunk  -= lengthOfRecord;
				headerInformation->theChunkHeader.id++;
			}

			// sizeOfSubChunk should be equal to 0 at the end of this loop
			if(sizeOfSubChunk != 0) {
				sprintf(outputLogChar,"Buffer = %d (unsigned char) : error when reading records",sizeOfSubChunk);
				return(1);
			}
		}
	}

	return (0);
}

/**
 * Process stars in an allocated buffer
 * This method contains the method ed_rec from Francois's code
 */
void processBufferedDataNOMAD1(Tcl_DString* const dsptr,const searchZoneNOMAD1* const mySearchZoneNOMAD1, unsigned char* buffer,
		const headerInformationNOMAD1* const headerInformation, int* const lengthOfRecord) {

	unsigned char presence;
	int status, m, i;

	int zoneNOMAD, zoneUSNO;          /* Zones: NOMAD, and USNO-B	*/
	int idNOMAD, idUSNO;              /* Identifications: NOMAD USNO  */
	int flags;                        /* Flags as defined in read-me*/
	int raInMas, spdInMas ;           /* RA and S. Polar Dist. mas	*/
	short int errorRa, errorSpd;      /* sd Position RA/Dec, mas	*/
	int epochRa, epochDec;            /* The 2 epochs, in 0.1yr	*/
	int pmRa, pmDec;                  /* Proper Motions in 0.1mas/yr	*/
	short int errorPmRa, errorPmDec;  /* sd Proper Motions 0.1mas/yr	*/
	short int mag[6];                 /* Magnitudes B V R J H K	*/
	unsigned char abvr[4];            /* Refs. Astrometry B V R : 1..9 = USNO,2MASS,YB6,UCAC2,Tycho2,Hip,.,O,E */
	int  idUCAC2;                     /* UCAC2 Identifier */
	int idTYC1, idTYC2, idTYC3;       /* Identifiers */
	short int flagFarTYC;             /* Flag r>0.3(1), 1"(2), 3"(3) */
	int idHIP;                        /* Hipparcos number */

	const searchZoneRaSpdMas* const subSearchZone = &(mySearchZoneNOMAD1->subSearchZone);

	/* Convert the compacted record */
	presence    = *buffer;			/* presence of mags and IDs */
	zoneNOMAD   = headerInformation->zoneNumber;
	zoneUSNO    = 0;
	idNOMAD     = headerInformation->theChunkHeader.id;

	/* USNO-B Name */
	idUSNO         = (buffer[1]<<16)|(buffer[2]<<8)|buffer[3];
	if (idUSNO) {
		zoneUSNO   = zoneNOMAD;
		if (idUSNO & 0x800000) {zoneUSNO -= 1;}
		if (idUSNO & 0x400000) {zoneUSNO += 1;}
		idUSNO    &= 0x3fffff;
	}

	raInMas       = (buffer[4]<<16) | (buffer[5]<<8) | buffer[6];
	if (headerInformation->numberOfChunks == 1) {
		++buffer;
		raInMas <<= 8;
		raInMas  |= buffer[6];
	}
	raInMas   += headerInformation->theChunkHeader.ra0;

	errorRa    = getBits(buffer+7, 0, 10);
	epochRa    = getBits(buffer+8, 2, 10) + headerInformation->ep;

	spdInMas   = getBits(buffer+9, 4, 20);
	spdInMas  += headerInformation->theChunkHeader.spd0;

	errorSpd   = getBits(buffer+12, 0, 10);
	epochDec   = getBits(buffer+13, 2, 10) + headerInformation->ep;

	pmRa       = getExtraValues(getBits(buffer+14, 4, 14), EXTRA_14_2, EXTRA_14_4,
			headerInformation->theChunkHeader.extraValues4, headerInformation->theChunkHeader.extraValues2) + headerInformation->pm;
	pmDec      = getExtraValues(getBits(buffer+16, 2, 14), EXTRA_14_2, EXTRA_14_4,
			headerInformation->theChunkHeader.extraValues4, headerInformation->theChunkHeader.extraValues2) + headerInformation->pm;
	errorPmRa  = getExtraValues(getBits(buffer+18, 0, 13), EXTRA_13_2, EXTRA_13_4,
			headerInformation->theChunkHeader.extraValues4, headerInformation->theChunkHeader.extraValues2);
	errorPmDec = getExtraValues(getBits(buffer+19, 5, 13), EXTRA_13_2, EXTRA_13_4,
			headerInformation->theChunkHeader.extraValues4, headerInformation->theChunkHeader.extraValues2);

	status     = ((buffer[21]&0x3f)<<24) | (buffer[22]<<16) | (buffer[23]<<8) | buffer[24];
	flags      = status >> 12;

	/* Fixed-length part done. */
	buffer         += NOMAD1_RECORD_LENGTH;
	*lengthOfRecord = NOMAD1_RECORD_LENGTH;

	/* UCAC2 */
	if (presence & 0x80) {
		idUCAC2            = (buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | buffer[3];
		buffer          += 4;
		*lengthOfRecord += 4;
	}

	/* Tycho */
	if (presence&0x40) {
		flagFarTYC = buffer[0] >> 7;
		idTYC3     = (int)getBits(buffer, 29, 3);
		if (idTYC3 == 0)
			idHIP = (getBits(buffer, 1, 28)) % 1000000;
		else {
			idTYC1 = (int)getBits(buffer, 1, 14);
			idTYC2 = (int)getBits(buffer, 15, 14);
		}
		buffer          += 4;
		*lengthOfRecord += 4;
	}

	/* Magnitudes */
	for (i=0, m = 0x20; i<6; i++, m >>= 1) {
		if (presence & m) {
			mag[i]           = ((buffer[0] << 8) | buffer[1]) + headerInformation->mag;
			buffer          += 2;
			*lengthOfRecord += 2;
		} else {
			mag[i]  = 0x8000 ;	/* -32768 */
		}
	}

	/* Sources */
	abvr[0] = status & 7;
	abvr[1] = (status >> 3) & 7;	/* Blue photometry */
	abvr[2] = (status >> 6) & 7;	/* V    photometry */
	abvr[3] = (status >> 9) & 7;	/* Red  photometry */
	if (flags & NOMAD_OMAGBIT) {abvr[1] = 8;}
	if (flags & NOMAD_EMAGBIT) {abvr[3] = 9;}

	/* Unfortunately the conditions have to be after decoding all argument : we need to output the total record length ! */
	if(
			(subSearchZone->isArroundZeroRa && (raInMas < subSearchZone->raStartInMas) && (raInMas > subSearchZone->raEndInMas)) ||
			(!subSearchZone->isArroundZeroRa && ((raInMas < subSearchZone->raStartInMas) || (raInMas > subSearchZone->raEndInMas)))
	) {
		/* The star is not accepted for output */
		return;
	}

	if((spdInMas  < subSearchZone->spdStartInMas) || (spdInMas > subSearchZone->spdEndInMas)) {
		/* The star is not accepted for output */
		return;
	}

	/* We consider Rmag = mag[2] for selection */
	if((mag[2] < mySearchZoneNOMAD1->magnitudeBox.magnitudeStartInMilliMag) || (mag[2] > mySearchZoneNOMAD1->magnitudeBox.magnitudeEndInMilliMag)) {
		/* The star is not accepted for output */
		return;
	}

	/* Add the result to TCL output */
	Tcl_DStringAppend(dsptr,"{ { NOMAD1 { } {",-1);

	//TODO Complete correctly
	sprintf(outputLogChar,"%04d-%07d %c %.8f %+.8f %.8f %.8f %+.8f %+.8f %.8f %.8f %.1f %.1f "
			"%c %.3f %c %.3f %c %.3f %.3f %.3f %.3f "
			"%d %d %d %d %d %hd",
			zoneNOMAD,idNOMAD,abvr[0],
			(double)raInMas/DEG2MAS,
			(double) (spdInMas + DEC_SOUTH_POLE_MAS) / DEG2MAS,
			(double)errorRa / DEG2MAS,
			(double)errorSpd / DEG2MAS,
			(double)pmRa / DEG2DECIMAS,
			(double)pmDec / DEG2DECIMAS,
			(double)errorPmRa / DEG2DECIMAS,
			(double)errorPmDec / DEG2DECIMAS,
			epochRa / 10., epochDec / 10.,
			abvr[1],(double)mag[0] / MAG2MILLIMAG,
			abvr[2],(double)mag[1] / MAG2MILLIMAG,
			abvr[3],(double)mag[2] / MAG2MILLIMAG,
			(double)mag[3] / MAG2MILLIMAG,
			(double)mag[4] / MAG2MILLIMAG,
			(double)mag[5] / MAG2MILLIMAG,
			idUCAC2, idHIP, idTYC1, idTYC2, idTYC3,flagFarTYC);

	Tcl_DStringAppend(dsptr,outputLogChar,-1);
	Tcl_DStringAppend(dsptr,"} } } ",-1);
}

/*==================================================================
		Convert the Input Record(s)
.PURPOSE  Retrieve a value from Index
.RETURNS  The Value
 *==================================================================*/
int getExtraValues(const int value, const int max, const int max2, const int* const extraValue4, const short int* const extraValue2) {

	if (value <= max) {
		return(value);
	}

	if(value > max2) {
		return (extraValue4[value-max2-1]);
	} else {
		return (extraValue2[value-max -1]);
	}
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

	sscanf(binaryHeader,NOMAD1_HEADER_FORMAT,&temp,&temp,&(headerInformation->zoneNumber),&temp,&temp,
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

