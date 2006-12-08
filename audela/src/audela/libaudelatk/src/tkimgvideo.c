/* tkimgvideo.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL 
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

// $Id: tkimgvideo.c,v 1.1 2006-12-08 16:43:16 michelpujol Exp $

/* 
 * usage (WINDOWS only) :
 *  
 * //declare a new image type called "video" in TCL interpreter
 * Tkimgvideo_Init(Tcl_Interp *interp)
 *   
 *
 * // create a video widget instance  "image1" 
 * image create video "image1"  
 * 
 * // add "image1" in a canvas
 * .audace;can.canvas1 itemconfigure display -image "image1"
 *
 * // plug "image" to a video source 
 * image1 configure -source $HwndCapture
 * 
 * // set the zoom = 2 
 * image1 configure -zoom 2.0
 * 
 * // set the zoom = 1/2 
 * image1 configure -zoom 0.5
 * 
 * 
 * //unplug the video source
 * image1 configure -source 0
 * 
 * //delete video widget
 * image delete "image1"
 * 
 * 
*/

#include <tcl.h>
#include <tk.h>

#ifdef __WIN32__
#include <windows.h>       // for HWND and SetParent()
#include <vfw.h>
Window Tk_AttachHWND(Tk_Window tkwin, HWND hwnd);
HWND Tk_GetHWND(Window window);
#endif

/*
 * Definition of the data associated with each photo image master.
 */

typedef struct VideoMaster {
    Tk_ImageMaster tkMaster;	/* Tk's token for image master.  NULL means
				 * the image is being deleted. */
    Tcl_Interp *interp;		/* Interpreter associated with the
				 * application using this image. */
    Tcl_Command imageCmd;	/* Token for image command (used to delete
				 * it when the image goes away).  NULL means
				 * the image command has already been
				 * deleted. */
    int	flags;			/* Sundry flags, defined below. */
    int	width, height;		/* Dimensions of image. */
    int  userWidth, userHeight;	/* User-declared image dimensions. */
    int  source;
    double zoom;
    int  previousParentSource;
    struct VideoInstance *instancePtr;	/* First in the list of instances
				                            * associated with this master. */
} VideoMaster;


/*
 * The following data structure represents all of the instances of
 * a photo image in windows on a given screen that are using the
 * same colormap.
 */

typedef struct VideoInstance {
    VideoMaster *masterPtr;	/* Pointer to master for image. */
    Display *display;		/* Display for windows using this instance. */
    Colormap colormap;		/* The image may only be used in windows with
				 * this particular colormap. */
    struct VideoInstance *nextPtr;
				/* Pointer to the next instance in the list
				 * of instances associated with this master. */
    int refCount;		/* Number of instances using this structure. */
    int width, height;		/* Dimensions of the pixmap. */
    Tk_Window  tkParentWindow;
    Tk_Window  tkVideoWindow;
} VideoInstance;

/*
 * Functions used in the type record for photo images.
 */

static int		ImgVideoCreate _ANSI_ARGS_((Tcl_Interp *interp,
			    char *name, int objc, Tcl_Obj *CONST objv[],
			    Tk_ImageType *typePtr, Tk_ImageMaster master,
			    ClientData *clientDataPtr));
static ClientData	ImgVideoGet _ANSI_ARGS_((Tk_Window tkwin,
			    ClientData clientData));
static void		ImgVideoDisplay _ANSI_ARGS_((ClientData clientData,
			    Display *display, Drawable drawable,
			    int imageX, int imageY, int width, int height,
			    int drawableX, int drawableY));
static void		ImgVideoFree _ANSI_ARGS_((ClientData clientData,
			    Display *display));
static void		ImgVideoDelete _ANSI_ARGS_((ClientData clientData));
static int		ImgVideoPostscript _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, Tk_Window tkwin,
			    Tk_PostscriptInfo psInfo, int x, int y, int width,
			    int height, int prepass));

/*
 * The type record itself for photo images:
 */

Tk_ImageType tkVideoImageType = {
    "video",			   // name 
    ImgVideoCreate,		// createProc 
    ImgVideoGet,		   // getProc 
    ImgVideoDisplay,		// displayProc 
    ImgVideoFree,		   // freeProc 
    ImgVideoDelete,		// deleteProc 
    ImgVideoPostscript, // postscriptProc 
    (Tk_ImageType *) NULL	/* nextPtr */
};

/*
 * Default configuration
 */

#define DEF_VIDEO_HEIGHT	"0"
#define DEF_VIDEO_WIDTH		"0"
#define DEF_VIDEO_SOURCE   "0"
#define DEF_VIDEO_ZOOM     "1.0"

/*
 * Information used for parsing configuration specifications:
 */
static Tk_ConfigSpec configSpecs[] = {
    {TK_CONFIG_INT, "-source", (char *) NULL, (char *) NULL,
	 DEF_VIDEO_SOURCE, Tk_Offset(VideoMaster, source), TK_CONFIG_NULL_OK},

    {TK_CONFIG_DOUBLE, "-zoom", (char *) NULL, (char *) NULL,
	 DEF_VIDEO_ZOOM, Tk_Offset(VideoMaster, zoom), 0},

    {TK_CONFIG_INT, "-height", (char *) NULL, (char *) NULL,
	 DEF_VIDEO_HEIGHT, Tk_Offset(VideoMaster, userHeight), 0},
    
    {TK_CONFIG_INT, "-width", (char *) NULL, (char *) NULL,
	 DEF_VIDEO_WIDTH, Tk_Offset(VideoMaster, userWidth), 0},
    
    {TK_CONFIG_END, (char *) NULL, (char *) NULL, (char *) NULL,
	 (char *) NULL, 0, 0}
};


/*
 * Implementation of the Porter-Duff Source-Over compositing rule.
 */

#define PD_SRC_OVER(srcColor,srcAlpha,dstColor,dstAlpha) \
	(srcColor*srcAlpha/255) + dstAlpha*(255-srcAlpha)/255*dstColor/255
#define PD_SRC_OVER_ALPHA(srcAlpha,dstAlpha) \
	(srcAlpha + (255-srcAlpha)*dstAlpha/255)

/*
 * loacal Forward declarations
 */

static int	ImgPhotoCmd _ANSI_ARGS_((ClientData clientData,
			      Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]));
static void	ImgPhotoCmdDeletedProc _ANSI_ARGS_((
			      ClientData clientData));
static int	ImgVideoConfigureMaster _ANSI_ARGS_((
			      Tcl_Interp *interp, VideoMaster *masterPtr,
			      int objc, Tcl_Obj *CONST objv[], int flags));
static void ImgVideoConfigureInstance _ANSI_ARGS_((
			      VideoInstance *instancePtr));
static void	 DisposeInstance _ANSI_ARGS_((ClientData clientData));
static int   detachVideoSource( VideoInstance *instancePtr) ;
void setSource( VideoMaster *masterPtr, int source);
void setZoom( VideoMaster *masterPtr, double zoom);

/*
 *----------------------------------------------------------------------
 *
 * tkimgvideo_Init
 *
 *	Point d'entree TCL de la librairies
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	declare le nouveau type d'image "video"
 *
 *----------------------------------------------------------------------
 */

int Tkimgvideo_Init(Tcl_Interp *interp)
{
   /*
   if(Tcl_InitStubs(interp,"8.4",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in libak.",TCL_STATIC);
      return TCL_ERROR;
   }
   Tcl_PkgProvide(interp,"tkimgvideo","1.1");
   */

   Tk_CreateImageType(&tkVideoImageType);

   return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ImgVideoCreate --
 *
 *	This procedure is called by the Tk image code to create
 *	a new photo image.
 *
 * Parameters : 
 *    interp         Interpreter for application containing image. 
 *    char *name;		Name to use for image.
 *    int objc;		Number of arguments.
 *    objv[]         Argument objects for options (doesn't include image name or type)
 *    typePtr;	      Pointer to our type record (not used)
 *    master;	      Token for image, to be used by us in later callbacks.
 *    clientDataPtr;	 Store manager's token for image here; it will be returned in later callbacks.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	The data structure for a new photo image is allocated and
 *	initialized.
 *
 *----------------------------------------------------------------------
 */

static int
ImgVideoCreate(Tcl_Interp *interp, char *name, int objc, Tcl_Obj *CONST objv[], 
               Tk_ImageType *typePtr, Tk_ImageMaster master, ClientData *clientDataPtr)
{
   VideoMaster *masterPtr;
   
   
   // Allocate and initialize the photo image master record.
   masterPtr = (VideoMaster *) ckalloc(sizeof(VideoMaster));
   memset((void *) masterPtr, 0, sizeof(VideoMaster));
   masterPtr->tkMaster = master;
   masterPtr->interp = interp;
   masterPtr->imageCmd = Tcl_CreateObjCommand(interp, name, ImgPhotoCmd, (ClientData) masterPtr, ImgPhotoCmdDeletedProc);

   // Process configuration options given in the image create command.
   if (ImgVideoConfigureMaster(interp, masterPtr, objc, objv, 0) != TCL_OK) {
      ImgVideoDelete((ClientData) masterPtr);
      return TCL_ERROR;
   }
   
   *clientDataPtr = (ClientData) masterPtr;
   return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPhotoCmd --
 *
 *	This procedure is invoked to process the Tcl command that
 *	corresponds to a photo image.  See the user documentation
 *	for details on what it does.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *----------------------------------------------------------------------
 */

static int
ImgPhotoCmd(ClientData clientData, Tcl_Interp * interp, int objc, Tcl_Obj *CONST objv[])

{
   int oldformat = 0;
   static char *photoOptions[] = {
      "cget", "configure", (char *) NULL
   };
   enum options {
      VIDEO_CGET, VIDEO_CONFIGURE
   };
   
   VideoMaster *masterPtr = (VideoMaster *) clientData;
   int result, index;
   int length;

   if (objc < 2) {
      Tcl_WrongNumArgs(interp, 1, objv, "option ?arg arg ...?");
      return TCL_ERROR;
   }

   if (Tcl_GetIndexFromObj(interp, objv[1], photoOptions, "option", 0, &index) != TCL_OK) {
      return TCL_ERROR;
   }
   
   switch ((enum options) index) {
   case VIDEO_CGET: {
      char *arg;
      
      if (objc != 3) {
         Tcl_WrongNumArgs(interp, 2, objv, "option");
         return TCL_ERROR;
      }
      arg = Tcl_GetStringFromObj(objv[2], &length);
      if (strcmp(arg,"-source") == 0) {
         Tcl_SetObjResult(interp, Tcl_NewIntObj(masterPtr->source));
      } else if (strcmp(arg,"-zoom") == 0) {
         Tcl_SetObjResult(interp, Tcl_NewDoubleObj(masterPtr->zoom));
      } else {
         Tk_ConfigureValue(interp, Tk_MainWindow(interp), configSpecs,
            (char *) masterPtr, Tcl_GetString(objv[2]), 0);
      }
      return TCL_OK;
                    }
      
   case VIDEO_CONFIGURE:      
      if (objc == 2) {
         Tcl_Obj *obj, *subobj;
         result = Tk_ConfigureInfo(interp, Tk_MainWindow(interp),
            configSpecs, (char *) masterPtr, (char *) NULL, 0);
         if (result != TCL_OK) {
            return result;
         }
         obj = Tcl_NewObj();
         subobj = Tcl_NewStringObj("-source {} {} {}", 16);
         Tcl_ListObjAppendElement(interp, obj, subobj);
         Tcl_ListObjAppendList(interp, obj, Tcl_GetObjResult(interp));
         Tcl_SetObjResult(interp, obj);
         return TCL_OK;
      } else if (objc == 3) {
         char *arg = Tcl_GetStringFromObj(objv[2], &length);         
         if (!strcmp(arg, "-source")) {
            Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),"-source {} {} {}", (char *) NULL);
            Tcl_SetObjResult(interp, Tcl_NewIntObj(masterPtr->source));
            return TCL_OK;
         } else if (!strcmp(arg, "-zoom")) {
            Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),"-zoom {} {} {}", (char *) NULL);
            Tcl_SetObjResult(interp, Tcl_NewDoubleObj(masterPtr->zoom));
            return TCL_OK;
         } else {
            return Tk_ConfigureInfo(interp, Tk_MainWindow(interp),
               configSpecs, (char *) masterPtr, arg, 0);
         }
      } else {
         return ImgVideoConfigureMaster(interp, masterPtr, objc-2, objv+2,
            TK_CONFIG_ARGV_ONLY);
      }
   }
   panic("unexpected fallthrough");
   return TCL_ERROR; /* NOT REACHED */
}

/*
 *----------------------------------------------------------------------
 *
 * ImgVideoConfigureMaster --
 *
 *	This procedure is called when a photo image is created or
 *	reconfigured.  It processes configuration options and resets
 *	any instances of the image.
 *
 * Results:
 *	A standard Tcl return value.  If TCL_ERROR is returned then
 *	an error message is left in the masterPtr->interp's result.
 *
 * Side effects:
 *	Existing instances of the image will be redisplayed to match
 *	the new configuration options.
 *
 *----------------------------------------------------------------------
 */

static int
ImgVideoConfigureMaster(interp, masterPtr, objc, objv, flags)
    Tcl_Interp *interp;		/* Interpreter to use for reporting errors. */
    VideoMaster *masterPtr;	/* Pointer to data structure describing
				 * overall photo image to (re)configure. */
    int objc;			/* Number of entries in objv. */
    Tcl_Obj *CONST objv[];	/* Pairs of configuration options for image. */
    int flags;			/* Flags to pass to Tk_ConfigureWidget,
				 * such as TK_CONFIG_ARGV_ONLY. */
{
   int i, j;
   
   for (i = 0, j = 0; i < objc; i++,j++) {
      if (!strcmp(Tcl_GetString(objv[i]), "-source")) {
         if (++i < objc) {
            int source = 0;
            if (Tcl_GetIntFromObj(interp,objv[i],&source)!=TCL_OK) {
               Tcl_AppendResult(interp, "value for \"-source\" not integer", (char *) NULL);
               return TCL_ERROR;
            } else {
               if ( source != masterPtr->source ) {
                  setSource(masterPtr, source);
               }
            }
         } else {
            Tcl_AppendResult(interp, "value for \"-source\" missing", (char *) NULL);
            return TCL_ERROR;
         }
      } 
      if (!strcmp(Tcl_GetString(objv[i]), "-zoom")) {
         if (++i < objc) {
            double zoom = 0;
            if (Tcl_GetDoubleFromObj(interp,objv[i],&zoom)!=TCL_OK) {
               Tcl_AppendResult(interp, "value for \"-zoom\" not double", (char *) NULL);
               return TCL_ERROR;
            } else {
               setZoom(masterPtr, zoom);
            }
         } else {
            Tcl_AppendResult(interp, "value for \"-zoom\" missing", (char *) NULL);
            return TCL_ERROR;
         }
      } 
   }
   
   return TCL_OK;   
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPhotoConfigureInstance --
 *
 *	This procedure is called to create displaying information for
 *	a photo image instance based on the configuration information
 *	in the master.  It is invoked both when new instances are
 *	created and when the master is reconfigured.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Generates errors via Tcl_BackgroundError if there are problems
 *	in setting up the instance.
 *
 *----------------------------------------------------------------------
 */
 
static void ImgVideoConfigureInstance(VideoInstance *instancePtr)
{
   VideoMaster *masterPtr = instancePtr->masterPtr;   
   Window  videoWindow;
   
   if ( masterPtr->source != 0  && instancePtr->tkParentWindow != 0 ) {
      
      if ( instancePtr->tkVideoWindow == 0 ) {
         //instancePtr->tkVideoWindow = Tk_CreateAnonymousWindow(masterPtr->interp, instancePtr->tkParentWindow, (char*) NULL);
         instancePtr->tkVideoWindow = Tk_CreateWindow(masterPtr->interp, instancePtr->tkParentWindow, "video", (char*) NULL);
         Tk_MapWindow(instancePtr->tkVideoWindow);
      }

      //videoWindow = attachVideoSource(instancePtr->tkVideoWindow, masterPtr->source );
#ifdef __WIN32__
       videoWindow= Tk_AttachHWND(instancePtr->tkVideoWindow,(HWND) masterPtr->source);
       masterPtr->previousParentSource = (int) SetParent((HWND) masterPtr->source, (HWND) Tk_GetHWND(Tk_WindowId(Tk_Parent(instancePtr->tkVideoWindow))));
#endif
   }
}


/*
*----------------------------------------------------------------------
*
* ImgVideoGet --
*
*	This procedure is called for each use of a photo image in a
*	widget.
*
* Parameters :
*    tkwin;		Window in which the instance will be used. 
*    masterData;	 Pointer to our master structure for the image.
*
* Results:
*	The return value is a token for the instance, which is passed
*	back to us in calls to ImgVideoDisplay and ImgVideoFree.
*
* Side effects:
*	A data structure is set up for the instance (or, an existing
*	instance is re-used for the new one).
*
*----------------------------------------------------------------------
*/

static ClientData ImgVideoGet(Tk_Window tkwin, ClientData masterData)
{
   VideoMaster *masterPtr = (VideoMaster *) masterData;
   VideoInstance *instancePtr;

   
   // See if there is already an instance for windows using
   // the same source.  If so then just re-use it.
   for (instancePtr = masterPtr->instancePtr; instancePtr != NULL; instancePtr = instancePtr->nextPtr) {
      if ((Tk_Display(tkwin) == instancePtr->display)) {
         // Re-use this instance.
         if (instancePtr->refCount == 0) {
            //  We are resurrecting this instance.            
            Tcl_CancelIdleCall(DisposeInstance, (ClientData) instancePtr);
            instancePtr->refCount++;
            return (ClientData) instancePtr;
         }
      }
   }
   
   // Make a new instance of the video.
   instancePtr = (VideoInstance *) ckalloc(sizeof(VideoInstance));
   instancePtr->masterPtr = masterPtr;
   instancePtr->display = Tk_Display(tkwin);
   instancePtr->tkParentWindow = tkwin;
   instancePtr->tkVideoWindow = 0;
   instancePtr->refCount = 1;
   instancePtr->width = 0;
   instancePtr->height = 0;

   instancePtr->nextPtr = masterPtr->instancePtr;
   masterPtr->instancePtr = instancePtr;

   ImgVideoConfigureInstance(instancePtr);
        
   return (ClientData) instancePtr ; // for calls to ImgVideoDisplay and ImgVideoFree 
}


/*
 *----------------------------------------------------------------------
 *
 * ImgVideoDisplay --
 *
 *	This procedure is invoked to draw a photo image.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	A portion of the image gets rendered in a pixmap or window.
 *
 *----------------------------------------------------------------------
 */

static void
ImgVideoDisplay(clientData, display, drawable, imageX, imageY, width,
	height, drawableX, drawableY)
    ClientData clientData;	/* Pointer to VideoInstance structure for
				 * for instance to be displayed. */
    Display *display;		/* Display on which to draw image. */
    Drawable drawable;		/* Pixmap or window in which to draw image. */
    int imageX, imageY;		/* Upper-left corner of region within image
				 * to draw. */
    int width, height;		/* Dimensions of region within image to draw. */
    int drawableX, drawableY;	/* Coordinates within drawable that
				 * correspond to imageX and imageY. */
{
   // pas de réfraichissement nécessaire pour une video
}


/*
 *----------------------------------------------------------------------
 *
 * ImgVideoFree --
 *
 *	This procedure is called when a widget ceases to use a
 *	particular instance of an image.  We don't actually get
 *	rid of the instance until later because we may be about
 *	to get this instance again.
 *
 *  parameters :
 *      clientData  Pointer to VideoInstance structure for for instance to be displayed. 
 *	 	  display      Display containing window that used image. 
 * Results:
 *	None.
 *
 * Side effects:
 *	Internal data structures get cleaned up, later.
 *
 *----------------------------------------------------------------------
 */

static void
ImgVideoFree(ClientData clientData, Display *display)
{
   VideoInstance *instancePtr = (VideoInstance *) clientData;
   
   instancePtr->refCount -= 1;
   if (instancePtr->refCount > 0) {
      return;
   }
   
   Tcl_DoWhenIdle(DisposeInstance, (ClientData) instancePtr);

}

/*
 *----------------------------------------------------------------------
 *
 * ImgVideoDelete --
 *
 *	This procedure is called by the image code to delete the
 *	master structure for an image.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Resources associated with the image get freed.
 *
 *----------------------------------------------------------------------
 */

static void ImgVideoDelete(ClientData masterData)
{
   VideoMaster *masterPtr = (VideoMaster *) masterData;
   VideoInstance *instancePtr;

   while ((instancePtr = masterPtr->instancePtr) != NULL) {
      if (instancePtr->refCount > 0) {
         panic("tried to delete photo image when instances still exist");
      }
      Tcl_CancelIdleCall(DisposeInstance, (ClientData) instancePtr);
      DisposeInstance((ClientData) instancePtr);
   }

   masterPtr->tkMaster = NULL;
   if (masterPtr->imageCmd != NULL) {
      Tcl_DeleteCommandFromToken(masterPtr->interp, masterPtr->imageCmd);
   }

   ckfree((char *) masterPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPhotoCmdDeletedProc --
 *
 *	This procedure is invoked when the image command for an image
 *	is deleted.  It deletes the image.
 *
 * Parameters : 
 *    clientData Pointer to VideoMaster structure for image
 * Results:
 *	None.
 *
 * Side effects:
 *	The image is deleted.
 *
 *----------------------------------------------------------------------
 */

static void
ImgPhotoCmdDeletedProc(ClientData clientData)
{
   VideoMaster *masterPtr = (VideoMaster *) clientData;
    
   masterPtr->imageCmd = NULL;
}

/*
 *----------------------------------------------------------------------
 *
 * DisposeInstance --
 *
 *	This procedure is called to finally free up an instance
 *	of a photo image which is no longer required.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The instance data structure and the resources it references
 *	are freed.
 *
 *----------------------------------------------------------------------
 */

static void DisposeInstance(ClientData clientData)
{
   VideoInstance *instancePtr = (VideoInstance *) clientData;
   VideoInstance *prevPtr;
   
   if (instancePtr->tkVideoWindow != NULL) {
      if ( instancePtr->masterPtr->source != 0 ) {
         detachVideoSource(instancePtr);
      }
      Tk_UnmapWindow(instancePtr->tkVideoWindow);
      Tk_DestroyWindow(instancePtr->tkVideoWindow);
      instancePtr->tkVideoWindow = NULL;
   }
   
   
   if (instancePtr->masterPtr->instancePtr == instancePtr) {
      instancePtr->masterPtr->instancePtr = instancePtr->nextPtr;
   } else {
      for (prevPtr = instancePtr->masterPtr->instancePtr;
         prevPtr->nextPtr != instancePtr; prevPtr = prevPtr->nextPtr) {
         /* Empty loop body */
      }
      prevPtr->nextPtr = instancePtr->nextPtr;
   }


   ckfree((char *) instancePtr);
}

 
/*
 *--------------------------------------------------------------
 *
 * TkPostscriptPhoto --
 *
 *	This procedure is called to output the contents of a
 *	photo image in Postscript by calling the Tk_PostscriptPhoto
 *	function.
 *
 * Results:
 *	Returns a standard Tcl return value.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */
static int
ImgVideoPostscript(clientData, interp, tkwin, psInfo,
        x, y, width, height, prepass)
     ClientData clientData;	/* Handle for the photo image */
    Tcl_Interp *interp;		/* Interpreter */
    Tk_Window tkwin;		/* (unused) */
    Tk_PostscriptInfo psInfo;	/* postscript info */
    int x, y;			/* First pixel to output */
    int width, height;		/* Width and height of area */
    int prepass;		/* (unused) */
{
    return TCL_ERROR;
}


/*
 *--------------------------------------------------------------
 *
 * detachVideoSource (WIN32 only)
 *
 *	This procedure attachs the video HWND  to the tkWindow 
 *
 * Results:
 *	Returns a standard Tcl return value.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */
int detachVideoSource( VideoInstance *instancePtr) {
#ifdef WIN32   
   if (Tk_MainWindow(instancePtr->masterPtr->interp) != NULL ) {
      // je detache la source pour eviter que la destruction de tkVideoWindow ne change le parent de hwndSource
      Tk_AttachHWND(instancePtr->tkVideoWindow, (HWND) NULL);
   }
   if(instancePtr->masterPtr->source != 0 ) {
       // je restaure l'ancien parent
       SetParent((HWND) instancePtr->masterPtr->source, (HWND) instancePtr->masterPtr->previousParentSource);
   }
#endif   
   return TCL_OK;
}


/*
 *--------------------------------------------------------------
 *
 * setSource (WIN32 only)
 *
 *	This procedure sets the zoom 
 *
 * Results:
 *	Returns a standard Tcl return value.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */
void setSource( VideoMaster *masterPtr, int source) {
   VideoInstance *instancePtr;

   if ( source != 0 ) {   
      if ( masterPtr->source != 0) {
         // detach  previous source
         for (instancePtr = masterPtr->instancePtr; instancePtr != NULL; instancePtr = instancePtr->nextPtr) {
            detachVideoSource(instancePtr );
         }
      }      
      // set new source
      masterPtr->source = source;
   
      // configure instance with the new source
      for (instancePtr = masterPtr->instancePtr; instancePtr != NULL; instancePtr = instancePtr->nextPtr) {
         ImgVideoConfigureInstance(instancePtr);
      }
   } else {
      // detach  previous source
      for (instancePtr = masterPtr->instancePtr; instancePtr != NULL; instancePtr = instancePtr->nextPtr) {
         detachVideoSource(instancePtr);
      }
      // erase source
      masterPtr->source = source;
   }
}

/*
 *--------------------------------------------------------------
 *
 * setZoom (WIN32 only)
 *
 *	This procedure sets the zoom 
 *
 * Results:
 *	Returns a standard Tcl return value.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */
void setZoom( VideoMaster *masterPtr, double zoom) {
#ifdef WIN32
   HWND hwndCap;
   CAPSTATUS capStatus;

   masterPtr->zoom = zoom;   
   hwndCap = (HWND) masterPtr->source;
   if ( hwndCap == NULL) {
      return;
   }

   if (capGetStatus(hwndCap, &capStatus, sizeof(CAPSTATUS)) == TRUE ) {
      int width = (int) (zoom * capStatus.uiImageWidth);
      int height = (int) (zoom * capStatus.uiImageHeight);

      //Tk_ResizeWindow(tkwin, width, height);
      SetWindowPos( 
         hwndCap,             // handle to window
         NULL,             // placement-order handle
         100,                // horizontal position
         100,                 // vertical position
         width,            // width
         height,           // height
         SWP_NOMOVE | SWP_NOOWNERZORDER // window-positioning flags
      );
      
      if ( masterPtr->zoom == 1.) {
         // video scale doesn't depend on window size
         capPreviewScale( hwndCap, FALSE);
      } else {
         // video scale depends on windows size
         capPreviewScale( hwndCap, TRUE);
      } 
   }


   #endif   
}

