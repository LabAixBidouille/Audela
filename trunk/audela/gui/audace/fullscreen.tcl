#
# Fichier : fullscreen.tcl
# Description : Fenetre plein ecran pour afficher des images
# Auteur : Michel PUJOL
# Date de mise a jour : 12 fevrier 2006
#

##############################################################################
# namespace FullScreen
#
#   ::FullScreen::showBuffer bufferName
#       ouvre la fenetre plein ecran et affiche l'image contenu dans un buffer
#
#   ::FullScreen::showFiles directory files
#       ouvre la fenetre plein ecran et affiche les images ou les films
#       contenus dans des fichiers
#
#   ::FullScreen::close
#       ferme la fenetre plein ecran
#       (la fenetre peut etre aussi fermee en appyuant sur ESCAPE)
#
#############################################################################

namespace eval ::FullScreen {
   global caption

   array set private {
      image             ""
      visuNo            ""
      bufNo             ""
      this              ""
      slideShow         0
      hWindow           ""
      hCanvas           ""
      zoom              "1"
      directory         ""
      files             ""
      currentItemIndex  0
      fileImage         "Image"
      fileMovie         "Film"
      animation         0
   }

   #--- Chargement des captions
   source [ file join $audace(rep_caption) fullscreen.cap ]
   set audace(fullscreen) 0

   #------------------------------------------------------------------------------
   #  showBuffer
   #   ouvre la fenetre plein ecran
   #   affiche l'image contenu dans le buffer
   #------------------------------------------------------------------------------
   proc showBuffer { visuNo hCanvas } {
      variable private

      set private(files)            ""
      set private(currentItemIndex) "0"
      set private(visuNo)           "$visuNo"
      #--- je cree la fenetre plein ecran
      createFullscreen $visuNo $hCanvas
   }

   #------------------------------------------------------------------------------
   #  showFiles
   #   ouvre la fenetre plein ecran
   #   et affiche les images ou les films contenus dans les fichiers
   #------------------------------------------------------------------------------
   proc showFiles { directory files } {
      variable private

      set private(directory)   $directory
      set private(files)       $files
      set private(inputBuffer) ""
      #--- je cree la fenetre plein ecran
      createFullscreen
      #--- j'affiche l'image contenue dans le premier fichier
      loadItem
   }

   #------------------------------------------------------------------------------
   #  createFullscreen
   #   ouvre la fenetre plein ecran
   #------------------------------------------------------------------------------
   proc createFullscreen { visuNo hCanvas } {
      variable private
      global audace
      global conf

      #--- je verifie que les variables de cette fenetre existent dans $conf(...)
      initConf

      #--- je recupere le nom de la toplevel
      set private(toplevel) [winfo toplevel $hCanvas]
      set private(hCanvas) $hCanvas

      #--- je recupere la liste des frames qui sont dans la top level
      set private(slaves) [pack slaves $private(toplevel)]

      #--- je masque les frames , sauf le canvas
      foreach slave $private(slaves) {
         # je sauvegarde les parametre de chaque frame
         set private($slave,pack_config) "[pack info $slave]"
         # je cache la frame sauf celle du canvas
         if { [string compare -length [string length $slave] "$slave" "$private(hCanvas)" ] != 0 } {
            pack forget $slave
         }
      }

      #--- je sauvegarde la taille de la fenetre
      set private(geometry) [wm geometry $private(toplevel)]

      #--- je sauvegarde le menu principal
      set private(menu) [$private(toplevel) cget -menu ]

      #--- je desactive le menu principal
      $private(toplevel) configure -menu ""

      #--- je cree le popup menu
      createPopupMenu $visuNo

      #--- j'affiche la fenetre en plein ecran
      set maxsize [wm maxsize $private(toplevel)]
      wm geometry $private(toplevel) [lindex $maxsize 0]x[lindex $maxsize 1]+0+0

      #--- je supprime le titre et les bordures de la fenetre
      wm overrideredirect $private(toplevel) 1

      #--- je deplace l'image au centre du canvas
      $private(hCanvas) itemconfigure display -anchor center
      $private(hCanvas) move display [expr [lindex $maxsize 0]/2] [expr [lindex $maxsize 1]/2]
      set private(bgcolor) [ $private(hCanvas) cget -bg ]

      #--- je donne le focus a la fenetre plein ecran
      focus $private(toplevel)

      set private(currentItemIndex) "0"
   }

   #------------------------------------------------------------------------------
   # loadItem
   #
   #  charge le fichier ou le buffer
   #------------------------------------------------------------------------------
   proc loadItem { } {
      variable private
      global audace
      global caption
      global conf

      if { "$private(files)" != "" } {
         #--- j'affiche l'image ou le film contenu dans le fichier

         #--- si une animation est en cours, j'arrete l'animation
         if { $private(animation) == 1 } {
            #--- j'arrete l'animation
            stopAnimation
         }

         #--- si un film est en cours, j'arrete le film
         ::Movie::close $private(visuNo,hCanvas)

         #--- je recupere le nom du fichier selectionne
         set index $private(currentItemIndex)
         set name [lindex [lindex $private(files) $index] 0 ]
         set type [lindex [lindex $private(files) $index] 1 ]
         set filename [file join "$private(directory)" "$name"]

         if { [string first "$private(fileImage)" "$type" ] != -1 } {
            #--- j'affiche l'image
            loadimage $filename $private(zoom)
            if { [::Image::isAnimatedGIF "$filename"] == 1 } {
               setAnimationState "1"
            } else {
               setAnimationState "0"
            }
         } elseif { "$type" == "$private(fileMovie)" } {
            #--- j'affiche la premiere image du film
            loadmovie $filename
            setAnimationState "1"
         }

         #--- si une animation etait en cours, je relance l'animation
         if { $conf(FullScreen,autoStartAnim) == 1 } {
            startAnimation
         }
      } else {
         ::confVisu::autovisu $private(visuNo)
      }
   }

   #------------------------------------------------------------------------------
   #  close
   #   ferme la fenetre plein ecran
   #------------------------------------------------------------------------------
   proc close { visuNo } {
      variable private
      global audace

      stopAnimation

      catch {
         ::Movie::close $private($visuNo,hCanvas)
      }

      #--- je place l'image dans le coin en haut a gauche
      $private(hCanvas) itemconfigure display -anchor nw
      $private(hCanvas) configure -bg $private(bgcolor)
      set coords [$private(hCanvas) coord display]
      $private(hCanvas) move display -[lindex $coords 0] -[lindex $coords 1]

      #--- je restaure la taille
      wm geometry $private(toplevel) $private(geometry)

      #--- je restaure les bordures et le titre
      wm overrideredirect  $private(toplevel) 0

      #--- je restaure le menu
      $private(toplevel) configure -menu $private(menu)

      #--- je restaure les fenetres filles
      foreach slave $private(slaves) {
         set a_exec "pack $slave $private($slave,pack_config)"
         eval $a_exec
      }

      #--- je desactive les bind
      bind $private(hCanvas) <ButtonPress-3>
      bind $private(hCanvas) <Key-S>
      bind $private(hCanvas) <Key-s>
      bind $private(hCanvas) <Key-Down>

      bind $private(hCanvas) <Key-P>
      bind $private(hCanvas) <Key-p>
      bind $private(hCanvas) <Key-Up>

      bind $private(hCanvas) <MouseWheel>
      bind $private(hCanvas) <Key-Escape>
      bind $private(hCanvas) <Key-space>

      destroy  $private(popupmenu)
      set ::confVisu::private($visuNo,fullscreen) "0"

      #--- je restaure les bind par defaut
      ::confVisu::createBindDialog $visuNo
      set private(image)          ""
      set private(visuNo)         ""
      set private(bufNo)          ""
      set private(hWindow)        ""
      set private(visuNo,hCanvas) ""

   }

   #------------------------------------------------------------------------------
   # loadNextItem
   #
   #------------------------------------------------------------------------------
   proc loadNextItem { } {
      variable private

      if { $private(currentItemIndex) < [expr [llength $private(files) ]-1] } {
         incr private(currentItemIndex)
      } else {
         set private(currentItemIndex) "0"
         bell
      }
      loadItem
   }

   #------------------------------------------------------------------------------
   # loadPreviousItem
   #
   #------------------------------------------------------------------------------
   proc loadPreviousItem { } {
      variable private

      if { $private(currentItemIndex) > "0" } {
         set private(currentItemIndex) [expr $private(currentItemIndex) -1]
      } else {
         set private(currentItemIndex) [expr [llength $private(files) ] -1]
         bell
      }
      loadItem
   }

   #------------------------------------------------------------------------------
   # changeZoom
   #
   # change la valeur du zoom private(zoom)
   # et affiche l'image ou le film avec le nouveau facteur de zoom
   #------------------------------------------------------------------------------
   proc changeZoom { zoom } {
      variable private
      global audace
      global conf

      if { $zoom == "auto" } {
         set private(zoom) "2.5"
      } else {
         set private(zoom) "$zoom"
      }

      visu$private(visuNo) zoom $private(zoom)

      #--- je rafraichis l'affichage du canvas
      loadItem
   }

   #------------------------------------------------------------------------------
   #  loadimage
   #     charge une image en plein ecran
   #------------------------------------------------------------------------------
   proc loadimage { filename zoom } {
      variable private

      #--- je masque la fenetre des films
      ::Movie::close $private(visuNo,hCanvas)

      set image   $private(image)
      set buf     "buf$private(bufNo)"
      set hCanvas $private(visuNo,hCanvas)

      #--- je charge le fichier dans le buffer
      set result [$buf load $filename]
      if {$result == ""} {
         image delete $image
         image create photo $image
         set seuil_haut [lindex [$buf getkwd MIPS-HI] 1]
         set seuil_bas  [lindex [$buf getkwd MIPS-LO] 1]
         #--- affiche l'image avec les seuils enregistres dans l'image
         visu$private(visuNo) zoom $zoom
         ::confVisu::autovisu $private(visuNo)
      }
      $private(visuNo,hCanvas) itemconfigure display -state normal
   }

   #------------------------------------------------------------------------------
   #  loadmovie
   #    charge un film dans la fenetre plein ecran
   #------------------------------------------------------------------------------
   proc loadmovie { filename } {
      variable private
      global audace

      #--- je masque la fenetre des images
      $private(visuNo,hCanvas) itemconfigure display -state hidden

      #--- je place la fenetre des film dans le canvas
      set maxsize [wm maxsize $audace(base)]
      set xc [expr [lindex $maxsize 0] /2 ]
      set yc [expr [lindex $maxsize 1] /2 ]

      #--- j'affiche le film
      ::Movie::open $filename $private(visuNo,hCanvas) $private(zoom) $xc $yc "center"
   }

   #------------------------------------------------------------------------------
   # setAnimationState
   #    active/desactive les boutons de commande de l'animation
   #
   #------------------------------------------------------------------------------
   proc setAnimationState { state } {
      variable private
      global caption

      set menu $private(popupmenu)

      #--- je configure le popup menu
      if { $state == 1 } {
         #--- j'active les commandes d'animation
         $menu entryconfigure $caption(fullscreen,animation) -state normal
      }  else {
         #--- je desactive les commandes d'animation
         $menu entryconfigure $caption(fullscreen,animation) -state disabled
      }
   }

   #------------------------------------------------------------------------------
   # toggleAnimation
   #
   #------------------------------------------------------------------------------
   proc toggleAnimation { } {
      variable private

      if { $private(animation) == 1 } {
         startAnimation
      } else {
         stopAnimation
      }
   }

   #------------------------------------------------------------------------------
   # startAnimation
   # Lance une animation (film ou GIF anime)
   #------------------------------------------------------------------------------
   proc startAnimation { } {
      variable private

      #--- je recupere le nom du fichier selectionne
      set index $private(currentItemIndex)
      set name [lindex [lindex $private(files) $index] 0 ]
      set type [lindex [lindex $private(files) $index] 1 ]
      set filename [file join "$private(directory)" "$name"]

      if { "$type" == "$private(fileImage)" } {
         ::Image::startGifAnimation $private(image) $private(zoom) "$filename"
      } elseif { "$type" == "$private(fileMovie)" } {
         ::Movie::start
      }
      set private(animation) 1
      update
   }

   #------------------------------------------------------------------------------
   # stopAnimation
   # Arrete une animation (film ou GIF anime)
   #------------------------------------------------------------------------------
   proc stopAnimation { } {
      variable private

      #--- je recupere le nom du fichier selectionne
      set index $private(currentItemIndex)
      set name [lindex [lindex $private(files) $index] 0 ]
      set type [lindex [lindex $private(files) $index] 1 ]
      set filename [file join "$private(directory)" "$name"]

      if { "$type" == "$private(fileImage)" } {
         ::Image::stopGifAnimation
      } elseif { "$type" == "$private(fileMovie)" } {
         ::Movie::stop
      }
      set private(animation) 0
      update
   }

   #------------------------------------------------------------------------------
   #  createPopupMenu
   #------------------------------------------------------------------------------
   proc createPopupMenu { visuNo } {
      variable private
      global caption
      global conf
      global audace
      global help

      set menu $private(toplevel).menufullscreen
      set private(popupmenu) "$menu"

      menu $menu -tearoff no
      $menu add command -label $caption(fullscreen,next_image) \
         -command { ::FullScreen::loadNextItem  }
      $menu add command -label $caption(fullscreen,previous_image) \
         -command { ::FullScreen::loadPreviousItem }
      $menu add checkbutton -label $caption(fullscreen,slide_show) \
         -variable private(slideShow) \
         -command { ::FullScreen::loadNextItem }

      $menu add separator
      $menu add cascade -label $caption(fullscreen,zoom) -menu $menu.zoom
      menu $menu.zoom -tearoff no
      $menu.zoom add radiobutton -label "$caption(fullscreen,zoom_0.125)" \
         -indicatoron "1" \
         -value "0.125" \
         -variable ::FullScreen::private(zoom) \
         -command { ::FullScreen::changeZoom "0.125" }
      $menu.zoom add radiobutton -label "$caption(fullscreen,zoom_0.25)" \
         -indicatoron "1" \
         -value "0.25" \
         -variable ::FullScreen::private(zoom) \
         -command { ::FullScreen::changeZoom "0.25" }
      $menu.zoom add radiobutton -label "$caption(fullscreen,zoom_0.5)" \
         -indicatoron "1" \
         -value "0.5" \
         -variable ::FullScreen::private(zoom) \
         -command { ::FullScreen::changeZoom "0.5" }
      $menu.zoom add radiobutton -label "$caption(fullscreen,zoom_1)" \
         -indicatoron "1" \
         -value "1" \
         -variable ::FullScreen::private(zoom) \
         -command { ::FullScreen::changeZoom "1" }
      $menu.zoom add radiobutton -label "$caption(fullscreen,zoom_2)" \
         -indicatoron "1" \
         -value "2" \
         -variable ::FullScreen::private(zoom) \
         -command { ::FullScreen::changeZoom "2" }
      $menu.zoom add radiobutton -label "$caption(fullscreen,zoom_4)" \
         -indicatoron "1" \
         -value "4" \
         -variable ::FullScreen::private(zoom) \
         -command { ::FullScreen::changeZoom "4" }
      #$menu.zoom add radiobutton -label "$caption(fullscreen,zoom_auto)" \
      #   -indicatoron "1" \
      #   -value "auto" \
      #   -variable ::FullScreen::private(zoom) \
      #   -command { ::FullScreen::changeZoom "auto" }

      $menu add separator
      $menu add checkbutton -label $caption(fullscreen,animation) \
         -variable ::FullScreen::private(animation) \
         -command { ::FullScreen::toggleAnimation }

      $menu add command -label $caption(fullscreen,configure) \
         -command { ::FullScreen::configure }

      $menu add command -label $caption(fullscreen,help) \
         -command {
            ::audace::showHelpPlugin "tool" "visio2" "visio2.htm" "fullscreen"
         }

      $menu add separator
      $menu add command -label $caption(fullscreen,close) \
         -command "::FullScreen::close $visuNo"

      bind $private(hCanvas) <ButtonPress-1> ""
      bind $private(hCanvas) <ButtonPress-3> [list tk_popup $menu %X %Y]
      bind $private(hCanvas) <Key-S>      { ::FullScreen::loadNextItem }
      bind $private(hCanvas) <Key-s>      { ::FullScreen::loadNextItem }
      bind $private(hCanvas) <Key-Down>   { ::FullScreen::loadNextItem }

      bind $private(hCanvas) <Key-P>      { ::FullScreen::loadPreviousItem }
      bind $private(hCanvas) <Key-p>      { ::FullScreen::loadPreviousItem }
      bind $private(hCanvas) <Key-Up>     { ::FullScreen::loadPreviousItem }

      bind $private(hCanvas) <MouseWheel> {
         if { %D > 0 } {
            ::FullScreen::loadNextItem
         } else {
            ::FullScreen::loadPreviousItem
         }
      }
      bind $private(toplevel) <Key-Escape> "::FullScreen::close $visuNo"
      bind $private(toplevel) <Key-space>  "::FullScreen::close $visuNo"
   }

   #------------------------------------------------------------
   #  initConf
   #     initialise les parametres dans le tableau conf()
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      if {![info exists conf(FullScreen,color)]}         { set conf(FullScreen,color)         "#000000" }
      if {![info exists conf(FullScreen,autoStartAnim)]} { set conf(FullScreen,autoStartAnim) "0" }
   }

   #------------------------------------------------------------------------------
   #  configure
   #   ouvre la fenetre de configuration
   #------------------------------------------------------------------------------
   proc configure { } {
      variable private
      global audace
      global conf

      #--- j'affiche la fenetre de configuration
      set confResult [::confGenerique::run "$audace(base).configfullscreen" "::FullScreen::config" $private(visuNo)]
      #if { $confResult == 1 } {
      #   $private(visuNo,hCanvas) configure -bg $conf(FullScreen,color)
      #}
      raise $private(toplevel)
      focus $private(toplevel)
   }

}

################################################################
# namespace ::FullScreen::config
#    fenetre de configuration de FullScreen
################################################################

namespace eval ::FullScreen::config {

   #==============================================================
   # Fonctions de configuration generiques appelees par ::confGenerique::run
   #
   # getLabel        retourne le titre de la fenetre de config
   # confToWidget    copie les parametres du tableau conf() dans les variables des widgets
   # widgetToConf    copie les variable des widgets dans le tableau conf()
   # fillConfigPage  affiche la fenetre de config
   #==============================================================

   #------------------------------------------------------------
   #  ::FullScreen::config::getLabel
   #  retourne le nom de la fenetre de configuration
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(fullscreen,title)"
   }

   #------------------------------------------------------------
   #  ::FullScreen::config::showHelp
   #  affiche l'aide de cette fenetre de configuration
   #------------------------------------------------------------
   proc showHelp { } {
      global help

      ::audace::showHelpPlugin "tool" "visio2" "visio2.htm" "fullscreen_config"
   }

   #------------------------------------------------------------
   #  ::FullScreen::config::confToWidget
   #     copie les parametres du tableau conf() dans les variables des widgets
   #------------------------------------------------------------
   proc confToWidget { visuNo } {
      variable private
      variable widget
      global conf

      set widget(color)         "$conf(FullScreen,color)"
      set widget(autoStartAnim) "$conf(FullScreen,autoStartAnim)"
   }

   #------------------------------------------------------------
   #  ::FullScreen::config::widgetToConf
   #     copie les variable des widgets dans le tableau conf()
   #------------------------------------------------------------
   proc widgetToConf { visuNo } {
      variable private
      variable widget
      global conf

      #--- j'enregistre la nouvelle configuration dans conf(...)
      set conf(FullScreen,color)         $widget(color)
      set conf(FullScreen,autoStartAnim) $widget(autoStartAnim)

      #--- j'applique la nouvelle configuration
      $::FullScreen::private(hCanvas) configure -bg $conf(FullScreen,color)
   }

   #------------------------------------------------------------
   #  ::FullScreen::config::fillConfigPage
   #     fenetre de configuration du panneau
   #
   #  return rien
   #
   #------------------------------------------------------------
   proc fillConfigPage { frm visuNo } {
      variable widget
      variable widgetEnableExtension
      global caption
      global conf

      #--- je memorise la reference de la frame
      set widget(frm) $frm

      #--- j'initialise les variables des widgets
      confToWidget $visuNo

      frame $frm.frameAnim -borderwidth 1 -relief raised
      pack $frm.frameAnim -side top -fill both -expand 1

      #--- demarrage automatique des animations
      checkbutton $frm.frameAnim.animation -text "$caption(fullscreen,auto_start_anim)" \
         -highlightthickness 0 -variable FullScreen::config::widget(autoStartAnim)
            pack $frm.frameAnim.animation -anchor center -side left -padx 10 -pady 5

      #--- frame choix couleur de fond
      frame $frm.frameColor -borderwidth 1 -relief raised
      pack $frm.frameColor -side top -fill both -expand 1

      label $frm.frameColor.labColor -text "$caption(fullscreen,color_label)"
           pack $frm.frameColor.labColor -in $frm.frameColor -anchor center -side left -padx 10 -pady 10

      button $frm.frameColor.butColor_color_invariant -relief raised -width 6 -bg $widget(color)\
         -command {
            set temp [ tk_chooseColor -initialcolor ${FullScreen::config::widget(color)} \
               -parent ${FullScreen::config::widget(frm)} -title ${caption(fullscreen,title)} ]
            if  { "$temp" != "" } {
               set FullScreen::config::widget(color) "$temp"
               ${FullScreen::config::widget(frm)}.frameColor.butColor_color_invariant configure \
                  -bg ${FullScreen::config::widget(color)}
            }
         }
      pack $frm.frameColor.butColor_color_invariant -in $frm.frameColor -anchor center -side left -padx 10 -pady 5 -ipady 5
   }

}

