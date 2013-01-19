#--------------------------------------------------
# source audace/plugin/tool/av4l/analyse_source.tcl
#--------------------------------------------------
#
# Fichier        : analyse_source.tcl
# Description    : Utilitaires de communcation avec un flux (video ou lot d'image)
# Auteur         : Frederic Vachier
# Mise à jour $Id: analyse_source.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

namespace eval ::analyse_source {


   #
   # ::analyse_source::test
   # 
   #
   proc ::analyse_source::test { listsources } {

      global bddconf
   
      ::console::affiche_resultat "[lindex $listsources 0]  \n"

      set unesource [lindex [lindex $listsources 1] 10]
      ::console::affiche_resultat "$unesource \n"
      set ra  [lindex [lindex [lindex $unesource 0] 1] 0]
      set dec [lindex [lindex [lindex $unesource 0] 1] 1]
      set x [lindex [lindex [lindex $unesource 0] 2] 2]
      set y [lindex [lindex [lindex $unesource 0] 2] 3]
      set fwhm [lindex [lindex [lindex $unesource 0] 2] 24]
      ::console::affiche_resultat "X $x / Y $y / FWHM $fwhm\n"

      set source [list {"SOURCE" {} {} } [list [list [list "SOURCE" [list $ra $dec] {}]]]]
      affich_rond $source "SOURCE" "green" 1

      gren_info "[::confVisu::screen2Canvas  $bddconf(visuno) [list $x $y]]\n"
      gren_info "[::confVisu::canvas2Picture $bddconf(visuno) [list $x $y]]\n"

      affich_un_rond_xy $x $y "green" 5  4

      set results [ ::av4l_photom::photom_methode $x $y $fwhm $bddconf(bufno) ]
      set x2 [lindex $results 0]
      set y2 [lindex $results 1]
      ::console::affiche_resultat "X $x2 / Y $y2 \n"
      affich_un_rond_xy $x2 $y2 "blue" 5  2
      ::console::affiche_resultat "diff X [expr abs($x2-$x)] / Y [expr abs($y2-$y)] \n"

      gren_info "$results\n"
   }




   #
   # Get Astroid fields
   #    xsm         : Position x du photocentre (px)
   #    ysm         : Position y du photocentre (px)
   #    fwhmx       : FWHM le long de l'axe x (px)
   #    fwhmy       : FWHM le long de l'axe y (px) 
   #    fwhm        : FWHM totale (px)
   #    fluxintegre : Flux integre 
   #    errflux     : Incertitude sur le flux integre
   #    pixmax      : Valeur du pixel maximum
   #    intensite   : Valeur du pixel maximum - valeur du fond de ciel
   #    sigmafond   : sigma du fond de ciel
   #    snint       : Signal/bruit de l'intensite
   #    snpx        : Signal/bruit du pixel max (obsolete)
   #    delta       : Taille de la fenetre de calcul de la PSF
   #    rdiff       : Difference entre (x,y) pixel demande et (x,y) pixel obtenu par la PSF
   #    ra          : RA de la source (deg)
   #    dec         : DEC de la source (deg)
   #    res_ra      : Residu en RA (arcsec)
   #    res_dec     : Residu en DEC (arcsec)
   #    omc_ra      : O-C(RA) (arcsec)
   #    omc_dec     : O-C(DEC) (arcsec)
   #    mag         : Magnitude mesuree (mag)
   #    err_mag     : Incertitude sur la magnitude mesuree (mag)
   #    name        : Designation de la source
   #    flagastrom  : 'r'eference ou 's'cience ou '' rien
   #    flagphotom  : 'r'eference ou 's'cience ou '' rien
   #    cataastrom  : Nom du catalogue de reference astrometrique associe a la source
   #    cataphotom  : Nom du catalogue de reference photometrique associe a la source
   #
   proc ::analyse_source::get_fieldastroid { } {

      return [list "ASTROID" [list "ra" "dec" "poserr" "mag" "magerr"] \
                             [list "xsm" "ysm" "fwhmx" "fwhmy" "fwhm" "fluxintegre" "errflux" \
                                   "pixmax" "intensite" "sigmafond" "snint" "snpx" "delta" "rdiff" \
                                   "ra" "dec" "res_ra" "res_dec" "omc_ra" "omc_dec" "mag" "err_mag" \
                                   "name" "flagastrom" "flagphotom" "cataastrom" "cataphotom"] ]

   }



   #
   # ::analyse_source::psf
   # Mesure de PSF d'une source
   #
   proc ::analyse_source::psf { listsources radius_threshold delta } {

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
                     lappend results $rdiff $ra $dec $poserr $poserr 0.0 0.0 $mag $magerr "" "" "" "" ""
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

   return [list $fields $newsources]
   }
# source $audace(rep_install)/gui/audace/plugin/tool/bddimages/utils/ssp_sex/main.tcl


}
