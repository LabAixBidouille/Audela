#
# Fichier : acqfen.tcl
# Description : Outil d'acquisition d'images fenetrees
# Auteur : Benoit MAUGIS
# Mise a jour $Id: acqfen.tcl,v 1.3 2006-06-20 20:44:30 robertdelmas Exp $
#

package provide acqfen 1.2.1

# =========================================================
# === définition du namespace acqfen pour créer l'outil ===
# =========================================================

namespace eval ::acqfen {


   # =======================================================================
   # === définition des fonctions de construction automatique de l'outil ===
   # =======================================================================


   global audace
   variable This
#--- Debut modif Robert
   variable parametres
#--- Fin modif Robert

   # chargement du fichier d'internationalisation
   source [ file join $audace(rep_plugin) tool acqfen acqfen.cap ]

   proc init {{in ""}} {
      createPanel $in.acqfen
   }


   proc createPanel {this} {
      variable This
#--- Debut modif Robert
      variable parametres
#--- Fin modif Robert
      global panneau caption

      set This $this
#--- Debut modif Robert
      #--- Recuperation de la derniere configuration de prise de vue
      ::acqfen::Chargement_Var
#--- Fin modif Robert
      set panneau(menu_name,acqfen)       $caption(acqfen,titre)
      set panneau(acqfen,ht_onglet)       280
      set panneau(acqfen,go_stop_cent)    "go"
      set panneau(acqfen,go_stop)         "go"

      # Valeurs par défaut d'acquisition (centrage)
      # Liste de valeurs du temps de pose disponibles par défaut
      set panneau(acqfen,temps_pose_centrage)	{.1 .2 .5 1 2 5}
      # Valeur par défaut du temps de pose:
#--- Debut modif Robert
     # set panneau(acqfen,pose_centrage)		.2
      if { ! [ info exists panneau(acqfen,pose_centrage) ] } {
         set panneau(acqfen,pose_centrage) "$parametres(acqfen,pose_centrage)"
      }
#--- Fin modif Robert
      # Binning par défaut: 4x4
#--- Debut modif Robert
     # set panneau(acqfen,bin_centrage) 		4
      if { ! [ info exists panneau(acqfen,bin_centrage) ] } {
         set panneau(acqfen,bin_centrage) "$parametres(acqfen,bin_centrage)"
      }
#--- Fin modif Robert
      
      # Valeurs par défaut d'acquisition (mode "planétaire", fenêtré)
      # Liste de valeurs du temps de pose disponibles par défaut
      set panneau(acqfen,temps_pose)	{.01 .02 .03 .05 .08 .1 .15 .2 .3 .5 1}
      # Valeur par défaut du temps de pose:
#--- Debut modif Robert
     # set panneau(acqfen,pose)			.05
      if { ! [ info exists panneau(acqfen,pose) ] } {
         set panneau(acqfen,pose) "$parametres(acqfen,pose)"
      }
#--- Fin modif Robert
      # Binning par défaut: 1x1
#--- Debut modif Robert
     # set panneau(acqfen,bin) 			1
      if { ! [ info exists panneau(acqfen,bin) ] } {
         set panneau(acqfen,bin) "$parametres(acqfen,bin)"
      }
#--- Fin modif Robert

      # Taille par défaut de la petite matrice schématisant le fenêtrage
      set panneau(acqfen,mtx_x)           81
      set panneau(acqfen,mtx_y)           54
      
      # Valeurs initiales des coordonnées de la "boîte"
      set panneau(acqfen,X1)              "-"
      set panneau(acqfen,Y1)              "-"
      set panneau(acqfen,X2)              "-"
      set panneau(acqfen,Y2)              "-"

      # Type de zoom par défaut (scale / zoom)
      set panneau(acqfen,typezoom)        "scale"
      
      # Mode d'acquisition par défaut
#--- Debut modif Robert
     # set panneau(acqfen,mode)           "une"
      if { ! [ info exists panneau(acqfen,mode) ] } {
         set panneau(acqfen,mode) "$parametres(acqfen,mode)"
      }

      # Mode du bouton de changement de mode
      if { $panneau(acqfen,mode) == "une" } {
         set panneau(acqfen,bouton_mode) "$caption(acqfen,uneimage)"
      } elseif { $panneau(acqfen,mode) == "serie" } {
         set panneau(acqfen,bouton_mode) "$caption(acqfen,serie)"
      } else {
         set panneau(acqfen,bouton_mode) "$caption(acqfen,continu)"
      }
#--- Fin modif Robert

      set panneau(acqfen,index)           1
      set panneau(acqfen,nb_images)	      1

      set panneau(acqfen,enregistrer)     0

      # Réglages acquisitions série et continu par défaut
      set panneau(acqfen,fenreglfen1)     1
      set panneau(acqfen,fenreglfen12)    0
      set panneau(acqfen,fenreglfen2)     1
      set panneau(acqfen,fenreglfen22)    2
      set panneau(acqfen,fenreglfen3)     1
      set panneau(acqfen,fenreglfen4)     1
      # Pourcentage de correction des défauts de suivi (doit être compris entre 1 et 100)
      set panneau(acqfen,fenreglfen42)    70

      # Au début les réglages de temps de pose et de binning sont "accessibles" pour les 2 modes d'acquisition
      set panneau(acqfen,affpleinetrame)  1
      set panneau(acqfen,afffenetrees)    1
      
      acqfenBuildIF $This
      
      ::acqfen::ActuAff

#--- Debut modif Robert
      pack $This.mode.$panneau(acqfen,mode) -anchor nw -fill x
#--- Fin modif Robert

   }

#--- Debut modif Robert
#***** Procedure Chargement_Var ********************************
   proc Chargement_Var { } {
      variable parametres
      global audace

      #--- Ouverture du fichier de parametres
      set fichier [ file join $audace(rep_plugin) tool acqfen acqfen.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }
      if { ! [ info exists parametres(acqfen,pose_centrage) ] } { set parametres(acqfen,pose_centrage) ".2" }  ; #--- Temps de pose : 0.2s
      if { ! [ info exists parametres(acqfen,bin_centrage) ] }  { set parametres(acqfen,bin_centrage)  "4" }   ; #--- Binning : 4x4
      if { ! [ info exists parametres(acqfen,pose) ] }          { set parametres(acqfen,pose)          ".05" } ; #--- Temps de pose : 0.05s
      if { ! [ info exists parametres(acqfen,bin) ] }           { set parametres(acqfen,bin)           "1" }   ; #--- Binning : 1x1
      if { ! [ info exists parametres(acqfen,mode) ] }          { set parametres(acqfen,mode)          "une" } ; #--- Mode : Une image
   }
#***** Fin de la procedure Chargement_Var **********************

#***** Procedure Enregistrement_Var ****************************
   proc Enregistrement_Var { } {
      variable parametres
      global audace
      global panneau

      #---
      set parametres(acqfen,pose_centrage) $panneau(acqfen,pose_centrage)
      set parametres(acqfen,bin_centrage)  $panneau(acqfen,bin_centrage)
      set parametres(acqfen,pose)          $panneau(acqfen,pose)
      set parametres(acqfen,bin)           $panneau(acqfen,bin)
      set parametres(acqfen,mode)          $panneau(acqfen,mode)

      #--- Sauvegarde des parametres
      catch {
         set nom_fichier [ file join $audace(rep_plugin) tool acqfen acqfen.ini ]
         if [ catch { open $nom_fichier w } fichier ] {
            #---
         } else {
            foreach { a b } [ array get parametres ] { 
               puts $fichier "set parametres($a) \"$b\"" 
            }
            close $fichier
         }
      }
   }
#***** Fin de la procedure Enregistrement_Var ******************
#--- Fin modif Robert

#--- Debut modif Robert
   proc startTool { visuNo } {
      variable This

      pack $This -side left -fill y
#--- Fin modif Robert
   }

#--- Debut modif Robert
   proc stopTool { visuNo } {
#--- Fin modif Robert
      # conseil A. Klotz : ne JAMAIS modifier cette procédure !
      variable This
      global audace

#--- Debut modif Robert
      #--- Sauvegarde de la configuration de prise de vue
      ::acqfen::Enregistrement_Var
#--- Fin modif Robert

      #--- Initialisation du fenetrage
#--- Debut modif Robert
      catch {
         set n1n2 [cam$audace(camNo)  nbcells]
         cam$audace(camNo) window [ list 1 1 [lindex $n1n2 0] [lindex $n1n2 1] ]
      }
      pack forget $This
#--- Fin modif Robert
   }


   # ==================================================================
   # === définition des fonctions générales à exécuter dans l'outil ===
   # ==================================================================


# Procedure de changement du binning (acquisitions fenêtrées)
   proc ChangeBin {} {
      global panneau caption
      variable This
      switch -exact -- $panneau(acqfen,bin) {
         "2" {
            set panneau(acqfen,bin) 1
            }
         "1" {
            set panneau(acqfen,bin) 2
            }
      }
      $This.acq.butbin config -text $caption(acqfen,bin,$panneau(acqfen,bin))
   }
      
# Procedure de changement du binning (acquisitions pleine trame)
   proc ChangeBinCent {} {
      global panneau caption
      variable This
      switch -exact -- $panneau(acqfen,bin_centrage) {
         "3" {
            set panneau(acqfen,bin_centrage) 4
            }
         "4" {
            set panneau(acqfen,bin_centrage) 3
            }
      }
      $This.acqcent.butbin config -text $caption(acqfen,bin,$panneau(acqfen,bin_centrage))
   }

# Procédures de changement d'affichage des réglages
   
   proc ChangeAffPleineTrame {} {
      global panneau
      variable This
      switch -exact -- $panneau(acqfen,affpleinetrame)$panneau(acqfen,afffenetrees) {
        "00" {
           set panneau(acqfen,affpleinetrame) 1
           pack forget $This.acqcentred
           pack forget $This.acqred
        }
        "01" {
           set panneau(acqfen,affpleinetrame) 1
           pack forget $This.acqcentred
           pack forget $This.acq
        }
        "10" {
           set panneau(acqfen,affpleinetrame) 0
           pack forget $This.acqcent
           pack forget $This.acqred
        }
        "11" {
           set panneau(acqfen,affpleinetrame) 0
           pack forget $This.acqcent
           pack forget $This.acq
        }
      }
      pack forget $This.mode
      acqfen::ActuAff
   }
     
   proc ChangeAffFenetrees {} {
      global panneau
      variable This
      switch -exact -- $panneau(acqfen,affpleinetrame)$panneau(acqfen,afffenetrees) {
        "00" {
           set panneau(acqfen,afffenetrees) 1
           pack forget $This.acqcentred
           pack forget $This.acqred
        }
        "01" {
           set panneau(acqfen,afffenetrees) 0
           pack forget $This.acqcentred
           pack forget $This.acq
        }
        "10" {
           set panneau(acqfen,afffenetrees) 1
           pack forget $This.acqcent
           pack forget $This.acqred
        }
        "11" {
           set panneau(acqfen,afffenetrees) 0
           pack forget $This.acqcent
           pack forget $This.acq
        }
      }
      pack forget $This.mode
      acqfen::ActuAff
   }

   proc ActuAff {} {  
     global panneau
     variable This
#--- Debut modif Robert
     switch -exact -- $panneau(acqfen,affpleinetrame)$panneau(acqfen,afffenetrees) {
       00 {
           pack $This.acqcentred -side top -fill x
           pack $This.acqred -side top -fill x
           pack $This.mode -side top -fill x
         }
       01 {
           pack $This.acqcentred -side top -fill x
           pack $This.acq -side top -fill x
           pack $This.mode -side top -fill x
         }
       10 {
           pack $This.acqcent -side top -fill x
           pack $This.acqred -side top -fill x
           pack $This.mode -side top -fill x
         }
       11 {
           pack $This.acqcent -side top -fill x
           pack $This.acq -side top -fill x
           pack $This.mode -side top -fill x
         }
      }
#--- Fin modif Robert
   }   

      
# Procédure d'acquisition pleine trame

   proc GoStopCent {} {
      global audace conf caption panneau
      variable This
      if { [::cam::list] != "" } {

      switch -exact -- $panneau(acqfen,go_stop_cent) {
      "go" {
         # Modification du bouton, pour éviter un second lancement
         set panneau(acqfen,go_stop_cent) stop
         $This.acqcent.but configure -text $caption(acqfen,stop)
         $This.acqcentred.but configure -text $caption(acqfen,stop)

         #--- Suppression de la zone selectionnee avec la souris
#--- Debut modif Robert
         if { [ lindex [ list [ ::confVisu::getBox ] ] 0 ] != "" } {
            ::confVisu::deleteBox
         }
#--- Fin modif Robert

         #--- Mise a jour en-tête audace
         wm title $audace(base) "$caption(acqfen,audace)"

         #--- La commande exptime permet de fixer le temps de pose de l'image.
         cam$audace(camNo) exptime $panneau(acqfen,pose_centrage)

         #--- La commande bin permet de fixer le binning.
         cam$audace(camNo) bin [list $panneau(acqfen,bin_centrage) $panneau(acqfen,bin_centrage)]

         #--- La commande window permet de fixer le fenêtrage de numérisation du CCD
         cam$audace(camNo) window [list 1 1 [lindex [cam$audace(camNo) nbcells] 0] [lindex [cam$audace(camNo) nbcells] 1]]

#--- Debut modif Robert
         #--- Cas des poses de 0 s : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
         if { $panneau(acqfen,pose_centrage) == "0" } {
            ::camera::Avancement_pose "1"
         }
#--- Fin modif Robert

         #--- Lecture du CCD
         cam$audace(camNo) acq

         #--- Alarme sonore de fin de pose
         ::camera::alarme_sonore $panneau(acqfen,pose_centrage)

#--- Debut modif Robert
       ###  #--- Attente de la fin de la pose
       ###  vwait status_cam$audace(camNo)
 
         #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
         ::camera::gestionPose $panneau(acqfen,pose_centrage) 1 cam$audace(camNo) buf$audace(bufNo)
#--- Fin modif Robert

         # Zoom
         if {$panneau(acqfen,typezoom)=="zoom"} {
            visu$audace(visuNo) zoom $panneau(acqfen,bin_centrage)
         } else {
            buf$audace(bufNo) scale [list $panneau(acqfen,bin_centrage) $panneau(acqfen,bin_centrage)] 1
            }
         
#--- Debut modif Robert
###         #--- Visualisation de l'image
###         image delete image0
###         image create photo image0
#--- Fin modif Robert

         #--- Affichage avec visu auto.
#--- Debut modif Robert
         audace::autovisu $audace(visuNo)
#--- Fin modif Robert
              
         # On restitue l'affichage du bouton "GO":
         set panneau(acqfen,go_stop_cent) go
         $This.acqcent.but configure -text $caption(acqfen,GO)
         $This.acqcentred.but configure -text $caption(acqfen,GO)
         
         # On modifie le bouton "Go" des acquisitions fenêtrées
         $This.acq.but configure -text $caption(acqfen,actuxy) -command {::acqfen::ActuCoord}
         $This.acqred.but configure -text $caption(acqfen,actuxy) -command {::acqfen::ActuCoord}
         
         # RAZ du fenêtrage
         set panneau(acqfen,X1)	"-"
         set panneau(acqfen,Y1)	"-"
         set panneau(acqfen,X2)	"-"
         set panneau(acqfen,Y2)	"-"     
         place forget $This.acq.matrice_color_invariant.fen
         place forget $This.acqred.matrice_color_invariant.fen
         $This.acq.matrice_color_invariant.fen config -width $panneau(acqfen,mtx_x) -height $panneau(acqfen,mtx_y)
         $This.acqred.matrice_color_invariant.fen config -width $panneau(acqfen,mtx_x) -height $panneau(acqfen,mtx_y)
         place $This.acq.matrice_color_invariant.fen -x 0 -y 0
         place $This.acqred.matrice_color_invariant.fen -x 0 -y 0
         }
      "stop" {
#--- Debut modif Robert
         #--- Annulation de l'alarme de fin de pose
         catch { after cancel bell }
         #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
         ::camera::gestionPose $panneau(acqfen,pose_centrage) 0 cam$audace(camNo) buf$audace(bufNo)
#--- Fin modif Robert
         #--- Arret de la pose
         catch { cam$audace(camNo) stop }
         after 200
         }         
      }
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
         }
   }


# Procédures d'acquisitions fenêtrées

  proc GoStop {} {
    global panneau audace caption
    variable This
    if { [::cam::list] != "" } {
#--- Debut modif Robert
      #--- Enregistrement de l'extension des fichiers
      set ext [ buf$audace(bufNo) extension ]
      #---
#--- Fin modif Robert
      switch -exact -- $panneau(acqfen,go_stop) {
      "go" {
        # Modification du bouton, pour éviter un second lancement
        set panneau(acqfen,go_stop) stop
        $This.acq.but configure -text $caption(acqfen,stop)
#--- Debut modif Robert
        $This.acqred.but configure -text $caption(acqfen,stop)
#--- Fin modif Robert

        # on désactive toute demande d'arrêt
        set panneau(acqfen,demande_arret) 0

        #--- Suppression de la zone selectionnee avec la souris
#--- Debut modif Robert
        if { [ lindex [ list [ ::confVisu::getBox ] ] 0 ] != "" } {
           ::confVisu::deleteBox
        }
#--- Fin modif Robert

        #--- Mise a jour en-tête audace
        wm title $audace(base) "$caption(acqfen,audace)"

        switch -exact -- $panneau(acqfen,mode) {
        "une" {
          set panneau(acqfen,enregistrer) 0
          acqfen::acq_acqfen
          #--- Affichage avec visu auto
#--- Debut modif Robert
          audace::autovisu $audace(visuNo)
#--- Fin modif Robert
          }
        "serie" {
          # On vérifie l'intégrité des paramètres d'entrée :

          # On vérifie qu'il y a bien un nom de fichier
          if {$panneau(acqfen,nom_image) == ""} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
             -message $caption(acqfen,donnomfich)
            # On restitue l'affichage du bouton "GO" :
            set panneau(acqfen,go_stop) go
            $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
            $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
            return
            }
          # On vérifie que le nom de fichier n'a pas d'espace
          if {[llength $panneau(acqfen,nom_image)] > 1} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
             -message $caption(acqfen,nomblanc)
            # On restitue l'affichage du bouton "GO" :
            set panneau(acqfen,go_stop) go
            $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
            $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
            return
            }
          # On vérifie que le nom de fichier ne contient pas de caractères interdits
          if {[acqfen::TestChaine $panneau(acqfen,nom_image)] == 0} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
             -message $caption(acqfen,mauvcar)
            # On restitue l'affichage du bouton "GO" :
            set panneau(acqfen,go_stop) go
            $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
            $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
            return
            }
          # On vérifie que l'index existe
          if {$panneau(acqfen,index) == ""} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
             -message $caption(acqfen,saisind)
            # On restitue l'affichage du bouton "GO" :
            set panneau(acqfen,go_stop) go
            $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
            $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
            return
            }
          # On vérifie que l'index est bien un nombre entier
          if {[acqfen::TestEntier $panneau(acqfen,index)] == 0} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
             -message $caption(acqfen,indinv)
            # On restitue l'affichage du bouton "GO" :
            set panneau(acqfen,go_stop) go
            $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
            $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
            return
            }
#--- Debut modif Robert
          #--- Envoie un warning si l'index n'est pas a 1
          if { $panneau(acqfen,index) != "1" } {
             set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                -message $caption(acqfen,indpasun)]
             if { $confirmation == "no" } {
                # On restitue l'affichage du bouton "GO" :
                set panneau(acqfen,go_stop) go
                $This.acq.but configure -text $caption(acqfen,GO)
                $This.acqred.but configure -text $caption(acqfen,GO)
                return
             }
          }
#--- Fin modif Robert
          # On vérifie que le nombre d'images à faire existe
          if {$panneau(acqfen,nb_images) == ""} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
             -message $caption(acqfen,saisnbim)
            # On restitue l'affichage du bouton "GO" :
            set panneau(acqfen,go_stop) go
            $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
            $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
            return
            }
          # On vérifie que le nombre d'images à faire est bien un nombre entier
          if {[acqfen::TestEntier $panneau(acqfen,nb_images)] == 0} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
             -message $caption(acqfen,nbiminv)
            # On restitue l'affichage du bouton "GO" :
            set panneau(acqfen,go_stop) go
            $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
            $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
            return
            }
#--- Debut modif Robert
          #--- Verifie que le nom des fichiers n'existe pas deja...
          set nom $panneau(acqfen,nom_image)
          #--- Pour eviter un nom de fichier qui commence par un blanc
          set nom [lindex $nom 0]
          append nom $panneau(acqfen,index) $ext
          if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
             #--- Dans ce cas, le fichier existe deja...
             set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                -message $caption(acqfen,fichdeja)]
             if { $confirmation == "no" } {
                # On restitue l'affichage du bouton "GO" :
                set panneau(acqfen,go_stop) go
                $This.acq.but configure -text $caption(acqfen,GO)
                $This.acqred.but configure -text $caption(acqfen,GO)
                return
             }
          }
#--- Fin modif Robert

          switch -exact -- $panneau(acqfen,fenreglfen2)$panneau(acqfen,fenreglfen3) {
          "11" {
             for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
               if {$panneau(acqfen,demande_arret)==1} {break}
                  # Acquisition
                  acqfen::acq_acqfen
                  # Affichage avec visu auto
#--- Debut modif Robert
                  audace::autovisu $audace(visuNo)
#--- Fin modif Robert
                  # Sauvegarde de l'image
                  set nom $panneau(acqfen,nom_image)
                  # Pour éviter un nom de fichier qui commence par un blanc :
                  set nom [lindex $nom 0]
#--- Debut modif Robert
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqfen,index) $ext
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                     #--- Dans ce cas, le fichier existe deja...
                     set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                        -message $caption(acqfen,fichdeja)]
                     if { $confirmation == "no" } {
                        break
                     }
                  }
                  #--- Sauvegarde de l'image
#--- Fin modif Robert
                  saveima [append nom $panneau(acqfen,index)]
                  incr panneau(acqfen,index)
                  # Corrections éventuelles de suivi
                  if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}	                                    
                  }
               }
            "21" {
              set nbint 1
              for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                if {$panneau(acqfen,demande_arret)==1} {break}
                  # Acquisition
                  acqfen::acq_acqfen                                    
                  # Affichage éventuel
                  if {$nbint==$panneau(acqfen,fenreglfen22)} {
#--- Debut modif Robert
                     audace::autovisu $audace(visuNo)
#--- Fin modif Robert
                     set nbint 1
                  } else {
                     incr nbint
                     }
                  # Sauvegarde de l'image
                  set nom $panneau(acqfen,nom_image)
                  # Pour éviter un nom de fichier qui commence par un blanc :
                  set nom [lindex $nom 0]
#--- Debut modif Robert
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqfen,index) $ext
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                     #--- Dans ce cas, le fichier existe deja...
                     set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                        -message $caption(acqfen,fichdeja)]
                     if { $confirmation == "no" } {
                        break
                     }
                  }
                  #--- Sauvegarde de l'image
#--- Fin modif Robert
                  saveima [append nom $panneau(acqfen,index)]
                  incr panneau(acqfen,index)
                  # Corrections éventuelles de suivi
                  if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}	                                    
                  }
               }
            "31" {
              for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                 if {$panneau(acqfen,demande_arret)==1} {break}
                  # Acquisition
                  acqfen::acq_acqfen                                    
                  # Sauvegarde de l'image
                  set nom $panneau(acqfen,nom_image)
                  # Pour éviter un nom de fichier qui commence par un blanc :
                  set nom [lindex $nom 0]
#--- Debut modif Robert
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqfen,index) $ext
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                     #--- Dans ce cas, le fichier existe deja...
                     set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                        -message $caption(acqfen,fichdeja)]
                     if { $confirmation == "no" } {
                        break
                     }
                  }
                  #--- Sauvegarde de l'image
#--- Fin modif Robert
                  saveima [append nom $panneau(acqfen,index)]
                  incr panneau(acqfen,index)
                  # Corrections éventuelles de suivi
                  if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}	                                    
                  }
               # Affichage avec visu auto
#--- Debut modif Robert
               audace::autovisu $audace(visuNo)
#--- Fin modif Robert
               }	            
            "12" {
              set liste_buffers ""
              for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                if {$panneau(acqfen,demande_arret)==1} {break}
                  # Acquisition
                  acqfen::acq_acqfen
                  # Affichage avec visu auto
#--- Debut modif Robert
                  audace::autovisu $audace(visuNo)
#--- Fin modif Robert
                  # Sauvegarde temporaire de l'image
                  set buftmp [buf::create]
                  buf$audace(bufNo) copyto $buftmp
                  lappend liste_buffers [list $buftmp $panneau(acqfen,index)]
                  incr panneau(acqfen,index)
                  # Corrections éventuelles de suivi
                  if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}	                                    
                  }
               # Sauvegarde des images sur le disque   
               foreach ima $liste_buffers {                                   
                  set nom $panneau(acqfen,nom_image)
                  # Pour éviter un nom de fichier qui commence par un blanc :
                  set nom [lindex $nom 0]
                  buf[lindex $ima 0] copyto $audace(bufNo)
#--- Debut modif Robert
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 [lindex $ima 1] $ext
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                     #--- Dans ce cas, le fichier existe deja...
                     set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                        -message $caption(acqfen,fichdeja)]
                     if { $confirmation == "no" } {
                        break
                     }
                  }
                  #--- Sauvegarde de l'image
#--- Fin modif Robert
                  saveima [append nom [lindex $ima 1]]                  
                  }
               # On libère les buffers temporaires
               foreach ima $liste_buffers {buf::delete [lindex $ima 0]}
               }
            "22" {
              set liste_buffers ""
              set nbint 1
              for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                if {$panneau(acqfen,demande_arret)==1} {break}
                  # Acquisition
                  acqfen::acq_acqfen                                    
                  # Affichage éventuel
                  if {$nbint==$panneau(acqfen,fenreglfen22)} {
#--- Debut modif Robert
                     audace::autovisu $audace(visuNo)
#--- Fin modif Robert
                     set nbint 1
                  } else {
                     incr nbint
                     }
                  # Sauvegarde temporaire de l'image
                  set buftmp [buf::create]
                  buf$audace(bufNo) copyto $buftmp
                  lappend liste_buffers [list $buftmp $panneau(acqfen,index)]
                  incr panneau(acqfen,index)
                  # Corrections éventuelles de suivi
                  if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}	                                    
                  }
               # Sauvegarde des images sur le disque   
               foreach ima $liste_buffers {                                   
                  set nom $panneau(acqfen,nom_image)
                  # Pour éviter un nom de fichier qui commence par un blanc :
                  set nom [lindex $nom 0]
                  buf[lindex $ima 0] copyto $audace(bufNo)
#--- Debut modif Robert
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 [lindex $ima 1] $ext
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                     #--- Dans ce cas, le fichier existe deja...
                     set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                        -message $caption(acqfen,fichdeja)]
                     if { $confirmation == "no" } {
                        break
                     }
                  }
                  #--- Sauvegarde de l'image
#--- Fin modif Robert
                  saveima [append nom [lindex $ima 1]]                  
                  }
               # On libère les buffers temporaires
               foreach ima $liste_buffers {buf::delete [lindex $ima 0]}
               }
            "32" {
              set liste_buffers ""
              for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                if {$panneau(acqfen,demande_arret)==1} {break}
                  # Acquisition
                  acqfen::acq_acqfen                                    
                  # Sauvegarde temporaire de l'image
                  set buftmp [buf::create]
                  buf$audace(bufNo) copyto $buftmp
                  lappend liste_buffers [list $buftmp $panneau(acqfen,index)]
                  incr panneau(acqfen,index)
                  # Corrections éventuelles de suivi
                  if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}	                                    
                  }
               # Sauvegarde des images sur le disque   
               foreach ima $liste_buffers {                                   
                  set nom $panneau(acqfen,nom_image)
                  # Pour éviter un nom de fichier qui commence par un blanc :
                  set nom [lindex $nom 0]
                  buf[lindex $ima 0] copyto $audace(bufNo)
#--- Debut modif Robert
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 [lindex $ima 1] $ext
                  if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                     #--- Dans ce cas, le fichier existe deja...
                     set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                        -message $caption(acqfen,fichdeja)]
                     if { $confirmation == "no" } {
                        break
                     }
                  }
                  #--- Sauvegarde de l'image
#--- Fin modif Robert
                  saveima [append nom [lindex $ima 1]]                  
                  }               
               # Affichage avec visu auto
#--- Debut modif Robert
               audace::autovisu $audace(visuNo)
#--- Fin modif Robert
               }
               # On libère les buffers temporaires
               foreach ima $liste_buffers {buf::delete [lindex $ima 0]}
            }               
            }
         "continu" {
           # On vérifie l'intégrité des paramètres d'entrée :

            # On vérifie qu'il y a bien un nom de fichier
            if {$panneau(acqfen,nom_image) == ""} {
               tk_messageBox -title $caption(acqfen,pb) -type ok \
                -message $caption(acqfen,donnomfich)
               # On restitue l'affichage du bouton "GO" :
               set panneau(acqfen,go_stop) go
               $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
               $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
               return
               }
            # On vérifie que le nom de fichier n'a pas d'espace
            if {[llength $panneau(acqfen,nom_image)] > 1} {
               tk_messageBox -title $caption(acqfen,pb) -type ok \
                -message $caption(acqfen,nomblanc)
               # On restitue l'affichage du bouton "GO" :
               set panneau(acqfen,go_stop) go
               $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
               $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
               return
               }
            # On vérifie que le nom de fichier ne contient pas de caractères interdits
            if {[acqfen::TestChaine $panneau(acqfen,nom_image)] == 0} {
               tk_messageBox -title $caption(acqfen,pb) -type ok \
                -message $caption(acqfen,mauvcar)
               # On restitue l'affichage du bouton "GO" :
               set panneau(acqfen,go_stop) go
               $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
               $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
               return
               }
            # On vérifie que l'index existe
            if {$panneau(acqfen,index) == ""} {
               tk_messageBox -title $caption(acqfen,pb) -type ok \
                -message $caption(acqfen,saisind)
               # On restitue l'affichage du bouton "GO" :
               set panneau(acqfen,go_stop) go
               $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
               $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
               return
               }
            # On vérifie que l'index est bien un nombre entier
            if {[acqfen::TestEntier $panneau(acqfen,index)] == 0} {
               tk_messageBox -title $caption(acqfen,pb) -type ok \
                -message $caption(acqfen,indinv)
               # On restitue l'affichage du bouton "GO" :
               set panneau(acqfen,go_stop) go
               $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
               $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
               return
               }
#--- Debut modif Robert
            #--- Envoie un warning si l'index n'est pas a 1
            if { $panneau(acqfen,index) != "1" } {
               set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                  -message $caption(acqfen,indpasun)]
               if { $confirmation == "no" } {
                  # On restitue l'affichage du bouton "GO" :
                  set panneau(acqfen,go_stop) go
                  $This.acq.but configure -text $caption(acqfen,GO)
                  $This.acqred.but configure -text $caption(acqfen,GO)
                  return
               }
            }
            #--- Verifie que le nom des fichiers n'existe pas deja...
            set nom $panneau(acqfen,nom_image)
            #--- Pour eviter un nom de fichier qui commence par un blanc
            set nom [lindex $nom 0]
            append nom $panneau(acqfen,index) $ext
            if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
               #--- Dans ce cas, le fichier existe deja...
               set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                  -message $caption(acqfen,fichdeja)]
               if { $confirmation == "no" } {
                  # On restitue l'affichage du bouton "GO" :
                  set panneau(acqfen,go_stop) go
                  $This.acq.but configure -text $caption(acqfen,GO)
                  $This.acqred.but configure -text $caption(acqfen,GO)
                  return
               }
            }
#--- Fin modif Robert
            
            switch -exact -- $panneau(acqfen,fenreglfen2)$panneau(acqfen,fenreglfen3) {
               "11" {
                  while {$panneau(acqfen,demande_arret)==0} {
                    # Acquisition
                    acqfen::acq_acqfen
                    # Affichage avec visu auto
#--- Debut modif Robert
                    audace::autovisu $audace(visuNo)
#--- Fin modif Robert
                    # Si demandé, sauvegarde de l'image
                    if {$panneau(acqfen,enregistrer)==1} {
                       set nom $panneau(acqfen,nom_image)
                       # Pour éviter un nom de fichier qui commence par un blanc :
                       set nom [lindex $nom 0]
#--- Debut modif Robert
                       #--- Verifie que le nom du fichier n'existe pas deja...
                       set nom1 "$nom"
                       append nom1 $panneau(acqfen,index) $ext
                       if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                          #--- Dans ce cas, le fichier existe deja...
                          set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                             -message $caption(acqfen,fichdeja)]
                          if { $confirmation == "no" } {
                             break
                          }
                       }
                       #--- Sauvegarde de l'image
#--- Fin modif Robert
                       saveima [append nom $panneau(acqfen,index)]
                       incr panneau(acqfen,index)
                       }
                    # Corrections éventuelles de suivi
                    if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}	                                    
                 }
              }
              "21" {
                 set nbint 1
                 while {$panneau(acqfen,demande_arret)==0} {
                   # Acquisition
                    acqfen::acq_acqfen                                    
                    # Affichage éventuel
                    if {$nbint==$panneau(acqfen,fenreglfen22)} {
#--- Debut modif Robert
                      audace::autovisu $audace(visuNo)
#--- Fin modif Robert
                       set nbint 1
                    } else {
                       incr nbint
                       }
                    # Si demandé, sauvegarde de l'image
                    if {$panneau(acqfen,enregistrer)==1} {
                       set nom $panneau(acqfen,nom_image)
                       # Pour éviter un nom de fichier qui commence par un blanc :
                       set nom [lindex $nom 0]
#--- Debut modif Robert
                       #--- Verifie que le nom du fichier n'existe pas deja...
                       set nom1 "$nom"
                       append nom1 $panneau(acqfen,index) $ext
                       if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                          #--- Dans ce cas, le fichier existe deja...
                          set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                             -message $caption(acqfen,fichdeja)]
                          if { $confirmation == "no" } {
                             break
                          }
                       }
                       #--- Sauvegarde de l'image
#--- Fin modif Robert
                       saveima [append nom $panneau(acqfen,index)]
                       incr panneau(acqfen,index)
                       }
                    # Corrections éventuelles de suivi
                    if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}	                                    
                 }
              }
              "31" {
                  while {$panneau(acqfen,demande_arret)==0} {
                    # Acquisition
                    acqfen::acq_acqfen     
                    # Si demandé, sauvegarde de l'image
                    if {$panneau(acqfen,enregistrer)==1} {
                       set nom $panneau(acqfen,nom_image)
                       # Pour éviter un nom de fichier qui commence par un blanc :
                       set nom [lindex $nom 0]
#--- Debut modif Robert
                       #--- Verifie que le nom du fichier n'existe pas deja...
                       set nom1 "$nom"
                       append nom1 $panneau(acqfen,index) $ext
                       if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                          #--- Dans ce cas, le fichier existe deja...
                          set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                             -message $caption(acqfen,fichdeja)]
                          if { $confirmation == "no" } {
                             break
                          }
                       }
                       #--- Sauvegarde de l'image
#--- Fin modif Robert
                       saveima [append nom $panneau(acqfen,index)]
                       incr panneau(acqfen,index)
                       }
                    # Corrections éventuelles de suivi
                    if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}	                                    
                 }
                 # Affichage avec visu auto
#--- Debut modif Robert
                 audace::autovisu $audace(visuNo)
#--- Fin modif Robert
              }
              "12" {
                  set liste_buffers ""
                  while {$panneau(acqfen,demande_arret)==0} {
                    # Acquisition
                    acqfen::acq_acqfen
                    # Affichage avec visu auto
#--- Debut modif Robert
                    audace::autovisu $audace(visuNo)
#--- Fin modif Robert
                    # Si demandé, sauvegarde temporaire de l'image
                    if {$panneau(acqfen,enregistrer)==1} {                  
                       set buftmp [buf::create]
                       buf$audace(bufNo) copyto $buftmp
                       lappend $liste_buffers [list $buftmp $panneau(acqfen,index)]
                       incr panneau(acqfen,index)
                       }
                    # Corrections éventuelles de suivi
                    if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}	                                    
                 }
                 # Sauvegarde des images sur le disque   
                 foreach ima $liste_buffers {                                   
                    set nom $panneau(acqfen,nom_image)
                    # Pour éviter un nom de fichier qui commence par un blanc :
                    set nom [lindex $nom 0]
                    buf[lindex $ima 0] copyto $audace(bufNo)
#--- Debut modif Robert
                    #--- Verifie que le nom du fichier n'existe pas deja...
                    set nom1 "$nom"
                    append nom1 [lindex $ima 1] $ext
                    if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                       #--- Dans ce cas, le fichier existe deja...
                       set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                          -message $caption(acqfen,fichdeja)]
                       if { $confirmation == "no" } {
                          break
                       }
                    }
                    #--- Sauvegarde de l'image
#--- Fin modif Robert
                    saveima [append nom [lindex $ima 1]]                  
                 }
              }
              "22" {
                  set nbint 1
                  while {$panneau(acqfen,demande_arret)==0} {
                    # Acquisition
                    acqfen::acq_acqfen                                    
                    # Affichage éventuel
                    if {$nbint==$panneau(acqfen,fenreglfen22)} {
#--- Debut modif Robert
                       audace::autovisu $audace(visuNo)
#--- Fin modif Robert
                       set nbint 1
                    } else {
                       incr nbint
                       }
                    # Si demandé, sauvegarde temporaire de l'image
                    if {$panneau(acqfen,enregistrer)==1} {                     
                       set buftmp [buf::create]
                       buf$audace(bufNo) copyto $buftmp
                       lappend $liste_buffers [list $buftmp $panneau(acqfen,index)]
                       incr panneau(acqfen,index)
                       }
                    # Corrections éventuelles de suivi
                    if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}	                                    
                 }
                 # Sauvegarde des images sur le disque   
                 foreach ima $liste_buffers {                                   
                    set nom $panneau(acqfen,nom_image)
                    # Pour éviter un nom de fichier qui commence par un blanc :
                    set nom [lindex $nom 0]
                    buf[lindex $ima 0] copyto $audace(bufNo)
#--- Debut modif Robert
                    #--- Verifie que le nom du fichier n'existe pas deja...
                    set nom1 "$nom"
                    append nom1 [lindex $ima 1] $ext
                    if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                       #--- Dans ce cas, le fichier existe deja...
                       set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                          -message $caption(acqfen,fichdeja)]
                       if { $confirmation == "no" } {
                          break
                       }
                    }
                    #--- Sauvegarde de l'image
#--- Fin modif Robert
                    saveima [append nom [lindex $ima 1]]                  
                 }
              }
              "32" {
                  while {$panneau(acqfen,demande_arret)==0} {
                    # Acquisition
                    acqfen::acq_acqfen
                    # Si demandé, sauvegarde temporaire de l'image
                    if {$panneau(acqfen,enregistrer)==1} {                                
                       set buftmp [buf::create]
                       buf$audace(bufNo) copyto $buftmp
                       lappend $liste_buffers [list $buftmp $panneau(acqfen,index)]
                       incr panneau(acqfen,index)
                       }
                    # Corrections éventuelles de suivi
                    if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}	                                    
                    }
                    # Sauvegarde des images sur le disque   
                    foreach ima $liste_buffers {                                   
                       set nom $panneau(acqfen,nom_image)
                       # Pour éviter un nom de fichier qui commence par un blanc :
                       set nom [lindex $nom 0]
                       buf[lindex $ima 0] copyto $audace(bufNo)
#--- Debut modif Robert
                       #--- Verifie que le nom du fichier n'existe pas deja...
                       set nom1 "$nom"
                       append nom1 [lindex $ima 1] $ext
                       if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                          #--- Dans ce cas, le fichier existe deja...
                          set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                             -message $caption(acqfen,fichdeja)]
                          if { $confirmation == "no" } {
                             break
                          }
                       }
                       #--- Sauvegarde de l'image
#--- Fin modif Robert
                       saveima [append nom [lindex $ima 1]]                  
                    }               
                    # Affichage avec visu auto
#--- Debut modif Robert
                    audace::autovisu $audace(visuNo)
#--- Fin modif Robert
                 }               
              }
            }       
         }                                                 
         # On restitue l'affichage du bouton "GO" :
         set panneau(acqfen,go_stop) go
         $This.acq.but configure -text $caption(acqfen,GO)
#--- Debut modif Robert
         $This.acqred.but configure -text $caption(acqfen,GO)
#--- Fin modif Robert
         }
      "stop" {
         # On positionne un indicateur de demande d'arrêt
         set panneau(acqfen,demande_arret) 1
#--- Debut modif Robert
         #--- Annulation de l'alarme de fin de pose
         catch { after cancel bell }
         #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
         ::camera::gestionPose $panneau(acqfen,pose) 0 cam$audace(camNo) buf$audace(bufNo)
#--- Fin modif Robert
         # Arret de la pose
         catch { cam$audace(camNo) stop }
         after 200
         }
      }
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
         }      
   }

   
   proc acq_acqfen {} {
      global audace conf caption panneau
      variable This

      #--- Raccourcis
      set camxis1 [lindex [cam$audace(camNo) nbcells] 0]
      set camxis2 [lindex [cam$audace(camNo) nbcells] 1]

      #--- La commande bin permet de fixer le binning.
      cam$audace(camNo) bin [list $panneau(acqfen,bin) $panneau(acqfen,bin)]

      #--- La commande window permet de fixer le fenêtrage de numérisation du CCD
      if {$panneau(acqfen,X1) == "-"} {
         cam$audace(camNo) window [list 1 1 $camxis1 $camxis2]
      } else {
         cam$audace(camNo) window [list $panneau(acqfen,X1) $panneau(acqfen,Y1) \
         $panneau(acqfen,X2) $panneau(acqfen,Y2)]
      }

      #--- Acquisition
      if {$panneau(acqfen,fenreglfen1)=="1"} {
         # Acquisitions avec nombre d'effacements préalables par défaut
         #--- La commande exptime permet de fixer le temps de pose de l'image.
         cam$audace(camNo) exptime $panneau(acqfen,pose)
#--- Debut modif Robert
         #--- Cas des poses de 0 s : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
         if { $panneau(acqfen,pose) == "0" } {
            ::camera::Avancement_pose "1"
         }
#--- Fin modif Robert
         #--- Acquisition
         cam$audace(camNo) acq
         #--- Alarme sonore de fin de pose
         ::camera::alarme_sonore $panneau(acqfen,pose)
#--- Debut modif Robert
        ### #--- Attente de la fin de la pose
        ### vwait status_cam$audace(camNo)
 
         #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
         ::camera::gestionPose $panneau(acqfen,pose) 1 cam$audace(camNo) buf$audace(bufNo)
#--- Fin modif Robert
      } else {
         for {set k 1} {$k<=$panneau(acqfen,fenreglfen12)} {incr k} {cam$audace(camNo) wipe}
         after [expr int(1000*$panneau(acqfen,pose))] [cam$audace(camNo) read]
      }

#--- Debut modif Robert
###      #--- Chargement de l'image dans le buffer Aud'ACE
###      image delete image0
###      image create photo image0
#--- Fin modif Robert
   }


   # Procédures d'actualisation des coordonnées
#--- Debut modif Robert
   proc ActuCoord { { visuNo "1" } } {
      global audace caption panneau
      variable This
      set box [ ::confVisu::getBox $visuNo ]
      if { $box != "" } {
           if {[lindex $box 0]<[lindex $box 2]} {
              set panneau(acqfen,X1) [lindex $box 0]
              set panneau(acqfen,X2) [lindex $box 2]
           } else {
              set panneau(acqfen,X1) [lindex $box 2]
              set panneau(acqfen,X2) [lindex $box 0]
              }
           if {[lindex $box 1]<[lindex $box 3]} {
              set panneau(acqfen,Y1) [lindex $box 1]
              set panneau(acqfen,Y2) [lindex $box 3]
           } else {
              set panneau(acqfen,Y1) [lindex $box 3]
              set panneau(acqfen,Y2) [lindex $box 1]
              }
#--- Fin modif Robert

           set hauteur [expr $panneau(acqfen,mtx_y)*($panneau(acqfen,Y2)-$panneau(acqfen,Y1))/[lindex [cam$audace(camNo) nbcells] 1]]
           $This.acq.matrice_color_invariant.fen config  -height $hauteur \
            -width [expr $panneau(acqfen,mtx_x)*($panneau(acqfen,X2)-$panneau(acqfen,X1))/[lindex [cam$audace(camNo) nbcells] 0]]
           $This.acqred.matrice_color_invariant.fen config  -height $hauteur \
            -width [expr $panneau(acqfen,mtx_x)*($panneau(acqfen,X2)-$panneau(acqfen,X1))/[lindex [cam$audace(camNo) nbcells] 0]]           
           place forget $This.acq.matrice_color_invariant.fen
           place forget $This.acqred.matrice_color_invariant.fen
           place $This.acq.matrice_color_invariant.fen \
            -x [expr $panneau(acqfen,mtx_x)*$panneau(acqfen,X1)/[lindex [cam$audace(camNo) nbcells] 0]] \
            -y [expr $panneau(acqfen,mtx_y)*([lindex [cam$audace(camNo) nbcells] 1]-$panneau(acqfen,Y1))/[lindex [cam$audace(camNo) nbcells] 1]-$hauteur]
           place $This.acqred.matrice_color_invariant.fen \
            -x [expr $panneau(acqfen,mtx_x)*$panneau(acqfen,X1)/[lindex [cam$audace(camNo) nbcells] 0]] \
            -y [expr $panneau(acqfen,mtx_y)*([lindex [cam$audace(camNo) nbcells] 1]-$panneau(acqfen,Y1))/[lindex [cam$audace(camNo) nbcells] 1]-$hauteur]
          
           # On modifie le bouton "Go" des acquisitions fenêtrées
           $This.acq.but configure -text $caption(acqfen,GO) -command {::acqfen::GoStop}
           $This.acqred.but configure -text $caption(acqfen,GO) -command {::acqfen::GoStop}
       }
   }
   
   # Procédure de gestion du mode d'acquisition
   proc ChangeMode {} {
      global caption panneau
      variable This

      switch -exact -- $panneau(acqfen,mode) {
         "une" {
            # On efface  l'ancien sous-panneau
            pack forget $This.mode.une -fill x
            # On met le nouveau à sa place
            pack $This.mode.serie -fill x -anchor nw
            $This.mode.but configure -text $caption(acqfen,serie)
            set panneau(acqfen,mode) "serie"
            }
         "serie" {
            # On efface  l'ancien sous-panneau
            pack forget $This.mode.serie -fill x
            # On met le nouveau à sa place
            pack $This.mode.continu -fill x -anchor nw
            $This.mode.but configure -text $caption(acqfen,continu)         
            set panneau(acqfen,mode) "continu"
            }
         "continu" {
            # On efface  l'ancien sous-panneau
            pack forget $This.mode.continu -fill x
            # On met le nouveau à sa place
            pack $This.mode.une -fill x -anchor nw
            $This.mode.but configure -text $caption(acqfen,uneimage)         
            set panneau(acqfen,mode) "une"
            }
      }
   }

  # Procédure de suivi par déplacement de la fenêtre
  proc depl_fen {} {
    global audace 
    set dimx [lindex [[buf$audace(bufNo) getkwd NAXIS1 ] 1]
    set dimy [lindex [[buf$audace(bufNo) getkwd NAXIS2 ] 1]
    set centro [buf$audace(bufNo) centro [list 1 1 $dimx $dimy ]] 
    set depl [list [expr [lindex $centro 0]-0.5*[lindex $format 0]] [expr [lindex $centro 1]-0.5*[lindex $format 1]]]
    set depl_corr [list [expr 1.*[lindex $depl 0]*$panneau(acqfen,fenreglfen42)] [expr 1.*[lindex $depl 1]*$panneau(acqfen,fenreglfen42)]]
    
    incr panneau(acqfen,X1) [lindex $depl_corr 0]
    incr panneau(acqfen,X2) [lindex $depl_corr 0]
    incr panneau(acqfen,Y1) [lindex $depl_corr 1]
    incr panneau(acqfen,Y2) [lindex $depl_corr 1]
    
    set hauteur [expr $panneau(acqfen,mtx_y)*($panneau(acqfen,Y2)-$panneau(acqfen,Y1))/[lindex [cam$audace(camNo) nbcells] 1]]
    $This.acq.matrice_color_invariant.fen config  -height $hauteur \
     -width [expr $panneau(acqfen,mtx_x)*($panneau(acqfen,X2)-$panneau(acqfen,X1))/[lindex [cam$audace(camNo) nbcells] 0]]
    $This.acqred.matrice_color_invariant.fen config  -height $hauteur \
     -width [expr $panneau(acqfen,mtx_x)*($panneau(acqfen,X2)-$panneau(acqfen,X1))/[lindex [cam$audace(camNo) nbcells] 0]]           
    place forget $This.acq.matrice_color_invariant.fen
    place forget $This.acqred.matrice_color_invariant.fen
    place $This.acq.matrice_color_invariant.fen \
     -x [expr $panneau(acqfen,mtx_x)*$panneau(acqfen,X1)/[lindex [cam$audace(camNo) nbcells] 0]] \
     -y [expr $panneau(acqfen,mtx_y)*([lindex [cam$audace(camNo) nbcells] 1]-$panneau(acqfen,Y1))/[lindex [cam$audace(camNo) nbcells] 1]-$hauteur]
    place $This.acqred.matrice_color_invariant.fen \
     -x [expr $panneau(acqfen,mtx_x)*$panneau(acqfen,X1)/[lindex [cam$audace(camNo) nbcells] 0]] \
     -y [expr $panneau(acqfen,mtx_y)*([lindex [cam$audace(camNo) nbcells] 1]-$panneau(acqfen,Y1))/[lindex [cam$audace(camNo) nbcells] 1]-$hauteur]
}
   
# Procédures reprises depuis acqFC.tcl :

#***** Procedure de sauvegarde de l'image **********************
# Cette routine est largement inspirée de Acq.tcl, livré avec Audela.
# Procedure lancee par appui sur le bouton "enregistrer", uniquement dans le
#    mode "Une image".
   proc SauveUneImage {} {
      variable This
      global panneau caption audace

#--- Debut modif Robert
      #--- Enregistrement de l'extension des fichiers
      set ext [ buf$audace(bufNo) extension ]
#--- Fin modif Robert

      # Vérifier qu'il y a bien un nom de fichier
      if {$panneau(acqfen,nom_image) == ""} {
         tk_messageBox -title $caption(acqfen,pb) -type ok \
            -message $caption(acqfen,donnomfich)
         return
         }
      # Vérifie que le nom de fichier n'a pas d'espace
      if {[llength $panneau(acqfen,nom_image)] > 1} {
         tk_messageBox -title $caption(acqfen,pb) -type ok \
            -message $caption(acqfen,nomblanc)
         return
         }
      # Vérifie que le nom de fichier ne contient pas de caractères interdits
      if {[acqfen::TestChaine $panneau(acqfen,nom_image)] == 0} {
         tk_messageBox -title $caption(acqfen,pb) -type ok \
            -message $caption(acqfen,mauvcar)
         return
         }
      # Si la case index est cochée, vérifier qu'il y a bien un index
      if {$panneau(acqfen,indexer) == 1} {
         # Vérifie que l'index existe
         if {$panneau(acqfen,index) == ""} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
               -message $caption(acqfen,saisind)
            return
            }
         # Verifier que l'index est bien un nombre entier
         if {[acqfen::TestEntier $panneau(acqfen,index)] == 0} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
               -message $caption(acqfen,indinv)
            return
            }
         }

      # Génération du nom de fichier
      set nom $panneau(acqfen,nom_image)
      # Pour éviter un nom de fichier qui commence par un blanc:
      set nom [lindex $nom 0]
      if {$panneau(acqfen,indexer) == 1 } {
         append nom $panneau(acqfen,index)
#--- Debut modif Robert
        # incr panneau(acqfen,index)
#--- Fin modif Robert
         }

#--- Debut modif Robert
      #--- Verifie que le nom du fichier n'existe pas deja...
      set nom1 "$nom"
      append nom1 $ext
      if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
         #--- Dans ce cas, le fichier existe deja...
         set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
            -message $caption(acqfen,fichdeja)]
         if { $confirmation == "no" } {
            return
            }
         }

      #--- Incremente l'index
      if {$panneau(acqfen,indexer) == 1 } {
         incr panneau(acqfen,index)
         }
#--- Fin modif Robert

      # Sauvegarde de l'image
      saveima $nom
   }
#***** Fin de la procédure de sauvegarde de l'image *************

#***** Procedure de test de validité d'un entier *****************
# Cette procédure (copiée de Methking) vérifie que la chaine passée en argument décrit
# bien un entier. Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un entier.
   proc TestEntier {valeur} {
      set test 1
      for {set i 0} {$i < [string length $valeur]} {incr i} {
         set a [string index $valeur $i]
         if {![string match {[0-9]} $a]} {
            set test 0
            }
         }
      if {$valeur==""} {set test 0}
      return $test
   }
#***** Fin de la procedure de test de validité d'une entier *******

#***** Procedure de test de validité d'une chaine de caractères *******
# Cette procédure vérifie que la chaine passée en argument ne contient que des caractères
# valides. Elle retourne 1 si c'est la cas, et 0 si ce n'est pas valable.
   proc TestChaine {valeur} {
      set test 1
      for {set i 0} {$i < [string length $valeur]} {incr i} {
         set a [string index $valeur $i]
         if {![string match {[-a-zA-Z0-9_]} $a]} {
            set test 0
            }
         }
      return $test
   }
#***** Fin de la procedure de test de validité d'une chaine de caractères *******

   proc fenreglfenquit {} {
	global panneau conf audace

      set panneau(acqfen,fenreglfen1)  $panneau(acqfen,oldfenreglfen1)
      set panneau(acqfen,fenreglfen12) $panneau(acqfen,oldfenreglfen12)
      set panneau(acqfen,fenreglfen2)  $panneau(acqfen,oldfenreglfen2)
      set panneau(acqfen,fenreglfen22) $panneau(acqfen,oldfenreglfen22)
      set panneau(acqfen,fenreglfen3)  $panneau(acqfen,oldfenreglfen3)
      set panneau(acqfen,fenreglfen4)  $panneau(acqfen,oldfenreglfen4)
      #--- Récupération de la position de la fenêtre de réglages
      ::acqfen::recup_position
      set conf(fenreglfen,position)    $panneau(acqfen,position)
      #---
      destroy $audace(base).fenreglfen
   }

#---Procédure de récupération de la position de la fenêtre de réglage

   proc recup_position { } {
      global panneau audace

      set panneau(acqfen,geometry) [ wm geometry $audace(base).fenreglfen ]
      set deb [ expr 1 + [ string first + $panneau(acqfen,geometry) ] ]
      set fin [ string length $panneau(acqfen,geometry) ]
      set panneau(acqfen,position) "+[string range $panneau(acqfen,geometry) $deb $fin]"     
   }

}

# ===============================
# === fin du namespace acqfen ===
# ===============================


proc acqfenBuildIF {This} {

# ============================
# === graphisme de l'outil ===
# ============================

global audace panneau caption color

#--- Trame du panneau

frame $This -borderwidth 2 -relief groove

   #--- Trame du titre panneau
#--- Debut modif Robert
   frame $This.titre -borderwidth 2 -relief groove
   pack $This.titre -side top -fill x
#--- Fin modif Robert

   Button $This.titre.but -borderwidth 1 -text $caption(acqfen,titre_fenetrees) \
      -command {
         ::audace::showHelpPlugin tool acqfen acqfen.htm
      }
   pack $This.titre.but -in $This.titre -anchor center -expand 1 -fill both -side top -ipadx 5
   DynamicHelp::add $This.titre.but -text $caption(acqfen,help_titre)

   bind $This.titre.but <ButtonPress-3> { Creefenreglfen }

   #--- Trame acquisition centrage (version complète)
#--- Debut modif Robert
   frame $This.acqcent -borderwidth 1 -relief groove
#--- Fin modif Robert

      #--- Sous-titre "acquisition pleine trame"
      button $This.acqcent.titre -text $caption(acqfen,titre_centrage) \
         -command {::acqfen::ChangeAffPleineTrame} -borderwidth 0
      pack $This.acqcent.titre -expand true -fill x -pady 2
      
      #--- Sous-trame pour temps de pose
      frame $This.acqcent.pose -borderwidth 1 -height 77 -relief groove

         #--- Bouton temps de pose
         menubutton $This.acqcent.pose.posebut -text $caption(acqfen,pose) -relief raised \
            -menu $This.acqcent.pose.posebut.menu
         pack $This.acqcent.pose.posebut -side left
         set m [menu $This.acqcent.pose.posebut.menu -tearoff 0]
         foreach temps $panneau(acqfen,temps_pose_centrage) {
            $m add radiobutton -label "$temps" \
               -indicatoron "1" \
               -value "$temps" \
               -variable panneau(acqfen,pose_centrage) \
               -command { }
         }

         #--- Label des secondes
         label $This.acqcent.pose.sec -text $caption(acqfen,sec)
         pack $This.acqcent.pose.sec -side right

         #--- Ligne de saisie du temps de pose
         entry $This.acqcent.pose.pose_ent -font $audace(font,arial_8_b) -width 4 \
            -textvariable panneau(acqfen,pose_centrage) -relief groove -justify center
         pack $This.acqcent.pose.pose_ent -side left -fill y

      pack $This.acqcent.pose -expand true

      #--- Bouton binning
      button $This.acqcent.butbin -text $caption(acqfen,bin,$panneau(acqfen,bin_centrage)) \
         -command {::acqfen::ChangeBinCent}
      pack $This.acqcent.butbin -expand true

      #--- Bouton Go/Stop
      button $This.acqcent.but -text $caption(acqfen,GO) -font $audace(font,arial_12_b) -borderwidth 3 \
         -command ::acqfen::GoStopCent
      pack $This.acqcent.but -expand true -fill both

   #--- Trame acquisition centrage (version réduite)
#--- Debut modif Robert
   frame $This.acqcentred -borderwidth 1 -relief groove
#--- Fin modif Robert

      #--- Sous-titre "acquisition pleine trame"
      button $This.acqcentred.titre -text $caption(acqfen,titre_centrage) \
         -command {::acqfen::ChangeAffPleineTrame} -borderwidth 0
      pack $This.acqcentred.titre -expand true -fill x -pady 2
      
      #--- Bouton Go/Stop
      button $This.acqcentred.but -text $caption(acqfen,GO) -font $audace(font,arial_12_b) -borderwidth 3 \
         -command ::acqfen::GoStopCent
      pack $This.acqcentred.but -expand true -fill both            

   #--- Trame acquisition (version complète)
#--- Debut modif Robert
   frame $This.acq -borderwidth 1 -relief groove
#--- Fin modif Robert

      #--- Sous-titre "acquisitions fenêtrées"
      button $This.acq.titre -text $caption(acqfen,titre_fenetrees) \
         -command {::acqfen::ChangeAffFenetrees} -borderwidth 0
      pack $This.acq.titre -expand true -fill x -pady 2

      #--- Sous-trame pour temps de pose
      frame $This.acq.pose -borderwidth 1 -height 77 -relief groove

         #--- Bouton temps de pose
         menubutton $This.acq.pose.posebut -text $caption(acqfen,pose) -relief raised \
            -menu $This.acq.pose.posebut.menu
         pack $This.acq.pose.posebut -side left
         set m [menu $This.acq.pose.posebut.menu -tearoff 0]
         foreach temps $panneau(acqfen,temps_pose) {
            $m add radiobutton -label "$temps" \
               -indicatoron "1" \
               -value "$temps" \
               -variable panneau(acqfen,pose) \
               -command { }
         }

         #--- Label des secondes
         label $This.acq.pose.sec -text $caption(acqfen,sec)
         pack $This.acq.pose.sec -side right

         #--- Ligne de saisie du temps de pose
         entry $This.acq.pose.pose_ent -font $audace(font,arial_8_b) -width 4 \
            -textvariable panneau(acqfen,pose) -relief groove -justify center
         pack $This.acq.pose.pose_ent -side left -fill y

      pack $This.acq.pose -expand true

      #--- Bouton binning
      button $This.acq.butbin -text $caption(acqfen,bin,$panneau(acqfen,bin)) \
         -command {::acqfen::ChangeBin}
      pack $This.acq.butbin -expand true 

      #--- Représentation matrice CCD
      frame $This.acq.matrice_color_invariant -bg $color(blue) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acq.matrice_color_invariant      
      frame $This.acq.matrice_color_invariant.fen -bg $color(cyan) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acq.matrice_color_invariant.fen 

      #--- Bouton Go/Stop
      button $This.acq.but -text $caption(acqfen,actuxy) -font $audace(font,arial_12_b) -borderwidth 3 \
         -command {::acqfen::ActuCoord}        
      pack $This.acq.but -expand true -fill both

   #--- Trame acquisition (version réduite)
#--- Debut modif Robert
   frame $This.acqred -borderwidth 1 -relief groove
#--- Fin modif Robert

      #--- Sous-titre "acquisitions fenêtrées"
      button $This.acqred.titre -text $caption(acqfen,titre_fenetrees) \
         -command {::acqfen::ChangeAffFenetrees} -borderwidth 0
      pack $This.acqred.titre -expand true -fill x -pady 2

      #--- Représentation matrice CCD
      frame $This.acqred.matrice_color_invariant -bg $color(blue) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acqred.matrice_color_invariant      
      frame $This.acqred.matrice_color_invariant.fen -bg $color(cyan) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acqred.matrice_color_invariant.fen

      #--- Bouton Go/Stop
      button $This.acqred.but -text $caption(acqfen,actuxy) -font $audace(font,arial_12_b) -borderwidth 3 \
         -command {::acqfen::ActuCoord}
      pack $This.acqred.but -expand true -fill both

   #--- Trame du mode d'acquisition
   frame $This.mode -borderwidth 2 -relief groove

#--- Debut modif Robert
      button $This.mode.but -text $panneau(acqfen,bouton_mode) -font $audace(font,arial_10_b) \
         -command ::acqfen::ChangeMode
      pack $This.mode.but -expand true -fill both
#--- Debut modif Robert

      # Définition du sous-panneau "Mode: Une seule image"
      frame $This.mode.une -borderwidth 0
#--- Debut modif Robert
     ### pack $This.mode.une -fill x -anchor nw
#--- Debut modif Robert

         frame $This.mode.une.nom -relief ridge -borderwidth 2
            label $This.mode.une.nom.but -text $caption(acqfen,nom) -pady 0 
            pack $This.mode.une.nom.but -fill x -side top
            entry $This.mode.une.nom.entr -width 10 -textvariable panneau(acqfen,nom_image) \
               -font $audace(font,arial_10_b) -relief groove
            pack $This.mode.une.nom.entr -fill x -side top
         pack $This.mode.une.nom -expand true -fill both
         frame $This.mode.une.index -relief ridge -borderwidth 2
            checkbutton $This.mode.une.index.case -pady 0 -text $caption(acqfen,index)\
               -variable panneau(acqfen,indexer)
            pack $This.mode.une.index.case -expand true -fill both
            entry $This.mode.une.index.entr -width 3 -textvariable panneau(acqfen,index) \
               -font $audace(font,arial_10_b) -relief groove -justify center 
            pack $This.mode.une.index.entr -side left -fill x -expand true
            button $This.mode.une.index.but -text "1" -width 3 -command {set panneau(acqfen,index) 1}
            pack $This.mode.une.index.but -side right -fill x
         pack $This.mode.une.index -expand true -fill both
         button $This.mode.une.sauve -text $caption(acqfen,sauvegde) \
            -command ::acqfen::SauveUneImage 
         pack $This.mode.une.sauve -expand true -fill both

      # Définition du sous-panneau "Mode: Serie d'image"
      frame $This.mode.serie -borderwidth 0
         frame $This.mode.serie.nom -relief ridge -borderwidth 2
            label $This.mode.serie.nom.but -text $caption(acqfen,nom) -pady 0 
            pack $This.mode.serie.nom.but -fill x
            entry $This.mode.serie.nom.entr -width 10 -textvariable panneau(acqfen,nom_image) \
               -font $audace(font,arial_10_b) -relief groove
            pack $This.mode.serie.nom.entr -fill x
         pack $This.mode.serie.nom -expand true -fill both
         frame $This.mode.serie.nb -relief ridge -borderwidth 2
            label $This.mode.serie.nb.but -text $caption(acqfen,nombre) -pady 0
            pack $This.mode.serie.nb.but -side left -fill y
            entry $This.mode.serie.nb.entr -width 3 -textvariable panneau(acqfen,nb_images) \
               -font $audace(font,arial_10_b) -relief groove -justify center
            pack $This.mode.serie.nb.entr -side left -fill x -expand true
         pack $This.mode.serie.nb -expand true -fill both
         frame $This.mode.serie.index -relief ridge -borderwidth 2
            label $This.mode.serie.index.lab -text $caption(acqfen,index) -pady 0
            pack $This.mode.serie.index.lab -expand true -fill both
            entry $This.mode.serie.index.entr -width 3 -textvariable panneau(acqfen,index) \
               -font $audace(font,arial_10_b) -relief groove -justify center 
            pack $This.mode.serie.index.entr -side left -fill x -expand true
            button $This.mode.serie.index.but -text "1" -width 3 -command {set panneau(acqfen,index) 1}
            pack $This.mode.serie.index.but -side right -fill x
         pack $This.mode.serie.index -expand true -fill both

      # Définition du sous-panneau "Mode: Continu"
      frame $This.mode.continu -borderwidth 0
         frame $This.mode.continu.sauve -relief ridge -borderwidth 2
            checkbutton $This.mode.continu.sauve.case -text $caption(acqfen,enregistrer) \
               -variable panneau(acqfen,enregistrer)
            pack $This.mode.continu.sauve.case -side left -fill x  -expand true
         pack $This.mode.continu.sauve -expand true -fill both
         frame $This.mode.continu.nom -relief ridge -borderwidth 2
            label $This.mode.continu.nom.but -text $caption(acqfen,nom) -pady 0
            pack $This.mode.continu.nom.but -fill x
            entry $This.mode.continu.nom.entr -width 10 -textvariable panneau(acqfen,nom_image) \
               -font $audace(font,arial_10_b) -relief groove
            pack $This.mode.continu.nom.entr -fill x
         pack $This.mode.continu.nom -expand true -fill both
         frame $This.mode.continu.index -relief ridge -borderwidth 2
            label $This.mode.continu.index.lab -text $caption(acqfen,index) -pady 0
            pack $This.mode.continu.index.lab -expand true -fill both
            entry $This.mode.continu.index.entr -width 3 -textvariable panneau(acqfen,index) \
               -font $audace(font,arial_10_b) -relief groove -justify center
            pack $This.mode.continu.index.entr -side left -fill x -expand true
            button $This.mode.continu.index.but -text "1" -width 3 -command {set panneau(acqfen,index) 1}
            pack $This.mode.continu.index.but -side right -fill x
         pack $This.mode.continu.index -expand true -fill both

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

#---Procédure d'affichage de la fenêtre de réglages acquisition série et continu

proc Creefenreglfen {} {
   global panneau caption infos audace conf

   if { ! [ info exists conf(fenreglfen,position) ] } { set conf(fenreglfen,position) "+0+0" }

   set panneau(acqfen,position) $conf(fenreglfen,position)

   if { [ info exists panneau(acqfen,geometry) ] } {
      set deb [ expr 1 + [ string first + $panneau(acqfen,geometry) ] ]
      set fin [ string length $panneau(acqfen,geometry) ]
      set panneau(acqfen,position) "+[string range $panneau(acqfen,geometry) $deb $fin]"     
   }

   if {[winfo exists $audace(base).fenreglfen] == 0} {
      # Création de la fenêtre
      toplevel $audace(base).fenreglfen
      wm geometry $audace(base).fenreglfen 400x370$panneau(acqfen,position)
      wm title $audace(base).fenreglfen $caption(acqfen,fenreglfen)
      wm protocol $audace(base).fenreglfen WM_DELETE_WINDOW ::acqfen::fenreglfenquit
      
      # Enregistrement des réglages courants
      set panneau(acqfen,oldfenreglfen1)  $panneau(acqfen,fenreglfen1)
      set panneau(acqfen,oldfenreglfen12) $panneau(acqfen,fenreglfen12)
      set panneau(acqfen,oldfenreglfen2)  $panneau(acqfen,fenreglfen2)
      set panneau(acqfen,oldfenreglfen22) $panneau(acqfen,fenreglfen22)
      set panneau(acqfen,oldfenreglfen3)  $panneau(acqfen,fenreglfen3)
      set panneau(acqfen,oldfenreglfen4)  $panneau(acqfen,fenreglfen4)
     
      # Trame réglages
      frame $audace(base).fenreglfen.1
      pack $audace(base).fenreglfen.1 -expand true -fill x                
      label $audace(base).fenreglfen.1.lab -text $caption(acqfen,fenreglfen1)
      pack $audace(base).fenreglfen.1.lab
      frame $audace(base).fenreglfen.1.1
      pack $audace(base).fenreglfen.1.1 -expand true -fill x
      radiobutton $audace(base).fenreglfen.1.1.but -text $caption(acqfen,fenreglfen11) \
         -variable panneau(acqfen,fenreglfen1) -value 1
      pack $audace(base).fenreglfen.1.1.but -side left
      frame $audace(base).fenreglfen.1.2
      pack $audace(base).fenreglfen.1.2 -expand true -fill x
      radiobutton $audace(base).fenreglfen.1.2.but -text $caption(acqfen,fenreglfen12) \
         -variable panneau(acqfen,fenreglfen1) -value 2
      pack $audace(base).fenreglfen.1.2.but -side left
      entry $audace(base).fenreglfen.1.2.ent -textvariable panneau(acqfen,fenreglfen12) \
         -font $audace(font,arial_8_b) -width 10 -justify center
      pack $audace(base).fenreglfen.1.2.ent -side left    
      frame $audace(base).fenreglfen.2
      pack $audace(base).fenreglfen.2 -expand true -fill x                
      label $audace(base).fenreglfen.2.lab -text $caption(acqfen,fenreglfen2)
      pack $audace(base).fenreglfen.2.lab
      frame $audace(base).fenreglfen.2.1
      pack $audace(base).fenreglfen.2.1 -expand true -fill x
      radiobutton $audace(base).fenreglfen.2.1.but -text $caption(acqfen,fenreglfen21) \
         -variable panneau(acqfen,fenreglfen2) -value 1
      pack $audace(base).fenreglfen.2.1.but -side left
      frame $audace(base).fenreglfen.2.2
      pack $audace(base).fenreglfen.2.2 -expand true -fill x
      radiobutton $audace(base).fenreglfen.2.2.but -text $caption(acqfen,fenreglfen22) \
         -variable panneau(acqfen,fenreglfen2) -value 2
      pack $audace(base).fenreglfen.2.2.but -side left
      entry $audace(base).fenreglfen.2.2.ent -textvariable panneau(acqfen,fenreglfen22) \
         -font $audace(font,arial_8_b) -width 10 -justify center
      pack $audace(base).fenreglfen.2.2.ent -side left    
      frame $audace(base).fenreglfen.2.3
      pack $audace(base).fenreglfen.2.3 -expand true -fill x
      radiobutton $audace(base).fenreglfen.2.3.but -text $caption(acqfen,fenreglfen23) \
         -variable panneau(acqfen,fenreglfen2) -value 3
      pack $audace(base).fenreglfen.2.3.but -side left      
      frame $audace(base).fenreglfen.3
      pack $audace(base).fenreglfen.3 -expand true -fill x
      label $audace(base).fenreglfen.3.lab -text $caption(acqfen,fenreglfen3)
      pack $audace(base).fenreglfen.3.lab
      frame $audace(base).fenreglfen.3.1
      pack $audace(base).fenreglfen.3.1 -expand true -fill x
      radiobutton $audace(base).fenreglfen.3.1.but -text $caption(acqfen,fenreglfen31) \
         -variable panneau(acqfen,fenreglfen3) -value 1
      pack $audace(base).fenreglfen.3.1.but -side left
      frame $audace(base).fenreglfen.3.2
      pack $audace(base).fenreglfen.3.2 -expand true -fill x
      radiobutton $audace(base).fenreglfen.3.2.but -text $caption(acqfen,fenreglfen32) \
         -variable panneau(acqfen,fenreglfen3) -value 2
      pack $audace(base).fenreglfen.3.2.but -side left
      frame $audace(base).fenreglfen.4
      pack $audace(base).fenreglfen.4 -expand true -fill x
      label $audace(base).fenreglfen.4.lab -text $caption(acqfen,fenreglfen4)
      pack $audace(base).fenreglfen.4.lab
      frame $audace(base).fenreglfen.4.1
      pack $audace(base).fenreglfen.4.1 -expand true -fill x
      radiobutton $audace(base).fenreglfen.4.1.but -text $caption(acqfen,fenreglfen41) \
         -variable panneau(acqfen,fenreglfen4) -value 1
      pack $audace(base).fenreglfen.4.1.but -side left
      frame $audace(base).fenreglfen.4.2
      pack $audace(base).fenreglfen.4.2 -expand true -fill x
      radiobutton $audace(base).fenreglfen.4.2.but -text $caption(acqfen,fenreglfen42) \
         -variable panneau(acqfen,fenreglfen4) -value 2
      pack $audace(base).fenreglfen.4.2.but -side left
                  
      #--- Sous-trame boutons OK & quitter
      frame $audace(base).fenreglfen.buttons
      pack $audace(base).fenreglfen.buttons
      button $audace(base).fenreglfen.buttons.ok -text $caption(acqfen,ok) -width 19 \
         -command {
            ::acqfen::recup_position
            set conf(fenreglfen,position) $panneau(acqfen,position)
            destroy $audace(base).fenreglfen
         }
      pack $audace(base).fenreglfen.buttons.ok -side left -expand true -padx 10 -pady 10
      button $audace(base).fenreglfen.buttons.quit -command acqfen::fenreglfenquit \
         -text $caption(acqfen,quitter) -width 19
      pack $audace(base).fenreglfen.buttons.quit -side left -expand true -padx 10 -pady 10

      #--- Focus
      focus $audace(base).fenreglfen

     #--- Mise a jour dynamique des couleurs
     ::confColor::applyColor $audace(base).fenreglfen
   } else {
      focus $audace(base).fenreglfen
   }
}

# =================================
# === initialisation de l'outil ===
# =================================

global audace

::acqfen::init $audace(base)

########## The end ##########

