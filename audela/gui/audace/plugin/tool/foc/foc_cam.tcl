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

      set visuNo $audace(visuNo)
      set bufNo $audace(bufNo)

      #---
      if { [ ::cam::list ] != "" } {

         #--- Gestion graphique des boutons
         $This.fra2.but1 configure -relief groove -state disabled ;  #--- Bouton GO
         $This.fra2.but2 configure -text $panneau(foc,stop) ;        #--- Bouton STOP/RAZ
         $This.fra4.focuser.list configure -state disabled ;         #--- Combobox de choix du focuser
         update

         #--- Applique le binning demande si la camera possede bien ce binning
         set binningCamera "2x2"
         if { [ lsearch [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningList ] $binningCamera ] != "-1" } {
            set panneau(foc,bin) "2"
         } else {
            set panneau(foc,bin) "1"
         }
         set panneau(foc,bin_centrage) $panneau(foc,bin)

         #--   S'informe si la cam a le windowing
         set panneau(foc,hasWindow) [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] hasWindow ]

         #--- Parametrage de la prise de vue en Centrage ou en Fenetrage
         if { [ info exists panneau(foc,actuel) ] == "0" } {
            set panneau(foc,actuel) "$caption(foc,centrage)"
            set dimxy               [ cam$audace(camNo) nbcells ]
            set panneau(foc,window) [ list 1 1 [ lindex $dimxy 0 ] [ lindex $dimxy 1 ] ]
         }

         if { $panneau(foc,menu) eq "$caption(foc,centrage)" } {

            #--- Mode Centrage

            #--- Applique le binning demande si la camera possede bien ce binning
            set binningCamera "2x2"
            if { [ lsearch [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningList ] $binningCamera ] != "-1" } {
               set panneau(foc,bin) "2"
            } else {
               set panneau(foc,bin) "1"
            }
            set panneau(foc,bin_centrage) "$panneau(foc,bin)"
            set dimxy                     [ cam$audace(camNo) nbcells ]
            set panneau(foc,window)       [ list 1 1 [ lindex $dimxy 0 ] [ lindex $dimxy 1 ] ]
            set panneau(foc,actuel)       "$caption(foc,centrage)"
            set panneau(foc,boucle)       "$caption(foc,off)"

         } else {

            #--- Mode Fenetrage

            if { $panneau(foc,menu) eq "$caption(foc,fenetre_auto)"} {

               #--   Fenetrage automatique

               #--   Coordonnees de l'étoile dans l'image binnee
               #--   attention si l'image est plate x=naxis1 et y=naxis2
               lassign [searchBrightestStar] x y

               #--   Debug : etoile artificielle
               #set x 100 ; set y 80

               #--   Calcule auto des cordonnees de la fenetre dans l'image binnee
               set a [expr { int(round($x)-20) }]
               set b [expr { int(round($y)-20) }]
               set c [expr { int(round($x)+20) }]
               set d [expr { int(round($y)+20) }]
               set binBox [list $a $b $c $d]

            } else {

               #--   Fenetrage manuel

               #--   Identifie la fenetre dans l'image binnee
               set binBox [ ::confVisu::getBox $visuNo ]

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

            } else {

               #--   Si oubli de fenetrer avant de faire "GO CCD"
               set panneau(foc,menu) "$caption(foc,centrage)"
              ::foc::cmdGo
            }

            set panneau(foc,actuel) $panneau(foc,menu)
            set panneau(foc,boucle) "$caption(foc,on)"

            #--   Debug : pour forcer l'affichage de HFDGraphe
            #set panneau(foc,typefocuser) "1"

            #--   Ouvre le graphique adhoc s'il n'existe pas deja
            if { $panneau(foc,typefocuser) == "0" && [winfo exists $audace(base).visufoc] ==0} {

               #--   Lance le graphique normal
               ::foc::focGraphe

               #--   Finalise la ligne de titre du fichier log
               append panneau(foc,fichier) "\n"

            } elseif { $panneau(foc,typefocuser) == "1" && [winfo exists $audace(base).visuhfd] ==0} {

               #--   Lance le graphique HFD
               ::foc::HFDGraphe

               #--   Photocentre dans la fenetre binnee
               lassign [buf$bufNo centro $binBox] xstar ystar

               #--   Dimensions de l'image binnee
               set naxis1 [buf$bufNo getpixelswidth]
               set naxis2 [buf$bufNo getpixelsheight]

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

            #--- Suppression de la zone selectionnee avec la souris
            ::confVisu::deleteBox $visuNo

         }

         cam$audace(camNo) window $panneau(foc,window)

         #--- Suppression de la zone selectionnee avec la souris
         #::confVisu::deleteBox $visuNo

         #--- Appel a la fonction d'acquisition
         ::foc::cmdAcq

         #--- Gestion graphique des boutons
         if { $panneau(foc,actuel) == "$caption(foc,centrage)" } {
            $This.fra2.but1 configure -relief raised -text $panneau(foc,go) -state normal ; #--- Bouton GO
         }
         $This.fra2.but2 configure -relief raised -text $panneau(foc,raz)                 ; #--- Bouton STOP/RAZ
         update

      } else {
         ::confCam::run
      }
   }

   #------------------------------------------------------------
   # cmdAcq
   #    lance une acquisition
   #------------------------------------------------------------
   proc cmdAcq { } {
      variable This
      global audace conf caption panneau

      #--- Petits raccourcis
      set camera cam$audace(camNo)
      set buffer buf$audace(bufNo)

      #--- Initialisation d'une variable
      set panneau(foc,finAquisition) ""

      #--- Pose en cours
      set panneau(foc,pose_en_cours) "1"

      #--- La commande bin permet de fixer le binning
      $camera bin [ list $panneau(foc,bin) $panneau(foc,bin) ]

      #--- Cas des petites poses : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
      if { $panneau(foc,exptime) >= "0" && $panneau(foc,exptime) < "1" } {
         ::foc::avancementPose 0
      }

      #--- Alarme sonore de fin de pose
      ::camera::alarmeSonore $panneau(foc,exptime)

      #--- Appel de l'arret du moteur de foc a 100 millisecondes de la fin de pose
      if { $::panneau(foc,focuser) != "" } {
         set delay 0.100
         if { [ expr $panneau(foc,exptime)-$delay ] > "0" } {
            set delay [ expr $panneau(foc,exptime)-$delay ]
            if { $panneau(foc,focuser) ne "$caption(foc,pas_focuser)" } {
               set audace(after,focstop,id) [ after [ expr int($delay*1000) ] { ::foc::cmdFocus stop } ]
            }
         }
      }

      #--- Declenchement de l'acquisition
      ::camera::acquisition [ ::confVisu::getCamItem $audace(visuNo) ] "::foc::attendImage" $panneau(foc,exptime)

      #--- Je lance la boucle d'affichage du decompte
      after 10 ::foc::dispTime

      #--- J'attends la fin de l'acquisition
      vwait panneau(foc,finAquisition)

      #--- Fenetrage sur le buffer si la camera ne possede pas le mode fenetrage (APN et WebCam)
      if {$panneau(foc,hasWindow) == "0"} {
         $buffer window $panneau(foc,window)
      }

      #--- Informations sur l'image fenetree
      if { $panneau(foc,actuel) ne "$caption(foc,centrage)" } {

         if { $panneau(foc,boucle) == "$caption(foc,on)" } {

            #--- Gestion graphique des boutons
            $This.fra2.but1 configure -relief groove -text $panneau(foc,go)
            $This.fra2.but2 configure -text $panneau(foc,stop)
            update

            incr panneau(foc,compteur)

            #--   Normalise le fond du ciel
            $buffer noffset 0

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
            lassign [ $buffer fwhm $panneau(foc,box) ] fwhmx fwhmy
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
   # attendImage
   #    sous processus de cmdAcq
   #------------------------------------------------------------
   proc attendImage { message args } {
      global audace panneau

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
            set panneau(foc,finAquisition) "acquisitionResult"
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
            $This.fra2.but1 configure -relief raised -text $panneau(foc,go) -state normal
            $This.fra2.but2 configure -relief raised -text $panneau(foc,raz) -state normal
         }

         #--   Desinhibe le choix du focuser
         $This.fra4.focuser.list configure -state normal ; # combobox de choix du focuser
         update
      } else {
         ::confCam::run
      }
   }

}

