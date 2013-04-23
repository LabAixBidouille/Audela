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
   
      set valmax 10000000000
      
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
         if {$err_psf=="Saturated"} {
            ::bdi_tools_psf::set_photom_error othf $err_psf
            return $othf
         }
         if {$err_psf!=""} {
            set results($radius,err) $err_psf
            continue
         }

         set results($radius) $othf
      }

      set pos_flux [::bdi_tools_psf::get_id_astroid "flux"]
      set pos_fwhm [::bdi_tools_psf::get_id_astroid "fwhm"]
      set pos_xsm  [::bdi_tools_psf::get_id_astroid "xsm" ]
      set pos_ysm  [::bdi_tools_psf::get_id_astroid "ysm" ]

      # statistique sur le FLUX
      set tabflux ""
      for {set radius 1} {$radius < $::bdi_tools_psf::psf_limitradius} {incr radius} {
         if {$results($radius,err)==0} {
            lappend tabflux [lindex $results($radius) $pos_flux]
         }
      }
      set nb [llength $tabflux]
      if {$nb>=1} {
         set median_flux      [::math::statistics::median $tabflux ]
         set stdev_flux       [::math::statistics::stdev  $tabflux ]
      } else {
         ::bdi_tools_psf::set_photom_error othf "Error"
         gren_erreur "globale erreur...\n"
         return $othf
      }

      # crop sur le FLUX
      # ici on fait 1 passe
      for {set i 0} {$i<1} {incr i} {
         set tabflux ""
         set tabfwhm ""
         set fluxmin  [expr  $median_flux - $stdev_flux]
         for {set radius 1} {$radius < $::bdi_tools_psf::psf_limitradius} {incr radius} {
            if {$results($radius,err)==0} {
               set flux  [lindex $results($radius) $pos_flux]
               if {$flux < $fluxmin } {
                  set results($radius,err) 4
               } else {
                  lappend tabflux $flux
                  lappend tabfwhm [lindex $results($radius) $pos_fwhm]
               }
            }
         }
         # recalcule des statistiques pour les autres passes
         set nb  [llength $tabflux]
         if {$nb>=1} {
            set median_flux [::math::statistics::median $tabflux]
            set stdev_flux  [::math::statistics::stdev  $tabflux]
            set median_fwhm [::math::statistics::median $tabfwhm]
            set stdev_fwhm  [::math::statistics::stdev  $tabfwhm]
         } else {
            # @todo gerer le cas quand la photometrie ne renvoit pas de donnees
         }
      }

      # crop sur la FWHM
      # ici on fait 1 passe
      for {set i 0} {$i<1} {incr i} {
         set fwhmmin  [expr  $median_fwhm - $stdev_fwhm]
         set fwhmmax  [expr  $median_fwhm + $stdev_fwhm]
         for {set radius 1} {$radius < $::bdi_tools_psf::psf_limitradius} {incr radius} {
            if {$results($radius,err)==0} {
               set fwhm [lindex $results($radius) $pos_fwhm]
               if {$fwhm < $fwhmmin || $fwhm > $fwhmmax} {
                  set results($radius,err) 5
               } else {
                  lappend tabfwhm  $fwhm
               }
            }
         }
         # recalcule des statistiques pour les autres passes
         set nb [llength $tabfwhm]
         if {$nb>=1} {
            set median_fwhm [::math::statistics::median $tabfwhm]
            set stdev_fwhm  [::math::statistics::stdev  $tabfwhm]
         } else {
            # @todo gerer le cas quand la photometrie ne renvoit pas de donnees
         }
      }
         
      # recherche du radius equivalent basé sur le flux
      set dmin $valmax
      set taboid(radius) 0
      for {set radius 1} {$radius < $::bdi_tools_psf::psf_limitradius} {incr radius} {
         if {$results($radius,err)==0} {
            set r  [lindex $results($radius) $pos_flux]
            set d [expr abs($r - $median_fwhm)]
            if {$d < $dmin } {
               set taboid(radius) $radius
               set dmin $d 
            }
         }
      }

      set listfield [list xsm ysm fwhmx fwhmy fwhm flux pixmax intensity sky err_sky snint rdiff ra dec]

      # Graphes
      for {set radius 1} {$radius < $::bdi_tools_psf::psf_limitradius} {incr radius} {
         set ::bdi_tools_psf::graph_results($radius,err) $results($radius,err)
         if {$results($radius,err)==0} {
            foreach field $listfield {
               set pos [::bdi_tools_psf::get_id_astroid $field]
               set ::bdi_tools_psf::graph_results($radius,$field) [lindex $results($radius) $pos]
            }
         }
      }

      # Solution
      set listfield [list xsm ysm fwhmx fwhmy fwhm flux pixmax intensity sky err_sky snint rdiff ra dec]
      foreach field $listfield {
         set tab ""
         for {set radius 1} {$radius < $::bdi_tools_psf::psf_limitradius} {incr radius} {
            if {$results($radius,err)==0} {
               set pos [::bdi_tools_psf::get_id_astroid $field]
               lappend tab [lindex $results($radius) $pos]
            }
         }
         # Stat
         set taboid($field) [::math::statistics::mean $tab]
         if {$field=="xsm"} {
            set taboid(err_xsm) [ expr 2.0 * [::math::statistics::stdev $tab] ]
         }
         if {$field=="ysm"} {
            set taboid(err_ysm) [ expr 2.0 * [::math::statistics::stdev $tab] ]
         }
         if {$field=="flux"} {
            set taboid(err_flux) [ expr 2.0 * [::math::statistics::stdev $tab] ]
         }
         if {$field=="sky"} {
            set taboid(err_sky) [ expr 2.0 * [::math::statistics::stdev $tab] ]
         }
      }

      set taboid(err_psf)    ""
      set othf [::bdi_tools_psf::get_astroid_null]
      foreach key [::bdi_tools_psf::get_basic_fields] {
         ::bdi_tools_psf::set_by_key othf $key $taboid($key)
      }
      return $othf


   }



   proc ::bdi_tools_methodes_psf::globale_stat { p_results } {
      
      set listfield [list xsm ysm fwhmx fwhmy fwhm flux pixmax intensity sky err_sky snint rdiff ra dec]
      foreach field $listfield {
         set tab ""
         for {set radius 1} {$radius < $::bdi_tools_psf::psf_limitradius} {incr radius} {
            if {$results($radius,err)==0} {
               lappend tab $results($radius,$field)
            }
         }
         # Stat
         set taboid($field) [::math::statistics::mean $tab]
         if {$field=="xsm"} {
            set taboid(err_xsm) [ expr 2.0 * [::math::statistics::stdev $tab] ]
         }
         if {$field=="ysm"} {
            set taboid(err_ysm) [ expr 2.0 * [::math::statistics::stdev $tab] ]
         }
         if {$field=="flux"} {
            set taboid(err_flux) [ expr 2.0 * [::math::statistics::stdev $tab] ]
         }
         if {$field=="sky"} {
            set taboid(err_sky) [ expr 2.0 * [::math::statistics::stdev $tab] ]
         }
      }
      
      set taboid(err_psf)    ""
      set othf [::bdi_tools_psf::get_astroid_null]
      foreach key [::bdi_tools_psf::get_basic_fields] {
         ::bdi_tools_psf::set_by_key othf $key $taboid($key)
      }
      return $othf
      

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

         set taboid(err_psf)    ""
         set taboid(flux)        [lindex $valeurs 0]
         set taboid(med_sky)     [lindex $valeurs 1]
         set taboid(moy_sky)     [lindex $valeurs 2]
         set taboid(sky)         $taboid(med_sky)
         set taboid(err_sky)     [lindex $valeurs 3]

         set taboid(npix)        [expr ($xs1 - $xs0 + 1) * ($ys1 - $ys0 + 1)]

         set valeurs             [buf$bufNo stat [list $xs0 $ys0 $xs1 $ys1] ]
         set taboid(pixmax)      [lindex $valeurs 2]
         set taboid(intensity)   [expr $taboid(pixmax) - $taboid(med_sky)]

         set taboid(snint)       [expr $taboid(flux) / sqrt ( $taboid(flux) + $taboid(npix) * $taboid(med_sky) )]
         set taboid(snpx)        [expr $taboid(intensity) / $taboid(err_sky)]

         # rejet si saturé
         if {$taboid(pixmax) > $::bdi_tools_psf::psf_saturation} {
            set taboid(err_psf)  "Saturated"
            set taboid(pixmax)   "Max"
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

         set taboid(err_xsm) ""
         set taboid(err_ysm) ""
         set taboid(err_flux) ""

         set othf [::bdi_tools_psf::get_astroid_null]
         foreach key [::bdi_tools_psf::get_basic_fields] {
            ::bdi_tools_psf::set_by_key othf $key $taboid($key)
         }
         return $othf

         # Calcul du signal sur bruit : 
         # S/N = flux / sqrt (flux + npix ( sky + offset + readnoise^2) )
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

         set taboid(intensity) [expr ($intx + $inty)/2.]
         set taboid(fwhm)      [expr ($taboid(fwhmx) + $taboid(fwhmy))/2.]
         set taboid(sky)       [expr ($fondx + $fondy)/2.]

         # calcul des coordonnees celeste de l'objet mesuré
         set radec [ buf$bufNo xy2radec [list $taboid(xsm) $taboid(ysm) ] ]
         set taboid(ra)  [lindex $radec 0] 
         set taboid(dec) [lindex $radec 1]

         set taboid(radius) [expr (abs($x1-$x2)+abs($y1-$y2))/4.0 ]

         set valeurs        [buf$bufNo stat [list $x1 $y1 $x2 $y2] ]
         set taboid(pixmax) [lindex $valeurs 2]

         set taboid(err_psf) ""
         set taboid(err_xsm) ""
         set taboid(err_ysm) ""
         set taboid(flux) ""
         set taboid(err_flux) ""
         set taboid(err_sky) ""
         set taboid(snint) ""
         set taboid(rdiff) ""

         set othf [::bdi_tools_psf::get_astroid_null]
         foreach key [::bdi_tools_psf::get_fitgauss_fields] {
            ::bdi_tools_psf::set_by_key othf $key $taboid($key)
         }
         return $othf

   }









}
