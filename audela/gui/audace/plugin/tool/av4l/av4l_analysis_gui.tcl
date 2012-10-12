#--------------------------------------------------
# source av4l_analysis_gui.tcl
#--------------------------------------------------
#
# Fichier        : av4l_analysis_gui.tcl
# Description    : GUI de l outil Courbe de lumiere
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: av4l_analysis_gui.tcl 7986 2011-12-22 20:15:55Z svaillant $
#

namespace eval ::av4l_analysis_gui {


















   proc ::av4l_analysis_gui::reinitialise { } {

      # 
      # Contexte
      # 
      set ::av4l_analysis_gui::occ_obj        ""
      set ::av4l_analysis_gui::occ_date       ""
      set ::av4l_analysis_gui::occ_pos        ""
      set ::av4l_analysis_gui::occ_pos_type   ""
      set ::av4l_analysis_gui::occ_obj_name   ""
      set ::av4l_analysis_gui::occ_obj_id     ""
      # 
      # Fichiers & Repertoires
      # 
      set ::av4l_analysis_gui::prj_file_short ""
      set ::av4l_analysis_gui::prj_file       ""
      set ::av4l_analysis_gui::prj_dir        ""
      # 
      # Ephemerides
      # 
      set ::av4l_analysis_gui::jd         ""
      set ::av4l_analysis_gui::rajapp     ""
      set ::av4l_analysis_gui::decapp     ""
      set ::av4l_analysis_gui::dist       ""
      set ::av4l_analysis_gui::magv       ""
      set ::av4l_analysis_gui::phase      ""
      set ::av4l_analysis_gui::elong      ""
      set ::av4l_analysis_gui::dracosd    ""
      set ::av4l_analysis_gui::ddec       ""
      set ::av4l_analysis_gui::vn         ""
      set ::av4l_analysis_gui::tsl        ""
      set ::av4l_analysis_gui::raj2000    ""
      set ::av4l_analysis_gui::decj2000   ""
      set ::av4l_analysis_gui::hourangle  ""
      set ::av4l_analysis_gui::decapp     ""
      set ::av4l_analysis_gui::azimuth    ""
      set ::av4l_analysis_gui::hauteur    ""
      set ::av4l_analysis_gui::airmass    ""
      set ::av4l_analysis_gui::dhelio     ""
      # 
      # Corrections courbe
      # 
      set ::av4l_analysis_gui::raw_filename_short ""
      set ::av4l_analysis_gui::raw_filename       ""
      set ::av4l_analysis_gui::raw_integ_offset   ""
      set ::av4l_analysis_gui::raw_integ_nb_img   ""
      set ::av4l_analysis_gui::int_corr           ""
      set ::av4l_analysis_gui::tps_corr           ""
      set ::av4l_analysis_gui::theo_expo          ""
      set ::av4l_analysis_gui::time_offset        ""
      set ::av4l_analysis_gui::ref_corr           ""
      # 
      # Evenements
      # 
      set ::av4l_analysis_gui::corr_filename_short        ""
      set ::av4l_analysis_gui::corr_filename              ""
      set ::av4l_analysis_tools::id_p1                    ""
      set ::av4l_analysis_tools::corr_duree_e1            ""
      set ::av4l_analysis_tools::nb_p1                    ""
      set ::av4l_analysis_gui::duree_max_immersion_search ""
      set ::av4l_analysis_tools::id_p2                    ""
      set ::av4l_analysis_tools::corr_duree_e2            ""
      set ::av4l_analysis_tools::nb_p2                    ""
      set ::av4l_analysis_tools::id_p3                    ""
      set ::av4l_analysis_tools::corr_duree_e3            ""
      set ::av4l_analysis_tools::nb_p3                    ""
      set ::av4l_analysis_gui::duree_max_emersion_search  ""
      set ::av4l_analysis_tools::id_p4                    ""
      set ::av4l_analysis_tools::corr_duree_e4            ""
      set ::av4l_analysis_tools::nb_p4                    ""
      set ::av4l_analysis_tools::id_p5                    ""
      set ::av4l_analysis_tools::corr_duree_e5            ""
      set ::av4l_analysis_tools::nb_p5                    ""
      set ::av4l_analysis_gui::duree_max_immersion_evnmt  ""
      set ::av4l_analysis_tools::id_p6                    ""
      set ::av4l_analysis_gui::date_immersion             ""
      set ::av4l_analysis_gui::duree_max_emersion_evnmt   ""
      set ::av4l_analysis_tools::id_p7                    ""
      set ::av4l_analysis_gui::date_emersion              ""

      # 
      # Parametres
      # 
      set ::av4l_analysis_gui::width             ""
      set ::av4l_analysis_gui::occ_star_name     ""
      set ::av4l_analysis_gui::occ_star_B        ""
      set ::av4l_analysis_gui::occ_star_V        ""
      set ::av4l_analysis_gui::occ_star_K        ""
      set ::av4l_analysis_gui::occ_star_size_mas ""
      set ::av4l_analysis_gui::occ_star_size_km  ""
      set ::av4l_analysis_gui::wvlngth           ""
      set ::av4l_analysis_gui::dlambda           ""
      set ::av4l_analysis_tools::irep            ""
      set ::av4l_analysis_gui::nheure            ""
      set ::av4l_analysis_gui::pas_heure         ""
      set ::av4l_analysis_tools::corr_exposure   ""
      set ::av4l_analysis_gui::date_begin_obs    ""
      set ::av4l_analysis_gui::date_end_obs      ""
      # 
      # Immersion & Emersion
      # 
      set ::av4l_analysis_gui::date_immersion_sol ""
      set ::av4l_analysis_gui::im_chi2_min        ""
      set ::av4l_analysis_gui::im_nfit_chi2_min   ""
      set ::av4l_analysis_gui::im_t0_chi2_min     ""
      set ::av4l_analysis_gui::im_t_inf           ""
      set ::av4l_analysis_gui::im_t_sup           ""
      set ::av4l_analysis_gui::im_t_diff          ""
      set ::av4l_analysis_gui::im_t_inf_3s        ""
      set ::av4l_analysis_gui::im_t_sup_3s        ""
      set ::av4l_analysis_gui::im_t_diff_3s       ""
      set ::av4l_analysis_gui::date_emersion_sol  ""
      set ::av4l_analysis_gui::em_chi2_min        ""
      set ::av4l_analysis_gui::em_nfit_chi2_min   ""
      set ::av4l_analysis_gui::em_t0_chi2_min     ""
      set ::av4l_analysis_gui::em_t_inf           ""
      set ::av4l_analysis_gui::em_t_sup           ""
      set ::av4l_analysis_gui::em_t_diff          ""
      set ::av4l_analysis_gui::em_t_inf_3s        ""
      set ::av4l_analysis_gui::em_t_sup_3s        ""
      set ::av4l_analysis_gui::em_t_diff_3s       ""
      set ::av4l_analysis_gui::bande              ""
      set ::av4l_analysis_gui::duree              ""
      set ::av4l_analysis_gui::result             ""
      # 
      # Contacts
      # 
      set ::av4l_analysis_gui::occ_observers  ""
      set ::av4l_analysis_gui::prj_reduc      ""
      set ::av4l_analysis_gui::prj_mail       ""
      set ::av4l_analysis_gui::prj_phone      ""
      set ::av4l_analysis_gui::prj_address    ""
      # 
      # Station
      # 
      set ::av4l_analysis_gui::type1_station  ""
      set ::av4l_analysis_gui::latitude       ""
      set ::av4l_analysis_gui::longitude      ""
      set ::av4l_analysis_gui::altitude       ""
      set ::av4l_analysis_gui::datum          ""
      set ::av4l_analysis_gui::nearest_city   ""
      set ::av4l_analysis_gui::type2_station  ""
      # 
      # Telescope
      # 
      set ::av4l_analysis_gui::telescop_type  ""
      set ::av4l_analysis_gui::telescop_aper  ""
      set ::av4l_analysis_gui::telescop_magn  ""
      set ::av4l_analysis_gui::telescop_moun  ""
      set ::av4l_analysis_gui::telescop_moto  ""
      # 
      # Acquisition
      # 
      set ::av4l_analysis_gui::record_evin    ""
      set ::av4l_analysis_gui::record_time    ""
      set ::av4l_analysis_gui::record_sens    ""
      set ::av4l_analysis_gui::record_prod    ""
      set ::av4l_analysis_gui::record_tiin    ""
      set ::av4l_analysis_gui::record_comp    ""
      # 
      # Conditions
      # 
      set ::av4l_analysis_gui::obscond_tran   ""
      set ::av4l_analysis_gui::obscond_wind   ""
      set ::av4l_analysis_gui::obscond_temp   ""
      set ::av4l_analysis_gui::obscond_stab   ""
      set ::av4l_analysis_gui::obscond_visi   ""
      # 
      # Comments
      # 
      .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f10.frm.comments.v delete 1.0 end 
      .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f10.frm.comments.v insert end ""

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














   proc ::av4l_analysis_gui::init_faible { } {

      set ::av4l_analysis_gui::but_calcul "Calcul"
      set ::av4l_analysis_gui::state_but_graph(1) 0
      set ::av4l_analysis_gui::state_but_graph(2) 0
      set ::av4l_analysis_gui::state_but_graph(3) 0
      set ::av4l_analysis_gui::state_but_graph(20) 0
      set ::av4l_analysis_gui::state_but_graph(21) 0
      set ::av4l_analysis_gui::state_but_graph(22) 0
      set ::av4l_analysis_gui::state_but_graph(23) 0
      set ::av4l_analysis_gui::state_but_graph(24) 0

      if {![info exists ::av4l_analysis_gui::wvlngth]} {set ::av4l_analysis_gui::wvlngth "0.75"}
      if {![info exists ::av4l_analysis_gui::dlambda]} {set ::av4l_analysis_gui::dlambda "0.4"}
      if {[string trim $::av4l_analysis_gui::wvlngth]==""} {set ::av4l_analysis_gui::wvlngth "0.75"}
      if {[string trim $::av4l_analysis_gui::dlambda]==""} {set ::av4l_analysis_gui::dlambda "0.4"}

      if {![info exists ::av4l_analysis_gui::dlambda]} {set ::av4l_analysis_gui::dlambda "0.4"}
      if {[string trim $::av4l_analysis_gui::wvlngth]==""} {set ::av4l_analysis_gui::wvlngth "0.75"}

      if {![info exists ::av4l_analysis_gui::nheure]}        {set ::av4l_analysis_gui::nheure 200}
      if {![info exists ::av4l_analysis_gui::pas_heure]}     {set ::av4l_analysis_gui::pas_heure 0.02}
      if {[string trim $::av4l_analysis_gui::nheure]==""}    {set ::av4l_analysis_gui::nheure 200}
      if {[string trim $::av4l_analysis_gui::pas_heure]==""} {set ::av4l_analysis_gui::pas_heure 0.02}


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
























  proc ::av4l_analysis_gui::test_sappho {  } {

     set ::av4l_analysis_gui::wvlngth 0.7500
     set ::av4l_analysis_gui::dlambda 0.4000

     set ::av4l_analysis_gui::dist    1.56
     set ::av4l_analysis_gui::occ_star_size_km      2.04
     set ::av4l_analysis_gui::vn      27.800

     set ::av4l_analysis_gui::width   150.0
     
     set ::av4l_analysis_gui::nheure  200  
     set ::av4l_analysis_gui::pas_heure  0.2
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
      ::plotxy::position {40 40 600 400}
      ::plotxy::plot $::av4l_analysis_gui::x $::av4l_analysis_gui::y b+
   }
























   proc ::av4l_analysis_gui::select_raw_data { visuNo frm } {

      global audace
      
      if {[info exists ::av4l_analysis_gui::prj_dir]} {
         set dir $::av4l_analysis_gui::prj_dir
      } else {
         set dir $audace(rep_images)
      }

      set fenetre [::confVisu::getBase $visuNo]
      set bufNo [ visu$visuNo buf ]
      set ::av4l_analysis_gui::raw_filename [ ::tkutil::box_load_csv $frm $dir $bufNo "1" ]
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
















   proc ::av4l_analysis_gui::corr_integ_reset { } {

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
      ::plotxy::position {40 40 600 400}
      ::plotxy::plot $::av4l_analysis_gui::x $::av4l_analysis_gui::y b+

   }
   
   





   proc ::av4l_analysis_gui::corr_integ_view { } {
     
     
      ::console::affiche_resultat " int_corr         = $::av4l_analysis_gui::int_corr\n"
      ::console::affiche_resultat " raw_integ_offset = $::av4l_analysis_gui::raw_integ_offset\n"
      ::console::affiche_resultat " raw_integ_nb_img = $::av4l_analysis_gui::raw_integ_nb_img\n"
      ::console::affiche_resultat " tps_corr         = $::av4l_analysis_gui::tps_corr\n"
      ::console::affiche_resultat " theo_expo        = $::av4l_analysis_gui::theo_expo\n"
      ::console::affiche_resultat " time_offset      = $::av4l_analysis_gui::time_offset\n"
      ::console::affiche_resultat " ref_corr         = $::av4l_analysis_gui::ref_corr\n"
          
      if {![info exists ::av4l_analysis_gui::raw_integ_offset]} {return}
      if {![info exists ::av4l_analysis_gui::raw_integ_nb_img]} {return}
      
      
      if {$::av4l_analysis_gui::int_corr==1} {
         ::av4l_analysis_tools::correction_integration $::av4l_analysis_gui::raw_integ_offset $::av4l_analysis_gui::raw_integ_nb_img
      }
      if {$::av4l_analysis_gui::tps_corr==1} {
         set ::av4l_analysis_gui::time_correction [expr ($::av4l_analysis_gui::theo_expo/2.0 + $::av4l_analysis_gui::time_offset)]
         ::av4l_analysis_tools::correction_temporelle
      } else {
         set ::av4l_analysis_gui::time_correction 0.0
      }
      
      
      # cree la courbe Rouges pour retrouver les paquets 
      set ::av4l_analysis_gui::x ""
      set ::av4l_analysis_gui::y ""

      for {set i 1} {$i<=$::av4l_analysis_tools::raw_nbframe} {incr i} {
         if {![info exists ::av4l_analysis_tools::medianecdl($i,jd)]} {continue}
         lappend ::av4l_analysis_gui::x [expr ($::av4l_analysis_tools::medianecdl($i,jd) - $::av4l_analysis_tools::orig) * 86400.0]
         lappend ::av4l_analysis_gui::y $::av4l_analysis_tools::medianecdl($i,obj_fint)
      }

      # affiche la courbe  couleur: rgbk   symbol: +xo* [list -linewidth 4]
      ::plotxy::plot $::av4l_analysis_gui::x $::av4l_analysis_gui::y rx 
      #  http://www-hermes.desy.de/pink/blt.html#Sect6_4

      # cree la courbe finale, mediane des paquets, correction d offset et correction du flux de reference
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
      ::plotxy::position {40 40 600 400}

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
      set ::av4l_analysis_gui::cdl_x ""
      set ::av4l_analysis_gui::cdl_y ""

      for {set i 1} {$i<=$::av4l_analysis_tools::corr_nbframe} {incr i} {
         lappend ::av4l_analysis_gui::cdl_x [expr ($::av4l_analysis_tools::cdl($i,jd) - $::av4l_analysis_tools::orig) * 86400.0 ]
         lappend ::av4l_analysis_gui::cdl_y $::av4l_analysis_tools::cdl($i,flux)
      }
      set ::av4l_analysis_gui::date_begin_obs [mc_date2iso8601 $::av4l_analysis_tools::cdl(1,jd)]
      set ::av4l_analysis_gui::date_end_obs   [mc_date2iso8601 $::av4l_analysis_tools::cdl($::av4l_analysis_tools::corr_nbframe,jd)]
      
      ::av4l_analysis_gui::active_graphe $frm.frm.graphe l 1
      
   }















   proc ::av4l_analysis_gui::select_corr_data { visuNo frm } {

      global audace

      if {[info exists ::av4l_analysis_gui::prj_dir]} {
         set dir $::av4l_analysis_gui::prj_dir
      } else {
         set dir $audace(rep_images)
      }

      set fenetre [::confVisu::getBase $visuNo]
      set bufNo [ visu$visuNo buf ]
      set ::av4l_analysis_gui::corr_filename [ ::tkutil::box_load_csv $frm $dir $bufNo "1" ]
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
            if {$cpt==1} {set id $i}
            set p($cpt,idframe) $x 
            set p($cpt,x) $x 
            set p($cpt,y) $y 
         }
      }
      if {$cpt==0} {return}
      
      if {$e==1} {
         set ::av4l_analysis_tools::id_p1           $id
         set ::av4l_analysis_tools::corr_duree_e1   [format "%.3f" [expr $p($cpt,x) - $p(1,x)] ]
         set ::av4l_analysis_tools::nb_p1 $cpt
      }
      if {$e==2} {
         set ::av4l_analysis_gui::duree_max_immersion_search  [format "%.3f" [expr $cpt / $::av4l_analysis_tools::corr_fps] ]
         set ::av4l_analysis_tools::id_p2           $id
         set ::av4l_analysis_tools::corr_duree_e2   [format "%.3f"  [expr $p($cpt,x) - $p(1,x)] ]
         set ::av4l_analysis_tools::nb_p2 $cpt
      }
      if {$e==3} {
         set ::av4l_analysis_tools::id_p3           $id
         set ::av4l_analysis_tools::corr_duree_e3   [format "%.3f"  [expr $p($cpt,x) - $p(1,x)] ]
         set ::av4l_analysis_tools::nb_p3 $cpt
      }
      if {$e==4} {
         set ::av4l_analysis_gui::duree_max_emersion_search  [format "%.3f" [expr $cpt / $::av4l_analysis_tools::corr_fps] ]
         set ::av4l_analysis_tools::id_p4           $id
         set ::av4l_analysis_tools::corr_duree_e4   [format "%.3f"  [expr $p($cpt,x) - $p(1,x)] ]
         set ::av4l_analysis_tools::nb_p4 $cpt
      }
      if {$e==5} {
         set ::av4l_analysis_tools::id_p5           $id
         set ::av4l_analysis_tools::corr_duree_e5   [format "%.3f"  [expr $p($cpt,x) - $p(1,x)] ]
         set ::av4l_analysis_tools::nb_p5 $cpt
      }
      if {$e==6} {
         set ::av4l_analysis_gui::duree_max_immersion_evnmt  [format "%.3f" [expr $cpt / $::av4l_analysis_tools::corr_fps] ]
         set i [expr int($cpt/2.0)]
         if {$i==0} {incr i}
         set ::av4l_analysis_tools::id_p6         [expr $id + $i]
         set ::av4l_analysis_gui::date_immersion  [ mc_date2iso8601 [expr $p($i,x) / 86400.0 + $::av4l_analysis_tools::orig ] ]
      }
      if {$e==7} {
         set ::av4l_analysis_gui::duree_max_emersion_evnmt  [format "%.3f" [expr $cpt / $::av4l_analysis_tools::corr_fps] ]
         set i [expr int($cpt/2.0)]
         if {$i==0} {incr i}
         set ::av4l_analysis_tools::id_p7        [expr $id + $i]
         set ::av4l_analysis_gui::date_emersion  [ mc_date2iso8601 [expr $p($i,x) / 86400.0 + $::av4l_analysis_tools::orig ] ]
      }

   }

















   proc ::av4l_analysis_gui::calcul_evenement { e } {

      # Test si calcul en cours      
      if {$::av4l_analysis_gui::but_calcul=="Stop"} {
         set ::av4l_analysis_tools::but_calcul "Stop"
         return
      }

      # On averti qu on va commencer le calcul       
      # BOUTTONS CALCUL -> mode WAIT
      .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .stop
      .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .stop
      set ::av4l_analysis_gui::but_calcul "Stop"


      # init du repertoire des fichiers de sorti
      set ::av4l_analysis_tools::dirwork $::av4l_analysis_gui::prj_dir
      set ::av4l_analysis_tools::filesout 0






      # Longueur d''onde (m)
      set ::av4l_analysis_tools::wvlngth [expr $::av4l_analysis_gui::wvlngth * 1.e-09]

      # Bande passante (m)
      set ::av4l_analysis_tools::dlambda [expr $::av4l_analysis_gui::dlambda * 1.e-09]

      #  Distance a l'anneau (km): distance geocentrique de l objet occulteur
      set ::av4l_analysis_tools::dist  [expr $::av4l_analysis_gui::dist * [::av4l_analysis_tools::ua]]

      #  Rayon de l'etoile (km)
      set ::av4l_analysis_tools::re $::av4l_analysis_gui::occ_star_size_km

      # Vitesse normale de l'etoile (dans plan du ciel, km/s) ???
      # Vitesse relative de l'objet par rapport a la terre (km/s)
      set ::av4l_analysis_tools::vn $::av4l_analysis_gui::vn

      # Largeur de la bande (km)
      # Taille estimée de l'objet (km)
      # si occultation rasante c est la taille de la corde (km)
      set ::av4l_analysis_tools::width $::av4l_analysis_gui::width

      # transmission
      # opaque = 0, sinon demander bruno
      set ::av4l_analysis_tools::trans 0

      # pas en temps (sec)
      set ::av4l_analysis_tools::pas [expr 1.0 * $::av4l_analysis_tools::corr_exposure]

      # on essai 100 points autour du T0 
      # en considerant un ecart entre les points de 0.02 sec
      # on peut dire qu on choisi pas = tmps d expo / 10
      # le pas est une estimation de la precision
      # nheure = 100 *0.02=> duree de 2 sec pour explorer l espace de
      # recherche autour de l evenement
      #
      # Nombre d'instant a explorer autour de la reference (points)
      set ::av4l_analysis_tools::nheure $::av4l_analysis_gui::nheure
      
      # pas (sec)
      set ::av4l_analysis_tools::pas_heure $::av4l_analysis_gui::pas_heure
      
      # mediane plateau haut
      set tab ""
      for {set i 1} {$i<=$::av4l_analysis_tools::nb_p1} {incr i} {
         set j [expr $i + $::av4l_analysis_tools::id_p1 - 1]
         lappend tab $::av4l_analysis_tools::cdl($j,flux)
      }
      for {set i 1} {$i<=$::av4l_analysis_tools::nb_p5} {incr i} {
         set j [expr $i + $::av4l_analysis_tools::id_p5 - 1]
         lappend tab $::av4l_analysis_tools::cdl($j,flux)
      }
      set ::av4l_analysis_tools::med1 [::math::statistics::median $tab]
      set ::av4l_analysis_tools::sigma [expr [::math::statistics::stdev $tab]/ $::av4l_analysis_tools::med1]

      # mediane plateau bas
      set tab ""
      for {set i 1} {$i<=$::av4l_analysis_tools::nb_p3} {incr i} {
         incr cpt
         set j [expr $i + $::av4l_analysis_tools::id_p3 - 1]
         lappend tab $::av4l_analysis_tools::cdl($j,flux)
      }
      set med0 [::math::statistics::median $tab]
      ::console::affiche_resultat "med0: $med0\n"      
      ::console::affiche_resultat "med1: $::av4l_analysis_tools::med1\n"      

      # normalisation du flux
      set ::av4l_analysis_tools::phi1 1
      set ::av4l_analysis_tools::phi0 [expr $med0 / $::av4l_analysis_tools::med1]
      ::console::affiche_resultat "phi0: $::av4l_analysis_tools::phi0\n"      
      ::console::affiche_resultat "phi1: $::av4l_analysis_tools::phi1\n"      




      if {$e==-1} {
      
         # Mode immersion
         set ::av4l_analysis_tools::mode -1

         # 
         # on a 5 secondes dans lesquelles on va mesurer l instant
         # on a37 points de 0.3 sec d ecart
         # 
         # 
         # Duree generee (points)
         # duree synthetique choisie autour de l'evenement.
         # ex: 30 sec alrs que l evenement est au milieu.
         # attention de ne pas choisir trop large pour englober
         # l'autre evenement.
         set ::av4l_analysis_tools::duree $::av4l_analysis_tools::nb_p2

         # Heure de reference (sec TU)
         set t  [ mc_date2jd $::av4l_analysis_gui::date_immersion]
         set ::av4l_analysis_tools::t0_ref [expr ( $t - $::av4l_analysis_tools::orig ) * 86400.0]
         set ::av4l_analysis_tools::t_milieu [expr $::av4l_analysis_tools::t0_ref  + $::av4l_analysis_tools::width/(2.0*$::av4l_analysis_tools::vn)]

         set ::av4l_analysis_tools::t0_min [expr $::av4l_analysis_tools::t0_ref - $::av4l_analysis_tools::pas_heure * $::av4l_analysis_tools::nheure / 2.0]
         set ::av4l_analysis_tools::t0_max [expr $::av4l_analysis_tools::t0_ref + $::av4l_analysis_tools::pas_heure * $::av4l_analysis_tools::nheure / 2.0]
         set ::av4l_analysis_tools::t0     $::av4l_analysis_tools::t0_min

         # tableau des observations
         for {set i 1} {$i<=$::av4l_analysis_tools::nb_p2} {incr i} {
            set j [expr $i + $::av4l_analysis_tools::id_p2 - 1]
            set ::av4l_analysis_tools::tobs($i) [expr ($::av4l_analysis_tools::cdl($j,jd)-$::av4l_analysis_tools::orig) * 86400.0]
            set ::av4l_analysis_tools::fobs($i) [expr $::av4l_analysis_tools::cdl($j,flux)/$::av4l_analysis_tools::med1]
         }

         set ::av4l_analysis_tools::chi2_search ""

         # Premier passage recherche du meilleur temps
         set err [ catch {::av4l_analysis_tools::partie2 1} msg ]
         if {$err} {
            ::console::affiche_erreur "Erreur durant le calcul\n"
            ::console::affiche_erreur "Err = $err\n"
            ::console::affiche_erreur "Msg = $msg\n"

            # BOUTTONS CALCUL -> mode Ok
            .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
            .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
            set ::av4l_analysis_gui::but_calcul "Calcul"

            return
         }
         
         
         
         if {1==1} {
         
            set nheuresav $::av4l_analysis_tools::nheure
            set ::av4l_analysis_tools::nheure   1
            set ::av4l_analysis_tools::t0_ref   $::av4l_analysis_tools::t0_chi2_min
            set ::av4l_analysis_tools::t_milieu [expr $::av4l_analysis_tools::t0_ref  + $::av4l_analysis_tools::width/(2.0*$::av4l_analysis_tools::vn)]
            set ::av4l_analysis_tools::t0_min   [expr $::av4l_analysis_tools::t0_ref - $::av4l_analysis_tools::pas_heure * $::av4l_analysis_tools::nheure / 2.0]
            set ::av4l_analysis_tools::t0_max   [expr $::av4l_analysis_tools::t0_ref + $::av4l_analysis_tools::pas_heure * $::av4l_analysis_tools::nheure / 2.0]
            set ::av4l_analysis_tools::t0       $::av4l_analysis_tools::t0_min

            # Deuxieme passage initialisation des resultats
            set err [ catch {::av4l_analysis_tools::partie2 2} msg ]
            if {$err} {
               ::console::affiche_erreur "Erreur durant le calcul\n"
               ::console::affiche_erreur "Err = $err\n"
               ::console::affiche_erreur "Msg = $msg\n"

               # BOUTTONS CALCUL -> mode Ok
               .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
               .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
               set ::av4l_analysis_gui::but_calcul "Calcul"

               return
            }
            set ::av4l_analysis_tools::nheure $nheuresav

         }
         
         ::console::affiche_resultat "orig: $::av4l_analysis_tools::orig\n"      
         ::console::affiche_resultat "t0_chi2_min: $::av4l_analysis_tools::t0_chi2_min\n"      
         ::console::affiche_resultat "t0_norm: [expr $::av4l_analysis_tools::t0_chi2_min / 86400.0 + $::av4l_analysis_tools::orig]\n"      
         
         set ::av4l_analysis_gui::date_immersion_sol [ mc_date2iso8601 [expr $::av4l_analysis_tools::t0_chi2_min / 86400.0 + $::av4l_analysis_tools::orig] ]

         set t $::av4l_analysis_tools::t0_chi2_min
         set ::av4l_analysis_tools::im_evenement_x [list $t $t]
         set ::av4l_analysis_tools::im_evenement_y [list 0 $::av4l_analysis_tools::med1]

         set ::av4l_analysis_gui::im_chi2_min      $::av4l_analysis_tools::chi2_min     
         set ::av4l_analysis_gui::im_nfit_chi2_min $::av4l_analysis_tools::nfit_chi2_min
         set ::av4l_analysis_gui::im_t0_chi2_min   $::av4l_analysis_tools::t0_chi2_min  
         set ::av4l_analysis_gui::im_t_inf         $::av4l_analysis_tools::t_inf        
         set ::av4l_analysis_gui::im_t_sup         $::av4l_analysis_tools::t_sup        
         set ::av4l_analysis_gui::im_t_diff        $::av4l_analysis_tools::t_diff       
         set ::av4l_analysis_gui::im_t_inf_3s      $::av4l_analysis_tools::t_inf_3s     
         set ::av4l_analysis_gui::im_t_sup_3s      $::av4l_analysis_tools::t_sup_3s     
         set ::av4l_analysis_gui::im_t_diff_3s     $::av4l_analysis_tools::t_diff_3s    

      }
      
      
      if {$e==1} {
      
         # Mode immersion
         set ::av4l_analysis_tools::mode 1

         # 
         # on a 5 secondes dans lesquelles on va mesurer l instant
         # on a37 points de 0.3 sec d ecart
         # 
         # 
         # Duree generee (points)
         # duree synthetique choisie autour de l'evenement.
         # ex: 30 sec alrs que l evenement est au milieu.
         # attention de ne pas choisir trop large pour englober
         # l'autre evenement.
         set ::av4l_analysis_tools::duree $::av4l_analysis_tools::nb_p4

         # Heure de reference (sec TU)
         set t  [ mc_date2jd $::av4l_analysis_gui::date_emersion]
         set ::av4l_analysis_tools::t0_ref [expr ( $t - $::av4l_analysis_tools::orig ) * 86400.0]
         set ::av4l_analysis_tools::t_milieu [expr $::av4l_analysis_tools::t0_ref  + $::av4l_analysis_tools::width/(2.0*$::av4l_analysis_tools::vn)]
      
         set ::av4l_analysis_tools::t0_min [expr $::av4l_analysis_tools::t0_ref - $::av4l_analysis_tools::pas_heure * $::av4l_analysis_tools::nheure / 2.0]
         set ::av4l_analysis_tools::t0_max [expr $::av4l_analysis_tools::t0_ref + $::av4l_analysis_tools::pas_heure * $::av4l_analysis_tools::nheure / 2.0]
         set ::av4l_analysis_tools::t0     $::av4l_analysis_tools::t0_min

         # tableau des observations
         for {set i 1} {$i<=$::av4l_analysis_tools::nb_p4} {incr i} {
            set j [expr $i + $::av4l_analysis_tools::id_p4 - 1]
            set ::av4l_analysis_tools::tobs($i) [expr ($::av4l_analysis_tools::cdl($j,jd)-$::av4l_analysis_tools::orig) * 86400.0]
            set ::av4l_analysis_tools::fobs($i) [expr $::av4l_analysis_tools::cdl($j,flux)/$::av4l_analysis_tools::med1]
         }

         set ::av4l_analysis_tools::chi2_search ""

         # Premier passage recherche du meilleur temps
         set err [ catch {::av4l_analysis_tools::partie2 1} msg ]
         if {$err} {
            ::console::affiche_erreur "Erreur durant le calcul\n"
            ::console::affiche_erreur "Err = $err\n"
            ::console::affiche_erreur "Msg = $msg\n"

            # BOUTTONS CALCUL -> mode Ok
            .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
            .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
            set ::av4l_analysis_gui::but_calcul "Calcul"

            return
         }
         
         if {1==1} {
         
            set nheuresav $::av4l_analysis_tools::nheure
            set ::av4l_analysis_tools::nheure   1
            set ::av4l_analysis_tools::t0_ref   $::av4l_analysis_tools::t0_chi2_min
            set ::av4l_analysis_tools::t_milieu [expr $::av4l_analysis_tools::t0_ref  + $::av4l_analysis_tools::width/(2.0*$::av4l_analysis_tools::vn)]
            set ::av4l_analysis_tools::t0_min   [expr $::av4l_analysis_tools::t0_ref - $::av4l_analysis_tools::pas_heure * $::av4l_analysis_tools::nheure / 2.0]
            set ::av4l_analysis_tools::t0_max   [expr $::av4l_analysis_tools::t0_ref + $::av4l_analysis_tools::pas_heure * $::av4l_analysis_tools::nheure / 2.0]
            set ::av4l_analysis_tools::t0       $::av4l_analysis_tools::t0_min



            # Deuxieme passage initialisation des resultats
            set err [ catch {::av4l_analysis_tools::partie2 2} msg ]
            if {$err} {
               ::console::affiche_erreur "Erreur durant le calcul\n"
               ::console::affiche_erreur "Err = $err\n"
               ::console::affiche_erreur "Msg = $msg\n"

               # BOUTTONS CALCUL -> mode Ok
               .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
               .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
               set ::av4l_analysis_gui::but_calcul "Calcul"

               return
            }
            set ::av4l_analysis_tools::nheure $nheuresav

         }
         
         ::console::affiche_resultat "orig: $::av4l_analysis_tools::orig\n"      
         ::console::affiche_resultat "t0_chi2_min: $::av4l_analysis_tools::t0_chi2_min\n"      
         ::console::affiche_resultat "t0_norm: [expr $::av4l_analysis_tools::t0_chi2_min / 86400.0 + $::av4l_analysis_tools::orig]\n"      
         
         set ::av4l_analysis_gui::date_emersion_sol [ mc_date2iso8601 [expr $::av4l_analysis_tools::t0_chi2_min / 86400.0 + $::av4l_analysis_tools::orig] ]

         set t $::av4l_analysis_tools::t0_chi2_min
         set ::av4l_analysis_tools::em_evenement_x [list $t $t]
         set ::av4l_analysis_tools::em_evenement_y [list 0 $::av4l_analysis_tools::med1]

         set ::av4l_analysis_gui::em_chi2_min      $::av4l_analysis_tools::chi2_min     
         set ::av4l_analysis_gui::em_nfit_chi2_min $::av4l_analysis_tools::nfit_chi2_min
         set ::av4l_analysis_gui::em_t0_chi2_min   $::av4l_analysis_tools::t0_chi2_min  
         set ::av4l_analysis_gui::em_t_inf         $::av4l_analysis_tools::t_inf        
         set ::av4l_analysis_gui::em_t_sup         $::av4l_analysis_tools::t_sup        
         set ::av4l_analysis_gui::em_t_diff        $::av4l_analysis_tools::t_diff       
         set ::av4l_analysis_gui::em_t_inf_3s      $::av4l_analysis_tools::t_inf_3s     
         set ::av4l_analysis_gui::em_t_sup_3s      $::av4l_analysis_tools::t_sup_3s     
         set ::av4l_analysis_gui::em_t_diff_3s     $::av4l_analysis_tools::t_diff_3s    

      }
      
      # Si l immersion et l emersion ont ete calculé alors on calcule la duree et la taille de la bande
      if {[info exists ::av4l_analysis_gui::date_emersion_sol]} {
         if {$::av4l_analysis_gui::date_emersion_sol!=""} {
            if {[info exists ::av4l_analysis_gui::date_immersion_sol]} {
               if {$::av4l_analysis_gui::date_immersion_sol!=""} {
                  set ::av4l_analysis_gui::duree [format "%.3f" [expr ([mc_date2jd $::av4l_analysis_gui::date_emersion_sol]-[mc_date2jd $::av4l_analysis_gui::date_immersion_sol])*86400.0] ]
                  set ::av4l_analysis_gui::bande [format "%.3f" [expr $::av4l_analysis_gui::duree * $::av4l_analysis_gui::vn] ]
               }
            }
         }
      }
      
      # BOUTTONS CALCUL -> mode Ok
      .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
      .audace.av4l_analysis.frm_av4l_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
      set ::av4l_analysis_gui::but_calcul "Calcul"

      ::av4l_analysis_gui::affiche_graphe
      
   }
      













   proc ::av4l_analysis_gui::affiche_graphe { } {
      
      # recupere les axes d un graphe 
      #  set ax [::plotxy::axis]
      
      # defninit les axes d un graphe 
      #  ::plotxy::axis $ax
      
      # Faire une trainée plus epaisse
      # [list -linewidth 4]
      
      # cacher un plot
      # plotxy::sethandler $::av4l_analysis_gui::h1 [list -hide yes]
      
      # montrer un plot
      # plotxy::sethandler $::av4l_analysis_gui::h1 [list -hide no]
      # ::plotxy::axis $ax

      # affiche la courbe
      set err [catch {set ax [::plotxy::getzoom]} msg ]
      if {!$err} {
         ::console::affiche_resultat "ZOOM: $ax\n"      
      } else {
      
    
      }
      
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {40 40 600 400}
      
      if {!$err&&$::av4l_analysis_gui::state_but_graph(24)!=1} {
         ::plotxy::setzoom $ax
      }

      # Signal photométrique (noir)
      if {$::av4l_analysis_gui::state_but_graph(1)==1} {
         set h1 [::plotxy::plot $::av4l_analysis_gui::cdl_x $::::av4l_analysis_gui::cdl_y .]
         plotxy::sethandler $h1 [list -color #000000 -linewidth 1]
      }
      # Polynome (noir)
      if {$::av4l_analysis_gui::state_but_graph(2)==1} {
         set h2 [::plotxy::plot $::av4l_analysis_tools::poly_x $::av4l_analysis_tools::poly_y o]
         plotxy::sethandler $h2 [list -color #18ad86 -linewidth 1]
      }
      # Evenements
      if {$::av4l_analysis_gui::state_but_graph(3)==1} {
         if {[info exists ::av4l_analysis_tools::im_evenement_x]&&[info exists ::av4l_analysis_tools::im_evenement_y]} {
            set h3 [::plotxy::plot $::av4l_analysis_tools::im_evenement_x $::av4l_analysis_tools::im_evenement_y o]
            plotxy::sethandler $h3 [list -color #00fffc -linewidth 1]
         }
         if {[info exists ::av4l_analysis_tools::em_evenement_x]&&[info exists ::av4l_analysis_tools::em_evenement_y]} {
            set h4 [::plotxy::plot $::av4l_analysis_tools::em_evenement_x $::av4l_analysis_tools::em_evenement_y o]
            plotxy::sethandler $h4 [list -color #00fffc -linewidth 1]
         }
      }
      # Ombre géométrique (jaune fff500)
      if {$::av4l_analysis_gui::state_but_graph(20)==1} {
         set h20 [::plotxy::plot $::av4l_analysis_tools::20_ombre_geometrique_x $::av4l_analysis_tools::20_ombre_geometrique_y o]
         plotxy::sethandler $h20 [list -color #fff500 -linewidth 1]
      }
      # Ombre avec diffraction (Fresnel) (bleue 002aff)
      if {$::av4l_analysis_gui::state_but_graph(21)==1} {
         set h21 [::plotxy::plot $::av4l_analysis_tools::21_ombre_avec_diffraction_x $::av4l_analysis_tools::21_ombre_avec_diffraction_y o]
         plotxy::sethandler $h21 [list -color #002aff -linewidth 1]
      }
      # Ombre lissee par la reponse instrumentale (donne par le modele) (magenta=ff00fc)
      if {$::av4l_analysis_gui::state_but_graph(22)==1} {
         set h22 [::plotxy::plot $::av4l_analysis_tools::22_ombre_instru_x $::av4l_analysis_tools::22_ombre_instru_y o]
         plotxy::sethandler $h22 [list -color #ff00fc -linewidth 1]
      }
      # Ombre interpolée sur les points d'observation (rouge=ff0000)
      if {$::av4l_analysis_gui::state_but_graph(23)==1} {
         set h23 [::plotxy::plot $::av4l_analysis_tools::23_ombre_interpol_x $::av4l_analysis_tools::23_ombre_interpol_y o]
         plotxy::sethandler $h23 [list -color #ff0000 -linewidth 0]
      }
      # Chi2 (vert foncé 18ad00)
      if {$::av4l_analysis_gui::state_but_graph(24)==1} {
         set h24 [::plotxy::plot $::av4l_analysis_tools::24_chi2_x $::av4l_analysis_tools::24_chi2_y o]
         plotxy::sethandler $h24 [list -color #18ad00 -linewidth 1]
      }
      
      

   }
















   proc ::av4l_analysis_gui::active_graphe { frame c b } {
   
   
      if {$::av4l_analysis_gui::state_but_graph($b) == 1} {
         set ::av4l_analysis_gui::state_but_graph($b) 0
         $frame.$c.$b.view configure -relief "raised"
      } else {
         set ::av4l_analysis_gui::state_but_graph($b) 1 
         $frame.$c.$b.view configure -relief "sunken"
      }
      
      if {$b==24} {
         set lb [list 1 2 3 20 21 22 23]
         if {$::av4l_analysis_gui::state_but_graph($b)==1 } {
            foreach bp $lb {
               set ::av4l_analysis_gui::state_but_graph($bp) 0
            }
            $frame.l.1.view configure -relief "raised"
            $frame.l.3.view configure -relief "raised"
            $frame.l.2.view configure -relief "raised"
            $frame.r.21.view configure -relief "raised"
            $frame.r.22.view configure -relief "raised"
            $frame.r.23.view configure -relief "raised"
            $frame.r.20.view configure -relief "raised"
         } else {
            set ::av4l_analysis_gui::state_but_graph(1) 1 
            $frame.l.1.view configure -relief "sunken"
         }
      } else {
         set ::av4l_analysis_gui::state_but_graph(24) 0 
         $frame.l.24.view configure -relief "raised"
      }
      
      ::av4l_analysis_gui::affiche_graphe
   
   }



















   proc ::av4l_analysis_gui::calcul_dureesearch { frm e } {

      global color

      if {$e==-1} {
         if {![info exists ::av4l_analysis_gui::duree_max_immersion_search]} {
            return
         }
         if {$::av4l_analysis_gui::duree_max_immersion_search==""} {
            return
         }
         if {![info exists ::av4l_analysis_gui::duree_max_immersion_evnmt]} {
            return
         }
         if {$::av4l_analysis_gui::duree_max_immersion_evnmt==""} {
            return
         }
         set duree_max_search $::av4l_analysis_gui::duree_max_immersion_search 
         set duree_max_evnmt  $::av4l_analysis_gui::duree_max_immersion_evnmt
      }
      if {$e==1} {
         if {![info exists ::av4l_analysis_gui::duree_max_emersion_search]} {
            return
         }
         if {$::av4l_analysis_gui::duree_max_emersion_search==""} {
            return
         }
         if {![info exists ::av4l_analysis_gui::duree_max_emersion_evnmt]} {
            return
         }
         if {$::av4l_analysis_gui::duree_max_emersion_evnmt==""} {
            return
         }
         set duree_max_search $::av4l_analysis_gui::duree_max_emersion_search 
         set duree_max_evnmt  $::av4l_analysis_gui::duree_max_emersion_evnmt
      }

      
      if {$::av4l_analysis_gui::pas_heure==""} {
         set ::av4l_analysis_gui::dureesearch "?"
         return
      }
      
      if {$::av4l_analysis_gui::nheure==""} {
         set ::av4l_analysis_gui::dureesearch "?"
         return
      }
      
      if {![string is double $::av4l_analysis_gui::pas_heure]} {
         set ::av4l_analysis_gui::dureesearch "?"
         return
      }
      
      if {![string is double $::av4l_analysis_gui::nheure]} {
         set ::av4l_analysis_gui::dureesearch "?"
         return
      }
      
      set ::av4l_analysis_gui::dureesearch [format "%.3f" [expr $::av4l_analysis_gui::pas_heure * $::av4l_analysis_gui::nheure]]
      
      $frm.v configure -fg $color(blue)
      if {$::av4l_analysis_gui::dureesearch > $duree_max_search } {
         $frm.v configure -fg $color(red)
      }
      if {$::av4l_analysis_gui::dureesearch < $duree_max_evnmt } {
         $frm.v configure -fg $color(red)
      }
      
      
      
   }   



















   proc ::av4l_analysis_gui::generer { visuNo } {

      if {![info exists ::av4l_analysis_gui::occ_obj]} {
         tk_messageBox -message "Veuillez entrer le nom d'un objet occulteur" -type ok
         return
      }
      if {![info exists ::av4l_analysis_gui::occ_date]} {
         tk_messageBox -message "Veuillez entrer une date d'occultation" -type ok
         return
      }
      if {![info exists ::av4l_analysis_gui::occ_pos]} {
         tk_messageBox -message "Veuillez entrer une position de l'observateur. Le code 500 du geocentre peut etre mis en attendant une position plus précise." -type ok
         return
      }
      if {![info exists ::av4l_analysis_gui::occ_pos_type]} {
         tk_messageBox -message "Veuillez selectionner un type de position de l'observateur. 'Code UAI' ou 'Lon Lat Alt'" -type ok
         return
      }
      if {$::av4l_analysis_gui::occ_obj==""} {
         tk_messageBox -message "Veuillez entrer le nom d'un objet occulteur" -type ok
         return
      }
      if {$::av4l_analysis_gui::occ_date==""} {
         tk_messageBox -message "Veuillez entrer une date d'occultation" -type ok
         return
      }
      if {$::av4l_analysis_gui::occ_pos==""} {
         tk_messageBox -message "Veuillez entrer une position de l'observateur. Le code 500 du geocentre peut etre mis en attendant une position plus précise." -type ok
         return
      }
      if {$::av4l_analysis_gui::occ_pos_type==""} {
         tk_messageBox -message "Veuillez selectionner un type de position de l'observateur. 'Code UAI' ou 'Lon Lat Alt'" -type ok
         return
      }
      
      # 2010-06-05_80_Sappho_Lat+48.0001_Lon_+02.0001

      # date
      #set date [mc_date2jd $::av4l_analysis_gui::occ_date ]
      #set date [expr floor($date)+0.5]
      #set date [mc_date2ymdhms $date]
      #set y [lindex $date 0]
      #set m [format "%0.2d" [lindex $date 1]]
      #set d [format "%0.2d" [lindex $date 2]]
      #set date "${y}-${m}-${d}"

      set date $::av4l_analysis_gui::occ_date
      regsub -all {\-} $date {}   date
      regsub -all { }  $date {_}  date
      regsub -all {T}  $date {_}  date
      regsub -all {:}  $date {}   date
      set d [split $date "."]
      set date [lindex $d 0]
      #regsub -all {\.} $date {_}  date
   
    
      #Type
      if {$::av4l_analysis_gui::occ_pos_type=="Code UAI"} {
         set pos  "UAI_$::av4l_analysis_gui::occ_pos"
      } else {
         set pos $::av4l_analysis_gui::occ_pos
         regsub -all -- {[[:space:]]+} $pos " " pos
         set pos [split $pos]
         foreach s_el $pos {
            ::console::affiche_resultat  "$s_el\n"
         }
         
         set longw [lindex $pos 0]
         set latn  [lindex $pos 1]
         set nb [regexp -all {\-} $longw]
         if {$nb==0} {
            set nb [regexp -all {\+} $longw]
            if {$nb==0} {
               set longw "+$longw"
            }
         }
         set nb [regexp -all {\-} $latn]
         if {$nb==0} {
            set nb [regexp -all {\+} $latn]
            if {$nb==0} {
               set latn "+$latn"
            }
         }
         
         set pos "LonW${longw}_LatN${latn}"
         
         #set pos [split $::av4l_analysis_gui::occ_pos " "]
         #Tset pos [split $::av4l_analysis_gui::occ_pos " "]
         #Tset longw [lindex $pos 0]
      }
      
      # Nom de l objet
      set name [::av4l_analysis_gui::cleanEntities $::av4l_analysis_gui::occ_obj]
      
      # Construction du fichier
      set filename "${date}_${name}_${pos}"
      #::console::affiche_resultat "FILENAME=$filename\n"


      if { $::av4l::parametres(av4l,$visuNo,dir_prj)!="" } {
         set ::av4l_analysis_gui::prj_dir [file join $::av4l::parametres(av4l,$visuNo,dir_prj) $filename]
      }

      set ::av4l_analysis_gui::prj_file [file join $::av4l_analysis_gui::prj_dir "$filename.atos"]
      set ::av4l_analysis_gui::prj_file_short "$filename.atos"

      set a1 [file exists $::av4l_analysis_gui::prj_file]
      set a2 [file exists $::av4l_analysis_gui::prj_dir]
      
      set msg "Creation du projet.\n"
      if {$a1 == 0} {set msg "${msg}Le fichier projet sera créé.\n"}
      if {$a2 == 0} {set msg "${msg}Le repertoire projet sera créé.\n"}
      if {$a1 == 1 && $a2 == 1} {return}
      
      set res [tk_messageBox -message $msg -type yesno]
      ::console::affiche_resultat "res=$res\n"
      
      if {$res == "no"} {return}
      
      set err [catch {file mkdir $::av4l_analysis_gui::prj_dir} msg]
      if {$err} {
         ::console::affiche_erreur "Erreur creation du repertoire\n"
         ::console::affiche_erreur "DIR=$::av4l_analysis_gui::prj_dir\n"
         ::console::affiche_erreur "ERR=$err\n"
         ::console::affiche_erreur "MSG=$msg\n"
      }
      
      set err [catch {save_project} msg]
      if {$err} {
         ::console::affiche_erreur "Erreur sauvegarde du projet\n"
         ::console::affiche_erreur "ERR=$err\n"
         ::console::affiche_erreur "MSG=$msg\n"
      }
      
      return
   }   

















   #
   # Charge du fichier projet
   #
   proc ::av4l_analysis_gui::load_atos_file { } {


      set pass "yes"
      if {![info exists ::av4l_analysis_gui::prj_file]} {
         set pass "no"
      } else {
         if  {$::av4l_analysis_gui::prj_file==""} {
            set pass "no"
         }
      }
      if {$pass=="no"} {
         tk_messageBox -message "Veuillez selectionner un fichier" -type ok
         return
      }




      set a1 [file exists $::av4l_analysis_gui::prj_file]
      if {$a1 == 0} {
         set res [tk_messageBox -message "Le fichier n'existe pas !" -type yes]
         return -code 0 "no"
      }
      
      source $::av4l_analysis_gui::prj_file
   }   















   #
   # Selection du fichier projet
   #
   proc ::av4l_analysis_gui::select_atos_file { visuNo frm } {

      global audace

      set fenetre [::confVisu::getBase $visuNo]
      set bufNo [ visu$visuNo buf ]
      set ::av4l_analysis_gui::prj_file [ ::tkutil::box_load_atos $frm $::av4l::parametres(av4l,$visuNo,dir_prj) $bufNo "1" ]
      set ::av4l_analysis_gui::prj_file_short [file tail $::av4l_analysis_gui::prj_file]
      set ::av4l_analysis_gui::prj_dir        [file dirname $::av4l_analysis_gui::prj_file]

   }   














#
# Clean special characters into string
# @param string chaine a convertir
# @return chunk chaine convertie
proc ::av4l_analysis_gui::cleanEntities { chunk } {
   regsub -all { }  $chunk {} chunk
   regsub -all {!}  $chunk {} chunk
   regsub -all {#}  $chunk {} chunk
   regsub -all {\$} $chunk {} chunk
   regsub -all {\&} $chunk {} chunk
   regsub -all {'}  $chunk {} chunk
   regsub -all {\(} $chunk {} chunk
   regsub -all {\)} $chunk {} chunk
   regsub -all {\*} $chunk {} chunk
   regsub -all {\+} $chunk {} chunk
   regsub -all {\-} $chunk {} chunk
   regsub -all {,}  $chunk {} chunk
   regsub -all {=}  $chunk {} chunk
   regsub -all {\?} $chunk {} chunk
   regsub -all {@}  $chunk {} chunk
   regsub -all {\[} $chunk {} chunk
   regsub -all {\]} $chunk {} chunk
   regsub -all {\^} $chunk {} chunk
   regsub -all {`}  $chunk {} chunk
   regsub -all {\{} $chunk {} chunk
   regsub -all {\|} $chunk {} chunk
   regsub -all {\}} $chunk {} chunk
   regsub -all {~}  $chunk {} chunk
   regsub -all {:}  $chunk {} chunk
   regsub -all {/}  $chunk {} chunk
   regsub -all {\.} $chunk {} chunk
   return $chunk
}














   #
   # Sauvegarde du fichier projet
   #
   proc ::av4l_analysis_gui::save_project { } {

      set a1 [file exists $::av4l_analysis_gui::prj_file]
      if {$a1 == 1} {
         set res [tk_messageBox -message "Le fichier existe. Voulez vous l'écraser ?" -type yesno]
         if {$res == "no"} {return -code 0 "no"}
      }

      set chan [open $::av4l_analysis_gui::prj_file w]

catch {
      puts $chan "###############################################################"
      puts $chan "#                                                             #"
      puts $chan "#                       A.T.O.S.                              #"
      puts $chan "#                                                             #"
      puts $chan "#    Acquisition et Traitement des Occultations stellaires    #"
      puts $chan "#                                                             #"
      puts $chan "#         Author : frederic.vachier@imcce.fr (2012)           #"
      puts $chan "#                                                             #"
      puts $chan "###############################################################"

      puts $chan "# "
      puts $chan "# Contexte"
      puts $chan "# "
      puts $chan "set ::av4l_analysis_gui::occ_obj        \"$::av4l_analysis_gui::occ_obj\""
      puts $chan "set ::av4l_analysis_gui::occ_date       \"$::av4l_analysis_gui::occ_date\""
      puts $chan "set ::av4l_analysis_gui::occ_pos        \"$::av4l_analysis_gui::occ_pos\""
      puts $chan "set ::av4l_analysis_gui::occ_pos_type   \"$::av4l_analysis_gui::occ_pos_type\""
      puts $chan "set ::av4l_analysis_gui::occ_obj_name   \"$::av4l_analysis_gui::occ_obj_name\""
      puts $chan "set ::av4l_analysis_gui::occ_obj_id     \"$::av4l_analysis_gui::occ_obj_id\""

      puts $chan "# "
      puts $chan "# Fichiers & Repertoires"
      puts $chan "# "
      puts $chan "set ::av4l_analysis_gui::prj_file_short \"$::av4l_analysis_gui::prj_file_short\""
      puts $chan "set ::av4l_analysis_gui::prj_file       \"$::av4l_analysis_gui::prj_file\""
      puts $chan "set ::av4l_analysis_gui::prj_dir        \"$::av4l_analysis_gui::prj_dir\""
      
      puts $chan "# "
      puts $chan "# Ephemerides"
      puts $chan "# "
      puts $chan "set ::av4l_analysis_gui::jd         \"$::av4l_analysis_gui::jd\""  
      puts $chan "set ::av4l_analysis_gui::rajapp     \"$::av4l_analysis_gui::rajapp\""  
      puts $chan "set ::av4l_analysis_gui::decapp     \"$::av4l_analysis_gui::decapp\""
      puts $chan "set ::av4l_analysis_gui::dist       \"$::av4l_analysis_gui::dist\""
      puts $chan "set ::av4l_analysis_gui::magv       \"$::av4l_analysis_gui::magv\""
      puts $chan "set ::av4l_analysis_gui::phase      \"$::av4l_analysis_gui::phase\""
      puts $chan "set ::av4l_analysis_gui::elong      \"$::av4l_analysis_gui::elong\""
      puts $chan "set ::av4l_analysis_gui::dracosd    \"$::av4l_analysis_gui::dracosd\""
      puts $chan "set ::av4l_analysis_gui::ddec       \"$::av4l_analysis_gui::ddec\""
      puts $chan "set ::av4l_analysis_gui::vn         \"$::av4l_analysis_gui::vn\""
      puts $chan "set ::av4l_analysis_gui::tsl        \"$::av4l_analysis_gui::tsl\""
      puts $chan "set ::av4l_analysis_gui::raj2000    \"$::av4l_analysis_gui::raj2000\""
      puts $chan "set ::av4l_analysis_gui::decj2000   \"$::av4l_analysis_gui::decj2000\""
      puts $chan "set ::av4l_analysis_gui::hourangle  \"$::av4l_analysis_gui::hourangle\""
      puts $chan "set ::av4l_analysis_gui::decapp     \"$::av4l_analysis_gui::decapp\""
      puts $chan "set ::av4l_analysis_gui::azimuth    \"$::av4l_analysis_gui::azimuth\""
      puts $chan "set ::av4l_analysis_gui::hauteur    \"$::av4l_analysis_gui::hauteur\""
      puts $chan "set ::av4l_analysis_gui::airmass    \"$::av4l_analysis_gui::airmass\""
      puts $chan "set ::av4l_analysis_gui::dhelio     \"$::av4l_analysis_gui::dhelio\""

      puts $chan "# "
      puts $chan "# Corrections courbe"
      puts $chan "# "
      puts $chan "set ::av4l_analysis_gui::raw_filename_short \"$::av4l_analysis_gui::raw_filename_short\""
      puts $chan "set ::av4l_analysis_gui::raw_filename       \"$::av4l_analysis_gui::raw_filename\""
      puts $chan "set ::av4l_analysis_gui::raw_integ_offset   \"$::av4l_analysis_gui::raw_integ_offset\""
      puts $chan "set ::av4l_analysis_gui::raw_integ_nb_img   \"$::av4l_analysis_gui::raw_integ_nb_img\""
      puts $chan "set ::av4l_analysis_gui::int_corr           \"$::av4l_analysis_gui::int_corr\""
      puts $chan "set ::av4l_analysis_gui::tps_corr           \"$::av4l_analysis_gui::tps_corr\""
      puts $chan "set ::av4l_analysis_gui::theo_expo          \"$::av4l_analysis_gui::theo_expo\""
      puts $chan "set ::av4l_analysis_gui::time_offset        \"$::av4l_analysis_gui::time_offset\""
      puts $chan "set ::av4l_analysis_gui::ref_corr           \"$::av4l_analysis_gui::ref_corr\""

      puts $chan "# "
      puts $chan "# Evenements"
      puts $chan "# "
      puts $chan "set ::av4l_analysis_gui::corr_filename_short        \"$::av4l_analysis_gui::corr_filename_short\""
      puts $chan "set ::av4l_analysis_gui::corr_filename              \"$::av4l_analysis_gui::corr_filename\""
      puts $chan "set ::av4l_analysis_tools::id_p1                    \"$::av4l_analysis_tools::id_p1\""
      puts $chan "set ::av4l_analysis_tools::corr_duree_e1            \"$::av4l_analysis_tools::corr_duree_e1\""
      puts $chan "set ::av4l_analysis_tools::nb_p1                    \"$::av4l_analysis_tools::nb_p1\""
      puts $chan "set ::av4l_analysis_gui::duree_max_immersion_search \"$::av4l_analysis_gui::duree_max_immersion_search\""
      puts $chan "set ::av4l_analysis_tools::id_p2                    \"$::av4l_analysis_tools::id_p2\""
      puts $chan "set ::av4l_analysis_tools::corr_duree_e2            \"$::av4l_analysis_tools::corr_duree_e2\""
      puts $chan "set ::av4l_analysis_tools::nb_p2                    \"$::av4l_analysis_tools::nb_p2\""
      puts $chan "set ::av4l_analysis_tools::id_p3                    \"$::av4l_analysis_tools::id_p3\""
      puts $chan "set ::av4l_analysis_tools::corr_duree_e3            \"$::av4l_analysis_tools::corr_duree_e3\""
      puts $chan "set ::av4l_analysis_tools::nb_p3                    \"$::av4l_analysis_tools::nb_p3\""
      puts $chan "set ::av4l_analysis_gui::duree_max_emersion_search  \"$::av4l_analysis_gui::duree_max_emersion_search\""
      puts $chan "set ::av4l_analysis_tools::id_p4                    \"$::av4l_analysis_tools::id_p4\""
      puts $chan "set ::av4l_analysis_tools::corr_duree_e4            \"$::av4l_analysis_tools::corr_duree_e4\""
      puts $chan "set ::av4l_analysis_tools::nb_p4                    \"$::av4l_analysis_tools::nb_p4\""
      puts $chan "set ::av4l_analysis_tools::id_p5                    \"$::av4l_analysis_tools::id_p5\""
      puts $chan "set ::av4l_analysis_tools::corr_duree_e5            \"$::av4l_analysis_tools::corr_duree_e5\""
      puts $chan "set ::av4l_analysis_tools::nb_p5                    \"$::av4l_analysis_tools::nb_p5\""
      puts $chan "set ::av4l_analysis_gui::duree_max_immersion_evnmt  \"$::av4l_analysis_gui::duree_max_immersion_evnmt\""
      puts $chan "set ::av4l_analysis_tools::id_p6                    \"$::av4l_analysis_tools::id_p6\""
      puts $chan "set ::av4l_analysis_gui::date_immersion             \"$::av4l_analysis_gui::date_immersion\""
      puts $chan "set ::av4l_analysis_gui::duree_max_emersion_evnmt   \"$::av4l_analysis_gui::duree_max_emersion_evnmt\""
      puts $chan "set ::av4l_analysis_tools::id_p7                    \"$::av4l_analysis_tools::id_p7\""       
      puts $chan "set ::av4l_analysis_gui::date_emersion              \"$::av4l_analysis_gui::date_emersion\"" 

      puts $chan "# "
      puts $chan "# Parametres"
      puts $chan "# "
      puts $chan "set ::av4l_analysis_gui::width             \"$::av4l_analysis_gui::width\""
      puts $chan "set ::av4l_analysis_gui::occ_star_name     \"$::av4l_analysis_gui::occ_star_name\""
      puts $chan "set ::av4l_analysis_gui::occ_star_B        \"$::av4l_analysis_gui::occ_star_B\""
      puts $chan "set ::av4l_analysis_gui::occ_star_V        \"$::av4l_analysis_gui::occ_star_V\""
      puts $chan "set ::av4l_analysis_gui::occ_star_K        \"$::av4l_analysis_gui::occ_star_K\""
      puts $chan "set ::av4l_analysis_gui::occ_star_size_mas \"$::av4l_analysis_gui::occ_star_size_mas\""
      puts $chan "set ::av4l_analysis_gui::occ_star_size_km  \"$::av4l_analysis_gui::occ_star_size_km\""
      puts $chan "set ::av4l_analysis_gui::wvlngth           \"$::av4l_analysis_gui::wvlngth\""
      puts $chan "set ::av4l_analysis_gui::dlambda           \"$::av4l_analysis_gui::dlambda\""
      puts $chan "set ::av4l_analysis_tools::irep            \"$::av4l_analysis_tools::irep\""
      puts $chan "set ::av4l_analysis_gui::nheure            \"$::av4l_analysis_gui::nheure\""
      puts $chan "set ::av4l_analysis_gui::pas_heure         \"$::av4l_analysis_gui::pas_heure\""
      puts $chan "set ::av4l_analysis_tools::corr_exposure   \"$::av4l_analysis_tools::corr_exposure\""
      puts $chan "set ::av4l_analysis_gui::date_begin_obs    \"$::av4l_analysis_gui::date_begin_obs\""
      puts $chan "set ::av4l_analysis_gui::date_end_obs      \"$::av4l_analysis_gui::date_end_obs\""

      puts $chan "# "
      puts $chan "# Immersion & Emersion"
      puts $chan "# "
      puts $chan "set ::av4l_analysis_gui::date_immersion_sol \"$::av4l_analysis_gui::date_immersion_sol\""
      puts $chan "set ::av4l_analysis_gui::im_chi2_min        \"$::av4l_analysis_gui::im_chi2_min\""
      puts $chan "set ::av4l_analysis_gui::im_nfit_chi2_min   \"$::av4l_analysis_gui::im_nfit_chi2_min\""
      puts $chan "set ::av4l_analysis_gui::im_t0_chi2_min     \"$::av4l_analysis_gui::im_t0_chi2_min\""
      puts $chan "set ::av4l_analysis_gui::im_t_inf           \"$::av4l_analysis_gui::im_t_inf\""
      puts $chan "set ::av4l_analysis_gui::im_t_sup           \"$::av4l_analysis_gui::im_t_sup\""
      puts $chan "set ::av4l_analysis_gui::im_t_diff          \"$::av4l_analysis_gui::im_t_diff\""
      puts $chan "set ::av4l_analysis_gui::im_t_inf_3s        \"$::av4l_analysis_gui::im_t_inf_3s\""
      puts $chan "set ::av4l_analysis_gui::im_t_sup_3s        \"$::av4l_analysis_gui::im_t_sup_3s\""
      puts $chan "set ::av4l_analysis_gui::im_t_diff_3s       \"$::av4l_analysis_gui::im_t_diff_3s\""
      puts $chan "set ::av4l_analysis_gui::date_emersion_sol  \"$::av4l_analysis_gui::date_emersion_sol\""
      puts $chan "set ::av4l_analysis_gui::em_chi2_min        \"$::av4l_analysis_gui::em_chi2_min\""
      puts $chan "set ::av4l_analysis_gui::em_nfit_chi2_min   \"$::av4l_analysis_gui::em_nfit_chi2_min\""
      puts $chan "set ::av4l_analysis_gui::em_t0_chi2_min     \"$::av4l_analysis_gui::em_t0_chi2_min\""
      puts $chan "set ::av4l_analysis_gui::em_t_inf           \"$::av4l_analysis_gui::em_t_inf\""
      puts $chan "set ::av4l_analysis_gui::em_t_sup           \"$::av4l_analysis_gui::em_t_sup\""
      puts $chan "set ::av4l_analysis_gui::em_t_diff          \"$::av4l_analysis_gui::em_t_diff\""
      puts $chan "set ::av4l_analysis_gui::em_t_inf_3s        \"$::av4l_analysis_gui::em_t_inf_3s\""
      puts $chan "set ::av4l_analysis_gui::em_t_sup_3s        \"$::av4l_analysis_gui::em_t_sup_3s\""
      puts $chan "set ::av4l_analysis_gui::em_t_diff_3s       \"$::av4l_analysis_gui::em_t_diff_3s\""

      puts $chan "set ::av4l_analysis_gui::bande       \"$::av4l_analysis_gui::bande\""
      puts $chan "set ::av4l_analysis_gui::duree       \"$::av4l_analysis_gui::duree\""
      puts $chan "set ::av4l_analysis_gui::result      \"$::av4l_analysis_gui::result\""

      puts $chan "# "
      puts $chan "# Contacts"
      puts $chan "# "
      puts $chan "set ::av4l_analysis_gui::occ_observers  \"$::av4l_analysis_gui::occ_observers\""
      puts $chan "set ::av4l_analysis_gui::prj_reduc      \"$::av4l_analysis_gui::prj_reduc\""
      puts $chan "set ::av4l_analysis_gui::prj_mail       \"$::av4l_analysis_gui::prj_mail\""
      puts $chan "set ::av4l_analysis_gui::prj_phone      \"$::av4l_analysis_gui::prj_phone\""
      puts $chan "set ::av4l_analysis_gui::prj_address    \"$::av4l_analysis_gui::prj_address\""

      puts $chan "# "
      puts $chan "# Station"
      puts $chan "# "
      puts $chan "set ::av4l_analysis_gui::type1_station  \"$::av4l_analysis_gui::type1_station\""
      puts $chan "set ::av4l_analysis_gui::latitude       \"$::av4l_analysis_gui::latitude\""
      puts $chan "set ::av4l_analysis_gui::longitude      \"$::av4l_analysis_gui::longitude\""
      puts $chan "set ::av4l_analysis_gui::altitude       \"$::av4l_analysis_gui::altitude\""
      puts $chan "set ::av4l_analysis_gui::datum          \"$::av4l_analysis_gui::datum\""
      puts $chan "set ::av4l_analysis_gui::nearest_city   \"$::av4l_analysis_gui::nearest_city\""
      puts $chan "set ::av4l_analysis_gui::type2_station  \"$::av4l_analysis_gui::type2_station\""

      puts $chan "# "
      puts $chan "# Telescope"
      puts $chan "# "
      puts $chan "set ::av4l_analysis_gui::telescop_type  \"$::av4l_analysis_gui::telescop_type\""
      puts $chan "set ::av4l_analysis_gui::telescop_aper  \"$::av4l_analysis_gui::telescop_aper\""
      puts $chan "set ::av4l_analysis_gui::telescop_magn  \"$::av4l_analysis_gui::telescop_magn\""
      puts $chan "set ::av4l_analysis_gui::telescop_moun  \"$::av4l_analysis_gui::telescop_moun\""
      puts $chan "set ::av4l_analysis_gui::telescop_moto  \"$::av4l_analysis_gui::telescop_moto\""

      puts $chan "# "
      puts $chan "# Acquisition"
      puts $chan "# "
      puts $chan "set ::av4l_analysis_gui::record_evin    \"$::av4l_analysis_gui::record_evin\""
      puts $chan "set ::av4l_analysis_gui::record_time    \"$::av4l_analysis_gui::record_time\""
      puts $chan "set ::av4l_analysis_gui::record_sens    \"$::av4l_analysis_gui::record_sens\""
      puts $chan "set ::av4l_analysis_gui::record_prod    \"$::av4l_analysis_gui::record_prod\""
      puts $chan "set ::av4l_analysis_gui::record_tiin    \"$::av4l_analysis_gui::record_tiin\""
      puts $chan "set ::av4l_analysis_gui::record_comp    \"$::av4l_analysis_gui::record_comp\""

      puts $chan "# "
      puts $chan "# Conditions"
      puts $chan "# "
      puts $chan "set ::av4l_analysis_gui::obscond_tran   \"$::av4l_analysis_gui::obscond_tran\""
      puts $chan "set ::av4l_analysis_gui::obscond_wind   \"$::av4l_analysis_gui::obscond_wind\""
      puts $chan "set ::av4l_analysis_gui::obscond_temp   \"$::av4l_analysis_gui::obscond_temp\""
      puts $chan "set ::av4l_analysis_gui::obscond_stab   \"$::av4l_analysis_gui::obscond_stab\""
      puts $chan "set ::av4l_analysis_gui::obscond_visi   \"$::av4l_analysis_gui::obscond_visi\""

      puts $chan "# "
      puts $chan "# Comments"
      puts $chan "# "
      #puts $chan "set ::av4l_analysis_gui::comments   \"$::av4l_analysis_gui::comments\""
      #puts $chan "$::av4l_analysis_gui::gui_comment.v insert 0 end \"$::av4l_analysis_gui::comments\""
      set a [split [$::av4l_analysis_gui::gui_comment.v get 1.0 end] "\n" ]
      set newl "$::av4l_analysis_gui::gui_comment.v insert end \""
      foreach line $a {
         gren_info "$line\n"
         if {[string bytelength [string trim $line]]==0} {continue}
         append newl "[string trim $line]\\n"
      }
      puts $chan "$::av4l_analysis_gui::gui_comment.v delete 1.0 end "
      puts $chan "$newl\""

}
      
      close $chan
      
      return -code 0 "ok"
   }   

















   #
   # Sauvegarde du fichier projet
   #
   proc ::av4l_analysis_gui::save_planoccult { } {

      set file [file join $::av4l_analysis_gui::prj_dir "$::av4l_analysis_gui::prj_file_short.PLANOCCULT"]
      if {[file exists $file]} {
         set res [tk_messageBox -message "Le Rapport PLANOCCULT existe. Voulez vous l'écraser ?" -type yesno]
         if {$res == "no"} {return -code 0 "no"}
      }


      # Was your reaction time applied to the above timings ?
      if {$::av4l_analysis_gui::tps_corr} {
         set reaction_time "YES"
      } else {
         set reaction_time "NO"
      }

      # Constantes 
      set ::av4l_analysis_gui::type2_station   "Single"
      set ::av4l_analysis_gui::record_evin ""

      # A Calculer  
      set obscond_alti [format "%+d deg" [lindex [split $::av4l_analysis_gui::hauteur ":"] 0] ]
      set occ_date_short [lindex [split $::av4l_analysis_gui::date_immersion_sol "T"] 0]

      # debut obs
      set datetmp [lindex [split $::av4l_analysis_gui::date_begin_obs "T"] 1]
      set datetmp [split $datetmp ":"]
      set hs  [lindex $datetmp 0]
      set ms  [lindex $datetmp 1]
      set ss  [lindex $datetmp 2]

      # immersion
      set datetmp [lindex [split $::av4l_analysis_gui::date_immersion_sol "T"] 1]
      set datetmp [split $datetmp ":"]
      set hd  [lindex $datetmp 0]
      set md  [lindex $datetmp 1]
      set sd  [lindex $datetmp 2]

      # emersion
      set datetmp [lindex [split $::av4l_analysis_gui::date_emersion_sol "T"] 1]
      set datetmp [split $datetmp ":"]
      set hr  [lindex $datetmp 0]
      set mr  [lindex $datetmp 1]
      set sr  [lindex $datetmp 2]

      # fin obs
      set datetmp [lindex [split $::av4l_analysis_gui::date_end_obs "T"] 1]
      set datetmp [split $datetmp ":"]
      set he  [lindex $datetmp 0]
      set me  [lindex $datetmp 1]
      set se  [lindex $datetmp 2]

      # incertitude imm et em
      set ad  $::av4l_analysis_gui::im_t_diff
      set ar  $::av4l_analysis_gui::em_t_diff
      # duree integration
      set int $::av4l_analysis_tools::corr_exposure
      # mid evenement
      set midevent  [mc_date2iso8601 [expr ([mc_date2jd $::av4l_analysis_gui::date_emersion_sol]+[mc_date2jd $::av4l_analysis_gui::date_immersion_sol])/2.0] ]
      # Commentaires
      set comments "8 frame integration used (Watec setting 4 Slow) Codec use for grab : No recompression YUY2"
      set comments [$::av4l_analysis_gui::gui_comment.v get 1.0 end]


# Ecriture du rapport

      set chan [open $file w]

      puts $chan "                   ASTEROIDAL OCCULTATION - REPORT FORM               "
      puts $chan "                                                                      "
      puts $chan "    +------------------------------+  +------------------------------+"
      puts $chan "    |            EAON              |  |            IOTA/ES           |"
      puts $chan "    |                              |  |   INTERNATIONAL OCCULTATION  |"
      puts $chan "    |     EUROPEAN  ASTEROIDAL     |  |      TIMING  ASSOCIATION     |"
      puts $chan "    |     OCCULTATION NETWORK      |  |       EUROPEAN SECTION       |"
      puts $chan "    +------------------------------+  +------------------------------+"
      puts $chan ""

      puts $chan [format "1 DATE: %s                   STAR: %s" $occ_date_short $::av4l_analysis_gui::occ_star_name]
      puts $chan [format "  ASTEROID: %-25s  No: %s" $::av4l_analysis_gui::occ_obj_name $::av4l_analysis_gui::occ_obj_id]
      puts $chan ""
      puts $chan [format "2 OBSERVER: Name: %s"    $::av4l_analysis_gui::occ_observers]
      puts $chan [format "            Phone: %s"   $::av4l_analysis_gui::prj_phone]
      puts $chan [format "            E-mail: %s"  $::av4l_analysis_gui::prj_mail]
      puts $chan [format "            Address: %s" $::av4l_analysis_gui::prj_address]
      puts $chan ""
      puts $chan [format "3 OBSERVING STATION: Nearest city: %s" $::av4l_analysis_gui::nearest_city]
      puts $chan [format "  Station:  %s"                        $::av4l_analysis_gui::type1_station]
      puts $chan [format "  Latitude:  %s"                       $::av4l_analysis_gui::latitude]
      puts $chan [format "  Longitude: %s"                       $::av4l_analysis_gui::longitude]
      puts $chan [format "  Altitude: %s"                        $::av4l_analysis_gui::altitude]
      puts $chan [format "  Datum (WGS84 preferred): %s"         $::av4l_analysis_gui::datum]
      puts $chan ""
      puts $chan [format "  Single, OR Double or Multiple station (Specify observer's name): %s" $::av4l_analysis_gui::type2_station]
      puts $chan ""
      puts $chan "                         +----------------------------------+"
      puts $chan "4 TIMING OF EVENTS:      |                                  |"
      puts $chan [format "                         |  OCCULTATION RECORDED: %8s  |"  $::av4l_analysis_gui::result]
      puts $chan "                         |                                  |"
      puts $chan "                         +----------------------------------+"
      puts $chan "  Type of event"
      puts $chan "  Start observation   Interrupt-start   Disappearance   Blink   Flash"
      puts $chan "  End observation     Interrupt-end     Reappearance    Other (specify)"
      puts $chan ""
      puts $chan "                                                  Comments"
      puts $chan "  Event   Time (UT)    P.E.   Acc."
      puts $chan "  Code   HH MM SS.ss   S.ss   S.ss"
      puts $chan ""
      puts $chan [format "    S  - %2d %2d %s   -      -         :" $hs $ms $ss] 
      puts $chan "       -                -      -         :"
      puts $chan [format "    D  - %2d %2d %s   -     %.3f      :  Video integration %.3f s" $hd $md $sd $ad $int]
      puts $chan [format "    R  - %2d %2d %s   -     %.3f      :  Video integration %.3f s" $hr $mr $sr $ar $int]
      puts $chan "       -                -      -         :"
      puts $chan [format "    E  - %2d %2d %s   -      -         :" $he $me $se]
      puts $chan ""
      puts $chan [format "                          Duration : %.3f s" $::av4l_analysis_gui::duree]
      puts $chan [format "                         Mid-event : %s UTC" $midevent]
      puts $chan [format "                             Width : %s km" $::av4l_analysis_gui::bande]
      puts $chan ""
      puts $chan "  Was your reaction time applied to the above timings? $reaction_time"
      puts $chan ""
      puts $chan "5 TELESCOPE:"
      puts $chan "    Type:          $::av4l_analysis_gui::telescop_type"
      puts $chan "    Aperture:      $::av4l_analysis_gui::telescop_aper"
      puts $chan "    Magnification: $::av4l_analysis_gui::telescop_magn"
      puts $chan "    Mount:         $::av4l_analysis_gui::telescop_moun"
      puts $chan "    Motor drive:   $::av4l_analysis_gui::telescop_moto"
      puts $chan ""
      puts $chan "6 TIMING & RECORDING:"
      puts $chan "    Time source:               $::av4l_analysis_gui::record_time"
      puts $chan "    Sensor:                    $::av4l_analysis_gui::record_sens"
      puts $chan "    Recording:                 $::av4l_analysis_gui::record_prod"
      puts $chan "    Time  insertion (specify): $::av4l_analysis_gui::record_tiin"
      puts $chan "    Event insertion (specify): $::av4l_analysis_gui::record_evin"
      puts $chan "    Compression:               $::av4l_analysis_gui::record_comp"
      puts $chan "    Software Reduction:        Audela/ATOS"
      puts $chan ""
      puts $chan "7 OBSERVING CONDITIONS:"
      puts $chan "    Atmospheric transparency: $::av4l_analysis_gui::obscond_tran"
      puts $chan "    Wind:                     $::av4l_analysis_gui::obscond_wind"
      puts $chan "    Temperature:              $::av4l_analysis_gui::obscond_temp"
      puts $chan "    Star image stability:     $::av4l_analysis_gui::obscond_stab"
      puts $chan "    Altitude:                 $obscond_alti"
      puts $chan "    Minor planet visible:     $::av4l_analysis_gui::obscond_visi"
      puts $chan ""
      puts $chan "8 ADDITIONAL COMMENTS: "
      set a [split $comments "\n" ]
      foreach line $a {
         puts $chan "     $line"
      }
      
      close $chan
      
      return -code 0 "ok"
   }   

















   #
   # Appel a Miriade pour recuperer quelques informations
   #
   proc ::av4l_analysis_gui::calcul_taille_etoile { frm } {


      set B $::av4l_analysis_gui::occ_star_B
      set V $::av4l_analysis_gui::occ_star_V
      set K $::av4l_analysis_gui::occ_star_K
      set D $::av4l_analysis_gui::dist
      
      set res [::av4l_analysis_tools::diametre_stellaire $B $V $K $D]

      set ::av4l_analysis_gui::occ_star_size_mas  [format "%.2f" [expr [lindex $res 0] * 1000.] ]
      set ::av4l_analysis_gui::occ_star_size_km   [format "%.4f" [lindex $res 1] ]

   }   



   proc ::av4l_analysis_gui::good_sexa { d m s prec } {

      set d [expr int($d)]
      set m [expr int($m)]
      set sa [expr int($s)]
      if {$prec==0} {
         return [format "%02d:%02d:%02d" $d $m $sa]
      }
      set ms [expr int(($s - $sa) * pow(10,$prec))]
      return [format "%02d:%02d:%02d.%0${prec}d" $d $m $sa $ms]
   }   



# ::av4l_analysis_gui::set_object_name "# Asteroide     80 Sappho"

   proc ::av4l_analysis_gui::set_object_name { line } {

      regsub -all -- {[[:space:]]+} $line " " line
      set line [split $line]
      set cpt 0
      set name ""
      foreach s_el $line {
         if {$cpt>2} {append name $s_el}
         incr cpt
      }
      regsub -all { }  $name {_} name

      set ::av4l_analysis_gui::occ_obj "[lindex $line 2]_$name"
      set ::av4l_analysis_gui::occ_obj_name $name
      set ::av4l_analysis_gui::occ_obj_type [lindex $line 1]     
      set ::av4l_analysis_gui::occ_obj_id   [lindex $line 2]     

      #::console::affiche_resultat  "obj = $::av4l_analysis_gui::occ_obj \n"
      #::console::affiche_resultat  "name = $::av4l_analysis_gui::occ_obj_name \n"
      #::console::affiche_resultat  "type = $::av4l_analysis_gui::occ_obj_type \n"
      #::console::affiche_resultat  "id = $::av4l_analysis_gui::occ_obj_id \n"
      ::console::affiche_resultat  "$::av4l_analysis_gui::occ_obj_type $::av4l_analysis_gui::occ_obj_id $::av4l_analysis_gui::occ_obj_name \n"

   }


   #
   # Appel a Miriade pour recuperer quelques informations
   #
   proc ::av4l_analysis_gui::miriade { } {


      # Verif
      set pass "yes"
      if {![info exists ::av4l_analysis_gui::occ_date]} {
         set pass "no"
      } else {
         if  {$::av4l_analysis_gui::occ_date==""} {
            set pass "no"
         }
      }
      if {![info exists ::av4l_analysis_gui::occ_obj_name]} {
         set pass "no"
      } else {
         if  {$::av4l_analysis_gui::occ_obj_name==""} {
            set pass "no"
         }
      }
      if {![info exists ::av4l_analysis_gui::occ_pos]} {
         set pass "no"
      } else {
         if  {$::av4l_analysis_gui::occ_pos==""} {
            set pass "no"
         }
      }
      if {$pass=="no"} {
         tk_messageBox -message "Veuillez entrer des valeurs valides pour les champs objet, date et localisation" -type ok
         return
      }

      #
      set jd [mc_date2jd $::av4l_analysis_gui::occ_date]
      #set ::av4l_analysis_gui::occ_date [mc_date2iso8601 $jd]
      set ::av4l_analysis_gui::jd $jd
     
      set cmd1 "vo_miriade_ephemcc \"$::av4l_analysis_gui::occ_obj_name\" \"\" $jd 1 \"1d\" \"UTC\" \"$::av4l_analysis_gui::occ_pos\" \"INPOP\" 2 1 1 \"text\" \"--jd\" 0"
      set cmd5 "vo_miriade_ephemcc \"$::av4l_analysis_gui::occ_obj_name\" \"\" $jd 1 \"1d\" \"UTC\" \"$::av4l_analysis_gui::occ_pos\" \"INPOP\" 2 5 1 \"text\" \"--jd,--rv\" 0"
      #::console::affiche_resultat "CMD MIRIADE=$cmd1\n"
      #::console::affiche_resultat "CMD MIRIADE=$cmd5\n"
      set textraw1 [vo_miriade_ephemcc "$::av4l_analysis_gui::occ_obj_name" "" $jd 1 "1d" "UTC" "$::av4l_analysis_gui::occ_pos" "INPOP" 2 1 1 "text" "--jd" 0]
      set textraw5 [vo_miriade_ephemcc "$::av4l_analysis_gui::occ_obj_name" "" $jd 1 "1d" "UTC" "$::av4l_analysis_gui::occ_pos" "INPOP" 2 5 1 "text" "--jd" 0]
      set text1 [split $textraw1 ";"]
      set text5 [split $textraw5 ";"]
      
      set nbl [llength $text1]
      if {$nbl == 1} {
         set res [tk_messageBox -message "L'appel aux ephemerides a echouer.\nVerifier le nom de l'objet.\nLa commande s'affiche dans la console" -type ok]
         ::console::affiche_erreur "CMD MIRIADE=$cmd1\n"
         return      
      }
      set nbl [llength $text5]
      if {$nbl == 1} {
         set res [tk_messageBox -message "L'appel aux ephemerides a echouer.\nVerifier le nom de l'objet.\nLa commande s'affiche dans la console" -type ok]
         ::console::affiche_erreur "CMD MIRIADE=$cmd5\n"
         return      
      }

      # Sauvegarde des fichiers intermediaires
      set file [file join $::av4l_analysis_gui::prj_dir "miriade.1"]
      set chan [open $file w]
      foreach line $text1 {
         puts $chan $line
      }
      close $chan
      set file [file join $::av4l_analysis_gui::prj_dir "miriade.5"]
      set chan [open $file w]
      foreach line $text5 {
         puts $chan $line
      }
      close $chan

      # Recupere la position de l'observateur
      foreach t $text1 {
         if { [regexp {.*(\d+) h +(\d+) m +(\d+)\.(\d+) s (.+?).* (\d+) d +(\d+) ' +(\d+)\.(\d+) " +(.+?).* ([-+]?\d*\.?\d*) m.*} $t str loh lom los loms lowe lad lam las lams lans alt] } {
            # "
            set ::av4l_analysis_gui::longitude [format "%s %02d %02d %02d.%03d" $lowe $loh $lom $los $loms ]
            set ::av4l_analysis_gui::latitude  [format "%s %02d %02d %02d.%03d" $lans $lad $lam $las $lams ]
            set ::av4l_analysis_gui::altitude  $alt
         }      
      }

      # Maj du nom de l asteroide      
      set ast [lindex $text1 2]
      if {$ast != ""} {
         ::av4l_analysis_gui::set_object_name $ast
      } else {
         set res [tk_messageBox -message "Le nom de l'objet n'est pas reconnu par Miriade.\nLe resultat de la commande s'affiche dans la console" -type ok]
         ::console::affiche_erreur "CMD MIRIADE=$cmd1\n"
         set cpt 0
         foreach line $text1 {
            ::console::affiche_erreur "($cpt)=$line\n"
            incr cpt
         }
         return               
      }

      # Interpretation appel format num 1
      set cpt 0
      foreach line $text1 {
         set char [string index [string trim $line] 0]
         #::console::affiche_resultat "ephemcc 1 ($cpt) ($char)=$line\n"
         if {$char!="#"} { break }
         incr cpt
      }
      #::console::affiche_resultat "cptdata = $cpt\n"
      # on split la la ligne pour retrouver les valeurs
      set line [lindex $text1 $cpt]
      regsub -all -- {[[:space:]]+} $line " " line
      set line [split $line]
      set cpt 0
      #foreach s_el $line {
      #   ::console::affiche_resultat  "($cpt) $s_el\n"
      #   incr cpt
      #}
      # on affecte les varaibles
      set ::av4l_analysis_gui::rajapp   [::av4l_analysis_gui::good_sexa [lindex $line  2] [lindex $line  3] [lindex $line  4] 2]
      set ::av4l_analysis_gui::decapp   [::av4l_analysis_gui::good_sexa [lindex $line  5] [lindex $line  6] [lindex $line  7] 2]
      set ::av4l_analysis_gui::dist     [format "%.5f" [lindex $line 8]]
      set ::av4l_analysis_gui::magv     [lindex $line 9]
      set ::av4l_analysis_gui::phase    [lindex $line 10]
      set ::av4l_analysis_gui::elong    [lindex $line 11]
      set ::av4l_analysis_gui::dracosd  [format "%.5f" [expr [lindex $line 12] * 60. ] ]
      set ::av4l_analysis_gui::ddec     [format "%.5f" [expr [lindex $line 13] * 60. ] ]
      set ::av4l_analysis_gui::vn       [lindex $line 14]

      # Interpretation appel format num 5
      set cpt 0
      foreach line $text5 {
         set char [string index [string trim $line] 0]
         #::console::affiche_resultat "ephemcc 5 ($cpt) ($char)=$line\n"
         if {$char!="#"} { break }
         incr cpt
      }
      #::console::affiche_resultat "cptdata = $cpt\n"
      
      # on split la la ligne pour retrouver les valeurs
      set line [lindex $text5 $cpt]
      regsub -all -- {[[:space:]]+} $line " " line
      set line [split $line]
      set cpt 0
      #foreach s_el $line {
      #   ::console::affiche_resultat  "($cpt) $s_el\n"
      #   incr cpt
      #}
      
      set tsl [mc_angle2hms [expr [lindex $line 2] * 15.] ]
      set ::av4l_analysis_gui::tsl       [::av4l_analysis_gui::good_sexa [lindex $tsl   0] [lindex $tsl   1] [lindex $tsl   2] 2]
      set ::av4l_analysis_gui::raj2000   [::av4l_analysis_gui::good_sexa [lindex $line  3] [lindex $line  4] [lindex $line  5] 2]
      set ::av4l_analysis_gui::decj2000  [::av4l_analysis_gui::good_sexa [lindex $line  6] [lindex $line  7] [lindex $line  8] 2]
      set ::av4l_analysis_gui::hourangle [::av4l_analysis_gui::good_sexa [lindex $line  9] [lindex $line 10] [lindex $line 11] 2]
      set ::av4l_analysis_gui::decapp    [::av4l_analysis_gui::good_sexa [lindex $line 12] [lindex $line 13] [lindex $line 14] 2]
      set ::av4l_analysis_gui::azimuth   [::av4l_analysis_gui::good_sexa [lindex $line 15] [lindex $line 16] [lindex $line 17] 2]
      set ::av4l_analysis_gui::hauteur   [::av4l_analysis_gui::good_sexa [lindex $line 18] [lindex $line 19] [lindex $line 20] 2]

      set ::av4l_analysis_gui::airmass   [lindex $line 21]
      set ::av4l_analysis_gui::dhelio    [lindex $line 23]
      
   }   












   proc ::av4l_analysis_gui::sendAladinScript { } {

      # Verif
      set pass "yes"
      if {![info exists ::av4l_analysis_gui::raj2000]} {
         set pass "no"
      } else {
         if  {$::av4l_analysis_gui::raj2000==""} {
            set pass "no"
         }
      }
      if {![info exists ::av4l_analysis_gui::decj2000]} {
         set pass "no"
      } else {
         if  {$::av4l_analysis_gui::decj2000==""} {
            set pass "no"
         }
      }
      if {![info exists ::av4l_analysis_gui::jd]} {
         set pass "no"
      } else {
         if  {$::av4l_analysis_gui::jd==""} {
            set pass "no"
         }
      }
      if {$pass=="no"} {
         tk_messageBox -message "Veuillez entrer des valeurs valides pour les champs RA,Dec,date et localisation" -type ok
         return
      }



      # Get parameters
      
      set ra  [expr [mc_angle2deg $::av4l_analysis_gui::raj2000] * 15.]
      set dec [mc_angle2deg $::av4l_analysis_gui::decj2000]
      set radius 10


      set coord "$ra $dec"
      set radius_arcmin "${radius}arcmin"
      set radius_arcsec [concat [expr $radius * 60.0] "arcsec"]
      set date [mc_date2iso8601 $::av4l_analysis_gui::jd]

      if {$::av4l_analysis_gui::occ_pos_type=="Code UAI"} {
         set uaicode  "$::av4l_analysis_gui::occ_pos"
      } else {
         set uaicode  "500"
      }
      
      # Request Skybot cone-search
      set skybotQuery "get SkyBoT.IMCCE($date,$uaicode,'Asteroids and Planets','$radius_arcsec')"

      # Draw a circle to mark the fov center
      set drawFovCenter "draw phot($ra,$dec,20.00arcsec)"
      # Draw USNO stars as triangles
      set getUSNO   "get VizieR(USNO2);   set USNO2  shape=triangle color=blue"
      set getNOMAD1 "get VizieR(NOMAD1);  set NOMAD1 shape=plus     color=red "

      # Aladin Script
      set script "get Aladin(DSS2) ${coord} $radius_arcmin; $getUSNO ; $getNOMAD1 ; sync; $skybotQuery;"
      # Broadcast script
      ::SampTools::broadcastAladinScript $script
   
   }

















}

