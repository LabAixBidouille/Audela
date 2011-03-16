#--------------------------------------------------
# source audace/plugin/tool/bddimages/bddimages_analyse.tcl
#--------------------------------------------------
#
# Fichier        : bddimages_astroid.tcl
# Description    : Environnement de recherche des images
#                  dans la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: bddimages_liste.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace bddimages_astroid
#
#--------------------------------------------------
#
#   -- Fichiers source externe :
#
#  bddimages_astroid.cap
#
#--------------------------------------------------

namespace eval bddimages_astroid {

   global audace
   global bddconf


   proc ::bddimages_astroid::run_astroid {  } {

      global bddconf

      ::console::affiche_resultat "head     = [lindex $::bddimages_analyse::current_cata 0] \n"


   }










# Fin Classe
}

