#
# Fichier : sophiespectro.tcl
# Description : interface avec le PC du spectrographe Sophie
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: sophiespectro.tcl,v 1.1 2009-06-13 23:59:16 michelpujol Exp $
#

#============================================================
# Declaration du namespace sophie::spectro
#    initialise le namespace
#============================================================
namespace eval ::sophie::spectro {
   variable private

   set private(socketHandle)  ""
}

#------------------------------------------------------------
# openSocket
#    connexion au PC du spectrographe Sophie
#
#
#------------------------------------------------------------
proc ::sophie::spectro::openSocket { callbackProc } {
   variable private


   if { $private(socketHandle) != "" } {
      #--- je ferme la socket si elle etait deja ouverte
      closeSocket
   }

   #--- j'ouvre la socket en reception
   set private(socketHandle) [socket -server ::sophie::spectro::acceptSocket $::conf(sophie,socketPort) ]
console::disp "::sophie::spectro::openSocket  OK channel=$private(socketHandle)\n"
}

#------------------------------------------------------------
# acceptSocket
#    configure la socket apres son ouverture
#
# @param channel
# @param address
# @param port
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

#------------------------------------------------------------
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

#------------------------------------------------------------
# acceptSocket
#    deuxieme etape de l'ouverture de la socket
#
#
#------------------------------------------------------------
proc ::sophie::spectro::readSocket { channel } {
   variable private

   if {[eof $channel ]} {
     ::console::disp "::sophie::spectro::readSocket close channel=$channel \n"
     close $channel
   } else {
      ###gets $channel data
      set data [read -nonewline $channel]
      ::console::disp "::sophie::spectro::readSocket read channel=$channel data=$data\n"

      switch $data {
         "!STAT_ON@" {
            ::sophie::startStatistics
         }
         "!STAT_OFF@" {
            ::sophie::stopStatistics
         }
         "!GET_STAT@" {
            set resultArray [::sophie::getStatistics ]

            #--- A<20h>=<20h><20h><20h>2.68<20h><20h>Arms<20h>=<20h><20h>83.17<20h>D<20h>=<20h><20h><20h>2.74<20h>Drms<20h>=<20h>177.85<20h>
            set resultString [format "A = %5.2f  Arms = %5.2f D = %5.2f Drms = %5.2f " \
               [lindex $resultArray 0] [lindex $resultArray 1] \
               [lindex $resultArray 2] [lindex $resultArray 3] \
            ]
::console::disp "::sophie::spectro::readSocket resultString=$resultString\n"
            puts $channel $resultString
         }
         "!RAZ_STAT@" {
            #--- ne fait rien car le statistiques sont remises a zéro par ::sophie::startStatistics
         }
         default {
            console::affiche_erreur "::sophie::spectro::readSocket invalid data=$data\n"
         }
      }

      #--- je retourne une réponse"
      ###puts -nonewline $channel "reponse OK!"
   }
}

::sophie::spectro::openSocket  ""