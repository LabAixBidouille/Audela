# source /srv/develop/audela/gui/audace/plugin/tool/av4l/av4l_analysis_tools.tcl

#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_analysis_tools.tcl
#--------------------------------------------------
#
# Fichier        : av4l_analysis_tools.tcl
# Description    : Outil Courbe de lumiere
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: av4l_analysis_tools.tcl 7986 2011-12-22 20:15:55Z svaillant $
#

#idframe,
#jd,
#dateiso,
#obj_fint     ,
#obj_pixmax   ,
#obj_intensite,
#obj_sigmafond,
#obj_snint    ,
#obj_snpx     ,
#obj_delta    ,
#obj_xpos,
#obj_ypos,
#obj_xfwhm,
#obj_yfwhm,
#ref_fint     ,
#ref_pixmax   ,
#ref_intensite,
#ref_sigmafond,
#ref_snint    ,
#ref_snpx     ,
#ref_delta    ,
#ref_xpos,
#ref_ypos,
#ref_xfwhm,
#ref_yfwhm,
#img_intmin ,
#img_intmax,
#img_intmoy,
#img_sigma ,
#img_xsize,
#img_ysize

namespace eval ::av4l_analysis_tools {

package require math::statistics
package require math::special
set tcl_precision 17

      variable cols
      variable cdl
      variable nb
      variable diravi
      variable dirwork
      variable filecsv
      








   proc ::av4l_analysis_tools::charge_csv { file } {


      if  {![file exists $file]} {return}
 
      set cpt 0
      
      set chan [open $file r]

      while {[gets $chan line] >= 0} {

         set line [string trim $line]
         set c [string index $line 0]
         if {$c=="#"} {continue}

         # description des colonnes
         if {$cpt==0} {
            set cols [split $line ","]
            set ::av4l_analysis_tools::cols ""
            foreach col $cols {
               lappend ::av4l_analysis_tools::cols [string trim $col]
            }
            incr cpt
            continue
         }
         
         set a [split $line ","]
         set idcol 0
         catch {unset csvraw}
         foreach col $::av4l_analysis_tools::cols {
            set ::av4l_analysis_tools::csv($cpt,$col) [string trim [lindex $a $idcol]]
            incr idcol
         }
        
         incr cpt
         #if {$cpt > 5} {break}
      }
      close $chan

      return -code 0 [expr $cpt - 1]
   }






   proc ::av4l_analysis_tools::filtre_raw_data { nb } {


      if {[info exists ::av4l_analysis_tools::cols]} {unset ::av4l_analysis_tools::cols}
      if {[info exists ::av4l_analysis_tools::cdl]} {unset ::av4l_analysis_tools::cdl}
      if {[info exists ::av4l_analysis_tools::raw_nbframe]} {unset ::av4l_analysis_tools::raw_nbframe}


      set ::av4l_analysis_tools::nb_pt_ref 0
      set cpt 1
      set cptref 0

      ::console::affiche_resultat "nb=$nb\n"
      
      for {set i 1} {$i<=$nb} {incr i} {
         
         if { $::av4l_analysis_tools::csv($i,idframe)==""}  {continue}
         if { $::av4l_analysis_tools::csv($i,jd)==""}       {continue}
         if { $::av4l_analysis_tools::csv($i,dateiso)==""}  {continue}
         if { $::av4l_analysis_tools::csv($i,obj_fint)==""} {continue}
                
         set ::av4l_analysis_tools::cdl($cpt,idframe)  $::av4l_analysis_tools::csv($i,idframe)
         set ::av4l_analysis_tools::cdl($cpt,jd)       $::av4l_analysis_tools::csv($i,jd)
         set ::av4l_analysis_tools::cdl($cpt,dateiso)  $::av4l_analysis_tools::csv($i,dateiso)
         set ::av4l_analysis_tools::cdl($cpt,obj_fint) $::av4l_analysis_tools::csv($i,obj_fint)

         if { $::av4l_analysis_tools::csv($i,ref_fint)!=""} {
            set ::av4l_analysis_tools::cdl($cpt,ref_fint) $::av4l_analysis_tools::csv($i,ref_fint)
            incr ::av4l_analysis_tools::nb_pt_ref 
         }
         
         incr cpt
      }
      if {$cpt==1} {
         return -code 1 "Aucune donnée"
      }

      set ::av4l_analysis_tools::raw_nbframe [expr $cpt - 1]
      set ::av4l_analysis_tools::raw_status_file "Chargé"
      set ::av4l_analysis_tools::raw_date_begin  $::av4l_analysis_tools::cdl(1,dateiso)
      set ::av4l_analysis_tools::raw_date_end  $::av4l_analysis_tools::cdl($::av4l_analysis_tools::raw_nbframe,dateiso)
      set ::av4l_analysis_tools::raw_duree  [format "%.3f" [expr ($::av4l_analysis_tools::cdl($::av4l_analysis_tools::raw_nbframe,jd) \
            - $::av4l_analysis_tools::cdl(1,jd) ) * 86400.0 ]]
      set ::av4l_analysis_tools::raw_fps  [format "%.3f" [expr ($::av4l_analysis_tools::raw_nbframe /$::av4l_analysis_tools::raw_duree )]]
      set ::av4l_analysis_tools::orig $::av4l_analysis_tools::cdl(1,jd)

      return -code 0 
   }










   proc ::av4l_analysis_tools::correction_integration { offset bloc } {

      if {[info exists ::av4l_analysis_tools::medianecdl]} {unset ::av4l_analysis_tools::medianecdl}
      if {[info exists ::av4l_analysis_tools::finalcdl]} {unset ::av4l_analysis_tools::finalcdl}

      set fin "no"
      set i 1
      while {$fin=="no"} {

         # on evite un nb d image de debut = offset
         if { $i<$offset} {
            incr i
            continue
         }

         # on calcule la mediane
         set med ""
         set k $i
         for {set j 1} {$j<=$bloc} {incr j} {
            incr k
            lappend med $::av4l_analysis_tools::cdl($k,obj_fint)
         }
         set med [::math::statistics::median $med]
         ::console::affiche_resultat "MED=$med\n"

         # on cree 2 nouvelles courbes
         for {set j 1} {$j<=$bloc} {incr j} {
            incr i
            if {$j==1} {
               set ::av4l_analysis_tools::finalcdl($i,idframe)  $::av4l_analysis_tools::cdl($i,idframe)
               set ::av4l_analysis_tools::finalcdl($i,jd)       $::av4l_analysis_tools::cdl($i,jd)
               set ::av4l_analysis_tools::finalcdl($i,obj_fint) $med
            }
            set ::av4l_analysis_tools::medianecdl($i,jd) $::av4l_analysis_tools::cdl($i,jd)
            set ::av4l_analysis_tools::medianecdl($i,obj_fint) $med
         }
         set reste [expr $::av4l_analysis_tools::raw_nbframe - $i]
         if {$reste<$bloc} {break}
         
      }

 
   }









   proc ::av4l_analysis_tools::save_corrected_curve { file } {
      
      set chan [open $file w]
      puts $chan "idframe,jd,flux"

      for {set i 1} {$i<=$::av4l_analysis_tools::raw_nbframe} {incr i} {
         if {![info exists ::av4l_analysis_tools::finalcdl($i,jd)]} {continue}
            puts $chan "$::av4l_analysis_tools::finalcdl($i,idframe),$::av4l_analysis_tools::finalcdl($i,jd),$::av4l_analysis_tools::finalcdl($i,obj_fint)"
      }

      close $chan

   }





   proc ::av4l_analysis_tools::filtre_corr_data { nb } {

      if {[info exists ::av4l_analysis_tools::cols]} {unset ::av4l_analysis_tools::cols}
      if {[info exists ::av4l_analysis_tools::cdl]} {unset ::av4l_analysis_tools::cdl}
      if {[info exists ::av4l_analysis_tools::corr_nbframe]} {unset ::av4l_analysis_tools::corr_nbframe}
      
      set cpt 1
      for {set i 1} {$i<=$nb} {incr i} {
         if { $::av4l_analysis_tools::csv($i,idframe)==""}  {continue}
         if { $::av4l_analysis_tools::csv($i,jd)==""}       {continue}
         if { $::av4l_analysis_tools::csv($i,flux)==""}     {continue}
         set ::av4l_analysis_tools::cdl($cpt,idframe)  $::av4l_analysis_tools::csv($i,idframe)
         set ::av4l_analysis_tools::cdl($cpt,jd)       $::av4l_analysis_tools::csv($i,jd)
         set ::av4l_analysis_tools::cdl($cpt,flux)  $::av4l_analysis_tools::csv($i,flux)
         incr cpt
      }
      if {$cpt==1} {
         return -code 1 "Aucune donnée"
      }

      set ::av4l_analysis_tools::corr_nbframe [expr $cpt - 1]
      set ::av4l_analysis_tools::corr_status_file "Chargé"
      set ::av4l_analysis_tools::corr_date_begin  [ mc_date2iso8601 $::av4l_analysis_tools::cdl(1,jd) ]
 
      set ::av4l_analysis_tools::corr_date_end  [ mc_date2iso8601 $::av4l_analysis_tools::cdl($::av4l_analysis_tools::corr_nbframe,jd) ]
      set ::av4l_analysis_tools::corr_duree  [format "%.3f" [expr ($::av4l_analysis_tools::cdl($::av4l_analysis_tools::corr_nbframe,jd) \
            - $::av4l_analysis_tools::cdl(1,jd) ) * 86400.0 ]]
      set ::av4l_analysis_tools::corr_fps  [format "%.3f" [expr ($::av4l_analysis_tools::corr_nbframe /$::av4l_analysis_tools::corr_duree )]]
      set ::av4l_analysis_tools::orig $::av4l_analysis_tools::cdl(1,jd)

      return -code 0 
   }














# Obsolete a venir

   proc ::av4l_analysis_tools::init {  } {

      set ::av4l_analysis_tools::diravi "/data/Occultations/20100605_80SAPPHO"
      set ::av4l_analysis_tools::dirwork "/data/Occultations/20100605_80SAPPHO/work"
      set ::av4l_analysis_tools::filecsv "sapphoseg.00.avi.00001.csv"

      if {[info exists ::av4l_analysis_tools::cols]} {unset ::av4l_analysis_tools::cols}
      if {[info exists ::av4l_analysis_tools::cdl]} {unset ::av4l_analysis_tools::cdl}
      if {[info exists ::av4l_analysis_tools::nb]} {unset ::av4l_analysis_tools::nb}

      set file [file join $::av4l_analysis_tools::dirwork "ombre_geometrique.csv"]
      set changeo [open $file w]
      puts $changeo "# OMBRE GEOMETRIQUE"
      close $changeo
      
   }






 


   proc ::av4l_analysis_tools::affiche_cdl {  } {

      ::console::affiche_resultat "Afichage de la courbe\n"

      for {set i 1} {$i<=$::av4l_analysis_tools::nbframe} {incr i} {
         foreach col $::av4l_analysis_tools::cols {
            ::console::affiche_resultat  "$::av4l_analysis_tools::cdl($i,$col) "
         }
            ::console::affiche_resultat  "\n"
      }

   }



   proc ::av4l_analysis_tools::sauve_brut {  } {
      
      set file [file join $::av4l_analysis_tools::dirwork "brut.csv"]
      set chan [open $file w]
      puts $chan "idframe,jd,obj_fint"
      for {set i 1} {$i<=$::av4l_analysis_tools::nbframe} {incr i} {
         #if {$::av4l_analysis_tools::cdl($i,jd)==""} {continue}
         #if {$::av4l_analysis_tools::cdl($i,obj_fint)==""} {continue}
         puts $chan "$::av4l_analysis_tools::cdl($i,idframe),$::av4l_analysis_tools::cdl($i,jd),$::av4l_analysis_tools::cdl($i,obj_fint)"
      }
      close $chan

   }
   
   
   
   proc ::av4l_analysis_tools::sauve_bmediane {  } {
      
      set file [file join $::av4l_analysis_tools::dirwork "bmediane.csv"]
      set chan [open $file w]
      puts $chan "idframe,jd,obj_fint,mediane"
      for {set i 1} {$i<=$::av4l_analysis_tools::nbframe} {incr i} {
         #if {$::av4l_analysis_tools::cdl($i,jd)==""} {continue}
         #if {$::av4l_analysis_tools::cdl($i,obj_fint)==""} {continue}
         if {![info exists ::av4l_analysis_tools::cdl($i,mediane)]} {
            set ::av4l_analysis_tools::cdl($i,mediane) ""
         }
         puts $chan "$::av4l_analysis_tools::cdl($i,idframe),$::av4l_analysis_tools::cdl($i,jd),$::av4l_analysis_tools::cdl($i,obj_fint),$::av4l_analysis_tools::cdl($i,mediane)"
      }
      close $chan

   }
   
   
   
   
   proc ::av4l_analysis_tools::sauve_mediane {  } {
      
      set file [file join $::av4l_analysis_tools::dirwork "mediane.csv"]
      set chan [open $file w]
      puts $chan "idframe,jd,flux"
      foreach v $::av4l_analysis_tools::newcdl {
         #puts $chan [format "%5s, %.3f, %.2f" [lindex $v 0] [lindex $v 1] [lindex $v 2]]
         puts $chan [format "%.3f  %.2f" [lindex $v 1] [lindex $v 2]]
      }
      close $chan

   }




   proc ::av4l_analysis_tools::genere_mediane {  } {

      ::av4l_analysis_tools::init
      ::av4l_analysis_tools::charge_cdl [file join $::av4l_analysis_tools::diravi $::av4l_analysis_tools::filecsv]
      #::av4l_analysis_tools::affiche_cdl 
      ::av4l_analysis_tools::sauve_brut
      ::av4l_analysis_tools::compacte
      ::av4l_analysis_tools::sauve_bmediane
      ::av4l_analysis_tools::sauve_mediane

   }



   proc ::av4l_analysis_tools::partie1 {  } {

      # Mode:
      # -1= t0 centre sur l''immersion
      # +1= t0 centre sur l''emersion
      # 0 = t0 centre sur le millieu de la bande

      # FORMULAIRE
      set ::av4l_analysis_tools::mode -1

      # idon :
      # Faut-il comparer a des donnees
      # 1 oui
      # 0 non

      # Longueur d''onde (microns)
      # FORMULAIRE
      set ::av4l_analysis_tools::wvlngth 0.75
      set ::av4l_analysis_tools::wvlngth [expr $::av4l_analysis_tools::wvlngth * 1.e-09]

      # Bande passante (microns)
      # FORMULAIRE
      set ::av4l_analysis_tools::dlambda 0.4
      set ::av4l_analysis_tools::dlambda [expr $::av4l_analysis_tools::dlambda * 1.e-09]

      #  Distance a l'anneau (km): distance geocentrique de l objet occulteur
      # FORMULAIRE
      set ::av4l_analysis_tools::dist  234000000.0

      #  Rayon de l'etoile (km)
      # FORMULAIRE
      set ::av4l_analysis_tools::re 2.04

      # Vitesse normale de l'etoile (dans plan du ciel, km/s) ???
      # Vitesse relative de l'objet par rapport a la terre (km/s)
      # FORMULAIRE
      set ::av4l_analysis_tools::vn 27.8

      # Largeur de la bande (km)
      # Taille estimée de l'objet (km)
      # si occultation rasante c est la taille de la corde (km)
      # FORMULAIRE
      set ::av4l_analysis_tools::width 150.0

      # transmission
      # opaque = 0, sinon demander bruno
      # FORMULAIRE
      set ::av4l_analysis_tools::trans 0.0

      # 
      # on a 5 secondes dans lesquelles on va mesurer l instant
      # on a37 points de 0.3 sec d ecart
      # 
      # 
      # Duree generee (points)
      # duree synthetique choisie autour de l'evenement.
      # ex: 30 sec alrs que l evenement est au milieu.
      # attention de ne pas choisir trop large pour englober
      # l'autre evenement.
      # FORMULAIRE
      set ::av4l_analysis_tools::duree 37

      # pas en temps (sec)
      # FORMULAIRE
      set ::av4l_analysis_tools::pas 0.3

      # Flux hors occultation (normalisé)
      # FORMULAIRE
      set ::av4l_analysis_tools::phi1 1

      # flux stellaire zero (normalisé)
      # FORMULAIRE
      set ::av4l_analysis_tools::phi0 0.29
      
      # Heure de reference (sec TU)
      # FORMULAIRE
      set ::av4l_analysis_tools::t0_ref 42082.185
      set ::av4l_analysis_tools::t_milieu [expr $::av4l_analysis_tools::t0_ref  + $::av4l_analysis_tools::width/(2.0*$::av4l_analysis_tools::vn)]

      # on essai 100 points autour du T0 
      # en considerant un ecart entre les points de 0.02 sec
      # on peut dire qu on choisi pas = tmps d expo / 10
      # le pas est une estimation de la precision
      # nheure = 100 *0.02=> duree de 2 sec pour explorer l espace de
      # recherche autour de l evenement
      #
      # Nombre d'instant a explorer autour de la reference (points)
      # FORMULAIRE
      set ::av4l_analysis_tools::nheure 200
      
      # pas (sec)
      # FORMULAIRE
      set ::av4l_analysis_tools::pas_heure 0.02
      
      set ::av4l_analysis_tools::t0_min [expr $::av4l_analysis_tools::t0_ref - $::av4l_analysis_tools::pas_heure * $::av4l_analysis_tools::nheure / 2.0]
      set ::av4l_analysis_tools::t0_max [expr $::av4l_analysis_tools::t0_ref + $::av4l_analysis_tools::pas_heure * $::av4l_analysis_tools::nheure / 2.0]
      set ::av4l_analysis_tools::t0     $::av4l_analysis_tools::t0_min
      
   }






   proc ::av4l_analysis_tools::partie2 {  } {
      
      #-----------------------------------------------------------------------------

      #-----------------------------------------------------------------------------
      # Fichiers de sortie
      # sorties:
      # fort.20: ombre geometrique
      # fort.21: ombre avec diffraction (convolee par la bande passante et
      #          par le diametre stellaire)
      # fort.22: ombre lissee par la reponse instrumentale
      # fort.23: ombre (fort.22) interpolee sur les points d'observation 
      # fort.24: t0, chi2, nombre de points ajustes
      # fort.25: rayon de l'etoile, chi2_min, npt fittes (NB. "append")
      # fort.26: dans le cas ou la bande a une largeur finie (ex. duree finie de l'occn) 
      #          chi2 - nfit (NB. "append"), voir par ex. donnees Hakos/Varuna 19 fev 2010
      set file21 [file join $::av4l_analysis_tools::dirwork "21_modele_flux_avant_convolution.csv"]
      set chan21 [open $file21 w]
      set file22 [file join $::av4l_analysis_tools::dirwork "22_modele_flux_apres_convolution.csv"]
      set chan22 [open $file22 w]
      set file23 [file join $::av4l_analysis_tools::dirwork "23_.csv"]
      set chan23 [open $file23 w]
      set file24 [file join $::av4l_analysis_tools::dirwork "24_.csv"]
      set chan24 [open $file24 w]
      set file25 [file join $::av4l_analysis_tools::dirwork "25_.csv"]
      set chan25 [open $file25 w]
      set file26 [file join $::av4l_analysis_tools::dirwork "26_.csv"]
      set chan26 [open $file26 w]
      set file27 [file join $::av4l_analysis_tools::dirwork "obs.dat"]
      set chan27 [open $file27 w]
      #-----------------------------------------------------------------------------

      # controle des observations
      for {set i 1} {$i<=$::av4l_analysis_tools::duree} {incr i} {
         puts $chan27 [format "%5.5f %5.5f" $::av4l_analysis_tools::tobs($i) $::av4l_analysis_tools::fobs($i)]
      }
      close $chan27

      
      #-----------------------------------------------------------------------------
      
      while { $::av4l_analysis_tools::t0<=$::av4l_analysis_tools::t0_max} {
      
         set npt [expr int ($::av4l_analysis_tools::duree/(2.0 * $::av4l_analysis_tools::pas) )]
         if {$::av4l_analysis_tools::mode==-1} {
            # bord gauche de l'ombre cale
            # sur l'origine (ie t0 en temps)
            set x1 0.0
            set x2 $::av4l_analysis_tools::width
         }
         if {$::av4l_analysis_tools::mode==0} {
            # ombre centree sur le milieu
            # de la bande
            set x1 [expr -$::av4l_analysis_tools::width / 2.0 ]
            set x2 [expr  $::av4l_analysis_tools::width / 2.0 ]
         }
         if {$::av4l_analysis_tools::mode==1} {
            # bord droit de l'ombre cale
            # sur l'origine (ie t0 en temps)
            set x1 [expr -$::av4l_analysis_tools::width ]
            set x2 0.0
         }

         set opa_ampli [expr  1.0 - sqrt($::av4l_analysis_tools::trans)]
      
         # Trace de l'ombre geometrique
         ::av4l_analysis_tools::ombre_geometrique  $::av4l_analysis_tools::mode $::av4l_analysis_tools::t0 $::av4l_analysis_tools::duree $::av4l_analysis_tools::width $::av4l_analysis_tools::vn $::av4l_analysis_tools::phi1 $::av4l_analysis_tools::phi0

      
      
      
         #-----------------------------------------------------------------------------
         #      etoile: sous-programme de convolution par le diametre
         #         stellaire.
         #
         #      NB.:    on appelle deux fois etoile pour convoluer par la
         #         bande passante.
         #
         set som 0.0
         
         for {set i [expr -$npt]} {$i<=$npt} {incr i} {
            set x [expr $::av4l_analysis_tools::vn * $::av4l_analysis_tools::pas * $i]
            set wvlngth1 [expr $::av4l_analysis_tools::wvlngth - $::av4l_analysis_tools::dlambda / 2.0]
            set wvlngth2 [expr $::av4l_analysis_tools::wvlngth + $::av4l_analysis_tools::dlambda / 2.0]
            set flux1 [::av4l_analysis_tools::etoile $::av4l_analysis_tools::re $x1 $x2 $opa_ampli $wvlngth1 $::av4l_analysis_tools::dist $x]
            set flux2 [::av4l_analysis_tools::etoile $::av4l_analysis_tools::re $x1 $x2 $opa_ampli $wvlngth2 $::av4l_analysis_tools::dist $x]
            set flu [expr  ( $flux1 + $flux2 )/2.0]
            set flux($i) [expr $flu*($::av4l_analysis_tools::phi1-$::av4l_analysis_tools::phi0) + $::av4l_analysis_tools::phi0]
            set t($i) [expr $::av4l_analysis_tools::t0 + $i * $::av4l_analysis_tools::pas]
            puts $chan21 "$t($i) , $flux($i)"
            set som [expr $som + $::av4l_analysis_tools::pas * $::av4l_analysis_tools::vn * (1.0-$flux($i))]
         }

         ::console::affiche_resultat "Integrale du flux avant convolution(km): $som\n"      
         #-----------------------------------------------------------------------------
      
      
         #-----------------------------------------------------------------------------
         #
         # Convolution par la reponse instrumentale
         # Considerer ici comme lineaire
         #
         set nptl 0
         for {set i [expr -$npt]} {$i<=$npt} {incr i} {
            incr nptl
            set ::av4l_analysis_tools::tl($nptl)    $t($i)
            set ::av4l_analysis_tools::fluxl($nptl) $flux($i)
         }
         #::console::affiche_resultat "FLUX 41: $::av4l_analysis_tools::fluxl(41)\n"      
         #close $chan21
         #return 

         #-----------------------------------------------------------------------------
      
      
         #-----------------------------------------------------------------------------
         #
         # Ecriture du modele final (apres convolution par etoile et instrument)
         #
         set som 0.0
         set tl_min  1.e50
         set tl_max  -1.d50   
         for {set i 1} {$i<=$nptl} {incr i} {
            puts $chan22 "$::av4l_analysis_tools::tl($i),$::av4l_analysis_tools::fluxl($i)"
            if {$::av4l_analysis_tools::tl($i)>=$tl_max} {set tl_max $::av4l_analysis_tools::tl($i)}
            if {$::av4l_analysis_tools::tl($i)<=$tl_min} {set tl_min $::av4l_analysis_tools::tl($i)}
            set som [expr $som + $::av4l_analysis_tools::pas * $::av4l_analysis_tools::vn * (1.0 - $::av4l_analysis_tools::fluxl($i))]
         }
         ::console::affiche_resultat "Integrale du flux apres convolution (km): $som\n"      
         #-----------------------------------------------------------------------------
      
      
      
         #-----------------------------------------------------------------------------
         #
         # Calcul du chi2 avec les donnees
         #
         set nfit 0
         set chi2 0.0
         set tobs_min 1.e50
         set tobs_max -1.e50
         for {set i 1} {$i<=$::av4l_analysis_tools::duree} {incr i} {
         
            set fac [expr ($::av4l_analysis_tools::tobs($i)-$tl_min)*($::av4l_analysis_tools::tobs($i)-$tl_max)]
            if {$fac<=0.0} {
               set fmod_inter [::av4l_analysis_tools::interpol $nptl $::av4l_analysis_tools::tobs($i)]
               puts $chan23 "$::av4l_analysis_tools::tobs($i),$fmod_inter"
               # fmod_inter ! attention !
               set sigma_local $::av4l_analysis_tools::sigma
               set chi2 [expr $chi2 + pow(($fmod_inter - $::av4l_analysis_tools::fobs($i))/$sigma_local,2)]
               incr nfit
               if {$::av4l_analysis_tools::tobs($i)<$tobs_min} {set tobs_min $::av4l_analysis_tools::tobs($i)}
               if {$::av4l_analysis_tools::tobs($i)>$tobs_max} {set tobs_max $::av4l_analysis_tools::tobs($i)}
            }
         }
         ::console::affiche_resultat "t0: $::av4l_analysis_tools::t0\n"      
         ::console::affiche_resultat "chi2: $chi2\n"      
         ::console::affiche_resultat "nfit: $nfit\n"      
         ::console::affiche_resultat "temps milieu de la bande: $::av4l_analysis_tools::t_milieu\n"      
         ::console::affiche_resultat "duree de la bande: [expr $::av4l_analysis_tools::width/$::av4l_analysis_tools::vn]\n"      
         ::console::affiche_resultat "$nfit points fittes entre: $tobs_min et $tobs_max  \n"      
         puts $chan24 "$::av4l_analysis_tools::t0,$chi2,$nfit"
         puts $chan26 "[expr $chi2 - $nfit*1.0]"
         #-----------------------------------------------------------------------------

         #  on incremente t0
         set ::av4l_analysis_tools::t0 [expr $::av4l_analysis_tools::t0 + $::av4l_analysis_tools::pas_heure] 

         set ::av4l_analysis_tools::percent [format "%.2f" [expr ($::av4l_analysis_tools::t0-$::av4l_analysis_tools::t0_min)/($::av4l_analysis_tools::t0_max-$::av4l_analysis_tools::t0_min)*100.0]]
         ::console::affiche_resultat "$::av4l_analysis_tools::percent ---------------------------------------------------\n"      

      # Fin While
      }
      
      close $chan21
      close $chan22
      close $chan23
      close $chan24
      close $chan26







      #-----------------------------------------------------------------------------
      #
      # on cherche le temps correspondant au minimum de chi2:
      #
      set chan24 [open $file24 r]
      set chi2_min 1.e50
      while {[gets $chan24 line] >= 0} {
         set line [string trim $line]
         set cols [split $line ","]
         set t0   [lindex $cols 0]
         set chi2 [lindex $cols 1]
         set nfit [lindex $cols 2]
         if {$chi2 <= $chi2_min} {
            set chi2_min      $chi2
            set t0_chi2_min   $t0
            set nfit_chi2_min $nfit
         }
      }
      close $chan24

      set chan24 [open $file24 r]
      set dchi2  1.0
      set t_inf  1.e50
      set t_sup -1.e50
      while {[gets $chan24 line] >= 0} {
         set line [string trim $line]
         set cols [split $line ","]
         set t0   [lindex $cols 0]
         set chi2 [lindex $cols 1]
         set nfit [lindex $cols 2]
         if {$chi2 <= [expr $chi2_min+$dchi2]} {
            if {$t0 <= $t_inf} { set t_inf $t0}
            if {$t0 >= $t_sup} { set t_sup $t0}
         }

      }
      close $chan24

      ::console::affiche_resultat  "t0 = $t0\n"
      ::console::affiche_resultat  "t0_chi2_min = $t0_chi2_min\n"
      ::console::affiche_resultat  "chi2_min = $chi2_min\n"
      ::console::affiche_resultat  "nfit_chi2_min = $nfit_chi2_min\n"
      ::console::affiche_resultat  "Dchi2 = $dchi2\n"
      ::console::affiche_resultat  "intervalle ou chi2 < chi2_min + dchi2 = $t_inf $t_sup\n"

      set ::av4l_analysis_tools::t0_chi2_min   [format "%.4f" $t0_chi2_min]
      set ::av4l_analysis_tools::chi2_min      [format "%.4f" $chi2_min]
      set ::av4l_analysis_tools::nfit_chi2_min $nfit_chi2_min
      set ::av4l_analysis_tools::dchi2         [format "%.4f" $dchi2]
      set ::av4l_analysis_tools::t_inf         [format "%.4f" $t_inf]
      set ::av4l_analysis_tools::t_sup         [format "%.4f" $t_sup]

      puts $chan25 "$::av4l_analysis_tools::width,$chi2_min,$nfit_chi2_min"
      puts $chan25 "[expr $::av4l_analysis_tools::width/$::av4l_analysis_tools::vn],$chi2_min,$nfit_chi2_min"
      close $chan25
   }





   #-----------------------------------------------------------------------------
   # This subroutine gives the complex amplitude resulting from diffraction of a 
   # coherent planar wave, on a homogeneous semi-transparent stripe. The stripe is
   # assumed to be infinite in the 0y direction, it begins at x= "x1" and ends
   # at x= "x2" (x1 < x2). It removes a fraction "opa_ampli" (opacity in amplitude)
   # of the amplitude of the incident wave. So, opa_ampli= 0 corresponds to a
   # transparent stripe, while opa_ampli= 1 corresponds to an opaque stripe. This
   # opacity is related to the fractional transmission in intensity, F, by:
   #
   #            opa_ampli= 1 - sqrt(F)
   #
   # The subroutine call the FRESNEL subroutine, which uses dimensionless 
   # quantities normalized to the Fresnel scale fr= sqrt( (wvlngth*dist)/2 ),
   # where "wvlngth" is the wavelength of the observation, and "dist" is the
   # distance of the observer to the diffracting object (here the stripe).
   #
   # The wave is assumed to have an amplitude equal to unity at the stripe,
   # and the subroutine gives the complex amplitude recorded by the observer,
   # whose abscissa along the 0x axis is "x". The real part of the amplitude
   # is Re= 1+r_ampli, and the imaginary part is Im= i_ampli (i_ampli to be 
   # declared REAL*8 !). Caution: the resulting intensity is flux= Re**2 + Im**2,
   # NO sqrt !
   #
   # The formula which is used is:
   #
   # amplitude(x)= opa_ampli*( (i-1)/2 )*{ C(x-x1) - C(x-x2) + 
   #                i*[ S(x-x1) - S(x-x2) ] },
   #
   # where x,x1,x2 have been normalized to the Fresnel scale, i*i= -1, and
   # C and S are given by the subroutine FRESNEL.
   #
   #
   # NB. x1,x2,wvlngth,dist and x must be expressed in the same unity when entered
   # in the subroutine !
   #
   #-----------------------------------------------------------------------------
   proc ::av4l_analysis_tools::bar { x1 x2 opa_ampli wvlngth dist x } {

      # Required accuracy on the amplitude:
      set eps 1.0e-16

      # Normalization to the Fresnel scale
      set fr   [expr sqrt( ($wvlngth*$dist)/2.0 ) ]
      set x1fr [expr $x1 / $fr ]
      set x2fr [expr $x2 / $fr ]
      set xfr  [expr $x  / $fr ]


      # Calculation of the amplitude
      set xmx1 [expr  $xfr-$x1fr ]
      set xmx2 [expr  $xfr-$x2fr ]

      # FRESNEL
      
      if {$xmx1<0.0} {
         set sxmx1 -1.0
         set xmx1 [expr -1.0 * $xmx1]
      } else {
         set sxmx1 1.0
      }
      if {$xmx2<0.0} {
         set sxmx2 -1.0
         set xmx2 [expr -1.0 * $xmx2]
      } else {
         set sxmx2 1.0
      }

      set c1 [::math::special::fresnel_C $xmx1]
      set s1 [::math::special::fresnel_S $xmx1]
      set c2 [::math::special::fresnel_C $xmx2]
      set s2 [::math::special::fresnel_S $xmx2]

      if {$sxmx1<0.0} {
         set c1 [expr -1.0 * $c1]
         set s1 [expr -1.0 * $s1]
      }
      if {$sxmx2<0.0} {
         set c2 [expr -1.0 * $c2]
         set s2 [expr -1.0 * $s2]
      }


      set cc [expr $c1-$c2 ]
      set ss [expr $s1-$s2 ]
      set r_ampli [expr  - ($cc+$ss)*($opa_ampli/2.0) ]
      set i_ampli [expr    ($cc-$ss)*($opa_ampli/2.0) ]
      set amplir  [expr  1.0 + $r_ampli  ]
      set amplii  [expr  $i_ampli ]
      set flux    [expr  $amplir*$amplir + $amplii*$amplii ]
      
      return $flux
   }









   proc ::av4l_analysis_tools::etoile { re x1 x2 opa_ampli wvlngth dist x } {

      # etoile ponctuelle
      set zero 0.0

      # npt: echantillonnage sur le rayon stellaire pour le lissage
      # doit etre pair pour "sommation" ! NB npt sert a la fois pour explorer 
      # horizontalement et verticalement le disque stellaire
      set npt 12
      
      set tranche [expr $re/($npt*1.0)]
      set flux 0.0
      set som  0.0

      
      # etoile ponctuelle
      if {$re==$zero} {
         set flux [::av4l_analysis_tools::bar $x1 $x2 $opa_ampli $wvlngth $dist $x]
      }
      
      for {set i [expr -$npt]} {$i<=$npt} {incr i} {
         set p [expr ($i * 1.0)*$tranche]

         #---------------------------------------------------------------------------
         # etoile uniforme
         set coeff [expr sqrt( abs ( pow($re,2) - pow($p,2) ) ) ]
         #---------------------------------------------------------------------------
         
         #---------------------------------------------------------------------------
         #  etoile assombrie centre-bord: 
         #  pour chaque valeur de p on integre ("sommation") l'intensite lumineuse 
         #  de 0 a dsqrt(re**2 - p**2) --->
         #  prend ~ 4 fois plus de temps que le disque uniforme. 
         #  On peut aller plus vite en calculant une fois pour toutes
         #  "coeff" pour differente valeur de p.
         # 
         #   p_norm= p/re                                ! cause de l'appel de "sommation" ---> a ne considerer que
         #   fac= 1.d0 - p_norm**2                       ! dans un 2eme temps
         #   ymax  = dsqrt( dabs(1.d0 - p_norm**2) )     ! dabs: si argument tres legerement negatif
         #   coeff = sommation(0.d0,ymax,p_norm,npt)     ! integre l'intensite verticalement a p_norm=cste
         #---------------------------------------------------------------------------
         
         set xx    [expr $x + $p]
         set fluxi [::av4l_analysis_tools::bar $x1 $x2 $opa_ampli $wvlngth $dist $xx]
         set flux  [expr $flux + $coeff*$fluxi]
         set som   [expr $som + $coeff]
      }
      
      return [expr $flux / $som ]
   }



   proc ::av4l_analysis_tools::instrument { } {

   # subroutine instrument (nmax, t, flux, npt, trep, rep ,nrep, tl, fluxl, nptl)


   }





   # Trace de l'ombre geometrique
   proc ::av4l_analysis_tools::ombre_geometrique { imod t0 duree width vn phi1 phi0 } {

      set file [file join $::av4l_analysis_tools::dirwork "20_ombre_geometrique.csv"]
      set changeo [open $file a+]

      if {$imod==0} {
         # milieu de la bande centre sur t0
         set t1 [expr $t0 - $duree / 2.0 ]
         set t2 [expr $t0 - $width / ( 2.0 * $vn ) ]
         set t3 [expr $t0 + $width / ( 2.0 * $vn ) ]
         set t4 [expr $t0 + $duree / 2.0 ]
      }
      
      
      if {$imod==-1} {
         # bord droit de la bande centre sur t0
         set t1 [expr $t0 - $duree / 2.0 ]
         set t2 $t0
         set t3 [expr $t0 + $width / $vn ]
         set t4 [expr $t0 + $duree / 2.0 ]
      }
      
   
      if {$imod==1} {
         # bord gauche de la bande centre sur t0
         set t1 [expr $t0 - $duree / 2.0 ]
         set t2 [expr $t0 - $width / $vn ]
         set t3 $t0
         set t4 [expr $t0 + $duree / 2.0 ]
      }
   
      if {$t1<$t2} {
         puts $changeo "$t1,$phi1"
         puts $changeo "$t2,$phi1"
         puts $changeo "$t2,$phi0"
      } else {
         puts $changeo "$t1,$phi0"
      }
      if {$t3<$t4} {
         puts $changeo "$t3,$phi0"
         puts $changeo "$t3,$phi1"
         puts $changeo "$t4,$phi1"
      } else {
         puts $changeo "$t4,$phi0"
      }

      close $changeo

   }

   #-----------------------------------------------------------------

   proc ::av4l_analysis_tools::interpol { nmod t } {

      set zero 0.0
      for {set i 1} {$i<$nmod} {incr i} {
         set fac [expr ( $t - $::av4l_analysis_tools::tl($i) ) * ($t - $::av4l_analysis_tools::tl([expr $i + 1]) ) ]
         if {$fac<=$zero} {
            set fmod_inter [expr ($::av4l_analysis_tools::fluxl([expr $i + 1])- $::av4l_analysis_tools::fluxl($i)) / ($::av4l_analysis_tools::tl([expr $i + 1])- $::av4l_analysis_tools::tl($i)) ]
            #::console::affiche_resultat "tmod : $::av4l_analysis_tools::tl($i) $::av4l_analysis_tools::tl([expr $i + 1])\n" 
            #::console::affiche_resultat "fmod : $::av4l_analysis_tools::fluxl($i) $::av4l_analysis_tools::fluxl([expr $i + 1])\n" 
            #::console::affiche_resultat "fmod_inter : $i $fmod_inter\n" 
            set fmod_inter [expr $fmod_inter*( $t - $::av4l_analysis_tools::tl($i) ) + $::av4l_analysis_tools::fluxl($i)]
            #::console::affiche_resultat "fmod_inter : $i $fmod_inter\n" 
            return $fmod_inter
         }
      } 
      return -code 1 "Pas d''interpolation possible!!!\n"
   }

   #-----------------------------------------------------------------
   # 
   # Integrale d'une fonction par la methode de Simpson
   # Integre la fonction f(x,y) sur y entre a et b, avec npt intervalles
   # Attention, npt doit etre pair !
   # 
   #    integrale(a,b)= (h/3)*[ f(x,a0) + 4f(x,a1) + 2f(x,a2) + 4f(x,a3) + ...
   #                      ... + 2f(x,an-2) + 4f(x,an-1) + f(x,an) ]
   # 
   #    ou h= (b-a)/npt, a0= a et an= b
   # 
   # 
   # 
   proc ::av4l_analysis_tools::sommation { a b x npt } {

      set h [expr ($b-$a)/($npt*1.0)]
      
      # somme des termes impairs
      set somi 0.0
      for {set i 1} {$i<$npt} {incr i 2} {
         set y [expr $a + $i * $h]
         set somi  [expr $somi + ::av4l_analysis_tools::func($x,$y)]
      }
      set somi [expr 4.0 * $somi]
      
      # somme des termes pairs
      set somi 0.0
      for {set i 2} {$i<=[expr $npt - 2]} {incr i 2} {
         set y [expr $a + $i * $h]
         set somp  [expr $somp + ::av4l_analysis_tools::func($x,$y)]
      }
      set somp [expr 4.0 * $somp]
      
      # addition des bornes
      set somme [expr ::av4l_analysis_tools::func($x,$a) + $somi + $somp + ::av4l_analysis_tools::func($x,$b)]
      set somme [expr ( $h * $somme ) / 3.0]
      return $somme
   }


   #-----------------------------------------------------------------
   # Calcul de l'intensite lumineuse a (x,y) du centre 
   # de l'etoile (assombrissement centre-bord)
   #
   # l'intensite lumineuse I emise par un element de surface 
   # de l'etoile dont la normale fait un angle theta avec 
   # la ligne de visee, avec mu=cos(theta), est de la form:
   #
   # I(mu)= 1 - sum_1^4 a_k*[1-mu^(k/2)]
   #
   # NB. l'intensite vaut un au milieu du disque stellaire (ou mu=1) 
   #
   # Sources: Claret Astron. Astrophys. 363, 1081Ð1190 (2000) et
   #-----------------------------------------------------------------
   proc ::av4l_analysis_tools::func { x y } {

      set tol  -1.e-15

      set a(1)  0.6699
      set a(2) -0.7671
      set a(3)  1.6405
      set a(4) -0.6607

      set fac [expr 1.0 - (pow(x,2) + pow(y,2))]
      if { $fac < 0.0  } { (fac.lt.(0.d0)) then
         if {$fac < $tol } {
            ::console::affiche_erreur  "Erreur dans le calcul de l'intensite lumineuse : 1-x^2-y^2=$fac\n"
         
         }(fac.lt.tol) write (*,*) 'erreur: 1-x^2-y^2=', fac
         set fac 0.0
      }

      set mu [expr sqrt($fac)]     

      set f 1.0
      for {set k 1} {$k<=4} {incr k} {
         set f [expr $f - $a($k)*( 1.0-pow($mu,$k)/2.0 )]
      }


   }






   # Procedure d'ajustement d'un polynome sur le signal
   # afin d'endeterminer la dispersion. 
   # -> estimation du sigma

   proc ::av4l_analysis_tools::calcul_sigma {  } {


      return 0.7

   }








   #
   proc ::av4l_analysis_tools::run {  } {
      

      ::av4l_analysis_tools::init
      ::av4l_analysis_tools::charge_cdl [file join $::av4l_analysis_tools::dirwork "immersion.dat"]
      #::av4l_analysis_tools::affiche_cdl
      ::av4l_analysis_tools::partie1
      ::av4l_analysis_tools::partie2
      
   }





}


