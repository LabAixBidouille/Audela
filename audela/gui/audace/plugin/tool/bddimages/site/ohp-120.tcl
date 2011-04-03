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

   # DATE-OBS
   if {! [::bddimages_liste::lexist $tabkey "date-obs"]} {
      return [list 1 "????-??-??T??:??:??"] 
   }
   set dateobs [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]

   if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $dateobs dateiso aa mm jj sep h m s sd] } {

      # Si date ISO
      set dateiso "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"

   } else {

      # Sinon
      set annee   [string range $dateobs 6 9]
      set mois    [string range $dateobs 3 4]
      set jour    [string range $dateobs 0 1]

      if {! [::bddimages_liste::lexist $tabkey "tm-start"]} {
         return [list 1 "${annee}-${mois}-${jour}T??:??:??"]
      }
      
      set duree [lindex [::bddimages_liste::lget $tabkey "tm-start"] 1]
      set heure [expr int($duree/3600.)]
      set minute [expr int($duree/60. - $heure*60.)]
      set seconde [expr int($duree - $heure*3600. - $minute*60.)]
      set millisec [expr int((($duree - $heure*3600. - $minute*60.) - $seconde)*100)]
      if {$millisec == 0} {
         set dateiso [format "%04d-%02d-%02dT%02d:%02d:%02d.00" $annee $mois $jour $heure $minute $seconde]
      } else {
         set dateiso [format "%04d-%02d-%02dT%02d:%02d:%02d.%2d" $annee $mois $jour $heure $minute $seconde $millisec]
      }

   }
   set l_dateiso [list "date-obs" $dateiso "string" "" ""]
   set tabkey [ ::bddimages_liste::lupdate $tabkey "date-obs" $l_dateiso ]

   # EXPOSURE
   if {! [::bddimages_liste::lexist $tabkey "exposure"]} {
      set line [::bddimages_liste::lget $tabkey "tm-expos"]
      set exposure [lreplace $line 0 0 "EXPOSURE"]
      set tabkey [::bddimages_liste::ladd $tabkey "exposure" $exposure]
   }

   # BIN1
   if {! [::bddimages_liste::lexist $tabkey "bin1"]} {
      set b [::bddimages_liste::lget $tabkey "binx"]
      set tabkey [::bddimages_liste::ladd $tabkey "bin1" $b]
   }

   # BIN2
   if {! [::bddimages_liste::lexist $tabkey "bin2"]} {
      set b [::bddimages_liste::lget $tabkey "biny"]
      set tabkey [::bddimages_liste::ladd $tabkey "bin2" $b]
   }

   # FILTER
   if {! [::bddimages_liste::lexist $tabkey "filter"]} {
      set f [::bddimages_liste::lget $tabkey "fltrnm"]
      set tabkey [::bddimages_liste::ladd $tabkey "filter" $f]
   }

   return [list 0 $tabkey]
}
