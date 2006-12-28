/*
 * tra10.h 1.00
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
 * This header file contains public declaration of traduction library.\n
 * This library is able to convert a high-level ETEL language command directly into
 * ebl records and vice-versa.\n
 * This library is also able to upload registers and sequences from drive into a 
 * text file and download sequences or registers text-file into the drives.\n
 * This library in conformed to POSIX 1003.1c, and has been ported on the following OS:
 * @li @c WIN32
 * @li @c QNX4
 * @li @c QNX6
 * @li @c LINUX
 * @li @c LYNXOS
 * @li @c SOLARIS SPARC 5
 * @li @c SOLARIS X86
 * @file tra10.h
 */


#ifndef _TRA10_H
#define _TRA10_H

#ifdef __WIN32__		/* defined by Borland C++ Builder */
#ifndef WIN32
#define WIN32
#endif
#endif

#ifdef __cplusplus
#ifdef ETEL_OO_API		/* defined by the user when he need the Object Oriented interface */
#define TRA_OO_API
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
/*** libraries ***/

#include <time.h>
#include <etb10.h>


/*** litterals ***/

#ifndef TRA_OO_API
#define TRA_FLAG_USE_ALIASES            0x00000001   /* parameter are replaced by aliases if possible */
#define TRA_FLAG_REMOVE_UNDEFINED       0x00000002   /* do not includes undefined indexes and subindexes */
#define TRA_FLAG_REMOVE_DEFAULT         0x00000004   /* do not includes values when equal to default value */
#define TRA_FLAG_REMOVE_AXIS            0x00000008   /* do not includes axis when uploading drive parameters */
#define TRA_FLAG_GROUP_SUBINDEXES       0x00000010   /* group identical indexes together */
#define TRA_FLAG_CONVERT_TO_ISO         0x00000020   /* convert uploaded command to iso whenever possible */
#define TRA_FLAG_SORT_REGISTERS         0x00000040   /* sort registers by category when uploading */
#define TRA_FLAG_NO_DEPRECATED          0x00000080   /* generate an error on deprecated commands */
#define TRA_FLAG_NO_EMPTY_LINES         0x00000100   /* generate an error on empty lines */
#define TRA_FLAG_RECEIVE_REWRITE        0x00000200   /* rewrite the command in the receive fct */
#define TRA_FLAG_RELAX_DRV_CHECK		0x00000800   /* allow the use of unknowed drv version */ 
#define TRA_FLAG_RELAX_EXT_CHECK        0x00001000   /* don't take extension card state into account */
#define TRA_FLAG_DISABLE_CHECKS         0x00002000   /* disable all checks */
#define TRA_FLAG_DISABLE_EDITMODE       0x00004000   /* disable setting drive in edit mode for downloading */
#define TRA_FLAG_COMMENT_NONE           0x00010000   /* don't insert any comment in uploaded files */
#define TRA_FLAG_COMMENT_VERBOSE        0x00020000   /* insert lots of comment in uploaded files */
#define TRA_FLAG_COMMENT_LINE           0x00040000   /* add a comment describing each line */
#define TRA_FLAG_USE_TAB_4              0x00100000   /* use one tab for 4 colums */
#define TRA_FLAG_USE_TAB_8              0x00200000   /* use one tab for 8 colums */
#define TRA_FLAG_USE_TAB_SINGLE			0x00400000   /* use one tab before comments */
#define TRA_FLAG_ALL_SUBINDEXES			0x01000000   /* get all register subindexes when uploading */
#define TRA_FLAG_RESTRICT_DEST_CHECK	0x02000000   /* alias.! syntax will be check only on destination axis mask (instead of present axis mask) */
#endif /* TRA_OO_API */

#ifndef TRA_OO_API
#define TRA_SKIP_SYSTEM                 0x00000001   /* skip system parameters on register download */
#define TRA_SKIP_NON_SYSTEM             0x00000002   /* skip non-system parameters on register download */
#endif /* TRA_OO_API */


/*
 * error codes - c
 */
#ifndef TRA_OO_API
#define TRA_ENOINT                       -570        /**< int value not allowed in this context */
#define TRA_ENOFLOAT                     -569        /**< float value not allowed in this context */
#define TRA_ENODRIVE                     -568        /**< the specified drive is not present */
#define TRA_ERDONLY                      -567        /**< attempting to write a read-only register */
#define TRA_ENOPARAM                     -566        /**< too many parameters in this command */
#define TRA_ENOISO                       -565        /**< iso value not allowed in this context */
#define TRA_ECONVERT                     -564        /**< iso conversion failed */
#define TRA_EENUM                        -563        /**< the given value is not part of the enumeration */
#define TRA_EOUTOFRANGE                  -562        /**< parameter out of range */
#define TRA_ESYNTAX                      -561        /**< syntax error in the command */
#define TRA_EEMPTY                       -560        /**< the command is empty */
#define TRA_EDEPRECATED                  -558        /**< the command or register is deprecated */
#define TRA_EBADSTREAM                   -553        /**< bad format of input stream */
#define TRA_EBADMSG                      -552        /**< bad response from etel bus */
#define TRA_EGETREC                      -551        /**< cannot get a response through etel-bus port */
#define TRA_EPUTREC                      -550        /**< cannot send a request through etel-bus port */
#define TRA_EMULTIREC                    -541        /**< bad multiple record command */
#define TRA_ENOTEXIST                    -540        /**< the requested register/command does not exist */
#define TRA_ENOCOMMAND                   -525        /**< no command available now */
#define TRA_ETOOSMALL                    -524        /**< record buffer too small */
#define TRA_EGETINFO                     -523        /**< error while getting drive information */
#define TRA_EBADSTATE                    -522        /**< this operation is not allowed in this state */
#define TRA_EBADEXTPROD                  -521        /**< an unknown extention card product has been specified */
#define TRA_EBADDRVPROD                  -520        /**< an unknown drive product has been specified */
#define TRA_EBADEXTVER                   -519        /**< an extention card with an incompatible version has been specified */
#define TRA_EBADDRVVER                   -518        /**< a drive with an incompatible version has been specified */
#define TRA_EBADPARAM                    -515        /**< one of the parameter is not valid */
#define TRA_EDRV                         -513        /**< the drive is in error state */
#define TRA_ENOACK                       -512        /**< no acknowledge from the drive */
#define TRA_ESYSTEM                      -511        /**< some system resource return an error */
#define TRA_EINTERNAL                    -510        /**< some internal error in the etel software */


/* TRA_ERANGE becomes TRA_EOUTOFRANGE because C++ ERANGE is already defined in math.h */
/* For C interface, we define manually TRA_ERANGE to be compatible with before */
#define TRA_ERANGE TRA_EOUTOFRANGE
#endif /* TRA_OO_API */



/*
 * destinations 
 */
#ifndef TRA_OO_API
#define TRA_DEST_EXPLICIT				   0		   /* destination is specified by an explicit mask */
#define TRA_DEST_MSK					   1		   /* destination is specified by a '.%' */
#define TRA_DEST_Z						   2           /* destination is specified by a '.Z. */
#endif /* TRA_OO_API */


/*** macros ***/

#ifndef ETEL_NO_P_MACROS
#define _TRA_P1(p)                       p
#define TRA_P1(p)                        p
#define _TRA_P2(p)                       p,
#define TRA_P2(p)                        p,
#endif

/*** types ***/

/* 
 * type modifiers
 */
#ifdef WIN32
#define _TRA_EXPORT __cdecl                          /* function exported by static library */
#define TRA_CALLBACK __cdecl                         /* client callback function called by library */
#endif /* WIN32 */

#ifdef QNX4
#define _TRA_EXPORT __cdecl                          /* function exported by the library */
#define TRA_CALLBACK __cdecl                         /* client callback function called by library */
#endif /* QNX4 */

#ifdef POSIX
#define _TRA_EXPORT                           /* function exported by the library */
#define TRA_CALLBACK                          /* client callback function called by library */
#endif /* POSIX */

/*
 * pointer to ETB_PORT
 */
typedef ETB_PORT *TRA_ETB_PORT_P;

/* 
 * hidden structures for library clients
 */
#ifndef TRA
#define TRA void
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


typedef int TRA_CALLBACK TRA_LINE_READER(TRA *tra, char *buffer, int max, void *stream);
typedef int TRA_CALLBACK TRA_LINE_WRITER(TRA *tra, const char *buffer, void *stream, ETB_REC recs[], int n_rec);
typedef int TRA_CALLBACK TRA_ISO_CONVERTER(TRA *tra, long *incr, double *iso, int conv, int axis, bool to_iso, void *user);


/*** prototypes ***/

/*
 * general functions
 */
dword   _TRA_EXPORT tra_get_version(void);
dword   _TRA_EXPORT tra_get_edi_version(void);
time_t  _TRA_EXPORT tra_get_build_time(void);
char_cp _TRA_EXPORT tra_translate_error(int code);
void    _TRA_EXPORT tra_version_to_string(char *buffer, int max, dword version);

/*
 * register traductor (offline)
 */
bool    _TRA_EXPORT tra_is_valid_register_traductor(TRA *tra);
int     _TRA_EXPORT tra_create_register_traductor_o(TRA **tra, int d_prod, dword d_ver, int x_prod, dword x_ver, dword flags);
int     _TRA_EXPORT tra_create_register_traductor_o2(TRA **tra, int d_prod, dword d_ver, int x_prod, dword x_ver,
					   int d_prod2, dword d_ver2, int x_prod2, dword x_ver2, dword flags);

/*
 * register traductor (etb extension/subclass)
 */
bool    _TRA_EXPORT tra_is_valid_register_traductor_e(TRA *tra);
int     _TRA_EXPORT tra_create_register_traductor_e(TRA **tra, ETB_PORT *port, dword flags);
int     _TRA_EXPORT tra_download_register_stream_e(TRA *tra, dword amsk, word tmsk, TRA_LINE_READER *reader, void *stream);
int     _TRA_EXPORT tra_download_register_stream_e2(TRA *tra, dword amsk, word tmsk, dword skip, TRA_LINE_READER *reader, void *stream);
int     _TRA_EXPORT tra_upload_register_stream_e(TRA *tra, dword amsk, word tmsk, TRA_LINE_WRITER *writer, void *stream);

/*
 * direct traductor (offline)
 */
bool    _TRA_EXPORT tra_is_valid_direct_traductor(TRA *tra);
int     _TRA_EXPORT tra_create_direct_traductor_o(TRA **tra, int d_prod, dword d_ver, int x_prod, dword x_ver, dword flags);
int     _TRA_EXPORT tra_create_direct_traductor_o2(TRA **tra, int d_prod, dword d_ver, int x_prod, dword x_ver,
					   int d_prod2, dword d_ver2, int x_prod2, dword x_ver2, dword flags);

/*
 * direct traductor (etb extension/subclass)
 */
bool    _TRA_EXPORT tra_is_valid_direct_traductor_e(TRA *tra);
int     _TRA_EXPORT tra_create_direct_traductor_e(TRA **tra, ETB_PORT *port, dword flags);
int     _TRA_EXPORT tra_send_direct_cmd_e(TRA *tra, char_cp buffer, void *key, bool *reply);
int		_TRA_EXPORT tra_receive_direct_cmd_e(TRA *tra, char_p buffer, int max, bool *p_ack, bool *p_error, bool *p_req, void **p_key, bool wait);
int     _TRA_EXPORT tra_send_direct_stream_e(TRA *tra, dword amsk, TRA_LINE_READER *reader, void *stream);
int     _TRA_EXPORT tra_get_axis_mask_e(TRA *tra, dword *mask);
int     _TRA_EXPORT tra_set_axis_mask_e(TRA *tra, dword mask);

/*
 * sequence traductor (offline)
 */
bool    _TRA_EXPORT tra_is_valid_sequence_traductor(TRA *tra);
int     _TRA_EXPORT tra_create_sequence_traductor_o(TRA **tra, int d_prod, dword d_ver, int x_prod, dword x_ver, dword flags);
int     _TRA_EXPORT tra_create_sequence_traductor_o2(TRA **tra, int d_prod, dword d_ver, int x_prod, dword x_ver,
					   int d_prod2, dword d_ver2, int x_prod2, dword x_ver2, dword flags);
int     _TRA_EXPORT tra_setup_sequence_drive_map(TRA *tra, dword amsk, int d_prod, dword d_ver, int x_prod, dword x_ver);
int     _TRA_EXPORT tra_clear_sequence_drive_map(TRA *tra);

/*
 * sequence traductor (etb extension/subclass)
 */
bool    _TRA_EXPORT tra_is_valid_sequence_traductor_e(TRA *tra);
int     _TRA_EXPORT tra_create_sequence_traductor_e(TRA **tra, ETB_PORT *port, dword flags);
int     _TRA_EXPORT tra_download_sequence_stream_e(TRA *tra, dword amsk, int from, int to, TRA_LINE_READER *reader, void *stream);
int     _TRA_EXPORT tra_upload_sequence_stream_e(TRA *tra, dword amsk, int from, int to, TRA_LINE_WRITER *writer, void *stream);
int     _TRA_EXPORT tra_get_sequence_line_e(TRA *tra, long *line);

/*
 * common functions
 */
int     _TRA_EXPORT tra_destroy(TRA **tra);
int     _TRA_EXPORT tra_get_progress(TRA *tra, double *val);
int     _TRA_EXPORT tra_set_progress(TRA *tra, double val);
int     _TRA_EXPORT tra_translate_rqs_to_ascii(TRA *tra, ETB_CONST_REC ETB_REC tx[], ETB_CONST_REC ETB_REC rx[], int n_rec, char_p buffer, int max);
int     _TRA_EXPORT tra_translate_rqs_to_ascii_ex(TRA *tra, ETB_CONST_REC ETB_REC tx[], ETB_CONST_REC ETB_REC rx[], int n_rec, int dest, dword mask, char_p buffer, int max);
int     _TRA_EXPORT tra_translate_cmd_to_ascii(TRA *tra, ETB_CONST_REC ETB_REC rec[], int n_rec, char_p buffer, int max);
int     _TRA_EXPORT tra_translate_cmd_to_ascii_ex(TRA *tra, ETB_CONST_REC ETB_REC rec[], int n_rec, int dest, dword mask, char_p buffer, int max);
int     _TRA_EXPORT tra_cmd_to_ascii_ex(TRA *tra, ETB_CONST_REC ETB_REC rec[], int n_rec, int dest, dword mask, char_p buffer, int max);
int     _TRA_EXPORT tra_translate_cmd_from_ascii(TRA *tra, ETB_REC rec[], int m_rec, int *n_rec, char_cp buffer);
int     _TRA_EXPORT tra_translate_cmd_from_ascii_ex(TRA *tra, ETB_REC rec[], int m_rec, int *n_rec, int *dest, dword *mask, char_cp buffer);
int     _TRA_EXPORT tra_cmd_fr_ascii_ex(TRA *tra, ETB_REC rec[], int m_rec, int *n_rec, int *dest, dword *mask, char_cp buffer);
int     _TRA_EXPORT tra_set_iso_converter(TRA *tra, TRA_ISO_CONVERTER *conv, void *user);
int     _TRA_EXPORT tra_get_iso_converter(TRA *tra, TRA_ISO_CONVERTER **rconv, void **ruser);
int     _TRA_EXPORT tra_set_flags(TRA *tra, dword flags);
int     _TRA_EXPORT tra_set_preference_axis_mask(TRA *tra, dword axis_mask);
dword   _TRA_EXPORT tra_get_preference_axis_mask(TRA *tra);

/*
 * general information retrieving
 */
dword   _TRA_EXPORT tra_get_flags(TRA *tra);
TRA_ETB_PORT_P _TRA_EXPORT tra_get_etb_port(TRA *tra);
int     _TRA_EXPORT tra_get_drv_product(TRA *tra, int axis);
int     _TRA_EXPORT tra_get_ext_product(TRA *tra, int axis);
dword   _TRA_EXPORT tra_get_drv_version(TRA *tra, int axis);
dword   _TRA_EXPORT tra_get_ext_version(TRA *tra, int axis);


#ifdef __cplusplus
} /* extern "C" */
#endif


#ifdef TRA_OO_API
#define ERRCHK(a) do { int _err = (a); if (_err) throw TraException(_err); } while(0)
#endif
/*
 * Tra base class - c++
 */
#ifdef TRA_OO_API
class Tra {
    /*
     * some public constants
     */
    /*
     * versions access
     */
public:
    static dword getVersion() { 
        return tra_get_version(); 
    }
    static dword getEdiVersion() { 
        return tra_get_edi_version(); 
    }
    static dword getBuildTime() { 
        return tra_get_build_time(); 
    }

    /*
     * static utility
     */
	static void versionToString(char *buffer, int max, dword version) {
		tra_version_to_string(buffer, max, version);
	}
};
#endif /* TRA_OO_API */

 
/*
 * Tra exception - c++
 */
#ifdef TRA_OO_API
class TraException : public Tra {
friend class TraData;
friend class TraAbstractTraductor;
friend class TraOLRegisterTraductor;
friend class TraRegisterTraductor;
friend class TraOLDirectTraductor;
friend class TraDirectTraductor;
friend class TraOLSequenceTraductor;
friend class TraSequenceTraductor;

    /*
     * public error codes
     */
public:
	    enum {EBADDRVPROD = -520 };                     /* an unknown drive product has been specified */
    enum {EBADDRVVER = -518 };                      /* a drive with an incompatible version has been specified */
    enum {EBADEXTPROD = -521 };                     /* an unknown extention card product has been specified */
    enum {EBADEXTVER = -519 };                      /* an extention card with an incompatible version has been specified */
    enum {EBADMSG = -552 };                         /* bad response from etel bus */
    enum {EBADPARAM = -515 };                       /* one of the parameter is not valid */
    enum {EBADSTATE = -522 };                       /* this operation is not allowed in this state */
    enum {EBADSTREAM = -553 };                      /* bad format of input stream */
    enum {ECONVERT = -564 };                        /* iso conversion failed */
    enum {EDEPRECATED = -558 };                     /* the command or register is deprecated */
    enum {EDRV = -513 };                            /* the drive is in error state */
    enum {EEMPTY = -560 };                          /* the command is empty */
    enum {EENUM = -563 };                           /* the given value is not part of the enumeration */
    enum {EGETINFO = -523 };                        /* error while getting drive information */
    enum {EGETREC = -551 };                         /* cannot get a response through etel-bus port */
    enum {EINTERNAL = -510 };                       /* some internal error in the etel software */
    enum {EMULTIREC = -541 };                       /* bad multiple record command */
    enum {ENOACK = -512 };                          /* no acknowledge from the drive */
    enum {ENOCOMMAND = -525 };                      /* no command available now */
    enum {ENODRIVE = -568 };                        /* the specified drive is not present */
    enum {ENOFLOAT = -569 };                        /* float value not allowed in this context */
    enum {ENOINT = -570 };                          /* int value not allowed in this context */
    enum {ENOISO = -565 };                          /* iso value not allowed in this context */
    enum {ENOPARAM = -566 };                        /* too many parameters in this command */
    enum {ENOTEXIST = -540 };                       /* the requested register/command does not exist */
    enum {EOUTOFRANGE = -562 };                     /* parameter out of range */
    enum {EPUTREC = -550 };                         /* cannot send a request through etel-bus port */
    enum {ERDONLY = -567 };                         /* attempting to write a read-only register */
    enum {ESYNTAX = -561 };                         /* syntax error in the command */
    enum {ESYSTEM = -511 };                         /* some system resource return an error */
    enum {ETOOSMALL = -524 };                       /* record buffer too small */


	/*
 	 * destinations
 	 */
	enum { DEST_EXPLICIT = 0 };						/* destination is specified by an explicit mask */
	enum { DEST_MSK = 1 };							/* destination is specified by a '.%' */
	enum { DEST_Z = 2 };							/* destination is specified by a '.Z. */

    /*
     * exception code
     */
private:
    int code;

	/*
     * error translation
     */
public:
    static const char *translate(int code) { 
        return tra_translate_error(code);
    }

    /*
     * constructor
     */
protected:
    TraException(int e) { code = e; };

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
#endif /* TRA_OO_API */

/*
 * c++ callbacks
 */
#ifdef TRA_OO_API
class TraAbstractTraductor;
typedef int TRA_CALLBACK TraLineReader(TraAbstractTraductor tra, char *buffer, int max, void *stream);
typedef int TRA_CALLBACK TraLineWriter(TraAbstractTraductor tra, const char *buffer, void *stream, EtbRec recs[], int n_rec);
typedef int TRA_CALLBACK TraIsoConverter(TraAbstractTraductor tra, long *incr, double *iso, int conv, int axis, bool to_iso, void *user);
#endif /* TRA_OO_API */

/*
 * Base class - c++
 */
#ifdef TRA_OO_API
class TraAbstractTraductor {
    /*
     * internal tra pointer
     */
protected:
    TRA *tra;

    /*
     * traductor flags
     */
public:
    enum { FLAG_USE_ALIASES = 0x00000001 };         /* parameter are replaced by aliases if possible */
	enum { FLAG_REMOVE_UNDEFINED = 0x00000002 };    /* do not includes undefined indexes and subindexes */
    enum { FLAG_REMOVE_DEFAULT = 0x00000004 };      /* do not includes values when equal to default value */
    enum { FLAG_REMOVE_AXIS = 0x00000008 };         /* do not includes axis when uploading drive parameters */
    enum { FLAG_GROUP_SUBINDEXES = 0x00000010 };    /* group identical indexes together */
    enum { FLAG_CONVERT_TO_ISO = 0x00000020 };      /* convert uploaded command to iso whenever possible */
    enum { FLAG_SORT_REGISTERS = 0x00000040 };      /* sort registers by category when uploading */
    enum { FLAG_NO_DEPRECATED = 0x00000080 };       /* generate an error on deprecated commands */
    enum { FLAG_NO_EMPTY_LINES = 0x00000100 };      /* generate an error on empty lines */
    enum { FLAG_RECEIVE_REWRITE = 0x00000200 };     /* rewrite the command in the receive fct */
    enum { FLAG_RELAX_DRV_CHECK = 0x00000800 };     /* allow the use of unknowed drv version */ 
    enum { FLAG_RELAX_EXT_CHECK = 0x00001000 };     /* don't take extension card state into account */
    enum { FLAG_DISABLE_CHECKS = 0x00002000 };      /* disable all checks */
    enum { FLAG_COMMENT_NONE = 0x00010000 };        /* don't insert any comment in uploaded files */
    enum { FLAG_COMMENT_VERBOSE = 0x00020000 };     /* insert lots of comment in uploaded files */
    enum { FLAG_COMMENT_LINE = 0x00040000 };        /* add a comment describing each line */
    enum { FLAG_USE_TAB_4 = 0x00100000 };           /* use one tab for 4 colums */
    enum { FLAG_USE_TAB_8 = 0x00200000 };           /* use one tab for 8 colums */
    enum { FLAG_USE_TAB_SINGLE = 0x00400000 };      /* use one tab before comments */
    enum { FLAG_ALL_SUBINDEXES = 0x01000000 };		/* get all register subindexes when uploading */

	/*
	 * Destinations.
	 */
public:
    enum { DEST_EXPLICIT = 0 };						/* destination is specified by an explicit mask */
    enum { DEST_MSK = 1 };							/* destination is specified by a '.%' */
    enum { DEST_Z = 2 };							/* destination is specified by a '.Z. */

	/*
     * progress information getting/setting
     */
public:
	double getProgress() {
		double val;
		ERRCHK(tra_get_progress(tra, &val));
		return val;
	}
	void setProgress(double val) {
		ERRCHK(tra_set_progress(tra, val));
	}

	/*
     * iso converter getting/setting
     */
public:
	TraIsoConverter *getIsoConverter(void **puser = NULL) {
		TRA_ISO_CONVERTER *conv;
		ERRCHK(tra_get_iso_converter(tra, &conv, puser));
		return (TraIsoConverter *)conv;
	}
	void setIsoConverter(TraIsoConverter conv, void *param = NULL) {
		ERRCHK(tra_set_iso_converter(tra, (TRA_ISO_CONVERTER *)conv, param));
	}

	/*
	 * flags settings
	 */
	void setFlags(dword flags) {
		ERRCHK(tra_set_flags(tra, flags));
	}

    /*
     * general information retrieving
     */
public:
	dword getFlags() {
		return tra_get_flags(tra);
	}
	EtbPort *getEtbPort() {
		return (EtbPort *)tra_get_etb_port(tra);
	}
	int getDrvProduct(int axis) {
	    return tra_get_drv_product(tra, axis);
	}
	int getExtProduct(int axis) {
	    return tra_get_ext_product(tra, axis);
	}
	int getDrvVersion(int axis) {
	    return tra_get_drv_version(tra, axis);
	}
	int getExtVersion(int axis) {
	    return tra_get_ext_version(tra, axis);
	}

    /*
     * translate single commands and requests
     */
public:
	void translateRqsToAscii(ETB_CONST_REC EtbRec tx[], ETB_CONST_REC EtbRec rx[], int n_rec, char_p buffer, int max) {
		ERRCHK(tra_translate_rqs_to_ascii(tra, (ETB_CONST_REC ETB_REC *)tx, (ETB_CONST_REC ETB_REC *)rx, n_rec, buffer, max));
	}
	void translateRqsToAscii(ETB_CONST_REC EtbRec tx[], ETB_CONST_REC EtbRec rx[], int n_rec, int dest, dword mask, char_p buffer, int max) {
		ERRCHK(tra_translate_rqs_to_ascii_ex(tra, (ETB_CONST_REC ETB_REC *)tx, (ETB_CONST_REC ETB_REC *)rx, n_rec, dest, mask, buffer, max));
	}
	void translateCmdToAscii(ETB_CONST_REC EtbRec rec[], int n_rec, char_p buffer, int max) {
		ERRCHK(tra_translate_cmd_to_ascii(tra, (ETB_CONST_REC ETB_REC *)rec, n_rec, buffer, max));
	}
	void translateCmdToAscii(ETB_CONST_REC EtbRec rec[], int n_rec, int dest, dword mask, char_p buffer, int max) {
		ERRCHK(tra_translate_cmd_to_ascii_ex(tra, (ETB_CONST_REC ETB_REC *)rec, n_rec, dest, mask, buffer, max));
	}
	int translateCmdFromAscii(EtbRec rec[], int m_rec, char_cp buffer) {
		int n_rec;
		ERRCHK(tra_translate_cmd_from_ascii(tra, (ETB_REC *)rec, m_rec, &n_rec, buffer));
		return n_rec;
	}
	int translateCmdFromAscii(EtbRec rec[], int m_rec, int *dest, dword *mask, char_cp buffer) {
		int n_rec;
		ERRCHK(tra_translate_cmd_from_ascii_ex(tra, (ETB_REC *)rec, m_rec, &n_rec, dest, mask, buffer));
		return n_rec;
	}

    /*
     * destructor function
     */
public:
    void destroy() {
        ERRCHK(tra_destroy(&tra));
    }
};
#endif /* TRA_OO_API */

/*
 * register traductor class (offline) - c++
 */
#ifdef TRA_OO_API
class TraOLRegisterTraductor : public TraAbstractTraductor {
    /*
     * constructors / destructor
     */
protected:
	TraOLRegisterTraductor() {}
public:
    TraOLRegisterTraductor(int d_prod, dword d_ver, int x_prod, dword x_ver, dword flags) {
	    tra = NULL; 
        ERRCHK(tra_create_register_traductor_o(&tra, d_prod, d_ver, x_prod, x_ver, flags));
    }
    TraOLRegisterTraductor(int d_prod, dword d_ver, int x_prod, dword x_ver,
		int d_prod2, dword d_ver2, int x_prod2, dword x_ver2, dword flags) 
	{
	    tra = NULL; 
        ERRCHK(tra_create_register_traductor_o2(&tra, d_prod, d_ver, x_prod, x_ver,
			d_prod2, d_ver2, x_prod2, x_ver2, flags));
    }
    bool isValid() {
        return tra_is_valid_register_traductor(tra);
    }
};
#endif /* TRA_OO_API */

/*
 * register traductor class - c++
 */
#ifdef TRA_OO_API
class TraRegisterTraductor : public TraOLRegisterTraductor {
    /*
     * skip flags
     */
public:
    enum { SKIP_SYSTEM = 0x00000001 };             /* skip system parameters on register download */
    enum { SKIP_NON_SYSTEM = 0x00000002 };         /* skip non-system parameters on register download */

    /*
     * constructors / destructor
     */
public:
    TraRegisterTraductor(EtbPort port, dword flags) {
	    tra = NULL; 
        ERRCHK(tra_create_register_traductor_e(&tra, *(ETB_PORT **)&port, flags));
    }
    bool isValid() {
        return tra_is_valid_register_traductor_e(tra);
    }

	/*
	 * download/upload opertations
	 */ 
	void uploadStream(dword amsk, word tmsk, TraLineWriter *writer, void *stream = NULL) {
		ERRCHK(tra_upload_register_stream_e(tra, amsk, tmsk, (TRA_LINE_WRITER *)writer, stream));
	}
	void downloadStream(dword amsk, word tmsk, TraLineReader *reader, void *stream = NULL) {
		ERRCHK(tra_download_register_stream_e(tra, amsk, tmsk, (TRA_LINE_READER *)reader, stream));
	}
	void downloadStream(dword amsk, word tmsk, dword skip, TraLineReader *reader, void *stream = NULL) {
		ERRCHK(tra_download_register_stream_e2(tra, amsk, tmsk, skip, (TRA_LINE_READER *)reader, stream));
	}
};
#endif /* TRA_OO_API */

/*
 * direct traductor class (offline) - c++
 */
#ifdef TRA_OO_API
class TraOLDirectTraductor : public TraAbstractTraductor {
    /*
     * constructors / destructor
     */
protected:
    TraOLDirectTraductor() {}
public:
    TraOLDirectTraductor(int d_prod, dword d_ver, int x_prod, dword x_ver, dword flags) {
	    tra = NULL; 
        ERRCHK(tra_create_direct_traductor_o(&tra, d_prod, d_ver, x_prod, x_ver, flags));
    }
    TraOLDirectTraductor(int d_prod, dword d_ver, int x_prod, dword x_ver,
		int d_prod2, dword d_ver2, int x_prod2, dword x_ver2, dword flags) 
	{
	    tra = NULL; 
        ERRCHK(tra_create_direct_traductor_o2(&tra, d_prod, d_ver, x_prod, x_ver,
			d_prod2, d_ver2, x_prod2, x_ver2, flags));
    }
    bool isValid() {
        return tra_is_valid_direct_traductor(tra);    
	}
};
#endif /* TRA_OO_API */

/*
 * direct traductor class - c++
 */
#ifdef TRA_OO_API
class TraDirectTraductor : public TraOLDirectTraductor {
    /*
     * constructors / destructor
     */
public:
    TraDirectTraductor(EtbPort port, dword flags) {
	    tra = NULL; 
        ERRCHK(tra_create_direct_traductor_e(&tra, *(ETB_PORT **)&port, flags));
    }
    bool isValid() {
        return tra_is_valid_direct_traductor_e(tra);    
	}

	/*
	 * send/receive operations
	 */
	bool sendCmd(char_cp buffer, void *key) {
		bool reply;
		ERRCHK(tra_send_direct_cmd_e(tra, buffer, key, &reply));
		return reply;
	}
	void *receiveCmd(char_p buffer, int max, bool *p_ack, bool *p_error, bool *p_req, bool wait) {
		void *key;
		ERRCHK(tra_receive_direct_cmd_e(tra, buffer, max, p_ack, p_error, p_req, &key, wait));
		return key;
	}
	void sendStream(dword amsk, TraLineReader *reader, void *stream = NULL) {
		ERRCHK(tra_send_direct_stream_e(tra, amsk, (TRA_LINE_READER *)reader, stream));
	}
	void setAxisMask(dword amsk) {
		ERRCHK(tra_set_axis_mask_e(tra, amsk));
	}
	dword getAxisMask() {
		dword amsk;
		ERRCHK(tra_get_axis_mask_e(tra, &amsk));
		return amsk;
	}
};
#endif /* TRA_OO_API */

/*
 * sequence traductor class (offline) - c++
 */
#ifdef TRA_OO_API
class TraOLSequenceTraductor : public TraAbstractTraductor {
    /*
     * constructors / destructor
     */
protected:
    TraOLSequenceTraductor() {}
public:
    TraOLSequenceTraductor(int d_prod, dword d_ver, int x_prod, dword x_ver, dword flags) {
	    tra = NULL; 
        ERRCHK(tra_create_sequence_traductor_o(&tra, d_prod, d_ver, x_prod, x_ver, flags));
    }
    TraOLSequenceTraductor(int d_prod, dword d_ver, int x_prod, dword x_ver,
		int d_prod2, dword d_ver2, int x_prod2, dword x_ver2, dword flags) 
	{
	    tra = NULL; 
        ERRCHK(tra_create_sequence_traductor_o2(&tra, d_prod, d_ver, x_prod, x_ver,
			d_prod2, d_ver2, x_prod2, x_ver2, flags));
    }
    bool isValid() {
        return tra_is_valid_sequence_traductor(tra);    
	}

	/*
	 * drive map setting
	 */
    void clearDriveMap() {
        ERRCHK(tra_clear_sequence_drive_map(tra));
    }
    void setupDriveMap(dword amsk, int d_prod, dword d_ver, int x_prod, dword x_ver) {
        ERRCHK(tra_setup_sequence_drive_map(tra, amsk, d_prod, d_ver, x_prod, x_ver));
    }
};
#endif /* TRA_OO_API */

/*
 * sequence traductor class - c++
 */
#ifdef TRA_OO_API
class TraSequenceTraductor : public TraOLSequenceTraductor {
    /*
     * constructors / destructor
     */
public:
    TraSequenceTraductor(EtbPort port, dword flags) {
	    tra = NULL; 
        ERRCHK(tra_create_sequence_traductor_e(&tra, *(ETB_PORT **)&port, flags));
    }
    bool isValid() {
        return tra_is_valid_sequence_traductor_e(tra);    
	}

	/*
	 * download/upload opertations
	 */ 
	void uploadStream(dword amsk, int from, int to, TraLineWriter *writer, void *stream = NULL) {
		ERRCHK(tra_upload_sequence_stream_e(tra, amsk, from, to, (TRA_LINE_WRITER *)writer, stream));
	}
	void downloadStream(dword amsk, int from, int to, TraLineReader *reader, void *stream = NULL) {
		ERRCHK(tra_download_sequence_stream_e(tra, amsk, from, to, (TRA_LINE_READER *)reader, stream));
	}
	long getSequenceLine() {
		long line;
		ERRCHK(tra_get_sequence_line_e(tra, &line));
		return line;
	}
};
#undef ERRCHK
#endif /* TRA_OO_API */

#endif /* _TRA10_H */
