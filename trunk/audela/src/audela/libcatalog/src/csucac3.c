#include "csucac.h"
/*
 * csucac3.c
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

static char outputLogChar[1024];

int cmd_tcl_csucac3(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char* pathToCatalog;
	int resultOfFunction;
	int idOfStar;
	int counterDec;
	int counterRa;
	double ra;
	double dec;
	double radius;
	double magMin;
	double magMax;
	indexTableUcac** indexTable;
	starUcac3 oneStar;
	searchZoneUcac3 mySearchZoneUcac3;
	arrayTwoDOfStarUcac3 unFilteredStars;
	arrayOneDOfStarUcac3 oneSetOfStar;
	starUcac3* allStars;
	Tcl_DString dsptr;

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
	pathToCatalog = argv[1];
	ra            = atof(argv[2]);
	dec           = atof(argv[3]);
	radius        = atof(argv[4]);
	if(argc == 7) {
		magMin    = atof(argv[5]);
		magMax    = atof(argv[6]);
	} else {
		magMin    = -99.99;
		magMax    = 99.99;
	}

	/* Add slash to the end of the path if not exist*/
	addLastSlashToPath(pathToCatalog);

	/* Define search zone */
	mySearchZoneUcac3 = findSearchZoneUcac3(ra,dec,radius,magMin,magMax);

	/* Read the index file */
	indexTable        = readIndexFileUcac3(pathToCatalog);
	if(indexTable == NULL) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Now read the catalog and retrieve stars */
	resultOfFunction = retrieveUnfilteredStarsUcac3(pathToCatalog,&mySearchZoneUcac3,indexTable,&unFilteredStars);
	if(resultOfFunction) {
		releaseDoubleArray((void**)indexTable, INDEX_TABLE_DEC_DIMENSION);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Print the filtered stars */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { UCAC3 { } "
			"{ ID ra_deg dec_deg im1_mag im2_mag sigmag_mag objt dsf sigra_deg sigdc_deg na1 nu1 us1 cn1 cepra_deg cepdc_deg "
			"pmrac_masperyear pmdc_masperyear sigpmr_masperyear sigpmd_masperyear id2m jmag_mag hmag_mag kmag_mag jicqflg hicqflg kicqflg je2mpho he2mpho ke2mpho "
			"smB_mag smR2_mag smI_mag clbl qfB qfR2 qfI "
			"catflg1 catflg2 catflg3 catflg4 catflg5 catflg6 catflg7 catflg8 catflg9 catflg10 "
			"g1 c1 leda x2m rn } } } ",-1);
	Tcl_DStringAppend(&dsptr,"{",-1); // start of sources list

	for(counterDec = 0; counterDec < unFilteredStars.length; counterDec++) {

		oneSetOfStar  = unFilteredStars.arrayTwoD[counterDec];
		allStars      = oneSetOfStar.arrayOneD;
		idOfStar      = oneSetOfStar.idOfFirstStarInArray;

		for(counterRa = 0; counterRa < oneSetOfStar.length; counterRa++) {

			idOfStar++;
			oneStar   = allStars[counterRa];

			if(isGoodStarUcac3(&oneStar,&mySearchZoneUcac3)) {

				Tcl_DStringAppend(&dsptr,"{ { UCAC3 { } {",-1);

				sprintf(outputLogChar,"%03d-%06d %.8f %+.8f %.3f %.3f %.3f %d %d %.8f %.8f %d %d %d %d %.8f %+.8f "
						"%+.8f %+.8f %.8f %.8f %d %.3f %.3f %.3f %d %d %d %.3f %.3f %.3f "
						"%.3f %.3f %.3f %d %d %d %d "
						"%d %d %d %d %d %d %d %d %d %d "
						"%d %d %d %d %d",

						oneSetOfStar.indexDec,idOfStar, // the ID %03d-%06d
						(double)oneStar.raInMas/DEG2MAS,
						(double)oneStar.distanceToSouthPoleInMas / DEG2MAS + DEC_SOUTH_POLE_DEG,
						(double)oneStar.ucacFitMagInMilliMag / MAG2MILLIMAG,
						(double)oneStar.ucacApertureMagInMilliMag / MAG2MILLIMAG,
						(double)oneStar.ucacErrorMagInMilliMag / MAG2MILLIMAG,
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
						(double)oneStar.jMagnitude2MassInMilliMag / MAG2MILLIMAG,
						(double)oneStar.hMagnitude2MassInMilliMag / MAG2MILLIMAG,
						(double)oneStar.kMagnitude2MassInMilliMag / MAG2MILLIMAG,
						oneStar.jQualityFlag2Mass,
						oneStar.hQualityFlag2Mass,
						oneStar.kQualityFlag2Mass,
						(double)oneStar.jErrorMagnitude2MassInCentiMag / MAG2CENTIMAG,
						(double)oneStar.hErrorMagnitude2MassInCentiMag / MAG2CENTIMAG,
						(double)oneStar.kErrorMagnitude2MassInCentiMag / MAG2CENTIMAG,

						(double)oneStar.bMagnitudeSCInMilliMag / MAG2MILLIMAG,
						(double)oneStar.r2MagnitudeSCInMilliMag / MAG2MILLIMAG,
						(double)oneStar.iMagnitudeSCInMilliMag / MAG2MILLIMAG,
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

				Tcl_DStringAppend(&dsptr,outputLogChar,-1);
				Tcl_DStringAppend(&dsptr,"} } } ",-1);
			}
		}
	}

	// end of sources list
	Tcl_DStringAppend(&dsptr,"}",-1); // end of main list
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	/* Release the memory */
	releaseDoubleArray((void**)indexTable, INDEX_TABLE_DEC_DIMENSION);
	releaseMemoryArrayTwoDOfStarUcac3(&unFilteredStars);

	return (TCL_OK);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
int isGoodStarUcac3(const starUcac3* const oneStar,const searchZoneUcac3* const mySearchZoneUcac3) {

	if(
			((mySearchZoneUcac3->isArroundZeroRa && ((oneStar->raInMas >= mySearchZoneUcac3->raStartInMas) || (oneStar->raInMas <= mySearchZoneUcac3->raEndInMas))) ||
					(!mySearchZoneUcac3->isArroundZeroRa && ((oneStar->raInMas >= mySearchZoneUcac3->raStartInMas) && (oneStar->raInMas <= mySearchZoneUcac3->raEndInMas)))) &&
					(oneStar->distanceToSouthPoleInMas  >= mySearchZoneUcac3->distanceToPoleStartInMas) &&
					(oneStar->distanceToSouthPoleInMas  <= mySearchZoneUcac3->distanceToPoleEndInMas) &&
					(oneStar->ucacApertureMagInMilliMag >= mySearchZoneUcac3->magnitudeStartInMilliMag) &&
					(oneStar->ucacApertureMagInMilliMag <= mySearchZoneUcac3->magnitudeEndInMilliMag)) {

		return (1);
	}

	return (0);
}

/**
 * Retrieve list of stars
 */
int retrieveUnfilteredStarsUcac3(const char* const pathOfCatalog, const searchZoneUcac3* const mySearchZoneUcac3,
		indexTableUcac* const * const indexTable, arrayTwoDOfStarUcac3* const unFilteredStars) {

	/* We retrieve the index of all used file zones */
	int indexZoneDecStart,indexZoneDecEnd,indexZoneRaStart,indexZoneRaEnd,resultOfFunction;
	int numberOfDecZones;

	retrieveIndexesUcac3(mySearchZoneUcac3,&indexZoneDecStart,&indexZoneDecEnd,&indexZoneRaStart,&indexZoneRaEnd);

	numberOfDecZones      = indexZoneDecEnd - indexZoneDecStart + 1;
	/* If ra is around 0, we double the size of the array */
	if(mySearchZoneUcac3->isArroundZeroRa) {
		numberOfDecZones *= 2;
	}

	unFilteredStars->length        = numberOfDecZones;
	if(numberOfDecZones == 0) {
		sprintf(outputLogChar,"Warn : no stars in the selected zone\n");
		return (1);
	}
	unFilteredStars->arrayTwoD     = (arrayOneDOfStarUcac3*)malloc(numberOfDecZones * sizeof(arrayOneDOfStarUcac3));
	if((*unFilteredStars).arrayTwoD == NULL) {
		sprintf(outputLogChar,"Error : theUnFilteredStars.arrayTwoD out of memory %d arrayOneDOfUcacStar*\n",numberOfDecZones);
		return (1);
	}

	//printf("numberOfDecZones = %d\n",numberOfDecZones);
	/* Now we allocate the memory for each zone */
	resultOfFunction = allocateUnfiltredStarUcac3(unFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, mySearchZoneUcac3->isArroundZeroRa);
	if(resultOfFunction) {
		return (1);
	}

	/* Now we read the un-filtered stars from the catalog */
	resultOfFunction = readUnfiltredStarUcac3(pathOfCatalog, unFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, mySearchZoneUcac3->isArroundZeroRa);
	if(resultOfFunction) {
		releaseMemoryArrayTwoDOfStarUcac3(unFilteredStars);
		return (1);
	}

	if(DEBUG) {
		printUnfilteredStarUcac3(unFilteredStars);
	}

	return (0);
}

/**
 * Release memory from one arrayTwoDOfUcacStarUcac3
 */
void releaseMemoryArrayTwoDOfStarUcac3(const arrayTwoDOfStarUcac3* const theTwoDArray) {

	arrayOneDOfStarUcac3* arrayTwoD;
	arrayOneDOfStarUcac3 oneSetOfStar;
	starUcac3* allStars;
	int counterDec;

	/* UCAC2 stop at dec = +42 deg*/
	if(theTwoDArray->length == 0) {
		return;
	}
	arrayTwoD = theTwoDArray->arrayTwoD;

	for(counterDec = 0; counterDec < theTwoDArray->length; counterDec++) {

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
int readUnfiltredStarUcac3(const char* const pathOfCatalog, const arrayTwoDOfStarUcac3* const unFilteredStars, indexTableUcac* const * const indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa) {

	int indexDec;
	int resultOfFunction;
	const int lastZoneRa = INDEX_TABLE_RA_DIMENSION - 1;
	int counterDec       = 0;

	if(isArroundZeroRa) {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac3(pathOfCatalog, &(unFilteredStars->arrayTwoD[counterDec]),
					indexTable[indexDec], indexDec, indexZoneRaStart, lastZoneRa);
			if(resultOfFunction) {
				return (1);
			}

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac3(pathOfCatalog, &(unFilteredStars->arrayTwoD[counterDec]),
					indexTable[indexDec], indexDec, 0, indexZoneRaEnd);

			if(resultOfFunction) {
				return (1);
			}

			counterDec++;
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac3(pathOfCatalog, &(unFilteredStars->arrayTwoD[counterDec]),
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
int readUnfiltredStarForOneDecZoneUcac3(const char* const pathOfCatalog, arrayOneDOfStarUcac3* const unFilteredStarsForOneDec,
		const indexTableUcac* const indexTableForOneDec,int indexDec, const int indexZoneRaStart,const int indexZoneRaEnd) {

	char completeFileName[1024];
	int indexRa;
	int sumOfStarBefore;
	int resultOfRead;
	FILE* myStream;

	if(unFilteredStarsForOneDec->length == 0) {
		return (0);
	}

	sumOfStarBefore      = 0;
	for(indexRa          = 0; indexRa < indexZoneRaStart; indexRa++) {
		sumOfStarBefore += indexTableForOneDec[indexRa].numberOfStarsInZone;
	}

	/* Open the file */
	indexDec++; //Names start with 1 not 0
	sprintf(completeFileName,ZONE_FILE_FORMAT_NAME,pathOfCatalog,indexDec);

	//printf("completeFileName = %s\n",completeFileName);
	myStream = fopen(completeFileName,"rb");

	if(myStream == NULL) {
		sprintf(outputLogChar,"Error : unable to open file %s\n",completeFileName);
		return (1);
	}

	/* Move to starting position */
	if(fseek(myStream,sumOfStarBefore*sizeof(starUcac3),SEEK_SET) != 0) {
		sprintf(outputLogChar,"Error : when moving inside %s\n",completeFileName);
		fclose(myStream);
		return (1);
	}

	resultOfRead = (int)fread(unFilteredStarsForOneDec->arrayOneD,sizeof(starUcac3),unFilteredStarsForOneDec->length,myStream);

	unFilteredStarsForOneDec->idOfFirstStarInArray = indexTableForOneDec[indexZoneRaStart].idOfFirstStarInZone;
	unFilteredStarsForOneDec->indexDec             = indexDec;

	fclose(myStream);

	if(resultOfRead != unFilteredStarsForOneDec->length) {
		sprintf(outputLogChar,"Error : resultOfRead = %d != sumOfStarToRead = %d\n",resultOfRead,unFilteredStarsForOneDec->length);
		return (1);
	}
	return (0);
}


/**
 * Allocate memory for one Dec zone for the un-filtered stars : case of ra not around 0
 */
int allocateUnfiltredStarUcac3(const arrayTwoDOfStarUcac3* const unFilteredStars, indexTableUcac* const * const indexTable,const int indexZoneDecStart,
		const int indexZoneDecEnd,const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa) {

	int indexDec;
	int resultOfFunction;
	const int lastZoneRa = INDEX_TABLE_RA_DIMENSION - 1;
	int counterDec       = 0;

	if(isArroundZeroRa) {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac3(&(unFilteredStars->arrayTwoD[counterDec]),
					indexTable[indexDec], indexZoneRaStart, lastZoneRa);
			if(resultOfFunction) {
				return (1);
			}

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac3(&(unFilteredStars->arrayTwoD[counterDec]),
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
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac3(&(unFilteredStars->arrayTwoD[counterDec]),
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
int allocateUnfiltredStarForOneDecZoneUcac3(arrayOneDOfStarUcac3* const unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd) {

	int indexRa;
	int sumOfStar   = 0;

	for(indexRa     = indexZoneRaStart; indexRa <= indexZoneRaEnd; indexRa++) {
		sumOfStar  += indexTableForOneDec[indexRa].numberOfStarsInZone;
	}

	unFilteredStarsForOneDec->length = 0;

	if(sumOfStar > 0) {
		/* Allocate memory */
		unFilteredStarsForOneDec->length        = sumOfStar;
		unFilteredStarsForOneDec->arrayOneD     = (starUcac3*)malloc(sumOfStar * sizeof(starUcac3));
		if(unFilteredStarsForOneDec->arrayOneD == NULL) {
			sprintf(outputLogChar,"Error : notFilteredStarsForOneDec->arrayOneD out of memory %d ucacStar\n",sumOfStar);
			return (1);
		}
	}

	return (0);
}

/**
 * We retrive the index of all used file zones
 */
void retrieveIndexesUcac3(const searchZoneUcac3* const mySearchZoneUcac3,int* const indexZoneDecStart,int* const indexZoneDecEnd,
		int* const indexZoneRaStart,int* const indexZoneRaEnd) {

	/* dec start */
	*indexZoneDecStart     = (int)((mySearchZoneUcac3->distanceToPoleStartInMas - DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS);
	if(*indexZoneDecStart  < 0) {
		*indexZoneDecStart = 0;
	}

	/* dec end */
	*indexZoneDecEnd       = (int)((mySearchZoneUcac3->distanceToPoleEndInMas - DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS);
	if(*indexZoneDecEnd   >= INDEX_TABLE_DEC_DIMENSION) {
		*indexZoneDecEnd   = INDEX_TABLE_DEC_DIMENSION - 1;
	}

	/* ra start */
	*indexZoneRaStart     = (int)((mySearchZoneUcac3->raStartInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS);
	if(*indexZoneDecStart < 0) {
		*indexZoneRaStart = 0;
	}

	/* ra end */
	*indexZoneRaEnd     = (int)((mySearchZoneUcac3->raEndInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS);
	if(*indexZoneRaEnd >= INDEX_TABLE_RA_DIMENSION) {
		*indexZoneRaEnd = INDEX_TABLE_RA_DIMENSION - 1;
	}
}

/**
 * Read the index file
 */
indexTableUcac** readIndexFileUcac3(const char* const pathOfCatalog) {

	char completeFileName[STRING_COMMON_LENGTH];
	char temporaryString[STRING_COMMON_LENGTH];
	char* temporaryPointer;
	int index;
	int numberOfStars;
	int decZoneNumber;
	int raZoneNumber;
	int numberOfStarsInPreviousZones;
	int index2;
	double tempDouble;
	indexTableUcac** indexTable;
	FILE* tableStream;

	sprintf(completeFileName,"%s/%s",pathOfCatalog,INDEX_FILE_NAME_UCAC3);
	tableStream = fopen(completeFileName,"rt");
	if(tableStream == NULL) {
		sprintf(outputLogChar,"Error : file %s not found\n",completeFileName);
		return (NULL);
	}

	/* Allocate memory */
	indexTable    = (indexTableUcac**)malloc(INDEX_TABLE_DEC_DIMENSION * sizeof(indexTableUcac*));
	if(indexTable == NULL) {
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		return (NULL);
	}
	for(index = 0; index < INDEX_TABLE_DEC_DIMENSION;index++) {
		indexTable[index] = (indexTableUcac*)malloc(INDEX_TABLE_RA_DIMENSION * sizeof(indexTableUcac));
		if(indexTable[index] == NULL) {
			sprintf(outputLogChar,"Error : indexTable[%d] out of memory\n",index);
			return (NULL);
		}
	}

	/* We read the content */
	while(!feof(tableStream)) {

		temporaryPointer = fgets(temporaryString , STRING_COMMON_LENGTH , tableStream);
		if(temporaryPointer == NULL) {
			break;
		}
		sscanf(temporaryString,FORMAT_INDEX_FILE_UCAC3,&numberOfStarsInPreviousZones,&numberOfStars,&decZoneNumber,&raZoneNumber,&tempDouble);
		indexTable[decZoneNumber - 1][raZoneNumber - 1].numberOfStarsInZone = numberOfStars;
		indexTable[decZoneNumber - 1][raZoneNumber - 1].idOfFirstStarInZone = numberOfStarsInPreviousZones;
	}

	fclose(tableStream);

	if(DEBUG) {
		for(index = 0; index < INDEX_TABLE_DEC_DIMENSION;index++) {
			for(index2 = 0; index2 < INDEX_TABLE_RA_DIMENSION;index2++) {
				printf("indexTable[%3d][%3d] = %d\n",index,index2,indexTable[index][index2].numberOfStarsInZone);
			}
		}
	}

	return (indexTable);
}

/**
 * Find the search zone having its center on (ra,dec) with a radius of radius
 *
 */
const searchZoneUcac3 findSearchZoneUcac3(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneUcac3 mySearchZoneUcac3;
	const double radiusInDeg                   = radiusInArcMin / DEG2ARCMIN;
	double ratio;
	double tmpValue;
	double radiusRa;

	mySearchZoneUcac3.distanceToPoleStartInMas = (int)(DEG2MAS * (decInDeg - DEC_SOUTH_POLE_DEG - radiusInDeg));
	mySearchZoneUcac3.distanceToPoleEndInMas   = (int)(DEG2MAS * (decInDeg - DEC_SOUTH_POLE_DEG + radiusInDeg));
	mySearchZoneUcac3.magnitudeStartInMilliMag = (int)(MAG2MILLIMAG * magMin);
	mySearchZoneUcac3.magnitudeEndInMilliMag   = (int)(MAG2MILLIMAG * magMax);

	if((mySearchZoneUcac3.distanceToPoleStartInMas  <= DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) && (mySearchZoneUcac3.distanceToPoleEndInMas >= DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS)) {

		mySearchZoneUcac3.distanceToPoleStartInMas   = 0;
		mySearchZoneUcac3.distanceToPoleEndInMas     = DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS;
		mySearchZoneUcac3.raStartInMas               = START_RA_MAS;
		mySearchZoneUcac3.raEndInMas                 = COMPLETE_RA_MAS;
		mySearchZoneUcac3.isArroundZeroRa            = 0;

	} else if(mySearchZoneUcac3.distanceToPoleStartInMas <= DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) {

		mySearchZoneUcac3.distanceToPoleStartInMas        = 0;
		mySearchZoneUcac3.raStartInMas                    = START_RA_MAS;
		mySearchZoneUcac3.raEndInMas                      = COMPLETE_RA_MAS;
		mySearchZoneUcac3.isArroundZeroRa                 = 0;

	} else if(mySearchZoneUcac3.distanceToPoleEndInMas >= DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS) {

		mySearchZoneUcac3.distanceToPoleEndInMas        = DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_MAS;
		mySearchZoneUcac3.raStartInMas                  = START_RA_MAS;
		mySearchZoneUcac3.raEndInMas                    = COMPLETE_RA_MAS;
		mySearchZoneUcac3.isArroundZeroRa               = 0;

	} else {

		radiusRa                        = radiusInDeg / cos(decInDeg * DEC2RAD);
		tmpValue                        = DEG2MAS * (raInDeg  - radiusRa);
		ratio                           = tmpValue / COMPLETE_RA_MAS;
		ratio                           = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                       -= ratio;
		mySearchZoneUcac3.raStartInMas  = (int)tmpValue;

		tmpValue                     = DEG2MAS * (raInDeg  + radiusRa);
		ratio                        = tmpValue / COMPLETE_RA_MAS;
		ratio                        = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                    -= ratio;
		mySearchZoneUcac3.raEndInMas      = (int)tmpValue;

		mySearchZoneUcac3.isArroundZeroRa      = 0;

		if(mySearchZoneUcac3.raStartInMas      >  mySearchZoneUcac3.raEndInMas) {
			mySearchZoneUcac3.isArroundZeroRa  = 1;
		}
	}

	if(DEBUG) {
		printf("mySearchZoneUcac3.decStart        = %d\n",mySearchZoneUcac3.distanceToPoleStartInMas);
		printf("mySearchZoneUcac3.decEnd          = %d\n",mySearchZoneUcac3.distanceToPoleEndInMas);
		printf("mySearchZoneUcac3.raStart         = %d\n",mySearchZoneUcac3.raStartInMas);
		printf("mySearchZoneUcac3.raEnd           = %d\n",mySearchZoneUcac3.raEndInMas);
		printf("mySearchZoneUcac3.isArroundZeroRa = %d\n",mySearchZoneUcac3.isArroundZeroRa);
		printf("mySearchZoneUcac3.magnitudeStart  = %d\n",mySearchZoneUcac3.magnitudeStartInMilliMag);
		printf("mySearchZoneUcac3.magnitudeEnd    = %d\n",mySearchZoneUcac3.magnitudeEndInMilliMag);
	}

	return (mySearchZoneUcac3);
}

/**
 * Print the un filtered stars
 */
void printUnfilteredStarUcac3(const arrayTwoDOfStarUcac3* const unFilteredStars) {

	arrayOneDOfStarUcac3* arrayTwoD;
	arrayOneDOfStarUcac3 oneSetOfStar;
	starUcac3 oneStar;
	int indexRa,indexDec;

	printf("The un-filtered stars are :\n");
	arrayTwoD = unFilteredStars->arrayTwoD;

	for(indexDec = 0; indexDec < unFilteredStars->length; indexDec++) {

		oneSetOfStar = arrayTwoD[indexDec];

		for(indexRa = 0; indexRa < oneSetOfStar.length; indexRa++) {

			oneStar = oneSetOfStar.arrayOneD[indexRa];
			printf("indexDec = %3d - indexRa = %3d : %8.4f %+8.4f %5.2f\n",indexDec,indexRa,oneStar.raInMas/DEG2MAS,
					oneStar.distanceToSouthPoleInMas/DEG2MAS,oneStar.ucacApertureMagInMilliMag/MAG2MILLIMAG);
		}
	}
}
