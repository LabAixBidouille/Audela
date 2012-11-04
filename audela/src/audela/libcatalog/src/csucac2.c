#include "csucac.h"
/*
 * csucac2.c
 *
 *  Created on: Dec 13, 2011
 *      Author: Y. Damerdji
 */

static char outputLogChar[1024];

int cmd_tcl_csucac2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char* pathToCatalog;
	int resultOfFunction;
	int counterDec;
	int counterRa;
	int idOfStar;
	double ra;
	double dec;
	double radius;
	double magMin;
	double magMax;
	indexTableUcac** indexTable;
	starUcac2 oneStar;
	searchZoneUcac2 mySearchZoneUcac2;
	arrayTwoDOfStarUcac2 unFilteredStars;
	arrayOneDOfStarUcac2 oneSetOfStar;
	starUcac2* allStars;
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
	mySearchZoneUcac2 = findSearchZoneUcac2(ra,dec,radius,magMin,magMax);

	/* Read the index file */
	indexTable        = readIndexFileUcac2(pathToCatalog);
	if(indexTable == NULL) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Now read the catalog and retrieve stars */
	resultOfFunction = retrieveUnfilteredStarsUcac2(pathToCatalog,&mySearchZoneUcac2,indexTable,&unFilteredStars);
	if(resultOfFunction) {
		releaseDoubleArray((void**)indexTable, INDEX_TABLE_DEC_DIMENSION_UCAC2AND3);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Print the filtered stars */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { UCAC2 { } "
			"{ ID ra_deg dec_deg U2Rmag_mag e_RAm_deg e_DEm_deg nobs e_pos_deg ncat cflg "
			"EpRAm_deg EpDEm_deg pmRA_masperyear pmDEC_masperyear e_pmRA_masperyear e_pmDE_masperyear "
			"q_pmRA q_pmDE 2m_id 2m_J 2m_H 2m_Ks 2m_ph 2m_cc} } } ",-1);
	Tcl_DStringAppend(&dsptr,"{",-1); // start of sources list

	for(counterDec = 0; counterDec < unFilteredStars.length; counterDec++) {

		oneSetOfStar  = unFilteredStars.arrayTwoD[counterDec];
		allStars      = oneSetOfStar.arrayOneD;
		idOfStar      = oneSetOfStar.idOfFirstStarInArray;

		for(counterRa = 0; counterRa < oneSetOfStar.length; counterRa++) {

			idOfStar++;
			oneStar   = allStars[counterRa];

			if(isGoodStarUcac2(&oneStar,&mySearchZoneUcac2)) {

				Tcl_DStringAppend(&dsptr,"{ { UCAC2 { } {",-1);

				sprintf(outputLogChar,
						"%d %.8f %+.8f %.3f %.8f %.8f %d %.8f %d %d "
						"%.8f %.8f %.8f %.8f %.8f %.8f "
						"%.5f %.5f %d %.3f %.3f %.3f %d %d",

						idOfStar,
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

						(double)oneStar.raProperMotionGoodnessOfFit * 0.05,
						(double)oneStar.decProperMotionGoodnessOfFit * 0.05,
						oneStar.idFrom2Mass,
						(double)oneStar.jMagnitude2MassInMilliMag / MAG2MILLIMAG,
						(double)oneStar.hMagnitude2MassInMilliMag / MAG2MILLIMAG,
						(double)oneStar.kMagnitude2MassInMilliMag / MAG2MILLIMAG,
						oneStar.qualityFlag2Mass,
						oneStar.ccFlag2Mass);

				Tcl_DStringAppend(&dsptr,outputLogChar,-1);
				Tcl_DStringAppend(&dsptr,"} } } ",-1);
			}
		}
	}

	Tcl_DStringAppend(&dsptr,"}",-1); // end of main list
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	/* Release the memory */
	releaseDoubleArray((void**)indexTable, INDEX_TABLE_DEC_DIMENSION_UCAC2AND3);
	releaseMemoryArrayTwoDOfStarUcac2(&unFilteredStars);

	return (TCL_OK);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
int isGoodStarUcac2(const starUcac2* const oneStar,const searchZoneUcac2* const mySearchZoneUcac2) {

	if(
			((mySearchZoneUcac2->isArroundZeroRa && ((oneStar->raInMas >= mySearchZoneUcac2->raStartInMas) || (oneStar->raInMas <= mySearchZoneUcac2->raEndInMas))) ||
					(!mySearchZoneUcac2->isArroundZeroRa && ((oneStar->raInMas >= mySearchZoneUcac2->raStartInMas) && (oneStar->raInMas <= mySearchZoneUcac2->raEndInMas)))) &&
					(oneStar->decInMas >= mySearchZoneUcac2->decStartInMas) &&
					(oneStar->decInMas <= mySearchZoneUcac2->decEndInMas) &&
					(oneStar->ucacMagInCentiMag >= mySearchZoneUcac2->magnitudeStartInCentiMag) &&
					(oneStar->ucacMagInCentiMag <= mySearchZoneUcac2->magnitudeEndInCentiMag)) {

		return(1);
	}

	return (0);
}

/**
 * Retrieve list of stars
 */
int retrieveUnfilteredStarsUcac2(const char* const pathOfCatalog, const searchZoneUcac2* const mySearchZoneUcac2,
		indexTableUcac* const * const indexTable, arrayTwoDOfStarUcac2* const unFilteredStars) {

	/* We retrieve the index of all used file zones */
	int indexZoneDecStart,indexZoneDecEnd,indexZoneRaStart,indexZoneRaEnd,resultOfFunction;
	int numberOfDecZones;

	retrieveIndexesUcac2(mySearchZoneUcac2,&indexZoneDecStart,&indexZoneDecEnd,&indexZoneRaStart,&indexZoneRaEnd);

	numberOfDecZones      = indexZoneDecEnd - indexZoneDecStart + 1;

	/* If RA is around 0, we double the size of the array */
	if(mySearchZoneUcac2->isArroundZeroRa) {
		numberOfDecZones *= 2;
	}

	unFilteredStars->length        = numberOfDecZones;
	if(numberOfDecZones == 0) {
		sprintf(outputLogChar,"Warn : no stars in the selected zone\n");
		return (1);
	}
	unFilteredStars->arrayTwoD     = (arrayOneDOfStarUcac2*)malloc(numberOfDecZones * sizeof(arrayOneDOfStarUcac2));
	if(unFilteredStars->arrayTwoD == NULL) {
		sprintf(outputLogChar,"Error : theUnFilteredStars.arrayTwoD out of memory %d arrayOneDOfucacStarUcac2*\n",numberOfDecZones);
		return (1);
	}

	//printf("numberOfDecZones = %d\n",numberOfDecZones);
	/* Now we allocate the memory for each zone */
	resultOfFunction = allocateUnfiltredStarUcac2(unFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, mySearchZoneUcac2->isArroundZeroRa);
	if(resultOfFunction) {
		return (1);
	}

	/* Now we read the un-filtered stars from the catalog */
	resultOfFunction = readUnfiltredStarUcac2(pathOfCatalog, unFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, mySearchZoneUcac2->isArroundZeroRa);
	if(resultOfFunction) {
		releaseMemoryArrayTwoDOfStarUcac2(unFilteredStars);
		return (1);
	}

	if(DEBUG) {
		printUnfilteredStarUcac2(unFilteredStars);
	}

	return (0);
}

/**
 * Release memory from one arrayTwoDOfucacStarUcac2
 */
void releaseMemoryArrayTwoDOfStarUcac2(const arrayTwoDOfStarUcac2* const theTwoDArray) {

	arrayOneDOfStarUcac2* arrayTwoD;
	arrayOneDOfStarUcac2 oneSetOfStar;
	starUcac2* allStars;
	int counterDec;

	/* UCAC2 stop at dec = +42 deg*/
	if(theTwoDArray->length == 0) {
		return;
	}

	arrayTwoD = theTwoDArray->arrayTwoD;

	for(counterDec = 0; counterDec < theTwoDArray->length; counterDec++) {

		if(arrayTwoD[counterDec].length > 0) {
			oneSetOfStar  = arrayTwoD[counterDec];
			allStars      = oneSetOfStar.arrayOneD;
			releaseSimpleArray(allStars);
		}
	}
	free(arrayTwoD);
}

/**
 * Read the stars from the catalog
 */
int readUnfiltredStarUcac2(const char* const pathOfCatalog, const arrayTwoDOfStarUcac2* const unFilteredStars,
		indexTableUcac* const * const indexTable, const int indexZoneDecStart,const int indexZoneDecEnd,
		const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa) {

	int indexDec;
	int resultOfFunction;
	const int lastZoneRa = INDEX_TABLE_RA_DIMENSION_UCAC2AND3 - 1;
	int counterDec       = 0;

	if(isArroundZeroRa) {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac2(pathOfCatalog, &(unFilteredStars->arrayTwoD[counterDec]),
					indexTable[indexDec], indexDec, indexZoneRaStart, lastZoneRa);
			if(resultOfFunction) {
				return (1);
			}

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac2(pathOfCatalog, &(unFilteredStars->arrayTwoD[counterDec]),
					indexTable[indexDec], indexDec, 0, indexZoneRaEnd);

			if(resultOfFunction) {
				return (1);
			}

			counterDec++;
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac2(pathOfCatalog, &(unFilteredStars->arrayTwoD[counterDec]),
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
int readUnfiltredStarForOneDecZoneUcac2(const char* const pathOfCatalog, arrayOneDOfStarUcac2* const unFilteredStarsForOneDec,
		const indexTableUcac* const indexTableForOneDec, int indexDec, const int indexZoneRaStart,const int indexZoneRaEnd) {

	char completeFileName[1024];
	int resultOfRead;
	int indexRa;
	int sumOfStarBefore;
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
	sprintf(completeFileName,ZONE_FILE_FORMAT_NAME_UCAC2AND3,pathOfCatalog,indexDec);

	myStream = fopen(completeFileName,"rb");
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

	resultOfRead = (int)fread(unFilteredStarsForOneDec->arrayOneD,sizeof(starUcac2),unFilteredStarsForOneDec->length,myStream);

	unFilteredStarsForOneDec->idOfFirstStarInArray = indexTableForOneDec[indexZoneRaStart].idOfFirstStarInZone;

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
int allocateUnfiltredStarUcac2(const arrayTwoDOfStarUcac2* const unFilteredStars, indexTableUcac* const * const indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa) {

	int indexDec;
	int resultOfFunction;
	const int lastZoneRa = INDEX_TABLE_RA_DIMENSION_UCAC2AND3 - 1;
	int counterDec       = 0;

	if(isArroundZeroRa) {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac2(&(unFilteredStars->arrayTwoD[counterDec]),
					indexTable[indexDec], indexZoneRaStart, lastZoneRa);
			if(resultOfFunction) {
				return (1);
			}

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac2(&(unFilteredStars->arrayTwoD[counterDec]),
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
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac2(&(unFilteredStars->arrayTwoD[counterDec]),
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
int allocateUnfiltredStarForOneDecZoneUcac2(arrayOneDOfStarUcac2* const unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
		const int indexZoneRaStart,const int indexZoneRaEnd) {

	int indexRa;
	int sumOfStar  = 0;
	for(indexRa    = indexZoneRaStart; indexRa <= indexZoneRaEnd; indexRa++) {
		sumOfStar += indexTableForOneDec[indexRa].numberOfStarsInZone;
	}

	unFilteredStarsForOneDec->length = sumOfStar;

	if(sumOfStar > 0) {
		/* Allocate memory */
		unFilteredStarsForOneDec->arrayOneD     = (starUcac2*)malloc(sumOfStar * sizeof(starUcac2));
		if(unFilteredStarsForOneDec->arrayOneD == NULL) {
			sprintf(outputLogChar,"Error : unFilteredStarsForOneDec->arrayOneD out of memory %d starUcac2\n",sumOfStar);
			return (1);
		}
	}

	return (0);
}

/**
 * We retrive the index of all used file zones
 */
void retrieveIndexesUcac2(const searchZoneUcac2* const mySearchZoneUcac2,int* const indexZoneDecStart,int* const indexZoneDecEnd,
		int* const indexZoneRaStart,int* const indexZoneRaEnd) {

	/* dec start */
	*indexZoneDecStart     = (int)((mySearchZoneUcac2->decStartInMas - DEC_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS_UCAC2AND3);
	if(*indexZoneDecStart  < 0) {
		*indexZoneDecStart = 0;
	}

	/* dec end */
	*indexZoneDecEnd       = (int)((mySearchZoneUcac2->decEndInMas - DEC_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS_UCAC2AND3);
	if(*indexZoneDecEnd   >= INDEX_TABLE_DEC_DIMENSION_UCAC2AND3) {
		*indexZoneDecEnd   = INDEX_TABLE_DEC_DIMENSION_UCAC2AND3 - 1;
	}

	/* ra start */
	*indexZoneRaStart     = (int)((mySearchZoneUcac2->raStartInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS_UCAC2AND3);
	if(*indexZoneDecStart < 0) {
		*indexZoneRaStart = 0;
	}

	/* ra end */
	*indexZoneRaEnd     = (int)((mySearchZoneUcac2->raEndInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS_UCAC2AND3);
	if(*indexZoneRaEnd >= INDEX_TABLE_RA_DIMENSION_UCAC2AND3) {
		*indexZoneRaEnd = INDEX_TABLE_RA_DIMENSION_UCAC2AND3 - 1;
	}
}

/**
 * Read the index file
 */
indexTableUcac** readIndexFileUcac2(const char* pathOfCatalog) {

	int index;
	int numberOfStarsInZone;
	int numberOfStarsInPreviousZones;
	int numberOfAccumulatedStars;
	int decZoneNumber;
	int raZoneNumber;
	int index2;
	double tempDouble;
	char completeFileName[STRING_COMMON_LENGTH];
	char temporaryString[STRING_COMMON_LENGTH];
	char* temporaryPointer;
	indexTableUcac** indexTable;
	FILE* tableStream;

	sprintf(completeFileName,"%s/%s",pathOfCatalog,INDEX_FILE_NAME_UCAC2);

	tableStream = fopen(completeFileName,"rt");
	if(tableStream == NULL) {
		sprintf(outputLogChar,"Error : file %s not found\n",completeFileName);
		return (NULL);
	}

	/* Allocate memory */
	indexTable = (indexTableUcac**)malloc(INDEX_TABLE_DEC_DIMENSION_UCAC2AND3 * sizeof(indexTableUcac*));
	if(indexTable == NULL) {
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		return (NULL);
	}
	for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_UCAC2AND3;index++) {
		indexTable[index] = (indexTableUcac*)malloc(INDEX_TABLE_RA_DIMENSION_UCAC2AND3 * sizeof(indexTableUcac));
		if(indexTable[index] == NULL) {
			sprintf(outputLogChar,"Error : indexTable[%d] out of memory\n",index);
			return (NULL);
		}
	}

	/* Read the header file */
	for(index = 0; index < INDEX_FILE_HEADER_NUMBER_OF_LINES_UCAC2; index++) {
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
		sscanf(temporaryString,FORMAT_INDEX_FILE_UCAC2,&numberOfStarsInZone,&numberOfStarsInPreviousZones,
				&numberOfAccumulatedStars,&decZoneNumber,&raZoneNumber,&tempDouble,&tempDouble);
		indexTable[decZoneNumber - 1][raZoneNumber - 1].numberOfStarsInZone = numberOfStarsInZone;
		indexTable[decZoneNumber - 1][raZoneNumber - 1].idOfFirstStarInZone = numberOfAccumulatedStars - numberOfStarsInZone;
	}

	fclose(tableStream);

	if(DEBUG) {
		for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_UCAC2AND3;index++) {
			for(index2 = 0; index2 < INDEX_TABLE_RA_DIMENSION_UCAC2AND3;index2++) {
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
const searchZoneUcac2 findSearchZoneUcac2(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax) {

	double ratio;
	double tmpValue;
	searchZoneUcac2 mySearchZoneUcac2;
	double radiusInDeg;
	double radiusRa;

	radiusInDeg                                = radiusInArcMin / DEG2ARCMIN;

	mySearchZoneUcac2.decStartInMas            = (int)(DEG2MAS * (decInDeg - radiusInDeg));
	mySearchZoneUcac2.decEndInMas              = (int)(DEG2MAS * (decInDeg + radiusInDeg));
	mySearchZoneUcac2.magnitudeStartInCentiMag = (short)(MAG2CENTIMAG * magMin);
	mySearchZoneUcac2.magnitudeEndInCentiMag   = (short)(MAG2CENTIMAG * magMax);

	if((mySearchZoneUcac2.decStartInMas  <= DEC_SOUTH_POLE_MAS) && (mySearchZoneUcac2.decEndInMas >= DEC_NORTH_POLE_MAS)) {

		mySearchZoneUcac2.decStartInMas   = DEC_SOUTH_POLE_MAS;
		mySearchZoneUcac2.decEndInMas     = DEC_NORTH_POLE_MAS;
		mySearchZoneUcac2.raStartInMas    = START_RA_MAS;
		mySearchZoneUcac2.raEndInMas      = COMPLETE_RA_MAS;
		mySearchZoneUcac2.isArroundZeroRa = 0;

	} else if(mySearchZoneUcac2.decStartInMas <= DEC_SOUTH_POLE_MAS) {

		mySearchZoneUcac2.decStartInMas   = DEC_SOUTH_POLE_MAS;
		mySearchZoneUcac2.raStartInMas    = START_RA_MAS;
		mySearchZoneUcac2.raEndInMas      = COMPLETE_RA_MAS;
		mySearchZoneUcac2.isArroundZeroRa = 0;

	} else if(mySearchZoneUcac2.decEndInMas >= DEC_NORTH_POLE_MAS) {

		mySearchZoneUcac2.decEndInMas     = DEC_NORTH_POLE_MAS;
		mySearchZoneUcac2.raStartInMas    = START_RA_MAS;
		mySearchZoneUcac2.raEndInMas      = COMPLETE_RA_MAS;
		mySearchZoneUcac2.isArroundZeroRa = 0;

	} else {

		radiusRa                     = radiusInDeg / cos(decInDeg * DEC2RAD);

		tmpValue                     = DEG2MAS * (raInDeg  - radiusRa);
		ratio                        = tmpValue / COMPLETE_RA_MAS;
		ratio                        = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                    -= ratio;
		mySearchZoneUcac2.raStartInMas          = (int)tmpValue;

		tmpValue                     = DEG2MAS * (raInDeg  + radiusRa);
		ratio                        = tmpValue / COMPLETE_RA_MAS;
		ratio                        = floor(ratio) * COMPLETE_RA_MAS;
		tmpValue                    -= ratio;
		mySearchZoneUcac2.raEndInMas           = (int)tmpValue;

		mySearchZoneUcac2.isArroundZeroRa      = 0;

		if(mySearchZoneUcac2.raStartInMas      >  mySearchZoneUcac2.raEndInMas) {
			mySearchZoneUcac2.isArroundZeroRa  = 1;
		}
	}

	if(DEBUG) {
		printf("mySearchZoneUcac2.decStart        = %d\n",mySearchZoneUcac2.decStartInMas);
		printf("mySearchZoneUcac2.decEnd          = %d\n",mySearchZoneUcac2.decEndInMas);
		printf("mySearchZoneUcac2.raStart         = %d\n",mySearchZoneUcac2.raStartInMas);
		printf("mySearchZoneUcac2.raEnd           = %d\n",mySearchZoneUcac2.raEndInMas);
		printf("mySearchZoneUcac2.isArroundZeroRa = %d\n",mySearchZoneUcac2.isArroundZeroRa);
		printf("mySearchZoneUcac2.magnitudeStart  = %d\n",mySearchZoneUcac2.magnitudeStartInCentiMag);
		printf("mySearchZoneUcac2.magnitudeEnd    = %d\n",mySearchZoneUcac2.magnitudeEndInCentiMag);
	}

	return (mySearchZoneUcac2);
}

/**
 * Print the un filtered stars
 */
void printUnfilteredStarUcac2(const arrayTwoDOfStarUcac2* const unFilteredStars) {

	arrayOneDOfStarUcac2* arrayTwoD = unFilteredStars->arrayTwoD;
	arrayOneDOfStarUcac2 oneSetOfStar;
	starUcac2 oneStar;
	int indexDec,indexRa;

	printf("The un-filtered stars are :\n");

	for(indexDec = 0; indexDec < unFilteredStars->length; indexDec++) {

		oneSetOfStar = arrayTwoD[indexDec];

		for(indexRa = 0; indexRa < oneSetOfStar.length; indexRa++) {

			oneStar = oneSetOfStar.arrayOneD[indexRa];
			printf("indexDec = %3d - indexRa = %3d : %8.4f %+8.4f %5.2f\n",indexDec,indexRa,oneStar.raInMas/DEG2MAS,
					oneStar.decInMas/DEG2MAS,oneStar.ucacMagInCentiMag/MAG2CENTIMAG);
		}
	}
}
