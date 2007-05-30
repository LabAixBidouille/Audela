#
# Fichier : scr1300xtc.tcl
# Description : Configuration de la camera SCR1300XTC
# Auteur : Robert DELMAS
# Mise a jour $Id: scr1300xtc.tcl,v 1.3 2007-05-30 17:15:20 robertdelmas Exp $
#

namespace eval ::scr1300xtc {
}

#
# ::scr1300xtc::init
#    Initialise les variables conf(scr1300xtc,...) et les captions
#
proc ::scr1300xtc::init { } {
   global audace conf

   #--- Charge le fichier caption
   source [ file join $audace(rep_plugin) camera scr1300xtc scr1300xtc.cap ]

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
# ::scr1300xtc::getBinningList
#    Retourne la liste des binnings disponibles de la camera
#
proc ::scr1300xtc::getBinningList { } {
   set binningList { 1x1 2x2 3x3 4x4 5x5 6x6 }
   return $binningList
}

#
# ::scr1300xtc::getBinningListScan
#    Retourne la liste des binnings disponibles pour les scans de la camera
#
proc ::scr1300xtc::getBinningListScan { } {
   set binningListScan { }
   return $binningListScan
}

# ::scr1300xtc::hasCapability
#    Retourne "la valeur de la propriete"
#
#  Parametres :
#     camNo      : Numero de la camera
#     capability : Fonctionnalite de la camera
#
proc ::scr1300xtc::hasCapability { camNo capability } {
   switch $capability {
      window { return 1 }
   }
}

#
# ::scr1300xtc::hasLongExposure
#    Retourne le mode longue pose de la camera (1 : oui , 0 : non)
#
proc ::scr1300xtc::hasLongExposure { } {
   return 0
}

#
# ::scr1300xtc::getLongExposure
#    Retourne 1 si le mode longue pose est activé
#    Sinon retourne 0
#
proc ::scr1300xtc::getLongExposure { } {
   return 0
}

#
# ::scr1300xtc::hasVideo
#    Retourne le mode video de la camera (1 : oui , 0 : non)
#
proc ::scr1300xtc::hasVideo { } {
   return 0
}

#
# ::scr1300xtc::hasScan
#    Retourne le mode scan de la camera (1 : Oui , 0 : Non)
#
proc ::scr1300xtc::hasScan { } {
   return 0
}

#
# ::scr1300xtc::hasShutter
#    Retourne la presence d'un obturateur (1 : Oui , 0 : Non)
#
proc ::scr1300xtc::hasShutter { } {
   return 0
}

#
# ::scr1300xtc::getShutterOption
#    Retourne le mode de fonctionnement de l'obturateur (O : Ouvert , F : Ferme , S : Synchro)
#
proc ::scr1300xtc::getShutterOption { } {
   global caption

   set ShutterOptionList { }
   return $ShutterOptionList
}

