#include "csusno.h"
/*
 * csusnoa2.c
 *
 *  Created on: Jul 24, 2012
 *      Author: A. Klotz / Y. Damerdji
 */

static char outputLogChar[1024];

int cmd_tcl_csusnoa2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	if((argc == 2) && (strcmp(argv[1],"-h") == 0)) {
		sprintf(outputLogChar,"Help usage : %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) ?magnitudeMin(mag) magnitudeMax(mag)?\n",argv[0]);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	if((argc != 5) && (argc != 7)) {
		sprintf(outputLogChar,"usage : %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) ?magnitudeMax(mag) magnitudeMin(mag)?\n",argv[0]);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Read inputs */
	char pathOfCatalog[1024];
	strcpy(pathOfCatalog,argv[1]);
	const double ra     = atof(argv[2]);
	const double dec    = atof(argv[3]);
	const double radius = atof(argv[4]);
	double magMin;
	double magMax;
	if(argc == 7) {
		magMin          = atof(argv[5]);
		magMax          = atof(argv[6]);
	} else {
		magMin          = -99.99;
		magMax          = 99.99;
	}

	/* Add slash to the end of the path if not exist*/
	const char slash[2] = "/";
	if (strlen(pathOfCatalog) > 0) {
		if (pathOfCatalog[strlen(pathOfCatalog)-1] != slash[0] ) {
			strcat(pathOfCatalog,slash);
		}
	}

	/* Define search zone */
	searchZoneUsnoa2 mySearchZoneUsnoa2 = findSearchZoneUsnoa2(ra,dec,radius,magMin,magMax);

	/* Put in a array the areas of right ascension : unit is CAS */
	double* rightAscensionAreas = computeAreasOfRightAscension();
	if(rightAscensionAreas == NULL) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Read all catalog files to be able to deliver an ID for each star */
	int maximumNumberOfStars = 0;
	const accFiles* allAccFiles = readAllCatalogFiles(pathOfCatalog,&maximumNumberOfStars);
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
	starUsno* arrayOfStars = (starUsno*)malloc(maximumNumberOfStars * sizeof(starUsno));
	if(arrayOfStars == NULL) {
		sprintf(outputLogChar,"arrayOfStars = %d (starUsno) out of memory\n",maximumNumberOfStars);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DString dsptr;
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { USNOA2 { } { ID ra_deg dec_deg sign qflag field magB magR } } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	int indexOfRA;
	int indexOfCatalog;
	char shortName[1024];
	char fileName[1024];
	FILE* inputStream;

	for(indexOfCatalog = mySearchZoneUsnoa2.indexOfFirstDistanceToPoleZone; indexOfCatalog <= mySearchZoneUsnoa2.indexOfLastDistanceToPoleZone; indexOfCatalog++) {

		/* Open the CAT file */
		sprintf(shortName,CATALOG_NAME_FORMAT,indexOfCatalog * CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DECI_DEGREE);
		sprintf(fileName,"%s%s%s",pathOfCatalog,shortName,DOT_CAT_EXTENSION);
		printf("open %s ....\n",fileName);

		inputStream = fopen(fileName,"rb");
		if(inputStream == NULL) {
			sprintf(outputLogChar,"%s not found\n",fileName);
			Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
			return (TCL_ERROR);
		}

		if(mySearchZoneUsnoa2.isArroundZeroRa) {

			for(indexOfRA = mySearchZoneUsnoa2.indexOfLastRightAscensionZone; indexOfRA < ACC_FILE_NUMBER_OF_LINES; indexOfRA++) {

				if(processOneZone(&dsptr,inputStream,allAccFiles[indexOfCatalog],arrayOfStars,&mySearchZoneUsnoa2,indexOfRA)) {
					Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
					return (TCL_ERROR);
				}
			}

			for(indexOfRA = 0; indexOfRA <= mySearchZoneUsnoa2.indexOfFirstRightAscensionZone; indexOfRA++) {

				if(processOneZone(&dsptr,inputStream,allAccFiles[indexOfCatalog],arrayOfStars,&mySearchZoneUsnoa2,indexOfRA)) {
					Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
					return (TCL_ERROR);
				}
			}

		} else {

			for(indexOfRA = mySearchZoneUsnoa2.indexOfFirstRightAscensionZone; indexOfRA <= mySearchZoneUsnoa2.indexOfLastRightAscensionZone; indexOfRA++) {

				if(processOneZone(&dsptr,inputStream,allAccFiles[indexOfCatalog],arrayOfStars,&mySearchZoneUsnoa2,indexOfRA)) {
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
	freeAllCatalogFiles(allAccFiles);
	releaseSimpleArray(rightAscensionAreas);
	releaseSimpleArray(arrayOfStars);

	return (TCL_OK);
}

/****************************************************************************/
/* Process one RA-DEC zone                                                  */
/****************************************************************************/
int processOneZone(Tcl_DString* dsptr, FILE* inputStream,accFiles oneAccFile,starUsno* const arrayOfStars,const searchZoneUsnoa2* mySearchZoneUsnoa2, const int indexOfRA) {

	int theId;
	int theSign,qflag,field;
	int raInCas;
	unsigned int indexOfStar;
	double raInDeg;
	double decInDeg;
	int spdInCas;
	int magnitudes;
	int redMagnitudeInDeciMag;
	double redMagnitudeInMag;
	double blueMagnitudeInMag;
	starUsno theStar;
	char tclString[1024];

	/* Move to this position */
	fseek(inputStream,oneAccFile.arrayOfPosition[indexOfRA] * sizeof(starUsno),SEEK_SET);
	/* Read the amount of stars */
	if(fread(arrayOfStars,sizeof(starUsno),oneAccFile.numberOfStars[indexOfRA],inputStream) !=  oneAccFile.numberOfStars[indexOfRA]) {
		sprintf(outputLogChar,"can not read %d (starUsno)\n",oneAccFile.numberOfStars[indexOfRA]);
		return (1);
	}

	theId = oneAccFile.arrayOfIds[indexOfRA];

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile.numberOfStars[indexOfRA]; indexOfStar++) {

		theStar  = arrayOfStars[indexOfStar];
		raInCas  = usnoa2Big2LittleEndianLong(theStar.ra);
		if ((raInCas < mySearchZoneUsnoa2->raStartInCas) || (raInCas > mySearchZoneUsnoa2->raEndInCas)) {
			continue;
		}
		spdInCas   = usnoa2Big2LittleEndianLong(theStar.spd);
		if ((spdInCas < mySearchZoneUsnoa2->distanceToPoleStartInCas) || (spdInCas > mySearchZoneUsnoa2->distanceToPoleEndInCas)) {
			continue;
		}
		magnitudes             = usnoa2Big2LittleEndianLong(theStar.mags);
		redMagnitudeInDeciMag  = usnoa2GetUsnoRedMagnitudeInDeciMag(magnitudes);
		if((redMagnitudeInDeciMag < mySearchZoneUsnoa2->magnitudeStartInDeciMag) || (redMagnitudeInDeciMag > mySearchZoneUsnoa2->magnitudeEndInDeciMag)) {
			continue;
		}

		raInDeg            = (double)raInCas / DEG2CAS;
		decInDeg           = (double)spdInCas / DEG2CAS + DEC_SOUTH_POLE_DEG;
		redMagnitudeInMag  = (double)redMagnitudeInDeciMag / MAG2DECIMAG;
		blueMagnitudeInMag = (double)usnoa2GetUsnoBleueMagnitudeInDeciMag(magnitudes) / MAG2DECIMAG;
		theSign            = usnoa2GetUsnoSign(magnitudes);
		qflag              = usnoa2GetUsnoQflag(magnitudes);
		field              = usnoa2GetUsnoField(magnitudes);

		sprintf(tclString,"{ { USNOA2 { } {%d %f %f %d %d %d %.2f %.2f} } } ",theId,raInDeg,decInDeg,theSign,qflag,field,blueMagnitudeInMag,redMagnitudeInMag);
		printf("%s\n",tclString);
		Tcl_DStringAppend(dsptr,tclString,-1);
		theId++;
	}

	return (0);
}

/****************************************************************************/
/* Put in an array the areas of right ascension : unit is CentiArcSecond    */
/***************************************************************************/
double* computeAreasOfRightAscension() {

	double* rightAscensionAreas = (double*)malloc(ACC_FILE_NUMBER_OF_LINES * sizeof(double));
	if(rightAscensionAreas == NULL) {
		sprintf(outputLogChar,"rightAscensionAreas = %d (double) out of memory\n",ACC_FILE_NUMBER_OF_LINES);
		return (NULL);
	}

	const double AccFileRaZoneWidthInCas = ACC_FILE_RA_ZONE_WIDTH_IN_DEGREE * DEG2CAS;

	int index                            = 0;
	while(index < ACC_FILE_NUMBER_OF_LINES) {

		rightAscensionAreas[index]       = index * AccFileRaZoneWidthInCas;
		index++;
	}

	return (rightAscensionAreas);
}

/****************************************************************************/
/* Free the all ACC files array */
/****************************************************************************/
void freeAllCatalogFiles(const accFiles* allAccFiles) {

	int indexOfFile;

	if(allAccFiles != NULL) {

		for(indexOfFile = 0; indexOfFile < NUMBER_OF_CATALOG_FILES; indexOfFile++) {

			releaseSimpleArray((void*)(allAccFiles[indexOfFile].arrayOfIds));
			releaseSimpleArray((void*)(allAccFiles[indexOfFile].arrayOfPosition));
			releaseSimpleArray((void*)(allAccFiles[indexOfFile].numberOfStars));
		}
	}

	releaseSimpleArray((void*)allAccFiles);
}

/****************************************************************************/
/* Read all catalog files to be able to deliver an ID for each star */
/****************************************************************************/
const accFiles* readAllCatalogFiles(const char* const pathOfCatalog, int* maximumNumberOfStars) {

	accFiles* allAccFiles = (accFiles*)malloc(NUMBER_OF_CATALOG_FILES* sizeof(accFiles));
	if(allAccFiles == NULL) {
		sprintf(outputLogChar,"allAccFiles = %d (accFiles) out of memory\n",NUMBER_OF_CATALOG_FILES);
		return (NULL);
	}

	int indexOfFile;
	int indexOfLine;
	char fileName[1024];
	char shortName[1024];
	char oneLine[128];
	FILE* inputStream;
	double zoneRa;
	int indexInFile;
	int numberOfStars;
	int theTotalId = 1;

	for(indexOfFile = 0; indexOfFile < NUMBER_OF_CATALOG_FILES; indexOfFile++) {

		/* Allocate memory for internal tables */
		allAccFiles[indexOfFile].arrayOfIds = (int*)malloc(ACC_FILE_NUMBER_OF_LINES* sizeof(int));
		if(allAccFiles[indexOfFile].arrayOfIds == NULL) {
			sprintf(outputLogChar,"allAccFiles[%d].arrayOfIds = %d (int) out of memory\n",indexOfFile,ACC_FILE_NUMBER_OF_LINES);
			return (NULL);
		}
		allAccFiles[indexOfFile].arrayOfPosition = (int*)malloc(ACC_FILE_NUMBER_OF_LINES* sizeof(int));
		if(allAccFiles[indexOfFile].arrayOfPosition == NULL) {
			sprintf(outputLogChar,"allAccFiles[%d].arrayOfPosition = %d (int) out of memory\n",indexOfFile,ACC_FILE_NUMBER_OF_LINES);
			return (NULL);
		}
		allAccFiles[indexOfFile].numberOfStars = (unsigned int*)malloc(ACC_FILE_NUMBER_OF_LINES* sizeof(int));
		if(allAccFiles[indexOfFile].numberOfStars == NULL) {
			sprintf(outputLogChar,"allAccFiles[%d].numberOfStars = %d (int) out of memory\n",indexOfFile,ACC_FILE_NUMBER_OF_LINES);
			return (NULL);
		}

		/* Open the catalog ACC files */
		sprintf(shortName,CATALOG_NAME_FORMAT,indexOfFile * CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DECI_DEGREE);
		sprintf(fileName,"%s%s%s",pathOfCatalog,shortName,DOT_ACC_EXTENSION);
		inputStream = fopen(fileName,"rt");
		if(inputStream == NULL) {
			sprintf(outputLogChar,"%s not found\n",fileName);
			return (NULL);
		}

		/* Read the catalog ACC files */
		for(indexOfLine = 0; indexOfLine < ACC_FILE_NUMBER_OF_LINES; indexOfLine++) {
			if ( fgets (oneLine , 128 , inputStream) == NULL ) {
				sprintf(outputLogChar,"%s : can not read the %d th line\n",fileName,indexOfLine);
				return (NULL);
			} else {
				sscanf(oneLine,FORMAT_ACC,&zoneRa,&indexInFile,&numberOfStars);

				if(fabs(zoneRa - indexOfLine * ACC_FILE_RA_ZONE_WIDTH_IN_HOUR) > 1e-6) {
					sprintf(outputLogChar,"%s : error in Ra zone in the %d th line\n",fileName,indexOfLine);
					return (NULL);
				}

				allAccFiles[indexOfFile].arrayOfIds[indexOfLine]      = theTotalId;
				allAccFiles[indexOfFile].arrayOfPosition[indexOfLine] = indexInFile - 1;
				allAccFiles[indexOfFile].numberOfStars[indexOfLine]   = numberOfStars;
				theTotalId                                           += numberOfStars;

				if(*maximumNumberOfStars  < numberOfStars) {
					*maximumNumberOfStars = numberOfStars;
				}
			}
		}

		fclose(inputStream);
	}

	return (allAccFiles);
}

/*=========================================================*/
/* Transform Big to Little Endian (and vice versa */
/* d'ailleurs...!!!). L'entier 32 bits ABCD est transforme */
/* en DCBA.                                                */
/*=========================================================*/
int usnoa2Big2LittleEndianLong(int l) {
	return ((l << 24) | ((l << 8) & 0x00FF0000) |
			((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF));
}

/*===========================================================*/
/* Extraction de la magnitude (bleue ou rouge selon l'etat   */
/* de la variable 'UsnoDisplayBlueMag') a partir de l'entier */
/* 32 bits brut en provenance du fichier USNO.               */
/* On prend en compte ici les petites subtilites expliquees  */
/* dans le fichier README de l'USNO (style mag a 99, ...).   */
/*===========================================================*/
double usnoa2GetUsnoBleueMagnitudeInDeciMag(int magL)
{
	double mag;
	char buf[11];
	char buf2[4];
	double TT_EPS_DOUBLE=2.225073858507203e-308;

	sprintf(buf,"%010ld",labs(magL));
	strncpy(buf2,buf+4,3); *(buf2+3)='\0';
	mag = (double)atof(buf2)/10.0;
	if (mag<=TT_EPS_DOUBLE)
	{
		strncpy(buf2,buf+1,3);
		*(buf2+3)='\0';
		if ((double)atof(buf2)<=TT_EPS_DOUBLE)
		{
			strncpy(buf2,buf+7,3); *(buf2+3) = '\0';
			mag = (double)atof(buf2);
		}
	}
	return (mag);
}

/*===========================================================*/
/* Extraction de la magnitude (bleue ou rouge selon l'etat   */
/* de la variable 'UsnoDisplayBlueMag') a partir de l'entier */
/* 32 bits brut en provenance du fichier USNO.               */
/* On rpend en compte ici les petites subtilites expliquees  */
/* dans le fichier README de l'USNO (style mag a 99, ...).   */
/*===========================================================*/
double usnoa2GetUsnoRedMagnitudeInDeciMag(int magL)
{
	double mag;
	char buf[11];
	char buf2[4];

	sprintf(buf,"%010ld",labs(magL));
	strncpy(buf2,buf+7,3); *(buf2+3) = '\0';
	mag=(double)atof(buf2)/10.0;
	if (mag==999.0)
	{
		strncpy(buf2,buf+4,3); *(buf2+3) = '\0';
		mag = (double)atof(buf2);
	}
	return (mag);
}

/*=======================================================================*/
/* The third 32-bit integer has been packed according to the following   */
/* format. SQFFFBBBRRR   (decimal), where                                */
/*  S = sign is - if this entry is correlated with an ACT star.  For     */
/*      these objects, the PMM's position and magnitude are quoted.  If  */
/*      you want the ACT values, use the ACT.  Please note that we have  */ 
/*      not preserved the identification of the ACT star.  Since there   */
/*      are so few ACT stars, spatial correlation alone is sufficient    */
/*      to do the cross-identification should it be needed.  {DIFFERENT} */
/*=======================================================================*/
int usnoa2GetUsnoSign(int magL)
{
	int sign;
	char buf[11];
	char buf2[4];

	sprintf(buf,"%010ld",labs(magL));
	strncpy(buf2,buf+0,1); *(buf2+1) = '\0';
	sign=(int)atoi(buf2);
	return (sign);
}

/*=======================================================================*/
/* The third 32-bit integer has been packed according to the following   */
/* format. SQFFFBBBRRR   (decimal), where                                */
/*  Q = 1 if internal PMM flags indicate that the magnitude(s) might be  */
/*      in error, or is 0 if things looked OK.  As discussed in read.pht,*/
/*      the PMM gets confused on bright stars.  If more than 40% of the  */
/*      pixels in the image were saturated, our experience is that the   */
/*      image fitting process has failed, and that the listed magnitude  */
/*      can be off by 3 magnitudes or more.  The Q flag is set if either */
/*      the blue or red image failed this test.  In general, this is a   */
/*      problem for bright (<12th mag) stars only. {SAME}                */
/*=======================================================================*/
int usnoa2GetUsnoQflag(int magL)
{
	int qflag;
	char buf[11];
	char buf2[4];

	sprintf(buf,"%010ld",labs(magL));
	strncpy(buf2,buf+1,1); *(buf2+1) = '\0';
	qflag=(int)atoi(buf2);
	return (qflag);
}

/*=======================================================================*/
/* The third 32-bit integer has been packed according to the following   */
/* format. SQFFFBBBRRR   (decimal), where                                */
/*  FFF = field on which this object was detected.  In the north, we     */
/*    adopted the MLP numbers for POSS-I.  These start at 1 at the       */
/*    north pole (1 and 2 are degenerate) and end at 825 in the -20      */
/*    degree zone.  Note that fields 723 and 724 are degenerate, and we  */
/*    measured but omitted 723 in favor of 724 which corresponds to the  */
/*    print in the paper POSS-I atlas.  In the south, the fields start   */
/*    at 1 at the south pole and the -20 zone ends at 606.  To avoid     */
/*    wasting space, the field numbers were not put on a common system.  */
/*                                                                       */
/*    Instead, you should use the following test                         */
/*          IF ((zone.lt.750).and.(field.le.606)) THEN                   */
/*         south(field)                                                  */
/*       ELSE                                                            */
/*         north(field)                                                  */
/*       ENDIF                                                           */
/*    DIFFERENT only in that A1.0 changed from south to north at -30     */
/*    and A2.0 changes at -20 (south)/-18 (north).  The actual boundary  */
/*    is pretty close to -17.5 degrees, depending on actual plate center.*/
/*=======================================================================*/
int usnoa2GetUsnoField(int magL)
{
	int field;
	char buf[11];
	char buf2[4];

	sprintf(buf,"%010ld",labs(magL));
	strncpy(buf2,buf+2,3); *(buf2+3) = '\0';
	field=(int)atoi(buf2);
	return (field);
}

/******************************************************************************/
/* Find the search zone having its center on (ra,dec) with a radius of radius */
/******************************************************************************/
const searchZoneUsnoa2 findSearchZoneUsnoa2(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneUsnoa2 mySearchZoneUsnoa2;
	const double radiusInDeg                    = radiusInArcMin / DEG2ARCMIN;
	mySearchZoneUsnoa2.distanceToPoleStartInCas = (int)(DEG2CAS * (decInDeg - DEC_SOUTH_POLE_DEG - radiusInDeg));
	mySearchZoneUsnoa2.distanceToPoleEndInCas   = (int)(DEG2CAS * (decInDeg - DEC_SOUTH_POLE_DEG + radiusInDeg));
	mySearchZoneUsnoa2.magnitudeStartInDeciMag  = (int)(MAG2DECIMAG * magMin);
	mySearchZoneUsnoa2.magnitudeEndInDeciMag    = (int)(MAG2DECIMAG * magMax);

	if((mySearchZoneUsnoa2.distanceToPoleStartInCas  <= DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_CAS) && (mySearchZoneUsnoa2.distanceToPoleEndInCas >= DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_CAS)) {

		mySearchZoneUsnoa2.distanceToPoleStartInCas   = 0;
		mySearchZoneUsnoa2.distanceToPoleEndInCas     = DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_CAS;
		mySearchZoneUsnoa2.raStartInCas               = START_RA_CAS;
		mySearchZoneUsnoa2.raEndInCas                 = COMPLETE_RA_CAS;
		mySearchZoneUsnoa2.isArroundZeroRa            = 0;

	} else if(mySearchZoneUsnoa2.distanceToPoleStartInCas <= DISTANCE_TO_SOUTH_POLE_AT_SOUTH_POLE_CAS) {

		mySearchZoneUsnoa2.distanceToPoleStartInCas        = 0;
		mySearchZoneUsnoa2.raStartInCas                    = START_RA_CAS;
		mySearchZoneUsnoa2.raEndInCas                      = COMPLETE_RA_CAS;
		mySearchZoneUsnoa2.isArroundZeroRa                 = 0;

	} else if(mySearchZoneUsnoa2.distanceToPoleEndInCas >= DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_CAS) {

		mySearchZoneUsnoa2.distanceToPoleEndInCas        = DISTANCE_TO_SOUTH_POLE_AT_NORTH_POLE_CAS;
		mySearchZoneUsnoa2.raStartInCas                  = START_RA_CAS;
		mySearchZoneUsnoa2.raEndInCas                    = COMPLETE_RA_CAS;
		mySearchZoneUsnoa2.isArroundZeroRa               = 0;

	} else {

		double ratio;
		double tmpValue;

		const double radiusRa                  = radiusInDeg / cos(decInDeg * DEC2RAD);
		tmpValue                               = DEG2CAS * (raInDeg  - radiusRa);
		ratio                                  = tmpValue / COMPLETE_RA_CAS;
		ratio                                  = floor(ratio) * COMPLETE_RA_CAS;
		tmpValue                              -= ratio;
		mySearchZoneUsnoa2.raStartInCas        = (int)tmpValue;

		tmpValue                               = DEG2CAS * (raInDeg  + radiusRa);
		ratio                                  = tmpValue / COMPLETE_RA_CAS;
		ratio                                  = floor(ratio) * COMPLETE_RA_CAS;
		tmpValue                              -= ratio;
		mySearchZoneUsnoa2.raEndInCas          = (int)tmpValue;

		mySearchZoneUsnoa2.isArroundZeroRa     = 0;

		if(mySearchZoneUsnoa2.raStartInCas     >  mySearchZoneUsnoa2.raEndInCas) {
			mySearchZoneUsnoa2.isArroundZeroRa = 1;
		}
	}

	mySearchZoneUsnoa2.indexOfFirstDistanceToPoleZone    = (int) (mySearchZoneUsnoa2.distanceToPoleStartInCas / (CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DEGREE * DEG2CAS));
	mySearchZoneUsnoa2.indexOfLastDistanceToPoleZone     = (int) (mySearchZoneUsnoa2.distanceToPoleEndInCas / (CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DEGREE * DEG2CAS));

	mySearchZoneUsnoa2.indexOfFirstRightAscensionZone    = (int) (mySearchZoneUsnoa2.raStartInCas / (ACC_FILE_RA_ZONE_WIDTH_IN_DEGREE * DEG2CAS));
	mySearchZoneUsnoa2.indexOfLastRightAscensionZone     = (int) (mySearchZoneUsnoa2.raEndInCas / (ACC_FILE_RA_ZONE_WIDTH_IN_DEGREE * DEG2CAS));

	if(DEBUG) {
		printf("mySearchZoneUsnoa2.decStart                         = %d\n",mySearchZoneUsnoa2.distanceToPoleStartInCas);
		printf("mySearchZoneUsnoa2.decEnd                           = %d\n",mySearchZoneUsnoa2.distanceToPoleEndInCas);
		printf("mySearchZoneUsnoa2.raStart                          = %d\n",mySearchZoneUsnoa2.raStartInCas);
		printf("mySearchZoneUsnoa2.raEnd                            = %d\n",mySearchZoneUsnoa2.raEndInCas);
		printf("mySearchZoneUsnoa2.isArroundZeroRa                  = %d\n",mySearchZoneUsnoa2.isArroundZeroRa);
		printf("mySearchZoneUsnoa2.magnitudeStart                   = %d\n",mySearchZoneUsnoa2.magnitudeStartInDeciMag);
		printf("mySearchZoneUsnoa2.magnitudeEnd                     = %d\n",mySearchZoneUsnoa2.magnitudeEndInDeciMag);
		printf("mySearchZoneUsnoa2.indexOfFirstDistanceToPoleZone   = %d\n",mySearchZoneUsnoa2.indexOfFirstDistanceToPoleZone);
		printf("mySearchZoneUsnoa2.indexOfLastDistanceToPoleZone    = %d\n",mySearchZoneUsnoa2.indexOfLastDistanceToPoleZone);
		printf("mySearchZoneUsnoa2.indexOfFirstRightAscensionZone   = %d\n",mySearchZoneUsnoa2.indexOfFirstRightAscensionZone);
		printf("mySearchZoneUsnoa2.indexOfLastRightAscensionZone    = %d\n",mySearchZoneUsnoa2.indexOfLastRightAscensionZone);
	}

	return (mySearchZoneUsnoa2);
}
