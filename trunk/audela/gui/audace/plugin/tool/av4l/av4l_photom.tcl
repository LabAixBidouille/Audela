#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_extraction.tcl
#--------------------------------------------------
#
# Fichier        : av4l_extraction.tcl
# Description    : Affiche le status de la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: av4l_extraction.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval ::av4l_photom {

   variable rect_img
   variable rect_obj

   proc select_fullimg { visuNo this } {

      global color
      
      # Recuperation du Rectangle de l image
      set rect  [ ::confVisu::getBox $visuNo ]
      
      # Affichage de la taille de la fenetre
      if {$rect==""} {
         $this.v.r.fenetre configure -text "Error" -fg $color(red)
         set ::av4l_photom::rect_img ""
      } else {
         set taillex [expr [lindex $rect 2] - [lindex $rect 0] ]
         set tailley [expr [lindex $rect 3] - [lindex $rect 1] ]
         $this.v.r.fenetre configure -text "${taillex}x${tailley}" -fg $color(blue)
         set ::av4l_photom::rect_img $rect
      }
      get_fullimg $visuNo $this
      
   }
   
   
   proc get_fullimg { visuNo this } {
   
      ::console::affiche_resultat "rect_img = $::av4l_photom::rect_img \n"

      if {$::av4l_photom::rect_img==""} { 
         $this.v.r.intmin configure -text "?"
         $this.v.r.intmax configure -text "?"
         $this.v.r.intmoy configure -text "?"
         $this.v.r.sigma  configure -text "?"
      
      } else {
         set bufNo [ ::confVisu::getBufNo $visuNo ]
         set stat [buf$bufNo stat $::av4l_photom::rect_img]
         $this.v.r.intmin configure -text [lindex $stat 3]
         $this.v.r.intmax configure -text [lindex $stat 2]
         $this.v.r.intmoy configure -text [lindex $stat 4]
         $this.v.r.sigma  configure -text [lindex $stat 5]
      }
   }







   proc select_obj { visuNo this } {

      global color
      
      # Recuperation du Rectangle de l image
      set rect  [ ::confVisu::getBox $visuNo ]
      
      # Affichage de la taille de la fenetre
      if {$rect==""} {
         $this.v.r.fenetre configure -text "Error" -fg $color(red)
         set ::av4l_photom::pos_obj ""
      } else {

          set xsm [expr ([lindex $rect 0] + [lindex $rect 2]) / 2. ]
          set ysm [expr ([lindex $rect 1] + [lindex $rect 3]) / 2. ]
          set deltax [expr abs([lindex $rect 0] - [lindex $rect 2]) / 2.  ]
          set deltay [expr abs([lindex $rect 1] - [lindex $rect 3]) / 2.  ]
          if {$deltax < $deltay} {
             set delta $deltay
          } else {
             set delta $deltax
          }
         set valeurs  [photom_methode $xsm $ysm $delta]
         set xsm      [lindex $valeurs 0]
         set ysm      [lindex $valeurs 1]
         set fluxs    [lindex $valeurs 2]
         set errfluxs [lindex $valeurs 3]
         set fwhms    [lindex $valeurs 4]
         set sigmas   [lindex $valeurs 5]
         set snb      [lindex $valeurs 6]




         set taillex [expr [lindex $rect 2] - [lindex $rect 0] ]
         set tailley [expr [lindex $rect 3] - [lindex $rect 1] ]
         $this.v.r.position configure -text "${taillex}x${tailley}" -fg $color(blue)
         set ::av4l_photom::rect_img $rect
      }
      get_obj $visuNo $this
      
   }
   
   
   proc get_obj { visuNo this } {
   
      ::console::affiche_resultat "rect_img = $::av4l_photom::rect_obj \n"

      if {$::av4l_photom::rect_obj==""} { 
         $this.v.r.int configure -text "?"
         $this.v.r.fwhm configure -text "?"
         $this.v.r.delta configure -text "?"
         $this.v.r.snb configure -text "?"
      
      } else {
         set bufNo [ ::confVisu::getBufNo $visuNo ]
         set stat [buf$bufNo stat $::av4l_photom::rect_img]
         $this.v.r.int configure -text [lindex $stat 3]
         $this.v.r.fwhm configure -text [lindex $stat 2]
      }
   }





proc photom_methode { xsm ysm delta bufNo} {

      set xs0 [expr int($xsm - $delta)]
      set ys0 [expr int($ysm - $delta)]
      set xs1 [expr int($xsm + $delta)]
      set ys1 [expr int($ysm + $delta)]

      set valeurs [  buf$bufNo fitgauss [ list $xs0 $ys0 $xs1 $ys1 ] ]
      set fwhm [expr ([lindex $valeurs 2] + [lindex $valeurs 6])/2.]
      set xsm  [lindex $valeurs 1]
      set ysm  [lindex $valeurs 5]

      set xs0 [expr int($xsm - $delta)]
      set ys0 [expr int($ysm - $delta)]
      set xs1 [expr int($xsm + $delta)]
      set ys1 [expr int($ysm + $delta)]

      set r1  [expr int(1*$delta)]
      set r2  [expr int(1.25*$delta)]
      set r3  [expr int(1.75*$delta)]

      set valeurs [  buf$bufNo photom [list $xs0 $ys0 $xs1 $ys1] square $r1 $r2 $r3 ]
      set flux    [lindex $valeurs 0]
      set sigma   [lindex $valeurs 3]
      set sn      [expr $flux/$sigma]
      set errflux 0
      #::console::affiche_erreur "M3 r1 r2 r3 flux sigma = $r1 $r2 $r3 $flux $sigma\n"

      #::console::affiche_resultat "flux int photom = $flux \n"

      return [ list $xsm $ysm $flux $errflux $fwhm $sigma $sn]
   }



}
