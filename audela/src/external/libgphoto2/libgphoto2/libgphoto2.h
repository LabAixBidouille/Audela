// File   :libgphoto.h .
// Date   :05/08/2005
// Author :Michel Pujol

// Description : simple API for libgphoto2 library

#ifndef __LIBGPHOTO_H__
#define __LIBGPHOTO_H__

#define LIBGPHOTO_OK 0
#define LIBGPHOTO_ERROR -1

#ifdef __cplusplus
extern "C" {
#endif


typedef struct _GPhotoSession GPhotoSession;

int libgphoto_openSession (GPhotoSession **gphotoSession, char * gphotoWinDllDir,int debug, char * debugPath);
int libgphoto_closeSession (GPhotoSession *gphotoSession);
int libgphoto_detectCamera(GPhotoSession *gphotoSession, char *cameraModel, char *cameraPath);
int libgphoto_openCamera(GPhotoSession *gphotoSession, char *cameraModel, char *cameraPath);
int libgphoto_closeCamera (GPhotoSession *gphotoSession);
int libgphoto_getsummary (GPhotoSession *gphotoSession);
int libgphoto_captureImage (GPhotoSession *gphotoSession, char * cameraFolder, char * cameraFile);
int libgphoto_captureImageWithoutCF (GPhotoSession *gphotoSession);
int libgphoto_captureAndLoadImageWithoutCF (GPhotoSession *gphotoSession, char * folder, char * file, char **imageData, unsigned long *imageSize, char **mimeType);
int libgphoto_loadImage   (GPhotoSession *gphotoSession, char * cameraFolder, char * cameraFile, char **imageData, unsigned long *imageLenght, char **mimeType);
int libgphoto_loadPreview (GPhotoSession *gphotoSession, char * cameraFolder, char * cameraFile, char **imageData, unsigned long *imageLenght, char *mimeType);
int libgphoto_deleteImage (GPhotoSession *gphotoSession, char * cameraFolder, char *cameraFile);
int libgphoto_startLongExposure(GPhotoSession *gphotoSession, int transfertMode);

// accessors
int libgphoto_setTransfertMode (GPhotoSession *gphotoSession, int value);
int libgphoto_getTimeValue (GPhotoSession *gphotoSession, float * timeValue);
int libgphoto_setTimeValue (GPhotoSession *gphotoSession, float timeValue);
int libgphoto_getDriveMode (GPhotoSession *gphotoSession, int * driveMode);
int libgphoto_setDriveMode (GPhotoSession *gphotoSession, int driveMode);
int libgphoto_getQuality (GPhotoSession *gphotoSession, char * quality);
int libgphoto_setQuality (GPhotoSession *gphotoSession, char * quality);

// log and errors
char * libgphoto_getLastErrorMessage(GPhotoSession *gphotoSession);
void libgphoto_setDebugLog(GPhotoSession *gphotoSession, int level, char *logFileName);
void libgphoto_closeLog(GPhotoSession *gphotoSession);

#ifdef __cplusplus
}
#endif

#endif
