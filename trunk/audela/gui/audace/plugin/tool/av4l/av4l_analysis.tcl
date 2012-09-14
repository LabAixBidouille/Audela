#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_analysis.tcl
#--------------------------------------------------
#
# Fichier        : av4l_analysis.tcl
# Description    : Outil Courbe de lumiere
# Auteur         : Frederic Vachier
# Mise à jour $Id: av4l_analysis.tcl 7986 2011-12-22 20:15:55Z svaillant $
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

namespace eval ::av4l_analysis {

package require math::statistics

      variable cols
      variable cdl
      variable nb
      variable diravi
      variable dirwork
      variable filecsv
      



   proc ::av4l_analysis::init {  } {

      set ::av4l_analysis::diravi "/data/Occultations/20100605_80SAPPHO"
      set ::av4l_analysis::dirwork "/data/Occultations/20100605_80SAPPHO/work"
      set ::av4l_analysis::filecsv "sapphoseg.00.avi.00001.csv"

      if {[info exists ::av4l_analysis::cols]} {unset ::av4l_analysis::cols}
      if {[info exists ::av4l_analysis::cdl]} {unset ::av4l_analysis::cdl}
      if {[info exists ::av4l_analysis::nb]} {unset ::av4l_analysis::nb}

      set file [file join $::av4l_analysis::dirwork "ombre_geometrique.csv"]
      set chan [open $file w]
      puts $chan "# OMBRE GEOMETRIQUE"
      close $chan
      
   }
 
   proc ::av4l_analysis::charge_cdl { file } {


      ::console::affiche_resultat "Chargement de la courbe : $file\n"


      set cpt 0
      
      set chan [open $file r]
      while {[gets $chan line] >= 0} {
         set line [string trim $line]
         set c [string index $line 0]
         if {$c=="#"} {continue}

         # description des colonnes
         if {$cpt==0} {
         
            set cols [split $line ","]
            set ::av4l_analysis::cols ""
            foreach col $cols {
               ::console::affiche_resultat  "col:$col\n"
               lappend ::av4l_analysis::cols [string trim $col]
            }
            ::console::affiche_resultat  "cols:$::av4l_analysis::cols\n"
            incr cpt
            continue
         }
         
         #::console::affiche_resultat  "$cpt:$line\n"
         set a [split $line ","]
         set idframe [lindex $a 0]

         set idcol 0
         foreach col $::av4l_analysis::cols {
            set ::av4l_analysis::cdl($cpt,$col) [string trim [lindex $a $idcol]]
            incr idcol
         }
         
         #if {$cpt > 32} {break}
         incr cpt
      }
      close $chan
      set ::av4l_analysis::nbframe [expr $cpt - 1]
      ::console::affiche_resultat  "nbframe=$::av4l_analysis::nbframe\n"
   }



   proc ::av4l_analysis::affiche_cdl {  } {

      ::console::affiche_resultat "Afichage de la courbe\n"

      for {set i 1} {$i<=$::av4l_analysis::nbframe} {incr i} {
         foreach col $::av4l_analysis::cols {
            ::console::affiche_resultat  "$::av4l_analysis::cdl($i,$col) "
         }
            ::console::affiche_resultat  "\n"
      }

   }



   proc ::av4l_analysis::sauve_brut {  } {
      
      set file [file join $::av4l_analysis::dirwork "brut.csv"]
      set chan [open $file w]
      puts $chan "idframe,jd,obj_fint"
      for {set i 1} {$i<=$::av4l_analysis::nbframe} {incr i} {
         #if {$::av4l_analysis::cdl($i,jd)==""} {continue}
         #if {$::av4l_analysis::cdl($i,obj_fint)==""} {continue}
         puts $chan "$::av4l_analysis::cdl($i,idframe),$::av4l_analysis::cdl($i,jd),$::av4l_analysis::cdl($i,obj_fint)"
      }
      close $chan

   }
   proc ::av4l_analysis::sauve_bmediane {  } {
      
      set file [file join $::av4l_analysis::dirwork "bmediane.csv"]
      set chan [open $file w]
      puts $chan "idframe,jd,obj_fint,mediane"
      for {set i 1} {$i<=$::av4l_analysis::nbframe} {incr i} {
         #if {$::av4l_analysis::cdl($i,jd)==""} {continue}
         #if {$::av4l_analysis::cdl($i,obj_fint)==""} {continue}
         if {![info exists ::av4l_analysis::cdl($i,mediane)]} {
            set ::av4l_analysis::cdl($i,mediane) ""
         }
         puts $chan "$::av4l_analysis::cdl($i,idframe),$::av4l_analysis::cdl($i,jd),$::av4l_analysis::cdl($i,obj_fint),$::av4l_analysis::cdl($i,mediane)"
      }
      close $chan

   }
   proc ::av4l_analysis::sauve_mediane {  } {
      
      set file [file join $::av4l_analysis::dirwork "mediane.csv"]
      set chan [open $file w]
      puts $chan "idframe,jd,flux"
      foreach v $::av4l_analysis::newcdl {
         puts $chan "[lindex $v 0],[lindex $v 1],[lindex $v 2]"
      }
      close $chan

   }

   proc ::av4l_analysis::compacte {  } {

      set offset 4
      set bloc 8
      
      set ::av4l_analysis::newcdl ""
      set fin "no"
      set i 1
      while {$fin=="no"} {
         if { $i<$offset} {
            incr i
            continue
         }
         set med ""
         set k $i
         for {set j 1} {$j<=$bloc} {incr j} {
            incr k
            lappend med $::av4l_analysis::cdl($k,obj_fint)
         }
         ::console::affiche_resultat "MED=$med\n"
         set med [::math::statistics::median $med]
         ::console::affiche_resultat "MED=$med\n"
         for {set j 1} {$j<=$bloc} {incr j} {
            incr i
            if {$j==1} {
               lappend ::av4l_analysis::newcdl [list $i $::av4l_analysis::cdl($i,jd) $med]
            }
            set ::av4l_analysis::cdl($i,mediane) $med
         }
         set reste [expr $::av4l_analysis::nbframe - $i]
         if {$reste<$bloc} {break}
         
      }

 
   }


   proc ::av4l_analysis::genere_mediane {  } {

      ::av4l_analysis::init
      ::av4l_analysis::charge_cdl [file join $::av4l_analysis::diravi $::av4l_analysis::filecsv]
      #::av4l_analysis::affiche_cdl 
      ::av4l_analysis::sauve_brut
      ::av4l_analysis::compacte
      ::av4l_analysis::sauve_bmediane
      ::av4l_analysis::sauve_mediane

   }



   proc ::av4l_analysis::partie1 {  } {

      # Mode:
      # -1= t0 centre sur l''immersion
      # +1= t0 centre sur l''emersion
      # 0 = t0 centre sur le millieu de la bande

      set ::av4l_analysis::mode -1

      # idon :
      # Faut-il comparer a des donnees
      # 1 oui
      # 0 non

      # Longueur d''onde (microns)
      set ::av4l_analysis::wvlngth
      set ::av4l_analysis::wvlngth [expr $::av4l_analysis::wvlngth * 1.e-09]

      # Bande passante (microns)
      set ::av4l_analysis::dlambda
      set ::av4l_analysis::dlambda [expr $::av4l_analysis::dlambda * 1.e-09]

      #  Distance a l'anneau (km)
      set ::av4l_analysis::dist

      #  Rayon de l'etoile (km)
      set ::av4l_analysis::re

      # Vitesse normale de l'etoile (dans plan du ciel, km/s)
      set ::av4l_analysis::vn

      # Largeur de la bande (km)
      set ::av4l_analysis::width

      # transmission
      set ::av4l_analysis::trans

      # Duree generee (sec)
      set ::av4l_analysis::duree

      # pas en temps (sec)
      set ::av4l_analysis::pas

      # Flux hors occultation
      set ::av4l_analysis::phi1

      # flux stellaire zero
      set ::av4l_analysis::phi0
      
      # Heure de reference (sec TU)
      set ::av4l_analysis::t0_ref
      set ::av4l_analysis::t_milieu [expr $::av4l_analysis::t0_ref  + $::av4l_analysis::width/(2.d0*$::av4l_analysis::vn)]

      # Nombre d''heures a explorer autour de la reference (sec)
      set ::av4l_analysis::nheure
      
      # pas (sec)
      set ::av4l_analysis::pas_heure
      set ::av4l_analysis::t0_min [expr $::av4l_analysis::t0_ref - $::av4l_analysis::pas_heure * nheure / 2.0]
      set ::av4l_analysis::t0_max [expr $::av4l_analysis::t0_ref + $::av4l_analysis::pas_heure * nheure / 2.0]
      set ::av4l_analysis::t0     $::av4l_analysis::t0_min
      
   }







   proc ::av4l_analysis::partie2 {  } {


      #-----------------------------------------------------------------------------
      #Constantes
      set nmax 10000
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
      set file21 [file join $::av4l_analysis::dirwork "21_modele_flux_avant_convol.csv"]
      set chan21 [open $file21 w]
      set file22 [file join $::av4l_analysis::dirwork "22_modele_flux_apres_convol.csv"]
      set chan22 [open $file22 w]
      set file23 [file join $::av4l_analysis::dirwork "23_.csv"]
      set chan23 [open $file23 w]
      set file24 [file join $::av4l_analysis::dirwork "24_.csv"]
      set chan24 [open $file24 w]
      set file26 [file join $::av4l_analysis::dirwork "26_.csv"]
      set chan26 [open $file26 w]
      #-----------------------------------------------------------------------------
      
      #-----------------------------------------------------------------------------
      # Observations :
      #TODO
      
      #Sigma des observations
      #TODO
      set sigma 
      #-----------------------------------------------------------------------------


      while { $::av4l_analysis::t0<=$::av4l_analysis::t0_max} {
      
         set npt [expr int ($::av4l_analysis::duree/(2.0*$::av4l_analysis::pas) )]
         if {$::av4l_analysis::imod==-1} {
            # bord gauche de l'ombre cale
            # sur l'origine (ie t0 en temps)
            set x1 0.0
            set x2 $::av4l_analysis::width
         }
         if {$::av4l_analysis::imod==0} {
            # ombre centree sur le milieu
            # de la bande
            set x1 [expr -$::av4l_analysis::width / 2.0 ]
            set x2 [expr  $::av4l_analysis::width / 2.0 ]
         }
         if {$::av4l_analysis::imod==1} {
            # bord droit de l'ombre cale
            # sur l'origine (ie t0 en temps)
            set x1 [expr -$::av4l_analysis::width ]
            set x2 0.0
         }

         set opa_ampli [expr  1.0 - sqrt($::av4l_analysis::trans)]
      
         # Trace de l'ombre geometrique
         ::av4l_analysis::ombre_geometrique  $::av4l_analysis::imod $::av4l_analysis::t0 $::av4l_analysis::duree $::av4l_analysis::width $::av4l_analysis::vn $::av4l_analysis::phi1 $::av4l_analysis::phi0

      
      
      
         #-----------------------------------------------------------------------------
         #      etoile: sous-programme de convolution par le diametre
         #         stellaire.
         #
         #      NB.:    on appelle deux fois etoile pour convoluer par la
         #         bande passante.
         #
         set som 0.0

         for {set i [expr -$npt]} {$i<=$npt} {incr i} {
            set x [expr $::av4l_analysis::vn * $::av4l_analysis::pas * $i]
            set wvlngth1 [expr $::av4l_analysis::wvlngth - $::av4l_analysis::dlambda / 2.0]
            set wvlngth2 [expr $::av4l_analysis::wvlngth + $::av4l_analysis::dlambda / 2.0]
            set flux1 [::av4l_analysis::etoile $::av4l_analysis::re $x1 $x2 $opa_ampli $wvlngth1 $::av4l_analysis::dist $x]
            set flux2 [::av4l_analysis::etoile $::av4l_analysis::re $x1 $x2 $opa_ampli $wvlngth2 $::av4l_analysis::dist $x]
            set flu [expr  ( $flux1 + $flux2 )/2.0]
            set flux($i) [expr $flu*($::av4l_analysis::phi1-$::av4l_analysis::phi0) + $::av4l_analysis::phi0]
            set t($i) [expr $::av4l_analysis::t0 + $i * $::av4l_analysis::pas]
            puts $chan21 "$t($i),$flux($i)"
            set som [expr $som + $::av4l_analysis::pas * $::av4l_analysis::vn * (1.0-$flux($i))]
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
            set tl($nptl) $t($i)
            set fluxl($nptl) $flux(i)
         }
         #-----------------------------------------------------------------------------
      
      
         #-----------------------------------------------------------------------------
         #
         # Ecriture du modele final (apres convolution par etoile et instrument)
         #
         set som 0.0
         set tl_min  1.e50
         set tl_max  -1.d50   
         for {set i 1} {$i<=$nptl} {incr i} {
            puts $chan22 "$tl($i),$fluxl($i)"
            if {$tl($i)>=$tl_max} {set tl_max $tl($i)}
            if {$tl($i)<=$tl_min} {set tl_min $tl($i)}
            set som [expr $som + $::av4l_analysis::pas * $::av4l_analysis::vn * (1.0 - $fluxl($i))]
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
         for {set i 1} {$i<=$nobs} {incr i} {
            set fac [expr ($tobs($i)-$tl_min)*($tobs($i)-$tl_max)]
            if {$fac<=0.0} {
               #TODO
               set fmod_inter [::av4l_analysis::interpol $nmax $nptl ($tl) ($fluxl) $tobs($i)]
               puts $chan23 "$tobs($i),$fmod_inter"
               # fmod_inter ! attention !
               set sigma_local $sigma
               set chi2 [expr $chi2 + pow(($fmod_inter - $fobs($i))/$sigma_local,2)]
               incr nfit
               if {$tobs($i)<$tobs_min)} {set tobs_min $tobs($i)}
               if {$tobs($i)>$tobs_max)} {set tobs_max $tobs($i)}
            }
         }
         ::console::affiche_resultat "t0: $::av4l_analysis::t0\n"      
         ::console::affiche_resultat "chi2: $chi2\n"      
         ::console::affiche_resultat "nfit: $nfit\n"      
         ::console::affiche_resultat "temps milieu de la bande: $t_milieu\n"      
         ::console::affiche_resultat "duree de la bande: [expr $::av4l_analysis::width/$::av4l_analysis::vn]\n"      
         ::console::affiche_resultat "$nfit points fittes entre: $tobs_min et $tobs_max  \n"      
         puts $chan24 "$::av4l_analysis::t0,$chi2,$nfit"
         puts $chan26 "[expr $chi2 - $nfit*1.0]"
         #-----------------------------------------------------------------------------

         #  on incremente t0
         set ::av4l_analysis::t0 [expr $::av4l_analysis::t0 + $::av4l_analysis::pas_heure] 
         ::console::affiche_resultat "---------------------------------------------------\n"      
      
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
      do i= 1, nmax
       read (24,*,err=103,end=103) t0, chi2, nfit
         if {chi2.le.chi2_min} {
           chi2_min     = chi2
           t0_chi2_min  = t0
           nfit_chi2_min= nfit
         }
      enddo

   close (24)
   open (unit=24,file='fort.24',status='old',form='formatted',position='rewind')
   dchi2=  1.d00
   t_inf=  1.d50
   t_sup= -1.d50
   do i= 1, nmax
    read (24,*,err=104,end=104) t0, chi2, nfit
    if (chi2.le.(chi2_min+dchi2)) then
     if (t0.le.t_inf) t_inf= t0
     if (t0.ge.t_sup) t_sup= t0
    endif
   enddo
104   continue

   write (*,*) 
   write (*,'(A,f9.3,3x,f6.3,3x,I3)') 't0, chi2 et nfit au minimum: ', t0_chi2_min, chi2_min, nfit_chi2_min
   write (*,'(A,f5.2,2x,f9.3,2x,f9.3)')  
     *   'Dchi2, intervalle ou chi2 < chi2_min + dchi2: ', sngl(dchi2), sngl(t_inf), sngl(t_sup)

   open (unit=25,file='fort.25',status='unknown',form='formatted',position='append')
c   write (25,*) sngl(width), sngl(chi2_min), nfit_chi2_min
   write (25,*) sngl(width/vn), sngl(chi2_min), nfit_chi2_min



   }













   # Trace de l'ombre geometrique
   proc ::av4l_analysis::ombre_geometrique { imod t0 duree width vn phi1 phi0 } {

      set file [file join $::av4l_analysis::dirwork "ombre_geometrique.csv"]
      set chan [open $file a+]

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
         puts $chan "$t1,$phi1"
         puts $chan "$t2,$phi1"
         puts $chan "$t2,$phi0"
      } else {
         puts $chan "$t1,$phi0"
      }
      if {$t3<$t4} {
         puts $chan "$t3,$phi0"
         puts $chan "$t3,$phi1"
         puts $chan "$t4,$phi1"
      } else {
         puts $chan "$t4,$phi0"
      }

      close $chan

   }

   #
   proc ::av4l_analysis::run {  } {

      ::av4l_analysis::init
      ::av4l_analysis::charge_cdl [file join $::av4l_analysis::dirwork "mediane.csv"]
      #::av4l_analysis::affiche_cdl
      ::av4l_analysis::partie1
      
   }





}


