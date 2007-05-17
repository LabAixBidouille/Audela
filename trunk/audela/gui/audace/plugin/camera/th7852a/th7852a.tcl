#
# Fichier : th7852a.tcl
# Description : Configuration de la camera TH7852A
# Auteur : Robert DELMAS
# Mise a jour $Id: th7852a.tcl,v 1.2 2007-05-17 16:58:29 robertdelmas Exp $
#

namespace eval ::th7852a {
}

#
# ::th7852a::init
#    Initialise les variables conf(th7852a,...) et les captions
#
proc ::th7852a::init { } {
   global audace conf

   #--- Charge le fichier caption
   source [ file join $audace(rep_plugin) camera th7852a th7852a.cap ]

   #--- Initialise la variable de la camera TH7852A
   if { ! [ info exists conf(th7852a,mirh) ] } { set conf(th7852a,mirh) "0" }
   if { ! [ info exists conf(th7852a,mirv) ] } { set conf(th7852a,mirv) "0" }
   if { ! [ info exists conf(th7852a,coef) ] } { set conf(th7852a,coef) "1.0" }
}

#
# ::th7852a::confToWidget
#    Copie la variable de configuration dans une variable locale
#
proc ::th7852a::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera TH7852A dans le tableau private(...)
   set private(mirh) $conf(th7852a,mirh)
   set private(mirv) $conf(th7852a,mirv)
   set private(coef) $conf(th7852a,coef)
}

#
# ::th7852a::widgetToConf
#    Copie la variable locale dans une variable de configuration
#
proc ::th7852a::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la camera TH7852A dans le tableau conf(th7852a,...)
   set conf(th7852a,mirh) $private(mirh)
   set conf(th7852a,mirv) $private(mirv)
   set conf(th7852a,coef) $private(coef)
}

#
# ::th7852a::fillConfigPage
#    Interface de configuration de la camera TH7852A
#
proc ::th7852a::fillConfigPage { frm } {
   variable private
   global audace caption color

   #--- confToWidget
   ::th7852a::confToWidget

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

   #--- Definition du coefficient
   label $frm.lab2 -text "$caption(th7852a,coef)"
   pack $frm.lab2 -in $frm.frame4 -anchor n -side left -padx 10 -pady 12

   entry $frm.coef -textvariable ::th7852a::private(coef) -width 5 -justify center
   pack $frm.coef -in $frm.frame4 -anchor n -side left -padx 0 -pady 12

   #--- Miroir en x et en y
   checkbutton $frm.mirx -text "$caption(th7852a,miroir_x)" -highlightthickness 0 \
      -variable ::th7852a::private(mirh)
   pack $frm.mirx -in $frm.frame5 -anchor w -side top -padx 20 -pady 10

   checkbutton $frm.miry -text "$caption(th7852a,miroir_y)" -highlightthickness 0 \
      -variable ::th7852a::private(mirv)
   pack $frm.miry -in $frm.frame5 -anchor w -side top -padx 20 -pady 10

   #--- Site web officiel de la TH7852A d'Yves LATIL
   label $frm.lab103 -text "$caption(th7852a,titre_site_web)"
   pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

   label $frm.labURL -text "$caption(th7852a,site_web_ref)" -font $audace(font,url) -fg $color(blue)
   pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

   #--- Creation du lien avec le navigateur web et changement de sa couleur
  ### bind $frm.labURL <ButtonPress-1> {
  ###    set filename "$caption(th7852a,site_web_ref)"
  ###    ::audace::Lance_Site_htm $filename
  ### }
   bind $frm.labURL <Enter> {
      global frmm
      set frm $frmm(Camera8)
      $frm.labURL configure -fg $color(purple)
   }
   bind $frm.labURL <Leave> {
      global frmm
      set frm $frmm(Camera8)
      $frm.labURL configure -fg $color(blue)
   }
}

#
# ::th7852a::configureCamera
#    Configure la camera TH7852A en fonction des donnees contenues dans les variables conf(th7852a,...)
#
proc ::th7852a::configureCamera { camItem } {
   global caption conf confCam

   set camNo [ cam::create camth "unknown" -name TH7852A ]
   console::affiche_erreur "$caption(th7852a,port) $caption(th7852a,2points) $caption(th7852a,bus_ISA)\n"
   console::affiche_saut "\n"
   set confCam($camItem,camNo) $camNo
   #--- J'associe le buffer de la visu
   set bufNo [visu$confCam($camItem,visuNo) buf]
   cam$camNo buf $bufNo
   #--- Je configure l'oriention des miroirs par defaut
   cam$camNo mirrorh $conf(th7852a,mirh)
   cam$camNo mirrorv $conf(th7852a,mirv)
   #--- Je configure le coefficient
   cam$camNo timescale $conf(th7852a,coef)
   #---
   ::confVisu::visuDynamix $confCam($camItem,visuNo) 32767 -32768
}

#
# ::th7852a::getBinningList
#    Retourne la liste des binnings disponibles de la camera
#
proc ::th7852a::getBinningList { } {
   set binningList { 1x1 2x2 3x3 4x4 }
   return $binningList
}

#
# ::th7852a::getBinningListScan
#    Retourne la liste des binnings disponibles pour les scans de la camera
#
proc ::th7852a::getBinningListScan { } {
   set binningListScan { }
   return $binningListScan
}

# ::th7852a::hasCapability
#    Retourne "la valeur de la propriete"
#
#  Parametres :
#     camNo      : Numero de la camera
#     capability : Fonctionnalite de la camera
#
proc ::th7852a::hasCapability { camNo capability } {
   switch $capability {
      window { return 1 }
   }
}

#
# ::th7852a::hasLongExposure
#    Retourne le mode longue pose de la camera (1 : oui , 0 : non)
#
proc ::th7852a::hasLongExposure { } {
   return 0
}

#
# ::th7852a::getLongExposure
#    Retourne 1 si le mode longue pose est activé
#    Sinon retourne 0
#
proc ::th7852a::getLongExposure { } {
   return 0
}

#
# ::th7852a::hasVideo
#    Retourne le mode video de la camera (1 : oui , 0 : non)
#
proc ::th7852a::hasVideo { } {
   return 0
}

#
# ::th7852a::hasScan
#    Retourne le mode scan de la camera (1 : Oui , 0 : Non)
#
proc ::th7852a::hasScan { } {
   return 0
}

#
# ::th7852a::hasShutter
#    Retourne la presence d'un obturateur (1 : Oui , 0 : Non)
#
proc ::th7852a::hasShutter { } {
   return 0
}

#
# ::th7852a::getShutterOption
#    Retourne le mode de fonctionnement de l'obturateur (O : Ouvert , F : Ferme , S : Synchro)
#
proc ::th7852a::getShutterOption { } {
   global caption

   set ShutterOptionList { }
   return $ShutterOptionList
}

