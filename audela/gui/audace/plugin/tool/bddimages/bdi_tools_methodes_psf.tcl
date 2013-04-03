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
















   proc ::bdi_tools_methodes_psf::globale { x y bufNo } {
   
      # calcul des coordonnees celeste de l'objet demandé
      set radec [ buf$bufNo xy2radec [list $x $y ] ]
      set ra    [lindex $radec 0] 
      set dec   [lindex $radec 1]

      # Photometrie d ouverture
      for {set radius 1} {$radius < $::bdi_tools_psf::psf_limitradius} {incr radius} {

         set results($radius,err) [catch {set othf [::bdi_tools_methodes_psf::basic $x $y $radius $bufNo]} msg]

         # erreur de mesure
         if {$results($radius,err)} {
            continue
         }
         set err_psf [::bdi_tools_psf::get_val othf "err_psf"]
         # rejet si erreur psf
         if {$err_psf} {
            set results($radius,err) $err_psf
            continue
         }

         set results($radius) $othf
      }

   }














   proc ::bdi_tools_methodes_psf::basic { x y radius bufNo } {


         set xs0         [expr int($x - $radius)]
         set ys0         [expr int($y - $radius)]
         set xs1         [expr int($x + $radius)]
         set ys1         [expr int($y + $radius)]

         set valeurs     [buf$bufNo fitgauss [ list $xs0 $ys0 $xs1 $ys1 ] ]
         set taboid(fwhmx)       [lindex $valeurs 2]
         set taboid(fwhmy)       [lindex $valeurs 6]
         set taboid(fwhm)        [expr ($taboid(fwhmx) + $taboid(fwhmy))/2.]

         set taboid(xsm)         [lindex $valeurs 1]
         set taboid(ysm)         [lindex $valeurs 5]

         set taboid(radius)      $radius

         set xs0         [expr int($taboid(xsm) - $radius)]
         set ys0         [expr int($taboid(ysm) - $radius)]
         set xs1         [expr int($taboid(xsm) + $radius)]
         set ys1         [expr int($taboid(ysm) + $radius)]

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

         set taboid(err_psf)    "-"
         set taboid(fluxintegre) [lindex $valeurs 0]
         set taboid(med_sky)     [lindex $valeurs 1]
         set taboid(moy_sky)     [lindex $valeurs 2]
         set taboid(sigma_sky)   [lindex $valeurs 3]

         set taboid(npix)        [expr ($xs1 - $xs0 + 1) * ($ys1 - $ys0 + 1)]

         set valeurs             [buf$bufNo stat [list $xs0 $ys0 $xs1 $ys1] ]
         set taboid(pixmax)      [lindex $valeurs 2]
         set taboid(intensity)   [expr $taboid(pixmax) - $taboid(med_sky)]

         set taboid(snint)       [expr $taboid(fluxintegre) / sqrt ( $taboid(fluxintegre) + $taboid(npix) * $taboid(med_sky) )]
         set taboid(snpx)        [expr $taboid(intensity) / $taboid(sigma_sky)]

         # rejet si saturé
         if {$taboid(pixmax) > $::bdi_tools_psf::psf_saturation} {
            set taboid(err_psf)    "Saturated"
            set taboid(pixmax) "Max"
         }

         # calcul des coordonnees celeste de l'objet mesuré
         set radec [ buf$bufNo xy2radec [list $x $y ] ]
         set ra    [lindex $radec 0] 
         set dec   [lindex $radec 1]
         set radec [ buf$bufNo xy2radec [list $taboid(xsm) $taboid(ysm) ] ]
         set taboid(ra)  [lindex $radec 0] 
         set taboid(dec) [lindex $radec 1]

         set radiff   [expr ($taboid(ra) - $ra ) * cos($taboid(dec) * 3.141592653589793 / 180.0)]
         set decdiff  [expr $taboid(dec) - $dec ]
         set taboid(rdiff) [expr sqrt ( ( pow($radiff,2) + pow($decdiff,2) ) / 2.0 ) * 3600.0]

         # rejet si trop loin de la position demandée
         if {$taboid(rdiff) > $::bdi_tools_psf::psf_threshold} {
            set taboid(err_psf) "Far"
         }

         set othf [::bdi_tools_psf::get_astroid_null]
         foreach key [::bdi_tools_psf::get_basic_fields] {
            ::bdi_tools_psf::set_by_key othf $key $taboid($key)
         }
         return $othf

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

         set valeurs [buf$bufNo fitgauss $rect ]
         
         set intx        [lindex $valeurs 0]
         set taboid(xsm)         [lindex $valeurs 1]
         set taboid(fwhmx)       [lindex $valeurs 2]
         set fondx       [lindex $valeurs 3]
         set inty        [lindex $valeurs 4]
         set taboid(ysm)         [lindex $valeurs 5]
         set taboid(fwhmy)       [lindex $valeurs 6]
         set fondy       [lindex $valeurs 7]

         set taboid(intensity)   [expr ($intx + $inty)/2.]
         set taboid(fwhm)        [expr ($taboid(fwhmx) + $taboid(fwhmy))/2.]
         set taboid(moy_sky)     [expr ($fondx + $fondy)/2.]

         # calcul des coordonnees celeste de l'objet mesuré
         set radec [ buf$bufNo xy2radec [list $taboid(xsm) $taboid(ysm) ] ]
         set taboid(ra)  [lindex $radec 0] 
         set taboid(dec) [lindex $radec 1]

         set taboid(radius) [expr (abs($x1-$x2)+abs($y1-$y2))/4.0 ]

         set valeurs        [buf$bufNo stat [list $x1 $y1 $x2 $y2] ]
         set taboid(pixmax) [lindex $valeurs 2]

         set taboid(err_psf) "-"

         set othf [::bdi_tools_psf::get_astroid_null]
         foreach key [::bdi_tools_psf::get_fitgauss_fields] {
            ::bdi_tools_psf::set_by_key othf $key $taboid($key)
         }
         return $othf

   }









}
