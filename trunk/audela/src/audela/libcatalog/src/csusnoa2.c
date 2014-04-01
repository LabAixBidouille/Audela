#include "csusno.h"
/*
 * csusnoa2.c
 *
 *  Created on: Jul 24, 2012
 *      Author: A. Klotz / Y. Damerdji
 */

static char outputLogChar[1024];

int cmd_tcl_csusnoa2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	int maximumNumberOfStars = 0;
	int indexOfRA;
	int indexOfCatalog;
	char shortName[1024];
	char fileName[1024];
	FILE* inputStream;
	searchZoneUsnoa2 mySearchZoneUsnoa2;
	starUsno* arrayOfStars;
	const indexTableUsno* allAccFiles;
	Tcl_DString dsptr;
//FILE *f;
//f=fopen("c:/d/a/usno2a.log","wt");
//fclose(f);
	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Define search zone */
	mySearchZoneUsnoa2 = findSearchZoneUsnoa2(ra,dec,radius,magMin,magMax);

	/* Read all catalog files to be able to deliver an ID for each star */
	allAccFiles        = readIndexFileUsno(pathToCatalog,&mySearchZoneUsnoa2,&maximumNumberOfStars);
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
	arrayOfStars     = (starUsno*)malloc(maximumNumberOfStars * sizeof(starUsno));
	if(arrayOfStars == NULL) {
		sprintf(outputLogChar,"arrayOfStars = %d (starUsno) out of memory\n",maximumNumberOfStars);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { USNOA2 { } { ID ra_deg dec_deg sign qflag field magB magR } } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	for(indexOfCatalog = mySearchZoneUsnoa2.indexOfFirstDistanceToPoleZone; indexOfCatalog <= mySearchZoneUsnoa2.indexOfLastDistanceToPoleZone; indexOfCatalog++) {

		/* Open the CAT file (.acc) */
		sprintf(shortName,CATALOG_NAME_FORMAT,indexOfCatalog * CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DECI_DEGREE);
		sprintf(fileName,"%s%s%s",pathToCatalog,shortName,DOT_CAT_EXTENSION);

		inputStream = fopen(fileName,"rb");
		if(inputStream == NULL) {
			sprintf(outputLogChar,"%s not found\n",fileName);
			Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
			return (TCL_ERROR);
		}

		if(mySearchZoneUsnoa2.subSearchZone.isArroundZeroRa) {

			for(indexOfRA = mySearchZoneUsnoa2.indexOfFirstRightAscensionZone; indexOfRA < ACC_FILE_NUMBER_OF_LINES; indexOfRA++) {

				if(processOneZoneUsnoCentredOnZeroRA(&dsptr,inputStream,&(allAccFiles[indexOfCatalog]),
						arrayOfStars,&mySearchZoneUsnoa2,indexOfCatalog,indexOfRA)) {
					Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
					return (TCL_ERROR);
				}
			}

			for(indexOfRA = 0; indexOfRA <= mySearchZoneUsnoa2.indexOfLastRightAscensionZone; indexOfRA++) {

				if(processOneZoneUsnoCentredOnZeroRA(&dsptr,inputStream,&(allAccFiles[indexOfCatalog]),
						arrayOfStars,&mySearchZoneUsnoa2,indexOfCatalog,indexOfRA)) {
					Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
					return (TCL_ERROR);
				}
			}

		} else {

			for(indexOfRA = mySearchZoneUsnoa2.indexOfFirstRightAscensionZone; indexOfRA <= mySearchZoneUsnoa2.indexOfLastRightAscensionZone; indexOfRA++) {

				if(processOneZoneUsnoNotCentredOnZeroRA(&dsptr,inputStream,&(allAccFiles[indexOfCatalog]),
						arrayOfStars,&mySearchZoneUsnoa2,indexOfCatalog,indexOfRA)) {
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
	freeAllUsnoCatalogFiles(allAccFiles,&mySearchZoneUsnoa2);
	releaseSimpleArray(arrayOfStars);

	return (TCL_OK);
}

/****************************************************************************/
/* Process one RA-DEC zone centered on zero ra                              */
/****************************************************************************/
int processOneZoneUsnoCentredOnZeroRA(Tcl_DString* const dsptr, FILE* const inputStream,const indexTableUsno* const oneAccFile,
		starUsno* const arrayOfStars,const searchZoneUsnoa2* const mySearchZoneUsnoa2, const int indexOfCatalog, const int indexOfRA) {

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
	starUsno theStar;
	char tclString[1024];

	const searchZoneRaSpdCas* const subSearchZone = &(mySearchZoneUsnoa2->subSearchZone);
	const magnitudeBoxDeciMag* const magnitudeBox = &(mySearchZoneUsnoa2->magnitudeBox);

	/* Move to this position */
	fseek(inputStream,oneAccFile->arrayOfPosition[indexOfRA] * sizeof(starUsno),SEEK_SET);
	/* Read the amount of stars */
	/*
	if(fread(arrayOfStars,sizeof(starUsno),oneAccFile->numberOfStars[indexOfRA],inputStream) !=  oneAccFile->numberOfStars[indexOfRA]) {
		sprintf(outputLogChar,"can not read %d (starUsno)\n",oneAccFile->numberOfStars[indexOfRA]);
		return (1);
	}
	*/

	position = oneAccFile->arrayOfPosition[indexOfRA];
	zoneId   = indexOfCatalog * CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DECI_DEGREE;

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile->numberOfStars[indexOfRA]; indexOfStar++) {

		/* Read the stars */
		if(fread(&arrayOfStars[indexOfStar].ra,sizeof(int),1,inputStream) !=  1) {
			sprintf(outputLogChar,"can not read %d (starUsno)\n",oneAccFile->numberOfStars[indexOfRA]);
			return (1);
		}
		if(fread(&arrayOfStars[indexOfStar].spd,sizeof(int),1,inputStream) !=  1) {
			sprintf(outputLogChar,"can not read %d (starUsno)\n",oneAccFile->numberOfStars[indexOfRA]);
			return (1);
		}
		if(fread(&arrayOfStars[indexOfStar].mags,sizeof(int),1,inputStream) !=  1) {
			sprintf(outputLogChar,"can not read %d (starUsno)\n",oneAccFile->numberOfStars[indexOfRA]);
			return (1);
		}
		theStar  = arrayOfStars[indexOfStar];
		raInCas  = convertBig2LittleEndianForInteger(theStar.ra);
		position++;

		if ((raInCas < subSearchZone->raStartInCas) && (raInCas > subSearchZone->raEndInCas)) {
			continue;
		}

		spdInCas   = convertBig2LittleEndianForInteger(theStar.spd);

		if ((spdInCas < subSearchZone->spdStartInCas) || (spdInCas > subSearchZone->spdEndInCas)) {
			continue;
		}
		magnitudes             = convertBig2LittleEndianForInteger(theStar.mags);
		redMagnitudeInDeciMag  = usnoa2GetUsnoRedMagnitudeInDeciMag(magnitudes);
		if((redMagnitudeInDeciMag < magnitudeBox->magnitudeStartInDeciMag) || (redMagnitudeInDeciMag > magnitudeBox->magnitudeEndInDeciMag)) {
			continue;
		}

		raInDeg            = (double)raInCas / DEG2CAS;
		decInDeg           = (double)spdInCas / DEG2CAS + DEC_SOUTH_POLE_DEG;
		redMagnitudeInMag  = (double)redMagnitudeInDeciMag / MAG2DECIMAG;
		blueMagnitudeInMag = (double)usnoa2GetUsnoBleueMagnitudeInDeciMag(magnitudes) / MAG2DECIMAG;
		theSign            = usnoa2GetUsnoSign(magnitudes);
		qflag              = usnoa2GetUsnoQflag(magnitudes);
		field              = usnoa2GetUsnoField(magnitudes);
		sprintf(theId,OUTPUT_ID_FORMAT,zoneId,position);
		sprintf(tclString,"{ { USNOA2 { } {%s %f %f %d %d %d %.2f %.2f} } } ",theId,raInDeg,decInDeg,theSign,qflag,field,blueMagnitudeInMag,redMagnitudeInMag);
		Tcl_DStringAppend(dsptr,tclString,-1);
	}

	return (0);
}

/****************************************************************************/
/* Process one RA-DEC zone not centered on zero ra                           */
/****************************************************************************/
int processOneZoneUsnoNotCentredOnZeroRA(Tcl_DString* const dsptr, FILE* const inputStream,const indexTableUsno* const oneAccFile,
		starUsno* const arrayOfStars,const searchZoneUsnoa2* const mySearchZoneUsnoa2, const int indexOfCatalog, const int indexOfRA) {

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
	starUsno theStar;
	char tclString[1024];
	const searchZoneRaSpdCas* const subSearchZone = &(mySearchZoneUsnoa2->subSearchZone);
	const magnitudeBoxDeciMag* const magnitudeBox = &(mySearchZoneUsnoa2->magnitudeBox);

	/* Move to this position */
	fseek(inputStream,oneAccFile->arrayOfPosition[indexOfRA] * sizeof(starUsno),SEEK_SET);

	/* Read the amount of stars */
	if(fread(arrayOfStars,sizeof(starUsno),oneAccFile->numberOfStars[indexOfRA],inputStream) !=  oneAccFile->numberOfStars[indexOfRA]) {
		sprintf(outputLogChar,"can not read %d (starUsno)\n",oneAccFile->numberOfStars[indexOfRA]);
		return (1);
	}

	position = oneAccFile->arrayOfPosition[indexOfRA];
	zoneId   = indexOfCatalog * CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DECI_DEGREE;

	/* Loop over stars and filter them */
	for(indexOfStar = 0; indexOfStar < oneAccFile->numberOfStars[indexOfRA]; indexOfStar++) {

		theStar  = arrayOfStars[indexOfStar];
		raInCas  = convertBig2LittleEndianForInteger(theStar.ra);
		position++;

		if ((raInCas < subSearchZone->raStartInCas) || (raInCas > subSearchZone->raEndInCas)) {
			continue;
		}

		spdInCas = convertBig2LittleEndianForInteger(theStar.spd);

		if ((spdInCas < subSearchZone->spdStartInCas) || (spdInCas > subSearchZone->spdEndInCas)) {
			continue;
		}
		magnitudes             = convertBig2LittleEndianForInteger(theStar.mags);
		redMagnitudeInDeciMag  = usnoa2GetUsnoRedMagnitudeInDeciMag(magnitudes);
		if((redMagnitudeInDeciMag < magnitudeBox->magnitudeStartInDeciMag) || (redMagnitudeInDeciMag > magnitudeBox->magnitudeEndInDeciMag)) {
			continue;
		}

		raInDeg            = (double)raInCas / DEG2CAS;
		decInDeg           = (double)spdInCas / DEG2CAS + DEC_SOUTH_POLE_DEG;
		redMagnitudeInMag  = (double)redMagnitudeInDeciMag / MAG2DECIMAG;
		blueMagnitudeInMag = (double)usnoa2GetUsnoBleueMagnitudeInDeciMag(magnitudes) / MAG2DECIMAG;
		theSign            = usnoa2GetUsnoSign(magnitudes);
		qflag              = usnoa2GetUsnoQflag(magnitudes);
		field              = usnoa2GetUsnoField(magnitudes);
		sprintf(theId,OUTPUT_ID_FORMAT,zoneId,position);
		sprintf(tclString,"{ { USNOA2 { } {%s %f %f %d %d %d %.2f %.2f} } } ",
				theId,raInDeg,decInDeg,theSign,qflag,field,blueMagnitudeInMag,redMagnitudeInMag);
		Tcl_DStringAppend(dsptr,tclString,-1);
	}

	return (0);
}

/****************************************************************************/
/* Free the all ACC files array */
/****************************************************************************/
void freeAllUsnoCatalogFiles(const indexTableUsno* const allAccFiles, const searchZoneUsnoa2* const mySearchZoneUsnoa2) {

	int indexOfFile;

	if(allAccFiles != NULL) {

		for(indexOfFile = mySearchZoneUsnoa2->indexOfFirstDistanceToPoleZone;
					indexOfFile <= mySearchZoneUsnoa2->indexOfLastDistanceToPoleZone;indexOfFile++) {

			releaseSimpleArray((void*)(allAccFiles[indexOfFile].arrayOfPosition));
			releaseSimpleArray((void*)(allAccFiles[indexOfFile].numberOfStars));
		}
	}

	releaseSimpleArray((void*)allAccFiles);
}

/****************************************************************************/
/* Read the catalog files which contain the search zones                    */
/****************************************************************************/
const indexTableUsno* readIndexFileUsno(const char* const pathOfCatalog,
		const searchZoneUsnoa2* const mySearchZoneUsnoa2, int* const maximumNumberOfStars) {

	int indexOfFile;
	int indexOfLine;
	char fileName[1024];
	char shortName[1024];
	char oneLine[128];
	FILE* inputStream;
	double zoneRa;
	int indexInFile;
	int numberOfStars;
	indexTableUsno* allAccFiles;

	allAccFiles = (indexTableUsno*)malloc(NUMBER_OF_CATALOG_FILES_USNO * sizeof(indexTableUsno));
	if(allAccFiles == NULL) {
		sprintf(outputLogChar,"allAccFiles = %d (accFiles) out of memory\n",NUMBER_OF_CATALOG_FILES_USNO);
		return (NULL);
	}

	for(indexOfFile = mySearchZoneUsnoa2->indexOfFirstDistanceToPoleZone;
			indexOfFile <= mySearchZoneUsnoa2->indexOfLastDistanceToPoleZone;indexOfFile++) {

		/* Allocate memory for internal tables */
		allAccFiles[indexOfFile].arrayOfPosition = (unsigned int*)malloc(ACC_FILE_NUMBER_OF_LINES* sizeof(unsigned int));
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
			if ( fgets (oneLine, 128, inputStream) == NULL ) {
				sprintf(outputLogChar,"%s : can not read the %d th line\n",fileName,indexOfLine);
				return (NULL);
			} else {
				sscanf(oneLine,FORMAT_ACC,&zoneRa,&indexInFile,&numberOfStars);

				if(fabs(zoneRa - indexOfLine * ACC_FILE_RA_ZONE_WIDTH_IN_HOUR) > 1e-6) {
					sprintf(outputLogChar,"%s : error in Ra zone in the %d th line\n",fileName,indexOfLine);
					return (NULL);
				}

				allAccFiles[indexOfFile].arrayOfPosition[indexOfLine] = indexInFile - 1;
				allAccFiles[indexOfFile].numberOfStars[indexOfLine]   = numberOfStars;

				if(*maximumNumberOfStars  < numberOfStars) {
					*maximumNumberOfStars = numberOfStars;
				}
			}
		}

		fclose(inputStream);
	}

	return (allAccFiles);
}

/*===========================================================*/
/* Extraction de la magnitude (bleue ou rouge selon l'etat   */
/* de la variable 'UsnoDisplayBlueMag') a partir de l'entier */
/* 32 bits brut en provenance du fichier USNO.               */
/* On prend en compte ici les petites subtilites expliquees  */
/* dans le fichier README de l'USNO (style mag a 99, ...).   */
/*===========================================================*/
double usnoa2GetUsnoBleueMagnitudeInDeciMag(const int magL)
{
	double mag;
	char buf[11];
	char buf2[4];
	double TT_EPS_DOUBLE = 2.225073858507203e-308;
	sprintf(buf,"%010ld",labs(magL));
	strncpy(buf2,buf+4,3); *(buf2+3)='\0';
	mag = (double)atof(buf2);
	if (mag <= TT_EPS_DOUBLE)
	{
		strncpy(buf2,buf+1,3);
		*(buf2+3)='\0';
		if ((double)atof(buf2) <= TT_EPS_DOUBLE)
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
double usnoa2GetUsnoRedMagnitudeInDeciMag(const int magL)
{
	double mag;
	char buf[11];
	char buf2[4];

	sprintf(buf,"%010ld",labs(magL));
	strncpy(buf2,buf+7,3); *(buf2+3) = '\0';
	mag = (double)atof(buf2);
	if (atoi(buf2)==999)
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
int usnoa2GetUsnoSign(const int magL)
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
int usnoa2GetUsnoQflag(const int magL)
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
int usnoa2GetUsnoField(const int magL)
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

	fillSearchZoneRaSpdCas(&(mySearchZoneUsnoa2.subSearchZone), raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxDeciMag(&(mySearchZoneUsnoa2.magnitudeBox), magMin, magMax);

	mySearchZoneUsnoa2.indexOfFirstDistanceToPoleZone    = (int) (mySearchZoneUsnoa2.subSearchZone.spdStartInCas / (CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DEGREE * DEG2CAS));
	mySearchZoneUsnoa2.indexOfLastDistanceToPoleZone     = (int) (mySearchZoneUsnoa2.subSearchZone.spdEndInCas / (CATLOG_DISTANCE_TO_POLE_WIDTH_IN_DEGREE * DEG2CAS));

	if(mySearchZoneUsnoa2.indexOfFirstDistanceToPoleZone >= NUMBER_OF_CATALOG_FILES_USNO) {
		mySearchZoneUsnoa2.indexOfFirstDistanceToPoleZone = NUMBER_OF_CATALOG_FILES_USNO - 1;
	}
	if(mySearchZoneUsnoa2.indexOfLastDistanceToPoleZone  >= NUMBER_OF_CATALOG_FILES_USNO) {
		mySearchZoneUsnoa2.indexOfLastDistanceToPoleZone  = NUMBER_OF_CATALOG_FILES_USNO - 1;
	}

	mySearchZoneUsnoa2.indexOfFirstRightAscensionZone    = (int) (mySearchZoneUsnoa2.subSearchZone.raStartInCas / (ACC_FILE_RA_ZONE_WIDTH_IN_DEGREE * DEG2CAS));
	mySearchZoneUsnoa2.indexOfLastRightAscensionZone     = (int) (mySearchZoneUsnoa2.subSearchZone.raEndInCas / (ACC_FILE_RA_ZONE_WIDTH_IN_DEGREE * DEG2CAS));

	/* debut ajout AK */
	if(mySearchZoneUsnoa2.indexOfFirstRightAscensionZone >= ACC_FILE_NUMBER_OF_LINES) {
		mySearchZoneUsnoa2.indexOfFirstRightAscensionZone = ACC_FILE_NUMBER_OF_LINES - 1;
	}
	if(mySearchZoneUsnoa2.indexOfLastRightAscensionZone >= ACC_FILE_NUMBER_OF_LINES) {
		mySearchZoneUsnoa2.indexOfLastRightAscensionZone = ACC_FILE_NUMBER_OF_LINES - 1;
	}
	/* fin ajout AK */

	if(DEBUG) {
		printf("mySearchZoneUsnoa2.indexOfFirstDistanceToPoleZone   = %d\n",mySearchZoneUsnoa2.indexOfFirstDistanceToPoleZone);
		printf("mySearchZoneUsnoa2.indexOfLastDistanceToPoleZone    = %d\n",mySearchZoneUsnoa2.indexOfLastDistanceToPoleZone);
		printf("mySearchZoneUsnoa2.indexOfFirstRightAscensionZone   = %d\n",mySearchZoneUsnoa2.indexOfFirstRightAscensionZone);
		printf("mySearchZoneUsnoa2.indexOfLastRightAscensionZone    = %d\n",mySearchZoneUsnoa2.indexOfLastRightAscensionZone);
	}

	return (mySearchZoneUsnoa2);
}
