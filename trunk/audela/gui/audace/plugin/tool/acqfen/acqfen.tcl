#
# Fichier : acqfen.tcl
# Description : Outil d'acquisition d'images fenetrees
# Auteur : Benoit MAUGIS
# Mise a jour $Id: acqfen.tcl,v 1.35 2010-01-29 20:45:01 michelpujol Exp $
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
         menu         { return "tool" }
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
      variable This
      global caption panneau

      #--- Initialisation
      set This $in.acqfen

      #--- Liste des modes disponibles
      set panneau(acqfen,list_mode) [ list $caption(acqfen,uneimage) $caption(acqfen,serie) \
         $caption(acqfen,continu) ]

      #--- Initialisation des modes
      set panneau(acqfen,mode,1) "$This.mode.une"
      set panneau(acqfen,mode,2) "$This.mode.serie"
      set panneau(acqfen,mode,3) "$This.mode.continu"

      #--- Preparation de la creation de la fenetre de l'outil
      createPanel $This

      #--- Affichage du mode choisi
      pack $panneau(acqfen,mode,$panneau(acqfen,mode)) -anchor nw -fill x
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
      ::acqfen::chargerParametres
      set panneau(acqfen,titre)        $caption(acqfen,titre)
      set panneau(acqfen,ht_onglet)    280
      set panneau(acqfen,go_stop_cent) "go"
      set panneau(acqfen,go_stop)      "go"

      #--- Valeurs par defaut d'acquisition (centrage)
      #--- Liste de valeurs du temps de pose disponibles par defaut
      set panneau(acqfen,temps_pose_centrage) {.1 .2 .5 1 2 3 5}
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
      set panneau(acqfen,temps_pose) {.01 .02 .03 .05 .08 .1 .15 .2 .3 .5 1 2 3 5}
      #--- Valeur par defaut du temps de pose:
      if { ! [ info exists panneau(acqfen,pose) ] } {
         set panneau(acqfen,pose) "$parametres(acqfen,pose)"
      }
      #--- Binning par defaut: 1x1
      if { ! [ info exists panneau(acqfen,bin) ] } {
         set panneau(acqfen,bin) "$parametres(acqfen,bin)"
      }

      #--- Taille par defaut de la petite matrice schematisant le fenetrage
      set panneau(acqfen,mtx_x) 81
      set panneau(acqfen,mtx_y) 54

      #--- Valeurs initiales des coordonnees de la "bo�te"
      set panneau(acqfen,X1) "-"
      set panneau(acqfen,Y1) "-"
      set panneau(acqfen,X2) "-"
      set panneau(acqfen,Y2) "-"

      #--- Type scale par defaut (scale ou zoom)
      set panneau(acqfen,typezoom) "scale"

      #--- Mode d'acquisition par defaut
      if { ! [ info exists panneau(acqfen,mode) ] } {
         set panneau(acqfen,mode) "$parametres(acqfen,mode)"
      }

      #--- Valeur par defaut du nombre de poses d'une serie
      if { ! [ info exists panneau(acqfen,nb_images) ] } {
         set panneau(acqfen,nb_images) "$parametres(acqfen,nb_images)"
      }

      #--- Fenetre d'avancement de la pose
      if { ! [ info exists panneau(acqfen,avancement_acq) ] } {
         set panneau(acqfen,avancement_acq) "$parametres(acqfen,avancement_acq)"
      }

      #--- Mode de la combobox de changement de mode
      if { $panneau(acqfen,mode) == "1" } {
         set panneau(acqfen,frame_mode) "une"
      } elseif { $panneau(acqfen,mode) == "2" } {
         set panneau(acqfen,frame_mode) "serie"
      } else {
         set panneau(acqfen,frame_mode) "continu"
      }

      #--- Variables diverses
      set panneau(acqfen,index)           1
      set panneau(acqfen,enregistrer)     0
      set panneau(acqfen,acquisition)     0
      set panneau(acqfen,demande_arret)   0
      set panneau(acqfen,dispTimeAfterId) ""
      set panneau(acqfen,finAquisition)   ""

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

      ::acqfenBuildIF $This

      ::acqfen::actualiserAffichage

      pack $This.mode.$panneau(acqfen,frame_mode) -anchor nw -fill x

   }

   #--- Procedure pour charger les parametres de configuration
   proc chargerParametres { } {
      variable parametres
      global audace

      #--- Ouverture du fichier de parametres
      set fichier [ file join $audace(rep_plugin) tool acqfen acqfen.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }
      if { ! [ info exists parametres(acqfen,pose_centrage) ] }  { set parametres(acqfen,pose_centrage)  ".2" }  ; #--- Temps de pose : 0.2s
      if { ! [ info exists parametres(acqfen,bin_centrage) ] }   { set parametres(acqfen,bin_centrage)   "4" }   ; #--- Binning : 4x4
      if { ! [ info exists parametres(acqfen,pose) ] }           { set parametres(acqfen,pose)           ".05" } ; #--- Temps de pose : 0.05s
      if { ! [ info exists parametres(acqfen,bin) ] }            { set parametres(acqfen,bin)            "1" }   ; #--- Binning : 1x1
      if { ! [ info exists parametres(acqfen,mode) ] }           { set parametres(acqfen,mode)           "1" }   ; #--- Mode : Une image
      if { ! [ info exists parametres(acqfen,nb_images) ] }      { set parametres(acqfen,nb_images)      "5" }   ; #--- Serie : Nombre de poses
      if { ! [ info exists parametres(acqfen,avancement_acq) ] } { set parametres(acqfen,avancement_acq) "1" }   ; #--- Barre de progression de la pose : Oui

      #--- je converis les anciennes valeurs pour assurer la compatibilité
      if { $parametres(acqfen,mode) == "une" }     { set parametres(acqfen,mode) 1 }
      if { $parametres(acqfen,mode) == "serie" }   { set parametres(acqfen,mode) 2 }
      if { $parametres(acqfen,mode) == "continu" } { set parametres(acqfen,mode) 3 }
   }

   #--- Procedure pour enregistrer les parametres de configuration
   proc enregistrerParametres { } {
      variable parametres
      global audace panneau

      #---
      set parametres(acqfen,pose_centrage)  $panneau(acqfen,pose_centrage)
      set parametres(acqfen,bin_centrage)   $panneau(acqfen,bin_centrage)
      set parametres(acqfen,pose)           $panneau(acqfen,pose)
      set parametres(acqfen,bin)            $panneau(acqfen,bin)
      set parametres(acqfen,mode)           $panneau(acqfen,mode)
      set parametres(acqfen,nb_images)      $panneau(acqfen,nb_images)
      set parametres(acqfen,avancement_acq) $panneau(acqfen,avancement_acq)

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

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable This

      #--- On cree la variable de configuration des mots cles
      if { ! [ info exists ::conf(acqfen,keywordConfigName) ] } { set ::conf(acqfen,keywordConfigName) "default" }

      pack $This -side left -fill y
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable This
      global audace panneau

      #--- Je verifie si une operation est en cours
      if { $panneau(acqfen,acquisition) == "1" } {
         return -1
      }

      #--- Sauvegarde de la configuration de prise de vue
      ::acqfen::enregistrerParametres

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
   proc changerBinning { } {
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
   proc changerBinningCent { } {
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

   #--- Procedure de mise a jour de l'interface graphique de l'outil
   proc changerAffPleineTrame { } {
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
      ::acqfen::actualiserAffichage
   }

   #--- Procedure de mise a jour de l'interface graphique de l'outil
   proc changerAffFenetrees { } {
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
      ::acqfen::actualiserAffichage
   }

   #--- Procedure de mise a jour de l'affichage du fenetrage sur la pleine trame
   proc actualiserAffichage { } {
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
   proc goStopCent { } {
      variable This
      global audace caption panneau

      if { [::cam::list] != "" } {

         switch -exact -- $panneau(acqfen,go_stop_cent) {
            "go" {
               set catchError [ catch {
                  #--- Mise a jour de variable
                  set panneau(acqfen,acquisition) "1"

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

                  #--- Cas des petites poses : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
                  if { $panneau(acqfen,pose_centrage) >= "0" && $panneau(acqfen,pose_centrage) < "1" } {
                     ::acqfen::avancementPose $panneau(acqfen,pose_centrage) 0
                  }

                  #--- Alarme sonore de fin de pose
                  ::camera::alarmeSonore $panneau(acqfen,pose_centrage)

                  #--- Declenchement de l'acquisition
                  ::camera::acquisition [ ::confVisu::getCamItem $audace(visuNo) ] "::acqfen::attendImage" $panneau(acqfen,pose_centrage)

                  #--- Appel du timer
                  after 10 ::acqfen::dispTime $panneau(acqfen,pose_centrage)

                  #--- Attente de la fin de l'acquisition
                  vwait panneau(acqfen,finAquisition)

                  #--- Applique un zoom ou un scale (re-echantillonnage)
                  if {$panneau(acqfen,typezoom)=="zoom"} {
                     #--- Applique un zoom
                     visu$audace(visuNo) zoom $panneau(acqfen,bin_centrage)
                  } else {
                     #--- Applique un scale (re-echantillonne) si la camera possede bien le binning demande
                     #--- L'image finale a la meme dimension a l'ecran que l'image en binning 1x1
                     set binningCamera "$panneau(acqfen,bin_centrage)x$panneau(acqfen,bin_centrage)"
                     if { [ lsearch [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningList ] $binningCamera ] != "-1" } {
                        buf$audace(bufNo) scale [list $panneau(acqfen,bin_centrage) $panneau(acqfen,bin_centrage)] 1
                     }
                  }

                  #--- Rajoute des mots cles dans l'en-tete FITS
                  foreach keyword [ ::keyword::getKeywords $audace(visuNo) $::conf(acqfen,keywordConfigName) ] {
                     buf$audace(bufNo) setkwd $keyword
                  }

                  #--- Mise a jour du nom du fichier dans le titre et de la fenetre de l'en-tete FITS
                  ::confVisu::setFileName $audace(visuNo) ""

                  #--- Affichage avec visu auto
                  ::audace::autovisu $audace(visuNo)

                  #--- On restitue l'affichage du bouton "GO":
                  set panneau(acqfen,go_stop_cent) go
                  $This.acqcent.but configure -text $caption(acqfen,GO)
                  $This.acqcentred.but configure -text $caption(acqfen,GO)

                  #--- On modifie le bouton "Go" des acquisitions fenetrees
                  $This.acq.but configure -text $caption(acqfen,actuxy) -command ::acqfen::actualiserCoordonnees
                  $This.acqred.but configure -text $caption(acqfen,actuxy) -command ::acqfen::actualiserCoordonnees

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

                  #--- Mise a jour de variables
                  set panneau(acqfen,acquisition)   "0"
                  set panneau(acqfen,demande_arret) "0"

                  #--- je ferme la fenetre d'avancement
                  ::acqfen::avancementPose $panneau(acqfen,pose_centrage) -1

               } ]

               if { $catchError == 1 } {
                  #--- j'affiche et je trace le message d'erreur
                  ::tkutil::displayErrorInfo $::caption(acqfen,titre_fenetrees)

                  #--- je restaure les boutons
                  set panneau(acqfen,go_stop_cent) go
                  $This.acqcent.but configure -text $::caption(acqfen,GO)
                  $This.acqcentred.but configure -text $::caption(acqfen,GO)
                  set panneau(acqfen,acquisition)   "0"
                  set panneau(acqfen,demande_arret) "0"

                  #--- je ferme la fenetre d'avancement
                  ::acqfen::avancementPose $panneau(acqfen,pose_centrage) -1
               }
            }

            "stop" {
               #--- On positionne un indicateur de demande d'arret
               set panneau(acqfen,demande_arret) "1"

               #--- Annulation de l'alarme de fin de pose
               catch { after cancel bell }

               #--- Arret de la capture de l'image
               ::camera::stopAcquisition [ ::confVisu::getCamItem $audace(visuNo) ]

               #--- J'attends la fin de l'acquisition
               vwait panneau(acqfen,finAquisition)
            }
         }

      } else {
         ::confCam::run
      }
   }

   #--- Procedure d'acquisitions fenetrees
   proc goStop { } {
      variable This
      global audace caption conf panneau

      if { [::cam::list] != "" } {
         #--- Enregistrement de l'extension des fichiers
         set ext $conf(extension,defaut)
         #---
         switch -exact -- $panneau(acqfen,go_stop) {
            "go" {
               #--- Mise a jour de variable
               set panneau(acqfen,acquisition) "1"

               #--- Modification du bouton, pour eviter un second lancement
               set panneau(acqfen,go_stop) stop
               $This.acq.but configure -text $caption(acqfen,stop)
               $This.acqred.but configure -text $caption(acqfen,stop)

               #--- on desactive toute demande d'arret
               set panneau(acqfen,demande_arret) "0"

               #--- Suppression de la zone selectionnee avec la souris
               if { [ lindex [ list [ ::confVisu::getBox 1 ] ] 0 ] != "" } {
                  ::confVisu::deleteBox
               }

               #--- Mise a jour en-tete audace
               wm title $audace(base) "$caption(acqfen,audace)"

               switch -exact -- $panneau(acqfen,mode) {
                  "1" {
                     set panneau(acqfen,enregistrer) 0
                     ::acqfen::acqAcqfen
                     #--- Affichage avec visu auto
                     ::audace::autovisu $audace(visuNo)
                  }
                  "2" {
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
                              ::acqfen::acqAcqfen
                              #--- Affichage avec visu auto
                              ::audace::autovisu $audace(visuNo)
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
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                        }
                        "21" {
                           set nbint 1
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Affichage eventuel
                              if {$nbint==$panneau(acqfen,fenreglfen22)} {
                                 ::audace::autovisu $audace(visuNo)
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
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                        }
                        "31" {
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              ::acqfen::acqAcqfen
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
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                           #--- Affichage avec visu auto
                           ::audace::autovisu $audace(visuNo)
                        }
                        "12" {
                           set liste_buffers ""
                           for {set i 1} {$i <= $panneau(acqfen,nb_images)} {incr i} {
                              if {$panneau(acqfen,demande_arret)==1} {break}
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Affichage avec visu auto
                              ::audace::autovisu $audace(visuNo)
                              #--- Sauvegarde temporaire de l'image
                              set buftmp [buf::create]
                              buf$buftmp extension $conf(extension,defaut)
                              buf$audace(bufNo) copyto $buftmp
                              lappend liste_buffers [list $buftmp $panneau(acqfen,index)]
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
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
                              ::acqfen::acqAcqfen
                              #--- Affichage eventuel
                              if {$nbint==$panneau(acqfen,fenreglfen22)} {
                                 ::audace::autovisu $audace(visuNo)
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
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
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
                              ::acqfen::acqAcqfen
                              #--- Sauvegarde temporaire de l'image
                              set buftmp [buf::create]
                              buf$buftmp extension $conf(extension,defaut)
                              buf$audace(bufNo) copyto $buftmp
                              lappend liste_buffers [list $buftmp $panneau(acqfen,index)]
                              incr panneau(acqfen,index)
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
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
                           ::audace::autovisu $audace(visuNo)
                        }
                        #--- On libere les buffers temporaires
                        foreach ima $liste_buffers {buf::delete [lindex $ima 0]}
                     }
                  }
                  "3" {
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
                              ::acqfen::acqAcqfen
                              #--- Affichage avec visu auto
                              ::audace::autovisu $audace(visuNo)
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
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                        }
                        "21" {
                           set nbint 1
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Affichage eventuel
                              if {$nbint==$panneau(acqfen,fenreglfen22)} {
                                 ::audace::autovisu $audace(visuNo)
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
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                        }
                        "31" {
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              ::acqfen::acqAcqfen
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
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
                           }
                           #--- Affichage avec visu auto
                           ::audace::autovisu $audace(visuNo)
                        }
                        "12" {
                           set liste_buffers ""
                           while {$panneau(acqfen,demande_arret)==0} {
                              #--- Acquisition
                              ::acqfen::acqAcqfen
                              #--- Affichage avec visu auto
                              ::audace::autovisu $audace(visuNo)
                              #--- Si demande, sauvegarde temporaire de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set buftmp [buf::create]
                                 buf$buftmp extension $conf(extension,defaut)
                                 buf$audace(bufNo) copyto $buftmp
                                 lappend $liste_buffers [list $buftmp $panneau(acqfen,index)]
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
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
                              ::acqfen::acqAcqfen
                              #--- Affichage eventuel
                              if {$nbint==$panneau(acqfen,fenreglfen22)} {
                                 ::audace::autovisu $audace(visuNo)
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
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
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
                              ::acqfen::acqAcqfen
                              #--- Si demande, sauvegarde temporaire de l'image
                              if {$panneau(acqfen,enregistrer)==1} {
                                 set buftmp [buf::create]
                                 buf$buftmp extension $conf(extension,defaut)
                                 buf$audace(bufNo) copyto $buftmp
                                 lappend $liste_buffers [list $buftmp $panneau(acqfen,index)]
                                 incr panneau(acqfen,index)
                              }
                              #--- Corrections eventuelles de suivi
                              if {$panneau(acqfen,fenreglfen4)=="2"} {acqfen::deplacerFenetre}
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
                           ::audace::autovisu $audace(visuNo)
                        }
                     }
                  }
               }
               #--- On restitue l'affichage du bouton "GO" :
               set panneau(acqfen,go_stop) go
               $This.acq.but configure -text $caption(acqfen,GO)
               $This.acqred.but configure -text $caption(acqfen,GO)
               #--- Mise a jour de variables
               set panneau(acqfen,acquisition)   "0"
               set panneau(acqfen,demande_arret) "0"
            }
            "stop" {
               #--- On positionne un indicateur de demande d'arret
               set panneau(acqfen,demande_arret) "1"
               #--- Annulation de l'alarme de fin de pose
               catch { after cancel bell }
               #--- Arret de la capture de l'image
               ::camera::stopAcquisition [ ::confVisu::getCamItem $audace(visuNo) ]
               #--- J'attends la fin de l'acquisition
               vwait panneau(acqfen,finAquisition)
            }
         }
      } else {
         ::confCam::run
      }
   }

   #--- Procedure d'acquisition elementaire
   proc acqAcqfen { } {
      global audace panneau

      set catchError [ catch {
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
            #--- Cas des petites poses : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
            if { $panneau(acqfen,pose) >= "0" && $panneau(acqfen,pose) < "1" } {
               ::acqfen::avancementPose $panneau(acqfen,pose) 0
            }
            #--- Alarme sonore de fin de pose
            ::camera::alarmeSonore $panneau(acqfen,pose)
            #--- Declenchement de l'acquisition
            ::camera::acquisition [ ::confVisu::getCamItem $audace(visuNo) ] "::acqfen::attendImage" $panneau(acqfen,pose)
            #--- Appel du timer
            after 10 ::acqfen::dispTime $panneau(acqfen,pose)
            #--- Attente de la fin de l'acquisition
            vwait panneau(acqfen,finAquisition)
            #--- Effacement de la fenetre de progression
            if [ winfo exists $audace(base).progress_pose ] {
               destroy $audace(base).progress_pose
            }
         } else {
            for {set k 1} {$k<=$panneau(acqfen,fenreglfen12)} {incr k} {cam$audace(camNo) wipe}
            after [expr int(1000*$panneau(acqfen,pose))] [cam$audace(camNo) read]
         }

         #--- Rajoute des mots cles dans l'en-tete FITS
         foreach keyword [ ::keyword::getKeywords $audace(visuNo) $::conf(acqfen,keywordConfigName) ] {
            buf$audace(bufNo) setkwd $keyword
         }

         #--- Mise a jour du nom du fichier dans le titre et de la fenetre de l'en-tete FITS
         ::confVisu::setFileName $audace(visuNo) ""

         #--- Fenetrage sur le buffer si la camera ne possede pas le mode fenetrage (APN et WebCam)
         if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] hasWindow ] == "0" } {
            buf$audace(bufNo) window [list $panneau(acqfen,X1) $panneau(acqfen,Y1) \
            $panneau(acqfen,X2) $panneau(acqfen,Y2)]
         }
      } ]

      if { $catchError == 1 } {
         #--- j'affiche et je trace le message d'erreur
         ::tkutil::displayErrorInfo $::caption(acqfen,titre_fenetrees)

         #--- Effacement de la fenetre de progression
         if [ winfo exists $audace(base).progress_pose ] {
            destroy $audace(base).progress_pose
         }
      }
   }

   #--- Procedure appelee par la thread de la camera pour informer de l'avancement des acquisitions
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
            set panneau(acqfen,finAquisition) "acquisitionResult"
         }
         "error" {
            #--- ce message signale qu'une erreur est survenue dans la thread de la camera
            #--- j'affiche l'erreur dans la console
            ::console::affiche_erreur "::acqfen::acqAcqfen error: $args\n"
            set panneau(acqfen,finAquisition) "acquisitionResult"
         }
      }
   }

   #------------------------------------------------------------
   # dispTime
   #    Decompte du temps d'exposition
   #    Utilisation dans les scripts : acqfen.tcl + snacq.tcl
   #------------------------------------------------------------
   proc dispTime { exptime } {
      global audace panneau

      #--- j'arrete le timer s'il est deja lance
      if { [ info exists panneau(acqfen,dispTimeAfterId) ] && $panneau(acqfen,dispTimeAfterId) != "" } {
         after cancel $panneau(acqfen,dispTimeAfterId)
         set panneau(acqfen,dispTimeAfterId) ""
      }

      #--- je mets a jour la fenetre de progression
      set t [ cam$audace(camNo) timer -1 ]
      ::acqfen::avancementPose $exptime $t

      if { $t > 0 } {
         #--- je lance l'iteration suivante avec un delai de 1000 millisecondes
         #--- (mode asynchone pour eviter l'empilement des appels recursifs)
         set panneau(acqfen,dispTimeAfterId) [ after 1000 ::acqfen::dispTime $exptime ]
      } else {
         #--- je ne relance pas le timer
         set panneau(acqfen,dispTimeAfterId) ""
      }
   }

   #------------------------------------------------------------
   # avancementPose exptime t
   #    Affichage d'une barre de progression qui simule l'avancement de la pose dans la visu 1
   #------------------------------------------------------------
   proc avancementPose { exptime t } {
      global audace caption color conf panneau

      #--- Fenetre d'avancement de la pose non demandee
      if { $panneau(acqfen,avancement_acq) == "0" } {
         return
      }

      #--- Recuperation de la position de la fenetre
      ::acqfen::recupPositionAvancementPose

      #--- Initialisation de la barre de progression
      set cpt "100"

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqfen,avancement,position) ] } { set conf(acqfen,avancement,position) "+120+315" }

      #---
      if { [ winfo exists $audace(base).progress_pose ] != "1" } {

         #--- Cree la fenetre toplevel
         toplevel $audace(base).progress_pose
         wm transient $audace(base).progress_pose $audace(base)
         wm resizable $audace(base).progress_pose 0 0
         wm title $audace(base).progress_pose "$caption(acqfen,en_cours)"
         wm geometry $audace(base).progress_pose $conf(acqfen,avancement,position)

         #--- Cree le widget et le label du temps ecoule
         label $audace(base).progress_pose.lab_status -text "" -justify center
         pack $audace(base).progress_pose.lab_status -side top -fill x -expand true -pady 5

         #---
         if { $panneau(acqfen,demande_arret) == "1" } {
            $audace(base).progress_pose.lab_status configure -text "$caption(acqfen,numerisation)"
         } else {
            if { $t < 0 } {
               destroy $audace(base).progress_pose
            } elseif { $t > 0 } {
               $audace(base).progress_pose.lab_status configure -text "$t $caption(acqfen,sec) / \
                  [ format "%d" [ expr int( $exptime ) ] ] $caption(acqfen,sec)"
               set cpt [ expr $t * 100 / int( $exptime ) ]
               set cpt [ expr 100 - $cpt ]
            } else {
               $audace(base).progress_pose.lab_status configure -text "$caption(acqfen,numerisation)"
            }
         }

         #---
         catch {
            #--- Cree le widget pour la barre de progression
            frame $audace(base).progress_pose.cadre -width 200 -height 30 -borderwidth 2 -relief groove
            pack $audace(base).progress_pose.cadre -in $audace(base).progress_pose -side top \
               -anchor center -fill x -expand true -padx 8 -pady 8

            #--- Affiche de la barre de progression
            frame $audace(base).progress_pose.cadre.barre_color_invariant -height 26 -bg $color(blue)
            place $audace(base).progress_pose.cadre.barre_color_invariant -in $audace(base).progress_pose.cadre \
               -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
            update
         }

         #--- Mise a jour dynamique des couleurs
         if { [ winfo exists $audace(base).progress_pose ] == "1" } {
            ::confColor::applyColor $audace(base).progress_pose
         }

      } else {

         #---
         if { $panneau(acqfen,acquisition) == "0" } {
            #--- Je supprime la fenetre s'il n'y a plus de pose en cours
            destroy $audace(base).progress_pose
         } else {
            if { $panneau(acqfen,demande_arret) == "0" } {
               if { $t > 0 } {
                  $audace(base).progress_pose.lab_status configure -text "$t $caption(acqfen,sec) / \
                     [ format "%d" [ expr int( $exptime ) ] ] $caption(acqfen,sec)"
                  set cpt [ expr $t * 100 / int( $exptime ) ]
                  set cpt [ expr 100 - $cpt ]
               } else {
                  $audace(base).progress_pose.lab_status configure -text "$caption(acqfen,numerisation)"
               }
            } else {
               #--- J'affiche "Lecture" des qu'une demande d'arret est demandee
               $audace(base).progress_pose.lab_status configure -text "$caption(acqfen,numerisation)"
            }
            catch {
               #--- Affiche de la barre de progression
               place $audace(base).progress_pose.cadre.barre_color_invariant -in $audace(base).progress_pose.cadre \
                  -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
               update
            }
         }

      }

   }

   #------------------------------------------------------------
   # recupPositionAvancementPose
   #    Recuperation de la position de la fenetre de progression de la pose
   #------------------------------------------------------------
   proc recupPositionAvancementPose { } {
      global audace conf

      if [ winfo exists $audace(base).progress_pose ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $audace(base).progress_pose ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqfen,avancement,position) "+[ string range $geometry $deb $fin ]"
      }
   }

   #--- Procedures d'actualisation des coordonnees
   proc actualiserCoordonnees { { visuNo "1" } } {
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
         $This.acq.but configure -text $caption(acqfen,GO) -command ::acqfen::goStop
         $This.acqred.but configure -text $caption(acqfen,GO) -command ::acqfen::goStop
      }
   }

   proc ChangeMode { { mode "" } } {
      global panneau

      pack forget $panneau(acqfen,mode,$panneau(acqfen,mode)) -anchor nw -fill x

      if { $mode != "" } {
         #--- j'applique le mode passe en parametre
         set panneau(acqfen,mode_en_cours) $mode
      }

      set panneau(acqfen,mode) [ expr [ lsearch "$panneau(acqfen,list_mode)" "$panneau(acqfen,mode_en_cours)" ] + 1 ]
      pack $panneau(acqfen,mode,$panneau(acqfen,mode)) -anchor nw -fill x
   }

   #--- Procedure de suivi par deplacement de la fenetre
   proc deplacerFenetre { } {
      global audace

      set dimx [lindex [buf$audace(bufNo) getkwd NAXIS1 ] 1]
      set dimy [lindex [buf$audace(bufNo) getkwd NAXIS2 ] 1]
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

   #--- Procedure de sauvegarde de l'image
   #--- Procedure lancee par appui sur le bouton "enregistrer", uniquement dans le
   #--- mode "Une image".
   proc sauveUneImage { } {
      global audace caption conf panneau

      #--- Enregistrement de l'extension des fichiers
      set ext $conf(extension,defaut)

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
      #--- Si la case index est cochee, verifier qu'il y a bien un index
      if {$panneau(acqfen,indexer) == 1} {
         #--- Verifie que l'index existe
         if {$panneau(acqfen,index) == ""} {
            tk_messageBox -title $caption(acqfen,pb) -type ok \
               -message $caption(acqfen,saisind)
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

   #---Procedure de fermeture de la fenetre des reglages
   proc quitFenReglFen { } {
   global audace conf panneau

      set panneau(acqfen,fenreglfen1)  $panneau(acqfen,oldfenreglfen1)
      set panneau(acqfen,fenreglfen12) $panneau(acqfen,oldfenreglfen12)
      set panneau(acqfen,fenreglfen2)  $panneau(acqfen,oldfenreglfen2)
      set panneau(acqfen,fenreglfen22) $panneau(acqfen,oldfenreglfen22)
      set panneau(acqfen,fenreglfen3)  $panneau(acqfen,oldfenreglfen3)
      set panneau(acqfen,fenreglfen4)  $panneau(acqfen,oldfenreglfen4)
      #--- Recuperation de la position de la fenetre de reglages
      ::acqfen::recupPosition
      set conf(fenreglfen,position)    $panneau(acqfen,position)
      #---
      destroy $audace(base).fenreglfen
   }

   #---Procedure de recuperation de la position de la fenetre de reglage
   proc recupPosition { } {
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
global caption color panneau

#--- Trame du panneau

frame $This -borderwidth 2 -relief groove

   #--- Trame du titre panneau
   frame $This.titre -borderwidth 2 -relief groove
   pack $This.titre -side top -fill x

      Button $This.titre.but -borderwidth 1 \
         -text "$caption(acqfen,help_titre1)\n$caption(acqfen,titre_fenetrees)" \
         -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqfen::getPluginType ] ] \
            [ ::acqfen::getPluginDirectory ] [ ::acqfen::getPluginHelp ]"
      pack $This.titre.but -in $This.titre -anchor center -expand 1 -fill both -side top -ipadx 5
      DynamicHelp::add $This.titre.but -text $caption(acqfen,help_titre)

   #--- Trame de la configuration
   frame $This.config -borderwidth 2 -relief groove
   pack $This.config -side top -fill x

      #--- Bonton de Configuration
      button $This.config.but -text $caption(acqfen,congiguration) -borderwidth 1 -command creeFenReglFen
      pack $This.config.but -in $This.config -anchor center -expand 1 -fill both -side top -ipadx 5

   #--- Trame acquisition centrage (version complete)
   frame $This.acqcent -borderwidth 1 -relief groove

      #--- Sous-titre "acquisition pleine trame"
      button $This.acqcent.titre -text $caption(acqfen,titre_centrage) -borderwidth 0 \
         -command ::acqfen::changerAffPleineTrame
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
            -relief groove -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $This.acqcent.pose.pose_ent -side left -fill y

      pack $This.acqcent.pose -expand true

      #--- Bouton binning
      button $This.acqcent.butbin -text $caption(acqfen,bin,$panneau(acqfen,bin_centrage)) \
         -command ::acqfen::changerBinningCent
      pack $This.acqcent.butbin -expand true

      #--- Bouton Go/Stop
      button $This.acqcent.but -text $caption(acqfen,GO) -borderwidth 3 -command ::acqfen::goStopCent
      pack $This.acqcent.but -expand true -fill both

   #--- Trame acquisition centrage (version reduite)
   frame $This.acqcentred -borderwidth 1 -relief groove

      #--- Sous-titre "acquisition pleine trame"
      button $This.acqcentred.titre -text $caption(acqfen,titre_centrage) -borderwidth 0 \
         -command ::acqfen::changerAffPleineTrame
      pack $This.acqcentred.titre -expand true -fill x -pady 2

      #--- Bouton Go/Stop
      button $This.acqcentred.but -text $caption(acqfen,GO) -borderwidth 3 -command ::acqfen::goStopCent
      pack $This.acqcentred.but -expand true -fill both

   #--- Trame acquisition fenetree (version complete)
   frame $This.acq -borderwidth 1 -relief groove

      #--- Sous-titre "acquisitions fenetrees"
      button $This.acq.titre -text $caption(acqfen,titre_fenetrees) -borderwidth 0 \
         -command ::acqfen::changerAffFenetrees
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
            -relief groove -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $This.acq.pose.pose_ent -side left -fill y

      pack $This.acq.pose -expand true

      #--- Bouton binning
      button $This.acq.butbin -text $caption(acqfen,bin,$panneau(acqfen,bin)) \
         -command ::acqfen::changerBinning
      pack $This.acq.butbin -expand true

      #--- Representation matrice CCD
      frame $This.acq.matrice_color_invariant -bg $color(blue) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acq.matrice_color_invariant
      frame $This.acq.matrice_color_invariant.fen -bg $color(cyan) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acq.matrice_color_invariant.fen

      #--- Bouton Go/Stop
      button $This.acq.but -text $caption(acqfen,actuxy) -borderwidth 3 -command ::acqfen::actualiserCoordonnees
      pack $This.acq.but -expand true -fill both

   #--- Trame acquisition fenetree (version reduite)
   frame $This.acqred -borderwidth 1 -relief groove

      #--- Sous-titre "acquisitions fenetrees"
      button $This.acqred.titre -text $caption(acqfen,titre_fenetrees) -borderwidth 0 \
         -command ::acqfen::changerAffFenetrees
      pack $This.acqred.titre -expand true -fill x -pady 2

      #--- Representation matrice CCD
      frame $This.acqred.matrice_color_invariant -bg $color(blue) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acqred.matrice_color_invariant
      frame $This.acqred.matrice_color_invariant.fen -bg $color(cyan) -height $panneau(acqfen,mtx_y) \
         -width $panneau(acqfen,mtx_x)
      pack $This.acqred.matrice_color_invariant.fen

      #--- Bouton Go/Stop
      button $This.acqred.but -text $caption(acqfen,actuxy) -borderwidth 3 -command ::acqfen::actualiserCoordonnees
      pack $This.acqred.but -expand true -fill both

   #--- Trame du mode d'acquisition
   frame $This.mode -borderwidth 2 -relief groove

      #--- Trame du mode d'acquisition
      set panneau(acqfen,mode_en_cours) [ lindex $panneau(acqfen,list_mode) [ expr $panneau(acqfen,mode) - 1 ] ]
      ComboBox $This.mode.but \
         -width 15         \
         -height [llength $panneau(acqfen,list_mode)] \
         -relief raised    \
         -borderwidth 1    \
         -editable 0       \
         -takefocus 1      \
         -justify center   \
         -textvariable panneau(acqfen,mode_en_cours) \
         -values $panneau(acqfen,list_mode) \
         -modifycmd "::acqfen::ChangeMode"
      pack $This.mode.but -side top -fill x

      #--- Definition du sous-panneau "Mode: Une seule image"
      frame $This.mode.une -borderwidth 0

         frame $This.mode.une.nom -relief ridge -borderwidth 2
            label $This.mode.une.nom.but -text $caption(acqfen,nom) -pady 0
            pack $This.mode.une.nom.but -fill x -side top
            entry $This.mode.une.nom.entr -width 10 -textvariable panneau(acqfen,nom_image) \
               -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $This.mode.une.nom.entr -fill x -side top
         pack $This.mode.une.nom -expand true -fill both
         frame $This.mode.une.index -relief ridge -borderwidth 2
            checkbutton $This.mode.une.index.case -pady 0 -text $caption(acqfen,index)\
               -variable panneau(acqfen,indexer)
            pack $This.mode.une.index.case -expand true -fill both
            entry $This.mode.une.index.entr -width 3 -textvariable panneau(acqfen,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $This.mode.une.index.entr -side left -fill x -expand true
            button $This.mode.une.index.but -text "1" -width 3 -command {set panneau(acqfen,index) 1}
            pack $This.mode.une.index.but -side right -fill x
         pack $This.mode.une.index -expand true -fill both
         button $This.mode.une.sauve -text $caption(acqfen,sauvegde) -command ::acqfen::sauveUneImage
         pack $This.mode.une.sauve -expand true -fill both

      #--- Definition du sous-panneau "Mode: Serie d'image"
      frame $This.mode.serie -borderwidth 0
         frame $This.mode.serie.nom -relief ridge -borderwidth 2
            label $This.mode.serie.nom.but -text $caption(acqfen,nom) -pady 0
            pack $This.mode.serie.nom.but -fill x
            entry $This.mode.serie.nom.entr -width 10 -textvariable panneau(acqfen,nom_image) \
               -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $This.mode.serie.nom.entr -fill x
         pack $This.mode.serie.nom -expand true -fill both
         frame $This.mode.serie.nb -relief ridge -borderwidth 2
            label $This.mode.serie.nb.but -text $caption(acqfen,nombre) -pady 0
            pack $This.mode.serie.nb.but -side left -fill y
            entry $This.mode.serie.nb.entr -width 3 -textvariable panneau(acqfen,nb_images) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $This.mode.serie.nb.entr -side left -fill x -expand true
         pack $This.mode.serie.nb -expand true -fill both
         frame $This.mode.serie.index -relief ridge -borderwidth 2
            label $This.mode.serie.index.lab -text $caption(acqfen,index) -pady 0
            pack $This.mode.serie.index.lab -expand true -fill both
            entry $This.mode.serie.index.entr -width 3 -textvariable panneau(acqfen,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
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
               -relief groove \
               -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $This.mode.continu.nom.entr -fill x
         pack $This.mode.continu.nom -expand true -fill both
         frame $This.mode.continu.index -relief ridge -borderwidth 2
            label $This.mode.continu.index.lab -text $caption(acqfen,index) -pady 0
            pack $This.mode.continu.index.lab -expand true -fill both
            entry $This.mode.continu.index.entr -width 3 -textvariable panneau(acqfen,index) \
               -relief groove -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
            pack $This.mode.continu.index.entr -side left -fill x -expand true
            button $This.mode.continu.index.but -text "1" -width 3 -command {set panneau(acqfen,index) 1}
            pack $This.mode.continu.index.but -side right -fill x
         pack $This.mode.continu.index -expand true -fill both

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      frame $This.mode.avancement_acq -borderwidth 2 -relief ridge
        #--- Checkbutton pour l'affichage de l'avancement de l'acqusition
        checkbutton $This.mode.avancement_acq.check -highlightthickness 0 \
           -text $caption(acqfen,avancement_acq) -variable panneau(acqfen,avancement_acq)
        pack $This.mode.avancement_acq.check -side left -fill x
     pack $This.mode.avancement_acq -side bottom -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

#---Procedure d'affichage de la fenetre de reglages acquisition serie et continu
proc creeFenReglFen { } {
   global audace caption conf panneau

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
      wm protocol $audace(base).fenreglfen WM_DELETE_WINDOW ::acqfen::quitFenReglFen

      #--- Enregistrement des reglages courants
      set panneau(acqfen,oldfenreglfen1)  $panneau(acqfen,fenreglfen1)
      set panneau(acqfen,oldfenreglfen12) $panneau(acqfen,fenreglfen12)
      set panneau(acqfen,oldfenreglfen2)  $panneau(acqfen,fenreglfen2)
      set panneau(acqfen,oldfenreglfen22) $panneau(acqfen,fenreglfen22)
      set panneau(acqfen,oldfenreglfen3)  $panneau(acqfen,fenreglfen3)
      set panneau(acqfen,oldfenreglfen4)  $panneau(acqfen,fenreglfen4)

      #--- Frame pour l'en-tete FITS
      frame $audace(base).fenreglfen.setup -borderwidth 0 -relief raise

         #--- Label de l'en-tete FITS
         label $audace(base).fenreglfen.setup.lab -text "$caption(acqfen,en-tete_fits)"
         pack $audace(base).fenreglfen.setup.lab -side left -padx 6

         #--- Bouton d'acces aux mots cles
         button $audace(base).fenreglfen.setup.but1 -text "$caption(acqfen,mots_cles)" \
            -command "::keyword::run $audace(visuNo) ::conf(acqfen,keywordConfigName)"
         pack $audace(base).fenreglfen.setup.but1 -side left -padx 6 -pady 10 -ipadx 20

      pack $audace(base).fenreglfen.setup -side top -fill both -expand 1

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
         -width 10 -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 9999 }
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
         -width 10 -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 2 9999 }
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
            ::acqfen::recupPosition
            set conf(fenreglfen,position) $panneau(acqfen,position)
            destroy $audace(base).fenreglfen
         }
      pack $audace(base).fenreglfen.buttons.ok -side left -expand true -padx 10 -pady 10
      button $audace(base).fenreglfen.buttons.quit -command ::acqfen::quitFenReglFen \
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

