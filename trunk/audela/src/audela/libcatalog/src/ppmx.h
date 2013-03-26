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

/* PPMX */
#define PPMX_HEADER_FORMAT      "PPMX(46)/%5s.bin N=%d Noff=%d n4=%d n2=%d oDE=%d"
#define PPMX_HEADER_LENGTH      80
#define PPMX_RECORD_LENGTH      46
#define PPMX_DECLINATION_STEP              27000000
#define PPMX_BINARY_FILE_NAME_LENGTH       10
#define PPMX_BINARY_FILE_NAME_FORMAT_SOUTH "s%s.bin"
#define PPMX_BINARY_FILE_NAME_FORMAT_NORTH "n%s.bin"
#define PPMX_CHUNK_SHIFT_RA     23

/* PPMXL */
#define PPMXL_HEADER_FORMAT                 "N=%d n4=%d Noff=%d*2 oDE=%dmas"
#define PPMXL_HEADER_UNUSEFUL_LENGTH        21
#define PPMXL_SHORT_RECORD_LENGTH           29
#define PPMXL_DECLINATION_FIRST_STEP        3600000
#define PPMXL_DECLINATION_SECOND_STEP       900000
#define PPMXL_BINARY_FILE_NAME_LENGTH       8
#define PPMXL_BINARY_FILE_NAME_FORMAT_SOUTH "s%02d%c.bin"
#define PPMXL_BINARY_FILE_NAME_FORMAT_NORTH "n%02d%c.bin"
#define binRA(s)                            ((s[12]&0x7f)<<24)|(s[13]<<16)|(s[14]<<8)|s[15]
#define NUMBER_OF_2MASS_MAGNITUDES          3
#define NUMBER_OF_USNO_MAGNITUDES           5

#define BAD_MAGNITUDE                    	-32768	/* NULL value for int2 values   */

typedef struct {
	searchZoneRaDecMas subSearchZone;
	magnitudeBoxMilliMag  magnitudeBox;
	char** binaryFileNames;
	int numberOfBinaryFiles;
} searchZonePPMX;

typedef struct {
	int numberOfExtra2;
	int numberOfExtra4;
	int lengthOfAcceleratorTable;
	short int* extraValues2;
	int* extraValues4;
	int* chunkOffsets;
	int* chunkNumberOfStars;
	int decStartInMas;
} headerInformationPPMX;

typedef struct {
	int numberOfExtra4;
	int lengthOfAcceleratorTable;
	int* extraValues4;
	int* chunkOffsets;
	int* chunkOffRa;
	int* chunkSizes;
	int decStartInMas;
} headerInformationPPMXL;

const searchZonePPMX findSearchZonePPMX(const double raInDeg,const double decInDeg,
		const double radiusInArcMin,const double magMin, const double magMax);
const searchZonePPMX findSearchZonePPMXL(const double raInDeg,const double decInDeg,
		const double radiusInArcMin,const double magMin, const double magMax);
void allocateMemoryForSearchZonePPMX(searchZonePPMX* const mySearchZonePPMX, const size_t fileNameLength);
int processOneFilePPMX(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX,
		const char* const binaryFileName);
int processOneFilePPMXL(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX,
		const char* const binaryFileName);
int readHeaderPPMX(FILE* const inputStream, headerInformationPPMX* const headerInformation,
		const char* const binaryFileName);
int readHeaderPPMXL(FILE* const inputStream, headerInformationPPMXL* const headerInformation,
		const char* const binaryFileName);
int processChunksPPMX(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX,FILE* const inputStream,
		const headerInformationPPMX* const headerInformation,const int chunkStart,const int chunkEnd, const char* const binaryFileName);
int processChunksPPMXL(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX,FILE* const inputStream,
		const headerInformationPPMXL* const headerInformation,const int chunkStart,const int chunkEnd, const char* const binaryFileName);
void processBufferedDataPPMX(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX,
		unsigned char* buffer, const headerInformationPPMX* const headerInformation, const int raStart);
void processBufferedDataPPMXL(Tcl_DString* const dsptr,const searchZonePPMX* const mySearchZonePPMX, unsigned char* buffer,
		const headerInformationPPMXL* const headerInformation, int* const lengthOfRecord);
void sJname(char * const str, const int ra, const int de, const int modJ);

#endif /* PPMX_H_ */
