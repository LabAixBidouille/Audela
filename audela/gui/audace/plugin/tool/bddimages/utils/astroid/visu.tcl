## \file visu.tcl
# Routines de visualisation dans une visu de Audace


## Affiche une image fits.
# \c fitsfile :: param[in] :: Chaine de caractere du nom du fichier fits

proc affich_image { fitsfile } {
   global bddconf
   global audace
   set errnum [catch {loadima $fitsfile} msg ]
   set bddconf(zoom) [::confVisu::getZoom $bddconf(visuno)]
   ::console::affiche_resultat "ZOOM=$bddconf(zoom)\n"
}



proc affich_rond { listsources catalog color width } {
   
   set fields  [lindex $listsources 0]
   set sources [lindex $listsources 1]
   foreach s $sources { 
      foreach cata $s {
         if { [lindex $cata 0] == $catalog } {
            set cm [lindex $cata 1]
            set ra [lindex $cm 0]
            set dec [lindex $cm 1]
            if {$ra != "" && $dec != ""} {
               affich_un_rond $ra $dec $color $width
            }
         }
      }
   }

}


proc affich_un_rond { ra dec color width } {

   global audace
   global bddconf
   set bufno $::bddconf(bufno)
   # Affiche un rond vert
   set img_xy [ buf$bufno radec2xy [ list $ra $dec ] ]
   set x [lindex $img_xy 0]
   set y [lindex $img_xy 1]
   #gren_info "affich_un_rond_xy $x $y $color 5 $width\n"
   affich_un_rond_xy $x $y $color 10 $width

}


proc affich_un_rond_xy { x y color radius width } {

   global audace

   set xi [expr $x - $radius]
   set yi [expr $y - $radius]
   set can_xy [ ::audace::picture2Canvas [list $xi $yi] ]
   set cxi [lindex $can_xy 0]
   set cyi [lindex $can_xy 1]

   set xs [expr $x + $radius]
   set ys [expr $y + $radius]
   set can_xy [ ::audace::picture2Canvas [list $xs $ys] ]
   set cxs [lindex $can_xy 0]
   set cys [lindex $can_xy 1]

   $audace(hCanvas) create oval $cxi $cyi $cxs $cys -outline $color -tags cadres -width $width
   
}


proc affich_un_rond_xy_crop { x y color radius width visuNo } {

   global audace

   set xi [expr $x - $radius]
   set yi [expr $y - $radius]
   set can_xy [::confVisu::picture2Canvas $visuNo [list $xi $yi ]]

   set cxi [lindex $can_xy 0]
   set cyi [lindex $can_xy 1]

   set xs [expr $x + $radius]
   set ys [expr $y + $radius]
   set can_xy [::confVisu::picture2Canvas $visuNo [list $xs $ys ]]
   set cxs [lindex $can_xy 0]
   set cys [lindex $can_xy 1]

   $::confVisu::private($visuNo,hCanvas) create oval $cxi $cyi $cxs $cys -outline $color -tags cadres -width $width
}


proc clean_crop { visuNo } {

      $::confVisu::private($visuNo,hCanvas) delete cadres

}


proc efface_rond { args } {
   global audace
   $audace(hCanvas) delete cadres
}


proc affich_un_carre_xy { x1 y1 x2 y2 color } {

   global audace

   set can1_xy [ ::audace::picture2Canvas [list $x1 $y1] ]
   set can2_xy [ ::audace::picture2Canvas [list $x2 $y2] ]

   $audace(hCanvas) create line [lindex $can1_xy 0] [lindex $can1_xy 1] [lindex $can2_xy 0] [lindex $can1_xy 1] -fill "$color" -tags carre -width 1.0
   $audace(hCanvas) create line [lindex $can2_xy 0] [lindex $can1_xy 1] [lindex $can2_xy 0] [lindex $can2_xy 1] -fill "$color" -tags carre -width 1.0
   $audace(hCanvas) create line [lindex $can2_xy 0] [lindex $can2_xy 1] [lindex $can1_xy 0] [lindex $can2_xy 1] -fill "$color" -tags carre -width 1.0
   $audace(hCanvas) create line [lindex $can1_xy 0] [lindex $can2_xy 1] [lindex $can1_xy 0] [lindex $can1_xy 1] -fill "$color" -tags carre -width 1.0
}


proc efface_carre { args } {
   global audace
   $audace(hCanvas) delete carre
}


#
# affich_vecteur
# Trace un vecteur
#
proc affich_vecteur { ra dec dra ddec factor color } {

   global audace 
   #--- coordonnees du centre du vecteur a tracer
   set img0_radec [ list $ra $dec ]
   set img0_xy [ buf$audace(bufNo) radec2xy $img0_radec ]
   set can0_xy [ ::audace::picture2Canvas $img0_xy ]
            
   #--- coordonnees du point final du vecteur
   set img1_radec [ list [expr [lindex $img0_radec 0]+$dra*$factor/3600.0] [expr [lindex $img0_radec 1]+$ddec*$factor/3600.0 ]]
   set img1_xy [ buf$audace(bufNo) radec2xy $img1_radec ]
   set can1_xy [ ::audace::picture2Canvas $img1_xy ]
   
   #--- trace du repere
   $audace(hCanvas) create line [lindex $can0_xy 0] [lindex $can0_xy 1] [lindex $can1_xy 0] [lindex $can1_xy 1] -fill "$color" -tags cadres -width 1.0 -arrow last
}

proc affich_libcata { { cata "usnoa2" } { limitmag -1 } { color "red" } { width 3 } } {

   global audace 
   cleanmark

   gren_info "catalog = $cata\n"
   gren_info "limitmag = $limitmag\n"
   gren_info "color = $color\n"
   gren_info "width = $width\n"
   
   if { $cata == "clean" } {
      return
   }

   set ra  [lindex [ buf$audace(bufNo) getkwd "RA"]  1]
   set dec [lindex [ buf$audace(bufNo) getkwd "DEC"] 1]

   set tabkey [::bdi_tools_image::get_tabkey_from_buffer]

   set naxis1 [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
   set naxis2 [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
   set scale_x [lindex [::bddimages_liste::lget $tabkey CD1_1] 1]
   set scale_y [lindex [::bddimages_liste::lget $tabkey CD2_2] 1]

   set lcd ""
   lappend lcd [lindex [::bddimages_liste::lget $tabkey CD1_1] 1]
   lappend lcd [lindex [::bddimages_liste::lget $tabkey CD1_2] 1]
   lappend lcd [lindex [::bddimages_liste::lget $tabkey CD2_1] 1]
   lappend lcd [lindex [::bddimages_liste::lget $tabkey CD2_2] 1]
   set mscale [::math::statistics::max $lcd]
   set radius [::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale]

   gren_info "ra = $ra\n"
   gren_info "dec = $dec\n"
   gren_info "radius = $radius\n"

   set ::tools_cata::nb 0
   set cata [string toupper $cata]

   set cmd          ""
   set path         ""
   set commonfields ""
      
   if { $cata == "USNOA2" } {
      set cmd          csusnoa2
      set path         $::tools_cata::catalog_usnoa2
      set commonfields { ra_deg dec_deg 5.0 magR 0.5 }
   }
   if { $cata == "TYCHO2" } {
      set cmd          cstycho2
      set path         $::tools_cata::catalog_tycho2
      set commonfields { RAdeg DEdeg 5.0 VT e_VT }
   }
   if { $cata == "UCAC2" } {
      set cmd          csucac2
      set path         $::tools_cata::catalog_ucac2
      set commonfields { ra_deg dec_deg e_pos_deg U2Rmag_mag 0.5 }
   }
   if { $cata == "UCAC3" } {
      set cmd          csucac3
      set path         $::tools_cata::catalog_ucac3
      set commonfields { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }
   }
   if { $cata == "UCAC4" } {
      set cmd          csucac4
      set path         $::tools_cata::catalog_ucac4
      set commonfields { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }
   }
   if { $cata == "PPMX" } {
      set cmd          csppmx
      set path         $::tools_cata::catalog_ppmx
      set commonfields { RAJ2000 DECJ2000 errDec Vmag ErrVmag }
   }
   if { $cata == "PPMXL" } {
      set cmd          csppmxl
      set path         $::tools_cata::catalog_ppmxl
      set commonfields { RAJ2000 DECJ2000 errDec magR1 0.5 }
   }
   if { $cata == "2MASS" } {
      set cmd          cs2mass
      set path         $::tools_cata::catalog_2mass
      set commonfields { ra_deg dec_deg err_dec jMag jMagError }
   }
   if { $cata == "wfibc" } {
      set cmd          cs2mass
      set path         $::tools_cata::catalog_2mass
      set commonfields { ra_deg dec_deg err_dec jMag jMagError }
   }
   
   if { $cmd == "" } {
      gren_erreur "Probleme $cata non reconnu\n"
      gren_erreur "cata possible : USNOA2 TYCHO2 UCAC2 \n"
      
      return
   }
   
   if { $limitmag == -1} {
      set listsources [$cmd $path $ra $dec $radius]
   } else {
      set listsources [$cmd $path $ra $dec $radius $limitmag 0]
   }
   gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"
   set listsources [::manage_source::set_common_fields $listsources $cata $commonfields]
   affich_rond $listsources $cata $color $width
   
   if { $cata == "usnoa2"} {
         if { $limitmag == -1} {
            set listsources [csusnoa2 $::tools_cata::catalog_tycho2 $ra $dec $radius]
         } else {
            set listsources [csusnoa2 $::tools_cata::catalog_tycho2 $ra $dec $radius $limitmag 0]
         }
         gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"
         set listsources [::manage_source::set_common_fields $listsources USNOA2 { RAdeg DEdeg 5.0 VT e_VT }]
         set ::tools_cata::nb [::manage_source::get_nb_sources_by_cata $listsources USNOA2]
         affich_rond $listsources USNOA2 $color $width
   }
   
   

   gren_info "nb = $::tools_cata::nb\n"
   
   
}

