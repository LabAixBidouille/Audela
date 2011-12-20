#include "cstycho.h"
/*
 * main.c
 *
 *  Created on: Dec 13, 2011
 *      Author: S. Vaillant
 */

// format.txt, character number of the beginning of field (first character number is 1)
static int istart[] = {
	1,6,12,14,16,29,42,50,58,62,
	66,71,76,84,92,95,99,103,107,111,
	118,124,131,137,141,143,149,153,166,179,
	184,189,195,201,203
};

// format.txt, character number of the end of field without trailing vertical bar
static int iend[] = {
	4-0,10-0,13-1,15-1,28-1,41-1,49-1,57-1,61-1,65-1,
	70-1,75-1,83-1,91-1,94-1,98-1,102-1,106-1,110-1,117-1,
	123-1,130-1,136-1,140-1,142-1,148-0,152-1,165-1,178-1,183-1,
	188-1,194-1,200-1,202-1,206-0
};

int field_is_blank(char *p) {
 while (*p == ' ') p++;
 return (*p == '\0');
}

char outputLine[1024];

/*
 * ra0 : from 0 to 360 degrees
 * dec0 : from -90 to 90 degrees
 * range : minutes
 */
char** tycho2_search(const char*pathName, double ra0, double dec0, double range,
		double magmin, double magmax, int* numberOfOutputs) {

    double dec_min, dec_max;
    double ra_min1, ra_max1;
    double ra_min2, ra_max2;

    char catalogCompleteName[1024];
    sprintf(catalogCompleteName,"%s/%s",pathName,CATALOG_FILE_NAME);

    double ra,dec,mag;
    FILE *fp;
    char buf[206+2+1]; // field length + cr + lf + null
    size_t sz;

    range /= DEG2ARCMIN; // convert range from minutes to degrees

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
        } else if (ra_max1 > 360.0) {
            ra_min2 = 0.0;
            ra_max2 = ra_max1 - 360.0;
        }
    }

    fp = fopen(catalogCompleteName,"r");
    if (fp==NULL) {
        sprintf(outputLine,"Cannot open catalog : %s\n",catalogCompleteName);
        return (NULL);
    }

    *numberOfOutputs            = 0;
    int lengthOfLine            = 1000;
    int numberOfSupposedOutputs = 10000000;
    char** outputs = (char**)malloc(numberOfSupposedOutputs * sizeof(char*));
    if(outputs == NULL) {
    	sprintf(outputLine,"outputs out of memory\n");
    	return (NULL);
    }

    // Create an implicit ID = line number in the catalog
    int id = 0;

    while((sz=fread(buf,sizeof(buf)-1,1,fp)) == 1) {
    	id++;
        buf[206] = '\0';
        if(buf[14-1] == 'X') continue; // no mean position
        // 16- 28   F12.8,1X deg     mRAdeg    []? Mean Right Asc, ICRS, epoch J2000 (3)
        buf[28-1]='\0'; ra=atof(buf+16-1);
        //if(field_is_blank(buf+16+1)) xabort();
        // 29- 41   F12.8,1X deg     mDEdeg    []? Mean Decl, ICRS, at epoch J2000 (3)
        buf[41-1]='\0'; dec=atof(buf+29-1);
        //if(field_is_blank(buf+29+1)) xabort();
        // 124-130   F6.3,1X  mag     VT        [1.905,15.193]? Tycho-2 VT magnitude (7)
        buf[130-1]='\0'; mag=atof(buf+124-1);
        if(dec_min <= dec && dec <= dec_max) {
            if((ra_min1 <= ra && ra <= ra_max1) || (ra_min2 <= ra && ra <= ra_max2)) {
                if((magmin <= mag && mag <= magmax) || field_is_blank(buf+124-1)) {
                    buf[28-1] = '|';
                    buf[41-1] = '|';
                    buf[130-1] = '|';
                    //printf("ra = %3.8f dec = %3.8f mag= %3.3f [%s]\n",ra, dec, mag, buf);
                    outputs[*numberOfOutputs] = (char*)malloc(lengthOfLine * sizeof(char));
                    if(outputs[*numberOfOutputs] == NULL) {
                    	sprintf(outputLine,"outputs[%d] out of memory\n",*numberOfOutputs);
                    	return (NULL);
                    }
                    sprintf(outputs[*numberOfOutputs],"%d|%s",id,buf);
                    (*numberOfOutputs)++;
                }
            }
        }
    }

    return (outputs);
}

/**
 * Extract stars from Tycho catalog
 */
int cmd_tcl_cstycho2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
	int i;
	char c;

	if((argc == 2) && (strcmp(argv[1],"-h") == 0)) {
		sprintf(outputLine,"Help usage : %s pathToCatalog ra(deg) dec(deg) radius(arcmin) magnitudeMin(mag)? magnitudeMax(mag)?\n",argv[0]);
		Tcl_SetResult(interp,outputLine,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	if((argc != 5) && (argc != 7)) {
		sprintf(outputLine,"usage : %s pathToCatalog ra(deg) dec(deg) radius(arcmin) magnitudeMax(mag)? magnitudeMin(mag)?\n",argv[0]);
		Tcl_SetResult(interp,outputLine,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/* Read inputs */
	const char* pathToCatalog = argv[1];
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
	//printf(outputLine,"Search stars in Tycho around : ra = %f(deg) - dec = %f(deg) - radius = %f(arcmin) - magnitude in [%f,%f](mag)\n",
			//ra,dec,radius,magMin,magMax);


	int index;
	int numberOfOutputs = 0;
	char** outputs = tycho2_search(pathToCatalog,ra,dec,radius,magMin,magMax,&numberOfOutputs);
	if(outputs == NULL) {
		Tcl_SetResult(interp,outputLine,TCL_VOLATILE);
		return (TCL_ERROR);
	}

	Tcl_DString dsptr;
	Tcl_DStringInit(&dsptr);
	Tcl_DStringAppend(&dsptr,"{ { TYCHO2 { } "
		"{ ID TYC1 TYC2 TYC3 pflag mRAdeg mDEdeg pmRA pmDE e_mRA e_mDE "
		"e_pmRA e_pmDE mepRA mepDE Num g_mRA g_mDE g_pmRA g_pmDE BT "
		"e_BT VT e_VT prox TYC HIP CCDM RAdeg DEdeg epRA epDE e_RA "
		"e_DE posflg corr } } } ",-1);
	Tcl_DStringAppend(&dsptr,"{",-1); // start of sources list
	for(index = 0; index < numberOfOutputs; index++) {
		Tcl_DStringAppend(&dsptr,"{ { TYCHO2 { } ",-1);
		Tcl_DStringAppend(&dsptr,"{",-1); // start of source fields list
		// 35 fields, must match length of istart and iend
		for(i=0;i<35;i++) {
			char *line = strchr(outputs[index],'|') + 1;
			c = *(line+iend[i]);
			*(line+iend[i]) = '\0';
			//printf("%d %s\n",i,outputs[index]+istart[i]-1); fflush(NULL);
			Tcl_DStringAppend(&dsptr," ",-1);
			if(field_is_blank(line+istart[i]-1)) {
				Tcl_DStringAppend(&dsptr,"_",-1);
			} else {
				Tcl_DStringAppend(&dsptr,line+istart[i]-1,-1);
			}
			*(line+iend[i]) = c;
		}
		//Tcl_DStringAppend(&dsptr,outputs[index],-1);
		Tcl_DStringAppend(&dsptr,"} } } ",-1);
	}
	Tcl_DStringAppend(&dsptr,"} ",-1); // end of sources list
	Tcl_DStringResult(interp,&dsptr);
	Tcl_DStringFree(&dsptr);

	/* Release outputs*/
	releaseDoubleArray((void**)outputs, numberOfOutputs);

	return (TCL_OK);
}

