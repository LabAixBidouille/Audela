
# source audace/plugin/tool/bddimages/bddimages_entete_preminforecon.tcl

# ---------------------------------------
# bddimages_entete_preminforecon {}
# ---------------------------------------

# Reconnaissance des champs DATE-OBS & 
# TELESCOP

# ---------------------------------------
proc bddimages_entete_preminforecon {tabkey} {

 global bddconf

  set site ""
  foreach keyval $tabkey {

    set key [lindex $keyval 0]
    set val [lindex [lindex $keyval 1] 1]
    
      switch $key {
          "TELESCOP" {
            set site [string trim $val]
            set site [string tolower $site]
            set site [string map {" " "_"} $site]
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
  if {$site==""} {
    set site "Unknown"
    } else {
    set errnum [catch {set sitemethod [glob $dir/*]} msg]
    if {!$errnum} {
      foreach i $sitemethod {
        set fic [file tail $i]
        if {$fic=="$site.tcl"} {
          source [ file join $dir $site.tcl ]
#          bddimages_sauve_fich "bddimages_entete_preminforecon: lecture de $site.tcl"
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
    return [list 1 "-" $site] 
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

return [list $err $dateiso $site]
}


