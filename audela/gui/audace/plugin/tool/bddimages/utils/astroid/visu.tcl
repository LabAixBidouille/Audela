proc affich_image { fitsfile } {
   global bddconf
   global audace
   set errnum [catch {loadima $fitsfile} msg ]
   set bddconf(zoom) [::confVisu::getZoom $bddconf(visuno)]
   ::console::affiche_resultat "ZOOM=$bddconf(zoom)\n"


}



proc affich_rond { listsources catalog color width } {
   
   #::console::affiche_resultat "AFFICH_CATALOG=($catalog, $color, $width) NB=[llength [lindex $listsources 1]]\n"
      
   set fields  [lindex $listsources 0]
   set sources [lindex $listsources 1]
   foreach s $sources { 
      #gren_info "s =  $s \n"
      foreach cata $s {
         #gren_info "cata =  $cata \n"
         if { [lindex $cata 0]==$catalog } {
            set cm [lindex $cata 1]
            #gren_info "cm =  $cm \n"
            set ra [lindex $cm 0]
            set dec [lindex $cm 1]
            if {$ra!=""&&$dec!=""} {
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
       #gren_info "DD =  $ra $dec \n"
       # Affiche un rond vert
       set img_xy [ buf$bufno radec2xy [ list $ra $dec ] ]
       gren_info "img_xy =  $img_xy \n"
       #--- Transformation des coordonnees image en coordonnees canvas
       set can_xy [ ::audace::picture2Canvas $img_xy ]
       set x [lindex $can_xy 0]
       set y [lindex $can_xy 1]
       # gren_info "XY =  $x $y \n"
       set radius 5           
       #--- Dessine l'objet selectionne en vert dans l'image
       $audace(hCanvas) create oval [ expr $x - $radius ] [ expr $y - $radius ] [ expr $x + $radius ] [ expr $y + $radius ] \
           -outline $color -tags cadres -width $width

}

proc affich_un_rond_xy { x y color radius width } {

   global audace
    set can_xy [ ::audace::picture2Canvas [list $x $y] ]
    set x [lindex $can_xy 0]
    set y [lindex $can_xy 1]
    $audace(hCanvas) create oval [ expr $x - $radius ]  \
        [ expr $y - $radius ] [ expr $x + $radius ] [ expr $y + $radius ] \
        -outline $color -tags cadres -width $width

}


proc efface_rond { args } {
   global audace conf bddconf
   #--- Efface les reperes des objets
   $audace(hCanvas) delete cadres
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
