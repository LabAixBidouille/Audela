
# source audace/plugin/tool/bddimages/bddimages_entete_preminforecon.tcl
# Mise à jour $Id$

# ---------------------------------------
# bddimages_entete_preminforecon {}
# ---------------------------------------

# Reconnaissance des champs DATE-OBS &
# TELESCOP

# ---------------------------------------
proc bddimages_entete_preminforecon { tabkey } {

 global bddconf

  set result_tabkey $tabkey

  #::console::affiche_erreur "- result_tabkey\n"
  #::console::affiche_resultat "result_tabkey $result_tabkey\n"

  set line [::bddimages_liste::lget $tabkey "telescop"]
  set telescop [lindex $line 1]

  set telescop [string trim $telescop]
  set telescop [string tolower $telescop]
  set telescop [string map {" " "_"} $telescop]

  set tabkey [::bddimages_liste::lupdate $tabkey "telescop" [lreplace $line 1 1 $telescop]]


  set dir [ file join $bddconf(rep_plug) site ]

  set garde "no"
  if {$telescop==""} {
    set telescop "Unknown"
    } else {
    set errnum [catch {set sitemethod [glob $dir/*]} msg]
    if {!$errnum} {
      foreach i $sitemethod {
        set fic [file tail $i]
        if {$fic=="$telescop.tcl"} {
          source [ file join $dir $telescop.tcl ]
          #bddimages_sauve_fich "bddimages_entete_preminforecon: lecture de $telescop.tcl"
          set garde "ok"
          break
          }
        }
      }
    }

  if {$garde=="no"} {
    source [ file join $dir default.tcl ]
    #bddimages_sauve_fich "bddimages_entete_preminforecon: lecture de default.tcl"
    }

  set result [chg_tabkey $tabkey]

  set err [lindex $result 0]
  if {$err!=0} {
    return [list 1 "-" $telescop]
    }

  set result_tabkey [lindex $result 1]
    
  set line [::bddimages_liste::lget $tabkey "date-obs"]
  set dateiso [lindex $line 1]
  
  set datejd  [ mc_date2jd $dateiso ]
  if {$datejd > 2268932. && $datejd < 2634166.} {
    set err 0
    } else {
    set err 2
    }

return [list $err $result_tabkey]
}







