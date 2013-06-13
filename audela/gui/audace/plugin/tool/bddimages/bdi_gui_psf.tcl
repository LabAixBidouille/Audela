## \file bdi_gui_psf.tcl
#  \brief     Traitement des psf des images
#  \details   Ce namepsace concerne seulement l'affichage et 
#             l'appel des methodes de mesures de psf
#  \author    Frederic Vachier
#  \version   1.0
#  \date      2013
#  \copyright GNU Public License.
#  \par Ressource 
#  \code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_psf.tcl]
#  \endcode
#  \todo      normaliser les noms des fichiers sources 

#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages bdi_gui_psf.tcl ]
#--------------------------------------------------
#
# Fichier        : bdi_gui_psf.tcl
# Description    : Traitement des psf des images
# Auteur         : Frederic Vachier
# Mise à jour $Id: bdi_gui_psf.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace bdi_gui_psf
#
#--------------------------------------------------


## Declaration du namespace \c bdi_gui_psf .
#  @pre       Chargement a partir d'Audace
#  @bug       Probleme de memoire sur les exec
#  @warning   Appel par GUI uniquement
namespace eval bdi_gui_psf {


   #------------------------------------------------------------
   ## Initialisation des parametres de PSF au niveau GUI
   # Cette initialisation est a effectuer avant l'appel
   # a une fonction de mesure de photocentre
   # @return void
   #
   proc ::bdi_gui_psf::inittoconf { } {

      ::bdi_tools_psf::inittoconf

   }   



   #------------------------------------------------------------
   ## Sauvegarde dans la conf des parametres lies a la PSF
   # Cette initialisation est a effectuer avant l'appel
   # a une fonction de mesure de photocentre
   # @return void
   #
   proc ::bdi_gui_psf::closetoconf { } {

      ::bdi_tools_psf::closetoconf

   }   



   #------------------------------------------------------------
   ## Fonction qui initialise la variable current_psf
   # et formate le resultat
   # @param otherfield ASTROID
   # @return void
   #
   proc ::bdi_gui_psf::init_current_psf { othf } {
   
      set l [::bdi_tools_psf::get_fields_current_psf]

      foreach key $l {
      
         set value [::bdi_tools_psf::get_val othf $key]
         
         if {[string is ascii $value]} {set fmt "%s"}
         if {[string is double $value]} {set fmt "%.4f"}
         if {$value==""} {
            set ::gui_cata::current_psf($key) ""
            continue
         }
         if { ! [info exists fmt] } {gren_erreur "$value n a pas de format\n"}
         set ::gui_cata::current_psf($key) [format $fmt $value ]
      }
      
   }



   proc ::bdi_gui_psf::gui_configuration { frm } {

      
      set spinlist ""
      for {set i 1} {$i<$::bdi_tools_psf::psf_limitradius_max} {incr i} {lappend spinlist $i}
      
      # configuration par onglets
      set block [frame $frm.conf -borderwidth 0 -cursor arrow -relief groove]
      pack $block -in $frm -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

              set meth_onglets [frame $block.meth_onglets -borderwidth 0 -cursor arrow -relief groove]
              pack $meth_onglets -in $block -side top -expand yes -fill both -padx 10 -pady 5

              pack [ttk::notebook $meth_onglets.nb] -expand yes -fill both 
              set i 0
              foreach m [::bdi_tools_psf::get_methodes] {
                 incr i
                 set ongl($i) [frame $meth_onglets.nb.g$i]
                 $meth_onglets.nb add $ongl($i) -text $m
              }

              ttk::notebook::enableTraversal $meth_onglets.nb

              # configuration photombasic
              set block [frame $ongl(2).conf -borderwidth 0 -cursor arrow -relief groove]
              pack $block -in $ongl(2) -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

                     label $block.satl -text "Saturation (ADU): " 
                     entry $block.satv -textvariable ::bdi_tools_psf::psf_saturation -relief sunken -width 5

                     label $block.thrl -text "Threshold (arcsec): " 
                     entry $block.thrv -textvariable ::bdi_tools_psf::psf_threshold -relief sunken -width 5

                     label $block.radl -text "Rayon : " 
                     set sav $::bdi_tools_psf::psf_radius
                     spinbox $block.radiusc -values $spinlist -from 1 -to $::bdi_tools_psf::psf_limitradius_max -textvariable ::bdi_tools_psf::psf_radius -width 3 \
                         -command ""
                     pack  $block.radiusc -side left 
              
                     set ::bdi_tools_psf::psf_radius $sav
                     $block.radiusc set $::bdi_tools_psf::psf_radius

                     grid $block.satl  $block.satv  -sticky nsw -pady 3
                     grid $block.thrl  $block.thrv  -sticky nsw -pady 3
                     grid $block.radl  $block.radiusc  -sticky nsw -pady 3

              # configuration globale
              set block [frame $ongl(3).conf -borderwidth 0 -cursor arrow -relief groove]
              pack $block -in $ongl(3) -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

                     label $block.satl -text "Saturation (ADU): " 
                     entry $block.satv -textvariable ::bdi_tools_psf::psf_saturation -relief sunken -width 5

                     label $block.thrl -text "Threshold (arcsec): " 
                     entry $block.thrv -textvariable ::bdi_tools_psf::psf_threshold -relief sunken -width 5

                     label $block.radl1 -text "Limite min du Rayon : " 
                     entry $block.radv1 -textvariable ::bdi_tools_psf::psf_limitradius_min -relief sunken -width 5

                     label $block.radl2 -text "Limite max du Rayon : " 
                     entry $block.radv2 -textvariable ::bdi_tools_psf::psf_limitradius_max -relief sunken -width 5

                     grid $block.satl   $block.satv  -sticky nsw -pady 3
                     grid $block.thrl   $block.thrv  -sticky nsw -pady 3
                     grid $block.radl1  $block.radv1 -sticky nsw -pady 3
                     grid $block.radl2  $block.radv2 -sticky nsw -pady 3


      set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
      pack $actions -in $frm -anchor c -side top

           label $actions.lab1 -text "Methode pour PSF : " 
           menubutton $actions.b -menu $actions.b.m -textvar ::bdi_tools_psf::psf_methode -width 10 -relief groove
           menu $actions.b.m -tearoff 0
           foreach value [::bdi_tools_psf::get_methodes] { 
              $actions.b.m add command -label $value -command [list ::bdi_gui_psf::focus_conf_methode $frm $value ] 
           }
           grid $actions.lab1 $actions.b
           #$actions.b.m select 

     ::bdi_gui_psf::focus_conf_methode $frm
   }



   # focus sur l'onglet de la methode de ::bdi_tools_psf::psf_methode
   proc ::bdi_gui_psf::focus_conf_methode { frm { value "" } } {
      
      if { $value != "" } {
         set ::bdi_tools_psf::psf_methode $value
      }

      set i 0
      foreach m [::bdi_tools_psf::get_methodes] {
         incr i
         if {$m == $::bdi_tools_psf::psf_methode } {
            $frm.conf.meth_onglets.nb select $frm.conf.meth_onglets.nb.g$i
            break
         }
      }
   }





   proc ::bdi_gui_psf::get_list_col { } {
      return [list xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff ra dec ]
   }




   proc ::bdi_gui_psf::get_pos_col { key } {

      set list_of_columns [::psf_gui::get_list_col]

      set cpt 0
      foreach c $list_of_columns {
         if {$c==$key} {
            return $cpt
         }
         incr cpt
      }
      return -1
   }

   proc ::bdi_gui_psf::graph_with_error { key err_key } {

         set delta $::gui_cata::current_psf($err_key)
         set y0    $::gui_cata::current_psf($key)
         #gren_info "$key = $y0 ; delta = $delta\n"
         set ymin [list [expr $y0 - $delta] [expr $y0 - $delta] ]
         set ymax [list [expr $y0 + $delta] [expr $y0 + $delta] ]
         set x0   [list 0 $::bdi_tools_psf::psf_limitradius_max]
         set h [::plotxy::plot $x0 $ymin .]
         plotxy::sethandler $h [list -color "#808080" -linewidth 2]
         set h [::plotxy::plot $x0 $ymax .]
         plotxy::sethandler $h [list -color "#808080" -linewidth 2]

   }


   proc ::bdi_gui_psf::graph { key } {
    
      # graph de log
      if {1 == 1} {
         for {set radius $::bdi_tools_psf::psf_limitradius_min} {$radius < $::bdi_tools_psf::psf_limitradius_max} {incr radius} {
            if {[info exists ::bdi_tools_psf::graph_results($radius,$key)]} {
               if {$::bdi_tools_psf::graph_results($radius,err)==10} {
                  gren_erreur "$radius $::bdi_tools_psf::graph_results($radius,err)\n"
               }
               if {$::bdi_tools_psf::graph_results($radius,err)==0} {
                  gren_info "$radius $::bdi_tools_psf::graph_results($radius,err)\n"
               }
            }
         }
      }            

      set ::bdi_gui_psf::graph_current_key $key

      set x ""
      set y ""

      for {set radius $::bdi_tools_psf::psf_limitradius_min} {$radius < $::bdi_tools_psf::psf_limitradius_max} {incr radius} {
         
         #catch { gren_erreur "$radius $::bdi_tools_psf::graph_results($radius,err)\n" }
         
         if {[info exists ::bdi_tools_psf::graph_results($radius,$key)]} {
            if {$::bdi_tools_psf::graph_results($radius,err)==0} {
               lappend x $radius
               lappend y $::bdi_tools_psf::graph_results($radius,$key)
            }
         }
      }
      
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
     

      # Affichage de la valeur obtenue sous forme d'une ligne horizontale
      set x0 [list 0 $::bdi_tools_psf::psf_limitradius_max]
      set y0 [list $::gui_cata::current_psf($key) $::gui_cata::current_psf($key)]
      set h [::plotxy::plot $x0 $y0 .]
      plotxy::sethandler $h [list -color black -linewidth 2]

      # Affichage des erreurs pour XSM
      if {$key == "xsm" } {
         ::bdi_gui_psf::graph_with_error "xsm" "err_xsm"
         set y0 $::gui_cata::current_psf($key)
         set h 0.1
         set axis [::plotxy::axis]
         set axis [lreplace $axis 2 3 [expr $y0 - $h/2.] [expr $y0 + $h/2.] ]
         ::plotxy::axis $axis
      }
      # Affichage des erreurs pour YSM
      if {$key == "ysm" } {
         ::bdi_gui_psf::graph_with_error "ysm" "err_ysm"
         set y0 $::gui_cata::current_psf($key)
         set h 0.1
         set axis [::plotxy::axis]
         set axis [lreplace $axis 2 3 [expr $y0 - $h/2.] [expr $y0 + $h/2.] ]
         ::plotxy::axis $axis
      }
      # Affichage des erreurs pour FLUX
      if {$key == "flux" } {
         ::bdi_gui_psf::graph_with_error "flux" "err_flux"
      }
      # Affichage des erreurs pour SKY
      if {$key == "sky" } {
         ::bdi_gui_psf::graph_with_error "sky" "err_sky"
      }




      array set point [list 0 . 1 o 2 + 3 . 4 + 5 o ]
      array set color [list 0 "#18ad86" 1 yellow 2 green 3 blue 4 red 5 black ]
      array set line  [list 0 1 1 0 2 0 3 0 4 0 5 0 ]

      set h [::plotxy::plot $x $y .]
      plotxy::sethandler $h [list -color "#18ad86" -linewidth 1]
     
      
   } 



   proc ::bdi_gui_psf::takall_obsolete {  } {

      # graph de log
      if {1 == 1} {
         gren_info "valeur avant takall\n"
         for {set radius $::bdi_tools_psf::psf_limitradius_min} {$radius < $::bdi_tools_psf::psf_limitradius_max} {incr radius} {
            if {[info exists ::bdi_tools_psf::graph_results($radius,err)]} {
               if {$::bdi_tools_psf::graph_results($radius,err)==10} {
                  gren_erreur "$radius $::bdi_tools_psf::graph_results($radius,err)\n"
               }
               if {$::bdi_tools_psf::graph_results($radius,err)==0} {
                  gren_info "$radius $::bdi_tools_psf::graph_results($radius,err)\n"
               }
            }
         }
      }            

      # remet tout a 0
      for {set radius $::bdi_tools_psf::psf_limitradius_min} {$radius < $::bdi_tools_psf::psf_limitradius_max} {incr radius} {
         if {$::bdi_tools_psf::graph_results($radius,err)==10} {
            set ::bdi_tools_psf::graph_results($radius,err) 0
         }
      }
      if { [winfo exists .audace.plotxy1] } {
         ::bdi_gui_psf::graph $::bdi_gui_psf::graph_current_key
      }

   } 




   proc ::bdi_gui_psf::setval { } {

      if { [winfo exists .audace.plotxy1] } {
         gren_info "current graph on  $::bdi_gui_psf::graph_current_key \n"
      }
      set key $::bdi_gui_psf::graph_current_key

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
 

      # on crop
      set cpt 0
      for {set radius $::bdi_tools_psf::psf_limitradius_min} {$radius < $::bdi_tools_psf::psf_limitradius_max} {incr radius} {
         if {$::bdi_tools_psf::graph_results($radius,err)==0} {
            incr cpt
            if {$radius < $x1 || $x2 < $radius } {
               set ::bdi_tools_psf::graph_results($radius,err) 10
               incr cpt -1
               continue
            }
            set val [lindex $::bdi_tools_psf::graph_results($radius,$key)] 
            if {$val < $y1 || $y2 < $val } {
               set ::bdi_tools_psf::graph_results($radius,err) 10
               incr cpt -1
            }
         }
      }
      gren_info "Nb radius stat crop = $cpt \n "


      set othf [::bdi_tools_methodes_psf::globale_stat ::bdi_tools_psf::graph_results]

      set i  [expr $::gui_cata::psf_id_source - 1]

      set s [lindex [lindex $::tools_cata::current_listsources 1] $i ]

      ::bdi_tools_psf::set_astroid_in_source s othf

      set lf [lindex $::tools_cata::current_listsources 0]
      set ls [lindex $::tools_cata::current_listsources 1]
      set ls [lreplace $ls $i $i $s]
      set ::tools_cata::current_listsources [list $lf $ls]

      ::bdi_gui_psf::init_current_psf $othf
      ::bdi_gui_gestion_source::maj_catalogues

      if { [winfo exists .audace.plotxy1] } {
         ::bdi_gui_psf::graph $::bdi_gui_psf::graph_current_key
      }

      cleanmark
      affich_un_rond_xy $::gui_cata::current_psf(xsm) $::gui_cata::current_psf(ysm) green $::gui_cata::current_psf(radius) 2

return 
      
      array set sol [::psf_tools::method_global_stat ::psf_tools::graph_results $::psf_tools::psf_limitradius_max 0]
      set ::gui_cata::psf_best_sol [::psf_tools::method_global_sol sol]

      set flagastroid [::psf_tools::add_astroid ::gui_cata::psf_source ::gui_cata::psf_best_sol $::gui_cata::psf_name_source]
      gren_info "Astroid = $flagastroid\n"
            
      set ::gui_cata::psf_add_astroid $flagastroid

      ::psf_tools::result_photom_methode $::gui_cata::psf_best_sol
      
      ::psf_gui::graph $key
      
      ::psf_gui::affichage_des_ronds_dans_imagette


   } 


}
