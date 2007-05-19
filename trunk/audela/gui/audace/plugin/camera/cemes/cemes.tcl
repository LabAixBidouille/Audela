#
# Fichier : cemes.tcl
# Description : Configuration de la camera Cemes
# Auteurs : Robert DELMAS
# Mise a jour $Id: cemes.tcl,v 1.8 2007-05-19 08:39:03 robertdelmas Exp $
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

   #--- confToWidget
   ::cemes::confToWidget

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
   pack $frm.frame4 -in $frm.frame3 -side left -fill x -expand 0

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -in $frm.frame3 -anchor n -side left -fill x -padx 20

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -in $frm.frame4 -side top -fill x -padx 10

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -in $frm.frame4 -side top -fill x -padx 30

   frame $frm.frame8 -borderwidth 0 -relief raised
   pack $frm.frame8 -in $frm.frame1 -side top -fill x -expand 0

   #--- Definition du refroidissement
   checkbutton $frm.cool -text "$caption(cemes,refroidissement)" -highlightthickness 0 \
      -variable ::cemes::private(cool)
   pack $frm.cool -in $frm.frame6 -anchor center -side left -padx 0 -pady 5

   entry $frm.temp -textvariable ::cemes::private(temp) -width 4 -justify center
   pack $frm.temp -in $frm.frame6 -anchor center -side left -padx 5 -pady 5

   label $frm.tempdeg -text "$caption(cemes,deg_c) $caption(cemes,refroidissement_1)"
   pack $frm.tempdeg -in $frm.frame6 -side left -fill x -padx 0 -pady 5

   #--- Definition de la temperature du capteur CCD
   label $frm.temp_ccd -text "$caption(cemes,temperature_CCD)"
   pack $frm.temp_ccd -in $frm.frame7 -side left -fill x -padx 20 -pady 5

   #--- Miroir en x et en y
   checkbutton $frm.mirx -text "$caption(cemes,miroir_x)" -highlightthickness 0 \
      -variable ::cemes::private(mirh)
   pack $frm.mirx -in $frm.frame5 -anchor w -side top -padx 20 -pady 10

   checkbutton $frm.miry -text "$caption(cemes,miroir_y)" -highlightthickness 0 \
      -variable ::cemes::private(mirv)
   pack $frm.miry -in $frm.frame5 -anchor w -side top -padx 20 -pady 10

   #--- Fonctionnement de l'obturateur
   label $frm.lab3 -text "$caption(cemes,fonc_obtu)"
   pack $frm.lab3 -in $frm.frame8 -anchor nw -side left -padx 10 -pady 5

   set list_combobox [ list $caption(cemes,obtu_ouvert) $caption(cemes,obtu_ferme) $caption(cemes,obtu_synchro) ]
   ComboBox $frm.foncobtu \
      -width 11           \
      -height [ llength $list_combobox ] \
      -relief sunken      \
      -borderwidth 1      \
      -editable 0         \
      -textvariable ::cemes::private(foncobtu) \
      -values $list_combobox
   pack $frm.foncobtu -in $frm.frame8 -anchor nw -side left -padx 0 -pady 5

   #--- Site web officiel de la Cemes
   label $frm.lab103 -text "$caption(cemes,titre_site_web)"
   pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

   label $frm.labURL -text "$caption(cemes,site_web_ref)" -font $audace(font,url) -fg $color(blue)
   pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   #--- Creation du lien avec le navigateur web et changement de sa couleur
   bind $frm.labURL <ButtonPress-1> {
      set filename "$caption(cemes,site_web_ref)"
      ::audace::Lance_Site_htm $filename
   }
   bind $frm.labURL <Enter> {
      global frmm
      set frm $frmm(Camera13)
      $frm.labURL configure -fg $color(purple)
   }
   bind $frm.labURL <Leave> {
      global frmm
      set frm $frmm(Camera13)
      $frm.labURL configure -fg $color(blue)
   }
}

#
# ::cemes::configureCamera
#    Configure la camera Cemes en fonction des donnees contenues dans les variables conf(cemes,...)
#
proc ::cemes::configureCamera { camItem } {
   global caption conf confCam

   set camNo [ cam::create cemes PCI ]
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
   global audace caption confCam frmm

   catch {
      set frm $frmm(Camera13)
      set camItem $confCam(currentCamItem)
      if { [ info exists audace(base).confCam ] == "1" && [ catch { set temp_ccd [ cam$confCam($camItem,camNo) temperature ] } ] == "0" } {
         set temp_ccd [ format "%+5.2f" $temp_ccd ]
         $frm.temp_ccd configure \
            -text "$caption(cemes,temperature_CCD) $temp_ccd $caption(cemes,deg_c)"
         set confCam(cemes,aftertemp) [ after 5000 ::cemes::CemesDispTemp ]
      } else {
         catch { unset confCam(cemes,aftertemp) }
      }
   }
}

#
# ::cemes::getBinningList
#    Retourne la liste des binnings disponibles de la camera
#
proc ::cemes::getBinningList { } {
   set binningList { 1x1 2x2 4x4 8x8 }
   return $binningList
}

#
# ::cemes::getBinningListScan
#    Retourne la liste des binnings disponibles pour les scans de la camera
#
proc ::cemes::getBinningListScan { } {
   set binningListScan { }
   return $binningListScan
}

# ::cemes::hasCapability
#    Retourne "la valeur de la propriete"
#
#  Parametres :
#     camNo      : Numero de la camera
#     capability : Fonctionnalite de la camera
#
proc ::cemes::hasCapability { camNo capability } {
   switch $capability {
      window { return 1 }
   }
}

#
# ::cemes::hasLongExposure
#    Retourne le mode longue pose de la camera (1 : oui , 0 : non)
#
proc ::cemes::hasLongExposure { } {
   return 0
}

#
# ::cemes::getLongExposure
#    Retourne 1 si le mode longue pose est activé
#    Sinon retourne 0
#
proc ::cemes::getLongExposure { } {
   return 0
}

#
# ::cemes::hasVideo
#    Retourne le mode video de la camera (1 : oui , 0 : non)
#
proc ::cemes::hasVideo { } {
   return 0
}

#
# ::cemes::hasScan
#    Retourne le mode scan de la camera (1 : Oui , 0 : Non)
#
proc ::cemes::hasScan { } {
   return 0
}

#
# ::cemes::hasShutter
#    Retourne la presence d'un obturateur (1 : Oui , 0 : Non)
#
proc ::cemes::hasShutter { } {
   return 1
}

#
# ::cemes::getShutterOption
#    Retourne le mode de fonctionnement de l'obturateur (O : Ouvert , F : Ferme , S : Synchro)
#
proc ::cemes::getShutterOption { } {
   global caption

   set ShutterOptionList { [ list $caption(cemes,obtu_ouvert) $caption(cemes,obtu_ferme) $caption(cemes,obtu_synchro) ] }
   return $ShutterOptionList
}

