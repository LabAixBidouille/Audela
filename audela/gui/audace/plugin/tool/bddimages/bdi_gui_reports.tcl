## @file bdi_gui_reports.tcl
#  @brief     GUI dediee aux rapports d'analyse
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports.tcl]
#  @endcode

# Mise à jour $Id: bdi_gui_reports.tcl 9215 2013-03-15 15:36:44Z jberthier $

#============================================================
## Declaration du namespace \c bdi_gui_reports .
#  @brief     GUI dediee aux rapports d'analyse
#  @pre       Requiert bdi_tools_xml 1.0 et bddimagesAdmin 1.0
#  @warning   Pour developpeur seulement
#
namespace eval bdi_gui_reports {

}


   #------------------------------------------------------------
   ## Creation de la GUI de gestion des configurations
   #  @return void
   #
   proc ::bdi_gui_reports::inittoconf {  } {


   }

   #------------------------------------------------------------
   ## Fermeture et destruction de la GUI
   #  @return void
   #
   proc ::bdi_gui_reports::fermer { } {

      #::bdi_gui_reports::closetoconf
      ::bdi_gui_reports::recup_position
      destroy $::bdi_gui_reports::fen

   }

   #------------------------------------------------------------
   ## Recuperation de la position d'affichage de la GUI
   #  @return void
   #
   proc ::bdi_gui_reports::recup_position { } {

      global conf bddconf

      set bddconf(geometry_reports) [ wm geometry $::bdi_gui_reports::fen ]
      set conf(bddimages,geometry_reports) $bddconf(geometry_reports)

   }

   #----------------------------------------------------------------------------
   ## Relance l outil
   # Les variables utilisees sont affectees a la variable globale
   # \c conf
   proc ::bdi_gui_reports::relance {  } {

      ::bddimages::ressource
      ::bdi_gui_reports::fermer
      ::bdi_gui_reports::run

   }


   # On click
   proc ::bdi_gui_reports::cmdButton1Click_data_objects { w args } {
      
      set curselection [$::bdi_tools_reports::data_objects curselection]
      set nb [llength $curselection]
      gren_info "nb select = $nb\n"
      foreach select $curselection {
         set obj [lindex [$::bdi_tools_reports::data_objects get $select] 0]
         gren_info "Info sur l objet : $obj\n"      
      }

   }
   proc ::bdi_gui_reports::cmdButton1Click_data_reports { w args } {

   }

   #------------------------------------------------------------
   ## Lancement de la GUI
   #  @return void
   #
   proc ::bdi_gui_reports::run { } {

      global audace caption color
      global conf bddconf 

      set widthlab 30
      set widthentry 30
      set ::bdi_gui_reports::fen .reports
      #--- Initialisation des parametres
      ::bdi_gui_reports::inittoconf

      #--- Geometry
      if { ! [ info exists conf(bddimages,geometry_reports) ] } {
         set conf(bddimages,geometry_reports) "+400+800"
      }
      set bddconf(geometry_reports) $conf(bddimages,geometry_reports)

      #--- Declare la GUI
      if { [ winfo exists $::bdi_gui_reports::fen ] } {
         wm withdraw $::bdi_gui_reports::fen
         wm deiconify $::bdi_gui_reports::fen
         focus $::bdi_gui_reports::fen.buttons.but_fermer
         return
      }

      #--- GUI
      toplevel $::bdi_gui_reports::fen -class Toplevel
      wm geometry $::bdi_gui_reports::fen $bddconf(geometry_reports)
      wm resizable $::bdi_gui_reports::fen 1 1
      wm title $::bdi_gui_reports::fen $caption(bddimages_go,reports)
      wm protocol $::bdi_gui_reports::fen WM_DELETE_WINDOW { ::bdi_gui_reports::fermer }

      set frm $::bdi_gui_reports::fen.appli
      frame $frm  -cursor arrow -relief groove
      pack $frm -in $::bdi_gui_reports::fen -anchor s -side top -expand yes -fill both -padx 10 -pady 5



     set objects [frame $frm.objects  -borderwidth 1 -relief groove]
     pack $objects -in $frm -expand yes -fill both

            set cols [list 0 "Name"    left  \
                           0 "Astrom"  right \
                           0 "Photom"  right \
                           0 "MPC"     right \
                     ]

            # Table
            set ::bdi_tools_reports::data_objects $objects.table
            tablelist::tablelist $::bdi_tools_reports::data_objects \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $objects.hsb set ] \
              -yscrollcommand [ list $objects.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1

            # Scrollbar
            scrollbar $objects.hsb -orient horizontal -command [list $::bdi_tools_reports::data_objects xview]
            pack $objects.hsb -in $objects -side bottom -fill x
            scrollbar $objects.vsb -orient vertical -command [list $::bdi_tools_reports::data_objects yview]
            pack $objects.vsb -in $objects -side right -fill y 

            # Pack la Table
            pack $::bdi_tools_reports::data_objects -in $objects -expand yes -fill both

            # Binding
            bind $::bdi_tools_reports::data_objects <<ListboxSelect>> [ list ::bdi_gui_reports::cmdButton1Click_data_objects %W ]
            bind [$::bdi_tools_reports::data_objects bodypath] <ButtonPress-3> [ list tk_popup $objects.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
            #    Ascii
            foreach ncol [list "Name"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_tools_reports::data_objects columnconfigure $pcol -sortmode ascii
            }
            #    Reel
            foreach ncol [list "Astrom" "Photom" "MPC"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_tools_reports::data_objects columnconfigure $pcol -sortmode ascii
            }

     set reports [frame $frm.reports  -borderwidth 1 -relief groove]
     pack $reports -in $frm -expand yes -fill both

            set cols [list 0 "Date"        left  \
                           0 "Batch"       right \
                           0 "Astrom TXT"  right \
                           0 "Astrom XML"  right \
                           0 "Astrom MPC"  right \
                           0 "Photom TXT"  right \
                           0 "Photom XML"  right \
                     ]

            # Table
            set ::bdi_tools_reports::data_reports $reports.table
            tablelist::tablelist $::bdi_tools_reports::data_reports \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $reports.hsb set ] \
              -yscrollcommand [ list $reports.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1

            # Scrollbar
            scrollbar $reports.hsb -orient horizontal -command [list $::bdi_tools_reports::data_reports xview]
            pack $reports.hsb -in $reports -side bottom -fill x
            scrollbar $reports.vsb -orient vertical -command [list $::bdi_tools_reports::data_reports yview]
            pack $reports.vsb -in $reports -side right -fill y 

            # Pack la Table
            pack $::bdi_tools_reports::data_reports -in $reports -expand yes -fill both

            # Binding
            bind $::bdi_tools_reports::data_reports <<ListboxSelect>> [ list ::bdi_gui_reports::cmdButton1Click_data_reports %W ]
            bind [$::bdi_tools_reports::data_reports bodypath] <ButtonPress-3> [ list tk_popup $reports.popupTbl %X %Y ]

            # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
            #    Ascii
            foreach ncol [list "Date" "Batch"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_tools_reports::data_reports columnconfigure $pcol -sortmode ascii
            }
            #    Reel
            foreach ncol [list "Astrom TXT" "Astrom XML" "Astrom MPC" "Photom TXT" "Photom XML"] {
               set pcol [expr int ([lsearch $cols $ncol]/3)]
               $::bdi_tools_reports::data_reports columnconfigure $pcol -sortmode ascii
            }


     # Develop
     set actions [frame $frm.actions  -borderwidth 1 -relief groove]
     pack $actions -in $frm -expand no -fill none


          button $actions.ressource -text "Ressource les scripts" -borderwidth 2 -takefocus 1 \
             -command "::bddimages::ressource"
          button $actions.relance -text "Relance la GUI" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_reports::relance"
          button $actions.clean -text "Efface le contenu de la console" -borderwidth 2 -takefocus 1 \
             -command "console::clear"


         grid $actions.ressource $actions.relance $actions.clean -sticky news


     ::bdi_gui_reports::affiche_data

   }



   proc ::bdi_gui_reports::affiche_data { } {

      global bddconf
      
      set tt0 [clock clicks -milliseconds]
      $::bdi_tools_reports::data_objects delete 0 end
      
      gren_info "Analyse du repertoire des Rapports : $bddconf(dirreports)\n"
      set liste [glob $bddconf(dirreports)/*]

      foreach i $liste {
         if {[file type $i]=="directory"} {
            $::bdi_tools_reports::data_objects insert end [file tail $i]
         }      
      }      
      
      # set ::bdi_tools_reports::data_objects
      
      # Fin de visualisation des donnees
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Affichage complet en $tt sec \n"
      
   }

