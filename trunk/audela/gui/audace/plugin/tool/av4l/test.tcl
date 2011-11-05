# source audace/plugin/tool/bddimages/test.tcl
#
# Fichier        : test.tcl
# Description    : Test de fonctionnement de procedures
# Auteur         : Fr√©d√©ric Vachier
# Mise √† jour $Id: test.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval testprocedure {

   global audace
   global bddconf
   global conf
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""

   if { [ package require dom ] == "2.6" } {
      interp alias {} ::dom::parse {} ::dom::tcl::parse
      interp alias {} ::dom::selectNode {} ::dom::tcl::selectNode
      interp alias {} ::dom::node {} ::dom::tcl::node
   }


   proc run {  } {

      test1
   }






proc test1 { } {

   global conf

 ::console::affiche_resultat "---------------------------\n"
 ::console::affiche_resultat " Test n∞ 1\n"
 ::console::affiche_resultat "---------------------------\n"


}






proc test2 { } {

global audace


 ::console::affiche_resultat "---------------------------\n"
 ::console::affiche_resultat " Test n∞ 2\n"
 ::console::affiche_resultat "---------------------------\n"


}

}
# fin du namespace

