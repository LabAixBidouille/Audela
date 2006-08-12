AudeLA-1.4.0-BETA1 (20060804)


1. Introduction
===============

AudeLA est un logiciel de pilotage d'instruments astronomiques amateurs, et
de traitement d'images. Sa particularite est de proposer une modularite unique
dans son domaine grace a un puissant langage de script. C'est le fruit du 
travail d'astronomes amateurs, realise pendant leur temps libre, dans le but 
d'ameliorer leurs conditions d'observations. Leur souhait est de partager cet
outil avec d'autres personnes, autant astronomes amateurs, qu'informaticiens 
amateurs, afin de le faire progresser : N'hesitez pas a nous contacter si vous
souhaitez apporter votre contribution.

Ce logiciel est libre, reportez vous au paragraphe 4 pour plus de details.


2. Materiel supporte
====================

AudeLA est capable de piloter les cameras CCD suivantes :
- Audine (Kaf series 400, 401, 401E, 1600, 1602, 1602E et 3200E),
- Hi-SIS 11,
- Hi-SIS 22 (12 et 14 bits),
- Hi-SIS 23,
- Hi-SIS 24,
- Hi-SIS 33,
- Hi-SIS 36,
- Hi-SIS 39,
- Hi-SIS 43,
- Hi-SIS 44,
- Hi-SIS 48,
- SBIG (tous les modeles),
- CB245,
- MX516,
- MX916,
- HX516,
- Kitty 237,
- Kitty 255,
- Kitty 2,
- WebCam,
- TH7852A,
- SCR1300XTC,
- APN (Appareil Photo Numérique),
- AndorTech,
- Finger Lakes Instruments.

AudeLA est capable de piloter les montures suivantes :
- LX200,
- Ouranos (codeurs absolus),
- AudeCom (ex-carte Kauffmann),
- Temma (monture Takahashi avec module Temma),
- ASCOM,
- N'importe quel telescope repondant au protocole LX200.

AudeLA est capable de piloter les interfaces de communication suivantes :
- AudiNet (interface Ethernet pour cameras Audine et telescopes LX200 : PicoWeb),
- EthernAude (interface Ethernet pour cameras CCD),
- Manuel,
- GPhoto2,
- Port parallele,
- PhotoPC
- QuickAudine (interface USB pour cameras Audine),
- QuickRemote (interface USB pour APN, WebCam longue pose, raquette de telescope,
  mise au point, etc.),
- Port serie.

AudeLA est capable de piloter les equipements suivants :
- La roue a filtres developpee dans le cadre de l'association Aude.

Bien entendu les auteurs ne disposent pas de tout ce materiel cite. Ils les ont 
integres en fonction des moyens et des connaissances disponibles, n'etant pas a 
l'abris de quelques specificites de ce materiel se traduisant soit par un 
dysfonctionnement, soit par une baisse de performance, soit par une absence de 
fonctionnalite.

AudeLA fonctionne avec :
Ordinateur PC,
Pentium 75 minimum
16 Mo Ram
Windows 95, 98, ME, NT, 2000, XP,
Linux.

* Particularite windows :
La plupart des cameras supportees exigent l'utilisation du port parallele.
L'utilisation du port parallele ne cause pas de difficulte sous Win95, 98, ME
ou Linux (root). En revanche, pour utiliser le port parallele sous winNT, XP,
2000, l'utilitaire "allowio" s'installe automatiquement au premier demarrage
pour donner acces aux ports. Si une version anterieure d'allowio est detectee
il sera propose de la desinstaller et de la remplacer par la version fournie
avec AudeLA. 

* Particularite linux :
AudeLA n'utilise pas de kernel driver pour communiquer avec les cameras, mais 
utilise les acces directs au port parallele. Il faut donc avoir les droits de
superviseur pour pouvoir realiser des acquisitions.


3. Quelle est la difference entre AudeLA et Aud'ACE ?
=====================================================

"AudeLA" est une executable qui ne fait que charger un ensemble de librairies
(traitement d'images, mecanique celeste, acquisition, pilotage, autres), et 
demarre ensuite un interpreteur TCL/TK. Ces librairies ont ete ecrites soit 
par les auteurs, soit par des contributeurs, et reposent egalement sur des 
librairies externes (TCL, FITSIO, GZIP, JPEG, et certains drivers de cameras). 

Par la suite on entend par "modules propres a AudeLA" ceux qui ont reellement
ete ecrits par les auteurs ou contributeurs directs. Cela correspond aux
repertoires audela, libak, libaudela, libcam, libgsl, libgzip, libjm, libmc, 
librgb, libsext, libtel, libtt.

"Aud'ACE" est une interface graphique qui exploite les possibilites de 
"AudeLA". "Aud'ACE" a ete ecrit en TCL/TK par les auteurs, et utilise bon
nombre de librairies externes (affichage, widgets, formats d'image, etc).


4. License
==========

Les modules propres a AudeLA et Aud'ACE sont distribues sous la license 
GPL (GNU Public Licence). En quelques mots, cela veut dire que c'est un
logiciel libre : Vous etes libres de le copier, le distribuer, et le 
modifier. La GPL impose que si vous distribuez ce programme, alors vous
devez donner les meme droits au recipiendaire que ceux que vous avez recus.
En particulier vous devez rendre les sources accessibles, y-compris les
modifications que vous auriez eventuellement pu apporter au programme.

La license GPL est faite pour developper le logiciel libre. Elle impose donc 
que si vous ecrivez un logiciel utilisant tout ou partie de "AudeLA", alors 
celui-ci devra etre GPL, a l'image de "Aud'ACE".

Ce programme ne comporte aucune garantie de fonctionnement (on essaye
quand meme de faire quelque chose qui marche :-)), et est livré "en l'état".
En particulier, les auteurs ne s'engagent en aucune maniere a devoir 
corriger des bugs, s'il y en avait ; Et ils ne peuvent en aucun cas etre 
tenus responsables d'une quelconque degradation du fait d'un evenement
ayant une relation avec AudeLA. Le disclaimer suivant resume la situation :

<<<
   This program is free software ; You can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation ; Either version 2 of the License, or (at
   your option) any later version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY ; Without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.
>>>

Consultez le site http://www.gnu.org pour plus de renseignements sur le
monde des logiciels libres.

AudeLA et Aud'ACE utilisent des librairies externes. Ces modules ont ete
ecrits par des gens que nous ne connaissons meme pas (mais que nous remercions
au passage), et sont distribuees avec des licenses diverses. Qu'il soit bien 
clair que nous n'appliquons pas la license GPL a ces modules. 

Nous avons autant que possible respecte la volonte des auteurs, lorsque 
celle-ci est stipulee, concernant la redistribution de leur travail. Nous
vous invitons a naviguer dans l'arborescence de AudeLA afin de consulter les
differents fichiers de license. Pour information, seuls les sources de
gzip ont legerement ete modifies afin de pouvoir generer une librairie partagee.

Enfin, certaines librairies sont distribuees sans license, voire meme sans
code source. Nous les redistribuons avec l'intention de rendre service a 
l'utilisateur, et avec l'espoir de ne pas aller a l'encontre de la volonte 
de leurs auteurs. Si tel etait le cas, qu'ils veuillent bien nous contacter.

Si les ayatollah du logiciel libre le veulent, ils peuvent supprimer ces fichiers 
apres leur installation afin de ne pas teinter leur machine.


5. Installation et demarrage
============================

5.1 Windows
-----------

Vous aurez probablement telecharge un executable d'installation.

Dans ce cas, executez-le. A l'issue de l'installation, il y aura un menu AudeLA
dans votre "Menu Demarrer", et aussi une icone sur votre bureau. C'est ce qui vous
permet de lancer AudeLA.

Note aux utilisateurs de cameras SBIG :
* Win 95/98 : Copiez le fichier bin\SBIGUDRV.VXD dans le sous-repertoire system
  du repertoire d'installation de Windows (c:\windows\system en general).
* Win NT/2000 : Copiez les fichiers bin\sbig*.sys dans le sous-repertoire
  c:\WINNT\system32\drivers. Puis executer le logiciel SBIGDriverChecker.exe
  disponible sur le site www.sbig.com.
* Win XP : Copiez les fichiers bin\sbig*.sys dans le sous-repertoire
  c:\WINDOWS\system32\drivers. Puis executer le logiciel SBIGDriverChecker.exe
  disponible sur le site www.sbig.com. 

5.1.1 Compilation des modules externes pour Windows
---------------------------------------------------

Effectuez les operations suivantes dans une console "Invite de commande",

  - Repertoire src\external\andor,
    lancer make.bat puis install.bat

  - Repertoire src\external\cfitsio,
    lancer vars.bat (regler les chemins si besoin), make.bat puis install.bat

  - Ouvrir et compiler avec visual c++, en mode release :
       src\external\fli\libfli\lib\windows\libfli.dsw
    Repertoire src\external\fli, lancer install.bat.

  - Repertoire src\external\gsl,
    lancer make.bat puis install.bat

  - Repertoire src\external\jpeg6b,
    lancer vars.bat (regler les chemins si besoin), make.bat puis install.bat

  - Repertoire src\external\libdcjpeg
    ouvrir visual c++  vc60\libdcjpeg.dsw et compiler en mode Release

  - Repertoire src\external\libdcraw
    ouvrir visual c++  vc60\libdcraw.dsw et compiler en mode Release

  - Repertoire src\external\libftd2xx
    lancer make.bat puis install.bat

  - Repertoire src\external\libgphoto2
    lancer make.bat puis install.bat

  - Repertoire src\external\libusb
    lancer make.bat puis install.bat
    telecharger libusb-win32-filter-bin-0.1.10.1.exe depuis le site web de sourceforge
    puis lancer libusb-win32-filter-bin-0.1.10.1.exe

  - Repertoire src\external\porttalk,
    lancer make.bat puis install.bat

  - Repertoire src\external\sbig,
    lancer make.bat puis install.bat

  - Ouvrir et compiler avec visual c++, en mode release :
       src\external\sextractor\sextractor\vc60\sextractor.dsw
          (sex.exe est mis directement dans audela/bin)

  - Repertoire src\external\tcl,
    lancer make.bat puis install.bat

  - Repertoire src\external\utils,
    lancer make.bat puis install.bat

5.1.2 Compilation de AudeLA pour Windows
----------------------------------------

Ouvrir avec Visual C++ le fichier src/audela.dsw : Allez
dans le menu Build, puis Batch Build ; Selectionnez les differentes
cibles que vous voulez compiler, et effectuez la compilation.

5.1.3 Installation des drivers optionels
----------------------------------------

5.1.3.1 Installation ftd2xx 
---------------------------

   Ce driver est nécessaire seulement pour les liaisons avec quickremote

   télécharger D10620.zip  pour quickremote
   URL:   http://www.ftdichip.com/Drivers/FT232-FT245/D2XX/Win/D10620.zip
   ou URL:   http://www.ftdichip.com/Drivers/D2XX/Win2000/D30104.zip
   dezipper le fichier dans un repertoire temporaire 
   brancher un quickremote, lorsque Windows demande où est le repertoire du driver, 
   pointer le repertoire temporaire où vient d'etre dézippe le fichier .
 
   Remarque : 
   Les drivers pour les autres version d'OS sont aussi sur le site http://www.ftdichip.com.

5.1.3.2 Arreter le service ftdi_sio 
-----------------------------------

  Cette action est nécessaire seulement pour les liaisons avec quickremote.
   
  arreter les services hotplug qui surveillent le branchement des equipements 
  qui ont le même identifiant USB que quickremote comme par exemple : ftdi_sio
  Pour cela, lister les services ftdi avec la commande lsmod.
  Si un  service existe, il l'arreter avec la commande rmmod.   

  Exemple : 
   $ su root
   # lsmod |grep ftdi_sio
   ftdi_sio               31940  0
   usbserial              26920  1 ftdi_sio
   usbcore               106008  5 ftdi_sio,usbserial,ehci-hcd,uhci-hcd
   # rmmod ftdi_sio
   # lsmod |grep ftdi_sio
   #

   Remarque : le service est relance automatiquement chaque fois que quickremote est 
   rebranche. Je n'ai pas trouve la commande qui desactive definitivement le hotplug pour 
   cet equipement.
   Pour relancer le service hotplug manuellement, taper la commande "modprobe ftdi_sio" 
   sous root.

5.1.3.3 Installation libusb-win32 
---------------------------------

   Ce driver est nécessaire seulement pour la liaison de la camera DSC (appareil
   photo numerique) avec libgphoto2.
   
   télécharger libusb-win32-filter-bin-0.1.10.1.exe disponible sur site
   http://libusb-win32.sourceforge.net , 
   puis installer libusb-win32 en executant ce fichier.

5.2 Linux
---------

5.2.1 Compilation et installation de AudeLA
------------------------------------------

-> Pour linux, il vous faut telecharger et extraire les sources de audela.
	$ wget http://software.audela.free.fr/13/audela-1.4.0-beta1-src.tar.gz
	$ tar -xf audela-1.4.0-beta1-src.tar.gz

-> Configurez le paquetage AudeLA :
	$ cd audela-1.4.0-beta1/src
	$ ./configure

	configure peut prendre les options suivantes :
	--with-tcl={path_to_tclConfig.sh}
	--with-tk={path_to_tkConfig.sh}
		Par defaut, configure va chercher les fichiers de configuration TCL/TK
		dans des emplacements standard. Sur certaines distributions, ces packages
		sont installes dans d'autres repertoires. Les deux fichiers tclConfig.sh
		et tkConfig.sh sont generes lors de la compilation de TCL/TK et permettent
		de retrouver ensuite les differentes options de compilation necessaires a
		AudeLA. Les deux options servent a indiquer les repertoires ou trouver
		chacun de ces deux fichiers. 
		Utilisez la commande find / | grep "tclConfig" pour localiser les fichiers.
	--with-gsl-prefix={path}
		La librairie GSL est recherchee a partir des emplacements standard.
		Cette option permet de preciser le prefix d'installation de GSL le cas
		echeant. Cette librairie n'est pas necessaire : Si elle est absente, 
		quelques modules de AudeLA ne seront volontairement pas compiles.
		Cette option est equivalente a faire pointer la variable d'environnement
		GSL-CONFIG vers l'executable gsl-config.

	Par exemple, pour la Debian 3.0, il faut avoir installer les paquets de developpement
	(tcl-dev, tk-dev, gsl-dev), et utiliser :
	./configure --with-tcl=/usr/lib/tcl8.4/ --with-tk=/usr/lib/tk8.4/ --with-gsl-prefix=/usr

-> Compiler d'abord les modules externes :
	$ make external

-> Compiler ensuite les contributions :
	$ make contrib

-> Compilez enfin audela :
	$ make

Les binaires sont dans le repertoire bin.

Vous pouvez tout compiler d'un coup :
	$ make all

	Mais commencez par le faire pas a pas pour identifier la cause eventuelle
	d'un dysfonctionnement.

	A l'execution, il peut y avoir des problemes avec des librairies telles que BLT,
	Img, ou encore TkHtml. Dans ce cas, supprimez leur repertoire de audela/lib, et
	installez-les sur votre machine (paquet .deb, .rpm, ou from source), et ajoutez
	les lignes suivantes au debut du fichier audace/audace/aud.tcl :
	lappend auto_path /mon/chemin/vers/ma/lib1
	lappend auto_path /mon/chemin/vers/ma/lib2
	etc.

	!! Attention !! Sous certaines plateformes il y a un echec de compilation pour
	la librairie FLI, et libfli. Cela est lie a l'USB, et n'a pas ete encore elucide.
	Vous pouvez neanmoins supprimer ces modules dans le fichier Makefile.defs pour 
	reprendre le cours normal de la compilation.

5.2.2 Installation des drivers optionels
----------------------------------------

5.2.2.1 Installation ftd2xx
---------------------------

   Ce driver est nécessaire seulement pour les liaisons avec quickremote

   telecharger la librairie libftd2xx
   http://www.ftdichip.com/Drivers/D2XX/Linux/libftd2xx0.4.8.tar.gz
   Pour installer, suivre les indications du fichier readme.dat .
 
   $ su root
   # cp libftd2xx.so.0.4.8 /usr/local/lib
   # cd /usr/local/lib
   # ln -s libftd2xx.so.0.4.8 libftd2xx.so
   # cd /usr/lib
   # ln -s /usr/local/lib/libftd2xx.so.0.4.8 libftd2xx.so
   
   Add the following line to /etc/fstab:
      none /proc/bus/usb usbdevfs defaults,devmode=0666 0 0
      or
      none /proc/bus/usb usbdevfs defaults,mode=0666 0 0 (use usbfs in 2.6 kernels)

   Unload ftdi_sio and usbserial if it is attached to your device 
   # rmmod ftdi_sio" 
   # rmmod usbserial 

5.2.2.2 Installation libgphoto2 2.1.6
-------------------------------------

   Ce driver est nécessaire seulement pour la camera DSC (appareil photo numérique).
   
   AudeLA founit un patch pour supporter les longues poses supérieures à 30 secondes
   pour les appareils Canon et Nikon.

   Télécharger libgphoto2-2.1.6.tar.gz depuis le site http://www.gphoto.org/ , 
   puis dezipper les modifications libgphoto2-2.1.6-patch-b.tar.gz ,
   puis installer :

   $ tar xzvf libgphoto2-2.1.6.tar.gz 
   $ cd libgphoto2-2.1.6
   $ tar xzvf libgphoto2-2.1.6-patch-b.tar.gz 
   $ ./configure --with-drivers=canon,ptp2 --prefix=/usr 
   $ make
   $ su root
   # make install

   Remarque : 
   il n'est pas necessaire d'installer gtkam ou gphoto2.
   Ne pas confondre gphoto2 avec libgphoto2 !!

5.2.3 Pre-requis
----------------

AudeLA necessite les modules externes suivants pour fonctionner:
 - Tcl 8.4 (avec Debian, paquets tcl84 et tcl84-dev)
 - Tk 8.4 (avec Debian, paquets tk84 et tk84-dev)

Optionnel:
 - gsl (http://www.gnu.org/software/gsl)

Autres:
 - Img 1.3 (http://prdownloads.sourceforge.net/tkimg/tkimg1.3.tar.gz?download)
 - Blt 2.4 (http://prdownloads.sourceforge.net/blt/BLT2.4z.tar.gz?download)

5.3 MAC OS-X
------------

La procedure a suivre est identique a celle de Linux, et a ete testee sur un MacOS
X.3 (Darwin kernel 7.8.0, avec fink). TclTkAquaBi etait installe (voir www.tcl.tk),
et la GSL compilee et installee suivant la procedure standard GNU.

La ligne de commande pour le configure etait pour cette machine:
./configure --with-tcl=/Library/Frameworks/Tcl.framework 
            --with-tk=/Library/Frameworks/Tk.framework
            --with-gsl-prefix=/usr/local

Appliquer les commandes suivantes:
make external
make
# Libtt pose probleme : la commande de compilation doit se faire a la main dans
# le repertoire macos:
cd audela/libtt/macos
make
# A la compilation de libtt il peut y avoir le probleme suivant:
# ld: table of contents for archive: ../../../external/lib/libjpeg.a is out of date; 
# rerun ranlib(1) (can't load from it)
pushd ../../../external/lib ; ranlib libjpeg.a ; popd
make
cd ../../..
make libcam
make libtel
cd ..

# A la fin de la compilation, dans le repertoire bin il faut renommer les fichier 
# libaudela.so et libmc.so en libaudela.dylib et libmc.dylib.
cd bin
mv libaudela.so libaudela.dylib
mv libmc.so libmc.dylib

# Vous pouvez executer audela : 
./audela

Le support pour cette plateforme est tout recent, aussi nous sommes tres interesses
par les retours d'experience sur le sujet MacOS-X...


6. Auteurs
==========

Les auteurs initiaux de AudeLA sont :
 - Alain KLOTZ <alain.klotz@free.fr> et
 - Denis MARCHAIS <denis.marchais@free.fr>.

Par la suite, ils ont ete rejoints par :
 - Robert DELMAS <delmas.robert@wanadoo.fr>,
 - Christian JASINSKI <chris.jasinski@free.fr>,
 - Michel PUJOL <michel-pujol@wanadoo.fr>.

Ils forment "The AudeLA Core Team" (TACT), nom employe pour le copyright dans 
les sources.

Un bon nombre de personnes ont contribue a AudeLA ou Aud'ACE. Citons dans
le desordre :
 - Jacques MICHELET <jacques.michelet@laposte.net> : Librairie libjm et
   outils GPS et King, scripts de photometrie (calaphot) et de tri par
   fwhm (tri_fwhm).
 - Francois COCHARD <francois.cochard@wanadoo.fr> : Outils Acquisition et
   Pretraitement.
 - Olivier THIZY <thizy@free.fr> : Script de photometrie (calaphot).
 - Raymond ZACHANTKE <zachantk@club-internet.fr> : Outil APN et monture
   Ouranos.
 - Philippe KAUFFMANN <philippe.kauffmann@free.fr> : Monture AudeCom.
 - Guillaume SPITZER <gspitzer@free.fr> : Librairie libgs pour
   l'interfacage avec "Guide".
 - Benoit MAUGIS <benoit.maugis@laposte.net> : Librairie libbm, traitement
   de series d'images, gestion d'images FITS polychromes (poly), traitement
   d'images stellaires, utilisation conjointe d'AudeLA et d'Iris, outils
   Visionneuse et Acquisition fenetree.
 - Pierre THIERRY : Imagerie couleur et obturateur "thierry".
 - Patrick CHEVALLEY <pchev@gmx.ch> : Driver WebCam longue pose.
 - Arkadius KALICKI : Driver WebCam.
 - Michel MEUNIER <michel.meunier100@wanadoo.fr> : Driver Ethernaude.
 - Vincent COTREZ <vincentcotrez@yahoo.fr> : Script de detection (detection).
 - Benjamin MAUCLAIRE <bmauclaire@underlands.org> : Filtres pour traitements
   d'images et scripts pour la spectroscopie (spcaudace).
 - Harald RISCHBIETER : Traitement d'images matriciel.
 - Xavier REY-ROBERT <xrr@altern.org> : Utilitaire scriptis pour executer
   des scripts de commande Iris.
 - Raoul BEHREND <raoul.behrend@obs.unige.ch> : Utilitaires pour la
   conversion d'images au format FITS.
 - Jerome BERTHIER <berthier@imcce.fr> : Outil pour l'Observatoire Virtuel.
 - Sylvain GIRARD <zesly@wanadoo.fr> : Driver libk2 de la camera Kitty2.
 - Jim CADIEN <jcadien1@gmail.com> : Support pour la camera Cookbook.
 - Darth VADOR <vador@darkstar.com> : Inspiration permanente.
 - Christian JASINSKI, Dez FUTAK, Dan HOLLER : Traduction anglaise.
 - Fausto MANENTI : Traduction italienne.
 - Rafael GONZALEZ FUENTETAJA, Cristobal GARCIA : Traduction espagnole.
 - Philippe KAUFFMANN, Joerg HOEBELMANN : Traduction allemande.
 - Knud STRANDBAEK : Traduction danoise.

Que ceux qui ont ete oublies nous excusent, et se manifestent aupres des auteurs
pour rectifier l'injustice qu'ils subissent.


7. Sources
==========

Voici la liste des sous-repertoires de AudeLA, avec l'explication
de ce que l'on peut y trouver :
- audace : Ensemble des fichiers TCL de l'interface Aud'ACE.
- audela : Sources de l'executable audela.
- bin : Repertoire ou sont stockes tous les binaires apres compilation.
  C'est egalement depuis ce repertoire qu'on execute AudeLA.
- contrib : Modules ecrits specifiquement pour AudeLA, par des personnes
  exterieures a la ACT, et dont la license n'est pas GPL.
- external : Repertoire contenant tous les modules externes utilises
  par AudeLA. Cela facilite l'indentification de ce qui est audela de
  ce qui a ete re-utilise.
- lib : Sous repertoires contenant les modules externes requis par TCL
  pour faire fonctionner Aud'ACE.
- libak : Librairie maintenue par Alain KLOTZ.
- libaudela : Librairie principale d'AudeLA.
- libcam : Contient tous les drivers de camera.
- libgsltcl : Interface TCL <-> GSL.
- libgzip : Module de compression.
- libmc : Librairie de mecanique celeste.
- librgb : Permet d'utiliser des images en couleur.
- libsext : Interface vers sextractor.
- libtel : Contient tous les drivers de montures de telescope.
- libtt : Librairie de traitement d'images.


8. Librairies additionnelles
============================

TCL/TK:
 - BLT : Trace des courbes sous TK (histogramme, plotxy).
 - BWidget : Definition de nouveaux widgets TK.
 - Dde : Protocole Dynamic Data Exchange pour Windows (Carte du Ciel V2.xx).
 - DialogWin : tk_messageBox evolue.
 - Dp : Communication sur protocole IP de bas niveau (TCP, RCP, UDP, SMTP, etc.).
 - HelpViewer : Affichage d'une aide.
 - Img : Librairie de chargement de formats d'images standards (jpg, bmp, etc.).
 - Reg : Fonctions d'acces a la base de registres Windows.
 - SuperGrid : Positionne automatiquement les widgets dans une grille.
 - TableList : Affichage d'une liste avec parametrage des colonnes (outil Visionneuse bis).
 - TclDOM : Extension DOM pour skybot/virtual observatory. http://tclxml.sourceforge.net
 - Tcllib : Outils divers (ftp, http, irc, ntp, etc.).
 - TclSoap : Extension SOAP pour skybot/virtual observatory. http://tclsoap.sourceforge.net
 - TclXML : Extension XML pour skybot/virtual observatory. http://tclxml.sourceforge.net
 - TCom : Protocole Microsoft COM (pour interfaces ASCOM).
 - TkHtml : Widget permettant d'afficher une page HTML.
 - TkImgVideo : Widget d'affichage des videos webcam.
 - TMCI : Gestion du format video avi.


Divers:
 - CFITSIO (2.51).
 - Sextractor.
 - jpeg6b.
 - GZIP.
 - Porttalk.
 - SBIG driver.
 - FLI driver.


Bonne Utilisation !!

Les Auteurs.


AudeLA, page d'accueil : http://audela.ccdaude.com
                    ou : http://software.audela.free.fr/

Copyright (C)1999-2006, The AudeLA Core Team.

