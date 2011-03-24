#
# Mise à jour $Id$
#

#--------------------------------------------------
#
#  Structure du tabkey
#
# { {TELESCOP { {TELESCOP} {TAROT CHILI} string {Observatory name} } }
#   {NAXIS2   { {NAXIS2}   {1024}        int    {}                 } }
#    etc ...
# }
#
#--------------------------------------------------
#     0         1         2
#       0123456789012345678901
# date <2006-06-23T20:22:36.08>
#--------------------------------------------------

proc chg_tabkey { tabkey } {

   if {! [::bddimages_liste::lexist $tabkey "date-obs"]} {
      return [list 1 "????-??-??T??:??:??"] 
      }
   set line    [::bddimages_liste::lget $tabkey "date-obs"]
   set dateobs [lindex $line 1]

   if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $dateobs dateiso aa mm jj sep h m s sd] } {

      # Si date ISO
      set dateiso "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"

   } else {

      # Sinon
      set annee   [string range $dateobs 6 9]
      set mois    [string range $dateobs 3 4]
      set jour    [string range $dateobs 0 1]
      
      
      if {! [catch { ::bddimages_liste::lget $tabkey "tm-start" } duree ] } { 
         return [list 1 "${annee}-${mois}-${jour}T??:??:??"]
         }

      set heure   [expr int($duree / 3600.)]
      set minute  [expr int($duree / 60. - $heure * 60.)]
      set seconde [expr $duree - $heure * 3600 - $minute * 60.]
      set dateiso "$annee-$mois-$jour\T$heure:$minute:$seconde"

   }

   set tabkey [ ::bddimages_liste::lupdate $tabkey "date-obs" $dateiso ]

   if {! [::bddimages_liste::lexist $tabkey "exposure"]} {
      set line     [::bddimages_liste::lget $tabkey "tm-expos"]
      set exposure [lreplace $line 0 0 "EXPOSURE"]
      set tabkey [::bddimages_liste::ladd $tabkey "exposure" $exposure]
   }

   return [list 0 $tabkey]
}

