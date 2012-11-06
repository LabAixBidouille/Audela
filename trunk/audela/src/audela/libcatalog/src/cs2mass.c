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
	Tcl_DStringAppend(&dsptr,"{ { 2Mass { } { ID ra_deg dec_deg sign qflag field magB magR } } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	for(indexOfCatalog = mySearchZone2Mass.indexOfFirstDecZone; indexOfCatalog <= mySearchZone2Mass.indexOfLastDecZone; indexOfCatalog++) {

		/* Open the CAT file (.acc) */
		sprintf(shortName,CATALOG_NAME_FORMAT,indexOfCatalog);
		sprintf(fileName,"%s%s%s",pathToCatalog,shortName,DOT_CAT_EXTENSION);

		inputStream = fopen(fileName,"rb");
		if(inputStream == NULL) {
			sprintf(outputLogChar,"%s not found\n",fileName);
			Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
			return (TCL_ERROR);
		}

		if(mySearchZone2Mass.isArroundZeroRa) {

			for(indexOfRA = mySearchZone2Mass.indexOfFirstRightAscensionZone; indexOfRA < ACC_FILE_NUMBER_OF_LINES; indexOfRA++) {

				if(processOneZoneCentredOnZeroRA(&dsptr,inputStream,&(allAccFiles[indexOfCatalog]),
						arrayOfStars,&mySearchZone2Mass,indexOfCatalog,indexOfRA)) {
					Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
					return (TCL_ERROR);
				}
			}

			for(indexOfRA = 0; indexOfRA <= mySearchZone2Mass.indexOfLastRightAscensionZone; indexOfRA++) {

				if(processOneZoneCentredOnZeroRA(&dsptr,inputStream,&(allAccFiles[indexOfCatalog]),
						arrayOfStars,&mySearchZone2Mass,indexOfCatalog,indexOfRA)) {
					Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
					return (TCL_ERROR);
				}
			}

		} else {

			for(indexOfRA = mySearchZone2Mass.indexOfFirstRightAscensionZone; indexOfRA <= mySearchZone2Mass.indexOfLastRightAscensionZone; indexOfRA++) {

				if(processOneZoneNotCentredOnZeroRA(&dsptr,inputStream,&(allAccFiles[indexOfCatalog]),
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
	freeAllCatalogFiles(allAccFiles,&mySearchZone2Mass);
	releaseSimpleArray(arrayOfStars);

	return (TCL_OK);
}

/****************************************************************************/
/* Process one RA-DEC zone centered on zero ra                              */
/****************************************************************************/
int processOneZoneCentredOnZeroRA(Tcl_DString* const dsptr, FILE* const inputStream,const indexTable2Mass* const oneAccFile,
		star2Mass* const arrayOfStars,const searchZone2Mass* const mySearchZone2Mass, const int indexOfCatalog, const int indexOfRA) {

	int position;
	int zoneId;
	char theId[14];
	int theSign,qflag,field;
	int raInCas;
	unsigned int indexOfStar;
	double raInDeg;
	double decInDeg;
	int spdInCas;
	int magnitudes;
	double redMagnitudeInDeciMag;
	double redMagnitudeInMag;
	double blueMagnitudeInMag;
	star2Mass theStar;
	char tclString[1024];

	/* Move to this position */
	fseek(inputStream,oneAccFile->arrayOfPosition[indexOfRA] * sizeof(star2Mass),SEEK_SET);
	/* Read the amount of stars */
	if(fread(arrayOfStars,sizeof(star2Mass),oneAccFile->numberOfStars[indexOfRA],inputStream) !=  oneAccFile->numberOfStars[indexOfRA]) {
		sprintf(outputLogChar,"can not read %d (star2Mass)\n",oneAccFile->numberOfStars[indexOfRA]);
		return (1);
	}

	position = oneAccFile->arrayOfPosition[indexOfRA];
	zoneId   = indexOfCatalog * CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DECI_DEGREE;

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile->numberOfStars[indexOfRA]; indexOfStar++) {

		theStar  = arrayOfStars[indexOfStar];
		raInCas  = 2MassBig2LittleEndianLong(theStar.ra);
		position++;

		if ((raInCas < mySearchZone2Mass->raStartInCas) && (raInCas > mySearchZone2Mass->raEndInCas)) {
			continue;
		}

		spdInCas   = 2MassBig2LittleEndianLong(theStar.spd);

		if ((spdInCas < mySearchZone2Mass->distanceToPoleStartInCas) || (spdInCas > mySearchZone2Mass->distanceToPoleEndInCas)) {
			continue;
		}
		magnitudes             = 2MassBig2LittleEndianLong(theStar.mags);
		redMagnitudeInDeciMag  = 2MassGet2MassRedMagnitudeInDeciMag(magnitudes);
		if((redMagnitudeInDeciMag < mySearchZone2Mass->magnitudeStartInDeciMag) || (redMagnitudeInDeciMag > mySearchZone2Mass->magnitudeEndInDeciMag)) {
			continue;
		}

		raInDeg            = (double)raInCas / DEG2CAS;
		decInDeg           = (double)spdInCas / DEG2CAS + DEC_SOUTH_POLE_DEG;
		redMagnitudeInMag  = (double)redMagnitudeInDeciMag / MAG2DECIMAG;
		blueMagnitudeInMag = (double)2MassGet2MassBleueMagnitudeInDeciMag(magnitudes) / MAG2DECIMAG;
		theSign            = 2MassGet2MassSign(magnitudes);
		qflag              = 2MassGet2MassQflag(magnitudes);
		field              = 2MassGet2MassField(magnitudes);
		sprintf(theId,OUTPUT_ID_FORMAT,zoneId,position);

		sprintf(tclString,"{ { 2Mass { } {%s %f %f %d %d %d %.2f %.2f} } } ",theId,raInDeg,decInDeg,theSign,qflag,field,blueMagnitudeInMag,redMagnitudeInMag);
		Tcl_DStringAppend(dsptr,tclString,-1);
	}

	return (0);
}

/****************************************************************************/
/* Process one RA-DEC zone not centered on zero ra                           */
/****************************************************************************/
int processOneZoneNotCentredOnZeroRA(Tcl_DString* const dsptr, FILE* const inputStream,const indexTable2Mass* const oneAccFile,
		star2Mass* const arrayOfStars,const searchZone2Mass* const mySearchZone2Mass, const int indexOfCatalog, const int indexOfRA) {

	int position;
	int zoneId;
	char theId[14];
	int theSign,qflag,field;
	int raInCas;
	unsigned int indexOfStar;
	double raInDeg;
	double decInDeg;
	int spdInCas;
	int magnitudes;
	double redMagnitudeInDeciMag;
	double redMagnitudeInMag;
	double blueMagnitudeInMag;
	star2Mass theStar;
	char tclString[1024];

	/* Move to this position */
	fseek(inputStream,oneAccFile->arrayOfPosition[indexOfRA] * sizeof(star2Mass),SEEK_SET);
	/* Read the amount of stars */
	if(fread(arrayOfStars,sizeof(star2Mass),oneAccFile->numberOfStars[indexOfRA],inputStream) !=  oneAccFile->numberOfStars[indexOfRA]) {
		sprintf(outputLogChar,"can not read %d (star2Mass)\n",oneAccFile->numberOfStars[indexOfRA]);
		return (1);
	}

	position = oneAccFile->arrayOfPosition[indexOfRA];
	zoneId   = indexOfCatalog * CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DECI_DEGREE;

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile->numberOfStars[indexOfRA]; indexOfStar++) {

		theStar  = arrayOfStars[indexOfStar];
		raInCas  = 2MassBig2LittleEndianLong(theStar.ra);
		position++;

		if ((raInCas < mySearchZone2Mass->raStartInCas) || (raInCas > mySearchZone2Mass->raEndInCas)) {
			continue;
		}

		spdInCas = 2MassBig2LittleEndianLong(theStar.spd);

		if ((spdInCas < mySearchZone2Mass->distanceToPoleStartInCas) || (spdInCas > mySearchZone2Mass->distanceToPoleEndInCas)) {
			continue;
		}
		magnitudes             = 2MassBig2LittleEndianLong(theStar.mags);
		redMagnitudeInDeciMag  = 2MassGet2MassRedMagnitudeInDeciMag(magnitudes);
		if((redMagnitudeInDeciMag < mySearchZone2Mass->magnitudeStartInDeciMag) || (redMagnitudeInDeciMag > mySearchZone2Mass->magnitudeEndInDeciMag)) {
			continue;
		}

		raInDeg            = (double)raInCas / DEG2CAS;
		decInDeg           = (double)spdInCas / DEG2CAS + DEC_SOUTH_POLE_DEG;
		redMagnitudeInMag  = (double)redMagnitudeInDeciMag / MAG2DECIMAG;
		blueMagnitudeInMag = (double)2MassGet2MassBleueMagnitudeInDeciMag(magnitudes) / MAG2DECIMAG;
		theSign            = 2MassGet2MassSign(magnitudes);
		qflag              = 2MassGet2MassQflag(magnitudes);
		field              = 2MassGet2MassField(magnitudes);
		sprintf(theId,OUTPUT_ID_FORMAT,zoneId,position);

		sprintf(tclString,"{ { 2Mass { } {%s %f %f %d %d %d %.2f %.2f} } } ",
				theId,raInDeg,decInDeg,theSign,qflag,field,blueMagnitudeInMag,redMagnitudeInMag);
		Tcl_DStringAppend(dsptr,tclString,-1);
	}

	return (0);
}

/****************************************************************************/
/* Free the all ACC files array */
/****************************************************************************/
void freeAllCatalogFiles(const indexTable2Mass* const allAccFiles, const searchZone2Mass* const mySearchZone) {

	int indexOfFile;

	if(allAccFiles != NULL) {

		for(indexOfFile = mySearchZone->indexOfFirstDistanceToPoleZone;
					indexOfFile <= mySearchZone->indexOfLastDistanceToPoleZone;indexOfFile++) {

			releaseSimpleArray((void*)(allAccFiles[indexOfFile]->arrayOfPosition));
			releaseSimpleArray((void*)(allAccFiles[indexOfFile]->numberOfStars));
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
	int indexInFile;
	int totalNumberOfStars;
	int numberOfStarsInZone;
	int raZoneNumber;
	int raZoneNumberPlusOne;
	indexTable2Mass* indexTable;
	FILE* inputStream;

	/* Allocate memory */
	indexTable    = (indexTable2Mass*)malloc(NUMBER_OF_CATALOG_FILES * sizeof(indexTable2Mass));
	if(indexTable == NULL) {
		sprintf(outputLogChar,"Error : indexTable out of memory\n");
		return (NULL);
	}

	for(indexOfFile = mySearchZone2Mass->indexOfFirstDecZone;
			indexOfFile <= mySearchZone2Mass->indexOfLastDecZone;indexOfFile++) {

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

		/* The first and last accelerator files (corresponding to poles) are empty */
		if(indexOfFile == 0) {

			for(indexOfLine = 0; indexOfLine < ACC_FILE_NUMBER_OF_LINES; indexOfLine++) {

				indexTable[indexOfFile].idOfFirstStarInZone[indexOfLine] = 0;
				indexTable[indexOfFile].numberOfStarsInZone[indexOfLine] = NUMBER_OF_STARS_IN_FIRST_ZONE;
			}

			if(*maximumNumberOfStars  < NUMBER_OF_STARS_IN_FIRST_ZONE) {
				*maximumNumberOfStars = NUMBER_OF_STARS_IN_FIRST_ZONE;
			}

		} else if (indexOfFile == NUMBER_OF_CATALOG_FILES - 1) {

			for(indexOfLine = 0; indexOfLine < ACC_FILE_NUMBER_OF_LINES; indexOfLine++) {

				indexTable[indexOfFile].idOfFirstStarInZone[indexOfLine] = 0;
				indexTable[indexOfFile].numberOfStarsInZone[indexOfLine] = NUMBER_OF_STARS_IN_LAST_ZONE;
			}

			if(*maximumNumberOfStars  < NUMBER_OF_STARS_IN_LAST_ZONE) {
				*maximumNumberOfStars = NUMBER_OF_STARS_IN_LAST_ZONE;
			}

		} else {

			/* Open the catalog ACC files */
			sprintf(shortName,CATALOG_NAME_FORMAT,indexOfFile);
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

					indexTable[indexOfFile].idOfFirstStarInZone[indexOfLine] = indexInFile - 1;
					indexTable[indexOfFile].numberOfStarsInZone[indexOfLine] = numberOfStarsInZone;

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
	const double decNorthPoleInMicroDegree               = DEG2MICRODEG * DEC_NORTH_POLE_DEG;
	const double decSouthPoleInMicroDegree               = DEG2MICRODEG * DEC_SOUTH_POLE_DEG;
	const double accFileRaZoneWidthInMicroDegree         = DEG2MICRODEG * ACC_FILE_RA_ZONE_WIDTH_IN_DEGREE;

	mySearchZone2Mass.decStartInMicroDegree    = (int)(DEG2MICRODEG * (decInDeg - radiusInDeg));
	mySearchZone2Mass.decEndInMicroDegree      = (int)(DEG2MICRODEG * (decInDeg + radiusInDeg));
	mySearchZone2Mass.magnitudeStartInMilliMag = (int)(MAG2MILLIMAG * magMin);
	mySearchZone2Mass.magnitudeEndInMilliMag   = (int)(MAG2MILLIMAG * magMax);

	if((mySearchZone2Mass.decStartInMicroDegree  <= decSouthPoleInMicroDegree) &&
			(mySearchZone2Mass.decEndInMicroDegree >= decNorthPoleInMicroDegree)) {

		mySearchZone2Mass.decStartInMicroDegree      = decSouthPoleInMicroDegree;
		mySearchZone2Mass.decEndInMicroDegree        = decNorthPoleInMicroDegree;
		mySearchZone2Mass.raStartInMicroDegree       = DEG2MICRODEG * START_RA_DEG;
		mySearchZone2Mass.raEndInMicroDegree         = DEG2MICRODEG * COMPLETE_RA_DEG;
		mySearchZone2Mass.isArroundZeroRa            = 0;

	} else if(mySearchZone2Mass.decStartInMicroDegree <= decSouthPoleInMicroDegree) {

		mySearchZone2Mass.decStartInMicroDegree      = decSouthPoleInMicroDegree;
		mySearchZone2Mass.raStartInMicroDegree       = DEG2MICRODEG * START_RA_DEG;
		mySearchZone2Mass.raEndInMicroDegree         = DEG2MICRODEG * COMPLETE_RA_DEG;
		mySearchZone2Mass.isArroundZeroRa            = 0;

	} else if(mySearchZone2Mass.decEndInMicroDegree >= decNorthPoleInMicroDegree) {

		mySearchZone2Mass.decEndInMicroDegree        = decNorthPoleInMicroDegree;
		mySearchZone2Mass.raStartInMicroDegree       = DEG2MICRODEG * START_RA_DEG;
		mySearchZone2Mass.raEndInMicroDegree         = DEG2MICRODEG * COMPLETE_RA_DEG;
		mySearchZone2Mass.isArroundZeroRa            = 0;

	} else {

		radiusRa                                = radiusInDeg / cos(decInDeg * DEC2RAD);
		tmpValue                                = DEG2MICRODEG * (raInDeg  - radiusRa);
		ratio                                   = tmpValue / COMPLETE_RA_DEG;
		ratio                                   = floor(ratio) * COMPLETE_RA_DEG;
		tmpValue                               -= ratio;
		mySearchZone2Mass.raStartInMicroDegree  = (int)tmpValue;

		tmpValue                                = DEG2MICRODEG * (raInDeg  + radiusRa);
		ratio                                   = tmpValue / COMPLETE_RA_DEG;
		ratio                                   = floor(ratio) * COMPLETE_RA_DEG;
		tmpValue                               -= ratio;
		mySearchZone2Mass.raEndInMicroDegree    = (int)tmpValue;

		mySearchZone2Mass.isArroundZeroRa       = 0;

		if(mySearchZone2Mass.raStartInMicroDegree >  mySearchZone2Mass.raEndInMicroDegree) {
			mySearchZone2Mass.isArroundZeroRa     = 1;
		}
	}

	mySearchZone2Mass.indexOfFirstDecZone = (int) ((mySearchZone2Mass.decStartInMicroDegree - decSouthPoleInMicroDegree) / catalogDistanceToPoleWidthInMicroDegree);
	mySearchZone2Mass.indexOfLastDecZone  = (int) ((mySearchZone2Mass.decEndInMicroDegree   - decSouthPoleInMicroDegree) / catalogDistanceToPoleWidthInMicroDegree);

	if(mySearchZone2Mass.indexOfFirstDecZone >= NUMBER_OF_CATALOG_FILES) {
		mySearchZone2Mass.indexOfFirstDecZone = NUMBER_OF_CATALOG_FILES - 1;
	}
	if(mySearchZone2Mass.indexOfLastDecZone  >= NUMBER_OF_CATALOG_FILES) {
		mySearchZone2Mass.indexOfLastDecZone  = NUMBER_OF_CATALOG_FILES - 1;
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
