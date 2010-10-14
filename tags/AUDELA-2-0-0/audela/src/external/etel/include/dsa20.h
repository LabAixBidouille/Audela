/*
 * dsa20.h 2.00
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
 * This header file contains public declarations for the high level library.\n
 * This library allows access to ETEL hardware like drives, dsmax, etc...\n
 * Once connected, it is possible to get and set registers, executing command
 * and different functions on the hardware itself.\n
 * This library is conformed to POSIX 1003.1c, and has been ported on the following OS:
 * @li @c WIN32
 * @li @c QNX4
 * @li @c QNX6
 * @li @c LINUX
 * @li @c LYNXOS
 * @li @c SOLARIS SPARC 5
 * @li @c SOLARIS X86
 * @file dsa20.h
 */


#ifndef _DSA20_H
#define _DSA20_H


/*** libraries ***/

#include <stdio.h>
#include <stddef.h>
#include <stdarg.h>
#include <time.h>
#ifdef __cplusplus
#include <typeinfo.h>
#ifndef bad_cast
#include <stdexcept>
using namespace std;
#define bad_cast invalid_argument
#endif
#endif



/*** litterals ***/

#ifdef __WIN32__		/* defined by Borland C++ Builder */
#ifndef WIN32
#define WIN32
#endif
#endif

#ifdef __cplusplus
#ifdef ETEL_OO_API		/* defined by the user when he need the Object Oriented interface */
#define DSA_OO_API
#endif
#endif 

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

#ifdef WIN32
#define DSA_DRIVES 32
#endif
#ifdef QNX4
#define DSA_DRIVES 32
#endif /* QNX4 */
#ifdef POSIX
#define DSA_DRIVES 32
#endif /* POSIX */

/*
 * flags
 */
#define DSA_FLAG_RELAX_DRV_CHECK	0x00000001	/**< allow the use of unknowed drv version */
#define DSA_FLAG_DISABLE_ISO_CONV	0x00000002  /**< disable all request of drv unit informations */

/*
 * error codes - c
 */
#define DSA_EBADIPOLGRP                  -327        /**< the ipol group is not correctly defined */
#define DSA_ENOTIMPLEMENTED              -326        /**< the specified operation is not implemented */
#define DSA_EBADDRVVER                   -325        /**< a drive with a bad version has been detected */
#define DSA_EBADSTATE                    -324        /**< this operation is not allowed in this state */
#define DSA_EDRVFAILED                   -323        /**< the drive does not operate properly */
#define DSA_EBADPARAM                    -322        /**< one of the parameter is not valid */
#define DSA_EOPENPORT                    -321        /**< the specified port cannot be open */
#define DSA_ENODRIVE                     -320        /**< the specified drive does not respond */
#define DSA_ECANCEL                      -319        /**< the transaction has been canceled */
#define DSA_ETRANS                       -318        /**< a transaction error has occured */
#define DSA_ECONVERT                     -317        /**< a parameter exceeded the permitted range */
#define DSA_EINTERNAL                    -316        /**< some internal error in the etel software */
#define DSA_ESYSTEM                      -315        /**< some system resource return an error */
#define DSA_EBUSRESET                    -314        /**< the underlaying etel-bus in performing a reset operation */
#define DSA_EBUSERROR                    -313        /**< the underlaying etel-bus is not working fine */
#define DSA_ENOACK                       -312        /**< no acknowledge from the drive */
#define DSA_EDRVERROR                    -311        /**< drive in error */
#define DSA_ETIMEOUT                     -310        /**< a timeout has occured */


/*
 * convert special value / macro
 */
#ifndef DSA_OO_API
#define DSA_CONV_AUTO                    (-1)        /**< try to use the conversion appropriate for this operation */
#endif

/*
 * timeout special values
 */
#ifndef INFINITE
#define INFINITE                         0xFFFFFFFF  /**< infinite timeout */
#endif
#ifndef DSA_OO_API
#define DSA_DEF_TIMEOUT                  (-2L)       /**< use the default timeout appropriate for this communication */
#endif

/*
 * register kind of access
 */
#ifndef DSA_OO_API
#define DSA_GET_CURRENT                  0           /**< get current value, bypass pending commands */
#define DSA_GET_WAITING                  1           /**< get current value, waiting pending commands */
#define DSA_GET_TRACE_CURRENT            2           /**< get trace array, bypass pending commands */
#define DSA_GET_TRACE_WAITING            3           /**< get trace array, waiting pending commands */
#define DSA_GET_CONV_FACTOR              10          /**< get the conversion factor */
#define DSA_GET_MIN_VALUE                11          /**< get the minimum value */
#define DSA_GET_MAX_VALUE                12          /**< get the maximum value */
#define DSA_GET_DEF_VALUE                13          /**< get the default value */
#endif /* DSA_OO_API */

/*
 * status warning bits
 */
#ifndef DSA_OO_API
#define DSA_SW1_W_I2T_OVER_CURRENT        0x01   /**< the i2t integral is > 50% k85 limit */
#define DSA_SW1_W_OVER_TEMPERATURE        0x02   /**< the driver's temperature is > 50°C */
#define DSA_SW1_W_ENCODER_AMPLITUDE       0x10   /**< the encoder signals amplitude is < 10% */
#define DSA_SW1_W_TRACKING_ERROR          0x20   /**< position error is > 50% k30 limit */
#endif /* DSA_OO_API */

/*
 * status error bits
 */
#ifndef DSA_OO_API
#define DSA_SW1_E_CURRENT                 0x01   /**< current error */
#define DSA_SW1_E_CONTROLLER              0x02   /**< controller error */
#define DSA_SW1_E_ETEL_BUS                0x04   /**< etel-bus error */
#define DSA_SW1_E_TRAJECTORY              0x08   /**< trajectory error */
#define DSA_SW1_E_ETEL_BUS_LITE           0x10   /**< etel-bus-lite error */
#define DSA_SW1_E_OTHER_AXIS              0x80   /**< other-axis error */
#endif /* DSA_OO_API */

/*
 * parameters enumeration values - c
 */
#ifndef DSA_OO_API
#define DSA_CTRL_ENABLE_AUTO             170         /* enable signal perform automatic power on of the drive */
#define DSA_CTRL_ENABLE_NOT_USED         125         /* enable signal not used */
#define DSA_CTRL_ENABLE_USED             0           /* enable signal is necessary to power on ths drive */
#define DSA_CTRL_FORCE_REFERENCE         0           /* driver controlled by a force reference */
#define DSA_CTRL_HOME_INVERTED           2           /* home switch is inverted */
#define DSA_CTRL_HOME_SWITCH             128         /* home switch is used */
#define DSA_CTRL_LIMIT_SWITCH            1           /* limit switch are used */
#define DSA_CTRL_POSITION_PROFILE        1           /* standard position profile mode */
#define DSA_CTRL_POSITION_REFERENCE      4           /* driver controlled by a position reference */
#define DSA_CTRL_PULSE_DIRECTION         5           /* pulse and direction mode */
#define DSA_CTRL_PULSE_DIRECTION_TTL     6           /* pulse and direction mode with TTL encoder */
#define DSA_CTRL_REGEN_LIMITED           2           /* regeneration of, max 10s */
#define DSA_CTRL_REGEN_OFF               0           /* no regeneration */
#define DSA_CTRL_REGEN_ON                3           /* regeneration always on */
#define DSA_CTRL_SOURCE_MONITORING       3           /* monitoring of a monitoring register */
#define DSA_CTRL_SOURCE_PARAMETER        2           /* monitoring of a parameter */
#define DSA_CTRL_SOURCE_USER_VARIABLE    1           /* monitoring of a user variable */
#define DSA_CTRL_SPEED_REFERENCE         3           /* driver controlled by a speed reference */
#define DSA_DRIVE_DISPLAY_ENCODER_SIGNAL 4           /* display encoder's signals */
#define DSA_DRIVE_DISPLAY_NORMAL         1           /* display normal informations */
#define DSA_DRIVE_DISPLAY_SEQUENCE       8           /* display sequence line number */
#define DSA_DRIVE_DISPLAY_TEMPERATURE    2           /* display drive's temperature */
#define DSA_HOMING_GATED_INDEX_NEG       17          /*  */
#define DSA_HOMING_GATED_INDEX_NEG_L     19          /*  */
#define DSA_HOMING_GATED_INDEX_POS       16          /*  */
#define DSA_HOMING_GATED_INDEX_POS_L     18          /*  */
#define DSA_HOMING_HOME_SW_NEG           3           /*  */
#define DSA_HOMING_HOME_SW_NEG_L         7           /*  */
#define DSA_HOMING_HOME_SW_POS           2           /*  */
#define DSA_HOMING_HOME_SW_POS_L         6           /*  */
#define DSA_HOMING_LIMIT_SW_NEG          5           /*  */
#define DSA_HOMING_LIMIT_SW_POS          4           /*  */
#define DSA_HOMING_MECHANICAL_NEG        1           /*  */
#define DSA_HOMING_MECHANICAL_POS        0           /*  */
#define DSA_HOMING_MULTI_INDEX_NEG       13          /*  */
#define DSA_HOMING_MULTI_INDEX_NEG_L     15          /*  */
#define DSA_HOMING_MULTI_INDEX_POS       12          /*  */
#define DSA_HOMING_MULTI_INDEX_POS_L     14          /*  */
#define DSA_HOMING_SINGLE_INDEX_NEG      9           /*  */
#define DSA_HOMING_SINGLE_INDEX_NEG_L    11          /*  */
#define DSA_HOMING_SINGLE_INDEX_POS      8           /*  */
#define DSA_HOMING_SINGLE_INDEX_POS_L    10          /*  */
#define DSA_INIT_CONTINUOUS_CURRENT      2           /* initialisation by sending continous to the motor */
#define DSA_INIT_CURRENT_PULSE           1           /* initialisation with current pulses */
#define DSA_INIT_NO_INIT                 0           /* no initialisation */
#define DSA_MON_SOURCE_MONITORING        3           /* monitoring of a monitoring register */
#define DSA_MON_SOURCE_OFF               0           /* no real time monitoring */
#define DSA_MON_SOURCE_PARAMETER         2           /* monitoring of a parameter */
#define DSA_MON_SOURCE_USER_VARIABLE     1           /* monitoring of a user variable */
#define DSA_MOTOR_INVERT_FORCE           2           /* invert current force of the motor */
#define DSA_MOTOR_INVERT_PHASES          1           /* invert phases 1 and 2 of the motor */
#define DSA_PARAM_DEFAULT_ALL            0           /* restore all informations from ROM default */
#define DSA_PARAM_DEFAULT_SEQ_LKT        1           /* restore sequence and user lookup-tables from ROM default */
#define DSA_PARAM_DEFAULT_X_PARAMS       2           /* restore user (X) registers and parameters from ROM default */
#define DSA_PARAM_LOAD_ALL               0           /* load all informations from flash memory */
#define DSA_PARAM_LOAD_SEQ_LKT           1           /* load sequence and user lookup-tables from flash memory */
#define DSA_PARAM_LOAD_X_PARAMS          2           /* load user (X) registers and parameters from flash memory */
#define DSA_PARAM_SAVE_ALL               0           /* save all informations in flash memory */
#define DSA_PARAM_SAVE_SEQ_LKT           1           /* save sequence and user lookup-tables in flash memory */
#define DSA_PARAM_SAVE_X_PARAMS          2           /* save user (X) registers and parameters in flash memory */
#define DSA_PL_INTEGRATOR_IN_POSITION    1           /* integrator off during motion */
#define DSA_PL_INTEGRATOR_OFF            2           /* integrator always off */
#define DSA_PL_INTEGRATOR_ON             0           /* integrator always on */
#define DSA_PROFILE_FAST_LKT_MVT         11          /* lookup-table motion in controller interrupt */
#define DSA_PROFILE_INFINITE_ROTARY_MVT  12          /* infinite rotary motion (deprecated) */
#define DSA_PROFILE_RECTANGULAR_MVT      2           /* trapezoidal motion (jerk = 0, acc = infinite) */
#define DSA_PROFILE_S_CURVE_MVT          1           /* s-curve motion */
#define DSA_PROFILE_SLOW_LKT_MVT         10          /* lookup-table motion in profile interrupt */
#define DSA_PROFILE_TRAPEZIODAL_MVT      0           /* trapezoidal motion (jerk = infinite, deprecated) */
#define DSA_QS_BYPASS                    2           /* bypass all pending command */
#define DSA_QS_INFINITE_DEC              1           /* stop motor with infinite deceleration (step) */
#define DSA_QS_POWER_OFF                 0           /* switch off power bridge */
#define DSA_QS_PROGRAMMED_DEC            2           /* stop motor with programmed deceleration */
#define DSA_QS_STOP_SEQUENCE             1           /* also stop the sequence */
#define DSA_SYSTEM_ANALOG                0           /* analog sine/cosine encoder */
#define DSA_SYSTEM_HALL                  2           /* HALL effect encoder */
#define DSA_SYSTEM_TTL                   1           /* TTL encoder */

#endif /* DSA_OO_API */


/*** macros ***/

#ifdef WIN32
#ifndef DSA_VB
#define DSA_IMPL_A
#endif /* DSA_VB */
#define DSA_IMPL_S
#define DSA_IMPL_G
#endif /* WIN32 */

#ifdef QNX4
#define DSA_IMPL_A
#define DSA_IMPL_S
#define DSA_IMPL_G
#endif /* QNX4 */

#ifdef POSIX
#define DSA_IMPL_A
#define DSA_IMPL_S
#define DSA_IMPL_G
#endif /* POSIX */

/* 
 * conversion macros
 */ 
#define DSA_REG_CONV(typ, idx, sidx)     (0x10000000 + ((typ)<<24) + ((sidx)<<16) + (idx))
#define DSA_PPK_CONV(idx, sidx)          (0x12000000 + ((sidx)<<16) + (idx))
#define DSA_MON_CONV(idx, sidx)          (0x13000000 + ((sidx)<<16) + (idx))
#define DSA_CMD_CONV(typ, idx, par)      (0x20000000 + ((typ)<<24) + ((par)<<16) + (idx))

#define DSA_GET_CONV_KIND(code)          (((unsigned)(code)) >> 28)
#define DSA_GET_CONV_TYP(code)           (((code) >> 24) & 0x0FU)
#define DSA_GET_CONV_IDX(code)           ((code) & 0xFFFFUL)
#define DSA_GET_CONV_PAR(code)           (((code) >> 16) & 0xFFU)
#define DSA_GET_CONV_SIDX(code)          (((code) >> 16) & 0xFFU)

/* 
 * diagnostic macros
 */
#define DSA_DIAG(err, dev)						(dsa_diag(__FILE__, __LINE__, err, dev))
#define DSA_SDIAG(str, err, dev)				(dsa_sdiag(str, __FILE__, __LINE__, err, dev))
#define DSA_FDIAG(output_file_name, err, dev)	(dsa_fdiag(output_file_name, __FILE__, __LINE__, err, dev))

/*** types ***/

/* 
 * type modifiers
 */
#ifdef WIN32
#define _DSA_EXPORT __cdecl                          /* function exported by static library */
#define DSA_CALLBACK __cdecl                         /* client callback function called by library */
#endif /* WIN32 */

#ifdef QNX4
#define _DSA_EXPORT __cdecl                          /* function exported by library */
#define DSA_CALLBACK __cdecl                         /* client callback function called by library */
#endif /* QNX4 */

#ifdef POSIX
#define _DSA_EXPORT                           /* function exported by library */
#define DSA_CALLBACK                          /* client callback function called by library */
#endif /* POSIX */
/* 
 * hidden structure for library clients
 */
#ifndef ETB
#define ETB void
struct EtbBus { ETB *etb; };
#endif
#ifndef DSA_DEVICE_BASE
#define DSA_DEVICE_BASE void
#endif
#ifndef DSA_DEVICE
#define DSA_DEVICE void
#endif
#ifndef DSA_DEVICE_GROUP
#define DSA_DEVICE_GROUP void
#endif
#ifndef DSA_DRIVE_BASE
#define DSA_DRIVE_BASE void
#endif
#ifndef DSA_DRIVE
#define DSA_DRIVE void
#endif
#ifndef DSA_DRIVE_GROUP
#define DSA_DRIVE_GROUP void
#endif
#ifndef DSA_GANTRY
#define DSA_GANTRY void
#endif
#ifndef DSA_DSMAX_BASE
#define DSA_DSMAX_BASE void
#endif
#ifndef DSA_DSMAX
#define DSA_DSMAX void
#endif
#ifndef DSA_DSMAX_GROUP
#define DSA_DSMAX_GROUP void
#endif
#ifndef DSA_IPOL_GROUP
#define DSA_IPOL_GROUP void
#endif
#ifndef DSA_GP_MODULE_BASE
#define DSA_GP_MODULE_BASE void
#endif
#ifndef DSA_GP_MODULE
#define DSA_GP_MODULE void
#endif
#ifndef DSA_GP_MODULE_GROUP
#define DSA_GP_MODULE_GROUP void
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
#endif
#ifndef __cplusplus
#ifndef __BOOL
#define __BOOL
typedef byte bool;
#endif
#endif

/**
 * @struct DSA_SW1
 * etel bus drive status word 1 when acces through M60
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN	
typedef struct DSA_SW1 {
	#ifndef DSA_OO_API
	unsigned power_on:1;                         /**< The power is applied to the motor */
	unsigned init_done:1;                        /**< The initialisation procedure has been done */
	unsigned homing_done:1;                      /**< The homing procedure has been done */
	unsigned present:1;                          /**< The drive is present */
	unsigned moving:1;                           /**< The motor is moving */
	unsigned in_window:1;                        /**< The motor is the target windows */
	unsigned master:1;                           /**< The drive is in master mode */
	unsigned busy:1;                             /**< The drive is busy */
	unsigned exec_seq:1;                         /**< A sequence is running */
	unsigned edit_mode:1;                        /**< The sequence can be edited */
	unsigned fatal:1;                            /**< Fatal error */
	unsigned trace_busy:1;                       /**< The aquisition of the trace is not finished */
	unsigned bridge:1;                           /**< The drive is in bridge mode */
	unsigned homing:1;                           /**< The motor is homing */
	unsigned ebl_to_eb:1;                        /**< The EBL is routed transparentrly to EB (download) */
	unsigned spy:1;                              /**< A slave is used as a spy: master of labView channel */
	unsigned warning:8;                          /**< Warning mask */
	unsigned error:8;                            /**< Error mask */
	#else /* DSA_OO_API */

	/*
	 * status warning bits
	 */
public:
	enum { W_I2T_OVER_CURRENT = 0x01 };          /* the i2t integral is > 50% k85 limit */
	enum { W_OVER_TEMPERATURE = 0x02 };          /* the driver's temperature is > 50°C */
	enum { W_ENCODER_AMPLITUDE = 0x10 };         /* the encoder signals amplitude is < 10% */
	enum { W_TRACKING_ERROR = 0x20 };            /* position error is > 50% k30 limit */

	/*
	 * status error bits
	 */
public:
	enum { E_CURRENT = 0x01 };                   /* current error */
	enum { E_CONTROLLER = 0x02 };                /* controller error */
	enum { E_ETEL_BUS = 0x04 };                  /* etel-bus error */
	enum { E_TRAJECTORY = 0x08 };                /* trajectory error */
	enum { E_ETEL_BUS_LITE = 0x10 };             /* etel-bus-lite error */
	enum { E_OTHER_AXIS = 0x80 };                /* other-axis error */

	unsigned powerOn:1;                          /* the power is applied to the motor */
	unsigned initDone:1;                         /* the initialisation procedure has been done */
	unsigned homingDone:1;                       /* the homing procedure has been done */
	unsigned present:1;                          /* the drive is present */
	unsigned moving:1;                           /* the motor is moving */
	unsigned inWindow:1;                         /* the motor is the target windows */
	unsigned master:1;                           /* the drive is in master mode */
	unsigned busy:1;                             /* the drive is busy */
	unsigned execSeq:1;                          /* a sequence is running */
	unsigned editMode:1;                         /* the sequence can be edited */
	unsigned fatal:1;                            /* fatal error */
	unsigned traceBusy:1;                        /* the aquisition of the trace is not finished */
	unsigned bridge:1;                           /* the drive is in bridge mode */
	unsigned homing:1;                           /* the motor is homing */
	unsigned eblToEb:1;                          /* the EBL is routed transparentrly to EB (download) */
	unsigned spy:1;                              /* a slave is used as a spy: master of labView channel */
	unsigned warning:8;                          /* warning mask */
	unsigned error:8;                            /* error mask */
	#endif /* DSA_OO_API */
} DSA_SW1;

#else /*__BYTE_ORDER == __BIG_ENDIAN*/

typedef struct DSA_SW1 {
	#ifndef DSA_OO_API
	unsigned error:8;                            /**< Eror mask */
	unsigned warning:8;                          /**< Wrning mask */
	unsigned spy:1;                              /**< Aslave is used as a spy: master of labView channel */
	unsigned ebl_to_eb:1;                        /**< The EBL is routed transparentrly to EB (download) */
	unsigned homing:1;                           /**< The motor is homing */
	unsigned bridge:1;                           /**< The drive is in bridge mode */
	unsigned trace_busy:1;                       /**< The aquisition of the trace is not finished */
	unsigned fatal:1;                            /**< Fatal error */
	unsigned edit_mode:1;                        /**< The sequence can be edited */
	unsigned exec_seq:1;                         /**< A sequence is running */
	unsigned busy:1;                             /**< The drive is busy */
	unsigned master:1;                           /**< The drive is in master mode */
	unsigned in_window:1;                        /**< The motor is the target windows */
	unsigned moving:1;                           /**< The motor is moving */
	unsigned present:1;                          /**< The drive is present */
	unsigned homing_done:1;                      /**< The homing procedure has been done */
	unsigned init_done:1;                        /**< The initialisation procedure has been done */
	unsigned power_on:1;                         /**< The power is applied to the motor */
	#else /* DSA_OO_API */

	/*
	 * status warning bits
	 */
public:
	enum { W_I2T_OVER_CURRENT = 0x01 };          /* the i2t integral is > 50% k85 limit */
	enum { W_OVER_TEMPERATURE = 0x02 };          /* the driver's temperature is > 50°C */
	enum { W_ENCODER_AMPLITUDE = 0x10 };         /* the encoder signals amplitude is < 10% */
	enum { W_TRACKING_ERROR = 0x20 };            /* position error is > 50% k30 limit */

	/*
	 * status error bits
	 */
public:
	enum { E_CURRENT = 0x01 };                   /* current error */
	enum { E_CONTROLLER = 0x02 };                /* controller error */
	enum { E_ETEL_BUS = 0x04 };                  /* etel-bus error */
	enum { E_TRAJECTORY = 0x08 };                /* trajectory error */
	enum { E_ETEL_BUS_LITE = 0x10 };             /* etel-bus-lite error */
	enum { E_OTHER_AXIS = 0x80 };                /* other-axis error */

	unsigned error:8;                            /* error mask */
	unsigned warning:8;                          /* warning mask */
	unsigned spy:1;                              /* a slave is used as a spy: master of labView channel */
	unsigned eblToEb:1;                          /* the EBL is routed transparentrly to EB (download) */
	unsigned homing:1;                           /* the motor is homing */
	unsigned bridge:1;                           /* the drive is in bridge mode */
	unsigned traceBusy:1;                        /* the aquisition of the trace is not finished */
	unsigned fatal:1;                            /* fatal error */
	unsigned editMode:1;                         /* the sequence can be edited */
	unsigned execSeq:1;                          /* a sequence is running */
	unsigned busy:1;                             /* the drive is busy */
	unsigned master:1;                           /* the drive is in master mode */
	unsigned inWindow:1;                         /* the motor is the target windows */
	unsigned moving:1;                           /* the motor is moving */
	unsigned present:1;                          /* the drive is present */
	unsigned homingDone:1;                       /* the homing procedure has been done */
	unsigned initDone:1;                         /* the initialisation procedure has been done */
	unsigned powerOn:1;                          /* the power is applied to the motor */
	#endif /* DSA_OO_API */
} DSA_SW1;
#endif /*__BYTE_ORDER*/

/**
 * @struct DSA_SW2
 * etel bus drive status word 2 when acces through M61
 */
#if __BYTE_ORDER == __LITTLE_ENDIAN	
typedef struct DSA_SW2 {
	#ifndef DSA_OO_API
	unsigned seq_error:1;                       /**< Error label has been executed */
	unsigned seq_warning:1;                     /**< Warning label has been executed */
	unsigned save_pos:1;                        /**< Position has been reached */
	unsigned :5;								
	unsigned user:8;                            /**< User status */
	unsigned :12;								
	unsigned dll:4;                             /**< Used internally by dlls */
	#else /* DSA_OO_API */
	unsigned seqError:1;                        /* error label has been executed */
	unsigned seqWarning:1;                      /* warning label has been executed */
	unsigned savePos:1;                         /* Position has been reached */
	unsigned :5;							
	unsigned user:8;                            /* user status */
	unsigned :12;							
	unsigned dll:4;                             /* used internally by dlls */
	#endif /* DSA_OO_API */
} DSA_SW2;

#else /*__BYTE_ORDER == __BIG_ENDIAN*/

typedef struct DSA_SW2 {
	#ifndef DSA_OO_API
	unsigned dll:4;                             /**< Used internally by dlls */
	unsigned :12;								
	unsigned user:8;                            /**< User status */
	unsigned :5;								
	unsigned save_pos:1;                        /**< Position has been reached */
	unsigned seq_warning:1;                     /**< Warning label has been executed */
	unsigned seq_error:1;                       /**< Error label has been executed */
	#else /* DSA_OO_API */
	unsigned dll:4;                             /* used internally by dlls */
	unsigned :12;								
	unsigned user:8;                            /* user status */
	unsigned :5;							
	unsigned savePos:1;                         /* Position has been reached */
	unsigned seqWarning:1;                      /* warning label has been executed */
	unsigned seqError:1;                        /* error label has been executed */
	#endif /* DSA_OO_API */
} DSA_SW2;
#endif/*__BYTE_ORDER*/

/**
 * @struct DsaStatusSWMode
 * Allow access to drive status with DSA_SW1 and DSA_SW2 members
 */
typedef struct DsaStatusSWMode {
	size_t size;								/**< The size of the structure */
	DSA_SW1 sw1;								/**< Drive status SW1 */
	DSA_SW2 sw2;								/**< Drive status SW2 */
} DsaStatusSWMode;

/**
 * @struct DsaStatusRawMode
 * Allow access to drive status with dword members
 */
typedef struct DsaStatusRawMode {
	size_t size;								/**< The size of the structure */
	dword sw1;									/**< Drive status SW1 in dword type */
	dword sw2;									/**< Drive status SW2 in dword type */
} DsaStatusRawMode;

#if __BYTE_ORDER == __LITTLE_ENDIAN	
/**
 * @struct DsaStatusDriveBitMode
 * Allow access to drive status with bit members when acces through M63
 */
typedef struct DsaStatusDriveBitMode {
	size_t size;								/**< The size of the structure */
	#ifndef DSA_OO_API			
	unsigned power_on:1;						/**< The drive is in power on */
	unsigned :2;								
	unsigned present:1;							/**< The drive is present */
	unsigned moving:1;                          /**< The motor is moving */
	unsigned in_window:1;						/**< The motor's position is in window */
	unsigned :2;								
	unsigned sequence:1;                        /**< A sequence is running */
	unsigned :1;								
	unsigned error:1;                           /**< Fatal error */
	unsigned trace:1;							/**< The aquisition of the trace is not finished */
	unsigned :4;								
	unsigned :7;								
	unsigned warning:1;				 			/**< Gglobal warning */
	unsigned :8;								
	unsigned :2;								
	unsigned save_pos:1;                        /**< Position has been reached */
    unsigned :1;
    unsigned breakpoint:1;						/**< Breakpoint is reached */
	unsigned :3;								
	unsigned user:16;                           /**< User status */
	unsigned :8;								
	#else /* DSA_OO_API */
	unsigned powerOn:1;							/* The drive is in power on*/
	unsigned :2;								/* Reserved */
	unsigned present:1;							/* The drive is present */
	unsigned moving:1;                          /* The motor is moving */
	unsigned inWindow:1;						/* The motor's position is in window */
	unsigned :2;								/* Reserved */
	unsigned sequence:1;                        /* A sequence is running */
	unsigned :1;								/* Reserved */
	unsigned error:1;                           /* Fatal error */
	unsigned trace:1;							/* The aquisition of the trace is not finished */
	unsigned :4;								/* Reserved */
	unsigned :7;								/* Reserved */
	unsigned warning:1;				 			/* Global warning */
	unsigned :8;								/* Reserved */
    unsigned :2;
    unsigned savePos:1;                         /* Position has been reached */
	unsigned :1;								/* Reserved */
	unsigned breakpoint:1;						/* Breakpoint is reached */
	unsigned :3;								/* Reserved */
	unsigned user:16;                           /* User status */
	unsigned :8;								/* Reserved */
	#endif /* DSA_OO_API */
} DsaStatusDriveBitMode;

/**
 * @struct DsaStatusDsmaxBitMode
 * Allow access to dsmax status with bit members when acces through M63
 */
typedef struct DsaStatusDsmaxBitMode {
	size_t size;								/**< The size of the structure */
	unsigned :3;								
	unsigned present:1;                         /**< The Dsmax is present */
	unsigned moving:1;                          /**< An axis (of ipol group 0 or 1) is moving */
	unsigned :3;								
	unsigned sequence:1;                        /**< A sequence is running */
	unsigned :1;								
	unsigned error:1;                           /**< Fatal error */
	unsigned trace:1;							/**< The aquisition of the trace is not finished */
	unsigned ipol0_moving:1;					/**< Ipol group 0 is moving */
	unsigned ipol1_moving:1;					/**< Ipol group 1 is moving */
	unsigned :2;
	unsigned :7;								
	unsigned warning:1;				 			/**< Global warning */
	unsigned :8;								
	unsigned :4;								
	unsigned breakpoint:1;						/**< Breakpoint is reached */
	unsigned :3;								
	unsigned user:16;                           /**< User status */
	unsigned :8;								
} DsaStatusDsmaxBitMode;

/**
 * @struct DsaStatusGPModuleBitMode
 * Allow access to general purpose module status with bit members
 */
typedef struct DsaStatusGPModuleBitMode {
	size_t size;								/**< The size of the structure */
	unsigned reserved1:1;						/**< Reserved for power on */
	unsigned :2;								
	unsigned present:1;							/**< The gp_module is present */
	unsigned reserved2:1;                       /**< Reserved for moving */
	unsigned reserved3:1;						/**< Reserved for in window */
	unsigned :2;								
	unsigned reserved4:1;                       /**< Reserved for sequence running */
	unsigned :1;								
	unsigned error:1;							/**< Fatal error */
	unsigned trace:1;							/**< The aquisition of the trace is not finished*/
	unsigned :4;								
	unsigned :7;								
	unsigned warning:1;				 			/**< Global warning */
	unsigned :8;								
	unsigned :2;                                
    unsigned reserved9:1;                       /**< Reserved for position has been reached */
	unsigned :1;								
	unsigned reserved8:1;						/**< Reserved for breakpoint */
	unsigned :3;								
	unsigned user:16;                           /**< User status */
	unsigned :8;								
} DsaStatusGPModuleBitMode;

#else /*__BYTE_ORDER == __BIG_ENDIAN*/

/**
 * @struct DsaStatusDriveBitMode
 * Allow access to drive status with bit members when acces through M63
 */
typedef struct DsaStatusDriveBitMode {
	size_t size;								/**< The size of the structure */
	#ifndef DSA_OO_API				
	unsigned :8;								
	unsigned warning:1;				 			/**< Global warning */
	unsigned :7;								
	unsigned :4;								
	unsigned trace:1;							/**< The aquisition of the trace is not finished */
	unsigned error:1;                           /**< Fatal error */
	unsigned :1;								
	unsigned sequence:1;                        /**< A sequence is running */
	unsigned :2;								
	unsigned in_window:1;						/**< The motor's position is in window */
	unsigned moving:1;                          /**< The motor is moving */
	unsigned present:1;							/**< The drive is present */
	unsigned :2;								
	unsigned power_on:1;						/**< The drive is in power on */
	unsigned :8;								
	unsigned user:16;                           /**< User status */
	unsigned :3;								
	unsigned breakpoint:1;						/**< Breakpoint is reached */
    unsigned : 1;
    unsigned save_pos:1;                        /**< Position has been reached */
    unsigned : 2;
	#else /* DSA_OO_API */
	unsigned :8;								
	unsigned warning:1;				 			/**< Global warning */
	unsigned :7;								
	unsigned :4;								
	unsigned trace:1;							/**< The aquisition of the trace is not finished */
	unsigned error:1;                           /**< Fatal error */
	unsigned :1;								
	unsigned sequence:1;                        /**< A sequence is running */
	unsigned :2;								
	unsigned inWindow:1;						/**< Position is in window */
	unsigned moving:1;                          /**< The motor is moving */
	unsigned present:1;							/**< The drive is present */
	unsigned :2;								
	unsigned powerOn:1;							/**< The drive is in power on */
	unsigned :8;								
	unsigned user:16;                           /**< User status */
	unsigned :3;								
	unsigned breakpoint:1;						/**< Breakpoint is reached */
    unsigned :1;
    unsigned savePos:1;                         /**< Position has been reached */
	unsigned :2;								
	#endif /* DSA_OO_API */
} DsaStatusDriveBitMode;

/**
 * @struct DsaStatusDsmaxBitMode
 * Allow access to dsmax status with bit members when acces through M60
 */
typedef struct DsaStatusDsmaxBitMode {
	size_t size;								/**< The size of the structure */
	unsigned :8;								
	unsigned warning:1;				 			/**< Global warning */
	unsigned :7;								
	unsigned :2;
	unsigned ipol1_moving:1;					/**< Ipol group 1 is moving */
	unsigned ipol0_moving:1;					/**< Ipol group 0 is moving */
	unsigned trace:1;							/**< The aquisition of the trace is not finished */
	unsigned error:1;                           /**< Fatal error */
	unsigned :1;								
	unsigned sequence:1;                        /**< A sequence is running */
	unsigned :3;								
	unsigned moving:1;                          /**< An axis (of ipol group 0 or 1) is moving */
	unsigned present:1;                         /**< The dsmax is present */
	unsigned :3;								
	unsigned :8;								
	unsigned user:16;                           /**< User status */
	unsigned :3;								
	unsigned breakpoint:1;						/**< Breakpoint is reached */
	unsigned :4;								
} DsaStatusDsmaxBitMode;

/**
 * @struct DsaStatusGPModuleBitMode
 * Allow access to general purpose module status with bit members
 */
typedef struct DsaStatusGPModuleBitMode {
	size_t size;								/**< The size of the structure */
	unsigned :8;								
	unsigned warning:1;			 				/**< Global warning */
	unsigned :7;								
	unsigned :4;								
	unsigned trace:1;							/**< The acquisition of the trace is not finished */
	unsigned error:1;							/**< Fatal error */
	unsigned :1;								
	unsigned reserved4:1;                       /**< Reserved for sequence running */
	unsigned :2;								
	unsigned reserved3:1;						/**< Reserved for position in window */
	unsigned reserved2:1;                       /**< Reserved for motor is moving */
	unsigned present:1;							/**< The drive is present */
	unsigned :2;								
	unsigned reserved1:1;						/**< Reserved for the drive is in power on */
	unsigned :8;								
	unsigned user:16;                           /**< User status */
	unsigned :3;								
	unsigned reserved8:1;						/**< Reserved for breakpoint*/
    unsigned :1;
	unsigned reserved9:1;						/**< Reserved for position reached*/
    unsigned :2;
} DsaStatusGPModuleBitMode;
#endif /*__BYTE_ORDER*/

/**
 * @union DSA_STATUS
 * Contains status of devices
 */
typedef union DSA_STATUS {
	size_t size;								/**< The size of this structure */
	DsaStatusSWMode sw;						/**< Status for SW1/SW2 access */
	DsaStatusRawMode raw;					/**< Status for raw access */	
	DsaStatusDriveBitMode drive;			/**< Status for drive bit access */
	DsaStatusDsmaxBitMode dsmax;			/**< Status for dsmax bit access */
	DsaStatusGPModuleBitMode gp_module;	/**< Status for gp module bit access */
} DSA_STATUS;

#define DsaStatus DSA_STATUS


/**
 * @struct DSA_INFO
 * Device info parameters monitoring structure
 */
typedef struct DSA_INFO {
    size_t size;                                     /**< Size of this structure */
#ifndef DSA_OO_API
    int info_product_number;                         /**< Product number */
    int info_boot_revision;                          /**< Boot revision */
    dword info_serial_number;                        /**< Serial number */
    dword info_soft_version;                         /**< Software version */
    dword info_p_soft_build_time;                    /**< Position software build time */
    dword info_c_soft_build_time;                    /**< Current software build time */
    dword info_product_string[8];                    /**< Product string */
#else /* DSA_OO_API */
    int infoProductNumber;                           /**< Product number */
    int infoBootRevision;                            /**< Boot revision */
    dword infoSerialNumber;                          /**< Serial number */
    dword infoSoftVersion;                           /**< Software version */
    dword infoPSoftBuildTime;                        /**< Position software build time */
    dword infoCSoftBuildTime;                        /**< Current software build time */
    dword infoProductString[8];                      /**< Product string */
#endif /* DSA_OO_API */
} DSA_INFO;

#define DsaInfo DSA_INFO

/**
 * @struct DSA_X_INFO
 * Extension card info parameters monitoring structure
 */
typedef struct DSA_X_INFO {
    size_t size;                                     /**< Size of this structure */
#ifndef DSA_OO_API
    int x_info_product_number;                       /**< Extension card info product number */
    int x_info_boot_revision;                        /**< Extension card info boot revision */
    dword x_info_serial_number;                      /**< Extension card info serial number */
    dword x_info_soft_version;                       /**< Extension card info software version */
    dword x_info_soft_build_time;                    /**< Extension card info software build time */
    dword x_info_product_string[4];                  /**< Extension card info product string */
#else /* DSA_OO_API */
    int xInfoProductNumber;                          /**< Extension card info product number */
    int xInfoBootRevision;                           /**< Extension card info boot revision */
    dword xInfoSerialNumber;                         /**< Extension card info serial number */
    dword xInfoSoftVersion;                          /**< Extension card info software version */
    dword xInfoSoftBuildTime;                        /**< Extension card info software build time */
    dword xInfoProductString[4];                     /**< Extension card info product string */
#endif /* DSA_OO_API */
} DSA_X_INFO;

#define DsaXInfo DSA_X_INFO

/**
 * @struct DSA_RTM_VAL
 * Contains realtime monitoring
 */
typedef struct DSA_RTM_VAL {
	long val0;				/**< The first monitoring */
	long val1;				/**< The second monitoring */
} DSA_RTM_VAL;
#define DsaRTMVal DSA_RTM_VAL

#define DSA_MAX_RTM 16		/**< Maximal number of drives by using realtime CHANNEL */

/**
 * @struct DSA_RTM_TABLE
 * Contains realtime monitoring in a table
 */
typedef struct DSA_RTM_TABLE {
	size_t size;							/**< The size of this structure */
	DSA_RTM_VAL mon[16];					/**< The monitoring table */
} DSA_RTM_TABLE;
#define DsaRTMTable DSA_RTM_TABLE

/**
 * @struct DSA_RTM_STRUCT
 * Contains realtime monitoring in structure
 */
typedef struct DSA_RTM_STRUCT {
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
} DSA_RTM_STRUCT;
#define DsaRTMStruct DSA_RTM_STRUCT


/**
 * @union DSA_RTM
 * Getted realtime monitoring structure
 */
typedef union DSA_RTM {
    size_t size;                /**< Size of this structure */
	DSA_RTM_STRUCT monStruct;	/**< Access to realtime monitoring through structure */			
	DSA_RTM_TABLE monTable;		/**< Access to realtime monitoring through table */			
} DSA_RTM;
#define DsaRTM DSA_RTM

/*Type of trajectory generator function called at each interrupt*/
typedef void (*DSA_TRAJECTORY_HANDLER)(DSA_RTM pts);
#define DsaTrajectoryHandler DSA_TRAJECTORY_HANDLER


/*
 * asynchronous handlers 
 */
typedef void (DSA_CALLBACK *DSA_HANDLER)(DSA_DEVICE_BASE *dev, int err, void *param);
typedef void (DSA_CALLBACK *DSA_INT_HANDLER)(DSA_DEVICE *dev, int err, void *param, int val);
typedef void (DSA_CALLBACK *DSA_LONG_HANDLER)(DSA_DEVICE *dev, int err, void *param, long val);
typedef void (DSA_CALLBACK *DSA_DWORD_HANDLER)(DSA_DEVICE *dev, int err, void *param, dword val);
typedef void (DSA_CALLBACK *DSA_DOUBLE_HANDLER)(DSA_DEVICE *dev, int err, void *param, double val);
typedef void (DSA_CALLBACK *DSA_STATUS_HANDLER)(DSA_DEVICE *dev, int err, void *param, const DSA_STATUS *status);
typedef void (DSA_CALLBACK *DSA_2INT_HANDLER)(DSA_DEVICE *dev, int err, void *param, int val1, int val2);

/**
 * @struct DsaId
 * generic command parameter
 */
typedef union DsaId {
	int i;					/**< Used when conv = 0 */
	double d;				/**< Used when conv != 0 */
} DsaId;

/**
 * @struct DSA_COMMAND_PARAM
 * Generic command parameter
 */
typedef struct DSA_COMMAND_PARAM {
	int typ;				/**< Parameter type */
	int conv;				/**< Coenversion index, zero means no conversion */
	DsaId val;				/**< Value of parameter */
} DSA_COMMAND_PARAM;

#define DsaCommandParam DSA_COMMAND_PARAM

/**
 * @struct DsaDim
 * Dimension of interpolation structure
 */
typedef struct DsaDim {
	double x;				/**< X axis*/
	double y;				/**< Y axis */
	double z;				/**< Z axis */
	double theta;			/**< Theta axis */
} DsaDim;

/**
 * @union DsaDimDArray
 * Allows access to parameter through DsaDim structure or array of double
 */
typedef union DsaDimDArray {
	DsaDim dim;			/**< Access through DsaDim structure */
	double array[4];		/**< Access through array of double */
} DsaDimDArray;

/**
 * @union DsaDimIArray
 * Allows access to parameter through DsaDim structure or array of integer
 */
typedef union DsaDimIArray {
	int array[4];			/**< Access through array of int */
} DsaDimIArray;

/**
 * @struct DSA_VECTOR
 * Vector
 */
typedef struct DSA_VECTOR {
    size_t size;                        /**< Size of this structure */
	int reserved;						/**< Reserved for compatibility algnment 8 bytes */
	DsaDimDArray val;					/**< The value of the axis */
} DSA_VECTOR;

#define DsaVector DSA_VECTOR

/**
 * @struct DSA_VECTOR_TYP
 * Vector Typ
 */
typedef struct DSA_VECTOR_TYP {
    size_t size;						/**< Size of this structure */
	int reserved;						/**< Reserved for compatibility algnment 8 bytes */
	DsaDimIArray val;					/**< The typ of the values of the axis */
} DSA_VECTOR_TYP;

#define DsaVectorTyp DSA_VECTOR_TYP
#define DSA_INT_VECTOR DSA_VECTOR_TYP
#define DsaIntVector DSA_VECTOR_TYP


/*** prototypes ***/

/*
 * special functions - synchronous
 */
#ifdef DSA_IMPL_S
int     _DSA_EXPORT dsa_power_on_s(DSA_DRIVE_BASE *grp, long timeout);
int     _DSA_EXPORT dsa_power_off_s(DSA_DRIVE_BASE *grp, long timeout);
int     _DSA_EXPORT dsa_new_setpoint_s(DSA_DRIVE_BASE *grp, int sidx, dword flags, long timeout);
int     _DSA_EXPORT dsa_change_setpoint_s(DSA_DRIVE_BASE *grp, int sidx, dword flags, long timeout);
int     _DSA_EXPORT dsa_quick_stop_s(DSA_DRIVE_BASE *grp, int mode, dword flags, long timeout);
int     _DSA_EXPORT dsa_homing_start_s(DSA_DRIVE_BASE *obj, long timeout);
int     _DSA_EXPORT dsa_get_warning_code_s(DSA_DEVICE *dev, int *code, int kind, long timeout);
int     _DSA_EXPORT dsa_execute_command_s(DSA_DEVICE_BASE *grp, int cmd, bool fast, bool ereport, long timeout);
int     _DSA_EXPORT dsa_execute_command_d_s(DSA_DEVICE_BASE *grp, int cmd, int typ1, long par1, bool fast, bool ereport, long timeout);
int     _DSA_EXPORT dsa_execute_command_i_s(DSA_DEVICE_BASE *grp, int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout);
int     _DSA_EXPORT dsa_execute_command_dd_s(DSA_DEVICE_BASE *grp, int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout);
int     _DSA_EXPORT dsa_execute_command_id_s(DSA_DEVICE_BASE *grp, int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout);
int     _DSA_EXPORT dsa_execute_command_di_s(DSA_DEVICE_BASE *grp, int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout);
int     _DSA_EXPORT dsa_execute_command_ii_s(DSA_DEVICE_BASE *grp, int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout);
int     _DSA_EXPORT dsa_execute_command_x_s(DSA_DEVICE_BASE *grp, int cmd, DSA_COMMAND_PARAM *params, int count, bool fast, bool ereport, long timeout);
int     _DSA_EXPORT dsa_get_register_s(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, long *val, int kind, long timeout);
int     _DSA_EXPORT dsa_get_array_s(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout);
int     _DSA_EXPORT dsa_set_register_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, long val, long timeout);
int     _DSA_EXPORT dsa_set_array_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout);
int     _DSA_EXPORT dsa_get_iso_register_s(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, double *val, int conv, int kind, long timeout);
int     _DSA_EXPORT dsa_get_iso_array_s(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, long timeout);
int     _DSA_EXPORT dsa_set_iso_register_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, double val, int conv, long timeout);
int     _DSA_EXPORT dsa_set_iso_array_s(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout);
int     _DSA_EXPORT dsa_ipol_begin_s(DSA_IPOL_GROUP *igrp, long timeout);
int     _DSA_EXPORT dsa_ipol_end_s(DSA_IPOL_GROUP *igrp, long timeout);
int     _DSA_EXPORT dsa_ipol_begin_concatenation_s(DSA_IPOL_GROUP *igrp, long timeout);
int     _DSA_EXPORT dsa_ipol_end_concatenation_s(DSA_IPOL_GROUP *igrp, long timeout);
int     _DSA_EXPORT dsa_ipol_line_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, long timeout);
int     _DSA_EXPORT dsa_ipol_circle_cw_r2d_s(DSA_IPOL_GROUP *igrp, double x, double y, double r, long timeout);
int     _DSA_EXPORT dsa_ipol_circle_ccw_r2d_s(DSA_IPOL_GROUP *igrp, double x, double y, double r, long timeout);
int     _DSA_EXPORT dsa_ipol_tan_velocity_s(DSA_IPOL_GROUP *igrp, double velocity, long timeout);
int     _DSA_EXPORT dsa_ipol_tan_acceleration_s(DSA_IPOL_GROUP *igrp, double acc, long timeout);
int     _DSA_EXPORT dsa_ipol_tan_deceleration_s(DSA_IPOL_GROUP *igrp, double dec, long timeout);
int     _DSA_EXPORT dsa_ipol_tan_jerk_time_s(DSA_IPOL_GROUP *igrp, double jerk_time, long timeout);
int     _DSA_EXPORT dsa_ipol_quick_stop_s(DSA_IPOL_GROUP *igrp, int mode, dword flags, long timeout);
int     _DSA_EXPORT dsa_ipol_continue_s(DSA_IPOL_GROUP *igrp, long timeout);
int     _DSA_EXPORT dsa_ipol_reset_s(DSA_IPOL_GROUP *igrp, long timeout);
int     _DSA_EXPORT dsa_ipol_pvt_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_VECTOR *velocity, double time, long timeout);
int     _DSA_EXPORT dsa_ipol_mark_s(DSA_IPOL_GROUP *igrp, long number, long operation, long op_param, long timeout);
int     _DSA_EXPORT dsa_ipol_set_velocity_rate_s(DSA_IPOL_GROUP *igrp, double rate, long timeout);
int     _DSA_EXPORT dsa_ipol_circle_cw_c2d_s(DSA_IPOL_GROUP *igrp, double x, double y, double cx, double cy, long timeout);
int     _DSA_EXPORT dsa_ipol_circle_ccw_c2d_s(DSA_IPOL_GROUP *igrp, double x, double y, double cx, double cy, long timeout);
int     _DSA_EXPORT dsa_ipol_line_2d_s(DSA_IPOL_GROUP *igrp, double x, double y, long timeout);
int     _DSA_EXPORT dsa_ipol_wait_movement_s(DSA_IPOL_GROUP *igrp, long timeout);
int     _DSA_EXPORT dsa_ipol_prepare_s(DSA_IPOL_GROUP *igrp, long timeout);
int     _DSA_EXPORT dsa_ipol_pvt_update_s(DSA_IPOL_GROUP *igrp, int depth, dword mask, long timeout);
int     _DSA_EXPORT dsa_ipol_pvt_reg_typ_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_VECTOR_TYP destTyp, DSA_VECTOR *velocity, DSA_VECTOR_TYP velocityTyp, double time, int timeTyp, long timeout);
int     _DSA_EXPORT dsa_ipol_set_lkt_speed_ratio_s(DSA_IPOL_GROUP *igrp, double value, long timeout);
int     _DSA_EXPORT dsa_ipol_set_lkt_cyclic_mode_s(DSA_IPOL_GROUP *igrp, bool active, long timeout);
int     _DSA_EXPORT dsa_ipol_set_lkt_relative_mode_s(DSA_IPOL_GROUP *igrp, bool active, long timeout);
int     _DSA_EXPORT dsa_ipol_lkt_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_INT_VECTOR *lkt_number, double time, long timeout);
int     _DSA_EXPORT dsa_ipol_wait_mark_s(DSA_IPOL_GROUP *igrp, int mark, long timeout);
int     _DSA_EXPORT dsa_ipol_uline_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, long timeout);
int     _DSA_EXPORT dsa_ipol_uline_2d_s(DSA_IPOL_GROUP *igrp, double x, double y, long timeout);
int     _DSA_EXPORT dsa_ipol_disable_uconcatenation_s(DSA_IPOL_GROUP *igrp, long timeout);
int     _DSA_EXPORT dsa_ipol_set_urelative_mode_s(DSA_IPOL_GROUP *igrp, bool active, long timeout);
int     _DSA_EXPORT dsa_ipol_uspeed_axis_mask_s(DSA_IPOL_GROUP *igrp, dword mask, long timeout);
int     _DSA_EXPORT dsa_ipol_uspeed_s(DSA_IPOL_GROUP *igrp, double speed, long timeout);
int     _DSA_EXPORT dsa_ipol_utime_s(DSA_IPOL_GROUP *igrp, double acc_time, double jerk_time, long timeout);
int     _DSA_EXPORT dsa_ipol_translate_matrix_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *trans, long timeout);
int     _DSA_EXPORT dsa_ipol_scale_matrix_s(DSA_IPOL_GROUP *igrp, DSA_VECTOR *scale, long timeout);
int     _DSA_EXPORT dsa_ipol_rotate_matrix_s(DSA_IPOL_GROUP *igrp, int plan, double degree, long timeout);
int     _DSA_EXPORT dsa_ipol_translate_matrix_2d_s(DSA_IPOL_GROUP *igrp, double x, double y, long timeout);
int     _DSA_EXPORT dsa_ipol_scale_matrix_2d_s(DSA_IPOL_GROUP *igrp, double x, double y, long timeout);
int     _DSA_EXPORT dsa_ipol_shear_matrix_s(DSA_IPOL_GROUP *igrp, int sheared_axis, double axis1_shearing, double axis2_shearing, double axis3_shearing, long timeout);
int     _DSA_EXPORT dsa_ipol_lock_s(DSA_IPOL_GROUP *igrp, long timeout);
int     _DSA_EXPORT dsa_ipol_unlock_s(DSA_IPOL_GROUP *igrp, long timeout);
int     _DSA_EXPORT dsa_wait_status_equal_s(DSA_DEVICE *drv, DSA_STATUS *mask, DSA_STATUS *ref, DSA_STATUS *status, long timeout);
int     _DSA_EXPORT dsa_wait_status_not_equal_s(DSA_DEVICE *drv, DSA_STATUS *mask, DSA_STATUS *ref, DSA_STATUS *status, long timeout);
int     _DSA_EXPORT dsa_grp_wait_and_status_equal_s(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, long timeout);
int     _DSA_EXPORT dsa_grp_wait_and_status_not_equal_s(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, long timeout);
int     _DSA_EXPORT dsa_gantry_wait_and_status_equal_s(DSA_GANTRY *gantry, DSA_STATUS *mask, DSA_STATUS *ref, long timeout);
int     _DSA_EXPORT dsa_gantry_wait_and_status_not_equal_s(DSA_GANTRY *gantry, DSA_STATUS *mask, DSA_STATUS *ref, long timeout);
int     _DSA_EXPORT dsa_wait_status_change_s(DSA_DEVICE *drv, DSA_STATUS *mask, DSA_STATUS *status, long timeout);
int     _DSA_EXPORT dsa_grp_wait_or_status_equal_s(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, long timeout);
int     _DSA_EXPORT dsa_grp_wait_or_status_not_equal_s(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, long timeout);
int     _DSA_EXPORT dsa_set_trace_mode_mvt_s(DSA_DEVICE_BASE *obj, double time, bool endm, long timeout);
int     _DSA_EXPORT dsa_set_trace_mode_pos_s(DSA_DEVICE_BASE *obj, double time, double pos, long timeout);
int     _DSA_EXPORT dsa_set_trace_mode_dev_s(DSA_DEVICE_BASE *obj, double time, long level, long timeout);
int     _DSA_EXPORT dsa_set_trace_mode_iso_s(DSA_DEVICE_BASE *obj, double time, void *level, int conv, long timeout);
int     _DSA_EXPORT dsa_set_trace_mode_immediate_s(DSA_DEVICE_BASE *obj, double time, long timeout);
int     _DSA_EXPORT dsa_trace_acquisition_s(DSA_DEVICE_BASE *obj, int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout);
int     _DSA_EXPORT dsa_sync_trace_enable_s(DSA_DEVICE_BASE *obj, bool enable, long timeout);
int     _DSA_EXPORT dsa_sync_trace_force_trigger_s(DSA_DEVICE_BASE *obj, long timeout);


#endif /* DSA_IMPL_S */

/*
 * special functions - asynchronous
 */
#ifdef DSA_IMPL_A
int     _DSA_EXPORT dsa_power_on_a(DSA_DRIVE_BASE *grp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_power_off_a(DSA_DRIVE_BASE *grp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_new_setpoint_a(DSA_DRIVE_BASE *grp, int sidx, dword flags, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_change_setpoint_a(DSA_DRIVE_BASE *grp, int sidx, dword flags, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_quick_stop_a(DSA_DRIVE_BASE *grp, int mode, dword flags, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_homing_start_a(DSA_DRIVE_BASE *obj, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_warning_code_a(DSA_DEVICE *dev, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_execute_command_a(DSA_DEVICE_BASE *grp, int cmd, bool fast, bool ereport, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_execute_command_d_a(DSA_DEVICE_BASE *grp, int cmd, int typ1, long par1, bool fast, bool ereport, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_execute_command_i_a(DSA_DEVICE_BASE *grp, int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_execute_command_dd_a(DSA_DEVICE_BASE *grp, int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_execute_command_id_a(DSA_DEVICE_BASE *grp, int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_execute_command_di_a(DSA_DEVICE_BASE *grp, int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_execute_command_ii_a(DSA_DEVICE_BASE *grp, int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_execute_command_x_a(DSA_DEVICE_BASE *grp, int cmd, DSA_COMMAND_PARAM *params, int count, bool fast, bool ereport, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_register_a(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, int kind, DSA_LONG_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_array_a(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_register_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, long val, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_array_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_iso_register_a(DSA_DEVICE *dev, int typ, unsigned idx, int sidx, int conv, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_iso_array_a(DSA_DEVICE *dev, int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_iso_register_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, int sidx, double val, int conv, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_iso_array_a(DSA_DEVICE_BASE *grp, int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_begin_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_end_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_begin_concatenation_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_end_concatenation_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_line_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_circle_cw_r2d_a(DSA_IPOL_GROUP *igrp, double x, double y, double r, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_circle_ccw_r2d_a(DSA_IPOL_GROUP *igrp, double x, double y, double r, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_tan_velocity_a(DSA_IPOL_GROUP *igrp, double velocity, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_tan_acceleration_a(DSA_IPOL_GROUP *igrp, double acc, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_tan_deceleration_a(DSA_IPOL_GROUP *igrp, double dec, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_tan_jerk_time_a(DSA_IPOL_GROUP *igrp, double jerk_time, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_quick_stop_a(DSA_IPOL_GROUP *igrp, int mode, dword flags, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_continue_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_reset_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_pvt_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_VECTOR *velocity, double time, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_mark_a(DSA_IPOL_GROUP *igrp, long number, long operation, long op_param, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_set_velocity_rate_a(DSA_IPOL_GROUP *igrp, double rate, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_circle_cw_c2d_a(DSA_IPOL_GROUP *igrp, double x, double y, double cx, double cy, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_circle_ccw_c2d_a(DSA_IPOL_GROUP *igrp, double x, double y, double cx, double cy, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_line_2d_a(DSA_IPOL_GROUP *igrp, double x, double y, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_wait_movement_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_prepare_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_pvt_update_a(DSA_IPOL_GROUP *igrp, int depth, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_pvt_reg_typ_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_VECTOR_TYP destTyp, DSA_VECTOR *velocity, DSA_VECTOR_TYP velocityTyp, double time, int timeTyp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_set_lkt_speed_ratio_a(DSA_IPOL_GROUP *igrp, double value, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_set_lkt_cyclic_mode_a(DSA_IPOL_GROUP *igrp, bool active, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_set_lkt_relative_mode_a(DSA_IPOL_GROUP *igrp, bool active, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_lkt_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_INT_VECTOR *lkt_number, double time, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_wait_mark_a(DSA_IPOL_GROUP *igrp, int mark, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_uline_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *dest, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_uline_2d_a(DSA_IPOL_GROUP *igrp, double x, double y, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_disable_uconcatenation_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_set_urelative_mode_a(DSA_IPOL_GROUP *igrp, bool active, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_uspeed_axis_mask_a(DSA_IPOL_GROUP *igrp, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_uspeed_a(DSA_IPOL_GROUP *igrp, double speed, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_utime_a(DSA_IPOL_GROUP *igrp, double acc_time, double jerk_time, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_translate_matrix_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *trans, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_scale_matrix_a(DSA_IPOL_GROUP *igrp, DSA_VECTOR *scale, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_rotate_matrix_a(DSA_IPOL_GROUP *igrp, int plan, double degree, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_translate_matrix_2d_a(DSA_IPOL_GROUP *igrp, double x, double y, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_scale_matrix_2d_a(DSA_IPOL_GROUP *igrp, double x, double y, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_shear_matrix_a(DSA_IPOL_GROUP *igrp, int sheared_axis, double axis1_shearing, double axis2_shearing, double axis3_shearing, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_lock_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_ipol_unlock_a(DSA_IPOL_GROUP *igrp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_wait_status_equal_a(DSA_DEVICE *drv, DSA_STATUS *mask, DSA_STATUS *ref, DSA_STATUS_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_wait_status_not_equal_a(DSA_DEVICE *drv, DSA_STATUS *mask, DSA_STATUS *ref, DSA_STATUS_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_grp_wait_and_status_equal_a(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_grp_wait_and_status_not_equal_a(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_gantry_wait_and_status_equal_a(DSA_GANTRY *gantry, DSA_STATUS *mask, DSA_STATUS *ref, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_gantry_wait_and_status_not_equal_a(DSA_GANTRY *gantry, DSA_STATUS *mask, DSA_STATUS *ref, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_wait_status_change_a(DSA_DEVICE *drv, DSA_STATUS *mask, DSA_STATUS_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_grp_wait_or_status_equal_a(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_grp_wait_or_status_not_equal_a(DSA_DEVICE_GROUP *grp, DSA_STATUS *mask, DSA_STATUS *ref, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_trace_mode_mvt_a(DSA_DEVICE_BASE *obj, double time, bool endm, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_trace_mode_pos_a(DSA_DEVICE_BASE *obj, double time, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_trace_mode_dev_a(DSA_DEVICE_BASE *obj, double time, long level, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_trace_mode_iso_a(DSA_DEVICE_BASE *obj, double time, void *level, int conv, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_trace_mode_immediate_a(DSA_DEVICE_BASE *obj, double time, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_trace_acquisition_a(DSA_DEVICE_BASE *obj, int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_sync_trace_enable_a(DSA_DEVICE_BASE *obj, bool enable, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_sync_trace_force_trigger_a(DSA_DEVICE_BASE *obj, DSA_HANDLER handler, void *param);

#endif /* DSA_IMPL_A */

/*
 * special functions - others
 */
int     _DSA_EXPORT dsa_open_e(DSA_DEVICE *dev, ETB *etb, int axis);
int     _DSA_EXPORT dsa_open_u(DSA_DEVICE *dev, char_cp url);
int     _DSA_EXPORT dsa_open_ef(DSA_DEVICE *dev, ETB *etb, int axis, dword flags);
int     _DSA_EXPORT dsa_reset(DSA_DEVICE *dev);
int     _DSA_EXPORT dsa_close(DSA_DEVICE *dev);
int     _DSA_EXPORT dsa_get_etb_bus(DSA_DEVICE *dev, ETB **etb);
int     _DSA_EXPORT dsa_get_etb_axis(DSA_DEVICE *dev, int *axis);
int     _DSA_EXPORT dsa_create_drive(DSA_DRIVE **rdrv);
int     _DSA_EXPORT dsa_create_dsmax(DSA_DSMAX **rdsmax);
int     _DSA_EXPORT dsa_destroy(DSA_DEVICE_BASE **rdev);
int     _DSA_EXPORT dsa_is_open(DSA_DEVICE *dev, bool *is_open);
int     _DSA_EXPORT dsa_share(DSA_DEVICE_BASE *dsa);
int     _DSA_EXPORT dsa_create_auto_e(DSA_DEVICE **rdev, ETB *etb, int axis);
int     _DSA_EXPORT dsa_create_auto_o(DSA_DEVICE **rdev, int prod);
int     _DSA_EXPORT dsa_create_gp_module(DSA_GP_MODULE **rgp_module);
int     _DSA_EXPORT dsa_get_motor_typ(DSA_DEVICE *dev);
dword   _DSA_EXPORT dsa_get_version(void);
time_t  _DSA_EXPORT dsa_get_build_time(void);
dword   _DSA_EXPORT dsa_get_timer(void);
char_cp _DSA_EXPORT dsa_translate_error(int code);
int     _DSA_EXPORT dsa_set_prio(int prio);
dword   _DSA_EXPORT dsa_get_edi_version(void);
int     _DSA_EXPORT dsa_get_error_text(DSA_DEVICE *dev, char_p text, int size, int code);
int     _DSA_EXPORT dsa_get_warning_text(DSA_DEVICE *dev, char_p text, int size, int code);
char_cp _DSA_EXPORT dsa_translate_edi_error(int code);
int     _DSA_EXPORT dsa_convert_to_iso(DSA_DEVICE *dev, double *iso, long inc, int conv);
int     _DSA_EXPORT dsa_convert_from_iso(DSA_DEVICE *dev, long *inc, double iso, int conv);
int     _DSA_EXPORT dsa_get_rtm_mon(DSA_DEVICE_BASE *grp, DSA_RTM *rtm);
int     _DSA_EXPORT dsa_init_rtm_fct(DSA_DEVICE_BASE *grp);
int     _DSA_EXPORT dsa_start_rtm(DSA_DEVICE_BASE *grp, DSA_TRAJECTORY_HANDLER fct);
int     _DSA_EXPORT dsa_stop_rtm(DSA_DEVICE_BASE *grp);
int     _DSA_EXPORT dsa_diag(char_cp file_name, int line, int err, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_sdiag(char_p str, char_cp file_name, int line, int err, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_fdiag(char_cp output_file_name, char_cp file_name, int line, int err, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_create_device_group(DSA_DEVICE_GROUP **rgrp, int size);
int     _DSA_EXPORT dsa_create_drive_group(DSA_DRIVE_GROUP **rgrp, int size);
int     _DSA_EXPORT dsa_create_dsmax_group(DSA_DSMAX_GROUP **rgrp, int size);
int     _DSA_EXPORT dsa_create_ipol_group(DSA_IPOL_GROUP **rgrp, int size);
int     _DSA_EXPORT dsa_get_group_size(DSA_DEVICE_GROUP *grp, int *size);
int     _DSA_EXPORT dsa_set_group_item(DSA_DEVICE_GROUP *grp, int pos, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_get_group_item(DSA_DEVICE_GROUP *grp, int pos, DSA_DEVICE_BASE **rdev);
int     _DSA_EXPORT dsa_add_group_item(DSA_DEVICE_GROUP *grp, DSA_DEVICE_BASE *dev);
int     _DSA_EXPORT dsa_set_dsmax(DSA_IPOL_GROUP *grp, DSA_DSMAX *dsmax);
int     _DSA_EXPORT dsa_get_dsmax(DSA_IPOL_GROUP *grp, DSA_DSMAX **dsmax);
bool    _DSA_EXPORT dsa_is_valid_device(DSA_DEVICE *dev);
bool    _DSA_EXPORT dsa_is_valid_drive(DSA_DRIVE *drv);
bool    _DSA_EXPORT dsa_is_valid_dsmax(DSA_DSMAX *dsmax);
bool    _DSA_EXPORT dsa_is_valid_device_group(DSA_DEVICE_GROUP *grp);
bool    _DSA_EXPORT dsa_is_valid_drive_group(DSA_DRIVE_GROUP *grp);
bool    _DSA_EXPORT dsa_is_valid_dsmax_group(DSA_DSMAX_GROUP *grp);
bool    _DSA_EXPORT dsa_is_valid_ipol_group(DSA_IPOL_GROUP *grp);
bool    _DSA_EXPORT dsa_is_valid_device_base(DSA_DEVICE_BASE *dev);
bool    _DSA_EXPORT dsa_is_valid_drive_base(DSA_DRIVE_BASE *dev);
bool    _DSA_EXPORT dsa_is_valid_dsmax_base(DSA_DSMAX_BASE *dev);
int     _DSA_EXPORT dsa_create_gantry(DSA_GANTRY **gantry);
bool    _DSA_EXPORT dsa_is_valid_gantry(DSA_GANTRY *gantry);
int     _DSA_EXPORT dsa_gantry_get_error_code(DSA_GANTRY *gantry, int *code, int *axis, int kind);
int     _DSA_EXPORT dsa_create_gp_module_group(DSA_GP_MODULE_GROUP **rgrp, int size);
bool    _DSA_EXPORT dsa_is_valid_gp_module(DSA_GP_MODULE *gp_module);
bool    _DSA_EXPORT dsa_is_valid_gp_module_group(DSA_GP_MODULE_GROUP *grp);
bool    _DSA_EXPORT dsa_is_valid_gp_module_base(DSA_GP_MODULE_BASE *dev);
int     _DSA_EXPORT dsa_get_info(DSA_DEVICE *dev, DSA_INFO *info);
bool    _DSA_EXPORT dsa_is_ipol_in_progress(DSA_IPOL_GROUP *igrp);
int     _DSA_EXPORT dsa_get_status(DSA_DEVICE *dev, DSA_STATUS *status);
int     _DSA_EXPORT dsa_cancel_status_wait(DSA_DEVICE_BASE *grp);
int     _DSA_EXPORT dsa_gantry_cancel_status_wait(DSA_GANTRY *gantry);
int     _DSA_EXPORT dsa_gantry_get_and_status(DSA_GANTRY *gantry, DSA_STATUS *status);
int     _DSA_EXPORT dsa_gantry_get_or_status(DSA_GANTRY *gantry, DSA_STATUS *status);
int     _DSA_EXPORT dsa_get_status_from_drive(DSA_DEVICE *dev, DSA_STATUS *status, long timeout);
int     _DSA_EXPORT dsa_grp_cancel_status_wait(DSA_DEVICE_GROUP *grp);
int     _DSA_EXPORT dsa_query_minimum_sample_time(DSA_DEVICE *obj, double *time);
int     _DSA_EXPORT dsa_query_sample_time(DSA_DEVICE *obj, double time, double *real_time);
int     _DSA_EXPORT dsa_begin_sync_trans(void);
int     _DSA_EXPORT dsa_rollback_sync_trans(void);
int     _DSA_EXPORT dsa_commit_sync_trans(long timeout);
int     _DSA_EXPORT dsa_begin_async_trans(void);
int     _DSA_EXPORT dsa_rollback_async_trans(void);
int     _DSA_EXPORT dsa_commit_async_trans(DSA_DEVICE_BASE *grp, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_trans_level(int *level);
int     _DSA_EXPORT dsa_get_x_info(DSA_DEVICE *dev, DSA_X_INFO *x_info);


DSA_STATUS	_DSA_EXPORT dsa_init_status(void);
DSA_INFO	_DSA_EXPORT dsa_init_info(void);
DSA_X_INFO	_DSA_EXPORT dsa_init_x_info(void);
DSA_VECTOR	_DSA_EXPORT dsa_init_vector(void);
DSA_VECTOR_TYP _DSA_EXPORT dsa_init_vector_typ(void);
DSA_RTM _DSA_EXPORT dsa_init_rtm(void);


/*
 * very special functions - do not use for normal applications 
 */
#ifdef DSA_IMPL_S
int     _DSA_EXPORT dsa_quick_register_request_s(DSA_DEVICE *dev, int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, long timeout);

#endif /* DSA_IMPL_S */
#ifdef DSA_IMPL_A
int     _DSA_EXPORT dsa_quick_register_request_a(DSA_DEVICE *dev, int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, DSA_2INT_HANDLER handler, void *param);

#endif /* DSA_IMPL_A */
#ifdef DSA_IMPL_A

#endif /* DSA_IMPL_A */

/*
 * commands - synchronous
 */
#ifdef DSA_IMPL_S
int     _DSA_EXPORT dsa_reset_error_s(DSA_DEVICE_BASE *obj, long timeout);
int     _DSA_EXPORT dsa_step_motion_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
int     _DSA_EXPORT dsa_execute_sequence_s(DSA_DEVICE_BASE *obj, int label, long timeout);
int     _DSA_EXPORT dsa_edit_sequence_s(DSA_DEVICE_BASE *obj, long timeout);
int     _DSA_EXPORT dsa_exit_sequence_s(DSA_DEVICE_BASE *obj, long timeout);
int     _DSA_EXPORT dsa_can_command_1_s(DSA_DRIVE_BASE *obj, dword val1, dword val2, long timeout);
int     _DSA_EXPORT dsa_can_command_2_s(DSA_DRIVE_BASE *obj, dword val1, dword val2, long timeout);
int     _DSA_EXPORT dsa_save_parameters_s(DSA_DEVICE_BASE *obj, int what, long timeout);
int     _DSA_EXPORT dsa_load_parameters_s(DSA_DEVICE_BASE *obj, int what, long timeout);
int     _DSA_EXPORT dsa_default_parameters_s(DSA_DEVICE_BASE *obj, int what, long timeout);
int     _DSA_EXPORT dsa_wait_movement_s(DSA_DEVICE_BASE *obj, long timeout);
int     _DSA_EXPORT dsa_wait_position_s(DSA_DEVICE_BASE *obj, double pos, long timeout);
int     _DSA_EXPORT dsa_wait_time_s(DSA_DEVICE_BASE *obj, double time, long timeout);
int     _DSA_EXPORT dsa_wait_window_s(DSA_DEVICE_BASE *obj, long timeout);

#endif /* DSA_IMPL_S */

/*
 * commands - asynchronous
 */
#ifdef DSA_IMPL_A
int     _DSA_EXPORT dsa_reset_error_a(DSA_DEVICE_BASE *obj, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_step_motion_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_execute_sequence_a(DSA_DEVICE_BASE *obj, int label, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_edit_sequence_a(DSA_DEVICE_BASE *obj, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_exit_sequence_a(DSA_DEVICE_BASE *obj, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_can_command_1_a(DSA_DRIVE_BASE *obj, dword val1, dword val2, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_can_command_2_a(DSA_DRIVE_BASE *obj, dword val1, dword val2, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_save_parameters_a(DSA_DEVICE_BASE *obj, int what, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_load_parameters_a(DSA_DEVICE_BASE *obj, int what, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_default_parameters_a(DSA_DEVICE_BASE *obj, int what, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_wait_movement_a(DSA_DEVICE_BASE *obj, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_wait_position_a(DSA_DEVICE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_wait_time_a(DSA_DEVICE_BASE *obj, double time, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_wait_window_a(DSA_DEVICE_BASE *obj, DSA_HANDLER handler, void *param);

#endif /* DSA_IMPL_A */

/*
 * register getter - synchronous
 */
#ifdef DSA_IMPL_S
int     _DSA_EXPORT dsa_get_pl_proportional_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
int     _DSA_EXPORT dsa_get_pl_speed_feedback_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
int     _DSA_EXPORT dsa_get_pl_force_feedback_gain_1_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
int     _DSA_EXPORT dsa_get_pl_integrator_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
int     _DSA_EXPORT dsa_get_pl_anti_windup_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
int     _DSA_EXPORT dsa_get_pl_integrator_limitation_s(DSA_DRIVE *obj, double *limit, int kind, long timeout);
int     _DSA_EXPORT dsa_get_pl_integrator_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
int     _DSA_EXPORT dsa_get_pl_speed_filter_s(DSA_DRIVE *obj, double *tim, int kind, long timeout);
int     _DSA_EXPORT dsa_get_pl_output_filter_s(DSA_DRIVE *obj, double *tim, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_input_filter_s(DSA_DRIVE *obj, double *tim, int kind, long timeout);
int     _DSA_EXPORT dsa_get_ttl_special_filter_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
int     _DSA_EXPORT dsa_get_pl_force_feedback_gain_2_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
int     _DSA_EXPORT dsa_get_pl_speed_feedfwd_gain_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
int     _DSA_EXPORT dsa_get_pl_acc_feedforward_gain_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_phase_advance_factor_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
int     _DSA_EXPORT dsa_get_apr_input_filter_s(DSA_DRIVE *obj, double *time, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_phase_advance_shift_s(DSA_DRIVE *obj, double *shift, int kind, long timeout);
int     _DSA_EXPORT dsa_get_min_position_range_limit_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_max_position_range_limit_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_max_profile_velocity_s(DSA_DRIVE *obj, double *vel, int kind, long timeout);
int     _DSA_EXPORT dsa_get_max_acceleration_s(DSA_DRIVE *obj, double *acc, int kind, long timeout);
int     _DSA_EXPORT dsa_get_following_error_window_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_velocity_error_limit_s(DSA_DRIVE *obj, double *vel, int kind, long timeout);
int     _DSA_EXPORT dsa_get_switch_limit_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
int     _DSA_EXPORT dsa_get_enable_input_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
int     _DSA_EXPORT dsa_get_min_soft_position_limit_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_max_soft_position_limit_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_profile_limit_mode_s(DSA_DRIVE *obj, dword *flags, int kind, long timeout);
int     _DSA_EXPORT dsa_get_io_error_event_mask_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_position_window_time_s(DSA_DRIVE *obj, double *tim, int kind, long timeout);
int     _DSA_EXPORT dsa_get_position_window_s(DSA_DRIVE *obj, double *win, int kind, long timeout);
int     _DSA_EXPORT dsa_get_homing_method_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
int     _DSA_EXPORT dsa_get_homing_zero_speed_s(DSA_DRIVE *obj, double *vel, int kind, long timeout);
int     _DSA_EXPORT dsa_get_homing_acceleration_s(DSA_DRIVE *obj, double *acc, int kind, long timeout);
int     _DSA_EXPORT dsa_get_homing_following_limit_s(DSA_DRIVE *obj, double *win, int kind, long timeout);
int     _DSA_EXPORT dsa_get_homing_current_limit_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
int     _DSA_EXPORT dsa_get_home_offset_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_homing_fixed_mvt_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_homing_switch_mvt_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_homing_index_mvt_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_homing_fine_tuning_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
int     _DSA_EXPORT dsa_get_homing_fine_tuning_value_s(DSA_DRIVE *obj, double *phase, int kind, long timeout);
int     _DSA_EXPORT dsa_get_motor_phase_correction_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
int     _DSA_EXPORT dsa_get_software_current_limit_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
int     _DSA_EXPORT dsa_get_drive_control_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
int     _DSA_EXPORT dsa_get_display_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_inversion_s(DSA_DRIVE *obj, double *invert, int kind, long timeout);
int     _DSA_EXPORT dsa_get_pdr_step_value_s(DSA_DRIVE *obj, double *step, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_phase_1_offset_s(DSA_DRIVE *obj, double *offset, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_phase_2_offset_s(DSA_DRIVE *obj, double *offset, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_phase_1_factor_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_phase_2_factor_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_phase_3_offset_s(DSA_DRIVE *obj, double *offset, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_index_distance_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_phase_3_factor_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_proportional_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_integrator_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_output_filter_s(DSA_DRIVE *obj, double *tim, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_current_limit_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_i2t_current_limit_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_i2t_time_limit_s(DSA_DRIVE *obj, double *tim, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_regen_mode_s(DSA_DRIVE *obj, int *mode, int kind, long timeout);
int     _DSA_EXPORT dsa_get_init_mode_s(DSA_DRIVE *obj, int *typ, int kind, long timeout);
int     _DSA_EXPORT dsa_get_init_pulse_level_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
int     _DSA_EXPORT dsa_get_init_max_current_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
int     _DSA_EXPORT dsa_get_init_final_phase_s(DSA_DRIVE *obj, double *cal, int kind, long timeout);
int     _DSA_EXPORT dsa_get_init_time_s(DSA_DRIVE *obj, double *tim, int kind, long timeout);
int     _DSA_EXPORT dsa_get_init_current_rate_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
int     _DSA_EXPORT dsa_get_init_phase_rate_s(DSA_DRIVE *obj, double *cal, int kind, long timeout);
int     _DSA_EXPORT dsa_get_init_initial_phase_s(DSA_DRIVE *obj, double *cal, int kind, long timeout);
int     _DSA_EXPORT dsa_get_drive_fuse_checking_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_motor_temp_checking_s(DSA_DRIVE *obj, dword *val, int kind, long timeout);
int     _DSA_EXPORT dsa_get_mon_source_type_s(DSA_DRIVE *obj, int sidx, int *typ, int kind, long timeout);
int     _DSA_EXPORT dsa_get_mon_source_index_s(DSA_DRIVE *obj, int sidx, int *index, int kind, long timeout);
int     _DSA_EXPORT dsa_get_mon_dest_index_s(DSA_DRIVE *obj, int sidx, int *index, int kind, long timeout);
int     _DSA_EXPORT dsa_get_mon_offset_s(DSA_DRIVE *obj, int sidx, long *offset, int kind, long timeout);
int     _DSA_EXPORT dsa_get_mon_gain_s(DSA_DRIVE *obj, int sidx, double *gain, int kind, long timeout);
int     _DSA_EXPORT dsa_get_x_analog_offset_s(DSA_DRIVE *obj, int sidx, double *offset, int kind, long timeout);
int     _DSA_EXPORT dsa_get_x_analog_gain_s(DSA_DRIVE *obj, int sidx, double *gain, int kind, long timeout);
int     _DSA_EXPORT dsa_get_syncro_input_mask_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_syncro_input_value_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_syncro_output_mask_s(DSA_DRIVE *obj, double *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_syncro_output_value_s(DSA_DRIVE *obj, double *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_syncro_start_timeout_s(DSA_DRIVE *obj, int *tim, int kind, long timeout);
int     _DSA_EXPORT dsa_get_digital_output_s(DSA_DRIVE *obj, dword *out, int kind, long timeout);
int     _DSA_EXPORT dsa_get_x_digital_output_s(DSA_DRIVE *obj, dword *out, int kind, long timeout);
int     _DSA_EXPORT dsa_get_x_analog_output_1_s(DSA_DRIVE *obj, double *out, int kind, long timeout);
int     _DSA_EXPORT dsa_get_x_analog_output_2_s(DSA_DRIVE *obj, double *out, int kind, long timeout);
int     _DSA_EXPORT dsa_get_analog_output_s(DSA_DRIVE *obj, double *out, int kind, long timeout);
int     _DSA_EXPORT dsa_get_interrupt_mask_1_s(DSA_DRIVE *obj, int sidx, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_interrupt_mask_2_s(DSA_DRIVE *obj, int sidx, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_trigger_irq_mask_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_trigger_io_mask_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_trigger_map_offset_s(DSA_DRIVE *obj, int *offset, int kind, long timeout);
int     _DSA_EXPORT dsa_get_trigger_map_size_s(DSA_DRIVE *obj, int *size, int kind, long timeout);
int     _DSA_EXPORT dsa_get_realtime_enabled_global_s(DSA_DRIVE *obj, int *enable, int kind, long timeout);
int     _DSA_EXPORT dsa_get_realtime_valid_mask_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_realtime_enabled_mask_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_realtime_pending_mask_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_ebl_baudrate_s(DSA_DRIVE *obj, long *baud, int kind, long timeout);
int     _DSA_EXPORT dsa_get_indirect_axis_number_s(DSA_DRIVE *obj, int *axis, int kind, long timeout);
int     _DSA_EXPORT dsa_get_indirect_register_idx_s(DSA_DRIVE *obj, int *idx, int kind, long timeout);
int     _DSA_EXPORT dsa_get_indirect_register_sidx_s(DSA_DRIVE *obj, int *sidx, int kind, long timeout);
int     _DSA_EXPORT dsa_get_concatenated_mvt_s(DSA_DRIVE *obj, int *concat, int kind, long timeout);
int     _DSA_EXPORT dsa_get_profile_type_s(DSA_DRIVE *obj, int sidx, int *typ, int kind, long timeout);
int     _DSA_EXPORT dsa_get_mvt_lkt_number_s(DSA_DRIVE *obj, int sidx, int *number, int kind, long timeout);
int     _DSA_EXPORT dsa_get_mvt_lkt_time_s(DSA_DRIVE *obj, int sidx, double *time, int kind, long timeout);
int     _DSA_EXPORT dsa_get_came_value_s(DSA_DRIVE *obj, double *factor, int kind, long timeout);
int     _DSA_EXPORT dsa_get_brake_deceleration_s(DSA_DRIVE *obj, double *dec, int kind, long timeout);
int     _DSA_EXPORT dsa_get_target_position_s(DSA_DRIVE *obj, int sidx, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_profile_velocity_s(DSA_DRIVE *obj, int sidx, double *vel, int kind, long timeout);
int     _DSA_EXPORT dsa_get_profile_acceleration_s(DSA_DRIVE *obj, int sidx, double *acc, int kind, long timeout);
int     _DSA_EXPORT dsa_get_jerk_time_s(DSA_DRIVE *obj, int sidx, double *tim, int kind, long timeout);
int     _DSA_EXPORT dsa_get_profile_deceleration_s(DSA_DRIVE *obj, int sidx, double *dec, int kind, long timeout);
int     _DSA_EXPORT dsa_get_end_velocity_s(DSA_DRIVE *obj, int sidx, double *vel, int kind, long timeout);
int     _DSA_EXPORT dsa_get_ctrl_source_type_s(DSA_DRIVE *obj, int *typ, int kind, long timeout);
int     _DSA_EXPORT dsa_get_ctrl_source_index_s(DSA_DRIVE *obj, int *index, int kind, long timeout);
int     _DSA_EXPORT dsa_get_ctrl_shift_factor_s(DSA_DRIVE *obj, int *shift, int kind, long timeout);
int     _DSA_EXPORT dsa_get_ctrl_offset_s(DSA_DRIVE *obj, long *offset, int kind, long timeout);
int     _DSA_EXPORT dsa_get_ctrl_gain_s(DSA_DRIVE *obj, double *gain, int kind, long timeout);
int     _DSA_EXPORT dsa_get_motor_kt_factor_s(DSA_DRIVE *obj, double *kt, int kind, long timeout);
int     _DSA_EXPORT dsa_get_position_ctrl_error_s(DSA_DRIVE *obj, double *err, int kind, long timeout);
int     _DSA_EXPORT dsa_get_position_max_error_s(DSA_DRIVE *obj, double *err, int kind, long timeout);
int     _DSA_EXPORT dsa_get_position_demand_value_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_position_actual_value_s(DSA_DRIVE *obj, double *pos, int kind, long timeout);
int     _DSA_EXPORT dsa_get_velocity_demand_value_s(DSA_DRIVE *obj, double *vel, int kind, long timeout);
int     _DSA_EXPORT dsa_get_velocity_actual_value_s(DSA_DRIVE *obj, double *vel, int kind, long timeout);
int     _DSA_EXPORT dsa_get_acc_demand_value_s(DSA_DRIVE *obj, double *acc, int kind, long timeout);
int     _DSA_EXPORT dsa_get_acc_actual_value_s(DSA_DRIVE *obj, double *acc, int kind, long timeout);
int     _DSA_EXPORT dsa_get_ref_demand_value_s(DSA_DRIVE *obj, double *ref, int kind, long timeout);
int     _DSA_EXPORT dsa_get_drive_control_mask_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_current_phase_1_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_current_phase_2_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_current_phase_3_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_lkt_phase_1_s(DSA_DRIVE *obj, double *lkt, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_lkt_phase_2_s(DSA_DRIVE *obj, double *lkt, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_lkt_phase_3_s(DSA_DRIVE *obj, double *lkt, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_demand_value_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_actual_value_s(DSA_DRIVE *obj, double *cur, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_sine_signal_s(DSA_DRIVE *obj, double *val, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_cosine_signal_s(DSA_DRIVE *obj, double *val, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_index_signal_s(DSA_DRIVE *obj, double *val, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_hall_1_signal_s(DSA_DRIVE *obj, double *val, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_hall_2_signal_s(DSA_DRIVE *obj, double *val, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_hall_3_signal_s(DSA_DRIVE *obj, double *val, int kind, long timeout);
int     _DSA_EXPORT dsa_get_encoder_hall_dig_signal_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_digital_input_s(DSA_DRIVE *obj, dword *inp, int kind, long timeout);
int     _DSA_EXPORT dsa_get_analog_input_s(DSA_DRIVE *obj, double *inp, int kind, long timeout);
int     _DSA_EXPORT dsa_get_x_digital_input_s(DSA_DRIVE *obj, dword *inp, int kind, long timeout);
int     _DSA_EXPORT dsa_get_x_analog_input_1_s(DSA_DRIVE *obj, double *inp, int kind, long timeout);
int     _DSA_EXPORT dsa_get_x_analog_input_2_s(DSA_DRIVE *obj, double *inp, int kind, long timeout);
int     _DSA_EXPORT dsa_get_drive_status_1_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_drive_status_2_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_error_code_s(DSA_DRIVE *obj, int *code, int kind, long timeout);
int     _DSA_EXPORT dsa_get_cl_i2t_value_s(DSA_DRIVE *obj, double *val, int kind, long timeout);
int     _DSA_EXPORT dsa_get_axis_number_s(DSA_DRIVE *obj, int *num, int kind, long timeout);
int     _DSA_EXPORT dsa_get_daisy_chain_number_s(DSA_DRIVE *obj, int *num, int kind, long timeout);
int     _DSA_EXPORT dsa_get_drive_temperature_s(DSA_DRIVE *obj, double *temp, int kind, long timeout);
int     _DSA_EXPORT dsa_get_drive_mask_value_s(DSA_DRIVE *obj, dword *str, int kind, long timeout);
int     _DSA_EXPORT dsa_get_drive_display_s(DSA_DRIVE *obj, int sidx, dword *str, int kind, long timeout);
int     _DSA_EXPORT dsa_get_drive_sequence_line_s(DSA_DRIVE *obj, long *line, int kind, long timeout);
int     _DSA_EXPORT dsa_get_drive_fuse_status_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_irq_drive_status_1_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_irq_drive_status_2_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_ack_drive_status_1_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_ack_drive_status_2_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_irq_pending_axis_mask_s(DSA_DRIVE *obj, dword *mask, int kind, long timeout);
int     _DSA_EXPORT dsa_get_can_feedback_1_s(DSA_DRIVE *obj, dword *val1, int kind, long timeout);
int     _DSA_EXPORT dsa_get_can_feedback_2_s(DSA_DRIVE *obj, dword *val1, int kind, long timeout);

#endif /* DSA_IMPL_S */

/*
 * register setter - synchronous
 */
#ifdef DSA_IMPL_S
int     _DSA_EXPORT dsa_set_pl_proportional_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
int     _DSA_EXPORT dsa_set_pl_speed_feedback_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
int     _DSA_EXPORT dsa_set_pl_force_feedback_gain_1_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
int     _DSA_EXPORT dsa_set_pl_integrator_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
int     _DSA_EXPORT dsa_set_pl_anti_windup_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
int     _DSA_EXPORT dsa_set_pl_integrator_limitation_s(DSA_DRIVE_BASE *obj, double limit, long timeout);
int     _DSA_EXPORT dsa_set_pl_integrator_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
int     _DSA_EXPORT dsa_set_pl_speed_filter_s(DSA_DRIVE_BASE *obj, double tim, long timeout);
int     _DSA_EXPORT dsa_set_pl_output_filter_s(DSA_DRIVE_BASE *obj, double tim, long timeout);
int     _DSA_EXPORT dsa_set_cl_input_filter_s(DSA_DRIVE_BASE *obj, double tim, long timeout);
int     _DSA_EXPORT dsa_set_ttl_special_filter_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
int     _DSA_EXPORT dsa_set_pl_force_feedback_gain_2_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
int     _DSA_EXPORT dsa_set_pl_speed_feedfwd_gain_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
int     _DSA_EXPORT dsa_set_pl_acc_feedforward_gain_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
int     _DSA_EXPORT dsa_set_cl_phase_advance_factor_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
int     _DSA_EXPORT dsa_set_apr_input_filter_s(DSA_DRIVE_BASE *obj, double time, long timeout);
int     _DSA_EXPORT dsa_set_cl_phase_advance_shift_s(DSA_DRIVE_BASE *obj, double shift, long timeout);
int     _DSA_EXPORT dsa_set_min_position_range_limit_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
int     _DSA_EXPORT dsa_set_max_position_range_limit_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
int     _DSA_EXPORT dsa_set_max_profile_velocity_s(DSA_DRIVE_BASE *obj, double vel, long timeout);
int     _DSA_EXPORT dsa_set_max_acceleration_s(DSA_DRIVE_BASE *obj, double acc, long timeout);
int     _DSA_EXPORT dsa_set_following_error_window_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
int     _DSA_EXPORT dsa_set_velocity_error_limit_s(DSA_DRIVE_BASE *obj, double vel, long timeout);
int     _DSA_EXPORT dsa_set_switch_limit_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
int     _DSA_EXPORT dsa_set_enable_input_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
int     _DSA_EXPORT dsa_set_min_soft_position_limit_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
int     _DSA_EXPORT dsa_set_max_soft_position_limit_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
int     _DSA_EXPORT dsa_set_profile_limit_mode_s(DSA_DRIVE_BASE *obj, dword flags, long timeout);
int     _DSA_EXPORT dsa_set_io_error_event_mask_s(DSA_DRIVE_BASE *obj, dword mask, long timeout);
int     _DSA_EXPORT dsa_set_position_window_time_s(DSA_DRIVE_BASE *obj, double tim, long timeout);
int     _DSA_EXPORT dsa_set_position_window_s(DSA_DRIVE_BASE *obj, double win, long timeout);
int     _DSA_EXPORT dsa_set_homing_method_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
int     _DSA_EXPORT dsa_set_homing_zero_speed_s(DSA_DRIVE_BASE *obj, double vel, long timeout);
int     _DSA_EXPORT dsa_set_homing_acceleration_s(DSA_DRIVE_BASE *obj, double acc, long timeout);
int     _DSA_EXPORT dsa_set_homing_following_limit_s(DSA_DRIVE_BASE *obj, double win, long timeout);
int     _DSA_EXPORT dsa_set_homing_current_limit_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
int     _DSA_EXPORT dsa_set_home_offset_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
int     _DSA_EXPORT dsa_set_homing_fixed_mvt_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
int     _DSA_EXPORT dsa_set_homing_switch_mvt_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
int     _DSA_EXPORT dsa_set_homing_index_mvt_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
int     _DSA_EXPORT dsa_set_homing_fine_tuning_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
int     _DSA_EXPORT dsa_set_homing_fine_tuning_value_s(DSA_DRIVE_BASE *obj, double phase, long timeout);
int     _DSA_EXPORT dsa_set_motor_phase_correction_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
int     _DSA_EXPORT dsa_set_software_current_limit_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
int     _DSA_EXPORT dsa_set_drive_control_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
int     _DSA_EXPORT dsa_set_display_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
int     _DSA_EXPORT dsa_set_encoder_inversion_s(DSA_DRIVE_BASE *obj, double invert, long timeout);
int     _DSA_EXPORT dsa_set_pdr_step_value_s(DSA_DRIVE_BASE *obj, double step, long timeout);
int     _DSA_EXPORT dsa_set_encoder_phase_1_offset_s(DSA_DRIVE_BASE *obj, double offset, long timeout);
int     _DSA_EXPORT dsa_set_encoder_phase_2_offset_s(DSA_DRIVE_BASE *obj, double offset, long timeout);
int     _DSA_EXPORT dsa_set_encoder_phase_1_factor_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
int     _DSA_EXPORT dsa_set_encoder_phase_2_factor_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
int     _DSA_EXPORT dsa_set_encoder_phase_3_offset_s(DSA_DRIVE_BASE *obj, double offset, long timeout);
int     _DSA_EXPORT dsa_set_encoder_index_distance_s(DSA_DRIVE_BASE *obj, double pos, long timeout);
int     _DSA_EXPORT dsa_set_encoder_phase_3_factor_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
int     _DSA_EXPORT dsa_set_cl_proportional_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
int     _DSA_EXPORT dsa_set_cl_integrator_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
int     _DSA_EXPORT dsa_set_cl_output_filter_s(DSA_DRIVE_BASE *obj, double tim, long timeout);
int     _DSA_EXPORT dsa_set_cl_current_limit_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
int     _DSA_EXPORT dsa_set_cl_i2t_current_limit_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
int     _DSA_EXPORT dsa_set_cl_i2t_time_limit_s(DSA_DRIVE_BASE *obj, double tim, long timeout);
int     _DSA_EXPORT dsa_set_cl_regen_mode_s(DSA_DRIVE_BASE *obj, int mode, long timeout);
int     _DSA_EXPORT dsa_set_init_mode_s(DSA_DRIVE_BASE *obj, int typ, long timeout);
int     _DSA_EXPORT dsa_set_init_pulse_level_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
int     _DSA_EXPORT dsa_set_init_max_current_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
int     _DSA_EXPORT dsa_set_init_final_phase_s(DSA_DRIVE_BASE *obj, double cal, long timeout);
int     _DSA_EXPORT dsa_set_init_time_s(DSA_DRIVE_BASE *obj, double tim, long timeout);
int     _DSA_EXPORT dsa_set_init_current_rate_s(DSA_DRIVE_BASE *obj, double cur, long timeout);
int     _DSA_EXPORT dsa_set_init_phase_rate_s(DSA_DRIVE_BASE *obj, double cal, long timeout);
int     _DSA_EXPORT dsa_set_init_initial_phase_s(DSA_DRIVE_BASE *obj, double cal, long timeout);
int     _DSA_EXPORT dsa_set_drive_fuse_checking_s(DSA_DRIVE_BASE *obj, dword mask, long timeout);
int     _DSA_EXPORT dsa_set_motor_temp_checking_s(DSA_DRIVE_BASE *obj, dword val, long timeout);
int     _DSA_EXPORT dsa_set_mon_source_type_s(DSA_DRIVE_BASE *obj, int sidx, int typ, long timeout);
int     _DSA_EXPORT dsa_set_mon_source_index_s(DSA_DRIVE_BASE *obj, int sidx, int index, long timeout);
int     _DSA_EXPORT dsa_set_mon_dest_index_s(DSA_DRIVE_BASE *obj, int sidx, int index, long timeout);
int     _DSA_EXPORT dsa_set_mon_offset_s(DSA_DRIVE_BASE *obj, int sidx, long offset, long timeout);
int     _DSA_EXPORT dsa_set_mon_gain_s(DSA_DRIVE_BASE *obj, int sidx, double gain, long timeout);
int     _DSA_EXPORT dsa_set_x_analog_offset_s(DSA_DRIVE_BASE *obj, int sidx, double offset, long timeout);
int     _DSA_EXPORT dsa_set_x_analog_gain_s(DSA_DRIVE_BASE *obj, int sidx, double gain, long timeout);
int     _DSA_EXPORT dsa_set_syncro_input_mask_s(DSA_DRIVE_BASE *obj, dword mask, long timeout);
int     _DSA_EXPORT dsa_set_syncro_input_value_s(DSA_DRIVE_BASE *obj, dword mask, long timeout);
int     _DSA_EXPORT dsa_set_syncro_output_mask_s(DSA_DRIVE_BASE *obj, double mask, long timeout);
int     _DSA_EXPORT dsa_set_syncro_output_value_s(DSA_DRIVE_BASE *obj, double mask, long timeout);
int     _DSA_EXPORT dsa_set_syncro_start_timeout_s(DSA_DRIVE_BASE *obj, int tim, long timeout);
int     _DSA_EXPORT dsa_set_digital_output_s(DSA_DRIVE_BASE *obj, dword out, long timeout);
int     _DSA_EXPORT dsa_set_x_digital_output_s(DSA_DRIVE_BASE *obj, dword out, long timeout);
int     _DSA_EXPORT dsa_set_x_analog_output_1_s(DSA_DRIVE_BASE *obj, double out, long timeout);
int     _DSA_EXPORT dsa_set_x_analog_output_2_s(DSA_DRIVE_BASE *obj, double out, long timeout);
int     _DSA_EXPORT dsa_set_analog_output_s(DSA_DRIVE_BASE *obj, double out, long timeout);
int     _DSA_EXPORT dsa_set_interrupt_mask_1_s(DSA_DRIVE_BASE *obj, int sidx, dword mask, long timeout);
int     _DSA_EXPORT dsa_set_interrupt_mask_2_s(DSA_DRIVE_BASE *obj, int sidx, dword mask, long timeout);
int     _DSA_EXPORT dsa_set_trigger_irq_mask_s(DSA_DRIVE_BASE *obj, dword mask, long timeout);
int     _DSA_EXPORT dsa_set_trigger_io_mask_s(DSA_DRIVE_BASE *obj, dword mask, long timeout);
int     _DSA_EXPORT dsa_set_trigger_map_offset_s(DSA_DRIVE_BASE *obj, int offset, long timeout);
int     _DSA_EXPORT dsa_set_trigger_map_size_s(DSA_DRIVE_BASE *obj, int size, long timeout);
int     _DSA_EXPORT dsa_set_realtime_enabled_global_s(DSA_DRIVE_BASE *obj, int enable, long timeout);
int     _DSA_EXPORT dsa_set_realtime_valid_mask_s(DSA_DRIVE_BASE *obj, dword mask, long timeout);
int     _DSA_EXPORT dsa_set_realtime_enabled_mask_s(DSA_DRIVE_BASE *obj, dword mask, long timeout);
int     _DSA_EXPORT dsa_set_realtime_pending_mask_s(DSA_DRIVE_BASE *obj, dword mask, long timeout);
int     _DSA_EXPORT dsa_set_ebl_baudrate_s(DSA_DRIVE_BASE *obj, long baud, long timeout);
int     _DSA_EXPORT dsa_set_indirect_axis_number_s(DSA_DRIVE_BASE *obj, int axis, long timeout);
int     _DSA_EXPORT dsa_set_indirect_register_idx_s(DSA_DRIVE_BASE *obj, int idx, long timeout);
int     _DSA_EXPORT dsa_set_indirect_register_sidx_s(DSA_DRIVE_BASE *obj, int sidx, long timeout);
int     _DSA_EXPORT dsa_set_concatenated_mvt_s(DSA_DRIVE_BASE *obj, int concat, long timeout);
int     _DSA_EXPORT dsa_set_profile_type_s(DSA_DRIVE_BASE *obj, int sidx, int typ, long timeout);
int     _DSA_EXPORT dsa_set_mvt_lkt_number_s(DSA_DRIVE_BASE *obj, int sidx, int number, long timeout);
int     _DSA_EXPORT dsa_set_mvt_lkt_time_s(DSA_DRIVE_BASE *obj, int sidx, double time, long timeout);
int     _DSA_EXPORT dsa_set_came_value_s(DSA_DRIVE_BASE *obj, double factor, long timeout);
int     _DSA_EXPORT dsa_set_brake_deceleration_s(DSA_DRIVE_BASE *obj, double dec, long timeout);
int     _DSA_EXPORT dsa_set_target_position_s(DSA_DRIVE_BASE *obj, int sidx, double pos, long timeout);
int     _DSA_EXPORT dsa_set_profile_velocity_s(DSA_DRIVE_BASE *obj, int sidx, double vel, long timeout);
int     _DSA_EXPORT dsa_set_profile_acceleration_s(DSA_DRIVE_BASE *obj, int sidx, double acc, long timeout);
int     _DSA_EXPORT dsa_set_jerk_time_s(DSA_DRIVE_BASE *obj, int sidx, double tim, long timeout);
int     _DSA_EXPORT dsa_set_profile_deceleration_s(DSA_DRIVE_BASE *obj, int sidx, double dec, long timeout);
int     _DSA_EXPORT dsa_set_end_velocity_s(DSA_DRIVE_BASE *obj, int sidx, double vel, long timeout);
int     _DSA_EXPORT dsa_set_ctrl_source_type_s(DSA_DRIVE_BASE *obj, int typ, long timeout);
int     _DSA_EXPORT dsa_set_ctrl_source_index_s(DSA_DRIVE_BASE *obj, int index, long timeout);
int     _DSA_EXPORT dsa_set_ctrl_shift_factor_s(DSA_DRIVE_BASE *obj, int shift, long timeout);
int     _DSA_EXPORT dsa_set_ctrl_offset_s(DSA_DRIVE_BASE *obj, long offset, long timeout);
int     _DSA_EXPORT dsa_set_ctrl_gain_s(DSA_DRIVE_BASE *obj, double gain, long timeout);
int     _DSA_EXPORT dsa_set_motor_kt_factor_s(DSA_DRIVE_BASE *obj, double kt, long timeout);

#endif /* DSA_IMPL_S */

/*
 * register getter - asynchronous
 */
#ifdef DSA_IMPL_A
int     _DSA_EXPORT dsa_get_pl_proportional_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_pl_speed_feedback_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_pl_force_feedback_gain_1_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_pl_integrator_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_pl_anti_windup_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_pl_integrator_limitation_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_pl_integrator_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_pl_speed_filter_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_pl_output_filter_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_input_filter_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_ttl_special_filter_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_pl_force_feedback_gain_2_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_pl_speed_feedfwd_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_pl_acc_feedforward_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_phase_advance_factor_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_apr_input_filter_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_phase_advance_shift_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_min_position_range_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_max_position_range_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_max_profile_velocity_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_max_acceleration_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_following_error_window_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_velocity_error_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_switch_limit_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_enable_input_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_min_soft_position_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_max_soft_position_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_profile_limit_mode_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_io_error_event_mask_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_position_window_time_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_position_window_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_homing_method_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_homing_zero_speed_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_homing_acceleration_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_homing_following_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_homing_current_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_home_offset_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_homing_fixed_mvt_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_homing_switch_mvt_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_homing_index_mvt_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_homing_fine_tuning_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_homing_fine_tuning_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_motor_phase_correction_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_software_current_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_drive_control_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_display_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_inversion_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_pdr_step_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_phase_1_offset_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_phase_2_offset_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_phase_1_factor_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_phase_2_factor_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_phase_3_offset_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_index_distance_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_phase_3_factor_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_proportional_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_integrator_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_output_filter_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_current_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_i2t_current_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_i2t_time_limit_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_regen_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_init_mode_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_init_pulse_level_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_init_max_current_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_init_final_phase_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_init_time_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_init_current_rate_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_init_phase_rate_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_init_initial_phase_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_drive_fuse_checking_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_motor_temp_checking_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_mon_source_type_a(DSA_DRIVE *obj, int sidx, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_mon_source_index_a(DSA_DRIVE *obj, int sidx, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_mon_dest_index_a(DSA_DRIVE *obj, int sidx, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_mon_offset_a(DSA_DRIVE *obj, int sidx, int kind, DSA_LONG_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_mon_gain_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_x_analog_offset_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_x_analog_gain_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_syncro_input_mask_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_syncro_input_value_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_syncro_output_mask_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_syncro_output_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_syncro_start_timeout_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_digital_output_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_x_digital_output_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_x_analog_output_1_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_x_analog_output_2_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_analog_output_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_interrupt_mask_1_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_interrupt_mask_2_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_trigger_irq_mask_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_trigger_io_mask_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_trigger_map_offset_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_trigger_map_size_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_realtime_enabled_global_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_realtime_valid_mask_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_realtime_enabled_mask_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_realtime_pending_mask_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_ebl_baudrate_a(DSA_DRIVE *obj, int kind, DSA_LONG_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_indirect_axis_number_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_indirect_register_idx_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_indirect_register_sidx_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_concatenated_mvt_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_profile_type_a(DSA_DRIVE *obj, int sidx, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_mvt_lkt_number_a(DSA_DRIVE *obj, int sidx, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_mvt_lkt_time_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_came_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_brake_deceleration_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_target_position_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_profile_velocity_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_profile_acceleration_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_jerk_time_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_profile_deceleration_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_end_velocity_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_ctrl_source_type_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_ctrl_source_index_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_ctrl_shift_factor_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_ctrl_offset_a(DSA_DRIVE *obj, int kind, DSA_LONG_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_ctrl_gain_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_motor_kt_factor_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_position_ctrl_error_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_position_max_error_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_position_demand_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_position_actual_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_velocity_demand_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_velocity_actual_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_acc_demand_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_acc_actual_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_ref_demand_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_drive_control_mask_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_current_phase_1_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_current_phase_2_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_current_phase_3_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_lkt_phase_1_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_lkt_phase_2_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_lkt_phase_3_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_demand_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_actual_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_sine_signal_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_cosine_signal_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_index_signal_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_hall_1_signal_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_hall_2_signal_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_hall_3_signal_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_encoder_hall_dig_signal_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_digital_input_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_analog_input_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_x_digital_input_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_x_analog_input_1_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_x_analog_input_2_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_drive_status_1_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_drive_status_2_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_error_code_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_cl_i2t_value_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_axis_number_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_daisy_chain_number_a(DSA_DRIVE *obj, int kind, DSA_INT_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_drive_temperature_a(DSA_DRIVE *obj, int kind, DSA_DOUBLE_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_drive_mask_value_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_drive_display_a(DSA_DRIVE *obj, int sidx, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_drive_sequence_line_a(DSA_DRIVE *obj, int kind, DSA_LONG_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_drive_fuse_status_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_irq_drive_status_1_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_irq_drive_status_2_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_ack_drive_status_1_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_ack_drive_status_2_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_irq_pending_axis_mask_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_can_feedback_1_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_get_can_feedback_2_a(DSA_DRIVE *obj, int kind, DSA_DWORD_HANDLER handler, void *param);

#endif /* DSA_IMPL_A */

/*
 * register setter - asynchronous
 */
#ifdef DSA_IMPL_A
int     _DSA_EXPORT dsa_set_pl_proportional_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_pl_speed_feedback_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_pl_force_feedback_gain_1_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_pl_integrator_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_pl_anti_windup_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_pl_integrator_limitation_a(DSA_DRIVE_BASE *obj, double limit, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_pl_integrator_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_pl_speed_filter_a(DSA_DRIVE_BASE *obj, double tim, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_pl_output_filter_a(DSA_DRIVE_BASE *obj, double tim, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_cl_input_filter_a(DSA_DRIVE_BASE *obj, double tim, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_ttl_special_filter_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_pl_force_feedback_gain_2_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_pl_speed_feedfwd_gain_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_pl_acc_feedforward_gain_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_cl_phase_advance_factor_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_apr_input_filter_a(DSA_DRIVE_BASE *obj, double time, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_cl_phase_advance_shift_a(DSA_DRIVE_BASE *obj, double shift, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_min_position_range_limit_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_max_position_range_limit_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_max_profile_velocity_a(DSA_DRIVE_BASE *obj, double vel, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_max_acceleration_a(DSA_DRIVE_BASE *obj, double acc, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_following_error_window_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_velocity_error_limit_a(DSA_DRIVE_BASE *obj, double vel, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_switch_limit_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_enable_input_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_min_soft_position_limit_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_max_soft_position_limit_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_profile_limit_mode_a(DSA_DRIVE_BASE *obj, dword flags, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_io_error_event_mask_a(DSA_DRIVE_BASE *obj, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_position_window_time_a(DSA_DRIVE_BASE *obj, double tim, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_position_window_a(DSA_DRIVE_BASE *obj, double win, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_homing_method_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_homing_zero_speed_a(DSA_DRIVE_BASE *obj, double vel, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_homing_acceleration_a(DSA_DRIVE_BASE *obj, double acc, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_homing_following_limit_a(DSA_DRIVE_BASE *obj, double win, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_homing_current_limit_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_home_offset_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_homing_fixed_mvt_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_homing_switch_mvt_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_homing_index_mvt_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_homing_fine_tuning_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_homing_fine_tuning_value_a(DSA_DRIVE_BASE *obj, double phase, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_motor_phase_correction_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_software_current_limit_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_drive_control_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_display_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_encoder_inversion_a(DSA_DRIVE_BASE *obj, double invert, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_pdr_step_value_a(DSA_DRIVE_BASE *obj, double step, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_encoder_phase_1_offset_a(DSA_DRIVE_BASE *obj, double offset, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_encoder_phase_2_offset_a(DSA_DRIVE_BASE *obj, double offset, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_encoder_phase_1_factor_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_encoder_phase_2_factor_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_encoder_phase_3_offset_a(DSA_DRIVE_BASE *obj, double offset, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_encoder_index_distance_a(DSA_DRIVE_BASE *obj, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_encoder_phase_3_factor_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_cl_proportional_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_cl_integrator_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_cl_output_filter_a(DSA_DRIVE_BASE *obj, double tim, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_cl_current_limit_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_cl_i2t_current_limit_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_cl_i2t_time_limit_a(DSA_DRIVE_BASE *obj, double tim, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_cl_regen_mode_a(DSA_DRIVE_BASE *obj, int mode, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_init_mode_a(DSA_DRIVE_BASE *obj, int typ, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_init_pulse_level_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_init_max_current_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_init_final_phase_a(DSA_DRIVE_BASE *obj, double cal, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_init_time_a(DSA_DRIVE_BASE *obj, double tim, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_init_current_rate_a(DSA_DRIVE_BASE *obj, double cur, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_init_phase_rate_a(DSA_DRIVE_BASE *obj, double cal, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_init_initial_phase_a(DSA_DRIVE_BASE *obj, double cal, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_drive_fuse_checking_a(DSA_DRIVE_BASE *obj, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_motor_temp_checking_a(DSA_DRIVE_BASE *obj, dword val, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_mon_source_type_a(DSA_DRIVE_BASE *obj, int sidx, int typ, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_mon_source_index_a(DSA_DRIVE_BASE *obj, int sidx, int index, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_mon_dest_index_a(DSA_DRIVE_BASE *obj, int sidx, int index, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_mon_offset_a(DSA_DRIVE_BASE *obj, int sidx, long offset, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_mon_gain_a(DSA_DRIVE_BASE *obj, int sidx, double gain, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_x_analog_offset_a(DSA_DRIVE_BASE *obj, int sidx, double offset, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_x_analog_gain_a(DSA_DRIVE_BASE *obj, int sidx, double gain, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_syncro_input_mask_a(DSA_DRIVE_BASE *obj, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_syncro_input_value_a(DSA_DRIVE_BASE *obj, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_syncro_output_mask_a(DSA_DRIVE_BASE *obj, double mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_syncro_output_value_a(DSA_DRIVE_BASE *obj, double mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_syncro_start_timeout_a(DSA_DRIVE_BASE *obj, int tim, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_digital_output_a(DSA_DRIVE_BASE *obj, dword out, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_x_digital_output_a(DSA_DRIVE_BASE *obj, dword out, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_x_analog_output_1_a(DSA_DRIVE_BASE *obj, double out, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_x_analog_output_2_a(DSA_DRIVE_BASE *obj, double out, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_analog_output_a(DSA_DRIVE_BASE *obj, double out, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_interrupt_mask_1_a(DSA_DRIVE_BASE *obj, int sidx, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_interrupt_mask_2_a(DSA_DRIVE_BASE *obj, int sidx, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_trigger_irq_mask_a(DSA_DRIVE_BASE *obj, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_trigger_io_mask_a(DSA_DRIVE_BASE *obj, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_trigger_map_offset_a(DSA_DRIVE_BASE *obj, int offset, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_trigger_map_size_a(DSA_DRIVE_BASE *obj, int size, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_realtime_enabled_global_a(DSA_DRIVE_BASE *obj, int enable, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_realtime_valid_mask_a(DSA_DRIVE_BASE *obj, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_realtime_enabled_mask_a(DSA_DRIVE_BASE *obj, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_realtime_pending_mask_a(DSA_DRIVE_BASE *obj, dword mask, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_ebl_baudrate_a(DSA_DRIVE_BASE *obj, long baud, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_indirect_axis_number_a(DSA_DRIVE_BASE *obj, int axis, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_indirect_register_idx_a(DSA_DRIVE_BASE *obj, int idx, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_indirect_register_sidx_a(DSA_DRIVE_BASE *obj, int sidx, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_concatenated_mvt_a(DSA_DRIVE_BASE *obj, int concat, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_profile_type_a(DSA_DRIVE_BASE *obj, int sidx, int typ, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_mvt_lkt_number_a(DSA_DRIVE_BASE *obj, int sidx, int number, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_mvt_lkt_time_a(DSA_DRIVE_BASE *obj, int sidx, double time, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_came_value_a(DSA_DRIVE_BASE *obj, double factor, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_brake_deceleration_a(DSA_DRIVE_BASE *obj, double dec, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_target_position_a(DSA_DRIVE_BASE *obj, int sidx, double pos, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_profile_velocity_a(DSA_DRIVE_BASE *obj, int sidx, double vel, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_profile_acceleration_a(DSA_DRIVE_BASE *obj, int sidx, double acc, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_jerk_time_a(DSA_DRIVE_BASE *obj, int sidx, double tim, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_profile_deceleration_a(DSA_DRIVE_BASE *obj, int sidx, double dec, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_end_velocity_a(DSA_DRIVE_BASE *obj, int sidx, double vel, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_ctrl_source_type_a(DSA_DRIVE_BASE *obj, int typ, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_ctrl_source_index_a(DSA_DRIVE_BASE *obj, int index, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_ctrl_shift_factor_a(DSA_DRIVE_BASE *obj, int shift, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_ctrl_offset_a(DSA_DRIVE_BASE *obj, long offset, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_ctrl_gain_a(DSA_DRIVE_BASE *obj, double gain, DSA_HANDLER handler, void *param);
int     _DSA_EXPORT dsa_set_motor_kt_factor_a(DSA_DRIVE_BASE *obj, double kt, DSA_HANDLER handler, void *param);

#endif /* DSA_IMPL_A */

#ifdef __cplusplus
} /* extern "C" */
#endif


/*
 * DSA constants - c++
 */
#ifdef DSA_OO_API

class Dsa;
class DsaException;
class DsaBase;
class DsaDeviceBase;
class DsaHandlerDeviceBase;
class DsaDevice;
class DsaDeviceGroup;
class DsaDriveBase;
class DsaDrive;
class DsaDriveGroup;
class DsaGantry;
class DsaDsmaxBase;
class DsaDsmax;
class DsaDsmaxGroup;
class DsaIpolGroup;
class DsaGPModuleBase;
class DsaGPModule;
class DsaGPModuleGroup;


/* 
 * generate exceptions from error codes
 */
#define ERRCHK(a) do { int _err = (a); if(_err) throw DsaException(_err); } while(0)
#define ERRTRANS() do { if(getTransLevel() > 0) throw DsaException(DSA_EBADSTATE); } while(0)


/*
 * asynchronous handler types
 */
typedef void (DSA_CALLBACK *DsaHandler)(DsaHandlerDeviceBase dev, int err, void *param);
typedef void (DSA_CALLBACK *DsaIntHandler)(DsaHandlerDeviceBase dev, int err, void *param, int val);
typedef void (DSA_CALLBACK *DsaLongHandler)(DsaHandlerDeviceBase dev, int err, void *param, long val);
typedef void (DSA_CALLBACK *DsaDWordHandler)(DsaHandlerDeviceBase dev, int err, void *param, dword val);
typedef void (DSA_CALLBACK *DsaDoubleHandler)(DsaHandlerDeviceBase dev, int err, void *param, double val);
typedef void (DSA_CALLBACK *DsaStatusHandler)(DsaHandlerDeviceBase dev, int err, void *param, const DsaStatus *stat);
typedef void (DSA_CALLBACK *Dsa2intHandler)(DsaHandlerDeviceBase dev, int err, void *param, int val1, int val2);


/*
 * DSA exception - c++
 */
class DsaException {
	friend class Dsa;
	friend class DsaBase;
	friend class DsaDeviceBase;
	friend class DsaHandlerDeviceBase;
	friend class DsaDevice;
	friend class DsaDeviceGroup;
	friend class DsaDriveBase;
	friend class DsaDrive;
	friend class DsaDriveGroup;
	friend class DsaGantry;
	friend class DsaDsmaxBase;
	friend class DsaDsmax;
	friend class DsaDsmaxGroup;
	friend class DsaIpolGroup;
	friend class DsaGPModuleBase;
	friend class DsaGPModule;
	friend class DsaGPModuleGroup;

	/* error codes - c++ */
public:
    enum { EBADDRVVER = -325 };                      /* a drive with a bad version has been detected */
    enum { EBADIPOLGRP = -327 };                     /* the ipol group is not correctly defined */
    enum { EBADPARAM = -322 };                       /* one of the parameter is not valid */
    enum { EBADSTATE = -324 };                       /* this operation is not allowed in this state */
    enum { EBUSERROR = -313 };                       /* the underlaying etel-bus is not working fine */
    enum { EBUSRESET = -314 };                       /* the underlaying etel-bus in performing a reset operation */
    enum { ECANCEL = -319 };                         /* the transaction has been canceled */
    enum { ECONVERT = -317 };                        /* a parameter exceeded the permitted range */
    enum { EDRVERROR = -311 };                       /* drive in error */
    enum { EDRVFAILED = -323 };                      /* the drive does not operate properly */
    enum { EINTERNAL = -316 };                       /* some internal error in the etel software */
    enum { ENOACK = -312 };                          /* no acknowledge from the drive */
    enum { ENODRIVE = -320 };                        /* the specified drive does not respond */
    enum { ENOTIMPLEMENTED = -326 };                 /* the specified operation is not implemented */
    enum { EOPENPORT = -321 };                       /* the specified port cannot be open */
    enum { ESYSTEM = -315 };                         /* some system resource return an error */
    enum { ETIMEOUT = -310 };                        /* a timeout has occured */
    enum { ETRANS = -318 };                          /* a transaction error has occured */


	/* exception code */
private:
    int code;

	/* constructor */
protected:
    DsaException(int e) { code = e; };

	/* translate error code */
public:
    static char_cp translate(int code) {
        return dsa_translate_error(code);
    }

    /* get error description */
public:
    int getCode() {
		return code; 
	}
    const char *getText() { 
		return translate(code); 
	}
};


/*
 * class Dsa - c++
 */
class Dsa {
	/*
	 * timeout special values
	 */
public:
     enum { DEF_TIMEOUT = (-2L) };                   /* use the default timeout appropriate for this communication */

	/*
	 * convert special value
	 */
public:
     enum { CONV_AUTO = -1 };                        /* read current drive value, bypass pending commands */

	/*
	 * register kind of access
	 */
public:
     enum { GET_CURRENT = 0 };                       /* read current drive value, bypass pending commands */
     enum { GET_WAITING = 1 };                       /* read current drive value, waiting pending commands */
     enum { GET_TRACE_CURRENT = 2 };                 /* get trace array, bypass pending commands */
     enum { GET_TRACE_WAITING = 3 };                 /* get trace array, waiting pending commands */
     enum { GET_CONV_FACTOR = 10 };                  /* get the conversion factor */
     enum { GET_MIN_VALUE = 11 };                    /* get the minimum value */
     enum { GET_MAX_VALUE = 12 };                    /* get the maximum value */
     enum { GET_DEF_VALUE = 13 };                    /* get the default value */

	/*
	 * parameters enumeration values - c++
	 */
public:
    enum { ANALOG = 0 };                             /* analog sine/cosine encoder */
    enum { CONTINUOUS_CURRENT = 2 };                 /* initialisation by sending continous to the motor */
    enum { CURRENT_PULSE = 1 };                      /* initialisation with current pulses */
    enum { DEFAULT_ALL = 0 };                        /* restore all informations from ROM default */
    enum { DEFAULT_SEQ_LKT = 1 };                    /* restore sequence and user lookup-tables from ROM default */
    enum { DEFAULT_X_PARAMS = 2 };                   /* restore user (X) registers and parameters from ROM default */
    enum { DISPLAY_ENCODER_SIGNALS = 4 };            /* display encoder's signals */
    enum { DISPLAY_NORMAL = 1 };                     /* display normal informations */
    enum { DISPLAY_SEQUENCE = 8 };                   /* display sequence line number */
    enum { DISPLAY_TEMPERATURE = 2 };                /* display drive's temperature */
    enum { ENABLE_AUTO = 170 };                      /* enable signal perform automatic power on of the drive */
    enum { ENABLE_NOT_USED = 125 };                  /* enable signal not used */
    enum { ENABLE_USED = 0 };                        /* enable signal is necessary to power on ths drive */
    enum { FAST_LKT_MVT = 11 };                      /* lookup-table motion in controller interrupt */
    enum { FORCE_REFERENCE = 0 };                    /* driver controlled by a force reference */
    enum { GATED_INDEX_NEG = 17 };                   /*  */
    enum { GATED_INDEX_NEG_L = 19 };                 /*  */
    enum { GATED_INDEX_POS = 16 };                   /*  */
    enum { GATED_INDEX_POS_L = 18 };                 /*  */
    enum { HALL = 2 };                               /* HALL effect encoder */
    enum { HOME_INVERTED = 2 };                      /* home switch is inverted */
    enum { HOME_SW_NEG = 3 };                        /*  */
    enum { HOME_SW_NEG_L = 7 };                      /*  */
    enum { HOME_SW_POS = 2 };                        /*  */
    enum { HOME_SW_POS_L = 6 };                      /*  */
    enum { HOME_SWITCH = 128 };                      /* home switch is used */
    enum { INFINITE_ROTARY_MVT = 12 };               /* infinite rotary motion (deprecated) */
    enum { INTEGRATOR_IN_POSITION = 1 };             /* integrator off during motion */
    enum { INTEGRATOR_OFF = 2 };                     /* integrator always off */
    enum { INTEGRATOR_ON = 0 };                      /* integrator always on */
    enum { INVERT_FORCE = 2 };                       /* invert current force of the motor */
    enum { INVERT_PHASES = 1 };                      /* invert phases 1 and 2 of the motor */
    enum { LIMIT_SW_NEG = 5 };                       /*  */
    enum { LIMIT_SW_POS = 4 };                       /*  */
    enum { LIMIT_SWITCH = 1 };                       /* limit switch are used */
    enum { LOAD_ALL = 0 };                           /* load all informations from flash memory */
    enum { LOAD_SEQ_LKT = 1 };                       /* load sequence and user lookup-tables from flash memory */
    enum { LOAD_X_PARAMS = 2 };                      /* load user (X) registers and parameters from flash memory */
    enum { MECHANICAL_NEG = 1 };                     /*  */
    enum { MECHANICAL_POS = 0 };                     /*  */
    enum { MULTI_INDEX_NEG = 13 };                   /*  */
    enum { MULTI_INDEX_NEG_L = 15 };                 /*  */
    enum { MULTI_INDEX_POS = 12 };                   /*  */
    enum { MULTI_INDEX_POS_L = 14 };                 /*  */
    enum { NO_INIT = 0 };                            /* no initialisation */
    enum { POSITION_PROFILE = 1 };                   /* standard position profile mode */
    enum { POSITION_REFERENCE = 4 };                 /* driver controlled by a position reference */
    enum { PULSE_DIRECTION = 5 };                    /* pulse and direction mode */
    enum { PULSE_DIRECTION_TTL = 6 };                /* pulse and direction mode with TTL encoder */
    enum { QS_BYPASS = 2 };                          /* bypass all pending command */
    enum { QS_INFINITE_DEC = 1 };                    /* stop motor with infinite deceleration (step) */
    enum { QS_POWER_OFF = 0 };                       /* switch off power bridge */
    enum { QS_PROGRAMMED_DEC = 2 };                  /* stop motor with programmed deceleration */
    enum { QS_STOP_SEQUENCE = 1 };                   /* also stop the sequence */
    enum { RECTANGULAR_MVT = 2 };                    /* trapezoidal motion (jerk = 0, acc = infinite) */
    enum { REGEN_LIMITED = 2 };                      /* regeneration of, max 10s */
    enum { REGEN_OFF = 0 };                          /* no regeneration */
    enum { REGEN_ON = 3 };                           /* regeneration always on */
    enum { S_CURVE_MVT = 1 };                        /* s-curve motion */
    enum { SAVE_ALL = 0 };                           /* save all informations in flash memory */
    enum { SAVE_SEQ_LKT = 1 };                       /* save sequence and user lookup-tables in flash memory */
    enum { SAVE_X_PARAMS = 2 };                      /* save user (X) registers and parameters in flash memory */
    enum { SINGLE_INDEX_NEG = 9 };                   /*  */
    enum { SINGLE_INDEX_NEG_L = 11 };                /*  */
    enum { SINGLE_INDEX_POS = 8 };                   /*  */
    enum { SINGLE_INDEX_POS_L = 10 };                /*  */
    enum { SLOW_LKT_MVT = 10 };                      /* lookup-table motion in profile interrupt */
    enum { SOURCE_MONITORING = 3 };                  /* monitoring of a monitoring register */
    enum { SOURCE_OFF = 0 };                         /* no real time monitoring */
    enum { SOURCE_PARAMETER = 2 };                   /* monitoring of a parameter */
    enum { SOURCE_USER_VARIABLE = 1 };               /* monitoring of a user variable */
    enum { SPEED_REFERENCE = 3 };                    /* driver controlled by a speed reference */
    enum { TRAPEZIODAL_MVT = 0 };                    /* trapezoidal motion (jerk = infinite, deprecated) */
    enum { TTL = 1 };                                /* TTL encoder */


	/*
	 * special functions - c++
	 */
public:
    static DsaDeviceBase createAuto(EtbBus etb, int axis);
    static DsaDeviceBase createAuto(int prod);

	static DsaStatus initStatus(void) {
		DsaStatus status = dsa_init_status();
		return status;
	}
	static DsaInfo initInfo(void) {
		DsaInfo info = dsa_init_info();
		return info;
	}
	static DsaXInfo initXInfo(void) {
		DsaXInfo info = dsa_init_x_info();
		return info;
	}
	static DsaVector initVector(void) {
		DsaVector vector = dsa_init_vector();
		return vector;
	}
	static DsaVectorTyp initVectorTyp(void) {
		DsaVectorTyp vector_typ = dsa_init_vector_typ();
		return vector_typ;
	}
	static DsaRTM initRtm(void) {
		DsaRTM rtm = dsa_init_rtm();
		return rtm;
	}


	#ifdef DSA_IMPL_S

	#endif /* DSA_IMPL_S */
	#ifdef DSA_IMPL_A

	#endif /* DSA_IMPL_A */
    static dword getVersion() {
        return dsa_get_version();
    }
    static time_t getBuildTime() {
        return dsa_get_build_time();
    }
    static dword getTimer() {
        return dsa_get_timer();
    }
    static dword getEdiVersion() {
        return dsa_get_edi_version();
    }
    static void beginSyncTrans() {
        ERRCHK(dsa_begin_sync_trans());
    }
    static void rollbackSyncTrans() {
        ERRCHK(dsa_rollback_sync_trans());
    }
    static void commitSyncTrans(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_commit_sync_trans(timeout));
    }
    static void beginAsyncTrans() {
        ERRCHK(dsa_begin_async_trans());
    }
    static void rollbackAsyncTrans() {
        ERRCHK(dsa_rollback_async_trans());
    }
    static void commitAsyncTrans(DsaDeviceBase *grp, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_commit_async_trans(*(DSA_DEVICE_BASE **)&grp, *(DSA_HANDLER*)&handler, param));
    }
    static int  getTransLevel() {
        int  level;
        ERRCHK(dsa_get_trans_level(&level));
        return level;
    }

};


/*
 * DsaBase class - c++
 */
class DsaBase: public Dsa {
	friend class DsaDeviceBase;
	friend class DsaDevice;
	friend class DsaDeviceGroup;
	friend class DsaDriveBase;
	friend class DsaDrive;
	friend class DsaDriveGroup;
	friend class DsaGantry;
	friend class DsaDsmaxBase;
	friend class DsaDsmax;
	friend class DsaDsmaxGroup;
	friend class DsaIpolGroup;
	friend class DsaGPModuleBase;
	friend class DsaGPModule;
	friend class DsaGPModuleGroup;

	/*
	 * member variable
	 */
protected:
    DSA_DEVICE_BASE *dsa;

	/* 
	 * constructors - destructor
	 */
protected:
	DsaBase(void) {
		this->dsa = NULL;		
	}
	DsaBase(DsaBase &obj) {
		ERRCHK(dsa_share(obj.dsa));		
		dsa = obj.dsa;
	}
public:
	~DsaBase(void) {
		if (dsa) 
			ERRCHK(dsa_destroy(&dsa));
	}

public:
    DSA_DEVICE_BASE* getDsaStructure() { 
		return(dsa);
	}
	/* 
	 * default operators
	 */
protected:
	DsaBase operator = (DsaBase &obj) {
		return obj;
	}

	/*
	 * hand make functions 
	 */
	DsaBase getGroupItem(int pos) {
		DsaBase obj;
		ERRCHK(dsa_get_group_item(dsa, pos, &obj.dsa));
		ERRCHK(dsa_share(obj.dsa));
		return obj;
	}
	DsaDsmax getDsmax(void);
	void setDsmax(DsaDsmax dsmax);

	/*
	 * special functions - c++
	 */
protected:
    void powerOn(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_power_on_s(dsa, timeout));
    }
    void powerOff(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_power_off_s(dsa, timeout));
    }
    void newSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_new_setpoint_s(dsa, sidx, flags, timeout));
    }
    void changeSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_change_setpoint_s(dsa, sidx, flags, timeout));
    }
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_quick_stop_s(dsa, mode, flags, timeout));
    }
    void homingStart(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_homing_start_s(dsa, timeout));
    }
    int  getWarningCode(int kind, long timeout = DEF_TIMEOUT) {
        int  code;
        ERRCHK(dsa_get_warning_code_s(dsa, &code, kind, timeout));
        return code;
    }
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_execute_command_s(dsa, cmd, fast, ereport, timeout));
    }
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_execute_command_d_s(dsa, cmd, typ1, par1, fast, ereport, timeout));
    }
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_execute_command_i_s(dsa, cmd, typ1, par1, conv1, fast, ereport, timeout));
    }
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_execute_command_dd_s(dsa, cmd, typ1, par1, typ2, par2, fast, ereport, timeout));
    }
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_execute_command_id_s(dsa, cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout));
    }
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_execute_command_di_s(dsa, cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout));
    }
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_execute_command_ii_s(dsa, cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout));
    }
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_execute_command_x_s(dsa, cmd, *(DSA_COMMAND_PARAM **)&params, count, fast, ereport, timeout));
    }
    long  getRegister(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {
        long  val;
        ERRCHK(dsa_get_register_s(dsa, typ, idx, sidx, &val, kind, timeout));
        return val;
    }
    void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_array_s(dsa, typ, idx, nidx, sidx, val, offset, kind, timeout));
    }
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_register_s(dsa, typ, idx, sidx, val, timeout));
    }
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_array_s(dsa, typ, idx, nidx, sidx, val, offset, timeout));
    }
    double  getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, long timeout = DEF_TIMEOUT) {
        double  val;
        ERRCHK(dsa_get_iso_register_s(dsa, typ, idx, sidx, &val, conv, kind, timeout));
        return val;
    }
    void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_iso_array_s(dsa, typ, idx, nidx, sidx, val, offset, conv, kind, timeout));
    }
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_iso_register_s(dsa, typ, idx, sidx, val, conv, timeout));
    }
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_iso_array_s(dsa, typ, idx, nidx, sidx, val, offset, conv, timeout));
    }
    void ipolBegin(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_begin_s(dsa, timeout));
    }
    void ipolEnd(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_end_s(dsa, timeout));
    }
    void ipolBeginConcatenation(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_begin_concatenation_s(dsa, timeout));
    }
    void ipolEndConcatenation(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_end_concatenation_s(dsa, timeout));
    }
    void ipolLine(DsaVector *dest, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_line_s(dsa, *(DSA_VECTOR **)&dest, timeout));
    }
    void ipolCircleCWR2d(double x, double y, double r, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_circle_cw_r2d_s(dsa, x, y, r, timeout));
    }
    void ipolCircleCcwR2d(double x, double y, double r, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_circle_ccw_r2d_s(dsa, x, y, r, timeout));
    }
    void ipolTanVelocity(double velocity, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_tan_velocity_s(dsa, velocity, timeout));
    }
    void ipolTanAcceleration(double acc, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_tan_acceleration_s(dsa, acc, timeout));
    }
    void ipolTanDeceleration(double dec, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_tan_deceleration_s(dsa, dec, timeout));
    }
    void ipolTanJerkTime(double jerk_time, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_tan_jerk_time_s(dsa, jerk_time, timeout));
    }
    void ipolQuickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_quick_stop_s(dsa, mode, flags, timeout));
    }
    void ipolContinue(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_continue_s(dsa, timeout));
    }
    void ipolReset(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_reset_s(dsa, timeout));
    }
    void ipolPvt(DsaVector *dest, DsaVector *velocity, double time, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_pvt_s(dsa, *(DSA_VECTOR **)&dest, *(DSA_VECTOR **)&velocity, time, timeout));
    }
    void ipolMark(long number, long operation, long op_param, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_mark_s(dsa, number, operation, op_param, timeout));
    }
    void ipolSetVelocityRate(double rate, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_set_velocity_rate_s(dsa, rate, timeout));
    }
    void ipolCircleCWC2d(double x, double y, double cx, double cy, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_circle_cw_c2d_s(dsa, x, y, cx, cy, timeout));
    }
    void ipolCircleCcwC2d(double x, double y, double cx, double cy, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_circle_ccw_c2d_s(dsa, x, y, cx, cy, timeout));
    }
    void ipolLine(double x, double y, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_line_2d_s(dsa, x, y, timeout));
    }
    void ipolWaitMovement(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_wait_movement_s(dsa, timeout));
    }
    void ipolPrepare(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_prepare_s(dsa, timeout));
    }
    void ipolPvtUpdate(int depth, dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_pvt_update_s(dsa, depth, mask, timeout));
    }
    void ipolPvtRegTyp(DsaVector *dest, DsaVectorTyp destTyp, DsaVector *velocity, DsaVectorTyp velocityTyp, double time, int timeTyp, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_pvt_reg_typ_s(dsa, *(DSA_VECTOR **)&dest, *(DSA_VECTOR_TYP*)&destTyp, *(DSA_VECTOR **)&velocity, *(DSA_VECTOR_TYP*)&velocityTyp, time, timeTyp, timeout));
    }
    void ipolSetLktSpeedRatio(double value, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_set_lkt_speed_ratio_s(dsa, value, timeout));
    }
    void ipolSetLktCyclicMode(bool active, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_set_lkt_cyclic_mode_s(dsa, active, timeout));
    }
    void ipolSetLktRelativeMode(bool active, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_set_lkt_relative_mode_s(dsa, active, timeout));
    }
    void ipolLkt(DsaVector *dest, DsaIntVector *lkt_number, double time, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_lkt_s(dsa, *(DSA_VECTOR **)&dest, *(DSA_INT_VECTOR **)&lkt_number, time, timeout));
    }
    void ipolWaitMark(int mark, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_wait_mark_s(dsa, mark, timeout));
    }
    void ipolUline(DsaVector *dest, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_uline_s(dsa, *(DSA_VECTOR **)&dest, timeout));
    }
    void ipolUline(double x, double y, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_uline_2d_s(dsa, x, y, timeout));
    }
    void ipolDisableUconcatenation(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_disable_uconcatenation_s(dsa, timeout));
    }
    void ipolSetUrelativeMode(bool active, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_set_urelative_mode_s(dsa, active, timeout));
    }
    void ipolUspeedAxisMask(dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_uspeed_axis_mask_s(dsa, mask, timeout));
    }
    void ipolUspeed(double speed, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_uspeed_s(dsa, speed, timeout));
    }
    void ipolUtime(double acc_time, double jerk_time, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_utime_s(dsa, acc_time, jerk_time, timeout));
    }
    void ipolTranslateMatrix(DsaVector *trans, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_translate_matrix_s(dsa, *(DSA_VECTOR **)&trans, timeout));
    }
    void ipolScaleMatrix(DsaVector *scale, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_scale_matrix_s(dsa, *(DSA_VECTOR **)&scale, timeout));
    }
    void ipolRotateMatrix(int plan, double degree, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_rotate_matrix_s(dsa, plan, degree, timeout));
    }
    void ipolTranslateMatrix(double x, double y, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_translate_matrix_2d_s(dsa, x, y, timeout));
    }
    void ipolScaleMatrix(double x, double y, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_scale_matrix_2d_s(dsa, x, y, timeout));
    }
    void ipolShearMatrix(int sheared_axis, double axis1_shearing, double axis2_shearing, double axis3_shearing, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_shear_matrix_s(dsa, sheared_axis, axis1_shearing, axis2_shearing, axis3_shearing, timeout));
    }
    void ipolLock(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_lock_s(dsa, timeout));
    }
    void ipolUnlock(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_ipol_unlock_s(dsa, timeout));
    }
    void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_quick_register_request_s(dsa, typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, timeout));
    }
    DsaStatus  waitStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
        DsaStatus  status = dsa_init_status();
        ERRCHK(dsa_wait_status_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, &*(DSA_STATUS *)&status, timeout));
        return status;
    }
    DsaStatus  waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
        DsaStatus  status = dsa_init_status();
        ERRCHK(dsa_wait_status_not_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, &*(DSA_STATUS *)&status, timeout));
        return status;
    }
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_grp_wait_and_status_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, timeout));
    }
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_grp_wait_and_status_not_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, timeout));
    }
    void gantryWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_gantry_wait_and_status_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, timeout));
    }
    void gantryWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_gantry_wait_and_status_not_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, timeout));
    }
    DsaStatus  waitStatusChange(DsaStatus *mask, long timeout = DEF_TIMEOUT) {
        DsaStatus  status = dsa_init_status();
        ERRCHK(dsa_wait_status_change_s(dsa, *(DSA_STATUS **)&mask, &*(DSA_STATUS *)&status, timeout));
        return status;
    }
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_grp_wait_or_status_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, timeout));
    }
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_grp_wait_or_status_not_equal_s(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, timeout));
    }
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_trace_mode_mvt_s(dsa, time, endm, timeout));
    }
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_trace_mode_pos_s(dsa, time, pos, timeout));
    }
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_trace_mode_dev_s(dsa, time, level, timeout));
    }
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_trace_mode_iso_s(dsa, time, level, conv, timeout));
    }
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_trace_mode_immediate_s(dsa, time, timeout));
    }
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_trace_acquisition_s(dsa, typ1, idx1, sidx1, typ2, idx2, sidx2, timeout));
    }
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_sync_trace_enable_s(dsa, enable, timeout));
    }
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_sync_trace_force_trigger_s(dsa, timeout));
    }

    void powerOn(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_power_on_a(dsa, (DSA_HANDLER)handler, param));
    }
    void powerOff(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_power_off_a(dsa, (DSA_HANDLER)handler, param));
    }
    void newSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_new_setpoint_a(dsa, sidx, flags, (DSA_HANDLER)handler, param));
    }
    void changeSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_change_setpoint_a(dsa, sidx, flags, (DSA_HANDLER)handler, param));
    }
    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_quick_stop_a(dsa, mode, flags, (DSA_HANDLER)handler, param));
    }
    void homingStart(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_homing_start_a(dsa, (DSA_HANDLER)handler, param));
    }
    void getWarningCode(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_warning_code_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_execute_command_a(dsa, cmd, fast, ereport, (DSA_HANDLER)handler, param));
    }
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_execute_command_d_a(dsa, cmd, typ1, par1, fast, ereport, (DSA_HANDLER)handler, param));
    }
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_execute_command_i_a(dsa, cmd, typ1, par1, conv1, fast, ereport, (DSA_HANDLER)handler, param));
    }
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_execute_command_dd_a(dsa, cmd, typ1, par1, typ2, par2, fast, ereport, (DSA_HANDLER)handler, param));
    }
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_execute_command_id_a(dsa, cmd, typ1, par1, conv1, typ2, par2, fast, ereport, (DSA_HANDLER)handler, param));
    }
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_execute_command_di_a(dsa, cmd, typ1, par1, typ2, par2, conv2, fast, ereport, (DSA_HANDLER)handler, param));
    }
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_execute_command_ii_a(dsa, cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, (DSA_HANDLER)handler, param));
    }
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_execute_command_x_a(dsa, cmd, *(DSA_COMMAND_PARAM **)&params, count, fast, ereport, (DSA_HANDLER)handler, param));
    }
    void getRegister(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_register_a(dsa, typ, idx, sidx, kind, (DSA_LONG_HANDLER)handler, param));
    }
    void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_array_a(dsa, typ, idx, nidx, sidx, val, offset, kind, (DSA_HANDLER)handler, param));
    }
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_register_a(dsa, typ, idx, sidx, val, (DSA_HANDLER)handler, param));
    }
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_array_a(dsa, typ, idx, nidx, sidx, val, offset, (DSA_HANDLER)handler, param));
    }
    void getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_iso_register_a(dsa, typ, idx, sidx, conv, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_iso_array_a(dsa, typ, idx, nidx, sidx, val, offset, conv, kind, (DSA_HANDLER)handler, param));
    }
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_iso_register_a(dsa, typ, idx, sidx, val, conv, (DSA_HANDLER)handler, param));
    }
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_iso_array_a(dsa, typ, idx, nidx, sidx, val, offset, conv, (DSA_HANDLER)handler, param));
    }
    void ipolBegin(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_begin_a(dsa, (DSA_HANDLER)handler, param));
    }
    void ipolEnd(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_end_a(dsa, (DSA_HANDLER)handler, param));
    }
    void ipolBeginConcatenation(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_begin_concatenation_a(dsa, (DSA_HANDLER)handler, param));
    }
    void ipolEndConcatenation(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_end_concatenation_a(dsa, (DSA_HANDLER)handler, param));
    }
    void ipolLine(DsaVector *dest, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_line_a(dsa, *(DSA_VECTOR **)&dest, (DSA_HANDLER)handler, param));
    }
    void ipolCircleCWR2d(double x, double y, double r, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_circle_cw_r2d_a(dsa, x, y, r, (DSA_HANDLER)handler, param));
    }
    void ipolCircleCcwR2d(double x, double y, double r, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_circle_ccw_r2d_a(dsa, x, y, r, (DSA_HANDLER)handler, param));
    }
    void ipolTanVelocity(double velocity, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_tan_velocity_a(dsa, velocity, (DSA_HANDLER)handler, param));
    }
    void ipolTanAcceleration(double acc, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_tan_acceleration_a(dsa, acc, (DSA_HANDLER)handler, param));
    }
    void ipolTanDeceleration(double dec, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_tan_deceleration_a(dsa, dec, (DSA_HANDLER)handler, param));
    }
    void ipolTanJerkTime(double jerk_time, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_tan_jerk_time_a(dsa, jerk_time, (DSA_HANDLER)handler, param));
    }
    void ipolQuickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_quick_stop_a(dsa, mode, flags, (DSA_HANDLER)handler, param));
    }
    void ipolContinue(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_continue_a(dsa, (DSA_HANDLER)handler, param));
    }
    void ipolReset(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_reset_a(dsa, (DSA_HANDLER)handler, param));
    }
    void ipolPvt(DsaVector *dest, DsaVector *velocity, double time, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_pvt_a(dsa, *(DSA_VECTOR **)&dest, *(DSA_VECTOR **)&velocity, time, (DSA_HANDLER)handler, param));
    }
    void ipolMark(long number, long operation, long op_param, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_mark_a(dsa, number, operation, op_param, (DSA_HANDLER)handler, param));
    }
    void ipolSetVelocityRate(double rate, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_set_velocity_rate_a(dsa, rate, (DSA_HANDLER)handler, param));
    }
    void ipolCircleCWC2d(double x, double y, double cx, double cy, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_circle_cw_c2d_a(dsa, x, y, cx, cy, (DSA_HANDLER)handler, param));
    }
    void ipolCircleCcwC2d(double x, double y, double cx, double cy, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_circle_ccw_c2d_a(dsa, x, y, cx, cy, (DSA_HANDLER)handler, param));
    }
    void ipolLine(double x, double y, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_line_2d_a(dsa, x, y, (DSA_HANDLER)handler, param));
    }
    void ipolWaitMovement(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_wait_movement_a(dsa, (DSA_HANDLER)handler, param));
    }
    void ipolPrepare(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_prepare_a(dsa, (DSA_HANDLER)handler, param));
    }
    void ipolPvtUpdate(int depth, dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_pvt_update_a(dsa, depth, mask, (DSA_HANDLER)handler, param));
    }
    void ipolPvtRegTyp(DsaVector *dest, DsaVectorTyp destTyp, DsaVector *velocity, DsaVectorTyp velocityTyp, double time, int timeTyp, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_pvt_reg_typ_a(dsa, *(DSA_VECTOR **)&dest, *(DSA_VECTOR_TYP*)&destTyp, *(DSA_VECTOR **)&velocity, *(DSA_VECTOR_TYP*)&velocityTyp, time, timeTyp, (DSA_HANDLER)handler, param));
    }
    void ipolSetLktSpeedRatio(double value, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_set_lkt_speed_ratio_a(dsa, value, (DSA_HANDLER)handler, param));
    }
    void ipolSetLktCyclicMode(bool active, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_set_lkt_cyclic_mode_a(dsa, active, (DSA_HANDLER)handler, param));
    }
    void ipolSetLktRelativeMode(bool active, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_set_lkt_relative_mode_a(dsa, active, (DSA_HANDLER)handler, param));
    }
    void ipolLkt(DsaVector *dest, DsaIntVector *lkt_number, double time, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_lkt_a(dsa, *(DSA_VECTOR **)&dest, *(DSA_INT_VECTOR **)&lkt_number, time, (DSA_HANDLER)handler, param));
    }
    void ipolWaitMark(int mark, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_wait_mark_a(dsa, mark, (DSA_HANDLER)handler, param));
    }
    void ipolUline(DsaVector *dest, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_uline_a(dsa, *(DSA_VECTOR **)&dest, (DSA_HANDLER)handler, param));
    }
    void ipolUline(double x, double y, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_uline_2d_a(dsa, x, y, (DSA_HANDLER)handler, param));
    }
    void ipolDisableUconcatenation(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_disable_uconcatenation_a(dsa, (DSA_HANDLER)handler, param));
    }
    void ipolSetUrelativeMode(bool active, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_set_urelative_mode_a(dsa, active, (DSA_HANDLER)handler, param));
    }
    void ipolUspeedAxisMask(dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_uspeed_axis_mask_a(dsa, mask, (DSA_HANDLER)handler, param));
    }
    void ipolUspeed(double speed, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_uspeed_a(dsa, speed, (DSA_HANDLER)handler, param));
    }
    void ipolUtime(double acc_time, double jerk_time, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_utime_a(dsa, acc_time, jerk_time, (DSA_HANDLER)handler, param));
    }
    void ipolTranslateMatrix(DsaVector *trans, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_translate_matrix_a(dsa, *(DSA_VECTOR **)&trans, (DSA_HANDLER)handler, param));
    }
    void ipolScaleMatrix(DsaVector *scale, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_scale_matrix_a(dsa, *(DSA_VECTOR **)&scale, (DSA_HANDLER)handler, param));
    }
    void ipolRotateMatrix(int plan, double degree, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_rotate_matrix_a(dsa, plan, degree, (DSA_HANDLER)handler, param));
    }
    void ipolTranslateMatrix(double x, double y, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_translate_matrix_2d_a(dsa, x, y, (DSA_HANDLER)handler, param));
    }
    void ipolScaleMatrix(double x, double y, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_scale_matrix_2d_a(dsa, x, y, (DSA_HANDLER)handler, param));
    }
    void ipolShearMatrix(int sheared_axis, double axis1_shearing, double axis2_shearing, double axis3_shearing, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_shear_matrix_a(dsa, sheared_axis, axis1_shearing, axis2_shearing, axis3_shearing, (DSA_HANDLER)handler, param));
    }
    void ipolLock(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_lock_a(dsa, (DSA_HANDLER)handler, param));
    }
    void ipolUnlock(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_ipol_unlock_a(dsa, (DSA_HANDLER)handler, param));
    }
    void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, Dsa2intHandler handler, void *param = NULL) {
        ERRCHK(dsa_quick_register_request_a(dsa, typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, (DSA_2INT_HANDLER)handler, param));
    }
    void waitStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {
        ERRCHK(dsa_wait_status_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_STATUS_HANDLER)handler, param));
    }
    void waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {
        ERRCHK(dsa_wait_status_not_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_STATUS_HANDLER)handler, param));
    }
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_grp_wait_and_status_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_HANDLER)handler, param));
    }
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_grp_wait_and_status_not_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_HANDLER)handler, param));
    }
    void gantryWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_gantry_wait_and_status_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_HANDLER)handler, param));
    }
    void gantryWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_gantry_wait_and_status_not_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_HANDLER)handler, param));
    }
    void waitStatusChange(DsaStatus *mask, DsaStatusHandler handler, void *param = NULL) {
        ERRCHK(dsa_wait_status_change_a(dsa, *(DSA_STATUS **)&mask, (DSA_STATUS_HANDLER)handler, param));
    }
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_grp_wait_or_status_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_HANDLER)handler, param));
    }
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_grp_wait_or_status_not_equal_a(dsa, *(DSA_STATUS **)&mask, *(DSA_STATUS **)&ref, (DSA_HANDLER)handler, param));
    }
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_trace_mode_mvt_a(dsa, time, endm, (DSA_HANDLER)handler, param));
    }
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_trace_mode_pos_a(dsa, time, pos, (DSA_HANDLER)handler, param));
    }
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_trace_mode_dev_a(dsa, time, level, (DSA_HANDLER)handler, param));
    }
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_trace_mode_iso_a(dsa, time, level, conv, (DSA_HANDLER)handler, param));
    }
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_trace_mode_immediate_a(dsa, time, (DSA_HANDLER)handler, param));
    }
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_trace_acquisition_a(dsa, typ1, idx1, sidx1, typ2, idx2, sidx2, (DSA_HANDLER)handler, param));
    }
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_sync_trace_enable_a(dsa, enable, (DSA_HANDLER)handler, param));
    }
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_sync_trace_force_trigger_a(dsa, (DSA_HANDLER)handler, param));
    }

    void open(EtbBus etb, int axis) {
        ERRCHK(dsa_open_e(dsa, *(ETB **)&etb, axis));
    }
    void open(char_cp url) {
        ERRCHK(dsa_open_u(dsa, url));
    }
    void open(EtbBus etb, int axis, dword flags) {
        ERRCHK(dsa_open_ef(dsa, *(ETB **)&etb, axis, flags));
    }
    void reset() {
        ERRCHK(dsa_reset(dsa));
    }
    void close() {
        ERRCHK(dsa_close(dsa));
    }
    EtbBus  getEtbBus() {
        EtbBus  etb;
        ERRCHK(dsa_get_etb_bus(dsa, &*(ETB **)&etb));
        return etb;
    }
    int  getEtbAxis() {
        int  axis;
        ERRCHK(dsa_get_etb_axis(dsa, &axis));
        return axis;
    }
    bool  isOpen() {
        bool  is_open;
        ERRCHK(dsa_is_open(dsa, &is_open));
        return is_open;
    }
    int getMotorTyp() {
        return dsa_get_motor_typ(dsa);
    }
    static char_cp translateError(int code) {
        return dsa_translate_error(code);
    }
    static void setPrio(int prio) {
        ERRCHK(dsa_set_prio(prio));
    }
    void getErrorText(char_p text, int size, int code) {
        ERRCHK(dsa_get_error_text(dsa, text, size, code));
    }
    void getWarningText(char_p text, int size, int code) {
        ERRCHK(dsa_get_warning_text(dsa, text, size, code));
    }
    static char_cp translateEdiError(int code) {
        return dsa_translate_edi_error(code);
    }
    double  convertToIso(long inc, int conv) {
        double  iso;
        ERRCHK(dsa_convert_to_iso(dsa, &iso, inc, conv));
        return iso;
    }
    long  convertFromIso(double iso, int conv) {
        long  inc;
        ERRCHK(dsa_convert_from_iso(dsa, &inc, iso, conv));
        return inc;
    }
    void getRtmMon(DsaRTM *rtm) {
        ERRCHK(dsa_get_rtm_mon(dsa, *(DSA_RTM **)&rtm));
    }
    void initRtmFct() {
        ERRCHK(dsa_init_rtm_fct(dsa));
    }
    void startRtm(DsaTrajectoryHandler fct) {
        ERRCHK(dsa_start_rtm(dsa, *(DSA_TRAJECTORY_HANDLER*)&fct));
    }
    void stopRtm() {
        ERRCHK(dsa_stop_rtm(dsa));
    }
    void diag(char_cp file_name, int line, int err) {
        ERRCHK(dsa_diag(file_name, line, err, dsa));
    }
    void sdiag(char_p str, char_cp file_name, int line, int err) {
        ERRCHK(dsa_sdiag(str, file_name, line, err, dsa));
    }
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {
        ERRCHK(dsa_fdiag(output_file_name, file_name, line, err, dsa));
    }
    int  getGroupSize() {
        int  size;
        ERRCHK(dsa_get_group_size(dsa, &size));
        return size;
    }
    int  gantryGetErrorCode(int *axis, int kind) {
        int  code;
        ERRCHK(dsa_gantry_get_error_code(dsa, &code, axis, kind));
        return code;
    }
    DsaInfo  getInfo() {
        DsaInfo  info = dsa_init_info();
        ERRCHK(dsa_get_info(dsa, &*(DSA_INFO *)&info));
        return info;
    }
    bool isIpolINProgress() {
        return dsa_is_ipol_in_progress(dsa);
    }
    DsaStatus  getStatus() {
        DsaStatus  status = dsa_init_status();
        ERRCHK(dsa_get_status(dsa, &*(DSA_STATUS *)&status));
        return status;
    }
    void cancelStatusWait() {
        ERRCHK(dsa_cancel_status_wait(dsa));
    }
    void gantryCancelStatusWait() {
        ERRCHK(dsa_gantry_cancel_status_wait(dsa));
    }
    DsaStatus  gantryGetAndStatus() {
        DsaStatus  status = dsa_init_status();
        ERRCHK(dsa_gantry_get_and_status(dsa, &*(DSA_STATUS *)&status));
        return status;
    }
    DsaStatus  gantryGetORStatus() {
        DsaStatus  status = dsa_init_status();
        ERRCHK(dsa_gantry_get_or_status(dsa, &*(DSA_STATUS *)&status));
        return status;
    }
    DsaStatus  getStatusFromDrive(long timeout = DEF_TIMEOUT) {
        DsaStatus  status = dsa_init_status();
        ERRCHK(dsa_get_status_from_drive(dsa, &*(DSA_STATUS *)&status, timeout));
        return status;
    }
    void grpCancelStatusWait() {
        ERRCHK(dsa_grp_cancel_status_wait(dsa));
    }
    double  queryMinimumSampleTime() {
        double  time;
        ERRCHK(dsa_query_minimum_sample_time(dsa, &time));
        return time;
    }
    double  querySampleTime(double time) {
        double  real_time;
        ERRCHK(dsa_query_sample_time(dsa, time, &real_time));
        return real_time;
    }
    DsaXInfo  getXInfo() {
        DsaXInfo  x_info = dsa_init_x_info();
        ERRCHK(dsa_get_x_info(dsa, &*(DSA_X_INFO *)&x_info));
        return x_info;
    }


	/*
	 * commands - synchronous
	 */
protected:
    void resetError(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_reset_error_s(dsa, timeout));
    }
    void stepMotion(double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_step_motion_s(dsa, pos, timeout));
    }
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_execute_sequence_s(dsa, label, timeout));
    }
    void editSequence(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_edit_sequence_s(dsa, timeout));
    }
    void exitSequence(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_exit_sequence_s(dsa, timeout));
    }
    void canCommand1(dword val1, dword val2, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_can_command_1_s(dsa, val1, val2, timeout));
    }
    void canCommand2(dword val1, dword val2, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_can_command_2_s(dsa, val1, val2, timeout));
    }
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_save_parameters_s(dsa, what, timeout));
    }
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_load_parameters_s(dsa, what, timeout));
    }
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_default_parameters_s(dsa, what, timeout));
    }
    void waitMovement(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_wait_movement_s(dsa, timeout));
    }
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_wait_position_s(dsa, pos, timeout));
    }
    void waitTime(double time, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_wait_time_s(dsa, time, timeout));
    }
    void waitWindow(long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_wait_window_s(dsa, timeout));
    }


	/*
	 * commands - asynchronous
	 */
protected:
    void resetError(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_reset_error_a(dsa, (DSA_HANDLER)handler, param));
    }
    void stepMotion(double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_step_motion_a(dsa, pos, (DSA_HANDLER)handler, param));
    }
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_execute_sequence_a(dsa, label, (DSA_HANDLER)handler, param));
    }
    void editSequence(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_edit_sequence_a(dsa, (DSA_HANDLER)handler, param));
    }
    void exitSequence(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_exit_sequence_a(dsa, (DSA_HANDLER)handler, param));
    }
    void canCommand1(dword val1, dword val2, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_can_command_1_a(dsa, val1, val2, (DSA_HANDLER)handler, param));
    }
    void canCommand2(dword val1, dword val2, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_can_command_2_a(dsa, val1, val2, (DSA_HANDLER)handler, param));
    }
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_save_parameters_a(dsa, what, (DSA_HANDLER)handler, param));
    }
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_load_parameters_a(dsa, what, (DSA_HANDLER)handler, param));
    }
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_default_parameters_a(dsa, what, (DSA_HANDLER)handler, param));
    }
    void waitMovement(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_wait_movement_a(dsa, (DSA_HANDLER)handler, param));
    }
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_wait_position_a(dsa, pos, (DSA_HANDLER)handler, param));
    }
    void waitTime(double time, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_wait_time_a(dsa, time, (DSA_HANDLER)handler, param));
    }
    void waitWindow(DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_wait_window_a(dsa, (DSA_HANDLER)handler, param));
    }


    /*
     * register setter - synchronous
     */
protected:
    void setPLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pl_proportional_gain_s(dsa, gain, timeout));
    }
    void setPLSpeedFeedbackGain(double gain, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pl_speed_feedback_gain_s(dsa, gain, timeout));
    }
    void setPLForceFeedbackGain1(double gain, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pl_force_feedback_gain_1_s(dsa, gain, timeout));
    }
    void setPLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pl_integrator_gain_s(dsa, gain, timeout));
    }
    void setPLAntiWindupGain(double gain, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pl_anti_windup_gain_s(dsa, gain, timeout));
    }
    void setPLIntegratorLimitation(double limit, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pl_integrator_limitation_s(dsa, limit, timeout));
    }
    void setPLIntegratorMode(int mode, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pl_integrator_mode_s(dsa, mode, timeout));
    }
    void setPLSpeedFilter(double tim, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pl_speed_filter_s(dsa, tim, timeout));
    }
    void setPLOutputFilter(double tim, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pl_output_filter_s(dsa, tim, timeout));
    }
    void setCLInputFilter(double tim, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_cl_input_filter_s(dsa, tim, timeout));
    }
    void setTtlSpecialFilter(double factor, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_ttl_special_filter_s(dsa, factor, timeout));
    }
    void setPLForceFeedbackGain2(double factor, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pl_force_feedback_gain_2_s(dsa, factor, timeout));
    }
    void setPLSpeedFeedfwdGain(double factor, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pl_speed_feedfwd_gain_s(dsa, factor, timeout));
    }
    void setPLAccFeedforwardGain(double factor, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pl_acc_feedforward_gain_s(dsa, factor, timeout));
    }
    void setCLPhaseAdvanceFactor(double factor, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_cl_phase_advance_factor_s(dsa, factor, timeout));
    }
    void setAprInputFilter(double time, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_apr_input_filter_s(dsa, time, timeout));
    }
    void setCLPhaseAdvanceShift(double shift, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_cl_phase_advance_shift_s(dsa, shift, timeout));
    }
    void setMinPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_min_position_range_limit_s(dsa, pos, timeout));
    }
    void setMaxPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_max_position_range_limit_s(dsa, pos, timeout));
    }
    void setMaxProfileVelocity(double vel, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_max_profile_velocity_s(dsa, vel, timeout));
    }
    void setMaxAcceleration(double acc, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_max_acceleration_s(dsa, acc, timeout));
    }
    void setFollowingErrorWindow(double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_following_error_window_s(dsa, pos, timeout));
    }
    void setVelocityErrorLimit(double vel, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_velocity_error_limit_s(dsa, vel, timeout));
    }
    void setSwitchLimitMode(int mode, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_switch_limit_mode_s(dsa, mode, timeout));
    }
    void setEnableInputMode(int mode, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_enable_input_mode_s(dsa, mode, timeout));
    }
    void setMinSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_min_soft_position_limit_s(dsa, pos, timeout));
    }
    void setMaxSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_max_soft_position_limit_s(dsa, pos, timeout));
    }
    void setProfileLimitMode(dword flags, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_profile_limit_mode_s(dsa, flags, timeout));
    }
    void setIOErrorEventMask(dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_io_error_event_mask_s(dsa, mask, timeout));
    }
    void setPositionWindowTime(double tim, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_position_window_time_s(dsa, tim, timeout));
    }
    void setPositionWindow(double win, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_position_window_s(dsa, win, timeout));
    }
    void setHomingMethod(int mode, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_homing_method_s(dsa, mode, timeout));
    }
    void setHomingZeroSpeed(double vel, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_homing_zero_speed_s(dsa, vel, timeout));
    }
    void setHomingAcceleration(double acc, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_homing_acceleration_s(dsa, acc, timeout));
    }
    void setHomingFollowingLimit(double win, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_homing_following_limit_s(dsa, win, timeout));
    }
    void setHomingCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_homing_current_limit_s(dsa, cur, timeout));
    }
    void setHomeOffset(double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_home_offset_s(dsa, pos, timeout));
    }
    void setHomingFixedMvt(double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_homing_fixed_mvt_s(dsa, pos, timeout));
    }
    void setHomingSwitchMvt(double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_homing_switch_mvt_s(dsa, pos, timeout));
    }
    void setHomingIndexMvt(double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_homing_index_mvt_s(dsa, pos, timeout));
    }
    void setHomingFineTuningMode(int mode, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_homing_fine_tuning_mode_s(dsa, mode, timeout));
    }
    void setHomingFineTuningValue(double phase, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_homing_fine_tuning_value_s(dsa, phase, timeout));
    }
    void setMotorPhaseCorrection(int mode, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_motor_phase_correction_s(dsa, mode, timeout));
    }
    void setSoftwareCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_software_current_limit_s(dsa, cur, timeout));
    }
    void setDriveControlMode(int mode, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_drive_control_mode_s(dsa, mode, timeout));
    }
    void setDisplayMode(int mode, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_display_mode_s(dsa, mode, timeout));
    }
    void setEncoderInversion(double invert, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_encoder_inversion_s(dsa, invert, timeout));
    }
    void setPdrStepValue(double step, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_pdr_step_value_s(dsa, step, timeout));
    }
    void setEncoderPhase1Offset(double offset, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_encoder_phase_1_offset_s(dsa, offset, timeout));
    }
    void setEncoderPhase2Offset(double offset, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_encoder_phase_2_offset_s(dsa, offset, timeout));
    }
    void setEncoderPhase1Factor(double factor, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_encoder_phase_1_factor_s(dsa, factor, timeout));
    }
    void setEncoderPhase2Factor(double factor, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_encoder_phase_2_factor_s(dsa, factor, timeout));
    }
    void setEncoderPhase3Offset(double offset, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_encoder_phase_3_offset_s(dsa, offset, timeout));
    }
    void setEncoderIndexDistance(double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_encoder_index_distance_s(dsa, pos, timeout));
    }
    void setEncoderPhase3Factor(double factor, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_encoder_phase_3_factor_s(dsa, factor, timeout));
    }
    void setCLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_cl_proportional_gain_s(dsa, gain, timeout));
    }
    void setCLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_cl_integrator_gain_s(dsa, gain, timeout));
    }
    void setCLOutputFilter(double tim, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_cl_output_filter_s(dsa, tim, timeout));
    }
    void setCLCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_cl_current_limit_s(dsa, cur, timeout));
    }
    void setCLI2tCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_cl_i2t_current_limit_s(dsa, cur, timeout));
    }
    void setCLI2tTimeLimit(double tim, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_cl_i2t_time_limit_s(dsa, tim, timeout));
    }
    void setCLRegenMode(int mode, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_cl_regen_mode_s(dsa, mode, timeout));
    }
    void setInitMode(int typ, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_init_mode_s(dsa, typ, timeout));
    }
    void setInitPulseLevel(double cur, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_init_pulse_level_s(dsa, cur, timeout));
    }
    void setInitMaxCurrent(double cur, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_init_max_current_s(dsa, cur, timeout));
    }
    void setInitFinalPhase(double cal, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_init_final_phase_s(dsa, cal, timeout));
    }
    void setInitTime(double tim, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_init_time_s(dsa, tim, timeout));
    }
    void setInitCurrentRate(double cur, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_init_current_rate_s(dsa, cur, timeout));
    }
    void setInitPhaseRate(double cal, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_init_phase_rate_s(dsa, cal, timeout));
    }
    void setInitInitialPhase(double cal, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_init_initial_phase_s(dsa, cal, timeout));
    }
    void setDriveFuseChecking(dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_drive_fuse_checking_s(dsa, mask, timeout));
    }
    void setMotorTempChecking(dword val, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_motor_temp_checking_s(dsa, val, timeout));
    }
    void setMonSourceType(int sidx, int typ, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_mon_source_type_s(dsa, sidx, typ, timeout));
    }
    void setMonSourceIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_mon_source_index_s(dsa, sidx, index, timeout));
    }
    void setMonDestIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_mon_dest_index_s(dsa, sidx, index, timeout));
    }
    void setMonOffset(int sidx, long offset, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_mon_offset_s(dsa, sidx, offset, timeout));
    }
    void setMonGain(int sidx, double gain, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_mon_gain_s(dsa, sidx, gain, timeout));
    }
    void setXAnalogOffset(int sidx, double offset, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_x_analog_offset_s(dsa, sidx, offset, timeout));
    }
    void setXAnalogGain(int sidx, double gain, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_x_analog_gain_s(dsa, sidx, gain, timeout));
    }
    void setSyncroInputMask(dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_syncro_input_mask_s(dsa, mask, timeout));
    }
    void setSyncroInputValue(dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_syncro_input_value_s(dsa, mask, timeout));
    }
    void setSyncroOutputMask(double mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_syncro_output_mask_s(dsa, mask, timeout));
    }
    void setSyncroOutputValue(double mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_syncro_output_value_s(dsa, mask, timeout));
    }
    void setSyncroStartTimeout(int tim, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_syncro_start_timeout_s(dsa, tim, timeout));
    }
    void setDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_digital_output_s(dsa, out, timeout));
    }
    void setXDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_x_digital_output_s(dsa, out, timeout));
    }
    void setXAnalogOutput1(double out, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_x_analog_output_1_s(dsa, out, timeout));
    }
    void setXAnalogOutput2(double out, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_x_analog_output_2_s(dsa, out, timeout));
    }
    void setAnalogOutput(double out, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_analog_output_s(dsa, out, timeout));
    }
    void setInterruptMask1(int sidx, dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_interrupt_mask_1_s(dsa, sidx, mask, timeout));
    }
    void setInterruptMask2(int sidx, dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_interrupt_mask_2_s(dsa, sidx, mask, timeout));
    }
    void setTriggerIrqMask(dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_trigger_irq_mask_s(dsa, mask, timeout));
    }
    void setTriggerIOMask(dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_trigger_io_mask_s(dsa, mask, timeout));
    }
    void setTriggerMapOffset(int offset, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_trigger_map_offset_s(dsa, offset, timeout));
    }
    void setTriggerMapSize(int size, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_trigger_map_size_s(dsa, size, timeout));
    }
    void setRealtimeEnabledGlobal(int enable, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_realtime_enabled_global_s(dsa, enable, timeout));
    }
    void setRealtimeValidMask(dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_realtime_valid_mask_s(dsa, mask, timeout));
    }
    void setRealtimeEnabledMask(dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_realtime_enabled_mask_s(dsa, mask, timeout));
    }
    void setRealtimePendingMask(dword mask, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_realtime_pending_mask_s(dsa, mask, timeout));
    }
    void setEblBaudrate(long baud, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_ebl_baudrate_s(dsa, baud, timeout));
    }
    void setIndirectAxisNumber(int axis, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_indirect_axis_number_s(dsa, axis, timeout));
    }
    void setIndirectRegisterIdx(int idx, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_indirect_register_idx_s(dsa, idx, timeout));
    }
    void setIndirectRegisterSidx(int sidx, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_indirect_register_sidx_s(dsa, sidx, timeout));
    }
    void setConcatenatedMvt(int concat, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_concatenated_mvt_s(dsa, concat, timeout));
    }
    void setProfileType(int sidx, int typ, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_profile_type_s(dsa, sidx, typ, timeout));
    }
    void setMvtLktNumber(int sidx, int number, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_mvt_lkt_number_s(dsa, sidx, number, timeout));
    }
    void setMvtLktTime(int sidx, double time, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_mvt_lkt_time_s(dsa, sidx, time, timeout));
    }
    void setCameValue(double factor, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_came_value_s(dsa, factor, timeout));
    }
    void setBrakeDeceleration(double dec, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_brake_deceleration_s(dsa, dec, timeout));
    }
    void setTargetPosition(int sidx, double pos, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_target_position_s(dsa, sidx, pos, timeout));
    }
    void setProfileVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_profile_velocity_s(dsa, sidx, vel, timeout));
    }
    void setProfileAcceleration(int sidx, double acc, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_profile_acceleration_s(dsa, sidx, acc, timeout));
    }
    void setJerkTime(int sidx, double tim, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_jerk_time_s(dsa, sidx, tim, timeout));
    }
    void setProfileDeceleration(int sidx, double dec, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_profile_deceleration_s(dsa, sidx, dec, timeout));
    }
    void setEndVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_end_velocity_s(dsa, sidx, vel, timeout));
    }
    void setCtrlSourceType(int typ, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_ctrl_source_type_s(dsa, typ, timeout));
    }
    void setCtrlSourceIndex(int index, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_ctrl_source_index_s(dsa, index, timeout));
    }
    void setCtrlShiftFactor(int shift, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_ctrl_shift_factor_s(dsa, shift, timeout));
    }
    void setCtrlOffset(long offset, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_ctrl_offset_s(dsa, offset, timeout));
    }
    void setCtrlGain(double gain, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_ctrl_gain_s(dsa, gain, timeout));
    }
    void setMotorKTFactor(double kt, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_set_motor_kt_factor_s(dsa, kt, timeout));
    }


    /*
     * register setter - asynchronous
     */
protected:
    void setPLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pl_proportional_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
    }
    void setPLSpeedFeedbackGain(double gain, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pl_speed_feedback_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
    }
    void setPLForceFeedbackGain1(double gain, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pl_force_feedback_gain_1_a(dsa, gain, (DSA_HANDLER)handler, param));
    }
    void setPLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pl_integrator_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
    }
    void setPLAntiWindupGain(double gain, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pl_anti_windup_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
    }
    void setPLIntegratorLimitation(double limit, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pl_integrator_limitation_a(dsa, limit, (DSA_HANDLER)handler, param));
    }
    void setPLIntegratorMode(int mode, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pl_integrator_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
    }
    void setPLSpeedFilter(double tim, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pl_speed_filter_a(dsa, tim, (DSA_HANDLER)handler, param));
    }
    void setPLOutputFilter(double tim, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pl_output_filter_a(dsa, tim, (DSA_HANDLER)handler, param));
    }
    void setCLInputFilter(double tim, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_cl_input_filter_a(dsa, tim, (DSA_HANDLER)handler, param));
    }
    void setTtlSpecialFilter(double factor, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_ttl_special_filter_a(dsa, factor, (DSA_HANDLER)handler, param));
    }
    void setPLForceFeedbackGain2(double factor, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pl_force_feedback_gain_2_a(dsa, factor, (DSA_HANDLER)handler, param));
    }
    void setPLSpeedFeedfwdGain(double factor, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pl_speed_feedfwd_gain_a(dsa, factor, (DSA_HANDLER)handler, param));
    }
    void setPLAccFeedforwardGain(double factor, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pl_acc_feedforward_gain_a(dsa, factor, (DSA_HANDLER)handler, param));
    }
    void setCLPhaseAdvanceFactor(double factor, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_cl_phase_advance_factor_a(dsa, factor, (DSA_HANDLER)handler, param));
    }
    void setAprInputFilter(double time, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_apr_input_filter_a(dsa, time, (DSA_HANDLER)handler, param));
    }
    void setCLPhaseAdvanceShift(double shift, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_cl_phase_advance_shift_a(dsa, shift, (DSA_HANDLER)handler, param));
    }
    void setMinPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_min_position_range_limit_a(dsa, pos, (DSA_HANDLER)handler, param));
    }
    void setMaxPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_max_position_range_limit_a(dsa, pos, (DSA_HANDLER)handler, param));
    }
    void setMaxProfileVelocity(double vel, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_max_profile_velocity_a(dsa, vel, (DSA_HANDLER)handler, param));
    }
    void setMaxAcceleration(double acc, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_max_acceleration_a(dsa, acc, (DSA_HANDLER)handler, param));
    }
    void setFollowingErrorWindow(double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_following_error_window_a(dsa, pos, (DSA_HANDLER)handler, param));
    }
    void setVelocityErrorLimit(double vel, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_velocity_error_limit_a(dsa, vel, (DSA_HANDLER)handler, param));
    }
    void setSwitchLimitMode(int mode, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_switch_limit_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
    }
    void setEnableInputMode(int mode, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_enable_input_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
    }
    void setMinSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_min_soft_position_limit_a(dsa, pos, (DSA_HANDLER)handler, param));
    }
    void setMaxSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_max_soft_position_limit_a(dsa, pos, (DSA_HANDLER)handler, param));
    }
    void setProfileLimitMode(dword flags, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_profile_limit_mode_a(dsa, flags, (DSA_HANDLER)handler, param));
    }
    void setIOErrorEventMask(dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_io_error_event_mask_a(dsa, mask, (DSA_HANDLER)handler, param));
    }
    void setPositionWindowTime(double tim, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_position_window_time_a(dsa, tim, (DSA_HANDLER)handler, param));
    }
    void setPositionWindow(double win, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_position_window_a(dsa, win, (DSA_HANDLER)handler, param));
    }
    void setHomingMethod(int mode, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_homing_method_a(dsa, mode, (DSA_HANDLER)handler, param));
    }
    void setHomingZeroSpeed(double vel, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_homing_zero_speed_a(dsa, vel, (DSA_HANDLER)handler, param));
    }
    void setHomingAcceleration(double acc, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_homing_acceleration_a(dsa, acc, (DSA_HANDLER)handler, param));
    }
    void setHomingFollowingLimit(double win, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_homing_following_limit_a(dsa, win, (DSA_HANDLER)handler, param));
    }
    void setHomingCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_homing_current_limit_a(dsa, cur, (DSA_HANDLER)handler, param));
    }
    void setHomeOffset(double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_home_offset_a(dsa, pos, (DSA_HANDLER)handler, param));
    }
    void setHomingFixedMvt(double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_homing_fixed_mvt_a(dsa, pos, (DSA_HANDLER)handler, param));
    }
    void setHomingSwitchMvt(double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_homing_switch_mvt_a(dsa, pos, (DSA_HANDLER)handler, param));
    }
    void setHomingIndexMvt(double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_homing_index_mvt_a(dsa, pos, (DSA_HANDLER)handler, param));
    }
    void setHomingFineTuningMode(int mode, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_homing_fine_tuning_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
    }
    void setHomingFineTuningValue(double phase, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_homing_fine_tuning_value_a(dsa, phase, (DSA_HANDLER)handler, param));
    }
    void setMotorPhaseCorrection(int mode, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_motor_phase_correction_a(dsa, mode, (DSA_HANDLER)handler, param));
    }
    void setSoftwareCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_software_current_limit_a(dsa, cur, (DSA_HANDLER)handler, param));
    }
    void setDriveControlMode(int mode, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_drive_control_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
    }
    void setDisplayMode(int mode, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_display_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
    }
    void setEncoderInversion(double invert, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_encoder_inversion_a(dsa, invert, (DSA_HANDLER)handler, param));
    }
    void setPdrStepValue(double step, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_pdr_step_value_a(dsa, step, (DSA_HANDLER)handler, param));
    }
    void setEncoderPhase1Offset(double offset, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_encoder_phase_1_offset_a(dsa, offset, (DSA_HANDLER)handler, param));
    }
    void setEncoderPhase2Offset(double offset, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_encoder_phase_2_offset_a(dsa, offset, (DSA_HANDLER)handler, param));
    }
    void setEncoderPhase1Factor(double factor, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_encoder_phase_1_factor_a(dsa, factor, (DSA_HANDLER)handler, param));
    }
    void setEncoderPhase2Factor(double factor, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_encoder_phase_2_factor_a(dsa, factor, (DSA_HANDLER)handler, param));
    }
    void setEncoderPhase3Offset(double offset, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_encoder_phase_3_offset_a(dsa, offset, (DSA_HANDLER)handler, param));
    }
    void setEncoderIndexDistance(double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_encoder_index_distance_a(dsa, pos, (DSA_HANDLER)handler, param));
    }
    void setEncoderPhase3Factor(double factor, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_encoder_phase_3_factor_a(dsa, factor, (DSA_HANDLER)handler, param));
    }
    void setCLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_cl_proportional_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
    }
    void setCLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_cl_integrator_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
    }
    void setCLOutputFilter(double tim, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_cl_output_filter_a(dsa, tim, (DSA_HANDLER)handler, param));
    }
    void setCLCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_cl_current_limit_a(dsa, cur, (DSA_HANDLER)handler, param));
    }
    void setCLI2tCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_cl_i2t_current_limit_a(dsa, cur, (DSA_HANDLER)handler, param));
    }
    void setCLI2tTimeLimit(double tim, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_cl_i2t_time_limit_a(dsa, tim, (DSA_HANDLER)handler, param));
    }
    void setCLRegenMode(int mode, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_cl_regen_mode_a(dsa, mode, (DSA_HANDLER)handler, param));
    }
    void setInitMode(int typ, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_init_mode_a(dsa, typ, (DSA_HANDLER)handler, param));
    }
    void setInitPulseLevel(double cur, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_init_pulse_level_a(dsa, cur, (DSA_HANDLER)handler, param));
    }
    void setInitMaxCurrent(double cur, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_init_max_current_a(dsa, cur, (DSA_HANDLER)handler, param));
    }
    void setInitFinalPhase(double cal, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_init_final_phase_a(dsa, cal, (DSA_HANDLER)handler, param));
    }
    void setInitTime(double tim, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_init_time_a(dsa, tim, (DSA_HANDLER)handler, param));
    }
    void setInitCurrentRate(double cur, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_init_current_rate_a(dsa, cur, (DSA_HANDLER)handler, param));
    }
    void setInitPhaseRate(double cal, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_init_phase_rate_a(dsa, cal, (DSA_HANDLER)handler, param));
    }
    void setInitInitialPhase(double cal, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_init_initial_phase_a(dsa, cal, (DSA_HANDLER)handler, param));
    }
    void setDriveFuseChecking(dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_drive_fuse_checking_a(dsa, mask, (DSA_HANDLER)handler, param));
    }
    void setMotorTempChecking(dword val, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_motor_temp_checking_a(dsa, val, (DSA_HANDLER)handler, param));
    }
    void setMonSourceType(int sidx, int typ, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_mon_source_type_a(dsa, sidx, typ, (DSA_HANDLER)handler, param));
    }
    void setMonSourceIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_mon_source_index_a(dsa, sidx, index, (DSA_HANDLER)handler, param));
    }
    void setMonDestIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_mon_dest_index_a(dsa, sidx, index, (DSA_HANDLER)handler, param));
    }
    void setMonOffset(int sidx, long offset, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_mon_offset_a(dsa, sidx, offset, (DSA_HANDLER)handler, param));
    }
    void setMonGain(int sidx, double gain, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_mon_gain_a(dsa, sidx, gain, (DSA_HANDLER)handler, param));
    }
    void setXAnalogOffset(int sidx, double offset, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_x_analog_offset_a(dsa, sidx, offset, (DSA_HANDLER)handler, param));
    }
    void setXAnalogGain(int sidx, double gain, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_x_analog_gain_a(dsa, sidx, gain, (DSA_HANDLER)handler, param));
    }
    void setSyncroInputMask(dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_syncro_input_mask_a(dsa, mask, (DSA_HANDLER)handler, param));
    }
    void setSyncroInputValue(dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_syncro_input_value_a(dsa, mask, (DSA_HANDLER)handler, param));
    }
    void setSyncroOutputMask(double mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_syncro_output_mask_a(dsa, mask, (DSA_HANDLER)handler, param));
    }
    void setSyncroOutputValue(double mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_syncro_output_value_a(dsa, mask, (DSA_HANDLER)handler, param));
    }
    void setSyncroStartTimeout(int tim, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_syncro_start_timeout_a(dsa, tim, (DSA_HANDLER)handler, param));
    }
    void setDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_digital_output_a(dsa, out, (DSA_HANDLER)handler, param));
    }
    void setXDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_x_digital_output_a(dsa, out, (DSA_HANDLER)handler, param));
    }
    void setXAnalogOutput1(double out, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_x_analog_output_1_a(dsa, out, (DSA_HANDLER)handler, param));
    }
    void setXAnalogOutput2(double out, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_x_analog_output_2_a(dsa, out, (DSA_HANDLER)handler, param));
    }
    void setAnalogOutput(double out, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_analog_output_a(dsa, out, (DSA_HANDLER)handler, param));
    }
    void setInterruptMask1(int sidx, dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_interrupt_mask_1_a(dsa, sidx, mask, (DSA_HANDLER)handler, param));
    }
    void setInterruptMask2(int sidx, dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_interrupt_mask_2_a(dsa, sidx, mask, (DSA_HANDLER)handler, param));
    }
    void setTriggerIrqMask(dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_trigger_irq_mask_a(dsa, mask, (DSA_HANDLER)handler, param));
    }
    void setTriggerIOMask(dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_trigger_io_mask_a(dsa, mask, (DSA_HANDLER)handler, param));
    }
    void setTriggerMapOffset(int offset, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_trigger_map_offset_a(dsa, offset, (DSA_HANDLER)handler, param));
    }
    void setTriggerMapSize(int size, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_trigger_map_size_a(dsa, size, (DSA_HANDLER)handler, param));
    }
    void setRealtimeEnabledGlobal(int enable, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_realtime_enabled_global_a(dsa, enable, (DSA_HANDLER)handler, param));
    }
    void setRealtimeValidMask(dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_realtime_valid_mask_a(dsa, mask, (DSA_HANDLER)handler, param));
    }
    void setRealtimeEnabledMask(dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_realtime_enabled_mask_a(dsa, mask, (DSA_HANDLER)handler, param));
    }
    void setRealtimePendingMask(dword mask, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_realtime_pending_mask_a(dsa, mask, (DSA_HANDLER)handler, param));
    }
    void setEblBaudrate(long baud, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_ebl_baudrate_a(dsa, baud, (DSA_HANDLER)handler, param));
    }
    void setIndirectAxisNumber(int axis, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_indirect_axis_number_a(dsa, axis, (DSA_HANDLER)handler, param));
    }
    void setIndirectRegisterIdx(int idx, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_indirect_register_idx_a(dsa, idx, (DSA_HANDLER)handler, param));
    }
    void setIndirectRegisterSidx(int sidx, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_indirect_register_sidx_a(dsa, sidx, (DSA_HANDLER)handler, param));
    }
    void setConcatenatedMvt(int concat, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_concatenated_mvt_a(dsa, concat, (DSA_HANDLER)handler, param));
    }
    void setProfileType(int sidx, int typ, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_profile_type_a(dsa, sidx, typ, (DSA_HANDLER)handler, param));
    }
    void setMvtLktNumber(int sidx, int number, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_mvt_lkt_number_a(dsa, sidx, number, (DSA_HANDLER)handler, param));
    }
    void setMvtLktTime(int sidx, double time, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_mvt_lkt_time_a(dsa, sidx, time, (DSA_HANDLER)handler, param));
    }
    void setCameValue(double factor, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_came_value_a(dsa, factor, (DSA_HANDLER)handler, param));
    }
    void setBrakeDeceleration(double dec, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_brake_deceleration_a(dsa, dec, (DSA_HANDLER)handler, param));
    }
    void setTargetPosition(int sidx, double pos, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_target_position_a(dsa, sidx, pos, (DSA_HANDLER)handler, param));
    }
    void setProfileVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_profile_velocity_a(dsa, sidx, vel, (DSA_HANDLER)handler, param));
    }
    void setProfileAcceleration(int sidx, double acc, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_profile_acceleration_a(dsa, sidx, acc, (DSA_HANDLER)handler, param));
    }
    void setJerkTime(int sidx, double tim, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_jerk_time_a(dsa, sidx, tim, (DSA_HANDLER)handler, param));
    }
    void setProfileDeceleration(int sidx, double dec, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_profile_deceleration_a(dsa, sidx, dec, (DSA_HANDLER)handler, param));
    }
    void setEndVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_end_velocity_a(dsa, sidx, vel, (DSA_HANDLER)handler, param));
    }
    void setCtrlSourceType(int typ, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_ctrl_source_type_a(dsa, typ, (DSA_HANDLER)handler, param));
    }
    void setCtrlSourceIndex(int index, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_ctrl_source_index_a(dsa, index, (DSA_HANDLER)handler, param));
    }
    void setCtrlShiftFactor(int shift, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_ctrl_shift_factor_a(dsa, shift, (DSA_HANDLER)handler, param));
    }
    void setCtrlOffset(long offset, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_ctrl_offset_a(dsa, offset, (DSA_HANDLER)handler, param));
    }
    void setCtrlGain(double gain, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_ctrl_gain_a(dsa, gain, (DSA_HANDLER)handler, param));
    }
    void setMotorKTFactor(double kt, DsaHandler handler, void *param = NULL) {
        ERRCHK(dsa_set_motor_kt_factor_a(dsa, kt, (DSA_HANDLER)handler, param));
    }


    /*
     * register getter - synchronous
     */
protected:
    double getPLProportionalGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double gain;
        ERRTRANS();
        ERRCHK(dsa_get_pl_proportional_gain_s(dsa, &gain, kind, timeout));
        return gain;
    }
    void getPLProportionalGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pl_proportional_gain_s(dsa, gain, kind, timeout));
    }
    double getPLSpeedFeedbackGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double gain;
        ERRTRANS();
        ERRCHK(dsa_get_pl_speed_feedback_gain_s(dsa, &gain, kind, timeout));
        return gain;
    }
    void getPLSpeedFeedbackGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pl_speed_feedback_gain_s(dsa, gain, kind, timeout));
    }
    double getPLForceFeedbackGain1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double gain;
        ERRTRANS();
        ERRCHK(dsa_get_pl_force_feedback_gain_1_s(dsa, &gain, kind, timeout));
        return gain;
    }
    void getPLForceFeedbackGain1(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pl_force_feedback_gain_1_s(dsa, gain, kind, timeout));
    }
    double getPLIntegratorGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double gain;
        ERRTRANS();
        ERRCHK(dsa_get_pl_integrator_gain_s(dsa, &gain, kind, timeout));
        return gain;
    }
    void getPLIntegratorGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pl_integrator_gain_s(dsa, gain, kind, timeout));
    }
    double getPLAntiWindupGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double gain;
        ERRTRANS();
        ERRCHK(dsa_get_pl_anti_windup_gain_s(dsa, &gain, kind, timeout));
        return gain;
    }
    void getPLAntiWindupGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pl_anti_windup_gain_s(dsa, gain, kind, timeout));
    }
    double getPLIntegratorLimitation(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double limit;
        ERRTRANS();
        ERRCHK(dsa_get_pl_integrator_limitation_s(dsa, &limit, kind, timeout));
        return limit;
    }
    void getPLIntegratorLimitation(double *limit, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pl_integrator_limitation_s(dsa, limit, kind, timeout));
    }
    int getPLIntegratorMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int mode;
        ERRTRANS();
        ERRCHK(dsa_get_pl_integrator_mode_s(dsa, &mode, kind, timeout));
        return mode;
    }
    void getPLIntegratorMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pl_integrator_mode_s(dsa, mode, kind, timeout));
    }
    double getPLSpeedFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double tim;
        ERRTRANS();
        ERRCHK(dsa_get_pl_speed_filter_s(dsa, &tim, kind, timeout));
        return tim;
    }
    void getPLSpeedFilter(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pl_speed_filter_s(dsa, tim, kind, timeout));
    }
    double getPLOutputFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double tim;
        ERRTRANS();
        ERRCHK(dsa_get_pl_output_filter_s(dsa, &tim, kind, timeout));
        return tim;
    }
    void getPLOutputFilter(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pl_output_filter_s(dsa, tim, kind, timeout));
    }
    double getCLInputFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double tim;
        ERRTRANS();
        ERRCHK(dsa_get_cl_input_filter_s(dsa, &tim, kind, timeout));
        return tim;
    }
    void getCLInputFilter(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_input_filter_s(dsa, tim, kind, timeout));
    }
    double getTtlSpecialFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double factor;
        ERRTRANS();
        ERRCHK(dsa_get_ttl_special_filter_s(dsa, &factor, kind, timeout));
        return factor;
    }
    void getTtlSpecialFilter(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_ttl_special_filter_s(dsa, factor, kind, timeout));
    }
    double getPLForceFeedbackGain2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double factor;
        ERRTRANS();
        ERRCHK(dsa_get_pl_force_feedback_gain_2_s(dsa, &factor, kind, timeout));
        return factor;
    }
    void getPLForceFeedbackGain2(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pl_force_feedback_gain_2_s(dsa, factor, kind, timeout));
    }
    double getPLSpeedFeedfwdGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double factor;
        ERRTRANS();
        ERRCHK(dsa_get_pl_speed_feedfwd_gain_s(dsa, &factor, kind, timeout));
        return factor;
    }
    void getPLSpeedFeedfwdGain(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pl_speed_feedfwd_gain_s(dsa, factor, kind, timeout));
    }
    double getPLAccFeedforwardGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double factor;
        ERRTRANS();
        ERRCHK(dsa_get_pl_acc_feedforward_gain_s(dsa, &factor, kind, timeout));
        return factor;
    }
    void getPLAccFeedforwardGain(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pl_acc_feedforward_gain_s(dsa, factor, kind, timeout));
    }
    double getCLPhaseAdvanceFactor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double factor;
        ERRTRANS();
        ERRCHK(dsa_get_cl_phase_advance_factor_s(dsa, &factor, kind, timeout));
        return factor;
    }
    void getCLPhaseAdvanceFactor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_phase_advance_factor_s(dsa, factor, kind, timeout));
    }
    double getAprInputFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double time;
        ERRTRANS();
        ERRCHK(dsa_get_apr_input_filter_s(dsa, &time, kind, timeout));
        return time;
    }
    void getAprInputFilter(double *time, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_apr_input_filter_s(dsa, time, kind, timeout));
    }
    double getCLPhaseAdvanceShift(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double shift;
        ERRTRANS();
        ERRCHK(dsa_get_cl_phase_advance_shift_s(dsa, &shift, kind, timeout));
        return shift;
    }
    void getCLPhaseAdvanceShift(double *shift, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_phase_advance_shift_s(dsa, shift, kind, timeout));
    }
    double getMinPositionRangeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_min_position_range_limit_s(dsa, &pos, kind, timeout));
        return pos;
    }
    void getMinPositionRangeLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_min_position_range_limit_s(dsa, pos, kind, timeout));
    }
    double getMaxPositionRangeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_max_position_range_limit_s(dsa, &pos, kind, timeout));
        return pos;
    }
    void getMaxPositionRangeLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_max_position_range_limit_s(dsa, pos, kind, timeout));
    }
    double getMaxProfileVelocity(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double vel;
        ERRTRANS();
        ERRCHK(dsa_get_max_profile_velocity_s(dsa, &vel, kind, timeout));
        return vel;
    }
    void getMaxProfileVelocity(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_max_profile_velocity_s(dsa, vel, kind, timeout));
    }
    double getMaxAcceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double acc;
        ERRTRANS();
        ERRCHK(dsa_get_max_acceleration_s(dsa, &acc, kind, timeout));
        return acc;
    }
    void getMaxAcceleration(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_max_acceleration_s(dsa, acc, kind, timeout));
    }
    double getFollowingErrorWindow(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_following_error_window_s(dsa, &pos, kind, timeout));
        return pos;
    }
    void getFollowingErrorWindow(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_following_error_window_s(dsa, pos, kind, timeout));
    }
    double getVelocityErrorLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double vel;
        ERRTRANS();
        ERRCHK(dsa_get_velocity_error_limit_s(dsa, &vel, kind, timeout));
        return vel;
    }
    void getVelocityErrorLimit(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_velocity_error_limit_s(dsa, vel, kind, timeout));
    }
    int getSwitchLimitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int mode;
        ERRTRANS();
        ERRCHK(dsa_get_switch_limit_mode_s(dsa, &mode, kind, timeout));
        return mode;
    }
    void getSwitchLimitMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_switch_limit_mode_s(dsa, mode, kind, timeout));
    }
    int getEnableInputMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int mode;
        ERRTRANS();
        ERRCHK(dsa_get_enable_input_mode_s(dsa, &mode, kind, timeout));
        return mode;
    }
    void getEnableInputMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_enable_input_mode_s(dsa, mode, kind, timeout));
    }
    double getMinSoftPositionLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_min_soft_position_limit_s(dsa, &pos, kind, timeout));
        return pos;
    }
    void getMinSoftPositionLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_min_soft_position_limit_s(dsa, pos, kind, timeout));
    }
    double getMaxSoftPositionLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_max_soft_position_limit_s(dsa, &pos, kind, timeout));
        return pos;
    }
    void getMaxSoftPositionLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_max_soft_position_limit_s(dsa, pos, kind, timeout));
    }
    dword getProfileLimitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword flags;
        ERRTRANS();
        ERRCHK(dsa_get_profile_limit_mode_s(dsa, &flags, kind, timeout));
        return flags;
    }
    void getProfileLimitMode(dword *flags, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_profile_limit_mode_s(dsa, flags, kind, timeout));
    }
    dword getIOErrorEventMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_io_error_event_mask_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getIOErrorEventMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_io_error_event_mask_s(dsa, mask, kind, timeout));
    }
    double getPositionWindowTime(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double tim;
        ERRTRANS();
        ERRCHK(dsa_get_position_window_time_s(dsa, &tim, kind, timeout));
        return tim;
    }
    void getPositionWindowTime(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_position_window_time_s(dsa, tim, kind, timeout));
    }
    double getPositionWindow(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double win;
        ERRTRANS();
        ERRCHK(dsa_get_position_window_s(dsa, &win, kind, timeout));
        return win;
    }
    void getPositionWindow(double *win, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_position_window_s(dsa, win, kind, timeout));
    }
    int getHomingMethod(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int mode;
        ERRTRANS();
        ERRCHK(dsa_get_homing_method_s(dsa, &mode, kind, timeout));
        return mode;
    }
    void getHomingMethod(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_homing_method_s(dsa, mode, kind, timeout));
    }
    double getHomingZeroSpeed(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double vel;
        ERRTRANS();
        ERRCHK(dsa_get_homing_zero_speed_s(dsa, &vel, kind, timeout));
        return vel;
    }
    void getHomingZeroSpeed(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_homing_zero_speed_s(dsa, vel, kind, timeout));
    }
    double getHomingAcceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double acc;
        ERRTRANS();
        ERRCHK(dsa_get_homing_acceleration_s(dsa, &acc, kind, timeout));
        return acc;
    }
    void getHomingAcceleration(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_homing_acceleration_s(dsa, acc, kind, timeout));
    }
    double getHomingFollowingLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double win;
        ERRTRANS();
        ERRCHK(dsa_get_homing_following_limit_s(dsa, &win, kind, timeout));
        return win;
    }
    void getHomingFollowingLimit(double *win, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_homing_following_limit_s(dsa, win, kind, timeout));
    }
    double getHomingCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cur;
        ERRTRANS();
        ERRCHK(dsa_get_homing_current_limit_s(dsa, &cur, kind, timeout));
        return cur;
    }
    void getHomingCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_homing_current_limit_s(dsa, cur, kind, timeout));
    }
    double getHomeOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_home_offset_s(dsa, &pos, kind, timeout));
        return pos;
    }
    void getHomeOffset(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_home_offset_s(dsa, pos, kind, timeout));
    }
    double getHomingFixedMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_homing_fixed_mvt_s(dsa, &pos, kind, timeout));
        return pos;
    }
    void getHomingFixedMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_homing_fixed_mvt_s(dsa, pos, kind, timeout));
    }
    double getHomingSwitchMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_homing_switch_mvt_s(dsa, &pos, kind, timeout));
        return pos;
    }
    void getHomingSwitchMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_homing_switch_mvt_s(dsa, pos, kind, timeout));
    }
    double getHomingIndexMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_homing_index_mvt_s(dsa, &pos, kind, timeout));
        return pos;
    }
    void getHomingIndexMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_homing_index_mvt_s(dsa, pos, kind, timeout));
    }
    int getHomingFineTuningMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int mode;
        ERRTRANS();
        ERRCHK(dsa_get_homing_fine_tuning_mode_s(dsa, &mode, kind, timeout));
        return mode;
    }
    void getHomingFineTuningMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_homing_fine_tuning_mode_s(dsa, mode, kind, timeout));
    }
    double getHomingFineTuningValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double phase;
        ERRTRANS();
        ERRCHK(dsa_get_homing_fine_tuning_value_s(dsa, &phase, kind, timeout));
        return phase;
    }
    void getHomingFineTuningValue(double *phase, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_homing_fine_tuning_value_s(dsa, phase, kind, timeout));
    }
    int getMotorPhaseCorrection(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int mode;
        ERRTRANS();
        ERRCHK(dsa_get_motor_phase_correction_s(dsa, &mode, kind, timeout));
        return mode;
    }
    void getMotorPhaseCorrection(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_motor_phase_correction_s(dsa, mode, kind, timeout));
    }
    double getSoftwareCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cur;
        ERRTRANS();
        ERRCHK(dsa_get_software_current_limit_s(dsa, &cur, kind, timeout));
        return cur;
    }
    void getSoftwareCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_software_current_limit_s(dsa, cur, kind, timeout));
    }
    int getDriveControlMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int mode;
        ERRTRANS();
        ERRCHK(dsa_get_drive_control_mode_s(dsa, &mode, kind, timeout));
        return mode;
    }
    void getDriveControlMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_drive_control_mode_s(dsa, mode, kind, timeout));
    }
    int getDisplayMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int mode;
        ERRTRANS();
        ERRCHK(dsa_get_display_mode_s(dsa, &mode, kind, timeout));
        return mode;
    }
    void getDisplayMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_display_mode_s(dsa, mode, kind, timeout));
    }
    double getEncoderInversion(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double invert;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_inversion_s(dsa, &invert, kind, timeout));
        return invert;
    }
    void getEncoderInversion(double *invert, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_inversion_s(dsa, invert, kind, timeout));
    }
    double getPdrStepValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double step;
        ERRTRANS();
        ERRCHK(dsa_get_pdr_step_value_s(dsa, &step, kind, timeout));
        return step;
    }
    void getPdrStepValue(double *step, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_pdr_step_value_s(dsa, step, kind, timeout));
    }
    double getEncoderPhase1Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double offset;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_phase_1_offset_s(dsa, &offset, kind, timeout));
        return offset;
    }
    void getEncoderPhase1Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_phase_1_offset_s(dsa, offset, kind, timeout));
    }
    double getEncoderPhase2Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double offset;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_phase_2_offset_s(dsa, &offset, kind, timeout));
        return offset;
    }
    void getEncoderPhase2Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_phase_2_offset_s(dsa, offset, kind, timeout));
    }
    double getEncoderPhase1Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double factor;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_phase_1_factor_s(dsa, &factor, kind, timeout));
        return factor;
    }
    void getEncoderPhase1Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_phase_1_factor_s(dsa, factor, kind, timeout));
    }
    double getEncoderPhase2Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double factor;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_phase_2_factor_s(dsa, &factor, kind, timeout));
        return factor;
    }
    void getEncoderPhase2Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_phase_2_factor_s(dsa, factor, kind, timeout));
    }
    double getEncoderPhase3Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double offset;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_phase_3_offset_s(dsa, &offset, kind, timeout));
        return offset;
    }
    void getEncoderPhase3Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_phase_3_offset_s(dsa, offset, kind, timeout));
    }
    double getEncoderIndexDistance(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_index_distance_s(dsa, &pos, kind, timeout));
        return pos;
    }
    void getEncoderIndexDistance(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_index_distance_s(dsa, pos, kind, timeout));
    }
    double getEncoderPhase3Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double factor;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_phase_3_factor_s(dsa, &factor, kind, timeout));
        return factor;
    }
    void getEncoderPhase3Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_phase_3_factor_s(dsa, factor, kind, timeout));
    }
    double getCLProportionalGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double gain;
        ERRTRANS();
        ERRCHK(dsa_get_cl_proportional_gain_s(dsa, &gain, kind, timeout));
        return gain;
    }
    void getCLProportionalGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_proportional_gain_s(dsa, gain, kind, timeout));
    }
    double getCLIntegratorGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double gain;
        ERRTRANS();
        ERRCHK(dsa_get_cl_integrator_gain_s(dsa, &gain, kind, timeout));
        return gain;
    }
    void getCLIntegratorGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_integrator_gain_s(dsa, gain, kind, timeout));
    }
    double getCLOutputFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double tim;
        ERRTRANS();
        ERRCHK(dsa_get_cl_output_filter_s(dsa, &tim, kind, timeout));
        return tim;
    }
    void getCLOutputFilter(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_output_filter_s(dsa, tim, kind, timeout));
    }
    double getCLCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cur;
        ERRTRANS();
        ERRCHK(dsa_get_cl_current_limit_s(dsa, &cur, kind, timeout));
        return cur;
    }
    void getCLCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_current_limit_s(dsa, cur, kind, timeout));
    }
    double getCLI2tCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cur;
        ERRTRANS();
        ERRCHK(dsa_get_cl_i2t_current_limit_s(dsa, &cur, kind, timeout));
        return cur;
    }
    void getCLI2tCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_i2t_current_limit_s(dsa, cur, kind, timeout));
    }
    double getCLI2tTimeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double tim;
        ERRTRANS();
        ERRCHK(dsa_get_cl_i2t_time_limit_s(dsa, &tim, kind, timeout));
        return tim;
    }
    void getCLI2tTimeLimit(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_i2t_time_limit_s(dsa, tim, kind, timeout));
    }
    int getCLRegenMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int mode;
        ERRTRANS();
        ERRCHK(dsa_get_cl_regen_mode_s(dsa, &mode, kind, timeout));
        return mode;
    }
    void getCLRegenMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_regen_mode_s(dsa, mode, kind, timeout));
    }
    int getInitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int typ;
        ERRTRANS();
        ERRCHK(dsa_get_init_mode_s(dsa, &typ, kind, timeout));
        return typ;
    }
    void getInitMode(int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_init_mode_s(dsa, typ, kind, timeout));
    }
    double getInitPulseLevel(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cur;
        ERRTRANS();
        ERRCHK(dsa_get_init_pulse_level_s(dsa, &cur, kind, timeout));
        return cur;
    }
    void getInitPulseLevel(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_init_pulse_level_s(dsa, cur, kind, timeout));
    }
    double getInitMaxCurrent(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cur;
        ERRTRANS();
        ERRCHK(dsa_get_init_max_current_s(dsa, &cur, kind, timeout));
        return cur;
    }
    void getInitMaxCurrent(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_init_max_current_s(dsa, cur, kind, timeout));
    }
    double getInitFinalPhase(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cal;
        ERRTRANS();
        ERRCHK(dsa_get_init_final_phase_s(dsa, &cal, kind, timeout));
        return cal;
    }
    void getInitFinalPhase(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_init_final_phase_s(dsa, cal, kind, timeout));
    }
    double getInitTime(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double tim;
        ERRTRANS();
        ERRCHK(dsa_get_init_time_s(dsa, &tim, kind, timeout));
        return tim;
    }
    void getInitTime(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_init_time_s(dsa, tim, kind, timeout));
    }
    double getInitCurrentRate(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cur;
        ERRTRANS();
        ERRCHK(dsa_get_init_current_rate_s(dsa, &cur, kind, timeout));
        return cur;
    }
    void getInitCurrentRate(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_init_current_rate_s(dsa, cur, kind, timeout));
    }
    double getInitPhaseRate(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cal;
        ERRTRANS();
        ERRCHK(dsa_get_init_phase_rate_s(dsa, &cal, kind, timeout));
        return cal;
    }
    void getInitPhaseRate(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_init_phase_rate_s(dsa, cal, kind, timeout));
    }
    double getInitInitialPhase(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cal;
        ERRTRANS();
        ERRCHK(dsa_get_init_initial_phase_s(dsa, &cal, kind, timeout));
        return cal;
    }
    void getInitInitialPhase(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_init_initial_phase_s(dsa, cal, kind, timeout));
    }
    dword getDriveFuseChecking(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_drive_fuse_checking_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getDriveFuseChecking(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_drive_fuse_checking_s(dsa, mask, kind, timeout));
    }
    dword getMotorTempChecking(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword val;
        ERRTRANS();
        ERRCHK(dsa_get_motor_temp_checking_s(dsa, &val, kind, timeout));
        return val;
    }
    void getMotorTempChecking(dword *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_motor_temp_checking_s(dsa, val, kind, timeout));
    }
    int getMonSourceType(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int typ;
        ERRTRANS();
        ERRCHK(dsa_get_mon_source_type_s(dsa, sidx, &typ, kind, timeout));
        return typ;
    }
    void getMonSourceType(int sidx, int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_mon_source_type_s(dsa, sidx, typ, kind, timeout));
    }
    int getMonSourceIndex(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int index;
        ERRTRANS();
        ERRCHK(dsa_get_mon_source_index_s(dsa, sidx, &index, kind, timeout));
        return index;
    }
    void getMonSourceIndex(int sidx, int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_mon_source_index_s(dsa, sidx, index, kind, timeout));
    }
    int getMonDestIndex(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int index;
        ERRTRANS();
        ERRCHK(dsa_get_mon_dest_index_s(dsa, sidx, &index, kind, timeout));
        return index;
    }
    void getMonDestIndex(int sidx, int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_mon_dest_index_s(dsa, sidx, index, kind, timeout));
    }
    long getMonOffset(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        long offset;
        ERRTRANS();
        ERRCHK(dsa_get_mon_offset_s(dsa, sidx, &offset, kind, timeout));
        return offset;
    }
    void getMonOffset(int sidx, long *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_mon_offset_s(dsa, sidx, offset, kind, timeout));
    }
    double getMonGain(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double gain;
        ERRTRANS();
        ERRCHK(dsa_get_mon_gain_s(dsa, sidx, &gain, kind, timeout));
        return gain;
    }
    void getMonGain(int sidx, double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_mon_gain_s(dsa, sidx, gain, kind, timeout));
    }
    double getXAnalogOffset(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double offset;
        ERRTRANS();
        ERRCHK(dsa_get_x_analog_offset_s(dsa, sidx, &offset, kind, timeout));
        return offset;
    }
    void getXAnalogOffset(int sidx, double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_x_analog_offset_s(dsa, sidx, offset, kind, timeout));
    }
    double getXAnalogGain(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double gain;
        ERRTRANS();
        ERRCHK(dsa_get_x_analog_gain_s(dsa, sidx, &gain, kind, timeout));
        return gain;
    }
    void getXAnalogGain(int sidx, double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_x_analog_gain_s(dsa, sidx, gain, kind, timeout));
    }
    dword getSyncroInputMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_syncro_input_mask_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getSyncroInputMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_syncro_input_mask_s(dsa, mask, kind, timeout));
    }
    dword getSyncroInputValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_syncro_input_value_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getSyncroInputValue(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_syncro_input_value_s(dsa, mask, kind, timeout));
    }
    double getSyncroOutputMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double mask;
        ERRTRANS();
        ERRCHK(dsa_get_syncro_output_mask_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getSyncroOutputMask(double *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_syncro_output_mask_s(dsa, mask, kind, timeout));
    }
    double getSyncroOutputValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double mask;
        ERRTRANS();
        ERRCHK(dsa_get_syncro_output_value_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getSyncroOutputValue(double *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_syncro_output_value_s(dsa, mask, kind, timeout));
    }
    int getSyncroStartTimeout(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int tim;
        ERRTRANS();
        ERRCHK(dsa_get_syncro_start_timeout_s(dsa, &tim, kind, timeout));
        return tim;
    }
    void getSyncroStartTimeout(int *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_syncro_start_timeout_s(dsa, tim, kind, timeout));
    }
    dword getDigitalOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword out;
        ERRTRANS();
        ERRCHK(dsa_get_digital_output_s(dsa, &out, kind, timeout));
        return out;
    }
    void getDigitalOutput(dword *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_digital_output_s(dsa, out, kind, timeout));
    }
    dword getXDigitalOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword out;
        ERRTRANS();
        ERRCHK(dsa_get_x_digital_output_s(dsa, &out, kind, timeout));
        return out;
    }
    void getXDigitalOutput(dword *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_x_digital_output_s(dsa, out, kind, timeout));
    }
    double getXAnalogOutput1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double out;
        ERRTRANS();
        ERRCHK(dsa_get_x_analog_output_1_s(dsa, &out, kind, timeout));
        return out;
    }
    void getXAnalogOutput1(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_x_analog_output_1_s(dsa, out, kind, timeout));
    }
    double getXAnalogOutput2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double out;
        ERRTRANS();
        ERRCHK(dsa_get_x_analog_output_2_s(dsa, &out, kind, timeout));
        return out;
    }
    void getXAnalogOutput2(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_x_analog_output_2_s(dsa, out, kind, timeout));
    }
    double getAnalogOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double out;
        ERRTRANS();
        ERRCHK(dsa_get_analog_output_s(dsa, &out, kind, timeout));
        return out;
    }
    void getAnalogOutput(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_analog_output_s(dsa, out, kind, timeout));
    }
    dword getInterruptMask1(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_interrupt_mask_1_s(dsa, sidx, &mask, kind, timeout));
        return mask;
    }
    void getInterruptMask1(int sidx, dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_interrupt_mask_1_s(dsa, sidx, mask, kind, timeout));
    }
    dword getInterruptMask2(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_interrupt_mask_2_s(dsa, sidx, &mask, kind, timeout));
        return mask;
    }
    void getInterruptMask2(int sidx, dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_interrupt_mask_2_s(dsa, sidx, mask, kind, timeout));
    }
    dword getTriggerIrqMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_trigger_irq_mask_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getTriggerIrqMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_trigger_irq_mask_s(dsa, mask, kind, timeout));
    }
    dword getTriggerIOMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_trigger_io_mask_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getTriggerIOMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_trigger_io_mask_s(dsa, mask, kind, timeout));
    }
    int getTriggerMapOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int offset;
        ERRTRANS();
        ERRCHK(dsa_get_trigger_map_offset_s(dsa, &offset, kind, timeout));
        return offset;
    }
    void getTriggerMapOffset(int *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_trigger_map_offset_s(dsa, offset, kind, timeout));
    }
    int getTriggerMapSize(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int size;
        ERRTRANS();
        ERRCHK(dsa_get_trigger_map_size_s(dsa, &size, kind, timeout));
        return size;
    }
    void getTriggerMapSize(int *size, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_trigger_map_size_s(dsa, size, kind, timeout));
    }
    int getRealtimeEnabledGlobal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int enable;
        ERRTRANS();
        ERRCHK(dsa_get_realtime_enabled_global_s(dsa, &enable, kind, timeout));
        return enable;
    }
    void getRealtimeEnabledGlobal(int *enable, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_realtime_enabled_global_s(dsa, enable, kind, timeout));
    }
    dword getRealtimeValidMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_realtime_valid_mask_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getRealtimeValidMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_realtime_valid_mask_s(dsa, mask, kind, timeout));
    }
    dword getRealtimeEnabledMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_realtime_enabled_mask_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getRealtimeEnabledMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_realtime_enabled_mask_s(dsa, mask, kind, timeout));
    }
    dword getRealtimePendingMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_realtime_pending_mask_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getRealtimePendingMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_realtime_pending_mask_s(dsa, mask, kind, timeout));
    }
    long getEblBaudrate(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        long baud;
        ERRTRANS();
        ERRCHK(dsa_get_ebl_baudrate_s(dsa, &baud, kind, timeout));
        return baud;
    }
    void getEblBaudrate(long *baud, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_ebl_baudrate_s(dsa, baud, kind, timeout));
    }
    int getIndirectAxisNumber(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int axis;
        ERRTRANS();
        ERRCHK(dsa_get_indirect_axis_number_s(dsa, &axis, kind, timeout));
        return axis;
    }
    void getIndirectAxisNumber(int *axis, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_indirect_axis_number_s(dsa, axis, kind, timeout));
    }
    int getIndirectRegisterIdx(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int idx;
        ERRTRANS();
        ERRCHK(dsa_get_indirect_register_idx_s(dsa, &idx, kind, timeout));
        return idx;
    }
    void getIndirectRegisterIdx(int *idx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_indirect_register_idx_s(dsa, idx, kind, timeout));
    }
    int getIndirectRegisterSidx(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int sidx;
        ERRTRANS();
        ERRCHK(dsa_get_indirect_register_sidx_s(dsa, &sidx, kind, timeout));
        return sidx;
    }
    void getIndirectRegisterSidx(int *sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_indirect_register_sidx_s(dsa, sidx, kind, timeout));
    }
    int getConcatenatedMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int concat;
        ERRTRANS();
        ERRCHK(dsa_get_concatenated_mvt_s(dsa, &concat, kind, timeout));
        return concat;
    }
    void getConcatenatedMvt(int *concat, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_concatenated_mvt_s(dsa, concat, kind, timeout));
    }
    int getProfileType(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int typ;
        ERRTRANS();
        ERRCHK(dsa_get_profile_type_s(dsa, sidx, &typ, kind, timeout));
        return typ;
    }
    void getProfileType(int sidx, int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_profile_type_s(dsa, sidx, typ, kind, timeout));
    }
    int getMvtLktNumber(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int number;
        ERRTRANS();
        ERRCHK(dsa_get_mvt_lkt_number_s(dsa, sidx, &number, kind, timeout));
        return number;
    }
    void getMvtLktNumber(int sidx, int *number, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_mvt_lkt_number_s(dsa, sidx, number, kind, timeout));
    }
    double getMvtLktTime(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double time;
        ERRTRANS();
        ERRCHK(dsa_get_mvt_lkt_time_s(dsa, sidx, &time, kind, timeout));
        return time;
    }
    void getMvtLktTime(int sidx, double *time, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_mvt_lkt_time_s(dsa, sidx, time, kind, timeout));
    }
    double getCameValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double factor;
        ERRTRANS();
        ERRCHK(dsa_get_came_value_s(dsa, &factor, kind, timeout));
        return factor;
    }
    void getCameValue(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_came_value_s(dsa, factor, kind, timeout));
    }
    double getBrakeDeceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double dec;
        ERRTRANS();
        ERRCHK(dsa_get_brake_deceleration_s(dsa, &dec, kind, timeout));
        return dec;
    }
    void getBrakeDeceleration(double *dec, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_brake_deceleration_s(dsa, dec, kind, timeout));
    }
    double getTargetPosition(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_target_position_s(dsa, sidx, &pos, kind, timeout));
        return pos;
    }
    void getTargetPosition(int sidx, double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_target_position_s(dsa, sidx, pos, kind, timeout));
    }
    double getProfileVelocity(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double vel;
        ERRTRANS();
        ERRCHK(dsa_get_profile_velocity_s(dsa, sidx, &vel, kind, timeout));
        return vel;
    }
    void getProfileVelocity(int sidx, double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_profile_velocity_s(dsa, sidx, vel, kind, timeout));
    }
    double getProfileAcceleration(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double acc;
        ERRTRANS();
        ERRCHK(dsa_get_profile_acceleration_s(dsa, sidx, &acc, kind, timeout));
        return acc;
    }
    void getProfileAcceleration(int sidx, double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_profile_acceleration_s(dsa, sidx, acc, kind, timeout));
    }
    double getJerkTime(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double tim;
        ERRTRANS();
        ERRCHK(dsa_get_jerk_time_s(dsa, sidx, &tim, kind, timeout));
        return tim;
    }
    void getJerkTime(int sidx, double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_jerk_time_s(dsa, sidx, tim, kind, timeout));
    }
    double getProfileDeceleration(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double dec;
        ERRTRANS();
        ERRCHK(dsa_get_profile_deceleration_s(dsa, sidx, &dec, kind, timeout));
        return dec;
    }
    void getProfileDeceleration(int sidx, double *dec, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_profile_deceleration_s(dsa, sidx, dec, kind, timeout));
    }
    double getEndVelocity(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double vel;
        ERRTRANS();
        ERRCHK(dsa_get_end_velocity_s(dsa, sidx, &vel, kind, timeout));
        return vel;
    }
    void getEndVelocity(int sidx, double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_end_velocity_s(dsa, sidx, vel, kind, timeout));
    }
    int getCtrlSourceType(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int typ;
        ERRTRANS();
        ERRCHK(dsa_get_ctrl_source_type_s(dsa, &typ, kind, timeout));
        return typ;
    }
    void getCtrlSourceType(int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_ctrl_source_type_s(dsa, typ, kind, timeout));
    }
    int getCtrlSourceIndex(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int index;
        ERRTRANS();
        ERRCHK(dsa_get_ctrl_source_index_s(dsa, &index, kind, timeout));
        return index;
    }
    void getCtrlSourceIndex(int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_ctrl_source_index_s(dsa, index, kind, timeout));
    }
    int getCtrlShiftFactor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int shift;
        ERRTRANS();
        ERRCHK(dsa_get_ctrl_shift_factor_s(dsa, &shift, kind, timeout));
        return shift;
    }
    void getCtrlShiftFactor(int *shift, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_ctrl_shift_factor_s(dsa, shift, kind, timeout));
    }
    long getCtrlOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        long offset;
        ERRTRANS();
        ERRCHK(dsa_get_ctrl_offset_s(dsa, &offset, kind, timeout));
        return offset;
    }
    void getCtrlOffset(long *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_ctrl_offset_s(dsa, offset, kind, timeout));
    }
    double getCtrlGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double gain;
        ERRTRANS();
        ERRCHK(dsa_get_ctrl_gain_s(dsa, &gain, kind, timeout));
        return gain;
    }
    void getCtrlGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_ctrl_gain_s(dsa, gain, kind, timeout));
    }
    double getMotorKTFactor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double kt;
        ERRTRANS();
        ERRCHK(dsa_get_motor_kt_factor_s(dsa, &kt, kind, timeout));
        return kt;
    }
    void getMotorKTFactor(double *kt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_motor_kt_factor_s(dsa, kt, kind, timeout));
    }
    double getPositionCtrlError(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double err;
        ERRTRANS();
        ERRCHK(dsa_get_position_ctrl_error_s(dsa, &err, kind, timeout));
        return err;
    }
    void getPositionCtrlError(double *err, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_position_ctrl_error_s(dsa, err, kind, timeout));
    }
    double getPositionMaxError(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double err;
        ERRTRANS();
        ERRCHK(dsa_get_position_max_error_s(dsa, &err, kind, timeout));
        return err;
    }
    void getPositionMaxError(double *err, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_position_max_error_s(dsa, err, kind, timeout));
    }
    double getPositionDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_position_demand_value_s(dsa, &pos, kind, timeout));
        return pos;
    }
    void getPositionDemandValue(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_position_demand_value_s(dsa, pos, kind, timeout));
    }
    double getPositionActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double pos;
        ERRTRANS();
        ERRCHK(dsa_get_position_actual_value_s(dsa, &pos, kind, timeout));
        return pos;
    }
    void getPositionActualValue(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_position_actual_value_s(dsa, pos, kind, timeout));
    }
    double getVelocityDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double vel;
        ERRTRANS();
        ERRCHK(dsa_get_velocity_demand_value_s(dsa, &vel, kind, timeout));
        return vel;
    }
    void getVelocityDemandValue(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_velocity_demand_value_s(dsa, vel, kind, timeout));
    }
    double getVelocityActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double vel;
        ERRTRANS();
        ERRCHK(dsa_get_velocity_actual_value_s(dsa, &vel, kind, timeout));
        return vel;
    }
    void getVelocityActualValue(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_velocity_actual_value_s(dsa, vel, kind, timeout));
    }
    double getAccDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double acc;
        ERRTRANS();
        ERRCHK(dsa_get_acc_demand_value_s(dsa, &acc, kind, timeout));
        return acc;
    }
    void getAccDemandValue(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_acc_demand_value_s(dsa, acc, kind, timeout));
    }
    double getAccActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double acc;
        ERRTRANS();
        ERRCHK(dsa_get_acc_actual_value_s(dsa, &acc, kind, timeout));
        return acc;
    }
    void getAccActualValue(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_acc_actual_value_s(dsa, acc, kind, timeout));
    }
    double getRefDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double ref;
        ERRTRANS();
        ERRCHK(dsa_get_ref_demand_value_s(dsa, &ref, kind, timeout));
        return ref;
    }
    void getRefDemandValue(double *ref, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_ref_demand_value_s(dsa, ref, kind, timeout));
    }
    dword getDriveControlMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_drive_control_mask_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getDriveControlMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_drive_control_mask_s(dsa, mask, kind, timeout));
    }
    double getCLCurrentPhase1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cur;
        ERRTRANS();
        ERRCHK(dsa_get_cl_current_phase_1_s(dsa, &cur, kind, timeout));
        return cur;
    }
    void getCLCurrentPhase1(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_current_phase_1_s(dsa, cur, kind, timeout));
    }
    double getCLCurrentPhase2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cur;
        ERRTRANS();
        ERRCHK(dsa_get_cl_current_phase_2_s(dsa, &cur, kind, timeout));
        return cur;
    }
    void getCLCurrentPhase2(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_current_phase_2_s(dsa, cur, kind, timeout));
    }
    double getCLCurrentPhase3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cur;
        ERRTRANS();
        ERRCHK(dsa_get_cl_current_phase_3_s(dsa, &cur, kind, timeout));
        return cur;
    }
    void getCLCurrentPhase3(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_current_phase_3_s(dsa, cur, kind, timeout));
    }
    double getCLLktPhase1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double lkt;
        ERRTRANS();
        ERRCHK(dsa_get_cl_lkt_phase_1_s(dsa, &lkt, kind, timeout));
        return lkt;
    }
    void getCLLktPhase1(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_lkt_phase_1_s(dsa, lkt, kind, timeout));
    }
    double getCLLktPhase2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double lkt;
        ERRTRANS();
        ERRCHK(dsa_get_cl_lkt_phase_2_s(dsa, &lkt, kind, timeout));
        return lkt;
    }
    void getCLLktPhase2(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_lkt_phase_2_s(dsa, lkt, kind, timeout));
    }
    double getCLLktPhase3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double lkt;
        ERRTRANS();
        ERRCHK(dsa_get_cl_lkt_phase_3_s(dsa, &lkt, kind, timeout));
        return lkt;
    }
    void getCLLktPhase3(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_lkt_phase_3_s(dsa, lkt, kind, timeout));
    }
    double getCLDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cur;
        ERRTRANS();
        ERRCHK(dsa_get_cl_demand_value_s(dsa, &cur, kind, timeout));
        return cur;
    }
    void getCLDemandValue(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_demand_value_s(dsa, cur, kind, timeout));
    }
    double getCLActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double cur;
        ERRTRANS();
        ERRCHK(dsa_get_cl_actual_value_s(dsa, &cur, kind, timeout));
        return cur;
    }
    void getCLActualValue(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_actual_value_s(dsa, cur, kind, timeout));
    }
    double getEncoderSineSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double val;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_sine_signal_s(dsa, &val, kind, timeout));
        return val;
    }
    void getEncoderSineSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_sine_signal_s(dsa, val, kind, timeout));
    }
    double getEncoderCosineSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double val;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_cosine_signal_s(dsa, &val, kind, timeout));
        return val;
    }
    void getEncoderCosineSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_cosine_signal_s(dsa, val, kind, timeout));
    }
    double getEncoderIndexSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double val;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_index_signal_s(dsa, &val, kind, timeout));
        return val;
    }
    void getEncoderIndexSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_index_signal_s(dsa, val, kind, timeout));
    }
    double getEncoderHall1Signal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double val;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_hall_1_signal_s(dsa, &val, kind, timeout));
        return val;
    }
    void getEncoderHall1Signal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_hall_1_signal_s(dsa, val, kind, timeout));
    }
    double getEncoderHall2Signal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double val;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_hall_2_signal_s(dsa, &val, kind, timeout));
        return val;
    }
    void getEncoderHall2Signal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_hall_2_signal_s(dsa, val, kind, timeout));
    }
    double getEncoderHall3Signal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double val;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_hall_3_signal_s(dsa, &val, kind, timeout));
        return val;
    }
    void getEncoderHall3Signal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_hall_3_signal_s(dsa, val, kind, timeout));
    }
    dword getEncoderHallDigSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_encoder_hall_dig_signal_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getEncoderHallDigSignal(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_encoder_hall_dig_signal_s(dsa, mask, kind, timeout));
    }
    dword getDigitalInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword inp;
        ERRTRANS();
        ERRCHK(dsa_get_digital_input_s(dsa, &inp, kind, timeout));
        return inp;
    }
    void getDigitalInput(dword *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_digital_input_s(dsa, inp, kind, timeout));
    }
    double getAnalogInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double inp;
        ERRTRANS();
        ERRCHK(dsa_get_analog_input_s(dsa, &inp, kind, timeout));
        return inp;
    }
    void getAnalogInput(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_analog_input_s(dsa, inp, kind, timeout));
    }
    dword getXDigitalInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword inp;
        ERRTRANS();
        ERRCHK(dsa_get_x_digital_input_s(dsa, &inp, kind, timeout));
        return inp;
    }
    void getXDigitalInput(dword *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_x_digital_input_s(dsa, inp, kind, timeout));
    }
    double getXAnalogInput1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double inp;
        ERRTRANS();
        ERRCHK(dsa_get_x_analog_input_1_s(dsa, &inp, kind, timeout));
        return inp;
    }
    void getXAnalogInput1(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_x_analog_input_1_s(dsa, inp, kind, timeout));
    }
    double getXAnalogInput2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double inp;
        ERRTRANS();
        ERRCHK(dsa_get_x_analog_input_2_s(dsa, &inp, kind, timeout));
        return inp;
    }
    void getXAnalogInput2(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_x_analog_input_2_s(dsa, inp, kind, timeout));
    }
    dword getDriveStatus1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_drive_status_1_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getDriveStatus1(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_drive_status_1_s(dsa, mask, kind, timeout));
    }
    dword getDriveStatus2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_drive_status_2_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getDriveStatus2(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_drive_status_2_s(dsa, mask, kind, timeout));
    }
    int getErrorCode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int code;
        ERRTRANS();
        ERRCHK(dsa_get_error_code_s(dsa, &code, kind, timeout));
        return code;
    }
    void getErrorCode(int *code, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_error_code_s(dsa, code, kind, timeout));
    }
    double getCLI2tValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double val;
        ERRTRANS();
        ERRCHK(dsa_get_cl_i2t_value_s(dsa, &val, kind, timeout));
        return val;
    }
    void getCLI2tValue(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_cl_i2t_value_s(dsa, val, kind, timeout));
    }
    int getAxisNumber(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int num;
        ERRTRANS();
        ERRCHK(dsa_get_axis_number_s(dsa, &num, kind, timeout));
        return num;
    }
    void getAxisNumber(int *num, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_axis_number_s(dsa, num, kind, timeout));
    }
    int getDaisyChainNumber(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        int num;
        ERRTRANS();
        ERRCHK(dsa_get_daisy_chain_number_s(dsa, &num, kind, timeout));
        return num;
    }
    void getDaisyChainNumber(int *num, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_daisy_chain_number_s(dsa, num, kind, timeout));
    }
    double getDriveTemperature(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        double temp;
        ERRTRANS();
        ERRCHK(dsa_get_drive_temperature_s(dsa, &temp, kind, timeout));
        return temp;
    }
    void getDriveTemperature(double *temp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_drive_temperature_s(dsa, temp, kind, timeout));
    }
    dword getDriveMaskValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword str;
        ERRTRANS();
        ERRCHK(dsa_get_drive_mask_value_s(dsa, &str, kind, timeout));
        return str;
    }
    void getDriveMaskValue(dword *str, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_drive_mask_value_s(dsa, str, kind, timeout));
    }
    dword getDriveDisplay(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword str;
        ERRTRANS();
        ERRCHK(dsa_get_drive_display_s(dsa, sidx, &str, kind, timeout));
        return str;
    }
    void getDriveDisplay(int sidx, dword *str, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_drive_display_s(dsa, sidx, str, kind, timeout));
    }
    long getDriveSequenceLine(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        long line;
        ERRTRANS();
        ERRCHK(dsa_get_drive_sequence_line_s(dsa, &line, kind, timeout));
        return line;
    }
    void getDriveSequenceLine(long *line, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_drive_sequence_line_s(dsa, line, kind, timeout));
    }
    dword getDriveFuseStatus(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_drive_fuse_status_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getDriveFuseStatus(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_drive_fuse_status_s(dsa, mask, kind, timeout));
    }
    dword getIrqDriveStatus1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_irq_drive_status_1_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getIrqDriveStatus1(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_irq_drive_status_1_s(dsa, mask, kind, timeout));
    }
    dword getIrqDriveStatus2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_irq_drive_status_2_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getIrqDriveStatus2(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_irq_drive_status_2_s(dsa, mask, kind, timeout));
    }
    dword getAckDriveStatus1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_ack_drive_status_1_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getAckDriveStatus1(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_ack_drive_status_1_s(dsa, mask, kind, timeout));
    }
    dword getAckDriveStatus2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_ack_drive_status_2_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getAckDriveStatus2(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_ack_drive_status_2_s(dsa, mask, kind, timeout));
    }
    dword getIrqPendingAxisMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword mask;
        ERRTRANS();
        ERRCHK(dsa_get_irq_pending_axis_mask_s(dsa, &mask, kind, timeout));
        return mask;
    }
    void getIrqPendingAxisMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_irq_pending_axis_mask_s(dsa, mask, kind, timeout));
    }
    dword getCanFeedback1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword val1;
        ERRTRANS();
        ERRCHK(dsa_get_can_feedback_1_s(dsa, &val1, kind, timeout));
        return val1;
    }
    void getCanFeedback1(dword *val1, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_can_feedback_1_s(dsa, val1, kind, timeout));
    }
    dword getCanFeedback2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        dword val1;
        ERRTRANS();
        ERRCHK(dsa_get_can_feedback_2_s(dsa, &val1, kind, timeout));
        return val1;
    }
    void getCanFeedback2(dword *val1, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {
        ERRCHK(dsa_get_can_feedback_2_s(dsa, val1, kind, timeout));
    }


    /*
     * register getter - asynchronous
     */
protected:
    void getPLProportionalGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_proportional_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLProportionalGain(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_proportional_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLSpeedFeedbackGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_speed_feedback_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLSpeedFeedbackGain(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_speed_feedback_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLForceFeedbackGain1(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_force_feedback_gain_1_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLForceFeedbackGain1(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_force_feedback_gain_1_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLIntegratorGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_integrator_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLIntegratorGain(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_integrator_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLAntiWindupGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_anti_windup_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLAntiWindupGain(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_anti_windup_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLIntegratorLimitation(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_integrator_limitation_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLIntegratorLimitation(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_integrator_limitation_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLIntegratorMode(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_integrator_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getPLIntegratorMode(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_integrator_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getPLSpeedFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_speed_filter_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLSpeedFilter(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_speed_filter_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLOutputFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_output_filter_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLOutputFilter(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_output_filter_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLInputFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_input_filter_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLInputFilter(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_input_filter_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getTtlSpecialFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ttl_special_filter_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getTtlSpecialFilter(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ttl_special_filter_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLForceFeedbackGain2(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_force_feedback_gain_2_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLForceFeedbackGain2(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_force_feedback_gain_2_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLSpeedFeedfwdGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_speed_feedfwd_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLSpeedFeedfwdGain(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_speed_feedfwd_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLAccFeedforwardGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_acc_feedforward_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPLAccFeedforwardGain(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pl_acc_feedforward_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLPhaseAdvanceFactor(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_phase_advance_factor_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLPhaseAdvanceFactor(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_phase_advance_factor_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getAprInputFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_apr_input_filter_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getAprInputFilter(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_apr_input_filter_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLPhaseAdvanceShift(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_phase_advance_shift_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLPhaseAdvanceShift(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_phase_advance_shift_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMinPositionRangeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_min_position_range_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMinPositionRangeLimit(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_min_position_range_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMaxPositionRangeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_max_position_range_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMaxPositionRangeLimit(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_max_position_range_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMaxProfileVelocity(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_max_profile_velocity_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMaxProfileVelocity(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_max_profile_velocity_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMaxAcceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_max_acceleration_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMaxAcceleration(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_max_acceleration_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getFollowingErrorWindow(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_following_error_window_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getFollowingErrorWindow(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_following_error_window_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getVelocityErrorLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_velocity_error_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getVelocityErrorLimit(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_velocity_error_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getSwitchLimitMode(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_switch_limit_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getSwitchLimitMode(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_switch_limit_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getEnableInputMode(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_enable_input_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getEnableInputMode(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_enable_input_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getMinSoftPositionLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_min_soft_position_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMinSoftPositionLimit(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_min_soft_position_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMaxSoftPositionLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_max_soft_position_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMaxSoftPositionLimit(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_max_soft_position_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getProfileLimitMode(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_profile_limit_mode_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getProfileLimitMode(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_profile_limit_mode_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getIOErrorEventMask(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_io_error_event_mask_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getIOErrorEventMask(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_io_error_event_mask_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getPositionWindowTime(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_position_window_time_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPositionWindowTime(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_position_window_time_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPositionWindow(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_position_window_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPositionWindow(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_position_window_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingMethod(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_method_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getHomingMethod(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_method_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getHomingZeroSpeed(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_zero_speed_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingZeroSpeed(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_zero_speed_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingAcceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_acceleration_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingAcceleration(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_acceleration_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingFollowingLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_following_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingFollowingLimit(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_following_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_current_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_current_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomeOffset(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_home_offset_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomeOffset(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_home_offset_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingFixedMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_fixed_mvt_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingFixedMvt(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_fixed_mvt_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingSwitchMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_switch_mvt_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingSwitchMvt(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_switch_mvt_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingIndexMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_index_mvt_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingIndexMvt(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_index_mvt_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingFineTuningMode(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_fine_tuning_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getHomingFineTuningMode(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_fine_tuning_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getHomingFineTuningValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_fine_tuning_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getHomingFineTuningValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_homing_fine_tuning_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMotorPhaseCorrection(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_motor_phase_correction_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getMotorPhaseCorrection(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_motor_phase_correction_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getSoftwareCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_software_current_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getSoftwareCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_software_current_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getDriveControlMode(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_control_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getDriveControlMode(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_control_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getDisplayMode(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_display_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getDisplayMode(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_display_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getEncoderInversion(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_inversion_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderInversion(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_inversion_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPdrStepValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pdr_step_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPdrStepValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_pdr_step_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderPhase1Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_phase_1_offset_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderPhase1Offset(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_phase_1_offset_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderPhase2Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_phase_2_offset_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderPhase2Offset(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_phase_2_offset_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderPhase1Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_phase_1_factor_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderPhase1Factor(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_phase_1_factor_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderPhase2Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_phase_2_factor_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderPhase2Factor(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_phase_2_factor_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderPhase3Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_phase_3_offset_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderPhase3Offset(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_phase_3_offset_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderIndexDistance(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_index_distance_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderIndexDistance(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_index_distance_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderPhase3Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_phase_3_factor_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderPhase3Factor(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_phase_3_factor_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLProportionalGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_proportional_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLProportionalGain(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_proportional_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLIntegratorGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_integrator_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLIntegratorGain(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_integrator_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLOutputFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_output_filter_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLOutputFilter(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_output_filter_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_current_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_current_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLI2tCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_i2t_current_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLI2tCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_i2t_current_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLI2tTimeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_i2t_time_limit_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLI2tTimeLimit(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_i2t_time_limit_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLRegenMode(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_regen_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getCLRegenMode(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_regen_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getInitMode(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_mode_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getInitMode(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_mode_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getInitPulseLevel(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_pulse_level_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitPulseLevel(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_pulse_level_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitMaxCurrent(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_max_current_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitMaxCurrent(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_max_current_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitFinalPhase(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_final_phase_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitFinalPhase(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_final_phase_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitTime(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_time_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitTime(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_time_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitCurrentRate(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_current_rate_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitCurrentRate(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_current_rate_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitPhaseRate(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_phase_rate_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitPhaseRate(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_phase_rate_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitInitialPhase(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_initial_phase_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInitInitialPhase(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_init_initial_phase_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getDriveFuseChecking(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_fuse_checking_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDriveFuseChecking(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_fuse_checking_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getMotorTempChecking(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_motor_temp_checking_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getMotorTempChecking(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_motor_temp_checking_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getMonSourceType(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mon_source_type_a(dsa, sidx, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getMonSourceType(int sidx, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mon_source_type_a(dsa, sidx, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getMonSourceIndex(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mon_source_index_a(dsa, sidx, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getMonSourceIndex(int sidx, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mon_source_index_a(dsa, sidx, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getMonDestIndex(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mon_dest_index_a(dsa, sidx, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getMonDestIndex(int sidx, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mon_dest_index_a(dsa, sidx, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getMonOffset(int sidx, int kind, DsaLongHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mon_offset_a(dsa, sidx, kind, (DSA_LONG_HANDLER)handler, param));
    }
    void getMonOffset(int sidx, DsaLongHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mon_offset_a(dsa, sidx, GET_CURRENT, (DSA_LONG_HANDLER)handler, param));
    }
    void getMonGain(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mon_gain_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMonGain(int sidx, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mon_gain_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getXAnalogOffset(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_analog_offset_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getXAnalogOffset(int sidx, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_analog_offset_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getXAnalogGain(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_analog_gain_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getXAnalogGain(int sidx, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_analog_gain_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getSyncroInputMask(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_syncro_input_mask_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getSyncroInputMask(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_syncro_input_mask_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getSyncroInputValue(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_syncro_input_value_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getSyncroInputValue(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_syncro_input_value_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getSyncroOutputMask(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_syncro_output_mask_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getSyncroOutputMask(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_syncro_output_mask_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getSyncroOutputValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_syncro_output_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getSyncroOutputValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_syncro_output_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getSyncroStartTimeout(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_syncro_start_timeout_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getSyncroStartTimeout(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_syncro_start_timeout_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getDigitalOutput(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_digital_output_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDigitalOutput(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_digital_output_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getXDigitalOutput(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_digital_output_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getXDigitalOutput(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_digital_output_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getXAnalogOutput1(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_analog_output_1_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getXAnalogOutput1(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_analog_output_1_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getXAnalogOutput2(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_analog_output_2_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getXAnalogOutput2(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_analog_output_2_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getAnalogOutput(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_analog_output_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getAnalogOutput(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_analog_output_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getInterruptMask1(int sidx, int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_interrupt_mask_1_a(dsa, sidx, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getInterruptMask1(int sidx, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_interrupt_mask_1_a(dsa, sidx, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getInterruptMask2(int sidx, int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_interrupt_mask_2_a(dsa, sidx, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getInterruptMask2(int sidx, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_interrupt_mask_2_a(dsa, sidx, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getTriggerIrqMask(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_trigger_irq_mask_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getTriggerIrqMask(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_trigger_irq_mask_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getTriggerIOMask(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_trigger_io_mask_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getTriggerIOMask(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_trigger_io_mask_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getTriggerMapOffset(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_trigger_map_offset_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getTriggerMapOffset(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_trigger_map_offset_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getTriggerMapSize(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_trigger_map_size_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getTriggerMapSize(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_trigger_map_size_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getRealtimeEnabledGlobal(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_realtime_enabled_global_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getRealtimeEnabledGlobal(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_realtime_enabled_global_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getRealtimeValidMask(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_realtime_valid_mask_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getRealtimeValidMask(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_realtime_valid_mask_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getRealtimeEnabledMask(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_realtime_enabled_mask_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getRealtimeEnabledMask(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_realtime_enabled_mask_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getRealtimePendingMask(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_realtime_pending_mask_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getRealtimePendingMask(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_realtime_pending_mask_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getEblBaudrate(int kind, DsaLongHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ebl_baudrate_a(dsa, kind, (DSA_LONG_HANDLER)handler, param));
    }
    void getEblBaudrate(DsaLongHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ebl_baudrate_a(dsa, GET_CURRENT, (DSA_LONG_HANDLER)handler, param));
    }
    void getIndirectAxisNumber(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_indirect_axis_number_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getIndirectAxisNumber(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_indirect_axis_number_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getIndirectRegisterIdx(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_indirect_register_idx_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getIndirectRegisterIdx(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_indirect_register_idx_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getIndirectRegisterSidx(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_indirect_register_sidx_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getIndirectRegisterSidx(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_indirect_register_sidx_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getConcatenatedMvt(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_concatenated_mvt_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getConcatenatedMvt(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_concatenated_mvt_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getProfileType(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_profile_type_a(dsa, sidx, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getProfileType(int sidx, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_profile_type_a(dsa, sidx, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getMvtLktNumber(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mvt_lkt_number_a(dsa, sidx, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getMvtLktNumber(int sidx, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mvt_lkt_number_a(dsa, sidx, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getMvtLktTime(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mvt_lkt_time_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMvtLktTime(int sidx, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_mvt_lkt_time_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCameValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_came_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCameValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_came_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getBrakeDeceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_brake_deceleration_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getBrakeDeceleration(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_brake_deceleration_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getTargetPosition(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_target_position_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getTargetPosition(int sidx, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_target_position_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getProfileVelocity(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_profile_velocity_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getProfileVelocity(int sidx, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_profile_velocity_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getProfileAcceleration(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_profile_acceleration_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getProfileAcceleration(int sidx, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_profile_acceleration_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getJerkTime(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_jerk_time_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getJerkTime(int sidx, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_jerk_time_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getProfileDeceleration(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_profile_deceleration_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getProfileDeceleration(int sidx, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_profile_deceleration_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEndVelocity(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_end_velocity_a(dsa, sidx, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEndVelocity(int sidx, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_end_velocity_a(dsa, sidx, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCtrlSourceType(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ctrl_source_type_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getCtrlSourceType(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ctrl_source_type_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getCtrlSourceIndex(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ctrl_source_index_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getCtrlSourceIndex(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ctrl_source_index_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getCtrlShiftFactor(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ctrl_shift_factor_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getCtrlShiftFactor(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ctrl_shift_factor_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getCtrlOffset(int kind, DsaLongHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ctrl_offset_a(dsa, kind, (DSA_LONG_HANDLER)handler, param));
    }
    void getCtrlOffset(DsaLongHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ctrl_offset_a(dsa, GET_CURRENT, (DSA_LONG_HANDLER)handler, param));
    }
    void getCtrlGain(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ctrl_gain_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCtrlGain(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ctrl_gain_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMotorKTFactor(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_motor_kt_factor_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getMotorKTFactor(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_motor_kt_factor_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPositionCtrlError(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_position_ctrl_error_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPositionCtrlError(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_position_ctrl_error_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPositionMaxError(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_position_max_error_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPositionMaxError(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_position_max_error_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPositionDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_position_demand_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPositionDemandValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_position_demand_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPositionActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_position_actual_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getPositionActualValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_position_actual_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getVelocityDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_velocity_demand_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getVelocityDemandValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_velocity_demand_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getVelocityActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_velocity_actual_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getVelocityActualValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_velocity_actual_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getAccDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_acc_demand_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getAccDemandValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_acc_demand_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getAccActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_acc_actual_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getAccActualValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_acc_actual_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getRefDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ref_demand_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getRefDemandValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ref_demand_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getDriveControlMask(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_control_mask_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDriveControlMask(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_control_mask_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getCLCurrentPhase1(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_current_phase_1_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLCurrentPhase1(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_current_phase_1_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLCurrentPhase2(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_current_phase_2_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLCurrentPhase2(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_current_phase_2_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLCurrentPhase3(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_current_phase_3_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLCurrentPhase3(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_current_phase_3_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLLktPhase1(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_lkt_phase_1_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLLktPhase1(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_lkt_phase_1_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLLktPhase2(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_lkt_phase_2_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLLktPhase2(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_lkt_phase_2_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLLktPhase3(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_lkt_phase_3_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLLktPhase3(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_lkt_phase_3_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_demand_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLDemandValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_demand_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_actual_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLActualValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_actual_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderSineSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_sine_signal_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderSineSignal(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_sine_signal_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderCosineSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_cosine_signal_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderCosineSignal(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_cosine_signal_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderIndexSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_index_signal_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderIndexSignal(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_index_signal_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderHall1Signal(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_hall_1_signal_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderHall1Signal(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_hall_1_signal_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderHall2Signal(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_hall_2_signal_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderHall2Signal(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_hall_2_signal_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderHall3Signal(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_hall_3_signal_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderHall3Signal(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_hall_3_signal_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getEncoderHallDigSignal(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_hall_dig_signal_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getEncoderHallDigSignal(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_encoder_hall_dig_signal_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDigitalInput(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_digital_input_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDigitalInput(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_digital_input_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getAnalogInput(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_analog_input_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getAnalogInput(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_analog_input_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getXDigitalInput(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_digital_input_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getXDigitalInput(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_digital_input_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getXAnalogInput1(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_analog_input_1_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getXAnalogInput1(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_analog_input_1_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getXAnalogInput2(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_analog_input_2_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getXAnalogInput2(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_x_analog_input_2_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getDriveStatus1(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_status_1_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDriveStatus1(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_status_1_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDriveStatus2(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_status_2_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDriveStatus2(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_status_2_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getErrorCode(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_error_code_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getErrorCode(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_error_code_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getCLI2tValue(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_i2t_value_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getCLI2tValue(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_cl_i2t_value_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getAxisNumber(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_axis_number_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getAxisNumber(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_axis_number_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getDaisyChainNumber(int kind, DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_daisy_chain_number_a(dsa, kind, (DSA_INT_HANDLER)handler, param));
    }
    void getDaisyChainNumber(DsaIntHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_daisy_chain_number_a(dsa, GET_CURRENT, (DSA_INT_HANDLER)handler, param));
    }
    void getDriveTemperature(int kind, DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_temperature_a(dsa, kind, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getDriveTemperature(DsaDoubleHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_temperature_a(dsa, GET_CURRENT, (DSA_DOUBLE_HANDLER)handler, param));
    }
    void getDriveMaskValue(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_mask_value_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDriveMaskValue(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_mask_value_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDriveDisplay(int sidx, int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_display_a(dsa, sidx, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDriveDisplay(int sidx, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_display_a(dsa, sidx, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDriveSequenceLine(int kind, DsaLongHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_sequence_line_a(dsa, kind, (DSA_LONG_HANDLER)handler, param));
    }
    void getDriveSequenceLine(DsaLongHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_sequence_line_a(dsa, GET_CURRENT, (DSA_LONG_HANDLER)handler, param));
    }
    void getDriveFuseStatus(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_fuse_status_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getDriveFuseStatus(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_drive_fuse_status_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getIrqDriveStatus1(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_irq_drive_status_1_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getIrqDriveStatus1(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_irq_drive_status_1_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getIrqDriveStatus2(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_irq_drive_status_2_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getIrqDriveStatus2(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_irq_drive_status_2_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getAckDriveStatus1(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ack_drive_status_1_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getAckDriveStatus1(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ack_drive_status_1_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getAckDriveStatus2(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ack_drive_status_2_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getAckDriveStatus2(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_ack_drive_status_2_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getIrqPendingAxisMask(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_irq_pending_axis_mask_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getIrqPendingAxisMask(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_irq_pending_axis_mask_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getCanFeedback1(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_can_feedback_1_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getCanFeedback1(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_can_feedback_1_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }
    void getCanFeedback2(int kind, DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_can_feedback_2_a(dsa, kind, (DSA_DWORD_HANDLER)handler, param));
    }
    void getCanFeedback2(DsaDWordHandler handler, void *param = NULL) {
        ERRCHK(dsa_get_can_feedback_2_a(dsa, GET_CURRENT, (DSA_DWORD_HANDLER)handler, param));
    }

};


/**
 * DsaDeviceBase class - C++
 */
class DsaDeviceBase: public DsaBase {
	friend class Dsa;

	/* constructors */
protected:
	DsaDeviceBase(void) {
	}
	DsaDeviceBase(DSA_DEVICE_BASE *dev) {
		ERRCHK(dsa_share(dev));
		dsa = dev;
	}
public:
	DsaDeviceBase(DsaDeviceBase &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaDeviceBase(DsaBase &obj) {
		if (!dsa_is_valid_device_base(obj.dsa))
			throw bad_cast("cannot cast to DsaDeviceBase");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}

	/* operators */
public:
	DsaDeviceBase operator = (DsaDeviceBase &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaDeviceBase operator = (DsaBase &obj) {
		if (!dsa_is_valid_device_base(obj.dsa))
			throw bad_cast("cannot cast to DsaDeviceBase");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* functions */
	#ifdef DSA_IMPL_S
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

	#endif /* DSA_IMPL_S */
	#ifdef DSA_IMPL_A
    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

	#endif /* DSA_IMPL_A */
    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */


	/* register getters */


};


/**
 * DsaHandlerDeviceBase class - C++
 */
class DsaHandlerDeviceBase: public DsaDeviceBase {
	/* constructors - destructors */
protected:
	DsaHandlerDeviceBase(void) {}
	DsaHandlerDeviceBase(DsaHandlerDeviceBase &obj) {}
public:
	~DsaHandlerDeviceBase(void) {
        if (dsa)
			ERRCHK(dsa_share(dsa));
	}
	/* operators */
protected:
	DsaHandlerDeviceBase operator = (DsaHandlerDeviceBase &obj) {
		return obj;
	}
};


/**
 * DsaDevice class - C++
 */
class DsaDevice: public DsaBase {
	/* constructors */
protected:
	DsaDevice(void) {
	}
public:
	DsaDevice(DsaDevice &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaDevice(DsaBase &obj) {
		if (!dsa_is_valid_device(obj.dsa))
			throw bad_cast("cannot cast to DsaDevice");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	/* operators */
public:
	DsaDevice operator = (DsaDevice &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaDevice operator = (DsaBase &obj) {
		if (!dsa_is_valid_device(obj.dsa))
			throw bad_cast("cannot cast to DsaDeviceBase");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* functions */
	#ifdef DSA_IMPL_S
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    int  getWarningCode(int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getWarningCode(kind, timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    long  getRegister(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegister(typ, idx, sidx, kind, timeout);}
    void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    double  getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, timeout);}
    void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, long timeout = DEF_TIMEOUT) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, timeout);}
    DsaStatus  waitStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusEqual(mask, ref, timeout);}
    DsaStatus  waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusNotEqual(mask, ref, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    DsaStatus  waitStatusChange(DsaStatus *mask, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusChange(mask, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

	#endif /* DSA_IMPL_S */
	#ifdef DSA_IMPL_A
    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void getWarningCode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getWarningCode(kind, handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void getRegister(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getRegister(typ, idx, sidx, kind, handler, param);}
    void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, handler, param);}
    void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, Dsa2intHandler handler, void *param = NULL) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, handler, param);}
    void waitStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusEqual(mask, ref, handler, param);}
    void waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusNotEqual(mask, ref, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void waitStatusChange(DsaStatus *mask, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusChange(mask, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

	#endif /* DSA_IMPL_A */
    void open(EtbBus etb, int axis) {DsaBase::open(etb, axis);}
    void open(char_cp url) {DsaBase::open(url);}
    void open(EtbBus etb, int axis, dword flags) {DsaBase::open(etb, axis, flags);}
    void reset() {DsaBase::reset();}
    void close() {DsaBase::close();}
    EtbBus  getEtbBus() {return DsaBase::getEtbBus();}
    int  getEtbAxis() {return DsaBase::getEtbAxis();}
    bool  isOpen() {return DsaBase::isOpen();}
    int getMotorTyp() {return DsaBase::getMotorTyp();}
    void getErrorText(char_p text, int size, int code) {DsaBase::getErrorText(text, size, code);}
    void getWarningText(char_p text, int size, int code) {DsaBase::getWarningText(text, size, code);}
    double  convertToIso(long inc, int conv) {return DsaBase::convertToIso(inc, conv);}
    long  convertFromIso(double iso, int conv) {return DsaBase::convertFromIso(iso, conv);}
    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    DsaInfo  getInfo() {return DsaBase::getInfo();}
    DsaStatus  getStatus() {return DsaBase::getStatus();}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    DsaStatus  getStatusFromDrive(long timeout = DEF_TIMEOUT) {return DsaBase::getStatusFromDrive(timeout);}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}
    DsaXInfo  getXInfo() {return DsaBase::getXInfo();}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */


	/* register getters */


};


/**
 * DsaDeviceGroup class - C++
 */
class DsaDeviceGroup: public DsaBase {
	/* constructors */
private:
    void _Group(int max, ...) {
        va_list arg;
        va_start(arg, max);
        ERRCHK(dsa_create_device_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
        va_end(arg);
    }
protected:
	DsaDeviceGroup(void) {
	}
public:
	DsaDeviceGroup(DsaDeviceGroup &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaDeviceGroup(DsaBase &obj) {
		if (!dsa_is_valid_device_group(obj.dsa))
			throw bad_cast("cannot cast to DsaDevice");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
    DsaDeviceGroup(int max, ...) {
        va_list arg;
        va_start(arg, max);
        ERRCHK(dsa_create_device_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
        va_end(arg);
    }       
    DsaDeviceGroup(int max, DsaDeviceBase *list[]) {
        ERRCHK(dsa_create_device_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, list[i]->dsa));
	}
    DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2) { 
        _Group(2, &d1, &d2); 
    }
    DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2, DsaDeviceBase d3) { 
        _Group(3, &d1, &d2, &d3); 
    }
    DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2, DsaDeviceBase d3, DsaDeviceBase d4) { 
        _Group(4, &d1, &d2, &d3, &d4); 
    }
    DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2, DsaDeviceBase d3, DsaDeviceBase d4, DsaDeviceBase d5) { 
        _Group(5, &d1, &d2, &d3, &d4, &d5); 
    }
    DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2, DsaDeviceBase d3, DsaDeviceBase d4, DsaDeviceBase d5, DsaDeviceBase d6) { 
        _Group(6, &d1, &d2, &d3, &d4, &d5, &d6); 
    }
    DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2, DsaDeviceBase d3, DsaDeviceBase d4, DsaDeviceBase d5, DsaDeviceBase d6, DsaDeviceBase d7) { 
        _Group(7, &d1, &d2, &d3, &d4, &d5, &d6, &d7); 
    }
    DsaDeviceGroup(DsaDeviceBase d1, DsaDeviceBase d2, DsaDeviceBase d3, DsaDeviceBase d4, DsaDeviceBase d5, DsaDeviceBase d6, DsaDeviceBase d7, DsaDeviceBase d8) { 
        _Group(8, &d1, &d2, &d3, &d4, &d5, &d6, &d7, &d8); 
    }
	/* operators */
public:
	DsaDeviceGroup operator = (DsaDeviceGroup &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaDeviceGroup operator = (DsaBase &obj) {
		if (!dsa_is_valid_device_group(obj.dsa))
			throw bad_cast("cannot cast to DsaDeviceBase");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* special functions */
public:
	DsaDeviceBase getGroupItem(int pos) {return DsaBase::getGroupItem(pos);}
	/* functions */
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    int  getGroupSize() {return DsaBase::getGroupSize();}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */


	/* register getters */


};


/**
 * DsaDriveBase class - C++
 */
class DsaDriveBase: public DsaBase {
	/* constructors */
protected:
	DsaDriveBase(void) {
	}
public:
	DsaDriveBase(DsaDriveBase &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaDriveBase(DsaBase &obj) {
		if (!dsa_is_valid_drive_base(obj.dsa))
			throw bad_cast("cannot cast to DsaDriveBase");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	/* operators */
public:
	DsaDriveBase operator = (DsaDriveBase &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaDriveBase operator = (DsaBase &obj) {
		if (!dsa_is_valid_drive_base(obj.dsa))
			throw bad_cast("cannot cast to DsaDriveBase");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* functions */
    void powerOn(long timeout = DEF_TIMEOUT) {DsaBase::powerOn(timeout);}
    void powerOff(long timeout = DEF_TIMEOUT) {DsaBase::powerOff(timeout);}
    void newSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::newSetpoint(sidx, flags, timeout);}
    void changeSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::changeSetpoint(sidx, flags, timeout);}
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    void homingStart(long timeout = DEF_TIMEOUT) {DsaBase::homingStart(timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

    void powerOn(DsaHandler handler, void *param = NULL) {DsaBase::powerOn(handler, param);}
    void powerOff(DsaHandler handler, void *param = NULL) {DsaBase::powerOff(handler, param);}
    void newSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::newSetpoint(sidx, flags, handler, param);}
    void changeSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::changeSetpoint(sidx, flags, handler, param);}
    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void homingStart(DsaHandler handler, void *param = NULL) {DsaBase::homingStart(handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void stepMotion(double pos, long timeout = DEF_TIMEOUT) {DsaBase::stepMotion(pos, timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void canCommand1(dword val1, dword val2, long timeout = DEF_TIMEOUT) {DsaBase::canCommand1(val1, val2, timeout);}
    void canCommand2(dword val1, dword val2, long timeout = DEF_TIMEOUT) {DsaBase::canCommand2(val1, val2, timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void stepMotion(double pos, DsaHandler handler, void *param = NULL) {DsaBase::stepMotion(pos, handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void canCommand1(dword val1, dword val2, DsaHandler handler, void *param = NULL) {DsaBase::canCommand1(val1, val2, handler, param);}
    void canCommand2(dword val1, dword val2, DsaHandler handler, void *param = NULL) {DsaBase::canCommand2(val1, val2, handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */
    void setPLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLProportionalGain(gain, timeout);}
    void setPLSpeedFeedbackGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedbackGain(gain, timeout);}
    void setPLForceFeedbackGain1(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLForceFeedbackGain1(gain, timeout);}
    void setPLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorGain(gain, timeout);}
    void setPLAntiWindupGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLAntiWindupGain(gain, timeout);}
    void setPLIntegratorLimitation(double limit, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorLimitation(limit, timeout);}
    void setPLIntegratorMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorMode(mode, timeout);}
    void setPLSpeedFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFilter(tim, timeout);}
    void setPLOutputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPLOutputFilter(tim, timeout);}
    void setCLInputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLInputFilter(tim, timeout);}
    void setTtlSpecialFilter(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setTtlSpecialFilter(factor, timeout);}
    void setPLForceFeedbackGain2(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLForceFeedbackGain2(factor, timeout);}
    void setPLSpeedFeedfwdGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedfwdGain(factor, timeout);}
    void setPLAccFeedforwardGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLAccFeedforwardGain(factor, timeout);}
    void setCLPhaseAdvanceFactor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCLPhaseAdvanceFactor(factor, timeout);}
    void setAprInputFilter(double time, long timeout = DEF_TIMEOUT) {DsaBase::setAprInputFilter(time, timeout);}
    void setCLPhaseAdvanceShift(double shift, long timeout = DEF_TIMEOUT) {DsaBase::setCLPhaseAdvanceShift(shift, timeout);}
    void setMinPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinPositionRangeLimit(pos, timeout);}
    void setMaxPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxPositionRangeLimit(pos, timeout);}
    void setMaxProfileVelocity(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setMaxProfileVelocity(vel, timeout);}
    void setMaxAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setMaxAcceleration(acc, timeout);}
    void setFollowingErrorWindow(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setFollowingErrorWindow(pos, timeout);}
    void setVelocityErrorLimit(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setVelocityErrorLimit(vel, timeout);}
    void setSwitchLimitMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setSwitchLimitMode(mode, timeout);}
    void setEnableInputMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setEnableInputMode(mode, timeout);}
    void setMinSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinSoftPositionLimit(pos, timeout);}
    void setMaxSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxSoftPositionLimit(pos, timeout);}
    void setProfileLimitMode(dword flags, long timeout = DEF_TIMEOUT) {DsaBase::setProfileLimitMode(flags, timeout);}
    void setIOErrorEventMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setIOErrorEventMask(mask, timeout);}
    void setPositionWindowTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindowTime(tim, timeout);}
    void setPositionWindow(double win, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindow(win, timeout);}
    void setHomingMethod(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingMethod(mode, timeout);}
    void setHomingZeroSpeed(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setHomingZeroSpeed(vel, timeout);}
    void setHomingAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setHomingAcceleration(acc, timeout);}
    void setHomingFollowingLimit(double win, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFollowingLimit(win, timeout);}
    void setHomingCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setHomingCurrentLimit(cur, timeout);}
    void setHomeOffset(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomeOffset(pos, timeout);}
    void setHomingFixedMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFixedMvt(pos, timeout);}
    void setHomingSwitchMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingSwitchMvt(pos, timeout);}
    void setHomingIndexMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingIndexMvt(pos, timeout);}
    void setHomingFineTuningMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningMode(mode, timeout);}
    void setHomingFineTuningValue(double phase, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningValue(phase, timeout);}
    void setMotorPhaseCorrection(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setMotorPhaseCorrection(mode, timeout);}
    void setSoftwareCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setSoftwareCurrentLimit(cur, timeout);}
    void setDriveControlMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDriveControlMode(mode, timeout);}
    void setDisplayMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDisplayMode(mode, timeout);}
    void setEncoderInversion(double invert, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderInversion(invert, timeout);}
    void setPdrStepValue(double step, long timeout = DEF_TIMEOUT) {DsaBase::setPdrStepValue(step, timeout);}
    void setEncoderPhase1Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Offset(offset, timeout);}
    void setEncoderPhase2Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Offset(offset, timeout);}
    void setEncoderPhase1Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Factor(factor, timeout);}
    void setEncoderPhase2Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Factor(factor, timeout);}
    void setEncoderPhase3Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase3Offset(offset, timeout);}
    void setEncoderIndexDistance(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderIndexDistance(pos, timeout);}
    void setEncoderPhase3Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase3Factor(factor, timeout);}
    void setCLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLProportionalGain(gain, timeout);}
    void setCLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLIntegratorGain(gain, timeout);}
    void setCLOutputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLOutputFilter(tim, timeout);}
    void setCLCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLCurrentLimit(cur, timeout);}
    void setCLI2tCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tCurrentLimit(cur, timeout);}
    void setCLI2tTimeLimit(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tTimeLimit(tim, timeout);}
    void setCLRegenMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setCLRegenMode(mode, timeout);}
    void setInitMode(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setInitMode(typ, timeout);}
    void setInitPulseLevel(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitPulseLevel(cur, timeout);}
    void setInitMaxCurrent(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitMaxCurrent(cur, timeout);}
    void setInitFinalPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitFinalPhase(cal, timeout);}
    void setInitTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setInitTime(tim, timeout);}
    void setInitCurrentRate(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitCurrentRate(cur, timeout);}
    void setInitPhaseRate(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitPhaseRate(cal, timeout);}
    void setInitInitialPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitInitialPhase(cal, timeout);}
    void setDriveFuseChecking(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setDriveFuseChecking(mask, timeout);}
    void setMotorTempChecking(dword val, long timeout = DEF_TIMEOUT) {DsaBase::setMotorTempChecking(val, timeout);}
    void setMonSourceType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceType(sidx, typ, timeout);}
    void setMonSourceIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceIndex(sidx, index, timeout);}
    void setMonDestIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonDestIndex(sidx, index, timeout);}
    void setMonOffset(int sidx, long offset, long timeout = DEF_TIMEOUT) {DsaBase::setMonOffset(sidx, offset, timeout);}
    void setMonGain(int sidx, double gain, long timeout = DEF_TIMEOUT) {DsaBase::setMonGain(sidx, gain, timeout);}
    void setXAnalogOffset(int sidx, double offset, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOffset(sidx, offset, timeout);}
    void setXAnalogGain(int sidx, double gain, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogGain(sidx, gain, timeout);}
    void setSyncroInputMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroInputMask(mask, timeout);}
    void setSyncroInputValue(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroInputValue(mask, timeout);}
    void setSyncroOutputMask(double mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroOutputMask(mask, timeout);}
    void setSyncroOutputValue(double mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroOutputValue(mask, timeout);}
    void setSyncroStartTimeout(int tim, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroStartTimeout(tim, timeout);}
    void setDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setDigitalOutput(out, timeout);}
    void setXDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setXDigitalOutput(out, timeout);}
    void setXAnalogOutput1(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput1(out, timeout);}
    void setXAnalogOutput2(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput2(out, timeout);}
    void setAnalogOutput(double out, long timeout = DEF_TIMEOUT) {DsaBase::setAnalogOutput(out, timeout);}
    void setInterruptMask1(int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setInterruptMask1(sidx, mask, timeout);}
    void setInterruptMask2(int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setInterruptMask2(sidx, mask, timeout);}
    void setTriggerIrqMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerIrqMask(mask, timeout);}
    void setTriggerIOMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerIOMask(mask, timeout);}
    void setTriggerMapOffset(int offset, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerMapOffset(offset, timeout);}
    void setTriggerMapSize(int size, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerMapSize(size, timeout);}
    void setRealtimeEnabledGlobal(int enable, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeEnabledGlobal(enable, timeout);}
    void setRealtimeValidMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeValidMask(mask, timeout);}
    void setRealtimeEnabledMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeEnabledMask(mask, timeout);}
    void setRealtimePendingMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimePendingMask(mask, timeout);}
    void setEblBaudrate(long baud, long timeout = DEF_TIMEOUT) {DsaBase::setEblBaudrate(baud, timeout);}
    void setIndirectAxisNumber(int axis, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectAxisNumber(axis, timeout);}
    void setIndirectRegisterIdx(int idx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterIdx(idx, timeout);}
    void setIndirectRegisterSidx(int sidx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterSidx(sidx, timeout);}
    void setConcatenatedMvt(int concat, long timeout = DEF_TIMEOUT) {DsaBase::setConcatenatedMvt(concat, timeout);}
    void setProfileType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setProfileType(sidx, typ, timeout);}
    void setMvtLktNumber(int sidx, int number, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktNumber(sidx, number, timeout);}
    void setMvtLktTime(int sidx, double time, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktTime(sidx, time, timeout);}
    void setCameValue(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCameValue(factor, timeout);}
    void setBrakeDeceleration(double dec, long timeout = DEF_TIMEOUT) {DsaBase::setBrakeDeceleration(dec, timeout);}
    void setTargetPosition(int sidx, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTargetPosition(sidx, pos, timeout);}
    void setProfileVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setProfileVelocity(sidx, vel, timeout);}
    void setProfileAcceleration(int sidx, double acc, long timeout = DEF_TIMEOUT) {DsaBase::setProfileAcceleration(sidx, acc, timeout);}
    void setJerkTime(int sidx, double tim, long timeout = DEF_TIMEOUT) {DsaBase::setJerkTime(sidx, tim, timeout);}
    void setProfileDeceleration(int sidx, double dec, long timeout = DEF_TIMEOUT) {DsaBase::setProfileDeceleration(sidx, dec, timeout);}
    void setEndVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setEndVelocity(sidx, vel, timeout);}
    void setCtrlSourceType(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceType(typ, timeout);}
    void setCtrlSourceIndex(int index, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceIndex(index, timeout);}
    void setCtrlShiftFactor(int shift, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlShiftFactor(shift, timeout);}
    void setCtrlOffset(long offset, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlOffset(offset, timeout);}
    void setCtrlGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlGain(gain, timeout);}
    void setMotorKTFactor(double kt, long timeout = DEF_TIMEOUT) {DsaBase::setMotorKTFactor(kt, timeout);}

    void setPLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLProportionalGain(gain, handler, param);}
    void setPLSpeedFeedbackGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedbackGain(gain, handler, param);}
    void setPLForceFeedbackGain1(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLForceFeedbackGain1(gain, handler, param);}
    void setPLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorGain(gain, handler, param);}
    void setPLAntiWindupGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLAntiWindupGain(gain, handler, param);}
    void setPLIntegratorLimitation(double limit, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorLimitation(limit, handler, param);}
    void setPLIntegratorMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorMode(mode, handler, param);}
    void setPLSpeedFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFilter(tim, handler, param);}
    void setPLOutputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPLOutputFilter(tim, handler, param);}
    void setCLInputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLInputFilter(tim, handler, param);}
    void setTtlSpecialFilter(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setTtlSpecialFilter(factor, handler, param);}
    void setPLForceFeedbackGain2(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLForceFeedbackGain2(factor, handler, param);}
    void setPLSpeedFeedfwdGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedfwdGain(factor, handler, param);}
    void setPLAccFeedforwardGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLAccFeedforwardGain(factor, handler, param);}
    void setCLPhaseAdvanceFactor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCLPhaseAdvanceFactor(factor, handler, param);}
    void setAprInputFilter(double time, DsaHandler handler, void *param = NULL) {DsaBase::setAprInputFilter(time, handler, param);}
    void setCLPhaseAdvanceShift(double shift, DsaHandler handler, void *param = NULL) {DsaBase::setCLPhaseAdvanceShift(shift, handler, param);}
    void setMinPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinPositionRangeLimit(pos, handler, param);}
    void setMaxPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxPositionRangeLimit(pos, handler, param);}
    void setMaxProfileVelocity(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setMaxProfileVelocity(vel, handler, param);}
    void setMaxAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setMaxAcceleration(acc, handler, param);}
    void setFollowingErrorWindow(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setFollowingErrorWindow(pos, handler, param);}
    void setVelocityErrorLimit(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setVelocityErrorLimit(vel, handler, param);}
    void setSwitchLimitMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setSwitchLimitMode(mode, handler, param);}
    void setEnableInputMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setEnableInputMode(mode, handler, param);}
    void setMinSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinSoftPositionLimit(pos, handler, param);}
    void setMaxSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxSoftPositionLimit(pos, handler, param);}
    void setProfileLimitMode(dword flags, DsaHandler handler, void *param = NULL) {DsaBase::setProfileLimitMode(flags, handler, param);}
    void setIOErrorEventMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setIOErrorEventMask(mask, handler, param);}
    void setPositionWindowTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindowTime(tim, handler, param);}
    void setPositionWindow(double win, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindow(win, handler, param);}
    void setHomingMethod(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingMethod(mode, handler, param);}
    void setHomingZeroSpeed(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setHomingZeroSpeed(vel, handler, param);}
    void setHomingAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setHomingAcceleration(acc, handler, param);}
    void setHomingFollowingLimit(double win, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFollowingLimit(win, handler, param);}
    void setHomingCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setHomingCurrentLimit(cur, handler, param);}
    void setHomeOffset(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomeOffset(pos, handler, param);}
    void setHomingFixedMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFixedMvt(pos, handler, param);}
    void setHomingSwitchMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingSwitchMvt(pos, handler, param);}
    void setHomingIndexMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingIndexMvt(pos, handler, param);}
    void setHomingFineTuningMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningMode(mode, handler, param);}
    void setHomingFineTuningValue(double phase, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningValue(phase, handler, param);}
    void setMotorPhaseCorrection(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setMotorPhaseCorrection(mode, handler, param);}
    void setSoftwareCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setSoftwareCurrentLimit(cur, handler, param);}
    void setDriveControlMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDriveControlMode(mode, handler, param);}
    void setDisplayMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDisplayMode(mode, handler, param);}
    void setEncoderInversion(double invert, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderInversion(invert, handler, param);}
    void setPdrStepValue(double step, DsaHandler handler, void *param = NULL) {DsaBase::setPdrStepValue(step, handler, param);}
    void setEncoderPhase1Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Offset(offset, handler, param);}
    void setEncoderPhase2Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Offset(offset, handler, param);}
    void setEncoderPhase1Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Factor(factor, handler, param);}
    void setEncoderPhase2Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Factor(factor, handler, param);}
    void setEncoderPhase3Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase3Offset(offset, handler, param);}
    void setEncoderIndexDistance(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderIndexDistance(pos, handler, param);}
    void setEncoderPhase3Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase3Factor(factor, handler, param);}
    void setCLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLProportionalGain(gain, handler, param);}
    void setCLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLIntegratorGain(gain, handler, param);}
    void setCLOutputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLOutputFilter(tim, handler, param);}
    void setCLCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLCurrentLimit(cur, handler, param);}
    void setCLI2tCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tCurrentLimit(cur, handler, param);}
    void setCLI2tTimeLimit(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tTimeLimit(tim, handler, param);}
    void setCLRegenMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setCLRegenMode(mode, handler, param);}
    void setInitMode(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setInitMode(typ, handler, param);}
    void setInitPulseLevel(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitPulseLevel(cur, handler, param);}
    void setInitMaxCurrent(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitMaxCurrent(cur, handler, param);}
    void setInitFinalPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitFinalPhase(cal, handler, param);}
    void setInitTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setInitTime(tim, handler, param);}
    void setInitCurrentRate(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitCurrentRate(cur, handler, param);}
    void setInitPhaseRate(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitPhaseRate(cal, handler, param);}
    void setInitInitialPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitInitialPhase(cal, handler, param);}
    void setDriveFuseChecking(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setDriveFuseChecking(mask, handler, param);}
    void setMotorTempChecking(dword val, DsaHandler handler, void *param = NULL) {DsaBase::setMotorTempChecking(val, handler, param);}
    void setMonSourceType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceType(sidx, typ, handler, param);}
    void setMonSourceIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceIndex(sidx, index, handler, param);}
    void setMonDestIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonDestIndex(sidx, index, handler, param);}
    void setMonOffset(int sidx, long offset, DsaHandler handler, void *param = NULL) {DsaBase::setMonOffset(sidx, offset, handler, param);}
    void setMonGain(int sidx, double gain, DsaHandler handler, void *param = NULL) {DsaBase::setMonGain(sidx, gain, handler, param);}
    void setXAnalogOffset(int sidx, double offset, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOffset(sidx, offset, handler, param);}
    void setXAnalogGain(int sidx, double gain, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogGain(sidx, gain, handler, param);}
    void setSyncroInputMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroInputMask(mask, handler, param);}
    void setSyncroInputValue(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroInputValue(mask, handler, param);}
    void setSyncroOutputMask(double mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroOutputMask(mask, handler, param);}
    void setSyncroOutputValue(double mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroOutputValue(mask, handler, param);}
    void setSyncroStartTimeout(int tim, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroStartTimeout(tim, handler, param);}
    void setDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setDigitalOutput(out, handler, param);}
    void setXDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setXDigitalOutput(out, handler, param);}
    void setXAnalogOutput1(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput1(out, handler, param);}
    void setXAnalogOutput2(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput2(out, handler, param);}
    void setAnalogOutput(double out, DsaHandler handler, void *param = NULL) {DsaBase::setAnalogOutput(out, handler, param);}
    void setInterruptMask1(int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setInterruptMask1(sidx, mask, handler, param);}
    void setInterruptMask2(int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setInterruptMask2(sidx, mask, handler, param);}
    void setTriggerIrqMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerIrqMask(mask, handler, param);}
    void setTriggerIOMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerIOMask(mask, handler, param);}
    void setTriggerMapOffset(int offset, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerMapOffset(offset, handler, param);}
    void setTriggerMapSize(int size, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerMapSize(size, handler, param);}
    void setRealtimeEnabledGlobal(int enable, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeEnabledGlobal(enable, handler, param);}
    void setRealtimeValidMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeValidMask(mask, handler, param);}
    void setRealtimeEnabledMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeEnabledMask(mask, handler, param);}
    void setRealtimePendingMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimePendingMask(mask, handler, param);}
    void setEblBaudrate(long baud, DsaHandler handler, void *param = NULL) {DsaBase::setEblBaudrate(baud, handler, param);}
    void setIndirectAxisNumber(int axis, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectAxisNumber(axis, handler, param);}
    void setIndirectRegisterIdx(int idx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterIdx(idx, handler, param);}
    void setIndirectRegisterSidx(int sidx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterSidx(sidx, handler, param);}
    void setConcatenatedMvt(int concat, DsaHandler handler, void *param = NULL) {DsaBase::setConcatenatedMvt(concat, handler, param);}
    void setProfileType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setProfileType(sidx, typ, handler, param);}
    void setMvtLktNumber(int sidx, int number, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktNumber(sidx, number, handler, param);}
    void setMvtLktTime(int sidx, double time, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktTime(sidx, time, handler, param);}
    void setCameValue(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCameValue(factor, handler, param);}
    void setBrakeDeceleration(double dec, DsaHandler handler, void *param = NULL) {DsaBase::setBrakeDeceleration(dec, handler, param);}
    void setTargetPosition(int sidx, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTargetPosition(sidx, pos, handler, param);}
    void setProfileVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setProfileVelocity(sidx, vel, handler, param);}
    void setProfileAcceleration(int sidx, double acc, DsaHandler handler, void *param = NULL) {DsaBase::setProfileAcceleration(sidx, acc, handler, param);}
    void setJerkTime(int sidx, double tim, DsaHandler handler, void *param = NULL) {DsaBase::setJerkTime(sidx, tim, handler, param);}
    void setProfileDeceleration(int sidx, double dec, DsaHandler handler, void *param = NULL) {DsaBase::setProfileDeceleration(sidx, dec, handler, param);}
    void setEndVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setEndVelocity(sidx, vel, handler, param);}
    void setCtrlSourceType(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceType(typ, handler, param);}
    void setCtrlSourceIndex(int index, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceIndex(index, handler, param);}
    void setCtrlShiftFactor(int shift, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlShiftFactor(shift, handler, param);}
    void setCtrlOffset(long offset, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlOffset(offset, handler, param);}
    void setCtrlGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlGain(gain, handler, param);}
    void setMotorKTFactor(double kt, DsaHandler handler, void *param = NULL) {DsaBase::setMotorKTFactor(kt, handler, param);}

	/* register getters */


};


/**
 * DsaDrive class - C++
 */
class DsaDrive: public DsaBase {
	/* constructors */
public:
	DsaDrive(void) {
		dsa = NULL;
		ERRCHK(dsa_create_drive(&dsa));
	}
	DsaDrive(DsaDrive &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaDrive(DsaBase &obj) {
		if (!dsa_is_valid_drive(obj.dsa))
			throw bad_cast("cannot cast to DsaDrive");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	/* operators */
public:
	DsaDrive operator = (DsaDrive &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaDrive operator = (DsaBase &obj) {
		if (!dsa_is_valid_drive(obj.dsa))
			throw bad_cast("cannot cast to DsaDriveBase");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* functions */
    void powerOn(long timeout = DEF_TIMEOUT) {DsaBase::powerOn(timeout);}
    void powerOff(long timeout = DEF_TIMEOUT) {DsaBase::powerOff(timeout);}
    void newSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::newSetpoint(sidx, flags, timeout);}
    void changeSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::changeSetpoint(sidx, flags, timeout);}
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    void homingStart(long timeout = DEF_TIMEOUT) {DsaBase::homingStart(timeout);}
    int  getWarningCode(int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getWarningCode(kind, timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    long  getRegister(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegister(typ, idx, sidx, kind, timeout);}
    void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    double  getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, timeout);}
    void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, long timeout = DEF_TIMEOUT) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, timeout);}
    DsaStatus  waitStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusEqual(mask, ref, timeout);}
    DsaStatus  waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusNotEqual(mask, ref, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    DsaStatus  waitStatusChange(DsaStatus *mask, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusChange(mask, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

    void powerOn(DsaHandler handler, void *param = NULL) {DsaBase::powerOn(handler, param);}
    void powerOff(DsaHandler handler, void *param = NULL) {DsaBase::powerOff(handler, param);}
    void newSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::newSetpoint(sidx, flags, handler, param);}
    void changeSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::changeSetpoint(sidx, flags, handler, param);}
    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void homingStart(DsaHandler handler, void *param = NULL) {DsaBase::homingStart(handler, param);}
    void getWarningCode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getWarningCode(kind, handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void getRegister(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getRegister(typ, idx, sidx, kind, handler, param);}
    void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, handler, param);}
    void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, Dsa2intHandler handler, void *param = NULL) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, handler, param);}
    void waitStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusEqual(mask, ref, handler, param);}
    void waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusNotEqual(mask, ref, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void waitStatusChange(DsaStatus *mask, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusChange(mask, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

    void open(EtbBus etb, int axis) {DsaBase::open(etb, axis);}
    void open(char_cp url) {DsaBase::open(url);}
    void open(EtbBus etb, int axis, dword flags) {DsaBase::open(etb, axis, flags);}
    void reset() {DsaBase::reset();}
    void close() {DsaBase::close();}
    EtbBus  getEtbBus() {return DsaBase::getEtbBus();}
    int  getEtbAxis() {return DsaBase::getEtbAxis();}
    bool  isOpen() {return DsaBase::isOpen();}
    int getMotorTyp() {return DsaBase::getMotorTyp();}
    void getErrorText(char_p text, int size, int code) {DsaBase::getErrorText(text, size, code);}
    void getWarningText(char_p text, int size, int code) {DsaBase::getWarningText(text, size, code);}
    double  convertToIso(long inc, int conv) {return DsaBase::convertToIso(inc, conv);}
    long  convertFromIso(double iso, int conv) {return DsaBase::convertFromIso(iso, conv);}
    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    DsaInfo  getInfo() {return DsaBase::getInfo();}
    DsaStatus  getStatus() {return DsaBase::getStatus();}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    DsaStatus  getStatusFromDrive(long timeout = DEF_TIMEOUT) {return DsaBase::getStatusFromDrive(timeout);}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}
    DsaXInfo  getXInfo() {return DsaBase::getXInfo();}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void stepMotion(double pos, long timeout = DEF_TIMEOUT) {DsaBase::stepMotion(pos, timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void canCommand1(dword val1, dword val2, long timeout = DEF_TIMEOUT) {DsaBase::canCommand1(val1, val2, timeout);}
    void canCommand2(dword val1, dword val2, long timeout = DEF_TIMEOUT) {DsaBase::canCommand2(val1, val2, timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void stepMotion(double pos, DsaHandler handler, void *param = NULL) {DsaBase::stepMotion(pos, handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void canCommand1(dword val1, dword val2, DsaHandler handler, void *param = NULL) {DsaBase::canCommand1(val1, val2, handler, param);}
    void canCommand2(dword val1, dword val2, DsaHandler handler, void *param = NULL) {DsaBase::canCommand2(val1, val2, handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */
    void setPLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLProportionalGain(gain, timeout);}
    void setPLSpeedFeedbackGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedbackGain(gain, timeout);}
    void setPLForceFeedbackGain1(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLForceFeedbackGain1(gain, timeout);}
    void setPLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorGain(gain, timeout);}
    void setPLAntiWindupGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLAntiWindupGain(gain, timeout);}
    void setPLIntegratorLimitation(double limit, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorLimitation(limit, timeout);}
    void setPLIntegratorMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorMode(mode, timeout);}
    void setPLSpeedFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFilter(tim, timeout);}
    void setPLOutputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPLOutputFilter(tim, timeout);}
    void setCLInputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLInputFilter(tim, timeout);}
    void setTtlSpecialFilter(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setTtlSpecialFilter(factor, timeout);}
    void setPLForceFeedbackGain2(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLForceFeedbackGain2(factor, timeout);}
    void setPLSpeedFeedfwdGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedfwdGain(factor, timeout);}
    void setPLAccFeedforwardGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLAccFeedforwardGain(factor, timeout);}
    void setCLPhaseAdvanceFactor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCLPhaseAdvanceFactor(factor, timeout);}
    void setAprInputFilter(double time, long timeout = DEF_TIMEOUT) {DsaBase::setAprInputFilter(time, timeout);}
    void setCLPhaseAdvanceShift(double shift, long timeout = DEF_TIMEOUT) {DsaBase::setCLPhaseAdvanceShift(shift, timeout);}
    void setMinPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinPositionRangeLimit(pos, timeout);}
    void setMaxPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxPositionRangeLimit(pos, timeout);}
    void setMaxProfileVelocity(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setMaxProfileVelocity(vel, timeout);}
    void setMaxAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setMaxAcceleration(acc, timeout);}
    void setFollowingErrorWindow(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setFollowingErrorWindow(pos, timeout);}
    void setVelocityErrorLimit(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setVelocityErrorLimit(vel, timeout);}
    void setSwitchLimitMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setSwitchLimitMode(mode, timeout);}
    void setEnableInputMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setEnableInputMode(mode, timeout);}
    void setMinSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinSoftPositionLimit(pos, timeout);}
    void setMaxSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxSoftPositionLimit(pos, timeout);}
    void setProfileLimitMode(dword flags, long timeout = DEF_TIMEOUT) {DsaBase::setProfileLimitMode(flags, timeout);}
    void setIOErrorEventMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setIOErrorEventMask(mask, timeout);}
    void setPositionWindowTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindowTime(tim, timeout);}
    void setPositionWindow(double win, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindow(win, timeout);}
    void setHomingMethod(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingMethod(mode, timeout);}
    void setHomingZeroSpeed(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setHomingZeroSpeed(vel, timeout);}
    void setHomingAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setHomingAcceleration(acc, timeout);}
    void setHomingFollowingLimit(double win, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFollowingLimit(win, timeout);}
    void setHomingCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setHomingCurrentLimit(cur, timeout);}
    void setHomeOffset(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomeOffset(pos, timeout);}
    void setHomingFixedMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFixedMvt(pos, timeout);}
    void setHomingSwitchMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingSwitchMvt(pos, timeout);}
    void setHomingIndexMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingIndexMvt(pos, timeout);}
    void setHomingFineTuningMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningMode(mode, timeout);}
    void setHomingFineTuningValue(double phase, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningValue(phase, timeout);}
    void setMotorPhaseCorrection(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setMotorPhaseCorrection(mode, timeout);}
    void setSoftwareCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setSoftwareCurrentLimit(cur, timeout);}
    void setDriveControlMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDriveControlMode(mode, timeout);}
    void setDisplayMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDisplayMode(mode, timeout);}
    void setEncoderInversion(double invert, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderInversion(invert, timeout);}
    void setPdrStepValue(double step, long timeout = DEF_TIMEOUT) {DsaBase::setPdrStepValue(step, timeout);}
    void setEncoderPhase1Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Offset(offset, timeout);}
    void setEncoderPhase2Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Offset(offset, timeout);}
    void setEncoderPhase1Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Factor(factor, timeout);}
    void setEncoderPhase2Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Factor(factor, timeout);}
    void setEncoderPhase3Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase3Offset(offset, timeout);}
    void setEncoderIndexDistance(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderIndexDistance(pos, timeout);}
    void setEncoderPhase3Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase3Factor(factor, timeout);}
    void setCLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLProportionalGain(gain, timeout);}
    void setCLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLIntegratorGain(gain, timeout);}
    void setCLOutputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLOutputFilter(tim, timeout);}
    void setCLCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLCurrentLimit(cur, timeout);}
    void setCLI2tCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tCurrentLimit(cur, timeout);}
    void setCLI2tTimeLimit(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tTimeLimit(tim, timeout);}
    void setCLRegenMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setCLRegenMode(mode, timeout);}
    void setInitMode(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setInitMode(typ, timeout);}
    void setInitPulseLevel(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitPulseLevel(cur, timeout);}
    void setInitMaxCurrent(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitMaxCurrent(cur, timeout);}
    void setInitFinalPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitFinalPhase(cal, timeout);}
    void setInitTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setInitTime(tim, timeout);}
    void setInitCurrentRate(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitCurrentRate(cur, timeout);}
    void setInitPhaseRate(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitPhaseRate(cal, timeout);}
    void setInitInitialPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitInitialPhase(cal, timeout);}
    void setDriveFuseChecking(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setDriveFuseChecking(mask, timeout);}
    void setMotorTempChecking(dword val, long timeout = DEF_TIMEOUT) {DsaBase::setMotorTempChecking(val, timeout);}
    void setMonSourceType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceType(sidx, typ, timeout);}
    void setMonSourceIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceIndex(sidx, index, timeout);}
    void setMonDestIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonDestIndex(sidx, index, timeout);}
    void setMonOffset(int sidx, long offset, long timeout = DEF_TIMEOUT) {DsaBase::setMonOffset(sidx, offset, timeout);}
    void setMonGain(int sidx, double gain, long timeout = DEF_TIMEOUT) {DsaBase::setMonGain(sidx, gain, timeout);}
    void setXAnalogOffset(int sidx, double offset, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOffset(sidx, offset, timeout);}
    void setXAnalogGain(int sidx, double gain, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogGain(sidx, gain, timeout);}
    void setSyncroInputMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroInputMask(mask, timeout);}
    void setSyncroInputValue(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroInputValue(mask, timeout);}
    void setSyncroOutputMask(double mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroOutputMask(mask, timeout);}
    void setSyncroOutputValue(double mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroOutputValue(mask, timeout);}
    void setSyncroStartTimeout(int tim, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroStartTimeout(tim, timeout);}
    void setDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setDigitalOutput(out, timeout);}
    void setXDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setXDigitalOutput(out, timeout);}
    void setXAnalogOutput1(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput1(out, timeout);}
    void setXAnalogOutput2(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput2(out, timeout);}
    void setAnalogOutput(double out, long timeout = DEF_TIMEOUT) {DsaBase::setAnalogOutput(out, timeout);}
    void setInterruptMask1(int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setInterruptMask1(sidx, mask, timeout);}
    void setInterruptMask2(int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setInterruptMask2(sidx, mask, timeout);}
    void setTriggerIrqMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerIrqMask(mask, timeout);}
    void setTriggerIOMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerIOMask(mask, timeout);}
    void setTriggerMapOffset(int offset, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerMapOffset(offset, timeout);}
    void setTriggerMapSize(int size, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerMapSize(size, timeout);}
    void setRealtimeEnabledGlobal(int enable, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeEnabledGlobal(enable, timeout);}
    void setRealtimeValidMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeValidMask(mask, timeout);}
    void setRealtimeEnabledMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeEnabledMask(mask, timeout);}
    void setRealtimePendingMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimePendingMask(mask, timeout);}
    void setEblBaudrate(long baud, long timeout = DEF_TIMEOUT) {DsaBase::setEblBaudrate(baud, timeout);}
    void setIndirectAxisNumber(int axis, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectAxisNumber(axis, timeout);}
    void setIndirectRegisterIdx(int idx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterIdx(idx, timeout);}
    void setIndirectRegisterSidx(int sidx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterSidx(sidx, timeout);}
    void setConcatenatedMvt(int concat, long timeout = DEF_TIMEOUT) {DsaBase::setConcatenatedMvt(concat, timeout);}
    void setProfileType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setProfileType(sidx, typ, timeout);}
    void setMvtLktNumber(int sidx, int number, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktNumber(sidx, number, timeout);}
    void setMvtLktTime(int sidx, double time, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktTime(sidx, time, timeout);}
    void setCameValue(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCameValue(factor, timeout);}
    void setBrakeDeceleration(double dec, long timeout = DEF_TIMEOUT) {DsaBase::setBrakeDeceleration(dec, timeout);}
    void setTargetPosition(int sidx, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTargetPosition(sidx, pos, timeout);}
    void setProfileVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setProfileVelocity(sidx, vel, timeout);}
    void setProfileAcceleration(int sidx, double acc, long timeout = DEF_TIMEOUT) {DsaBase::setProfileAcceleration(sidx, acc, timeout);}
    void setJerkTime(int sidx, double tim, long timeout = DEF_TIMEOUT) {DsaBase::setJerkTime(sidx, tim, timeout);}
    void setProfileDeceleration(int sidx, double dec, long timeout = DEF_TIMEOUT) {DsaBase::setProfileDeceleration(sidx, dec, timeout);}
    void setEndVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setEndVelocity(sidx, vel, timeout);}
    void setCtrlSourceType(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceType(typ, timeout);}
    void setCtrlSourceIndex(int index, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceIndex(index, timeout);}
    void setCtrlShiftFactor(int shift, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlShiftFactor(shift, timeout);}
    void setCtrlOffset(long offset, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlOffset(offset, timeout);}
    void setCtrlGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlGain(gain, timeout);}
    void setMotorKTFactor(double kt, long timeout = DEF_TIMEOUT) {DsaBase::setMotorKTFactor(kt, timeout);}

    void setPLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLProportionalGain(gain, handler, param);}
    void setPLSpeedFeedbackGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedbackGain(gain, handler, param);}
    void setPLForceFeedbackGain1(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLForceFeedbackGain1(gain, handler, param);}
    void setPLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorGain(gain, handler, param);}
    void setPLAntiWindupGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLAntiWindupGain(gain, handler, param);}
    void setPLIntegratorLimitation(double limit, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorLimitation(limit, handler, param);}
    void setPLIntegratorMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorMode(mode, handler, param);}
    void setPLSpeedFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFilter(tim, handler, param);}
    void setPLOutputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPLOutputFilter(tim, handler, param);}
    void setCLInputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLInputFilter(tim, handler, param);}
    void setTtlSpecialFilter(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setTtlSpecialFilter(factor, handler, param);}
    void setPLForceFeedbackGain2(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLForceFeedbackGain2(factor, handler, param);}
    void setPLSpeedFeedfwdGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedfwdGain(factor, handler, param);}
    void setPLAccFeedforwardGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLAccFeedforwardGain(factor, handler, param);}
    void setCLPhaseAdvanceFactor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCLPhaseAdvanceFactor(factor, handler, param);}
    void setAprInputFilter(double time, DsaHandler handler, void *param = NULL) {DsaBase::setAprInputFilter(time, handler, param);}
    void setCLPhaseAdvanceShift(double shift, DsaHandler handler, void *param = NULL) {DsaBase::setCLPhaseAdvanceShift(shift, handler, param);}
    void setMinPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinPositionRangeLimit(pos, handler, param);}
    void setMaxPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxPositionRangeLimit(pos, handler, param);}
    void setMaxProfileVelocity(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setMaxProfileVelocity(vel, handler, param);}
    void setMaxAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setMaxAcceleration(acc, handler, param);}
    void setFollowingErrorWindow(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setFollowingErrorWindow(pos, handler, param);}
    void setVelocityErrorLimit(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setVelocityErrorLimit(vel, handler, param);}
    void setSwitchLimitMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setSwitchLimitMode(mode, handler, param);}
    void setEnableInputMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setEnableInputMode(mode, handler, param);}
    void setMinSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinSoftPositionLimit(pos, handler, param);}
    void setMaxSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxSoftPositionLimit(pos, handler, param);}
    void setProfileLimitMode(dword flags, DsaHandler handler, void *param = NULL) {DsaBase::setProfileLimitMode(flags, handler, param);}
    void setIOErrorEventMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setIOErrorEventMask(mask, handler, param);}
    void setPositionWindowTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindowTime(tim, handler, param);}
    void setPositionWindow(double win, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindow(win, handler, param);}
    void setHomingMethod(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingMethod(mode, handler, param);}
    void setHomingZeroSpeed(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setHomingZeroSpeed(vel, handler, param);}
    void setHomingAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setHomingAcceleration(acc, handler, param);}
    void setHomingFollowingLimit(double win, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFollowingLimit(win, handler, param);}
    void setHomingCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setHomingCurrentLimit(cur, handler, param);}
    void setHomeOffset(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomeOffset(pos, handler, param);}
    void setHomingFixedMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFixedMvt(pos, handler, param);}
    void setHomingSwitchMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingSwitchMvt(pos, handler, param);}
    void setHomingIndexMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingIndexMvt(pos, handler, param);}
    void setHomingFineTuningMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningMode(mode, handler, param);}
    void setHomingFineTuningValue(double phase, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningValue(phase, handler, param);}
    void setMotorPhaseCorrection(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setMotorPhaseCorrection(mode, handler, param);}
    void setSoftwareCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setSoftwareCurrentLimit(cur, handler, param);}
    void setDriveControlMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDriveControlMode(mode, handler, param);}
    void setDisplayMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDisplayMode(mode, handler, param);}
    void setEncoderInversion(double invert, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderInversion(invert, handler, param);}
    void setPdrStepValue(double step, DsaHandler handler, void *param = NULL) {DsaBase::setPdrStepValue(step, handler, param);}
    void setEncoderPhase1Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Offset(offset, handler, param);}
    void setEncoderPhase2Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Offset(offset, handler, param);}
    void setEncoderPhase1Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Factor(factor, handler, param);}
    void setEncoderPhase2Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Factor(factor, handler, param);}
    void setEncoderPhase3Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase3Offset(offset, handler, param);}
    void setEncoderIndexDistance(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderIndexDistance(pos, handler, param);}
    void setEncoderPhase3Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase3Factor(factor, handler, param);}
    void setCLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLProportionalGain(gain, handler, param);}
    void setCLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLIntegratorGain(gain, handler, param);}
    void setCLOutputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLOutputFilter(tim, handler, param);}
    void setCLCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLCurrentLimit(cur, handler, param);}
    void setCLI2tCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tCurrentLimit(cur, handler, param);}
    void setCLI2tTimeLimit(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tTimeLimit(tim, handler, param);}
    void setCLRegenMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setCLRegenMode(mode, handler, param);}
    void setInitMode(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setInitMode(typ, handler, param);}
    void setInitPulseLevel(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitPulseLevel(cur, handler, param);}
    void setInitMaxCurrent(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitMaxCurrent(cur, handler, param);}
    void setInitFinalPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitFinalPhase(cal, handler, param);}
    void setInitTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setInitTime(tim, handler, param);}
    void setInitCurrentRate(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitCurrentRate(cur, handler, param);}
    void setInitPhaseRate(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitPhaseRate(cal, handler, param);}
    void setInitInitialPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitInitialPhase(cal, handler, param);}
    void setDriveFuseChecking(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setDriveFuseChecking(mask, handler, param);}
    void setMotorTempChecking(dword val, DsaHandler handler, void *param = NULL) {DsaBase::setMotorTempChecking(val, handler, param);}
    void setMonSourceType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceType(sidx, typ, handler, param);}
    void setMonSourceIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceIndex(sidx, index, handler, param);}
    void setMonDestIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonDestIndex(sidx, index, handler, param);}
    void setMonOffset(int sidx, long offset, DsaHandler handler, void *param = NULL) {DsaBase::setMonOffset(sidx, offset, handler, param);}
    void setMonGain(int sidx, double gain, DsaHandler handler, void *param = NULL) {DsaBase::setMonGain(sidx, gain, handler, param);}
    void setXAnalogOffset(int sidx, double offset, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOffset(sidx, offset, handler, param);}
    void setXAnalogGain(int sidx, double gain, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogGain(sidx, gain, handler, param);}
    void setSyncroInputMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroInputMask(mask, handler, param);}
    void setSyncroInputValue(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroInputValue(mask, handler, param);}
    void setSyncroOutputMask(double mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroOutputMask(mask, handler, param);}
    void setSyncroOutputValue(double mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroOutputValue(mask, handler, param);}
    void setSyncroStartTimeout(int tim, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroStartTimeout(tim, handler, param);}
    void setDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setDigitalOutput(out, handler, param);}
    void setXDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setXDigitalOutput(out, handler, param);}
    void setXAnalogOutput1(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput1(out, handler, param);}
    void setXAnalogOutput2(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput2(out, handler, param);}
    void setAnalogOutput(double out, DsaHandler handler, void *param = NULL) {DsaBase::setAnalogOutput(out, handler, param);}
    void setInterruptMask1(int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setInterruptMask1(sidx, mask, handler, param);}
    void setInterruptMask2(int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setInterruptMask2(sidx, mask, handler, param);}
    void setTriggerIrqMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerIrqMask(mask, handler, param);}
    void setTriggerIOMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerIOMask(mask, handler, param);}
    void setTriggerMapOffset(int offset, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerMapOffset(offset, handler, param);}
    void setTriggerMapSize(int size, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerMapSize(size, handler, param);}
    void setRealtimeEnabledGlobal(int enable, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeEnabledGlobal(enable, handler, param);}
    void setRealtimeValidMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeValidMask(mask, handler, param);}
    void setRealtimeEnabledMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeEnabledMask(mask, handler, param);}
    void setRealtimePendingMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimePendingMask(mask, handler, param);}
    void setEblBaudrate(long baud, DsaHandler handler, void *param = NULL) {DsaBase::setEblBaudrate(baud, handler, param);}
    void setIndirectAxisNumber(int axis, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectAxisNumber(axis, handler, param);}
    void setIndirectRegisterIdx(int idx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterIdx(idx, handler, param);}
    void setIndirectRegisterSidx(int sidx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterSidx(sidx, handler, param);}
    void setConcatenatedMvt(int concat, DsaHandler handler, void *param = NULL) {DsaBase::setConcatenatedMvt(concat, handler, param);}
    void setProfileType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setProfileType(sidx, typ, handler, param);}
    void setMvtLktNumber(int sidx, int number, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktNumber(sidx, number, handler, param);}
    void setMvtLktTime(int sidx, double time, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktTime(sidx, time, handler, param);}
    void setCameValue(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCameValue(factor, handler, param);}
    void setBrakeDeceleration(double dec, DsaHandler handler, void *param = NULL) {DsaBase::setBrakeDeceleration(dec, handler, param);}
    void setTargetPosition(int sidx, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTargetPosition(sidx, pos, handler, param);}
    void setProfileVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setProfileVelocity(sidx, vel, handler, param);}
    void setProfileAcceleration(int sidx, double acc, DsaHandler handler, void *param = NULL) {DsaBase::setProfileAcceleration(sidx, acc, handler, param);}
    void setJerkTime(int sidx, double tim, DsaHandler handler, void *param = NULL) {DsaBase::setJerkTime(sidx, tim, handler, param);}
    void setProfileDeceleration(int sidx, double dec, DsaHandler handler, void *param = NULL) {DsaBase::setProfileDeceleration(sidx, dec, handler, param);}
    void setEndVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setEndVelocity(sidx, vel, handler, param);}
    void setCtrlSourceType(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceType(typ, handler, param);}
    void setCtrlSourceIndex(int index, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceIndex(index, handler, param);}
    void setCtrlShiftFactor(int shift, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlShiftFactor(shift, handler, param);}
    void setCtrlOffset(long offset, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlOffset(offset, handler, param);}
    void setCtrlGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlGain(gain, handler, param);}
    void setMotorKTFactor(double kt, DsaHandler handler, void *param = NULL) {DsaBase::setMotorKTFactor(kt, handler, param);}

	/* register getters */
    double getPLProportionalGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLProportionalGain(kind, timeout);}
    void getPLProportionalGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLProportionalGain(gain, kind, timeout);}
    double getPLSpeedFeedbackGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLSpeedFeedbackGain(kind, timeout);}
    void getPLSpeedFeedbackGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLSpeedFeedbackGain(gain, kind, timeout);}
    double getPLForceFeedbackGain1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLForceFeedbackGain1(kind, timeout);}
    void getPLForceFeedbackGain1(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLForceFeedbackGain1(gain, kind, timeout);}
    double getPLIntegratorGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLIntegratorGain(kind, timeout);}
    void getPLIntegratorGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLIntegratorGain(gain, kind, timeout);}
    double getPLAntiWindupGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLAntiWindupGain(kind, timeout);}
    void getPLAntiWindupGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLAntiWindupGain(gain, kind, timeout);}
    double getPLIntegratorLimitation(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLIntegratorLimitation(kind, timeout);}
    void getPLIntegratorLimitation(double *limit, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLIntegratorLimitation(limit, kind, timeout);}
    int getPLIntegratorMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLIntegratorMode(kind, timeout);}
    void getPLIntegratorMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLIntegratorMode(mode, kind, timeout);}
    double getPLSpeedFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLSpeedFilter(kind, timeout);}
    void getPLSpeedFilter(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLSpeedFilter(tim, kind, timeout);}
    double getPLOutputFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLOutputFilter(kind, timeout);}
    void getPLOutputFilter(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLOutputFilter(tim, kind, timeout);}
    double getCLInputFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLInputFilter(kind, timeout);}
    void getCLInputFilter(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLInputFilter(tim, kind, timeout);}
    double getTtlSpecialFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTtlSpecialFilter(kind, timeout);}
    void getTtlSpecialFilter(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTtlSpecialFilter(factor, kind, timeout);}
    double getPLForceFeedbackGain2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLForceFeedbackGain2(kind, timeout);}
    void getPLForceFeedbackGain2(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLForceFeedbackGain2(factor, kind, timeout);}
    double getPLSpeedFeedfwdGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLSpeedFeedfwdGain(kind, timeout);}
    void getPLSpeedFeedfwdGain(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLSpeedFeedfwdGain(factor, kind, timeout);}
    double getPLAccFeedforwardGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLAccFeedforwardGain(kind, timeout);}
    void getPLAccFeedforwardGain(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLAccFeedforwardGain(factor, kind, timeout);}
    double getCLPhaseAdvanceFactor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLPhaseAdvanceFactor(kind, timeout);}
    void getCLPhaseAdvanceFactor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLPhaseAdvanceFactor(factor, kind, timeout);}
    double getAprInputFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAprInputFilter(kind, timeout);}
    void getAprInputFilter(double *time, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAprInputFilter(time, kind, timeout);}
    double getCLPhaseAdvanceShift(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLPhaseAdvanceShift(kind, timeout);}
    void getCLPhaseAdvanceShift(double *shift, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLPhaseAdvanceShift(shift, kind, timeout);}
    double getMinPositionRangeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMinPositionRangeLimit(kind, timeout);}
    void getMinPositionRangeLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMinPositionRangeLimit(pos, kind, timeout);}
    double getMaxPositionRangeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMaxPositionRangeLimit(kind, timeout);}
    void getMaxPositionRangeLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMaxPositionRangeLimit(pos, kind, timeout);}
    double getMaxProfileVelocity(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMaxProfileVelocity(kind, timeout);}
    void getMaxProfileVelocity(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMaxProfileVelocity(vel, kind, timeout);}
    double getMaxAcceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMaxAcceleration(kind, timeout);}
    void getMaxAcceleration(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMaxAcceleration(acc, kind, timeout);}
    double getFollowingErrorWindow(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getFollowingErrorWindow(kind, timeout);}
    void getFollowingErrorWindow(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getFollowingErrorWindow(pos, kind, timeout);}
    double getVelocityErrorLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getVelocityErrorLimit(kind, timeout);}
    void getVelocityErrorLimit(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getVelocityErrorLimit(vel, kind, timeout);}
    int getSwitchLimitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSwitchLimitMode(kind, timeout);}
    void getSwitchLimitMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSwitchLimitMode(mode, kind, timeout);}
    int getEnableInputMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEnableInputMode(kind, timeout);}
    void getEnableInputMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEnableInputMode(mode, kind, timeout);}
    double getMinSoftPositionLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMinSoftPositionLimit(kind, timeout);}
    void getMinSoftPositionLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMinSoftPositionLimit(pos, kind, timeout);}
    double getMaxSoftPositionLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMaxSoftPositionLimit(kind, timeout);}
    void getMaxSoftPositionLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMaxSoftPositionLimit(pos, kind, timeout);}
    dword getProfileLimitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileLimitMode(kind, timeout);}
    void getProfileLimitMode(dword *flags, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileLimitMode(flags, kind, timeout);}
    dword getIOErrorEventMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIOErrorEventMask(kind, timeout);}
    void getIOErrorEventMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIOErrorEventMask(mask, kind, timeout);}
    double getPositionWindowTime(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionWindowTime(kind, timeout);}
    void getPositionWindowTime(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionWindowTime(tim, kind, timeout);}
    double getPositionWindow(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionWindow(kind, timeout);}
    void getPositionWindow(double *win, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionWindow(win, kind, timeout);}
    int getHomingMethod(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingMethod(kind, timeout);}
    void getHomingMethod(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingMethod(mode, kind, timeout);}
    double getHomingZeroSpeed(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingZeroSpeed(kind, timeout);}
    void getHomingZeroSpeed(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingZeroSpeed(vel, kind, timeout);}
    double getHomingAcceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingAcceleration(kind, timeout);}
    void getHomingAcceleration(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingAcceleration(acc, kind, timeout);}
    double getHomingFollowingLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingFollowingLimit(kind, timeout);}
    void getHomingFollowingLimit(double *win, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingFollowingLimit(win, kind, timeout);}
    double getHomingCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingCurrentLimit(kind, timeout);}
    void getHomingCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingCurrentLimit(cur, kind, timeout);}
    double getHomeOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomeOffset(kind, timeout);}
    void getHomeOffset(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomeOffset(pos, kind, timeout);}
    double getHomingFixedMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingFixedMvt(kind, timeout);}
    void getHomingFixedMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingFixedMvt(pos, kind, timeout);}
    double getHomingSwitchMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingSwitchMvt(kind, timeout);}
    void getHomingSwitchMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingSwitchMvt(pos, kind, timeout);}
    double getHomingIndexMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingIndexMvt(kind, timeout);}
    void getHomingIndexMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingIndexMvt(pos, kind, timeout);}
    int getHomingFineTuningMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingFineTuningMode(kind, timeout);}
    void getHomingFineTuningMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingFineTuningMode(mode, kind, timeout);}
    double getHomingFineTuningValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingFineTuningValue(kind, timeout);}
    void getHomingFineTuningValue(double *phase, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingFineTuningValue(phase, kind, timeout);}
    int getMotorPhaseCorrection(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMotorPhaseCorrection(kind, timeout);}
    void getMotorPhaseCorrection(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMotorPhaseCorrection(mode, kind, timeout);}
    double getSoftwareCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSoftwareCurrentLimit(kind, timeout);}
    void getSoftwareCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSoftwareCurrentLimit(cur, kind, timeout);}
    int getDriveControlMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveControlMode(kind, timeout);}
    void getDriveControlMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveControlMode(mode, kind, timeout);}
    int getDisplayMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDisplayMode(kind, timeout);}
    void getDisplayMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDisplayMode(mode, kind, timeout);}
    double getEncoderInversion(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderInversion(kind, timeout);}
    void getEncoderInversion(double *invert, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderInversion(invert, kind, timeout);}
    double getPdrStepValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPdrStepValue(kind, timeout);}
    void getPdrStepValue(double *step, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPdrStepValue(step, kind, timeout);}
    double getEncoderPhase1Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase1Offset(kind, timeout);}
    void getEncoderPhase1Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase1Offset(offset, kind, timeout);}
    double getEncoderPhase2Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase2Offset(kind, timeout);}
    void getEncoderPhase2Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase2Offset(offset, kind, timeout);}
    double getEncoderPhase1Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase1Factor(kind, timeout);}
    void getEncoderPhase1Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase1Factor(factor, kind, timeout);}
    double getEncoderPhase2Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase2Factor(kind, timeout);}
    void getEncoderPhase2Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase2Factor(factor, kind, timeout);}
    double getEncoderPhase3Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase3Offset(kind, timeout);}
    void getEncoderPhase3Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase3Offset(offset, kind, timeout);}
    double getEncoderIndexDistance(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderIndexDistance(kind, timeout);}
    void getEncoderIndexDistance(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderIndexDistance(pos, kind, timeout);}
    double getEncoderPhase3Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase3Factor(kind, timeout);}
    void getEncoderPhase3Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase3Factor(factor, kind, timeout);}
    double getCLProportionalGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLProportionalGain(kind, timeout);}
    void getCLProportionalGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLProportionalGain(gain, kind, timeout);}
    double getCLIntegratorGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLIntegratorGain(kind, timeout);}
    void getCLIntegratorGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLIntegratorGain(gain, kind, timeout);}
    double getCLOutputFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLOutputFilter(kind, timeout);}
    void getCLOutputFilter(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLOutputFilter(tim, kind, timeout);}
    double getCLCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLCurrentLimit(kind, timeout);}
    void getCLCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLCurrentLimit(cur, kind, timeout);}
    double getCLI2tCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLI2tCurrentLimit(kind, timeout);}
    void getCLI2tCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLI2tCurrentLimit(cur, kind, timeout);}
    double getCLI2tTimeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLI2tTimeLimit(kind, timeout);}
    void getCLI2tTimeLimit(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLI2tTimeLimit(tim, kind, timeout);}
    int getCLRegenMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLRegenMode(kind, timeout);}
    void getCLRegenMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLRegenMode(mode, kind, timeout);}
    int getInitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitMode(kind, timeout);}
    void getInitMode(int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitMode(typ, kind, timeout);}
    double getInitPulseLevel(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitPulseLevel(kind, timeout);}
    void getInitPulseLevel(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitPulseLevel(cur, kind, timeout);}
    double getInitMaxCurrent(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitMaxCurrent(kind, timeout);}
    void getInitMaxCurrent(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitMaxCurrent(cur, kind, timeout);}
    double getInitFinalPhase(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitFinalPhase(kind, timeout);}
    void getInitFinalPhase(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitFinalPhase(cal, kind, timeout);}
    double getInitTime(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitTime(kind, timeout);}
    void getInitTime(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitTime(tim, kind, timeout);}
    double getInitCurrentRate(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitCurrentRate(kind, timeout);}
    void getInitCurrentRate(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitCurrentRate(cur, kind, timeout);}
    double getInitPhaseRate(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitPhaseRate(kind, timeout);}
    void getInitPhaseRate(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitPhaseRate(cal, kind, timeout);}
    double getInitInitialPhase(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitInitialPhase(kind, timeout);}
    void getInitInitialPhase(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitInitialPhase(cal, kind, timeout);}
    dword getDriveFuseChecking(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveFuseChecking(kind, timeout);}
    void getDriveFuseChecking(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveFuseChecking(mask, kind, timeout);}
    dword getMotorTempChecking(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMotorTempChecking(kind, timeout);}
    void getMotorTempChecking(dword *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMotorTempChecking(val, kind, timeout);}
    int getMonSourceType(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMonSourceType(sidx, kind, timeout);}
    void getMonSourceType(int sidx, int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMonSourceType(sidx, typ, kind, timeout);}
    int getMonSourceIndex(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMonSourceIndex(sidx, kind, timeout);}
    void getMonSourceIndex(int sidx, int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMonSourceIndex(sidx, index, kind, timeout);}
    int getMonDestIndex(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMonDestIndex(sidx, kind, timeout);}
    void getMonDestIndex(int sidx, int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMonDestIndex(sidx, index, kind, timeout);}
    long getMonOffset(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMonOffset(sidx, kind, timeout);}
    void getMonOffset(int sidx, long *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMonOffset(sidx, offset, kind, timeout);}
    double getMonGain(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMonGain(sidx, kind, timeout);}
    void getMonGain(int sidx, double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMonGain(sidx, gain, kind, timeout);}
    double getXAnalogOffset(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogOffset(sidx, kind, timeout);}
    void getXAnalogOffset(int sidx, double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogOffset(sidx, offset, kind, timeout);}
    double getXAnalogGain(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogGain(sidx, kind, timeout);}
    void getXAnalogGain(int sidx, double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogGain(sidx, gain, kind, timeout);}
    dword getSyncroInputMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSyncroInputMask(kind, timeout);}
    void getSyncroInputMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSyncroInputMask(mask, kind, timeout);}
    dword getSyncroInputValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSyncroInputValue(kind, timeout);}
    void getSyncroInputValue(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSyncroInputValue(mask, kind, timeout);}
    double getSyncroOutputMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSyncroOutputMask(kind, timeout);}
    void getSyncroOutputMask(double *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSyncroOutputMask(mask, kind, timeout);}
    double getSyncroOutputValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSyncroOutputValue(kind, timeout);}
    void getSyncroOutputValue(double *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSyncroOutputValue(mask, kind, timeout);}
    int getSyncroStartTimeout(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSyncroStartTimeout(kind, timeout);}
    void getSyncroStartTimeout(int *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSyncroStartTimeout(tim, kind, timeout);}
    dword getDigitalOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDigitalOutput(kind, timeout);}
    void getDigitalOutput(dword *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDigitalOutput(out, kind, timeout);}
    dword getXDigitalOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXDigitalOutput(kind, timeout);}
    void getXDigitalOutput(dword *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXDigitalOutput(out, kind, timeout);}
    double getXAnalogOutput1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogOutput1(kind, timeout);}
    void getXAnalogOutput1(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogOutput1(out, kind, timeout);}
    double getXAnalogOutput2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogOutput2(kind, timeout);}
    void getXAnalogOutput2(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogOutput2(out, kind, timeout);}
    double getAnalogOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAnalogOutput(kind, timeout);}
    void getAnalogOutput(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAnalogOutput(out, kind, timeout);}
    dword getInterruptMask1(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInterruptMask1(sidx, kind, timeout);}
    void getInterruptMask1(int sidx, dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInterruptMask1(sidx, mask, kind, timeout);}
    dword getInterruptMask2(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInterruptMask2(sidx, kind, timeout);}
    void getInterruptMask2(int sidx, dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInterruptMask2(sidx, mask, kind, timeout);}
    dword getTriggerIrqMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTriggerIrqMask(kind, timeout);}
    void getTriggerIrqMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTriggerIrqMask(mask, kind, timeout);}
    dword getTriggerIOMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTriggerIOMask(kind, timeout);}
    void getTriggerIOMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTriggerIOMask(mask, kind, timeout);}
    int getTriggerMapOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTriggerMapOffset(kind, timeout);}
    void getTriggerMapOffset(int *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTriggerMapOffset(offset, kind, timeout);}
    int getTriggerMapSize(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTriggerMapSize(kind, timeout);}
    void getTriggerMapSize(int *size, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTriggerMapSize(size, kind, timeout);}
    int getRealtimeEnabledGlobal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getRealtimeEnabledGlobal(kind, timeout);}
    void getRealtimeEnabledGlobal(int *enable, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getRealtimeEnabledGlobal(enable, kind, timeout);}
    dword getRealtimeValidMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getRealtimeValidMask(kind, timeout);}
    void getRealtimeValidMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getRealtimeValidMask(mask, kind, timeout);}
    dword getRealtimeEnabledMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getRealtimeEnabledMask(kind, timeout);}
    void getRealtimeEnabledMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getRealtimeEnabledMask(mask, kind, timeout);}
    dword getRealtimePendingMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getRealtimePendingMask(kind, timeout);}
    void getRealtimePendingMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getRealtimePendingMask(mask, kind, timeout);}
    long getEblBaudrate(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEblBaudrate(kind, timeout);}
    void getEblBaudrate(long *baud, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEblBaudrate(baud, kind, timeout);}
    int getIndirectAxisNumber(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIndirectAxisNumber(kind, timeout);}
    void getIndirectAxisNumber(int *axis, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIndirectAxisNumber(axis, kind, timeout);}
    int getIndirectRegisterIdx(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIndirectRegisterIdx(kind, timeout);}
    void getIndirectRegisterIdx(int *idx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIndirectRegisterIdx(idx, kind, timeout);}
    int getIndirectRegisterSidx(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIndirectRegisterSidx(kind, timeout);}
    void getIndirectRegisterSidx(int *sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIndirectRegisterSidx(sidx, kind, timeout);}
    int getConcatenatedMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getConcatenatedMvt(kind, timeout);}
    void getConcatenatedMvt(int *concat, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getConcatenatedMvt(concat, kind, timeout);}
    int getProfileType(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileType(sidx, kind, timeout);}
    void getProfileType(int sidx, int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileType(sidx, typ, kind, timeout);}
    int getMvtLktNumber(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMvtLktNumber(sidx, kind, timeout);}
    void getMvtLktNumber(int sidx, int *number, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMvtLktNumber(sidx, number, kind, timeout);}
    double getMvtLktTime(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMvtLktTime(sidx, kind, timeout);}
    void getMvtLktTime(int sidx, double *time, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMvtLktTime(sidx, time, kind, timeout);}
    double getCameValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCameValue(kind, timeout);}
    void getCameValue(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCameValue(factor, kind, timeout);}
    double getBrakeDeceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getBrakeDeceleration(kind, timeout);}
    void getBrakeDeceleration(double *dec, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getBrakeDeceleration(dec, kind, timeout);}
    double getTargetPosition(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTargetPosition(sidx, kind, timeout);}
    void getTargetPosition(int sidx, double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTargetPosition(sidx, pos, kind, timeout);}
    double getProfileVelocity(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileVelocity(sidx, kind, timeout);}
    void getProfileVelocity(int sidx, double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileVelocity(sidx, vel, kind, timeout);}
    double getProfileAcceleration(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileAcceleration(sidx, kind, timeout);}
    void getProfileAcceleration(int sidx, double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileAcceleration(sidx, acc, kind, timeout);}
    double getJerkTime(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getJerkTime(sidx, kind, timeout);}
    void getJerkTime(int sidx, double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getJerkTime(sidx, tim, kind, timeout);}
    double getProfileDeceleration(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileDeceleration(sidx, kind, timeout);}
    void getProfileDeceleration(int sidx, double *dec, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileDeceleration(sidx, dec, kind, timeout);}
    double getEndVelocity(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEndVelocity(sidx, kind, timeout);}
    void getEndVelocity(int sidx, double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEndVelocity(sidx, vel, kind, timeout);}
    int getCtrlSourceType(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlSourceType(kind, timeout);}
    void getCtrlSourceType(int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlSourceType(typ, kind, timeout);}
    int getCtrlSourceIndex(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlSourceIndex(kind, timeout);}
    void getCtrlSourceIndex(int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlSourceIndex(index, kind, timeout);}
    int getCtrlShiftFactor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlShiftFactor(kind, timeout);}
    void getCtrlShiftFactor(int *shift, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlShiftFactor(shift, kind, timeout);}
    long getCtrlOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlOffset(kind, timeout);}
    void getCtrlOffset(long *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlOffset(offset, kind, timeout);}
    double getCtrlGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlGain(kind, timeout);}
    void getCtrlGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlGain(gain, kind, timeout);}
    double getMotorKTFactor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMotorKTFactor(kind, timeout);}
    void getMotorKTFactor(double *kt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMotorKTFactor(kt, kind, timeout);}
    double getPositionCtrlError(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionCtrlError(kind, timeout);}
    void getPositionCtrlError(double *err, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionCtrlError(err, kind, timeout);}
    double getPositionMaxError(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionMaxError(kind, timeout);}
    void getPositionMaxError(double *err, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionMaxError(err, kind, timeout);}
    double getPositionDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionDemandValue(kind, timeout);}
    void getPositionDemandValue(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionDemandValue(pos, kind, timeout);}
    double getPositionActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionActualValue(kind, timeout);}
    void getPositionActualValue(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionActualValue(pos, kind, timeout);}
    double getVelocityDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getVelocityDemandValue(kind, timeout);}
    void getVelocityDemandValue(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getVelocityDemandValue(vel, kind, timeout);}
    double getVelocityActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getVelocityActualValue(kind, timeout);}
    void getVelocityActualValue(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getVelocityActualValue(vel, kind, timeout);}
    double getAccDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAccDemandValue(kind, timeout);}
    void getAccDemandValue(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAccDemandValue(acc, kind, timeout);}
    double getAccActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAccActualValue(kind, timeout);}
    void getAccActualValue(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAccActualValue(acc, kind, timeout);}
    double getRefDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getRefDemandValue(kind, timeout);}
    void getRefDemandValue(double *ref, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getRefDemandValue(ref, kind, timeout);}
    dword getDriveControlMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveControlMask(kind, timeout);}
    void getDriveControlMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveControlMask(mask, kind, timeout);}
    double getCLCurrentPhase1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLCurrentPhase1(kind, timeout);}
    void getCLCurrentPhase1(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLCurrentPhase1(cur, kind, timeout);}
    double getCLCurrentPhase2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLCurrentPhase2(kind, timeout);}
    void getCLCurrentPhase2(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLCurrentPhase2(cur, kind, timeout);}
    double getCLCurrentPhase3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLCurrentPhase3(kind, timeout);}
    void getCLCurrentPhase3(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLCurrentPhase3(cur, kind, timeout);}
    double getCLLktPhase1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLLktPhase1(kind, timeout);}
    void getCLLktPhase1(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLLktPhase1(lkt, kind, timeout);}
    double getCLLktPhase2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLLktPhase2(kind, timeout);}
    void getCLLktPhase2(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLLktPhase2(lkt, kind, timeout);}
    double getCLLktPhase3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLLktPhase3(kind, timeout);}
    void getCLLktPhase3(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLLktPhase3(lkt, kind, timeout);}
    double getCLDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLDemandValue(kind, timeout);}
    void getCLDemandValue(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLDemandValue(cur, kind, timeout);}
    double getCLActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLActualValue(kind, timeout);}
    void getCLActualValue(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLActualValue(cur, kind, timeout);}
    double getEncoderSineSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderSineSignal(kind, timeout);}
    void getEncoderSineSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderSineSignal(val, kind, timeout);}
    double getEncoderCosineSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderCosineSignal(kind, timeout);}
    void getEncoderCosineSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderCosineSignal(val, kind, timeout);}
    double getEncoderIndexSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderIndexSignal(kind, timeout);}
    void getEncoderIndexSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderIndexSignal(val, kind, timeout);}
    double getEncoderHall1Signal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderHall1Signal(kind, timeout);}
    void getEncoderHall1Signal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderHall1Signal(val, kind, timeout);}
    double getEncoderHall2Signal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderHall2Signal(kind, timeout);}
    void getEncoderHall2Signal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderHall2Signal(val, kind, timeout);}
    double getEncoderHall3Signal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderHall3Signal(kind, timeout);}
    void getEncoderHall3Signal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderHall3Signal(val, kind, timeout);}
    dword getEncoderHallDigSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderHallDigSignal(kind, timeout);}
    void getEncoderHallDigSignal(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderHallDigSignal(mask, kind, timeout);}
    dword getDigitalInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDigitalInput(kind, timeout);}
    void getDigitalInput(dword *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDigitalInput(inp, kind, timeout);}
    double getAnalogInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAnalogInput(kind, timeout);}
    void getAnalogInput(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAnalogInput(inp, kind, timeout);}
    dword getXDigitalInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXDigitalInput(kind, timeout);}
    void getXDigitalInput(dword *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXDigitalInput(inp, kind, timeout);}
    double getXAnalogInput1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogInput1(kind, timeout);}
    void getXAnalogInput1(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogInput1(inp, kind, timeout);}
    double getXAnalogInput2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogInput2(kind, timeout);}
    void getXAnalogInput2(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogInput2(inp, kind, timeout);}
    dword getDriveStatus1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveStatus1(kind, timeout);}
    void getDriveStatus1(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveStatus1(mask, kind, timeout);}
    dword getDriveStatus2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveStatus2(kind, timeout);}
    void getDriveStatus2(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveStatus2(mask, kind, timeout);}
    int getErrorCode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getErrorCode(kind, timeout);}
    void getErrorCode(int *code, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getErrorCode(code, kind, timeout);}
    double getCLI2tValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLI2tValue(kind, timeout);}
    void getCLI2tValue(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLI2tValue(val, kind, timeout);}
    int getAxisNumber(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAxisNumber(kind, timeout);}
    void getAxisNumber(int *num, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAxisNumber(num, kind, timeout);}
    int getDaisyChainNumber(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDaisyChainNumber(kind, timeout);}
    void getDaisyChainNumber(int *num, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDaisyChainNumber(num, kind, timeout);}
    double getDriveTemperature(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveTemperature(kind, timeout);}
    void getDriveTemperature(double *temp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveTemperature(temp, kind, timeout);}
    dword getDriveMaskValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveMaskValue(kind, timeout);}
    void getDriveMaskValue(dword *str, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveMaskValue(str, kind, timeout);}
    dword getDriveDisplay(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveDisplay(sidx, kind, timeout);}
    void getDriveDisplay(int sidx, dword *str, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveDisplay(sidx, str, kind, timeout);}
    long getDriveSequenceLine(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveSequenceLine(kind, timeout);}
    void getDriveSequenceLine(long *line, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveSequenceLine(line, kind, timeout);}
    dword getDriveFuseStatus(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveFuseStatus(kind, timeout);}
    void getDriveFuseStatus(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveFuseStatus(mask, kind, timeout);}
    dword getIrqDriveStatus1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIrqDriveStatus1(kind, timeout);}
    void getIrqDriveStatus1(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIrqDriveStatus1(mask, kind, timeout);}
    dword getIrqDriveStatus2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIrqDriveStatus2(kind, timeout);}
    void getIrqDriveStatus2(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIrqDriveStatus2(mask, kind, timeout);}
    dword getAckDriveStatus1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAckDriveStatus1(kind, timeout);}
    void getAckDriveStatus1(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAckDriveStatus1(mask, kind, timeout);}
    dword getAckDriveStatus2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAckDriveStatus2(kind, timeout);}
    void getAckDriveStatus2(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAckDriveStatus2(mask, kind, timeout);}
    dword getIrqPendingAxisMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIrqPendingAxisMask(kind, timeout);}
    void getIrqPendingAxisMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIrqPendingAxisMask(mask, kind, timeout);}
    dword getCanFeedback1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCanFeedback1(kind, timeout);}
    void getCanFeedback1(dword *val1, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCanFeedback1(val1, kind, timeout);}
    dword getCanFeedback2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCanFeedback2(kind, timeout);}
    void getCanFeedback2(dword *val1, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCanFeedback2(val1, kind, timeout);}

    void getPLProportionalGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLProportionalGain(kind, handler, param);}
    void getPLProportionalGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLProportionalGain(handler, param);}
    void getPLSpeedFeedbackGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFeedbackGain(kind, handler, param);}
    void getPLSpeedFeedbackGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFeedbackGain(handler, param);}
    void getPLForceFeedbackGain1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLForceFeedbackGain1(kind, handler, param);}
    void getPLForceFeedbackGain1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLForceFeedbackGain1(handler, param);}
    void getPLIntegratorGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLIntegratorGain(kind, handler, param);}
    void getPLIntegratorGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLIntegratorGain(handler, param);}
    void getPLAntiWindupGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLAntiWindupGain(kind, handler, param);}
    void getPLAntiWindupGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLAntiWindupGain(handler, param);}
    void getPLIntegratorLimitation(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLIntegratorLimitation(kind, handler, param);}
    void getPLIntegratorLimitation(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLIntegratorLimitation(handler, param);}
    void getPLIntegratorMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getPLIntegratorMode(kind, handler, param);}
    void getPLIntegratorMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getPLIntegratorMode(handler, param);}
    void getPLSpeedFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFilter(kind, handler, param);}
    void getPLSpeedFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFilter(handler, param);}
    void getPLOutputFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLOutputFilter(kind, handler, param);}
    void getPLOutputFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLOutputFilter(handler, param);}
    void getCLInputFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLInputFilter(kind, handler, param);}
    void getCLInputFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLInputFilter(handler, param);}
    void getTtlSpecialFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getTtlSpecialFilter(kind, handler, param);}
    void getTtlSpecialFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getTtlSpecialFilter(handler, param);}
    void getPLForceFeedbackGain2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLForceFeedbackGain2(kind, handler, param);}
    void getPLForceFeedbackGain2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLForceFeedbackGain2(handler, param);}
    void getPLSpeedFeedfwdGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFeedfwdGain(kind, handler, param);}
    void getPLSpeedFeedfwdGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFeedfwdGain(handler, param);}
    void getPLAccFeedforwardGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLAccFeedforwardGain(kind, handler, param);}
    void getPLAccFeedforwardGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLAccFeedforwardGain(handler, param);}
    void getCLPhaseAdvanceFactor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLPhaseAdvanceFactor(kind, handler, param);}
    void getCLPhaseAdvanceFactor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLPhaseAdvanceFactor(handler, param);}
    void getAprInputFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAprInputFilter(kind, handler, param);}
    void getAprInputFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAprInputFilter(handler, param);}
    void getCLPhaseAdvanceShift(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLPhaseAdvanceShift(kind, handler, param);}
    void getCLPhaseAdvanceShift(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLPhaseAdvanceShift(handler, param);}
    void getMinPositionRangeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMinPositionRangeLimit(kind, handler, param);}
    void getMinPositionRangeLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMinPositionRangeLimit(handler, param);}
    void getMaxPositionRangeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxPositionRangeLimit(kind, handler, param);}
    void getMaxPositionRangeLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxPositionRangeLimit(handler, param);}
    void getMaxProfileVelocity(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxProfileVelocity(kind, handler, param);}
    void getMaxProfileVelocity(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxProfileVelocity(handler, param);}
    void getMaxAcceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxAcceleration(kind, handler, param);}
    void getMaxAcceleration(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxAcceleration(handler, param);}
    void getFollowingErrorWindow(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getFollowingErrorWindow(kind, handler, param);}
    void getFollowingErrorWindow(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getFollowingErrorWindow(handler, param);}
    void getVelocityErrorLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityErrorLimit(kind, handler, param);}
    void getVelocityErrorLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityErrorLimit(handler, param);}
    void getSwitchLimitMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getSwitchLimitMode(kind, handler, param);}
    void getSwitchLimitMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getSwitchLimitMode(handler, param);}
    void getEnableInputMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getEnableInputMode(kind, handler, param);}
    void getEnableInputMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getEnableInputMode(handler, param);}
    void getMinSoftPositionLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMinSoftPositionLimit(kind, handler, param);}
    void getMinSoftPositionLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMinSoftPositionLimit(handler, param);}
    void getMaxSoftPositionLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxSoftPositionLimit(kind, handler, param);}
    void getMaxSoftPositionLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxSoftPositionLimit(handler, param);}
    void getProfileLimitMode(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getProfileLimitMode(kind, handler, param);}
    void getProfileLimitMode(DsaDWordHandler handler, void *param = NULL) {DsaBase::getProfileLimitMode(handler, param);}
    void getIOErrorEventMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getIOErrorEventMask(kind, handler, param);}
    void getIOErrorEventMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getIOErrorEventMask(handler, param);}
    void getPositionWindowTime(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionWindowTime(kind, handler, param);}
    void getPositionWindowTime(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionWindowTime(handler, param);}
    void getPositionWindow(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionWindow(kind, handler, param);}
    void getPositionWindow(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionWindow(handler, param);}
    void getHomingMethod(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getHomingMethod(kind, handler, param);}
    void getHomingMethod(DsaIntHandler handler, void *param = NULL) {DsaBase::getHomingMethod(handler, param);}
    void getHomingZeroSpeed(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingZeroSpeed(kind, handler, param);}
    void getHomingZeroSpeed(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingZeroSpeed(handler, param);}
    void getHomingAcceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingAcceleration(kind, handler, param);}
    void getHomingAcceleration(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingAcceleration(handler, param);}
    void getHomingFollowingLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFollowingLimit(kind, handler, param);}
    void getHomingFollowingLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFollowingLimit(handler, param);}
    void getHomingCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingCurrentLimit(kind, handler, param);}
    void getHomingCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingCurrentLimit(handler, param);}
    void getHomeOffset(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomeOffset(kind, handler, param);}
    void getHomeOffset(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomeOffset(handler, param);}
    void getHomingFixedMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFixedMvt(kind, handler, param);}
    void getHomingFixedMvt(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFixedMvt(handler, param);}
    void getHomingSwitchMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingSwitchMvt(kind, handler, param);}
    void getHomingSwitchMvt(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingSwitchMvt(handler, param);}
    void getHomingIndexMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingIndexMvt(kind, handler, param);}
    void getHomingIndexMvt(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingIndexMvt(handler, param);}
    void getHomingFineTuningMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getHomingFineTuningMode(kind, handler, param);}
    void getHomingFineTuningMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getHomingFineTuningMode(handler, param);}
    void getHomingFineTuningValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFineTuningValue(kind, handler, param);}
    void getHomingFineTuningValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFineTuningValue(handler, param);}
    void getMotorPhaseCorrection(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMotorPhaseCorrection(kind, handler, param);}
    void getMotorPhaseCorrection(DsaIntHandler handler, void *param = NULL) {DsaBase::getMotorPhaseCorrection(handler, param);}
    void getSoftwareCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSoftwareCurrentLimit(kind, handler, param);}
    void getSoftwareCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSoftwareCurrentLimit(handler, param);}
    void getDriveControlMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDriveControlMode(kind, handler, param);}
    void getDriveControlMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getDriveControlMode(handler, param);}
    void getDisplayMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDisplayMode(kind, handler, param);}
    void getDisplayMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getDisplayMode(handler, param);}
    void getEncoderInversion(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderInversion(kind, handler, param);}
    void getEncoderInversion(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderInversion(handler, param);}
    void getPdrStepValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPdrStepValue(kind, handler, param);}
    void getPdrStepValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPdrStepValue(handler, param);}
    void getEncoderPhase1Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase1Offset(kind, handler, param);}
    void getEncoderPhase1Offset(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase1Offset(handler, param);}
    void getEncoderPhase2Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase2Offset(kind, handler, param);}
    void getEncoderPhase2Offset(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase2Offset(handler, param);}
    void getEncoderPhase1Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase1Factor(kind, handler, param);}
    void getEncoderPhase1Factor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase1Factor(handler, param);}
    void getEncoderPhase2Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase2Factor(kind, handler, param);}
    void getEncoderPhase2Factor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase2Factor(handler, param);}
    void getEncoderPhase3Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase3Offset(kind, handler, param);}
    void getEncoderPhase3Offset(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase3Offset(handler, param);}
    void getEncoderIndexDistance(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderIndexDistance(kind, handler, param);}
    void getEncoderIndexDistance(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderIndexDistance(handler, param);}
    void getEncoderPhase3Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase3Factor(kind, handler, param);}
    void getEncoderPhase3Factor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase3Factor(handler, param);}
    void getCLProportionalGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLProportionalGain(kind, handler, param);}
    void getCLProportionalGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLProportionalGain(handler, param);}
    void getCLIntegratorGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLIntegratorGain(kind, handler, param);}
    void getCLIntegratorGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLIntegratorGain(handler, param);}
    void getCLOutputFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLOutputFilter(kind, handler, param);}
    void getCLOutputFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLOutputFilter(handler, param);}
    void getCLCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentLimit(kind, handler, param);}
    void getCLCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentLimit(handler, param);}
    void getCLI2tCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tCurrentLimit(kind, handler, param);}
    void getCLI2tCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tCurrentLimit(handler, param);}
    void getCLI2tTimeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tTimeLimit(kind, handler, param);}
    void getCLI2tTimeLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tTimeLimit(handler, param);}
    void getCLRegenMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getCLRegenMode(kind, handler, param);}
    void getCLRegenMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getCLRegenMode(handler, param);}
    void getInitMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getInitMode(kind, handler, param);}
    void getInitMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getInitMode(handler, param);}
    void getInitPulseLevel(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitPulseLevel(kind, handler, param);}
    void getInitPulseLevel(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitPulseLevel(handler, param);}
    void getInitMaxCurrent(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitMaxCurrent(kind, handler, param);}
    void getInitMaxCurrent(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitMaxCurrent(handler, param);}
    void getInitFinalPhase(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitFinalPhase(kind, handler, param);}
    void getInitFinalPhase(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitFinalPhase(handler, param);}
    void getInitTime(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitTime(kind, handler, param);}
    void getInitTime(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitTime(handler, param);}
    void getInitCurrentRate(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitCurrentRate(kind, handler, param);}
    void getInitCurrentRate(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitCurrentRate(handler, param);}
    void getInitPhaseRate(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitPhaseRate(kind, handler, param);}
    void getInitPhaseRate(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitPhaseRate(handler, param);}
    void getInitInitialPhase(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitInitialPhase(kind, handler, param);}
    void getInitInitialPhase(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitInitialPhase(handler, param);}
    void getDriveFuseChecking(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveFuseChecking(kind, handler, param);}
    void getDriveFuseChecking(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveFuseChecking(handler, param);}
    void getMotorTempChecking(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getMotorTempChecking(kind, handler, param);}
    void getMotorTempChecking(DsaDWordHandler handler, void *param = NULL) {DsaBase::getMotorTempChecking(handler, param);}
    void getMonSourceType(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonSourceType(sidx, kind, handler, param);}
    void getMonSourceType(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonSourceType(sidx, handler, param);}
    void getMonSourceIndex(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonSourceIndex(sidx, kind, handler, param);}
    void getMonSourceIndex(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonSourceIndex(sidx, handler, param);}
    void getMonDestIndex(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonDestIndex(sidx, kind, handler, param);}
    void getMonDestIndex(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonDestIndex(sidx, handler, param);}
    void getMonOffset(int sidx, int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getMonOffset(sidx, kind, handler, param);}
    void getMonOffset(int sidx, DsaLongHandler handler, void *param = NULL) {DsaBase::getMonOffset(sidx, handler, param);}
    void getMonGain(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMonGain(sidx, kind, handler, param);}
    void getMonGain(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMonGain(sidx, handler, param);}
    void getXAnalogOffset(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOffset(sidx, kind, handler, param);}
    void getXAnalogOffset(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOffset(sidx, handler, param);}
    void getXAnalogGain(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogGain(sidx, kind, handler, param);}
    void getXAnalogGain(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogGain(sidx, handler, param);}
    void getSyncroInputMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getSyncroInputMask(kind, handler, param);}
    void getSyncroInputMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getSyncroInputMask(handler, param);}
    void getSyncroInputValue(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getSyncroInputValue(kind, handler, param);}
    void getSyncroInputValue(DsaDWordHandler handler, void *param = NULL) {DsaBase::getSyncroInputValue(handler, param);}
    void getSyncroOutputMask(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSyncroOutputMask(kind, handler, param);}
    void getSyncroOutputMask(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSyncroOutputMask(handler, param);}
    void getSyncroOutputValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSyncroOutputValue(kind, handler, param);}
    void getSyncroOutputValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSyncroOutputValue(handler, param);}
    void getSyncroStartTimeout(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getSyncroStartTimeout(kind, handler, param);}
    void getSyncroStartTimeout(DsaIntHandler handler, void *param = NULL) {DsaBase::getSyncroStartTimeout(handler, param);}
    void getDigitalOutput(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDigitalOutput(kind, handler, param);}
    void getDigitalOutput(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDigitalOutput(handler, param);}
    void getXDigitalOutput(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getXDigitalOutput(kind, handler, param);}
    void getXDigitalOutput(DsaDWordHandler handler, void *param = NULL) {DsaBase::getXDigitalOutput(handler, param);}
    void getXAnalogOutput1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput1(kind, handler, param);}
    void getXAnalogOutput1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput1(handler, param);}
    void getXAnalogOutput2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput2(kind, handler, param);}
    void getXAnalogOutput2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput2(handler, param);}
    void getAnalogOutput(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAnalogOutput(kind, handler, param);}
    void getAnalogOutput(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAnalogOutput(handler, param);}
    void getInterruptMask1(int sidx, int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getInterruptMask1(sidx, kind, handler, param);}
    void getInterruptMask1(int sidx, DsaDWordHandler handler, void *param = NULL) {DsaBase::getInterruptMask1(sidx, handler, param);}
    void getInterruptMask2(int sidx, int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getInterruptMask2(sidx, kind, handler, param);}
    void getInterruptMask2(int sidx, DsaDWordHandler handler, void *param = NULL) {DsaBase::getInterruptMask2(sidx, handler, param);}
    void getTriggerIrqMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getTriggerIrqMask(kind, handler, param);}
    void getTriggerIrqMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getTriggerIrqMask(handler, param);}
    void getTriggerIOMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getTriggerIOMask(kind, handler, param);}
    void getTriggerIOMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getTriggerIOMask(handler, param);}
    void getTriggerMapOffset(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getTriggerMapOffset(kind, handler, param);}
    void getTriggerMapOffset(DsaIntHandler handler, void *param = NULL) {DsaBase::getTriggerMapOffset(handler, param);}
    void getTriggerMapSize(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getTriggerMapSize(kind, handler, param);}
    void getTriggerMapSize(DsaIntHandler handler, void *param = NULL) {DsaBase::getTriggerMapSize(handler, param);}
    void getRealtimeEnabledGlobal(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getRealtimeEnabledGlobal(kind, handler, param);}
    void getRealtimeEnabledGlobal(DsaIntHandler handler, void *param = NULL) {DsaBase::getRealtimeEnabledGlobal(handler, param);}
    void getRealtimeValidMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getRealtimeValidMask(kind, handler, param);}
    void getRealtimeValidMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getRealtimeValidMask(handler, param);}
    void getRealtimeEnabledMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getRealtimeEnabledMask(kind, handler, param);}
    void getRealtimeEnabledMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getRealtimeEnabledMask(handler, param);}
    void getRealtimePendingMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getRealtimePendingMask(kind, handler, param);}
    void getRealtimePendingMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getRealtimePendingMask(handler, param);}
    void getEblBaudrate(int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getEblBaudrate(kind, handler, param);}
    void getEblBaudrate(DsaLongHandler handler, void *param = NULL) {DsaBase::getEblBaudrate(handler, param);}
    void getIndirectAxisNumber(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectAxisNumber(kind, handler, param);}
    void getIndirectAxisNumber(DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectAxisNumber(handler, param);}
    void getIndirectRegisterIdx(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectRegisterIdx(kind, handler, param);}
    void getIndirectRegisterIdx(DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectRegisterIdx(handler, param);}
    void getIndirectRegisterSidx(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectRegisterSidx(kind, handler, param);}
    void getIndirectRegisterSidx(DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectRegisterSidx(handler, param);}
    void getConcatenatedMvt(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getConcatenatedMvt(kind, handler, param);}
    void getConcatenatedMvt(DsaIntHandler handler, void *param = NULL) {DsaBase::getConcatenatedMvt(handler, param);}
    void getProfileType(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getProfileType(sidx, kind, handler, param);}
    void getProfileType(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getProfileType(sidx, handler, param);}
    void getMvtLktNumber(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMvtLktNumber(sidx, kind, handler, param);}
    void getMvtLktNumber(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getMvtLktNumber(sidx, handler, param);}
    void getMvtLktTime(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMvtLktTime(sidx, kind, handler, param);}
    void getMvtLktTime(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMvtLktTime(sidx, handler, param);}
    void getCameValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCameValue(kind, handler, param);}
    void getCameValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCameValue(handler, param);}
    void getBrakeDeceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getBrakeDeceleration(kind, handler, param);}
    void getBrakeDeceleration(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getBrakeDeceleration(handler, param);}
    void getTargetPosition(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getTargetPosition(sidx, kind, handler, param);}
    void getTargetPosition(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getTargetPosition(sidx, handler, param);}
    void getProfileVelocity(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileVelocity(sidx, kind, handler, param);}
    void getProfileVelocity(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileVelocity(sidx, handler, param);}
    void getProfileAcceleration(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileAcceleration(sidx, kind, handler, param);}
    void getProfileAcceleration(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileAcceleration(sidx, handler, param);}
    void getJerkTime(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getJerkTime(sidx, kind, handler, param);}
    void getJerkTime(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getJerkTime(sidx, handler, param);}
    void getProfileDeceleration(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileDeceleration(sidx, kind, handler, param);}
    void getProfileDeceleration(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileDeceleration(sidx, handler, param);}
    void getEndVelocity(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEndVelocity(sidx, kind, handler, param);}
    void getEndVelocity(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEndVelocity(sidx, handler, param);}
    void getCtrlSourceType(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlSourceType(kind, handler, param);}
    void getCtrlSourceType(DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlSourceType(handler, param);}
    void getCtrlSourceIndex(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlSourceIndex(kind, handler, param);}
    void getCtrlSourceIndex(DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlSourceIndex(handler, param);}
    void getCtrlShiftFactor(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlShiftFactor(kind, handler, param);}
    void getCtrlShiftFactor(DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlShiftFactor(handler, param);}
    void getCtrlOffset(int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getCtrlOffset(kind, handler, param);}
    void getCtrlOffset(DsaLongHandler handler, void *param = NULL) {DsaBase::getCtrlOffset(handler, param);}
    void getCtrlGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCtrlGain(kind, handler, param);}
    void getCtrlGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCtrlGain(handler, param);}
    void getMotorKTFactor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMotorKTFactor(kind, handler, param);}
    void getMotorKTFactor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMotorKTFactor(handler, param);}
    void getPositionCtrlError(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionCtrlError(kind, handler, param);}
    void getPositionCtrlError(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionCtrlError(handler, param);}
    void getPositionMaxError(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionMaxError(kind, handler, param);}
    void getPositionMaxError(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionMaxError(handler, param);}
    void getPositionDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionDemandValue(kind, handler, param);}
    void getPositionDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionDemandValue(handler, param);}
    void getPositionActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionActualValue(kind, handler, param);}
    void getPositionActualValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionActualValue(handler, param);}
    void getVelocityDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityDemandValue(kind, handler, param);}
    void getVelocityDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityDemandValue(handler, param);}
    void getVelocityActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityActualValue(kind, handler, param);}
    void getVelocityActualValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityActualValue(handler, param);}
    void getAccDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAccDemandValue(kind, handler, param);}
    void getAccDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAccDemandValue(handler, param);}
    void getAccActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAccActualValue(kind, handler, param);}
    void getAccActualValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAccActualValue(handler, param);}
    void getRefDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getRefDemandValue(kind, handler, param);}
    void getRefDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getRefDemandValue(handler, param);}
    void getDriveControlMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveControlMask(kind, handler, param);}
    void getDriveControlMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveControlMask(handler, param);}
    void getCLCurrentPhase1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase1(kind, handler, param);}
    void getCLCurrentPhase1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase1(handler, param);}
    void getCLCurrentPhase2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase2(kind, handler, param);}
    void getCLCurrentPhase2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase2(handler, param);}
    void getCLCurrentPhase3(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase3(kind, handler, param);}
    void getCLCurrentPhase3(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase3(handler, param);}
    void getCLLktPhase1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase1(kind, handler, param);}
    void getCLLktPhase1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase1(handler, param);}
    void getCLLktPhase2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase2(kind, handler, param);}
    void getCLLktPhase2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase2(handler, param);}
    void getCLLktPhase3(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase3(kind, handler, param);}
    void getCLLktPhase3(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase3(handler, param);}
    void getCLDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLDemandValue(kind, handler, param);}
    void getCLDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLDemandValue(handler, param);}
    void getCLActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLActualValue(kind, handler, param);}
    void getCLActualValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLActualValue(handler, param);}
    void getEncoderSineSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderSineSignal(kind, handler, param);}
    void getEncoderSineSignal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderSineSignal(handler, param);}
    void getEncoderCosineSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderCosineSignal(kind, handler, param);}
    void getEncoderCosineSignal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderCosineSignal(handler, param);}
    void getEncoderIndexSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderIndexSignal(kind, handler, param);}
    void getEncoderIndexSignal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderIndexSignal(handler, param);}
    void getEncoderHall1Signal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderHall1Signal(kind, handler, param);}
    void getEncoderHall1Signal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderHall1Signal(handler, param);}
    void getEncoderHall2Signal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderHall2Signal(kind, handler, param);}
    void getEncoderHall2Signal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderHall2Signal(handler, param);}
    void getEncoderHall3Signal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderHall3Signal(kind, handler, param);}
    void getEncoderHall3Signal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderHall3Signal(handler, param);}
    void getEncoderHallDigSignal(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getEncoderHallDigSignal(kind, handler, param);}
    void getEncoderHallDigSignal(DsaDWordHandler handler, void *param = NULL) {DsaBase::getEncoderHallDigSignal(handler, param);}
    void getDigitalInput(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDigitalInput(kind, handler, param);}
    void getDigitalInput(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDigitalInput(handler, param);}
    void getAnalogInput(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAnalogInput(kind, handler, param);}
    void getAnalogInput(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAnalogInput(handler, param);}
    void getXDigitalInput(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getXDigitalInput(kind, handler, param);}
    void getXDigitalInput(DsaDWordHandler handler, void *param = NULL) {DsaBase::getXDigitalInput(handler, param);}
    void getXAnalogInput1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput1(kind, handler, param);}
    void getXAnalogInput1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput1(handler, param);}
    void getXAnalogInput2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput2(kind, handler, param);}
    void getXAnalogInput2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput2(handler, param);}
    void getDriveStatus1(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveStatus1(kind, handler, param);}
    void getDriveStatus1(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveStatus1(handler, param);}
    void getDriveStatus2(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveStatus2(kind, handler, param);}
    void getDriveStatus2(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveStatus2(handler, param);}
    void getErrorCode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getErrorCode(kind, handler, param);}
    void getErrorCode(DsaIntHandler handler, void *param = NULL) {DsaBase::getErrorCode(handler, param);}
    void getCLI2tValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tValue(kind, handler, param);}
    void getCLI2tValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tValue(handler, param);}
    void getAxisNumber(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getAxisNumber(kind, handler, param);}
    void getAxisNumber(DsaIntHandler handler, void *param = NULL) {DsaBase::getAxisNumber(handler, param);}
    void getDaisyChainNumber(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDaisyChainNumber(kind, handler, param);}
    void getDaisyChainNumber(DsaIntHandler handler, void *param = NULL) {DsaBase::getDaisyChainNumber(handler, param);}
    void getDriveTemperature(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getDriveTemperature(kind, handler, param);}
    void getDriveTemperature(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getDriveTemperature(handler, param);}
    void getDriveMaskValue(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveMaskValue(kind, handler, param);}
    void getDriveMaskValue(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveMaskValue(handler, param);}
    void getDriveDisplay(int sidx, int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveDisplay(sidx, kind, handler, param);}
    void getDriveDisplay(int sidx, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveDisplay(sidx, handler, param);}
    void getDriveSequenceLine(int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getDriveSequenceLine(kind, handler, param);}
    void getDriveSequenceLine(DsaLongHandler handler, void *param = NULL) {DsaBase::getDriveSequenceLine(handler, param);}
    void getDriveFuseStatus(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveFuseStatus(kind, handler, param);}
    void getDriveFuseStatus(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveFuseStatus(handler, param);}
    void getIrqDriveStatus1(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getIrqDriveStatus1(kind, handler, param);}
    void getIrqDriveStatus1(DsaDWordHandler handler, void *param = NULL) {DsaBase::getIrqDriveStatus1(handler, param);}
    void getIrqDriveStatus2(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getIrqDriveStatus2(kind, handler, param);}
    void getIrqDriveStatus2(DsaDWordHandler handler, void *param = NULL) {DsaBase::getIrqDriveStatus2(handler, param);}
    void getAckDriveStatus1(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getAckDriveStatus1(kind, handler, param);}
    void getAckDriveStatus1(DsaDWordHandler handler, void *param = NULL) {DsaBase::getAckDriveStatus1(handler, param);}
    void getAckDriveStatus2(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getAckDriveStatus2(kind, handler, param);}
    void getAckDriveStatus2(DsaDWordHandler handler, void *param = NULL) {DsaBase::getAckDriveStatus2(handler, param);}
    void getIrqPendingAxisMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getIrqPendingAxisMask(kind, handler, param);}
    void getIrqPendingAxisMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getIrqPendingAxisMask(handler, param);}
    void getCanFeedback1(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getCanFeedback1(kind, handler, param);}
    void getCanFeedback1(DsaDWordHandler handler, void *param = NULL) {DsaBase::getCanFeedback1(handler, param);}
    void getCanFeedback2(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getCanFeedback2(kind, handler, param);}
    void getCanFeedback2(DsaDWordHandler handler, void *param = NULL) {DsaBase::getCanFeedback2(handler, param);}

};


/**
 * DsaDriveGroup class - C++
 */
class DsaDriveGroup: public DsaBase {
	/* constructors */
private:
    void _Group(int max, ...) {
        va_list arg;
        va_start(arg, max);
        ERRCHK(dsa_create_drive_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
        va_end(arg);
    }
protected:
	DsaDriveGroup(void) {
	}
public:
	DsaDriveGroup(DsaDriveGroup &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaDriveGroup(DsaBase &obj) {
		if (!dsa_is_valid_drive_group(obj.dsa))
			throw bad_cast("cannot cast to DsaDevice");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
    DsaDriveGroup(int max, ...) {
        va_list arg;
        va_start(arg, max);
        ERRCHK(dsa_create_drive_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
        va_end(arg);
    }       
    DsaDriveGroup(int max, DsaDriveBase *list[]) {
        ERRCHK(dsa_create_drive_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, list[i]->dsa));
    }       
    DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2) { 
        _Group(2, &d1, &d2); 
    }
    DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3) { 
        _Group(3, &d1, &d2, &d3); 
    }
    DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4) { 
        _Group(4, &d1, &d2, &d3, &d4); 
    }
    DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5) { 
        _Group(5, &d1, &d2, &d3, &d4, &d5); 
    }
    DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6) { 
        _Group(6, &d1, &d2, &d3, &d4, &d5, &d6); 
    }
    DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6, DsaDriveBase d7) { 
        _Group(7, &d1, &d2, &d3, &d4, &d5, &d6, &d7); 
    }
    DsaDriveGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6, DsaDriveBase d7, DsaDriveBase d8) { 
        _Group(8, &d1, &d2, &d3, &d4, &d5, &d6, &d7, &d8); 
    }
	/* operators */
public:
	DsaDriveGroup operator = (DsaDriveGroup &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaDriveGroup operator = (DsaBase &obj) {
		if (!dsa_is_valid_drive_group(obj.dsa))
			throw bad_cast("cannot cast to DsaDriveBase");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* hand make funtions */
public:
	DsaDriveBase getGroupItem(int pos) {return DsaBase::getGroupItem(pos);}
	/* functions */
    void powerOn(long timeout = DEF_TIMEOUT) {DsaBase::powerOn(timeout);}
    void powerOff(long timeout = DEF_TIMEOUT) {DsaBase::powerOff(timeout);}
    void newSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::newSetpoint(sidx, flags, timeout);}
    void changeSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::changeSetpoint(sidx, flags, timeout);}
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    void homingStart(long timeout = DEF_TIMEOUT) {DsaBase::homingStart(timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

    void powerOn(DsaHandler handler, void *param = NULL) {DsaBase::powerOn(handler, param);}
    void powerOff(DsaHandler handler, void *param = NULL) {DsaBase::powerOff(handler, param);}
    void newSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::newSetpoint(sidx, flags, handler, param);}
    void changeSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::changeSetpoint(sidx, flags, handler, param);}
    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void homingStart(DsaHandler handler, void *param = NULL) {DsaBase::homingStart(handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    int  getGroupSize() {return DsaBase::getGroupSize();}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void stepMotion(double pos, long timeout = DEF_TIMEOUT) {DsaBase::stepMotion(pos, timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void canCommand1(dword val1, dword val2, long timeout = DEF_TIMEOUT) {DsaBase::canCommand1(val1, val2, timeout);}
    void canCommand2(dword val1, dword val2, long timeout = DEF_TIMEOUT) {DsaBase::canCommand2(val1, val2, timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void stepMotion(double pos, DsaHandler handler, void *param = NULL) {DsaBase::stepMotion(pos, handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void canCommand1(dword val1, dword val2, DsaHandler handler, void *param = NULL) {DsaBase::canCommand1(val1, val2, handler, param);}
    void canCommand2(dword val1, dword val2, DsaHandler handler, void *param = NULL) {DsaBase::canCommand2(val1, val2, handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */
    void setPLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLProportionalGain(gain, timeout);}
    void setPLSpeedFeedbackGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedbackGain(gain, timeout);}
    void setPLForceFeedbackGain1(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLForceFeedbackGain1(gain, timeout);}
    void setPLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorGain(gain, timeout);}
    void setPLAntiWindupGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLAntiWindupGain(gain, timeout);}
    void setPLIntegratorLimitation(double limit, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorLimitation(limit, timeout);}
    void setPLIntegratorMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorMode(mode, timeout);}
    void setPLSpeedFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFilter(tim, timeout);}
    void setPLOutputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPLOutputFilter(tim, timeout);}
    void setCLInputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLInputFilter(tim, timeout);}
    void setTtlSpecialFilter(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setTtlSpecialFilter(factor, timeout);}
    void setPLForceFeedbackGain2(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLForceFeedbackGain2(factor, timeout);}
    void setPLSpeedFeedfwdGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedfwdGain(factor, timeout);}
    void setPLAccFeedforwardGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLAccFeedforwardGain(factor, timeout);}
    void setCLPhaseAdvanceFactor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCLPhaseAdvanceFactor(factor, timeout);}
    void setAprInputFilter(double time, long timeout = DEF_TIMEOUT) {DsaBase::setAprInputFilter(time, timeout);}
    void setCLPhaseAdvanceShift(double shift, long timeout = DEF_TIMEOUT) {DsaBase::setCLPhaseAdvanceShift(shift, timeout);}
    void setMinPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinPositionRangeLimit(pos, timeout);}
    void setMaxPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxPositionRangeLimit(pos, timeout);}
    void setMaxProfileVelocity(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setMaxProfileVelocity(vel, timeout);}
    void setMaxAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setMaxAcceleration(acc, timeout);}
    void setFollowingErrorWindow(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setFollowingErrorWindow(pos, timeout);}
    void setVelocityErrorLimit(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setVelocityErrorLimit(vel, timeout);}
    void setSwitchLimitMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setSwitchLimitMode(mode, timeout);}
    void setEnableInputMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setEnableInputMode(mode, timeout);}
    void setMinSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinSoftPositionLimit(pos, timeout);}
    void setMaxSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxSoftPositionLimit(pos, timeout);}
    void setProfileLimitMode(dword flags, long timeout = DEF_TIMEOUT) {DsaBase::setProfileLimitMode(flags, timeout);}
    void setIOErrorEventMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setIOErrorEventMask(mask, timeout);}
    void setPositionWindowTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindowTime(tim, timeout);}
    void setPositionWindow(double win, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindow(win, timeout);}
    void setHomingMethod(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingMethod(mode, timeout);}
    void setHomingZeroSpeed(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setHomingZeroSpeed(vel, timeout);}
    void setHomingAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setHomingAcceleration(acc, timeout);}
    void setHomingFollowingLimit(double win, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFollowingLimit(win, timeout);}
    void setHomingCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setHomingCurrentLimit(cur, timeout);}
    void setHomeOffset(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomeOffset(pos, timeout);}
    void setHomingFixedMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFixedMvt(pos, timeout);}
    void setHomingSwitchMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingSwitchMvt(pos, timeout);}
    void setHomingIndexMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingIndexMvt(pos, timeout);}
    void setHomingFineTuningMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningMode(mode, timeout);}
    void setHomingFineTuningValue(double phase, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningValue(phase, timeout);}
    void setMotorPhaseCorrection(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setMotorPhaseCorrection(mode, timeout);}
    void setSoftwareCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setSoftwareCurrentLimit(cur, timeout);}
    void setDriveControlMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDriveControlMode(mode, timeout);}
    void setDisplayMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDisplayMode(mode, timeout);}
    void setEncoderInversion(double invert, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderInversion(invert, timeout);}
    void setPdrStepValue(double step, long timeout = DEF_TIMEOUT) {DsaBase::setPdrStepValue(step, timeout);}
    void setEncoderPhase1Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Offset(offset, timeout);}
    void setEncoderPhase2Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Offset(offset, timeout);}
    void setEncoderPhase1Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Factor(factor, timeout);}
    void setEncoderPhase2Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Factor(factor, timeout);}
    void setEncoderPhase3Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase3Offset(offset, timeout);}
    void setEncoderIndexDistance(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderIndexDistance(pos, timeout);}
    void setEncoderPhase3Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase3Factor(factor, timeout);}
    void setCLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLProportionalGain(gain, timeout);}
    void setCLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLIntegratorGain(gain, timeout);}
    void setCLOutputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLOutputFilter(tim, timeout);}
    void setCLCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLCurrentLimit(cur, timeout);}
    void setCLI2tCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tCurrentLimit(cur, timeout);}
    void setCLI2tTimeLimit(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tTimeLimit(tim, timeout);}
    void setCLRegenMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setCLRegenMode(mode, timeout);}
    void setInitMode(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setInitMode(typ, timeout);}
    void setInitPulseLevel(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitPulseLevel(cur, timeout);}
    void setInitMaxCurrent(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitMaxCurrent(cur, timeout);}
    void setInitFinalPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitFinalPhase(cal, timeout);}
    void setInitTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setInitTime(tim, timeout);}
    void setInitCurrentRate(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitCurrentRate(cur, timeout);}
    void setInitPhaseRate(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitPhaseRate(cal, timeout);}
    void setInitInitialPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitInitialPhase(cal, timeout);}
    void setDriveFuseChecking(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setDriveFuseChecking(mask, timeout);}
    void setMotorTempChecking(dword val, long timeout = DEF_TIMEOUT) {DsaBase::setMotorTempChecking(val, timeout);}
    void setMonSourceType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceType(sidx, typ, timeout);}
    void setMonSourceIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceIndex(sidx, index, timeout);}
    void setMonDestIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonDestIndex(sidx, index, timeout);}
    void setMonOffset(int sidx, long offset, long timeout = DEF_TIMEOUT) {DsaBase::setMonOffset(sidx, offset, timeout);}
    void setMonGain(int sidx, double gain, long timeout = DEF_TIMEOUT) {DsaBase::setMonGain(sidx, gain, timeout);}
    void setXAnalogOffset(int sidx, double offset, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOffset(sidx, offset, timeout);}
    void setXAnalogGain(int sidx, double gain, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogGain(sidx, gain, timeout);}
    void setSyncroInputMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroInputMask(mask, timeout);}
    void setSyncroInputValue(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroInputValue(mask, timeout);}
    void setSyncroOutputMask(double mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroOutputMask(mask, timeout);}
    void setSyncroOutputValue(double mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroOutputValue(mask, timeout);}
    void setSyncroStartTimeout(int tim, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroStartTimeout(tim, timeout);}
    void setDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setDigitalOutput(out, timeout);}
    void setXDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setXDigitalOutput(out, timeout);}
    void setXAnalogOutput1(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput1(out, timeout);}
    void setXAnalogOutput2(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput2(out, timeout);}
    void setAnalogOutput(double out, long timeout = DEF_TIMEOUT) {DsaBase::setAnalogOutput(out, timeout);}
    void setInterruptMask1(int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setInterruptMask1(sidx, mask, timeout);}
    void setInterruptMask2(int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setInterruptMask2(sidx, mask, timeout);}
    void setTriggerIrqMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerIrqMask(mask, timeout);}
    void setTriggerIOMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerIOMask(mask, timeout);}
    void setTriggerMapOffset(int offset, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerMapOffset(offset, timeout);}
    void setTriggerMapSize(int size, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerMapSize(size, timeout);}
    void setRealtimeEnabledGlobal(int enable, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeEnabledGlobal(enable, timeout);}
    void setRealtimeValidMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeValidMask(mask, timeout);}
    void setRealtimeEnabledMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeEnabledMask(mask, timeout);}
    void setRealtimePendingMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimePendingMask(mask, timeout);}
    void setEblBaudrate(long baud, long timeout = DEF_TIMEOUT) {DsaBase::setEblBaudrate(baud, timeout);}
    void setIndirectAxisNumber(int axis, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectAxisNumber(axis, timeout);}
    void setIndirectRegisterIdx(int idx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterIdx(idx, timeout);}
    void setIndirectRegisterSidx(int sidx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterSidx(sidx, timeout);}
    void setConcatenatedMvt(int concat, long timeout = DEF_TIMEOUT) {DsaBase::setConcatenatedMvt(concat, timeout);}
    void setProfileType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setProfileType(sidx, typ, timeout);}
    void setMvtLktNumber(int sidx, int number, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktNumber(sidx, number, timeout);}
    void setMvtLktTime(int sidx, double time, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktTime(sidx, time, timeout);}
    void setCameValue(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCameValue(factor, timeout);}
    void setBrakeDeceleration(double dec, long timeout = DEF_TIMEOUT) {DsaBase::setBrakeDeceleration(dec, timeout);}
    void setTargetPosition(int sidx, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTargetPosition(sidx, pos, timeout);}
    void setProfileVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setProfileVelocity(sidx, vel, timeout);}
    void setProfileAcceleration(int sidx, double acc, long timeout = DEF_TIMEOUT) {DsaBase::setProfileAcceleration(sidx, acc, timeout);}
    void setJerkTime(int sidx, double tim, long timeout = DEF_TIMEOUT) {DsaBase::setJerkTime(sidx, tim, timeout);}
    void setProfileDeceleration(int sidx, double dec, long timeout = DEF_TIMEOUT) {DsaBase::setProfileDeceleration(sidx, dec, timeout);}
    void setEndVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setEndVelocity(sidx, vel, timeout);}
    void setCtrlSourceType(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceType(typ, timeout);}
    void setCtrlSourceIndex(int index, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceIndex(index, timeout);}
    void setCtrlShiftFactor(int shift, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlShiftFactor(shift, timeout);}
    void setCtrlOffset(long offset, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlOffset(offset, timeout);}
    void setCtrlGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlGain(gain, timeout);}
    void setMotorKTFactor(double kt, long timeout = DEF_TIMEOUT) {DsaBase::setMotorKTFactor(kt, timeout);}

    void setPLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLProportionalGain(gain, handler, param);}
    void setPLSpeedFeedbackGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedbackGain(gain, handler, param);}
    void setPLForceFeedbackGain1(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLForceFeedbackGain1(gain, handler, param);}
    void setPLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorGain(gain, handler, param);}
    void setPLAntiWindupGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLAntiWindupGain(gain, handler, param);}
    void setPLIntegratorLimitation(double limit, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorLimitation(limit, handler, param);}
    void setPLIntegratorMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorMode(mode, handler, param);}
    void setPLSpeedFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFilter(tim, handler, param);}
    void setPLOutputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPLOutputFilter(tim, handler, param);}
    void setCLInputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLInputFilter(tim, handler, param);}
    void setTtlSpecialFilter(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setTtlSpecialFilter(factor, handler, param);}
    void setPLForceFeedbackGain2(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLForceFeedbackGain2(factor, handler, param);}
    void setPLSpeedFeedfwdGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedfwdGain(factor, handler, param);}
    void setPLAccFeedforwardGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLAccFeedforwardGain(factor, handler, param);}
    void setCLPhaseAdvanceFactor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCLPhaseAdvanceFactor(factor, handler, param);}
    void setAprInputFilter(double time, DsaHandler handler, void *param = NULL) {DsaBase::setAprInputFilter(time, handler, param);}
    void setCLPhaseAdvanceShift(double shift, DsaHandler handler, void *param = NULL) {DsaBase::setCLPhaseAdvanceShift(shift, handler, param);}
    void setMinPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinPositionRangeLimit(pos, handler, param);}
    void setMaxPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxPositionRangeLimit(pos, handler, param);}
    void setMaxProfileVelocity(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setMaxProfileVelocity(vel, handler, param);}
    void setMaxAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setMaxAcceleration(acc, handler, param);}
    void setFollowingErrorWindow(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setFollowingErrorWindow(pos, handler, param);}
    void setVelocityErrorLimit(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setVelocityErrorLimit(vel, handler, param);}
    void setSwitchLimitMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setSwitchLimitMode(mode, handler, param);}
    void setEnableInputMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setEnableInputMode(mode, handler, param);}
    void setMinSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinSoftPositionLimit(pos, handler, param);}
    void setMaxSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxSoftPositionLimit(pos, handler, param);}
    void setProfileLimitMode(dword flags, DsaHandler handler, void *param = NULL) {DsaBase::setProfileLimitMode(flags, handler, param);}
    void setIOErrorEventMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setIOErrorEventMask(mask, handler, param);}
    void setPositionWindowTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindowTime(tim, handler, param);}
    void setPositionWindow(double win, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindow(win, handler, param);}
    void setHomingMethod(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingMethod(mode, handler, param);}
    void setHomingZeroSpeed(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setHomingZeroSpeed(vel, handler, param);}
    void setHomingAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setHomingAcceleration(acc, handler, param);}
    void setHomingFollowingLimit(double win, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFollowingLimit(win, handler, param);}
    void setHomingCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setHomingCurrentLimit(cur, handler, param);}
    void setHomeOffset(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomeOffset(pos, handler, param);}
    void setHomingFixedMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFixedMvt(pos, handler, param);}
    void setHomingSwitchMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingSwitchMvt(pos, handler, param);}
    void setHomingIndexMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingIndexMvt(pos, handler, param);}
    void setHomingFineTuningMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningMode(mode, handler, param);}
    void setHomingFineTuningValue(double phase, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningValue(phase, handler, param);}
    void setMotorPhaseCorrection(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setMotorPhaseCorrection(mode, handler, param);}
    void setSoftwareCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setSoftwareCurrentLimit(cur, handler, param);}
    void setDriveControlMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDriveControlMode(mode, handler, param);}
    void setDisplayMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDisplayMode(mode, handler, param);}
    void setEncoderInversion(double invert, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderInversion(invert, handler, param);}
    void setPdrStepValue(double step, DsaHandler handler, void *param = NULL) {DsaBase::setPdrStepValue(step, handler, param);}
    void setEncoderPhase1Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Offset(offset, handler, param);}
    void setEncoderPhase2Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Offset(offset, handler, param);}
    void setEncoderPhase1Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Factor(factor, handler, param);}
    void setEncoderPhase2Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Factor(factor, handler, param);}
    void setEncoderPhase3Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase3Offset(offset, handler, param);}
    void setEncoderIndexDistance(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderIndexDistance(pos, handler, param);}
    void setEncoderPhase3Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase3Factor(factor, handler, param);}
    void setCLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLProportionalGain(gain, handler, param);}
    void setCLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLIntegratorGain(gain, handler, param);}
    void setCLOutputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLOutputFilter(tim, handler, param);}
    void setCLCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLCurrentLimit(cur, handler, param);}
    void setCLI2tCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tCurrentLimit(cur, handler, param);}
    void setCLI2tTimeLimit(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tTimeLimit(tim, handler, param);}
    void setCLRegenMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setCLRegenMode(mode, handler, param);}
    void setInitMode(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setInitMode(typ, handler, param);}
    void setInitPulseLevel(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitPulseLevel(cur, handler, param);}
    void setInitMaxCurrent(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitMaxCurrent(cur, handler, param);}
    void setInitFinalPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitFinalPhase(cal, handler, param);}
    void setInitTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setInitTime(tim, handler, param);}
    void setInitCurrentRate(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitCurrentRate(cur, handler, param);}
    void setInitPhaseRate(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitPhaseRate(cal, handler, param);}
    void setInitInitialPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitInitialPhase(cal, handler, param);}
    void setDriveFuseChecking(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setDriveFuseChecking(mask, handler, param);}
    void setMotorTempChecking(dword val, DsaHandler handler, void *param = NULL) {DsaBase::setMotorTempChecking(val, handler, param);}
    void setMonSourceType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceType(sidx, typ, handler, param);}
    void setMonSourceIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceIndex(sidx, index, handler, param);}
    void setMonDestIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonDestIndex(sidx, index, handler, param);}
    void setMonOffset(int sidx, long offset, DsaHandler handler, void *param = NULL) {DsaBase::setMonOffset(sidx, offset, handler, param);}
    void setMonGain(int sidx, double gain, DsaHandler handler, void *param = NULL) {DsaBase::setMonGain(sidx, gain, handler, param);}
    void setXAnalogOffset(int sidx, double offset, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOffset(sidx, offset, handler, param);}
    void setXAnalogGain(int sidx, double gain, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogGain(sidx, gain, handler, param);}
    void setSyncroInputMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroInputMask(mask, handler, param);}
    void setSyncroInputValue(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroInputValue(mask, handler, param);}
    void setSyncroOutputMask(double mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroOutputMask(mask, handler, param);}
    void setSyncroOutputValue(double mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroOutputValue(mask, handler, param);}
    void setSyncroStartTimeout(int tim, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroStartTimeout(tim, handler, param);}
    void setDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setDigitalOutput(out, handler, param);}
    void setXDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setXDigitalOutput(out, handler, param);}
    void setXAnalogOutput1(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput1(out, handler, param);}
    void setXAnalogOutput2(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput2(out, handler, param);}
    void setAnalogOutput(double out, DsaHandler handler, void *param = NULL) {DsaBase::setAnalogOutput(out, handler, param);}
    void setInterruptMask1(int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setInterruptMask1(sidx, mask, handler, param);}
    void setInterruptMask2(int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setInterruptMask2(sidx, mask, handler, param);}
    void setTriggerIrqMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerIrqMask(mask, handler, param);}
    void setTriggerIOMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerIOMask(mask, handler, param);}
    void setTriggerMapOffset(int offset, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerMapOffset(offset, handler, param);}
    void setTriggerMapSize(int size, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerMapSize(size, handler, param);}
    void setRealtimeEnabledGlobal(int enable, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeEnabledGlobal(enable, handler, param);}
    void setRealtimeValidMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeValidMask(mask, handler, param);}
    void setRealtimeEnabledMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeEnabledMask(mask, handler, param);}
    void setRealtimePendingMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimePendingMask(mask, handler, param);}
    void setEblBaudrate(long baud, DsaHandler handler, void *param = NULL) {DsaBase::setEblBaudrate(baud, handler, param);}
    void setIndirectAxisNumber(int axis, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectAxisNumber(axis, handler, param);}
    void setIndirectRegisterIdx(int idx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterIdx(idx, handler, param);}
    void setIndirectRegisterSidx(int sidx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterSidx(sidx, handler, param);}
    void setConcatenatedMvt(int concat, DsaHandler handler, void *param = NULL) {DsaBase::setConcatenatedMvt(concat, handler, param);}
    void setProfileType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setProfileType(sidx, typ, handler, param);}
    void setMvtLktNumber(int sidx, int number, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktNumber(sidx, number, handler, param);}
    void setMvtLktTime(int sidx, double time, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktTime(sidx, time, handler, param);}
    void setCameValue(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCameValue(factor, handler, param);}
    void setBrakeDeceleration(double dec, DsaHandler handler, void *param = NULL) {DsaBase::setBrakeDeceleration(dec, handler, param);}
    void setTargetPosition(int sidx, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTargetPosition(sidx, pos, handler, param);}
    void setProfileVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setProfileVelocity(sidx, vel, handler, param);}
    void setProfileAcceleration(int sidx, double acc, DsaHandler handler, void *param = NULL) {DsaBase::setProfileAcceleration(sidx, acc, handler, param);}
    void setJerkTime(int sidx, double tim, DsaHandler handler, void *param = NULL) {DsaBase::setJerkTime(sidx, tim, handler, param);}
    void setProfileDeceleration(int sidx, double dec, DsaHandler handler, void *param = NULL) {DsaBase::setProfileDeceleration(sidx, dec, handler, param);}
    void setEndVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setEndVelocity(sidx, vel, handler, param);}
    void setCtrlSourceType(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceType(typ, handler, param);}
    void setCtrlSourceIndex(int index, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceIndex(index, handler, param);}
    void setCtrlShiftFactor(int shift, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlShiftFactor(shift, handler, param);}
    void setCtrlOffset(long offset, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlOffset(offset, handler, param);}
    void setCtrlGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlGain(gain, handler, param);}
    void setMotorKTFactor(double kt, DsaHandler handler, void *param = NULL) {DsaBase::setMotorKTFactor(kt, handler, param);}

	/* register getters */


};

/**
 * DsaGantry class - C++
 */
class DsaGantry: public DsaBase {
	/* constructors */
protected:
	DsaGantry(void) {
	}
public:
	DsaGantry(DsaGantry &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaGantry(DsaBase &obj) {
		if (!dsa_is_valid_drive_group(obj.dsa))
			throw bad_cast("cannot cast to DsaDevice");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
    DsaGantry(DsaDriveBase d1, DsaDriveBase d2) { 
        ERRCHK(dsa_set_group_item(dsa, 0, d1.dsa));
        ERRCHK(dsa_set_group_item(dsa, 1, d2.dsa));
    }
	/* operators */
public:
	DsaGantry operator = (DsaGantry &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaGantry operator = (DsaBase &obj) {
		if (!dsa_is_valid_drive_group(obj.dsa))
			throw bad_cast("cannot cast to DsaDriveBase");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* hand make funtions */
public:
	DsaGantry getGroupItem(int pos) {return DsaBase::getGroupItem(pos);}
	/* functions */
    void powerOn(long timeout = DEF_TIMEOUT) {DsaBase::powerOn(timeout);}
    void powerOff(long timeout = DEF_TIMEOUT) {DsaBase::powerOff(timeout);}
    void newSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::newSetpoint(sidx, flags, timeout);}
    void changeSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::changeSetpoint(sidx, flags, timeout);}
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    void homingStart(long timeout = DEF_TIMEOUT) {DsaBase::homingStart(timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    void gantryWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::gantryWaitAndStatusEqual(mask, ref, timeout);}
    void gantryWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::gantryWaitAndStatusNotEqual(mask, ref, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

    void powerOn(DsaHandler handler, void *param = NULL) {DsaBase::powerOn(handler, param);}
    void powerOff(DsaHandler handler, void *param = NULL) {DsaBase::powerOff(handler, param);}
    void newSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::newSetpoint(sidx, flags, handler, param);}
    void changeSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::changeSetpoint(sidx, flags, handler, param);}
    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void homingStart(DsaHandler handler, void *param = NULL) {DsaBase::homingStart(handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void gantryWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::gantryWaitAndStatusEqual(mask, ref, handler, param);}
    void gantryWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::gantryWaitAndStatusNotEqual(mask, ref, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    int  getGroupSize() {return DsaBase::getGroupSize();}
    int  gantryGetErrorCode(int *axis, int kind) {return DsaBase::gantryGetErrorCode(axis, kind);}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    void gantryCancelStatusWait() {DsaBase::gantryCancelStatusWait();}
    DsaStatus  gantryGetAndStatus() {return DsaBase::gantryGetAndStatus();}
    DsaStatus  gantryGetORStatus() {return DsaBase::gantryGetORStatus();}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void stepMotion(double pos, long timeout = DEF_TIMEOUT) {DsaBase::stepMotion(pos, timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void canCommand1(dword val1, dword val2, long timeout = DEF_TIMEOUT) {DsaBase::canCommand1(val1, val2, timeout);}
    void canCommand2(dword val1, dword val2, long timeout = DEF_TIMEOUT) {DsaBase::canCommand2(val1, val2, timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void stepMotion(double pos, DsaHandler handler, void *param = NULL) {DsaBase::stepMotion(pos, handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void canCommand1(dword val1, dword val2, DsaHandler handler, void *param = NULL) {DsaBase::canCommand1(val1, val2, handler, param);}
    void canCommand2(dword val1, dword val2, DsaHandler handler, void *param = NULL) {DsaBase::canCommand2(val1, val2, handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */
    void setPLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLProportionalGain(gain, timeout);}
    void setPLSpeedFeedbackGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedbackGain(gain, timeout);}
    void setPLForceFeedbackGain1(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLForceFeedbackGain1(gain, timeout);}
    void setPLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorGain(gain, timeout);}
    void setPLAntiWindupGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLAntiWindupGain(gain, timeout);}
    void setPLIntegratorLimitation(double limit, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorLimitation(limit, timeout);}
    void setPLIntegratorMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorMode(mode, timeout);}
    void setPLSpeedFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFilter(tim, timeout);}
    void setPLOutputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPLOutputFilter(tim, timeout);}
    void setCLInputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLInputFilter(tim, timeout);}
    void setTtlSpecialFilter(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setTtlSpecialFilter(factor, timeout);}
    void setPLForceFeedbackGain2(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLForceFeedbackGain2(factor, timeout);}
    void setPLSpeedFeedfwdGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedfwdGain(factor, timeout);}
    void setPLAccFeedforwardGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLAccFeedforwardGain(factor, timeout);}
    void setCLPhaseAdvanceFactor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCLPhaseAdvanceFactor(factor, timeout);}
    void setAprInputFilter(double time, long timeout = DEF_TIMEOUT) {DsaBase::setAprInputFilter(time, timeout);}
    void setCLPhaseAdvanceShift(double shift, long timeout = DEF_TIMEOUT) {DsaBase::setCLPhaseAdvanceShift(shift, timeout);}
    void setMinPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinPositionRangeLimit(pos, timeout);}
    void setMaxPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxPositionRangeLimit(pos, timeout);}
    void setMaxProfileVelocity(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setMaxProfileVelocity(vel, timeout);}
    void setMaxAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setMaxAcceleration(acc, timeout);}
    void setFollowingErrorWindow(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setFollowingErrorWindow(pos, timeout);}
    void setVelocityErrorLimit(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setVelocityErrorLimit(vel, timeout);}
    void setSwitchLimitMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setSwitchLimitMode(mode, timeout);}
    void setEnableInputMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setEnableInputMode(mode, timeout);}
    void setMinSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinSoftPositionLimit(pos, timeout);}
    void setMaxSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxSoftPositionLimit(pos, timeout);}
    void setProfileLimitMode(dword flags, long timeout = DEF_TIMEOUT) {DsaBase::setProfileLimitMode(flags, timeout);}
    void setIOErrorEventMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setIOErrorEventMask(mask, timeout);}
    void setPositionWindowTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindowTime(tim, timeout);}
    void setPositionWindow(double win, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindow(win, timeout);}
    void setHomingMethod(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingMethod(mode, timeout);}
    void setHomingZeroSpeed(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setHomingZeroSpeed(vel, timeout);}
    void setHomingAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setHomingAcceleration(acc, timeout);}
    void setHomingFollowingLimit(double win, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFollowingLimit(win, timeout);}
    void setHomingCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setHomingCurrentLimit(cur, timeout);}
    void setHomeOffset(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomeOffset(pos, timeout);}
    void setHomingFixedMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFixedMvt(pos, timeout);}
    void setHomingSwitchMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingSwitchMvt(pos, timeout);}
    void setHomingIndexMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingIndexMvt(pos, timeout);}
    void setHomingFineTuningMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningMode(mode, timeout);}
    void setHomingFineTuningValue(double phase, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningValue(phase, timeout);}
    void setMotorPhaseCorrection(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setMotorPhaseCorrection(mode, timeout);}
    void setSoftwareCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setSoftwareCurrentLimit(cur, timeout);}
    void setDriveControlMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDriveControlMode(mode, timeout);}
    void setDisplayMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDisplayMode(mode, timeout);}
    void setEncoderInversion(double invert, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderInversion(invert, timeout);}
    void setPdrStepValue(double step, long timeout = DEF_TIMEOUT) {DsaBase::setPdrStepValue(step, timeout);}
    void setEncoderPhase1Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Offset(offset, timeout);}
    void setEncoderPhase2Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Offset(offset, timeout);}
    void setEncoderPhase1Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Factor(factor, timeout);}
    void setEncoderPhase2Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Factor(factor, timeout);}
    void setEncoderPhase3Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase3Offset(offset, timeout);}
    void setEncoderIndexDistance(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderIndexDistance(pos, timeout);}
    void setEncoderPhase3Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase3Factor(factor, timeout);}
    void setCLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLProportionalGain(gain, timeout);}
    void setCLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLIntegratorGain(gain, timeout);}
    void setCLOutputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLOutputFilter(tim, timeout);}
    void setCLCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLCurrentLimit(cur, timeout);}
    void setCLI2tCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tCurrentLimit(cur, timeout);}
    void setCLI2tTimeLimit(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tTimeLimit(tim, timeout);}
    void setCLRegenMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setCLRegenMode(mode, timeout);}
    void setInitMode(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setInitMode(typ, timeout);}
    void setInitPulseLevel(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitPulseLevel(cur, timeout);}
    void setInitMaxCurrent(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitMaxCurrent(cur, timeout);}
    void setInitFinalPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitFinalPhase(cal, timeout);}
    void setInitTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setInitTime(tim, timeout);}
    void setInitCurrentRate(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitCurrentRate(cur, timeout);}
    void setInitPhaseRate(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitPhaseRate(cal, timeout);}
    void setInitInitialPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitInitialPhase(cal, timeout);}
    void setDriveFuseChecking(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setDriveFuseChecking(mask, timeout);}
    void setMotorTempChecking(dword val, long timeout = DEF_TIMEOUT) {DsaBase::setMotorTempChecking(val, timeout);}
    void setMonSourceType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceType(sidx, typ, timeout);}
    void setMonSourceIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceIndex(sidx, index, timeout);}
    void setMonDestIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonDestIndex(sidx, index, timeout);}
    void setMonOffset(int sidx, long offset, long timeout = DEF_TIMEOUT) {DsaBase::setMonOffset(sidx, offset, timeout);}
    void setMonGain(int sidx, double gain, long timeout = DEF_TIMEOUT) {DsaBase::setMonGain(sidx, gain, timeout);}
    void setXAnalogOffset(int sidx, double offset, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOffset(sidx, offset, timeout);}
    void setXAnalogGain(int sidx, double gain, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogGain(sidx, gain, timeout);}
    void setSyncroInputMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroInputMask(mask, timeout);}
    void setSyncroInputValue(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroInputValue(mask, timeout);}
    void setSyncroOutputMask(double mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroOutputMask(mask, timeout);}
    void setSyncroOutputValue(double mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroOutputValue(mask, timeout);}
    void setSyncroStartTimeout(int tim, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroStartTimeout(tim, timeout);}
    void setDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setDigitalOutput(out, timeout);}
    void setXDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setXDigitalOutput(out, timeout);}
    void setXAnalogOutput1(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput1(out, timeout);}
    void setXAnalogOutput2(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput2(out, timeout);}
    void setAnalogOutput(double out, long timeout = DEF_TIMEOUT) {DsaBase::setAnalogOutput(out, timeout);}
    void setInterruptMask1(int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setInterruptMask1(sidx, mask, timeout);}
    void setInterruptMask2(int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setInterruptMask2(sidx, mask, timeout);}
    void setTriggerIrqMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerIrqMask(mask, timeout);}
    void setTriggerIOMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerIOMask(mask, timeout);}
    void setTriggerMapOffset(int offset, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerMapOffset(offset, timeout);}
    void setTriggerMapSize(int size, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerMapSize(size, timeout);}
    void setRealtimeEnabledGlobal(int enable, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeEnabledGlobal(enable, timeout);}
    void setRealtimeValidMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeValidMask(mask, timeout);}
    void setRealtimeEnabledMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeEnabledMask(mask, timeout);}
    void setRealtimePendingMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimePendingMask(mask, timeout);}
    void setEblBaudrate(long baud, long timeout = DEF_TIMEOUT) {DsaBase::setEblBaudrate(baud, timeout);}
    void setIndirectAxisNumber(int axis, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectAxisNumber(axis, timeout);}
    void setIndirectRegisterIdx(int idx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterIdx(idx, timeout);}
    void setIndirectRegisterSidx(int sidx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterSidx(sidx, timeout);}
    void setConcatenatedMvt(int concat, long timeout = DEF_TIMEOUT) {DsaBase::setConcatenatedMvt(concat, timeout);}
    void setProfileType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setProfileType(sidx, typ, timeout);}
    void setMvtLktNumber(int sidx, int number, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktNumber(sidx, number, timeout);}
    void setMvtLktTime(int sidx, double time, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktTime(sidx, time, timeout);}
    void setCameValue(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCameValue(factor, timeout);}
    void setBrakeDeceleration(double dec, long timeout = DEF_TIMEOUT) {DsaBase::setBrakeDeceleration(dec, timeout);}
    void setTargetPosition(int sidx, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTargetPosition(sidx, pos, timeout);}
    void setProfileVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setProfileVelocity(sidx, vel, timeout);}
    void setProfileAcceleration(int sidx, double acc, long timeout = DEF_TIMEOUT) {DsaBase::setProfileAcceleration(sidx, acc, timeout);}
    void setJerkTime(int sidx, double tim, long timeout = DEF_TIMEOUT) {DsaBase::setJerkTime(sidx, tim, timeout);}
    void setProfileDeceleration(int sidx, double dec, long timeout = DEF_TIMEOUT) {DsaBase::setProfileDeceleration(sidx, dec, timeout);}
    void setEndVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setEndVelocity(sidx, vel, timeout);}
    void setCtrlSourceType(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceType(typ, timeout);}
    void setCtrlSourceIndex(int index, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceIndex(index, timeout);}
    void setCtrlShiftFactor(int shift, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlShiftFactor(shift, timeout);}
    void setCtrlOffset(long offset, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlOffset(offset, timeout);}
    void setCtrlGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlGain(gain, timeout);}
    void setMotorKTFactor(double kt, long timeout = DEF_TIMEOUT) {DsaBase::setMotorKTFactor(kt, timeout);}

    void setPLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLProportionalGain(gain, handler, param);}
    void setPLSpeedFeedbackGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedbackGain(gain, handler, param);}
    void setPLForceFeedbackGain1(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLForceFeedbackGain1(gain, handler, param);}
    void setPLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorGain(gain, handler, param);}
    void setPLAntiWindupGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLAntiWindupGain(gain, handler, param);}
    void setPLIntegratorLimitation(double limit, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorLimitation(limit, handler, param);}
    void setPLIntegratorMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorMode(mode, handler, param);}
    void setPLSpeedFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFilter(tim, handler, param);}
    void setPLOutputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPLOutputFilter(tim, handler, param);}
    void setCLInputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLInputFilter(tim, handler, param);}
    void setTtlSpecialFilter(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setTtlSpecialFilter(factor, handler, param);}
    void setPLForceFeedbackGain2(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLForceFeedbackGain2(factor, handler, param);}
    void setPLSpeedFeedfwdGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedfwdGain(factor, handler, param);}
    void setPLAccFeedforwardGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLAccFeedforwardGain(factor, handler, param);}
    void setCLPhaseAdvanceFactor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCLPhaseAdvanceFactor(factor, handler, param);}
    void setAprInputFilter(double time, DsaHandler handler, void *param = NULL) {DsaBase::setAprInputFilter(time, handler, param);}
    void setCLPhaseAdvanceShift(double shift, DsaHandler handler, void *param = NULL) {DsaBase::setCLPhaseAdvanceShift(shift, handler, param);}
    void setMinPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinPositionRangeLimit(pos, handler, param);}
    void setMaxPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxPositionRangeLimit(pos, handler, param);}
    void setMaxProfileVelocity(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setMaxProfileVelocity(vel, handler, param);}
    void setMaxAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setMaxAcceleration(acc, handler, param);}
    void setFollowingErrorWindow(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setFollowingErrorWindow(pos, handler, param);}
    void setVelocityErrorLimit(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setVelocityErrorLimit(vel, handler, param);}
    void setSwitchLimitMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setSwitchLimitMode(mode, handler, param);}
    void setEnableInputMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setEnableInputMode(mode, handler, param);}
    void setMinSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinSoftPositionLimit(pos, handler, param);}
    void setMaxSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxSoftPositionLimit(pos, handler, param);}
    void setProfileLimitMode(dword flags, DsaHandler handler, void *param = NULL) {DsaBase::setProfileLimitMode(flags, handler, param);}
    void setIOErrorEventMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setIOErrorEventMask(mask, handler, param);}
    void setPositionWindowTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindowTime(tim, handler, param);}
    void setPositionWindow(double win, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindow(win, handler, param);}
    void setHomingMethod(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingMethod(mode, handler, param);}
    void setHomingZeroSpeed(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setHomingZeroSpeed(vel, handler, param);}
    void setHomingAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setHomingAcceleration(acc, handler, param);}
    void setHomingFollowingLimit(double win, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFollowingLimit(win, handler, param);}
    void setHomingCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setHomingCurrentLimit(cur, handler, param);}
    void setHomeOffset(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomeOffset(pos, handler, param);}
    void setHomingFixedMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFixedMvt(pos, handler, param);}
    void setHomingSwitchMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingSwitchMvt(pos, handler, param);}
    void setHomingIndexMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingIndexMvt(pos, handler, param);}
    void setHomingFineTuningMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningMode(mode, handler, param);}
    void setHomingFineTuningValue(double phase, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningValue(phase, handler, param);}
    void setMotorPhaseCorrection(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setMotorPhaseCorrection(mode, handler, param);}
    void setSoftwareCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setSoftwareCurrentLimit(cur, handler, param);}
    void setDriveControlMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDriveControlMode(mode, handler, param);}
    void setDisplayMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDisplayMode(mode, handler, param);}
    void setEncoderInversion(double invert, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderInversion(invert, handler, param);}
    void setPdrStepValue(double step, DsaHandler handler, void *param = NULL) {DsaBase::setPdrStepValue(step, handler, param);}
    void setEncoderPhase1Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Offset(offset, handler, param);}
    void setEncoderPhase2Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Offset(offset, handler, param);}
    void setEncoderPhase1Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Factor(factor, handler, param);}
    void setEncoderPhase2Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Factor(factor, handler, param);}
    void setEncoderPhase3Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase3Offset(offset, handler, param);}
    void setEncoderIndexDistance(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderIndexDistance(pos, handler, param);}
    void setEncoderPhase3Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase3Factor(factor, handler, param);}
    void setCLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLProportionalGain(gain, handler, param);}
    void setCLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLIntegratorGain(gain, handler, param);}
    void setCLOutputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLOutputFilter(tim, handler, param);}
    void setCLCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLCurrentLimit(cur, handler, param);}
    void setCLI2tCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tCurrentLimit(cur, handler, param);}
    void setCLI2tTimeLimit(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tTimeLimit(tim, handler, param);}
    void setCLRegenMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setCLRegenMode(mode, handler, param);}
    void setInitMode(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setInitMode(typ, handler, param);}
    void setInitPulseLevel(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitPulseLevel(cur, handler, param);}
    void setInitMaxCurrent(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitMaxCurrent(cur, handler, param);}
    void setInitFinalPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitFinalPhase(cal, handler, param);}
    void setInitTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setInitTime(tim, handler, param);}
    void setInitCurrentRate(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitCurrentRate(cur, handler, param);}
    void setInitPhaseRate(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitPhaseRate(cal, handler, param);}
    void setInitInitialPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitInitialPhase(cal, handler, param);}
    void setDriveFuseChecking(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setDriveFuseChecking(mask, handler, param);}
    void setMotorTempChecking(dword val, DsaHandler handler, void *param = NULL) {DsaBase::setMotorTempChecking(val, handler, param);}
    void setMonSourceType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceType(sidx, typ, handler, param);}
    void setMonSourceIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceIndex(sidx, index, handler, param);}
    void setMonDestIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonDestIndex(sidx, index, handler, param);}
    void setMonOffset(int sidx, long offset, DsaHandler handler, void *param = NULL) {DsaBase::setMonOffset(sidx, offset, handler, param);}
    void setMonGain(int sidx, double gain, DsaHandler handler, void *param = NULL) {DsaBase::setMonGain(sidx, gain, handler, param);}
    void setXAnalogOffset(int sidx, double offset, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOffset(sidx, offset, handler, param);}
    void setXAnalogGain(int sidx, double gain, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogGain(sidx, gain, handler, param);}
    void setSyncroInputMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroInputMask(mask, handler, param);}
    void setSyncroInputValue(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroInputValue(mask, handler, param);}
    void setSyncroOutputMask(double mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroOutputMask(mask, handler, param);}
    void setSyncroOutputValue(double mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroOutputValue(mask, handler, param);}
    void setSyncroStartTimeout(int tim, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroStartTimeout(tim, handler, param);}
    void setDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setDigitalOutput(out, handler, param);}
    void setXDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setXDigitalOutput(out, handler, param);}
    void setXAnalogOutput1(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput1(out, handler, param);}
    void setXAnalogOutput2(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput2(out, handler, param);}
    void setAnalogOutput(double out, DsaHandler handler, void *param = NULL) {DsaBase::setAnalogOutput(out, handler, param);}
    void setInterruptMask1(int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setInterruptMask1(sidx, mask, handler, param);}
    void setInterruptMask2(int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setInterruptMask2(sidx, mask, handler, param);}
    void setTriggerIrqMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerIrqMask(mask, handler, param);}
    void setTriggerIOMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerIOMask(mask, handler, param);}
    void setTriggerMapOffset(int offset, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerMapOffset(offset, handler, param);}
    void setTriggerMapSize(int size, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerMapSize(size, handler, param);}
    void setRealtimeEnabledGlobal(int enable, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeEnabledGlobal(enable, handler, param);}
    void setRealtimeValidMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeValidMask(mask, handler, param);}
    void setRealtimeEnabledMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeEnabledMask(mask, handler, param);}
    void setRealtimePendingMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimePendingMask(mask, handler, param);}
    void setEblBaudrate(long baud, DsaHandler handler, void *param = NULL) {DsaBase::setEblBaudrate(baud, handler, param);}
    void setIndirectAxisNumber(int axis, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectAxisNumber(axis, handler, param);}
    void setIndirectRegisterIdx(int idx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterIdx(idx, handler, param);}
    void setIndirectRegisterSidx(int sidx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterSidx(sidx, handler, param);}
    void setConcatenatedMvt(int concat, DsaHandler handler, void *param = NULL) {DsaBase::setConcatenatedMvt(concat, handler, param);}
    void setProfileType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setProfileType(sidx, typ, handler, param);}
    void setMvtLktNumber(int sidx, int number, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktNumber(sidx, number, handler, param);}
    void setMvtLktTime(int sidx, double time, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktTime(sidx, time, handler, param);}
    void setCameValue(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCameValue(factor, handler, param);}
    void setBrakeDeceleration(double dec, DsaHandler handler, void *param = NULL) {DsaBase::setBrakeDeceleration(dec, handler, param);}
    void setTargetPosition(int sidx, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTargetPosition(sidx, pos, handler, param);}
    void setProfileVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setProfileVelocity(sidx, vel, handler, param);}
    void setProfileAcceleration(int sidx, double acc, DsaHandler handler, void *param = NULL) {DsaBase::setProfileAcceleration(sidx, acc, handler, param);}
    void setJerkTime(int sidx, double tim, DsaHandler handler, void *param = NULL) {DsaBase::setJerkTime(sidx, tim, handler, param);}
    void setProfileDeceleration(int sidx, double dec, DsaHandler handler, void *param = NULL) {DsaBase::setProfileDeceleration(sidx, dec, handler, param);}
    void setEndVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setEndVelocity(sidx, vel, handler, param);}
    void setCtrlSourceType(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceType(typ, handler, param);}
    void setCtrlSourceIndex(int index, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceIndex(index, handler, param);}
    void setCtrlShiftFactor(int shift, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlShiftFactor(shift, handler, param);}
    void setCtrlOffset(long offset, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlOffset(offset, handler, param);}
    void setCtrlGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlGain(gain, handler, param);}
    void setMotorKTFactor(double kt, DsaHandler handler, void *param = NULL) {DsaBase::setMotorKTFactor(kt, handler, param);}

	/* register getters */


};

/**
 * DsaDsmaxBase class - C++
 */
class DsaDsmaxBase: public DsaBase {
	/* constructors */
protected:
	DsaDsmaxBase(void) {
	}
public:
	DsaDsmaxBase(DsaDsmaxBase &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaDsmaxBase(DsaBase &obj) {
		if (!dsa_is_valid_dsmax_base(obj.dsa))
			throw bad_cast("cannot cast to DsaDsmaxBase");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	/* operators */
public:
	DsaDsmaxBase operator = (DsaDsmaxBase &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaDsmaxBase operator = (DsaBase &obj) {
		if (!dsa_is_valid_dsmax_base(obj.dsa))
			throw bad_cast("cannot cast to DsaDsmaxBase");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* functions */
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */


	/* register getters */


};


/**
 * DsaDsmax class - C++
 */
class DsaDsmax: public DsaBase {
	/* constructors */
public:
	DsaDsmax(void) {
		dsa = NULL;
		ERRCHK(dsa_create_dsmax(&dsa));
	}
	DsaDsmax(DsaDsmax &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaDsmax(DsaBase &obj) {
		if (!dsa_is_valid_dsmax(obj.dsa))
			throw bad_cast("cannot cast to DsaDsmax");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	/* operators */
public:
	DsaDsmax operator = (DsaDsmax &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaDsmax operator = (DsaBase &obj) {
		if (!dsa_is_valid_dsmax(obj.dsa))
			throw bad_cast("cannot cast to DsaDsmax");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* functions */
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    int  getWarningCode(int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getWarningCode(kind, timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    long  getRegister(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegister(typ, idx, sidx, kind, timeout);}
    void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    double  getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, timeout);}
    void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, long timeout = DEF_TIMEOUT) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, timeout);}
    DsaStatus  waitStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusEqual(mask, ref, timeout);}
    DsaStatus  waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusNotEqual(mask, ref, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    DsaStatus  waitStatusChange(DsaStatus *mask, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusChange(mask, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void getWarningCode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getWarningCode(kind, handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void getRegister(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getRegister(typ, idx, sidx, kind, handler, param);}
    void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, handler, param);}
    void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, Dsa2intHandler handler, void *param = NULL) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, handler, param);}
    void waitStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusEqual(mask, ref, handler, param);}
    void waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusNotEqual(mask, ref, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void waitStatusChange(DsaStatus *mask, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusChange(mask, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

    void open(EtbBus etb, int axis) {DsaBase::open(etb, axis);}
    void open(char_cp url) {DsaBase::open(url);}
    void open(EtbBus etb, int axis, dword flags) {DsaBase::open(etb, axis, flags);}
    void reset() {DsaBase::reset();}
    void close() {DsaBase::close();}
    EtbBus  getEtbBus() {return DsaBase::getEtbBus();}
    int  getEtbAxis() {return DsaBase::getEtbAxis();}
    bool  isOpen() {return DsaBase::isOpen();}
    int getMotorTyp() {return DsaBase::getMotorTyp();}
    void getErrorText(char_p text, int size, int code) {DsaBase::getErrorText(text, size, code);}
    void getWarningText(char_p text, int size, int code) {DsaBase::getWarningText(text, size, code);}
    double  convertToIso(long inc, int conv) {return DsaBase::convertToIso(inc, conv);}
    long  convertFromIso(double iso, int conv) {return DsaBase::convertFromIso(iso, conv);}
    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    DsaInfo  getInfo() {return DsaBase::getInfo();}
    DsaStatus  getStatus() {return DsaBase::getStatus();}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    DsaStatus  getStatusFromDrive(long timeout = DEF_TIMEOUT) {return DsaBase::getStatusFromDrive(timeout);}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}
    DsaXInfo  getXInfo() {return DsaBase::getXInfo();}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */


	/* register getters */


};


/**
 * DsaDsmaxGroup class - C++
 */
class DsaDsmaxGroup: public DsaBase {
	/* constructors */
private:
    void _Group(int max, ...) {
        va_list arg;
        va_start(arg, max);
        ERRCHK(dsa_create_dsmax_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
        va_end(arg);
    }
protected:
	DsaDsmaxGroup(void) {
	}
public:
	DsaDsmaxGroup(DsaDsmaxGroup &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaDsmaxGroup(DsaBase &obj) {
		if (!dsa_is_valid_dsmax_group(obj.dsa))
			throw bad_cast("cannot cast to DsaDsmaxGroup");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
    DsaDsmaxGroup(int max, ...) {
        va_list arg;
        va_start(arg, max);
        ERRCHK(dsa_create_dsmax_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
        va_end(arg);
    }       
    DsaDsmaxGroup(int max, DsaDriveBase *list[]) {
        ERRCHK(dsa_create_dsmax_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, list[i]->dsa));
    }       
    DsaDsmaxGroup(DsaDriveBase d1, DsaDriveBase d2) { 
        _Group(2, &d1, &d2); 
    }
    DsaDsmaxGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3) { 
        _Group(3, &d1, &d2, &d3); 
    }
    DsaDsmaxGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4) { 
        _Group(4, &d1, &d2, &d3, &d4); 
    }
    DsaDsmaxGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5) { 
        _Group(5, &d1, &d2, &d3, &d4, &d5); 
    }
    DsaDsmaxGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6) { 
        _Group(6, &d1, &d2, &d3, &d4, &d5, &d6); 
    }
    DsaDsmaxGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6, DsaDriveBase d7) { 
        _Group(7, &d1, &d2, &d3, &d4, &d5, &d6, &d7); 
    }
    DsaDsmaxGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6, DsaDriveBase d7, DsaDriveBase d8) { 
        _Group(8, &d1, &d2, &d3, &d4, &d5, &d6, &d7, &d8); 
    }
	/* operators */
public:
	DsaDsmaxGroup operator = (DsaDsmaxGroup &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaDsmaxGroup operator = (DsaBase &obj) {
		if (!dsa_is_valid_dsmax_group(obj.dsa))
			throw bad_cast("cannot cast to DsaDsmaxGroup");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* functions */
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    int  getGroupSize() {return DsaBase::getGroupSize();}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */


	/* register getters */


};


/**
 * DsaIpolGroup class - C++
 */
class DsaIpolGroup: public DsaBase {
	/* constructors */
private:
    void _Group(int max, ...) {
        va_list arg;
        va_start(arg, max);
        ERRCHK(dsa_create_ipol_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
        va_end(arg);
    }
protected:
	DsaIpolGroup(void) {
	}
public:
	DsaIpolGroup(DsaIpolGroup &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaIpolGroup(DsaBase &obj) {
		if (!dsa_is_valid_ipol_group(obj.dsa))
			throw bad_cast("cannot cast to DsaIpolGroup");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
    DsaIpolGroup(int max, ...) {
        va_list arg;
        va_start(arg, max);
        ERRCHK(dsa_create_ipol_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
        va_end(arg);
    }       
    DsaIpolGroup(int max, DsaDriveBase *list[]) {
        ERRCHK(dsa_create_ipol_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, list[i]->dsa));
    }       
    DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2) { 
        _Group(2, &d1, &d2); 
    }
    DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3) { 
        _Group(3, &d1, &d2, &d3); 
    }
    DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4) { 
        _Group(4, &d1, &d2, &d3, &d4); 
    }
    DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5) { 
        _Group(5, &d1, &d2, &d3, &d4, &d5); 
    }
    DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6) { 
        _Group(6, &d1, &d2, &d3, &d4, &d5, &d6); 
    }
    DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6, DsaDriveBase d7) { 
        _Group(7, &d1, &d2, &d3, &d4, &d5, &d6, &d7); 
    }
    DsaIpolGroup(DsaDriveBase d1, DsaDriveBase d2, DsaDriveBase d3, DsaDriveBase d4, DsaDriveBase d5, DsaDriveBase d6, DsaDriveBase d7, DsaDriveBase d8) { 
        _Group(8, &d1, &d2, &d3, &d4, &d5, &d6, &d7, &d8); 
    }
	/* operators */
public:
	DsaIpolGroup operator = (DsaIpolGroup &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaIpolGroup operator = (DsaBase &obj) {
		if (!dsa_is_valid_ipol_group(obj.dsa))
			throw bad_cast("cannot cast to DsaIpolGroup");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* hand make funtions */
public:
	DsaDriveBase getGroupItem(int pos) {return DsaBase::getGroupItem(pos);}
	DsaDsmax getDsmax(void) {return DsaBase::getDsmax();}
	void setDsmax(DsaDsmax dsmax) {DsaBase::setDsmax(dsmax);}
	/* functions */
    void powerOn(long timeout = DEF_TIMEOUT) {DsaBase::powerOn(timeout);}
    void powerOff(long timeout = DEF_TIMEOUT) {DsaBase::powerOff(timeout);}
    void newSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::newSetpoint(sidx, flags, timeout);}
    void changeSetpoint(int sidx, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::changeSetpoint(sidx, flags, timeout);}
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    void homingStart(long timeout = DEF_TIMEOUT) {DsaBase::homingStart(timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void ipolBegin(long timeout = DEF_TIMEOUT) {DsaBase::ipolBegin(timeout);}
    void ipolEnd(long timeout = DEF_TIMEOUT) {DsaBase::ipolEnd(timeout);}
    void ipolBeginConcatenation(long timeout = DEF_TIMEOUT) {DsaBase::ipolBeginConcatenation(timeout);}
    void ipolEndConcatenation(long timeout = DEF_TIMEOUT) {DsaBase::ipolEndConcatenation(timeout);}
    void ipolLine(DsaVector *dest, long timeout = DEF_TIMEOUT) {DsaBase::ipolLine(dest, timeout);}
    void ipolCircleCWR2d(double x, double y, double r, long timeout = DEF_TIMEOUT) {DsaBase::ipolCircleCWR2d(x, y, r, timeout);}
    void ipolCircleCcwR2d(double x, double y, double r, long timeout = DEF_TIMEOUT) {DsaBase::ipolCircleCcwR2d(x, y, r, timeout);}
    void ipolTanVelocity(double velocity, long timeout = DEF_TIMEOUT) {DsaBase::ipolTanVelocity(velocity, timeout);}
    void ipolTanAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::ipolTanAcceleration(acc, timeout);}
    void ipolTanDeceleration(double dec, long timeout = DEF_TIMEOUT) {DsaBase::ipolTanDeceleration(dec, timeout);}
    void ipolTanJerkTime(double jerk_time, long timeout = DEF_TIMEOUT) {DsaBase::ipolTanJerkTime(jerk_time, timeout);}
    void ipolQuickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::ipolQuickStop(mode, flags, timeout);}
    void ipolContinue(long timeout = DEF_TIMEOUT) {DsaBase::ipolContinue(timeout);}
    void ipolReset(long timeout = DEF_TIMEOUT) {DsaBase::ipolReset(timeout);}
    void ipolPvt(DsaVector *dest, DsaVector *velocity, double time, long timeout = DEF_TIMEOUT) {DsaBase::ipolPvt(dest, velocity, time, timeout);}
    void ipolMark(long number, long operation, long op_param, long timeout = DEF_TIMEOUT) {DsaBase::ipolMark(number, operation, op_param, timeout);}
    void ipolSetVelocityRate(double rate, long timeout = DEF_TIMEOUT) {DsaBase::ipolSetVelocityRate(rate, timeout);}
    void ipolCircleCWC2d(double x, double y, double cx, double cy, long timeout = DEF_TIMEOUT) {DsaBase::ipolCircleCWC2d(x, y, cx, cy, timeout);}
    void ipolCircleCcwC2d(double x, double y, double cx, double cy, long timeout = DEF_TIMEOUT) {DsaBase::ipolCircleCcwC2d(x, y, cx, cy, timeout);}
    void ipolLine(double x, double y, long timeout = DEF_TIMEOUT) {DsaBase::ipolLine(x, y, timeout);}
    void ipolWaitMovement(long timeout = DEF_TIMEOUT) {DsaBase::ipolWaitMovement(timeout);}
    void ipolPrepare(long timeout = DEF_TIMEOUT) {DsaBase::ipolPrepare(timeout);}
    void ipolPvtUpdate(int depth, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::ipolPvtUpdate(depth, mask, timeout);}
    void ipolPvtRegTyp(DsaVector *dest, DsaVectorTyp destTyp, DsaVector *velocity, DsaVectorTyp velocityTyp, double time, int timeTyp, long timeout = DEF_TIMEOUT) {DsaBase::ipolPvtRegTyp(dest, destTyp, velocity, velocityTyp, time, timeTyp, timeout);}
    void ipolSetLktSpeedRatio(double value, long timeout = DEF_TIMEOUT) {DsaBase::ipolSetLktSpeedRatio(value, timeout);}
    void ipolSetLktCyclicMode(bool active, long timeout = DEF_TIMEOUT) {DsaBase::ipolSetLktCyclicMode(active, timeout);}
    void ipolSetLktRelativeMode(bool active, long timeout = DEF_TIMEOUT) {DsaBase::ipolSetLktRelativeMode(active, timeout);}
    void ipolLkt(DsaVector *dest, DsaIntVector *lkt_number, double time, long timeout = DEF_TIMEOUT) {DsaBase::ipolLkt(dest, lkt_number, time, timeout);}
    void ipolWaitMark(int mark, long timeout = DEF_TIMEOUT) {DsaBase::ipolWaitMark(mark, timeout);}
    void ipolUline(DsaVector *dest, long timeout = DEF_TIMEOUT) {DsaBase::ipolUline(dest, timeout);}
    void ipolUline(double x, double y, long timeout = DEF_TIMEOUT) {DsaBase::ipolUline(x, y, timeout);}
    void ipolDisableUconcatenation(long timeout = DEF_TIMEOUT) {DsaBase::ipolDisableUconcatenation(timeout);}
    void ipolSetUrelativeMode(bool active, long timeout = DEF_TIMEOUT) {DsaBase::ipolSetUrelativeMode(active, timeout);}
    void ipolUspeedAxisMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::ipolUspeedAxisMask(mask, timeout);}
    void ipolUspeed(double speed, long timeout = DEF_TIMEOUT) {DsaBase::ipolUspeed(speed, timeout);}
    void ipolUtime(double acc_time, double jerk_time, long timeout = DEF_TIMEOUT) {DsaBase::ipolUtime(acc_time, jerk_time, timeout);}
    void ipolTranslateMatrix(DsaVector *trans, long timeout = DEF_TIMEOUT) {DsaBase::ipolTranslateMatrix(trans, timeout);}
    void ipolScaleMatrix(DsaVector *scale, long timeout = DEF_TIMEOUT) {DsaBase::ipolScaleMatrix(scale, timeout);}
    void ipolRotateMatrix(int plan, double degree, long timeout = DEF_TIMEOUT) {DsaBase::ipolRotateMatrix(plan, degree, timeout);}
    void ipolTranslateMatrix(double x, double y, long timeout = DEF_TIMEOUT) {DsaBase::ipolTranslateMatrix(x, y, timeout);}
    void ipolScaleMatrix(double x, double y, long timeout = DEF_TIMEOUT) {DsaBase::ipolScaleMatrix(x, y, timeout);}
    void ipolShearMatrix(int sheared_axis, double axis1_shearing, double axis2_shearing, double axis3_shearing, long timeout = DEF_TIMEOUT) {DsaBase::ipolShearMatrix(sheared_axis, axis1_shearing, axis2_shearing, axis3_shearing, timeout);}
    void ipolLock(long timeout = DEF_TIMEOUT) {DsaBase::ipolLock(timeout);}
    void ipolUnlock(long timeout = DEF_TIMEOUT) {DsaBase::ipolUnlock(timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

    void powerOn(DsaHandler handler, void *param = NULL) {DsaBase::powerOn(handler, param);}
    void powerOff(DsaHandler handler, void *param = NULL) {DsaBase::powerOff(handler, param);}
    void newSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::newSetpoint(sidx, flags, handler, param);}
    void changeSetpoint(int sidx, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::changeSetpoint(sidx, flags, handler, param);}
    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void homingStart(DsaHandler handler, void *param = NULL) {DsaBase::homingStart(handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void ipolBegin(DsaHandler handler, void *param = NULL) {DsaBase::ipolBegin(handler, param);}
    void ipolEnd(DsaHandler handler, void *param = NULL) {DsaBase::ipolEnd(handler, param);}
    void ipolBeginConcatenation(DsaHandler handler, void *param = NULL) {DsaBase::ipolBeginConcatenation(handler, param);}
    void ipolEndConcatenation(DsaHandler handler, void *param = NULL) {DsaBase::ipolEndConcatenation(handler, param);}
    void ipolLine(DsaVector *dest, DsaHandler handler, void *param = NULL) {DsaBase::ipolLine(dest, handler, param);}
    void ipolCircleCWR2d(double x, double y, double r, DsaHandler handler, void *param = NULL) {DsaBase::ipolCircleCWR2d(x, y, r, handler, param);}
    void ipolCircleCcwR2d(double x, double y, double r, DsaHandler handler, void *param = NULL) {DsaBase::ipolCircleCcwR2d(x, y, r, handler, param);}
    void ipolTanVelocity(double velocity, DsaHandler handler, void *param = NULL) {DsaBase::ipolTanVelocity(velocity, handler, param);}
    void ipolTanAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::ipolTanAcceleration(acc, handler, param);}
    void ipolTanDeceleration(double dec, DsaHandler handler, void *param = NULL) {DsaBase::ipolTanDeceleration(dec, handler, param);}
    void ipolTanJerkTime(double jerk_time, DsaHandler handler, void *param = NULL) {DsaBase::ipolTanJerkTime(jerk_time, handler, param);}
    void ipolQuickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::ipolQuickStop(mode, flags, handler, param);}
    void ipolContinue(DsaHandler handler, void *param = NULL) {DsaBase::ipolContinue(handler, param);}
    void ipolReset(DsaHandler handler, void *param = NULL) {DsaBase::ipolReset(handler, param);}
    void ipolPvt(DsaVector *dest, DsaVector *velocity, double time, DsaHandler handler, void *param = NULL) {DsaBase::ipolPvt(dest, velocity, time, handler, param);}
    void ipolMark(long number, long operation, long op_param, DsaHandler handler, void *param = NULL) {DsaBase::ipolMark(number, operation, op_param, handler, param);}
    void ipolSetVelocityRate(double rate, DsaHandler handler, void *param = NULL) {DsaBase::ipolSetVelocityRate(rate, handler, param);}
    void ipolCircleCWC2d(double x, double y, double cx, double cy, DsaHandler handler, void *param = NULL) {DsaBase::ipolCircleCWC2d(x, y, cx, cy, handler, param);}
    void ipolCircleCcwC2d(double x, double y, double cx, double cy, DsaHandler handler, void *param = NULL) {DsaBase::ipolCircleCcwC2d(x, y, cx, cy, handler, param);}
    void ipolLine(double x, double y, DsaHandler handler, void *param = NULL) {DsaBase::ipolLine(x, y, handler, param);}
    void ipolWaitMovement(DsaHandler handler, void *param = NULL) {DsaBase::ipolWaitMovement(handler, param);}
    void ipolPrepare(DsaHandler handler, void *param = NULL) {DsaBase::ipolPrepare(handler, param);}
    void ipolPvtUpdate(int depth, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::ipolPvtUpdate(depth, mask, handler, param);}
    void ipolPvtRegTyp(DsaVector *dest, DsaVectorTyp destTyp, DsaVector *velocity, DsaVectorTyp velocityTyp, double time, int timeTyp, DsaHandler handler, void *param = NULL) {DsaBase::ipolPvtRegTyp(dest, destTyp, velocity, velocityTyp, time, timeTyp, handler, param);}
    void ipolSetLktSpeedRatio(double value, DsaHandler handler, void *param = NULL) {DsaBase::ipolSetLktSpeedRatio(value, handler, param);}
    void ipolSetLktCyclicMode(bool active, DsaHandler handler, void *param = NULL) {DsaBase::ipolSetLktCyclicMode(active, handler, param);}
    void ipolSetLktRelativeMode(bool active, DsaHandler handler, void *param = NULL) {DsaBase::ipolSetLktRelativeMode(active, handler, param);}
    void ipolLkt(DsaVector *dest, DsaIntVector *lkt_number, double time, DsaHandler handler, void *param = NULL) {DsaBase::ipolLkt(dest, lkt_number, time, handler, param);}
    void ipolWaitMark(int mark, DsaHandler handler, void *param = NULL) {DsaBase::ipolWaitMark(mark, handler, param);}
    void ipolUline(DsaVector *dest, DsaHandler handler, void *param = NULL) {DsaBase::ipolUline(dest, handler, param);}
    void ipolUline(double x, double y, DsaHandler handler, void *param = NULL) {DsaBase::ipolUline(x, y, handler, param);}
    void ipolDisableUconcatenation(DsaHandler handler, void *param = NULL) {DsaBase::ipolDisableUconcatenation(handler, param);}
    void ipolSetUrelativeMode(bool active, DsaHandler handler, void *param = NULL) {DsaBase::ipolSetUrelativeMode(active, handler, param);}
    void ipolUspeedAxisMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::ipolUspeedAxisMask(mask, handler, param);}
    void ipolUspeed(double speed, DsaHandler handler, void *param = NULL) {DsaBase::ipolUspeed(speed, handler, param);}
    void ipolUtime(double acc_time, double jerk_time, DsaHandler handler, void *param = NULL) {DsaBase::ipolUtime(acc_time, jerk_time, handler, param);}
    void ipolTranslateMatrix(DsaVector *trans, DsaHandler handler, void *param = NULL) {DsaBase::ipolTranslateMatrix(trans, handler, param);}
    void ipolScaleMatrix(DsaVector *scale, DsaHandler handler, void *param = NULL) {DsaBase::ipolScaleMatrix(scale, handler, param);}
    void ipolRotateMatrix(int plan, double degree, DsaHandler handler, void *param = NULL) {DsaBase::ipolRotateMatrix(plan, degree, handler, param);}
    void ipolTranslateMatrix(double x, double y, DsaHandler handler, void *param = NULL) {DsaBase::ipolTranslateMatrix(x, y, handler, param);}
    void ipolScaleMatrix(double x, double y, DsaHandler handler, void *param = NULL) {DsaBase::ipolScaleMatrix(x, y, handler, param);}
    void ipolShearMatrix(int sheared_axis, double axis1_shearing, double axis2_shearing, double axis3_shearing, DsaHandler handler, void *param = NULL) {DsaBase::ipolShearMatrix(sheared_axis, axis1_shearing, axis2_shearing, axis3_shearing, handler, param);}
    void ipolLock(DsaHandler handler, void *param = NULL) {DsaBase::ipolLock(handler, param);}
    void ipolUnlock(DsaHandler handler, void *param = NULL) {DsaBase::ipolUnlock(handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    int  getGroupSize() {return DsaBase::getGroupSize();}
    bool isIpolINProgress() {return DsaBase::isIpolINProgress();}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void stepMotion(double pos, long timeout = DEF_TIMEOUT) {DsaBase::stepMotion(pos, timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void canCommand1(dword val1, dword val2, long timeout = DEF_TIMEOUT) {DsaBase::canCommand1(val1, val2, timeout);}
    void canCommand2(dword val1, dword val2, long timeout = DEF_TIMEOUT) {DsaBase::canCommand2(val1, val2, timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void stepMotion(double pos, DsaHandler handler, void *param = NULL) {DsaBase::stepMotion(pos, handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void canCommand1(dword val1, dword val2, DsaHandler handler, void *param = NULL) {DsaBase::canCommand1(val1, val2, handler, param);}
    void canCommand2(dword val1, dword val2, DsaHandler handler, void *param = NULL) {DsaBase::canCommand2(val1, val2, handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */
    void setPLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLProportionalGain(gain, timeout);}
    void setPLSpeedFeedbackGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedbackGain(gain, timeout);}
    void setPLForceFeedbackGain1(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLForceFeedbackGain1(gain, timeout);}
    void setPLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorGain(gain, timeout);}
    void setPLAntiWindupGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setPLAntiWindupGain(gain, timeout);}
    void setPLIntegratorLimitation(double limit, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorLimitation(limit, timeout);}
    void setPLIntegratorMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setPLIntegratorMode(mode, timeout);}
    void setPLSpeedFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFilter(tim, timeout);}
    void setPLOutputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPLOutputFilter(tim, timeout);}
    void setCLInputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLInputFilter(tim, timeout);}
    void setTtlSpecialFilter(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setTtlSpecialFilter(factor, timeout);}
    void setPLForceFeedbackGain2(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLForceFeedbackGain2(factor, timeout);}
    void setPLSpeedFeedfwdGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLSpeedFeedfwdGain(factor, timeout);}
    void setPLAccFeedforwardGain(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setPLAccFeedforwardGain(factor, timeout);}
    void setCLPhaseAdvanceFactor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCLPhaseAdvanceFactor(factor, timeout);}
    void setAprInputFilter(double time, long timeout = DEF_TIMEOUT) {DsaBase::setAprInputFilter(time, timeout);}
    void setCLPhaseAdvanceShift(double shift, long timeout = DEF_TIMEOUT) {DsaBase::setCLPhaseAdvanceShift(shift, timeout);}
    void setMinPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinPositionRangeLimit(pos, timeout);}
    void setMaxPositionRangeLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxPositionRangeLimit(pos, timeout);}
    void setMaxProfileVelocity(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setMaxProfileVelocity(vel, timeout);}
    void setMaxAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setMaxAcceleration(acc, timeout);}
    void setFollowingErrorWindow(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setFollowingErrorWindow(pos, timeout);}
    void setVelocityErrorLimit(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setVelocityErrorLimit(vel, timeout);}
    void setSwitchLimitMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setSwitchLimitMode(mode, timeout);}
    void setEnableInputMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setEnableInputMode(mode, timeout);}
    void setMinSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMinSoftPositionLimit(pos, timeout);}
    void setMaxSoftPositionLimit(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setMaxSoftPositionLimit(pos, timeout);}
    void setProfileLimitMode(dword flags, long timeout = DEF_TIMEOUT) {DsaBase::setProfileLimitMode(flags, timeout);}
    void setIOErrorEventMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setIOErrorEventMask(mask, timeout);}
    void setPositionWindowTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindowTime(tim, timeout);}
    void setPositionWindow(double win, long timeout = DEF_TIMEOUT) {DsaBase::setPositionWindow(win, timeout);}
    void setHomingMethod(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingMethod(mode, timeout);}
    void setHomingZeroSpeed(double vel, long timeout = DEF_TIMEOUT) {DsaBase::setHomingZeroSpeed(vel, timeout);}
    void setHomingAcceleration(double acc, long timeout = DEF_TIMEOUT) {DsaBase::setHomingAcceleration(acc, timeout);}
    void setHomingFollowingLimit(double win, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFollowingLimit(win, timeout);}
    void setHomingCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setHomingCurrentLimit(cur, timeout);}
    void setHomeOffset(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomeOffset(pos, timeout);}
    void setHomingFixedMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFixedMvt(pos, timeout);}
    void setHomingSwitchMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingSwitchMvt(pos, timeout);}
    void setHomingIndexMvt(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setHomingIndexMvt(pos, timeout);}
    void setHomingFineTuningMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningMode(mode, timeout);}
    void setHomingFineTuningValue(double phase, long timeout = DEF_TIMEOUT) {DsaBase::setHomingFineTuningValue(phase, timeout);}
    void setMotorPhaseCorrection(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setMotorPhaseCorrection(mode, timeout);}
    void setSoftwareCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setSoftwareCurrentLimit(cur, timeout);}
    void setDriveControlMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDriveControlMode(mode, timeout);}
    void setDisplayMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setDisplayMode(mode, timeout);}
    void setEncoderInversion(double invert, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderInversion(invert, timeout);}
    void setPdrStepValue(double step, long timeout = DEF_TIMEOUT) {DsaBase::setPdrStepValue(step, timeout);}
    void setEncoderPhase1Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Offset(offset, timeout);}
    void setEncoderPhase2Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Offset(offset, timeout);}
    void setEncoderPhase1Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase1Factor(factor, timeout);}
    void setEncoderPhase2Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase2Factor(factor, timeout);}
    void setEncoderPhase3Offset(double offset, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase3Offset(offset, timeout);}
    void setEncoderIndexDistance(double pos, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderIndexDistance(pos, timeout);}
    void setEncoderPhase3Factor(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setEncoderPhase3Factor(factor, timeout);}
    void setCLProportionalGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLProportionalGain(gain, timeout);}
    void setCLIntegratorGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCLIntegratorGain(gain, timeout);}
    void setCLOutputFilter(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLOutputFilter(tim, timeout);}
    void setCLCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLCurrentLimit(cur, timeout);}
    void setCLI2tCurrentLimit(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tCurrentLimit(cur, timeout);}
    void setCLI2tTimeLimit(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setCLI2tTimeLimit(tim, timeout);}
    void setCLRegenMode(int mode, long timeout = DEF_TIMEOUT) {DsaBase::setCLRegenMode(mode, timeout);}
    void setInitMode(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setInitMode(typ, timeout);}
    void setInitPulseLevel(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitPulseLevel(cur, timeout);}
    void setInitMaxCurrent(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitMaxCurrent(cur, timeout);}
    void setInitFinalPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitFinalPhase(cal, timeout);}
    void setInitTime(double tim, long timeout = DEF_TIMEOUT) {DsaBase::setInitTime(tim, timeout);}
    void setInitCurrentRate(double cur, long timeout = DEF_TIMEOUT) {DsaBase::setInitCurrentRate(cur, timeout);}
    void setInitPhaseRate(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitPhaseRate(cal, timeout);}
    void setInitInitialPhase(double cal, long timeout = DEF_TIMEOUT) {DsaBase::setInitInitialPhase(cal, timeout);}
    void setDriveFuseChecking(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setDriveFuseChecking(mask, timeout);}
    void setMotorTempChecking(dword val, long timeout = DEF_TIMEOUT) {DsaBase::setMotorTempChecking(val, timeout);}
    void setMonSourceType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceType(sidx, typ, timeout);}
    void setMonSourceIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonSourceIndex(sidx, index, timeout);}
    void setMonDestIndex(int sidx, int index, long timeout = DEF_TIMEOUT) {DsaBase::setMonDestIndex(sidx, index, timeout);}
    void setMonOffset(int sidx, long offset, long timeout = DEF_TIMEOUT) {DsaBase::setMonOffset(sidx, offset, timeout);}
    void setMonGain(int sidx, double gain, long timeout = DEF_TIMEOUT) {DsaBase::setMonGain(sidx, gain, timeout);}
    void setXAnalogOffset(int sidx, double offset, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOffset(sidx, offset, timeout);}
    void setXAnalogGain(int sidx, double gain, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogGain(sidx, gain, timeout);}
    void setSyncroInputMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroInputMask(mask, timeout);}
    void setSyncroInputValue(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroInputValue(mask, timeout);}
    void setSyncroOutputMask(double mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroOutputMask(mask, timeout);}
    void setSyncroOutputValue(double mask, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroOutputValue(mask, timeout);}
    void setSyncroStartTimeout(int tim, long timeout = DEF_TIMEOUT) {DsaBase::setSyncroStartTimeout(tim, timeout);}
    void setDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setDigitalOutput(out, timeout);}
    void setXDigitalOutput(dword out, long timeout = DEF_TIMEOUT) {DsaBase::setXDigitalOutput(out, timeout);}
    void setXAnalogOutput1(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput1(out, timeout);}
    void setXAnalogOutput2(double out, long timeout = DEF_TIMEOUT) {DsaBase::setXAnalogOutput2(out, timeout);}
    void setAnalogOutput(double out, long timeout = DEF_TIMEOUT) {DsaBase::setAnalogOutput(out, timeout);}
    void setInterruptMask1(int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setInterruptMask1(sidx, mask, timeout);}
    void setInterruptMask2(int sidx, dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setInterruptMask2(sidx, mask, timeout);}
    void setTriggerIrqMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerIrqMask(mask, timeout);}
    void setTriggerIOMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerIOMask(mask, timeout);}
    void setTriggerMapOffset(int offset, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerMapOffset(offset, timeout);}
    void setTriggerMapSize(int size, long timeout = DEF_TIMEOUT) {DsaBase::setTriggerMapSize(size, timeout);}
    void setRealtimeEnabledGlobal(int enable, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeEnabledGlobal(enable, timeout);}
    void setRealtimeValidMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeValidMask(mask, timeout);}
    void setRealtimeEnabledMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimeEnabledMask(mask, timeout);}
    void setRealtimePendingMask(dword mask, long timeout = DEF_TIMEOUT) {DsaBase::setRealtimePendingMask(mask, timeout);}
    void setEblBaudrate(long baud, long timeout = DEF_TIMEOUT) {DsaBase::setEblBaudrate(baud, timeout);}
    void setIndirectAxisNumber(int axis, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectAxisNumber(axis, timeout);}
    void setIndirectRegisterIdx(int idx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterIdx(idx, timeout);}
    void setIndirectRegisterSidx(int sidx, long timeout = DEF_TIMEOUT) {DsaBase::setIndirectRegisterSidx(sidx, timeout);}
    void setConcatenatedMvt(int concat, long timeout = DEF_TIMEOUT) {DsaBase::setConcatenatedMvt(concat, timeout);}
    void setProfileType(int sidx, int typ, long timeout = DEF_TIMEOUT) {DsaBase::setProfileType(sidx, typ, timeout);}
    void setMvtLktNumber(int sidx, int number, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktNumber(sidx, number, timeout);}
    void setMvtLktTime(int sidx, double time, long timeout = DEF_TIMEOUT) {DsaBase::setMvtLktTime(sidx, time, timeout);}
    void setCameValue(double factor, long timeout = DEF_TIMEOUT) {DsaBase::setCameValue(factor, timeout);}
    void setBrakeDeceleration(double dec, long timeout = DEF_TIMEOUT) {DsaBase::setBrakeDeceleration(dec, timeout);}
    void setTargetPosition(int sidx, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTargetPosition(sidx, pos, timeout);}
    void setProfileVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setProfileVelocity(sidx, vel, timeout);}
    void setProfileAcceleration(int sidx, double acc, long timeout = DEF_TIMEOUT) {DsaBase::setProfileAcceleration(sidx, acc, timeout);}
    void setJerkTime(int sidx, double tim, long timeout = DEF_TIMEOUT) {DsaBase::setJerkTime(sidx, tim, timeout);}
    void setProfileDeceleration(int sidx, double dec, long timeout = DEF_TIMEOUT) {DsaBase::setProfileDeceleration(sidx, dec, timeout);}
    void setEndVelocity(int sidx, double vel, long timeout = DEF_TIMEOUT) {DsaBase::setEndVelocity(sidx, vel, timeout);}
    void setCtrlSourceType(int typ, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceType(typ, timeout);}
    void setCtrlSourceIndex(int index, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlSourceIndex(index, timeout);}
    void setCtrlShiftFactor(int shift, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlShiftFactor(shift, timeout);}
    void setCtrlOffset(long offset, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlOffset(offset, timeout);}
    void setCtrlGain(double gain, long timeout = DEF_TIMEOUT) {DsaBase::setCtrlGain(gain, timeout);}
    void setMotorKTFactor(double kt, long timeout = DEF_TIMEOUT) {DsaBase::setMotorKTFactor(kt, timeout);}

    void setPLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLProportionalGain(gain, handler, param);}
    void setPLSpeedFeedbackGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedbackGain(gain, handler, param);}
    void setPLForceFeedbackGain1(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLForceFeedbackGain1(gain, handler, param);}
    void setPLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorGain(gain, handler, param);}
    void setPLAntiWindupGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setPLAntiWindupGain(gain, handler, param);}
    void setPLIntegratorLimitation(double limit, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorLimitation(limit, handler, param);}
    void setPLIntegratorMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setPLIntegratorMode(mode, handler, param);}
    void setPLSpeedFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFilter(tim, handler, param);}
    void setPLOutputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPLOutputFilter(tim, handler, param);}
    void setCLInputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLInputFilter(tim, handler, param);}
    void setTtlSpecialFilter(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setTtlSpecialFilter(factor, handler, param);}
    void setPLForceFeedbackGain2(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLForceFeedbackGain2(factor, handler, param);}
    void setPLSpeedFeedfwdGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLSpeedFeedfwdGain(factor, handler, param);}
    void setPLAccFeedforwardGain(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setPLAccFeedforwardGain(factor, handler, param);}
    void setCLPhaseAdvanceFactor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCLPhaseAdvanceFactor(factor, handler, param);}
    void setAprInputFilter(double time, DsaHandler handler, void *param = NULL) {DsaBase::setAprInputFilter(time, handler, param);}
    void setCLPhaseAdvanceShift(double shift, DsaHandler handler, void *param = NULL) {DsaBase::setCLPhaseAdvanceShift(shift, handler, param);}
    void setMinPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinPositionRangeLimit(pos, handler, param);}
    void setMaxPositionRangeLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxPositionRangeLimit(pos, handler, param);}
    void setMaxProfileVelocity(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setMaxProfileVelocity(vel, handler, param);}
    void setMaxAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setMaxAcceleration(acc, handler, param);}
    void setFollowingErrorWindow(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setFollowingErrorWindow(pos, handler, param);}
    void setVelocityErrorLimit(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setVelocityErrorLimit(vel, handler, param);}
    void setSwitchLimitMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setSwitchLimitMode(mode, handler, param);}
    void setEnableInputMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setEnableInputMode(mode, handler, param);}
    void setMinSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMinSoftPositionLimit(pos, handler, param);}
    void setMaxSoftPositionLimit(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setMaxSoftPositionLimit(pos, handler, param);}
    void setProfileLimitMode(dword flags, DsaHandler handler, void *param = NULL) {DsaBase::setProfileLimitMode(flags, handler, param);}
    void setIOErrorEventMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setIOErrorEventMask(mask, handler, param);}
    void setPositionWindowTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindowTime(tim, handler, param);}
    void setPositionWindow(double win, DsaHandler handler, void *param = NULL) {DsaBase::setPositionWindow(win, handler, param);}
    void setHomingMethod(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingMethod(mode, handler, param);}
    void setHomingZeroSpeed(double vel, DsaHandler handler, void *param = NULL) {DsaBase::setHomingZeroSpeed(vel, handler, param);}
    void setHomingAcceleration(double acc, DsaHandler handler, void *param = NULL) {DsaBase::setHomingAcceleration(acc, handler, param);}
    void setHomingFollowingLimit(double win, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFollowingLimit(win, handler, param);}
    void setHomingCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setHomingCurrentLimit(cur, handler, param);}
    void setHomeOffset(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomeOffset(pos, handler, param);}
    void setHomingFixedMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFixedMvt(pos, handler, param);}
    void setHomingSwitchMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingSwitchMvt(pos, handler, param);}
    void setHomingIndexMvt(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setHomingIndexMvt(pos, handler, param);}
    void setHomingFineTuningMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningMode(mode, handler, param);}
    void setHomingFineTuningValue(double phase, DsaHandler handler, void *param = NULL) {DsaBase::setHomingFineTuningValue(phase, handler, param);}
    void setMotorPhaseCorrection(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setMotorPhaseCorrection(mode, handler, param);}
    void setSoftwareCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setSoftwareCurrentLimit(cur, handler, param);}
    void setDriveControlMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDriveControlMode(mode, handler, param);}
    void setDisplayMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setDisplayMode(mode, handler, param);}
    void setEncoderInversion(double invert, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderInversion(invert, handler, param);}
    void setPdrStepValue(double step, DsaHandler handler, void *param = NULL) {DsaBase::setPdrStepValue(step, handler, param);}
    void setEncoderPhase1Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Offset(offset, handler, param);}
    void setEncoderPhase2Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Offset(offset, handler, param);}
    void setEncoderPhase1Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase1Factor(factor, handler, param);}
    void setEncoderPhase2Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase2Factor(factor, handler, param);}
    void setEncoderPhase3Offset(double offset, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase3Offset(offset, handler, param);}
    void setEncoderIndexDistance(double pos, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderIndexDistance(pos, handler, param);}
    void setEncoderPhase3Factor(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setEncoderPhase3Factor(factor, handler, param);}
    void setCLProportionalGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLProportionalGain(gain, handler, param);}
    void setCLIntegratorGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCLIntegratorGain(gain, handler, param);}
    void setCLOutputFilter(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLOutputFilter(tim, handler, param);}
    void setCLCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLCurrentLimit(cur, handler, param);}
    void setCLI2tCurrentLimit(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tCurrentLimit(cur, handler, param);}
    void setCLI2tTimeLimit(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setCLI2tTimeLimit(tim, handler, param);}
    void setCLRegenMode(int mode, DsaHandler handler, void *param = NULL) {DsaBase::setCLRegenMode(mode, handler, param);}
    void setInitMode(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setInitMode(typ, handler, param);}
    void setInitPulseLevel(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitPulseLevel(cur, handler, param);}
    void setInitMaxCurrent(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitMaxCurrent(cur, handler, param);}
    void setInitFinalPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitFinalPhase(cal, handler, param);}
    void setInitTime(double tim, DsaHandler handler, void *param = NULL) {DsaBase::setInitTime(tim, handler, param);}
    void setInitCurrentRate(double cur, DsaHandler handler, void *param = NULL) {DsaBase::setInitCurrentRate(cur, handler, param);}
    void setInitPhaseRate(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitPhaseRate(cal, handler, param);}
    void setInitInitialPhase(double cal, DsaHandler handler, void *param = NULL) {DsaBase::setInitInitialPhase(cal, handler, param);}
    void setDriveFuseChecking(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setDriveFuseChecking(mask, handler, param);}
    void setMotorTempChecking(dword val, DsaHandler handler, void *param = NULL) {DsaBase::setMotorTempChecking(val, handler, param);}
    void setMonSourceType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceType(sidx, typ, handler, param);}
    void setMonSourceIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonSourceIndex(sidx, index, handler, param);}
    void setMonDestIndex(int sidx, int index, DsaHandler handler, void *param = NULL) {DsaBase::setMonDestIndex(sidx, index, handler, param);}
    void setMonOffset(int sidx, long offset, DsaHandler handler, void *param = NULL) {DsaBase::setMonOffset(sidx, offset, handler, param);}
    void setMonGain(int sidx, double gain, DsaHandler handler, void *param = NULL) {DsaBase::setMonGain(sidx, gain, handler, param);}
    void setXAnalogOffset(int sidx, double offset, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOffset(sidx, offset, handler, param);}
    void setXAnalogGain(int sidx, double gain, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogGain(sidx, gain, handler, param);}
    void setSyncroInputMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroInputMask(mask, handler, param);}
    void setSyncroInputValue(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroInputValue(mask, handler, param);}
    void setSyncroOutputMask(double mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroOutputMask(mask, handler, param);}
    void setSyncroOutputValue(double mask, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroOutputValue(mask, handler, param);}
    void setSyncroStartTimeout(int tim, DsaHandler handler, void *param = NULL) {DsaBase::setSyncroStartTimeout(tim, handler, param);}
    void setDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setDigitalOutput(out, handler, param);}
    void setXDigitalOutput(dword out, DsaHandler handler, void *param = NULL) {DsaBase::setXDigitalOutput(out, handler, param);}
    void setXAnalogOutput1(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput1(out, handler, param);}
    void setXAnalogOutput2(double out, DsaHandler handler, void *param = NULL) {DsaBase::setXAnalogOutput2(out, handler, param);}
    void setAnalogOutput(double out, DsaHandler handler, void *param = NULL) {DsaBase::setAnalogOutput(out, handler, param);}
    void setInterruptMask1(int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setInterruptMask1(sidx, mask, handler, param);}
    void setInterruptMask2(int sidx, dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setInterruptMask2(sidx, mask, handler, param);}
    void setTriggerIrqMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerIrqMask(mask, handler, param);}
    void setTriggerIOMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerIOMask(mask, handler, param);}
    void setTriggerMapOffset(int offset, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerMapOffset(offset, handler, param);}
    void setTriggerMapSize(int size, DsaHandler handler, void *param = NULL) {DsaBase::setTriggerMapSize(size, handler, param);}
    void setRealtimeEnabledGlobal(int enable, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeEnabledGlobal(enable, handler, param);}
    void setRealtimeValidMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeValidMask(mask, handler, param);}
    void setRealtimeEnabledMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimeEnabledMask(mask, handler, param);}
    void setRealtimePendingMask(dword mask, DsaHandler handler, void *param = NULL) {DsaBase::setRealtimePendingMask(mask, handler, param);}
    void setEblBaudrate(long baud, DsaHandler handler, void *param = NULL) {DsaBase::setEblBaudrate(baud, handler, param);}
    void setIndirectAxisNumber(int axis, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectAxisNumber(axis, handler, param);}
    void setIndirectRegisterIdx(int idx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterIdx(idx, handler, param);}
    void setIndirectRegisterSidx(int sidx, DsaHandler handler, void *param = NULL) {DsaBase::setIndirectRegisterSidx(sidx, handler, param);}
    void setConcatenatedMvt(int concat, DsaHandler handler, void *param = NULL) {DsaBase::setConcatenatedMvt(concat, handler, param);}
    void setProfileType(int sidx, int typ, DsaHandler handler, void *param = NULL) {DsaBase::setProfileType(sidx, typ, handler, param);}
    void setMvtLktNumber(int sidx, int number, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktNumber(sidx, number, handler, param);}
    void setMvtLktTime(int sidx, double time, DsaHandler handler, void *param = NULL) {DsaBase::setMvtLktTime(sidx, time, handler, param);}
    void setCameValue(double factor, DsaHandler handler, void *param = NULL) {DsaBase::setCameValue(factor, handler, param);}
    void setBrakeDeceleration(double dec, DsaHandler handler, void *param = NULL) {DsaBase::setBrakeDeceleration(dec, handler, param);}
    void setTargetPosition(int sidx, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTargetPosition(sidx, pos, handler, param);}
    void setProfileVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setProfileVelocity(sidx, vel, handler, param);}
    void setProfileAcceleration(int sidx, double acc, DsaHandler handler, void *param = NULL) {DsaBase::setProfileAcceleration(sidx, acc, handler, param);}
    void setJerkTime(int sidx, double tim, DsaHandler handler, void *param = NULL) {DsaBase::setJerkTime(sidx, tim, handler, param);}
    void setProfileDeceleration(int sidx, double dec, DsaHandler handler, void *param = NULL) {DsaBase::setProfileDeceleration(sidx, dec, handler, param);}
    void setEndVelocity(int sidx, double vel, DsaHandler handler, void *param = NULL) {DsaBase::setEndVelocity(sidx, vel, handler, param);}
    void setCtrlSourceType(int typ, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceType(typ, handler, param);}
    void setCtrlSourceIndex(int index, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlSourceIndex(index, handler, param);}
    void setCtrlShiftFactor(int shift, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlShiftFactor(shift, handler, param);}
    void setCtrlOffset(long offset, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlOffset(offset, handler, param);}
    void setCtrlGain(double gain, DsaHandler handler, void *param = NULL) {DsaBase::setCtrlGain(gain, handler, param);}
    void setMotorKTFactor(double kt, DsaHandler handler, void *param = NULL) {DsaBase::setMotorKTFactor(kt, handler, param);}

	/* register getters */


};

/*
 * this function should be defined once all classes are well known
 */
inline DsaDeviceBase Dsa::createAuto(EtbBus etb, int axis) {
	DsaDeviceBase obj;
	ERRCHK(dsa_create_auto_e(&obj.dsa, *(ETB **)&etb, axis));
	return obj;
}
inline DsaDeviceBase Dsa::createAuto(int prod) {
	DsaDeviceBase obj;
	ERRCHK(dsa_create_auto_o(&obj.dsa, prod));
	return obj;
}
inline DsaDsmax DsaBase::getDsmax(void) {
	DsaDsmax obj;
	ERRCHK(dsa_get_dsmax(dsa, &obj.dsa));
	ERRCHK(dsa_share(obj.dsa));
	return obj;
}
inline void DsaBase::setDsmax(DsaDsmax dsmax) {
	ERRCHK(dsa_set_dsmax(dsa, dsmax.dsa));
}



/**
 * DsaGPModuleBase class - C++
 */
class DsaGPModuleBase: public DsaBase {
	/* constructors */
protected:
	DsaGPModuleBase(void) {
	}
public:
	DsaGPModuleBase(DsaGPModuleBase &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaGPModuleBase(DsaBase &obj) {
		if (!dsa_is_valid_gp_module_base(obj.dsa))
			throw bad_cast("cannot cast to DsaGPModuleBase");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	/* operators */
public:
	DsaGPModuleBase operator = (DsaGPModuleBase &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaGPModuleBase operator = (DsaBase &obj) {
		if (!dsa_is_valid_gp_module_base(obj.dsa))
			throw bad_cast("cannot cast to DsaGPModuleBase");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* functions */
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */


	/* register getters */


};


/**
 * DsaGPModule class - C++
 */
class DsaGPModule: public DsaBase {
	/* constructors */
public:
	DsaGPModule(void) {
		dsa = NULL;
		ERRCHK(dsa_create_gp_module(&dsa));
	}
	DsaGPModule(DsaGPModule &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaGPModule(DsaBase &obj) {
		if (!dsa_is_valid_gp_module(obj.dsa))
			throw bad_cast("cannot cast to DsaGPModule");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	/* operators */
public:
	DsaGPModule operator = (DsaGPModule &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaGPModule operator = (DsaBase &obj) {
		if (!dsa_is_valid_gp_module(obj.dsa))
			throw bad_cast("cannot cast to DsaGPModuleBase");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* functions */
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    int  getWarningCode(int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getWarningCode(kind, timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    long  getRegister(int typ, unsigned idx, int sidx, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getRegister(typ, idx, sidx, kind, timeout);}
    void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    double  getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, long timeout = DEF_TIMEOUT) {return DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, timeout);}
    void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, long timeout = DEF_TIMEOUT) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, long timeout = DEF_TIMEOUT) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, timeout);}
    DsaStatus  waitStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusEqual(mask, ref, timeout);}
    DsaStatus  waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusNotEqual(mask, ref, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    DsaStatus  waitStatusChange(DsaStatus *mask, long timeout = DEF_TIMEOUT) {return DsaBase::waitStatusChange(mask, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void getWarningCode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getWarningCode(kind, handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void getRegister(int typ, unsigned idx, int sidx, int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getRegister(typ, idx, sidx, kind, handler, param);}
    void getArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getArray(typ, idx, nidx, sidx, val, offset, kind, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void getIsoRegister(int typ, unsigned idx, int sidx, int conv, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getIsoRegister(typ, idx, sidx, conv, kind, handler, param);}
    void getIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, int kind, DsaHandler handler, void *param = NULL) {DsaBase::getIsoArray(typ, idx, nidx, sidx, val, offset, conv, kind, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void quickRegisterRequest(int typ1, unsigned idx1, int sidx1, long *val1, int typ2, unsigned idx2, int sidx2, long *val2, dword *rx_time, Dsa2intHandler handler, void *param = NULL) {DsaBase::quickRegisterRequest(typ1, idx1, sidx1, val1, typ2, idx2, sidx2, val2, rx_time, handler, param);}
    void waitStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusEqual(mask, ref, handler, param);}
    void waitStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusNotEqual(mask, ref, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void waitStatusChange(DsaStatus *mask, DsaStatusHandler handler, void *param = NULL) {DsaBase::waitStatusChange(mask, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

    void open(EtbBus etb, int axis) {DsaBase::open(etb, axis);}
    void open(char_cp url) {DsaBase::open(url);}
    void open(EtbBus etb, int axis, dword flags) {DsaBase::open(etb, axis, flags);}
    void reset() {DsaBase::reset();}
    void close() {DsaBase::close();}
    EtbBus  getEtbBus() {return DsaBase::getEtbBus();}
    int  getEtbAxis() {return DsaBase::getEtbAxis();}
    bool  isOpen() {return DsaBase::isOpen();}
    int getMotorTyp() {return DsaBase::getMotorTyp();}
    void getErrorText(char_p text, int size, int code) {DsaBase::getErrorText(text, size, code);}
    void getWarningText(char_p text, int size, int code) {DsaBase::getWarningText(text, size, code);}
    double  convertToIso(long inc, int conv) {return DsaBase::convertToIso(inc, conv);}
    long  convertFromIso(double iso, int conv) {return DsaBase::convertFromIso(iso, conv);}
    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    DsaInfo  getInfo() {return DsaBase::getInfo();}
    DsaStatus  getStatus() {return DsaBase::getStatus();}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    DsaStatus  getStatusFromDrive(long timeout = DEF_TIMEOUT) {return DsaBase::getStatusFromDrive(timeout);}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}
    DsaXInfo  getXInfo() {return DsaBase::getXInfo();}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */


	/* register getters */
    double getPLProportionalGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLProportionalGain(kind, timeout);}
    void getPLProportionalGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLProportionalGain(gain, kind, timeout);}
    double getPLSpeedFeedbackGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLSpeedFeedbackGain(kind, timeout);}
    void getPLSpeedFeedbackGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLSpeedFeedbackGain(gain, kind, timeout);}
    double getPLForceFeedbackGain1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLForceFeedbackGain1(kind, timeout);}
    void getPLForceFeedbackGain1(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLForceFeedbackGain1(gain, kind, timeout);}
    double getPLIntegratorGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLIntegratorGain(kind, timeout);}
    void getPLIntegratorGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLIntegratorGain(gain, kind, timeout);}
    double getPLAntiWindupGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLAntiWindupGain(kind, timeout);}
    void getPLAntiWindupGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLAntiWindupGain(gain, kind, timeout);}
    double getPLIntegratorLimitation(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLIntegratorLimitation(kind, timeout);}
    void getPLIntegratorLimitation(double *limit, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLIntegratorLimitation(limit, kind, timeout);}
    int getPLIntegratorMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLIntegratorMode(kind, timeout);}
    void getPLIntegratorMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLIntegratorMode(mode, kind, timeout);}
    double getPLSpeedFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLSpeedFilter(kind, timeout);}
    void getPLSpeedFilter(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLSpeedFilter(tim, kind, timeout);}
    double getPLOutputFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLOutputFilter(kind, timeout);}
    void getPLOutputFilter(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLOutputFilter(tim, kind, timeout);}
    double getCLInputFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLInputFilter(kind, timeout);}
    void getCLInputFilter(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLInputFilter(tim, kind, timeout);}
    double getTtlSpecialFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTtlSpecialFilter(kind, timeout);}
    void getTtlSpecialFilter(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTtlSpecialFilter(factor, kind, timeout);}
    double getPLForceFeedbackGain2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLForceFeedbackGain2(kind, timeout);}
    void getPLForceFeedbackGain2(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLForceFeedbackGain2(factor, kind, timeout);}
    double getPLSpeedFeedfwdGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLSpeedFeedfwdGain(kind, timeout);}
    void getPLSpeedFeedfwdGain(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLSpeedFeedfwdGain(factor, kind, timeout);}
    double getPLAccFeedforwardGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPLAccFeedforwardGain(kind, timeout);}
    void getPLAccFeedforwardGain(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPLAccFeedforwardGain(factor, kind, timeout);}
    double getCLPhaseAdvanceFactor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLPhaseAdvanceFactor(kind, timeout);}
    void getCLPhaseAdvanceFactor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLPhaseAdvanceFactor(factor, kind, timeout);}
    double getAprInputFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAprInputFilter(kind, timeout);}
    void getAprInputFilter(double *time, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAprInputFilter(time, kind, timeout);}
    double getCLPhaseAdvanceShift(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLPhaseAdvanceShift(kind, timeout);}
    void getCLPhaseAdvanceShift(double *shift, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLPhaseAdvanceShift(shift, kind, timeout);}
    double getMinPositionRangeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMinPositionRangeLimit(kind, timeout);}
    void getMinPositionRangeLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMinPositionRangeLimit(pos, kind, timeout);}
    double getMaxPositionRangeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMaxPositionRangeLimit(kind, timeout);}
    void getMaxPositionRangeLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMaxPositionRangeLimit(pos, kind, timeout);}
    double getMaxProfileVelocity(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMaxProfileVelocity(kind, timeout);}
    void getMaxProfileVelocity(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMaxProfileVelocity(vel, kind, timeout);}
    double getMaxAcceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMaxAcceleration(kind, timeout);}
    void getMaxAcceleration(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMaxAcceleration(acc, kind, timeout);}
    double getFollowingErrorWindow(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getFollowingErrorWindow(kind, timeout);}
    void getFollowingErrorWindow(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getFollowingErrorWindow(pos, kind, timeout);}
    double getVelocityErrorLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getVelocityErrorLimit(kind, timeout);}
    void getVelocityErrorLimit(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getVelocityErrorLimit(vel, kind, timeout);}
    int getSwitchLimitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSwitchLimitMode(kind, timeout);}
    void getSwitchLimitMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSwitchLimitMode(mode, kind, timeout);}
    int getEnableInputMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEnableInputMode(kind, timeout);}
    void getEnableInputMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEnableInputMode(mode, kind, timeout);}
    double getMinSoftPositionLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMinSoftPositionLimit(kind, timeout);}
    void getMinSoftPositionLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMinSoftPositionLimit(pos, kind, timeout);}
    double getMaxSoftPositionLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMaxSoftPositionLimit(kind, timeout);}
    void getMaxSoftPositionLimit(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMaxSoftPositionLimit(pos, kind, timeout);}
    dword getProfileLimitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileLimitMode(kind, timeout);}
    void getProfileLimitMode(dword *flags, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileLimitMode(flags, kind, timeout);}
    dword getIOErrorEventMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIOErrorEventMask(kind, timeout);}
    void getIOErrorEventMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIOErrorEventMask(mask, kind, timeout);}
    double getPositionWindowTime(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionWindowTime(kind, timeout);}
    void getPositionWindowTime(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionWindowTime(tim, kind, timeout);}
    double getPositionWindow(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionWindow(kind, timeout);}
    void getPositionWindow(double *win, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionWindow(win, kind, timeout);}
    int getHomingMethod(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingMethod(kind, timeout);}
    void getHomingMethod(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingMethod(mode, kind, timeout);}
    double getHomingZeroSpeed(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingZeroSpeed(kind, timeout);}
    void getHomingZeroSpeed(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingZeroSpeed(vel, kind, timeout);}
    double getHomingAcceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingAcceleration(kind, timeout);}
    void getHomingAcceleration(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingAcceleration(acc, kind, timeout);}
    double getHomingFollowingLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingFollowingLimit(kind, timeout);}
    void getHomingFollowingLimit(double *win, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingFollowingLimit(win, kind, timeout);}
    double getHomingCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingCurrentLimit(kind, timeout);}
    void getHomingCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingCurrentLimit(cur, kind, timeout);}
    double getHomeOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomeOffset(kind, timeout);}
    void getHomeOffset(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomeOffset(pos, kind, timeout);}
    double getHomingFixedMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingFixedMvt(kind, timeout);}
    void getHomingFixedMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingFixedMvt(pos, kind, timeout);}
    double getHomingSwitchMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingSwitchMvt(kind, timeout);}
    void getHomingSwitchMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingSwitchMvt(pos, kind, timeout);}
    double getHomingIndexMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingIndexMvt(kind, timeout);}
    void getHomingIndexMvt(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingIndexMvt(pos, kind, timeout);}
    int getHomingFineTuningMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingFineTuningMode(kind, timeout);}
    void getHomingFineTuningMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingFineTuningMode(mode, kind, timeout);}
    double getHomingFineTuningValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getHomingFineTuningValue(kind, timeout);}
    void getHomingFineTuningValue(double *phase, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getHomingFineTuningValue(phase, kind, timeout);}
    int getMotorPhaseCorrection(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMotorPhaseCorrection(kind, timeout);}
    void getMotorPhaseCorrection(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMotorPhaseCorrection(mode, kind, timeout);}
    double getSoftwareCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSoftwareCurrentLimit(kind, timeout);}
    void getSoftwareCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSoftwareCurrentLimit(cur, kind, timeout);}
    int getDriveControlMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveControlMode(kind, timeout);}
    void getDriveControlMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveControlMode(mode, kind, timeout);}
    int getDisplayMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDisplayMode(kind, timeout);}
    void getDisplayMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDisplayMode(mode, kind, timeout);}
    double getEncoderInversion(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderInversion(kind, timeout);}
    void getEncoderInversion(double *invert, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderInversion(invert, kind, timeout);}
    double getPdrStepValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPdrStepValue(kind, timeout);}
    void getPdrStepValue(double *step, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPdrStepValue(step, kind, timeout);}
    double getEncoderPhase1Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase1Offset(kind, timeout);}
    void getEncoderPhase1Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase1Offset(offset, kind, timeout);}
    double getEncoderPhase2Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase2Offset(kind, timeout);}
    void getEncoderPhase2Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase2Offset(offset, kind, timeout);}
    double getEncoderPhase1Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase1Factor(kind, timeout);}
    void getEncoderPhase1Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase1Factor(factor, kind, timeout);}
    double getEncoderPhase2Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase2Factor(kind, timeout);}
    void getEncoderPhase2Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase2Factor(factor, kind, timeout);}
    double getEncoderPhase3Offset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase3Offset(kind, timeout);}
    void getEncoderPhase3Offset(double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase3Offset(offset, kind, timeout);}
    double getEncoderIndexDistance(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderIndexDistance(kind, timeout);}
    void getEncoderIndexDistance(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderIndexDistance(pos, kind, timeout);}
    double getEncoderPhase3Factor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderPhase3Factor(kind, timeout);}
    void getEncoderPhase3Factor(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderPhase3Factor(factor, kind, timeout);}
    double getCLProportionalGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLProportionalGain(kind, timeout);}
    void getCLProportionalGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLProportionalGain(gain, kind, timeout);}
    double getCLIntegratorGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLIntegratorGain(kind, timeout);}
    void getCLIntegratorGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLIntegratorGain(gain, kind, timeout);}
    double getCLOutputFilter(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLOutputFilter(kind, timeout);}
    void getCLOutputFilter(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLOutputFilter(tim, kind, timeout);}
    double getCLCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLCurrentLimit(kind, timeout);}
    void getCLCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLCurrentLimit(cur, kind, timeout);}
    double getCLI2tCurrentLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLI2tCurrentLimit(kind, timeout);}
    void getCLI2tCurrentLimit(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLI2tCurrentLimit(cur, kind, timeout);}
    double getCLI2tTimeLimit(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLI2tTimeLimit(kind, timeout);}
    void getCLI2tTimeLimit(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLI2tTimeLimit(tim, kind, timeout);}
    int getCLRegenMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLRegenMode(kind, timeout);}
    void getCLRegenMode(int *mode, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLRegenMode(mode, kind, timeout);}
    int getInitMode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitMode(kind, timeout);}
    void getInitMode(int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitMode(typ, kind, timeout);}
    double getInitPulseLevel(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitPulseLevel(kind, timeout);}
    void getInitPulseLevel(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitPulseLevel(cur, kind, timeout);}
    double getInitMaxCurrent(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitMaxCurrent(kind, timeout);}
    void getInitMaxCurrent(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitMaxCurrent(cur, kind, timeout);}
    double getInitFinalPhase(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitFinalPhase(kind, timeout);}
    void getInitFinalPhase(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitFinalPhase(cal, kind, timeout);}
    double getInitTime(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitTime(kind, timeout);}
    void getInitTime(double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitTime(tim, kind, timeout);}
    double getInitCurrentRate(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitCurrentRate(kind, timeout);}
    void getInitCurrentRate(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitCurrentRate(cur, kind, timeout);}
    double getInitPhaseRate(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitPhaseRate(kind, timeout);}
    void getInitPhaseRate(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitPhaseRate(cal, kind, timeout);}
    double getInitInitialPhase(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInitInitialPhase(kind, timeout);}
    void getInitInitialPhase(double *cal, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInitInitialPhase(cal, kind, timeout);}
    dword getDriveFuseChecking(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveFuseChecking(kind, timeout);}
    void getDriveFuseChecking(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveFuseChecking(mask, kind, timeout);}
    dword getMotorTempChecking(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMotorTempChecking(kind, timeout);}
    void getMotorTempChecking(dword *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMotorTempChecking(val, kind, timeout);}
    int getMonSourceType(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMonSourceType(sidx, kind, timeout);}
    void getMonSourceType(int sidx, int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMonSourceType(sidx, typ, kind, timeout);}
    int getMonSourceIndex(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMonSourceIndex(sidx, kind, timeout);}
    void getMonSourceIndex(int sidx, int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMonSourceIndex(sidx, index, kind, timeout);}
    int getMonDestIndex(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMonDestIndex(sidx, kind, timeout);}
    void getMonDestIndex(int sidx, int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMonDestIndex(sidx, index, kind, timeout);}
    long getMonOffset(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMonOffset(sidx, kind, timeout);}
    void getMonOffset(int sidx, long *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMonOffset(sidx, offset, kind, timeout);}
    double getMonGain(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMonGain(sidx, kind, timeout);}
    void getMonGain(int sidx, double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMonGain(sidx, gain, kind, timeout);}
    double getXAnalogOffset(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogOffset(sidx, kind, timeout);}
    void getXAnalogOffset(int sidx, double *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogOffset(sidx, offset, kind, timeout);}
    double getXAnalogGain(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogGain(sidx, kind, timeout);}
    void getXAnalogGain(int sidx, double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogGain(sidx, gain, kind, timeout);}
    dword getSyncroInputMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSyncroInputMask(kind, timeout);}
    void getSyncroInputMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSyncroInputMask(mask, kind, timeout);}
    dword getSyncroInputValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSyncroInputValue(kind, timeout);}
    void getSyncroInputValue(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSyncroInputValue(mask, kind, timeout);}
    double getSyncroOutputMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSyncroOutputMask(kind, timeout);}
    void getSyncroOutputMask(double *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSyncroOutputMask(mask, kind, timeout);}
    double getSyncroOutputValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSyncroOutputValue(kind, timeout);}
    void getSyncroOutputValue(double *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSyncroOutputValue(mask, kind, timeout);}
    int getSyncroStartTimeout(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getSyncroStartTimeout(kind, timeout);}
    void getSyncroStartTimeout(int *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getSyncroStartTimeout(tim, kind, timeout);}
    dword getDigitalOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDigitalOutput(kind, timeout);}
    void getDigitalOutput(dword *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDigitalOutput(out, kind, timeout);}
    dword getXDigitalOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXDigitalOutput(kind, timeout);}
    void getXDigitalOutput(dword *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXDigitalOutput(out, kind, timeout);}
    double getXAnalogOutput1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogOutput1(kind, timeout);}
    void getXAnalogOutput1(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogOutput1(out, kind, timeout);}
    double getXAnalogOutput2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogOutput2(kind, timeout);}
    void getXAnalogOutput2(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogOutput2(out, kind, timeout);}
    double getAnalogOutput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAnalogOutput(kind, timeout);}
    void getAnalogOutput(double *out, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAnalogOutput(out, kind, timeout);}
    dword getInterruptMask1(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInterruptMask1(sidx, kind, timeout);}
    void getInterruptMask1(int sidx, dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInterruptMask1(sidx, mask, kind, timeout);}
    dword getInterruptMask2(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getInterruptMask2(sidx, kind, timeout);}
    void getInterruptMask2(int sidx, dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getInterruptMask2(sidx, mask, kind, timeout);}
    dword getTriggerIrqMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTriggerIrqMask(kind, timeout);}
    void getTriggerIrqMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTriggerIrqMask(mask, kind, timeout);}
    dword getTriggerIOMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTriggerIOMask(kind, timeout);}
    void getTriggerIOMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTriggerIOMask(mask, kind, timeout);}
    int getTriggerMapOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTriggerMapOffset(kind, timeout);}
    void getTriggerMapOffset(int *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTriggerMapOffset(offset, kind, timeout);}
    int getTriggerMapSize(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTriggerMapSize(kind, timeout);}
    void getTriggerMapSize(int *size, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTriggerMapSize(size, kind, timeout);}
    int getRealtimeEnabledGlobal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getRealtimeEnabledGlobal(kind, timeout);}
    void getRealtimeEnabledGlobal(int *enable, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getRealtimeEnabledGlobal(enable, kind, timeout);}
    dword getRealtimeValidMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getRealtimeValidMask(kind, timeout);}
    void getRealtimeValidMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getRealtimeValidMask(mask, kind, timeout);}
    dword getRealtimeEnabledMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getRealtimeEnabledMask(kind, timeout);}
    void getRealtimeEnabledMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getRealtimeEnabledMask(mask, kind, timeout);}
    dword getRealtimePendingMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getRealtimePendingMask(kind, timeout);}
    void getRealtimePendingMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getRealtimePendingMask(mask, kind, timeout);}
    long getEblBaudrate(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEblBaudrate(kind, timeout);}
    void getEblBaudrate(long *baud, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEblBaudrate(baud, kind, timeout);}
    int getIndirectAxisNumber(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIndirectAxisNumber(kind, timeout);}
    void getIndirectAxisNumber(int *axis, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIndirectAxisNumber(axis, kind, timeout);}
    int getIndirectRegisterIdx(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIndirectRegisterIdx(kind, timeout);}
    void getIndirectRegisterIdx(int *idx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIndirectRegisterIdx(idx, kind, timeout);}
    int getIndirectRegisterSidx(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIndirectRegisterSidx(kind, timeout);}
    void getIndirectRegisterSidx(int *sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIndirectRegisterSidx(sidx, kind, timeout);}
    int getConcatenatedMvt(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getConcatenatedMvt(kind, timeout);}
    void getConcatenatedMvt(int *concat, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getConcatenatedMvt(concat, kind, timeout);}
    int getProfileType(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileType(sidx, kind, timeout);}
    void getProfileType(int sidx, int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileType(sidx, typ, kind, timeout);}
    int getMvtLktNumber(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMvtLktNumber(sidx, kind, timeout);}
    void getMvtLktNumber(int sidx, int *number, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMvtLktNumber(sidx, number, kind, timeout);}
    double getMvtLktTime(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMvtLktTime(sidx, kind, timeout);}
    void getMvtLktTime(int sidx, double *time, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMvtLktTime(sidx, time, kind, timeout);}
    double getCameValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCameValue(kind, timeout);}
    void getCameValue(double *factor, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCameValue(factor, kind, timeout);}
    double getBrakeDeceleration(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getBrakeDeceleration(kind, timeout);}
    void getBrakeDeceleration(double *dec, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getBrakeDeceleration(dec, kind, timeout);}
    double getTargetPosition(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getTargetPosition(sidx, kind, timeout);}
    void getTargetPosition(int sidx, double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getTargetPosition(sidx, pos, kind, timeout);}
    double getProfileVelocity(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileVelocity(sidx, kind, timeout);}
    void getProfileVelocity(int sidx, double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileVelocity(sidx, vel, kind, timeout);}
    double getProfileAcceleration(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileAcceleration(sidx, kind, timeout);}
    void getProfileAcceleration(int sidx, double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileAcceleration(sidx, acc, kind, timeout);}
    double getJerkTime(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getJerkTime(sidx, kind, timeout);}
    void getJerkTime(int sidx, double *tim, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getJerkTime(sidx, tim, kind, timeout);}
    double getProfileDeceleration(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getProfileDeceleration(sidx, kind, timeout);}
    void getProfileDeceleration(int sidx, double *dec, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getProfileDeceleration(sidx, dec, kind, timeout);}
    double getEndVelocity(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEndVelocity(sidx, kind, timeout);}
    void getEndVelocity(int sidx, double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEndVelocity(sidx, vel, kind, timeout);}
    int getCtrlSourceType(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlSourceType(kind, timeout);}
    void getCtrlSourceType(int *typ, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlSourceType(typ, kind, timeout);}
    int getCtrlSourceIndex(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlSourceIndex(kind, timeout);}
    void getCtrlSourceIndex(int *index, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlSourceIndex(index, kind, timeout);}
    int getCtrlShiftFactor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlShiftFactor(kind, timeout);}
    void getCtrlShiftFactor(int *shift, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlShiftFactor(shift, kind, timeout);}
    long getCtrlOffset(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlOffset(kind, timeout);}
    void getCtrlOffset(long *offset, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlOffset(offset, kind, timeout);}
    double getCtrlGain(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCtrlGain(kind, timeout);}
    void getCtrlGain(double *gain, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCtrlGain(gain, kind, timeout);}
    double getMotorKTFactor(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getMotorKTFactor(kind, timeout);}
    void getMotorKTFactor(double *kt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getMotorKTFactor(kt, kind, timeout);}
    double getPositionCtrlError(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionCtrlError(kind, timeout);}
    void getPositionCtrlError(double *err, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionCtrlError(err, kind, timeout);}
    double getPositionMaxError(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionMaxError(kind, timeout);}
    void getPositionMaxError(double *err, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionMaxError(err, kind, timeout);}
    double getPositionDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionDemandValue(kind, timeout);}
    void getPositionDemandValue(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionDemandValue(pos, kind, timeout);}
    double getPositionActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getPositionActualValue(kind, timeout);}
    void getPositionActualValue(double *pos, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getPositionActualValue(pos, kind, timeout);}
    double getVelocityDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getVelocityDemandValue(kind, timeout);}
    void getVelocityDemandValue(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getVelocityDemandValue(vel, kind, timeout);}
    double getVelocityActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getVelocityActualValue(kind, timeout);}
    void getVelocityActualValue(double *vel, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getVelocityActualValue(vel, kind, timeout);}
    double getAccDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAccDemandValue(kind, timeout);}
    void getAccDemandValue(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAccDemandValue(acc, kind, timeout);}
    double getAccActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAccActualValue(kind, timeout);}
    void getAccActualValue(double *acc, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAccActualValue(acc, kind, timeout);}
    double getRefDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getRefDemandValue(kind, timeout);}
    void getRefDemandValue(double *ref, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getRefDemandValue(ref, kind, timeout);}
    dword getDriveControlMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveControlMask(kind, timeout);}
    void getDriveControlMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveControlMask(mask, kind, timeout);}
    double getCLCurrentPhase1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLCurrentPhase1(kind, timeout);}
    void getCLCurrentPhase1(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLCurrentPhase1(cur, kind, timeout);}
    double getCLCurrentPhase2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLCurrentPhase2(kind, timeout);}
    void getCLCurrentPhase2(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLCurrentPhase2(cur, kind, timeout);}
    double getCLCurrentPhase3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLCurrentPhase3(kind, timeout);}
    void getCLCurrentPhase3(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLCurrentPhase3(cur, kind, timeout);}
    double getCLLktPhase1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLLktPhase1(kind, timeout);}
    void getCLLktPhase1(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLLktPhase1(lkt, kind, timeout);}
    double getCLLktPhase2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLLktPhase2(kind, timeout);}
    void getCLLktPhase2(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLLktPhase2(lkt, kind, timeout);}
    double getCLLktPhase3(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLLktPhase3(kind, timeout);}
    void getCLLktPhase3(double *lkt, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLLktPhase3(lkt, kind, timeout);}
    double getCLDemandValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLDemandValue(kind, timeout);}
    void getCLDemandValue(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLDemandValue(cur, kind, timeout);}
    double getCLActualValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLActualValue(kind, timeout);}
    void getCLActualValue(double *cur, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLActualValue(cur, kind, timeout);}
    double getEncoderSineSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderSineSignal(kind, timeout);}
    void getEncoderSineSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderSineSignal(val, kind, timeout);}
    double getEncoderCosineSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderCosineSignal(kind, timeout);}
    void getEncoderCosineSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderCosineSignal(val, kind, timeout);}
    double getEncoderIndexSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderIndexSignal(kind, timeout);}
    void getEncoderIndexSignal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderIndexSignal(val, kind, timeout);}
    double getEncoderHall1Signal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderHall1Signal(kind, timeout);}
    void getEncoderHall1Signal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderHall1Signal(val, kind, timeout);}
    double getEncoderHall2Signal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderHall2Signal(kind, timeout);}
    void getEncoderHall2Signal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderHall2Signal(val, kind, timeout);}
    double getEncoderHall3Signal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderHall3Signal(kind, timeout);}
    void getEncoderHall3Signal(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderHall3Signal(val, kind, timeout);}
    dword getEncoderHallDigSignal(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getEncoderHallDigSignal(kind, timeout);}
    void getEncoderHallDigSignal(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getEncoderHallDigSignal(mask, kind, timeout);}
    dword getDigitalInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDigitalInput(kind, timeout);}
    void getDigitalInput(dword *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDigitalInput(inp, kind, timeout);}
    double getAnalogInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAnalogInput(kind, timeout);}
    void getAnalogInput(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAnalogInput(inp, kind, timeout);}
    dword getXDigitalInput(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXDigitalInput(kind, timeout);}
    void getXDigitalInput(dword *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXDigitalInput(inp, kind, timeout);}
    double getXAnalogInput1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogInput1(kind, timeout);}
    void getXAnalogInput1(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogInput1(inp, kind, timeout);}
    double getXAnalogInput2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getXAnalogInput2(kind, timeout);}
    void getXAnalogInput2(double *inp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getXAnalogInput2(inp, kind, timeout);}
    dword getDriveStatus1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveStatus1(kind, timeout);}
    void getDriveStatus1(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveStatus1(mask, kind, timeout);}
    dword getDriveStatus2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveStatus2(kind, timeout);}
    void getDriveStatus2(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveStatus2(mask, kind, timeout);}
    int getErrorCode(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getErrorCode(kind, timeout);}
    void getErrorCode(int *code, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getErrorCode(code, kind, timeout);}
    double getCLI2tValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCLI2tValue(kind, timeout);}
    void getCLI2tValue(double *val, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCLI2tValue(val, kind, timeout);}
    int getAxisNumber(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAxisNumber(kind, timeout);}
    void getAxisNumber(int *num, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAxisNumber(num, kind, timeout);}
    int getDaisyChainNumber(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDaisyChainNumber(kind, timeout);}
    void getDaisyChainNumber(int *num, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDaisyChainNumber(num, kind, timeout);}
    double getDriveTemperature(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveTemperature(kind, timeout);}
    void getDriveTemperature(double *temp, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveTemperature(temp, kind, timeout);}
    dword getDriveMaskValue(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveMaskValue(kind, timeout);}
    void getDriveMaskValue(dword *str, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveMaskValue(str, kind, timeout);}
    dword getDriveDisplay(int sidx, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveDisplay(sidx, kind, timeout);}
    void getDriveDisplay(int sidx, dword *str, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveDisplay(sidx, str, kind, timeout);}
    long getDriveSequenceLine(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveSequenceLine(kind, timeout);}
    void getDriveSequenceLine(long *line, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveSequenceLine(line, kind, timeout);}
    dword getDriveFuseStatus(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getDriveFuseStatus(kind, timeout);}
    void getDriveFuseStatus(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getDriveFuseStatus(mask, kind, timeout);}
    dword getIrqDriveStatus1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIrqDriveStatus1(kind, timeout);}
    void getIrqDriveStatus1(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIrqDriveStatus1(mask, kind, timeout);}
    dword getIrqDriveStatus2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIrqDriveStatus2(kind, timeout);}
    void getIrqDriveStatus2(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIrqDriveStatus2(mask, kind, timeout);}
    dword getAckDriveStatus1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAckDriveStatus1(kind, timeout);}
    void getAckDriveStatus1(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAckDriveStatus1(mask, kind, timeout);}
    dword getAckDriveStatus2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getAckDriveStatus2(kind, timeout);}
    void getAckDriveStatus2(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getAckDriveStatus2(mask, kind, timeout);}
    dword getIrqPendingAxisMask(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getIrqPendingAxisMask(kind, timeout);}
    void getIrqPendingAxisMask(dword *mask, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getIrqPendingAxisMask(mask, kind, timeout);}
    dword getCanFeedback1(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCanFeedback1(kind, timeout);}
    void getCanFeedback1(dword *val1, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCanFeedback1(val1, kind, timeout);}
    dword getCanFeedback2(int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {return DsaBase::getCanFeedback2(kind, timeout);}
    void getCanFeedback2(dword *val1, int kind = GET_CURRENT, long timeout = DEF_TIMEOUT) {DsaBase::getCanFeedback2(val1, kind, timeout);}

    void getPLProportionalGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLProportionalGain(kind, handler, param);}
    void getPLProportionalGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLProportionalGain(handler, param);}
    void getPLSpeedFeedbackGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFeedbackGain(kind, handler, param);}
    void getPLSpeedFeedbackGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFeedbackGain(handler, param);}
    void getPLForceFeedbackGain1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLForceFeedbackGain1(kind, handler, param);}
    void getPLForceFeedbackGain1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLForceFeedbackGain1(handler, param);}
    void getPLIntegratorGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLIntegratorGain(kind, handler, param);}
    void getPLIntegratorGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLIntegratorGain(handler, param);}
    void getPLAntiWindupGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLAntiWindupGain(kind, handler, param);}
    void getPLAntiWindupGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLAntiWindupGain(handler, param);}
    void getPLIntegratorLimitation(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLIntegratorLimitation(kind, handler, param);}
    void getPLIntegratorLimitation(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLIntegratorLimitation(handler, param);}
    void getPLIntegratorMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getPLIntegratorMode(kind, handler, param);}
    void getPLIntegratorMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getPLIntegratorMode(handler, param);}
    void getPLSpeedFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFilter(kind, handler, param);}
    void getPLSpeedFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFilter(handler, param);}
    void getPLOutputFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLOutputFilter(kind, handler, param);}
    void getPLOutputFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLOutputFilter(handler, param);}
    void getCLInputFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLInputFilter(kind, handler, param);}
    void getCLInputFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLInputFilter(handler, param);}
    void getTtlSpecialFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getTtlSpecialFilter(kind, handler, param);}
    void getTtlSpecialFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getTtlSpecialFilter(handler, param);}
    void getPLForceFeedbackGain2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLForceFeedbackGain2(kind, handler, param);}
    void getPLForceFeedbackGain2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLForceFeedbackGain2(handler, param);}
    void getPLSpeedFeedfwdGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFeedfwdGain(kind, handler, param);}
    void getPLSpeedFeedfwdGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLSpeedFeedfwdGain(handler, param);}
    void getPLAccFeedforwardGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLAccFeedforwardGain(kind, handler, param);}
    void getPLAccFeedforwardGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPLAccFeedforwardGain(handler, param);}
    void getCLPhaseAdvanceFactor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLPhaseAdvanceFactor(kind, handler, param);}
    void getCLPhaseAdvanceFactor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLPhaseAdvanceFactor(handler, param);}
    void getAprInputFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAprInputFilter(kind, handler, param);}
    void getAprInputFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAprInputFilter(handler, param);}
    void getCLPhaseAdvanceShift(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLPhaseAdvanceShift(kind, handler, param);}
    void getCLPhaseAdvanceShift(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLPhaseAdvanceShift(handler, param);}
    void getMinPositionRangeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMinPositionRangeLimit(kind, handler, param);}
    void getMinPositionRangeLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMinPositionRangeLimit(handler, param);}
    void getMaxPositionRangeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxPositionRangeLimit(kind, handler, param);}
    void getMaxPositionRangeLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxPositionRangeLimit(handler, param);}
    void getMaxProfileVelocity(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxProfileVelocity(kind, handler, param);}
    void getMaxProfileVelocity(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxProfileVelocity(handler, param);}
    void getMaxAcceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxAcceleration(kind, handler, param);}
    void getMaxAcceleration(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxAcceleration(handler, param);}
    void getFollowingErrorWindow(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getFollowingErrorWindow(kind, handler, param);}
    void getFollowingErrorWindow(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getFollowingErrorWindow(handler, param);}
    void getVelocityErrorLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityErrorLimit(kind, handler, param);}
    void getVelocityErrorLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityErrorLimit(handler, param);}
    void getSwitchLimitMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getSwitchLimitMode(kind, handler, param);}
    void getSwitchLimitMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getSwitchLimitMode(handler, param);}
    void getEnableInputMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getEnableInputMode(kind, handler, param);}
    void getEnableInputMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getEnableInputMode(handler, param);}
    void getMinSoftPositionLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMinSoftPositionLimit(kind, handler, param);}
    void getMinSoftPositionLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMinSoftPositionLimit(handler, param);}
    void getMaxSoftPositionLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxSoftPositionLimit(kind, handler, param);}
    void getMaxSoftPositionLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMaxSoftPositionLimit(handler, param);}
    void getProfileLimitMode(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getProfileLimitMode(kind, handler, param);}
    void getProfileLimitMode(DsaDWordHandler handler, void *param = NULL) {DsaBase::getProfileLimitMode(handler, param);}
    void getIOErrorEventMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getIOErrorEventMask(kind, handler, param);}
    void getIOErrorEventMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getIOErrorEventMask(handler, param);}
    void getPositionWindowTime(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionWindowTime(kind, handler, param);}
    void getPositionWindowTime(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionWindowTime(handler, param);}
    void getPositionWindow(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionWindow(kind, handler, param);}
    void getPositionWindow(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionWindow(handler, param);}
    void getHomingMethod(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getHomingMethod(kind, handler, param);}
    void getHomingMethod(DsaIntHandler handler, void *param = NULL) {DsaBase::getHomingMethod(handler, param);}
    void getHomingZeroSpeed(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingZeroSpeed(kind, handler, param);}
    void getHomingZeroSpeed(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingZeroSpeed(handler, param);}
    void getHomingAcceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingAcceleration(kind, handler, param);}
    void getHomingAcceleration(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingAcceleration(handler, param);}
    void getHomingFollowingLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFollowingLimit(kind, handler, param);}
    void getHomingFollowingLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFollowingLimit(handler, param);}
    void getHomingCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingCurrentLimit(kind, handler, param);}
    void getHomingCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingCurrentLimit(handler, param);}
    void getHomeOffset(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomeOffset(kind, handler, param);}
    void getHomeOffset(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomeOffset(handler, param);}
    void getHomingFixedMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFixedMvt(kind, handler, param);}
    void getHomingFixedMvt(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFixedMvt(handler, param);}
    void getHomingSwitchMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingSwitchMvt(kind, handler, param);}
    void getHomingSwitchMvt(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingSwitchMvt(handler, param);}
    void getHomingIndexMvt(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingIndexMvt(kind, handler, param);}
    void getHomingIndexMvt(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingIndexMvt(handler, param);}
    void getHomingFineTuningMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getHomingFineTuningMode(kind, handler, param);}
    void getHomingFineTuningMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getHomingFineTuningMode(handler, param);}
    void getHomingFineTuningValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFineTuningValue(kind, handler, param);}
    void getHomingFineTuningValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getHomingFineTuningValue(handler, param);}
    void getMotorPhaseCorrection(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMotorPhaseCorrection(kind, handler, param);}
    void getMotorPhaseCorrection(DsaIntHandler handler, void *param = NULL) {DsaBase::getMotorPhaseCorrection(handler, param);}
    void getSoftwareCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSoftwareCurrentLimit(kind, handler, param);}
    void getSoftwareCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSoftwareCurrentLimit(handler, param);}
    void getDriveControlMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDriveControlMode(kind, handler, param);}
    void getDriveControlMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getDriveControlMode(handler, param);}
    void getDisplayMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDisplayMode(kind, handler, param);}
    void getDisplayMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getDisplayMode(handler, param);}
    void getEncoderInversion(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderInversion(kind, handler, param);}
    void getEncoderInversion(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderInversion(handler, param);}
    void getPdrStepValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPdrStepValue(kind, handler, param);}
    void getPdrStepValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPdrStepValue(handler, param);}
    void getEncoderPhase1Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase1Offset(kind, handler, param);}
    void getEncoderPhase1Offset(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase1Offset(handler, param);}
    void getEncoderPhase2Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase2Offset(kind, handler, param);}
    void getEncoderPhase2Offset(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase2Offset(handler, param);}
    void getEncoderPhase1Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase1Factor(kind, handler, param);}
    void getEncoderPhase1Factor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase1Factor(handler, param);}
    void getEncoderPhase2Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase2Factor(kind, handler, param);}
    void getEncoderPhase2Factor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase2Factor(handler, param);}
    void getEncoderPhase3Offset(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase3Offset(kind, handler, param);}
    void getEncoderPhase3Offset(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase3Offset(handler, param);}
    void getEncoderIndexDistance(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderIndexDistance(kind, handler, param);}
    void getEncoderIndexDistance(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderIndexDistance(handler, param);}
    void getEncoderPhase3Factor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase3Factor(kind, handler, param);}
    void getEncoderPhase3Factor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderPhase3Factor(handler, param);}
    void getCLProportionalGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLProportionalGain(kind, handler, param);}
    void getCLProportionalGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLProportionalGain(handler, param);}
    void getCLIntegratorGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLIntegratorGain(kind, handler, param);}
    void getCLIntegratorGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLIntegratorGain(handler, param);}
    void getCLOutputFilter(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLOutputFilter(kind, handler, param);}
    void getCLOutputFilter(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLOutputFilter(handler, param);}
    void getCLCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentLimit(kind, handler, param);}
    void getCLCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentLimit(handler, param);}
    void getCLI2tCurrentLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tCurrentLimit(kind, handler, param);}
    void getCLI2tCurrentLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tCurrentLimit(handler, param);}
    void getCLI2tTimeLimit(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tTimeLimit(kind, handler, param);}
    void getCLI2tTimeLimit(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tTimeLimit(handler, param);}
    void getCLRegenMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getCLRegenMode(kind, handler, param);}
    void getCLRegenMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getCLRegenMode(handler, param);}
    void getInitMode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getInitMode(kind, handler, param);}
    void getInitMode(DsaIntHandler handler, void *param = NULL) {DsaBase::getInitMode(handler, param);}
    void getInitPulseLevel(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitPulseLevel(kind, handler, param);}
    void getInitPulseLevel(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitPulseLevel(handler, param);}
    void getInitMaxCurrent(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitMaxCurrent(kind, handler, param);}
    void getInitMaxCurrent(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitMaxCurrent(handler, param);}
    void getInitFinalPhase(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitFinalPhase(kind, handler, param);}
    void getInitFinalPhase(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitFinalPhase(handler, param);}
    void getInitTime(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitTime(kind, handler, param);}
    void getInitTime(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitTime(handler, param);}
    void getInitCurrentRate(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitCurrentRate(kind, handler, param);}
    void getInitCurrentRate(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitCurrentRate(handler, param);}
    void getInitPhaseRate(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitPhaseRate(kind, handler, param);}
    void getInitPhaseRate(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitPhaseRate(handler, param);}
    void getInitInitialPhase(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitInitialPhase(kind, handler, param);}
    void getInitInitialPhase(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getInitInitialPhase(handler, param);}
    void getDriveFuseChecking(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveFuseChecking(kind, handler, param);}
    void getDriveFuseChecking(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveFuseChecking(handler, param);}
    void getMotorTempChecking(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getMotorTempChecking(kind, handler, param);}
    void getMotorTempChecking(DsaDWordHandler handler, void *param = NULL) {DsaBase::getMotorTempChecking(handler, param);}
    void getMonSourceType(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonSourceType(sidx, kind, handler, param);}
    void getMonSourceType(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonSourceType(sidx, handler, param);}
    void getMonSourceIndex(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonSourceIndex(sidx, kind, handler, param);}
    void getMonSourceIndex(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonSourceIndex(sidx, handler, param);}
    void getMonDestIndex(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonDestIndex(sidx, kind, handler, param);}
    void getMonDestIndex(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getMonDestIndex(sidx, handler, param);}
    void getMonOffset(int sidx, int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getMonOffset(sidx, kind, handler, param);}
    void getMonOffset(int sidx, DsaLongHandler handler, void *param = NULL) {DsaBase::getMonOffset(sidx, handler, param);}
    void getMonGain(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMonGain(sidx, kind, handler, param);}
    void getMonGain(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMonGain(sidx, handler, param);}
    void getXAnalogOffset(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOffset(sidx, kind, handler, param);}
    void getXAnalogOffset(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOffset(sidx, handler, param);}
    void getXAnalogGain(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogGain(sidx, kind, handler, param);}
    void getXAnalogGain(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogGain(sidx, handler, param);}
    void getSyncroInputMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getSyncroInputMask(kind, handler, param);}
    void getSyncroInputMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getSyncroInputMask(handler, param);}
    void getSyncroInputValue(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getSyncroInputValue(kind, handler, param);}
    void getSyncroInputValue(DsaDWordHandler handler, void *param = NULL) {DsaBase::getSyncroInputValue(handler, param);}
    void getSyncroOutputMask(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSyncroOutputMask(kind, handler, param);}
    void getSyncroOutputMask(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSyncroOutputMask(handler, param);}
    void getSyncroOutputValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSyncroOutputValue(kind, handler, param);}
    void getSyncroOutputValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getSyncroOutputValue(handler, param);}
    void getSyncroStartTimeout(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getSyncroStartTimeout(kind, handler, param);}
    void getSyncroStartTimeout(DsaIntHandler handler, void *param = NULL) {DsaBase::getSyncroStartTimeout(handler, param);}
    void getDigitalOutput(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDigitalOutput(kind, handler, param);}
    void getDigitalOutput(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDigitalOutput(handler, param);}
    void getXDigitalOutput(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getXDigitalOutput(kind, handler, param);}
    void getXDigitalOutput(DsaDWordHandler handler, void *param = NULL) {DsaBase::getXDigitalOutput(handler, param);}
    void getXAnalogOutput1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput1(kind, handler, param);}
    void getXAnalogOutput1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput1(handler, param);}
    void getXAnalogOutput2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput2(kind, handler, param);}
    void getXAnalogOutput2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogOutput2(handler, param);}
    void getAnalogOutput(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAnalogOutput(kind, handler, param);}
    void getAnalogOutput(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAnalogOutput(handler, param);}
    void getInterruptMask1(int sidx, int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getInterruptMask1(sidx, kind, handler, param);}
    void getInterruptMask1(int sidx, DsaDWordHandler handler, void *param = NULL) {DsaBase::getInterruptMask1(sidx, handler, param);}
    void getInterruptMask2(int sidx, int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getInterruptMask2(sidx, kind, handler, param);}
    void getInterruptMask2(int sidx, DsaDWordHandler handler, void *param = NULL) {DsaBase::getInterruptMask2(sidx, handler, param);}
    void getTriggerIrqMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getTriggerIrqMask(kind, handler, param);}
    void getTriggerIrqMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getTriggerIrqMask(handler, param);}
    void getTriggerIOMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getTriggerIOMask(kind, handler, param);}
    void getTriggerIOMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getTriggerIOMask(handler, param);}
    void getTriggerMapOffset(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getTriggerMapOffset(kind, handler, param);}
    void getTriggerMapOffset(DsaIntHandler handler, void *param = NULL) {DsaBase::getTriggerMapOffset(handler, param);}
    void getTriggerMapSize(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getTriggerMapSize(kind, handler, param);}
    void getTriggerMapSize(DsaIntHandler handler, void *param = NULL) {DsaBase::getTriggerMapSize(handler, param);}
    void getRealtimeEnabledGlobal(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getRealtimeEnabledGlobal(kind, handler, param);}
    void getRealtimeEnabledGlobal(DsaIntHandler handler, void *param = NULL) {DsaBase::getRealtimeEnabledGlobal(handler, param);}
    void getRealtimeValidMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getRealtimeValidMask(kind, handler, param);}
    void getRealtimeValidMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getRealtimeValidMask(handler, param);}
    void getRealtimeEnabledMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getRealtimeEnabledMask(kind, handler, param);}
    void getRealtimeEnabledMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getRealtimeEnabledMask(handler, param);}
    void getRealtimePendingMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getRealtimePendingMask(kind, handler, param);}
    void getRealtimePendingMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getRealtimePendingMask(handler, param);}
    void getEblBaudrate(int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getEblBaudrate(kind, handler, param);}
    void getEblBaudrate(DsaLongHandler handler, void *param = NULL) {DsaBase::getEblBaudrate(handler, param);}
    void getIndirectAxisNumber(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectAxisNumber(kind, handler, param);}
    void getIndirectAxisNumber(DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectAxisNumber(handler, param);}
    void getIndirectRegisterIdx(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectRegisterIdx(kind, handler, param);}
    void getIndirectRegisterIdx(DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectRegisterIdx(handler, param);}
    void getIndirectRegisterSidx(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectRegisterSidx(kind, handler, param);}
    void getIndirectRegisterSidx(DsaIntHandler handler, void *param = NULL) {DsaBase::getIndirectRegisterSidx(handler, param);}
    void getConcatenatedMvt(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getConcatenatedMvt(kind, handler, param);}
    void getConcatenatedMvt(DsaIntHandler handler, void *param = NULL) {DsaBase::getConcatenatedMvt(handler, param);}
    void getProfileType(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getProfileType(sidx, kind, handler, param);}
    void getProfileType(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getProfileType(sidx, handler, param);}
    void getMvtLktNumber(int sidx, int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getMvtLktNumber(sidx, kind, handler, param);}
    void getMvtLktNumber(int sidx, DsaIntHandler handler, void *param = NULL) {DsaBase::getMvtLktNumber(sidx, handler, param);}
    void getMvtLktTime(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMvtLktTime(sidx, kind, handler, param);}
    void getMvtLktTime(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMvtLktTime(sidx, handler, param);}
    void getCameValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCameValue(kind, handler, param);}
    void getCameValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCameValue(handler, param);}
    void getBrakeDeceleration(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getBrakeDeceleration(kind, handler, param);}
    void getBrakeDeceleration(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getBrakeDeceleration(handler, param);}
    void getTargetPosition(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getTargetPosition(sidx, kind, handler, param);}
    void getTargetPosition(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getTargetPosition(sidx, handler, param);}
    void getProfileVelocity(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileVelocity(sidx, kind, handler, param);}
    void getProfileVelocity(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileVelocity(sidx, handler, param);}
    void getProfileAcceleration(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileAcceleration(sidx, kind, handler, param);}
    void getProfileAcceleration(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileAcceleration(sidx, handler, param);}
    void getJerkTime(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getJerkTime(sidx, kind, handler, param);}
    void getJerkTime(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getJerkTime(sidx, handler, param);}
    void getProfileDeceleration(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileDeceleration(sidx, kind, handler, param);}
    void getProfileDeceleration(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getProfileDeceleration(sidx, handler, param);}
    void getEndVelocity(int sidx, int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEndVelocity(sidx, kind, handler, param);}
    void getEndVelocity(int sidx, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEndVelocity(sidx, handler, param);}
    void getCtrlSourceType(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlSourceType(kind, handler, param);}
    void getCtrlSourceType(DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlSourceType(handler, param);}
    void getCtrlSourceIndex(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlSourceIndex(kind, handler, param);}
    void getCtrlSourceIndex(DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlSourceIndex(handler, param);}
    void getCtrlShiftFactor(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlShiftFactor(kind, handler, param);}
    void getCtrlShiftFactor(DsaIntHandler handler, void *param = NULL) {DsaBase::getCtrlShiftFactor(handler, param);}
    void getCtrlOffset(int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getCtrlOffset(kind, handler, param);}
    void getCtrlOffset(DsaLongHandler handler, void *param = NULL) {DsaBase::getCtrlOffset(handler, param);}
    void getCtrlGain(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCtrlGain(kind, handler, param);}
    void getCtrlGain(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCtrlGain(handler, param);}
    void getMotorKTFactor(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMotorKTFactor(kind, handler, param);}
    void getMotorKTFactor(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getMotorKTFactor(handler, param);}
    void getPositionCtrlError(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionCtrlError(kind, handler, param);}
    void getPositionCtrlError(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionCtrlError(handler, param);}
    void getPositionMaxError(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionMaxError(kind, handler, param);}
    void getPositionMaxError(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionMaxError(handler, param);}
    void getPositionDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionDemandValue(kind, handler, param);}
    void getPositionDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionDemandValue(handler, param);}
    void getPositionActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionActualValue(kind, handler, param);}
    void getPositionActualValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getPositionActualValue(handler, param);}
    void getVelocityDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityDemandValue(kind, handler, param);}
    void getVelocityDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityDemandValue(handler, param);}
    void getVelocityActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityActualValue(kind, handler, param);}
    void getVelocityActualValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getVelocityActualValue(handler, param);}
    void getAccDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAccDemandValue(kind, handler, param);}
    void getAccDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAccDemandValue(handler, param);}
    void getAccActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAccActualValue(kind, handler, param);}
    void getAccActualValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAccActualValue(handler, param);}
    void getRefDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getRefDemandValue(kind, handler, param);}
    void getRefDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getRefDemandValue(handler, param);}
    void getDriveControlMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveControlMask(kind, handler, param);}
    void getDriveControlMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveControlMask(handler, param);}
    void getCLCurrentPhase1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase1(kind, handler, param);}
    void getCLCurrentPhase1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase1(handler, param);}
    void getCLCurrentPhase2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase2(kind, handler, param);}
    void getCLCurrentPhase2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase2(handler, param);}
    void getCLCurrentPhase3(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase3(kind, handler, param);}
    void getCLCurrentPhase3(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLCurrentPhase3(handler, param);}
    void getCLLktPhase1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase1(kind, handler, param);}
    void getCLLktPhase1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase1(handler, param);}
    void getCLLktPhase2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase2(kind, handler, param);}
    void getCLLktPhase2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase2(handler, param);}
    void getCLLktPhase3(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase3(kind, handler, param);}
    void getCLLktPhase3(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLLktPhase3(handler, param);}
    void getCLDemandValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLDemandValue(kind, handler, param);}
    void getCLDemandValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLDemandValue(handler, param);}
    void getCLActualValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLActualValue(kind, handler, param);}
    void getCLActualValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLActualValue(handler, param);}
    void getEncoderSineSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderSineSignal(kind, handler, param);}
    void getEncoderSineSignal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderSineSignal(handler, param);}
    void getEncoderCosineSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderCosineSignal(kind, handler, param);}
    void getEncoderCosineSignal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderCosineSignal(handler, param);}
    void getEncoderIndexSignal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderIndexSignal(kind, handler, param);}
    void getEncoderIndexSignal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderIndexSignal(handler, param);}
    void getEncoderHall1Signal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderHall1Signal(kind, handler, param);}
    void getEncoderHall1Signal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderHall1Signal(handler, param);}
    void getEncoderHall2Signal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderHall2Signal(kind, handler, param);}
    void getEncoderHall2Signal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderHall2Signal(handler, param);}
    void getEncoderHall3Signal(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderHall3Signal(kind, handler, param);}
    void getEncoderHall3Signal(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getEncoderHall3Signal(handler, param);}
    void getEncoderHallDigSignal(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getEncoderHallDigSignal(kind, handler, param);}
    void getEncoderHallDigSignal(DsaDWordHandler handler, void *param = NULL) {DsaBase::getEncoderHallDigSignal(handler, param);}
    void getDigitalInput(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDigitalInput(kind, handler, param);}
    void getDigitalInput(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDigitalInput(handler, param);}
    void getAnalogInput(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAnalogInput(kind, handler, param);}
    void getAnalogInput(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getAnalogInput(handler, param);}
    void getXDigitalInput(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getXDigitalInput(kind, handler, param);}
    void getXDigitalInput(DsaDWordHandler handler, void *param = NULL) {DsaBase::getXDigitalInput(handler, param);}
    void getXAnalogInput1(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput1(kind, handler, param);}
    void getXAnalogInput1(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput1(handler, param);}
    void getXAnalogInput2(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput2(kind, handler, param);}
    void getXAnalogInput2(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getXAnalogInput2(handler, param);}
    void getDriveStatus1(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveStatus1(kind, handler, param);}
    void getDriveStatus1(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveStatus1(handler, param);}
    void getDriveStatus2(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveStatus2(kind, handler, param);}
    void getDriveStatus2(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveStatus2(handler, param);}
    void getErrorCode(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getErrorCode(kind, handler, param);}
    void getErrorCode(DsaIntHandler handler, void *param = NULL) {DsaBase::getErrorCode(handler, param);}
    void getCLI2tValue(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tValue(kind, handler, param);}
    void getCLI2tValue(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getCLI2tValue(handler, param);}
    void getAxisNumber(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getAxisNumber(kind, handler, param);}
    void getAxisNumber(DsaIntHandler handler, void *param = NULL) {DsaBase::getAxisNumber(handler, param);}
    void getDaisyChainNumber(int kind, DsaIntHandler handler, void *param = NULL) {DsaBase::getDaisyChainNumber(kind, handler, param);}
    void getDaisyChainNumber(DsaIntHandler handler, void *param = NULL) {DsaBase::getDaisyChainNumber(handler, param);}
    void getDriveTemperature(int kind, DsaDoubleHandler handler, void *param = NULL) {DsaBase::getDriveTemperature(kind, handler, param);}
    void getDriveTemperature(DsaDoubleHandler handler, void *param = NULL) {DsaBase::getDriveTemperature(handler, param);}
    void getDriveMaskValue(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveMaskValue(kind, handler, param);}
    void getDriveMaskValue(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveMaskValue(handler, param);}
    void getDriveDisplay(int sidx, int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveDisplay(sidx, kind, handler, param);}
    void getDriveDisplay(int sidx, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveDisplay(sidx, handler, param);}
    void getDriveSequenceLine(int kind, DsaLongHandler handler, void *param = NULL) {DsaBase::getDriveSequenceLine(kind, handler, param);}
    void getDriveSequenceLine(DsaLongHandler handler, void *param = NULL) {DsaBase::getDriveSequenceLine(handler, param);}
    void getDriveFuseStatus(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveFuseStatus(kind, handler, param);}
    void getDriveFuseStatus(DsaDWordHandler handler, void *param = NULL) {DsaBase::getDriveFuseStatus(handler, param);}
    void getIrqDriveStatus1(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getIrqDriveStatus1(kind, handler, param);}
    void getIrqDriveStatus1(DsaDWordHandler handler, void *param = NULL) {DsaBase::getIrqDriveStatus1(handler, param);}
    void getIrqDriveStatus2(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getIrqDriveStatus2(kind, handler, param);}
    void getIrqDriveStatus2(DsaDWordHandler handler, void *param = NULL) {DsaBase::getIrqDriveStatus2(handler, param);}
    void getAckDriveStatus1(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getAckDriveStatus1(kind, handler, param);}
    void getAckDriveStatus1(DsaDWordHandler handler, void *param = NULL) {DsaBase::getAckDriveStatus1(handler, param);}
    void getAckDriveStatus2(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getAckDriveStatus2(kind, handler, param);}
    void getAckDriveStatus2(DsaDWordHandler handler, void *param = NULL) {DsaBase::getAckDriveStatus2(handler, param);}
    void getIrqPendingAxisMask(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getIrqPendingAxisMask(kind, handler, param);}
    void getIrqPendingAxisMask(DsaDWordHandler handler, void *param = NULL) {DsaBase::getIrqPendingAxisMask(handler, param);}
    void getCanFeedback1(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getCanFeedback1(kind, handler, param);}
    void getCanFeedback1(DsaDWordHandler handler, void *param = NULL) {DsaBase::getCanFeedback1(handler, param);}
    void getCanFeedback2(int kind, DsaDWordHandler handler, void *param = NULL) {DsaBase::getCanFeedback2(kind, handler, param);}
    void getCanFeedback2(DsaDWordHandler handler, void *param = NULL) {DsaBase::getCanFeedback2(handler, param);}

};


/**
 * DsaGPModuleGroup class - C++
 */
class DsaGPModuleGroup: public DsaBase {
	/* constructors */
private:
    void _Group(int max, ...) {
        va_list arg;
        va_start(arg, max);
        ERRCHK(dsa_create_gp_module_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
        va_end(arg);
    }
protected:
	DsaGPModuleGroup(void) {
	}
public:
	DsaGPModuleGroup(DsaGPModuleGroup &obj) {
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
	DsaGPModuleGroup(DsaBase &obj) {
		if (!dsa_is_valid_gp_module_group(obj.dsa))
			throw bad_cast("cannot cast to DsaGPModuleGroup");
        ERRCHK(dsa_share(obj.dsa));
		dsa = obj.dsa;
	}
    DsaGPModuleGroup(int max, ...) {
        va_list arg;
        va_start(arg, max);
        ERRCHK(dsa_create_gp_module_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, va_arg(arg, DsaBase *)->dsa));
        va_end(arg);
    }       
    DsaGPModuleGroup(int max, DsaGPModuleBase *list[]) {
        ERRCHK(dsa_create_gp_module_group(&dsa, max));
        for(int i = 0; i < max; i++) 
            ERRCHK(dsa_set_group_item(dsa, i, list[i]->dsa));
    }       
    DsaGPModuleGroup(DsaGPModuleBase d1, DsaGPModuleBase d2) { 
        _Group(2, &d1, &d2); 
    }
    DsaGPModuleGroup(DsaGPModuleBase d1, DsaGPModuleBase d2, DsaGPModuleBase d3) { 
        _Group(3, &d1, &d2, &d3); 
    }
    DsaGPModuleGroup(DsaGPModuleBase d1, DsaGPModuleBase d2, DsaGPModuleBase d3, DsaGPModuleBase d4) { 
        _Group(4, &d1, &d2, &d3, &d4); 
    }
    DsaGPModuleGroup(DsaGPModuleBase d1, DsaGPModuleBase d2, DsaGPModuleBase d3, DsaGPModuleBase d4, DsaGPModuleBase d5) { 
        _Group(5, &d1, &d2, &d3, &d4, &d5); 
    }
    DsaGPModuleGroup(DsaGPModuleBase d1, DsaGPModuleBase d2, DsaGPModuleBase d3, DsaGPModuleBase d4, DsaGPModuleBase d5, DsaGPModuleBase d6) { 
        _Group(6, &d1, &d2, &d3, &d4, &d5, &d6); 
    }
    DsaGPModuleGroup(DsaGPModuleBase d1, DsaGPModuleBase d2, DsaGPModuleBase d3, DsaGPModuleBase d4, DsaGPModuleBase d5, DsaGPModuleBase d6, DsaGPModuleBase d7) { 
        _Group(7, &d1, &d2, &d3, &d4, &d5, &d6, &d7); 
    }
    DsaGPModuleGroup(DsaGPModuleBase d1, DsaGPModuleBase d2, DsaGPModuleBase d3, DsaGPModuleBase d4, DsaGPModuleBase d5, DsaGPModuleBase d6, DsaGPModuleBase d7, DsaGPModuleBase d8) { 
        _Group(8, &d1, &d2, &d3, &d4, &d5, &d6, &d7, &d8); 
    }
	/* operators */
public:
	DsaGPModuleGroup operator = (DsaGPModuleGroup &obj) {
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	DsaGPModuleGroup operator = (DsaBase &obj) {
		if (!dsa_is_valid_gp_module_group(obj.dsa))
			throw bad_cast("cannot cast to DsaGPModuleGroup");
        ERRCHK(dsa_share(obj.dsa));
		ERRCHK(dsa_destroy(&dsa));
		dsa = obj.dsa;
		return *this;
	}
	/* hand make funtions */
public:
	DsaGPModuleBase getGroupItem(int pos) {return DsaBase::getGroupItem(pos);}
	/* functions */
    void quickStop(int mode, dword flags, long timeout = DEF_TIMEOUT) {DsaBase::quickStop(mode, flags, timeout);}
    void executeCommand(int cmd, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, timeout);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, long timeout = DEF_TIMEOUT) {DsaBase::executeCommand(cmd, params, count, fast, ereport, timeout);}
    void setRegister(int typ, unsigned idx, int sidx, long val, long timeout = DEF_TIMEOUT) {DsaBase::setRegister(typ, idx, sidx, val, timeout);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, long timeout = DEF_TIMEOUT) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, timeout);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, timeout);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, timeout);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusEqual(mask, ref, timeout);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, timeout);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusEqual(mask, ref, timeout);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, long timeout = DEF_TIMEOUT) {DsaBase::grpWaitORStatusNotEqual(mask, ref, timeout);}
    void setTraceModeMvt(double time, bool endm, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeMvt(time, endm, timeout);}
    void setTraceModePos(double time, double pos, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModePos(time, pos, timeout);}
    void setTraceModeDev(double time, long level, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeDev(time, level, timeout);}
    void setTraceModeIso(double time, void *level, int conv, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeIso(time, level, conv, timeout);}
    void setTraceModeImmediate(double time, long timeout = DEF_TIMEOUT) {DsaBase::setTraceModeImmediate(time, timeout);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, long timeout = DEF_TIMEOUT) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, timeout);}
    void syncTraceEnable(bool enable, long timeout = DEF_TIMEOUT) {DsaBase::syncTraceEnable(enable, timeout);}
    void syncTraceForceTrigger(long timeout = DEF_TIMEOUT) {DsaBase::syncTraceForceTrigger(timeout);}

    void quickStop(int mode, dword flags, DsaHandler handler, void *param = NULL) {DsaBase::quickStop(mode, flags, handler, param);}
    void executeCommand(int cmd, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, long par2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, long par1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, int typ1, double par1, int conv1, int typ2, double par2, int conv2, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, typ1, par1, conv1, typ2, par2, conv2, fast, ereport, handler, param);}
    void executeCommand(int cmd, DsaCommandParam *params, int count, bool fast, bool ereport, DsaHandler handler, void *param = NULL) {DsaBase::executeCommand(cmd, params, count, fast, ereport, handler, param);}
    void setRegister(int typ, unsigned idx, int sidx, long val, DsaHandler handler, void *param = NULL) {DsaBase::setRegister(typ, idx, sidx, val, handler, param);}
    void setArray(int typ, unsigned idx, unsigned nidx, int sidx, long *val, int offset, DsaHandler handler, void *param = NULL) {DsaBase::setArray(typ, idx, nidx, sidx, val, offset, handler, param);}
    void setIsoRegister(int typ, unsigned idx, int sidx, double val, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoRegister(typ, idx, sidx, val, conv, handler, param);}
    void setIsoArray(int typ, unsigned idx, unsigned nidx, int sidx, double *val, int offset, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setIsoArray(typ, idx, nidx, sidx, val, offset, conv, handler, param);}
    void grpWaitAndStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusEqual(mask, ref, handler, param);}
    void grpWaitAndStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitAndStatusNotEqual(mask, ref, handler, param);}
    void grpWaitORStatusEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusEqual(mask, ref, handler, param);}
    void grpWaitORStatusNotEqual(DsaStatus *mask, DsaStatus *ref, DsaHandler handler, void *param = NULL) {DsaBase::grpWaitORStatusNotEqual(mask, ref, handler, param);}
    void setTraceModeMvt(double time, bool endm, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeMvt(time, endm, handler, param);}
    void setTraceModePos(double time, double pos, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModePos(time, pos, handler, param);}
    void setTraceModeDev(double time, long level, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeDev(time, level, handler, param);}
    void setTraceModeIso(double time, void *level, int conv, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeIso(time, level, conv, handler, param);}
    void setTraceModeImmediate(double time, DsaHandler handler, void *param = NULL) {DsaBase::setTraceModeImmediate(time, handler, param);}
    void traceAcquisition(int typ1, int idx1, int sidx1, int typ2, int idx2, int sidx2, DsaHandler handler, void *param = NULL) {DsaBase::traceAcquisition(typ1, idx1, sidx1, typ2, idx2, sidx2, handler, param);}
    void syncTraceEnable(bool enable, DsaHandler handler, void *param = NULL) {DsaBase::syncTraceEnable(enable, handler, param);}
    void syncTraceForceTrigger(DsaHandler handler, void *param = NULL) {DsaBase::syncTraceForceTrigger(handler, param);}

    void getRtmMon(DsaRTM *rtm) {DsaBase::getRtmMon(rtm);}
    void initRtmFct() {DsaBase::initRtmFct();}
    void startRtm(DsaTrajectoryHandler fct) {DsaBase::startRtm(fct);}
    void stopRtm() {DsaBase::stopRtm();}
    void diag(char_cp file_name, int line, int err) {DsaBase::diag(file_name, line, err);}
    void sdiag(char_p str, char_cp file_name, int line, int err) {DsaBase::sdiag(str, file_name, line, err);}
    void fdiag(char_cp output_file_name, char_cp file_name, int line, int err) {DsaBase::fdiag(output_file_name, file_name, line, err);}
    int  getGroupSize() {return DsaBase::getGroupSize();}
    void cancelStatusWait() {DsaBase::cancelStatusWait();}
    void grpCancelStatusWait() {DsaBase::grpCancelStatusWait();}
    double  queryMinimumSampleTime() {return DsaBase::queryMinimumSampleTime();}
    double  querySampleTime(double time) {return DsaBase::querySampleTime(time);}

	/* commands */
    void resetError(long timeout = DEF_TIMEOUT) {DsaBase::resetError(timeout);}
    void executeSequence(int label, long timeout = DEF_TIMEOUT) {DsaBase::executeSequence(label, timeout);}
    void editSequence(long timeout = DEF_TIMEOUT) {DsaBase::editSequence(timeout);}
    void exitSequence(long timeout = DEF_TIMEOUT) {DsaBase::exitSequence(timeout);}
    void saveParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::saveParameters(what, timeout);}
    void loadParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::loadParameters(what, timeout);}
    void defaultParameters(int what, long timeout = DEF_TIMEOUT) {DsaBase::defaultParameters(what, timeout);}
    void waitMovement(long timeout = DEF_TIMEOUT) {DsaBase::waitMovement(timeout);}
    void waitPosition(double pos, long timeout = DEF_TIMEOUT) {DsaBase::waitPosition(pos, timeout);}
    void waitTime(double time, long timeout = DEF_TIMEOUT) {DsaBase::waitTime(time, timeout);}
    void waitWindow(long timeout = DEF_TIMEOUT) {DsaBase::waitWindow(timeout);}

    void resetError(DsaHandler handler, void *param = NULL) {DsaBase::resetError(handler, param);}
    void executeSequence(int label, DsaHandler handler, void *param = NULL) {DsaBase::executeSequence(label, handler, param);}
    void editSequence(DsaHandler handler, void *param = NULL) {DsaBase::editSequence(handler, param);}
    void exitSequence(DsaHandler handler, void *param = NULL) {DsaBase::exitSequence(handler, param);}
    void saveParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::saveParameters(what, handler, param);}
    void loadParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::loadParameters(what, handler, param);}
    void defaultParameters(int what, DsaHandler handler, void *param = NULL) {DsaBase::defaultParameters(what, handler, param);}
    void waitMovement(DsaHandler handler, void *param = NULL) {DsaBase::waitMovement(handler, param);}
    void waitPosition(double pos, DsaHandler handler, void *param = NULL) {DsaBase::waitPosition(pos, handler, param);}
    void waitTime(double time, DsaHandler handler, void *param = NULL) {DsaBase::waitTime(time, handler, param);}
    void waitWindow(DsaHandler handler, void *param = NULL) {DsaBase::waitWindow(handler, param);}

	/* register setters */


	/* register getters */


};

#undef ERRCHK
#endif /* DSA_OO_API */


#endif /* _DSA20_H */
