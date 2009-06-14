#
# Fichier : sectiongraph.tcl
# Description : Affiche une coupe de l'image
# Auteur : Michel PUJOL
# Mise a jour $Id: sectiongraph.tcl,v 1.12 2009-06-14 08:51:39 robertdelmas Exp $
#

namespace eval ::sectiongraph {
}

#------------------------------------------------------------
#  init
#     initialise le graphe
#
#------------------------------------------------------------
proc ::sectiongraph::init { visuNo } {
   variable private
   global conf

   if { [ buf[::confVisu::getBufNo $visuNo] imageready] == "0" } {
      return
   }

   #--- Initialisation de variables
   if { ! [ info exists conf(sectiongraph,position) ] }    { set conf(sectiongraph,position)    "+350+75" }
   if { ! [ info exists conf(sectiongraph,modeRefresh) ] } { set conf(sectiongraph,modeRefresh) "0" }

   #--- je verifie si la variable existe
   if { [info exists private($visuNo,This)] } {
      wm withdraw $private($visuNo,This)
      wm deiconify $private($visuNo,This)
      focus $private($visuNo,This)
      return
   }

   #--- j'initalise les variables de travail
   ::blt::vector create sectiongraphX$visuNo sectiongraphYR$visuNo sectiongraphYG$visuNo sectiongraphYB$visuNo
   ::polydraw::init $visuNo
   #--- j'interdis l'ajout d'item et de nodes avec la souris
   ::polydraw::setMouseAddItem $visuNo "0"
   ::polydraw::setMouseAddNode $visuNo "0"
   #--- je dessine la ligne de coupe au centre du canvas
   set canvasCenter [::confVisu::getCanvasCenter $visuNo ]
   set x1 [expr [lindex $canvasCenter 0 ] - 20 ]
   set x2 [expr [lindex $canvasCenter 0 ] + 20 ]
   set y [lindex $canvasCenter 1 ]
   set private($visuNo,itemNo) [::polydraw::createLine $visuNo [list $x1 $y $x2 $y ] ]
   #--- je cree la fenetre contenant le graphe
   ::sectiongraph::createToplevel $visuNo
}

#------------------------------------------------------------
#  confSectionGraph
#     rafraichit la fenetre
#  parametres
#     visuNo : numero de visu
#     args   : valeurs fournies par le gestionnaire de listener
#  return : null
#------------------------------------------------------------
proc ::sectiongraph::confSectionGraph { visuNo args } {
   variable private
   global conf

   #--- Configure le bouton pour le rafraichissement
   if { $conf(sectiongraph,modeRefresh) == "0" } {
      $private($visuNo,This).frame2.butRefresh configure -state normal
      #--- J'arrete le rafraichissement automatique
      ::confVisu::removeFileNameListener $visuNo "::sectiongraph::refresh $visuNo $private($visuNo,itemNo)"
      ::polydraw::removeMoveItemListener $visuNo $private($visuNo,itemNo) "::sectiongraph::refresh $visuNo $private($visuNo,itemNo)"
   } else {
      $private($visuNo,This).frame2.butRefresh configure -state disabled
      #--- j'active le rafraichissement automatique sur deplacement de la ligne de coupe
      ::polydraw::addMoveItemListener $visuNo $private($visuNo,itemNo) "::sectiongraph::refresh $visuNo $private($visuNo,itemNo)"
      #--- je declare le rafraichissement automatique au changement d'image
      ::confVisu::addFileNameListener $visuNo "::sectiongraph::refresh $visuNo $private($visuNo,itemNo)"
   }
}

#------------------------------------------------------------
#  refresh
#     mise a jour du graphe
#  parametres
#     visuNo : numero de visu
#     args   : valeurs fournies par le gestionnaire de listener
#  return : null
#------------------------------------------------------------
proc ::sectiongraph::refresh { visuNo itemNo args } {
   variable private

   #--- je recupere les coordonnees de la ligne de coupe
   set box [::polydraw::getCoords $visuNo $itemNo]

   #--- je convertis en coordonnees image
   set pointA [::confVisu::canvas2Picture $visuNo [lrange $box 0 1]]
   set pointZ [::confVisu::canvas2Picture $visuNo [lrange $box 2 3]]
   set x1 [lindex $pointA 0]
   set y1 [lindex $pointA 1]
   set x2 [lindex $pointZ 0]
   set y2 [lindex $pointZ 1]

   #--- je redresse gauche/droite
   if { $x1 > $x2 } {
      set x  $x1
      set x1 $x2
      set x2 $x
   }

   #--- je redresse haut/bas
   if { $y1 > $y2 } {
      set y  $y1
      set y1 $y2
      set y2 $y
   }

   set bufNo     [::confVisu::getBufNo $visuNo]
   set lx        [list ]
   set lyR       [list ]
   set lyG       [list ]
   set lyB       [list ]
   set xDiff     [expr {$x2 - $x1}]
   set yDiff     [expr {$y2 - $y1}]
   set numPixels [expr {hypot($xDiff,$yDiff)}]
   set xRatio    [expr {$xDiff / $numPixels}]
   set yRatio    [expr {$yDiff / $numPixels}]
   set width     [buf$bufNo getpixelswidth]
   set height    [buf$bufNo getpixelsheight]

   if { [buf$bufNo getnaxis] == 1 } {
      set height [visu$visuNo thickness]
   }

   if { $width > 0 && $height > 0 } {
      #--- je teste la valeur d'un point pour connaitre le nombre de plan de couleur
      set nbcolor($visuNo) [lindex [buf$bufNo getpix [list 1 1 ] ] 0]
   } else {
      set nbcolor($visuNo) [lindex [buf$bufNo getpix [list 1 1 ] ] 0]
   }

   #--- je copie l'intensite des points de la ligne de coupe dans les vecteurs du graphe
   for {set p 0} {$p < $numPixels} {incr p} {
      set x [expr {round($xRatio * $p) + $x1}]
      set y [expr {round($yRatio * $p) + $y1}]
      lappend lx $p
      if { ($x>0) && ($x<=$width) && ($y>0) && ($y<=$height) } {
         lappend lyR [lindex [buf$bufNo getpix [list $x $y ] ] 1]
         if { $nbcolor($visuNo) == 3 } {
            lappend lyG [lindex [buf$bufNo getpix [list $x $y ] ] 2]
            lappend lyB [lindex [buf$bufNo getpix [list $x $y ] ] 3]
         }
      } else {
         #--- si le point est hors de l'image , j'affecte la valeur 0
         lappend lyR 0
         if { $nbcolor($visuNo) == 3 } {
            lappend lyG 0
            lappend lyB 0
         }
      }
   }

   #--- j'affiche le graphe
   sectiongraphX$visuNo set $lx
   sectiongraphYR$visuNo set $lyR
   if { $nbcolor($visuNo) == 1 } {
      #--- j'affiche une courbe blanche
      $private($visuNo,graph,horz) element configure lineR -color white
      $private($visuNo,graph,horz) element configure lineR -hide no
      #--- je masque les deux autres courbes
      $private($visuNo,graph,horz) element configure lineG -hide yes
      $private($visuNo,graph,horz) element configure lineB -hide yes
   } else {
      sectiongraphYG$visuNo set $lyG
      sectiongraphYB$visuNo set $lyB
      #--- j'affiche trois courbes rouge, verte et bleue
      $private($visuNo,graph,horz) element configure lineR -color red
      $private($visuNo,graph,horz) element configure lineG -color green
      $private($visuNo,graph,horz) element configure lineB -color blue
      $private($visuNo,graph,horz) element configure lineR -hide no
      $private($visuNo,graph,horz) element configure lineG -hide no
      $private($visuNo,graph,horz) element configure lineB -hide no
   }
}

#------------------------------------------------------------
#  createToplevel
#     creation de la fenetre
#
#  return : null
#------------------------------------------------------------
proc ::sectiongraph::createToplevel { visuNo } {
   variable private
   global caption conf

   set base [ ::confVisu::getBase $visuNo ]
   set This "$base.sectiongraph"
   set private($visuNo,This) $This
   set width 400
   set height 200

   #--- je verifie si la fenetre existe deja
   if { [winfo exists $This] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   #--- Creation de la fenetre
   toplevel $This
   wm transient $This $base
   wm resizable $This 0 0
   wm title $This "$caption(sectiongraph,title) (visu$visuNo)"
   wm geometry $This $conf(sectiongraph,position)
   wm protocol $This WM_DELETE_WINDOW "::sectiongraph::closeToplevel $visuNo"

   #--- Creation d'une frame
   frame $private($visuNo,This).frame1 -borderwidth 2 -relief raised
   pack $private($visuNo,This).frame1 -side top -fill both -expand 1

   #--- Horizontal Graph
   set private($visuNo,graph,horz) [blt::graph $This.horz \
            -title "" \
            -width $width -height $height \
            -takefocus 0 \
            -bd 0 -relief flat \
            -rightmargin 1 -leftmargin 60 \
            -topmargin 1 -bottommargin 25 \
            -background black \
            -plotborderwidth 2 -plotrelief groove \
            -plotpadx 0 -plotpady 0 \
            -plotbackground black \
         ]

   set fgColor white

   $private($visuNo,graph,horz) element create lineR \
      -xdata sectiongraphX$visuNo -ydata sectiongraphYR$visuNo -color $fgColor -symbol ""
   $private($visuNo,graph,horz) element create lineG \
      -xdata sectiongraphX$visuNo -ydata sectiongraphYG$visuNo -color $fgColor -symbol ""
   $private($visuNo,graph,horz) element create lineB \
      -xdata sectiongraphX$visuNo -ydata sectiongraphYB$visuNo -color $fgColor -symbol ""
   $private($visuNo,graph,horz) legend configure -hide yes
   $private($visuNo,graph,horz) axis configure x -min 0
   $private($visuNo,graph,horz) xaxis configure -title "" -hide no -color $fgColor \
      -ticklength 4
   $private($visuNo,graph,horz) x2axis configure -title "" -hide yes
   $private($visuNo,graph,horz) yaxis configure -title "" -hide no -color $fgColor \
      -ticklength 4
   $private($visuNo,graph,horz) y2axis configure -title "" -hide yes
   $private($visuNo,graph,horz) grid configure -mapy y -dashes ""
   $private($visuNo,graph,horz) crosshairs on
   $private($visuNo,graph,horz) crosshairs configure -color green
   $private($visuNo,graph,horz) element configure lineR -hide no

   pack $private($visuNo,graph,horz) -in $private($visuNo,This).frame1

   #--- Creation d'une frame
   frame $private($visuNo,This).frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $private($visuNo,This).frame2.modeRefresh -text "$caption(sectiongraph,refreshAuto)" \
         -variable conf(sectiongraph,modeRefresh) -command "::sectiongraph::confSectionGraph $visuNo"
      pack $private($visuNo,This).frame2.modeRefresh -anchor w -side top -padx 3 -pady 3

      #--- Cree le bouton pour rafraichir la coupe
      button $private($visuNo,This).frame2.butRefresh -text "$caption(sectiongraph,refreshManuel)" \
         -command "::sectiongraph::refresh $visuNo $private($visuNo,itemNo)"
      pack $private($visuNo,This).frame2.butRefresh -side top -padx 6 -pady 10 -ipadx 20 -ipady 6

   pack $private($visuNo,This).frame2 -side top -fill both -expand 1

   #--- Rafraichir le graphe
   ::sectiongraph::refresh $visuNo $private($visuNo,itemNo)

   #--- Rafraichir la fenetre
   ::sectiongraph::confSectionGraph $visuNo

   #--- La fenetre est active
   focus $private($visuNo,This)

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $private($visuNo,This) <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private($visuNo,This)
}

#------------------------------------------------------------
#  closeToplevel
#     ferme la fenetre et libere les ressources associees
#
#  return : null
#------------------------------------------------------------
proc ::sectiongraph::closeToplevel { visuNo } {
   variable private
   global conf

   if { [info exists private($visuNo,itemNo)] } {
      ::polydraw::deleteItem $visuNo $private($visuNo,itemNo)
      ::polydraw::close $visuNo
      blt::vector destroy sectiongraphX$visuNo sectiongraphYR$visuNo sectiongraphYG$visuNo sectiongraphYB$visuNo

      #--- je determine la position de la fenetre
      set geometry [ wm geometry $private($visuNo,This) ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(sectiongraph,position) "+[ string range $geometry $deb $fin ]"

      #--- je supprime la fenetre
      destroy $private($visuNo,This)

      #--- je supprime les variables associees a la visu
      array unset private $visuNo,*
   }
}

