#include "csucac.h"
/*
 * csucac4.c
 *
 *  Created on: Nov 04, 2012
 *      Author: Y. Damerdji
 */

static char outputLogChar[STRING_COMMON_LENGTH];

int cmd_tcl_csucac4(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int resultOfFunction;
	int idOfStar;
	int counterDec;
	int counterRa;
	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	indexTableUcac** indexTable;
	starUcac4 oneStar;
	searchZoneUcac3And4 mySearchZoneUcac4;
	arrayTwoDOfStarUcac4 unFilteredStars;
	arrayOneDOfStarUcac4 oneSetOfStar;
	starUcac4* allStars;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Define search zone */
	mySearchZoneUcac4 = findSearchZoneUcac3And4(ra,dec,radius,magMin,magMax);

	/* Read the index file */
	indexTable        = readIndexFileUcac4(pathToCatalog);
	if(indexTable == NULL) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Now read the catalog and retrieve stars */
	resultOfFunction = retrieveUnfilteredStarsUcac4(pathToCatalog,&mySearchZoneUcac4,indexTable,&unFilteredStars);
	if(resultOfFunction) {
		releaseDoubleArray((void**)indexTable, INDEX_TABLE_DEC_DIMENSION_UCAC2AND3);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Print the filtered stars */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { UCAC4 { } "
			"{ ID ra_deg dec_deg im1_mag im2_mag sigmag_mag objt dsf "
			"sigra_deg sigdc_deg na1 nu1 us1 cepra_deg cepdc_deg pmrac_masperyear pmdc_masperyear sigpmr_masperyear sigpmd_masperyear "
			"id2m jmag_mag hmag_mag kmag_mag jicqflg hicqflg kicqflg je2mpho he2mpho ke2mpho "
			"apassB_mag apassV_mag apassG_mag apassR_mag apassI_mag apassB_errmag apassV_errmag apassG_errmag apassR_errmag apassI_errmag"
			"catflg1 catflg2 catflg3 catflg4 starId zoneUcac2 idUcac2 } } } ",-1);
	Tcl_DStringAppend(&dsptr,"{",-1); // start of sources list

	for(counterDec = 0; counterDec < unFilteredStars.length; counterDec++) {

		oneSetOfStar  = unFilteredStars.arrayTwoD[counterDec];
		allStars      = oneSetOfStar.arrayOneD;
		idOfStar      = oneSetOfStar.idOfFirstStarInArray;

		for(counterRa = 0; counterRa < oneSetOfStar.length; counterRa++) {

			idOfStar++;
			oneStar   = allStars[counterRa];

			if(isGoodStarUcac4(&oneStar,&mySearchZoneUcac4)) {

				Tcl_DStringAppend(&dsptr,"{ { UCAC4 { } {",-1);

				sprintf(outputLogChar,"%03d-%06d %.8f %+.8f %.3f %.3f %.3f %d %d "
						"%.8f %.8f %d %d %d %.8f %+.8f %+.8f %+.8f %.8f %.8f "
						"%d %.3f %.3f %.3f %d %d %d %.3f %.3f %.3f "
						"%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f "
						"%d %d %d %d %d %d %d",

						oneSetOfStar.indexDec,idOfStar, // the ID %03d-%06d
						(double)oneStar.raInMas/DEG2MAS,
						(double)oneStar.distanceToSouthPoleInMas / DEG2MAS + DEC_SOUTH_POLE_DEG,
						(double)oneStar.ucacFitMagInMilliMag / MAG2MILLIMAG,
						(double)oneStar.ucacApertureMagInMilliMag / MAG2MILLIMAG,
						(double)oneStar.ucacErrorMagInCentiMag / MAG2CENTIMAG,
						oneStar.objectType,
						oneStar.doubleStarFlag,

						(double)oneStar.errorOnUcacRaInMas / DEG2MAS,
						(double)oneStar.errorOnUcacDecInMas / DEG2MAS,
						oneStar.numberOfCcdObservation,
						oneStar.numberOfUsedCcdObservation,
						oneStar.numberOfUsedCatalogsForProperMotion,
						(double)oneStar.centralEpochForMeanRaInCentiMas/ DEG2MAS / 100.,
						(double)oneStar.centralEpochForMeanDecInCentiMas/ DEG2MAS / 100.,
						(double)oneStar.raProperMotionInOneTenthMasPerYear / 10.,
						(double)oneStar.decProperMotionInOneTenthMasPerYear / 10.,
						(double)oneStar.errorOnRaProperMotionInOneTenthMasPerYear / 10.,
						(double)oneStar.errorOnDecProperMotionInOneTenthMasPerYear / 10.,

						oneStar.idFrom2Mass,
						(double)oneStar.jMagnitude2MassInMilliMag / MAG2MILLIMAG,
						(double)oneStar.hMagnitude2MassInMilliMag / MAG2MILLIMAG,
						(double)oneStar.kMagnitude2MassInMilliMag / MAG2MILLIMAG,
						oneStar.qualityFlag2Mass[0],
						oneStar.qualityFlag2Mass[1],
						oneStar.qualityFlag2Mass[2],
						(double)oneStar.errorMagnitude2MassInCentiMag[0] / MAG2CENTIMAG,
						(double)oneStar.errorMagnitude2MassInCentiMag[1] / MAG2CENTIMAG,
						(double)oneStar.errorMagnitude2MassInCentiMag[2] / MAG2CENTIMAG,

						(double)oneStar.magnitudeAPASSInMilliMag[0] / MAG2MILLIMAG,
						(double)oneStar.magnitudeAPASSInMilliMag[1] / MAG2MILLIMAG,
						(double)oneStar.magnitudeAPASSInMilliMag[2] / MAG2MILLIMAG,
						(double)oneStar.magnitudeAPASSInMilliMag[3] / MAG2MILLIMAG,
						(double)oneStar.magnitudeAPASSInMilliMag[4] / MAG2MILLIMAG,
						(double)oneStar.magnitudeErrorAPASSInCentiMag[0] / MAG2CENTIMAG,
						(double)oneStar.magnitudeErrorAPASSInCentiMag[1] / MAG2CENTIMAG,
						(double)oneStar.magnitudeErrorAPASSInCentiMag[2] / MAG2CENTIMAG,
						(double)oneStar.magnitudeErrorAPASSInCentiMag[3] / MAG2CENTIMAG,
						(double)oneStar.magnitudeErrorAPASSInCentiMag[4] / MAG2CENTIMAG,

						oneStar.gFlagYale,
						oneStar.fk6HipparcosTychoSourceFlag,
						oneStar.legaGalaxyMatchFlag,
						oneStar.extendedSource2MassFlag,
						oneStar.starIdentifier,
						oneStar.zoneNumberUcac2,
						oneStar.recordNumberUcac2);

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
	releaseDoubleArray((void**)indexTable, INDEX_TABLE_DEC_DIMENSION_UCAC2AND3);
	releaseMemoryArrayTwoDOfStarUcac4(&unFilteredStars);

	return (TCL_OK);
}

/**
 * Filter the un-filtered stars with respect to restrictions
 */
int isGoodStarUcac4(const starUcac4* const oneStar,const searchZoneUcac3And4* const mySearchZoneUcac4) {

	const searchZoneRaSpdMas* const subSearchZone  = &(mySearchZoneUcac4->subSearchZone);
	const magnitudeBoxMilliMag* const magnitudeBox = &(mySearchZoneUcac4->magnitudeBox);

	if(
			((subSearchZone->isArroundZeroRa && ((oneStar->raInMas >= subSearchZone->raStartInMas) || (oneStar->raInMas <= subSearchZone->raEndInMas))) ||
					(!subSearchZone->isArroundZeroRa && ((oneStar->raInMas >= subSearchZone->raStartInMas) && (oneStar->raInMas <= subSearchZone->raEndInMas)))) &&
					(oneStar->distanceToSouthPoleInMas  >= subSearchZone->spdStartInMas) &&
					(oneStar->distanceToSouthPoleInMas  <= subSearchZone->spdEndInMas) &&
					(oneStar->ucacApertureMagInMilliMag >= magnitudeBox->magnitudeStartInMilliMag) &&
					(oneStar->ucacApertureMagInMilliMag <= magnitudeBox->magnitudeEndInMilliMag)) {

		return (1);
	}

	return (0);
}

/**
 * Retrieve list of stars
 */
int retrieveUnfilteredStarsUcac4(const char* const pathOfCatalog, const searchZoneUcac3And4* const mySearchZoneUcac4,
		indexTableUcac* const * const indexTable, arrayTwoDOfStarUcac4* const unFilteredStars) {

	/* We retrieve the index of all used file zones */
	int indexZoneDecStart,indexZoneDecEnd,indexZoneRaStart,indexZoneRaEnd,resultOfFunction;
	int numberOfDecZones;

	const searchZoneRaSpdMas* const subSearchZone  = &(mySearchZoneUcac4->subSearchZone);

	retrieveIndexesUcac4(mySearchZoneUcac4,&indexZoneDecStart,&indexZoneDecEnd,&indexZoneRaStart,&indexZoneRaEnd);

	numberOfDecZones      = indexZoneDecEnd - indexZoneDecStart + 1;
	/* If ra is around 0, we double the size of the array */
	if(subSearchZone->isArroundZeroRa) {
		numberOfDecZones *= 2;
	}

	unFilteredStars->length        = numberOfDecZones;
	if(numberOfDecZones == 0) {
		sprintf(outputLogChar,"Warn : no stars in the selected zone\n");
		return (1);
	}
	unFilteredStars->arrayTwoD     = (arrayOneDOfStarUcac4*)malloc(numberOfDecZones * sizeof(arrayOneDOfStarUcac4));
	if((*unFilteredStars).arrayTwoD == NULL) {
		sprintf(outputLogChar,"Error : theUnFilteredStars.arrayTwoD out of memory %d arrayOneDOfUcacStar*\n",numberOfDecZones);
		return (1);
	}

	//printf("numberOfDecZones = %d\n",numberOfDecZones);
	/* Now we allocate the memory for each zone */
	resultOfFunction = allocateUnfiltredStarUcac4(unFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, subSearchZone->isArroundZeroRa);
	if(resultOfFunction) {
		return (1);
	}

	/* Now we read the un-filtered stars from the catalog */
	resultOfFunction = readUnfiltredStarUcac4(pathOfCatalog, unFilteredStars, indexTable, indexZoneDecStart, indexZoneDecEnd,
			indexZoneRaStart, indexZoneRaEnd, subSearchZone->isArroundZeroRa);
	if(resultOfFunction) {
		releaseMemoryArrayTwoDOfStarUcac4(unFilteredStars);
		return (1);
	}

	if(DEBUG) {
		printUnfilteredStarUcac4(unFilteredStars);
	}

	return (0);
}

/**
 * Release memory from one arrayTwoDOfUcacStarUcac4
 */
void releaseMemoryArrayTwoDOfStarUcac4(const arrayTwoDOfStarUcac4* const theTwoDArray) {

	arrayOneDOfStarUcac4* arrayTwoD;
	arrayOneDOfStarUcac4 oneSetOfStar;
	starUcac4* allStars;
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
int readUnfiltredStarUcac4(const char* const pathOfCatalog, const arrayTwoDOfStarUcac4* const unFilteredStars, indexTableUcac* const * const indexTable,
		const int indexZoneDecStart,const int indexZoneDecEnd, const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa) {

	int indexDec;
	int resultOfFunction;
	const int lastZoneRa = INDEX_TABLE_RA_DIMENSION_UCAC4 - 1;
	int counterDec       = 0;

	if(isArroundZeroRa) {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac4(pathOfCatalog, &(unFilteredStars->arrayTwoD[counterDec]),
					indexTable[indexDec], indexDec, indexZoneRaStart, lastZoneRa);
			if(resultOfFunction) {
				return (1);
			}

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac4(pathOfCatalog, &(unFilteredStars->arrayTwoD[counterDec]),
					indexTable[indexDec], indexDec, 0, indexZoneRaEnd);

			if(resultOfFunction) {
				return (1);
			}

			counterDec++;
		}

	} else {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to indexZoneRaEnd*/
			resultOfFunction = readUnfiltredStarForOneDecZoneUcac4(pathOfCatalog, &(unFilteredStars->arrayTwoD[counterDec]),
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
int readUnfiltredStarForOneDecZoneUcac4(const char* const pathOfCatalog, arrayOneDOfStarUcac4* const unFilteredStarsForOneDec,
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
	sprintf(completeFileName,ZONE_FILE_FORMAT_NAME_UCAC4,pathOfCatalog,indexDec);

	//printf("completeFileName = %s\n",completeFileName);
	myStream = fopen(completeFileName,"rb");

	if(myStream == NULL) {
		sprintf(outputLogChar,"Error : unable to open file %s\n",completeFileName);
		return (1);
	}

	/* Move to starting position */
	if(fseek(myStream,sumOfStarBefore*sizeof(starUcac4),SEEK_SET) != 0) {
		sprintf(outputLogChar,"Error : when moving inside %s\n",completeFileName);
		fclose(myStream);
		return (1);
	}

	resultOfRead = (int)fread(unFilteredStarsForOneDec->arrayOneD,sizeof(starUcac4),unFilteredStarsForOneDec->length,myStream);

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
int allocateUnfiltredStarUcac4(const arrayTwoDOfStarUcac4* const unFilteredStars, indexTableUcac* const * const indexTable,const int indexZoneDecStart,
		const int indexZoneDecEnd,const int indexZoneRaStart,const int indexZoneRaEnd, const char isArroundZeroRa) {

	int indexDec;
	int resultOfFunction;
	const int lastZoneRa = INDEX_TABLE_RA_DIMENSION_UCAC2AND3 - 1;
	int counterDec       = 0;

	if(isArroundZeroRa) {

		for(indexDec = indexZoneDecStart; indexDec <= indexZoneDecEnd; indexDec++) {

			/* From indexZoneRaStart to lastZoneRa*/
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac4(&(unFilteredStars->arrayTwoD[counterDec]),
					indexTable[indexDec], indexZoneRaStart, lastZoneRa);
			if(resultOfFunction) {
				return (1);
			}

			counterDec++;

			/* From 0 to indexZoneRaEnd*/
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac4(&(unFilteredStars->arrayTwoD[counterDec]),
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
			resultOfFunction = allocateUnfiltredStarForOneDecZoneUcac4(&(unFilteredStars->arrayTwoD[counterDec]),
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
int allocateUnfiltredStarForOneDecZoneUcac4(arrayOneDOfStarUcac4* const unFilteredStarsForOneDec, const indexTableUcac* const indexTableForOneDec,
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
		unFilteredStarsForOneDec->arrayOneD     = (starUcac4*)malloc(sumOfStar * sizeof(starUcac4));
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
void retrieveIndexesUcac4(const searchZoneUcac3And4* const mySearchZoneUcac4,int* const indexZoneDecStart,int* const indexZoneDecEnd,
		int* const indexZoneRaStart,int* const indexZoneRaEnd) {

	const searchZoneRaSpdMas* const subSearchZone  = &(mySearchZoneUcac4->subSearchZone);

	/* dec start */
	*indexZoneDecStart     = (int)((subSearchZone->spdStartInMas - DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS_UCAC4);
	if(*indexZoneDecStart  < 0) {
		*indexZoneDecStart = 0;
	}

	/* dec end */
	*indexZoneDecEnd       = (int)((subSearchZone->spdEndInMas - DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_MAS) / DEC_WIDTH_ZONE_MAS_UCAC4);
	if(*indexZoneDecEnd   >= INDEX_TABLE_DEC_DIMENSION_UCAC4) {
		*indexZoneDecEnd   = INDEX_TABLE_DEC_DIMENSION_UCAC4 - 1;
	}

	/* ra start */
	*indexZoneRaStart     = (int)((subSearchZone->raStartInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS_UCAC4);
	if(*indexZoneDecStart < 0) {
		*indexZoneRaStart = 0;
	}

	/* ra end */
	*indexZoneRaEnd     = (int)((subSearchZone->raEndInMas - START_RA_MAS) / RA_WIDTH_ZONE_MAS_UCAC4);
	if(*indexZoneRaEnd >= INDEX_TABLE_RA_DIMENSION_UCAC4) {
		*indexZoneRaEnd = INDEX_TABLE_RA_DIMENSION_UCAC4 - 1;
	}
}

/**
 * Read the index file
 */
indexTableUcac** readIndexFileUcac4(const char* const pathOfCatalog) {

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

	sprintf(completeFileName,"%s%s",pathOfCatalog,INDEX_FILE_NAME_UCAC4);
	tableStream = fopen(completeFileName,"rt");
	if(tableStream == NULL) {
		sprintf(outputLogChar,"Error : file %s not found\n",completeFileName);
		return (NULL);
	}

	/* Allocate memory */
	indexTable    = (indexTableUcac**)malloc(INDEX_TABLE_DEC_DIMENSION_UCAC4 * sizeof(indexTableUcac*));
	if(indexTable == NULL) {
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		return (NULL);
	}
	for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_UCAC4;index++) {
		indexTable[index] = (indexTableUcac*)malloc(INDEX_TABLE_RA_DIMENSION_UCAC4 * sizeof(indexTableUcac));
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
		sscanf(temporaryString,FORMAT_INDEX_FILE_UCAC3AND4,&numberOfStarsInPreviousZones,&numberOfStars,&decZoneNumber,&raZoneNumber,&tempDouble);
		indexTable[decZoneNumber - 1][raZoneNumber - 1].numberOfStarsInZone = numberOfStars;
		indexTable[decZoneNumber - 1][raZoneNumber - 1].idOfFirstStarInZone = numberOfStarsInPreviousZones;
	}

	fclose(tableStream);

	if(DEBUG) {
		for(index = 0; index < INDEX_TABLE_DEC_DIMENSION_UCAC4;index++) {
			for(index2 = 0; index2 < INDEX_TABLE_RA_DIMENSION_UCAC4;index2++) {
				printf("indexTable[%3d][%3d] = %d\n",index,index2,indexTable[index][index2].numberOfStarsInZone);
			}
		}
	}

	return (indexTable);
}

/**
 * Print the un filtered stars
 */
void printUnfilteredStarUcac4(const arrayTwoDOfStarUcac4* const unFilteredStars) {

	arrayOneDOfStarUcac4* arrayTwoD;
	arrayOneDOfStarUcac4 oneSetOfStar;
	starUcac4 oneStar;
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
