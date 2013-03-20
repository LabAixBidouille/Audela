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
   affich_un_rond_xy $x $y $color 5 $width

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
