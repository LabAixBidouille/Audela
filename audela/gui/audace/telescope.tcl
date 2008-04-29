#
# Fichier : telescope.tcl
# Description : Centralise les commandes de mouvement des montures
# Auteur : Michel PUJOL
# Mise a jour $Id: telescope.tcl,v 1.25 2008-04-29 17:40:52 michelpujol Exp $
#

namespace eval ::telescope {
}

#------------------------------------------------------------
# init
#    Chargement des captions et initialisation de variables
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::init { } {
   global audace caption

   #--- Chargement des captions
   source [ file join $audace(rep_caption) telescope.cap ]

   #--- Initialisation
   set audace(telescope,getra)         "00h00m00"
   set audace(telescope,getdec)        "+00d00m00"
   set audace(telescope,targetRa)      "00h00m00"
   set audace(telescope,targetDec)     "+00d00m00"
   set audace(telescope,targetname)    ""
   set audace(telescope,targetEquinox) "J2000"
   set audace(telescope,rate)          "1"
   set audace(telescope,labelspeed)    "$caption(telescope,interro)"
   set audace(telescope,speed)         "1"
   set audace(telescope,goto)          "0"
   set audace(telescope,inittel)       "$caption(telescope,init)"
   set audace(telescope,controle)      "$caption(telescope,suivi_marche)"
}

#------------------------------------------------------------
# initTel
#    Initialisation du pointage en AD et en Dec de la monture AudeCom
#
# Parametres :
#    this   : Widget du bouton dedie
#    visuNo : Numero de la visu
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::initTel { this visuNo } {
   variable Button_Init
   global audace caption conf

   set Button_Init $this

   set base [ ::confVisu::getBase $visuNo ]

   if { ( $conf(telescope) == "audecom" ) && ( [ ::confTel::isReady ] == 1 ) } {
      #--- Neutralisation du bouton initialisation
      $Button_Init configure -relief groove -state disabled
      #--- Reset position de la monture
      tel$audace(telNo) initcoord
      #--- Creation d'une fenetre Toplevel
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
         if { [ winfo exists $::telescope::Button_Init ] } {
            $::telescope::Button_Init configure -relief raised -state normal
         }
      }
   } else {
      ::confTel::run
      tkwait window $base.confTel
      #--- Activation du bouton initialisation
      $Button_Init configure -relief raised -state normal
   }
   #--- Les coordonnees AD et Dec sont mises a jour
   afficheCoord
}

#------------------------------------------------------------
# match
#    Synchronise la monture avec la liste de coordonnees radec
#
#    Si modele = gemini, propose un alignement additionnel
#    Sinon sur un seul objet
#
# Parametres :
#    radec : Liste des coordonnees AD et Dec a pointer
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::match { radec { radecEquinox "J2000" } } {
   variable private
   global audace caption conf

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
            #--- Cas de la monture principale
            tel$audace(telNo) radec init $radec
            #--- Si Ouranos est une monture secondaire, envoie egalement le Match a l'interface Ouranos
            set secondaryTelNo [ getSecondaryTelNo ]
            if { $secondaryTelNo != "0" } {
               tel$secondaryTelNo radec init $radec
            }
         }
      }
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
   }
   afficheCoord
}

#------------------------------------------------------------
# goto
#    Verifie que la monture possede la fonction goto
#    Envoie l'ordre a la monture de pointer les coordonnees list_radec en mode blocant ou non
#
# Parametres :
#    list_radec   : Liste des coordonnees AD et Dec a pointer
#    blocking     : Mode blocant (1) ou non (0)
#    But_Goto     : Widget du bouton Goto (optionnel)
#    But_Match    : Widget du bouton Match (optionnel)
#    objectName   : Nom de l'objet (optionnel)
#    radecEquinox : Equinoxe des coordonnees de l'objet (optionnel)
# Return :
#    0 si OK
#    -1 si erreur (monture absente)
#------------------------------------------------------------
proc ::telescope::goto { list_radec blocking { But_Goto "" } { But_Match "" } { objectName "" } { radecEquinox "J2000" } } {
   global audace caption cataGoto catalogue conf

   if { [ ::tel::list ] != "" } {
      set audace(telescope,targetRa)      [lindex $list_radec 0]
      set audace(telescope,targetDec)     [lindex $list_radec 1]
      set audace(telescope,targetname)    $objectName
      set audace(telescope,targetEquinox) $radecEquinox
      #---
      setTrackSpeed
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
      #--- Cas d'un Goto avec rattrapage des jeux
      set audace(telescope,stopgoto) "0"
      if { [ ::confTel::getPluginProperty backlash ] == "1" } {
         #--- Goto
         tel$audace(telNo) radec goto $list_radec -blocking $blocking -backlash 1
         #--- Boucle tant que la monture n'est pas arretee
         set audace(telescope,goto) "1"
         set radec0 [ tel$audace(telNo) radec coord ]
         surveille_goto [ list $radec0 ] $But_Goto $But_Match
         #--- j'attends que la variable soit remise a zero
         vwait ::audace(telescope,goto)
         #--- je traite le mode slewpath (si long, je passe en short pour le rattrapage des jeux)
         slewpathLong2Short
      }
      #---
      if { $audace(telescope,stopgoto) == "1" } {
         return 0
      }
      #--- Goto
      tel$audace(telNo) radec goto $list_radec -blocking $blocking
      #--- Boucle tant que la monture n'est pas arretee
      set audace(telescope,goto) "1"
      set radec0 [ tel$audace(telNo) radec coord ]
      surveille_goto [ list $radec0 ] $But_Goto $But_Match
      #--- j'attends que la variable soit remise a zero
      vwait ::audace(telescope,goto)
      #--- je restaure le mode slewpath si necessaire
      slewpathShort2Long
      return 0
   } else {
      ::confTel::run
      return -1
   }
}

#------------------------------------------------------------
# surveille_goto
#    Surveille si la fonction goto est active
#
# Parametres :
#    radec0    : Liste des coordonnees AD et Dec de l'objet
#    But_Goto  : Widget du bouton Goto (optionnel)
#    But_Match : Widget du bouton Match (optionnel)
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::surveille_goto { radec0 { But_Goto "" } { But_Match "" } } {
   global audace

   set radec1 [ tel$audace(telNo) radec coord ]
   afficheCoord
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
# stopGoto
#    Arrete le mouvement du GOTO
#
# Parametres :
#    Button_Stop : Widget du bouton Stop Goto (optionnel)
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::stopGoto { { Button_Stop "" } } {
   global audace conf

   set audace(telescope,stopgoto) "1"
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
   afficheCoord
}

#------------------------------------------------------------
# getSpeedLabelList
#    Retourne la liste des libelles des vitesses supportees par la monture
#
# Parametres :
#    Aucun
# Return :
#    La liste des libelles des vitesses supportees par la monture
#------------------------------------------------------------
proc ::telescope::getSpeedLabelList { } {
   global caption conf

   if { $conf(telescope) == "audecom" } {
      set speedList "$caption(telescope,x1) $caption(telescope,x5) $caption(telescope,200)"
   } elseif { $conf(telescope) == "temma" } {
      set speedList "$caption(telescope,NS) $caption(telescope,HS)"
   } else {
      set speedList "1 2 3 4"
   }
   return $speedList
}

#------------------------------------------------------------
# getSpeedValueList
#    Retourne la liste des valeurs des vitesses supportees par la monture
#
# Parametres :
#    Aucun
# Return :
#    La liste des valeurs des vitesses supportees par la monture
#------------------------------------------------------------
proc ::telescope::getSpeedValueList { } {
   global caption conf

   if { $conf(telescope) == "audecom" } {
      set speedList "1 2 3"
   } elseif { $conf(telescope) == "temma" } {
      set speedList "1 2"
   } else {
      set speedList "1 2 3 4"
   }
   return $speedList
}

#------------------------------------------------------------
# decodeSpeedDlgShift
#    Decode la vitesse de la monture pour les decalages de l'outil Acquisition
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::decodeSpeedDlgShift { } {
   global audace caption conf panneau

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
# decodeSpeedDlgShiftVideo
#    Decode la vitesse de la monture pour les decalages de l'outil Acquisition Video
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::decodeSpeedDlgShiftVideo { } {
   global audace caption conf panneau

   if { [ ::tel::list ] != "" } {
      if { $conf(telescope) == "audecom" } {
         if { $panneau(DlgShiftVideo,shiftSpeed) == "$caption(telescope,x1)" } {
            setSpeed "1"
         } elseif { $panneau(DlgShiftVideo,shiftSpeed) == "$caption(telescope,x5)" } {
            setSpeed "2"
         } elseif { $panneau(DlgShiftVideo,shiftSpeed) == "$caption(telescope,200)" } {
            setSpeed "3"
         }
      } elseif { $conf(telescope) == "lx200" } {
         if { $panneau(DlgShiftVideo,shiftSpeed) == "1" } {
            setSpeed "1"
         } elseif { $panneau(DlgShiftVideo,shiftSpeed) == "2" } {
            setSpeed "2"
         } elseif { $panneau(DlgShiftVideo,shiftSpeed) == "3" } {
            setSpeed "3"
         } elseif { $panneau(DlgShiftVideo,shiftSpeed) == "4" } {
            setSpeed "4"
         }
      } elseif { $conf(telescope) == "temma" } {
         if { $panneau(DlgShiftVideo,shiftSpeed) == "$caption(telescope,NS)" } {
            setSpeed "1"
         } elseif { $panneau(DlgShiftVideo,shiftSpeed) == "$caption(telescope,HS)" } {
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
# incrementSpeed
#    Incremente la vitesse de la monture
#    Met la nouvelle valeur dans la variable audace(telescope,speed)
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::incrementSpeed { } {
   global audace conf

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
         #--- Inactif pour les autres montures
         setSpeed "0"
      }
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
      set audace(telescope,rate) "0"
   }
}

#------------------------------------------------------------
# setSpeed
#    Change la vitesse de la monture
#    Met a jour les variables audace(telescope,speed), audace(telescope,labelspeed),
#    audace(telescope,rate), statustel(speed)
#
# Parametres :
#    value : Vitesse de la monture (optionnel)
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::setSpeed { { value "2" } } {
   global audace caption conf statustel

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
# controleSuivi
#    Arrete ou met en marche la monture
#    Met à jour la variable audace(telescope,controle)
#
# Parametres :
#    value : Marche (Suivi on) ou arret (Suivi off) du suivi (optionnel)
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::controleSuivi { { value " " } } {
   global audace caption conf

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
   afficheCoord
}

#------------------------------------------------------------
# move
#    Demarre le mouvement dans une direction
#
# Parametres :
#    direction : Direction du deplacement (n, s, e ou w)
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::move { direction } {
   variable AfterId
   variable AfterState
   global audace conf

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
# nextPulseTemma
#    Envoie des pulses des boutons cardinaux pour Temma
#
# Parametres :
#    direction : Direction du deplacement (n, s, e ou w)
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::nextPulseTemma { direction } {
   variable AfterId
   variable AfterState
   global audace

   if { $AfterState == "1" } {
      tel$audace(telNo) radec move $direction $audace(telescope,rate)
      set AfterId [ after 250 ::telescope::nextPulseTemma $direction ]
   }
}

#------------------------------------------------------------
# stop
#    Arrete le mouvement dans une direction
#
# Parametres :
#    direction : Direction du deplacement (n, s, e ou w)
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::stop { direction } {
   variable AfterId
   variable AfterState
   global audace conf

   if { [ ::tel::list ] != "" } {
      if { $conf(telescope) == "audecom" } {
         tel$audace(telNo) radec stop $direction
         if { $audace(telescope,speed) == "3" } {
            after 3700
         } else {
            Boucle
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
   afficheCoord
}

#------------------------------------------------------------
# Boucle
#    Boucle tant que la monture n'est pas arretee
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::Boucle { } {
   global audace

   #--- Boucle tant que la monture n'est pas arretee
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
# afficheCoord
#    Met a jour l'affichage des coordonnees
#    Interroge la monture et met le resultat dans
#    les variables audace(telescope,getra) et audace(telescope,getdec)
#
# Parametres :
#    Aucun
# Return :
#    radec : Liste des coordonnees AD et Dec a pointer
#------------------------------------------------------------
proc ::telescope::afficheCoord { } {
   global audace caption conf

   set radec ""

   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty hasCoordinates ] == "1" } {
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
               #--- Affichage de la position du telescope sur la monture equatoriale allemande
               monture_allemande
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
# monture_allemande
#    Permet d'initialiser la position du telescope sur la monture
#    Le tube optique est a l'est ou a l'ouest de la monture
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::monture_allemande { } {
   global audace caption

   #--- Position E ou O du telescope sur la monture equatoriale allemande
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
# getSecondaryTelNo
#    Retourne le numero de la monture secondaire, sinon retourne "0"
#
# Parametres :
#    Aucun
# Return :
#    result : Le numero de la monture secondaire
#------------------------------------------------------------
proc ::telescope::getSecondaryTelNo { } {
   global conf

   if { [ ::confTel::getPluginProperty multiMount ] == "1" } {
      set result [ ::$conf(telescope)::getSecondaryTelNo ]
   } else {
      set result "0"
   }
   return $result
}

#------------------------------------------------------------
# slewpathLong2Short
#    Commute le mode slewpath de long a short
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::slewpathLong2Short { } {
   global conf

   if { [ info command ::$conf(telescope)::slewpathLong2Short ] != "" } {
      ::$conf(telescope)::slewpathLong2Short
   }
}

#------------------------------------------------------------
# slewpathShort2Long
#    Commute le mode slewpath de short a long
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::slewpathShort2Long { } {
   global conf

   if { [ info command ::$conf(telescope)::slewpathShort2Long ] != "" } {
      ::$conf(telescope)::slewpathShort2Long
   }
}

#------------------------------------------------------------
# setTrackSpeed
#    Parametre la vitesse de suivi pour le Soleil ou la Lune
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::setTrackSpeed { } {
   global conf

   if { [ info command ::$conf(telescope)::setTrackSpeed ] != "" } {
      ::$conf(telescope)::setTrackSpeed
   }
}

#------------------------------------------------------------
# addSpeedListener
#    Ajoute une procedure a appeler si on change de vitesse
#
# Parametres :
#    cmd : Commande TCL a lancer quand la camera change
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::addSpeedListener { cmd } {
   trace add variable "::audace(telescope,speed)" write $cmd
}

#------------------------------------------------------------
# removeSpeedListener
#    supprime une procedure a appeler si on change de vitesse
#
#  Parametres :
#    cmd : Commande TCL a lancer quand la camera change
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::removeSpeedListener { cmd } {
   trace remove variable "::audace(telescope,speed)" write $cmd
}

#------------------------------------------------------------
# getTargetRa
#    Retourne l'ascension droite de l'objet cible
#
# Parametres :
#    Aucun
# Return :
#    Ascension droite
#------------------------------------------------------------
proc ::telescope::getTargetRa { } {
   global audace

   return $audace(telescope,targetRa)
}

#------------------------------------------------------------
# getTargetDec
#    Retourne la declinaison de l'objet cible
#
# Parametres :
#    Aucun
# Return :
#    Declinaison
#------------------------------------------------------------
proc ::telescope::getTargetDec { } {
   global audace

   return $audace(telescope,targetDec)
}

#------------------------------------------------------------
# getTargetName
#    Retourne le nom de l'objet cible
#
# Parametres :
#    Aucun
# Return :
#    Nom de l'objet cible
#------------------------------------------------------------
proc ::telescope::getTargetName { } {
   global audace

   return $audace(telescope,targetname)
}

#------------------------------------------------------------
# getTargetEquinox
#    retourne l'equinoxe des coordonnees de l'objet cible
#
# Parametres :
#    Aucun
# Return :
#    Nom de l'objet cible
#------------------------------------------------------------
proc ::telescope::getTargetEquinox { } {
   global audace

   return $audace(telescope,targetEquinox)
}

#------------------------------------------------------------
# moveTelescope
#    Deplace le telescope pendant un duree determinee
#    Le deplacement est interrompu si private(acquisitionState)!=1
#
# Parametres :
#    alphaDirection : Direction (e, w, n, ou s) du movement en AD
#    alphaDelay     : Duree du deplacement en milliseconde (nombre entier) en AD
#    deltaDirection : Direction (e, w, n, ou s) du movement en Dec
#    deltaDelay     : Duree du deplacement en milliseconde (nombre entier) en Dec
# Return :
#    Rien
#------------------------------------------------------------
proc ::telescope::moveTelescope { alphaDirection alphaDelay deltaDirection deltaDelay } {
   variable private
   global audace

   set private(acquisitionState) 1

   #--- laisse la main pour traiter une eventuelle demande d'arret
   update

   #--- je demarre le deplacement alpha
   tel$audace(telNo) radec move $alphaDirection $audace(telescope,rate)
   #--- j'attend l'expiration du delai par tranche de 1 seconde
   set delay $alphaDelay
   while { $delay > 0 } {
      if { $private(acquisitionState) == 1 } {
         if { $delay > 1000 } {
            after 999
            set delay [expr $delay - 1000 ]
         } else {
            after $delay
            set delay 0
         }
      } else {
         #--- j'interromp l'attente s'il y a une demande d'arret
         set delay 0
      }
   }
   #--- j'arrete le deplacement alpha
   tel$audace(telNo) radec stop $alphaDirection

   #--- laisse la main pour traiter une eventuelle demande d'arret
   update
   #--- je demarre le deplacement delta
   tel$audace(telNo) radec move $deltaDirection $audace(telescope,rate))
   #--- j'attend l'expiration du delai par tranche de 1 seconde
   set delay $deltaDelay
   while { $delay > 0 } {
      if { $private(acquisitionState) == 1 } {
         if { $delay > 10000 } {
            after 9990
            set delay [expr $delay - 10000 ]
         } else {
            after $delay
            set delay 0
         }
      } else {
         #--- j'interromp l'attente s'il y a une demande d'arret
         set delay 0
      }
   }
   #--- j'arrete le deplacement delta
   tel$audace(telNo) radec stop $deltaDirection
}

::telescope::init

