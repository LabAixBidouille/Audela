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
      variable This

      #--- Gestion graphique des boutons
      $This.fra4.we.canv1PoliceInvariant configure -relief ridge
      $This.fra4.we.canv2PoliceInvariant configure -relief ridge
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
         cmdStop
      }
   }

   #------------------------------------------------------------
   # cmdInitFoc
   #    cmd du bouton 'Initialisation'
   #------------------------------------------------------------
   proc cmdInitFoc { } {
      variable This
      global audace panneau

      if { [ ::tel::list ] != "" } {
         #--- Gestion graphique du bouton
         $This.fra5.but3 configure -relief groove -text $panneau(foc,initialise)
         update
         #--- Met le compteur de foc a zero et rafraichit les affichages
         ::focus::initPosition $::panneau(foc,focuser)
         set audace(focus,currentFocus) "0"
         $This.fra5.fra1.lab1 configure -textvariable audace(focus,currentFocus)
         set audace(focus,targetFocus) ""
         $This.fra5.fra2.ent3 configure -textvariable audace(focus,targetFocus)
         update
         #--- Gestion graphique du bouton
         $This.fra5.but3 configure -relief raised -text $panneau(foc,initialise)
         update
      } else {
         ::confTel::run
      }
   }

   #------------------------------------------------------------
   # cmdSeDeplaceA
   #    Affiche la fenetre indiquant les limites du focaliseur
   #    commande du bouton "Aller à" (focuseraudecom et usb_focus)
   # Parametres : Aucun
   # Return : Rien
   #------------------------------------------------------------
   proc cmdSeDeplaceA { } {
      variable This
      global audace panneau

      if { [ ::tel::list ] != "" } {
         if { $audace(focus,targetFocus) != "" } {
            #--- Gestion graphique des boutons
            $This.fra5.but3 configure -relief groove -state disabled
            $This.fra5.but2 configure -relief groove -text $panneau(foc,deplace)
            update
            #--- Gestion des limites
            if { $audace(focus,targetFocus) > "32767" } {
               #--- Message au-dela de la limite superieure
               ::foc::limiteFoc
               set audace(focus,targetFocus) ""
               $This.fra5.fra2.ent3 configure -textvariable audace(focus,targetFocus)
               update
            } elseif { $audace(focus,targetFocus) < "-32767" } {
               #--- Message au-dela de la limite inferieure
               ::foc::limiteFoc
               set audace(focus,targetFocus) ""
               $This.fra5.fra2.ent3 configure -textvariable audace(focus,targetFocus)
               update
            } else {
               #--- Lit la position du compteur de foc
               ::focus::displayCurrentPosition $::panneau(foc,focuser)
               #--- Lance le goto du focaliseur
               ::focus::goto $::panneau(foc,focuser)
               #--- Affiche la position d'arrivee
               $This.fra5.fra1.lab1 configure -textvariable audace(focus,currentFocus)
            }
            #--- Gestion graphique des boutons
            $This.fra5.but2 configure -relief raised -text $panneau(foc,deplace)
            $This.fra5.but3 configure -relief raised -state normal
            update
         }
      } else {
         ::confTel::run
      }
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
         $This.fra5.fra1.lab1 configure -textvariable audace(focus,currentFocus)
         update
         #--- Gestion graphique du bouton
         $This.fra5.but1 configure -relief raised -text $panneau(foc,trouve)
         update
      } else {
         ::confTel::run
      }
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

      #--   definit les limites
      switch -exact $::panneau(foc,focuser) {
         focuseraudecom     {set limite1 -32767 ; set limite2 32767 }
         usb_focus          {set limite1 0      ; set limite2 65535 }
      }

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

      #--   definit les limites
      switch -exact $::panneau(foc,focuser) {
         focuseraudecom     {set limite1 -32767 ; set limite2 32767 }
         usb_focus          {set limite1 0      ; set limite2 65535 }
      }

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

}

