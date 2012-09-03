namespace eval gui_astrometry {



   proc ::gui_astrometry::inittoconf {  } {

      global bddconf, conf
      set ::tools_astrometry::science   "SKYBOT"
      set ::tools_astrometry::reference "UCAC3"
      set ::tools_astrometry::delta 15
      set ::tools_astrometry::treshold 5
      set ::gui_astrometry::factor 1000
      set ::tools_astrometry::id_img 0
      
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
         if { [ info exists $::tools_astrometry::img_list ] }           {unset ::tools_astrometry::img_list}
         if { [ info exists $::tools_astrometry::nb_img_list ] }        {unset ::tools_astrometry::nb_img_list}
         if { [ info exists $::tools_astrometry::current_image ] }      {unset ::tools_astrometry::current_image}
         if { [ info exists $::tools_astrometry::current_image_name ] } {unset ::tools_astrometry::current_image_name}
      }
      
      set ::tools_astrometry::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::tools_astrometry::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_astrometry::img_list]
      set ::tools_astrometry::nb_img [llength $::tools_astrometry::img_list]

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
      wm protocol $::gui_astrometry::fen WM_DELETE_WINDOW "destroy $::gui_astrometry::fen"

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

         #--- Cree un frame ifort
         set delta [frame $frm.delta -borderwidth 0 -cursor arrow -relief groove]
         pack $delta -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
 
              label  $delta.lab -text "Rayon de la fenetre pour la psf :" -borderwidth 1
              pack   $delta.lab -in $delta -side left -padx 3 -pady 3 -anchor c
              entry  $delta.val -relief sunken -textvariable ::tools_astrometry::delta -width 5
              pack   $delta.val -in $delta -side left -padx 3 -pady 3 -anchor w

         #--- Cree un frame ifort
         set treshold [frame $frm.treshold -borderwidth 0 -cursor arrow -relief groove]
         pack $treshold -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
 
              label  $treshold.lab -text "threshold rdiff :" -borderwidth 1
              pack   $treshold.lab -in $treshold -side left -padx 3 -pady 3 -anchor c
              entry  $treshold.val -relief sunken -textvariable ::tools_astrometry::treshold -width 5
              pack   $treshold.val -in $treshold -side left -padx 3 -pady 3 -anchor w

         #--- Cree un frame pour afficher bouton fermeture
         set enregistrer [frame $frm.enregistrer  -borderwidth 0 -cursor arrow -relief groove]
         pack $enregistrer  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              label  $enregistrer.lab -text "Enregistrer : " -borderwidth 1
              pack   $enregistrer.lab -in $enregistrer -side left -padx 3 -pady 3 -anchor c

              button $enregistrer.txt -text "TXT" -borderwidth 2 -takefocus 1 \
                      -command "::tools_astrometry::save TXT"
              pack   $enregistrer.txt -side left -anchor e -expand 0

              button $enregistrer.mpc -text "MPC" -borderwidth 2 -takefocus 1 \
                      -command "::tools_astrometry::save MPC"
              pack   $enregistrer.mpc -side left -anchor e -expand 0

              button $enregistrer.cata -text "CATA" -borderwidth 2 -takefocus 1 \
                      -command "::tools_astrometry::save CATA"
              pack   $enregistrer.cata -side left -anchor e -expand 0

         #--- Cree un frame pour afficher bouton fermeture
         set voir [frame $frm.voir  -borderwidth 0 -cursor arrow -relief groove]
         pack $voir  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              label  $voir.lab -text "Voir : " -borderwidth 1
              pack   $voir.lab -in $voir -side left -padx 3 -pady 3 -anchor c

              button $voir.clean -text "Clean" -borderwidth 2 -takefocus 1 \
                      -command "cleanmark"
              pack   $voir.clean -side left -anchor e -expand 0

              button $voir.residus -text "Residus" -borderwidth 2 -takefocus 1 \
                      -command "::gui_astrometry::see_residus"
              pack   $voir.residus -side left -anchor e -expand 0

              label  $voir.lab2 -text "facteur : " -borderwidth 1
              pack   $voir.lab2 -in $voir -side left -padx 3 -pady 3 -anchor c

              entry  $voir.factor -relief sunken -textvariable ::gui_astrometry::factor -width 5
              pack   $voir.factor -in $voir -side left -padx 3 -pady 3 -anchor w


         #--- Cree un frame pour afficher bouton fermeture
         set info [frame $frm.info  -borderwidth 0 -cursor arrow -relief groove]
         pack $info  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              label  $info.lab1 -text "Image " -borderwidth 1
              pack   $info.lab1 -in $info -side left -padx 3 -pady 3 -anchor c
              label  $info.id -textvariable ::tools_astrometry::id_img -borderwidth 1
              pack   $info.id -in $info -side left -padx 3 -pady 3 -anchor c
              label  $info.lab2 -text " / " -borderwidth 1
              pack   $info.lab2 -in $info -side left -padx 3 -pady 3 -anchor c
              label  $info.nb -textvariable ::tools_astrometry::nb_img -borderwidth 1
              pack   $info.nb -in $info -side left -padx 3 -pady 3 -anchor c



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
   
   
   

# "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" 
# "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
# "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "flagastrom" 
# "mag" "err_mag" 
   proc ::gui_astrometry::see_residus {  } {

      foreach ::tools_astrometry::current_image $::tools_astrometry::img_list {
         set tabkey      [::bddimages_liste::lget $::tools_astrometry::current_image "tabkey"]

         set ::tools_astrometry::current_listsources [::bddimages_liste::lget $::tools_astrometry::current_image "listsources"]
         set ::tools_astrometry::current_listsources [::manage_source::extract_sources_by_catalog $::tools_astrometry::current_listsources "ASTROID"]
         gren_info "Rolextr=[ ::manage_source::get_nb_sources_rollup $::tools_astrometry::current_listsources]\n"

         #::manage_source::imprim_sources  $::tools_astrometry::current_listsources "ASTROID"

         foreach s [lindex $::tools_astrometry::current_listsources 1] {
            foreach cata $s {
            
               if {[lindex $cata 0] == $::tools_astrometry::science} {
                  set comm [lindex $cata 1]
                  set ra      [lindex $comm 0]  
                  set dec     [lindex $comm 1]
                  affich_un_rond $ra $dec "green" 1
               }
               if {[lindex $cata 0] == $::tools_astrometry::reference} {
                  set comm [lindex $cata 1]
                  set ra      [lindex $comm 0]  
                  set dec     [lindex $comm 1]
                  affich_un_rond $ra $dec "yellow" 1
               }
            
               if {[lindex $cata 0] == "ASTROID"} {
                  set astroid [lindex $cata 2]
                  
                  set flagastrom  [lindex $astroid 20]  
                  set ra      [lindex $astroid 14]  
                  set dec     [lindex $astroid 15]   
                  set res_ra  [lindex $astroid 16]  
                  set res_dec [lindex $astroid 17]  
                  set omc_ra  [lindex $astroid 18]   
                  set omc_dec [lindex $astroid 19]  
                  set color "red"
                  if {$flagastrom=="S"} { set color "green"}
                  if {$flagastrom=="R"} { set color "yellow"}
                  affich_vecteur $ra $dec $res_ra $res_dec $::gui_astrometry::factor $color
                  gren_info "vect! $ra $dec $res_ra $res_dec $::gui_astrometry::factor $color\n"
               }
            }
         }
         
      }

   
   }
   
   
}
