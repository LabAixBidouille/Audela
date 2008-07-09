AudeLA-1.5.0-beta2 (20080709)


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

Pour tout support, veuillez vous inscrire a la mailing list audela-dev:
http://fr.groups.yahoo.com/group/audeladev/


2. Materiel supporte
====================

AudeLA est capable de piloter les cameras CCD suivantes :
- AndorTech,
- APN (Appareil Photo Numerique, CANON et NIKON),
- Audine (Kaf series 400, 401, 401E, 1600, 1602, 1602E et 3200E),
- CB245,
- Cemes,
- Finger Lakes Instruments,
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
- Kitty 2,
- SBIG (tous les modeles),
- SCR1300XTC,
- MX516,
- MX916,
- HX516,
- TH7852A,
- WebCam,
- Nikon CoolPix (port serie) : Uniquement creee par l'outil Acquisition APN CoolPix.

AudeLA est capable de piloter les montures suivantes :
- ASCOM,
- AudeCom (ex-carte Kauffmann),
- Celestron,
- Delta Tau,
- Etel,
- LX200 ou n'importe quelle monture repondant au protocole LX200,
- Ouranos (codeurs absolus),
- Temma (monture Takahashi avec module Temma).

AudeLA est capable de piloter les interfaces de communication suivantes :
- AudiNet (interface Ethernet pour cameras Audine et telescopes LX200 : PicoWeb),
- EthernAude (interface Ethernet pour cameras CCD),
- GPhoto2,
- Manuel,
- Port parallele,
- Port serie,
- QuickAudine (interface USB pour cameras Audine),
- QuickRemote (interface USB pour APN, WebCam longue pose, raquette de telescope,
  mise au point, etc.).

AudeLA est capable de piloter les equipements suivants :
- Focaliseur AudeCom,
- Focaliseur JMI,
- Focaliseur LX200,
- Lhires III,
- Roue a filtres developpee dans le cadre de l'association Aude.

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
quand meme de faire quelque chose qui marche :-)), et est livre "en l'etat".
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

Note aux utilisateurs de cameras SBIG : Installez le driver systeme pour la camera 
avec le logiciel propose par SBIG: "SetupDriverChecker.exe", disponible gratuitement 
a l'adresse suivante: ftp://ftp.sbig.com/pub/SetupDriverChecker.exe

Note aux utilisateurs d'APN (Appareil Photo Numerique) :
   La liaison USB entre AudeLA et les APN requiert libusb-win32 qui est disponible 
   sur le site  http://libusb-win32.sourceforge.net
   Telecharger le fichier libusb-win32-filter-bin-0.1.10.1.exe 
   Puis installer libusb-win32 en executant ce fichier.

Note aux utilisateurs de Quickaudine et de Quickremote : 
   La liaison USB entre AudeLA et Quickaudine ou Quickremote necessite le driver FTDI
   qui est disponible sur le site http://www.ftdichip.com/
   (menu Drivers->D2XX)
   
   Pour Windows XP 64 bits , telecharger le fichier 
        http://www.ftdichip.com/Drivers/CDM/WinXPx64/CDM%202.00.00%20x64.zip
   Pour Windows XP 32 bits , telecharger le fichier 
        http://www.ftdichip.com/Drivers/CDM/Win2000/CDM%202.00.00.zip
   Pour Windows 98 ou Me , telecharger le fichier    
        http://www.ftdichip.com/Drivers/D2XX/Win98/D30104.zip

   Puis dezipper le fichier dans un repertoire temporaire et lancer l'installation 
   en suivant la procedure decrite dans 
   http://www.ftdichip.com/Documents/InstallGuides.htm

5.2 Linux
---------

5.2.1 Prerequis
---------------

AudeLA exploite la philosophie linux, basee sur le partage et la mise en commun
d'elements de base: outre un noyau consistant de fonctions propres, AudeLA utilise
de nombreux autres morceaux de logiciels. Mais pour limiter la taille des sources
a diffuser, les autres modules sont a telecharger et installer suivant les pratiques
de chaque plateforme (paquets Debian, archives RPM, etc).

Les briques suivantes sont requises. Le paquet Debian correspondant est mentionne.
  Tcl (the Tool Command Language) v8.4 - run-time files         (tcl8.4)
  Tk toolkit for Tcl and X11, v8.4 - run-time files             (tk8.4)
  Extended image format support for Tcl/Tk                      (libtk-img)
  GNU Scientific Library (GSL) -- library package               (libgsl0)
  The BLT extension library for Tcl/Tk - run-time package       (blt)
  Userspace USB programming library                             (libusb-0.1-4)

Les outils pour compiler/developper:
  Automatic configure script builder                            (autoconf)
  File comparison utilities                                     (diff)
  The GNU version of the "make" utility                         (make)
  The GNU C compiler                                            (gcc  >4.1)
  The GNU C++ compiler                                          (g++  >4.1)
  GNU Scientific Library (GSL) -- development package           (libgsl0-dev)
  Userspace USB programming library development files           (libusb-dev)
  Linux Kernel Headers for development                          (linux-kernel-headers)
  Apply a diff file to an original                              (patch)
  Tcl (the Tool Command Language) v8.4 - development files      (tcl8.4-dev)
  Tk toolkit for Tcl and X11, v8.4 - development files          (tk8.4-dev)

5.2.2 Lancer AudeLA
-------------------

Aller dans le repertoire bin, et executer ./audela.sh

5.2.3 Utilisation de quickremote ou quickaudine
-----------------------------------------------

Cette action peut etre necessaire seulement pour les liaisons avec 
quickremote et quickaudine.

Il se peut que les services hotplug qui surveillent le branchement des
equipements prenne la main de maniere exclusive sur les peripheriques
a base de FTDI, tels que quickremote et quickaudine.

Pour savoir si tel est le cas, brancher un des deux equipements et lancer
la commande shell lsmod pour lister les drivers utilises par le kernel.
Generalement celui correspondant a l'identifiant USB de quickremote 
s'appelle ftdi_sio.  Si ce service existe, le supprimer.

Pour lister les services, utiliser la commande lsmod.
Pour arreter un service, utiliser la commande rmmod.
  
Attention, ces commandes sont a executer en ayant les privileges root.

Exemple : 
  # su root
  # lsmod |grep ftdi_sio
    ftdi_sio               31940  0
    usbserial              26920  1 ftdi_sio
    usbcore               106008  5 ftdi_sio,usbserial,ehci-hcd,uhci-hcd
  # rmmod ftdi_sio
  # lsmod |grep ftdi_sio
  #

Remarques : 
  - le service est relance automatiquement chaque fois que quickremote est 
    rebranche. Je n'ai pas trouve la commande qui desactive definitivement 
    le hotplug pour cet equipement.
  - Pour relancer le service hotplug manuellement, taper la commande 
    "modprobe ftdi_sio" sous root.

5.3 Organisation des repertoires
--------------------------------
bin : Repertoire ou sont stockes tous les binaires apres compilation.
      C'est egalement depuis ce repertoire qu'on execute AudeLA.
gui : Contient les differentes interfaces graphiques, en particulier
      Aud'ACE dans le repertoire gui/audace.
src : Repertoire des sources.
lib : Contient les librairies TCL additionnelles.


    
    
6. Auteurs
==========

Les auteurs initiaux de AudeLA sont :
 - Alain KLOTZ <alain.klotz@free.fr> et
 - Denis MARCHAIS <denis.marchais@free.fr>.

Par la suite, ils ont ete rejoints par :
 - Robert DELMAS <delmas.robert@wanadoo.fr>,
 - Christian JASINSKI <chris.jasinski@gmail.com>,
 - Michel PUJOL <michel-pujol@wanadoo.fr>.

Ils forment "The AudeLA Core Team" (TACT), nom employe pour le copyright dans 
les sources.


7. Contributions
================

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
 - Jim CADIEN <jcadien1@gmail.com> : Support pour la camera Cookbook et SBIG (linux).
 - Dark VADOR <vador@darkstar.com> : Inspiration permanente.
 - Christian JASINSKI, Dez FUTAK, Dan HOLLER : Traduction anglaise.
 - Fausto MANENTI : Traduction italienne.
 - Rafael GONZALEZ FUENTETAJA, Cristobal GARCIA : Traduction espagnole.
 - Philippe KAUFFMANN, Joerg HOEBELMANN : Traduction allemande.
 - Knud STRANDBAEK : Traduction danoise.

Que ceux qui ont ete oublies nous excusent, et se manifestent aupres des auteurs
pour rectifier l'injustice qu'ils subissent.


8. Librairies et logiciels externes
===================================
 - BLT : Trace des courbes sous TK (histogramme, plotxy).
 - BWidget : Definition de nouveaux widgets TK.
 - Dde : Protocole Dynamic Data Exchange pour Windows (Carte du Ciel V2.xx).
 - DialogWin : tk_messageBox evolue.
 - Dp : Communication sur protocole IP de bas niveau (TCP, RCP, UDP, SMTP, etc.).
 - HelpViewer : Affichage d'une aide.
 - Img : Librairie de chargement de formats d'images standards (jpg, bmp, etc.).
 - Memchan : Librairie pour l'outil "Mise à jour d'AudeLA".
 - Mk4tcl : Librairie pour l'outil "Mise à jour d'AudeLA".
 - Reg : Fonctions d'acces a la base de registres Windows.
 - SuperGrid : Positionne automatiquement les widgets dans une grille.
 - TableList : Affichage d'une liste avec parametrage des colonnes (outil Visionneuse bis).
 - TclDOM : Extension DOM pour skybot/virtual observatory. http://tclxml.sourceforge.net
 - Tcllib : Outils divers (ftp, http, irc, ntp, etc.).
 - TclSoap : Extension SOAP pour skybot/virtual observatory. http://tclsoap.sourceforge.net
 - TclXML : Extension XML pour skybot/virtual observatory. http://tclxml.sourceforge.net
 - TCom : Protocole Microsoft COM (pour interfaces ASCOM).
 - Thread : Multi-thread.
 - TkHtml : Widget permettant d'afficher une page HTML.
 - TMCI : Gestion du format video avi.
 - Trf : Librairie pour l'outil "Mise à jour d'AudeLA".
 - Vfs : Librairie pour l'outil "Mise à jour d'AudeLA".
 - Zlibtcl : Librairie pour l'outil "Mise à jour d'AudeLA".
 - CFITSIO (2.51).
 - Sextractor.
 - jpeg6b.
 - GZIP.
 - Porttalk.
 - SBIG driver.
 - FLI driver.


Bonne Utilisation !!

Les Auteurs.


AudeLA, page d'accueil : http://www.audela.org

Copyright (C)1999-2008, The AudeLA Core Team.

