## \file bdi_gui_cata_delete.tcl
#  \brief     Effacement d'un ou plusieurs catalogues dans une ou plusieurs images
#  \details   Ce namepsace concerne seulement l'affichage permettant de 
#             choisir les catalogues a supprimer
#             
#  \author    Frederic Vachier
#  \version   1.0
#  \date      2013
#  \copyright GNU Public License.
#  \par Ressource 
#  \code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_cata_delete.tcl]
#  \endcode
#  \todo      finir et verifier les entetes doxyfile

namespace eval gui_cata_delete {

   variable fen
   variable frmtable

   proc ::gui_cata_delete::inittoconf { } {

   }
   
   proc ::gui_cata_delete::fermer { } {
      
      if { [winfo exists $::cata_gestion_gui::fen] } {
         gren_info "Fenetre gestion des catalogues existe\n"
         ::cata_gestion_gui::charge_image_directaccess
      }
      destroy $::gui_cata_delete::fen
   }
   
   





   proc ::gui_cata_delete::cmdButton1Click { w args } {

   }







   proc ::gui_cata_delete::create_Tbl_sources { frmtable name_of_columns} {

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

        $popupTbl add command -label "Supprimer" -command "::gui_cata_delete::popup_delete $tbl"

      #--- Gestion des evenements
      bind [$tbl bodypath] <Control-Key-a> [ list ::gui_cata_delete::selectall $tbl ]
      bind $tbl <<ListboxSelect>> [ list ::gui_cata_delete::cmdButton1Click %W ]
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]

      pack  $tbl -in  $frmtable -expand yes -fill both
      
   }























   proc ::gui_cata_delete::popup_delete { tbl } {


      for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {

         gren_info "Image $i / $::tools_cata::nb_img_list : "
         foreach select [$tbl curselection] {
            set cata [lindex [$tbl get $select] 0]      
            gren_info "$cata "
            set ::tools_cata::current_listsources [::manage_source::delete_catalog $::gui_cata::cata_list($i) $cata]
            set ::gui_cata::cata_list($i) $::tools_cata::current_listsources

            # chargement de la tklist sous forme de liste tcl. (pour affichage)
            ::tools_cata::current_listsources_to_tklist

            set ::gui_cata::tk_list($i,list_of_columns) [array get ::gui_cata::tklist_list_of_columns]
            set ::gui_cata::tk_list($i,tklist)          [array get ::gui_cata::tklist]
            set ::gui_cata::tk_list($i,cataname)        [array get ::gui_cata::cataname]



         }
         gren_info "rollup = [::manage_source::get_nb_sources_rollup $::gui_cata::cata_list($i)]\n"

      }
      ::gui_cata_delete::reload
   }




















   proc ::gui_cata_delete::reload {  } {

      array unset tab
      for {set i 1} {$i<=$::tools_cata::nb_img_list} {incr i} {
         set current_listsources $::gui_cata::cata_list($i)
         set fields [lindex $current_listsources 0]
         foreach x $fields {
            set x [lindex $x 0]
            set tab($x) 0
         }
      }

      $::gui_cata_delete::fen.appli.frmtable.tbl delete 0 end
      foreach {x y} [array get tab] {
         $::gui_cata_delete::fen.appli.frmtable.tbl insert end $x
      }

   }













   proc ::gui_cata_delete::run_from_recherche { img_list } {
   
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
      ::gui_cata_delete::run
   }













   proc ::gui_cata_delete::run {  } {

      global audace
      global bddconf

      ::gui_cata_delete::inittoconf
      
      set col_catas { 0 cata }
     
      
      #--- Creation de la fenetre
      set ::gui_cata_delete::fen .deletecata
      if { [winfo exists $::gui_cata_delete::fen] } {
         wm withdraw $::gui_cata_delete::fen
         wm deiconify $::gui_cata_delete::fen
         focus $::gui_cata_delete::fen
         return
      }
      toplevel $::gui_cata_delete::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::gui_cata_delete::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::gui_cata_delete::fen ] "+" ] 2 ]
      wm geometry $::gui_cata_delete::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::gui_cata_delete::fen 1 1
      wm title $::gui_cata_delete::fen "Effacement de Catalogues"
      wm protocol $::gui_cata_delete::fen WM_DELETE_WINDOW "::gui_cata_delete::fermer"

      set frm $::gui_cata_delete::fen.appli

      #--- Cree un frame general
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::gui_cata_delete::fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

         set frmtable [frame $frm.frmtable -borderwidth 0 -cursor arrow -relief groove -background white]
         pack $frmtable -in $frm -expand yes -fill both -padx 3 -pady 6 -side right -anchor e
         ::gui_cata_delete::create_Tbl_sources $frmtable $col_catas

         set actions [frame $frm.pied -borderwidth 0 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $actions.reload -text "Recharger" -borderwidth 2 -takefocus 1 \
                   -command "::gui_cata_delete::reload" 
             pack $actions.reload -side top -anchor c -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
             button $actions.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                   -command "::gui_cata_delete::fermer" 
             pack $actions.fermer -side top -anchor c -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      ::gui_cata_delete::reload

   }


}
