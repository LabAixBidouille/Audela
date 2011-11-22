# source audace/plugin/tool/bddimages/test.tcl
#
# Fichier        : test.tcl
# Description    : Test de fonctionnement de procedures
# Auteur         : Frédéric Vachier
# Mise à jour $Id: test.tcl 6795 2011-02-26 16:05:27Z michelpujol $
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

   global conf audace

 ::console::affiche_resultat "---------------------------\n"
 ::console::affiche_resultat " Test n� 1\n"
 ::console::affiche_resultat "---------------------------\n"
::av4l_tools::avi_next_image  

 set rect [ ::confVisu::getBox 1 ]
 ::console::affiche_resultat "rect $rect\n"

 if { [info exists $rect] } {
    return
 }
 #set rect { [lindex $rect 0] [lindex $rect 1] [lindex $rect 2] [lindex $rect 3] }

 ::console::affiche_resultat "visu \n"

 buf1 window $rect
 buf1 mirrory
# buf1 save ocr.png
set stat  [buf1 stat]
 ::console::affiche_resultat "stat = $stat \n"

buf1 savejpeg ocr.jpg 100 [lindex $stat 3] [lindex $stat 0] 

set err [ catch {set result [exec jpegtopnm ocr.jpg | gocr -C 0-9 -f UTF8 ]} msg ]

 ::console::affiche_resultat "err = $err \n"
 ::console::affiche_resultat "msg = $msg \n"




}






proc test2 { } {

global audace


 ::console::affiche_resultat "---------------------------\n"
 ::console::affiche_resultat " Test n� 2\n"
 ::console::affiche_resultat "---------------------------\n"


}

}
# fin du namespace

