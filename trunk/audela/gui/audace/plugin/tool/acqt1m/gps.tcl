#
# Fichier : gps.tcl
# Description : Pilotage de la datation GPS
# Auteur : Frederic Vachier
# Mise à jour $Id$
#
# source audace/plugin/tool/acqt1m/gps.tcl
#

#============================================================
# Declaration du namespace bddimages
#    initialise le namespace
#============================================================
namespace eval ::gps {

   variable flag
   variable sync
   variable flagsync
   variable antenna
   variable flagantenna







   proc ::gps::open { } {

      gren_info "GPS::OPEN\n"
      set r [meinberg_gps open]
      set e [split $r ";"]
      #::console::affiche_resultat "r = $r\n"
      #::console::affiche_resultat "e = $e\n"
      #gren_info "r0 = [lindex $r 0]\n"
      foreach a $e {
         gren_info "O:$a\n"
      }

      set ::gps::flag 0
      set s [string first "Antenna is connected" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Antenna is not connected\n"
         set ::gps::antenna        "Antenna is not connected"
         set ::gps::flagantenna    0
         return 1
      } else {
         set ::gps::antenna      "Antenna is connected"
         set ::gps::flagantenna  1
      }

      set s [string first "Time is synchronized" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Time not synchronized\n"
         set ::gps::sync        "Time not synchronized"
         set ::gps::flagsync    0
         return 1
      } else {
         set ::gps::sync        "Time is synchronized"
         set ::gps::flagsync    1
      }
      # reset buffer
      set r [meinberg_gps reset]
      ::console::affiche_resultat "reset => $r\n"
      set s [string first "Capture buffer cleared for meinberg" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Buffer not cleared\n"
         return 1
      }
      set ::gps::flag 1
      gren_info "GPS::OPEN END\n\n"

      return 0
   }







   proc ::gps::read { } {

      set result [ catch { set r [meinberg_gps read] } msg ]
      if { $result == "1" } {
         ::console::disp "meinberg_gps read error=$msg \n"
         return ERROR
      } else {
         #::console::disp "meinberg_gps read OK\n"
      }

      set e [split $r ";"]
      #foreach a $e {
      #   gren_info "R:$a\n"
      #}
      set date [lindex $e 0]

      set ::gps::flag 0
      set s [string first "Antenna is connected" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Antenna is not connected\n"
         set ::gps::antenna        "Antenna is not connected"
         set ::gps::flagantenna    0
      } else {
         set ::gps::antenna      "Antenna is connected"
         set ::gps::flagantenna  1
      }

      set s [string first "Time is synchronized" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Time not synchronized\n"
         set ::gps::sync        "Time not synchronized"
         set ::gps::flagsync    0
      } else {
         set ::gps::sync        "Time is synchronized"
         set ::gps::flagsync    1
      }
      if { $::gps::flagsync == 1 && $::gps::flagantenna == 1} { set ::gps::flag 1 }
      return $date
   }






   proc ::gps::getdate { exposure bufNo } {

      global tcl_precision

      set tcl_precision 17
      set log 0

      # Recupere la date GPS
      set dategps   [::gps::read]

      if {$log} {gren_info "dategps=$dategps\n"}

      if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $dategps dateiso aa mm jj sep h m s sd] } {
         # Si date ISO
         set dateend "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"
         set datepc  [ lindex [ buf$bufNo getkwd DATE-OBS ] 1 ]
         set dategpsendjd   [ mc_date2jd $dateend ]
         set dategpsbegjd [expr $dategpsendjd - double($exposure)/86400.0]
         set datepcbegjd    [ mc_date2jd $datepc ]
         set dateobs        [ mc_date2iso8601 $dategpsbegjd ]
         set gpspc          [format "%.3f" [ expr ($dategpsbegjd - $datepcbegjd)*86400. ]]

      } else {
         set datepc   [ lindex [ buf$bufNo getkwd DATE-OBS ] 1 ]
         set dateobs  $datepc
         set dateend  [ lindex [ buf$bufNo getkwd DATE-END ] 1 ]
         set dategps "unknown"
         set ::gps::flag 0
         set gpspc       -99999
      }


      if {$log} {
         gren_info "** HEADER \n"
         gren_info "EXPOSURE=$exposure         \n"
         gren_info "DATE-OBS=$dateobs          \n"
         gren_info "DATE-END=$dateend          \n"
         gren_info "DATE-PC =$datepc           \n"
         gren_info "DATE-GPS=$dategps          \n"
         gren_info "FLAG-GPS=$::gps::flag          \n"
         gren_info "GPS-PC  =$gpspc            \n"
         if {[info exists ::gps::antenna]}     {gren_info "GPS-ANTE=$::gps::antenna   \n"}
         if {[info exists ::gps::sync]}        {gren_info "GPS-SYNC=$::gps::sync      \n"}
         if {[info exists ::gps::flagantenna]} {gren_info "GPS-FANT=$::gps::flagantenna   \n"}
         if {[info exists ::gps::flagsync]}    {gren_info "GPS-FSYN=$::gps::flagsync      \n"}
      }

      buf$bufNo setkwd [list DATE-OBS $dateobs      string  "Begining date of the observation"                     "Date ISO8601"]
      buf$bufNo setkwd [list DATE-END $dateend      string  "End date of the observation"                          "Date ISO8601"]
      buf$bufNo setkwd [list DATE-PC  $datepc       string  "Begining date of the observation from Computer Clock" "Date ISO8601"]
      buf$bufNo setkwd [list DATE-GPS $dategps      string  "Begining date of the observation from GPS Clock"      "Date ISO8601"]
      buf$bufNo setkwd [list GPS-FLAG $::gps::flag  boolean "flag = 1 if GPS datation is valid, 0 otherwise"       none]
      buf$bufNo setkwd [list GPS-PC   $gpspc        double  "difference between GPS Clock and Computer Clock"      second]
      if {[info exists ::gps::antenna]}     {buf$bufNo setkwd [list GPS-ANTE $::gps::antenna      string  "Status of GPS Antenna" ""]}
      if {[info exists ::gps::sync]}        {buf$bufNo setkwd [list GPS-SYNC $::gps::sync         string  "Status of GPS Synchronization" ""]}
      if {[info exists ::gps::flagantenna]} {buf$bufNo setkwd [list GPS-FANT $::gps::flagantenna  boolean  "flag = 1 if GPS Antenna is connected, 0 otherwise" ""]}
      if {[info exists ::gps::flagsync]}    {buf$bufNo setkwd [list GPS-FSYN $::gps::flagsync     boolean  "flag = 1 if GPS Time is synchronized, 0 otherwise" ""]}
      buf$bufNo delkwd GPS-DATE

      return $::gps::flag
   }


# Fin NameSpace
}

