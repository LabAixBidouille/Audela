#
# Fichier : foc.tcl
# Description : Outil pour le controle de la focalisation
# Compatibilité : Protocoles LX200 et AudeCom
# Auteurs : Alain KLOTZ et Robert DELMAS
# Mise à jour $Id$
#

#--- Initialisation de variables
set ::graphik(compteur) {}
set ::graphik(inten)    {}
set ::graphik(fwhmx)    {}
set ::graphik(fwhmy)    {}
set ::graphik(contr)    {}
set ::graphik(fichier)  ""

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
      global caption panneau

      set This $this

      #---
      set panneau(foc,titre)            "$caption(foc,focalisation)"
      set panneau(foc,aide)             "$caption(foc,help_titre)"
      set panneau(foc,aide1)            "$caption(foc,help_titre1)"
      set panneau(foc,acq)              "$caption(foc,acquisition)"
      set panneau(foc,menu)             "$caption(foc,centrage)"
      set panneau(foc,centrage_fenetre) "1"
      set panneau(foc,compteur)         "0"
      set panneau(foc,bin)              "1"
      set panneau(foc,exptime)          "2"
      set panneau(foc,secondes)         "$caption(foc,seconde)"
      set panneau(foc,go)               "$caption(foc,go)"
      set panneau(foc,stop)             "$caption(foc,stop)"
      set panneau(foc,raz)              "$caption(foc,raz)"
      set panneau(foc,focuser)          "focuserlx200"
      set panneau(foc,motorfoc)         "$caption(foc,moteur_focus)"
      set panneau(foc,position)         "$caption(foc,pos_focus)"
      set panneau(foc,trouve)           "$caption(foc,se_trouve)"
      set panneau(foc,pas)              "$caption(foc,pas)"
      set panneau(foc,deplace)          "$caption(foc,aller_a)"
      set panneau(foc,initialise)       "$caption(foc,init)"
      set panneau(foc,graphe)           "$caption(foc,graphe)"
      set panneau(foc,dispTimeAfterId)  ""
      set panneau(foc,pose_en_cours)    "0"
      set panneau(foc,demande_arret)    "0"
      set panneau(foc,avancement_acq)   "1"

      focBuildIF $This
   }

   proc adaptOutilFoc { { a "" } { b "" } { c "" } } {
      variable This

      if { [ ::focus::possedeControleEtendu $::panneau(foc,focuser) ] == "1" } {
         #--- Avec controle etendu
         set ::panneau(foc,focuser) "focuseraudecom"
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
      } else {
         #--- Sans controle etendu
         set ::panneau(foc,focuser) "focuserlx200"
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

      #--- Je configure la combobox du focuser
      ::confEqt::setValueFrameFocuserTool $This.fra4.focuser $::panneau(foc,focuser)
   }

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable This

      trace add variable ::conf(telescope) write ::foc::adaptOutilFoc
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
      set ::graphik(compteur)   {}
      set ::graphik(inten)      {}
      set ::graphik(fwhmx)      {}
      set ::graphik(fwhmy)      {}
      set ::graphik(contr)      {}
      if [ winfo exists $audace(base).parafoc ] {
         destroy $audace(base).parafoc
      }
      if [ winfo exists $audace(base).visufoc ] {
         destroy $audace(base).visufoc
      }

      #--- Arret de la surveillance de la variable conf(telescope)
      trace remove variable ::conf(telescope) write ::foc::adaptOutilFoc

      #---
      pack forget $This
   }

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
            update
         } else {
            $This.fra2.but2 configure -relief raised -text $panneau(foc,raz)
            update
         }
      } else {
         ::confCam::run
      }
   }

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
            lappend ::graphik(compteur) $panneau(foc,compteur)
            #--- Statistiques
            set s [ stat ]
            set maxi [ lindex $s 2 ]
            set fond [ lindex $s 7 ]
            set ::contr [ format "%.0f" [ expr -1.*[ lindex $s 8 ] ] ]
            set ::inten [ format "%.0f" [ expr $maxi-$fond ] ]
            lappend ::graphik(inten) $::inten
            lappend ::graphik(contr) $::contr
            #--- Fwhm
            set naxis1 [ expr [ lindex [ $buffer getkwd NAXIS1 ] 1 ]-0 ]
            set naxis2 [ expr [ lindex [ $buffer getkwd NAXIS2 ] 1 ]-0 ]
            set box [ list 1 1 $naxis1 $naxis2 ]
            set f [ $buffer fwhm $box ]
            set ::fwhmx [ lindex $f 0 ]
            set ::fwhmy [ lindex $f 1 ]
            lappend ::graphik(fwhmx) $::fwhmx
            lappend ::graphik(fwhmy) $::fwhmy
            #--- Graphique
            append ::graphik(fichier) "$::inten $::fwhmx $::fwhmy $::contr \n"
            visuf g_inten $::graphik(compteur) $::graphik(inten) "$caption(foc,intensite_adu)" no
            visuf g_fwhmx $::graphik(compteur) $::graphik(fwhmx) "$caption(foc,fwhm_x)" no
            visuf g_fwhmy $::graphik(compteur) $::graphik(fwhmy) "$caption(foc,fwhm_y)" no
            visuf g_contr $::graphik(compteur) $::graphik(contr) "$caption(foc,contrast_adu)" no
            #--- Valeurs a l'ecran
            ::foc::qualiteFoc
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

   proc avancementPose { t } {
      global audace caption color conf panneau

      #--- Fenetre d'avancement de la pose non demandee
      if { $panneau(foc,avancement_acq) == "0" } {
         return
      }

      #--- Recuperation de la position de la fenetre
      ::foc::recupPositionAvancementPose

      #--- Initialisation de la barre de progression
      set cpt "100"

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(foc,avancement,position) ] } { set conf(foc,avancement,position) "+120+315" }

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
            destroy $audace(base).progress_pose
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

   proc recupPositionAvancementPose { } {
      global audace conf

      if [ winfo exists $audace(base).progress_pose ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $audace(base).progress_pose ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(foc,avancement,position) "+[ string range $geometry $deb $fin ]"
      }
   }

   proc cmdStop { } {
      variable This
      global audace caption panneau

      if { [ ::cam::list ] != "" } {
         if { [ $This.fra2.but2 cget -text ] == "$panneau(foc,raz)" } {
            set panneau(foc,compteur) "0"
            set ::graphik(compteur)   {}
            set ::graphik(inten)      {}
            set ::graphik(fwhmx)      {}
            set ::graphik(fwhmy)      {}
            set ::graphik(contr)      {}
            destroy $audace(base).parafoc
            destroy $audace(base).visufoc
            update
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
            update
         }
      } else {
         ::confCam::run
      }
   }

   proc cmdSauveLog { namefile } {
      global panneau

     if [ catch { open [ file join $::audace(rep_log) $namefile ] w } fileId ] {
        return
     } else {
         puts -nonewline $fileId $::graphik(fichier)
         close $fileId
      }
   }

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

   proc cmdInitFoc { } {
      variable This
      global audace panneau

      if { [ ::tel::list ] != "" } {
         #--- Gestion graphique du bouton
         $This.fra5.but3 configure -relief groove -text $panneau(foc,initialise)
         update
         #--- Met le compteur de foc a zero et rafraichit les affichages
         ::focus::initPosition  $::panneau(foc,focuser)
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

   proc formatFoc { } {
      global audace caption

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
      label $audace(base).formatfoc.lab1 -text "$caption(foc,formatfoc1)"
      pack $audace(base).formatfoc.lab1 -padx 10 -pady 2
      label $audace(base).formatfoc.lab2 -text "$caption(foc,formatfoc2)"
      pack $audace(base).formatfoc.lab2 -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $audace(base).formatfoc

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).formatfoc
   }

   proc limiteFoc { } {
      global audace caption

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
      label $audace(base).limitefoc.lab1 -text "$caption(foc,limitefoc1)"
      pack $audace(base).limitefoc.lab1 -padx 10 -pady 2
      if { $audace(focus,targetFocus) > "32767" } {
         label $audace(base).limitefoc.lab2 -text "$caption(foc,limitefoc2)"
         pack $audace(base).limitefoc.lab2 -padx 10 -pady 2
      } else {
         label $audace(base).limitefoc.lab2 -text "$caption(foc,limitefoc3)"
         pack $audace(base).limitefoc.lab2 -padx 10 -pady 2
      }

      #--- La nouvelle fenetre est active
      focus $audace(base).limitefoc

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).limitefoc
   }

   proc qualiteFoc { } {
      global audace caption conf panneau

      #--- Fenetre d'affichage des parametres de la foc
      if [ winfo exists $audace(base).parafoc ] {
         ::foc::fermeQualiteFoc
      }
      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(parafoc,position) ] } { set conf(parafoc,position) "+500+75" }
      #--- Creation de la fenetre
      toplevel $audace(base).parafoc
      wm transient $audace(base).parafoc $audace(base)
      wm resizable $audace(base).parafoc 0 0
      wm title $audace(base).parafoc "$caption(foc,focalisation)"
      wm geometry $audace(base).parafoc $conf(parafoc,position)
      wm protocol $audace(base).parafoc WM_DELETE_WINDOW ::foc::fermeQualiteFoc
      #--- Cree les etiquettes
      label $audace(base).parafoc.lab1 -text "$panneau(foc,compteur)"
      pack $audace(base).parafoc.lab1 -padx 10 -pady 2
      label $audace(base).parafoc.lab2 -text "$caption(foc,intensite) $caption(foc,egale) $::inten"
      pack $audace(base).parafoc.lab2 -padx 5 -pady 2
      label $audace(base).parafoc.lab3 -text "$caption(foc,fwhm__x) $caption(foc,egale) $::fwhmx"
      pack $audace(base).parafoc.lab3 -padx 5 -pady 2
      label $audace(base).parafoc.lab4 -text "$caption(foc,fwhm__y) $caption(foc,egale) $::fwhmy"
      pack $audace(base).parafoc.lab4 -padx 5 -pady 2
      label $audace(base).parafoc.lab5 -text "$caption(foc,contraste) $caption(foc,egale) $::contr"
      pack $audace(base).parafoc.lab5 -padx 5 -pady 2
      update

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).parafoc
   }

   proc fermeQualiteFoc { } {
      global audace conf

      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $audace(base).parafoc ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(parafoc,position) "+[ string range $geometry $deb $fin ]"
      #--- Fermeture de la fenetre
      destroy $audace(base).parafoc
   }

}

proc focGraphe { } {
   global audace caption conf panneau

   #--- Fenetre d'affichage des parametres de la foc
   if [ winfo exists $audace(base).visufoc ] {
      fermeGraphe
   }
   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(visufoc,position) ] } { set conf(visufoc,position) "+200+0" }
   #--- Creation et affichage des graphes
   if { [ winfo exists $audace(base).visufoc ] == "0" } {
      package require BLT
      #--- Creation de la fenetre
      toplevel $audace(base).visufoc
      wm title $audace(base).visufoc "$caption(foc,titre_graphe)"
      if { $panneau(foc,exptime) > "2" } {
         wm transient $audace(base).visufoc $audace(base)
      }
      wm resizable $audace(base).visufoc 1 1
      wm geometry $audace(base).visufoc $conf(visufoc,position)
      wm protocol $audace(base).visufoc WM_DELETE_WINDOW { fermeGraphe }
      #---
      ::blt::graph $audace(base).visufoc.g_inten
      ::blt::graph $audace(base).visufoc.g_fwhmx
      ::blt::graph $audace(base).visufoc.g_fwhmy
      ::blt::graph $audace(base).visufoc.g_contr
      visuf g_inten $::graphik(compteur) $::graphik(inten) "$caption(foc,intensite_adu)" no
      visuf g_fwhmx $::graphik(compteur) $::graphik(fwhmx) "$caption(foc,fwhm_x)" no
      visuf g_fwhmy $::graphik(compteur) $::graphik(fwhmy) "$caption(foc,fwhm_y)" no
      visuf g_contr $::graphik(compteur) $::graphik(contr) "$caption(foc,contrast_adu)" no
      update

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).visufoc
   }
}

proc fermeGraphe { } {
   global audace conf

   #--- Determination de la position de la fenetre
   set geometry [ wm geometry $audace(base).visufoc ]
   set deb [ expr 1 + [ string first + $geometry ] ]
   set fin [ string length $geometry ]
   set conf(visufoc,position) "+[ string range $geometry $deb $fin ]"
   #--- Fermeture de la fenetre
   destroy $audace(base).visufoc
}

proc visuf { win_name x y { title "" } { yesno "yes" } } {
   global audace

   if { [ winfo exists $audace(base).visufoc.$win_name ] == "1" } {
      ::blt::vector delete vx$win_name
      ::blt::vector delete vy$win_name
      catch { $audace(base).visufoc.$win_name element delete line1 }
      ::blt::vector create vx$win_name
      vx$win_name set $x
      ::blt::vector create vy$win_name
      vy$win_name set $y
      $audace(base).visufoc.$win_name element create line1 -xdata vx$win_name -ydata vy$win_name
      $audace(base).visufoc.$win_name legend configure -hide yes
      $audace(base).visufoc.$win_name axis configure y -title "$title"
      $audace(base).visufoc.$win_name axis configure x -hide $yesno
      if { $yesno == "yes" } {
         set h 110
      } else {
         set h 140
      }
      $audace(base).visufoc.$win_name configure -height $h
      $audace(base).visufoc.$win_name axis configure x2 -hide no
      set lx [ $audace(base).visufoc.$win_name axis limits x ]
      $audace(base).visufoc.$win_name axis configure x2 -min [ lindex $lx 0 ] -max [ lindex $lx 1 ]
      $audace(base).visufoc.$win_name axis configure y2 -hide no
      set ly [ $audace(base).visufoc.$win_name axis limits y ]
      $audace(base).visufoc.$win_name axis configure y2 -min [ lindex $ly 0 ] -max [ lindex $ly 1 ]
      pack $audace(base).visufoc.$win_name
   }
}

#------------------------------------------------------------
# focBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc focBuildIF { This } {
   global audace caption panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$panneau(foc,aide1)\n$panneau(foc,titre)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::foc::getPluginType ] ] \
               [ ::foc::getPluginDirectory ] [ ::foc::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(foc,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du centrage/pointage
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour acquistion
         label $This.fra2.lab1 -text $panneau(foc,acq) -relief flat
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
            label $This.fra2.fra1.lab1 -text $panneau(foc,secondes) -relief flat
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

         #--- Label pour moteur focus
         label $This.fra4.lab1 -text $panneau(foc,motorfoc) -relief flat
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
         label $This.fra5.lab1 -text $panneau(foc,position) -relief flat
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
         button $This.fra3.but1 -borderwidth 2 -text $panneau(foc,graphe) -command { focGraphe }
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

