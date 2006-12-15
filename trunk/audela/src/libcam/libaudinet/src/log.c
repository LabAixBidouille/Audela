/* log.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 * fonctions utilitaires pour ecrire des traces
 * a l'ecran ou dans un fichier
 *
 * $Id: log.c,v 1.3 2006-12-15 23:31:21 michelpujol Exp $
 */


#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#if defined(OS_LIN) || defined(OS_MACOS)
#include <unistd.h>
#include <stdarg.h>
#endif

#if defined(OS_MACOS)
#include <sys/time.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>		/* time, ftime, strftime, localtime */
#include <sys/timeb.h>		/* ftime, struct timebuffer */
#include <stdio.h>

static char *getlogdate(char *buf, size_t size);

static char logFileName[] = "audinet.log";

static int audinet_logLevel= 0;

/*
 * void initLog(char *fmt,...)
 *    Writes data to the log files. Works likes printf functions, with
 *    a format string, plus the correspondings arguments.
 */
void initLog( int logLevel)
{
    FILE *f;

   audinet_logLevel = logLevel;

   if (audinet_logLevel == 0 ) { return; };

   if ((f = fopen(logFileName, "w")) != NULL) {
      fprintf(f, "Debut de trace\n");
      fclose(f);
   }
}


/*
 * void logInfo(char *fmt,...)
 *    Writes data to the log files. Works likes printf functions, with
 *    a format string, plus the correspondings arguments.
 */
void logInfo(char *fmt, ...)
{
    char s[8192];
    va_list va;
    FILE *f;
    char logdate[25];

   if (audinet_logLevel == 0 ) { return; };


    if ((f = fopen(logFileName, "at+")) != NULL) {
	va_start(va, fmt);
	vsprintf(s, fmt, va);
	va_end(va);
	getlogdate(logdate, sizeof(logdate));
	fprintf(f, "[%s] INFO: %s\n", logdate, s);
	fclose(f);
    }
}

void logError(char *fmt, ...)
{
    char s[8192];
    va_list va;
    FILE *f;
    char logdate[25];

   if (audinet_logLevel == 0 ) { return; };

    if ((f = fopen(logFileName, "at+")) != NULL) {
	va_start(va, fmt);
	vsprintf(s, fmt, va);
	va_end(va);
	getlogdate(logdate, sizeof(logdate));
	fprintf(f, "[%s] ERROR: %s\n", logdate, s);
	fclose(f);
    }

}


void logImage(unsigned short *p0, int imax, int jmax)
{
    //je trace les pixels dans un fichier texte
    char trace[8192];
    char trace2[10];
    int c, r;

   if (audinet_logLevel == 0 ) { return; };

    sprintf(trace, "    ");
    for (c = 0; c < imax; c++) {
	sprintf(trace2, "  %03d", c);
	strcat(trace, trace2);
    }
    logInfo(trace);
    for (r = 0; r < jmax; r++) {
	sprintf(trace, "L%3d:", r);
	for (c = 0; c < imax; c++) {
	    sprintf(trace2, "%4X ", p0[r * jmax + c]);
	    strcat(trace, trace2);
	}
	logInfo(trace);
    }

}


/*
 * char* getlogdate(char *buf, size_t size)
 *   Generates a FITS compliant string into buf representing the date at which
 *   this function is called. Returns buf.
 */
char *getlogdate(char *buf, size_t size)
{
#if defined(OS_WIN)
  #ifdef _MSC_VER
    /* cas special a Microsoft C++ pour avoir les millisecondes */
    struct _timeb timebuffer;
    time_t ltime;
    _ftime(&timebuffer);
    time(&ltime);
    strftime(buf, size - 3, "%Y-%m-%d %H:%M:%S", localtime(&ltime));
    sprintf(buf, "%s.%02d", buf, (int) (timebuffer.millitm / 10));
  #else
    struct time t1;
    struct date d1;
    getdate(&d1);
    gettime(&t1);
    sprintf(buf, "%04d-%02d-%02d %02d:%02d:%02d.%02d : ", d1.da_year,
	    d1.da_mon, d1.da_day, t1.ti_hour, t1.ti_min, t1.ti_sec,
	    t1.ti_hund);
  #endif
#elif defined(OS_LIN)
    struct timeb timebuffer;
    time_t ltime;
    ftime(&timebuffer);
    time(&ltime);
    strftime(buf, size - 3, "%Y-%m-%d %H:%M:%S", localtime(&ltime));
    sprintf(buf, "%s.%02d", buf, (int) (timebuffer.millitm / 10));
#elif defined(OS_MACOS)
    struct timeval t;
    char message[50];
    char s1[27];
    gettimeofday(&t,NULL);
    strftime(message,45,"%Y-%m-%dT%H:%M:%S",localtime((const time_t*)(&t.tv_sec)));
    sprintf(s1,"%s.%02d : ",message,(t.tv_usec)/10000);
#else
    sprintf(s1,"[No time functions available]");
#endif

    return buf;
}
