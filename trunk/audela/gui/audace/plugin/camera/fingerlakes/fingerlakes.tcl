#
# Fichier : fingerlakes.tcl
# Description : Configuration de la camera FLI (Finger Lakes Instrumentation)
# Auteurs : Robert DELMAS
# Mise a jour $Id: fingerlakes.tcl,v 1.1 2007-05-17 20:49:52 robertdelmas Exp $
#

namespace eval ::fingerlakes {
}

#
# ::fingerlakes::init
#    Initialise les variables conf(fingerlakes,...) et les captions
#
proc ::fingerlakes::init { } {
   global audace conf

   #--- Charge le fichier caption
   source [ file join $audace(rep_plugin) camera fingerlakes fingerlakes.cap ]

   #--- Initialise les variables de la camera FLI
   if { ! [ info exists conf(fingerlakes,cool) ] }     { set conf(fingerlakes,cool)     "0" }
   if { ! [ info exists conf(fingerlakes,foncobtu) ] } { set conf(fingerlakes,foncobtu) "2" }
   if { ! [ info exists conf(fingerlakes,mirh) ] }     { set conf(fingerlakes,mirh)     "0" }
   if { ! [ info exists conf(fingerlakes,mirv) ] }     { set conf(fingerlakes,mirv)     "0" }
   if { ! [ info exists conf(fingerlakes,temp) ] }     { set conf(fingerlakes,temp)     "-50" }
}

#
# ::fingerlakes::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::fingerlakes::confToWidget { } {
   variable private
   global caption conf

   #--- Recupere la configuration de la camera fingerlakes dans le tableau private(...)
   set private(cool)     $conf(fingerlakes,cool)
   set private(foncobtu) [ lindex "$caption(fingerlakes,obtu_ouvert) $caption(fingerlakes,obtu_ferme) $caption(fingerlakes,obtu_synchro)" $conf(fingerlakes,foncobtu) ]
   set private(mirh)     $conf(fingerlakes,mirh)
   set private(mirv)     $conf(fingerlakes,mirv)
   set private(temp)     $conf(fingerlakes,temp)
}

#
# ::fingerlakes::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::fingerlakes::widgetToConf { } {
   variable private
   global caption conf

   #--- Memorise la configuration de la camera FLI dans le tableau conf(fingerlakes,...)
   set conf(fingerlakes,cool)     $private(cool)
   set conf(fingerlakes,foncobtu) [ lsearch "$caption(fingerlakes,obtu_ouvert) $caption(fingerlakes,obtu_ferme) $caption(fingerlakes,obtu_synchro)" "$private(foncobtu)" ]
   set conf(fingerlakes,mirh)     $private(mirh)
   set conf(fingerlakes,mirv)     $private(mirv)
   set conf(fingerlakes,temp)     $private(temp)
}

#
# ::fingerlakes::fillConfigPage
#    Interface de configuration de la camera FLI
#
proc ::fingerlakes::fillConfigPage { frm } {
   variable private
   global audace caption color

   #--- confToWidget
   ::fingerlakes::confToWidget

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
   checkbutton $frm.cool -text "$caption(fingerlakes,refroidissement)" -highlightthickness 0 \
      -variable ::fingerlakes::private(cool)
   pack $frm.cool -in $frm.frame6 -anchor center -side left -padx 0 -pady 5

   entry $frm.temp -textvariable ::fingerlakes::private(temp) -width 4 -justify center
   pack $frm.temp -in $frm.frame6 -anchor center -side left -padx 5 -pady 5

   label $frm.tempdeg -text "$caption(fingerlakes,deg_c) $caption(fingerlakes,refroidissement_1)"
   pack $frm.tempdeg -in $frm.frame6 -side left -fill x -padx 0 -pady 5

   #--- Definition de la temperature du capteur CCD
   label $frm.temp_ccd -text "$caption(fingerlakes,temperature_CCD)"
   pack $frm.temp_ccd -in $frm.frame7 -side left -fill x -padx 20 -pady 5

   #--- Miroir en x et en y
   checkbutton $frm.mirx -text "$caption(fingerlakes,miroir_x)" -highlightthickness 0 \
      -variable ::fingerlakes::private(mirh)
   pack $frm.mirx -in $frm.frame5 -anchor w -side top -padx 20 -pady 10

   checkbutton $frm.miry -text "$caption(fingerlakes,miroir_y)" -highlightthickness 0 \
      -variable ::fingerlakes::private(mirv)
   pack $frm.miry -in $frm.frame5 -anchor w -side top -padx 20 -pady 10

   #--- Fonctionnement de l'obturateur
   label $frm.lab3 -text "$caption(fingerlakes,fonc_obtu)"
   pack $frm.lab3 -in $frm.frame8 -anchor nw -side left -padx 10 -pady 5

   set list_combobox [ list $caption(fingerlakes,obtu_ouvert) $caption(fingerlakes,obtu_ferme) \
      $caption(fingerlakes,obtu_synchro) ]
   ComboBox $frm.foncobtu \
      -width 11           \
      -height [ llength $list_combobox ] \
      -relief sunken      \
      -borderwidth 1      \
      -editable 0         \
      -textvariable ::fingerlakes::private(foncobtu) \
      -values $list_combobox
   pack $frm.foncobtu -in $frm.frame8 -anchor nw -side left -padx 0 -pady 5

   #--- Site web officiel de la FLI
   label $frm.lab103 -text "$caption(fingerlakes,titre_site_web)"
   pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

   label $frm.labURL -text "$caption(fingerlakes,site_web_ref)" -font $audace(font,url) -fg $color(blue)
   pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

   #--- Creation du lien avec le navigateur web et changement de sa couleur
   bind $frm.labURL <ButtonPress-1> {
      set filename "$caption(fingerlakes,site_web_ref)"
      ::audace::Lance_Site_htm $filename
   }
   bind $frm.labURL <Enter> {
      global frmm
      set frm $frmm(Camera12)
      $frm.labURL configure -fg $color(purple)
   }
   bind $frm.labURL <Leave> {
      global frmm
      set frm $frmm(Camera12)
      $frm.labURL configure -fg $color(blue)
   }
}

#
# ::fingerlakes::configureCamera
#    Configure la camera FLI en fonction des donnees contenues dans les variables conf(fingerlakes,...)
#
proc ::fingerlakes::configureCamera { camItem } {
   global caption conf confCam

   set camNo [ cam::create fingerlakes USB ]
   console::affiche_erreur "$caption(fingerlakes,port) ([ cam$camNo name ]) $caption(fingerlakes,2points) USB\n"
   console::affiche_saut "\n"
   set confCam($camItem,camNo) $camNo
   set foncobtu $conf(fingerlakes,foncobtu)
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
   if { $conf(fingerlakes,cool) == "1" } {
      cam$camNo cooler on
      cam$camNo cooler check $conf(fingerlakes,temp)
   } else {
      cam$camNo cooler off
   }
   #--- J'associe le buffer de la visu
   set bufNo [visu$confCam($camItem,visuNo) buf]
   cam$camNo buf $bufNo
   #--- Je configure l'oriention des miroirs par defaut
   cam$camNo mirrorh $conf(fingerlakes,mirh)
   cam$camNo mirrorv $conf(fingerlakes,mirv)
   #---
   ::confVisu::visuDynamix $confCam($camItem,visuNo) 65535 0
   #---
   if { [ info exists confCam(fingerlakes,aftertemp) ] == "0" } {
      ::fingerlakes::FLIDispTemp
   }
}

#
# ::fingerlakes::FLIDispTemp
#    Affiche la temperature du CCD
#
proc ::fingerlakes::FLIDispTemp { } {
   global audace caption confCam frmm

   catch {
      set frm $frmm(Camera12)
      set camItem $confCam(currentCamItem)
      if { [ info exists audace(base).confCam ] == "1" && [ catch { set temp_ccd [ cam$confCam($camItem,camNo) temperature ] } ] == "0" } {
         set temp_ccd [ format "%+5.2f" $temp_ccd ]
         $frm.temp_ccd configure \
            -text "$caption(fingerlakes,temperature_CCD) $temp_ccd $caption(fingerlakes,deg_c)"
         set confCam(fingerlakes,aftertemp) [ after 5000 ::fingerlakes::FLIDispTemp ]
      } else {
         catch { unset confCam(fingerlakes,aftertemp) }
      }
   }
}

#
# ::fingerlakes::getBinningList
#    Retourne la liste des binnings disponibles de la camera
#
proc ::fingerlakes::getBinningList { } {
   set binningList { 1x1 2x2 3x3 4x4 5x5 6x6 7x7 8x8 }
   return $binningList
}

#
# ::fingerlakes::getBinningListScan
#    Retourne la liste des binnings disponibles pour les scans de la camera
#
proc ::fingerlakes::getBinningListScan { } {
   set binningListScan { }
   return $binningListScan
}

# ::fingerlakes::hasCapability
#    Retourne "la valeur de la propriete"
#
#  Parametres :
#     camNo      : Numero de la camera
#     capability : Fonctionnalite de la camera
#
proc ::fingerlakes::hasCapability { camNo capability } {
   switch $capability {
      window { return 1 }
   }
}

#
# ::fingerlakes::hasLongExposure
#    Retourne le mode longue pose de la camera (1 : oui , 0 : non)
#
proc ::fingerlakes::hasLongExposure { } {
   return 0
}

#
# ::fingerlakes::getLongExposure
#    Retourne 1 si le mode longue pose est activé
#    Sinon retourne 0
#
proc ::fingerlakes::getLongExposure { } {
   return 0
}

#
# ::fingerlakes::hasVideo
#    Retourne le mode video de la camera (1 : oui , 0 : non)
#
proc ::fingerlakes::hasVideo { } {
   return 0
}

#
# ::fingerlakes::hasScan
#    Retourne le mode scan de la camera (1 : Oui , 0 : Non)
#
proc ::fingerlakes::hasScan { } {
   return 0
}

#
# ::fingerlakes::hasShutter
#    Retourne la presence d'un obturateur (1 : Oui , 0 : Non)
#
proc ::fingerlakes::hasShutter { } {
   return 1
}

#
# ::fingerlakes::getShutterOption
#    Retourne le mode de fonctionnement de l'obturateur (O : Ouvert , F : Ferme , S : Synchro)
#
proc ::fingerlakes::getShutterOption { } {
   global caption

   set ShutterOptionList { [ list $caption(fingerlakes,obtu_ouvert) $caption(fingerlakes,obtu_ferme) $caption(fingerlakes,obtu_synchro) ] }
   return $ShutterOptionList
}

