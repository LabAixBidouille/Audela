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
depends_debian="libc6, libgcc1, libgphoto2-2, libgsl0, libstdc++6, libusb-0.1-4, tcl8.4, tk8.4, tclthread, libx11-6, libxau6, gnuplot-x11, gzip, tclxml, tcllib, tclvfs, libtk-img, blt"
depends_ubuntu="libc6, libgcc1, libgphoto2-2, libgsl0ldbl, libstdc++6, libusb-0.1-4, tcl8.4, tk8.4, gnuplot-x11, gzip, tclxml, tcllib, tclvfs, libtk-img, blt"
depends_mandriva="libc6, libgcc1, libgphoto2-2, libgsl0ldbl, libstdc++6, libusb-0.1-4, tcl8.4, tk8.4, gnuplot-x11, gzip, tclxml, tcllib, tclvfs, libtk-img, blt"


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

if test -e ../../bin/libtcl8.4.so*
then
    nom_paquet="audela-thread"
    lesuffixe="thread"
else
    nom_paquet="audela-mono"
    lesuffixe="mono"
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

echo "#!/bin/sh
set -e
ln -s $INST_DIR/bin/audela.sh /usr/bin/audela
# Compense un probleme dans l'edition de lien d'Audela : il lui faut lib...so au lieu de .so.0. Mais c'est mal de faire ainsi !
if test -e /usr/lib/libtcl8.4.so ; then echo "" ; else ln -s /usr/lib/libtcl8.4.so.0 /usr/lib/libtcl8.4.so ; fi
if test -e /usr/lib/libtcl8.4.so ; then echo "" ; else ln -s /usr/lib/libtk8.4.so.0 /usr/lib/libtk8.4.so ; fi
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



#--- Creation du fichier de demarrage d'Audela :
echo "#!/bin/sh
export LD_LIBRARY_PATH=$INST_DIR/bin:\$LD_LIBRARY_PATH
cd $INST_DIR/bin
./audela \$*
" > $DIRECTORY/bin/audela.sh
chmod +x $DIRECTORY/bin/audela.sh
sudo chown -R root.root $DIRECTORY/*
#sudo chmod a+w $DIRECTORY/bin/audace.txt


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
    rm -rf rpm
    echo "Paquet RPM cree."
fi


#--- Fin du script :


