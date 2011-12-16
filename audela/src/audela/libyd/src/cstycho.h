/*
 * main.h
 *
 *  Created on: Dec 13, 2011
 *      Author: S. Vaillant
 */

#ifndef CSTYCHO_H_
#define CSTYCHO_H_

#include "ydtcl.h"

/* 1 mag = 1000 mili mag */
#define MAG2MILIMAG 1000.
/* 1 deg = 60 arcmin */
#define DEG2ARCMIN 60.
/* 1 deg = pi / 180. rad = 0.01745329251994329547 rad */
#define DEC2RAD 0.01745329251994329547
#define STRING_COMMON_LENGTH 1024
#define CATALOG_FILE_NAME "catalog.dat"

/* Function prototypes */
int field_is_blank(char *p);
char** tycho2_search(const char* catalogCompleteName, double ra0, double dec0, double range,
		double magmin, double magmax, int* numberOfOutputs);

#endif /* CSTYCHO_H_ */
