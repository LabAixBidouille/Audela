/*
 * csucac2.h
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

#ifndef CSUCAC_H_
#define CSUCAC_H_

#include "libcatalog.h"
#include "useful.h"

/* 1 mag = 100 centimag */
#define MAG2CENTIMAG 100.
/* 1 mag = 1000 mili mag */
#define MAG2MILIMAG 1000.
/* 1 deg = 3600000 mas */
#define DEG2MAS 3600000.
/* 1 deg = 60 arcmin */
#define DEG2ARCMIN 60.
/* 0 deg = 0 mas */
#define START_RA_MAS    0.
/* 360 deg = 1296000000. mas */
#define COMPLETE_RA_MAS 1296000000.

/* dec at the south pole in deg */
#define DEC_SOUTH_POLE_DEG -90.
/* dec at the north pole in deg */
#define DEC_NORTH_POLE_DEG 90.
/* dec at the south pole in mas : -90 deg = -324000000. mas */
#define DEC_SOUTH_POLE_MAS -324000000.
/* dec at the north pole in mas : +90 deg = +324000000. mas */
#define DEC_NORTH_POLE_MAS 324000000.
/* distance to south pole at at the south pole in mas : 0 deg = 0. mas */
#define DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS 0.
/* distance to south pole at at the north pole in mas : +180 deg = 648000000. mas */
#define DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS 648000000.
/* 1 deg = pi / 180. rad = 0.01745329251994329547 rad */
#define DEC2RAD 0.01745329251994329547
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
/* 0.1 hour = 1.5 deg = 5400000 mas */
#define RA_WIDTH_ZONE_MAS 5400000.
#define STRING_COMMON_LENGTH 1024
#define DEBUG 0

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
	short jMagnitude2MassInMiliMag;
	short hMagnitude2MassInMiliMag;
	short kMagnitude2MassInMiliMag;
	char qualityFlag2Mass;
	char ccFlag2Mass;
} starUcac2;

typedef struct {
	int raStartInMas;
	int raEndInMas;
	char   isArroundZeroRa;
	int decStartInMas;
	int decEndInMas;
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
	short ucacFitMagInMiliMag;
	short ucacApertureMagInMiliMag;
	short ucacErrorMagInMiliMag;
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
	short jMagnitude2MassInMiliMag;
	short hMagnitude2MassInMiliMag;
	short kMagnitude2MassInMiliMag;
	char jQualityFlag2Mass;
	char hQualityFlag2Mass;
	char kQualityFlag2Mass;
	char jErrorMagnitude2MassInCentiMag;
	char hErrorMagnitude2MassInCentiMag;
	char kErrorMagnitude2MassInCentiMag;
	short bMagnitudeSCInMiliMag;
	short r2MagnitudeSCInMiliMag;
	short iMagnitudeSCInMiliMag;
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
	int raStartInMas;
	int raEndInMas;
	char   isArroundZeroRa;
	int distanceToPoleStartInMas;
	int distanceToPoleEndInMas;
	int magnitudeStartInMiliMag;
	int magnitudeEndInMiliMag;
} searchZoneUcac3;

typedef struct {
	starUcac3* arrayOneD;
	int length;
} arrayOneDOfStarUcac3;

typedef struct {
	arrayOneDOfStarUcac3* arrayTwoD;
	int length;
} arrayTwoDOfStarUcac3;

/* Function prototypes */
const searchZoneUcac2 findSearchZoneUcac2(const double ra,const double dec,const double radius,const double magMin, const double magMax);
const searchZoneUcac3 findSearchZoneUcac3(const double ra,const double dec,const double radius,const double magMin, const double magMax);
int retrieveUnFilteredStarsUcac2(const char* pathOfCatalog, searchZoneUcac2* mySearchZone, int** indexTable, arrayTwoDOfStarUcac2* theUnilteredStars);
int retrieveUnFilteredStarsUcac3(const char* pathOfCatalog, searchZoneUcac3* mySearchZone, int** indexTable, arrayTwoDOfStarUcac3* theUnilteredStars);
int** readIndexFileUcac2(const char* pathOfCatalog);
int** readIndexFileUcac3(const char* pathOfCatalog);
void retrieveIndexesUcac2(searchZoneUcac2* mySearchZone,int* indexZoneDecStart,int* indexZoneDecEnd,int* indexZoneRaStart,int* indexZoneRaEnd);
void retrieveIndexesUcac3(searchZoneUcac3* mySearchZone,int* indexZoneDecStart,int* indexZoneDecEnd,int* indexZoneRaStart,int* indexZoneRaEnd);
int allocateUnfiltredStarUcac2(arrayTwoDOfStarUcac2* theUnilteredStars, int** indexTable,const int indexZoneDecStart,const int indexZoneDecEnd,
		const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int allocateUnfiltredStarUcac3(arrayTwoDOfStarUcac3* theUnilteredStars, int** indexTable,const int indexZoneDecStart,const int indexZoneDecEnd,
		const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int allocateUnfiltredStarForOneDecZoneUcac2(arrayOneDOfStarUcac2* unFilteredStarsForOneDec, int* indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd);
int allocateUnfiltredStarForOneDecZoneUcac3(arrayOneDOfStarUcac3* unFilteredStarsForOneDec, int* indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd);
int readUnfiltredStarUcac2(const char* pathOfCatalog, arrayTwoDOfStarUcac2* theUnilteredStars, int** indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int readUnfiltredStarUcac3(const char* pathOfCatalog, arrayTwoDOfStarUcac3* theUnilteredStars, int** indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa);
int readUnfiltredStarForOneDecZoneUcac2(const char* pathOfCatalog, arrayOneDOfStarUcac2* notFilteredStarsForOneDec, int* indexTableForOneDec,
		int indexDec, const int indexZoneRaStart,const int indexZoneRaEnd);
int readUnfiltredStarForOneDecZoneUcac3(const char* pathOfCatalog, arrayOneDOfStarUcac3* notFilteredStarsForOneDec, int* indexTableForOneDec,
		int indexDec, const int indexZoneRaStart,const int indexZoneRaEnd);
void releaseMemoryArrayTwoDOfStarUcac2(arrayTwoDOfStarUcac2* theTwoDArray);
void releaseMemoryArrayTwoDOfStarUcac3(arrayTwoDOfStarUcac3* theTwoDArray);
void printUnfilteredStarUcac2(arrayTwoDOfStarUcac2* theUnilteredStars);
void printUnfilteredStarUcac3(arrayTwoDOfStarUcac3* theUnilteredStars);
int filterStarsUcac2(arrayTwoDOfStarUcac2* theUnFilteredStars,arrayOneDOfStarUcac2* theFilteredStars,searchZoneUcac2* mySearchZone);
int filterStarsUcac3(arrayTwoDOfStarUcac3* theUnFilteredStars,arrayOneDOfStarUcac3* theFilteredStars,searchZoneUcac3* mySearchZone);

#endif /* CSUCAC_H_ */
