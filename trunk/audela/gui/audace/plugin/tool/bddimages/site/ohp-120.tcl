#
# Mise à jour $Id$
#

proc chg_tabkey { tabkey } {

   #     0         1         2
   #       0123456789012345678901
   # date <2006-06-23T20:22:36.08>

   if {! [catch { get_tabkey $tabkey "DATE-OBS" } dateobs ] } { 
      return [list 1 "????-??-??T??:??:??"] 
      }
      
   if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $dateobs dateiso aa mm jj sep h m s sd] } {

      # Si date ISO
      set dateiso "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"

   } else {

      # Sinon
      set annee   [string range $dateobs 6 9]
      set mois    [string range $dateobs 3 4]
      set jour    [string range $dateobs 0 1]
      
      
      if {! [catch { get_tabkey $tabkey "TM-START" } duree ] } { 
         return [list 1 "${annee}-${mois}-${jour}T??:??:??"]
         }

      set heure   [expr int($duree / 3600.)]
      set minute  [expr int($duree / 60. - $heure * 60.)]
      set seconde [expr $duree - $heure * 3600 - $minute * 60.]
      set dateiso "$annee-$mois-$jour\T$heure:$minute:$seconde"

   }

   set tabkey [ update_tabkey $tabkey "DATE-OBS" $dateiso ]

   if {! [exist_tabkey $tabkey "EXPOSURE"]} {
      set exposure [get_tabkey $tabkey "TM-EXPOS"]      
      set tabkey [add_tabkey $tabkey "EXPOSURE" $exposure]
   }

   return [list 0 $tabkey]
}

