/*

  Copyright (c) 2002 Finger Lakes Instrumentation (FLI), L.L.C.
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

        Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

        Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials
        provided with the distribution.

        Neither the name of Finger Lakes Instrumentation (FLI), LLC
        nor the names of its contributors may be used to endorse or
        promote products derived from this software without specific
        prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.

  ======================================================================

  Finger Lakes Instrumentation, L.L.C. (FLI)
  web: http://www.fli-cam.com
  email: support@fli-cam.com

*/

#include <sys/types.h>
#include <sys/stat.h>

#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

#include "libfli.h"
#include "myerr.h"

#if defined(__linux__) || defined(__NetBSD__)
#undef WARNC
#define WARNC(c, format, args...)			\
  warnx(__ERR_PREFIX format ": %s",			\
	__FILE__, __LINE__ , ## args, strerror(c))
#endif

#define TRYFUNC(f, ...)				\
  do {						\
    if ((r = f(__VA_ARGS__)))			\
      WARNC(-r, #f "() failed");		\
  } while (0)

#define LIBVERSIZ 1024

typedef struct {
  flidomain_t domain;
  char *dname;
  char *name;
} cam_t;

int numcams = 0;

void findcams(flidomain_t domain, cam_t **cam);

void usage(char *fmt, ...)
{
  extern const char *__progname;
  va_list ap;

  va_start(ap, fmt);

  printf("\n");
  if (fmt != NULL)
  {
    vprintf(fmt, ap);
    printf("\n\n");
  }
  printf("  Usage: %s <outfile basename>\n\n", __progname);

  va_end(ap);

  exit(0);
}

int main(int argc, char *argv[])
{
  int opt, i;
  long r;
  char *outfile, libver[LIBVERSIZ];
  cam_t *cam = NULL;

  /* Parse command line argument list */
  while ((opt = getopt(argc, argv, "")) != -1)
  {
    switch (opt)
    {
    default:
      usage(NULL);
    }
  }

  argc -= optind;
  argv += optind;

  if (argc == 0)
    usage("No output file basename given");

  outfile = argv[0];
  argc--;
  argv++;

  for (opt = 0; opt < argc; opt++)
    WARNX("Ignoring command line argument `%s'", argv[opt]);

  TRYFUNC(FLISetDebugLevel, "NO HOST", FLIDEBUG_ALL);

  TRYFUNC(FLIGetLibVersion, libver, LIBVERSIZ);
  INFO("Library version `%s'", libver);

  /* Parallel port */
  //findcams(FLIDOMAIN_PARALLEL_PORT, &cam);
  /* USB */
  findcams(FLIDOMAIN_USB, &cam);
  /* Serial */
  findcams(FLIDOMAIN_SERIAL, &cam);
  /* Inet */
  //findcams(FLIDOMAIN_INET, &cam);

  for (i = 0; i < numcams; i++)
  {
    long tmp1, tmp2, tmp3, tmp4, row, img_rows, row_width;
    double d1, d2;
    flidev_t dev;
#define BUFF_SIZ 4096
    char buff[BUFF_SIZ];
    u_int16_t *img;
    int fd, img_size;

    INFO("Trying camera `%s' from %s domain", cam[i].name, cam[i].dname);

    TRYFUNC(FLIOpen, &dev, cam[i].name, FLIDEVICE_CAMERA | cam[i].domain);
    if (r)
      continue;

    TRYFUNC(FLIGetModel, dev, buff, BUFF_SIZ);
    INFO("Model: %s", buff);

    TRYFUNC(FLIGetHWRevision, dev, &tmp1);
    INFO("Hardware Rev: %ld", tmp1);

    TRYFUNC(FLIGetFWRevision, dev, &tmp1);
    INFO("Firmware Rev: %ld", tmp1);

    TRYFUNC(FLIGetPixelSize, dev, &d1, &d2);
    INFO("Pixel Size: %f x %f\n", d1, d2);

    TRYFUNC(FLIGetArrayArea, dev, &tmp1, &tmp2, &tmp3, &tmp4);
    INFO("Array area: (%ld, %ld)(%ld, %ld)", tmp1, tmp2, tmp3, tmp4);

    TRYFUNC(FLIGetVisibleArea, dev, &tmp1, &tmp2, &tmp3, &tmp4);
    INFO("Visible area: (%ld, %ld)(%ld, %ld)\n", tmp1, tmp2, tmp3, tmp4);
    row_width = tmp3 - tmp1;
    img_rows = tmp4 - tmp2;

    TRYFUNC(FLISetImageArea, dev, tmp1, tmp2, tmp3, tmp4);

    TRYFUNC(FLISetNFlushes, dev, 0);

    d1 = -10.0;
    TRYFUNC(FLISetTemperature, dev, d1);

    TRYFUNC(FLIGetTemperature, dev, &d1);
    INFO("Temperature: %f", d1);

    TRYFUNC(FLISetExposureTime, dev, 500);

    TRYFUNC(FLISetFrameType, dev, FLI_FRAME_TYPE_NORMAL);

    TRYFUNC(FLISetBitDepth, dev, FLI_MODE_8BIT);

    TRYFUNC(FLISetHBin, dev, 1);

    TRYFUNC(FLISetVBin, dev, 1);

    TRYFUNC(FLIExposeFrame, dev);

    do {
      TRYFUNC(FLIGetExposureStatus, dev, &tmp1);
      if (r)
	break;

      usleep(tmp1 * 1000);
    } while (tmp1);

    img_size = img_rows * row_width * sizeof(u_int16_t);

    if ((img = malloc(img_size)) == NULL)
      ERR(1, "malloc() failed");

    for (row = 0; row < img_rows; row++)
      TRYFUNC(FLIGrabRow, dev, &img[row * row_width], row_width);

    if (snprintf(buff, BUFF_SIZ, "%s.%d.raw", outfile, i) == -1)
      ERR(1, "output file name too long");

    if ((fd = open(buff, O_WRONLY | O_CREAT | O_EXCL,
		   S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH )) == -1)
      ERR(1, "open() of `%s' failed", buff);
    if (write(fd, img, img_size) != img_size)
      WARN("write() failed");
    close(fd);
    INFO("Raw image written to `%s'", buff);

    if (snprintf(buff, BUFF_SIZ, "%s.%d.png", outfile, i) == -1)
      ERR(1, "output file name too long");

    TRYFUNC(WritePNG, buff, row_width, img_rows, img);
    INFO("PNG image written to `%s'", buff);

    free(img);
    TRYFUNC(FLIClose, dev);
  }

  for (i = 0; i < numcams; i++)
    free(cam[i].name);

  free(cam);

  exit(0);
}

void findcams(flidomain_t domain, cam_t **cam)
{
  long r;
  char **tmplist;

  TRYFUNC(FLIList, domain | FLIDEVICE_CAMERA, &tmplist);

  if (tmplist != NULL && tmplist[0] != NULL)
  {
    int i, cams = 0;

    for (i = 0; tmplist[i] != NULL; i++)
      cams++;

    if ((*cam = realloc(*cam, (numcams + cams) * sizeof(cam_t))) == NULL)
      ERR(1, "realloc() failed");

    for (i = 0; tmplist[i] != NULL; i++)
    {
      int j;

      for (j = 0; tmplist[i][j] != '\0'; j++)
	if (tmplist[i][j] == ';')
	{
	  tmplist[i][j] = '\0';
	  break;
	}

      cam[numcams + i]->domain = domain;
      switch (domain)
      {
      case FLIDOMAIN_PARALLEL_PORT:
	cam[numcams + i]->dname = "parallel port";
	break;

      case FLIDOMAIN_USB:
	cam[numcams + i]->dname = "USB";
	break;

      case FLIDOMAIN_SERIAL:
	cam[numcams + i]->dname = "serial";
	break;

      case FLIDOMAIN_INET:
	cam[numcams + i]->dname = "inet";
	break;

      default:
	cam[numcams + i]->dname = "Unknown domain";
      }
      cam[numcams + i]->name = strdup(tmplist[i]);
    }

    numcams += cams;
  }

  TRYFUNC(FLIFreeList, tmplist);

  return;
}
