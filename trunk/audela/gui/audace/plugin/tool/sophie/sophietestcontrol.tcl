##------------------------------------------------------------
# @file     sophiesimulcontrol.tcl
# @brief    Fichier du namespace ::sophie::test
# @author   Michel PUJOL et Robert DELMAS
# @version  $Id: sophietestcontrol.tcl,v 1.2 2009-10-19 21:10:00 michelpujol Exp $
#------------------------------------------------------------

##-----------------------------------------------------------
# @brief    Procédures de test de l'outil sophie et simulation des interfaces externes
#
#------------------------------------------------------------

#============================================================
#
# SIMULATION DE L'INTERFACE DE CONTROLE DU T193
#
#============================================================
namespace eval ::sophie::test {

}

proc ::sophie::test::init { mainThreadNo telescopeCommandPort telescopeNotificationPort} {
   variable private

   set private(mainThreadNo)  $mainThreadNo
   set private(telescopeControl,commandSocket) ""
   set private(telescopeControl,notificationSocket) ""
   set private(telescopeControl,writeNotificationSocket) ""
   set private(telescopeCommandPort) $telescopeCommandPort
   set private(telescopeNotificationPort) $telescopeNotificationPort
   set private(radecCoord,enabled) 0
   set private(sideralSlew,enabled) 1

   set private(motor,ra) "45.0"
   set private(motor,dec) "10.0"
   set private(motor,afterId) ""
   set private(motor,clock)   [clock milliseconds]
   set private(motor,raSpeed)   0
   set private(motor,decSpeed)  0

   set binDirectory [file dirname [info nameofexecutable]]
   load [file join $binDirectory libmc[info sharedlibextension]]
   ####disp "::sophie::test::init  \n"

}

proc ::sophie::test::disp { message } {
   variable private
   ::thread::send -async $private(mainThreadNo) [list ::console::disp "$message" ]
}


#------------------------------------------------------------
# openTelescopeControlSocket
#   ouvre une socket en lecture pour simuler l'interface de controle du telescope
#
#
#------------------------------------------------------------
proc ::sophie::test::openTelescopeControlSocket { } {
   variable private

   set catchError [ catch {
      #--- j'ouvre la socket des commandes
      set private(telescopeControl,commandSocket) [socket -server ::sophie::test::acceptTelescopeCommandSocket $private(telescopeCommandPort) ]

      #--- j'ouvre la socket de notification
      set private(telescopeControl,notificationSocket) [socket -server ::sophie::test::acceptTelescopeNotificationSocket $private(telescopeNotificationPort) ]

   }]

   if { $catchError != 0 } {
      #--- je referme les sockets ouvertes
      if { $private(telescopeControl,commandSocket) != "" } {
         close $private(telescopeControl,commandSocket)
         set private(telescopeControl,commandSocket) ""
      }

      if { $private(telescopeControl,notificationSocket) != "" } {
         close $private(telescopeControl,notificationSocket)
         set private(telescopeControl,notificationSocket) ""
      }
      #--- je tranmets l'erreur
      error $::errorInfo
   }
}

#------------------------------------------------------------
# closeTelescopeControlSocket
#   ferme les sockets
#
#------------------------------------------------------------
proc ::sophie::test::closeTelescopeControlSocket { } {
   variable private

   if { $private(telescopeControl,commandSocket) != "" } {
      close $private(telescopeControl,commandSocket)
      set private(telescopeControl,commandSocket) ""
   }
   if { $private(telescopeControl,notificationSocket) != "" } {
      close $private(telescopeControl,notificationSocket)
      set private(telescopeControl,notificationSocket) ""
   }
}

##------------------------------------------------------------
# acceptTelescopeCommandSocket
#    traite la demande de connexion entrante sur l'interface de controle.
#    Les donnees recues sont traitees par ::sophie::spectro::readSocket
# @param channel  identifiant du channel de la socket
# @param address  adresse de la machine du client
# @param port     port de la connexion entrante
# @return rien
#------------------------------------------------------------
proc ::sophie::test::acceptTelescopeCommandSocket { channel address port } {
   variable private

   disp " acceptTelescopeCommandSocket fconfigure $channel -buffering line -blocking false -translation binary -encoding binary\n"
   #--- je configure la gestion des buffer -buffering none -blocking no -translation binary -encoding binary
   fconfigure $channel -buffering line -blocking false -translation binary -encoding binary
   disp  "::sophie::test::acceptTelescopeCommandSocket $address:$port channel=$channel connected \n"
   #--- j'indique la procedure a appeler pour lire et traiter les donnees recues
   fileevent $channel readable [list ::sophie::test::readTelescopeCommandSocket $channel ]
}

##------------------------------------------------------------
# acceptTelescopeNotificationSocket
#    traite la demande de connexion entrante sur l'interface de controle.
#    Les donnees recues sur seront traitees par ::sophie::test::readSocket
#
# @param channel  identifiant du channel de la socket
# @param address  adresse de la machine du client
# @param port     port de la connexion entrante
# @return rien
#------------------------------------------------------------
proc ::sophie::test::acceptTelescopeNotificationSocket { channel address port } {
   variable private

   #--- je configure la gestion des buffer -buffering none -blocking no -translation binary -encoding binary
   fconfigure $channel -buffering line -blocking false -translation binary -encoding binary
   set private(telescopeControl,writeNotificationSocket) $channel
   disp  "::sophie::test::acceptTelescopeNotificationSocket  $address:$port channel=$channel connected \n"
   #--- j'indique la procedure a appeler pour lire et traiter les donnees recues
   fileevent $channel readable [list ::sophie::test::readTelescopeNotificationSocket $channel ]
}


#------------------------------------------------------------
# readTelescopeCommandSocket
#   lit la commande du PC de guidage
#   traite la commande
#   retounr une reponse
# @param channel handle de la socket
# @return rien
#------------------------------------------------------------
proc ::sophie::test::readTelescopeCommandSocket { channel } {
   variable private

   set catchError [ catch {
      if {[eof $channel ]} {
        close $channel
         disp "::sophie::test::readTelescopeCommandSocket close socket\n"
      } else {
         set command [gets $channel ]
         disp "::sophie::test::readTelescopeCommandSocket command=$command\n"

         #--- je decoupe la commande en un tableau
         set commandArray [split $command]
         #--- je traite la commande
         switch [lindex $commandArray 0] {
            "!RADEC" {
               switch [lindex $commandArray 1] {
                  MOVE {
                     #---
                     #---  $commandArray 2 = direction
                     set direction [lindex $commandArray 2]
                     set speedCode [lindex $commandArray 3]
                     ::sophie::test::startMotor $direction $speedCode
                     set returnCode 0
                     set response [format "!RADEC MOVE %d %s @" $returnCode $direction ]
                     ::sophie::test::writeTelescopeCommandSocket $channel $response
                  }
                  STOP {
                     set direction [lindex $commandArray 2]
                     ::sophie::test::stopMotor $direction
                     set returnCode 0
                     set response [format "!RADEC STOP %d %s @" $returnCode $direction ]
                     ::sophie::test::writeTelescopeCommandSocket $channel $response
                  }
                  COORD {
                     switch [lindex $commandArray 2] {
                        "0" {
                           #--- j'arrete de l'envoi periodique des coordonnees
                           ::sophie::test::stopRadecCoord
                           #--- je retourne la reponse
                           set raHms  [mc_angle2hms $private(motor,ra)]
                           set decDms [mc_angle2dms $private(motor,dec)]
                           set returnCode 0
                           set response [format "!RADEC COORD %d %02dh%02dm%04.1fs %+02dd%02dm%04.1fs @" \
                              $returnCode \
                              [lindex $raHms 0] [lindex $raHms 1] [lindex $raHms 2] \
                              [lindex $decDms 0] [lindex $decDms 1] [lindex $decDms 2] \
                           ]
                           ::sophie::test::writeTelescopeCommandSocket $channel $response
                        }
                        "1" {
                           #--- je demarre l'envoi periodique des coordonnees (boucle infinie en tache de fond)
                           ::sophie::test::startRadecCoord
                           #--- je retourne la reponse
                           set raHms  [mc_angle2hms $private(motor,ra)]
                           set decDms [mc_angle2dms $private(motor,dec)]
                           set returnCode 0
                           set response [format "!RADEC COORD %d %02dh%02dm%04.1fs %+02dd%02dm%04.1fs @" \
                              $returnCode \
                              [lindex $raHms 0] [lindex $raHms 1] [lindex $raHms 2] \
                              [lindex $decDms 0] [lindex $decDms 1] [lindex $decDms 2] \
                           ]
                           ::sophie::test::writeTelescopeCommandSocket $channel $response
                           #--- envoi des coordonnees
                        }
                        "2" {
                           #--- je retourne les coordonnes immediatement dans la reponse
                           set raHms  [mc_angle2hms $private(motor,ra)]
                           set decDms [mc_angle2dms $private(motor,dec)]
                           set returnCode 0
                           set response [format "!RADEC COORD %d %02dh%02dm%04.1fs %+02dd%02dm%04.1fs @" \
                              $returnCode \
                              [lindex $raHms 0] [lindex $raHms 1] [lindex $raHms 2] \
                              [lindex $decDms 0] [lindex $decDms 1] [lindex $decDms 2] \
                           ]
                           ::sophie::test::writeTelescopeCommandSocket $channel $response
                        }
                     }
                  }
                  GOTO {
                     ::sophie::test::startRadecGoto  [lindex $commandArray 2]  [lindex $commandArray 3]
                     #--- j'envoie le code retour
                     set returnCode 0
                     set response [format "!RADEC COORD %d @" $returnCode ]
                     ::sophie::test::writeTelescopeCommandSocket $channel $response
                  }
                  default {
                     disp "::sophie::test::readTelescopeCommandSocket invalid [lindex $commandArray 1] command=$command\n"
                  }
               }
            }
            "!FOC" {
               disp "::sophie::test::readTelescopeCommandSocket invalid [lindex $commandArray 0] command=$command\n"
               #--- je retourne une erreur 19= NOT IMPLEMENTED
               set returnCode 19 ;
               set response [format "!RADEC COORD %d @" $returnCode ]
               ::sophie::test::writeTelescopeCommandSocket $channel $response
            }
            default {
               disp "::sophie::test::readTelescopeCommandSocket invalid [lindex $commandArray 0] command=$command\n"
            }
         }
      }
   }]

   if { $catchError != 0 } {
      #--- je trace l'erreur dans la console
      disp $::errorInfo
   }
}

#------------------------------------------------------------
# writeTelescopeCommandSocket
#   envoie une reponse de la commande vers le PC de guidage
#
# @param response a envoyer
#------------------------------------------------------------
proc ::sophie::test::writeTelescopeCommandSocket { channel response } {
   variable private

   disp "::sophie::test::writeTelescopeCommandSocket response=$response\n"
   #--- remarque la commande puts ajoute "\n" a la fin de la chaine
   puts $channel $response

}

#------------------------------------------------------------
# readTelescopeNotificationSocket
#   envoie une donne vers le PC de guidage
#
#------------------------------------------------------------
proc ::sophie::test::readTelescopeNotificationSocket { channel } {
   variable private

   set response [gets $private(telescopeControl,notificationSocket) ]
   disp "::sophie::test::readTelescopeNotificationSocket response=$response\n"
}

#------------------------------------------------------------
# writeTelescopeNotificationSocket
#   envoie une notitifaction au PC de guidage
# Exemple :
#  ::sophie::test::writeTelescopeNotificationSocket "!RADEC COORD 0 0 03h00m00.0s +44d59m59.0s @"
#
# @param notitifaction a envoyer
#------------------------------------------------------------
proc ::sophie::test::writeTelescopeNotificationSocket { notification } {
   variable private

   ###disp "::sophie::test::writeTelescopeNotificationSocket notification=$notification\n"
   puts $private(telescopeControl,writeNotificationSocket)  $notification

}

#------------------------------------------------------------
# startRadecCoord
#   demarre l'envoi des coordonnees au PC de guidage
#
# @param donnees a envoyer
#------------------------------------------------------------
proc ::sophie::test::startRadecCoord { } {
   variable private
   if { $private(radecCoord,enabled) == 0 } {
      set private(radecCoord,enabled) 1
      after 1000 ::sophie::test::sendRadecCoord
   }
}

#------------------------------------------------------------
# stopRadecCoord
#   demarre l'envoi des coordonnees au PC de guidage
#
# @param donnees a envoyer
#------------------------------------------------------------
proc ::sophie::test::stopRadecCoord { } {
   variable private
   set private(radecCoord,enabled) 0
}

#------------------------------------------------------------
# sendRadecCoord
#   envoie une donnee au PC de guidage
#
# @param donnees a envoyer
#------------------------------------------------------------
proc ::sophie::test::sendRadecCoord { } {
   variable private

   set raHms [mc_angle2hms $private(motor,ra)]
   set decDms [mc_angle2dms $private(motor,dec)]
   set returnCode 0
   set moveCode  0
   set response [format "!RADEC COORD %d %d %02dh%02dm%04.1fs %+02dd%02dm%04.1fs @" \
      $returnCode $moveCode \
      [lindex $raHms 0] [lindex $raHms 1] [lindex $raHms 2] \
      [lindex $decDms 0]  [lindex $decDms 1] [lindex $decDms 2] \
   ]
   ###disp "::sophie::test::sendRadecCoord response=$response\n"
   ::sophie::test::writeTelescopeNotificationSocket $response
   if { $private(radecCoord,enabled) == 1 } {
      #--- je lance une nouvelle iteration apres 1000 miliscondes
      after 1000 ::sophie::test::sendRadecCoord
   }
}


#------------------------------------------------------------
# startMotor
#   demarre un mouvement de moteur
#
# @param direction N S E W
# @param speedCode guidage ou centrage
#------------------------------------------------------------
proc ::sophie::test::startMotor { direction speedCode } {
   variable private

   set catchError [ catch {
      if { $speedCode == "guidage" } {
         set speed 3.75  ; #--- le quart de la vitesse siderale en arssec/s
      } else {
         set speed 30    ; #--- le double de la vitesse siderale en arssec/s
      }

      #--- je change la vitesse de la monture
      switch $direction {
         "E" {
            set private(motor,raSpeed) $speed
         }
         "W" {
            set private(motor,raSpeed) [expr 0 - $speed]
         }
         "N" {
            set private(motor,decSpeed) $speed
         }
         "S" {
            set private(motor,decSpeed) [expr 0 - $speed]
         }
      }


      if { $private(motor,raSpeed) != 0 || $private(motor,decSpeed) != 0 } {
         ###disp "startMotor $direction $speedCode $private(motor,raSpeed) $private(motor,decSpeed)\n"
         set private(motor,clock) [clock milliseconds]
         if { $private(motor,afterId) == "" } {
            set private(motor,afterId) [after 500 ::sophie::test::simulateMotor]
         }
      }
   }]

   if { $catchError != 0 } {
      ::sophie::test::disp  "$::errorInfo \n"
   }
}

#------------------------------------------------------------
# stopMotor
#   arrete un mouvement de moteur
#
# @param direction N S E W
#------------------------------------------------------------
proc ::sophie::test::stopMotor { direction } {
   variable private
   switch $direction {
      "E" -
      "W" {
         set private(motor,raSpeed) 0
      }
      "N" -
      "S" {
         set private(motor,decSpeed) 0
      }
   }
}

#------------------------------------------------------------
# simulateMotor
#   simule un mouvement de moteur en modifiant les coordonnes
#   toute les 500 millisecondes
#
#------------------------------------------------------------
proc ::sophie::test::simulateMotor { } {
   variable private
   set now [clock milliseconds]
   #--- je calcule le delai ecoule depuis le debut du mouvement
   set delay [ expr $now - $private(motor,clock)]
   set private(motor,clock) $now

   if { $private(motor,raSpeed) != 0 } {
      #--- je simule le deplacement
      set private(motor,ra) [expr $private(motor,ra) + double($delay) * $private(motor,raSpeed) / 3600.0 / 1000.0 ]
   }

   if { $private(motor,decSpeed) != 0 } {
      #--- je simule le deplacement
      set private(motor,dec) [expr $private(motor,dec) + double($delay) * $private(motor,decSpeed)  / 3600.0 / 1000.0 ]
   }
   ###disp "simulateMotor $private(motor,raSpeed) $private(motor,decSpeed) \n"

   ::thread::send -async $private(mainThreadNo) [list ::sophie::test::setRadec $private(motor,ra) $private(motor,dec) $private(motor,raSpeed) $private(motor,decSpeed)]
   if { $private(motor,raSpeed) != 0 ||  $private(motor,decSpeed) != 0 } {
      set private(motor,afterId) [after 500 ::sophie::test::simulateMotor ]
   } else {
      set private(motor,afterId) ""
   }

}

#------------------------------------------------------------
# startRadecGoto
#   demarre un GOTO
#
# @param ra  ascension droite (format hms)
# @param dec declinaison (format dms)
#------------------------------------------------------------
proc ::sophie::test::startRadecGoto { ra dec } {
   variable private

   set catchError [ catch {

      if { $private(motor,raSpeed) != 0 || $private(motor,decSpeed) != 0 } {
         ###disp "startMotor $direction $speedCode $private(motor,raSpeed) $private(motor,decSpeed)\n"
         set private(motor,clock) [clock milliseconds]
         if { $private(motor,afterId) == "" } {
            set private(motor,afterId) [after 500 ::sophie::test::simulateMotor]
         }
      }
   }]

   if { $catchError != 0 } {
      ::sophie::test::disp  "$::errorInfo \n"
   }
}


#------------------------------------------------------------
# slewSideral
#   si le suivi sideral est arrete, j'ajoute 15 arsec a RA toutes les secondes
#  pour simuler la dérive du telescope par rapport au ciel
#------------------------------------------------------------
proc ::sophie::test::slewSideral { } {
   variable private

   #--- je verifie que les temps sideral est arrete
   if { $private(sideralSlew,enabled) == 0 } {

      set private(motor,ra) [expr $private(motor,ra) + 15.0 / 3600 ]
      if { $private(motor,ra) > 360.0 } {
         set private(motor,ra) [expr $private(motor,ra) - 360.0 ]
      }
      ::thread::send -async $private(mainThreadNo) [list ::sophie::test::setRadec $private(motor,ra) $private(motor,dec) $private(motor,raSpeed) $private(motor,decSpeed) ]

      #--- je lance une nouvelle iteration apres 1 seconde
      after 1000 ::sophie::test::sendRadecCoord
   }
}




