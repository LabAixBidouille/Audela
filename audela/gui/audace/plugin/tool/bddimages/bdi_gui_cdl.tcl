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
   variable dataline ; # table des donnees des etoiles de reference
   
}


   #----------------------------------------------------------------------------
   ## Initialisation des variables de namespace
   #  \details   Si la variable n'existe pas alors on va chercher
   #             dans la variable globale \c conf
   proc ::bdi_gui_cdl::inittoconf {  } {
      
      
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







   proc ::bdi_gui_cdl::cmdButton1Click_starstar { w args } {

   }


   proc ::bdi_gui_cdl::cmdButton1Click_dataline { w args } {

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

   #----------------------------------------------------------------------------
   ## Creation de la boite de dialogue.
   proc ::bdi_gui_cdl::create_dialog { } {

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
            set f_dataline [frame $onglets.nb.f_dataline]
            set f_starstar [frame $onglets.nb.f_starstar]
            set f_classif  [frame $onglets.nb.f_classif]
            set f_timeline [frame $onglets.nb.f_timeline]

            $onglets.nb add $f_dataline -text "References"
            $onglets.nb add $f_starstar -text "Variations"
            $onglets.nb add $f_classif  -text "Classification"
            $onglets.nb add $f_timeline -text "Timeline"

            #$onglets.nb select $f_dataline
            ttk::notebook::enableTraversal $onglets.nb

         # References
         set results [frame $f_dataline.dataline  -borderwidth 1 -relief groove]
         pack $results -in $f_dataline -expand yes -fill both
            
            set cols [list 0 "Id"       left  \
                           0 "Name"    left  \
                           0 "Nb img"  right \
                           0 "Moy Mag" right \
                           0 "StDev Mag" right \
                     ]
            # Table
            set ::bdi_gui_cdl::dataline $results.table
            tablelist::tablelist $::bdi_gui_cdl::dataline \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $results.hsb set ] \
              -yscrollcommand [ list $results.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1
    
            # Scrollbar
            scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::dataline xview]
            pack $results.hsb -in $results -side bottom -fill x
            scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::dataline yview]
            pack $results.vsb -in $results -side right -fill y 

            # Pack la Table
            pack $::bdi_gui_cdl::dataline -in $results -expand yes -fill both

            # Popup
            menu $results.popupTbl -title "Actions"

               $results.popupTbl add command -label "Voir l'objet dans une image" \
                   -command "" -state disabled
               $results.popupTbl add command -label "Supprimer" \
                   -command "::bdi_gui_cdl::unset_dataline" 

            # Binding
            bind $::bdi_gui_cdl::dataline <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_dataline %W ]
            bind [$::bdi_gui_cdl::dataline bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
            #    Ascii
            foreach ncol [list "Name"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::dataline columnconfigure $pcol -sortmode ascii
            }
            #    Reel
            foreach ncol [list "Id" "Nb img" "Moy Mag" "StDev Mag"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_gui_cdl::dataline columnconfigure $pcol -sortmode real
            }


         # Variations
         set results [frame $f_starstar.starstar  -borderwidth 1 -relief groove]
         pack $results -in $f_starstar -expand yes -fill both
            


            set onglets [frame $results.onglets]
            pack $onglets -in $results -expand yes -fill both

               pack [ttk::notebook $onglets.nb] -expand yes -fill both 
               set ss_flux_rapport [frame $onglets.nb.ss_flux_rapport]
               set ss_flux_stdev   [frame $onglets.nb.ss_flux_stdev  ]
               set ss_mag_stedv    [frame $onglets.nb.ss_mag_stedv   ]
               set ss_nbmes        [frame $onglets.nb.ss_nbmes       ]

               $onglets.nb add $ss_flux_rapport -text "Rapport Flux"
               $onglets.nb add $ss_flux_stdev   -text "Flux stdev"
               $onglets.nb add $ss_mag_stedv    -text "Mag stdev"
               $onglets.nb add $ss_nbmes        -text "Nb mesure"

               $onglets.nb select $ss_flux_rapport
               ttk::notebook::enableTraversal $onglets.nb



               # Rapport de flux
               set results [frame $ss_flux_rapport.frm  -borderwidth 1 -relief groove]
               pack $results -in $ss_flux_rapport -expand yes -fill both

                  set cols [list 0 " " left ]
                  # Table
                  set ::bdi_gui_cdl::ss_flux_rapport $results.table
                  tablelist::tablelist $::bdi_gui_cdl::ss_flux_rapport \
                    -columns $cols \
                    -labelcommand tablelist::sortByColumn \
                    -xscrollcommand [ list $results.hsb set ] \
                    -yscrollcommand [ list $results.vsb set ] \
                    -selectmode extended \
                    -activestyle none \
                    -stripebackground "#e0e8f0" \
                    -showseparators 1

                  # Scrollbar
                  scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::ss_flux_rapport xview]
                  pack $results.hsb -in $results -side bottom -fill x
                  scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::ss_flux_rapport yview]
                  pack $results.vsb -in $results -side right -fill y 

                  # Pack la Table
                  pack $::bdi_gui_cdl::ss_flux_rapport -in $results -expand yes -fill both

                  # Popup
                  menu $results.popupTbl -title "Actions"

                     $results.popupTbl add command -label "Voir l'objet dans une image" \
                         -command "" -state disabled
                     $results.popupTbl add command -label "Supprimer" \
                         -command "::bdi_gui_cdl::unset_starstar $::bdi_gui_cdl::ss_flux_rapport" 


                  # Binding
                  bind $::bdi_gui_cdl::ss_flux_rapport <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_starstar %W ]
                  bind [$::bdi_gui_cdl::ss_flux_rapport bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]



               # Mag stdev
               set results [frame $ss_mag_stedv.frm  -borderwidth 1 -relief groove]
               pack $results -in $ss_mag_stedv -expand yes -fill both

                  set cols [list 0 " " left ]
                  # Table
                  set ::bdi_gui_cdl::ss_mag_stedv $results.table
                  tablelist::tablelist $::bdi_gui_cdl::ss_mag_stedv \
                    -columns $cols \
                    -labelcommand tablelist::sortByColumn \
                    -xscrollcommand [ list $results.hsb set ] \
                    -yscrollcommand [ list $results.vsb set ] \
                    -selectmode extended \
                    -activestyle none \
                    -stripebackground "#e0e8f0" \
                    -showseparators 1

                  # Scrollbar
                  scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::ss_mag_stedv xview]
                  pack $results.hsb -in $results -side bottom -fill x
                  scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::ss_mag_stedv yview]
                  pack $results.vsb -in $results -side right -fill y 

                  # Pack la Table
                  pack $::bdi_gui_cdl::ss_mag_stedv -in $results -expand yes -fill both

                  # Popup
                  menu $results.popupTbl -title "Actions"

                     $results.popupTbl add command -label "Voir l'objet dans une image" \
                         -command "" -state disabled
                     $results.popupTbl add command -label "Supprimer" \
                         -command "::bdi_gui_cdl::unset_starstar $::bdi_gui_cdl::ss_mag_stedv" 


                  # Binding
                  bind $::bdi_gui_cdl::ss_mag_stedv <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_starstar %W ]
                  bind [$::bdi_gui_cdl::ss_mag_stedv bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]



               # Nb mesure
               set results [frame $ss_nbmes.frm  -borderwidth 1 -relief groove]
               pack $results -in $ss_nbmes -expand yes -fill both

                  set cols [list 0 " " left ]
                  # Table
                  set ::bdi_gui_cdl::ss_nbmes $results.table
                  tablelist::tablelist $::bdi_gui_cdl::ss_nbmes \
                    -columns $cols \
                    -labelcommand tablelist::sortByColumn \
                    -xscrollcommand [ list $results.hsb set ] \
                    -yscrollcommand [ list $results.vsb set ] \
                    -selectmode extended \
                    -activestyle none \
                    -stripebackground "#e0e8f0" \
                    -showseparators 1

                  # Scrollbar
                  scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::ss_nbmes xview]
                  pack $results.hsb -in $results -side bottom -fill x
                  scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::ss_nbmes yview]
                  pack $results.vsb -in $results -side right -fill y 

                  # Pack la Table
                  pack $::bdi_gui_cdl::ss_nbmes -in $results -expand yes -fill both

                  # Popup
                  menu $results.popupTbl -title "Actions"

                     $results.popupTbl add command -label "Voir l'objet dans une image" \
                         -command "" -state disabled
                     $results.popupTbl add command -label "Supprimer" \
                         -command "::bdi_gui_cdl::unset_starstar $::bdi_gui_cdl::ss_nbmes" 


                  # Binding
                  bind $::bdi_gui_cdl::ss_nbmes <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_starstar %W ]
                  bind [$::bdi_gui_cdl::ss_nbmes bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]




         # Classification
         set results [frame $f_classif.classif  -borderwidth 1 -relief groove]
         pack $results -in $f_classif -expand yes -fill both
            
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
            pack $::bdi_gui_cdl::classif -in $results -expand yes -fill both

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

              button $actions.ressource -text "Ressource" -borderwidth 2 -takefocus 1 \
                 -command "::bddimages::ressource"
              button $actions.relance -text "Relance" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::relance"
              button $actions.clean -text "Clean" -borderwidth 2 -takefocus 1 \
                 -command "console::clear"

              button $actions.chargexml -text "Charge XML" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::charge_cata_xml"
              button $actions.stopxml -text "STOP XML" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::stop_charge_cata_xml"
              button $actions.chargelist -text "Charge LIST" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_tools_cdl::charge_cata_list"
              button $actions.voir -text "Voir" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::affiche_data"

              button $actions.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
                 -command "::bdi_gui_cdl::fermer"
              button $actions.aide -text "Aide" -borderwidth 2 -takefocus 1 \
                 -command "" -state disabled
              
              grid $actions.ressource -row 0 -column 0 -sticky news
              grid $actions.relance   -row 0 -column 1 -sticky news
              grid $actions.clean     -row 0 -column 2 -sticky news

              grid $actions.chargexml  -row 1 -column 0 -sticky news
              grid $actions.stopxml    -row 1 -column 1 -sticky news
              grid $actions.chargelist -row 1 -column 2 -sticky news
              grid $actions.voir       -row 1 -column 3 -sticky news

              grid $actions.aide      -row 2 -column 0 -sticky news
              grid $actions.fermer    -row 2 -column 1 -sticky news

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

      # Onglet References

      $::bdi_gui_cdl::dataline delete 0 end

      set ids 0
      foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
         incr ids
         if {$y == 0} {continue}
         $::bdi_gui_cdl::dataline insert end $::bdi_tools_cdl::table_dataline($name)
         lappend ::bdi_tools_cdl::list_of_stars $ids
      }

      # Onglet variation

      $::bdi_gui_cdl::ss_flux_rapport delete 0 end
      $::bdi_gui_cdl::ss_mag_stedv    delete 0 end
      $::bdi_gui_cdl::ss_nbmes        delete 0 end

      catch { $::bdi_gui_cdl::ss_flux_rapport deletecolumns 0 end } 
      catch { $::bdi_gui_cdl::ss_mag_stedv    deletecolumns 0 end } 
      catch { $::bdi_gui_cdl::ss_nbmes        deletecolumns 0 end } 

      $::bdi_gui_cdl::ss_flux_rapport insertcolumns end 0 "" left
      $::bdi_gui_cdl::ss_mag_stedv    insertcolumns end 0 "" left
      $::bdi_gui_cdl::ss_mag_stedv    insertcolumns end 0 "sum" center
      $::bdi_gui_cdl::ss_nbmes        insertcolumns end 0 "" left

      set pcol 0
      foreach ids $::bdi_tools_cdl::list_of_stars {
         $::bdi_gui_cdl::ss_flux_rapport insertcolumns end 0 $ids right
         $::bdi_gui_cdl::ss_flux_rapport columnconfigure $pcol -sortmode real
         $::bdi_gui_cdl::ss_mag_stedv    insertcolumns end 0 $ids right
         $::bdi_gui_cdl::ss_mag_stedv    columnconfigure $pcol -sortmode real
         $::bdi_gui_cdl::ss_nbmes        insertcolumns end 0 $ids right
         $::bdi_gui_cdl::ss_nbmes        columnconfigure $pcol -sortmode real
         incr pcol
      }

      set magmax -1
      set col 0
      foreach ids1 $::bdi_tools_cdl::list_of_stars { 
         set line_flux_rapport $ids1
         set line_mag_stedv [list $ids1 "-"]
         set line_nbmes $ids1
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
            lappend line_flux_rapport [format "%.3f" $::bdi_tools_cdl::table_variations($ids1,$ids2,flux,mean)]
            lappend line_mag_stedv    [format "%.3f" $mag]
            lappend line_nbmes        [format "%d" $::bdi_tools_cdl::table_variations($ids1,$ids2,flux,nbmes)]
            incr row
         }
         set line_mag_stedv [lreplace $line_mag_stedv 1 1 [format "%.3f" $sum]]
         $::bdi_gui_cdl::ss_flux_rapport insert end $line_flux_rapport
         $::bdi_gui_cdl::ss_mag_stedv    insert end $line_mag_stedv
         $::bdi_gui_cdl::ss_nbmes        insert end $line_nbmes
         incr col
      }
 
      $::bdi_gui_cdl::ss_mag_stedv cellconfigure $colmax,$rowmax -background red
      set pcol 0
      foreach ids1 $::bdi_tools_cdl::list_of_stars {
         $::bdi_gui_cdl::ss_flux_rapport cellconfigure $pcol,[expr $pcol+1] -background darkgrey
         $::bdi_gui_cdl::ss_mag_stedv    cellconfigure $pcol,[expr $pcol+2] -background darkgrey
         $::bdi_gui_cdl::ss_mag_stedv    cellconfigure $pcol,1 -background ivory
         $::bdi_gui_cdl::ss_nbmes        cellconfigure $pcol,[expr $pcol+1] -background darkgrey
         incr pcol
      }


      # Onglet Classification
      $::bdi_gui_cdl::classif delete 0 end
      set ids 0
      foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
         incr ids
         if {$y == 0} {continue}
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


      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Affichage complet en $tt sec \n"

      return

   }





   proc ::bdi_gui_cdl::unset_dataline { } {

      foreach select [$::bdi_gui_cdl::dataline curselection] {
         set name [lindex [$::bdi_gui_cdl::dataline get $select] 1]      
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
