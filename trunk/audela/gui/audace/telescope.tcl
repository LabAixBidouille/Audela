#
# Fichier : telescope.tcl
# Description : Centralise les commandes de mouvement des telescopes
# Auteur : Michel PUJOL
# Mise a jour $Id: telescope.tcl,v 1.14 2007-12-18 22:32:48 robertdelmas Exp $
#

namespace eval ::telescope {
global audace

   #--- Chargement des captions
   source [ file join $audace(rep_caption) telescope.cap ]

   proc init { } {
      global audace
      global caption

      #---
      set audace(telescope,getra)      "00h00m00"
      set audace(telescope,getdec)     "+00d00m00"
      set audace(telescope,rate)       "1"
      set audace(telescope,labelspeed) "$caption(telescope,interro)"
      set audace(telescope,speed)      "1"
      set audace(telescope,goto)       "0"
      set audace(telescope,inittel)    "$caption(telescope,init)"
      set audace(telescope,controle)   "$caption(telescope,suivi_marche)"
   }

   proc initTel { this visuNo } {
      variable Button_Init
      global conf
      global audace
      global caption

      set Button_Init $this

      set base [ ::confVisu::getBase $visuNo ]

      if [ winfo exists $base.inittel ] {
         destroy $base.inittel
      }

      if { ( $conf(telescope) == "audecom" ) && ( [ ::confTel::isReady ] == 1 ) } {
         #--- Neutralisation du bouton initialisation
         $Button_Init configure -relief groove -state disabled
         #--- Reset position telescope
         tel$audace(telNo) initcoord

         toplevel $base.inittel
         wm transient $base.inittel $base
         wm resizable $base.inittel 0 0
         wm title $base.inittel "$caption(telescope,inittelscp0)"
         set posx_inittel [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
         set posy_inittel [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
         wm geometry $base.inittel +[ expr $posx_inittel + 120 ]+[ expr $posy_inittel + 105 ]

         #--- Cree l'affichage du message
         label $base.inittel.lab1 -text "$caption(telescope,inittelscp1)\n$caption(telescope,inittelscp2)\n \
            $caption(telescope,inittelscp3)\n$caption(telescope,inittelscp4)\n$caption(telescope,inittelscp5)\n \
            $caption(telescope,inittelscp6)\n\n$caption(telescope,inittelscp7)\n$caption(telescope,inittelscp8)\n \
            $caption(telescope,inittelscp9)"
         pack $base.inittel.lab1 -padx 10 -pady 2

         #--- La nouvelle fenetre est active
         focus $base.inittel

         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $base.inittel

         #--- Fermeture de la fenetre
         bind $base.inittel <Destroy> {
            #--- Les coordonnees AD et Dec sont mises a jour a la fermeture de la fenetre
            ::telescope::afficheCoord
            #--- Activation du bouton initialisation
            $::telescope::Button_Init configure -relief raised -state normal
         }

      } else {
         ::confTel::run
         tkwait window $base.confTel
         #--- Activation du bouton initialisation
         $Button_Init configure -relief raised -state normal
      }
      ::telescope::afficheCoord
   }

   #------------------------------------------------------------
   #  match
   #     synchronise le telescope avec les cordonnees radec
   #
   #     si modele = gemini
   #------------------------------------------------------------
   proc match { radec } {
      global conf
      global audace
      global caption

      if { [ ::tel::list ] != "" } {
         if { $conf(telescope) == "lx200" && $conf(lx200,modele) == "$caption(telescope,modele_gemini)" } {
            #--- cas du modele Losmandy Gemini
            set choix [ tk_dialog \
               $audace(base).selectAlign \
               "$caption(telescope,match)" \
               "$caption(telescope,match_confirm)" \
               "" \
               1  \
               "$caption(telescope,match_alg_init)" "$caption(telescope,match_alg_add)" \
               "$caption(telescope,match_cancel)" \
               ]
            if { $choix == "0" } {
               #--- alignement normal
               tel$audace(telNo) radec init $radec
            } elseif { $choix == "1" } {
               #--- alignement additionel pour modele gemini
                tel$audace(telNo) radec init -option additional $radec
            } else {
               #--- rien a faire
            }
         } else {
            #--- cas des autres modeles (lx200, audecom, skysensor, ...)
            set choix [ tk_messageBox -type yesno -icon warning -title "$caption(telescope,match)" \
               -message "$caption(telescope,match_confirm)" ]
            if { $choix == "yes" } {
               tel$audace(telNo) radec init $radec
            }
         }
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
      }
      ::telescope::afficheCoord
   }

   #------------------------------------------------------------
   #  goto
   #     verifie que le telescope possede la fonction goto
   #     envoi l'ordre au telescope de pointer les cordonnees list_radec en mode blocant ou non
   #  return
   #     0 si OK
   #     -1 si erreur (telescope absent)
   #------------------------------------------------------------
   proc goto { list_radec blocking { But_Goto "" } { But_Match "" } } {
      global conf
      global audace
      global caption
      global cataGoto
      global catalogue

      if { ( $conf(telescope) == "audecom" ) && ( [ ::confTel::isReady ] == 1 ) } {
         set audace(telescope,goto) "1"
         #--- Cas particulier du GOTO sur le Soleil et sur la Lune
         #--- Transfere les parametres de derive dans le microcontroleur
         set vit_der_alpha 0; set vit_der_delta 0
         catch {
            if { $catalogue(planete_choisie) == "$caption(telescope,soleil)" } {
               set vit_der_alpha 3548
               set vit_der_delta 0
            } elseif { $catalogue(planete_choisie) == "$caption(telescope,lune)" } {
               set vit_der_alpha 43636
               set vit_der_delta 0
            } else {
               set vit_der_alpha 0
               set vit_der_delta 0
            }
         }
         #--- Precaution pour ne jamais diviser par zero
         if { $vit_der_alpha == "0" } { set vit_der_alpha "1" }
         if { $vit_der_delta == "0" } { set vit_der_delta "1" }
         #--- Calcul de la correction
         set alpha [ expr $conf(audecom,dsuivinom)*1296000/$vit_der_alpha ]
         set alpha [ expr round($alpha) ]
         set delta [ expr $conf(audecom,dsuividelta)*1296000/$vit_der_delta ]
         set delta [ expr round($delta) ]
         #--- Bornage de la correction
         if { $alpha > "99999999" } { set alpha "99999999" }
         if { $alpha < "-99999999" } { set alpha "-99999999" }
         if { $delta > "99999999" } { set delta "99999999" }
         if { $delta < "-99999999" } { set delta "-99999999" }
         #--- Application de la correction solaire/lunaire ou annulation (suivi sideral)
         #--- Arret des moteurs + Application des corrections + Mise en marche des moteurs
         tel$audace(telNo) radec motor off
         tel$audace(telNo) driftspeed $alpha $delta
         tel$audace(telNo) radec motor on
      }
      if { [ ::tel::list ] != "" } {
         #--- Gestion des boutons Goto et Match
         if { $But_Goto != "" } {
            $But_Goto configure -relief groove -state disabled
         }
         if { $But_Match != "" } {
            $But_Match configure -relief raised -state disabled
         }
         update
         #--- Affichage du champ dans une carte. Parametres : nom_objet, ad, dec, zoom_objet, avant_plan
         if { $cataGoto(carte,validation) == "1" } {
            ::carte::gotoObject $cataGoto(carte,nom_objet) $cataGoto(carte,ad) $cataGoto(carte,dec) $cataGoto(carte,zoom_objet) $cataGoto(carte,avant_plan)
         }
         #--- Goto
         tel$audace(telNo) radec goto $list_radec -blocking $blocking
         #--- Boucle tant que le telescope n'est pas arrete
         set audace(telescope,goto) "1"
         set radec0 [ tel$audace(telNo) radec coord ]
         ::telescope::surveille_goto [ list $radec0 ] $But_Goto $But_Match
         #--- j'attends que la variable soit remise a zero
         vwait ::audace(telescope,goto)
         return 0
      } else {
         ::confTel::run
         return -1
      }
   }

   #------------------------------------------------------------
   #  surveille_goto
   #     surveille si la fonction goto est active
   #------------------------------------------------------------
   proc surveille_goto { radec0 { But_Goto "" } { But_Match "" } } {
      global audace

      set radec1 [ tel$audace(telNo) radec coord ]
      ::telescope::afficheCoord
      if { $radec1 != $radec0 } {
         after 1000 ::telescope::surveille_goto [ list $radec1 ] $But_Goto $But_Match
      } else {
         if { $But_Goto != "" } {
            $But_Goto configure -relief raised -state normal
         }
         if { $But_Match != "" } {
            $But_Match configure -relief raised -state normal
         }
         set audace(telescope,goto) "0"
         update
      }
   }

   #------------------------------------------------------------
   #  stopGoto
   #     arrete le mouvement du GOTO
   #------------------------------------------------------------
   proc stopGoto { { Button_Stop "" } } {
      global conf
      global audace

      if { ( $conf(telescope) == "audecom" ) && ( [ ::confTel::isReady ] == 1 ) } {
         #--- Arret d'urgence du pointage et retour a la position au moment de l'action
         tel$audace(telNo) radec stop
         if { $audace(telescope,goto) == "0" } {
            $Button_Stop configure -relief raised -state normal
            update
         }
         set audace(telescope,goto) "0"
      } elseif { [ ::tel::list ] != "" } {
         tel$audace(telNo) radec stop
         set audace(telescope,goto) "0"
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
         catch {
            $Button_Stop configure -relief raised -state normal
            update
         }
      }
      ::telescope::afficheCoord
   }

   #------------------------------------------------------------
   #  getSpeedLabelList
   #     retourne la liste des libelles des  vitesses supportees par le telescope
   #------------------------------------------------------------
   proc getSpeedLabelList { } {
      global conf caption

      if { $conf(telescope) == "audecom" } {
         set speedList "$caption(telescope,x1) $caption(telescope,x5) $caption(telescope,200)"
      } elseif { $conf(telescope) == "temma" } {
         set speedList "$caption(telescope,NS) $caption(telescope,HS)"
      } else {
         set speedList "1 2 3 4"
      }
      return  $speedList
   }


   #------------------------------------------------------------
   #  getSpeedValueList
   #     retourne la liste des valeurs des  vitesses supportees par le telescope
   #------------------------------------------------------------
   proc getSpeedValueList { } {
      global conf caption

      if { $conf(telescope) == "audecom" } {
         set speedList "1 2 3"
      } elseif { $conf(telescope) == "temma" } {
         set speedList "1 2"
      } else {
         set speedList "1 2 3 4"
      }
      return  $speedList
   }

   #------------------------------------------------------------
   #  decodeSpeedDlgShift
   #     decode la vitesse du telescope pour les decalages de l'outil Acquisition
   #------------------------------------------------------------
   proc decodeSpeedDlgShift { } {
      global audace
      global caption
      global conf
      global panneau

      if { [ ::tel::list ] != "" } {
         if { $conf(telescope) == "audecom" } {
            if { $panneau(DlgShift,shiftSpeed) == "$caption(telescope,x1)" } {
               setSpeed "1"
            } elseif { $panneau(DlgShift,shiftSpeed) == "$caption(telescope,x5)" } {
               setSpeed "2"
            } elseif { $panneau(DlgShift,shiftSpeed) == "$caption(telescope,200)" } {
               setSpeed "3"
            }
         } elseif { $conf(telescope) == "lx200" } {
            if { $panneau(DlgShift,shiftSpeed) == "1" } {
               setSpeed "1"
            } elseif { $panneau(DlgShift,shiftSpeed) == "2" } {
               setSpeed "2"
            } elseif { $panneau(DlgShift,shiftSpeed) == "3" } {
               setSpeed "3"
            } elseif { $panneau(DlgShift,shiftSpeed) == "4" } {
               setSpeed "4"
            }
         } elseif { $conf(telescope) == "temma" } {
            if { $panneau(DlgShift,shiftSpeed) == "$caption(telescope,NS)" } {
               setSpeed "1"
            } elseif { $panneau(DlgShift,shiftSpeed) == "$caption(telescope,HS)" } {
               setSpeed "2"
            }
         } else {
            #--- Inactif pour autres telescopes
            setSpeed "0"
         }
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
         set audace(telescope,rate) "0"
      }
   }

   #------------------------------------------------------------
   #  incrementSpeed
   #     incremente la vitesse du telescope
   #     et met la nouvelle valeur dans la variable audace(telescope,speed)
   #------------------------------------------------------------
   proc incrementSpeed { } {
      global conf
      global audace

      if { [ ::tel::list ] != "" } {
         if { $conf(telescope) == "audecom" } {
            #--- Pour audecom, l'increment peut prendre 3 valeurs ( 1 2 3 )
            if { $audace(telescope,speed) == "1" } {
               setSpeed "2"
            } elseif { $audace(telescope,speed) == "2" } {
               setSpeed "3"
            } elseif { $audace(telescope,speed) == "3" } {
               setSpeed "1"
            } else {
               setSpeed "1"
            }
         } elseif { $conf(telescope) == "lx200" } {
            #--- Pour lx200, l'increment peut prendre 4 valeurs ( 1 2 3 4 )
            if { $audace(telescope,speed) == "1" } {
               setSpeed "2"
            } elseif { $audace(telescope,speed) == "2" } {
               setSpeed "3"
            } elseif { $audace(telescope,speed) == "3" } {
               setSpeed "4"
            } elseif { $audace(telescope,speed) == "4" } {
               setSpeed "1"
            } else {
               setSpeed "1"
            }
         } elseif { $conf(telescope) == "temma" } {
            #--- Pour temma, l'increment peut prendre 2 valeurs ( 1 2 )
            if { $audace(telescope,speed) == "1" } {
               setSpeed "2"
            } elseif { $audace(telescope,speed) == "2" } {
               setSpeed "1"
            } else {
               setSpeed "1"
            }
         } elseif { $conf(telescope) == "ascom" } {
            #--- Pour lx200, l'increment peut prendre 4 valeurs ( 1 2 3 4 )
            if { $audace(telescope,speed) == "1" } {
               setSpeed "2"
            } elseif { $audace(telescope,speed) == "2" } {
               setSpeed "3"
            } elseif { $audace(telescope,speed) == "3" } {
               setSpeed "4"
            } elseif { $audace(telescope,speed) == "4" } {
               setSpeed "1"
            } else {
               setSpeed "1"
            }
         } else {
            #--- Inactif pour autres telescopes
            setSpeed "0"
         }
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
         set audace(telescope,rate) "0"
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

      if { [ ::tel::list ] != "" } {
         if { $conf(telescope) == "audecom" } {
            if { $value == "1" } {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "$caption(telescope,x1)"
               set audace(telescope,rate) "0"
               set statustel(speed) "0"
            } elseif { $value == "2" } {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "$caption(telescope,x5)"
               set audace(telescope,rate) "0.5"
               set statustel(speed) "0.33"
            } elseif { $value == "3" } {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "$caption(telescope,200)"
               set audace(telescope,rate) "1"
               set statustel(speed) "0.66"
            } else {
               set audace(telescope,speed) "3"
               set audace(telescope,labelspeed) "$caption(telescope,200)"
               set audace(telescope,rate) "1"
               set statustel(speed) "0.66"
            }
         } elseif { $conf(telescope) == "lx200" } {
            if { $value == "1" } {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "1"
               set audace(telescope,rate) "0"
               set statustel(speed) "0"
               tel$audace(telNo) focus fast
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
               set audace(telescope,labelspeed) "$caption(telescope,NS)"
               set audace(telescope,rate) "0"
               set statustel(speed) "0"
            } elseif { $value == "2" } {
               set audace(telescope,speed) "2"
               set audace(telescope,labelspeed) "$caption(telescope,HS)"
               set audace(telescope,rate) "1"
               set statustel(speed) "1"
            } else {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "$caption(telescope,NS)"
               set audace(telescope,rate) "0"
               set statustel(speed) "0"
            }
         } elseif { $conf(telescope) == "ascom" } {
            if { $value == "1" } {
               set audace(telescope,speed) "1"
               set audace(telescope,labelspeed) "1"
               set audace(telescope,rate) "0"
               set statustel(speed) "0"
               tel$audace(telNo) focus fast
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
         } else {
            set audace(telescope,speed) "1"
            set audace(telescope,labelspeed) "$caption(telescope,interro)"
            set audace(telescope,rate) "0"
            set statustel(speed) "0"
         }
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
         set audace(telescope,rate) "0"
         set statustel(speed) "0"
      }
   }

   #------------------------------------------------------------
   #  possedeControleSuivi
   #     retourne 1 si le telescope possede le controle de suivi
   #     retourne 0 sinon
   #------------------------------------------------------------
   proc possedeControleSuivi { {value " "} } {
      global conf

      if { ( $conf(telescope) == "audecom" )
         || ( ( $conf(telescope) == "temma" ) && ( $conf(temma,modele) == "2" ) ) } {
         set result "1"
      } else {
         set result "0"
      }
      return $result
   }

   #------------------------------------------------------------
   #  controleSuivi
   #     arrete ou met en marche le telescope
   #
   #     met à jour la variable audace(telescope,controle)
   #------------------------------------------------------------
   proc controleSuivi { {value " "} } {
      global conf
      global audace
      global caption

      if { [ ::tel::list ] != "" } {
         if { ( $conf(telescope) == "audecom" ) || ( $conf(telescope) == "temma" ) } {
            if { $value == " " } {
               if { $audace(telescope,controle) == "$caption(telescope,suivi_marche)" } {
                  tel$audace(telNo) radec motor off
                  set audace(telescope,controle) "$caption(telescope,suivi_arret)"
               } elseif { $audace(telescope,controle) == "$caption(telescope,suivi_arret)" } {
                  tel$audace(telNo) radec motor on
                  set audace(telescope,controle) "$caption(telescope,suivi_marche)"
               }
            } else {
               if { $value == "$caption(telescope,suivi_marche)" } {
                  tel$audace(telNo) radec motor off
                  set audace(telescope,controle) "$caption(telescope,suivi_arret)"
               } elseif { $value == "$caption(telescope,suivi_arret)" } {
                  tel$audace(telNo) radec motor on
                  set audace(telescope,controle) "$caption(telescope,suivi_marche)"
               }
            }
         } elseif { ( $conf(telescope) == "temma" ) && \
            ( $audace(telescope,controle) == "$caption(telescope,suivi_marche)" ) } {
            #--- Applique les corrections de la vitesse de suivi en ad et en dec
            if { $conf(temma,type) == "0" } {
               tel$audace(telNo) driftspeed 0 0
               ::console::affiche_resultat "$caption(telescope,mobile_etoile)\n\n"
            } elseif { $conf(temma,type) == "1" } {
               tel$audace(telNo) driftspeed $conf(temma,suivi_ad) $conf(temma,suivi_dec)
               set correction_suivi [ tel$audace(telNo) driftspeed ]
               ::console::affiche_resultat "$caption(telescope,ctl_mobile:)\n"
               ::console::affiche_resultat "$caption(telescope,mobile_ad) $caption(telescope,2points)\
                  [ lindex $correction_suivi 0 ]\n"
               ::console::affiche_resultat "$caption(telescope,mobile_dec) $caption(telescope,2points)\
                  [ lindex $correction_suivi 1 ]\n\n"
            }
         }
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
      }
      ::telescope::afficheCoord
   }

   #------------------------------------------------------------
   #  move
   #     demarre le mouvement dans une direction
   #------------------------------------------------------------
   proc move { direction } {
      variable AfterId
      variable AfterState
      global conf
      global audace

      if { $audace(telNo) != "0" } {
         if { $conf(telescope) == "temma" } {
            set AfterState "1"
            set AfterId [ after 10 ::telescope::nextPulseTemma $direction ]
         } else {
            tel$audace(telNo) radec move $direction $audace(telescope,rate)
         }
      } else {
         ::confTel::run
        # tkwait window $audace(base).confTel
      }
   }

   #------------------------------------------------------------
   #  nextPulseTemma
   #     envoi des pulses des boutons cardinaux de Temma
   #------------------------------------------------------------
   proc nextPulseTemma { direction } {
      variable AfterId
      variable AfterState
      global audace

      if { $AfterState == "1" } {
         tel$audace(telNo) radec move $direction $audace(telescope,rate)
         set AfterId [ after 250 ::telescope::nextPulseTemma $direction ]
      }
   }

   #------------------------------------------------------------
   #  stop
   #     arrete le mouvement dans une direction
   #------------------------------------------------------------
   proc stop { direction } {
      variable AfterId
      variable AfterState
      global conf
      global audace

      if { [ ::tel::list ] != "" } {
         if { $conf(telescope) == "audecom" } {
            tel$audace(telNo) radec stop $direction
            if { $audace(telescope,speed) == "3" } {
               after 3700
            } else {
               ::telescope::Boucle
            }
         } elseif { $conf(telescope) == "lx200" } {
            tel$audace(telNo) radec stop $direction
            if { $conf(lx200,modele) == "AudeCom" } {
               if { ( $audace(telescope,speed) == "3" ) || ( $audace(telescope,speed) == "4" ) } {
                  after 3700
               }
            }
         } elseif { $conf(telescope) == "temma" } {
            set AfterState "0"
            after cancel $AfterId
            tel$audace(telNo) radec stop $direction
         } else {
            tel$audace(telNo) radec stop $direction
         }
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
      }
      ::telescope::afficheCoord
   }

   proc Boucle { } {
      global audace

      #--- Boucle tant que le telescope n'est pas arrete
      set radecB0 [ tel$audace(telNo) radec coord ]
      after 300
      set radecB1 [ tel$audace(telNo) radec coord ]
      while { $radecB0 != $radecB1 } {
         set radecB0 $radecB1
         after 200
         set radecB1 [ tel$audace(telNo) radec coord ]
      }
   }

   #------------------------------------------------------------
   #  afficheCoord
   #     met a jour l'affichage des coordonnees
   #
   #  description : interroge le telescope et met le resultat dans
   #      les variables audace(telescope,getra) et audace(telescope,getdec)
   #------------------------------------------------------------
   proc afficheCoord { } {
      global conf
      global audace
      global caption

      set radec ""

      if { [ ::tel::list ] != "" } {
         if { [ ::telescope::fourniCoord ] != "0" } {
            set radec [ tel$audace(telNo) radec coord ]
            #--- Traitement des coordonnees
            if { $radec == " +" } {
               #--- Cas du cable AudeCom non connecte
               set audace(telescope,getra)  "$caption(telescope,tel)"
               set audace(telescope,getdec) "$caption(telescope,non_connecte)"
            } elseif { [ lindex $radec 0 ] == "tel$audace(telNo)" } {
               set audace(telescope,getra)  "$caption(telescope,astre_est)"
               set audace(telescope,getdec) "$caption(telescope,pas_leve)"
            } else {
               set audace(telescope,getra)  [ lindex $radec 0 ]
               set audace(telescope,getdec) [ lindex $radec 1 ]
               if { $conf(telescope) == "temma" } {
                  #--- Affichage de la position du telescope
                  ::telescope::monture_allemande
               }
            }
         } else {
            set audace(telescope,getra)  "$caption(telescope,pas_coord1)"
            set audace(telescope,getdec) "$caption(telescope,pas_coord2)"
         }
      } else {
         set audace(telescope,getra)  "$caption(telescope,tel)"
         set audace(telescope,getdec) "$caption(telescope,non_connecte)"
      }

      return $radec
   }

   #------------------------------------------------------------
   #  possedeCorrectionRefraction
   #     retourne 1 si le telescope corrige la refraction
   #     retourne 0 sinon
   #------------------------------------------------------------
   proc possedeCorrectionRefraction { } {

      # The telescope mount computes the refraction corrections
      # yes = 1 (case of the Meade LX200, Sky Sensor 2000 PC, Losmandy Gemini or Mel Bartels)
      # no  = 0 (case of the Ouranos, AudeCom or Ite-lente)
      global audace
      global conf
      global caption

      #--- Je verifie si la monture est capable fournir son nom de famille
      set result [ catch { tel$audace(telNo) name } telName ]
      #---
      if { $result == 0 } {
         switch -exact -- $telName {
            LX200       {
                           if { $conf(lx200,modele) == "$caption(telescope,modele_audecom)" } {
                              return 0
                           } elseif { $conf(lx200,modele) == "$caption(telescope,modele_ite-lente)" } {
                              return 0
                           } else {
                              return 1
                           }
                        }
            Ouranos     { return 0 }
            AudeCom     { return 0 }
            Temma       { return 0 }
            ASCOM       { return 0 }
            Celestron   { return 1 }
            default     { return 0 }
         }
      } else {
         return 0
      }
   }

   #------------------------------------------------------------
   #  possedeGoto
   #     retourne 1 si le telescope possede la fonction Goto
   #     retourne 0 sinon
   #------------------------------------------------------------
   proc possedeGoto { } {

      # The telescope mounts have Goto function
      # yes = 1 (onglet LX200, AudeCom, Temma )
      # no  = 0 (onglet Ouranos)
      global conf

      if { [ regexp (lx200|audecom|temma|ascom) $conf(telescope) ] } {
         set result "1"
      } else {
         set result "0"
      }

      return $result
   }

   #------------------------------------------------------------
   #  fourniCoord
   #     retourne 1 si le telescope renvoie des coordonnees
   #     retourne 0 sinon
   #------------------------------------------------------------
   proc fourniCoord { } {

      # The telescope mounts send coordinates
      # yes = 1 (onglet LX200, Ouranos, AudeCom, Temma )
      # no  = 0 (onglet )
      global conf

      if { [ regexp (lx200|ouranos|audecom|temma|ascom) $conf(telescope) ] } {
         set result "1"
      } else {
         set result "0"
      }

      return $result
   }

   #------------------------------------------------------------
   #  monture_allemande
   #------------------------------------------------------------
   proc monture_allemande { } {
      global audace
      global caption

      #--- Position E ou O du telescope sur une monture equatoriale allemande
      set pos_tel [ tel$audace(telNo) german ]
      if { $pos_tel == "E" } {
         set audace(pos_tel_ew) "$caption(telescope,cote_est)"
         set audace(chg_pos_tel) "$caption(telescope,cote_ouest)"
      } elseif { $pos_tel == "W" } {
         set audace(pos_tel_ew) "$caption(telescope,cote_ouest)"
         set audace(chg_pos_tel) "$caption(telescope,cote_est)"
      } else {
         set audace(pos_tel_ew) ""
         set audace(chg_pos_tel) "  ?  "
      }
   }

   #------------------------------------------------------------
   # addSpeedListener
   #    ajoute une procedure a appeler si on change de vitesse
   #  parametres :
   #    cmd : commande TCL a lancer quand la camera change
   #------------------------------------------------------------
   proc addSpeedListener { cmd } {
      trace add variable "::audace(telescope,speed)" write $cmd
   }

   #------------------------------------------------------------
   # removeSpeedListener
   #    supprime une procedure a appeler si on change de vitesse
   #  parametres :
   #    cmd : commande TCL a lancer quand la camera change
   #------------------------------------------------------------
   proc removeSpeedListener { cmd } {
      trace remove variable "::audace(telescope,speed)" write $cmd
   }

}

::telescope::init

