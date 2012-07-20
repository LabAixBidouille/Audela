#--------------------------------------------------
# source audace/plugin/tool/bddimages/tools_astroid.tcl
#--------------------------------------------------
#
# Fichier        : tools_astroid.tcl
# Description    : Environnement d analyse de la photometrie et astrometrie  
#                  pour des images qui ont un cata
# Auteur         : Frederic Vachier
# Mise à jour $Id: tools_astroid.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
namespace eval tools_astroid {

   variable id


   proc ::tools_astroid::astroid { } {
    
      global bddconf
    
      cleanmark
    
      set cataexist [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
      if {$cataexist==0} {
        set ::tools_cata::current_image [::bddimages_liste_gui::add_info_cata $::tools_cata::current_image]
        set cataexist [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
      }
#      gren_info "current_image = $::tools_cata::current_image\n"
      if {$cataexist} {
         set catafilename [::bddimages_liste::lget $::tools_cata::current_image "catafilename"]
         set catadirfilename [::bddimages_liste::lget $::tools_cata::current_image "catadirfilename"]
         set catafile [file join $bddconf(dirbase) $catadirfilename $catafilename] 
         gren_info "cataexist = $cataexist\n"
         gren_info "catafile = $catafile\n"
         set catafile [extract_cata_xml $catafile]
         gren_info "READ catafile = $catafile\n"
         set listsources [get_cata_xml $catafile]
         ::manage_source::imprim_3_sources $listsources
         set listsources [::manage_source::set_common_fields $listsources USNOA2 {ra dec poserr mag magerr }]
         affich_rond $listsources USNOA2 $::tools_cata::color_usnoa2  1
         set listsources [::manage_source::set_common_fields $listsources UCAC2 { ra_deg dec_deg e_pos_deg U2Rmag_mag 0.5 }]
         affich_rond $listsources UCAC2 $::tools_cata::color_ucac2 2

#         set listmesure [::manage_source::extract_sources_by_catalog $listsources UCAC2]
#         ::priam::create_file_oldformat $listsources USNOA2 $listmesure

      }
    
    
      
   }

# Fin du namespace
}
