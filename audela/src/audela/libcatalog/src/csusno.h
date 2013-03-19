/*
 * csucac2.h
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

#ifndef CSUSNO_H_
#define CSUSNO_H_

#include "useful.h"

/* Number of ACC and CAT files*/
#define NUMBER_OF_CATALOG_FILES_USNO            24
/* Extensions and format */
#define DOT_ACC_EXTENSION                       ".ACC"
#define DOT_CAT_EXTENSION                       ".CAT"
#define CATALOG_NAME_FORMAT                     "ZONE%04d"
#define OUTPUT_ID_FORMAT                        "%04d-%08d"
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
	unsigned int* arrayOfPosition;
	unsigned int* numberOfStars;
} indexTableUsno;

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
const indexTableUsno* readIndexFileUsno(const char* const pathOfCatalog, const searchZoneUsnoa2* const mySearchZoneUsnoa2, int* const maximumNumberOfStars);
void freeAllUsnoCatalogFiles(const indexTableUsno* const allAccFiles,const searchZoneUsnoa2* const mySearchZoneUsnoa2);
double usnoa2GetUsnoBleueMagnitudeInDeciMag(const int magL);
double usnoa2GetUsnoRedMagnitudeInDeciMag(const int magL);
int usnoa2GetUsnoSign(const int magL);
int usnoa2GetUsnoQflag(const int magL);
int usnoa2GetUsnoField(const int magL);
int processOneZoneUsnoNotCentredOnZeroRA(Tcl_DString* const dsptr, FILE* const inputStream,const indexTableUsno* const oneAccFile,
		starUsno* const arrayOfStars,const searchZoneUsnoa2* const mySearchZoneUsnoa2, const int indexOfCatalog, const int indexOfRA);
int processOneZoneUsnoCentredOnZeroRA(Tcl_DString* const dsptr, FILE* const inputStream,const indexTableUsno* const oneAccFile,
		starUsno* const arrayOfStars,const searchZoneUsnoa2* const mySearchZoneUsnoa2, const int indexOfCatalog, const int indexOfRA);

#endif /* CSUSNO_H_ */

