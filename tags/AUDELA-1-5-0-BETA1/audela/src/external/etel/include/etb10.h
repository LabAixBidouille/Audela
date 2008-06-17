/*
 * etb10.h 1.00
 *
 * Copyright (c) 1997-2005 ETEL SA. All Rights Reserved.
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
 * This header file contains public declaration for etel-bus library.\n
 * This library contains all drivers to access to the hardware.\n
 * This library is responsible of the communication protocol.\n
 * This library is conformed to POSIX 1003.1c, and has been ported on the following OS:
 * @li @c WIN32
 * @li @c QNX4
 * @li @c QNX6
 * @li @c LINUX
 * @li @c LYNXOS
 * @li @c SOLARIS SPARC 5
 * @li @c SOLARIS X86
 * @file etb10.h
 */


#ifndef _ETB10_H
#define _ETB10_H

#ifdef __WIN32__		/* defined by Borland C++ Builder */
#ifndef WIN32
#define WIN32
#endif
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
#endif/*BYTE_ORDER*/

#ifdef __cplusplus
#ifdef ETEL_OO_API		/* defined by the user when he need the Object Oriented interface */
#define ETB_OO_API
#endif
#endif 

#if defined ETB_OO_API && defined _DSA20_H
#error dsa20.h must be included AFTER etb10.h
#endif

#ifdef __cplusplus
extern "C" {
#endif


/*** libraries ***/

#include <time.h>


/*** litterals ***/

#undef ERROR
#define ETB_DRIVES                       32           /* the maximum number of drives in a bus */
#define ETB_SERVERS                      4            /* the maximum number of servers in the path */


/*
 * error codes - c
 */
#ifndef ETB_OO_API
#define ETB_EBAUDRATE                    -292        /**< matching baudrate not found */
#define ETB_EFPGAFILENOTFOUND            -291        /**< FPGA file is not found in path */
#define ETB_EUNAVAILABLE                 -290        /**< function not available for the driver */
#define ETB_EGPIODEV                     -286        /**< cannot open the gpio device */
#define ETB_EFLASHNOTLOCKED              -285        /**< flash not locked */
#define ETB_EFLASHPROTECTED              -284        /**< flash protected */
#define ETB_EFLASHWRITE                  -283        /**< unable to write flash */
#define ETB_EFLASHREAD                   -282        /**< unable to read flash */
#define ETB_EFLASHINFO                   -281        /**< unable to read flash information */
#define ETB_EFLASHDEV                    -280        /**< unable to open flash device */
#define ETB_EBADOS                       -270        /**< function unavilable on actual OS */
#define ETB_EBOOTPROG                    -263        /**< bad block programming */
#define ETB_EBOOTHEADER                  -262        /**< bad header in boot protocol */
#define ETB_EBOOTENTER                   -261        /**< cannot enter in boot mode */
#define ETB_EBOOTPASSWD                  -260        /**< bad password when enter in boot mode */
#define ETB_EBADHOST                     -253        /**< the specified host address cannot be translated */
#define ETB_ENETWORK                     -252        /**< network problem */
#define ETB_ESOCKRESET                   -251        /**< the socket connection has been broken by peer */
#define ETB_EOPENSOCK                    -250        /**< the specified socket connection cannot be opened */
#define ETB_ECHECKSUM                    -249        /**< checksum error with serial communication */
#define ETB_EOPENCOM                     -240        /**< the specified communication port cannot be opened */
#define ETB_ECRC                         -230        /**< a CRC error has occured */
#define ETB_EBOOTFAILED                  -229        /**< a problem has occured while communicating with the boot */
#define ETB_EBADMODE                     -225        /**< the drive is in a bad mode */
#define ETB_EBADSERVER                   -224        /**< a bad/incompatible server was found */
#define ETB_ESERVER                      -223        /**< the server has incorrect behavior */
#define ETB_EBADSTATE                    -222        /**< this operation is not allowed in this state */
#define ETB_EBUSRESET                    -221        /**< the underlaying etel-bus in performing a reset operation */
#define ETB_EBUSERROR                    -220        /**< the underlaying etel-bus is in error state */
#define ETB_EBADMSG                      -219        /**< a bad message is given */
#define ETB_EBADDRVVER                   -218        /**< a drive with a version < 3.00 has been detected */
#define ETB_EBADLIBRARY                  -217        /**< a bad/incompatible library was found */
#define ETB_ENOLIBRARY                   -216        /**< a requested library is not found */
#define ETB_EBADPARAM                    -215        /**< one of the parameter is not valid */
#define ETB_ENODRIVE                     -214        /**< the specified drive does not respond */
#define ETB_EMASTER                      -213        /**< cannot enter or quit master mode */
#define ETB_EINTERNAL                    -212        /**< some internal error in the etel software */
#define ETB_ESYSTEM                      -211        /**< some system resource return an error */
#define ETB_ETIMEOUT                     -210        /**< a timeout has occured */
#define ETB_EBADFIRMWARE                 -200        /**< file is not a firmware file */

#endif /* ETB_OO_API */

/*
 * timeout special values
 */
#ifndef INFINITE
#define INFINITE                         0xFFFFFFFF  /* infinite timeout */
#endif
#ifndef ETB_OO_API
#define ETB_DEF_TIMEOUT                  (-2L)       /* use the default timeout appropriate for this communication */
#endif /* ETB_OO_API */

/*
 * open/reset/close flags
 */
#ifndef ETB_OO_API
#define ETB_FLAG_BOOT_RUN                0x00000001  /* assumes that the drive is in run mode */
#define ETB_FLAG_BOOT_DIRECT             0x00000002  /* assumes that the drive is in boot mode */
#define ETB_FLAG_BOOT_BRIDGE             0x00000004  /* assumes that the drive is in boot bridge mode */

#define ETB_FLAG_MASTER_BRIDGE           0x00000010  /* enter master if an axis 0 is connected */
#define ETB_FLAG_MASTER_EXIT             0x00000020  /* return to slave mode if the axis 0 is in master mode */
#define ETB_FLAG_MASTER_NORMAL           0x00000040  /* enter master mas.0=1 if an axis 0 is connected */
#define ETB_FLAG_MASTER_SPY              0x00000080  /* enter master mas.!=255 */

#define ETB_FLAG_TIMEOUT_GUARDED         0x00000100  /* check for continous connection in both pc and drive side */
#define ETB_FLAG_TIMEOUT_DEBUG           0x00000200  /* allows disconnection of the communication - try to recover */
#define ETB_FLAG_TIMEOUT_DISABLE         0x00000400  /* disable all timeouts on the drive side - try to recover */

#define ETB_FLAG_STATUS_POLL             0x00001000  /* continuously send status drive status requests */
#define ETB_FLAG_STATUS_OFF              0x00002000  /* don't send drive status requests */
#define ETB_FLAG_STATUS_IRQ              0x00004000  /* use drive interrupt to poll status */
#define ETB_FLAG_DETECT_OFF              0x00008000  /* don't send any traffics wihtout requests */

#define ETB_FLAG_CAN_STANDARD            0x00100000  /* use CAN standard 11 bit identifiers */
#define ETB_FLAG_CAN_EXTENDED            0x00200000  /* use CAN extended 29 bit identifiers */

/* These flags are for ETEL advanced users only */
#define ETB_FLAG_SYNCHRO_OFF             0x01000000  /* communication detection and bus synchronization offline */
#define ETB_FLAG_ALL_REQUEST_OFF         0x02000000  /* don't send any request */
#define ETB_FLAG_INFO_DRIVE_OFF          0x04000000  /* don't ask drivers informations */
#define ETB_FLAG_INFO_EXTENSION_OFF      0x08000000  /* don't ask extensions informations */

#define ETB_FLAG_SPECIAL_SL              0x10000000  /* use speed loop drive - special mode for download only */

#define ETB_FLAG_RESET_MASTER            0x20000000  /* reset the master (used only with DSMAX) */
#define ETB_FLAG_RESET_SLAVES            0x40000000  /* reset all slaves (used only with DSC) */

#define ETB_FLAG_DEBUG_MODE              0x80000000  /* the communication is in a special mode for debug */
#endif /* ETB_OO_API */

/*
 * boot modes
 */
#ifndef ETB_OO_API
#define ETB_BOOT_MODE_RUN                0           /* drive run mode - normal operation */
#define ETB_BOOT_MODE_DIRECT             1           /* direct communication to the connected drive boot */
#define ETB_BOOT_MODE_BRIDGE             2           /* allows access to etel bus slave boot */
#endif /* ETB_OO_API */

/*
 * watchdog flags
 */
#ifndef ETB_OO_API
#define ETB_IRQ_WATCHDOG_NEVER			 0			 /* watchdog must run never */
#define ETB_IRQ_WATCHDOG_ALWAYS			 1			 /* watchdog must run always */
#define ETB_IRQ_WATCHDOG_REALTIME_ONLY	 2			 /* watchdog must run only in realtime mode*/
#endif /* ETB_OO_API */

/*
 * special axis number
 */
#ifndef ETB_OO_API
#define ETB_AXIS_AND                     (-2)        /* and value of the status bits of all drives presents */
#define ETB_AXIS_OR                      (-1)        /* or value of the status bits of all drives presents */
#endif /* ETB_OO_API */

/*
 * server (record 00h) command numbers
 */
#ifndef ETB_OO_API
#define ETB_R_SVR_NUMBER                 0x11        /* get the number of remote servers in the chain */
#define ETB_R_SVR_INFO_0                 0x12        /* get the product number and soft version of server */
#define ETB_R_SVR_TIMEOUTS_0             0x15        /* get the bus default timeouts of a remote server */
#define ETB_R_SVR_STATUS_0               0x21        /* get the bus status of a remote server */
#define ETB_R_SVR_STATUS_IRQ_0           0x22        /* the bus status interrupt of a remote server */
#define ETB_R_SVR_COUNTERS_0             0x25        /* get the bus counters of a remote server */
#define ETB_R_SVR_COUNTERS_IRQ_0         0x26        /* the bus counters interrupt of a remote server */
#define ETB_R_CHANGE_BOOT_MODE           0x31        /* change the boot mode of the remote drive */
#define ETB_R_START_DOWNLOAD             0x32        /* start download of the remote drive */
#define ETB_R_DOWNLOAD_SEGMENT           0x33        /* download a data segment in the remote drive */
#define ETB_R_START_UPLOAD               0x34        /* start upload of the remote drive */
#define ETB_R_UPLOAD_SEGMENT             0x35        /* upload a data segment in the remote drive */
#define ETB_R_AUTO_NUMBER                0x36        /* renumber the remote drives */
#define ETB_R_OPEN                       0x41        /* open a new connection - first message */
#define ETB_R_RESET                      0x42        /* reset the current connection to the server */
#define ETB_R_CLOSE                      0x43        /* close the current connection - last message */
#define ETB_R_KEEP_ALIVE                 0x44        /* keep connection with the server alive */
#define ETB_R_START_IRQ                  0x45        /* ask server to start sendnig irqs when required */
#define ETB_R_PURGE_STOP                 0x46        /* purge queues and stop sending data / interrupts */
#define ETB_R_MULTI_SEND                 0x50        /* send multiple records */
#define ETB_R_ALIVE_RATE                 0x60        /* message to define timeout of connection break */
#endif /* ETB_OO_API */

/* 
 * magic commands for record 04/12/14
 */
#ifndef ETB_OO_API
#define ETB_MAGIC_WAITING_REC_14         0x80        /* denotes a waiting request (record 14) */
#define ETB_MAGIC_PRESENT                0x90        /* denotes a drive present request (record 14) */
#define ETB_MAGIC_WAITING_REC_12         0x80        /* denotes a waiting request (record 12) */
#define ETB_MAGIC_STATUS_DRV_0           0x90        /* denotes a drive status request (record 12) */
#define ETB_MAGIC_STATUS_DRV_IRQ_0       0xA0        /* denotes a drive status interrupt (record 12) */
#define ETB_MAGIC_INFO_DRV_0             0xB0        /* denotes the first drive information request (record 12) */
#define ETB_MAGIC_INFO_DRV_1             0xC0        /* denotes the second drive information request (record 12) */
#define ETB_MAGIC_INFO_DRV_2             0xC1        /* denotes the third drive information request (record 12) */
#define ETB_MAGIC_INFO_EXT_0             0xD0        /* denotes the first extension card information request (record 12) */
#define ETB_MAGIC_INFO_EXT_1             0xE0        /* denotes the second extension card information request (record 12) */
#define ETB_MAGIC_STATUS_DRV_PRESENT     0xF0        /* denotes a drive present request on umaster (record 12) */
#endif /* ETB_OO_API */

/* 
 * real-time modes
 */ 
#ifndef ETB_OO_API
#define ETB_RT_ACTIVE                    1           /* real-time is running */
#define ETB_RT_IDLE                      0           /* real-time is idle */
#define ETB_RT_ERROR                     -1          /* real-time is in error */
#endif /* ETB_OO_API */

/* 
 * etb special axis number
 */ 
#ifndef ETB_OO_API
#define ETB_ALL_AXIS                     0x40        /* special axis value meaning all axis */
#define ETB_MSK_AXIS                     0x20        /* special axis value meaning masked axis */
#endif /* ETB_OO_API */

/*
 * etel bus events
 */
#ifndef ETB_OO_API
#define ETB_BEV_ERROR_SET                0x00000001  /* the error bit has been set */
#define ETB_BEV_ERROR_CLR                0x00000002  /* the error bit has been cleared */
#define ETB_BEV_ERROR                    0x00000003  /* the error bit has changed */
#define ETB_BEV_WARNING_SET              0x00000004  /* the warning bit has been set */
#define ETB_BEV_WARNING_CLR              0x00000008  /* the warning bit has been cleared */
#define ETB_BEV_WARNING                  0x0000000C  /* the warning bit has changed */
#define ETB_BEV_RESET_SET                0x00000010  /* the driver has entered reset mode */
#define ETB_BEV_RESET_CLR                0x00000020  /* the driver has exited reset mode */
#define ETB_BEV_RESET                    0x00000030  /* the reset bit has changed */
#define ETB_BEV_OPEN_SET                 0x00000040  /* the driver is open */
#define ETB_BEV_OPEN_CLR                 0x00000080  /* the driver is closed */
#define ETB_BEV_OPEN                     0x000000C0  /* the open bit has changed */
#define ETB_BEV_WATCHDOG_SET             0x00000100  /* the watchdog bit has been set */
#define ETB_BEV_WATCHDOG_CLR             0x00000200  /* the watchdog bit has been cleared */
#define ETB_BEV_WATCHDOG                 0x00000300  /* the watchdog bit has changed */
#define ETB_BEV_STATUS                   0x00001000  /* the bus status has changed */
#endif /* ETB_OO_API */

/*
 * etel bus drive events
 */
#ifndef ETB_OO_API
#define ETB_DEV_ERROR_SET                0x00000001  /* one of the error bit has been set */
#define ETB_DEV_ERROR_CLR                0x00000002  /* one of the error bit has been cleared */
#define ETB_DEV_ERROR                    0x00000003  /* one of the error bit has changed */
#define ETB_DEV_WARNING_SET              0x00000004  /* one of the warning bit has been set */
#define ETB_DEV_WARNING_CLR              0x00000008  /* one of the warning bit has been cleared */
#define ETB_DEV_WARNING                  0x0000000C  /* one of the warning bit has changed */
#define ETB_DEV_PRESENT_SET              0x00000010  /* a new drive is present */
#define ETB_DEV_PRESENT_CLR              0x00000020  /* a drive has disappeared */
#define ETB_DEV_PRESENT                  0x00000030  /* the present bit has changed */
#define ETB_DEV_STATUS_1                 0x00000100  /* the first status word has changed */
#define ETB_DEV_STATUS_2                 0x00000200  /* the second status word has changed */
#define ETB_DEV_STATUS                   0x00000300  /* one of the status word has changed */
#define ETB_DEV_USER                     0x00001000  /* the user field has changed */
#endif /* ETB_OO_API */


/*** macros ***/

#define ETB_CONST_REC                        const

#ifndef ETEL_NO_P_MACROS
#define _ETB_P1(p)                       p
#define ETB_P1(p)                        p
#define _ETB_P2(p)                       p,
#define ETB_P2(p)                        p,

#define _ETB_AXIS_P1(p)                  p
#define ETB_AXIS_P1(p)                   p
#define _ETB_AXIS_P2(p)                  p,
#define ETB_AXIS_P2(p)                   p,

#define _ETB_PORT_P1(p)                  p
#define ETB_PORT_P1(p)                   p
#define _ETB_PORT_P2(p)                  p,
#define ETB_PORT_P2(p)                   p,

#define _ETB_SVR_P1(p)                   p
#define ETB_SVR_P1(p)                    p
#define _ETB_SVR_P2(p)                   p,
#define ETB_SVR_P2(p)                    p,
#endif

/*** types ***/

/*
 * type modifiers
 */
#ifdef WIN32
#define _ETB_EXPORT __cdecl                          /* function exported by static library */
#define ETB_CALLBACK __cdecl                         /* client callback function called by library */
#endif /* WIN32 */

#ifdef QNX4
#define _ETB_EXPORT   __cdecl                        /* function exported by library */
#define ETB_CALLBACK  __cdecl                        /* client callback function called by library */
#endif /* QNX4 */

#ifdef POSIX
#define _ETB_EXPORT                           /* function exported by library */
#define ETB_CALLBACK                          /* client callback function called by library */
#endif /*POSIX*/

/* 
 * hidden structures for library clients
 */
#ifndef ETB
#define ETB void
#endif
#ifndef ETB_PORT
#define ETB_PORT void
#endif

/*
 * extended types
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

/**
 * @struct EtbSW1BitMode
 * Allow access to drive status 1 (M60) with bit members
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbSW1BitMode {
	#ifndef ETB_OO_API
	unsigned power_on:1;				/**< The power is applied to the motor */
	unsigned init_done:1;				/**< The initialisation procedure has been done */
	unsigned homing_done:1;				/**< The homing procedure has been done */
	unsigned present:1;					/**< The drive is present */
	unsigned moving:1;					/**< The motor is moving */
	unsigned in_window:1;				/**< The motor is the target windows */
	unsigned master:1;                  /**< The drive is in master mode */
	unsigned busy:1;                    /**< The drive is busy */
	unsigned exec_seq:1;                /**< A sequence is running */
	unsigned edit_mode:1;               /**< The sequence can be edited */
	unsigned fatal:1;                   /**< Fatal error */
	unsigned trace_busy:1;              /**< The aquisition of the trace is not finished */
	unsigned bridge:1;                  /**< The drive is in bridge mode */
	unsigned homing:1;                  /**< The motor is homing */
	unsigned ebl_to_eb:1;               /**< The EBL is routed transparentrly to EB (download) */
	unsigned spy:1;                     /**< A slave is used as a spy: master of labView channel */
	unsigned warning:8;                 /**< Warning mask */
	unsigned error:8;                   /**< Error mask */
	#else /* ETB_OO_API */
	unsigned powerOn:1;                 /**< The power is applied to the motor */
	unsigned initDone:1;                /**< The initialisation procedure has been done */
	unsigned homingDone:1;              /**< The homing procedure has been done */
	unsigned present:1;                 /**< The drive is present */
	unsigned moving:1;                  /**< The motor is moving */
	unsigned inWindow:1;                /**< The motor is the target windows */
	unsigned master:1;                  /**< The drive is in master mode */
	unsigned busy:1;                    /**< The drive is busy */
	unsigned execSeq:1;                 /**< A sequence is running */
	unsigned editMode:1;                /**< The sequence can be edited */
	unsigned fatal:1;                   /**< Fatal error */
	unsigned traceBusy:1;               /**< The aquisition of the trace is not finished */
	unsigned bridge:1;                  /**< The drive is in bridge mode */
	unsigned homing:1;                  /**< The motor is homing */
	unsigned eblToEb:1;                 /**< The EBL is routed transparentrly to EB (download) */
	unsigned spy:1;                     /**< A slave is used as a spy: master of labView channel */
	unsigned warning:8;                 /**< Warning mask */
	unsigned error:8;                   /**< Error mask */
	#endif /* ETB_OO_API */
} EtbSW1BitMode;
#else /*__BYTE_ORDER == __BIG_ENDIAN*/
typedef struct EtbSW1BitMode {
	#ifndef ETB_OO_API
	unsigned error:8;                   /**< Error mask */
	unsigned warning:8;                 /**< Warning mask */
	unsigned spy:1;                     /**< A slave is used as a spy: master of labView channel */
	unsigned ebl_to_eb:1;               /**< The EBL is routed transparentrly to EB (download) */
	unsigned homing:1;                  /**< The motor is homing */
	unsigned bridge:1;                  /**< The drive is in bridge mode */
	unsigned trace_busy:1;              /**< The aquisition of the trace is not finished */
	unsigned fatal:1;                   /**< Fatal error */
	unsigned edit_mode:1;               /**< The sequence can be edited */
	unsigned exec_seq:1;                /**< A sequence is running */
	unsigned busy:1;                    /**< The drive is busy */
	unsigned master:1;                  /**< The drive is in master mode */
	unsigned in_window:1;               /**< The motor is the target windows */
	unsigned moving:1;                  /**< The motor is moving */
	unsigned present:1;                 /**< The drive is present */
	unsigned homing_done:1;             /**< The homing procedure has been done */
	unsigned init_done:1;               /**< The initialisation procedure has been done */
	unsigned power_on:1;                /**< The power is applied to the motor */
	#else /* ETB_OO_API */
	unsigned error:8;                   /**< Error mask */
	unsigned warning:8;                 /**< Warning mask */
	unsigned spy:1;                     /**< A slave is used as a spy: master of labView channel */
	unsigned eblToEb:1;                 /**< The EBL is routed transparentrly to EB (download) */
	unsigned homing:1;                  /**< The motor is homing */
	unsigned bridge:1;                  /**< The drive is in bridge mode */
	unsigned traceBusy:1;               /**< The aquisition of the trace is not finished */
	unsigned fatal:1;                   /**< Fatal error */
	unsigned editMode:1;                /**< A sequence is running */
	unsigned execSeq:1;                 /**< A sequence is running */
	unsigned busy:1;                    /**< The drive is busy */
	unsigned master:1;                  /**< The drive is in master mode */
	unsigned inWindow:1;                /**< The motor is the target windows */
	unsigned moving:1;                  /**< The motor is moving */
	unsigned present:1;                 /**< The drive is present */
	unsigned homingDone:1;              /**< The homing procedure has been done */
	unsigned initDone:1;                /**< The initialisation procedure has been done */
	unsigned powerOn:1;                 /**< The power is applied to the motor */
	#endif /* ETB_OO_API */
} EtbSW1BitMode;
#endif /*__BYTE_ORDER*/
	
/**
 * @union ETB_SW1
 * Contains status 1 of devices (M60)
 */
typedef union ETB_SW1 {
	dword l;							/**< Status 1 for acces in double word format */
	EtbSW1BitMode s;					/**< Status 1 for access in bit format */
} ETB_SW1;


/**
 * @struct EtbSW2BitMode
 * Allow access to drive status 2 (M61) with bit members
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbSW2BitMode {
	#ifndef ETB_OO_API
	unsigned seq_error:1;               /**< Error label has been executed */
	unsigned seq_warning:1;             /**< Warning label has been executed */
	unsigned :6;
	unsigned user:8;                    /**< User status */
	unsigned :12; 
	unsigned dll:4;                     /**< Used internally by dlls */
	#else /* ETB_OO_API */
	unsigned seqError:1;                /**< Error label has been executed */
	unsigned seqWarning:1;              /**< Warning label has been executed */
	unsigned :6;
	unsigned user:8;                    /**< User status */
	unsigned :12; 
	unsigned dll:4;                     /**< Used internally by dlls */
	#endif /* ETB_OO_API */
} EtbSW2BitMode;

#else /*__BYTE_ORDER == __BIG_ENDIAN*/
typedef struct EtbSW2BitMode {
	#ifndef ETB_OO_API
	unsigned dll:4;                     /**< Used internally by dlls */
	unsigned :12; 
	unsigned user:8;                    /**< User status */
	unsigned :6;
	unsigned seq_warning:1;             /**< Warning label has been executed */
	unsigned seq_error:1;               /**< Error label has been executed */
	#else /* ETB_OO_API */
	unsigned dll:4;                     /**< Used internally by dlls */
	unsigned :12; 
	unsigned user:8;                    /**< User status */
	unsigned :6;
	unsigned seqWarning:1;              /**< Warning label has been executed */
	unsigned seqError:1;                /**< Error label has been executed */
	#endif /* ETB_OO_API */
} EtbSW2BitMode;
#endif /*__BYTE_ORDER*/

/**
 * @union ETB_SW2
 * Contains status 2 of devices (M61)
 */
typedef union ETB_SW2 {
	dword l;							/**< Status 2 for acces in double word format */
	EtbSW2BitMode s;					/**< Status 2 for access in bit format */
} ETB_SW2;


/**
 * @struct ETB_DRV_STATUS
 * Etel bus drive status
 */
typedef struct ETB_DRV_STATUS {
    size_t size;							/**< The size of the structure */
    ETB_SW1 sw1;								/**< Status 1 (M60)*/
    ETB_SW2 sw2;								/**< Status 2 (M61)*/
} ETB_DRV_STATUS;

#define EtbDrvStatus ETB_DRV_STATUS


/**
 * @struct EtbRecParamBitMode
 * Allow acces to Etel bus message parameter with bit members
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecParamBitMode {
    unsigned idx:16;                        /**< Index in specified address space */
    unsigned sidx:8;                        /**< Sub-index in specified address space */
    unsigned axis:7;                        /**< Axis or bit number */
    unsigned bit:1;                         /**< Bit flag (bit field, rec 0x14) */
} EtbRecParamBitMode;

#else /*__BYTE_ORDER == __BIG_ENDIAN*/
typedef struct EtbRecParamBitMode {
    unsigned bit:1;                         /**< Bit flag (bit field, rec 0x14) */
    unsigned axis:7;                        /**< Axis or bit number */
    unsigned sidx:8;                        /**< Sub-index in specified address space */
    unsigned idx:16;                        /**< Index in specified address space */
} EtbRecParamBitMode;
#endif /*__BYTE_ORDER*/

/**
 * @union ETB_REC_PARAM
 * Etel bus message parameter
 */
typedef union ETB_REC_PARAM {
    long l;									/**< Parameter for access in long format*/
	EtbRecParamBitMode v;					/**< Parameter for access in bit format*/
} ETB_REC_PARAM;

#define EtbRecParam ETB_REC_PARAM


/**
 * @struct EtbRecRawMode
 * Allows access to Etb record with raw members
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecRawMode {
	byte raw0;						/**< Byte 0 of record */
	byte raw1;						/**< Byte 1 of record */
	byte raw2;						/**< Byte 2 of record */
	byte raw3;						/**< Byte 3 of record */
	byte raw4;						/**< Byte 4 of record */
	byte raw5;						/**< Byte 5 of record */
	byte raw6;						/**< Byte 6 of record */
	byte raw7;						/**< Byte 7 of record */
	byte raw8;						/**< Byte 8 of record */
	byte raw9;						/**< Byte 9 of record */
	byte raw10;						/**< Byte 10 of record */
	byte raw11;						/**< Byte 11 of record */
} EtbRecRawMode;
#else /*__BYTE_ORDER*/
typedef struct EtbRecRawMode {
	byte raw3;						/**< Byte 3 of record */
	byte raw2;						/**< Byte 2 of record */
	byte raw1;						/**< Byte 1 of record */
	byte raw0;						/**< Byte 0 of record */
	byte raw7;						/**< Byte 7 of record */
	byte raw6;						/**< Byte 6 of record */			
	byte raw5;						/**< Byte 5 of record */
	byte raw4;						/**< Byte 4 of record */
	byte raw11;						/**< Byte 11 of record */
	byte raw10;						/**< Byte 10 of record */
	byte raw9;						/**< Byte 9 of record */
	byte raw8;						/**< Byte 8 of record */
} EtbRecRawMode;
#endif

/**
 * @struct EtbRecDataByteMode
 * Allows access to Etb record's datas in byte mode
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecDataByteMode {
	byte d0;						/**< Byte 0 of record's data*/
	byte d1;						/**< Byte 1 of record's data*/
	byte d2;						/**< Byte 2 of record's data*/
	byte d3;						/**< Byte 3 of record's data*/
	byte d4;						/**< Byte 4 of record's data*/
	byte d5;						/**< Byte 5 of record's data*/
	byte d6;						/**< Byte 6 of record's data*/
	byte d7;						/**< Byte 7 of record's data*/
} EtbRecDataByteMode;
#else /*_BYTE_ORDER*/
typedef struct EtbRecDataByteMode {
	byte d3;						/**< Byte 3 of record's data*/
	byte d2;						/**< Byte 2 of record's data*/
	byte d1;						/**< Byte 1 of record's data*/
	byte d0;						/**< Byte 0 of record's data*/
	byte d7;						/**< Byte 7 of record's data*/
	byte d6;						/**< Byte 6 of record's data*/
	byte d5;						/**< Byte 5 of record's data*/
	byte d4;						/**< Byte 4 of record's data*/
} EtbRecDataByteMode;
#endif

/**
 * @union EtbRecData
 * Etel bus message datas
 */
typedef union EtbRecData {
	byte d[8];						/**< Datas for access in table of bytes */
	EtbRecDataByteMode ds;			/**< Datas for access in bytes */
} EtbRecData;

/**
 * @struct EtbRecAll {
 * Allows access to Etel bus general message
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecAll {
    unsigned rec:6;                 /**< Record number */
    unsigned irq:1;                 /**< Interrupt request flag */
    unsigned error:1;               /**< Error bit */
    unsigned axis:7;                /**< Axis number */
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned extra:16;              /**< Extra header information */
	EtbRecData data;				/**< Message's datas */
} EtbRecAll;
#else /*__BYTE_ORDER*/
typedef struct EtbRecAll {
    unsigned extra:16;              /**< Extra header information */
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned axis:7;                /**< Axis number */
    unsigned error:1;               /**< Error bit */
    unsigned irq:1;                 /**< Interrupt request flag */
    unsigned rec:6;                 /**< Record number */
	EtbRecData data;				/**< Message's datas */
} EtbRecAll;
#endif/*__BYTE_ORDER*/

/**
 * @struct EtbRecTx04 {
 * Allows access to Etel bus send message Type 0x04
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecTx04 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                 
    unsigned :1;                    
    unsigned axis:7;                /**< Axis number */
    unsigned :1;                     
    unsigned cmd:8;                 /**< Command number */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned typ2:4;                /**< Type of parameter 2 */
	ETB_REC_PARAM par1;             /**< First parameter value */
    ETB_REC_PARAM par2;             /**< Second parameter value */
} EtbRecTx04;
#else /*__BYTE_ORDER*/
typedef struct EtbRecTx04 {
    unsigned typ2:4;                /**< Type of parameter 2 */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned cmd:8;                 /**< Command number */
    unsigned :1;                     
    unsigned axis:7;                /**< Axis number */
    unsigned :1;                    
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
	ETB_REC_PARAM par1;		        /**< First parameter value */
    ETB_REC_PARAM par2;			    /**< Second parameter value */
} EtbRecTx04;						
#endif/*__BYTE_ORDER*/


/**
 * @struct EtbRecTx12Par {
 * Allows access to Parameters of Etel bus send message Type 0x12
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecTx12Par {
	unsigned idx:16;                /**< Index in specified address space */
    unsigned sidx:8;                /**< Sub-index in specified address space */
    unsigned axis:7;                /**< Record number */
    unsigned :1;                    
} EtbRecTx12Par;
#else /*__BYTE_ORDER*/
typedef struct EtbRecTx12Par {
    unsigned :1;                    
    unsigned axis:7;                /**< Record number */
    unsigned sidx:8;                /**< Sub-index in specified address space */
	unsigned idx:16;                /**< Index in specified address space */
} EtbRecTx12Par;
#endif /*__BYTE_ORDER*/

/**
 * @struct EtbRecTx12 {
 * Allows access to Etel bus send message Type 0x12
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecTx12 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned :1;                    
    unsigned axis:7;                /**< Axis number */
    unsigned :1;                     
    unsigned :8;		            
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned typ2:4;                /**< Type of parameter 2 */
	EtbRecTx12Par par1;             /**< First parameter value */
    EtbRecTx12Par par2;             /**< Second parameter value */
} EtbRecTx12;
#else /*__BYTE_ORDER*/
typedef struct EtbRecTx12 {
    unsigned typ2:4;                /**< Type of parameter 2 */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned :8;					
    unsigned :1;                     
    unsigned axis:7;                /**< Axis number */
    unsigned :1;                    
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
	EtbRecTx12Par par1;		        /**< First parameter value */
    EtbRecTx12Par par2;			    /**< Second parameter value */
} EtbRecTx12;						
#endif/*__BYTE_ORDER*/


/**
 * @struct EtbRecTx14Par {
 * Allows access to Parameters of Etel bus send message Type 0x14
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecTx14Par {
	unsigned idx:16;                /**< Index in specified address space */
    unsigned sidx:8;                /**< Sub-index in specified address space */
    unsigned bit:5;	                /**< Bit number */
    unsigned :3;                    
} EtbRecTx14Par;
#else /*__BYTE_ORDER*/
typedef struct EtbRecTx14Par {
    unsigned :3;                    
    unsigned bit:5;		            /**< Bit number */
    unsigned sidx:8;                /**< Sub-index in specified address space */
	unsigned idx:16;                /**< Index in specified address space */
} EtbRecTx14Par;
#endif /*__BYTE_ORDER*/

/**
 * @struct EtbRecTx14 {
 * Allows access to Etel bus send message Type 0x14
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecTx14 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned :1;                    
    unsigned :7;					
    unsigned :1;                     
    unsigned :8;					
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned typ2:4;                /**< Type of parameter 2 */
	EtbRecTx14Par par1;             /**< First parameter value */
    EtbRecTx14Par par2;             /**< Second parameter value */
} EtbRecTx14;
#else /*__BYTE_ORDER*/
typedef struct EtbRecTx14 {
    unsigned typ2:4;                /**< Type of parameter 2 */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned :8;					
    unsigned :1;                     
    unsigned :7;	                
    unsigned :1;                    
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
	EtbRecTx14Par par1;		        /**< First parameter value */
    EtbRecTx14Par par2;			    /**< Second parameter value */
} EtbRecTx14;						
#endif/*__BYTE_ORDER*/

/**
 * @struct EtbRecTx18 {
 * Allows access to Etel bus send message Type 0x18
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecTx18 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned :1;                    
    unsigned axis:7;                /**< Axis number */
    unsigned :1;                     
    unsigned cmd:8;                 /**< Command number */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned typ2:4;                /**< Type of parameter 2 */
	ETB_REC_PARAM par1;             /**< First parameter value */
    ETB_REC_PARAM par2;             /**< Second parameter value */
} EtbRecTx18;
#else /*__BYTE_ORDER*/
typedef struct EtbRecTx18 {
    unsigned typ2:4;                /**< Type of parameter 2 */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned cmd:8;                 /**< Command number */
    unsigned :1;                     
    unsigned axis:7;                /**< Axis number */
    unsigned :1;                    
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
	ETB_REC_PARAM par1;		        /**< First parameter value */
    ETB_REC_PARAM par2;			    /**< Second parameter value */
} EtbRecTx18;
#endif/*__BYTE_ORDER*/

/**
 * @struct EtbRecTx20 {
 * Allows access to Etel bus send message Type 0x20
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecTx20 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned :1;                    
    unsigned axis:7;                /**< Axis number */
    unsigned :1;                     
    unsigned cmd:8;                 /**< Command number */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned typ2:4;                /**< Type of parameter 2 */
	ETB_REC_PARAM par1;             /**< First parameter value */
    ETB_REC_PARAM par2;             /**< Second parameter value */
} EtbRecTx20;
#else /*__BYTE_ORDER*/
typedef struct EtbRecTx20 {
    unsigned typ2:4;                /**< Type of parameter 2 */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned cmd:8;                 /**< Command number */
    unsigned :1;                     
    unsigned axis:7;                /**< Axis number */
    unsigned :1;                    
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
	ETB_REC_PARAM par1;		        /**< First parameter value */
    ETB_REC_PARAM par2;			    /**< Second parameter value */
} EtbRecTx20;
#endif/*__BYTE_ORDER*/


/**
 * @struct EtbRecTx30 {
 * Allows access to Etel bus send message Type 0x30
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecTx30 {
    unsigned rec:6;                 /**< Record number */
    unsigned :26;                   
} EtbRecTx30;
#else /*__BYTE_ORDER*/
typedef struct EtbRecTx30 {
    unsigned :26;                   
    unsigned rec:6;                 /**< Record number */
} EtbRecTx30;
#endif/*__BYTE_ORDER*/

/**
 * @struct EtbRecTx32 {
 * Allows access to Etel bus send message Type 0x32
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecTx32 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned :1;                    
    unsigned :7;                    
    unsigned :1;                     
    unsigned : 16;					
	dword mask;						/**< bit array for busy flags */
} EtbRecTx32;
#else /*__BYTE_ORDER*/
typedef struct EtbRecTx32 {
    unsigned : 16;					
    unsigned :1;                     
    unsigned :7;					
    unsigned :1;                    
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
	dword mask;						/**< bit array for busy flags */
} EtbRecTx32;
#endif/*__BYTE_ORDER*/


/**
 * @struct EtbRecTx34 {
 * Allows access to Etel bus send message Type 0x34
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecTx34 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned :1;                    
    unsigned axis:7;                /**< Axis number */
    unsigned :1;                     
    unsigned : 16;					
} EtbRecTx34;
#else /*__BYTE_ORDER*/
typedef struct EtbRecTx34 {
    unsigned : 16;					
    unsigned :1;                     
    unsigned axis:7;                /**< Axis number */
    unsigned :1;                    
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
} EtbRecTx34;
#endif/*__BYTE_ORDER*/

/**
 * @struct EtbRecRx04 {
 * Allows access to Etel bus receive message Type 0x04
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecRx04 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned error:1;               /**< Error bit */
    unsigned axis:7;                /**< Axis number */
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned cmd:8;                 /**< Command number */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned typ2:4;                /**< Type of parameter 2 */
	ETB_REC_PARAM par1;		        /**< First parameter value */
    ETB_REC_PARAM par2;			    /**< Second parameter value */
} EtbRecRx04;
#else /*__BYTE_ORDER*/
typedef struct EtbRecRx04 {
    unsigned typ2:4;                /**< Type of parameter 2 */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned cmd:8;                 /**< Command number */
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned axis:7;                /**< Axis number */
    unsigned error:1;               /**< Error bit */
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
	ETB_REC_PARAM par1;		        /**< First parameter value */
    ETB_REC_PARAM par2;			    /**< Second parameter value */
} EtbRecRx04;
#endif/*__BYTE_ORDER*/

/**
 * @struct EtbRecRx12 {
 * Allows access to Etel bus receive message Type 0x12
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecRx12 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned error:1;               /**< Error bit */
    unsigned axis:7;                /**< Axis number */
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned :8;	                
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned typ2:4;                /**< Type of parameter 2 */
	long val1;						/**< First parameter value */
    long val2;						/**< Second parameter value */
} EtbRecRx12;
#else /*__BYTE_ORDER*/
typedef struct EtbRecRx12 {
    unsigned typ2:4;                /**< Type of parameter 2 */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned :8;					
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned axis:7;                /**< Axis number */
    unsigned error:1;               /**< Error bit */
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
	long val1;				        /**< First parameter value */
    long val2;						/**< Second parameter value */
} EtbRecRx12;
#endif/*__BYTE_ORDER*/


/**
 * @struct EtbRecRx14 {
 * Allows access to Etel bus receive message Type 0x14
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecRx14 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned error:1;               /**< Error bit */
    unsigned :7;					
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned :8;					
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned typ2:4;                /**< Type of parameter 2 */
	long mask1;						/**< First parameter value */
    long mask2;						/**< Second parameter value */
} EtbRecRx14;
#else /*__BYTE_ORDER*/
typedef struct EtbRecRx14 {
    unsigned typ2:4;                /**< Type of parameter 2 */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned :8;					
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned :7;					
    unsigned error:1;               /**< Error bit */
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
	long mask1;				        /**< First parameter value */
    long mask2;						/**< Second parameter value */
} EtbRecRx14;
#endif/*__BYTE_ORDER*/


/**
 * @struct EtbRecRx18 {
 * Allows access to Etel bus receive message Type 0x18
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecRx18 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned error:1;               /**< Error bit */
    unsigned axis:7;                /**< Axis number */
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned cmd:8;                 /**< Command number */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned typ2:4;                /**< Type of parameter 2 */
	ETB_REC_PARAM par1;		        /**< First parameter value */
    ETB_REC_PARAM par2;			    /**< Second parameter value */
} EtbRecRx18;
#else /*__BYTE_ORDER*/
typedef struct EtbRecRx18 {
    unsigned typ2:4;                /**< Type of parameter 2 */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned cmd:8;                 /**< Command number */
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned axis:7;                /**< Axis number */
    unsigned error:1;               /**< Error bit */
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
	ETB_REC_PARAM par1;		        /**< First parameter value */
    ETB_REC_PARAM par2;			    /**< Second parameter value */
} EtbRecRx18;
#endif/*__BYTE_ORDER*/


/**
 * @struct EtbRecRx20 {
 * Allows access to Etel bus receive message Type 0x20
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecRx20 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned error:1;               /**< Error bit */
    unsigned axis:7;                /**< Axis number */
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned cmd:8;                 /**< Command number */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned typ2:4;                /**< Type of parameter 2 */
	ETB_REC_PARAM par1;		        /**< First parameter value */
    ETB_REC_PARAM par2;			    /**< Second parameter value */
} EtbRecRx20;
#else /*__BYTE_ORDER*/
typedef struct EtbRecRx20 {
    unsigned typ2:4;                /**< Type of parameter 2 */
    unsigned typ1:4;                /**< Type of parameter 1 */
    unsigned cmd:8;                 /**< Command number */
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned axis:7;                /**< Axis number */
    unsigned error:1;               /**< Error bit */
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
	ETB_REC_PARAM par1;		        /**< First parameter value */
    ETB_REC_PARAM par2;			    /**< Second parameter value */
} EtbRecRx20;
#endif/*__BYTE_ORDER*/


/**
 * @struct EtbRecRx30 {
 * Allows access to Etel bus receive message Type 0x30
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecRx30 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned error:1;               /**< Error bit */
    unsigned :7;                    
    unsigned ack:1;                 /**< ack bit */ 
    unsigned slaves:16;             /**< number of slaves on the bus */
    dword busy;                     /**< bit array for busy flags */
    dword exception;                /**< bit array which indicates that */
                                    /**< an error or warning has occured on the drive */
} EtbRecRx30;
#else /*__BYTE_ORDER*/
typedef struct EtbRecRx30 {
    unsigned slaves:16;             /**< number of slaves on the bus */
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned :7;	                
    unsigned error:1;               /**< Error bit */
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
    dword busy;                     /**< bit array for busy flags */
    dword exception;                /**< bit array which indicates that */
                                    /**< an error or warning has occured on the drive */
} EtbRecRx30;
#endif/*__BYTE_ORDER*/


/**
 * @struct EtbRecRx32 {
 * Allows access to Etel bus receive message Type 0x32
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecRx32 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned error:1;               /**< Error bit */
    unsigned :7;                  
    unsigned ack:1;                 /**< ack bit */ 
    unsigned :16;		            
    dword mask;                     /**< bit array for axis mask */
    dword exception;                /**< bit array which indicates that */
                                    /**< an error or warning has occured on the drive */
} EtbRecRx32;
#else /*__BYTE_ORDER*/
typedef struct EtbRecRx32 {
    unsigned :16;		            
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned :7;	                
    unsigned error:1;               /**< Error bit */
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
    dword mask;                     /**< bit array for axis mask */
    dword exception;                /**< bit array which indicates that */
                                    /**< an error or warning has occured on the drive */
} EtbRecRx32;
#endif/*__BYTE_ORDER*/

/**
 * @struct EtbRecRx34 {
 * Allows access to Etel bus receive message Type 0x34
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbRecRx34 {
    unsigned rec:6;                 /**< Record number */
    unsigned :1;                    
    unsigned error:1;               /**< Error bit */
    unsigned axis:7;                /**< Axis number */
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned :16;		            
    ETB_SW1 sw1;                     /**< Status word 1 of the drive */
    ETB_SW2 sw2;                     /**< Status word 2 of the drive */
} EtbRecRx34;
#else /*__BYTE_ORDER*/
typedef struct EtbRecRx34 {
    unsigned :16;		            
    unsigned ack:1;                 /**< Ack bit */ 
    unsigned axis:7;                /**< Axis number */
    unsigned error:1;               /**< Error bit */
    unsigned :1;                    
    unsigned rec:6;                 /**< Record number */
    ETB_SW1 sw1;                     /**< Status word 1 of the drive */
    ETB_SW2 sw2;                     /**< Status word 2 of the drive */
} EtbRecRx34;
#endif/*__BYTE_ORDER*/

/**
 * @union ETB_REC
 * Etel bus message structure
 */
typedef union ETB_REC {
	byte raw[12];               /**< Etb record for access of table of bytes */
	EtbRecRawMode raws;			/**< Etb record for access of raws (little/big endian compatible)*/
    dword part[3];              /**< Etb record for access of table of double word */
	EtbRecAll all;				/**< Etb Record for access of general mode */
	EtbRecTx04 tx04;			/**< Etb Record for access of send record 0x04 */
	EtbRecTx12 tx12;			/**< Etb Record for access of send record 0x12 */
	EtbRecTx14 tx14;			/**< Etb Record for access of send record 0x14 */
	EtbRecTx18 tx18;			/**< Etb Record for access of send record 0x18 */
	EtbRecTx20 tx20;			/**< Etb Record for access of send record 0x20 */
	EtbRecTx30 tx30;			/**< Etb Record for access of send record 0x30 */
	EtbRecTx32 tx32;			/**< Etb Record for access of send record 0x32 */
	EtbRecTx34 tx34;			/**< Etb Record for access of send record 0x34 */
	EtbRecRx04 rx04;			/**< Etb Record for access of received record 0x04 */
	EtbRecRx12 rx12;			/**< Etb Record for access of received record 0x12 */
	EtbRecRx14 rx14;			/**< Etb Record for access of received record 0x14 */
	EtbRecRx18 rx18;			/**< Etb Record for access of received record 0x18 */
	EtbRecRx20 rx20;			/**< Etb Record for access of received record 0x20 */
	EtbRecRx30 rx30;			/**< Etb Record for access of received record 0x30 */
	EtbRecRx32 rx32;			/**< Etb Record for access of received record 0x32 */
	EtbRecRx34 rx34;			/**< Etb Record for access of received record 0x34 */
} ETB_REC;

#define EtbRec ETB_REC

/**
 * @struct EtbSWBitMode
 * Allows acces to Etel bus status double word in bit mode
 */

#if __BYTE_ORDER == __LITTLE_ENDIAN
typedef struct EtbSWBitMode {
	#ifndef ETB_OO_API
	unsigned open:1;				/**< The driver is open */
	unsigned reset:1;               /**< The driver currently perforn a reset */
	unsigned b_direct:1;            /**< The drive(s) are in direct boot mode */
	unsigned b_bridge:1;            /**< The drive(s) are in bridge boot mode */
	unsigned warning:1;             /**< There is a communication warning */
	unsigned error:1;               /**< There is a communication error */
	unsigned busy:1;                /**< The drive cannot communicate now */
	unsigned watchdog:1;			/**< There is a watchdog error on communication. DSTEB3 only*/
	unsigned :4;
	unsigned :16;
	unsigned dll:4;                 /**< Reserved for dll use */
	#else /* ETB_OO_API */
	unsigned open:1;                /**< The driver is open */
	unsigned reset:1;               /**< The driver currently perforn a reset */
	unsigned bDirect:1;             /**< The drive(s) are in direct boot mode */
	unsigned bBridge:1;             /**< The drive(s) are in bridge boot mode */
	unsigned warning:1;             /**< There is a communication warning */
	unsigned error:1;               /**< There is a communication error */
	unsigned busy:1;                /**< The drive cannot communicate now */
	unsigned watchdog:1;			/**< There is a watchdog error on communication. DSTEB3 only*/
	unsigned :4;
	unsigned :16;
	unsigned dll:4;                 /**< Reserved for dll use */
	#endif /* ETB_OO_API */
} EtbSWBitMode;
#else /*__BYTE_ORDER == __BIG_ENDIAN*/
typedef struct EtbSWBitMode {
	#ifndef ETB_OO_API
	unsigned dll:4;                 /**< Reserved for dll use */
	unsigned :16;
	unsigned :4;
	unsigned watchdog:1;			/**< There is a watchdog error on communication. DSTEB3 only*/
	unsigned busy:1;                /**< The drive cannot communicate now */
	unsigned error:1;               /**< There is a communication error */
	unsigned warning:1;             /**< There is a communication warning */
	unsigned b_bridge:1;            /**< The drive(s) are in bridge boot mode */
	unsigned b_direct:1;            /**< The drive(s) are in direct boot mode */
	unsigned reset:1;               /**< The driver currently perforn a reset */
	unsigned open:1;				/**< The driver is open */
	#else /* ETB_OO_API */
	unsigned dll:4;                 /**< Reserved for dll use */
	unsigned :16;
	unsigned :4;
	unsigned watchdog:1;			/**< There is a watchdog error on communication. DSTEB3 only*/
	unsigned busy:1;                /**< The drive cannot communicate now */
	unsigned error:1;               /**< There is a communication error */
	unsigned warning:1;             /**< There is a communication warning */
	unsigned bBidge:1;	            /**< The drive(s) are in bridge boot mode */
	unsigned bDrect:1;		        /**< The drive(s) are in direct boot mode */
	unsigned reset:1;               /**< The driver currently perforn a reset */
	unsigned open:1;				/**< The driver is open */
	#endif /* ETB_OO_API */
} EtbSWBitMode;
#endif /*__BYTE_ORDER*/

/**
 * @union ETB_SW
 * Etel bus status double word
 */
typedef union ETB_SW {
	dword l;						/**< Status double word for access in double word */
	EtbSWBitMode s;					/**< Status double word for accexss in bit mode */				
} ETB_SW;

#define EtbSW ETB_SW

/**
 * @struct ETB_BUS_STATUS
 * Etel bus status structure
 */
typedef struct ETB_BUS_STATUS {
    size_t size;                    /**< The size of this structure */ 
	ETB_SW sw;                      /**< The status */
    int e_code;                     /**< The error code */
} ETB_BUS_STATUS;

#define EtbBusStatus ETB_BUS_STATUS

/**
 * @struct ETB_DRV_INFO
 * Etel bus drive information
 */
typedef struct ETB_DRV_INFO {
    size_t size;                    /**< The size of this structure */
	#ifndef ETB_OO_API
    int product_number;             /**< The drive product number */
    int boot_revision;              /**< The boot revision of drive */
    long serial_number;             /**< The serial number of drive */
    dword soft_version;             /**< The version of drive software */
	#else /* ETB_OO_API */
    int productNumber;              /**< The drive product number */
    int bootRevision;               /**< The boot revision of drive */
    long serialNumber;              /**< The serial number of drive */
    dword softVersion;              /**< The version of drive software */
	#endif /* ETB_OO_API */
} ETB_DRV_INFO;

#define EtbDrvInfo ETB_DRV_INFO

/**
 * @struct ETB_DRV_NAME
 * Etel bus drive information
 */
typedef struct ETB_DRV_NAME {
    size_t size;                    /**< The size of this structure */
    char name[17];		            /**< The name of the drive */
} ETB_DRV_NAME;

#define EtbDrvName ETB_DRV_NAME


/**
 * @struct ETB_EXT_INFO
 * Etel bus extension card information
 */
typedef struct ETB_EXT_INFO {
    size_t size;                    /**< The size of this structure */
	#ifndef ETB_OO_API
    int product_number;             /**< The extension card product number */
    int boot_revision;              /**< The boot revision of extension card */
    long serial_number;             /**< The serial number of extension card */
    dword soft_version;             /**< The version of extension card software */
	#else /* ETB_OO_API */
    int productNumber;              /**< The extension card product number */
    int bootRevision;               /**< The boot revision of extension card */
    long serialNumber;              /**< The serial number of extension card */
    dword softVersion;              /**< The version of extension card software */
	#endif /* ETB_OO_API */
} ETB_EXT_INFO;

#define EtbExtInfo ETB_EXT_INFO

/**
 * @struct ETB_SVR_INFO
 * Etel bus server information
 */
typedef struct ETB_SVR_INFO {
    size_t size;                    /**< The size of this structure */
	#ifndef ETB_OO_API
    int product_number;             /**< The server product number */
    dword soft_version;             /**< The version of server software */
	#else /* ETB_OO_API */
    int productNumber;              /**< The server product number */
    dword softVersion;              /**< The version of server software */
	#endif /* ETB_OO_API */
} ETB_SVR_INFO;

#define EtbSvrInfo ETB_SVR_INFO

/**
 * @struct ETB_TIMEOUTS
 * Etel bus preferred timeouts information
 */
typedef struct ETB_TIMEOUTS {
    size_t size;                    /**< The size of this structure */
    int base;                       /**< The base value of preferred timeouts */
    int fast;                       /**< The factor for preferred fast timeouts */
    int slow;                       /**< The factor for preferred slow timeouts */
} ETB_TIMEOUTS;

#define EtbTimeouts ETB_TIMEOUTS

/**
 * @struct ETB_RTM_VAL
 * Realtime values 
 */
typedef struct ETB_RTM_VAL {
	long val0;						/**< The first realtime value on channel*/
	long val1;						/**< The second realtime value on channel */
} ETB_RTM_VAL;

#define ETB_MAX_RTM 16     /**< Maximal number of drives by using realtime monitoring */

/**
 * @struct ETB_RTM_TABLE
 * Contains realtime monitoring in a table
 */
typedef struct ETB_RTM_TABLE {
	size_t size;							/**< The size of this structure */
	ETB_RTM_VAL mon[ETB_MAX_RTM];			/**< The monitoring table */
} ETB_RTM_TABLE;

/**
 * @struct ETB_RTM_STRUCT
 * Contains realtime monitoring in structure
 */
typedef struct ETB_RTM_STRUCT {
	size_t size;					/**< The size of this structure */
	long axis0_m0;				/**< The first realtime monitoring value of 1st axis */
	long axis0_m1;				/**< The second realtime monitoring value of 1st axis */
	long axis1_m0;				/**< The first realtime monitoring value of 2nd axis */
	long axis1_m1;				/**< The second realtime monitoring value of 2nd axis */
	long axis2_m0;				/**< The first realtime monitoring value of 3rd axis */
	long axis2_m1;				/**< The second realtime monitoring value of 3rd axis */
	long axis3_m0;				/**< The first realtime monitoring value of 4th axis */
	long axis3_m1;				/**< The second realtime monitoring value of 4th axis */
	long axis4_m0;				/**< The first realtime monitoring value of 5th axis */
	long axis4_m1;				/**< The second realtime monitoring value of 5th axis */
	long axis5_m0;				/**< The first realtime monitoring value of 6th axis */
	long axis5_m1;				/**< The second realtime monitoring value of 6th axis */
	long axis6_m0;				/**< The first realtime monitoring value of 7th axis */
	long axis6_m1;				/**< The second realtime monitoring value of 7th axis */
	long axis7_m0;				/**< The first realtime monitoring value of 8th axis */
	long axis7_m1;				/**< The second realtime monitoring value of 8th axis */
	long axis8_m0;				/**< The first realtime monitoring value of 9th axis */
	long axis8_m1;				/**< The second realtime monitoring value of 9th axis */
	long axis9_m0;				/**< The first realtime monitoring value of 10th axis */
	long axis9_m1;				/**< The second realtime monitoring value of 10th axis */
	long axis10_m0;				/**< The first realtime monitoring value of 11th axis */
	long axis10_m1;				/**< The second realtime monitoring value of 11th axis */
	long axis11_m0;				/**< The first realtime monitoring value of 12th axis */
	long axis11_m1;				/**< The second realtime monitoring value of 12th axis */
	long axis12_m0;				/**< The first realtime monitoring value of 13th axis */
	long axis12_m1;				/**< The second realtime monitoring value of 13th axis */
	long axis13_m0;				/**< The first realtime monitoring value of 14th axis */
	long axis13_m1;				/**< The second realtime monitoring value of 14th axis */
	long axis14_m0;				/**< The first realtime monitoring value of 15th axis */
	long axis14_m1;				/**< The second realtime monitoring value of 15th axis */
	long axis15_m0;				/**< The first realtime monitoring value of 16th axis */
	long axis15_m1;				/**< The second realtime monitoring value of 16th axis */
} ETB_RTM_STRUCT;


/**
 * @union ETB_RTM
 * Getted realtime monitoring structure
 */
typedef union ETB_RTM {
    size_t size;                /**< Size of this structure */
	ETB_RTM_STRUCT monStruct;	/**< Access to realtime monitoring through structure */			
	ETB_RTM_TABLE monTable;		/**< Access to realtime monitoring through table */			
} ETB_RTM;

/*Type of trajectory generator function called at each interrupt*/
typedef void (*ETB_TRAJECTORY_HANDLER)(ETB_RTM *pts);

/*Type of axis mask structure for realtime channel*/
typedef unsigned long ETB_RTM_AXISMASK[ETB_MAX_RTM];

/**
 * @struct ETB_COUNTERS
 * Etel bus counters information
 */
typedef struct ETB_COUNTERS {
    size_t size;                    /**< The size of this structure */
	#ifndef ETB_OO_API
    int tx_counter;                 /**< The number of messages transmitted */
    int rx_counter;                 /**< The number of messages received */
	#else /* ETB_OO_API */
    int txCounter;                  /**< The number of messages transmitted */
    int rxCounter;                  /**< The number of messages received */
	#endif /* ETB_OO_API */
} ETB_COUNTERS;

#define EtbCounters ETB_COUNTERS


#ifdef ETB_OO_API
/**
 * @struct EtbSrvCommands
 * Server (record 00h) command numbers
 */
struct EtbSvrCommands {
public:
    enum { SVR_NUMBER = 0x11 };          /**< Get the number of remote servers in the chain */
    enum { SVR_INFO_0 = 0x12 };          /**< Get the product number and soft version of server */
    enum { SVR_TIMEOUTS_0 = 0x15 };      /**< Get the bus default timeouts of a remote server */
    enum { SVR_STATUS_0 = 0x21 };        /**< Get the bus status of a remote server */
    enum { SVR_STATUS_IRQ_0 = 0x22 };    /**< The bus status interrupt of a remote server */
    enum { SVR_COUNTERS_0 = 0x25 };      /**< Get the bus counters of a remote server */
    enum { SVR_COUNTERS_IRQ_0 = 0x26 };  /**< The bus counters interrupt of a remote server */
    enum { CHANGE_BOOT_MODE = 0x31 };    /**< Change the boot mode of the remote drive */
    enum { START_DOWNLOAD = 0x32 };      /**< Start download of the remote drive */
    enum { DOWNLOAD_SEGMENT = 0x33 };    /**< Download a data segment in the remote drive */
    enum { START_UPLOAD = 0x34 };        /**< Start upload of the remote drive */
    enum { UPLOAD_SEGMENT = 0x35 };      /**< Upload a data segment in the remote drive */
    enum { AUTO_NUMBER = 0x36 };         /**< Renumber the remote drives */
    enum { OPEN = 0x41 };                /**< Open a new connection - first message */
    enum { RESET = 0x42 };               /**< Reset the current connection to the server */
    enum { CLOSE = 0x43 };               /**< Close the current connection - last message */
    enum { KEEP_ALIVE = 0x44 };          /**< Keep connection with the server alive */
    enum { START_IRQ = 0x45 };           /**< Ask server to start sendnig irqs when required */
    enum { PURGE_STOP = 0x46 };          /**< Purge queues and stop sending data / interrupts */
};
#endif /* ETB_OO_API */

#ifdef ETB_OO_API
/**
 * @struct EtbMagic 
 * Magic commands for record 04/12/14
 */
struct EtbMagic {
public:
    enum { WAITING_REC_14 = 0x80 };      /**< Mark a waiting request (record 14) */
    enum { PRESENT = 0x90 };             /**< Mark a drive present request (record 14) */
    enum { WAITING_REC_12 = 0x80 };      /**< Mark a waiting request (record 12) */
    enum { STATUS_DRV_0 = 0x90 };        /**< Mark a drive status request (record 12) */
    enum { STATUS_DRV_IRQ_0 = 0xA0 };    /**< Mark a drive status interrupt (record 12) */
    enum { INFO_DRV_0 = 0xB0 };          /**< Mark the first drive information request (record 12) */
    enum { INFO_DRV_1 = 0xC0 };          /**< Mark the second drive information request (record 12) */
    enum { INFO_EXT_0 = 0xD0 };          /**< Mark the first extension card information request (record 12) */
    enum { INFO_EXT_1 = 0xE0 };          /**< Mark the second extension card information request (record 12) */
};
#endif /* ETB_OO_API */

#ifdef ETB_OO_API
/**
 * @struct EtbBusEvent
 * Etel bus handler structure
 */
struct EtbBusEvent {
public:
    enum { ERROR_SET = 0x00000001 };      /**< The error bit has been set */
    enum { ERROR_CLR = 0x00000002 };      /**< The error bit has been cleared */
    enum { ERROR = 0x00000003 };          /**< The error bit has changed */
    enum { WARNING_SET = 0x00000004 };    /**< The warning bit has been set */
    enum { WARNING_CLR = 0x00000008 };    /**< The warning bit has been cleared */
    enum { WARNING = 0x0000000C };        /**< The warning bit has changed */
    enum { RESET_SET =  0x00000010 };     /**< The driver has entered reset mode */
    enum { RESET_CLR = 0x00000020 };      /**< The driver has exited reset mode */
    enum { RESET = 0x00000030 };          /**< The reset bit has changed */
    enum { OPEN_SET = 0x00000040 };       /**< The driver is open */
    enum { OPEN_CLR = 0x00000080 };       /**< The driver is closed */
    enum { OPEN = 0x000000C0 };           /**< The open bit has changed */
    enum { WATCHDOG_SET =  0x00000100 };  /**< the watchdog bit has been set */
    enum { WATCHDOG_CLR = 0x00000200 };   /**< the watchdog bit has been cleared */
    enum { WATCHDOG = 0x00000300 };       /**< The watchdog bit has changed */
    enum { STATUS = 0x00001000 };         /**< The bus status has changed */
};
#endif

#ifdef ETB_OO_API
/**
 * @struct EtbDrvPresent
 * Etel bus drive event
 */
struct EtbDrvEvent {
public:
    enum { ERROR_SET = 0x00000001 };      /**< One of the error bit has been set */
    enum { ERROR_CLR = 0x00000002 };      /**< One of the error bit has been cleared */
    enum { ERROR = 0x00000003 };          /**< One of the error bit has changed */
    enum { WARNING_SET = 0x00000004 };    /**< One of the warning bit has been set */
    enum { WARNING_CLR = 0x00000008 };    /**< One of the warning bit has been cleared */
    enum { WARNING = 0x0000000C };        /**< One of the warning bit has changed */
    enum { PRESENT_SET = 0x00000010 };    /**< A new drive is present */
    enum { PRESENT_CLR = 0x00000020 };    /**< A drive has disappeared */
    enum { PRESENT = 0x00000030 };        /**< The present bit has changed */
    enum { STATUS_1 = 0x00000100 };       /**< The first status word has changed */
    enum { STATUS_2 = 0x00000200 };       /**< The second status word has changed */
    enum { STATUS = 0x00000300 };         /**< One of the status word has changed */
    enum { USER = 0x00001000 };           /**< The user field has changed */
};
#endif

/**
 * @struct ETB_FW_INFO
 * Firmware information
 */
typedef struct ETB_FW_INFO {
	char title[64];			/**< The name of the firmware */
	char version[64];		/**< The version of the firmware */
} ETB_FW_INFO;


/*** variables ***/

#ifndef AXIS_PAR
extern int etb_axis;
#endif /* AXIS_PAR */


/*** prototypes ***/

/*
 * general functions
 */
dword   _ETB_EXPORT etb_get_version(void);
dword   _ETB_EXPORT etb_get_edi_version(void);
time_t  _ETB_EXPORT etb_get_build_time(void);
long    _ETB_EXPORT etb_get_timer(void);
char_cp _ETB_EXPORT etb_translate_error(int code);

/*
 * connection management functions
 */
int     _ETB_EXPORT etb_create_bus(ETB **retb);
int     _ETB_EXPORT etb_destroy_bus(ETB **retb);
bool    _ETB_EXPORT etb_is_valid_bus(ETB *etb);
int     _ETB_EXPORT etb_create_port(ETB_PORT **rport, ETB *etb);
int     _ETB_EXPORT etb_destroy_port(ETB_PORT **rport);
int     _ETB_EXPORT etb_create_spy_port(ETB_PORT **rport, ETB *etb);
int     _ETB_EXPORT etb_destroy_spy_port(ETB_PORT **rport);
bool    _ETB_EXPORT etb_is_valid_port(ETB_PORT *port);
int     _ETB_EXPORT etb_open(ETB *etb, const char *driver, dword flags, long baudrate, long timeout);
int     _ETB_EXPORT etb_reset(ETB *etb, dword flags, long baudrate, long timeout, bool deep);
int     _ETB_EXPORT etb_close(ETB *etb, dword flags, long timeout);
int     _ETB_EXPORT etb_is_open(ETB *etb, bool *open);
int     _ETB_EXPORT etb_get_bus(ETB_PORT *port, ETB **etb);
int     _ETB_EXPORT etb_get_driver(ETB *etb, char *buf, size_t max);
int     _ETB_EXPORT etb_get_flags(ETB *etb, dword *flags);
int     _ETB_EXPORT etb_get_baudrate(ETB *etb, long *baudrate);
int		_ETB_EXPORT etb_activate_status(ETB *etb, bool on);
int		_ETB_EXPORT etb_multi_send(ETB *etb, int nb_rec, ETB_REC send_table[], dword mask_table[], ETB_REC recv_table[], dword time_table[], int timeout);
int		_ETB_EXPORT etb_start_rtm(ETB *etb, ETB_TRAJECTORY_HANDLER get_trajectory_point);
int		_ETB_EXPORT etb_stop_rtm(ETB *etb);
int		_ETB_EXPORT etb_init_rtm_fct(ETB *etb, ETB_RTM_AXISMASK realtime_axis);
int		_ETB_EXPORT etb_set_rates(ETB *etb, int irq_rate, int status_rate, int mon_rate, int fast_rate, int slow_rate);
int     _ETB_EXPORT etb_get_rtm_mon(ETB *etb, ETB_RTM *rtm_mon);
int	    _ETB_EXPORT etb_set_prio(ETB *etb, int prio);
ETB_RTM _ETB_EXPORT etb_init_rtm(void);
int		_ETB_EXPORT etb_link_error(ETB *etb, bool on);
int		_ETB_EXPORT etb_irq_watchdog(ETB *etb, int watchdog);
void	_ETB_EXPORT etb_bus_clear_watchdog(ETB *etb);

/*
 * status/info access functions
 */
int     _ETB_EXPORT etb_get_bus_status(ETB *etb, int server, ETB_BUS_STATUS *stat);
int     _ETB_EXPORT etb_get_bus_counters(ETB *etb, int server, ETB_COUNTERS *counters);
int     _ETB_EXPORT etb_get_bus_timeouts(ETB *etb, ETB_TIMEOUTS *timeouts);
int     _ETB_EXPORT etb_get_svr_number(ETB *etb, int *number);
int     _ETB_EXPORT etb_get_svr_info(ETB *etb, int server, ETB_SVR_INFO *info);
int     _ETB_EXPORT etb_get_drv_present(ETB *etb, dword *present);
int     _ETB_EXPORT etb_get_drv_peer(ETB *etb, dword *peer);
int     _ETB_EXPORT etb_get_drv_status(ETB *etb, int axis, ETB_DRV_STATUS *stat);
int     _ETB_EXPORT etb_get_drv_info(ETB *etb, int axis, ETB_DRV_INFO *info);
int     _ETB_EXPORT etb_get_ext_info(ETB *etb, int axis, ETB_EXT_INFO *info);

/*
 * handlers management functions
 */
int     _ETB_EXPORT etb_add_bus_handler(ETB *etb, void *key, dword svr_mask, dword ev_mask, void (ETB_CALLBACK *handler)(ETB *, int, dword, void *), void *param);
int     _ETB_EXPORT etb_remove_bus_handler(ETB *etb, void *key);
int     _ETB_EXPORT etb_add_drv_handler(ETB *etb, void *key, dword axis_mask, bool and_mask, bool or_mask, dword ev_mask, void (ETB_CALLBACK *handler)(ETB *, int, dword, void *), void *param);
int     _ETB_EXPORT etb_remove_drv_handler(ETB *etb, void *key);
int     _ETB_EXPORT etb_add_rt_handler(ETB *etb, void *key, dword axis_mask, int (ETB_CALLBACK *handler)(ETB *, int, long *, void *), void *param);
int     _ETB_EXPORT etb_remove_rt_handler(ETB *etb, void *key);
int     _ETB_EXPORT etb_add_msg_handler(ETB_PORT *port, void *key, void (ETB_CALLBACK *handler)(ETB_PORT *, void *), void *param);
int     _ETB_EXPORT etb_remove_msg_handler(ETB_PORT *port, void *key);

/*
 * transaction support
 */
int     _ETB_EXPORT etb_begin_trans(ETB *etb, long timeout);
int     _ETB_EXPORT etb_end_trans(ETB *etb);

/*
 * message handling functions
 */
int     _ETB_EXPORT etb_putm(ETB_PORT *port, const void *key, dword mask, ETB_CONST_REC ETB_REC *rec, long timeout);
int     _ETB_EXPORT etb_putr(ETB_PORT *port, ETB_CONST_REC ETB_REC *rec, long timeout);
int     _ETB_EXPORT etb_getm(ETB_PORT *port, const void **key, dword *mask, ETB_REC *rec, dword *rx_time, long timeout);
int     _ETB_EXPORT etb_getr(ETB_PORT *port, ETB_REC *rec, dword *rx_time, long timeout);

/*
 * boot control functions
 */
int     _ETB_EXPORT etb_change_boot_mode(ETB *etb, int mode);
int     _ETB_EXPORT etb_start_download(ETB *etb, dword mask, int block);
int     _ETB_EXPORT etb_download_segment(ETB *etb, const char *buf, size_t size);
int     _ETB_EXPORT etb_start_upload(ETB *etb, int axis, int block);
int     _ETB_EXPORT etb_upload_segment(ETB *etb, char *buf, size_t size);
int     _ETB_EXPORT etb_auto_number(ETB *etb, int start, bool save);
int		_ETB_EXPORT etb_get_block_size(int block, long *size);
bool    _ETB_EXPORT etb_is_block_available(int block, int prod);
int		_ETB_EXPORT etb_download_firmware(ETB *etb, int axis_mask, char *firmware, void (ETB_CALLBACK *user_fct)(int, int));
int		_ETB_EXPORT etb_get_firmware_info (char *firmware, ETB_FW_INFO *info);

/*
 * initialization functions
 */
ETB_DRV_INFO     _ETB_EXPORT etb_init_drv_info(void);
ETB_TIMEOUTS     _ETB_EXPORT etb_init_timeouts(void);
ETB_EXT_INFO     _ETB_EXPORT etb_init_ext_info(void);
ETB_DRV_STATUS   _ETB_EXPORT etb_init_drv_status(void);
ETB_REC_PARAM    _ETB_EXPORT etb_init_rec_param(void);
ETB_COUNTERS	 _ETB_EXPORT etb_init_counters(void);
ETB_BUS_STATUS	 _ETB_EXPORT etb_init_bus_status(void);
ETB_SVR_INFO     _ETB_EXPORT etb_init_svr_info(void);

/* debug function for dsmax2 only */
#ifdef LINUX
#ifdef __powerpc__
int _ETB_EXPORT dsmax2_set_debug_gpio1(void);
int _ETB_EXPORT dsmax2_clear_debug_gpio1(void);
int _ETB_EXPORT dsmax2_set_debug_gpio2(void);
int _ETB_EXPORT dsmax2_clear_debug_gpio2(void);
int _ETB_EXPORT dsmax2_set_debug_gpio3(void);
int _ETB_EXPORT dsmax2_clear_debug_gpio3(void);
#endif
#endif

#ifdef __cplusplus
} /* extern "C" */
#endif


/*
 * Etb handlers - c++
 */
#ifdef ETB_OO_API
struct EtbDrvHandler;
struct EtbBusHandler;
#endif

/*
 * Etb base class - c++
 */
#ifdef ETB_OO_API
class Etb {
    /*
     * some public constants
     */
public:
    enum { DRIVES = ETB_DRIVES };                    /* the maximum number of drives in a bus */
    enum { SERVERS = ETB_SERVERS };                  /* the maximum number of servers in the path */

	/* 
	 * etb special axis number
	 */ 
public:
	enum { ALL_AXIS = 0x40 };                        /* special axis value meaning all axis*/
	enum { MSK_AXIS = 0x20 };                        /* special axis value meaning masked axis */

	/*
	 * timeout special values
	 */
public:
    enum { DEF_TIMEOUT = (-2L) };                    /* use the default timeout appropriate for this communication */

    /*
     * versions access
     */
public:
    static dword getVersion() { 
        return etb_get_version(); 
    }
    static dword getEdiVersion() { 
        return etb_get_edi_version(); 
    }
    static dword getBuildTime() { 
        return etb_get_build_time(); 
    }
    static long getTimer() { 
        return etb_get_timer(); 
    }
public:
    static EtbDrvInfo etbInitDrvInfo(void) {
		EtbDrvInfo info = etb_init_drv_info();
		return info;
    }
    static EtbTimeouts etbInitTimeouts(void) {
		EtbTimeouts timeouts = etb_init_timeouts();
		return timeouts;
    }
    static EtbExtInfo etbInitExtInfo(void) {
		EtbExtInfo info = etb_init_ext_info();
		return info;
    }
    static EtbDrvStatus etbInitDrvStatus(void) {
		EtbDrvStatus status= etb_init_drv_status();
		return status;
    }
    static EtbRecParam etbInitRecParam(void) {
		EtbRecParam param = etb_init_rec_param();
		return param;
    }
    static EtbCounters etbInitCounters(void) {
		EtbCounters counters = etb_init_counters();
		return counters;
    }
    static EtbBusStatus etbInitBusStatus(void) {
		EtbBusStatus busStatus = etb_init_bus_status();
		return busStatus;
    }
    static EtbSvrInfo etbInitSvrInfo(void) {
		EtbSvrInfo info = etb_init_svr_info();
		return info;
    }
};
#endif /* ETB_OO_API */

 
/*
 * Etb exception - c++
 */
#ifdef ETB_OO_API
class EtbException {
friend class EtbBus;
friend class EtbPortBase;
friend class EtbPort;
friend class EtbSpyPort;
friend class EtbTraductor;
    /*
     * public error codes
     */
public:
    enum {EBADDRVVER = -218 };                      /* a drive with a version < 3.00 has been detected */
    enum {EBADFIRMWARE = -200 };                    /* file is not a firmware file */
    enum {EBADHOST = -253 };                        /* the specified host address cannot be translated */
    enum {EBADLIBRARY = -217 };                     /* a bad/incompatible library was found */
    enum {EBADMODE = -225 };                        /* the drive is in a bad mode */
    enum {EBADMSG = -219 };                         /* a bad message is given */
    enum {EBADOS = -270 };                          /* function unavilable on actual OS */
    enum {EBADPARAM = -215 };                       /* one of the parameter is not valid */
    enum {EBADSERVER = -224 };                      /* a bad/incompatible server was found */
    enum {EBADSTATE = -222 };                       /* this operation is not allowed in this state */
    enum {EBAUDRATE = -292 };                       /* matching baudrate not found */
    enum {EBOOTENTER = -261 };                      /* cannot enter in boot mode */
    enum {EBOOTFAILED = -229 };                     /* a problem has occured while communicating with the boot */
    enum {EBOOTHEADER = -262 };                     /* bad header in boot protocol */
    enum {EBOOTPASSWD = -260 };                     /* bad password when enter in boot mode */
    enum {EBOOTPROG = -263 };                       /* bad block programming */
    enum {EBUSERROR = -220 };                       /* the underlaying etel-bus is in error state */
    enum {EBUSRESET = -221 };                       /* the underlaying etel-bus in performing a reset operation */
    enum {ECHECKSUM = -249 };                       /* checksum error with serial communication */
    enum {ECRC = -230 };                            /* a CRC error has occured */
    enum {EFLASHDEV = -280 };                       /* unable to open flash device */
    enum {EFLASHINFO = -281 };                      /* unable to read flash information */
    enum {EFLASHNOTLOCKED = -285 };                 /* flash not locked */
    enum {EFLASHPROTECTED = -284 };                 /* flash protected */
    enum {EFLASHREAD = -282 };                      /* unable to read flash */
    enum {EFLASHWRITE = -283 };                     /* unable to write flash */
    enum {EFPGAFILENOTFOUND = -291 };               /* FPGA file is not found in path */
    enum {EGPIODEV = -286 };                        /* cannot open the gpio device */
    enum {EINTERNAL = -212 };                       /* some internal error in the etel software */
    enum {EMASTER = -213 };                         /* cannot enter or quit master mode */
    enum {ENETWORK = -252 };                        /* network problem */
    enum {ENODRIVE = -214 };                        /* the specified drive does not respond */
    enum {ENOLIBRARY = -216 };                      /* a requested library is not found */
    enum {EOPENCOM = -240 };                        /* the specified communication port cannot be opened */
    enum {EOPENSOCK = -250 };                       /* the specified socket connection cannot be opened */
    enum {ESERVER = -223 };                         /* the server has incorrect behavior */
    enum {ESOCKRESET = -251 };                      /* the socket connection has been broken by peer */
    enum {ESYSTEM = -211 };                         /* some system resource return an error */
    enum {ETIMEOUT = -210 };                        /* a timeout has occured */
    enum {EUNAVAILABLE = -290 };                    /* function not available for the driver */


    /*
     * error translation
     */
public:
    static const char *translate(int code) { 
        return etb_translate_error(code);
    }

    /*
     * exception code
     */
private:
    int code;

    /*
     * constructor
     */
protected:
    EtbException(int e) { code = e; };

    /*
     * get error description
     */
public:
    int getCode() { 
        return code; 
    }
    const char *getText() { 
        return translate(code); 
    }
};
#endif /* ETB_OO_API */


/*
 * Bus class - c++
 */
#ifdef ETB_OO_API
#define ERRCHK(a) do { int _err = (a); if (_err) throw EtbException(_err); } while(0)
class EtbBus {
friend class EtbPortBase;
friend class EtbPort;
friend class EtbSpyPort;
    /*
     * internal etb pointer
     */
protected:
    ETB *etb;

	/*
	 * open/reset/close flags
	 */
public:
    enum { FLAG_BOOT_RUN =           0x00000001 }; /* assumes that the drive is in run mode */
    enum { FLAG_BOOT_DIRECT =        0x00000002 }; /* assumes that the drive is in boot mode */
    enum { FLAG_BOOT_BRIDGE =        0x00000004 }; /* assumes that the drive is in boot bridge mode */

    enum { FLAG_MASTER_BRIDGE =      0x00000010 }; /* enter master if an axis 0 is connected */
    enum { FLAG_MASTER_EXIT =        0x00000020 }; /* return to slave mode if the axis 0 is in master mode */
    enum { FLAG_MASTER_NORMAL =      0x00000040 }; /* enter master mas.0=1 if an axis 0 is connected */
    enum { FLAG_MASTER_SPY =         0x00000080 }; /* enter master mas.!=255 */

    enum { FLAG_TIMEOUT_GUARDED =    0x00000100 }; /* check for continous connection in both pc and drive side */
    enum { FLAG_TIMEOUT_DEBUG =      0x00000200 }; /* allows disconnection of the communication - try to recover */
    enum { FLAG_TIMEOUT_DISABLE =    0x00000400 }; /* disable all timeouts on the drive side  - try to recover */

    enum { FLAG_STATUS_POLL =        0x00001000 }; /* continuously send status drive status requests */
    enum { FLAG_STATUS_OFF =         0x00002000 }; /* don't send drive status requests */
    enum { FLAG_STATUS_IRQ =         0x00004000 }; /* use drive interrupt to poll status */
	enum { FLAG_DETECT_OFF =         0x00008000 }; /* don't send any traffics without requests */

    enum { FLAG_CAN_STANDARD =       0x00100000 }; /* use CAN standard 11 bit identifiers */
    enum { FLAG_CAN_EXTENDED =       0x00200000 }; /* use CAN extended 29 bit identifiers */

    enum { FLAG_SYNCHRO_OFF =        0x01000000 }; /* communication detection and bus synchronisation off */
	enum { FLAG_ALL_REQUEST_OFF =    0x02000000 }; /* don't check present axis */
	enum { FLAG_INFO_DRIVE_OFF =     0x04000000 }; /* don't ask drivers informations */
	enum { FLAG_INFO_EXTENSION_OFF = 0x08000000 }; /* don't ask extensions informations */

	enum { FLAG_SPECIAL_SL =         0x10000000 }; /* use speed loop drive - special mode for download only */
	enum { FLAG_RESET_MASTER =       0x20000000 }; /* reset the master (used only with DSMAX) */
	enum { FLAG_RESET_SLAVES =       0x40000000 }; /* reset all slaves (used only with DSC) */
	enum { FLAG_DEBUG_MODE =         0x80000000 }; /* the communication is in a special mode for debug */

	/*
	 * boot modes
	 */
public:
    enum { BOOT_MODE_RUN = 0 };                      /* drive run mode - normal operation */
    enum { BOOT_MODE_DIRECT = 1 };                   /* direct communication to the connected drive boot */
    enum { BOOT_MODE_BRIDGE = 2 };                   /* allows access to etel bus slave boot */

	/*
	 * special axis number
	 */
public:
    enum { AXIS_AND = (-2) };                        /* and value of the status bits of all drives presents */
    enum { AXIS_OR = (-1) };                         /* or value of the status bits of all drives presents */

    /*
     * real-time modes
     */
public:
    enum { RT_ACTIVE = 1 };                          /* real-time is running */
    enum { RT_IDLE = 0 };                            /* real-time is idle */
    enum { RT_ERROR = -1 };                          /* real-time is in error */

	/*
	* watchdog flags
	*/
public:
	enum {IRQ_WATCHDOG_NEVER = 0};					 /* watchdog must not run */
	enum {IRQ_WATCHDOG_ALWAYS = 1};					 /* watchdog must run always */
	enum {IRQ__WATCHDOG_REALTIME_ONLY = 2};			 /* watchdog must run only in realtime mode*/

    /*
     * constructors
     */
public:
    EtbBus() {
		etb = NULL; 
		etb_create_bus(&etb);
	}
protected:
    EtbBus(ETB *b) { 
	    etb = b; 
	};
public:
    bool isValid() {
        return etb_is_valid_bus(etb);
    }

    /*
     * destructor function
     */
    void destroy() {
        ERRCHK(etb_destroy_bus(&etb));
    }

    /*
     * connection management functions
     */
public:
    void open(const char *s, dword flags, long baudrate = 0, long timeout = 0) {
        ERRCHK(etb_open(etb, s, flags, baudrate, timeout));
    }
    void reset(dword flags = 0, long baudrate = 0, long timeout = 0, bool deep = false) {
        ERRCHK(etb_reset(etb, flags, baudrate, timeout, deep));
    }
    void close(dword flags = 0, long timeout = 0) {
        ERRCHK(etb_close(etb, flags, timeout));
    }
    bool isOpen() {
	    bool open;
        ERRCHK(etb_is_open(etb, &open));
        return open;
    }
	void getDriver(char *buf, size_t max) {
        ERRCHK(etb_get_driver(etb, buf, max));
	}
	dword getFlags() {
		dword flags;
        ERRCHK(etb_get_flags(etb, &flags));
		return flags;
	}
	long getBaudrate() {
		long baudrate;
        ERRCHK(etb_get_baudrate(etb, &baudrate));
		return baudrate;
	}
    int activateStatus(bool on) {
		int err = etb_activate_status(etb, on);
        ERRCHK(err);
        return err;
    }


    /*
     * status/info access functions
     */
public:
    EtbBusStatus getBusStatus(int server) {
        ETB_BUS_STATUS status = etb_init_bus_status();
        ERRCHK(etb_get_bus_status(etb, server, &status));
        return status;
    }
    EtbTimeouts getBusTimeouts(long *base, long *fast, long *slow) {
        ETB_TIMEOUTS timeouts = etb_init_timeouts();
        ERRCHK(etb_get_bus_timeouts(etb, &timeouts));
        return timeouts;
    }
    EtbCounters getBusCounters(int server, long *tx, long *rx) {
        ETB_COUNTERS counters = etb_init_counters();
        ERRCHK(etb_get_bus_counters(etb, server, &counters));
        return counters;
    }
    int getSvrNumber() {
        int number;
        ERRCHK(etb_get_svr_number(etb, &number));
        return number;
    }
    EtbSvrInfo getSvrInfo(int server) {
        ETB_SVR_INFO info = etb_init_svr_info();
        ERRCHK(etb_get_svr_info(etb, server, &info));
        return info;
    }
    dword getDrvPresent() {
        dword mask;
        ERRCHK(etb_get_drv_present(etb, &mask));
        return mask;
    }
    int getDrvPeer() {
        dword peer;
        ERRCHK(etb_get_drv_peer(etb, &peer));
        return peer;
    }
    EtbDrvStatus getDrvStatus(int axis) {
        ETB_DRV_STATUS status = etb_init_drv_status();
        ERRCHK(etb_get_drv_status(etb, axis, &status));
        return status;
    }
    EtbDrvInfo getDrvInfo(int axis) {
        ETB_DRV_INFO info = etb_init_drv_info();
        ERRCHK(etb_get_drv_info(etb, axis, &info));
        return info;
    }
    EtbExtInfo getExtInfo(int axis) {
        ETB_EXT_INFO info = etb_init_ext_info();
        ERRCHK(etb_get_ext_info(etb, axis, &info));
        return info;
    }

    /*
     * handler management functions
     */
public:
    void addBusHandler(void *key, dword svr_mask, dword ev_mask, void (ETB_CALLBACK *handler)(EtbBus, int, dword, void *), void *param) {
        ERRCHK(etb_add_bus_handler(etb, key, svr_mask, ev_mask, (void (ETB_CALLBACK *)(ETB *, int, dword, void *))handler, param));
    }
    void removeBusHandler(void *key) {
        ERRCHK(etb_remove_bus_handler(etb, key));
    }
    void addDrvHandler(void *key, dword axis_mask, bool and_mask, bool or_mask, dword ev_mask, void (ETB_CALLBACK *handler)(EtbBus, int, dword, void *), void *param) {
        ERRCHK(etb_add_drv_handler(etb, key, axis_mask, and_mask, or_mask, ev_mask, (void (ETB_CALLBACK *)(ETB *, int, dword, void *))handler, param));
    }
    void removeDrvHandler(void *key) {
        ERRCHK(etb_remove_drv_handler(etb, key));
    }
    void addRTHandler(void *key, dword axis_mask, int (ETB_CALLBACK *handler)(EtbBus, int, long *, void *), void *param) {
        ERRCHK(etb_add_rt_handler(etb, key, axis_mask, (int (ETB_CALLBACK *)(ETB *, int, long *, void *))handler, param));
    }
    void removeRTHandler(void *key) {
        ERRCHK(etb_remove_rt_handler(etb, key));
    }

    /*
     * transaction support
     */
    void beginTrans(long timeout) {
        ERRCHK(etb_begin_trans(etb, timeout));
    }
    void endTrans() {
        ERRCHK(etb_end_trans(etb));
    }

    /*
     * boot control functions
     */
public:
    void changeBootMode(int mode) {
        ERRCHK(etb_change_boot_mode(etb, mode));
    }
    void startDownload(int axis, int block) {
        ERRCHK(etb_start_download(etb, axis, block));
    }
    void downloadSegment(const char *buf, size_t size) {
        ERRCHK(etb_download_segment(etb, buf, size));
    }
    void startUpload(int axis, int block) {
        ERRCHK(etb_start_upload(etb, axis, block));
    }
    void uploadSegment(char *buf, size_t size) {
        ERRCHK(etb_upload_segment(etb, buf, size));
    }
    void autoNumber(int start, bool save) {
        ERRCHK(etb_auto_number(etb, start, save));
    }
    long getBlockSize(int block) {
		long size;
		ERRCHK(etb_get_block_size(block, &size));
		return size;
    }
	void multiSend(int nb_rec, ETB_REC send_table[], dword mask_table[], ETB_REC recv_table[], dword time_table[], int timeout) {
		ERRCHK(etb_multi_send(etb, nb_rec, send_table, mask_table, recv_table, time_table, timeout));
	}
	void startRTM(ETB_TRAJECTORY_HANDLER get_trajectory_point) {
		ERRCHK(etb_start_rtm(etb, get_trajectory_point));
	}
	void stopRTM(void) {
		ERRCHK(etb_stop_rtm(etb));
	}
	void initRTM(ETB_RTM_AXISMASK realtime_axis) {
		ERRCHK(etb_init_rtm_fct(etb, realtime_axis));
	}
	void setPrio(int prio) {
        ERRCHK(etb_set_prio(etb, prio));
    }
	void setRates(int irq_rate, int status_rate, int mon_rate, int fast_rate, int slow_rate) {
		ERRCHK(etb_set_rates(etb, irq_rate, status_rate, mon_rate, fast_rate, slow_rate));
	}
    void getRTMMon(ETB_RTM *rtm_mon) {
        ERRCHK(etb_get_rtm_mon(etb, rtm_mon));
    }
	void linkError(bool on) {
		ERRCHK(etb_link_error(etb, on));
	}
	void irq_watchdog(int watchdog) {
		ERRCHK(etb_irq_watchdog(etb, watchdog));
	}
};
#endif /* ETB_OO_API */

/*
 * Port Base class - c++
 */
#ifdef ETB_OO_API
class EtbPortBase {
    /*
     * internal etb pointer
     */
protected:
    ETB_PORT *port;

public:
    bool isValid() {
        return etb_is_valid_port(port);
    }
	EtbBus getBus() {
		ETB *etb;
		ERRCHK(etb_get_bus(port, &etb));
		EtbBus bus(etb);
		return bus;
	}

    /*
     * handler management functions
     */
public:
    void addMsgHandler(void *key, void (ETB_CALLBACK *handler)(EtbPort, void *), void *param) {
        ERRCHK(etb_add_msg_handler(port, key, (void (ETB_CALLBACK *)(ETB_PORT *, void *))handler, param));
    }
    void removeMsgHandler(void *key) {
        ERRCHK(etb_remove_msg_handler(port, key));
    }

    /*
     * message handling functions
     */
public:
    EtbRec getMsg(dword *mask, const void **key = NULL, dword *rx_time = NULL, long timeout = 0) {
        EtbRec rec;
        ERRCHK(etb_getm(port, key, mask, (ETB_REC *)&rec, rx_time, timeout));
        return rec;
    }
    EtbRec getRec(dword *rx_time = NULL, long timeout = 0) {
        EtbRec rec;
        ERRCHK(etb_getr(port, (ETB_REC *)&rec, rx_time, timeout));
        return rec;
    }
};
#endif /* ETB_OO_API */

/*
 * Port class - c++
 */
#ifdef ETB_OO_API
class EtbPort : public EtbPortBase {
    /*
     * constructors
     */
public:
    EtbPort(EtbBus etb) {
		port = NULL; 
		etb_create_port(&port, etb.etb);
	}
protected:
    EtbPort(ETB_PORT *p) { 
	    port = p; 
	};

    /*
     * destructor function
     */
public:
    void destroy() {
        ERRCHK(etb_destroy_port(&port));
    }

    /*
     * message handling functions
     */
public:
    void putMsg(dword mask, const EtbRec &rec, const void *key = NULL, long timeout = 0) {
        ERRCHK(etb_putm(port, key, mask, (const ETB_REC *)&rec, timeout));
    }
    void putRec(const EtbRec &rec, long timeout = 0) {
        ERRCHK(etb_putr(port, (const ETB_REC *)&rec, timeout));
    }
};
#endif /* ETB_OO_API */

/*
 * Spy Port class - c++
 */
#ifdef ETB_OO_API
class EtbSpyPort : public EtbPortBase {
	/*
     * constructors
     */
public:
    EtbSpyPort(EtbBus etb) {
		port = NULL; 
		etb_create_spy_port(&port, etb.etb);
	}
protected:
    EtbSpyPort(ETB_PORT *p) { 
	    port = p; 
	};

    /*
     * destructor function
     */
public:
    void destroy() {
        ERRCHK(etb_destroy_spy_port(&port));
    }
};
#endif /* ETB_OO_API */

#undef ERRCHK

#endif /* _ETB10_H */
