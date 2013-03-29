namespace eval tools_verifcata {


   proc ::tools_verifcata::verif { send_source_list send_date_list } {

      upvar $send_source_list source_list
      upvar $send_date_list   date_list
 
 
      set source_list ""
      set date_list ""
      
      
      if {[info exists ::gui_cata::cata_list]} {
         
         foreach {idd listsources} [array get ::gui_cata::cata_list] {

            set satraster 0
            set err 0

            set sources [lindex $listsources 1] 
            set ids 0
            foreach s $sources {
               incr ids
               set star  "n"
               set aster "n"
               set catas ""
               foreach cata $s {
                  set name [lindex $cata 0]
                  append catas " $name"
                  switch $name {
                      "SKYBOT" { set aster "y" } 
                      "UCAC2" - 
                      "UCAC3" -
                      "UCAC4" { set star  "y" } 
                      default {}
                  }
               }
               set namable [::manage_source::namable $s]
               if {$namable==""} {
                  set namesource ""
               } else {
                  set namesource [::manage_source::naming $s $namable]
               } 

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
