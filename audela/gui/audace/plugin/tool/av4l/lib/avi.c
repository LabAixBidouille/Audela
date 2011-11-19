/* :set ts=4 sw=4 et */

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#define _FILE_OFFSET_BITS 64
#define _LARGEFILE64_SOURCE

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "avformat.h"
#include "avcodec.h"
#include "swscale.h"

#include <sys/stat.h>

#include <tcl.h>

#define LIBNAME "av4l"

struct aviprop {
    Tcl_Interp * interp;
    int status;
    char *path; //!< chemin complet du fichier avi
    int current_image;
    AVFormatContext *pFormatCtx;
    int videoStream; //!< index du flux video
    AVCodecContext *pCodecCtx;
    AVCodec *pCodec;
    AVFrame *pFrame; //!< image provenant du flux
    AVFrame *pFrameRGB; //!< image apres conversion
    AVPacket packet;
    struct SwsContext * pSwsCtx;
    off_t filesize; //!< taille du fichier avi en octets
    off_t previous_offset;
};


static int
avi_load(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
    int i;
    char * path = argv[2];
    struct stat st;
    uint8_t *buffer;
    int numBytes;

    if(stat(path,&st) != 0) {
        Tcl_SetResult(interp, "File not found in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }

    avi->filesize = st.st_size;

    //fprintf(stderr,"file size = %ld\n", avi->filesize);


    if(avformat_open_input(&avi->pFormatCtx, path, NULL, NULL)!=0) {
        Tcl_SetResult(interp, "File open failed in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }

    if(av_find_stream_info(avi->pFormatCtx)<0) {
        Tcl_SetResult(interp, "Stream info not found in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }

    // Dump format on stdout/stderr
    av_dump_format(avi->pFormatCtx, 0, path, 0);

    // Find the video stream
    avi->videoStream=-1;
    for(i=0; i<avi->pFormatCtx->nb_streams; i++) {
        if(avi->pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
            avi->videoStream=i;
            break;
        }
    }

    if(avi->videoStream==-1) {
        Tcl_SetResult(interp, "No video stream found in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }

    // Get a pointer to the codec context for the video stream
    avi->pCodecCtx = avi->pFormatCtx->streams[avi->videoStream]->codec;

    // Find the decoder for the video stream
    avi->pCodec = avcodec_find_decoder(avi->pCodecCtx->codec_id);
    if(avi->pCodec==NULL) {
        Tcl_SetResult(interp, "Unsupported codec in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }

    if(avcodec_open(avi->pCodecCtx, avi->pCodec)<0){
        Tcl_SetResult(interp, "Open codec failed in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }


    avi->pFrame = avcodec_alloc_frame();

    avi->pFrameRGB = avcodec_alloc_frame();

    numBytes=avpicture_get_size(PIX_FMT_RGB24, avi->pCodecCtx->width,
            avi->pCodecCtx->height);
    buffer=(uint8_t *)av_malloc(numBytes*sizeof(uint8_t));
    avpicture_fill((AVPicture *)avi->pFrameRGB, buffer, PIX_FMT_GRAY8,
            avi->pCodecCtx->width, avi->pCodecCtx->height);
    avi->pSwsCtx = sws_getContext(
            avi->pCodecCtx->width, avi->pCodecCtx->height, avi->pCodecCtx->pix_fmt,
            avi->pCodecCtx->width, avi->pCodecCtx->height, PIX_FMT_GRAY8,
            SWS_BICUBIC,
            NULL, NULL,
            NULL
            );

    avi->current_image = -1;

    avi->previous_offset = 0;

    avi->status = 0;

    return TCL_OK;
}

// Procedure independante appelee uniquement par le module d'acquisition
// argv[1] chemin d'une image brute YUYV422 ( format packed )
static int
convert_shared_image(ClientData cdata, Tcl_Interp *interp, int argc, const char * argv[])
{
    static AVFrame *pFrame = 0, *pFrameRGB = 0;
    static struct SwsContext * pSwsCtx = 0;

    const char * path = argv[1];
    struct stat st;
    off_t filesize = 0;
    int width, height;
    static int numBytesSrc;
    static int numBytesDst;
    uint8_t *buffer;

    width = height = 0;
    if(stat(path,&st) != 0) {
        return TCL_ERROR;
    }
    filesize = st.st_size;
    //fprintf(stderr,"file size = %lld\n", filesize);
    if(filesize == 2*720*576) {
        width = 720; height=576;
    } else if (filesize == 2*640*480) {
        width = 640; height=480;
    } else {
        Tcl_SetResult(interp, "Size of image not detected in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }


    if(pFrame == 0) {
        pFrame=avcodec_alloc_frame();
        numBytesSrc=avpicture_get_size(PIX_FMT_YUYV422, width, height);
        fprintf(stderr,"numBytesSrc = %d\n",numBytesSrc);
        buffer=(uint8_t *)av_malloc(numBytesSrc*sizeof(uint8_t));
        avpicture_fill((AVPicture *)pFrame, buffer, PIX_FMT_YUYV422, width, height);
        fprintf(stderr," %d %d %d\n",pFrame->linesize[0], pFrame->linesize[1], pFrame->linesize[2]);
        pFrameRGB=avcodec_alloc_frame();
        numBytesDst=avpicture_get_size(PIX_FMT_GRAY8, width, height);
        buffer=(uint8_t *)av_malloc(numBytesDst*sizeof(uint8_t));
        avpicture_fill((AVPicture *)pFrameRGB, buffer, PIX_FMT_GRAY8, width, height);
        pSwsCtx = sws_getContext(
            width, height, PIX_FMT_YUYV422,
            width, height, PIX_FMT_GRAY8,
            SWS_BICUBIC,
            NULL, NULL,
            NULL
            );
    }

    {
        FILE *fp = fopen(path,"r");
        if(fp) {
            fread(pFrame->data[0],numBytesSrc,1,fp);
            fclose(fp);
        }
    }

    sws_scale( pSwsCtx,
            pFrame->data,
            pFrame->linesize,
            0,
            height,
            pFrameRGB->data,
            pFrameRGB->linesize
            );

    if (Tcl_Eval(interp, "buf1 clear") == TCL_ERROR) {
        if (Tcl_Eval(interp, "buf::create 1") == TCL_ERROR) {
            Tcl_SetResult(interp, "buf::create failed in " LIBNAME ".", TCL_VOLATILE);
            return TCL_ERROR;
        }
    }

    {
        char s[4000];
        sprintf(s,"buf1 setpixels CLASS_GRAY %d %d FORMAT_BYTE COMPRESS_NONE %ld", width, height, pFrameRGB->data[0]);
        if (Tcl_Eval(interp, s) == TCL_ERROR) {
            Tcl_SetResult(interp, "buf1 setpixels failed in " LIBNAME ".", TCL_VOLATILE);
            return TCL_ERROR;
        }

    }

    return TCL_OK;
}

static int
avi_next(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
    int frameFinished = 0;

    avi->previous_offset = avi->pFormatCtx->pb->pos;

    while(av_read_frame(avi->pFormatCtx, &avi->packet)>=0) {
        // Is this a packet from the video stream?
        if(avi->packet.stream_index==avi->videoStream) {
            // Decode video frame
            avcodec_decode_video2(avi->pCodecCtx, avi->pFrame, &frameFinished,
                    &avi->packet);

            // Did we get a video frame?
            if(frameFinished) {
                // Convert the image from its native format to RGB
                sws_scale( avi->pSwsCtx,
                        avi->pFrame->data,
                        avi->pFrame->linesize,
                        0,
                        avi->pCodecCtx->height,
                        avi->pFrameRGB->data,
                        avi->pFrameRGB->linesize
                        );

                if (Tcl_Eval(interp, "buf1 clear") == TCL_ERROR) {
                    if (Tcl_Eval(interp, "buf::create 1") == TCL_ERROR) {
                        Tcl_SetResult(interp, "buf::create failed in " LIBNAME ".", TCL_VOLATILE);
                        return TCL_ERROR;
                    }
                }

                {
                    char s[4000];
                    sprintf(s,"buf1 setpixels CLASS_GRAY %d %d FORMAT_BYTE COMPRESS_NONE %ld", avi->pCodecCtx->width, avi->pCodecCtx->height, avi->pFrameRGB->data[0]);
                    if (Tcl_Eval(interp, s) == TCL_ERROR) {
                        Tcl_SetResult(interp, "buf1 setpixels failed in " LIBNAME ".", TCL_VOLATILE);
                        return TCL_ERROR;
                    }

                }
                av_free_packet(&avi->packet);
                break;	
            }
        }

        // Free the packet that was allocated by av_read_frame
        av_free_packet(&avi->packet);
        return TCL_OK;
    }
    return TCL_OK;
}





// Test en tout genre
static int
avi_test(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	char s[1000];
	sprintf(s,"%s","** pFormatCtx **\n");
	sprintf(s,"%s %s %lld \n",s,"nb img = ",avi->pFormatCtx->streams[avi->videoStream]->nb_frames);
	sprintf(s,"%s %s %d \n",s,"index = ",avi->packet.stream_index);
	sprintf(s,"%s %s %d \n",s,"bit_rate = ",avi->pFormatCtx->bit_rate);
	sprintf(s,"%s %s %d \n",s,"packed_size = ",avi->pFormatCtx->packet_size);
//	sprintf(s,"%s %s %d \n",s,"key = ",avi->pFormatCtx->key);
	sprintf(s,"%s %s %d \n",s,"keylen = ",avi->pFormatCtx->keylen);
	sprintf(s,"%s","** streams **\n");
	sprintf(s,"%s %s %lld \n",s,"first_pts = ", avi->pFormatCtx->streams[avi->videoStream]->first_dts);
	sprintf(s,"%s %s %lld \n",s,"start_time = ", avi->pFormatCtx->streams[avi->videoStream]->start_time);
	sprintf(s,"%s %s %lld \n",s,"cur_dts = ", avi->pFormatCtx->streams[avi->videoStream]->cur_dts);
	sprintf(s,"%s %s %lld \n",s,"last_IP_pts = ", avi->pFormatCtx->streams[avi->videoStream]->last_IP_pts);
	sprintf(s,"%s %s %lld \n",s,"nb_index_entries = ", avi->pFormatCtx->streams[avi->videoStream]->nb_index_entries);
	sprintf(s,"%s %s %lld \n",s,"duration = ", avi->pFormatCtx->streams[avi->videoStream]->duration);
	sprintf(s,"%s %s %lld \n",s,"pts_wrap_bits = ", avi->pFormatCtx->streams[avi->videoStream]->pts_wrap_bits);




	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}







static int
avi_seek_percent(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	int frameFinished;
	int i;
	double pos;
	off_t off;

	Tcl_GetDouble(interp, argv[2], &pos);
	off = pos * avi->filesize;
	//ff_read_frame_flush(avi->pFormatCtx);
	i = av_seek_frame(avi->pFormatCtx, -1, off, AVSEEK_FLAG_BYTE);
	avi->previous_offset = avi->pFormatCtx->pb->pos;
	return TCL_OK;
}

static int
avi_seek_byte(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	int frameFinished;
	int i;
	int pos;
	off_t off;

	Tcl_GetInt(interp, argv[2], &pos);
	off = pos;

	i = av_seek_frame(avi->pFormatCtx, -1, off, AVSEEK_FLAG_BYTE);
	//fprintf(stderr,"seek pos %lld\n", avi->pFormatCtx->pb->pos);
	avi->previous_offset = avi->pFormatCtx->pb->pos;
	return TCL_OK;
    
}

static int
avi_get_offset(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	char s[100];
	sprintf(s,"%lld",avi->pFormatCtx->pb->pos);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}

static int
avi_get_previous_offset(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	char s[100];
	sprintf(s,"%lld",avi->previous_offset);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}

static int
avi_close(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
    // TODO
	return TCL_OK;
}

static int
avi_status(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	char s[100];
	sprintf(s,"%d",avi->status);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}

static int
avi_count(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	int posmin, posmax,pos;
	int count=0;
	char s[100];
	int frameFinished;

	Tcl_GetInt(interp,argv[2],&posmin);
	Tcl_GetInt(interp,argv[3],&posmax);
	av_seek_frame(avi->pFormatCtx, -1, posmin, AVSEEK_FLAG_BYTE);
	for(;;) {
	 pos=avi->pFormatCtx->pb->pos;
	 if(pos>posmax) break;
	 {
		while(av_read_frame(avi->pFormatCtx, &avi->packet)>=0) {
			 if(avi->packet.stream_index==avi->videoStream) {
                                 break;
			 }
		 }

		av_free_packet(&avi->packet);
	 }
	 count++;
	}
	sprintf(s,"%ld",count);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}






// Renvoit le nombre total d'images de la video
static int
avi_get_nb_frames(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	char s[100];
	sprintf(s,"%lld",avi->pFormatCtx->streams[avi->videoStream]->nb_frames);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}







static int
cmdAvi(ClientData cdata, Tcl_Interp *interp, int argc, char * argv[])
{
    struct aviprop * avi = (struct aviprop *)cdata;

    if (argc == 1) {
        return TCL_ERROR;
    }

    if( strcmp(argv[1], "load") == 0 ) {
        return avi_load(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "next") == 0) {
        return avi_next(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "seekpercent") == 0) {
        return avi_seek_percent(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "seekbyte") == 0) {
        return avi_seek_byte(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "getoffset") == 0) {
        return avi_get_offset(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "getpreviousoffset") == 0) {
        return avi_get_previous_offset(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "count") == 0) {
        return avi_count(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "get_nb_frames") == 0) {
        return avi_get_nb_frames(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "test") == 0) {
        return avi_test(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "close") == 0) {
        return avi_close(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "status") == 0) {
        return avi_status(avi,interp,argc,argv);
    } else {
        return TCL_ERROR;
    }
}

static int
Avi_Create(ClientData cdata, Tcl_Interp *interp, int argc, const char * argv[])
{
    char s[1000];
    struct aviprop * avi;

    avi = calloc(1, sizeof(struct aviprop));
    avi->status = -1;
    avi->interp = interp;

    Tcl_CreateCommand(interp, argv[1], (Tcl_CmdProc *) cmdAvi, (ClientData) avi, NULL);

    sprintf(s,"%d",argc);
    Tcl_SetResult(interp, s, TCL_VOLATILE);
    return TCL_OK;
}


int
Avi_Init(Tcl_Interp *interp)
{
    Tcl_Namespace *nsPtr;

    av_register_all();

    if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) {
        return TCL_ERROR;
    }
    nsPtr = Tcl_CreateNamespace(interp, "avi", NULL, NULL);
    if (nsPtr == NULL) {
        return TCL_ERROR;
    }

    /* changed this to check for an error - GPS */
    if (Tcl_PkgProvide(interp, "Avi", "1.0") == TCL_ERROR) {
        return TCL_ERROR;
    }

    Tcl_CreateCommand(interp, "::avi::create", Avi_Create, NULL, NULL);

    Tcl_CreateCommand(interp, "::avi::convert_shared_image", convert_shared_image, NULL, NULL);

    return TCL_OK;
}
