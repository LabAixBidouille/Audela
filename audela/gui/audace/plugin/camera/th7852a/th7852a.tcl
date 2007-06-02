#
# Fichier : th7852a.tcl
# Description : Configuration de la camera TH7852A
# Auteur : Robert DELMAS
# Mise a jour $Id: th7852a.tcl,v 1.5 2007-06-02 00:19:11 robertdelmas Exp $
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

   #--- Frame du coefficent et des miroirs en x et en y
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame du coefficient
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

         label $frm.frame1.frame3.lab2 -text "$caption(th7852a,coef)"
         pack $frm.frame1.frame3.lab2 -anchor n -side left -padx 10 -pady 30

         entry $frm.frame1.frame3.coef -textvariable ::th7852a::private(coef) -width 5 -justify center
         pack $frm.frame1.frame3.coef -anchor n -side left -padx 0 -pady 30

      pack $frm.frame1.frame3 -anchor n -side left -fill x

      #--- Frame des miroirs en x et en y
      frame $frm.frame1.frame4 -borderwidth 0 -relief raised

         checkbutton $frm.frame1.frame4.mirx -text "$caption(th7852a,miroir_x)" -highlightthickness 0 \
            -variable ::th7852a::private(mirh)
         pack $frm.frame1.frame4.mirx -anchor w -side top -padx 20 -pady 10

         checkbutton $frm.frame1.frame4.miry -text "$caption(th7852a,miroir_y)" -highlightthickness 0 \
            -variable ::th7852a::private(mirv)
         pack $frm.frame1.frame4.miry -anchor w -side top -padx 20 -pady 10

      pack $frm.frame1.frame4 -anchor n -side left -fill x -padx 20

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la TH7852A d'Yves LATIL (a creer)
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(th7852a,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(th7852a,site_web_ref)" "" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::th7852a::configureCamera
#    Configure la camera TH7852A en fonction des donnees contenues dans les variables conf(th7852a,...)
#
proc ::th7852a::configureCamera { camItem } {
   global caption conf confCam

   set camNo [ cam::create camth "unknown" -name TH7852A ]
   set confCam($camItem,product) [ cam$camNo product ]
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
# ::th7852a::getPluginProperty
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
proc ::th7852a::getPluginProperty { camItem propertyName } {
   switch $propertyName {
      binningList     { return [ list 1x1 2x2 3x3 4x4 ] }
      binningListScan { return [ list "" ] }
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

