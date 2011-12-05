
Plugin av4l

Aller sur http://www.ffmpeg.org
Sur la page "Download" dans la section "FFmpeg Releases" télécharger la version 0.8.5

Décompresser l'archive de façon à obtenir un répertoire /opt/ffmpeg-0.8.5

Dans le répertoire lib du plugin : $AUDELA/gui/audace/plugin/tool/av4l/lib
Taper les commandes suivantes :
make ffmpeg-config
make ffmpeg-clean
make ffmpeg
make ffmpeg-links
make

make install

=== ANCIEN

Dans $AUDELA/gui/audace/plugin/tool/acqvideolinux :

ln -s pkgIndex.tcl.nonactif pkgIndex.tcl

===

Lancer AudeLA avec $AUDELA/bin/audela.sh

=== ANCIEN

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

