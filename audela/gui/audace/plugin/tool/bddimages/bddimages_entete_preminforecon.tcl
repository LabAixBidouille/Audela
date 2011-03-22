
# source audace/plugin/tool/bddimages/bddimages_entete_preminforecon.tcl
# Mise à jour $Id$

# ---------------------------------------
# bddimages_entete_preminforecon {}
# ---------------------------------------

# Reconnaissance des champs DATE-OBS &
# TELESCOP

# ---------------------------------------
proc bddimages_entete_preminforecon {tabkey} {

 global bddconf

  set result_tabkey $tabkey

  set telescop ""
  foreach keyval $tabkey {

    set key [lindex $keyval 0]
    set val [lindex [lindex $keyval 1] 1]

    switch $key {
        "TELESCOP" {
          set telescop [string trim $val]
          set telescop [string tolower $telescop]
          set telescop [string map {" " "_"} $telescop]
          break
          }
        default {
          }
        }
        # fin switch
    }
      # fin foreach

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
#          bddimages_sauve_fich "bddimages_entete_preminforecon: lecture de $telescop.tcl"
          set garde "ok"
          break
          }
        }
      }
    }

  if {$garde=="no"} {
    source [ file join $dir default.tcl ]
#    bddimages_sauve_fich "bddimages_entete_preminforecon: lecture de default.tcl"
    }

  set result [dateobs $tabkey]
  set err [lindex $result 0]
  if {$err!=0} {
    return [list 1 "-" $telescop]
    } else {
    set dateiso [lindex $result 1]
    }

  set datejd [ mc_date2jd $dateiso ]
  if {$datejd > 2268932. && $datejd < 2634166.} {
    set err 0
    } else {
    set err 2
    }
  set dateiso [ mc_date2iso8601 $datejd ]

return [list $err $dateiso $telescop]
}

