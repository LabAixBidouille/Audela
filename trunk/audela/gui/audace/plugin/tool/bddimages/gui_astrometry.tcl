namespace eval gui_astrometry {



   proc ::gui_astrometry::inittoconf {  } {

      global bddconf, conf
      set ::tools_astrometry::science   "SKYBOT"
      set ::tools_astrometry::reference "UCAC3"


      if {! [info exists ::tools_astrometry::ifortlib] } {
         if {[info exists conf(bddimages,cata,ifortlib)]} {
            set ::tools_astrometry::ifortlib $conf(bddimages,cata,ifortlib)
         } else {
            set ::tools_astrometry::ifortlib "/opt/intel/lib/ia32"
         }
      }

   }


   proc ::gui_astrometry::charge_list { img_list } {

     catch {
         if { [ info exists $::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
         if { [ info exists $::tools_cata::nb_img_list ] }        {unset ::tools_cata::nb_img_list}
         if { [ info exists $::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
         if { [ info exists $::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
      }
      
      set ::tools_astrometry::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::tools_astrometry::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_astrometry::img_list]
      set ::tools_astrometry::nb_img_list [llength $::tools_astrometry::img_list]

   }

   proc ::gui_astrometry::fermer {  } {

      set conf(bddimages,cata,ifortlib) $::tools_astrometry::ifortlib

      destroy $::gui_astrometry::fen
      #::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
      #::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
      cleanmark

   }

   proc ::gui_astrometry::go {  } {

      ::tools_astrometry::go

   }

   proc ::gui_astrometry::setup { img_list } {

      global audace
      global bddconf

      ::gui_astrometry::charge_list $img_list
      ::gui_astrometry::inittoconf


      set ::gui_astrometry::fen .new
      if { [winfo exists $::gui_astrometry::fen] } {
         wm withdraw $::gui_astrometry::fen
         wm deiconify $::gui_astrometry::fen
         focus $::gui_astrometry::fen
         return
      }
      toplevel $::gui_astrometry::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_astrometry::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_astrometry::fen ] "+" ] 2 ]
      wm geometry $::gui_astrometry::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_astrometry::fen 1 1
      wm title $::gui_astrometry::fen "Creation du CATA"
      wm protocol $::gui_astrometry::fen WM_DELETE_WINDOW "destroy $::gui_cata::fen"

      set frm $::gui_astrometry::fen.frm_creation_cata
      set ::gui_astrometry::current_appli $frm


      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_astrometry::fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un frame science
         set science [frame $frm.science -borderwidth 0 -cursor arrow -relief groove]
         pack $science -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              label  $science.lab -text "Science" -borderwidth 1
              pack   $science.lab -in $science -side left -padx 3 -pady 3 -anchor c
              entry  $science.val -relief sunken -textvariable ::tools_astrometry::science -width 10
              pack   $science.val -in $science -side left -padx 3 -pady 3 -anchor w

         #--- Cree un frame science
         set reference [frame $frm.reference -borderwidth 0 -cursor arrow -relief groove]
         pack $reference -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
 
              label  $reference.lab -text "Reference" -borderwidth 1
              pack   $reference.lab -in $reference -side left -padx 3 -pady 3 -anchor c
              entry  $reference.val -relief sunken -textvariable ::tools_astrometry::reference -width 10
              pack   $reference.val -in $reference -side left -padx 3 -pady 3 -anchor w

         #--- Cree un frame ifort
         set ifortlib [frame $frm.ifortlib -borderwidth 0 -cursor arrow -relief groove]
         pack $ifortlib -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
 
              label  $ifortlib.lab -text "ifort" -borderwidth 1
              pack   $ifortlib.lab -in $ifortlib -side left -padx 3 -pady 3 -anchor c
              entry  $ifortlib.val -relief sunken -textvariable ::tools_astrometry::ifortlib -width 30
              pack   $ifortlib.val -in $ifortlib -side left -padx 3 -pady 3 -anchor w

         #--- Cree un frame pour afficher bouton fermeture
         set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
         pack $boutonpied  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              set ::gui_cata::gui_fermer [button $boutonpied.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                 -command "::gui_astrometry::fermer"]
              pack $boutonpied.fermer -side left -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

              set ::gui_cata::gui_go [button $boutonpied.go -text "Go" -borderwidth 2 -takefocus 1 \
                 -command "::gui_astrometry::go"]
              pack $boutonpied.go -side left -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   }
   
   
   
   
   
   
}
