/*
 * main.h
 *
 *  Created on: Dec 13, 2011
 *      Author: S. Vaillant
 */

#ifndef CSTYCHO_H_
#define CSTYCHO_H_

#include "libcatalog.h"
#include "useful.h"

#define STRING_COMMON_LENGTH 1024
#define CATALOG_FILE_NAME "catalog.dat"

/* Function prototypes */
int field_is_blank(char *p);
char** tycho2_search(const char* catalogCompleteName, double ra0, double dec0, double range,
		double magmin, double magmax, int* numberOfOutputs);

#endif /* CSTYCHO_H_ */
