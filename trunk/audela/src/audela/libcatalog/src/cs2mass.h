/*
 * cs2mass.h
 *
 *  Created on: Nov 05, 2012
 *      Author: Y. Damerdji
 */

#ifndef CS2MASS_H_
#define CS2MASS_H_

#include "useful.h"

/* Number of ACC and CAT files*/
#define NUMBER_OF_CATALOG_FILES 900
/* Extensions and format */
#define DOT_ACC_EXTENSION                       ".acc"
#define DOT_CAT_EXTENSION                       ".ast"
#define CATALOG_NAME_FORMAT                     "p%03dTMASS"
#define OUTPUT_ID_FORMAT                        "%02d%02d%04d%+03d%02d%03d"
#define CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DEGREE 0.2
#define ACC_FILE_NUMBER_OF_LINES                360
#define ACC_FILE_RA_ZONE_WIDTH_IN_DEGREE        1.

/* Number of stars in poles : the accelerator files are empty */
#define NUMBER_OF_STARS_IN_FIRST_ZONE           322157
#define NUMBER_OF_STARS_IN_LAST_ZONE            167

/* Format of the ACC file */
#ifdef OS_LINUX_GCC_SO
#define FORMAT_ACC "%d < RA =< %d %d %d %d"
#else
#define FORMAT_ACC "%ld < RA =< %ld %ld %ld %ld"
#endif

/* 2MASS ACC files */
typedef struct {
	unsigned int* numberOfStarsInZone;
	unsigned int* idOfFirstStarInZone;
} indexTable2Mass;

typedef struct {
	int   raStartInMicroDegree;
	int   raEndInMicroDegree;
	char  isArroundZeroRa;
	int   decStartInMicroDegree;
	int   decEndInMicroDegree;
	short magnitudeStartInMilliMag;
	short magnitudeEndInMilliMag;
	int   indexOfFirstDecZone;
	int   indexOfLastDecZone;
	int   indexOfFirstRightAscensionZone;
	int   indexOfLastRightAscensionZone;
} searchZone2Mass;

/* Raw structures are read herein,  so the following structure  */
/* must be packed on byte boundaries:                           */
#pragma pack( 1)

typedef struct {
	int   raInMicroDegree;
	int   decInMicroDegree;
	short errorOnCoordinates;
	short jMagInMilliMag;
	char  jErrorMagInCentiMag;
	short hMagInMilliMag;
	char  hErrorMagInCentiMag;
	short kMagInMilliMag;
	char  kErrorMagInCentiMag;
	int   jd;
} star2Mass;

#pragma pack( )

/* Function prototypes for 2MASS */
const searchZone2Mass findSearchZone2Mass(const double ra,const double dec,const double radius,const double magMin, const double magMax);
const indexTable2Mass* readIndexFile2Mass(const char* const pathOfCatalog, const searchZone2Mass* const mySearchZone2Mass, int* const maximumNumberOfStars);
void freeAll2MassCatalogFiles(const indexTable2Mass* allAccFiles,const searchZone2Mass* mySearchZone2Mass);
int processOneZone2MassNotCentredOnZeroRA(Tcl_DString* const dsptr, FILE* const inputStream,const indexTable2Mass* const oneAccFile,
		star2Mass* const arrayOfStars,const searchZone2Mass* const mySearchZone2Mass, const int indexOfCatalog, const int indexOfRA);
int processOneZone2MassCentredOnZeroRA(Tcl_DString* const dsptr, FILE* const inputStream,const indexTable2Mass* const oneAccFile,
		star2Mass* const arrayOfStars,const searchZone2Mass* const mySearchZone2Mass, const int indexOfCatalog, const int indexOfRA);
#endif /* CS2MASS_H_ */

