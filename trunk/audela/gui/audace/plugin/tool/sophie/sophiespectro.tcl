##-----------------------------------------------------------
# @file     sophiespectro.tcl
# @brief    fichier du namespace ::sophie::spectro
# @author   Michel PUJOL et Robert DELMAS
# @version  $Id: sophiespectro.tcl,v 1.7 2009-09-19 15:46:48 robertdelmas Exp $
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
            #--- j'enregistre l'image integree
            saveImage [lindex $resultList 0] [lindex $resultList 1] [lindex $resultList 2] [lindex $resultList 3]
            set log [ format "%s Ecart : A=%5.2f  Arms=%5.2f  D=%5.2f  Drms=%5.2f  Gain : AP=%s  AI=%s  DP=%s  DI=%s  Coord : RA=%s  Dec=%s\n" \
               [ mc_date2iso8601 now ] \
               [lindex $resultList 0] [lindex $resultList 1] \
               [lindex $resultList 2] [lindex $resultList 3] \
               [ expr $::conf(sophie,alphaProportionalGain) * 100 ] \
               [ expr $::conf(sophie,alphaIntegralGain) * 100 ] \
               [ expr $::conf(sophie,deltaProportionalGain) * 100 ] \
               [ expr $::conf(sophie,deltaIntegralGain) * 100 ] \
               $::audace(telescope,getra) $::audace(telescope,getdec) ]
            ::sophie::log::writeLogFile $::audace(visuNo) log "$log"
            #--- je mets en forme le resultat pour le PC Sophie
            #--- a revoir ...A<20h>=<20h><20h><20h>2.68<20h><20h>Arms<20h>=<20h><20h>83.17<20h>D<20h>=<20h><20h><20h>2.74<20h>Drms<20h>=<20h>177.85<20h>
            set resultString [format "!GET_STAT@    A = %5.2f  Arms = %5.2f  D = %5.2f  Drms = %5.2f" \
               [lindex $resultList 0] [lindex $resultList 1] \
               [lindex $resultList 2] [lindex $resultList 3] \
            ]
           ### ::console::disp "::sophie::spectro::spectro::readSocket resultString=$resultString\n"
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
#     nom du fichier : "prefixe-date.fit"
#
#  avec  prefixe = "centrage" ou "guidage"  suivant le mode courant
#        date    = date courante au format ISO8601 , exemple : 2009-05-13T18:51:30.250
#  Mots cles enregistre dans le fichier :
#   - BIN1     binning horizontal
#   - BIN2     binning vertical
#   - DATE-OBS  date de debut de pose
#   - DATE-END  date de fin de pose
#   - EXPOSURE  temps de pose
#   - NAXIS1   largeur de l'image en pixel
#   - NAXIS2   hauteur de l'image en pixel
#   -
#------------------------------------------------------------
proc ::sophie::spectro::saveImage { alphaMean alphaRms deltaMean deltaRms} {
   variable private

   set sumBufNo [::sophie::getBufNo "sumBufNo"]
   if { $sumBufNo != 0 && [buf$sumBufNo imageready] == 1 } {
      set catchError [ catch {
         set visuNo  [::sophie::getVisuNo]
         set camItem [::confVisu::getCamItem $visuNo ]
         if { [file exists $::conf(sophie,imageDirectory)] == 0 } {
            #--- je signale que le repertoire n'existe pas
            error [format $::caption(sophie,directoryNotFound) $::conf(sophie,imageDirectory)]
         }

         #--- je recupere la date UT
         set shortName "$::conf(sophie,guidingFileNameprefix)-[mc_date2iso8601 [::audace::date_sys2ut now]]$::conf(extension,defaut)"
         #--- je remplace ":" par "-" car ce n'est pas un caractere autorise dasn le nom d'un fichier.
         set shortName [string map { ":" "-" } $shortName]
         #--- j'ajoute le repertoire dans le nom du fichier
         set fileName [file join $::conf(sophie,imageDirectory) $shortName]
         #--- j'ajoute les mot cles dans l'image integree
         ::keyword::setKeywordValue $visuNo "RA_MEAN"  $alphaMean
         ::keyword::setKeywordValue $visuNo "RA_RMS"   $alphaRms
         ::keyword::setKeywordValue $visuNo "DEC_MEAN" $deltaMean
         ::keyword::setKeywordValue $visuNo "DEC_RMS"  $deltaRms
         ::keyword::setKeywordValue $visuNo "DETNAM"   [::confCam::getPluginProperty $camItem "name"]
         ::keyword::setKeywordValue $visuNo "TELESCOP" $::conf(telescope)
         ::keyword::setKeywordValue $visuNo "SWCREATE" "[::audela::getPluginTitle] $::audela(version)"
         #--- j'ajoute des mots clefs dans l'en-tete FITS de l'image
         foreach keyword [ ::keyword::getKeywords $visuNo ] {
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

