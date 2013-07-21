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

         #--- Parametrage de la prise de vue en Centrage ou en Fenetrage
         if { [ info exists panneau(foc,actuel) ] == "0" } {
            set panneau(foc,actuel) "$caption(foc,centrage)"
            set dimxy               [ cam$audace(camNo) nbcells ]
            set panneau(foc,window) [ list 1 1 [ lindex $dimxy 0 ] [ lindex $dimxy 1 ] ]
         }


         if { $panneau(foc,menu) == "$caption(foc,centrage)" } {
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

         } elseif { $panneau(foc,menu) == "$caption(foc,fenetre)" } {

            set panneau(foc,bin) "1"
            if { $panneau(foc,actuel) == "$caption(foc,centrage)" } {
               if { [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ] != "" } {
                  set a [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ]
                  set kk 0
                  set b $a
                  #--- Tient compte du binning
                  foreach e $a {
                     set b [ lreplace $b $kk $kk [ expr $panneau(foc,bin_centrage)*$e ] ]
                     incr kk
                  }
                  set panneau(foc,window) $b
               }
            }
            set panneau(foc,actuel) "$caption(foc,fenetre)"
            set panneau(foc,boucle) "$caption(foc,on)"

            #--   Ouvre le graphique adhoc s'il n'existe pas deja
            if { $panneau(foc,typefocuser) == "0" && [winfo exists $audace(base).visufoc] ==0} {
               ::foc::focGraphe
               #--   finalise la ligne de titre
               append panneau(foc,fichier) "\n"
            } elseif { $panneau(foc,typefocuser) == "1" && [winfo exists $audace(base).visuhfd] ==0} {
               ::foc::HFDGraphe
               #--   finalise la ligne de titre
               append panneau(foc,fichier) "$caption(foc,hfd)\t${caption(foc,pos_focus)}\n"
            }
         }

         #--   Calcule la taille de la box
         lassign $panneau(foc,window) x1 y1 x2 y2
         set panneau(foc,box) [list 1 1 [expr { $x2-$x1+1 }] [expr { $y2-$y1+1 }]]

         cam$audace(camNo) window $panneau(foc,window)

         #--- Suppression de la zone selectionnee avec la souris
         ::confVisu::deleteBox $audace(visuNo)

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
      global audace caption panneau

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
            if { $panneau(foc,focuser) != "$caption(foc,pas_focuser)" } {
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

      #--- Informations sur l'image fenetree
      if { $panneau(foc,actuel) == "$caption(foc,fenetre)" } {

         if { $panneau(foc,boucle) == "$caption(foc,on)" } {

            #--- Gestion graphique des boutons
            $This.fra2.but1 configure -relief groove -text $panneau(foc,go)
            $This.fra2.but2 configure -text $panneau(foc,stop)
            update

            incr panneau(foc,compteur)

            #--   Normalise le fond du ciel
            $buffer noffset 0

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

