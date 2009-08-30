##------------------------------------------------------------
# @file     sophietest.tcl
# @brief    Fichier du namespace ::sophie::test
# @author   Michel PUJOL et Robert DELMAS
# @version  $Id: sophietest.tcl,v 1.11 2009-08-30 22:00:38 michelpujol Exp $
#------------------------------------------------------------

##-----------------------------------------------------------
# @brief    Procédures de test de l'outil sophie et simulation des interfaces externes
#
#------------------------------------------------------------
namespace eval ::sophie::test {

}


      #--- je mesure la position de l'etoile et le trou de la fibre
      # buf$bufNo fibercentro
      # Parameters IN:
      # @param     Argv[2]= [list x1 y1 x2 y2 ] fenetre de detection
      # @param     Argv[3]=biasBufNo       numero du buffer du bias
      # @param     Argv[4]=maskBufNo       numero du buffer du masque
      # @param     Argv[5]=sumBufNo        numero du buffer de l'image integree
      # @param     Argv[6]=fiberBufNo      numero du buffer de l'image resultat
      # @param     Argv[7]=maskRadius      rayon du masque
      # @param     Argv[8]=originSumNb     nombre d'acquisition de l'image integree
      # @param     Argv[9]=originSumCounter compteur d'integration de l'image de l'origine
      # @param     Argv[10]=previousFiberX abcisse du centre de la fibre
      # @param     Argv[11]=previousFiberY ordonnee du centre de la fibre
      # @param     Argv[12]=maskFwhm       largeur a mi hauteur de la gaussienne
      # @param     Argv[13]=findFiber      1=recherche de l'entrée de fibre , 0= ne pas rechercher
      # @param     Argv[14]=pixelMinCount  nombre minimal de pixels pour accepter l'image
      # @param     Argv[15]=maskPercent    pourcentage du niveau du mask
      #
      # @return si TCL_OK
      #            list[0] starStatus      resultat de la recherche de la fibre (DETECTED NO_SIGNAL)
      #            list[1] starX           abcisse du centre de la fibre   (pixel binné)
      #            list[2] starY           ordonnee du centre de la fibre  (pixel binné
      #            list[3] fiberStatus     resultat de la recherche de la fibre (DETECTED NO_SIGNAL)
      #            list[4] fiberX          abcisse du centre de la fibre  (pixel binné)
      #            list[5] fiberY          ordonnee du centre de la fibre (pixel binné)
      #            list[6] measuredFwhmX   gaussienne mesuree (pixel binné)
      #            list[7] measuredFwhmY   gaussienne mesuree (pixel binné)
      #            list[8] background      fond du ciel (ADU)
      #            list[9] maxIntensity    intensite max (ADU)
      #            list[10] message        message d'information
      #
      #         si TCL_ERREUR
      #            message d'erreur



#------------------------------------------------------------
# simulHp
#    teste l'envoi des coordonnees toutes les secondes
#------------------------------------------------------------
proc ::sophie::test::simulHp { } {
   variable private

   set private(testhp) 0

   set private(dataNo) 0
   set private(data,0) "02h 06m 47.87s / -13d 44' 28\" / -1d "
   set private(data,1) "02h 07m 47.87s / -00d 44' 28\" / -1d "
   set private(data,2) "02h 08m 47.87s / +10d 44' 28\" / -1d "
   set private(data,2) "02h 08m 47.87s /-310d 44' 28\" / -1d "

   # je lance l'envoi permanent des coordonnees sur le port COM
   set private(writeHpHandle) [open COM7 "r+" ]
   fconfigure $private(writeHpHandle) -mode "19200,n,8,1" -buffering none -blocking 0
console::disp "simulHp writeHpHandle=$private(writeHpHandle)\n"
   # j'ouvre le port de reception des coordonnees
   ###set private(readHpHandle) [open COM8 "r+" ]
   ###fconfigure $private(readHpHandle) -mode "19200,n,8,1" -buffering none -blocking 0

   set private(testhp) 1
   after 1000 ::sophie::test::testWriteHp
   ###after 1500 ::sophie::test::testReadHp

}

#------------------------------------------------------------
# stophp
#    arrete l'envoi des coordonnees
#------------------------------------------------------------
proc ::sophie::test::stopHp { } {
   variable private

   set private(testhp) 0

   if { $private(writeHpHandle) != "" } {
      close $private(writeHpHandle)
      set private(writeHpHandle) ""
   }

  #if { $private(readHpHandle) != "" } {
  #    close $private(readHpHandle)
  #    set private(readHpHandle) ""
  # }

}

#------------------------------------------------------------
# testWriteHp
#    envoie les coordonnees toutes les secondes
#------------------------------------------------------------
proc ::sophie::test::testWriteHp { } {
   variable private

   set data  $private(data,$private(dataNo))
   if { $private(dataNo) < "2" } {
      incr  private(dataNo)
   } else {
      set private(dataNo) 0
   }

   if { $private(testhp) == 1 } {
      puts  $private(writeHpHandle) $data
console::disp "testWriteHp data=$data\n"
     after 5000 ::sophie::test::testWriteHp
   } else {
     if { $private(writeHpHandle) != "" } {
         close $private(writeHpHandle)
         set private(writeHpHandle) ""
      }
   }
}

#------------------------------------------------------------
# testReadCom
#    lit les coordonnees toutes les 3 secondes
#------------------------------------------------------------
proc ::sophie::test::testReadCom { } {
   variable private

   if { $private(testhp) == 1 } {
      set data [read -nonewline $private(readHpHandle)]
      set data [split $data "\n" ]
      set messageNb [llength $data]
      console::disp "\ntestReadHp nb=$messageNb data=$data\n"
      after 3000 ::sophie::test::testReadHp
   } else {
     if { $private(readHpHandle) != "" } {
         close $private(readHpHandle)
         set private(readHpHandle) ""
      }
   }
}

#------------------------------------------------------------
# startReadHp
#    lance la lecture sur le port COM1
#------------------------------------------------------------
proc ::sophie::test::startReadHp { } {
   variable private

   # j'ouvre le port de reception des coordonnees
   set private(readHpHandle) [open COM1 "r+" ]
   fconfigure $private(readHpHandle) -mode "19200,n,8,1" -buffering none -blocking 0
   console::disp "startReadHp  private(readHpHandle)=$private(readHpHandle)\n"
   set private(testhp) 1
   ::sophie::test::testReadHp
}

#------------------------------------------------------------
# stopReadHp
#    lit les coordonnees toutes les 3 secondes
#------------------------------------------------------------
proc ::sophie::test::stopReadHp { } {
   variable private

   set private(testhp) 0

}

#------------------------------------------------------------
# testReadHp
#    lit les coordonnees toutes les 3 secondes
#------------------------------------------------------------
proc ::sophie::test::testReadHp { } {
   variable private

   if { $private(testhp) == 1 } {
      set data [read -nonewline $private(readHpHandle)]
      set data [split $data "\n" ]
      set messageNb [llength $data]
      set data [lindex $data end]
      if { $data != "" } {
         set nbVar [scan $data "%dh %dm %fs / %dd %d' %d'' / %dd" ah am as dd dm ds ba]
         if { $nbVar == 7 } {
            ##set alpha "${ah}h${am}m${as}s"
            set alpha [format "%02dh%02dm%05.2fs" $ah $am $as]
            set delta "${dd}h${dm}m${ds}s"
            console::disp "testReadHp nb=$messageNb data=$data  alpha=$alpha delta=$delta\n"
         } else {
            console::affiche_erreur  "testReadHp nb=$messageNb data=$data nbVar=$nbVar\n"
         }
      } else {
         console::disp "testReadHp nb=$messageNb data=$data\n"
      }
      after 2000 ::sophie::test::testReadHp
   } else {
     if { $private(readHpHandle) != "" } {
         close $private(readHpHandle)
         set private(readHpHandle) ""
      }
   }
}

#============================================================
#
# SIMULATION DU PC SOPHIE
#
#============================================================

#------------------------------------------------------------
# openSocketSophie
#   ouvre une socket en ecriture pour simuler l'envoi des donnees du PC Sophie
#
# @param host adress IP ou nom DNS du PC de guidage (parametre optionel, valeur par defaut= localhost)
#------------------------------------------------------------
proc ::sophie::test::openSocketSophie { } {
   variable private

   set private(socketChannel) [socket $private(host) $::conf(sophie,socketPort) ]
   #---  -translation binary -encoding binary
   fconfigure $private(socketChannel) -buffering line -blocking false -translation binary -encoding binary
   fileevent $private(socketChannel) readable [list ::sophie::test::readSocketSophie ]

}

#------------------------------------------------------------
# closeSocketSophie
#   ferme la socket
#
#------------------------------------------------------------
proc ::sophie::test::closeSocketSophie { } {
   variable private
   if { $private(socketChannel) != "" } {
      close $private(socketChannel)
      set private(socketChannel) ""
   }
}

#------------------------------------------------------------
# readSocketSophie
#   envoie des donnes vers le PC de guidage
#
#------------------------------------------------------------
proc ::sophie::test::readSocketSophie {  } {
   variable private

   set private(socketResponse) [gets $private(socketChannel) ]
   ###return $result
}

#------------------------------------------------------------
# writeSocketSophie
#   envoie des donnes vers le PC de guidage
#
# @param data : donnees a envoyer
#------------------------------------------------------------
proc ::sophie::test::writeSocketSophie { data } {
   variable private

   console::disp "::sophie::test::writeSocketSophie data=$data\n"
   puts $private(socketChannel) $data

}

#============================================================
#
# tests de la fenetre de controle
#
#============================================================

##------------------------------------------------------------
# tests de la fenetre de controle
#------------------------------------------------------------
proc ::sophie::test::tc1 { } {
   ### starDetection fiberDetection originX originY starX starY fwhmX fwhmY background maxFlow
   ::sophie::control::setCenterInformation 1 1 750 512 752 514 45 46 100 10000
}

##------------------------------------------------------------
# tests de la fenetre de controle
#------------------------------------------------------------
proc ::sophie::test::tsim0 { }  {
   set ::conf(sophie,simulation) 0
   set ::conf(sophie,simulationGenericFileName) "C:/Documents and Settings/michel/Mes documents/astronomie/test/OHP/simulation/centrage_"
   ::console::disp "pas de simulation\n"
}

##------------------------------------------------------------
# tests de la fenetre de controle
#------------------------------------------------------------
proc ::sophie::tsim1 { }  {
   set ::conf(sophie,simulation) 1
   set ::conf(sophie,simulationGenericFileName) "$::audace(rep_images)/test/OHP/simulation/centrage_"
   ::console::disp "simulation fichiers centrage_*\n"
}

##------------------------------------------------------------
# tests de la fenetre de controle
#------------------------------------------------------------
proc ::sophie::test::tsim2 { }  {
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

   ::sophie::test::createDialogSimul
}

#------------------------------------------------------------
# ok
#    Fonction appellee lors de l'appui sur le bouton 'OK' pour
#    appliquer la configuration et fermer la fenetre
#------------------------------------------------------------
proc ::sophie::test::ok { } {
   variable private

   set ::conf(sophie,simulation)                $private(simulation)
   set ::conf(sophie,simulationGenericFileName) $private(simulationGenericFileName)

   if { $::conf(sophie,simulation) == 1 } {
      ::camera::setParam $::sophie::private(camItem) "simulation" 1
      ::camera::setParam $::sophie::private(camItem) "simulationGenericFileName" $::conf(sophie,simulationGenericFileName)
   } else {
      ::camera::setParam $::sophie::private(camItem) "simulation" 0
   }
   ::sophie::test::fermer
}

#------------------------------------------------------------
# fermer
#    Fonction appellee lors de l'appui sur le bouton 'Fermer' pour
#    fermer la fenetre
#------------------------------------------------------------
proc ::sophie::test::fermer { } {
   variable private

   #--- je referme la socket du pc de guidage
   ::sophie::test::closeSocketSophie

   destroy $private(frm)
}

#------------------------------------------------------------
# createDialogSimul
#    Creation de l'interface graphique
#------------------------------------------------------------
proc ::sophie::test::createDialogSimul { } {
   variable private

   #--- j'initialise les variables
   set private(host) "localhost"
   set private(socketChannel) ""
   set private(frm) $::audace(base).configSimul

   set frm $private(frm)
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
   wm protocol $frm WM_DELETE_WINDOW ::sophie::test::fermer

   #--- On utilise les valeurs contenues dans le tableau conf pour l'initialisation
   set private(simulation)                $::conf(sophie,simulation)
   set private(simulationGenericFileName) $::conf(sophie,simulationGenericFileName)

   #--- Frame pour la simulation des acquisitions
   TitleFrame $frm.simulAcquisition -borderwidth 2 -relief groove -text $::caption(sophie,simulAcquisition)

      #--- Frame pour la simulation
      frame $frm.simulAcquisition.check -borderwidth 0 -relief raised

         #--- Activation ou non de la simulation
         checkbutton $frm.simulAcquisition.check.simul -text $::caption(sophie,modeSimulation) \
            -highlightthickness 0 -variable ::sophie::test::private(simulation)
         pack $frm.simulAcquisition.check.simul -anchor center -side left -padx 5 -pady 5

      pack $frm.simulAcquisition.check -in [ $frm.simulAcquisition getframe ] \
         -side top -fill both -expand 1

      #--- Frame pour les fichiers de simulation
      frame $frm.simulAcquisition.filename -borderwidth 0 -relief raised

         #--- Label
         label $frm.simulAcquisition.filename.label -text $::caption(sophie,simulGenericFileName)
         pack $frm.simulAcquisition.filename.label -anchor center -side left -padx 5 -pady 5

         #--- Entry pour le nom generique des images de simulation
         entry $frm.simulAcquisition.filename.entry -textvariable ::sophie::test::private(simulationGenericFileName) \
            -width 25 -justify left
         pack $frm.simulAcquisition.filename.entry -anchor center -side left -padx 5 -pady 5

         #--- Bouton 'Parcourir'
         button $frm.simulAcquisition.filename.butParcourir -text $::caption(sophie,parcourir) \
            -borderwidth 2 -command "::sophie::test::simulationGenericFileName"
         pack $frm.simulAcquisition.filename.butParcourir -anchor center -side left -padx 5 -pady 5

      pack $frm.simulAcquisition.filename -in [ $frm.simulAcquisition getframe ] \
         -side top -fill both -expand 1

   pack $frm.simulAcquisition -side top -fill both -expand 1

   #--- Frame pour le mode de fonctionnement
   TitleFrame $frm.pcsophie -borderwidth 2 -relief groove -text $::caption(sophie,simulPCSophie)

      #--- host
      label $frm.pcsophie.hostLabel -text $::caption(sophie,host)
      grid $frm.pcsophie.hostLabel -in [ $frm.pcsophie getframe ] -row 0 -column 0 -sticky ens -padx 2
      entry $frm.pcsophie.hostEntry -textvariable ::sophie::test::private(host)
      grid $frm.pcsophie.hostEntry -in [ $frm.pcsophie getframe ] -row 0 -column 1 -sticky ens -padx 2

      #--- Bouton connect et disconnect
      button $frm.pcsophie.connect -text $::caption(sophie,connecter) -command "::sophie::test::connecterPcGuidage"
      grid $frm.pcsophie.connect -in [ $frm.pcsophie getframe ] -row 0 -column 2 -sticky ens -padx 2

      #--- Bouton envoi de commande
      button $frm.pcsophie.clearstat -text "RAZ STAT" -command [list ::sophie::test::sendPcGuidage "RAZ_STAT" ]
      grid $frm.pcsophie.clearstat -in [ $frm.pcsophie getframe ] -row 0 -column 3 -sticky ens -padx 2

      button $frm.pcsophie.staton -text "STAT ON" -command [list ::sophie::test::sendPcGuidage "STAT_ON" ]
      grid $frm.pcsophie.staton -in [ $frm.pcsophie getframe ] -row 1 -column 3 -sticky ens -padx 2

      button $frm.pcsophie.statoff -text "STAT OFF" -command [list ::sophie::test::sendPcGuidage "STAT_OFF" ]
      grid $frm.pcsophie.statoff -in [ $frm.pcsophie getframe ] -row 2 -column 3 -sticky ens -padx 2

      button $frm.pcsophie.getstat -text "GET STAT" -command [list ::sophie::test::sendPcGuidage "GET_STAT" ]
      grid $frm.pcsophie.getstat -in [ $frm.pcsophie getframe ] -row 3 -column 3 -sticky ens -padx 2

   pack $frm.pcsophie -in $frm -side top -fill both -expand 1

   #--- Frame pour les boutons
   frame $frm.frameButton -borderwidth 1 -relief raised

      #--- Bouton 'OK'
      button $frm.butOk -text $::caption(sophie,ok) -borderwidth 2 \
         -command "::sophie::test::ok"
      pack $frm.butOk -in $frm.frameButton -anchor center -side left -padx 5 -pady 5 -ipadx 10 -ipady 5

      #--- Bouton 'Fermer'
      button $frm.butFermer -text $::caption(sophie,fermer) -borderwidth 2 \
         -command "::sophie::test::fermer"
      pack $frm.butFermer -in $frm.frameButton -anchor center -side right -padx 5 -pady 5 -ipadx 10 -ipady 5

   pack $frm.frameButton -side top -fill x

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
proc ::sophie::test::simulationGenericFileName { } {
   variable private

   #--- Ouvre la fenetre de choix des images
   set filename [ ::tkutil::box_load $::audace(base) $::audace(rep_images) $::audace(bufNo) "1" ]
   #--- Nom generique avec le chemin
   set private(simulationGenericFileName) [ file join [ lindex [ decomp $filename ] 0 ] [ lindex [ decomp $filename ] 1 ] ]
   #--- Il faut un fichier
   if { $private(simulationGenericFileName) == "" } {
      return
   }
}

#------------------------------------------------------------
# connecterPcGuidage
#    connecter/deconnecter au PC de guidage
#------------------------------------------------------------
proc ::sophie::test::connecterPcGuidage { } {
   variable private

   set catchError [ catch {
      if { $private(socketChannel) == "" } {
         ::sophie::test::openSocketSophie
         $private(frm).pcsophie.connect configure -text "déconnecter"
      } else {
         ::sophie::test::closeSocketSophie
         $private(frm).pcsophie.connect configure -text "connecter"
      }
   }]

   if { $catchError != 0 } {
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(sophie,simulation)
   }
}

#------------------------------------------------------------
# connecterPcGuidage
#    envoie des donnees au PC de guidage
#------------------------------------------------------------
proc ::sophie::test::sendPcGuidage { commandName } {
   variable private

   set catchError [ catch {
      switch $commandName {
         "STAT_ON" {
            ::sophie::test::writeSocketSophie "!STAT_ON@"
         }
         "STAT_OFF" {
            ::sophie::test::writeSocketSophie "!STAT_OFF@"
         }
         "GET_STAT" {
            #--- je purge la socket
            set private(socketResponse) ""

            ::sophie::test::writeSocketSophie "!GET_STAT@"
            ###set result [::sophie::test::readSocketSophie]
            update
            set result $private(socketResponse)
            #--- j'affiche le resultat
            tk_messageBox -title $::caption(sophie,simulation) -type ok -message "statistiques=$result" -icon info
         }
         "RAZ_STAT" {
            ::sophie::test::writeSocketSophie "!RAZ_STAT@"
         }

         default {
            error "invalid commandName=$commandName"
         }
      }
   }]

   if { $catchError != 0 } {
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(sophie,simulation)
   }

}

###### Fin de la fenetre de configuration de la simulation ######

###::sophie::simul

#  source audace/plugin/tool/sophie/sophietest.tcl

