##------------------------------------------------------------
# @file     sophiesimulcontrol.tcl
# @brief    Fichier du namespace ::sophie::testcontrol
# @author   Michel PUJOL et Robert DELMAS
# @version  $Id: sophietestcontrol.tcl,v 1.4 2009-11-29 11:11:45 michelpujol Exp $
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
namespace eval ::sophie::testcontrol {

}

proc ::sophie::testcontrol::init { mainThreadNo telescopeCommandPort telescopeNotificationPort} {
   variable private

   set private(mainThreadNo)  $mainThreadNo
   set private(telescopeControl,commandSocket) ""
   set private(telescopeControl,notificationSocket) ""
   set private(telescopeControl,writeNotificationSocket) ""
   set private(telescopeCommandPort) $telescopeCommandPort
   set private(telescopeNotificationPort) $telescopeNotificationPort

   set private(motor,ra)      "45.0"          ; #--- en degres decimaux (positif vers l'est)
   set private(motor,dec)     "10.0"          ; #--- en degres decimaux (positif vers le nord)
   set private(motor,afterId) ""
   set private(motor,clock)   [clock milliseconds]
   set private(motor,raSpeed)   0
   set private(motor,decSpeed)  0

   set private(motor,slewSpeed,0)   0.0      ; #--- ces vitesses sont configurees quand le thread principal appelle sophie::test:configure au demarrage
   set private(motor,slewSpeed,1)   0.0
   set private(motor,slewSpeed,2)   0.0
   set private(motor,guidage)       0.0
   set private(motor,centrage)      0.0
   set private(motor,gotoSpeed)     0.0

   #--- variables de travail
   set private(motor,slewMode)  1         ; #--- 0 = pas de suivi, 1=suivi sideral, 2=suivi lunaire
   set private(radecCoord,enabled) 0      ; #--- 1=envoit les coordonnes periodiquement 0=n'envoit pas les coordonnees
   set private(motor,mode)    "NONE"      ; #--- NONE, ILLIMITED_MOVE, LIMITED_MOVE, GOTO
   set private(goto,raSpeed)  0.0
   set private(goto,decSpeed) 0.0

   #--- je charge la librairie de calcul de mecanique celeste dans le thread
   set binDirectory [file dirname [info nameofexecutable]]
   load [file join $binDirectory libmc[info sharedlibextension]]

   #--- je lance la boucle de simulation du moteur
   set private(motor,clock) [clock milliseconds]
   ::sophie::testcontrol::simulateMotor

   #--- j'envoi les coordonnees au thread principal pour les afficher dans la fenetre du simulateur
   ::sophie::testcontrol::updateGui

   ####disp "::sophie::testcontrol::init  \n"

}

proc ::sophie::testcontrol::disp { message } {
   variable private
   ::thread::send -async $private(mainThreadNo) [list ::console::disp "$message" ]
}


#------------------------------------------------------------
# openTelescopeControlSocket
#   ouvre une socket en lecture pour simuler l'interface de controle du telescope
#
#
#------------------------------------------------------------
proc ::sophie::testcontrol::openTelescopeControlSocket { } {
   variable private

   set catchError [ catch {
      #--- j'ouvre la socket des commandes
      set private(telescopeControl,commandSocket) [socket -server ::sophie::testcontrol::acceptTelescopeCommandSocket $private(telescopeCommandPort) ]

      #--- j'ouvre la socket de notification
      set private(telescopeControl,notificationSocket) [socket -server ::sophie::testcontrol::acceptTelescopeNotificationSocket $private(telescopeNotificationPort) ]

   }]

   set private(radecCoord,enabled) 0

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
proc ::sophie::testcontrol::closeTelescopeControlSocket { } {
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
proc ::sophie::testcontrol::acceptTelescopeCommandSocket { channel address port } {
   variable private

   disp " acceptTelescopeCommandSocket fconfigure $channel -buffering line -blocking false -translation binary -encoding binary\n"
   #--- je configure la gestion des buffer -buffering none -blocking no -translation binary -encoding binary
   fconfigure $channel -buffering line -blocking false -translation binary -encoding binary
   disp  "::sophie::testcontrol::acceptTelescopeCommandSocket $address:$port channel=$channel connected \n"
   #--- j'indique la procedure a appeler pour lire et traiter les donnees recues
   fileevent $channel readable [list ::sophie::testcontrol::readTelescopeCommandSocket $channel ]
}

##------------------------------------------------------------
# acceptTelescopeNotificationSocket
#    traite la demande de connexion entrante sur l'interface de controle.
#    Les donnees recues sur seront traitees par ::sophie::testcontrol::readSocket
#
# @param channel  identifiant du channel de la socket
# @param address  adresse de la machine du client
# @param port     port de la connexion entrante
# @return rien
#------------------------------------------------------------
proc ::sophie::testcontrol::acceptTelescopeNotificationSocket { channel address port } {
   variable private

   #--- je configure la gestion des buffer -buffering none -blocking no -translation binary -encoding binary
   fconfigure $channel -buffering line -blocking false -translation binary -encoding binary
   set private(telescopeControl,writeNotificationSocket) $channel
   disp  "::sophie::testcontrol::acceptTelescopeNotificationSocket  $address:$port channel=$channel connected \n"
   #--- j'indique la procedure a appeler pour lire et traiter les donnees recues
   fileevent $channel readable [list ::sophie::testcontrol::readTelescopeNotificationSocket $channel ]
}


#------------------------------------------------------------
# readTelescopeCommandSocket
#   lit la commande du PC de guidage
#   traite la commande
#   retounr une reponse
# @param channel handle de la socket
# @return rien
#------------------------------------------------------------
proc ::sophie::testcontrol::readTelescopeCommandSocket { channel } {
   variable private

   set catchError [ catch {
      if {[eof $channel ]} {
         #--- le client s'est deconnecte , je ferme la socket
         disp "::sophie::testcontrol::readTelescopeCommandSocket close socket\n"
         #---  je ferme la socket
         close $channel
         #--- j'arrete l'envoi des notifications
         set private(radecCoord,enabled) 0
      } else {
         set command [gets $channel ]
         disp "::sophie::testcontrol::readTelescopeCommandSocket command=$command\n"

         #--- je decoupe la commande en un tableau
         set commandArray [split $command]
         #--- je traite la commande
         switch [lindex $commandArray 0] {
            "!RADEC" {
               switch [lindex $commandArray 1] {
                  MOVE {
                     #---  je recupere la direction et la vitesse
                     set direction [lindex $commandArray 2]
                     set speedCode [lindex $commandArray 3]
                     set distance  [lindex $commandArray 4]
                     set returnCode [startRadecMove $direction $speedCode $distance]
                     set response [format "!RADEC MOVE %d %s @" $returnCode $direction ]
                     writeTelescopeCommandSocket $channel $response
                  }
                  STOP {
                     #---  je recupere la direction
                     set direction [lindex $commandArray 2]
                     set returnCode [stopRadecMove $direction]
                     set response [format "!RADEC STOP %d %s @" $returnCode $direction ]
                     writeTelescopeCommandSocket $channel $response
                  }
                  COORD {
                     switch [lindex $commandArray 2] {
                        "0" {
                           #--- j'arrete de l'envoi periodique des coordonnees
                           stopRadecCoord
                           #--- je retourne la reponse
                           set raHms  [mc_angle2hms $private(motor,ra) 360 zero 2 auto string]
                           set decDms [mc_angle2dms $private(motor,dec) 90 zero 2 + string]
                           set returnCode 0
                           set response [format "!RADEC COORD %d %s %s @" $returnCode $raHms $decDms ]
                           writeTelescopeCommandSocket $channel $response
                        }
                        "1" {
                           #--- je demarre l'envoi periodique des coordonnees (boucle infinie en tache de fond)
                           startRadecCoord
                           #--- je retourne la reponse
                           set returnCode 0
                           set raHms  [mc_angle2hms $private(motor,ra) 360 zero 2 auto string]
                           set decDms [mc_angle2dms $private(motor,dec) 90 zero 2 + string]
                           set response [format "!RADEC COORD %d %s %s @" $returnCode $raHms $decDms ]
                           writeTelescopeCommandSocket $channel $response
                           #--- envoi des coordonnees
                        }
                        "2" {
                           #--- je retourne les coordonnes immediatement dans la reponse
                           set returnCode 0
                           set raHms  [mc_angle2hms $private(motor,ra) 360 zero 2 auto string]
                           set decDms [mc_angle2dms $private(motor,dec) 90 zero 2 + string]
                           set response [format "!RADEC COORD %d %s %s @" $returnCode $raHms $decDms ]
                           writeTelescopeCommandSocket $channel $response
                        }
                     }
                  }
                  GOTO {
                     set returnCode [startRadecGoto [lindex $commandArray 2] [lindex $commandArray 3]]
                     #--- j'envoie le code retour
                     set raHms  [mc_angle2hms $private(motor,ra) 360 zero 2 auto string]
                     set decDms [mc_angle2dms $private(motor,dec) 90 zero 2 + string]
                     set response [format "!RADEC GOTO %d %s %s @" $returnCode $raHms $decDms ]
                     writeTelescopeCommandSocket $channel $response
                  }
                  SLEW {
                     set returnCode [setRadecSlew [lindex $commandArray 2] ]
                     #--- j'envoie le code retour
                     set response [format "!RADEC SLEW %d @" $returnCode ]
                     writeTelescopeCommandSocket $channel $response
                  }
                  default {
                     #--- j'envoie le code retour 99
                     set response [format "!RADEC [lindex $commandArray 1] 99 @" ]
                     writeTelescopeCommandSocket $channel $response
                     disp "::sophie::testcontrol::readTelescopeCommandSocket invalid [lindex $commandArray 1] command=$command\n"
                  }
               }
            }
            "!FOC" {
               disp "::sophie::testcontrol::readTelescopeCommandSocket invalid [lindex $commandArray 0] command=$command\n"
               #--- je retourne une erreur 19= NOT IMPLEMENTED
               set returnCode 19 ;
               set response [format "!RADEC COORD %d @" $returnCode ]
               writeTelescopeCommandSocket $channel $response
            }
            default {
               #--- j'envoie le code retour 99
               set returnCode 99
               set response [format "[lindex $commandArray 0] [lindex $commandArray 1] %d @" $returnCode ]
               writeTelescopeCommandSocket $channel $response
               disp "::sophie::testcontrol::readTelescopeCommandSocket invalid [lindex $commandArray 0] command=$command\n"
            }
         }
      }
   }]

   if { $catchError != 0 } {
      set response "!ERROR 1 \"$::errorInfo\" @"
      writeTelescopeCommandSocket $channel $response
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
proc ::sophie::testcontrol::writeTelescopeCommandSocket { channel response } {
   variable private

   disp "::sophie::testcontrol::writeTelescopeCommandSocket response=$response\n"
   #--- remarque la commande puts ajoute "\n" a la fin de la chaine
   puts $channel $response

}

#------------------------------------------------------------
# readTelescopeNotificationSocket
#   envoie une donne vers le PC de guidage
#
#------------------------------------------------------------
proc ::sophie::testcontrol::readTelescopeNotificationSocket { channel } {
   variable private

   set response [gets $private(telescopeControl,notificationSocket) ]
   disp "::sophie::testcontrol::readTelescopeNotificationSocket response=$response\n"
}

#------------------------------------------------------------
# writeTelescopeNotificationSocket
#   envoie une notitifaction au PC de guidage
# Exemple :
#  ::sophie::testcontrol::writeTelescopeNotificationSocket "!RADEC COORD 0 0 03h00m00.0s +44d59m59.0s @"
#
# @param notitifaction a envoyer
#------------------------------------------------------------
proc ::sophie::testcontrol::writeTelescopeNotificationSocket { notification } {
   variable private

   ###disp "::sophie::testcontrol::writeTelescopeNotificationSocket notification=$notification\n"
   puts $private(telescopeControl,writeNotificationSocket)  $notification

}

#------------------------------------------------------------
# startRadecCoord
#   demarre l'envoi des coordonnees au PC de guidage
#
# @param donnees a envoyer
#------------------------------------------------------------
proc ::sophie::testcontrol::startRadecCoord { } {
   variable private

   if { $private(radecCoord,enabled) == 0 } {
      set private(radecCoord,enabled) 1
      after 1000 ::sophie::testcontrol::sendRadecCoord
   }
}

#------------------------------------------------------------
# stopRadecCoord
#   arrete l'envoi des coordonnees au PC de guidage
#
# @param donnees a envoyer
#------------------------------------------------------------
proc ::sophie::testcontrol::stopRadecCoord { } {
   variable private
   set private(radecCoord,enabled) 0
}

#------------------------------------------------------------
# sendRadecCoord
#   envoie une donnee au PC de guidage
#
# @param donnees a envoyer
#------------------------------------------------------------
proc ::sophie::testcontrol::sendRadecCoord { } {
   variable private

   set raHms  [mc_angle2hms $private(motor,ra) 360 zero 2 auto string ]
   set decDms [mc_angle2dms $private(motor,dec) 90 zero 2 + string ]
   switch $private(motor,mode) {
      "NONE" {
         #--- le telescope n'est pas en mouvement (excepte le suivi)
         set moveCode 0
      }
      default {
         #--- le telescope est pas en mouvement
         set moveCode 1
      }
   }
   set returnCode 0
   set response [format "!RADEC COORD %d %s %s %s @" $returnCode $moveCode $raHms $decDms ]
   ###disp "sendRadecCoord response=$response\n"
   ::sophie::testcontrol::writeTelescopeNotificationSocket $response
   if { $private(radecCoord,enabled) == 1 } {
      #--- je lance une nouvelle iteration apres 1000 miliscondes
      after 1000 ::sophie::testcontrol::sendRadecCoord
   }
}

#------------------------------------------------------------
# setRadecSlew
#   change la vitess de suivi
#
# @param slewMode mode de suivi
#        - 0= pas de suivi,
#        - 1= suivi sideral
#        - 2= suivi lunaire
# @return code retour 0=OK , 1=Erreur
#------------------------------------------------------------
proc ::sophie::testcontrol::setRadecSlew { slewMode } {
   variable private

   switch $slewMode {
      0 -
      1 -
      2 {
         #--- je memorise la nouvelle vitesse de suivi
         set private(motor,slewMode) $slewMode
         set result 0
      }
      default {
         set result 1
      }
   }
   return $result
}


#------------------------------------------------------------
# startRadecMove
#   demarre un mouvement de moteur
#
# @param direction N S E W
# @param speedCode guidage ou centrage
# @param distance en arcsec
# @return code retour 0=OK , 1=Erreur
#------------------------------------------------------------
proc ::sophie::testcontrol::startRadecMove { direction speedCode distance} {
   variable private

   set catchError [ catch {

      if { $private(motor,mode) == "NONE" } {
         set speed $private(motor,$speedCode)

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

         if { $distance == 0 } {
            set private(motor,mode) "ILLIMITED_MOVE"
         } else {
            set private(motor,mode) "LIMITED_MOVE"
            #--- je calcule les coordonnees cibles
            switch $direction {
               "E" {
                  set private(target,ra) [expr $private(motor,ra) + $distance / 3600.0]
                  set private(target,dec) $private(motor,dec)
               }
               "W" {
                  set private(target,ra) [expr $private(motor,ra) - $distance / 3600.0]
                  set private(target,dec) $private(motor,dec)
               }
               "N" {
                  set private(target,ra) $private(motor,ra)
                  set private(target,dec) [expr $private(motor,dec) + $distance / 3600.0]
               }
               "S" {
                  set private(target,ra) $private(motor,ra)
                  set private(target,dec) [expr $private(motor,dec) - $distance / 3600.0]
               }
            }
         }
         set result 0
      } else {
         #--- le telescope est deja en mouvement
         set result 1
      }
   }]

   if { $catchError != 0 } {
      ::sophie::testcontrol::disp  "$::errorInfo \n"
      set result 1
   }

   return $result
}

#------------------------------------------------------------
# stopRadecMove
#   arrete un mouvement de moteur
#
# @param direction N S E W
#------------------------------------------------------------
proc ::sophie::testcontrol::stopRadecMove { direction } {
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
      "T" {
         set private(motor,raSpeed) 0
         set private(motor,decSpeed) 0
      }
   }
   if { $private(motor,raSpeed) == 0 && $private(motor,decSpeed) == 0 } {
      set private(motor,mode) "NONE"
   }

   return 0
}

#------------------------------------------------------------
# startRadecGoto
#   demarre un GOTO
#
# @param ra  ascension droite (format hms)
# @param dec declinaison (format dms)
# @return code retour
#    0=OK ,
#    1=goto deja en cours
#    1=sous l'horizon (moins de 10 degres de hauteur
#
#------------------------------------------------------------
proc ::sophie::testcontrol::startRadecGoto { ra dec } {
   variable private
   set result 0

   #--- je convertis les coordonnees en degres
   set ra [mc_angle2deg $ra]
   set dec [mc_angle2deg $dec]

   #--- je verifie que les coordonnees sont au dessus de l'horizon
   set now [clock format [clock seconds] -format "%Y %m %d %H %M %S" -gmt 1 ]
   set altazCoord [ mc_radec2altaz $ra $dec $private(observaterPosition) $now ]
   set azimuth    [ lindex $altazCoord 0 ]
   set elevation  [ lindex $altazCoord 1 ]

   disp "::sophie::testcontrol::startRadecGoto private(motor,mode)=$private(motor,mode) \n"
   if { $private(motor,mode) == "NONE" } {
      #--- je verifie que l'elevation est superieure a 10 degres
      if { $elevation != "" } {
         #--- je calcule le sens de deplacement en ascension droite
         if { $ra > $private(motor,ra) } {
            set private(goto,raSpeed) $private(motor,gotoSpeed)
         } else {
            set private(goto,raSpeed) [expr 0 - $private(motor,gotoSpeed)]
         }

         if { $dec > $private(motor,dec) } {
            set private(goto,decSpeed) $private(motor,gotoSpeed)
         } else {
            set private(goto,decSpeed) [expr 0 - $private(motor,gotoSpeed)]
         }

         #--- je memorise les coordonnes cibles
         set private(target,ra) $ra
         set private(target,dec) $dec

         set private(motor,mode) "GOTO"

      } else {
         set result
      }
   } else {
      set result 1
   }
   return $result
}

#------------------------------------------------------------
# simulateMotor
#   simule un mouvement de moteur en modifiant les coordonnes
#   toute les 500 millisecondes
#
#------------------------------------------------------------
proc ::sophie::testcontrol::simulateMotor { } {
   variable private

   set catchError [ catch {

      set now [clock milliseconds]

      #--- je calcule le delai ecoule depuis le debut du mouvement
      set delay [ expr double($now - $private(motor,clock)) / 1000.0]
      set private(motor,clock) $now

      switch $private(motor,mode) {
         "NONE" {
            #--- je simule le suivi en ascension droite (la declinaison n'est pas modifiee
            set private(motor,ra) [expr $private(motor,ra) + $delay * (15.0 - $private(motor,slewSpeed,$private(motor,slewMode)))  / 3600.0  ]
         }
         "ILLIMITED_MOVE" {
            #--- je simule le deplacement  illimitee
            set private(motor,ra) [expr $private(motor,ra) + $delay * ($private(motor,raSpeed) + (15.0 - $private(motor,slewSpeed,$private(motor,slewMode))))  / 3600.0  ]
            set private(motor,dec) [expr $private(motor,dec) + $delay * $private(motor,decSpeed)  / 3600.0  ]
         }
         "LIMITED_MOVE" {
            #--- je simule le deplacement limite
            if { [expr abs($private(motor,ra) - $private(target,ra)) > abs($delay * $private(motor,raSpeed) /3600.0) ] } {
               set private(motor,ra) [expr $private(motor,ra) + $delay * $private(motor,raSpeed) /3600.0 ]
            } else {
               set private(motor,ra) $private(target,ra)
            }
            if { [expr abs($private(motor,dec) - $private(target,dec)) > abs($delay * $private(motor,decSpeed) /3600.0) ] } {
               set private(motor,dec) [expr $private(motor,dec) + $delay * $private(motor,decSpeed) /3600.0 ]
            } else {
               set private(motor,dec) $private(target,dec)
            }
disp "simulateMotor delai=$delay ra=$private(motor,ra) dec=$private(motor,dec) target=$private(target,ra) $private(target,dec)\n"

            if { $private(motor,ra) == $private(target,ra) && $private(motor,dec) == $private(target,dec) } {
               #--- je memorise l'arret du MOVE
               set private(motor,mode) "NONE"
               #--- j'envoie une notification pour signaler que le GOTO est termine
               ::sophie::testcontrol::sendRadecCoord
            }
         }
         "GOTO" {
            #--- je simule le GOTO
            if { [expr abs($private(motor,ra) - $private(target,ra)) > abs($delay * $private(goto,raSpeed) /3600.0) ] } {
               set private(motor,ra) [expr $private(motor,ra) + $delay * $private(goto,raSpeed) /3600.0 ]
            } else {
               set private(motor,ra) $private(target,ra)
            }
            if { [expr abs($private(motor,dec) - $private(target,dec)) > abs($delay * $private(goto,decSpeed) /3600.0) ] } {
               set private(motor,dec) [expr $private(motor,dec) + $delay * $private(goto,decSpeed) /3600.0 ]
            } else {
               set private(motor,dec) $private(target,dec)
            }

            if { $private(motor,ra) == $private(target,ra) && $private(motor,dec) == $private(target,dec) } {
               #--- je memorise l'arret du GOTO
               set private(motor,mode) "NONE"
               #--- j'envoie une notification pour signaler que le GOTO est termine
               ::sophie::testcontrol::sendRadecCoord
            }
         }
      }

      ###disp "simulateMotor delai=$delay ra=$private(motor,ra) dec=$private(motor,ra) \n"

      #--- je met a jour la fenetre du simulateur
      ::sophie::testcontrol::updateGui

      set private(motor,afterId) [after 500 ::sophie::testcontrol::simulateMotor ]
   }]

   if { $catchError != 0 } {
      ::sophie::testcontrol::disp  "$::errorInfo \n"
   }
}


#------------------------------------------------------------
# configure
#   met a jour les parametres de configuration
#   cette procedure est appelee par le thread principal chaque fois qu'un parametre est modifie par l'utilisateur
# @param sideralSpeed   vitesse siderale (arsec/sec)
# @param lunarSpeed     vitesse lunaire (arsec/sec)
# @param guidingSpeed   vitesse des corrections de guidage (arsec/sec)
# @param centeringSpeed vitesse de centrage (arsec/sec)
# @param observaterPosition position de l'observateur au format "GPS 0.142300 E 42.936639 2890.5"
#------------------------------------------------------------
proc ::sophie::testcontrol::configure { sideralSpeed lunarSpeed guidingSpeed centeringSpeed gotoSpeed observaterPosition } {
   variable private

   set private(motor,slewSpeed,1)   $sideralSpeed
   set private(motor,slewSpeed,2)   $lunarSpeed
   set private(motor,guidage)       $guidingSpeed
   set private(motor,centrage)      $centeringSpeed
   set private(motor,gotoSpeed)     $gotoSpeed
   set private(observaterPosition)  $observaterPosition
}


#------------------------------------------------------------
# updateGui
#  envoie les valeurs courantes au thread principal pour les afficher dans la fenetre du simulateur
#  pour simuler la dérive du telescope par rapport au ciel
#------------------------------------------------------------
proc ::sophie::testcontrol::updateGui { } {
   variable private

   ::thread::send -async $private(mainThreadNo) \
      [list ::sophie::test::updateGui $private(motor,ra) $private(motor,dec) [expr $private(motor,raSpeed)+ $private(motor,slewSpeed,$private(motor,slewMode))]  $private(motor,decSpeed) $private(motor,slewMode) $private(motor,slewSpeed,$private(motor,slewMode)) ]
}




