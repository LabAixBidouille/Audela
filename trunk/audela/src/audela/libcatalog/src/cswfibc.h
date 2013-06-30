/*
 * cswfibc.h
 *
 *  Created on: 30/06/2013
 *      Author: Y. Damerdji
 */

#ifndef CSWFIBC_H_
#define CSWFIBC_H_

#include "useful.h"

#define ACCELERATOR_TABLE           "accelerator_table.txt"
#define OFFSET_TABLE                "offset_table.txt"
#define RA_STEP                     0.25
#define RA_START                    0.
#define RA_END                      359.9999
#define FORMAT_OFFSET_TABLE_COMMENT "# RA =   %lf -   %lf"
#define FORMAT_OFFSET_TABLE_DATA    "\t FILE : %20s - OFFSET = %d - NUMBER_OF_LINES = %d"
#define CATALOG_LINE_FORMAT         "%d %d %lf %d %d %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf"

typedef struct {
	double raStart;
	double raEnd;
	int offset; // The offset in OFFSET_TABLE
	int numberOfLines;
} raZone;

typedef struct {
	searchZoneRaDecDeg subSearchZone;
	magnitudeBoxMag magnitudeBox;
	int indexOfFirstRightAscensionZone;
	int indexOfLastRightAscensionZone;
} searchZoneWfibc;

const searchZoneWfibc findSearchZoneWfibc(const double ra,const double dec,const double radius,const double magMin, const double magMax);
raZone* const readAcceleratorFileWfbic(const char* const pathToCatalog, const int numberOfZones);
const int processOneZone(Tcl_DString* const dsptr, FILE* const offsetFileStream, const raZone* const theRaZone, const searchZoneWfibc* const mySearchZoneWfibc,
		const char* const pathToCatalog);
const int processOneZoneInOneFile(Tcl_DString* const dsptr, const char* const catalogFullName, const int offset, const int numberOfLines, const searchZoneWfibc* const mySearchZoneWfibc);



#endif /* CSWFIBC_H_ */
