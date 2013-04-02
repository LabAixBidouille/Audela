## \file bdi_tools_methodes_psf.tcl
#  \brief     Traitement des psf des images
#  \details   Ce namepsace concerne l'appel des methodes de mesures de psf sans GUI
#  \author    Frederic Vachier
#  \version   1.0
#  \date      2013
#  \copyright GNU Public License.
#  \par Ressource 
#  \code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_psf.tcl]
#  \endcode
#  \todo      normaliser les noms des fichiers sources 

#--------------------------------------------------
#
# source [ file join $audace(rep_plugin) tool bddimages bdi_tools_psf.tcl ]
#
#--------------------------------------------------
#
# Mise Ã  jour $Id: bdi_tools_psf.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------

## Declaration du namespace \c bdi_tools_psf .
#  @pre       Chargement a partir d'Audace
#  @bug       Probleme de memoire sur les exec
#  @warning   Appel SANS GUI
namespace eval bdi_tools_methodes_psf {








   proc ::bdi_tools_methodes_psf::get_methodes { } {
   
      return { fitgauss basic globale aphot bphot }
   
   }








   proc ::bdi_tools_methodes_psf::globale { x y bufNo } {
   
      # calcul des coordonnees celeste de l'objet demandé
      set radec [ buf$bufNo xy2radec [list $x $y ] ]
      set ra    [lindex $radec 0] 
      set dec   [lindex $radec 1]

      # Photometrie d ouverture
      for {set radius 1} {$radius < $::bdi_tools_psf::psf_limitradius} {incr radius} {

         set results($radius,err) [catch {set result [::bdi_tools_methodes_psf::photombasic $x $y $radius $bufNo]} msg]

         # rejet si echec avec la methode photombasic
         if {$result==-1} {
            set results($radius,err) 2
            continue
         }

         set xsm [lindex $result 0]
         set ysm [lindex $result 1]
         set pixmax [lindex $result 9]

         # rejet si saturé
         if {$pixmax > $::bdi_tools_psf::psf_saturation} {
            set results($radius,err) 4
            continue
         }

         # calcul des coordonnees celeste de l'objet mesuré
         set radec [ buf$bufNo xy2radec [list $xsm $ysm ] ]
         set pra   [lindex $radec 0] 
         set pdec  [lindex $radec 1]

         set radiff   [expr ($ra - $pra ) * cos($dec * 3.141592653589793 / 180.0)]
         set decdiff  [expr $dec - $pdec ]
         set rsecdiff [expr sqrt ( ( pow($radiff,2) + pow($decdiff,2) ) / 2.0 ) * 3600.0]

         # rejet si trop loin de la position demandée
         if {$rsecdiff > $::bdi_tools_psf::psf_threshold} {
            set results($radius,err) 3
            continue
         }

         set result [linsert $result end $rsecdiff $pra $pdec]
         set results($radius) $result
  
      }
        
   }








   proc ::bdi_tools_methodes_psf::basic { x y radius bufNo } {

         set xs0         [expr int($xsm - $radius)]
         set ys0         [expr int($ysm - $radius)]
         set xs1         [expr int($xsm + $radius)]
         set ys1         [expr int($ysm + $radius)]

         set valeurs     [buf$bufNo fitgauss [ list $xs0 $ys0 $xs1 $ys1 ] ]
         set fwhmx       [lindex $valeurs 2]
         set fwhmy       [lindex $valeurs 6]
         set fwhm        [expr ($fwhmx + $fwhmy)/2.]
         set xsm         [lindex $valeurs 1]
         set ysm         [lindex $valeurs 5]
         set err_xsm     0.0
         set err_ysm     0.0

         set xs0         [expr int($xsm - $radius)]
         set ys0         [expr int($ysm - $radius)]
         set xs1         [expr int($xsm + $radius)]
         set ys1         [expr int($ysm + $radius)]

         set r1          [expr int(1*$radius)]
         set r2          [expr int(2*$radius)]
         set r3          [expr int(2.6*$radius)]

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
        
         set npix [expr ($xs1 - $xs0 + 1) * ($ys1 - $ys0 + 1)]

         set valeurs     [buf$bufNo stat [list $xs0 $ys0 $xs1 $ys1] ]
         set pixmax      [lindex $valeurs 2]
         set intensite   [expr $pixmax - $fondmed]

         set snint       [expr $fluxintegre / sqrt ( $fluxintegre + $npix * $fondmed )]
         set snpx        [expr $intensite / $sigmafond]

         return [ list $xsm $ysm $err_xsm $err_ysm $fwhmx $fwhmy $fwhm $fluxintegre $errflux $pixmax $intensite $sigmafond $snint $snpx $radius] 


         # Calcul du signal sur bruit : 
         # S/N = fluxintegre / sqrt (fluxintegre + npix ( sky + offset + readnoise^2) )
         # avec
         # npix = nombre de pixel dans la fenetre de calcul du flux
         # sky  = (par pixel) valeur mediane du fond du ciel r2<r<r3
         # offset = (par pixel) valeur mediane de l'offset
         # readnoise = single pixel noise (electron RMS)


   }










   proc ::bdi_tools_methodes_psf::fitgauss { rect bufNo } {

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



         set valeurs     [buf$bufNo fitgauss $rect ]
         
         set intx        [lindex $valeurs 0]
         set xsm         [lindex $valeurs 1]
         set fwhmx       [lindex $valeurs 2]
         set fondx       [lindex $valeurs 3]
         set inty        [lindex $valeurs 4]
         set ysm         [lindex $valeurs 5]
         set fwhmy       [lindex $valeurs 6]
         set fondy       [lindex $valeurs 7]

         set intensite   [expr ($intx + $inty)/2.]
         set fwhm        [expr ($fwhmx + $fwhmy)/2.]
         set fond        [expr ($fondx + $fondy)/2.]

         set radius [expr (abs($x1-$x2)+abs($y1-$y2))/4.0 ]

         set valeurs     [buf$bufNo stat [list $x1 $y1 $x2 $y2] ]
         set pixmax      [lindex $valeurs 2]

         return [ list $xsm $ysm "Nan" "Nan" $fwhmx $fwhmy $fwhm "Nan" "Nan" $pixmax $intensite "Nan" "Nan" "Nan" $radius] 

   }









}
