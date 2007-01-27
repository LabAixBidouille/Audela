#
# Fichier : ouranoscom.tcl
# Description : Script minimum, variante de audecom.tcl dediee a l'interface Ouranos de Patrick DUFOUR
# Auteurs : Raymond ZACHANTKE et Robert DELMAS
# Mise a jour $Id: ouranoscom.tcl,v 1.4 2007-01-27 15:24:30 robertdelmas Exp $
#

global confTel

#--- Initialisation de variables
#--- Si la trace des communications n'est pas souhaitee, mettre trace_in et trace_out a 0
#--- Si la trace des communications est souhaitee, mettre trace_in et trace_out a 1
array set ouranoscom {
   tty       ""
   delay     "20"
   trace_in  "0"
   trace_out "0"
   lecture   "0"
}

set confTel(ouranos,connect) "0"

namespace eval OuranosCom {
   global ouranoscom

   #
   # OuranosCom::init (est lance automatiquement au chargement de ce fichier tcl)
   # Initialise les variables caption(...)
   #
   proc init { } {
      global audace

      #--- Charge le fichier caption
      source [ file join $audace(rep_plugin) mount ouranos ouranoscom.cap ]
   }

   #
   # OuranosCom::go_ouranos
   # Lit l'interface Ouranos
   #
   proc go_ouranos { } {
      global conf
      global caption
      global confTel
      global ouranoscom
      global frmm

      catch {
         set frm $frmm(Telscp2)
         set ouranoscom(lecture) "1"
         if { $confTel(ouranos,find) == "1" } {
            set confTel(ouranos,find) "0"
            set confTel(ouranos,show_coord) $conf(ouranos,show_coord)
            ::confTel::MatchOuranos
         }
         #--- Traitement graphique du bouton 'Lire'
         $frm.but_read configure -text "$caption(ouranoscom,lire)" -relief groove -state disabled
         update
         #--- Traitement graphique du bouton 'Regler'
         $frm.but_init configure -text "$caption(ouranoscom,reglage)" -state disabled
         update
         #--- Traitement graphique du bouton 'MATCH'
         if { $confTel(ouranos,show_coord) == "1" } {
            #--- Bouton MATCH avec entry actif
            $frm.but_match configure -text "$caption(ouranoscom,match)" -width 8 -state normal \
               -command { ::OuranosCom::match_ouranos }
            update
         }
         #--- Lit et affiche les coordonnees
         ::OuranosCom::read_coord
      }
      return
   }

   #
   # OuranosCom::match_ouranos
   # MATCH
   #
   proc match_ouranos { } {
      global audace
      global confTel

      #--- Envoi le Match
      tel$audace(telNo) radec init { $confTel(ouranos,match_ra) $confTel(ouranos,match_dec) }
      return
   }

   #
   # OuranosCom::match_transfert_ouranos
   # Transfert des coordonnees pour le bouton MATCH
   #
   proc match_transfert_ouranos { } {
      global caption
      global confTel
      global catalogue
      global frmm

      set frm $frmm(Telscp2)
      if { $confTel(ouranos,obj_choisi) == "$caption(ouranoscom,messier)" } {
         set confTel(ouranos,match_ra) $catalogue(objet_ad)
         $frm.match_ra_entry configure -textvariable confTel(ouranos,match_ra)
         set confTel(ouranos,match_dec) $catalogue(objet_dec)
         $frm.match_dec_entry configure -textvariable confTel(ouranos,match_dec)
      } elseif { $confTel(ouranos,obj_choisi) == "$caption(ouranoscom,ngc)" } {
         set confTel(ouranos,match_ra) $catalogue(objet_ad)
         $frm.match_ra_entry configure -textvariable confTel(ouranos,match_ra)
         set confTel(ouranos,match_dec) $catalogue(objet_dec)
         $frm.match_dec_entry configure -textvariable confTel(ouranos,match_dec)
      } elseif { $confTel(ouranos,obj_choisi) == "$caption(ouranoscom,ic)" } {
         set confTel(ouranos,match_ra) $catalogue(objet_ad)
         $frm.match_ra_entry configure -textvariable confTel(ouranos,match_ra)
         set confTel(ouranos,match_dec) $catalogue(objet_dec)
         $frm.match_dec_entry configure -textvariable confTel(ouranos,match_dec)
      } elseif { $confTel(ouranos,obj_choisi) == "$caption(ouranoscom,etoile)" } {
         set confTel(ouranos,match_ra) $catalogue(etoile_ad)
         $frm.match_ra_entry configure -textvariable confTel(ouranos,match_ra)
         set confTel(ouranos,match_dec) $catalogue(etoile_dec)
         $frm.match_dec_entry configure -textvariable confTel(ouranos,match_dec)
      }
      set confTel(ouranos,objet) "4"
      return
   }

   #
   # OuranosCom::init_ouranos
   # Initialisation
   #
   proc init_ouranos { } {
      global confTel
      global conf
      global caption

      #---
      set confTel(ouranos,status)      $caption(ouranoscom,off)
      #---
      set confTel(ouranos,cod_dec)     $conf(ouranos,cod_dec)
      set confTel(ouranos,cod_ra)      $conf(ouranos,cod_ra)
      set confTel(ouranos,freq)        $conf(ouranos,freq)
      set confTel(ouranos,init)        $conf(ouranos,init)
      set confTel(ouranos,inv_dec)     $conf(ouranos,inv_dec)
      set confTel(ouranos,inv_ra)      $conf(ouranos,inv_ra)
      set confTel(ouranos,show_coord)  $conf(ouranos,show_coord)
      set confTel(ouranos,tjrsvisible) $conf(ouranos,tjrsvisible)
      #---
      set confTel(ouranos,find)        "0"
      ::OuranosCom::set_dec_ra
      return
   }

   #
   # OuranosCom::set_dec_ra
   # Offset des pas codeurs DEC et RA en fonction du mode d'initialisation
   #
   proc set_dec_ra { } {
      global confTel

      if { [ string compare $confTel(ouranos,init) "1" ] == "0" } {
          set confTel(ouranos,init_dec) [ expr $confTel(ouranos,cod_dec)/4 ]
      } else {
          set confTel(ouranos,init_dec) [ expr $confTel(ouranos,cod_dec)/2 ]
      }
      #--- Preposition de RA
      set confTel(ouranos,init_ra) [ expr $confTel(ouranos,cod_ra)/2 ]
      return
   }

   #
   # OuranosCom::send_encod
   # Envoie une commande
   #
   proc send_encod { cmd } {
      global caption
      global ouranoscom

      #--- Lit un eventuel message
      ::OuranosCom::read_com
      #--- Envoie la commande
      ::OuranosCom::emis_cmd $cmd
      #--- Attend une reponse
      after [ expr $ouranoscom(delay) ]
      #--- La reponse comporte normalement le caractere 'R'
      set answer [ read $ouranoscom(tty) 1 ]
      if { [ string compare $answer "" ] != "0" } {
         #--- Si une trace est demandee
         if { [ string compare $ouranoscom(trace_in) "0" ] != "0" } {
            console::affiche_erreur  "$caption(ouranoscom,reponse) $answer\n"
         }
      } else {
         ::OuranosCom::no_answer
      }
      return
   }

   #
   # OuranosCom::read_coord
   # Lit les encodeurs Ouranos
   #
   proc read_coord { } {
      global caption
      global confTel
      global ouranoscom
      global Fenetre

      if { [ string compare $ouranoscom(tty) "" ] != "0" } {
         #--- Verifie si un message n'est pas en attente, tres rustique mais operationnel
         set answer [ read $ouranoscom(tty) 1 ]
         if { ( [ string compare $ouranoscom(trace_in) "0" ] != "0" ) && ( [ string compare $answer "" ] != "0" ) } {
            console::affiche_erreur  "$caption(ouranoscom,recu) $answer\n"
         }
         #--- Envoi un signal d'interrogation
         set cmd "Q"
         ::OuranosCom::emis_cmd $cmd
         #--- Procede a une lecture
         after [ expr $ouranoscom(delay) ]
         gets $ouranoscom(tty) answer
         if { [ string compare $answer "" ] != "0" } {
            ::OuranosCom::analyze_answer $answer
            if { [ string compare $ouranoscom(trace_in) "0"] != "0" } {
               console::affiche_erreur "$caption(ouranoscom,dec1) $caption(ouranoscom,2points)\
                  $confTel(ouranos,dec_enc) $caption(ouranoscom,ad1) $caption(ouranoscom,2points)\
                  $confTel(ouranos,ra_enc)\n"
            }
         } else {
            ::OuranosCom::no_answer
         }
         if { [ string compare $confTel(ouranos,find) "0" ] == "0" } {
            ::OuranosCom::show1
         } else {
            ::OuranosCom::show2
         }
         #--- Et recommence
         if { [ winfo exists $audace(base).tjrsvisible ] } {
            if { $confTel(ouranos,tjrsvisible) == "1" } {
               set Fenetre(ouranos,coord_ra) "$caption(ouranoscom,ad) $confTel(ouranos,coord_ra)"
               $audace(base).tjrsvisible.lab1 configure -text "$Fenetre(ouranos,coord_ra)"
               set Fenetre(ouranos,coord_dec) "$caption(ouranoscom,dec) $confTel(ouranos,coord_dec)"
               $audace(base).tjrsvisible.lab2 configure -text "$Fenetre(ouranos,coord_dec)"
            }
         } elseif { [ winfo exists $audace(base).tjrsvisible_x10 ] } {
            if { $confTel(ouranos,tjrsvisible) == "1" } {
               set Fenetre(ouranos,coord_ra) "$caption(ouranoscom,ad)\n$confTel(ouranos,coord_ra)"
               $audace(base).tjrsvisible_x10.lab1 configure -text "$Fenetre(ouranos,coord_ra)"
               set Fenetre(ouranos,coord_dec) "$caption(ouranoscom,dec)\n$confTel(ouranos,coord_dec)"
               $audace(base).tjrsvisible_x10.lab2 configure -text "$Fenetre(ouranos,coord_dec)"
            }
         } else {
            set confTel(ouranos,tjrsvisible) "0"
         }
         if { $ouranoscom(lecture) == "1" } {
            after [ expr $confTel(ouranos,freq)*1000 ] ::OuranosCom::read_coord
         } else {
            #--- Effacement des coordonnees AD et Dec.
            set confTel(ouranos,coord_ra)  ""
            set confTel(ouranos,coord_dec) ""
         }
      }
      return
   }

   #
   # OuranosCom::show1
   # Selection de l'affichage
   #
   proc show1 { } {
      global audace
      global caption
      global confTel

      catch {
         if { [ string compare $confTel(ouranos,show_coord) "0" ] == "0" } {
            set pas_encod [ tel$audace(telNo) nbticks ]
            set confTel(ouranos,coord_ra)  "[ lindex $pas_encod 0 ] $caption(ouranoscom,pas)"
            set confTel(ouranos,coord_dec) "[ lindex $pas_encod 1 ] $caption(ouranoscom,pas)"
         } else {
            set radec [ tel$audace(telNo) radec coord ]
            set confTel(ouranos,coord_ra)  [ lindex $radec 0 ]
            set confTel(ouranos,coord_dec) [ lindex $radec 1 ]
            ::telescope::afficheCoord
         }
      }
      return
   }

   #
   # OuranosCom::show2
   # Affichage des pas codeurs
   #
   proc show2 { } {
      global confTel

      set dec_enc [ expr $confTel(ouranos,dec_enc) ]
      set ra_enc [ expr $confTel(ouranos,ra_enc) ]
      if { [ expr abs($dec_enc)-32768 ] > "0" } {
         set dec_enc [ expr 65536-[ expr abs($dec_enc) ] ]
         set confTel(ouranos,inv_dec) "-1"
      }
      if { [ expr abs($ra_enc)-32768 ] > "0" } {
         set ra_enc [ expr 65536-[ expr abs($ra_enc) ] ]
         set confTel(ouranos,inv_ra) "-1"
      }
      set confTel(ouranos,cod_dec) $dec_enc
      set confTel(ouranos,cod_ra)  $ra_enc
      return
   }

   #
   # OuranosCom::analyze_answer
   # Analyse la reponse des encodeurs
   #
   proc analyze_answer { answer } {
      global confTel

      #--- Ote le retour chariot
      set answer [ split $answer \r ]
      set coords [ lindex $answer 0 ]
      #--- Ote le caractere de tabulation
      set coords [ split $coords \t ]
      set confTel(ouranos,dec_enc) [ format "%g" [ lindex $coords 1 ] ]
      set confTel(ouranos,ra_enc)  [ format "%g" [ lindex $coords 0 ] ]
      set confTel(ouranos,dec_enc) [ expr $confTel(ouranos,inv_dec)*$confTel(ouranos,dec_enc) ]
      set confTel(ouranos,ra_enc)  [ expr $confTel(ouranos,inv_ra)*$confTel(ouranos,ra_enc) ]
      return
   }

   #
   # OuranosCom::emis_cmd
   # Emission d'une commande et echo si demande
   #
   proc emis_cmd { cmd } {
      global caption
      global ouranoscom

      puts $ouranoscom(tty) $cmd
      after 100
      if { [ string compare $ouranoscom(trace_out) "0" ] != "0" } {
         console::affiche_erreur "$caption(ouranoscom,emis) $cmd\n"
      }
      return
   }

   #
   # OuranosCom::read_com
   # Lit le port serie
   #
   proc read_com { } {
      global caption
      global ouranoscom

      after [ expr $ouranoscom(delay) ]
      gets $ouranoscom(tty) answer
      if { ( [ string compare $ouranoscom(trace_in) "0" ] != "0" ) && ( [ string compare $answer "" ] != "0" ) } {
         console::affiche_erreur "$caption(ouranoscom,recu) $answer\n"
      }
      return
   }

   #
   # OuranosCom::close_com
   # Ferme le port serie, s'il n'est pas ferme
   #
   proc close_com { } {
      global caption
      global conf
      global audace
      global ouranoscom
      global confTel
      global frmm

      set frm $frmm(Telscp2)
      catch {
         set ouranoscom(lecture) "0"
         #--- Traitement graphique du bouton 'Lire'
         $frm.but_read configure -text "$caption(ouranoscom,lire)" -relief raised -state normal
         update
         #--- Traitement graphique du bouton 'Regler'
         $frm.but_init configure -text "$caption(ouranoscom,reglage)" -relief raised -state normal
         update
         #--- Traitement graphique du bouton 'MATCH'
         if { $confTel(ouranos,show_coord) == "1" } {
            #--- Bouton MATCH avec entry inactif
            $frm.but_match configure -text "$caption(ouranoscom,match)" -width 8 -state disabled \
               -command { ::OuranosCom::match_ouranos }
            update
         }
         #--- Effacement du contenu des labels et des entry
         set confTel(ouranos,match_ra)  ""
         set confTel(ouranos,match_dec) ""
         destroy $frm.match_ra
         destroy $frm.match_dec
         destroy $frm.match_ra_entry
         destroy $frm.match_dec_entry
         if { ( $confTel(ouranos,show_coord) == "1" ) && ( $conf(ouranos,show_coord) == "1" ) } {
            #--- Valeur Dec. en ° ' "
            entry $frm.match_dec_entry -textvariable confTel(ouranos,match_dec) -justify center -width 12
            pack $frm.match_dec_entry -in $frm.frame4 -anchor center -side right -padx 10
            #--- Commentaires Dec.
            label $frm.match_dec -text "$caption(ouranoscom,dec1) $caption(ouranoscom,dms_angle)"
            pack $frm.match_dec -in $frm.frame4 -anchor center -side right -padx 10
            #--- Gestion des evenements Dec.
            bind $frm.match_dec_entry <Enter> { ::confTel::Format_Match_Dec }
            bind $frm.match_dec_entry <Leave> { destroy $audace(base).format_match_dec }
            #--- Valeur AD en h mn s
            entry $frm.match_ra_entry -textvariable confTel(ouranos,match_ra) -justify center -width 12
            pack $frm.match_ra_entry -in $frm.frame4 -anchor center -side right -padx 10
            #--- Commentaires AD
            label $frm.match_ra -text "$caption(ouranoscom,ad1) $caption(ouranoscom,hms_angle)"
            pack $frm.match_ra -in $frm.frame4 -anchor center -side right -padx 10
            #--- Gestion des evenements AD
            bind $frm.match_ra_entry <Enter> { ::confTel::Format_Match_AD }
            bind $frm.match_ra_entry <Leave> { destroy $audace(base).format_match_ad }
         }
         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $frm
         #--- Boutons et radio-boutons inactifs
         $frm.but_init configure -state disabled
         $frm.but_close configure -state disabled
         $frm.but_read configure -state disabled
         $frm.rad0 configure -state disabled
         $frm.rad1 configure -state disabled
         $frm.rad2 configure -state disabled
         $frm.rad3 configure -state disabled
         #--- Effacement des coordonnees AD et Dec.
         set confTel(ouranos,coord_ra)  ""
         set confTel(ouranos,coord_dec) ""
         #--- Effacement des fenetres
         set confTel(ouranos,tjrsvisible) "0"
         if { [ winfo exists $audace(base).tjrsvisible ] } {
            destroy $audace(base).tjrsvisible
         }
         if { [ winfo exists $audace(base).tjrsvisible_x10 ] } {
            destroy $audace(base).tjrsvisible_x10
         }
         #--- Fermeture du port et affichage su status
         tel$audace(telNo) close
         set ouranoscom(tty) ""
         set confTel(ouranos,status) $caption(ouranoscom,off)
         console::affiche_erreur "$caption(ouranoscom,port) ($conf(ouranos,port))\
            $caption(ouranoscom,2points) $caption(ouranoscom,ferme)\n"
      }
      return
   }

   #
   # OuranosCom::no_answer
   # If no answer
   #
   proc no_answer {} {
      global caption

      console::affiche_erreur "$caption(ouranoscom,pas_de_reponse)\n"
      ::OuranosCom::close_com
      return
   }

   #
   # OuranosCom::find_res
   # Find resolution
   #
   proc find_res { } {
      global confTel
      global caption
      global frmm

      catch {
         set frm $frmm(Telscp2)
         #--- Traitement graphique du bouton 'Lire'
         $frm.but_read configure -text "$caption(ouranoscom,lire)" -state disabled
         update
         #--- Traitement graphique du bouton 'Regler'
         $frm.but_init configure -text "$caption(ouranoscom,reglage)" -relief groove -state disabled
         update
         set confTel(ouranos,cod_dec)    "65536"
         set confTel(ouranos,cod_ra)     "65536"
         set confTel(ouranos,init_dec)   "0"
         set confTel(ouranos,init_ra)    "0"
         set confTel(ouranos,init)       "0"
         set confTel(ouranos,inv_dec)    "1"
         set confTel(ouranos,inv_ra)     "1"
         set confTel(ouranos,show_coord) "0"
         ::confTel::MatchOuranos
         set confTel(ouranos,find)       "1"
         ::OuranosCom::send_encod [ format "R%d\t%d\r" $confTel(ouranos,cod_ra) $confTel(ouranos,cod_dec) ]
         ::OuranosCom::send_encod [ format "I%d\t%d\r" $confTel(ouranos,init_ra) $confTel(ouranos,init_dec) ]
         ::OuranosCom::read_coord
      }
      return
   }

   #
   # OuranosCom::TjrsVisible
   # Affichage visible des coordonnees ou des pas
   #
   proc TjrsVisible { } {
      global audace
      global conf
      global confTel
      global caption

      catch {
         if { $confTel(ouranos,tjrsvisible) == "0" } {
            destroy $audace(base).tjrsvisible
         } else {
            if { [ winfo exists $audace(base).tjrsvisible ] } {
               destroy $audace(base).tjrsvisible
            }
            toplevel $audace(base).tjrsvisible
            wm transient $audace(base).tjrsvisible $audace(base)
            wm resizable $audace(base).tjrsvisible 0 0
            wm title $audace(base).tjrsvisible "$caption(ouranoscom,pos_tel)"
            wm protocol $audace(base).tjrsvisible WM_DELETE_WINDOW {
               set confTel(ouranos,tjrsvisible) "0"
               destroy $audace(base).tjrsvisible
            }
            if { [ info exists conf(ouranos,wmgeometry) ] == "1" } {
               wm geometry $audace(base).tjrsvisible $conf(ouranos,wmgeometry)
            } else {
               wm geometry $audace(base).tjrsvisible 200x70+370+375
            }

            #--- Cree l'affichage d'AD et Dec
            label $audace(base).tjrsvisible.lab1 -borderwidth 1 -anchor w
            uplevel #0 { pack $audace(base).tjrsvisible.lab1 -padx 10 -pady 2 }
            label $audace(base).tjrsvisible.lab2 -borderwidth 1 -anchor w
            uplevel #0 { pack $audace(base).tjrsvisible.lab2 -padx 10 -pady 2 }

            #--- Bouton radio x1
            radiobutton $audace(base).tjrsvisible.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -text "$caption(ouranoscom,x1)" -value 0 -variable confTel(ouranos,dim) -command {
                  destroy $audace(base).tjrsvisible_x10 ; ::OuranosCom::TjrsVisible
               }
            uplevel #0 { pack $audace(base).tjrsvisible.rad0 -padx 20 -pady 2 -side left }
            #--- Bouton radio x10
            radiobutton $audace(base).tjrsvisible.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -text "$caption(ouranoscom,x5)" -value 1 -variable confTel(ouranos,dim) -command {
                  destroy $audace(base).tjrsvisible ; ::OuranosCom::TjrsVisible_x10
               }
            uplevel #0 { pack $audace(base).tjrsvisible.rad1 -padx 20 -pady 2 -side right }
            #--- La fenetre est active
            focus $audace(base).tjrsvisible
            #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
            bind $audace(base).tjrsvisible <Key-F1> { $audace(console)::GiveFocus }
         }
         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $audace(base).tjrsvisible
      }
   }

   #
   # OuranosCom::TjrsVisible_x10
   # Affichage visible des coordonnees ou des pas en tres gros
   #
   proc TjrsVisible_x10 { } {
      global audace
      global conf
      global confTel
      global caption

      catch {
         if { $confTel(ouranos,tjrsvisible) == "0" } {
            destroy $audace(base).tjrsvisible_x10
         } else {
            if { [ winfo exists $audace(base).tjrsvisible_x10 ] } {
               destroy $audace(base).tjrsvisible_x10
            }
            toplevel $audace(base).tjrsvisible_x10
            wm transient $audace(base).tjrsvisible_x10 $audace(base)
            wm resizable $audace(base).tjrsvisible_x10 0 0
            wm title $audace(base).tjrsvisible_x10 "$caption(ouranoscom,pos_tel)"
            wm protocol $audace(base).tjrsvisible_x10 WM_DELETE_WINDOW {
               set confTel(ouranos,tjrsvisible) "0"
               destroy $audace(base).tjrsvisible_x10
            }
            if { [ info exists conf(ouranos,x10,wmgeometry) ] == "1" } {
               wm geometry $audace(base).tjrsvisible_x10 $conf(ouranos,x10,wmgeometry)
            } else {
               wm geometry $audace(base).tjrsvisible_x10 850x500+0+0
            }

            #--- Cree l'affichage d'AD et Dec
            label $audace(base).tjrsvisible_x10.lab1 -borderwidth 1 -anchor w -font {verdana 60 bold}
            uplevel #0 { pack $audace(base).tjrsvisible_x10.lab1 -padx 10 -pady 2 }
            label $audace(base).tjrsvisible_x10.lab2 -borderwidth 1 -anchor w -font {verdana 60 bold}
            uplevel #0 { pack $audace(base).tjrsvisible_x10.lab2 -padx 10 -pady 2 }

            #--- Bouton radio x1
            radiobutton $audace(base).tjrsvisible_x10.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -font {verdana 20 bold} -text "$caption(ouranoscom,:5)" -value 0 -variable confTel(ouranos,dim) \
               -command {
                  destroy $audace(base).tjrsvisible_x10 ; ::OuranosCom::TjrsVisible
               }
            uplevel #0 { pack $audace(base).tjrsvisible_x10.rad0 -padx 100 -pady 10 -side left }
            #--- Bouton radio x10
            radiobutton $audace(base).tjrsvisible_x10.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -font {verdana 20 bold} -text "$caption(ouranoscom,x1)" -value 1 -variable confTel(ouranos,dim) \
               -command {
                  destroy $audace(base).tjrsvisible ; ::OuranosCom::TjrsVisible_x10
               }
            uplevel #0 { pack $audace(base).tjrsvisible_x10.rad1 -padx 100 -pady 10 -side right }
            #--- La fenetre est active
            focus $audace(base).tjrsvisible_x10
            #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
            bind $audace(base).tjrsvisible_x10 <Key-F1> { $audace(console)::GiveFocus }
         }
         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $audace(base).tjrsvisible_x10
      }
   }

}

#--- Chargement au demarrage
::OuranosCom::init

