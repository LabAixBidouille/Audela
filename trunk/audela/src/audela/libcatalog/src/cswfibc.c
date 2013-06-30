/*
 * cswfibc.c
 *
 *  Created on: 30/06/2013
 *      Author: Y. Damerdji
 */

#include "cswfibc.h"

static char outputLogChar[1024];

int cmd_tcl_cswfibc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char pathToCatalog[STRING_COMMON_LENGTH];
	double ra     = 0.;
	double dec    = 0.;
	double radius = 0.;
	double magMin = 0.;
	double magMax = 0.;
	int indexOfZone;
	int numberOfZones;
	char fileName[1024];
	FILE* offsetFileStream;
	searchZoneWfibc mySearchZoneWfibc;
	raZone* raZones;
	Tcl_DString dsptr;

	/* Decode inputs */
	if(decodeInputs(outputLogChar, argc, argv, pathToCatalog, &ra, &dec, &radius, &magMin, &magMax)) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Define search zone */
	mySearchZoneWfibc = findSearchZoneWfibc(ra,dec,radius,magMin,magMax);

	/* Read the accelerator file */
	numberOfZones = (int)((RA_END - RA_START) / RA_STEP) + 1;
	raZones       = readAcceleratorFileWfbic(pathToCatalog,numberOfZones);
	if(raZones == NULL) {
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Open the offset file */
	sprintf(fileName,"%s%s",pathToCatalog,OFFSET_TABLE);
	offsetFileStream = fopen(fileName,"rt");
	if(offsetFileStream == NULL) {
		sprintf(outputLogChar,"File %s not found\n",fileName);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		free(raZones);
		return (TCL_ERROR);
	}

	/* Now we loop over the concerned catalog and send to TCL the results */
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { WFIBC { } { RA_deg DEC_deg error_AlphaCosDelta error_Delta JD PM_AlphaCosDelta PM_Delta error_PM_AlphaCosDelta"
			" error_PM_Delta magR error_magR} } } ",-1);
	/* start of main list */
	Tcl_DStringAppend(&dsptr,"{ ",-1);

	if(mySearchZoneWfibc.subSearchZone.isArroundZeroRa) {

		for(indexOfZone = mySearchZoneWfibc.indexOfFirstRightAscensionZone; indexOfZone < numberOfZones; indexOfZone++) {

			if(processOneZone(&dsptr,offsetFileStream,&(raZones[indexOfZone]),&mySearchZoneWfibc,pathToCatalog)) {
				Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
				free(raZones);
				fclose(offsetFileStream);
				return (TCL_ERROR);
			}
		}

		for(indexOfZone = 0; indexOfZone <= mySearchZoneWfibc.indexOfLastRightAscensionZone; indexOfZone++) {

			if(processOneZone(&dsptr,offsetFileStream,&(raZones[indexOfZone]),&mySearchZoneWfibc,pathToCatalog)) {
				Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
				free(raZones);
				fclose(offsetFileStream);
				return (TCL_ERROR);
			}
		}

	} else {

		for(indexOfZone = mySearchZoneWfibc.indexOfFirstRightAscensionZone; indexOfZone <= mySearchZoneWfibc.indexOfLastRightAscensionZone; indexOfZone++) {

			if(processOneZone(&dsptr,offsetFileStream,&(raZones[indexOfZone]),&mySearchZoneWfibc,pathToCatalog)) {
				Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
				free(raZones);
				fclose(offsetFileStream);
				return (TCL_ERROR);
			}
		}
	}

	/* end of sources list */
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	fclose(offsetFileStream);
	free(raZones);

	return (TCL_OK);
}

/******************************************************************************/
/* Process one zone of RA                                                     */
/******************************************************************************/
const int processOneZone(Tcl_DString* const dsptr, FILE* const offsetFileStream, const raZone* const theRaZone, const searchZoneWfibc* const mySearchZoneWfibc,
		const char* const pathToCatalog) {

	char oneLine[1024];
	char catalogShortName[1024];
	char catalogFullName[1024];
	const double epsilon = 1e-6;
	double raStart, raEnd;
	int indexOfLine;
	int offset;
	int numberOfLines;

	if(theRaZone->numberOfLines == 0) {
		/* Nothing to do */
		return (0);
	}

	if(fseek(offsetFileStream,theRaZone->offset,SEEK_SET)) {
		sprintf(outputLogChar,"Can not move by %d in %s\n",theRaZone->offset,OFFSET_TABLE);
		return(1);
	}

	if(fgets(oneLine,1024,offsetFileStream) == NULL) {
		sprintf(outputLogChar,"Can not read line from %s\n",OFFSET_TABLE);
		return(1);
	}

	/* Check the validity of data */
	if(oneLine[0] != '#') {
		sprintf(outputLogChar,"Line %s should start with #\n",oneLine);
		return(1);
	}

	sscanf(oneLine,FORMAT_OFFSET_TABLE_COMMENT,&raStart,&raEnd);
	if((fabs(theRaZone->raStart - raStart) > epsilon) || (fabs(theRaZone->raEnd - raEnd) > epsilon)) {
		sprintf(outputLogChar,"Line %s contains incompatible data\n",oneLine);
		return(1);
	}

	/* Read the lines */
	for(indexOfLine = 0; indexOfLine < theRaZone->numberOfLines; indexOfLine++) {
		if(fgets(oneLine,1024,offsetFileStream) == NULL) {
			sprintf(outputLogChar,"Can not read line from %s\n",OFFSET_TABLE);
			return(1);
		}
		if(oneLine[0] == '#') {
			sprintf(outputLogChar,"Line %s should not start with #\n",oneLine);
			return(1);
		}
		if(oneLine[0] != '\t') {
			sprintf(outputLogChar,"Line %s should start with tabulation\n",oneLine);
			return(1);
		}
		sscanf(oneLine,FORMAT_OFFSET_TABLE_DATA,catalogShortName,&offset,&numberOfLines);
		sprintf(catalogFullName,"%s%s",pathToCatalog,catalogShortName);

		if(processOneZoneInOneFile(dsptr,catalogFullName,offset,numberOfLines,mySearchZoneWfibc)) {
			return(1);
		}
	}

	return (0);
}

/******************************************************************************/
/* Process one zone of RA   in a catalog file                                 */
/******************************************************************************/
const int processOneZoneInOneFile(Tcl_DString* const dsptr, const char* const catalogFullName, const int offset, const int numberOfLines,
		const searchZoneWfibc* const mySearchZoneWfibc) {

	int lineNumber;
	char oneLine[1024];
	int raDeg, raMin, decDeg, decMin;
	double raSec, decSec, ra, dec, errRa, errDec;
	double pmRa, pmDec, errPmRa, errPmDec, jd;
	double magR, errMagR;
	FILE* const inputStream = fopen(catalogFullName,"rt");
	if(inputStream == NULL) {
		sprintf(outputLogChar,"File %s not found\n",catalogFullName);
		return(1);
	}

	if(fseek(inputStream,offset,SEEK_SET)) {
		sprintf(outputLogChar,"Can not move by %d in %s\n",offset,catalogFullName);
		return(1);
	}

	//printf("Process %s\n",catalogFullName);

	/* Read numberOfLines and output those satisfying the search box */
	for(lineNumber = 0; lineNumber < numberOfLines; lineNumber++) {
		if(fgets(oneLine,1024,inputStream) == NULL) {
			sprintf(outputLogChar,"Can not read line from %s\n",catalogFullName);
			return(1);
		}
		//printf("oneLine = %s\n",oneLine);
		sscanf(oneLine,CATALOG_LINE_FORMAT,&raDeg, &raMin, &raSec, &decDeg, &decMin, &decSec, &errRa, &errDec,
				&jd, &pmRa, &pmDec, &errPmRa, &errPmDec, &magR, &errMagR);

		ra      = 15. * (raDeg + raMin / 60. + raSec / 3600.);
		if(decDeg < 0) {
			dec = decDeg - decMin / 60. - decSec / 3600.;
		} else {
			dec = decDeg + decMin / 60. + decSec / 3600.;
		}

		if(
				((mySearchZoneWfibc->subSearchZone.isArroundZeroRa && ((ra >= mySearchZoneWfibc->subSearchZone.raStartInDeg) || (ra <= mySearchZoneWfibc->subSearchZone.raEndInDeg))) ||
						(!mySearchZoneWfibc->subSearchZone.isArroundZeroRa && ((ra >= mySearchZoneWfibc->subSearchZone.raStartInDeg) && (ra <= mySearchZoneWfibc->subSearchZone.raEndInDeg)))) &&
						(dec  >= mySearchZoneWfibc->subSearchZone.decStartInDeg) &&
						(dec  <= mySearchZoneWfibc->subSearchZone.decEndInDeg) &&
						(magR >= mySearchZoneWfibc->magnitudeBox.magnitudeStartInMag) &&
						(magR <= mySearchZoneWfibc->magnitudeBox.magnitudeEndInMag)) {

			Tcl_DStringAppend(dsptr,"{ { WFIBC { } {",-1);

			sprintf(outputLogChar,"%.6f %.6f %.3f %.3f %.8f %.3f %.3f %.3f %.3f %.3f %.3f", ra, dec, errRa, errDec, jd, pmRa, pmDec, errPmRa, errPmDec, magR, errMagR);

			Tcl_DStringAppend(dsptr,outputLogChar,-1);
			Tcl_DStringAppend(dsptr,"} } } ",-1);
		}
	}

	fclose(inputStream);

	return(0);
}

/******************************************************************************/
/* Read the accelerator table                                                 */
/******************************************************************************/
raZone* const readAcceleratorFileWfbic(const char* const pathToCatalog, const int numberOfZones) {

	const double epsilon = 1e-6;
	char fileFullName[1024];
	char oneLine[1024];
	int indexOfZone;
	FILE* inputStream;
	raZone* raZones   = (raZone*)malloc(numberOfZones * sizeof(raZone));
	if(raZones == NULL) {
		sprintf(outputLogChar,"raZones out of memory (%d raZone)\n",numberOfZones);
		return (NULL);
	}

	/* Read the file */
	sprintf(fileFullName,"%s%s",pathToCatalog,ACCELERATOR_TABLE);
	inputStream = fopen(fileFullName,"rt");
	if(raZones == NULL) {
		sprintf(outputLogChar,"File %s not found\n",fileFullName);
		free(raZones);
		return (NULL);
	}

	for(indexOfZone = 0; indexOfZone < numberOfZones; indexOfZone++) {

		if(fgets(oneLine,1024,inputStream) == NULL) {
			sprintf(outputLogChar,"Can not read line from %s\n",fileFullName);
			free(raZones);
			fclose(inputStream);
			return(NULL);
		}

		sscanf(oneLine,"%lf %lf %d %d", &(raZones[indexOfZone].raStart), &(raZones[indexOfZone].raEnd),
				&(raZones[indexOfZone].offset), &(raZones[indexOfZone].numberOfLines));

		/* Check the compatibility of data */
		if((fabs(raZones[indexOfZone].raStart - RA_START - indexOfZone * RA_STEP) > epsilon) ||
				(fabs(raZones[indexOfZone].raEnd - RA_START - (indexOfZone + 1) * RA_STEP) > epsilon)) {
			sprintf(outputLogChar,"Line %s contains incompatible data\n",oneLine);
			free(raZones);
			fclose(inputStream);
			return(NULL);

		}
	}

	fclose(inputStream);
	return(raZones);
}

/******************************************************************************/
/* Find the search zone having its center on (ra,dec) with a radius of radius */
/******************************************************************************/
const searchZoneWfibc findSearchZoneWfibc(const double raInDeg,const double decInDeg,const double radiusInArcMin,const double magMin, const double magMax) {

	searchZoneWfibc mySearchZoneWfibc;

	fillSearchZoneRaDecDeg(&(mySearchZoneWfibc.subSearchZone), raInDeg, decInDeg, radiusInArcMin);
	fillMagnitudeBoxMag(&(mySearchZoneWfibc.magnitudeBox), magMin, magMax);

	mySearchZoneWfibc.indexOfFirstRightAscensionZone = (int) ((mySearchZoneWfibc.subSearchZone.raStartInDeg - RA_START) / RA_STEP);
	mySearchZoneWfibc.indexOfLastRightAscensionZone  = (int) ((mySearchZoneWfibc.subSearchZone.raEndInDeg   - RA_START) / RA_STEP);

	if(DEBUG) {
		printf("mySearchZoneWfibc.indexOfFirstRightAscensionZone   = %d\n",mySearchZoneWfibc.indexOfFirstRightAscensionZone);
		printf("mySearchZoneWfibc.indexOfLastRightAscensionZone    = %d\n",mySearchZoneWfibc.indexOfLastRightAscensionZone);
	}

	return (mySearchZoneWfibc);
}

