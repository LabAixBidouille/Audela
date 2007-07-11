#ifndef _MYERR_H_
#define _MYERR_H_

#include <err.h>

extern const char *__progname;

#define __FILENAME_LEN 12
#define __LINENUM_LEN 5

#define __STRINGIFY(x) ___STRINGIFY(x)
#define ___STRINGIFY(x) #x

#define __ERR_PREFIX							\
  "%-" __STRINGIFY(__FILENAME_LEN) "." __STRINGIFY(__FILENAME_LEN) "s"	\
  "[%" __STRINGIFY(__LINENUM_LEN) "d]: "

#define ERR(x, format, args...)					\
  err(x, __ERR_PREFIX format, __FILE__, __LINE__ , ## args)

#define ERRC(x, c, format, args...)				\
  errc(x, c, __ERR_PREFIX format, __FILE__, __LINE__ , ## args)

#define ERRX(x, format, args...)				\
  errx(x, __ERR_PREFIX format, __FILE__, __LINE__ , ## args)

#define WARN(format, args...)					\
  warn(__ERR_PREFIX format, __FILE__, __LINE__ , ## args)

#define WARNC(c, format, args...)				\
  warnc(c, __ERR_PREFIX format, __FILE__, __LINE__ , ## args)

#define WARNX(format, args...)					\
  warnx(__ERR_PREFIX format, __FILE__, __LINE__ , ## args)

#define INFO(format, args...)				\
  printf("%s: " __ERR_PREFIX format "\n",		\
	 __progname, __FILE__, __LINE__ , ## args)

#endif /* _MYERR_H_ */
