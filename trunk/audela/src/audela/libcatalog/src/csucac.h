/*
 * csucac2.h
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

#ifndef CSUCAC_H_
#define CSUCAC_H_

#include "useful.h"

/* The index file name*/
#define INDEX_FILE_NAME_UCAC2                   "u2index.txt"
#define INDEX_FILE_NAME_UCAC3                   "u3index.asc"
#define INDEX_FILE_NAME_UCAC4                   "u4i/u4index.asc"
#define ZONE_FILE_FORMAT_NAME_UCAC2AND3         "%sz%03d"
#define ZONE_FILE_FORMAT_NAME_UCAC4             "%su4b/z%03d"
#define INDEX_TABLE_DEC_DIMENSION_UCAC2AND3     360
#define INDEX_TABLE_DEC_DIMENSION_UCAC4         900
#define INDEX_TABLE_RA_DIMENSION_UCAC2AND3      240
#define INDEX_TABLE_RA_DIMENSION_UCAC4          1440
#define INDEX_FILE_HEADER_NUMBER_OF_LINES_UCAC2 10
#define FORMAT_INDEX_FILE_UCAC2                 "%d %d %d %d %d %lf %lf"
#define FORMAT_INDEX_FILE_UCAC3AND4             "%d %d %d %d %lf"
/* 0.5 deg = 1800000 mas */
#define DEC_WIDTH_ZONE_MAS_UCAC2AND3            1800000.
/* 0.2 deg = 720000 mas */
#define DEC_WIDTH_ZONE_MAS_UCAC4                720000.
/* 0.1 hour = 1.5 deg = 5400000 mas */
#define RA_WIDTH_ZONE_MAS_UCAC2AND3             5400000.
/* 0.25 deg = 900000 mas */
#define RA_WIDTH_ZONE_MAS_UCAC4                 900000.

typedef struct {
	int   raInMas;
	int   decInMas;
	short ucacMagInCentiMag;
	char  errorRaInMas;
	char  errorDecInMas;
	char  numberOfObservations;
	char  errorOnUcacPositionInMas;
	char  numberOfCatalogsForPosition;
	char  majorCatalogIdForPosition;
	short centralEpochForMeanRaInMas;
	short centralEpochForMeanDecInMas;
	int   raProperMotionInOneTenthMasPerYear;
	int   decProperMotionInOneTenthMasPerYear;
	char  errorOnRaProperMotionInOneTenthMasPerYear;
	char  errorOnDecProperMotionInOneTenthMasPerYear;
	char  raProperMotionGoodnessOfFit;
	char  decProperMotionGoodnessOfFit;
	int   idFrom2Mass;
	short jMagnitude2MassInMilliMag;
	short hMagnitude2MassInMilliMag;
	short kMagnitude2MassInMilliMag;
	char  qualityFlag2Mass;
	char  ccFlag2Mass;
} starUcac2;

typedef struct {
	starUcac2* arrayOneD;
	int idOfFirstStarInArray;
	int length;
} arrayOneDOfStarUcac2;

typedef struct {
	arrayOneDOfStarUcac2* arrayTwoD;
	int length;
} arrayTwoDOfStarUcac2;

typedef struct {
	int   raInMas;
	int   distanceToSouthPoleInMas;
	short ucacFitMagInMilliMag;
	short ucacApertureMagInMilliMag;
	short ucacErrorMagInMilliMag;
	char  objectType;
	char  doubleStarFlag;
	short errorOnUcacRaInMas;
	short errorOnUcacDecInMas;
	char  numberOfCcdObservation;
	char  numberOfUsedCcdObservation;
	char  numberOfUsedCatalogsForProperMotion;
	char  numberOfMatchingCatalogs;
	short centralEpochForMeanRaInMas;
	short centralEpochForMeanDecInMas;
	int   raProperMotionInOneTenthMasPerYear;
	int   decProperMotionInOneTenthMasPerYear;
	short errorOnRaProperMotionInOneTenthMasPerYear;
	short errorOnDecProperMotionInOneTenthMasPerYear;
	int   idFrom2Mass;
	short jMagnitude2MassInMilliMag;
	short hMagnitude2MassInMilliMag;
	short kMagnitude2MassInMilliMag;
	char  jQualityFlag2Mass;
	char  hQualityFlag2Mass;
	char  kQualityFlag2Mass;
	char  jErrorMagnitude2MassInCentiMag;
	char  hErrorMagnitude2MassInCentiMag;
	char  kErrorMagnitude2MassInCentiMag;
	short bMagnitudeSCInMilliMag;
	short r2MagnitudeSCInMilliMag;
	short iMagnitudeSCInMilliMag;
	char  scStarGalaxieClass;
	char  bQualityFlagSC;
	char  r2QualityFlagSC;
	char  iQualityFlag2SC;
	char  hipparcosMatchFlag;
	char  tychoMatchFlag;
	char  ac2000MatchFlag;
	char  agk2bMatchFlag;
	char  agk2hMatchFlag;
	char  zaMatchFlag;
	char  byMatchFlag;
	char  lickMatchFlag;
	char  scMatchFlag;
	char  spmMatchFlag;
	char  yaleSpmObjectType;
	char  yaleSpmInputCatalog;
	char  ledaGalaxyMatchFlag;
	char  extendedSourceFlag2Mass;
	char  mposStarNumber;
} starUcac3;

typedef struct {
	starUcac3* arrayOneD;
	int idOfFirstStarInArray;
	int indexDec;
	int length;
} arrayOneDOfStarUcac3;

typedef struct {
	arrayOneDOfStarUcac3* arrayTwoD;
	int length;
} arrayTwoDOfStarUcac3;

/* Raw structures are read herein,  so the following structure  */
/* must be packed on byte boundaries:                           */
#pragma pack( 1)

typedef struct {
	int            raInMas;
	int            distanceToSouthPoleInMas;
	unsigned short ucacFitMagInMilliMag;
	unsigned short ucacApertureMagInMilliMag;
	unsigned char  ucacErrorMagInCentiMag;
	unsigned char  objectType;
	unsigned char  doubleStarFlag;
	char           errorOnUcacRaInMas;
	char           errorOnUcacDecInMas;
	unsigned char  numberOfCcdObservation;
	unsigned char  numberOfUsedCcdObservation;
	unsigned char  numberOfUsedCatalogsForProperMotion;
	unsigned short centralEpochForMeanRaInCentiMas;
	unsigned short centralEpochForMeanDecInCentiMas;
	short          raProperMotionInOneTenthMasPerYear;
	short          decProperMotionInOneTenthMasPerYear;
	char           errorOnRaProperMotionInOneTenthMasPerYear;
	char           errorOnDecProperMotionInOneTenthMasPerYear;
	unsigned int   idFrom2Mass;
	unsigned short jMagnitude2MassInMilliMag;
	unsigned short hMagnitude2MassInMilliMag;
	unsigned short kMagnitude2MassInMilliMag;
	unsigned char  qualityFlag2Mass[3];
	unsigned char  errorMagnitude2MassInCentiMag[3];
	unsigned short magnitudeAPASSInMilliMag[5];
	unsigned char  magnitudeErrorAPASSInCentiMag[5];
	unsigned char  gFlagYale;
	unsigned int   fk6HipparcosTychoSourceFlag;
	unsigned char  legaGalaxyMatchFlag;
	unsigned char  extendedSource2MassFlag;
	unsigned int   starIdentifier;
	unsigned short zoneNumberUcac2;
	unsigned int   recordNumberUcac2;
} starUcac4;
#pragma pack( )

typedef struct {
	starUcac4* arrayOneD;
	int idOfFirstStarInArray;
	int indexDec;
	int length;
} arrayOneDOfStarUcac4;

typedef struct {
	arrayOneDOfStarUcac4* arrayTwoD;
	int length;
} arrayTwoDOfStarUcac4;

typedef struct {
	int numberOfStarsInZone;
	int idOfFirstStarInZone;
} indexTableUcac;

typedef struct {
	int  raStartInMas;
	int  raEndInMas;
	char isArroundZeroRa;
	int  decStartInMas;
	int  decEndInMas;
	int  magnitudeStartInCentiMag;
	int  magnitudeEndInCentiMag;
} searchZoneUcac2;

typedef struct {
	int  raStartInMas;
	int  raEndInMas;
	char isArroundZeroRa;
	int  distanceToPoleStartInMas;
	int  distanceToPoleEndInMas;
	int  magnitudeStartInMilliMag;
	int  magnitudeEndInMilliMag;
} searchZoneUcac3And4;

/* Function prototypes for UCAC2 */
const searchZoneUcac2 findSearchZoneUcac2(const double ra,const double dec,const double radius,const double magMin, const double magMax);
indexTableUcac** readIndexFileUcac2(const char* const pathOfCatalog);
void retrieveIndexesUcac2(const searchZoneUcac2* const mySearchZone,int* const indexZoneDecStart,int* const indexZoneDecEnd,
		int* const indexZoneRaStart,int* const indexZoneRaEnd);
int retrieveUnfilteredStarsUcac2(const char* const pathOfCatalog, const searchZoneUcac2* const mySearchZone,
		indexTableUcac* const * const indexTable, arrayTwoDOfStarUcac2* const unFilteredStars);
int allocateUnfiltredStarUcac2(const arrayTwoDOfStarUcac2* const unFilteredStars, indexTableUcac* const * const indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd,const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int allocateUnfiltredStarForOneDecZoneUcac2(arrayOneDOfStarUcac2* const unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd);
int readUnfiltredStarUcac2(const char* const pathOfCatalog, const arrayTwoDOfStarUcac2* const unFilteredStars, indexTableUcac* const * const indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int readUnfiltredStarForOneDecZoneUcac2(const char* const pathOfCatalog, arrayOneDOfStarUcac2* const unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
		int indexDec, const int indexZoneRaStart,const int indexZoneRaEnd);
int isGoodStarUcac2(const starUcac2* const oneStar,const searchZoneUcac2* const mySearchZoneUcac2);
void releaseMemoryArrayTwoDOfStarUcac2(const arrayTwoDOfStarUcac2* const theTwoDArray);
void printUnfilteredStarUcac2(const arrayTwoDOfStarUcac2* const unFilteredStars);

/* Function prototypes for UCAC3 (some functions are common with UCAC4)*/
const searchZoneUcac3And4 findSearchZoneUcac3And4(const double ra,const double dec,const double radius,const double magMin, const double magMax);
indexTableUcac** readIndexFileUcac3(const char* const pathOfCatalog);
void retrieveIndexesUcac3(const searchZoneUcac3And4* const mySearchZone,int* const indexZoneDecStart,int* const indexZoneDecEnd,
		int* const indexZoneRaStart,int* const indexZoneRaEnd);
int retrieveUnfilteredStarsUcac3(const char* const pathOfCatalog, const searchZoneUcac3And4* const mySearchZone,
		indexTableUcac* const * const indexTable,arrayTwoDOfStarUcac3* const unFilteredStars);
int allocateUnfiltredStarUcac3(const arrayTwoDOfStarUcac3* const unFilteredStars, indexTableUcac* const * const indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd,const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int allocateUnfiltredStarForOneDecZoneUcac3(arrayOneDOfStarUcac3* const unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd);
int readUnfiltredStarUcac3(const char* const pathOfCatalog, const arrayTwoDOfStarUcac3* const unFilteredStars, indexTableUcac* const * const indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int readUnfiltredStarForOneDecZoneUcac3(const char* const pathOfCatalog, arrayOneDOfStarUcac3* const unFilteredStarsForOneDec,
		const indexTableUcac* const indexTableForOneDec,int indexDec, const int indexZoneRaStart,const int indexZoneRaEnd);
int isGoodStarUcac3(const starUcac3* const oneStar,const searchZoneUcac3And4* const mySearchZoneUcac3);
int filterStarsUcac3(const arrayTwoDOfStarUcac3* theUnFilteredStars, arrayOneDOfStarUcac3* theFilteredStars,const searchZoneUcac3And4* mySearchZoneUcac3);
void releaseMemoryArrayTwoDOfStarUcac3(const arrayTwoDOfStarUcac3* const theTwoDArray);
void printUnfilteredStarUcac3(const arrayTwoDOfStarUcac3* const unFilteredStars);

/* Function prototypes for UCAC3 */
void retrieveIndexesUcac4(const searchZoneUcac3And4* const mySearchZone,int* const indexZoneDecStart,int* const indexZoneDecEnd,int* const indexZoneRaStart,int* const indexZoneRaEnd);
indexTableUcac** readIndexFileUcac4(const char* const pathOfCatalog);
int retrieveUnfilteredStarsUcac4(const char* const pathOfCatalog, const searchZoneUcac3And4* const mySearchZone,
		indexTableUcac* const * const indexTable,arrayTwoDOfStarUcac4* const unFilteredStars);
int allocateUnfiltredStarUcac4(const arrayTwoDOfStarUcac4* const unFilteredStars, indexTableUcac* const * const indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd,const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int allocateUnfiltredStarForOneDecZoneUcac4(arrayOneDOfStarUcac4* const unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd);
int readUnfiltredStarUcac4(const char* const pathOfCatalog, const arrayTwoDOfStarUcac4* const unFilteredStars, indexTableUcac* const * const indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int readUnfiltredStarForOneDecZoneUcac4(const char* const pathOfCatalog, arrayOneDOfStarUcac4* const unFilteredStarsForOneDec,
		const indexTableUcac* const indexTableForOneDec,int indexDec, const int indexZoneRaStart,const int indexZoneRaEnd);
int isGoodStarUcac4(const starUcac4* const oneStar,const searchZoneUcac3And4* const mySearchZoneUcac3);
int filterStarsUcac4(const arrayTwoDOfStarUcac4* theUnFilteredStars, arrayOneDOfStarUcac4* theFilteredStars,const searchZoneUcac3And4* mySearchZoneUcac4);
void releaseMemoryArrayTwoDOfStarUcac4(const arrayTwoDOfStarUcac4* const theTwoDArray);
void printUnfilteredStarUcac4(const arrayTwoDOfStarUcac4* const unFilteredStars);

#endif /* CSUCAC_H_ */

