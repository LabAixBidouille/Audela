#
# Fichier : acqfen.tcl
# Description : Outil d'acquisition d'images fenetrees
# Auteur : Benoit MAUGIS
# Mise a jour $Id: acqfen.tcl,v 1.18 2008-12-15 22:22:17 robertdelmas Exp $
#

# =========================================================
# === definition du namespace acqfen pour creer l'outil ===
# =========================================================

namespace eval ::acqfen {
   package provide acqfen 1.2.1
   package require audela 1.4.0

   # =======================================================================
   # === definition des fonctions de construction automatique de l'outil ===
   # =======================================================================

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] acqfen.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(acqfen,titre)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "acqfen.htm"
   }

   #------------------------------------------------------------
   # getPluginType
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # getPluginDirectory
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginDirectory { } {
      return "acqfen"
   }

   #------------------------------------------------------------
   # getPluginOS
   #    retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   # getPluginProperty
   #    retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "acquisition" }
         subfunction1 { return "windowed" }
         display      { return "panel" }
      }
   }

   #------------------------------------------------------------
   # initPlugin
   #    initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { tkbase } {

   }

   #------------------------------------------------------------
   # createPluginInstance
   #    cree une nouvelle instance de l'outil
   #------------------------------------------------------------
   proc createPluginInstance { { in "" } { visuNo 1 } } {
      createPanel $in.acqfen
   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {

   }

   #------------------------------------------------------------
   # createPanel
   #    prepare la creation de la fenetre de l'outil
   #------------------------------------------------------------
   proc createPanel { this } {
      variable This
      variable parametres
      global caption panneau

      set This $this
      #--- Recuperation de la derniere configuration de prise de vue
      ::acqfen::Chargement_Var
      set panneau(acqfen,titre)        $caption(acqfen,titre)
      set panneau(acqfen,ht_onglet)    280
      set panneau(acqfen,go_stop_cent) "go"
      set panneau(acqfen,go_stop)      "go"

      #--- Valeurs par defaut d'acquisition (centrage)
      #--- Liste de valeurs du temps de pose disponibles par defaut
      set panneau(acqfen,temps_pose_centrage) {.1 .2 .5 1 2 5}
      #--- Valeur par defaut du temps de pose:
      if { ! [ info exists panneau(acqfen,pose_centrage) ] } {
         set panneau(acqfen,pose_centrage) "$parametres(acqfen,pose_centrage)"
      }
      #--- Binning par defaut: 4x4
      if { ! [ info exists panneau(acqfen,bin_centrage) ] } {
         set panneau(acqfen,bin_centrage) "$parametres(acqfen,bin_centrage)"
      }

      #--- Valeurs par defaut d'acquisition (mode "planetaire", fenetre)
      #--- Liste de valeurs du temps de pose disponibles par defaut
      set panneau(acqfen,temps_pose) {.01 .02 .03 .05 .08 .1 .15 .2 .3 .5 1}
      #--- Valeur par defaut du temps de pose:
      if { ! [ info exists panneau(acqfen,pose) ] } {
         set panneau(acqfen,pose) "$parametres(acqfen,pose)"
      }
      #--- Binning par defaut: 1x1
      if { ! [ info exists panneau(acqfen,bin) ] } {
         set panneau(acqfen,bin) "$parametres(acqfen,bin)"
      }

      #--- Taille par defaut de la petite matrice schematisant le fenetrage
      set panneau(acqfen,mtx_x)           81
      set panneau(acqfen,mtx_y)           54

      #--- Valeurs initiales des coordonnees de la "boîte"
      set panneau(acqfen,X1)              "-"
      set panneau(acqfen,Y1)              "-"
      set panneau(acqfen,X2)              "-"
      set panneau(acqfen,Y2)              "-"

      #--- Type de zoom par defaut (scale / zoom)
      set panneau(acqfen,typezoom)        "scale"

      #--- Mode d'acquisition par defaut
      if { ! [ info exists panneau(acqfen,mode) ] } {
         set panneau(acqfen,mode) "$parametres(acqfen,mode)"
      }

      #--- Mode du bouton de changement de mode
      if { $panneau(acqfen,mode) == "une" } {
         set panneau(acqfen,bouton_mode) "$caption(acqfen,uneimage)"
      } elseif { $panneau(acqfen,mode) == "serie" } {
         set panneau(acqfen,bouton_mode) "$caption(acqfen,serie)"
      } else {
         set panneau(acqfen,bouton_mode) "$caption(acqfen,continu)"
      }

      #--- Variables diverses
      set panneau(acqfen,index)           1
      set panneau(acqfen,nb_images)       1
      set panneau(acqfen,enregistrer)     0

      #--- Reglages acquisitions serie et continu par defaut
      set panneau(acqfen,fenreglfen1)     1
      set panneau(acqfen,fenreglfen12)    0
      set panneau(acqfen,fenreglfen2)     1
      set panneau(acqfen,fenreglfen22)    2
      set panneau(acqfen,fenreglfen3)     1
      set panneau(acqfen,fenreglfen4)     1

      #--- Pourcentage de correction des defauts de suivi (doit etre compris entre 1 et 100)
      set panneau(acqfen,fenreglfen42)    70

      #--- Au debut les reglages de temps de pose et de binning sont "accessibles" pour les 2 modes d'acquisition
      set panneau(acqfen,affpleinetrame)  1
      set panneau(acqfen,afffenetrees)    1

      acqfenBuildIF $This

      ::acqfen::ActuAff

      pack $This.mode.$panneau(acqfen,mode) -anchor nw -fill x

   }

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
      if { ! [ info exists parametres(acqfen,bin_centrage) ] }  { set parametres(acqfen,bin_centrage)  "4" }   ; #--- Binning       : 4x4
      if { ! [ info exists parametres(acqfen,pose) ] }          { set parametres(acqfen,pose)          ".05" } ; #--- Temps de pose : 0.05s
      if { ! [ info exists parametres(acqfen,bin) ] }           { set parametres(acqfen,bin)           "1" }   ; #--- Binning       : 1x1
      if { ! [ info exists parametres(acqfen,mode) ] }          { set parametres(acqfen,mode)          "une" } ; #--- Mode          : Une image
   }
#***** Fin de la procedure Chargement_Var **********************

#***** Procedure Enregistrement_Var ****************************
   proc Enregistrement_Var { } {
      variable parametres
      global audace panneau

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

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable This

      pack $This -side left -fill y
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable This
      global audace

      #--- Sauvegarde de la configuration de prise de vue
      ::acqfen::Enregistrement_Var

      #--- Initialisation du fenetrage
      catch {
         set n1n2 [cam$audace(camNo) nbcells]
         cam$audace(camNo) window [ list 1 1 [lindex $n1n2 0] [lindex $n1n2 1] ]
      }
      pack forget $This
   }

   # ==================================================================
   # === definition des fonctions generales a executer dans l'outil ===
   # ==================================================================

   #--- Procedure de changement du binning (acquisitions fenetrees)
   proc ChangeBin { } {
      variable This
      global caption panneau

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

   #--- Procedure de changement du binning (acquisitions pleine trame)
   proc ChangeBinCent { } {
      variable This
      global caption panneau

      switch -exact -- $panneau(acqfen,bin_centrage) {
         "1" {
            set panneau(acqfen,bin_centrage) 2
         }
         "2" {
            set panneau(acqfen,bin_centrage) 3
         }
         "3" {
            set panneau(acqfen,bin_centrage) 4
         }
         "4" {
            set panneau(acqfen,bin_centrage) 1
         }
      }
      $This.acqcent.butbin config -text $caption(acqfen,bin,$panneau(acqfen,bin_centrage))
   }

   #--- Procedures de changement d'affichage des reglages
   proc ChangeAffPleineTrame { } {
      variable This
      global panneau

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

   proc ChangeAffFenetrees { } {
      variable This
      global panneau

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

   proc ActuAff { } {
      variable This
      global panneau

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
   }

   #--- Procedure d'acquisition pleine trame
   proc GoStopCent { } {
      variable This
      global audace caption conf panneau

      if { [::cam::list] != "" } {

         switch -exact -- $panneau(acqfen,go_stop_cent) {
            "go" {
               #--- Modification du bouton, pour eviter un second lancement
               set panneau(acqfen,go_stop_cent) stop
               $This.acqcent.but configure -text $caption(acqfen,stop)
               $This.acqcentred.but configure -text $caption(acqfen,stop)

               #--- Suppression de la zone selectionnee avec la souris
               if { [ lindex [ list [ ::confVisu::getBox 1 ] ] 0 ] != "" } {
                  ::confVisu::deleteBox
               }

               #--- Mise a jour en-tete audace
               wm title $audace(base) "$caption(acqfen,audace)"

               #--- La commande exptime permet de fixer le temps de pose de l'image.
               cam$audace(camNo) exptime $panneau(acqfen,pose_centrage)

               #--- La commande bin permet de fixer le binning.
               cam$audace(camNo) bin [list $panneau(acqfen,bin_centrage) $panneau(acqfen,bin_centrage)]

               #--- La commande window permet de fixer le fenetrage de numerisation du CCD
               cam$audace(camNo) window [list 1 1 [lindex [cam$audace(camNo) nbcells] 0] [lindex [cam$audace(camNo) nbcells] 1]]

               #--- Cas des poses de 0 s : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
               if { $panneau(acqfen,pose_centrage) == "0" } {
                  ::camera::Avancement_pose "1"
               }

               #--- Lecture du CCD
               cam$audace(camNo) acq

               #--- Alarme sonore de fin de pose
               ::camera::alarme_sonore $panneau(acqfen,pose_centrage)

               #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
               ::camera::gestionPose $panneau(acqfen,pose_centrage) 1 cam$audace(camNo) buf$audace(bufNo)

               #--- Zoom
               if {$panneau(acqfen,typezoom)=="zoom"} {
                  visu$audace(visuNo) zoom $panneau(acqfen,bin_centrage)
               } else {
                  #--- Applique le scale si la camera possede bien le binning demande
                  set binningCamera "$panneau(acqfen,bin_centrage)x$panneau(acqfen,bin_centrage)"
                  if { [ lsearch [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningList ] $binningCamera ] != "-1" } {
                     buf$audace(bufNo) scale [list $panneau(acqfen,bin_centrage) $panneau(acqfen,bin_centrage)] 1
                  }
               }

               #--- Rajoute des mots clefs dans l'en-tete FITS
               foreach keyword [ ::keyword::getKeywords $audace(visuNo) ] {
                  buf$audace(bufNo) setkwd $keyword
               }

               #--- Affichage avec visu auto.
               audace::autovisu $audace(visuNo)

               #--- On restitue l'affichage du bouton "GO":
               set panneau(acqfen,go_stop_cent) go
               $This.acqcent.but configure -text $caption(acqfen,GO)
               $This.acqcentred.but configure -text $caption(acqfen,GO)

               #--- On modifie le bouton "Go" des acquisitions fenetrees
               $This.acq.but configure -text $caption(acqfen,actuxy) -command ::acqfen::ActuCoord
               $This.acqred.but configure -text $caption(acqfen,actuxy) -command ::acqfen::ActuCoord

               #--- RAZ du fenetrage
               set panneau(acqfen,X1) "-"
               set panneau(acqfen,Y1) "-"
               set panneau(acqfen,X2) "-"
               set panneau(acqfen,Y2) "-"
               place forget $This.acq.matrice_color_invariant.fen
               place forget $This.acqred.matrice_color_invariant.fen
               $This.acq.matrice_color_invariant.fen config -width $panneau(acqfen,mtx_x) -height $panneau(acqfen,mtx_y)
               $This.acqred.matrice_color_invariant.fen config -width $panneau(acqfen,mtx_x) -height $panneau(acqfen,mtx_y)
               place $This.acq.matrice_color_invariant.fen -x 0 -y 0
               place $This.acqred.matrice_color_invariant.fen -x 0 -y 0
            }
            "stop" {
               #--- Annulation de l'alarme de fin de pose
               catch { after cancel bell }
               #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
               ::camera::gestionPose $panneau(acqfen,pose_centrage) 0 cam$audace(camNo) buf$audace(bufNo)
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

   #--- Procedures d'acquisitions fenetrees
   proc GoStop { } {
      variable This
      global audace caption conf panneau

      if { [::cam::list] != "" } {
         #--- Enregistrement de l'extension des fichiers
         set ext [ buf$audace(bufNo) extension ]
         #---
         switch -exact -- $panneau(acqfen,go_stop) {
            "go" {
               #--- Modification du bouton, pour eviter un second lancement
               set panneau(acqfen,go_stop) stop
               $This.acq.but configure -text $caption(acqfen,stop)
               $This.acqred.but configure -text $caption(acqfen,stop)

               #--- on desactive toute demande d'arret
               set panneau(acqfen,demande_arret) 0

               #--- Suppression de la zone selectionnee avec la souris
               if { [ lindex [ list [ ::confVisu::getBox 1 ] ] 0 ] != "" } {
                  ::confVisu::deleteBox
               }

               #--- Mise a jour en-tete audace
               wm title $audace(base) "$caption(acqfen,audace)"

               switch -exact -- $panneau(acqfen,mode) {
                  "une" {
                     set panneau(acqfen,enregistrer) 0
                     acqfen::acq_acqfen
                     #--- Affichage avec visu auto
                     audace::autovisu $audace(visuNo)
                  }
                  "serie" {
                     #--- On verifie l'integrite des parametres d'entree :

                     #--- On verifie qu'il y a bien un nom de fichier
                     if {$panneau(acqfen,nom_image) == ""} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,donnomfich)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- On verifie que le nom de fichier n'a pas d'espace
                     if {[llength $panneau(acqfen,nom_image)] > 1} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,nomblanc)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- On verifie que le nom de fichier ne contient pas de caracteres interdits
                     if {[acqfen::TestChaine $panneau(acqfen,nom_image)] == 0} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,mauvcar)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- On verifie que l'index existe
                     if {$panneau(acqfen,index) == ""} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,saisind)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- On verifie que l'index est bien un nombre entier
                     if {[acqfen::TestEntier $panneau(acqfen,index)] == 0} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,indinv)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- Envoie un warning si l'index n'est pas a 1
                     if { $panneau(acqfen,index) != "1" } {
                        set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                           -message $caption(acqfen,indpasun)]
                        if { $confirmation == "no" } {
                           #--- On restitue l'affichage du bouton "GO" :
                           set panneau(acqfen,go_stop) go
                           $This.acq.but configure -text $caption(acqfen,GO)
                           $This.acqred.but configure -text $caption(acqfen,GO)
                           return
                        }
                     }
                     #--- On verifie que le nombre d'images a faire existe
                     if {$panneau(acqfen,nb_images) == ""} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,saisnbim)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- On verifie que le nombre d'images a faire est bien un nombre entier
                     if {[acqfen::TestEntier $panneau(acqfen,nb_images)] == 0} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,nbiminv)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
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
                           #--- On restitue l'affichage du bouton "GO" :
                           set panneau(acqfen,go_stop) go
                           $This.acq.but configure -text $caption(acqfen,GO)
                           $This.acqred.but configure -text $caption(acqfen,GO)
                           return
                        }
                     }

                     switch -exact -- $panneau(acqfen,fenreglfen2)$panneau(acqfen,fenreglfen3) {
                        "11" {
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              acqfen::acq_acqfen
                              #--- Affichage avec visu auto
                              audace::autovisu $audace(visuNo)
                              #--- Sauvegarde de l'image
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
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
                              saveima [append nom $panneau(acqfen,index)]
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}
                           }
                        }
                        "21" {
                           set nbint 1
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              acqfen::acq_acqfen
                              #--- Affichage eventuel
                              if {$nbint==$panneau(acqfen,fenreglfen22)} {
                                 audace::autovisu $audace(visuNo)
                                 set nbint 1
                              } else {
                                 incr nbint
                              }
                              #--- Sauvegarde de l'image
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
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
                              saveima [append nom $panneau(acqfen,index)]
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}
                           }
                        }
                        "31" {
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              acqfen::acq_acqfen
                              #--- Sauvegarde de l'image
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
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
                              saveima [append nom $panneau(acqfen,index)]
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}
                           }
                           #--- Affichage avec visu auto
                           audace::autovisu $audace(visuNo)
                        }
                        "12" {
                           set liste_buffers ""
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              acqfen::acq_acqfen
                              #--- Affichage avec visu auto
                              audace::autovisu $audace(visuNo)
                              #--- Sauvegarde temporaire de l'image
                              set buftmp [buf::create]
                              buf$buftmp extension $conf(extension,defaut)
                              buf$audace(bufNo) copyto $buftmp
                              lappend liste_buffers [list $buftmp $panneau(acqfen,index)]
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}
                           }
                           #--- Sauvegarde des images sur le disque
                           foreach ima $liste_buffers {
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              buf[lindex $ima 0] copyto $audace(bufNo)
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
                              saveima [append nom [lindex $ima 1]]
                           }
                           #--- On libere les buffers temporaires
                           foreach ima $liste_buffers {buf::delete [lindex $ima 0]}
                        }
                        "22" {
                           set liste_buffers ""
                           set nbint 1
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              acqfen::acq_acqfen
                              #--- Affichage eventuel
                              if {$nbint==$panneau(acqfen,fenreglfen22)} {
                                 audace::autovisu $audace(visuNo)
                                 set nbint 1
                              } else {
                                 incr nbint
                              }
                              #--- Sauvegarde temporaire de l'image
                              set buftmp [buf::create]
                              buf$buftmp extension $conf(extension,defaut)
                              buf$audace(bufNo) copyto $buftmp
                              lappend liste_buffers [list $buftmp $panneau(acqfen,index)]
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}
                           }
                           #--- Sauvegarde des images sur le disque
                           foreach ima $liste_buffers {
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              buf[lindex $ima 0] copyto $audace(bufNo)
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
                              saveima [append nom [lindex $ima 1]]
                           }
                           #--- On libere les buffers temporaires
                           foreach ima $liste_buffers {buf::delete [lindex $ima 0]}
                        }
                        "32" {
                           set liste_buffers ""
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              acqfen::acq_acqfen
                              #--- Sauvegarde temporaire de l'image
                              set buftmp [buf::create]
                              buf$buftmp extension $conf(extension,defaut)
                              buf$audace(bufNo) copyto $buftmp
                              lappend liste_buffers [list $buftmp $panneau(acqfen,index)]
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}
                           }
                           #--- Sauvegarde des images sur le disque
                           foreach ima $liste_buffers {
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              buf[lindex $ima 0] copyto $audace(bufNo)
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
                              saveima [append nom [lindex $ima 1]]
                           }
                           #--- Affichage avec visu auto
                           audace::autovisu $audace(visuNo)
                        }
                        #--- On libere les buffers temporaires
                        foreach ima $liste_buffers {buf::delete [lindex $ima 0]}
                     }
                  }
                  "continu" {
                     #--- On verifie l'integrite des parametres d'entree :

                     #--- On verifie qu'il y a bien un nom de fichier
                     if {$panneau(acqfen,nom_image) == ""} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,donnomfich)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- On verifie que le nom de fichier n'a pas d'espace
                     if {[llength $panneau(acqfen,nom_image)] > 1} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,nomblanc)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- On verifie que le nom de fichier ne contient pas de caracteres interdits
                     if {[acqfen::TestChaine $panneau(acqfen,nom_image)] == 0} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,mauvcar)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- On verifie que l'index existe
                     if {$panneau(acqfen,index) == ""} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,saisind)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- On verifie que l'index est bien un nombre entier
                     if {[acqfen::TestEntier $panneau(acqfen,index)] == 0} {
                        tk_messageBox -title $caption(acqfen,pb) -type ok \
                           -message $caption(acqfen,indinv)
                        #--- On restitue l'affichage du bouton "GO" :
                        set panneau(acqfen,go_stop) go
                        $This.acq.but configure -text $caption(acqfen,GO)
                        $This.acqred.but configure -text $caption(acqfen,GO)
                        return
                     }
                     #--- Envoie un warning si l'index n'est pas a 1
                     if { $panneau(acqfen,index) != "1" } {
                        set confirmation [tk_messageBox -title $caption(acqfen,conf) -type yesno \
                           -message $caption(acqfen,indpasun)]
                        if { $confirmation == "no" } {
                           #--- On restitue l'affichage du bouton "GO" :
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
                           #--- On restitue l'affichage du bouton "GO" :
                           set panneau(acqfen,go_stop) go
                           $This.acq.but configure -text $caption(acqfen,GO)
                           $This.acqred.but configure -text $caption(acqfen,GO)
                           return
                        }
                     }

                     switch -exact -- $panneau(acqfen,fenreglfen2)$panneau(acqfen,fenreglfen3) {
                        "11" {
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              acqfen::acq_acqfen
                              #--- Affichage avec visu auto
                              audace::autovisu $audace(visuNo)
                              #--- Si demande, sauvegarde de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set nom $panneau(acqfen,nom_image)
                                 #--- Pour eviter un nom de fichier qui commence par un blanc :
                                 set nom [lindex $nom 0]
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
                                 saveima [append nom $panneau(acqfen,index)]
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}
                           }
                        }
                        "21" {
                           set nbint 1
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              acqfen::acq_acqfen
                              #--- Affichage eventuel
                              if {$nbint==$panneau(acqfen,fenreglfen22)} {
                                 audace::autovisu $audace(visuNo)
                                 set nbint 1
                              } else {
                                 incr nbint
                              }
                              #--- Si demande, sauvegarde de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set nom $panneau(acqfen,nom_image)
                                 #--- Pour eviter un nom de fichier qui commence par un blanc :
                                 set nom [lindex $nom 0]
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
                                 saveima [append nom $panneau(acqfen,index)]
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}
                           }
                        }
                        "31" {
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              acqfen::acq_acqfen
                              #--- Si demande, sauvegarde de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set nom $panneau(acqfen,nom_image)
                                 #--- Pour eviter un nom de fichier qui commence par un blanc :
                                 set nom [lindex $nom 0]
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
                                 saveima [append nom $panneau(acqfen,index)]
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}
                           }
                           #--- Affichage avec visu auto
                           audace::autovisu $audace(visuNo)
                        }
                        "12" {
                           set liste_buffers ""
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              acqfen::acq_acqfen
                              #--- Affichage avec visu auto
                              audace::autovisu $audace(visuNo)
                              #--- Si demande, sauvegarde temporaire de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set buftmp [buf::create]
                                 buf$buftmp extension $conf(extension,defaut)
                                 buf$audace(bufNo) copyto $buftmp
                                 lappend $liste_buffers [list $buftmp $panneau(acqfen,index)]
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}
                           }
                           #--- Sauvegarde des images sur le disque
                           foreach ima $liste_buffers {
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              buf[lindex $ima 0] copyto $audace(bufNo)
                              #--- Verifie que le nom du fichier n'existe pas deja
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
                              saveima [append nom [lindex $ima 1]]
                           }
                        }
                        "22" {
                           set nbint 1
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              acqfen::acq_acqfen
                              #--- Affichage eventuel
                              if {$nbint==$panneau(acqfen,fenreglfen22)} {
                                 audace::autovisu $audace(visuNo)
                                 set nbint 1
                              } else {
                                 incr nbint
                              }
                              #--- Si demande, sauvegarde temporaire de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set buftmp [buf::create]
                                 buf$buftmp extension $conf(extension,defaut)
                                 buf$audace(bufNo) copyto $buftmp
                                 lappend $liste_buffers [list $buftmp $panneau(acqfen,index)]
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}
                           }
                           #--- Sauvegarde des images sur le disque
                           foreach ima $liste_buffers {
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              buf[lindex $ima 0] copyto $audace(bufNo)
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
                              saveima [append nom [lindex $ima 1]]
                           }
                        }
                        "32" {
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              acqfen::acq_acqfen
                              #--- Si demande, sauvegarde temporaire de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set buftmp [buf::create]
                                 buf$buftmp extension $conf(extension,defaut)
                                 buf$audace(bufNo) copyto $buftmp
                                 lappend $liste_buffers [list $buftmp $panneau(acqfen,index)]
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::depl_fen}
                           }
                           #--- Sauvegarde des images sur le disque
                           foreach ima $liste_buffers {
                              set nom $panneau(acqfen,nom_image)
                              #--- Pour eviter un nom de fichier qui commence par un blanc :
                              set nom [lindex $nom 0]
                              buf[lindex $ima 0] copyto $audace(bufNo)
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
                              saveima [append nom [lindex $ima 1]]
                           }
                           #--- Affichage avec visu auto
                           audace::autovisu $audace(visuNo)
                        }
                     }
                  }
               }
               #--- On restitue l'affichage du bouton "GO" :
               set panneau(acqfen,go_stop) go
               $This.acq.but configure -text $caption(acqfen,GO)
               $This.acqred.but configure -text $caption(acqfen,GO)
            }
            "stop" {
               #--- On positionne un indicateur de demande d'arret
               set panneau(acqfen,demande_arret) 1
               #--- Annulation de l'alarme de fin de pose
               catch { after cancel bell }
               #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
               ::camera::gestionPose $panneau(acqfen,pose) 0 cam$audace(camNo) buf$audace(bufNo)
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

   proc acq_acqfen { } {
      variable This
      global audace caption conf panneau

      #--- Raccourcis
      set camxis1 [lindex [cam$audace(camNo) nbcells] 0]
      set camxis2 [lindex [cam$audace(camNo) nbcells] 1]

      #--- La commande bin permet de fixer le binning.
      cam$audace(camNo) bin [list $panneau(acqfen,bin) $panneau(acqfen,bin)]

      #--- La commande window permet de fixer le fenetrage de numerisation du CCD
      if {$panneau(acqfen,X1) == "-"} {
         cam$audace(camNo) window [list 1 1 $camxis1 $camxis2]
      } else {
         cam$audace(camNo) window [list $panneau(acqfen,X1) $panneau(acqfen,Y1) \
         $panneau(acqfen,X2) $panneau(acqfen,Y2)]
      }

      #--- Acquisition
      if {$panneau(acqfen,fenreglfen1)=="1"} {
         #--- Acquisitions avec nombre d'effacements prealables par defaut
         #--- La commande exptime permet de fixer le temps de pose de l'image.
         cam$audace(camNo) exptime $panneau(acqfen,pose)
         #--- Cas des poses de 0 s : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
         if { $panneau(acqfen,pose) == "0" } {
            ::camera::Avancement_pose "1"
         }
         #--- Acquisition
         cam$audace(camNo) acq
         #--- Alarme sonore de fin de pose
         ::camera::alarme_sonore $panneau(acqfen,pose)
         #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
         ::camera::gestionPose $panneau(acqfen,pose) 1 cam$audace(camNo) buf$audace(bufNo)
      } else {
         for {set k 1} {$k<=$panneau(acqfen,fenreglfen12)} {incr k} {cam$audace(camNo) wipe}
         after [expr int(1000*$panneau(acqfen,pose))] [cam$audace(camNo) read]
      }

      #--- Rajoute des mots clefs dans l'en-tete FITS
      foreach keyword [ ::keyword::getKeywords $audace(visuNo) ] {
         buf$audace(bufNo) setkwd $keyword
      }

      #--- Fenetrage sur le buffer si la camera ne possede pas le mode fenetrage (APN et WebCam)
      if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] window ] == "0" } {
         buf$audace(bufNo) window [list $panneau(acqfen,X1) $panneau(acqfen,Y1) \
         $panneau(acqfen,X2) $panneau(acqfen,Y2)]
      }
   }

   #--- Procedures d'actualisation des coordonnees
   proc ActuCoord { { visuNo "1" } } {
      variable This
      global audace caption panneau

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

         #--- On modifie le bouton "Go" des acquisitions fenetrees
         $This.acq.but configure -text $caption(acqfen,GO) -command ::acqfen::GoStop
         $This.acqred.but configure -text $caption(acqfen,GO) -command ::acqfen::GoStop
      }
   }

   #--- Procedure de gestion du mode d'acquisition
   proc ChangeMode { } {
      variable This
      global caption panneau

      switch -exact -- $panneau(acqfen,mode) {
         "une" {
            #--- On efface  l'ancien sous-panneau
            pack forget $This.mode.une -fill x
            #--- On met le nouveau a sa place
            pack $This.mode.serie -fill x -anchor nw
            $This.mode.but configure -text $caption(acqfen,serie)
            set panneau(acqfen,mode) "serie"
         }
         "serie" {
            #--- On efface  l'ancien sous-panneau
            pack forget $This.mode.serie -fill x
            #--- On met le nouveau a sa place
            pack $This.mode.continu -fill x -anchor nw
            $This.mode.but configure -text $caption(acqfen,continu)
            set panneau(acqfen,mode) "continu"
         }
         "continu" {
            #--- On efface  l'ancien sous-panneau
            pack forget $This.mode.continu -fill x
            #--- On met le nouveau a sa place
            pack $This.mode.une -fill x -anchor nw
            $This.mode.but configure -text $caption(acqfen,uneimage)
            set panneau(acqfen,mode) "une"
         }
      }
   }

   #--- Procedure de suivi par deplacement de la fenetre
   proc depl_fen { } {
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

#***** Procedure de sauvegarde de l'image **********************
#--- Cette routine est largement inspiree de Acq.tcl, livre avec Audela.
#--- Procedure lancee par appui sur le bouton "enregistrer", uniquement dans le
#--- mode "Une image".
   proc SauveUneImage { } {
      variable This
      global audace caption panneau

      #--- Enregistrement de l'extension des fichiers
      set ext [ buf$audace(bufNo) extension ]

      #--- Verifier qu'il y a bien un nom de fichier
      if {$panneau(acqfen,nom_image) == ""} {
         tk_messageBox -title $caption(acqfen,pb) -type ok \
            -message $caption(acqfen,donnomfich)
         return
      }
      #--- Verifie que le nom de fichier n'a pas d'espace
      if {[llength $panneau(acqfen,nom_image)] > 1} {
         tk_messageBox -title $caption(acqfen,pb) -type ok \
            -message $caption(acqfen,nomblanc)
         return
      }
      #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
      if {[acqfen::TestChaine $panneau(acqfen,nom_image)] == 0} {
         tk_messageBox -title $caption(acqfen,pb) -type ok \
            -message $caption(acqfen,mauvcar)
         return
      }
      #--- Si la case index est cochee, verifier qu'il y a bien un index
      if {$panneau(acqfen,indexer) == 1} {
         #--- Verifie que l'index existe
         if {$panneau(acqfen,index) == ""} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
               -message $caption(acqfen,saisind)
            return
         }
         #--- Verifier que l'index est bien un nombre entier
         if {[acqfen::TestEntier $panneau(acqfen,index)] == 0} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
               -message $caption(acqfen,indinv)
            return
         }
      }

      #--- Generation du nom de fichier
      set nom $panneau(acqfen,nom_image)
      #--- Pour eviter un nom de fichier qui commence par un blanc:
      set nom [lindex $nom 0]
      if {$panneau(acqfen,indexer) == 1 } {
         append nom $panneau(acqfen,index)
      }

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

      #--- Sauvegarde de l'image
      saveima $nom
   }
#***** Fin de la procedure de sauvegarde de l'image *************

#***** Procedure de test de validite d'un entier *****************
#--- Cette procedure (copiee de Methking) verifie que la chaine passee en argument decrit
#--- bien un entier. Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un entier.
   proc TestEntier { valeur } {
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
#***** Fin de la procedure de test de validite d'une entier *******

#***** Procedure de test de validite d'une chaine de caracteres *******
#--- Cette procedure verifie que la chaine passee en argument ne contient que des caracteres
#--- valides. Elle retourne 1 si c'est la cas, et 0 si ce n'est pas valable.
   proc TestChaine { valeur } {
      set test 1
      for {set i 0} {$i < [string length $valeur]} {incr i} {
         set a [string index $valeur $i]
         if {![string match {[-a-zA-Z0-9_]} $a]} {
            set test 0
         }
      }
      return $test
   }
#***** Fin de la procedure de test de validite d'une chaine de caracteres *******

   proc fenreglfenquit { } {
   global audace conf panneau

      set panneau(acqfen,fenreglfen1)  $panneau(acqfen,oldfenreglfen1)
      set panneau(acqfen,fenreglfen12) $panneau(acqfen,oldfenreglfen12)
      set panneau(acqfen,fenreglfen2)  $panneau(acqfen,oldfenreglfen2)
      set panneau(acqfen,fenreglfen22) $panneau(acqfen,oldfenreglfen22)
      set panneau(acqfen,fenreglfen3)  $panneau(acqfen,oldfenreglfen3)
      set panneau(acqfen,fenreglfen4)  $panneau(acqfen,oldfenreglfen4)
      #--- Recuperation de la position de la fenetre de reglages
      ::acqfen::recup_position
      set conf(fenreglfen,position)    $panneau(acqfen,position)
      #---
      destroy $audace(base).fenreglfen
   }

#---Procedure de recuperation de la position de la fenetre de reglage

   proc recup_position { } {
      global audace panneau

      set panneau(acqfen,geometry) [ wm geometry $audace(base).fenreglfen ]
      set deb [ expr 1 + [ string first + $panneau(acqfen,geometry) ] ]
      set fin [ string length $panneau(acqfen,geometry) ]
      set panneau(acqfen,position) "+[string range $panneau(acqfen,geometry) $deb $fin]"
   }

}

# ===============================
# === fin du namespace acqfen ===
# ===============================

#------------------------------------------------------------
# acqfenBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc acqfenBuildIF { This } {
global audace caption color panneau

#--- Trame du panneau

frame $This -borderwidth 2 -relief groove

   #--- Trame du titre panneau
   frame $This.titre -borderwidth 2 -relief groove
   pack $This.titre -side top -fill x

      Button $This.titre.but -borderwidth 1 -text $caption(acqfen,titre_fenetrees) \
         -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqfen::getPluginType ] ] \
            [ ::acqfen::getPluginDirectory ] [ ::acqfen::getPluginHelp ]"
      pack $This.titre.but -in $This.titre -anchor center -expand 1 -fill both -side top -ipadx 5
      DynamicHelp::add $This.titre.but -text $caption(acqfen,help_titre)

   #--- Trame de la configuration
   frame $This.config -borderwidth 2 -relief groove
   pack $This.config -side top -fill x

      #--- Bonton de Configuration
      button $This.config.but -text $caption(acqfen,congiguration) -borderwidth 1 -command Creefenreglfen
      pack $This.config.but -in $This.config -anchor center -expand 1 -fill both -side top -ipadx 5

   #--- Trame acquisition centrage (version complete)
   frame $This.acqcent -borderwidth 1 -relief groove

      #--- Sous-titre "acquisition pleine trame"
      button $This.acqcent.titre -text $caption(acqfen,titre_centrage) -borderwidth 0 \
         -command ::acqfen::ChangeAffPleineTrame
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
         entry $This.acqcent.pose.pose_ent -width 4 -textvariable panneau(acqfen,pose_centrage) \
            -relief groove -justify center
         pack $This.acqcent.pose.pose_ent -side left -fill y

      pack $This.acqcent.pose -expand true

      #--- Bouton binning
      button $This.acqcent.butbin -text $caption(acqfen,bin,$panneau(acqfen,bin_centrage)) \
         -command ::acqfen::ChangeBinCent
      pack $This.acqcent.butbin -expand true

      #--- Bouton Go/Stop
      button $This.acqcent.but -text $caption(acqfen,GO) -borderwidth 3 -command ::acqfen::GoStopCent
      pack $This.acqcent.but -expand true -fill both

   #--- Trame acquisition centrage (version reduite)
   frame $This.acqcentred -borderwidth 1 -relief groove

      #--- Sous-titre "acquisition pleine trame"
      button $This.acqcentred.titre -text $caption(acqfen,titre_centrage) -borderwidth 0 \
         -command ::acqfen::ChangeAffPleineTrame
      pack $This.acqcentred.titre -expand true -fill x -pady 2

      #--- Bouton Go/Stop
      button $This.acqcentred.but -text $caption(acqfen,GO) -borderwidth 3 -command ::acqfen::GoStopCent
      pack $This.acqcentred.but -expand true -fill both

   #--- Trame acquisition (version complete)
   frame $This.acq -borderwidth 1 -relief groove

      #--- Sous-titre "acquisitions fenetrees"
      button $This.acq.titre -text $caption(acqfen,titre_fenetrees) -borderwidth 0 \
         -command ::acqfen::ChangeAffFenetrees
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
         entry $This.acq.pose.pose_ent -width 4 -textvariable panneau(acqfen,pose) \
            -relief groove -justify center
         pack $This.acq.pose.pose_ent -side left -fill y

      pack $This.acq.pose -expand true

      #--- Bouton binning
      button $This.acq.butbin -text $caption(acqfen,bin,$panneau(acqfen,bin)) -command ::acqfen::ChangeBin
      pack $This.acq.butbin -expand true

      #--- Representation matrice CCD
      frame $This.acq.matrice_color_invariant -bg $color(blue) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acq.matrice_color_invariant
      frame $This.acq.matrice_color_invariant.fen -bg $color(cyan) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acq.matrice_color_invariant.fen

      #--- Bouton Go/Stop
      button $This.acq.but -text $caption(acqfen,actuxy) -borderwidth 3 -command ::acqfen::ActuCoord
      pack $This.acq.but -expand true -fill both

   #--- Trame acquisition (version reduite)
   frame $This.acqred -borderwidth 1 -relief groove

      #--- Sous-titre "acquisitions fenetrees"
      button $This.acqred.titre -text $caption(acqfen,titre_fenetrees) -borderwidth 0 \
         -command ::acqfen::ChangeAffFenetrees
      pack $This.acqred.titre -expand true -fill x -pady 2

      #--- Representation matrice CCD
      frame $This.acqred.matrice_color_invariant -bg $color(blue) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acqred.matrice_color_invariant
      frame $This.acqred.matrice_color_invariant.fen -bg $color(cyan) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acqred.matrice_color_invariant.fen

      #--- Bouton Go/Stop
      button $This.acqred.but -text $caption(acqfen,actuxy) -borderwidth 3 -command ::acqfen::ActuCoord
      pack $This.acqred.but -expand true -fill both

   #--- Trame du mode d'acquisition
   frame $This.mode -borderwidth 2 -relief groove

      button $This.mode.but -text $panneau(acqfen,bouton_mode) -command ::acqfen::ChangeMode
      pack $This.mode.but -expand true -fill both

      #--- Definition du sous-panneau "Mode: Une seule image"
      frame $This.mode.une -borderwidth 0

         frame $This.mode.une.nom -relief ridge -borderwidth 2
            label $This.mode.une.nom.but -text $caption(acqfen,nom) -pady 0
            pack $This.mode.une.nom.but -fill x -side top
            entry $This.mode.une.nom.entr -width 10 -textvariable panneau(acqfen,nom_image) \
               -relief groove
            pack $This.mode.une.nom.entr -fill x -side top
         pack $This.mode.une.nom -expand true -fill both
         frame $This.mode.une.index -relief ridge -borderwidth 2
            checkbutton $This.mode.une.index.case -pady 0 -text $caption(acqfen,index)\
               -variable panneau(acqfen,indexer)
            pack $This.mode.une.index.case -expand true -fill both
            entry $This.mode.une.index.entr -width 3 -textvariable panneau(acqfen,index) \
               -relief groove -justify center
            pack $This.mode.une.index.entr -side left -fill x -expand true
            button $This.mode.une.index.but -text "1" -width 3 -command {set panneau(acqfen,index) 1}
            pack $This.mode.une.index.but -side right -fill x
         pack $This.mode.une.index -expand true -fill both
         button $This.mode.une.sauve -text $caption(acqfen,sauvegde) -command ::acqfen::SauveUneImage
         pack $This.mode.une.sauve -expand true -fill both

      #--- Definition du sous-panneau "Mode: Serie d'image"
      frame $This.mode.serie -borderwidth 0
         frame $This.mode.serie.nom -relief ridge -borderwidth 2
            label $This.mode.serie.nom.but -text $caption(acqfen,nom) -pady 0
            pack $This.mode.serie.nom.but -fill x
            entry $This.mode.serie.nom.entr -width 10 -textvariable panneau(acqfen,nom_image) \
               -relief groove
            pack $This.mode.serie.nom.entr -fill x
         pack $This.mode.serie.nom -expand true -fill both
         frame $This.mode.serie.nb -relief ridge -borderwidth 2
            label $This.mode.serie.nb.but -text $caption(acqfen,nombre) -pady 0
            pack $This.mode.serie.nb.but -side left -fill y
            entry $This.mode.serie.nb.entr -width 3 -textvariable panneau(acqfen,nb_images) \
               -relief groove -justify center
            pack $This.mode.serie.nb.entr -side left -fill x -expand true
         pack $This.mode.serie.nb -expand true -fill both
         frame $This.mode.serie.index -relief ridge -borderwidth 2
            label $This.mode.serie.index.lab -text $caption(acqfen,index) -pady 0
            pack $This.mode.serie.index.lab -expand true -fill both
            entry $This.mode.serie.index.entr -width 3 -textvariable panneau(acqfen,index) \
               -relief groove -justify center
            pack $This.mode.serie.index.entr -side left -fill x -expand true
            button $This.mode.serie.index.but -text "1" -width 3 -command {set panneau(acqfen,index) 1}
            pack $This.mode.serie.index.but -side right -fill x
         pack $This.mode.serie.index -expand true -fill both

      #--- Definition du sous-panneau "Mode: Continu"
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
               -relief groove
            pack $This.mode.continu.nom.entr -fill x
         pack $This.mode.continu.nom -expand true -fill both
         frame $This.mode.continu.index -relief ridge -borderwidth 2
            label $This.mode.continu.index.lab -text $caption(acqfen,index) -pady 0
            pack $This.mode.continu.index.lab -expand true -fill both
            entry $This.mode.continu.index.entr -width 3 -textvariable panneau(acqfen,index) \
               -relief groove -justify center
            pack $This.mode.continu.index.entr -side left -fill x -expand true
            button $This.mode.continu.index.but -text "1" -width 3 -command {set panneau(acqfen,index) 1}
            pack $This.mode.continu.index.but -side right -fill x
         pack $This.mode.continu.index -expand true -fill both

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

#---Procedure d'affichage de la fenetre de reglages acquisition serie et continu

proc Creefenreglfen { } {
   global audace caption conf infos panneau

   if { ! [ info exists conf(fenreglfen,position) ] } { set conf(fenreglfen,position) "+0+0" }

   set panneau(acqfen,position) $conf(fenreglfen,position)

   if { [ info exists panneau(acqfen,geometry) ] } {
      set deb [ expr 1 + [ string first + $panneau(acqfen,geometry) ] ]
      set fin [ string length $panneau(acqfen,geometry) ]
      set panneau(acqfen,position) "+[string range $panneau(acqfen,geometry) $deb $fin]"
   }

   if {[winfo exists $audace(base).fenreglfen] == 0} {
      #--- Creation de la fenetre
      toplevel $audace(base).fenreglfen
      wm geometry $audace(base).fenreglfen 400x370$panneau(acqfen,position)
      wm title $audace(base).fenreglfen $caption(acqfen,fenreglfen)
      wm protocol $audace(base).fenreglfen WM_DELETE_WINDOW ::acqfen::fenreglfenquit

      #--- Enregistrement des reglages courants
      set panneau(acqfen,oldfenreglfen1)  $panneau(acqfen,fenreglfen1)
      set panneau(acqfen,oldfenreglfen12) $panneau(acqfen,fenreglfen12)
      set panneau(acqfen,oldfenreglfen2)  $panneau(acqfen,fenreglfen2)
      set panneau(acqfen,oldfenreglfen22) $panneau(acqfen,fenreglfen22)
      set panneau(acqfen,oldfenreglfen3)  $panneau(acqfen,fenreglfen3)
      set panneau(acqfen,oldfenreglfen4)  $panneau(acqfen,fenreglfen4)

      #--- Bouton du configurateur d'en-tete FITS
      button $audace(base).fenreglfen.but1 -text "$caption(acqfen,en-tete_fits)" \
         -command "::keyword::run $audace(visuNo)"
      pack $audace(base).fenreglfen.but1 -side top -fill x

      #--- Trame reglages
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
         -width 10 -justify center
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
         -width 10 -justify center
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
      button $audace(base).fenreglfen.buttons.quit -command ::acqfen::fenreglfenquit \
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

########## The end ##########

