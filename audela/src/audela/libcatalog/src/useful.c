/*
 * useful.c
 *
 *  Created on: Dec 19, 2011
 *      Author: Y. Damerdji
 */

#include "useful.h"

/*
 * Free memory of a double pointer array
 */
void releaseDoubleArray(void** theTwoDArray, const int firstDimension) {

	int index;

	if(theTwoDArray != NULL) {

		index = 0;

		while(index < firstDimension) {

			if(theTwoDArray[index] != NULL) {
				releaseSimpleArray(theTwoDArray[index]);
			}

			index++;
		}

		free(theTwoDArray);
		theTwoDArray = NULL;
	}
}

/*
 * Free memory of a simple array
 */
void releaseSimpleArray(void* theOneDArray) {

	if(theOneDArray != NULL) {
		free(theOneDArray);
		theOneDArray = NULL;
	}
}

/*
 * Add a slash to the end of a path if not exist
 */
void addLastSlashToPath(char* onePath) {

	char slash[3];

#if defined(LIBRARY_DLL)
	sprintf(slash,"\\");
#else
	sprintf(slash,"/");
#endif

	if (strlen(onePath) > 0) {
		if (onePath[strlen(onePath)-1] != slash[0] ) {
			strcat(onePath,slash);
		}
	}
}


