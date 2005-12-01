#
# Fichier : avrcom.tcl
# Description : Gere une carte avec un microcontroleur AVR sur le port serie
# Auteur : Raymond ZACHANTKE
# Date de mise a jour : 11 novembre 2004
#

global confTel

#--- Initialisation de variables
#--- Si la trace des communications n'est pas souhaitee, mettre trace_in et trace_out a 0
#--- Si la trace des communications est souhaitee, mettre trace_in et trace_out a 1
array set avrcom { 
   tty       ""
   delay     "100"
   trace_in  "1"
   trace_out "1"
   bouton    "0"
} 

set confTel(avrcom,connect)  "0"

namespace eval AvrCom {
   global avrcom

   #
   # AvrCom::init (est lance automatiquement au chargement de ce fichier tcl)
   # Initialise les variables caption(...) 
   #
   proc init { } {
      global audace   
 
      #--- Charge le fichier caption
      uplevel #0 "source \"[ file join $audace(rep_plugin) mount avrcom avrcom.cap ]\""
   }

   #
   #--- Lit une donnee sur le port serie
   #
   proc avr_read { tty } {
      global audace
      global avrcom

      #--- Lit une donnee
      gets [ tel$audace(telNo) channel ] answer
      after [ expr $avrcom(delay) ]
      return $answer
   }

   #
   # AvrCom::go_pad
   # Envoie les donnees
   #
   proc go_pad { } {
      global avrcom
      global caption
      global frmm

      #--- Initialisation
      set avrcom(bouton) "1"
      set frm $frmm(Telscp5)
      #--- Gestion des boutons
      $frm.but_init configure -relief groove -state disabled
	$frm.but_send configure -relief raised -state disabled
      update
	#--- Transmission de donnees au demarrage specifique a l'AVR 
	#--- Temps universel de l'horloge
	set date [clock format [clock seconds] -format "%Y %m %d" -gmt 1]
      console::affiche_saut "\n"
	console::affiche_erreur "$caption(avrcom,date) [lindex $date 0] [lindex $date 1] [lindex $date 2]\n"
	#--- Heure siderale de greenwich
	set sideral [mc_date2lst {now} {gps 0 e 0 0}]
 	console::affiche_erreur "$caption(avrcom,sideral) $sideral\n"
	#--- Temps universel
	set time [clock format [clock seconds] -format "%H %M %S" -gmt 1]
	#console::affiche_erreur "$caption(avrcom,heure) [lindex $time 0] [lindex $time 1] [lindex $time 2]\n"
      ::AvrCom::send_pad "#:SS [lindex $sideral 0]:[lindex $sideral 1]:[expr int([lindex $sideral 2])]#"
      ::AvrCom::send_pad "#:SU [lindex $time 0]:[lindex $time 1]:[lindex $time 0]#"	
      ::AvrCom::send_pad "#:ID#"
      #--- Gestion des boutons
      $frm.but_init configure -relief raised -state normal
	$frm.but_send configure -relief raised -state normal
      update
	#--- Initialisation
	set avrcom(cmd) {}
      set avrcom(bouton) "0"
      return
   }

   #
   # AvrCom::send_pad
   # Envoie une commande
   #
   proc send_pad { cmd } {
      global audace
	global caption
      global avrcom
      global frmm

      #--- Initialisation
      set frm $frmm(Telscp5)
      #--- Gestion des boutons
      if { $avrcom(bouton) == "0" } {
         $frm.but_init configure -relief raised -state disabled
	   $frm.but_send configure -relief groove -state disabled
         update
      }
	#--- Lit un eventuel message
      ::AvrCom::read_pad
	#--- Envoie la commande
      ::AvrCom::cmd $cmd
      #--- Attend une reponse
      after [expr $avrcom(delay)]
      set avrcom(answer) [ avr_read [ tel$audace(telNo) channel ] ]
	if { [string compare $avrcom(answer) ""]!=0 } {
	   #--- Si une trace est demandee
         if {[string compare $avrcom(trace_in) "0"]!=0 } {	
            console::affiche_erreur  "$caption(avrcom,reponse) $avrcom(answer)\n"
         }
      } else {
         ::AvrCom::no_answer
      }
      #--- Gestion des boutons
      if { $avrcom(bouton) != "1" } {
         $frm.but_init configure -relief raised -state normal
	   $frm.but_send configure -relief raised -state normal
         update
      }
      return
   }

   #
   # AvrCom::cmd
   # Emission d'une commande et echo si demande
   #
   proc cmd { cmd } {
      global audace
      global caption
      global avrcom

      #--- Envoi une commande
      puts [ tel$audace(telNo) channel ] $cmd
      after [ expr $avrcom(delay) ]
      #---
      if { [string compare $avrcom(trace_out) "0"]!=0 } {
         console::affiche_saut "\n"
	   console::affiche_erreur "$caption(avrcom,emis) $cmd\n"
      }
      return
   }

   #
   # AvrCom::read_pad
   # Lit le port serie
   #
   proc read_pad { } { 
      global audace
      global caption
      global avrcom
   
      after [expr $avrcom(delay)]
      set answer [ avr_read [ tel$audace(telNo) channel ] ]
      if { [string compare $avrcom(trace_in) "0"]!=0 && ([string compare $answer ""]!=0) } {
         console::affiche_saut "\n"
	   console::affiche_erreur "$caption(avrcom,recu) $answer\n"
      }
      return
   }

   #
   # AvrCom::no_answer
   # If no answer
   # 
   proc no_answer { } {
      global caption

	console::affiche_erreur  "$caption(avrcom,pas_reponse)\n"
      return
   }

}

#--- Chargement au demarrage
::AvrCom::init

