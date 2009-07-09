##-----------------------------------------------------------
# @file     sophiespectro.tcl
# @brief    fichier du namespace ::sophie::spectro
# @author   Michel PUJOL et Robert DELMAS
# @version  $Id: sophiespectro.tcl,v 1.3 2009-07-09 17:27:07 michelpujol Exp $
#------------------------------------------------------------

##------------------------------------------------------------
# @namespace sophie::spectro
# @brief   interface avec le PC du spectrographe Sophie
#
#------------------------------------------------------------
namespace eval ::sophie::spectro {
   variable private

   set private(socketHandle)  ""

   #--- variables de calcul des statistiques pour le PC Sophie
   set private(alphaMean) 0.0       ; #---  moyenne des corrections alpha
   set private(alphaRms)  0.0       ; #---  dispersion des corrections alpha
   set private(deltaMean) 0.0       ; #--- moyenne des corrections delta
   set private(deltaRms)  0.0       ; #--- dispersion des corrections delta
   set private(correctionNb)  0     ; #--- nombre de corrections
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
      ###::console::disp "::sophie::spectro::readSocket read channel=$channel data=$data\n"
      switch $data {
         "!RAZ_STAT@" {
            ::sophie::spectro::resetStatistics
         }
         "!STAT_ON@" {
            ::sophie::spectro::startStatistics
         }
         "!STAT_OFF@" {
            ::sophie::spectro::stopStatistics
         }
         "!GET_STAT@" {
            set resultList [::sophie::spectro::getStatistics ]

            #--- A<20h>=<20h><20h><20h>2.68<20h><20h>Arms<20h>=<20h><20h>83.17<20h>D<20h>=<20h><20h><20h>2.74<20h>Drms<20h>=<20h>177.85<20h>
            set resultString [format "A = %5.2f  Arms = %5.2f D = %5.2f Drms = %5.2f\n" \
               [lindex $resultList 0] [lindex $resultList 1] \
               [lindex $resultList 2] [lindex $resultList 3] \
            ]
            ###::console::disp "::sophie::spectro::spectro::readSocket resultString=$resultString\n"
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
}

##------------------------------------------------------------
# getStatistics
#  retourne les statistiques de guidage pour le PC Sophie
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
# @param alphaCorrection  correction alpha (arcsec)
# @param deltaCorrection  correction delta (arcsec)
# @return null
#------------------------------------------------------------
proc ::sophie::spectro::updateStatistics { alphaCorrection deltaCorrection } {
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
      set private(alphaMean) $alphaCorrection
      set private(deltaMean) $deltaCorrection
   }

   #--- je calcule la moyenne des corrections Alpha
   set diff [expr ($alphaCorrection + $private(alphaMean)) ]
   if { [expr abs($diff) < $epsilon ] }  {
      if { [expr $diff < 0] } {
         set diff [expr - $epsilon]
      } else {
         set diff [expr $epsilon]
      }
   }
   set mean [expr $private(alphaMean) + $diff / $private(correctionNb)]

   #--- je calcule rms des corrections Alpha
   set rms  [expr $private(alphaRms) + $diff * ($alphaCorrection  - $mean)]
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
   set diff [expr $deltaCorrection - $private(deltaMean) ]
   if { [expr abs($diff) < $epsilon ] }  {
     if { [expr $diff < 0] } {
         set diff [expr - $epsilon]
      } else {
         set diff [expr $epsilon]
      }
   }
   set mean [expr $private(deltaMean) + $diff / $private(correctionNb) ]

   #--- je calcule rms des corrections Delta
   set rms  [expr $private(deltaRms) + $diff * ( $deltaCorrection  - $mean )]
   if { [expr abs($rms) < $epsilon ] } {
      if { [expr $rms  < 0] } {
         set rms [expr - $epsilon]
      } else {
         set rms [expr $epsilon]
      }
   }

   set private(deltaMean) $mean
   set private(deltaRms)  $rms

   ###console::disp "::sophie::updateStatistics alphaMean=$private(alphaMean) alphaRms=$private(alphaRms) deltaMean=$private(deltaMean) deltaRms=$private(deltaRms)\n"
   return
}

