#
# Mise à jour $Id$
#

proc chg_tabkey {tabkey} {

   #     0         1         2
   #       0123456789012345678901
   # date <2006-06-23T20:22:36.08>

   foreach keyval $tabkey {

      set key [lindex $keyval 0]
      set val [lindex [lindex $keyval 1] 1]

      switch $key {
         "DATE-OBS" {
            set dateobs [string trim $val]
         }
         "TU-START" {
            set heurobs [string trim $val]
         }
         default {
         }
      }
      # fin switch
   }
   # fin foreach

   set annee   [expr [string range $dateobs 6 9] + 1900]
   set mois    [string range $dateobs 3 4]
   set jour    [string range $dateobs 0 1]
   set dateiso "$annee-$mois-${jour}T$heurobs"

   return [list 0 $dateiso]
}

