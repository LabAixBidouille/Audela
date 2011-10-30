
Plugin acqvideolinux

Aller sur http://www.ffmpeg.org
Sur la page "Download" dans la section "FFmpeg Releases" télécharger la version 0.8.5

Décompresser l'archive de façon à obtenir un répertoire /opt/ffmpeg-0.8.5

===
Dans /opt/ffmpeg-0.8.5 :

./configure --enable-pic --enable-shared \
 --disable-doc --disable-avdevice --disable-pthreads --disable-network \
 --disable-devices \
 --disable-protocols --enable-protocol=file \
 --disable-encoders \
 --disable-decoders --enable-decoder=ffvhuff --enable-decoder=huffyuv \
 --disable-muxers \
 --disable-demuxers --enable-demuxer=avi \
 --disable-bsfs \
 --disable-parsers

make

mkdir libs
cd libs
ln -s ../libavcodec/libavcodec.so
ln -s ../libavcodec/libavcodec.so.53
ln -s ../libavfilter/libavfilter.so
ln -s ../libavfilter/libavfilter.so.2
ln -s ../libavformat/libavformat.so
ln -s ../libavformat/libavformat.so.53
ln -s ../libavutil/libavutil.so
ln -s ../libavutil/libavutil.so.51
ln -s ../libswscale/libswscale.so
ln -s ../libswscale/libswscale.so.2

===

Editer $AUDELA/bin/audela.sh pour remplacer la ligne
typeset -x LD_LIBRARY_PATH=$chemin
par
typeset -x LD_LIBRARY_PATH=$chemin:$LD_LIBRARY_PATH

===

export LD_LIBRARY_PATH=/opt/ffmpeg-0.8.5/libs

===
Dans $AUDELA/gui/audace/plugin/tool/acqvideolinux/lib :

make

Verifier que la commande 'ldd libavi.so' va bien chercher les librairies dans /opt :
...
	libavformat.so.53 => /opt/ffmpeg-0.8.5/libs/libavformat.so.53 (0x00007f1d968e2000)
	libavcodec.so.53 => /opt/ffmpeg-0.8.5/libs/libavcodec.so.53 (0x00007f1d96552000)
	libavutil.so.51 => /opt/ffmpeg-0.8.5/libs/libavutil.so.51 (0x00007f1d96332000)
	libswscale.so.2 => /opt/ffmpeg-0.8.5/libs/libswscale.so.2 (0x00007f1d960f5000)
...

===

Dans $AUDELA/gui/audace/plugin/tool/acqvideolinux :

ln -s pkgIndex.tcl.nonactif pkgIndex.tcl

===

Lancer AudeLA avec $AUDELA/bin/audela.sh

===

Exemple rapide d'utilisation du module extraction.

Placer un fichier demo.avi dans $HOME/audela/images

Aller dans Fichier / Acquisition Video Linux puis cliquer sur Extraction

Cliquer sur "..." our ouvrir la boîte "Ouvrir une image".
Choisir Files of type : *
Choisir demo.avi

Dans la boîte Extraction Video : cliquer sur open
Si l'image est trop sombre : Affichage / Seuils... / OK
Faire défiler les images avec la barre de défilement.
Cliquer sur setmin pour marquer le début de la séquence.
Avancer dans le film puis cliquer sur setmax pour marquer la fin de la séquence.

Cliquer sur count pour compter le nombre d'images.

Entrer un répertoire de destination (il doit déjà exister) : par ex. /tmp/images
Entrer le prefixe de fichiers FITS à générer : par ex. img

Cliquer sur extract pour créer les fichiers /tmp/images/img1.fit etc.

