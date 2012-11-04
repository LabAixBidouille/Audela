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
#define NUMBER_OF_CATALOG_FILES 24
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
const accFiles* readCatalogFiles(const char* const pathOfCatalog, const searchZoneUsnoa2* mySearchZoneUsnoa2, int* maximumNumberOfStars);
void freeAllCatalogFiles(const accFiles* allAccFiles,const searchZoneUsnoa2* mySearchZoneUsnoa2);
double usnoa2GetUsnoBleueMagnitudeInDeciMag(int magL);
double usnoa2GetUsnoRedMagnitudeInDeciMag(int magL);
int usnoa2GetUsnoSign(int magL);
int usnoa2GetUsnoQflag(int magL);
int usnoa2GetUsnoField(int magL);
int processOneZoneNotCentredOnZeroRA(Tcl_DString* dsptr, FILE* inputStream,accFiles oneAccFile,
		starUsno* const arrayOfStars,const searchZoneUsnoa2* mySearchZoneUsnoa2, const int indexOfCatalog, const int indexOfRA);
int processOneZoneCentredOnZeroRA(Tcl_DString* dsptr, FILE* inputStream,accFiles oneAccFile,
		starUsno* const arrayOfStars,const searchZoneUsnoa2* mySearchZoneUsnoa2, const int indexOfCatalog, const int indexOfRA);

#endif /* CSUSNO_H_ */

