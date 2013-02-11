#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages bdi_cata_gestion_gui.tcl ]
#--------------------------------------------------
#
# Fichier        : cata_gestion_gui.tcl
# Description    : GUI de Gestion des catalogues 
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: cata_gestion_gui.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace cata_gestion_gui
#
#--------------------------------------------------


namespace eval cata_gestion_gui {






   proc ::cata_gestion_gui::inittoconf {  } {

      if {! [info exists ::tools_cata::astroid_saturation] } {
         if {[info exists conf(astrometry,cata,astroid,saturation)]} {
            set ::tools_cata::astroid_saturation $conf(astrometry,cata,astroid,saturation)
         } else {
            set ::tools_cata::astroid_saturation 50000
         }
      }
      if {! [info exists ::tools_cata::astroid_delta] } {
         if {[info exists conf(astrometry,cata,astroid,delta)]} {
            set ::tools_cata::astroid_delta $conf(astrometry,cata,astroid,delta)
         } else {
            set ::tools_cata::astroid_delta 15
         }
      }
      if {! [info exists ::tools_cata::astroid_threshold] } {
         if {[info exists conf(astrometry,cata,astroid,threshold)]} {
            set ::tools_cata::astroid_threshold $conf(astrometry,cata,astroid,threshold)
         } else {
            set ::tools_cata::astroid_threshold 5
         }
      }

      # Uncosmic or not
      if {! [info exists ::gui_cata::use_uncosmic] } {
         if {[info exists conf(astrometry,cata,use_uncosmic)]} {
            set ::gui_cata::use_uncosmic $conf(astrometry,cata,use_uncosmic)
         } else {
            set ::gui_cata::use_uncosmic 1
         }
      }
      if {! [info exists ::tools_cdl::uncosm_param1] } {
         if {[info exists conf(astrometry,cata,uncosm_param1)]} {
            set ::tools_cdl::uncosm_param1 $conf(astrometry,cata,uncosm_param1)
         } else {
            set ::tools_cdl::uncosm_param1 0.8
         }
      }
      if {! [info exists ::tools_cdl::uncosm_param2] } {
         if {[info exists conf(astrometry,cata,uncosm_param2)]} {
            set ::tools_cdl::uncosm_param2 $conf(astrometry,cata,uncosm_param2)
         } else {
            set ::tools_cdl::uncosm_param2 100
         }
      }

   }



# Anciennement ::gui_cata::fermer_feng
# ferme la fenetre de gestion de catalogues

   proc ::cata_gestion_gui::fermer { } {

      set ::cata_gestion_gui::state_gestion 0
      cleanmark
      destroy $::cata_gestion_gui::fen

   }








# Anciennement ::gui_cata::gestion_back

   proc ::cata_gestion_gui::back { } {

      if {$::cata_gestion_gui::directaccess==1 } { return }
      incr ::cata_gestion_gui::directaccess -1
      ::cata_gestion_gui::charge_image_directaccess

   }








# Anciennement ::gui_cata::gestion_next

   proc ::cata_gestion_gui::next { } {

      if {$::cata_gestion_gui::directaccess==$::tools_cata::nb_img_list } { return }
      incr ::cata_gestion_gui::directaccess 
      ::cata_gestion_gui::charge_image_directaccess

   }
   









# Anciennement ::gui_cata::gestion_go
# Charge une image en memoire dont l id est celui de la liste ::tools_cata::img_list
# l'id evolue de 1 a $::tools_cata::nb_img_list
# l image est chargée en memoire : ::tools_cata::current_image
# mais aussi dans la visu d audace

   proc ::cata_gestion_gui::charge_image_directaccess { } {

      set ::tools_cata::id_current_image $::cata_gestion_gui::directaccess

      gren_info "image = $::tools_cata::id_current_image / $::tools_cata::nb_img_list\n"
      ::cata_gestion_gui::set_progress 0 100      

      set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]
      set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set ::tools_cata::current_image_date [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]

      set ::tools_cata::current_image_name [::bddimages_liste::lget $::tools_cata::current_image "filename"]
      set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

      ::cata_gestion_gui::set_progress 25 100

      array set ::gui_cata::tklist_list_of_columns $::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns)
      array set ::gui_cata::tklist                 $::gui_cata::tk_list($::tools_cata::id_current_image,tklist)
      array set ::gui_cata::cataname               $::gui_cata::tk_list($::tools_cata::id_current_image,cataname)

      ::cata_gestion_gui::set_progress 50 100

      ::cata_gestion_gui::affich_current_tklist

      ::cata_gestion_gui::set_progress 75 100

      ::gui_cata::affiche_current_image

      ::cata_gestion_gui::set_progress 100 100
      gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

   }












# Anciennement ::gui_cata::affich_current_tklist


   proc ::cata_gestion_gui::affich_current_tklist { } {


      set onglets $::cata_gestion_gui::fen.appli.onglets
   
      # TODO afficher l image ici
   
      set listsources $::tools_cata::current_listsources
      set fields [lindex $listsources 0]
   
      set nbcatadel [expr [llength [array get ::gui_cata::cataname]]/2]
      #gren_info "cataname = [array get ::gui_cata::cataname] \n"
      #gren_info "nbcatadel = $nbcatadel \n"
   
      foreach t [$onglets.nb tabs] {
         destroy $t
      }

      set idcata 0
      set select 0
      foreach field $fields {
         incr idcata
         
         set fc($idcata) [frame $onglets.nb.f$idcata]
         
         set c [lindex $field 0]
         
         $onglets.nb add $fc($idcata) -text $c
         if {$c=="IMG"} {
            set select $idcata
         }
      }
      set nbcata $idcata
      #gren_info "nbcata : $nbcata\n"
   
      if {$select >0} {$onglets.nb select $fc($select)}
      ttk::notebook::enableTraversal $onglets.nb

      for { set idcata 1 } { $idcata <= $nbcata} { incr idcata } {

         set ::cata_gestion_gui::frmtable($idcata) [frame $fc($idcata).frmtable -borderwidth 0 -cursor arrow -relief groove -background white]
         pack $::cata_gestion_gui::frmtable($idcata) -expand yes -fill both -padx 3 -pady 6 -in $fc($idcata) -side right -anchor e

         #--- Cree un acsenseur vertical
         scrollbar $::cata_gestion_gui::frmtable($idcata).vsb -orient vertical \
            -command { $::cata_gestion_gui::frmtable($idcata).lst1 yview } -takefocus 1 -borderwidth 1
         pack $::cata_gestion_gui::frmtable($idcata).vsb -in $::cata_gestion_gui::frmtable($idcata) -side right -fill y

         #--- Cree un acsenseur horizontal
         scrollbar $::cata_gestion_gui::frmtable($idcata).hsb -orient horizontal \
            -command { $::cata_gestion_gui::frmtable($idcata).lst1 xview } -takefocus 1 -borderwidth 1
         pack $::cata_gestion_gui::frmtable($idcata).hsb -in $::cata_gestion_gui::frmtable($idcata) -side bottom -fill x

         #--- Creation de la table
         ::cata_gestion_gui::create_Tbl_sources $idcata
         pack  $::cata_gestion_gui::frmtable($idcata).tbl -in  $::cata_gestion_gui::frmtable($idcata) -expand yes -fill both


         catch { $::cata_gestion_gui::frmtable($idcata).tbl delete 0 end
                 $::cata_gestion_gui::frmtable($idcata).tbl deletecolumns 0 end  
         }
        
         set nbcol [llength $::gui_cata::tklist_list_of_columns($idcata)]
         for { set j 0 } { $j < $nbcol} { incr j } {
            set current_columns [lindex $::gui_cata::tklist_list_of_columns($idcata) $j]
            $::cata_gestion_gui::frmtable($idcata).tbl insertcolumns end 0 [lindex $current_columns 1] left
            $::cata_gestion_gui::frmtable($idcata).tbl columnconfigure $j -sortmode dictionary
         }

         #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
         if { [ $::cata_gestion_gui::frmtable($idcata).tbl columncount ] != "0" } {
            $::cata_gestion_gui::frmtable($idcata).tbl columnconfigure 0 -sortmode dictionary
         }
         foreach col {5 6 7 8 9} {
             $::cata_gestion_gui::frmtable($idcata).tbl columnconfigure $col -background ivory -sortmode dictionary
         }

         foreach line $::gui_cata::tklist($idcata) {
            $::cata_gestion_gui::frmtable($idcata).tbl insert end $line
         }
         
         #gren_info "$::gui_cata::cataname($idcata) : [llength $::gui_cata::tklist($idcata)]\n"
         #gren_info "onglets : [$::cata_gestion_gui::fen.appli.onglets.nb tabs]\n"
         
         $::cata_gestion_gui::fen.appli.onglets.nb tab [expr $idcata - 1] -text "([llength $::gui_cata::tklist($idcata)])$::gui_cata::cataname($idcata)"
         
      }
   }











# Anciennement ::gui_cata::set_progress

   proc ::cata_gestion_gui::set_progress { cur max } {
      set ::cata_gestion_gui::progress [format "%0.0f" [expr $cur * 100. /$max ] ]
      update
   }
   proc ::cata_gestion_gui::set_popupprogress { cur max } {
      set ::cata_gestion_gui::popupprogress [format "%0.0f" [expr $cur * 100. /$max ] ]
      update
   }







# Anciennement ::gui_cata::charge_memory


   proc ::cata_gestion_gui::charge_memory { { gui 1 } } {

      if {$gui} {
      
         set state [$::cata_gestion_gui::fen.appli.actions.charge cget -text]

         if  {$state == "Annuler"} {
             set ::gui_cata::annul 1
             return
         }

         set ::gui_cata::annul 0
         $::cata_gestion_gui::fen.appli.actions.charge configure -text "Annuler"
      }

      for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image<=$::tools_cata::nb_img_list} {incr ::tools_cata::id_current_image} {
         
         if {$gui} {
            if {$::gui_cata::annul == 1} {
               gren_info "Chargement annulé...\n"
               break
            }
            ::cata_gestion_gui::set_progress $::tools_cata::id_current_image $::tools_cata::nb_img_list
         }

         ::cata_gestion_gui::charge_current_cata

      }

      if {$gui} { ::cata_gestion_gui::set_progress 0 $::tools_cata::nb_img_list 

         $::cata_gestion_gui::fen.appli.actions.charge configure -text "Charge"

         set ::cata_gestion_gui::directaccess 1
         ::cata_gestion_gui::charge_image_directaccess
      }

   }







# Anciennement ::gui_cata::charge_current_cata

   proc ::cata_gestion_gui::charge_current_cata { } {

      global bddconf
 
      #gren_info "charge_current_cata ::tools_cata::id_current_image = $::tools_cata::id_current_image\n"

      set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]
      set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]

      set ::tools_cata::current_image_date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
      set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
      set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
      set ::tools_cata::current_image_name [::bddimages_liste::lget $::tools_cata::current_image "filename"]
      set file        [file join $bddconf(dirbase) $dirfilename $::tools_cata::current_image_name]
      
      ::gui_cata::load_cata

      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
      #gren_info "charge_current_catas ::tools_cata::id_current_image=$::tools_cata::id_current_image\n"

      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources

      # chargement de la tklist sous forme de liste tcl. (pour affichage)
      ::tools_cata::current_listsources_to_tklist

      set ::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::gui_cata::tklist_list_of_columns]
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::gui_cata::tklist]
      set ::gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::gui_cata::cataname]

   }








# Anciennement ::gui_cata::charge_gestion_cata

   proc ::cata_gestion_gui::charge_gestion_cata { img_list } {

      global audace
      global bddconf

     catch {
         if { [ info exists $::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
         if { [ info exists $::tools_cata::nb_img_list ] }        {unset ::tools_cata::nb_img_list}
         if { [ info exists $::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
         if { [ info exists $::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
      }

      set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
      set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]

      # Chargement premiere image sans GUI
      set ::tools_cata::id_current_image 1
      set ::tools_cata::current_image [lindex $::tools_cata::img_list 0]

      set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]

      set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
      set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
      set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
      set filename    [::bddimages_liste::lget $::tools_cata::current_image filename   ]
      set file        [file join $bddconf(dirbase) $dirfilename $filename]

      set ::tools_cata::current_image_name $filename
      set ::tools_cata::current_image_date $date

      #?Charge l image a l ecran
      buf$::audace(bufNo) load $file
      cleanmark

      set ::gui_cata::stateback disabled
      set ::tools_cata::nb_img     0
      set ::tools_cata::nb_usnoa2  0
      set ::tools_cata::nb_tycho2  0
      set ::tools_cata::nb_ucac2   0
      set ::tools_cata::nb_ucac3   0
      set ::tools_cata::nb_nomad1  0
      set ::tools_cata::nb_skybot  0
      set ::tools_cata::nb_astroid 0

      ::gui_cata::affiche_current_image
      ::gui_cata::affiche_cata

   }









# Anciennement ::gui_cata::create_Tbl_sources


   proc ::cata_gestion_gui::create_Tbl_sources { idcata } {

      variable This
      global audace
      global caption
      global bddconf

      #--- Quelques raccourcis utiles
      set tbl $::cata_gestion_gui::frmtable($idcata).tbl
      set popupTbl $::cata_gestion_gui::frmtable($idcata).popupTbl

      #--- Table des objets
      tablelist::tablelist $tbl \
         -labelcommand tablelist::sortByColumn \
         -xscrollcommand [ list $::cata_gestion_gui::frmtable($idcata).hsb set ] \
         -yscrollcommand [ list $::cata_gestion_gui::frmtable($idcata).vsb set ] \
         -selectmode extended \
         -activestyle none \
         -stripebackground #e0e8f0 \
         -showseparators 1

      #--- Scrollbars verticale et horizontale
      $::cata_gestion_gui::frmtable($idcata).vsb configure -command [ list $tbl yview ]
      $::cata_gestion_gui::frmtable($idcata).hsb configure -command [ list $tbl xview ]

      #--- Gestion des popup

      #--- Menu pop-up associe a la table
      menu $popupTbl -title "Selection"

        # Edite la liste selectionnee
        $popupTbl add command -label "Grab les sources" \
           -command "::cata_gestion_gui::grab_sources $tbl"

        # Edite la liste selectionnee
        $popupTbl add command -label "Propager les sources" \
           -command "::cata_gestion_gui::propagation $tbl"

        # Separateur
        $popupTbl add separator

        # Edite la liste selectionnee
        $popupTbl add command -label "Editer la source" \
           -command "::cata_gestion_gui::edit_source $tbl" -state disable

        # Edite la liste selectionnee
        $popupTbl add command -label "Sauver la source" \
           -command "" -state disable

        # Supprime les sources selectionnees dans l'image courante
        $popupTbl add command -label "Supprimer dans l'image courante" \
           -command "::cata_gestion_gui::delete_sources $tbl"

        # Supprime les sources selectionnees dans toutes les images
        $popupTbl add command -label "Supprimer dans toutes les images" \
           -command "::cata_gestion_gui::delete_sources_allimg $tbl"

        # Separateur
        $popupTbl add separator

        # Edite la liste selectionnee
        $popupTbl add command -label "Unset" \
           -command "::cata_gestion_gui::unset_flag $tbl"

        # Separateur
        $popupTbl add separator

        # Edite la liste selectionnee
        $popupTbl add command -label "Set astrometric reference" \
           -command "::cata_gestion_gui::set_astrom_ref $tbl"

        # Supprime la liste selectionnee
        $popupTbl add command -label "Set astrometric mesure" \
           -command "::cata_gestion_gui::set_astrom_mes $tbl"

        # Separateur
        $popupTbl add separator

        # Edite la liste selectionnee
        $popupTbl add command -label "Set photometric reference" \
           -command "::cata_gestion_gui::set_photom_ref $tbl"

        # Edite la liste selectionnee
        $popupTbl add command -label "Set photometric mesure" \
           -command "::cata_gestion_gui::set_photom_mes $tbl"

        # Separateur
        $popupTbl add separator

        # Edite la liste selectionnee
        $popupTbl add command -label "PSF Auto -> ASTROID" \
           -command "::cata_gestion_gui::psf_popup_auto $tbl" -state normal

        # Separateur
        $popupTbl add separator

        # Edite la liste selectionnee
        $popupTbl add command -label "Cataloguer la source" \
           -command "" -state disable


      #--- Gestion des evenements
      bind [$tbl bodypath] <Control-Key-a> [ list ::cata_gestion_gui::selectall $tbl ]
      bind $tbl <<ListboxSelect>> [ list ::cata_gestion_gui::cmdButton1Click %W ]
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
      
   }












 
 













# Anciennement ::gui_cata::grab_sources

   proc ::cata_gestion_gui::grab_sources { { tbl "" } } {

      global audace

      set color red
      set width 2
      cleanmark
      if {$tbl!=""} {
         gren_info "grab_sources GUI\n"
         $tbl selection clear 0 end
      }

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "Veuillez dessiner un carre dans l'image (avec un clic gauche)" -type ok
         return
      }

      set sources [lindex $::tools_cata::current_listsources 1]
      set id 1
      set cpt_grab 0
      foreach s $sources {

         set x -100
         set y -100
         foreach cata $s {
         
            set x -100
            set y -100
            set pass "no"
                        
            if {[lindex $cata 0] == "IMG"} {
               set ra [lindex [lindex $cata 1] 0]
               set dec [lindex [lindex $cata 1] 1]
               set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
               set x [lindex $xy 0]
               set y [lindex $xy 1]
               if {$x > [lindex $rect 0] && $x < [lindex $rect 2] && $y > [lindex $rect 1] && $y < [lindex $rect 3]} {
                  set pass "yes"
                  set xpass $x
                  set ypass $y
               }
            }
            if {[lindex $cata 0] == "ASTROID"} {
               set ra [lindex [lindex $cata 1] 0]
               set dec [lindex [lindex $cata 1] 1]
               set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
               set x [lindex $xy 0]
               set y [lindex $xy 1]
               if {$x > [lindex $rect 0] && $x < [lindex $rect 2] && $y > [lindex $rect 1] && $y < [lindex $rect 3]} {
                  set pass "yes"
                  set xpass $x
                  set ypass $y
               }
            }
            
            if {$pass=="yes"} {

               incr cpt_grab

               set pos [lsearch -index 0 $s "IMG"]
               if {$pos != -1} {
                   set ra [lindex [lindex $cata 1] 0]
                   set dec [lindex [lindex $cata 1] 1]
                   set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
                   set x [lindex $xy 0]
                   set y [lindex $xy 1]
                   affich_un_rond $ra $dec green 3 
                   affich_un_rond_xy $x $y green 1 10
               }

               set pos [lsearch -index 0 $s "ASTROID"]         
               if {$pos != -1} {
                  set cata [lindex $s $pos]
                  affich_un_rond_xy  [lindex [lindex $cata 2] 0] [lindex [lindex $cata 2] 1] red 30 1
                  set ra [lindex [lindex $cata 1] 0]
                  set dec [lindex [lindex $cata 1] 1]
                  set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
                  set x [lindex $xy 0]
                  set y [lindex $xy 1]
                  affich_un_rond $ra $dec blue 2
                  affich_un_rond_xy $x $y blue 1 5
               }

               # selection de la source
               set u 0
               # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
               # l indice de la table.
               if {$tbl!=""} {
                  foreach l [$tbl get 0 end] {
                     set idx [lindex $l 0]
                     if {$idx == $id} {
                        $tbl selection set $u
                        
                        set namable [::manage_source::namable $s]
                        if {$namable==""} {
                           set name ""
                        } else {
                           set name [::manage_source::naming $s $namable]
                        } 
                        
                        gren_info "mNAME ($id) = $name "
                        foreach cata $s {
                           gren_info "[lindex $cata 0] "
                        }
                        gren_info "\n"
                        break
                     }
                     incr u
                  }

               }
               break
            }
         }
         incr id
      }
      if {$cpt_grab==0} { return [list 1 "Unknown"] }
      return 
   }


















# Anciennement ::gui_cata::propagation

   proc ::cata_gestion_gui::propagation { tbl } {

      set onglets $::cata_gestion_gui::fen.appli.onglets

      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]
      if {[string compare -nocase $cataselect "ASTROID"] == 0} {
         
         set propalist ""
         foreach select [$tbl curselection] {

            set id   [lindex [$tbl get $select] [::gui_cata::get_pos_col bdi_idc_lock $idcata]]
            set ar   [lindex [$tbl get $select] [::gui_cata::get_pos_col astrom_reference $idcata]]
            set ac   [lindex [$tbl get $select] [::gui_cata::get_pos_col astrom_catalog $idcata]]
            set pr   [lindex [$tbl get $select] [::gui_cata::get_pos_col photom_reference $idcata]]
            set pc   [lindex [$tbl get $select] [::gui_cata::get_pos_col photom_catalog $idcata]]
            set name [lindex [$tbl get $select] [::gui_cata::get_pos_col name $idcata]]
            set cata ""
            if {$ac != "-"} {
               set cata $ac
            } elseif {$pc != "-"} {
               set cata $pc
            }

            set s [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
            set namable [::manage_source::namable $s]

            #gren_info "namable = $namable\n"
            if {$namable==""} {
               set res [tk_messageBox -message "La source dont l'ID est $id ne peut pas etre propagee vers d'autres images car elle n est referencee dans aucun catalogue. Continuer quand meme ?" -type yesno]
               #gren_info "res = $res\n"
               if {$res=="no"} {
                  return
               } else {
                  continue
               }
            }
            
            gren_info "\n*** s = $s \n\n"
            if {$cata!=""} {
               set name [::manage_source::naming $s $cata]
            } else {
               gren_info "\n***"
               set cata $namable
               set name [::manage_source::naming $s $cata]
            }
            gren_info "$id :: $ar $ac :: $pr $pc :: $name :: $cata\n"
            lappend propalist [list $cata $name $ar $ac $pr $pc]
         }
         
         if {[llength $propalist] > 0} {
            #gren_info "propalist =$propalist\n"
         } else {
            gren_info "Rien a faire ...\n"
            return
         }

         # on sauve les variables courantes
         set tklist_list_of_columns_sav [array get ::gui_cata::tklist_list_of_columns]
         
         # on boucle sur les images (sauf celle qui est courrante car rien a propager)
         for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {

            if {$i == $::tools_cata::id_current_image} { continue }
               
            gren_info "Image =$i / $::tools_cata::nb_img_list\n"

            array set tklist                             $::gui_cata::tk_list($i,tklist)
            array set ::gui_cata::tklist_list_of_columns $::gui_cata::tk_list($i,list_of_columns)
            array set cataname                           $::gui_cata::tk_list($i,cataname)
            set current_listsources                      $::gui_cata::cata_list($i)
            set sources [lindex $current_listsources 1]

            #array set ::gui_cata::tklist                 $::gui_cata::tk_list($::tools_cata::id_current_image,tklist)
            #array set ::gui_cata::tklist_list_of_columns $::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns)
            #array set ::gui_cata::cataname               $::gui_cata::tk_list($::tools_cata::id_current_image,cataname)
            #set ::tools_cata::current_listsources        $::gui_cata::cata_list($::tools_cata::id_current_image)
            
            #gren_info "cataname = [array get cataname]\n"
            foreach {x y} [array get cataname] {
               #gren_info "getid=$x $y\n"
               set getid($y) $x
            }

            set nbcol [array size ::gui_cata::tklist_list_of_columns]
#            gren_info "nbcol =$nbcol\n"

            # Ob boucle sur les sources a propager
            foreach c $propalist {
            
               set cata [lindex $c 0]
               set name [lindex $c 1]
               set ar   [lindex $c 2]
               set ac   [lindex $c 3]
               set pr   [lindex $c 4]
               set pc   [lindex $c 5]

               set err [catch {set idcata $getid($cata)} msg]
               if {$err} {
                  continue
               }
               
#               gren_info "$cata ($idcata) :: $name :: $ar $ac :: $pr $pc\n"

               # on boucle sur les sources du cata
               set cpt 1
               set pass "no"
               foreach s $sources {
               
                  foreach c $s {
                     if {[lindex $c 0]==$cata} {
                        set namesou [::manage_source::naming $s $cata]
                        if {$namesou==$name} {
                           set pass "ok"
                           break
                        }
                     }
                  }
                  
                  if {$pass=="ok"} {break}
                  incr cpt
               }

               if {$pass=="ok"} {

                  #gren_info "source retrouvee $cpt $name\n"

                  # Modif TKLIST
                  foreach {idcata cata} [array get cataname] {

                     set pos [lsearch -index 0 $tklist($idcata) $cpt]
                     if {$pos != -1} {
                        set b [lindex $tklist($idcata) $pos]
                        #gren_info "*** $idcata $cata\n"
                        #gren_info "b = $b\n"
                        set col [::gui_cata::get_pos_col astrom_reference $idcata]
                        #gren_info "     ar = $ar , $col, [lindex $b $col]\n"
                        set b [lreplace $b $col $col $ar]
                        set col [::gui_cata::get_pos_col astrom_catalog $idcata]
                        #gren_info "     ac = $ac , $col, [lindex $b $col]\n"
                        set b [lreplace $b $col $col $ac]
                        set col [::gui_cata::get_pos_col photom_reference $idcata]
                        #gren_info "     pr = $pr , $col, [lindex $b $col]\n"
                        set b [lreplace $b $col $col $pr]
                        set col [::gui_cata::get_pos_col photom_catalog $idcata]
                        #gren_info "     pc = $pc , $col, [lindex $b $col]\n"
                        set b [lreplace $b $col $col $pc]
                        if {[string compare -nocase $cata "ASTROID"] == 0} {

                           #gren_info "tklist_list_of_columns =  $::gui_cata::tklist_list_of_columns($idcata)\n"

                           set col [::gui_cata::get_pos_col flagastrom $idcata]
                           #gren_info "     aar = $ar , $col, [lindex $b $col]\n"
                           set b [lreplace $b $col $col $ar]

                           set col [::gui_cata::get_pos_col cataastrom $idcata]
                           #gren_info "     aac = $ac , $col, [lindex $b $col]\n"
                           set b [lreplace $b $col $col $ac]

                           set col [::gui_cata::get_pos_col flagphotom $idcata]
                           #gren_info "     apr = $pr , $col, [lindex $b $col]\n"
                           set b [lreplace $b $col $col $pr]

                           set col [::gui_cata::get_pos_col cataphotom $idcata]
                           #gren_info "     apc = $pc , $col, [lindex $b $col]\n"
                           set b [lreplace $b $col $col $pc]
                        }
                        set tklist($idcata) [lreplace $tklist($idcata) $pos $pos $b]
                        #gren_info "a modif = [lindex $tklist($idcata) $pos]\n"



                     }
                     
                  }
                  
                  # Modif CATALIST
                  set s [lindex $sources [expr $cpt -1]]
                  #gren_info "S = $s\n"
                  set x  [lsearch -index 0 $s "ASTROID"]
                  if {$x>=0} {
                     set a [lindex $s $x]
                     set b [lindex $a 2]
                     set b [lreplace $b 25 25 $ar]
                     set b [lreplace $b 27 27 $ac]
                     set b [lreplace $b 26 26 $pr]
                     set b [lreplace $b 28 28 $pc]
                     set a [lreplace $a 2 2 $b]
                     #gren_info "a modif = $a\n"
                     set s [lreplace $s $x $x $a]
                     #gren_info "S modif = $s\n"
                     set sources [lreplace $sources [expr $cpt -1] [expr $cpt -1] $s]
                  }
               }
               
            }

            # Modification du tk_list
            set ::gui_cata::tk_list($i,tklist) [array get tklist]

            # Modification du cata_list
            set ::gui_cata::cata_list($i) [list [lindex $current_listsources 0] $sources]
             
            # break

         }

         # on recupere les variables courantes
         array set ::gui_cata::tklist_list_of_columns $tklist_list_of_columns_sav

      } else {
         tk_messageBox -message "Le catalogue selectionné doit etre ASTROID" -type ok
      }

   }
 
 













# Anciennement ::gui_cata::edit_source

   proc ::cata_gestion_gui::edit_source { tbl } {
# 
#      foreach select [$tbl curselection] {
#         $tbl cellconfigure $select, -text $flag
#      }
#      $tbl rowconfigure -editable yes
#
#   
   }




 













# Anciennement ::gui_cata::delete_sources

   proc ::cata_gestion_gui::delete_sources { tbl } {

      set onglets $::cata_gestion_gui::fen.appli.onglets
      set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

      # On boucle sur les selections (indice de la table affichée de 0 a end)
      set cpt 0
      foreach select [$tbl curselection] {
         
         set id [lindex [$tbl get $select] 0]
         # On boucle sur les onglets
         foreach t [$onglets.nb tabs] {
            set idcata [string index [lindex [split $t .] 5] 1]
            # modification de la tklist
            set x [lsearch -index 0 $::gui_cata::tklist($idcata) $id]
            if {$x != -1} {
               set ::gui_cata::tklist($idcata) [lreplace $::gui_cata::tklist($idcata) $x $x]
            }
         }

         # Modification du current_listsources
         set fields [lindex $::tools_cata::current_listsources 0]
         set sources [lindex $::tools_cata::current_listsources 1]
         set sources [lreplace $sources [expr $select-$cpt] [expr $select-$cpt]]
         set ::tools_cata::current_listsources [list $fields $sources]

         # Compteur de sources effacees
         incr cpt
      }
      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::gui_cata::tklist]
      ::cata_gestion_gui::charge_image_directaccess
      return
 
   }















# Anciennement ::gui_cata::delete_sources_allimg

   proc ::cata_gestion_gui::delete_sources_allimg { tbl } {

      set onglets $::cata_gestion_gui::fen.appli.onglets
      set idcata [string index [lindex [split $tbl .] 5] 1]
         
      set dellist ""
      foreach select [$tbl curselection] {
         set id [lindex [$tbl get $select] [::gui_cata::get_pos_col bdi_idc_lock $idcata]]
         set s [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
         set sname [::manage_source::naming $s "IMG"]
         lappend dellist $sname
      }
gren_info "ListToDel: $dellist\n"

      # Si la liste est vide, rien a faire
      if {[llength $dellist] < 1} {
         return
      }

      # On boucle sur les images (sauf celle qui est courrante car rien a propager)
      for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {

::console::affiche_erreur "Image #$i / $::tools_cata::nb_img_list\n"

         array set tklist $::gui_cata::tk_list($i,tklist)
         array set cataname $::gui_cata::tk_list($i,cataname)
gren_info "cataname = [array get ::gui_cata::cataname]\n"
         set current_listsources $::gui_cata::cata_list($i)
         set sources [lindex $current_listsources 1]
#gren_info "sources = $sources \n"

            foreach {x y} [array get cataname] {
               set getid($y) $x
            }

         # On boucle sur les sources a effacer
         foreach dl $dellist {

gren_info "DL = $dl\n"

            # on boucle sur les sources du cata
            set cpt 1
            set pass "no"
            foreach s $sources {
               foreach c $s {
                  if {[lindex $c 0] == "IMG"} {
                     set namesou [::manage_source::naming $s "IMG"]
                     if {$namesou == $dl} {
                        set pass "ok"
                        break
                     }
                  }
               }
               if {$pass == "ok"} { break }
               incr cpt
            }

gren_info "PASS? $pass \n"

            if {$pass == "ok"} {

gren_info " => source retrouvee $cpt $dl\n"

               # Modif TKLIST
               foreach {idcata cata} [array get cataname] {
                  set x [lsearch -index 0 $tklist($idcata) $cpt]
                  if {$x != -1} {
                     set tklist($idcata) [lreplace $tklist($idcata) $x $x]
                  }
               }
 
               # Modif current_listsources
               set fields [lindex $::tools_cata::current_listsources 0]
               set sources [lindex $::tools_cata::current_listsources 1]
               set sources [lreplace $sources $cpt $cpt]
               set ::tools_cata::current_listsources [list $fields $sources]

            }
               
         }

         # Modification du tk_list
         set ::gui_cata::tk_list($i,tklist) [array get tklist]
         # Modification du cata_list
         set ::gui_cata::cata_list($i) [list [lindex $current_listsources 0] $sources]

      }

      ::cata_gestion_gui::charge_image_directaccess
      return

   } 
 
 
 
 
 
 
 








# Anciennement ::gui_cata::set_astrom_ref


   proc ::cata_gestion_gui::set_astrom_ref { tbl } {

      set flag "R"
      set onglets $::cata_gestion_gui::fen.appli.onglets
      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]

      if {![::tools_cata::is_astrometric_catalog $cataselect]} {
         tk_messageBox -message "Le catalogue selectionné $cataselect n'est pas astrometrique" -type ok
         return
      }

      # On boucle sur les selections (indice de la table affichée de 0 a end)
      foreach select [$tbl curselection] {
         
         set id [lindex [$tbl get $select] 0]

         # On boucle sur les onglets
         foreach t [$onglets.nb tabs] {

            set idcata [string index [lindex [split $t .] 5] 1]
            set cata   $::gui_cata::cataname($idcata)
         
            # Modification du cata_list_source
            if {[string compare -nocase $cata "ASTROID"] == 0} {

               set fields [lindex $::tools_cata::current_listsources 0]
               set sources [lindex $::tools_cata::current_listsources 1]

               set a [lindex $sources [expr $id - 1]]
               set cpt 0
               foreach c $a {
                  if {[lindex $c 0]=="ASTROID"} {
                     set b [lindex $c 2]
                     set pos [expr [::gui_cata::get_pos_col flagastrom $idcata] - 10]
                     set b [lreplace $b $pos $pos $flag]
                     set pos [expr [::gui_cata::get_pos_col cataastrom $idcata] - 10]
                     set b [lreplace $b $pos $pos $cataselect]
                     set c [lreplace $c 2 2 $b]
                     set a [lreplace $a $cpt $cpt $c]
                     set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
                     set ::tools_cata::current_listsources [list $fields $sources]
                     break
                  }
                  incr cpt
               }
               
            }


            # modification de la tklist
            set x [lsearch -index 0 $::gui_cata::tklist($idcata) $id]
            if {$x != -1} {
               set a [lindex $::gui_cata::tklist($idcata) $x]
               set b [lreplace $a [::gui_cata::get_pos_col astrom_reference] [::gui_cata::get_pos_col astrom_reference] $flag]
               set b [lreplace $b [::gui_cata::get_pos_col astrom_catalog] [::gui_cata::get_pos_col astrom_catalog] $cataselect]
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  set b [lreplace $b [::gui_cata::get_pos_col flagastrom $idcata] [::gui_cata::get_pos_col flagastrom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col cataastrom $idcata] [::gui_cata::get_pos_col cataastrom $idcata] $cataselect]
               }
               set ::gui_cata::tklist($idcata) [lreplace $::gui_cata::tklist($idcata) $x $x $b]
            }

            # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
            if {"$tbl" == "$t.frmtable.tbl"} {
               #gren_info "on est ici $t\n"
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col astrom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col astrom_catalog]   -text $cataselect
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col flagastrom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col cataastrom $idcata] -text $cataselect
               }
               continue
            }

            # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
            # l indice de la table.
            set u 0
            foreach x [$t.frmtable.tbl get 0 end] {
               set idx [lindex $x 0]
               if {$idx == $id} {
                  #gren_info "$id -> $u sur $t\n"
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col astrom_reference] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col astrom_catalog]   -text $cataselect
                  # Rempli les champs correspondants dans le cata ASTROID
                  if {[string compare -nocase $cata "ASTROID"] == 0} {
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col flagastrom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col cataastrom $idcata] -text $cataselect
                  }
                  break
               }
               incr u
            }

         }

      }
      set a [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
      set x [lsearch -index 0 $a "ASTROID"]
      set a [lindex [lindex $a $x] 2]
      gren_info "AV REF $a\n"

      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::gui_cata::tklist]

      set a [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
      set x [lsearch -index 0 $a "ASTROID"]
      set a [lindex [lindex $a $x] 2]
      gren_info "SET REF $a\n"

      return
   }













# Anciennement ::gui_cata::set_astrom_mes


   proc ::cata_gestion_gui::set_astrom_mes { tbl } {

      set flag "S"
      set onglets $::cata_gestion_gui::fen.appli.onglets
      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]

      # On boucle sur les selections (indice de la table affichée de 0 a end)
      foreach select [$tbl curselection] {
         
         set id [lindex [$tbl get $select] 0]

         # On boucle sur les onglets
         foreach t [$onglets.nb tabs] {

            set idcata [string index [lindex [split $t .] 5] 1]
            set cata   $::gui_cata::cataname($idcata)

            # Modification du cata_list_source
            if {[string compare -nocase $cata "ASTROID"] == 0} {

               set fields [lindex $::tools_cata::current_listsources 0]
               set sources [lindex $::tools_cata::current_listsources 1]

               set a [lindex $sources [expr $id - 1]]
               set cpt 0
               foreach c $a {
                  if {[lindex $c 0]=="ASTROID"} {
                     set b [lindex $c 2]
                     set pos [expr [::gui_cata::get_pos_col flagastrom $idcata] - 10]
                     set b [lreplace $b $pos $pos $flag]
                     set pos [expr [::gui_cata::get_pos_col cataastrom $idcata] - 10]
                     set b [lreplace $b $pos $pos $cataselect]
                     set c [lreplace $c 2 2 $b]
                     set a [lreplace $a $cpt $cpt $c]
                     set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
                     set ::tools_cata::current_listsources [list $fields $sources]
                     break
                  }
                  incr cpt
               }
               
            }
            
            # modification de la tklist
            set x [lsearch -index 0 $::gui_cata::tklist($idcata) $id]
            if {$x != -1} {
               set a [lindex $::gui_cata::tklist($idcata) $x]
               set b [lreplace $a [::gui_cata::get_pos_col astrom_reference] [::gui_cata::get_pos_col astrom_reference] $flag]
               set b [lreplace $b [::gui_cata::get_pos_col astrom_catalog]   [::gui_cata::get_pos_col astrom_catalog] $cataselect]
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  set b [lreplace $b [::gui_cata::get_pos_col flagastrom $idcata] [::gui_cata::get_pos_col flagastrom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col cataastrom $idcata] [::gui_cata::get_pos_col cataastrom $idcata] $cataselect]
               }
               set ::gui_cata::tklist($idcata) [lreplace $::gui_cata::tklist($idcata) $x $x $b]
            }

            # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
            if {"$tbl" == "$t.frmtable.tbl"} {
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col astrom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col astrom_catalog]   -text $cataselect
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col flagastrom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col cataastrom $idcata] -text $cataselect
               }
               continue
            }
            
            # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
            # l indice de la table.
            set u 0
            foreach x [$t.frmtable.tbl get 0 end] {
               set idx [lindex $x 0]
               if {$idx == $id} {
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col astrom_reference] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col astrom_catalog]   -text $cataselect
                  # Rempli les champs correspondants dans le cata ASTROID
                  if {[string compare -nocase $cata "ASTROID"] == 0} {
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col flagastrom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col cataastrom $idcata] -text $cataselect
                  }
                  break
               }
               incr u
            }
            
            
         }
         
      }
      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::gui_cata::tklist]
      return
   }
 
 
 
 
 
 
 
 
# Anciennement ::gui_cata::unset_flag
 
   proc ::cata_gestion_gui::unset_flag { tbl } {

      set flag "-"
      gren_info "tbl=$tbl\n"
      set onglets $::cata_gestion_gui::fen.appli.onglets
      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]

      # On boucle sur les selections (indice de la table affichée de 0 a end)
      foreach select [$tbl curselection] {
         
         set id [lindex [$tbl get $select] 0]

         # On boucle sur les onglets
         foreach t [$onglets.nb tabs] {

            set idcata [string index [lindex [split $t .] 5] 1]
            set cata   $::gui_cata::cataname($idcata)


            # Modification du cata_list_source

            if {[string compare -nocase $cata "ASTROID"] == 0} {

               gren_info "modif  current_listsources\n"
               set fields [lindex $::tools_cata::current_listsources 0]
               set sources [lindex $::tools_cata::current_listsources 1]

               set a [lindex $sources [expr $id - 1]]
               set x [lsearch -index 0 $a "ASTROID"]
               set astroid [lindex $a $x]

               set b [lindex $astroid 2]
               set pos [expr [::gui_cata::get_pos_col flagphotom $idcata] - 10]
               gren_info "pos flagphotom= $pos\n"
               set b [lreplace $b $pos $pos $flag]
               set pos [expr [::gui_cata::get_pos_col cataphotom $idcata] - 10]
               gren_info "pos cataphotom= $pos\n"
               set b [lreplace $b $pos $pos $flag]
               set pos [expr [::gui_cata::get_pos_col flagastrom $idcata] - 10]
               gren_info "pos flagastrom= $pos\n"
               set b [lreplace $b $pos $pos $flag]
               set pos [expr [::gui_cata::get_pos_col cataastrom $idcata] - 10]
               gren_info "pos cataastrom= $pos\n"
               set b [lreplace $b $pos $pos $flag]

               set astroid [lreplace $astroid 2 2 $b]
               set a [lreplace $a $x $x $astroid]

               set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
               set ::tools_cata::current_listsources [list $fields $sources]
               
            }

            # modification de la tklist
            set x [lsearch -index 0 $::gui_cata::tklist($idcata) $id]
            if {$x != -1} {
               set a [lindex $::gui_cata::tklist($idcata) $x]
               set b [lreplace $a [::gui_cata::get_pos_col astrom_reference] [::gui_cata::get_pos_col astrom_reference] $flag]
               set b [lreplace $b [::gui_cata::get_pos_col astrom_catalog]   [::gui_cata::get_pos_col astrom_catalog]   $flag]
               set b [lreplace $b [::gui_cata::get_pos_col photom_reference] [::gui_cata::get_pos_col photom_reference] $flag]
               set b [lreplace $b [::gui_cata::get_pos_col photom_catalog]   [::gui_cata::get_pos_col photom_catalog]   $flag]
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  set b [lreplace $b [::gui_cata::get_pos_col flagphotom $idcata] [::gui_cata::get_pos_col flagastrom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col cataphotom $idcata] [::gui_cata::get_pos_col cataastrom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col flagphotom $idcata] [::gui_cata::get_pos_col flagphotom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col cataphotom $idcata] [::gui_cata::get_pos_col cataphotom $idcata] $flag]
               }
               set ::gui_cata::tklist($idcata) [lreplace $::gui_cata::tklist($idcata) $x $x $b]
            }

            # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
            if {"$tbl" == "$t.frmtable.tbl"} {
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col astrom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col astrom_catalog]   -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col photom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col photom_catalog]   -text $flag
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col flagastrom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col cataastrom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col flagphotom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col cataphotom $idcata] -text $flag
               }
               continue
            }
            
            # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
            # l indice de la table.
            set u 0
            foreach x [$t.frmtable.tbl get 0 end] {
               set idx [lindex $x 0]
               if {$idx == $id} {
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col astrom_reference] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col astrom_catalog]   -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col photom_reference] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col photom_catalog]   -text $flag
                  # Rempli les champs correspondants dans le cata ASTROID
                  if {[string compare -nocase $cata "ASTROID"] == 0} {
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col flagastrom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col cataastrom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col flagphotom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col cataphotom $idcata] -text $flag
                  }
                  break
               }
               incr u
            }               

         }
         
      }
      set a [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
      set x [lsearch -index 0 $a "ASTROID"]
      set a [lindex [lindex $a $x] 2]
      gren_info "AV UNSET $a\n"

      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      
      set a [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] [expr $id - 1]]
      set x [lsearch -index 0 $a "ASTROID"]
      set a [lindex [lindex $a $x] 2]
      gren_info "UNSET $a\n"
      
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::gui_cata::tklist]
      return
   }














# Anciennement ::gui_cata::set_photom_ref
 
   proc ::cata_gestion_gui::set_photom_ref { tbl } {

      set flag "R"
      set onglets $::cata_gestion_gui::fen.appli.onglets
      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]

      if {![::tools_cata::is_photometric_catalog $cataselect]} {
         tk_messageBox -message "Le catalogue selectionné $cataselect n'est pas photometrique" -type ok
         return
      }

      # On boucle sur les selections (indice de la table affichée de 0 a end)
      foreach select [$tbl curselection] {
         
         set id [lindex [$tbl get $select] 0]

         # On boucle sur les onglets
         foreach t [$onglets.nb tabs] {

            set idcata [string index [lindex [split $t .] 5] 1]
            set cata   $::gui_cata::cataname($idcata)

            # Modification du cata_list_source
            if {[string compare -nocase $cata "ASTROID"] == 0} {

               set fields [lindex $::tools_cata::current_listsources 0]
               set sources [lindex $::tools_cata::current_listsources 1]

               set a [lindex $sources [expr $id - 1]]
               set cpt 0
               foreach c $a {
                  if {[lindex $c 0]=="ASTROID"} {
                     set b [lindex $c 2]
                     set pos [expr [::gui_cata::get_pos_col flagphotom $idcata] - 10]
                     set b [lreplace $b $pos $pos $flag]
                     set pos [expr [::gui_cata::get_pos_col cataphotom $idcata] - 10]
                     set b [lreplace $b $pos $pos $cataselect]
                     set c [lreplace $c 2 2 $b]
                     set a [lreplace $a $cpt $cpt $c]
                     set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
                     set ::tools_cata::current_listsources [list $fields $sources]
                     break
                  }
                  incr cpt
               }
               
            }
            
            # modification de la tklist
            set x [lsearch -index 0 $::gui_cata::tklist($idcata) $id]
            if {$x != -1} {
               set a [lindex $::gui_cata::tklist($idcata) $x]
               set b [lreplace $a [::gui_cata::get_pos_col photom_reference] [::gui_cata::get_pos_col photom_reference] $flag]
               set b [lreplace $b [::gui_cata::get_pos_col photom_catalog] [::gui_cata::get_pos_col photom_catalog] $cataselect]
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  set b [lreplace $b [::gui_cata::get_pos_col flagphotom $idcata] [::gui_cata::get_pos_col flagphotom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col cataphotom $idcata] [::gui_cata::get_pos_col cataphotom $idcata] $cataselect]
               }
               set ::gui_cata::tklist($idcata) [lreplace $::gui_cata::tklist($idcata) $x $x $b]
            }

            # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
            if {"$tbl" == "$t.frmtable.tbl"} {
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col photom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col photom_catalog]   -text $cataselect
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col flagphotom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col cataphotom $idcata] -text $cataselect
               }
               continue
            }
            
            # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
            # l indice de la table.
            set u 0
            foreach x [$t.frmtable.tbl get 0 end] {
               set idx [lindex $x 0]
               if {$idx == $id} {
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col photom_reference] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col photom_catalog]   -text $cataselect
                  # Rempli les champs correspondants dans le cata ASTROID
                  if {[string compare -nocase $cata "ASTROID"] == 0} {
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col flagphotom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col cataphotom $idcata] -text $cataselect
                  }
                  break
               }
               incr u
            }
            
         }
         
      }
      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::gui_cata::tklist]
      return
   }
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
# Anciennement ::gui_cata::set_photom_mes
 
   proc ::cata_gestion_gui::set_photom_mes { tbl } {

      set flag "S"
      set onglets $::cata_gestion_gui::fen.appli.onglets
      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]

      set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

      #gren_info "Cata select = $cataselect\n"
      #gren_info "idCata select = $idcata\n"
      #gren_info "flag = $flag\n"

      # On boucle sur les selections (indice de la table affichée de 0 a end)
      foreach select [$tbl curselection] {
         
         set id [lindex [$tbl get $select] 0]

         #gren_info "select = $id ($select)\n"
         #gren_info "tbl = $tbl\n"
         
         # On boucle sur les onglets
         foreach t [$onglets.nb tabs] {

            set idcata [string index [lindex [split $t .] 5] 1]
            set cata   $::gui_cata::cataname($idcata)
            #gren_info "Cata   = $cata\n"
            #gren_info "idCata = $idcata\n"

            # Modification du cata_list_source
            if {[string compare -nocase $cata "ASTROID"] == 0} {

               set fields [lindex $::tools_cata::current_listsources 0]
               set sources [lindex $::tools_cata::current_listsources 1]

               set a [lindex $sources [expr $id - 1]]
               set cpt 0
               foreach c $a {
                  if {[lindex $c 0]=="ASTROID"} {
                     set b [lindex $c 2]
                     set pos [expr [::gui_cata::get_pos_col flagphotom $idcata] - 10]
                     set b [lreplace $b $pos $pos $flag]
                     set pos [expr [::gui_cata::get_pos_col cataphotom $idcata] - 10]
                     set b [lreplace $b $pos $pos $cataselect]
                     set c [lreplace $c 2 2 $b]
                     set a [lreplace $a $cpt $cpt $c]
                     set sources [lreplace $sources [expr $id - 1] [expr $id - 1] $a]
                     set ::tools_cata::current_listsources [list $fields $sources]
                     break
                  }
                  incr cpt
               }
               
            }


            # modification de la tklist
            set x [lsearch -index 0 $::gui_cata::tklist($idcata) $id]
            #gren_info "indice tklist($idcata)  =  $x\n"
            if {$x != -1} {
               set a [lindex $::gui_cata::tklist($idcata) $x]
               #gren_info "a =  $a\n"
               set b [lreplace $a [::gui_cata::get_pos_col photom_reference] [::gui_cata::get_pos_col photom_reference] $flag]
               set b [lreplace $b [::gui_cata::get_pos_col photom_catalog] [::gui_cata::get_pos_col photom_catalog] $cataselect]
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  set b [lreplace $b [::gui_cata::get_pos_col flagphotom $idcata] [::gui_cata::get_pos_col flagphotom $idcata] $flag]
                  set b [lreplace $b [::gui_cata::get_pos_col cataphotom $idcata] [::gui_cata::get_pos_col cataphotom $idcata] $cataselect]
               }
               set ::gui_cata::tklist($idcata) [lreplace $::gui_cata::tklist($idcata) $x $x $b]
            }

            # cas de l onglet courant (pas besoin de rechercher l indice de la table. il est fournit par $select
            if {"$tbl" == "$t.frmtable.tbl"} {
               #gren_info "on est ici $t\n"
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col photom_reference] -text $flag
               $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col photom_catalog]   -text $cataselect
               # Rempli les champs correspondants dans le cata ASTROID
               if {[string compare -nocase $cata "ASTROID"] == 0} {
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col flagphotom $idcata] -text $flag
                  $t.frmtable.tbl cellconfigure $select,[::gui_cata::get_pos_col cataphotom $idcata] -text $cataselect
               }
               continue
            }
            
            set u 0
            # On boucle sur les sources de l onglet courant. on est obligé de boucler sur les sources pour retrouver
            # l indice de la table.
            foreach x [$t.frmtable.tbl get 0 end] {
               set idx [lindex $x 0]
               if {$idx == $id} {
                  #gren_info "$id -> $u sur $t\n"
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col photom_reference] -text $flag
                  $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col photom_catalog]   -text $cataselect
                  # Rempli les champs correspondants dans le cata ASTROID
                  if {[string compare -nocase $cata "ASTROID"] == 0} {
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col flagphotom $idcata] -text $flag
                     $t.frmtable.tbl cellconfigure $u,[::gui_cata::get_pos_col cataphotom $idcata] -text $cataselect
                  }
                  break
               }
               incr u
            }

         }

      }
      #set a [lindex [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1] 0] 
      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist) [array get ::gui_cata::tklist]
      return
   }















# Anciennement ::cata_gestion_gui::psf_popup_auto_go
 
   proc ::cata_gestion_gui::psf_popup_auto_go { list_id } {

      #gren_info "id_current_image = $::tools_cata::id_current_image \n"
     
      set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

      set fields  [lindex $::tools_cata::current_listsources 0]
      set sources [lindex $::tools_cata::current_listsources 1]
      set nd_sources [llength $list_id]

      #gren_info "Sources selectionnees ($nd_sources): \n"
      set pass "no"

      set cpt 0      
      foreach id $list_id {
         incr cpt
         ::cata_gestion_gui::set_popupprogress $cpt $nd_sources
         #gren_info "ID = $id\n"
         set s [lindex $sources [expr $id - 1 ]]
         #gren_info "S=$s\n"
         set err [ catch {set r [::psf_tools::method_global s $::gui_cata::psf_threshold $::gui_cata::psf_limitradius]} msg ]
         if {$err} {
            ::console::affiche_erreur "*ERREUR PSF no_gui: $msg\n"
            ::console::affiche_erreur "*ERREUR PSF no_gui: $err\n"
         } else {
            set pos [lsearch -index 0 $s "ASTROID"]
            if {$pos != -1} { set name [lindex [lindex [lindex $s $pos] 2] 24] } else { set name "noname"}
            gren_info "NEW PSF ($id) $name\n"
            #gren_info "AVS [lindex $sources [expr $id - 1 ] ]\n"
            set sources [lreplace $sources [expr $id - 1 ] [expr $id - 1 ] $s]
            #gren_info "APS [lindex $sources [expr $id - 1 ] ]\n"
            set pass "yes"
         }

      }

      if {$pass=="no"} { return }

      set pos [lsearch -index 0 $fields "ASTROID"]
      if {$pos!=-1} {
         set fields [lreplace $fields $pos $pos [::analyse_source::get_fieldastroid]]
      } else {
         set fields [linsert $fields end [::analyse_source::get_fieldastroid]]
      }
      
      set ::tools_cata::current_listsources [list $fields $sources]
      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      ::tools_cata::current_listsources_to_tklist
      set ::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::gui_cata::tklist_list_of_columns]
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::gui_cata::tklist]
      set ::gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::gui_cata::cataname]
      ::cata_gestion_gui::charge_image_directaccess

   }
   
   
   
   
   










# Anciennement ::gui_cata::psf_popup_auto
 
   proc ::cata_gestion_gui::psf_popup_auto { tbl } {

      #gren_info "psf_popup_auto tbl = $tbl \n"

      set list_id ""
      foreach select [$tbl curselection] {
         set list_id [linsert $list_id end [lindex [$tbl get $select] 0] ]
      }
      set list_id [list $list_id]
      #gren_info "list_id = $list_id \n"



      set ::cata_gestion_gui::popupprogress 0
      set ::gui_cata::psf_limitradius 100
      set ::gui_cata::psf_threshold 2

      set ::gui_cata::fenpopuppsf .popuppsf
      if { [winfo exists $::gui_cata::fenpopuppsf] } {
         wm withdraw $::gui_cata::fenpopuppsf
         wm deiconify $::gui_cata::fenpopuppsf
         focus $::gui_cata::fenpopuppsf
         return
      }
      toplevel $::gui_cata::fenpopuppsf -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_cata::fenpopuppsf ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_cata::fenpopuppsf ] "+" ] 2 ]
      wm geometry $::gui_cata::fenpopuppsf +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_cata::fenpopuppsf 1 1
      wm title $::gui_cata::fenpopuppsf "PSF"
      wm protocol $::gui_cata::fenpopuppsf WM_DELETE_WINDOW "destroy $::gui_cata::fenpopuppsf"

      set frm $::gui_cata::fenpopuppsf.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_cata::fenpopuppsf -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

         set data  [frame $frm.threshold -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             label $data.l -text "Threshold : " 
             pack  $data.l -side left -padx 2 -pady 0
             
             entry $data.v -textvariable ::gui_cata::psf_threshold -relief sunken -width 5
             pack  $data.v -side left -padx 2 -pady 0

         set data  [frame $frm.limitradius -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             label $data.l -text "Limite du Rayon : " 
             pack  $data.l -side left -padx 2 -pady 0
             
             entry $data.v -textvariable ::gui_cata::psf_limitradius -relief sunken -width 5
             pack  $data.v -side left -padx 2 -pady 0

         set data  [frame $frm.progress -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set    pf [ ttk::progressbar $data.p -variable ::cata_gestion_gui::popupprogress -orient horizontal -length 200 -mode determinate]
             pack   $pf -in $data -side top

         set data  [frame $frm.boutons -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $data.ress -state active -text "Ressource" -relief "raised" \
                -command "::bddimages::ressource"
             pack   $data.ress -side left -anchor c -padx 0 -padx 10 -pady 5

             button $data.fermer -state active -text "Fermer" -relief "raised" \
                -command "destroy $::gui_cata::fenpopuppsf"
             pack   $data.fermer -side right -anchor c -padx 0 -padx 10 -pady 5

             button $data.go -state active -text "Go" -relief "raised" \
                -command "::cata_gestion_gui::psf_popup_auto_go $list_id ; destroy $::gui_cata::fenpopuppsf"
             pack   $data.go -side left -anchor c -padx 0 -padx 10 -pady 5


   }




      











# Anciennement ::cata_gestion_gui::psf_auto_go

   proc ::cata_gestion_gui::psf_auto_go { type list_id } {

      if {$type == "one"} {
         ::cata_gestion_gui::psf_auto_go_one
      }
      if {$type == "popup"} {
      }
      if {$type == "all"} {
         ::cata_gestion_gui::psf_auto_go_all
      }

   }

















# Anciennement ::cata_gestion_gui::psf_auto_go_one

   proc ::cata_gestion_gui::psf_auto_go_one { } {

      #gren_info "id_current_image = $::tools_cata::id_current_image \n"
     
      set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

      set fields  [lindex $::tools_cata::current_listsources 0]
      set sources [lindex $::tools_cata::current_listsources 1]
      set nd_sources [llength $sources]

      #gren_info "Sources selectionnees ($nd_sources): \n"
      set pass "no"

      set id 0     
      foreach s $sources {
         incr id
         ::cata_gestion_gui::set_popupprogress $id $nd_sources
         #gren_info "ID = $id\n"
         #gren_info "S=$s\n"
         set err [ catch {set r [::psf_tools::method_global s $::gui_cata::psf_threshold $::gui_cata::psf_limitradius]} msg ]
         if {$err} {
            ::console::affiche_erreur "*ERREUR PSF no_gui: $msg\n"
            ::console::affiche_erreur "*ERREUR PSF no_gui: $err\n"
         } else {
            set pos [lsearch -index 0 $s "ASTROID"]
            if {$pos != -1} { set name [lindex [lindex [lindex $s $pos] 2] 24] } else { set name "noname"}
            gren_info "NEW PSF ($id) $name\n"
            #gren_info "AVS [lindex $sources [expr $id - 1 ] ]\n"
            set sources [lreplace $sources [expr $id - 1 ] [expr $id - 1 ] $s]
            #gren_info "APS [lindex $sources [expr $id - 1 ] ]\n"
            set pass "yes"
         }
      }

      if {$pass=="no"} { return }

      set pos [lsearch -index 0 $fields "ASTROID"]
      if {$pos!=-1} {
         set fields [lreplace $fields $pos $pos [::analyse_source::get_fieldastroid]]
      } else {
         set fields [linsert $fields end [::analyse_source::get_fieldastroid]]
      }
      
      set ::tools_cata::current_listsources [list $fields $sources]
      set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
      ::tools_cata::current_listsources_to_tklist
      set ::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::gui_cata::tklist_list_of_columns]
      set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::gui_cata::tklist]
      set ::gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::gui_cata::cataname]
      ::cata_gestion_gui::charge_image_directaccess

   }
   















# Anciennement ::cata_gestion_gui::psf_auto_go_all

   proc ::cata_gestion_gui::psf_auto_go_all { } {

      #gren_info "id_current_image = $::tools_cata::id_current_image \n"
      set nd_sources 0
      for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {
         incr nd_sources [llength [lindex $::gui_cata::cata_list($i) 1]]
      }
      set cpt 0


     
      for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image<=$::tools_cata::nb_img_list} {incr ::tools_cata::id_current_image} {

         set ::cata_gestion_gui::directaccess $::tools_cata::id_current_image
         ::cata_gestion_gui::charge_image_directaccess

         set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

         set fields  [lindex $::tools_cata::current_listsources 0]
         set sources [lindex $::tools_cata::current_listsources 1]

         #gren_info "Sources selectionnees ($nd_sources): \n"
         set pass "no"

         set id 0     
         foreach s $sources {
            incr id
            incr cpt
            ::cata_gestion_gui::set_popupprogress $cpt $nd_sources
            #gren_info "ID = $id\n"
            #gren_info "S=$s\n"
            set err [ catch {set r [::psf_tools::method_global s $::gui_cata::psf_threshold $::gui_cata::psf_limitradius]} msg ]
            if {$err} {
               ::console::affiche_erreur "*ERREUR PSF no_gui: $msg\n"
               ::console::affiche_erreur "*ERREUR PSF no_gui: $err\n"
            } else {
               set pos [lsearch -index 0 $s "ASTROID"]
               if {$pos != -1} { set name [lindex [lindex [lindex $s $pos] 2] 24] } else { set name "noname"}
               gren_info "NEW PSF ($id) $name\n"
               #gren_info "AVS [lindex $sources [expr $id - 1 ] ]\n"
               set sources [lreplace $sources [expr $id - 1 ] [expr $id - 1 ] $s]
               #gren_info "APS [lindex $sources [expr $id - 1 ] ]\n"
               set pass "yes"
            }
         }

         if {$pass=="no"} { return }

         set pos [lsearch -index 0 $fields "ASTROID"]
         if {$pos!=-1} {
            set fields [lreplace $fields $pos $pos [::analyse_source::get_fieldastroid]]
         } else {
            set fields [linsert $fields end [::analyse_source::get_fieldastroid]]
         }

         set ::tools_cata::current_listsources [list $fields $sources]
         set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources
         ::tools_cata::current_listsources_to_tklist
         set ::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::gui_cata::tklist_list_of_columns]
         set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::gui_cata::tklist]
         set ::gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::gui_cata::cataname]

      }


      set ::cata_gestion_gui::directaccess 1
      ::cata_gestion_gui::charge_image_directaccess


   }
   
   
   












# Anciennement ::gui_cata::psf_auto

   proc ::cata_gestion_gui::psf_auto { type { tbl ""} } {

      set list_id [list "nothing"]
      if {$type == "one"} {
         set nd_sources [llength [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1]]
      }
      if {$type == "popup"} {
         set list_id ""
         foreach select [$tbl curselection] {
            set list_id [linsert $list_id end [lindex [$tbl get $select] 0] ]
         }
         set list_id [list $list_id]
         #gren_info "psf_popup_auto tbl = $tbl \n"
      }
      if {$type == "all"} {
         set nd_sources 0
         for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {
            incr nd_sources [llength [lindex $::gui_cata::cata_list($i) 1]]
         }
      }

      set ::cata_gestion_gui::popupprogress 0
      set ::gui_cata::psf_limitradius 100
      set ::gui_cata::psf_threshold 2

      set ::gui_cata::fenpopuppsf .popuppsf
      if { [winfo exists $::gui_cata::fenpopuppsf] } {
         wm withdraw $::gui_cata::fenpopuppsf
         wm deiconify $::gui_cata::fenpopuppsf
         focus $::gui_cata::fenpopuppsf
         return
      }
      toplevel $::gui_cata::fenpopuppsf -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_cata::fenpopuppsf ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_cata::fenpopuppsf ] "+" ] 2 ]
      wm geometry $::gui_cata::fenpopuppsf +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_cata::fenpopuppsf 1 1
      wm title $::gui_cata::fenpopuppsf "PSF"
      wm protocol $::gui_cata::fenpopuppsf WM_DELETE_WINDOW "destroy $::gui_cata::fenpopuppsf"

      set frm $::gui_cata::fenpopuppsf.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_cata::fenpopuppsf -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

         set data  [frame $frm.threshold -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             label $data.l -text "Threshold : " 
             pack  $data.l -side left -padx 2 -pady 0
             
             entry $data.v -textvariable ::gui_cata::psf_threshold -relief sunken -width 5
             pack  $data.v -side left -padx 2 -pady 0

         set data  [frame $frm.limitradius -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             label $data.l -text "Limite du Rayon : " 
             pack  $data.l -side left -padx 2 -pady 0
             
             entry $data.v -textvariable ::gui_cata::psf_limitradius -relief sunken -width 5
             pack  $data.v -side left -padx 2 -pady 0

         set info  [frame $frm.info -borderwidth 0 -cursor arrow -relief groove]
         pack $info -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             label $info.l -text "Nb sources = $nd_sources" 
             pack  $info.l -side left -padx 2 -pady 0

         set data  [frame $frm.progress -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set    pf [ ttk::progressbar $data.p -variable ::cata_gestion_gui::popupprogress -orient horizontal -length 200 -mode determinate]
             pack   $pf -in $data -side top

         set data  [frame $frm.boutons -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $data.fermer -state active -text "Fermer" -relief "raised" \
                -command "destroy $::gui_cata::fenpopuppsf"
             pack   $data.fermer -side right -anchor c -padx 0 -padx 10 -pady 5

             button $data.go -state active -text "Go" -relief "raised" \
                -command "::cata_gestion_gui::psf_auto_go $type $list_id  ; destroy $::gui_cata::fenpopuppsf"
             pack   $data.go -side left -anchor c -padx 0 -padx 10 -pady 5


   }






 
 
 
 
 
 
 
 
 
 
 
 
# Anciennement ::gui_cata::selectall
 
    proc ::cata_gestion_gui::selectall { tbl } {
      
      # Selectionne toutes les sources
      $tbl selection set 0 end

      # Affiche les sources selectionnees
      cleanmark
      set selected [$tbl get 0 end]
      foreach s $selected {
         set id [lindex $s 0]
         set ra [lindex $s [::gui_cata::get_pos_col ra]]
         set dec [lindex $s [::gui_cata::get_pos_col dec]]
         affich_un_rond $ra $dec red 2
      }
      return

   }


 
 
 
 
 
 
 
 
 

#--------------------------------------------------
#  ::cata_gestion_gui::cmdButton1Click { frame }
#--------------------------------------------------
#
#    fonction  : 
#    
#
#    variables en entree :
#        frame = reference de l'objet graphique de la selection
#
#    variables en sortie : void
#
#--------------------------------------------------

# Anciennement ::gui_cata::cmdButton1Click

   proc ::cata_gestion_gui::cmdButton1Click { w args } {

      set color red
      set width 2
      cleanmark
      foreach select [$w curselection] {
         set id [lindex [$w get $select] 0]
         set ra [lindex [$w get $select] [::gui_cata::get_pos_col ra]]
         set dec [lindex [$w get $select] [::gui_cata::get_pos_col dec]]
         #gren_info "line = [$w get $select]\n"
         #gren_info "pos ra dec = [::gui_cata::get_pos_col ra] [::gui_cata::get_pos_col dec]\n"
         #gren_info "ra dec = $ra $dec\n"
         affich_un_rond $ra $dec $color $width
      }
      return

   }


























# Anciennement ::gui_cata::gestion_cata
# Gui de gestion des fichiers catalogues
# interface de gestion, selection de sources de reference pour 
# l astrometrie et photometrie.
# effacement des sources
# mesure des photocentre
# mode manuel de visualisation des sources dans l image.
# traitement par lot d images.

   proc ::cata_gestion_gui::go { img_list } {

      global audace
      global bddconf

      set ::cata_gestion_gui::directaccess 1
      set ::cata_gestion_gui::progress 0
      set ::tools_cata::mem_use 0
      set ::tools_cata::mem_total 0

      set ::cata_gestion_gui::state_gestion 1
      
      ::cata_gestion_gui::inittoconf
      
      ::cata_gestion_gui::charge_gestion_cata $img_list 

      #--- Creation de la fenetre
      set ::cata_gestion_gui::fen .gestion_cata
      if { [winfo exists $::cata_gestion_gui::fen] } {
         wm withdraw $::cata_gestion_gui::fen
         wm deiconify $::cata_gestion_gui::fen
         focus $::cata_gestion_gui::fen
         return
      }
      toplevel $::cata_gestion_gui::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::cata_gestion_gui::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::cata_gestion_gui::fen ] "+" ] 2 ]
      wm geometry $::cata_gestion_gui::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::cata_gestion_gui::fen 1 1
      wm title $::cata_gestion_gui::fen "Gestion du CATA"
      wm protocol $::cata_gestion_gui::fen WM_DELETE_WINDOW "::cata_gestion_gui::fermer"

      set frm $::cata_gestion_gui::fen.appli

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::cata_gestion_gui::fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

         #--- Cree un frame general
         set menubar [frame $frm.menubar -cursor arrow -borderwidth 1 -relief raised]
         pack $menubar -in $frm -side top -fill x

           #--- menu Fichier
           menubutton $menubar.catalog -text "Catalogue" -underline 0 -menu $menubar.catalog.menu
           menu $menubar.catalog.menu

             $menubar.catalog.menu add command -label "Personnel" \
                -command ""
             $menubar.catalog.menu add command -label "Astroid" \
                -command ""
             $menubar.catalog.menu add command -label "Astrometrie" \
                -command ""
             $menubar.catalog.menu add command -label "Photometrie" \
                -command ""
             $menubar.catalog.menu add separator
             $menubar.catalog.menu add command -label "Supprimer" \
                -command ""

             #$This.frame0.file.menu add command -label "$caption(bddimages_recherche,delete_list)" -command " ::bddimages_recherche::cmd_list_delete $This.frame6.liste.tbl "
             pack $menubar.catalog -side left

           #--- menu Fichier
           menubutton $menubar.psf -text "PSF" -underline 0 -menu $menubar.psf.menu
           menu $menubar.psf.menu

             $menubar.psf.menu add command -label "Manuel sur l'image" \
                -command "::psf_gui::gestion_mode_manuel"
             $menubar.psf.menu add command -label "Auto sur l'image" \
                -command "::cata_gestion_gui::psf_auto one"
             $menubar.psf.menu add command -label "Auto toutes images" \
                -command "::cata_gestion_gui::psf_auto all"

             #$This.frame0.file.menu add command -label "$caption(bddimages_recherche,delete_list)" -command " ::bddimages_recherche::cmd_list_delete $This.frame6.liste.tbl "
             pack $menubar.psf -side left




         #--- Cree un frame general
         set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #----- 
             button $actions.charge -state active -text "Charge" -relief "raised" -command "::cata_gestion_gui::charge_memory"
             pack   $actions.charge -in $actions -side left -anchor w -padx 0

             set    pf [ ttk::progressbar $actions.p -variable ::cata_gestion_gui::progress -orient horizontal -length 200 -mode determinate]
             pack   $pf -in $actions -side left

             label $actions.lab1 -text "Img ("
             pack  $actions.lab1 -in $actions -side left -padx 5 -pady 0
             label $actions.lab2 -textvariable ::tools_cata::id_current_image
             pack  $actions.lab2 -in $actions -side left -padx 5 -pady 0
             label $actions.lab3 -text "/"
             pack  $actions.lab3 -in $actions -side left -padx 5 -pady 0
             label $actions.lab4 -textvariable ::tools_cata::nb_img_list
             pack  $actions.lab4 -in $actions -side left -padx 5 -pady 0
             label $actions.lab5 -text ")"
             pack  $actions.lab5 -in $actions -side left -padx 5 -pady 0

         set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $onglets -in $frm -side top -expand yes -fill both -padx 10 -pady 5
 
            pack [ttk::notebook $onglets.nb] -expand yes -fill both 
 
 

#      ::gui_cata::affiche_Tbl_sources $nbcata   
        


        #--- Cree un frame pour afficher les boutons
        set infoimg [frame $frm.infoimg -borderwidth 0 -cursor arrow -relief groove]
        pack $infoimg -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un checkbutton
             label $infoimg.lab1 -textvariable ::tools_cata::id_current_image
             pack  $infoimg.lab1 -in $infoimg -side left -padx 5 -pady 0
             #--- Cree un checkbutton
             label $infoimg.lab2 -textvariable ::tools_cata::current_image_name
             pack  $infoimg.lab2 -in $infoimg -side left -padx 5 -pady 0
             #--- Cree un checkbutton
             label $infoimg.lab3 -textvariable ::tools_cata::current_image_date
             pack  $infoimg.lab3 -in $infoimg -side left -padx 5 -pady 0


        #--- Cree un frame pour afficher les boutons
        set navigation [frame $frm.navigation -borderwidth 0 -cursor arrow -relief groove]
        pack $navigation -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $navigation.back -text "Precedent" -borderwidth 2 -takefocus 1 \
                   -command "::cata_gestion_gui::back" 
             pack $navigation.back -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $navigation.next -text "Suivant" -borderwidth 2 -takefocus 1 \
                   -command "::cata_gestion_gui::next" 
             pack $navigation.next -side left -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Cree un checkbutton
             label $navigation.lab -text "Access direct a l'image : "
             pack $navigation.lab -in $navigation -side left -padx 5 -pady 0
             entry $navigation.val -relief sunken \
                -textvariable ::cata_gestion_gui::directaccess -width 6 \
                -justify center
             pack $navigation.val -in $navigation -side left -pady 1 -anchor w
             button $navigation.go -text "Go" -borderwidth 1 -takefocus 1 \
                   -command "::cata_gestion_gui::charge_image_directaccess" 
             pack $navigation.go -side left -anchor e -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0


        #--- Cree un frame pour afficher bouton fermeture
        set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
        pack $boutonpied  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $boutonpied.annuler -text "Fermer" -borderwidth 2 -takefocus 1 \
                -command "::cata_gestion_gui::fermer"
             pack $boutonpied.annuler -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $boutonpied.enregistrer -text "Enregistrer" -borderwidth 2 -takefocus 1 \
                -command "::gui_cata::save_cata"
             pack $boutonpied.enregistrer -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             button $boutonpied.aide -text "Aide" -borderwidth 2 -takefocus 1 \
                -command ""
             pack $boutonpied.aide -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             set ::gui_cata::gui_info [label $boutonpied.info -text ""]
             pack $boutonpied.info -in $boutonpied -side top -padx 3 -pady 3
             set ::gui_cata::gui_info2 [label $boutonpied.info2 -text ""]
             pack $::gui_cata::gui_info2 -in $boutonpied -side top -padx 3 -pady 3


      ::cata_gestion_gui::charge_memory
   }
   
   
   
   
   











#- Fin du namespace -------------------------------------------------
}
