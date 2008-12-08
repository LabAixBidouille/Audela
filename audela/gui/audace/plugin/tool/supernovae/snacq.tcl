#
# Fichier : snacq.tcl
# Description : Outil d'acqusition d'images pour la recherche de supernovae
# Auteur : Alain KLOTZ
# Mise a jour $Id: snacq.tcl,v 1.13 2008-12-08 22:28:34 robertdelmas Exp $
#

# ===================================================================
# ===================================================================
# ===================================================================

#--- Initialisation des repertoires
set sn(inidir)        [ pwd ]
set snconf(repsnaude) [ file join $audace(rep_plugin) tool supernovae ]

#--- Chargement des scripts associes
source [ file join $snconf(repsnaude) snmacros.tcl ]
source [ file join $snconf(repsnaude) snmacros.cap ]

#--- Chargement de la configuration
catch { snconfacq_load }
snconfacq_verif

#--- Recuperation de la localisation de l'observateur
catch { set snconf(localite) "$audace(posobs,observateur,gps)" }

#--- Recuperation du repertoire dedie aux images
catch { set snconf(dossier) "$conf(rep_images)" }

#--- Recuperation du nom de l'observateur
catch { set snconf(fits,OBSERVER) "$conf(posobs,nom_observateur)" }

# ===================================================================
# ===================================================================
# ===================================================================

set extname          "[buf$audace(bufNo) extension]"
set snconf(darkfile) "d$snconf(exptime)b$snconf(binning)$extname"
set snconf(biasfile) "d0b$snconf(binning)$extname"

#--- Definition of global variables (arrays)
#--- Definition des variables globales (arrays)
global num        #--- Index for devices
global caption    #--- Texts of captions
global zone       #--- Window name of usefull screen parts
global info_image #--- Some infos on the current image
global audace
global sn
global snconf
global conf
global color

#--- Initialisation pour la sortie par appui sur Quitter
set sn(exit)      "0"
set sn(stop)      "0"
set sn(exit_visu) "0"

#--- Load the captions
source [ file join $snconf(repsnaude) snacq.cap ]

# ==========================================
# ===   Setting the graphic interface    ===
# === Met en place l'interface graphique ===
# ==========================================

#--- Create the toplevel window .snacq
#--- Cree la fenetre .snacq de niveau le plus haut

if { [winfo exists $audace(base).snacq] } {
   wm withdraw $audace(base).snacq
   wm deiconify $audace(base).snacq
   focus $audace(base).snacq.frame2.but_exit
   return
}

#---
if { [ info exists snconf(geometry) ] } {
   set deb [ expr 1 + [ string first + $snconf(geometry) ] ]
   set fin [ string length $snconf(geometry) ]
   set snconf(position) "+[ string range $snconf(geometry) $deb $fin ]"
}

#---
toplevel $audace(base).snacq -class Toplevel
wm geometry $audace(base).snacq 530x420$snconf(position)
wm resizable $audace(base).snacq 1 1
wm minsize $audace(base).snacq 530 420
wm maxsize $audace(base).snacq 600 600
wm title $audace(base).snacq $caption(snacq,main_title)
wm protocol $audace(base).snacq WM_DELETE_WINDOW { ::recup_position ; ::ExitSnAcq }

#--- Cree un frame pour l'etat des connexions
frame $audace(base).snacq.frame1 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame1 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Cree un label pour la camera
   if {[::cam::list]!=""} {
      set cap1 "$caption(snacq,typecam) [lindex [cam$audace(camNo) info] 1]"
      set fg $color(blue)
   } else {
      set cap1 $caption(snacq,nocam)
      set fg $color(red)
   }
   label $audace(base).snacq.frame1.labURL_cam \
      -font $audace(font,url) -text $cap1 \
      -borderwidth 0 -relief flat -fg $fg
   pack $audace(base).snacq.frame1.labURL_cam \
      -in $audace(base).snacq.frame1 -side left \
      -padx 8 -pady 3

   #--- Cree un label pour le telescope
   set snconf(telescope) $conf(telescope)
   if {[::tel::list]!=""} {
      set cap1 "$caption(snacq,typetel) [ tel$audace(telNo) name ]"
      set fg $color(blue)
   } else {
      set cap1 $caption(snacq,notel)
      set fg $color(red)
   }
   label $audace(base).snacq.frame1.labURL_tel \
      -font $audace(font,url) -text $cap1 \
      -borderwidth 0 -relief flat -fg $fg
   pack $audace(base).snacq.frame1.labURL_tel \
      -in $audace(base).snacq.frame1 -side left \
      -padx 8 -pady 3

#--- Cree un frame pour le dossier
frame $audace(base).snacq.frame9 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame9 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Cree un label pour le dossier
   label $audace(base).snacq.frame9.label_rep \
      -font $audace(font,arial_8_b) -text $caption(snacq,dossier) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame9.label_rep \
      -in $audace(base).snacq.frame9 -side left \
      -padx 3 -pady 3

   #--- Cree un label pour le chemin du dossier
   label $audace(base).snacq.frame9.labURL_chemin_rep \
      -font $audace(font,url) -text $snconf(dossier) \
      -borderwidth 0 -relief flat -fg $color(blue)
   pack $audace(base).snacq.frame9.labURL_chemin_rep \
      -in $audace(base).snacq.frame9 -side left \
      -padx 3 -pady 3

#--- Cree un frame pour la logalite et la hauteur du Soleil
frame $audace(base).snacq.frame10 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame10 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Cree un label pour la localite
   label $audace(base).snacq.frame10.label_localite \
      -font $audace(font,arial_8_b) -text $caption(snacq,localite) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame10.label_localite \
      -in $audace(base).snacq.frame10 -side left \
      -padx 3 -pady 3

   #--- Cree un label pour la position de la localite
   label $audace(base).snacq.frame10.labURL_position_localite \
      -font $audace(font,url) -text $snconf(localite) \
      -borderwidth 0 -relief flat -fg $color(blue)
   pack $audace(base).snacq.frame10.labURL_position_localite \
      -in $audace(base).snacq.frame10 -side left \
      -padx 3 -pady 3

   #--- Cree un label pour la hauteur du soleil
   label $audace(base).snacq.frame10.label_haurore \
      -font $audace(font,arial_8_b) -text $caption(snacq,haurore) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame10.label_haurore \
      -in $audace(base).snacq.frame10 -side left \
      -padx 3 -pady 3

   #--- Cree une ligne d'entree pour la hauteur du soleil
   entry $audace(base).snacq.frame10.entry_haurore \
      -font $audace(font,arial_8_b) -textvariable snconf(haurore) \
      -borderwidth 1 -relief groove -width 8
   pack $audace(base).snacq.frame10.entry_haurore \
      -in $audace(base).snacq.frame10 -side left \
      -padx 3 -pady 3

#--- Cree un frame pour y mettre des boutons
frame $audace(base).snacq.frame11 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame11 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame11.label_houest \
      -font $audace(font,arial_8_b) -text $caption(snacq,houest) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame11.label_houest \
      -in $audace(base).snacq.frame11 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame11.entry_houest \
      -font $audace(font,arial_8_b) -textvariable snconf(houest) \
      -borderwidth 1 -relief groove -width 8
   pack $audace(base).snacq.frame11.entry_houest \
      -in $audace(base).snacq.frame11 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame11.label_hest \
      -font $audace(font,arial_8_b) -text $caption(snacq,hest) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame11.label_hest \
      -in $audace(base).snacq.frame11 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame11.entry_hest \
      -font $audace(font,arial_8_b) -textvariable snconf(hest) \
      -borderwidth 1 -relief groove -width 8
   pack $audace(base).snacq.frame11.entry_hest \
      -in $audace(base).snacq.frame11 -side left \
      -padx 3 -pady 3

#--- Cree un frame
frame $audace(base).snacq.frame12 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame12 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame12.label_decinf \
      -font $audace(font,arial_8_b) -text $caption(snacq,decinf) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame12.label_decinf \
      -in $audace(base).snacq.frame12 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame12.entry_decinf \
      -font $audace(font,arial_8_b) -textvariable snconf(decinf) \
      -borderwidth 1 -relief groove -width 8
   pack $audace(base).snacq.frame12.entry_decinf \
      -in $audace(base).snacq.frame12 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame12.label_decsup \
      -font $audace(font,arial_8_b) -text $caption(snacq,decsup) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame12.label_decsup \
      -in $audace(base).snacq.frame12 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame12.entry_decsup \
      -font $audace(font,arial_8_b) -textvariable snconf(decsup) \
      -borderwidth 1 -relief groove -width 8
   pack $audace(base).snacq.frame12.entry_decsup \
      -in $audace(base).snacq.frame12 -side left \
      -padx 3 -pady 3

#--- Cree un frame
frame $audace(base).snacq.frame13 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame13 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame13.label_exptime \
      -font $audace(font,arial_8_b) -text "$caption(snacq,exptime)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame13.label_exptime \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame13.entry_exptime \
      -font $audace(font,arial_8_b) -textvariable snconf(exptime) \
      -borderwidth 1 -relief groove -width 4
   pack $audace(base).snacq.frame13.entry_exptime \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame13.label_nbimages \
      -font $audace(font,arial_8_b) -text "$caption(snacq,nbimages)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame13.label_nbimages \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame13.entry_nbimages \
      -font $audace(font,arial_8_b) -textvariable snconf(nbimages) \
      -borderwidth 1 -relief groove -width 2
   pack $audace(base).snacq.frame13.entry_nbimages \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame13.label_unsmearing \
      -font $audace(font,arial_8_b) -text $caption(snacq,unsmearing) \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame13.label_unsmearing \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame13.entry_unsmearing \
      -font $audace(font,arial_8_b) -textvariable snconf(unsmearing) \
      -borderwidth 1 -relief groove -width 8
   pack $audace(base).snacq.frame13.entry_unsmearing \
      -in $audace(base).snacq.frame13 -side left \
      -padx 3 -pady 3

#--- Cree un frame
frame $audace(base).snacq.frame14 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame14 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame14.label_fichier_sn \
      -font $audace(font,arial_8_b) -text "$caption(snacq,fichier_sn)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame14.label_fichier_sn \
      -in $audace(base).snacq.frame14 -side left \
      -padx 3 -pady 3

   #--- Recherche des catalogues de galaxies disponibles pour la recherche de supernovae
   set catasupernovae      ""
   set list_catasupernovae ""
   set list_fichier [ glob -nocomplain -dir [ file join $snconf(repsnaude) cata_supernovae ] *.txt ]
   for { set i 0 } { $i <= [ expr [ llength $list_fichier ] - 1 ] } { incr i } {
      set catasupernovae [ file tail [ lindex $list_fichier $i ] ]
      lappend list_catasupernovae "$catasupernovae"
   }

   #--- Create a combobox
   #--- Cree une combobox
   #--- Combobox catalogues de galaxies
   set list_combobox "$list_catasupernovae"
   ComboBox $audace(base).snacq.frame14.combobox_fichier_sn \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -font $audace(font,arial_8_b) \
      -relief sunken    \
      -borderwidth 1    \
      -editable 0       \
      -textvariable snconf(fichier_sn) \
      -values $list_combobox
   pack $audace(base).snacq.frame14.combobox_fichier_sn \
      -in $audace(base).snacq.frame14 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame14.label_magsup \
      -font $audace(font,arial_8_b) -text "$caption(snacq,magsup)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame14.label_magsup \
      -in $audace(base).snacq.frame14 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame14.entry_magsup \
      -font $audace(font,arial_8_b) -textvariable snconf(magsup) \
      -borderwidth 1 -relief groove -width 5
   pack $audace(base).snacq.frame14.entry_magsup \
      -in $audace(base).snacq.frame14 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame14.label_maginf \
      -font $audace(font,arial_8_b) -text "$caption(snacq,maginf)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame14.label_maginf \
      -in $audace(base).snacq.frame14 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame14.entry_maginf \
      -font $audace(font,arial_8_b) -textvariable snconf(maginf) \
      -borderwidth 1 -relief groove -width 5
   pack $audace(base).snacq.frame14.entry_maginf\
      -in $audace(base).snacq.frame14 -side left \
      -padx 3 -pady 3

#--- Cree un frame
frame $audace(base).snacq.frame15 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame15 \
   -in $audace(base).snacq -anchor s -side top -expand 0 -fill x

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame15.label_binning \
      -font $audace(font,arial_8_b) -text "$caption(snacq,binning)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame15.label_binning \
      -in $audace(base).snacq.frame15 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame15.entry_binning \
      -font $audace(font,arial_8_b) -textvariable snconf(binning) \
      -borderwidth 1 -relief groove -width 3
   pack $audace(base).snacq.frame15.entry_binning \
      -in $audace(base).snacq.frame15 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame15.label_foclen \
      -font $audace(font,arial_8_b) -text "$caption(snacq,foclen)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame15.label_foclen \
      -in $audace(base).snacq.frame15 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame15.entry_foclen \
      -font $audace(font,arial_8_b) -textvariable snconf(foclen) \
      -borderwidth 1 -relief groove -width 6
   pack $audace(base).snacq.frame15.entry_foclen \
      -in $audace(base).snacq.frame15 -side left \
      -padx 3 -pady 3

   #--- Create a label
   #--- Cree un label
   label $audace(base).snacq.frame15.label_observer \
      -font $audace(font,arial_8_b) -text "$caption(snacq,fits,OBSERVER)" \
      -borderwidth 0 -relief flat
   pack $audace(base).snacq.frame15.label_observer \
      -in $audace(base).snacq.frame15 -side left \
      -padx 3 -pady 3

   #--- Create an entry line
   #--- Cree une ligne d'entree
   entry $audace(base).snacq.frame15.entry_observer \
      -font $audace(font,arial_8_b) -textvariable snconf(fits,OBSERVER) \
      -borderwidth 1 -relief groove -width 25
   pack $audace(base).snacq.frame15.entry_observer \
      -in $audace(base).snacq.frame15 -side left \
      -padx 3 -pady 3

#--- Create a frame to put buttons in it
#--- Cree un frame pour y mettre des boutons
frame $audace(base).snacq.frame2 \
   -borderwidth 0 -cursor arrow
pack $audace(base).snacq.frame2 \
   -in $audace(base).snacq -anchor s -side bottom -expand 0 -fill x

#--- Create the button GO and ...
#--- Create the button GO and ...
button $audace(base).snacq.frame2.but_go2 \
   -text $caption(snacq,go2) -borderwidth 2 \
   -command { snacq_go 1 }
pack $audace(base).snacq.frame2.but_go2 \
   -in $audace(base).snacq.frame2 -side left  -anchor w \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
button $audace(base).snacq.frame2.but_go \
   -text $caption(snacq,go) -borderwidth 2 \
   -command { snacq_go 0 }
pack $audace(base).snacq.frame2.but_go \
   -in $audace(base).snacq.frame2 -side left -anchor e \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
button $audace(base).snacq.frame2.but_stop \
   -text $caption(snacq,stop) -borderwidth 2 \
   -command { $audace(base).snacq.frame2.but_stop configure -relief groove ; ::StopSnAcq }
pack $audace(base).snacq.frame2.but_stop \
   -in $audace(base).snacq.frame2 -side left -anchor e \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
button $audace(base).snacq.frame2.but_exit \
   -text $caption(snacq,exit) -borderwidth 2 \
   -command { ::recup_position ; $audace(base).snacq.frame2.but_exit configure -relief groove ; ::ExitSnAcq }
pack $audace(base).snacq.frame2.but_exit \
   -in $audace(base).snacq.frame2 -side left -anchor e \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

button $audace(base).snacq.frame2.but_help \
   -text $caption(snacq,help) -borderwidth 2 \
   -command { ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::supernovae::getPluginType ] ] \
      [ ::supernovae::getPluginDirectory ] [ ::supernovae::getPluginHelp ] sn_acq }
pack $audace(base).snacq.frame2.but_help \
   -in $audace(base).snacq.frame2 -side right -anchor e \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
button $audace(base).snacq.frame2.but_gobias \
   -text $caption(snacq,gobias) -borderwidth 2 \
   -command { makebias }
pack $audace(base).snacq.frame2.but_gobias \
   -in $audace(base).snacq.frame2 -side right -anchor e \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
button $audace(base).snacq.frame2.but_godark \
   -text $caption(snacq,godark) -borderwidth 2 \
   -command { makedark }
pack $audace(base).snacq.frame2.but_godark \
   -in $audace(base).snacq.frame2 -side right -anchor e \
   -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
#--- Create a vertical scrollbar for the status listbox
#--- Cree un acsenseur vertical pour la console de retour d'etats
frame $audace(base).snacq.frame3
scrollbar $audace(base).snacq.frame3.scr1 -orient vertical \
   -command {$audace(base).snacq.frame3.lst1 yview} -takefocus 1 -borderwidth 1
pack $audace(base).snacq.frame3.scr1 \
   -in $audace(base).snacq.frame3 -side right -fill y
set zone(status_scrl) $audace(base).snacq.frame3.scr1

#--- Create a console for status returned
#--- Cree la console de retour d'etats
text $audace(base).snacq.frame3.lst1 \
   -borderwidth 1 -relief sunken \
   -yscrollcommand {global audace ; $audace(base).snacq.frame3.scr1 set} -wrap word
pack $audace(base).snacq.frame3.lst1 \
   -in $audace(base).snacq.frame3 -expand yes -fill both \
   -padx 3 -pady 3
set zone(status_list) $audace(base).snacq.frame3.lst1
pack $audace(base).snacq.frame3 -expand yes -fill both

#--- La fenetre est active
focus $audace(base).snacq

#--- Mise a jour dynamique des couleurs
::confColor::applyColor $audace(base).snacq

$zone(status_list) insert end "$caption(snacq,status_1)\n"
$zone(status_list) insert end "$caption(snacq,status_2)\n\n\n"

# =================================
# ===    Setting the binding    ===
# === Met en place les liaisons ===
# =================================

bind $audace(base).snacq.frame9.labURL_chemin_rep <ButtonPress-1> {
   ::cwdWindow::run "$audace(base).cwdWindow"
   tkwait window $audace(base).cwdWindow
   set snconf(dossier) "$conf(rep_images)"
   set audace(rep_images) "$conf(rep_images)"
   catch { $audace(base).snacq.frame9.labURL_chemin_rep configure -text $snconf(dossier) }
   update
}

bind $audace(base).snacq.frame10.labURL_position_localite <ButtonPress-1> {
   ::confPosObs::run "$audace(base).confPosObs"
   tkwait window $audace(base).confPosObs
   set snconf(localite) $conf(posobs,observateur,gps)
   set audace(posobs,observateur,gps) $conf(posobs,observateur,gps)
   catch { $audace(base).snacq.frame10.labURL_position_localite configure -text $snconf(localite) }
   update
}

bind $audace(base).snacq.frame1.labURL_tel <ButtonPress-1> {
   ::confTel::run
   tkwait window $audace(base).confTel
   set snconf(telescope) $conf(telescope)
   if {[::tel::list]!=""} {
      set cap1 "$caption(snacq,typetel) [ tel$audace(telNo) name ]"
      set fg $color(blue)
   } else {
      set cap1 $caption(snacq,notel)
      set fg $color(red)
   }
   catch { $audace(base).snacq.frame1.labURL_tel configure -text $cap1 -fg $fg }
   update
}

bind $audace(base).snacq.frame1.labURL_cam <ButtonPress-1> {
   ::confCam::run
   tkwait window $audace(base).confCam
   if {[::cam::list]!=""} {
      set cap1 "$caption(snacq,typecam) [lindex [cam$audace(camNo) info] 1]"
      set fg $color(blue)
   } else {
      set cap1 $caption(snacq,nocam)
      set fg $color(red)
   }
   catch { $audace(base).snacq.frame1.labURL_cam configure -text $cap1 -fg $fg }
   update
}

# ============================== FIN DU PROGRAMME PRINCIPAL ===============================


# =========================================================================================
proc snacq_go { {sndebug 0} } {

   global audace
   global zone
   global caption
   global snconf
   global sn
   global conf

   set testjour      "0"
   set sn(stop)      "0"
   set sn(exit_visu) "1"

   # ================================================
   # === Mise a jour des donnees de configuration ===
   # ================================================
   ::UpdateSnAcq

   # =====================================================
   # === Verifie que tous les composants sont presents ===
   # =====================================================
   if {$sndebug==0} {
      set snlog sn.log
      set sn2log sn2.log
      if {[::cam::list]==""} {
         bell
         sninfo "$caption(snacq,nocam)\n"
         set sn(exit_visu) "0"
         return
      }
      if {[::tel::list]==""} {
         bell
         sninfo "$caption(snacq,notel)\n"
         set sn(exit_visu) "0"
         return
      }
      set f ""
      catch { set f [ glob [ file join $snconf(dossier) $snconf(darkfile) ] ] } {
         set f ""
      }
      if {$f==""} {
         bell
         sninfo "$caption(snacq,status_nodark)\n"
         set sn(exit_visu) "0"
         return
      }
      set f ""
      catch { set f [ glob [ file join $snconf(dossier) $snconf(biasfile) ] ] } {
         set f ""
      }
      if {$f==""} {
         bell
         sninfo "$caption(snacq,status_nobias)\n"
         set sn(exit_visu) "0"
         return
      }
   } else {
      set snlog snsimu.log
      set sn2log snsimu2.log
   }

   set dossier_alerte [ file join $snconf(repsnaude) alert ]

   # ================================
   # === Charge des macros utiles ===
   # ================================
   sninfo "$caption(snacq,status_importemacros)..."
   source [ file join $snconf(repsnaude) snmacros.tcl ]

   # ============================================
   # === Initialisation de l'heure (TU ou HL) ===
   # ============================================
   set now now
   catch {
      set now [::audace::date_sys2ut now]
   }

   # ===================================================================
   # === Calcule les heures de la prochaine nuit et du prochain jour ===
   # ===================================================================
   sninfo "$caption(snacq,status_hdebfin)"
   set jj_debutnuit [sunset  $snconf(haurore) $snconf(localite)]
   set jj_debutjour [sunrise $snconf(haurore) $snconf(localite)]
   sninfo " $caption(snacq,status_debnuit) : [mc_date2ymdhms $jj_debutnuit]"
   sninfo " $caption(snacq,status_finnuit) : [mc_date2ymdhms $jj_debutjour]"

   # ===============================================
   # === Si il fait jour alors on attend la nuit ===
   # ===============================================
   if {$sndebug==0} {
      if {$jj_debutnuit<$jj_debutjour} {
         sninfo "$caption(snacq,status_ilfaitjour)\n"
         if {$testjour==0} {
            while {[mc_date2jd $now]<=$jj_debutnuit} {
               #--- Cas d'une action sur le bouton Quitter
               set sn(exit_visu) "0"
               if { $sn(exit) == "1" } {
                  destroy $audace(base).snacq
                  if [winfo exists $audace(base).outSnAcq] {
                     destroy $audace(base).outSnAcq
                  }
               }
               #--- Cas d'une action sur le bouton Stop
               set sn(exit_visu) "0"
               if { $sn(stop) == "1" } {
                  if [winfo exists $audace(base).out_SnAcq] {
                     destroy $audace(base).out_SnAcq
                     $audace(base).snacq.frame2.but_stop configure -relief raised
                  }
               }
               #--- Bouclage sur l'heure TU du systeme
               set now now
               catch {
                  set now [::audace::date_sys2ut now]
               }
               update
            }
         }
      }
   }

   if {$jj_debutnuit>$jj_debutjour} {
      set jj_debutnuit [expr ${jj_debutnuit}-1]
   }
   set jj_finnuit $jj_debutjour
   sninfo " $caption(snacq,status_obsjusqua) : [mc_date2ymdhms $jj_finnuit]"

   # =================================================================
   # === Charge la liste des objets et supprime ceux inobservables ===
   # =================================================================
   # === Chaque ligne du fichier des objets est au format suivant :
   # === nom hh mm ss dd ''
   # =================================================================
   sninfo "$caption(snacq,status_loaddb)..."
   set objlist [readobjs [ file join $snconf(repsnaude) cata_supernovae $snconf(fichier_sn) ] ]
   sninfo " [llength $objlist] $caption(snacq,status_galadb)"
   sninfo "$caption(snacq,status_seledb)..."
   set objlist [selectobjs $objlist $snconf(decinf) $snconf(decsup) $snconf(localite) $snconf(maginf) $snconf(magsup)]
   sninfo " [llength $objlist] $caption(snacq,status_galobs)"
   sninfo ""
   set contents $objlist

   set DR [expr acos(-1)/180.]

   catch {unset name0} {}

   # =======================================================
   # === Initialise les liste d'acquisitions deja faites ===
   # =======================================================
   set dejafaits {}
   set dejafaits2 ""
   if {$sndebug==0} {
      catch {
         set input [ open [ file join $snconf(dossier) sn.log ] r]
         set dejafaits [ read $input ]
         close $input
      }
      catch {
         set input [ open [ file join $snconf(dossier) sn2.log ] r]
         set dejafaits2 [ read $input ]
         close $input
         set dejafaits2 [ string range $dejafaits2 0 [ expr [ string length $dejafaits2 ]-2 ]  ]
      }
   }

   # ===============================
   # === Boucle des acquisitions ===
   # ===============================

   set kdeb -1
   set nbgal 0
   set nbgal2 0
   set listfileeventdone ""
   set now now
   catch {
      set now [::audace::date_sys2ut now]
   }
   if {$sndebug==1} {
      if {[mc_date2jd $now]<$jj_debutnuit} {
         set nownow $jj_debutnuit
      } else {
         set nownow [mc_date2jd $now]
      }
      set nownow0 $nownow
   } else {
      set nownow $now
   }

   #--- duree = temps deplacement telescope (environ 10 s) + temps acquisition image en fonction du binning
   set duree [ expr ( 10. + ( 3. +$snconf(exptime) + 10. * 2. / $snconf(binning) ) ) ]

   set indice_image 0

   while {[mc_date2jd $nownow]<=$jj_finnuit} {

      #--- Sortie de la boucle si appui sur le bouton Quitter
      if { $sn(exit) == "1" } {
         break
      }

      #--- Sortie de la boucle si appui sur le bouton Stop
      if { $sn(stop) == "1" } {
         break
      }

      #--- nownow
      if {$sndebug==1} {
         set nownow [ expr ${nownow0} + $duree / 86400. * $nbgal2 ]
     } else {
         set now now
         catch {
            set now [::audace::date_sys2ut now]
         }
         set nownow [mc_date2jd $now]
      }

      #--- Y-a-il un evenement a observer ?
      set listfileevent ""
      catch { set listfileevent [glob ${dossier_alerte}*.tcl] } {
         set listfileevent ""
      }
      foreach fileevent $listfileevent {
         catch {source $fileevent} {
            sninfo "$caption(snacq,status_alerterror) $fileevent !!!"
         }
      }

      #--- Calcule le temps sideral local
      set ligne [mc_date2lst $nownow $snconf(localite)]
      set tsl [mc_angle2deg [lindex $ligne 0]h[lindex $ligne 1]m[lindex $ligne 2]s]

      #--- Calcule la valeur de kdeb
      if {$kdeb==-1} {
         set kfin [expr [llength $contents]-2]
         for {set k 0} {$k < $kfin} {incr k} {
            set ligne [lindex $contents $k]
            set ra0 [mc_angle2deg [lindex $ligne 1]h[lindex $ligne 2]m[lindex $ligne 3]s]
            set kk [expr $k+1]
            set ligne [lindex $contents $kk]
            set ra1 [mc_angle2deg [lindex $ligne 1]h[lindex $ligne 2]m[lindex $ligne 3]s]
            set h0 [expr $tsl-$ra0-$snconf(houest)]
            set h1 [expr $tsl-$ra1-$snconf(houest)]
            set h [expr $h0*$h1]
            if {$h<0} {
               break;
            }
         }
         set kdeb $k
      }

      #--- Selectionne l'objet a observer
      if {($indice_image<$snconf(nbimages))&&($indice_image!=0)} {
         set ligne $lignedavant
         incr indice_image
      } else {
         set fin [expr [llength $contents]-1]
         set kfin [expr 2*[llength $contents]-1]
         set ongarde 0
         for {set k $kdeb} {$k < $kfin} {incr k} {
            #--- Calcule l'indice kk
            if {$k>$fin} {
               set kk [expr $k-$fin-1]
            } else {
               set kk $k
            }
            #--- ra est le RA de la galaxie
            set ligne [lindex $contents $kk]
            set ra [mc_angle2deg [lindex $ligne 1]h[lindex $ligne 2]m[lindex $ligne 3]s]
            set dec [mc_angle2deg [lindex $ligne 4]d[lindex $ligne 5]m[lindex $ligne 6]s 90]
            #--- h est l'angle horaire de la galaxie
            set h [expr $tsl-$ra]
            if {$h<0} {
               set h [expr $h+360.]
            }
            #--- Critere pour garder l'objet
            set ongarde 0
            if {$h<$snconf(houest)} {
               set ongarde 1
            }
            if {$h>$snconf(hest)} {
               set ongarde 1
            }
            if {$h<$snconf(hest)} {
               if {$h>180} {
                  set ongarde 0
                  break
               }
            }
            set name [lindex $ligne 0]
            if {[string first $name $dejafaits2]!=-1} {
               set ongarde 0
            }
            #--- On garde l'objet
            if {$ongarde==1} {
               set indice_image 1
               set kdeb $k
               incr kdeb
               lappend dejafaits $ligne
               set lignedavant $ligne
               set dudul [format "jj= %f tsl= %.2f ra= %.2f h= %.2f dec= %.2f %s" $nownow $tsl $ra $h $dec $ligne]
               append dejafaits2 "$dudul \n"
               break
            }
         }
         #--- Fin de la boucle for
      }

      if {$ongarde==1} {
         set ra "[lindex $ligne 1]h[lindex $ligne 2]m[lindex $ligne 3]s"
         set dec "[lindex $ligne 4]d[lindex $ligne 5]m[lindex $ligne 6]s"

         set result "[ mc_date2ymdhms $nownow ]\n[ list $ligne $ra $dec ]"
         sninfo "$result"

         if {$sndebug==0} {
            #--- Pointe le telescope
            if {$indice_image==1} {
                ::telescope::goto [ list $ra $dec ] "1"
            }

            #--- Delai d'attente a la demande de Robin
            after 1000

            #--- Lit la position du telescope
            set result "$caption(snacq,status_telpointe) [ ::telescope::afficheCoord ]"
            sninfo ""
            sninfo "$result"
            sninfo ""

            #--- Si une raquette existe, rafraichissement de l'affichage des coordonnees
            ::telescope::afficheCoord

            #--- Acquisition
            set camera "cam$audace(camNo)"
            set buffer buf[cam$audace(camNo) buf]

            #--- Initialisation du fenetrage
            catch {
               set n1n2 [$camera nbcells]
               $camera window [list 1 1 [lindex $n1n2 0] [lindex $n1n2 1] ]
            }

            #--- La commande exptime permet de fixer le temps de pose de l'image
            $camera exptime $snconf(exptime)

            #--- La commande bin permet de fixer le binning
            $camera bin [list $snconf(binning) $snconf(binning)]

            #--- Cas des poses de 0 s : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
            if { $snconf(exptime) == "0" } {
               ::camera::Avancement_pose "1"
            }

            #--- Declenchement de l'acquisition
            $camera acq

            #--- Alarme sonore de fin de pose
            ::camera::alarme_sonore $snconf(exptime)

            #--- Pretraitement pendant l'integration
            if { [info exist name0] == 1 } {
               set extname "[buf$audace(bufNo) extension]"
               ttscript2 "IMA/SERIES \"$snconf(dossier)\" \"$name0\" . . \"$extname\" \"$snconf(dossier)\" \"$name0\" . \"$extname\" OPT \"dark=$snconf(dossier)/$snconf(darkfile)\" \"bias=$snconf(dossier)/$snconf(biasfile)\" unsmearing=$snconf(unsmearing)"
               ttscript2 "IMA/SERIES \"$snconf(dossier)\" \"$name0\" . . \"$extname\" \"$snconf(dossier)\" \"$name0\" . \"$extname\" FILTER kernel_type=med kernel_width=3 kernel_coef=1.2"
               ttscript2 "IMA/SERIES \"$snconf(dossier)\" \"$name0\" . . \"$extname\" \"$snconf(dossier)\" \"$name0\" . \"$extname\" STAT fwhm"
            }

            #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
            ::camera::gestionPose $snconf(exptime) 1 $camera $buffer

            #--- Visualisation de l'image acquise
            ::audace::autovisu $audace(visuNo)

            #--- Modification du nom des images a la demande de Robin
            if { $snconf(nbimages) != "1" } {
               set name "[lindex $ligne 0]-$indice_image"
            } else {
               set name "[lindex $ligne 0]"
            }

            #--- On ajoute des mots cle a l'image
            set rad [mc_angle2deg [lindex $ligne 1]h[lindex $ligne 2]m[lindex $ligne 3]s ]
            set decd [mc_angle2deg [lindex $ligne 4]d[lindex $ligne 5]m[lindex $ligne 6]s 90 ]
            #---
            $buffer setkwd [list RA $rad float "right ascension" deg]
            $buffer setkwd [list DEC $decd float "declination" deg]
            $buffer setkwd [list FOCLEN $snconf(foclen) float "focal length" m]
            $buffer setkwd [list PIXSIZE1 9 float "pixel size" um]
            $buffer setkwd [list PIXSIZE2 9 float "pixel size" um]
            #--- Mot cles pour compatibilité Prism
            snprism

            #--- Sauvegarde de l'image
            $buffer save [ file join $snconf(dossier) ${name} ]
            set name0 $name

         }
         #--- Fin du debug

         incr nbgal
         sninfo " "

         catch {
            set fileId [ open [ file join $snconf(dossier) ${snlog} ] w ]
            puts $fileId $dejafaits
            close $fileId
         }

         catch {
            set fileId [ open [ file join $snconf(dossier) ${sn2log} ] w ]
            puts $fileId $dejafaits2
            close $fileId
         }

      }
      #--- Fin de la condition 'on garde' (donc on observe)

      if {$sndebug==1} {
         incr nbgal2
         if {$nbgal2>=700} {break;}
         if {$nownow>=$jj_debutjour} { break; }
      }

   }
   #-- Fin du while

   if {$sndebug==0} {
      if { [info exist name0] == 1 } {
         #--- Pretraitement de la derniere pose
         set extname "[buf$audace(bufNo) extension]"
         ttscript2 "IMA/SERIES \"$snconf(dossier)\" \"$name0\" . . \"$extname\" \"$snconf(dossier)\" \"$name0\" . \"$extname\" OPT \"dark=$snconf(dossier)/$snconf(darkfile)\" \"bias=$snconf(dossier)/$snconf(biasfile)\" unsmearing=$snconf(unsmearing)"
         ttscript2 "IMA/SERIES \"$snconf(dossier)\" \"$name0\" . . \"$extname\" \"$snconf(dossier)\" \"$name0\" . \"$extname\" FILTER kernel_type=med kernel_width=3 kernel_coef=1.2"
         ttscript2 "IMA/SERIES \"$snconf(dossier)\" \"$name0\" . . \"$extname\" \"$snconf(dossier)\" \"$name0\" . \"$extname\" STAT fwhm"
      }
   }

   set nbgal0 [expr int(ceil(($nbgal)/$snconf(nbimages)))]
   set result "$caption(snacq,status_nightend) $nbgal0 galaxies"
   sninfo "$result\n"

   set sn(exit_visu) "0"
   if { $sn(exit) == "1" } {
      destroy $audace(base).snacq
      if [winfo exists $audace(base).outSnAcq] {
         destroy $audace(base).outSnAcq
      }
   }
   if { $sn(stop) == "1" } {
      if [winfo exists $audace(base).out_SnAcq] {
         destroy $audace(base).out_SnAcq
         $audace(base).snacq.frame2.but_stop configure -relief raised
      }
   }
}

# ===========================================================================================
# recup_position
# Permet de recuperer et de sauvegarder la position de la fenetre SnAcq
#
proc recup_position { } {
   global audace
   global conf
   global snconf

   set snconf(geometry) [ wm geometry $audace(base).snacq ]
   set deb [ expr 1 + [ string first + $snconf(geometry) ] ]
   set fin [ string length $snconf(geometry) ]
   set snconf(position) "+[ string range $snconf(geometry) $deb $fin ]"
}

# ===========================================================================================
# OutSnAcq
# Affichage d'un message d'alerte lors de la fermeture de la fenetre SnAcq ou de l'appui sur
# le bouton Quitter
#
proc OutSnAcq { } {
   global audace
   global caption
   global color

   #---
   if [winfo exists $audace(base).outSnAcq] {
      destroy $audace(base).outSnAcq
   }
   toplevel $audace(base).outSnAcq
   wm resizable $audace(base).outSnAcq 0 0
   wm title $audace(base).outSnAcq "$caption(snacq,attention)"
   set posx_outSnAcq [ lindex [ split [ wm geometry $audace(base).snacq ] "+" ] 1 ]
   set posy_outSnAcq [ lindex [ split [ wm geometry $audace(base).snacq ] "+" ] 2 ]
   wm geometry $audace(base).outSnAcq +[ expr $posx_outSnAcq + 200 ]+[ expr $posy_outSnAcq + 270 ]
   wm transient $audace(base).outSnAcq $audace(base).snacq

   #--- Cree l'affichage du message
   label $audace(base).outSnAcq.labURL1 -text "$caption(snacq,texte1)" -font $audace(font,arial_10_b) -fg $color(red)
   pack $audace(base).outSnAcq.labURL1 -padx 10 -pady 2
   label $audace(base).outSnAcq.labURL2 -text "$caption(snacq,texte2)" -font $audace(font,arial_10_b) -fg $color(red)
   pack $audace(base).outSnAcq.labURL2 -padx 10 -pady 2

   #--- La nouvelle fenetre est active
   focus $audace(base).outSnAcq

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).outSnAcq
}

# ===========================================================================================
# Out_SnAcq
# Affichage d'un message d'alerte lors de l'appui sur le bouton Stop
#
proc Out_SnAcq { } {
   global audace
   global caption
   global color

   #---
   if [winfo exists $audace(base).out_SnAcq] {
      destroy $audace(base).out_SnAcq
   }
   toplevel $audace(base).out_SnAcq
   wm resizable $audace(base).out_SnAcq 0 0
   wm title $audace(base).out_SnAcq "$caption(snacq,attention)"
   set posx_out_SnAcq [ lindex [ split [ wm geometry $audace(base).snacq ] "+" ] 1 ]
   set posy_out_SnAcq [ lindex [ split [ wm geometry $audace(base).snacq ] "+" ] 2 ]
   wm geometry $audace(base).out_SnAcq +[ expr $posx_out_SnAcq + 200 ]+[ expr $posy_out_SnAcq + 270 ]
   wm transient $audace(base).out_SnAcq $audace(base).snacq

   #--- Cree l'affichage du message
   label $audace(base).out_SnAcq.labURL1 -text "$caption(snacq,texte3)" -font $audace(font,arial_10_b) -fg $color(red)
   pack $audace(base).out_SnAcq.labURL1 -padx 10 -pady 2
   label $audace(base).out_SnAcq.labURL2 -text "$caption(snacq,texte4)" -font $audace(font,arial_10_b) -fg $color(red)
   pack $audace(base).out_SnAcq.labURL2 -padx 10 -pady 2

   #--- La nouvelle fenetre est active
   focus $audace(base).out_SnAcq

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).out_SnAcq
}

# ===========================================================================================
# ExitSnAcq
# Fermer la fenetre SnAcq
#
proc ExitSnAcq { } {
   global audace
   global sn

   if { $sn(exit_visu) == "0" } {
      update ; snconfacq_save ; cd $sn(inidir) ; destroy $audace(base).snacq
   } else {
      set sn(exit) "1"
      ::OutSnAcq
      update ; snconfacq_save ; cd $sn(inidir)
   }
}

# ===========================================================================================
# StopSnAcq
# Fermer la fenetre SnAcq
#
proc StopSnAcq { } {
   global audace
   global sn

   if { $sn(exit_visu) == "0" } {
      $audace(base).snacq.frame2.but_stop configure -relief raised
   } else {
      set sn(stop) "1"
      ::Out_SnAcq
   }
}

# ===========================================================================================
# UpdateSnAcq
# Mise a jour des variables snconf
#
proc UpdateSnAcq { } {
   global snconf
   global audace

   #--- Sauvegarde des parametres
   snconfacq_save
   #--- Chargement de la configuration
   catch { snconfacq_load }
   snconfacq_verif
   #--- Rafraichissement des variables et des entry
   set extname "[buf$audace(bufNo) extension]"
   set snconf(darkfile) "d$snconf(exptime)b$snconf(binning)$extname"
   set snconf(biasfile) "d0b$snconf(binning)$extname"
   $audace(base).snacq.frame10.entry_haurore configure -textvariable snconf(haurore)
   $audace(base).snacq.frame11.entry_houest configure -textvariable snconf(houest)
   $audace(base).snacq.frame11.entry_hest configure -textvariable snconf(hest)
   $audace(base).snacq.frame12.entry_decinf configure -textvariable snconf(decinf)
   $audace(base).snacq.frame12.entry_decsup configure -textvariable snconf(decsup)
   $audace(base).snacq.frame13.entry_exptime configure -textvariable snconf(exptime)
   $audace(base).snacq.frame13.entry_nbimages configure -textvariable snconf(nbimages)
   $audace(base).snacq.frame13.entry_unsmearing configure -textvariable snconf(unsmearing)
   $audace(base).snacq.frame14.combobox_fichier_sn configure -textvariable snconf(fichier_sn)
   $audace(base).snacq.frame14.entry_magsup configure -textvariable snconf(magsup)
   $audace(base).snacq.frame14.entry_maginf configure -textvariable snconf(maginf)
   $audace(base).snacq.frame15.entry_binning configure -textvariable snconf(binning)
   $audace(base).snacq.frame15.entry_foclen configure -textvariable snconf(foclen)
   $audace(base).snacq.frame15.entry_observer configure -textvariable snconf(observer)
   update
}

