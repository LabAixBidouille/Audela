namespace eval gui_verifcata {

   variable fen

   proc ::gui_verifcata::inittoconf { } {

   }
   
   proc ::gui_verifcata::fermer { } {
      
      destroy $::gui_verifcata::fen
   }
   
   




   proc ::gui_verifcata::affich_results_tklist { } {


      return
      
      set onglets $::gui_verifcata::fen.appli.onglets
   
      # TODO ::gui_verifcata::affich_current_tklist : afficher l image ici
   
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

         set ::gui_verifcata::frmtable($idcata) [frame $fc($idcata).frmtable -borderwidth 0 -cursor arrow -relief groove -background white]
         pack $::gui_verifcata::frmtable($idcata) -expand yes -fill both -padx 3 -pady 6 -in $fc($idcata) -side right -anchor e

         #--- Cree un acsenseur vertical
         scrollbar $::gui_verifcata::frmtable($idcata).vsb -orient vertical \
            -command { $::gui_verifcata::frmtable($idcata).lst1 yview } -takefocus 1 -borderwidth 1
         pack $::gui_verifcata::frmtable($idcata).vsb -in $::gui_verifcata::frmtable($idcata) -side right -fill y

         #--- Cree un acsenseur horizontal
         scrollbar $::gui_verifcata::frmtable($idcata).hsb -orient horizontal \
            -command { $::gui_verifcata::frmtable($idcata).lst1 xview } -takefocus 1 -borderwidth 1
         pack $::gui_verifcata::frmtable($idcata).hsb -in $::gui_verifcata::frmtable($idcata) -side bottom -fill x

         #--- Creation de la table
         ::gui_verifcata::create_Tbl_sources $idcata
         pack  $::gui_verifcata::frmtable($idcata).tbl -in  $::gui_verifcata::frmtable($idcata) -expand yes -fill both


         catch { $::gui_verifcata::frmtable($idcata).tbl delete 0 end
                 $::gui_verifcata::frmtable($idcata).tbl deletecolumns 0 end  
         }
        
         set nbcol [llength $::gui_cata::tklist_list_of_columns($idcata)]
         for { set j 0 } { $j < $nbcol} { incr j } {
            set current_columns [lindex $::gui_cata::tklist_list_of_columns($idcata) $j]
            $::gui_verifcata::frmtable($idcata).tbl insertcolumns end 0 [lindex $current_columns 1] left
            $::gui_verifcata::frmtable($idcata).tbl columnconfigure $j -sortmode dictionary
         }

         #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
         if { [ $::gui_verifcata::frmtable($idcata).tbl columncount ] != "0" } {
            $::gui_verifcata::frmtable($idcata).tbl columnconfigure 0 -sortmode dictionary
         }
         foreach col {5 6 7 8 9} {
             $::gui_verifcata::frmtable($idcata).tbl columnconfigure $col -background ivory -sortmode dictionary
         }

         foreach line $::gui_cata::tklist($idcata) {
            $::gui_verifcata::frmtable($idcata).tbl insert end $line
         }
         
         #gren_info "$::gui_cata::cataname($idcata) : [llength $::gui_cata::tklist($idcata)]\n"
         #gren_info "onglets : [$::gui_verifcata::fen.appli.onglets.nb tabs]\n"
         
         $::gui_verifcata::fen.appli.onglets.nb tab [expr $idcata - 1] -text "([llength $::gui_cata::tklist($idcata)])$::gui_cata::cataname($idcata)"
         
      }
   }








   proc ::gui_verifcata::verif {  } {

      ::tools_verifcata::verif
      ::gui_verifcata::affich_results_tklist

   }






   proc ::gui_verifcata::run {  } {

      global audace
      global bddconf

      ::gui_verifcata::inittoconf
      
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

   }


}
