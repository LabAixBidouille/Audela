#include "csucac.h"
/*
 * csucac2.c
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

char outputLogChar[1024];

int cmd_tcl_csucac2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	if((argc == 2) && (strcmp(argv[1],"-h") == 0)) {
		sprintf(outputLogChar,"Help usage : %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) magnitudeMin(mag)? magnitudeMax(mag)?\n",
				argv[0]);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	if((argc != 5) && (argc != 7)) {
		sprintf(outputLogChar,"usage : %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) magnitudeMax(mag)? magnitudeMin(mag)?\n",
				argv[0]);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Read inputs */
	const char* pathOfCatalog = argv[1];
	const double ra           = atof(argv[2]);
	const double dec          = atof(argv[3]);
	const double radius       = atof(argv[4]);
	double magMin;
	double magMax;
	if(argc == 7) {
		magMin                = atof(argv[5]);
		magMax                = atof(argv[6]);
	} else {
		magMin                = -99.99;
		magMax                = 99.99;
	}
	//printf("Search stars in UCAC2 around : ra = %f(deg) - dec = %f(deg) - radius = %f(arcmin) - magnitude in [%f,%f](mag)\n",
				//ra,dec,radius,magMin,magMax);

	/* Define search zone */
	searchZoneUcac2 mysearchZoneUcac2 = findSearchZoneUcac2(ra,dec,radius,magMin,magMax);

	/* Read the index file */
	int** indexTable = readIndexFileUcac2(pathOfCatalog);
	if(indexTable == NULL) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Now read the catalog and retrieve stars */
	int resultOfFunction;
	arrayTwoDOfStarUcac2 theUnFilteredStars;
	resultOfFunction = retrieveUnFilteredStarsUcac2(pathOfCatalog,&mysearchZoneUcac2,indexTable,&theUnFilteredStars);
	if(resultOfFunction) {
		releaseDoubleArray((void**)indexTable, INDEX_TABLE_DEC_DIMENSION);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	arrayOneDOfStarUcac2 theFilteredStars;
	resultOfFunction = filterStarsUcac2(&theUnFilteredStars,&theFilteredStars,&mysearchZoneUcac2);
	if(resultOfFunction) {
		releaseDoubleArray((void**)indexTable, INDEX_TABLE_DEC_DIMENSION);
		releaseMemoryArrayTwoDOfStarUcac2(&theUnFilteredStars);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Print the filtered stars */
	Tcl_DString dsptr;
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { UCAC2 { } "
			"{ ra_deg dec_deg U2Rmag_mag e_RAm_deg e_DEm_deg nobs e_pos_deg ncat cflg "
			"EpRAm_deg EpDEm_deg pmRA_masperyear pmDEC_masperyear e_pmRA_masperyear e_pmDE_masperyear "
			"q_pmRA q_pmDE 2m_id 2m_J 2m_H 2m_Ks 2m_ph 2m_cc} } } ",-1);
	Tcl_DStringAppend(&dsptr,"{",-1); // start of sources list

	//printf("theFilteredStars.length = %d\n",theFilteredStars.length);

	int index;
	starUcac2 oneStar;
	for(index = 0; index < theFilteredStars.length; index++) {

		Tcl_DStringAppend(&dsptr,"{ { UCAC2 { } {",-1);

		oneStar = theFilteredStars.arrayOneD[index];
		sprintf(outputLogChar,
				"%.8f %+.8f %.3f %.8f %.8f %d %.8f %d %d "
				"%.8f %.8f %.8f %.8f %.8f %.8f %.8f "
				"%.5f %.5f %d %.3f %.3f %.3f %d %d\n",

				(double)oneStar.raInMas / DEG2MAS,
				(double)oneStar.decInMas / DEG2MAS,
				(double)oneStar.ucacMagInCentiMag / MAG2CENTIMAG,
				(double)oneStar.errorRaInMas / DEG2MAS,
				(double)oneStar.errorDecInMas / DEG2MAS,
				oneStar.numberOfObservations,
				(double)oneStar.errorOnUcacPositionInMas / DEG2MAS,
				oneStar.numberOfCatalogsForPosition,
				oneStar.majorCatalogIdForPosition,

				(double)oneStar.centralEpochForMeanRaInMas / DEG2MAS,
				(double)oneStar.centralEpochForMeanDecInMas / DEG2MAS,
				(double)oneStar.raProperMotionInOneTenthMasPerYear / 10.,
				(double)oneStar.decProperMotionInOneTenthMasPerYear / 10.,
				(double)oneStar.errorOnRaProperMotionInOneTenthMasPerYear / 10.,
				(double)oneStar.errorOnDecProperMotionInOneTenthMasPerYear / 10.,
				(double)oneStar.errorOnDecProperMotionInOneTenthMasPerYear / 10.,

				(double)oneStar.raProperMotionGoodnessOfFit * 0.05,
				(double)oneStar.decProperMotionGoodnessOfFit * 0.05,
				oneStar.idFrom2Mass,
				(double)oneStar.jMagnitude2MassInMiliMag / MAG2MILIMAG,
				(double)oneStar.hMagnitude2MassInMiliMag / MAG2MILIMAG,
				(double)oneStar.kMagnitude2MassInMiliMag / MAG2MILIMAG,
				oneStar.qualityFlag2Mass,
				oneStar.ccFlag2Mass);

		Tcl_DStringAppend(&dsptr,outputLogChar,-1);
		Tcl_DStringAppend(&dsptr,"} } } ",-1);
	}

	Tcl_DStringAppend(&dsptr,"}",-1); // end of main list
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);
	/* Release the memory */
	releaseDoubleArray((void**)indexTable, INDEX_TABLE_DEC_DIMENSION);
	releaseMemoryArrayTwoDOfStarUcac2(&theUnFilteredStars);

	return (TCL_OK);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
int filterStarsUcac2(arrayTwoDOfStarUcac2* theUnFilteredStars,arrayOneDOfStarUcac2* theFilteredStars,searchZoneUcac2* mysearchZoneUcac2) {

	/* Count the stars which satisfies the criteria in mysearchZoneUcac2 */
	int numberOfStars              = 0;
	const int lengthOfTwoDArray    = theUnFilteredStars->length;
	/* UCAC2 stop at dec = +42 deg*/
	if(lengthOfTwoDArray == 0) {
		return (0);
	}
	arrayOneDOfStarUcac2* arrayTwoD = theUnFilteredStars->arrayTwoD;
	arrayOneDOfStarUcac2 oneSetOfStar;
	starUcac2* allStars;
	starUcac2 oneStar;
	int lengthOfOneDArray;
	int counterDec,counterRa;

	for(counterDec = 0; counterDec < lengthOfTwoDArray; counterDec++) {

		oneSetOfStar      = arrayTwoD[counterDec];
		lengthOfOneDArray = oneSetOfStar.length;
		allStars          = oneSetOfStar.arrayOneD;

		for(counterRa     = 0; counterRa < lengthOfOneDArray; counterRa++) {
			oneStar       = allStars[counterRa];
			if((oneStar.raInMas >= mysearchZoneUcac2->raStartInMas) &&
					(oneStar.raInMas <= mysearchZoneUcac2->raEndInMas) &&
					(oneStar.decInMas >= mysearchZoneUcac2->decStartInMas) &&
					(oneStar.decInMas <= mysearchZoneUcac2->decEndInMas) &&
					(oneStar.ucacMagInCentiMag >= mysearchZoneUcac2->magnitudeStartInCentiMag) &&
					(oneStar.ucacMagInCentiMag <= mysearchZoneUcac2->magnitudeEndInCentiMag)) {
				numberOfStars++;
			}
		}
	}

	(*theFilteredStars).length    = numberOfStars;
	if(numberOfStars == 0) {
		return (0);
	}
	(*theFilteredStars).arrayOneD = (starUcac2*)malloc(numberOfStars * sizeof(starUcac2));

	if((*theFilteredStars).arrayOneD == NULL) {
		sprintf(outputLogChar,"Error : theFilteredStars.arrayOneD out of memory %d starUcac2",numberOfStars);
		return (1);
	}

	/* Fill the array */
	numberOfStars = 0;
	for(counterDec = 0; counterDec < lengthOfTwoDArray; counterDec++) {

		oneSetOfStar      = arrayTwoD[counterDec];
		lengthOfOneDArray = oneSetOfStar.length;
		allStars          = oneSetOfStar.arrayOneD;

		for(counterRa = 0; counterRa < lengthOfOneDArray; counterRa++) {
			oneStar       = allStars[counterRa];
			if((oneStar.raInMas >= mysearchZoneUcac2->raStartInMas) &&
					(oneStar.raInMas <= mysearchZoneUcac2->raEndInMas) &&
					(oneStar.decInMas >= mysearchZoneUcac2->decStartInMas) &&
					(oneStar.decInMas <= mysearchZoneUcac2->decEndInMas) &&
					(oneStar.ucacMagInCentiMag >= mysearchZoneUcac2->magnitudeStartInCentiMag) &&
					(oneStar.ucacMagInCentiMag <= mysearchZoneUcac2->magnitudeEndInCentiMag)) {

				theFilteredStars->arrayOneD[numberOfStars] = oneStar;
				numberOfStars++;
			}
		}
	}

	return (0);
}

/**
 * Retrieve list of stars
 */
int retrieveUnFilteredStarsUcac2(const char* pathOfCatalog, searchZoneUcac2* mysearchZoneUcac2, int** indexTable, arrayTwoDOfStarUcac2* theUnFilteredStars) {

	/* We retrive the index of all used file zones */
	int indexZoneDecStart,indexZoneDecEnd,indexZoneRaStart,indexZoneRaEnd,resultOfFunction;
	retrieveIndexesUcac2(mysearchZoneUcac2,&indexZoneDecStart,&indexZoneDecEnd,&indexZoneRaStart,&indexZoneRaEnd);

	int numberOfDecZones        = indexZoneDecEnd - indexZoneDecStart + 1;
	/* If ra is around 0, we double the size of the array */
	if((*mysearchZoneUcac2).isArroundZeroRa) {
		numberOfDecZones       *= 2;
	}

	theUnFilteredStars->length    = numberOfDecZones;
	if(numberOfDecZones == 0) {
		sprintf(outputLogChar,"Warn : no stars in the selected zone\n");
		return (1);
	}
	theUnFilteredStars->arrayTwoD      = (arrayOneDOfStarUcac2*)malloc(numberOfDecZones * sizeof(arrayOneDOfStarUcac2));
	if(theUnFilteredStars->arrayTwoD == NULL) {
		sprintf(outputLogChar,"Error : theUnFilteredStars.arrayTwoD out of memory %d arrayOneDOfucacStarUcac2*\n",numberOfDecZones);
		return (1);
	}

	//printf("numberOfDecZones = %d\n",numberOfDecZones);
	/* Now we allocate the memory for each zone */
	resultOfFunction = allocateUnfiltredStarUcac2(theUnFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, mysearchZoneUcac2->isArroundZeroRa);
	if(resultOfFunction) {
		return (1);
	}

	/* Now we read the un-filtered stars from the catalog */
	resultOfFunction = readUnfiltredStarUcac2(pathOfCatalog, theUnFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, mysearchZoneUcac2->isArroundZeroRa);
	if(resultOfFunction) {
		releaseMemoryArrayTwoDOfStarUcac2(theUnFilteredStars);
		return (1);
	}

	if(DEBUG) {
		printUnfilteredStarUcac2(theUnFilteredStars);
	}

	return (0);
}

/**
 * Release memory from one arrayTwoDOfucacStarUcac2
 */
void releaseMemoryArrayTwoDOfStarUcac2(arrayTwoDOfStarUcac2* theTwoDArray) {

	const int lengthOfTwoDArray    = theTwoDArray->length;
	/* UCAC2 stop at dec = +42 deg*/
	if(lengthOfTwoDArray == 0) {
		return;
	}
	arrayOneDOfStarUcac2* arrayTwoD = theTwoDArray->arrayTwoD;
	arrayOneDOfStarUcac2 oneSetOfStar;
	starUcac2* allStars;
	int counterDec;

	for(counterDec = 0; counterDec < lengthOfTwoDArray; counterDec++) {

		//printf("counterDec = %d / %d\n",counterDec,lengthOfTwoDArray);
		if(arrayTwoD[counterDec].length > 0) {
			oneSetOfStar  = arrayTwoD[counterDec];
			allStars      = oneSetOfStar.arrayOneD;
			free(allStars);
		}
	}
	free(arrayTwoD);
}

/**
 * Read the stars from the catalog
 */
int readUnfiltredStarUcac2(const char* pathOfCatalog, arrayTwoDOfStarUcac2* theUnFilteredStars, int** indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa) {

	int counterDec = 0;
	int indexDec;
	int resultOfFunction;
	//printf("isArroundZeroRa = %d\n",isArroundZeroRa);

	if(isArroundZeroRa) {

		const int lastZoneRa = INDEX_TABLE_RA_DIMENSION - 1;

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac2(pathOfCatalog, &(*theUnFilteredStars).arrayTwoD[counterDec],
					indexTable[indexDec], indexDec, indexZoneRaStart, lastZoneRa);
			if(resultOfFunction) {
				return (1);
			}

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac2(pathOfCatalog, &(*theUnFilteredStars).arrayTwoD[counterDec],
					indexTable[indexDec], indexDec, 0, indexZoneRaEnd);

			if(resultOfFunction) {
				return (1);
			}

			counterDec++;
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac2(pathOfCatalog, &(*theUnFilteredStars).arrayTwoD[counterDec],
					indexTable[indexDec], indexDec, indexZoneRaStart,indexZoneRaEnd);
			if(resultOfFunction) {
				return (1);
			}
			counterDec++;
		}
	}

	return (0);
}

/**
 * read stars from the catalog for one Dec zone for the un-filtered stars : case of ra not around 0
 */
int readUnfiltredStarForOneDecZoneUcac2(const char* pathOfCatalog, arrayOneDOfStarUcac2* notFilteredStarsForOneDec, int* indexTableForOneDec,
		int indexDec, const int indexZoneRaStart,const int indexZoneRaEnd) {

	//printf("notFilteredStarsForOneDec->length = %d\n",notFilteredStarsForOneDec->length);
	if(notFilteredStarsForOneDec->length == 0) {
		return (0);
	}

	int indexRa;
	int sumOfStarBefore   = 0;
	for(indexRa           = 0; indexRa < indexZoneRaStart; indexRa++) {
		sumOfStarBefore  += indexTableForOneDec[indexRa];
	}

	int sumOfStarToRead   = 0;
	for(indexRa           = indexZoneRaStart; indexRa <= indexZoneRaEnd; indexRa++) {
		sumOfStarToRead  += indexTableForOneDec[indexRa];
	}

	/* Open the file */
	indexDec++; //Names start with 1 not 0
	char completeFileName[1024];
	sprintf(completeFileName,ZONE_FILE_FORMAT_NAME,pathOfCatalog,indexDec);

	//printf("completeFileName = %s\n",completeFileName);
	FILE* myStream = fopen(completeFileName,"rb");

	if(myStream == NULL) {
		sprintf(outputLogChar,"Error : unable to open file %s\n",completeFileName);
		return (1);
	}

	/* Move to starting position */
	if(fseek(myStream,sumOfStarBefore*sizeof(starUcac2),SEEK_SET) != 0) {
		fclose(myStream);
		sprintf(outputLogChar,"Error : when moving inside %s\n",completeFileName);
		return (1);
	}

	int resultOfRead = (int)fread(notFilteredStarsForOneDec->arrayOneD,sizeof(starUcac2),sumOfStarToRead,myStream);

	fclose(myStream);

	if(resultOfRead != sumOfStarToRead) {
		sprintf(outputLogChar,"Error : resultOfRead = %d != sumOfStarToRead = %d\n",resultOfRead,sumOfStarToRead);
		return (1);
	}

	return (0);
}


/**
 * Allocate memory for one Dec zone for the un-filtered stars : case of ra not around 0
 */
int allocateUnfiltredStarUcac2(arrayTwoDOfStarUcac2* theUnilteredStars, int** indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa) {

	int counterDec = 0;
	int indexDec;
	int resultOfFunction;
	//printf("isArroundZeroRa = %d\n",isArroundZeroRa);

	if(isArroundZeroRa) {

		const int lastZoneRa = INDEX_TABLE_RA_DIMENSION - 1;

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac2(&((*theUnilteredStars).arrayTwoD[counterDec]),
					indexTable[indexDec], indexZoneRaStart, lastZoneRa);
			if(resultOfFunction) {
				return (1);
			}

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac2(&((*theUnilteredStars).arrayTwoD[counterDec]),
					indexTable[indexDec], 0, indexZoneRaEnd);

			if(resultOfFunction) {
				return (1);
			}

			counterDec++;

			//printf("1) indexDec = %d - counterDec = %d - indexZoneDecStart = %d - indexZoneDecEnd = %d\n",indexDec,counterDec,indexZoneDecStart,indexZoneDecEnd);
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac2(&((*theUnilteredStars).arrayTwoD[counterDec]),
					indexTable[indexDec], indexZoneRaStart,indexZoneRaEnd);
			if(resultOfFunction) {
				return (1);
			}
			counterDec++;
			//printf("2) indexDec = %d - counterDec = %d - indexZoneDecStart = %d - indexZoneDecEnd = %d\n",indexDec,counterDec,indexZoneDecStart,indexZoneDecEnd);
		}
	}

	return (0);
}

/**
 * Allocate memory for one Dec zone for the un-filtered stars
 */
int allocateUnfiltredStarForOneDecZoneUcac2(arrayOneDOfStarUcac2* notFilteredStarsForOneDec, int* indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd) {

	int indexRa;
	int sumOfStar   = 0;
	for(indexRa     = indexZoneRaStart; indexRa <= indexZoneRaEnd; indexRa++) {
		sumOfStar  += indexTableForOneDec[indexRa];
	}
	//printf("sumOfStar = %d\n",sumOfStar);
	notFilteredStarsForOneDec->length = 0;

	if(sumOfStar > 0) {
		/* Allocate memory */
		notFilteredStarsForOneDec->length        = sumOfStar;
		notFilteredStarsForOneDec->arrayOneD     = (starUcac2*)malloc(sumOfStar * sizeof(starUcac2));
		if(notFilteredStarsForOneDec->arrayOneD == NULL) {
			sprintf(outputLogChar,"Error : notFilteredStarsForOneDec->arrayOneD out of memory %d starUcac2\n",sumOfStar);
			return (1);
		}
	}

	return (0);
}

/**
 * We retrive the index of all used file zones
 */
void retrieveIndexesUcac2(searchZoneUcac2* mysearchZoneUcac2,int* indexZoneDecStart,int* indexZoneDecEnd,int* indexZoneRaStart,int* indexZoneRaEnd) {

	/* dec start */
	*indexZoneDecStart     = (int)((mysearchZoneUcac2->decStartInMas - DEC_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS);
	if(*indexZoneDecStart  < 0) {
		*indexZoneDecStart = 0;
	}

	/* dec end */
	*indexZoneDecEnd       = (int)((mysearchZoneUcac2->decEndInMas - DEC_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS);
	if(*indexZoneDecEnd   >= INDEX_TABLE_DEC_DIMENSION) {
		*indexZoneDecEnd   = INDEX_TABLE_DEC_DIMENSION - 1;
	}

	/* ra start */
	*indexZoneRaStart     = (int)((mysearchZoneUcac2->raStartInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS);
	if(*indexZoneDecStart < 0) {
		*indexZoneRaStart = 0;
	}

	/* ra end */
	*indexZoneRaEnd     = (int)((mysearchZoneUcac2->raEndInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS);
	if(*indexZoneRaEnd >= INDEX_TABLE_RA_DIMENSION) {
		*indexZoneRaEnd = INDEX_TABLE_RA_DIMENSION - 1;
	}
}

/**
 * Read the index file
 */
int** readIndexFileUcac2(const char* pathOfCatalog) {

	int index;
	int numberOfStars;
	int decZoneNumber;
	int raZoneNumber;
	int tempInt;
	double tempDouble;
	char completeFileName[STRING_COMMON_LENGTH];
	char temporaryString[STRING_COMMON_LENGTH];
	char* temporaryPointer;
	sprintf(completeFileName,"%s/%s",pathOfCatalog,INDEX_FILE_NAME_UCAC2);

	FILE* tableStream = fopen(completeFileName,"rt");
	if(tableStream == NULL) {
		sprintf(outputLogChar,"Error : file %s not found\n",completeFileName);
		return (NULL);
	}

	/* Allocate memory */
	int** indexTable = (int**)malloc(INDEX_TABLE_DEC_DIMENSION * sizeof(int*));
	if(indexTable == NULL) {
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		return (NULL);
	}
	for(index = 0; index < INDEX_TABLE_DEC_DIMENSION;index++) {
		indexTable[index] = (int*)malloc(INDEX_TABLE_RA_DIMENSION * sizeof(int));
		if(indexTable[index] == NULL) {
			sprintf(outputLogChar,"Error : indexTable[%d] out of memory\n",index);
			return (NULL);
		}
	}

	/* Read the header file */
	for(index = 0; index < INDEX_FILE_HEADER_NUMBER_OF_LINES; index++) {
		if (fgets(temporaryString , STRING_COMMON_LENGTH , tableStream) == NULL) {
			sprintf(outputLogChar,"Error : Can not read line from %s\n",completeFileName);
			return (NULL);
		}
	}

	/* Now we read the remaining content */
	while(!feof(tableStream)) {

		temporaryPointer = fgets(temporaryString , STRING_COMMON_LENGTH , tableStream);
		if(temporaryPointer == NULL) {
			break;
		}
		sscanf(temporaryString,FORMAT_INDEX_FILE_UCAC2,&numberOfStars,&tempInt,&tempInt,&decZoneNumber,&raZoneNumber,&tempDouble,&tempDouble);
		indexTable[decZoneNumber - 1][raZoneNumber - 1] = numberOfStars;
	}

	fclose(tableStream);

	if(DEBUG) {
		int index2;
		for(index = 0; index < INDEX_TABLE_DEC_DIMENSION;index++) {
			for(index2 = 0; index2 < INDEX_TABLE_RA_DIMENSION;index2++) {
				printf("indexTable[%3d][%3d] = %d\n",index,index2,indexTable[index][index2]);
			}
		}
	}

	return (indexTable);
}

/**
 * Find the search zone having its center on (ra,dec) with a radius of radius
 *
 */
const searchZoneUcac2 findSearchZoneUcac2(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneUcac2 mysearchZoneUcac2;
	const double radiusInDeg              = radiusInArcMin / DEG2ARCMIN;
	mysearchZoneUcac2.decStartInMas            = (int)(DEG2MAS * (decInDeg - radiusInDeg));
	mysearchZoneUcac2.decEndInMas              = (int)(DEG2MAS * (decInDeg + radiusInDeg));
	mysearchZoneUcac2.magnitudeStartInCentiMag = (short)(MAG2CENTIMAG * magMin);
	mysearchZoneUcac2.magnitudeEndInCentiMag   = (short)(MAG2CENTIMAG * magMax);

	if((mysearchZoneUcac2.decStartInMas  <= DEC_SOUTH_POLE_MAS) && (mysearchZoneUcac2.decEndInMas >= DEC_NORTH_POLE_MAS)) {

		mysearchZoneUcac2.decStartInMas   = DEC_SOUTH_POLE_MAS;
		mysearchZoneUcac2.decEndInMas     = DEC_NORTH_POLE_MAS;
		mysearchZoneUcac2.raStartInMas    = START_RA_MAS;
		mysearchZoneUcac2.raEndInMas      = COMPLETE_RA_MAS;
		mysearchZoneUcac2.isArroundZeroRa = 0;

	} else if(mysearchZoneUcac2.decStartInMas <= DEC_SOUTH_POLE_MAS) {

		mysearchZoneUcac2.decStartInMas   = DEC_SOUTH_POLE_MAS;
		mysearchZoneUcac2.raStartInMas    = START_RA_MAS;
		mysearchZoneUcac2.raEndInMas      = COMPLETE_RA_MAS;
		mysearchZoneUcac2.isArroundZeroRa = 0;

	} else if(mysearchZoneUcac2.decEndInMas >= DEC_NORTH_POLE_MAS) {

		mysearchZoneUcac2.decEndInMas     = DEC_NORTH_POLE_MAS;
		mysearchZoneUcac2.raStartInMas    = START_RA_MAS;
		mysearchZoneUcac2.raEndInMas      = COMPLETE_RA_MAS;
		mysearchZoneUcac2.isArroundZeroRa = 0;

	} else {

		double ratio;
		double tmpValue;

		const double radiusRa        = radiusInDeg / cos(decInDeg * DEC2RAD);
		tmpValue                     = DEG2MAS * (raInDeg  - radiusRa);
		ratio                        = tmpValue / COMPLETE_RA_MAS;
		ratio                        = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                    -= ratio;
		mysearchZoneUcac2.raStartInMas    = (int)tmpValue;

		tmpValue                     = DEG2MAS * (raInDeg  + radiusRa);
		ratio                        = tmpValue / COMPLETE_RA_MAS;
		ratio                        = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                    -= ratio;
		mysearchZoneUcac2.raEndInMas      = (int)tmpValue;

		mysearchZoneUcac2.isArroundZeroRa      = 0;

		if(mysearchZoneUcac2.raStartInMas      >  mysearchZoneUcac2.raEndInMas) {
			mysearchZoneUcac2.isArroundZeroRa  = 1;
		}
	}

	if(DEBUG) {
		printf("mysearchZoneUcac2.decStart        = %d\n",mysearchZoneUcac2.decStartInMas);
		printf("mysearchZoneUcac2.decEnd          = %d\n",mysearchZoneUcac2.decEndInMas);
		printf("mysearchZoneUcac2.raStart         = %d\n",mysearchZoneUcac2.raStartInMas);
		printf("mysearchZoneUcac2.raEnd           = %d\n",mysearchZoneUcac2.raEndInMas);
		printf("mysearchZoneUcac2.isArroundZeroRa = %d\n",mysearchZoneUcac2.isArroundZeroRa);
		printf("mysearchZoneUcac2.magnitudeStart  = %d\n",mysearchZoneUcac2.magnitudeStartInCentiMag);
		printf("mysearchZoneUcac2.magnitudeEnd    = %d\n",mysearchZoneUcac2.magnitudeEndInCentiMag);
	}

	return (mysearchZoneUcac2);
}

/**
 * Print the un filtered stars
 */
void printUnfilteredStarUcac2(arrayTwoDOfStarUcac2* theUnilteredStars) {

	printf("The un-filtered stars are :\n");
	arrayOneDOfStarUcac2* arrayTwoD = theUnilteredStars->arrayTwoD;
	arrayOneDOfStarUcac2 oneSetOfStar;
	starUcac2 oneStar;
	int indexDec,indexRa;

	for(indexDec = 0; indexDec < theUnilteredStars->length; indexDec++) {

		oneSetOfStar = arrayTwoD[indexDec];

		for(indexRa = 0; indexRa < oneSetOfStar.length; indexRa++) {

			oneStar = oneSetOfStar.arrayOneD[indexRa];
			printf("indexDec = %3d - indexRa = %3d : %8.4f %+8.4f %5.2f\n",indexDec,indexRa,oneStar.raInMas/DEG2MAS,
					oneStar.decInMas/DEG2MAS,oneStar.ucacMagInCentiMag/MAG2CENTIMAG);
		}
	}
}
