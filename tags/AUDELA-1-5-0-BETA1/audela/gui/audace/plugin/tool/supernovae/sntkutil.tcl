#
# Fichier : sntkutil.tcl
# Description : Utilitaires pour la recherche de supernovae
# Auteur : Alain KLOTZ
# Mise a jour $Id: sntkutil.tcl,v 1.5 2006-09-01 22:42:01 robertdelmas Exp $
#

#
# Scrolled_Canvas
# Cree un canvas scrollable, ainsi que les deux scrollbars pour le deplacer
# Ref: Brent Welsh, Practical Programming in TCL/TK, rev.2, page 392
#
proc sn_Scrolled_Canvas { c yscroll args } {
   frame $c
   set grille { 0 1 0 0 1 1 }
   if { $yscroll == "right" } {
      set grille { 0 0 0 1 1 0 }
   }
   eval { canvas $c.canvas \
      -xscrollcommand [ list $c.xscroll set ] \
      -yscrollcommand [ list $c.yscroll set ] \
      } $args
   scrollbar $c.xscroll -orient horizontal -command [ list $c.canvas xview ]
   scrollbar $c.yscroll -orient vertical -command [ list $c.canvas yview ]
   grid $c.canvas  -column [ lindex $grille 1 ] -row [ lindex $grille 0 ] -sticky news
   grid $c.yscroll -column [ lindex $grille 3 ] -row [ lindex $grille 2 ] -sticky news
   grid $c.xscroll -column [ lindex $grille 5 ] -row [ lindex $grille 4 ] -sticky we
   grid rowconfigure $c 0 -weight 1
   grid columnconfigure $c 0 -weight 1
   return $c.canvas
}

#
# Transforme des coordonnees ecran en coordonnees canvas. L'argument est une liste de
# deux entiers, et retourne également une liste de deux entiers. Pour l'image de gauche
#
proc sn_screen2Canvas_g { coord } {
   global zone

   set x [ $zone(image1) canvasx [ lindex $coord 0 ] ]
   set y [ $zone(image1) canvasy [ lindex $coord 1 ] ]
   return [ list $x $y ]
}

#
# Transforme des coordonnees ecran en coordonnees canvas. L'argument est une liste de
# deux entiers, et retourne également une liste de deux entiers. Pour l'image de droite
#
proc sn_screen2Canvas_d { coord } {
   global zone

   set x [ $zone(image2) canvasx [ lindex $coord 0 ] ]
   set y [ $zone(image2) canvasy [ lindex $coord 1 ] ]
   return [ list $x $y ]
}

#
# Transforme des coordonnees canvas en coordonnees image. L'argument est une liste de
# deux entiers, et retourne également une liste de deux entiers. Pour l'image de gauche
#
proc sn_canvas2Picture_g { coord } {
   global zone

   set xx [ expr [ lindex $coord 0 ] + 1 ]
   set point [ string first . $xx ]
   if { $point != "-1" } {
      set xx [ string range $xx 0 [ incr point -1 ] ]
   }
   set yy 0
   catch {
      set yy [ expr $zone(naxis2) - [ lindex $coord 1 ] ]
   }
   set point [ string first . $yy ]
   if { $point != "-1" } {
      set yy [ string range $yy 0 [ incr point -1 ] ]
   }
   return [ list $xx $yy ]
}

#
# Transforme des coordonnees canvas en coordonnees image. L'argument est une liste de
# deux entiers, et retourne également une liste de deux entiers. Pour l'image de droite
#
proc sn_canvas2Picture_d { coord } {
   global zone

   set xx [ expr [ lindex $coord 0 ] + 1 ]
   set point [ string first . $xx ]
   if { $point != "-1" } {
      set xx [ string range $xx 0 [ incr point -1 ] ]
   }
   set yy 0
   catch {
      set yy [ expr $zone(naxis2_2) - [ lindex $coord 1 ] ]
   }
   set point [ string first . $yy ]
   if { $point != "-1" } {
      set yy [ string range $yy 0 [ incr point -1 ] ]
   }
   return [ list $xx $yy ]
}

#
# Lancement de la recherche du fichier image au format .cpa sur le DVD
#
proc Recherche_Fichier_DVD { filename3 } {
   global snconfvisu

   if { ( $snconfvisu(rep_dss_dvd) != "" ) && ( $filename3 != "" ) } {
      #--- Recherche du fichier image
      set repertoire [ ::audace::fichier_partPresent "$filename3" "$snconfvisu(rep_dss_dvd)" ]
      set repertoire [ glob -nocomplain -type f -dir "$repertoire" "$filename3" ]
      set repertoire [ string trimleft $repertoire "{" ]
      set repertoire [ string trimright $repertoire "}" ]
      if { $repertoire != "." } {
         set snconfvisu(binarypath) $repertoire
      } else {
         set snconfvisu(binarypath) ""
      }
   }
   return
}

#
# Affichage d'image au format .cpa du DVD
#
proc snvisu_loadima_nofits { { fichier } { rep } } {
   global audace
   global caption
   global conf
   global num

   set rep_tmp [cree_sousrep]
   file copy [ file join $rep $fichier ] [ file join $rep_tmp $fichier ]
   bifsconv_full [ file join $rep_tmp $fichier ]
   set fichierfits [ file join $rep_tmp [ file rootname $fichier ].fit ]
   #--- Chargement du fichier
   buf$num(buffer2) load $fichierfits
   #--- Visualisation automatique
   visu$num(visu_2) disp
   #--- Suppression du fichier copié
   file delete [ file join $rep_tmp $fichier ]
   #--- Suppression du fichier FITS temporaire
   file delete $fichierfits
   #--- Suppression du répertoire temporaire
   file delete $rep_tmp
}

