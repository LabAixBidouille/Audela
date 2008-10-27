#
# Fichier : snvisuzoom.tcl
# Description : Creation d'une loupe de visualisation en association avec Sn Visu
# Auteur : Alain KLOTZ
# Mise a jour $Id: snvisuzoom.tcl,v 1.7 2008-10-27 21:50:07 robertdelmas Exp $
#

#--- Chargement des captions
global audace

source [ file join $audace(rep_plugin) tool supernovae snvisuzoom.cap ]

proc sn_visuzoom_g { { zoom 3 } } {
   global audace
   global caption
   global conf
   global snvisu
   global snconfvisu
   global zone
   global num

   #---
   if { ! [ info exists conf(snvisuzoom_g,position) ] } { set conf(snvisuzoom_g,position) "+125+340" }

   #---
   if { [ info exists snvisu(geometry_g) ] } {
      set deb [ expr 1 + [ string first + $snvisu(geometry_g) ] ]
      set fin [ string length $snvisu(geometry_g) ]
      set conf(snvisuzoom_g,position) "+[ string range $snvisu(geometry_g) $deb $fin ]"
   }

   #--- Cree la fenetre $audace(base).snvisuzoom_g de niveau le plus haut
   toplevel $audace(base).snvisuzoom_g
   wm transient $audace(base).snvisuzoom_g $audace(base).snvisu
   wm deiconify $audace(base).snvisuzoom_g
   wm geometry $audace(base).snvisuzoom_g 200x200$conf(snvisuzoom_g,position)
   wm resizable $audace(base).snvisuzoom_g 0 0
   wm title $audace(base).snvisuzoom_g $caption(snvisuzoom,zoom_main_title)
   wm protocol $audace(base).snvisuzoom_g WM_DELETE_WINDOW {
      ::recup_position_snvisuzoom_g ; destroy $audace(base).snvisuzoom_g
   }

   #--- Attente affichage
   label $audace(base).snvisuzoom_g.label -text $caption(snvisuzoom,wait)
   pack $audace(base).snvisuzoom_g.label -pady 20

   #--- Cree le nouveau canevas pour l'image
   sn_Scrolled_Canvas $audace(base).snvisuzoom_g.image1 right -borderwidth 0 -relief flat \
      -width 150 -height 150 -scrollregion {0 0 0 0}
   $audace(base).snvisuzoom_g.image1.canvas configure -borderwidth 0
   $audace(base).snvisuzoom_g.image1.canvas configure -relief flat
   set zone(image1_zoom) $audace(base).snvisuzoom_g.image1.canvas

   #--- Declare un nouvel objet de visualisation pour afficher le contenu du buffer
   #--- ::visu::create bufNo imageNo [ visuNo ]
   set num(loupeGaucheVisuNo) "2000"
   if {$snvisu(afflog)==0} {
      ::visu::create $num(buffer1) $num(loupeGaucheVisuNo) $num(loupeGaucheVisuNo)
   } else {
      ::visu::create $num(buffer1b) $num(loupeGaucheVisuNo) $num(loupeGaucheVisuNo)
   }

   #--- Cree un widget image dans un canvas pour afficher l'objet de visualisation
   $zone(image1_zoom) create image 0 0 -image image$num(loupeGaucheVisuNo) -anchor nw -tag img4

   visu$num(loupeGaucheVisuNo) zoom $zoom
   set zone(naxis1_zoom) [expr int($zone(naxis1)*$zoom)]
   set zone(naxis2_zoom) [expr int($zone(naxis2)*$zoom)]
   $zone(image1_zoom) configure -scrollregion [list 0 0 $zone(naxis1_zoom) $zone(naxis2_zoom)]

   #--- Cree un frame pour le reglage des niveaux de visualisation
   frame $audace(base).snvisuzoom_g.frame1 -borderwidth 0 -cursor arrow

       scale $audace(base).snvisuzoom_g.frame1.sca1 -orient horizontal -to 32767 -from -10000 \
          -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
          -background $audace(color,cursor_blue) -activebackground $audace(color,cursor_blue_actif) \
          -relief raised -command changeHiCut2000
       pack $audace(base).snvisuzoom_g.frame1.sca1 \
          -in $audace(base).snvisuzoom_g.frame1 -anchor s -side left -expand 1 -fill x -padx 0

   pack $audace(base).snvisuzoom_g.frame1 -in $audace(base).snvisuzoom_g \
      -anchor s -side bottom -expand 0 -fill x

   set zone(sh2000) $audace(base).snvisuzoom_g.frame1.sca1

   #--- Definition du binding
   if { [ string tolower "$snconfvisu(cuts_change)" ] == "motion" } {
      bind $zone(sh2000) <Motion> { visu$num(loupeGaucheVisuNo) disp }
   } else {
      bind $zone(sh2000) <ButtonRelease> { visu$num(loupeGaucheVisuNo) disp }
   }

   #--- La nouvelle fenetre est active
   focus $audace(base).snvisuzoom_g

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).snvisuzoom_g
}

proc recup_position_snvisuzoom_g { } {
   global audace
   global conf
   global snvisu

   set snvisu(geometry_g) [ wm geometry $audace(base).snvisuzoom_g ]
   set deb [ expr 1 + [ string first + $snvisu(geometry_g) ] ]
   set fin [ string length $snvisu(geometry_g) ]
   set conf(snvisuzoom_g,position) "+[ string range $snvisu(geometry_g) $deb $fin ]"
}

proc sn_visuzoom_disp_g { { x 1 } { y 1 } { zoom 3 } } {
   global audace
   global zone
   global num
   global snvisu

   set disp "0"
   if {[string length [info commands $audace(base).snvisuzoom_g.*]]==0} {
      sn_visuzoom_g "3"
      set disp "1"
   }
   set x [expr int($x-200./2./$zoom-$zoom)]
   set y [expr int($y+200./2./$zoom+$zoom)]
   set fracx [expr 1.*$x/$zone(naxis1)]
   set fracy [expr 1.-1.*$y/$zone(naxis2)]
   $audace(base).snvisuzoom_g.image1.canvas xview moveto $fracx
   $audace(base).snvisuzoom_g.image1.canvas yview moveto $fracy
   if { $disp == "1" } {
      #--- Affichage en mode normal
      set sh $snvisu(seuil_1_haut)
      set sb $snvisu(seuil_1_bas)
      visu$num(loupeGaucheVisuNo) cut [ list $sh $sb ]
      #--- Affichage en mode logarithme
      if {$snvisu(afflog)==1} {
         visu$num(loupeGaucheVisuNo) cut [sn_buflog $num(buffer1) $num(buffer1b)]
      }
      #---
      visu$num(loupeGaucheVisuNo) disp
      destroy $audace(base).snvisuzoom_g.label
      pack $audace(base).snvisuzoom_g.image1 \
         -in $audace(base).snvisuzoom_g -expand 1 -side top -anchor center -fill both
      #---
      if {$snvisu(afflog)==0} {
         set nume $num(buffer1)
      } else {
         set nume $num(buffer1b)
      }
      #---
      set scalecut [lindex [get_seuils $nume] 0]
      set s        [ buf$nume stat ]
      set scalemax [lindex $s 2]
      set scalemin [lindex $s 3]
      if {($scalecut>=$scalemin)&&($scalecut<=$scalemax)} {
         set ds1 [expr $scalemax-$scalecut]
         set ds2 [expr $scalecut-$scalemin]
         if {$ds1>$ds2} {
            set scalemin [expr $scalecut-$ds1]
         } else {
            set scalemax [expr $scalecut+$ds2]
         }
      }
      $zone(sh2000) set $scalecut
      $zone(sh2000) configure -to $scalemax -from $scalemin
      update
   }
}

proc sn_visuzoom_d { { zoom 3 } } {
   global audace
   global caption
   global conf
   global snvisu
   global snconfvisu
   global zone
   global num

   #---
   if { ! [ info exists conf(snvisuzoom_d,position) ] } { set conf(snvisuzoom_d,position) "+525+340" }

   #---
   if { [ info exists snvisu(geometry_d) ] } {
      set deb [ expr 1 + [ string first + $snvisu(geometry_d) ] ]
      set fin [ string length $snvisu(geometry_d) ]
      set conf(snvisuzoom_d,position) "+[ string range $snvisu(geometry_d) $deb $fin ]"
   }

   #--- Cree la fenetre $audace(base).snvisuzoom_d de niveau le plus haut
   toplevel $audace(base).snvisuzoom_d
   wm transient $audace(base).snvisuzoom_d $audace(base).snvisu
   wm deiconify $audace(base).snvisuzoom_d
   wm geometry $audace(base).snvisuzoom_d 200x200$conf(snvisuzoom_d,position)
   wm resizable $audace(base).snvisuzoom_d 0 0
   wm title $audace(base).snvisuzoom_d $caption(snvisuzoom,zoom_main_title_d)
   wm protocol $audace(base).snvisuzoom_d WM_DELETE_WINDOW {
      ::recup_position_snvisuzoom_d ; destroy $audace(base).snvisuzoom_d
   }

   #--- Attente affichage
   label $audace(base).snvisuzoom_d.label -text $caption(snvisuzoom,wait)
   pack $audace(base).snvisuzoom_d.label -pady 20

   #--- Cree le nouveau canevas pour l'image
   sn_Scrolled_Canvas $audace(base).snvisuzoom_d.image2 right -borderwidth 0 -relief flat \
      -width 150 -height 150 -scrollregion {0 0 0 0}
   $audace(base).snvisuzoom_d.image2.canvas configure -borderwidth 0
   $audace(base).snvisuzoom_d.image2.canvas configure -relief flat
   set zone(image2_zoom) $audace(base).snvisuzoom_d.image2.canvas

   #--- Declare un nouvel objet de visualisation pour afficher le contenu du buffer
   #--- ::visu::create bufNo imageNo [ visuNo ]
   set num(loupeDroiteVisuNo) "2001"
   if {$snvisu(afflog)==0} {
      ::visu::create $num(buffer2) $num(loupeDroiteVisuNo) $num(loupeDroiteVisuNo)
   } else {
      ::visu::create $num(buffer2b) $num(loupeDroiteVisuNo) $num(loupeDroiteVisuNo)
   }
   #--- Cree un widget image dans un canvas pour afficher l'objet de visualisation
   $zone(image2_zoom) create image 0 0 -image image$num(loupeDroiteVisuNo) -anchor nw -tag img5

   visu$num(loupeDroiteVisuNo) zoom $zoom
   set zone(naxis1_zoom_2) [expr int($zone(naxis1_2)*$zoom)]
   set zone(naxis2_zoom_2) [expr int($zone(naxis2_2)*$zoom)]
   $zone(image2_zoom) configure -scrollregion [list 0 0 $zone(naxis1_zoom_2) $zone(naxis2_zoom_2)]

   #--- Cree un frame pour le reglage des niveaux de visualisation
   frame $audace(base).snvisuzoom_d.frame1 -borderwidth 0 -cursor arrow

       scale $audace(base).snvisuzoom_d.frame1.sca1 -orient horizontal -to 32767 -from -10000 \
          -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
          -background $audace(color,cursor_blue) -activebackground $audace(color,cursor_blue_actif) \
          -relief raised -command changeHiCut2001
       pack $audace(base).snvisuzoom_d.frame1.sca1 \
          -in $audace(base).snvisuzoom_d.frame1 -anchor s -side left -expand 1 -fill x -padx 0

   pack $audace(base).snvisuzoom_d.frame1 -in $audace(base).snvisuzoom_d \
      -anchor s -side bottom -expand 0 -fill x

   set zone(sh2001) $audace(base).snvisuzoom_d.frame1.sca1

   #--- Definition du binding
   if { [ string tolower "$snconfvisu(cuts_change)" ] == "motion" } {
      bind $zone(sh2001) <Motion> { visu$num(loupeDroiteVisuNo) disp }
   } else {
      bind $zone(sh2001) <ButtonRelease> { visu$num(loupeDroiteVisuNo) disp }
   }

   #--- La nouvelle fenetre est active
   focus $audace(base).snvisuzoom_d

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).snvisuzoom_d
}

proc recup_position_snvisuzoom_d { } {
   global audace
   global conf
   global snvisu

   set snvisu(geometry_d) [ wm geometry $audace(base).snvisuzoom_d ]
   set deb [ expr 1 + [ string first + $snvisu(geometry_d) ] ]
   set fin [ string length $snvisu(geometry_d) ]
   set conf(snvisuzoom_d,position) "+[ string range $snvisu(geometry_d) $deb $fin ]"
}

proc sn_visuzoom_disp_d { { x 1 } { y 1 } { zoom 3 } } {
   global audace
   global zone
   global num
   global snvisu

   set disp "0"
   if {[string length [info commands $audace(base).snvisuzoom_d.*]]==0} {
      sn_visuzoom_d "3"
      set disp "1"
   }
   set x [expr int($x-200./2./$zoom-$zoom)]
   set y [expr int($y+200./2./$zoom+$zoom)]
   set fracx [expr 1.*$x/$zone(naxis1_2)]
   set fracy [expr 1.-1.*$y/$zone(naxis2_2)]
   $audace(base).snvisuzoom_d.image2.canvas xview moveto $fracx
   $audace(base).snvisuzoom_d.image2.canvas yview moveto $fracy
   if { $disp == "1" } {
      #--- Affichage en mode normal
      set sh $snvisu(seuil_2_haut)
      set sb $snvisu(seuil_2_bas)
      visu$num(loupeDroiteVisuNo) cut [ list $sh $sb ]
      #--- Affichage en mode logarithme
      if {$snvisu(afflog)==1} {
         visu$num(loupeDroiteVisuNo) cut [sn_buflog $num(buffer2) $num(buffer2b)]
      }
      #---
      visu$num(loupeDroiteVisuNo) disp
      destroy $audace(base).snvisuzoom_d.label
      pack $audace(base).snvisuzoom_d.image2 \
         -in $audace(base).snvisuzoom_d -expand 1 -side top -anchor center -fill both
      #---
      if {$snvisu(afflog)==0} {
         set nume $num(buffer2)
      } else {
         set nume $num(buffer2b)
      }
      #---
      set scalecut [lindex [get_seuils $nume] 0]
      set s        [ buf$nume stat ]
      set scalemax [lindex $s 2]
      set scalemin [lindex $s 3]
      if {($scalecut>=$scalemin)&&($scalecut<=$scalemax)} {
         set ds1 [expr $scalemax-$scalecut]
         set ds2 [expr $scalecut-$scalemin]
         if {$ds1>$ds2} {
            set scalemin [expr $scalecut-$ds1]
         } else {
            set scalemax [expr $scalecut+$ds2]
         }
      }
      $zone(sh2001) set $scalecut
      $zone(sh2001) configure -to $scalemax -from $scalemin
      update
   }
}

proc changeHiCut2000 { foo } {
   global num

   set sbh [visu$num(loupeGaucheVisuNo) cut]
   visu$num(loupeGaucheVisuNo) cut [list $foo [lindex $sbh 1]]
}

proc changeHiCut2001 { foo } {
   global num

   set sbh [visu$num(loupeDroiteVisuNo) cut]
   visu$num(loupeDroiteVisuNo) cut [list $foo [lindex $sbh 1]]
}

