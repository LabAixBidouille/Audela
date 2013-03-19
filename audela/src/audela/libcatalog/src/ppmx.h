/*
 * ppmx.h
 *
 *  Created on: 18/03/2013
 *      Author: Y. Damerdji
 *
 *  This code is inspired from Francois Ochsenbein's code
 */

#ifndef PPMX_H_
#define PPMX_H_

#include "useful.h"

#define PPMX_HEADER_FORMAT      "PPMX(46)/%5s.bin N=%d Noff=%d n4=%d n2=%d oDE=%d"
#define PPMX_HEADER_LENGTH      80
#define PPMX_RECORD_LENGTH      46
#define PPMX_DECLINATION_STEP   27000000
#define BINARY_FILE_NAME_LENGTH 10
#define BINARY_FILE_NAME_FORMAT_SOUTH "s%s.bin"
#define BINARY_FILE_NAME_FORMAT_NORTH "n%s.bin"
#define CHUNK_SHIFT_RA          23

typedef struct {
	int  raStartInMas;
	int  raEndInMas;
	int  declinationStartInMas;
	int  declinationEndInMas;
	int  magnitudeStartInMilliMag;
	int  magnitudeEndInMilliMag;
	char isArroundZeroRa;
	char** binaryFileNames;
	int numberOfBinaryFiles;
} searchZonePPMX;

typedef struct {
	int numberOfExtra2;
	int numberOfExtra4;
	int lengthOfAcceleratorTable;
	short* extraValues2;
	int* extraValues4;
	int* chunkOffsets;
	int* chunkNumberOfStars;
	int decStartInMas;
} headerInformationPPMX;

const searchZonePPMX findSearchZonePPMX(const double raInDeg,const double decInDeg,
		const double radiusInArcMin,const double magMin, const double magMax);
void allocateMemoryForSearchZonePPMX(searchZonePPMX* const mySearchZonePPMX);
int processOneFilePPMX(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX,
		const char* const binaryFileName);
int readHeaderPPMX(FILE* const inputStream, headerInformationPPMX* const headerInformation,
		const char* const binaryFileName);


#endif /* PPMX_H_ */
