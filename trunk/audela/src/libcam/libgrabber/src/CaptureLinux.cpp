// Capture.cpp: implementation of the CCaptureLinux class.
//
//////////////////////////////////////////////////////////////////////

#include "sysexp.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/videodev2.h>
#include <sys/ioctl.h>
#include <linux/ppdev.h>
#include <linux/parport.h>
#include <errno.h>
#include <sys/mman.h>

#include <libcam/util.h>  // pour libcam_strupr

#include "CaptureLinux.h"

#define LOG_NONE    0
#define LOG_ERROR   1
#define LOG_WARNING 2
#define LOG_INFO    3
#define LOG_DEBUG   4

extern void webcam_log(int level, const char *fmt, ...);

/**
 * Definitions and global variables for yuv420p_to_rgb24 conversion.
 * Code comes from xawtv.
*/

#define CLIP         320

# define RED_NULL    128
# define BLUE_NULL   128
# define LUN_MUL     256
# define RED_MUL     512
# define BLUE_MUL    512

#define GREEN1_MUL  (-RED_MUL/2)
#define GREEN2_MUL  (-BLUE_MUL/6)
#define RED_ADD     (-RED_NULL  * RED_MUL)
#define BLUE_ADD    (-BLUE_NULL * BLUE_MUL)
#define GREEN1_ADD  (-RED_ADD/2)
#define GREEN2_ADD  (-BLUE_ADD/6)

static unsigned int ng_yuv_gray[256];
static unsigned int ng_yuv_red[256];
static unsigned int ng_yuv_blue[256];
static unsigned int ng_yuv_g1[256];
static unsigned int ng_yuv_g2[256];
static unsigned int ng_clip[256 + 2 * CLIP];

#define GRAY(val)               ng_yuv_gray[val]
#define RED(gray,red)           ng_clip[ CLIP + gray + ng_yuv_red[red] ]
#define GREEN(gray,red,blue)    ng_clip[ CLIP + gray + ng_yuv_g1[red] + \
                                                       ng_yuv_g2[blue] ]
#define BLUE(gray,blue)         ng_clip[ CLIP + gray + ng_yuv_blue[blue] ]

/**
 * Frame with any pixel > REQUIRED_MAX_VALUE is detected
 * as valid frame (used in autodetection mode).
*/
#define REQUIRED_MAX_VALUE 150


/**
 * Default value of cam->validFrame parameter.
*/
#define VALID_FRAME 9


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCaptureLinux::CCaptureLinux(char * portName)
{
    webcam_log( LOG_DEBUG,"ctor de CCaptureLinux" );
    strncpy( this->portName, portName,sizeof(this->portName ) );
    validFrame = VALID_FRAME;
    bgrBuffer = 0;
    yuvBuffer = 0;
    yuvBufferSize = 0;
    bgrBuffer = NULL;
    cam_fd = -1;
    IsPhilips = 0;
    shutterSpeed = -1;
    longExposure = FALSE;
    mmap_buffers = 0;
    capturing = FALSE;
    driver_params = new v4l2_parameters();
}

CCaptureLinux::~CCaptureLinux()
{
    webcam_log( LOG_DEBUG,"dtor de CCaptureLinux" );

    if (mmap_buffers) {
        webcam_mmapDelete();
    }
    if ( cam_fd >= 0 ) {
        close( cam_fd );
        cam_fd = -1;
    }

    if ( yuvBuffer != 0 ) {
        free( yuvBuffer );
        yuvBuffer = 0;
    }
    yuvBufferSize = 0;

    if ( bgrBuffer != 0 ) {
        free( bgrBuffer );
        bgrBuffer = 0;
    }
}

/**
*----------------------------------------------------------------------
*
* create an instance of CCaptureLinux
*
*----------------------------------------------------------------------
*/

BOOL CCaptureLinux::get_parameters( v4l2_parameters * param, char * errorMessage ) {
    struct v4l2_capability cap;

    webcam_log( LOG_DEBUG, "get_parameters : ioctl VIDEO_QUERY_CAP" );
    if ( EINVAL == ioctl( cam_fd, VIDIOC_QUERYCAP, &cap ) ) {
        sprintf( errorMessage, "No VIDIOC_QUERY_CAP : %s ", strerror( errno ) );
        webcam_log( LOG_ERROR, "get_parameters : VIDEOC_QUERY_CAP non supporté, pilote non compatible V4L2" );
        return FALSE;
    }
    else {
        webcam_log( LOG_DEBUG, "get_parameters : pilote %s %u.%u.%u, materiel %s, bus %s", cap.driver, (cap.version >> 16) & 0xff, (cap.version >> 8) & 0xff, cap.version & 0xff, cap.card, cap.bus_info );
        unsigned int capabilities = cap.capabilities;
        if ( ( capabilities & V4L2_CAP_VIDEO_CAPTURE ) == 0 ) {
            sprintf( errorMessage, "Not a video capture device" );
            webcam_log( LOG_ERROR, "get_parameters : Pas de capture video possible");
            return FALSE;
        }

        param->io |= IO_METHOD_NIL;
        if ( ( capabilities & V4L2_CAP_STREAMING ) != 0 ) {
            webcam_log( LOG_INFO, "get_parameters : Accès en mmap possible");
            param->io |= IO_METHOD_MMAP;
        }

        if ( ( capabilities & V4L2_CAP_READWRITE ) != 0 ) {
            webcam_log( LOG_DEBUG, "get_parameters : Accès en read possible");
            param->io |= IO_METHOD_READ;
        }

        if ( param->io == IO_METHOD_NIL ) {
            sprintf( errorMessage, "No supported io method (mmap or read)" );
            webcam_log( LOG_ERROR, "get_parameters : Pas de lecture possible par read ou mmap");
            return FALSE;
        }
    }

    /* Recherche de tous les formats de données de sortie disponibles (numériques) */
    struct v4l2_fmtdesc fmt_desc;
    fmt_desc.index = 0;
    fmt_desc.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    param->data_format = FORMAT_NIL;
    webcam_log( LOG_DEBUG, "get_parameters : ioctl VIDEOC_ENUM_FMT" );
    while ( ioctl( cam_fd, VIDIOC_ENUM_FMT, &fmt_desc ) >= 0 ) {
        webcam_log( LOG_DEBUG, "get_parameters : VIDIOC_ENUM_FMT : format %s disponible (fourcc=%x)", fmt_desc.description, fmt_desc.pixelformat );
        if ( fmt_desc.pixelformat == fourcc('Y', 'U', 'Y', 'V') )
            param->data_format |= FORMAT_YUV422;
        if ( fmt_desc.pixelformat == fourcc('Y', 'U', '1', '2') )
            param->data_format |= FORMAT_YUV420;
        if ( fmt_desc.pixelformat == fourcc('R', 'G', 'B', '3') )
            param->data_format |= FORMAT_RGB24;
        if ( fmt_desc.pixelformat == fourcc('G', 'R', 'B', 'G') )
            param->data_format |= FORMAT_BAYER_GRBG;
        fmt_desc.index ++;
    }
    if ( param->data_format == FORMAT_NIL ) {
        sprintf( errorMessage, "No supported data format" );
        webcam_log( LOG_ERROR, "get_parameters : Pas de format de donnée valide");
        return FALSE;
    }

    /* Recherche de tous les formats de données d'entrée disponibles (normes vidéo) */
    webcam_log( LOG_DEBUG, "get_parameters : ioctl VIDEOC_G_STD" );
    if ( ioctl( cam_fd, VIDIOC_G_STD, &(param->stdid) ) < 0 ) {
        webcam_log( LOG_WARNING, "get_parameters : VIDEOC_G_STD %s", strerror( errno ) );
        webcam_log( LOG_WARNING, "get_parameters : VIDEOC_G_STD not supported. Not an issue as it is optional" );
    }
    else {
        if ( ( param->stdid & 0xffff ) != 0 )
            webcam_log( LOG_INFO, "VIDIOC_G_STD : PAL video format supported" );
    }

    return TRUE;
}

BOOL CCaptureLinux::select_parameters( v4l2_parameters * param, char * errorMessage ) {
    /* Sélection du mode d'accès : on favorise le mode mmap */
    if ( ( param->io & IO_METHOD_MMAP ) != 0 ) {
        param->io = IO_METHOD_MMAP;
        webcam_log( LOG_INFO, "select_parameters : Accès en mmap selectionné");
    }
    else if ( ( param->io & IO_METHOD_READ ) != 0 ) {
        param->io = IO_METHOD_READ;
        webcam_log( LOG_INFO, "select_parameters : Accès en read selectionné");
    }
    else {
        /* On ne devrait jamais passer ici */
            sprintf( errorMessage, "No supported io method (mmap or read)" );
            webcam_log( LOG_ERROR, "select_parameters : Pas de lecture possible par read ou mmap");
            return FALSE;
    }

    if ( param->io == IO_METHOD_READ ) {
        /* en mode read, on ne supporte que le mode YUV422, car les autres n'ont jamais été testés */
        /* par la suite, cette discrimination devrait disparaitre */
        if ( ( param->data_format & FORMAT_YUV422 ) != 0 ) {
            param->data_format = FORMAT_YUV422;
            webcam_log( LOG_INFO, "select_parameters : Data format in YUV422" );
        }
        else {
            sprintf( errorMessage, "No supported data format for the read mode" );
            webcam_log( LOG_ERROR, "select_parameters : No supported data format for the read mode" );
            return FALSE;
        }
    }
    else { // io = IO_METHOD_MMAP
        /* Sélection du format RGB24 en priorité */
        if ( ( param->data_format & FORMAT_RGB24 ) != 0 ) {
            param->data_format = FORMAT_RGB24;
            webcam_log( LOG_INFO, "select_parameters : Data format in RGB24" );
        }
        else if ( ( param->data_format & FORMAT_YUV422 ) != 0 ) {
            param->data_format = FORMAT_YUV422;
            webcam_log( LOG_INFO, "select_parameters : Data format in YUV422" );
        }
        else if ( ( param->data_format & FORMAT_YUV420 ) != 0 ) {
            param->data_format = FORMAT_YUV420;
            webcam_log( LOG_INFO, "select_parameters : Data format in YUV420" );
        }
        /* Format non testé car grosse bogue dans le pilote STV06xx */
    //    else if ( ( supp_format & FORMAT_BAYER_GRBG ) != 0 ) {
    //        data_format = FORMAT_BAYER_GRBG;
    //        webcam_log( LOG_INFO, "get_capabilities : Data format in Bayer GRBG" );
    //    }
        else {
            sprintf( errorMessage, "No supported data format" );
            webcam_log( LOG_ERROR, "select_parameters : No supported data format" );
            close( cam_fd );
            cam_fd = -1;
            return FALSE;
        }
    }

    /* On ne garde que les formats PAL */
    param->stdid = param->stdid & 0xffff;

    return TRUE;
}

BOOL CCaptureLinux::set_parameters( v4l2_parameters * param, char * errorMessage ) {
   struct v4l2_format fmt;

    // Libération de la mémoire allouée dans le pilote
    // Parfois indispensable pour appeler VIDIOC_S_FMT
    if ( param->io == IO_METHOD_MMAP ) {
        alloc_driver_memory(0);
    }

    // Source video 0. A changer ?
    int index = 0;
    webcam_log( LOG_DEBUG, "set_parameters : ioctl VIDEOC_S_INPUT" );
    if ( ioctl( cam_fd, VIDIOC_S_INPUT, &index ) < 0 ) {
        sprintf( errorMessage, "VIDEOC_S_INPUT %s", strerror( errno ) );
        webcam_log( LOG_ERROR, "set_parameters : VIDEOC_S_INPUT %s", strerror( errno ) );
        return FALSE;
    }

    /* Format de la video en entrée */
    webcam_log( LOG_DEBUG, "set_parameters : ioctl VIDEOC_S_STD" );
    if ( ioctl( cam_fd, VIDIOC_S_STD, &(param->stdid) ) < 0 ) {
        sprintf( errorMessage, "VIDIOC_S_STD : %s", strerror( errno ) );
        webcam_log( LOG_WARNING, "set_parameters : VIDEOC_S_STD %s", strerror( errno ) );
        webcam_log( LOG_WARNING, "set_parameters : VIDEOC_S_STD not supported. Not an issue as it is optional" );
    }

    /* Initialisation */
    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    struct v4l2_pix_format *p = (struct v4l2_pix_format *)&fmt.fmt;
    webcam_log( LOG_DEBUG, "set_parameters : ioctl VIDEOC_G_FMT" );
    if ( ioctl( cam_fd,VIDIOC_G_FMT, &fmt ) < 0 ) {
        sprintf( errorMessage, "VIDIOC_G_FMT  : %s", strerror( errno ) );
        webcam_log( LOG_ERROR, "set_parameters : VIDEOC_G_FMT %s", strerror( errno ) );
        return FALSE;
    }
    else {
        webcam_log( LOG_DEBUG, "set_parameters : VIDEOC_G_FMT dimensions image %u x %u", p->width, p->height );
        webcam_log( LOG_DEBUG, "set_parameters : VIDEOC_G_FMT format %c%c%c%c", p->pixelformat & 0xff, ( p->pixelformat >> 8 ) & 0xff , ( p->pixelformat >> 16 ) & 0xff, ( p->pixelformat >> 24 ) & 0xff );
    }

    /* Initialisation du pilote */
    unsigned int pixel_format;
    switch ( param->data_format ) {
        case FORMAT_YUV422 :
            pixel_format = V4L2_PIX_FMT_YUYV;
            break;
        case FORMAT_YUV420 :
            pixel_format = V4L2_PIX_FMT_YUV420;
            break;
        case FORMAT_BAYER_GRBG :
            // Ce fourcc n'est pas défini explicitement dans videodev2.h. Donc on le crée ...
            pixel_format = fourcc('G', 'R', 'B', 'G');
            break;
        case FORMAT_RGB24 :
        default :
            pixel_format = V4L2_PIX_FMT_RGB24;
            break;
    }
    p->pixelformat = pixel_format;
    p->colorspace = V4L2_COLORSPACE_470_SYSTEM_BG;
    p->field = V4L2_FIELD_INTERLACED;

    webcam_log( LOG_DEBUG, "set_parameters : ioctl VIDEOC_S_FMT" );
    webcam_log( LOG_DEBUG, "set_parameters : VIDEOC_S_FMT format %c%c%c%c", p->pixelformat & 0xff, ( p->pixelformat >> 8 ) & 0xff , ( p->pixelformat >> 16 ) & 0xff, ( p->pixelformat >> 24 ) & 0xff );
    if ( ioctl( cam_fd,VIDIOC_S_FMT, &fmt ) < 0 ) {
        sprintf( errorMessage, "VIDIOC_S_FMT %s", strerror( errno ) );
        webcam_log( LOG_ERROR, "set_parameters : VIDEOC_S_FMT %s", strerror( errno ) );
        return FALSE;
   }

    /* Un peu de paranoia, mais c'est malheureusement nécessaire, car certains pilotes de caméra sont assez folkloriques */
    webcam_log( LOG_DEBUG, "set_parameters : ioctl VIDEOC_G_FMT" );
    if ( ioctl( cam_fd,VIDIOC_G_FMT, &fmt ) < 0 ) {
        sprintf( errorMessage, "VIDIOC_G_FMT  : %s", strerror( errno ) );
        webcam_log( LOG_ERROR, "set_parameters : VIDEOC_G_FMT %s", strerror( errno ) );
        return FALSE;
    }
    else {
        webcam_log( LOG_DEBUG, "set_parameters : VIDEOC_G_FMT dimensions image %u x %u", p->width, p->height );
        webcam_log( LOG_DEBUG, "set_parameters : VIDEOC_G_FMT format %c%c%c%c", p->pixelformat & 0xff, ( p->pixelformat >> 8 ) & 0xff , ( p->pixelformat >> 16 ) & 0xff, ( p->pixelformat >> 24 ) & 0xff );
        if ( p->pixelformat != pixel_format ) {
            webcam_log( LOG_WARNING, "set_parameters : the driver has a bug" );
            if ( p->pixelformat == V4L2_PIX_FMT_RGB24 ) {
                param->data_format = FORMAT_RGB24;
                webcam_log( LOG_WARNING, "set_parameters : data format set to RGB24" );
            }
            else if ( p->pixelformat == V4L2_PIX_FMT_YUYV ) {
                param->data_format = FORMAT_YUV422;
                webcam_log( LOG_WARNING, "set_parameters : data format set to YUV422" );
            }
            else {
                sprintf( errorMessage, "VIDIOC_G_FMT  : %s", strerror( errno ) );
                webcam_log( LOG_ERROR, "set_parameters : cannot set the data format to a supported format" );
                return FALSE;
            }
        }
    }

    if ( param->io == IO_METHOD_MMAP ) {
        // Allocation des buffers dans la mémoire du pilote de la caméra
        if ( alloc_driver_memory( 2 ) != 0 ) {
            sprintf(errorMessage, "error alloc_driver_memory");
            close(cam_fd);
            cam_fd = -1;
            return FALSE;
        }
    }
    return TRUE;
}

BOOL CCaptureLinux::initHardware( UINT uIndex, CCaptureListener * captureListener, char * errorMessage ) {

    ng_color_yuv2rgb_init();
    if ( -1 == ( cam_fd = open( portName, O_RDWR ) ) ) {
        sprintf( errorMessage, "Can't open %s - %s", portName, strerror(errno) );
        return FALSE;
    }

    webcam_log( LOG_DEBUG, "initHardware %s cam_fd=%d\n", portName, cam_fd );

    if ( get_parameters( driver_params, errorMessage ) == FALSE ) {
        close( cam_fd );
        cam_fd = -1;
        return FALSE;
    }

    if ( select_parameters( driver_params, errorMessage ) == FALSE ) {
        close( cam_fd );
        cam_fd = -1;
        return FALSE;
    }

    if ( set_parameters( driver_params, errorMessage ) == FALSE ) {
        close( cam_fd );
        cam_fd = -1;
        return FALSE;
    }


    return TRUE;
}

/**
*----------------------------------------------------------------------
*
* connect video stream
*
*----------------------------------------------------------------------
*/
BOOL CCaptureLinux::connect(BOOL longExposure, UINT uIndex, char *errorMsg) {
   BOOL result;

   this->longExposure = longExposure;
   result = TRUE;

   return result;
}


/**
*----------------------------------------------------------------------
*
* disconnect video stream
*
*----------------------------------------------------------------------
*/
BOOL CCaptureLinux::disconnect(char *errorMsg) {
   BOOL   result = TRUE;

   return result;
}

/**
*----------------------------------------------------------------------
* isConnected
*  returns connected sate
*
*----------------------------------------------------------------------
*/
BOOL CCaptureLinux::isConnected() {
   BOOL   result = TRUE;
   return result;
}

/**
*----------------------------------------------------------------------
*
* accessors
*
*----------------------------------------------------------------------
*/

unsigned int CCaptureLinux::getImageWidth() {
    return currentWidth;
}

unsigned int CCaptureLinux::getImageHeight() {
    return currentHeight;
}

/*
unsigned long    CCaptureLinux::getVideoFormat(BITMAPINFO * pbi, int size ) {
   return capGetVideoFormat(hwndCap, pbi, size);
}
*/

BOOL CCaptureLinux::setVideoFormat( char *formatname, char *errorMessage )
{
    webcam_log( LOG_DEBUG, "setVideoFormat : formatname = %s", formatname );
    char ligne[128];
    int imax, jmax, box = 1;

    //change to upper: void libcam_strupr(char *chainein, char *chaineout)
    libcam_strupr( formatname, ligne );

    imax = 0;
    jmax = 0;
    if (strcmp(ligne, "SAME") == 0) {
        box = 0;
    }
    if (strcmp(ligne, "VGA") == 0) {
        imax = 640;
        jmax = 480;
    } else if (strcmp(ligne, "CIF") == 0) {
        imax = 352;
        jmax = 288;
    } else if (strcmp(ligne, "SIF") == 0) {
        imax = 320;
        jmax = 240;
   } else if (strcmp(ligne, "SSIF") == 0) {
        imax = 240;
        jmax = 176;
    } else if (strcmp(ligne, "QCIF") == 0) {
        imax = 176;
        jmax = 144;
    } else if (strcmp(ligne, "QSIF") == 0) {
        imax = 160;
        jmax = 120;
    } else if (strcmp(ligne, "SQCIF") == 0) {
        imax = 128;
        jmax = 96;
    } else if (strcmp(ligne, "720X576") == 0) {
        imax = 720;
        jmax = 576;
    }
    if (jmax == 0 || imax == 0) {
        sprintf(errorMessage, "Unknown format: %s", formatname);
        webcam_log( LOG_DEBUG, "setVideoFormat : Unknown format: %s", formatname );
        return FALSE;
    }

    /* Il faut impérativement arrêter le mode capture de la caméra */
    if ( capturing == TRUE ) {
        if ( abortCapture() == FALSE ) {
            sprintf( errorMessage, "Canot stop the capture mode" );
            webcam_log( LOG_DEBUG, "setVideoFormat : Impossible d'arrêter la capture vidéo" );
            return FALSE;
        }
    }

    /* New buffer size */
    currentWidth = imax;
    currentHeight= jmax;

    /* Set window size */
    struct v4l2_format fmt;
    struct v4l2_pix_format *p = (struct v4l2_pix_format *)&fmt.fmt;

    /* Parfois indispensable pour appeler VIDIOC_S_FMT */
    if ( driver_params->io == IO_METHOD_MMAP ) {
        alloc_driver_memory( 0 );
    }


    /* Récupération du format video */
    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    webcam_log( LOG_DEBUG, "setVideoFormat : ioctl VIDEOC_G_FMT" );
    if ( ioctl( cam_fd, VIDIOC_G_FMT, &fmt ) < 0 ) {
        sprintf( errorMessage, "setVideoFormat : VIDIOC_G_FMT  : %s", strerror( errno ) );
        webcam_log( LOG_ERROR, "setVideoFormat : VIDEOC_G_FMT %s", strerror( errno ) );
        return FALSE;
    }
    else {
        webcam_log( LOG_DEBUG, "setVideoFormat : VIDEOC_G_FMT taille physique %u x %u", p->width, p->height );
        webcam_log( LOG_DEBUG, "setVideoFormat : VIDEOC_G_FMT format %c%c%c%c", p->pixelformat & 0xff, ( p->pixelformat >> 8 ) & 0xff , ( p->pixelformat >> 16 ) & 0xff, ( p->pixelformat >> 24 ) & 0xff );
        webcam_log( LOG_DEBUG, "setVideoFormat : VIDEOC_G_FMT octets par ligne %u", p->bytesperline );
        webcam_log( LOG_DEBUG, "setVideoFormat : VIDEOC_G_FMT taille buffer %u", p->sizeimage );
        webcam_log( LOG_DEBUG, "setVideoFormat : VIDEOC_G_FMT tramage %u", p->field );
    }

    p->width = currentWidth;
    p->height = currentHeight;

    webcam_log( LOG_DEBUG, "setVideoFormat : ioctl VIDEOC_S_FMT" );
    if ( ioctl( cam_fd, VIDIOC_S_FMT, &fmt ) < 0 ) {
        sprintf( errorMessage, "VIDIOC_S_FMT  : %s", strerror( errno ) );
        webcam_log( LOG_ERROR, "setVideoFormat : VIDEOC_S_FMT %s", strerror( errno ) );
        return FALSE;
    }

    /* On vérifie la prise en compte du nouveau format */
    webcam_log( LOG_DEBUG, "setVideoFormat : ioctl VIDEOC_G_FMT" );
    if ( ioctl( cam_fd, VIDIOC_G_FMT, &fmt ) < 0 ) {
        sprintf( errorMessage, "VIDIOC_G_FMT  : %s", strerror( errno ) );
        webcam_log( LOG_ERROR, "setVideoFormat : VIDEOC_G_FMT %s", strerror( errno ) );
        return FALSE;
    }
    else {
        webcam_log( LOG_DEBUG, "setVideoFormat : VIDEOC_G_FMT taille physique %u x %u", p->width, p->height );
        webcam_log( LOG_DEBUG, "setVideoFormat : VIDEOC_G_FMT format %c%c%c%c", p->pixelformat & 0xff, (p->pixelformat >> 8 ) & 0xff , (p->pixelformat >> 16 ) & 0xff, (p->pixelformat >> 24 ) & 0xff );
        webcam_log( LOG_DEBUG, "setVideoFormat : VIDEOC_G_FMT octets par ligne %u", p->bytesperline );
        webcam_log( LOG_DEBUG, "setVideoFormat : VIDEOC_G_FMT taille buffer %u", p->sizeimage );
        webcam_log( LOG_DEBUG, "setVideoFormat : VIDEOC_G_FMT tramage %u", p->field );
    }

    if ( ( p->width != currentWidth ) || ( p->height != currentHeight ) ) {
        webcam_log( LOG_WARNING, "setVideoFormat : Cannot set video format to %d x %d ", currentWidth, currentHeight );
        webcam_log( LOG_WARNING, "setVideoFormat : The video format will be modified to %d x %d ", p->width, p->height );
        currentWidth = p->width;
        currentHeight = p->height;
    }

    yuvBufferSize = p->sizeimage;
    if ( ( yuvBuffer = (unsigned char *) malloc( yuvBufferSize ) ) == NULL ) {
       strcpy(errorMessage, "Not enough memory");
       close(cam_fd);
       cam_fd = -1;
       yuvBufferSize = 0;
       return FALSE;
    }

    if (bgrBuffer != NULL) {
       free(bgrBuffer);
    }

    bgrBuffer = (unsigned char *) calloc(currentWidth * currentHeight * 3, 1);

    /* Le nombre et la taille des buffers internes au pilote peuvent dépendre du format */
    if ( driver_params->io == IO_METHOD_MMAP ) {
        if ( alloc_driver_memory( 2 ) != 0 ) {
            sprintf( errorMessage, "setVideoFormat : Cannot allocate driver buffers" );
            webcam_log( LOG_ERROR, "setVideoFormat : Cannot allocate driver buffers" );
            return FALSE;
        }
    }

    webcam_log( LOG_DEBUG, "setVideoFormat : yuvBufferSize = %d", yuvBufferSize );
    return TRUE;

}

/**
 * webcam_getVideoParameter - returns asked parameters.
 * command is defined by <i>command</i>,
 * result is copied to <i>result</i> string,
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in errorMessage.
*/
BOOL CCaptureLinux::getVideoParameter(char *result, int command, char* errorMessage)
{
    webcam_log( LOG_DEBUG, "getVideoParameter" );

    int ret = TRUE;

    switch (command) {

    case GETVALIDFRAME:
        sprintf(result, "%d",validFrame);
        break;

    default:
        strcpy(errorMessage, "command not found");
        ret = FALSE;
        break;
    }

   return ret;
}

/**
 * webcam_setVideoParameter - sets some video source parameters.
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in errorMessage.
 *
 * Function implemented for Linux.
*/
BOOL CCaptureLinux::setVideoParameter(int paramValue, int command, char * errorMessage)
{
    webcam_log( LOG_DEBUG, "setVideoParameter paramValue=%d, command=%d", paramValue, command );

    int ret = TRUE;
    switch (command) {

    case SETVALIDFRAME:
        validFrame = paramValue;
        break;

    default:
        strcpy(errorMessage, "command not found");
        ret = FALSE;
        break;
    }

    if (ret == FALSE) {
        printf("setVideoParameter errorMessage=%s\n",errorMessage);
    }
    return ret;
}

/**
 * setWhiteBalance sets White Balance.
 * Arguments:
 * - mode - mode name
 * - red, blue - red and blue levels - valid only when mode is "manual"
 *
 * Returns value:
 * - 0 when success.
 * - no 0 when error occurred, error description in msg.
 *
 * Function implemented for Linux.
*/
BOOL CCaptureLinux::setWhiteBalance(char *mode, int red, int blue, char * errorMessage)
{
    strcpy(errorMessage, "setWhiteBalance TODO");
    return 1;
}



/**
*----------------------------------------------------------------------
*
* Windows Video capture core fonctions
*
*----------------------------------------------------------------------
*/

BOOL CCaptureLinux::isPreviewEnabled()  {
    return FALSE;
}

void CCaptureLinux::setPreview(BOOL value,int owner) {
}

BOOL CCaptureLinux::getOverlay()  {
    return FALSE;
}
void CCaptureLinux::setOverlay(BOOL value) {
}

BOOL CCaptureLinux::setPreviewRate(int rate, char *errorMessage) {
   // TODO
    return TRUE;
}

BOOL CCaptureLinux::getPreviewRate(int *rate, char *errorMessage) {
    sprintf(errorMessage,"grabber_getPreviewRate TODO");
    return FALSE;
}



void CCaptureLinux::setPreviewScale(BOOL scale){

}

BOOL CCaptureLinux::getCaptureAudio() {
   return FALSE;
}

void CCaptureLinux::setCaptureAudio(BOOL value){
}

BOOL CCaptureLinux::grabFrame(char *errorMessage){
    webcam_log( LOG_DEBUG, "grabFrame" );
    int readResult;
    int i;
    BOOL retcode = TRUE;

    if ( cam_fd < 0 ) {
        strcpy( errorMessage, "cam_fd is < 0" );
        return FALSE;
    }

    switch ( driver_params->io ) {
        case IO_METHOD_READ :
            for ( i = 0 ; i < validFrame; i++)  {
                webcam_mmapSync();
                readResult = read( cam_fd, yuvBuffer, yuvBufferSize );
                if ( yuvBufferSize != readResult ) {
                    sprintf( errorMessage, "error while reading frame: read()=%d yuvBufferSize=%d", readResult, yuvBufferSize );
                    webcam_log( LOG_DEBUG, "grabFrame : read returns %d : %s", readResult, strerror( errno ) );
                    retcode = FALSE;
                    break;
                }
            }
            readResult = read( cam_fd, yuvBuffer, yuvBufferSize );
            if ( yuvBufferSize != readResult ) {
                sprintf( errorMessage, "error while reading frame: read()=%d yuvBufferSize=%d", readResult, yuvBufferSize );
                webcam_log( LOG_DEBUG, "grabFrame : read returns %d : %s", readResult, strerror( errno ) );
                retcode = FALSE;
                break;
            }
            else
                yuv422_to_bgr24( yuvBuffer, bgrBuffer, currentWidth, currentHeight );
            break;

        case IO_METHOD_MMAP :
            /* Démarrage de la capture */
            if ( capturing == FALSE ) {
                capturing = startCapture( 0, 0, 0 );
                if ( capturing == FALSE ) {
                    retcode = FALSE;
                    break;
                }
            }

            // webcam_mmapSync();
            retcode = webcam_mmapCapture();
            break;

        default :
            retcode = FALSE;
    }
    return retcode;
}

/**
*----------------------------------------------------------------------
*
* capabilities
*
*----------------------------------------------------------------------
*/

BOOL CCaptureLinux::hasOverlay() {
   return FALSE;
}

BOOL CCaptureLinux::hasDlgVideoFormat() {
   return FALSE;
}

BOOL CCaptureLinux::hasDlgVideoSource() {
   return FALSE;
}

BOOL CCaptureLinux::hasDlgVideoDisplay() {
   return FALSE;
}


/**
*----------------------------------------------------------------------
*
* configuration dialogs
*
*----------------------------------------------------------------------
*/
BOOL CCaptureLinux::openDlgVideoFormat() {
   return FALSE;
}

BOOL CCaptureLinux::openDlgVideoSource() {
   return FALSE;
}

BOOL CCaptureLinux::openDlgVideoDisplay() {
   return FALSE;
}

BOOL CCaptureLinux::openDlgVideoCompression() {
   return FALSE;
}


/**
 *----------------------------------------------------------------------
 * startCapture
 *    starts streaming video capture with default saving method
 *    !!file space allocation must be done before calling startCaptureNoFile
 *
 * Parameters:
 *    none
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    allocate file space
 *    starts the capture sequence with saving file
 *----------------------------------------------------------------------
 */
BOOL CCaptureLinux::startCapture(unsigned short exptime, unsigned long microSecPerFrame, char * fileName) {
    BOOL retcode = FALSE;

    webcam_log( LOG_DEBUG, "startCapture" );

    switch ( driver_params->io ) {
        case IO_METHOD_READ :
            retcode = TRUE;
            break;

        case IO_METHOD_MMAP  :
            retcode = TRUE;
            /* Mappage dans l'espace mémoire local */
            mmap_buffers = (s_mmap_buffers *)calloc( n_mmap_buffers, sizeof( s_mmap_buffers ) );

            for ( unsigned int i = 0; i < n_mmap_buffers; i++ ) {
                struct v4l2_buffer buffer;

                memset ( &buffer, 0, sizeof (buffer) );
                buffer.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                buffer.memory = V4L2_MEMORY_MMAP;
                buffer.index = i;

                webcam_log( LOG_DEBUG, "startCapture : buffer n %d : ioctl VIDEOC_QUERYBUF", i );
                if ( -1 == ioctl( cam_fd, VIDIOC_QUERYBUF, &buffer ) ) {
                    webcam_log( LOG_DEBUG, "startCapture : %s ", strerror( errno ) );
                    return FALSE;
                }

                webcam_log( LOG_DEBUG, "startCapture : buffer n %d : ioctl VIDEOC_QUERYBUF : bytesused = %d / field = %d", i, buffer.bytesused, buffer.flags );

                mmap_buffers[i].length = buffer.length; /* remember for munmap() */
                mmap_buffers[i].start = mmap (NULL,
                                        buffer.length,
                                        PROT_READ | PROT_WRITE, /* recommended */
                                        MAP_SHARED,             /* recommended */
                                        cam_fd, buffer.m.offset);

                if ( MAP_FAILED == mmap_buffers[i].start ) {
                    webcam_log( LOG_ERROR, "startCapture : buffer n %d : %s", i, strerror( errno ) );
                    return FALSE;
                        /* If you do not exit here you should unmap() and free()
                           the buffers mapped so far. */
                        // perror ("mmap");
                        // exit (EXIT_FAILURE);
                }
            }

            /* Passage des buffers dans la queue d'entrée du pilote */
            for ( unsigned int i = 0; i < n_mmap_buffers; i++ ) {
                struct v4l2_buffer buffer;

                memset ( &buffer, 0, sizeof (buffer) );

                buffer.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                buffer.memory = V4L2_MEMORY_MMAP;
                buffer.index = i;

                webcam_log( LOG_DEBUG, " startCapture : buffer n %i : ioctl VIDEOC_QBUF", i );
                if ( -1 == ioctl( cam_fd, VIDIOC_QBUF, &buffer ) ) {
                    webcam_log( LOG_ERROR, "startCapture : buffer n %u : %s", i, strerror( errno ) );
                    retcode = FALSE;
                    break;
                }
            }

            enum v4l2_buf_type type;
            type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
            webcam_log( LOG_DEBUG, "startCapture : ioctl VIDEOC_STREAMON" );
            if ( -1 == ioctl( cam_fd, VIDIOC_STREAMON, &type ) ) {
                webcam_log( LOG_ERROR, "startCapture %s : ioctl VIDEOC_STREAMON : ", strerror( errno ) );
                retcode = FALSE;
                break;
            }
            break;

        default :
            retcode =  FALSE;
    }
    return retcode;
}

/**
 *----------------------------------------------------------------------
 * abortCapture
 *    abort the current capture
 *
 * Parameters:
 *    none
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    halt step capture at the current position
 *----------------------------------------------------------------------
 */
BOOL CCaptureLinux::abortCapture() {
    webcam_log( LOG_DEBUG, "abortCapture" );

    int retcode = TRUE;
    enum v4l2_buf_type type = V4L2_BUF_TYPE_VIDEO_CAPTURE;

    if ( capturing == TRUE ) {
        if ( driver_params->io == IO_METHOD_MMAP ) {
            webcam_log( LOG_DEBUG, "abortCapture : ioctl VIDEOC_STREAMOFF" );
            if ( -1 == ioctl( cam_fd, VIDIOC_STREAMOFF, &type ) ) {
                webcam_log( LOG_ERROR, "abortCapture %s : ioctl VIDEOC_STREAMOFF : ", strerror( errno ) );
                retcode = FALSE;
            }
            webcam_mmapDelete();
        }
        capturing = FALSE;
    }
    else {
        webcam_log( LOG_ERROR, "abortCapture %s : La caméra n'est pas en mode capture video" );
    }
    return retcode;
}

/**
 *----------------------------------------------------------------------
 * isCapturingNow
 *    return TRUE if capture is running
 *
 * Parameters:
 *    none
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *    refresh capStatus structure
 *
 *----------------------------------------------------------------------
 */
BOOL CCaptureLinux::isCapturingNow()
{
    webcam_log( LOG_DEBUG, "isCapturingNow" );
    return capturing;
}


/**
 *----------------------------------------------------------------------
 * readFrame
 *
 *
 * Parameters:
 *    bgrBuffer : must be pre-allocated
 * Results:
 *    TRUE or FALSE.
 * Side effects:
 *
 *
 *----------------------------------------------------------------------
 */
unsigned char * CCaptureLinux::getGrabbedFrame( char *errorMessage )
{
    webcam_log( LOG_DEBUG, "getGrabbedFrame" );

    return bgrBuffer;
}

/**
*----------------------------------------------------------------------
*
* window position
*
*----------------------------------------------------------------------
*/

/*
void CCaptureWinVfw::setScrollPos(POINT *pt) {
   if( hwndCap != NULL) {
      capSetScrollPos(hwndCap, pt);
   }
}
*/

void CCaptureLinux::getWindowPosition(int *x1, int *y1,int *x2,int *y2) {
}

void CCaptureLinux::setWindowPosition(int x1, int y1,int x2,int y2) {
}

void CCaptureLinux::setWindowSize(int width, int height) {
}

/*******************************************************/
/*  Fonctions d'acces direct à la mémoire video LINUX  */
/*                                                     */
/*                                                     */
/*******************************************************/

int CCaptureLinux::alloc_driver_memory( unsigned int nb_bloc ) {
    struct v4l2_requestbuffers reqbuf;
    int retcode = 0;

    webcam_log( LOG_DEBUG, "alloc_driver_memory nb_bloc = %d", nb_bloc );

    /* Allocation des blocs dans l'espace mémoire du pilote */
    memset( &reqbuf, 0, sizeof (reqbuf) );
    reqbuf.count = nb_bloc;
    reqbuf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    reqbuf.memory = V4L2_MEMORY_MMAP;

    if ( nb_bloc == 0 ) {
        /* Il s'agit d'une libération mémoire dans le pilote */
        webcam_log( LOG_DEBUG, "alloc_driver_memory : ioctl VIDEOC_REQBUFS" );
        if ( -1 == ioctl( cam_fd, VIDIOC_REQBUFS, &reqbuf ) ) {
            /* Certains pilotes ne sont pas conformes à l'API V4L2 et sortent en erreur si reqbuf.count vaut 0 */
            /* On se contente de tracer le problème, mais on ne sort pas en erreur systématiquement */
            webcam_log( LOG_WARNING, "alloc_driver_memory : strerror( errno )" );
            webcam_log( LOG_WARNING, "alloc_driver_memory : ce pilote ne supporte pas la libération de la mémoire interne." );
        }
        retcode = 0;
    }
    else { // ( nb_bloc > 0 )
        /* Il s'agit d'une allocation mémoire dans le pilote */
        webcam_log( LOG_DEBUG, "alloc_driver_memory : ioctl VIDEOC_REQBUFS" );
        if ( -1 == ioctl( cam_fd, VIDIOC_REQBUFS, &reqbuf ) ) {
            webcam_log( LOG_WARNING, "alloc_driver_memory : strerror( errno )" );
            retcode = -1;
        }
        else if ( reqbuf.count < 2 ) {
            /* Pas assez de blocs mémoire alloués */
            /* Désallocation des buffers alloués */
            webcam_log( LOG_ERROR, "alloc_driver_memory : pas assez de bloc mémoire alloués (reqbuf.count=%d)", reqbuf.count );
            webcam_log( LOG_DEBUG, "alloc_driver_memory : désallocation des blocs mémoire" );
            reqbuf.count = 0;
            ioctl( cam_fd, VIDIOC_REQBUFS, &reqbuf );
            retcode = -1;
        }
        else {
            n_mmap_buffers = reqbuf.count;
            retcode = 0;
        }
    }
    return retcode;
}

void CCaptureLinux::webcam_mmapSync() {
    webcam_log( LOG_DEBUG, "webcam_mmapSync" );

    for (;;) {
        fd_set fds;
        struct timeval tv;
        int r = 0;

        FD_ZERO ( &fds );
        FD_SET ( cam_fd, &fds );

        /* Timeout de 5s */
        tv.tv_sec = 5;
        tv.tv_usec = 0;

        webcam_log( LOG_DEBUG, "webcam_mmapSync select" );
        r = select ( cam_fd + 1, &fds, NULL, NULL, &tv );

        if ( r == -1 ) {
            if ( EINTR == errno ) {
                webcam_log( LOG_ERROR, "webcam_mmapSync %s", strerror( errno ) );
                continue;
            }
            else {
                webcam_log( LOG_ERROR, "webcam_mmapSync %s", strerror( errno ) );
                break;
            }
        }
        else if ( r == 0 ) {
            webcam_log( LOG_ERROR, "webcam_mmapSync select timeout" );
            break;
        }
        else {
            break;;
        }
    }
    webcam_log( LOG_DEBUG, "webcam_mmapSync end" );
}

unsigned char * CCaptureLinux::webcam_mmapLastFrame() {
    webcam_log( LOG_DEBUG, "webcam_mmapLastFrame" );
 return NULL;
}

BOOL CCaptureLinux::webcam_mmapCapture() {
    webcam_log( LOG_DEBUG, "webcam_mmapCapture" );

    struct v4l2_buffer buffer;
    memset ( &buffer, 0, sizeof (buffer) );

    buffer.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    buffer.memory = V4L2_MEMORY_MMAP;

    /* Récupération d'un buffer de la queue de sortie */
    webcam_log( LOG_DEBUG, "webcam_mmapCapture : ioctl VIDEOC_DQBUF" );
    if ( -1 == ioctl ( cam_fd, VIDIOC_DQBUF, &buffer ) ) {
        switch (errno) {
            case EAGAIN:
                webcam_log( LOG_ERROR, "webcam_mmapCapture : VIDIOC_DQBUF : %s", strerror( errno ) );
                return FALSE;

            case EIO:
                /* Could ignore EIO, see spec. */

                /* fall through */
            default:
                webcam_log( LOG_ERROR, "webcam_mmapCapture : VIDIOC_DQBUF : %s", strerror( errno ) );
        }
    }

    webcam_log( LOG_INFO, "webcam_mmapCapture : buffer n %d : ioctl VIDEOC_DQBUF : bytesused = %d / field = %d", buffer.index, buffer.bytesused, buffer.flags );

    if ( buffer.index >= n_mmap_buffers ) {
        webcam_log( LOG_ERROR, "webcam_mmapCapture : buffer index (%d) is greater than number of buffers (%d)", buffer.index, n_mmap_buffers );
        return FALSE;
    }
    if ( buffer.bytesused > (size_t)yuvBufferSize ) {
        webcam_log( LOG_ERROR, "webcam_mmapCapture : buffer n %d length (%d) is greater than YUV buffer (%d)", buffer.index, buffer.bytesused, yuvBufferSize );
        return FALSE;
    }
    webcam_log( LOG_INFO, "webcam_mmapCapture : buffer n %d received, with payload size %d", buffer.index, buffer.bytesused );

    switch ( driver_params->data_format ) {
        case FORMAT_YUV422 :
            yuv422_to_bgr24( (unsigned char *)mmap_buffers[buffer.index].start, bgrBuffer, currentWidth, currentHeight );
            break;
        case FORMAT_YUV420 :
            yuv420p_to_bgr24( (unsigned char *)mmap_buffers[buffer.index].start, bgrBuffer, currentWidth, currentHeight );
            break;
        case FORMAT_RGB24 :
            rgb24_to_bgr24( (unsigned char *)mmap_buffers[buffer.index].start, bgrBuffer, currentWidth, currentHeight );
            break;
        default :
            memset( bgrBuffer, 128, buffer.bytesused );
    }

    /* Remise du buffer dans la queue d'entrée */
    webcam_log( LOG_DEBUG, "webcam_mmapCapture : ioctl VIDEOC_QBUF" );
    if ( -1 == ioctl ( cam_fd, VIDIOC_QBUF, &buffer ) ) {
        webcam_log( LOG_ERROR, "webcam_mmapCapture : VIDIOC_DQBUF : %s", strerror( errno ) );
        return FALSE;
    }
    webcam_log( LOG_INFO, "webcam_mmapCapture : buffer n %d : ioctl VIDEOC_QBUF : bytesused = %d / field = %d", buffer.index, buffer.bytesused, buffer.flags );
    return TRUE;

}

void CCaptureLinux::webcam_mmapDelete() {
    for ( unsigned int i = 0; i < n_mmap_buffers; i++)
        munmap( mmap_buffers[i].start, mmap_buffers[i].length );
}


/******************************************************************/
/*  Fonctions conversion YUV, RGB  */
/*                                                                */
/*                                        */
/******************************************************************/


/**
 * Init Lookup tables for yuv to rgb conversion.
 * Code comes from xawtv.
*/
void CCaptureLinux::ng_color_yuv2rgb_init(void)
{
    webcam_log( LOG_DEBUG, "ng_color_yuv2rgb_init" );
   int i;

   /* init Lookup tables */
   for (i = 0; i < 256; i++) {
      ng_yuv_gray[i] = i * LUN_MUL >> 8;
      ng_yuv_red[i] = (RED_ADD + i * RED_MUL) >> 8;
      ng_yuv_blue[i] = (BLUE_ADD + i * BLUE_MUL) >> 8;
      ng_yuv_g1[i] = (GREEN1_ADD + i * GREEN1_MUL) >> 8;
      ng_yuv_g2[i] = (GREEN2_ADD + i * GREEN2_MUL) >> 8;
   }
   for (i = 0; i < CLIP; i++)
      ng_clip[i] = 0;
   for (; i < CLIP + 256; i++)
      ng_clip[i] = i - CLIP;
   for (; i < 2 * CLIP + 256; i++)
      ng_clip[i] = 255;
}


/**
 * Convert from yuv 4:2:0 to bgr.
 *
 * Code comes from xawtv, actually it converts to bgr
 * and flips vertically.
*/
void CCaptureLinux::yuv420p_to_bgr24( unsigned char *yuv, unsigned char *bgr, int width, int height )
{
    unsigned char *y, *u, *v, *d;
    unsigned char *us, *vs;
    unsigned char *dp;
    int i, j;
    int gray;

    dp = bgr + (height - 1) * width * 3;
    y = yuv;
    u = y + width * height;
    v = u + width * height / 4;

    for (i = 0; i < height; i++) {
        d = dp;
        us = u;
        vs = v;
        for (j = 0; j < width; j += 2) {
            gray = GRAY(*y);
            *(d++) = BLUE(gray, *u);
            *(d++) = GREEN(gray, *v, *u);
            *(d++) = RED(gray, *v);
            y++;
            gray = GRAY(*y);
            *(d++) = BLUE(gray, *u);
            *(d++) = GREEN(gray, *v, *u);
            *(d++) = RED(gray, *v);
            y++;
            u++;
            v++;
        }
        if (0 == (i % 2)) {
            u = us;
            v = vs;
        }
        dp -= width * 3;
    }
}

/**
 * Convert from yuv 4:2:2 to bgr.
 *
 * Code comes from xawtv, actually it converts to bgr
 * and flips vertically.
*/
void CCaptureLinux::yuv422_to_bgr24( unsigned char *yuv, unsigned char *bgr, int width, int height )
{
    webcam_log( LOG_DEBUG, "yuv422_to_bgr24" );

    unsigned char * s = yuv;

    // dp pointe sur la dernière ligne
    unsigned char * dp = bgr + ( height - 1 ) * width * 3;
    int gray;

    for ( int i = 0; i < height; i++ ) {
        unsigned char * d = dp;
        for ( int j = 0; j < width; j += 2 ) {
            gray = GRAY( s[0] );
            d[0] = BLUE( gray, s[1] );
            d[1] = GREEN( gray, s[3], s[1] );
            d[2] = RED( gray, s[3] );
            gray = GRAY( s[2] );
            d[3] = BLUE( gray, s[1] );
            d[4] = GREEN( gray, s[3], s[1] );
            d[5] = RED( gray, s[3] );
            d += 6;
            s += 4;
        }
        dp -= width * 3;
    }
}

/**
 * Copy and flip vertically an rgb buffer to a grb one
*/
void CCaptureLinux::rgb24_to_bgr24( unsigned char *rgb, unsigned char *bgr, int width, int height )
{
    webcam_log( LOG_DEBUG, "rgb24_to_bgr24" );

    unsigned char * s = rgb;

    for ( int i = 0; i < height; i++ ) {
        unsigned char * d = bgr + ( height - 1 - i ) * width * 3;
        for ( int j = 0; j < width; j++ ) {
            d[0] = s[2];
            d[1] = s[1];
            d[2] = s[0];
            s += 3;
            d += 3;
        }
    }
}
