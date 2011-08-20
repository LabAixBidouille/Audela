#
# Fichier : t1m_roue_a_filtre.tcl
# Description : Pilotage de la roue a filtres du T1m - Observation en automatique
# Camera : Script optimise pour une Andor ikon-L
# Auteur : Frédéric Vachier
# Mise à jour $Id$
#
# source audace/plugin/tool/acqt1m/flat_t1m_auto.tcl
#

namespace eval ::t1m_roue_a_filtre {

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   # source [ file join [file dirname [info script]] acqt1m.cap ]

   #--- Procedure d'initialisation de la liste des filtres
   proc init { } {
      variable private

      # Col : 0 Actif/NonActif
      # Col : 1 Nom court
      # Col : 2 Nom long
      # Col : 3 nbimage
      # Col : 4 sens de debut nuit
      # Col : 5 epaisseur
      # Col : 6 centre
      # Col : 7 offset exptime

      set private(filtre,1) [list 0  "L"   "Large"   0   9   0.1   0.2   0.]
      set private(filtre,2) [list 0  "B"   "B"       0   8   0.1   0.2   0.]
      set private(filtre,3) [list 0  "V"   "V"       0   7   0.1   0.2   0.]
      set private(filtre,4) [list 0  "R"   "Rouge"   0   5   0.1   0.2   0.]
      set private(filtre,5) [list 0  "740" "740"     0   6   0.1   0.2   0.]
      set private(filtre,6) [list 0  "807" "807"     0   4   0.1   0.2   0.]
      set private(filtre,7) [list 0  "U"   "U"       0   2   0.1   0.2   0.]
      set private(filtre,8) [list 0  "Ha"  "Halpha"  0   3   0.1   0.2   0.]
      set private(filtre,9) [list 0  "CH4" "CH4"     0   1   0.1   0.2   0.]
   }

   #--- Procedure d'initialisation de la roue a filtres
   proc initFiltre { visuNo } {
      variable private
      global panneau

      ::t1m_roue_a_filtre::init

      set panneau(acqt1m,$visuNo,filtrelist) "none"
      for { set i 1 } {$i <= 9} {incr i} {
         ::console::affiche_resultat "$::caption(t1m_roue_a_filtre,filtre) [lindex $private(filtre,$i) 2]\n"
         lappend panneau(acqt1m,$visuNo,filtrelist) [lindex $private(filtre,$i) 2]
      }

      set panneau(acqt1m,$visuNo,filtrecourant) "none"
   }

   #--- Procedure de changement de filtre
   proc changeFiltre { visuNo } {
      variable private
      global panneau

      if { [lindex $panneau(acqt1m,$visuNo,filtrelist) 0] == "none"} {
         set panneau(acqt1m,$visuNo,filtrelist) ""
         for { set i 1 } {$i <= 9} {incr i} {
            lappend panneau(acqt1m,$visuNo,filtrelist) [lindex $private(filtre,$i) 2]
         }
         $panneau(acqt1m,$visuNo,This).filtre.filtrecourant.menu delete 0
      }

      ::console::affiche_resultat "$::caption(t1m_roue_a_filtre,changeFiltre) $panneau(acqt1m,$visuNo,filtrecourant)\n"
      for { set idfiltre 1 } {$idfiltre <= 9} {incr idfiltre} {
         if {[lindex $private(filtre,$idfiltre) 2]==$panneau(acqt1m,$visuNo,filtrecourant)} {
            break
         }
      }

      # Initialise la roue a filtres
      set err [ catch { set tty [open "/dev/ttyS0" r+] } ]
      if { $err == 1 } {
         ::console::affiche_resultat "$::caption(t1m_roue_a_filtre,roueNonInitialise)\n\n"
         return
      }

      fconfigure $tty -mode "19200,n,8,1" -buffering none -blocking 0

      # Initialise la roue a filtres
      puts -nonewline $tty "WSMODE"
      while {1==1} {
         after 100
         set char [read $tty 10]
         #::console::affiche_resultat "$char"
         if {[lsearch -exact $char "!"] == 0} {
            break
         }
      }

      # Changement de filtre
      puts -nonewline $tty "WGOTO$idfiltre"
      while {1==1} {
         after 100
         set char [read $tty 10]
         #::console::affiche_resultat "$char"
         if {[lsearch -exact $char "*"] == 0} {
            break
         }
     }

      puts -nonewline $tty "WFILTR"
      while {1==1} {
         after 100
         set char [read $tty 10]
         #::console::affiche_resultat "$char"
         if {[llength $char] == 1} {
            break
         }
     }

      if {$idfiltre != $char} {
         ::console::affiche_erreur "$::caption(t1m_roue_a_filtre,probleme)\n"
      }

      # Ferme la connexion avec la roue a filtres
      puts -nonewline $tty "WEXITS"
      while {1==1} {
         after 100
         set char [read $tty 10]
         #::console::affiche_resultat "$char"
         if {[lsearch -exact $char "END"] == 0} {
            break
         }
      }
      close $tty
   }

}

