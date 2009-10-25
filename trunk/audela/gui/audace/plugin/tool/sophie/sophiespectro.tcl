##-----------------------------------------------------------
# @file     sophiespectro.tcl
# @brief    fichier du namespace ::sophie::spectro
# @author   Michel PUJOL et Robert DELMAS
# @version  $Id: sophiespectro.tcl,v 1.10 2009-10-25 13:26:24 michelpujol Exp $
#------------------------------------------------------------

##------------------------------------------------------------
# @namespace sophie::spectro
# @brief   interface avec le PC du spectrographe Sophie
#
#------------------------------------------------------------
namespace eval ::sophie::spectro {
   variable private

   set private(socketHandle) ""

   #--- variables de calcul des statistiques pour le PC Sophie
   set private(alphaMean) 0.0        ; #---  moyenne des corrections alpha
   set private(alphaRms)  0.0        ; #---  dispersion des corrections alpha
   set private(deltaMean) 0.0        ; #--- moyenne des corrections delta
   set private(deltaRms)  0.0        ; #--- dispersion des corrections delta
   set private(correctionNb)  0      ; #--- nombre de corrections
   set private(statisticsEnabled) 0  ; #---
   set private(xFwhm)     0.0        ; #--- seeing sur l'axe X (en arsec)
   set private(yFwhm)     0.0        ; #--- seeing sur l'axe Y (en arsec)
   set private(skyLevel)  0.0        ; #--- fond du ciel (en ADU)

}

##------------------------------------------------------------
# openSocket
#    ouvre une socket en attente d'une connexion du PC Sophie.
#    La connexion entrante du PC Sophie est traitee par ::sophie::spectro::acceptSocket
#
#------------------------------------------------------------
proc ::sophie::spectro::openSocket { } {
   variable private

   if { $private(socketHandle) != "" } {
      #--- je ferme la socket si elle etait deja ouverte
      closeSocket
   }

   #--- j'ouvre la socket en reception
   set private(socketHandle) [socket -server ::sophie::spectro::acceptSocket $::conf(sophie,socketPort) ]
   ###console::disp "::sophie::spectro::openSocket  OK channel=$private(socketHandle)\n"
}

##------------------------------------------------------------
# acceptSocket
#    traite la demande de connexion entrante du PC Sophie.
#    Les donnees recues sont traitees par ::sophie::spectro::readSocket
# @param channel  identifiant du channel de la socket
# @param address  adresse de la machine du client
# @param port     port de la connexion entrante
# @return rien
#------------------------------------------------------------
proc ::sophie::spectro::acceptSocket { channel address port } {
   variable private

   #--- je configure la gestion des buffer -buffering none -blocking no -translation binary -encoding binary
   fconfigure $channel -buffering line -blocking false -translation binary -encoding binary
   ###::console::disp  "::sophie::spectro::acceptSocket $address:$port channel=$channel connected \n"
   #--- j'indique la procedure a appeler pour lire et traiter les donnees recues
   fileevent $channel readable [list ::sophie::spectro::readSocket $channel ]
}

##------------------------------------------------------------
# closeSocket
#    deconnexion au PC du spectrographe Sophie
#
#
#------------------------------------------------------------
proc ::sophie::spectro::closeSocket {  } {
   variable private

   if { $private(socketHandle) != "" } {
      close $private(socketHandle)
      set private(socketHandle) ""
   }
}

##------------------------------------------------------------
# readSocket
#   lit et traite le message envoye par le PC Sophie.
#   Les messages sont :
#   - si RAZ_STAT  alors appelle resetStatistics
#   - si STAT_ON  alors appelle startStatistics
#   - si STAT_OFF  alors appelle stopStatistics
#   - si GET_STAT  alors appelle getStatistics et retourne les valeurs alphaMean alphaRms deltaMean deltaRms
#  @param channel  identifiant du channel de la socket
#------------------------------------------------------------
proc ::sophie::spectro::readSocket { channel } {
   variable private

   if {[eof $channel ]} {
     close $channel
   } else {
      set data [read -nonewline $channel]
      set beginPos [string first "!" $data ]
      set endPos   [string first "@" $data ]
      if { $beginPos != -1 && $endPos != -1 && $beginPos < $endPos } {
         set data [string range $data $beginPos $endPos ]
      }
     ### ::console::disp "::sophie::spectro::readSocket read channel=$channel data=###$data###\n"
      switch $data {
         "!RAZ_STAT@" {
            ::sophie::spectro::resetStatistics
         }
         "!STAT_ON@" {
            #--- j'initialise l'image integree
            set private(AsynchroneParameter) 1
            set camItem [::confVisu::getCamItem [::sophie::getVisuNo]]
            if { $camItem != "" } {
               ::camera::setAsynchroneParameter  $camItem \
                  "originSumCounter"         0
            }
            #--- j'initialise les statistique
            ::sophie::spectro::startStatistics
         }
         "!STAT_OFF@" {
            ::sophie::spectro::stopStatistics
         }
         "!GET_STAT@" {
            #--- je recupere les statistiques ( alphaMean alphaRms deltaMean detaRms)
            set resultList [::sophie::spectro::getStatistics ]
            #--- je calcule le seeing en faisant la moyenne de xFwhm et yFwhm
            set seeing [expr ($private(xFwhm) + $private(yFwhm)) / 2.0 ]
            #--- j'enregistre l'image integree
            set fileName [saveImage [lindex $resultList 0] [lindex $resultList 1] [lindex $resultList 2] [lindex $resultList 3] $seeing $private(skyLevel)]
            #--- j'ajoute un message dans le fichier de log
            set log [ format "%s Ecart : A=%5.2f  Arms=%5.2f  D=%5.2f  Drms=%5.2f  Seeing=%5.2f skyLevel= %5.2f Gain : AP=%s  AI=%s AD=%s DP=%s  DI=%s DD=%s Coord : RA=%s  Dec=%s\n" \
               [ mc_date2iso8601 now ] \
               [lindex $resultList 0] [lindex $resultList 1] \
               [lindex $resultList 2] [lindex $resultList 3] \
               $seeing $private(skyLevel) \
               [ expr $::conf(sophie,alphaProportionalGain) * 100 ] \
               [ expr $::conf(sophie,alphaIntegralGain) * 100 ] \
               [ expr $::conf(sophie,deltaProportionalGain) * 100 ] \
               [ expr $::conf(sophie,deltaIntegralGain) * 100 ] \
               [ expr $::conf(sophie,deltaDerivativeGain) * 100 ] \
               [ expr $::conf(sophie,deltaDerivativeGain) * 100 ] \
               $::audace(telescope,getra) $::audace(telescope,getdec) ]
            ::sophie::log::writeLogFile $::audace(visuNo) log $log
            #--- je mets en forme le resultat pour le PC Sophie
            #--- a revoir ...A<20h>=<20h><20h><20h>2.68<20h><20h>Arms<20h>=<20h><20h>83.17<20h>D<20h>=<20h><20h><20h>2.74<20h>Drms<20h>=<20h>177.85<20h>
            ###set resultString [format "!GET_STAT@    A = %5.2f  Arms = %5.2f  D = %5.2f  Drms = %5.2f" \
            ###   [lindex $resultList 0] [lindex $resultList 1] \
            ###   [lindex $resultList 2] [lindex $resultList 3] \
            ###]
            set resultString [format "!GET_STAT@    A = %5.2f  Arms = %5.2f  D = %5.2f  Drms = %5.2f  Seeing= %5.2f  SkyLevel= %5.2f FileName= %s " \
               [lindex $resultList 0] [lindex $resultList 1] \
               [lindex $resultList 2] [lindex $resultList 3] \
               $seeing $private(skyLevel) $fileName \
            ]
            ::console::disp "::sophie::spectro::spectro::readSocket resultString=$resultString\n"
            #--- je retourne le resultat au PC Sophie
            puts $channel $resultString

         }
         "" {
            #--- je ne fais rien s'il n'y a pas de donnees
         }
         default {
            console::affiche_erreur "::sophie::spectro::spectro::readSocket invalid data=$data\n"
         }
      }
   }
}

##------------------------------------------------------------
# resetStatistics
#   raz des variables de calcul des statistiques pour le PC Sophie
#
#------------------------------------------------------------
proc ::sophie::spectro::resetStatistics { } {
   variable private

   set private(alphaMean) 0.0       ; #--- moyenne des corrections alpha
   set private(alphaRms)  0.0       ; #--- dispersion des corrections alpha
   set private(deltaMean) 0.0       ; #--- moyenne des corrections delta
   set private(deltaRms)  0.0       ; #--- dispersion des corrections delta
   set private(correctionNb)  0     ; #--- nombre de corrections

}

##------------------------------------------------------------
# saveImage
#  enregistre l'image integree
#  Le nom du fichier est "guidage-dateISO8601.fit"
#
#  exemple : guidage-2009-05-13T18:51:30.250.fit
#
#  Mots cles enregistre dans l'image integree :
#   - BIN1     binning horizontal
#   - BIN2     binning vertical
#   - DATE-OBS  date de debut de pose
#   - DATE-END  date de fin de pose
#   - EXPOSURE  temps de pose individuel des images
#   - NAXIS1   largeur de l'image en pixel
#   - NAXIS2   hauteur de l'image en pixel
#
#   - RA_MEAN  moyenne l'ecart etoile/consigne sur l'axe alpha
#   - RA_RMS   ecart type de l'ecart etoile/consigne sur l'axe alpha
#   - DEC_MEAN moyenne l'ecart etoile/consigne sur l'axe delta
#   - DEC_RMS  ecart type de l'ecart etoile/consigne sur l'axe delta
#   - SEEING   seeing moyenne (en arcsec)
#   - BACKGROUND fond du ciel (en ADU)
#   - DETNAM   nom de la camera
#   - TELESCOP nom du telescope
#   - SWCREATE nom du logiciel d'acquisition
#
# @param alphaMean
# @param alphaRms
# @param deltaMean
# @param deltaRms
# @param xFwhm
# @param yFwhm
#
# @return filename
#------------------------------------------------------------
proc ::sophie::spectro::saveImage { alphaMean alphaRms deltaMean deltaRms seeing skyLevel } {
   variable private

   set shortName ""

   set sumBufNo [::sophie::getBufNo "sumBufNo"]
   if { $sumBufNo != 0 && [buf$sumBufNo imageready] == 1 } {
      set catchError [ catch {
         set visuNo  [::sophie::getVisuNo]
         set camItem [::confVisu::getCamItem $visuNo ]
         if { [file exists $::audace(rep_images)] == 0 } {
            #--- je signale que le repertoire n'existe pas
            error [format $::caption(sophie,directoryNotFound) $::audace(rep_images)]
         }

         #--- je recupere la date UT
         set shortName "$::conf(sophie,guidingFileNameprefix)-[mc_date2iso8601 [::audace::date_sys2ut now]]$::conf(extension,defaut)"
         #--- je remplace ":" par "-" car ce n'est pas un caractere autorise dasn le nom d'un fichier.
         set shortName [string map { ":" "-" } $shortName]
         #--- j'ajoute le repertoire dans le nom du fichier
         set fileName [file join $::audace(rep_images) $shortName]
         #--- j'ajoute les mot cles dans l'image integree
         ::keyword::setKeywordValue $visuNo "RA_MEAN"  $alphaMean
         ::keyword::setKeywordValue $visuNo "RA_RMS"   $alphaRms
         ::keyword::setKeywordValue $visuNo "DEC_MEAN" $deltaMean
         ::keyword::setKeywordValue $visuNo "DEC_RMS"  $deltaRms
         ::keyword::setKeywordValue $visuNo "SEEING"   $seeing
         ::keyword::setKeywordValue $visuNo "SKYLEVEL" $skyLevel
         ::keyword::setKeywordValue $visuNo "DETNAM"   [::confCam::getPluginProperty $camItem "name"]
         ::keyword::setKeywordValue $visuNo "TELESCOP" $::conf(telescope)
         ::keyword::setKeywordValue $visuNo "SWCREATE" "[::audela::getPluginTitle] $::audela(version)"
         set keywordNameList [list RA_MEAN RA_RMS DEC_MEAN DEC_RMS SEEING SKYLEVEL DETNAM TELESCOP SWCREATE]
         #--- j'ajoute des mots clefs dans l'en-tete FITS de l'image
         foreach keyword [ ::keyword::getKeywords $visuNo $keywordNameList] {
            #--- j'ajoute tous les mots cles qui ne sont pas vide
            buf$sumBufNo setkwd $keyword
         }

         #--- Sauvegarde de l'image
         buf$sumBufNo save $fileName
      } ]

      if { $catchError != 0 } {
         #--- je trace le message d'erreur
         ::console::affiche_erreur $::errorInfo
      }
   } else {
      ::console::affiche_erreur $::caption(sophie,sumNotReady)
   }

   return $shortName
}

##------------------------------------------------------------
# setSeeing
#   memorise le seeing
# @param xFwhm       seeing sur l'axe x (en arsec)
# @param yFwhm       seeing sur l'axe y (en arsec)
# #param background  fond du ciel (en ADU)
#------------------------------------------------------------
proc ::sophie::spectro::setSeeing { xFwhm yFwhm skyLevel} {
   variable private

   set private(xFwhm)      $xFwhm
   set private(yFwhm)      $yFwhm
   set private(skyLevel)   $skyLevel
}

##------------------------------------------------------------
# startStatistics
#  debute le calcul des statistiques de guidage pour le PC Sophie
#
#------------------------------------------------------------
proc ::sophie::spectro::startStatistics { } {
   variable private

   #--- j'active les statistiques
   set private(statisticsEnabled) 1

   #--- je met a jour le voyant dans la fenetre de controle
   ::sophie::control::setAcquisitionSophie 1

   #--- j'ajoute le mot cle DATE-OBS dans l'image integree
   set sumBufNo [::sophie::getBufNo "sumBufNo"]
   if { $sumBufNo != 0 && [buf$sumBufNo imageready] == 1 } {
      set dateObs [mc_date2iso8601 [::audace::date_sys2ut now]]
      buf$sumBufNo setkwd [list "DATE-OBS" $dateObs string "" "" ]
   }
}

##------------------------------------------------------------
# stopStatistics
#  arrete le calcul des statistiques de guidage pour le PC Sophie
#
#------------------------------------------------------------
proc ::sophie::spectro::stopStatistics { } {
   variable private

   #--- j'arrete la mise a jour des statistiques
   set private(statisticsEnabled) 0

   #--- je met a jour le voyant dans la fenetre de controle
   ::sophie::control::setAcquisitionSophie 0

   #--- j'ajoute le mot cle DATE-END dans l'image integree
   set sumBufNo [::sophie::getBufNo "sumBufNo"]
   if { $sumBufNo != 0 && [buf$sumBufNo imageready] == 1 } {
      set dateEnd [mc_date2iso8601 [::audace::date_sys2ut now]]
      buf$sumBufNo setkwd [list "DATE-END" $dateEnd string "" "" ]
   }
}

##------------------------------------------------------------
# getStatistics
#  retourne les statistiques de guidage pour le PC Sophie
#
#  @return liste de 4 valeurs : private(alphaMean) private(alphaRms) private(deltaMean) private(deltaRms)
#------------------------------------------------------------
proc ::sophie::spectro::getStatistics { } {
   variable private

   #--- je calcule la valeur finale de alphaRms
   if { $private(alphaRms) >=0 && $private(correctionNb) > 0 } {
      set private(alphaRms) [expr sqrt($private(alphaRms) / $private(correctionNb)) ]
   } else {
      set private(alphaRms) 0.0
   }

   #--- je calcule la valeur finale de alphaRms
   if { $private(deltaRms) >=0 && $private(correctionNb) > 0 } {
      set private(deltaRms) [expr sqrt($private(deltaRms) / $private(correctionNb)) ]
   } else {
      set private(deltaRms) 0.0
   }

   set result [list $private(alphaMean) $private(alphaRms) $private(deltaMean) $private(deltaRms) ]
   ###set result [list 2.68 83.17 2.74 177.85 ]
   ###console::disp "::sophie::getStatistics $result\n"
   return $result
}

##------------------------------------------------------------
# updateStatistics
#   ajoute la correction du telescope dans les statistiques.
#   Les variables private(alphaMean) private(alphaRms) private(deltaaMean) private(deltaaRms)
#   sont mises a jour.
# @param alphaDiff  ecart alpha etoile/consigne (arcsec)
# @param deltaDiff  ecart delta etoile/consigne (arcsec)
# @return null
#------------------------------------------------------------
proc ::sophie::spectro::updateStatistics { alphaDiff deltaDiff } {
   variable private

   if { $private(statisticsEnabled) == 0 } {
      #--- je ne fais pas de mise a jour si les statistiques ne sont pas activees
      return
   }

   #--- j'increment le nombre de corrections
   incr private(correctionNb)
   set epsilon "1.0e-300"

   #--- j’initialise les moyennes pour la première itération
   if { $private(correctionNb) == 1 }  {
      set private(alphaMean) $alphaDiff
      set private(deltaMean) $deltaDiff
   }

   #--- je calcule la moyenne des corrections Alpha
   set diff [expr $alphaDiff - $private(alphaMean) ]
   if { [expr abs($diff) < $epsilon ] }  {
      if { [expr $diff < 0] } {
         set diff [expr - $epsilon]
      } else {
         set diff [expr $epsilon]
      }
   }
   set mean [expr $private(alphaMean) + $diff / $private(correctionNb)]

   #--- je calcule rms des corrections Alpha
   set rms  [expr $private(alphaRms) + $diff * ($alphaDiff  - $mean)]
   if { [expr abs($rms) < $epsilon ] } {
      if { [expr $rms  < 0] } {
         set rms [expr - $epsilon]
      } else {
         set rms [expr $epsilon]
      }
   }
   set private(alphaMean) $mean
   set private(alphaRms)  $rms

   #--- je calcule la moyenne des corrections Delta
   set diff [expr $deltaDiff - $private(deltaMean) ]
   if { [expr abs($diff) < $epsilon ] }  {
     if { [expr $diff < 0] } {
         set diff [expr - $epsilon]
      } else {
         set diff [expr $epsilon]
      }
   }
   set mean [expr $private(deltaMean) + $diff / $private(correctionNb) ]

   #--- je calcule rms des corrections Delta
   set rms  [expr $private(deltaRms) + $diff * ( $deltaDiff  - $mean )]
   if { [expr abs($rms) < $epsilon ] } {
      if { [expr $rms  < 0] } {
         set rms [expr - $epsilon]
      } else {
         set rms [expr $epsilon]
      }
   }

   set private(deltaMean) $mean
   set private(deltaRms)  $rms

  ### console::disp "::sophie::updateStatistics alphaMean=$private(alphaMean) alphaRms=$private(alphaRms) deltaMean=$private(deltaMean) deltaRms=$private(deltaRms)\n"
   return
}

