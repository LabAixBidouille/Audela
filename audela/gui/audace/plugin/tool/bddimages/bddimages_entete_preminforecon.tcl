
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

  set telescop [get_tabkey $tabkey "TELESCOP"]
  set telescop [string trim $telescop]
  set telescop [string tolower $telescop]
  set telescop [string map {" " "_"} $telescop]
  set tabkey   [update_tabkey $tabkey "TELESCOP" $telescop]


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

  set $result [chg_tabkey $tabkey]

  set err [lindex $tabkey 0]
  if {$err!=0} {
    return [list 1 "-" $telescop]
    }

  set result_tabkey [lindex $tabkey 1]
    
  set dateiso [get_tabkey $result_tabkey "DATE-OBS"]
  set datejd  [ mc_date2jd $dateiso ]
  if {$datejd > 2268932. && $datejd < 2634166.} {
    set err 0
    } else {
    set err 2
    }

return [list $err $result_tabkey]
}




proc get_tabkey { tabkey inkey } {

  foreach keyval $tabkey {
    set key [lindex $keyval 0]
    set val [lindex [lindex $keyval 1] 1]

    if { $key == $inkey } {
       return -code ok $val
       }
    }

return -code error
}


proc update_tabkey { tabkey key val } {

return val
}
proc add_tabkey { tabkey key  } {

return 0
}
proc exist_tabkey { tabkey key  } {

return 0
}
