#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages bdi_psf_gui.tcl ]
#--------------------------------------------------
#
# Fichier        : bdi_psf_gui.tcl
# Description    : Traitement des psf des images
# Auteur         : Frederic Vachier
# Mise à jour $Id: bdi_psf_gui.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace psf_gui
#
#--------------------------------------------------


namespace eval psf_gui {



# Anciennement ::gui_cata::psf_fermer
# Ferme la boite de dialogue appell�e
# depuis la gestion des cata pour faire l analyse des psf en mode manuel
   proc ::psf_gui::gestion_mode_manuel_fermer { } {

      destroy $::psf_gui::fen
      ::cata_gestion_gui::charge_image_directaccess

   }


# Anciennement ::gui_cata::init_psf
# Initialise la boite de dialogue appell�e
# depuis la gestion des cata pour faire l analyse des psf en mode manuel

   proc ::psf_gui::gestion_mode_manuel_init { sou } {

      if {[info exists ::gui_cata::current_psf]} {unset ::gui_cata::current_psf}
      foreach key [list xsm ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta] {
         set ::gui_cata::current_psf($key) "-"
      }
      foreach key [ list xflux xcent xfwhm xfond yflux ycent yfwhm yfond ] {
         set ::gui_cata::current_psf($key) "-"
      }


      if { $sou == "" } {
         set ::gui_cata::psf_radius 15
         set ::gui_cata::psf_name_source "Unknown"
         set ::gui_cata::list_of_cata ""
      } else {
         
      }

      set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)
      set ::tools_cata::current_image [lindex $::tools_cata::img_list [expr $::tools_cata::id_current_image-1]]
      


   }



# Anciennement ::gui_cata::grab_sources_from_gui


   proc ::psf_gui::grab_sources {  } {
 

      set color red
      set width 2
      cleanmark

      set ambigue "no"

      set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
      if {$err>0 || $rect==""} {
         tk_messageBox -message "Veuillez dessiner un carre dans l'image (avec un clic gauche)" -type ok
         return
      }

      set sources [lindex $::tools_cata::current_listsources 1]
      set id 1
      set cpt_grab 0
      foreach s $sources {
         set x -100
         set y -100
         foreach cata $s {
         
            set namable [::manage_source::namable $s]
            if {$namable==""} {
               set name ""
            } else {
               set name [::manage_source::naming $s $namable]
            } 

            set x -100
            set y -100
            set pass "no"
                        
            if {[lindex $cata 0] == "IMG"} {
               set ra [lindex [lindex $cata 1] 0]
               set dec [lindex [lindex $cata 1] 1]
               #gren_info "IMG ra dec : $ra $dec \n"
               set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
               set x [lindex $xy 0]
               set y [lindex $xy 1]
               if {$x > [lindex $rect 0] && $x < [lindex $rect 2] && $y > [lindex $rect 1] && $y < [lindex $rect 3]} {
                  set pass "yes"
                  set xpass $x
                  set ypass $y
               }
            }
            
            if {[lindex $cata 0] == "ASTROID"} {
               set ra [lindex [lindex $cata 1] 0]
               set dec [lindex [lindex $cata 1] 1]
               #gren_info "ASTROID ra dec ($id) : $ra $dec \n"
               set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
               set x [lindex $xy 0]
               set y [lindex $xy 1]
               if {$x > [lindex $rect 0] && $x < [lindex $rect 2] && $y > [lindex $rect 1] && $y < [lindex $rect 3]} {
                  set pass "yes"
                  set xpass $x
                  set ypass $y
               }
            }
            
            if {$pass=="yes"} {

               #gren_info "**NAME = $name \n"
               incr cpt_grab
               if {$cpt_grab>1}  { set ambigue "yes"}

               #gren_info "NAME = $name \n"
               #gren_info "xpass ypass  = $xpass $ypass\n"
               #gren_info "rect = $rect\n"
               affich_un_rond_xy $xpass $ypass green 60 1

               set pos [lsearch -index 0 $s "IMG"]
               if {$pos != -1} {
                   set ra [lindex [lindex $cata 1] 0]
                   set dec [lindex [lindex $cata 1] 1]
                   set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
                   set x [lindex $xy 0]
                   set y [lindex $xy 1]
                   affich_un_rond $ra $dec green 3 
                   affich_un_rond_xy $x $y green 1 10
               }

               set pos [lsearch -index 0 $s "ASTROID"]         
               if {$pos != -1} {
                  set cata [lindex $s $pos]
                  affich_un_rond_xy  [lindex [lindex $cata 2] 0] [lindex [lindex $cata 2] 1] red 30 1
                  set ra [lindex [lindex $cata 1] 0]
                  set dec [lindex [lindex $cata 1] 1]
                  set xy [ buf$::audace(bufNo) radec2xy [ list $ra $dec ] ]
                  set x [lindex $xy 0]
                  set y [lindex $xy 1]
                  affich_un_rond $ra $dec blue 2
                  affich_un_rond_xy $x $y blue 1 5
               }


               # gren_info "cpt_grab = $cpt_grab\n"

               gren_info "SOURCE FOUND : ID = $id NAME = $name CATAS = "
               foreach cata $s {
                  gren_info "[lindex $cata 0] "
                  if {[lindex $cata 0]==$namable} {
                     set ra  [lindex [lindex $cata 1] 0]
                     set dec [lindex [lindex $cata 1] 1]
                     #affich_un_rond $ra $dec $color $width
                  }
               }
               gren_info "\n"

               if {$ambigue == "yes" } {
                  set result [list 1 "Ambigue" $id $xpass $ypass $s]
               } else {
                  set result [list 0 "" $id $xpass $ypass $s]
               }
               break
            }
         }
         incr id
      }
      if {$cpt_grab==0} { return [list 1 "Unknown"] }
      return $result
   }
 
 
 
 
 
 

# Anciennement ::gui_cata::psf_grab
# Grab des sources dans l image
# appele depuis l analyse des psf en mode manuel


   proc ::psf_gui::gestion_mode_manuel_grab { } {

       $::psf_gui::fen.appli.actions.save configure -state disabled
       $::psf_gui::fen.appli.actions.new  configure -state disabled

       set ::gui_cata::psf_id_source ""
       set ::gui_cata::list_of_cata ""
       set r [::psf_gui::grab_sources]

       #gren_info "r=$r\n"

       set err   [lindex $r 0]
       set aff   [lindex $r 1]
       set id    [lindex $r 2]
       set xpass [lindex $r 3]
       set ypass [lindex $r 4]
       set s     [lindex $r 5]

       set ::gui_cata::psf_best_sol [list $xpass $ypass]

       if {$err!=0} {
           set ::gui_cata::psf_name_source "Erreur"
           if { $aff=="Unknown" || $aff=="Ambigue" } {
              set ::gui_cata::psf_name_source $aff
              if {[info exists ::gui_cata::psf_best_sol]} { unset ::gui_cata::psf_best_sol }
           }
           if { $aff=="Ambigue" } {
              set ::gui_cata::psf_name_source $aff
              if {[info exists ::gui_cata::psf_best_sol]} { unset ::gui_cata::psf_best_sol }
           }
           return
       }
       ::psf_tools::result_photom_methode "err" 
       ::psf_tools::result_fitgauss "err" 

       set d [::manage_source::namable $s]
       if {$d==""} {
          gren_info "s=$s\n"
          set ::gui_cata::psf_name_source "Unnamable"
          return
       }
       set ::gui_cata::psf_source $s
       set ::gui_cata::psf_name_source [::manage_source::naming $s $d]
       set ::gui_cata::psf_name_cata $d
       set ::gui_cata::psf_id_source $id
            
       foreach mycata $s {
          append ::gui_cata::list_of_cata " " [lindex $mycata 0]
       }

   }








# Anciennement ::gui_cata::psf_save
# sauve les resultats de la psf d'une source connue selectionnee dans l image
# appel�e depuis l analyse des psf en mode manuel

   proc ::psf_gui::gestion_mode_manuel_save { } {

       gren_info "Maj id = $::gui_cata::psf_id_source \n"

       set current_image [ lindex  $::tools_cata::img_list [expr $::tools_cata::id_current_image -1] ]
       set commundatejj  [::bddimages_liste::lget $current_image "commundatejj"]
       set dateiso       [ mc_date2iso8601 $commundatejj ]
       set ls            [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1]

       set ls [lreplace $ls [expr $::gui_cata::psf_id_source - 1] [expr $::gui_cata::psf_id_source - 1] $::gui_cata::psf_source]
       set ::gui_cata::cata_list($::tools_cata::id_current_image) [lreplace $::gui_cata::cata_list($::tools_cata::id_current_image) 1 1 $ls]

       set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)
       gren_info "new source = $::gui_cata::psf_source\n"

       ::tools_cata::current_listsources_to_tklist

       set ::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::gui_cata::tklist_list_of_columns]
       set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::gui_cata::tklist]
       set ::gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::gui_cata::cataname]

       $::psf_gui::fen.appli.actions.save  configure -state disabled
   
   }



# Anciennement ::gui_cata::psf_new
# sauve les resultats de la psf d'une source inconnue selectionnee dans l image
# appel�e depuis l analyse des psf en mode manuel


   proc ::psf_gui::gestion_mode_manuel_new { } {

      # "ra" "dec" "poserr" "mag" "magerr"
      # "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux"
      # "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" 
      # "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" 
      # "name" "flagastrom" "flagphotom" "cataastrom" "cataphotom"

       #$::gui_cata::cata_list($::tools_cata::id_current_image)

       set current_image [ lindex  $::tools_cata::img_list [expr $::tools_cata::id_current_image -1] ]
       set commundatejj  [::bddimages_liste::lget $current_image "commundatejj"]
       set dateiso       [ mc_date2iso8601 $commundatejj ]
       set ls            [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1]
       lappend ls $::gui_cata::psf_source

       #gren_info "id_current_image = $::tools_cata::id_current_image\n"
       #gren_info "date = $dateiso\n"
       #gren_info "new source = $::gui_cata::psf_source\n"

       set ::gui_cata::cata_list($::tools_cata::id_current_image) [lreplace $::gui_cata::cata_list($::tools_cata::id_current_image) 1 1 $ls]
       gren_info "New id = [llength [lindex $::gui_cata::cata_list($::tools_cata::id_current_image) 1]]\n"

       set ::tools_cata::current_listsources $::gui_cata::cata_list($::tools_cata::id_current_image)

       ::tools_cata::current_listsources_to_tklist

       set ::gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::gui_cata::tklist_list_of_columns]
       set ::gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::gui_cata::tklist]
       set ::gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::gui_cata::cataname]

       $::psf_gui::fen.appli.actions.new  configure -state disabled


   }







# Anciennement ::gui_cata::psf_button_psf
# Effectue l analyse d'une psf pour un rayon donn�
# appel� depuis l analyse des psf en mode manuel


   proc ::psf_gui::one_psf { } {

      global bddconf

      if {$::gui_cata::psf_name_source=="Unknown"&&[info exists ::gui_cata::psf_best_sol]} {
         unset ::gui_cata::psf_best_sol
      }

      if {[info exists ::gui_cata::psf_best_sol]} {

         set xcent [expr int([lindex $::gui_cata::psf_best_sol 0])]
         set ycent [expr int([lindex $::gui_cata::psf_best_sol 1])]
         ::psf_tools::psf_box $xcent $ycent

      } else {
         set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
         if {$err>0 || $rect ==""} {
            cleanmark
            return -code 2
         }
         ::psf_tools::psf_box $rect
      }
      switch $::gui_cata::psf_name_source {
         "Erreur" {
            $::psf_gui::fen.appli.actions.save configure -state disabled
            $::psf_gui::fen.appli.actions.new  configure -state disabled
         }
         "Unknown" {
            $::psf_gui::fen.appli.actions.save configure -state disabled
            $::psf_gui::fen.appli.actions.new  configure -state normal
         }
         "Ambigue" {
            $::psf_gui::fen.appli.actions.save configure -state disabled
            $::psf_gui::fen.appli.actions.new  configure -state disabled
         }
         default {
            $::psf_gui::fen.appli.actions.save configure -state normal
            $::psf_gui::fen.appli.actions.new  configure -state disabled
         }
      }

#     AFFICHAGE DES RONDS

      catch {

         cleanmark
      
         set r $::gui_cata::current_psf(delta)
         affich_un_rond_xy $::gui_cata::current_psf(xsm) $::gui_cata::current_psf(ysm) green 0 1
         affich_un_rond_xy $::gui_cata::current_psf(xsm) $::gui_cata::current_psf(ysm) green $r 2

         set r [expr 3.0*sqrt((pow($::gui_cata::current_psf(xfwhm),2)+pow($::gui_cata::current_psf(yfwhm),2))/2.0)]

         affich_un_rond_xy $::gui_cata::current_psf(xcent) $::gui_cata::current_psf(ycent) red 0 1
         affich_un_rond_xy $::gui_cata::current_psf(xcent) $::gui_cata::current_psf(ycent) blue $r 2
      
      }
   }













# Anciennement ::gui_cata::psf_box_auto
# Effectue une analyse de psf, en methode globale
# cad qu il fait une statistique sur une multitude de rayon de recherche


   proc ::psf_gui::box_global { } {
   
      global bddconf

      #::gui_cata::psf_cataname
      #::gui_cata::psf_source
      #::gui_cata::psf_name_source
      #::gui_cata::psf_id_source 


      if {$::gui_cata::psf_name_source == "Unknown" } {
         set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
         if {$err>0 || $rect ==""} {
            cleanmark
            return
         }
         set result_fitgauss [buf$bddconf(bufno) fitgauss $rect]
         ::psf_tools::result_fitgauss $result_fitgauss
         set xcent  [lindex $result_fitgauss 1]  
         set ycent  [lindex $result_fitgauss 5]  

         set err [ catch {set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]} msg ]
         if {$err} {
            ::console::affiche_erreur "$err $msg\n"
            return
         }
         set ra  [lindex $a 0]
         set dec [lindex $a 1]

         set othf [::tools_cata::get_img_null]
         set othf [lreplace $othf 0 3 0 1 $xcent $ycent]
         set othf [lreplace $othf 8 9 $ra $dec]
         set img_source [ list "IMG" [list $ra $dec 5 0 0] $othf ]
         set astroid_source [list "ASTROID" [list $ra $dec 5 0 0] [::analyse_source::get_astroid_null] ]
         set ::gui_cata::psf_source [list $img_source ]
      }

      set pass "no"
      # A decocher au cas ou on veut logger cette partie
      # set r [::psf_tools::method_global ::gui_cata::psf_source $::gui_cata::psf_threshold $::gui_cata::psf_limitradius ]
      set err [ catch {set r [::psf_tools::method_global ::gui_cata::psf_source $::gui_cata::psf_threshold $::gui_cata::psf_limitradius ]} msg ]
      if {$err} {
         ::console::affiche_erreur "ERREUR PSF no_gui: $msg\n"
      } else {
         set pass "yes"
      }

      switch $::gui_cata::psf_name_source {
         "Erreur" {
            $::psf_gui::fen.appli.actions.save configure -state disabled
            $::psf_gui::fen.appli.actions.new  configure -state disabled
         }
         "Unknown" {
            $::psf_gui::fen.appli.actions.save configure -state disabled
            $::psf_gui::fen.appli.actions.new  configure -state normal
         }
         "Ambigue" {
            $::psf_gui::fen.appli.actions.save configure -state disabled
            $::psf_gui::fen.appli.actions.new  configure -state disabled
         }
         default {
            $::psf_gui::fen.appli.actions.save configure -state normal
            $::psf_gui::fen.appli.actions.new  configure -state disabled
         }
      }
      
      if { $pass=="no" } { return }
      
      #gren_info "::gui_cata::psf_source = $::gui_cata::psf_source\n"

      #gren_info "*best PSF pour ($::gui_cata::psf_id_source) $::gui_cata::psf_name_source \n"
      set ::gui_cata::psf_best_sol        [lindex $r 0]
      set ::gui_cata::psf_radius          [lindex $r 1]
      set ::gui_cata::psf_add_astroid     [lindex $r 2]

      if {$::gui_cata::psf_name_source == "Unknown" } {
         gren_info "NEW SOURCE : ADD IMG = Success, ASTROID = $::gui_cata::psf_add_astroid \n"
      }
      #gren_info "psf_radius   = $::gui_cata::psf_radius \n"
      #gren_info "psf_best_sol = $::gui_cata::psf_best_sol   \n"

      set result [lindex $r 0]
      ::psf_tools::result_photom_methode $result

      set xcent [expr int([lindex $result 0])]
      set ycent [expr int([lindex $result 1])]
      set delta [lindex $r 1]
      set rect [list [expr $xcent - $delta] [expr $ycent - $delta] [expr $xcent + $delta]  [expr $ycent + $delta] ] 

      #     fit gauss
      set result_fitgauss [buf$bddconf(bufno) fitgauss $rect]
      ::psf_tools::result_fitgauss $result_fitgauss
 
      set xd [expr abs($::gui_cata::current_psf(xsm)-$::gui_cata::current_psf(xcent))]
      set yd [expr abs($::gui_cata::current_psf(ysm)-$::gui_cata::current_psf(ycent))]
      set rdiff [expr sqrt (pow($xd,2) + pow($yd ,2))]
      set ::gui_cata::current_psf(rdiff) [format "%.4f" $rdiff ]

      catch {

         cleanmark
      
         set r $::gui_cata::current_psf(delta)
         affich_un_rond_xy $::gui_cata::current_psf(xsm) $::gui_cata::current_psf(ysm) green 0 1
         affich_un_rond_xy $::gui_cata::current_psf(xsm) $::gui_cata::current_psf(ysm) green $r 2

         set r [expr 3.0*sqrt((pow($::gui_cata::current_psf(xfwhm),2)+pow($::gui_cata::current_psf(yfwhm),2))/2.0)]

         affich_un_rond_xy $::gui_cata::current_psf(xcent) $::gui_cata::current_psf(ycent) red 0 1
         affich_un_rond_xy $::gui_cata::current_psf(xcent) $::gui_cata::current_psf(ycent) blue $r 2
      
      }
      
   }



#    xsm,mean)          
#    ysm,mean)          
#    xsm,err3s)         
#    ysm,err3s)         
#    fwhmx,mean)        
#    fwhmy,mean)        
#    fwhm,mean)         
#    fluxintegre,mean)  
#    fluxintegre,err3s) 
#    pixmax,mean)       
#    intensite,mean)    
#    sigmafond,mean)    
#    snint,mean)        
#    snpx,mean)         
#    delta,mean)        
#    rdiff,mean)        
#    ra,mean)           
#    dec,mean)          
#

#   {xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff ra dec}

   proc ::psf_gui::get_list_col { } {
      return [list xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff ra dec ]
   }


   proc ::psf_gui::get_pos_col { key } {

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






   proc ::psf_gui::graph { key } {
   
      set list_of_columns [::psf_gui::get_list_col]

      foreach c $list_of_columns {
         if {$c == $key} {
            $::psf_gui::fen.appli.results.photommethode.values.$key.setval configure -state active
         } else {
            catch {$::psf_gui::fen.appli.results.photommethode.values.$c.setval configure -state disabled}
         }
      }
   
      
      set id [::psf_gui::get_pos_col $key]

      if {$id == -1 } {
         ::console::affiche_erreur "$key (err $id) n'est pas definie dans la routine ::psf_gui::get_pos_col\n"
      }


      

      
      for {set i 0} {$i <= 5} {incr i} {

         set x($i) ""
         set y($i) ""

         for {set radius 1} {$radius < $::gui_cata::psf_limitradius} {incr radius} {
            
            if {$::psf_tools::graph_results($radius,err)==$i && [info exists ::psf_tools::graph_results($radius)]} {
                lappend x($i) $radius
                lappend y($i) [lindex $::psf_tools::graph_results($radius) $id]
            }

         }
            
      }
      
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {40 40 600 400}
     

      # Affichage de la valeur obtenue
      set x0 [ list 0 $::gui_cata::psf_limitradius ]
      set y0 [ list $::gui_cata::current_psf($key) $::gui_cata::current_psf($key)]
      set h [::plotxy::plot $x0 $y0 .]
      plotxy::sethandler $h [list -color black -linewidth 2]

      # Affichage des erreurs
      if {$key == "xsm" } {
         set delta $::gui_cata::current_psf(err_xsm)
         set y0    $::gui_cata::current_psf($key)
         gren_info "delta y = $key $delta $y0\n"
         set ymin  [list [expr $y0 - $delta] [expr $y0 - $delta] ]
         set ymax  [list [expr $y0 + $delta] [expr $y0 + $delta] ]
         set x0    [ list 0 $::gui_cata::psf_limitradius ]
         set h [::plotxy::plot $x0 $ymin .]
         plotxy::sethandler $h [list -color "#808080" -linewidth 1]
         set h [::plotxy::plot $x0 $ymax .]
         plotxy::sethandler $h [list -color "#808080" -linewidth 1]
      }
      # Affichage des erreurs
      if {$key == "ysm" } {
         set delta $::gui_cata::current_psf(err_ysm)
         set y0    $::gui_cata::current_psf($key)
         gren_info "delta y = $key $delta $y0\n"
         set ymin  [list [expr $y0 - $delta] [expr $y0 - $delta] ]
         set ymax  [list [expr $y0 + $delta] [expr $y0 + $delta] ]
         set x0    [ list 0 $::gui_cata::psf_limitradius ]
         set h [::plotxy::plot $x0 $ymin .]
         plotxy::sethandler $h [list -color "#808080" -linewidth 1]
         set h [::plotxy::plot $x0 $ymax .]
         plotxy::sethandler $h [list -color "#808080" -linewidth 1]
      }




      array set point [list 0 . 1 o 2 + 3 . 4 + 5 o ]
      array set color [list 0 "#18ad86" 1 yellow 2 green 3 blue 4 red 5 black ]
      array set line  [list 0 1 1 0 2 0 3 0 4 0 5 0 ]

      for {set i 0} {$i <= 5} {incr i} {
         if {$i==3} {continue}
         set h [::plotxy::plot $x($i) $y($i) $point($i)]
         plotxy::sethandler $h [list -color $color($i) -linewidth $line($i)]
      }
      
   } 





   proc ::psf_gui::setval { key } {

      set id [::psf_gui::get_pos_col $key]

      if {$id == -1 } {
         ::console::affiche_erreur "$key (err $id) n'est pas definie dans la routine ::psf_gui::get_pos_col\n"
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
 
      if {$x1 < 0 && $x2 > $::gui_cata::psf_limitradius} {
         # Astuce pour remettre a zero le graphe
         for {set radius 1} {$radius < $::gui_cata::psf_limitradius} {incr radius} {
            set ::psf_tools::graph_results($radius,err) 0
         }
      } else {

         # on crop
         set cpt 0
         for {set radius 1} {$radius < $::gui_cata::psf_limitradius} {incr radius} {
            if {$::psf_tools::graph_results($radius,err)==0} {
               incr cpt
               if {$radius < $x1 || $x2 < $radius } {
                  set ::psf_tools::graph_results($radius,err) 5
                  incr cpt -1
                  continue
               }
               set val [lindex $::psf_tools::graph_results($radius) $id] 
               if {$val < $y1 || $y2 < $val } {
                  set ::psf_tools::graph_results($radius,err) 5
                  incr cpt -1
               }
            }
         }
         gren_info "Nb radius stat crop = $cpt \n "

      }
      
      array set sol [::psf_tools::method_global_stat ::psf_tools::graph_results $::gui_cata::psf_limitradius 0]
      set ::gui_cata::psf_best_sol [::psf_tools::method_global_sol sol]

      set flagastroid [::psf_tools::add_astroid ::gui_cata::psf_source ::gui_cata::psf_best_sol $::gui_cata::psf_name_source]
      set ::gui_cata::psf_add_astroid $flagastroid

      ::psf_tools::result_photom_methode $::gui_cata::psf_best_sol
      

      ::psf_gui::graph $key



   } 






# Anciennement ::gui_cata::psf
# Ouvre une boite de dialogue depuis la gestion des cata pour faire 
# l analyse des psf en mode manuel

   proc ::psf_gui::gestion_mode_manuel { { sou "" } } {

      ::psf_gui::gestion_mode_manuel_init $sou
      set ::gui_cata::psf_limitradius 50
      set ::gui_cata::psf_threshold 2
      
      set spinlist ""
      for {set i 1} {$i<$::gui_cata::psf_limitradius} {incr i} {lappend spinlist $i}

      set ::psf_gui::fen .psf
      if { [winfo exists $::psf_gui::fen] } {
         wm withdraw $::psf_gui::fen
         wm deiconify $::psf_gui::fen
         focus $::psf_gui::fen
         return
      }
      toplevel $::psf_gui::fen -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $::psf_gui::fen ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $::psf_gui::fen ] "+" ] 2 ]
      wm geometry $::psf_gui::fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $::psf_gui::fen 1 1
      wm title $::psf_gui::fen "PSF"
      wm protocol $::psf_gui::fen WM_DELETE_WINDOW "::psf_gui::gestion_mode_manuel_fermer"

      set frm $::psf_gui::fen.appli

      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $::psf_gui::fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5


         set info  [frame $frm.info -borderwidth 0 -cursor arrow -relief groove]
         pack $info -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             label $info.lab1 -text "Source : " 
             pack  $info.lab1 -side left -padx 2 -pady 0
             
             label $info.labv -textvariable ::gui_cata::psf_name_source 
             pack  $info.labv -side left -padx 2 -pady 0

             #label $info.op -text "(" 
             #pack  $info.op -side left -padx 2 -pady 0

             label $info.loc -textvariable ::gui_cata::list_of_cata -fg darkblue
             pack  $info.loc -side left -padx 2 -pady 0

             #label $info.fp -text ")" 
             #pack  $info.fp -side left -padx 2 -pady 0

         set actions [frame $frm.actions -borderwidth 1 -cursor arrow -relief groove]
         pack $actions -in $frm -anchor c -side top -expand 1 

                 button $actions.grab -state active -text "Grab" -relief "raised" -command "::psf_gui::gestion_mode_manuel_grab"
                 pack   $actions.grab -side left -padx 0

                 button $actions.new -state disabled -text "New" -relief "raised" -command "::psf_gui::gestion_mode_manuel_new"
                 pack   $actions.new -side left -padx 0

                 button $actions.save -state disabled -text "Save" -relief "raised" -command "::psf_gui::gestion_mode_manuel_save"
                 pack   $actions.save -side left -padx 0
 
         set config [frame $frm.config -borderwidth 0 -cursor arrow -relief groove]
         pack $config -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             set data  [frame $config.threshold -borderwidth 0 -cursor arrow -relief groove]
             pack $data -in $config -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                 label $data.l -text "Threshold : " 
                 pack  $data.l -side left -padx 2 -pady 0

                 entry $data.v -textvariable ::gui_cata::psf_threshold -relief sunken -width 5
                 pack  $data.v -side left -padx 2 -pady 0

             set data  [frame $config.limitradius -borderwidth 0 -cursor arrow -relief groove]
             pack $data -in $config -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                 label $data.l -text "Limite du Rayon : " 
                 pack  $data.l -side left -padx 2 -pady 0

                 entry $data.v -textvariable ::gui_cata::psf_limitradius -relief sunken -width 5
                 pack  $data.v -side left -padx 2 -pady 0

         set actions2 [frame $frm.actions2 -borderwidth 1 -cursor arrow -relief groove]
         pack $actions2 -in $frm -anchor c -side top

             spinbox $actions2.radius -values $spinlist -from 1 -to $::gui_cata::psf_limitradius -textvariable ::gui_cata::psf_radius -width 3 \
                 -command "::psf_gui::one_psf"
             pack  $actions2.radius -side left 
             $actions2.radius set 15

             button $actions2.psf -state active -text "PSF" -relief "raised" -command "::psf_gui::one_psf"
             pack   $actions2.psf -side left 
 
             button $actions2.psfauto -state active -text "Auto" -relief "raised" -command "::psf_gui::box_global"
             pack   $actions2.psfauto -side left 
 
         set results [frame $frm.results -borderwidth 0 -cursor arrow -relief groove]
         pack $results -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

         set photommethode [frame $results.photommethode -borderwidth 0 -cursor arrow -relief groove]
         pack $photommethode -in $results -anchor n -side left -expand 0 -fill x -padx 10 -pady 5

             label $photommethode.lab1 -text "PhotomMethode :"
             pack  $photommethode.lab1 -in $photommethode -side top -padx 2 -pady 0

             set values [ frame $photommethode.values -borderwidth 0 -cursor arrow -relief groove ]
             pack $values -in $photommethode -anchor n -side top -expand 1 -fill both -padx 10 -pady 2

                    foreach key [list xsm ysm err_xsm err_ysm fwhmx fwhmy fwhm fluxintegre errflux pixmax intensite sigmafond snint snpx delta rdiff] {

                         set value [ frame $values.$key -borderwidth 0 -cursor arrow -relief groove ]
                         pack $value -in $values -anchor n -side top -expand 1 -fill both -padx 2 -pady 2

                              if {$key=="err_xsm"||$key=="err_ysm"||$key=="errflux"||$key=="delta"} {
                                 set active disabled
                              } else {
                                 set active active
                              }
                              button $value.graph -state $active -text "@" -relief "raised" \
                                 -command "::psf_gui::graph $key" 
                              pack   $value.graph -side left -padx 0
                              button $value.setval -state $active -text "S" -relief "raised" \
                                 -command "::psf_gui::setval $key" 
                              pack   $value.setval -side left -padx 0
                              
                              label $value.lab1 -text "$key =" 
                              pack  $value.lab1 -side left -padx 2 -pady 0
                              label $value.lab2 -textvariable ::gui_cata::current_psf($key)
                              pack  $value.lab2 -side right -padx 2 -pady 0
                    }

         set fitgauss [frame $results.fitgauss -borderwidth 0 -cursor arrow -relief groove]
         pack $fitgauss -in $results -anchor n -side left -expand 0 -fill x -padx 2 -pady 2

             label $fitgauss.labfitgauss -text "FitGauss :"
             pack  $fitgauss.labfitgauss -in $fitgauss -side top -padx 2 -pady 0

             set values [ frame $fitgauss.values -borderwidth 0 -cursor arrow -relief groove ]
             pack $values -in $fitgauss -anchor n -side top -expand 1 -fill both -padx 2 -pady 2

                    foreach key [list xflux xcent xfwhm xfond yflux ycent yfwhm yfond] {

                         set value [ frame $values.$key -borderwidth 0 -cursor arrow -relief groove ]
                         pack $value -in $values -anchor n -side top -expand 1 -fill both -padx 2 -pady 2

                              label $value.lab1 -text "$key =" 
                              pack  $value.lab1 -side left -anchor sw -padx 5 -pady 0
                              label $value.lab2 -textvariable ::gui_cata::current_psf($key)
                              pack  $value.lab2 -side right -padx 5 -pady 0 -anchor se 
                    }

         set actionspied [frame $frm.actionspied -borderwidth 0 -cursor arrow -relief groove]
         pack $actionspied -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             button $actionspied.fermer -state active -text "Fermer" -relief "raised" -command "::psf_gui::gestion_mode_manuel_fermer"
             pack   $actionspied.fermer -in $actionspied -side right -anchor w -padx 0

   }














   #
   # ::analyse_source::psf
   # Mesure de PSF d'une source
   #
   proc ::psf_gui::psf_listsources_no_auto { sent_listsources radius_threshold delta saturation} {
   
      upvar $sent_listsources listsources

      global bddconf

      set log 0
      set cpt 0
      set doute 0

      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]

      set nbs [::manage_source::get_nb_sources_by_cata $listsources "IMG"]
      if {$log} {gren_info "nb sources to work : $nbs \n"}

      lappend fields [::analyse_source::get_fieldastroid]

      set cpts 0
      set newsources {}

      foreach s $sources {
         incr cpts
         if {$log} {gren_info "source #$cpts : "}
         
         set cptc 0
         foreach cata $s {
            incr cptc
            if {$log} {
               gren_info " -> cata : $cptc [lindex $cata 0] "
            }
            if { [lindex $cata 0]=="ASTROID" } { break }

            if { [lindex $cata 0]=="IMG" } {

               set ra     [lindex [lindex [lindex $s 0] 1] 0]
               set dec    [lindex [lindex [lindex $s 0] 1] 1]
               set poserr [lindex [lindex [lindex $s 0] 1] 2]
               set mag    [lindex [lindex [lindex $s 0] 1] 3]
               set magerr [lindex [lindex [lindex $s 0] 1] 4]
               set x      [lindex [lindex [lindex $s 0] 2] 2]
               set y      [lindex [lindex [lindex $s 0] 2] 3]
               set fwhm   [lindex [lindex [lindex $s 0] 2] 24]

               if {$log} {
                  affich_un_rond $ra $dec red 4
                  gren_info " -> RA,DEC,x,y : $ra $dec $x $y\n"
               }

               # Mesure de PSF de la source: 
               # result = {$xsm $ysm $fwhmx $fwhmy $fwhm $fluxintegre $errflux $pixmax $intensite $sigmafond $snint $snpx $delta}
               set err [catch {set results [::tools_cdl::photom_methode $x $y $delta $bddconf(bufno)]} msg]
               if {$err} { 
                  gren_info "photom error ($err) ($msg)\n" 
                  set results -1
               } 

               if { $results == -1 } {
                  lappend newsources $s
               } else {
                  incr cpt
                  set xd [expr abs([lindex $results 0]-$x)]
                  set yd [expr abs([lindex $results 1]-$y)]
                  set rdiff [expr sqrt (pow($xd,2) + pow($yd ,2))]
                  if {$rdiff > $radius_threshold } {
                     lappend newsources $s
                     incr doute
                  } else {
                     # Ajoute rdiff, RA, DEC, res_ra, res_dec, omc_ra, omc_dec, mag, err_mag, name, flag*, cata* aux resultats
                     lappend results $rdiff $ra $dec $poserr $poserr 0.0 0.0 $mag $magerr "-" "-" "-" "-" "-"
                     # Reconstruit la liste des sources en ajoutant la source ASTROID
                     set ns {}
                     foreach cata $s {
                        if { [lindex $cata 0]!="ASTROID" } {
                           lappend ns $cata
                        }
                     }
                     lappend ns [list "ASTROID" {} $results]
                     lappend newsources $ns
                  }

               }
               break

            }

         }
         
      }

      if {$log} {gren_info "nb doute : $doute \n"}

   set listsources [list $fields $newsources]
   }
# source $audace(rep_install)/gui/audace/plugin/tool/bddimages/utils/ssp_sex/main.tcl

















   #
   # ::analyse_source::psf
   # Mesure de PSF d'une source
   #
   proc ::psf_gui::psf_listsources_auto { sent_listsources threshold limitradius saturation} {
   
      upvar $sent_listsources listsources

      global bddconf

      set log 0
      set cpt 0
      set doute 0

      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]

      set nbs [::manage_source::get_nb_sources_by_cata $listsources "IMG"]
      if {$log} {gren_info "nb sources to work : $nbs \n"}

      lappend fields [::analyse_source::get_fieldastroid]

      set cpts 0
      set newsources {}

      foreach s $sources {
         incr cpts
         if {$log} {gren_info "source #$cpts : "}
         
         # Mesure de PSF de la source: 
         # result = {$xsm $ysm $fwhmx $fwhmy $fwhm $fluxintegre $errflux $pixmax $intensite $sigmafond $snint $snpx $delta}

         set err [ catch {set r [::psf_tools::method_global s $threshold $limitradius ]} msg ]
         if {$err} {
            ::console::affiche_erreur "ERREUR PSF psf_listsources_auto: $msg\n"
         }
         lappend newsources $s

      }

      if {$log} {gren_info "nb doute : $doute \n"}

      set listsources [list $fields $newsources]
   }

#- Fin du namespace -------------------------------------------------
}
