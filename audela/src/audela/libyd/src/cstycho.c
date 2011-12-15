#include "cstycho.h"
/*
 * main.c
 *
 *  Created on: Dec 13, 2011
 *      Author: S. Vaillant
 */

int field_is_blank(char *p) {
 while (*p == ' ') p++;
 return (*p == '\0');
}

char** tycho2_search(const char*catalogCompleteName, double ra0, double dec0, double range,
		double magmin, double magmax, int* numberOfOutputs) {

    double dec_min, dec_max;
    double ra_min1, ra_max1;
    double ra_min2, ra_max2;

    double ra,dec,mag;
    FILE *fp;
    char buf[206+2+1];
    size_t sz;

    range /= DEG2ARCMIN;

    dec_min = dec0 - range;
    dec_max = dec0 + range;

    if(dec_max >= 89.9 || dec_min <= -89.9) {
        ra_min1 = 0.0; ra_max1 = 360.0;
        ra_min2 = 0.0; ra_max2 = 360.0;
    } else {
        range /= cos(dec0 * DEC2RAD);
        ra_min1 = ra_min2 = ra0 - range;
        ra_max1 = ra_max2 = ra0 + range;
        if(ra_min1 < 0.0) {
            ra_min2 = ra_min1 + 360.0;
            ra_max2 = 360.0;
        } else if ( ra_max1 > 360.0) {
            ra_min2 = 0.0;
            ra_max2 = ra_max1 - 360.0;
        }
    }

    fp = fopen(catalogCompleteName,"r");
    if (fp==NULL) {
        fprintf(stderr,"Cannot open catalog : %s\n",catalogCompleteName);
        return 1;
    }

    *numberOfOutputs            = 0;
    int lengthOfLine            = 8192;
    int numberOfSupposedOutputs = 10000000;
    char** outputs = (char**)malloc(numberOfSupposedOutputs * sizeof(char*));
	if(outputs == NULL) {
		return NULL;
	}

    while((sz=fread(buf,sizeof(buf)-1,1,fp)) == 1) {
        buf[206] = '\0';
        if(buf[14-1] == 'X') continue; // no mean position
        // 16- 28   F12.8,1X deg     mRAdeg    []? Mean Right Asc, ICRS, epoch J2000 (3)
        buf[28-1]='\0'; ra=atof(buf+16-1);
        if(field_is_blank(buf+16+1)) xabort();
        // 29- 41   F12.8,1X deg     mDEdeg    []? Mean Decl, ICRS, at epoch J2000 (3)
        buf[41-1]='\0'; dec=atof(buf+29-1);
        if(field_is_blank(buf+29+1)) xabort();
        // 124-130   F6.3,1X  mag     VT        [1.905,15.193]? Tycho-2 VT magnitude (7)
        buf[130-1]='\0'; mag=atof(buf+124-1);
        if(dec_min <= dec && dec <= dec_max) {
            if((ra_min1 <= ra && ra <= ra_max1) || (ra_min2 <= ra && ra <= ra_max2)) {
                if((magmin <= mag && mag <= magmax) || field_is_blank(buf+124-1)) {
                    buf[28-1] = '|';
                    buf[41-1] = '|';
                    buf[130-1] = '|';
                    //printf("ra = %3.8f dec = %3.8f mag= %3.3f [%s]\n",ra, dec, mag, buf);
                    outputs[*numberOfOutputs] = (char*)malloc(lengthOfLine * sizeof(char*));
                    if(outputs[*numberOfOutputs] == NULL) {
                    	return NULL;
                    }
                    sprintf(outputs[*numberOfOutputs],"%s",buf);
                    *numberOfOutputs++;
                }
            }
        }
    }

	return outputs;
}

/**
 * Extract stars from Tycho catalog
 */
int Cmd_ydtcl_cstycho(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	if((argc == 2) && (strcmp(argv[1],"-h") == 0)) {
		printf("Help usage : %s catalogCompleteName ra(deg) dec(deg) radius(arcmin) magnitudeMin(mag)? magnitudeMax(mag)?\n",argv[0]);
		return TCL_OK;
	}

	if((argc != 5) && (argc != 7)) {
		printf("usage : %s catalogCompleteName ra(deg) dec(deg) radius(arcmin) magnitudeMax(mag)? magnitudeMin(mag)?\n",argv[0]);
		return TCL_ERROR;
	}

	/* Read inputs */
	const char* catalogCompleteName = argv[1];
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
	printf("Search stars in Tycho around : ra = %f(deg) - dec = %f(deg) - radius = %f(arcmin) - magnitude in [%f,%f](mag)\n",
			ra,dec,radius,magMin,magMax);


	int index;
	int numberOfOutputs = 0;
	char** outputs = tycho2_search(catalogCompleteName,ra,dec,radius,magMin,magMax,numberOfOutputs);
	if(outputs == NULL) {
		return TCL_ERROR;
	}

	Tcl_DString dsptr;
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{",-1);
	char tclLine[8192];
	for(index = 0; index < numberOfOutputs; index++) {
		sprintf(tclLine,"%s",outputs[index]);
		Tcl_DStringAppend(&dsptr,tclLine,-1);
		Tcl_DStringAppend(&dsptr,"}{",-1);
	}
	Tcl_DStringAppend(&dsptr,"}",-1);
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	/* Release outputs*/
	for(index = 0; index < numberOfOutputs; index++) {
		free(outputs[index]);
	}
	free(outputs);
	return TCL_OK;
}
