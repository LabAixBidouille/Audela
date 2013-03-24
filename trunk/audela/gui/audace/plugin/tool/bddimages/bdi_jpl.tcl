#--------------------------------------------------
# source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/bdi_jpl.tcl
#--------------------------------------------------
#
# Fichier        : bdi_jpl.tcl
# Description    : Calcul des ephemerides JPL
# Auteur         : J. Berthier <berthier@imcce.fr> et F. Vachier <fv@imcce.fr>
# Mise à jour $Id: bdi_tools.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#
namespace eval bdi_jpl {
   package provide bdi_jpl 1.0

   variable destinataire "horizons@ssd.jpl.nasa.gov"
   variable sujet "JOB"

}

#----------------------------------------------------------------------------
## Creation du message a envoyer a Horizons@JPL pour calculer
# les ephemerides d'un corps du systeme solaire
#  @param sso_name string Nom du Sso a calculer
#  @param list_dates array Liste des dates JJ de calcul
#  @param iau_code string Code UAI du lieu
#  @return string Job a soumettre au systeme Horizons@JPL
proc ::bdi_jpl::create { sso_name list_dates iau_code } {

   upvar $list_dates dates

   set jpl_job "!\$\$SOF\n"
   append jpl_job "EMAIL_ADDR= \n"
   append jpl_job "COMMAND= '[string trim $sso_name];'\n"
   append jpl_job "CENTER= '$iau_code@399'\n"
   append jpl_job "MAKE_EPHEM= 'YES'\n"
   append jpl_job "TABLE_TYPE= 'OBSERVER'\n"
   append jpl_job "TLIST=\n"
   foreach {midepoch dateimg} [array get dates] {
      append jpl_job "'$midepoch'\n"
   }
   append jpl_job "CAL_FORMAT= 'JD'\n"
   append jpl_job "TIME_DIGITS= 'FRACSEC'\n"
   append jpl_job "ANG_FORMAT= 'DEG'\n"
   append jpl_job "OUT_UNITS= 'KM-S'\n"
   append jpl_job "RANGE_UNITS= 'AU'\n"
   append jpl_job "APPARENT= 'AIRLESS'\n"
   append jpl_job "SOLAR_ELONG= '0,180'\n"
   append jpl_job "SUPPRESS_RANGE_RATE= 'NO'\n"
   append jpl_job "SKIP_DAYLT= 'NO'\n"
   append jpl_job "EXTRA_PREC= 'YES'\n"
   append jpl_job "R_T_S_ONLY= 'NO'\n"
   append jpl_job "REF_SYSTEM= 'J2000'\n"
   append jpl_job "CSV_FORMAT= 'NO'\n"
   append jpl_job "OBJ_DATA= 'YES'\n"
   append jpl_job "QUANTITIES= '1,9,20,23,24'\n"
   append jpl_job "!\$\$EOF\n"

   return $jpl_job
} 


#----------------------------------------------------------------------------
## Fonction envoyant le mail a Horizons@JPL pour demander le calcul
# des ephemerides du corps du systeme solaire
#  @TODO
proc ::bdi_jpl::send { } {



} 


#----------------------------------------------------------------------------
## Lecture des donnees renvoyees par Horizons@JPL pour extraire
# les coordonnees du corps du systeme solaire
#  @param recv string message renvoye par Horizons@JPL
#  @return array ephemerides calculees par Horizons@JPL
proc ::bdi_jpl::read { recv ephem } {

   upvar $ephem eph

   array unset eph
   set readres "no"
   foreach line [split $recv "\n"] {
      set chars [string range $line 0 4]
      if {$chars == "\$\$SOE"} {set readres "ok" ; continue}
      if {$chars == "\$\$EOE"} {set readres "no"}
      if {$readres == "no"} {continue}
      regsub -all -- {[[:space:]]+} $line " " line
      set line [split $line]
      set jd  [lindex $line 0]
      set ra  [lindex $line 1]
      set dec [lindex $line 2]
      set eph([format "%18.9f" $jd]) [list $jd $ra $dec]
   }
  
}
