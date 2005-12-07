AudeLA-1.3.0 (20050714)


1. Introduction
---------------

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
--------------------

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
- Kitty K2,
- WebCam,
- AudiNet (Audine pilotee par une interface Ethernet : PicoWeb),
- EthernAude (interface Ethernet pour cameras CCD),
- TH7852A,
- QuickAudine,
- Finger Lakes Instruments,
- AndorTech,
- SRC1300XTC.

AudeLA est capable de piloter les montures suivantes :
- LX200,
- Ouranos (codeurs absolus),
- AudeCom (ex-carte Kauffmann),
- LXnet (LX200 pilote par une interface Ethernet : PicoWeb),
- Temma (monture Takahashi avec module Temma),
- MCMT,
- N'importe quel telescope repondant au protocole LX200.

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
-----------------------------------------------------

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
----------

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
----------------------------

5.1 Windows

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

Pour compiler sous Windows :
1/ Effectuez les operations
suivantes dans une console "Invite de commande",

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
    lancer make.bat puis uinstall.bat

2/ Ouvrir avec Visual C++ le fichier src/audela.dsw : Allez
dans le menu Build, puis Batch Build ; Selectionnez les differentes
cibles que vous voulez compiler, et effectuez la compilation. A noter
que libtt peut conduire a un crash du compilateur en mode Release, alors
compilez cette librairie en mode Debug.

5.2 Linux

-> Pour linux, il vous faut telecharger et extraire les sources de audela.
	$ wget http://software.audela.free.fr/13/audela-1.3.0-src.tar.gz
	$ tar -xf audela-1.3.0-src.tar.gz

-> Configurez le paquetage AudeLA :
	$ cd audela-1.3.0/src
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
	
5.3 MAC OS-X

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
----------

Les auteurs initiaux de AudeLA sont :
 - Alain KLOTZ <alain.klotz@free.fr> et
 - Denis MARCHAIS <denis.marchais@free.fr>.

Par la suite, ils ont ete rejoints par :
 - Robert DELMAS <delmas.robert@wanadoo.fr>,
 - Christian JASINSKI <christian@jasinski.name>,
 - Michel PUJOL <michel-pujol@wanadoo.fr>.

Ils forment "The AudeLA Core Team" (TACT), nom employe pour le copyright dans 
les sources.

Un bon nombre de personnes a contribue a AudeLA ou Aud'ACE. Citons dans le
desordre :
 - Jacques MICHELET <jacques.michelet@laposte.net> : libjm et outils GPS,
   King, scripts de photometrie (calaphot) et de tri par fwhm (tri_fwhm).
 - Francois COCHARD : Outils Acquisition et Pretraitement.
 - Olivier THIZY : Script de photometrie (calaphot).
 - Raymond ZACHANTKE : Outil APN, telescope AvrCom, codeurs Ouranos.
 - Philippe KAUFFMANN : Carte AudeCom.
 - Guillaume SPITZER : libgs pour l'interfacage avec "Guide".
 - Benoit MAUGIS : libbm, traitement de series d'images, gestion d'images
   FITS polychromes (poly), traitement d'images stellaires, utilisation
   conjointe d'AudeLA et d'Iris, outils Visionneuse et Acquisition fenetree.
 - Michel MEUNIER <michel.meunier10@tiscali.fr> est l'auteur du driver 
   Ethernaude et du driver MCMT.
 - Sylvain GIRARD <sly.girarg@wanadoo.fr> est l'auteur du driver libk2 de la
   camera Kitty2.
 - Jim CADIEN : support pour la camera Cookbook.
 - Pierre THIERRY : Imagerie couleur et obturateur "thierry".
 - Patrick CHEVALLEY : Driver WebCam longue pose.
 - Arkadius KALICKI : Driver WebCam.
 - Benjamin MAUCLAIRE : Filtres des traitements d'images.
 - Darth VADOR <vador@darkstar.com> : Inspiration permanente.
 - Xavier REY-ROBERT : Utilitaire scriptis pour executer des scripts de
   commande Iris.
 - Vincent COTREZ : Script de detection (detection).
 - Harald RISCHBIETER : Traitement d'images matriciel.
 - Christian JASINSKI, Dez FUTAK, Dan HOLLER : Traduction anglaise.
 - Fausto MANENTI : Traduction italienne.
 - Rafael GONZALEZ FUENTETAJA, Cristobal GARCIA : Traduction espagnole.
 - Philippe KAUFFMANN, Joerg HOEBELMANN : Traduction allemande.
 - Knud STRANDBAEK : Traduction danoise.

Que ceux qui ont ete oublies nous excusent, et se manifestent aupres des auteurs
pour rectifier l'injustice qu'ils subissent.


7. Sources
----------

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
- libaudela : 
- libcam : Contient tous les drivers de camera.
- libgsltcl : Interface TCL <-> GSL.
- libgzip : Module de compression.
- libmc : Librairie de mecanique celeste.
- librgb : Permet d'utiliser des images en couleur.
- libsext : Interface vers sextractor.
- libtel : Contient tous les drivers de montures de telescope.
- libtt : Librairie de traitement d'images.


8. Librairies additionnelles
--------------------------------
TCL/TK:
 - BLT : Trace des courbes sous TK (histogramme, plotxy).
 - BWidget : Definition de nouveaux widgets TK.
 - dde : Protocole Dynamic Data Exchange pour Windows (Carte du Ciel V2.xx).
 - DialogWin : tk_messageBox evolue.
 - HelpViewer : Affichage d'une aide.
 - Img : Librairie de chargement de formats d'images standards (jpg, bmp, etc.).
 - Reg : Fonctions d'acces a la base de registres Windows.
 - SuperGrid : Positionne automatiquement les widgets dans une grille.
 - TableList : Affichage d'une liste avec parametrage des colonnes (outil Visionneuse bis).
 - Tcllib : Outils divers (ftp, http, irc, ntp, etc.).
 - TCom : Protocole Microsoft COM (pour interfaces ASCOM).
 - TkHtml : Widget permettant d'afficher une page HTML.
 - TkImgVideo : Widget d'affichage des videos webcam.
 - TMCI : Gestion du format video avi.
 - TclSoap-1.6.7 : extension SOAP pour skybot/virtual observatory. http://tclsoap.sourceforge.net
 - TclDOM-2.6 : extension DOM pour skybot/virtual observatory. http://tclxml.sourceforge.net
 - TclXML-2.6 : extension XML pour skybot/virtual observatory. http://tclxml.sourceforge.net
 

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

Copyright (C)1999-2005, The AudeLA Core Team.

