#
# File : cmaude.tcl
# Description : Prototype for the Cloud Monitor panel
# Author : Sylvain RONDI
# Date of release : April 2002
#
# Date de mise a jour : 14 janvier 2006
#
# REMARKS :
# The definition of some variables (binning, exp. time, rythm...)
# is available in file cmaude_ini.tcl to be easily modified
#

package provide cmaude 1.0

namespace eval ::cmaude {
#============================================================
#===   Definition of namespace cmaude to create a panel   ===
#============================================================

   #================================================================
   #===   Definition of automatic functions to build the panel   ===
   #================================================================

   variable This
   variable cmconf
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool cmaude cmaude.cap ]

   proc init { { in "" } } {
      createPanel $in.cmaude
   }

   proc createPanel { this } {
      variable This
      variable cmconf
      global conf
      global audace
      global panneau
      global caption

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
      catch {
         set cmconf(folder)    "$conf(rep_images)"
         set cmconf(extension) "$conf(extension,defaut)"
      }
      set This $this
      #---
      set panneau(menu_name,cmaude)     "$caption(cmaude,titre_mascot)"
      set panneau(cmaude,titre)         "$caption(cmaude,titre_mascot)"
      set panneau(cmaude,aide)          "$caption(cmaude,help_titre)"
      set panneau(cmaude,label_bias)    "$caption(cmaude,bias)"
      set panneau(cmaude,bias11)        "c:/images/bias/off11synth$cmconf(extension)"
      set panneau(cmaude,label_dark)    "$caption(cmaude,dark)"
      set panneau(cmaude,dark11)        "c:/images/dark/dark11$cmconf(extension)"
      set panneau(cmaude,bias22)        "c:/images/bias/off22synth$cmconf(extension)"
      set panneau(cmaude,dark22)        "c:/images/dark/dark22$cmconf(extension)"
      set panneau(cmaude,label_overlay) "$caption(cmaude,overlay)"
      set panneau(cmaude,overlay11)     "c:/images/overlay/overlay$cmconf(extension)"
      set panneau(cmaude,label_nom)     "$caption(cmaude,nom_image)"
      set panneau(cmaude,nom)           "$cmconf(folder)[string range [mc_date2jd $now] 0 6]-"
      set panneau(cmaude,label_binning) "$caption(cmaude,binning)"
      set panneau(cmaude,binning)       "$cmconf(binning)"
      set panneau(cmaude,list_binning)  "1x1 2x2"
      set panneau(cmaude,label_time)    "$caption(cmaude,temps_pose)"
      set panneau(cmaude,time)          "$cmconf(exptime1)"
      set panneau(cmaude,label_rythm)   "$caption(cmaude,entre_2_images)"
      set panneau(cmaude,rythm)         "$cmconf(rythm)"
      set panneau(cmaude,go)            "$caption(cmaude,go_acquisition)"
      set panneau(cmaude,stop)          "$caption(cmaude,stop)"
      set panneau(cmaude,ephem)         "$caption(cmaude,ephemerides)"
      set panneau(cmaude,label_status)  "$caption(cmaude,status)"
      set panneau(cmaude,status)        "$caption(cmaude,status1)"
      set panneau(cmaude,status2)       "$caption(cmaude,status2)"
      set panneau(cmaude,status3)       "$caption(cmaude,status2)"
      cmaudeBuildIF $This
   }

   proc startTool { visuNo } {
      variable This

      pack $This -side left -fill y
      console::affiche_prompt "-------------------------\n"
      console::affiche_prompt "| Acquisition (MASCOT)\n"
      console::affiche_prompt "-------------------------\n"
      console::affiche_prompt "| Mini\n"
      console::affiche_prompt "| All\n"
      console::affiche_prompt "| Sky\n"
      console::affiche_prompt "| Cloud\n"
      console::affiche_prompt "| Observation\n"
      console::affiche_prompt "| Tool\n"
      console::affiche_prompt "-------------------------\n\n"
   }

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
      global audace
      global panneau
      global loopexit
      global compteur
      global namelog

      if { [ ::cam::list ] != "" } {
         $This.fra2.but1 configure -relief groove -state disabled
         update
         #--- Initialisation de l'heure TU ou TL
         set now now
         catch {
            set now [::audace::date_sys2ut now]
         }
         set loopexit "0"
         console::affiche_erreur "###############################\n"
         console::affiche_prompt "Beginning the Automatic Script Loop\n"
         set sndebug "0"
         set compteur "1"
         set namelog [string range [mc_date2jd $now] 0 6]

         #--- Recuperation de la position de l'observateur
         catch {
            set cmconf(localite) "$audace(posobs,observateur,gps)"
         }
         set localite "$cmconf(localite)"

         #--- Altitude of the sun under horizon for which one considers it's night
         set haurore "$cmconf(haurore)"

         #--- Some astronomical parameters...
         set ladate [mc_date2jd $now]

         set datheur [mc_date2ymdhms $ladate]
         set hautsol [lindex [mc_ephem sun [list [mc_date2tt $ladate]] {altitude} -topo $localite] 0]
         set azimsol [lindex [mc_ephem sun [list [mc_date2tt $ladate]] {azimuth} -topo $localite] 0]
         console::affiche_erreur "###############################\n"
         console::affiche_erreur "It is (YMD-HMS) $datheur TU\n"
         console::affiche_erreur "or (Julian Day) $ladate\n"
         console::affiche_erreur "Sun Position:\n"
         console::affiche_erreur	"Altitude: [string range $hautsol 0 5]°\n"
         console::affiche_erreur "Azimuth: [string range $azimsol 0 5]°\n"
         set phaslun [lindex [mc_ephem moon [list [mc_date2tt $ladate]] {phase} -topo $localite] 0]
         console::affiche_erreur "Actual Moon Phase: [string range $phaslun 0 5]°\n"
         set illufrac [expr 100 * (0.5 + 0.5 * cos ($phaslun / 180. * 3.1415))]
         console::affiche_erreur "Illuminated Fraction: [expr int($illufrac)]%\n"

         #--- Infinite loop running the automatic acquisition sequence (simulated)
         #--- Begins by calculating the parameters of sunset and sunrise for the current day
         #--- This loop ends by pushing STOP (change "loopexit" value to 1)

         while { 1 == 1 } {
            if { $loopexit == "1" } {
               break
            }
            set panneau(cmaude,status) "Auto Script Running..."
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
            set resultb "Night begins at [mc_date2iso8601 $jd_deb] UT\n"
            console::affiche_erreur "Night for Sun Altitude < $cmconf(haurore)°\n"
            console::affiche_erreur "$resultb"
            console::affiche_erreur "or JD = $jd_deb\n"

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
            set resulte "Night ends at [mc_date2iso8601 $jd_fin] UT\n"
            console::affiche_erreur "$resulte"
            console::affiche_erreur "or JD = $jd_fin\n"
            console::affiche_erreur "###############################\n"

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
              # set actuel [expr $actuel+0.125]
               console::affiche_saut "\n"
               console::affiche_erreur "It's now [string range [mc_date2iso8601 $actuel] 11 20] UT ...\n"
               console::affiche_erreur "Waiting for the Night at [string range [mc_date2iso8601 $jd_deb] 11 20] UT\n"
               console::affiche_erreur "COUNTDOWN: ###[string range [mc_date2iso8601 [format "%f" [expr $jd_deb - $actuel]]] 11 18]###\n"
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
                  set panneau(cmaude,status2) "Waiting for the Night..."
                  $This.fra3.labURL3 configure -text "$panneau(cmaude,status2)"
                  set panneau(cmaude,status3) "Countdown: [string range [mc_date2iso8601 [format "%f" [expr $jd_deb - $actuel]]] 11 18]"
                  $This.fra3.labURL4 configure -text "$panneau(cmaude,status3)"
                  update
               }
            }
            if { $loopexit == "0" } {
               console::affiche_saut "\n"
               console::affiche_prompt "Night has come\n"
               console::affiche_prompt "Beginning of the Acquisition Loop Imminent...\n\n"
               #--- Writing the observation Log
               set namelog [string range [mc_date2jd $now] 0 6]
               catch {
                  set fileId [open $cmconf(folder)/$namelog.log a]
                  set textlog "Observation Log for Julian Day [string range [mc_date2jd $now] 0 6] or [string range [mc_date2iso8601 $actuel] 0 9]\n"
                  append textlog "Night for altitude of Sun < $haurore°\n"
                  append textlog $resultb
                  append textlog $resulte
                  puts $fileId $textlog
                  close $fileId
               }
            }

            #--- Night has come, acquisitions beginning (simulation)
            #--- Waiting for the day to end the acquisitions

            ##!!! Correction horloge PC - A modifier !!!
            set actuel [mc_date2jd $now]
            # set actuel [expr $actuel+0.125]
            ##!!! Correction horloge PC - A modifier !!!

            set panneau(cmaude,status2) "---"
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
                  set panneau(cmaude,status2) "Loop of Acquisitions"
                  $This.fra3.labURL3 configure -text "$panneau(cmaude,status2)"
                  set panneau(cmaude,status3) "Next Image [string range [mc_date2iso8601 [format "%f" [expr $flag - $actuel]]] 11 18]"
                  $This.fra3.labURL4 configure -text "$panneau(cmaude,status3)"
                  update
               }
            }
            if { $loopexit == "0" } {
               console::affiche_prompt "Day has come...\n"
               console::affiche_prompt "Number of Images during the Night: [expr $compteur-1]\n"
               set textlog "End of observations the [string range [mc_date2iso8601 $actuel] 0 9] at [string range [mc_date2iso8601 $actuel] 11 20]UT\n"
               catch {
                  set fileId [open $cmconf(folder)/$namelog.log a]
                  append textlog "Number of images during the night: [expr $compteur-1]\n"
                  puts $fileId $textlog
                  close $fileId
               }
               set compteur "1"
               set panneau(cmaude,nom) "$cmconf(folder)"
               console::affiche_prompt "Calculating the Parameters for the Following Night...\n"
            }
            #--- Day has come, the loop re-run beginning with
            #--- the calculation of the parameters for the following day
         #--- End of infinite loop
         }
         console::affiche_prompt "! Manual End of the Acquisition Loop !\n"
         console::affiche_erreur "###############################\n\n"
         set panneau(cmaude,status2) "No Activity"
         $This.fra3.labURL3 configure -text "$panneau(cmaude,status2)"
         set panneau(cmaude,status3) "---"
         $This.fra3.labURL4 configure -text "$panneau(cmaude,status3)"
         set dateend [mc_date2iso8601 now]
         catch {
            set fileId [open $cmconf(folder)/$namelog.log a]
            puts $fileId "! Manual end of the acquisition loop at $dateend !\n"
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
      global audace
      global panneau
      global loopexit

      if { [ ::cam::list ] != "" } {
         $This.fra2.but2 configure -relief groove -state disabled
         update
         set loopexit "1"
         console::affiche_saut "\n"
         console::affiche_erreur "###############################\n"
         set panneau(cmaude,status) "Auto Script Stopped"
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
      global audace
      global panneau
      global compteur
      global namelog

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
      catch {
         set cmconf(localite) "$audace(posobs,observateur,gps)"
      }
      set localite "$cmconf(localite)"
      set highsun [lindex [mc_ephem sun [list [mc_date2tt $actuel]] {altitude} -topo $localite] 0]
      set highmoon [lindex [mc_ephem moon [list [mc_date2tt $actuel]] {altitude} -topo $localite] 0]
      if { $highsun > $cmconf(hastwilight) } then {
        # console::affiche_erreur "Sun Alt. =$highsun°, so above $cmconf(hastwilight)°\n"
         set panneau(cmaude,time) "$cmconf(exptime2)"
      }
      if { $highmoon > $cmconf(hmooncritic) } {
        # console::affiche_erreur "Moon Alt. =$highmoon° so above $cmconf($hmooncritic)°\n"
         set panneau(cmaude,time) "$cmconf(exptime2)"
      }

      ::cmaude::acq $panneau(cmaude,time) $panneau(cmaude,binning)
     # console::affiche_erreur "Aquisition Running...\n"
      set nameima "[string range [mc_date2jd $now] 0 6]-$compteur$cmconf(extension)"
      set sidertime [mc_date2lst now $localite]
      #--- Keywords
      buf$audace(bufNo) setkwd [list "OBSERVER" $cmconf(fits,OBSERVER) string "name of observer/observatory" " "]
      buf$audace(bufNo) setkwd [list "OPTICS" $cmconf(fits,OPTICS) string "type of optics used" " "]
      buf$audace(bufNo) setkwd [list "INSTRUME" $cmconf(fits,INSTRUME) string "type of instrument" " "]
      buf$audace(bufNo) setkwd [list "SIDERAL" $sidertime string "local sideral time" " "]

     # saveima $nameima
      set textima "Image $nameima done the [string range [mc_date2iso8601 $actuel] 0 9] at [string range [mc_date2iso8601 $actuel] 11 18] UT"
      console::affiche_erreur "$textima\n"
      console::affiche_erreur "Paused $panneau(cmaude,time) sec in binning $panneau(cmaude,binning)\n"

      #--- Pre-processing
      console::affiche_erreur "Pre-processing (offset, dark, window)...\n"
     # loadima $nameima
      if { $panneau(cmaude,binning) == "1x1" } then {
         catch { opt $panneau(cmaude,dark11) $panneau(cmaude,bias11) }
         #--- Cut of the image to gain space and avoid the black part around
         window $cmconf(win11)
         #--- Add the image "overlay.extension" with orientation info and logo ;-)
         catch { add $panneau(cmaude,overlay11) 0 }
      }
      if { $panneau(cmaude,binning) == "2x2" } then {
         catch { opt $panneau(cmaude,dark22) $panneau(cmaude,bias22) }
         window $cmconf(win22)
      }
      saveima $nameima
      ::audace::autovisu $audace(visuNo)
      sauve_jpeg "$nameima.jpg"
      console::affiche_erreur "Image pre-processed and saved\n"
      console::affiche_erreur "\n"
      console::affiche_erreur "Next Image in $panneau(cmaude,rythm) Seconds\n"
      console::affiche_erreur "\n"
      set panneau(cmaude,nom) "$cmconf(folder)[string range [mc_date2jd $now] 0 6]-$compteur"
      $This.fra3.lab2 configure -text "$panneau(cmaude,status)"
      #--- Writing the observation Log and html file
     # source [ file join $audace(rep_plugin) tool cmaude makehtml.tcl ]
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
      variable cmconf
      global audace
      global conf
      global caption
      global panneau
      global numcam

      set numcam [::cam::create audine lpt1 -ccd kaf400]
      cam$numcam buf 1

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
      cam$numcam shuttertype audine
      cam$numcam shutter synchro
      cam$numcam ampli synchro

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

      #--- Visualisation
      ::audace::autovisu $audace(visuNo)

     # wm title $audace(base) "$caption(audace,image,acquisition) $exptime s"
   }

   #===============================
   #=== Command of button Ephem ===

   proc cmdEphe { } {
   #--- Fonction called by pushing button Ephemeris
   #--- Print on console some ephemeris about Sun and Moon for the current date
      variable This
      variable cmconf
      global audace
      global panneau

      #--- Recuperation de la position de l'observateur
      catch {
         set cmconf(localite) "$audace(posobs,observateur,gps)"
      }
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

      console::affiche_prompt "######## MASCOT ########\n"
      console::affiche_prompt "######## Ephemeris ########\n"
      console::affiche_prompt "###### for current date ######\n"
      console::affiche_prompt "Date UT: [string range [mc_date2iso8601 $nownow] 0 9]\n"
      console::affiche_prompt "Hour UT: [string range [mc_date2iso8601 $nownow] 11 20]\n"
      console::affiche_prompt "Julian Day: $nownow\n"
      console::affiche_prompt "Sideral Time (hms): $sidetime\n"
      console::affiche_prompt "######## Sun ########\n"
      console::affiche_prompt "Sun Position:\n"
      console::affiche_prompt "Altitude: [string range $hautsol 0 5]°\n"
      console::affiche_prompt "Azimuth: [string range $azimsol 0 5]°\n"
      console::affiche_prompt "######## Moon ########\n"
      console::affiche_prompt "Moon Position:\n"
      console::affiche_prompt "Altitude: [string range $hautmoo 0 5]°\n"
      console::affiche_prompt "Azimuth: [string range $azimmoo 0 5]°\n"
      console::affiche_prompt "Elongation from Sun: [string range $elongmoo 0 4]°\n"
      console::affiche_prompt "Actual Moon Fhase: [string range $phaslun 0 4]°\n"
      console::affiche_prompt "Illuminated Fraction: ~[string range $illufrac 0 4]%\n"
      console::affiche_prompt "######################\n\n"
   }
}

proc cmaudeBuildIF {This} {
#======================
#=== Panel graphism ===
#======================
global audace
global panneau
global color

   #--- Frame of panel
   frame $This -borderwidth 2 -relief groove

      #--- Frame of panel title
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label of title
         Button $This.fra1.but1 -borderwidth 1 -text $panneau(cmaude,titre) \
            -command {
               ::audace::showHelpPlugin tool cmaude cmaude.htm
            }
         pack $This.fra1.but1 -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but1 -text $panneau(cmaude,aide)

      pack $This.fra1 -side top -fill x

      #--- General frame
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label for the name of bias
         label  $This.fra2.lab1 -text "$panneau(cmaude,label_bias)" -relief flat
         pack   $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 1
         #--- Entry for the name of bias
         entry  $This.fra2.ent1 -font $audace(font,arial_7_b) -textvariable panneau(cmaude,bias11) -relief groove
         pack   $This.fra2.ent1 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2

         #--- Label for the name of dark
         label  $This.fra2.lab2 -text "$panneau(cmaude,label_dark)" -relief flat
         pack   $This.fra2.lab2 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 1
         #--- Entry for the name of dark
         entry  $This.fra2.ent2 -font $audace(font,arial_7_b) -textvariable panneau(cmaude,dark11) -relief groove
         pack   $This.fra2.ent2 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2

         #--- Label for the name of overlay
         label  $This.fra2.lab2a -text "$panneau(cmaude,label_overlay)" -relief flat
         pack   $This.fra2.lab2a -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 1
         #--- Entry for the name of overlay
         entry  $This.fra2.ent2a -font $audace(font,arial_7_b) -textvariable panneau(cmaude,overlay11) -relief groove
         pack   $This.fra2.ent2a -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2

         #--- Label for the name of image
         label  $This.fra2.lab3 -text "$panneau(cmaude,label_nom)" -relief flat
         pack   $This.fra2.lab3 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2
         #--- Entry for the name of image
         entry  $This.fra2.ent3 -font $audace(font,arial_7_b) -textvariable panneau(cmaude,nom) -relief groove
         pack   $This.fra2.ent3 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2

         #--- Label for the binning
         label  $This.fra2.lab4 -text "$panneau(cmaude,label_binning)" -relief flat
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
         label  $This.fra2.lab5 -text "$panneau(cmaude,label_time)" -relief flat
         pack   $This.fra2.lab5 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 1
         #--- Entry for the exptime
         entry  $This.fra2.ent5 -font $audace(font,arial_8_b) -textvariable panneau(cmaude,time) \
            -width 4 -relief groove -justify center
         pack   $This.fra2.ent5 -in $This.fra2 -anchor center -padx 4 -pady 2

         #--- Label for the rythm
         label  $This.fra2.lab6 -text "$panneau(cmaude,label_rythm)" -relief flat
         pack   $This.fra2.lab6 -in $This.fra2 -anchor center -expand 1 -fill both -padx 4 -pady 2
         #--- Entry for the rythm
         entry  $This.fra2.ent6 -font $audace(font,arial_8_b) -textvariable panneau(cmaude,rythm) \
            -width 5 -relief groove -justify center
         pack   $This.fra2.ent6 -in $This.fra2 -anchor center -padx 4 -pady 2

         #--- Button GO
         button $This.fra2.but1 -borderwidth 2 -text "$panneau(cmaude,go)" \
            -command { ::cmaude::cmdGo }
         pack   $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 8 -ipadx 25 -ipady 6

         #--- Button STOP
         button $This.fra2.but2 -borderwidth 2 -text "$panneau(cmaude,stop)" \
            -command { ::cmaude::cmdStop }
         pack   $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 8 -ipadx 15 -ipady 2

         #--- Button Ephemeris
         button $This.fra2.but3 -borderwidth 2 -text "$panneau(cmaude,ephem)" \
            -command { ::cmaude::cmdEphe }
         pack   $This.fra2.but3 -in $This.fra2 -anchor center -fill none -pady 8 -ipadx 15 -ipady 2

      pack $This.fra2 -side top -fill x

      #--- Frame for the status
      frame $This.fra3 -borderwidth 2 -relief groove

         #--- Label for designation of status
         label  $This.fra3.lab1 -text "$panneau(cmaude,label_status)" -font $audace(font,arial_10_b) -relief flat
         pack   $This.fra3.lab1 -in $This.fra3 -anchor center -expand 1 -fill both -side top
         #--- Label for status2
         label  $This.fra3.lab2 -text "$panneau(cmaude,status)" -font $audace(font,arial_8_b) -relief flat
         pack   $This.fra3.lab2 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1
         #--- Label for status2
         label  $This.fra3.labURL3 -text "$panneau(cmaude,status2)" -font $audace(font,arial_8_b) -fg $color(red) -relief flat
         pack   $This.fra3.labURL3 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1
         #--- Label for status3
         label  $This.fra3.labURL4 -text "$panneau(cmaude,status3)" -font $audace(font,arial_8_b) -fg $color(red) -relief flat
         pack   $This.fra3.labURL4 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1

      pack $This.fra3 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

#================================
#=== Intialisation of pannel  ===
#================================
global audace

::cmaude::init $audace(base)

#=== End of file cmaude.tcl ===

