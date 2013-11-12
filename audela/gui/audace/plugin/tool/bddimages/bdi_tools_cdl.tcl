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

   variable fen      ; # Variable definissant la racine de la fenetre de l'outil
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
      }    
         
      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      gren_info "Chargement complet en $tt sec \n"

      return

   }

   proc ::bdi_tools_cdl::charge_cata_list { } {

   }
