#
# Fichier : cmanimate.tcl
# Description : Animation/slides control panel for Cloud Monitor
# Auteur : Sylvain RONDI
# Mise a jour $Id: cmanimate.tcl,v 1.12 2007-10-05 15:34:12 robertdelmas Exp $
#

#****************************************************************
# NAME
#   cmanimate : Animate the FITS images from MASCOT
#
# SYNOPSIS :
#
#
# DESCRIPTION :
#   Permit the user to browse and animate the images from the
#   Mini All Sky Cloud Observation Tool (MASCOT) and to display
#   some information (positions of the UT's)
#
#----------------------------------------------------------------

#============================================================
# Declaration du namespace cmanimate
#    initialise le namespace
#============================================================
namespace eval ::cmanimate {
   package provide cmanimate 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] cmanimate.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(cmanimate,titre)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "cmanimate.htm"
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
      return "cmanimate"
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
         function     { return "utility" }
         subfunction1 { return "animate" }
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
      createPanel $in.cmanimate
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
      global audace
      global caption
      global cmconf
      global numero
      global panneau

      #--- Chargement des variables de configuration de cmaude
      set fichier_cmaude [ file join $audace(rep_plugin) tool cmaude cmaude_ini.tcl ]
      if { [ file exists $fichier_cmaude ] } {
         source $fichier_cmaude
      }
      #--- Chargement des variables de configuration
      set fichier_cmanimate [ file join $audace(rep_plugin) tool cmanimate cmanimate.ini ]
      if { [ file exists $fichier_cmanimate ] } {
         source $fichier_cmanimate
      }
      #--- Initialisation du nom de la fenetre
      set This $this
      #--- Initialisation des captions
      set panneau(cmanimate,titre)           "$caption(cmanimate,titre)"
      set panneau(cmanimate,aide)            "$caption(cmanimate,help_titre)"
      set panneau(cmanimate,genericfilename) "$caption(cmanimate,nom_generique)"
      set panneau(cmanimate,parcourir)       "$caption(cmanimate,parcourir)"
      set panneau(cmanimate,nbimages)        "$caption(cmanimate,nbre_images)"
      set panneau(cmanimate,delayms)         "$caption(cmanimate,delai_ms)"
      set panneau(cmanimate,nbloops)         "$caption(cmanimate,nbre_boucles)"
      set panneau(cmanimate,goall)           "$caption(cmanimate,animation_totale)"
      set panneau(cmanimate,golast)          "$caption(cmanimate,animation_fin)"
      set panneau(cmanimate,lbllast)         "$caption(cmanimate,image)"
      set panneau(cmanimate,gotolast)        "$caption(cmanimate,aller_derniere_image)"
      set panneau(cmanimate,forw)            "$caption(cmanimate,image_suivante)"
      set panneau(cmanimate,backw)           "$caption(cmanimate,image_precedante)"
      set panneau(cmanimate,label_ima)       "$caption(cmanimate,status)"
      set panneau(cmanimate,status)          "$caption(cmanimate,status1)"
      set panneau(cmanimate,goimg)           "$caption(cmanimate,aller_image)"
      #--- Initialisation de variables
      if { [ info exists panneau(cmanimate,filename) ] == "0" } { set panneau(cmanimate,filename) "" }
      if { [ info exists panneau(cmanimate,nbi) ] == "0" }      { set panneau(cmanimate,nbi)      "3" }
      if { [ info exists panneau(cmanimate,ms) ] == "0" }       { set panneau(cmanimate,ms)       "100" }
      if { [ info exists panneau(cmanimate,nbl) ] == "0" }      { set panneau(cmanimate,nbl)      "2" }
      set panneau(cmanimate,nblast)          "10"
      set panneau(cmanimate,numimg)          "1"
      set numero                          "1"
      #--- Construction de l'interface
      cmanimateBuildIF $This
   }

   proc chargementVar { } {
      variable parametres
      global audace

      #--- Ouverture du fichier de parametres
      set fichier [ file join $audace(rep_plugin) tool cmanimate cmanimate.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }
      if { ! [ info exists parametres(cmanimate,position) ]} { set parametres(cmanimate,position) "0" }
   }

   proc enregistrementVar { } {
      variable parametres
      global audace
      global panneau

      set parametres(cmanimate,position) "$panneau(cmanimate,position)"

      #--- Sauvegarde des parametres
      catch {
         set nom_fichier [ file join $audace(rep_plugin) tool cmanimate cmanimate.ini ]
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

   proc adaptOutilcmanimate { { a "" } { b "" } { c "" } } {
      variable This
      global panneau

      if { $panneau(cmanimate,position) == "0" } {
         pack forget $This.frauts.case3
         pack $This.frauts.case2 -in $This.frauts -side bottom -fill none -ipadx 5 -ipady 2 -pady 2 -padx 2
         pack $This.frauts.lab.but1 -anchor center -fill both -side left -expand true
         pack forget $This.frauts.lab.but2
         pack forget $This.frauts.lab.but2.labURL1
         pack forget $This.frauts.lab.but2.labURL2
         pack forget $This.frauts.lab.but2.labURL3
         pack forget $This.frauts.lab.but2.labURL4
         pack forget $This.frauts.lab.but3
      } elseif { $panneau(cmanimate,position) == "1" } {
         pack forget $This.frauts.case2
         pack $This.frauts.case3 -in $This.frauts -side bottom -fill none -ipadx 5 -ipady 2 -pady 2 -padx 2
         pack forget $This.frauts.lab.but1
         pack forget $This.frauts.lab.but2
         pack forget $This.frauts.lab.but2.labURL1
         pack forget $This.frauts.lab.but2.labURL2
         pack forget $This.frauts.lab.but2.labURL3
         pack forget $This.frauts.lab.but2.labURL4
         pack $This.frauts.lab.but3 -anchor center -fill both -side left -expand true
      } elseif { $panneau(cmanimate,position) == "2" } {
         pack forget $This.frauts.case2
         pack $This.frauts.case3 -in $This.frauts -side bottom -fill none -ipadx 5 -ipady 2 -pady 2 -padx 2
         pack forget $This.frauts.lab.but1
         pack $This.frauts.lab.but2 -anchor center -fill both -side left -expand true
         pack $This.frauts.lab.but2.labURL1 -anchor center -fill both -side left -expand true
         pack $This.frauts.lab.but2.labURL2 -anchor center -fill both -side left -expand true
         pack $This.frauts.lab.but2.labURL3 -anchor center -fill both -side left -expand true
         pack $This.frauts.lab.but2.labURL4 -anchor center -fill both -side left -expand true
         pack forget $This.frauts.lab.but3
      }
   }

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable This
      variable parametres
      global caption
      global panneau

      trace add variable ::panneau(cmanimate,position) write ::cmanimate::adaptOutilcmanimate
      ::cmanimate::chargementVar
      set panneau(cmanimate,position) "$parametres(cmanimate,position)"
      pack $This -side left -fill y
      console::affiche_prompt "$caption(cmanimate,en_tete_1)"
      console::affiche_prompt "$caption(cmanimate,en_tete_2)"
      console::affiche_prompt "$caption(cmanimate,en_tete_3)"
      console::affiche_prompt "$caption(cmanimate,en_tete_4)"
      console::affiche_prompt "$caption(cmanimate,en_tete_5)"
      console::affiche_prompt "$caption(cmanimate,en_tete_6)"
      console::affiche_prompt "$caption(cmanimate,en_tete_7)"
      console::affiche_prompt "$caption(cmanimate,en_tete_8)"
      console::affiche_prompt "$caption(cmanimate,en_tete_9)"
      console::affiche_prompt "$caption(cmanimate,en_tete_10)"
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable This
      global audace
      global panneau

      trace remove variable ::panneau(cmanimate,position) write ::cmanimate::adaptOutilcmanimate
      ::cmanimate::enregistrementVar
      pack forget $This
      if { [ winfo exists $audace(base).erreurfichier ] } {
         destroy $audace(base).erreurfichier
      }
      if { [ winfo exists $audace(base).position_tel ] } {
         destroy $audace(base).position_tel
      }
   }

   proc cmdGoall { } {
      variable This
      global audace
      global caption
      global panneau

      #--- Destruction de la fenetre d'erreur si elle existe
      if { [ winfo exists $audace(base).erreurfichier ] } {
         destroy $audace(base).erreurfichier
      }
      #--- Clean the screen
      visu$audace(visuNo) clear
      #--- Lancement de l'animation
      if { $panneau(cmanimate,filename) != "" } {
         #--- Efface la position des telescopes
         $audace(hCanvas) delete uts
         grab $This.frago.but1
         $This.frago.but1 configure -relief groove -state disabled
         set panneau(cmanimate,status) "$caption(cmanimate,animation_en_cours)"
         $This.fra6.labURL2 configure -text "$panneau(cmanimate,status)"
         update
         #--- Animation avec gestion des erreurs (absence d'images, images dans un autre repertoire, etc.)
         #--- supportee par la variable error retournee par la procedure animateMascot du present script
         set error [ animateMascot $panneau(cmanimate,filename) $panneau(cmanimate,nbi) $panneau(cmanimate,ms) \
            $panneau(cmanimate,nbl) ]
         if { $error == "1" } {
            ::cmanimate::erreurFichier
         }
         grab release $This.frago.but1
         $This.frago.but1 configure -relief raised -state normal
         update
         set panneau(cmanimate,status) "$caption(cmanimate,animation_terminee)"
         $This.fra6.labURL2 configure -text "$panneau(cmanimate,status)"
         cmdchkuts_1
      }
   }

   proc animateMascot { filename nb {millisecondes 200} {nbtours 10} } {
      #--- filename : Nom generique des fichiers image filename*.fit a animer
      #--- nb : Nombre d'images (1 a nb)
      #--- millisecondes : Temps entre chaque image affichee
      #--- nbtours : Nombre de boucles sur les nb images
      global audace
      global caption
      global color
      global conf
      global panneau

      #--- Repertoire des images
      set len [string length $conf(rep_images)]
      set folder "$conf(rep_images)"
      if { $len > "0" } {
         set car [string index "$conf(rep_images)" [expr $len-1]]
         if { $car != "/" } {
            append folder "/"
         }
      }
      #--- Je sauvegarde le canvas
      set basecanvas $audace(base).can1.canvas
      #--- Je sauvegarde le numero de l'image associe a la visu
      set imageNo [visu$audace(visuNo) image]
      #--- Initialisation des visu
      set off "100"
      #--- Creation de nb visu a partir de la visu numero 101 (100 + 1) et des Tk_photoimage
      for { set k 1 } { $k <= $nb } { incr k } {
         set kk [expr $k+$off]
         #--- Creation de l'image et association a la visu
         visu$audace(visuNo) image $kk
         #--- Chargement de l'image avec gestion des erreurs
         set error [ catch { buf$audace(bufNo) load "$folder$filename$k" } msg ]
         #--- Positionnement de la zone pointee par le telescope sur l'image
         if { $panneau(cmanimate,drawposuts) == "1" } {
            if { $panneau(cmanimate,position) == "2" } {
            #--- Positionnement pour l'option Paranal avec des images en binning 1x1
               set nom_image [ file join $audace(rep_images) $panneau(cmanimate,filename)$k$conf(extension,defaut) ]
               catch {
                  set altut1($k) [lindex [buf$audace(bufNo) getkwd "ALTUT1"] 1]
                  set aziut1($k) [lindex [buf$audace(bufNo) getkwd "AZUT1"] 1]
                  set altut2($k) [lindex [buf$audace(bufNo) getkwd "ALTUT2"] 1]
                  set aziut2($k) [lindex [buf$audace(bufNo) getkwd "AZUT2"] 1]
                  set altut3($k) [lindex [buf$audace(bufNo) getkwd "ALTUT3"] 1]
                  set aziut3($k) [lindex [buf$audace(bufNo) getkwd "AZUT3"] 1]
                  set altut4($k) [lindex [buf$audace(bufNo) getkwd "ALTUT4"] 1]
                  set aziut4($k) [lindex [buf$audace(bufNo) getkwd "AZUT4"] 1]
               }
            } elseif { $panneau(cmanimate,position) == "1" } {
            #--- Positionnement pour l'option 'Votre instrument' avec des images en binning 1x1
               #--- A developper, recuperation des coordonnees de pointage (lx200, audecom, ouranos, etc.)
            }
         }
         #--- Affichage de l'image associee a la visu
         ::audace::autovisu $audace(visuNo)
      }
      #--- Animation
      if { $error == "0" } {
         for { set t 1 } { $t <= $nbtours } { incr t } {
            for { set k 1 } { $k <= $nb } { incr k } {
               set kk [expr $k+$off]
               #--- Positionnement de la zone pointee par le telescope sur l'image
               if { $panneau(cmanimate,drawposuts) == "1" } {
                  if { $panneau(cmanimate,position) == "2" } {
                  #--- Positionnement pour l'option Paranal avec des images en binning 1x1
                     catch {
                        set altut(1) $altut1($k)
                        set aziut(1) $aziut1($k)
                        set altut(2) $altut2($k)
                        set aziut(2) $aziut2($k)
                        set altut(3) $altut3($k)
                        set aziut(3) $aziut3($k)
                        set altut(4) $altut4($k)
                        set aziut(4) $aziut4($k)
                        altaz2oval $altut(1) $aziut(1) "$caption(cmanimate,ut1)" "$color(red)" "1" "13" "uts"
                        altaz2oval $altut(2) $aziut(2) "$caption(cmanimate,ut2)" "$color(yellow)" "1" "13" "uts"
                        altaz2oval $altut(3) $aziut(3) "$caption(cmanimate,ut3)" "$color(green)" "1" "13" "uts"
                        altaz2oval $altut(4) $aziut(4) "$caption(cmanimate,ut4)" "$color(blue)" "1" "13" "uts"
                     }
                  } elseif { $panneau(cmanimate,position) == "1" } {
                  #--- Positionnement pour l'option 'Votre instrument' avec des images en binning 1x1
                     #--- A developper, recuperation des coordonnees de pointage (lx200, audecom, ouranos, etc.)
                  }
               }
               $basecanvas itemconfigure display -image image$kk
               #--- Chargement de l'image associee a la visu
               visu$audace(visuNo) image $kk
               update
               after $millisecondes
               #--- Effacement des surimpressions
               $audace(hCanvas) delete uts
            }
         }
      }
      #--- Destruction des Tk_photoimage
      for { set k 1 } { $k <= $nb } { incr k } {
         set kk [expr $k+$off]
         image delete image$kk
      }
      #--- Reconfiguration pour Aud'ACE normal
      $basecanvas itemconfigure display -image image$imageNo
      update
      #--- Restauration du numero de l'image associe a la visu
      visu$audace(visuNo) image $imageNo
      #--- Affichage de la premiere image de l'animation si elle existe
      if { $error == "0" } {
         buf$audace(bufNo) load $folder${filename}1
         ::audace::autovisu $audace(visuNo)
      }
      #--- Variable error pour la gestion des erreurs
      return $error
   }

   proc cmdGolast { } {
      variable This
      global audace
      global caption
      global conf
      global numbrend
      global numbrstart
      global panneau

      set numbrend "0"
      set num "1"
      while { $num != "0" } {
         incr numbrend 1
         set nom_image [ file join $audace(rep_images) $panneau(cmanimate,filename)$numbrend$conf(extension,defaut) ]
         set num [ file exists $nom_image ]
      }
      incr numbrend -1
      set numbrstart [expr $numbrend - $panneau(cmanimate,nblast) + 1]
      if { $numbrstart <= "0" } {
         set numbrstart "1"
      }
      if { $numbrend <= "0" } {
         set numbrend "1"
      }
      #--- Destruction de la fenetre d'erreur si elle existe
      if { [ winfo exists $audace(base).erreurfichier ] } {
         destroy $audace(base).erreurfichier
      }
      #--- Clean the screen
      visu$audace(visuNo) clear
      #--- Lancement de l'animation
      if { $panneau(cmanimate,filename) != "" } {
         #--- Efface la position des telescopes
         $audace(hCanvas) delete uts
         grab $This.frago.but5
         $This.frago.but5 configure -relief groove -state disabled
         set panneau(cmanimate,status) "$caption(cmanimate,animation_en_cours)"
         $This.fra6.labURL2 configure -text "$panneau(cmanimate,status)"
         update
         #--- Animation avec gestion des erreurs (absence d'images, images dans un autre repertoire, etc.)
         #--- supportee par la variable error retournee par la procedure animateMascotLast du present script
         set error [ ::cmanimate::animateMascotLast $panneau(cmanimate,filename) $numbrstart $numbrend \
            $panneau(cmanimate,ms) $panneau(cmanimate,nbl) ]
         if { $error == "1" } {
            ::cmanimate::erreurFichier
         }
         grab release $This.frago.but5
         $This.frago.but5 configure -relief raised -state normal
         update
         set panneau(cmanimate,status) "$caption(cmanimate,animation_terminee)"
         $This.fra6.labURL2 configure -text "$panneau(cmanimate,status)"
         cmdchkuts_1
      }
   }

   proc animateMascotLast { filename numbrstart numbrend millisecondes nbtours } {
      #--- filename : Nom generique des fichiers image filename*.fit a animer
      #--- numbrstart : Numero de l'image de debut
      #--- numbrend : Numero de l'image de fin
      #--- millisecondes : Temps entre chaque image affichee
      #--- nbtours : Nombre de boucles sur les nb images
      global audace
      global caption
      global color
      global conf
      global panneau

      #--- Repertoire des images
      set len [string length $conf(rep_images)]
      set folder "$conf(rep_images)"
      if { $len > "0" } {
         set car [string index "$conf(rep_images)" [expr $len-1]]
         if { $car != "/" } {
            append folder "/"
         }
      }
      #--- Je sauvegarde le canvas
      set basecanvas $audace(base).can1.canvas
      #--- Je sauvegarde le numero de l'image associe a la visu
      set imageNo [visu$audace(visuNo) image]
      #--- Initialisation des visu
      set off "100"
      #--- Creation de nb visu a partir de la visu numero 101 (100 + 1) et des Tk_photoimage
      for { set k $numbrstart } { $k <= $numbrend } { incr k } {
         set kk [expr $k+$off]
         #--- Creation de l'image et association a la visu
         visu$audace(visuNo) image $kk
         #--- Chargement de l'image avec gestion des erreurs
         set error [ catch { buf$audace(bufNo) load "$folder$filename$k" } msg ]
         #--- Positionnement de la zone pointee par le telescope sur l'image
         if { $panneau(cmanimate,drawposuts) == "1" } {
            if { $panneau(cmanimate,position) == "2" } {
            #--- Positionnement pour l'option Paranal avec des images en binning 1x1
               set nom_image [ file join $audace(rep_images) $panneau(cmanimate,filename)$k$conf(extension,defaut) ]
               catch {
                  set altut1($k) [lindex [buf$audace(bufNo) getkwd "ALTUT1"] 1]
                  set aziut1($k) [lindex [buf$audace(bufNo) getkwd "AZUT1"] 1]
                  set altut2($k) [lindex [buf$audace(bufNo) getkwd "ALTUT2"] 1]
                  set aziut2($k) [lindex [buf$audace(bufNo) getkwd "AZUT2"] 1]
                  set altut3($k) [lindex [buf$audace(bufNo) getkwd "ALTUT3"] 1]
                  set aziut3($k) [lindex [buf$audace(bufNo) getkwd "AZUT3"] 1]
                  set altut4($k) [lindex [buf$audace(bufNo) getkwd "ALTUT4"] 1]
                  set aziut4($k) [lindex [buf$audace(bufNo) getkwd "AZUT4"] 1]
               }
            } elseif { $panneau(cmanimate,position) == "1" } {
            #--- Positionnement pour l'option 'Votre instrument' avec des images en binning 1x1
               #--- A developper, recuperation des coordonnees de pointage (lx200, audecom, ouranos, etc.)
            }
         }
         #--- Affichage de l'image associee a la visu
         ::audace::autovisu $audace(visuNo)
      }
      #--- Animation
      if { $error == "0" } {
         for { set t 1 } { $t <= $nbtours } { incr t } {
            for { set k $numbrstart } { $k <= $numbrend } { incr k } {
               set kk [expr $k+$off]
               #--- Positionnement de la zone pointee par le telescope sur l'image
               if { $panneau(cmanimate,drawposuts) == "1" } {
                  if { $panneau(cmanimate,position) == "2" } {
                  #--- Positionnement pour l'option Paranal avec des images en binning 1x1
                     catch {
                        set altut(1) $altut1($k)
                        set aziut(1) $aziut1($k)
                        set altut(2) $altut2($k)
                        set aziut(2) $aziut2($k)
                        set altut(3) $altut3($k)
                        set aziut(3) $aziut3($k)
                        set altut(4) $altut4($k)
                        set aziut(4) $aziut4($k)
                        altaz2oval $altut(1) $aziut(1) "$caption(cmanimate,ut1)" "$color(red)" "1" "13" "uts"
                        altaz2oval $altut(2) $aziut(2) "$caption(cmanimate,ut2)" "$color(yellow)" "1" "13" "uts"
                        altaz2oval $altut(3) $aziut(3) "$caption(cmanimate,ut3)" "$color(green)" "1" "13" "uts"
                        altaz2oval $altut(4) $aziut(4) "$caption(cmanimate,ut4)" "$color(blue)" "1" "13" "uts"
                     }
                  } elseif { $panneau(cmanimate,position) == "1" } {
                  #--- Positionnement pour l'option 'Votre instrument' avec des images en binning 1x1
                     #--- A developper, recuperation des coordonnees de pointage (lx200, audecom, ouranos, etc.)
                  }
               }
               $basecanvas itemconfigure display -image image$kk
               #--- Chargement de l'image associee a la visu
               visu$audace(visuNo) image $kk
               update
               after $millisecondes
               #--- Effacement des surimpressions
               $audace(hCanvas) delete uts
            }
         }
      }
      #--- Destruction des Tk_photoimage
      for { set k $numbrstart } { $k <= $numbrend } { incr k } {
         set kk [expr $k+$off]
         image delete image$kk
      }
      #--- Reconfiguration pour Aud'ACE normal
      $basecanvas itemconfigure display -image image$imageNo
      update
      #--- Restauration du numero de l'image associe a la visu
      visu$audace(visuNo) image $imageNo
      #--- Affichage de la premiere image de l'animation si elle existe
      if { $error == "0" } {
         buf$audace(bufNo) load $folder${filename}1
         ::audace::autovisu $audace(visuNo)
      }
      #--- Variable error pour la gestion des erreurs
      return $error
   }

   proc cmdForw { } {
   #--- Push on FORWARD button, pass to the following image
      variable This
      global audace
      global caption
      global conf
      global numero
      global panneau

      #--- Destruction de la fenetre d'erreur si elle existe
      if { [ winfo exists $audace(base).erreurfichier ] } {
         destroy $audace(base).erreurfichier
      }
      #---
      if { $panneau(cmanimate,filename) != "" } {
         incr numero 1
         set nom_image [ file join $audace(rep_images) $panneau(cmanimate,filename)$numero$conf(extension,defaut) ]
         set num [ catch { loadima $nom_image } msg ]
         if { $num == "1" } {
            incr numero -1
            ::cmanimate::erreurFichier
         } else {
            set datefits [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]
            set panneau(cmanimate,status) "$caption(cmanimate,image_numero)$numero - [string range $datefits 0 15]"
            $This.fra6.labURL2 configure -text "$panneau(cmanimate,status)"
            cmdchkuts_1
         }
      }
   }

   proc cmdBackw { } {
   #--- Push on BACKWARD button, pass to the previous image
      variable This
      global audace
      global caption
      global conf
      global numero
      global panneau

      #--- Destruction de la fenetre d'erreur si elle existe
      if { [ winfo exists $audace(base).erreurfichier ] } {
         destroy $audace(base).erreurfichier
      }
      #---
      if { $panneau(cmanimate,filename) != "" } {
         incr numero -1
         if { $numero < "1" } {
            set numero "1"
            ::cmanimate::erreurFichier
         }
         set nom_image [ file join $audace(rep_images) $panneau(cmanimate,filename)$numero$conf(extension,defaut) ]
         set num [ catch { loadima $nom_image } msg ]
         if { $num == "1" } then {
            incr numero 1
            ::cmanimate::erreurFichier
         } else {
            set datefits [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]
            set panneau(cmanimate,status) "$caption(cmanimate,image_numero)$numero - [string range $datefits 0 15]"
            $This.fra6.labURL2 configure -text "$panneau(cmanimate,status)"
            cmdchkuts_1
         }
      }
   }

   proc cmdGotolast { } {
   #--- Push on Go To Last button, pass to the last image available
      variable This
      global audace
      global caption
      global conf
      global numero
      global panneau

      #--- Destruction de la fenetre d'erreur si elle existe
      if { [ winfo exists $audace(base).erreurfichier ] } {
         destroy $audace(base).erreurfichier
      }
      #---
      if { $panneau(cmanimate,filename) != "" } {
         set numero "1"
         set num "1"
         while { $num != "0" } {
            incr numero 1
            set nom_image [ file join $audace(rep_images) $panneau(cmanimate,filename)$numero$conf(extension,defaut) ]
            set num [ file exists $nom_image ]
         }
         incr numero -1
         set nom_image [ file join $audace(rep_images) $panneau(cmanimate,filename)$numero$conf(extension,defaut) ]
         set num [catch {loadima $nom_image} msg]
         if { $num == "1" } then {
            ::cmanimate::erreurFichier
         } else {
            set datefits [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]
            set panneau(cmanimate,status) "$caption(cmanimate,image_numero)$numero - [string range $datefits 0 15]"
            $This.fra6.labURL2 configure -text "$panneau(cmanimate,status)"
            cmdchkuts_1
         }
      }
   }

   proc cmdGoto { } {
   #--- Push on Go To button, pass to the image number "numero"
      variable This
      global audace
      global caption
      global conf
      global numero
      global panneau

      #--- Destruction de la fenetre d'erreur si elle existe
      if { [ winfo exists $audace(base).erreurfichier ] } {
         destroy $audace(base).erreurfichier
      }
      #---
      if { $panneau(cmanimate,filename) != "" } {
         set numero "$panneau(cmanimate,numimg)"
         set nom_image [ file join $audace(rep_images) $panneau(cmanimate,filename)$numero$conf(extension,defaut) ]
         set num [catch {loadima $nom_image} msg]
         if { $num == "1" } then {
            ::cmanimate::erreurFichier
            set numero "1"
         } else {
            set datefits [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]
            set panneau(cmanimate,status) "$caption(cmanimate,image_numero)$numero - [string range $datefits 0 15]"
            $This.fra6.labURL2 configure -text "$panneau(cmanimate,status)"
            cmdchkuts_1
         }
      }
   }

   proc cmdchkgrid { } {
      global audace
      global caption
      global panneau

      if { $panneau(cmanimate,drawgrid) == "1" } then {
         console::affiche_erreur "$caption(cmanimate,dessine_grille)"
         cmdGrid
      } else {
         console::affiche_erreur "$caption(cmanimate,efface_grille)"
         $audace(hCanvas) delete thegrid
      }
   }

   proc cmdGrid { } {
      global audace
      global caption
      global cmconf
      global color
      global panneau

      if { $panneau(cmanimate,position) == "2" } {
      #--- Grille pour l'option Paranal avec des images en binning 1x1
         #--- Draw an AltAz grid over the image
         set centerx [lindex $cmconf(zenith11) 0]
         set centery [lindex $cmconf(zenith11) 1]
         foreach anglegrid { 0. 15. 30. 50. 70. } {
            #--- The radius of the image is 275 pixels
            set centeroff [expr 285.0 - ($anglegrid / 90.0 * 285.0)]
            set x1 [expr $centerx-$centeroff]
            set y1 [expr $centery-$centeroff]
            set x2 [expr $centerx+$centeroff]
            set y2 [expr $centery+$centeroff]
            set offsetxtxt [expr $x1+15.0]
            set offsetytxt [expr $centery-5.0]
            $audace(hCanvas) create oval $x1 $y1 $x2 $y2 -outline $color(violet) -tags thegrid
            $audace(hCanvas) create text $offsetxtxt $offsetytxt -text "$anglegrid$caption(cmanimate,degres)" \
               -fill $color(violet) -tags thegrid
         }
         set x1 [expr $centerx-295.0]
         set y1 [expr $centery-295.0]
         set x2 [expr $centerx+295.0]
         set y2 [expr $centery+285.0]
         $audace(hCanvas) create line $x1 $centery $x2 $centery -fill $color(violet) -tags thegrid
         $audace(hCanvas) create line $centerx $y1 $centerx $y2 -fill $color(violet) -tags thegrid
         for { set anglegrid2 20 } { $anglegrid2 < 361 } { incr anglegrid2 20 } {
            altaz2oval "20" $anglegrid2 $anglegrid2 "$color(violet)" "1" "0" "thegrid"
            altaz2oval "15" $anglegrid2 "" "$color(violet)" "1" "2" "thegrid"
         }
      } else {
      #--- Grille pour les 2 autres options avec des images en binning 1x1
         #--- A developper pour le cas specifique, car depend du champ et de l'orientation de la camera
      }
   }

   proc altaz2oval { altut aziut utID color_cmanimate width radius tag } {
      global audace
      global caption
      global cmconf

      set centerx [lindex $cmconf(zenith11) 0]
      set centery [lindex $cmconf(zenith11) 1]
      #--- Convert the {altitude azimuth} position into the {x1 y1 x2 y2} oval coordinates
      #--- This is the radius from the center given by the altitude
      set altdeci [expr 285.0 - ($altut / 90.0 * 285.0)]
      #--- This is X and Y
      set xpos [expr $centerx + ($altdeci * sin ($aziut / 180. * 3.1415))]
      set ypos [expr $centery - ($altdeci * cos ($aziut / 180. * 3.1415))]
      set x1 [expr $xpos - $radius]
      set y1 [expr $ypos - $radius]
      set x2 [expr $xpos + $radius]
      set y2 [expr $ypos + $radius]
      $audace(hCanvas) create oval $x1 $y1 $x2 $y2 -outline $color_cmanimate -width $width -tags $tag
      $audace(hCanvas) create text $xpos $ypos -text "$utID$caption(cmanimate,degres)" -fill $color_cmanimate -tags $tag
   }

   proc cmdchkuts { } {
      global audace
      global caption
      global panneau

      if { $panneau(cmanimate,drawposuts) == "1" } then {
         $audace(hCanvas) delete uts
         if { $panneau(cmanimate,position) == "1" } {
            console::affiche_erreur "$caption(cmanimate,dessine_position)"
         } else {
            console::affiche_erreur "$caption(cmanimate,dessine_positions)"
         }
         catch { cmdDrawuts }
      } else {
         if { $panneau(cmanimate,position) == "1" } {
            console::affiche_erreur "$caption(cmanimate,efface_position)"
         } else {
            console::affiche_erreur "$caption(cmanimate,efface_positions)"
         }
         $audace(hCanvas) delete uts
      }
   }

   proc cmdchkuts_1 { } {
      global audace
      global panneau

      if { $panneau(cmanimate,drawposuts) == "1" } then {
         $audace(hCanvas) delete uts
         catch { cmdDrawuts }
      } else {
         $audace(hCanvas) delete uts
      }
   }

   proc cmdDrawuts { } {
   #--- Draw the position of the UT's on the image
      global audace
      global caption
      global color
      global panneau

      if { $panneau(cmanimate,position) == "2" } {
      #--- Positionnement pour l'option Paranal avec des images en binning 1x1
         #--- Prepare the datas
         #--- Erase the previous overlay
         #--- Put the position from the header into local variables (optionnal?)
         set altut1 [lindex [buf$audace(bufNo) getkwd "ALTUT1"] 1]
         set aziut1 [lindex [buf$audace(bufNo) getkwd "AZUT1"] 1]
         set altut2 [lindex [buf$audace(bufNo) getkwd "ALTUT2"] 1]
         set aziut2 [lindex [buf$audace(bufNo) getkwd "AZUT2"] 1]
         set altut3 [lindex [buf$audace(bufNo) getkwd "ALTUT3"] 1]
         set aziut3 [lindex [buf$audace(bufNo) getkwd "AZUT3"] 1]
         set altut4 [lindex [buf$audace(bufNo) getkwd "ALTUT4"] 1]
         set aziut4 [lindex [buf$audace(bufNo) getkwd "AZUT4"] 1]
         #--- Put the wind parameters
         set aziwind "340"
         set forcewind "5"
         #--- Draw the circles on the canvas
         #--- Options : alti, azim, name, color, thickness, radius
         altaz2oval $altut1 $aziut1 "$caption(cmanimate,ut1)" "$color(red)" "1" "13" "uts"
         altaz2oval $altut2 $aziut2 "$caption(cmanimate,ut2)" "$color(yellow)" "1" "13" "uts"
         altaz2oval $altut3 $aziut3 "$caption(cmanimate,ut3)" "$color(green)" "1" "13" "uts"
         altaz2oval $altut4 $aziut4 "$caption(cmanimate,ut4)" "$color(blue)" "1" "13" "uts"
         drawwind $aziwind $forcewind
      } elseif { $panneau(cmanimate,position) == "1" } {
      #--- Positionnement pour l'option 'Votre instrument' avec des images en binning 1x1
         #--- A developper, recuperation des coordonnees de pointage (lx200, audecom, ouranos, etc.)
      }
   }

   proc drawwind { aziwind forcewind } {
      global audace
      global caption
      global color

      #--- Convert the {altitude azimuth} position into the {x1 y1 x2 y2} oval coordinates
      #--- This is the radius from the center given by the altitude
      #--- This is X and Y
      set xpos [expr ($forcewind * sin ($aziwind / 180. * 3.1415))]
      set ypos [expr ($forcewind * -1. * cos ($aziwind / 180. * 3.1415))]
      set x1 "545"
      set y1 "60"
      set x2 [expr 545. + $xpos]
      set y2 [expr 60. + $ypos]
      #--- 14m/s speed (pointing limit)
      $audace(hCanvas) create oval 536 51 564 79 -outline $color(cyan) -width 1 -tags uts
      #--- 18m/s speed (close dome)
      $audace(hCanvas) create oval 532 47 568 83 -outline $color(cyan) -width 1 -tags uts
      #--- 25m/s speed
      $audace(hCanvas) create oval 525 40 575 90 -outline $color(cyan) -width 1 -tags uts
      $audace(hCanvas) create line $x1 $y1 $x2 $y2 -fill $color(cyan) -width 1 -tags uts
      $audace(hCanvas) create text 515 45 -text "$caption(cmanimate,vent)" -fill $color(cyan) -tags uts
   }

   proc erreurFichier { } {
   #--- Notice the user of a wrong folder or file
      global audace
      global caption

      if { [ winfo exists $audace(base).erreurfichier ] } {
         destroy $audace(base).erreurfichier
      }
      toplevel $audace(base).erreurfichier
      wm transient $audace(base).erreurfichier $audace(base)
      wm title $audace(base).erreurfichier "$caption(cmanimate,attention)"
      set posx_erreurfichier [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_erreurfichier [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $audace(base).erreurfichier +[ expr $posx_erreurfichier + 170 ]+[ expr $posy_erreurfichier + 102 ]
      wm resizable $audace(base).erreurfichier 0 0
      #--- Create the message
      label $audace(base).erreurfichier.lab1 -text "$caption(cmanimate,erreur1)"
      pack $audace(base).erreurfichier.lab1 -padx 10 -pady 2
      label $audace(base).erreurfichier.lab2 -text "$caption(cmanimate,erreur2)"
      pack $audace(base).erreurfichier.lab2 -padx 10 -pady 2
      label $audace(base).erreurfichier.lab3 -text "$caption(cmanimate,erreur3)"
      pack $audace(base).erreurfichier.lab3 -padx 10 -pady 2
      #--- New message window is on
      focus $audace(base).erreurfichier
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).erreurfichier
   }

   proc positionTel { } {
   #--- Notice the user of a wrong folder or file
      global audace
      global caption
      global panneau

      if { [ winfo exists $audace(base).position_tel ] } {
         destroy $audace(base).position_tel
      }
      toplevel $audace(base).position_tel
      wm transient $audace(base).position_tel $audace(base)
      wm title $audace(base).position_tel "$caption(cmanimate,position_tel)"
      set posx_position_tel [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_position_tel [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $audace(base).position_tel 280x90+[ expr $posx_position_tel + 170 ]+[ expr $posy_position_tel + 102 ]
      wm resizable $audace(base).position_tel 0 0
      #--- Create the message
      radiobutton $audace(base).position_tel.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(cmanimate,non)" -value 0 -variable panneau(cmanimate,position) -command {  }
      pack $audace(base).position_tel.rad1 -padx 10 -pady 5
      radiobutton $audace(base).position_tel.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(cmanimate,oui)" -value 1 -variable panneau(cmanimate,position) -command {  }
      pack $audace(base).position_tel.rad2 -padx 10 -pady 5
      radiobutton $audace(base).position_tel.rad3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(cmanimate,paranal)" -value 2 -variable panneau(cmanimate,position) -command {  }
      pack $audace(base).position_tel.rad3 -padx 10 -pady 5
      #--- New message window is on
      focus $audace(base).position_tel
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).position_tel
   }

   proc editNomGenerique { } {
      global audace
      global panneau

      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- Extraction du nom generique
      set filenameAnimation        [ ::pretraitement::afficherNomGenerique [ file tail $filename ] ]
      set panneau(cmanimate,filename) [ lindex $filenameAnimation 0 ]
      set panneau(cmanimate,nbi)      [ lindex $filenameAnimation 1 ]
   }

#--- End of the procedures
}

#------------------------------------------------------------
# cmanimateBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc cmanimateBuildIF { This } {
   global audace
   global caption
   global color
   global panneau

   #--- Frame de l'outil
   frame $This -borderwidth 2 -relief groove

      #--- Title frame
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label for title
         Button $This.fra1.but -borderwidth 1 -text $panneau(cmanimate,titre) \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::cmanimate::getPluginType ] ] \
               [ ::cmanimate::getPluginDirectory ] [ ::cmanimate::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(cmanimate,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame for generic name
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label for generic name
         label  $This.fra2.lab1 -text "$panneau(cmanimate,genericfilename)" -relief flat
         pack   $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 2

         #--- Entry for generic name
         entry  $This.fra2.ent1 -font $audace(font,arial_8_b) -textvariable panneau(cmanimate,filename) -relief groove
         pack   $This.fra2.ent1 -in $This.fra2 -anchor center -fill none -padx 2 -pady 4 -side left

         #--- Bouton parcourir
         button $This.fra2.but1 -borderwidth 2 -text "$panneau(cmanimate,parcourir)" \
            -command { ::cmanimate::editNomGenerique }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -padx 2 -pady 4 -ipady 3 -side left

      pack $This.fra2 -side top -fill x

      #--- Frame for the number of images
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Label for the number of images
         label  $This.fra3.lab1 -text "$panneau(cmanimate,nbimages)" -relief flat
         pack   $This.fra3.lab1 -in $This.fra3 -anchor center -expand true -fill none -side left

         #--- Entry for the number of images
         entry  $This.fra3.ent1 -font $audace(font,arial_8_b) -textvariable panneau(cmanimate,nbi) -relief groove \
            -width 4 -justify center
         pack   $This.fra3.ent1 -in $This.fra3 -anchor center -expand true -fill none -side left -pady 4

      pack $This.fra3 -side top -fill x

      #--- Frame for the delay
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Label for the delay
         label  $This.fra4.lab1 -text "$panneau(cmanimate,delayms)" -relief flat
         pack   $This.fra4.lab1 -in $This.fra4 -anchor center -expand true -fill none -side left

         #--- Entry for the delay
         entry  $This.fra4.ent1 -font $audace(font,arial_8_b) -textvariable panneau(cmanimate,ms) -relief groove \
            -width 5 -justify center
         pack   $This.fra4.ent1 -in $This.fra4 -anchor center -expand true -fill none -side left -pady 4

      pack $This.fra4 -side top -fill x

      #--- Frame for the number of loops
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Label for the number of loops
         label  $This.fra5.lab1 -text "$panneau(cmanimate,nbloops)" -relief flat
         pack   $This.fra5.lab1 -in $This.fra5 -anchor center -expand true -fill none -side left

         #--- Entry pour le nb de boucles
         entry  $This.fra5.ent1 -font $audace(font,arial_8_b) -textvariable panneau(cmanimate,nbl) -relief groove \
            -width 2 -justify center
         pack   $This.fra5.ent1 -in $This.fra5 -anchor center -expand true -fill none -side left -pady 4

      pack $This.fra5 -side top -fill x

      #--- Frame of commands
      frame $This.frago -borderwidth 1 -relief groove

         #--- Bouton GO animate all
         button  $This.frago.but1 -borderwidth 2 -text "$panneau(cmanimate,goall)" \
            -command { ::cmanimate::cmdGoall }
         pack   $This.frago.but1 -in $This.frago -side top -fill none -padx 2 -pady 8 -ipadx 5 -ipady 8

         #--- Bouton GO animate last X images
         button  $This.frago.but5 -borderwidth 2 -text "$panneau(cmanimate,golast)" \
            -command { ::cmanimate::cmdGolast }
         pack   $This.frago.but5 -in $This.frago -side left -expand true -pady 8 -ipadx 3 -ipady 3

         #--- Entry for the number of last images
         entry  $This.frago.ent2 -font $audace(font,arial_8_b) -textvariable panneau(cmanimate,nblast) -relief groove \
            -width 3 -justify center
         pack   $This.frago.ent2 -in $This.frago -side left -expand true

         #--- Label for the number of last images
         label  $This.frago.lab1 -text "$panneau(cmanimate,lbllast)" -relief flat
         pack   $This.frago.lab1 -in $This.frago -side left -expand true

      pack $This.frago -side top -fill x

      #--- Frame of image browser
      frame $This.frabrowse -borderwidth 1 -relief groove

         #--- Bouton Forward
         button $This.frabrowse.but2 -borderwidth 2 -text "$panneau(cmanimate,forw)" \
            -command { ::cmanimate::cmdForw }
         pack   $This.frabrowse.but2 -in $This.frabrowse -anchor center -fill none -padx 4 -pady 8 -ipadx 3 -ipady 3

         #--- Bouton Backward
         button $This.frabrowse.but3 -borderwidth 2 -text "$panneau(cmanimate,backw)" \
            -command { ::cmanimate::cmdBackw }
         pack   $This.frabrowse.but3 -in $This.frabrowse -anchor center -fill none -padx 4 -pady 8 -ipadx 3 -ipady 3

         #--- Button go to last image
         button $This.frabrowse.but5 -borderwidth 2 -text "$panneau(cmanimate,gotolast)" \
            -command { ::cmanimate::cmdGotolast }
         pack   $This.frabrowse.but5 -in $This.frabrowse -anchor center -fill none -padx 4 -pady 8 -ipadx 3 -ipady 3

         #--- Bouton Go To image
         button $This.frabrowse.but4 -borderwidth 2 -text "$panneau(cmanimate,goimg)" \
            -command { ::cmanimate::cmdGoto }
         pack   $This.frabrowse.but4 -in $This.frabrowse -side left -expand true -pady 8 -ipadx 3 -ipady 3

         #--- Entry for the Go To image number
         entry  $This.frabrowse.ent1 -font $audace(font,arial_8_b) -textvariable panneau(cmanimate,numimg) -relief groove \
            -width 4 -justify center
         pack   $This.frabrowse.ent1 -in $This.frabrowse -side left -expand true

      pack $This.frabrowse -side top -fill x

      #--- Frame of UT's overlay
      frame $This.frauts -borderwidth 1 -relief groove

         #--- Checkcase for coordinate grid overlay
         checkbutton $This.frauts.case1 -pady 0 -text "$caption(cmanimate,grille_sur_image)" \
            -variable panneau(cmanimate,drawgrid) -command { ::cmanimate::cmdchkgrid }
         pack   $This.frauts.case1 -in $This.frauts -side top -fill none -padx 2 -pady 2 -ipadx 5 -ipady 2

         #--- Checkcase for position of the UT's
         checkbutton $This.frauts.case2 -pady 0 -text "$caption(cmanimate,telescope_sur_image)" \
            -state disabled
         pack   $This.frauts.case2 -in $This.frauts -side bottom -fill none -padx 2 -pady 2 -ipadx 5 -ipady 2

         #--- Checkcase for position of the UT's
         checkbutton $This.frauts.case3 -pady 0 -text "$caption(cmanimate,telescope_sur_image)" \
            -variable panneau(cmanimate,drawposuts) -command { ::cmanimate::cmdchkuts }
         pack   $This.frauts.case3 -in $This.frauts -side bottom -fill none -padx 2 -pady 2 -ipadx 5 -ipady 2

         #--- Labels color of the UT's
         frame $This.frauts.lab -borderwidth 0 -height 100 -relief groove
            button $This.frauts.lab.but1 -borderwidth 2 -text "$caption(cmanimate,pas_instrument)" \
               -font $audace(font,arial_10_b) -command { ::cmanimate::positionTel }
            pack $This.frauts.lab.but1 -in $This.frauts.lab -anchor center -fill both -side left -expand true
            button $This.frauts.lab.but2 -borderwidth 2 -font $audace(font,arial_10_b) -state disabled
            pack $This.frauts.lab.but2 -in $This.frauts.lab -anchor center -fill both -side left -expand true
            label $This.frauts.lab.but2.labURL1 -borderwidth 2 -text "$caption(cmanimate,ut1)" \
               -font $audace(font,arial_10_b) -fg $color(red)
            pack $This.frauts.lab.but2.labURL1 -in $This.frauts.lab.but2 -anchor center -fill both -side left -expand true
            label $This.frauts.lab.but2.labURL2 -borderwidth 2 -text "$caption(cmanimate,ut2)" \
               -font $audace(font,arial_10_b) -fg $color(yellow)
            pack $This.frauts.lab.but2.labURL2 -in $This.frauts.lab.but2 -anchor center -fill both -side left -expand true
            label $This.frauts.lab.but2.labURL3 -borderwidth 2 -text "$caption(cmanimate,ut3)" \
               -font $audace(font,arial_10_b) -fg $color(green)
            pack $This.frauts.lab.but2.labURL3 -in $This.frauts.lab.but2 -anchor center -fill both -side left -expand true
            label $This.frauts.lab.but2.labURL4 -borderwidth 2 -text "$caption(cmanimate,ut4)" \
               -font $audace(font,arial_10_b) -fg $color(blue)
            pack $This.frauts.lab.but2.labURL4 -in $This.frauts.lab.but2 -anchor center -fill both -side left -expand true
            button $This.frauts.lab.but3 -borderwidth 2 -text "$caption(cmanimate,instrument)" \
               -font $audace(font,arial_10_b) -command { ::cmanimate::positionTel }
            pack $This.frauts.lab.but3 -in $This.frauts.lab -anchor center -fill both -side left -expand true
         pack   $This.frauts.lab -in $This.frauts -side top -fill none -padx 2 -pady 2 -ipadx 4 -ipady 2

      pack $This.frauts -side top -fill x

      #--- Frame for image infos
      frame $This.fra6 -borderwidth 2 -relief groove

         #--- Label for title
         label $This.fra6.lab1 -borderwidth 1 -text "$panneau(cmanimate,label_ima)" -font $audace(font,arial_10_b)
         pack $This.fra6.lab1 -in $This.fra6 -anchor center -expand 1 -fill both -side top

         #--- Label for images name
         label  $This.fra6.labURL2 -text "$panneau(cmanimate,status)" -font $audace(font,arial_7_b) -fg $color(red) -relief flat
         pack   $This.fra6.labURL2 -in $This.fra6 -anchor center -expand 1 -fill both -padx 4 -pady 1

      pack $This.fra6 -side top -fill x

      #--- Binding pour afficher le nom generique des images et le positionnement des instruments
      catch {
         bind $This.frauts.lab.but2.labURL1 <ButtonPress-1> { ::cmanimate::positionTel }
         bind $This.frauts.lab.but2.labURL2 <ButtonPress-1> { ::cmanimate::positionTel }
         bind $This.frauts.lab.but2.labURL3 <ButtonPress-1> { ::cmanimate::positionTel }
         bind $This.frauts.lab.but2.labURL4 <ButtonPress-1> { ::cmanimate::positionTel }
      }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

#=== End of file cmanimate.tcl ===

