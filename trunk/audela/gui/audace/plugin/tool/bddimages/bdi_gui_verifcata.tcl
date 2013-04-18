namespace eval gui_verifcata {

   variable fen
   variable frmtable

   proc ::gui_verifcata::inittoconf { } {

   }
   
   proc ::gui_verifcata::fermer { } {
      
      destroy $::gui_verifcata::fen
   }
   
   





   proc ::gui_verifcata::cmdButton1Click { w args } {

   }







   proc ::gui_verifcata::create_Tbl_sources { frmtable name_of_columns} {

      variable This
      global audace
      global caption
      global bddconf

      #--- Quelques raccourcis utiles
      set tbl $frmtable.tbl
      set popupTbl $frmtable.popupTbl

      #--- Table des objets
      tablelist::tablelist $tbl \
         -columns $name_of_columns \
         -labelcommand tablelist::sortByColumn \
         -selectmode extended \
         -activestyle none \
         -stripebackground #e0e8f0 \
         -showseparators 1


      #--- Gestion des popup

      #--- Menu pop-up associe a la table
      menu $popupTbl -title "Selection"

        $popupTbl add command -label "Voir une source" -command "::gui_verifcata::popup_voir $tbl"
        $popupTbl add command -label "Psf"             -command "::gui_verifcata::popup_psf $tbl"
        $popupTbl add command -label "Unset"           -command "::gui_verifcata::popup_unset $tbl"


      #--- Gestion des evenements
      bind [$tbl bodypath] <Control-Key-a> [ list ::gui_verifcata::selectall $tbl ]
      bind $tbl <<ListboxSelect>> [ list ::gui_verifcata::cmdButton1Click %W ]
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]

      pack  $tbl -in  $frmtable -expand yes -fill both
      
   }















   proc ::gui_verifcata::affich_results_tklist { send_source_list send_date_list } {

      upvar $send_source_list source_list
      upvar $send_date_list   date_list


      set onglets $::gui_verifcata::fen.appli.onglets
      set tbl1 $onglets.nb.f1.frmtable.tbl
      set tbl2 $onglets.nb.f2.frmtable.tbl
      catch { 
         $tbl1 delete 0 end
         $tbl2 delete 0 end
      }

      foreach line $source_list {
         $tbl1 insert end $line
      }
      foreach line $date_list {
         $tbl2 insert end $line
      }
      


      return
         
   }



   proc ::gui_verifcata::visu_image {  } {

      set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]
      set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)
      ::gui_cata::affiche_current_image
   }







   proc ::gui_verifcata::popup_voir { tbl } {

      foreach select [$tbl curselection] {
      
         set ids [lindex [$tbl get $select] 0]      
         set idd [lindex [$tbl get $select] 1]   
         gren_info "ids = $ids ; idd = $idd \n"   
         break
      }
      
      if {$::tools_cata::id_current_image == $idd} {
         # L image est deja affichée
         
      } else {
         # L image affichée n est pas la bonne
         set ::tools_cata::id_current_image $idd
         ::gui_verifcata::visu_image
      }
      set s [lindex [lindex $::tools_cata::current_listsources 1] [expr $ids - 1] ]
      set r [::bdi_gui_gestion_source::grab_sources_getsource $ids $s ]
   

      #gren_info "r=$r\n"

      set err   [lindex $r 0]
      set aff   [lindex $r 1]
      set id    [lindex $r 2]
      set xpass [lindex $r 3]
      set ypass [lindex $r 4]
      
      ::confVisu::setPos $::audace(visuNo) [list $xpass $ypass]
      affich_un_rond_xy $xpass $ypass green  10 1

   }








   proc ::gui_verifcata::popup_psf { tbl } {


      set worklist ""
      foreach select [$tbl curselection] {
         set ids [lindex [$tbl get $select] 0]      
         set idd [lindex [$tbl get $select] 1]   
         gren_info "ids = $ids ; idd = $idd \n"   
         lappend worklist [list $idd $ids]
      }
      set worklist [lsort -dictionary $worklist]
      gren_info "worklist = $worklist\n"
      ::bdi_gui_gestion_source::run $worklist
      gren_info "popup_psf fin\n"
      return

      # premiere image de la liste 
      set a [lindex $worklist 0]
      set idd [lindex $a 0]
      set ids [lindex $a 1]      
      
      if {$::tools_cata::id_current_image == $idd} {
         # L image est deja affichée
         
      } else {
         # L image affichée n est pas la bonne
         set ::tools_cata::id_current_image $idd
         ::gui_verifcata::visu_image
      }
      set s [lindex [lindex $::tools_cata::current_listsources 1] [expr $ids - 1] ]
      set r [::bdi_gui_gestion_source::grab_sources_getsource $ids $s ]
   

      #gren_info "r=$r\n"

      set err   [lindex $r 0]
      set aff   [lindex $r 1]
      set id    [lindex $r 2]
      set xpass [lindex $r 3]
      set ypass [lindex $r 4]
      ::confVisu::setPos $::audace(visuNo) [list $xpass $ypass]
      
      
      
      ::bdi_gui_gestion_source::run $ids
      
   }






   proc ::gui_verifcata::popup_unset { tbl } {

      global bddconf
      
      set worklist ""
      foreach select [$tbl curselection] {
         set ids [lindex [$tbl get $select] 0]      
         set idd [lindex [$tbl get $select] 1]   
         
         set current_listsources $::gui_cata::cata_list($idd)
         set sources [lindex $current_listsources 1]
         set s [lindex $sources [expr $ids - 1] ]
         set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
         ::bdi_tools_psf::set_by_key othf "flagastrom" ""
         ::bdi_tools_psf::set_by_key othf "cataastrom" ""
         ::bdi_tools_psf::set_astroid_in_source s othf
         set sources [lreplace $sources [expr $ids - 1] [expr $ids - 1] $s]
         set current_listsources [list [lindex $current_listsources 0] $sources]


         # @TODO
         set current_image [lindex $::tools_cata::img_list [expr $idd-1]]
         set tabkey         [::bddimages_liste::lget $current_image "tabkey"]
         set imgfilename    [::bddimages_liste::lget $current_image filename]
         set imgdirfilename [::bddimages_liste::lget $current_image dirfilename]
         set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
         set cataxml "${f}_cata.xml"
         
         ::tools_cata::save_cata $current_listsources $tabkey $cataxml


      }
      return

   }







   proc ::gui_verifcata::verif {  } {

      ::tools_verifcata::verif source_list date_list
      ::gui_verifcata::affich_results_tklist source_list date_list 

   }













   proc ::gui_verifcata::run_from_recherche { img_list } {
   
     global bddconf

     catch {
         if { [ info exists ::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
         if { [ info exists ::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
         if { [ info exists ::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
         if { [ info exists ::gui_cata::cata_list ] }            {unset ::gui_cata::cata_list}
      } 

      set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
      set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]
      
      set ::tools_cata::id_current_image -1
      ::gui_verifcata::run
   }













   proc ::gui_verifcata::run {  } {

      global audace
      global bddconf

      ::gui_verifcata::inittoconf
      
      set col_sources { 0 IdS  0 IdD 0 Date-Obs 0 Erreur     0 Name 0 Catas }
      set col_dates   { 0 IdS  0 IdD 0 Date-Obs 0 Star&Aster 0 CataDouble 0 CataAstrom }
     
      
      #--- Creation de la fenetre
      set ::gui_verifcata::fen .verifcata
      if { [winfo exists $::gui_verifcata::fen] } {
         wm withdraw $::gui_verifcata::fen
         wm deiconify $::gui_verifcata::fen
         focus $::gui_verifcata::fen
         return
      }
      toplevel $::gui_verifcata::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_verifcata::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_verifcata::fen ] "+" ] 2 ]
      wm geometry $::gui_verifcata::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_verifcata::fen 1 1
      wm title $::gui_verifcata::fen "Verification du CATA"
      wm protocol $::gui_verifcata::fen WM_DELETE_WINDOW "::gui_verifcata::fermer"

      set frm $::gui_verifcata::fen.appli

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_verifcata::fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

         #--- Cree un frame general
         set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $actions.back -text "Verifier" -borderwidth 2 -takefocus 1 \
                   -command "::gui_verifcata::verif" 
             pack $actions.back -side top -anchor c -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


         set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $onglets -in $frm -side top -expand yes -fill both -padx 10 -pady 5
 
              pack [ttk::notebook $onglets.nb] -expand yes -fill both 
              set f1 [frame $onglets.nb.f1]
              set f2 [frame $onglets.nb.f2]

              $onglets.nb add $f1 -text "Sources"
              $onglets.nb add $f2 -text "Dates"

             $onglets.nb select $f1
             ttk::notebook::enableTraversal $onglets.nb

             set frmtable [frame $f1.frmtable -borderwidth 0 -cursor arrow -relief groove -background white]
             pack $frmtable -in $f1 -expand yes -fill both -padx 3 -pady 6 -side right -anchor e
             ::gui_verifcata::create_Tbl_sources $frmtable $col_sources

             set frmtable [frame $f2.frmtable -borderwidth 0 -cursor arrow -relief groove -background white]
             pack $frmtable -in $f2 -expand yes -fill both -padx 3 -pady 6 -side right -anchor e
             ::gui_verifcata::create_Tbl_sources $frmtable $col_dates



         set actions [frame $frm.pied -borderwidth 0 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $actions.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                   -command "::gui_verifcata::fermer" 
             pack $actions.fermer -side top -anchor c -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0



   }


}
