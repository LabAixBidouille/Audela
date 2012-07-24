#include "csusno.h"
/*
 * csusnoa2.c
 *
 *  Created on: Jul 24, 2012
 *      Author: A. Klotz
 */

static char outputLogChar[1024];

int cmd_tcl_csusnoa2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	if((argc == 2) && (strcmp(argv[1],"-h") == 0)) {
		sprintf(outputLogChar,"Help usage : %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) magnitudeMin(mag)? magnitudeMax(mag)?\n",argv[0]);
		Tcl_SetResult(interp,outputLogChar,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	if((argc != 5) && (argc != 7)) {
		sprintf(outputLogChar,"usage : %s pathOfCatalog ra(deg) dec(deg) radius(arcmin) magnitudeMax(mag)? magnitudeMin(mag)?\n",argv[0]);
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

	/* Print the filtered stars */
	Tcl_DString dsptr;
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { USNOA2 { } "
		"{ ra_deg dec_deg im1_mag im2_mag sigmag_mag objt dsf sigra_deg sigdc_deg na1 nu1 us1 cn1 cepra_deg cepdc_deg "
		"pmrac_masperyear pmdc_masperyear sigpmr_masperyear sigpmd_masperyear id2m jmag_mag hmag_mag kmag_mag jicqflg hicqflg kicqflg je2mpho he2mpho ke2mpho "
		"smB_mag smR2_mag smI_mag clbl qfB qfR2 qfI "
		"catflg1 catflg2 catflg3 catflg4 catflg5 catflg6 catflg7 catflg8 catflg9 catflg10 "
		"g1 c1 leda x2m rn } } } ",-1);

	Tcl_DStringAppend(&dsptr,"} } } ",-1);

	 // end of sources list
	Tcl_DStringAppend(&dsptr,"}",-1); // end of main list
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	/* Release the memory */

	return (TCL_OK);
}

