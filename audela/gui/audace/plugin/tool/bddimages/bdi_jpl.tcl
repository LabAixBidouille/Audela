#--------------------------------------------------
# source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/bdi_jpl.tcl
#--------------------------------------------------
#
# Fichier        : bdi_jpl.tcl
# Description    : Calcul des ephemerides JPL
# Auteur         : J. Berthier <berthier@imcce.fr> et F. Vachier <fv@imcce.fr>
# Mise à jour $Id: bdi_tools.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#
namespace eval ::bdi_jpl {
   package provide bdi_jpl 1.0

   variable destinataire "horizons@ssd.jpl.nasa.gov"
   variable subject "JOB"


   proc ::bdi_jpl::create { object_name iau_code reply_mail } {

      gren_info "Object : $object_name\n"

      set jpl_cmd "!\$\$SOF\n"
      append jpl_cmd "EMAIL_ADDR= '$reply_mail'\n"
      append jpl_cmd "COMMAND= '$object_name;'\n"
      append jpl_cmd "CENTER= '$iau_code@399'\n"
      append jpl_cmd "MAKE_EPHEM= 'YES'\n"
      append jpl_cmd "TABLE_TYPE= 'OBSERVER'\n"
      append jpl_cmd "TLIST=\n"
      foreach {name y} [array get listscience] {
         if {$name != $object_name} { continue }
         foreach dateimg $listscience($name) {
            
            set resultmp [::gui_astrometry::get_data_report $name $dateimg]
            
            set midexpo  [lindex $resultmp 0]
            if {$midexpo == -1} { continue }
            set datejj  [format "%.9f"  [ expr [ mc_date2jd $dateimg] + $midexpo / 86400. ] ]
            append jpl_cmd  "'$datejj'\n"
         }
      }
      append jpl_cmd "CAL_FORMAT= 'JD'\n"
      append jpl_cmd "TIME_DIGITS= 'FRACSEC'\n"
      append jpl_cmd "ANG_FORMAT= 'DEG'\n"
      append jpl_cmd "OUT_UNITS= 'KM-S'\n"
      append jpl_cmd "RANGE_UNITS= 'AU'\n"
      append jpl_cmd "APPARENT= 'AIRLESS'\n"
      append jpl_cmd "SOLAR_ELONG= '0,180'\n"
      append jpl_cmd "SUPPRESS_RANGE_RATE= 'NO'\n"
      append jpl_cmd "SKIP_DAYLT= 'NO'\n"
      append jpl_cmd "EXTRA_PREC= 'YES'\n"
      append jpl_cmd "R_T_S_ONLY= 'NO'\n"
      append jpl_cmd "REF_SYSTEM= 'J2000'\n"
      append jpl_cmd "CSV_FORMAT= 'NO'\n"
      append jpl_cmd "OBJ_DATA= 'YES'\n"
      append jpl_cmd "QUANTITIES= '1,9,20,23,24'\n"
      append jpl_cmd "!\$\$EOF\n"

   } 


   proc ::bdi_jpl::send { } {
   
   } 


   proc ::bdi_jpl::read { } {

      set recv [$::gui_astrometry::getjpl_recev get 0.0 end]
      
      set results ""
      set readres "no"
      foreach line [split $recv "\n"] {
         set chars [string range $line 0 4]
         if {$chars == "\$\$SOE"} {set readres "ok" ; continue}
         if {$chars == "\$\$EOE"} {set readres "no"}
         if {$readres == "no"} {continue}
         regsub -all -- {[[:space:]]+} $line " " line
         set line [split $line]
         set datejj [lindex $line 0]
         set ra     [lindex $line 1]
         set dec    [lindex $line 2]
         set ::gui_astrometry::jpl_ephem($datejj) [list $ra $dec]
         #gren_info "$datejj = $ra $dec\n" 
      }
     
   }

}