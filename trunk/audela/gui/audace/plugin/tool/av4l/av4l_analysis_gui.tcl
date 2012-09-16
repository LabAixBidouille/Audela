#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_analysis_gui.tcl
#--------------------------------------------------
#
# Fichier        : av4l_analysis_gui.tcl
# Description    : GUI de l outil Courbe de lumiere
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: av4l_analysis_gui.tcl 7986 2011-12-22 20:15:55Z svaillant $
#

namespace eval ::av4l_analysis_gui {






   proc ::av4l_analysis_gui::reinitialise { } {

      set ::av4l_analysis_gui::raw_filename        ""
      set ::av4l_analysis_gui::raw_filename_short  ""
      set ::av4l_analysis_gui::corr_filename       ""
      set ::av4l_analysis_gui::corr_filename_short ""


      set ::av4l_analysis_tools::raw_status_file   ""
      set ::av4l_analysis_tools::raw_nbframe       ""
      set ::av4l_analysis_tools::raw_duree         ""
      set ::av4l_analysis_tools::raw_fps           ""
      set ::av4l_analysis_tools::raw_date_begin    ""
      set ::av4l_analysis_tools::raw_date_end      ""
      set ::av4l_analysis_gui::raw_integ_offset    ""
      set ::av4l_analysis_gui::raw_integ_nb_img    ""


      set ::av4l_analysis_gui::corr_filename_short   ""
      set ::av4l_analysis_tools::corr_status_file    ""
      set ::av4l_analysis_tools::corr_nbframe        ""
      set ::av4l_analysis_tools::corr_duree          ""
      set ::av4l_analysis_tools::corr_fps            ""
      set ::av4l_analysis_tools::corr_date_begin     ""
      set ::av4l_analysis_tools::corr_date_end       ""
      set ::av4l_analysis_tools::nb_p1  ""
      set ::av4l_analysis_tools::corr_duree_e1    ""
      set ::av4l_analysis_tools::nb_p2  ""
      set ::av4l_analysis_tools::corr_duree_e2    ""
      set ::av4l_analysis_tools::nb_p3  ""
      set ::av4l_analysis_tools::corr_duree_e3    ""
      set ::av4l_analysis_tools::nb_p4  ""
      set ::av4l_analysis_tools::corr_duree_e4    ""
      set ::av4l_analysis_tools::nb_p5  ""
      set ::av4l_analysis_tools::corr_duree_e5    ""
   }






   #
   # Chargement des captions
   #
   proc ::av4l_analysis_gui::init { } {
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions

      set ::av4l_analysis_tools::raw_status_file  ""
      set ::av4l_analysis_tools::raw_nbframe      ""
      set ::av4l_analysis_tools::raw_date_begin   ""
      set ::av4l_analysis_tools::raw_date_end     ""
      set ::av4l_analysis_tools::raw_fps          ""
      set ::av4l_analysis_tools::raw_duree        ""

      set ::av4l_analysis_tools::corr_status_file ""
      set ::av4l_analysis_tools::corr_nbframe     ""
      set ::av4l_analysis_tools::corr_date_begin  ""
      set ::av4l_analysis_tools::corr_date_end    ""
      set ::av4l_analysis_tools::corr_fps         ""
      set ::av4l_analysis_tools::corr_duree       ""

   }







   #
   # Initialisation des variables de configuration
   #
   proc ::av4l_analysis_gui::initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,messages) ] }                           { set ::av4l::parametres(av4l,$visuNo,messages)                           "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,save_file_log) ] }                      { set ::av4l::parametres(av4l,$visuNo,save_file_log)                      "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,alarme_fin_serie) ] }                   { set ::av4l::parametres(av4l,$visuNo,alarme_fin_serie)                   "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier) ] }           { set ::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)           "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,verifier_index_depart) ] }              { set ::av4l::parametres(av4l,$visuNo,verifier_index_depart)              "1" }

   }












   #
   # Charge la configuration dans des variables locales
   #
   proc ::av4l_analysis_gui::confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set ::av4l_analysis_gui::panneau(av4l,$visuNo,messages)                   $::av4l::parametres(av4l,$visuNo,messages)
      set ::av4l_analysis_gui::panneau(av4l,$visuNo,save_file_log)              $::av4l::parametres(av4l,$visuNo,save_file_log)
      set ::av4l_analysis_gui::panneau(av4l,$visuNo,alarme_fin_serie)           $::av4l::parametres(av4l,$visuNo,alarme_fin_serie)
      set ::av4l_analysis_gui::panneau(av4l,$visuNo,verifier_ecraser_fichier)   $::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)
      set ::av4l_analysis_gui::panneau(av4l,$visuNo,verifier_index_depart)      $::av4l::parametres(av4l,$visuNo,verifier_index_depart)


   }















   #
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc ::av4l_analysis_gui::widgetToConf { visuNo } {
      variable parametres
      global panneau

   }















   #
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::av4l_analysis_gui::run { visuNo frm } {

      global audace panneau

      set panneau(av4l,$visuNo,av4l_analysis_gui) $frm

      createdialog $visuNo $frm

   }















   #
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::av4l_analysis_gui::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::av4l::getPluginType ] ] \
         [ ::av4l::getPluginDirectory ] av4l_analysis_gui.htm
   }
















   #
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::av4l_analysis_gui::closeWindow { this visuNo } {

      ::av4l_analysis_gui::widgetToConf $visuNo
      ::plotxy::clf 1
      destroy $this
   }





















   proc ::av4l_analysis_gui::open_raw_file { visuNo frm  } {

      global color

      if {$::av4l_analysis_gui::raw_filename==""||![info exists ::av4l_analysis_gui::raw_filename]} {return}
      
 
      ::console::affiche_resultat "Chargement de la courbe : $::av4l_analysis_gui::raw_filename\n"
      set err [catch {set nb [::av4l_analysis_tools::charge_csv $::av4l_analysis_gui::raw_filename]} msg ]
      if {$err} {
         ::console::affiche_erreur "Erreur de chargement du fichier\n"
         ::console::affiche_erreur "Fichier = $::av4l_analysis_gui::raw_filename\n"
         ::console::affiche_erreur "Err = $err\n"
         ::console::affiche_erreur "Msg = $msg\n"
         return
      }
      set err [catch {::av4l_analysis_tools::filtre_raw_data $nb} msg ]
      if {$err} {
         ::console::affiche_erreur "Erreur de lecture de la courbe de lumiere\n"
         ::console::affiche_erreur "Fichier = $::av4l_analysis_gui::raw_filename\n"
         ::console::affiche_erreur "Err = $err\n"
         ::console::affiche_erreur "Msg = $msg\n"
         return
      }
      
      $::av4l_analysis_tools::raw_status_file_gui configure -fg $color(blue)

      # cree la courbe
      set ::av4l_analysis_gui::x ""
      set ::av4l_analysis_gui::y ""

      for {set i 1} {$i<=$::av4l_analysis_tools::raw_nbframe} {incr i} {
         lappend ::av4l_analysis_gui::x [expr ($::av4l_analysis_tools::cdl($i,jd) - $::av4l_analysis_tools::orig) * 86400.0 ]
         lappend ::av4l_analysis_gui::y $::av4l_analysis_tools::cdl($i,obj_fint)
      }
      
      # affiche la courbe
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::plot $::av4l_analysis_gui::x $::av4l_analysis_gui::y b+
   }
























   proc ::av4l_analysis_gui::select_raw_data { visuNo frm } {

      global audace

      set fenetre [::confVisu::getBase $visuNo]
      set bufNo [ visu$visuNo buf ]
      set ::av4l_analysis_gui::raw_filename [ ::tkutil::box_load_csv $frm $audace(rep_images) $bufNo "1" ]
      set ::av4l_analysis_gui::raw_filename_short [file tail $::av4l_analysis_gui::raw_filename]

   }
















   proc ::av4l_analysis_gui::corr_integ_get_offset { visuNo corr_integ } {

      set err [ catch {set rect [::plotxy::get_selected_region]} msg]
      if {$err} {
         return
      }
      set x1 [lindex $rect 0]
      set y1 [lindex $rect 1]
      set x2 [lindex $rect 2]
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
      
      set cpt 0
      for {set i 1} {$i<=$::av4l_analysis_tools::raw_nbframe} {incr i} {
         set x  [expr ($::av4l_analysis_tools::cdl($i,jd) - $::av4l_analysis_tools::orig) * 86400.0 ]
         set y  $::av4l_analysis_tools::cdl($i,obj_fint)
         if { $x > $x1 && $x < $x2 && $y > $y1 && $y < $y2 } {
            ::console::affiche_resultat "id = $i\n"
            incr cpt
         }
      }
      
      set ::av4l_analysis_gui::raw_integ_offset $cpt
   }









   proc ::av4l_analysis_gui::corr_integ_get_nb_img { visuNo corr_integ } {

      set err [ catch {set rect [::plotxy::get_selected_region]} msg]
      if {$err} {
         return
      }
      set x1 [lindex $rect 0]
      set y1 [lindex $rect 1]
      set x2 [lindex $rect 2]
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
      
      for {set i 1} {$i<=$::av4l_analysis_tools::raw_nbframe} {incr i} {
         set x  [expr ($::av4l_analysis_tools::cdl($i,jd) - $::av4l_analysis_tools::orig) * 86400.0 ]
         set y  $::av4l_analysis_tools::cdl($i,obj_fint)
         if { $x > $x1 && $x < $x2 && $y > $y1 && $y < $y2 } {
            incr cpt
         }
      }
      
      set ::av4l_analysis_gui::raw_integ_nb_img $cpt
   }














   proc ::av4l_analysis_gui::corr_integ_view { } {
     
      if {![info exists ::av4l_analysis_gui::raw_integ_offset]} {return}
      if {![info exists ::av4l_analysis_gui::raw_integ_nb_img]} {return}
      
      ::av4l_analysis_tools::correction_integration $::av4l_analysis_gui::raw_integ_offset $::av4l_analysis_gui::raw_integ_nb_img
      
      # cree la courbe
      set ::av4l_analysis_gui::x ""
      set ::av4l_analysis_gui::y ""

      for {set i 1} {$i<=$::av4l_analysis_tools::raw_nbframe} {incr i} {
         if {![info exists ::av4l_analysis_tools::medianecdl($i,jd)]} {continue}
         lappend ::av4l_analysis_gui::x [expr ($::av4l_analysis_tools::medianecdl($i,jd) - $::av4l_analysis_tools::orig) * 86400.0 ]
         lappend ::av4l_analysis_gui::y $::av4l_analysis_tools::medianecdl($i,obj_fint)
      }

      # affiche la courbe  couleur: rgbk   symbol: +xo* [list -linewidth 4]
      ::plotxy::plot $::av4l_analysis_gui::x $::av4l_analysis_gui::y rx 
      #  http://www-hermes.desy.de/pink/blt.html#Sect6_4

      # cree la courbe
      set ::av4l_analysis_gui::x ""
      set ::av4l_analysis_gui::y ""

      for {set i 1} {$i<=$::av4l_analysis_tools::raw_nbframe} {incr i} {
         if {![info exists ::av4l_analysis_tools::finalcdl($i,jd)]} {continue}
         lappend ::av4l_analysis_gui::x [expr ($::av4l_analysis_tools::finalcdl($i,jd) - $::av4l_analysis_tools::orig) * 86400.0 ]
         lappend ::av4l_analysis_gui::y $::av4l_analysis_tools::finalcdl($i,obj_fint)
      }

      # affiche la courbe  couleur: rgbk   symbol: +xo*
      ::plotxy::plot $::av4l_analysis_gui::x $::av4l_analysis_gui::y go 4



      
   }



   proc ::av4l_analysis_gui::corr_integ_apply { } {

      # affiche la courbe  couleur: rgbk   symbol: +xo*
      ::plotxy::plot $::av4l_analysis_gui::x $::av4l_analysis_gui::y rx

      # cree la courbe
      set ::av4l_analysis_gui::x ""
      set ::av4l_analysis_gui::y ""

      for {set i 1} {$i<=$::av4l_analysis_tools::raw_nbframe} {incr i} {
         if {![info exists ::av4l_analysis_tools::finalcdl($i,jd)]} {continue}
         lappend ::av4l_analysis_gui::x [expr ($::av4l_analysis_tools::finalcdl($i,jd) - $::av4l_analysis_tools::orig) * 86400.0 ]
         lappend ::av4l_analysis_gui::y $::av4l_analysis_tools::finalcdl($i,obj_fint)
      }

      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 

      # affiche la courbe  couleur: rgbk   symbol: +xo*
      ::plotxy::plot $::av4l_analysis_gui::x $::av4l_analysis_gui::y bo 1


   }




   proc ::av4l_analysis_gui::save_corrected_curve { } {


      set file [string range $::av4l_analysis_gui::raw_filename 0 [expr [string last .csv $::av4l_analysis_gui::raw_filename] -1]]
      set ::av4l_analysis_gui::corr_filename "${file}_CORR.csv"
      set ::av4l_analysis_gui::corr_filename_short [file tail $::av4l_analysis_gui::corr_filename]

      ::console::affiche_resultat "Sauvegarde de la courbe : $::av4l_analysis_gui::corr_filename\n"
      
      set err [catch {::av4l_analysis_tools::save_corrected_curve $::av4l_analysis_gui::corr_filename} msg]
      if {$err} {
         ::console::affiche_erreur "Erreur de sauvegarde du fichier\n"
         ::console::affiche_erreur "Fichier = $::av4l_analysis_gui::corr_filename\n"
         ::console::affiche_erreur "Err = $err\n"
         ::console::affiche_erreur "Msg = $msg\n"
         return
      }
      
      ::plotxy::clf 1
      
   }
















   proc ::av4l_analysis_gui::open_corr_file { visuNo frm  } {

      global color

      if {$::av4l_analysis_gui::corr_filename==""||![info exists ::av4l_analysis_gui::corr_filename]} {return}
      
 
      ::console::affiche_resultat "Chargement de la courbe : $::av4l_analysis_gui::corr_filename\n"
      set err [catch {set nb [::av4l_analysis_tools::charge_csv $::av4l_analysis_gui::corr_filename]} msg ]
      if {$err} {
         ::console::affiche_erreur "Erreur de chargement du fichier\n"
         ::console::affiche_erreur "Fichier = $::av4l_analysis_gui::corr_filename\n"
         ::console::affiche_erreur "Err = $err\n"
         ::console::affiche_erreur "Msg = $msg\n"
         return
      }
      set err [catch {::av4l_analysis_tools::filtre_corr_data $nb} msg ]
      if {$err} {
         ::console::affiche_erreur "Erreur de lecture de la courbe de lumiere\n"
         ::console::affiche_erreur "Fichier = $::av4l_analysis_gui::corr_filename\n"
         ::console::affiche_erreur "Err = $err\n"
         ::console::affiche_erreur "Msg = $msg\n"
         return
      }
      
      $::av4l_analysis_tools::corr_status_file_gui configure -fg $color(blue)

      # cree la courbe
      set ::av4l_analysis_gui::x ""
      set ::av4l_analysis_gui::y ""

      for {set i 1} {$i<=$::av4l_analysis_tools::corr_nbframe} {incr i} {
         lappend ::av4l_analysis_gui::x [expr ($::av4l_analysis_tools::cdl($i,jd) - $::av4l_analysis_tools::orig) * 86400.0 ]
         lappend ::av4l_analysis_gui::y $::av4l_analysis_tools::cdl($i,flux)
      }
      
      # affiche la courbe
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::plot $::av4l_analysis_gui::x $::av4l_analysis_gui::y b+
   }



   proc ::av4l_analysis_gui::select_corr_data { visuNo frm } {

      global audace

      set fenetre [::confVisu::getBase $visuNo]
      set bufNo [ visu$visuNo buf ]
      set ::av4l_analysis_gui::corr_filename [ ::tkutil::box_load_csv $frm $audace(rep_images) $bufNo "1" ]
      set ::av4l_analysis_gui::corr_filename_short [file tail $::av4l_analysis_gui::corr_filename]

   }





   proc ::av4l_analysis_gui::select_event { e } {

   
      set err [ catch {set rect [::plotxy::get_selected_region]} msg]
      if {$err} {
         return
      }
      set x1 [lindex $rect 0]
      set x2 [lindex $rect 2]
      
      if {$x1>$x2} {
         set t $x1
         set x1 $x2
         set x2 $t
      }
      
      
      set cpt 0
      for {set i 1} {$i<=$::av4l_analysis_tools::corr_nbframe} {incr i} {
         set x  [expr ($::av4l_analysis_tools::cdl($i,jd) - $::av4l_analysis_tools::orig) * 86400.0 ]
         set y  $::av4l_analysis_tools::cdl($i,flux)
         if { $x > $x1 && $x < $x2 } {
            incr cpt
            set p($cpt,idframe) $x 
            set p($cpt,x) $x 
            set p($cpt,y) $y 
         }
      }
      if {$cpt==0} {return}
      
      if {$e==1} {
         set ::av4l_analysis_tools::corr_duree_e1   [format "%.3f" [expr $p($cpt,x) - $p(1,x)] ]
         set ::av4l_analysis_tools::nb_p1 $cpt
      }
      if {$e==2} {
         set ::av4l_analysis_tools::corr_duree_e2   [format "%.3f"  [expr $p($cpt,x) - $p(1,x)] ]
         set ::av4l_analysis_tools::nb_p2 $cpt
      }
      if {$e==3} {
         set ::av4l_analysis_tools::corr_duree_e3   [format "%.3f"  [expr $p($cpt,x) - $p(1,x)] ]
         set ::av4l_analysis_tools::nb_p3 $cpt
      }
      if {$e==4} {
         set ::av4l_analysis_tools::corr_duree_e4   [format "%.3f"  [expr $p($cpt,x) - $p(1,x)] ]
         set ::av4l_analysis_tools::nb_p4 $cpt
      }
      if {$e==5} {
         set ::av4l_analysis_tools::corr_duree_e5   [format "%.3f"  [expr $p($cpt,x) - $p(1,x)] ]
         set ::av4l_analysis_tools::nb_p5 $cpt
      }

   }














   #
   # Creation de l'interface graphique
   #
   proc ::av4l_analysis_gui::createdialog { visuNo this } {

      package require Img

      global caption panneau av4lconf color audace

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      #--- Creation de la fenetre
      if { [winfo exists $this] } {
         wm withdraw $this
         wm deiconify $this
         focus $this
         return
      }
      toplevel $this -class Toplevel

      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $this +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $this 1 1

      wm protocol $this WM_DELETE_WINDOW "::av4l_analysis_gui::closeWindow $this $visuNo"

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::av4l_analysis_gui::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set frm $this.frm_av4l_analysis_gui


      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -font $av4lconf(font,arial_14_b) \
              -text "Analyse de la Courbe de lumiere"
        pack $frm.titre \
             -in $frm -side top -padx 3 -pady 3

         set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $onglets -in $frm -side top -expand 0 -fill x -padx 10 -pady 5

            pack [ttk::notebook $onglets.nb]
            set f1 [frame $onglets.nb.f1]
            set f2 [frame $onglets.nb.f2]
            set f3 [frame $onglets.nb.f3]
            set f4 [frame $onglets.nb.f4]
            set f5 [frame $onglets.nb.f5]
            set f6 [frame $onglets.nb.f6]
            set f7 [frame $onglets.nb.f7]
            
            $onglets.nb add $f1 -text "Corrections"
            $onglets.nb add $f2 -text "Evenements"
            $onglets.nb add $f3 -text "Parametres"
            $onglets.nb add $f4 -text "Vracs"
            $onglets.nb add $f5 -text "Immersion"
            $onglets.nb add $f6 -text "Emersion"
            $onglets.nb add $f7 -text "Rapport"
            $onglets.nb select $f1
            ttk::notebook::enableTraversal $onglets.nb
        
        



#---


#--- ONGLET : Courbe brute


#---


        #--- Cree un frame pour afficher le contenu de l onglet
        set courbe [frame $f1.frm -borderwidth 0 -cursor arrow -relief groove]
        pack $courbe -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
        

             #--- Cree un frame pour le chargement d'un fichier
             set charge [frame $courbe.charge -borderwidth 0 -cursor arrow -relief groove]
             pack $charge -in $courbe -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Creation du bouton open
                  button $charge.but_open \
                     -text "ouvrir" -borderwidth 2 \
                     -command "::av4l_analysis_gui::open_raw_file $visuNo $f1"
                  pack $charge.but_open \
                     -side left -anchor e \
                     -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

                  #--- Creation du bouton select
                  button $charge.but_select \
                     -text "..." -borderwidth 2 -takefocus 1 \
                     -command "::av4l_analysis_gui::select_raw_data $visuNo $charge"
                  pack $charge.but_select \
                     -side left -anchor e \
                     -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

                  #--- Cree un label pour le chemin de l'AVI
                  entry $charge.csvpath -textvariable ::av4l_analysis_gui::raw_filename_short
                  pack $charge.csvpath -side left -padx 3 -pady 1 -expand true -fill x


             #--- Cree un frame pour le chargement d'un fichier
             set info [frame $courbe.info -borderwidth 0 -cursor arrow -relief groove]
             pack $info -in $courbe -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                   #--- Cree un frame
                   frame $info.l1 -borderwidth 0 -cursor arrow
                   pack  $info.l1 -in $info -side top -expand 0 -anchor w

                        #--- Cree un label
                        label $info.l1.statusl -text "Fichier :"
                        pack  $info.l1.statusl -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        set ::av4l_analysis_tools::raw_status_file_gui $info.l1.statusv
                        label $info.l1.statusv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::raw_status_file
                        pack  $info.l1.statusv -in $info.l1 -side left -anchor e 

                             #--- Cree un label
                             label $info.l1.blank -width 5
                             pack  $info.l1.blank -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.nbl -text "Nb points :"
                        pack  $info.l1.nbl -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.nbv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::raw_nbframe
                        pack  $info.l1.nbv -in $info.l1 -side left -anchor e 

                             #--- Cree un label
                             label $info.l1.blank2 -width 5
                             pack  $info.l1.blank2 -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.dureel -text "durée (sec):"
                        pack  $info.l1.dureel -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.dureev -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::raw_duree
                        pack  $info.l1.dureev -in $info.l1 -side left -anchor e 

                             #--- Cree un label
                             label $info.l1.blank3 -width 5
                             pack  $info.l1.blank3 -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.fpsl -text "fps :"
                        pack  $info.l1.fpsl -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.fpsv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::raw_fps
                        pack  $info.l1.fpsv -in $info.l1 -side left -anchor e 


                   #--- Cree un frame
                   frame $info.l2 -borderwidth 0 -cursor arrow
                   pack  $info.l2 -in $info -side top -expand 0 -anchor w

                        #--- Cree un label
                        label $info.l2.dbegl -text "Date de début :"
                        pack  $info.l2.dbegl -in $info.l2 -side left -anchor w

                        #--- Cree un label
                        label $info.l2.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::raw_date_begin
                        pack  $info.l2.dbegv -in $info.l2 -side left -anchor e 

                             #--- Cree un label
                             label $info.l2.blank -width 5
                             pack  $info.l2.blank -in $info.l2 -side left -anchor w 

                        #--- Cree un label
                        label $info.l2.dendl -text "Date de Fin :"
                        pack  $info.l2.dendl -in $info.l2 -side left -anchor w 

                        #--- Cree un label
                        label $info.l2.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::raw_date_end
                        pack  $info.l2.dendv -in $info.l2 -side left -anchor e 



             #--- Cree un frame pour le chargement d'un fichier
             set corr_integ [frame $courbe.corr_integ -borderwidth 0 -cursor arrow -relief groove]
             pack $corr_integ -in $courbe -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $corr_integ.label -text "Correction de l intégration : "
                  pack  $corr_integ.label -side left -anchor w

                  #--- Creation du bouton open
                  button $corr_integ.but_offset -text "offset" -borderwidth 2 \
                        -command "::av4l_analysis_gui::corr_integ_get_offset $visuNo $corr_integ"
                  pack $corr_integ.but_offset -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $corr_integ.offset -textvariable ::av4l_analysis_gui::raw_integ_offset -width 4
                  pack $corr_integ.offset -side left -padx 3 -pady 1 

                  #--- Creation du bouton open
                  button $corr_integ.but_nb_img -text "nb img" -borderwidth 2 \
                        -command "::av4l_analysis_gui::corr_integ_get_nb_img $visuNo $corr_integ"
                  pack $corr_integ.but_nb_img -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $corr_integ.nb_img -textvariable ::av4l_analysis_gui::raw_integ_nb_img -width 4
                  pack  $corr_integ.nb_img -side left -padx 3 -pady 1 

                  #--- Creation du bouton open
                  button $corr_integ.but_view -text "view" -borderwidth 2 \
                        -command "::av4l_analysis_gui::corr_integ_view"
                  pack $corr_integ.but_view -side left -anchor e 

                  #--- Creation du bouton open
                  button $corr_integ.but_apply -text "Appliquer" -borderwidth 2 \
                        -command "::av4l_analysis_gui::corr_integ_apply"
                  pack $corr_integ.but_apply -side left -anchor e 


             #--- Cree un frame pour le chargement d'un fichier
             set sauver [frame $courbe.sauver -borderwidth 0 -cursor arrow -relief groove]
             pack $sauver -in $courbe -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                  #--- Creation du bouton open
                  button $sauver.but_save -text "Sauver" -borderwidth 2 \
                        -command "::av4l_analysis_gui::save_corrected_curve"
                  pack $sauver.but_save -side left -anchor e 





#---


#--- ONGLET : Courbe corrigee


#---




        #--- Cree un frame pour afficher le contenu de l onglet
        set corrected [frame $f2.frm -borderwidth 0 -cursor arrow -relief groove]
        pack $corrected -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
        
        
             #--- Cree un frame pour le chargement d'un fichier
             set charge [frame $corrected.charge -borderwidth 0 -cursor arrow -relief groove]
             pack $charge -in $corrected -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Creation du bouton open
                  button $charge.but_open \
                     -text "ouvrir" -borderwidth 2 \
                     -command "::av4l_analysis_gui::open_corr_file $visuNo $f1"
                  pack $charge.but_open \
                     -side left -anchor e \
                     -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

                  #--- Creation du bouton select
                  button $charge.but_select \
                     -text "..." -borderwidth 2 -takefocus 1 \
                     -command "::av4l_analysis_gui::select_corr_data $visuNo $charge"
                  pack $charge.but_select \
                     -side left -anchor e \
                     -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

                  #--- Cree un label pour le chemin de l'AVI
                  entry $charge.csvpath -textvariable ::av4l_analysis_gui::corr_filename_short
                  pack $charge.csvpath -side left -padx 3 -pady 1 -expand true -fill x


             #--- Cree un frame pour le chargement d'un fichier
             set info [frame $corrected.info -borderwidth 0 -cursor arrow -relief groove]
             pack $info -in $corrected -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                   #--- Cree un frame
                   frame $info.l1 -borderwidth 0 -cursor arrow
                   pack  $info.l1 -in $info -side top -expand 0 -anchor w

                        #--- Cree un label
                        label $info.l1.statusl -text "Fichier :"
                        pack  $info.l1.statusl -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        set ::av4l_analysis_tools::corr_status_file_gui $info.l1.statusv
                        label $info.l1.statusv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::corr_status_file
                        pack  $info.l1.statusv -in $info.l1 -side left -anchor e 

                             #--- Cree un label
                             label $info.l1.blank -width 5
                             pack  $info.l1.blank -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.nbl -text "Nb points :"
                        pack  $info.l1.nbl -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.nbv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::corr_nbframe
                        pack  $info.l1.nbv -in $info.l1 -side left -anchor e 

                             #--- Cree un label
                             label $info.l1.blank2 -width 5
                             pack  $info.l1.blank2 -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.dureel -text "durée (sec):"
                        pack  $info.l1.dureel -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.dureev -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::corr_duree
                        pack  $info.l1.dureev -in $info.l1 -side left -anchor e 

                             #--- Cree un label
                             label $info.l1.blank3 -width 5
                             pack  $info.l1.blank3 -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.fpsl -text "fps :"
                        pack  $info.l1.fpsl -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.fpsv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::corr_fps
                        pack  $info.l1.fpsv -in $info.l1 -side left -anchor e 

                   #--- Cree un frame
                   frame $info.l2 -borderwidth 0 -cursor arrow
                   pack  $info.l2 -in $info -side top -expand 0 -anchor w

                        #--- Cree un label
                        label $info.l2.dbegl -text "Date de début :"
                        pack  $info.l2.dbegl -in $info.l2 -side left -anchor w

                        #--- Cree un label
                        label $info.l2.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::corr_date_begin
                        pack  $info.l2.dbegv -in $info.l2 -side left -anchor e 

                             #--- Cree un label
                             label $info.l2.blank -width 5
                             pack  $info.l2.blank -in $info.l2 -side left -anchor w 

                        #--- Cree un label
                        label $info.l2.dendl -text "Date de Fin :"
                        pack  $info.l2.dendl -in $info.l2 -side left -anchor w 

                        #--- Cree un label
                        label $info.l2.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::corr_date_end
                        pack  $info.l2.dendv -in $info.l2 -side left -anchor e 


             #--- Cree un frame pour le chargement d'un fichier
             set events [frame $corrected.events -borderwidth 0 -cursor arrow -relief groove]
             pack $events -in $corrected -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                  #--- Cree un frame
                  frame $events.e1 -borderwidth 0 -cursor arrow
                  pack  $events.e1 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       image create photo .p1 -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_p1.png ]
                       button $events.e1.but_select -image .p1 -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 1"
                       pack $events.e1.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e1.but_select -text "Selection 1er plateau : Eviter de prendre trop proche de l'immersion !"
                        
                       #--- Cree un label
                       label $events.e1.dbegl -text "Nb img :"
                       pack  $events.e1.dbegl -in $events.e1 -side left -anchor w

                       #--- Cree un label
                       label $events.e1.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::nb_p1
                       pack  $events.e1.dbegv -in $events.e1 -side left -anchor e 

                            #--- Cree un label
                            label $events.e1.blank -width 3
                            pack  $events.e1.blank -in  $events.e1 -side left -anchor w 

                       #--- Cree un label
                       label $events.e1.dendl -text "Durée :"
                       pack  $events.e1.dendl -in $events.e1 -side left -anchor w 

                       #--- Cree un label
                       label $events.e1.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::corr_duree_e1
                       pack  $events.e1.dendv -in $events.e1 -side left -anchor e 
                         
                  #--- Cree un frame
                  frame $events.e2 -borderwidth 0 -cursor arrow
                  pack  $events.e2 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       image create photo .p2 -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_p2.png ]
                       button $events.e2.but_select -image .p2 -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 2"
                       pack $events.e2.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e2.but_select -text "Immersion : Prendre autant de point d'un coté que de l'autre \n autour de l'immersion. Eviter de prendre trop proche de l'emersion"
                          
                       #--- Cree un label
                       label $events.e2.dbegl -text "Nb img :"
                       pack  $events.e2.dbegl -in $events.e2 -side left -anchor w

                       #--- Cree un label
                       label $events.e2.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::nb_p2
                       pack  $events.e2.dbegv -in $events.e2 -side left -anchor e 

                            #--- Cree un label
                            label $events.e2.blank -width 3
                            pack  $events.e2.blank -in  $events.e2 -side left -anchor w 

                       #--- Cree un label
                       label $events.e2.dendl -text "Durée :"
                       pack  $events.e2.dendl -in $events.e2 -side left -anchor w 

                       #--- Cree un label
                       label $events.e2.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::corr_duree_e2
                       pack  $events.e2.dendv -in $events.e2 -side left -anchor e 
                         
                  #--- Cree un frame
                  frame $events.e3 -borderwidth 0 -cursor arrow
                  pack  $events.e3 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       image create photo .p3 -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_p3.png ]
                       button $events.e3.but_select -image .p3 -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 3"
                       pack $events.e3.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e3.but_select -text "Occultation : Eviter de prendre trop proche des evenements"
                          
                       #--- Cree un label
                       label $events.e3.dbegl -text "Nb img :"
                       pack  $events.e3.dbegl -in $events.e3 -side left -anchor w

                       #--- Cree un label
                       label $events.e3.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::nb_p3
                       pack  $events.e3.dbegv -in $events.e3 -side left -anchor e 

                            #--- Cree un label
                            label $events.e3.blank -width 3
                            pack  $events.e3.blank -in  $events.e3 -side left -anchor w 

                       #--- Cree un label
                       label $events.e3.dendl -text "Durée :"
                       pack  $events.e3.dendl -in $events.e3 -side left -anchor w 

                       #--- Cree un label
                       label $events.e3.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::corr_duree_e3
                       pack  $events.e3.dendv -in $events.e3 -side left -anchor e 
                         
                  #--- Cree un frame
                  frame $events.e4 -borderwidth 0 -cursor arrow
                  pack  $events.e4 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       image create photo .p4 -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_p4.png ]
                       button $events.e4.but_select -image .p4 -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 4"
                       pack $events.e4.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e4.but_select -text "Emersion : Prendre autant de point d'un coté que de l'autre \n autour de l'emersion. Eviter de prendre trop proche de l'immersion"
                          
                       #--- Cree un label
                       label $events.e4.dbegl -text "Nb img :"
                       pack  $events.e4.dbegl -in $events.e4 -side left -anchor w

                       #--- Cree un label
                       label $events.e4.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::nb_p4
                       pack  $events.e4.dbegv -in $events.e4 -side left -anchor e 

                            #--- Cree un label
                            label $events.e4.blank -width 3
                            pack  $events.e4.blank -in  $events.e4 -side left -anchor w 

                       #--- Cree un label
                       label $events.e4.dendl -text "Durée :"
                       pack  $events.e4.dendl -in $events.e4 -side left -anchor w 

                       #--- Cree un label
                       label $events.e4.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::corr_duree_e4
                       pack  $events.e4.dendv -in $events.e4 -side left -anchor e 
                         
                  #--- Cree un frame
                  frame $events.e5 -borderwidth 0 -cursor arrow
                  pack  $events.e5 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       image create photo .p5 -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_p5.png ]
                       button $events.e5.but_select -image .p5 -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 5"
                       pack $events.e5.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e5.but_select -text "Selection 2eme plateau : Eviter de prendre trop proche de l'emersion !"
                          
                       #--- Cree un label
                       label $events.e5.dbegl -text "Nb img :"
                       pack  $events.e5.dbegl -in $events.e5 -side left -anchor w

                       #--- Cree un label
                       label $events.e5.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::nb_p5
                       pack  $events.e5.dbegv -in $events.e5 -side left -anchor e 

                            #--- Cree un label
                            label $events.e5.blank -width 3
                            pack  $events.e5.blank -in  $events.e5 -side left -anchor w 

                       #--- Cree un label
                       label $events.e5.dendl -text "Durée :"
                       pack  $events.e5.dendl -in $events.e5 -side left -anchor w 

                       #--- Cree un label
                       label $events.e5.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::corr_duree_e5
                       pack  $events.e5.dendv -in $events.e5 -side left -anchor e 
                         


                      
#---


#--- ONGLET : Vracs


#---




        #--- Cree un frame pour afficher le contenu de l onglet
        set vrac [frame $f4.frm -borderwidth 0 -cursor arrow -relief groove]
        pack $vrac -in $f4 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
        
        
             #--- Cree un frame pour le chargement d'un fichier
             set wvlngth [frame $vrac.wvlngth -borderwidth 0 -cursor arrow -relief groove]
             pack $wvlngth -in $vrac -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $wvlngth.l -text "Longueur d'onde (microns) : "
                  pack  $wvlngth.l -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $wvlngth.v -textvariable ::av4l_analysis_gui::wvlngth
                  pack $wvlngth.v -side left -padx 3 -pady 1 -expand true -fill x





       
   # Fin proc ::av4l_analysis_gui::createdialog 
   }




}

