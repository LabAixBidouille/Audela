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

static int current_image = 0;

static int
Avi_Cmd(ClientData cdata, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
 Tcl_SetObjResult(interp, Tcl_NewStringObj("Hello, World!", -1));
 return TCL_OK;
}

struct aviprop {
 Tcl_Interp * interp;
 char *path;
 int current_image;
 AVFormatContext *pFormatCtx;
 AVCodecContext *pCodecCtx;
 AVCodec *pCodec;
 AVFrame *pFrame, *pFrameRGB;
 uint8_t *buffer;
 int numBytes;
 int frameFinished;
 AVPacket packet;
 struct SwsContext * pSwsCtx;
 int videoStream;
 off_t filesize;
 off_t previous_offset;
};

static int
avi_load(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
 int i;
 char * path = argv[2];
 struct stat st;

 if(stat(path,&st) != 0) {
	 return TCL_ERROR;
 }

 avi->filesize = st.st_size;

 fprintf(stderr,"file size = %ld\n", avi->filesize);


 if(av_open_input_file(&avi->pFormatCtx, path, NULL, 0, NULL)!=0)
  return TCL_ERROR;

 if(av_find_stream_info(avi->pFormatCtx)<0)
	 return TCL_ERROR;

 dump_format(avi->pFormatCtx, 0, path, 0);

 avi->videoStream=-1;
 for(i=0; i<avi->pFormatCtx->nb_streams; i++)
	   if(avi->pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
		   avi->videoStream=i;
		   break;
	   }
 if(avi->videoStream==-1)
	 return TCL_ERROR;

 // Get a pointer to the codec context for the video stream
 avi->pCodecCtx=avi->pFormatCtx->streams[avi->videoStream]->codec;



 // Find the decoder for the video stream
 avi->pCodec=avcodec_find_decoder(avi->pCodecCtx->codec_id);
 if(avi->pCodec==NULL) {
    fprintf(stderr, "Unsupported codec!\n");
      return TCL_ERROR; // Codec not found
 }

 if(avcodec_open(avi->pCodecCtx, avi->pCodec)<0)
	 return TCL_ERROR;


 avi->pFrame=avcodec_alloc_frame();

 avi->pFrameRGB=avcodec_alloc_frame();

 avi->numBytes=avpicture_get_size(PIX_FMT_RGB24, avi->pCodecCtx->width,
		                             avi->pCodecCtx->height);
 avi->buffer=(uint8_t *)av_malloc(avi->numBytes*sizeof(uint8_t));
 avpicture_fill((AVPicture *)avi->pFrameRGB, avi->buffer, PIX_FMT_GRAY8,
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

 return TCL_OK;
}

static int
avi_next(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	int frameFinished;

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
    sws_scale( 	avi->pSwsCtx,
		avi->pFrame->data,
		avi->pFrame->linesize,
		0,
		avi->pCodecCtx->height,
		avi->pFrameRGB->data,
		avi->pFrameRGB->linesize
	);

    // src/libcam/libcam.c AcqRead
    if (Tcl_Eval(interp, "buf1 clear") == TCL_ERROR) {
	    //libcam_log(LOG_WARNING, "error in this command: result='%s'", interp->result);
	    if (Tcl_Eval(interp, "buf::create 1") == TCL_ERROR) {
		    //libcam_log(LOG_ERROR, "(libcam.c @ %d) error in the command '%s': result='%s'", __LINE__, s, interp->result);
	    }
    }

    {
	    char s[4000];
	    sprintf(s,"buf1 setpixels CLASS_GRAY %d %d FORMAT_BYTE COMPRESS_NONE %ld", avi->pCodecCtx->width, avi->pCodecCtx->height, avi->pFrameRGB->data[0]);
	    if (Tcl_Eval(interp, s) == TCL_ERROR) {
		    //libcam_log(LOG_ERROR, "(libcam.c @ %d) error in command '%s': result='%s'", __LINE__, s, interp->result);
		    //sprintf(errorMessage,"Errors setpixels: %s", interp->result);
		    fprintf(stderr, "ERROR setpixel\n");
	    }

    }
     break;	
    }
  }
    
  // Free the packet that was allocated by av_read_frame
  av_free_packet(&avi->packet);
  return TCL_OK;
}
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
 } else if (strcmp(argv[1], "close") == 0) {
	 return avi_close(avi,interp,argc,argv);
 } else {
	 return TCL_ERROR;
 }
}

static int
Avi_Create(ClientData cdata, Tcl_Interp *interp, int argc, char * argv[])
{
 char s[1000];
 struct aviprop * avi;
 avi = calloc(1, sizeof(struct aviprop));
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
	return TCL_OK;
}
