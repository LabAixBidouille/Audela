namespace eval tools_verifcata {


   proc ::tools_verifcata::verif { send_source_list send_date_list } {

      upvar $send_source_list source_list
      upvar $send_date_list   date_list
 
 
      set source_list ""
      set date_list ""
      
      
      set ::tools_cata::id_current_image 0

      foreach ::tools_cata::current_image $::tools_cata::img_list {

         incr ::tools_cata::id_current_image
         set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
         set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
         set ::tools_cata::current_image_date [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         set ::tools_cata::current_image_name [::bddimages_liste::lget $::tools_cata::current_image "filename"]
         ::gui_cata::load_cata
         
         set idd $::tools_cata::id_current_image
         set listsources $::tools_cata::current_listsources
         set ::gui_cata::cata_list($::tools_cata::id_current_image) $listsources
         
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
               lappend source_list [list $ids $idd $::tools_cata::current_image_date "DoubleCata" $namesource $catas]
            }

            # Test si la source est a la fois stellaire et systeme solaire
            if {$star == "y" && $aster == "y"} {
               lappend source_list [list $ids $idd $::tools_cata::current_image_date "Star&Aster" $namesource $catas]
               incr satraster
               incr err
            }

         }


         if {$err} { lappend date_list [list $ids $idd $idd $satraster] }
      }
         
      

   }

}
