#
# Fichier : cookbook.tcl
# Description : Configuration de la camera Cookbook
# Auteur : Robert DELMAS
# Mise a jour $Id: cookbook.tcl,v 1.3 2007-05-19 08:39:21 robertdelmas Exp $
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

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill both -expand 1

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side bottom -fill x -pady 2

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -in $frm.frame1 -side top -fill x -expand 0

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -in $frm.frame3 -anchor center -side left -fill x

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -in $frm.frame3 -anchor n -side left -fill x -padx 20

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -in $frm.frame1 -side top -fill x -expand 0

   #--- Definition du port
   label $frm.lab1 -text "$caption(cookbook,port)"
   pack $frm.lab1 -in $frm.frame4 -anchor center -side left -padx 10 -pady 10

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

   #--- Bouton de configuration des ports et liaisons
   button $frm.configure -text "$caption(cookbook,configurer)" -relief raised \
      -command {
         ::confLink::run ::cookbook::private(port) \
            { parallelport } \
            "- $caption(cookbook,acquisition) - $caption(cookbook,camera)"
      }
   pack $frm.configure -in $frm.frame4 -anchor center -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width 7        \
      -height [ llength $list_combobox ] \
      -relief sunken  \
      -borderwidth 1  \
      -editable 0     \
      -textvariable ::cookbook::private(port) \
      -values $list_combobox
   pack $frm.port -in $frm.frame4 -anchor center -side left -padx 10 -pady 10

   #--- Miroir en x et en y
   checkbutton $frm.mirx -text "$caption(cookbook,miroir_x)" -highlightthickness 0 \
      -variable ::cookbook::private(mirh)
   pack $frm.mirx -in $frm.frame5 -anchor w -side top -padx 20 -pady 10

   checkbutton $frm.miry -text "$caption(cookbook,miroir_y)" -highlightthickness 0 \
     -variable ::cookbook::private(mirv)
   pack $frm.miry -in $frm.frame5 -anchor w -side top -padx 20 -pady 10

   #--- Parametrage du delai
   label $frm.lab3 -text "$caption(cookbook,delai)"
   pack $frm.lab3 -in $frm.frame6 -anchor center -side left -padx 10 -pady 4

   entry $frm.delai_a -textvariable ::cookbook::private(delai) -width 7 -justify center
   pack $frm.delai_a -in $frm.frame6 -anchor center -side left

   #--- Site web officiel de la CB245
   label $frm.lab103 -text "$caption(cookbook,titre_site_web)"
   pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

   label $frm.labURL -text "$caption(cookbook,site_web_ref)" -font $audace(font,url) -fg $color(blue)
   pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   #--- Creation du lien avec le navigateur web et changement de sa couleur
   bind $frm.labURL <ButtonPress-1> {
      set filename "$caption(cookbook,site_web_ref)"
      ::audace::Lance_Site_htm $filename
   }
   bind $frm.labURL <Enter> {
      global frmm
      set frm $frmm(Camera4)
      $frm.labURL configure -fg $color(purple)
   }
   bind $frm.labURL <Leave> {
      global frmm
      set frm $frmm(Camera4)
      $frm.labURL configure -fg $color(blue)
   }
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
# ::cookbook::getBinningList
#    Retourne la liste des binnings disponibles de la camera
#
proc ::cookbook::getBinningList { } {
   set binningList { 1x1 }
   return $binningList
}

#
# ::cookbook::getBinningListScan
#    Retourne la liste des binnings disponibles pour les scans de la camera
#
proc ::cookbook::getBinningListScan { } {
   set binningListScan { }
   return $binningListScan
}

# ::cookbook::hasCapability
#    Retourne "la valeur de la propriete"
#
#  Parametres :
#     camNo      : Numero de la camera
#     capability : Fonctionnalite de la camera
#
proc ::cookbook::hasCapability { camNo capability } {
   switch $capability {
      window { return 1 }
   }
}

#
# ::cookbook::hasLongExposure
#    Retourne le mode longue pose de la camera (1 : oui , 0 : non)
#
proc ::cookbook::hasLongExposure { } {
   return 0
}

#
# ::cookbook::getLongExposure
#    Retourne 1 si le mode longue pose est activé
#    Sinon retourne 0
#
proc ::cookbook::getLongExposure { } {
   return 0
}

#
# ::cookbook::hasVideo
#    Retourne le mode video de la camera (1 : oui , 0 : non)
#
proc ::cookbook::hasVideo { } {
   return 0
}

#
# ::cookbook::hasScan
#    Retourne le mode scan de la camera (1 : Oui , 0 : Non)
#
proc ::cookbook::hasScan { } {
   return 0
}

#
# ::cookbook::hasShutter
#    Retourne la presence d'un obturateur (1 : Oui , 0 : Non)
#
proc ::cookbook::hasShutter { } {
   return 0
}

#
# ::cookbook::getShutterOption
#    Retourne le mode de fonctionnement de l'obturateur (O : Ouvert , F : Ferme , S : Synchro)
#
proc ::cookbook::getShutterOption { } {
   global caption

   set ShutterOptionList { }
   return $ShutterOptionList
}

