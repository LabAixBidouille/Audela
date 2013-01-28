namespace eval gui_astrometry {



   proc ::gui_astrometry::inittoconf {  } {

      global bddconf, conf
      set ::tools_astrometry::science   "SKYBOT"
      set ::tools_astrometry::reference "UCAC3"
      set ::tools_astrometry::delta 15
      set ::tools_astrometry::treshold 5
      set ::gui_astrometry::factor 1000


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






#tabval($name,$dateiso) [list $ar $ra $dec $res_ra $res_dec $ecart $mag]
#tabfield(sources,$name) $dateiso
#tabfield(science,$name) $dateiso
#tabfield(ref,$name) $dateiso
#tabfield(date,$dateiso) $name





# "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" 
# "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
# "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "flagastrom" 
# "mag" "err_mag" "name"
   proc ::gui_astrometry::see_residus {  } {

      set id_current_image 1
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
         
         incr id_current_image
      }

   
   }











   proc ::gui_astrometry::cmdButton1Click_srpt { w args } {

      foreach select [$w curselection] {
         set name [lindex [$w get $select] 0]
         gren_info "srpt name = $name \n"

         $::gui_astrometry::sret delete 0 end
         foreach date $::tools_astrometry::listref($name) {
            $::gui_astrometry::sret insert end [lreplace $::tools_astrometry::tabval($name,$date) 1 2 $date]
         }
         
         ::gui_cata::voir_sxpt $::gui_astrometry::srpt

         break
      }
   }



   proc ::gui_astrometry::cmdButton1Click_sspt { w args } {

      foreach select [$w curselection] {
         set name [lindex [$w get $select] 0]
         gren_info "name = $name \n"

         $::gui_astrometry::sset delete 0 end
         foreach date $::tools_astrometry::listscience($name) {
            $::gui_astrometry::sset insert end [lreplace $::tools_astrometry::tabval($name,$date) 1 2 $date]
         }

         ::gui_cata::voir_sxpt $::gui_astrometry::sspt

         break
      }
   }

   proc ::gui_astrometry::cmdButton1Click_dspt { w args } {

      foreach select [$w curselection] {
         set date [lindex [$w get $select] 0]
         gren_info "dspt date = $date \n"

         $::gui_astrometry::dset delete 0 end
         foreach name $::tools_astrometry::listdate($date) {
            $::gui_astrometry::dset insert end [lreplace $::tools_astrometry::tabval($name,$date) 1 1 $name]
         }

#         foreach name [array names ::tools_astrometry::listscience] {
#            $::gui_astrometry::dset insert end [lreplace $::tools_astrometry::tabval($name,$date) 1 1 $name]
#         }

#         foreach name [array names ::tools_astrometry::listref] {
#            gren_info "dspt name = $name \n"
#            gren_info "dspt name = $::tools_astrometry::listref($name) \n"
#            gren_info "dspt DATE = [array names ::tools_astrometry::listdate] \n"
            
#            $::gui_astrometry::dset insert end [lreplace $::tools_astrometry::tabval($name,$date) 1 1 $name]
#         }



         break
      }
   }


   proc ::gui_astrometry::cmdButton1Click_dwpt { w args } {

      foreach select [$w curselection] {
         set date [lindex [$w get $select] 0]
         gren_info "date = $date \n"

         break
      }
   }








   proc ::gui_astrometry::affich_gestion {  } {
       
         gren_info "\n\n\n-----------\n"
      set tt0 [clock clicks -milliseconds]

      if {$::gui_astrometry::state_gestion == 0} {
         catch {destroy .gestion_cata}
         gren_info "Chargement des fichiers XML\n"
         ::gui_cata::gestion_cata $::tools_cata::img_list
         set ::gui_astrometry::state_gestion 1
      }
      if {[info exists ::gui_cata::state_gestion] && $::gui_cata::state_gestion == 1} {
         gren_info "Chargement depuis la fenetre de gestion des sources\n"
         ::gui_astrometry::affich_catalist
      } else {
         catch {destroy .gestion_cata}
         gren_info "Chargement des fichiers XML\n"
         ::gui_cata::gestion_cata $::tools_cata::img_list
      }

      focus .astrometry

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "TOTAL Bouton Charge in $tt sec \n"

      return

   }


   proc ::gui_astrometry::affich_catalist {  } {

      ::tools_astrometry::affich_catalist

      set tt0 [clock clicks -milliseconds]

      $::gui_astrometry::srpt delete 0 end
      $::gui_astrometry::sret delete 0 end
      $::gui_astrometry::sspt delete 0 end
      $::gui_astrometry::sset delete 0 end
      $::gui_astrometry::dspt delete 0 end
      $::gui_astrometry::dset delete 0 end
      $::gui_astrometry::dwpt delete 0 end
 
      foreach name [array names ::tools_astrometry::listref] {
         $::gui_astrometry::srpt insert end $::tools_astrometry::tabref($name)
      }

      foreach name [array names ::tools_astrometry::listscience] {
         $::gui_astrometry::sspt insert end $::tools_astrometry::tabscience($name)
      }

      foreach date [array names ::tools_astrometry::listdate] {
         $::gui_astrometry::dspt insert end $::tools_astrometry::tabdate($date)
         $::gui_astrometry::dwpt insert end $::tools_astrometry::tabdate($date)
      }

      
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Affichage des resultats in $tt sec \n"


   }


   proc ::gui_astrometry::go_priam {  } {

      ::tools_astrometry::init_priam
      ::tools_astrometry::go_priam
      ::gui_astrometry::affich_catalist
   }



   proc ::gui_astrometry::priam_to_catalist {  } {

      ::tools_astrometry::affich_priam

      set tt0 [clock clicks -milliseconds]

      $::gui_astrometry::srpt delete 0 end
      $::gui_astrometry::sret delete 0 end
      $::gui_astrometry::sspt delete 0 end
      $::gui_astrometry::sset delete 0 end
      $::gui_astrometry::dspt delete 0 end
      $::gui_astrometry::dset delete 0 end
      $::gui_astrometry::dwpt delete 0 end
 
      foreach name [array names ::tools_astrometry::listref] {
         $::gui_astrometry::srpt insert end $::tools_astrometry::tabref($name)
      }

      foreach name [array names ::tools_astrometry::listscience] {
         $::gui_astrometry::sspt insert end $::tools_astrometry::tabscience($name)
      }

      foreach date [array names ::tools_astrometry::listdate] {
         $::gui_astrometry::dspt insert end $::tools_astrometry::tabdate($date)
         $::gui_astrometry::dwpt insert end $::tools_astrometry::tabdate($date)
      }

      
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Affichage des resultats in $tt sec \n"

   }











   proc ::gui_astrometry::setup { img_list } {

      global audace
      global bddconf

      ::gui_astrometry::charge_list $img_list
      ::gui_astrometry::inittoconf
      
      
      set ::gui_astrometry::state_gestion 0
      
      set loc_sources_par [list 0 "Name"              left  \
                                0 "Nb img"            right \
                                0 "\u03C1"            right \
                                0 "stdev \u03C1"      right \
                                0 "moy res \u03B1"    right \
                                0 "moy res \u03B4"    right \
                                0 "stdev res \u03B1"  right \
                                0 "stdev res \u03B4"  right \
                                0 "moy \u03B1"        right \
                                0 "moy \u03B4"        right \
                                0 "stdev \u03B1"      right \
                                0 "stdev \u03B4"      right \
                                0 "moy Mag"           right \
                                0 "stdev Mag"         right ]
      set loc_dates_enf   [list 0 "Id"                right \
                                0 "Mid-Date"          left  \
                                0 "\u03C1"            right \
                                0 "res \u03B1"        right \
                                0 "res \u03B4"        right \
                                0 "\u03B1"            right \
                                0 "\u03B4"            right \
                                0 Mag                 right \
                                0 err_Mag             right ]
      set loc_dates_par   [list 0 "Mid-Date"          left  \
                                0 "Nb ref"            right \
                                0 "\u03C1"            right \
                                0 "stdev \u03C1"      right \
                                0 "moy res \u03B1"    right \
                                0 "moy res \u03B4"    right \
                                0 "stdev res \u03B1"  right \
                                0 "stdev res \u03B4"  right \
                                0 "moy \u03B1"        right \
                                0 "moy \u03B4"        right \
                                0 "stdev \u03B1"      right \
                                0 "stdev \u03B4"      right \
                                0 "moy Mag"           right \
                                0 "stdev Mag"         right ]
      set loc_sources_enf [list 0 "Id"                right \
                                0 "Name"              left  \
                                0 "type"              center \
                                0 "\u03C1"            right \
                                0 "res \u03B1"        right \
                                0 "res \u03B4"        right \
                                0 "\u03B1"            right \
                                0 "\u03B4"            right \
                                0 Mag                 right \
                                0 err_Mag             right ]
      
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
      pack $frm -in $::gui_astrometry::fen -anchor s -side top -expand yes -fill both  -padx 10 -pady 5

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

              set ::gui_astrometry::gui_affich_gestion [button $actions.affich_gestion -text "Charge" -borderwidth 2 -takefocus 1 \
                 -relief "raised" \
                 -command "::gui_astrometry::affich_gestion"]
              pack $actions.affich_gestion -side left -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

              set ::gui_astrometry::gui_go_priam [button $actions.go_priam -text "Priam" -borderwidth 2 -takefocus 1 \
                 -command "::gui_astrometry::go_priam"]
              pack $actions.go_priam -side left -anchor e \
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
         pack $tables  -in $frm -anchor s -side top -expand 0  -padx 10 -pady 5

         set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $onglets -in $frm -side top -expand yes -fill both -padx 10 -pady 5
 
            
            pack [ttk::notebook $onglets.list] -expand yes -fill both 
 
            set sources [frame $onglets.list.sources]
            pack $sources -in $onglets.list -expand yes -fill both 
            $onglets.list add $sources -text "Sources"
            
            set dates [frame $onglets.list.dates]
            pack $dates -in $onglets.list -expand yes -fill both 
            $onglets.list add $dates -text "Dates"

            set graphes [frame $onglets.list.graphes]
            pack $graphes -in $onglets.list -expand yes -fill both 
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





            # Sources - References Parent (par liste de source et moyenne)
            set srp [frame $onglets_sources.list.references.parent -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $srp -in $onglets_sources.list.references -expand yes -fill both -side left

                 set ::gui_astrometry::srpt $srp.table
                 
                 tablelist::tablelist $::gui_astrometry::srpt \
                   -columns $loc_sources_par \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $srp.hsb set ] \
                   -yscrollcommand [ list $srp.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 scrollbar $srp.hsb -orient horizontal -command [list $::gui_astrometry::srpt xview]
                 pack $srp.hsb -in $srp -side bottom -fill x
                 scrollbar $srp.vsb -orient vertical -command [list $::gui_astrometry::srpt yview]
                 pack $srp.vsb -in $srp -side left -fill y

                 menu $srp.popupTbl -title "Tools"

                     $srp.popupTbl add command -label "Voir" \
                        -command "::gui_cata::voir_srpt"
                     $srp.popupTbl add command -label "Supprimer de toutes les images" \
                         -command "::gui_cata::unset_srpt"
                 
                 #--- bindings
                 bind $::gui_astrometry::srpt <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_srpt %W ]
                 bind [$::gui_astrometry::srpt bodypath] <ButtonPress-3> [ list tk_popup $srp.popupTbl %X %Y ]

                 pack $::gui_astrometry::srpt -in $srp -expand yes -fill both 





            # Sources - References Enfant (par liste de date chaque mesure)
            set sre [frame $onglets_sources.list.references.enfant -borderwidth 0 -cursor arrow -relief groove -background white]
            pack $sre -in $onglets_sources.list.references -expand yes -fill both -side left

                 set ::gui_astrometry::sret $sre.table

                 tablelist::tablelist $::gui_astrometry::sret \
                   -columns $loc_dates_enf \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $sre.hsb set ] \
                   -yscrollcommand [ list $sre.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1


                 scrollbar $sre.hsb -orient horizontal -command [list $::gui_astrometry::sret xview]
                 pack $sre.hsb -in $sre -side bottom -fill x
                 scrollbar $sre.vsb -orient vertical -command [list $::gui_astrometry::sret yview]
                 pack $sre.vsb -in $sre -side right -fill y

                 menu $sre.popupTbl -title "Tools"

                     $sre.popupTbl add command -label "Voir" \
                        -command "::gui_cata::voir_sret"
                     $sre.popupTbl add command -label "Supprimer de cette image uniquement" \
                        -command ""

                 bind [$::gui_astrometry::sret bodypath] <ButtonPress-3> [ list tk_popup $sre.popupTbl %X %Y ]

                 pack $::gui_astrometry::sret -in $sre -expand yes -fill both



            # Sources - Science Parent (par liste de source et moyenne)
            set ssp [frame $onglets_sources.list.sciences.parent -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $ssp -in $onglets_sources.list.sciences -expand yes -fill both -side left

                 set ::gui_astrometry::sspt $onglets_sources.list.sciences.parent.table

                 tablelist::tablelist $::gui_astrometry::sspt \
                   -columns $loc_sources_par \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $ssp.hsb set ] \
                   -yscrollcommand [ list $ssp.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 scrollbar $ssp.hsb -orient horizontal -command [list $::gui_astrometry::sspt xview]
                 pack $ssp.hsb -in $ssp -side bottom -fill x
                 scrollbar $ssp.vsb -orient vertical -command [list $::gui_astrometry::sspt yview]
                 pack $ssp.vsb -in $ssp -side left -fill y

                 menu $ssp.popupTbl -title "Tools"

                     $ssp.popupTbl add command -label "Supprimer de toutes les images" \
                         -command ""

                 bind $::gui_astrometry::sspt <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_sspt %W ]
                 bind [$::gui_astrometry::sspt bodypath] <ButtonPress-3> [ list tk_popup $ssp.popupTbl %X %Y ]

                 pack $::gui_astrometry::sspt -in $ssp -expand yes -fill both 





            # Sources - Science Enfant (par liste de date chaque mesure)
            set sse [frame $onglets_sources.list.sciences.enfant -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $sse -in $onglets_sources.list.sciences -expand yes -fill both -side left

                 set ::gui_astrometry::sset $onglets_sources.list.sciences.enfant.table

                 tablelist::tablelist $::gui_astrometry::sset \
                   -columns $loc_dates_enf \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $sse.hsb set ] \
                   -yscrollcommand [ list $sse.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 scrollbar $sse.hsb -orient horizontal -command [list $::gui_astrometry::sset xview]
                 pack $sse.hsb -in $sse -side bottom -fill x
                 scrollbar $sse.vsb -orient vertical -command [list $::gui_astrometry::sset yview]
                 pack $sse.vsb -in $sse -side right -fill y

                 menu $sse.popupTbl -title "Tools"

                     $sse.popupTbl add command -label "Supprimer de cette image uniquement" \
                        -command ""

                 bind [$::gui_astrometry::sset bodypath] <ButtonPress-3> [ list tk_popup $sre.popupTbl %X %Y ]

                 pack $::gui_astrometry::sset -in $sse -expand yes -fill both





            # Dates - Sources Parent (par liste de dates et moyenne)
            set dsp [frame $onglets_dates.list.sources.parent -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $dsp -in $onglets_dates.list.sources -expand yes -fill both -side left

                 set ::gui_astrometry::dspt $onglets_dates.list.sources.parent.table

                 tablelist::tablelist $::gui_astrometry::dspt \
                   -columns $loc_dates_par \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $dsp.hsb set ] \
                   -yscrollcommand [ list $dsp.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1


                 scrollbar $dsp.hsb -orient horizontal -command [list $::gui_astrometry::dspt xview]
                 pack $dsp.hsb -in $dsp -side bottom -fill x
                 scrollbar $dsp.vsb -orient vertical -command [list $::gui_astrometry::dspt yview]
                 pack $dsp.vsb -in $dsp -side left -fill y

                 menu $dsp.popupTbl -title "Tools"

                     $dsp.popupTbl add command -label "Supprimer l'image" \
                         -command ""
                 

                 bind $::gui_astrometry::dspt <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_dspt %W ]
                 bind [$::gui_astrometry::dspt bodypath] <ButtonPress-3> [ list tk_popup $dsp.popupTbl %X %Y ]

                 pack $::gui_astrometry::dspt -in $dsp -expand yes -fill both 




            # Dates - Sources Enfant (par liste de sources chaque mesure)
            set dse [frame $onglets_dates.list.sources.enfant -borderwidth 0 -cursor arrow -relief groove -background white]
            pack $dse -in $onglets_dates.list.sources -expand yes -fill both -side left

                 set ::gui_astrometry::dset $dse.table

                 tablelist::tablelist $::gui_astrometry::dset \
                   -columns $loc_sources_enf \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $dse.hsb set ] \
                   -yscrollcommand [ list $dse.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1


                 scrollbar $dse.hsb -orient horizontal -command [list $::gui_astrometry::dset xview]
                 pack $dse.hsb -in $dse -side bottom -fill x
                 scrollbar $dse.vsb -orient vertical -command [list $::gui_astrometry::dset yview]
                 pack $dse.vsb -in $dse -side right -fill y

                 menu $dse.popupTbl -title "Tools"

                     $dse.popupTbl add command -label "Supprimer de cette image uniquement" \
                        -command ""

                 bind [$::gui_astrometry::dset bodypath] <ButtonPress-3> [ list tk_popup $dse.popupTbl %X %Y ]

                 pack $::gui_astrometry::dset -in $dse -expand yes -fill both





            # Dates - WCS Parent (par liste de dates et moyenne)
            set dwp [frame $onglets_dates.list.wcs.parent -borderwidth 1 -cursor arrow -relief groove -background white]
            pack $dwp -in $onglets_dates.list.wcs -expand yes -fill both -side left

                 set ::gui_astrometry::dwpt $onglets_dates.list.wcs.parent.table

                 tablelist::tablelist $::gui_astrometry::dwpt \
                   -columns $loc_dates_par \
                   -labelcommand tablelist::sortByColumn \
                   -xscrollcommand [ list $dwp.hsb set ] \
                   -yscrollcommand [ list $dwp.vsb set ] \
                   -selectmode extended \
                   -activestyle none \
                   -stripebackground #e0e8f0 \
                   -showseparators 1

                 scrollbar $dwp.hsb -orient horizontal -command [list $::gui_astrometry::dwpt xview]
                 pack $dwp.hsb -in $dwp -side bottom -fill x
                 scrollbar $dwp.vsb -orient vertical -command [list $::gui_astrometry::dwpt yview]
                 pack $dwp.vsb -in $dwp -side left -fill y

                 bind $::gui_astrometry::dwpt <<ListboxSelect>> [ list ::gui_astrometry::cmdButton1Click_dwpt %W ]

                 pack $::gui_astrometry::dwpt -in $dwp -expand yes -fill both 



            # Dates - WCS Enfant (Solution astrometrique)
            set dwe [frame $onglets_dates.list.wcs.enfant -borderwidth 1 -cursor arrow -relief groove -background ivory]
            pack $dwe -in $onglets_dates.list.wcs -expand yes -fill both -side left

              label  $dwe.titre -text "Solution astrometrique" -borderwidth 1
              pack   $dwe.titre -in $dwe -side top -padx 3 -pady 3 -anchor c


         #  set ps [frame $onglets_sources.list.sciences.table_par -borderwidth 0 -cursor arrow -relief groove -background white]
         #  pack $ps -in $onglets_sources.list.sciences
            




#            frame $onglets0.list.sources.table_enf -borderwidth 0 -cursor arrow -relief groove -background white







         #--- Cree un frame pour afficher bouton fermeture
         set info [frame $frm.info  -borderwidth 0 -cursor arrow -relief groove]
         pack $info  -in $frm -anchor s -side bottom -expand 0 -fill x -padx 10 -pady 5

              label  $info.labf -text "Fichier resultats : " -borderwidth 1
              pack   $info.labf -in $info -side left -padx 3 -pady 3 -anchor c
              label  $info.lastres -textvariable ::tools_astrometry::last_results_file -borderwidth 1
              pack   $info.lastres -in $info -side left -padx 3 -pady 3 -anchor c







   }
   

   
   
   
   
   
   
   
   
   
   
   
   


   
}
