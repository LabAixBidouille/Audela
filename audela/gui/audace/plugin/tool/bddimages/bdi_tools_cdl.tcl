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

      array unset ::bdi_tools_cdl::table_noms  
      array unset ::bdi_tools_cdl::table_nbcata
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
               if {$mag!="" && [string is double $mag]} { lappend tab(mag) $mag }
               set flux [::bdi_tools_psf::get_val othf "flux"]
               if {$flux!="" && [string is double $flux]} { lappend tab(flux) $flux }
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
            if { $flux1=="" && $flux1<=0} { continue }

            foreach ids2 $::bdi_tools_cdl::list_of_stars {
               set name2 $::bdi_tools_cdl::id_to_name($ids2)
               if {![info exists ::bdi_tools_cdl::table_othf($name2,$idcata,othf)]} { continue }
               set othf $::bdi_tools_cdl::table_othf($name2,$idcata,othf)
               set flux2 [::bdi_tools_psf::get_val othf "flux"]
               if { $flux2=="" && $flux2<=0 } { continue }
               
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

      #::bdi_gui_cdl::affiche_starstar

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
