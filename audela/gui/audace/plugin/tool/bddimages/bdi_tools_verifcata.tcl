namespace eval tools_verifcata {


   proc ::tools_verifcata::verif { send_source_list send_date_list } {

      upvar $send_source_list source_list
      upvar $send_date_list   date_list
 
 
      set source_list ""
      set date_list ""
      
      
      if {[info exists ::gui_cata::cata_list]} {
         
         foreach {idd listsources} [array get ::gui_cata::cata_list] {

            set satraster 0
            set catadouble 0
            set err 0

            set sources [lindex $listsources 1] 
            set ids 0
            foreach s $sources {
               incr ids
               set star  "n"
               set aster "n"
               set catas ""
               set doubl "n"
               foreach cata $s {
                  set name [lindex $cata 0]
                  
                  # Test si plusieurs catas du meme nom pour une meme source
                  set p [lsearch $catas $name]
                  if {$p!=-1} {
                     incr err
                     incr catadouble
                     set doubl "y"
                  }
                  # identifie la source, stellaire ou systeme solaire
                  append catas " $name"
                  switch $name {
                      "SKYBOT" { set aster "y" } 
                      "UCAC2" - 
                      "UCAC3" -
                      "UCAC4" { set star  "y" } 
                      default {}
                  }
               }
               # Denomination de la source
               set namable [::manage_source::namable $s]
               if {$namable==""} {
                  set namesource ""
               } else {
                  set namesource [::manage_source::naming $s $namable]
               } 
               
               # Test si plusieurs catas du meme nom pour une meme source
               if {$doubl == "y"} {
                  lappend source_list [list $ids $idd $idd "DoubleCata" $namesource $catas]
               }
               
               # Test si la source est a la fois stellaire et systeme solaire
               if {$star == "y" && $aster == "y"} {
                  lappend source_list [list $ids $idd $idd "Star&Aster" $namesource $catas]
                  incr satraster
                  incr err
               }
               
            }


            if {$err} { lappend date_list [list $ids $idd $idd $satraster] }
         }
         
      }
      

   }

}
