#
# Fichier : cmaude.tcl
# Description : Prototype for the Cloud Monitor panel
# Auteur : Sylvain RONDI
# Mise a jour $Id: cmaude.tcl,v 1.16 2008-05-25 15:54:33 robertdelmas Exp $
#
# Remarks :
# The definition of some variables (binning, exp. time, rythm, etc.)
# is available in file cmaude_ini.tcl to be easily modified
#

#============================================================
#===   Definition of namespace cmaude to create a panel   ===
#============================================================
namespace eval ::cmaude {
   package provide cmaude 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] cmaude.cap ]

   #================================================================
   #===   Definition of automatic functions to build the panel   ===
   #================================================================

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(cmaude,titre_mascot)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "cmaude.htm"
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
      return "cmaude"
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
      createPanel $in.cmaude
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
      variable cmconf
      global audace caption compteur conf panneau

      #--- Initialisation de l'heure TU ou TL
      set now now
      catch {
         set now [::audace::date_sys2ut now]
      }
      #--- Chargement des variables de configuration
      set fichier_cmaude [ file join $audace(rep_plugin) tool cmaude cmaude_ini.tcl ]
      if { [ file exists $fichier_cmaude ] } {
         source $fichier_cmaude
      }
      #--- Recuperation du repertoire dedie aux images et de l'extension des images
      set cmconf(folder)    "$conf(rep_images)"
      set cmconf(extension) "$conf(extension,defaut)"
      set This $this
      #--- Initialisation du compteur des images
      set compteur "1"
      #--- Initialisation des variables panneau
      set panneau(cmaude,titre)           "$caption(cmaude,titre_mascot)"
      set panneau(cmaude,aide)            "$caption(cmaude,help_titre)"
      set panneau(cmaude,config)          "$caption(cmaude,configuration)"
      set panneau(cmaude,parcourir)       "$caption(cmaude,parcourir)"
      set panneau(cmaude,label_bias)      "$caption(cmaude,bias)"
      set panneau(cmaude,bias)            "C:/images/bias/off_synth$cmconf(extension)"
      set panneau(cmaude,label_dark)      "$caption(cmaude,dark)"
      set panneau(cmaude,dark)            "C:/images/dark/dark_synth$cmconf(extension)"
      set panneau(cmaude,label_overlay)   "$caption(cmaude,overlay)"
      set panneau(cmaude,overlay)         "C:/images/overlay/overlay$cmconf(extension)"
      set panneau(cmaude,label_nom)       "$caption(cmaude,nom_image)"
      set panneau(cmaude,nom)             "$cmconf(folder)/[string range [mc_date2jd $now] 0 6]-"
      set panneau(cmaude,label_page_html) "$caption(cmaude,page_html)"
      set panneau(cmaude,page_html)       "0"
      set panneau(cmaude,label_binning)   "$caption(cmaude,binning)"
      set panneau(cmaude,binning)         "$cmconf(binning)"
      set panneau(cmaude,list_binning)    "1x1 2x2"
      set panneau(cmaude,label_time)      "$caption(cmaude,temps_pose)"
      set panneau(cmaude,time)            "$cmconf(exptime1)"
      set panneau(cmaude,label_rythm)     "$caption(cmaude,entre_2_images)"
      set panneau(cmaude,rythm)           "$cmconf(rythm)"
      set panneau(cmaude,go)              "$caption(cmaude,go_acquisition)"
      set panneau(cmaude,stop)            "$caption(cmaude,stop)"
      set panneau(cmaude,ephem)           "$caption(cmaude,ephemerides)"
      set panneau(cmaude,label_status)    "$caption(cmaude,status)"
      set panneau(cmaude,status)          "$caption(cmaude,status1)"
      set panneau(cmaude,status2)         "$caption(cmaude,status2)"
      set panneau(cmaude,status3)         "$caption(cmaude,status2)"
      cmaudeBuildIF $This
   }

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable This
      global caption

      pack $This -side left -fill y
      ::console::affiche_prompt "----------------------------\n"
      ::console::affiche_prompt "| $caption(cmaude,titre_mascot)\n"
      ::console::affiche_prompt "----------------------------\n"
      ::console::affiche_prompt "| Mini\n"
      ::console::affiche_prompt "| All\n"
      ::console::affiche_prompt "| Sky\n"
      ::console::affiche_prompt "| Cloud\n"
      ::console::affiche_prompt "| Observation\n"
      ::console::affiche_prompt "| Tool\n"
      ::console::affiche_prompt "----------------------------\n\n"
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable This

      pack forget $This
   }

   #=======================================================
   #===   Definition of fonctions to run in the panel   ===
   #=======================================================

   #============================
   #=== Command of button GO ===

   proc cmdGo { } {
   #--- Function called by pushing button GO
      variable This
      variable cmconf
      global audace caption compteur loopexit namelog panneau

      if { [ ::cam::list ] != "" } {
         $This.fra2.but1 configure -relief groove -state disabled
         update
         #--- Initialisation de l'heure TU ou TL
         set now now
         catch {
            set now [::audace::date_sys2ut now]
         }
         set loopexit "0"
         ::console::affiche_erreur "###############################\n"
         ::console::affiche_erreur "$caption(cmaude,debut_script)\n"
         set namelog [string range [mc_date2jd $now] 0 6]

         #--- Recuperation de la position de l'observateur
         set cmconf(localite) "$audace(posobs,observateur,gps)"
         set localite "$cmconf(localite)"

         #--- Altitude of the sun under horizon for which one considers it's night
         set haurore "$cmconf(haurore)"

         #--- Some astronomical parameters
         set ladate [mc_date2jd $now]

         set datheur [mc_date2ymdhms $ladate]
         set hautsol [lindex [mc_ephem sun [list [mc_date2tt $ladate]] {altitude} -topo $localite] 0]
         set azimsol [lindex [mc_ephem sun [list [mc_date2tt $ladate]] {azimuth} -topo $localite] 0]
         ::console::affiche_erreur "###############################\n"
         ::console::affiche_erreur "$caption(cmaude,il_est) $datheur $caption(cmaude,TU)\n"
         ::console::affiche_erreur "$caption(cmaude,jour_julien) $ladate\n"
         ::console::affiche_erreur "$caption(cmaude,position_soleil)\n"
         ::console::affiche_erreur "$caption(cmaude,hauteur) [string range $hautsol 0 5]°\n"
         ::console::affiche_erreur "$caption(cmaude,azimut) [string range $azimsol 0 5]°\n"
         set phaslun [lindex [mc_ephem moon [list [mc_date2tt $ladate]] {phase} -topo $localite] 0]
         set cmconf(phaslun) $phaslun
         ::console::affiche_erreur "$caption(cmaude,phase_lune) [string range $phaslun 0 5]°\n"
         set illufrac [expr 100 * (0.5 + 0.5 * cos ($phaslun / 180. * 3.1415))]
         set cmconf(illufrac) $illufrac
         ::console::affiche_erreur "$caption(cmaude,illumine_lune) ~[expr int($illufrac)]%\n"

         #--- Infinite loop running the automatic acquisition sequence (simulated)
         #--- Begins by calculating the parameters of sunset and sunrise for the current day
         #--- This loop ends by pushing STOP (change "loopexit" value to 1)

         while { 1 == 1 } {
            if { $loopexit == "1" } {
               break
            }
            set panneau(cmaude,status) "$caption(cmaude,execution_auto)"
            $This.fra3.lab2 configure -text "$panneau(cmaude,status)"

            #--- Calculate 'jd_deb', le julian day corresponding to the beginning
            #--- of the night (sun altitude equals "haurore")

            set date1 [mc_date2ymdhms [mc_date2jd $now]]
            if { [lindex $date1 3] < "6" } {
               set date1 [mc_date2ymdhms [mc_date2jd now0]]
            } else {
               set date1 [mc_date2ymdhms [mc_date2jd now1]]
            }
            set amj "[lindex $date1 0] [lindex $date1 1] [lindex $date1 2]"
            set jd_deb [mc_date2jd $amj ]
            for { set jj [expr $jd_deb-0.5] } { $jj < [expr $jd_deb] } { set jj [expr $jj+0.001] } {
               set hauteur [lindex [mc_ephem sun [list [mc_date2tt $jj]] {altitude} -topo $localite] 0]
               set result "[mc_date2ymdhms $jj] => h= $hauteur degres "
               if { $hauteur < $haurore } {
                  break
               }
            }
            set jd_deb "$jj"
            set resultb "$caption(cmaude,debut_nuit) [mc_date2iso8601 $jd_deb] $caption(cmaude,TU)\n"
            set cmconf(resultb) $resultb
            ::console::affiche_erreur "$caption(cmaude,hauteur_soleil_debut_nuit) < $cmconf(haurore)°\n"
            ::console::affiche_erreur "$resultb"
            ::console::affiche_erreur "$caption(cmaude,jour_julien) = $jd_deb\n"

            #--- Calculate 'jd_fin', the julian day corresponding to the end
            #--- of the night (sun altitude equals "haurore")

            set date1 [mc_date2ymdhms [mc_date2jd $now]]
            if { [lindex $date1 3] < "6" } {
               set date1 [mc_date2ymdhms [mc_date2jd now0]]
            } else {
               set date1 [mc_date2ymdhms [mc_date2jd now1]]
            }
            set amj "[lindex $date1 0] [lindex $date1 1] [lindex $date1 2]"
            set jd_fin [mc_date2jd $amj ]
            for { set jj $jd_fin } { $jj < [expr $jd_fin+0.5] } { set jj [expr $jj+0.001] } {
               set hauteur [lindex [mc_ephem sun [list [mc_date2tt $jj]] {altitude} -topo $localite] 0]
               if { $hauteur > $haurore } {
                   break
               }
            }
            set jd0 "$jd_fin"
            set jd_fin "$jj"
            set resulte "$caption(cmaude,fin_nuit) [mc_date2iso8601 $jd_fin] $caption(cmaude,TU)\n"
            set cmconf(resulte) $resulte
            ::console::affiche_erreur "$resulte"
            ::console::affiche_erreur "$caption(cmaude,jour_julien) = $jd_fin\n"
            ::console::affiche_erreur "###############################\n\n"

            #--- Waiting for the night
            set actuel [mc_date2jd $now]

            while { [mc_date2jd $now] <= $jd_deb } {
            #--- Test to exit the loop if push on STOP
               if { $loopexit == "1" } {
                  break
               }
               #--- Bouclage sur l'heure systeme
               set now now
               catch {
                  set now [::audace::date_sys2ut now]
               }
               update
               set actuel [mc_date2jd $now]
               ::console::affiche_erreur "$caption(cmaude,il_est_maintenant) [string range [mc_date2iso8601 $actuel] 11 20] $caption(cmaude,TU)\n"
               ::console::affiche_erreur "$caption(cmaude,attendre_nuit_a) [string range [mc_date2iso8601 $jd_deb] 11 20] $caption(cmaude,TU)\n"
               ::console::affiche_erreur "$caption(cmaude,decompte) ### [string range [mc_date2iso8601 [format "%f" [expr $jd_deb - $actuel]]] 11 18] ###\n\n"
               #--- Delay of the waiting loop in seconds
               set delayloop "60"
               set flag [expr [expr $delayloop / 86400.0] + [mc_date2jd $now]]
               #--- Waiting loop
               while { $actuel <= $flag } {
                  if { $loopexit == "1" } {
                     break
                  }
                  #--- Bouclage sur l'heure systeme
                  set now now
                  catch {
                     set now [::audace::date_sys2ut now]
                  }
                  update
                  set actuel [mc_date2jd $now]
                  set panneau(cmaude,status2) "$caption(cmaude,attendre_nuit)"
                  $This.fra3.labURL3 configure -text "$panneau(cmaude,status2)"
                  set panneau(cmaude,status3) "$caption(cmaude,decompte) [string range [mc_date2iso8601 [format "%f" [expr $jd_deb - $actuel]]] 11 18]"
                  $This.fra3.labURL4 configure -text "$panneau(cmaude,status3)"
                  update
               }
            }
            if { $loopexit == "0" } {
               ::console::affiche_prompt "$caption(cmaude,nuit_a_commencee)\n"
               ::console::affiche_prompt "$caption(cmaude,debut_acquisition)\n\n"
               #--- Writing the observation Log
               set namelog [string range [mc_date2jd $now] 0 6]
               catch {
                  set fileId [open $cmconf(folder)/$namelog.log a]
                  set textlog "$caption(cmaude,observation_log) [string range [mc_date2jd $now] 0 6] $caption(cmaude,ou) [string range [mc_date2iso8601 $actuel] 0 9]\n\n"
                  append textlog "$caption(cmaude,hauteur_soleil_debut_nuit) < $haurore°\n\n"
                  append textlog $resultb
                  append textlog $resulte
                  puts $fileId $textlog
                  close $fileId
               }
            }

            #--- Night has come, acquisitions beginning (simulation)
            #--- Waiting for the day to end the acquisitions

            set actuel [mc_date2jd $now]

            set panneau(cmaude,status2) "$caption(cmaude,status2)"
            $This.fra3.labURL3 configure -text "$panneau(cmaude,status2)"

            while { [mc_date2jd $now] <= $jd_fin } {
            #--- Test to exit the loop if push on STOP
               if { $loopexit == "1" } {
                  break
               }
               #--- Acquisition procedure
               ::cmaude::cmdAcq
               incr compteur
               #--- Bouclage sur l'heure systeme
               set now now
               catch {
                  set now [::audace::date_sys2ut now]
               }
               update
               set actuel [mc_date2jd $now]
               set flag [expr [expr $panneau(cmaude,rythm) / 86400.0] + $actuel]
               #--- Loop waiting to take the following image
               while { $actuel <= $flag } {
                  if { $loopexit == "1" } {
                     break
                  }
                  #--- Bouclage sur l'heure systeme
                  set now now
                  catch {
                     set now [::audace::date_sys2ut now]
                  }
                  update
                  set actuel [mc_date2jd $now]
                  set panneau(cmaude,status2) "$caption(cmaude,boucle_acquisition)"
                  $This.fra3.labURL3 configure -text "$panneau(cmaude,status2)"
                  set panneau(cmaude,status3) "$caption(cmaude,prochaine_image) [string range [mc_date2iso8601 [format "%f" [expr $flag - $actuel]]] 11 18]"
                  $This.fra3.labURL4 configure -text "$panneau(cmaude,status3)"
                  update
               }
            }
            if { $loopexit == "0" } {
               ::console::affiche_prompt "$caption(cmaude,jour_a_commence)\n"
               ::console::affiche_prompt "$caption(cmaude,nbre_image_nuit) [expr $compteur-1]\n\n"
               set textlog "\n$caption(cmaude,fin_observation) [string range [mc_date2iso8601 $actuel] 0 9] $caption(cmaude,a) [string range [mc_date2iso8601 $actuel] 11 20] $caption(cmaude,TU)\n\n"
               catch {
                  set fileId [open $cmconf(folder)/$namelog.log a]
                  append textlog "$caption(cmaude,nbre_image_nuit) [expr $compteur-1]\n"
                  puts $fileId $textlog
                  close $fileId
               }
               set compteur "1"
               set panneau(cmaude,nom) "$cmconf(folder)"
               ::console::affiche_prompt "$caption(cmaude,calcul_parametres)\n\n"
               ::console::affiche_erreur "###############################\n"
            }
            #--- Day has come, the loop re-run beginning with
            #--- the calculation of the parameters for the following day
         #--- End of infinite loop
         }
         ::console::affiche_erreur "###############################\n"
         ::console::affiche_erreur "$caption(cmaude,fin_boucle_acquisition)\n"
         ::console::affiche_erreur "###############################\n\n"
         set panneau(cmaude,status2) "$caption(cmaude,pas_activite)"
         $This.fra3.labURL3 configure -text "$panneau(cmaude,status2)"
         set panneau(cmaude,status3) "$caption(cmaude,status2)"
         $This.fra3.labURL4 configure -text "$panneau(cmaude,status3)"
         set dateend [mc_date2iso8601 now]
         catch {
            set fileId [open $cmconf(folder)/$namelog.log a]
            puts $fileId "\n$caption(cmaude,fin_boucle_acquisition_a) $dateend !\n"
            close $fileId
         }
         $This.fra2.but1 configure -relief raised -state normal
         update
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   #--- End of proc cmdGO
   }

   #==============================
   #=== Command of button STOP ===

   proc cmdStop { } {
   #--- Fonction called by pushing button STOP
      variable This
      global audace caption compteur loopexit panneau

      if { [ ::cam::list ] != "" } {
         $This.fra2.but2 configure -relief groove -state disabled
         update
         #--- Initialisation a la demande du compteur des images a 1
         set choix [ tk_messageBox -type yesno -icon warning -title "$caption(cmaude,initialisation)" \
            -message "$caption(cmaude,texte_init)" ]
         if { $choix == "yes" } {
            set compteur "1"
         }
         #---
         set loopexit "1"
         set panneau(cmaude,status) "$caption(cmaude,arret_auto_script)"
         $This.fra3.lab2 configure -text "$panneau(cmaude,status)"
         $This.fra2.but2 configure -relief raised -state normal
         update
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   }

   #==============================
   #=== Command of Acquisition ===

   proc cmdAcq { } {
   #--- Fonction of acquisition
      variable This
      variable cmconf
      global audace caption compteur namelog panneau

      #--- Initialisation de l'heure TU ou TL
      set now now
      catch {
         set now [::audace::date_sys2ut now]
      }
      #--- Acquisition of an image
      set actuel [mc_date2jd $now]
      #--- Test of the astronomical twilight and of the presence of the Moon
      #--- and adapt the right exposure time
      #--- Recuperation de la position de l'observateur
      set cmconf(localite) "$audace(posobs,observateur,gps)"
      set localite "$cmconf(localite)"
      set highsun [lindex [mc_ephem sun [list [mc_date2tt $actuel]] {altitude} -topo $localite] 0]
      set highmoon [lindex [mc_ephem moon [list [mc_date2tt $actuel]] {altitude} -topo $localite] 0]
      ::console::affiche_erreur "\n"
      if { $highsun > $cmconf(hastwilight) } {
         ::console::affiche_erreur "$caption(cmaude,hauteur_soleil) = [string range $highsun 0 4]° $caption(cmaude,au-dessus) $cmconf(hastwilight)°\n"
         ::console::affiche_erreur "$caption(cmaude,hauteur_limite_soleil)\n"
         set panneau(cmaude,time) "$cmconf(exptime2)"
      }
      if { $highmoon > $cmconf(hmooncritic) } {
         ::console::affiche_erreur "$caption(cmaude,hauteur_lune) = [string range $highmoon 0 4]° $caption(cmaude,au-dessus) $cmconf(hmooncritic)°\n"
         ::console::affiche_erreur "$caption(cmaude,hauteur_critique_lune)\n"
         set panneau(cmaude,time) "$cmconf(exptime2)"
      }

      ::console::affiche_erreur "$caption(cmaude,acquisition_lance)\n"
      ::cmaude::acq $panneau(cmaude,time) $panneau(cmaude,binning)
      set nameima "[string range [mc_date2jd $now] 0 6]-$compteur$cmconf(extension)"
      set cmconf(nameima) [ file join $cmconf(folder) [string range [mc_date2jd $now] 0 6]-$compteur ]
      set sidertime [ mc_date2lst now $localite ]
      #--- Specific keywords
      buf$audace(bufNo) setkwd [ list "OPTICS"   $cmconf(fits,OPTICS)   string "Type of optics used" " " ]
      buf$audace(bufNo) setkwd [ list "SIDERAL"  $sidertime             string "Local Sideral Time" " " ]

      set textima "$caption(cmaude,image) $nameima $caption(cmaude,acquise_le) [string range [mc_date2iso8601 $actuel] 0 9] $caption(cmaude,a) [string range [mc_date2iso8601 $actuel] 11 18] $caption(cmaude,TU)"
      ::console::affiche_erreur "$textima\n"
      ::console::affiche_erreur "$caption(cmaude,posee) $panneau(cmaude,time) $caption(cmaude,seconde) - $caption(cmaude,binning) $panneau(cmaude,binning)\n"

      #--- Pre-processing
      ::console::affiche_erreur "$caption(cmaude,pretraitement)\n"
      catch { opt $panneau(cmaude,dark) $panneau(cmaude,bias) }
      if { $panneau(cmaude,binning) == "1x1" } {
         #--- Cut of the image to gain space and avoid the black part around
         buf$audace(bufNo) window $cmconf(win11)
      } elseif { $panneau(cmaude,binning) == "2x2" } {
         #--- Cut of the image to gain space and avoid the black part around
         buf$audace(bufNo) window $cmconf(win22)
      }
      #--- Add the image "overlay.extension" with orientation info and logo ;-)
      catch { add $panneau(cmaude,overlay) 0 }
      #---
      saveima $nameima
      ::audace::autovisu $audace(visuNo)
      sauve_jpeg "[ file rootname $nameima ]"
      ::console::affiche_erreur "$caption(cmaude,image_sauvee)\n"
      ::console::affiche_erreur "\n"
      ::console::affiche_erreur "$caption(cmaude,prochaine_image_dans) $panneau(cmaude,rythm) $caption(cmaude,secondes)\n"
      ::console::affiche_erreur "\n\n"
      set panneau(cmaude,nom) "$cmconf(folder)[string range [mc_date2jd $now] 0 6]-$compteur"
      $This.fra3.lab2 configure -text "$panneau(cmaude,status)"
      #--- Writing the observation Log and html file
      if { $panneau(cmaude,page_html) == "1" } {
         source [ file join $audace(rep_plugin) tool cmaude cmaude_makehtml.tcl ]
      }
      catch {
         set fileId [open $cmconf(folder)/$namelog.log a]
         puts $fileId $textima
         close $fileId
      }
   }

   #=======================
   #=== The acquisition ===

   proc acq { exptime binning } {
      variable This
      global audace caption numcam panneau

      #--- Petit raccourci
      set numcam [ ::confCam::getCamNo [::confVisu::getCamItem $audace(visuNo)] ]

      #--- Initialisation du fenetrage
      catch {
         set n1n2 [ cam$numcam nbcells ]
         cam$numcam window [ list 1 1 [ lindex $n1n2 0 ] [ lindex $n1n2 1 ] ]
      }

      #--- La commande exptime permet de fixer le temps de pose de l'image
      cam$numcam exptime $exptime

      #--- La commande bin permet de fixer le binning
      set binalors [ string range $panneau(cmaude,binning) 0 0 ]
      cam$numcam bin [list $binalors $binalors]

      #--- Declenchement de l'acquisition
      cam$numcam acq

      #--- Alarme sonore de fin de pose
      ::camera::alarme_sonore $exptime

      #--- Annonce Timer
      if { $exptime > "1" } {
         ::camera::dispTime cam$numcam $This.fra3.labURL4
      }

      #--- Attente de la fin de la pose
      vwait status_cam$numcam

      #--- Rajoute des mots clefs dans l'en-tete FITS
      foreach keyword [ ::keyword::getKeywords $audace(visuNo) ] {
         buf$audace(bufNo) setkwd $keyword
      }

      #--- Visualisation
      ::audace::autovisu $audace(visuNo)

      wm title $audace(base) "$caption(cmaude,image_acq) $exptime s"
   }

   #===============================
   #=== Command of button Ephem ===

   proc cmdEphe { } {
   #--- Fonction called by pushing button Ephemeris
   #--- Print on console some ephemeris about Sun and Moon for the current date
      variable cmconf
      global audace caption

      #--- Recuperation de la position de l'observateur
      set cmconf(localite) "$audace(posobs,observateur,gps)"
      set localite "$cmconf(localite)"
      #--- Initialisation de l'heure TU ou TL
      set now now
      catch {
         set now [::audace::date_sys2ut now]
      }
      set nownow [mc_date2jd $now]

      set datheur [mc_date2ymdhms $nownow]
      set hautsol [lindex [mc_ephem sun [list [mc_date2tt $nownow]] {altitude} -topo $localite] 0]
      set azimsol [lindex [mc_ephem sun [list [mc_date2tt $nownow]] {azimuth} -topo $localite] 0]

      set hautmoo [lindex [mc_ephem moon [list [mc_date2tt $nownow]] {altitude} -topo $localite] 0]
      set azimmoo [lindex [mc_ephem moon [list [mc_date2tt $nownow]] {azimuth} -topo $localite] 0]
      set elongmoo [lindex [mc_ephem moon [list [mc_date2tt $nownow]] {elong}] 0]
      set phaslun [lindex [mc_ephem moon [list [mc_date2tt $nownow]] {phase} -topo $localite] 0]
      set illufrac [expr 100 * (0.5 + 0.5 * cos ($phaslun / 180. * 3.1415))]
      set sidetime [mc_date2lst $nownow $localite]

      ::console::affiche_prompt "########## MASCOT #########\n"
      ::console::affiche_prompt "######## $caption(cmaude,ephemerides) ########\n"
      ::console::affiche_prompt "###### $caption(cmaude,date_courante) #####\n"
      ::console::affiche_prompt "$caption(cmaude,date) [string range [mc_date2iso8601 $nownow] 0 9]\n"
      ::console::affiche_prompt "$caption(cmaude,heure_tu) [string range [mc_date2iso8601 $nownow] 11 20]\n"
      ::console::affiche_prompt "$caption(cmaude,jour_julien:) $nownow\n"
      ::console::affiche_prompt "$caption(cmaude,temps_sideral) $sidetime\n"
      ::console::affiche_prompt "########### $caption(cmaude,soleil) ##########\n"
      ::console::affiche_prompt "$caption(cmaude,position_soleil)\n"
      ::console::affiche_prompt "$caption(cmaude,hauteur) [string range $hautsol 0 5]°\n"
      ::console::affiche_prompt "$caption(cmaude,azimut) [string range $azimsol 0 5]°\n"
      ::console::affiche_prompt "########### $caption(cmaude,lune) ##########\n"
      ::console::affiche_prompt "$caption(cmaude,position_lune)\n"
      ::console::affiche_prompt "$caption(cmaude,hauteur) [string range $hautmoo 0 5]°\n"
      ::console::affiche_prompt "$caption(cmaude,azimut) [string range $azimmoo 0 5]°\n"
      ::console::affiche_prompt "$caption(cmaude,elongation_lune) [string range $elongmoo 0 4]°\n"
      ::console::affiche_prompt "$caption(cmaude,phase_lune) [string range $phaslun 0 4]°\n"
      ::console::affiche_prompt "$caption(cmaude,illumine_lune) [string range $illufrac 0 4]%\n"
      ::console::affiche_prompt "#########################\n\n"
   }

   #===============================
   #=== Command of button ... ===

   proc parcourir { option } {
      global audace panneau

      #--- Parent window
      set fenetre "$audace(base)"
      #--- Open the window to select images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- File name
      if { $option == "1" } {
        set panneau(cmaude,bias) $filename
      } elseif { $option == "2" } {
        set panneau(cmaude,dark) $filename
      } elseif { $option == "3" } {
        # set traiteWindow(in) [ file rootname [ file tail $filename ] ]
        set panneau(cmaude,overlay) $filename
      }
   }

}

################################################################
# namespace ::cmaude::config
#    Fenetre de configuration de l'outil Acquisition MASCOT
################################################################
namespace eval ::cmaude::config {

   #
   # cmaude::config::initToConf
   # Initialisation des variables de configuration
   #
   proc initToConf { } {
   }

   #
   # cmaude::config::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { } {
   }

   #
   # cmaude::config::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
   }

   #
   # cmaude::config::run
   # Cree la fenetre de configuration
   #
   proc run { } {
      variable This
      global audace

      #---
      set This "$audace(base).cmaudeSetup"
      ::confGenerique::run $audace(visuNo) "$This" "::cmaude::config" -modal 0
      set posx_config [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_config + 180 ]+[ expr $posy_config + 60 ]
   }

   #
   # cmaude::config::apply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc apply { visuNo } {
   }

   #
   # cmaude::config::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::cmaude::getPluginType ] ] \
         [ ::cmaude::getPluginDirectory ] cmaude.htm
   }

   #
   # cmaude::config::closeWindow
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc closeWindow { visuNo } {
   }

   #
   # cmaude::config::getLabel
   # Retourne le nom de la fenetre de configuration
   #
   proc getLabel { } {
      global caption

      return "$caption(cmaude,titre_config)"
   }

   #
   # cmaude::config::fillConfigPage
   # Creation de l'interface graphique
   #
   proc fillConfigPage { frm visuNo } {
      variable This
      global audace caption

      #--- Frame pour le bouton
      frame $This.frame3 -borderwidth 1 -relief raise

         #--- Bouton du configurateur d'en-tete FITS
         button $This.frame3.but -text $caption(cmaude,en-tete_fits) \
            -command "::keyword::run $audace(visuNo)"
         pack $This.frame3.but -side top -fill x

      pack $This.frame3 -side top -fill both -expand 1
   }

}

################################################################

#------------------------------------------------------------
# cmaudeBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc cmaudeBuildIF {This} {
global audace color panneau

   #--- Frame of panel
   frame $This -borderwidth 2 -relief groove

      #--- Frame of panel title
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label of title
         Button $This.fra1.but1 -borderwidth 1 -text $panneau(cmaude,titre) \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::cmaude::getPluginType ] ] \
               [ ::cmaude::getPluginDirectory ] [ ::cmaude::getPluginHelp ]"
         pack $This.fra1.but1 -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but1 -text $panneau(cmaude,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du bouton de configuration
      frame $This.fra1a -borderwidth 2 -relief groove

         #--- Label du bouton Configuration
         button $This.fra1a.but -borderwidth 1 -text $panneau(cmaude,config) \
            -command { cmaude::config::run }
         pack $This.fra1a.but -in $This.fra1a -anchor center -expand 1 -fill both -side top -ipadx 5

      pack $This.fra1a -side top -fill x

      #--- General frame
      frame $This.fra2 -borderwidth 1 -relief groove

         frame $This.fra2.fra4 -borderwidth 0 -relief flat

            #--- Bouton parcourir
            button $This.fra2.fra4.explore1 -borderwidth 2 -text $panneau(cmaude,parcourir) \
               -command { ::cmaude::parcourir 1 }
            pack $This.fra2.fra4.explore1 -in $This.fra2.fra4 -anchor center -fill none -padx 2 -pady 1 -ipady 3 -side right
            #--- Label for the name of bias
            label $This.fra2.fra4.lab1 -text "$panneau(cmaude,label_bias)" -relief flat
            pack $This.fra2.fra4.lab1 -in $This.fra2.fra4 -anchor center -expand 1 -fill both -padx 4 -pady 1
            #--- Entry for the name of bias
            entry $This.fra2.fra4.ent1 -font $audace(font,arial_7_b) -textvariable panneau(cmaude,bias) -relief groove
            pack $This.fra2.fra4.ent1 -in $This.fra2.fra4 -anchor center -expand 1 -fill both -padx 4 -pady 2

         pack $This.fra2.fra4 -side top -fill x

         frame $This.fra2.fra5 -borderwidth 0 -relief flat

            #--- Bouton parcourir
            button $This.fra2.fra5.explore2 -borderwidth 2 -text $panneau(cmaude,parcourir) \
               -command { ::cmaude::parcourir 2 }
            pack $This.fra2.fra5.explore2 -in $This.fra2.fra5 -anchor center -fill none -padx 2 -pady 1 -ipady 3 -side right
            #--- Label for the name of dark
            label $This.fra2.fra5.lab2 -text "$panneau(cmaude,label_dark)" -relief flat
            pack $This.fra2.fra5.lab2 -in $This.fra2.fra5 -anchor center -expand 1 -fill both -padx 4 -pady 1
            #--- Entry for the name of dark
            entry $This.fra2.fra5.ent2 -font $audace(font,arial_7_b) -textvariable panneau(cmaude,dark) -relief groove
            pack $This.fra2.fra5.ent2 -in $This.fra2.fra5 -anchor center -expand 1 -fill both -padx 4 -pady 2

         pack $This.fra2.fra5 -side top -fill x

         frame $This.fra2.fra6 -borderwidth 0 -relief flat

            #--- Bouton parcourir
            button $This.fra2.fra6.explore3 -borderwidth 2 -text $panneau(cmaude,parcourir) \
               -command { ::cmaude::parcourir 3 }
            pack $This.fra2.fra6.explore3 -in $This.fra2.fra6 -anchor center -fill none -padx 2 -pady 1 -ipady 3 -side right
            #--- Label for the name of overlay
            label $This.fra2.fra6.lab2a -text "$panneau(cmaude,label_overlay)" -relief flat
            pack $This.fra2.fra6.lab2a -in $This.fra2.fra6 -anchor center -expand 1 -fill both -padx 4 -pady 1
            #--- Entry for the name of overlay
            entry $This.fra2.fra6.ent2a -font $audace(font,arial_7_b) -textvariable panneau(cmaude,overlay) -relief groove
            pack $This.fra2.fra6.ent2a -in $This.fra2.fra6 -anchor center -expand 1 -fill both -padx 4 -pady 2

         pack $This.fra2.fra6 -side top -fill x

         #--- Label for the name of image
         label $This.fra2.lab3 -text "$panneau(cmaude,label_nom)" -relief flat
         pack $This.fra2.lab3 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2
         #--- Entry for the name of image
         entry $This.fra2.ent3 -font $audace(font,arial_7_b) -textvariable panneau(cmaude,nom) -relief groove
         pack $This.fra2.ent3 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2

         #--- Checkbutton for HTML page creation
         checkbutton $This.fra2.chck1 -text "$panneau(cmaude,label_page_html)" -variable panneau(cmaude,page_html)
         pack $This.fra2.chck1 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2

         #--- Label for the binning
         label $This.fra2.lab4 -text "$panneau(cmaude,label_binning)" -relief flat
         pack $This.fra2.lab4 -in $This.fra2 -anchor center -expand 1 -padx 4 -pady 1
         #--- Menu for the binning
         menubutton $This.fra2.but_binning -textvariable panneau(cmaude,binning) \
            -menu $This.fra2.but_binning.menu -relief raised
         pack $This.fra2.but_binning -in $This.fra2 -anchor center -padx 4 -pady 2 -ipadx 3
         set m [menu $This.fra2.but_binning.menu -tearoff 0 ]
         foreach binning $panneau(cmaude,list_binning) {
            $m add radiobutton -label "$binning" \
               -indicatoron "1" \
               -value "$binning" \
               -variable panneau(cmaude,binning) \
               -command { }
         }

         #--- Label for the exptime
         label $This.fra2.lab5 -text "$panneau(cmaude,label_time)" -relief flat
         pack $This.fra2.lab5 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 1
         #--- Entry for the exptime
         entry $This.fra2.ent5 -font $audace(font,arial_8_b) -textvariable panneau(cmaude,time) \
            -width 4 -relief groove -justify center
         pack $This.fra2.ent5 -in $This.fra2 -anchor center -padx 4 -pady 2

         #--- Label for the rythm
         label $This.fra2.lab6 -text "$panneau(cmaude,label_rythm)" -relief flat
         pack $This.fra2.lab6 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2
         #--- Entry for the rythm
         entry $This.fra2.ent6 -font $audace(font,arial_8_b) -textvariable panneau(cmaude,rythm) \
            -width 5 -relief groove -justify center
         pack $This.fra2.ent6 -in $This.fra2 -anchor center -padx 4 -pady 2

         #--- Button GO
         button $This.fra2.but1 -borderwidth 2 -text "$panneau(cmaude,go)" \
            -command { ::cmaude::cmdGo }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 8 -ipadx 25 -ipady 6

         #--- Button STOP
         button $This.fra2.but2 -borderwidth 2 -text "$panneau(cmaude,stop)" \
            -command { ::cmaude::cmdStop }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 8 -ipadx 15 -ipady 2

         #--- Button Ephemeris
         button $This.fra2.but3 -borderwidth 2 -text "$panneau(cmaude,ephem)" \
            -command { ::cmaude::cmdEphe }
         pack $This.fra2.but3 -in $This.fra2 -anchor center -fill none -pady 8 -ipadx 15 -ipady 2

      pack $This.fra2 -side top -fill x

      #--- Frame for the status
      frame $This.fra3 -borderwidth 2 -relief groove

         #--- Label for designation of status
         label $This.fra3.lab1 -text "$panneau(cmaude,label_status)" -font $audace(font,arial_10_b) -relief flat
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -expand 1 -fill both -side top
         #--- Label for status2
         label $This.fra3.lab2 -text "$panneau(cmaude,status)" -font $audace(font,arial_8_b) -relief flat
         pack $This.fra3.lab2 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1
         #--- Label for status2
         label $This.fra3.labURL3 -text "$panneau(cmaude,status2)" -font $audace(font,arial_8_b) -fg $color(red) -relief flat
         pack $This.fra3.labURL3 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1
         #--- Label for status3
         label $This.fra3.labURL4 -text "$panneau(cmaude,status3)" -font $audace(font,arial_8_b) -fg $color(red) -relief flat
         pack $This.fra3.labURL4 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1

      pack $This.fra3 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

#================================
#=== Intialisation of pannel  ===
#================================

#=== End of file cmaude.tcl ===

