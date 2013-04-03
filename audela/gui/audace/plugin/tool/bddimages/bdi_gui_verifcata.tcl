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

        # Edite la liste selectionnee
        $popupTbl add command -label "Voir" -command ""

        # Edite la liste selectionnee
        $popupTbl add command -label "psf" -command "::gui_verifcata::popup_psf $tbl"


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


   proc ::gui_verifcata::popup_psf { tbl } {

      foreach select [$tbl curselection] {
      
         set ids [lindex [$tbl get $select] 0]      
         set idd [lindex [$tbl get $select] 1]   
         gren_info "ids = $ids ; idd = $idd \n"   
         break
      }
   }


   proc ::gui_verifcata::verif {  } {

      ::tools_verifcata::verif source_list date_list 
      ::gui_verifcata::affich_results_tklist source_list date_list 

   }



   proc ::gui_verifcata::run_from_recherche { img_list } {
   
     global bddconf
   
     catch {
         if { [ info exists $::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
         if { [ info exists $::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
         if { [ info exists $::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
      }

      set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
      set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
      set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]
      
      foreach ::tools_cata::current_image $::tools_cata::img_list {

         set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
         set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]

         set ::tools_cata::current_image_date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
         set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
         set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
         set ::tools_cata::current_image_name [::bddimages_liste::lget $::tools_cata::current_image "filename"]
         set file        [file join $bddconf(dirbase) $dirfilename $::tools_cata::current_image_name]

         ::gui_cata::load_cata

         set ::gui_cata::cata_list($::tools_cata::id_current_image) $::tools_cata::current_listsources

      }
      ::gui_verifcata::run
   }


   proc ::gui_verifcata::run {  } {

      global audace
      global bddconf

      ::gui_verifcata::inittoconf
      
      set col_sources { 0 IdS  0 IdD 0 Date-Obs 0 Erreur     0 Name 0 Catas }
      set col_dates   { 0 IdS  0 IdD 0 Date-Obs 0 Star&Aster   }
     
      
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
