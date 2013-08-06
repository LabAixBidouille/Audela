#
# Fichier : foc_cam.tcl
# Description : Script de toutes les commandes concernant l'acquisition
# Auteurs : Alain KLOTZ, Robert DELMAS et Raymond ZACHANTKE
# Mise à jour $Id$
#

namespace eval ::foc {

   #------------------------------------------------------------
   # cmdGo
   #    lance le processus d'acquisition
   #------------------------------------------------------------
   proc cmdGo { } {
      variable This
      global audace caption panneau

      #--   Raccourcis
      set visuNo $audace(visuNo)

      #---
      if { [ ::cam::list ] != "" || [ ::cam::list ] == "" && $panneau(foc,simulation) ==1} {

         #--- Gestion graphique des boutons
         ::foc::setFocusState acq disabled
         ::foc::setAcqState centrage

         #--  la variable panneau(foc,actuel) n'existe que si on a fait le Centrage
         #--  Force Centrage si l'utilisateur a selectionne fenetrage avant Centrage
         if { [ info exists panneau(foc,actuel) ] == "0" } {
            $This.fra2.optionmenu1.menu invoke 0
         }

         if { $panneau(foc,menu) eq "$caption(foc,centrage)" } {

            #--- Mode Centrage
            ::foc::centrage
            set panneau(foc,actuel) "$panneau(foc,menu)"
            set panneau(foc,boucle) "$caption(foc,off)"

         } else {

            #--- Mode Fenetrage
            set binWindow $panneau(foc,window)
            set binBox [foc::fenetrage]
            if {$binBox ==0} { return }
            set panneau(foc,actuel) "$panneau(foc,menu)"
            set panneau(foc,boucle) "$caption(foc,on)"
            ::foc::selectGraph $binBox $binWindow

            #--- Suppression de la zone selectionnee avec la souris
            ::confVisu::deleteBox $visuNo
            #--- Suppression l'image
            ::confVisu::clear $visuNo
         }

         if {$panneau(foc,simulation) == 0} {

            #--   S'informe si la cam a le windowing
            set panneau(foc,hasWindow) [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] hasWindow ]
            #--- Fenetrage sur la cam si elle camera possede le mode fenetrage (pas APN et ni WebCam)
            if {$panneau(foc,hasWindow) == "1"} {
               cam$audace(camNo) window $panneau(foc,window)
            }
            #--- Appel a la fonction d'acquisition
            ::foc::cmdAcq

            #--- Gestion graphique des boutons
            ::foc::setAcqState post

         } else {

            #--   Simulation

            #--   Decoche l'affichage de l'avancement
            set panneau(foc,avancement_acq) 0
            update

            if { $panneau(foc,menu) eq "$caption(foc,centrage)" } {
               ::foc::createImage $panneau(foc,bin) 21 $panneau(foc,exptime)
               #--- Gestion graphique des boutons
               ::foc::setAcqState post
            } else {
               ::foc::simule
                #--- Gestion graphique des boutons
                ::foc::setFocusState acq normal
                ::foc::setAcqState stop
            }
         }

      } else {
         #--   Pas de camera connectee : ouvre le panneau de selection de la camera
         ::confCam::run
      }
   }

   #------------------------------------------------------------
   # centrage
   #     Configure les variables pour le Centrage
   # Return : Rien
   #------------------------------------------------------------
   proc centrage { } {
      global audace panneau

      if {$panneau(foc,simulation) == 0} {

         #--- Applique le binning demande si la camera possede bien ce binning
         set binningCamera "2x2"
         if { [ lsearch [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningList ] $binningCamera ] != "-1" } {
            set panneau(foc,bin) "2"
         } else {
            set panneau(foc,bin) "1"
         }
         set panneau(foc,bin_centrage) "$panneau(foc,bin)"
         lassign [ cam$audace(camNo) nbcells ] naxis1 naxis2
         set panneau(foc,window)       [ list 1 1 $naxis1 $naxis1 ]

      } else {

         #--   Mode simulation de camera
         set panneau(foc,bin) "2"
         set panneau(foc,bin_centrage) "$panneau(foc,bin)"
         #--   attention moitie de naxis1 et naxis2 du fait du binning
         set panneau(foc,window) [ list 1 1 384  256 ]
      }
   }

   #------------------------------------------------------------
   # fenetrage
   #     Configure les variables pour le Fenetrage
   # Return : 0 si erreur
   #------------------------------------------------------------
   proc fenetrage { } {
      global audace caption panneau

      if { $panneau(foc,menu) eq "$caption(foc,fenetre_auto)"} {

         #--   Fenetrage automatique

         #--   Coordonnees de l'étoile dans l'image binnee
         #--   attention si l'image est plate x=naxis1 et y=naxis2
         lassign [ ::prtr::searchMax $panneau(foc,window) $audace(bufNo) ] x y

         #--   Calcule auto des cordonnees de la fenetre dans l'image binnee
         set a [expr { int(round($x)-40) }]
         set b [expr { int(round($y)-40) }]
         set c [expr { int(round($x)+40) }]
         set d [expr { int(round($y)+40) }]
         set binBox [list $a $b $c $d]

         #--   Visualise la boite durant 3 secondes
         ::confVisu::setBox $audace(visuNo) $binBox
         after 3000

      } else {

         #--   Fenetrage manuel

         #--   Identifie la fenetre dans l'image binnee
         set binBox [ ::confVisu::getBox $audace(visuNo) ]
         if {$binBox eq ""} {
            tk_messageBox -title $caption(foc,attention)\
               -icon error -type ok -message "$caption(foc,erreur)"
            ::foc::setAcqState stop
            return 0
         }

      }

      #--   Recalcule les coordonnees dans l'image non binnee
      set panneau(foc,bin) "1"
      lassign $binBox a b c d
      #--   Verifie que la selection existe
      if {$a ne ""} {
         set x1 [expr { $panneau(foc,bin_centrage)*$a }]
         set y1 [expr { $panneau(foc,bin_centrage)*$b }]
         set x2 [expr { $panneau(foc,bin_centrage)*$c }]
         set y2 [expr { $panneau(foc,bin_centrage)*$d }]

         #--   Definit le fenetrage dans l'image non binnee
         set panneau(foc,window) [list $x1 $y1 $x2 $y2]

         #--   Calcule la taille de la fenetre a partir de ses coordonnees en tenant compte du binning
         set naxis1Fen [expr { ($x2-$x1+1)*$panneau(foc,bin_centrage) }]
         set naxis2Fen [expr { ($y2-$y1+1)*$panneau(foc,bin_centrage) }]
         set panneau(foc,box) [list 1 1 $naxis1Fen $naxis2Fen]
      }

      return $binBox
   }

   #------------------------------------------------------------
   # selectGraph
   #     Ouvre le graphique adhoc s'il n'existe pas deja
   # parametres : coordonnees de la boite et dimensions de l'image
   # Return : Rien
   #------------------------------------------------------------
   proc selectGraph { binBox binWindow } {
      global audace caption panneau

      if { $panneau(foc,typefocuser) == "0" && [winfo exists $audace(base).visufoc] ==0} {

         #--   Lance le graphique normal
         ::foc::focGraphe

         #--   Finalise la ligne de titre du fichier log
         append panneau(foc,fichier) "\n"

     } elseif { $panneau(foc,typefocuser) == "1" && [winfo exists $audace(base).visuhfd] ==0} {

         #--   Lance le graphique HFD
         ::foc::HFDGraphe

         #--   Photocentre dans la fenetre binnee
         lassign [buf$audace(bufNo) centro $binBox] xstar ystar

         #--   Dimensions de l'image binnee
         lassign $binWindow -> -> naxis1 naxis2

         #--   Centre l'etoile si l'image est plate
         if {$xstar == $naxis1 && $ystar == $naxis2} {
            set xstar [expr { $naxis1/2 }]
            set ystar [expr { $naxis2/2 }]
         }

         #--   Dessine le schema etoile/image a partir de l'image binnee
         ::foc::updateLocator $naxis1 $naxis2 $xstar $ystar

         #--   Finalise la ligne de titre  du fichier log
         append panneau(foc,fichier) "$caption(foc,hfd)\t${caption(foc,pos_focus)}\n"
      }
   }

   #------------------------------------------------------------
   # cmdAcq
   #    lance une acquisition
   #------------------------------------------------------------
   proc cmdAcq { } {
      variable This
      global audace conf caption panneau

      #--- Initialisation d'une variable
      set panneau(foc,finAquisition) ""

      #--- Pose en cours
      set panneau(foc,pose_en_cours) "1"

      #--- La commande bin permet de fixer le binning
      cam$audace(camNo) bin [ list $panneau(foc,bin) $panneau(foc,bin) ]

      #--- Cas des petites poses : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
      if { $panneau(foc,exptime) >= "0" && $panneau(foc,exptime) < "1" } {
         ::foc::avancementPose 0
      }

      #--- Alarme sonore de fin de pose
      ::camera::alarmeSonore $panneau(foc,exptime)

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

      #--- Declenchement de l'acquisition
      ::camera::acquisition [ ::confVisu::getCamItem $audace(visuNo) ] "::foc::attendImage" $panneau(foc,exptime)

      #--- Je lance la boucle d'affichage du decompte
      after 10 ::foc::dispTime

      #--- J'attends la fin de l'acquisition
      vwait panneau(foc,finAquisition)

      #--- Informations sur l'image fenetree
      if { $panneau(foc,actuel) ne "$caption(foc,centrage)" } {
         if { $panneau(foc,boucle) == "$caption(foc,on)" } {
            ::foc::updateValues
            after idle ::foc::cmdAcq
         }
      }

      #--- Pose en cours
      set panneau(foc,pose_en_cours) "0"

      #--- Demande d'arret de la pose
      set panneau(foc,demande_arret) "0"

      #--- Effacement de la barre de progression quand la pose est terminee
      ::foc::avancementPose -1
   }

   #------------------------------------------------------------
   # updateValues
   #     Met a jour les graphiques
   # Return : Rien
   # Durée : < 250 ms
   #------------------------------------------------------------
   proc updateValues { } {
      global audace panneau

      set bufNo $audace(bufNo)

      #--- Fenetrage sur le buffer si la camera ne possede pas le mode fenetrage (APN et WebCam)
      if {$panneau(foc,hasWindow) == "0"} {
         buf$bufNo window $panneau(foc,window)
         ::confVisu::autovisu $audace(visuNo)
      }

      #--- Gestion graphique des boutons
      ::foc::setAcqState window

      incr panneau(foc,compteur)

      #--   Normalise le fond du ciel
      buf$bufNo noffset 0

      if {$panneau(foc,typefocuser) == "1"} {
         ::foc::extractBiny $audace(bufNo)
      }

      #--- Statistiques
      set s [ stat ]
      set maxi [ lindex $s 2 ]
      set fond [ lindex $s 7 ]
      set contr [ format "%.0f" [ expr -1.*[ lindex $s 8 ] ] ]
      set inten [ format "%.0f" [ expr $maxi-$fond ] ]
      #--- Fwhm
      lassign [ buf$bufNo fwhm $panneau(foc,box) ] fwhmx fwhmy
      #--- Valeurs a l'ecran
      ::foc::qualiteFoc $inten $fwhmx $fwhmy $contr
      update

      #--  Traitement differentie selon focuser
      if { $panneau(foc,typefocuser) == "0"} {
         #--   Mise a jour des graphiques
         ::foc::updateFocGraphe [list $panneau(foc,compteur) $inten $fwhmx $fwhmy $contr]
         #--- Actualise les donnees pour le fichier log
         append panneau(foc,fichier) "$inten\t$fwhmx\t$fwhmy\t$contr\n"
      } else {
         #--   Calculs et Mise a jour des graphiques (le temps de traitement double)
         ::foc::processHFD
         #--- Actualise les donnees pour le fichier log
         append panneau(foc,fichier) "$inten\t$fwhmx\t$fwhmy\t$contr\t$panneau(foc,hfd)\t$audace(focus,currentFocus)\n"
      }
   }

   #------------------------------------------------------------
   # attendImage
   #    sous processus de cmdAcq
   #------------------------------------------------------------
   proc attendImage { message args } {
      global audace panneau

      #::console::affiche_resultat "message = $message args = $args\n"

      switch $message {
         "autovisu" {
            #--- ce message signale que l'image est prete dans le buffer
            #--- on peut l'afficher sans attendre la fin complete de la thread de la camera
            ::confVisu::autovisu $audace(visuNo)
         }
         "acquisitionResult" {
            #--- ce message signale que la thread de la camera a termine completement l'acquisition
            #--- je peux traiter l'image
            set panneau(foc,finAquisition) "acquisitionResult"
         }
         "error" {
            #--- ce message signale qu'une erreur est survenue dans la thread de la camera
            #--- j'affiche l'erreur dans la console
            ::console::affiche_erreur "foc::cmdAcq error: $args\n"
            set panneau(foc,finAquisition) "error"
         }
      }
   }

   #------------------------------------------------------------
   # dispTime
   #    compte a rebours du temps d'exposition
   #------------------------------------------------------------
   proc dispTime { } {
      global audace panneau

      #--- J'arrete le timer s'il est deja lance
      if { [info exists panneau(foc,dispTimeAfterId)] && $panneau(foc,dispTimeAfterId)!="" } {
         after cancel $panneau(foc,dispTimeAfterId)
         set panneau(foc,dispTimeAfterId) ""
      }

      #--- Je mets a jour la fenetre de progression
      set t [cam$audace(camNo) timer -1 ]
      ::foc::avancementPose $t

      if { $t > 0 } {
         #--- Je lance l'iteration suivante avec un delai de 1000 millisecondes
         #--- (mode asynchone pour eviter l'empilement des appels recursifs)
         set panneau(foc,dispTimeAfterId) [ after 1000 ::foc::dispTime ]
      } else {
         #--- Je ne relance pas le timer
         set panneau(foc,dispTimeAfterId) ""
      }
   }

   #------------------------------------------------------------
   # cmdStop
   #    cmd du bouton STOP/RAZ
   #------------------------------------------------------------
   proc cmdStop { } {
      variable This
      global audace caption panneau

      if { [ ::cam::list ] != "" } {
         if { [ $This.fra2.but2 cget -text ] == "$panneau(foc,raz)" } {
            set panneau(foc,compteur) "0"
            closeAllWindows $audace(base)
            #--   Destruction et reconstruction des graphiques
            if { $panneau(foc,typefocuser) == "0"} {
               ::foc::focGraphe
            } else {
               ::foc::HFDGraphe
            }
         } else {
            #--- Je positionne l'indicateur d'arret de la pose
            set panneau(foc,demande_arret) "1"
            #--- On annule l'identificateur qui arrete le moteur de foc
            catch { after cancel $audace(after,focstop,id) }
            #--- Graphiques du panneau
            set panneau(foc,boucle) "$caption(foc,off)"
            #--- Annulation de l'alarme de fin de pose
            catch { after cancel bell }
            #--- Arret de la capture de l'image
            ::camera::stopAcquisition [ ::confVisu::getCamItem $audace(visuNo) ]
            #--- Sauvegarde du fichier des traces
            ::foc::cmdSauveLog foc.log
            #--- J'attends la fin de l'acquisition
            vwait panneau(foc,finAquisition)

            #--- Gestion graphique des boutons
            ::foc::setAcqState stop
         }
         ::foc::setFocusState acq normal
      } else {
         if {$panneau(foc,simulation) ==1} {
            set panneau(foc,boucle) "$caption(foc,off)"
         } else {
           ::confCam::run
         }
      }
   }

   #------------------------------------------------------------
   # setAcqState
   #     gere l'etat des boutons GO et STOP/RAZ
   # Parametres : op et state {normal|disabled}
   # Return : Rien
   #------------------------------------------------------------
   proc setAcqState { op {state ""} } {
      variable This
      global caption panneau

      #--   Rem : state n'est pas toujours utile
      switch -exact $op {
         goto     {  #--  Etat lors d'un GOTO
                     $This.fra2.but1 configure -state $state
                     $This.fra2.but2 configure -state $state
                  }
         centrage {  #--  Etat avant une acquisition de centrage
                     $This.fra2.but1 configure -relief groove -state disabled
                     $This.fra2.but2 configure -relief raised -text $panneau(foc,stop) -state normal
                  }
         post     {  #--  Etat apres une acquisition de centrage
                     if { $panneau(foc,actuel) == "$caption(foc,centrage)" } {
                        $This.fra2.but1 configure -relief raised -text $panneau(foc,go) -state normal
                     }
                     $This.fra2.but2 configure -relief raised -text $panneau(foc,raz)
                  }
         window   {  #--  Etat post-window
                     $This.fra2.but1 configure -relief groove -text $panneau(foc,go)
                     $This.fra2.but2 configure -text $panneau(foc,stop)
                  }
         stop     {  #--  Etat a la fin d'un stop
                     $This.fra2.but1 configure -relief raised -text $panneau(foc,go) -state normal
                     $This.fra2.but2 configure -relief raised -text $panneau(foc,raz) -state normal
                  }
      }
      update
   }

   #------------------------------------------------------------
   # simule
   #
   # Return : Rien
   #------------------------------------------------------------
   proc simule { } {
      variable This
      global audace caption panneau

      set seeing 21
      set incrSeeing -2

      #--   Definit les limites de la simulation
      if {$panneau(foc,typefocuser) == 1} {
         #--   Focuser audecom ou USB_Focus
         switch -exact $panneau(foc,focuser) {
            focuseraudecom     {set limite1 -32767 ; set limite2 32767 }
            usb_focus          {set limite1 0      ; set limite2 65535 }
         }
      } else {
         #--   Tous les autres focuser
         set limite1 0 ; set limite2 65535
      }
      set audace(focus,currentFocus $limite1
      set panneau(foc,start) $audace(focus,currentFocus)
      set panneau(foc,step) 3000
      set n [expr { int(($limite2-$limite1)/$panneau(foc,step)) }]
      set panneau(foc,end) [expr { $limite1+$n*$panneau(foc,step) }]
      update

      #--   Boucle
      for {set currentFocus $panneau(foc,start)} {$currentFocus <= $panneau(foc,end)} {incr currentFocus $panneau(foc,step)} {

         if {$panneau(foc,boucle) eq "$caption(foc,off)"} {
            #--   Sort de la boucle
            break
         }

         #--   Actualise la cible
         set audace(focus,targetFocus) $currentFocus

         after 2000

         #--   Actualise la position courante
         set audace(focus,currentFocus) $currentFocus

         #--   Repetition des prise de vue
         for {set rep 1} {$rep <= $panneau(foc,repeat)} {incr rep} {

            ::foc::createImage $panneau(foc,bin) $seeing $panneau(foc,exptime)
            ::foc::setAcqState post

            #--- Actualise le graphique
            if { $panneau(foc,boucle) == "$caption(foc,on)" } {
               ::foc::updateValues
            }
            ::foc::setAcqState window

            if {[$This.fra2.but2 configure -relief] eq "sunken"} {
               ::foc::cmdStop
               break
            }
         } ; # fin des iterations

         #--   Modifie l'increment du seeing
         incr seeing $incrSeeing
         if {$seeing <= 0} {
            set incrSeeing 2
            incr seeing $incrSeeing
         }

         after 2000
      } ; # fin de boucle

      #--- Sauvegarde du fichier des traces
      ::foc::cmdSauveLog foc.log
   }

}

