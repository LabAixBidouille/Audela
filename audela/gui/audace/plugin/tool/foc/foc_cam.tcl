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
            if { $panneau(foc,typefocuser) == "0" && [winfo exists $audace(base).visufoc] ==0} {
               focGraphe
            } elseif { $panneau(foc,typefocuser) == "1" && [winfo exists $audace(base).visuhfd] ==0} {
               initFocHFD
            }
         }

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

            #--- Statistiques
            set s [ stat ]
            set maxi [ lindex $s 2 ]
            set fond [ lindex $s 7 ]
            set contr [ format "%.0f" [ expr -1.*[ lindex $s 8 ] ] ]
            set inten [ format "%.0f" [ expr $maxi-$fond ] ]
            #--- Fwhm
            set naxis1 [ expr [ lindex [ $buffer getkwd NAXIS1 ] 1 ]-0 ]
            set naxis2 [ expr [ lindex [ $buffer getkwd NAXIS2 ] 1 ]-0 ]
            set box [ list 1 1 $naxis1 $naxis2 ]
            lassign [ $buffer fwhm $box ] fwhmx fwhmy

            #--- Valeurs a l'ecran
            ::foc::qualiteFoc $inten $fwhmx $fwhmy $contr
            update

            #--- Actualise les donnees pour le fichier log
            append panneau(foc,fichier) "$inten $fwhmx $fwhmy $contr \n"

            #--  Traitement differentie selon focuser
            if { $panneau(foc,typefocuser) == "0"} {
               updateFocGraphe [list $panneau(foc,compteur) $inten $fwhmx $fwhmy $contr]
            } else {
               updateHFDGraphe
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
   # updateFocGraphe
   #    sous processus de cmdAcq de mise a jour des 4 graphiques
   # Parametre : liste du n° d'image, intensite, fwhmx, fwhmy et contraste
   #------------------------------------------------------------
   proc updateFocGraphe { data } {
      global audace

      #--   raccourci
      set w $audace(base).visufoc

      lassign $data count inten fwhmx fwhmy contr

      #--   Met a jour les vecteurs
      ::vx append $count
      ::vyg_inten append $inten
      ::vyg_fwhmx append $fwhmx
      ::vyg_fwhmy append $fwhmy
      ::vyg_contr append $contr

      #--   Met a jour les graphiques

      #--- Affiche les 19 dernieres mesures glissantes + 1 vide
      if { [::vx length] > 19 } {
         lassign [ $w.g_fwhmx axis limits x ] xmin xmax
         set xmin [expr { $xmin+1 }]
         set xmax [expr { $xmax+1 }]
         foreach childGraph [list g_inten g_fwhmx g_fwhmy g_contr] {
            $w.$childGraph axis configure x -min $xmin -max $xmax
            $w.$childGraph axis configure x2 -min $xmin -max $xmax
         }
      }

      #--- Ajuste l'echelle de droite a celle de gauche
      foreach childGraph [list g_inten g_fwhmx g_fwhmy g_contr] {
         lassign [ $w.$childGraph axis limits y ] ymin ymax
         $w.$childGraph axis configure y2 -min $ymin -max $ymax
      }
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
   # avancementPose
   #    sous processus de cmdAcq et de dispTime
   #------------------------------------------------------------
   proc avancementPose { t } {
      global audace caption color conf panneau

      #--- Fenetre d'avancement de la pose non demandee
      if { $panneau(foc,avancement_acq) == "0" } {
         return
      }

      #--   raccourci
      set w $audace(base).progress_pose

      #--- Recuperation de la position de la fenetre
      ::foc::closePositionAvancementPose

      #--- Initialisation de la barre de progression
      set cpt "100"

      #---
      if { [ winfo exists $w ] != "1" } {

         #--- Cree la fenetre toplevel
         toplevel $w
         wm transient $w $audace(base)
         wm resizable $w 0 0
         wm title $w "$caption(foc,en_cours)"
         wm geometry $w $conf(foc,avancement,position)

         #--- Cree le widget et le label du temps ecoule
         label $w.lab_status -text "" -justify center
         pack $w.lab_status -side top -fill x -expand true -pady 5

         #---
         if { $panneau(foc,demande_arret) == "1" } {
            $w.lab_status configure -text "$caption(foc,numerisation)"
         } else {
            if { $t < "0" } {
               destroy $w
            } elseif { $t > "0" } {
               $w.lab_status configure -text "$t $caption(foc,sec) / \
                  [ format "%d" [ expr int( $panneau(foc,exptime) ) ] ] $caption(foc,sec)"
               set cpt [ expr $t * 100 / int( $panneau(foc,exptime) ) ]
               set cpt [ expr 100 - $cpt ]
            } else {
               $w.lab_status configure -text "$caption(foc,numerisation)"
            }
         }

         #---
         if { [ winfo exists $audace(base).progress_pose ] == "1" } {
            #--- Cree le widget pour la barre de progression
            frame $w.cadre -width 200 -height 30 -borderwidth 2 -relief groove
            pack $w.cadre -in $w -side top \
               -anchor center -fill x -expand true -padx 8 -pady 8

            #--- Affiche de la barre de progression
            frame $w.cadre.barre_color_invariant -height 26 -bg $color(blue)
            place $w.cadre.barre_color_invariant -in $w.cadre \
               -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
            update
         }

         #--- Mise a jour dynamique des couleurs
         if { [ winfo exists $w ] == "1" } {
            ::confColor::applyColor $w
         }

      } else {

         #---
         if { $panneau(foc,pose_en_cours) == "0" } {

            #--- Je supprime la fenetre s'il n'y a plus de pose en cours
            ::foc::closePositionAvancementPose

         } else {

            if { $panneau(foc,demande_arret) == "0" } {
               if { $t > "0" } {
                  $w.lab_status configure -text "$t $caption(foc,sec) / \
                     [ format "%d" [ expr int( $panneau(foc,exptime) ) ] ] $caption(foc,sec)"
                  set cpt [ expr $t * 100 / int( $panneau(foc,exptime) ) ]
                  set cpt [ expr 100 - $cpt ]
               } else {
                  $w.lab_status configure -text "$caption(foc,numerisation)"
               }
            } else {
               #--- J'affiche "Lecture" des qu'une demande d'arret est demandee
               $w.lab_status configure -text "$caption(foc,numerisation)"
            }
            #--- Affiche de la barre de progression
            place $w.cadre.barre_color_invariant -in $w.cadre \
               -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
            update

         }

      }

   }

   #------------------------------------------------------------
   # closePositionAvancementPose
   #    ferme la fenetre d'avancement de la pose et sauve sa position
   #------------------------------------------------------------
   proc closePositionAvancementPose { } {
      global audace conf

      set w $audace(base).progress_pose
      if [ winfo exists $w ] {
         #--- Determination de la position de la fenetre
         regsub {([0-9]+x[0-9]+)} [ wm geometry $w ] "" conf(foc,avancement,position)

         #--- Je supprime la fenetre s'il n'y a plus de pose en cours
         destroy $w
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
               focGraphe
            } else {
               ::foc::initFocHFD
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

   #------------------------------------------------------------
   # cmdSauveLog
   #    sous processus de cmdStop
   # Parametre : chemin du fichier
   #------------------------------------------------------------
   proc cmdSauveLog { namefile } {
      global panneau

      if [ catch { open [ file join $::audace(rep_log) $namefile ] w } fileId ] {
         return
      } else {
         puts -nonewline $fileId $panneau(foc,fichier)
         close $fileId
      }
   }

   #------------   fenetre affichant les valeurs  --------------

   #------------------------------------------------------------
   # qualiteFoc
   #    affiche la valeur des parametres dans une fenetre
   # Parametres : les valeurs a afficher
   #------------------------------------------------------------
   proc qualiteFoc { inten fwhmx fwhmy contr } {
      global audace caption conf panneau

      set this $audace(base).parafoc

      #--- Fenetre d'affichage des parametres de la foc
      if [ winfo exists $this ] {
         fermeQualiteFoc
      }

      #--- Creation de la fenetre
      toplevel $this
      wm transient $this $audace(base)
      wm resizable $this 0 0
      wm title $this "$caption(foc,focalisation)"
      wm geometry $this $conf(parafoc,position)
      wm protocol $this WM_DELETE_WINDOW { ::foc::fermeQualiteFoc }
      #--- Cree les etiquettes
      label $this.lab1 -text "$panneau(foc,compteur)"
      pack $this.lab1 -padx 10 -pady 2
      label $this.lab2 -text "$caption(foc,intensite) $caption(foc,egale) $inten"
      pack $this.lab2 -padx 5 -pady 2
      label $this.lab3 -text "$caption(foc,fwhm__x) $caption(foc,egale) $fwhmx"
      pack $this.lab3 -padx 5 -pady 2
      label $this.lab4 -text "$caption(foc,fwhm__y) $caption(foc,egale) $fwhmy"
      pack $this.lab4 -padx 5 -pady 2
      label $this.lab5 -text "$caption(foc,contraste) $caption(foc,egale) $contr"
      pack $this.lab5 -padx 5 -pady 2
      update

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }

   #------------------------------------------------------------
   # fermeQualiteFoc
   #    ferme la fenetre de la qualite et sauve sa position
   # Parametre : chemin de la fenetre
   #------------------------------------------------------------
   proc fermeQualiteFoc { } {
      global audace conf

      set w $audace(base).parafoc

      #--- Determination de la position de la fenetre
      regsub {([0-9]+x[0-9]+)} [wm geometry $w] "" conf(parafoc,position)

      #--- Fermeture de la fenetre
      destroy $w
   }

}

