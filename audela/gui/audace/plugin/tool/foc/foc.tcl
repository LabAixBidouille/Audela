#
# Fichier : foc.tcl
# Description : Outil pour le controle de la focalisation
# Compatibilité : Protocoles LX200 et AudeCom
# Auteurs : Alain KLOTZ et Robert DELMAS
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace foc
#    initialise le namespace
#============================================================
namespace eval ::foc {
   package provide foc 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] foc.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(foc,focalisation)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "foc.htm"
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
      return "foc"
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
         subfunction1 { return "focusing" }
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
      createPanel $in.foc
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
      global conf caption panneau

      set This $this

      #--- Initialisation de la position du graphique
      if { ! [ info exists conf(visufoc,position) ] } {
         set conf(visufoc,position) "+200+0"
      }
      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(parafoc,position) ] } {
         set conf(parafoc,position) "+500+75"
      }
      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(foc,avancement,position) ] } {
         set conf(foc,avancement,position) "+120+315"
      }

      #--- Initialisation de variables
      set panneau(foc,menu)             "$caption(foc,centrage)"
      set panneau(foc,centrage_fenetre) "1"
      set panneau(foc,compteur)         "0"
      set panneau(foc,bin)              "1"
      set panneau(foc,exptime)          "2"
      set panneau(foc,go)               "$caption(foc,go)"
      set panneau(foc,stop)             "$caption(foc,stop)"
      set panneau(foc,raz)              "$caption(foc,raz)"
      set panneau(foc,focuser)          "focuserlx200"
      set panneau(foc,trouve)           "$caption(foc,se_trouve)"
      set panneau(foc,pas)              "$caption(foc,pas)"
      set panneau(foc,deplace)          "$caption(foc,aller_a)"
      set panneau(foc,initialise)       "$caption(foc,init)"
      set panneau(foc,dispTimeAfterId)  ""
      set panneau(foc,pose_en_cours)    "0"
      set panneau(foc,demande_arret)    "0"
      set panneau(foc,avancement_acq)   "1"
      set panneau(foc,fichier)          ""

      focBuildIF $This
   }

   #------------------------------------------------------------
   # adaptOutilFoc
   #    adapte automatiquement l'interface graphique de l'outil
   #------------------------------------------------------------
   proc adaptOutilFoc { { a "" } { b "" } { c "" } } {
      variable This

      if { [ ::focus::possedeControleEtendu $::panneau(foc,focuser) ] == "1"} {
         #--- Avec controle etendu
         pack $This.fra5.lab1 -in $This.fra5 -anchor center -fill none -padx 4 -pady 1
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill x -pady 1 -ipadx 15 -ipady 1 -padx 5
         pack $This.fra5.fra1 -in $This.fra5 -anchor center -fill none
         pack $This.fra5.fra1.lab1 -in $This.fra5.fra1 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.fra1.lab2 -in $This.fra5.fra1 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.but2 -in $This.fra5 -anchor center -fill x -pady 1 -ipadx 15 -padx 5
         pack $This.fra5.fra2 -in $This.fra5 -anchor center -fill none
         pack $This.fra5.fra2.ent3 -in $This.fra5.fra2 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.fra2.lab4 -in $This.fra5.fra2 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.but3 -in $This.fra5 -anchor center -fill x -pady 1 -ipadx 15 -padx 5
         if {$::panneau(foc,focuser) eq "usb_focus"} {
            pack forget $This.fra5.but1
            ::focus::displayCurrentPosition $::panneau(foc,focuser) ; #usb_focus
            #--   modifie la commande du bouton en appelant la cmd focus en mode non bloquant
            $This.fra5.but2 configure -command { ::focus::goto usb_focus 0 }
            #--   modifie la commande validation de la saisie
            $This.fra5.fra2.ent3 configure -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 65535 }
            pack forget $This.fra5.but3
         } else {
            #--   sans effet si la commande est deja configuree comme cela
            $This.fra5.but2 configure -command { ::foc::cmdSeDeplaceA }
            $This.fra5.fra2.ent3 configure -validatecommand { ::tkutil::validateNumber %W %V %P %s integer -32767 32767 }
         }
      } else {
         #--- Sans controle etendu
         pack forget $This.fra5.lab1
         pack forget $This.fra5.but1
         pack forget $This.fra5.fra1.lab1
         pack forget $This.fra5.fra1.lab2
         pack forget $This.fra5.but2
         pack forget $This.fra5.fra2.ent3
         pack forget $This.fra5.fra2.lab4
         pack forget $This.fra5.but3
      }
      $This.fra4.we.labPoliceInvariant configure -text $::audace(focus,labelspeed)
   }

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable This

      trace add variable ::conf(telescope) write ::foc::adaptOutilFoc
      trace add variable ::confEqt::private(variablePluginName) write ::foc::adaptOutilFoc
      pack $This -side left -fill y
      ::foc::adaptOutilFoc
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable This
      global audace panneau

      #--- Je verifie si une operation est en cours
      if { $panneau(foc,pose_en_cours) == "1" } {
         return -1
      }

      #--- Initialisation du fenetrage
      set camItem [ ::confVisu::getCamItem $audace(visuNo) ]
      if { [ ::confCam::isReady $camItem ] == "1" } {
         set n1n2 [ cam$audace(camNo) nbcells ]
         cam$audace(camNo) window [ list 1 1 [ lindex $n1n2 0 ] [ lindex $n1n2 1 ] ]
      }

      #--- Initialisation des variables et fermeture des fenetres auxiliaires
      set panneau(foc,compteur) "0"
      closeAllWindows $audace(base)

      #--- Arret de la surveillance de la variable conf(telescope)
      trace remove variable :::confEqt::private(variablePluginName) write ::foc::adaptOutilFoc
      trace remove variable ::conf(telescope) write ::foc::adaptOutilFoc

      #---
      pack forget $This
   }

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
         $This.fra2.but1 configure -relief groove -state disabled
         $This.fra2.but2 configure -text $panneau(foc,stop)
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
         }
         cam$audace(camNo) window $panneau(foc,window)
         #--- Suppression de la zone selectionnee avec la souris
         ::confVisu::deleteBox $audace(visuNo)
         #--- Appel a la fonction d'acquisition
         ::foc::cmdAcq
         #--- Gestion graphique des boutons
         if { $panneau(foc,actuel) == "$caption(foc,centrage)" } {
            $This.fra2.but1 configure -relief raised -text $panneau(foc,go) -state normal
            $This.fra2.but2 configure -relief raised -text $panneau(foc,raz)
         } else {
            $This.fra2.but2 configure -relief raised -text $panneau(foc,raz)
         }
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
            set audace(after,focstop,id) [ after [ expr int($delay*1000) ] { ::foc::cmdFocus stop } ]
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

            #--- Graphique
            append panneau(foc,fichier) "$inten $fwhmx $fwhmy $contr \n"

            ::vx append $panneau(foc,compteur)
            ::vyg_fwhmx append $fwhmx
            ::vyg_fwhmy append $fwhmy
            ::vyg_inten append $inten
            ::vyg_contr append $contr

            set w $audace(base).visufoc.g_fwhmx
            set lx [ $w axis limits x ]

            #--- Affichage des 20 dernieres mesures glissantes
            set index [ lindex $x [ expr [ llength $x ] - 1 ] ]
            if { $index > 20 } {
               $w axis configure x  -min [ expr $index - 19 ] -max $index
               $w axis configure x2 -min [ expr $index - 19 ] -max $index
            }

            set ly [ $w axis limits y ]
            $w axis configure y2 -min [ lindex $ly 0 ] -max [ lindex $ly 1 ]

            #--- Valeurs a l'ecran
            ::foc::qualiteFoc $inten $fwhmx $fwhmy $contr
            update
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
   # avancementPose
   #    sous processus de cmdAcq et de dispTime
   #------------------------------------------------------------
   proc avancementPose { t } {
      global audace caption color conf panneau

      #--- Fenetre d'avancement de la pose non demandee
      if { $panneau(foc,avancement_acq) == "0" } {
         return
      }

      #--- Recuperation de la position de la fenetre
      ::foc::closePositionAvancementPose

      #--- Initialisation de la barre de progression
      set cpt "100"

      #---
      if { [ winfo exists $audace(base).progress_pose ] != "1" } {

         #--- Cree la fenetre toplevel
         toplevel $audace(base).progress_pose
         wm transient $audace(base).progress_pose $audace(base)
         wm resizable $audace(base).progress_pose 0 0
         wm title $audace(base).progress_pose "$caption(foc,en_cours)"
         wm geometry $audace(base).progress_pose $conf(foc,avancement,position)

         #--- Cree le widget et le label du temps ecoule
         label $audace(base).progress_pose.lab_status -text "" -justify center
         pack $audace(base).progress_pose.lab_status -side top -fill x -expand true -pady 5

         #---
         if { $panneau(foc,demande_arret) == "1" } {
            $audace(base).progress_pose.lab_status configure -text "$caption(foc,numerisation)"
         } else {
            if { $t < "0" } {
               destroy $audace(base).progress_pose
            } elseif { $t > "0" } {
               $audace(base).progress_pose.lab_status configure -text "$t $caption(foc,sec) / \
                  [ format "%d" [ expr int( $panneau(foc,exptime) ) ] ] $caption(foc,sec)"
               set cpt [ expr $t * 100 / int( $panneau(foc,exptime) ) ]
               set cpt [ expr 100 - $cpt ]
            } else {
               $audace(base).progress_pose.lab_status configure -text "$caption(foc,numerisation)"
            }
         }

         #---
         if { [ winfo exists $audace(base).progress_pose ] == "1" } {
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
         if { $panneau(foc,pose_en_cours) == "0" } {

            #--- Je supprime la fenetre s'il n'y a plus de pose en cours
            ::foc::closePositionAvancementPose

         } else {

            if { $panneau(foc,demande_arret) == "0" } {
               if { $t > "0" } {
                  $audace(base).progress_pose.lab_status configure -text "$t $caption(foc,sec) / \
                     [ format "%d" [ expr int( $panneau(foc,exptime) ) ] ] $caption(foc,sec)"
                  set cpt [ expr $t * 100 / int( $panneau(foc,exptime) ) ]
                  set cpt [ expr 100 - $cpt ]
               } else {
                  $audace(base).progress_pose.lab_status configure -text "$caption(foc,numerisation)"
               }
            } else {
               #--- J'affiche "Lecture" des qu'une demande d'arret est demandee
               $audace(base).progress_pose.lab_status configure -text "$caption(foc,numerisation)"
            }
            #--- Affiche de la barre de progression
            place $audace(base).progress_pose.cadre.barre_color_invariant -in $audace(base).progress_pose.cadre \
               -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
            update

         }

      }

   }

   #------------------------------------------------------------
   # closePositionAvancementPose
   #    ferme la fenetre d'avancement de la pose st sauve sa position
   #------------------------------------------------------------
   proc closePositionAvancementPose { } {
      global audace conf

      set w $audace(base).progress

      if [ winfo exists $audace(base).progress_pose ] {
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
   # closeAllWindows
   #    ferme toutes les fenetres annexes
   # Parametre : chemin du parent
   #------------------------------------------------------------
   proc closeAllWindows { base } {
      if {[winfo exists $base.parafoc]} {
         ::foc::fermeQualiteFoc $base.parafoc
      }
      if {[winfo exists $base.visufoc]} {
         ::foc::fermeGraphe $base.visufoc
      }
      if {[winfo exists $base.hfd]} {
         ::foc::closeHFDGraphe $::audace(visuNo) $base.hfd
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
         ::foc::fermeQualiteFoc
      }

      #--- Creation de la fenetre
      toplevel $this
      wm transient $this $audace(base)
      wm resizable $this 0 0
      wm title $this "$caption(foc,focalisation)"
      wm geometry $this $conf(parafoc,position)
      wm protocol $this WM_DELETE_WINDOW ::foc::fermeQualiteFoc

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

#------------   gestion du graphique classique -----------------

#---------------------------------------------------------------
# focGraphe
#    cree le fenetre graphique de suivi des parametres de focalisation
#---------------------------------------------------------------
proc focGraphe { } {
   global audace caption conf panneau

   set this $audace(base).visufoc

   #--- Fenetre d'affichage des parametres de la foc
   if [ winfo exists $this ] {
      fermeGraphe
   }

   #--- Creation et affichage des graphes
   if { [ winfo exists $this ] == "0" } {
      package require BLT
      #--- Creation de la fenetre
      toplevel $this
      wm title $this "$caption(foc,titre_graphe)"
      if { $panneau(foc,exptime) > "2" } {
         wm transient $this $audace(base)
      }
      wm resizable $this 1 1
      wm geometry $this $conf(visufoc,position)
      wm protocol $this WM_DELETE_WINDOW "fermeGraphe"
      #---
      visuf $this g_inten "$caption(foc,intensite_adu)"
      visuf $this g_fwhmx "$caption(foc,fwhm_x)"
      visuf $this g_fwhmy "$caption(foc,fwhm_y)"
      visuf $this g_contr "$caption(foc,contrast_adu)"
      update

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }
}

#------------------------------------------------------------
# visuf
#    cree un graphique de suivi d'un parametre
#------------------------------------------------------------
proc visuf { base win_name title } {

   set frm $base.$win_name

   #--   ::vx (compteur) est commun a tous les graphes
   if {"::vx" ni [blt::vector names]} {
      ::blt::vector create ::vx -watchunset 1
   }
   ::blt::vector create ::vy$win_name -watchunset 1

   ::blt::graph $frm
   $frm element create line1 -xdata ::vx -ydata ::vy$win_name
   $frm axis configure x -hide no -min 1 -max 20 -subdivision 0 -stepsize 1
   $frm axis configure x2 -hide no -min 1 -max 20 -subdivision 0 -stepsize 1
   $frm axis configure y -title "$title" -hide no -min 0 -max 1
   $frm axis configure y2 -hide no -min 0 -max 1
   $frm legend configure -hide yes
   $frm configure -height 140
   pack $frm
}

#------------------------------------------------------------
# fermeGraphe
#    ferme la fenetre des graphes et sauve la position
# Parametre : chemin de la fenetre
#------------------------------------------------------------
proc fermeGraphe { } {
   global audace conf

   set w $audace(base).visufoc

   #--- Determination de la position de la fenetre
   regsub {([0-9]+x[0-9]+)} [wm geometry $w] "" conf(visufoc,position)

   #--- Detruit les vecteurs persistants
   blt::vector destroy ::vx ::vyg_fwhmx ::vyg_fwhmy ::vyg_inten ::vyg_contr

   #--- Fermeture de la fenetre
   destroy $w
}

#------------------------------------------------------------
# focBuildIF
#    cree le panneau de l'outil
#------------------------------------------------------------
proc focBuildIF { This } {
   global audace caption panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$caption(foc,help_titre1)\n$caption(foc,focalisation)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::foc::getPluginType ] ] \
               [ ::foc::getPluginDirectory ] [ ::foc::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $caption(foc,help_titre)

      pack $This.fra1 -side top -fill x

      #--- Frame du centrage/pointage
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour acquistion
         label $This.fra2.lab1 -text $caption(foc,acquisition) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Menu
         menubutton $This.fra2.optionmenu1 -textvariable panneau(foc,menu) \
            -menu $This.fra2.optionmenu1.menu -relief raised
         pack $This.fra2.optionmenu1 -in $This.fra2 -anchor center -padx 4 -pady 2 -ipadx 3
         set m [ menu $This.fra2.optionmenu1.menu -tearoff 0 ]
         $m add radiobutton -label "$caption(foc,centrage)" \
            -indicatoron "1" \
            -value "1" \
            -variable panneau(foc,centrage_fenetre) \
            -command { set panneau(foc,menu) "$caption(foc,centrage)" ; set panneau(foc,centrage_fenetre) "1" }
         $m add radiobutton -label "$caption(foc,fenetre)" \
            -indicatoron "1" \
            -value "2" \
            -variable panneau(foc,centrage_fenetre) \
            -command { set panneau(foc,menu) "$caption(foc,fenetre)" ; set panneau(foc,centrage_fenetre) "2" }

         #--- Frame des entry & label
         frame $This.fra2.fra1 -borderwidth 1 -relief flat

            #--- Entry pour exptime
            entry $This.fra2.fra1.ent1 -textvariable panneau(foc,exptime) \
               -relief groove -width 6 -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
            pack $This.fra2.fra1.ent1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 2

            #--- Label secondes
            label $This.fra2.fra1.lab1 -text $caption(foc,seconde) -relief flat
            pack $This.fra2.fra1.lab1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 2

         pack $This.fra2.fra1 -in $This.fra2 -anchor center -fill none

         #--- Bouton GO
         button $This.fra2.but1 -borderwidth 2 -text $panneau(foc,go) -command { ::foc::cmdGo }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill x -padx 5 -pady 2 -ipadx 15 -ipady 1

         #--- Bouton STOP/RAZ
         button $This.fra2.but2 -borderwidth 2 -text $panneau(foc,raz) -command { ::foc::cmdStop }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill x -padx 5 -pady 2 -ipadx 15 -ipady 1

      pack $This.fra2 -side top -fill x

      #--- Frame des boutons manuels
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Frame focuser
         ::confEqt::createFrameFocuserTool $This.fra4.focuser ::panneau(foc,focuser)
         pack $This.fra4.focuser -in $This.fra4 -anchor nw -side top -padx 4 -pady 1

         #--   je lis la configuration de la commande de la combobox
         set oldCmd [$This.fra4.focuser.list configure -modifycmd]
         #--   je lis la commande ecrite par la proc ::confEqt::createFrameFocuserTool
         set cmd [lindex $oldCmd 4]
         #--   j'ajoute l'instruction ::foc::adaptOutilFoc
         append cmd "; ::foc::adaptOutilFoc"
         #--   je modifie la commande de la combobox
         $This.fra4.focuser.list configure -modifycmd $cmd

         #--- Label pour moteur focus
         label $This.fra4.lab1 -text $caption(foc,moteur_focus) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -fill none -padx 4 -pady 1

         #--- Create the buttons '- +'
         frame $This.fra4.we -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.we -in $This.fra4 -side top -fill x

         #--- Button '-'
         button $This.fra4.we.canv1PoliceInvariant -borderwidth 2 \
            -text "-" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $This.fra4.we.canv1PoliceInvariant -in $This.fra4.we -expand 0 -side left -padx 2 -pady 2

         #--- Write the label of speed for LX200 and compatibles
         label $This.fra4.we.labPoliceInvariant \
            -textvariable audace(focus,labelspeed) -width 2 -borderwidth 0 -relief flat
         pack $This.fra4.we.labPoliceInvariant -in $This.fra4.we -expand 1 -side left

         #--- Button '+'
         button $This.fra4.we.canv2PoliceInvariant -borderwidth 2 \
            -text "+" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $This.fra4.we.canv2PoliceInvariant -in $This.fra4.we -expand 0 -side right -padx 2 -pady 2

         set zone(moins) $This.fra4.we.canv1PoliceInvariant
         set zone(plus)  $This.fra4.we.canv2PoliceInvariant

      pack $This.fra4 -side top -fill x

      #--- Speed
      bind $This.fra4.we.labPoliceInvariant <ButtonPress-1> { ::foc::cmdSpeed }

      #--- Cardinal moves
      bind $zone(moins) <ButtonPress-1>   { ::foc::cmdFocus - }
      bind $zone(moins) <ButtonRelease-1> { ::foc::cmdFocus stop }
      bind $zone(plus)  <ButtonPress-1>   { ::foc::cmdFocus + }
      bind $zone(plus)  <ButtonRelease-1> { ::foc::cmdFocus stop }

      #--- Frame de la position focus
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Label pour la position focus
         label $This.fra5.lab1 -text $$caption(foc,pos_focus) -relief flat
         pack $This.fra5.lab1 -in $This.fra5 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton "Se trouve à"
         button $This.fra5.but1 -borderwidth 2 -text $panneau(foc,trouve) -command { ::foc::cmdSeTrouveA }
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Frame des labels
         frame $This.fra5.fra1 -borderwidth 1 -relief flat

            #--- Label pour la position courante du focuser
            entry $This.fra5.fra1.lab1 -textvariable audace(focus,currentFocus) \
               -relief groove -width 6 -state disabled
            pack $This.fra5.fra1.lab1 -in $This.fra5.fra1 -side left -fill none -padx 4 -pady 2

            #--- Label pas
            label $This.fra5.fra1.lab2 -text $panneau(foc,pas) -relief flat
            pack $This.fra5.fra1.lab2 -in $This.fra5.fra1 -side left -fill none -padx 4 -pady 2

         pack $This.fra5.fra1 -in $This.fra5 -anchor center -fill none

         #--- Bouton "Aller à"
         button $This.fra5.but2 -borderwidth 2 -text $panneau(foc,deplace) -command { ::foc::cmdSeDeplaceA }
         pack $This.fra5.but2 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Frame des entry & label
         frame $This.fra5.fra2 -borderwidth 1 -relief flat

            #--- Entry pour la position cible du focuser
            entry $This.fra5.fra2.ent3 -textvariable audace(focus,targetFocus) \
               -relief groove -width 6 -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer -32767 32767 }
            pack $This.fra5.fra2.ent3 -in $This.fra5.fra2 -side left -fill none -padx 4 -pady 2
            bind $This.fra5.fra2.ent3 <Enter> { ::foc::formatFoc }
            bind $This.fra5.fra2.ent3 <Leave> { destroy $audace(base).formatfoc }

            #--- Label pas
            label $This.fra5.fra2.lab4 -text $panneau(foc,pas) -relief flat
            pack $This.fra5.fra2.lab4 -in $This.fra5.fra2 -side left -fill none -padx 4 -pady 2

         pack $This.fra5.fra2 -in $This.fra5 -anchor center -fill none

         #--- Bouton "Initialisation"
         button $This.fra5.but3 -borderwidth 2 -text $panneau(foc,initialise) -command { ::foc::cmdInitFoc }
         pack $This.fra5.but3 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

      pack $This.fra5 -side top -fill x

      #--- Frame du graphe
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Bouton GRAPHE
         button $This.fra3.but1 -borderwidth 2 -text $caption(foc,graphe) -command { focGraphe }
         pack $This.fra3.but1 -in $This.fra3 -side bottom -fill x -padx 5 -pady 5 -ipadx 15 -ipady 2

      pack $This.fra3 -side top -fill x

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      frame $This.fra6 -borderwidth 2 -relief ridge

        #--- Checkbutton pour l'affichage de l'avancement de l'acqusition
        checkbutton $This.fra6.avancement_acq -highlightthickness 0 \
           -text $caption(foc,avancement_acq) -variable panneau(foc,avancement_acq)
        pack $This.fra6.avancement_acq -side left -fill x

     pack $This.fra6 -side top -fill x

     #--- Mise a jour dynamique des couleurs
     ::confColor::applyColor $This
}

