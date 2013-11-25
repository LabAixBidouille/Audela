## \file bdi_gui_cdl.tcl
#  \brief     Creation des courbes de lumiere 
#  \details   Ce namepsace se restreint a tout ce qui est gestion des sources
#             pour la selection des refereence en vue de faire la courbe de 
#             Lumiere.
#  \author    Frederic Vachier
#  \version   1.0
#  \date      2013
#  \copyright GNU Public License.
#  \par Ressource 
#  \code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_cdl.tcl]
#  \endcode
#  \todo      normaliser les noms des fichiers sources 

#--------------------------------------------------
#
# source [ file join $audace(rep_plugin) tool bddimages bdi_gui_cdl.tcl ]
#
#--------------------------------------------------
#
# Mise à jour $Id: bdi_tools_cdl.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------

## Declaration du namespace \c bdi_gui_cdl.
#  @pre       Chargement a partir d'Audace
#  @bug       Probleme de memoire sur les exec
#  @warning   Appel GUI
namespace eval bdi_gui_cdl {

   
   variable fen      ; # Variable definissant la racine de la fenetre de l'outil
   variable data_reference ; # table des donnees des etoiles de reference
   
}


   #----------------------------------------------------------------------------
   ## Initialisation des variables de namespace
   #  \details   Si la variable n'existe pas alors on va chercher
   #             dans la variable globale \c conf
   proc ::bdi_gui_cdl::inittoconf {  } {
      
      ::bdi_tools_cdl::free_memory
   }

   #----------------------------------------------------------------------------
   ## Fermeture de la fenetre .
   # Les variables utilisees sont affectees a la variable globale
   # \c conf
   proc ::bdi_gui_cdl::fermer {  } {


      #array unset ::gui_cata::cata_list
      destroy $::bdi_gui_cdl::fen
      
      unset ::bdi_gui_cdl::fen
      
   }

   #----------------------------------------------------------------------------
   ## Relance l outil
   # Les variables utilisees sont affectees a la variable globale
   # \c conf
   proc ::bdi_gui_cdl::relance {  } {

      ::bddimages::ressource
      ::bdi_gui_cdl::fermer
      ::bdi_gui_cdl::run
      foreach img $::tools_cata::img_list {
         gren_info "IMG = [llength $img]\n"
         break
      }
      ::bdi_tools_cdl::get_memory

   }







   # On click
   proc ::bdi_gui_cdl::cmdButton1Click_data_reference { w args } {

   }

   proc ::bdi_gui_cdl::cmdButton1Click_data_science { w args } {

   }

   proc ::bdi_gui_cdl::cmdButton1Click_data_rejected { w args } {

   }

   proc ::bdi_gui_cdl::cmdButton1Click_starstar { w args } {

   }

   proc ::bdi_gui_cdl::cmdButton1Click_classif { w args } {

   }

   proc ::bdi_gui_cdl::cmdButton1Click_timeline { w args } {

   }


   #----------------------------------------------------------------------------
   ## Demarrage de l'outil
   #  \param img_list structure de liste d'images
   proc ::bdi_gui_cdl::run { } {

      ::bdi_gui_cdl::inittoconf
   
      set ::bdi_tools_cdl::memory(memview) 0
      ::bdi_tools_cdl::get_memory

      ::bdi_gui_cdl::create_dialog
   }

   proc ::bdi_gui_cdl::clean_gui_photometry { } {

      $::bdi_gui_cdl::data_reference delete 0 end
      $::bdi_gui_cdl::data_science   delete 0 end
      $::bdi_gui_cdl::data_rejected  delete 0 end
      $::bdi_gui_cdl::classif        delete 0 end
      $::bdi_gui_cdl::ss_mag_stdev   delete 0 end 
      $::bdi_gui_cdl::timeline       delete 0 end

      catch { $::bdi_gui_cdl::timeline     deletecolumns 0 end } 
      catch { $::bdi_gui_cdl::ss_mag_stdev deletecolumns 0 end } 

   }

   proc ::bdi_gui_cdl::charge_from_gestion { } {

      ::bdi_tools_cdl::free_memory
      ::bdi_gui_cdl::clean_gui_photometry
      ::bdi_gui_cdl::affich_gestion
      ::bdi_tools_cdl::charge_from_gestion
   }

   #----------------------------------------------------------------------------
   ## Affichage de l outil de gestion des cata
   proc ::bdi_gui_cdl::affich_gestion { } {

      set tt0 [clock clicks -milliseconds]
      #catch {destroy $::cata_gestion_gui::fen}
      if {[winfo exists $::cata_gestion_gui::fen]==0} {
         ::cata_gestion_gui::go $::tools_cata::img_list
      }
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Chargement de la fenetre Gestion en $tt sec \n"
      
   }


   #----------------------------------------------------------------------------
   ## Creation de la boite de dialogue.
   proc ::bdi_gui_cdl::create_dialog { } {

      global audace

      


      set ::bdi_gui_cdl::fen .photometry
      if { [winfo exists $::bdi_gui_cdl::fen] } {
         wm withdraw $::bdi_gui_cdl::fen
         wm deiconify $::bdi_gui_cdl::fen
         focus $::bdi_gui_cdl::fen
         return
      }
      toplevel $::bdi_gui_cdl::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::bdi_gui_cdl::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::bdi_gui_cdl::fen ] "+" ] 2 ]
      wm geometry $::bdi_gui_cdl::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::bdi_gui_cdl::fen 1 1
      wm title $::bdi_gui_cdl::fen "Photometrie V3"
      wm protocol $::bdi_gui_cdl::fen WM_DELETE_WINDOW "::bdi_gui_cdl::fermer"

      set frm $::bdi_gui_cdl::fen.appli
      #--- Cree un frame general
      frame $frm  -cursor arrow -relief groove
      pack $frm -in $::bdi_gui_cdl::fen -anchor s -side top -expand yes -fill both -padx 10 -pady 5

         set onglets [frame $frm.onglets]
         pack $onglets -in $frm  -expand yes -fill both

            pack [ttk::notebook $onglets.nb] -expand yes -fill both 
            set f_data_reference [frame $onglets.nb.f_data_reference]
            set f_data_science   [frame $onglets.nb.f_data_science]
            set f_data_rejected  [frame $onglets.nb.f_data_rejected]
            set f_starstar       [frame $onglets.nb.f_starstar]
            set f_classif        [frame $onglets.nb.f_classif]
            set f_timeline       [frame $onglets.nb.f_timeline]

            $onglets.nb add $f_data_reference -text "References"
            $onglets.nb add $f_data_science   -text "Sciences"
            $onglets.nb add $f_data_rejected  -text "Rejetees"
            $onglets.nb add $f_starstar       -text "Variations"
            $onglets.nb add $f_classif        -text "Classification"
            $onglets.nb add $f_timeline       -text "Timeline"

            #$onglets.nb select $f_data_reference
            ttk::notebook::enableTraversal $onglets.nb

         # References
         set results [frame $f_data_reference.data_reference  -borderwidth 1 -relief groove]
         pack $results -in $f_data_reference -expand yes -fill both
            
            set cols [list 0 "Id"       left  \
                           0 "Name"    left  \
                           0 "Nb img"  right \
                           0 "Nb mes"  right \
                           0 "Moy Mag" right \
                           0 "StDev Mag" right \
                     ]
            # Table
            set ::bdi_gui_cdl::data_reference $results.table
            tablelist::tablelist $::bdi_gui_cdl::data_reference \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $results.hsb set ] \
              -yscrollcommand [ list $results.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1
    
            # Scrollbar
            scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::data_reference xview]
            pack $results.hsb -in $results -side bottom -fill x
            scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::data_reference yview]
            pack $results.vsb -in $results -side right -fill y 

            # Pack la Table
            pack $::bdi_gui_cdl::data_reference -in $results -expand yes -fill both

            # Popup
            menu $results.popupTbl -title "Actions"

               $results.popupTbl add command -label "Voir l'objet dans une image" \
                   -command "::gui_cata::voirobj_photom_ref" 
               $results.popupTbl add command -label "Definir Science" \
                   -command "::bdi_gui_cdl::set_to_science_data_reference" 
               $results.popupTbl add command -label "Rejeter" \
                   -command "::bdi_gui_cdl::unset_data_reference" 

            # Binding
            bind $::bdi_gui_cdl::data_reference <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_data_reference %W ]
            bind [$::bdi_gui_cdl::data_reference bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
            #    Ascii
            foreach ncol [list "Name"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::data_reference columnconfigure $pcol -sortmode ascii
            }
            #    Reel
            foreach ncol [list "Id" "Nb img" "Nb mes" "Moy Mag" "StDev Mag"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::data_reference columnconfigure $pcol -sortmode real
            }








         # Sciences
         set results [frame $f_data_science.data_science  -borderwidth 1 -relief groove]
         pack $results -in $f_data_science -expand yes -fill both
            
            set cols [list 0 "Id"       left  \
                           0 "Name"    left  \
                           0 "Nb img"  right \
                           0 "Nb mes"  right \
                           0 "Moy Mag" right \
                           0 "StDev Mag" right \
                     ]
            # Table
            set ::bdi_gui_cdl::data_science $results.table
            tablelist::tablelist $::bdi_gui_cdl::data_science \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $results.hsb set ] \
              -yscrollcommand [ list $results.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1
    
            # Scrollbar
            scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::data_science xview]
            pack $results.hsb -in $results -side bottom -fill x
            scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::data_science yview]
            pack $results.vsb -in $results -side right -fill y 

            # Pack la Table
            pack $::bdi_gui_cdl::data_science -in $results -expand yes -fill both

            # Popup
            menu $results.popupTbl -title "Actions"

               $results.popupTbl add command -label "Voir l'objet dans une image" \
                   -command "" -state disabled
               $results.popupTbl add command -label "Definir Reference" \
                   -command "::bdi_gui_cdl::set_to_reference_data_science" 
               $results.popupTbl add command -label "Rejeter" \
                   -command "::bdi_gui_cdl::unset_data_science" 
               $results.popupTbl add command -label "Graphe" \
                   -command "::bdi_gui_cdl::graph_science_mag_popup" 

            # Binding
            bind $::bdi_gui_cdl::data_science <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_data_science %W ]
            bind [$::bdi_gui_cdl::data_science bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
            #    Ascii
            foreach ncol [list "Name"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::data_science columnconfigure $pcol -sortmode ascii
            }
            #    Reel
            foreach ncol [list "Id" "Nb img" "Nb mes" "Moy Mag" "StDev Mag"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::data_science columnconfigure $pcol -sortmode real
            }








         # Rejetes
         set results [frame $f_data_rejected.data_rejected  -borderwidth 1 -relief groove]
         pack $results -in $f_data_rejected -expand yes -fill both
            
            set cols [list 0 "Id"       left  \
                           0 "Name"    left  \
                           0 "Nb img"  right \
                           0 "Nb mes"  right \
                           0 "Moy Mag" right \
                           0 "StDev Mag" right \
                     ]
            # Table
            set ::bdi_gui_cdl::data_rejected $results.table
            tablelist::tablelist $::bdi_gui_cdl::data_rejected \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $results.hsb set ] \
              -yscrollcommand [ list $results.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1
    
            # Scrollbar
            scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::data_rejected xview]
            pack $results.hsb -in $results -side bottom -fill x
            scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::data_rejected yview]
            pack $results.vsb -in $results -side right -fill y 

            # Pack la Table
            pack $::bdi_gui_cdl::data_rejected -in $results -expand yes -fill both

            # Popup
            menu $results.popupTbl -title "Actions"

               $results.popupTbl add command -label "Voir l'objet dans une image" \
                   -command "" -state disabled
               $results.popupTbl add command -label "Definir Reference" \
                   -command "::bdi_gui_cdl::set_to_reference_data_rejected" 
               $results.popupTbl add command -label "Definir Science" \
                   -command "::bdi_gui_cdl::set_to_science_data_rejected" 

            # Binding
            bind $::bdi_gui_cdl::data_rejected <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_data_rejected %W ]
            bind [$::bdi_gui_cdl::data_rejected bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
            #    Ascii
            foreach ncol [list "Name"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::data_rejected columnconfigure $pcol -sortmode ascii
            }
            #    Reel
            foreach ncol [list "Id" "Nb img" "Nb mes" "Moy Mag" "StDev Mag"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::data_rejected columnconfigure $pcol -sortmode real
            }

















         # Variations
         set results [frame $f_starstar.starstar  -borderwidth 1 -relief groove]
         pack $results -in $f_starstar -expand yes -fill both
            

                  set cols [list 0 " " left ]
                  # Table
                  set ::bdi_gui_cdl::ss_mag_stdev $results.table
                  tablelist::tablelist $::bdi_gui_cdl::ss_mag_stdev \
                    -columns $cols \
                    -labelcommand tablelist::sortByColumn \
                    -xscrollcommand [ list $results.hsb set ] \
                    -yscrollcommand [ list $results.vsb set ] \
                    -selectmode extended \
                    -activestyle none \
                    -stripebackground "#e0e8f0" \
                    -showseparators 1

                  # Scrollbar
                  scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::ss_mag_stdev xview]
                  pack $results.hsb -in $results -side bottom -fill x
                  scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::ss_mag_stdev yview]
                  pack $results.vsb -in $results -side right -fill y 

                  # Pack la Table
                  pack $::bdi_gui_cdl::ss_mag_stdev -in $results -expand yes -fill both

                  # Popup
                  menu $results.popupTbl -title "Actions"

                     $results.popupTbl add command -label "Voir l'objet dans une image" \
                         -command "" -state disabled
                     $results.popupTbl add command -label "Supprimer" \
                         -command "::bdi_gui_cdl::unset_starstar $::bdi_gui_cdl::ss_mag_stdev" 


                  # Binding
                  bind $::bdi_gui_cdl::ss_mag_stdev <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_starstar %W ]
                  bind [$::bdi_gui_cdl::ss_mag_stdev bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]




         # Classification
         set results [frame $f_classif.classif  -borderwidth 1 -relief groove]
         pack $results -in $f_classif -expand yes -fill both
            
            global audace
            package require Img
            set photo [image create photo -file [ file join $audace(rep_plugin) tool bddimages images classification_spectrale.png ]]
            label $results.cs -image $photo -borderwidth 2 -width 850 -height 81
            pack $results.cs -in $results -side top -expand no 
            
            set cols [list 0 "Id"             left  \
                           0 "Name"           left  \
                           0 "Class"          left  \
                           0 "USNOA2_magB"    left  \
                           0 "USNOA2_magR"    left  \
                           0 "UCAC4_im1_mag"  left  \
                           0 "UCAC4_im2_mag"  left  \
                           0 "NOMAD1_magB"    left  \
                           0 "NOMAD1_magV"    left  \
                           0 "NOMAD1_magR"    left  \
                           0 "NOMAD1_magJ"    left  \
                           0 "NOMAD1_magH"    left  \
                           0 "NOMAD1_magK"    left  \
                     ]

            # Table
            set ::bdi_gui_cdl::classif $results.table
            tablelist::tablelist $::bdi_gui_cdl::classif \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $results.hsb set ] \
              -yscrollcommand [ list $results.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1
    
            # Scrollbar
            scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::classif xview]
            pack $results.hsb -in $results -side bottom -fill x
            scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::classif yview]
            pack $results.vsb -in $results -side right -fill y 

            # Pack la Table
            pack $::bdi_gui_cdl::classif -in $results -side top -expand yes -fill both

            # Popup
            menu $results.popupTbl -title "Actions"

               $results.popupTbl add command -label "Voir l'objet dans une image" \
                   -command "" -state disabled
               $results.popupTbl add command -label "Supprimer" \
                   -command "::bdi_gui_cdl::unset_classif" 

            # Binding
            bind $::bdi_gui_cdl::classif <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_classif %W ]
            bind [$::bdi_gui_cdl::classif bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
            #    Ascii
            foreach ncol [list "Name" "Class"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::classif columnconfigure $pcol -sortmode ascii
            }
            #    Reel
            foreach ncol [list "Id" "USNOA2_magB" "USNOA2_magR" "UCAC4_im1_mag" "UCAC4_im2_mag" "NOMAD1_magB" \
                               "NOMAD1_magV" "NOMAD1_magR"  "NOMAD1_magJ" "NOMAD1_magH" "NOMAD1_magK" ] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::classif columnconfigure $pcol -sortmode real
            }




         # Timeline
         set results [frame $f_timeline.tab  -borderwidth 1 -relief groove]
         pack $results -in $f_timeline -expand yes -fill both
            
            set cols [list 0 "Idcata"         left  \
                           0 "Date"           left  \
                           0 "NbStars"        left  \
                     ]

            # Table
            set ::bdi_gui_cdl::timeline $results.table
            tablelist::tablelist $::bdi_gui_cdl::timeline \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $results.hsb set ] \
              -yscrollcommand [ list $results.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1
    
            # Scrollbar
            scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::timeline xview]
            pack $results.hsb -in $results -side bottom -fill x
            scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::timeline yview]
            pack $results.vsb -in $results -side right -fill y 

            # Pack la Table
            pack $::bdi_gui_cdl::timeline -in $results -expand yes -fill both

            # Popup
            menu $results.popupTbl -title "Actions"

               $results.popupTbl add command -label "Voir l'objet dans une image" \
                   -command "" -state disabled
               $results.popupTbl add command -label "Supprimer" \
                   -command "::bdi_gui_cdl::unset_timeline" 

            # Binding
            bind $::bdi_gui_cdl::timeline <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_timeline %W ]
            bind [$::bdi_gui_cdl::timeline bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
            #    Ascii
            foreach ncol [list "Date" ] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::classif columnconfigure $pcol -sortmode ascii
            }
            #    Reel
            foreach ncol [list "Idcata" "NbStars" ] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::classif columnconfigure $pcol -sortmode real
            }









         #--- Cree un frame 
         set pb [frame $frm.pb  -borderwidth 0 -cursor arrow -relief groove]
         pack $pb  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set ::bdi_tools_cdl::progress 0
             set    pf [ ttk::progressbar $pb.p -variable ::bdi_tools_cdl::progress -orient horizontal -mode determinate]
             pack   $pf -in $pb -side left -expand 1 -fill x 

         #--- Cree un frame pour afficher les boutons
         set center [frame $frm.info  -borderwidth 2 -cursor arrow -relief groove]
         pack $center  -in $frm -anchor s -side bottom -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un frame pour afficher les boutons
         set info [frame $center.info  -borderwidth 0 -cursor arrow -relief groove]
         pack $info  -in $center -anchor s -side top -expand 0 -padx 10 -pady 5
 
 
             checkbutton $info.check -variable ::bdi_tools_cdl::memory(memview)  -justify left \
                -command "::bdi_tools_cdl::get_memory"
             label $info.labjob -text "Mem Job :"  -justify left
             label $info.valjob -textvariable ::bdi_tools_cdl::memory(mempid)  -justify left
             label $info.labmem -text "Mem Free % :"  -justify left
             label $info.valmem -textvariable ::bdi_tools_cdl::memory(mem)  -justify left
             label $info.labswa -text "Swap Free % :"  -justify left
             label $info.valswa -textvariable ::bdi_tools_cdl::memory(swap)  -justify left

             grid $info.check $info.labjob $info.valjob $info.labmem $info.valmem $info.labswa $info.valswa 
             
         #--- Cree un frame pour afficher les boutons
         set center [frame $frm.actions  -borderwidth 2 -cursor arrow -relief groove]
         pack $center  -in $frm -anchor s -side bottom -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un frame pour afficher les boutons
         set actions [frame $center.actions  -borderwidth 4 -cursor arrow -relief groove]
         pack $actions  -in $center -anchor s -side top -expand 0 -fill y -padx 10 -pady 5

              label $actions.labdev -text "Developpement"  -justify left
              button $actions.ressource -text "Ressource" -borderwidth 2 -takefocus 1 \
                 -command "::bddimages::ressource"
              button $actions.relance -text "Relance" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::relance"
              button $actions.clean -text "Clean" -borderwidth 2 -takefocus 1 \
                 -command "console::clear"
              button $actions.testgui -text "Test GUI" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::test_gui"

              label $actions.labcharge -text "Chargement"  -justify left
              button $actions.charge_alavolee -text "A la volee" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::charge_cata_alavolee"
              button $actions.stop -text "STOP" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::stop_charge_cata_alavolee"
              button $actions.charge_gestion -text "Gestion" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::charge_from_gestion"
              button $actions.chargelist -text "Charge LIST" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::charge_cata_list"

              label $actions.labexport -text "Export"  -justify left
              button $actions.export_gestion -text "Gestion" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::export_cata_to_gestion"

              label $actions.labsauve -text "Sauvegarde"  -justify left
              button $actions.sauve_gestion -text "Gestion" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::save_cata_from_gestion"
              button $actions.sauve_result -text "Resultats" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::save_photometry"

              label $actions.labvoir -text "Affichage"  -justify left
              button $actions.voir -text "Tables" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::affiche_data"

              label $actions.labcalc -text "Calculs"  -justify left
              button $actions.magcst -text "Const. Mag" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::calcul_const_mags"
              button $actions.calcsci -text "Science" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::calcul_science"
              button $actions.calcrej -text "Rejetes" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::calcul_rejected"

              label $actions.labref -text "References"  -justify left
              button $actions.const_mag -text "Constantes" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::graph_const_mag"
              button $actions.stars_mag -text "Stars" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::graph_stars_mag"

              label $actions.labscience -text "Sciences"  -justify left
              button $actions.science_mag -text "Mag" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::graph_science_mag"



              button $actions.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::fermer"
              button $actions.aide -text "Aide" -borderwidth 2 -takefocus 1 \
                 -command "" -state disabled


             grid $actions.labdev       -row 0 -column 0 -sticky news
             grid $actions.ressource    -row 1 -column 0 -sticky news
             grid $actions.relance      -row 2 -column 0 -sticky news
             grid $actions.clean        -row 3 -column 0 -sticky news
             grid $actions.testgui      -row 4 -column 0 -sticky news

             grid $actions.labcharge       -row 0 -column 1 -sticky news
             grid $actions.charge_alavolee -row 1 -column 1 -sticky news
             grid $actions.stop            -row 2 -column 1 -sticky news
             grid $actions.charge_gestion  -row 3 -column 1 -sticky news
             grid $actions.chargelist      -row 4 -column 1 -sticky news

             grid $actions.labexport      -row 0 -column 2 -sticky news
             grid $actions.export_gestion -row 1 -column 2 -sticky news

             grid $actions.labsauve       -row 0 -column 3 -sticky news
             grid $actions.sauve_gestion  -row 1 -column 3 -sticky news
             grid $actions.sauve_result   -row 2 -column 3 -sticky news

             grid $actions.labvoir      -row 0 -column 4 -sticky news
             grid $actions.voir         -row 1 -column 4 -sticky news

             grid $actions.labcalc      -row 0 -column 5 -sticky news
             grid $actions.magcst       -row 1 -column 5 -sticky news
             grid $actions.calcsci      -row 2 -column 5 -sticky news
             grid $actions.calcrej      -row 3 -column 5 -sticky news

             grid $actions.labref       -row 0 -column 6 -sticky news
             grid $actions.const_mag    -row 1 -column 6 -sticky news
             grid $actions.stars_mag    -row 2 -column 6 -sticky news

             grid $actions.labscience   -row 0 -column 8 -sticky news
             grid $actions.science_mag  -row 1 -column 8 -sticky news

             grid $actions.aide         -row 2 -column 10 -sticky news 
             grid $actions.fermer       -row 3 -column 10 -sticky news 

              
   }






   proc ::bdi_gui_cdl::test_gui { } {


   }





   # Structure ASTROID :
   #  0    "xsm" 
   #  1    "ysm" 
   #  2    "err_xsm" 
   #  3    "err_ysm" 
   #  4    "fwhmx" 
   #  5    "fwhmy" 
   #  6    "fwhm" 
   #  7    "flux" 
   #  8    "err_flux" 
   #  9    "pixmax"
   #  10   "intensity" 
   #  11   "sky" 
   #  12   "err_sky" 
   #  13   "snint" 
   #  14   "radius" 
   #  15   "rdiff" 
   #  16   "err_psf" 
   #  17   "ra" 
   #  18   "dec"
   #  19   "res_ra" 
   #  20   "res_dec" 
   #  21   "omc_ra" 
   #  22   "omc_dec" 
   #  23   "mag" 
   #  24   "err_mag" 
   #  25   "name" 
   #  26   "flagastrom" 
   #  27   "flagphotom" 
   #  28   "cataastrom"
   #  29   "cataphotom"
   proc ::bdi_gui_cdl::affiche_data { } {

      set tt0 [clock clicks -milliseconds]

      if {[info exists ::bdi_tools_cdl::list_of_stars]} {unset ::bdi_tools_cdl::list_of_stars}

      if {![info exists ::bdi_tools_cdl::table_data_source]} {return}

      # Onglet References

      $::bdi_gui_cdl::data_reference delete 0 end

      set ids 0
      foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
         incr ids
         if {$y != 1} {continue}
         $::bdi_gui_cdl::data_reference insert end $::bdi_tools_cdl::table_data_source($name)
         lappend ::bdi_tools_cdl::list_of_stars $ids
      }

      # Onglet Science

      $::bdi_gui_cdl::data_science delete 0 end

      set ids 0
      foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
         incr ids
         if {$y != 2} {continue}
         $::bdi_gui_cdl::data_science insert end $::bdi_tools_cdl::table_data_source($name)
      }

      # Onglet Rejected

      $::bdi_gui_cdl::data_rejected delete 0 end

      set ids 0
      foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
         incr ids
         if {$y != 0} {continue}
         $::bdi_gui_cdl::data_rejected insert end $::bdi_tools_cdl::table_data_source($name)
      }

      # Onglet variation

      $::bdi_gui_cdl::ss_mag_stdev    delete 0 end

      catch { $::bdi_gui_cdl::ss_mag_stdev deletecolumns 0 end } 

      $::bdi_gui_cdl::ss_mag_stdev    insertcolumns end 0 "" left
      $::bdi_gui_cdl::ss_mag_stdev    insertcolumns end 0 "sum" center

      
      if {[info exists ::bdi_tools_cdl::list_of_stars]} {

         set pcol 0
         foreach ids $::bdi_tools_cdl::list_of_stars {
            $::bdi_gui_cdl::ss_mag_stdev    insertcolumns end 0 $ids right
            $::bdi_gui_cdl::ss_mag_stdev    columnconfigure $pcol -sortmode real
            incr pcol
         }
      
         set magmax -1
         set col 0
         foreach ids1 $::bdi_tools_cdl::list_of_stars {
            set line_mag_stdev [list $ids1 "-"]
            set row 2
            set sum 0
            foreach ids2 $::bdi_tools_cdl::list_of_stars {
               set mag $::bdi_tools_cdl::table_variations($ids1,$ids2,mag,stdev)
               set sum [expr $sum + $mag]
               if {$mag>$magmax} {
                 # gren_info "$mag>$magmax $row,$col\n"
                  set magmax $mag
                  set colmax $col
                  set rowmax $row
               }
               lappend line_mag_stdev    [format "%.3f" $mag]
               incr row
            }
            set line_mag_stdev [lreplace $line_mag_stdev 1 1 [format "%.3f" $sum]]
            $::bdi_gui_cdl::ss_mag_stdev    insert end $line_mag_stdev
            incr col
         }

         $::bdi_gui_cdl::ss_mag_stdev cellconfigure $colmax,$rowmax -background red
         set pcol 0
         foreach ids1 $::bdi_tools_cdl::list_of_stars {
            $::bdi_gui_cdl::ss_mag_stdev    cellconfigure $pcol,[expr $pcol+2] -background darkgrey
            $::bdi_gui_cdl::ss_mag_stdev    cellconfigure $pcol,1 -background ivory
            incr pcol
         }
         $::bdi_gui_cdl::ss_mag_stdev sortbycolumn 1 -decreasing


         # Onglet Classification
         $::bdi_gui_cdl::classif delete 0 end
         set ids 0
         foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
            incr ids
            if {$y != 1} {continue}
            set line [list $ids $name $::bdi_tools_cdl::table_values($name,sptype)]
            if { ![info exists ::bdi_tools_cdl::table_mag($name,USNOA2_magB)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,USNOA2_magB)   }
            if { ![info exists ::bdi_tools_cdl::table_mag($name,USNOA2_magR)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,USNOA2_magR)   }
            if { ![info exists ::bdi_tools_cdl::table_mag($name,UCAC4_im1_mag)] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,UCAC4_im1_mag) }
            if { ![info exists ::bdi_tools_cdl::table_mag($name,UCAC4_im2_mag)] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,UCAC4_im2_mag) }
            if { ![info exists ::bdi_tools_cdl::table_mag($name,NOMAD1_magB)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,NOMAD1_magB)   }
            if { ![info exists ::bdi_tools_cdl::table_mag($name,NOMAD1_magV)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,NOMAD1_magV)   }
            if { ![info exists ::bdi_tools_cdl::table_mag($name,NOMAD1_magR)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,NOMAD1_magR)   }
            if { ![info exists ::bdi_tools_cdl::table_mag($name,NOMAD1_magJ)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,NOMAD1_magJ)   }
            if { ![info exists ::bdi_tools_cdl::table_mag($name,NOMAD1_magH)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,NOMAD1_magH)   }
            if { ![info exists ::bdi_tools_cdl::table_mag($name,NOMAD1_magK)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,NOMAD1_magK)   }
            $::bdi_gui_cdl::classif insert end $line
         }
         $::bdi_gui_cdl::classif columnconfigure 2 -sortmode ascii
         $::bdi_gui_cdl::classif sortbycolumn 2

         # Onglet Timeline

         $::bdi_gui_cdl::timeline    delete 0 end

         catch { $::bdi_gui_cdl::timeline    deletecolumns 0 end } 

         $::bdi_gui_cdl::timeline insertcolumns end 0 "idcata"  left
         $::bdi_gui_cdl::timeline insertcolumns end 0 "Date"    center
         $::bdi_gui_cdl::timeline insertcolumns end 0 "NbStars" center

         set pcol 0
         foreach ids $::bdi_tools_cdl::list_of_stars {
            $::bdi_gui_cdl::timeline    insertcolumns end 0 $ids right
            $::bdi_gui_cdl::timeline    columnconfigure $pcol -sortmode real
            incr pcol
         }

         set idcata 0
         for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {

            if {![info exists ::bdi_tools_cdl::table_date($idcata)]} { 
               continue 
            }
            set line [list $idcata $::bdi_tools_cdl::table_date($idcata) ""]
            set cpt 0
            foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
               if {$y != 1} {continue}
               if {![info exists ::bdi_tools_cdl::table_mesure($idcata,$name)]} { 
                  lappend line 0
                  continue 
               }
               if { $::bdi_tools_cdl::table_mesure($idcata,$name) != 1 } { 
                  lappend line 0
                  continue 
               }

               incr cpt
               lappend line 1
            }
            set line [lreplace $line 2 2 $cpt]
            $::bdi_gui_cdl::timeline insert end $line
         }
         $::bdi_gui_cdl::timeline columnconfigure 0 -sortmode real
         $::bdi_gui_cdl::timeline columnconfigure 1 -sortmode ascii
         $::bdi_gui_cdl::timeline sortbycolumn 1 

      # fin test : if {![info exists ::bdi_tools_cdl::list_of_stars]} {}
      }

      # Fin de visualisation des donnees
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Affichage complet en $tt sec \n"

      return

   }









   proc ::bdi_gui_cdl::set_to_science_data_reference { } {

      foreach select [$::bdi_gui_cdl::data_reference curselection] {
         set name [lindex [$::bdi_gui_cdl::data_reference get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 2
         gren_info "$name to Science\n"
      }
      ::bdi_gui_cdl::affiche_data

   }

   proc ::bdi_gui_cdl::set_to_reference_data_science { } {

      foreach select [$::bdi_gui_cdl::data_science curselection] {
         set name [lindex [$::bdi_gui_cdl::data_science get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 1
      }
      ::bdi_gui_cdl::affiche_data

   }

   proc ::bdi_gui_cdl::set_to_reference_data_rejected { } {

      foreach select [$::bdi_gui_cdl::data_rejected curselection] {
         set name [lindex [$::bdi_gui_cdl::data_rejected get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 1
      }
      ::bdi_gui_cdl::affiche_data

   }

   proc ::bdi_gui_cdl::set_to_science_data_rejected { } {

      foreach select [$::bdi_gui_cdl::data_rejected curselection] {
         set name [lindex [$::bdi_gui_cdl::data_rejected get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 2
      }
      ::bdi_gui_cdl::affiche_data

   }






   proc ::bdi_gui_cdl::unset_data_reference { } {

      foreach select [$::bdi_gui_cdl::data_reference curselection] {
         set name [lindex [$::bdi_gui_cdl::data_reference get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 0
      }
      ::bdi_gui_cdl::affiche_data
   }

   proc ::bdi_gui_cdl::unset_data_science { } {

      foreach select [$::bdi_gui_cdl::data_science curselection] {
         set name [lindex [$::bdi_gui_cdl::data_science get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 0
      }
      ::bdi_gui_cdl::affiche_data
   }





   proc ::bdi_gui_cdl::unset_classif { } {

      foreach select [$::bdi_gui_cdl::classif curselection] {
         set name [lindex [$::bdi_gui_cdl::classif get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 0
      }
      ::bdi_gui_cdl::affiche_data
   }

   proc ::bdi_gui_cdl::unset_starstar { tbl } {

      foreach select [$tbl curselection] {
         set ids [lindex [$tbl get $select] 0]
         set name $::bdi_tools_cdl::id_to_name($ids)
         set ::bdi_tools_cdl::table_noms($name) 0
      }
      ::bdi_gui_cdl::affiche_data
   }




   proc ::bdi_gui_cdl::graph_const_mag {  } {
      
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
      ::plotxy::title "Constantes des magnitudes au cours du temps" 

      array unset x  
      array unset y
      
      for {set idcata 1} {$idcata < $::tools_cata::nb_img_list} { incr idcata } {

         set id_superstar $::bdi_tools_cdl::table_superstar_idcata($idcata)
         #if { $id_superstar !=1 } { continue }


         gren_info "$idcata=> id_superstar $id_superstar ($::bdi_tools_cdl::table_superstar_id($id_superstar))\n"
         foreach ids $::bdi_tools_cdl::table_superstar_id($id_superstar) {

            set name  $::bdi_tools_cdl::id_to_name($ids)
            set mag   [lindex $::bdi_tools_cdl::table_data_source($name) 4]
            set flux  $::bdi_tools_cdl::table_star_flux($name,$idcata,flux)

            set magss [expr $mag -2.5 * log10(1.0 * $::bdi_tools_cdl::table_superstar_flux($id_superstar,$idcata) / $flux) ]

            lappend x($id_superstar)  $idcata
            lappend y($id_superstar)  $magss

         }

      }
      set color [list black blue red green yellow grey ]
      set cpt 0
      foreach {indice_superstar id_superstar} [array get ::bdi_tools_cdl::table_superstar_exist] {
         gren_info "id_superstar $id_superstar mag = $::bdi_tools_cdl::table_superstar_solu($id_superstar,mag) stdev = $::bdi_tools_cdl::table_superstar_solu($id_superstar,stdevmag) \n"
         set h [::plotxy::plot $x($id_superstar) $y($id_superstar) .]
         plotxy::sethandler $h [list -color [lindex $color $cpt] -linewidth 0]
         incr cpt
         if { $cpt >= [llength $color] } {
            set cpt 0
         }
      }

      
   }
   
   proc ::bdi_gui_cdl::graph_stars_mag {  } {

      
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}

      ::plotxy::title "Magnitude des etoiles de reference au cours du temps" 

      array unset x  
      array unset y
      array unset list_star

      for {set idcata 1} {$idcata < $::tools_cata::nb_img_list} { incr idcata } {

         set id_superstar $::bdi_tools_cdl::table_superstar_idcata($idcata)

         foreach ids $::bdi_tools_cdl::table_superstar_id($id_superstar) {
            lappend x($ids) $idcata
            lappend y($ids) $::bdi_tools_cdl::table_star_mag($ids,$idcata)
            set list_star($ids) 1
         }
      }

      set color [list black blue red green yellow grey ]
      set cpt 0
      foreach { ids o } [array get list_star] {
         set h [::plotxy::plot $x($ids) $y($ids) .]
         gren_info "ids = $ids cpt = $cpt\n"
         plotxy::sethandler $h [list -color [lindex $color $cpt] -linewidth 1]
         incr cpt
         if { $cpt >= [llength $color] } {
            set cpt 0
         }
      }


   }

   proc ::bdi_gui_cdl::graph_science_mag_popup {  } {

      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
      ::plotxy::title "Courbe de lumiere des objets sciences " 
      array unset x  
      array unset y
      set list_source ""
      set colors [list blue red green yellow grey black ]
      set cpt 0
      foreach select [$::bdi_gui_cdl::data_science curselection] {
         set ids [lindex [$::bdi_gui_cdl::data_science get $select] 0]
         set name [lindex [$::bdi_gui_cdl::data_science get $select] 1]
         lappend list_source $ids
         set color [lindex $colors $cpt]
         gren_info "Graph $name color : $color\n"
         incr cpt
         if { $cpt >= [llength $colors] } {
            set cpt 0
         }

         for {set idcata 1} {$idcata < $::tools_cata::nb_img_list} { incr idcata } {
            if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata)]} {continue}
            lappend x($ids)  $idcata
            lappend y($ids)  $::bdi_tools_cdl::table_science_mag($ids,$idcata)
         }

         set h [::plotxy::plot $x($ids) $y($ids) .]
         plotxy::sethandler $h [list -color $color -linewidth 0]

      }
      
      
      
      
   }

   proc ::bdi_gui_cdl::graph_science_mag {  } {

      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
      ::plotxy::title "Courbe de lumiere des objets sciences " 
      array unset x  
      array unset y
      set list_source ""
      set colors [list blue red green yellow grey black ]
      set cpt 0


      set ids 0
      foreach {name o} [array get ::bdi_tools_cdl::table_noms] {
         incr ids
         if {$o != 2} {continue}

         lappend list_source $ids
         set color [lindex $colors $cpt]
         gren_info "Graph $name color : $color\n"
         incr cpt
         if { $cpt >= [llength $colors] } {
            set cpt 0
         }

         for {set idcata 1} {$idcata < $::tools_cata::nb_img_list} { incr idcata } {
            if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata)]} {continue}
            lappend x($ids)  $idcata
            lappend y($ids)  [expr $::bdi_tools_cdl::table_science_mag($ids,$idcata) - [lindex $::bdi_tools_cdl::table_data_source($name) 4] ]
         }

         set h [::plotxy::plot $x($ids) $y($ids) .]
         plotxy::sethandler $h [list -color $color -linewidth 0]

      }


   }
