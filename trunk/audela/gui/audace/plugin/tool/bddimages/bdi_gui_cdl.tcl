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
      
      ::bdi_tools_cdl::inittoconf
      ::bdi_tools_cdl::free_memory
   }

   #----------------------------------------------------------------------------
   ## Fermeture de la fenetre .
   # Les variables utilisees sont affectees a la variable globale
   # \c conf
   proc ::bdi_gui_cdl::fermer {  } {

      # sauvegarde de la configuration
      ::bdi_tools_cdl::closetoconf

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

      catch { $::bdi_gui_cdl::ss_mag_stdev deletecolumns 0 end } 

   }

   proc ::bdi_gui_cdl::charge_from_gestion { } {

      ::bdi_tools_cdl::free_memory
      ::bdi_gui_cdl::clean_gui_photometry
      ::bdi_gui_cdl::affich_gestion
      ::bdi_tools_cdl::charge_from_gestion

      ::bdi_gui_cdl::calcule_tout
      
      ::bdi_gui_cdl::affiche_data
   }

   #----------------------------------------------------------------------------
   ## Affichage de l outil de gestion des cata
   proc ::bdi_gui_cdl::affich_gestion { } {

      if {![info exists ::cata_gestion_gui::fen]} {
         ::cata_gestion_gui::go $::tools_cata::img_list
      } else {
         if {[winfo exists $::cata_gestion_gui::fen]==0} {
            ::cata_gestion_gui::go $::tools_cata::img_list
         }
      }
      return
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
            set f_results        [frame $onglets.nb.f_results]
            set f_bigdata        [frame $onglets.nb.f_bigdata]
            set f_develop        [frame $onglets.nb.f_develop]

            $onglets.nb add $f_data_reference -text "References"
            $onglets.nb add $f_data_science   -text "Sciences"
            $onglets.nb add $f_data_rejected  -text "Rejetees"
            $onglets.nb add $f_starstar       -text "Variations"
            $onglets.nb add $f_classif        -text "Classification"
            $onglets.nb add $f_results        -text "Resultats"
            $onglets.nb add $f_bigdata        -text "Big Data"
            $onglets.nb add $f_develop        -text "Develop"

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
               $results.popupTbl add command -label "Table" \
                   -command "::bdi_gui_cdl::table_popup ref" 

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
               $results.popupTbl add command -label "Table" \
                   -command "::bdi_gui_cdl::table_popup sci" 

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



      set wdth 13

         # Resultats
         set results [frame $f_results.data_reference  -borderwidth 1 -relief groove]
         pack $results -in $f_results -expand yes -fill both

            #--- Onglet RAPPORT - Entetes
            set block [frame $results.uai_code  -borderwidth 0 -cursor arrow -relief groove]
            pack $block  -in $results -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  label  $block.lab -text "IAU Code : " -borderwidth 1 -width $wdth
                  pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                  entry  $block.val -relief sunken -width 5 -textvariable ::bdi_tools_cdl::rapport_uai_code
                  pack   $block.val -side left -padx 3 -pady 3 -anchor w

                  label  $block.loc -textvariable ::bdi_tools_astrometry::rapport_uai_location -borderwidth 1 -width $wdth
                  pack   $block.loc -side left -padx 3 -pady 3 -anchor w

            set block [frame $results.rapporteur  -borderwidth 0 -cursor arrow -relief groove]
            pack $block  -in $results -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  label  $block.lab -text "Rapporteur : " -borderwidth 1 -width $wdth
                  pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                  entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_cdl::rapport_rapporteur
                  pack   $block.val -side left -padx 3 -pady 3 -anchor w

            set block [frame $results.adresse  -borderwidth 0 -cursor arrow -relief groove]
            pack $block  -in $results -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  label  $block.lab -text "Adresse : " -borderwidth 1 -width $wdth
                  pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                  entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_cdl::rapport_adresse
                  pack   $block.val -side left -padx 3 -pady 3 -anchor w

            set block [frame $results.mail  -borderwidth 0 -cursor arrow -relief groove]
            pack $block  -in $results -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  label  $block.lab -text "Mail : " -borderwidth 1 -width $wdth
                  pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                  entry  $block.val -relief sunken -width 80  -textvariable ::bdi_tools_cdl::rapport_mail
                  pack   $block.val -side left -padx 3 -pady 3 -anchor w

            set block [frame $results.observ  -borderwidth 0 -cursor arrow -relief groove]
            pack $block  -in $results -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  label  $block.lab -text "Observateurs : " -borderwidth 1 -width $wdth
                  pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                  entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_cdl::rapport_observ
                  pack   $block.val -side left -padx 3 -pady 3 -anchor w

            set block [frame $results.reduc  -borderwidth 0 -cursor arrow -relief groove]
            pack $block  -in $results -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  label  $block.lab -text "Reduction : " -borderwidth 1 -width $wdth
                  pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                  entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_cdl::rapport_reduc
                  pack   $block.val -side left -padx 3 -pady 3 -anchor w

            set block [frame $results.instru  -borderwidth 0 -cursor arrow -relief groove]
            pack $block  -in $results -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  label  $block.lab -text "Instrument : " -borderwidth 1 -width $wdth
                  pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                  entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_cdl::rapport_instru
                  pack   $block.val -side left -padx 3 -pady 3 -anchor w

            set block [frame $results.labcom  -borderwidth 0 -cursor arrow -relief groove]
            pack $block  -in $results -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  label  $block.lab -text "Commentaire pour le rapport final : " -borderwidth 1 
                  pack   $block.lab -side left -padx 3 -pady 3 -anchor w

           set block [frame $results.comment  -borderwidth 0 -cursor arrow -relief groove]
            pack $block  -in $results -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  label  $block.lab -text "" -borderwidth 1 -width $wdth
                  pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                  entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_cdl::rapport_comment
                  pack   $block.val -side left -padx 3 -pady 3 -anchor w


            set block [frame $results.actionsave  -borderwidth 0 -cursor arrow -relief groove]
            pack $block  -in $results -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  button $block.sauve_result -text "Sauver" -borderwidth 2 -takefocus 1 \
                     -command "::bdi_gui_cdl::save_reports"
                  pack   $block.sauve_result -side top -padx 3 -pady 3 -anchor c


         # Big DATA
         set center [frame $f_bigdata.frm  -borderwidth 1 -relief groove]
         pack $center -in $f_bigdata -expand yes -fill both

            set actions [frame $center.center  -borderwidth 0 -relief sunken]
            pack $actions -in $center -expand no -fill y
              

              checkbutton $actions.check -variable ::bdi_tools_cdl::bigdata  -justify left \
                -text "Fonctionnalitee pour reduire l'utilisation de la memoire"

              label $actions.labcharge -text "Chargement"  -justify left
              button $actions.charge_alavolee -text "A la volee" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::charge_cata_alavolee"
              button $actions.stop -text "STOP" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::stop_charge_cata_alavolee"
              button $actions.chargelist -text "Charge LIST" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::charge_cata_list"

             grid $actions.check           -row 0 -column 0  -columnspan 3 -sticky news -ipadx 10 -ipady 10

             grid $actions.labcharge       -row 1 -column 0 -sticky news -ipady 10
             grid $actions.charge_alavolee -row 2 -column 0 -sticky news
             grid $actions.stop            -row 3 -column 0 -sticky news
             grid $actions.chargelist      -row 4 -column 0 -sticky news

              label $actions.labcalc -text "Calculs"  -justify left
              button $actions.magcst -text "Constante des Mag" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::calcul_const_mags"
              button $actions.calcsci -text "Sources Science" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::calcul_science"
              button $actions.calcrej -text "Sources Rejetes" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::calcul_rejected"
              button $actions.variation -text "Table de variations" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::calcul_variation"
              button $actions.typspec -text "Type spectral" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::calcul_classification"

             grid $actions.labcalc    -row 1 -column 1 -sticky news -ipady 10
             grid $actions.magcst     -row 2 -column 1 -sticky news
             grid $actions.calcsci    -row 3 -column 1 -sticky news
             grid $actions.calcrej    -row 4 -column 1 -sticky news
             grid $actions.variation  -row 5 -column 1 -sticky news
             grid $actions.typspec    -row 6 -column 1 -sticky news

              label $actions.labvoir -text "Affichage"  -justify left
              button $actions.voir -text "Tables" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::affiche_data"

             grid $actions.labvoir      -row 1 -column 2 -sticky news -ipady 10
             grid $actions.voir         -row 2 -column 2 -sticky news



         # Develop
         set actions [frame $f_develop.frm  -borderwidth 1 -relief groove]
         pack $actions -in $f_develop -expand yes -fill both


              button $actions.ressource -text "Ressource les scripts" -borderwidth 2 -takefocus 1 \
                 -command "::bddimages::ressource"
              button $actions.relance -text "Relance la GUI" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::relance"
              button $actions.clean -text "Efface le contenu de la console" -borderwidth 2 -takefocus 1 \
                 -command "console::clear"
              button $actions.testgui -text "Test GUI" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::test_gui"


             grid $actions.ressource    -row 1 -column 0 -sticky news
             grid $actions.relance      -row 2 -column 0 -sticky news
             grid $actions.clean        -row 3 -column 0 -sticky news
             grid $actions.testgui      -row 4 -column 0 -sticky news



         #--- Cree un frame 
         set pb [frame $frm.pb  -borderwidth 0 -cursor arrow -relief groove]
         pack $pb  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set ::bdi_tools_cdl::progress 0
             set    pf [ ttk::progressbar $pb.p -variable ::bdi_tools_cdl::progress -orient horizontal -mode determinate]
             pack   $pf -in $pb -side left -expand 1 -fill x 


         #--- Cree un frame pour afficher les boutons
         set center [frame $frm.cnbsources  -borderwidth 2 -cursor arrow -relief groove]
         pack $center  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un frame 
         set nbsources [frame $center.nbsources  -borderwidth 0 -cursor arrow -relief groove]
         pack $nbsources  -in $center -anchor s -side top -expand 0 -padx 10 -pady 5

              label $nbsources.labref -text "Nb References :"  
              label $nbsources.nbref  -textvariable ::bdi_tools_cdl::nbref
              label $nbsources.labsci -text " - Nb Sciences :"  
              label $nbsources.nbsci  -textvariable ::bdi_tools_cdl::nbscience
              label $nbsources.labrej -text " - Nb Rejetees :"  
              label $nbsources.nbrej  -textvariable ::bdi_tools_cdl::nbrej

              grid $nbsources.labref $nbsources.nbref  $nbsources.labsci $nbsources.nbsci  $nbsources.labrej $nbsources.nbrej -sticky news

         #--- Cree un frame pour afficher les boutons
         set center [frame $frm.actions  -borderwidth 2 -cursor arrow -relief groove]
         pack $center  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un frame pour afficher les boutons
         set actions [frame $center.actions  -borderwidth 4 -cursor arrow -relief groove]
         pack $actions  -in $center -anchor s -side top -expand 0 -fill y -padx 10 -pady 5


              label $actions.labgestion -text "Gestion"  -justify left
              button $actions.charge_gestion -text "Charge" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::charge_from_gestion"
              button $actions.sauve_gestion -text "Sauve" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::save_image_cata"

              label $actions.labref -text "References"  -justify left
              button $actions.const_mag -text "Constantes" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::graph_const_mag"
              button $actions.stars_mag -text "Stars" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::graph_stars_mag"
              button $actions.timeline  -text "Timeline" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::graph_timeline"

              label $actions.labscience -text "Sciences"  -justify left
              button $actions.science_mag -text "Mag" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::graph_science_mag"
              button $actions.science_unset -text "Clean graph" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::unset_science_in_graph"

              button $actions.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::fermer"
              button $actions.aide -text "Aide" -borderwidth 2 -takefocus 1 \
                 -command "" -state disabled


             grid $actions.labgestion      -row 0 -column 2 -sticky news
             grid $actions.charge_gestion  -row 1 -column 2 -sticky news
             grid $actions.sauve_gestion   -row 2 -column 2 -sticky news

             grid $actions.labref       -row 0 -column 6 -sticky news
             grid $actions.const_mag    -row 1 -column 6 -sticky news
             grid $actions.stars_mag    -row 2 -column 6 -sticky news
             grid $actions.timeline     -row 3 -column 6 -sticky news

             grid $actions.labscience    -row 0 -column 8 -sticky news
             grid $actions.science_mag   -row 1 -column 8 -sticky news
             grid $actions.science_unset -row 2 -column 8 -sticky news

             grid $actions.aide         -row 2 -column 10 -sticky news 
             grid $actions.fermer       -row 3 -column 10 -sticky news 

              

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
             

   }






   #-------------------------------------------------------------------
   ## Effectue un test de la GUI
   # \ l idee est d afficher un grand nombre de ligne pour voir 
   # evoluer la memoire
   #  \param void 
   #  \return void
   proc ::bdi_gui_cdl::test_gui { } {


   }





   #-------------------------------------------------------------------
   ## Affiche les valeurs dans les tables Science References et Rejets
   # \brief
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
   #
   #  \param void 
   #  \return void
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

      # Fin de visualisation des donnees
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Affichage complet en $tt sec \n"

      return

   }


   proc ::bdi_gui_cdl::calcule_tout { } {
   
      if {$::bdi_tools_cdl::bigdata==0} {
         ::bdi_tools_cdl::charge_cata_list
         ::bdi_tools_cdl::calcul_const_mags
         ::bdi_tools_cdl::calcul_science
         ::bdi_tools_cdl::calcul_rejected
         ::bdi_gui_cdl::calcul_variation
         ::bdi_gui_cdl::calcul_classification
         ::bdi_gui_cdl::affiche_data
         if {[::plotxy::figure]} {
            ::bdi_gui_cdl::graph_science_mag_popup_exec
         }
      }
      
   }




   #----------------------------------------------------------------------------
   ## Affiche le calcul de la variation etoile a etoile de reference
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::calcul_variation { } {

      set tt0 [clock clicks -milliseconds]

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

      }

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Calcul des variations en $tt sec \n"

   }





   #----------------------------------------------------------------------------
   ## Affiche la classification spectrale des etoiles 
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::calcul_classification { } {

      set tt0 [clock clicks -milliseconds]

      if {[info exists ::bdi_tools_cdl::list_of_stars]} {

         # Onglet Classification
         $::bdi_gui_cdl::classif delete 0 end
         set ids 0
         foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
            incr ids
            if {$y != 1} {continue}
            set line [list $ids $name $::bdi_tools_cdl::table_values($name,sptype)]
            gren_info "name class = $name\n"
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


      # fin test : if {![info exists ::bdi_tools_cdl::list_of_stars]} {}
      }

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Calcul des Classifications en $tt sec \n"
   }















   #----------------------------------------------------------------------------
   ## Definit un objet science dans la tables des objets references
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::set_to_science_data_reference { } {
      
      foreach select [$::bdi_gui_cdl::data_reference curselection] {

         incr ::bdi_tools_cdl::nbscience
         incr ::bdi_tools_cdl::nbref -1
      
         set name [lindex [$::bdi_gui_cdl::data_reference get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 2
         gren_info "$name to Science\n"
      }
      ::bdi_gui_cdl::affiche_data
      ::bdi_gui_cdl::calcule_tout

   }

   #----------------------------------------------------------------------------
   ## Definit un objet reference dans la tables des objets sciences
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::set_to_reference_data_science { } {

      foreach select [$::bdi_gui_cdl::data_science curselection] {
         incr ::bdi_tools_cdl::nbref
         incr ::bdi_tools_cdl::nbscience -1
      
         set idps [lindex [$::bdi_gui_cdl::data_science get $select] 0]      
         set name [lindex [$::bdi_gui_cdl::data_science get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 1
      }
      ::bdi_tools_cdl::add_to_ref $name $idps
      ::bdi_gui_cdl::affiche_data
      ::bdi_gui_cdl::calcule_tout

   }

   #----------------------------------------------------------------------------
   ## Definit un objet reference dans la tables des objets rejetes
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::set_to_reference_data_rejected { } {

      foreach select [$::bdi_gui_cdl::data_rejected curselection] {
         incr ::bdi_tools_cdl::nbref
         incr ::bdi_tools_cdl::nbrej -1
         set idps [lindex [$::bdi_gui_cdl::data_rejected get $select] 0]      
         set name [lindex [$::bdi_gui_cdl::data_rejected get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 1
      }
      ::bdi_tools_cdl::add_to_ref $name $idps
      ::bdi_gui_cdl::affiche_data
      ::bdi_gui_cdl::calcule_tout
   }

   #----------------------------------------------------------------------------
   ## Definit un objet science dans la tables des objets rejetes
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::set_to_science_data_rejected { } {

      foreach select [$::bdi_gui_cdl::data_rejected curselection] {
         incr ::bdi_tools_cdl::nbscience
         incr ::bdi_tools_cdl::nbrej -1
         set name [lindex [$::bdi_gui_cdl::data_rejected get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 2
      }
      ::bdi_gui_cdl::affiche_data
      ::bdi_gui_cdl::calcule_tout

   }

   #----------------------------------------------------------------------------
   ## Rejete une source dans la table des objets references
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::unset_data_reference { } {

      foreach select [$::bdi_gui_cdl::data_reference curselection] {
         incr ::bdi_tools_cdl::nbrej
         incr ::bdi_tools_cdl::nbref -1
         set name [lindex [$::bdi_gui_cdl::data_reference get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 0
      }
      ::bdi_gui_cdl::affiche_data
      ::bdi_gui_cdl::calcule_tout
   }

   #----------------------------------------------------------------------------
   ## Rejete une source dans la table des objets sciences
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::unset_data_science { } {

      foreach select [$::bdi_gui_cdl::data_science curselection] {
         incr ::bdi_tools_cdl::nbrej
         incr ::bdi_tools_cdl::nbscience -1
         set name [lindex [$::bdi_gui_cdl::data_science get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 0
      }
      ::bdi_gui_cdl::affiche_data
      ::bdi_gui_cdl::calcule_tout
   }

   #----------------------------------------------------------------------------
   ## Rejete une source dans la table des types spectraux
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::unset_classif { } {

      foreach select [$::bdi_gui_cdl::classif curselection] {
         incr ::bdi_tools_cdl::nbrej
         incr ::bdi_tools_cdl::nbref -1
         set name [lindex [$::bdi_gui_cdl::classif get $select] 1]      
         set ::bdi_tools_cdl::table_noms($name) 0
      }
      ::bdi_gui_cdl::affiche_data
      ::bdi_gui_cdl::calcule_tout
   }

   #----------------------------------------------------------------------------
   ## Rejete une source dans la table des variations
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::unset_starstar { tbl } {

      foreach select [$tbl curselection] {
         incr ::bdi_tools_cdl::nbrej
         incr ::bdi_tools_cdl::nbref -1
         set ids [lindex [$tbl get $select] 0]
         set name $::bdi_tools_cdl::id_to_name($ids)
         set ::bdi_tools_cdl::table_noms($name) 0
      }
      ::bdi_gui_cdl::affiche_data
      ::bdi_gui_cdl::calcule_tout
   }



   #----------------------------------------------------------------------------
   ## Enregistre les images et cata en affichant une barre de pregression
   # et un bouton d'annulation du traitement
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::save_image_cata {  } {

#      $::bdi_gui_astrometry::fen.appli.info.fermer configure -state disabled
#      $::bdi_gui_astrometry::fen.appli.info.enregistrer configure -state disabled

      set tt0 [clock clicks -milliseconds]

      set ::bdi_tools_cdl::savprogress 0
      set ::bdi_tools_cdl::savannul 0

      set ::bdi_gui_cdl::fensav .savprogress
      if { [winfo exists $::bdi_gui_cdl::fensav] } {
         wm withdraw $::bdi_gui_cdl::fensav
         wm deiconify $::bdi_gui_cdl::fensav
         focus $::bdi_gui_cdl::fensav
         return
      }

      toplevel $::bdi_gui_cdl::fensav -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::bdi_gui_cdl::fensav ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::bdi_gui_cdl::fensav ] "+" ] 2 ]
      wm geometry $::bdi_gui_cdl::fensav +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::bdi_gui_cdl::fensav 1 1
      wm title $::bdi_gui_cdl::fensav "Enregistrement"
      wm protocol $::bdi_gui_cdl::fensav WM_DELETE_WINDOW ""

      set frm $::bdi_gui_cdl::fensav.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::bdi_gui_cdl::fensav -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

         set data  [frame $frm.progress -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set    pf [ ttk::progressbar $data.p -variable ::bdi_tools_cdl::savprogress -orient horizontal -length 200 -mode determinate]
             pack   $pf -in $data -side top

         set data  [frame $frm.boutons -borderwidth 0 -cursor arrow -relief groove]
         pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $data.annul -state active -text "Annuler" -relief "raised" \
                -command "::bdi_gui_cdl::annul_save_images"
             pack   $data.annul -side top -anchor c -padx 0 -padx 10 -pady 5

      update
      ::bdi_tools_cdl::save_images

      # on met a jour les table de la gui de gestion
      for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image <= $::tools_cata::nb_img_list} { incr ::tools_cata::id_current_image } {
         set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)
         ::tools_cata::current_listsources_to_tklist
         set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::gui_cata::tklist]
         set ::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::gui_cata::tklist_list_of_columns]
         set ::gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::gui_cata::cataname]
      }
      
      # On reaffiche gestion
      ::cata_gestion_gui::charge_image_directaccess

      destroy $::bdi_gui_cdl::fensav

#      $::bdi_gui_cdl::fen.appli.info.fermer configure -state normal
#      $::bdi_gui_cdl::fen.appli.info.enregistrer configure -state normal
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Sauvegarde des images et cata en $tt sec \n"

   }




   #----------------------------------------------------------------------------
   ## Annule l'enregistrement en cours, des images et cata
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::annul_save_images { } {

      $::bdi_gui_cdl::fensav.appli.boutons.annul configure -state disabled
      set ::bdi_tools_cdl::savannul 1

   }



   #----------------------------------------------------------------------------
   ## Enregistre les resultats sous forme de rapport Texte et XML/VOTABLE  
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::save_reports {  } {

      ::bdi_tools_cdl::closetoconf
      set err [ catch { ::bdi_tools_cdl::save_reports } msg]
      if {$err} {
         tk_messageBox -message "Erreur : $msg" -type ok
      }
   }




   #----------------------------------------------------------------------------
   ## Affichage du graphe de la constante des magnitudes  
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::graph_const_mag {  } {
      
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
      ::plotxy::title "Constantes des magnitudes au cours du temps" 
      ::plotxy::xlabel "Time (jd)" 
      ::plotxy::ylabel "Mag" 

      array unset x  
      array unset y
      set pass "no"
      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {

         if {![info exists ::bdi_tools_cdl::table_superstar_idcata($idcata)]} {continue}
         set pass "yes"
         set id_superstar $::bdi_tools_cdl::table_superstar_idcata($idcata)
         #gren_info "$idcata=> id_superstar $id_superstar ($::bdi_tools_cdl::table_superstar_id($id_superstar))\n"
         foreach ids $::bdi_tools_cdl::table_superstar_id($id_superstar) {

            set name  $::bdi_tools_cdl::id_to_name($ids)
            set mag   [lindex $::bdi_tools_cdl::table_data_source($name) 4]
            set flux  $::bdi_tools_cdl::table_star_flux($name,$idcata,flux)

            set magss [expr $mag -2.5 * log10(1.0 * $::bdi_tools_cdl::table_superstar_flux($id_superstar,$idcata) / $flux) ]

            lappend x($id_superstar)  $::bdi_tools_cdl::idcata_to_jdc($idcata)
            lappend y($id_superstar)  $magss

         }
      }

      if {$pass=="no"} {
         tk_messageBox -message "Veuillez ajouter des sources de references" -type ok
         return
      }

      set color [list black blue red green yellow grey ]
      set cpt 0
      foreach {indice_superstar id_superstar} [array get ::bdi_tools_cdl::table_superstar_exist] {
         #gren_info "id_superstar $id_superstar mag = $::bdi_tools_cdl::table_superstar_solu($id_superstar,mag) stdev = $::bdi_tools_cdl::table_superstar_solu($id_superstar,stdevmag) \n"
         set h [::plotxy::plot $x($id_superstar) $y($id_superstar) .]
         plotxy::sethandler $h [list -color [lindex $color $cpt] -linewidth 0]
         incr cpt
         if { $cpt >= [llength $color] } {
            set cpt 0
         }
      }

      return
   }
   




   #----------------------------------------------------------------------------
   ## Affichage du graphe qui presente la magnitude des etoiles de reference 
   # au cours du temps
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::graph_stars_mag {  } {

      
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}

      ::plotxy::title "Magnitude des etoiles de reference au cours du temps" 
      ::plotxy::xlabel "Time (jd)" 
      ::plotxy::ylabel "Mag" 

      array unset x  
      array unset y
      array unset list_star
      set pass "no"

      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {

         if {![info exists ::bdi_tools_cdl::table_superstar_idcata($idcata)]} {continue}
         set pass "yes"
         set id_superstar $::bdi_tools_cdl::table_superstar_idcata($idcata)

         foreach ids $::bdi_tools_cdl::table_superstar_id($id_superstar) {
            lappend x($ids) $::bdi_tools_cdl::idcata_to_jdc($idcata)
            lappend y($ids) $::bdi_tools_cdl::table_star_mag($ids,$idcata)
            set list_star($ids) 1
         }
      }

      if {$pass=="no"} {
         tk_messageBox -message "Veuillez ajouter des sources de references" -type ok
         return
      }

      set color [list black blue red green yellow grey ]
      set cpt 0
      foreach { ids o } [array get list_star] {
         set h [::plotxy::plot $x($ids) $y($ids) .]
         plotxy::sethandler $h [list -color [lindex $color $cpt] -linewidth 1]
         incr cpt
         if { $cpt >= [llength $color] } {
            set cpt 0
         }
      }

      return
   }





   #----------------------------------------------------------------------------
   ## Affichage du graphe Timeline 
   # ce graphe represente la presence au cours du temps des etoiles de reference
   #  \param void 
   #  \return void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::graph_timeline { } {

      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
      ::plotxy::title "Timeline" 
      ::plotxy::xlabel "Time" 
      ::plotxy::ylabel "Id Stars" 

      array unset x  
      array unset y
      array unset list_star
      set pass "no"

      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {

         if {![info exists ::bdi_tools_cdl::table_superstar_idcata($idcata)]} {continue}
         set pass "yes"
         set id_superstar $::bdi_tools_cdl::table_superstar_idcata($idcata)

         foreach ids $::bdi_tools_cdl::table_superstar_id($id_superstar) {
            lappend x($ids) $::bdi_tools_cdl::idcata_to_jdc($idcata)
            lappend y($ids) $ids
            set list_star($ids) 1
         }
      }

      if {$pass=="no"} {
         tk_messageBox -message "Veuillez ajouter des sources de references" -type ok
         return
      }

      set color [list black blue red green yellow grey ]
      set cpt 0
      foreach { ids o } [array get list_star] {
         set h [::plotxy::plot $x($ids) $y($ids) o]
         plotxy::sethandler $h [list -color [lindex $color $cpt] -linewidth 0]
         incr cpt
         if { $cpt >= [llength $color] } {
            set cpt 0
         }
      }

   }



   #----------------------------------------------------------------------------
   ## Affiche un graphe representant les magnitudes differentielles des objets
   #  sciences. Les moyennes des magnitudes sont les magnitudes absolues
   #  \param void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::graph_science_mag_popup {  } {

      set ::bdi_gui_cdl::graph_science ""
      foreach select [$::bdi_gui_cdl::data_science curselection] {
         set ids [lindex [$::bdi_gui_cdl::data_science get $select] 0]
         set name [lindex [$::bdi_gui_cdl::data_science get $select] 1]
         lappend ::bdi_gui_cdl::graph_science [list $ids $name]
      }
      ::bdi_gui_cdl::graph_science_mag_popup_exec
   }

   proc ::bdi_gui_cdl::graph_science_mag_popup_exec {  } {

      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
      ::plotxy::title "Courbe de lumiere des objets sciences\n Magnitudes absolues" 
      ::plotxy::xlabel "Time (jd)" 
      ::plotxy::ylabel "Mag" 
      ::plotxy::ydir reverse
      
      array unset x  
      array unset y
      set colors [list blue red green yellow grey black ]
      set cpt 0
      foreach select $::bdi_gui_cdl::graph_science {
         set ids   [lindex $select 0]
         set name  [lindex $select 1]
         set color [lindex $colors $cpt]
         gren_info "Graph $name color : $color\n"
         incr cpt
         if { $cpt >= [llength $colors] } {
            set cpt 0
         }

         for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {
            if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)]} {continue}
            lappend x($ids)  $::bdi_tools_cdl::idcata_to_jdc($idcata)
            lappend y($ids)  $::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)
            if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,err_mag)]} {
               lappend by($ids) 0
            } else {
               lappend by($ids) $::bdi_tools_cdl::table_science_mag($ids,$idcata,err_mag)
            }
            #gren_info "($ids) ($x($ids)) ($y($ids)) \n"
         }

         set h [::plotxy::plot $x($ids) $y($ids) ro. 1.5 [list -ybars $by($ids)] ]
         plotxy::sethandler $h [list -color $color -linewidth 0]

      }
      
   }



   #----------------------------------------------------------------------------
   ## Affiche un graphe representant les magnitudes differentielles des objets
   #  sciences. Les moyennes des magnitudes sont centrees sur zero
   #  \param void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::graph_science_mag {  } {

      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
      ::plotxy::title "Courbe de lumiere des objets sciences\n Magnitudes centrees sur zero" 
      ::plotxy::xlabel "Time (jd)" 
      ::plotxy::ylabel "Diff Mag" 

      array unset x  
      array unset y
      set colors [list blue red green yellow grey black ]
      set cpt 0


      set ids 0
      foreach {name o} [array get ::bdi_tools_cdl::table_noms] {
         incr ids
         if {$o != 2} {continue}

         set color [lindex $colors $cpt]
         gren_info "Graph $name color : $color\n"
         incr cpt
         if { $cpt >= [llength $colors] } {
            set cpt 0
         }

         for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {
            if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)]} {continue}
            lappend x($ids)  $::bdi_tools_cdl::idcata_to_jdc($idcata)
            lappend y($ids)  [expr $::bdi_tools_cdl::table_science_mag($ids,$idcata,mag) - [lindex $::bdi_tools_cdl::table_data_source($name) 4] ]
         }

         set h [::plotxy::plot $x($ids) $y($ids) .]
         plotxy::sethandler $h [list -color $color -linewidth 0]

      }


   }


   #----------------------------------------------------------------------------
   ## Supprime partiellement un point de mesure et le rejete pour le rapport
   #  Mais les points supprimes ne le sont pas dans les fichiers cata
   #  \param void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::unset_science_in_graph {  } {

      if {[::plotxy::figure] == 0 } {
         gren_erreur "Pas de graphe actif\n"
         return
      }

      set err [ catch {set rect [::plotxy::get_selected_region]} msg]
      if {$err} {
         return
      }
      set x1 [lindex $rect 0]
      set x2 [lindex $rect 2]
      set y1 [lindex $rect 1]
      set y2 [lindex $rect 3]

      if {$x1>$x2} {
         set t $x1
         set x1 $x2
         set x2 $t
      }
      if {$y1>$y2} {
         set t $y1
         set y1 $y2
         set y2 $t
      }
      
#      gren_info "Crop Zone = $x1 : $x2 / $y1 : $y2\n"

      set ids 0
      foreach {name o} [array get ::bdi_tools_cdl::table_noms] {
         incr ids
         if {$o != 2} {continue}
         for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {
            if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)]} {continue}
            set x  $::bdi_tools_cdl::idcata_to_jdc($idcata)
            set y  [expr $::bdi_tools_cdl::table_science_mag($ids,$idcata,mag) - [lindex $::bdi_tools_cdl::table_data_source($name) 4] ]
            
            if {$x >= $x1 && $x < $x2 && $y > $y1 && $y < $y2 } {
               unset ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)
               gren_info "Suppression idcata = $idcata, midepoch = [mc_date2iso8601 $::bdi_tools_cdl::table_jdmidexpo($idcata)] name=$name \n"
            }
         }

      }

      ::bdi_gui_cdl::graph_science_mag
   }


   #----------------------------------------------------------------------------
   ## Affiche une fenetre representant les donnees d'une source
   #  sur l'ensemble des images
   #  \param void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::table_popup { onglet } {

      if {$onglet == "ref" } {
         if {[llength [$::bdi_gui_cdl::data_reference curselection]]!=1} {
            tk_messageBox -message "Veuillez selectionner 1 source" -type ok
            return
         }
         set select [$::bdi_gui_cdl::data_reference curselection]
         set name [lindex [$::bdi_gui_cdl::data_reference get $select] 1]
      }
   
      if {$onglet == "sci" } {
         if {[llength [$::bdi_gui_cdl::data_science curselection]]!=1} {
            tk_messageBox -message "Veuillez selectionner 1 source" -type ok
            return
         }
         set select [$::bdi_gui_cdl::data_science curselection]
         set name [lindex [$::bdi_gui_cdl::data_science get $select] 1]
      }

      set ::bdi_gui_cdl::fentable .photometry_table
      if { [winfo exists $::bdi_gui_cdl::fentable] } {
         destroy $::bdi_gui_cdl::fentable
      }
      toplevel $::bdi_gui_cdl::fentable -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::bdi_gui_cdl::fentable ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::bdi_gui_cdl::fentable ] "+" ] 2 ]
      wm geometry $::bdi_gui_cdl::fentable 1000x600+[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::bdi_gui_cdl::fentable 1 1
      wm title $::bdi_gui_cdl::fentable $name
      wm protocol $::bdi_gui_cdl::fentable WM_DELETE_WINDOW "destroy $::bdi_gui_cdl::fentable"

      set frm $::bdi_gui_cdl::fentable.appli
      #--- Cree un frame general
      frame $frm  -cursor arrow -relief groove
      pack $frm -in $::bdi_gui_cdl::fentable -anchor s -side top -expand yes -fill both -padx 10 -pady 5

            set cols [list 0 "Ids"        left  \
                           0 "idcata"     left  \
                           0 "date-obs"   left  \
                           0 "flux"       right \
                           0 "err_flux"   right \
                           0 "mag"        right \
                           0 "err_mag"    right \
                           0 "pixmax"     right \
                           0 "sky"        right \
                           0 "snint"      right \
                           0 "fwhm"       right \
                           0 "radius"     right \
                           0 "err_psf"    right \
                           0 "psf_method" right \
                           0 "globale"    right \
                     ]
         
            set ::bdi_gui_cdl::data_source $frm.table
            tablelist::tablelist $::bdi_gui_cdl::data_source \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $frm.hsb set ] \
              -yscrollcommand [ list $frm.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1
   
            # Scrollbar
            scrollbar $frm.hsb -orient horizontal -command [list $::bdi_gui_cdl::data_source xview]
            pack $frm.hsb -in $frm -side bottom -fill x
            scrollbar $frm.vsb -orient vertical -command [list $::bdi_gui_cdl::data_source yview]
            pack $frm.vsb -in $frm -side right -fill y 

            # Pack la Table
            pack $::bdi_gui_cdl::data_source -in $frm -expand yes -fill both

            # Popup
            menu $frm.popupTbl -title "Actions"

               $frm.popupTbl add command -label "Voir l'objet dans l'image" \
                   -command "::bdi_gui_cdl::table_voir" 
               $frm.popupTbl add command -label "Selection par le graphe" \
                   -command "::bdi_gui_cdl::table_select_from_graph $name" 
               $frm.popupTbl add command -label "Mesurer Manuel" \
                   -command "::bdi_gui_cdl::table_mesure_manuel" 
               $frm.popupTbl add command -label "Mesurer Auto" \
                   -command "::bdi_gui_cdl::table_mesure_auto" 
               $frm.popupTbl add command -label "Rejeter" \
                   -command "::bdi_gui_cdl::table_rejet" 

            # Binding
            # bind $::bdi_gui_cdl::data_source <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_data_source %W ]
            bind [$::bdi_gui_cdl::data_source bodypath] <ButtonPress-3> [ list tk_popup $frm.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
            #    Ascii
            foreach ncol [list "date-obs" "err_psf" "psf_method" "globale"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::data_source columnconfigure $pcol -sortmode ascii
            }
            #    Reel
            foreach ncol [list "Ids" "idcata" "flux" "err_flux" "mag" "err_mag" "pixmax" "sky" \
                               "snint" "fwhm" "radius" ] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::data_source columnconfigure $pcol -sortmode real
            }
            
      ::bdi_gui_cdl::table_popup_view 
   }

   proc ::bdi_gui_cdl::table_popup_view {  } {
   
      set name [wm title $::bdi_gui_cdl::fentable]
      $::bdi_gui_cdl::data_source delete 0 end

      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {
         if {[info exists ::bdi_tools_cdl::table_othf($name,$idcata,othf)]} {
            set othf $::bdi_tools_cdl::table_othf($name,$idcata,othf)
            set ids [expr $::bdi_tools_cdl::table_star_ids($name,$idcata) +1]
            set dateobs $::bdi_tools_cdl::table_date($idcata)
            set flux [::bdi_tools_psf::get_val othf "flux"]
            set err_flux [::bdi_tools_psf::get_val othf "err_flux"]
            set mag [::bdi_tools_psf::get_val othf "mag"]
            set err_mag [::bdi_tools_psf::get_val othf "err_mag"]
            set pixmax [::bdi_tools_psf::get_val othf "pixmax"]
            set sky [::bdi_tools_psf::get_val othf "sky"]
            set snint [::bdi_tools_psf::get_val othf "snint"]
            set fwhm [::bdi_tools_psf::get_val othf "fwhm"]
            set radius [::bdi_tools_psf::get_val othf "radius"]
            set err_psf [::bdi_tools_psf::get_val othf "err_psf"]
            set psf_method [::bdi_tools_psf::get_val othf "psf_method"]
            set globale [::bdi_tools_psf::get_val othf "globale"]

            if {![string is double $flux]||$flux==""} {set flux -1}
            if {![string is double $err_flux]||$err_flux==""} {set err_flux -1}
            if {![string is double $mag]||$mag==""} {set mag -1}
            if {![string is double $err_mag]||$err_mag==""} {set err_mag -1}
            if {![string is double $pixmax]||$pixmax==""} {set pixmax -1}
            if {![string is double $sky]||$sky==""} {set sky -1}
            if {![string is double $snint]||$snint==""} {set snint -1}
            if {![string is double $fwhm]||$fwhm==""} {set fwhm -1}
            if {![string is double $radius]||$radius==""} {set radius -1}
            $::bdi_gui_cdl::data_source insert end [list $ids $idcata $dateobs $flux \
                $err_flux $mag $err_mag $pixmax $sky $snint $fwhm $radius $err_psf \
                $psf_method $globale]
         }
      }
   }

   #----------------------------------------------------------------------------
   ## Affiche un rond dans l'image de la source a la date selectionnee
   #  \param void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::table_voir {  } {

      set color red
      set width 2
         
      if {[llength [$::bdi_gui_cdl::data_source curselection]]!=1} {
         tk_messageBox -message "Veuillez selectionner 1 date" -type ok
         return
      }
      set select [$::bdi_gui_cdl::data_source curselection]
      set ids [lindex [$::bdi_gui_cdl::data_source get $select] 0]
      set idcata [lindex [$::bdi_gui_cdl::data_source get $select] 1]

      set ::cata_gestion_gui::directaccess $idcata
      ::cata_gestion_gui::charge_image_directaccess
      set ids [expr $ids -1]
      set s [lindex  $::tools_cata::current_listsources 1 $ids] 
      set xy [::bdi_tools_psf::get_xy s]
      set radec [buf$::audace(bufNo) xy2radec [list [lindex $xy 0] [lindex $xy 1] ]]

      affich_un_rond [lindex $radec 0] [lindex $radec 1] $color $width
      
   }
   #----------------------------------------------------------------------------
   ## selectionne dans la table les lignes qui ont ete selectionnee dans le graphe
   #  \param void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::table_select_from_graph { name } {

      if {[::plotxy::figure] == 0 } {
         gren_erreur "Pas de graphe actif\n"
         return
      }

      set err [ catch {set rect [::plotxy::get_selected_region]} msg]
      if {$err} {
         return
      }
      set x1 [lindex $rect 0]
      set x2 [lindex $rect 2]
      set y1 [lindex $rect 1]
      set y2 [lindex $rect 3]

      if {$x1>$x2} {
         set t $x1
         set x1 $x2
         set x2 $t
      }
      if {$y1>$y2} {
         set t $y1
         set y1 $y2
         set y2 $t
      }
      set ids []
      
      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {
         if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)]} {continue}
         set x  $::bdi_tools_cdl::idcata_to_jdc($idcata)
         set y  [expr $::bdi_tools_cdl::table_science_mag($ids,$idcata,mag) - [lindex $::bdi_tools_cdl::table_data_source($name) 4] ]
         
         if {$x >= $x1 && $x < $x2 && $y > $y1 && $y < $y2 } {
            #unset ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)
            #gren_info "Suppression idcata = $idcata, midepoch = [mc_date2iso8601 $::bdi_tools_cdl::table_jdmidexpo($idcata)] name=$name \n"
         }
      }

   }

   #----------------------------------------------------------------------------
   ## Effectue une mesure de photocentre manuelle sur la source 
   # aux dates/images selectionnees
   #  \param void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::table_mesure_manuel {  } {

      foreach select [$::bdi_gui_cdl::data_source curselection] {
         set ids [lindex [$::bdi_gui_cdl::data_source get $select] 0]
         set idcata [lindex [$::bdi_gui_cdl::data_source get $select] 1]
         lappend worklist [list $idcata $ids]
      }
      set ::bdi_gui_gestion_source::variable_cloture 1

      ::bdi_gui_gestion_source::run $worklist
      
      vwait ::bdi_gui_gestion_source::variable_cloture
      
      ::bdi_tools_cdl::charge_from_gestion
      ::bdi_gui_cdl::calcule_tout
      if {[winfo exists $::bdi_gui_cdl::fentable]} {
         ::bdi_gui_cdl::table_popup_view
      }
   }
   
   #----------------------------------------------------------------------------
   ## Effectue une mesure de photocentre automatique sur la source 
   # aux dates/images selectionnees
   #  \param void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::table_mesure_auto {  } {

      global bddconf

      set ::cata_gestion_gui::variable_cloture 1

      ::cata_gestion_gui::psf_auto "popup_photom_table"
      
      vwait ::cata_gestion_gui::variable_cloture
      
      # sauvegarde les fichiers dans la base
      foreach id_current_image $::cata_gestion_gui::worklist(list_id) {
         set current_image [lindex $::tools_cata::img_list $id_current_image]
         # Tabkey
         set tabkey [::bddimages_liste::lget $current_image "tabkey"]
         # Liste des sources
         set listsources $::gui_cata::cata_list($id_current_image)
         # Noms du fichier cata
         set imgfilename [::bddimages_liste::lget $current_image filename]
         set imgdirfilename [::bddimages_liste::lget $current_image dirfilename]
         set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
         set cataxml "${f}_cata.xml"

         ::tools_cata::save_cata $listsources $tabkey $cataxml
         
      }

      ::bdi_tools_cdl::charge_from_gestion
      ::bdi_gui_cdl::calcule_tout
      
      if {[winfo exists $::bdi_gui_cdl::fentable]} {
         ::bdi_gui_cdl::table_popup_view
      }
   }
   
   #----------------------------------------------------------------------------
   ## supprime le flag de la source
   # aux dates/images selectionnees
   #  \param void
   #----------------------------------------------------------------------------
   proc ::bdi_gui_cdl::table_rejet {  } {

   }
