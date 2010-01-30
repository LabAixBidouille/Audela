#
# Fichier : rmtctrltel.tcl
# Description : Script pour le controle de la monture
# Auteur : Raymond ZACHANTKE
# Mise a jour $Id: rmtctrltel.tcl,v 1.1 2010-01-30 14:48:43 robertdelmas Exp $
#

   proc fillTelPanel { } {
      global audace panneau caption
      variable This

      set panneau(remotectrl,after)     "200"
      set panneau(remotectrl,menu)      "$caption(remotectrl,coord)"
      set panneau(remotectrl,nomObjet)  ""
      set panneau(remotectrl,equinox)   ""
      #--- Coordonnees J2000.0 de M104
      set panneau(remotectrl,getobj)    "12h40m0 -11d37m22"
      #---
      set panneau(remotectrl,goto)      "$caption(remotectrl,goto)"
      set panneau(remotectrl,match)     "$caption(remotectrl,match)"
      #---
      set audace(focus,speed)           "1"

      #--- Frame du pointage
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Frame pour choisir un catalogue
         ::cataGoto::createFrameCatalogue $This.fra2.catalogue $panneau(remotectrl,getobj) 1 "::remotectrl"
         pack $This.fra2.catalogue -in $This.fra2 -anchor nw -side top -padx 4 -pady 1

         #--- Label de l'objet choisi
         label $This.fra2.lab1 -textvariable panneau(remotectrl,nomObjet) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -padx 2 -pady 1

         #--- Entry pour l'objet a entrer
         entry $This.fra2.ent1 -textvariable panneau(remotectrl,getobj) -width 14 -relief groove
         pack $This.fra2.ent1 -in $This.fra2 -anchor center -pady 2

         #--- Bouton GOTO
         button $This.fra2.but1 -borderwidth 2 -text $panneau(remotectrl,goto) -command { ::remotectrl::cmdGoto }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill x -ipadx 15 -ipady 3

      pack $This.fra2 -side top -fill x

      bind $This.fra2.but1 <ButtonRelease-3> { ::remotectrl::cmdMatch }

      #--- Frame des coordonnees
      frame $This.fra3 -borderwidth 1 -relief groove

         set panneau(remotectrl,getra)  " "
         set panneau(remotectrl,getdec) " "

         #--- Label pour RA
         label $This.fra3.ent1 -text $panneau(remotectrl,getra) -relief flat
         pack $This.fra3.ent1 -in $This.fra3 -anchor center -fill none -pady 0

         #--- Label pour DEC
         label $This.fra3.ent2 -text $panneau(remotectrl,getdec) -relief flat
         pack $This.fra3.ent2 -in $This.fra3 -anchor center -fill none -pady 1

      pack $This.fra3 -side top -fill x

      set zone(radec) $This.fra3
      bind $zone(radec) <ButtonPress-1>      { ::remotectrl::cmdAfficheCoord0 }
      bind $zone(radec).ent1 <ButtonPress-1> { ::remotectrl::cmdAfficheCoord0 }
      bind $zone(radec).ent2 <ButtonPress-1> { ::remotectrl::cmdAfficheCoord0 }

      #--- Frame des boutons manuels
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Create frame of delay
         frame $This.fra4.after -width 27 -borderwidth 0 -relief flat

            #--- Write the label delay
            label $This.fra4.after.lab -text " $caption(remotectrl,delay)" -borderwidth 0 -relief flat
            pack $This.fra4.after.lab -in $This.fra4.after -side left

            #--- Write the entry
            entry $This.fra4.after.entry -textvariable panneau(remotectrl,after) \
               -relief groove -width 4 -justify center
            pack $This.fra4.after.entry -in $This.fra4.after -side left -padx 0

            #--- Write the label milliseconds
            label $This.fra4.after.ms -text "$caption(remotectrl,ms)" -borderwidth 0 -relief flat
            pack $This.fra4.after.ms -in $This.fra4.after -side left

         pack $This.fra4.after -in $This.fra4 -side top -fill x -pady 1

         #--- Create the button 'E'
         frame $This.fra4.e -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.e -in $This.fra4 -side left -expand true -fill y
         #--- Button-design 'E'
         button $This.fra4.e.canv1PoliceInvariant -borderwidth 2 \
            -text "$caption(remotectrl,est)" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.fra4.e.canv1PoliceInvariant -in $This.fra4.e -expand 1

         #--- Create the buttons 'N S'
         frame $This.fra4.ns -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.ns -in $This.fra4 -side left -expand true -fill y
         #--- Button-design 'N'
         button $This.fra4.ns.canv1PoliceInvariant -borderwidth 2 \
            -text "$caption(remotectrl,nord)" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.fra4.ns.canv1PoliceInvariant -in $This.fra4.ns -expand 1 -side top

         #--- Write the label of moves speed
         label $This.fra4.ns.labPoliceInvariant \
            -textvariable audace(telescope,labelspeed) -borderwidth 0 -relief flat
         pack $This.fra4.ns.labPoliceInvariant -in $This.fra4.ns -expand 0 -side top -pady 6

         #--- Button-design 'S'
         button $This.fra4.ns.canv2PoliceInvariant -borderwidth 2 \
            -text "$caption(remotectrl,sud)" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.fra4.ns.canv2PoliceInvariant -in $This.fra4.ns -expand 1 -side bottom

         #--- Create the button 'W'
         frame $This.fra4.w -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.w -in $This.fra4 -side left -expand true -fill y
         #--- Button-design 'W'
         button $This.fra4.w.canv1PoliceInvariant -borderwidth 2 \
            -text "$caption(remotectrl,ouest)" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.fra4.w.canv1PoliceInvariant -in $This.fra4.w -expand 1

         set zone(e) $This.fra4.e.canv1PoliceInvariant
         set zone(n) $This.fra4.ns.canv1PoliceInvariant
         set zone(s) $This.fra4.ns.canv2PoliceInvariant
         set zone(w) $This.fra4.w.canv1PoliceInvariant

      pack $This.fra4 -side top -fill x

      #--- Cardinal speed
      bind $This.fra4.ns.labPoliceInvariant <ButtonPress-1> { ::remotectrl::cmdSpeed }

      #--- Cardinal moves
      bind $zone(e) <ButtonRelease-1> { catch { ::remotectrl::cmdPulse e } }
      bind $zone(w) <ButtonRelease-1> { catch { ::remotectrl::cmdPulse w } }
      bind $zone(s) <ButtonRelease-1> { catch { ::remotectrl::cmdPulse s } }
      bind $zone(n) <ButtonRelease-1> { catch { ::remotectrl::cmdPulse n } }

      #--- Frame des boutons manuels
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Create the button '+'
         frame $This.fra5.e -width 27 -borderwidth 0 -relief flat
         pack $This.fra5.e -in $This.fra5 -side left -expand true -fill y
         #--- Button-design '+'
         button $This.fra5.e.canv1PoliceInvariant -borderwidth 2 \
            -text "+" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.fra5.e.canv1PoliceInvariant -in $This.fra5.e -expand 1

         #--- Create the button focus speed
         frame $This.fra5.speed -width 27 -borderwidth 0 -relief flat
         pack $This.fra5.speed -in $This.fra5 -side left -expand true -fill y
         #--- Write the label of focus speed
         label $This.fra5.speed.labPoliceInvariant \
            -textvariable audace(focus,labelspeed) -borderwidth 0 -relief flat
         pack $This.fra5.speed.labPoliceInvariant -in $This.fra5.speed -expand 0 -side top -pady 6

         #--- Create the button '-'
         frame $This.fra5.w -width 27 -borderwidth 0 -relief flat
         pack $This.fra5.w -in $This.fra5 -side left -expand true -fill y
         #--- Button-design '-'
         button $This.fra5.w.canv1PoliceInvariant -borderwidth 2 \
            -text "-" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.fra5.w.canv1PoliceInvariant -in $This.fra5.w -expand 1

         set zone(+) $This.fra5.e.canv1PoliceInvariant
         set zone(-) $This.fra5.w.canv1PoliceInvariant

      pack $This.fra5 -side top -fill x

      #--- Foc speed
      bind $This.fra5.speed.labPoliceInvariant <ButtonPress-1> { ::remotectrl::cmdFocusSpeed }

      #--- Foc moves
      bind $zone(+) <ButtonRelease-1> { catch { ::remotectrl::cmdPulseFoc + } }
      bind $zone(-) <ButtonRelease-1> { catch { ::remotectrl::cmdPulseFoc - } }
  }

   proc cmdGoto { } {
      variable This
      global conf
      global audace
      global panneau
      global caption
      global catalogue

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         $This.fra2.but1 configure -relief groove -state disabled
         update
         #--- Cas particulier si le premier pointage est en mode coordonnees
         if { $panneau(remotectrl,menu) == "$caption(remotectrl,coord)" } {
            set panneau(remotectrl,list_radec) $panneau(remotectrl,getobj)
         }
         #--- Debut modif reseau
         set message "send \{tel\$audace(telNo) radec goto \{[ list [lindex $panneau(remotectrl,list_radec) 0] [lindex $panneau(remotectrl,list_radec) 1] ]\}\}"
         eval $message
         #--- Fin modif reseau
         $This.fra2.but1 configure -relief raised -state normal
         update
      } else {
         #--- Affiche un message de non connexion du telescope
         set panneau(remotectrl,getra)  "$caption(remotectrl,tel)"
         set panneau(remotectrl,getdec) "$caption(remotectrl,non_connecte)"
         $This.fra3.ent1 configure -text $panneau(remotectrl,getra)
         $This.fra3.ent2 configure -text $panneau(remotectrl,getdec)
         update
      }
      ::remotectrl::cmdAfficheCoord
   }

   proc setRaDec { 1 listRaDec nomObjet equinox magnitude } {
      global panneau

      set panneau(remotectrl,getobj)       $listRaDec
      set panneau(remotectrl,nomObjet)     $nomObjet
      set panneau(remotectrl,equinoxObjet) $equinox
   }

   proc cmdSpeed { { value " " } } {
      global audace

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
         #--- Fin modif reseau

         #--- Incremente la valeur et met à jour les raquettes et les outils locaux
         ::remotectrl::incrementSpeed

         #--- Met à jour les raquettes et les outils distants
         set message "send \{::remotectrl::setSpeed $audace(telescope,speed)\}"
         eval $message

      } else {
         console::affiche_erreur "cmdSpeed erreur"
      }
      update
      return
   }

   proc cmdFocusSpeed { { value " " } } {
      global audace

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
         #--- Fin modif reseau

         #--- Incremente la valeur et met à jour les raquettes et les outils locaux
         ::remotectrl::incrementFocusSpeed

         #--- Met à jour les raquettes et les outils distants
         set message "send \{::remotectrl::setFocusSpeed $audace(focus,speed)\}"
         eval $message

      } else {
         console::affiche_erreur "cmdSpeed erreur"
      }
      update
      return
   }

   #------------------------------------------------------------
   #  incrementSpeed
   #     incremente la vitesse du telescope
   #     et met la nouvelle valeur dans la variable audace(telescope,speed)
   #------------------------------------------------------------
   proc incrementSpeed { } {
      global conf
      global audace

      if {[eval "send \{::tel::list\}"]!=""} {
         if { $conf(telescope) == "audecom" } {
            #--- Pour audecom, l'increment peut prendre 3 valeurs ( 1 2 3 )
            if { $audace(telescope,speed) == "1" } {
               ::remotectrl::setSpeed "2"
            } elseif { $audace(telescope,speed) == "2" } {
               ::remotectrl::setSpeed "3"
            } elseif { $audace(telescope,speed) == "3" } {
               ::remotectrl::setSpeed "1"
            } else {
               ::remotectrl::setSpeed "1"
            }
         } elseif { $conf(telescope) == "lx200" } {
            #--- Pour lx200, l'increment peut prendre 4 valeurs ( 1 2 3 4 )
            if { $audace(telescope,speed) == "1" } {
               ::remotectrl::setSpeed "2"
            } elseif { $audace(telescope,speed) == "2" } {
               ::remotectrl::setSpeed "3"
            } elseif { $audace(telescope,speed) == "3" } {
               ::remotectrl::setSpeed "4"
            } elseif { $audace(telescope,speed) == "4" } {
               ::remotectrl::setSpeed "1"
            } else {
               ::remotectrl::setSpeed "1"
            }
         } elseif { $conf(telescope) == "temma" } {
            #--- Pour temma, l'increment peut prendre 2 valeurs ( 1 2 )
            if { $audace(telescope,speed) == "1" } {
               ::remotectrl::setSpeed "2"
            } elseif { $audace(telescope,speed) == "2" } {
               ::remotectrl::setSpeed "1"
            } else {
               ::remotectrl::setSpeed "1"
            }
         } else {
            #--- Inactif pour autres telescopes
            ::remotectrl::setSpeed "0"
         }
      }
   }

   #------------------------------------------------------------
   #  incrementFocusSpeed
   #     incremente la vitesse du focaliseur
   #     et met la nouvelle valeur dans la variable audace(focus,speed)
   #------------------------------------------------------------
   proc incrementFocusSpeed { } {
      global conf
      global audace

      if {[eval "send \{::tel::list\}"]!=""} {
         if { $conf(telescope) == "audecom" } {
            #--- Pour audecom, l'increment peut prendre 2 valeurs ( 1 2 )
            if { $audace(focus,speed) == "1" } {
               ::remotectrl::setFocusSpeed "2"
            } elseif { $audace(focus,speed) == "2" } {
               ::remotectrl::setFocusSpeed "1"
            } else {
               ::remotectrl::setFocusSpeed "1"
            }
         } elseif { $conf(telescope) == "lx200" } {
            #--- Pour lx200, l'increment peut prendre 2 valeurs ( 1 2 )
            if { $audace(focus,speed) == "1" } {
               ::remotectrl::setFocusSpeed "2"
            } elseif { $audace(focus,speed) == "2" } {
               ::remotectrl::setFocusSpeed "1"
            } else {
               ::remotectrl::setFocusSpeed "1"
            }
         } else {
            #--- Inactif pour autres telescopes
            ::remotectrl::setFocusSpeed "0"
         }
      }
   }

   #------------------------------------------------------------
   #  setSpeed
   #     change la vitesse du telescope
   #
   #     met a jour les variables audace(telescope,speed), audace(telescope,labelspeed),
   #     audace(telescope,rate), statustel(speed)
   #------------------------------------------------------------
   proc setSpeed { { value "2" } } {
      global conf
      global audace
      global caption
      global statustel

      if { $conf(telescope) == "audecom" } {
         if { $value == "1" } {
            set audace(telescope,speed) "1"
            set audace(telescope,labelspeed) "$caption(remotectrl,x1)"
            set audace(telescope,rate) "0"
            set statustel(speed) "0"
         } elseif { $value == "2" } {
            set audace(telescope,speed) "2"
            set audace(telescope,labelspeed) "$caption(remotectrl,x5)"
            set audace(telescope,rate) "0.5"
            set statustel(speed) "0.33"
         } elseif { $value == "3" } {
            set audace(telescope,speed) "3"
            set audace(telescope,labelspeed) "$caption(remotectrl,200)"
            set audace(telescope,rate) "1"
            set statustel(speed) "0.66"
         } else {
            set audace(telescope,speed) "3"
            set audace(telescope,labelspeed) "$caption(remotectrl,200)"
            set audace(telescope,rate) "1"
            set statustel(speed) "0.66"
         }
      } elseif { $conf(telescope) == "lx200" } {
         if { $value == "1" } {
            set audace(telescope,speed) "1"
            set audace(telescope,labelspeed) "1"
            set audace(telescope,rate) "0"
            set statustel(speed) "0"
         } elseif { $value == "2" } {
            set audace(telescope,speed) "2"
            set audace(telescope,labelspeed) "2"
            set audace(telescope,rate) "0.33"
            set statustel(speed) "0.33"
         } elseif { $value == "3" } {
            set audace(telescope,speed) "3"
            set audace(telescope,labelspeed) "3"
            set audace(telescope,rate) "0.66"
            set statustel(speed) "0.66"
         } elseif { $value == "4" } {
            set audace(telescope,speed) "4"
            set audace(telescope,labelspeed) "4"
            set audace(telescope,rate) "1"
            set statustel(speed) "1"
         } else {
            set audace(telescope,speed) "1"
            set audace(telescope,labelspeed) "1"
            set audace(telescope,rate) "0"
            set statustel(speed) "0"
         }
      } elseif { $conf(telescope) == "temma" } {
         if { $value == "1" } {
            set audace(telescope,speed) "1"
            set audace(telescope,labelspeed) "$caption(remotectrl,NS)"
            set audace(telescope,rate) "0"
            set statustel(speed) "0"
         } elseif { $value == "2" } {
            set audace(telescope,speed) "2"
            set audace(telescope,labelspeed) "$caption(remotectrl,HS)"
            set audace(telescope,rate) "1"
            set statustel(speed) "1"
         } else {
            set audace(telescope,speed) "1"
            set audace(telescope,labelspeed) "$caption(remotectrl,NS)"
            set audace(telescope,rate) "0"
            set statustel(speed) "0"
         }
      } else {
         set audace(telescope,speed) "1"
         set audace(telescope,labelspeed) "$caption(remotectrl,interro)"
         set audace(telescope,rate) "0"
         set statustel(speed) "0"
      }
   }

   #------------------------------------------------------------
   #  setFocusSpeed
   #     change la vitesse du focaliseur
   #
   #     met a jour les variables audace(focus,speed), audace(focus,labelspeed),
   #     audace(focus,rate), statustel(speed)
   #------------------------------------------------------------
   proc setFocusSpeed { { value "2" } } {
      global conf
      global audace
      global caption
      global statustel

      if { $conf(telescope) == "audecom" } {
         if { $value == "1" } {
            set audace(focus,speed) "1"
            set audace(focus,labelspeed) "$caption(remotectrl,x1)"
            set audace(focus,rate) "0"
            set statustel(speed) "0"
         } elseif { $value == "2" } {
            set audace(focus,speed) "2"
            set audace(focus,labelspeed) "$caption(remotectrl,x5)"
            set audace(focus,rate) "1"
            set statustel(speed) "0.33"
         } else {
            set audace(focus,speed) "2"
            set audace(focus,labelspeed) "$caption(remotectrl,x5)"
            set audace(focus,rate) "1"
            set statustel(speed) "0.33"
         }
      } elseif { $conf(telescope) == "lx200" } {
         if { $value == "1" } {
            set audace(focus,speed) "1"
            set audace(focus,labelspeed) "1"
            set audace(focus,rate) "0"
            set statustel(speed) "0"
         } elseif { $value == "2" } {
            set audace(focus,speed) "2"
            set audace(focus,labelspeed) "2"
            set audace(focus,rate) "1"
            set statustel(speed) "0.33"
         } else {
            set audace(focus,speed) "1"
            set audace(focus,labelspeed) "1"
            set audace(focus,rate) "0"
            set statustel(speed) "0"
         }
      } else {
         set audace(focus,speed) "1"
         set audace(focus,labelspeed) "$caption(remotectrl,interro)"
         set audace(focus,rate) "0"
         set statustel(speed) "0"
      }
   }

   proc cmdPulse { direction } {
      variable This
      global audace
      global caption
      global panneau

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         set delay [expr int($panneau(remotectrl,after))]
         if {$delay<=0} {
            return
         }
         if {$delay>=120000} {
            set delay 120000
         }
         #--- Debut modif reseau
         set message "send \{tel\$audace(telNo) radec move $direction $audace(telescope,rate)\; after $delay; tel\$audace(telNo) radec stop $direction\}"
         eval $message
         #--- Fin modif reseau
      } else {
         #--- Affiche un message de non connexion du telescope
         set panneau(remotectrl,getra)  "$caption(remotectrl,tel)"
         set panneau(remotectrl,getdec) "$caption(remotectrl,non_connecte)"
         $This.fra3.ent1 configure -text $panneau(remotectrl,getra)
         $This.fra3.ent2 configure -text $panneau(remotectrl,getdec)
         update
      }
      ::remotectrl::cmdAfficheCoord
   }

   proc cmdStop { direction } {
      global conf
      global audace

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         #--- Debut modif reseau
         set message "send \{tel\$audace(telNo) radec stop $direction\}"
         eval $message
         #--- Fin modif reseau
         if { $conf(telescope) == "audecom" } {
            if { $audace(telescope,speed) == "3" } {
               after 3700
            } else {
               ::remotectrl::cmdBoucle
            }
         } elseif { $conf(telescope) == "lx200" } {
            if { $conf(lx200,modele) == "AudeCom" } {
               if { ( $audace(telescope,speed) == "3" ) || ( $audace(telescope,speed) == "4" ) } {
                  after 3700
               }
            }
         }
      }
      ::remotectrl::cmdAfficheCoord
   }

   proc cmdBoucle { } {
      global audace

      #--- Boucle tant que le telescope n'est pas arrete
      #--- Debut modif reseau
      set message "send \{tel\$audace(telNo) radec coord\}"
      set radecB0 [eval $message]
      #--- Fin modif reseau
      after 300
      #--- Debut modif reseau
      set message "send \{tel\$audace(telNo) radec coord\}"
      set radecB1 [eval $message]
      #--- Fin modif reseau
      while { $radecB0 != $radecB1 } {
         set radecB0 $radecB1
         after 200
         #--- Debut modif reseau
         set message "send \{tel\$audace(telNo) radec coord\}"
         set radecB1 [eval $message]
         #--- Fin modif reseau
      }
   }

   proc cmdPulseFoc { direction } {
      variable This
      global audace
      global caption
      global panneau

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         set delay [expr int($panneau(remotectrl,after))]
         if {$delay<=0} {
            return
         }
         if {$delay>=120000} {
            set delay 120000
         }
         #--- Debut modif reseau
         set message "send \{tel\$audace(telNo) focus move $direction $audace(focus,rate)\; after $delay; tel\$audace(telNo) focus stop\}"
         eval $message
         #--- Fin modif reseau
      } else {
         #--- Affiche un message de non connexion du telescope
         set panneau(remotectrl,getra)  "$caption(remotectrl,tel)"
         set panneau(remotectrl,getdec) "$caption(remotectrl,non_connecte)"
         $This.fra3.ent1 configure -text $panneau(remotectrl,getra)
         $This.fra3.ent2 configure -text $panneau(remotectrl,getdec)
         update
      }
   }

   proc cmdMatch { } {
      global audace
      global caption
      global panneau

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         set choix [ tk_messageBox -type yesno -icon warning -title "$caption(remotectrl,match)" \
            -message "$caption(remotectrl,match_confirm)" ]
         if { $choix == "yes" } {
            #--- Debut modif reseau
            set message "send \{tel\$audace(telNo) radec init \{$panneau(remotectrl,getobj)\}\}"
            eval $message
            #--- Fin modif reseau
         }
      }
      ::remotectrl::cmdAfficheCoord
   }

   proc cmdAfficheCoord0 { } {
      ::remotectrl::cmdAfficheCoord
   }

   proc cmdAfficheCoord { } {
      variable This
      global audace
      global caption
      global panneau

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         #--- Debut modif reseau
         set message "send \{tel\$audace(telNo) radec coord\}"
         set radec [eval $message]
         ::console::affiche_resultat "<radec=$radec>\n"
         #--- Fin modif reseau
         #--- Debut modif reseau
         set message [eval "send \{tel\$audace(telNo) radec coord\}"]
         if {[lindex $radec 0]=="$message"} {
            set panneau(remotectrl,getra)  "$caption(remotectrl,astre_est)"
            set panneau(remotectrl,getdec) "$caption(remotectrl,pas_leve)"
         } else {
            set panneau(remotectrl,getra)  [lindex $radec 0]
            set panneau(remotectrl,getdec) [lindex $radec 1]
         }
         #--- Fin modif reseau
      } else {
         set panneau(remotectrl,getra)  "$caption(remotectrl,tel)"
         set panneau(remotectrl,getdec) "$caption(remotectrl,non_connecte)"
      }
      $This.fra3.ent1 configure -text $panneau(remotectrl,getra)
      $This.fra3.ent2 configure -text $panneau(remotectrl,getdec)
      update
      ::telescope::afficheCoord
      #--- Debut modif reseau
      set message "send \{::telescope::afficheCoord\}"
      set radec [eval $message]
      #--- Fin modif reseau
   }

