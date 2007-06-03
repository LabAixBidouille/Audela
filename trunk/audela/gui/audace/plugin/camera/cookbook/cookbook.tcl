#
# Fichier : cookbook.tcl
# Description : Configuration de la camera Cookbook
# Auteur : Robert DELMAS
# Mise a jour $Id: cookbook.tcl,v 1.7 2007-06-03 14:34:28 michelpujol Exp $
#

namespace eval ::cookbook {
}

#
# ::cookbook::init
#    Initialise les variables conf(cookbook,...) et les captions
#
proc ::cookbook::init { } {
   global audace conf

   #--- Charge le fichier caption
   source [ file join $audace(rep_plugin) camera cookbook cookbook.cap ]

   #--- Initialise les variables de la camera CB245
   if { ! [ info exists conf(cookbook,port) ] }  { set conf(cookbook,port)  "LPT1:" }
   if { ! [ info exists conf(cookbook,mirh) ] }  { set conf(cookbook,mirh)  "0" }
   if { ! [ info exists conf(cookbook,mirv) ] }  { set conf(cookbook,mirv)  "0" }
   if { ! [ info exists conf(cookbook,delai) ] } { set conf(cookbook,delai) "142" }
}

#
# ::cookbook::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::cookbook::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera CB245 dans le tableau private(...)
   set private(port)  $conf(cookbook,port)
   set private(mirh)  $conf(cookbook,mirh)
   set private(mirv)  $conf(cookbook,mirv)
   set private(delai) $conf(cookbook,delai)
}

#
# ::cookbook::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::cookbook::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la camera CB245 dans le tableau conf(cookbook,...)
   set conf(cookbook,port)  $private(port)
   set conf(cookbook,mirh)  $private(mirh)
   set conf(cookbook,mirv)  $private(mirv)
   set conf(cookbook,delai) $private(delai)
}

#
# ::cookbook::fillConfigPage
#    Interface de configuration de la camera CB245
#
proc ::cookbook::fillConfigPage { frm } {
   variable private
   global audace caption color

   #--- confToWidget
   ::cookbook::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Je constitue la liste des liaisons pour l'acquisition des images
   set list_combobox [ ::confLink::getLinkLabels { "parallelport" } ]

   #--- Je verifie le contenu de la liste
   if { [llength $list_combobox ] > 0 } {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_combobox $private(port) ] == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private(port) [lindex $list_combobox 0]
      }
   } else {
      #--- si la liste est vide, on continue quand meme
   }

   #--- Frame de la configuration du port, des miroirs en x et en y et du parametrage du delai
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame de la configuration du port
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

         #--- Definition du port
         label $frm.frame1.frame3.lab1 -text "$caption(cookbook,port)"
         pack $frm.frame1.frame3.lab1 -anchor center -side left -padx 10 -pady 30

         #--- Bouton de configuration des ports et liaisons
         button $frm.frame1.frame3.configure -text "$caption(cookbook,configurer)" -relief raised \
            -command {
               ::confLink::run ::cookbook::private(port) { parallelport } \
                  "- $caption(cookbook,acquisition) - $caption(cookbook,camera)"
            }
         pack $frm.frame1.frame3.configure -anchor center -side left -pady 28 -ipadx 10 -ipady 1 -expand 0

         #--- Choix du port ou de la liaison
         ComboBox $frm.frame1.frame3.port \
            -width 7                      \
            -height [ llength $list_combobox ] \
            -relief sunken                \
            -borderwidth 1                \
            -editable 0                   \
            -textvariable ::cookbook::private(port) \
            -values $list_combobox
         pack $frm.frame1.frame3.port -anchor center -side left -padx 10 -pady 30

      pack $frm.frame1.frame3 -anchor nw -side left -fill x

      #--- Frame des miroirs en x et en y
      frame $frm.frame1.frame4 -borderwidth 0 -relief raised

         #--- Miroir en x et en y
         checkbutton $frm.frame1.frame4.mirx -text "$caption(cookbook,miroir_x)" -highlightthickness 0 \
            -variable ::cookbook::private(mirh)
         pack $frm.frame1.frame4.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame1.frame4.miry -text "$caption(cookbook,miroir_y)" -highlightthickness 0 \
            -variable ::cookbook::private(mirv)
         pack $frm.frame1.frame4.miry -anchor w -side top -padx 20 -pady 10

      pack $frm.frame1.frame4 -anchor nw -side left -fill x -padx 20

      #--- Frame du parametrage du delai
      frame $frm.frame1.frame5 -borderwidth 0 -relief raised

         #--- Parametrage du delai
         label $frm.frame1.frame5.lab3 -text "$caption(cookbook,delai)"
         pack $frm.frame1.frame5.lab3 -anchor center -side left -padx 10 -pady 30

         entry $frm.frame1.frame5.delai_a -textvariable ::cookbook::private(delai) -width 7 -justify center
         pack $frm.frame1.frame5.delai_a -anchor center -side left -pady 30

      pack $frm.frame1.frame5 -anchor nw -side left -fill x

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la CB245
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(cookbook,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(cookbook,site_web_ref)" \
         "$caption(cookbook,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::cookbook::configureCamera
#    Configure la camera CB245 en fonction des donnees contenues dans les variables conf(cookbook,...)
#
proc ::cookbook::configureCamera { camItem } {
   global caption conf confCam

   set camNo [ cam::create cookbook $conf(cookbook,port) -name CB245 ]
   console::affiche_erreur "$caption(cookbook,port_camera) $caption(cookbook,2points) $conf(cookbook,port)\n"
   console::affiche_saut "\n"
   set confCam($camItem,camNo) $camNo
   #--- Je cree la liaison utilisee par la camera pour l'acquisition
   set linkNo [ ::confLink::create $conf(cookbook,port) "cam$camNo" "acquisition" "bits 1 to 8" ]
   #--- Je configure le delai
   cam$camNo delay $conf(cookbook,delai)
   #--- J'associe le buffer de la visu
   set bufNo [visu$confCam($camItem,visuNo) buf]
   cam$camNo buf $bufNo
   #--- Je configure l'oriention des miroirs par defaut
   cam$camNo mirrorh $conf(cookbook,mirh)
   cam$camNo mirrorv $conf(cookbook,mirv)
   #---
   ::confVisu::visuDynamix $confCam($camItem,visuNo) 4096 -4096
}

#
# ::cookbook::getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# binningList :     Retourne la liste des binnings disponibles
# binningListScan : Retourne la liste des binnings disponibles en mode scan
# hasLongExposure : Retourne l'existence du mode longue pose (1 : Oui, 0 : Non)
# hasScan :         Retourne l'existence du mode scan (1 : Oui, 0 : Non)
# hasShutter :      Retourne l'existence d'un obturateur (1 : Oui, 0 : Non)
# hasVideo :        Retourne l'existence du mode video (1 : Oui, 0 : Non)
# hasWindow :       Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
# longExposure :    Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
# multiCamera :     Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
# shutterList :     Retourne l'etat de l'obturateur (O : Ouvert, F : Ferme, S : Synchro)
#
proc ::cookbook::getPluginProperty { camItem propertyName } {
   switch $propertyName {
      binningList     { return [ list 1x1 ] }
      binningListScan { return [ list "" ] }
      hasBinning      { return 1 }
      hasLongExposure { return 0 }
      hasScan         { return 0 }
      hasShutter      { return 0 }
      hasVideo        { return 0 }
      hasWindow       { return 1 }
      longExposure    { return 1 }
      multiCamera     { return 0 }
      shutterList     { return [ list "" ] }
   }
}

