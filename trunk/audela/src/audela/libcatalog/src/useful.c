/*
 * useful.c
 *
 *  Created on: Dec 19, 2011
 *      Author: Y. Damerdji
 */

#include "useful.h"

void releaseDoubleIntArray(int** theTwoDArray, const int firstDimension) {

	int index = 0;

	while(index < firstDimension) {
		free(theTwoDArray[index]);
		index++;
	}

	free(theTwoDArray);
}

void releaseDoubleCharArray(char** theTwoDArray, const int firstDimension) {

	int index = 0;

	while(index < firstDimension) {
		free(theTwoDArray[index]);
		index++;
	}

	free(theTwoDArray);
}


