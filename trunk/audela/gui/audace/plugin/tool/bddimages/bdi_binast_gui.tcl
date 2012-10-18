namespace eval bdi_binast_gui {



   proc ::bdi_binast_gui::inittoconf {  } {

      global bddconf, conf
      set ::tools_astrometry::science   "SKYBOT"
      set ::tools_astrometry::reference "UCAC3"
      set ::tools_astrometry::delta 15
      set ::tools_astrometry::treshold 5
      set ::gui_astrometry::factor 1000
      set ::tools_cata::id_current_image 0

      if {! [info exists ::tools_astrometry::ifortlib] } {
         if {[info exists conf(bddimages,cata,ifortlib)]} {
            set ::tools_astrometry::ifortlib $conf(bddimages,cata,ifortlib)
         } else {
            set ::tools_astrometry::ifortlib "/opt/intel/lib/ia32"
         }
      }

   }
   


   
}
