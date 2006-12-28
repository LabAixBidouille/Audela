/*
 * dmd10.h 1.00
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
 * This header file contains public declaration for drive meta-data library.\n
 * This library allows access to the definitions of all ETEL drives'versions.\n
 * This library is only a pool of datas.\n
 * No access is made to the drive itself.\n 
 * The available datas are, for example, the list of all versions of a product,
 * the number of registers of a product, the minimum and maximum values of a
 * register, etc.\n
 * This library is conformed to POSIX 1003.1c, and has been ported on the following OS:
 * @li @c WIN32
 * @li @c QNX4
 * @li @c QNX6
 * @li @c LINUX
 * @li @c LYNXOS
 * @li @c SOLARIS SPARC 5
 * @li @c SOLARIS X86
 * @file dmd10.h
 */


#ifndef _DMD10_H
#define _DMD10_H

#ifdef __WIN32__		/* defined by Borland C++ Builder */
#ifndef WIN32
#define WIN32
#endif
#endif

#ifdef __cplusplus
#ifdef ETEL_OO_API		/* defined by the user when he need the Object Oriented interface */
#define DMD_OO_API
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
#endif/*BYTE_ORDER*/
/*** libraries ***/

#include <time.h>
#include <limits.h>


/*** litterals ***/

/*
 * error codes - c
 */
#ifndef DMD_OO_API
#define DMD_EBADEXTVER                   -419        /**< an extention card with an incompatible version has been specified */
#define DMD_EBADDRVVER                   -418        /**< a drive with an incompatible version has been specified */
#define DMD_EBADEXTPROD                  -417        /**< an unknown extention card  product has been specified */
#define DMD_EBADDRVPROD                  -416        /**< an unknown drive product has been specified */
#define DMD_EBADPARAM                    -415        /**< one of the parameter is not valid */
#define DMD_ESYSTEM                      -414        /**< some system resource return an error */

#endif /* DMD_OO_API */

/*
 * lab-view (record 04h) command numbers
 */ 
#ifndef DMD_OO_API
#define DMD_LAB_TRACE_MODE               210         /* change trace acquisition speed and trigger mode */
#define DMD_LAB_TRACE_LEVEL              211         /* define trigger level for mode 3 and 4 */  
#define DMD_LAB_TRACE_ACQUIRE            202         /* trig aquisition of two vectors */
#endif /* DMD_OO_API */

/*
 * text query constants
 */ 
#ifndef DMD_OO_API
#define DMD_TEXT_MNEMONIC                1           /* mnemonic */
#define DMD_TEXT_SHORT                   2           /* short text description */
#endif /* DMD_OO_API */

/*
 * drive special user variables
 */ 
#ifndef DMD_OO_API
#define DMD_USR_ACC                      0xFFFF      /* special user data - accumulator */
#define DMD_VAR_INDIRECT		         0xFFFE      /* indirect register access */
#endif /* DMD_OO_API */

/*
 * special product number
 */ 
#ifndef DMD_OO_API
#define DMD_PRODUCT_ANY                  (-1)        /* special product number - any */
#endif /* DMD_OO_API */


/* 
 * release status
 */ 
#ifndef DMD_OO_API
#define DMD_MICRO_ALPHA                  0x00        /* base number for alpha releases */
#define DMD_MICRO_BETA                   0x40        /* base number for beta releases */
#define DMD_MICRO_FINAL                  0x80        /* base number for final releases */
#endif /* DMD_OO_API */

/*
 * some maximum values
 */
#ifndef DMD_OO_API
#define DMD_TYPES                        16          /* no more than 16 types now */
/* If you change this value, change WHERE clause in dmdCode, tableAllEnumGroups AND
   dmdlocal.t _dmd_enum_grps[][];*/
#define DMD_ENUMS                        128         /* no more than 128 enums now */
#define DMD_COMMANDS                     1280        /* no more than 1280 commands now */
#define DMD_CONVS                        256         /* no more than 256 conversions now */
#endif /* DMD_OO_API */


/*The enum values are now freezed
-ETELSQL-
SELECT subquery FROM prepareEnums
ORDER BY code;
-/ETELSQL-
*/

/*
 * ebl baud rates - c
 */
#ifndef DMD_OO_API
#define DMD_BAUDRATE_DEFAULT             0           /* default baud rate */
#define DMD_BAUDRATE_B_9600              9600        /* 9600 bauds */
#define DMD_BAUDRATE_B_19200             19200       /* 19200 bauds */
#define DMD_BAUDRATE_B_38400             38400       /* 38400 bauds */
#define DMD_BAUDRATE_B_57600             57600       /* 57600 bauds */
#define DMD_BAUDRATE_B_115200            115200      /* 115200 bauds */

#endif /* DMD_OO_API */


/*
 * display modes - c
 */
#ifndef DMD_OO_API
#define DMD_DISPLAY_NORMAL               1           /* normal informations */
#define DMD_DISPLAY_TEMPERATURE          2           /* drive temperature */
#define DMD_DISPLAY_ENCODER              4           /* analog encoder signals */
#define DMD_DISPLAY_SEQUENCE             8           /* sequence line number */
#define DMD_DISPLAY_X_BOARD              16          /* extension board */

#endif /* DMD_OO_API */


/*
 * drive error codes - c
 */
#ifndef DMD_OO_API
#define DMD_EDRV_SAVE_OPERATION          1           /* save operation error */
#define DMD_EDRV_OVER_CURRENT_1          2           /* over current 1 */
#define DMD_EDRV_OVER_CURRENT_2          3           /* over current 2 */
#define DMD_EDRV_I2T_OVER_CURRENT        4           /* i2t over current */
#define DMD_EDRV_OVER_TEMPERATURE        5           /* over temperature */
#define DMD_EDRV_OVER_VOLTAGE            6           /* over voltage error */
#define DMD_EDRV_POWER_SUPPLY_INRUSH     7           /* inrush power supply error */
#define DMD_EDRV_5V_UNDER_VOLTAGE        8           
#define DMD_EDRV_UNDER_VOLTAGE			 9
#define DMD_EDRV_OVER_OFFSET			 10
#define DMD_EDRV_ENCODER_AMPLITUDE       20          /* encoder amplitude error */
#define DMD_EDRV_ENCODER_POSITION_LOST   21          /* encoder position lost */
#define DMD_EDRV_UC_SYNCHRO              22          /* uc synchro error */
#define DMD_EDRV_TRACKING_ERROR          23          /* tracking error */
#define DMD_EDRV_OVER_SPEED              24          /* over speed error */
#define DMD_EDRV_POWER_ON                26          /* power on error */
#define DMD_EDRV_MOTOR_OVER_TEMP         29          /* motor over temperature */
#define DMD_EDRV_LIMIT_SWITCH            30          /* limit switch reached */
#define DMD_EDRV_LVDT_ERROR              31          /* LVDT error */
#define DMD_EDRV_LVDT_NOT_PRESENT        32          /* LVDT not present */
#define DMD_EDRV_LVDT_ADC_ERROR          33          /* LVDT ADC out */
#define DMD_EDRV_F3_FUSE                 34          /* F3 fuse dead */
#define DMD_EDRV_F7_FUSE                 35          /* F7 fuse dead */
#define DMD_EDRV_BAD_SEQ_LABEL           36          /* sequence label number */
#define DMD_EDRV_BAD_SEQ_LINE            37          /* sequence line number */
#define DMD_EDRV_BAD_REG_IDX             38          /* register number */
#define DMD_EDRV_STACK_OVERFLOW          39          /* stack overflow */
#define DMD_EDRV_ETB_FRAMING             46          /* EB framing error */
#define DMD_EDRV_ETB_OVERRUN             47          /* EB overrun */
#define DMD_EDRV_ETB_CHECKSUM            48          /* EB checksum error */
#define DMD_EDRV_ETB_SAME_AXIS           49          /* EB same axis error */
#define DMD_EDRV_ETB_UNKNOWN_MESSAGE     50          /* EB unknown message */
#define DMD_EDRV_ETB_DAISY_CHAIN         51          /* EB daisy chain error */
#define DMD_EDRV_ETB_NO_SLAVES           52          /* EB no slaves */
#define DMD_EDRV_ETB_OTHER_AXIS          53          /* EB other axis error */
#define DMD_EDRV_ETB_SELF_TEST           54          /* EB self test error */
#define DMD_EDRV_ETB_CHARACTER_LOST      55          /* EB character lost */
#define DMD_EDRV_ETB_TIMEOUT             56          /* EB timeout */
#define DMD_EDRV_HOMING_SWITCH_PRESENT   60
#define DMD_EDRV_MULTIPLE_INDEX          61          /* multiple index error */
#define DMD_EDRV_SINGLE_INDEX            62          /* single index error */
#define DMD_EDRV_SYNCHRO_START           63          /* synchro start error */
#define DMD_EDRV_X65			         65
#define DMD_EDRV_MASTER_POWER_OFF        67
#define DMD_EDRV_ETB_NO_MASTER           71          /* EB no master */
#define DMD_EDRV_EBL_FRAMING             80          /* EBL framing error */
#define DMD_EDRV_EBL_OVERRUN             81          /* EBL overrun */
#define DMD_EDRV_EBL_CHECKSUM            82          /* EBL checksum error */
#define DMD_EDRV_EBL_UNKNOWN_MESSAGE     83          /* EBL unknown message */
#define DMD_EDRV_EBL_INPUT_BUFFER        84          /* EBL input buffer error */
#define DMD_EDRV_BAD_CRC		         85          
#define DMD_EDRV_EBL_TIMEOUT_1           86          /* EBL timeout 1 */
#define DMD_EDRV_EBL_TIMEOUT_2           87          /* EBL timeout 2 */
#define DMD_EDRV_EBL_OTHER_AXIS          88          /* EBL other axis error */
#define DMD_EDRV_MAC_OVERRUN             89          /* MACRO overrun */
#define DMD_EDRV_MAC_VIOLATION           90          /* MACRO violation */
#define DMD_EDRV_MAC_PARITY              91          /* MACRO parity error */
#define DMD_EDRV_MAC_UNDERRUN            92          /* MACRO underrun */
#define DMD_EDRV_MAC_SYNC_LOST           93          /* MACRO synchro lost */
#define DMD_EDRV_MAC_AUX_2_CMD           94          /* MACRO aux 2 cmd error */
#define DMD_EDRV_MAC_AUX_2               95          /* MACRO aux 2 error */
#define DMD_EDRV_MAC_AUX_3               96          /* MACRO aux 3 error */
#define DMD_EDRV_MAC_AUX_4               97          /* MACRO aux 4 error */
#define DMD_EDRV_X100		             100
#define DMD_EDRV_X101		             101
#define DMD_EDRV_X102		             102
#define DMD_EDRV_X103		             103
#define DMD_EDRV_X104		             104
#define DMD_EDRV_X105		             105
#define DMD_EDRV_X106		             106
#define DMD_EDRV_X107		             107
#define DMD_EDRV_X108		             108
#define DMD_EDRV_X109		             109
#define DMD_EDRV_X110                    110
#define DMD_EDRV_X111                    111
#define DMD_EDRV_X112		             112
#define DMD_EDRV_X113		             113
#define DMD_EDRV_X114		             114
#define DMD_EDRV_X115		             115
#define DMD_EDRV_X116		             116
#define DMD_EDRV_BAD_GANTRY_CONF         117
#define DMD_EDRV_GANTRY_OTHER_AXIS_ERROR 118
#define DMD_EDRV_GANTRY_TRACKING_ERROR   119
#define DMD_EDRV_HARD_OVER_CURRENT       130         /* hardware overcurrent */
#define DMD_EDRV_WD_CURRENT_UC           140         /* current uc watchdog error */
#define DMD_EDRV_WD_POSITION_FPGA        141         /* position FPGA watchdog */
#define DMD_EDRV_WD_POSITION_UC          142         /* position uc watchdog error */
#define DMD_EDRV_WD_CURRENT_AD           143         /* current A/D watchdog */
#define DMD_EDRV_WD_QUARTZ               144         /* quartz watchdog */
#define DMD_EDRV_INIT_MOTOR_1            150         /* motor initialisation error 1 */
#define DMD_EDRV_INIT_MOTOR_2            151         /* motor initialisation error 2 */
#define DMD_EDRV_INIT_MOTOR_DISABLED     152    
#define DMD_EDRV_BAD_SOFTWARE            176         /* bad software */
#define DMD_EDRV_SAV_COMMAND		     190

#endif /* DMD_OO_API */


/*
 * status of enable input - c
 */
#ifndef DMD_OO_API
#define DMD_ENABLE_INPUT_REQUIRED        0           /* required */
#define DMD_ENABLE_INPUT_NOT_USED        125         /* not used */
#define DMD_ENABLE_INPUT_X135            135         /* enable use of K110, K111, K112 */
#define DMD_ENABLE_INPUT_AUTO            170         /* automatic */

#endif /* DMD_OO_API */


/*
 * kind of encoder - c
 */
#ifndef DMD_OO_API
#define DMD_ENCODER_ANALOG               0           /* analog encoder */
#define DMD_ENCODER_TTL                  1           /* TTL encoder */
#define DMD_ENCODER_HALL                 2           /* HALL encoder */
#define DMD_ENCODER_LVDT                 3           /* LVDT encoder */
#define DMD_ENCODER_ANALOG_AND_MACRO     100         /* analog encoder with MACRO bus */
#define DMD_ENCODER_TTL_AND_MACRO        101         /* TTL encoder with MACRO bus */
#define DMD_ENCODER_UNCHECKED_ANALOG_AND 102         /* unchecked analog encoder with MACRO bus */
#define DMD_ENCODER_HALL_AND_MACRO       103         /* HALL encoder with MACRO bus */

#endif /* DMD_OO_API */


/*
 * mask of fuses not controlled - c
 */
#ifndef DMD_OO_API
#define DMD_FUSE_CTRL_F3_DISABLED        1           /* F3 disabled */
#define DMD_FUSE_CTRL_F7_DISABLED        2           /* F7 disabled */

#endif /* DMD_OO_API */


/*
 * usage of limit/home switch - c
 */
#ifndef DMD_OO_API
#define DMD_SWITCH_LIMIT_ENABLED         1           /* limit switch enabled */
#define DMD_SWITCH_HOME_INVERTED         2           /* home switch inverted */
#define DMD_SWITCH_HOME_ENABLED          128         /* home switch enabled */

#endif /* DMD_OO_API */


/*
 * homing modes - c
 */
#ifndef DMD_OO_API
#define DMD_HOMING_NEGATIVE_MVT          1           /* negative movement */
#define DMD_HOMING_MECHANICAL            0           /* mechanical end stop */
#define DMD_HOMING_HOME_SW               2           /* home switch */
#define DMD_HOMING_LIMIT_SW              4           /* limit switch */
#define DMD_HOMING_HOME_SW_L             6           /* home switch w/limit */
#define DMD_HOMING_SINGLE_INDEX          8           /* single index */
#define DMD_HOMING_SINGLE_INDEX_L        10          /* single index w/limit */
#define DMD_HOMING_MULTI_INDEX           12          /* multi-index */
#define DMD_HOMING_MULTI_INDEX_L         14          /* multi-index w/limit */
#define DMD_HOMING_GATED_INDEX           16          /* single index and DIN2 */
#define DMD_HOMING_GATED_INDEX_L         18          /* single index and DIN2 w/limit */
#define DMD_HOMING_MULTI_INDEX_DS        20          /* multi-index w/defined stroke */
#define DMD_HOMING_IMMEDIATE             22          /* immediate */
#define DMD_HOMING_SINGLE_INDEX_DS       24          /* single index w/defined stroke */

#endif /* DMD_OO_API */


/*
 * init modes - c
 */
#ifndef DMD_OO_API
#define DMD_INIT_NONE                    0           /* none */
#define DMD_INIT_PULSE                   1           /* current pulses */
#define DMD_INIT_CONTINOUS               2           /* continous current */
#define DMD_INIT_HALL_UNTIL_EDGE         3           /* digital hall sensor until edge */
#define DMD_INIT_HALL_UNTIL_INDEX        4           /* digital hall sensor until index */
#define DMD_INIT_HALL                    5           /* digital hall sensor */

#endif /* DMD_OO_API */


/*
 * integrator mode - c
 */
#ifndef DMD_OO_API
#define DMD_INTEGRATOR_ON                0           /* always off */
#define DMD_INTEGRATOR_IN_POSITION       1           /* on in position */
#define DMD_INTEGRATOR_OFF               2           /* always on */

#endif /* DMD_OO_API */


/*
 * motor phase correction - c
 */
#ifndef DMD_OO_API
#define DMD_PHASE_CORR_PHASES            0           /* phase not inverted */
#define DMD_PHASE_CORR_FORCE             3           /* phase inverted */

#endif /* DMD_OO_API */


/*
 * lookup-table definitions - c
 */
#ifndef DMD_OO_API
#define DMD_LKT_USER_0                   0           /* user defined 0 */
#define DMD_LKT_USER_1                   1           /* user defined 1 */
#define DMD_LKT_USER_2                   2           /* user defined 2 */
#define DMD_LKT_USER_3                   3           /* user defined 3 */
#define DMD_LKT_S_CURVE                  25          /* s-curve */
#define DMD_LKT_TRIANGULAR               28          /* triangular */
#define DMD_LKT_SINE_CURVE               31          /* sine curve */

#endif /* DMD_OO_API */


/*
 * drive mode - c
 */
#ifndef DMD_OO_API
#define DMD_MODE_FORCE_REFERENCE         0           /* force reference */
#define DMD_MODE_POSITION_PROFILE        1           /* position profile */
#define DMD_MODE_SPEED_REFERENCE         3           /* speed reference */
#define DMD_MODE_POSITION_REFERENCE      4           /* position reference */
#define DMD_MODE_PULSE_DIRECTION         5           /* pulse direction */
#define DMD_MODE_PULSE_DIRECTION_TTL     6           /* pulse direction TTL */
#define DMD_MODE_DSMAX_POSITION_REFERENC 7           /* DSMAX position reference */
#define DMD_MODE_POSITION_REFERENCE_2    36          /* position reference */
#define DMD_MODE_PULSE_DIRECTION_2       37          /* pulse direction */
#define DMD_MODE_PULSE_DIRECTION_TTL_2   38          /* pulse direction TTL */

#endif /* DMD_OO_API */


/*
 * motor phases - c
 */
#ifndef DMD_OO_API
#define DMD_PWM_MODE_PHASES_1            10          /* 1 phase motor */
#define DMD_PWM_MODE_PHASE_1_LOW_SWITCHI 11          /* 1 phase motor with low switching freq */
#define DMD_PWM_MODE_PHASE_1_HIGH_CL_FRE 13          /* 1 phase motor with high cl freq. */
#define DMD_PWM_MODE_PHASES_2            20          /* 2 phase motor */
#define DMD_PWM_MODE_PHASE_2_LOW_SWITCHI 21          /* 2 phase motor with low switching freq. */
#define DMD_PWM_MODE_PHASE_2_HIGH_CL_FRE 23          /* 2 phase motor with high cl freq. */
#define DMD_PWM_MODE_PHASES_3            30          /* 3 phase motor */
#define DMD_PWM_MODE_PHASE_3_LOW_SWITCHI 31          /* 3 phase motor with low switching freq. */
#define DMD_PWM_MODE_PHASE_3_HIGH_CL_FRE 33          /* 3 phase motor with high cl freq. */

#endif /* DMD_OO_API */


/*
 * types of movement - c
 */
#ifndef DMD_OO_API
#define DMD_MVT_TRAPEZIODAL              0           /* trapezoidal movement */
#define DMD_MVT_S_CURVE                  1           /* S-curve movement */
#define DMD_MVT_INFINITE_ROTARY_SLOW     8           /* infinite rotary movement */
#define DMD_MVT_SLOW_LKT                 10          /* LKT movement in slow interrupt */
#define DMD_MVT_FAST_LKT                 11          /* LKT movement in fast interrupt */
#define DMD_MVT_INFINITE_ROTARY_FAST     12          /* infinite rotary movement (deprecated) */
#define DMD_MVT_TTL_DRIVEN_LKT           13          /* LKT movement drived by TTL encoder */
#define DMD_MVT_SCURVE_ROTARY            17          /* S-curve rotary movement */
#define DMD_MVT_INFINITE_ROTARY          24          /* infinite rotary movement */
#define DMD_MVT_LKT_ROTARY               26          /* LKT rotary movement */

#endif /* DMD_OO_API */


/*
 * drive products - c
 */
#ifndef DMD_OO_API
#define DMD_PRODUCT_DSA2P                2           /* DSA2P drive */
#define DMD_PRODUCT_DSB2P                4           /* DSB2P drive */
#define DMD_PRODUCT_DSC2P                6           /* DSC2P drive */
#define DMD_PRODUCT_DSCDP                7           /* DSCDP drive */
#define DMD_PRODUCT_DSCDL                8           /* DSCDL drive */
#define DMD_PRODUCT_DSCDL_QT             9           /* DSCDL Servo Track Writer*/
#define DMD_PRODUCT_DSCDM                10          /* DSCDM drive*/
#define DMD_PRODUCT_DSCDU                11          /* DSCDU drive*/
#define DMD_PRODUCT_GP_MODULE		 15	     /* GP_MODULE General purpose module */
#define DMD_PRODUCT_DSMAX                16          /* DSMAX axis controller */
#define DMD_PRODUCT_DSMAX2               17          /* DSMAX2 axis controller */
#define DMD_PRODUCT_DSMAX3               18          /* DSMAX3 axis controller */

#endif /* DMD_OO_API */


/*
 * extension card products - c
 */
#ifndef DMD_OO_API
#define DMD_X_PRODUCT_DSOSIO             1           /* DSOSIO super i/o */
#define DMD_X_PRODUCT_DSO001             2           /* DSO001 power i/o */
#define DMD_X_PRODUCT_DSOLVD             3           /* DSOLVD LVDT adapter */
#define DMD_X_PRODUCT_DSOMAC             4           /* DSOMAC MACRO bus */
#define DMD_X_PRODUCT_DSOTEB             5           /* DSOTEB (Turbo ETEL-BUS) */
#define DMD_X_PRODUCT_DSO003             6           /* DSO003 */
#define DMD_X_PRODUCT_DSOHIO             7           /* DSOHIO hyper i/o */
#define DMD_X_PRODUCT_DSOCAN_CNE         16          /* DSOCAN w/CANetel protocol */
#define DMD_X_PRODUCT_DSOCAN_CNW         17          /* DSOCAN w/Wuilfer protocol */
#define DMD_X_PRODUCT_DSOSER             24          /* DSOSER SERCOS bus */
#define DMD_X_PRODUCT_DSOPRO             32          /* DSOPRO PROFIBUS*/
#define DMD_X_PRODUCT_DSOSER2            25          /* DSOSER2 SERCOS bus */

#endif /* DMD_OO_API */


/*
 * regeneration modes - c
 */
#ifndef DMD_OO_API
#define DMD_REGEN_OFF                    0           /* always off */
#define DMD_REGEN_LIMITED                2           /* on for max 10s */
#define DMD_REGEN_ON                     3           /* always on */

#endif /* DMD_OO_API */


/*
 * source type - c
 */
#ifndef DMD_OO_API
#define DMD_TYP_NONE                     0           /**< no type */
#define DMD_TYP_IMMEDIATE                0           /**< disabled or immediate value */
#define DMD_TYP_USER                     1           /**< user registers */
#define DMD_TYP_PPK                      2           /**< drive parameters */
#define DMD_TYP_MONITOR                  3           /**< monitoring registers */
#define DMD_TYP_SEQUENCE                 5           /**< sequence buffer */
#define DMD_TYP_TRACE                    6           /**< trace buffer */
#define DMD_TYP_ADDRESS                  7           /**< address value */
#define DMD_TYP_LKT                      8           /**< movement lookup tables */
#define DMD_TYP_TRIGGER                  9           /**< triggers buffer */
#define DMD_TYP_REALTIME                 10          /**< realtime buffer */
#define DMD_TYP_HALL_LKT                 11          /**< hall lookup tables (deprecated)*/
#define DMD_TYP_Y		                 11          /**< Y type variables */
#define DMD_TYP_FLOAT                    12          /**< float register */

#endif /* DMD_OO_API */


/*
 * status drive 1 - c
 */
#ifndef DMD_OO_API
#define DMD_SW1_ERROR_OTHER_AXIS         LONG_MIN    /* other axis error */
#define DMD_SW1_ERROR_BYTE               -16777216   /* error byte */
#define DMD_SW1_POWER_ON                 1           /* power on */
#define DMD_SW1_INIT_DONE                2           /* initialization done */
#define DMD_SW1_HOMING_DONE              4           /* indexation done */
#define DMD_SW1_PRESENT                  8           /* present */
#define DMD_SW1_MOVING                   16          /* moving */
#define DMD_SW1_IN_WINDOW                32          /* in window */
#define DMD_SW1_MASTER                   64          /* EB master mode */
#define DMD_SW1_WAITING                  128         /* driver is waiting */
#define DMD_SW1_EXEC_SEQ                 256         /* sequence execution */
#define DMD_SW1_EDIT_SEQ                 512         /* sequence edition */
#define DMD_SW1_ERROR_ANY                1024        /* global error */
#define DMD_SW1_TRACE_BUSY               2048        /* trace busy */
#define DMD_SW1_BRIDGE                   4096        /* EB bridge mode */
#define DMD_SW1_HOMING                   8192        /* homing */
#define DMD_SW1_EBL_TO_EB                16384       /* EBL to EB pass trough */
#define DMD_SW1_SPY                      32768       /* EB spy mode */
#define DMD_SW1_WARNING_I2T              65536       /* i2t warning */
#define DMD_SW1_WARNING_TEMP             131072      /* over temperature warning */
#define DMD_SW1_WARNING_ENCODER          1048576     /* encoder warning */
#define DMD_SW1_WARNING_TRACKING         2097152     /* tracking warning */
#define DMD_SW1_WARNING_BYTE             16711680    /* warning byte */
#define DMD_SW1_ERROR_CURRENT            16777216    /* current error */
#define DMD_SW1_ERROR_CONTROLLER         33554432    /* controller error */
#define DMD_SW1_ERROR_ETB_COMM           67108864    /* EB communication error */
#define DMD_SW1_ERROR_TRAJECTORY         134217728   /* trajectory error */
#define DMD_SW1_ERROR_EBL_COMM           268435456   /* EBL communication error */

#endif /* DMD_OO_API */


/*
 * status drive 2 - c
 */
#ifndef DMD_OO_API
#define DMD_SW2_SEQ_ERROR                1           /* sequence error label pending */
#define DMD_SW2_SEQ_WARNING              2           /* sequence warning label pending */
#define DMD_SW2_BP_WAITING               16          /* break point waiting */
#define DMD_SW2_USER_0                   256         /* user bit 0 */
#define DMD_SW2_USER_1                   512         /* user bit 1 */
#define DMD_SW2_USER_2                   1024        /* user bit 2 */
#define DMD_SW2_USER_3                   2048        /* user bit 3 */
#define DMD_SW2_USER_4                   4096        /* user bit 4 */
#define DMD_SW2_USER_5                   8192        /* user bit 5 */
#define DMD_SW2_USER_6                   16384       /* user bit 6 */
#define DMD_SW2_USER_7                   32768       /* user bit 7 */
#define DMD_SW2_USER_BYTE                65280       /* user mask */

#endif /* DMD_OO_API */


/*
 * current loop adc resolution - c
 */
#ifndef DMD_OO_API
#define DMD_CUR_ADC_BITS_12              0           /* 12 bits */
#define DMD_CUR_ADC_BITS_14              1           /* 14 bits */

#endif /* DMD_OO_API */


/*
 * current LKT mode - c
 */
#ifndef DMD_OO_API
#define DMD_LKT_MODE_FINE_ADJUST         1           /* fine phase adjustment */
#define DMD_LKT_MODE_ROLLOVER            2           /* rollover counter */

#endif /* DMD_OO_API */


/*
 * monitoring register number - c
 */
#ifndef DMD_OO_API
#define DMD_MON_DEST_X_AOUT_1            173         /* extended analog output 1 */
#define DMD_MON_DEST_X_AOUT_2            174         /* extended analog output 2 */
#define DMD_MON_DEST_AOUT_1              175         /* analog output 1 */

#endif /* DMD_OO_API */


/*
 * flash operations - c
 */
#ifndef DMD_OO_API
#define DMD_FLASH_ALL                    0           /* all */
#define DMD_FLASH_SEQ_LKT                1           /* sequence and user LKT */
#define DMD_FLASH_OTHER_PARAMS           2           /* other parameters */

#endif /* DMD_OO_API */


/*
 * master modes - c
 */
#ifndef DMD_OO_API
#define DMD_MASTER_EXIT                  0           /* exit master mode */
#define DMD_MASTER_MASTER                1           /* enter master mode */
#define DMD_MASTER_BRIDGE                2           /* enter bridge mode */
#define DMD_MASTER_MASTER_AR             3           /* enter master mode w/auto-recovery */
#define DMD_MASTER_BRIDGE_AR             4           /* enter bridge mode w/auto-recovery */
#define DMD_MASTER_SPY                   255         /* enter spy mode */

#endif /* DMD_OO_API */


/*
 * automatic operations - c
 */
#ifndef DMD_OO_API
#define DMD_AUTO_CURRENT_LOOP            1           /* tune current loop */
#define DMD_AUTO_PHASE_CORRECTION        2           /* set motor phase correction */
#define DMD_AUTO_PHASE_ADJUSTMENT        8           /* tune fine phase adjustment */
#define DMD_AUTO_POSITION_LOOP           16          /* tune regulator parameters */

#endif /* DMD_OO_API */


/*
 * breakpoint commands - c
 */
#ifndef DMD_OO_API
#define DMD_BREAKPOINT_SET               1           /* set breakpoint */
#define DMD_BREAKPOINT_CLEAR             2           /* clear breakpoint */
#define DMD_BREAKPOINT_SET_ALL           3           /* set all breakpoints */
#define DMD_BREAKPOINT_CLEAR_ALL         4           /* clear all breakpoints */
#define DMD_BREAKPOINT_GLOBAL            5           /* set global breakpoint */

#endif /* DMD_OO_API */


/*
 * continue commands - c
 */
#ifndef DMD_OO_API
#define DMD_CONTINUE_CLEAR               0           /* clear breakpoint counter */
#define DMD_CONTINUE_STEP                1           /* step after breakpoint */

#endif /* DMD_OO_API */


/*
 * download options - c
 */
#ifndef DMD_OO_API
#define DMD_DOWNLOAD_PASS_THROUGH        170         /* enter EBL/EB pass trough mode */
#define DMD_DOWNLOAD_DIRECT              255         /* enter download mode */

#endif /* DMD_OO_API */


/*
 * reboot option - c
 */
#ifndef DMD_OO_API
#define DMD_SHUTDOWN_MAGIC               255         /* magic number */

#endif /* DMD_OO_API */


/*
 * setpoint buffer mask - c
 */
#ifndef DMD_OO_API
#define DMD_SETPOINT_TARGET_POSITION     1           /* target position */
#define DMD_SETPOINT_PROFILE_VELOCITY    2           /* profile velocity */
#define DMD_SETPOINT_PROFILE_ACCELERATIO 4           /* profile acceleration */
#define DMD_SETPOINT_JERK_FILTER_TIME    8           /* jerk filter time */
#define DMD_SETPOINT_PROFILE_DECELERATIO 16          /* profile deceleration */
#define DMD_SETPOINT_END_VELOCITY        32          /* end velocity */
#define DMD_SETPOINT_PROFILE_TYPE        64          /* profile type */
#define DMD_SETPOINT_MVT_LKT_NUMBER      128         /* lookup table number */
#define DMD_SETPOINT_MVT_LKT_TIME        256         /* lookup table time */
#define DMD_SETPOINT_MVT_LKT_AMPLITUDE   512         /* movement lookup table amplitude */
#define DMD_SETPOINT_MVT_DIRECTION       1024        /* movement direction */

#endif /* DMD_OO_API */


/*
 * trace trigger mode - c
 */
#ifndef DMD_OO_API
#define DMD_TRACE_TRIG_NONE              0           /* no trigger */
#define DMD_TRACE_TRIG_MVT_START         1           /* start of movement */
#define DMD_TRACE_TRIG_MVT_END           2           /* end of movement */
#define DMD_TRACE_TRIG_POSITION          3           /* specified position */
#define DMD_TRACE_TRIG_VALUE_1           4           /* value on first channel */

#endif /* DMD_OO_API */


/*
 * fast interrupt time - c
 */
#ifndef DMD_OO_API
#define DMD_FAST_INT_SYNCHRO             4           /* PWM synchronization */
#define DMD_FAST_INT_U_166               0           /* 166 us */
#define DMD_FAST_INT_U_125               1           /* 125 us */
#define DMD_FAST_INT_U_83                2           /* 83 us */

#endif /* DMD_OO_API */


/*
 * rotary movement direction - c
 */
#ifndef DMD_OO_API
#define DMD_MVT_DIR_POSITIVE             0           /* positive movement */
#define DMD_MVT_DIR_NEGATIVE             1           /* negative movement */
#define DMD_MVT_DIR_SHORTEST             2           /* shortest movement */

#endif /* DMD_OO_API */


/*
 * concatenated mode - c
 */
#ifndef DMD_OO_API
#define DMD_CONCAT_MODE_DISABLED         0           /* concatened movement disabled */
#define DMD_CONCAT_MODE_ENABLED          1           /* concatened movement enabled */
#define DMD_CONCAT_MODE_LKT_ONLY         2           /* concatened movement enabled for LKT */

#endif /* DMD_OO_API */


/*
 * LKT selection mode - c
 */
#ifndef DMD_OO_API
#define DMD_X45_X0                       0           /* the start and target position of the LKT is not the same */
#define DMD_X45_X1                       1           /* the start and target position of the LKT is the same */

#endif /* DMD_OO_API */


/*
 * fuse status - c
 */
#ifndef DMD_OO_API
#define DMD_FUSE_STAT_F3_FUSE            1           /* fuse F3 dead */
#define DMD_FUSE_STAT_F7_FUSE            2           /* fuse F7 dead */

#endif /* DMD_OO_API */


/*
 * SLS selection mode - c
 */
#ifndef DMD_OO_API
#define DMD_SLS_MODE_NEGATIVE_MVT        1           /* begin by negative movement */
#define DMD_SLS_MODE_MECHANICAL          0           /* mechanical end stop */
#define DMD_SLS_MODE_LIMIT_SW            2           /* limit switch */

#endif /* DMD_OO_API */


/*
 * profile buffer - c
 */
#ifndef DMD_OO_API
#define DMD_PROFILE_BUF_IMMEDIATE        0           /* immediate */
#define DMD_PROFILE_BUF_BUFFER_1         1           /* buffer 1 */
#define DMD_PROFILE_BUF_BUFFER_2         2           /* buffer 2 */
#define DMD_PROFILE_BUF_BUFFER_3         3           /* buffer 3 */

#endif /* DMD_OO_API */


/*
 * monitor channel - c
 */
#ifndef DMD_OO_API
#define DMD_MON_CHANNEL_0                0           /* channel 0 */
#define DMD_MON_CHANNEL_1                1           /* channel 1 */

#endif /* DMD_OO_API */


/*
 * sequence buffer subindex - c
 */
#ifndef DMD_OO_API
#define DMD_SEQ_HEADER                   0           /* header */
#define DMD_SEQ_PARAMETER_1              1           /* parameter 1 */
#define DMD_SEQ_PARAMETER_2              2           /* parameter 2 */

#endif /* DMD_OO_API */


/*
 * realtime table - c
 */
#ifndef DMD_OO_API
#define DMD_REALTIME_HEADER              0           /* header */
#define DMD_REALTIME_PARAMETER_1         1           /* parameter 1 */
#define DMD_REALTIME_PARAMETER_2         2           /* parameter 2 */
#define DMD_REALTIME_PARAMETER_3         3           /* parameter 3 */

#endif /* DMD_OO_API */


/*
 * realtime header - c
 */
#ifndef DMD_OO_API
#define DMD_RT_HEADER_STATUS_MASK        -16777216   /* status mask */
#define DMD_RT_HEADER_TYPE_MASK          255         /* type mask */
#define DMD_RT_HEADER_LABEL_MASK         65280       /* label mask */
#define DMD_RT_HEADER_CLEAR_WAIT_MODE    65536       /* clear wait mode */
#define DMD_RT_HEADER_MODE_MASK          16711680    /* mode mask */
#define DMD_RT_HEADER_VALID_STATUS       16777216    /* valid status */
#define DMD_RT_HEADER_ACTIVE_STATUS      33554432    /* active status */
#define DMD_RT_HEADER_ENABLE_STATUS      67108864    /* enable status */
#define DMD_RT_HEADER_WAITING_CMD_STATUS 134217728   /* waiting command status */
#define DMD_RT_HEADER_NO_OPERATION       0           /* no operation */
#define DMD_RT_HEADER_BIT_COPY           2           /* bit copy */
#define DMD_RT_HEADER_BIT_TEST           3           /* bit test */
#define DMD_RT_HEADER_MASK_TEST          4           /* mask test */
#define DMD_RT_HEADER_REGISTER_TEST      20          /* register test */
#define DMD_RT_HEADER_REGISTER_COMPARE   21          /* register compare */
#define DMD_RT_HEADER_SIMPLE_CLOCK       40          /* simple clock */

#endif /* DMD_OO_API */


/*
 * trigger table - c
 */
#ifndef DMD_OO_API
#define DMD_TRIGGER_HEADER               0           /* header */
#define DMD_TRIGGER_OUT_MASK             1           /* output mask */
#define DMD_TRIGGER_SW_MASK              2           /* status mask */
#define DMD_TRIGGER_POSITION             3           /* position */

#endif /* DMD_OO_API */


/*
 * trigger header - c
 */
#ifndef DMD_OO_API
#define DMD_TRIG_HEADER_TYPE_MASK        255         /* trigger type */
#define DMD_TRIG_HEADER_ACTION_MASK      16711680    /* trigger action */
#define DMD_TRIG_HEADER_NO_OPERATION     0           /* no operation */
#define DMD_TRIG_HEADER_DISABLED         128         /* disabled */
#define DMD_TRIG_HEADER_POSITIVE         129         /* positive */
#define DMD_TRIG_HEADER_NEGATIVE         130         /* negative */
#define DMD_TRIG_HEADER_BIDIRECTIONAL    131         /* bidirectional */
#define DMD_TRIG_HEADER_SET_OUT_SW       65536       /* set output and user sw */

#endif /* DMD_OO_API */


/*
 * trace buffer - c
 */
#ifndef DMD_OO_API
#define DMD_TRACE_BUFFER_0               0           /* buffer 0 */
#define DMD_TRACE_BUFFER_1               1           /* buffer 1 */

#endif /* DMD_OO_API */


/*
 * hall lookup table - c
 */
#ifndef DMD_OO_API
#define DMD_HALL_LKT_LKT_0               0           /* lookup table 0 */
#define DMD_HALL_LKT_LKT_1               1           /* lookup table 1 */
#define DMD_HALL_LKT_LKT_2               2           /* lookup table 2 */
#define DMD_HALL_LKT_LKT_3               3           /* lookup table 3 */
#define DMD_HALL_LKT_LKT_4               4           /* lookup table 4 */
#define DMD_HALL_LKT_LKT_5               5           /* lookup table 5 */
#define DMD_HALL_LKT_LKT_6               6           /* lookup table 6 */
#define DMD_HALL_LKT_LKT_7               7           /* lookup table 7 */

#endif /* DMD_OO_API */


/*
 * interrupt edge - c
 */
#ifndef DMD_OO_API
#define DMD_INT_EDGE_POSITIVE            0           /* positive */
#define DMD_INT_EDGE_NEGATIVE            1           /* negative */

#endif /* DMD_OO_API */


/*
 * test mode - c
 */
#ifndef DMD_OO_API

#endif /* DMD_OO_API */


/*
 * drive (record 20h) command numbers
 */ 
#ifndef DMD_OO_API
#define DMD_CMD_ACKNOWLEDGE_INTERRUPT            118         /* acknowledge interrupt */
#define DMD_CMD_ADD_ACC                          161         /* Adds accumulator */
#define DMD_CMD_ADD_REGISTER                     91          /* Adds register */
#define DMD_CMD_AND_ACC                          165         /* And accumulator */
#define DMD_CMD_AND_NOT_ACC                      167         /* And not accumulator */
#define DMD_CMD_AND_NOT_REGISTER                 97          /* And not register */
#define DMD_CMD_AND_REGISTER                     95          /* And register */
#define DMD_CMD_AUTO_CONFIG_CL                   150         /* Auto config current loop */
#define DMD_CMD_CALL_SUBROUTINE                  68          /* Calls subroutine */
#define DMD_CMD_CAN_COMMAND_1                    250         /* can command 1 */
#define DMD_CMD_CAN_COMMAND_2                    251         /* can command 2 */
#define DMD_CMD_CHANGE_AXIS                      109         /* Changes axis */
#define DMD_CMD_CHANGE_POWER                     124         /* Changes power */
#define DMD_CMD_CLEAR_CALL_STACK                 34          /* Clears call stack */
#define DMD_CMD_CLEAR_PENDING_ERROR              50          /* Clear pending error */
#define DMD_CMD_CLEAR_PENDING_WARNING            51          /* clear pending warning */
#define DMD_CMD_CLEAR_TRIGGER_TABLE              107         /* Clears trigger table */
#define DMD_CMD_CLEAR_USER_VAR                   17          /* Clears user variable */
#define DMD_CMD_CONV_REGISTER                    122         /* Converts between int and float */
#define DMD_CMD_DEFINE_EMPTY_TRIGGER             108         /* define empty trigger */
#define DMD_CMD_DEFINE_LABEL                     27          /* Defines a label */
#define DMD_CMD_DEFINE_NEG_TRIGGER               106         /* define negative trigger */
#define DMD_CMD_DEFINE_POS_TRIGGER               105         /* define positive trigger */
#define DMD_CMD_DIVIDE_ACC                       163         /* Divides accumulator */
#define DMD_CMD_DIVIDE_REGISTER                  94          /* Divides register */
#define DMD_CMD_DRIVE_NEW                        78          /* Drive new */
#define DMD_CMD_DRIVE_RESTORE                    49          /* Drive restore */
#define DMD_CMD_DRIVE_SAVE                       48          /* Drive save */
#define DMD_CMD_EDIT_SEQUENCE                    62          /* Edit sequence */
#define DMD_CMD_ENABLE_RTI                       183         /* realtime enable when seq_on 0 */
#define DMD_CMD_ENTER_DOWNLOAD                   42          /* Enter download mode */
#define DMD_CMD_EXIT_SEQUENCE                    63          /* Exit sequence */
#define DMD_CMD_FLOAT_COS                        223         /* Executes command cos */
#define DMD_CMD_FLOAT_FRAC_PART                  225         /* Executes command frac_part */
#define DMD_CMD_FLOAT_INT_PART                   226         /* Executes command int_part */
#define DMD_CMD_FLOAT_INV                        221         /* Executes command inv */
#define DMD_CMD_FLOAT_SIGN                       224         /* Executes command sign */
#define DMD_CMD_FLOAT_SIN                        222         /* Executes command sin */
#define DMD_CMD_FLOAT_SQRT                       220         /* Executes command sqrt */
#define DMD_CMD_FLOAT_TEST                       227         /* Executes command test */
#define DMD_CMD_HARDWARE_RESET                   600         /* hardware reset */
#define DMD_CMD_HOMING_START                     45          /* Homing start */
#define DMD_CMD_HOMING_SYNCHRONISED              41          /* Synchronized homing */
#define DMD_CMD_IF_EQUAL                         151         /* Jumps if par1 == XAC */
#define DMD_CMD_IF_GREATER                       154         /* Jumps if par1 > XAC */
#define DMD_CMD_IF_GREATER_OR_EQUAL              156         /* Jumps if par1 >= XAC */
#define DMD_CMD_IF_LOWER                         153         /* Jumps if par1 < XAC */
#define DMD_CMD_IF_LOWER_OR_EQUAL                155         /* Jumps if par1 <= XAC */
#define DMD_CMD_IF_NOT_EQUAL                     152         /* Jumps if par1 != XAC */
#define DMD_CMD_INI_START                        44          /* Initialization start */
#define DMD_CMD_INPUT_START_MVT                  33          /* Starts mvt on input */
#define DMD_CMD_INVERT_REGISTER                  174         /* Inverts register */
#define DMD_CMD_IPOL_BEGIN                       553         /* enter to interpolated mode */
#define DMD_CMD_IPOL_BEGIN_CONCATENATION         1030        /* start the concatenation */
#define DMD_CMD_IPOL_CIRCLE_CCW_C2D              1041        /* add circular segment to trajectory */
#define DMD_CMD_IPOL_CIRCLE_CCW_R2D              1027        /* add circular segment to trajectory */
#define DMD_CMD_IPOL_CIRCLE_CW_C2D               1040        /* add circular segment to trajectory */
#define DMD_CMD_IPOL_CIRCLE_CW_R2D               1026        /* add circular segment to trajectory */
#define DMD_CMD_IPOL_CONTINUE                    654         /* restart interpolation after a quick stop */
#define DMD_CMD_IPOL_END                         554         /* leave the interpolated mode */
#define DMD_CMD_IPOL_END_CONCATENATION           1031        /* stop the concatenation */
#define DMD_CMD_IPOL_LINE                        1025        /* add linear segment to trajectory */
#define DMD_CMD_IPOL_LKT                         1032        /* add lkt segment to trajectory */
#define DMD_CMD_IPOL_LOCK                        1044        /* lock the trajectory execution */
#define DMD_CMD_IPOL_MARK                        1039        /* put  mark in the trajectory */
#define DMD_CMD_IPOL_PUSH                        1279        /* push parameters for ipol commands */
#define DMD_CMD_IPOL_PVT                         1028        /* add pvt segment to trajectory */
#define DMD_CMD_IPOL_PVT_UPDATE                  662         /* Updates registers for PVT trajectory */
#define DMD_CMD_IPOL_RESET                       652         /* reset interpolation */
#define DMD_CMD_IPOL_SET                         552         /* set the interpolation axis */
#define DMD_CMD_IPOL_STOP_EMCY                   656         /* stop interpolation emergency */
#define DMD_CMD_IPOL_STOP_SMOOTH                 653         /* stop interpolation smooth */
#define DMD_CMD_IPOL_TAN_ACCELERATION            1036        /* add acceleration modification to trajectory */
#define DMD_CMD_IPOL_TAN_DECELERATION            1037        /* add deceleration modification to trajectory */
#define DMD_CMD_IPOL_TAN_JERK_TIME               1038        /* add jerk time modification to trajectory */
#define DMD_CMD_IPOL_TAN_VELOCITY                1035        /* add speed modification to trajectory */
#define DMD_CMD_IPOL_UNLOCK                      655         /* unlock the trajectory execution */
#define DMD_CMD_IPOL_WAIT_TIME                   1029        /* wait before continue the trajectory */
#define DMD_CMD_JUMP_BIT_CLEAR                   37          /* Jump bit clear */
#define DMD_CMD_JUMP_BIT_SET                     36          /* Jump bit set */
#define DMD_CMD_JUMP_LABEL                       26          /* Jumps to label */
#define DMD_CMD_MASTER_MODE                      143         /* master mode */
#define DMD_CMD_MULTIPLY_ACC                     162         /* Multiplies accumulator */
#define DMD_CMD_MULTIPLY_REGISTER                93          /* Multiplies register */
#define DMD_CMD_OR_ACC                           164         /* Or accumulator */
#define DMD_CMD_OR_NOT_ACC                       166         /* Or not accumulator */
#define DMD_CMD_OR_NOT_REGISTER                  98          /* Or not register */
#define DMD_CMD_OR_REGISTER                      96          /* Or register */
#define DMD_CMD_PURGE                            190         /* purge */
#define DMD_CMD_PUSH                             255         /* Push parameters */
#define DMD_CMD_REALTIME_DISABLE                 176         /* Real-time disable */
#define DMD_CMD_REALTIME_ENABLE                  175         /* Real-time enable */
#define DMD_CMD_RESET_BUS                        87          /* reset bus */
#define DMD_CMD_RESET_DRIVE                      88          /* Resets drive */
#define DMD_CMD_RESET_ERROR                      79          /* Resets error */
#define DMD_CMD_RESET_TRIGGER                    104         /* reset trigger */
#define DMD_CMD_SEARCH_LIMIT_STROKE              46          /* Searches limit stroke */
#define DMD_CMD_SET_DEBUG_TIMEOUT                180         /* set debug timeout */
#define DMD_CMD_SET_GROUP_MASK                   40          /* set group mask */
#define DMD_CMD_SET_GUARD_TIMEOUT                181         /* set guard timeout */
#define DMD_CMD_SET_REGISTER                     123         /* Sets register */
#define DMD_CMD_SET_USER_POSITION                22          /* Sets user position */
#define DMD_CMD_SHIFT_LEFT_ACC                   169         /* Shift left accumulator */
#define DMD_CMD_SHIFT_LEFT_REGISTER              173         /* Shift left register */
#define DMD_CMD_SHIFT_RIGHT_ACC                  168         /* Shift right accumulator */
#define DMD_CMD_SHIFT_RIGHT_REGISTER             172         /* Shift right register */
#define DMD_CMD_START_MVT                        25          /* Starts movement */
#define DMD_CMD_STEP_ABSOLUTE                    129         /* Absolute step */
#define DMD_CMD_STEP_NEGATIVE                    115         /* Negative step */
#define DMD_CMD_STEP_POSITIVE                    114         /* Positive step */
#define DMD_CMD_STOP_MOTOR_EMCY                  18          /* Emergency stop */
#define DMD_CMD_STOP_MOTOR_SMOOTH                70          /* Stops motor smoothly */
#define DMD_CMD_STOP_SEQ_MOTOR_EMCY              120         /* Stops seq motor emergency */
#define DMD_CMD_STOP_SEQ_MOTOR_SMOOTH            121         /* Stops seq motor smooth */
#define DMD_CMD_STOP_SEQ_POWER_OFF               119         /* Stops seq power off */
#define DMD_CMD_STOP_SEQUENCE                    0           /* Stops sequence */
#define DMD_CMD_SUBROUTINE_RETURN                69          /* Subroutine return */
#define DMD_CMD_SUBSTRACT_ACC                    160         /* Substracts accumulator */
#define DMD_CMD_SUBSTRACT_REGISTER               92          /* Substracts register */
#define DMD_CMD_SYNCRO_START_MVT                 35          /* syncro start mvt */
#define DMD_CMD_WAIT_AXIS_BUSY                   13          /* Waits for end of axis busy */
#define DMD_CMD_WAIT_BIT_CLEAR                   54          /* Wait bit clear */
#define DMD_CMD_WAIT_BIT_SET                     55          /* Wait bit set */
#define DMD_CMD_WAIT_BUSY                        148         /* wait busy */
#define DMD_CMD_WAIT_GREATER                     53          /* Wait greater */
#define DMD_CMD_WAIT_IN_WINDOW                   11          /* Waits in window */
#define DMD_CMD_WAIT_LOWER                       52          /* Wait lower */
#define DMD_CMD_WAIT_MARK                        513         /* wait until the movement reach a mark */
#define DMD_CMD_WAIT_MOVEMENT                    8           /* Waits for movement */
#define DMD_CMD_WAIT_POSITION                    9           /* Waits for position */
#define DMD_CMD_WAIT_TH_SPEED                    12          /* wait theoretical speed */
#define DMD_CMD_WAIT_TIME                        10          /* Waits for time */
#define DMD_CMD_WAITING_REC_04                   254         /* waiting record 04 */
#define DMD_CMD_WAITING_REC_12                   252         /* waiting record 12 */
#define DMD_CMD_WAITING_REC_14                   253         /* waiting record 14 */

#endif /* DMD_OO_API */

/*
 * drive parameters numbers
 */ 
#ifndef DMD_OO_API
#define DMD_PPK_ANALOG_OUTPUT            175         /* analog output */
#define DMD_PPK_ANR_MAX_POSITION         219         /* anr maximum position */
#define DMD_PPK_ANR_MAX_VOLTAGE          218         /* anr maximum voltage */
#define DMD_PPK_ANR_MIN_POSITION         217         /* anr minimum position */
#define DMD_PPK_ANR_MIN_VOLTAGE          216         /* anr minimum voltage */
#define DMD_PPK_APR_INPUT_FILTER         24          /* apr input filter */
#define DMD_PPK_BRAKE_DECELERATION       206         /* Brake deceleration */
#define DMD_PPK_CAME_VALUE               205         /* Came value */
#define DMD_PPK_CL_ADC_BITS              49          /* current loop adc bits */
#define DMD_PPK_CL_CURRENT_LIMIT         83          /* Current loop overcurrent limit */
#define DMD_PPK_CL_I2T_CURRENT_LIMIT     84          /* Curr. loop i2t rms current limit */
#define DMD_PPK_CL_I2T_TIME_LIMIT        85          /* Current loop i2t time limit */
#define DMD_PPK_CL_INPUT_FILTER          10          /* current loop input filter */
#define DMD_PPK_CL_INTEGRATOR_GAIN       81          /* Current loop integrator gain */
#define DMD_PPK_CL_OUTPUT_FILTER         82          /* Current loop output filter */
#define DMD_PPK_CL_PHASE_ADVANCE_FACTOR  23          /* phase advance factor */
#define DMD_PPK_CL_PHASE_ADVANCE_SHIFT   25          /* current loop phase advance shift */
#define DMD_PPK_CL_PROPORTIONAL_GAIN     80          /* Current loop proportional gain */
#define DMD_PPK_CL_REGEN_MODE            86          /* current loop regeneration mode */
#define DMD_PPK_CONCATENATED_MVT         201         /* Concatenated movement selection */
#define DMD_PPK_CTRL_GAIN                224         /* Control source gain */
#define DMD_PPK_CTRL_OFFSET              223         /* Control source offset */
#define DMD_PPK_CTRL_SHIFT_FACTOR        222         /* Control source shift factor */
#define DMD_PPK_CTRL_SOURCE_INDEX        221         /* Control source index */
#define DMD_PPK_CTRL_SOURCE_TYPE         220         /* Control source type */
#define DMD_PPK_CUSTOM_SETTINGS_VERSION  245         /* customer settings version */
#define DMD_PPK_DIGITAL_OUTPUT           171         /* Digital outputs */
#define DMD_PPK_DISPLAY_MODE             66          /* Display mode */
#define DMD_PPK_DRIVE_CONTROL_MODE       61          /* Reference mode */
#define DMD_PPK_DRIVE_FAST_SEQ_MODE      63          /* drive fast execution seq.mode */
#define DMD_PPK_DRIVE_FUSE_CHECKING      140         /* drive fuse checking */
#define DMD_PPK_DRIVE_NAME               244         /* Drive name */
#define DMD_PPK_DRIVE_PL_CYCLE_TIME      88          /* Int pos ctrl 0=166,1=125,2=83us */
#define DMD_PPK_DRIVE_SLS_MODE           145         /* Searches limit stroke (SLS) mode */
#define DMD_PPK_DRIVE_SP_FACTOR          64          /* drive SP calculator factor */
#define DMD_PPK_EBL_BAUDRATE             195         /* etel-bus-lite baudrate */
#define DMD_PPK_EBL_INTRA_FRAME_TIMEOUT  196         /* EBL intra-frame timeout */
#define DMD_PPK_ENABLE_INPUT_MODE        33          /* Enables input mode */
#define DMD_PPK_ENCODER_HALL_PHASE_ADJ   86          /* Digital Hall sensor phase adjustment */
#define DMD_PPK_ENCODER_INDEX_DISTANCE   75          /* Distance between two indexes */
#define DMD_PPK_ENCODER_INVERSION        68          /* Encoder inversion */
#define DMD_PPK_ENCODER_IPOL_SHIFT       77          /* Encoder interp. shift value */
#define DMD_PPK_ENCODER_MOTOR_RATIO      51          /* encoder motor ratio */
#define DMD_PPK_ENCODER_MUL_SHIFT        78          /* encoder multip.shift value */
#define DMD_PPK_ENCODER_PERIOD           241         /* Encoder period */
#define DMD_PPK_ENCODER_PHASE_1_FACTOR   72          /* Analog encoder sine factor */
#define DMD_PPK_ENCODER_PHASE_1_OFFSET   70          /* Analog encoder sine offset */
#define DMD_PPK_ENCODER_PHASE_2_FACTOR   73          /* Analog encoder cosine factor */
#define DMD_PPK_ENCODER_PHASE_2_OFFSET   71          /* Analog encoder cosine offset */
#define DMD_PPK_ENCODER_PHASE_3_FACTOR   76          /* encoder phase 3 factor */
#define DMD_PPK_ENCODER_PHASE_3_OFFSET   74          /* encoder phase 3 offset */
#define DMD_PPK_ENCODER_TURN_FACTOR      55          /* Encoder turn factor */
#define DMD_PPK_ENCODER_TYPE             79          /* Encoder type selection */
#define DMD_PPK_END_VELOCITY             215         /* end velocity */
#define DMD_PPK_FOLLOWING_ERROR_WINDOW   30          /* Tracking error limit */
#define DMD_PPK_GANTRY_TYPE              245         /* Gantry function */
#define DMD_PPK_HOME_OFFSET              45          /* Offset on absolute position */
#define DMD_PPK_HOMING_ACCELERATION      42          /* Homing acceleration */
#define DMD_PPK_HOMING_CURRENT_LIMIT     44          /* Homing force limit for mech. end stop detection */
#define DMD_PPK_HOMING_FINE_TUNING_MODE  52          /* Homing fine tuning mode */
#define DMD_PPK_HOMING_FINE_TUNING_VALUE 53          /* Homing fine tuning value */
#define DMD_PPK_HOMING_FIXED_MVT         46          /* Homing movement stroke */
#define DMD_PPK_HOMING_FOLLOWING_LIMIT   43          /* Homing track. limit for mech. end stop detection */
#define DMD_PPK_HOMING_INDEX_MVT         48          /* Mvt to go out of idx/home switch */
#define DMD_PPK_HOMING_METHOD            40          /* Homing mode */
#define DMD_PPK_HOMING_SWITCH_MVT        47          /* Mvt to go out of limit switch or mech. end stop */
#define DMD_PPK_HOMING_ZERO_SPEED        41          /* Homing speed */
#define DMD_PPK_INDIRECT_AXIS_NUMBER     197         /* indirect axis number */
#define DMD_PPK_INDIRECT_REGISTER_IDX    198         /* Indirect register index */
#define DMD_PPK_INDIRECT_REGISTER_SIDX   199         /* indirect register subindex */
#define DMD_PPK_INIT_CURRENT_RATE        95          /* initialisation current rate */
#define DMD_PPK_INIT_FINAL_PHASE         93          /* Initialization final phase */
#define DMD_PPK_INIT_INITIAL_PHASE       97          /* Initialization initial phase */
#define DMD_PPK_INIT_MAX_CURRENT         92          /* Init. constant current level */
#define DMD_PPK_INIT_MODE                90          /* Initialization mode */
#define DMD_PPK_INIT_PHASE_RATE          96          /* initialisation phase rate */
#define DMD_PPK_INIT_PULSE_LEVEL         91          /* Initialization pulse level */
#define DMD_PPK_INIT_TIME                94          /* Initialization time */
#define DMD_PPK_INIT_VOLTAGE_RATE        98          /* Initialization voltage rate */
#define DMD_PPK_INTERRUPT_MASK_1         180         /* interrupt mask 1 */
#define DMD_PPK_INTERRUPT_MASK_2         181         /* interrupt  mask 2 */
#define DMD_PPK_IO_ERROR_EVENT_MASK      37          /* DOUT mask error event */
#define DMD_PPK_IPOL_CAME_VALUE          717         /* Interpolation, came value */
#define DMD_PPK_IPOL_LKT_CYCLIC_MODE     710         /* LKT, cyclic mode */
#define DMD_PPK_IPOL_LKT_RELATIVE_MODE   711         /* LKT, relative mode */
#define DMD_PPK_IPOL_LKT_SPEED_RATIO     700         /* LKT, speed ratio of the pointer */
#define DMD_PPK_IPOL_VELOCITY_RATE       530         /* Interpolation, Speed rate */
#define DMD_PPK_JERK_FILTER_TIME         213         /* Jerk time */
#define DMD_PPK_MAX_ACCELERATION         29          /* maximum acceleration */
#define DMD_PPK_MAX_POSITION_RANGE_LIMIT 27          /* Maximum position range limit */
#define DMD_PPK_MAX_PROFILE_VELOCITY     28          /* maximum profile velocity */
#define DMD_PPK_MAX_SOFT_POSITION_LIMIT  35          /* Maximum software position limit */
#define DMD_PPK_MEASURE_DRIVE_CL_INT     234         /* Enables timing meas. for curr. int. */
#define DMD_PPK_MEASURE_DRIVE_PL_INT     235         /* Enables timing meas. for slow int. */
#define DMD_PPK_MEASURE_DRIVE_SP_INT     236         /* enable timing meas.for slow Int. */
#define DMD_PPK_MIN_POSITION_RANGE_LIMIT 26          /* minimum position range limit */
#define DMD_PPK_MIN_SOFT_POSITION_LIMIT  34          /* Minimum software position limit */
#define DMD_PPK_MON_DEST_INDEX           153         /* monitoring destination index */
#define DMD_PPK_MON_DEST_TYPE            152         /* monitoring destination type */
#define DMD_PPK_MON_GAIN                 155         /* monitoring gain */
#define DMD_PPK_MON_OFFSET               154         /* monitoring offset */
#define DMD_PPK_MON_SOURCE_INDEX         151         /* monitoring source index */
#define DMD_PPK_MON_SOURCE_TYPE          150         /* monitoring source type */
#define DMD_PPK_MOTOR_DIV_FACTOR         243         /* Motor division factor */
#define DMD_PPK_MOTOR_KT_FACTOR          239         /* Motor Kt factor */
#define DMD_PPK_MOTOR_MUL_FACTOR         242         /* Position multiplication factor */
#define DMD_PPK_MOTOR_PHASE_CORRECTION   56          /* Motor phase correction */
#define DMD_PPK_MOTOR_PHASE_NB           89          /* Motor phase number */
#define DMD_PPK_MOTOR_POLE_NB            54          /* Motor pole pair number */
#define DMD_PPK_MOTOR_TEMP_CHECKING      141         /* Enables motor time-out TEB error checking */
#define DMD_PPK_MOTOR_TYPE               240         /* Motor type */
#define DMD_PPK_MVT_DIRECTION            209         /* Rotary movement type selection */
#define DMD_PPK_MVT_LKT_AMPLITUDE        208         /* Max. stroke for LKT */
#define DMD_PPK_MVT_LKT_NUMBER           203         /* Look-up table number movement */
#define DMD_PPK_MVT_LKT_TIME             204         /* Movement look-up table time */
#define DMD_PPK_MVT_LKT_TYPE             207         /* LKT mode select */
#define DMD_PPK_PDR_STEP_VALUE           69          /* TTL encoder interp. shift value */
#define DMD_PPK_PL_ACC_FEEDFORWARD_GAIN  21          /* Pos. loop acc. feedforw. gain */
#define DMD_PPK_PL_ACC_FEEDFORWARD_GAIN_ 18          /* acc.feed forw. in pulse/dir mode */
#define DMD_PPK_PL_ANTI_WINDUP_GAIN      5           /* position loop anti-windup gain */
#define DMD_PPK_PL_FORCE_FEEDBACK_GAIN_1 3           /* pos.loop force feedback gain 1 */
#define DMD_PPK_PL_FORCE_FEEDBACK_GAIN_2 13          /* pos. loop force feedback gain 2 */
#define DMD_PPK_PL_INTEGRATOR_GAIN       4           /* position loop integrator gain */
#define DMD_PPK_PL_INTEGRATOR_LIMITATION 6           /* Pos. loop integrator limitation */
#define DMD_PPK_PL_INTEGRATOR_MODE       7           /* Position loop integrator mode */
#define DMD_PPK_PL_OUTPUT_FILTER         9           /* position loop output filter */
#define DMD_PPK_PL_PROPORTIONAL_GAIN     1           /* Position loop proportional gain */
#define DMD_PPK_PL_SPEED_FEEDBACK_GAIN   2           /* Pos. loop speed feedback gain */
#define DMD_PPK_PL_SPEED_FEEDFWD_GAIN    20          /* Pos. loop speed feedforw. gain */
#define DMD_PPK_PL_SPEED_FEEDFWD_GAIN_PD 17          /* speed feed forw.in pulse/dir mode */
#define DMD_PPK_PL_SPEED_FILTER          8           /* Position loop speed filter */
#define DMD_PPK_PL_SPEED_FILTER_2        12          /* speed filter 2 */
#define DMD_PPK_POSITION_WINDOW          39          /* Position range window */
#define DMD_PPK_POSITION_WINDOW_TIME     38          /* Position window time */
#define DMD_PPK_PROFILE_ACCELERATION     212         /* Absolute max. acc./deceleration */
#define DMD_PPK_PROFILE_DECELERATION     214         /* profile deceleration */
#define DMD_PPK_PROFILE_LIMIT_MODE       36          /* Enables position limit (K34, K35) */
#define DMD_PPK_PROFILE_MUL_SHIFT        50          /* Profile multiplication shift */
#define DMD_PPK_PROFILE_TYPE             202         /* Movement type */
#define DMD_PPK_PROFILE_VELOCITY         211         /* Absolute maximum speed */
#define DMD_PPK_REALTIME_ENABLED_GLOBAL  190         /* RTI global enable */
#define DMD_PPK_REALTIME_ENABLED_MASK    192         /* RTI enabled mask */
#define DMD_PPK_REALTIME_PENDING_MASK    193         /* RTI pending mask */
#define DMD_PPK_REALTIME_VALID_MASK      191         /* RTI valid mask */
#define DMD_PPK_SOFTWARE_CURRENT_LIMIT   60          /* Software force/torque limit */
#define DMD_PPK_SWITCH_LIMIT_MODE        32          /* Limit/home switch mode */
#define DMD_PPK_SYNCRO_INPUT_MASK        160         /* Syncro input mask */
#define DMD_PPK_SYNCRO_INPUT_VALUE       161         /* Syncro input value */
#define DMD_PPK_SYNCRO_OUTPUT_MASK       162         /* Syncro output mask */
#define DMD_PPK_SYNCRO_OUTPUT_VALUE      163         /* Syncro output value */
#define DMD_PPK_SYNCRO_START_TIMEOUT     164         /* Syncro time-out */
#define DMD_PPK_TARGET_POSITION          210         /* Target position */
#define DMD_PPK_TRIGGER_IO_MASK          185         /* Trigger digital output mask */
#define DMD_PPK_TRIGGER_IRQ_MASK         184         /* User status mask for trigger */
#define DMD_PPK_TRIGGER_MAP_OFFSET       186         /* Trigger mapping number */
#define DMD_PPK_TRIGGER_MAP_SIZE         187         /* Trigger mapping size */
#define DMD_PPK_TTL_SPECIAL_FILTER       11          /* ttl special filter */
#define DMD_PPK_UFAI_TEN_POWER           525         /* ufai ten power */
#define DMD_PPK_UFPI_MUL_FACTOR          522         /* ufpi multiplication factor */
#define DMD_PPK_UFPI_TEN_POWER           523         /* ufpi ten power */
#define DMD_PPK_UFSI_TEN_POWER           524         /* ufsi ten power */
#define DMD_PPK_UFTI_TEN_POWER           526         /* ufti ten power */
#define DMD_PPK_USER_STATUS              177         /* User status */
#define DMD_PPK_VELOCITY_ERROR_LIMIT     31          /* Velocity error limit */
#define DMD_PPK_X_ANALOG_GAIN            157         /* extension card analog gain */
#define DMD_PPK_X_ANALOG_OFFSET          156         /* extension card analog offset */
#define DMD_PPK_X_ANALOG_OUTPUT_1        173         /* extension card analog output 1 */
#define DMD_PPK_X_ANALOG_OUTPUT_2        174         /* extension card analog output 2 */
#define DMD_PPK_X_DIGITAL_OUTPUT         172         /* extension card digital outputs */

#endif /* DMD_OO_API */

/*
 * drive monitoring variables numbers
 */
#ifndef DMD_OO_API
#define DMD_MON_ACC_ACTUAL_VALUE         15          /* real acceleration */
#define DMD_MON_ACC_DEMAND_VALUE         14          /* Theoretical acceleration (dai) */
#define DMD_MON_ACK_DRIVE_STATUS_1       162         /* acknowledge drive status 1 */
#define DMD_MON_ACK_DRIVE_STATUS_2       163         /* acknowledge drive status 2 */
#define DMD_MON_ANALOG_INPUT             51          /* analog input */
#define DMD_MON_AXIS_NUMBER              87          /* Axis number */
#define DMD_MON_CAN_FEEDBACK_1           250         /* extension card feedback 1 */
#define DMD_MON_CAN_FEEDBACK_2           251         /* extension card feedback 2 */
#define DMD_MON_CL_ACTUAL_VALUE          31          /* real force */
#define DMD_MON_CL_CURRENT_PHASE_1       20          /* current loop current in phase 1 */
#define DMD_MON_CL_CURRENT_PHASE_2       21          /* current loop current in phase 2 */
#define DMD_MON_CL_CURRENT_PHASE_3       22          /* current loop current phase 3 */
#define DMD_MON_CL_DEMAND_VALUE          30          /* theoretical force */
#define DMD_MON_CL_I2T_VALUE             67          /* current loop i2t value */
#define DMD_MON_CL_LKT_PHASE_1           25          /* curr.loop lookup table phase 1 */
#define DMD_MON_CL_LKT_PHASE_2           26          /* curr.loop lookup table phase 2 */
#define DMD_MON_CL_LKT_PHASE_3           27          /* curr.loop lookup table phase 3 */
#define DMD_MON_DAISY_CHAIN_NUMBER       88          /* daisy chain number */
#define DMD_MON_DIGITAL_INPUT            50          /* Digital inputs value */
#define DMD_MON_DIGITAL_OUTPUT_ACTUAL    171         /* Real state of drive's DOUTs */
#define DMD_MON_DRIVE_CL_INT_ACTUAL_TIME 190         /* Act. time of process on curr. int. */
#define DMD_MON_DRIVE_CL_INT_MAX_TIME    192         /* Min. time of process on curr. int. */
#define DMD_MON_DRIVE_CL_INT_MIN_TIME    191         /* Max. time of process on curr. int. */
#define DMD_MON_DRIVE_CL_TIME_FACTOR     243         /* Drv curr. loop time factor (cti) */
#define DMD_MON_DRIVE_CONTROL_MODE_BF    19          /* driver control mode bit-field */
#define DMD_MON_DRIVE_DISPLAY            95          /* Display's string */
#define DMD_MON_DRIVE_FUSE_STATUS        140         /* drive fuse status */
#define DMD_MON_DRIVE_MASK_VALUE         93          /* drive mask value */
#define DMD_MON_DRIVE_MAX_CURRENT        82          /* Drive maximum current */
#define DMD_MON_DRIVE_PENDING_BPT        98          /* pending breakpoints */
#define DMD_MON_DRIVE_PL_INT_ACTUAL_TIME 193         /* Act. time of process on fast int. */
#define DMD_MON_DRIVE_PL_INT_MAX_TIME    195         /* Min. time of process on fast int. */
#define DMD_MON_DRIVE_PL_INT_MIN_TIME    194         /* Max. time of process on fast int. */
#define DMD_MON_DRIVE_PL_TIME_FACTOR     244         /* Drv fast int. time factor (fti) */
#define DMD_MON_DRIVE_QUARTZ_FREQUENCY   242         /* Drive quartz frequency [Hz] */
#define DMD_MON_DRIVE_SEQUENCE_LINE      96          /* Executed sequence's line */
#define DMD_MON_DRIVE_SEQUENCE_USAGE     97          /* drive sequence buffer usage */
#define DMD_MON_DRIVE_SP_INT_ACTUAL_TIME 196         /* Act. time of process on slow int. */
#define DMD_MON_DRIVE_SP_INT_MAX_TIME    198         /* Min. time of process on slow int. */
#define DMD_MON_DRIVE_SP_INT_MIN_TIME    197         /* Max. time of process on slow int. */
#define DMD_MON_DRIVE_SP_TIME_FACTOR     245         /* Drv SP calculator time factor */
#define DMD_MON_DRIVE_STATUS_1           60          /* Drive status 1 */
#define DMD_MON_DRIVE_STATUS_2           61          /* Drive status 2 */
#define DMD_MON_DRIVE_TEMPERATURE        90          /* drive temperature */
#define DMD_MON_EB_RUNNING               89          /* etel-bus running */
#define DMD_MON_ENCODER_1VPTP_VALUE      43          /* Analog encoder sine^2 + cosine^2 */
#define DMD_MON_ENCODER_COSINE_SIGNAL    41          /* Analog encoder cosine signal */
#define DMD_MON_ENCODER_HALL_1_SIGNAL    45          /* encoder hall analog signal 1 */
#define DMD_MON_ENCODER_HALL_2_SIGNAL    46          /* encoder hall analog signal 2 */
#define DMD_MON_ENCODER_HALL_3_SIGNAL    47          /* encoder hall analog signal 3 */
#define DMD_MON_ENCODER_HALL_DIG_SIGNAL  48          /* encoder hall digital signal */
#define DMD_MON_ENCODER_INDEX_SIGNAL     42          /* encoder index signal */
#define DMD_MON_ENCODER_IPOL_FACTOR      241         /* Encoder interpolation factor */
#define DMD_MON_ENCODER_LIMIT_SWITCH     44          /* Encoder limit switch */
#define DMD_MON_ENCODER_SINE_SIGNAL      40          /* Analog encoder sine signal */
#define DMD_MON_ERROR_CODE               64          /* Error code */
#define DMD_MON_INDIRECT_AXIS_MASK       94          /* drive mask for generic command */
#define DMD_MON_INFO_BOOT_REVISION       71          /* Soft. boot version of the drive */
#define DMD_MON_INFO_C_SOFT_BUILD_TIME   74          /* info current software build time */
#define DMD_MON_INFO_P_SOFT_BUILD_TIME   75          /* position uC software build time */
#define DMD_MON_INFO_PRODUCT_NUMBER      70          /* Drive type */
#define DMD_MON_INFO_PRODUCT_STRING      85          /* Article number */
#define DMD_MON_INFO_SERIAL_NUMBER       73          /* Serial number of the drive */
#define DMD_MON_INFO_SOFT_VERSION        72          /* Firmware version of the drive */
#define DMD_MON_IRQ_DRIVE_STATUS_1       160         /* interrupt drive status 1 */
#define DMD_MON_IRQ_DRIVE_STATUS_2       161         /* interrupt drive status 2 */
#define DMD_MON_IRQ_PENDING_AXIS_MASK    164         /* interrupt pending axis mask */
#define DMD_MON_MAX_SLS_POSITION_LIMIT   37          /* Superior pos. after SLS cmd */
#define DMD_MON_MIN_SLS_POSITION_LIMIT   36          /* Inferior pos. after SLS cmd */
#define DMD_MON_PDR_ACC_DEMAND_VALUE     35          /* theo.acceleration (pulse/dir) */
#define DMD_MON_PDR_POSITION_VALUE       17          /* Ref. val. for mode K61=0, 1, 3, 4, 36 */
#define DMD_MON_PDR_VELOCITY_DEMAND_VALU 34          /* theoretical speed (pulse/dir) */
#define DMD_MON_POSITION_ACTUAL_VALUE_DS 1           /* Real pos. w/ scal./map. */
#define DMD_MON_POSITION_ACTUAL_VALUE_US 7           /* Real pos. w/ SET/scal./map. (upi) */
#define DMD_MON_POSITION_CTRL_ERROR      2           /* Tracking error */
#define DMD_MON_POSITION_DEMAND_VALUE_DS 0           /* Theo. pos. w/ scal./map. */
#define DMD_MON_POSITION_DEMAND_VALUE_US 6           /* Theo. pos. w/ SET/scal./map. (upi) */
#define DMD_MON_POSITION_MAX_ERROR       3           /* Max. track. error during move. */
#define DMD_MON_REF_DEMAND_VALUE         18          /* reference demand value */
#define DMD_MON_TEB_NODE_MASK            512         /* present nodes on TEB */
#define DMD_MON_VELOCITY_ACTUAL_VALUE    11          /* Real velocity (dsi) */
#define DMD_MON_VELOCITY_DEMAND_VALUE    10          /* Theoretical velocity (dsi) */
#define DMD_MON_VELOCITY_SECONDARY_ACTUA 19          /* Second encoder real velocity */
#define DMD_MON_X_ANALOG_INPUT_1         56          /* extension card analog input 1 */
#define DMD_MON_X_ANALOG_INPUT_2         57          /* extension card analog input 2 */
#define DMD_MON_X_DIGITAL_INPUT          55          /* extension card digital inputs */
#define DMD_MON_X_INFO_BOOT_REVISION     77          /* extension card boot revision */
#define DMD_MON_X_INFO_PRODUCT_NUMBER    76          /* extension card product number */
#define DMD_MON_X_INFO_PRODUCT_STRING    86          /* extension card product string */
#define DMD_MON_X_INFO_SERIAL_NUMBER     79          /* extension card serial number */
#define DMD_MON_X_INFO_SOFT_BUILD_TIME   80          /* extension card soft build time */
#define DMD_MON_X_INFO_SOFT_VERSION      78          /* extension card soft version */

#endif /* DMD_OO_API */

/*
 * convertion constants
 */
#ifndef DMD_OO_API
#define DMD_CONV_DWORD                   0           /* double word value without conversion */
#define DMD_CONV_BOOL                    1           /* boolean value */
#define DMD_CONV_INT                     2           /* integer value without conversion */
#define DMD_CONV_LONG                    3           /* long integer value without conversion */
#define DMD_CONV_K14                     3           /*  */
#define DMD_CONV_K8                      3           /*  */
#define DMD_CONV_STRING                  4           /* packed string value */
#define DMD_CONV_FLOAT                   5           /* float value */
#define DMD_CONV_KFLOAT                  6           /* float value for K parameters */
#define DMD_CONV_UPI                     10          /* user position increment */
#define DMD_CONV_USI                     11          /* user speed increment */
#define DMD_CONV_UAI                     12          /* acceleration, user acceleration increment */
#define DMD_CONV_DPI                     15          /* drive position increment */
#define DMD_CONV_DSI                     16          /* drive speed increment */
#define DMD_CONV_DAI                     17          /* drive acceleration increment */
#define DMD_CONV_C13                     20          /* current 13bit range */
#define DMD_CONV_C14                     21          /* current 14bit range */
#define DMD_CONV_C29                     22          /* current 29bit range */
#define DMD_CONV_C15                     23          /* current 15bit range */
#define DMD_CONV_CUR                     24          /* current */
#define DMD_CONV_CUR2                    25          /* i<SUP>2</SUP>, dissipation value */
#define DMD_CONV_CUR2T                   26          /* i<SUP>2</SUP>t, integration value */
#define DMD_CONV_M82                     28          /* current limit in 10 mA unit, 100 <=> 1.0A */
#define DMD_CONV_STI                     30          /* slow time increment (500us-2ms) */
#define DMD_CONV_FTI                     31          /* fast time increment (125us-166us) */
#define DMD_CONV_CTI                     32          /* current loop time increment (41us) */
#define DMD_CONV_EXP10                   33          /* ten power factor */
#define DMD_CONV_HSTI                    34          /* half slow time increment */
#define DMD_CONV_M242                    35          /* quartz frequency in Hz */
#define DMD_CONV_QZTIME                  36          /* interrupt time in sec = inc / m242 */
#define DMD_CONV_SPEC2F                  37          /* filter time, T = [fti] * (2<SUP>n</SUP>-1) */
#define DMD_CONV_TEMP                    38          /* 2<SUP>0</SUP> = 1 <=> 1.0 */
#define DMD_CONV_UFTI                    39          /* user friendly time increment */
#define DMD_CONV_AVI                     40          /* analog voltage increment -8192 <=> 10V  8192 <=> -10V */
#define DMD_CONV_VOLT                    41          /* 2<SUP>0</SUP> = 1 <=> 1.0 */
#define DMD_CONV_ENCOFF                  42          /* 11bit with 2048 offset */
#define DMD_CONV_VOLT100                 43          /* (2<SUP>0</SUP>)/100 = 1 <=> 1.0 */
#define DMD_CONV_PH11                    44          /* 2<SUP>11</SUP> = 2048 <=> 360° */
#define DMD_CONV_PH12                    45          /* 2<SUP>12</SUP> = 4096 <=> 360° */
#define DMD_CONV_PH28                    46          /* 2<SUP>28</SUP> = 65536*4096 <=> 360° */
#define DMD_CONV_AVI12BIT                47          /* analog voltage increment 2048 <=>10V   -2048 <=> -10V */
#define DMD_CONV_AVI16BIT                48          /* analog voltage increment 32767 <=>10V   -32768 <=> -10V */
#define DMD_CONV_BIT0                    50          /* 2<SUP>0</SUP> = 1 <=> 1.0 */
#define DMD_CONV_BIT5                    55          /* 2<SUP>5</SUP> = 32 <=> 1.0 */
#define DMD_CONV_BIT8                    58          /* 2<SUP>8</SUP> = 256 <=> 1.0 */
#define DMD_CONV_BIT9                    59          /* 2<SUP>9</SUP> = 512 <=> 1.0 */
#define DMD_CONV_BIT10                   60          /* 2<SUP>10</SUP> = 1024 <=> 1.0 */
#define DMD_CONV_BIT11                   61          /* 2<SUP>11</SUP> = 2048 <=> 1.0 */
#define DMD_CONV_BIT11_ENCODER           62          /* Analgog encoder signal amplitude in volt (11 bit) */
#define DMD_CONV_BIT15_ENCODER           63          /* Analgog encoder signal amplitude in volt (15 bit) */
#define DMD_CONV_BIT15                   65          /* 2<SUP>15</SUP> = 32768 <=> 1.0 */
#define DMD_CONV_BIT24                   74          /* 2<SUP>24</SUP> = 256*65536 <=> 1.0 */
#define DMD_CONV_BIT31                   81          /* 2<SUP>31</SUP> = 32768*65536 <=> 1.0 */
#define DMD_CONV_BIT11P2                 82          /*  */
#define DMD_CONV_BIT15P2                 83          /*  */
#define DMD_CONV_UFPI                    85          /* user friendly position increment */
#define DMD_CONV_UFSI                    86          /* user friendly speed increment */
#define DMD_CONV_UFAI                    87          /* user friendly acceleration increment */
#define DMD_CONV_MSEC                    88          /* milliseconds */
#define DMD_CONV_K1                      90          /* pl prop gain, k(A/m) = k1 * Iref * dpi_factor / 2<SUP>29</SUP> */
#define DMD_CONV_K2                      92          /* pl speed feedback gain, k(A/(m/s)) = k2 * Iref * dsi_factor / 2<SUP>29</SUP> */
#define DMD_CONV_K4                      94          /* pl integrator gain, k(A/(m*s)) = k1 * Iref * dpi_factor / 2<SUP>29</SUP> / pl_time */
#define DMD_CONV_K5                      96          /* anti-windup K[m/A]=K5*4096/(dpi_factor * Iref) */
#define DMD_CONV_K9                      98          /* 1st order filter in pl */
#define DMD_CONV_K10                     100         /* 1st order filter in s. */
#define DMD_CONV_K20_DSB                 102         /* speed feedback, sec unit (m/(m/s)), F = k20 / 2<SUP>16-k50</SUP> * dsi_factor / dpi_factor */
#define DMD_CONV_K20                     103         /* speed feedback, sec unit (m/(m/s)), F = k20 / 2<SUP>16-k50</SUP> * dsi_factor / dpi_factor */
#define DMD_CONV_K21_DSB                 104         /* speed feedback, sec unit (m/(m/s<SUP>2</SUP>)), F = k20 / 2<SUP>24-k50</SUP> * dai_factor / dpi_factor */
#define DMD_CONV_K21                     105         /* speed feedback, sec unit (m/(m/s<SUP>2</SUP>)), F = k20 / 2<SUP>24-k50</SUP> * dai_factor / dpi_factor */
#define DMD_CONV_K23                     106         /* commutation phase advance period/(m/s) */
#define DMD_CONV_K75                     108         /* encoder multiple index distance, 1/1024 * encoder perion unit */
#define DMD_CONV_K80                     110         /* cl prop gain delta[1/A] */
#define DMD_CONV_K81                     112         /* cl prop integrator delta[1/(A*s)] */
#define DMD_CONV_K82                     114         /* filter time, T = [cti] * (2<SUP>n</SUP>-1) */
#define DMD_CONV_K94                     116         /* time in 2x current loop increment */
#define DMD_CONV_K95                     118         /* current rate for k95 */
#define DMD_CONV_K96                     120         /* phase rate for k96 */
#define DMD_CONV_PER_100                 122         /* per cent unit, 100 <=> 1.0 */
#define DMD_CONV_PER_1000                123         /* per thousand unit */
#define DMD_CONV_K239                    124         /* motor Kt factor in mN(m)/A, 1000 <=> 1.0mN(m)/A */

#endif /* DMD_OO_API */


/*** macros ***/

#define DMD_MAJOR(v)  (((v)>>24) & 0xFF)             /* major version information */
#define DMD_MINOR(v)  (((v)>>16) & 0xFF)             /* minor version information */
#define DMD_MICRO(v)  (((v)>>8) & 0xFF)              /* micro version information */

#ifndef ETEL_NO_P_MACROS
#define _DMD_P1(p)                       p
#define DMD_P1(p)                        p
#define _DMD_P2(p)                       p,
#define DMD_P2(p)                        p,
#endif

/*** types ***/

/* 
 * type modifiers
 */
#ifdef WIN32
#define _DMD_EXPORT __cdecl                          /* function exported by static library */
#define DMD_CALLBACK __cdecl                         /* client callback function called by library */
#endif /* WIN32 */

#ifdef QNX4
#define _DMD_EXPORT __cdecl                          /* function exported by library */
#define DMD_CALLBACK __cdecl                         /* client callback function called by library */
#endif /* QNX4 */

#ifdef POSIX
#define _DMD_EXPORT                           /* function exported by library */
#define DMD_CALLBACK                          /* client callback function called by library */
#endif /* POSIX */
/* 
 * hidden structures for library clients
 */
#ifndef DMD
#define DMD void
#endif

/**
 * @struct DMD_UNITS 
 * unit structure
 */
typedef struct DMD_UNITS {
    size_t size;                                     /**< the size of this structure */
	#ifdef DMD_OO_API
	int secondExp;                                   /**< exposent of 's' unit */
	int positionExp;                                 /**< exposent of 'm' or 't'(turn) unit */
	int voltExp;                                     /**< exposent of 'V' unit */
	int ampereExp;                                   /**< exposent of 'A' unit */
	int periodExp;                                   /**< exposent of period (360 deg) unit */
	int forceExp;                                    /**< exposent of 'N' or 'Nm' unit */
	int tempExp;                                     /**< exposent of '0C' unit */
	#else /* DMD_OO_API */
	int second_exp;                                  /**< exposent of 's' unit */
	int position_exp;                                /**< exposent of 'm' or 't'(turn) unit */
	int volt_exp;                                    /**< exposent of 'V' unit */
	int ampere_exp;                                  /**< exposent of 'A' unit */
	int period_exp;                                  /**< exposent of period (360 deg) unit */
	int force_exp;                                   /**< exposent of 'N' or 'Nm' unit */
	int temp_exp;                                    /**< exposent of '0C' unit */
	#endif /* DMD_OO_API */
} DMD_UNITS;
#define DmdUnits DMD_UNITS
typedef const DMD_UNITS *DMD_UNITS_CP;               /**< pointer to units information */


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

/*** prototypes ***/

/*
 * general functions
 */
dword   _DMD_EXPORT dmd_get_version(void);
dword   _DMD_EXPORT dmd_get_edi_version(void);
time_t  _DMD_EXPORT dmd_get_build_time(void);
char_cp _DMD_EXPORT dmd_translate_error(int code);
char_cp _DMD_EXPORT dmd_translate_drv_product(int d_prod);
char_cp _DMD_EXPORT dmd_translate_ext_product(int x_prod);
bool	_DMD_EXPORT dmd_is_double_conv(int conv);
DMD_UNITS_CP _DMD_EXPORT dmd_get_conv_units(int conv);

/*
 * supported drive version
 */
dword   _DMD_EXPORT dmd_get_first_defined_drv_version(int prod);
dword   _DMD_EXPORT dmd_get_last_defined_drv_version(int prod);
dword   _DMD_EXPORT dmd_get_next_defined_drv_version(int prod, dword ver);
bool    _DMD_EXPORT dmd_is_drv_version_supported(int prod, dword ver);
bool    _DMD_EXPORT dmd_is_drv_version_compatible(int prod, dword ref, dword ver);

/*
 * supported extension card version
 */
dword   _DMD_EXPORT dmd_get_first_defined_ext_version(int prod);
dword   _DMD_EXPORT dmd_get_last_defined_ext_version(int prod);
dword   _DMD_EXPORT dmd_get_next_defined_ext_version(int prod, dword ver);
bool    _DMD_EXPORT dmd_is_ext_version_supported(int prod, dword ver);
bool    _DMD_EXPORT dmd_is_ext_version_compatible(int prod, dword ref, dword ver);

/*
 * object creation functions
 */
int     _DMD_EXPORT dmd_create(DMD **dmd, int d_prod, dword d_ver, int x_prod, dword x_ver);
int     _DMD_EXPORT dmd_destroy(DMD **dmd);
bool    _DMD_EXPORT dmd_is_valid(DMD *dmd);

/*
 * general information retrieving
 */
int     _DMD_EXPORT dmd_get_drv_product(DMD *dmd);
int     _DMD_EXPORT dmd_get_ext_product(DMD *dmd);
dword   _DMD_EXPORT dmd_get_drv_version(DMD *dmd);
dword   _DMD_EXPORT dmd_get_ext_version(DMD *dmd);

/*
 * register meta-data access
 */
char_cp _DMD_EXPORT dmd_get_type_text(DMD *dmd, int text, int typ);
char_cp _DMD_EXPORT dmd_get_register_text(DMD *dmd, int text, int typ, unsigned idx, int sidx);
char_cp _DMD_EXPORT dmd_get_register_group(DMD *dmd, int text, int typ, unsigned idx);
long    _DMD_EXPORT dmd_get_register_min_value(DMD *dmd, int typ, unsigned idx, int sidx);
long    _DMD_EXPORT dmd_get_register_max_value(DMD *dmd, int typ, unsigned idx, int sidx);
long    _DMD_EXPORT dmd_get_register_default_value(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_double_register(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_system_register(DMD *dmd, int typ, unsigned idx, int sidx);
int     _DMD_EXPORT dmd_get_register_convert(DMD *dmd, int typ, unsigned idx, int sidx);
DMD_UNITS_CP 
        _DMD_EXPORT dmd_get_register_units(DMD *dmd, int typ, unsigned idx, int sidx);
int     _DMD_EXPORT dmd_get_register_enum_group(DMD *dmd, int typ, unsigned idx, int sidx);
int     _DMD_EXPORT dmd_get_subindex_enum_group(DMD *dmd, int typ, unsigned idx);
bool    _DMD_EXPORT dmd_is_type_available(DMD *dmd, int typ);
bool    _DMD_EXPORT dmd_is_type_uniform(DMD *dmd, int typ);
bool    _DMD_EXPORT dmd_is_type_writable(DMD *dmd, int typ);
bool    _DMD_EXPORT dmd_is_type_restored(DMD *dmd, int typ);
bool    _DMD_EXPORT dmd_is_index_available(DMD *dmd, int typ, unsigned idx);
bool    _DMD_EXPORT dmd_is_register_available(DMD *dmd, int typ, unsigned idx, int sidx);
long    _DMD_EXPORT dmd_get_number_of_indexes(DMD *dmd, int typ);
int     _DMD_EXPORT dmd_get_number_of_subindexes(DMD *dmd, int typ, int index);
int     _DMD_EXPORT dmd_get_max_number_of_subindexes(DMD *dmd, int typ);
bool    _DMD_EXPORT dmd_is_register_writable(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_register_restored(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_register_deprecated(DMD *dmd, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_register_hidden(DMD *dmd, int typ, unsigned idx, int sidx);

/*
 * command meta-data access
 */
char_cp _DMD_EXPORT dmd_get_command_text(DMD *dmd, int text, int idx);
char_cp _DMD_EXPORT dmd_get_command_group(DMD *dmd, int text, int idx);
char_cp _DMD_EXPORT dmd_get_parameter_text(DMD *dmd, int text, int idx, int par);
long    _DMD_EXPORT dmd_get_parameter_min_value(DMD *dmd, int idx, int par);
long    _DMD_EXPORT dmd_get_parameter_max_value(DMD *dmd, int idx, int par);
long    _DMD_EXPORT dmd_get_parameter_default_value(DMD *dmd, int idx, int par);
bool    _DMD_EXPORT dmd_is_double_parameter(DMD *dmd, int idx, int par);
int     _DMD_EXPORT dmd_get_parameter_convert(DMD *dmd, int idx, int par);
DMD_UNITS_CP 
        _DMD_EXPORT dmd_get_parameter_units(DMD *dmd, int idx, int par);
int     _DMD_EXPORT dmd_get_parameter_enum_group(DMD *dmd, int idx, int par);
int     _DMD_EXPORT dmd_get_number_of_parameters(DMD *dmd, int idx);
bool    _DMD_EXPORT dmd_is_command_available(DMD *dmd, int idx);
bool    _DMD_EXPORT dmd_is_command_rec_available(DMD *dmd, int idx, int rec, int dst_typ);
bool    _DMD_EXPORT dmd_is_command_deprecated(DMD *dmd, int idx);
bool    _DMD_EXPORT dmd_is_command_hidden(DMD *dmd, int idx);
bool    _DMD_EXPORT dmd_is_command_waiting(DMD *dmd, int idx);
bool    _DMD_EXPORT dmd_is_parameter_jump_target(DMD *dmd, int idx, int par);
bool    _DMD_EXPORT dmd_is_parameter_l_value(DMD *dmd, int idx, int par);

/*
 * enum_g values access
 */
bool    _DMD_EXPORT dmd_is_enum_group_available(DMD *dmd, int enum_g);
char_cp _DMD_EXPORT dmd_get_enum_group_text(DMD *dmd, int text, int enum_g);
int     _DMD_EXPORT dmd_get_enum_group_size(DMD *dmd, int enum_g);
char_cp _DMD_EXPORT dmd_get_enum_text(DMD *dmd, int text, int enum_g, int id);
long    _DMD_EXPORT dmd_get_enum_value(DMD *dmd, int enum_g, int id);
int     _DMD_EXPORT dmd_get_enum_range(DMD *dmd, int enum_g, int id);
bool    _DMD_EXPORT dmd_is_enum_mask(DMD *dmd, int enum_g, int id);
bool    _DMD_EXPORT dmd_is_enum_hidden(DMD *dmd, int enum_g, int id);
bool    _DMD_EXPORT dmd_is_enum_deprecated(DMD *dmd, int enum_g, int id);
bool    _DMD_EXPORT dmd_is_register_enum_available(DMD *dmd, int enum_id, int typ, unsigned idx, int sidx);
bool    _DMD_EXPORT dmd_is_subindex_enum_available(DMD *dmd, int enum_id, int typ, unsigned idx);
bool    _DMD_EXPORT dmd_is_parameter_enum_available(DMD *dmd, int enum_id, int idx, int par);

#ifdef __cplusplus
} /* extern "C" */
#endif


/*
 * Dmd base class - c++
 */
#ifdef DMD_OO_API
class Dmd {
    /*
     * some public constants
     */
	/*
	 * release status
	 */ 
public:
    enum { MICRO_ALPHA =  0x00 };                    /* base number for alpha releases */
    enum { MICRO_BETA = 0x40 };                      /* base number for beta releases */
    enum { MICRO_FINAL = 0x80 };                     /* base number for final releases */

	/*
	 * lab-view (record 04h) command numbers
	 */ 
public:
    enum { LAB_TRACE_MODE = 210 };                   /* change trace acquisition speed and trigger mode */
    enum { LAB_TRACE_LEVEL = 211 };                  /* define trigger level for mode 3 and 4 */  
    enum { LAB_TRACE_ACQUIRE = 202 };                /* trig aquisition of two vectors */

	/*
	 * special user register
	 */ 
public:
    enum { USR_ACC = 0xFFFF } ;                      /* special user data - accumulator */
    enum { VAR_INDIRECT = 0xFFFE } ;                 /* indirect register access */

	/*
	 * special product number
	 */ 
public:
    enum { PRODUCT_ANY = -1 } ;                      /* special product number - any */

	/*
	 * some maximum values
	 */
	enum { TYPES = 16 };                             /* no more than 16 types now */
	enum { ENUMS = 128 };                             /* no more than 128 enums now */
	enum { COMMANDS = 1280 };                         /* no more than 1280 commands now */
	enum { CONVS = 256 };                            /* no more than 256 conversions now */
    
	/*
     * versions access
     */
public:
    static dword getVersion() { 
        return dmd_get_version(); 
    }
    static dword getEdiVersion() { 
        return dmd_get_edi_version(); 
    }
    static dword getBuildTime() { 
        return dmd_get_build_time(); 
    }

	static bool isDoubleConv(int conv) {
	    return dmd_is_double_conv(conv);
	}

	static const DmdUnits &getConvUnits(int conv) {
	    return *dmd_get_conv_units(conv);
	}

    /*
	 * supported drive version
	 */
    static dword getFirstDefinedDrvVersion(int prod) {
	    return dmd_get_first_defined_drv_version(prod);
	}
    static dword getLastDefinedDrvVersion(int prod) {
	    return dmd_get_last_defined_drv_version(prod);
	}
    static dword getNextDefinedDrvVersion(int prod, dword ver) {
	    return dmd_get_next_defined_drv_version(prod, ver);
	}
    static bool isDrvVersionSupported(int prod, dword ver) {
	    return dmd_is_drv_version_supported(prod, ver);
	}
    static bool isDrvVersionCompatible(int prod, dword ref, dword ver) {
	    return dmd_is_drv_version_compatible(prod, ref, ver);
	}

    /*
	 * supported extension card version
	 */
    static dword getFirstDefinedExtVersion(int prod) {
	    return dmd_get_first_defined_ext_version(prod);
	}
    static dword getLastDefinedExtVersion(int prod) {
	    return dmd_get_last_defined_ext_version(prod);
	}
    static dword getNextDefinedExtVersion(int prod, dword ver) {
	    return dmd_get_next_defined_ext_version(prod, ver);
	}
    static bool isExtVersionSupported(int prod, dword ver) {
	    return dmd_is_ext_version_supported(prod, ver);
	}
    static bool isExtVersionCompatible(int prod, dword ref, dword ver) {
	    return dmd_is_ext_version_compatible(prod, ref, ver);
	}
};
#endif /* DMD_OO_API */

 
/*
 * Dmd exception - c++
 */
#ifdef DMD_OO_API
class DmdException {
friend class DmdData;
friend class DmdTraductor;
    /*
     * public error codes
     */
public:
    enum { EBADDRVPROD = -416 };                     /* an unknown drive product has been specified */
    enum { EBADDRVVER = -418 };                      /* a drive with an incompatible version has been specified */
    enum { EBADEXTPROD = -417 };                     /* an unknown extention card  product has been specified */
    enum { EBADEXTVER = -419 };                      /* an extention card with an incompatible version has been specified */
    enum { EBADPARAM = -415 };                       /* one of the parameter is not valid */
    enum { ESYSTEM = -414 };                         /* some system resource return an error */

    /*
     * exception code
     */
private:
    int code;

    /*
     * constructor
     */
protected:
    DmdException(int e) { code = e; };

    /*
     * translate a drive product code to the text description
     */
public:
    static const char *translate(int d_prod) { 
        return dmd_translate_error(d_prod);
    }

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
#endif /* DMD_OO_API */


/*
 * Data class - c++
 */
#ifdef DMD_OO_API
#define ERRCHK(a) do { int _err = (a); if (_err) throw DmdException(_err); } while(0)
class DmdData {
    /*
     * internal dmd pointer
     */
protected:
    DMD *dmd;

	/*
	 * text query constants
	 */ 
public:
    enum { TEXT_MNEMONIC = 1 };                      /* mnemonic */
    enum { TEXT_SHORT = 2 };                         /* short text description */

	/*
	 * type of parameter parameters
	 */
public:
    enum { TYP_IMMEDIATE = 0x00 };                   /* the parameter is an immediate value */
    enum { TYP_USER = 0x01 };                        /* the parameter is a user variable */
    enum { TYP_PPK = 0x02 };                         /* the parameter is a parameter */
    enum { TYP_MONITOR = 0x03 };                     /* the parameter is a monitoring register */
    enum { TYP_SEQUENCE = 0x05 };                    /* the parameter is a part of the sequence buffer */
    enum { TYP_TRACE = 0x06 };                       /* the parameter is a part of the trace buffer */
    enum { TYP_ADDRESS = 0x07 };                     /* the parameter is a longword in the drive memory */
    enum { TYP_LKT = 0x08 };                         /* the parameter is a part of a lookup table */
    enum { TYP_TRIGGER = 0x09 };                     /* the parameter is a part of the trigger buffer */
    enum { TYP_REALTIME = 0x0A };                    /* the parameter is a part of the RI buffer */
    enum { TYP_HALL_LKT = 0x0B };                    /* the parameter is a part of the hall effect lookup-table */

    /*
     * constructors / destructor
     */
public:
    DmdData(int d_prod, dword d_ver, int x_prod, dword x_ver) { 
	    dmd = NULL; 
        ERRCHK(dmd_create(&dmd, d_prod, d_ver, x_prod, x_ver));
    }
    DmdData(DmdData &data) { 
	    dmd = data.dmd; 
    }
    bool isValid() {
        return dmd_is_valid(dmd);
    }

    /*
     * destructor function
     */
    void destroy() {
        ERRCHK(dmd_destroy(&dmd));
    }
	
	/*
	 * general information retrieving
	 */
	int getDrvProduct() {
	    return dmd_get_drv_product(dmd);
	}
	int getExtProduct() {
	    return dmd_get_ext_product(dmd);
	}
	int getDrvVersion() {
	    return dmd_get_drv_version(dmd);
	}
	int getExtVersion() {
	    return dmd_get_ext_version(dmd);
	}

    /*
     * register meta-data access
     */
	char_cp getTypeText(int text, int typ) {
	    return dmd_get_type_text(dmd, text, typ);
	}
	char_cp getRegisterText(int text, int typ, unsigned idx, int sidx) {
	    return dmd_get_register_text(dmd, text, typ, idx, sidx);
	}
	char_cp getRegisterGroup(int text, int typ, unsigned idx) {
	    return dmd_get_register_group(dmd, text, typ, idx);
	}
	long getRegisterMinValue(int typ, unsigned idx, int sidx) {
	    return dmd_get_register_min_value(dmd, typ, idx, sidx);
	}
	long getRegisterMaxValue(int typ, unsigned idx, int sidx) {
	    return dmd_get_register_max_value(dmd, typ, idx, sidx);
	}
	long getRegisterDefaultValue(int typ, unsigned idx, int sidx) {
	    return dmd_get_register_default_value(dmd, typ, idx, sidx);
	}
	int getRegisterConvert(int typ, unsigned idx, int sidx) {
	    return dmd_get_register_convert(dmd, typ, idx, sidx);
	}
	int getRegisterEnumGroup(int typ, unsigned idx, int sidx) {
	    return dmd_get_register_enum_group(dmd, typ, idx, sidx);
	}
	int getSubindexEnumGroup(int typ, unsigned idx) {
	    return dmd_get_subindex_enum_group(dmd, typ, idx);
	}
	bool isDoubleRegister(int typ, unsigned idx, int sidx) {
	    return dmd_is_double_register(dmd, typ, idx, sidx);
	}
	bool isSystemRegister(int typ, unsigned idx, int sidx) {
	    return dmd_is_system_register(dmd, typ, idx, sidx);
	}
	const DMD_UNITS &getRegisterUnits(int typ, unsigned idx, int sidx) {
	    return *dmd_get_register_units(dmd, typ, idx, sidx);
	}
	bool isTypeAvailable(int typ) {
	    return dmd_is_type_available(dmd, typ);
	}
	bool isTypeUniform(int typ) {
	    return dmd_is_type_uniform(dmd, typ);
	}
	bool isTypeWritable(int typ) {
	    return dmd_is_type_writable(dmd, typ);
	}
	bool isTypeRestored(int typ) {
	    return dmd_is_type_restored(dmd, typ);
	}
	bool isIndexAvailable(int typ, unsigned idx) {
	    return dmd_is_index_available(dmd, typ, idx);
	}
	bool isRegisterAvailable(int typ, unsigned idx, int sidx) {
	    return dmd_is_register_available(dmd, typ, idx, sidx);
	}
	bool isRegisterWritable(int typ, unsigned idx, int sidx) {
	    return dmd_is_register_writable(dmd, typ, idx, sidx);
	}
	bool isRegisterRestored(int typ, unsigned idx, int sidx) {
	    return dmd_is_register_restored(dmd, typ, idx, sidx);
	}
	bool isRegisterHidden(int typ, unsigned idx, int sidx) {
	    return dmd_is_register_hidden(dmd, typ, idx, sidx);
	}
	bool isRegisterDeprecated(int typ, unsigned idx, int sidx) {
	    return dmd_is_register_deprecated(dmd, typ, idx, sidx);
	}
	long getNumberOfIndexes(int typ) {
	    return dmd_get_number_of_indexes(dmd, typ);
	}
	int getNumberOfSubindexes(int typ, int index) {
	    return dmd_get_number_of_subindexes(dmd, typ, index);
	}
	int getMaxNumberOfSubindexes(int typ) {
	    return dmd_get_max_number_of_subindexes(dmd, typ);
	}

    /*
     * command meta-data access
     */
	char_cp getCommandText(int text, int idx) {
	    return dmd_get_command_text(dmd, text, idx);
	}
	char_cp getCommandGroup(int text, int idx) {
	    return dmd_get_command_group(dmd, text, idx);
	}
	char_cp getParameterText(int text, int idx, int par) {
	    return dmd_get_parameter_text(dmd, text, idx, par);
	}
	long getParameterMinValue(int idx, int par) {
	    return dmd_get_parameter_min_value(dmd, idx, par);
	}
	long getParameterMaxValue(int idx, int par) {
	    return dmd_get_parameter_max_value(dmd, idx, par);
	}
	long getParameterDefaultValue(int idx, int par) {
	    return dmd_get_parameter_default_value(dmd, idx, par);
	}
	int getParameterConvert(int idx, int par) {
	    return dmd_get_parameter_convert(dmd, idx, par);
	}
	bool isDoubleParameter(int idx, int par) {
	    return dmd_is_double_parameter(dmd, idx, par);
	}
	const DMD_UNITS &getParameterUnits(int idx, int par) {
	    return *dmd_get_parameter_units(dmd, idx, par);
	}
	int getParameterEnumGroup(int idx, int par) {
	    return dmd_get_parameter_enum_group(dmd, idx, par);
	}
	int getNumberOfParameters(int idx) {
	    return dmd_get_number_of_parameters(dmd, idx);
	}
	bool isCommandAvailable(int idx) {
	    return dmd_is_command_available(dmd, idx);
	}
	bool isCommandRecAvailable(int idx, int rec, int dst_typ) {
	    return dmd_is_command_rec_available(dmd, idx, rec, dst_typ);
	}
	bool isCommandDeprecated(int idx) {
	    return dmd_is_command_deprecated(dmd, idx);
	}
	bool isCommandHidden(int idx) {
	    return dmd_is_command_hidden(dmd, idx);
	}
	bool isParameterJumpTarget(int idx, int par) {
	    return dmd_is_parameter_jump_target(dmd, idx, par);
	}
	bool isParameterLValue(int idx, int par) {
	    return dmd_is_parameter_l_value(dmd, idx, par);
	}

	/*
	 * enum_g values access
	 */
	bool isEnumGroupAvailable(int enum_g) {
	    return dmd_is_enum_group_available(dmd, enum_g);
	}
	char_cp getEnumGroupText(int text, int enum_g) {
	    return dmd_get_enum_group_text(dmd, text, enum_g);
	}
	int getEnumGroupSize(int enum_g) {
	    return dmd_get_enum_group_size(dmd, enum_g);
	}
	char_cp getEnumText(int text, int enum_g, int id) {
	    return dmd_get_enum_text(dmd, text, enum_g, id);
	}
	long getEnumValue(int enum_g, int id) {
	    return dmd_get_enum_value(dmd, enum_g, id);
	}
	int getEnumRange(int enum_g, int id) {
	    return dmd_get_enum_range(dmd, enum_g, id);
	}
	bool isEnumMask(int enum_g, int id) {
	    return dmd_is_enum_mask(dmd, enum_g, id);
	}
	bool isEnumHidden(int enum_g, int id) {
	    return dmd_is_enum_hidden(dmd, enum_g, id);
	}
	bool isEnumDeprecated(int enum_g, int id) {
	    return dmd_is_enum_deprecated(dmd, enum_g, id);
	}
	bool isRegisterEnumAvailable(int enum_id, int typ, int idx, int sidx) {
	    return dmd_is_register_enum_available(dmd, enum_id, typ, idx, sidx);
	}
	bool isSubindexEnumAvailable(int enum_id, int typ, int idx) {
	    return dmd_is_subindex_enum_available(dmd, enum_id, typ, idx);
	}
	bool isParameterEnumAvailable(int enum_id, int idx, int par) {
	    return dmd_is_parameter_enum_available(dmd, enum_id, idx, par);
	}

};
#undef ERRCHK
#endif /* DMD_OO_API */

/*The enum values are now freezed
-ETELSQL-
    SELECT subquery FROM prepareEnumsCpp
    ORDER BY code;
-/ETELSQL-
*/

/*
 * ebl baud rates - c++
 */
#ifdef DMD_OO_API
class DmdBaudrate {
public:
    enum { DEFAULT = 0 };                            /* default baud rate */
    enum { B_9600 = 9600 };                          /* 9600 bauds */
    enum { B_19200 = 19200 };                        /* 19200 bauds */
    enum { B_38400 = 38400 };                        /* 38400 bauds */
    enum { B_57600 = 57600 };                        /* 57600 bauds */
    enum { B_115200 = 115200 };                      /* 115200 bauds */

};
#endif /* DMD_OO_API */


/*
 * display modes - c++
 */
#ifdef DMD_OO_API
class DmdDisplay {
public:
    enum { NORMAL = 1 };                             /* normal informations */
    enum { TEMPERATURE = 2 };                        /* drive temperature */
    enum { ENCODER = 4 };                            /* analog encoder signals */
    enum { SEQUENCE = 8 };                           /* sequence line number */
    enum { X_BOARD = 16 };                           /* extension board */

};
#endif /* DMD_OO_API */


/*
 * drive error codes - c++
 */
#ifdef DMD_OO_API
class DmdDrvError {
public:
    enum { SAVE_OPERATION = 1 };                     /* save operation error */
    enum { OVER_CURRENT_1 = 2 };                     /* over current 1 */
    enum { OVER_CURRENT_2 = 3 };                     /* over current 2 */
    enum { I2T_OVER_CURRENT = 4 };                   /* i2t over current */
    enum { OVER_TEMPERATURE = 5 };                   /* over temperature */
    enum { OVER_VOLTAGE = 6 };                       /* over voltage error */
    enum { POWER_SUPPLY_INRUSH = 7 };                /* inrush power supply error */
    enum { ENCODER_AMPLITUDE = 20 };                 /* encoder amplitude error */
    enum { ENCODER_POSITION_LOST = 21 };             /* encoder position lost */
    enum { UC_SYNCHRO = 22 };                        /* uc synchro error */
    enum { TRACKING_ERROR = 23 };                    /* tracking error */
    enum { OVER_SPEED = 24 };                        /* over speed error */
    enum { POWER_ON = 26 };                          /* power on error */
    enum { MOTOR_OVER_TEMP = 29 };                   /* motor over temperature */
    enum { LIMIT_SWITCH = 30 };                      /* limit switch reached */
    enum { LVDT_ERROR = 31 };                        /* LVDT error */
    enum { LVDT_NOT_PRESENT = 32 };                  /* LVDT not present */
    enum { LVDT_ADC_ERROR = 33 };                    /* LVDT ADC out */
    enum { F3_FUSE = 34 };                           /* F3 fuse dead */
    enum { F7_FUSE = 35 };                           /* F7 fuse dead */
    enum { BAD_SEQ_LABEL = 36 };                     /* sequence label number */
    enum { BAD_SEQ_LINE = 37 };                      /* sequence line number */
    enum { BAD_REG_IDX = 38 };                       /* register number */
    enum { STACK_OVERFLOW = 39 };                    /* stack overflow */
    enum { ETB_FRAMING = 46 };                       /* EB framing error */
    enum { ETB_OVERRUN = 47 };                       /* EB overrun */
    enum { ETB_CHECKSUM = 48 };                      /* EB checksum error */
    enum { ETB_SAME_AXIS = 49 };                     /* EB same axis error */
    enum { ETB_UNKNOWN_MESSAGE = 50 };               /* EB unknown message */
    enum { ETB_DAISY_CHAIN = 51 };                   /* EB daisy chain error */
    enum { ETB_NO_SLAVES = 52 };                     /* EB no slaves */
    enum { ETB_OTHER_AXIS = 53 };                    /* EB other axis error */
    enum { ETB_SELF_TEST = 54 };                     /* EB self test error */
    enum { ETB_CHARACTER_LOST = 55 };                /* EB character lost */
    enum { ETB_TIMEOUT = 56 };                       /* EB timeout */
    enum { MULTIPLE_INDEX = 61 };                    /* multiple index error */
    enum { SINGLE_INDEX = 62 };                      /* single index error */
    enum { SYNCHRO_START = 63 };                     /* synchro start error */
    enum { ETB_NO_MASTER = 71 };                     /* EB no master */
    enum { EBL_FRAMING = 80 };                       /* EBL framing error */
    enum { EBL_OVERRUN = 81 };                       /* EBL overrun */
    enum { EBL_CHECKSUM = 82 };                      /* EBL checksum error */
    enum { EBL_UNKNOWN_MESSAGE = 83 };               /* EBL unknown message */
    enum { EBL_INPUT_BUFFER = 84 };                  /* EBL input buffer error */
    enum { EBL_TIMEOUT_1 = 86 };                     /* EBL timeout 1 */
    enum { EBL_TIMEOUT_2 = 87 };                     /* EBL timeout 2 */
    enum { EBL_OTHER_AXIS = 88 };                    /* EBL other axis error */
    enum { MAC_OVERRUN = 89 };                       /* MACRO overrun */
    enum { MAC_VIOLATION = 90 };                     /* MACRO violation */
    enum { MAC_PARITY = 91 };                        /* MACRO parity error */
    enum { MAC_UNDERRUN = 92 };                      /* MACRO underrun */
    enum { MAC_SYNC_LOST = 93 };                     /* MACRO synchro lost */
    enum { MAC_AUX_2_CMD = 94 };                     /* MACRO aux 2 cmd error */
    enum { MAC_AUX_2 = 95 };                         /* MACRO aux 2 error */
    enum { MAC_AUX_3 = 96 };                         /* MACRO aux 3 error */
    enum { MAC_AUX_4 = 97 };                         /* MACRO aux 4 error */
    enum { HARD_OVER_CURRENT = 130 };                /* hardware overcurrent */
    enum { WD_CURRENT_UC = 140 };                    /* current uc watchdog error */
    enum { WD_POSITION_FPGA = 141 };                 /* position FPGA watchdog */
    enum { WD_POSITION_UC = 142 };                   /* position uc watchdog error */
    enum { WD_CURRENT_AD = 143 };                    /* current A/D watchdog */
    enum { WD_QUARTZ = 144 };                        /* quartz watchdog */
    enum { INIT_MOTOR_1 = 150 };                     /* motor initialisation error 1 */
    enum { INIT_MOTOR_2 = 151 };                     /* motor initialisation error 2 */
    enum { BAD_SOFTWARE = 176 };                     /* bad software */

};
#endif /* DMD_OO_API */


/*
 * status of enable input - c++
 */
#ifdef DMD_OO_API
class DmdEnableInput {
public:
    enum { REQUIRED = 0 };                           /* required */
    enum { NOT_USED = 125 };                         /* not used */
    enum { X135 = 135 };                             /* enable use of K110, K111, K112 */
    enum { AUTO = 170 };                             /* automatic */

};
#endif /* DMD_OO_API */


/*
 * kind of encoder - c++
 */
#ifdef DMD_OO_API
class DmdEncoder {
public:
    enum { ANALOG = 0 };                             /* analog encoder */
    enum { TTL = 1 };                                /* TTL encoder */
    enum { HALL = 2 };                               /* HALL encoder */
    enum { LVDT = 3 };                               /* LVDT encoder */
    enum { ANALOG_AND_MACRO = 100 };                 /* analog encoder with MACRO bus */
    enum { TTL_AND_MACRO = 101 };                    /* TTL encoder with MACRO bus */
    enum { UNCHECKED_ANALOG_AND_MACRO = 102 };       /* unchecked analog encoder with MACRO bus */
    enum { HALL_AND_MACRO = 103 };                   /* HALL encoder with MACRO bus */

};
#endif /* DMD_OO_API */


/*
 * mask of fuses not controlled - c++
 */
#ifdef DMD_OO_API
class DmdFuseControl {
public:
    enum { F3_DISABLED = 1 };                        /* F3 disabled */
    enum { F7_DISABLED = 2 };                        /* F7 disabled */

};
#endif /* DMD_OO_API */


/*
 * usage of limit/home switch - c++
 */
#ifdef DMD_OO_API
class DmdSwitch {
public:
    enum { LIMIT_ENABLED = 1 };                      /* limit switch enabled */
    enum { HOME_INVERTED = 2 };                      /* home switch inverted */
    enum { HOME_ENABLED = 128 };                     /* home switch enabled */

};
#endif /* DMD_OO_API */


/*
 * homing modes - c++
 */
#ifdef DMD_OO_API
class DmdHoming {
public:
    enum { NEGATIVE_MVT = 1 };                       /* negative movement */
    enum { MECHANICAL = 0 };                         /* mechanical end stop */
    enum { HOME_SW = 2 };                            /* home switch */
    enum { LIMIT_SW = 4 };                           /* limit switch */
    enum { HOME_SW_L = 6 };                          /* home switch w/limit */
    enum { SINGLE_INDEX = 8 };                       /* single index */
    enum { SINGLE_INDEX_L = 10 };                    /* single index w/limit */
    enum { MULTI_INDEX = 12 };                       /* multi-index */
    enum { MULTI_INDEX_L = 14 };                     /* multi-index w/limit */
    enum { GATED_INDEX = 16 };                       /* single index and DIN2 */
    enum { GATED_INDEX_L = 18 };                     /* single index and DIN2 w/limit */
    enum { MULTI_INDEX_DS = 20 };                    /* multi-index w/defined stroke */
    enum { IMMEDIATE = 22 };                         /* immediate */
    enum { SINGLE_INDEX_DS = 24 };                   /* single index w/defined stroke */

};
#endif /* DMD_OO_API */


/*
 * init modes - c++
 */
#ifdef DMD_OO_API
class DmdInitMode {
public:
    enum { NONE = 0 };                               /* none */
    enum { PULSE = 1 };                              /* current pulses */
    enum { CONTINOUS = 2 };                          /* continous current */
    enum { HALL_UNTIL_EDGE = 3 };                    /* digital hall sensor until edge */
    enum { HALL_UNTIL_INDEX = 4 };                   /* digital hall sensor until index */
    enum { HALL = 5 };                               /* digital hall sensor */

};
#endif /* DMD_OO_API */


/*
 * integrator mode - c++
 */
#ifdef DMD_OO_API
class DmdIntegrator {
public:
    enum { ON = 0 };                                 /* always off */
    enum { IN_POSITION = 1 };                        /* on in position */
    enum { OFF = 2 };                                /* always on */

};
#endif /* DMD_OO_API */


/*
 * motor phase correction - c++
 */
#ifdef DMD_OO_API
class DmdPhaseCorrection {
public:
    enum { PHASES = 0 };                             /* phase not inverted */
    enum { FORCE = 3 };                              /* phase inverted */

};
#endif /* DMD_OO_API */


/*
 * lookup-table definitions - c++
 */
#ifdef DMD_OO_API
class DmdLookupTable {
public:
    enum { USER_0 = 0 };                             /* user defined 0 */
    enum { USER_1 = 1 };                             /* user defined 1 */
    enum { USER_2 = 2 };                             /* user defined 2 */
    enum { USER_3 = 3 };                             /* user defined 3 */
    enum { S_CURVE = 25 };                           /* s-curve */
    enum { TRIANGULAR = 28 };                        /* triangular */
    enum { SINE_CURVE = 31 };                        /* sine curve */

};
#endif /* DMD_OO_API */


/*
 * drive mode - c++
 */
#ifdef DMD_OO_API
class DmdDrvMode {
public:
    enum { FORCE_REFERENCE = 0 };                    /* force reference */
    enum { POSITION_PROFILE = 1 };                   /* position profile */
    enum { SPEED_REFERENCE = 3 };                    /* speed reference */
    enum { POSITION_REFERENCE = 4 };                 /* position reference */
    enum { PULSE_DIRECTION = 5 };                    /* pulse direction */
    enum { PULSE_DIRECTION_TTL = 6 };                /* pulse direction TTL */
    enum { DSMAX_POSITION_REFERENCE = 7 };           /* DSMAX position reference */
    enum { POSITION_REFERENCE_2 = 36 };              /* position reference */
    enum { PULSE_DIRECTION_2 = 37 };                 /* pulse direction */
    enum { PULSE_DIRECTION_TTL_2 = 38 };             /* pulse direction TTL */

};
#endif /* DMD_OO_API */


/*
 * motor phases - c++
 */
#ifdef DMD_OO_API
class DmdPwmMode {
public:
    enum { PHASES_1 = 10 };                          /* 1 phase motor */
    enum { PHASE_1_LOW_SWITCHING = 11 };             /* 1 phase motor with low switching freq */
    enum { PHASE_1_HIGH_CL_FREQ = 13 };              /* 1 phase motor with high cl freq. */
    enum { PHASES_2 = 20 };                          /* 2 phase motor */
    enum { PHASE_2_LOW_SWITCHING = 21 };             /* 2 phase motor with low switching freq. */
    enum { PHASE_2_HIGH_CL_FREQ = 23 };              /* 2 phase motor with high cl freq. */
    enum { PHASES_3 = 30 };                          /* 3 phase motor */
    enum { PHASE_3_LOW_SWITCHING = 31 };             /* 3 phase motor with low switching freq. */
    enum { PHASE_3_HIGH_CL_FREQ = 33 };              /* 3 phase motor with high cl freq. */

};
#endif /* DMD_OO_API */


/*
 * types of movement - c++
 */
#ifdef DMD_OO_API
class DmdMovement {
public:
    enum { TRAPEZIODAL = 0 };                        /* trapezoidal movement */
    enum { S_CURVE = 1 };                            /* S-curve movement */
    enum { INFINITE_ROTARY_SLOW = 8 };               /* infinite rotary movement */
    enum { SLOW_LKT = 10 };                          /* LKT movement in slow interrupt */
    enum { FAST_LKT = 11 };                          /* LKT movement in fast interrupt */
    enum { INFINITE_ROTARY_FAST = 12 };              /* infinite rotary movement (deprecated) */
    enum { TTL_DRIVEN_LKT = 13 };                    /* LKT movement drived by TTL encoder */
    enum { SCURVE_ROTARY = 17 };                     /* S-curve rotary movement */
    enum { INFINITE_ROTARY = 24 };                   /* infinite rotary movement */
    enum { LKT_ROTARY = 26 };                        /* LKT rotary movement */

};
#endif /* DMD_OO_API */


/*
 * drive products - c++
 */
#ifdef DMD_OO_API
class DmdDrvProduct {
public:
    enum { DSA2P = 2 };                              /* DSA2P drive */
    enum { DSB2P = 4 };                              /* DSB2P drive */
    enum { DSC2P = 6 };                              /* DSC2P drive */
    enum { DSCDP = 7 };                              /* DSCDP drive */
    enum { DSCDL = 8 };                              /* DSCDL drive */
    enum { DSCDL_QT = 9 };                           /* DSCDL Servo Track Writer*/
    enum { DSCDM = 10 };                             /* DSCDM drive */
    enum { DSCDU = 11 };                             /* DSCDU drive */
    enum { GP_MODULE = 15 };                	     /* GP_MODULE General purpose module */
    enum { DSMAX = 16 };                             /* DSMAX axis controller */
    enum { DSMAX2 = 17 };                            /* DSMAX2 axis controller */

};
#endif /* DMD_OO_API */


/*
 * extension card products - c++
 */
#ifdef DMD_OO_API
class DmdExtProduct {
public:
    enum { DSOSIO = 1 };                             /* DSOSIO super i/o */
    enum { DSO001 = 2 };                             /* DSO001 power i/o */
    enum { DSOLVD = 3 };                             /* DSOLVD LVDT adapter */
    enum { DSOMAC = 4 };                             /* DSOMAC MACRO bus */
    enum { DSOTEB = 5 };                             /* DSOTEB (Turbo ETEL-BUS) */
    enum { DSO003 = 6 };                             /* DSO003 */
    enum { DSOHIO = 7 };                             /* DSOHIO hyper i/o */
    enum { DSOCAN_CNE = 16 };                        /* DSOCAN w/CANetel protocol */
    enum { DSOCAN_CNW = 17 };                        /* DSOCAN w/Wuilfer protocol */
    enum { DSOSER = 24 };                            /* DSOSER SERCOS bus */
    enum { DSOPRO = 32 };							 /* DSOCAN w/Wuilfer protocol */
    enum { DSOSER2 = 25 };                           /* DSOSER2 SERCOS bus */

};
#endif /* DMD_OO_API */


/*
 * regeneration modes - c++
 */
#ifdef DMD_OO_API
class DmdRegeneration {
public:
    enum { OFF = 0 };                                /* always off */
    enum { LIMITED = 2 };                            /* on for max 10s */
    enum { ON = 3 };                                 /* always on */

};
#endif /* DMD_OO_API */


/*
 * source type - c++
 */
#ifdef DMD_OO_API
class DmdTyp {
public:
    enum { NONE = 0 };                               /* no type */
    enum { IMMEDIATE = 0 };                          /* disabled or immediate value */
    enum { USER = 1 };                               /* user registers */
    enum { PPK = 2 };                                /* drive parameters */
    enum { MONITOR = 3 };                            /* monitoring registers */
    enum { SEQUENCE = 5 };                           /* sequence buffer */
    enum { TRACE = 6 };                              /* trace buffer */
    enum { ADDRESS = 7 };                            /* address value */
    enum { LKT = 8 };                                /* movement lookup tables */
    enum { TRIGGER = 9 };                            /* triggers buffer */
    enum { REALTIME = 10 };                          /* realtime buffer */
    enum { HALL_LKT = 11 };                          /* hall lookup tables */
    enum { FLOAT = 12 };                             /* float register */

};
#endif /* DMD_OO_API */


/*
 * status drive 1 - c++
 */
#ifdef DMD_OO_API
class DmdStatus1 {
public:
    enum { ERROR_OTHER_AXIS = LONG_MIN };            /* other axis error */
    enum { ERROR_BYTE = -16777216 };                 /* error byte */
    enum { POWER_ON = 1 };                           /* power on */
    enum { INIT_DONE = 2 };                          /* initialization done */
    enum { HOMING_DONE = 4 };                        /* indexation done */
    enum { PRESENT = 8 };                            /* present */
    enum { MOVING = 16 };                            /* moving */
    enum { IN_WINDOW = 32 };                         /* in window */
    enum { MASTER = 64 };                            /* EB master mode */
    enum { WAITING = 128 };                          /* driver is waiting */
    enum { EXEC_SEQ = 256 };                         /* sequence execution */
    enum { EDIT_SEQ = 512 };                         /* sequence edition */
    enum { ERROR_ANY = 1024 };                       /* global error */
    enum { TRACE_BUSY = 2048 };                      /* trace busy */
    enum { BRIDGE = 4096 };                          /* EB bridge mode */
    enum { HOMING = 8192 };                          /* homing */
    enum { EBL_TO_EB = 16384 };                      /* EBL to EB pass trough */
    enum { SPY = 32768 };                            /* EB spy mode */
    enum { WARNING_I2T = 65536 };                    /* i2t warning */
    enum { WARNING_TEMP = 131072 };                  /* over temperature warning */
    enum { WARNING_ENCODER = 1048576 };              /* encoder warning */
    enum { WARNING_TRACKING = 2097152 };             /* tracking warning */
    enum { WARNING_BYTE = 16711680 };                /* warning byte */
    enum { ERROR_CURRENT = 16777216 };               /* current error */
    enum { ERROR_CONTROLLER = 33554432 };            /* controller error */
    enum { ERROR_ETB_COMM = 67108864 };              /* EB communication error */
    enum { ERROR_TRAJECTORY = 134217728 };           /* trajectory error */
    enum { ERROR_EBL_COMM = 268435456 };             /* EBL communication error */

};
#endif /* DMD_OO_API */


/*
 * status drive 2 - c++
 */
#ifdef DMD_OO_API
class DmdStatus2 {
public:
    enum { SEQ_ERROR = 1 };                          /* sequence error label pending */
    enum { SEQ_WARNING = 2 };                        /* sequence warning label pending */
    enum { BP_WAITING = 16 };                        /* break point waiting */
    enum { USER_0 = 256 };                           /* user bit 0 */
    enum { USER_1 = 512 };                           /* user bit 1 */
    enum { USER_2 = 1024 };                          /* user bit 2 */
    enum { USER_3 = 2048 };                          /* user bit 3 */
    enum { USER_4 = 4096 };                          /* user bit 4 */
    enum { USER_5 = 8192 };                          /* user bit 5 */
    enum { USER_6 = 16384 };                         /* user bit 6 */
    enum { USER_7 = 32768 };                         /* user bit 7 */
    enum { USER_BYTE = 65280 };                      /* user mask */

};
#endif /* DMD_OO_API */


/*
 * current loop adc resolution - c++
 */
#ifdef DMD_OO_API
class DmdCurrentAdc {
public:
    enum { BITS_12 = 0 };                            /* 12 bits */
    enum { BITS_14 = 1 };                            /* 14 bits */

};
#endif /* DMD_OO_API */


/*
 * current LKT mode - c++
 */
#ifdef DMD_OO_API
class DmdLktMode {
public:
    enum { FINE_ADJUST = 1 };                        /* fine phase adjustment */
    enum { ROLLOVER = 2 };                           /* rollover counter */

};
#endif /* DMD_OO_API */


/*
 * monitoring register number - c++
 */
#ifdef DMD_OO_API
class DmdMonitorDest {
public:
    enum { X_AOUT_1 = 173 };                         /* extended analog output 1 */
    enum { X_AOUT_2 = 174 };                         /* extended analog output 2 */
    enum { AOUT_1 = 175 };                           /* analog output 1 */

};
#endif /* DMD_OO_API */


/*
 * flash operations - c++
 */
#ifdef DMD_OO_API
class DmdFlash {
public:
    enum { ALL = 0 };                                /* all */
    enum { SEQ_LKT = 1 };                            /* sequence and user LKT */
    enum { OTHER_PARAMS = 2 };                       /* other parameters */

};
#endif /* DMD_OO_API */


/*
 * master modes - c++
 */
#ifdef DMD_OO_API
class DmdMaster {
public:
    enum { EXIT = 0 };                               /* exit master mode */
    enum { MASTER = 1 };                             /* enter master mode */
    enum { BRIDGE = 2 };                             /* enter bridge mode */
    enum { MASTER_AR = 3 };                          /* enter master mode w/auto-recovery */
    enum { BRIDGE_AR = 4 };                          /* enter bridge mode w/auto-recovery */
    enum { SPY = 255 };                              /* enter spy mode */

};
#endif /* DMD_OO_API */


/*
 * automatic operations - c++
 */
#ifdef DMD_OO_API
class DmdAuto {
public:
    enum { CURRENT_LOOP = 1 };                       /* tune current loop */
    enum { PHASE_CORRECTION = 2 };                   /* set motor phase correction */
    enum { PHASE_ADJUSTMENT = 8 };                   /* tune fine phase adjustment */
    enum { POSITION_LOOP = 16 };                     /* tune regulator parameters */

};
#endif /* DMD_OO_API */


/*
 * breakpoint commands - c++
 */
#ifdef DMD_OO_API
class DmdBreakpoint {
public:
    enum { SET = 1 };                                /* set breakpoint */
    enum { CLEAR = 2 };                              /* clear breakpoint */
    enum { SET_ALL = 3 };                            /* set all breakpoints */
    enum { CLEAR_ALL = 4 };                          /* clear all breakpoints */
    enum { GLOBAL = 5 };                             /* set global breakpoint */

};
#endif /* DMD_OO_API */


/*
 * continue commands - c++
 */
#ifdef DMD_OO_API
class DmdContinue {
public:
    enum { CLEAR = 0 };                              /* clear breakpoint counter */
    enum { STEP = 1 };                               /* step after breakpoint */

};
#endif /* DMD_OO_API */


/*
 * download options - c++
 */
#ifdef DMD_OO_API
class DmdDownload {
public:
    enum { PASS_THROUGH = 170 };                     /* enter EBL/EB pass trough mode */
    enum { DIRECT = 255 };                           /* enter download mode */

};
#endif /* DMD_OO_API */


/*
 * reboot option - c++
 */
#ifdef DMD_OO_API
class DmdShutdown {
public:
    enum { MAGIC = 255 };                            /* magic number */

};
#endif /* DMD_OO_API */


/*
 * setpoint buffer mask - c++
 */
#ifdef DMD_OO_API
class DmdSetpoint {
public:
    enum { TARGET_POSITION = 1 };                    /* target position */
    enum { PROFILE_VELOCITY = 2 };                   /* profile velocity */
    enum { PROFILE_ACCELERATION = 4 };               /* profile acceleration */
    enum { JERK_FILTER_TIME = 8 };                   /* jerk filter time */
    enum { PROFILE_DECELERATION = 16 };              /* profile deceleration */
    enum { END_VELOCITY = 32 };                      /* end velocity */
    enum { PROFILE_TYPE = 64 };                      /* profile type */
    enum { MVT_LKT_NUMBER = 128 };                   /* lookup table number */
    enum { MVT_LKT_TIME = 256 };                     /* lookup table time */
    enum { MVT_LKT_AMPLITUDE = 512 };                /* movement lookup table amplitude */
    enum { MVT_DIRECTION = 1024 };                   /* movement direction */

};
#endif /* DMD_OO_API */


/*
 * trace trigger mode - c++
 */
#ifdef DMD_OO_API
class DmdTraceTrigger {
public:
    enum { NONE = 0 };                               /* no trigger */
    enum { MVT_START = 1 };                          /* start of movement */
    enum { MVT_END = 2 };                            /* end of movement */
    enum { POSITION = 3 };                           /* specified position */
    enum { VALUE_1 = 4 };                            /* value on first channel */

};
#endif /* DMD_OO_API */


/*
 * fast interrupt time - c++
 */
#ifdef DMD_OO_API
class DmdFastInterrupt {
public:
    enum { SYNCHRO = 4 };                            /* PWM synchronization */
    enum { U_166 = 0 };                              /* 166 us */
    enum { U_125 = 1 };                              /* 125 us */
    enum { U_83 = 2 };                               /* 83 us */

};
#endif /* DMD_OO_API */


/*
 * rotary movement direction - c++
 */
#ifdef DMD_OO_API
class DmdMovementDir {
public:
    enum { POSITIVE = 0 };                           /* positive movement */
    enum { NEGATIVE = 1 };                           /* negative movement */
    enum { SHORTEST = 2 };                           /* shortest movement */

};
#endif /* DMD_OO_API */


/*
 * concatenated mode - c++
 */
#ifdef DMD_OO_API
class DmdConcatMode {
public:
    enum { DISABLED = 0 };                           /* concatened movement disabled */
    enum { ENABLED = 1 };                            /* concatened movement enabled */
    enum { LKT_ONLY = 2 };                           /* concatened movement enabled for LKT */

};
#endif /* DMD_OO_API */


/*
 * LKT selection mode - c++
 */
#ifdef DMD_OO_API
class Dmdx45 {
public:
    enum { X0 = 0 };                                 /* the start and target position of the LKT is not the same */
    enum { X1 = 1 };                                 /* the start and target position of the LKT is the same */

};
#endif /* DMD_OO_API */


/*
 * fuse status - c++
 */
#ifdef DMD_OO_API
class DmdFuseStatus {
public:
    enum { F3_FUSE = 1 };                            /* fuse F3 dead */
    enum { F7_FUSE = 2 };                            /* fuse F7 dead */

};
#endif /* DMD_OO_API */


/*
 * SLS selection mode - c++
 */
#ifdef DMD_OO_API
class DmdSlsMode {
public:
    enum { NEGATIVE_MVT = 1 };                       /* begin by negative movement */
    enum { MECHANICAL = 0 };                         /* mechanical end stop */
    enum { LIMIT_SW = 2 };                           /* limit switch */

};
#endif /* DMD_OO_API */


/*
 * profile buffer - c++
 */
#ifdef DMD_OO_API
class DmdProfileBuffer {
public:
    enum { IMMEDIATE = 0 };                          /* immediate */
    enum { BUFFER_1 = 1 };                           /* buffer 1 */
    enum { BUFFER_2 = 2 };                           /* buffer 2 */
    enum { BUFFER_3 = 3 };                           /* buffer 3 */

};
#endif /* DMD_OO_API */


/*
 * monitor channel - c++
 */
#ifdef DMD_OO_API
class DmdMonitor {
public:
    enum { CHANNEL_0 = 0 };                          /* channel 0 */
    enum { CHANNEL_1 = 1 };                          /* channel 1 */

};
#endif /* DMD_OO_API */


/*
 * sequence buffer subindex - c++
 */
#ifdef DMD_OO_API
class DmdSequence {
public:
    enum { HEADER = 0 };                             /* header */
    enum { PARAMETER_1 = 1 };                        /* parameter 1 */
    enum { PARAMETER_2 = 2 };                        /* parameter 2 */

};
#endif /* DMD_OO_API */


/*
 * realtime table - c++
 */
#ifdef DMD_OO_API
class DmdRealtime {
public:
    enum { HEADER = 0 };                             /* header */
    enum { PARAMETER_1 = 1 };                        /* parameter 1 */
    enum { PARAMETER_2 = 2 };                        /* parameter 2 */
    enum { PARAMETER_3 = 3 };                        /* parameter 3 */

};
#endif /* DMD_OO_API */


/*
 * realtime header - c++
 */
#ifdef DMD_OO_API
class DmdRealtimeHeader {
public:
    enum { STATUS_MASK = -16777216 };                /* status mask */
    enum { TYPE_MASK = 255 };                        /* type mask */
    enum { LABEL_MASK = 65280 };                     /* label mask */
    enum { CLEAR_WAIT_MODE = 65536 };                /* clear wait mode */
    enum { MODE_MASK = 16711680 };                   /* mode mask */
    enum { VALID_STATUS = 16777216 };                /* valid status */
    enum { ACTIVE_STATUS = 33554432 };               /* active status */
    enum { ENABLE_STATUS = 67108864 };               /* enable status */
    enum { WAITING_CMD_STATUS = 134217728 };         /* waiting command status */
    enum { NO_OPERATION = 0 };                       /* no operation */
    enum { BIT_COPY = 2 };                           /* bit copy */
    enum { BIT_TEST = 3 };                           /* bit test */
    enum { MASK_TEST = 4 };                          /* mask test */
    enum { REGISTER_TEST = 20 };                     /* register test */
    enum { REGISTER_COMPARE = 21 };                  /* register compare */
    enum { SIMPLE_CLOCK = 40 };                      /* simple clock */

};
#endif /* DMD_OO_API */


/*
 * trigger table - c++
 */
#ifdef DMD_OO_API
class DmdTrigger {
public:
    enum { HEADER = 0 };                             /* header */
    enum { OUT_MASK = 1 };                           /* output mask */
    enum { SW_MASK = 2 };                            /* status mask */
    enum { POSITION = 3 };                           /* position */

};
#endif /* DMD_OO_API */


/*
 * trigger header - c++
 */
#ifdef DMD_OO_API
class DmdTriggerHeader {
public:
    enum { TYPE_MASK = 255 };                        /* trigger type */
    enum { ACTION_MASK = 16711680 };                 /* trigger action */
    enum { NO_OPERATION = 0 };                       /* no operation */
    enum { DISABLED = 128 };                         /* disabled */
    enum { POSITIVE = 129 };                         /* positive */
    enum { NEGATIVE = 130 };                         /* negative */
    enum { BIDIRECTIONAL = 131 };                    /* bidirectional */
    enum { SET_OUT_SW = 65536 };                     /* set output and user sw */

};
#endif /* DMD_OO_API */


/*
 * trace buffer - c++
 */
#ifdef DMD_OO_API
class DmdTrace {
public:
    enum { BUFFER_0 = 0 };                           /* buffer 0 */
    enum { BUFFER_1 = 1 };                           /* buffer 1 */

};
#endif /* DMD_OO_API */


/*
 * hall lookup table - c++
 */
#ifdef DMD_OO_API
class DmdHallLkt {
public:
    enum { LKT_0 = 0 };                              /* lookup table 0 */
    enum { LKT_1 = 1 };                              /* lookup table 1 */
    enum { LKT_2 = 2 };                              /* lookup table 2 */
    enum { LKT_3 = 3 };                              /* lookup table 3 */
    enum { LKT_4 = 4 };                              /* lookup table 4 */
    enum { LKT_5 = 5 };                              /* lookup table 5 */
    enum { LKT_6 = 6 };                              /* lookup table 6 */
    enum { LKT_7 = 7 };                              /* lookup table 7 */

};
#endif /* DMD_OO_API */


/*
 * interrupt edge - c++
 */
#ifdef DMD_OO_API
class DmdInterruptEdge {
public:
    enum { POSITIVE = 0 };                           /* positive */
    enum { NEGATIVE = 1 };                           /* negative */

};
#endif /* DMD_OO_API */


/*
 * test mode - c++
 */
#ifdef DMD_OO_API
class DmdTestMode {
public:

};
#endif /* DMD_OO_API */


/*
 * Dmd Commands Numbers - c++
 */
#ifdef DMD_OO_API
class DmdCommands {
    /*
     * public constants
     */
public:
    enum { ACKNOWLEDGE_INTERRUPT = 118 };            /* acknowledge interrupt */
    enum { ADD_ACC = 161 };                          /* Adds accumulator */
    enum { ADD_REGISTER = 91 };                      /* Adds register */
    enum { AND_ACC = 165 };                          /* And accumulator */
    enum { AND_NOT_ACC = 167 };                      /* And not accumulator */
    enum { AND_NOT_REGISTER = 97 };                  /* And not register */
    enum { AND_REGISTER = 95 };                      /* And register */
    enum { AUTO_CONFIG_CL = 150 };                   /* Auto config current loop */
    enum { CALL_SUBROUTINE = 68 };                   /* Calls subroutine */
    enum { CAN_COMMAND_1 = 250 };                    /* can command 1 */
    enum { CAN_COMMAND_2 = 251 };                    /* can command 2 */
    enum { CHANGE_AXIS = 109 };                      /* Changes axis */
    enum { CHANGE_POWER = 124 };                     /* Changes power */
    enum { CLEAR_CALL_STACK = 34 };                  /* Clears call stack */
    enum { CLEAR_PENDING_ERROR = 50 };               /* Clear pending error */
    enum { CLEAR_PENDING_WARNING = 51 };             /* clear pending warning */
    enum { CLEAR_TRIGGER_TABLE = 107 };              /* Clears trigger table */
    enum { CLEAR_USER_VAR = 17 };                    /* Clears user variable */
    enum { CONV_REGISTER = 122 };                    /* Converts between int and float */
    enum { DEFINE_EMPTY_TRIGGER = 108 };             /* define empty trigger */
    enum { DEFINE_LABEL = 27 };                      /* Defines a label */
    enum { DEFINE_NEG_TRIGGER = 106 };               /* define negative trigger */
    enum { DEFINE_POS_TRIGGER = 105 };               /* define positive trigger */
    enum { DIVIDE_ACC = 163 };                       /* Divides accumulator */
    enum { DIVIDE_REGISTER = 94 };                   /* Divides register */
    enum { DRIVE_NEW = 78 };                         /* Drive new */
    enum { DRIVE_RESTORE = 49 };                     /* Drive restore */
    enum { DRIVE_SAVE = 48 };                        /* Drive save */
    enum { EDIT_SEQUENCE = 62 };                     /* Edit sequence */
    enum { ENABLE_RTI = 183 };                       /* realtime enable when seq_on 0 */
    enum { ENTER_DOWNLOAD = 42 };                    /* Enter download mode */
    enum { EXIT_SEQUENCE = 63 };                     /* Exit sequence */
    enum { FLOAT_COS = 223 };                        /* Executes command cos */
    enum { FLOAT_FRAC_PART = 225 };                  /* Executes command frac_part */
    enum { FLOAT_INT_PART = 226 };                   /* Executes command int_part */
    enum { FLOAT_INV = 221 };                        /* Executes command inv */
    enum { FLOAT_SIGN = 224 };                       /* Executes command sign */
    enum { FLOAT_SIN = 222 };                        /* Executes command sin */
    enum { FLOAT_SQRT = 220 };                       /* Executes command sqrt */
    enum { FLOAT_TEST = 227 };                       /* Executes command test */
    enum { HARDWARE_RESET = 600 };                   /* hardware reset */
    enum { HOMING_START = 45 };                      /* Homing start */
    enum { HOMING_SYNCHRONISED = 41 };               /* Synchronized homing */
    enum { IF_EQUAL = 151 };                         /* Jumps if par1 == XAC */
    enum { IF_GREATER = 154 };                       /* Jumps if par1 > XAC */
    enum { IF_GREATER_OR_EQUAL = 156 };              /* Jumps if par1 >= XAC */
    enum { IF_LOWER = 153 };                         /* Jumps if par1 < XAC */
    enum { IF_LOWER_OR_EQUAL = 155 };                /* Jumps if par1 <= XAC */
    enum { IF_NOT_EQUAL = 152 };                     /* Jumps if par1 != XAC */
    enum { INI_START = 44 };                         /* Initialization start */
    enum { INPUT_START_MVT = 33 };                   /* Starts mvt on input */
    enum { INVERT_REGISTER = 174 };                  /* Inverts register */
    enum { IPOL_BEGIN = 553 };                       /* enter to interpolated mode */
    enum { IPOL_BEGIN_CONCATENATION = 1030 };        /* start the concatenation */
    enum { IPOL_CIRCLE_CCW_C2D = 1041 };             /* add circular segment to trajectory */
    enum { IPOL_CIRCLE_CCW_R2D = 1027 };             /* add circular segment to trajectory */
    enum { IPOL_CIRCLE_CW_C2D = 1040 };              /* add circular segment to trajectory */
    enum { IPOL_CIRCLE_CW_R2D = 1026 };              /* add circular segment to trajectory */
    enum { IPOL_CONTINUE = 654 };                    /* restart interpolation after a quick stop */
    enum { IPOL_END = 554 };                         /* leave the interpolated mode */
    enum { IPOL_END_CONCATENATION = 1031 };          /* stop the concatenation */
    enum { IPOL_LINE = 1025 };                       /* add linear segment to trajectory */
    enum { IPOL_LKT = 1032 };                        /* add lkt segment to trajectory */
    enum { IPOL_LOCK = 1044 };                       /* lock the trajectory execution */
    enum { IPOL_MARK = 1039 };                       /* put  mark in the trajectory */
    enum { IPOL_PUSH = 1279 };                       /* push parameters for ipol commands */
    enum { IPOL_PVT = 1028 };                        /* add pvt segment to trajectory */
    enum { IPOL_PVT_UPDATE = 662 };                  /* Updates registers for PVT trajectory */
    enum { IPOL_RESET = 652 };                       /* reset interpolation */
    enum { IPOL_SET = 552 };                         /* set the interpolation axis */
    enum { IPOL_STOP_EMCY = 656 };                   /* stop interpolation emergency */
    enum { IPOL_STOP_SMOOTH = 653 };                 /* stop interpolation smooth */
    enum { IPOL_TAN_ACCELERATION = 1036 };           /* add acceleration modification to trajectory */
    enum { IPOL_TAN_DECELERATION = 1037 };           /* add deceleration modification to trajectory */
    enum { IPOL_TAN_JERK_TIME = 1038 };              /* add jerk time modification to trajectory */
    enum { IPOL_TAN_VELOCITY = 1035 };               /* add speed modification to trajectory */
    enum { IPOL_UNLOCK = 655 };                      /* unlock the trajectory execution */
    enum { IPOL_WAIT_TIME = 1029 };                  /* wait before continue the trajectory */
    enum { JUMP_BIT_CLEAR = 37 };                    /* Jump bit clear */
    enum { JUMP_BIT_SET = 36 };                      /* Jump bit set */
    enum { JUMP_LABEL = 26 };                        /* Jumps to label */
    enum { MASTER_MODE = 143 };                      /* master mode */
    enum { MULTIPLY_ACC = 162 };                     /* Multiplies accumulator */
    enum { MULTIPLY_REGISTER = 93 };                 /* Multiplies register */
    enum { OR_ACC = 164 };                           /* Or accumulator */
    enum { OR_NOT_ACC = 166 };                       /* Or not accumulator */
    enum { OR_NOT_REGISTER = 98 };                   /* Or not register */
    enum { OR_REGISTER = 96 };                       /* Or register */
    enum { PURGE = 190 };                            /* purge */
    enum { PUSH = 255 };                             /* Push parameters */
    enum { REALTIME_DISABLE = 176 };                 /* Real-time disable */
    enum { REALTIME_ENABLE = 175 };                  /* Real-time enable */
    enum { RESET_BUS = 87 };                         /* reset bus */
    enum { RESET_DRIVE = 88 };                       /* Resets drive */
    enum { RESET_ERROR = 79 };                       /* Resets error */
    enum { RESET_TRIGGER = 104 };                    /* reset trigger */
    enum { SEARCH_LIMIT_STROKE = 46 };               /* Searches limit stroke */
    enum { SET_DEBUG_TIMEOUT = 180 };                /* set debug timeout */
    enum { SET_GROUP_MASK = 40 };                    /* set group mask */
    enum { SET_GUARD_TIMEOUT = 181 };                /* set guard timeout */
    enum { SET_REGISTER = 123 };                     /* Sets register */
    enum { SET_USER_POSITION = 22 };                 /* Sets user position */
    enum { SHIFT_LEFT_ACC = 169 };                   /* Shift left accumulator */
    enum { SHIFT_LEFT_REGISTER = 173 };              /* Shift left register */
    enum { SHIFT_RIGHT_ACC = 168 };                  /* Shift right accumulator */
    enum { SHIFT_RIGHT_REGISTER = 172 };             /* Shift right register */
    enum { START_MVT = 25 };                         /* Starts movement */
    enum { STEP_ABSOLUTE = 129 };                    /* Absolute step */
    enum { STEP_NEGATIVE = 115 };                    /* Negative step */
    enum { STEP_POSITIVE = 114 };                    /* Positive step */
    enum { STOP_MOTOR_EMCY = 18 };                   /* Emergency stop */
    enum { STOP_MOTOR_SMOOTH = 70 };                 /* Stops motor smoothly */
    enum { STOP_SEQ_MOTOR_EMCY = 120 };              /* Stops seq motor emergency */
    enum { STOP_SEQ_MOTOR_SMOOTH = 121 };            /* Stops seq motor smooth */
    enum { STOP_SEQ_POWER_OFF = 119 };               /* Stops seq power off */
    enum { STOP_SEQUENCE = 0 };                      /* Stops sequence */
    enum { SUBROUTINE_RETURN = 69 };                 /* Subroutine return */
    enum { SUBSTRACT_ACC = 160 };                    /* Substracts accumulator */
    enum { SUBSTRACT_REGISTER = 92 };                /* Substracts register */
    enum { SYNCRO_START_MVT = 35 };                  /* syncro start mvt */
    enum { WAIT_AXIS_BUSY = 13 };                    /* Waits for end of axis busy */
    enum { WAIT_BIT_CLEAR = 54 };                    /* Wait bit clear */
    enum { WAIT_BIT_SET = 55 };                      /* Wait bit set */
    enum { WAIT_BUSY = 148 };                        /* wait busy */
    enum { WAIT_GREATER = 53 };                      /* Wait greater */
    enum { WAIT_IN_WINDOW = 11 };                    /* Waits in window */
    enum { WAIT_LOWER = 52 };                        /* Wait lower */
    enum { WAIT_MARK = 513 };                        /* wait until the movement reach a mark */
    enum { WAIT_MOVEMENT = 8 };                      /* Waits for movement */
    enum { WAIT_POSITION = 9 };                      /* Waits for position */
    enum { WAIT_TH_SPEED = 12 };                     /* wait theoretical speed */
    enum { WAIT_TIME = 10 };                         /* Waits for time */
    enum { WAITING_REC_04 = 254 };                   /* waiting record 04 */
    enum { WAITING_REC_12 = 252 };                   /* waiting record 12 */
    enum { WAITING_REC_14 = 253 };                   /* waiting record 14 */

};
#endif /* DMD_OO_API */

/*
 * Dmd Parameters Numbers - c++
 */
#ifdef DMD_OO_API
class DmdParameters {
    /*
     * public constants
     */
public:
    enum { ANALOG_OUTPUT = 175 };                    /* analog output */
    enum { ANR_MAX_POSITION = 219 };                 /* anr maximum position */
    enum { ANR_MAX_VOLTAGE = 218 };                  /* anr maximum voltage */
    enum { ANR_MIN_POSITION = 217 };                 /* anr minimum position */
    enum { ANR_MIN_VOLTAGE = 216 };                  /* anr minimum voltage */
    enum { APR_INPUT_FILTER = 24 };                  /* apr input filter */
    enum { BRAKE_DECELERATION = 206 };               /* Brake deceleration */
    enum { CAME_VALUE = 205 };                       /* Came value */
    enum { CL_ADC_BITS = 49 };                       /* current loop adc bits */
    enum { CL_CURRENT_LIMIT = 83 };                  /* Current loop overcurrent limit */
    enum { CL_I2T_CURRENT_LIMIT = 84 };              /* Curr. loop i2t rms current limit */
    enum { CL_I2T_TIME_LIMIT = 85 };                 /* Current loop i2t time limit */
    enum { CL_INPUT_FILTER = 10 };                   /* current loop input filter */
    enum { CL_INTEGRATOR_GAIN = 81 };                /* Current loop integrator gain */
    enum { CL_OUTPUT_FILTER = 82 };                  /* Current loop output filter */
    enum { CL_PHASE_ADVANCE_FACTOR = 23 };           /* phase advance factor */
    enum { CL_PHASE_ADVANCE_SHIFT = 25 };            /* current loop phase advance shift */
    enum { CL_PROPORTIONAL_GAIN = 80 };              /* Current loop proportional gain */
    enum { CL_REGEN_MODE = 86 };                     /* current loop regeneration mode */
    enum { CONCATENATED_MVT = 201 };                 /* Concatenated movement selection */
    enum { CTRL_GAIN = 224 };                        /* Control source gain */
    enum { CTRL_OFFSET = 223 };                      /* Control source offset */
    enum { CTRL_SHIFT_FACTOR = 222 };                /* Control source shift factor */
    enum { CTRL_SOURCE_INDEX = 221 };                /* Control source index */
    enum { CTRL_SOURCE_TYPE = 220 };                 /* Control source type */
    enum { CUSTOM_SETTINGS_VERSION = 245 };          /* customer settings version */
    enum { DIGITAL_OUTPUT = 171 };                   /* Digital outputs */
    enum { DISPLAY_MODE = 66 };                      /* Display mode */
    enum { DRIVE_CONTROL_MODE = 61 };                /* Reference mode */
    enum { DRIVE_FAST_SEQ_MODE = 63 };               /* drive fast execution seq.mode */
    enum { DRIVE_FUSE_CHECKING = 140 };              /* drive fuse checking */
    enum { DRIVE_NAME = 244 };                       /* Drive name */
    enum { DRIVE_PL_CYCLE_TIME = 88 };               /* Int pos ctrl 0=166,1=125,2=83us */
    enum { DRIVE_SLS_MODE = 145 };                   /* Searches limit stroke (SLS) mode */
    enum { DRIVE_SP_FACTOR = 64 };                   /* drive SP calculator factor */
    enum { EBL_BAUDRATE = 195 };                     /* etel-bus-lite baudrate */
    enum { EBL_INTRA_FRAME_TIMEOUT = 196 };          /* EBL intra-frame timeout */
    enum { ENABLE_INPUT_MODE = 33 };                 /* Enables input mode */
    enum { ENCODER_HALL_PHASE_ADJ = 86 };            /* Digital Hall sensor phase adjustment */
    enum { ENCODER_INDEX_DISTANCE = 75 };            /* Distance between two indexes */
    enum { ENCODER_INVERSION = 68 };                 /* Encoder inversion */
    enum { ENCODER_IPOL_SHIFT = 77 };                /* Encoder interp. shift value */
    enum { ENCODER_MOTOR_RATIO = 51 };               /* encoder motor ratio */
    enum { ENCODER_MUL_SHIFT = 78 };                 /* encoder multip.shift value */
    enum { ENCODER_PERIOD = 241 };                   /* Encoder period */
    enum { ENCODER_PHASE_1_FACTOR = 72 };            /* Analog encoder sine factor */
    enum { ENCODER_PHASE_1_OFFSET = 70 };            /* Analog encoder sine offset */
    enum { ENCODER_PHASE_2_FACTOR = 73 };            /* Analog encoder cosine factor */
    enum { ENCODER_PHASE_2_OFFSET = 71 };            /* Analog encoder cosine offset */
    enum { ENCODER_PHASE_3_FACTOR = 76 };            /* encoder phase 3 factor */
    enum { ENCODER_PHASE_3_OFFSET = 74 };            /* encoder phase 3 offset */
    enum { ENCODER_TURN_FACTOR = 55 };               /* Encoder turn factor */
    enum { ENCODER_TYPE = 79 };                      /* Encoder type selection */
    enum { END_VELOCITY = 215 };                     /* end velocity */
    enum { FOLLOWING_ERROR_WINDOW = 30 };            /* Tracking error limit */
    enum { GANTRY_TYPE = 245 };                      /* Gantry function */
    enum { HOME_OFFSET = 45 };                       /* Offset on absolute position */
    enum { HOMING_ACCELERATION = 42 };               /* Homing acceleration */
    enum { HOMING_CURRENT_LIMIT = 44 };              /* Homing force limit for mech. end stop detection */
    enum { HOMING_FINE_TUNING_MODE = 52 };           /* Homing fine tuning mode */
    enum { HOMING_FINE_TUNING_VALUE = 53 };          /* Homing fine tuning value */
    enum { HOMING_FIXED_MVT = 46 };                  /* Homing movement stroke */
    enum { HOMING_FOLLOWING_LIMIT = 43 };            /* Homing track. limit for mech. end stop detection */
    enum { HOMING_INDEX_MVT = 48 };                  /* Mvt to go out of idx/home switch */
    enum { HOMING_METHOD = 40 };                     /* Homing mode */
    enum { HOMING_SWITCH_MVT = 47 };                 /* Mvt to go out of limit switch or mech. end stop */
    enum { HOMING_ZERO_SPEED = 41 };                 /* Homing speed */
    enum { INDIRECT_AXIS_NUMBER = 197 };             /* indirect axis number */
    enum { INDIRECT_REGISTER_IDX = 198 };            /* Indirect register index */
    enum { INDIRECT_REGISTER_SIDX = 199 };           /* indirect register subindex */
    enum { INIT_CURRENT_RATE = 95 };                 /* initialisation current rate */
    enum { INIT_FINAL_PHASE = 93 };                  /* Initialization final phase */
    enum { INIT_INITIAL_PHASE = 97 };                /* Initialization initial phase */
    enum { INIT_MAX_CURRENT = 92 };                  /* Init. constant current level */
    enum { INIT_MODE = 90 };                         /* Initialization mode */
    enum { INIT_PHASE_RATE = 96 };                   /* initialisation phase rate */
    enum { INIT_PULSE_LEVEL = 91 };                  /* Initialization pulse level */
    enum { INIT_TIME = 94 };                         /* Initialization time */
    enum { INIT_VOLTAGE_RATE = 98 };                 /* Initialization voltage rate */
    enum { INTERRUPT_MASK_1 = 180 };                 /* interrupt mask 1 */
    enum { INTERRUPT_MASK_2 = 181 };                 /* interrupt  mask 2 */
    enum { IO_ERROR_EVENT_MASK = 37 };               /* DOUT mask error event */
    enum { IPOL_CAME_VALUE = 717 };                  /* Interpolation, came value */
    enum { IPOL_LKT_CYCLIC_MODE = 710 };             /* LKT, cyclic mode */
    enum { IPOL_LKT_RELATIVE_MODE = 711 };           /* LKT, relative mode */
    enum { IPOL_LKT_SPEED_RATIO = 700 };             /* LKT, speed ratio of the pointer */
    enum { IPOL_VELOCITY_RATE = 530 };               /* Interpolation, Speed rate */
    enum { JERK_FILTER_TIME = 213 };                 /* Jerk time */
    enum { MAX_ACCELERATION = 29 };                  /* maximum acceleration */
    enum { MAX_POSITION_RANGE_LIMIT = 27 };          /* Maximum position range limit */
    enum { MAX_PROFILE_VELOCITY = 28 };              /* maximum profile velocity */
    enum { MAX_SOFT_POSITION_LIMIT = 35 };           /* Maximum software position limit */
    enum { MEASURE_DRIVE_CL_INT = 234 };             /* Enables timing meas. for curr. int. */
    enum { MEASURE_DRIVE_PL_INT = 235 };             /* Enables timing meas. for slow int. */
    enum { MEASURE_DRIVE_SP_INT = 236 };             /* enable timing meas.for slow Int. */
    enum { MIN_POSITION_RANGE_LIMIT = 26 };          /* minimum position range limit */
    enum { MIN_SOFT_POSITION_LIMIT = 34 };           /* Minimum software position limit */
    enum { MON_DEST_INDEX = 153 };                   /* monitoring destination index */
    enum { MON_DEST_TYPE = 152 };                    /* monitoring destination type */
    enum { MON_GAIN = 155 };                         /* monitoring gain */
    enum { MON_OFFSET = 154 };                       /* monitoring offset */
    enum { MON_SOURCE_INDEX = 151 };                 /* monitoring source index */
    enum { MON_SOURCE_TYPE = 150 };                  /* monitoring source type */
    enum { MOTOR_DIV_FACTOR = 243 };                 /* Motor division factor */
    enum { MOTOR_KT_FACTOR = 239 };                  /* Motor Kt factor */
    enum { MOTOR_MUL_FACTOR = 242 };                 /* Position multiplication factor */
    enum { MOTOR_PHASE_CORRECTION = 56 };            /* Motor phase correction */
    enum { MOTOR_PHASE_NB = 89 };                    /* Motor phase number */
    enum { MOTOR_POLE_NB = 54 };                     /* Motor pole pair number */
    enum { MOTOR_TEMP_CHECKING = 141 };              /* Enables motor time-out TEB error checking */
    enum { MOTOR_TYPE = 240 };                       /* Motor type */
    enum { MVT_DIRECTION = 209 };                    /* Rotary movement type selection */
    enum { MVT_LKT_AMPLITUDE = 208 };                /* Max. stroke for LKT */
    enum { MVT_LKT_NUMBER = 203 };                   /* Look-up table number movement */
    enum { MVT_LKT_TIME = 204 };                     /* Movement look-up table time */
    enum { MVT_LKT_TYPE = 207 };                     /* LKT mode select */
    enum { PDR_STEP_VALUE = 69 };                    /* TTL encoder interp. shift value */
    enum { PL_ACC_FEEDFORWARD_GAIN = 21 };           /* Pos. loop acc. feedforw. gain */
    enum { PL_ACC_FEEDFORWARD_GAIN_PD = 18 };        /* acc.feed forw. in pulse/dir mode */
    enum { PL_ANTI_WINDUP_GAIN = 5 };                /* position loop anti-windup gain */
    enum { PL_FORCE_FEEDBACK_GAIN_1 = 3 };           /* pos.loop force feedback gain 1 */
    enum { PL_FORCE_FEEDBACK_GAIN_2 = 13 };          /* pos. loop force feedback gain 2 */
    enum { PL_INTEGRATOR_GAIN = 4 };                 /* position loop integrator gain */
    enum { PL_INTEGRATOR_LIMITATION = 6 };           /* Pos. loop integrator limitation */
    enum { PL_INTEGRATOR_MODE = 7 };                 /* Position loop integrator mode */
    enum { PL_OUTPUT_FILTER = 9 };                   /* position loop output filter */
    enum { PL_PROPORTIONAL_GAIN = 1 };               /* Position loop proportional gain */
    enum { PL_SPEED_FEEDBACK_GAIN = 2 };             /* Pos. loop speed feedback gain */
    enum { PL_SPEED_FEEDFWD_GAIN = 20 };             /* Pos. loop speed feedforw. gain */
    enum { PL_SPEED_FEEDFWD_GAIN_PD = 17 };          /* speed feed forw.in pulse/dir mode */
    enum { PL_SPEED_FILTER = 8 };                    /* Position loop speed filter */
    enum { PL_SPEED_FILTER_2 = 12 };                 /* speed filter 2 */
    enum { POSITION_WINDOW = 39 };                   /* Position range window */
    enum { POSITION_WINDOW_TIME = 38 };              /* Position window time */
    enum { PROFILE_ACCELERATION = 212 };             /* Absolute max. acc./deceleration */
    enum { PROFILE_DECELERATION = 214 };             /* profile deceleration */
    enum { PROFILE_LIMIT_MODE = 36 };                /* Enables position limit (K34, K35) */
    enum { PROFILE_MUL_SHIFT = 50 };                 /* Profile multiplication shift */
    enum { PROFILE_TYPE = 202 };                     /* Movement type */
    enum { PROFILE_VELOCITY = 211 };                 /* Absolute maximum speed */
    enum { REALTIME_ENABLED_GLOBAL = 190 };          /* RTI global enable */
    enum { REALTIME_ENABLED_MASK = 192 };            /* RTI enabled mask */
    enum { REALTIME_PENDING_MASK = 193 };            /* RTI pending mask */
    enum { REALTIME_VALID_MASK = 191 };              /* RTI valid mask */
    enum { SOFTWARE_CURRENT_LIMIT = 60 };            /* Software force/torque limit */
    enum { SWITCH_LIMIT_MODE = 32 };                 /* Limit/home switch mode */
    enum { SYNCRO_INPUT_MASK = 160 };                /* Syncro input mask */
    enum { SYNCRO_INPUT_VALUE = 161 };               /* Syncro input value */
    enum { SYNCRO_OUTPUT_MASK = 162 };               /* Syncro output mask */
    enum { SYNCRO_OUTPUT_VALUE = 163 };              /* Syncro output value */
    enum { SYNCRO_START_TIMEOUT = 164 };             /* Syncro time-out */
    enum { TARGET_POSITION = 210 };                  /* Target position */
    enum { TRIGGER_IO_MASK = 185 };                  /* Trigger digital output mask */
    enum { TRIGGER_IRQ_MASK = 184 };                 /* User status mask for trigger */
    enum { TRIGGER_MAP_OFFSET = 186 };               /* Trigger mapping number */
    enum { TRIGGER_MAP_SIZE = 187 };                 /* Trigger mapping size */
    enum { TTL_SPECIAL_FILTER = 11 };                /* ttl special filter */
    enum { UFAI_TEN_POWER = 525 };                   /* ufai ten power */
    enum { UFPI_MUL_FACTOR = 522 };                  /* ufpi multiplication factor */
    enum { UFPI_TEN_POWER = 523 };                   /* ufpi ten power */
    enum { UFSI_TEN_POWER = 524 };                   /* ufsi ten power */
    enum { UFTI_TEN_POWER = 526 };                   /* ufti ten power */
    enum { USER_STATUS = 177 };                      /* User status */
    enum { VELOCITY_ERROR_LIMIT = 31 };              /* Velocity error limit */
    enum { X_ANALOG_GAIN = 157 };                    /* extension card analog gain */
    enum { X_ANALOG_OFFSET = 156 };                  /* extension card analog offset */
    enum { X_ANALOG_OUTPUT_1 = 173 };                /* extension card analog output 1 */
    enum { X_ANALOG_OUTPUT_2 = 174 };                /* extension card analog output 2 */
    enum { X_DIGITAL_OUTPUT = 172 };                 /* extension card digital outputs */

};
#endif /* DMD_OO_API */

/*
 * Dmd Monitoring Numbers - c++
 */
#ifdef DMD_OO_API
class DmdMonitoring {
    /*
     * public constants
     */
public:
    enum { ACC_ACTUAL_VALUE = 15 };                  /* real acceleration */
    enum { ACC_DEMAND_VALUE = 14 };                  /* Theoretical acceleration (dai) */
    enum { ACK_DRIVE_STATUS_1 = 162 };               /* acknowledge drive status 1 */
    enum { ACK_DRIVE_STATUS_2 = 163 };               /* acknowledge drive status 2 */
    enum { ANALOG_INPUT = 51 };                      /* analog input */
    enum { AXIS_NUMBER = 87 };                       /* Axis number */
    enum { CAN_FEEDBACK_1 = 250 };                   /* extension card feedback 1 */
    enum { CAN_FEEDBACK_2 = 251 };                   /* extension card feedback 2 */
    enum { CL_ACTUAL_VALUE = 31 };                   /* real force */
    enum { CL_CURRENT_PHASE_1 = 20 };                /* current loop current in phase 1 */
    enum { CL_CURRENT_PHASE_2 = 21 };                /* current loop current in phase 2 */
    enum { CL_CURRENT_PHASE_3 = 22 };                /* current loop current phase 3 */
    enum { CL_DEMAND_VALUE = 30 };                   /* theoretical force */
    enum { CL_I2T_VALUE = 67 };                      /* current loop i2t value */
    enum { CL_LKT_PHASE_1 = 25 };                    /* curr.loop lookup table phase 1 */
    enum { CL_LKT_PHASE_2 = 26 };                    /* curr.loop lookup table phase 2 */
    enum { CL_LKT_PHASE_3 = 27 };                    /* curr.loop lookup table phase 3 */
    enum { DAISY_CHAIN_NUMBER = 88 };                /* daisy chain number */
    enum { DIGITAL_INPUT = 50 };                     /* Digital inputs value */
    enum { DIGITAL_OUTPUT_ACTUAL = 171 };            /* Real state of drive's DOUTs */
    enum { DRIVE_CL_INT_ACTUAL_TIME = 190 };         /* Act. time of process on curr. int. */
    enum { DRIVE_CL_INT_MAX_TIME = 192 };            /* Min. time of process on curr. int. */
    enum { DRIVE_CL_INT_MIN_TIME = 191 };            /* Max. time of process on curr. int. */
    enum { DRIVE_CL_TIME_FACTOR = 243 };             /* Drv curr. loop time factor (cti) */
    enum { DRIVE_CONTROL_MODE_BF = 19 };             /* driver control mode bit-field */
    enum { DRIVE_DISPLAY = 95 };                     /* Display's string */
    enum { DRIVE_FUSE_STATUS = 140 };                /* drive fuse status */
    enum { DRIVE_MASK_VALUE = 93 };                  /* drive mask value */
    enum { DRIVE_MAX_CURRENT = 82 };                 /* Drive maximum current */
    enum { DRIVE_PENDING_BPT = 98 };                 /* pending breakpoints */
    enum { DRIVE_PL_INT_ACTUAL_TIME = 193 };         /* Act. time of process on fast int. */
    enum { DRIVE_PL_INT_MAX_TIME = 195 };            /* Min. time of process on fast int. */
    enum { DRIVE_PL_INT_MIN_TIME = 194 };            /* Max. time of process on fast int. */
    enum { DRIVE_PL_TIME_FACTOR = 244 };             /* Drv fast int. time factor (fti) */
    enum { DRIVE_QUARTZ_FREQUENCY = 242 };           /* Drive quartz frequency [Hz] */
    enum { DRIVE_SEQUENCE_LINE = 96 };               /* Executed sequence's line */
    enum { DRIVE_SEQUENCE_USAGE = 97 };              /* drive sequence buffer usage */
    enum { DRIVE_SP_INT_ACTUAL_TIME = 196 };         /* Act. time of process on slow int. */
    enum { DRIVE_SP_INT_MAX_TIME = 198 };            /* Min. time of process on slow int. */
    enum { DRIVE_SP_INT_MIN_TIME = 197 };            /* Max. time of process on slow int. */
    enum { DRIVE_SP_TIME_FACTOR = 245 };             /* Drv SP calculator time factor */
    enum { DRIVE_STATUS_1 = 60 };                    /* Drive status 1 */
    enum { DRIVE_STATUS_2 = 61 };                    /* Drive status 2 */
    enum { DRIVE_TEMPERATURE = 90 };                 /* drive temperature */
    enum { EB_RUNNING = 89 };                        /* etel-bus running */
    enum { ENCODER_1VPTP_VALUE = 43 };               /* Analog encoder sine^2 + cosine^2 */
    enum { ENCODER_COSINE_SIGNAL = 41 };             /* Analog encoder cosine signal */
    enum { ENCODER_HALL_1_SIGNAL = 45 };             /* encoder hall analog signal 1 */
    enum { ENCODER_HALL_2_SIGNAL = 46 };             /* encoder hall analog signal 2 */
    enum { ENCODER_HALL_3_SIGNAL = 47 };             /* encoder hall analog signal 3 */
    enum { ENCODER_HALL_DIG_SIGNAL = 48 };           /* encoder hall digital signal */
    enum { ENCODER_INDEX_SIGNAL = 42 };              /* encoder index signal */
    enum { ENCODER_IPOL_FACTOR = 241 };              /* Encoder interpolation factor */
    enum { ENCODER_LIMIT_SWITCH = 44 };              /* Encoder limit switch */
    enum { ENCODER_SINE_SIGNAL = 40 };               /* Analog encoder sine signal */
    enum { ERROR_CODE = 64 };                        /* Error code */
    enum { INDIRECT_AXIS_MASK = 94 };                /* drive mask for generic command */
    enum { INFO_BOOT_REVISION = 71 };                /* Soft. boot version of the drive */
    enum { INFO_C_SOFT_BUILD_TIME = 74 };            /* info current software build time */
    enum { INFO_P_SOFT_BUILD_TIME = 75 };            /* position uC software build time */
    enum { INFO_PRODUCT_NUMBER = 70 };               /* Drive type */
    enum { INFO_PRODUCT_STRING = 85 };               /* Article number */
    enum { INFO_SERIAL_NUMBER = 73 };                /* Serial number of the drive */
    enum { INFO_SOFT_VERSION = 72 };                 /* Firmware version of the drive */
    enum { IRQ_DRIVE_STATUS_1 = 160 };               /* interrupt drive status 1 */
    enum { IRQ_DRIVE_STATUS_2 = 161 };               /* interrupt drive status 2 */
    enum { IRQ_PENDING_AXIS_MASK = 164 };            /* interrupt pending axis mask */
    enum { MAX_SLS_POSITION_LIMIT = 37 };            /* Superior pos. after SLS cmd */
    enum { MIN_SLS_POSITION_LIMIT = 36 };            /* Inferior pos. after SLS cmd */
    enum { PDR_ACC_DEMAND_VALUE = 35 };              /* theo.acceleration (pulse/dir) */
    enum { PDR_POSITION_VALUE = 17 };                /* Ref. val. for mode K61=0, 1, 3, 4, 36 */
    enum { PDR_VELOCITY_DEMAND_VALUE = 34 };         /* theoretical speed (pulse/dir) */
    enum { POSITION_ACTUAL_VALUE_DS = 1 };           /* Real pos. w/ scal./map. */
    enum { POSITION_ACTUAL_VALUE_US = 7 };           /* Real pos. w/ SET/scal./map. (upi) */
    enum { POSITION_CTRL_ERROR = 2 };                /* Tracking error */
    enum { POSITION_DEMAND_VALUE_DS = 0 };           /* Theo. pos. w/ scal./map. */
    enum { POSITION_DEMAND_VALUE_US = 6 };           /* Theo. pos. w/ SET/scal./map. (upi) */
    enum { POSITION_MAX_ERROR = 3 };                 /* Max. track. error during move. */
    enum { REF_DEMAND_VALUE = 18 };                  /* reference demand value */
    enum { TEB_NODE_MASK = 512 };                    /* present nodes on TEB */
    enum { VELOCITY_ACTUAL_VALUE = 11 };             /* Real velocity (dsi) */
    enum { VELOCITY_DEMAND_VALUE = 10 };             /* Theoretical velocity (dsi) */
    enum { VELOCITY_SECONDARY_ACTUAL_VALUE = 19 };   /* Second encoder real velocity */
    enum { X_ANALOG_INPUT_1 = 56 };                  /* extension card analog input 1 */
    enum { X_ANALOG_INPUT_2 = 57 };                  /* extension card analog input 2 */
    enum { X_DIGITAL_INPUT = 55 };                   /* extension card digital inputs */
    enum { X_INFO_BOOT_REVISION = 77 };              /* extension card boot revision */
    enum { X_INFO_PRODUCT_NUMBER = 76 };             /* extension card product number */
    enum { X_INFO_PRODUCT_STRING = 86 };             /* extension card product string */
    enum { X_INFO_SERIAL_NUMBER = 79 };              /* extension card serial number */
    enum { X_INFO_SOFT_BUILD_TIME = 80 };            /* extension card soft build time */
    enum { X_INFO_SOFT_VERSION = 78 };               /* extension card soft version */

};
#endif /* DMD_OO_API */

/*
 * Dmd Convert Numbers - c++
 */
#ifdef DMD_OO_API
class DmdConvert {
    /*
     * public constants
     */
public:
    enum { AVI = 40 };                            /* analog voltage increment -8192 <=> 10V  8192 <=> -10V */
    enum { AVI12BIT = 47 };                       /* analog voltage increment 2048 <=>10V   -2048 <=> -10V */
    enum { AVI16BIT = 48 };                       /* analog voltage increment 32767 <=>10V   -32768 <=> -10V */
    enum { BIT0 = 50 };                           /* 2<SUP>0</SUP> = 1 <=> 1.0 */
    enum { BIT10 = 60 };                          /* 2<SUP>10</SUP> = 1024 <=> 1.0 */
    enum { BIT11 = 61 };                          /* 2<SUP>11</SUP> = 2048 <=> 1.0 */
    enum { BIT11_ENCODER = 62 };                  /* Analgog encoder signal amplitude in volt (11 bit) */
    enum { BIT11P2 = 82 };                        /*  */
    enum { BIT15 = 65 };                          /* 2<SUP>15</SUP> = 32768 <=> 1.0 */
    enum { BIT15_ENCODER = 63 };                  /* Analgog encoder signal amplitude in volt (15 bit) */
    enum { BIT15P2 = 83 };                        /*  */
    enum { BIT24 = 74 };                          /* 2<SUP>24</SUP> = 256*65536 <=> 1.0 */
    enum { BIT31 = 81 };                          /* 2<SUP>31</SUP> = 32768*65536 <=> 1.0 */
    enum { BIT5 = 55 };                           /* 2<SUP>5</SUP> = 32 <=> 1.0 */
    enum { BIT8 = 58 };                           /* 2<SUP>8</SUP> = 256 <=> 1.0 */
    enum { BIT9 = 59 };                           /* 2<SUP>9</SUP> = 512 <=> 1.0 */
    enum { BOOL = 1 };                            /* boolean value */
    enum { C13 = 20 };                            /* current 13bit range */
    enum { C14 = 21 };                            /* current 14bit range */
    enum { C15 = 23 };                            /* current 15bit range */
    enum { C29 = 22 };                            /* current 29bit range */
    enum { CTI = 32 };                            /* current loop time increment (41us) */
    enum { CUR = 24 };                            /* current */
    enum { CUR2 = 25 };                           /* i<SUP>2</SUP>, dissipation value */
    enum { CUR2T = 26 };                          /* i<SUP>2</SUP>t, integration value */
    enum { DAI = 17 };                            /* drive acceleration increment */
    enum { DPI = 15 };                            /* drive position increment */
    enum { DSI = 16 };                            /* drive speed increment */
    enum { DWORD = 0 };                           /* double word value without conversion */
    enum { ENCOFF = 42 };                         /* 11bit with 2048 offset */
    enum { EXP10 = 33 };                          /* ten power factor */
    enum { FLOAT = 5 };                           /* float value */
    enum { FTI = 31 };                            /* fast time increment (125us-166us) */
    enum { HSTI = 34 };                           /* half slow time increment */
    enum { INT = 2 };                             /* integer value without conversion */
    enum { K1 = 90 };                             /* pl prop gain, k(A/m) = k1 * Iref * dpi_factor / 2<SUP>29</SUP> */
    enum { K10 = 100 };                           /* 1st order filter in s. */
    enum { K14 = 3 };                             /*  */
    enum { K2 = 92 };                             /* pl speed feedback gain, k(A/(m/s)) = k2 * Iref * dsi_factor / 2<SUP>29</SUP> */
    enum { K20 = 103 };                           /* speed feedback, sec unit (m/(m/s)), F = k20 / 2<SUP>16-k50</SUP> * dsi_factor / dpi_factor */
    enum { K20_DSB = 102 };                       /* speed feedback, sec unit (m/(m/s)), F = k20 / 2<SUP>16-k50</SUP> * dsi_factor / dpi_factor */
    enum { K21 = 105 };                           /* speed feedback, sec unit (m/(m/s<SUP>2</SUP>)), F = k20 / 2<SUP>24-k50</SUP> * dai_factor / dpi_factor */
    enum { K21_DSB = 104 };                       /* speed feedback, sec unit (m/(m/s<SUP>2</SUP>)), F = k20 / 2<SUP>24-k50</SUP> * dai_factor / dpi_factor */
    enum { K23 = 106 };                           /* commutation phase advance period/(m/s) */
    enum { K239 = 124 };                          /* motor Kt factor in mN(m)/A, 1000 <=> 1.0mN(m)/A */
    enum { K4 = 94 };                             /* pl integrator gain, k(A/(m*s)) = k1 * Iref * dpi_factor / 2<SUP>29</SUP> / pl_time */
    enum { K5 = 96 };                             /* anti-windup K[m/A]=K5*4096/(dpi_factor * Iref) */
    enum { K75 = 108 };                           /* encoder multiple index distance, 1/1024 * encoder perion unit */
    enum { K8 = 3 };                              /*  */
    enum { K80 = 110 };                           /* cl prop gain delta[1/A] */
    enum { K81 = 112 };                           /* cl prop integrator delta[1/(A*s)] */
    enum { K82 = 114 };                           /* filter time, T = [cti] * (2<SUP>n</SUP>-1) */
    enum { K9 = 98 };                             /* 1st order filter in pl */
    enum { K94 = 116 };                           /* time in 2x current loop increment */
    enum { K95 = 118 };                           /* current rate for k95 */
    enum { K96 = 120 };                           /* phase rate for k96 */
    enum { KFLOAT = 6 };                          /* float value for K parameters */
    enum { LONG = 3 };                            /* long integer value without conversion */
    enum { M242 = 35 };                           /* quartz frequency in Hz */
    enum { M82 = 28 };                            /* current limit in 10 mA unit, 100 <=> 1.0A */
    enum { MSEC = 88 };                           /* milliseconds */
    enum { PER_100 = 122 };                       /* per cent unit, 100 <=> 1.0 */
    enum { PER_1000 = 123 };                      /* per thousand unit */
    enum { PH11 = 44 };                           /* 2<SUP>11</SUP> = 2048 <=> 360° */
    enum { PH12 = 45 };                           /* 2<SUP>12</SUP> = 4096 <=> 360° */
    enum { PH28 = 46 };                           /* 2<SUP>28</SUP> = 65536*4096 <=> 360° */
    enum { QZTIME = 36 };                         /* interrupt time in sec = inc / m242 */
    enum { SPEC2F = 37 };                         /* filter time, T = [fti] * (2<SUP>n</SUP>-1) */
    enum { STI = 30 };                            /* slow time increment (500us-2ms) */
    enum { STRING = 4 };                          /* packed string value */
    enum { TEMP = 38 };                           /* 2<SUP>0</SUP> = 1 <=> 1.0 */
    enum { UAI = 12 };                            /* acceleration, user acceleration increment */
    enum { UFAI = 87 };                           /* user friendly acceleration increment */
    enum { UFPI = 85 };                           /* user friendly position increment */
    enum { UFSI = 86 };                           /* user friendly speed increment */
    enum { UFTI = 39 };                           /* user friendly time increment */
    enum { UPI = 10 };                            /* user position increment */
    enum { USI = 11 };                            /* user speed increment */
    enum { VOLT = 41 };                           /* 2<SUP>0</SUP> = 1 <=> 1.0 */
    enum { VOLT100 = 43 };                        /* (2<SUP>0</SUP>)/100 = 1 <=> 1.0 */

};
#endif /* DMD_OO_API */

#endif /* _DMD10_H */
