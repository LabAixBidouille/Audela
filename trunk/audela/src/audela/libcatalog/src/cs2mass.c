#include "cs2mass.h"
/*
 * cs2mass.c
 *
 *  Created on: Nov 05, 2012
 *      Author: Y. Damerdji
 */

static char outputLogChar[1024];

int cmd_tcl_cs2mass(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char* pathToCatalog;
	double ra;
	double dec;
	double radius;
	double magMin;
	double magMax;
	int maximumNumberOfStars = 0;
	int indexOfRA;
	int indexOfCatalog;
	char shortName[1024];
	char fileName[1024];
	FILE* inputStream;
	searchZone2Mass mySearchZone2Mass;
	star2Mass* arrayOfStars;
	const indexTable2Mass* allAccFiles;
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
	mySearchZone2Mass = findSearchZone2Mass(ra,dec,radius,magMin,magMax);

	/* Read all catalog files to be able to deliver an ID for each star */
	allAccFiles        = readIndexFile2Mass(pathToCatalog,&mySearchZone2Mass,&maximumNumberOfStars);
	if(allAccFiles == NULL) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}
	if(maximumNumberOfStars <= 0) {
		sprintf(outputLogChar,"maximumNumberOfStars = %d should be > 0\n",maximumNumberOfStars);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Allocate memory for an array in which we put the read stars */
	arrayOfStars     = (star2Mass*)malloc(maximumNumberOfStars * sizeof(star2Mass));
	if(arrayOfStars == NULL) {
		sprintf(outputLogChar,"arrayOfStars = %d (star2Mass) out of memory\n",maximumNumberOfStars);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { 2Mass { } { ID ra_deg dec_deg err_ra err_dec jMag jMagError hMag hMagError kMag kMagError jd } } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	for(indexOfCatalog = mySearchZone2Mass.indexOfFirstDecZone; indexOfCatalog <= mySearchZone2Mass.indexOfLastDecZone; indexOfCatalog++) {

		/* Open the CAT file (.acc) */
		sprintf(shortName,CATALOG_NAME_FORMAT,allAccFiles[indexOfCatalog].prefix,allAccFiles[indexOfCatalog].indexOfCatalog);
		sprintf(fileName,"%s%s%s",pathToCatalog,shortName,DOT_CAT_EXTENSION);

		inputStream = fopen(fileName,"rb");
		if(inputStream == NULL) {
			sprintf(outputLogChar,"%s not found\n",fileName);
			Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
			return (TCL_ERROR);
		}

		if(mySearchZone2Mass.isArroundZeroRa) {

			for(indexOfRA = mySearchZone2Mass.indexOfFirstRightAscensionZone; indexOfRA < ACC_FILE_NUMBER_OF_LINES; indexOfRA++) {

				if(processOneZone2MassCentredOnZeroRA(&dsptr,inputStream,&(allAccFiles[indexOfCatalog]),
						arrayOfStars,&mySearchZone2Mass,indexOfCatalog,indexOfRA)) {
					Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
					return (TCL_ERROR);
				}
			}

			for(indexOfRA = 0; indexOfRA <= mySearchZone2Mass.indexOfLastRightAscensionZone; indexOfRA++) {

				if(processOneZone2MassCentredOnZeroRA(&dsptr,inputStream,&(allAccFiles[indexOfCatalog]),
						arrayOfStars,&mySearchZone2Mass,indexOfCatalog,indexOfRA)) {
					Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
					return (TCL_ERROR);
				}
			}

		} else {

			for(indexOfRA = mySearchZone2Mass.indexOfFirstRightAscensionZone; indexOfRA <= mySearchZone2Mass.indexOfLastRightAscensionZone; indexOfRA++) {

				if(processOneZone2MassNotCentredOnZeroRA(&dsptr,inputStream,&(allAccFiles[indexOfCatalog]),
						arrayOfStars,&mySearchZone2Mass,indexOfCatalog,indexOfRA)) {
					Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
					return (TCL_ERROR);
				}
			}
		}

		fclose(inputStream);
	}

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	/* Release memory */
	freeAll2MassCatalogFiles(allAccFiles,&mySearchZone2Mass);
	releaseSimpleArray(arrayOfStars);

	return (TCL_OK);
}

/****************************************************************************/
/* Process one RA-DEC zone centered on zero ra                              */
/****************************************************************************/
int processOneZone2MassCentredOnZeroRA(Tcl_DString* const dsptr, FILE* const inputStream,const indexTable2Mass* const oneAccFile,
		star2Mass* const arrayOfStars,const searchZone2Mass* const mySearchZone2Mass, const int indexOfCatalog, const int indexOfRA) {

	unsigned int indexOfStar;
	star2Mass theStar;
	char tclString[STRING_COMMON_LENGTH];

	/* Move to this position */
	fseek(inputStream,oneAccFile->idOfFirstStarInZone[indexOfRA] * sizeof(star2Mass),SEEK_SET);
	/* Read the amount of stars */
	if(fread(arrayOfStars,sizeof(star2Mass),oneAccFile->numberOfStarsInZone[indexOfRA],inputStream) !=  oneAccFile->numberOfStarsInZone[indexOfRA]) {
		sprintf(outputLogChar,"can not read %d (star2Mass)\n",oneAccFile->numberOfStarsInZone[indexOfRA]);
		return (1);
	}

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile->numberOfStarsInZone[indexOfRA]; indexOfStar++) {

		theStar  = arrayOfStars[indexOfStar];

		if ((theStar.raInMicroDegree < mySearchZone2Mass->raStartInMicroDegree) && (theStar.raInMicroDegree > mySearchZone2Mass->raEndInMicroDegree)) {
			continue;
		}

		if ((theStar.decInMicroDegree < mySearchZone2Mass->decStartInMicroDegree) || (theStar.decInMicroDegree > mySearchZone2Mass->decEndInMicroDegree)) {
			continue;
		}

		if((theStar.jMagInMilliMag < mySearchZone2Mass->magnitudeStartInMilliMag) || (theStar.jMagInMilliMag > mySearchZone2Mass->magnitudeEndInMilliMag)) {
			continue;
		}

		printStar(&theStar,tclString);

		Tcl_DStringAppend(dsptr,tclString,-1);
	}

	return (0);
}

/****************************************************************************/
/* Process one RA-DEC zone not centered on zero ra                           */
/****************************************************************************/
int processOneZone2MassNotCentredOnZeroRA(Tcl_DString* const dsptr, FILE* const inputStream,const indexTable2Mass* const oneAccFile,
		star2Mass* const arrayOfStars,const searchZone2Mass* const mySearchZone2Mass, const int indexOfCatalog, const int indexOfRA) {

	unsigned int indexOfStar;
	star2Mass theStar;
	char tclString[STRING_COMMON_LENGTH];

	/* Move to this position */
	fseek(inputStream,oneAccFile->idOfFirstStarInZone[indexOfRA] * sizeof(star2Mass),SEEK_SET);
	/* Read the amount of stars */
	if(fread(arrayOfStars,sizeof(star2Mass),oneAccFile->numberOfStarsInZone[indexOfRA],inputStream) !=  oneAccFile->numberOfStarsInZone[indexOfRA]) {
		sprintf(outputLogChar,"can not read %d (star2Mass)\n",oneAccFile->numberOfStarsInZone[indexOfRA]);
		return (1);
	}

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile->numberOfStarsInZone[indexOfRA]; indexOfStar++) {

		theStar  = arrayOfStars[indexOfStar];

		if ((theStar.raInMicroDegree < mySearchZone2Mass->raStartInMicroDegree) || (theStar.raInMicroDegree > mySearchZone2Mass->raEndInMicroDegree)) {
			continue;
		}

		if ((theStar.decInMicroDegree < mySearchZone2Mass->decStartInMicroDegree) || (theStar.decInMicroDegree > mySearchZone2Mass->decEndInMicroDegree)) {
			continue;
		}

		if((theStar.jMagInMilliMag < mySearchZone2Mass->magnitudeStartInMilliMag) || (theStar.jMagInMilliMag > mySearchZone2Mass->magnitudeEndInMilliMag)) {
			continue;
		}

		printStar(&theStar,tclString);

		Tcl_DStringAppend(dsptr,tclString,-1);
	}

	return (0);
}

/**
 * Print one star to append it in the output TCL string
 */
void printStar(const star2Mass* const theStar, char* const tclString) {

	char sign;
	char theId[17];
	int raHour,raMinute,raSeconds;
	double raInDegDouble,raHourDouble,raMinuteDouble,raSecondsDouble;
	int decDegree,decMinute,decSeconds;
	double decInDegDouble,absDecInDegDouble,decMinuteDouble,decSecondsDouble;
	double jMagnitude,hMagnitude,kMagnitude;
	double jMagnitudeError,hMagnitudeError,kMagnitudeError;
	double jd;
	double errorRa,errorDec;

	raInDegDouble      = (double)theStar->raInMicroDegree  / DEG2MICRODEG;
	decInDegDouble     = (double)theStar->decInMicroDegree / DEG2MICRODEG;
	jMagnitude         = (double)theStar->jMagInMilliMag / MAG2MILLIMAG;
	hMagnitude         = (double)theStar->hMagInMilliMag / MAG2MILLIMAG;
	kMagnitude         = (double)theStar->kMagInMilliMag / MAG2MILLIMAG;
	jMagnitudeError    = (double)theStar->jErrorMagInCentiMag / MAG2CENTIMAG;
	hMagnitudeError    = (double)theStar->hErrorMagInCentiMag / MAG2CENTIMAG;
	kMagnitudeError    = (double)theStar->kErrorMagInCentiMag / MAG2CENTIMAG;
	jd                 = (double)theStar->jd / 1.e4 + 2451.0e3;

	raHourDouble       = raInDegDouble / HOUR2DEG;
	raHour             = (int) raHourDouble;
	raMinuteDouble     = (raHourDouble - raHour) * DEG2ARCMIN;
	raMinute           = (int) raMinuteDouble;
	raSecondsDouble    = (raMinuteDouble - raMinute) * DEG2ARCMIN;
	raSeconds          = (int) round(100. * raSecondsDouble);

	absDecInDegDouble  = fabs(decInDegDouble);
	decDegree          = (int) absDecInDegDouble;
	decMinuteDouble    = (absDecInDegDouble - decDegree) * DEG2ARCMIN;
	decMinute          = (int) decMinuteDouble;
	decSecondsDouble   = (decMinuteDouble - decMinute) * DEG2ARCMIN;
	decSeconds         = (int) round(10. * decSecondsDouble);

	sign               = '+';
	if(decInDegDouble  < 0.) {
		sign           = '-';
	}

	errorDec           = (double)(theStar->errorOnCoordinates % 100) /100.;
	errorRa            = ((double)theStar->errorOnCoordinates - errorDec) / 10000.;

	sprintf(theId,OUTPUT_ID_FORMAT,raHour,raMinute,raSeconds,sign,decDegree,decMinute,decSeconds);

	sprintf(tclString,"{ { 2Mass { } {%s %.8f %.8f %.6f %.6f %.2f %.2f %.2f %.2f %.2f %.2f %.6f} } } ",
			theId,raInDegDouble,decInDegDouble,errorRa,errorDec,jMagnitude,jMagnitudeError,hMagnitude,hMagnitudeError,
			kMagnitude,kMagnitudeError,jd);
}

/****************************************************************************/
/* Free the all ACC files array */
/****************************************************************************/
void freeAll2MassCatalogFiles(const indexTable2Mass* const allAccFiles, const searchZone2Mass* const mySearchZone) {

	int indexOfFile;

	if(allAccFiles != NULL) {

		for(indexOfFile = mySearchZone->indexOfFirstDecZone;
				indexOfFile <= mySearchZone->indexOfLastDecZone;indexOfFile++) {

			releaseSimpleArray((void*)(allAccFiles[indexOfFile].idOfFirstStarInZone));
			releaseSimpleArray((void*)(allAccFiles[indexOfFile].numberOfStarsInZone));
		}
	}

	releaseSimpleArray((void*)allAccFiles);
}

/**
 * Read the index file
 */
const indexTable2Mass* readIndexFile2Mass(const char* const pathOfCatalog, const searchZone2Mass* const mySearchZone2Mass, int* const maximumNumberOfStars) {

	char completeFileName[STRING_COMMON_LENGTH];
	char shortName[STRING_COMMON_LENGTH];
	char oneLine[STRING_COMMON_LENGTH];
	int indexOfFile;
	int indexOfLine;
	/* .acc are badly filled: when numberOfStarsInZone = 0, the fields indexInFile
	 * and totalNumberOfStars do not exist, so sscanf does not change them
	 * In this case indexInFile will be equal to 0 (0 is the value of numberOfStarsInZone)
	 * THIS IS THE BEHAVIOUR UNDER LINUX : NOT SURE TO BE THE SAME UNDER OTHER OSs
	 * So : we initialise totalNumberOfStars to 0 and indexInFile to -1 (indexInFile is not used hereafter)*/
	int indexInFile         = -1;
	int totalNumberOfStars  = 0;
	int numberOfStarsInZone = 0;
	int raZoneNumber;
	int raZoneNumberPlusOne;
	indexTable2Mass* indexTable;
	FILE* inputStream;

	/* Allocate memory */
	indexTable    = (indexTable2Mass*)malloc(NUMBER_OF_CATALOG_FILES_2MASS * sizeof(indexTable2Mass));
	if(indexTable == NULL) {
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		return (NULL);
	}

	for(indexOfFile = mySearchZone2Mass->indexOfFirstDecZone;
			indexOfFile <= mySearchZone2Mass->indexOfLastDecZone;indexOfFile++) {

		if(indexOfFile         >= HALF_NUMBER_OF_CATALOG_FILES_2MASS) {
			/* North hemisphere */
			indexTable[indexOfFile].indexOfCatalog = indexOfFile - HALF_NUMBER_OF_CATALOG_FILES_2MASS;
			indexTable[indexOfFile].prefix         = NORTH_HEMISPHERE_PREFIX;
		} else {
			/* South hemisphere */
			indexTable[indexOfFile].indexOfCatalog = HALF_NUMBER_OF_CATALOG_FILES_2MASS_MINUS_ONE - indexOfFile;
			indexTable[indexOfFile].prefix         = SOUTH_HEMISPHERE_PREFIX;
		}

		/* Allocate memory for internal tables */
		indexTable[indexOfFile].idOfFirstStarInZone = (unsigned int*)malloc(ACC_FILE_NUMBER_OF_LINES* sizeof(unsigned int));
		if(indexTable[indexOfFile].idOfFirstStarInZone == NULL) {
			sprintf(outputLogChar,"indexTable[%d].idOfFirstStarInZone = %d (int) out of memory\n",indexOfFile,ACC_FILE_NUMBER_OF_LINES);
			return (NULL);
		}
		indexTable[indexOfFile].numberOfStarsInZone = (unsigned int*)malloc(ACC_FILE_NUMBER_OF_LINES* sizeof(unsigned int));
		if(indexTable[indexOfFile].numberOfStarsInZone == NULL) {
			sprintf(outputLogChar,"indexTable[%d].numberOfStarsInZone = %d (int) out of memory\n",indexOfFile,ACC_FILE_NUMBER_OF_LINES);
			return (NULL);
		}

		/* The first and last accelerator files are empty (m000TMASS.acc and p899TMASS.acc) */
		if((indexTable[indexOfFile].prefix == SOUTH_HEMISPHERE_PREFIX) && (indexTable[indexOfFile].indexOfCatalog == 0)) {

			for(indexOfLine = 0; indexOfLine < ACC_FILE_NUMBER_OF_LINES; indexOfLine++) {

				indexTable[indexOfFile].idOfFirstStarInZone[indexOfLine] = 0;
				indexTable[indexOfFile].numberOfStarsInZone[indexOfLine] = NUMBER_OF_STARS_IN_M000;
			}

			if(*maximumNumberOfStars  < NUMBER_OF_STARS_IN_M000) {
				*maximumNumberOfStars = NUMBER_OF_STARS_IN_M000;
			}

		} else if ((indexTable[indexOfFile].prefix == NORTH_HEMISPHERE_PREFIX) &&
				(indexTable[indexOfFile].indexOfCatalog == HALF_NUMBER_OF_CATALOG_FILES_2MASS_MINUS_ONE)) {

			for(indexOfLine = 0; indexOfLine < ACC_FILE_NUMBER_OF_LINES; indexOfLine++) {

				indexTable[indexOfFile].idOfFirstStarInZone[indexOfLine] = 0;
				indexTable[indexOfFile].numberOfStarsInZone[indexOfLine] = NUMBER_OF_STARS_IN_P899;
			}

			if(*maximumNumberOfStars  < NUMBER_OF_STARS_IN_P899) {
				*maximumNumberOfStars = NUMBER_OF_STARS_IN_P899;
			}

		} else {

			/* Open the catalog ACC files */
			sprintf(shortName,CATALOG_NAME_FORMAT,indexTable[indexOfFile].prefix,indexTable[indexOfFile].indexOfCatalog);
			sprintf(completeFileName,"%s%s%s",pathOfCatalog,shortName,DOT_ACC_EXTENSION);
			inputStream = fopen(completeFileName,"rt");
			if(inputStream == NULL) {
				sprintf(outputLogChar,"%s not found\n",completeFileName);
				return (NULL);
			}

			/* Read the catalog ACC files */
			for(indexOfLine = 0; indexOfLine < ACC_FILE_NUMBER_OF_LINES; indexOfLine++) {
				if ( fgets (oneLine, STRING_COMMON_LENGTH, inputStream) == NULL ) {
					sprintf(outputLogChar,"%s : can not read the %d th line\n",completeFileName,indexOfLine);
					return (NULL);
				} else {
					sscanf(oneLine,FORMAT_ACC,&raZoneNumber,&raZoneNumberPlusOne,&indexInFile,&totalNumberOfStars,&numberOfStarsInZone);

					if(raZoneNumber != indexOfLine) {
						sprintf(outputLogChar,"%s : error in Ra zone in the %d th line\n",completeFileName,indexOfLine);
						return (NULL);
					}

					/* .acc are badly filled: when numberOfStarsInZone = 0, the fields indexInFile
					 * and totalNumberOfStars do not exist, so sscanf does not change them
					 * In this case indexInFile will be equal to 0 (0 is the value of numberOfStarsInZone) :
					 * THIS IS THE BEHAVIOUR UNDER LINUX : NOT SURE TO BE THE SAME UNDER OTHER OSs*/
					if(indexInFile == 0) {
						indexTable[indexOfFile].idOfFirstStarInZone[indexOfLine] = totalNumberOfStars;
						indexTable[indexOfFile].numberOfStarsInZone[indexOfLine] = 0;
					} else {
						indexTable[indexOfFile].idOfFirstStarInZone[indexOfLine] = totalNumberOfStars - numberOfStarsInZone;
						indexTable[indexOfFile].numberOfStarsInZone[indexOfLine] = numberOfStarsInZone;
					}

					if(*maximumNumberOfStars  < numberOfStarsInZone) {
						*maximumNumberOfStars = numberOfStarsInZone;
					}
				}
			}

			fclose(inputStream);
		}
	}

	return (indexTable);
}

/**
 * Find the search zone having its center on (ra,dec) with a radius of radius
 *
 */
const searchZone2Mass findSearchZone2Mass(const double raInDeg,const double decInDeg,
		const double radiusInArcMin,const double magMin, const double magMax) {

	searchZone2Mass mySearchZone2Mass;
	const double radiusInDeg                   = radiusInArcMin / DEG2ARCMIN;
	double ratio;
	double tmpValue;
	double radiusRa;
	const double catalogDistanceToPoleWidthInMicroDegree = DEG2MICRODEG * CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DEGREE;
	const int decNorthPoleInMicroDegree                  = (int) (DEG2MICRODEG * DEC_NORTH_POLE_DEG);
	const int decSouthPoleInMicroDegree                  = (int) (DEG2MICRODEG * DEC_SOUTH_POLE_DEG);
	const double accFileRaZoneWidthInMicroDegree         = DEG2MICRODEG * ACC_FILE_RA_ZONE_WIDTH_IN_DEGREE;

	mySearchZone2Mass.decStartInMicroDegree    = (int)(DEG2MICRODEG * (decInDeg - radiusInDeg));
	mySearchZone2Mass.decEndInMicroDegree      = (int)(DEG2MICRODEG * (decInDeg + radiusInDeg));
	mySearchZone2Mass.magnitudeStartInMilliMag = (int)(MAG2MILLIMAG * magMin);
	mySearchZone2Mass.magnitudeEndInMilliMag   = (int)(MAG2MILLIMAG * magMax);

	if((mySearchZone2Mass.decStartInMicroDegree  <= decSouthPoleInMicroDegree) &&
			(mySearchZone2Mass.decEndInMicroDegree >= decNorthPoleInMicroDegree)) {

		mySearchZone2Mass.decStartInMicroDegree      = decSouthPoleInMicroDegree;
		mySearchZone2Mass.decEndInMicroDegree        = decNorthPoleInMicroDegree;
		mySearchZone2Mass.raStartInMicroDegree       = (int) (DEG2MICRODEG * START_RA_DEG);
		mySearchZone2Mass.raEndInMicroDegree         = (int) (DEG2MICRODEG * COMPLETE_RA_DEG);
		mySearchZone2Mass.isArroundZeroRa            = 0;

	} else if(mySearchZone2Mass.decStartInMicroDegree <= decSouthPoleInMicroDegree) {

		mySearchZone2Mass.decStartInMicroDegree      = decSouthPoleInMicroDegree;
		mySearchZone2Mass.raStartInMicroDegree       = (int) (DEG2MICRODEG * START_RA_DEG);
		mySearchZone2Mass.raEndInMicroDegree         = (int) (DEG2MICRODEG * COMPLETE_RA_DEG);
		mySearchZone2Mass.isArroundZeroRa            = 0;

	} else if(mySearchZone2Mass.decEndInMicroDegree >= decNorthPoleInMicroDegree) {

		mySearchZone2Mass.decEndInMicroDegree        = decNorthPoleInMicroDegree;
		mySearchZone2Mass.raStartInMicroDegree       = (int) (DEG2MICRODEG * START_RA_DEG);
		mySearchZone2Mass.raEndInMicroDegree         = (int) (DEG2MICRODEG * COMPLETE_RA_DEG);
		mySearchZone2Mass.isArroundZeroRa            = 0;

	} else {

		radiusRa                                = radiusInDeg / cos(decInDeg * DEC2RAD);
		tmpValue                                = raInDeg  - radiusRa;
		ratio                                   = tmpValue / COMPLETE_RA_DEG;
		ratio                                   = floor(ratio) * COMPLETE_RA_DEG;
		tmpValue                               -= ratio;
		mySearchZone2Mass.raStartInMicroDegree  = (int)floor(DEG2MICRODEG * tmpValue);

		tmpValue                                = raInDeg  + radiusRa;
		ratio                                   = tmpValue / COMPLETE_RA_DEG;
		ratio                                   = floor(ratio) * COMPLETE_RA_DEG;
		tmpValue                               -= ratio;
		mySearchZone2Mass.raEndInMicroDegree    = (int)ceil(DEG2MICRODEG * tmpValue);

		mySearchZone2Mass.isArroundZeroRa       = 0;

		if(mySearchZone2Mass.raStartInMicroDegree >  mySearchZone2Mass.raEndInMicroDegree) {
			mySearchZone2Mass.isArroundZeroRa     = 1;
		}
	}

	mySearchZone2Mass.indexOfFirstDecZone = (int) ((mySearchZone2Mass.decStartInMicroDegree - decSouthPoleInMicroDegree) / catalogDistanceToPoleWidthInMicroDegree);
	mySearchZone2Mass.indexOfLastDecZone  = (int) ((mySearchZone2Mass.decEndInMicroDegree   - decSouthPoleInMicroDegree) / catalogDistanceToPoleWidthInMicroDegree);

	if(mySearchZone2Mass.indexOfFirstDecZone >= NUMBER_OF_CATALOG_FILES_2MASS) {
		mySearchZone2Mass.indexOfFirstDecZone = NUMBER_OF_CATALOG_FILES_2MASS - 1;
	}
	if(mySearchZone2Mass.indexOfLastDecZone  >= NUMBER_OF_CATALOG_FILES_2MASS) {
		mySearchZone2Mass.indexOfLastDecZone  = NUMBER_OF_CATALOG_FILES_2MASS - 1;
	}

	mySearchZone2Mass.indexOfFirstRightAscensionZone = (int)(mySearchZone2Mass.raStartInMicroDegree / accFileRaZoneWidthInMicroDegree);
	mySearchZone2Mass.indexOfLastRightAscensionZone  = (int)(mySearchZone2Mass.raEndInMicroDegree   / accFileRaZoneWidthInMicroDegree);

	if(DEBUG) {
		printf("mySearchZoneUcac3.decStart        = %d\n",mySearchZone2Mass.decStartInMicroDegree);
		printf("mySearchZoneUcac3.spdEnd          = %d\n",mySearchZone2Mass.decEndInMicroDegree);
		printf("mySearchZoneUcac3.raStart         = %d\n",mySearchZone2Mass.raStartInMicroDegree);
		printf("mySearchZoneUcac3.raEnd           = %d\n",mySearchZone2Mass.raEndInMicroDegree);
		printf("mySearchZoneUcac3.isArroundZeroRa = %d\n",mySearchZone2Mass.isArroundZeroRa);
		printf("mySearchZoneUcac3.magnitudeStart  = %d\n",mySearchZone2Mass.magnitudeStartInMilliMag);
		printf("mySearchZoneUcac3.magnitudeEnd    = %d\n",mySearchZone2Mass.magnitudeEndInMilliMag);
	}

	return (mySearchZone2Mass);
}
