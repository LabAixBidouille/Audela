namespace eval tools_astrometry {


variable science
variable reference
variable imglist
variable current_image

   proc ::tools_astrometry::go {  } {

      gren_info "Science = $::tools_astrometry::science\n"
      gren_info "Reference = $::tools_astrometry::reference\n"

      foreach ::tools_astrometry::current_image $::tools_astrometry::img_list {
         set tabkey      [::bddimages_liste::lget $::tools_astrometry::current_image "tabkey"]
         set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         set idbddimg    [::bddimages_liste::lget $::tools_astrometry::current_image idbddimg]
         gren_info "date : $date  idbddimg : $idbddimg\n"
         #gren_info "CURRENT_IMAGE :  $::tools_astrometry::current_image\n"
      }

   }

}
