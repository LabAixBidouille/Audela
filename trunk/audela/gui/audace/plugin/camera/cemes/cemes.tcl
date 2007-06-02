#
# Fichier : cemes.tcl
# Description : Configuration de la camera Cemes
# Auteurs : Robert DELMAS
# Mise a jour $Id: cemes.tcl,v 1.10 2007-06-02 00:15:41 robertdelmas Exp $
#

namespace eval ::cemes {
}

#
# ::cemes::init
#    Initialise les variables conf(cemes,...) et les captions
#
proc ::cemes::init { } {
   global audace conf

   #--- Charge le fichier caption
   source [ file join $audace(rep_plugin) camera cemes cemes.cap ]

   #--- Initialise les variables de la camera Cemes
   if { ! [ info exists conf(cemes,cool) ] }     { set conf(cemes,cool)     "0" }
   if { ! [ info exists conf(cemes,foncobtu) ] } { set conf(cemes,foncobtu) "2" }
   if { ! [ info exists conf(cemes,mirh) ] }     { set conf(cemes,mirh)     "0" }
   if { ! [ info exists conf(cemes,mirv) ] }     { set conf(cemes,mirv)     "0" }
   if { ! [ info exists conf(cemes,temp) ] }     { set conf(cemes,temp)     "-50" }
}

#
# ::cemes::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::cemes::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera Cemes dans le tableau private(...)
   set private(cool)     $conf(cemes,cool)
   set private(foncobtu) [ lindex "$caption(cemes,obtu_ouvert) $caption(cemes,obtu_ferme) $caption(cemes,obtu_synchro)" $conf(cemes,foncobtu) ]
   set private(mirh)     $conf(cemes,mirh)
   set private(mirv)     $conf(cemes,mirv)
   set private(temp)     $conf(cemes,temp)
}

#
# ::cemes::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::cemes::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera Cemes dans le tableau conf(cemes,...)
   set conf(cemes,cool)     $private(cool)
   set conf(cemes,foncobtu) [ lsearch "$caption(cemes,obtu_ouvert) $caption(cemes,obtu_ferme) $caption(cemes,obtu_synchro)" "$private(foncobtu)" ]
   set conf(cemes,mirh)     $private(mirh)
   set conf(cemes,mirv)     $private(mirv)
   set conf(cemes,temp)     $private(temp)
}

#
# ::cemes::fillConfigPage
#    Interface de configuration de la camera Cemes
#
proc ::cemes::fillConfigPage { frm } {
   variable private
   global audace caption color

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- confToWidget
   ::cemes::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Frame du refroidissement, de la temperature du capteur CCD, des miroirs en x et en y et de l'obturateur
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Frame du refroidissement, de la temperature du capteur CCD et des miroirs en x et en y
      frame $frm.frame1.frame3 -borderwidth 0 -relief raised

         #--- Frame du refroidissement et de la temperature du capteur CCD
         frame $frm.frame1.frame3.frame4 -borderwidth 0 -relief raised

            #--- Frame du refroidissement
            frame $frm.frame1.frame3.frame4.frame6 -borderwidth 0 -relief raised

               #--- Definition du refroidissement
               checkbutton $frm.frame1.frame3.frame4.frame6.cool -text "$caption(cemes,refroidissement)" \
                  -highlightthickness 0 -variable ::cemes::private(cool)
               pack $frm.frame1.frame3.frame4.frame6.cool -anchor center -side left -padx 0 -pady 5

               entry $frm.frame1.frame3.frame4.frame6.temp -textvariable ::cemes::private(temp) -width 4 \
                  -justify center
               pack $frm.frame1.frame3.frame4.frame6.temp -anchor center -side left -padx 5 -pady 5

               label $frm.frame1.frame3.frame4.frame6.tempdeg \
                  -text "$caption(cemes,deg_c) $caption(cemes,refroidissement_1)"
               pack $frm.frame1.frame3.frame4.frame6.tempdeg -side left -fill x -padx 0 -pady 5

            pack $frm.frame1.frame3.frame4.frame6 -side top -fill x -padx 10

            #--- Frame de la temperature du capteur CCD
            frame $frm.frame1.frame3.frame4.frame7 -borderwidth 0 -relief raised

               #--- Definition de la temperature du capteur CCD
               label $frm.frame1.frame3.frame4.frame7.temp_ccd -text "$caption(cemes,temperature_CCD)"
               pack $frm.frame1.frame3.frame4.frame7.temp_ccd -side left -fill x -padx 20 -pady 5

            pack $frm.frame1.frame3.frame4.frame7 -side top -fill x -padx 30

         pack $frm.frame1.frame3.frame4 -side left -fill x -expand 0

         #--- Frame des miroirs en x et en y
         frame $frm.frame1.frame3.frame5 -borderwidth 0 -relief raised

            #--- Miroirs en x et en y
            checkbutton $frm.frame1.frame3.frame5.mirx -text "$caption(cemes,miroir_x)" -highlightthickness 0 \
               -variable ::cemes::private(mirh)
            pack $frm.frame1.frame3.frame5.mirx -anchor w -side top -padx 20 -pady 10

            checkbutton $frm.frame1.frame3.frame5.miry -text "$caption(cemes,miroir_y)" -highlightthickness 0 \
               -variable ::cemes::private(mirv)
            pack $frm.frame1.frame3.frame5.miry -anchor w -side top -padx 20 -pady 10

         pack $frm.frame1.frame3.frame5 -anchor n -side left -fill x -padx 20

      pack $frm.frame1.frame3 -side top -fill x -expand 0

      #--- Frame du mode de fonctionnement de l'obturateur
      frame $frm.frame1.frame8 -borderwidth 0 -relief raised

         #--- Mode de fonctionnement de l'obturateur
         label $frm.frame1.frame8.lab3 -text "$caption(cemes,fonc_obtu)"
         pack $frm.frame1.frame8.lab3 -anchor nw -side left -padx 10 -pady 5

         set list_combobox [ list $caption(cemes,obtu_ouvert) $caption(cemes,obtu_ferme) $caption(cemes,obtu_synchro) ]
         ComboBox $frm.frame1.frame8.foncobtu \
            -width 11           \
            -height [ llength $list_combobox ] \
            -relief sunken      \
            -borderwidth 1      \
            -editable 0         \
            -textvariable ::cemes::private(foncobtu) \
            -values $list_combobox
         pack $frm.frame1.frame8.foncobtu -anchor nw -side left -padx 0 -pady 5

      pack $frm.frame1.frame8 -side top -fill x -expand 0

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Frame du site web officiel de la Cemes
   frame $frm.frame2 -borderwidth 0 -relief raised

      label $frm.frame2.lab103 -text "$caption(cemes,titre_site_web)"
      pack $frm.frame2.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame2 "$caption(cemes,site_web_ref)" \
         "$caption(cemes,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame2 -side bottom -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# ::cemes::configureCamera
#    Configure la camera Cemes en fonction des donnees contenues dans les variables conf(cemes,...)
#
proc ::cemes::configureCamera { camItem } {
   global caption conf confCam

   set camNo [ cam::create cemes PCI ]
   set confCam($camItem,product) [ cam$camNo product ]
   console::affiche_erreur "$caption(cemes,port) $caption(cemes,2points) [ cam$camNo port ]\n"
   console::affiche_saut "\n"
   set confCam($camItem,camNo) $camNo
   set foncobtu $conf(cemes,foncobtu)
   switch -exact -- $foncobtu {
      0 {
         cam$camNo shutter "opened"
      }
      1 {
         cam$camNo shutter "closed"
      }
      2 {
         cam$camNo shutter "synchro"
      }
   }
   if { $conf(cemes,cool) == "1" } {
      cam$camNo cooler on
      cam$camNo cooler check $conf(cemes,temp)
   } else {
      cam$camNo cooler off
   }
   #--- J'associe le buffer de la visu
   set bufNo [visu$confCam($camItem,visuNo) buf]
   cam$camNo buf $bufNo
   #--- Je configure l'oriention des miroirs par defaut
   cam$camNo mirrorh $conf(cemes,mirh)
   cam$camNo mirrorv $conf(cemes,mirv)
   #---
   ::confVisu::visuDynamix $confCam($camItem,visuNo) 65535 0
   #---
   if { [ info exists confCam(cemes,aftertemp) ] == "0" } {
      ::cemes::CemesDispTemp
   }
}

#
# ::cemes::CemesDispTemp
#    Affiche la temperature du CCD
#
proc ::cemes::CemesDispTemp { } {
   variable private
   global audace caption confCam

   catch {
      set frm $private(frm)
      set camItem $confCam(currentCamItem)
      if { [ info exists audace(base).confCam ] == "1" && [ catch { set temp_ccd [ cam$confCam($camItem,camNo) temperature ] } ] == "0" } {
         set temp_ccd [ format "%+5.2f" $temp_ccd ]
         $frm.frame1.frame3.frame4.frame7.temp_ccd configure \
            -text "$caption(cemes,temperature_CCD) $temp_ccd $caption(cemes,deg_c)"
         set confCam(cemes,aftertemp) [ after 5000 ::cemes::CemesDispTemp ]
      } else {
         catch { unset confCam(cemes,aftertemp) }
      }
   }
}

#
# ::cemes::getPluginProperty
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
proc ::cemes::getPluginProperty { camItem propertyName } {
   switch $propertyName {
      binningList     { return [ list 1x1 2x2 4x4 8x8 ] }
      binningListScan { return [ list "" ] }
      hasLongExposure { return 0 }
      hasScan         { return 0 }
      hasShutter      { return 1 }
      hasVideo        { return 0 }
      hasWindow       { return 1 }
      longExposure    { return 1 }
      multiCamera     { return 0 }
      shutterList     { return [ list $::caption(cemes,obtu_ouvert) $::caption(cemes,obtu_ferme) $::caption(cemes,obtu_synchro) ] }
   }
}

