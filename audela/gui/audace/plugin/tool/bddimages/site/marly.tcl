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

proc chg_tabkey {tabkey} {

   if {! [::bddimages_liste::lexist $tabkey "date-obs"]} {
      return [list 1 "????-??-??T??:??:??"] 
   }
   set dateobs [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]

   if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $dateobs dateiso aa mm jj sep h m s sd] } {

      # Si date ISO
      set dateiso "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"

   } else {

      # Sinon
      set annee   [expr [string range $dateobs 6 9] + 1900]
      set mois    [string range $dateobs 3 4]
      set jour    [string range $dateobs 0 1]
      
      if {! [::bddimages_liste::lexist $tabkey "tu-start"]} {
         return [list 1 "${annee}-${mois}-${jour}T??:??:??"]
      }
      set heurobs [lindex [::bddimages_liste::lget $tabkey "tu-start"] 1]
      set dateiso "$annee-$mois-${jour}T$heurobs"

   }

   set l_dateiso [list "date-obs" $dateiso "string" "" ""]
   set tabkey [ ::bddimages_liste::lupdate $tabkey "date-obs" $l_dateiso ]

   return [list 0 $tabkey]
}

