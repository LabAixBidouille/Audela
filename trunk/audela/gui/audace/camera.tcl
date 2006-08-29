#
# Fichier : camera.tcl
# Description : Utilitaires lies aux cameras CCD
# Auteur : Robert DELMAS
# Mise a jour $Id: camera.tcl,v 1.6 2006-08-29 20:46:21 robertdelmas Exp $
#

namespace eval camera {
   global audace camera

   #--- Chargement des captions
   source [ file join $audace(rep_caption) camera.cap ]

   #
   # ::camera::alarme_sonore exptime
   # Alarme sonore de fin de pose
   #
   proc alarme_sonore { { exptime } } {
      global audace conf

      #--- Appel de la sonnerie a $conf(acq,bell)+1 secondes de la fin de pose
      #--- La sonnerie dure 1 seconde
      #--- Sonnerie immediate pour des temps de pose < $conf(acq,bell) et > 1 seconde
      #--- Pas de sonnerie pour des temps de pose inferieurs a 1 seconde
      #--- $conf(acq,bell) < "0" pour ne pas sonner
      if { [ info exists conf(acq,bell) ] == "0" } {
         set conf(acq,bell) "-1"
      }
      if { ( $conf(acq,bell) >= "0" ) && ( $exptime > "1" ) } {
         if { $conf(acq,bell) >= $exptime } {
            set delay "0.1"
         } else {
            set delay [ expr $exptime-$conf(acq,bell)-1 ]
            if { $delay <= "0" } {
               set delay "0.1"
            }
         }
         if { $delay > "0" } {
            set audace(after,bell,id) [ after [ expr int($delay*1000) ] bell ]
         }
      }
   }

   #
   # ::camera::dispLine t Nb_Line_sec Nb_Line_Total Stop_Scan
   # Decompte du nombre de lignes du scan
   #
   proc dispLine { t Nb_Line_sec Nb_Line_Total Stop_Scan } {

      set t [ expr $t-1 ]
      set tt [ expr $t*$Nb_Line_sec ]
      if { $Stop_Scan != "1" } {
         if { $t > "1" } {
            after 1000 ::camera::dispLine $t $Nb_Line_sec $Nb_Line_Total
            if { $Nb_Line_Total >= "30" } {
               ::camera::Avancement_scan $tt $Nb_Line_Total
            }
         }
      }
   }

   #
   # ::camera::Avancement_scan tt Nb_Line_Total
   # Affichage de la progression en lignes du scan
   #
   proc Avancement_scan { tt Nb_Line_Total } {
      global audace caption conf

      #--- Recuperation de la position de la fenetre
      ::camera::recup_position_Avancement_Scan

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(avancement_scan,position) ] } { set conf(avancement_scan,position) "+120+315" }

      #---
      if { [ winfo exists $audace(base).progress_scan ] != "1" } {
         #---
         toplevel $audace(base).progress_scan
         wm transient $audace(base).progress_scan $audace(base)
         wm resizable $audace(base).progress_scan 0 0
         wm title $audace(base).progress_scan "$caption(camera,en_cours)"
         wm geometry $audace(base).progress_scan 250x30$conf(avancement_scan,position)

         #--- Cree le widget et le label du temps ecoule
         label $audace(base).progress_scan.lab_status -text "" -font $audace(font,arial_12_b) -justify center
         uplevel #0 { pack $audace(base).progress_scan.lab_status -side top -fill x -expand true -pady 5 }
         if { $tt == "-10" } {
            if { $conf(tempo_scan,delai) > "1" } {
               $audace(base).progress_scan.lab_status configure -text "$caption(camera,attente) $conf(tempo_scan,delai) \
                  $caption(camera,secondes)"
            } else {
               $audace(base).progress_scan.lab_status configure -text "$caption(camera,attente) $conf(tempo_scan,delai) \
                  $caption(camera,seconde)"
            }
         } else {
            $audace(base).progress_scan.lab_status configure -text "[ expr int($tt) ] $caption(camera,ligne) \
               / $Nb_Line_Total $caption(camera,ligne)"
         }
      } else {
         if { $tt == "-10" } {
            if { $conf(tempo_scan,delai) > "1" } {
               $audace(base).progress_scan.lab_status configure -text "$caption(camera,attente) $conf(tempo_scan,delai) \
                  $caption(camera,secondes)"
            } else {
               $audace(base).progress_scan.lab_status configure -text "$caption(camera,attente) $conf(tempo_scan,delai) \
                  $caption(camera,seconde)"
            }
         } else {
            $audace(base).progress_scan.lab_status configure -text "[ expr int($tt) ] $caption(camera,ligne) \
               / $Nb_Line_Total $caption(camera,ligne)"
         }
      }

      #--- Mise a jour dynamique des couleurs
      if  [ winfo exists $audace(base).progress_scan ] {
         ::confColor::applyColor $audace(base).progress_scan
      }
   }

   #
   # ::camera::recup_position_Avancement_Scan
   # Recuperation de la position de la fenetre de progression du scan
   #
   proc recup_position_Avancement_Scan { } {
      global audace conf

      if [ winfo exists $audace(base).progress_scan ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $audace(base).progress_scan ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(avancement_scan,position) "+[ string range $geometry $deb $fin ]"
      }
   }

   #
   # ::camera::dispTime CameraName Label_Time Color_Label Proc_Avancement_pose
   # Decompte du temps d'exposition
   # Utilisation dans les scripts : acqcolor.tcl + cmaude.tcl + remotectrl.tcl + telshift.tcl
   #
   proc dispTime { CameraName Label_Time { Color_Label "#FF0000" } { Proc_Avancement_pose "" } } {
      global caption

      set t "[ $CameraName timer -1 ]"

      if { $t > "1" } {
         $Label_Time configure -text "[ expr $t-1 ] / [ format "%d" [ expr int([ $CameraName exptime ]) ] ]" \
            -fg $Color_Label
         update
         after 1000 ::camera::dispTime $CameraName $Label_Time $Color_Label $Proc_Avancement_pose
      } else {
         $Label_Time configure -text "$caption(camera,numerisation)" -fg $Color_Label
         update
      }

      if { $Proc_Avancement_pose != "" } {
         $Proc_Avancement_pose $t
      }
   }

   #
   # ::camera::gestionPose Exposure GO_Stop CameraName BufferName
   # Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
   #
   proc gestionPose { Exposure GO_Stop { CameraName "" } { BufferName "" } } {
      global audace conf

      #--- Correspond a un demarrage de la pose
      if { $GO_Stop == "1" } {

         #--- Appel du timer
         if { $Exposure >= "2" } {
            ::camera::dispTime_1 $CameraName "::camera::Avancement_pose"
         }

         #--- Attente de la fin de la pose
         vwait status_$CameraName

         #--- Effacement de la fenetre de progression
         if [ winfo exists $audace(base).progress_pose ] {
            destroy $audace(base).progress_pose
         }

      #--- Correspond a un arret anticipe de la pose
      } elseif { $GO_Stop == "0" } {

         #--- Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
         ::camera::Avancement_pose "1"

      }
   }

   #
   # ::camera::dispTime_1 CameraName Proc_Avancement_pose
   # Decompte du temps d'exposition
   # Utilisation dans les scripts : foc.tcl + snacq.tcl + tel.tcl
   #
   proc dispTime_1 { CameraName { Proc_Avancement_pose "" } } {

      set t "[ $CameraName timer -1 ]"

      if { $t > "1" } {
         after 1000 ::camera::dispTime_1 $CameraName $Proc_Avancement_pose
      }

      if { $Proc_Avancement_pose != "" } {
         $Proc_Avancement_pose $t
      }
   }

   #
   # ::camera::Avancement_pose t
   # Affichage d'une barre de progression qui simule l'avancement de la pose
   #
   proc Avancement_pose { { t } } {
      global audace caption color conf

      #--- Recuperation de la position de la fenetre
      ::camera::recup_position_Avancement_Pose

      #--- Initialisation de la barre de progression
      set cpt "100"

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(avancement_pose,position) ] } { set conf(avancement_pose,position) "+120+315" }

      #---
      if { [ winfo exists $audace(base).progress_pose ] != "1" } {
         #---
         toplevel $audace(base).progress_pose
         wm transient $audace(base).progress_pose $audace(base)
         wm resizable $audace(base).progress_pose 0 0
         wm title $audace(base).progress_pose "$caption(camera,en_cours)"
         wm geometry $audace(base).progress_pose $conf(avancement_pose,position)

         #--- Cree le widget et le label du temps ecoule
         label $audace(base).progress_pose.lab_status -text "" -font $audace(font,arial_12_b) -justify center
         uplevel #0 { pack $audace(base).progress_pose.lab_status -side top -fill x -expand true -pady 5 }

         #--- t est un nombre entier
         if { $t <= "0" } {
            destroy $audace(base).progress_pose
         } elseif { $t > "1" } {
            $audace(base).progress_pose.lab_status configure -text "[ expr $t-1 ] $caption(camera,sec) / \
               [ format "%d" [ expr int( [ cam$audace(camNo) exptime ] ) ] ] $caption(camera,sec)"
            set cpt [ expr ( $t-1 ) * 100 / [ expr int( [ cam$audace(camNo) exptime ] ) ] ]
            set cpt [ expr 100 - $cpt ]
         } else {
            $audace(base).progress_pose.lab_status configure -text "$caption(camera,numerisation)"
         }
         #---
         catch {
            #--- Cree le widget pour la barre de progression
            frame $audace(base).progress_pose.cadre -width 200 -height 30 -borderwidth 2 -relief groove
            uplevel #0 { pack $audace(base).progress_pose.cadre -in $audace(base).progress_pose -side top \
               -anchor center -fill x -expand true -padx 8 -pady 8 }

            #--- Affiche de la barre de progression
            frame $audace(base).progress_pose.cadre.barre_color_invariant -height 26 -bg $color(blue)
            place $audace(base).progress_pose.cadre.barre_color_invariant -in $audace(base).progress_pose.cadre \
               -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
            update
         }
      } else {
         #--- t est un nombre entier
         if { $t <= "0" } {
            destroy $audace(base).progress_pose
         } elseif { $t > "1" } {
            $audace(base).progress_pose.lab_status configure -text "[ expr $t-1 ] $caption(camera,sec) / \
               [ format "%d" [ expr int( [ cam$audace(camNo) exptime ] ) ] ] $caption(camera,sec)"
            set cpt [ expr ( $t-1 ) * 100 / [ expr int( [ cam$audace(camNo) exptime ] ) ] ]
            set cpt [ expr 100 - $cpt ]
         } else {
            $audace(base).progress_pose.lab_status configure -text "$caption(camera,numerisation)"
         }
         catch {
            #--- Affiche de la barre de progression
            place $audace(base).progress_pose.cadre.barre_color_invariant -in $audace(base).progress_pose.cadre \
               -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
            update
         }
      }

      #--- Mise a jour dynamique des couleurs
      if  [ winfo exists $audace(base).progress_pose ] {
         ::confColor::applyColor $audace(base).progress_pose
      }
   }

   #
   # ::camera::recup_position_Avancement_Pose
   # Recuperation de la position de la fenetre de progression de la pose
   #
   proc recup_position_Avancement_Pose { } {
      global audace conf

      if [ winfo exists $audace(base).progress_pose ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $audace(base).progress_pose ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(avancement_pose,position) "+[ string range $geometry $deb $fin ]"
      }
   }

   #
   # ::camera::dispTime_2 CameraName Label_Time Proc_Avancement_pose
   # Decompte du temps d'exposition
   # Utilisation dans les scripts : acqfc.tcl
   #
   proc dispTime_2 { CameraName Label_Time { Proc_Avancement_pose "" } { visuNo "" } } {
      global caption

      set t "[ $CameraName timer -1 ]"

      if { $t > "1" } {
         $Label_Time configure -text "[ expr $t-1 ] / [ format "%d" [ expr int([ $CameraName exptime ]) ] ]"
         update
         after 1000 ::camera::dispTime_2 $CameraName $Label_Time $Proc_Avancement_pose $visuNo
      } else {
         $Label_Time configure -text "$caption(camera,numerisation)"
         update
      }

      if { $Proc_Avancement_pose != "" } {
         $Proc_Avancement_pose $visuNo $t
      }
   }

}

