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

      ::confVisu::addZoomListener $::audace(visuNo) "efface_rond"
      ::confVisu::addMirrorListener $::audace(visuNo) "efface_rond"
      ::confVisu::addFileNameListener $::audace(visuNo) "efface_rond"

      ::console::affiche_resultat "astroid head     = [lindex $::bddimages_analyse::current_cata 0] \n"

      # Affichage centre champ de l image
      set centre [list {"CENTRE" {} {} } [list [list [list "CENTRE" [list $::bddimages_analyse::current_image(ra) $::bddimages_analyse::current_image(dec)] {}]]]]
      ::bddimages_astroid::affich_rond $centre "CENTRE" "red" 7
      ::console::affiche_resultat "ROND ROUGE: centre du champ provenant du header fits\n"

      # Recupere le catalog astrometrique
      #set astrometric_list [::bddimages_astroid::vo_cds_query "UCAC2" $::bddimages_analyse::current_image(ra) $::bddimages_analyse::current_image(dec) $::bddimages_analyse::current_image(radius)]
      set astrometric_list [get_astrometric_catalog $::bddimages_analyse::current_image(ra) $::bddimages_analyse::current_image(dec) $::bddimages_analyse::current_image(radius)]
       ::console::affiche_resultat "astroid astrometric_list =  $astrometric_list\n"
       ::console::affiche_resultat "astroid num_star_sources astrometric_list =  [llength $astrometric_list]\n"

      # Affichage le catalogue astrometrique
      affich_rond $astrometric_list "UCAC2" "blue" 2
      ::console::affiche_resultat "ROND BLEU: Etoiles astrometric 2\n"


   }





proc ::bddimages_astroid::get_astrometric_catalog { ra dec radius} {

   set astrometric_catalog UCAC2

   ::console::affiche_resultat "CDSQUERY=($ra, $dec, $radius, $astrometric_catalog)\n"
   # Appel du catalogue TYCHO
   # {
   #  {I/239/tyc_main {The Hipparcos and Tycho Catalogues (ESA 1997)}} 
   #  {TYC RAhms DEdms Vmag RA(ICRS) DE(ICRS) BTmag VTmag B-V} 
   #  {{{ 170  2854 1} {07 00 48.04} {+03 54 53.5} 9.58 105.20017797 3.91485967 11.429 9.740 1.410}
   #   {{ 170  2509 1} {07 01 05.79} {+03 54 17.6} 9.60 105.27411183 3.90488073 11.004 9.718 1.092}
   #   {{ 170  2476 1} {07 01 07.94} {+03 52 20.2} 10.29 105.28309416 3.87228981 11.588 10.402 1.013}
   #  }I/259/tyc2 I/297/out
   # }
   # 2eme forme
   # {
   # {TYC1 TYC2 TYC3 pmRA pmDE BTmag VTmag HIP RA(ICRS) DE(ICRS)} 
   # {
   #  {170 2854 1 1.8 -0.7 11.432 9.716 {} 105.20018639 3.91485778} 
   #  {170 2607 1 -4.0 1.1 11.358 10.992 {} 105.25741056 3.99244917}}}


   set star_list [::bddimages_astroid::vo_cds_query $astrometric_catalog $ra $dec $radius]
   #set star_list [vo_vizier_query $ra $dec $radius arcmin I/289/out]

   ::console::affiche_resultat "set starlist {$star_list}\n"

   set tmp [lindex $star_list 0]
   set allfields [lindex $tmp 0]

   set cmfields  [list ra dec poserr mag magerr]
   set list_fields [list [list "UCAC2" $cmfields $allfields] ]

   ::console::affiche_resultat "$list_fields\n"
   
   set list_sources {}
   set tmp [lindex $tmp 1]
   foreach star $tmp {
       ::console::affiche_resultat "star=$star\n"
       #set cmval [list [expr [ mc_angle2deg [lindex $star 1]]*15] [expr [ mc_angle2deg [lindex $star 2]]*1.] .2 [lindex $star 3] 0.2 ]
       set cmval [list [lindex $star 8] [lindex $star 9] .2 [lindex $star 6] 0.2 ]
       #::console::affiche_resultat "cmval=$cmval\n"
       lappend list_sources [list [list "UCAC2" $cmval $star ] ] 
       continue
       }

   #::console::affiche_resultat "TYCHO2: [list $list_fields $list_sources]\n"

   return [list $list_fields $list_sources]
   }


#
# catalog : I/289/out for UCAC2
# catalog : I/315/out for UCAC3
# catalog : I/239/hip_main for HIPPARCOS
# ra : 
# dec : signe obligatoire
# r : rayon
proc ::bddimages_astroid::vo_cds_query { catalogname ra dec r } {

package require xml
package require dom
package require http

if {$catalogname == "UCAC3"}  then { set catalog "I/315/out" }
if {$catalogname == "UCAC2"}  then { set catalog "I/289/out" }
if {$catalogname == "UCAC2A"} then { set catalog "I/294A/ucac2bss" }
if {$catalogname == "HIP"}    then { set catalog "I/239/hip_main" }
if {$catalogname == "2MASS"}  then { set catalog "II/246/out" }
if {$catalogname == "TYCHO"}  then { set catalog "I/239/tyc_main" }


#http://vizier.u-strasbg.fr/viz-bin/votable?-out.max=10000&-c=0+%2B0&-c.eq=J2000&-oc.form=dec&-c.r=+10&-c.u=arcmin&-c.geom=r&-source=I%2F289%2Fout&-out.all=1

set url "http://vizier.u-strasbg.fr/viz-bin/votable"
set catalog [::http::formatQuery $catalog ]
set ra [::http::formatQuery $ra]
set dec [::http::formatQuery $dec]
set r [::http::formatQuery $r]
set query "-out.max=10000&-c=$ra+$dec&-c.eq=J2000&-oc.form=dec&-c.r=+$r&-c.u=arcmin&-c.geom=r&-source=$catalog%2Fout&-out.all=1"

#gren_info " query = $url?$query"

set token [ ::http::geturl $url -query $query ]
set votable [::dom::parse [::http::data $token]]
set fields {}
foreach n [::dom::selectNode $votable {descendant::FIELD/attribute::name}] {
   lappend fields "[::dom::node stringValue $n]"
   }

#set idmagbmv [lsearch $fields "B-V"]

set rows {}
foreach tr [::dom::selectNode $votable {descendant::TR}] {
   set row {}
   foreach td [::dom::selectNode $tr {descendant::TD/text()}] {
      lappend row [::dom::node stringValue $td]
      }
#      set magbnv [lindex $row $idmagbmv]
#   if {$magbnv > 0.5 && $magbnv < 0.9}  then {
#      gren_info " B-V = [lindex $row $idmagbmv]"
      lappend rows [list [list $catalogname $fields $row] ]
#      }
#   lappend rows [list $catalogname $fields $row]
   }

return $rows
}





proc ::bddimages_astroid::extract_sun_star { starlist } {


set commonfields [list ra dec poserr mag magerr]
set rows {}
foreach star $starlist {
   set insert "no"
   foreach cata $star {
      set fields   [lindex $cata 1]
      set idmagbmv [lsearch $fields "B-V"]
      set magbnv   [lindex [lindex $cata 2] $idmagbmv]
      if {$magbnv > 0.5 && $magbnv < 0.9}  then {
         #gren_info " B-V = $magbnv"         
         set insert "yes"
         set ra      [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "RAhms"] ]
         set ra      [mc_angle2deg $ra]
         set ra      [expr $ra * 15.0]
         set dec     [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "DEdms"] ]
         set dec     [mc_angle2deg $dec]
         set e_RAdeg [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "e_RAdeg"] ]
         set e_DEdeg [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "e_DEdeg"] ]
         set mag     [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "Vmag"] ]
         set magerr  0.3
         #gren_info " field = [lindex $cata 1] "
         #gren_info " value = [lindex $cata 2] "
         #gren_info " tag =$ra $dec $e_RAdeg $e_DEdeg $mag $magerr"
         set poserr  0.3
         #gren_info " tag =$ra $dec $poserr $mag $magerr"
         }
      }
   if {$insert == "yes"} {
      lappend star [list "common" $commonfields [list $ra $dec $poserr $mag $magerr] ]
      lappend rows $star 
      }
   }
#gren_info "rows = $rows"
return $rows
}








proc ::bddimages_astroid::affich_image { fitsfile } {
   global bddconf
   global audace
   set bufno $::bddconf(bufno)
   set errnum [catch {buf$bufno load $fitsfile} msg ]
   set nbvisu [::visu::create $bufno 1]
   #visu$nbvisu zoom 0.5
   #visu$nbvisu clear
   #visu$nbvisu disp
   #$audace(hCanvas) delete cadres
   }



proc ::bddimages_astroid::affich_rond { listsources catalog color width } {
   
   ::console::affiche_resultat "AFFICH_CATALOG=($catalog, $color, $width) NB=[llength [lindex $listsources 1]]\n"
      
   set fields  [lindex $listsources 0]
   set sources [lindex $listsources 1]
   foreach s $sources { 
      #gren_info "s =  $s \n"
      foreach cata $s {
         #gren_info "cata =  $cata \n"
         if { [lindex $cata 0]==$catalog } {
            set cm [lindex $cata 1]
            #gren_info "cm =  $cm \n"
            affich_un_rond [lindex $cm 0] [lindex $cm 1] $color $width
            }
         }
      }
   }


proc ::bddimages_astroid::affich_un_rond { ra dec color width } {

   global audace
   global bddconf
   set bufno $::bddconf(bufno)
        #gren_info "DD =  $ra $dec \n"
       # Affiche un rond vert
       set img_xy [ buf$bufno radec2xy [ list $ra $dec ] ]
       #--- Transformation des coordonnees image en coordonnees canvas
       set can_xy [ ::audace::picture2Canvas $img_xy ]
       set x [lindex $can_xy 0]
       set y [lindex $can_xy 1]
       # gren_info "XY =  $x $y \n"
       set radius 5           
       #--- Dessine l'objet selectionne en vert dans l'image
       $audace(hCanvas) create oval [ expr $x - $radius ] [ expr $y - $radius ] [ expr $x + $radius ] [ expr $y + $radius ] \
           -outline $color -tags cadres -width $width

   }


 proc ::bddimages_astroid::efface_rond { args } {
      global audace conf bddconf
 
         #--- Efface les reperes des objets
         $audace(hCanvas) delete cadres
      }


# Fin Classe
}

