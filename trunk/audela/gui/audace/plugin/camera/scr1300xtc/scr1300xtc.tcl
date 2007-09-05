#
# Fichier : scr1300xtc.tcl
# Description : Configuration de la camera SCR1300XTC
# Auteur : Robert DELMAS
# Mise a jour $Id: scr1300xtc.tcl,v 1.12 2007-09-05 21:08:10 robertdelmas Exp $
#

namespace eval ::scr1300xtc {
   package provide scr1300xtc 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] scr1300xtc.cap ]
}

#
# ::scr1300xtc::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::scr1300xtc::getPluginTitle { } {
   global caption

   return "$caption(scr1300xtc,camera)"
}

#
#  ::scr1300xtc::getPluginHelp
#     Retourne la documentation du driver
#
proc ::scr1300xtc::getPluginHelp { } {
   return "scr1300xtc.htm"
}

#
# ::scr1300xtc::getPluginType
#    Retourne le type de driver
#
proc ::scr1300xtc::getPluginType { } {
   return "camera"
}

#
# ::scr1300xtc::initPlugin
#    Initialise les variables conf(scr1300xtc,...)
#
proc ::scr1300xtc::initPlugin { } {
   global conf

   #--- Initialise les variables de la camera SCR1300XTC
   if { ! [ info exists conf(scr1300xtc,port) ] } { set conf(scr1300xtc,port) "LPT1:" }
   if { ! [ info exists conf(scr1300xtc,mirh) ] } { set conf(scr1300xtc,mirh) "0" }
   if { ! [ info exists conf(scr1300xtc,mirv) ] } { set conf(scr1300xtc,mirv) "0" }
}

#
# ::scr1300xtc::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::scr1300xtc::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera SCR1300XTC dans le tableau private(...)
   set private(port) $conf(scr1300xtc,port)
   set private(mirh) $conf(scr1300xtc,mirh)
   set private(mirv) $conf(scr1300xtc,mirv)
}

#
# ::scr1300xtc::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::scr1300xtc::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la camera SCR1300XTC dans le tableau conf(scr1300xtc,...)
   set conf(scr1300xtc,port) $private(port)
   set conf(scr1300xtc,mirh) $private(mirh)
   set conf(scr1300xtc,mirv) $private(mirv)
}

#
# ::scr1300xtc::fillConfigPage
#    Interface de configuration de la camera SCR1300XTC
#
proc ::scr1300xtc::fillConfigPage { frm } {
   variable private
   global audace caption color

   #--- confToWidget
   ::scr1300xtc::confToWidget

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

   #--- Frame de la configuration du port et des miroirs en x et en y
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame de la configuration du port
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

         #--- Definition du port
         label $frm.frame1.frame3.lab1 -text "$caption(scr1300xtc,port)"
         pack $frm.frame1.frame3.lab1 -anchor center -side left -padx 10 -pady 30

         #--- Bouton de configuration des ports et liaisons
         button $frm.frame1.frame3.configure -text "$caption(scr1300xtc,configurer)" -relief raised \
            -command {
               ::confLink::run ::scr1300xtc::private(port) { parallelport } \
                  "- $caption(scr1300xtc,acquisition) - $caption(scr1300xtc,camera)"
            }
         pack $frm.frame1.frame3.configure -anchor center -side left -pady 28 -ipadx 10 -ipady 1 -expand 0

         #--- Choix du port ou de la liaison
         ComboBox $frm.frame1.frame3.port \
            -width 7                      \
            -height [ llength $list_combobox ] \
            -relief sunken                \
            -borderwidth 1                \
            -editable 0                   \
            -textvariable ::scr1300xtc::private(port) \
            -values $list_combobox
         pack $frm.frame1.frame3.port -anchor center -side left -padx 10 -pady 30

      pack $frm.frame1.frame3 -anchor nw -side left -fill x

      #--- Frame des miroirs en x et en y
      frame $frm.frame1.frame4 -borderwidth 0 -relief raised

         #--- Miroir en x et en y
         checkbutton $frm.frame1.frame4.mirx -text "$caption(scr1300xtc,miroir_x)" -highlightthickness 0 \
            -variable ::scr1300xtc::private(mirh)
         pack $frm.frame1.frame4.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame1.frame4.miry -text "$caption(scr1300xtc,miroir_y)" -highlightthickness 0 \
            -variable ::scr1300xtc::private(mirv)
         pack $frm.frame1.frame4.miry -anchor w -side top -padx 20 -pady 10

      pack $frm.frame1.frame4 -anchor nw -side left -fill x -padx 20

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la SCR1300XTC
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(scr1300xtc,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(scr1300xtc,site_web_ref)" \
         "$caption(scr1300xtc,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::scr1300xtc::configureCamera
#    Configure la camera SCR1300XTC en fonction des donnees contenues dans les variables conf(scr1300xtc,...)
#
proc ::scr1300xtc::configureCamera { camItem } {
   global caption conf confCam

   set camNo [ cam::create synonyme $conf(scr1300xtc,port) -name SCR1300XTC ]
   console::affiche_erreur "$caption(scr1300xtc,port_camera) $caption(scr1300xtc,2points) $conf(scr1300xtc,port)\n"
   console::affiche_saut "\n"
   set confCam($camItem,camNo) $camNo
   #--- Je cree la liaison utilisee par la camera pour l'acquisition
   set linkNo [ ::confLink::create $conf(scr1300xtc,port) "cam$camNo" "acquisition" "bits 1 to 8" ]
   #--- J'associe le buffer de la visu
   set bufNo [visu$confCam($camItem,visuNo) buf]
   cam$camNo buf $bufNo
   #--- Je configure l'oriention des miroirs par defaut
   cam$camNo mirrorh $conf(scr1300xtc,mirh)
   cam$camNo mirrorv $conf(scr1300xtc,mirv)
   #---
   ::confVisu::visuDynamix $confCam($camItem,visuNo) 4096 -4096
}

#
# ::scr1300xtc::stop
#    Arrete la camera SCR1300XTC
#
proc ::scr1300xtc::stop { camItem } {
   global conf confCam

   #--- Je ferme la liaison d'acquisition de la camera
   ::confLink::delete $conf(scr1300xtc,port) "cam$confCam($camItem,camNo)" "acquisition"

   #--- J'arrete la camera
   if { $confCam($camItem,camNo) != 0 } {
      cam::delete $confCam($camItem,camNo)
      set confCam($camItem,camNo) 0
   }
}

#
# ::scr1300xtc::getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# binningList :      Retourne la liste des binnings disponibles
# binningXListScan : Retourne la liste des binnings en x disponibles en mode scan
# binningYListScan : Retourne la liste des binnings en y disponibles en mode scan
# hasBinning :       Retourne l'existence d'un binning (1 : Oui, 0 : Non)
# hasFormat :        Retourne l'existence d'un format (1 : Oui, 0 : Non)
# hasLongExposure :  Retourne l'existence du mode longue pose (1 : Oui, 0 : Non)
# hasScan :          Retourne l'existence du mode scan (1 : Oui, 0 : Non)
# hasShutter :       Retourne l'existence d'un obturateur (1 : Oui, 0 : Non)
# hasVideo :         Retourne l'existence du mode video (1 : Oui, 0 : Non)
# hasWindow :        Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
# longExposure :     Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
# multiCamera :      Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
# shutterList :      Retourne l'etat de l'obturateur (O : Ouvert, F : Ferme, S : Synchro)
#
proc ::scr1300xtc::getPluginProperty { camItem propertyName } {
   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 0 }
      hasVideo         { return 0 }
      hasWindow        { return 1 }
      longExposure     { return 1 }
      multiCamera      { return 0 }
      shutterList      { return [ list "" ] }
   }
}

