
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

  ::console::affiche_resultat "bddimages_entete_preminforecon\n"
  ::console::affiche_resultat "\n\n\n\ntabkey [lindex $tabkey 0]\n\n\n\n"
  set telescop [get_tabkey $tabkey "TELESCOP"]
  ::console::affiche_resultat "avTELESCOP $telescop\n"
  set telescop [string trim $telescop]
  set telescop [string tolower $telescop]
  set telescop [string map {" " "_"} $telescop]
  set tabkey   [update_tabkey $tabkey "TELESCOP" $telescop]
  ::console::affiche_resultat "apTELESCOP $telescop\n"


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
       return $val
       }
    }

return ""
}





proc update_tabkey { tabkey inkey inval } {

  set result_list ""
  foreach keyval $tabkey {

     set key [lindex $keyval 0]
     set val [lindex [lindex $keyval 1] 1]

     if { $key == $inkey } {
        ::console::affiche_resultat "maj $inkey\n"
        lappend result_list [list $inkey $inval]
     } else {
        lappend result_list [list $key $val]
     }
  }

return $result_list
}





proc add_tabkey { tabkey inkey inval } {

   if {[exist_tabkey $tabkey $inkey]} {
      ::console::affiche_resultat "$inkey existe\n"
      set tabkey [update_tabkey $tabkey $inkey $inval]
   } else {
      ::console::affiche_resultat "$inkey n existe pas\n"
      lappend tabkey [list $inkey $inval]
   }
   
return $tabkey
}




proc exist_tabkey { tabkey inkey } {

  foreach keyval $tabkey {
     set key [lindex $keyval 0]
     if { $key == $inkey } {
        return 1
     }
  }

return 0
}
