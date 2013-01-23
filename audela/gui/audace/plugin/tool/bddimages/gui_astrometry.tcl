namespace eval gui_astrometry {



   proc ::gui_astrometry::inittoconf {  } {

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


   proc ::gui_astrometry::charge_list { img_list } {

     catch {
         if { [ info exists $::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
         if { [ info exists $::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
         if { [ info exists $::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
      }
      
      set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
      set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]

   }







   proc ::gui_astrometry::fermer {  } {

      global conf
      set conf(bddimages,cata,ifortlib) $::tools_astrometry::ifortlib

      destroy $::gui_astrometry::fen
      #::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
      #::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
      cleanmark

   }




   proc ::gui_astrometry::go_priam {  } {

      ::tools_astrometry::go_priam

   }



   proc ::gui_astrometry::init_priam {  } {

      ::tools_astrometry::init_priam

   }


   proc ::gui_astrometry::results_priam {  } {

      ::tools_astrometry::results_priam


      $::gui_astrometry::sret delete 0 end
      $::gui_astrometry::sset delete 0 end
      $::gui_astrometry::dspt delete 0 end
      $::gui_astrometry::dwpt delete 0 end

      for {set i 1} {$i<=$::tools_astrometry::nb_dates} {incr i} {

         set  table_dates $::tools_astrometry::dates($i,dateiso)
         lappend table_dates "toto"

         $::gui_astrometry::sret insert end $table_dates
         $::gui_astrometry::sset insert end $table_dates
         $::gui_astrometry::dspt insert end $table_dates
         $::gui_astrometry::dwpt insert end $table_dates

      }



   #gren_info "SRol=[ ::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
   #gren_info "ASTROIDS=[::manage_source::extract_sources_by_catalog $::tools_cata::current_listsources ASTROID]\n"
   #gren_info "LISTSOURCES=$::tools_cata::current_listsources\n"

   # Ecriture des resultats dans un fichier 
      


   }





# "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" 
# "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
# "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "flagastrom" 
# "mag" "err_mag" "name"
   proc ::gui_astrometry::see_residus {  } {

      set ::tools_cata::id_current_image 0
      foreach ::tools_cata::current_image $::tools_cata::img_list {
         set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]

         set ::tools_cata::current_listsources [::bddimages_liste::lget $::tools_cata::current_image "listsources"]
         set ::tools_cata::current_listsources [::manage_source::extract_sources_by_catalog $::tools_cata::current_listsources "ASTROID"]
         #gren_info "Rolextr=[ ::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

         #::manage_source::imprim_sources  $::tools_cata::current_listsources "ASTROID"

         foreach s [lindex $::tools_cata::current_listsources 1] {
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
                  #gren_info "vect! $ra $dec $res_ra $res_dec $::gui_astrometry::factor $color\n"
               }
            }
         }
         
         incr ::tools_cata::id_current_image
      }

   
   }












   proc ::gui_astrometry::setup { img_list } {

      global audace
      global bddconf

      ::gui_astrometry::charge_list $img_list
      ::gui_astrometry::inittoconf
      
      set loc_dates [list 0 "Mid-Date" 0 "TOTO"]


      set ::gui_astrometry::fen .astrometry
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
      wm title $::gui_astrometry::fen "Astrometrie"
      wm protocol $::gui_astrometry::fen WM_DELETE_WINDOW "destroy $::gui_astrometry::fen"

      set frm $::gui_astrometry::fen.appli
      set ::gui_astrometry::current_appli $frm


      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_astrometry::fen -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un frame ifort
         set ifortlib [frame $frm.ifortlib -borderwidth 0 -cursor arrow -relief groove]
         pack $ifortlib -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
 
              label  $ifortlib.lab -text "ifort" -borderwidth 1
              pack   $ifortlib.lab -in $ifortlib -side left -padx 3 -pady 3 -anchor c
              entry  $ifortlib.val -relief sunken -textvariable ::tools_astrometry::ifortlib -width 30
              pack   $ifortlib.val -in $ifortlib -side left -padx 3 -pady 3 -anchor w


         #--- Cree un frame pour afficher bouton fermeture
         set actions [frame $frm.actions  -borderwidth 0 -cursor arrow -relief groove]
         pack $actions  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              set ::gui_astrometry::gui_init_priam [button $actions.init_priam -text "Init" -borderwidth 2 -takefocus 1 \
                 -command "::gui_astrometry::init_priam"]
              pack $actions.init_priam -side left -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

              set ::gui_astrometry::gui_go_priam [button $actions.go_priam -text "Priam" -borderwidth 2 -takefocus 1 \
                 -command "::gui_astrometry::go_priam"]
              pack $actions.go_priam -side left -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

              set ::gui_astrometry::gui_go_priam [button $actions.results_priam -text "Resultats" -borderwidth 2 -takefocus 1 \
                 -command "::gui_astrometry::results_priam"]
              pack $actions.results_priam -side left -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

              label  $actions.labv -text "Voir : " -borderwidth 1
              pack   $actions.labv -in $actions -side left -padx 3 -pady 3 -anchor c

              button $actions.clean -text "Clean" -borderwidth 2 -takefocus 1 \
                      -command "cleanmark"
              pack   $actions.clean -side left -anchor e -expand 0

              button $actions.residus -text "Residus" -borderwidth 2 -takefocus 1 \
                      -command "::gui_astrometry::see_residus"
              pack   $actions.residus -side left -anchor e -expand 0

              label  $actions.labf -text "facteur : " -borderwidth 1
              pack   $actions.labf -in $actions -side left -padx 3 -pady 3 -anchor c

              entry  $actions.factor -relief sunken -textvariable ::gui_astrometry::factor -width 5
              pack   $actions.factor -in $actions -side left -padx 3 -pady 3 -anchor w

              label  $actions.labe -text "Enregistrer : " -borderwidth 1
              pack   $actions.labe -in $actions -side left -padx 3 -pady 3 -anchor c

              button $actions.txt -text "TXT" -borderwidth 2 -takefocus 1 \
                      -command "::tools_astrometry::save TXT"
              pack   $actions.txt -side left -anchor e -expand 0

              button $actions.mpc -text "MPC" -borderwidth 2 -takefocus 1 \
                      -command "::tools_astrometry::save MPC"
              pack   $actions.mpc -side left -anchor e -expand 0

              button $actions.cata -text "CATA" -borderwidth 2 -takefocus 1 \
                      -command "::tools_astrometry::save CATA"
              pack   $actions.cata -side left -anchor e -expand 0





              set ::gui_astrometry::gui_fermer [button $actions.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                 -command "::gui_astrometry::fermer"]
              pack $actions.fermer -side right -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


         #--- Cree un frame pour afficher bouton fermeture
         set tables [frame $frm.tables  -borderwidth 0 -cursor arrow -relief groove]
         pack $tables  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $onglets -in $frm -side top -expand yes -fill both -padx 10 -pady 5
 
            
            pack [ttk::notebook $onglets.list] -expand yes -fill both 
 
            set sources [frame $onglets.list.sources]
            pack $sources -in $onglets.list
            $onglets.list add $sources -text "Sources"
            
            set dates [frame $onglets.list.dates]
            pack $dates -in $onglets.list
            $onglets.list add $dates -text "Dates"

            set graphes [frame $onglets.list.graphes]
            pack $graphes -in $onglets.list
            $onglets.list add $graphes -text "Graphes"

            set onglets_sources [frame $sources.onglets -borderwidth 1 -cursor arrow -relief groove]
            pack $onglets_sources -in $sources -side top -expand yes -fill both -padx 10 -pady 5
 
                 pack [ttk::notebook $onglets_sources.list] -expand yes -fill both 
 
                 set references [frame $onglets_sources.list.references -borderwidth 1]
                 pack $references -in $onglets_sources.list -expand yes -fill both 
                 $onglets_sources.list add $references -text "References"

                 set sciences [frame $onglets_sources.list.sciences -borderwidth 1]
                 pack $sciences -in $onglets_sources.list -expand yes -fill both 
                 $onglets_sources.list add $sciences -text "Sciences"

            set onglets_dates [frame $dates.onglets -borderwidth 1 -cursor arrow -relief groove]
            pack $onglets_dates -in $dates -side top -expand yes -fill both -padx 10 -pady 5
 
                 pack [ttk::notebook $onglets_dates.list] -expand yes -fill both 
 
                 set sour [frame $onglets_dates.list.sources -borderwidth 1]
                 pack $sour -in $onglets_dates.list -expand yes -fill both 
                 $onglets_dates.list add $sour -text "Sources"

                 set wcs [frame $onglets_dates.list.wcs -borderwidth 1]
                 pack $wcs -in $onglets_dates.list -expand yes -fill both 
                 $onglets_dates.list add $wcs -text "WCS"



            set srp [frame $onglets_sources.list.references.parent -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $srp -in $onglets_sources.list.references -expand yes -fill both -side left

                 set ::gui_astrometry::srpt $onglets_sources.list.references.parent.table

                 tablelist::tablelist $::gui_astrometry::srpt \
                  -labelcommand tablelist::sortByColumn \
                  -selectmode extended \
                  -activestyle none \
                  -stripebackground #e0e8f0 \
                  -showseparators 1

                 $::gui_astrometry::srpt insertcolumns end 0 "References" left
                 for { set j 0 } { $j < 10} { incr j } {
                    $::gui_astrometry::srpt insert end $j
                 }

                 pack $::gui_astrometry::srpt -in $srp -expand yes -fill both 

            set sre [frame $onglets_sources.list.references.enfant -borderwidth 0 -cursor arrow -relief groove -background white]
            pack $sre -in $onglets_sources.list.references -expand yes -fill both -side left

                 set ::gui_astrometry::sret $onglets_sources.list.references.enfant.table

                 tablelist::tablelist $::gui_astrometry::sret \
                   -columns $loc_dates \
                   -labelcommand tablelist::sortByColumn \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 for { set j 0 } { $j < 10} { incr j } {
                    $::gui_astrometry::sret insert end $j
                 }

                 pack $::gui_astrometry::sret -in $sre -expand yes -fill both


            set ssp [frame $onglets_sources.list.sciences.parent -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $ssp -in $onglets_sources.list.sciences -expand yes -fill both -side left

                 set ::gui_astrometry::sspt $onglets_sources.list.sciences.parent.table

                 tablelist::tablelist $::gui_astrometry::sspt \
                  -labelcommand tablelist::sortByColumn \
                  -selectmode extended \
                  -activestyle none \
                  -stripebackground #e0e8f0 \
                  -showseparators 1

                 $::gui_astrometry::sspt insertcolumns end 0 "Sciences" left
                 for { set j 0 } { $j < 10} { incr j } {
                    $::gui_astrometry::sspt insert end $j
                 }

                 pack $::gui_astrometry::sspt -in $ssp -expand yes -fill both 

            set sse [frame $onglets_sources.list.sciences.enfant -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $sse -in $onglets_sources.list.sciences -expand yes -fill both -side left

                 set ::gui_astrometry::sset $onglets_sources.list.sciences.enfant.table

                 tablelist::tablelist $::gui_astrometry::sset \
                   -columns $loc_dates \
                   -labelcommand tablelist::sortByColumn \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 for { set j 0 } { $j < 10} { incr j } {
                    $::gui_astrometry::sset insert end $j
                 }

                 pack $::gui_astrometry::sset -in $sse -expand yes -fill both





            set dsp [frame $onglets_dates.list.sources.parent -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $dsp -in $onglets_dates.list.sources -expand yes -fill both -side left

                 set ::gui_astrometry::dspt $onglets_dates.list.sources.parent.table

                 tablelist::tablelist $::gui_astrometry::dspt \
                   -columns $loc_dates \
                   -labelcommand tablelist::sortByColumn \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 for { set j 0 } { $j < 10} { incr j } {
                    $::gui_astrometry::dspt insert end $j
                 }

                 pack $::gui_astrometry::dspt -in $dsp -expand yes -fill both 

            set dse [frame $onglets_dates.list.sources.enfant -borderwidth 0 -cursor arrow -relief groove -background white]
            pack $dse -in $onglets_dates.list.sources -expand yes -fill both -side left

                 set ::gui_astrometry::dset $onglets_dates.list.sources.enfant.table

                 tablelist::tablelist $::gui_astrometry::dset \
                  -labelcommand tablelist::sortByColumn \
                  -selectmode extended \
                  -activestyle none \
                  -stripebackground #e0e8f0 \
                  -showseparators 1

                 $::gui_astrometry::dset insertcolumns end 0 "Sources" left
                 for { set j 0 } { $j < 10} { incr j } {
                    $::gui_astrometry::dset insert end $j
                 }

                 pack $::gui_astrometry::dset -in $dse -expand yes -fill both

            set dwp [frame $onglets_dates.list.wcs.parent -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $dwp -in $onglets_dates.list.wcs -expand yes -fill both -side left

                 set ::gui_astrometry::dwpt $onglets_dates.list.wcs.parent.table

                 tablelist::tablelist $::gui_astrometry::dwpt \
                   -columns $loc_dates \
                   -labelcommand tablelist::sortByColumn \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 for { set j 0 } { $j < 10} { incr j } {
                    $::gui_astrometry::dwpt insert end $j
                 }

                 pack $::gui_astrometry::dwpt -in $dwp -expand yes -fill both 

            set dwe [frame $onglets_dates.list.wcs.enfant -borderwidth 1 -cursor arrow -relief groove -background ivory]
            pack $dwe -in $onglets_dates.list.wcs -expand yes -fill both -side left

              label  $dwe.titre -text "Solution astrometrique" -borderwidth 1
              pack   $dwe.titre -in $dwe -side top -padx 3 -pady 3 -anchor c


         #  set ps [frame $onglets_sources.list.sciences.table_par -borderwidth 0 -cursor arrow -relief groove -background white]
         #  pack $ps -in $onglets_sources.list.sciences
            




#            frame $onglets0.list.sources.table_enf -borderwidth 0 -cursor arrow -relief groove -background white







         #--- Cree un frame pour afficher bouton fermeture
         set info [frame $frm.info  -borderwidth 0 -cursor arrow -relief groove]
         pack $info  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              label  $info.labf -text "Fichier resultats : " -borderwidth 1
              pack   $info.labf -in $info -side left -padx 3 -pady 3 -anchor c
              label  $info.lastres -textvariable ::tools_astrometry::last_results_file -borderwidth 1
              pack   $info.lastres -in $info -side left -padx 3 -pady 3 -anchor c






      ::tools_astrometry::load_all_cata

   }
   

   
   
   
   
   
   
   
   
   
   
   
   


   
}
