/*
 * useful.c
 *
 *  Created on: Dec 19, 2011
 *      Author: Y. Damerdji
 */

#include "useful.h"

void releaseDoubleArray(void** theTwoDArray, const int firstDimension) {

	int index = 0;

	while(index < firstDimension) {
		free(theTwoDArray[index]);
		index++;
	}

	free(theTwoDArray);
}


