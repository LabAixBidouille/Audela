#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages bdi_set_ref_science_gui.tcl ]
#--------------------------------------------------
#
# Fichier        : bdi_set_ref_science_gui.tcl
# Description    : definition des references et des sciences en fonction des catalogues
# Auteur         : Frederic Vachier
# Mise à jour $Id: bdi_set_ref_science_gui.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace psf_gui
#
#--------------------------------------------------


namespace eval set_ref_science {



   proc ::set_ref_science::fermer { } {
      destroy $::set_ref_science::fen
   }





   proc ::set_ref_science::apply { } {
      
      gren_info "Sciences    = $::set_ref_science::cata_science\n"
      gren_info "Reference   = $::set_ref_science::cata_ref\n"
      gren_info "selet bord  = $::set_ref_science::select_bord\n"
      gren_info "bordure     = $::set_ref_science::bord\n"
      gren_info "nb_img_list = $::tools_cata::nb_img_list\n"
      
      for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image<=$::tools_cata::nb_img_list} {incr ::tools_cata::id_current_image} {

         gren_info "image = $::tools_cata::id_current_image / $::tools_cata::nb_img_list\n"
         ::set_ref_science::set_progress $::tools_cata::id_current_image $::tools_cata::nb_img_list
         set current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)
         set fields [lindex $current_listsources 0]
         set sources [lindex $current_listsources 1]
         array set tklist $::gui_cata::tk_list($::tools_cata::id_current_image,tklist)
         array set cataname $::gui_cata::tk_list($::tools_cata::id_current_image,cataname)
         foreach {x y} [array get cataname] {
            set getid($y) $x
         }

         set ids 0
         foreach s $sources {
            incr ids
            set posastroid [lsearch -index 0 $s "ASTROID"]
            if {$posastroid != -1} {
               set astroid [lindex $s $posastroid]
               set b [lindex $astroid 2]
               set change 0
               
               set p [lsearch -index 0 $s $::set_ref_science::cata_science]
               if {$p != -1} {
                  set ar "S"
                  set ac $::set_ref_science::cata_science
                  set b [lreplace $b 25 25 $ar]
                  set b [lreplace $b 27 27 $ac]
                  set change 1
               }
               
               set p [lsearch -index 0 $s $::set_ref_science::cata_ref]
               if {$p != -1} {
                  set ar "R"
                  set ac $::set_ref_science::cata_ref
                  set b [lreplace $b 25 25 $ar]
                  set b [lreplace $b 27 27 $::set_ref_science::cata_ref]
                  set change 1
               }

               if {$change == 1} {
                  set astroid [lreplace $astroid 2 2 $b]
                  set s [lreplace $s $posastroid $posastroid $astroid]
                  set sources [lreplace $sources [expr $ids-1] [expr $ids-1] $s]
                  # Modif TKLIST
                  foreach {idcata cata} [array get cataname] {
                     set x [lsearch -index 0 $tklist($idcata) $ids]
                     if {$x != -1} {
                        set b [lindex $tklist($idcata) $x]
                        set b [lreplace $b 1 2 $ar $ac]
                        set tklist($idcata) [lreplace $tklist($idcata) $x $x $b]
                     }
                  }
               }
            }
         }
         set ::gui_cata::cata_list($::tools_cata::id_current_image) [list $fields $sources]
         set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get tklist]
         
         
      }

      ::set_ref_science::set_progress 0 100
      ::set_ref_science::fermer
      ::cata_gestion_gui::charge_image_directaccess
     
     
      
   }




   proc ::set_ref_science::go { } {

      # init
      
      set list_cata [list SKYBOT UCAC2 UCAC3 UCAC4 TYCHO2 NOMAD1 PPMX PPMXL USNOA2 2MASS]
      set nb_cata [llength $list_cata]
      set ::set_ref_science::progress 0
      set ::set_ref_science::bord 10
      set ::set_ref_science::select_bord 1

      #--- Creation de la fenetre
      set ::set_ref_science::fen .set_ref_science
      if { [winfo exists $::set_ref_science::fen] } {
         wm withdraw $::set_ref_science::fen
         wm deiconify $::set_ref_science::fen
         focus $::set_ref_science::fen
         return
      }
      toplevel $::set_ref_science::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::set_ref_science::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::set_ref_science::fen ] "+" ] 2 ]
      wm geometry $::set_ref_science::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::set_ref_science::fen 1 1
      wm title $::set_ref_science::fen "References / Sciences"
      wm protocol $::set_ref_science::fen WM_DELETE_WINDOW "::set_ref_science::fermer"

      set frm $::set_ref_science::fen.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::set_ref_science::fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5
      
      
         set sciences [frame $frm.sciences -borderwidth 0 -cursor arrow -relief groove]
         pack $sciences -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             label $sciences.lab -width 15 -text "Sciences"
             pack  $sciences.lab -in $sciences -side left -padx 5 -pady 0

             ComboBox $sciences.combo \
                -width 10 -height $nb_cata \
                -relief sunken -borderwidth 1 -editable 0 \
                -textvariable ::set_ref_science::cata_science \
                -values $list_cata
             pack $sciences.combo -anchor center -side left -fill x -expand 1
      
         set references [frame $frm.references -borderwidth 0 -cursor arrow -relief groove]
         pack $references -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             label $references.lab -width 15  -text "References"
             pack  $references.lab -in $references -side left -padx 5 -pady 0
      
             ComboBox $references.combo \
                -width 10 -height $nb_cata \
                -relief sunken -borderwidth 1 -editable 0 \
                -textvariable ::set_ref_science::cata_ref \
                -values $list_cata
             pack $references.combo -anchor center -side left -fill x -expand 1
      
         set mask [frame $frm.mask -borderwidth 0 -cursor arrow -relief groove]
         pack $mask -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $mask.check -highlightthickness 0 -text " Ne pas prendre les objets a" -variable ::set_ref_science::select_bord -state disabled
             pack $mask.check -in $mask -side left -padx 5 -pady 0

             entry $mask.bord -relief sunken -textvariable ::set_ref_science::bord -borderwidth 2 -width 6 -justify center
             pack  $mask.bord -in $mask -side left -padx 5 -pady 0

             label $mask.lab -width 15  -text " pixels du bord de l'image"
             pack  $mask.lab -in $mask -side left -padx 5 -pady 0




         set progressbar [frame $frm.progressbar -borderwidth 0 -cursor arrow -relief groove]
         pack $progressbar -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set pf [ ttk::progressbar $progressbar.p -variable ::set_ref_science::progress -orient horizontal -length 300 -mode determinate]
             pack $pf -in $progressbar -side left


        set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
        pack $boutonpied  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $boutonpied.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                -command "::set_ref_science::fermer"
             pack $boutonpied.fermer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $boutonpied.enregistrer -text "Appliquer" -borderwidth 2 -takefocus 1 \
                -command "::set_ref_science::apply"
             pack $boutonpied.enregistrer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
      
      

   }

   proc ::set_ref_science::set_progress { cur max } {
      set ::set_ref_science::progress [format "%0.0f" [expr $cur * 100. /$max ] ]
      update
   }



}

