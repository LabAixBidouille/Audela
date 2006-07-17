#include <windows.h>
#include <stdio.h>
#include <time.h>
#include <errno.h>

#include "../libfli-libfli.h"
#include "../libfli-debug.h"

#define MAX_DEBUG_STRING (1024)

LARGE_INTEGER dlltime;
static int _level = 0;
static HANDLE dfile = INVALID_HANDLE_VALUE;

int debugclose(void)
{
	if(dfile != INVALID_HANDLE_VALUE)
	{
		CloseHandle(dfile);
	}

	return 0;
}

int debugopen(char *host)
{
	char date[12], time[12];

	_strdate(date);
	_strtime(time);
	QueryPerformanceCounter(&dlltime);

	if(host != NULL)
	{
		dfile = CreateFile(host, GENERIC_WRITE, FILE_SHARE_READ, NULL,
			OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
		if(dfile == INVALID_HANDLE_VALUE)
			return -EBADF;
	}

	debug(FLIDEBUG_ALL, "*** %s %s ***", date, time);
	debug(FLIDEBUG_ALL, "%s", version);
	return 0;
}

void debug(int level, char *format, ...)
{
	char stime[16];
	char buffer[MAX_DEBUG_STRING];
	char output[MAX_DEBUG_STRING];
	int ret;
	LARGE_INTEGER time, freq;
	double dtime;
	
#ifndef _DEBUG
	if( level & _level )
#endif
	{
		va_list ap;
		va_start(ap, format);
		ret = _vsnprintf(buffer, MAX_DEBUG_STRING - 1, format, ap);
		va_end(ap);

		QueryPerformanceCounter(&time);
		QueryPerformanceFrequency(&freq);

		dtime = ((double) time.QuadPart - (double) dlltime.QuadPart ) / (double) freq.QuadPart;

		_snprintf(stime, 15, "%8.3f", dtime);

		switch (level)
		{
			case FLIDEBUG_INFO:
				ret = _snprintf(output, MAX_DEBUG_STRING - 1, "INFO<%s>: %s\n", stime, buffer);
				break;

			case FLIDEBUG_WARN:
				ret = _snprintf(output, MAX_DEBUG_STRING - 1, "WARN<%s>: %s\n", stime, buffer);
				break;

			case FLIDEBUG_FAIL:
				ret = _snprintf(output, MAX_DEBUG_STRING - 1, "FAIL<%s>: %s\n", stime, buffer);
				break;

			default:
				ret = _snprintf(output, MAX_DEBUG_STRING - 1, " ALL<%s>: %s\n", stime, buffer);
				break;
		}

		if(ret >= 0)
		{
			OutputDebugString(output);
#ifdef _DEBUG
			Sleep(5);
#endif
			if(dfile != INVALID_HANDLE_VALUE)
			{
				DWORD bytes;
				WriteFile(dfile, output, strlen(output), &bytes, NULL);
			}
		}
	}

	return;
}

void setdebuglevel(char *host, int level)
{
	_level = level;

	if (level == 0)
	{
		debugclose();
	}
	else
	{
		debugopen(host);
	}

	return;
}
