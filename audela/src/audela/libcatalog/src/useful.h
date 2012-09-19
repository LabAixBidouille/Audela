/*
 * useful.h
 *
 *  Created on: Dec 19, 2011
 *      Author: Y. Damerdji
 */

#ifndef USEFUL_H_
#define USEFUL_H_

#include "libcatalog.h"

/***************************************************************************/
/*                            Useful definitions                      */
/***************************************************************************/
#ifndef max
#   define max(a,b) (((a)>(b))?(a):(b))
#endif

#ifndef min
#   define min(a,b) (((a)<(b))?(a):(b))
#endif

/* pi */
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif//M_PI

/* 1 mag = 10 deciimag */
#define MAG2DECIMAG   10.
/* 1 mag = 100 centimag */
#define MAG2CENTIMAG  100.
/* 1 mag = 1000 milli mag */
#define MAG2MILLIMAG  1000.
/* 1 hour = 15 deg */
#define HOUR2DEG      15.
/* 1 deg = 60 arcmin */
#define DEG2ARCMIN    60.

/* dec at the south pole in deg */
#define DEC_SOUTH_POLE_DEG -90.
/* dec at the north pole in deg */
#define DEC_NORTH_POLE_DEG  90.
/* 1 deg = pi / 180. rad = 0.01745329251994329547 rad */
#define DEC2RAD 0.01745329251994329547

#define DEBUG 1


void releaseSimpleArray(void* theOneDArray);
void releaseDoubleArray(void** theTwoDArray, const int firstDimension);


#endif /* USEFUL_H_ */
