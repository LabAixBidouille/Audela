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
    
      set cataexist [::bddimages_liste::lget $::analyse_tools::current_image "cataexist"]
      set catafilename [::bddimages_liste::lget $::analyse_tools::current_image "catafilename"]
      set catadirfilename [::bddimages_liste::lget $::analyse_tools::current_image "catadirfilename"]
      set catafile [file join $bddconf(dirbase) $catadirfilename $catafilename] 

      gren_info "current_image = $::analyse_tools::current_image\n"

      gren_info "cataexist = $cataexist\n"
      set ::analyse_tools::current_image [::bddimages_liste_gui::add_info_cata $::analyse_tools::current_image]
      gren_info "cataexist = $cataexist\n"
      if {$cataexist} {
         set listsources [get_cata_xml $catafile]
         ::manage_source::imprim_3_sources $listsources
      }
    
    
      
   }

# Fin du namespace
}
