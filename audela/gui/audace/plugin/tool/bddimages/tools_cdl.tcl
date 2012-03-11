#--------------------------------------------------
# source audace/plugin/tool/bddimages/gui_cdl_withwcs.tcl
#--------------------------------------------------
#
# Fichier        : gui_cdl_withwcs.tcl
# Description    : Environnement d analyse de courbes de lumiere  
#                  pour des images qui ont un wcs
# Auteur         : Frederic Vachier
# Mise à jour $Id: bddimages_liste.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
namespace eval tools_cdl {

   variable id_current_image
   variable current_image
   variable current_cata
   variable current_image_name
   variable current_image_date
   variable current_image_jjdate
   variable img_list
   variable nb_img_list
   variable current_listsources
   variable tabphotom
   variable tabsource
   variable saturation
   variable movingobject 
   variable bestdelta  
   variable deltamin 
   variable deltamax 
   variable magref 
   variable starref 
   variable firstrefstar 









   proc ::tools_cdl::select_obj { rect bufNo } {

      # Affichage de la taille de la fenetre
      if {$rect!=""} {

          set xsm [expr ([lindex $rect 0] + [lindex $rect 2]) / 2. ]
          set ysm [expr ([lindex $rect 1] + [lindex $rect 3]) / 2. ]
          set deltax [expr abs([lindex $rect 0] - [lindex $rect 2]) / 2.  ]
          set deltay [expr abs([lindex $rect 1] - [lindex $rect 3]) / 2.  ]
          if {$deltax < $deltay} {
             set delta $deltay
          } else {
             set delta $deltax
          }

         set valeurs  [::tools_cdl::photom_methode $xsm $ysm $delta $bufNo]
         set xsm      [lindex $valeurs 0]
         set ysm      [lindex $valeurs 1]

         return [list $xsm $ysm]
      }

      return false
   }




   proc ::tools_cdl::mesure_obj { xsm ysm delta bufNo } {

         set valeurs [::tools_cdl::photom_methode $xsm $ysm $delta $bufNo]
         return $valeurs
   }




   proc ::tools_cdl::photom_methode { xsm ysm delta bufNo} {

         set xs0         [expr int($xsm - $delta)]
         set ys0         [expr int($ysm - $delta)]
         set xs1         [expr int($xsm + $delta)]
         set ys1         [expr int($ysm + $delta)]

         set valeurs     [buf$bufNo fitgauss [ list $xs0 $ys0 $xs1 $ys1 ] ]
         set fwhmx       [lindex $valeurs 2]
         set fwhmy       [lindex $valeurs 6]
         set fwhm        [expr ($fwhmx + $fwhmy)/2.]
         set xsm         [lindex $valeurs 1]
         set ysm         [lindex $valeurs 5]

         set xs0         [expr int($xsm - $delta)]
         set ys0         [expr int($ysm - $delta)]
         set xs1         [expr int($xsm + $delta)]
         set ys1         [expr int($ysm + $delta)]

         set r1          [expr int(1*$delta)]
         set r2          [expr int(1.25*$delta)]
         set r3          [expr int(1.75*$delta)]

         if {0} {
            if {$r1<1} {set r1 1}
            if {$r2<$r1} {set r2 $r1}
            if {$r3<[expr $r2+1]} {set r3 [expr $r2+1]}
            gren_info "--- photom --- \n"
            gren_info "xs0  = $xs0 \n"
            gren_info "ys0  = $ys0 \n"
            gren_info "xs1  = $xs1 \n"
            gren_info "ys1  = $ys1 \n"
            gren_info "r1   = $r1  \n"
            gren_info "r2   = $r2  \n"
            gren_info "r3   = $r3  \n"
            gren_info "--- \n"
         }

         set err [ catch { set valeurs [buf$bufNo photom [list $xs0 $ys0 $xs1 $ys1] square $r1 $r2 $r3 ] } msg ]
         if {$err} {
            return -1
         }

         set fluxintegre [lindex $valeurs 0]
         set fondmed     [lindex $valeurs 1]
         set fondmoy     [lindex $valeurs 2]
         set sigmafond   [lindex $valeurs 3]
         set errflux 0

         set valeurs     [buf$bufNo stat [list $xs0 $ys0 $xs1 $ys1] ]
         set pixmax      [lindex $valeurs 2]
         set intensite   [expr $pixmax - $fondmed]

         set snint       [expr $fluxintegre / $sigmafond]
         set snpx        [expr $intensite / $sigmafond]

         return [ list $xsm $ysm $fwhmx $fwhmy $fwhm $fluxintegre $errflux $pixmax $intensite $sigmafond $snint $snpx $delta] 
   }















# Fin du namespace
}
