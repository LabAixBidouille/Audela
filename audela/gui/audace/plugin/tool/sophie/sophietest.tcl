#
# Fichier : sophie.tcl
# Description : Outil d'autoguidage pour le spectro Sophie du telescope T193 de l'OHP
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: sophietest.tcl,v 1.2 2009-05-11 13:44:13 michelpujol Exp $
#

#------------------------------------------------------------
# test lenvoie les coordonnees toutes le secondes
#------------------------------------------------------------
proc ::sophie::testhp { } {
   variable private

   set private(testhp) 0

   # je lance l'envoi permanent des coordonnees sur le port COM5
   set private(writeHpHandle) [open COM7 "r+" ]
   fconfigure $private(writeHpHandle) -mode "19200,n,8,1" -buffering none -blocking 0

   # j'ouvre le port de reception des coordonnees
   set private(readHpHandle) [open COM8 "r+" ]
   fconfigure $private(readHpHandle) -mode "19200,n,8,1" -buffering none -blocking 0

   set private(testhp) 1
   after 1000 ::sophie::testWriteHp
   after 1500 ::sophie::testReadHp

}

proc ::sophie::stophp { } {
   variable private

   set private(testhp) 0

   if { $private(writeHpHandle) != "" } {
      close $private(writeHpHandle)
      set private(writeHpHandle) ""
   }

  if { $private(readHpHandle) != "" } {
      close $private(readHpHandle)
      set private(readHpHandle) ""
   }

}

#------------------------------------------------------------
# testWriteHp
#    envoie les coordonnees toutes le secondes
#------------------------------------------------------------
proc ::sophie::testWriteHp { } {
   variable private

   set data "02h 06m 47.87s / -13d 44' 28\" /   -1d"
   if { $private(testhp) == 1 } {
      puts  $private(writeHpHandle) $data
console::disp "testWriteHp data=$data\n"
     after 2000 ::sophie::testWriteHp
   } else {

     if { $private(writeHpHandle) != "" } {
         close $private(writeHpHandle)
         set private(writeHpHandle) ""
      }
   }
}

#------------------------------------------------------------
# testReadHp
#    lit  les coordonnees toutes les 3 secondes
#------------------------------------------------------------
proc ::sophie::testReadHp { } {
   variable private

   if { $private(testhp) == 1 } {
      set data [read -nonewline $private(readHpHandle)]
      set data [split $data "\n" ]
      set messageNb [llength $data]
      console::disp "\ntestReadHp nb=$messageNb data=$data\n"
      set data [lindex $data end]
      if { $data != "" } {
         scan $data "#%2dh%2x%2x" r g b
         set  [ format "%02dh%02dm%02ds" $h $m $sec);
         console::disp "\ntestReadHp nb=$messageNb data=$data\n"
      }
      after 4000 ::sophie::testReadHp
   } else {
     if { $private(readHpHandle) != "" } {
         close $private(readHpHandle)
         set private(readHpHandle) ""
      }
   }
}



#----------
# tests de la fentre de controle
#-----------------

proc ::sophie::ta1 { }  {
   ::sophie::control::setAcquisitionState { 1 }
}

proc ::sophie::ta2 { }  {
   ::sophie::control::setAcquisitionState { 0 }
}


proc ::sophie::tc1 { } {
   ####          starDetection fiberDetection originX originY starX starY fwhmX fwhmY background maxFlow
   ::sophie::control::setCenterInformation 1 1 750 512 752 514 45 46 100 10000

}





