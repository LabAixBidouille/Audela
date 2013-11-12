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
}


   #----------------------------------------------------------------------------
   ## Chargement de la liste d'image selectionnee dans l'outil Recherche.
   #  \param img_list structure de liste d'images
   #  \note le resultat de cette procedure affecte la variable de
   # namespace  \c tools_cata::img_list puis charge toutes l'info des cata
   # associes aux images
   #----------------------------------------------------------------------------
   proc ::bdi_tools_cdl::charge_cata_xml { } {

      set tt0 [clock clicks -milliseconds]

      set id 0
      foreach ::tools_cata::current_image $::tools_cata::img_list {
         incr id
         ::gui_cata::load_cata
         set ::gui_cata::cata_list($id) $::tools_cata::current_listsources
         ::bdi_tools_cdl::set_progress $id $::tools_cata::nb_img_list
         ::bdi_tools_cdl::get_memory      
      }    
         
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Chargement complet en $tt sec \n"

      return

   }

   proc ::bdi_tools_cdl::charge_cata_list { } {

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

      set pid [exec pidof audela]
            
      set info [exec cat /proc/$pid/status ]
      
      set ::bdi_tools_cdl::memory(mempid) [format "%0.1f Mb" [expr \
                  [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]

      set info [exec cat /proc/meminfo ]

      set ::bdi_tools_cdl::memory(memtotal) [::bdi_tools_cdl::get_mem info "MemTotal:"]
      gren_info "memtotal = $::bdi_tools_cdl::memory(memtotal) \n"
      set ::bdi_tools_cdl::memory(memfree) [::bdi_tools_cdl::get_mem info "MemFree:"]
      gren_info "memfree = $::bdi_tools_cdl::memory(memfree) \n"
      set ::bdi_tools_cdl::memory(swaptotal) [::bdi_tools_cdl::get_mem info "SwapTotal:"]
      set ::bdi_tools_cdl::memory(swapfree) [::bdi_tools_cdl::get_mem info "SwapFree:"]
      set ::bdi_tools_cdl::memory(mem) [format "%0.1f" [expr 1.0*$::bdi_tools_cdl::memory(memfree)/$::bdi_tools_cdl::memory(memtotal)]]
      set ::bdi_tools_cdl::memory(swap) [format "%0.1f" [expr 1.0*$::bdi_tools_cdl::memory(swapfree)/$::bdi_tools_cdl::memory(swaptotal)]]

   }
