/*
 * csucac2.h
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

#ifndef CSUCAC_H_
#define CSUCAC_H_

#include "useful.h"

/* 1 deg = 3600000 mas (= milli arc second) */
#define DEG2MAS         3600000.
/* 0 deg = 0 mas */
#define START_RA_MAS    0
/* 360 deg = 1296000000. mas */
#define COMPLETE_RA_MAS 1296000000

/* The index file name*/
#define INDEX_FILE_NAME_UCAC2 "u2index.txt"
#define INDEX_FILE_NAME_UCAC3 "u3index.asc"
#define ZONE_FILE_FORMAT_NAME "%s/z%03d"
#define INDEX_TABLE_DEC_DIMENSION 360
#define INDEX_TABLE_RA_DIMENSION 240
#define INDEX_FILE_HEADER_NUMBER_OF_LINES 10
#define FORMAT_INDEX_FILE_UCAC2 "%d %d %d %d %d %lf %lf"
#define FORMAT_INDEX_FILE_UCAC3 "%d %d %d %d %lf"
/* 0.5 deg = 1800000 mas */
#define DEC_WIDTH_ZONE_MAS 1800000.
/* dec at the south pole in mas : -90 deg = -324000000. mas */
#define DEC_SOUTH_POLE_MAS -324000000
/* dec at the north pole in mas : +90 deg = +324000000. mas */
#define DEC_NORTH_POLE_MAS  324000000
/* distance to south pole at at the south pole in Mas : 0 deg = 0. mas */
#define DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS 0.
/* distance to south pole at at the north pole in mas : +180 deg = 648000000. mas */
#define DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS 648000000
/* 0.1 hour = 1.5 deg = 5400000 mas */
#define RA_WIDTH_ZONE_MAS 5400000.
#define STRING_COMMON_LENGTH 1024

typedef struct {
	int raInMas;
	int decInMas;
	short ucacMagInCentiMag;
	char errorRaInMas;
	char errorDecInMas;
	char numberOfObservations;
	char errorOnUcacPositionInMas;
	char numberOfCatalogsForPosition;
	char majorCatalogIdForPosition;
	short centralEpochForMeanRaInMas;
	short centralEpochForMeanDecInMas;
	int raProperMotionInOneTenthMasPerYear;
	int decProperMotionInOneTenthMasPerYear;
	char errorOnRaProperMotionInOneTenthMasPerYear;
	char errorOnDecProperMotionInOneTenthMasPerYear;
	char raProperMotionGoodnessOfFit;
	char decProperMotionGoodnessOfFit;
	int idFrom2Mass;
	short jMagnitude2MassInMilliMag;
	short hMagnitude2MassInMilliMag;
	short kMagnitude2MassInMilliMag;
	char qualityFlag2Mass;
	char ccFlag2Mass;
} starUcac2;

typedef struct {
	int   raStartInMas;
	int   raEndInMas;
	char  isArroundZeroRa;
	int   decStartInMas;
	int   decEndInMas;
	short magnitudeStartInCentiMag;
	short magnitudeEndInCentiMag;
} searchZoneUcac2;

typedef struct {
	starUcac2* arrayOneD;
	int length;
} arrayOneDOfStarUcac2;

typedef struct {
	arrayOneDOfStarUcac2* arrayTwoD;
	int length;
} arrayTwoDOfStarUcac2;

typedef struct {
	int raInMas;
	int distanceToSouthPoleInMas;
	short ucacFitMagInMilliMag;
	short ucacApertureMagInMilliMag;
	short ucacErrorMagInMilliMag;
	char objectType;
	char doubleStarFlag;
	short errorOnUcacRaInMas;
	short errorOnUcacDecInMas;
	char numberOfCcdObservation;
	char numberOfUsedCcdObservation;
	char numberOfUsedCatalogsForProperMotion;
	char numberOfMatchingCatalogs;
	short centralEpochForMeanRaInMas;
	short centralEpochForMeanDecInMas;
	int raProperMotionInOneTenthMasPerYear;
	int decProperMotionInOneTenthMasPerYear;
	short errorOnRaProperMotionInOneTenthMasPerYear;
	short errorOnDecProperMotionInOneTenthMasPerYear;
	int idFrom2Mass;
	short jMagnitude2MassInMilliMag;
	short hMagnitude2MassInMilliMag;
	short kMagnitude2MassInMilliMag;
	char jQualityFlag2Mass;
	char hQualityFlag2Mass;
	char kQualityFlag2Mass;
	char jErrorMagnitude2MassInCentiMag;
	char hErrorMagnitude2MassInCentiMag;
	char kErrorMagnitude2MassInCentiMag;
	short bMagnitudeSCInMilliMag;
	short r2MagnitudeSCInMilliMag;
	short iMagnitudeSCInMilliMag;
	char scStarGalaxieClass;
	char bQualityFlagSC;
	char r2QualityFlagSC;
	char iQualityFlag2SC;
	char hipparcosMatchFlag;
	char tychoMatchFlag;
	char ac2000MatchFlag;
	char agk2bMatchFlag;
	char agk2hMatchFlag;
	char zaMatchFlag;
	char byMatchFlag;
	char lickMatchFlag;
	char scMatchFlag;
	char spmMatchFlag;
	char yaleSpmObjectType;
	char yaleSpmInputCatalog;
	char ledaGalaxyMatchFlag;
	char extendedSourceFlag2Mass;
	char mposStarNumber;
} starUcac3;

typedef struct {
	int  raStartInMas;
	int  raEndInMas;
	char isArroundZeroRa;
	int  distanceToPoleStartInMas;
	int  distanceToPoleEndInMas;
	int  magnitudeStartInMilliMag;
	int  magnitudeEndInMilliMag;
} searchZoneUcac3;

typedef struct {
	starUcac3* arrayOneD;
	int length;
} arrayOneDOfStarUcac3;

typedef struct {
	arrayOneDOfStarUcac3* arrayTwoD;
	int length;
} arrayTwoDOfStarUcac3;

/* Function prototypes for UCAC2 */
const searchZoneUcac2 findSearchZoneUcac2(const double ra,const double dec,const double radius,const double magMin, const double magMax);
int** readIndexFileUcac2(const char* const pathOfCatalog);
void retrieveIndexesUcac2(const searchZoneUcac2* mySearchZone,int* indexZoneDecStart,int* indexZoneDecEnd,int* indexZoneRaStart,int* indexZoneRaEnd);
int retrieveUnfilteredStarsUcac2(const char* const pathOfCatalog, const searchZoneUcac2* mySearchZone, int** indexTable, arrayTwoDOfStarUcac2* theUnfilteredStars);
int allocateUnfiltredStarUcac2(const arrayTwoDOfStarUcac2* theUnilteredStars, int** indexTable,const int indexZoneDecStart,const int indexZoneDecEnd,
		const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int allocateUnfiltredStarForOneDecZoneUcac2(arrayOneDOfStarUcac2* unFilteredStarsForOneDec, const int* const indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd);
int readUnfiltredStarUcac2(const char* const pathOfCatalog, const arrayTwoDOfStarUcac2* theUnilteredStars, int** indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int readUnfiltredStarForOneDecZoneUcac2(const char* const pathOfCatalog, const arrayOneDOfStarUcac2* notFilteredStarsForOneDec, const int* const indexTableForOneDec,
		int indexDec, const int indexZoneRaStart,const int indexZoneRaEnd);
int filterStarsUcac2(const arrayTwoDOfStarUcac2* theUnfilteredStars,arrayOneDOfStarUcac2* thefilteredStars,const searchZoneUcac2* mySearchZone);
void releaseMemoryArrayTwoDOfStarUcac2(const arrayTwoDOfStarUcac2* theTwoDArray);
void printUnfilteredStarUcac2(const arrayTwoDOfStarUcac2* theUnilteredStars);

/* Function prototypes for UCAC3 */
const searchZoneUcac3 findSearchZoneUcac3(const double ra,const double dec,const double radius,const double magMin, const double magMax);
int** readIndexFileUcac3(const char* const pathOfCatalog);
void retrieveIndexesUcac3(const searchZoneUcac3* mySearchZone,int* indexZoneDecStart,int* indexZoneDecEnd,int* indexZoneRaStart,int* indexZoneRaEnd);
int retrieveUnfilteredStarsUcac3(const char* const pathOfCatalog, const searchZoneUcac3* mySearchZone, int* const* indexTable,
		arrayTwoDOfStarUcac3* theUnfilteredStars);
int allocateUnfiltredStarUcac3(const arrayTwoDOfStarUcac3* theUnilteredStars, int* const* indexTable,const int indexZoneDecStart,
		const int indexZoneDecEnd,const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int allocateUnfiltredStarForOneDecZoneUcac3(arrayOneDOfStarUcac3* unFilteredStarsForOneDec, const int* const indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd);
int readUnfiltredStarUcac3(const char* const pathOfCatalog, const arrayTwoDOfStarUcac3* theUnfilteredStars, int* const* indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int readUnfiltredStarForOneDecZoneUcac3(const char* const pathOfCatalog, const arrayOneDOfStarUcac3* notFilteredStarsForOneDec,
		const int* const indexTableForOneDec,int indexDec, const int indexZoneRaStart,const int indexZoneRaEnd);
int filterStarsUcac3(const arrayTwoDOfStarUcac3* theUnFilteredStars, arrayOneDOfStarUcac3* theFilteredStars,const searchZoneUcac3* mySearchZone);
void releaseMemoryArrayTwoDOfStarUcac3(const arrayTwoDOfStarUcac3* theTwoDArray);
void printUnfilteredStarUcac3(const arrayTwoDOfStarUcac3* theUnilteredStars);

#endif /* CSUCAC_H_ */

