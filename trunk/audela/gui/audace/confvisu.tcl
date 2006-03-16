#
# Fichier : confvisu.tcl
# Description : Gestionnaire des visu
# Auteur : Michel PUJOL
# $Id: confvisu.tcl,v 1.12 2006-03-16 22:39:13 robertdelmas Exp $

namespace eval ::confVisu {

   #--- variables locales de ce namespace
   array set private {
      driverlist     ""
   }

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
      if { ! [ info exists conf(seuils,visu$visuNo,mode) ] } {
         set conf(seuils,visu$visuNo,mode) "histoauto"
      }
      if { ! [ info exists conf(visu,crosshairstate) ] } {
         set conf(visu,crosshairstate) "0"
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
      set private($visuNo,picture_orgx)    "0"
      set private($visuNo,picture_orgy)    "0"
      set private($visuNo,labcoord_type)   "xy"
      set private($visuNo,picture_w)       "0"
      set private($visuNo,picture_h)       "0"
      set private($visuNo,autovisuEnCours) "0"
      set private($visuNo,lastFileName)    "?"
      set private($visuNo,maxdyn)          "32767"
      set private($visuNo,mindyn)          "-32768"
      set private($visuNo,crosshairstate)  $conf(visu,crosshairstate)
      set private($visuNo,menu)            ""

      #--- Initialisation de variables utilisees par les menus
      set private($visuNo,mirror_x)        "0"
      set private($visuNo,mirror_y)        "0"
      set private($visuNo,window)          "0"
      set private($visuNo,fullscreen)      "0"
      set private($visuNo,zoom)            "1"
      set private($visuNo,toolNameSpace)   ""
      set private($visuNo,box)             ""

      set private($visuNo,camNo)           "0"
      set private($visuNo,camName)         ""

      set private($visuNo,intensity)       "1"

      #--- initialisation des bind de touches et de la souris
      set private($visuNo,MouseState) rien

      #--- je cree la fenetre 
      ::confVisu::createDialog $visuNo $private($visuNo,This)

      #--- je cree le buffer
      set result [catch {::buf::create} bufNo]
      if { $result } {
         #--- je cree une exception
         error  "erreur creation buffer pour nouvelle visu\n"
      } else {
         #--- configuration buffer
         buf$bufNo extension $conf(extension,defaut)
         #--- Fichiers image compresses ou non
         if { $conf(fichier,compres) == "0" } {
            buf$bufNo compress "none"
         } else {
            buf$bufNo compress "gzip"
         }
      }

      #--- Creation de l'image associee a la visu dans le tag "display"
      $private($visuNo,hCanvas) create image 0 0 -anchor nw -tag display
      image create photo image$visuNo
      $private($visuNo,hCanvas) itemconfigure display -image image$visuNo

      #--- je cree la visu associee au buffer bufNo et a l'image image$visuNo
      set visuNo [::visu::create $bufNo $visuNo]

      #--- je cree les instances d'outil pour cette visu
      if { $base == "" } {
         #--- je charge seulement les outils qui gérent les visu multiples
         ::AcqFC::Init $private($visuNo,This) $visuNo
         ::Autoguider::Init $private($visuNo,This) $visuNo
      }

      #--- je cree le menu
      if { $base == "" } {
         ::confVisu::createMenu $visuNo
      }

      #--- je cree les bind
      ::confVisu::createBindDialog $visuNo

      return $visuNo
   }

   #------------------------------------------------------------
   #  close
   #     ferme la visu
   #------------------------------------------------------------
   proc close { visuNo } {
      variable private
      global conf 
      global caption

      set bufNo [visu$visuNo buf]
      
      #--- si une camera a le meme buffer que la visu, je ferme la camera
      foreach camNo [::cam::list] {
         if { [cam$camNo buf] == $bufNo } {
            ::confCam::closeCamera $camNo
         }
      }

      #--- je supprime les bind 
      ::confVisu::deleteBindDialog $visuNo 

      #--- je memorise la position de la fenetre
      set conf(audace,visu$visuNo,wmgeometry) "[wm geometry $::confVisu::private($visuNo,This)]"

      #--- je supprime le menubar et toutes ses entree
      if { $private($visuNo,menu) != "" } {
         Menubar_Delete $visuNo
      }

      #--- je ferme l'outil courant
      if { [getTool $visuNo] != "" } {
         ::[getTool $visuNo]::deletePanel $visuNo
      }

      #--- je ferme les outils Acquisition et Autoguidage dedies aux autres visu
      if { $visuNo > "1" } {
         ::AcqFC::deletePanel $visuNo
         ::Autoguider::deletePanel $visuNo
      }

      #--- je supprime l'image associee à la visu
      image delete image[visu$visuNo image]

      #--- je supprime la visu
      ::visu::delete $visuNo

      #--- je supprime le buffer associe a la visu
      ::buf::delete $bufNo

      
      #--- je supprime la fenetre
      destroy $private($visuNo,This)
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
   proc autovisu { visuNo { force "-no" } { fileName "" } } {
      variable private
      global conf  
      global caption

      #--- je mets a jour le nom du fichier dans le titre de la fenetre  
      if { $fileName != "" } {
        wm title $private($visuNo,This) "$caption(audace,titre) (visu$visuNo) - $fileName"
      } else {
        wm title $private($visuNo,This) "$caption(audace,titre) (visu$visuNo)"
      }
      

      if { $force == "-novisu" } {
         return
      }
      
      set bufNo [visu$visuNo buf]
      set private($visuNo,picture_w) [lindex [buf$bufNo getkwd NAXIS1] 1]
      if { "$private($visuNo,picture_w)" == "" } { 
         set private($visuNo,picture_w)  0
      }
      set private($visuNo,picture_h) [lindex [buf$bufNo getkwd NAXIS2] 1]
      if { "$private($visuNo,picture_h)" == "" } {
         set private($visuNo,picture_h) 0
      }

      set width  $private($visuNo,picture_w)
      set height $private($visuNo,picture_h)
      set zoom   $private($visuNo,zoom)
      set imageNo [visu$visuNo image]


      if { [ image type image$imageNo ] == "video" } {
         #--- Je mets la fenetre a l'echelle
         image$imageNo configure -scale "$zoom"

         #--- Je mets a jour la taille les scrollbars
         $private($visuNo,hCanvas) configure -scrollregion [list 0 0 $width $height ]
         #--- Je mets a jour la taille du reticule
         ::confVisu::redrawCrosshair $visuNo

      } else {
         #--- mise à jour des scrollbar
         $private($visuNo,hCanvas) configure \
            -scrollregion [list 0 0 [expr int(${zoom} * $width)] [expr int(${zoom} * $height)]]
         $private($visuNo,hCanvas) itemconfigure display -state normal

         #--- Je mets a jour la taille du reticule
         ::confVisu::redrawCrosshair $visuNo

         #--- Si le buffer est vide, on n'essaie pas de mettre à jour en fonction des seuils
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
                  visu $visuNo [ list [ lindex [ buf$bufNo getkwd MIPS-HI ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-LO ] 1 ] ]
               }
            }
         } else { 
            #--- nettoyage de l'affichage  s'il n'y a pas d'image
            visu $visuNo current     
         }
      }
      
      #--- je met a jour le nom du fichier  (cette variable est surveillee par un listener)
      set private($visuNo,lastFileName) "$fileName"   
   }

   #
   # visu [l2i cuts]
   # Visualisation du buffer : Eventuellement on peut changer les seuils en passant une liste de
   # deux elements entiers : le seuil haut et le seuil bas
   #
   # Exemple :
   # visu
   # visu {500 0}
   #
   proc visu { visuNo { cuts "autocuts" } } {
      variable private 

      set bufNo [visu$visuNo buf ]

      if { [llength $cuts] == 1 } {
         if { $cuts == "autocuts"} {
            set cuts [ lrange [ buf$bufNo autocuts ] 0 1 ]
         } else {
            # autre choix = on garde les seuils actuels
            set cuts [visu$visuNo cut ]
            set sh [ expr [ lindex $cuts 0 ] ]
            set sb [ expr [ lindex $cuts 1 ] ]
            set cuts [ list $sh $sb ]
         }
      } elseif { [llength $cuts] == 2 } {
         visu$visuNo cut $cuts
      }

      visu$visuNo clear
      ::confVisu::ComputeScaleRange $visuNo
      ::confVisu::ChangeHiCutDisplay $visuNo [lindex $cuts 0]
      ::confVisu::ChangeLoCutDisplay $visuNo [lindex $cuts 1]
      set width  $private($visuNo,picture_w)
      set height $private($visuNo,picture_h)
      set zoom   $private($visuNo,zoom)
      $private($visuNo,hCanvas) configure -scrollregion [ list 0 0 [ expr int(${zoom}*$private($visuNo,picture_w)) ] [ expr int(${zoom}*$private($visuNo,picture_h)) ] ]

      # rafraichissement de l'affichage
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
      ::Movie::deleteMovieWindow $private($visuNo,hCanvas)

      catch { ::astrometry::quit }
      catch { ::AcqFC::stopPreview }
  
      #--- Suppression de la fenetre a l'ecran
      if { $private($visuNo,box) != "" } {
         set private($visuNo,box) ""
         $private($visuNo,hCanvas) delete $private($visuNo,box)
      }

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
         set private($visuNo,labcoord_type) xy
         bind $private($visuNo,This).fra1.labURLX <Button-1> "::confVisu::toogleCoordType $visuNo"
         bind $private($visuNo,This).fra1.labURLY <Button-1> "::confVisu::toogleCoordType $visuNo"
      } else {
         $private($visuNo,This).fra1.labURLX configure -fg $audace(color,textColor)
         $private($visuNo,This).fra1.labURLY configure -fg $audace(color,textColor)
         set private($visuNo,labcoord_type)  xy
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
         set private($visuNo,labcoord_type) radec
         $private($visuNo,This).fra1.labURLX configure -text "$caption(caractere,RA) $caption(caractere,egale) $caption(caractere,tiret)"
         $private($visuNo,This).fra1.labURLY configure -text "$caption(caractere,DEC) $caption(caractere,egale) $caption(caractere,tiret)"
       } else {
         set private($visuNo,labcoord_type) xy
         $private($visuNo,This).fra1.labURLX configure -text "$caption(caractere,X) $caption(caractere,egale) $caption(caractere,tiret)"
         $private($visuNo,This).fra1.labURLY configure -text "$caption(caractere,Y) $caption(caractere,egale) $caption(caractere,tiret)"
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

      set box [grid bbox .audace.can1 0 0]
      set xScreenCenter [expr ([lindex $box 2] - [lindex $box 0])/2 ]  
      set yScreenCenter [expr ([lindex $box 3] - [lindex $box 1])/2 ]

      set canvasCenter  [::confVisu::screen2Canvas $visuNo [list $xScreenCenter $yScreenCenter]]
   }

   #------------------------------------------------------------
   #  setZoom
   #     change le zoom  et rafraichit l'affichage
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc setZoom { visuNo } {
      variable private 

      set box [grid bbox .audace.can1 0 0]
      set xScreenCenter [expr ([lindex $box 2] - [lindex $box 0])/2 ]  
      set yScreenCenter [expr ([lindex $box 3] - [lindex $box 1])/2 ]

      set canvasCenter  [::confVisu::screen2Canvas $visuNo [list $xScreenCenter $yScreenCenter]]
      set pictureCenter [::confVisu::canvas2Picture $visuNo $canvasCenter ]

      visu$visuNo zoom $private($visuNo,zoom)

      #--- Je mets a jour la taille du reticule
      #::confVisu::redrawCrosshair $visuNo
      
      visu$visuNo clear
      
      #--- mise à jour des scrollbar
      $private($visuNo,hCanvas) configure \
         -scrollregion [list 0 0 [expr int($private($visuNo,zoom) * $private($visuNo,picture_w))] [expr int($private($visuNo,zoom) * $private($visuNo,picture_h))]]

      # rafraichissement de l'image
      visu$visuNo disp   

      set canvasCenter [::confVisu::picture2Canvas $visuNo $pictureCenter]
   
      set xFactor [.audace.can1.canvas xview]
      set yFactor [.audace.can1.canvas yview]
      set scrollRegion [.audace.can1.canvas cget -scrollregion]
      
      set xmin [expr  [lindex $xFactor 0] * [lindex $scrollRegion 2] ]
      set ymin [expr  [lindex $yFactor 0] * [lindex $scrollRegion 3] ]
      set xmax [expr  [lindex $xFactor 1] * [lindex $scrollRegion 2] ]
      set ymax [expr  [lindex $yFactor 1] * [lindex $scrollRegion 3] ]
      
      set x [expr [lindex $canvasCenter 0] -($xmax-$xmin)/2 ] 
      set y [expr [lindex $canvasCenter 1] -($ymax-$ymin)/2 ] 
      if { $x < 0 } { set x 0 }
      if { $y < 0 } { set y 0 }
      
      if { [lindex $scrollRegion 2] != "0" } {
         .audace.can1.canvas xview moveto [expr 1.0*$x / [lindex $scrollRegion 2] ]
      }
      if { [lindex $scrollRegion 3] != "0" } {
         .audace.can1.canvas yview moveto [expr 1.0*$y / [lindex $scrollRegion 3] ]
      }
      
   }

   #------------------------------------------------------------
   #  setMirrorX
   #     applique un miroir par rapport à l'axe des X
   #
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc setMirrorX { visuNo } {
      variable private

      set bufNo [visu$visuNo buf]
      if { [ buf$bufNo imageready ] == "1" } {
         visu$visuNo mirrorx $private($visuNo,mirror_x)
         ::confVisu::autovisu $visuNo
      } else {
         set private($visuNo,mirror_x) "0"
      }
   }

   #------------------------------------------------------------
   #  setMirrorY
   #     applique un miroir par rapport à l'axe des Y
   #
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc setMirrorY { visuNo } {
      variable private
      
      set bufNo [visu$visuNo buf]
      if { [ buf$bufNo imageready ] == "1" } {
         visu$visuNo mirrory $private($visuNo,mirror_y)
         ::confVisu::autovisu $visuNo
      } else {
         set private($visuNo,mirror_y) "0"
      }
   }

   #------------------------------------------------------------
   #  setCamera
   #     associe une camera à la visu
   #  parametres :
   #    visuNo: numero de la visu
   #    camNo : numero de la camera
   #    model : libelle de la camera a afficher dans la visu
   #  exemple : setCamera 2 3 "EOS 300D" cree l'association entre visu2 et cam3
   #            setCamera 2 "" ""        supprime l'association
   #------------------------------------------------------------
   proc setCamera { visuNo camNo { model "" } } {
      variable private
      global caption
      global color

      set private($visuNo,camNo) $camNo
      if { $camNo == 0 } {
         set private($visuNo,camName) ""
         if { [winfo exists $private($visuNo,This)] == 1} {
            $private($visuNo,This).fra1.labCam_name_labURL configure -text $caption(caractere,tiret) -fg $color(blue)
         }
      } else {
         set private($visuNo,camName) [cam$camNo name]
         set private($visuNo,camProductName) [cam$camNo product]
         $private($visuNo,This).fra1.labCam_name_labURL configure -text "$private($visuNo,camName) $model" -fg $color(blue)
      }
   }

   #------------------------------------------------------------
   #  getCamNo
   #     retourne le numero de camera associee à la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getCamNo { visuNo } {
      variable private

      return $private($visuNo,camNo)
   }

   #------------------------------------------------------------
   #  getCamera
   #     retourne le nom de camera associee à la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getCamera { visuNo } {
      variable private

      return $private($visuNo,camName)
   }

   #------------------------------------------------------------
   #  getProduct
   #     retourne le nom de famille de la camera associee à la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getProduct { visuNo } {
      variable private

      return $private($visuNo,camProductName)
   }

   #------------------------------------------------------------
   #  getBufNo
   #     retourne le nom de camera associee à la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getBufNo { visuNo } {
      variable private

      return [visu$visuNo buf]
   }

   #------------------------------------------------------------
   #  setWindow
   #     affiche une partie de l'image
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
            if { $private($visuNo,box) != "" } {
               visu$visuNo window $private($visuNo,box)
               set private($visuNo,box) ""
               $private($visuNo,hCanvas) delete $private($visuNo,hBox)
               ::confVisu::autovisu $visuNo
            } else {
               tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,boite,tracer)
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
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc setFullScreen { visuNo } {
      variable private

      set bufNo [visu$visuNo buf]
      if { [ buf$bufNo imageready ] == "1" } {
         if { $private($visuNo,fullscreen) == "1" } {
            ::FullScreen::showBuffer $visuNo $private($visuNo,hCanvas)
         } else { 
            ::FullScreen::close
         }
      } else {
         set private($visuNo,fullscreen) "0"
      }
   }

   #------------------------------------------------------------
   #  setVideo
   #     active/desactive le mode video pour une camera pour afficher
   #     des films AVI
   #   
   #  parametres :
   #    visuNo: numero de la visu
   #    state : 1= active le mode video , 0=desactive le mode video
   #------------------------------------------------------------
   proc setVideo { visuNo state } {
      variable private
      set imageNo [visu$visuNo image]

      if { $state == 1 } {
         #--- j'active le mode video
         #--- Je supprime l'image precedente
         image delete image$imageNo
         buf[visu$visuNo buf] clear
         #--- Je cree une image de type "video"
         image create video image$imageNo
         #--- Je connecte la sortie de la camera a l'image
         set result [ catch { cam$private($visuNo,camNo) startvideoview $visuNo } msg ]
      } else {
         #--- Je deconnecte la sortie de la camera 
         set result [ catch { cam$private($visuNo,camNo) stopvideoview $visuNo } msg ]
         #--- je desactive le mode video
         image delete image$imageNo
         #--- Je cree une image de type "photo"
         image create photo image$imageNo
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
   #    cmd : commande TCL a lancer quand la camera associee à la visu change
   #------------------------------------------------------------
   proc addCameraListener { visuNo cmd } {
      variable private

      trace add variable "::confVisu::private($visuNo,camNo)" write $cmd
   }

   #------------------------------------------------------------
   # removeCameraListener
   #    supprime une procedure a appeler si on change de camera
   #  parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand la camera associee à la visu change
   #------------------------------------------------------------
   proc removeCameraListener { visuNo cmd } {
      variable private

      trace remove variable "::confVisu::private($visuNo,camNo)" write $cmd
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

      trace add variable "::confVisu::private($visuNo,zoom)" write $cmd
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

      trace remove variable "::confVisu::private($visuNo,zoom)" write $cmd
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

      trace add variable "::confVisu::private($visuNo,lastFileName)" write $cmd
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

      trace remove variable "::confVisu::private($visuNo,lastFileName)" write $cmd
   }


   #------------------------------------------------------------
   #  stopTool
   #     arrete l'outil courant
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable private

      if { $private($visuNo,toolNameSpace) != "" } { 
         $private($visuNo,toolNameSpace)::stopTool $visuNo
      }
   }

   #------------------------------------------------------------
   #  selectTool
   #     arrete l'outil courant 
   #     demarre le nouvel outil
   #  parametres :
   #    visuNo: numero de la visu
   #    toolName : nom de l'outil a lancer
   #------------------------------------------------------------
   proc selectTool { visuNo toolName } {
      variable private

      if { "private($visuNo,toolNameSpace)" != "" } {
         #--- Cela veut dire qu'il y a deja un outil selectionne
         if { "private($visuNo,toolNameSpace)" != "$toolName" } {
            #--- Cela veut dire que l'utilisateur selectionne un nouvel outil
            stopTool $visuNo
         } 
         namespace inscope $toolName startTool $visuNo
         set private($visuNo,toolNameSpace) $toolName
      } else {
         #--- Dans ce cas, aucun outil n'est selectionne
         namespace inscope $toolName startTool $visuNo
      }
   }

   #------------------------------------------------------------
   #  getTool
   #     retourne  le nom de l'outil courant
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getTool { visuNo } {
      variable private

      return [ string trimleft $private($visuNo,toolNameSpace) "::" ]
   }

   #------------------------------------------------------------
   #  getVisuNo
   #     retourne le numero de visu contenant le canvas
   #  parametres
   #     hCanvas : nom du canvas , exemple: .audace.can1.canvas 
   #  return : 
   #    numero de la visu contenant le canvas
   #------------------------------------------------------------
   proc getVisuNo { hCanvas } {
      #-- le numero de la visu se trouve dans le parametre "class de la toplevel 
      #-- qui contient le canvas
      return [winfo class [winfo toplevel $hCanvas ] ]   
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
   #  getBase
   #     retourne le chemin de la toplevel de la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getBase { visuNo } {
      variable private

      return $private($visuNo,This)
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

      toplevel $This -class $visuNo
      wm geometry $This $conf(audace,visu$visuNo,wmgeometry)
      wm maxsize $This [winfo screenwidth .] [winfo screenheight .]
      wm minsize $This 320 240
      wm resizable $This 1 1
      wm deiconify $This
      wm title $This "$caption(audace,titre) (visu$visuNo)"
      wm protocol $This WM_DELETE_WINDOW " ::confVisu::close $visuNo "
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

         button $This.fra1.but_seuils_auto -text "$caption(audace,seuil,auto)" \
            -command "::confVisu::onCutLabelLeftClick $visuNo" -width 5
         grid configure $This.fra1.but_seuils_auto -column 0 -row 0 -rowspan 2 -sticky we -in $This.fra1 -padx 5

         button $This.fra1.but_config_glissieres -text "$caption(script,parcourir)" \
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

         label $This.fra1.lab1 -width 10 -text "$caption(seuil,haut)" -font $audace(font,arial_8_n)
         grid configure $This.fra1.lab1 -column 3 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.lab2 -width 10 -text "$caption(seuil,bas)" -font $audace(font,arial_8_n)
         grid configure $This.fra1.lab2 -column 3 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labURLX -width 16 -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(caractere,X) $caption(caractere,egale) $caption(caractere,tiret)"
         grid configure $This.fra1.labURLX -column 4 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labURLY -width 16 -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(caractere,Y) $caption(caractere,egale) $caption(caractere,tiret)"
         grid configure $This.fra1.labURLY -column 4 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labI -width 19 -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(caractere,I) $caption(caractere,egale) $caption(caractere,tiret)"
         grid configure $This.fra1.labI -column 5 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labTime -width 19 -font $audace(font,arial_8_n) -anchor w \
            -textvariable "audace(tu,format,dmyhmsint)"
         grid configure $This.fra1.labTime -column 5 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labCam_labURL -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(audace,menu,camera) $caption(caractere,2points)" -fg $color(blue)
         grid configure $This.fra1.labCam_labURL -column 6 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labCam_name_labURL -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(caractere,tiret)" -fg $color(blue)
         grid configure $This.fra1.labCam_name_labURL -column 7 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labTel_labURL -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(audace,menu,monture) $caption(caractere,2points)" -fg $color(blue)
         grid configure $This.fra1.labTel_labURL -column 6 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labTel_name_labURL -font $audace(font,arial_8_n) -anchor w \
            -text "$caption(caractere,tiret)" -fg $color(blue)
         grid configure $This.fra1.labTel_name_labURL -column 7 -row 1 -sticky we -in $This.fra1 -pady 2

      pack $This.fra1 -anchor center -expand 0 -fill x -side bottom

      grid columnconfigure $This.fra1 5 -weight 1

      #--- Canvas de dessin de l'image
      Scrolled_Canvas $This.can1 -borderwidth 0 -relief flat \
         -width 300 -height 200 -scrollregion {0 0 0 0} -cursor crosshair
      pack $This.can1 -in $This -anchor center -expand 1 -fill both -side right
      $This.can1.canvas configure -borderwidth 0
      $This.can1.canvas configure -relief flat

      #--- petit raccouci vers le canvas
      set private($visuNo,hCanvas) $private($visuNo,This).can1.canvas

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
      bind $This <Key-F1> { $audace(console)::GiveFocus }

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

      #--- bind du canvas avec la souris , j'ative les valeurs par defaut
      createBindCanvas $visuNo <ButtonPress-1>   "default"
      createBindCanvas $visuNo <ButtonRelease-1> "default"
      createBindCanvas $visuNo <B1-Motion>       "default"
      createBindCanvas $visuNo <Motion>          "default"
      createBindCanvas $visuNo <ButtonPress-3>   "default"

      #--- bind pour l'ouverture de la boite de configuration des cameras
      bind $This.fra1.labCam_labURL <ButtonPress-1> {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
      bind $This.fra1.labCam_name_labURL <ButtonPress-1> {
         ::confCam::run
         tkwait window $audace(base).confCam
      }

      #--- bind pour l'ouverture de la boite de configuration des montures
      bind $This.fra1.labTel_labURL <ButtonPress-1> {
         ::confTel::run
         tkwait window $audace(base).confTel
      }
      bind $This.fra1.labTel_name_labURL <ButtonPress-1> {
         ::confTel::run
         tkwait window $audace(base).confTel
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
      bind $This <Key-F1> { $audace(console)::GiveFocus }

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
   #     command  : command a executer. si command="default"  
   #                alors c'est la commande par defaut qui est associe
   #------------------------------------------------------------
   proc createBindCanvas { visuNo sequence { command "default" } } {
      variable private 

      if { "$command" == "default" } {
         switch -exact $sequence     {
            <ButtonPress-1> {
               bind $private($visuNo,hCanvas) <ButtonPress-1>   "::confVisu::pressButton1 $visuNo %x %y"
            }
            <ButtonRelease-1> {
               bind $private($visuNo,hCanvas) <ButtonRelease-1> "::confVisu::releaseButton1 $visuNo %x %y"
            }
            <B1-Motion> {
               bind $private($visuNo,hCanvas) <B1-Motion>       "::confVisu::motionButton1 $visuNo %x %y"
            }
            <Motion> {
               bind $private($visuNo,hCanvas) <Motion>          "::confVisu::motionMouse $visuNo %x %y"
            }
            <ButtonPress-3> {
               bind $private($visuNo,hCanvas) <ButtonPress-3>   "::confVisu::showPopupMenu $visuNo %X %Y"
            }
         }
      }  else {
         bind $private($visuNo,hCanvas) $sequence  "$command"
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
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,entete)" " ::audace::header $visuNo "

      Menu_Separator $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo  "$caption(audace,menu,fichier)" "$caption(creer,dialogue,fermer)" \
         " ::confVisu::close $visuNo "

      Menu           $visuNo "$caption(audace,menu,affichage)"

      Menu_Command   $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,nouvelle_visu)" ::confVisu::create
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_grise)" \
               "1" "conf(visu_palette)" " ::audace::MAJ_palette $visuNo "
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_inverse)" \
              "2" "conf(visu_palette)" " ::audace::MAJ_palette $visuNo "
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_iris)" \
              "3" "conf(visu_palette)" " ::audace::MAJ_palette $visuNo "
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_arc_en_ciel)" \
              "5" "conf(visu_palette)" " ::audace::MAJ_palette $visuNo "
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Cascade $visuNo "$caption(audace,menu,affichage)" "$caption(fcttransfert,titre)" 
      Menu_Command_Radiobutton $visuNo "$caption(fcttransfert,titre)" "$caption(fcttransfert,lin)" "1" \
              "conf(fonction_transfert,visu$visuNo,mode)" " ::audace::fonction_transfert $visuNo "
      Menu_Command_Radiobutton $visuNo "$caption(fcttransfert,titre)" "$caption(fcttransfert,log)" "2" \
              "conf(fonction_transfert,visu$visuNo,mode)" " ::audace::fonction_transfert $visuNo "
      Menu_Command_Radiobutton $visuNo "$caption(fcttransfert,titre)" "$caption(fcttransfert,exp)" "3" \
              "conf(fonction_transfert,visu$visuNo,mode)" " ::audace::fonction_transfert $visuNo "
      Menu_Command_Radiobutton $visuNo "$caption(fcttransfert,titre)" "$caption(fcttransfert,arc)" "4" \
              "conf(fonction_transfert,visu$visuNo,mode)" " ::audace::fonction_transfert $visuNo "
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command $visuNo "$caption(audace,menu,affichage)" "$caption(seuils,titre)..." \
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
         "::confGenerique::run $This.confCrossHair ::Crosshair $visuNo"

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
      #--- Affichage de l'outil Acquisition
      set liste ""
      foreach m [array names panneau menu_name,*] {
         lappend liste [list "$panneau($m) " $m]
      }
      foreach m [lsort $liste] {
         set m [lindex $m 1]
         if { ( $m == "menu_name,AcqFC" ) || ( $m == "menu_name,Autoguider" ) } {
            if { [scan "$m" "menu_name,%s" ns] == "1" } {
               Menu_Command $visuNo "$caption(audace,menu,outils)" "$panneau($m)" "::confVisu::selectTool $visuNo ::$ns"
               #--- Lancement automatique de l'outil Acquisition
               ::confVisu::selectTool $visuNo ::AcqFC
            }
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
   # Transforme des coordonnees ecran en coordonnees canvas. L'argument est une liste de deux entiers,
   # et retourne également une liste de deux entiers
   #
   proc screen2Canvas { visuNo coord } {
      variable private

      scan [$private($visuNo,hCanvas) canvasx [lindex $coord 0]] "%d" xx
      scan [$private($visuNo,hCanvas) canvasy [lindex $coord 1]] "%d" yy
      return [list $xx $yy]
   }

   #
   # ::confVisu::canvas2Picture coord {stick left}
   # Transforme des coordonnees canvas en coordonnees image. L'argument est une liste de deux entiers,
   # et retourne également une liste de deux entiers.
   # Les coordonnees canvas commencent a 0,0 dans le coin superieur gauche de l'image.
   # Les coordonnees image  commencent a 1,1 dans le coin inferieur gauche de l'image.
   # En passant un argument <> de left pour stick, calcule les coordonnees par arrondi superieur.
   #
   proc canvas2Picture { visuNo coord { stick left } } {
      variable private

      set zoom   [visu$visuNo zoom]
      set window [visu$visuNo window]
      set bufNo  [visu$visuNo buf]
      set height $private($visuNo,picture_h)

      if {$window=="full"} {
         set x0 0
         set y0 0
      } else {
         set x0 [lindex $window 0]
         set y0 [lindex $window 1]
      }

      if {$zoom >= 1} {
         set xx [expr [lindex $coord 0] / $zoom - $private($visuNo,picture_orgx) + 1 + $x0]
         set yy [expr $height + $private($visuNo,picture_orgy) - ([lindex $coord 1]/$zoom) - $y0]
      } else {
         if {$stick == "left"} {
            #--- Ce calcul sert a obtenir la borne inferieure en cas de sous-echantillonnage
            set xx [expr int([lindex $coord 0] / $zoom - $private($visuNo,picture_orgx) + 1 + $x0)]
            set yy [expr int($height + $private($visuNo,picture_orgy) - ([lindex $coord 1] + 1) / $zoom + 1 - $y0)]
         } else {
            #--- Alors que ce calcul sert a obtenir la borne superieure en cas de sous-echantillonnage
            set xx [expr int(([lindex $coord 0] + 1) / $zoom - $private($visuNo,picture_orgx) + $x0)]
            set yy [expr int($height + $private($visuNo,picture_orgy) - [lindex $coord 1] / $zoom - $y0)]
         }
      }
      return [list $xx $yy]
   }

   #
   # ::confVisu::picture2Canvas coord
   # Transforme des coordonnees image en coordonnees canvas. L'argument est une liste de deux entiers,
   # et retourne également une liste de deux entiers
   #
   proc picture2Canvas { visuNo coord } {
      variable private

      set zoom    $private($visuNo,zoom)
      set window  [visu$visuNo window]
      set height $private($visuNo,picture_h)
      if {$window=="full"} {
         set x0 0
         set y0 0
      } else {
         set x0 [lindex $window 0]
         set y0 [lindex $window 1]
      }
      set xx [ expr int(( [lindex $coord 0] + $private($visuNo,picture_orgx) - 1 - $x0)*$zoom) ]
      set yy [ expr int(( $height  -[lindex $coord 1] + $private($visuNo,picture_orgy) + $y0)*$zoom) ]
      return [list $xx $yy]
   }

   proc pressButton1 { visuNo x y } {
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
               ###set audace(clickxy) [::confVisu::canvas2Picture $visuNo [::confVisu::screen2Canvas $visuNo [list $x $y] ] ]
            }
         }
      } else {
         if { [string compare $::confVisu::private($visuNo,MouseState) context] == 0 } {
            [MenuGet $visuNo "$caption(audace,menu,affichage)"] unpost
            set ::confVisu::private($visuNo,MouseState) rien
         }
      }
   }

   proc motionButton1 { visuNo x y } {
      variable private

      if { [string compare $::confVisu::private($visuNo,MouseState) dragging] == 0 } {
         #--- Affichage des coordonnees
         ::confVisu::displayCursorCoord $visuNo [list $x $y]
         #--- On n'oublie pas de dragger eventuellement la fenetre
         ::confVisu::boxDrag $visuNo [list $x $y]
      }
   }

   proc releaseButton1 { visuNo x y } {
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

   proc motionMouse { visuNo x y } {
      #--- Affichage des coordonnees
      ::confVisu::displayCursorCoord $visuNo [list $x $y]
   }

   proc displayCursorCoord { visuNo coord } {
      variable private
      global caption

      catch {
         #--- Transformation des coordonnees ecran en coordonnees image (pour tenir compte du retournement de l'image)
         set coord [ ::confVisu::canvas2Picture $visuNo [ ::confVisu::screen2Canvas $visuNo $coord ] ]

         set This $private($visuNo,This)
         set bufNo [visu$visuNo buf]

         #--- xi et yi sont des 'coordonnees-image'
         set xi [ lindex $coord 0 ]
         set yi [ lindex $coord 1 ]

         #--- ii contiendra l'intensite du pixel pointe
         set ii [ buf$bufNo getpix [ list $xi $yi ] ]
         if { $private($visuNo,intensity) == "1" } {
            if { [ lindex $ii 0 ] == "1" } {
               set intensite "$caption(caractere,I) $caption(caractere,egale) [ lindex $ii 1 ]"
            } elseif { [ lindex $ii 0 ] == "3" } {
               set intensite "$caption(couleur,rouge)[ lindex $ii 1 ] $caption(couleur,vert)[ lindex $ii 2 ] $caption(couleur,bleu)[ lindex $ii 3 ]"
            }
         } elseif { $private($visuNo,intensity) == "0" } {
            if { [ lindex $ii 0 ] == "1" } {
               set intensite "$caption(caractere,I) $caption(caractere,egale) [ string trimleft [ format "%8.0f" [ lindex $ii 1 ] ] " " ]"
            } elseif { [ lindex $ii 0 ] == "3" } {
               set intensite "$caption(couleur,rouge)[ string trimleft [ format "%8.0f" [ lindex $ii 1 ] ] " " ] \
                  $caption(couleur,vert)[ string trimleft [ format "%8.0f" [ lindex $ii 2 ] ] " " ] \
                  $caption(couleur,bleu)[ string trimleft [ format "%8.0f" [ lindex $ii 3 ] ] " " ]"
            }
         }

         #--- Affichage a l'ecran
         if { $private($visuNo,labcoord_type) == "xy" } {
            $This.fra1.labURLX configure -text "$caption(caractere,X) $caption(caractere,egale) $xi"
            $This.fra1.labURLY configure -text "$caption(caractere,Y) $caption(caractere,egale) $yi"
            $This.fra1.labI configure -text "$intensite"
         } else {
            set temp [ buf$bufNo xy2radec [ list $xi $yi ] ]
            $This.fra1.labURLX configure -text "$caption(caractere,RA) $caption(caractere,egale) [ mc_angle2hms [ lindex $temp 0 ] 360 zero 1 auto string ]"
            $This.fra1.labURLY configure -text "$caption(caractere,DEC) $caption(caractere,egale) [ mc_angle2dms [ lindex $temp 1 ] 90 zero 0 + string ]"
            $This.fra1.labI configure -text "$intensite"
         }
      }
   }

   #------------------------------------------------------------
   #  getBox
   #     retourne 
   #  parametres :
   #     visuNo : numero de la visu
   #------------------------------------------------------------
   proc getBox { { visuNo "1" } } {
      variable private

      return $private($visuNo,box)
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

   #
   # Attention : Les coordonnees coord sont des coordonnees canvas et non ecran
   #
   proc boxBegin { visuNo coord } {
      variable private

      set private($visuNo,box) ""
      set private($visuNo,box_1) [ screen2Canvas $visuNo $coord ]
   }

   #
   # Attention : Les coordonnees x et y sont des coordonnees canvas et non ecran
   #
   proc boxEnd { visuNo coord } {
      variable private
      global audace

      ::confVisu::boxDrag $visuNo $coord
      if { $private($visuNo,box_1) == $private($visuNo,box_2) } {
         set private($visuNo,box) ""
         $private($visuNo,hCanvas) delete $private($visuNo,hBox)
      } else {
         if {[lindex $private($visuNo,box_1) 0] > [lindex $private($visuNo,box_2) 0]} {
            set x1 [lindex $private($visuNo,box_2) 0]
            set x2 [lindex $private($visuNo,box_1) 0]
         } else {
            set x1 [lindex $private($visuNo,box_1) 0]
            set x2 [lindex $private($visuNo,box_2) 0]
         }
         if {[lindex $private($visuNo,box_1) 1] < [lindex $private($visuNo,box_2) 1]} {
            # !! Le test est inverse car l'origine en canvas est en haut !!
            set y1 [lindex $private($visuNo,box_2) 1]
            set y2 [lindex $private($visuNo,box_1) 1]
         } else {
            set y1 [lindex $private($visuNo,box_1) 1]
            set y2 [lindex $private($visuNo,box_2) 1]
         }
         set coord1 [::confVisu::canvas2Picture $visuNo [list $x1 $y1]]
         set coord2 [::confVisu::canvas2Picture $visuNo [list $x2 $y2] -right ]
         set x1 [lindex $coord1 0]
         set y1 [lindex $coord1 1]
         set x2 [lindex $coord2 0]
         set y2 [lindex $coord2 1]
         set private($visuNo,box) ""
         set private($visuNo,box) [list $x1 $y1 $x2 $y2]
      }
   }

   #
   # Attention : Les coordonnees x et y sont des coordonnees canvas et non ecran
   #
   proc boxDrag { visuNo coord } {
      variable private
      global audace

      set zoom  $private($visuNo,zoom)
      set bufNo [visu$visuNo buf]
      set width  $private($visuNo,picture_w)
      set height $private($visuNo,picture_h)

      set wz [expr $width * $zoom]
      set hz [expr $height * $zoom]

      catch {$private($visuNo,hCanvas) delete $private($visuNo,hBox)}
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

   proc deleteBox { { visuNo "1" } } {
      variable private

      if { $private($visuNo,box) != "" } {
         set private($visuNo,box) ""
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
         save_cursor
         all_cursor watch
         #--- Le -force permet de forcer la visu si on a choisi
         #--- dans le panneau de config "pas de recalcul automatique"
         ::confVisu::autovisu $visuNo -force
         restore_cursor
         set private($visuNo,autovisuEnCours) "0"
      }
   }

   proc onCutLabelRightClick { visuNo } {
      variable private

      ::seuilWindow::run $private($visuNo,This) $visuNo 
   }

   proc onHiCutCommand { visuNo val } {
      set sbh [visu$visuNo cut]
      visu$visuNo cut [list $val [lindex $sbh 1]]
      ChangeHiCutDisplay $visuNo $val
   }

   proc onLoCutCommand { visuNo val } {
      set sbh [visu$visuNo cut]
      visu$visuNo cut [list [lindex $sbh 0] $val]
      ChangeLoCutDisplay $visuNo $val
   }

   proc ChangeHiCutDisplay { visuNo val } {
      variable private

      $private($visuNo,This).fra1.sca1 set $val
      $private($visuNo,This).fra1.lab1 configure -text $val
   }

   proc ChangeLoCutDisplay { visuNo val } {
      variable private     
      
      $private($visuNo,This).fra1.sca2 set $val
      $private($visuNo,This).fra1.lab2 configure -text $val
   }
   
   proc onCutScaleRelease { visuNo } {
      variable private

      ComputeScaleRange $visuNo
      visu$visuNo disp
   }

   proc ComputeScaleRange { visuNo } {
      variable private
      global conf

      set zone(sh1) $private($visuNo,This).fra1.sca1
      set zone(sb1) $private($visuNo,This).fra1.sca2
      if { $conf(seuils,auto_manuel) == 1 } {
         #--- Calcule les nouveaux seuils
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
         set maxi [ expr $maxi + $conf(seuils,%_dynamique) / 100.0 * $range ]
         set mini [ expr $mini - $conf(seuils,%_dynamique) / 100.0 * $range ]
         #--- Redimensionne le scale widget
         $zone(sb1) configure -from $mini -to $maxi
         $zone(sh1) configure -from $mini -to $maxi
         set private($visuNo,mindyn) $mini
         set private($visuNo,maxdyn) $maxi
      } elseif { $conf(seuils,auto_manuel) == 2 } {
         $zone(sb1) configure -from $private($visuNo,mindyn) -to $private($visuNo,maxdyn)
         $zone(sh1) configure -from $private($visuNo,mindyn) -to $private($visuNo,maxdyn)
      }
   }

   #------------------------------------------------------------
   #  setCrosshair
   #  set Crosshair  state 
   #   state = 0 or 1
   #------------------------------------------------------------
   proc setCrosshair { visuNo state } {
      variable private

      set private($visuNo,crosshairstate) $state
      redrawCrosshair $visuNo
   }

   #------------------------------------------------------------
   #  toggleCrosshair
   #  toggle drawing/hiding Crosshair 
   #  as check button state indicate 
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
      update
   }

   #------------------------------------------------------------
   #  displayCrosshair
   #  draw Crosshair lines ( 1 horizontal line , 1 vertical line)
   #   
   #------------------------------------------------------------
   proc displayCrosshair { visuNo } {
      variable private
      global conf

      set hCanvas $private($visuNo,hCanvas)
      set private($visuNo,hCrosshairH) $hCanvas.crosshairH
      set private($visuNo,hCrosshairV) $hCanvas.crosshairV
      
      #--- je cree le label representant la ligne horizontale
      if { ![winfo exists $private($visuNo,hCrosshairH)] } {
         label $private($visuNo,hCrosshairH) -bg $conf(crosshair,color)
      }
      #--- je cree le label representant la ligne verticale
      if { ![winfo exists $private($visuNo,hCrosshairV)] } {
         label $private($visuNo,hCrosshairV) -bg $conf(crosshair,color)
      }

      #--- j'applique la couleur
      $private($visuNo,hCrosshairH) configure -bg $conf(crosshair,color)
      $private($visuNo,hCrosshairV) configure -bg $conf(crosshair,color)

      #--- calcul des dimensions en fonction du zoom
      set zoom $private($visuNo,zoom)
      set w [expr int($zoom*$private($visuNo,picture_w))]
      set h [expr int($zoom*$private($visuNo,picture_h))]
      
      #--- coordonnees du centre
      set xc [expr $w / 2]
      set yc [expr $h / 2]

      #--- draw horizontal line
      $hCanvas create window 1 1 -tag lineh -anchor nw -window $private($visuNo,hCrosshairH) -height 1
      $hCanvas coords lineh 0 $yc
      $hCanvas itemconfigure lineh -width $w  
      $hCanvas itemconfigure lineh -state normal 
      raise $private($visuNo,hCrosshairH)
      
      #--- draw vertical line
      $hCanvas create window 1 1 -tag linev -anchor nw -window $private($visuNo,hCrosshairV) -width 1
      $hCanvas coords linev $xc 0
      $hCanvas itemconfigure linev -height $h 
      $hCanvas itemconfigure linev -state normal
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
   }

}
####  namespace end

::confVisu::init

