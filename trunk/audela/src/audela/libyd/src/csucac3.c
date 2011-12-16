#include "csucac.h"
/*
 * csucac3.c
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

int Cmd_ydtcl_csucac3(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char outputLine[1024];

	if((argc == 2) && (strcmp(argv[1],"-h") == 0)) {
		sprintf(outputLine,"Help usage : %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) magnitudeMin(mag)? magnitudeMax(mag)?\n",argv[0]);
		Tcl_SetResult(interp,outputLine,TCL_VOLATILE);
		return TCL_ERROR;
	}

	if((argc != 5) && (argc != 7)) {
		sprintf(outputLine,"usage : %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) magnitudeMax(mag)? magnitudeMin(mag)?\n",argv[0]);
		Tcl_SetResult(interp,outputLine,TCL_VOLATILE);
		return TCL_ERROR;
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
//	printf("Search stars in UCAC2 around : ra = %f(deg) - dec = %f(deg) - radius = %f(arcmin) - magnitude in [%f,%f](mag)\n",
//			ra,dec,radius,magMin,magMax);

	/* Define search zone */
	searchZoneUcac3 mysearchZoneUcac3 = findSearchZoneUcac3(ra,dec,radius,magMin,magMax);

	/* Read the index file */
	int** indexTable = readIndexFileUcac3(pathOfCatalog);
	if(indexTable == NULL) {
		return TCL_ERROR;
	}

	/* Now read the catalog and retrieve stars */
	int resultOfFunction;
	arrayTwoDOfStarUcac3 theUnFilteredStars;
	resultOfFunction = retrieveUnFilteredStarsUcac3(pathOfCatalog,&mysearchZoneUcac3,indexTable,&theUnFilteredStars);
	if(resultOfFunction) {
		releaseDoubleIntArray(indexTable, INDEX_TABLE_DEC_DIMENSION);
		return TCL_ERROR;
	}

	arrayOneDOfStarUcac3 theFilteredStars;
	resultOfFunction = filterStarsUcac3(&theUnFilteredStars,&theFilteredStars,&mysearchZoneUcac3);
	if(resultOfFunction) {
		releaseDoubleIntArray(indexTable, INDEX_TABLE_DEC_DIMENSION);
		releaseMemoryArrayTwoDOfStarUcac3(&theUnFilteredStars);
		return TCL_ERROR;
	}

	/* Print the filtered stars */
	Tcl_DString dsptr;
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { UCAC3 { } "
		"{ ra_deg dec_deg im1_mag im2_mag sigmag_mag objt dsf sigra_deg sigdc_deg na1 nu1 us1 cn1 cepra_deg cepdc_deg"
		"pmrac_masperyear pmdc_masperyear sigpmr_masperyear sigpmd_masperyear id2m jmag_mag hmag_mag kmag_mag jicqflg hicqflg kicqflg je2mpho he2mpho ke2mpho "
		"smB_mag smR2_mag smI_mag clbl qfB qfR2 qfI "
		"catflg1 catflg2 catflg3 catflg4 catflg5 catflg6 catflg7 catflg8 catflg9 catflg10 "
		"g1 c1 leda x2m rn } } } ",-1);
	Tcl_DStringAppend(&dsptr,"{",-1); // start of sources list

	starUcac3 oneStar;
	int index;
	for(index = 0; index < theFilteredStars.length; index++) {

		Tcl_DStringAppend(&dsptr,"{ { UCAC3 { } {",-1);
		oneStar = theFilteredStars.arrayOneD[index];
		sprintf(outputLine,"%.8f %+.8f %.3f %.3f %.3f %d %d %.8f %.8f %d %d %d %d %.8f %+.8f "
				"%+.8f %+.8f %.8f %.8f %d %.3f %.3f %.3f %d %d %d %.3f %.3f %.3f "
				"%.3f %.3f %.3f %d %d %d %d "
				"%d %d %d %d %d %d %d %d %d %d "
				"%d %d %d %d %d\n",

				(double)oneStar.raInMas/DEG2MAS,
				(double)oneStar.distanceToSouthPoleInMas / DEG2MAS + DEC_SOUTH_POLE_DEG,
				(double)oneStar.ucacFitMagInMiliMag / MAG2MILIMAG,
				(double)oneStar.ucacApertureMagInMiliMag / MAG2MILIMAG,
				(double)oneStar.ucacErrorMagInMiliMag / MAG2MILIMAG,
				oneStar.objectType,
				oneStar.doubleStarFlag,
				(double)oneStar.errorOnUcacRaInMas / DEG2MAS,
				(double)oneStar.errorOnUcacDecInMas / DEG2MAS,
				oneStar.numberOfCcdObservation,
				oneStar.numberOfUsedCcdObservation,
				oneStar.numberOfUsedCatalogsForProperMotion,
				oneStar.numberOfMatchingCatalogs,
				(double)oneStar.centralEpochForMeanRaInMas/ DEG2MAS,
				(double)oneStar.centralEpochForMeanDecInMas/ DEG2MAS,

				(double)oneStar.raProperMotionInOneTenthMasPerYear / 10.,
				(double)oneStar.decProperMotionInOneTenthMasPerYear / 10.,
				(double)oneStar.errorOnRaProperMotionInOneTenthMasPerYear / 10.,
				(double)oneStar.errorOnDecProperMotionInOneTenthMasPerYear / 10.,
				oneStar.idFrom2Mass,
				(double)oneStar.jMagnitude2MassInMiliMag / MAG2MILIMAG,
				(double)oneStar.hMagnitude2MassInMiliMag / MAG2MILIMAG,
				(double)oneStar.kMagnitude2MassInMiliMag / MAG2MILIMAG,
				oneStar.jQualityFlag2Mass,
				oneStar.hQualityFlag2Mass,
				oneStar.kQualityFlag2Mass,
				(double)oneStar.jErrorMagnitude2MassInCentiMag / MAG2CENTIMAG,
				(double)oneStar.hErrorMagnitude2MassInCentiMag / MAG2CENTIMAG,
				(double)oneStar.kErrorMagnitude2MassInCentiMag / MAG2CENTIMAG,

				(double)oneStar.bMagnitudeSCInMiliMag / MAG2MILIMAG,
				(double)oneStar.r2MagnitudeSCInMiliMag / MAG2MILIMAG,
				(double)oneStar.iMagnitudeSCInMiliMag / MAG2MILIMAG,
				oneStar.scStarGalaxieClass,
				oneStar.bQualityFlagSC,
				oneStar.r2QualityFlagSC,
				oneStar.iQualityFlag2SC,

				oneStar.hipparcosMatchFlag,
				oneStar.tychoMatchFlag,
				oneStar.ac2000MatchFlag,
				oneStar.agk2bMatchFlag,
				oneStar.agk2hMatchFlag,
				oneStar.zaMatchFlag,
				oneStar.byMatchFlag,
				oneStar.lickMatchFlag,
				oneStar.scMatchFlag,
				oneStar.spmMatchFlag,

				oneStar.yaleSpmObjectType,
				oneStar.yaleSpmInputCatalog,
				oneStar.ledaGalaxyMatchFlag,
				oneStar.extendedSourceFlag2Mass,
				oneStar.mposStarNumber);

		Tcl_DStringAppend(&dsptr,outputLine,-1);
		Tcl_DStringAppend(&dsptr,"} } } ",-1);
	}

	 // end of sources list
	Tcl_DStringAppend(&dsptr,"}",-1); // end of main list
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	/* Release the memory */
	releaseDoubleIntArray(indexTable, INDEX_TABLE_DEC_DIMENSION);
	releaseMemoryArrayTwoDOfStarUcac3(&theUnFilteredStars);

	return TCL_OK;
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
int filterStarsUcac3(arrayTwoDOfStarUcac3* theUnFilteredStars,arrayOneDOfStarUcac3* theFilteredStars,searchZoneUcac3* mysearchZoneUcac3) {

	/* Count the stars which satisfies the criteria in mysearchZoneUcac3 */
	int numberOfStars              = 0;
	const int lengthOfTwoDArray    = (*theUnFilteredStars).length;
	/* UCAC2 stop at dec = +42 deg*/
	if(lengthOfTwoDArray == 0) {
		return 0;
	}

	//TODO
	//printf("lengthOfTwoDArray = %d\n",lengthOfTwoDArray);

	arrayOneDOfStarUcac3* arrayTwoD = (*theUnFilteredStars).arrayTwoD;
	arrayOneDOfStarUcac3 oneSetOfStar;
	starUcac3* allStars;
	starUcac3 oneStar;
	int lengthOfOneDArray,counterDec,counterRa;
	searchZoneUcac3 myLocalsearchZoneUcac3   = (*mysearchZoneUcac3); // avoid parenthesis

	for(counterDec = 0; counterDec < lengthOfTwoDArray; counterDec++) {

		oneSetOfStar      = arrayTwoD[counterDec];
		lengthOfOneDArray = oneSetOfStar.length;
		allStars          = oneSetOfStar.arrayOneD;

		//TODO
		//printf("lengthOfOneDArray = %d\n",lengthOfOneDArray);

		for(counterRa = 0; counterRa < lengthOfOneDArray; counterRa++) {
			oneStar       = allStars[counterRa];

			if((oneStar.raInMas >= myLocalsearchZoneUcac3.raStartInMas) &&
					(oneStar.raInMas <= myLocalsearchZoneUcac3.raEndInMas) &&
					(oneStar.distanceToSouthPoleInMas >= myLocalsearchZoneUcac3.distanceToPoleStartInMas) &&
					(oneStar.distanceToSouthPoleInMas <= myLocalsearchZoneUcac3.distanceToPoleEndInMas) &&
					(oneStar.ucacApertureMagInMiliMag >= myLocalsearchZoneUcac3.magnitudeStartInMiliMag) &&
					(oneStar.ucacApertureMagInMiliMag <= myLocalsearchZoneUcac3.magnitudeEndInMiliMag)) {
				numberOfStars++;
			}
		}
		//TODO
		//printf("numberOfStars = %d\n",numberOfStars);
	}

	theFilteredStars->length    = numberOfStars;
	if(numberOfStars == 0) {
		return 0;
	}
	theFilteredStars->arrayOneD = (starUcac3*)malloc(numberOfStars * sizeof(starUcac3));

	if(theFilteredStars->arrayOneD == NULL) {
		printf("Error : theFilteredStars.arrayOneD out of memory %d ucacStar",numberOfStars);
		return 1;
	}

	/* Fill the array */
	numberOfStars = 0;
	for(counterDec = 0; counterDec < lengthOfTwoDArray; counterDec++) {

		oneSetOfStar      = arrayTwoD[counterDec];
		lengthOfOneDArray = oneSetOfStar.length;
		allStars          = oneSetOfStar.arrayOneD;

		for(counterRa = 0; counterRa < lengthOfOneDArray; counterRa++) {
			oneStar       = allStars[counterRa];
			if((oneStar.raInMas >= myLocalsearchZoneUcac3.raStartInMas) &&
					(oneStar.raInMas <= myLocalsearchZoneUcac3.raEndInMas) &&
					(oneStar.distanceToSouthPoleInMas >= myLocalsearchZoneUcac3.distanceToPoleStartInMas) &&
					(oneStar.distanceToSouthPoleInMas <= myLocalsearchZoneUcac3.distanceToPoleEndInMas) &&
					(oneStar.ucacApertureMagInMiliMag >= myLocalsearchZoneUcac3.magnitudeStartInMiliMag) &&
					(oneStar.ucacApertureMagInMiliMag <= myLocalsearchZoneUcac3.magnitudeEndInMiliMag)) {

				(*theFilteredStars).arrayOneD[numberOfStars] = oneStar;
				numberOfStars++;
			}
		}
	}

	return 0;
}

/**
 * Retrieve list of stars
 */
int retrieveUnFilteredStarsUcac3(const char* pathOfCatalog, searchZoneUcac3* mysearchZoneUcac3, int** indexTable, arrayTwoDOfStarUcac3* theUnFilteredStars) {

	/* We retrive the index of all used file zones */
	int indexZoneDecStart,indexZoneDecEnd,indexZoneRaStart,indexZoneRaEnd,resultOfFunction;
	retrieveIndexesUcac3(mysearchZoneUcac3,&indexZoneDecStart,&indexZoneDecEnd,&indexZoneRaStart,&indexZoneRaEnd);

	int numberOfDecZones        = indexZoneDecEnd - indexZoneDecStart + 1;
	/* If ra is around 0, we double the size of the array */
	if((*mysearchZoneUcac3).isArroundZeroRa) {
		numberOfDecZones       *= 2;
	}

	//TODO
	printf("numberOfDecZones = %d : indexZoneDecEnd = %d - indexZoneDecStart = %d\n",numberOfDecZones,indexZoneDecEnd,indexZoneDecStart);

	theUnFilteredStars->length    = numberOfDecZones;
	if(numberOfDecZones == 0) {
		printf("Warn : no stars in the selected zone\n");
		return 1;
	}
	theUnFilteredStars->arrayTwoD = (arrayOneDOfStarUcac3*)malloc(numberOfDecZones * sizeof(arrayOneDOfStarUcac3));
	if((*theUnFilteredStars).arrayTwoD == NULL) {
		printf("Error : theUnFilteredStars.arrayTwoD out of memory %d arrayOneDOfUcacStar*\n",numberOfDecZones);
		return 1;
	}

	//printf("numberOfDecZones = %d\n",numberOfDecZones);
	/* Now we allocate the memory for each zone */
	resultOfFunction = allocateUnfiltredStarUcac3(theUnFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, (*mysearchZoneUcac3).isArroundZeroRa);
	if(resultOfFunction) {
		return 1;
	}

	/* Now we read the un-filtered stars from the catalog */
	resultOfFunction = readUnfiltredStarUcac3(pathOfCatalog, theUnFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, (*mysearchZoneUcac3).isArroundZeroRa);
	if(resultOfFunction) {
		releaseMemoryArrayTwoDOfStarUcac3(theUnFilteredStars);
		return 1;
	}

	if(DEBUG) {
		printUnfilteredStarUcac3(theUnFilteredStars);
	}

	return 0;
}

/**
 * Release memory from one arrayTwoDOfUcacStarUcac3
 */
void releaseMemoryArrayTwoDOfStarUcac3(arrayTwoDOfStarUcac3* theTwoDArray) {

	const int lengthOfTwoDArray    = theTwoDArray->length;
	/* UCAC2 stop at dec = +42 deg*/
	if(lengthOfTwoDArray == 0) {
		return;
	}
	arrayOneDOfStarUcac3* arrayTwoD = theTwoDArray->arrayTwoD;
	arrayOneDOfStarUcac3 oneSetOfStar;
	starUcac3* allStars;
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
int readUnfiltredStarUcac3(const char* pathOfCatalog, arrayTwoDOfStarUcac3* theUnFilteredStars, int** indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa) {

	int counterDec = 0;
	int indexDec;
	int resultOfFunction;
	//printf("isArroundZeroRa = %d\n",isArroundZeroRa);

	if(isArroundZeroRa) {

		const int lastZoneRa = INDEX_TABLE_RA_DIMENSION - 1;

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac3(pathOfCatalog, &(*theUnFilteredStars).arrayTwoD[counterDec],
					indexTable[indexDec], indexDec, indexZoneRaStart, lastZoneRa);
			if(resultOfFunction) {
				return 1;
			}

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac3(pathOfCatalog, &(*theUnFilteredStars).arrayTwoD[counterDec],
					indexTable[indexDec], indexDec, 0, indexZoneRaEnd);

			if(resultOfFunction) {
				return 1;
			}

			counterDec++;
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac3(pathOfCatalog, &(*theUnFilteredStars).arrayTwoD[counterDec],
					indexTable[indexDec], indexDec, indexZoneRaStart,indexZoneRaEnd);
			if(resultOfFunction) {
				return 1;
			}
			counterDec++;
		}
	}

	return 0;
}

/**
 * read stars from the catalog for one Dec zone for the un-filtered stars : case of ra not around 0
 */
int readUnfiltredStarForOneDecZoneUcac3(const char* pathOfCatalog, arrayOneDOfStarUcac3* notFilteredStarsForOneDec, int* indexTableForOneDec,
		int indexDec, const int indexZoneRaStart,const int indexZoneRaEnd) {

	//TODO
	//printf("notFilteredStarsForOneDec->length = %d\n",notFilteredStarsForOneDec->length);
	if(notFilteredStarsForOneDec->length == 0) {
		return 0;
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

	//TODO
	//printf("completeFileName = %s\n",completeFileName);
	FILE* myStream = fopen(completeFileName,"rb");

	if(myStream == NULL) {
		printf("Error : unable to open file %s\n",completeFileName);
		return 1;
	}

	/* Move to starting position */
	if(fseek(myStream,sumOfStarBefore*sizeof(starUcac3),SEEK_SET) != 0) {
		fclose(myStream);
		return 1;
	}

	int resultOfRead = (int)fread(notFilteredStarsForOneDec->arrayOneD,sizeof(starUcac3),sumOfStarToRead,myStream);

	fclose(myStream);

	if(resultOfRead != sumOfStarToRead) {
		printf("Error : resultOfRead = %d != sumOfStarToRead = %d\n",resultOfRead,sumOfStarToRead);
		return 1;
	}
	return 0;
}


/**
 * Allocate memory for one Dec zone for the un-filtered stars : case of ra not around 0
 */
int allocateUnfiltredStarUcac3(arrayTwoDOfStarUcac3* theUnilteredStars, int** indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa) {

	int counterDec = 0;
	int indexDec;
	int resultOfFunction;
	//printf("isArroundZeroRa = %d\n",isArroundZeroRa);

	if(isArroundZeroRa) {

		const int lastZoneRa = INDEX_TABLE_RA_DIMENSION - 1;

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac3(&(theUnilteredStars->arrayTwoD[counterDec]),
					indexTable[indexDec], indexZoneRaStart, lastZoneRa);
			if(resultOfFunction) {
				return 1;
			}

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac3(&(theUnilteredStars->arrayTwoD[counterDec]),
					indexTable[indexDec], 0, indexZoneRaEnd);

			if(resultOfFunction) {
				return 1;
			}

			counterDec++;

			//printf("1) indexDec = %d - counterDec = %d - indexZoneDecStart = %d - indexZoneDecEnd = %d\n",indexDec,counterDec,indexZoneDecStart,indexZoneDecEnd);
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac3(&(theUnilteredStars->arrayTwoD[counterDec]),
					indexTable[indexDec], indexZoneRaStart,indexZoneRaEnd);
			if(resultOfFunction) {
				return 1;
			}
			counterDec++;
			//printf("2) indexDec = %d - counterDec = %d - indexZoneDecStart = %d - indexZoneDecEnd = %d\n",indexDec,counterDec,indexZoneDecStart,indexZoneDecEnd);
		}
	}

	return 0;
}

/**
 * Allocate memory for one Dec zone for the un-filtered stars
 */
int allocateUnfiltredStarForOneDecZoneUcac3(arrayOneDOfStarUcac3* notFilteredStarsForOneDec, int* indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd) {

	int indexRa;
	int sumOfStar   = 0;
	for(indexRa     = indexZoneRaStart; indexRa <= indexZoneRaEnd; indexRa++) {
		sumOfStar  += indexTableForOneDec[indexRa];
	}
	//TODO
	//printf("sumOfStar = %d\n",sumOfStar);
	notFilteredStarsForOneDec->length = 0;

	if(sumOfStar > 0) {
		/* Allocate memory */
		notFilteredStarsForOneDec->length        = sumOfStar;
		notFilteredStarsForOneDec->arrayOneD     = (starUcac3*)malloc(sumOfStar * sizeof(starUcac3));
		if(notFilteredStarsForOneDec->arrayOneD == NULL) {
			printf("Error : notFilteredStarsForOneDec->arrayOneD out of memory %d ucacStar\n",sumOfStar);
			return 1;
		}
	}

	return 0;
}

/**
 * We retrive the index of all used file zones
 */
void retrieveIndexesUcac3(searchZoneUcac3* mysearchZoneUcac3,int* indexZoneDecStart,int* indexZoneDecEnd,int* indexZoneRaStart,int* indexZoneRaEnd) {

	/* dec start */
	*indexZoneDecStart     = (int)((mysearchZoneUcac3->distanceToPoleStartInMas - DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS);
	if(*indexZoneDecStart  < 0) {
		*indexZoneDecStart = 0;
	}

	/* dec end */
	*indexZoneDecEnd       = (int)((mysearchZoneUcac3->distanceToPoleEndInMas - DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS);
	if(*indexZoneDecEnd   >= INDEX_TABLE_DEC_DIMENSION) {
		*indexZoneDecEnd   = INDEX_TABLE_DEC_DIMENSION - 1;
	}

	/* ra start */
	*indexZoneRaStart     = (int)((mysearchZoneUcac3->raStartInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS);
	if(*indexZoneDecStart < 0) {
		*indexZoneRaStart = 0;
	}

	/* ra end */
	*indexZoneRaEnd     = (int)((mysearchZoneUcac3->raEndInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS);
	if(*indexZoneRaEnd >= INDEX_TABLE_RA_DIMENSION) {
		*indexZoneRaEnd = INDEX_TABLE_RA_DIMENSION - 1;
	}
}

/**
 * Read the index file
 */
int** readIndexFileUcac3(const char* pathOfCatalog) {

	int index;
	int numberOfStars;
	int decZoneNumber;
	int raZoneNumber;
	int tempInt;
	double tempDouble;
	char completeFileName[STRING_COMMON_LENGTH];
	char temporaryString[STRING_COMMON_LENGTH];
	char* temporaryPointer;
	sprintf(completeFileName,"%s/%s",pathOfCatalog,INDEX_FILE_NAME_UCAC3);

	FILE* tableStream = fopen(completeFileName,"rt");
	if(tableStream == NULL) {
		printf("Error : file %s not found\n",completeFileName);
		return NULL;
	}

	/* Allocate memory */
	int** indexTable = (int**)malloc(INDEX_TABLE_DEC_DIMENSION * sizeof(int*));
	if(indexTable == NULL) {
		printf("Error : indexTable out of memory\n");
		return NULL;
	}
	for(index = 0; index < INDEX_TABLE_DEC_DIMENSION;index++) {
		indexTable[index] = (int*)malloc(INDEX_TABLE_RA_DIMENSION * sizeof(int));
		if(indexTable[index] == NULL) {
			printf("Error : indexTable[%d] out of memory\n",index);
			return NULL;
		}
	}

	/* We read the content */
	while(!feof(tableStream)) {

		temporaryPointer = fgets(temporaryString , STRING_COMMON_LENGTH , tableStream);
		if(temporaryPointer == NULL) {
			break;
		}
		sscanf(temporaryString,FORMAT_INDEX_FILE_UCAC3,&tempInt,&numberOfStars,&decZoneNumber,&raZoneNumber,&tempDouble);
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

	return indexTable;
}

/**
 * Find the search zone having its center on (ra,dec) with a radius of radius
 *
 */
const searchZoneUcac3 findSearchZoneUcac3(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneUcac3 mysearchZoneUcac3;
	const double radiusInDeg              = radiusInArcMin / DEG2ARCMIN;
	mysearchZoneUcac3.distanceToPoleStartInMas = (int)(DEG2MAS * (decInDeg - DEC_SOUTH_POLE_DEG - radiusInDeg));
	mysearchZoneUcac3.distanceToPoleEndInMas   = (int)(DEG2MAS * (decInDeg - DEC_SOUTH_POLE_DEG + radiusInDeg));
	mysearchZoneUcac3.magnitudeStartInMiliMag  = (int)(MAG2MILIMAG * magMin);
	mysearchZoneUcac3.magnitudeEndInMiliMag    = (int)(MAG2MILIMAG * magMax);

	if((mysearchZoneUcac3.distanceToPoleStartInMas  <= DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) && (mysearchZoneUcac3.distanceToPoleEndInMas >= DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS)) {

		mysearchZoneUcac3.distanceToPoleStartInMas   = 0;
		mysearchZoneUcac3.distanceToPoleEndInMas     = DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS;
		mysearchZoneUcac3.raStartInMas               = START_RA_MAS;
		mysearchZoneUcac3.raEndInMas                 = COMPLETE_RA_MAS;
		mysearchZoneUcac3.isArroundZeroRa            = 0;

	} else if(mysearchZoneUcac3.distanceToPoleStartInMas <= DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) {

		mysearchZoneUcac3.distanceToPoleStartInMas        = 0.;
		mysearchZoneUcac3.raStartInMas                    = START_RA_MAS;
		mysearchZoneUcac3.raEndInMas                      = COMPLETE_RA_MAS;
		mysearchZoneUcac3.isArroundZeroRa                 = 0;

	} else if(mysearchZoneUcac3.distanceToPoleEndInMas >= DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS) {

		mysearchZoneUcac3.distanceToPoleEndInMas        = DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS;
		mysearchZoneUcac3.raStartInMas                  = START_RA_MAS;
		mysearchZoneUcac3.raEndInMas                    = COMPLETE_RA_MAS;
		mysearchZoneUcac3.isArroundZeroRa               = 0;

	} else {

		double ratio;
		double tmpValue;

		const double radiusRa        = radiusInDeg / cos(decInDeg * DEC2RAD);
		tmpValue                     = DEG2MAS * (raInDeg  - radiusRa);
		ratio                        = tmpValue / COMPLETE_RA_MAS;
		ratio                        = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                    -= ratio;
		mysearchZoneUcac3.raStartInMas    = (int)tmpValue;

		tmpValue                     = DEG2MAS * (raInDeg  + radiusRa);
		ratio                        = tmpValue / COMPLETE_RA_MAS;
		ratio                        = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                    -= ratio;
		mysearchZoneUcac3.raEndInMas      = (int)tmpValue;

		mysearchZoneUcac3.isArroundZeroRa      = 0;

		if(mysearchZoneUcac3.raStartInMas      >  mysearchZoneUcac3.raEndInMas) {
			mysearchZoneUcac3.isArroundZeroRa  = 1;
		}
	}

	if(!DEBUG) {
		printf("mysearchZoneUcac3.decStart        = %d\n",mysearchZoneUcac3.distanceToPoleStartInMas);
		printf("mysearchZoneUcac3.decEnd          = %d\n",mysearchZoneUcac3.distanceToPoleEndInMas);
		printf("mysearchZoneUcac3.raStart         = %d\n",mysearchZoneUcac3.raStartInMas);
		printf("mysearchZoneUcac3.raEnd           = %d\n",mysearchZoneUcac3.raEndInMas);
		printf("mysearchZoneUcac3.isArroundZeroRa = %d\n",mysearchZoneUcac3.isArroundZeroRa);
		printf("mysearchZoneUcac3.magnitudeStart  = %d\n",mysearchZoneUcac3.magnitudeStartInMiliMag);
		printf("mysearchZoneUcac3.magnitudeEnd    = %d\n",mysearchZoneUcac3.magnitudeEndInMiliMag);
	}

	return mysearchZoneUcac3;
}

/**
 * Print the un filtered stars
 */
void printUnfilteredStarUcac3(arrayTwoDOfStarUcac3* theUnilteredStars) {

	printf("The un-filtered stars are :\n");
	arrayOneDOfStarUcac3* arrayTwoD = theUnilteredStars->arrayTwoD;
	arrayOneDOfStarUcac3 oneSetOfStar;
	starUcac3 oneStar;
	int indexRa,indexDec;

	for(indexDec = 0; indexDec < theUnilteredStars->length; indexDec++) {

		oneSetOfStar = arrayTwoD[indexDec];

		for(indexRa = 0; indexRa < oneSetOfStar.length; indexRa++) {

			oneStar = oneSetOfStar.arrayOneD[indexRa];
			printf("indexDec = %3d - indexRa = %3d : %8.4f %+8.4f %5.2f\n",indexDec,indexRa,oneStar.raInMas/DEG2MAS,
					oneStar.distanceToSouthPoleInMas/DEG2MAS,oneStar.ucacApertureMagInMiliMag/MAG2MILIMAG);
		}
	}
}
