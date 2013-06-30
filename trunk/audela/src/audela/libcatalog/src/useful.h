/*
 * useful.h
 *
 *  Created on: Dec 19, 2011
 *      Author: Y. Damerdji
 */

#ifndef USEFUL_H_
#define USEFUL_H_

#include "libcatalog.h"

/***************************************************************************/
/*                            Useful definitions                      */
/***************************************************************************/
#ifndef max
#   define max(a,b) (((a)>(b))?(a):(b))
#endif

#ifndef min
#   define min(a,b) (((a)<(b))?(a):(b))
#endif

/* pi */
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif /* M_PI */

/* 1 mag = 10 deciimag */
#define MAG2DECIMAG   10.
/* 1 mag = 100 centimag */
#define MAG2CENTIMAG  100.
/* 1 mag = 1000 milli mag */
#define MAG2MILLIMAG  1000.
/* 1 hour = 15 deg */
#define HOUR2DEG      15.
/* 1 deg = 60 arcmin */
#define DEG2ARCMIN    60.

/* dec at the south pole in deg */
#define DEC_SOUTH_POLE_DEG -90.
/* dec at the north pole in deg */
#define DEC_NORTH_POLE_DEG  90.
/* 1 deg = pi / 180. rad = 0.01745329251994329547 rad */
#define DEC2RAD 0.01745329251994329547

/* 1 deg = 3600000 mas (= milli arc second) */
#define DEG2MAS         3600000.
#define DEG2DECIMAS     36000000.
#define DEG2MICRODEG    1.e6
/* 0 deg = 0 mas */
#define START_RA_MAS    0
/* 360 deg = 1296000000. mas */
#define COMPLETE_RA_MAS 1296000000
/* 0 deg */
#define START_RA_DEG    0
/* 360 deg */
#define COMPLETE_RA_DEG 360.

/* 1 deg = 360000 cas (= centi arc second)*/
#define DEG2CAS         360000
/* 0 deg = 0 cas */
#define START_RA_CAS    0
/* 360 deg = 129600000. cas */
#define COMPLETE_RA_CAS 129600000
/* dec at the south pole in mas : -90 deg = -324000000. mas */
#define DEC_SOUTH_POLE_MAS -324000000
/* dec at the north pole in mas : +90 deg = +324000000. mas */
#define DEC_NORTH_POLE_MAS  324000000
/* distance to south pole at at the south pole in Cas : 0 deg = 0. cas */
#define DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_CAS 0
/* distance to south pole at at the north pole in mas : +180 deg = 64800000. cas */
#define DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_CAS 64800000
/* distance to south pole at at the south pole in Mas : 0 deg = 0. mas */
#define DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS 0.
/* distance to south pole at at the north pole in mas : +180 deg = 648000000. mas */
#define DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS 648000000

#define STRING_COMMON_LENGTH 1024

/* Search zones structures */
/* {RA,DEC} in DEGREE */
typedef struct {
	double  raStartInDeg;
	double  raEndInDeg;
	double  decStartInDeg;
	double  decEndInDeg;
	char isArroundZeroRa;
} searchZoneRaDecDeg;
/* {RA,DEC} in MAS */
typedef struct {
	int  raStartInMas;
	int  raEndInMas;
	int  decStartInMas;
	int  decEndInMas;
	char isArroundZeroRa;
} searchZoneRaDecMas;
/* {RA,DEC} in Micro DEG */
typedef struct {
	int   raStartInMicroDegree;
	int   raEndInMicroDegree;
	int   decStartInMicroDegree;
	int   decEndInMicroDegree;
	char  isArroundZeroRa;
} searchZoneRaDecMicroDeg;
/* {RA,SPD} in MAS */
typedef struct {
	int  raStartInMas;
	int  raEndInMas;
	int  spdStartInMas;
	int  spdEndInMas;
	char isArroundZeroRa;
} searchZoneRaSpdMas;
/* {RA,SPD} in CAS */
typedef struct {
	int  raStartInCas;
	int  raEndInCas;
	int  spdStartInCas;
	int  spdEndInCas;
	char isArroundZeroRa;
} searchZoneRaSpdCas;

/* Magnitude box structures */
/* Milli mag */
typedef struct {
	int  magnitudeStartInMilliMag;
	int  magnitudeEndInMilliMag;
} magnitudeBoxMilliMag;
/* Centi mag */
typedef struct {
	short int  magnitudeStartInCentiMag;
	short int  magnitudeEndInCentiMag;
} magnitudeBoxCentiMag;
/* Deci mag */
typedef struct {
	short int  magnitudeStartInDeciMag;
	short int  magnitudeEndInDeciMag;
} magnitudeBoxDeciMag;
/* Mag */
typedef struct {
	int  magnitudeStartInMag;
	int  magnitudeEndInMag;
} magnitudeBoxMag;

#define DEBUG 0

int decodeInputs(char* const outputLogChar, const int argc, char* const argv[],
		char* const pathToCatalog,double* const ra, double* const dec,
		double* const radius, double* const magBright, double* const magFaint);
void releaseSimpleArray(void* theOneDArray);
void releaseDoubleArray(void** theTwoDArray, const int firstDimension);
void addLastSlashToPath(char* onePath);
int convertBig2LittleEndianForInteger(int l);
void convertBig2LittleEndianForArrayOfInteger(int* const inputArray, const int length);
short convertBig2LittleEndianForShort(short int l);
void convertBig2LittleEndianForArrayOfShort(short int* const inputArray, const int length);
int sumNumberOfElements(const int* const inputArray,const int indexStart,const int indexEnd);
int findComponentNumber(const int* const sortedArrayOfValues, const int lengthOfArray, const int value);
void fillSearchZoneRaDecDeg(searchZoneRaDecDeg* const theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin);
void fillSearchZoneRaDecMas(searchZoneRaDecMas* const theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin);
void fillSearchZoneRaSpdMas(searchZoneRaSpdMas* const theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin);
void fillSearchZoneRaDecMicroDeg(searchZoneRaDecMicroDeg* const theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin);
void fillSearchZoneRaSpdCas(searchZoneRaSpdCas* const theSearchZone, const double raInDeg,const double decInDeg,
		const double radiusInArcMin);
void fillMagnitudeBoxMilliMag(magnitudeBoxMilliMag* const magnitudeBox, const double magMin, const double magMax);
void fillMagnitudeBoxCentiMag(magnitudeBoxCentiMag* const magnitudeBox, const double magMin, const double magMax);
void fillMagnitudeBoxDeciMag(magnitudeBoxDeciMag* const magnitudeBox, const double magMin, const double magMax);
void fillMagnitudeBoxMag(magnitudeBoxMag* const magnitudeBox, const double magMin, const double magMax);
/* Francois Ochsenbein's methods */
int getBits(unsigned char * const a, const int b, const int length);
int xget4(unsigned char * const a, const int b, const int length, const int max, const int * const xtra4);
int xget2(unsigned char * const a, const int b, const int length, const int max, const short int* const xtra2);
int strloc(char * const text, const int c);

#endif /* USEFUL_H_ */
