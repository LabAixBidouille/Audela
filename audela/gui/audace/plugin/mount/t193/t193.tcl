#
# Fichier : t193.tcl
# Description : Configuration de la monture du T193 de l'OHP
# Auteur : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: t193.tcl,v 1.5 2009-05-14 12:27:22 michelpujol Exp $
#

namespace eval ::t193 {
   package provide t193 1.0
   package require audela 1.5.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] t193.cap ]
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::t193::getPluginTitle { } {
   global caption

   return "$caption(t193,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::t193::getPluginHelp { } {
   return "t193.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::t193::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::t193::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::t193::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::t193::isReady { } {
   variable private

   if { $private(telNo) == "0" } {
      #--- Monture KO
      return 0
   } else {
      #--- Monture OK
      return 1
   }
}

#
# initPlugin
#    Initialise les variables conf(t193,...)
#
proc ::t193::initPlugin { } {
   variable private
   global conf

   #--- Initialisation
   set private(telNo) "0"
   set private(frm)   ""

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- configuration de la monture du T193 de l'OHP
   if { ! [ info exists conf(t193,portSerie) ] }      { set conf(t193,portSerie)  [ lindex $list_connexion 0 ] }
   if { ! [ info exists conf(t193,nomCarte) ] }       { set conf(t193,nomCarte)   "Dev1" }
   if { ! [ info exists conf(t193,nomPortTelescope) ] }       { set conf(t193,nomPortTelescope)   "port0" }
   if { ! [ info exists conf(t193,nomPortAttenuateur) ] }     { set conf(t193,nomPortAttenuateur)   "port1" }
   #--- vitesses de guidage en arcseconde de degre par seconde de temps
   if { ! [ info exists conf(t193,alphaSpeed) ] }     { set conf(t193,alphaSpeed) "1.0" }
   if { ! [ info exists conf(t193,deltaSpeed) ] }     { set conf(t193,alphaSpeed) "1.0" }
   #--- duree de deplacement entre les 2 butees (mini et maxi) de l'attenuateur
   if { ! [ info exists conf(t193,dureeMaxAttenuateur) ] }          { set conf(t193,dureeMaxAttenuateur)      "16" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::t193::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture du T193 de l'OHP dans le tableau private(...)
   set private(portSerie) $conf(t193,portSerie)
   set private(nomCarte)  $conf(t193,nomCarte)
   set private(nomPortTelescope)  $conf(t193,nomPortTelescope)
   set private(nomPortAttenuateur)  $conf(t193,nomPortAttenuateur)
   set private(dureeMaxAttenuateur)     $conf(t193,dureeMaxAttenuateur)
   set private(raquette)  $conf(raquette)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::t193::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture du T193 de l'OHP dans le tableau conf(t193,...)
   set conf(t193,portSerie) $private(portSerie)
   set conf(t193,nomCarte)  $private(nomCarte)
   set conf(t193,nomPortTelescope)  $private(nomPortTelescope)
   set conf(t193,nomPortAttenuateur)  $private(nomPortAttenuateur)
   set conf(t193,dureeMaxAttenuateur)     $private(dureeMaxAttenuateur)
   set conf(raquette)                     $private(raquette)
}

#
# fillConfigPage
#    Interface de configuration de la monture du T193 de l'OHP
#
proc ::t193::fillConfigPage { frm } {
   variable private
   global audace caption

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::t193::confToWidget

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill x

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side top -fill x

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -side top -fill x

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -side top -fill x

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -side bottom -fill x -pady 2

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -side bottom -fill x -pady 2

   #--- Definition du port serie
   label $frm.lab4 -text "$caption(t193,port)"
   pack $frm.lab4 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

   #--- Je verifie le contenu de la liste
   if { [ llength $list_connexion ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_connexion $private(portSerie) ] == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private(portSerie) [ lindex $list_connexion 0 ]
      }
   } else {
      #--- Si la liste est vide, on continue quand meme
   }

   #--- Bouton de configuration des ports
   button $frm.configure -text "$caption(t193,configurer)" -relief raised \
      -command {
         ::confLink::run ::t193::private(portSerie) { serialport } \
            "- $caption(t193,controle) - $caption(t193,monture)"
      }
   pack $frm.configure -in $frm.frame3 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port
   ComboBox $frm.portSerie \
      -width [ ::tkutil::lgEntryComboBox $list_connexion ] \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::t193::private(portSerie) \
      -editable 0       \
      -values $list_connexion
   pack $frm.portSerie -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

   #--- Definition du nom de la carte USB-6501 et de son port
   label $frm.lab2 -text "$caption(t193,nom_carte)"
   pack $frm.lab2 -in $frm.frame4 -anchor n -side left -padx 10 -pady 10

   #--- Entry du du nom de la carte USB-6501 et de son port
   entry $frm.nomCarte -textvariable ::t193::private(nomCarte) -width 15 -justify left
   pack $frm.nomCarte -in $frm.frame4 -anchor n -side left -padx 10 -pady 10

   #--- J'affiche les boutons N, S, E et O
   TitleFrame $frm.test1 -borderwidth 2 -relief ridge -text "$caption(t193,raquette)"

      #--- J'affiche le bouton E
      button $frm.test1.est -text "$caption(t193,est)" -relief ridge -width 2
      grid $frm.test1.est -in [ $frm.test1 getframe ] -row 1 -column 1 -ipadx 5

      #--- J'affiche le bouton N
      button $frm.test1.nord -text "$caption(t193,nord)" -relief ridge -width 2
      grid $frm.test1.nord -in [ $frm.test1 getframe ] -row 0 -column 2 -ipadx 5

      #--- J'affiche le bouton S
      button $frm.test1.sud -text "$caption(t193,sud)" -relief ridge -width 2
      grid $frm.test1.sud -in [ $frm.test1 getframe ] -row 2 -column 2 -ipadx 5

      #--- J'affiche le bouton O
      button $frm.test1.ouest -text "$caption(t193,ouest)" -relief ridge -width 2
      grid $frm.test1.ouest -in [ $frm.test1 getframe ] -row 1 -column 3 -ipadx 5

      grid rowconfigure [ $frm.test1 getframe ] 0 -minsize 25 -weight 0
      grid rowconfigure [ $frm.test1 getframe ] 1 -minsize 25 -weight 0
      grid rowconfigure [ $frm.test1 getframe ] 2 -minsize 25 -weight 0

      grid columnconfigure [ $frm.test1 getframe ] 1 -minsize 40 -weight 0
      grid columnconfigure [ $frm.test1 getframe ] 2 -minsize 40 -weight 0
      grid columnconfigure [ $frm.test1 getframe ] 3 -minsize 40 -weight 0

   pack $frm.test1 -side left -anchor w -fill none -pady 5 -expand 1

   #--- J'affiche le bouton pour la lecture des coordonnees AD et Dec.
   TitleFrame $frm.test2 -borderwidth 2 -relief ridge -text "$caption(t193,coordonnées)"

      #--- J'affiche le label pour l'AD
      label $frm.test2.labAD -text $caption(t193,AD)
      grid $frm.test2.labAD -in [ $frm.test2 getframe ] -row 0 -column 1

      #--- J'affiche l'entry de l'AD
      entry $frm.test2.entryAD -textvariable audace(telescope,getra) -width 15 \
         -justify center -state disabled
      grid $frm.test2.entryAD -in [ $frm.test2 getframe ] -row 1 -column 1

      #--- J'affiche le label pour la Dec.
      label $frm.test2.labDec -text $caption(t193,Dec)
      grid $frm.test2.labDec -in [ $frm.test2 getframe ] -row 0 -column 2

      #--- J'affiche l'entry de la Dec.
      entry $frm.test2.entryDec -textvariable audace(telescope,getdec) -width 15 \
         -justify center -state disabled
      grid $frm.test2.entryDec -in [ $frm.test2 getframe ] -row 1 -column 2

      #--- J'affiche le bouton de lecture des coordonnees
      button $frm.test2.lecture -text $caption(t193,lecture) -relief raised \
         -command "::telescope::afficheCoord"
      grid $frm.test2.lecture -in [ $frm.test2 getframe ] -row 2 -column 1 -columnspan 2 -ipadx 15

      grid rowconfigure [ $frm.test2 getframe ] 0 -minsize 30 -weight 0
      grid rowconfigure [ $frm.test2 getframe ] 2 -minsize 30 -weight 0

   pack $frm.test2 -side left -anchor w -fill none -pady 5 -expand 1

   #--- J'affiche les boutons - et + de l'attenuateur
   TitleFrame $frm.test3 -borderwidth 2 -relief ridge -text "$caption(t193,attenuateur)"

      #--- J'affiche le label pour la duree du deplacement
      label $frm.test3.attenuateur -text $caption(t193,duree)
      grid $frm.test3.attenuateur -in [ $frm.test3 getframe ] -row 0 -column 1

      #--- J'affiche l'entry de la duree du deplacement
      entry $frm.test3.entryDuree -textvariable ::t193::private(dureeMaxAttenuateur) -width 5 \
         -justify left
      grid $frm.test3.entryDuree -in [ $frm.test3 getframe ] -row 0 -column 2

      #--- J'affiche le bouton -
      button $frm.test3.attenuateur- -text "$caption(t193,attenuateur-)" -relief ridge -width 2
      grid $frm.test3.attenuateur- -in [ $frm.test3 getframe ] -row 1 -column 1 -ipadx 5

      #--- J'affiche le bouton +
      button $frm.test3.attenuateur+ -text "$caption(t193,attenuateur+)" -relief ridge -width 2
      grid $frm.test3.attenuateur+ -in [ $frm.test3 getframe ] -row 1 -column 2 -ipadx 5

      #--- J'affiche l'entry de la position de l'attenuateur
      entry $frm.test3.entryPosition -textvariable ::t193::private(position) \
         -justify center -state disabled
      grid $frm.test3.entryPosition -in [ $frm.test3 getframe ] -row 2 -column 1 -columnspan 2 \
         -sticky ew

      grid rowconfigure [ $frm.test3 getframe ] 0 -minsize 25 -weight 0
      grid rowconfigure [ $frm.test3 getframe ] 1 -minsize 25 -weight 0
      grid rowconfigure [ $frm.test3 getframe ] 2 -minsize 25 -weight 0

      grid columnconfigure [ $frm.test3 getframe ] 1 -minsize 40 -weight 0
      grid columnconfigure [ $frm.test3 getframe ] 2 -minsize 40 -weight 0

   pack $frm.test3 -side left -anchor w -fill none -pady 5 -expand 1

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(t193,raquette_tel)" \
      -highlightthickness 0 -variable ::t193::private(raquette)
   pack $frm.raquette -in $frm.frame6 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame6 -anchor center -side left -padx 0 -pady 10

   #--- Site web officiel du T193 de l'OHP
   label $frm.lab103 -text "$caption(t193,titre_site_web)"
   pack $frm.lab103 -in $frm.frame7 -side top -fill x -pady 2

   set labelName [ ::confTel::createUrlLabel $frm.frame7 "$caption(t193,site_t193)" \
      "$caption(t193,site_t193)" ]
   pack $labelName -side top -fill x -pady 2

   #--- Configuration des boutons de test
   ::t193::configureConfigPage

   #--- Actions des boutons E, N, S et O
   bind $frm.test1.est <ButtonPress-1>     "::t193::moveTelescop e press"
   bind $frm.test1.est <ButtonRelease-1>   "::t193::moveTelescop e release"
   bind $frm.test1.nord <ButtonPress-1>    "::t193::moveTelescop n press"
   bind $frm.test1.nord <ButtonRelease-1>  "::t193::moveTelescop n release"
   bind $frm.test1.sud <ButtonPress-1>     "::t193::moveTelescop s press"
   bind $frm.test1.sud <ButtonRelease-1>   "::t193::moveTelescop s release"
   bind $frm.test1.ouest <ButtonPress-1>   "::t193::moveTelescop w press"
   bind $frm.test1.ouest <ButtonRelease-1> "::t193::moveTelescop w release"

   #--- Actions des boutons - et + de l'attenuateur
   bind $frm.test3.attenuateur- <ButtonPress-1>   "::t193::moveFilter -"
   bind $frm.test3.attenuateur- <ButtonRelease-1> "::t193::stopFilter"
   bind $frm.test3.attenuateur+ <ButtonPress-1>   "::t193::moveFilter +"
   bind $frm.test3.attenuateur+ <ButtonRelease-1> "::t193::stopFilter"
}

#
# configureMonture
#    Configure la monture du T193 de l'OHP en fonction des donnees contenues dans les variables conf(t193,...)
#
proc ::t193::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      set usbLine "0 1 2 3 4 0 1 2 3"
      #--- Je cree la monture
      set telNo [ tel::create t193 HP1000 -hpcom $conf(t193,portSerie) \
         -usbCardName $::conf(t193,nomCarte) \
         -usbTelescopPort $::conf(t193,nomPortTelescope) \
         -usbFilterPort   $::conf(t193,nomPortAttenuateur) \
         -northRelay 0 \
         -southRelay 1 \
         -estRelay   2 \
         -westRelay  3 \
         -enabledRelay 4 \
         -decreaseFilterRelay 0 \
         -increaseFilterRelay 1 \
         -minDetectorFilterInput 2 \
         -maxDetectorFilterInput 3 \
         -filterMaxDelay $conf(t193,dureeMaxAttenuateur) \
      ]

      #--- J'affiche un message d'information dans la Console
      ::console::affiche_entete "$caption(t193,port_t193) $caption(t193,2points) $conf(t193,portSerie)\n"
      ::console::affiche_entete "$caption(t193,nom_carte) $caption(t193,2points) $conf(t193,nomCarte)\n"
      ::console::affiche_saut "\n"
      #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
      set linkNo [ ::confLink::create $conf(t193,portSerie) "tel$telNo" "control" [ tel$telNo product ] -noopen ]
      #--- Je change de variable
      set private(telNo) $telNo
      #--- Configuration des boutons de test
      ::t193::configureConfigPage
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::t193::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture du T193 de l'OHP
#
proc ::t193::stop { } {
   variable private
   global conf

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Je memorise le port
   set telPort [ tel$private(telNo) port ]
   #--- J'arrete la monture
   tel::delete $private(telNo)
   #--- J'arrete le link
   ::confLink::delete $telPort "tel$private(telNo)" "control"
   #--- Remise a zero du numero de monture
   set private(telNo) "0"

   #--- Configuration des boutons de test
   ::t193::configureConfigPage
}

# configureConfigPage
#   Autorise/Interdit les widgets de test
#
proc ::t193::configureConfigPage { } {
   variable private

   if { [ winfo exists $private(frm) ] } {
      if { [ ::t193::isReady ] == 1 } {
         #--- J'active les boutons de l'interface
         $private(frm).test1.est configure -state normal
         $private(frm).test1.nord configure -state normal
         $private(frm).test1.sud configure -state normal
         $private(frm).test1.ouest configure -state normal
         $private(frm).test2.lecture configure -state normal
         $private(frm).test3.entryDuree configure -state normal
         $private(frm).test3.attenuateur- configure -state normal
         $private(frm).test3.attenuateur+ configure -state normal
      } else {
         #--- Je desactive les boutons de l'interface
         $private(frm).test1.est configure -state disabled
         $private(frm).test1.nord configure -state disabled
         $private(frm).test1.sud configure -state disabled
         $private(frm).test1.ouest configure -state disabled
         $private(frm).test2.lecture configure -state disabled
         $private(frm).test3.entryDuree configure -state disabled
         $private(frm).test3.attenuateur- configure -state disabled
         $private(frm).test3.attenuateur+ configure -state disabled
      }
   }
}

#
# moveTelescop
#    Actionne les mouvements du telescope
#
proc ::t193::moveTelescop { direction state } {
   variable private

   if { $private(telNo) == "0" } {
      return
   }

   if { $state == "press" } {
      ::telescope::move $direction
   } else {
      ::telescope::stop $direction
   }
}

#
# moveFilter
#    Actionne le filtre attenuateur
#
proc ::t193::moveFilter { direction } {
   variable private

   if { [ ::tel::list ] != "" } {
      tel$private(telNo) filter move $direction
   }
}

#
# stopFilter
#    Arrete le filtre attenuateur et lit sa position
#
proc ::t193::stopFilter { } {
   variable private

   if { [ ::tel::list ] != "" } {
      tel$private(telNo) filter stop
      set private(position) [ tel$private(telNo) filter coord ]
   }
}

#
# getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# multiMount              Retourne la possibilite de se connecter avec Ouranos (1 : Oui, 0 : Non)
# name                    Retourne le modele de la monture
# product                 Retourne le nom du produit
# hasCoordinates          Retourne la possibilite d'afficher les coordonnees
# hasGoto                 Retourne la possibilite de faire un Goto
# hasMatch                Retourne la possibilite de faire un Match
# hasManualMotion         Retourne la possibilite de faire des deplacement Nord, Sud, Est ou Ouest
# hasControlSuivi         Retourne la possibilite d'arreter le suivi sideral
# hasCorrectionRefraction Retourne la possibilite de calculer les corrections de refraction
# hasModel                Retourne la possibilite d'avoir plusieurs modeles pour le meme product
# hasPark                 Retourne la possibilite de parquer la monture
# hasUnpark               Retourne la possibilite de de-parquer la monture
# hasUpdateDate           Retourne la possibilite de mettre a jour la date et le lieu
# backlash                Retourne la possibilite de faire un rattrapage des jeux
#
proc ::t193::getPluginProperty { propertyName } {
   variable private

   switch $propertyName {
      multiMount              { return 0 }
      name                    {
         if { $private(telNo) != "0" } {
            return [ tel$private(telNo) name ]
         } else {
            return ""
         }
      }
      product                 {
         if { $private(telNo) != "0" } {
            return [ tel$private(telNo) product ]
         } else {
            return ""
         }
      }
      hasCoordinates          { return 1 }
      hasGoto                 { return 0 }
      hasMatch                { return 0 }
      hasManualMotion         { return 1 }
      hasControlSuivi         { return 0 }
      hasCorrectionRefraction { return 0 }
      hasModel                { return 0 }
      hasPark                 { return 0 }
      hasUnpark               { return 0 }
      hasUpdateDate           { return 0 }
      backlash                { return 0 }
      guidingSpeed            { return [list $::conf(t193,alphaGuidingSpeed) $::conf(t193,deltaGuidingSpeed) ] }
   }
}

