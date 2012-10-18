namespace eval bdi_binast_tools {


variable img_list
variable current_image
variable current_image_name
variable nb_img_list



   proc ::bdi_binast_tools::charge_list { img_list } {

      catch {
         if { [ info exists $::bdi_binast_tools::img_list ] }           {unset ::bdi_binast_tools::img_list}
         if { [ info exists $::bdi_binast_tools::current_image ] }      {unset ::bdi_binast_tools::current_image}
         if { [ info exists $::bdi_binast_tools::current_image_name ] } {unset ::bdi_binast_tools::current_image_name}
      }
      
      set ::bdi_binast_tools::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::bdi_binast_tools::img_list    [::bddimages_liste_gui::add_info_cata_list $::bdi_binast_tools::img_list]
      set ::bdi_binast_tools::nb_img_list [llength $::bdi_binast_tools::img_list]


   }


   
}
