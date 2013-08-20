#
# Fichier : foc_focuser.tcl
# Description : Script de toutes les commandes concernant les focaliseurs
# Auteurs : Alain KLOTZ, Robert DELMAS et Raymond ZACHANTKE
# Mise à jour $Id$
#

namespace eval ::foc {

   #------------------------------------------------------------
   # cmdSpeed
   #
   #------------------------------------------------------------
   proc cmdSpeed { } {
      #--- Commande et gestion de l'erreur
      set catchResult [ catch {
         if { $::panneau(foc,focuser) != "" } {
            ::focus::incrementSpeed $::panneau(foc,focuser) "tool foc"
         }
      } ]
      #--- Traitement de l'erreur
      if { $catchResult == "1" } {
         #--- J'ouvre la fenetre de configuration du focuser
         ::confEqt::run ::panneau(foc,focuser) focuser
         #--- J'arrete les acquisitions continues
         cmdStop
      }
   }

   #------------------------------------------------------------
   # cmdFocus
   #
   #------------------------------------------------------------
   proc cmdFocus { command } {

      #--- Gestion graphique des boutons
      #--   Boutons d'acquisition
      if {$command eq "stop"} {
         ::foc::setAcqState normal
      }  else {
         ::foc::setAcqState disabled
      }
      #--- Commande et gestion de l'erreur
      set catchResult [ catch {
         if { $::panneau(foc,focuser) != "" } {
            ::focus::move $::panneau(foc,focuser) $command
         }
      } ]
      #--- Traitement de l'erreur
      if { $catchResult == "1" } {

         #--- J'ouvre la fenetre de configuration du focuser
         ::confEqt::run ::panneau(foc,focuser) focuser

         #--- J'arrete les acquisitions continues
         ::foc::cmdStop
      }
   }

   #------------------------------------------------------------
   # cmdInitFoc
   #    cmd du bouton 'Initialisation' pour focuseraudecom
   #    seulement
   #------------------------------------------------------------
   proc cmdInitFoc { } {
      variable This
      global audace panneau

      if { [ ::tel::list ] != "" } {
         #--- Gestion graphique du bouton
         $This.fra5.but0 configure -relief groove -text $panneau(foc,initialise)
         update
         #--- Met le compteur de foc a zero et rafraichit les affichages
         ::focus::initPosition $::panneau(foc,focuser)
         set audace(focus,currentFocus) "0"
         $This.fra5.current configure -textvariable audace(focus,currentFocus)
         set audace(focus,targetFocus) ""
         $This.fra5.target configure -textvariable audace(focus,targetFocus)
         update
         #--- Gestion graphique du bouton
         $This.fra5.but0 configure -relief raised -text $panneau(foc,initialise)
         update
      } else {
         ::confTel::run
      }
   }

   #------------------------------------------------------------
   # cmdSeDeplaceA
   #    Affiche la fenetre indiquant les limites du focaliseur
   #    commande du bouton "Aller à" pour focuseraudecom
   # Parametres : Aucun
   # Return : Rien
   #------------------------------------------------------------
   proc cmdSeDeplaceA { } {
      variable This
      global audace panneau

      if { [ ::tel::list ] != "" } {
         if { $audace(focus,targetFocus) != "" } {

            #--- Gestion graphique des boutons
            ::foc::setFocusState goto disabled
            ::foc::setAcqState disabled

            #--- Gestion des limites
            if { $audace(focus,targetFocus) > "32767" } {
               #--- Message au-dela de la limite superieure
               ::foc::limiteFoc
               set audace(focus,targetFocus) ""
               $This.fra5.target configure -textvariable audace(focus,targetFocus)
               update
            } elseif { $audace(focus,targetFocus) < "-32767" } {
               #--- Message au-dela de la limite inferieure
               ::foc::limiteFoc
               set audace(focus,targetFocus) ""
               $This.fra5.target configure -textvariable audace(focus,targetFocus)
               update
            } else {

               #--- Lit la position du compteur de foc
               ::focus::displayCurrentPosition $::panneau(foc,focuser)

               #--- Lance le goto du focaliseur
               ::focus::goto $::panneau(foc,focuser)

               #--- Affiche la position d'arrivee
               $This.fra5.current configure -textvariable audace(focus,currentFocus)
            }

            #--- Gestion graphique des boutons
            ::foc::setFocusState goto normal
            ::foc::setAcqState stop

         }
      } else {
         ::confTel::run
      }
   }

   #------------------------------------------------------------
   # cmdUSB_FocusGoto
   #    Affiche la fenetre indiquant les limites du focaliseur
   #    commande du bouton "Aller à" pour usb_focus
   # Parametres : Aucun
   # Return : Rien
   #------------------------------------------------------------
   proc cmdUSB_FocusGoto { } {
      variable This
      global audace panneau

      if {[::usb_focus::isReady] == 1} {

         #--- Gestion graphique des boutons
         ::foc::setFocusState goto disabled
         ::foc::setAcqState goto disabled
         #--- Gestion des limites
#--   modif RZ
         lassign [::foc::getLimits $::panneau(foc,focuser)] limite1 limite2
#--   fin modif RZ
         if { $audace(focus,targetFocus) > $limite2 } {
            #--- Message au-dela de la limite superieure
            ::foc::limiteFoc
            set audace(focus,targetFocus) ""
            $This.fra5.target configure -textvariable audace(focus,targetFocus)
            update
          } elseif { $audace(focus,targetFocus) < $limite1 } {
            #--- Message au-dela de la limite inferieure
            ::foc::limiteFoc
            set audace(focus,targetFocus) ""
            $This.fra5.target configure -textvariable audace(focus,targetFocus)
            update
          } else {

            #--- Lit la position du compteur de foc
            ::focus::displayCurrentPosition $::panneau(foc,focuser)

            #--- Lance le goto du focaliseur
            ::focus::goto $::panneau(foc,focuser)

            #--- Affiche la position d'arrivee
            $This.fra5.current configure -textvariable audace(focus,currentFocus)
         }
         #--- Gestion graphique des boutons
         ::foc::setFocusState goto normal
         ::foc::setAcqState stop
      } else {
         ::confEqt::run ::confEqt::private(selectedFocuser) focuser "Focaliseur USB_Focus"
      }
   }

   #------------------------------------------------------------
   # setFocusState
   #     gere l'etat des boutons +/-, 'Aller à' et choix du focuser
   #     pour tout type de focuser
   # Parametres : {goto | acq} {normal|disabled}
   # Return : Rien
   #------------------------------------------------------------
   proc setFocusState { op state } {
      variable This

      switch -exact $op {
         goto { #--  Etat lors d'un GOTO
                #--  Etat du bouton 'Aller à'
                if {$state eq "normal"} {
                  $This.fra5.but2 configure -relief raised
                } else {
                  $This.fra5.but2 configure -relief sunken
                }
                #--  Inhibition d +/- et du choix du focuser
                $This.fra3.focuser.list configure -state $state
                $This.fra4.we.canv1PoliceInvariant configure -state $state
                $This.fra4.we.canv2PoliceInvariant configure -state $state
              }
         acq  { #--  Etat lors d'une acquisition
                #--  toutes les commandes existantes, a l'exception du bouton Configurer, sont inhibees
                $This.fra3.focuser.list configure -state $state
                foreach cmd [list fra4.we.canv1PoliceInvariant fra4.we.canv2PoliceInvariant \
                  fra5.but2 fra5.target fra6.start fra6.end fra6.step fra6.repeat] {
                   if {[winfo exists $This.$cmd]} {
                      $This.$cmd configure -state $state
                   }
                }
              }
      }
      update
   }

   #------------------------------------------------------------
   # cmdSeTrouveA (focuseraudecom)
   # Parametres : Aucun
   # Return : Rien
   #------------------------------------------------------------
   proc cmdSeTrouveA { } {
      variable This
      global audace panneau

      if { [ ::tel::list ] != "" } {
         #--- Gestion graphique du bouton
         $This.fra5.but1 configure -relief groove -text $panneau(foc,trouve)
         update
         #--- Lit et affiche la position du compteur de foc
         ::focus::displayCurrentPosition $::panneau(foc,focuser)
         if { $audace(focus,currentFocus) == "" } {
            set audace(focus,currentFocus) "0"
         }
         $This.fra5.current configure -textvariable audace(focus,currentFocus)
         update
         #--- Gestion graphique du bouton
         $This.fra5.but1 configure -relief raised -text $panneau(foc,trouve)
         update
      } else {
         ::confTel::run
      }
   }

   #------------------------------------------------------------
   # dynamicFoc
   #  Calcule et effectue le deplacemnt de focuseraudecom et usb_focus
   # Return : Rien
   #------------------------------------------------------------
   proc dynamicFoc { } {
      global audace caption panneau

      if {[::usb_focus::isReady] ==1 || [::focuseraudecom::isReady] ==1} {
         set activFocuser "1"
      } else {
         set activFocuser "0"
      }

      #--   GOTO si la position de depart n'est pas la position courante
      if {$audace(focus,currentFocus) != $panneau(foc,start)} {

         #--   Fixe la position cible
         set audace(focus,targetFocus) $panneau(foc,start)

         if {$activFocuser ==1} {

            #--   Focuser connecte
            switch -exact $panneau(foc,focuser) {
               focuseraudecom     { ::foc::cmdSeDeplaceA }
               usb_focus          { ::foc::cmdUSB_FocusGoto }
            }

            #--   delai de stabilisation
            after 500

         } else {

            #--- Appel de l'arret du moteur de foc a 100 millisecondes de la fin de pose
            #if { $panneau(foc,focuser) ni [list "$caption(foc,pas_focuser)" ""]} {
            #     set delay 0.100
            #   if { [ expr $panneau(foc,exptime)-$delay ] > "0" } {
            #      set delay [ expr $panneau(foc,exptime)-$delay ]
            #      if { $panneau(foc,focuser) ne "$caption(foc,pas_focuser)" } {
            #        #set audace(after,focstop,id) [ after [ expr int($delay*1000) ] { ::foc::cmdFocus stop } ]
            #      }
            #   }
            #   after 100
            #}

            #--   Focuser simule
            #--   Actualise la position courante
            set audace(focus,targetFocus) $panneau(foc,start)
            after 5000
            set audace(focus,currentFocus) $audace(focus,targetFocus)
         }
      } else {
         set audace(focus,targetFocus) $audace(focus,currentFocus)
      }

      update

      #--   Apres deplacement reel ou simule
      if {$panneau(foc,menu) ne "$caption(foc,centrage)"} {
         #--   En mode Fenetrage
         #--   Calcule la position suivante
         set newPosition [expr { $audace(focus,currentFocus)+$panneau(foc,step) }]
         if {$newPosition <= $panneau(foc,end)} {
            #--   Fixe la prochaine etape avec start
            set panneau(foc,start) $newPosition
         }

         if {$audace(focus,currentFocus) == $panneau(foc,start)} {
            #--   Demande l'arret apres l'acquisition
            set panneau(foc,demande_arret) "1"
         }

      } else {

         #--   Simulation : initialise durant le Centrage
         if {$panneau(foc,simulation) ==1 && $activFocuser ==0} {
            set limite1 0 ; set limite2 65535
            if {$panneau(foc,focuser) eq "focuseraudecom"} {
               set limite1 -32767 ; set limite2 32767
            }
            #--   Fixe les valeurs initiales
            set panneau(foc,start) $limite1
            set panneau(foc,end) $limite2
            set panneau(foc,step) 10000
            set panneau(foc,repeat) 1
         }
      }
      update
   }

   #------------   fenetre affichant les limites  --------------

   #------------------------------------------------------------
   # formatFoc
   #    Affiche la fenetre indiquant les limites du focaliseur
   #    commande specifique a audeCOM et a USB_Focus
   # Parametres : Aucun
   # Return : Rien
   #------------------------------------------------------------
   proc formatFoc { } {
      global audace caption

#--   modif RZ
      #--   definit les limites
      lassign [::foc::getLimits $::panneau(foc,focuser)] limite1 limite2
      #switch -exact $panneau(foc,focuser) {
      #   focuseraudecom     {set limite1 -32767 ; set limite2 32767 }
      #   usb_focus          {set limite1 0      ; set limite2 65535 }
      #}
#--   fin modif RZ

      if [ winfo exists $audace(base).formatfoc ] {
         destroy $audace(base).formatfoc
      }
      toplevel $audace(base).formatfoc
      wm transient $audace(base).formatfoc $audace(base)
      wm title $audace(base).formatfoc "$caption(foc,attention)"
      set posx_formatfoc [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_formatfoc [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $audace(base).formatfoc +[ expr $posx_formatfoc + 150 ]+[ expr $posy_formatfoc + 370 ]
      wm resizable $audace(base).formatfoc 0 0

      #--- Cree l'affichage du message
      label $audace(base).formatfoc.lab -text "[format $caption(foc,formatfoc) $limite1 $limite2]"
      pack $audace(base).formatfoc.lab -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $audace(base).formatfoc

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).formatfoc
   }

   #------------------------------------------------------------
   # limiteFoc
   #    Affiche la fenetre d'erreur en cas de depassement des limites
   #    commande specifique a audeCOM et a USB_Focus
   # Parametres : Aucun
   # Return : Rien
   #------------------------------------------------------------
   proc limiteFoc { } {
      global audace caption

#--   modif RZ
      #--   definit les limites
      lassign [::foc::getLimits $::panneau(foc,focuser)] limite1 limite2
      #switch -exact $panneau(foc,focuser) {
      #   focuseraudecom     {set limite1 -32767 ; set limite2 32767 }
      #   usb_focus          {set limite1 0      ; set limite2 65535 }
      #}
#--   fin modif RZ

      if [ winfo exists $audace(base).limitefoc ] {
         destroy $audace(base).limitefoc
      }
      toplevel $audace(base).limitefoc
      wm transient $audace(base).limitefoc $audace(base)
      wm title $audace(base).limitefoc "$caption(foc,attention)"
      set posx_limitefoc [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_limitefoc [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $audace(base).limitefoc +[ expr $posx_limitefoc + 120 ]+[ expr $posy_limitefoc + 340 ]
      wm resizable $audace(base).limitefoc 0 0

      #--- Cree l'affichage du message
      if { $audace(focus,targetFocus) > "limite2" } {
         set texte [format $caption(foc,limitefoc) $limite2]"
      } elseif { $audace(focus,targetFocus) < "limite1" } {
         set texte [format $caption(foc,limitefoc) $limite2]"
      }
      label $audace(base).limitefoc.lab -text $texte
      pack $audace(base).limitefoc.lab -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $audace(base).limitefoc

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).limitefoc
   }

   #------------------------------------------------------------
   # analyseAuto
   #    Analyse les valeurs start,end, step et nb du programme Auto
   #    Emet un message en cas d'erreur
   # Parametres : Aucun
   # Return : Rien
   #------------------------------------------------------------
   proc analyseAuto { v } {
      global caption panneau

      set err 0
      #--   Verifie qu'il s'agit d'un entier
      if {[string is integer -strict $panneau(foc,$v)] ==0} {
         tk_messageBox -title $caption(foc,attention)\
            -icon error -type ok -message "$caption(foc,errInt) "
         return
      }

      #--   Focuser audecom ou USB_Focus
#--   modif RZ
      lassign [::foc::getLimits $panneau(foc,focuser)] limite1 limite2
      #switch -exact $panneau(foc,focuser) {
      #   focuseraudecom     {set limite1 -32767 ; set limite2 32767 }
      #   usb_focus          {set limite1 0      ; set limite2 65535 }
      #}
#--   fin modif RZ

      switch -exact $v {
         start { if {$panneau(foc,$v) < $limite1 || $panneau(foc,$v) > $limite2} {
                    tk_messageBox -title $caption(foc,attention)\
                       -icon error -type ok -message "$caption(foc,errLim)"
                    return
                 }
               }
         end   { if {$panneau(foc,$v) < $panneau(foc,start) || $panneau(foc,$v) > $limite2} {
                    tk_messageBox -title $caption(foc,attention)\
                       -icon error -type ok -message "$caption(foc,errLim)"
                 }
               }
      }
   }

   #------------------------------------------------------------
   # getLimits
   #    Retourne les positions limites du focuser
   # Parametres : nom du focuser {focuseraudecom | usb_focus}
   # Return : liste des limites
   #------------------------------------------------------------
   proc getLimits { focuser } {

      if {$focuser eq "focuseraudecom"} {
         set limite1 -32767 ; set limite2 32767
      } elseif {$focuser eq "usb_focus"} {
         if {[::usb_focus::isReady] == 1} {
             set limite1 0 ; set limite2 $::usb_focus::widget(maxstep)
         } else {
             set limite1 0 ; set limite2 65535
         }
      }

      return [list $limite1 $limite2]
   }

}

