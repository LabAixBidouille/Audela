#
# Fichier : confvisu.tcl
# Description : Gestionnaire des visu
# Auteur : Michel PUJOL
# Mise a jour $Id: confvisu.tcl,v 1.81 2008-06-26 19:04:02 michelpujol Exp $
#

namespace eval ::confVisu {

   #------------------------------------------------------------
   # confVisu::init
   #    initialise le namespace visu
   #
   #------------------------------------------------------------
   proc init { } {
      variable private
      global conf

   }

   #------------------------------------------------------------
   # confVisu::create
   #    cree une nouvelle visu
   # parametres :
   #    base : fenetre Toplevel dans laquelle est cree la visu
   #           si base est vide, la fonction cree une nouvelle Toplevel
   # retour :
   #    retourne une exception en cas d'erreur
   #------------------------------------------------------------
   proc create { { base "" } } {
      variable private
      global audace
      global conf

      #--- je cree une visu temporaire pour savoir quel sera le numero de visu
      set result [catch {::visu::create 1 1} visuNo]
      if { $result } {
         #--- je cree une exception
         error "erreur creation visu temporaire\n"
      } else {
         #--- je detruis la visu temporaire
         ::visu::delete $visuNo
      }

      #--- cree les variables dans conf(..) si elles n'existent pas
      if { ! [ info exists conf(audace,visu$visuNo,wmgeometry) ] } {
         set conf(audace,visu$visuNo,wmgeometry) "600x400+0+0"
      }
      if { ! [ info exists conf(seuils,visu$visuNo,intervalleSHSB) ] } {
         set conf(seuils,visu$visuNo,intervalleSHSB) "1"
      }
      if { ! [ info exists conf(seuils,visu$visuNo,mode) ] } {
         set conf(seuils,visu$visuNo,mode) "loadima"
      }
      if { ! [ info exists conf(visu,crosshairstate) ] } {
         set conf(visu,crosshairstate) "0"
      }
      if { ! [ info exists conf(visu_palette,visu$visuNo,mode) ] } {
         set conf(visu_palette,visu$visuNo,mode) "1"
      }
      if { ! [ info exists conf(fonction_transfert,visu$visuNo,position) ] } {
         set conf(fonction_transfert,visu$visuNo,position) "+0+0"
      }
      if { ! [ info exists conf(fonction_transfert,visu$visuNo,mode) ] } {
         set conf(fonction_transfert,visu$visuNo,mode) "1"
      }

      if { $base != "" } {
         set private($visuNo,This) $base
         #--- pas besoin de creer de toplevel
      } else {
         #--- creation de la fenetre toplevel
         set private($visuNo,This) ".visu$visuNo"
         ::confVisu::createToplevel $visuNo $private($visuNo,This)
      }

      #--- Position de l'image dans la fenetre principale
      set private($visuNo,labcoord_type)   "xy"
      set private($visuNo,picture_w)       "0"
      set private($visuNo,picture_h)       "0"
      set private($visuNo,applyThickness)  "0"
      set private($visuNo,autovisuEnCours) "0"
      set private($visuNo,lastFileName)    "?"
      set private($visuNo,maxdyn)          "32767"
      set private($visuNo,mindyn)          "-32768"
      set private($visuNo,intervalleSHSB)  "$conf(seuils,visu$visuNo,intervalleSHSB)"
      set private($visuNo,a)               "0"
      set private($visuNo,b)               "1"
      set private($visuNo,hCanvas)         $private($visuNo,This).can1.canvas
      set private($visuNo,hCrosshairH)     $private($visuNo,hCanvas).crosshairH
      set private($visuNo,hCrosshairV)     $private($visuNo,hCanvas).crosshairV
      set private($visuNo,crosshairstate)  $conf(visu,crosshairstate)
      set private($visuNo,menu)            ""

      #--- Initialisation des variables utilisees par les menus
      set private($visuNo,mirror_x)        "0"
      set private($visuNo,mirror_y)        "0"
      set private($visuNo,window)          "0"
      set private($visuNo,fullscreen)      "0"
      set private($visuNo,zoom)            "1"
      set private($visuNo,currentTool)     ""
      set private($visuNo,pluginInstanceList) [list ]

      #--- Initialisation de variables pour le trace de repere
      set private($visuNo,boxSize)         ""
      set private($visuNo,hBox)            ""

      set private($visuNo,camItem)         ""

      set private($visuNo,intensity)       "1"

      #--- initialisation des bind de touches et de la souris
      set private($visuNo,MouseState) rien

      #--- je cree la fenetre
      ::confVisu::createDialog $visuNo $private($visuNo,This)

      #--- je cree le buffer
      set result [catch {::buf::create} bufNo]
      if { $result } {
         #--- je cree une exception
         error "erreur creation buffer pour nouvelle visu\n"
      } else {
         #--- configuration buffer
         buf$bufNo extension $conf(extension,defaut)
         #--- Fichiers image compresses ou non
         if { $conf(fichier,compres) == "0" } {
            buf$bufNo compress "none"
         } else {
            buf$bufNo compress "gzip"
         }
         #--- Format des fichiers image (entier ou flottant)
         if { $conf(format_fichier_image) == "0" } {
            buf$bufNo bitpix ushort
         } else {
            buf$bufNo bitpix float
         }
      }

      #--- Creation de l'image associee a la visu dans le tag "display"
      $private($visuNo,hCanvas) create image 0 0 -anchor nw -tag display
      image create photo image$visuNo
      $private($visuNo,hCanvas) itemconfigure display -image image$visuNo

      #--- je cree la visu associee au buffer bufNo et a l'image image$visuNo
      set visuNo [::visu::create $bufNo $visuNo]

      #--- je cree le menu
      if { $base == "" } {
         ::confVisu::createMenu $visuNo
      }

      #--- je cree les bind
      ::confVisu::createBindDialog $visuNo

      #--- j'affiche le nom de la monture
      setMount $visuNo

      return $visuNo
   }

   #------------------------------------------------------------
   #  close
   #     ferme la visu
   #------------------------------------------------------------
   proc close { visuNo } {
      variable private
      global audace
      global conf
      global caption

      #--- je verifie que la visu existe
      if { [info commands "::visu$visuNo" ] == "::visu$visuNo" } {
         set bufNo [visu$visuNo buf]

         #--- je ferme l'outil courant
         if { [getTool $visuNo] != "" } {
            ::[getTool $visuNo]::stopTool $visuNo
         }

         #--- je ferme la camera associee a la visu
         ::confCam::stopItem $private($visuNo,camItem)

         #--- je memorise les variables dans conf(..)
         set conf(audace,visu$visuNo,wmgeometry)     [wm geometry $::confVisu::private($visuNo,This)]
         set conf(seuils,visu$visuNo,intervalleSHSB) $private($visuNo,intervalleSHSB)

         #--- je supprime les bind
         ::confVisu::deleteBindDialog $visuNo

         #--- je supprime le menubar et toutes ses entrees
         if { $private($visuNo,menu) != "" } {
            Menubar_Delete $visuNo
         }

         #--- je detruis tous les outils
         if { "$private($visuNo,This)" != "$audace(base).select" } {
            foreach pluginInstance $private($visuNo,pluginInstanceList) {
               $pluginInstance\::deletePluginInstance $visuNo
            }
         }

         #--- je supprime l'image associee a la visu
         image delete image[visu$visuNo image]

         #--- je supprime la visu
         ::visu::delete $visuNo

         #--- je supprime le buffer associe a la visu
         ::buf::delete $bufNo

         #--- je supprime les graphes des coupes
         ::sectiongraph::closeToplevel $visuNo

      }

      #--- je supprime la fenetre et la variable
      destroy $private($visuNo,This)
      unset private($visuNo,This)

   }

   #------------------------------------------------------------
   # autovisu
   #     rafraichit l'affichage
   # parametres
   #  visuNo: numero de la visu
   #  force:  -dovisu : rafraichissement complet
   #          -no     : rafraichissement sans recalcul des seuils
   #          -novisu : pas de rafraichissement
   #  retour: null
   #------------------------------------------------------------
   proc autovisu { visuNo { force "-no" } } {
      variable private
      global conf
      global caption

      if { $force == "-novisu" } {
         return
      }

      #--- petit raccourci pour la suite
      set bufNo [visu$visuNo buf]
      set camNo [::confCam::getCamNo $private($visuNo,camItem)]

      if { [ image type image[visu$visuNo image] ] == "video" } {
         #--- je recupere la largeur et la hauteur de la video
         set videoSize [cam$camNo nbpix ]
         set private($visuNo,picture_w)  [lindex $videoSize 0]
         set private($visuNo,picture_h)  [lindex $videoSize 1]
         #--- Je mets a jour la taille les scrollbars
         setScrollbarSize $visuNo
         #--- Je mets a jour la taille du reticule
         ::confVisu::redrawCrosshair $visuNo
      } else {
         #--- je recupere la largeur et la hauteur de l'image
         set private($visuNo,picture_w) [buf$bufNo getpixelswidth]
         if { "$private($visuNo,picture_w)" == "" } {
            set private($visuNo,picture_w) 0
         }
         if { [buf$bufNo getpixelsheight] == 1 } {
            #--- dans le cas d'une image 1D, la hauteur correspond a l'epaisseur affichee par la visu
            set private($visuNo,applyThickness) "1"
            set private($visuNo,picture_h) [visu$visuNo thickness]
         } else {
            #--- dans le cas d'une image 2D ou plus, la hauteur est la hauteur retournee par le buffer
            set private($visuNo,applyThickness) "0"
            set private($visuNo,picture_h) [buf$bufNo getpixelsheight]
         }

         set width  $private($visuNo,picture_w)
         set height $private($visuNo,picture_h)

         #--- je supprime l'item video s'il existe
         Movie::deleteMovieWindow $visuNo
         $private($visuNo,hCanvas) itemconfigure display -state normal

         #--- je supprime le fenetrage si la fenetre deborde de l'image
         set windowBox [visu$visuNo window]
         if { [lindex $windowBox 2] > $width
            || [lindex $windowBox 3] > $height } {
            set private($visuNo,window) "0"
            setWindow $visuNo
         }

         #--- Si le buffer contient une image on met a jour les seuils
         if { [ buf$bufNo imageready ] == "1" } {
            switch -exact -- $conf(seuils,visu$visuNo,mode) {
               disable {
                  if { $force == "-no" } {
                    visu $visuNo current
                  } else {
                     visu $visuNo [ lrange [ buf$bufNo stat ] 0 1 ]
                  }
               }
               loadima {
                  visu $visuNo [ lrange [ buf$bufNo stat ] 0 1 ]
               }
               iris {
                  set moyenne [ lindex [ buf$bufNo stat ] 4 ]
                  visu $visuNo [ list [ expr $moyenne + $conf(seuils,irisautohaut) ] [expr $moyenne - $conf(seuils,irisautobas) ] ]
               }
               histoauto {
                  set keytype FLOAT
                  buf$bufNo imaseries "CUTS lofrac=[expr 0.01*$conf(seuils,histoautobas)] hifrac=[expr 0.01*$conf(seuils,histoautohaut)] keytype=$keytype"
                  visu $visuNo [ list [ lindex [ buf$bufNo getkwd MIPS-HI ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-LO ] 1 ] ]
               }
               initiaux {
                  buf$bufNo initialcut
                  if { [ lindex [ buf$bufNo getkwd NAXIS ] 1 ] == "3" } {
                     set mycuts [ list [ lindex [ buf$bufNo getkwd MIPS-HIR ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-LOR ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-HIG ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-LOG ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-HIB ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-LOB ] 1 ] ]
                  } else {
                     set mycuts [ list [ lindex [ buf$bufNo getkwd MIPS-HI ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-LO ] 1 ] ]
                  }
                  visu $visuNo $mycuts
               }
            }
         } else {
            #--- nettoyage de l'affichage s'il n'y a pas d'image dans le buffer
            set private($visuNo,picture_w) 0
            set private($visuNo,picture_h) 0
            visu $visuNo current
         }

         #--- Je mets a jour la taille les scrollbars
         setScrollbarSize $visuNo

         #--- Je mets a jour la taille du reticule
         ::confVisu::redrawCrosshair $visuNo
      }

   }

   #
   # visu [l2i cuts]
   # Visualisation du buffer : Eventuellement on peut changer les seuils en passant
   # une liste de deux elements entiers par plan image, le seuil haut et le seuil bas
   # liste de 2 elements pour une image naxis 2 et de 6 elements pour une image naxis 3
   #
   # Exemple :
   # visu
   # visu {500 0}
   #
   proc visu { visuNo { cuts "autocuts" } } {
      variable private

      if { [llength $cuts] == 1 } {
         if { $cuts == "autocuts"} {
            set bufNo [visu$visuNo buf ]
            set cuts [ lrange [ buf$bufNo autocuts ] 0 1 ]
         } elseif { $cuts == "current" } {
            #--- on ne touche pas aux seuils
           # set cuts [ list [getHiCutDisplay $visuNo] [getLoCutDisplay $visuNo] ]
           # visu$visuNo cut $cuts
         } else {
            console::affiche_erreur "confVisu::visu inexptected value cuts = $cuts \n"
         }
      } elseif { [llength $cuts] >= 2 } {
         visu$visuNo cut $cuts
      }

      visu$visuNo clear
      ::confVisu::ComputeScaleRange $visuNo
      ::confVisu::ChangeCutsDisplay $visuNo

      #--- prise en compte de la palette prealablement choisie
      ::audace::MAJ_palette $visuNo

      #--- rafraichissement de l'affichage
      visu$visuNo disp
   }

   #------------------------------------------------------------
   #  clear
   #    efface le contenu de la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc clear { visuNo } {
      variable private

      #--- Je masque la fenetre des films
      ::Movie::deleteMovieWindow $visuNo

      catch { ::astrometry::quit }

      #--- Suppression de la fenetre a l'ecran
      deleteBox $visuNo

      #--- je reinitialise l'image
      visu$visuNo clear
   }

   #------------------------------------------------------------
   #  setAvailableScale
   #     affiche les echelles de coordonnees autorisees
   #       "xy" :
   #
   #  parametres :
   #    visuNo: numero de la visu
   #    scales :  "xy"         coordonnes x,y uniquement
   #              "xy_radec"   coordonnes x,y  ou ra,dec
   #------------------------------------------------------------
   proc setAvailableScale { visuNo scales } {
      variable private
      global color
      global audace

      if { $scales == "xy_radec" } {
         $private($visuNo,This).fra1.labURLX configure -fg $color(blue)
         $private($visuNo,This).fra1.labURLY configure -fg $color(blue)
        ### set private($visuNo,labcoord_type) "xy"
         bind $private($visuNo,This).fra1.labURLX <Button-1> "::confVisu::toogleCoordType $visuNo"
         bind $private($visuNo,This).fra1.labURLY <Button-1> "::confVisu::toogleCoordType $visuNo"
      } else {
         $private($visuNo,This).fra1.labURLX configure -fg $audace(color,textColor)
         $private($visuNo,This).fra1.labURLY configure -fg $audace(color,textColor)
         set private($visuNo,labcoord_type) "xy"
         #--- Annulation des bindings
         bind $private($visuNo,This).fra1.labURLX <Button-1> {}
         bind $private($visuNo,This).fra1.labURLY <Button-1> {}
      }
   }

   #------------------------------------------------------------
   #  toogleCoordType
   #     change l'echelle des coordonnees  (xy <=> radec)
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc toogleCoordType { visuNo } {
      global caption
      variable private

       if { $private($visuNo,labcoord_type) == "xy" } {
         set private($visuNo,labcoord_type) "radec"
         $private($visuNo,This).fra1.labURLX configure -text "$caption(confVisu,RA) $caption(confVisu,egale) $caption(confVisu,tiret)"
         $private($visuNo,This).fra1.labURLY configure -text "$caption(confVisu,DEC) $caption(confVisu,egale) $caption(confVisu,tiret)"
       } else {
         set private($visuNo,labcoord_type) "xy"
         $private($visuNo,This).fra1.labURLX configure -text "$caption(confVisu,X) $caption(confVisu,egale) $caption(confVisu,tiret)"
         $private($visuNo,This).fra1.labURLY configure -text "$caption(confVisu,Y) $caption(confVisu,egale) $caption(confVisu,tiret)"
       }
   }

   #------------------------------------------------------------
   #  getCanvasCenter
   #     retourne les coordonnees du centre du canvas (referentiel canvas)
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getCanvasCenter { visuNo } {
      variable private

      set box [grid bbox $private($visuNo,This).can1 0 0]
      set xScreenCenter [expr ([lindex $box 2] - [lindex $box 0])/2 ]
      set yScreenCenter [expr ([lindex $box 3] - [lindex $box 1])/2 ]

      return [::confVisu::screen2Canvas $visuNo [list $xScreenCenter $yScreenCenter]]
   }

   #------------------------------------------------------------
   #  getHiCutDisplay
   #     retourne le valeur du seuil haut
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getHiCutDisplay { visuNo } {
      variable private

      return [$private($visuNo,This).fra1.sca1 get]
   }

   #------------------------------------------------------------
   #  getLoCutDisplay
   #     retourne le valeur du seuil bas
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getLoCutDisplay { visuNo } {
      variable private

      return [$private($visuNo,This).fra1.sca2 get]
   }

   #------------------------------------------------------------
   #  setZoom
   #     change le zoom et rafraichit l'affichage
   #     conserve le centre de l'image au centre du canvas si possible
   #  parametres :
   #    visuNo: numero de la visu
   #    zoom  : valeur du zoom. Ce parametre est optionnel, le zoom
   #            courant est utilise s'il n'est pas reseigne.
   #  Exemple : afficher la visu 1 avec zoom = 0.5
   #    ::confVisu::setZoom 1 0.5
   #------------------------------------------------------------
   proc setZoom { visuNo { zoom "" } } {
      variable private

      #--- je modifie le zoom si une nouvelle valeur est donnee en parametre
      if { $zoom == "" } {
         #--- rien a faire, on prend la valeur de private($visuNo,zoom)
      } elseif { $zoom==.125 || $zoom==.25 || $zoom==.5 || $zoom==1 || $zoom==2 || $zoom==4 } {
         set private($visuNo,zoom) $zoom
      } else {
         ::console::affiche_erreur "confVisu::setZoom error : zoom $zoom not authorized\n"
      }

      #--- je calcule les coordonnées du centre de l'image
      set canvasCenterPrev [getCanvasCenter $visuNo]
      set pictureCenter [::confVisu::canvas2Picture $visuNo $canvasCenterPrev ]

      #--- je calcule la position du bord gauche et du bord haut
      set previousLeft [expr [lindex $canvasCenterPrev 0] - [lindex [$private($visuNo,hCanvas) xview] 0] * [lindex [$private($visuNo,hCanvas) cget -scrollregion ] 2] ]
      set previousTop  [expr [lindex $canvasCenterPrev 1] - [lindex [$private($visuNo,hCanvas) yview] 0] * [lindex [$private($visuNo,hCanvas) cget -scrollregion ] 3] ]
      set zoomPrev [visu$visuNo zoom]

      #--- j'applique le nouveau zoom
      visu$visuNo zoom $private($visuNo,zoom)

      #--- rafraichissement de l'image avec le nouveau zoom
      visu$visuNo clear
      visu$visuNo disp

      #--- mise a jour du parametre scrollposition du canvas
      setScrollbarSize $visuNo

      #--- je calcule les coordonnes de l'ancien centre du canvas dans le nouveau repere
      set canvasCenter [::confVisu::picture2Canvas $visuNo $pictureCenter]

      #--- je calcule la nouvelle position du bord gauche et du haut pour garder le centre de l'image au meme endroit
      set newleft [expr [lindex $canvasCenter 0] - $previousLeft ]
      set newtop  [expr [lindex $canvasCenter 1] - $previousTop  ]

      #--- je corrige les deplacements si l'ancien centre du canvas n'est plus visible
      if { $newleft < 0 } { set newleft 0 }
      if { $newtop  < 0 } { set newtop  0 }

      #--- je centre le canvas
      set scrollRegion [$private($visuNo,hCanvas) cget -scrollregion]
      set leftRegion   [lindex $scrollRegion 0]
      set topRegion    [lindex $scrollRegion 1]
      set rightRegion  [lindex $scrollRegion 2]
      set bottomRegion [lindex $scrollRegion 3]

      if { $rightRegion != 0 } {
         $private($visuNo,hCanvas) xview moveto [ expr $newleft / ($rightRegion - $leftRegion) ]
      }

      if { $bottomRegion != 0 } {
         $private($visuNo,hCanvas) yview moveto [ expr $newtop / ($bottomRegion - $topRegion) ]
      }

      #--- je mets a jour la taille du reticule
      ::confVisu::redrawCrosshair $visuNo
   }

   #------------------------------------------------------------
   #  setMirrorX
   #     applique un miroir par rapport a l'axe des X
   #
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc setMirrorX { visuNo } {
      variable private

      #--- j'applique un miroir vertical (sur l'axe des x)
      visu$visuNo mirrorx $private($visuNo,mirror_x)
      ::confVisu::autovisu $visuNo

   }

   #------------------------------------------------------------
   #  setMirrorY
   #     applique un miroir par rapport a l'axe des Y
   #
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc setMirrorY { visuNo } {
      variable private

      #--- j'applique un miroir horizontal (sur l'axe des y)
      visu$visuNo mirrory $private($visuNo,mirror_y)
      ::confVisu::autovisu $visuNo
   }

   #------------------------------------------------------------
   #  setCamera
   #     memorise la camera associee a la visu
   #  parametres :
   #    visuNo  : numero de la visu
   #    camItem : instance de la camera, ou "" s'il n'y a pas de camera
   #    model   : modele de la camera (optionnel)
   #  exemple :
   #    setCamera 2 A
   #------------------------------------------------------------
   proc setCamera { visuNo camItem { model "" } } {
      variable private
      global caption

      if { [winfo exists $private($visuNo,This)] == 1} {
         if { $camItem == "" } {
            set description "$caption(confVisu,2points) $caption(confVisu,non_connecte)"
         } else {
            set camName [::confCam::getPluginProperty $camItem "name"]
            set description "$camItem $caption(confVisu,2points) $camName $model"
         }
      }
      #--- J'affiche le nom de la camera
      $private($visuNo,This).fra1.labCam_name_labURL configure -text $description
      #--- Je renseigne la dynamique de la camera
      set dynamic [ ::confCam::getPluginProperty $camItem "dynamic" ]
      ::confVisu::visuDynamix $visuNo [ lindex $dynamic 0 ] [ lindex $dynamic 1 ]
      #--- je memorise le camItem associe a cette visu
      set private($visuNo,camItem) $camItem
   }

   #------------------------------------------------------------
   #  setMount
   #     associe une monture a la visu
   #  parametre :
   #    visuNo  : numero de la visu
   #------------------------------------------------------------
   proc setMount { visuNo } {
      variable private
      global audace
      global caption
      global color

      if { $audace(telNo) == "0" } {
         $private($visuNo,This).fra1.labTel_name_labURL configure -text "$caption(confVisu,2points) $caption(confVisu,non_connecte)" \
            -fg $color(blue)
      } else {
         $private($visuNo,This).fra1.labTel_name_labURL configure -text "$caption(confVisu,2points) [ tel$audace(telNo) name ]" \
            -fg $color(blue)
      }
   }

   #------------------------------------------------------------
   #  getCamItem
   #     retourne l'item de camera associee a la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getCamItem { visuNo } {
      variable private

      #--- je teste l'existance de la variable au cas ou la visu n'existe pas
      if { [ info exists private($visuNo,camItem) ] == "1" } {
         return $private($visuNo,camItem)
      } else {
         return ""
      }
   }

   #------------------------------------------------------------
   #  getBufNo
   #     retourne le numero du buffer associe a la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getBufNo { visuNo } {
      variable private

      return [visu$visuNo buf]
   }

   #------------------------------------------------------------
   #  getWindow
   #     retourne les coordonnees du rectangle de l'image visible dans la visu
   #     (refrentiel buffer)
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getWindow { visuNo } {
      variable private

      set bufNo [visu$visuNo buf]
      if { [ buf$bufNo imageready ] == "1" } {
         set windowBox [visu$visuNo window]
         if {$windowBox=="full"} {
            set x0 1
            set y0 1
            set x1 $private($visuNo,picture_w)
            set y1 $private($visuNo,picture_h)
         } else {
            set x0 [lindex $windowBox 0]
            set y0 [lindex $windowBox 1]
            set x1 [lindex $windowBox 2]
            set y1 [lindex $windowBox 3]
         }
         set result [list $x0 $y0 $x1 $y1]
      } else {
         set result [list  0 0 0 0 ]
      }
      return $result

   }
   #------------------------------------------------------------
   #  setWindow
   #     affiche une partie de l'image delimitee par private(visuNo,boxSize)
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc setWindow { visuNo } {
      variable private
      global caption

      set bufNo [visu$visuNo buf]
      if { [ buf$bufNo imageready ] == "1" } {
         if { $private($visuNo,window) == "0" } {
            visu$visuNo window full
            ::confVisu::autovisu $visuNo
         } else {
            if { $private($visuNo,boxSize) != "" } {
               visu$visuNo window $private($visuNo,boxSize)
               deleteBox $visuNo
               ::confVisu::autovisu $visuNo
               #--- Je redessine le reticule
               redrawCrosshair $visuNo
            } else {
               tk_messageBox -title $caption(confVisu,attention) -type ok -message $caption(confVisu,tracer_boite)
               set private($visuNo,window) "0"
            }
         }
      } else {
         set private($visuNo,window) "0"
      }
   }

   #------------------------------------------------------------
   #  setFullScreen
   #     affiche la visu en plein ecran
   #  parametres :
   #    visuNo : numero de la visu
   #------------------------------------------------------------
   proc setFullScreen { visuNo } {
      variable private

      set directory [ file dirname $private($visuNo,lastFileName) ]
      set filename [ file tail $private($visuNo,lastFileName) ]
      set bufNo [visu$visuNo buf]
      if { [ buf$bufNo imageready ] == "1" } {
         if { $private($visuNo,fullscreen) == "1" } {
            ##if { [::Image::isAnimatedGIF "$private($visuNo,lastFileName)"] == 1 } {
            ##   #--- Ne fonctionne que pour des gif animes (type Image en dur dans le script), pas pour des videos
            ##   set private(gif_anime) "1"
            ##   ::FullScreen::showFiles $visuNo $private($visuNo,hCanvas) $directory [ list [ list $filename "Image" ] ]
            ##} else {
            ##}
            ::FullScreen::showBuffer $visuNo $private($visuNo,hCanvas)
         } else {
            ::FullScreen::closeWindow $visuNo
         }
      } else {
         set private($visuNo,fullscreen) "0"
      }
   }

   #------------------------------------------------------------
   #  setScrollbarSize
   #     met a jour la taille des scrollbars
   #     si le parametre box n'est pas founi, la taille des scrollbars est determine
   #     a partir de l'image deja affichee
   #  parametres :
   #    visuNo: numero de la visu
   #    box   : coordonnee mini et maxi dans le repere image (facultatif)
   #------------------------------------------------------------
   proc setScrollbarSize { visuNo { box "" } } {
      variable private

      if { "$box" == "" } {
         set windowBox [visu$visuNo window]
         if {$windowBox=="full"} {
            set x0 1
            set y0 1
            set x1 $private($visuNo,picture_w)
            set y1 $private($visuNo,picture_h)
         } else {
            set x0 [lindex $windowBox 0]
            set y0 [lindex $windowBox 1]
            set x1 [lindex $windowBox 2]
            set y1 [lindex $windowBox 3]
         }
      } else {
         set x0 [lindex $box 0]
         set y0 [lindex $box 1]
         set x1 [lindex $box 2]
         set y1 [lindex $box 3]
      }
      #--- j'ajoute une unite en largeur et en hauteur pour que les scollbars
      #--- permettent de voir l'ensemble de l'image
      set x1 [expr $x1 + 1 ]
      set y0 [expr $y0 - 1 ]
      set coord0 [ picture2Canvas $visuNo [list $x0 $y0 ] ]
      set coord1 [ picture2Canvas $visuNo [list $x1 $y1 ] ]

      if { [lindex $coord0 0] < [lindex $coord1 0] } {
         set left  [lindex $coord0 0]
         set right [lindex $coord1 0]
      } else {
         set left  [lindex $coord1 0]
         set right [lindex $coord0 0]
      }

      #--- attention : il faut inverser y0 et y1 car l'origine de l'axe y est en haut dans le repere canvas
      if { [lindex $coord0 1] < [lindex $coord1 1] } {
         set top    [lindex $coord0 1]
         set bottom [lindex $coord1 1]
      } else {
         set top    [lindex $coord1 1]
         set bottom [lindex $coord0 1]
      }

      #--- j'elimine les erreur d'arrondi quand zoom <1
      if { $left < 0 } { set left 0 }
      if { $top < 0 }  { set top  0 }

      $private($visuNo,hCanvas) configure -scrollregion [list $left $top $right $bottom]
   }

   #------------------------------------------------------------
   #  setVideo
   #     active/desactive le mode video pour une camera pour afficher
   #     des films AVI
   #
   #  parametres :
   #    visuNo: numero de la visu
   #    state : 1= active le mode video, 0=desactive le mode video
   #------------------------------------------------------------
   proc setVideo { visuNo state } {
      variable private

      set imageNo [visu$visuNo image]
      set camNo   [::confCam::getCamNo $private($visuNo,camItem) ]

      if { $state == 1 } {
         #--- Je supprime l'image precedente
         buf[visu$visuNo buf] clear
         #--- j'active le mode video
         visu$visuNo mode video

         #--- Je connecte la sortie de la camera a l'image
         set result [ catch { cam$camNo startvideoview $visuNo } ]
         if { $result == 1 } {
            #--- je restaure le mode photo
            visu$visuNo mode photo
            #--- j'active le reglage des seuils
            $private($visuNo,This).fra1.sca1 configure -state normal
            $private($visuNo,This).fra1.sca2 configure -state normal
            ::console::affiche_erreur "$::errorInfo\n"
            tk_messageBox -message "$::errorInfo. See console" -icon error
            return
         }

         visu$visuNo disp

         #--- je desactive le reglage des seuils
         $private($visuNo,This).fra1.sca1 configure -state disabled
         $private($visuNo,This).fra1.sca2 configure -state disabled

      } else {
         #--- Je deconnecte la sortie de la camera
         set result [ catch { cam$camNo stopvideoview $visuNo } msg ]
         #--- je desactive le mode video
         visu$visuNo mode photo
         #--- j'active le reglage des seuils
         $private($visuNo,This).fra1.sca1 configure -state normal
         $private($visuNo,This).fra1.sca2 configure -state normal
      }

      if { $result != 1 } {
         ::confVisu::autovisu $visuNo
      }

      return $result
   }

   #------------------------------------------------------------
   # addCameraListener
   #    ajoute une procedure a appeler si on change de camera
   #  parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand la camera associee a la visu change
   #------------------------------------------------------------
   proc addCameraListener { visuNo cmd } {
      variable private

      trace add execution ::confVisu::setCamera  leave $cmd
   }

   #------------------------------------------------------------
   # removeCameraListener
   #    supprime une procedure a appeler si on change de camera
   #  parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand la camera associee a la visu change
   #------------------------------------------------------------
   proc removeCameraListener { visuNo cmd } {
      variable private

      trace remove execution ::confVisu::setCamera leave $cmd
   }

   #------------------------------------------------------------
   # addFileNameListener
   #   ajoute une procedure a appeler si on change de nom de fichier image
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le fichier change
   #------------------------------------------------------------
   proc addFileNameListener { visuNo cmd } {
      variable private

      ##trace add execution ::confVisu::setFileName leave $cmd
      trace add variable ::confVisu::private($visuNo,lastFileName) write $cmd
   }

   #------------------------------------------------------------
   # removeFileNameListener
   #   supprime une procedure a appeler si on change de nom de fichier image
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le fichier change
   #------------------------------------------------------------
   proc removeFileNameListener { visuNo cmd } {
      variable private

      ###trace remove execution ::confVisu::setFileName leave $cmd
      trace remove variable ::confVisu::private($visuNo,lastFileName) write $cmd
   }

   #------------------------------------------------------------
   # addMirrorListener
   #    ajoute une procedure a appeler si on change de mirroir
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le zoom change
   #------------------------------------------------------------
   proc addMirrorListener { visuNo cmd } {
      variable private

      trace add execution ::confVisu::setMirrorX leave $cmd
      trace add execution ::confVisu::setMirrorY leave $cmd
   }

   #------------------------------------------------------------
   # removeMirrorListener
   #   supprime une procedure a appeler si on change de mirroir
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le fichier change
   #------------------------------------------------------------
   proc removeMirrorListener { visuNo cmd } {
      variable private

      trace remove execution ::confVisu::setMirrorX leave $cmd
      trace remove execution ::confVisu::setMirrorY leave $cmd
   }

   #------------------------------------------------------------
   # addSubWindowListener
   #    ajoute une procedure a appeler si on change le fenetrage
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le zoom change
   #------------------------------------------------------------
   proc addSubWindowListener { visuNo cmd } {
      variable private

      trace add execution ::confVisu::setWindow leave $cmd
   }

   #------------------------------------------------------------
   # removeSubWindowListener
   #   supprime une procedure a appeler si on change le fenetrage
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le zoom change
   #------------------------------------------------------------
   proc removeSubWindowListener { visuNo cmd } {
      variable private

      trace remove execution ::confVisu::setWindow leave $cmd
   }

   #------------------------------------------------------------
   # addZoomListener
   #    ajoute une procedure a appeler si on change de zoom
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le zoom change
   #------------------------------------------------------------
   proc addZoomListener { visuNo cmd } {
      variable private

      trace add execution ::confVisu::setZoom  leave $cmd

   }

   #------------------------------------------------------------
   # removeZoomListener
   #   supprime une procedure a appeler si on change de camera
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le zoom change
   #------------------------------------------------------------
   proc removeZoomListener { visuNo cmd } {
      variable private

      trace remove execution ::confVisu::setZoom  leave $cmd
   }

   #------------------------------------------------------------
   #  stopTool
   #     arrete l'outil courant
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable private

      if { $private($visuNo,currentTool) != "" } {
         $private($visuNo,currentTool)::stopTool $visuNo
      }
   }

   #------------------------------------------------------------
   #  selectTool
   #     arrete l'outil courant si le nouvel outil n'a pas la prop display=window"
   #     demarre le nouvel outil
   #  parametres :
   #    visuNo: numero de la visu
   #    toolName : nom de l'outil a lancer
   #  Remarque:
   #    si toolName="" , alors l'outil courant est arrete. Aucun autre outil n'est pas demarré.
   #------------------------------------------------------------
   proc selectTool { visuNo toolName } {
      variable private

      #--- j'arrete l'outil deja present
      if { "$private($visuNo,currentTool)" != "" } {
         #--- Cela veut dire qu'il y a deja un outil selectionne
         if { "$private($visuNo,currentTool)" != "$toolName" } {
            if { $toolName != "" } {
               if { [$toolName\::getPluginProperty "display" ] != "window"
                  && [$private($visuNo,currentTool)::getPluginProperty "display" ] != "window" } {
                  #--- Cela veut dire que l'utilisateur selectionne un nouvel outil
                  stopTool $visuNo
               }
            } else {
               #--- Cela veut dire que l'utilisateur veut arreter l'outil en cours
               stopTool $visuNo
            }
         }
      }

      if { $toolName != "" } {
         #--- je verifie que l'outils a deja une instance cree
         if { [lsearch -exact $private($visuNo,pluginInstanceList) $toolName ] == -1 } {
            #--- je cree une instance de l'outil
            set catchResult [catch {
               namespace inscope $toolName createPluginInstance $private($visuNo,This) $visuNo
            }]
            if { $catchResult == 1 } {
               ::console::affiche_erreur "$::errorInfo\n"
               tk_messageBox -message "$::errorInfo. See console" -icon error
               return
            }
            #--- j'ajoute cette intance dans la liste
            lappend private($visuNo,pluginInstanceList) $toolName
         }
         #--- je demarre l'outil
         namespace inscope $toolName startTool $visuNo

         #--- je memorise le nom de l'outil en cours d'execution
         if { [$toolName\::getPluginProperty "display" ] != "window" } {
            set private($visuNo,currentTool) $toolName
         }
      } else {
         set private($visuNo,currentTool) ""
      }
   }

   #------------------------------------------------------------
   #  getBase
   #     retourne le chemin de la toplevel de la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getBase { visuNo } {
      variable private

      #--- je teste l'existance de la variable au cas ou la visu n'existe pas
      if { [ info exists private($visuNo,This) ] == "1" } {
         return $private($visuNo,This)
      } else {
         error "Visu$visuNo does not exit."
      }
   }

   #------------------------------------------------------------
   #  getFileName
   #     retourne le nom du fichier courant
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getFileName { visuNo } {
      variable private

      return "$private($visuNo,lastFileName)"
   }

   #------------------------------------------------------------
   #  getTool
   #     retourne  le nom de l'outil courant
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getTool { visuNo } {
      variable private

      return [ string trimleft $private($visuNo,currentTool) "::" ]
   }

   #------------------------------------------------------------
   #  getZoom
   #     retourne  la valeur du zoom
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getZoom { visuNo } {
      variable private

      return $private($visuNo,zoom)
   }

   #------------------------------------------------------------
   #  createToplevel
   #     cree une fentetre toplevel avec le canvas et la frame de seuils
   #     le numero de visu est copie dans son attribut "class"
   #  parametres :
   #     visuNo  : numero de la visu associee
   #     This    : chemin de la toplevel
   #  retour
   #
   #------------------------------------------------------------
   proc createToplevel { visuNo This } {
      global conf
      global audace
      global caption

      toplevel $This
      wm geometry $This $conf(audace,visu$visuNo,wmgeometry)
      wm maxsize $This [winfo screenwidth .] [winfo screenheight .]
      wm minsize $This 320 240
      wm resizable $This 1 1
      wm deiconify $This
      wm title $This "$caption(audace,titre) (visu$visuNo)"
      wm protocol $This WM_DELETE_WINDOW "::confVisu::close $visuNo"
      update
   }

   #------------------------------------------------------------
   #  createDialog
   #     cree une fentetre toplevel avec le canvas et la frame de seuils
   #
   #  parametres :
   #     visuNo  : numero de la visu associee
   #     This    : chemin de la toplevel contenant la dialog
   #  retour
   #     null
   #------------------------------------------------------------
   proc createDialog { visuNo This } {
      variable private
      global conf
      global audace
      global caption
      global color

      #---
      frame $This.fra1 -borderwidth 2 -cursor arrow -relief groove

         button $This.fra1.but_seuils_auto -text "$caption(confVisu,seuil_auto)" \
            -command "::confVisu::onCutLabelLeftClick $visuNo" -width 5
         grid configure $This.fra1.but_seuils_auto -column 0 -row 0 -rowspan 2 -sticky we -in $This.fra1 -padx 5

         button $This.fra1.but_config_glissieres -text "$caption(confVisu,boite_seuil)" \
            -command "::seuilWindow::run $::confVisu::private($visuNo,This) $visuNo"
         grid configure $This.fra1.but_config_glissieres -column 1 -row 0 -rowspan 2 -sticky {} -in $This.fra1 -padx 5

         scale $This.fra1.sca1 -orient horizontal -to 32767 -from -32768 -length 150 \
            -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
            -background $audace(color,cursor_blue) -activebackground $audace(color,cursor_blue_actif) -relief raised
         grid configure $This.fra1.sca1 -column 2 -row 0 -sticky we -in $This.fra1 -pady 2

         scale $This.fra1.sca2 -orient horizontal -to 32767 -from -32768 -length 150 \
            -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
            -background $audace(color,cursor_blue) -activebackground $audace(color,cursor_blue_actif) -relief raised
         grid configure $This.fra1.sca2 -column 2 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.lab1 -width 10 -text "$caption(confVisu,seuil_haut)" -font $audace(font,arial_8_n)
         grid configure $This.fra1.lab1 -column 3 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.lab2 -width 10 -text "$caption(confVisu,seuil_bas)" -font $audace(font,arial_8_n)
         grid configure $This.fra1.lab2 -column 3 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labURLX -width 16 -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(confVisu,X) $caption(confVisu,egale) $caption(confVisu,tiret)"
         grid configure $This.fra1.labURLX -column 4 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labURLY -width 16 -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(confVisu,Y) $caption(confVisu,egale) $caption(confVisu,tiret)"
         grid configure $This.fra1.labURLY -column 4 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labI -width 19 -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(confVisu,I) $caption(confVisu,egale) $caption(confVisu,tiret)"
         grid configure $This.fra1.labI -column 5 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labTime -width 19 -font $audace(font,arial_8_n) -anchor w \
            -textvariable "audace(tu,format,dmyhmsint)"
         grid configure $This.fra1.labTime -column 5 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labCam_labURL -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(audace,menu,camera)" -fg $color(blue)
         grid configure $This.fra1.labCam_labURL -column 6 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labCam_name_labURL -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(confVisu,2points) $caption(confVisu,non_connecte)" -fg $color(blue)
         grid configure $This.fra1.labCam_name_labURL -column 7 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labTel_labURL -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(audace,menu,monture)" -fg $color(blue)
         grid configure $This.fra1.labTel_labURL -column 6 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labTel_name_labURL -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(confVisu,2points) $caption(confVisu,non_connecte)" -fg $color(blue)
         grid configure $This.fra1.labTel_name_labURL -column 7 -row 1 -sticky we -in $This.fra1 -pady 2

      pack $This.fra1 -anchor center -expand 0 -fill x -side bottom

      grid columnconfigure $This.fra1 5 -weight 1

      #--- Canvas de dessin de l'image
      Scrolled_Canvas $This.can1 -borderwidth 0 -relief flat \
         -width 300 -height 200 -scrollregion {0 0 0 0} -cursor crosshair
      pack $This.can1 -in $This -anchor center -expand 1 -fill both -side right
      $This.can1.canvas configure -borderwidth 0
      $This.can1.canvas configure -relief flat

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

   }

   #------------------------------------------------------------
   #  createBindDialog
   #     cree les bind de la fenetre
   #
   #  parametres :
   #     visuNo : numero de la visu
   #------------------------------------------------------------
   proc createBindDialog { visuNo } {
      variable private

      set This $private($visuNo,This)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- bind des labels des seuils
      bind $This.fra1.lab1 <ButtonPress-1> "::confVisu::onCutLabelLeftClick   $visuNo"
      bind $This.fra1.lab2 <ButtonPress-1> "::confVisu::onCutLabelLeftClick   $visuNo"
      bind $This.fra1.lab1 <ButtonPress-3> "::confVisu::onCutLabelRightClick  $visuNo"
      bind $This.fra1.lab2 <ButtonPress-3> "::confVisu::onCutLabelRightClick  $visuNo"

      #--- bind du label des intensites
      bind $This.fra1.labI <ButtonPress-1> "::confVisu::changeDisplayIntensity $visuNo"

      #--- Raccourci pour affichage du reticule
      bind $This <Key-C> "::confVisu::toggleCrosshair $visuNo"
      bind $This <Key-c> "::confVisu::toggleCrosshair $visuNo"

      #--- bind des glissieres
      $This.fra1.sca1 configure -command "::confVisu::onHiCutCommand $visuNo"
      $This.fra1.sca2 configure -command "::confVisu::onLoCutCommand $visuNo"
      bind $This.fra1.sca1 <ButtonRelease> "::confVisu::onCutScaleRelease $visuNo"
      bind $This.fra1.sca2 <ButtonRelease> "::confVisu::onCutScaleRelease $visuNo"

      #--- bind du canvas avec la souris, j'ative les valeurs par defaut
      createBindCanvas $visuNo <ButtonPress-1>   "default"
      createBindCanvas $visuNo <ButtonRelease-1> "default"
      createBindCanvas $visuNo <B1-Motion>       "default"
      createBindCanvas $visuNo <Motion>          "default"
      createBindCanvas $visuNo <ButtonPress-3>   "default"

      #--- bind pour l'ouverture de la boite de configuration des cameras
      bind $This.fra1.labCam_labURL <ButtonPress-1> {
         ::confCam::run
     }
      bind $This.fra1.labCam_name_labURL <ButtonPress-1> {
         ::confCam::run
      }

      #--- bind pour l'ouverture de la boite de configuration des montures
      bind $This.fra1.labTel_labURL <ButtonPress-1> {
         ::confTel::run
      }
      bind $This.fra1.labTel_name_labURL <ButtonPress-1> {
         ::confTel::run
      }

   }

   #------------------------------------------------------------
   #  deleteBindDialog
   #     supprime les bind de la fenetre
   #
   #  parametres :
   #     visuNo : numero de la visu
   #------------------------------------------------------------
   proc deleteBindDialog { visuNo } {
      variable private

      set This $private($visuNo,This)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- bind des labels des seuils
      bind $This.fra1.lab1 <ButtonPress-1> ""
      bind $This.fra1.lab2 <ButtonPress-1> ""
      bind $This.fra1.lab1 <ButtonPress-3> ""
      bind $This.fra1.lab2 <ButtonPress-3> ""

      #--- Raccourci pour affichage du reticule
      bind $This <Key-C> ""
      bind $This <Key-c> ""

      #--- bind des glissieres
      bind $This.fra1.sca1 <ButtonRelease> ""
      bind $This.fra1.sca2 <ButtonRelease> ""

      #--- bind du canvas avec la souris
      createBindCanvas $visuNo <ButtonPress-1>   ""
      createBindCanvas $visuNo <ButtonRelease-1> ""
      createBindCanvas $visuNo <B1-Motion>       ""
      createBindCanvas $visuNo <Motion>          ""
      createBindCanvas $visuNo <ButtonPress-3>   ""

      #--- bind pour l'ouverture de la boite de configuration des cameras
      bind $This.fra1.labCam_name_labURL <ButtonPress-1> ""
      bind $This.fra1.labCam_labURL <ButtonPress-1>      ""

      #--- bind pour l'ouverture de la boite de configuration des montures
      bind $This.fra1.labTel_name_labURL <ButtonPress-1> ""
      bind $This.fra1.labTel_labURL <ButtonPress-1>      ""

   }

   #------------------------------------------------------------
   #  createBindCanvas
   #     associe un evenement du canvas avec une commande
   #
   #  parametres :
   #     visuNo : numero de la visu
   #     sequence : evenement associe
   #     command  : command a executer si command="default"
   #                alors c'est la commande par defaut qui est associe
   #------------------------------------------------------------
   proc createBindCanvas { visuNo sequence { command "default" } } {
      variable private

      if { "$command" == "default" } {
         switch -exact $sequence {
            <ButtonPress-1> {
               bind $private($visuNo,hCanvas) <ButtonPress-1>   "::confVisu::onPressButton1 $visuNo %x %y"
            }
            <ButtonRelease-1> {
               bind $private($visuNo,hCanvas) <ButtonRelease-1> "::confVisu::onReleaseButton1 $visuNo %x %y"
            }
            <B1-Motion> {
               bind $private($visuNo,hCanvas) <B1-Motion>       "::confVisu::onMotionButton1 $visuNo %x %y"
            }
            <Motion> {
               bind $private($visuNo,hCanvas) <Motion>          "::confVisu::onMotionMouse $visuNo %x %y"
            }
            <ButtonPress-3> {
               bind $private($visuNo,hCanvas) <ButtonPress-3>   "::confVisu::showPopupMenu $visuNo %X %Y"
            }
         }
      }  else {
         bind $private($visuNo,hCanvas) $sequence "$command"
      }
   }

   proc createMenu { visuNo } {
      variable private
      global audace
      global conf
      global caption
      global panneau

      set This $private($visuNo,This)
      set bufNo [ visu$visuNo buf ]

      set private($visuNo,menu) "$This.menubar"

      Menu_Setup $visuNo $private($visuNo,menu)

      Menu           $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,charger)..." \
         "::audace::charger $visuNo "
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,enregistrer)" \
         "::audace::enregistrer $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,enregistrer_sous)..." \
         "::audace::enregistrer_sous $visuNo"

      Menu_Separator $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,entete)" " ::keyword::header $visuNo "

      Menu_Separator $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo  "$caption(audace,menu,fichier)" "$caption(confVisu,fermer)" \
         " ::confVisu::close $visuNo "

      Menu           $visuNo "$caption(audace,menu,affichage)"

      Menu_Command   $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,nouvelle_visu)" ::confVisu::create
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_grise)" \
              "1" "conf(visu_palette,visu$visuNo,mode)" " ::audace::MAJ_palette $visuNo "
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_inverse)" \
              "2" "conf(visu_palette,visu$visuNo,mode)" " ::audace::MAJ_palette $visuNo "
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_iris)" \
              "3" "conf(visu_palette,visu$visuNo,mode)" " ::audace::MAJ_palette $visuNo "
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_arc_en_ciel)" \
              "4" "conf(visu_palette,visu$visuNo,mode)" " ::audace::MAJ_palette $visuNo "
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Cascade $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,fcttransfert_titre)"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_lin)" \
              "1" "conf(fonction_transfert,visu$visuNo,mode)" " ::audace::fonction_transfert $visuNo "
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_log)" \
              "2" "conf(fonction_transfert,visu$visuNo,mode)" " ::audace::fonction_transfert $visuNo "
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_exp)" \
              "3" "conf(fonction_transfert,visu$visuNo,mode)" " ::audace::fonction_transfert $visuNo "
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_arc)" \
              "4" "conf(fonction_transfert,visu$visuNo,mode)" " ::audace::fonction_transfert $visuNo "
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,seuils)..." \
              "::seuilWindow::run $This $visuNo"

      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,zoom) $caption(audace,menu,zoom_0.125)" "0.125" \
              "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,zoom) $caption(audace,menu,zoom_0.25)" "0.25" \
              "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,zoom) $caption(audace,menu,zoom_0.5)" "0.5" \
              "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,zoom) $caption(audace,menu,zoom_1)" "1" \
              "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,zoom) $caption(audace,menu,zoom_2)" "2" \
              "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,zoom) $caption(audace,menu,zoom_4)" "4" \
              "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"

      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Check $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,plein_ecran)" \
               "::confVisu::private($visuNo,fullscreen)" "::confVisu::setFullScreen $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"

      Menu_Check $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,miroir_x)" \
              "::confVisu::private($visuNo,mirror_x)" "::confVisu::setMirrorX $visuNo"
      Menu_Check $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,miroir_y)" \
              "::confVisu::private($visuNo,mirror_y)" "::confVisu::setMirrorY $visuNo"
      Menu_Check $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,window)" \
              "::confVisu::private($visuNo,window)" "::confVisu::setWindow $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"

      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
         "$caption(audace,menu,vision_nocturne)" "1" "conf(confcolor,menu_night_vision)" \
         "::confColor::switchDayNight ; \
            if { [ winfo exists $audace(base).select_color ] } { \
               destroy $audace(base).select_color \
               ::confColor::run $visuNo\
            } \
         "
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"

      Menu_Command   $visuNo "$caption(audace,menu,affichage)" "[::Crosshair::getLabel]..." \
              "::Crosshair::run $visuNo"

      Menu           $visuNo "$caption(audace,menu,analyse)"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,histo)" "::audace::Histo $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,coupe)" "::sectiongraph::init $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,statwin)" "statwin $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,fwhm)" "fwhm $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,fitgauss)" "fitgauss $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,centro)" "center $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,phot)" "photom $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,subfitgauss)" "subfitgauss $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,scar)" "scar $visuNo"

      Menu           $visuNo "$caption(audace,menu,outils)"
      Menu_Command   $visuNo "$caption(audace,menu,outils)" "$caption(audace,menu,pas_outil)" "::confVisu::stopTool $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,outils)"
      #--- Remplissage du menu deroulant outils
      set liste ""
      foreach m [array names panneau menu_name,*] {
         lappend liste [list "$panneau($m) " $m]
      }
      set firstTool ""
      set liste [lsort $liste]
      foreach m $liste {
         set m [lindex $m 1]
         scan "$m" "menu_name,%s" pluginName
         if { [ ::$pluginName\::getPluginProperty "multivisu" ] == "1" } {
            if { $firstTool == "" } {
               set firstTool $pluginName
               #--- Lancement automatique du premier outil de la liste
               ::confVisu::selectTool $visuNo ::$firstTool
            }
            Menu_Command $visuNo "$caption(audace,menu,outils)" "$panneau($m)" "::confVisu::selectTool $visuNo ::$pluginName"
         }
      }

   }

   proc cursor { visuNo curs } {
      variable private

      $private($visuNo,hCanvas) configure -cursor $curs
   }

   proc bg { coul } {
      variable private

      $private($visuNo,hCanvas) configure -background $coul
   }

   #
   # ::confVisu::screen2Canvas
   # Transforme des coordonnees ecran en coordonnees canvas
   # L'argument est une liste de deux entiers, et retourne egalement une liste de deux entiers
   #
   proc screen2Canvas { visuNo coord } {
      variable private

      scan [$private($visuNo,hCanvas) canvasx [lindex $coord 0]] "%d" xx
      scan [$private($visuNo,hCanvas) canvasy [lindex $coord 1]] "%d" yy
      return [list $xx $yy]
   }

   #
   # ::confVisu::canvas2Picture coord {stick left}
   # Transforme des coordonnees canvas en coordonnees image
   # L'argument est une liste de deux entiers, et retourne egalement une liste de deux entiers
   # Les coordonnees canvas commencent a 0,0 dans le coin superieur gauche de l'image
   # Les coordonnees image  commencent a 1,1 dans le coin inferieur gauche de l'image
   # En passant un argument <> de left pour stick, calcule les coordonnees par arrondi superieur
   #
   proc canvas2Picture { visuNo coord { stick left } } {
      variable private

      set zoom   [visu$visuNo zoom]
      set window [visu$visuNo window]
      set bufNo  [visu$visuNo buf]
      set height $private($visuNo,picture_h)

      if {$window=="full"} {
         set x0 1
         set y0 1
         set x1 $private($visuNo,picture_w)
         set y1 $private($visuNo,picture_h)
      } else {
         set x0 [lindex $window 0]
         set y0 [lindex $window 1]
         set x1 [lindex $window 2]
         set y1 [lindex $window 3]
      }

      if { $private($visuNo,mirror_x) == 1 } {
         lset coord 0 [ expr ($x1 - $x0)*$zoom - [lindex $coord 0] ]
      }
      if { $private($visuNo,mirror_y) == 1 } {
         lset coord 1 [ expr ($y1 - $y0 )*$zoom - [lindex $coord 1] ]
      }

      if {$zoom >= 1} {
         set xx [expr [lindex $coord 0] / $zoom + $x0]
         set yy [expr $y1 - [lindex $coord 1] / $zoom ]
      } else {
         if {$stick == "left"} {
            #--- Ce calcul sert a obtenir la borne inferieure en cas de sous-echantillonnage
            set xx [expr int([lindex $coord 0] / $zoom  + 1 + $x0)]
            set yy [expr int($y1 - ([lindex $coord 1] + 1) / $zoom + 1 )]
         } else {
            #--- Alors que ce calcul sert a obtenir la borne superieure en cas de sous-echantillonnage
            set xx [expr int(([lindex $coord 0] + 1) / $zoom  + $x0)]
            set yy [expr int($y1 - [lindex $coord 1] / $zoom )]
         }
      }

      if { $private($visuNo,applyThickness) == 1 } {
         set yy 1
      }

      return [list $xx $yy]
   }

   #
   # ::confVisu::picture2Canvas coord
   # Transforme des coordonnees image en coordonnees canvas
   # L'argument est une liste de deux entiers, et retourne egalement une liste de deux entiers
   #
   #
   proc picture2Canvas { visuNo coord } {
      variable private

      set zoom   [visu$visuNo zoom]
      set height $private($visuNo,picture_h)

      #--- je prend en compte le fenetrage
      set windowBox  [visu$visuNo window]
      if {$windowBox=="full"} {
         set x0 1
         set y0 1
         set x1 $private($visuNo,picture_w)
         set y1 $private($visuNo,picture_h)
      } else {
         set x0 [lindex $windowBox 0]
         set y0 [lindex $windowBox 1]
         set x1 [lindex $windowBox 2]
         set y1 [lindex $windowBox 3]
      }

      #--- j'applique le zoom et j'inverse l'axe Y
      set xx [ expr int(( [lindex $coord 0] - $x0)*$zoom) ]
      set yy [ expr int(( $y1 -[lindex $coord 1] )*$zoom) ]

      #--- j'applique le mirroir sur l'axe x
      if { $private($visuNo,mirror_x) == 1 } {
         set xx [ expr ($x1 -$x0 +1)*$zoom - $xx ]
      }

      #--- j'applique le mirroir sur l'axe y
      if { $private($visuNo,mirror_y) == 1 } {
         set yy [ expr ($y1 -$y0+1)*$zoom - $yy ]
      }

      return [list $xx $yy]
   }

   #------------------------------------------------------------
   #  onPressButton1
   #     demarre le trace de la boite
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc onPressButton1 { visuNo x y } {
      variable private
      global caption

      if { [string compare $::confVisu::private($visuNo,MouseState) rien] == 0 } {
         set bufNo [visu$visuNo buf]
         set liste [::confVisu::screen2Canvas $visuNo [list $x $y]]
         if {[ buf$bufNo imageready ] == "1" } {
            set zoom   $private($visuNo,zoom)
            set width  $::confVisu::private($visuNo,picture_w)
            set height $::confVisu::private($visuNo,picture_h)
            set wz [expr $width * $zoom]
            set hz [expr $height * $zoom]
            if {[lindex $liste 0]<$wz && [lindex $liste 1]<$hz} {
               ::confVisu::boxBegin $visuNo [list $x $y]
               set ::confVisu::private($visuNo,MouseState) dragging
            }
         }
      } else {
         if { [string compare $::confVisu::private($visuNo,MouseState) context] == 0 } {
            [MenuGet $visuNo "$caption(audace,menu,affichage)"] unpost
            set ::confVisu::private($visuNo,MouseState) rien
         }
      }
   }

   #------------------------------------------------------------
   #  onMotionButton1
   #     redessine la boite en suivant le deplacement de la souris
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc onMotionButton1 { visuNo x y } {
      variable private

      if { [string compare $::confVisu::private($visuNo,MouseState) dragging] == 0 } {
         #--- Affichage des coordonnees
         ::confVisu::displayCursorCoord $visuNo [list $x $y]
         #--- On n'oublie pas de dragger eventuellement la fenetre
         ::confVisu::boxDrag $visuNo [list $x $y]
      }
   }

   proc onReleaseButton1 { visuNo x y } {
      variable private

      if { [string compare $private($visuNo,MouseState) dragging] == 0 } {
         set private($visuNo,MouseState) rien
         catch { ::confVisu::boxEnd $visuNo [list $x $y] }
      }
   }

   proc showPopupMenu { visuNo X Y } {
      variable private
      global audace
      global caption

      if { $visuNo == 1 } {
         set menuName "$caption(audace,menu,analyse)"
      } else {
         set menuName "$caption(audace,menu,analyse)"
      }

      if { [string compare $::confVisu::private($visuNo,MouseState) rien] == 0 } {
         [MenuGet $visuNo $menuName] post $X $Y
         set ::confVisu::private($visuNo,MouseState) context
      } else {
         if { [string compare $::confVisu::private($visuNo,MouseState) context] == 0 } {
            [MenuGet $visuNo $menuName] unpost
            set ::confVisu::private($visuNo,MouseState) rien
         }
      }
   }

   #------------------------------------------------------------
   #  onMotionMouse
   #     affiche les cordonnees et l'intensite du pixel pointe par la souris
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc onMotionMouse { visuNo x y } {
      #--- Affichage des coordonnees
      ::confVisu::displayCursorCoord $visuNo [list $x $y]
   }

   #------------------------------------------------------------
   #  displayCursorCoord
   #     affiche les cordonnees et l'intensite du pixel pointe par la souris
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc displayCursorCoord { visuNo coord } {
      variable private
      global caption

      #--- Transformation des coordonnees ecran en coordonnees image
      set coord [ ::confVisu::canvas2Picture $visuNo [ ::confVisu::screen2Canvas $visuNo $coord ] ]
      set xc [lindex $coord 0 ]
      set yc [lindex $coord 1 ]

      set windowBox [visu$visuNo window]
      if {$windowBox=="full"} {
         set x0 1
         set y0 1
         set x1 $private($visuNo,picture_w)
         set y1 $private($visuNo,picture_h)
      } else {
         set x0 [lindex $windowBox 0]
         set y0 [lindex $windowBox 1]
         set x1 [lindex $windowBox 2]
         set y1 [lindex $windowBox 3]
      }

      set This $private($visuNo,This)
      set bufNo [visu$visuNo buf]

      #--- j'affiche les coordonnees si le curseur de la souris est a l'interieur de la fenetre
      if { $xc < $x0 || $xc > $x1 || $yc < $y0 || $yc >$y1 } {
         set xi "$caption(confVisu,tiret)"
         set yi "$caption(confVisu,tiret)"
         set intensite "$caption(confVisu,I) $caption(confVisu,egale) $caption(confVisu,tiret)"
      } else {
         #--- xi et yi sont des 'coordonnees-buffer'
         set xi $xc
         set yi $yc
         #--- si le buffer ne contient qu'une ligne , j'affiche l'intensite de
         #--- cette ligne quelque soit la position verticale du curseur de la
         #--- souris dans l'image car c'est la meme valeur sur toute la colonne
         if { [buf$bufNo getpixelsheight]==1 } {
            set yii 1
         } else {
            set yii $yi
         }
         #--- ii contiendra l'intensite du pixel pointe
         set result [catch { set ii [ buf$bufNo getpix [ list $xi $yii ] ] } ]
         if { $result == 0 } {
            if { $private($visuNo,intensity) == "1" } {
               if { [ lindex $ii 0 ] == "1" } {
                  set intensite "$caption(confVisu,I) $caption(confVisu,egale) [ lindex $ii 1 ]"
               } elseif { [ lindex $ii 0 ] == "3" } {
                  set intensite "$caption(confVisu,rouge)[ lindex $ii 1 ] $caption(confVisu,vert)[ lindex $ii 2 ] $caption(confVisu,bleu)[ lindex $ii 3 ]"
               }
            } elseif { $private($visuNo,intensity) == "0" } {
               if { [ lindex $ii 0 ] == "1" } {
                  set intensite "$caption(confVisu,I) $caption(confVisu,egale) [ string trimleft [ format "%8.0f" [ lindex $ii 1 ] ] " " ]"
               } elseif { [ lindex $ii 0 ] == "3" } {
                  set intensite "$caption(confVisu,rouge)[ string trimleft [ format "%8.0f" [ lindex $ii 1 ] ] " " ] \
                     $caption(confVisu,vert)[ string trimleft [ format "%8.0f" [ lindex $ii 2 ] ] " " ] \
                     $caption(confVisu,bleu)[ string trimleft [ format "%8.0f" [ lindex $ii 3 ] ] " " ]"
               }
            }
         } else {
            #--- je traite le cas ou la taille de l'image a ete changee dans le buffer et que
            #--- et que les variables private($visuNo,picture_w) et private($visuNo,picture_w)
            #--- ne sont pas enore à jour (par exemple acquisition en cours avec une camera)
            set xi "$caption(confVisu,tiret)"
            set yi "$caption(confVisu,tiret)"
            set intensite "$caption(confVisu,I) $caption(confVisu,egale) $caption(confVisu,tiret)"
         }
      }

      #--- Affichage a l'ecran
      if { $private($visuNo,labcoord_type) == "xy" } {
         $This.fra1.labURLX configure -text "$caption(confVisu,X) $caption(confVisu,egale) $xi"
         $This.fra1.labURLY configure -text "$caption(confVisu,Y) $caption(confVisu,egale) $yi"
         $This.fra1.labI configure -text "$intensite"
      } else {
         if { $xi != "$caption(confVisu,tiret)" } {
            set result [catch { set temp [ buf$bufNo xy2radec [ list $xi $yi ] ] } ]
            if { $result == 1 } {
               #--- en cas d'erreur de conversion, je reviens en coordonnees xy
               set private($visuNo,labcoord_type) "xy"
               return
            }
            $This.fra1.labURLX configure -text "$caption(confVisu,RA) $caption(confVisu,egale) [ mc_angle2hms [ lindex $temp 0 ] 360 zero 1 auto string ]"
            $This.fra1.labURLY configure -text "$caption(confVisu,DEC) $caption(confVisu,egale) [ mc_angle2dms [ lindex $temp 1 ] 90 zero 0 + string ]"
         } else {
            $This.fra1.labURLX configure -text "$caption(confVisu,RA) $caption(confVisu,egale) $caption(confVisu,tiret)"
            $This.fra1.labURLY configure -text "$caption(confVisu,DEC) $caption(confVisu,egale) $caption(confVisu,tiret)"
         }
         $This.fra1.labI configure -text "$intensite"
      }
   }

   #------------------------------------------------------------
   #  getBox
   #     retourne les coordonnees de la boite (coordonnees dans le
   #     buffer) si elle existe, sinon retourne une chaine vide
   #  parametres :
   #     visuNo : numero de la visu
   #------------------------------------------------------------
   proc getBox { { visuNo } } {
      variable private

      return $private($visuNo,boxSize)
   }

   #------------------------------------------------------------
   #  getCanvas
   #     retourne le nom du canvas (chemin TK)
   #  parametres :
   #     visuNo : numero de la visu
   #------------------------------------------------------------
   proc getCanvas { visuNo } {
      variable private

      return $private($visuNo,hCanvas)
   }

   #------------------------------------------------------------
   #  boxBegin
   #     demarre le trace de la boite
   #     et memorise les coordonnees de la souris dans private($visuNo,box_1)
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc boxBegin { visuNo coord } {
      variable private

      set private($visuNo,box_1) [ screen2Canvas $visuNo $coord ]
      deleteBox $visuNo
   }

   #------------------------------------------------------------
   #  boxEnd
   #     redessine la boite en suivant le deplacement de la souris
   #     et enregistre les coordonnees de la boite dans private($visuNo,boxSize)
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc boxEnd { visuNo coord } {
      variable private
      global audace

      ::confVisu::boxDrag $visuNo $coord
      if { $private($visuNo,box_1) == $private($visuNo,box_2) } {
         deleteBox $visuNo
      } else {
         if {[lindex $private($visuNo,box_1) 0] > [lindex $private($visuNo,box_2) 0]} {
            set x1 [lindex $private($visuNo,box_2) 0]
            set x2 [lindex $private($visuNo,box_1) 0]
         } else {
            set x1 [lindex $private($visuNo,box_1) 0]
            set x2 [lindex $private($visuNo,box_2) 0]
         }
         if {[lindex $private($visuNo,box_1) 1] < [lindex $private($visuNo,box_2) 1]} {
            #--- !! Le test est inverse car l'origine en canvas est en haut !!
            set y1 [lindex $private($visuNo,box_2) 1]
            set y2 [lindex $private($visuNo,box_1) 1]
         } else {
            set y1 [lindex $private($visuNo,box_1) 1]
            set y2 [lindex $private($visuNo,box_2) 1]
         }
         set coord1 [::confVisu::canvas2Picture $visuNo [list $x1 $y1]]
         set coord2 [::confVisu::canvas2Picture $visuNo [list $x2 $y2] -right ]

         if {[lindex $coord1 0] < [lindex $coord2 0]} {
            set x1 [lindex $coord1 0]
            set x2 [lindex $coord2 0]
         } else {
            set x1 [lindex $coord2 0]
            set x2 [lindex $coord1 0]
         }

         if {[lindex $coord1 1] < [lindex $coord2 1]} {
            set y1 [lindex $coord1 1]
            set y2 [lindex $coord2 1]
         } else {
            set y1 [lindex $coord2 1]
            set y2 [lindex $coord1 1]
         }
         set private($visuNo,boxSize) [list $x1 $y1 $x2 $y2]
      }
   }

   #------------------------------------------------------------
   #  boxDrag
   #     redessine la boite en suivant le deplacement de la souris
   #     et memorise les coordonnees de la souris dans private($visuNo,box_2)
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc boxDrag { visuNo coord } {
      variable private
      global audace

      set zoom  $private($visuNo,zoom)
      set bufNo [visu$visuNo buf]
      set width  $private($visuNo,picture_w)
      set height $private($visuNo,picture_h)

      set wz [expr $width * $zoom]
      set hz [expr $height * $zoom]

      if { $private($visuNo,hBox) != "" } {
         $private($visuNo,hCanvas) delete $private($visuNo,hBox)
      }
      set x [lindex $coord 0]
      if {$x<0} {set coord [lreplace $coord 0 0 0]}
      if {$x>=$wz} {
         set coord [lreplace $coord 0 0 [expr $wz-1]]
      }
      set y [lindex $coord 1]
      if {$y<0} {set coord [lreplace $coord 1 1 0]}
      if {$y>=$hz} {
         set coord [lreplace $coord 1 1 [expr $hz-1]]
      }
      set private($visuNo,box_2) [screen2Canvas $visuNo $coord]
      set private($visuNo,hBox) [eval {$private($visuNo,hCanvas) create rect} $private($visuNo,box_1) \
      $private($visuNo,box_2) -outline $audace(color,drag_rectangle) -tag selBox]
   }

   #------------------------------------------------------------
   #  deleteBox
   #     efface la boite
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc deleteBox { { visuNo "1" } } {
      variable private

      if { $private($visuNo,boxSize) != "" } {
         set private($visuNo,boxSize) ""
         $private($visuNo,hCanvas) delete $private($visuNo,hBox)
      }
   }

   #------------------------------------------------------------
   #  visuDynamix
   #      fixe les bornes des glissierres de reglage des seuils
   #------------------------------------------------------------
   proc visuDynamix { visuNo max min } {
      variable private

      $private($visuNo,This).fra1.sca1 configure -from $min -to $max
      $private($visuNo,This).fra1.sca2 configure -from $min -to $max
   }

   #------------------------------------------------------------
   #  changeDisplayIntensity
   #      affiche l'intensite (N&B) ou les intensites (RGB) en decimal ou en entier
   #------------------------------------------------------------
   proc changeDisplayIntensity { visuNo } {
      variable private

      if { $private($visuNo,intensity) == "1" } {
         set private($visuNo,intensity) "0"
      } elseif { $private($visuNo,intensity) == "0" } {
         set private($visuNo,intensity) "1"
      }
   }

   proc onCutLabelLeftClick { visuNo } {
      variable private

      if { $private($visuNo,autovisuEnCours) == "0" } {
         set private($visuNo,autovisuEnCours) "1"
         #--- Le -force permet de forcer la visu si on a choisi
         #--- dans le panneau de config "pas de recalcul automatique"
         ::confVisu::autovisu $visuNo -force
         set private($visuNo,autovisuEnCours) "0"
      }
   }

   proc onCutLabelRightClick { visuNo } {
      variable private

      ::seuilWindow::run $private($visuNo,This) $visuNo
   }

   proc index2cut { visuNo val } {
      variable private
      return [ expr $val * $private($visuNo,a) + $private($visuNo,b) ]
   }

   proc onHiCutCommand { visuNo val } {
      set new_hi_cut [ index2cut $visuNo $val ]
      #::console::affiche_resultat "onHiCutCommand: $val => $new_hi_cut\n"
      set sbh [visu$visuNo cut]
      visu$visuNo cut [list $new_hi_cut [lindex $sbh 1]]
      ChangeCutsDisplay $visuNo
   }

   proc onLoCutCommand { visuNo val } {
      set new_lo_cut [ index2cut $visuNo $val ]
      #::console::affiche_resultat "onLoCutCommand: $val => $new_lo_cut\n"
      set sbh [visu$visuNo cut]
      visu$visuNo cut [list [lindex $sbh 0] $new_lo_cut]
      ChangeCutsDisplay $visuNo
   }

   proc ChangeCutsDisplay { visuNo } {
      variable private

      set sh [lindex [visu$visuNo cut] 0]
      set sb [lindex [visu$visuNo cut] 1]
      if { [ expr abs( $sh - $sb ) ] > "$private($visuNo,intervalleSHSB)" } {
         $private($visuNo,This).fra1.lab1 configure -text [format %d [expr int($sh)]]
         $private($visuNo,This).fra1.lab2 configure -text [format %d [expr int($sb)]]
      } else {
         $private($visuNo,This).fra1.lab1 configure -text [format %.4e $sh]
         $private($visuNo,This).fra1.lab2 configure -text [format %.4e $sb]
      }
   }

   proc onCutScaleRelease { visuNo } {
      variable private

      ComputeScaleRange $visuNo
      if { [ image type image[visu$visuNo image] ] == "photo" } {
         visu$visuNo disp
      }
   }

   proc ComputeScaleRange { visuNo } {
      variable private
      global conf

      set zone(sh1) $private($visuNo,This).fra1.sca1
      set zone(sb1) $private($visuNo,This).fra1.sca2
      if { $conf(seuils,auto_manuel) == 1 } {
         #--- Calcule la nouvelle dynamique de deplacement des curseurs
         set sh [lindex [visu$visuNo cut] 0]
         set sb [lindex [visu$visuNo cut] 1]
         if {$sb<$sh} {
            set maxi $sh
            set mini $sb
         } else {
            set maxi $sb
            set mini $sh
         }
         set range [expr $maxi-$mini]
         if {$range == 0} {
            set range 1024
         }
         set private($visuNo,mincut) [ expr $mini - $conf(seuils,%_dynamique) / 100.0 * $range ]
         set private($visuNo,maxcut) [ expr $maxi + $conf(seuils,%_dynamique) / 100.0 * $range ]
         set private($visuNo,minindex) [ $private($visuNo,This).fra1.sca1 cget -from ]
         set private($visuNo,maxindex) [ $private($visuNo,This).fra1.sca1 cget -to ]

         #--- Calcul des coefficients de transformation seuil de visu = f(position):
         #---         cut = a * pos + b
         set cut_lo $private($visuNo,mincut)
         set cut_hi $private($visuNo,maxcut)
         set index_lo $private($visuNo,minindex)
         set index_hi $private($visuNo,maxindex)

         set private($visuNo,a) [ expr ( $cut_lo - $cut_hi ) / ( $index_lo - $index_hi ) ]
         set private($visuNo,b) [ expr ( $cut_lo * $index_hi - $cut_hi * $index_lo ) / ( $index_hi - $index_lo ) ]

         #--- Repositionnement des poignees a leur nouvelle position
         $private($visuNo,This).fra1.sca1 set [ expr ( $sh - $private($visuNo,b) ) / $private($visuNo,a) ]
         $private($visuNo,This).fra1.sca2 set [ expr ( $sb - $private($visuNo,b) ) / $private($visuNo,a) ]
#::console::affiche_resultat "ComputeScaleRange: sh=$sh, sb=$sb, min_index=$private($visuNo,minindex), max_index=$private($visuNo,maxindex), maxi=$maxi, mini=$mini, a=$private($visuNo,a), b=$private($visuNo,b)\n"
      } elseif { $conf(seuils,auto_manuel) == 2 } {
         $zone(sb1) configure -from $private($visuNo,mindyn) -to $private($visuNo,maxdyn)
         $zone(sh1) configure -from $private($visuNo,mindyn) -to $private($visuNo,maxdyn)
      }
   }

   #------------------------------------------------------------
   #  setCrosshair
   #  set Crosshair state
   #   state = 0 or 1
   #------------------------------------------------------------
   proc setCrosshair { visuNo state } {
      variable private

      set private($visuNo,crosshairstate) $state
      redrawCrosshair $visuNo
   }

   #------------------------------------------------------------
   #  getCrosshair
   #  returns crosshair state 1=shown 0=hidden
   #
   #------------------------------------------------------------
   proc getCrosshair { visuNo } {
      variable private

      return $private($visuNo,crosshairstate)
   }

   #------------------------------------------------------------
   #  toggleCrosshair
   #  toggle drawing/hiding Crosshair
   #  as check button state indicate
   #------------------------------------------------------------
   proc toggleCrosshair { visuNo } {
      variable private

      if { "$private($visuNo,crosshairstate)"=="0"} {
         set private($visuNo,crosshairstate) "1"
      } else {
         set private($visuNo,crosshairstate) "0"
      }
      redrawCrosshair $visuNo
   }

   #------------------------------------------------------------
   #  redrawCrosshair
   #  redraw Crosshair if image size is changed
   #------------------------------------------------------------
   proc redrawCrosshair { visuNo } {
      variable private

      #--- je masque le reticule
      hideCrosshair $visuNo
      if { "$private($visuNo,crosshairstate)" == "1" } {
         #--- j'affiche le reticule
         displayCrosshair $visuNo
      }
   }

   #--------------------------------------------------------------
   #  displayCrosshair
   #  draw Crosshair lines ( 1 horizontal line, 1 vertical line )
   #
   #--------------------------------------------------------------
   proc displayCrosshair { visuNo } {
      variable private
      global conf

      set hCanvas $private($visuNo,hCanvas)

      #--- je cree le label representant la ligne horizontale
      if { ![winfo exists $private($visuNo,hCrosshairH)] } {
         label $private($visuNo,hCrosshairH) -bg $conf(crosshair,color)
      } else {
         $private($visuNo,hCrosshairH) configure -bg $conf(crosshair,color)
      }

      #--- je cree le label representant la ligne verticale
      if { ![winfo exists $private($visuNo,hCrosshairV)] } {
         label $private($visuNo,hCrosshairV) -bg $conf(crosshair,color)
      } else {
         $private($visuNo,hCrosshairV) configure -bg $conf(crosshair,color)
      }

      #--- coordonnees du centre du reticule dans le repere canvas
      #--- attention : le reticule est centre sur l'image (pas sur le canvas)
      set xc [expr int($private($visuNo,picture_w) / 2) ]
      set yc [expr int($private($visuNo,picture_h) / 2) ]
      set centerCoord [ picture2Canvas $visuNo [list $xc $yc ] ]
      set xcCanvas [lindex $centerCoord 0]
      set ycCanvas [lindex $centerCoord 1]

      #--- longueur des traits du reticule dans le repere canvas
      #--- en fonction de la fenetre et du zoom
      set windowBox [visu$visuNo window]
      if {$windowBox=="full"} {
         set x0 1
         set y0 1
         set x1 $private($visuNo,picture_w)
         set y1 $private($visuNo,picture_h)
      } else {
         set x0 [lindex $windowBox 0]
         set y0 [lindex $windowBox 1]
         set x1 [lindex $windowBox 2]
         set y1 [lindex $windowBox 3]
      }
##::console::disp "displayCrosshair   x0=$x0 y0=$y0 x1=$x1 y1=$y1 \n"
      set coord0Canvas [ picture2Canvas $visuNo [list $x0 $y0 ] ]
      set coord1Canvas [ picture2Canvas $visuNo [list $x1 $y1 ] ]
      set widthCanvas [expr [lindex $coord1Canvas 0] - [lindex $coord0Canvas 0] + 1]
      set heightCanvas [expr [lindex $coord0Canvas 1] - [lindex $coord1Canvas 1] + 1]

      #--- j'affiche le trait horizontal du reticule s'il est a l'interieur de la fenetre
      if { $yc >= $y0 && $yc <= $y1 } {
         $hCanvas create window 1 1 -tag lineh -anchor nw -window $private($visuNo,hCrosshairH) -height 1
         $hCanvas coords lineh 0 $ycCanvas
         $hCanvas itemconfigure lineh -width $widthCanvas
         $hCanvas itemconfigure lineh -state normal
      }

      #--- j'affiche le trait vertical du reticule s'il est a l'interieur de la fenetre
      if { $xc >= $x0 && $xc <= $x1 } {
         $hCanvas create window 1 1 -tag linev -anchor nw -window $private($visuNo,hCrosshairV) -width 1
         $hCanvas coords linev $xcCanvas 0
         $hCanvas itemconfigure linev -height $heightCanvas
         $hCanvas itemconfigure linev -state normal
      }
      raise $private($visuNo,hCrosshairH)
      raise $private($visuNo,hCrosshairV)

   }

   #------------------------------------------------------------
   #  hideCrosshair
   #  hiding Crosshair lines
   #
   #------------------------------------------------------------
   proc hideCrosshair { visuNo } {
      variable private

      $private($visuNo,hCanvas) delete lineh
      $private($visuNo,hCanvas) delete linev

      if { ![winfo exists $private($visuNo,hCrosshairH)] } {
         destroy $private($visuNo,hCrosshairH)
      }
      if { ![winfo exists $private($visuNo,hCrosshairV)] } {
         destroy $private($visuNo,hCrosshairV)
      }
   }

   #------------------------------------------------------------
   #  setFileName
   #    modifie le nom du fichier courant
   #    et affiche le nom dans le titre de la fenetre
   #  parametres :
   #    visuNo : numero de la visu
   #    fileName: nom du fichier
   #------------------------------------------------------------
   proc setFileName { visuNo fileName} {
      variable private
      global caption

      #--- je mets a jour le nom du fichier dans le titre de la fenetre
      if { $fileName != "" } {
        wm title $private($visuNo,This) "$caption(audace,titre) (visu$visuNo) - $fileName"
      } else {
        wm title $private($visuNo,This) "$caption(audace,titre) (visu$visuNo)"
      }

      #--- je mets a jour le nom du fichier
      set private($visuNo,lastFileName) "$fileName"
   }

   #------------------------------------------------------------
   #  loadFile
   #    charge et affiche un fichier
   #  parametres :
   #    visuNo : numero de la visu
   #    fileName: nom du fichier
   #------------------------------------------------------------
   proc loadFile { visuNo fileName} {
      variable private

      loadima $fileName $visuNo
      autovisu $visuNo
   }

}
#--- namespace end

::confVisu::init

