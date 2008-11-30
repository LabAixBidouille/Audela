#!/bin/sh
#
# make_packages.sh [debian/ubuntu/mandriva]
#
#     Ce script permet de generer une archive deb et rpm a partir d'un repertoire de dev.
#
# Version initiale : Denis Marchais
# Version actuelle : Benjamin Mauclaire
#


#--- Variables de focntionnement :
depends_debian="tk8.4, libstdc++6, libgsl0, gnuplot-x11, gzip, libusb-0.1-4, tclxml, tcllib, tclvfs, libtk-img, blt"
# depends_debian="libc6, libgcc1, libgsl0, libstdc++6, libusb-0.1-4, tcl8.4, tk8.4, tclthread, libx11-6, libxau6, gnuplot-x11, gzip, tclxml, tcllib, tclvfs, libtk-img, blt"
depends_ubuntu="tk8.4, libstdc++6, libgsl0ldbl, gnuplot-x11, gzip, libusb-0.1-4, tclxml, tcllib, tclvfs, libtk-img, blt"
# depends_ubuntu="libc6, libgcc1, libgsl0ldbl, libstdc++6, libusb-0.1-4, tcl8.4, tk8.4, gnuplot-x11, gzip, tclxml, tcllib, tclvfs, libtk-img, blt"
depends_mandriva="libtk8.4, gsl, libstdc++6, gnuplot, gzip, libusb, tcl-tcllib, blt"
# depends_mandriva="glibc, libgcc1, libgphoto, gsl, libstdc++6, libusb, libtcl8.4, libtk8.4, gnuplot, gzip, tcl-tcllib, blt"
# unfound : gnuplot-x11 tclxml tclvfs, libtk-img


#--- Choix de la distro et parametrage en consequence :
if test "$1" = "debian"
then
    echo "La distribution est une Debian."
    depends="$depends_debian"
    ladistro="$1"
elif test "$1" = "ubuntu"
then
    echo "La distribution est une *Ubuntu."
    depends="$depends_ubuntu"
    ladistro="$1"
elif test "$1" = "mandriva"
then
    echo "La distribution est une Mandriva."
    depends="$depends_mandriva"
    ladistro="$1"
elif "$1" = "-h"
then
    echo "make_packages.sh [debian/ubuntu/mandriva]"
    exit 0
elif test $# = 0
then
    #-- Detection automatique de la distro de la plateforme de travail :
    distro1=`cat /etc/issue`
    distro=`expr "$distro1" : '\(.*\)'`

    if test "`expr "$distro" : '.*\(Debian\).*'`" = "Debian"
    then
        echo "La distribution est une Debian."
        depends="$depends_debian"
        ladistro="debian"
    elif test "`expr "$distro" : '.*\(buntu\).*'`" = "buntu"
    then
        echo "La distribution est une *Ubuntu."
        depends="$depends_ubuntu"
        ladistro="ubuntu"
    else
        echo "La distribution est inconnue."
        depends="$depends_mandriva"
        ladistro="mandriva"
    fi
else
    echo "make_packages.sh [debian/ubuntu/mandriva]"
    exit 0
fi


#--- Construit ne numero de version :
#DAILY=20080509
#DAILY=`date +"%Y%m%d"`
noteversion=`grep "audela(version)" ../../bin/version.tcl | tr -d '"'`
laversion=`expr "$noteversion" : '.*\s\([0-9]*\.[0-9]*\.[0-9]*\).*'`
info_audela=`ls -gG ../../bin/audela`
ladate=`expr "$info_audela" : '.*\([0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]\).*'`
DAILY=$laversion.`echo $ladate | tr -d '-'`
echo "Creation des paquets AudeLA version $DAILY :"


BUILD_DIR=audela-$DAILY
INST_DIR=/usr/lib/audela-$DAILY
DIRECTORY=$BUILD_DIR$INST_DIR

#--- Menage :
sudo rm -rf audela-*
#rm -f $BUILD_DIR.deb
rm -rf rpm

#--- Creation des fichiers necessaire a l'empaquetage :
echo "Creation des fichiers necessaire a l'empaquetage..."

if test -e ../../bin/libtcl8.4.so
then
    nom_paquet="audela-thread"
    lesuffixe="thread"
    # liens="#
# Libs .so.0 necessaires pour BLT :
#ln -s $INST_DIR/bin/libtcl8.4.so $INST_DIR/bin/libtcl8.4.so.0
#ln -s $INST_DIR/bin/libtk8.4.so $INST_DIR/bin/libtk8.4.so.0
#"
    liens="#"
else
    nom_paquet="audela-mono"
    lesuffixe="mono"
    liens="#
# Compense un probleme dans l'edition de lien d'Audela : il faut a Audela les lib.so (lien realise par le paquet de tk-dev) au lieu de .so.0 (pour BLT et dispo ds paquet binaire) Mais c'est MAL de faire ainsi !
if test -e /usr/lib/libtcl8.4.so || test -h /usr/lib/libtcl8.4.so ; then echo "" ; elif test -e /usr/lib/libtcl8.4.so.0 ; then ln -s /usr/lib/libtcl8.4.so.0 /usr/lib/libtcl8.4.so ; fi
if test -e /usr/lib/libtk8.4.so || test -h /usr/lib/libtk8.4.so ; then echo "" ; elif test -e /usr/lib/libtk8.4.so.0 ; then ln -s /usr/lib/libtk8.4.so.0 /usr/lib/libtk8.4.so ; fi
"
fi

mkdir -p $BUILD_DIR/DEBIAN
echo "Package: $nom_paquet
Version: $DAILY
Section: science 
Priority: optional
Architecture: i386
Essential: no
Depends: $depends
Installed-Size: 57521
Maintainer: Benjamin MAUCLAIRE <bmauclaire@gmail.com>
Provides: audela
Description: Logiciel libre multiplateforme (Win32, Linux, Mac), permettant les acquisitions CCD, le pilotage de telescopes, le traitement et l'exploitation des images. Automatisation possible grace aux scripts TCL. Il se couple avec Cartes du Ciel pour le pointage. Homepage : http://www.audela.org.
" > $BUILD_DIR/DEBIAN/control

# AudeLA is a TCL extension aimed at providing amateur astronomers with image processing, telescope controling, ccd camera driving, and various astronomical algorithms.


echo "#!/bin/sh
set -e
# Cree un lien symbolique pour la derniere version d'Audela instalee :
if test -h /usr/bin/audela ; then rm -f /usr/bin/audela ; fi
ln -s $INST_DIR/bin/audela.sh /usr/bin/audela
$liens
# Automatically added by dh_installmenu
if [ "$1" = "configure" ] && [ -x "`which update-menus 2>/dev/null`" ]; then
        update-menus
fi
# End automatically added section
" > $BUILD_DIR/DEBIAN/postinst
chmod 555 $BUILD_DIR/DEBIAN/postinst

echo "#!/bin/sh
set -e
rm -f /usr/bin/audela
if test -h $INST_DIR/bin/libtcl8.4.so.0 ; then rm -rf $INST_DIR ; fi
# Automatically added by dh_installmenu
if [ -x "`which update-menus 2>/dev/null`" ]; then update-menus ; fi
# End automatically added section
" > $BUILD_DIR/DEBIAN/postrm
chmod 555 $BUILD_DIR/DEBIAN/postrm


#--- Creation de l'arborescence, copie des repertoires entiers :
echo "Creation de l'arborescence, copie des repertoires entiers..."
mkdir -p $DIRECTORY
cp -r ../../bin $DIRECTORY
cp -r ../../lib $DIRECTORY
cp -r ../../gui $DIRECTORY
cp -r ../../images $DIRECTORY

#--- Petit menage :
cp ../COPYING $DIRECTORY
cp ../../readme.txt $DIRECTORY
rm -f $DIRECTORY/bin/version.tcl.in
find $DIRECTORY | grep CVS | xargs rm -rf
rm -f $DIRECTORY/bin/Makefile
chmod a-x $DIRECTORY/bin/*.so*
cp $DIRECTORY/readme.txt $DIRECTORY/bin/audela.txt
#rm -f $DIRECTORY/bin/audace.txt
#if test -e $DIRECTORY/bin/libtk8.4.so ; then rm -f $DIRECTORY/bin/libtk8.4.so ; fi


#--- Gestion de libthread :
dirlocal=`pwd`
cd $DIRECTORY/lib/thread2.6
if [ "$ladistro" = "debian" ] || [ "$ladistro" = "ubuntu" ]
then
    ln -s libthread2.6.5.1.so_debian libthread2.6.5.1.so
elif test "$ladistro" = "mandriva"
then
    ln -s Thread2.6.5.1.so_mandriva libthread2.6.5.1.so
fi
cd $dirlocal


#--- Creation du fichier de demarrage d'Audela :
echo "#!/bin/sh
export LD_LIBRARY_PATH=$INST_DIR/bin:\$LD_LIBRARY_PATH
cd $INST_DIR/bin
./audela \$*
" > $DIRECTORY/bin/audela.sh
chmod +x $DIRECTORY/bin/audela.sh
sudo chown -R root.root $DIRECTORY/*
#sudo chmod a+w $DIRECTORY/bin/audace.txt


#--- Creation du fichier d'entree pour la presence d'Audela dans le menu du gestionnaire de fenetres :
mkdir -p $BUILD_DIR/usr/share/applications/
echo "[Desktop Entry]
Name=AudeLA
Comment=Astronomy image processing, telescope controling, and ccd camera driving software
Comment[fr]=Logiciel de traitement d'image astronomique, de contôle de télescopes et de pilotage de caméra ccd
Exec=audela
Icon=audela.xpm
Terminal=false
Type=Application
Categories=Astronomy;Science;Education;
" > $BUILD_DIR/usr/share/applications/audela.desktop
chmod a+r $BUILD_DIR/usr/share/applications/audela.desktop
sudo chown -R root.root $BUILD_DIR/usr/share/*

mkdir $BUILD_DIR/usr/share/menu
echo "?package(audela):needs="X11" section="Apps/Science" \
  section="Apps/Science" \
  title="AudeLA" \
  longtitle="AudeLA: astronomy software" \
  hints="AudeLA: astronomy software" \
  command="/usr/bin/audela" \
  icon="/usr/share/pixmaps/audela.xpm"
" > $BUILD_DIR/usr/share/menu/audela

mkdir $BUILD_DIR/usr/share/pixmaps
cp audela.xpm $BUILD_DIR/usr/share/pixmaps/


#--- Creation du paquet :
echo "Creation du paquet Debian..."
sudo dpkg -b $BUILD_DIR $BUILD_DIR-$lesuffixe.deb
luser=`whoami`
sudo chown $luser.$luser *.deb
echo "Paquet DEB cree."


#--- Creation du rpm :
if test "$ladistro" = "mandriva"
then
    echo "Creation du paquet RPM..."
    mkdir rpm
    cd rpm
    sudo alien -v --to-rpm --scripts ../$BUILD_DIR-$lesuffixe.deb
    sudo chown $luser.$luser *.rpm
    mv *.rpm ..
    cd ..
    rm -rf rpm *.deb
    echo "Paquet RPM cree."
fi

#rm -rf $BUILD_DIR

#--- Fin du script :


