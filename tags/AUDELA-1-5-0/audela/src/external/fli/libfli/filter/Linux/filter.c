#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

#include "../takepic/unix/myerr.h"
#include "libfli.h"

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
#define BUFF_SIZ 4096

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
  printf("  Usage: %s -p [position]\n\n", __progname);

  va_end(ap);

  exit(0);
}

int main(int argc, char *argv[])
{
  int i, position = -1;
  long r;
  char libver[LIBVERSIZ], **list;

  /* Parse command line argument list */
  while (1)
  {
    int opt;

    if ((opt = getopt(argc, argv, "p:")) == -1)
      break;

    switch (opt)
    {
    case 'p':
      position = atoi(optarg);
      if (position < 0)
	usage("Invalid position: %s", optarg);
      break;

    default:
      usage(NULL);
    }
  }

  argc -= optind;
  argv += optind;

  if (position < 0)
    usage("No position given");

  for (i = 0; i < argc; i++)
    WARNX("Ignoring command line argument `%s'", argv[i]);

  TRYFUNC(FLISetDebugLevel, "", FLIDEBUG_ALL);

  TRYFUNC(FLIGetLibVersion, libver, LIBVERSIZ);
  INFO("Library version `%s'", libver);

  TRYFUNC(FLIList, FLIDOMAIN_USB | FLIDEVICE_FILTERWHEEL, &list);

  for (i = 0; list[i] != NULL; i++)
  {
    int j;

    for (j = 0; list[i][j] != '\0'; j++)
      if (list[i][j] == ';')
      {
	list[i][j] = '\0';
	break;
      }
  }

  for (i = 0; list[i] != NULL; i++)
  {
    flidev_t dev;
    long tmp;
    char buff[BUFF_SIZ];

    INFO("Trying filter wheel `%s'", list[i]);

    TRYFUNC(FLIOpen, &dev, list[i], FLIDOMAIN_USB | FLIDEVICE_FILTERWHEEL);
    if (r)
      continue;

    TRYFUNC(FLIGetModel, dev, buff, BUFF_SIZ);
    INFO("Model: %s", buff);

    TRYFUNC(FLIGetHWRevision, dev, &tmp);
    INFO("Hardware Rev: %ld", tmp);

    TRYFUNC(FLIGetFWRevision, dev, &tmp);
    INFO("Firmware Rev: %ld", tmp);

    INFO("Setting filter wheel to position %d", position);
    TRYFUNC(FLISetFilterPos, dev, position);
  }

  TRYFUNC(FLIFreeList, list);

  exit(0);
}
