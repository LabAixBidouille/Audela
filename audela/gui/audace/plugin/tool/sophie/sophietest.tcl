#
# Fichier : sophie.tcl
# Description : Outil de tests pour le developpement de Sophie pour le T193 de l'OHP
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: sophietest.tcl,v 1.4 2009-05-12 17:48:25 michelpujol Exp $
#

#------------------------------------------------------------
# testhp
#    teste l'envoi des coordonnees toutes les secondes
#------------------------------------------------------------
proc ::sophie::testhp { } {
   variable private

   set private(testhp) 0

   # je lance l'envoi permanent des coordonnees sur le port COM
   set private(writeHpHandle) [open COM7 "r+" ]
   fconfigure $private(writeHpHandle) -mode "19200,n,8,1" -buffering none -blocking 0

   # j'ouvre le port de reception des coordonnees
   set private(readHpHandle) [open COM8 "r+" ]
   fconfigure $private(readHpHandle) -mode "19200,n,8,1" -buffering none -blocking 0

   set private(testhp) 1
   after 1000 ::sophie::testWriteHp
   after 1500 ::sophie::testReadHp

}

#------------------------------------------------------------
# stophp
#    arrete l'envoi des coordonnees
#------------------------------------------------------------
proc ::sophie::stophp { } {
   variable private

   set private(testhp) 0

   if { $private(writeHpHandle) != "" } {
      close $private(writeHpHandle)
      set private(writeHpHandle) ""
   }

  if { $private(readHpHandle) != "" } {
      close $private(readHpHandle)
      set private(readHpHandle) ""
   }

}

#------------------------------------------------------------
# testWriteHp
#    envoie les coordonnees toutes les secondes
#------------------------------------------------------------
proc ::sophie::testWriteHp { } {
   variable private

   set data "02h 06m 47.87s / -13d 44' 28\" /   -1d"
   if { $private(testhp) == 1 } {
      puts  $private(writeHpHandle) $data
console::disp "testWriteHp data=$data\n"
     after 2000 ::sophie::testWriteHp
   } else {

     if { $private(writeHpHandle) != "" } {
         close $private(writeHpHandle)
         set private(writeHpHandle) ""
      }
   }
}

#------------------------------------------------------------
# testReadHp
#    lit les coordonnees toutes les 3 secondes
#------------------------------------------------------------
proc ::sophie::testReadHp { } {
   variable private

   if { $private(testhp) == 1 } {
      set data [read -nonewline $private(readHpHandle)]
      set data [split $data "\n" ]
      set messageNb [llength $data]
      console::disp "\ntestReadHp nb=$messageNb data=$data\n"
      set data [lindex $data end]
      if { $data != "" } {
         scan $data "#%2dh%2x%2x" r g b
         set  [ format "%02dh%02dm%02ds" $h $m $sec);
         console::disp "\ntestReadHp nb=$messageNb data=$data\n"
      }
      after 4000 ::sophie::testReadHp
   } else {
     if { $private(readHpHandle) != "" } {
         close $private(readHpHandle)
         set private(readHpHandle) ""
      }
   }
}

#------------------------------------------------------------
# tests de la fenetre de controle
#------------------------------------------------------------
proc ::sophie::ta1 { }  {
   ::sophie::control::setAcquisitionState { 1 }
}

proc ::sophie::ta2 { }  {
   ::sophie::control::setAcquisitionState { 0 }
}

proc ::sophie::tc1 { } {
   ### starDetection fiberDetection originX originY starX starY fwhmX fwhmY background maxFlow
   ::sophie::control::setCenterInformation 1 1 750 512 752 514 45 46 100 10000

}

proc ::sophie::tsim0 { }  {
   set ::conf(sophie,simulation) 0
   set ::conf(sophie,simulationGenericFileName) "C:/Documents and Settings/michel/Mes documents/astronomie/test/OHP/simulation/centrage_"
   ::console::disp "pas de simulation\n"
}

proc ::sophie::tsim1 { }  {
   set ::conf(sophie,simulation) 1
   set ::conf(sophie,simulationGenericFileName) "$::audace(rep_images)/test/OHP/simulation/centrage_"
   ::console::disp "simulation fichiers centrage_*\n"
}

proc ::sophie::tsim2 { }  {
   set ::conf(sophie,simulation) 1
   set ::conf(sophie,simulationGenericFileName) "$::audace(rep_images)/test/OHP/simulation/simuFWHM10px_fibre_"
   ::console::disp "simulation fichiers simuFWHM10px_fibre_*\n"
}


###### Fenetre de configuration de la simulation ######

#------------------------------------------------------------
# simul
#    Creation de la fenetre de configuration de la simulation
#------------------------------------------------------------
proc ::sophie::simul { } {
   variable private

   set private(frmsimul) $::audace(base).configSimul
   ::sophie::createDialogSimul
   tkwait visibility $private(frmsimul)
}

#------------------------------------------------------------
# ok
#    Fonction appellee lors de l'appui sur le bouton 'OK' pour
#    appliquer la configuration et fermer la fenetre
#------------------------------------------------------------
proc ::sophie::ok { } {
   variable private

   set ::conf(sophie,simulation)                $private(simulation)
   set ::conf(sophie,simulationGenericFileName) $private(simulationGenericFileName)
   ::sophie::fermer
}

#------------------------------------------------------------
# fermer
#    Fonction appellee lors de l'appui sur le bouton 'Fermer' pour
#    fermer la fenetre
#------------------------------------------------------------
proc ::sophie::fermer { } {
   variable private

   destroy $private(frmsimul)
}

#------------------------------------------------------------
# createDialogSimul
#    Creation de l'interface graphique
#------------------------------------------------------------
proc ::sophie::createDialogSimul { } {
   variable private

   set frm $private(frmsimul)

   if { [ winfo exists $frm ] } {
      wm withdraw $frm
      wm deiconify $frm
      focus $frm
      return
   }

   #--- Creation de la fenetre $frm de niveau le plus haut
   toplevel $frm -class Toplevel
   wm title $frm $::caption(sophie,simulation)
   set posxSimul [ lindex [ split [ wm geometry $::audace(base) ] "+" ] 1 ]
   set posySimul [ lindex [ split [ wm geometry $::audace(base) ] "+" ] 2 ]
   wm geometry $frm +[ expr $posxSimul + 134 ]+[ expr $posySimul + 60 ]
   wm resizable $frm 1 1
   wm protocol $frm WM_DELETE_WINDOW ::sophie::fermer

   #--- On utilise les valeurs contenues dans le tableau conf pour l'initialisation
   set private(simulation)                $::conf(sophie,simulation)
   set private(simulationGenericFileName) $::conf(sophie,simulationGenericFileName)

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 1 -relief raised
   pack $frm.frame1 -side top -fill both -expand 1

   frame $frm.frame2 -borderwidth 1 -relief raised
   pack $frm.frame2 -side top -fill x

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -in $frm.frame1 -side top -fill both -expand 1

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -in $frm.frame1 -side top -fill both -expand 1

   #--- Activation ou non de la simulation
   checkbutton $frm.simul -text $::caption(sophie,modeSimulation) -highlightthickness 0 \
      -variable ::sophie::private(simulation)
   pack $frm.simul -in $frm.frame3 -anchor center -side left -padx 5 -pady 5

   #--- Label
   label $frm.label -text $::caption(sophie,simulGenericFileName)
   pack $frm.label -in $frm.frame4 -anchor center -side left -padx 5 -pady 5

   #--- Entry pour le nom generique des images de simulation
   entry $frm.entry -textvariable ::sophie::private(simulationGenericFileName) -width 25 -justify left
   pack $frm.entry -in $frm.frame4 -anchor center -side left -padx 5 -pady 5

   #--- Bouton 'Parcourir'
   button $frm.butParcourir -text $::caption(sophie,parcourir) -borderwidth 2 \
      -command "::sophie::simulationGenericFileName"
   pack $frm.butParcourir -in $frm.frame4 -anchor center -side left -padx 5 -pady 5

   #--- Bouton 'OK'
   button $frm.butOk -text $::caption(sophie,ok) -borderwidth 2 \
      -command "::sophie::ok"
   pack $frm.butOk -in $frm.frame2 -anchor center -side left -padx 5 -pady 5 -ipadx 10 -ipady 5

   #--- Bouton 'Fermer'
   button $frm.butFermer -text $::caption(sophie,fermer) -borderwidth 2 \
      -command "::sophie::fermer"
   pack $frm.butFermer -in $frm.frame2 -anchor center -side right -padx 5 -pady 5 -ipadx 10 -ipady 5

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
# simulationGenericFileName
#    Ouvre le navigateur pour choisir les images de simulation
#------------------------------------------------------------
proc ::sophie::simulationGenericFileName { } {
   variable private

   #--- Ouvre la fenetre de choix des images
   set private(simulationGenericFileName) [ ::tkutil::box_load $::audace(base) $::audace(rep_images) $::audace(bufNo) "1" ]
   #--- Il faut un fichier
   if { $private(simulationGenericFileName)  == "" } {
      return
   }
}

###### Fin de la fenetre de configuration de la simulation ######
