#
# Fichier : polydraw.tcl
# Description : Dessine un polygone
# Auteur : Michel PUJOL
# Mise à jour $Id$
#

namespace eval ::polydraw {
}

#------------------------------------------------------------
#  init
#     initialise le mode polydraw
#  parameters :
#     visuNo : numero de la visu
#  return : null
#------------------------------------------------------------
proc ::polydraw::init { visuNo } {
   variable private

   set private($visuNo,hCanvas) [::confVisu::getCanvas $visuNo]

   set private($visuNo,mouseAddItem)   "0"
   set private($visuNo,mouseAddNode)   "0"
   set private($visuNo,mouseMoveLine)  "1"

   set private($visuNo,previousZoom)   [confVisu::getZoom $visuNo]
   ::confVisu::addZoomListener $visuNo "::polydraw::setZoom $visuNo"

   interp alias {} tags$private($visuNo,hCanvas) {} $private($visuNo,hCanvas) itemcget current -tags

   #-- add bindings for drawing/editing polygons to a canvas
   $private($visuNo,hCanvas) bind polydraw <Button-1>         "::polydraw::mark   $visuNo %W %x %y"
   $private($visuNo,hCanvas) bind polydraw <B1-Motion>        "::polydraw::move   $visuNo %W %x %y"
   $private($visuNo,hCanvas) bind polydraw <Shift-B1-Motion>  "::polydraw::move   $visuNo %W %x %y 1"
   $private($visuNo,hCanvas) bind polydraw <Button-3>         "::polydraw::delete $visuNo %W 1"
   $private($visuNo,hCanvas) bind polydraw <Double-1>         "::polydraw::insert $visuNo %W"
   $private($visuNo,hCanvas) bind polydraw <Button-2>         "::polydraw::rotate $visuNo %W 0.1"
   $private($visuNo,hCanvas) bind polydraw <Shift-2>          "::polydraw::rotate $visuNo %W -0.1"
   $private($visuNo,hCanvas) bind polydraw <Button-3>         "::polydraw::delete $visuNo %W"
   $private($visuNo,hCanvas) bind polydraw <Shift-3>          "::polydraw::delete $visuNo %W 1"
}

#------------------------------------------------------------
#  close
#     termine polydraw
#  return :
#------------------------------------------------------------
proc ::polydraw::close { visuNo } {
   variable private

   if { [info exists private($visuNo,hCanvas)] } {
      #--- je supprime les binds ( si le canvas avit déjà été memorisé)
      $private($visuNo,hCanvas) bind polydraw <Button-1>         ""
      $private($visuNo,hCanvas) bind polydraw <B1-Motion>        ""
      $private($visuNo,hCanvas) bind polydraw <Shift-B1-Motion>  ""
      $private($visuNo,hCanvas) bind polydraw <Button-3>         ""
      $private($visuNo,hCanvas) bind polydraw <Double-1>         ""
      $private($visuNo,hCanvas) bind polydraw <Button-2>         ""
      $private($visuNo,hCanvas) bind polydraw <Shift-2>          ""
      $private($visuNo,hCanvas) bind polydraw <Button-3>         ""
      $private($visuNo,hCanvas) bind polydraw <Shift-3>          ""
      $private($visuNo,hCanvas) delete polydraw
   }
   confVisu::removeZoomListener $visuNo "::polydraw::setZoom $visuNo"
}

#------------------------------------------------------------
#  setMouseAddItem
#     autorise/interdit l'ajout d'item avec la souris
#  parametres
#     visuNo : numero de visu
#     value  : 1=autorise  0=interdit
#  return :
#------------------------------------------------------------
proc ::polydraw::setMouseAddItem { visuNo value } {
   variable private

   set private($visuNo,mouseAddItem) $value
}

#------------------------------------------------------------
#  setMouseAddNode
#     autorise/interdit l'ajout de noeud avec la souris
#  parametres
#     visuNo : numero de visu
#     value  : 1=autorise  0=interdit
#  return :
#------------------------------------------------------------
proc ::polydraw::setMouseAddNode { visuNo value } {
   variable private

   set private($visuNo,mouseAddNode) $value
}

#------------------------------------------------------------
#  setMouseMoveLine
#     autorise/interdit le deplacement d'une ligne avec la souris
#  parametres
#     visuNo : numero de visu
#     value  : 1=autorise  0=interdit
#  return :
#------------------------------------------------------------
proc ::polydraw::setMouseMoveLine { visuNo value } {
   variable private

   set private($visuNo,mouseMoveLine) $value
}

#------------------------------------------------------------
#  setZoom
#     applique un zoom sur tous les items, cette procedure peut etre appelee:
#      - soit par une autre procedure
#           exemple: ::polydraw::setZoom 1
#      - soit automatiquement a chaque modification du zoom de la visu
#          voir ::confVisu::addZoomListener
#  parametres
#     visuNo : numero de visu
#     args   : valeur fournies par le gestionnaire de listener
#  return : null
#------------------------------------------------------------
proc ::polydraw::setZoom { visuNo args } {
   variable private

   set w $private($visuNo,hCanvas)
   set zoom [confVisu::getZoom $visuNo]
   if { $zoom == $private($visuNo,previousZoom) } {
      return
   }
   set coeff [expr 1.0*$zoom/$private($visuNo,previousZoom)]
   foreach item [$w find all] {
      set tag [lindex [$w itemcget $item -tags] 0]
      switch $tag {
         line {
            #--- homothetie
            $w scale $item 0 0 $coeff $coeff
            ::polydraw::markNodes $visuNo $w $item
         }
         polygon {
            #--- homothetie
            $w scale $item 0 0 $coeff $coeff
            ::polydraw::markNodes $visuNo $w $item
         }
      }
   }
   set private($visuNo,previousZoom) $zoom
}

#------------------------------------------------------------
#  createLine
#     cree une ligne
#  exemple :
#     ::polydraw::createLine 1 { 10 10 10 50 }
#  parametres
#     visuNo : numero de la visu
#     points : liste des points { {x1 y1 x2 y2} }
#  return : numero de l'item dans le canvas
#------------------------------------------------------------
proc ::polydraw::createLine {visuNo points { moveCommand ""} } {
   variable private

   if { [llength $points] < 4 } {
      console::affiche_erreur "::polydraw::createLine must be >= 4 coordinates\n"
      return ""
   }
   set lineNo [$private($visuNo,hCanvas) create line $points -fill yellow -width 2 -activewidth 4 ]
   $private($visuNo,hCanvas) itemconfigure $lineNo -tags { line polydraw }
   ::polydraw::markNodes $visuNo $private($visuNo,hCanvas) $lineNo
   set private($visuNo,moveCommand,$lineNo) $moveCommand
   return $lineNo
}

#------------------------------------------------------------
#  createPolygon
#     cree un polygone
#  exemple :
#     ::polydraw::createPolygon 1 { 10 10 10 50 50 50 50 10 }
#  parametres
#     visuNo : numero de la visu
#     points : liste des points { {x1 y1} {x2 y2} ... }
#  return : numero de l'item dans le canvas
#------------------------------------------------------------
proc ::polydraw::createPolygon {visuNo points } {
   variable private

   if { [llength $points] < "6" } {
      console::affiche_erreur "::polydraw::createPolygon points llength must be >= 6\n"
      return ""
   }
   set itemNo [$private($visuNo,hCanvas) create poly $points  -fill {} -outline white -width 1 -activewidth 3 ]
   $private($visuNo,hCanvas) itemconfigure $itemNo -tags { polygon polydraw }
   ::polydraw::markNodes $visuNo $private($visuNo,hCanvas) $itemNo
   return $itemNo
}

#------------------------------------------------------------
#  deleteItem
#     supprime un item
#  exemple :
#     ::polydraw::deleteItem  1 32
#  parametres
#     visuNo : numero de la visu
#     itemNo : numero de l'item
#  return : null
#------------------------------------------------------------
proc ::polydraw::deleteItem { visuNo itemNo } {
   variable private

   $private($visuNo,hCanvas) delete $itemNo
   $private($visuNo,hCanvas) delete $itemNo of:$itemNo
   return
}

#------------------------------------------------------------
#  getCoords
#     retourne les coordonnees du polygone (referentiel canvas)
#  parametres
#     visuNo : numero de la visu
#     itemNo : numero de l'item
#  return :
#      liste des coordonnees  { {x1 y1} {x2 y2} ... }
#------------------------------------------------------------
proc ::polydraw::getCoords { visuNo itemNo} {
   variable private

   set lc [ list ]
   foreach {x y} [$private($visuNo,hCanvas) coords $itemNo] {
      lappend lc [expr int($x)] [expr int($y)]
   }
   return $lc
}

#------------------------------------------------------------
#  add
#     ajoute un point
#  return :
#------------------------------------------------------------
proc ::polydraw::add {visuNo w x y} {
   variable private

   set result ""

   if {![info exists private($visuNo,tempItem)]} {
      if { $private($visuNo,mouseAddItem) == "1" } {
         #--- je cree une ligne de longueur=1
         set coords [list [expr {$x-1}] [expr {$y-1}] $x $y]
         set private($visuNo,tempItem) [$w create line $coords -fill red -tags { line0 polydraw} ]
         set result $private($visuNo,tempItem)
      }
   } else {
      set item $private($visuNo,tempItem)
      foreach {x0 y0} [$w coords $item] break
      if {hypot($x-$x0,$y-$y0) < 5} {
         set coords [lrange [$w coords $item] 2 end]
         $w delete $item
         unset private($visuNo,tempItem)
         set newItem [$w create poly $coords -fill {} -tags { polygon polydraw } -outline black]
         ::polydraw::markNodes $visuNo $w $newItem
         set result $newItem
      } else {
         $w coords $item [concat [$w coords $item] $x $y]
         set result $item
      }
   }
   return $result
}

#------------------------------------------------------------
#  delete
#     supprime un point ou un polygone
#  return :
#------------------------------------------------------------
proc ::polydraw::delete { visuNo w {all 0}} {
   variable private

   set tags [tags$w]
   ###set visuNo [::confVisu::getVisuNo $w ]
   if {[regexp {of:([^ ]+)} $tags -> poly]} {
      if {$all} {
         #--- supprime un item
         if { $private($visuNo,mouseAddItem) == "1" } {
            $w delete $poly of:$poly
         }
      } else {
         #--- supprime un node
         if { $private($visuNo,mouseAddNode) == "1" } {
            regexp {at:([^ ]+)} $tags -> pos
            if { $pos > 2 } {
               $w coords $poly [lreplace [$w coords $poly] $pos [incr pos]]
               ::polydraw::markNodes $visuNo $w $poly
            }
         }
      }
   }
   $w delete poly0 ;# possibly clean up unfinished polygon
   catch {unset ::private($visuNo,tempItem)}
}

#------------------------------------------------------------
#  insert
#     insere un noeud dans un polygone
#  return :
#------------------------------------------------------------
proc ::polydraw::insert {visuNo w} {
   variable private

   ###set visuNo [::confVisu::getVisuNo $w ]
   if { $private($visuNo,mouseAddNode) == "1" } {
      set tags [tags$w]
      if {[has $tags node]} {
         regexp {of:([^ ]+)} $tags -> poly
         regexp {at:([^ ]+)} $tags -> pos
         set coords [$w coords $poly]
         set pos2 [expr {$pos==0? [llength $coords]-2 : $pos-2}]
         foreach {x0 y0} [lrange $coords $pos end] break
         foreach {x1 y1} [lrange $coords $pos2 end] break
         set x [expr {($x0 + $x1) / 2}]
         set y [expr {($y0 + $y1) / 2}]
         $w coords $poly [linsert $coords $pos $x $y]
         ::polydraw::markNodes $visuNo $w $poly
      }
   }
}

#------------------------------------------------------------
#  mark
#     ajoute un nouveau point ou selectionne un point existant
#  return
#------------------------------------------------------------
proc ::polydraw::mark {visuNo w x y} {
   variable private
   set result ""

   set x [$w canvasx $x]; set y [$w canvasy $y]
   catch {unset private($visuNo,currentItem)}
   if {[has [tags$w] node]} {
      set private($visuNo,currentItem) [$w find withtag current]
      set private($visuNo,currentx)    $x
      set private($visuNo,currenty)    $y
      set result $private($visuNo,currentItem)
   } elseif {[has [tags$w] line]} {
      set private($visuNo,currentItem) [$w find withtag current]
      set private($visuNo,currentx)    $x
      set private($visuNo,currenty)    $y
      set result $private($visuNo,currentItem)
   } elseif {[has [tags$w] polygon]} {
      set private($visuNo,currentItem) [$w find withtag current]
      set private($visuNo,currentx)    $x
      set private($visuNo,currenty)    $y
      set result $private($visuNo,currentItem)
   } else {
      set result [::polydraw::add $visuNo $w $x $y]
   }
   ###return $result
}

#------------------------------------------------------------
#  markNodes
#     dessine les rectangles des noeuds sur les points d'inflexion d'une ligne
#  @param visuNo   numero de la visu
#  @param hCanvas  nom tk du canvas
#  @param lineNo   numero de l'item de la ligne dans le canvas
#  @return void
#------------------------------------------------------------
proc ::polydraw::markNodes {visuNo hCanvas lineNo} {
   #-- decorate a polygon with square marks at its nodes
   $hCanvas delete of:$lineNo
   set pos 0
   foreach {x y} [$hCanvas coords $lineNo] {
      set coord [list [expr $x-2] [expr $y-2] [expr $x+2] [expr $y+2]]
      $hCanvas create rect $coord -fill blue -activefill turquoise -tags "node of:$lineNo at:$pos polydraw"
      incr pos 2
   }
}

#------------------------------------------------------------
#  move
#     deplace un noeud ou un ensemble de noeuds
#  return :
#------------------------------------------------------------
proc ::polydraw::move {visuNo w x y {all 0}} {
   variable private

   #-- move a node of, or a whole polygon
   set x [$w canvasx $x]; set y [$w canvasy $y]
   if {[info exists private($visuNo,currentItem)]} {
      set dx [expr {$x - $private($visuNo,currentx)}]
      set dy [expr {$y - $private($visuNo,currenty)}]
      set private($visuNo,currentx) $x
      set private($visuNo,currenty) $y
      if {!$all} {
         set tags [tags$w]
         set typeItem [lindex $tags 0]
         if { $typeItem == "node" } {
            #--- je translate le point d'inflexion de la ligne
            if { $private($visuNo,mouseMoveLine) == 1 } {
               ::polydraw::moveNode $visuNo $w $dx $dy
            }
         } elseif { $typeItem == "line" } {
            if { $private($visuNo,mouseMoveLine) == 1 } {
               $w move $private($visuNo,currentItem)    $dx $dy
               $w move of:$private($visuNo,currentItem) $dx $dy
            }
         } elseif { $typeItem == "polygon" } {
            if { $private($visuNo,mouseMoveLine) == 1 } {
               $w move $private($visuNo,currentItem)    $dx $dy
               $w move of:$private($visuNo,currentItem) $dx $dy
            }
         }
      } elseif [regexp {of:([^ ]+)} [tags$w] -> itemNo] {
          ###::console::disp "move all itemNo=$itemNo\n"
          ###$w move $itemNo    $dx $dy
          ###$w move of:$itemNo $dx $dy
      }

      #--- je lance le listener de deplacement s'il existe
      if { [info exists ::polydraw::private($visuNo,listener,$private($visuNo,currentItem))] } {
         #--- j'ecris dans la variable pour activer le listener
         set ::polydraw::private($visuNo,listener,$private($visuNo,currentItem)) "1"
      }
   }
}

#------------------------------------------------------------
# addMoveItemListener
#    ajoute une procedure a appeler quand on deplace un item
# parametre :
#     visuNo : numero de la visu
#     itemNo : numero de l'item
#     cmd    : procedure a appeler
# retour : null
#------------------------------------------------------------
proc ::polydraw::addMoveItemListener { visuNo item cmd } {
   variable private

   set ::polydraw::private($visuNo,listener,$item) "1"
   trace add variable "::polydraw::private($visuNo,listener,$item)" write $cmd
}

#------------------------------------------------------------
# removeZoomListener
#    supprime une procedure a appeler quand on deplace un item
# parametre :
#    visuNo : numero de la visu
#    itemNo : numero de l'item
#    cmd    : procedure a appeler
# retour : null
#------------------------------------------------------------
proc ::polydraw::removeMoveItemListener { visuNo item cmd } {
   variable private

   trace remove variable "::polydraw::private($visuNo,listener,$item)" write $cmd
   if { [ info exists ::polydraw::private($visuNo,listener,$item) ] } {
      unset ::polydraw::private($visuNo,listener,$item)
   }
}

#------------------------------------------------------------
# moveNode
#    deplace un point d'inflexion de la ligne
# @param hCanvas : nom tk du canvas
# @param dx : translation horizontale (en coordonnees canvas)
# @param dy : translation verticale (en coordonnees canvas)
# @return void
#------------------------------------------------------------
proc ::polydraw::moveNode { visuNo hCanvas dx dy} {
   variable private

   set tags [tags$hCanvas]

   if [regexp {of:([^ ]+)} $tags -> lineNo] {
      #--- je deplace l'extremite de la ligne
      regexp {at:([^ ]+)} $tags -> xPos
      set yPos [expr {$xPos + 1}]
      set coords [$hCanvas coords $lineNo]
      if { $private($visuNo,moveCommand,$lineNo) ne "" } {
          #--- je corrige la translation avec la procedure specifique si elle existe
          set nodeNo [expr $xPos / 2 + 1 ]
          set dCoord [eval $private($visuNo,moveCommand,$lineNo) $nodeNo [lindex $coords $xPos] [lindex $coords $yPos] $dx $dy ]
          set dx [lindex $dCoord 0]
          set dy [lindex $dCoord 1]
      }
      #--- je calcule les nouvelles coordonnees en faisant une translation
      set x [expr [lindex $coords $xPos] + $dx ]
      set y [expr [lindex $coords $yPos] + $dy ]
      $hCanvas coords $lineNo [lreplace $coords $xPos $yPos $x $y]

      #--- je deplace le carre autour du point
      $hCanvas move $private($visuNo,currentItem) $dx $dy
      ###console::disp "::polydraw::moveNode hCanvas=$hCanvas lineNo=$lineNo itemNo=$private($visuNo,currentItem) xPos=$xPos yPos=$yPos dx=$dx dy=$dy\n"
   }
}

proc ::polydraw::rotate { visuNo w angle} {
   if [regexp {of:([^ ]+)} [tags$w] -> item] {
      ::polydraw::rotateItem $visuNo $w $item $angle
      ::polydraw::markNodes $visuNo $w $item
   }
}

#--------------------------------------- more general routines
proc ::polydraw::center {visuNo w item} {
   foreach {x0 y0 x1 y1} [$w bbox $item] break
   list [expr {($x0 + $x1) / 2.}] [expr {($y0 + $y1) / 2.}]
}

proc ::polydraw::rotateItem {visuNo w item angle} {
   # This little code took me hours... but the Welch book saved me!
   foreach {xm ym} [::polydraw::center $visuNo $w $item] break
   set coords {}
   foreach {x y} [$w coords $item] {
      set rad [expr {hypot($x-$xm, $y-$ym)}]
      set th  [expr {atan2($y-$ym, $x-$xm)}]
      lappend coords [expr {$xm + $rad * cos($th - $angle)}]
      lappend coords [expr {$ym + $rad * sin($th - $angle)}]
   }
   $w coords $item $coords
}

proc ::polydraw::has {list element} {
   expr {[lsearch $list $element]>=0}
}

proc ::polydraw::listAll { visuNo } {
   variable private

   ::console::disp "listAll:\n"

   foreach item [$private($visuNo,hCanvas) find all] {
      ::console::disp "   item $item tag=[$private($visuNo,hCanvas) itemcget $item -tags]\n"
   }
}

###::polydraw::init 1
###set w ".audace.can1.canvas"
###polydraw $w

