/*
 * lib10.h 1.00
 *
 * Copyright (c) 1997-1999 ETEL SA. All Rights Reserved.
 *
 * This software is the confidential and proprietary informatione of ETEL SA 
 * ("Confidential Information"). You shall not disclose such Confidential 
 * Information and shall use it only in accordance with the terms of the 
 * license agreement you entered into with ETEL.
 *
 * This software is provided "AS IS," without a warranty of any kind. ALL
 * EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY
 * IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR
 * NON-INFRINGEMENT, ARE HEREBY EXCLUDED. ETEL AND ITS LICENSORS SHALL NOT BE
 * LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING
 * OR DISTRIBUTING THE SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL ETEL OR ITS
 * LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT,
 * INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER
 * CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF
 * OR INABILITY TO USE SOFTWARE, EVEN IF ETEL HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGES.
 *
 * This software is not designed or intended for use in on-line control of
 * aircraft, air traffic, aircraft navigation or aircraft communications; or in
 * the design, construction, operation or maintenance of any nuclear
 * facility. Licensee represents and warrants that it will not use or
 * redistribute the Software for such purposes.
 *
 */

/**
 * this header file contains public declaration for low-level library. it also
 * contains macro-definition for real-time objects/operations used to achieve
 * multi-platform source code.
 * @library lib10
 * @platform win32
 * @platform can296
 * @platform ser296
 * @platform qnx4
 * @platform qnx6
 * @author cbe
 * @since 1.00
 */

#ifndef _LIB10_H
#define _LIB10_H

#ifdef __cplusplus
extern "C" {
#endif

#ifndef __BYTE_ORDER
#if defined WIN32 || defined QNX4
#define __LITTLE_ENDIAN 1234
#define __BIG_ENDIAN 4321
#define __BYTE_ORDER __LITTLE_ENDIAN	/* define byte order for INTEL processor */
#endif /*WIN32 || QNX4*/

#ifdef POSIX
	
#ifdef SOLARIS
#define __LITTLE_ENDIAN 1234
#define __BIG_ENDIAN 4321
#ifdef _BIG_ENDIAN
#define __BYTE_ORDER __BIG_ENDIAN		/* define byte order for SPARC processor */
#else
#define __BYTE_ORDER __LITTLE_ENDIAN		/* define byte order for SPARC processor */
#endif 
#endif /*SOLARIS*/

#ifdef LINUX
#include <endian.h>
#endif /*LINUX*/

#ifdef QNX6
#define __LITTLE_ENDIAN 1234
#define __BIG_ENDIAN 4321
#ifdef __BIGENDIAN__
#define __BYTE_ORDER __BIG_ENDIAN		/* define byte order for SPARC processor */
#else
#define __BYTE_ORDER __LITTLE_ENDIAN		/* define byte order for SPARC processor */
#endif 
#endif /*QNX6*/

#endif /*POSIX*/
#endif /*BYTE_ORDER*/
/*** libraries ***/

#include <stddef.h>
#include <string.h>
#include <assert.h>
#include <time.h>
#include <stdio.h>
#ifdef WIN32
#include <winsock2.h>
#include <windows.h>
#include <jni.h>
#endif
#ifdef QNX4
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <semaphore.h>
#include <netdb.h>
#include <unistd.h>
#endif
#ifdef POSIX
#ifdef LINUX
#include <pthread.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/resource.h>
#include <semaphore.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <math.h>
#endif /*LINUX*/
#ifdef LYNXOS 
#include <unistd.h>
#include <pthread.h>
#include <socket.h>
#include <resource.h>
#include <timers.h>
#include <semaphore.h>
#include <math.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <ieeefp.h>
#endif /*LYNXOS*/
#ifdef SOLARIS 
#include <unistd.h>
#include <pthread.h>
#include <sys/socket.h>
#include <sys/resource.h>
#include <semaphore.h>
#include <math.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <ieeefp.h>
#endif /*SOLARIS*/
#ifdef QNX6
#include <pthread.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <semaphore.h>
#include <netdb.h>
#include <unistd.h>
#endif
#endif /*POSIX */

/*
 * define verify macro - like assert but continue to evaluate and
 * check the argument with the release build
 */
#ifndef NDEBUG
#define verify(v) assert(v)
#else
#define verify(v) do { if(!(v)) abort(); } while(0)
#endif


/*** litterals ***/

#define SIO_PAR                          1           /* sio parameter used with this platform */
#define PRO_PAR                          1           /* pro parameter used with this platform */

/* 
 * infinite (no) timeout special value
 */
#ifndef INFINITE
#define INFINITE                        (-1)
#endif

/* 
 * true/false boolean values
 */
#ifndef FALSE
#define FALSE                            (unsigned char)0
#endif
#ifndef TRUE
#define TRUE                             (unsigned char)1
#endif

/* 
 * flash number in dsa2/dsb2 and extension card
 */
#define FLA_POSITION                     0
#define FLA_CURRENT                      1
#define FLA_EXTENSION                    2

/* 
 * boot mode/operation constants
 */
#define BOO_START_REQ                    1
#define BOO_START_EXEC                   2
#define BOO_MAIN                         3
#define BOO_DWN_REQ                      4
#define BOO_DWN_EXEC                     5
#define BOO_BOOT_MASTER                  6
#define BOO_BOOT_SLAVE                   7


/*
 * real-time objects constants used in rto module
 */

#ifdef QNX4
#define RTO_TYPE_NONE					0
#define RTO_TYPE_EVENT					1
#define RTO_TYPE_AUTO_RESET_EVENT		2
#define RTO_TYPE_SEMAPHORE				3
#define RTO_TYPE_MUTEX					4
#define RTO_TYPE_MAX					5
#define RTO_INVALID_HANDLE				-1
#endif /* QNX4 */

/* 
 * return value of wait functions
 */
#ifdef QNX4
#define WAIT_OBJECT_0 0
#define WAIT_TIMEOUT -1
#endif /* QNX4 */

#ifdef POSIX
#define WAIT_OBJECT_0	0
#define WAIT_TIMEOUT	-1
#define WAIT_FAILED		-2
#endif /*POSIX*/

 /*
 * thread priority levels
 */
#ifdef QNX4
#define THREAD_PRIORITY_IDLE				1
#define THREAD_PRIORITY_LOWEST				8
#define THREAD_PRIORITY_BELOW_NORMAL		9
#define THREAD_PRIORITY_NORMAL				10
#define THREAD_PRIORITY_ABOVE_NORMAL		11
#define THREAD_PRIORITY_HIGHEST				12
#define THREAD_PRIORITY_TIME_CRITICAL		15
#endif /* QNX4 */

#ifdef POSIX
#ifdef LINUX
#define THREAD_PRIORITY_IDLE				20
#define THREAD_PRIORITY_LOWEST				10
#define THREAD_PRIORITY_BELOW_NORMAL		5
#define THREAD_PRIORITY_NORMAL				0
#define THREAD_PRIORITY_ABOVE_NORMAL		-5
#define THREAD_PRIORITY_HIGHEST				-10
#define THREAD_PRIORITY_TIME_CRITICAL		-20
#endif /* LINUX */
#ifdef LYNXOS
#define THREAD_PRIORITY_IDLE				0
#define THREAD_PRIORITY_LOWEST				13
#define THREAD_PRIORITY_BELOW_NORMAL		15
#define THREAD_PRIORITY_NORMAL				17
#define THREAD_PRIORITY_ABOVE_NORMAL		19	
#define THREAD_PRIORITY_HIGHEST				21
#define THREAD_PRIORITY_TIME_CRITICAL		40
#endif /* LYNXOS*/
#ifdef SOLARIS
#define THREAD_PRIORITY_IDLE				127
#define THREAD_PRIORITY_LOWEST				70
#define THREAD_PRIORITY_BELOW_NORMAL		60
#define THREAD_PRIORITY_NORMAL				50
#define THREAD_PRIORITY_ABOVE_NORMAL		40	
#define THREAD_PRIORITY_HIGHEST				30
#define THREAD_PRIORITY_TIME_CRITICAL		0
#endif /* SOLARIS*/
#ifdef QNX6
#define THREAD_PRIORITY_IDLE				1
#define THREAD_PRIORITY_LOWEST				10
#define THREAD_PRIORITY_BELOW_NORMAL		12
#define THREAD_PRIORITY_NORMAL				15
#define THREAD_PRIORITY_ABOVE_NORMAL		18
#define THREAD_PRIORITY_HIGHEST				20
#define THREAD_PRIORITY_TIME_CRITICAL		30
#endif /* QNX4 */
#endif /*POSIX*/

 /* 
 * debug constants - kind of event
 */
#define DBG_KIND_INFORMATION                0x01
#define DBG_KIND_WARNING                    0x02
#define DBG_KIND_ERROR                      0x03
#define DBG_KIND_FATAL_ERROR                0x04
#define DBG_KIND_STREAM_IN                  0x05
#define DBG_KIND_STREAM_OUT                 0x06
#define DBG_KIND_FCT_BEGIN                  0x07
#define DBG_KIND_FCT_END                    0x08
#define DBG_KIND_MEM_ALLOC                  0x09

/* 
 * debug constants - source of event
 */
#define DBG_SOURCE_LIB                      0x01
#define DBG_SOURCE_DMD                      0x02
#define DBG_SOURCE_CAN                      0x03
#define DBG_SOURCE_ETB                      0x04
#define DBG_SOURCE_TRA                      0x05
#define DBG_SOURCE_DSA                      0x06
#define DBG_SOURCE_BUF                      0x07
#define DBG_SOURCE_ETN                      0x10

/* 
 * debug constants - kind of stream
 */
#define DBG_STREAM_COM                      0x01
#define DBG_STREAM_CAN                      0x02
#define DBG_STREAM_TCP                      0x03
#define DBG_STREAM_DSM2                     0x04
#define DBG_STREAM_DSM3                     0x04
#define DBG_STREAM_ISA                      0x05
#define DBG_STREAM_DSTEB                    0x06

/*
 * socket constants for qnx4
 */ 
#ifdef QNX4
#define INVALID_SOCKET						-1
#endif /* QNX4 */

#ifdef POSIX
#define INVALID_SOCKET		-1
#endif /*POSIX*/
/*** types ***/

/*
 * special macro to specifie register static or global variables
 * this macro expand to nothing in standard platform
 */
#define REGISTER

/*
 * monitor
 */
#ifdef WIN32
#define DEFINE_CRITICAL CRITICAL_SECTION monitor;
#endif
#ifdef QNX4
#define DEFINE_CRITICAL sem_t m_sem; int m_counter; pid_t m_pid;
#endif /* QNX4 */
#ifdef POSIX
#if defined MUTEX_STD|| defined MUTEX_FAST
#ifdef MUTEX_STD
#define DEFINE_CRITICAL 	pthread_mutex_t mutex; int m_counter; pid_t m_pid;
#endif /*MUTEX_STD*/
#ifdef MUTEX_FAST 
#define DEFINE_CRITICAL 	pthread_mutex_t mutex; pthread_mutexattr_t attr; 
#endif /*MUTEX_FAST*/
#else
#define DEFINE_CRITICAL 	sem_t m_sem; int m_counter; pid_t m_pid;
#endif
#endif

 /*
 * common types used in all libraries
 * bool is a standard type in C++ only
 */
#ifndef __BYTE
#define __BYTE
typedef unsigned char byte;
#endif
#ifndef __WORD
#define __WORD
typedef unsigned short word;
#endif
#ifndef __DWORD
#define __DWORD
typedef unsigned long dword;
#endif
#ifndef __CHAR_P
#define __CHAR_P
typedef char *char_p;
#endif
#ifndef __CHAR_CP
#define __CHAR_CP
typedef const char *char_cp;
#ifndef __cplusplus
#ifndef __BOOL
#define __BOOL
typedef byte bool;
#endif
#endif
#endif

/*
 * common types used in JNI code
 */
#ifdef WIN32
#ifndef __JNIVM_P
#define __JNIVM_P
typedef JavaVM *jnivm_p;
#endif
#ifndef __JNIENV_P
#define __JNIENV_P
typedef JNIEnv *jnienv_p;
#endif
#endif /* WIN32 */

/*
 * debug buffer entry
 */
typedef struct _dbg_entry {
	char process_name[32];
	long event_id;
	int process_id;
	int process_priority;
	int thread_id;
	int thread_priority;
	double timestamp;
	int event_kind;
	int event_source;
	int event_stream;
	int event_ecode;
	int stream_size;
	byte stream_data[32];
	char fct_name[32];
	char event_msg[64];
} DBG_ENTRY;

/*
 * defered procedure call structure
 */
typedef void (*DPC_FCT)(long param[4]);
typedef struct _dpc_s {
    struct _dpc_s *next;
    DPC_FCT fct;
    long param[4];
} DPC, *DPC_P;

/*
 * timer definition structure
 */
typedef struct _timer_s {
    struct _timer_s *next;
    long reload;
    long time;
    DPC dpc;
} TIMER;

typedef struct _fw_manifest {
	char name[64];
	char version[64];
	char reg_blocks[64];
	char seq_blocks[64];
	char title[64];
} FW_MANIFEST;

typedef struct _directory_entry {
	char name[256];
} DIRECTORY_ENTRY;

/* 
 * types used to define real-time(RT) object in RTO module
 */
#ifdef QNX4
typedef int RTO_HANDLE;
#endif /* QNX4 */

/* 
 * types for net module
 */
#ifdef QNX4
typedef int SOCKET;
typedef struct hostent HOSTENT;
typedef struct sockaddr_in SOCKADDR_IN;
typedef struct sockaddr SOCKADDR;
#endif /* QNX4 */

#ifdef POSIX
#ifdef SOLARIS
#define INADDR_NONE	-1
#endif
typedef int SOCKET;
typedef struct hostent HOSTENT;
typedef struct sockaddr_in SOCKADDR_IN;
typedef struct sockaddr SOCKADDR;
#endif /* POSIX */
/*
 * type modifiers
 */
#ifdef WIN32
#ifndef _LIB_EXPORT
#ifndef  LIB_STATIC
/* @@@ */
/* #define _LIB_EXPORT __declspec(dllimport) __cdecl */    /* function exported by DLL library */
#define _LIB_EXPORT __cdecl    /* function exported by DLL library */
#else
#define _LIB_EXPORT __cdecl                          /* function exported by static library */
#endif
#endif /* _ETB_EXPORT */
#define LIB_CALLBACK __cdecl                         /* client callback function called by library */
#endif /* WIN32 */

#ifdef QNX4
#define _LIB_EXPORT __cdecl
#define LIB_EXPORT __cdecl
#endif /* QNX4 */

#ifdef POSIX
#define _LIB_EXPORT 
#define LIB_EXPORT  
#endif /*POSIX*/

														   /* 
 * hidden structures for library clients
 */
#ifndef SIO
#define SIO void
#endif
#ifndef PRO
#define PRO void
#endif
#ifndef SHM
#define SHM void
#endif

/*** macros ***/

/*
 * macros used to optimize platform with only one serial port
 * the sio parameter could be removes in theses situations
 */
#ifdef SIO_PAR
#define _SIO_P1(p)                       p
#define SIO_P1(p)                        p
#define _SIO_P2(p)                       p,
#define SIO_P2(p)                        p,
#else /* SIO_PAR */
#define _SIO_P1(p)                       void
#define SIO_P1(p)
#define _SIO_P2(p)
#define SIO_P2(p)
#endif /* SIO_PAR */

/*
 * macros used to optimize platform with only one property file
 * the pro parameter could be removes in theses situations
 */
#ifdef PRO_PAR
#define _PRO_P1(p)                       p
#define PRO_P1(p)                        p
#define _PRO_P2(p)                       p,
#define PRO_P2(p)                        p,
#else /* PRO_PAR */
#define _PRO_P1(p)                       void
#define PRO_P1(p)
#define _PRO_P2(p)
#define PRO_P2(p)
#endif /* PRO_PAR */

/*
 * clear the specified structure - utility function
 */
#define CLEAR(s) (memset(&(s), '\0', sizeof(s)))

/* 
 * bit array manipulation
 */
#define BYTE_BITS                        8
#define BIT(w,i)                         (((w) >> (i)) & 1)
#define BIT_ARRAY_SIZE(n)                (((n)+BYTE_BITS-1)/BYTE_BITS)
#define BIT_ARRAY_SET(a, i)              ((a)[(i)/BYTE_BITS]|=(1<<((i)%BYTE_BITS)))
#define BIT_ARRAY_CLR(a, i)              ((a)[(i)/BYTE_BITS]&=~(1<<((i)%BYTE_BITS)))
#define BIT_ARRAY_GET(a, i)              BIT((a)[(i)/BYTE_BITS],(i)%BYTE_BITS)

/*
 * critical sections - used to protect task against others or DPC 
 * when shared variables are used betweed tasks.
 */
#ifdef WIN32
#define CRITICAL struct {DEFINE_CRITICAL}
#define CRITICAL_INIT(ob) do { InitializeCriticalSection(&(ob).monitor); } while(0)
#define CRITICAL_DESTROY(ob) do { DeleteCriticalSection(&(ob).monitor); } while(0)
#define CRITICAL_ENTER(ob) do { EnterCriticalSection(&(ob).monitor); } while(0)
#define CRITICAL_LEAVE(ob) do { LeaveCriticalSection(&(ob).monitor); } while(0)
#endif /* WIN32 */
#ifdef QNX4
#define CRITICAL struct {DEFINE_CRITICAL}
#define CRITICAL_INIT(ob) do { sem_init(&(ob).m_sem, TRUE, 1); (ob).m_counter=0; (ob).m_pid=-1; } while(0)
#define CRITICAL_DESTROY(ob) do { sem_destroy(&(ob).m_sem); } while(0)
#define CRITICAL_ENTER(ob) do { if ((ob).m_pid==getpid()) (ob).m_counter++; \
                                else {sem_wait(&(ob).m_sem); (ob).m_pid=getpid(); (ob).m_counter++;} } while(0)
#define CRITICAL_LEAVE(ob) do { if (--(ob).m_counter==0) { (ob).m_pid=-1; sem_post(&(ob).m_sem);} } while(0)
#endif /* QNX4 */


#ifdef POSIX
#if defined MUTEX_STD || defined MUTEX_FAST
#ifdef MUTEX_STD
#define CRITICAL 		struct {DEFINE_CRITICAL}
#define CRITICAL_INIT(ob)	do { \
							pthread_mutex_init(&((ob).mutex), NULL); \
							(ob).m_counter=0;\
							(ob).m_pid=-1;\
							} while(0)
#define CRITICAL_DESTROY(ob) 	do { \
								pthread_mutex_destroy(&(ob).mutex); \
								} while(0)
#define CRITICAL_ENTER(ob)	do { \
							if ((ob).m_pid==pthread_self()) { \
								(ob).m_counter++; \
							} \
							else { \
								pthread_mutex_lock(&(ob).mutex); \
								(ob).m_pid=pthread_self(); \
								(ob).m_counter++; \
							} \
							} while(0)
#define CRITICAL_LEAVE(ob) 	do { \
							if ((ob).m_pid==pthread_self()) { \
								if (--((ob).m_counter)==0) { \
									(ob).m_pid=-1; \
									pthread_mutex_unlock(&(ob).mutex); \
								} \
							} \
							} while(0)
#endif /*MUTEX_STD*/

#ifdef MUTEX_FAST 
#define CRITICAL 		struct {DEFINE_CRITICAL}
#if defined SOLARISSP5 || defined QNX6
#define CRITICAL_INIT(ob)	do { \
							pthread_mutexattr_init(&((ob).attr)); \
							pthread_mutexattr_settype(&((ob).attr), PTHREAD_MUTEX_RECURSIVE); \
							pthread_mutex_init(&((ob).mutex), &((ob).attr)); \
							} while(0)
#else 
#define CRITICAL_INIT(ob)	do { \
							(ob).attr.__mutexkind = PTHREAD_MUTEX_RECURSIVE_NP; \
							pthread_mutex_init(&((ob).mutex), &((ob).attr)); \
							} while(0)
#endif

#define CRITICAL_DESTROY(ob) 	do { \
								pthread_mutex_destroy(&(ob).mutex); \
								} while(0)
#define CRITICAL_ENTER(ob)	do { \
							pthread_mutex_lock(&((ob).mutex)); \
							} while(0)
#define CRITICAL_LEAVE(ob) 	do { \
							pthread_mutex_unlock(&((ob).mutex)); \
							} while(0)
#endif /*MUTEX_FAST*/
#else

#define CRITICAL 		struct {DEFINE_CRITICAL}
#define CRITICAL_INIT(ob)	do { \
							sem_init (&(ob).m_sem, FALSE, 1); \
							(ob).m_counter=0; \
							(ob).m_pid=-1; \
							} while(0)
#define CRITICAL_DESTROY(ob) 	do { \
								sem_destroy(&(ob).m_sem); \
								} while(0)
#define CRITICAL_ENTER(ob)	do { \
							if ((ob).m_pid==pthread_self()) { \
								(ob).m_counter++; \
							} \
							else { \
								sem_wait(&(ob).m_sem); \
								(ob).m_pid=pthread_self(); \
								(ob).m_counter++; \
							} \
							} while(0)
#define CRITICAL_LEAVE(ob) 	do { \
							if ((ob).m_pid==pthread_self()) { \
								if (--((ob).m_counter)==0) { \
									(ob).m_pid=-1; \
									sem_post(&(ob).m_sem); \
								} \
							} \
							} while(0)
#endif
#endif

/*
 * waiting macro - wait the specified number of milliseconds
 */
#ifdef WIN32
#define SLEEP(time) (Sleep(time))
#endif /* WIN32 */
#ifdef QNX4
#define SLEEP(time) do { rto_sleep(time); } while(0)
#endif /* WIN32 */
#ifdef POSIX
#define SLEEP(time)	 do { special_sleep(time); } while(0)
#endif /*POSIX*/	
 
/*
 * thread macros - use thread in a multi-platform way
 */
#ifdef WIN32
#define THREAD HANDLE
#define THREAD_INVALID ((HANDLE)(-1))
#define THREAD_INIT(thr, fct, arg) do { (thr) = rtx_beginthread((fct), (arg)); } while(0)
#define THREAD_INIT_AND_NAME(thr, name, fct, arg) do { (thr) = rtx_begin_named_thread((name), (fct), (arg)); } while(0)
#define THREAD_SET_PRIORITY(thr, pri) do { SetThreadPriority((thr), (pri)); } while(0)
#define THREAD_GET_PRIORITY(thr) (GetThreadPriority((thr)))
#define THREAD_SET_CURRENT_PRIORITY(pri) do { SetThreadPriority(GetCurrentThread(), (pri)); } while(0)
#define THREAD_GET_CURRENT_PRIORITY() (GetThreadPriority(GetCurrentThread()))
#define THREAD_WAIT(thr, timeout) (WaitForSingleObject((thr), (timeout)))
#define THREAD_GET_CURRENT() (GetCurrentThread())
#define THREAD_GET_CURRENT_ID() (GetCurrentThreadId())
#define THREAD_GET_NAME(thr) (rtx_get_thread_name(thr))
#define PROCESS_GET_CURRENT() (GetCurrentProcess())
#define PROCESS_GET_CURRENT_ID() (GetCurrentProcessId())
#endif /* WIN32 */
#ifdef QNX4
#define THREAD pid_t
#define THREAD_INVALID ((pid_t)(-1))
#define THREAD_INIT(thr, fct, arg) do { (thr) = rto_thread_init((fct), (arg)); } while(0)
#define THREAD_INIT_AND_NAME(thr, name, fct, arg) do { (thr) = rto_thread_init_and_name((name), (fct), (arg)); } while(0)
#define THREAD_SET_PRIORITY(thr, pri) do { rto_set_thread_priority((thr), (pri)); } while(0)
#define THREAD_GET_PRIORITY(thr) (rto_get_thread_priority(thr))
#define THREAD_SET_CURRENT_PRIORITY(pri) do { rto_set_thread_priority(getpid(), (pri)); } while(0)
#define THREAD_GET_CURRENT_PRIORITY() (rto_get_thread_priority(getpid()))
#define THREAD_WAIT(thr, timeout) (rto_thread_wait(thr, timeout))
#define THREAD_GET_CURRENT() (getpid())
#define THREAD_GET_CURRENT_ID() (getpid())
#define THREAD_GET_NAME(thr) (rto_get_thread_name(thr))
#define PROCESS_GET_CURRENT() (rto_get_main_thread_pid())
#define PROCESS_GET_CURRENT_ID() ((int)rto_get_main_thread_pid())
#endif /* QNX4 */

#ifdef POSIX
#define THREAD 			pthread_t
#define THREAD_INVALID 		((pthread_t)(-1))
#define THREAD_INIT(thr,fct,arg) 	do { \
									pthread_create (&thr, NULL, (void*)&fct, arg); \
									}while (0)
#define THREAD_INIT_AND_NAME(thr,name,fct,arg)	do {\
												pthread_create (&thr, NULL, (void*)&fct, arg);\
												}while (0)
#define THREAD_WAIT(thr,timeout) 	(pthread_join (thr, NULL))
//#define THREAD_WAIT(thr,timeout) 	(0)
//pas de timeout
#define THREAD_GET_CURRENT()	(pthread_self())
#define THREAD_GET_CURRENT_ID()	(pthread_self())
#define THREAD_GET_NAME(thr) 	NULL
#define THREAD_SET_PRIORITY(thr,pri) 		(thread_set_prio(thr, pri))
#define THREAD_GET_PRIORITY(thr)			(thread_get_prio(thr))
#define THREAD_SET_CURRENT_PRIORITY(pri)	(thread_set_prio(pthread_self(), pri))
#define THREAD_GET_CURRENT_PRIORITY() 		(thread_get_prio(pthread_self()))
#define PROCESS_GET_CURRENT() 				(getpid())
#define PROCESS_GET_CURRENT_ID() 			(getpid())
#endif /*POSIX*/

/*
 * events macros - create manual event with specified initial state
 */
#ifdef WIN32
#define EVENT HANDLE
#define EVENT_INVALID NULL
#define EVENT_INIT(ev, init) do { (ev) = CreateEvent(NULL, TRUE, (init), NULL); } while(0)
#define EVENT_DESTROY(ev) do { CloseHandle(ev); } while(0)
#define EVENT_SET(ev) do { SetEvent((ev)); } while(0)
#define EVENT_RESET(ev) do { ResetEvent((ev)); } while(0)
#define EVENT_WAIT(ev, timeout) (WaitForSingleObject((ev), (timeout)))
#define IS_VALID_EVENT(ev)	(ev != EVENT_INVALID)
#endif /* WIN32 */
#ifdef QNX4
#define EVENT RTO_HANDLE
#define EVENT_INVALID RTO_INVALID_HANDLE
#define EVENT_INIT(ev, init) rto_create_object(&ev, RTO_TYPE_EVENT, init, 0)
#define EVENT_DESTROY(ev) rto_destroy_object(ev)
#define EVENT_SET(ev) rto_set_event(ev)
#define EVENT_RESET(ev) rto_reset_event(ev)
#define EVENT_WAIT(ev, timeout) rto_wait_for_object(ev, timeout)
#define IS_VALID_EVENT(ev)	(ev != EVENT_INVALID)
#endif /* QNX4 */

#ifdef POSIX
#define DEFINE_EVENT		pthread_mutex_t	mutex; pthread_cond_t cond; int state; int error; int valid;
#define EVENT_INVALID 	NULL
#define EVENT	 		struct {DEFINE_EVENT}
#define EVENT_INIT(ev,init)	do { \
							pthread_cond_init(&(ev).cond, NULL); \
							pthread_mutex_init(&(ev).mutex, NULL); \
							ev.state = init; \
							ev.error = 0; \
							ev.valid = 1; \
							} while(0)
#define EVENT_DESTROY(ev)	do { \
							pthread_mutex_lock(&(ev).mutex); \
							ev.error = WAIT_FAILED; \
							pthread_mutex_unlock(&(ev).mutex); \
							pthread_cond_broadcast(&(ev).cond); \
							pthread_cond_destroy(&(ev).cond); \
							pthread_mutex_destroy(&(ev).mutex); \
							ev.valid = 0; \
							} while (0)
#define EVENT_SET(ev) 		do { \
							pthread_mutex_lock(&(ev).mutex); \
							ev.state = TRUE; \
							pthread_mutex_unlock(&(ev).mutex); \
							pthread_cond_broadcast(&(ev).cond);	\
							} while (0)
#define EVENT_RESET(ev) 	do { \
							pthread_mutex_lock(&(ev).mutex); \
							ev.state = FALSE; \
							pthread_mutex_unlock(&(ev).mutex); \
							} while (0)
#define EVENT_WAIT(ev,timeout)	(event_wait(&(ev.mutex), &(ev.cond), &(ev.state), \
								 &(ev.error), timeout))
#define IS_VALID_EVENT(ev)	(ev.valid == 1)
#endif /*POSIX*/


/*
 * auto events macros - create automatic event with specified initial state
 */
#ifdef WIN32
#define AUTOEVENT HANDLE
#define AUTOEVENT_INVALID NULL
#define AUTOEVENT_INIT(ev, init) do { (ev) = CreateEvent(NULL, FALSE, (init), NULL); } while(0)
#define AUTOEVENT_DESTROY(ev) do { CloseHandle(ev); } while(0)
#define AUTOEVENT_SET(ev) do { SetEvent((ev)); } while(0)
#define AUTOEVENT_RESET(ev) do { ResetEvent((ev)); } while(0)
#define AUTOEVENT_WAIT(ev, timeout) (WaitForSingleObject((ev), (timeout)))
#define IS_VALID_AUTOEVENT(ev)	(ev != AUTOEVENT_INVALID)
#endif /* WIN32 */
#ifdef QNX4
#define AUTOEVENT RTO_HANDLE
#define AUTOEVENT_INVALID RTO_INVALID_HANDLE
#define AUTOEVENT_INIT(ev, init) rto_create_object(&ev, RTO_TYPE_AUTO_RESET_EVENT, init, 0)
#define AUTOEVENT_DESTROY(ev) rto_destroy_object(ev)
#define AUTOEVENT_SET(ev)rto_set_event(ev)
#define AUTOEVENT_RESET(ev) rto_reset_event(ev)
#define AUTOEVENT_WAIT(ev, timeout) rto_wait_for_object(ev, timeout)
#define IS_VALID_AUTOEVENT(ev)	(ev != AUTOEVENT_INVALID)
#endif /* QNX4 */
#ifdef POSIX 
#define DEFINE_AUTOEVENT	pthread_mutex_t	mutex; pthread_cond_t cond; int state; int error; int valid;
#define AUTOEVENT_INVALID	NULL
#define AUTOEVENT	 	struct {DEFINE_AUTOEVENT}
#define AUTOEVENT_INIT(ev,init)	do { \
								pthread_cond_init(&(ev).cond, NULL); \
								pthread_mutex_init(&(ev).mutex, NULL); \
								ev.state = init; \
								ev.error = 0;\
								ev.valid = 1;\
								} while(0)
#define AUTOEVENT_DESTROY(ev)	do{ \
								pthread_mutex_lock(&(ev).mutex); \
								ev.error = WAIT_FAILED; \
								pthread_mutex_unlock(&(ev).mutex); \
								pthread_cond_broadcast(&(ev).cond); \
								pthread_cond_destroy(&(ev).cond); \
								pthread_mutex_destroy(&(ev).mutex);\
								ev.valid = 0; \
								} while (0)
#define AUTOEVENT_SET(ev)	do { \
							pthread_mutex_lock(&(ev).mutex);\
							ev.state = TRUE;\
							pthread_mutex_unlock(&(ev).mutex); \
							pthread_cond_broadcast(&(ev).cond); \
							}while (0)
#define AUTOEVENT_RESET(ev) 	do { \
								pthread_mutex_lock(&(ev).mutex); \
								ev.state = FALSE; \
								pthread_mutex_unlock(&(ev).mutex); \
								} while (0)
#define AUTOEVENT_WAIT(ev,timeout)	(autoevent_wait(&(ev.mutex), &(ev.cond),\
									&(ev.state), &(ev.error), timeout))
#define IS_VALID_AUTOEVENT(ev)	(ev.valid == 1)
#endif

/*
 * mutexes macros - create manual event with specified initial state
 */
#ifdef WIN32
#define MUTEX HANDLE
#define MUTEX_INVALID NULL
#define MUTEX_INIT(ev, init) do { (ev) = CreateMutex(NULL, (init), NULL); } while(0)
#define MUTEX_DESTROY(ev) do { CloseHandle((ev)); } while(0)
#define MUTEX_RELEASE(ev) do { ReleaseMutex((ev)); } while(0)
#define MUTEX_WAIT(ev, timeout) (WaitForSingleObject((ev), (timeout)))
#define IS_VALID_MUTEX(ev)	(ev != MUTEX_INVALID)
#endif /* WIN32 */
#ifdef QNX4
#define MUTEX RTO_HANDLE
#define MUTEX_INVALID RTO_INVALID_HANDLE
#define MUTEX_INIT(ev, init) rto_create_object(&ev, RTO_TYPE_MUTEX, 0, 0)
#define MUTEX_DESTROY(ev) rto_destroy_object(ev)
#define MUTEX_RELEASE(ev) rto_release_object(ev)
#define MUTEX_WAIT(ev, timeout) rto_wait_for_object(ev, timeout)
#define IS_VALID_MUTEX(ev)	(ev != MUTEX_INVALID)
#endif /* QNX4 */
#ifdef POSIX 
#define DEFINE_MUTEX	pthread_mutex_t	mutex; pthread_cond_t cond;  int tid; int counter; int error; int valid;
#define MUTEX_INVALID 	NULL
#define MUTEX			struct {DEFINE_MUTEX}
#define MUTEX_INIT(mut,init)	do { \
								pthread_cond_init(&(mut).cond, NULL); \
								pthread_mutex_init(&(mut).mutex, NULL);	\
								mut.error = 0; \
								if (init) { \
									mut.tid = pthread_self(); \
									mut.counter = 0; \
								} \
								else { \
									mut.tid = -1; \
									mut.counter = 1; \
								} \
								mut.valid = 1; \
								} while(0)
#define MUTEX_DESTROY(mut)		do { \
								pthread_mutex_lock(&(mut).mutex); \
								mut.error = WAIT_FAILED; \
								pthread_mutex_unlock(&(mut).mutex); \
								pthread_cond_broadcast(&(mut).cond); \
								pthread_cond_destroy(&(mut).cond); \
								pthread_mutex_destroy(&(mut).mutex); \
								mut.valid = 0; \
								} while (0)
#define MUTEX_RELEASE(mut)		do { \
								if ((mut).tid==pthread_self()) { \
									pthread_mutex_lock(&(mut).mutex); \
									if (++((mut).counter)==1) { \
										(mut).tid=-1; \
										pthread_mutex_unlock(&(mut).mutex); \
										pthread_cond_signal(&(mut).cond); \
									} \
									else \
										pthread_mutex_unlock(&(mut).mutex); \
								} \
								} while(0)
#define MUTEX_WAIT(mut,timeout)	mutex_wait(&(mut.mutex), &(mut.cond), &(mut.tid), \
				&(mut.counter), &(mut.error), timeout)
#define IS_VALID_MUTEX(mut)	(mut.valid == 1)
#endif /*POSIX*/

/*
 * counting semaphore macros - create semaphore with specified initial and maximum value
 */
#ifdef WIN32
#define SEMACOUNT HANDLE 
#define SEMACOUNT_INVALID NULL
#define SEMACOUNT_INIT(sem, init, max) do { (sem) = CreateSemaphore(NULL, (init), (max), NULL); } while(0)
#define SEMACOUNT_DESTROY(sem) do { CloseHandle(sem); } while(0)
#define SEMACOUNT_RELEASE(sem) do { ReleaseSemaphore((sem), 1, NULL); } while(0)
#define SEMACOUNT_WAIT(sem, timeout) (WaitForSingleObject((sem), (timeout)))
#define IS_VALID_SEMACOUNT(ev)	(ev != SEMACOUNT_INVALID)
#define SET_SEMACOUNT(target, source)	do { memcpy(&target, &source, sizeof(target));} while (0)
#endif /* WIN32 */
#ifdef QNX4
#define SEMACOUNT RTO_HANDLE 
#define SEMACOUNT_INVALID RTO_INVALID_HANDLE
#define SEMACOUNT_INIT(sem, init, max) rto_create_object(&sem, RTO_TYPE_SEMAPHORE, init, max)
#define SEMACOUNT_DESTROY(sem) rto_destroy_object(sem)
#define SEMACOUNT_RELEASE(sem) rto_release_object(sem)
#define SEMACOUNT_WAIT(sem, timeout) rto_wait_for_object(sem, timeout)
#define IS_VALID_SEMACOUNT(ev)	(ev != SEMACOUNT_INVALID)
#define SET_SEMACOUNT(target, source)	do { memcpy(&target, &source, sizeof(target));} while (0)
#endif /* QNX4 */
#ifdef POSIX 
#define DEFINE_SEMACOUNT	pthread_mutex_t	mutex; pthread_cond_t cond; int counter; \
							int error; int max_count; int valid;
#define SEMACOUNT_INVALID 	NULL
#define SEMACOUNT			struct {DEFINE_SEMACOUNT}
#define SEMACOUNT_INIT(sema,init,max_count_val)	do { \
												pthread_cond_init(&(sema).cond, NULL); \
												pthread_mutex_init(&(sema).mutex, NULL); \
												sema.counter = init; \
												sema.max_count = max_count_val; \
												sema.error = 0;\
												sema.valid = 1;\
												} while(0)
#define SEMACOUNT_DESTROY(sema)	do { \
								pthread_mutex_lock(&(sema).mutex); \
								sema.error = WAIT_FAILED; \
								pthread_mutex_unlock(&(sema).mutex); \
								pthread_cond_broadcast(&(sema).cond); \
								pthread_cond_destroy(&(sema).cond); \
								pthread_mutex_destroy(&(sema).mutex); \
								sema.valid = 0; \
								} while (0)
#define SEMACOUNT_RELEASE(sema)	do { \
								pthread_mutex_lock(&(sema).mutex); \
								if (++((sema).counter) > sema.max_count) \
									sema.counter = sema.max_count; \
								pthread_mutex_unlock(&(sema).mutex); \
								pthread_cond_signal(&(sema).cond); \
								} while(0)
#define SEMACOUNT_WAIT(sema,timeout)	sema_wait(&(sema.mutex), &(sema.cond), \
										&(sema.counter), &(sema.error), timeout)
#define IS_VALID_SEMACOUNT(sema)	(sema.valid == 1)
#define SET_SEMACOUNT(target, source)	(memcpy(&target, &source, sizeof(target)))
#endif /*POSIX*/

/*
 * thread local storage macros
 */
#ifdef WIN32
#define TLS_ALLOC(idx) ((idx = TlsAlloc()) == 0xFFFFFFFF)
#define TLS_FREE(idx) (!TlsFree(idx))
#define TLS_SET_VALUE(idx, val) (!TlsSetValue(idx, val))
#define TLS_GET_VALUE(idx) (TlsGetValue(idx))
#endif /* WIN32 */
#ifdef QNX4
#define TLS_ALLOC(idx) (tls_alloc(&idx))
#define TLS_FREE(idx) (tls_free(idx))
#define TLS_SET_VALUE(idx, val) (tls_set_value(idx, val))
#define TLS_GET_VALUE(idx) (tls_get_value(idx))
#endif /* QNX4 */

#ifdef POSIX 
#define TLS_ALLOC(idx) 			(pthread_key_create((pthread_key_t*)&idx, NULL))
#define TLS_FREE(idx) 			(pthread_key_delete((pthread_key_t)idx))
#define TLS_SET_VALUE(idx, val) (pthread_setspecific((pthread_key_t)idx, (void*)val))
#define TLS_GET_VALUE(idx) 		(pthread_getspecific((pthread_key_t)idx))
#endif /*POSIX*/


/*
 * Yield function implementation
 */
#ifdef WIN32
#define YIELD() do {Sleep(1);} while(0)
#endif /* WIN32 */
#ifdef QNX4
#define YIELD() Yield()
#endif /* QNX4 */
#ifdef POSIX 
#ifdef LINUX
#define YIELD()		(usleep(1))
#endif /*LINUX*/
#if defined LYNXOS || defined SOLARIS || defined QNX6
#define YIELD()		(sched_yield())
#endif  /*LYNXOS || SOLARIS*/
#endif /*POSIX*/

/* 
 * fifo macro - put/get/extract a message in/form a first in first out queue.
 * a valid fifo queue is a structure who defines 'first' 
 * and 'last' pointer to a message.
 * a valid message is a structure which define a 'next' pointer
 */
#define FIFO_EXTRACT(queue, msg, lmsg)										\
	do {																	\
        if(lmsg) {															\
            if((msg) = (lmsg)->next)										\
                if(!((lmsg)->next = (msg)->next)) (queue).last = lmsg;      \
        } else {															\
            if((msg) = (queue).first)										\
                if(!((queue).first = (msg)->next))(queue).last = NULL;      \
        }                                             \
    } while(0)
#define FIFO_GET(queue, msg)                    \
    do {                                        \
        if((msg) = (queue).first) {             \
            if(!((queue).first = (msg)->next))  \
                (queue).last = NULL;            \
            (msg)->next = NULL;                 \
        }                                       \
    } while(0)
#define FIFO_PUT(queue, msg)                          \
    do {                                              \
        (msg)->next = NULL;                           \
        if(!(queue).first) {                          \
            (queue).first = (msg);                    \
            (queue).last = (msg);                     \
        } else {                                      \
            (queue).last->next = (msg);               \
            queue.last = (msg);                       \
        }                                             \
    } while(0)
#define FIFO_INS(queue, msg)                          \
    do {                                              \
        if(!(queue).first) {                          \
            (msg)->next = NULL;                       \
            (queue).first = (msg);                    \
            (queue).last = (msg);                     \
        } else {                                      \
            (msg)->next = (queue).first;              \
            (queue).first = (msg);                    \
        }                                             \
    } while(0)

/* 
 * lifo macro - put/get/extract a message in/form a last in first out queue.
 * a valid lifo queue is a structure who defines 'first' pointer to a message.
 * a valid message is a structure which define a 'next' pointer
 */
#define LIFO_GET(queue, msg)                          \
    do {                                              \
        if((msg) = (queue).first) {                   \
            (queue).first = (msg)->next;              \
            (msg)->next = NULL;                       \
        }                                             \
    } while(0)
#define LIFO_PUT(queue, msg)                          \
    do {                                              \
        (msg)->next = (queue).first;                  \
        (queue).first = (msg);                        \
    } while(0)


#define MAX(A, B)   ((A) > (B) ? (A) : (B)) 
#define MIN(A, B)   ((A) < (B) ? (A) : (B)) 
#define ONEBIT(A)   ((A) && !((A) & ((A)-1))) 


/*** functions ***/

/* 
 * QNX math functions
 */
#ifdef QNX4
#define _isnan(d) ((((dword*)&d)[1] & 0x7FF00000) == 0x7FF00000 && (((dword*)&d)[0] != 0 || (((dword*)&d)[1] & 0x000FFFFF) != 0))
#define _finite(d) (!(((dword*)&d)[0] == 0 && (((dword*)&d)[1] & 0x7FFFFFFF) == 0x7FF00000) && !_isnan(d))
#endif /* QNX4 */
#ifdef POSIX 
#define _isnan(d) 	(isnan(d))
#define _finite(d) 	(finite(d))
#endif /*POSIX*/

/*
 * libini - initialize libraries
 */
#ifdef WIN32
#define lib_init() do { tim_init(); dpc_init(); } while(0)
#endif

/*
 * libver.c
 */
time_t  _LIB_EXPORT lib_get_build_time(void);
dword   _LIB_EXPORT lib_get_version(void);
dword   _LIB_EXPORT lib_get_edi_version(void);
void    _LIB_EXPORT lib_get_library_path(char *buf, int size);
void    _LIB_EXPORT lib_get_library_dir(char *buf, int size);

/*
 * libtim.c
 */
long    _LIB_EXPORT tim_counter(void);
double  _LIB_EXPORT tim_dbl_counter(void);
void    _LIB_EXPORT tim_init(void);
int     _LIB_EXPORT tim_add(TIMER *tr);
int     _LIB_EXPORT tim_remove(TIMER *tr);
#ifdef EXT296
void    _LIB_EXPORT tim_sleep(long msec);
#endif
#define tim_diff

/*
 * libdbg - functions currently defined as macros
 */
void    _LIB_EXPORT dbg_init(void);
void    _LIB_EXPORT dbg_reset(void);
void    _LIB_EXPORT dbg_set_kind_mask(dword mask);
dword   _LIB_EXPORT dbg_get_kind_mask(void);
void    _LIB_EXPORT dbg_set_source_mask(dword mask);
dword   _LIB_EXPORT dbg_get_source_mask(void);
void    _LIB_EXPORT dbg_set_stream_mask(dword mask);
dword   _LIB_EXPORT dbg_get_stream_mask(void);
int     _LIB_EXPORT dbg_get_entry_size(void);
int     _LIB_EXPORT dbg_get_entry_number(void);
int		_LIB_EXPORT dbg_get_entry_count(void);
void    _LIB_EXPORT dbg_fetch_data(DBG_ENTRY *buffer);
int		_LIB_EXPORT dbg_fetch_last_data(DBG_ENTRY *buffer, int *entry_count);
void    _LIB_EXPORT dbg_put_im(int source, const char *fct, const char *msg, ...);
void    _LIB_EXPORT dbg_put_wm(int source, const char *fct, const char *msg, ...);
void    _LIB_EXPORT dbg_put_em(int source, const char *fct, const char *msg, int ecode, ...);
void    _LIB_EXPORT dbg_put_fm(int source, const char *fct, const char *msg, int ecode, ...);
void    _LIB_EXPORT dbg_put_is(int source, const char *fct, const char *msg, int stream, const char *buffer, size_t size, ...);
void    _LIB_EXPORT dbg_put_os(int source, const char *fct, const char *msg, int stream, const char *buffer, size_t size, ...);
void    _LIB_EXPORT dbg_put_bf(int source, const char *fct, const char *msg, ...);
void    _LIB_EXPORT dbg_put_ef(int source, const char *fct, const char *msg, int ecode, ...);
void    _LIB_EXPORT dbg_put_mm(const char *fct, const char *msg, ...);
void    _LIB_EXPORT putlog(const char *format, ...);

#ifdef QNX4
void    _LIB_EXPORT dbg_put_im(int source, const char *fct, const char *msg, ...);
void    _LIB_EXPORT dbg_put_bf(int source, const char *fct, const char *msg, ...);
void    _LIB_EXPORT dbg_put_ef(int source, const char *fct, const char *msg, int ecode, ...);
#endif /* QNX4 */

#ifdef WIN32
#ifndef NDEBUG
#define DBG_PUT_IM dbg_put_im
#define DBG_PUT_WM dbg_put_wm
#define DBG_PUT_EM dbg_put_em
#define DBG_PUT_FM dbg_put_fm
#define DBG_PUT_IS dbg_put_is
#define DBG_PUT_OS dbg_put_os
#define DBG_PUT_BF dbg_put_bf
#define DBG_PUT_EF dbg_put_ef
#else /* DEBUG */
#define DBG_PUT_IM
#define DBG_PUT_WM
#define DBG_PUT_EM
#define DBG_PUT_FM
#define DBG_PUT_IS
#define DBG_PUT_OS
#define DBG_PUT_BF
#define DBG_PUT_EF
#endif /* DEBUG */
#endif /* WIN32 */

#ifdef QNX4
#pragma disable_message (111)
#ifndef NDEBUG
#define DBG_PUT_IM dbg_put_im
#define DBG_PUT_WM dbg_put_wm
#define DBG_PUT_EM dbg_put_em
#define DBG_PUT_FM dbg_put_fm
#define DBG_PUT_IS dbg_put_is
#define DBG_PUT_OS dbg_put_os
#define DBG_PUT_BF dbg_put_bf
#define DBG_PUT_EF dbg_put_ef
#else /* DEBUG */
#define DBG_PUT_IM
#define DBG_PUT_WM
#define DBG_PUT_EM
#define DBG_PUT_FM
#define DBG_PUT_IS
#define DBG_PUT_OS
#define DBG_PUT_BF
#define DBG_PUT_EF
#endif /* DEBUG */
#endif /* QNX4 */

#ifdef POSIX
#ifndef NDEBUG
#define DBG_PUT_IM dbg_put_im
#define DBG_PUT_WM dbg_put_wm
#define DBG_PUT_EM dbg_put_em
#define DBG_PUT_FM dbg_put_fm
#define DBG_PUT_IS dbg_put_is
#define DBG_PUT_OS dbg_put_os
#define DBG_PUT_BF dbg_put_bf
#define DBG_PUT_EF dbg_put_ef
#else /* DEBUG */
#define DBG_PUT_IM
#define DBG_PUT_WM
#define DBG_PUT_EM
#define DBG_PUT_FM
#define DBG_PUT_IS
#define DBG_PUT_OS
#define DBG_PUT_BF
#define DBG_PUT_EF
#endif /* DEBUG */
#endif /* POSIX */

#ifdef NDEBUG
#define dbg_raise(bit)
#define dbg_lower(bit)
#define dbg_toggle(bit)
#define dbg_trace
#else /* NDEBUG */
#define dbg_raise(bit) pio_or_output(1<<(bit))
#define dbg_lower(bit) pio_and_output(~(1<<(bit)))
#define dbg_toggle(bit) pio_xor_output(1<<(bit))
#define dbg_trace printf
#endif /* NDEBUG */

/*
 * Base functions to handle memory allocation.
 */
void * _LIB_EXPORT mem_malloc(size_t size);
void * _LIB_EXPORT mem_calloc(size_t num, size_t size);
void * _LIB_EXPORT mem_realloc(void *memblock, size_t size);
void   _LIB_EXPORT mem_free(void *memblock);
bool   _LIB_EXPORT mem_is_valid_heap_pointer(void *ptr);

#ifdef WIN32
#ifdef NDEBUG
#define MALLOC(size)			malloc(size)
#define CALLOC(num, size)		calloc(num, size)
#define REALLOC(memblock, size) realloc(memblock, size)
#define FREE(membloc)			free(membloc)
#else /* NDEBUG */
#define MALLOC(size)			mem_malloc(size)
#define CALLOC(num, size)		mem_calloc(num, size)
#define REALLOC(memblock, size) mem_realloc(memblock, size)
#define FREE(membloc)			mem_free(membloc)
#endif /* NDEBUG */
#endif /* WIN32 */

#ifdef QNX4
#ifdef NDEBUG
#define MALLOC(size)			malloc(size)
#define CALLOC(num, size)		calloc(num, size)
#define REALLOC(memblock, size) realloc(memblock, size)
#define FREE(membloc)			free(membloc)
#else /* NDEBUG */
#define MALLOC(size)			malloc(size)
#define CALLOC(num, size)		calloc(num, size)
#define REALLOC(memblock, size) realloc(memblock, size)
#define FREE(membloc)			free(membloc)
#endif /* NDEBUG */
#endif /* QNX4 */

#ifdef POSIX
#ifdef NDEBUG
#define MALLOC(size)			malloc(size)
#define CALLOC(num, size)		calloc(num, size)
#define REALLOC(memblock, size) 	realloc(memblock, size)
#define FREE(membloc)			free(membloc)
#else /* NDEBUG */
#define MALLOC(size)			malloc(size)
#define CALLOC(num, size)		calloc(num, size)
#define REALLOC(memblock, size) 	realloc(memblock, size)
#define FREE(membloc)			free(membloc)
#endif /* NDEBUG */
#endif /* POSIX */

/*
 * libtim.c
 */

#ifdef POSIX
void _LIB_EXPORT special_sleep(long time);
#endif

/*
 * libsio.c
 */
int     _LIB_EXPORT sio_open(SIO **sio, char_cp drv);
void    _LIB_EXPORT sio_close(SIO **sio);
int     _LIB_EXPORT sio_c_putch(SIO *sio, int c);
int     _LIB_EXPORT sio_c_getch(SIO *sio);
int     _LIB_EXPORT sio_putch(SIO *sio, int c);
int     _LIB_EXPORT sio_getch(SIO *sio);
int     _LIB_EXPORT sio_putb(SIO *sio, char_cp buffer, size_t size, long timeout);
int     _LIB_EXPORT sio_getb(SIO *sio, char_p buffer, size_t size, long timeout);
int		_LIB_EXPORT sio_purge(SIO *sio);

/*
 * libpro.c
 */

int     _LIB_EXPORT pro_create(PRO **rpro);
int     _LIB_EXPORT pro_destroy(PRO **rpro);
int     _LIB_EXPORT pro_open_f(PRO *pro, char_cp fn);
int     _LIB_EXPORT pro_open_s(PRO *pro, char_cp host, short port);
int     _LIB_EXPORT pro_send_sh(PRO *pro, SOCKET sock);
char_cp _LIB_EXPORT pro_get_next(PRO *pro, char_cp name);
char_cp _LIB_EXPORT pro_get_string(PRO *pro, char_cp name, char_cp def);
int     _LIB_EXPORT pro_get_int(PRO *pro, char_cp name, int def);
long    _LIB_EXPORT pro_get_long(PRO *pro, char_cp name, long def);
double  _LIB_EXPORT pro_get_double(PRO *pro, char_cp name, double def);
int     _LIB_EXPORT pro_add_property(PRO *pro, char_cp name);
int     _LIB_EXPORT pro_add_string(PRO *pro, char_cp name, char_cp str);
int     _LIB_EXPORT pro_c_add_string(PRO *pro, char_cp name, char_cp str, char_cp def);
int     _LIB_EXPORT pro_add_int(PRO *pro, char_cp name, int val);
int     _LIB_EXPORT pro_c_add_int(PRO *pro, char_cp name, int val, int def);
int     _LIB_EXPORT pro_add_long(PRO *pro, char_cp name, long val);
int     _LIB_EXPORT pro_c_add_long(PRO *pro, char_cp name, long val, long def);
int     _LIB_EXPORT pro_add_double(PRO *pro, char_cp name, double val);
int     _LIB_EXPORT pro_c_add_double(PRO *pro, char_cp name, double val, double def);
int     _LIB_EXPORT pro_erase(PRO *pro);
int     _LIB_EXPORT pro_commit(PRO *pro);


/*
 * libfla.c
 */
dword   _LIB_EXPORT fla_size(int block);
dword   _LIB_EXPORT fla_block(const void *adr, int bl, long *off);

/*
 * libcrc.c
 */
word    _LIB_EXPORT crc16_update(word crc, word c);

/*
 * libdpc.c
 */
void    _LIB_EXPORT dpc_init(void);
int     _LIB_EXPORT dpc_add(void (*fct)(long param[4]), long param[], int siz);
DPC_P   _LIB_EXPORT dpc_find(void (*fct)(long param[4]));

/*
 * librto.c
 */
#ifdef QNX4
int		_LIB_EXPORT rto_manager_main(void);
int		_LIB_EXPORT rto_create_object(RTO_HANDLE *obj, dword rto_type, dword init_state, dword limit);
int		_LIB_EXPORT rto_destroy_object(RTO_HANDLE obj);
int		_LIB_EXPORT rto_wait_for_object(RTO_HANDLE obj, dword timeout);
int		_LIB_EXPORT rto_release_object(RTO_HANDLE obj);
int		_LIB_EXPORT rto_set_event(RTO_HANDLE obj);
int		_LIB_EXPORT rto_reset_event(RTO_HANDLE obj);
int		_LIB_EXPORT rto_sleep(dword msec);
pid_t	_LIB_EXPORT rto_thread_init(void (* fuct)(void *), void *param);
pid_t   _LIB_EXPORT rto_thread_init_and_name(const char *name, void (* func)(void *), void *param);
pid_t	_LIB_EXPORT rto_get_main_thread_pid(void);
int		_LIB_EXPORT rto_thread_wait(pid_t pid, dword timeout);
int		_LIB_EXPORT rto_set_thread_priority(pid_t pis, int priority);
int		_LIB_EXPORT rto_get_thread_priority(pid_t pid);
char_cp _LIB_EXPORT rto_get_thread_name(pid_t pid);
#endif /* QNX4 */

/*
 * libtls.c
 */
#ifdef QNX4
int		_LIB_EXPORT tls_alloc(dword *tls_index);
int		_LIB_EXPORT tls_free(dword tls_index);
int		_LIB_EXPORT tls_set_value(dword tls_index, void *value);
void *	_LIB_EXPORT tls_get_value(dword tls_index);
#endif /* QNX4 */

/*
 * librtx.c
 */
#ifdef WIN32
THREAD  _LIB_EXPORT rtx_beginthread(int (*fct)(void *param), void *param);
THREAD  _LIB_EXPORT rtx_begin_named_thread(const char *name, int (*fct)(void *param), void *param);
char_cp _LIB_EXPORT rtx_get_thread_name(THREAD thread);
#endif /* WIN32 */

/*
 * libnet.c
 */
int _LIB_EXPORT		net_init(void);
int _LIB_EXPORT		net_recv(SOCKET s, char *buf, int len, int flags);
int _LIB_EXPORT		net_recvfrom(SOCKET s, char *buf, int len, int flags, struct sockaddr *from, int *fromlen);
int _LIB_EXPORT		net_send(SOCKET s, char *buf, int len, int flags);
int _LIB_EXPORT		net_sendto(SOCKET s, char *buf, int len, int flags, const struct sockaddr *to, int tolen);
int _LIB_EXPORT		net_socket(int af, int type, int protocol);
int _LIB_EXPORT		net_connect(SOCKET s, const struct sockaddr *name, int namelen);
int _LIB_EXPORT		net_close(SOCKET s);
int _LIB_EXPORT		net_listen(SOCKET s, int backlog);
int _LIB_EXPORT		net_accept(SOCKET s, struct sockaddr *addr, int *addrlen);
int _LIB_EXPORT		net_bind(SOCKET s, const struct sockaddr *name, int namelen);
int _LIB_EXPORT		net_setsockopt(SOCKET s, int level, int optname, const char *optval, int optlen);
int _LIB_EXPORT		net_getsockopt(SOCKET s, int level, int optname, char *optval, int *optlen);
int _LIB_EXPORT		net_select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, const struct timeval *timeout);
HOSTENT * _LIB_EXPORT net_gethostbyname(const char* name);
int _LIB_EXPORT net_gethostname(char* name, int size);
unsigned long _LIB_EXPORT net_inet_addr(const char* cp);
u_short _LIB_EXPORT net_ntohs(u_short netshort);
u_long  _LIB_EXPORT net_ntohl(u_long netlong);
u_short _LIB_EXPORT net_htons(u_short hostshort);
u_long  _LIB_EXPORT net_htonl(u_long hostlong);
#ifdef WIN32
int _LIB_EXPORT net_wsa_fd_is_set(SOCKET s, fd_set FAR *fd);
#define __WSAFDIsSet net_wsa_fd_is_set
#endif /* WIN32 */

/*
 * libjni.c
 */
#ifdef WIN32
void    _LIB_EXPORT jni_set_vm(jnivm_p);
jnivm_p _LIB_EXPORT jni_get_vm(void);
jnienv_p _LIB_EXPORT jni_get_env(void);
void    _LIB_EXPORT jni_detach(void);
jobject _LIB_EXPORT jni_create_object(jnienv_p env, const char *name, const char *sig, ...);
void    _LIB_EXPORT jni_out_of_memory_error(jnienv_p env, const char *s);
void    _LIB_EXPORT jni_illegal_argument_exception(jnienv_p env, const char *s);
void    _LIB_EXPORT jni_illegal_state_exception(jnienv_p env, const char *s);
#endif /* WIN32 */

/*
 * libshm.c
 */
int _LIB_EXPORT shm_create(SHM **shm_obj, char *name, dword size);
int _LIB_EXPORT shm_destroy(SHM *shm_obj);
int _LIB_EXPORT shm_map(SHM *shm_obj, void **addr);
int _LIB_EXPORT shm_unmap(SHM *shm_obj, void *addr);
int _LIB_EXPORT shm_exist(char *name, int size);

/*
 * libprio.c
 */
#ifdef POSIX
int _LIB_EXPORT thread_get_prio(pthread_t thr);
void _LIB_EXPORT thread_set_prio(pthread_t thr, int prio);
#endif /* POSIX */

/*
 * libwait.c
 */
#ifdef POSIX
int _LIB_EXPORT event_wait (pthread_mutex_t *mutex, pthread_cond_t *cond, int *state, int *error, int timeout);
int _LIB_EXPORT autoevent_wait (pthread_mutex_t *mutex, pthread_cond_t *cond, int *state, int *error, int timeout);
int _LIB_EXPORT mutex_wait (pthread_mutex_t *mutex, pthread_cond_t *cond, int *tid, int *counter, int *error, int timeout);
int _LIB_EXPORT sema_wait (pthread_mutex_t *mutex, pthread_cond_t *cond, int *counter, int *error, int timeout);
#endif /* POSIX */

/*
 * libpar.c
 */
#ifdef POSIX
#ifdef LYNXOS
void LIB_EXPORT par_set_pin(int pin);
void LIB_EXPORT par_reset_pin(int pin);
#endif
#endif


/*
 * libzip.c
 */

int _LIB_EXPORT zip_fw_unzip(char *zipFile, char *extractDir);
int _LIB_EXPORT zip_fw_get_manifest (char *extractDir, FW_MANIFEST *fw_manifest);


/*
 * libdir.c
 */
int _LIB_EXPORT dir_find_first_file (char *dirName, DIRECTORY_ENTRY *entry);
int _LIB_EXPORT dir_find_next_file (DIRECTORY_ENTRY *entry);
char* _LIB_EXPORT dir_tmpname();
int _LIB_EXPORT dir_remove(char *dirName);

/*
 * liberr.c
 */
#define CREATE_EDI_ERROR(fctName,errorNr,errorText,comment,axisMask,recNr,cmd,typ1,typ2,par1,par2,timeout) \
	do {\
		lib_create_error(__FILE__, __LINE__, fctName,errorNr,errorText,comment,axisMask,recNr,cmd,typ1,typ2,par1,par2,timeout); \
	} while(0)
#define ADD_EDI_TRACE(fctName,comment) \
	do {\
		lib_add_error_trace(__FILE__, __LINE__, fctName,comment); \
	} while(0)
#define TRACE_OFF() \
	do {\
		lib_trace_off(); \
	} while(0)
#define TRACE_ON() \
	do {\
		lib_trace_on(); \
	} while(0)
								 
int _LIB_EXPORT lib_create_error(char *file,
								 int line,
								 char *fctName,
								 int errorNr,
								 const char *errorText,
								 char *comment,
								 dword axisMask,
								 int recNr,
								 int cmd,
								 int typ1,
								 int typ2,
								 dword par1,
								 dword par2,
								 int timeout);
int _LIB_EXPORT lib_add_error_trace(char *file,
									int line,
									char *fctName,
									char *comment);
int _LIB_EXPORT lib_trace_off();
int _LIB_EXPORT lib_trace_on();
char* _LIB_EXPORT lib_get_edi_error_text(int size, char *str);
#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* _LIB10_H */
