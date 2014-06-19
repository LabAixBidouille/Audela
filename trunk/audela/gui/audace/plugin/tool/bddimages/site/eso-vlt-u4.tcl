#
# Mise à jour $Id: eso-vlt-u4.tcl 8220 2012-04-12 13:30:11Z jberthier $
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
      set annee [string range $dateobs 6 9]
      set mois  [string range $dateobs 3 4]
      set jour  [string range $dateobs 0 1]

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

   # RA
   if {! [::bddimages_liste::lexist $tabkey "ra"]} {
      set ra [lindex [::bddimages_liste::lget $tabkey "POSTN-RA"] 1]
      set tabkey [::bddimages_liste::ladd $tabkey "ra" [list RA $ra double "RA J2000.0" "deg"]]
   }

   # DEC
   if {! [::bddimages_liste::lexist $tabkey "dec"]} {
      set dec [lindex [::bddimages_liste::lget $tabkey "POSTN-DE"] 1]
      set tabkey [::bddimages_liste::ladd $tabkey "dec" [list DEC $dec double "DEC J2000.0" "deg"]]
   }

   # FOCLEN
   if {! [::bddimages_liste::lexist $tabkey "foclen"]} {
      set foclen 7.2
      set tabkey [::bddimages_liste::ladd $tabkey "foclen" [list FOCLEN $foclen double "Focal length" "m"]]
   }

   # PIXSIZE1
   if {! [::bddimages_liste::lexist $tabkey "pixsize1"]} {
      set pixsize1 24
      set tabkey [::bddimages_liste::ladd $tabkey "pixsize1" [list PIXSIZE1 $pixsize1 double "Pixel dimension" "m"]]
   }

   # PIXSIZE2
   if {! [::bddimages_liste::lexist $tabkey "pixsize2"]} {
      set pixsize2 24
      set tabkey [::bddimages_liste::ladd $tabkey "pixsize2" [list PIXSIZE2 $pixsize2 double "Pixel dimension" "m"]]
   }

   
   
   
#   set fullname [lindex $files $k]
#   set dirname [file dirname $fullname]
#   set tail [file tail $fullname]
#   set shortname [file rootname $tail]
#   set fullname2 ${dirname}/c_${shortname}${extout}
#   
#::console::affiche_resultat "::OhpT120::convert: processing $fullname -> $fullname2 \n"
#
#   catch {file copy -force $fullname $fullname2}
#   buf$audace(bufNo) load $fullname2
#   set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
#   set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
#   catch {buf$audace(bufNo) delkwd COMMENT=}
#   set pixsize 24e-6
#   set foclen 7.2
#   set crota 0.
#   set cdelt [expr $pixsize/$foclen*180./$pi]
#   buf$audace(bufNo) setkwd [list PIXSIZE1 $pixsize double "Pixel dimension" "m"]
#   buf$audace(bufNo) setkwd [list PIXSIZE2 $pixsize double "Pixel dimension" "m"]
#   buf$audace(bufNo) setkwd [list FOCLEN  $foclen    double "Focal length" "m"]
#   buf$audace(bufNo) setkwd [list CDELT1 [expr -$cdelt] double "X scale" "deg/pix"]
#   buf$audace(bufNo) setkwd [list CDELT2 $cdelt double "Y scale" "deg/pix"]
#   buf$audace(bufNo) setkwd [list CROTA2 $crota double "" "deg"]
#   buf$audace(bufNo) setkwd [list CRPIX1 [expr $naxis1/2] double "" "pix"]
#   buf$audace(bufNo) setkwd [list CRPIX2 [expr $naxis2/2] double "" "pix"]
#   set date_obs [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]
#   set kk [string first T $date_obs]
#   if {$kk<0} {
#      set jour [string range $date_obs 0 1]
#      set mois [string range $date_obs 3 4]
#      set annee [string range $date_obs 6 9]
#      set instant [lindex [buf$audace(bufNo) getkwd TM-START] 1]
#      set instant [mc_angle2hms [expr $instant/240.]]
#      set heure [format %02d [lindex $instant 0]]
#      set minute [format %02d [lindex $instant 1]]
#      set seconde [format %05.2f [lindex $instant 2]]
#      set date_obs ${annee}-${mois}-${jour}T${heure}:${minute}:${seconde}
#      buf$audace(bufNo) setkwd [list DATE-OBS $date_obs string "debut de pose" "iso8601"]
#      set exposure [lindex [buf$audace(bufNo) getkwd TM-EXPOS] 1]
#      buf$audace(bufNo) setkwd [list EXPOSURE $exposure float "duree de pose" "s"]
#      set ra [lindex [buf$audace(bufNo) getkwd POSTN-RA] 1]
#      set dec [lindex [buf$audace(bufNo) getkwd POSTN-DE] 1]
#   } else {
#      set exposure [lindex [buf$audace(bufNo) getkwd EXPTIME] 1]
#      buf$audace(bufNo) setkwd [list EXPOSURE $exposure float "duree de pose" "s"]
#   }
#   buf$audace(bufNo) setkwd [list RA $ra double "RA J2000.0" "deg"]
#   buf$audace(bufNo) setkwd [list DEC $dec double "DEC J2000.0" "deg"]
#   buf$audace(bufNo) setkwd [list CRVAL1 $ra double "" "deg"]
#   buf$audace(bufNo) setkwd [list CRVAL2 $dec double "" "deg"]
#   buf$audace(bufNo) save $fullname2

   return [list 0 $tabkey]
}
