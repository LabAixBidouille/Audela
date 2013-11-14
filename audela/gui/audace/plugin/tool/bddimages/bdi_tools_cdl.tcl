## \file bdi_tools_cdl.tcl
#  \brief     Creation des courbes de lumiere 
#  \details   Ce namepsace se restreint a tout ce qui est gestion des variables
#             pour apporter un suport a la partie GUI
#  \author    Frederic Vachier
#  \version   1.0
#  \date      2013
#  \copyright GNU Public License.
#  \par Ressource 
#  \code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_cdl.tcl]
#  \endcode
#  \todo      normaliser les noms des fichiers sources 

#--------------------------------------------------
#
# source [ file join $audace(rep_plugin) tool bddimages bdi_tools_cdl.tcl ]
#
#--------------------------------------------------
#
# Mise à jour $Id: bdi_tools_cdl.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------

## Declaration du namespace \c bdi_tools_cdl.
#  @pre       Chargement a partir d'Audace
#  @bug       Probleme de memoire sur les exec
#  @warning   Appel SANS GUI
namespace eval bdi_tools_cdl {

   variable progress      ; # Barre de progression
   variable table_noms      ; # 
   variable table_nbcata      ; # 
   variable table_values      ; # 
}


   proc ::bdi_tools_cdl::stop_charge_cata_xml { } {
     set ::bdi_tools_cdl::encours_charge_cata_xml 0
   }

   #----------------------------------------------------------------------------
   ## Chargement des cata de la liste d'image selectionnee dans l'outil Recherche.
   #  \param void
   #  \note le resultat de cette procedure affecte la variable de
   # namespace  \c tools_cata::img_list puis charge toutes l'info des cata
   # associes aux images
   #----------------------------------------------------------------------------
   proc ::bdi_tools_cdl::charge_cata_xml { } {

      set tt0 [clock clicks -milliseconds]

      ::bdi_tools_cdl::init_spectral_type
      
      array unset ::bdi_tools_cdl::table_noms  
      array unset ::bdi_tools_cdl::table_nbcata
      array unset ::bdi_tools_cdl::table_othf
      array unset ::bdi_tools_cdl::table_othf

      # array unset ::gui_cata::cata_list


      set ::bdi_tools_cdl::encours_charge_cata_xml 1
      set idcata 0
      foreach ::tools_cata::current_image $::tools_cata::img_list {
         if {$::bdi_tools_cdl::encours_charge_cata_xml!=1} { break }
         incr idcata
         ::gui_cata::load_cata
         ::bdi_tools_cdl::set_progress $idcata $::tools_cata::nb_img_list
         ::bdi_tools_cdl::get_memory      

         # set ::gui_cata::cata_list($idcata) $::tools_cata::current_listsources
         
         set sources [lindex  $::tools_cata::current_listsources 1]         

         foreach s $sources {

            set name [::manage_source::namincata $s]
            if {$name == ""} {continue}

            if {[info exists ::bdi_tools_cdl::table_noms($name)]} {
               incr ::bdi_tools_cdl::table_nbcata($name)
            } else {
               set ::bdi_tools_cdl::table_nbcata($name) 1
            }
            set ::bdi_tools_cdl::table_noms($name) 1

            set ::bdi_tools_cdl::table_othf($name,$idcata,othf) [::bdi_tools_psf::get_astroid_othf_from_source $s]

            set USNOA2_magB     ""
            set USNOA2_magR     ""
            set UCAC4_im1_mag   ""
            set UCAC4_im2_mag   ""
            set NOMAD1_magB     ""
            set NOMAD1_magV     ""
            set NOMAD1_magR     ""
            set NOMAD1_magJ     ""
            set NOMAD1_magH     ""
            set NOMAD1_magK     ""

            foreach cata $s {
               switch [lindex $cata 0] {
                  "USNOA2" {
                     set USNOA2_magB   [lindex $cata 2 6]
                     set USNOA2_magR   [lindex $cata 2 7]
                  }
                  "UCAC4" {
                     set UCAC4_im1_mag [lindex $cata 2 4]
                     set UCAC4_im2_mag [lindex $cata 2 5]
                  }
                  "NOMAD1" {
                     set NOMAD1_magB   [lindex $cata 2 13]
                     set NOMAD1_magV   [lindex $cata 2 15]
                     set NOMAD1_magR   [lindex $cata 2 17]
                     set NOMAD1_magJ   [lindex $cata 2 18]
                     set NOMAD1_magH   [lindex $cata 2 19]
                     set NOMAD1_magK   [lindex $cata 2 20]
                  }
               }
            }
            gren_info "MAGS $name = $USNOA2_magB  $USNOA2_magR  $UCAC4_im1_mag $UCAC4_im2_mag \
                                           $NOMAD1_magB  $NOMAD1_magV  $NOMAD1_magR   $NOMAD1_magJ \
                                           $NOMAD1_magH  $NOMAD1_magK   \n"
            set r [::bdi_tools_cdl::get_spectral_type \
                                    [list \
                                           $USNOA2_magB  $USNOA2_magR  $UCAC4_im1_mag $UCAC4_im2_mag \
                                           $NOMAD1_magB  $NOMAD1_magV  $NOMAD1_magR   $NOMAD1_magJ \
                                           $NOMAD1_magH  $NOMAD1_magK  ] \
                   ]
            set ::bdi_tools_cdl::table_values($name,sptype)      [lindex $r 0]
            set  ::bdi_tools_cdl::table_values($name,sptype,cpt) [lindex $r 1]
            set  ::bdi_tools_cdl::table_values($name,sptype,sep) [lindex $r 2]
            #break
         }

      # Fin boucle sur les images
      }

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Chargement complet en $tt sec \n"

      return

   }





# Chargement des structure de variable pour l affichage
   proc ::bdi_tools_cdl::charge_cata_list { } {

      set tt0 [clock clicks -milliseconds]

      array unset ::bdi_tools_cdl::id_to_name
      array unset ::bdi_tools_cdl::table_dataline
      array unset ::bdi_tools_cdl::table_variations
      if {[info exists ::bdi_tools_cdl::list_of_stars]} {unset ::bdi_tools_cdl::list_of_stars}
      
      set ids 0
      foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
         incr ids
         if {$y == 0} {continue}

         array unset tab

         set nbimg 0
         for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {
            if {[info exists ::bdi_tools_cdl::table_othf($name,$idcata,othf)]} {
               incr nbimg
               set othf $::bdi_tools_cdl::table_othf($name,$idcata,othf)
               set mag [::bdi_tools_psf::get_val othf "mag"]
               if {$mag!="" && [string is double $mag] && $mag+1 != $mag} { lappend tab(mag) $mag }
               set flux [::bdi_tools_psf::get_val othf "flux"]
               if {$flux!="" && [string is double $flux] && $mag+1 != $mag} { lappend tab(flux) $flux }
            }
         }

         #gren_info "[llength $tab(mag)] $nbimg\n"
         #gren_info "$tab(mag)\n"
                  
         if { [info exists tab(mag)] } {
            if {[llength $tab(mag)]>1} {
               set mag_mean  [format "%0.4f" [::math::statistics::mean $tab(mag)]]
               set mag_stdev [format "%0.4f" [::math::statistics::stdev $tab(mag)]]
            } else {
               set mag_mean  [format "%0.4f" [lindex $tab(mag) 0]]
               set mag_stdev 0
            }
         } else {
               set mag_mean  "-99"
               set mag_stdev "0"
         }

         lappend ::bdi_tools_cdl::list_of_stars $ids
         set ::bdi_tools_cdl::id_to_name($ids) $name
         set ::bdi_tools_cdl::table_dataline($name) [list $ids $name $nbimg $mag_mean $mag_stdev]

      }

      # Onglet variation
      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {

         foreach ids1 $::bdi_tools_cdl::list_of_stars {
            set name1 $::bdi_tools_cdl::id_to_name($ids1)
            if {![info exists ::bdi_tools_cdl::table_othf($name1,$idcata,othf)]} { continue }
            set othf $::bdi_tools_cdl::table_othf($name1,$idcata,othf)
            set flux1 [::bdi_tools_psf::get_val othf "flux"]
            if { $flux1=="" || $flux1<=0 || $flux1+1 == $flux1} { continue }

            foreach ids2 $::bdi_tools_cdl::list_of_stars {
               set name2 $::bdi_tools_cdl::id_to_name($ids2)
               if {![info exists ::bdi_tools_cdl::table_othf($name2,$idcata,othf)]} { continue }
               set othf $::bdi_tools_cdl::table_othf($name2,$idcata,othf)
               set flux2 [::bdi_tools_psf::get_val othf "flux"]
               if { $flux2=="" || $flux2<=0 || $flux2+1 == $flux2 } { continue }
               
               lappend ::bdi_tools_cdl::table_variations($ids1,$ids2,flux) [expr 1.0*$flux1/$flux2]
               lappend ::bdi_tools_cdl::table_variations($ids2,$ids1,flux) [expr 1.0*$flux2/$flux1]

            }

         }

      }

      array unset tab
      foreach ids1 $::bdi_tools_cdl::list_of_stars {
         foreach ids2 $::bdi_tools_cdl::list_of_stars {
            if { [info exists ::bdi_tools_cdl::table_variations($ids1,$ids2,flux)] } {
               set tab(flux) $::bdi_tools_cdl::table_variations($ids1,$ids2,flux)
               
               
               set nbmes [llength $tab(flux)]
               if {$nbmes>1} {
                  set meanflux  [::math::statistics::mean  $tab(flux)]
                  set stdevflux [::math::statistics::stdev $tab(flux)]
                  set mag ""
                  foreach rflux $tab(flux) {
                     lappend mag [expr  - 2.5*log10($rflux)]
                  }
                  set stdevmag  [::math::statistics::stdev $mag]
               } else {
                  set meanflux  [lindex $tab(flux) 0]
                  set stdevflux 0
                  set stdevmag  "-98"
               }
            } else {
               set nbmes -1
               set meanflux  "-99"
               set stdevflux "-99"
            }

            set ::bdi_tools_cdl::table_variations($ids1,$ids2,flux,mean)  $meanflux
            set ::bdi_tools_cdl::table_variations($ids1,$ids2,flux,stdev) $stdevflux
            set ::bdi_tools_cdl::table_variations($ids1,$ids2,mag,stdev)  $stdevmag
            set ::bdi_tools_cdl::table_variations($ids1,$ids2,flux,nbmes) $nbmes
         }
      }

      # Onglet Classification

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Affichage complet en $tt sec \n"

   }








   proc ::bdi_tools_cdl::set_progress { cur max } {
      set ::bdi_tools_cdl::progress [format "%0.0f" [expr $cur * 100. /$max ] ]
      update
   }

   proc ::bdi_tools_cdl::get_mem { p_info key } {
      upvar $p_info info

      set a [string first $key $info]
      set a [ string range $info [expr $a + [string length $key]] [expr $a + 30] ]
      set b [expr [string first "kB" $a] -1]
      set a [ string range $a 0 $b ]
      set a [ string trim $a]
      return $a 
   }
   
   
   
   proc ::bdi_tools_cdl::get_memory {  } {

      if {$::bdi_tools_cdl::memory(memview)==0} {return}

      set pid [exec pidof audela]
            
      set info [exec cat /proc/$pid/status ]
      
      set ::bdi_tools_cdl::memory(mempid) [format "%0.1f Mb" [expr \
                  [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]

      set info [exec cat /proc/meminfo ]

      set ::bdi_tools_cdl::memory(memtotal) [::bdi_tools_cdl::get_mem info "MemTotal:"]
      set ::bdi_tools_cdl::memory(memfree) [::bdi_tools_cdl::get_mem info "MemFree:"]
      set ::bdi_tools_cdl::memory(swaptotal) [::bdi_tools_cdl::get_mem info "SwapTotal:"]
      set ::bdi_tools_cdl::memory(swapfree) [::bdi_tools_cdl::get_mem info "SwapFree:"]
      set ::bdi_tools_cdl::memory(mem) [format "%0.1f" [expr 100.0*$::bdi_tools_cdl::memory(memfree)/$::bdi_tools_cdl::memory(memtotal)]]
      set ::bdi_tools_cdl::memory(swap) [format "%0.1f" [expr 100.0*$::bdi_tools_cdl::memory(swapfree)/$::bdi_tools_cdl::memory(swaptotal)]]
   }
   
   proc ::bdi_tools_cdl::get_spectral_type { l } {

      set USNOA2_magB    [ lindex $l  0 ]
      set USNOA2_magR    [ lindex $l  1 ]
      set UCAC4_im1_mag  [ lindex $l  2 ]
      set UCAC4_im2_mag  [ lindex $l  3 ]
      set NOMAD1_magB    [ lindex $l  4 ]
      set NOMAD1_magV    [ lindex $l  5 ]
      set NOMAD1_magR    [ lindex $l  6 ]
      set NOMAD1_magJ    [ lindex $l  7 ]
      set NOMAD1_magH    [ lindex $l  8 ]
      set NOMAD1_magK    [ lindex $l  9 ]

      set U ""
      set B ""
      set V ""
      set U ""
      set R ""
      set I ""
      set J ""
      set H ""
      set K ""
      set L ""
      set M ""
      set N ""
       
      if {$USNOA2_magB   != "" && $USNOA2_magB   > -10 } {set B $USNOA2_magB  }
      if {$USNOA2_magR   != "" && $USNOA2_magR   > -10 } {set R $USNOA2_magR  }
#      if {$UCAC4_im1_mag != "" && $UCAC4_im1_mag > -10 } {set N $UCAC4_im1_mag}
#      if {$UCAC4_im2_mag != "" && $UCAC4_im2_mag > -10 } {set N $UCAC4_im2_mag}
      if {$NOMAD1_magB   != "" && $NOMAD1_magB   > -10 } {set B $NOMAD1_magB  }
      if {$NOMAD1_magV   != "" && $NOMAD1_magV   > -10 } {set V $NOMAD1_magV  }
      if {$NOMAD1_magR   != "" && $NOMAD1_magR   > -10 } {set R $NOMAD1_magR  }
      if {$NOMAD1_magJ   != "" && $NOMAD1_magJ   > -10 } {set J $NOMAD1_magJ  }
      if {$NOMAD1_magH   != "" && $NOMAD1_magH   > -10 } {set H $NOMAD1_magH  }
      if {$NOMAD1_magK   != "" && $NOMAD1_magK   > -10 } {set K $NOMAD1_magK  }

      gren_info "band = B=$B V=$V R=$R J=$J H=$H K=$K \n"

      set UB ""
      set BV ""
      set VR ""
      set VI ""
      set VJ ""
      set VH ""
      set VK ""
      set VL ""
      set VM ""
      set VN ""

      if {$U!="" && $B!=""} { set UB [expr $U - $B] }      
      if {$B!="" && $V!=""} { set BV [expr $B - $V] }      
      if {$V!="" && $R!=""} { set VR [expr $V - $R] }      
      if {$V!="" && $I!=""} { set VI [expr $V - $I] }      
      if {$V!="" && $J!=""} { set VJ [expr $V - $J] }      
      if {$V!="" && $H!=""} { set VH [expr $V - $H] }      
      if {$V!="" && $K!=""} { set VK [expr $V - $K] }      
      if {$V!="" && $L!=""} { set VL [expr $V - $L] }      
      if {$V!="" && $M!=""} { set VM [expr $V - $M] }      
      if {$V!="" && $N!=""} { set VN [expr $V - $N] }      

      set idst ""
      if {$UB!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band UB $UB] }
      if {$BV!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band BV $BV] }
      if {$VR!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VR $VR] }
      if {$VI!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VI $VI] }
      if {$VJ!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VJ $VJ] }
      if {$VH!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VH $VH] }
      if {$VK!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VK $VK] }
      if {$VL!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VL $VL] }
      if {$VM!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VM $VM] }
      if {$VN!=""} { lappend idst [::bdi_tools_cdl::get_indice_by_band VN $VN] }

      set cpt  [llength $idst]
      
      if {$cpt > 1 } {
         set mean [expr int([::math::statistics::mean $idst])]
         set min  [::math::statistics::min $idst]
         set max  [::math::statistics::max $idst]
         set sep  [expr $max - $min]
      } elseif { $cpt == 1 } {
         set mean [lindex $idst 0]
         set sep  -99
      } else {
         set mean -99
         set sep  -99
      }
      gren_info "result = $mean [lindex $::bdi_tools_cdl::table_sptype(sptype) $mean] $cpt $sep\n"
      if {$mean>=0 && $mean<50} {
         return [list [lindex $::bdi_tools_cdl::table_sptype(sptype) $mean] $cpt $sep]
      }
      return "?"
   }

   proc ::bdi_tools_cdl::get_indice_by_band { band mag} {

      gren_info "get_indice_by_band = $band $mag \n"

      set min 99
      set idst 0
      set idmin -1
      
      foreach val $::bdi_tools_cdl::table_sptype($band) {
         set tmp [expr abs($val - $mag)]
         if {$tmp<$min} { 
            set idmin $idst 
            set min $tmp 
         }
         incr idst
      }

      gren_info "get_indice_by_band = $idmin \n"
      return $idmin
   }

# The following table aims to provide a guide to the unreddened 
# colours expected for main sequence stars of spectral types B0 
# to M4. The data are taken from Fitzgerald (1970 - A&A 4, 234), 
# who provides UBV data for spectral classes O5 to M8, and from 
# Ducati et al. (2001 - ApJ, 558, 309), who cover B0 to M4. Both 
# compilations also present data for giants and supergiants. 
# Ducati et al. present photometry on the Johnson 11-colour 
# system, and we have used the relations given by Bessell (1979 
# - PASP 91, 589) to transform the (V-R) and (V-I) colours to 
# the Cousins system. The L (3.5 micron), M (4.8 micron) and N 
# (10.5 micron) colours are essentially on the PbS-based system 
# and give only a guide to the colours with modern photometers, 
# detectors and filters. 
# 
#  
# SpType   U-B   (B-V)  (V-R)C  (V-I)C   (V-J)   (V-H)   (V-K)   (V-L)   (V-M)   (V-N)  (V-R)J  (V-I)J
# B0.0   -1.08   -0.30   -0.19   -0.31   -0.80   -0.92   -0.97   -1.13   -1.00   -9.99   -0.22   -0.44
# B0.5   -1.00   -0.28   -0.18   -0.31   -0.77   -0.89   -0.95   -1.11   -0.99   -9.99   -0.20   -0.43
# B1.0   -0.95   -0.26   -0.16   -0.30   -0.73   -0.85   -0.93   -1.08   -0.96   -9.99   -0.18   -0.42
# B1.5   -0.88   -0.25   -0.15   -0.29   -0.70   -0.82   -0.91   -1.05   -0.94   -9.99   -0.17   -0.41
# B2.0   -0.81   -0.24   -0.14   -0.29   -0.67   -0.79   -0.89   -1.02   -0.92   -9.99   -0.15   -0.40
# B2.5   -0.72   -0.22   -0.13   -0.28   -0.64   -0.76   -0.86   -0.97   -0.88   -0.96   -0.14   -0.39
# B3.0   -0.68   -0.20   -0.12   -0.27   -0.60   -0.72   -0.82   -0.92   -0.84   -0.91   -0.13   -0.38
# B3.5   -0.65   -0.19   -0.12   -0.26   -0.58   -0.70   -0.80   -0.90   -0.82   -0.87   -0.12   -0.37
# B4.0   -0.63   -0.18   -0.11   -0.25   -0.56   -0.68   -0.77   -0.86   -0.79   -0.84   -0.11   -0.35
# B4.5   -0.61   -0.17   -0.11   -0.24   -0.54   -0.65   -0.74   -0.83   -0.76   -0.80   -0.11   -0.34
# B5.0   -0.58   -0.16   -0.10   -0.24   -0.51   -0.62   -0.71   -0.78   -0.73   -0.75   -0.10   -0.33
# B6.0   -0.49   -0.14   -0.10   -0.21   -0.46   -0.57   -0.64   -0.70   -0.65   -0.66   -0.09   -0.29
# B7.0   -0.43   -0.13   -0.09   -0.19   -0.41   -0.51   -0.57   -0.61   -0.58   -0.58   -0.08   -0.26
# B7.5   -0.40   -0.12   -0.09   -0.17   -0.39   -0.48   -0.54   -0.57   -0.54   -0.53   -0.08   -0.24
# B8.0   -0.36   -0.11   -0.08   -0.16   -0.36   -0.45   -0.49   -0.52   -0.49   -0.48   -0.07   -0.22
# B8.5   -0.27   -0.09   -0.08   -0.13   -0.31   -0.40   -0.43   -0.43   -0.42   -0.39   -0.07   -0.18
# B9.0   -0.18   -0.07   -0.07   -0.10   -0.26   -0.34   -0.33   -0.34   -0.34   -0.30   -0.06   -0.14
# B9.5   -0.10   -0.04   -0.05   -0.08   -0.22   -0.29   -0.26   -0.27   -0.26   -0.22   -0.03   -0.11
# A0.0   -0.02   -0.01   -0.04   -0.04   -0.16   -0.19   -0.17   -0.18   -0.18   -0.14   -0.01   -0.05
# A1.0    0.01    0.02   -0.02   -0.02   -0.11   -0.12   -0.11   -0.12   -0.13   -0.08    0.01   -0.03
# A2.0    0.05    0.05   -0.01    0.00   -0.07   -0.04   -0.05   -0.07   -0.08   -0.02    0.03    0.00
# A3.0    0.08    0.08    0.01    0.02   -0.02    0.03    0.01   -0.01   -0.02    0.03    0.05    0.02
# A4.0    0.09    0.12    0.02    0.05    0.03    0.11    0.08    0.05   -0.04    0.09    0.07    0.07
# A5.0    0.09    0.15    0.04    0.09    0.09    0.19    0.15    0.12    0.10    0.16    0.10    0.12
# A6.0    0.10    0.17    0.05    0.12    0.13    0.30    0.21    0.17    0.15    0.21    0.11    0.16
# A7.0    0.10    0.20    0.06    0.15    0.18    0.32    0.27    0.23    0.20    0.26    0.13    0.19
# A8.0    0.09    0.27    0.09    0.20    0.25    0.42    0.36    0.33    0.29    0.34    0.16    0.26
# A9.0    0.08    0.30    0.10    0.24    0.31    0.49    0.44    0.41    0.36    0.41    0.18    0.31
# F0.0    0.03    0.32    0.12    0.28    0.37    0.57    0.52    0.49    0.43    0.48    0.21    0.36
# F1.0    0.00    0.34    0.14    0.31    0.43    0.64    0.58    0.57    0.49    0.54    0.23    0.40
# F2.0    0.00    0.35    0.15    0.35    0.48    0.71    0.66    0.66    0.56    0.60    0.25    0.45
# F5.0   -0.02    0.45    0.21    0.44    0.67    0.93    0.89    0.90    0.77    0.80    0.33    0.57
# F8.0    0.02    0.53    0.24    0.50    0.79    1.06    1.03    1.06    0.91    0.91    0.37    0.64 
# G0.0    0.06    0.60    0.27    0.54    0.87    1.15    1.14    1.18    1.01    1.01    0.41    0.70 
# G2.0    0.09    0.63    0.30    0.58    0.97    1.25    1.26    1.31    1.12    1.11    0.45    0.75 
# G3.0    0.12    0.65    0.30    0.59    0.98    1.27    1.28    1.33    1.14    1.13    0.45    0.76 
# G5.0    0.20    0.68    0.31    0.61    1.02    1.31    1.32    1.38    1.18    1.17    0.47    0.78 
# G8.0    0.30    0.74    0.35    0.66    1.14    1.44    1.47    1.55    1.34    1.30    0.52    0.85 
# K0.0    0.44    0.81    0.42    0.75    1.34    1.67    1.74    1.85    1.61    1.54    0.61    0.97 
# K1.0    0.48    0.86    0.46    0.82    1.46    1.80    1.89    2.02    1.78    1.68    0.67    1.05 
# K2.0    0.67    0.92    0.50    0.89    1.60    1.94    2.06    2.21    1.97    1.84    0.73    1.14 
# K3.0    0.73    0.95    0.55    0.97    1.73    2.09    2.23    2.40    2.17    2.01    0.80    1.25 
# K4.0    1.00    1.00    0.60    1.04    1.84    2.22    2.38    2.57    2.36    2.15    0.86    1.34 
# K5.0    1.06    1.15    0.68    1.20    2.04    2.46    2.66    2.87    2.71    2.44    0.97    1.54 
# K7.0    1.21    1.33    0.62    1.45    2.30    2.78    3.01    3.25    3.21    2.83    1.13    1.86 
# M0.0    1.23    1.37    0.70    1.67    2.49    3.04    3.29    3.54    3.65    3.16    1.26    2.15 
# M1.0    1.18    1.47    0.76    1.84    2.61    3.22    3.47    3.72    3.95    3.39    1.36    2.36 
# M2.0    1.15    1.47    0.83    2.06    2.74    3.42    3.67    3.92    4.31    3.66    1.46    2.62 
# M3.0    1.17    1.50    0.89    2.24    2.84    3.58    3.83    4.08    4.62    3.89    1.56    2.84 
# M4.0    1.07    1.52    0.94    2.43    2.93    3.74    3.98    4.22    4.93    4.11    1.65    3.07 
# 
# 
   proc ::bdi_tools_cdl::init_spectral_type { } {
      
      array unset ::bdi_tools_cdl::table_sptype

      set ::bdi_tools_cdl::table_sptype(UB) [list \
                      -1.08 -1.00 -0.95 -0.88 -0.81 \
                      -0.72 -0.68 -0.65 -0.63 -0.61 \
                      -0.58 -0.49 -0.43 -0.40 -0.36 \
                      -0.27 -0.18 -0.10 -0.02  0.01 \
                       0.05  0.08  0.09  0.09  0.10 \
                       0.10  0.09  0.08  0.03  0.00 \
                       0.00 -0.02  0.02  0.06  0.09 \
                       0.12  0.20  0.30  0.44  0.48 \
                       0.67  0.73  1.00  1.06  1.21 \
                       1.23  1.18  1.15  1.17  1.07 \
                       ]

      set ::bdi_tools_cdl::table_sptype(BV) [list \
                      -0.30 -0.28 -0.26 -0.25 -0.24 \
                      -0.22 -0.20 -0.19 -0.18 -0.17 \
                      -0.16 -0.14 -0.13 -0.12 -0.11 \
                      -0.09 -0.07 -0.04 -0.01  0.02 \
                       0.05  0.08  0.12  0.15  0.17 \
                       0.20  0.27  0.30  0.32  0.34 \
                       0.35  0.45  0.53  0.60  0.63 \
                       0.65  0.68  0.74  0.81  0.86 \
                       0.92  0.95  1.00  1.15  1.33 \
                       1.37  1.47  1.47  1.50  1.52 \
                       ]


      set ::bdi_tools_cdl::table_sptype(VR) [list \
                      -0.19 -0.18 -0.16 -0.15 -0.14 \
                      -0.13 -0.12 -0.12 -0.11 -0.11 \
                      -0.10 -0.10 -0.09 -0.09 -0.08 \
                      -0.08 -0.07 -0.05 -0.04 -0.02 \
                      -0.01  0.01  0.02  0.04  0.05 \
                       0.06  0.09  0.10  0.12  0.14 \
                       0.15  0.21  0.24  0.27  0.30 \
                       0.30  0.31  0.35  0.42  0.46 \
                       0.50  0.55  0.60  0.68  0.62 \
                       0.70  0.76  0.83  0.89  0.94 \
                       ]

      set ::bdi_tools_cdl::table_sptype(VI) [list \
                      -0.31 -0.31 -0.30 -0.29 -0.29 \
                      -0.28 -0.27 -0.26 -0.25 -0.24 \
                      -0.24 -0.21 -0.19 -0.17 -0.16 \
                      -0.13 -0.10 -0.08 -0.04 -0.02 \
                       0.00  0.02  0.05  0.09  0.12 \
                       0.15  0.20  0.24  0.28  0.31 \
                       0.35  0.44  0.50  0.54  0.58 \
                       0.59  0.61  0.66  0.75  0.82 \
                       0.89  0.97  1.04  1.20  1.45 \
                       1.67  1.84  2.06  2.24  2.43 \
                       ]

      set ::bdi_tools_cdl::table_sptype(VJ) [list \
                      -0.80 -0.77 -0.73 -0.70 -0.67 \
                      -0.64 -0.60 -0.58 -0.56 -0.54 \
                      -0.51 -0.46 -0.41 -0.39 -0.36 \
                      -0.31 -0.26 -0.22 -0.16 -0.11 \
                      -0.07 -0.02  0.03  0.09  0.13 \
                       0.18  0.25  0.31  0.37  0.43 \
                       0.48  0.67  0.79  0.87  0.97 \
                       0.98  1.02  1.14  1.34  1.46 \
                       1.60  1.73  1.84  2.04  2.30 \
                       2.49  2.61  2.74  2.84  2.93 \
                       ]

      set ::bdi_tools_cdl::table_sptype(VH) [list \
                      -0.92 -0.89 -0.85 -0.82 -0.79 \
                      -0.76 -0.72 -0.70 -0.68 -0.65 \
                      -0.62 -0.57 -0.51 -0.48 -0.45 \
                      -0.40 -0.34 -0.29 -0.19 -0.12 \
                      -0.04  0.03  0.11  0.19  0.30 \
                       0.32  0.42  0.49  0.57  0.64 \
                       0.71  0.93  1.06  1.15  1.25 \
                       1.27  1.31  1.44  1.67  1.80 \
                       1.94  2.09  2.22  2.46  2.78 \
                       3.04  3.22  3.42  3.58  3.74 \
                       ]

      set ::bdi_tools_cdl::table_sptype(VK) [list \
                      -0.97 -0.95 -0.93 -0.91 -0.89 \
                      -0.86 -0.82 -0.80 -0.77 -0.74 \
                      -0.71 -0.64 -0.57 -0.54 -0.49 \
                      -0.43 -0.33 -0.26 -0.17 -0.11 \
                      -0.05  0.01  0.08  0.15  0.21 \
                       0.27  0.36  0.44  0.52  0.58 \
                       0.66  0.89  1.03  1.14  1.26 \
                       1.28  1.32  1.47  1.74  1.89 \
                       2.06  2.23  2.38  2.66  3.01 \
                       3.29  3.47  3.67  3.83  3.98 \
                       ] 

      set ::bdi_tools_cdl::table_sptype(VL) [list \
                      -1.13 -1.11 -1.08 -1.05 -1.02 \
                      -0.97 -0.92 -0.90 -0.86 -0.83 \
                      -0.78 -0.70 -0.61 -0.57 -0.52 \
                      -0.43 -0.34 -0.27 -0.18 -0.12 \
                      -0.07 -0.01  0.05  0.12  0.17 \
                       0.23  0.33  0.41  0.49  0.57 \
                       0.66  0.90  1.06  1.18  1.31 \
                       1.33  1.38  1.55  1.85  2.02 \
                       2.21  2.40  2.57  2.87  3.25 \
                       3.54  3.72  3.92  4.08  4.22 \
                       ]

      set ::bdi_tools_cdl::table_sptype(VM) [list \
                      -1.00 -0.99 -0.96 -0.94 -0.92 \
                      -0.88 -0.84 -0.82 -0.79 -0.76 \
                      -0.73 -0.65 -0.58 -0.54 -0.49 \
                      -0.42 -0.34 -0.26 -0.18 -0.13 \
                      -0.08 -0.02 -0.04  0.10  0.15 \
                       0.20  0.29  0.36  0.43  0.49 \
                       0.56  0.77  0.91  1.01  1.12 \
                       1.14  1.18  1.34  1.61  1.78 \
                       1.97  2.17  2.36  2.71  3.21 \
                       3.65  3.95  4.31  4.62  4.93 \
                       ]

      set ::bdi_tools_cdl::table_sptype(VN) [list \
                      -9.99 -9.99 -9.99 -9.99 -9.99 \
                      -0.96 -0.91 -0.87 -0.84 -0.80 \
                      -0.75 -0.66 -0.58 -0.53 -0.48 \
                      -0.39 -0.30 -0.22 -0.14 -0.08 \
                      -0.02  0.03  0.09  0.16  0.21 \
                       0.26  0.34  0.41  0.48  0.54 \
                       0.60  0.80  0.91  1.01  1.11 \
                       1.13  1.17  1.30  1.54  1.68 \
                       1.84  2.01  2.15  2.44  2.83 \
                       3.16  3.39  3.66  3.89  4.11 \
                       ]

      set ::bdi_tools_cdl::table_sptype(sptype) [list \
                       B0.0 B0.5 B1.0 B1.5 B2.0 \
                       B2.5 B3.0 B3.5 B4.0 B4.5 \
                       B5.0 B6.0 B7.0 B7.5 B8.0 \
                       B8.5 B9.0 B9.5 A0.0 A1.0 \
                       A2.0 A3.0 A4.0 A5.0 A6.0 \
                       A7.0 A8.0 A9.0 F0.0 F1.0 \
                       F2.0 F5.0 F8.0 G0.0 G2.0 \
                       G3.0 G5.0 G8.0 K0.0 K1.0 \
                       K2.0 K3.0 K4.0 K5.0 K7.0 \
                       M0.0 M1.0 M2.0 M3.0 M4.0 \
                       ]

    }    
    
    





