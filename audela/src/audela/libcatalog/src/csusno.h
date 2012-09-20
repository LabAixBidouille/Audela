/*
 * csucac2.h
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

#ifndef CSUSNO_H_
#define CSUSNO_H_

#include "useful.h"

/* 1 deg = 360000 cas (= centi arc second)*/
#define DEG2CAS         360000.
/* 0 deg = 0 cas */
#define START_RA_CAS    0
/* 360 deg = 129600000. cas */
#define COMPLETE_RA_CAS 129600000
/* distance to south pole at at the south pole in Cas : 0 deg = 0. cas */
#define DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_CAS 0
/* distance to south pole at at the north pole in mas : +180 deg = 64800000. cas */
#define DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_CAS 64800000
/* Number of ACC and CAT files*/
#define NUMBER_OF_CATALOG_FILES 24
/* Extensions and format */
#define DOT_ACC_EXTENSION                       ".ACC"
#define DOT_CAT_EXTENSION                       ".CAT"
#define CATALOG_NAME_FORMAT                     "ZONE%04d"
#define CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DEGREE      7.5
#define CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DECI_DEGREE 75
#define ACC_FILE_NUMBER_OF_LINES                96
#define ACC_FILE_RA_ZONE_WIDTH_IN_HOUR          0.25
#define ACC_FILE_RA_ZONE_WIDTH_IN_DEGREE        3.75
/* Format of the ACC file */
#ifdef OS_LINUX_GCC_SO
#define FORMAT_ACC "%lf %d %d"
#else
#define FORMAT_ACC "%lf %ld %ld"
#endif

/* USNO2A ACC files */
typedef struct {
	int* arrayOfIds;
	int* arrayOfPosition;
	unsigned int* numberOfStars;
} accFiles;

typedef struct {
	int    raStartInCas;
	int    raEndInCas;
	char   isArroundZeroRa;
	int    distanceToPoleStartInCas;
	int    distanceToPoleEndInCas;
	short  magnitudeStartInDeciMag;
	short  magnitudeEndInDeciMag;
	int    indexOfFirstDistanceToPoleZone;
	int    indexOfLastDistanceToPoleZone;
	int    indexOfFirstRightAscensionZone;
	int    indexOfLastRightAscensionZone;
} searchZoneUsnoa2;

typedef struct {
	int ra;
	int spd;
	int mags;
} starUsno;

const searchZoneUsnoa2 findSearchZoneUsnoa2(const double ra,const double dec,const double radius,const double magMin, const double magMax);
int usnoa2Big2LittleEndianLong(int l);
const accFiles* readAllCatalogFiles(const char* const pathOfCatalog, int* maximumNumberOfStars);
void freeAllCatalogFiles(const accFiles* allAccFiles);
double usnoa2GetUsnoBleueMagnitudeInDeciMag(int magL);
double usnoa2GetUsnoRedMagnitudeInDeciMag(int magL);
int usnoa2GetUsnoSign(int magL);
int usnoa2GetUsnoQflag(int magL);
int usnoa2GetUsnoField(int magL);
int processOneZoneNotCentredOnZeroRA(Tcl_DString* dsptr, FILE* inputStream,accFiles oneAccFile,
		starUsno* const arrayOfStars,const searchZoneUsnoa2* mySearchZoneUsnoa2, const int indexOfRA);
int processOneZoneCentredOnZeroRA(Tcl_DString* dsptr, FILE* inputStream,accFiles oneAccFile,
		starUsno* const arrayOfStars,const searchZoneUsnoa2* mySearchZoneUsnoa2, const int indexOfRA);

#endif /* CSUSNO_H_ */

