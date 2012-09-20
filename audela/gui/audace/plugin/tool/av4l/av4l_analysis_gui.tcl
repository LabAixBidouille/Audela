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












  proc ::av4l_analysis_gui::test_sappho {  } {

     set ::av4l_analysis_gui::wvlngth 0.7500
     set ::av4l_analysis_gui::dlambda 0.4000

     set ::av4l_analysis_gui::dist    1.56
     set ::av4l_analysis_gui::re      2.04
     set ::av4l_analysis_gui::vn      27.800

     set ::av4l_analysis_gui::width   150.0
     set ::av4l_analysis_gui::trans   0.00
     
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
















   proc ::av4l_analysis_gui::open_corr_file { visuNo f5  } {

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
      
      
      ::av4l_analysis_gui::active_graphe $f5.frm.graphe l 1
      
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
         set i [expr int($cpt/2.0)]
         set ::av4l_analysis_tools::id_p6         [expr $id+ $i]
         set ::av4l_analysis_gui::date_immersion  [ mc_date2iso8601 [expr $p($i,x) / 86400.0 + $::av4l_analysis_tools::orig ] ]
      }
      if {$e==7} {
         set i [expr int($cpt/2.0)]
         set ::av4l_analysis_tools::id_p7        [expr $id+ $i]
         set ::av4l_analysis_gui::date_emersion  [ mc_date2iso8601 [expr $p($i,x) / 86400.0 + $::av4l_analysis_tools::orig ] ]
      }

   }





   proc ::av4l_analysis_gui::calcul_evenement { frm e } {

      
      if {$::av4l_analysis_gui::but_calcul=="Stop"} {
         set ::av4l_analysis_tools::but_calcul "Stop"
         return
      }
      $frm configure -image .stop
      set ::av4l_analysis_gui::but_calcul "Stop"

      set ::av4l_analysis_tools::dirwork "/data/Occultations/20100605_80SAPPHO/work2"

      if {$e==-1} {
      
         # Mode immersion
         set ::av4l_analysis_tools::mode -1

         # Longueur d''onde (m)
         set ::av4l_analysis_tools::wvlngth [expr $::av4l_analysis_gui::wvlngth * 1.e-09]

         # Bande passante (m)
         set ::av4l_analysis_tools::dlambda [expr $::av4l_analysis_gui::dlambda * 1.e-09]

         #  Distance a l'anneau (km): distance geocentrique de l objet occulteur
         set ::av4l_analysis_tools::dist  [expr $::av4l_analysis_gui::dist * 149598000.]

         #  Rayon de l'etoile (km)
         set ::av4l_analysis_tools::re $::av4l_analysis_gui::re

         # Vitesse normale de l'etoile (dans plan du ciel, km/s) ???
         # Vitesse relative de l'objet par rapport a la terre (km/s)
         set ::av4l_analysis_tools::vn $::av4l_analysis_gui::vn

         # Largeur de la bande (km)
         # Taille estimée de l'objet (km)
         # si occultation rasante c est la taille de la corde (km)
         set ::av4l_analysis_tools::width $::av4l_analysis_gui::width

         # transmission
         # opaque = 0, sinon demander bruno
         set ::av4l_analysis_tools::trans $::av4l_analysis_gui::trans

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

         # pas en temps (sec)
         set ::av4l_analysis_tools::pas [expr 1.0/$::av4l_analysis_tools::corr_fps]

         # Heure de reference (sec TU)
         set t  [ mc_date2jd $::av4l_analysis_gui::date_immersion]
         set ::av4l_analysis_tools::t0_ref [expr ( $t - $::av4l_analysis_tools::orig ) * 86400.0]
         set ::av4l_analysis_tools::t_milieu [expr $::av4l_analysis_tools::t0_ref  + $::av4l_analysis_tools::width/(2.0*$::av4l_analysis_tools::vn)]

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
      
         set ::av4l_analysis_tools::t0_min [expr $::av4l_analysis_tools::t0_ref - $::av4l_analysis_tools::pas_heure * $::av4l_analysis_tools::nheure / 2.0]
         set ::av4l_analysis_tools::t0_max [expr $::av4l_analysis_tools::t0_ref + $::av4l_analysis_tools::pas_heure * $::av4l_analysis_tools::nheure / 2.0]
         set ::av4l_analysis_tools::t0     $::av4l_analysis_tools::t0_min

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
            $frm configure -image .calc
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
               $frm configure -image .calc
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
         set ::av4l_analysis_tools::evenement_x [list $t $t]
         set ::av4l_analysis_tools::evenement_y [list 0 $::av4l_analysis_tools::med1]

#     2012-01-01T23:41:22.345
#bar  2012-01-01T23:41:22.345

#set t 31.540
#set tf [ mc_date2iso8601 [expr $t / 86400.0 + $::av4l_analysis_tools::orig] ]           
#set x [list $t $t]
#set y [list 0 1000]
#::plotxy::plot $x $y ko 





      }
      
      $frm configure -image .calc
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
         set h3 [::plotxy::plot $::av4l_analysis_tools::evenement_x $::av4l_analysis_tools::evenement_y o]
         plotxy::sethandler $h3 [list -color #00fffc -linewidth 1]
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


   #
   # Creation de l'interface graphique
   #
   proc ::av4l_analysis_gui::createdialog { visuNo this } {

      package require Img

      global caption panneau av4lconf color audace



      set ::av4l_analysis_gui::but_calcul "Calcul"
      set ::av4l_analysis_gui::state_but_graph(1) 0
      set ::av4l_analysis_gui::state_but_graph(2) 0
      set ::av4l_analysis_gui::state_but_graph(3) 0
      set ::av4l_analysis_gui::state_but_graph(20) 0
      set ::av4l_analysis_gui::state_but_graph(21) 0
      set ::av4l_analysis_gui::state_but_graph(22) 0
      set ::av4l_analysis_gui::state_but_graph(23) 0
      set ::av4l_analysis_gui::state_but_graph(24) 0

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


#--- ONGLET : Evenements


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
                     -command "::av4l_analysis_gui::open_corr_file $visuNo $f5"
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
                         
                  #--- Cree un frame
                  frame $events.e6 -borderwidth 0 -cursor arrow
                  pack  $events.e6 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       image create photo .immersion -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_immersion.png ]
                       button $events.e6.but_select -image .immersion -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 6"
                       pack $events.e6.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e6.but_select -text "Selection de l'immersion : prendre un carré serré autour de l'evenement"
                          
                       #--- Cree un label
                       label $events.e6.dendl -text "Date de l'évènement :"
                       pack  $events.e6.dendl -in $events.e6 -side left -anchor w 

                       #--- Cree un label
                       label $events.e6.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_gui::date_immersion
                       pack  $events.e6.dendv -in $events.e6 -side left -anchor e 
                         
                  #--- Cree un frame
                  frame $events.e7 -borderwidth 0 -cursor arrow
                  pack  $events.e7 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       image create photo .emersion -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_emersion.png ]
                       button $events.e7.but_select -image .emersion -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 7"
                       pack $events.e7.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e7.but_select -text "Selection de l'emersion : prendre un carré serré autour de l'evenement"
                          
                       #--- Cree un label
                       label $events.e7.dendl -text "Date de l'évènement :"
                       pack  $events.e7.dendl -in $events.e7 -side left -anchor w 

                       #--- Cree un label
                       label $events.e7.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_gui::date_emersion
                       pack  $events.e7.dendv -in $events.e7 -side left -anchor e 
                         


                      
#---


#--- ONGLET : Vracs


#---




        #--- Cree un frame pour afficher le contenu de l onglet
        set vrac [frame $f4.frm -borderwidth 0 -cursor arrow -relief groove]
        pack $vrac -in $f4 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
        
        

             #--- Cree un frame pour le chargement d'un fichier
             set frmgauche [frame $vrac.frmgauche -borderwidth 0 -cursor arrow -relief groove]
             pack $frmgauche -in $vrac -anchor s -side top -expand 0 -fill x -padx 10 -pady 5



                  #--- Cree un frame pour le chargement d'un fichier
                  set wvlngth [frame $frmgauche.wvlngth -borderwidth 0 -cursor arrow -relief groove]
                  pack $wvlngth -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $wvlngth.l -text "Longueur d'onde (microns) : "
                       pack  $wvlngth.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $wvlngth.v -textvariable ::av4l_analysis_gui::wvlngth -width 10
                       pack $wvlngth.v -side left -padx 3 -pady 1 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set dlambda [frame $frmgauche.dlambda -borderwidth 0 -cursor arrow -relief groove]
                  pack $dlambda -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $dlambda.l -text "Bande passante (microns) : "
                       pack  $dlambda.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $dlambda.v -textvariable ::av4l_analysis_gui::dlambda -width 10
                       pack $dlambda.v -side left -padx 3 -pady 1 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set dist [frame $frmgauche.dist -borderwidth 0 -cursor arrow -relief groove]
                  pack $dist -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $dist.l -text "Distance geocentrique de l objet occulteur (UA) : "
                       pack  $dist.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $dist.v -textvariable ::av4l_analysis_gui::dist -width 10
                       pack $dist.v -side left -padx 3 -pady 1 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set re [frame $frmgauche.re -borderwidth 0 -cursor arrow -relief groove]
                  pack $re -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $re.l -text "Rayon de l'etoile (km) : "
                       pack  $re.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $re.v -textvariable ::av4l_analysis_gui::re -width 10
                       pack $re.v -side left -padx 3 -pady 1 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set vn [frame $frmgauche.vn -borderwidth 0 -cursor arrow -relief groove]
                  pack $vn -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $vn.l -text "Vitesse relative de l'objet par rapport a la terre (km/s) : "
                       pack  $vn.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $vn.v -textvariable ::av4l_analysis_gui::vn -width 10
                       pack $vn.v -side left -padx 3 -pady 1 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set width [frame $frmgauche.width -borderwidth 0 -cursor arrow -relief groove]
                  pack $width -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $width.l -text "Largeur de la bande (km) : "
                       pack  $width.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $width.v -textvariable ::av4l_analysis_gui::width -width 10
                       pack $width.v -side left -padx 3 -pady 1 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set trans [frame $frmgauche.trans -borderwidth 0 -cursor arrow -relief groove]
                  pack $trans -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $trans.l -text "transmission : 0=opaque à 1=transparent  : "
                       pack  $trans.l -side left -anchor e  

                       #--- Cree un label pour le chemin de l'AVI
                       entry $trans.v -textvariable ::av4l_analysis_gui::trans -width 10
                       pack $trans.v -side left -padx 3 -pady 1 -fill x




#---


#--- ONGLET : Immersion


#---

        #--- Cree un frame pour afficher le contenu de l onglet
        set immersion [frame $f5.frm -borderwidth 0 -cursor arrow -relief groove]
        pack $immersion -in $f5 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
        
        
             #--- Cree un frame pour le chargement d'un fichier
             set frmgauche [frame $immersion.frmgauche -borderwidth 0 -cursor arrow -relief groove]
             pack $frmgauche -in $immersion -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                  #--- Cree un frame pour le chargement d'un fichier
                  set duree [frame $frmgauche.duree -borderwidth 0 -cursor arrow -relief groove]
                  pack $duree -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $duree.l -text "Nombre de points mesurés autour l'évenement : "
                       pack  $duree.l -side left -anchor e 

                       #--- Cree un entry ( == ::av4l_analysis_tools::duree)
                       entry $duree.v -textvariable ::av4l_analysis_tools::nb_p2 -width 10
                       pack $duree.v -side left -padx 3 -pady 1 -fill x


                  #--- Cree un frame pour le chargement d'un fichier
                  set t0_ref [frame $frmgauche.t0_ref -borderwidth 0 -cursor arrow -relief groove]
                  pack $t0_ref -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $t0_ref.l -text "Heure de reference (sec TU) : "
                       pack  $t0_ref.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $t0_ref.v -textvariable ::av4l_analysis_gui::date_immersion -width 30
                       pack $t0_ref.v -side left -padx 3 -pady 1 -fill x


                  #--- Cree un frame pour le chargement d'un fichier
                  set nheure [frame $frmgauche.nheure -borderwidth 0 -cursor arrow -relief groove]
                  pack $nheure -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $nheure.l -text "Nombre d'instant a explorer autour de la reference (points) : "
                       pack  $nheure.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $nheure.v -textvariable ::av4l_analysis_gui::nheure -width 10
                       pack $nheure.v -side left -padx 3 -pady 1 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set pas_heure [frame $frmgauche.pas_heure -borderwidth 0 -cursor arrow -relief groove]
                  pack $pas_heure -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $pas_heure.l -text "Pas de recherche de l'instant de l'evenement (sec): "
                       pack  $pas_heure.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $pas_heure.v -textvariable ::av4l_analysis_gui::pas_heure -width 10
                       pack $pas_heure.v -side left -padx 3 -pady 1 -fill x

             #--- Cree un frame pour le chargement d'un fichier
             set calcul [frame $immersion.calcul -borderwidth 0 -cursor arrow -relief groove]
             pack $calcul -in $immersion -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  image create photo .calc -format PNG -file [ file join $audace(rep_plugin) tool av4l img calcul.png ]
                  image create photo .stop -format PNG -file [ file join $audace(rep_plugin) tool av4l img stop2.png ]
                  #--- Creation du bouton open
                  button $calcul.but_calc -image .calc -borderwidth 2 \
                        -command "::av4l_analysis_gui::calcul_evenement $calcul.but_calc -1"
                  pack $calcul.but_calc -side top -anchor c 

             #--- Cree un frame pour le chargement d'un fichier
             set results [frame $immersion.results -borderwidth 0 -cursor arrow -relief groove]
             pack $results -in $immersion -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un frame pour le chargement d'un fichier
                  set frmgauche [frame $results.frmgauche -borderwidth 0 -cursor arrow -relief groove]
                  pack $frmgauche -in $results -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set percent [frame $frmgauche.percent -borderwidth 0 -cursor arrow -relief groove]
                       pack $percent -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $percent.l -text "Evolution : "
                            pack  $percent.l -side left -anchor e 

                            #--- Cree un label
                            label $percent.v -textvariable ::av4l_analysis_tools::percent
                            pack  $percent.v -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set date_immersion_sol [frame $frmgauche.date_immersion_sol -borderwidth 0 -cursor arrow -relief groove]
                       pack $date_immersion_sol -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $date_immersion_sol.l -text "Date de l'immersion : "
                            pack  $date_immersion_sol.l -side left -anchor e 

                            #--- Cree un label
                            label $date_immersion_sol.v -textvariable ::av4l_analysis_gui::date_immersion_sol
                            pack  $date_immersion_sol.v -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set chi2_min [frame $frmgauche.chi2_min -borderwidth 0 -cursor arrow -relief groove]
                       pack $chi2_min -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $chi2_min.l -text "Chi2 : "
                            pack  $chi2_min.l -side left -anchor e 

                            #--- Cree un label
                            label $chi2_min.v -textvariable ::av4l_analysis_tools::chi2_min
                            pack  $chi2_min.v -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set nfit_chi2_min [frame $frmgauche.nfit_chi2_min -borderwidth 0 -cursor arrow -relief groove]
                       pack $nfit_chi2_min -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $nfit_chi2_min.l -text "Nombre de points utilisés pour l'ajustement : "
                            pack  $nfit_chi2_min.l -side left -anchor e 

                            #--- Cree un label
                            label $nfit_chi2_min.v -textvariable ::av4l_analysis_tools::nfit_chi2_min
                            pack  $nfit_chi2_min.v -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set t0_chi2_min [frame $frmgauche.t0_chi2_min -borderwidth 0 -cursor arrow -relief groove]
                       pack $t0_chi2_min -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $t0_chi2_min.l -text "t0 normalisé : "
                            pack  $t0_chi2_min.l -side left -anchor e 

                            #--- Cree un label
                            label $t0_chi2_min.v -textvariable ::av4l_analysis_tools::t0_chi2_min
                            pack  $t0_chi2_min.v -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set tps_dchi2 [frame $frmgauche.tps_dchi2 -borderwidth 0 -cursor arrow -relief groove]
                       pack $tps_dchi2 -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $tps_dchi2.l1 -text "Intervalle 1 \u03C3 : "
                            pack  $tps_dchi2.l1 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v1 -textvariable ::av4l_analysis_tools::t_inf
                            pack  $tps_dchi2.v1 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l2 -text "<=>"
                            pack  $tps_dchi2.l2 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v2 -textvariable ::av4l_analysis_tools::t_sup
                            pack  $tps_dchi2.v2 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l3 -text "  ("
                            pack  $tps_dchi2.l3 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v3 -textvariable ::av4l_analysis_tools::t_diff
                            pack  $tps_dchi2.v3 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l4 -text " sec)"
                            pack  $tps_dchi2.l4 -side left -anchor e 


                       #--- Cree un frame pour le chargement d'un fichier
                       set tps_dchi2 [frame $frmgauche.tps_dchi2_3s -borderwidth 0 -cursor arrow -relief groove]
                       pack $tps_dchi2 -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $tps_dchi2.l1 -text "Intervalle 3 \u03C3 : "
                            pack  $tps_dchi2.l1 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v1 -textvariable ::av4l_analysis_tools::t_inf_3s
                            pack  $tps_dchi2.v1 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l2 -text "<=>"
                            pack  $tps_dchi2.l2 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v2 -textvariable ::av4l_analysis_tools::t_sup_3s
                            pack  $tps_dchi2.v2 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l3 -text "  ("
                            pack  $tps_dchi2.l3 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v3 -textvariable ::av4l_analysis_tools::t_diff_3s
                            pack  $tps_dchi2.v3 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l4 -text " sec)"
                            pack  $tps_dchi2.l4 -side left -anchor e 


             #--- Cree un frame pour le chargement d'un fichier
             set graphe [frame $immersion.graphe -borderwidth 0 -cursor arrow -relief groove]
             pack $graphe -in $immersion -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                  image create photo .view -format PNG -file [ file join $audace(rep_plugin) tool av4l img view.png ]

                  
                  #--- Cree un frame pour le chargement d'un fichier
                  set graphel [frame $graphe.l -borderwidth 0 -cursor arrow -relief groove]
                  pack $graphel -in $graphe -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe1 [frame $graphel.1 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe1 -in $graphel -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                      #--- Creation du bouton select
                            button $graphe1.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe l 1"
                            pack $graphe1.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe1.lab -text "Signal photométrique" -font $av4lconf(font,courier_10_b)
                            pack  $graphe1.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe3 [frame $graphel.3 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe3 -in $graphel -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe3.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe l 3"
                            pack $graphe3.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe3.lab -text "Evenements"
                            pack  $graphe3.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe2 [frame $graphel.2 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe2 -in $graphel -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe2.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe l 2"
                            pack $graphe2.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe2.lab -text "Polynome"
                            pack  $graphe2.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe24 [frame $graphel.24 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe24 -in $graphel -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe24.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe l 24"
                            pack $graphe24.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe24.lab -text "Chi2" -font $av4lconf(font,courier_10_b)
                            pack  $graphe24.lab -side left -anchor e 

                  #--- Cree un frame pour le chargement d'un fichier
                  set grapher [frame $graphe.r -borderwidth 0 -cursor arrow -relief groove]
                  pack $grapher -in $graphe -anchor s -side right -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe23 [frame $grapher.23 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe23 -in $grapher -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe23.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe r 23"
                            pack $graphe23.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe23.lab -text "Ombre interpolée sur les points d'observation" -font $av4lconf(font,courier_10_b)
                            pack  $graphe23.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe20 [frame $grapher.20 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe20 -in $grapher -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe20.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe r 20"
                            pack $graphe20.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe20.lab -text "Ombre géométrique"
                            pack  $graphe20.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe21 [frame $grapher.21 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe21 -in $grapher -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe21.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe r 21"
                            pack $graphe21.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe21.lab -text "Ombre avec diffraction"
                            pack  $graphe21.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe22 [frame $grapher.22 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe22 -in $grapher -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe22.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe r 22"
                            pack $graphe22.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe22.lab -text "Ombre lissee par la reponse instrumentale"
                            pack  $graphe22.lab -side left -anchor e 






   # Fin proc ::av4l_analysis_gui::createdialog 
   }




}

