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
# - namespace set_ref_science
#
#--------------------------------------------------


namespace eval set_ref_science {

   variable use_mask
   variable mask
   variable use_saturation
   variable saturation
   variable use_visu
   variable progress


   proc ::set_ref_science::inittoconf { } {

      global conf

      cleanmark
      efface_carre

      if {! [info exists ::set_ref_science::use_mask] } {
         if {[info exists conf(bddimages,astrometry,set_ref_science,use_mask)]} {
            set ::set_ref_science::use_mask $conf(bddimages,astrometry,set_ref_science,use_mask)
         } else {
            set ::set_ref_science::use_mask 1
         }
      }
      if {! [info exists ::set_ref_science::mask] } {
         if {[info exists conf(bddimages,astrometry,set_ref_science,mask)]} {
            set ::set_ref_science::mask $conf(bddimages,astrometry,set_ref_science,mask)
         } else {
            set ::set_ref_science::mask 10
         }
      }
      if {! [info exists ::set_ref_science::use_saturation] } {
         if {[info exists conf(bddimages,astrometry,set_ref_science,use_saturation)]} {
            set ::set_ref_science::use_saturation $conf(bddimages,astrometry,set_ref_science,use_saturation)
         } else {
            set ::set_ref_science::use_saturation 0
         }
      }
      if {! [info exists ::set_ref_science::saturation] } {
         if {[info exists conf(bddimages,astrometry,set_ref_science,saturation)]} {
            set ::set_ref_science::saturation $conf(bddimages,astrometry,set_ref_science,saturation)
         } else {
            set ::set_ref_science::saturation 65000
         }
      }
      if {! [info exists ::set_ref_science::use_visu] } {
         if {[info exists conf(bddimages,astrometry,set_ref_science,use_visu)]} {
            set ::set_ref_science::use_visu $conf(bddimages,astrometry,set_ref_science,use_visu)
         } else {
            set ::set_ref_science::use_visu 0
         }
      }

      set ::set_ref_science::progress 0

   }


   proc ::set_ref_science::closetoconf { } {

      global conf

      set conf(bddimages,astrometry,set_ref_science,use_mask)       $::set_ref_science::use_mask
      set conf(bddimages,astrometry,set_ref_science,mask)           $::set_ref_science::mask
      set conf(bddimages,astrometry,set_ref_science,use_saturation) $::set_ref_science::use_saturation
      set conf(bddimages,astrometry,set_ref_science,saturation)     $::set_ref_science::saturation
      set conf(bddimages,astrometry,set_ref_science,use_visu)       $::set_ref_science::use_visu

   }


   proc ::set_ref_science::fermer { } {

      ::set_ref_science::closetoconf
      destroy $::set_ref_science::fen

   }


   proc ::set_ref_science::apply { } {
      
      # Sanity check
      if {[string length $::set_ref_science::cata_science] < 1 && [string length $::set_ref_science::cata_ref] < 1} {
         tk_messageBox -message "Veuillez selectionner au moins un catalogue Science ou Reference" -type ok
         return
      }

      # Log
      gren_info "Sciences = $::set_ref_science::cata_science\n"
      gren_info "Reference = $::set_ref_science::cata_ref\n"
      set msg "Mask = $::set_ref_science::use_mask"
      if {$::set_ref_science::use_mask} { set msg "$msg (bordure = $::set_ref_science::mask pixels)" }
      gren_info "$msg\n"
      gren_info "Nb images a traiter = $::tools_cata::nb_img_list\n"

      # Go
      for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image <= $::tools_cata::nb_img_list} {incr ::tools_cata::id_current_image} {

         set current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]

         gren_info " -> traitement image $::tools_cata::id_current_image / $::tools_cata::nb_img_list ([::bddimages_liste::lget $current_image filename])\n"
         ::set_ref_science::set_progress $::tools_cata::id_current_image $::tools_cata::nb_img_list

         set current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

         # Recupere les NAXISi de l'image courante
         set tabkey [::bddimages_liste::lget $current_image "tabkey"]
         set naxis1 [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
         set naxis2 [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
         # Definition du mask
         set mx_min $::set_ref_science::mask
         set mx_max [expr $naxis1 - $::set_ref_science::mask]
         set my_min $::set_ref_science::mask
         set my_max [expr $naxis2 - $::set_ref_science::mask]

         # Defini les champs et les sources de l'image courante
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
               set px [lindex $b 0]
               set py [lindex $b 1]
               set pixmax [lindex $b 9]

               # Applique le mask si demande
               set accept 1
               if {$::set_ref_science::use_mask} {
                  if {$::set_ref_science::use_visu} {
                     affich_un_carre_xy $mx_min $my_min $mx_max $my_max blue
                  }
                  if {$px <= $mx_min || $px >= $mx_max || $py <= $my_min || $py >= $my_max} { set accept 0 }
               }
               if {$::set_ref_science::use_saturation} {
                  if {$pixmax > $::set_ref_science::saturation} { set accept 0 }
               }

               if {$accept} {
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
                     set b [lreplace $b 27 27 $ac]
                     set change 1
                  }
   
                  if {$change == 1} {
                     if {$::set_ref_science::use_visu} {
                        affich_un_rond_xy $px $py green 4 2
                     }
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
                  } else {
                     if {$::set_ref_science::use_visu} {
                        affich_un_rond_xy $px $py orange 4 2
                     }
                  }
               } else {
                  if {$::set_ref_science::use_visu} {
                     affich_un_rond_xy $px $py red 4 2
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
      ::set_ref_science::inittoconf

      set list_cata [list "" SKYBOT UCAC2 UCAC3 UCAC4 TYCHO2 NOMAD1 PPMX PPMXL USNOA2 2MASS]
      set nb_cata [llength $list_cata]

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

      frame $frm -borderwidth 0 -cursor arrow
      pack $frm -in $::set_ref_science::fen -anchor c -side top -expand 1 -fill both -padx 10 -pady 5

         label $frm.lab -text "Veuillez selectionner au moins un catalogue" -relief groove -borderwidth 1 -padx 10 -pady 7
         pack  $frm.lab -in $frm -side top -padx 5 -pady 5 -anchor c

         set sciences [frame $frm.sciences -borderwidth 0 -cursor arrow -relief groove]
         pack $sciences -in $frm -anchor s -side top -expand 1 -fill x -padx 10 -pady 5

             label $sciences.lab -width 15 -text "Sciences"
             pack  $sciences.lab -in $sciences -anchor e -side left -fill x -expand 0 -padx 5 -pady 0

             ComboBox $sciences.combo \
                -height $nb_cata \
                -relief sunken -borderwidth 1 -editable 0 \
                -textvariable ::set_ref_science::cata_science \
                -values $list_cata
             pack $sciences.combo -anchor center -side left -fill x -expand 1
      
         set references [frame $frm.references -borderwidth 0 -cursor arrow -relief groove]
         pack $references -in $frm -anchor s -side top -expand 1 -fill x -padx 10 -pady 5

             label $references.lab -width 15  -text "References"
             pack  $references.lab -in $references -anchor e -side left -fill x -expand 0 -padx 5 -pady 0

             ComboBox $references.combo \
                -height $nb_cata \
                -relief sunken -borderwidth 1 -editable 0 \
                -textvariable ::set_ref_science::cata_ref \
                -values $list_cata
             pack $references.combo -anchor center -side left -fill x -expand 1

         set options [frame $frm.options -borderwidth 1 -cursor arrow -relief groove]
         pack $options -in $frm -anchor c -side top -expand 1 -fill x -padx 10 -pady 5

            set mask [frame $options.mask -borderwidth 0 -cursor arrow -relief groove]
            pack $mask -in $options -anchor c -side top -expand 1 -fill x -padx 10 -pady 5
   
                checkbutton $mask.check -highlightthickness 0 -text "Exclure les sources a moins de" -variable ::set_ref_science::use_mask
                pack $mask.check -in $mask -anchor c -side left -padx 5 -pady 0 
   
                entry $mask.val -relief sunken -textvariable ::set_ref_science::mask -borderwidth 2 -width 6 -justify center
                pack  $mask.val -in $mask -anchor c -side left -padx 5 -pady 0 
   
                label $mask.lab -text "pixels du bord de l'image"
                pack  $mask.lab -in $mask -anchor c -side left -padx 5 -pady 0

            set satu [frame $options.satu -borderwidth 0 -cursor arrow -relief groove]
            pack $satu -in $options -anchor c -side top -expand 1 -fill x -padx 10 -pady 5
   
                checkbutton $satu.check -highlightthickness 0 -text "Exclure les sources de flux superieur a" -variable ::set_ref_science::use_saturation
                pack $satu.check -in $satu -anchor c -side left -padx 5 -pady 0 
   
                entry $satu.val -relief sunken -textvariable ::set_ref_science::saturation -borderwidth 1 -width 6 -justify center
                pack  $satu.val -in $satu -anchor c -side left -padx 5 -pady 0 
   
                label $satu.lab -text "ADU"
                pack  $satu.lab -in $satu -anchor c -side left -padx 5 -pady 0

            set voir [frame $options.voir -borderwidth 0 -cursor arrow -relief groove]
            pack $voir -in $options -anchor c -side top -expand 1 -fill x -padx 10 -pady 5
   
                checkbutton $voir.check -highlightthickness 0 -text "Voir les sources selectionnees" -variable ::set_ref_science::use_visu
                pack $voir.check -in $voir -anchor c -side left -padx 5 -pady 0 

         set progressbar [frame $frm.progressbar -borderwidth 0 -cursor arrow -relief groove]
         pack $progressbar -in $frm -anchor c -side top -expand 1 -fill x -padx 10 -pady 5

             set pf [ ttk::progressbar $progressbar.p -variable ::set_ref_science::progress -orient horizontal -length 300 -mode determinate]
             pack $pf -in $progressbar -side top -expand 0

         set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
         pack $boutonpied  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $boutonpied.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                -command "::set_ref_science::fermer"
             pack $boutonpied.fermer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $boutonpied.enregistrer -text "Appliquer" -borderwidth 2 -takefocus 1 \
                -command "::set_ref_science::apply"
             pack $boutonpied.enregistrer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      # Bindings
      bind $::set_ref_science::fen <Key-F1> { ::console::GiveFocus }

   }


   proc ::set_ref_science::set_progress { cur max } {

      set ::set_ref_science::progress [format "%0.0f" [expr $cur * 100. /$max ] ]
      update

   }

}

