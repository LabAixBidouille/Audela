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

      set result [ catch { set r [meinberg_gps read2dates] } msg ]

      if { $result == "1" } {
         ::console::disp "meinberg_gps read error=$msg \n"
         return ERROR
      } else {
         #::console::disp "meinberg_gps read OK\n"
      }
      #::console::disp "result = $r\n"

      set e [split $r ";"]

      if {1==0} {
         foreach a $e {
            gren_info "R:$a\n"
         }
      }

      set dateend [lindex $e 0]
      if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $dateend dateiso aa mm jj sep h m s sd] } {
         # ok on a une date iso
         
      } else {
         set dateend 0
      }
      
      set datebeg [lindex $e 1]

      if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $datebeg dateiso aa mm jj sep h m s sd] } {
         # ok on a une date iso
         
      } else {
         set datebeg 0
      }
      
      set date [list $dateend $datebeg]

      set ::gps::flag 0

      set s [string first "No GPS date available" $r]
      if { $s!=-1 } {
         ::console::affiche_erreur "No GPS date available\n"
         set date [list 0 0]
      } 
      
#      set result [ catch { set r [meinberg_gps status] } msg ]
#      if { $result == "1" } {
#         ::console::disp "meinberg_gps status error=$msg \n"
#         return ERROR
#      } 

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

      set log 0

      # Recupere la date GPS la premiere date est la date de fermeture de l obturateur
      set dategps [::gps::read]
      
      set date_iso_gps_end [lindex $dategps 0]
      set date_iso_gps_beg [lindex $dategps 1]

      if {$log} {gren_info "dategps=$dategps\n"}

      set date_iso_pc_beg [ lindex [ buf$bufNo getkwd DATE-OBS ] 1 ]
      set date_jda_pc_beg [ mc_date2jd $date_iso_pc_beg ]
      set date_iso_pc_end [ lindex [ buf$bufNo getkwd DATE-END ] 1 ]
      set date_jda_pc_end [ mc_date2jd $date_iso_pc_end ]



      if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $date_iso_gps_end dateiso aa mm jj sep h m s sd] } {
         set date_iso_gps_end "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"
         set date_jda_gps_end [ mc_date2jd $date_iso_gps_end ]
         set pass_end 1
      } else {
         set pass_end 0
      }



      if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $date_iso_gps_beg dateiso aa mm jj sep h m s sd] } {
         set date_iso_gps_beg "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"
         set date_jda_gps_beg [ mc_date2jd $date_iso_gps_beg ]
         set dategps $date_iso_gps_beg
         set pass_beg 1
      } else {
         set pass_beg 0
      }

      if {$pass_beg && $pass_end} {

         set diff [expr abs($date_jda_gps_end - $date_jda_gps_beg)*86400.0]
         if {$diff<0.001} {
            set pass_beg 0
         } 
         if {abs($diff - $exposure)<0.001} {
            set pass_beg 1
            set pass_end 1
         } 
         if {abs($diff - $exposure)>0.001 && $diff>0.001} {
            set pass_beg 0
            set pass_end 0
         }
      }

      if {$pass_beg == 1 && $pass_end == 1 } {
         set dateobs $date_iso_gps_beg
         set dateend $date_iso_gps_end
         set ::gps::flag 2
         set gpspc [format "%.3f" [ expr ($date_jda_gps_beg - $date_jda_pc_beg)*86400. ]]
         
         # set exposure [format "%.6f" [ expr ($date_jda_gps_end - $date_jda_gps_beg)*86400. ]]
         # gren_info "Expo = $exposure \n"
         # buf$bufNo setkwd [list EXPOSURE $exposure double  "New Exposure Time by GPS estimation" "second"]
      } 

      if {$pass_beg == 1  && $pass_end == 0 } {
         set dateobs $date_iso_gps_beg
         set dateend [expr $date_jda_gps_beg + double($exposure)/86400.0]
         set ::gps::flag 1
         set gpspc [format "%.3f" [ expr ($date_jda_gps_beg - $date_jda_pc_beg)*86400. ]]
      } 
      
      if {$pass_beg == 0 && $pass_end == 1 } {
         set date_jda_gps_beg [expr $date_jda_gps_end - double($exposure)/86400.0]
         set dateobs [ mc_date2iso8601 $date_jda_gps_beg ]
         set dateend $date_iso_gps_end
         set ::gps::flag 1
         set dategps $dateobs
         set gpspc [format "%.3f" [ expr ($date_jda_gps_end - $date_jda_pc_end)*86400. ]]
      } 

      if {$pass_beg == 0  && $pass_end == 0 } {
         set ::gps::flag 0
         set gpspc   -99999
         set dategps "unknown"
         set dateobs $date_iso_pc_beg     
         set dateend $date_iso_pc_end
      } 


      if {$log} {
         gren_info "** HEADER \n"
         gren_info "EXPOSURE=$exposure         \n"
         gren_info "DATE-OBS=$dateobs          \n"
         gren_info "DATE-END=$dateend          \n"

         gren_info "DATE-PC =$date_iso_pc_beg  \n"
         gren_info "DATE-GPS=$dategps          \n"

         gren_info "FLAG-GPS=$::gps::flag      \n"
         gren_info "GPS-PC  =$gpspc            \n"
         if {[info exists ::gps::antenna]}     {gren_info "GPS-ANTE=$::gps::antenna   \n"}
         if {[info exists ::gps::sync]}        {gren_info "GPS-SYNC=$::gps::sync      \n"}
         if {[info exists ::gps::flagantenna]} {gren_info "GPS-FANT=$::gps::flagantenna   \n"}
         if {[info exists ::gps::flagsync]}    {gren_info "GPS-FSYN=$::gps::flagsync      \n"}
      }

      buf$bufNo setkwd [list DATE-OBS $dateobs         string  "Begining date of the observation"                     "Date ISO8601"]
      buf$bufNo setkwd [list DATE-END $dateend         string  "End date of the observation"                          "Date ISO8601"]
      buf$bufNo setkwd [list DATE-PC  $date_iso_pc_beg string  "Beginning date of the observation from Computer Clock" "Date ISO8601"]
      buf$bufNo setkwd [list DATE-GPS $dategps         string  "Beginning date of the observation from GPS Clock"      "Date ISO8601"]
      buf$bufNo setkwd [list GPS-FLAG $::gps::flag     boolean "0 no gps, 1 one event, 2 begin and end exposure gps datation"       none]
      buf$bufNo setkwd [list GPS-PC   $gpspc           float   "Difference between GPS Clock and Computer Clock"      second]
      if {[info exists ::gps::antenna]}     {buf$bufNo setkwd [list GPS-ANTE $::gps::antenna      string  "Status of GPS Antenna" ""]}
      if {[info exists ::gps::sync]}        {buf$bufNo setkwd [list GPS-SYNC $::gps::sync         string  "Status of GPS Synchronization" ""]}
      if {[info exists ::gps::flagantenna]} {buf$bufNo setkwd [list GPS-FANT $::gps::flagantenna  boolean  "flag = 1 if GPS Antenna is connected, 0 otherwise" ""]}
      if {[info exists ::gps::flagsync]}    {buf$bufNo setkwd [list GPS-FSYN $::gps::flagsync     boolean  "flag = 1 if GPS Time is synchronized, 0 otherwise" ""]}
      buf$bufNo delkwd GPS-DATE

      return $::gps::flag
   }

# Fin NameSpace
}

