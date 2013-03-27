/*
 * nomad1.h
 *
 *  Created on: 27/03/2013
 *      Author: Y. Damerdji
 *
 *  This code is inspired from Francois Ochsenbein's code
 */

#ifndef NOMAD1_H_
#define NOMAD1_H_

#include "useful.h"

#define NOMAD1_HEADER_FORMAT "NOMAD-1.0(%d) %d/N%d.bin %d-%d  pm=%d mag=%d Ep=%d xtra=%d,%d UCAC2=%d(%07d/%07d) Tyc2=%d"
#define NOMAD1_HEADER_LENGTH                160
#define NOMAD1_SPD_STEP                     360000 /* 0.1 deg = 360000 mas */
#define NOMAD1_BINARY_FILE_NAME_LENGTH       14
#if defined(LIBRARY_DLL)
#define NOMAD1_BINARY_FILE_NAME_FORMAT      "%03d\\N%04d.bin"
#else
#define NOMAD1_BINARY_FILE_NAME_FORMAT      "%03d/N%04d.bin"
#endif
#define NOMAD1_NUMBER_OF_FILES_PER_SUBDIRECTORY 10
#define NOMAD1_LENTGH_ACCELERATOR_TABLE         160
#define NOMAD1_HALF_LENTGH_ACCELERATOR_TABLE    80
#define NOMAD1_CHUNK_SHIFT_RA                24


typedef struct {
	searchZoneRaSpdMas subSearchZone;
	magnitudeBoxMilliMag  magnitudeBox;
	char** binaryFileNames;
	int numberOfBinaryFiles;
} searchZoneNOMAD1;

typedef struct {
	int chunkTable[NOMAD1_LENTGH_ACCELERATOR_TABLE];
	int numberOfChunks;
	int pm;
	int mag;
	int ep;
} headerInformationNOMAD1;

const searchZoneNOMAD1 findSearchZoneNOMAD1(const double raInDeg,const double decInDeg,
		const double radiusInArcMin,const double magMin, const double magMax);
int processOneFileNOMAD1(Tcl_DString* const dsptr,const searchZoneNOMAD1* const mySearchZoneNOMAD1,
		const char* const binaryFileName);
int readHeaderNOMAD1(FILE* const inputStream, headerInformationNOMAD1* const headerInformation,
		const char* const binaryFileName);
int processChunksNOMAD1(Tcl_DString* const dsptr,const searchZoneNOMAD1* const mySearchZoneNOMAD1, FILE* const inputStream,
		const headerInformationNOMAD1* const headerInformation,const int chunkNumber, const char* const binaryFileName);
void processBufferedDataNOMAD1(Tcl_DString* const dsptr,const searchZoneNOMAD1* const mySearchZoneNOMAD1, unsigned char* buffer,
		const headerInformationNOMAD1* const headerInformation, int* const lengthOfRecord);
void allocateMemoryForSearchZoneNOMAD1(searchZoneNOMAD1* const mySearchZonePPMX, const size_t fileNameLength);

#endif /* NOMAD1_H_ */
