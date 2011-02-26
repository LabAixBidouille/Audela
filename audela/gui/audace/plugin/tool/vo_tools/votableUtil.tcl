#
# Fichier : votableUtil.tcl
# Description : Outil de manipulation des VOTable (http://www.ivoa.net/Documents/latest/VOT.html)
#
# Sequence de test:
#    source /usr/local/src/audela/gui/audace/plugin/tool/vo_tools/votableUtil.tcl
#    loadima "/surfer/Observations/telescopes/Tarot/IM_20091127_044139448_230749_59096501.fits.gz"
#    ::votableUtil::loadVotable "/surfer/Observations/telescopes/Tarot/IM_20091127_044139448_230749_59096501_fov2.xml"
#    ::votableUtil::displayVotable [::votableUtil::votable2list]
#
# Auteur : Jerome BERTHIER
# Mise à jour $Id$
#

namespace eval ::votableUtil {
   package provide votableUtil 1.0
   package require votable 1.0
   #--- Compatibilite ascendante
   if { [ package require dom ] == "2.6" } {
      interp alias {} ::dom::parse {} ::dom::tcl::parse
      interp alias {} ::dom::selectNode {} ::dom::tcl::selectNode
      interp alias {} ::dom::node {} ::dom::tcl::node
   }

   # Internationalisation
   source [ file join [file dirname [info script]] votableUtil.cap ]

   # #############################################################################
   #
   # Implementation des attributs de l'espace de nom votable
   #
   # #############################################################################

   #
   # @var string VOTable prete a etre manipulee / affichee / ...
   variable votBuf

   #
   # @var array tableau contenant la liste des objets celestes charges depuis la VOTable et affiches dans la visu
   variable astroObject

   #
   # @brief Conversion d'un nombre sexagesimal en un nombre decimal
   # @param[in] dms valeur sexagesimale a convertir
   # @return valeur decimal
   proc sexa2dec {dms} {
      set d [expr double([lindex $dms 0])]

      if {[string length [string map {0 ""} [lindex $dms 1]]] < 1} {
         set m 0
      } else {
         if {[string first 0 [lindex $dms 1]] == 0} {
            set m [expr double([string map {0 ""} [lindex $dms 1]])]
         } else {
            set m [expr double([lindex $dms 1])]
         }
      }
      set s [expr double([lindex $dms 2])]
      return [expr $d + $m/60.0 + $s/3600]
   }

}

# #############################################################################
#
# Implementation des methodes de l'espace de nom votableUtil
#
# #############################################################################

#
# Charge en memoire (::votableUtil::votBuf) une VOTable a partir d'un fichier
# @param filename string nom d'un fichier XML contenant une VOTable
# @param visuNo integer numero de la visu
# @return true si le chargement est ok, false sinon
#
# Chargement de la VOTable:
#   Si filename == "" ou "?" alors la VOTable est chargee a partir d'un fichier selectionne via une fenetre de selection
#   Si filename == <string> alors la VOTable est chargee a partir du fichier fourni.
#   Si le nom du fichier est relatif alors le fichier est recherche dans le repertoire audace(rep_image)
#
proc ::votableUtil::loadVotable { { filename "?" } { visuNo 1 } } {
   global audace visu conf

   # Recupere le buffer de la visu donnee (1 par defaut)
   set bufNo [ visu$visuNo buf ]
   # Recupere de l'extension par defaut
   buf$bufNo extension ".xml"
   # Recupere de l'information de compression ou non
   if { $conf(fichier,compres) == "1" } {
      buf$bufNo compress gzip
   } else {
      buf$bufNo compress none
   }
   # Charge la VOTable dans ::votableUtil::votBuf
   if { [string length $filename] < 1 || $filename == "?" } {
      #--- Fenetre parent
      set fenetre [::confVisu::getBase $visuNo]
      #--- Ouvre la fenetre de choix d'une VOTable
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $bufNo "10" $visuNo ]
   } else {
      if {[file pathtype $filename] == "relative"} {
         set filename [file join $audace(rep_images) $filename]
      }
   }
   if { [file exists $filename] } {
      # Lecture du fichier d'entree
      set fl [open $filename]
      ::votableUtil::setVotable $filename [read $fl]
      close $fl
      return 1
   }
   return 0
}

#
# Affecte en memoire (::votableUtil::votBuf) le nom du fichier et le contenu d'une VOTable
# @param xml string une VOTable
# @return void
#
proc ::votableUtil::setVotable { filename xml } {
   set ::votableUtil::votBuf(file) $filename
   set ::votableUtil::votBuf(xml) $xml
}

#
# Retourne le contenu du buffer de VOTable
# @return string une VOTable sous la forme d'une chaine de caractere
proc ::votableUtil::getVotable {} {
   return $::votableUtil::votBuf(xml)
}

#
# Retourne le nom du fichier contenant la VOTable chargee dans le buffer
# @return string le nom du fichier contenant la VOTable
proc ::votableUtil::getVotableFilename {} {
   return $::votableUtil::votBuf(file)
}

#
# Efface le buffer de VOTable
# @return void
proc ::votableUtil::clearVotable {} {
   unset $::votableUtil::votBuf
   set votBuf(file) "?"
   set votBut(xml) ""
}

#
# Efface les objets affiches dans l'image courante a partir de la VOTable
# @return void
proc ::votableUtil::clearDisplay { } {
   global audace
   $audace(hCanvas) delete astrobj
}

#
# Transforme un fichier CATA en une liste au format AstroId
# @param catafile string le chemin et nom d'un fichier CATA
# @return list liste au format AstroId
#
#{
# {
#  { IMG   {list field crossmatch} {list fields}}
#  { TYC2  {list field crossmatch} {list fields}}
#  { USNO2 {list field crossmatch} {list fields}}
# }
# {                                -> liste des sources
#  {                               -> 1 source
#   { IMG   {crossmatch} {fields}}  -> vue dans l image
#   { TYC2  {crossmatch} {fields}}  -> vue dans le catalogue
#   { USNO2 {crossmatch} {fields}}  -> vue dans le catalogue
#  }
# }
#}
#
# TODO
#
proc ::votableUtil::cata2astroid { catafile } {
   # Initialisations
   set linerech "123456789 123456789 123456789 123456789"
   set comfields [list ra dec poserr mag magerr]
   set allfields [list id flag xpos ypos instr_mag err_mag flux_sex \
                        err_flux_sex ra dec calib_mag calib_mag_ss1 err_calib_mag_ss1 \
                        calib_mag_ss2 err_calib_mag_ss2 nb_neighbours radius background_sex \
                        x2_momentum_sex y2_momentum_sex xy_momentum_sex major_axis_sex \
                        minor_axis_sex position_angle_sex fwhm_sex flag_sex]
   set list_fields [list [list "IMG" $comfields $allfields] [list "OVNI" $comfields {}] [list "USNO2" $comfields {}]]

   # TODO si fichier cata zippe alors dezip !

   # Ouvre le fichier cata
   if {[catch {set chan [open $catafile r]} err]} {
      ::console::affiche_erreur "::votableUtil::cata2votable: error <$err>, cannot open CATA file ($catafile)"
   }
   # Parse le fichier cata
   set list_sources {}
   set lineCount 0
   set littab "no"
   while {[gets $chan line] >= 0} {
      if {$littab=="ok"} {
         incr lineCount
         set zlist [split $line " "]
         set xlist {}
         foreach value $zlist {
            if {$value != {}} {
               set xlist [linsert $xlist end $value]
            }
         }
         set row {}
         set cmval [list [lindex $xlist 8] [lindex $xlist 9] 5.0 [lindex $xlist 10] [lindex $xlist 12]]
         if {[lindex $xlist 1] == 1} {
            lappend row [list "IMG" $cmval $xlist]
            lappend row [list "OVNI" $cmval {}]
         }
         if {[lindex $xlist 1] == 3} {
            lappend row [list "IMG" $cmval $xlist]
            lappend row [list "USNOA2" $cmval {}]
         }
         if {[llength $row] > 0} {
            lappend list_sources $row
         }
      } else {
         set a [string first $linerech $line 0]
         if {$a >= 0} { set littab "ok" }
      }
   }
   # Ferme le fichier cata
   if {[catch {close $chan} err]} {
       ::console::affiche_erreur "::votableUtil::cata2votable: error <$err>, cannot close CATA file"
   }

   # Retourne le cata sous forme d'une liste astroId
   return [list $list_fields $list_sources]
}

#
# Transforme une liste au format AstroId en VOTable
# @param list liste au format AstroId
# @return string une VOTable
#
# TODO
#
proc ::votableUtil::astroid2votable { astroIdList } {
   set votable ""
   return $votable
}

#
# Charge les objets (astronomiques) contenus dans la VOTable chargee en memoire (::votableUtil::votBuf)
# dans une liste contenant toutes les informations fournies par la VOTable sous la forme :
#   {resource { {tableName tableDesc} {fieldName} {fieldUCD} {{row_1} {row_2} {row_3} {...}} } {table_suivante} {...} }
# Les objets astronomiques sont definis par leurs coordonnees sur la sphere celeste fournies
# par les champs de la VOTable ayant pour UCD 'pos.eq.ra;meta.main' et 'pos.eq.dec;meta.main'.
#
# Exemple:
#   { I/239 {The Hipparcos and Tycho Catalogues (ESA 1997)} }
#   {
#     { I/239/hip_main {The Hipparcos Main Catalogue\vizContent{timeSerie}} }
#     { HIP RAhms DEdms Vmag RA(ICRS) DE(ICRS) Plx pmRA pmDE e_Plx B-V Notes }
#     { {meta.id;meta.main} {pos.eq.ra;meta.main} {pos.eq.dec;meta.main} {phot.mag;em.opt.V} pos.eq.ra pos.eq.dec pos.parallax.trig {pos.pm;pos.eq.ra} {pos.pm;pos.eq.dec} stat.error {phot.color;em.opt.B;em.opt.V} meta.note }
#     { 1 2 }
#     {
#      {33545 {06 58 17.52} {+03 53 44.9} 7.05 104.57301302 3.89580223 3.08 -0.22 -4.59 0.96 1.340 { }}
#      {33603 {06 58 57.03} {+03 36 08.5} 5.96 104.73761182 3.60236429 3.52 -3.59 -3.65 0.87 1.056 { }}
#      {33689 {06 59 57.23} {+04 04 59.7} 7.79 104.98845210 4.08324024 3.55 40.84 -42.40 1.04 1.079 { }}
#      ...
#     }
#   }
#   {
#     {I/239/tyc_main {The main part of Tycho Catalogue\vizContent{timeSerie}}}
#     {TYC RAhms DEdms Vmag RA(ICRS) DE(ICRS) BTmag VTmag B-V}
#     { {meta.id;meta.main} {pos.eq.ra;meta.main} {pos.eq.dec;meta.main} {phot.mag;em.opt.V} pos.eq.ra pos.eq.dec {phot.mag;em.opt.B} {phot.mag;em.opt.V} {phot.color;em.opt.B;em.opt.V} }
#     { 1 2 }
#     {
#      {{ 157  1054 1} {06 58 07.82} {+03 53 38.8} 10.27 104.53257884 3.89410933 10.712 10.310 0.376}
#      {{ 157  2266 1} {06 58 17.52} {+03 53 44.9} 7.02 104.57301266 3.89580356 8.769 7.170 1.340}
#      {{ 157   900 1} {06 58 40.50} {+04 14 53.1} 10.35 104.66873787 4.24807664 10.913 10.405 0.477}
#      ...
#     }
#   }
#
# Test:
#  ::votableUtil::loadVotable "/surfer/Observations/telescopes/Tarot/IM_20091127_044139448_230749_59096501_fov.xml"
#  ::votableUtil::votable2list
#
# @return false si aucune VOTable n'est chargee en menoire, sinon retourne le contenu de la VOTable sous la forme d'une liste
#
proc ::votableUtil::votable2list { } {
   # Initialisations
   set resource {}
   set tableInfo {}
   array set fields {}

   # Recupere la VOTable chargee en memoire
   set err [catch {::votableUtil::getVotable} xml]
   # Retourne false si erreur ou si la chaine est vide
   if { $err == 0 && [string length $xml] < 1} {
      return 0
   }

   # Parse la votable
   set votable [::dom::parse $xml]

   #-- Recupere le nom du catalogue -> resource/attribut::name et resource/description
   set resourceName [::dom::node stringValue [::dom::selectNode $votable {descendant::RESOURCE/attribute::name}]]
   set resourceDesc [::dom::node stringValue [::dom::selectNode $votable {descendant::RESOURCE/DESCRIPTION/text()}]]
   lappend resource [list $resourceName $resourceDesc]

   #-- Lecture des tables contenues dans la VOTable
   set idx 0
   foreach table [::dom::selectNode $votable {descendant::TABLE}] {
      #-- Initialisations
      set name {}
      set ucd {}
      set datatype {}
      set rows {}
      #-- Recupere le nom et la description de la table
      set err [ catch {::dom::node stringValue [::dom::selectNode $table {attribute::name}]} tableName]
      if { $err != "0" } { set tableName "?" }
      set err [ catch { ::dom::node stringValue [::dom::selectNode $table {DESCRIPTION/text()}] } tableDesc ]
      if { $err != "0" } { set tableDesc "?" }
      set tableInfo [list $tableName $tableDesc]
      #-- Recupere les noms des champs
      foreach n [::dom::selectNode $table {FIELD/attribute::name}] {
         lappend name "[::dom::node stringValue $n]"
      }
      set fields(name) $name
      #-- Recupere les UCDs des champs
      set indexRA -1
      set indexDE -1
      set cpt 0
      foreach n [::dom::selectNode $table {FIELD/attribute::ucd}] {
         set node [::dom::node stringValue $n]
         lappend ucd $node
         # determine l'index de RA
         set comp [string equal -nocase $node "pos.eq.ra;meta.main"]
         if {$comp == 1} { set indexRA $cpt }
         set comp [string equal -nocase $node "pos.eq.ra"]
         if {$comp == 1 && $indexRA < 0} { set indexRA $cpt }
         # determine l'index de DEC
         set comp [string equal -nocase $node "pos.eq.dec;meta.main"]
         if {$comp == 1} { set indexDE $cpt }
         set comp [string equal -nocase $node "pos.eq.dec"]
         if {$comp == 1 && $indexDE < 0} { set indexDE $cpt }
         # incremente le compteur
         incr cpt
      }
      set fields(ucd) $ucd
      set fields(index) [list $indexRA $indexDE]
      #-- Recupere les datatype des champs
      set datatypeRA ""
      set datatypeDE ""
      foreach n [::dom::selectNode $table {FIELD/attribute::datatype}] {
         set node [::dom::node stringValue $n]
         lappend datatype $node
      }
      set fields(datatype) $datatype
      #-- Recupere les lignes de la table courante
      set idx 0
      foreach tr [::dom::selectNode $table {descendant::TR}] {
         set row {}
         foreach td [::dom::selectNode $tr {descendant::TD/text()}] {
            set node [::dom::node stringValue $td]
            lappend row $node
            #
         }
         lappend rows $row
      }
      #-- Sauve la table courante
      lappend resource [list $tableInfo $fields(name) $fields(ucd) $fields(datatype) $fields(index) $rows]
      #-- Incremente le compteur de table
      incr idx
   }

   # Retourne la VOTable sous forme de liste
   return $resource
}

#
# Affiche une liste d'objets astronomiques dans l'image de la vue visuNo
# @param votaCan list liste contenant les objets astronomiques fournie par ::votableUtil::votable2list
# @param visuNo integer numero de la visu
# @param mycolor string couleur d'affichage des objets astronomiques
# @param mytype string forme des objets affiches (e.g. oval | rectangle)
# @return false si une erreur s'est produite, sinon renvoie la liste des objets affiches sous la forme d'une liste {RA DEC color}
#
proc ::votableUtil::displayVotable { votCan { visuNo 1 } { mycolor "orange" } { mytype "oval" } } {
   global audace visu color caption

   # Verifie qu'un image est chargee dans la visu
   set image [::confVisu::getFileName $visuNo]
   if { [file exists $image] == 0 } {
      tk_messageBox -title "Error" -type ok -message $caption(votableUtil,no_image)
      return 0
   }

   # Recupere la valeur courante du zoom
   set zoom [visu$visuNo zoom]
   # Recupere les limites minmax de l'image dans le canvas
   set xmin 0
   set xmax [expr [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1] * $zoom]
   set ymin 0
   set ymax [expr [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1] * $zoom]

   # Recupere et transforme les coordonnees des objets a afficher
   set tables [lassign $votCan resource]
   set resourceName [lindex $resource 0]
   set resourceDesc [lindex $resource 1]

   set idx 0
   array set ::votableUtil::astroObject {}
   foreach table $tables {
      lassign $table tableInfo tableColName tableColUCD tableColDatatype tableIndex tableData
      set tableName [lindex $tableInfo 0]
      set tableDesc [lindex $tableInfo 1]
      set RAdt [lindex $tableColDatatype [lindex $tableIndex 0]]
      set DEdt [lindex $tableColDatatype [lindex $tableIndex 1]]

      foreach data $tableData {
         #--- Extraction RA et DEC
         set RAstr [lindex $data [lindex $tableIndex 0]]
         set DEstr [lindex $data [lindex $tableIndex 1]]
         if {$RAdt eq "char"} {
            set RA [expr [::votableUtil::sexa2dec [split $RAstr " "]] * 15.0]
         } else {
            set RA [expr double($RAstr)]
         }
         if {$DEdt eq "char"} {
            set DEC [::votableUtil::sexa2dec [split $DEstr " "]]
         } else {
            set DEC [expr double($DEstr)]
         }
         #--- Coordonnees images de l'objet
         set imgXY [buf$audace(bufNo) radec2xy [list $RA $DEC]]
         #--- Transformation des coordonnees image en coordonnees canvas
         set canXY [::audace::picture2Canvas $imgXY]
         #-- Ne trace l'objet que si ses coordonnnes font parties de l'image
         set x [lindex $canXY 0]
         set y [lindex $canXY 1]
         if { $x >= $xmin && $x <= $xmax && $y >= $ymin && $y <= $ymax } {
            # Sauvegarde le point affiche
            set ::votableUtil::astroObject($idx) [list $RA $DEC $mycolor]
            # Affiche le point dans le canvas
            $audace(hCanvas) create $mytype [expr $x - 6] [expr $y - 6] [expr $x + 6] [expr $y + 6] -outline $color($mycolor) -tags astrobj -width 1.0
            # incremente le compteur d'objets
            incr idx
         }
      }
   }
   # Nombre d'objets affiches
   set nbo [expr $idx - 1]
   ::console::affiche_resultat "$nbo $caption(votableUtil,nb_objets)"
   # Active la mise a jour automatique de l'affichage quand on change de zoom ou d'image
   ::confVisu::addZoomListener $visuNo "::votableUtil::refreshVisu"
   ::confVisu::addMirrorListener $visuNo "::votableUtil::refreshVisu"
   ::confVisu::addSubWindowListener $visuNo "::votableUtil::refreshVisu"
   ::confVisu::addFileNameListener $visuNo "::votableUtil::refreshVisu"

   # Retourne true
   return 1

}

#
# Raffraichi l'affiche des objets astronomiques dans l'image
# @param args valeur fournies par le gestionnaire de listener
# @return void
#
proc ::votableUtil::refreshVisu { args } {
   global audace color
   # Efface les objets du canvas
   ::votableUtil::clearDisplay
   # Recupere la valeur courante du zoom
   set zoom [visu$::audace(visuNo) zoom]
   # Calcul les limites minmax de l'image dans le canvas
                  set box [ ::confVisu::getBox 1 ]
                  set x1 [lindex  [confVisu::getBox 1 ] 0]
                  set y1 [lindex  [confVisu::getBox 1 ] 1]
                  set x2 [lindex  [confVisu::getBox 1 ] 2]
                  set y2 [lindex  [confVisu::getBox 1 ] 3]
                  puts "BOX = $box ($x1, $y1, $x2, $y2)"
   set xmin 0
   set xmax [expr [lindex [buf$audace(bufNo) getkwd NAXIS1] 1] * $zoom]
   set ymin 0
   set ymax [expr [lindex [buf$audace(bufNo) getkwd NAXIS2] 1] * $zoom]
   # Re-affiche les objets
   for {set i 0} {$i < [array size ::votableUtil::astroObject]} {incr i} {
      #--- Coordonnees celestes de l'objet
      set RA [lindex $::votableUtil::astroObject($i) 0]
      set DEC [lindex $::votableUtil::astroObject($i) 1]
      #--- Coordonnees images de l'objet
      if {[catch {buf$audace(bufNo) radec2xy [list $RA $DEC]} imgXY] == 0} {
         #--- Transformation des coordonnees image en coordonnees canvas
         set canXY [::audace::picture2Canvas $imgXY]
         #-- Coordonnees x,y de l'objet dans le canvas
         set x [lindex $canXY 0]
         set y [lindex $canXY 1]
         #--- Couleur d'affichage
         set mycolor [lindex $::votableUtil::astroObject($i) 2]
         #--- Affichage de l'objet
         if { $x >= $xmin && $x <= $xmax && $y >= $ymin && $y <= $ymax } {
            $audace(hCanvas) create oval [expr $x - 6] [expr $y - 6] [expr $x + 6] [expr $y + 6] -outline $color($mycolor) -tags astrobj -width 1.0
         }
      }
   }
}

#
# Raffraichi l'affiche des objets astronomiques dans l'image
# @param args valeur fournies par le gestionnaire de listener
# @return void
#
proc ::votableUtil::pointAtSky { RA DEC } {
   global audace color
   # Efface les objets du canvas
   ::votableUtil::clearDisplay
   ::votableUtil::refreshVisu
   # Recupere la valeur courante du zoom
   set zoom [visu$::audace(visuNo) zoom]
   # Calcul les limites minmax de l'image dans le canvas
   set xmin 0
   set xmax [expr [lindex [buf$audace(bufNo) getkwd NAXIS1] 1] * $zoom]
   set ymin 0
   set ymax [expr [lindex [buf$audace(bufNo) getkwd NAXIS2] 1] * $zoom]
   # Affiche le point de coordonnees
   #--- Coordonnees images de l'objet
   if {[catch {buf$audace(bufNo) radec2xy [list $RA $DEC]} imgXY] == 0} {
      #--- Transformation des coordonnees image en coordonnees canvas
      set canXY [::audace::picture2Canvas $imgXY]
      #-- Coordonnees x,y de l'objet dans le canvas
      set x [lindex $canXY 0]
      set y [lindex $canXY 1]
      #--- Affichage de l'objet
      if { $x >= $xmin && $x <= $xmax && $y >= $ymin && $y <= $ymax } {
         $audace(hCanvas) create line [expr $x - 9] $y [expr $x - 3] $y -fill $color(green) -tags astrobj -width 2.0
         $audace(hCanvas) create line [expr $x + 3] $y [expr $x + 9] $y -fill $color(green) -tags astrobj -width 2.0
         $audace(hCanvas) create line $x [expr $y - 9] $x [expr $y - 3] -fill $color(green) -tags astrobj -width 2.0
         $audace(hCanvas) create line $x [expr $y + 3] $x [expr $y + 9] -fill $color(green) -tags astrobj -width 2.0
      }
   }
}

