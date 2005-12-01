#
# Fichier : fullscreen.tcl
# Description : Fenetre plein ecran pour afficher des images
# Auteur : Michel PUJOL
# Date de mise a jour : 18 decembre 2004
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
   proc showBuffer { inputBuffer } {
      variable private  

      set private(files)       ""
      set private(inputBuffer) $inputBuffer
      #--- je cree la fenetre plein ecran
      createFullscreen
      #--- je charge l'image contenue dans le buffer
      loadItem            
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
   #  open
   #   ouvre la fenetre plein ecran
   #------------------------------------------------------------------------------
   proc createFullscreen { } {
      variable private  
      global audace
      global conf

      set private(this) "$audace(base).fullscreen" 
      if { [winfo exists $private(this)] } {
         wm withdraw $private(this)
         wm deiconify $private(this)
         return
      }
      
      #--- je verifie que les variables de cette fenetre existent dans $conf(...)
      initConf

      #--- Cree la fenetre plein ecran 
      toplevel $private(this) -class Frame
      wm resizable $private(this) 0 0
      wm title $private(this) "Aud'Ace Full screen"
      #--- je supprime le titre et les bordures de la fenetre
      wm overrideredirect  $private(this) 1
      #--- j'affiche la fenetre en plein ecran
      set maxsize [wm maxsize $audace(base)]
      wm geometry $private(this) [lindex $maxsize 0]x[lindex $maxsize 1]+0+0
      #wm state $private(this) zoomed

      #--- je cree le canvas
      set private(hCanvas)  $private(this).canvas_color_invariant 
      canvas $private(hCanvas) -highlightthickness 0  -borderwidth 0 \
         -bg $conf(FullScreen,color) \
         -width [lindex $maxsize 0] -height [lindex $maxsize 1]          
      pack $private(hCanvas) -in $private(this) -anchor center -expand 1 -fill both

      #--- je cree le tag pour afficher les images
      set private(imageNo) "9"
      set private(image) "image$private(imageNo)"
      image create photo $private(image)
      set xc [expr [lindex $maxsize 0] /2  ]
      set yc [expr [lindex $maxsize 1] /2  ]
      
      $private(hCanvas) create image $xc $yc -anchor center -tag display
      $private(hCanvas) itemconfigure display -image $private(image)
      
      #--- je cree la fenetre pour afficher les films
      set private(hWindow) $private(hCanvas).movie  
      #--- (le widget "label" est la plus simple des fenetres)
      label $private(hWindow) -bg darkGreen 

      #--- je cree le buffer et la visu pour traiter les fichiers fits
      set private(bufNo)  [::buf::create]
      set private(visuNo) [::visu::create $private(bufNo) $private(imageNo)]
       
      #--- je cree le popup menu
      createPopupMenu
      update
      
      set audace(fullscreen) 1
      #--- je donne le focus à la fenetre plein ecran
      focus $private(this)
      
      set private(currentItemIndex) 0

      ::confColor::applyColor $private(this)
   }

   #------------------------------------------------------------------------------
   #  close
   #   ferme la fenetre plein ecran
   #------------------------------------------------------------------------------
   proc close { } {
      variable private
      global audace
      
      stopAnimation
      
      catch {
         ::Movie::close $private(hCanvas)
      }
      
      #--- je supprime les objets graphiques
      image delete $private(image)
      ::visu::delete $private(visuNo)
      ::buf::delete $private(bufNo)
      destroy $private(this)

      set private(image)   ""
      set private(visuNo)  ""
      set private(bufNo)   ""
      set private(hWindow) ""
      set private(hCanvas) ""

      set audace(fullscreen) 0
      after idle "destroy $private(this)"
   }

   #------------------------------------------------------------------------------
   # loadItem 
   #
   #  charge le fichier ou le buffer
   #------------------------------------------------------------------------------
   proc loadItem  { } {
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
         ::Movie::close $private(hCanvas)
      
         set index $private(currentItemIndex)
         set name [lindex [lindex $private(files) $index] 0 ]
         set type [lindex [lindex $private(files) $index] 1 ] 
         set filename [file join "$private(directory)" "$name"]
             
         if { [string first "$private(fileImage)" "$type" ] != -1 } {
            #--- j'affiche l'image
            loadimage $filename $private(zoom)
            if  { [::Image::isAnimatedGIF "$filename"] == 1 } {
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
         #--- j'affiche l'image contenue dans le buffer
         set result [$private(inputBuffer) copyto $private(bufNo) ]
         if {$result == ""} {
            image delete $private(image) 
            image create photo $private(image)
            #--- j'affiche l'image avec les seuils enregistres dans l'image
            visu$private(visuNo) zoom $private(zoom)
            ::audace::autovisu visu$private(visuNo)
         }
      }
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
         set private(currentItemIndex) 0
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
                
      if { $private(currentItemIndex) > 0  } {
         set private(currentItemIndex)  [expr $private(currentItemIndex) -1]
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
      ::Movie::close $private(hCanvas)
      
      set image   $private(image)
      set buf     "buf$private(bufNo)"
      set visu    "visu$private(visuNo)"
      set hCanvas $private(hCanvas)

      #--- je charge le fichier dans le buffer
      set result [$buf load $filename]
      if {$result == ""} {
         image delete $image 
         image create photo $image
         set seuil_haut [lindex [$buf getkwd MIPS-HI] 1]
         set seuil_bas  [lindex [$buf getkwd MIPS-LO] 1]
         #--- affiche l'image avec les seuils enregistres dans l'image
         $visu zoom $zoom
         ::audace::autovisu $visu
      }
      $private(hCanvas) itemconfigure display -state normal
   }

   #------------------------------------------------------------------------------
   #  loadmovie
   #    charge un film dans la fenetre plein ecran
   #------------------------------------------------------------------------------
   proc loadmovie { filename } {
      variable private
      global audace
      
      #--- je masque la fenetre des images 
      $private(hCanvas) itemconfigure display -state hidden

      #--- je place la fenetre des film dans le canvas
      set maxsize [wm maxsize $audace(base)]
      set xc [expr [lindex $maxsize 0] /2  ]
      set yc [expr [lindex $maxsize 1] /2  ]

      #--- j'affiche le film
      #createMovieWindow
      ::Movie::open $filename $private(hCanvas) $private(zoom) $xc $yc "center" 
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
      if { $state == 1 }  {
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
   # arrete une animation (film ou GIF anime)
   #------------------------------------------------------------------------------
   proc stopAnimation { } {
      variable private 
      
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
   proc createPopupMenu { } {
      global caption
      global conf
      global audace
      global help
      variable private

      set menu $private(this).menu
      set private(popupmenu) "$menu"

      menu $menu -tearoff no      
      $menu add command -label $caption(fullscreen,next_image)  \
         -command { ::FullScreen::loadNextItem  }
      $menu add command -label $caption(fullscreen,previous_image)  \
         -command { ::FullScreen::loadPreviousItem  }
      $menu add checkbutton -label $caption(fullscreen,slide_show)  \
         -variable private(slideShow)      \
         -command { ::FullScreen::loadNextItem   }

      $menu add separator        
      $menu add cascade -label $caption(fullscreen,zoom) -menu $menu.zoom       
      menu $menu.zoom -tearoff no
      $menu.zoom add radiobutton -label "$caption(fullscreen,zoom_0.25)" \
         -indicatoron "1" \
         -value "0.25" \
         -variable ::FullScreen::private(zoom) \
         -command { ::FullScreen::changeZoom "0.25"  }
      $menu.zoom add radiobutton -label "$caption(fullscreen,zoom_0.5)" \
         -indicatoron "1" \
         -value "0.5" \
         -variable ::FullScreen::private(zoom) \
         -command { ::FullScreen::changeZoom "0.5"  }
      $menu.zoom add radiobutton -label "$caption(fullscreen,zoom_1)" \
         -indicatoron "1" \
         -value "1" \
         -variable ::FullScreen::private(zoom) \
         -command { ::FullScreen::changeZoom "1"  }
      $menu.zoom add radiobutton -label "$caption(fullscreen,zoom_2)" \
         -indicatoron "1" \
         -value "2" \
         -variable ::FullScreen::private(zoom) \
         -command { ::FullScreen::changeZoom "2"  }
      #$menu.zoom add radiobutton -label "$caption(fullscreen,zoom_auto)" \
      #   -indicatoron "1" \
      #   -value "auto" \
      #   -variable ::FullScreen::private(zoom) \
      #   -command { ::FullScreen::changeZoom "auto" }

      $menu add separator        
      $menu add checkbutton -label $caption(fullscreen,animation)    \
         -variable  ::FullScreen::private(animation)       \
         -command { ::FullScreen::toggleAnimation  }

      $menu add command -label $caption(fullscreen,configure)  \
         -command { ::FullScreen::configure  }
         
      $menu add command -label $caption(fullscreen,help)  \
         -command { 
            ::audace::showHelpPlugin "tool" "visio2" "visio2.htm" "fullscreen"
         }

      $menu add separator        
      $menu add command -label $caption(fullscreen,close)  \
         -command { ::FullScreen::close  }

      bind $private(this) <<Button3>> [list tk_popup $menu %X %Y]
      bind $private(this) <Key-S>      { ::FullScreen::loadNextItem }
      bind $private(this) <Key-s>      { ::FullScreen::loadNextItem }
      bind $private(this) <Key-Down>   { ::FullScreen::loadNextItem }
       
      bind $private(this) <Key-P>      { ::FullScreen::loadPreviousItem }
      bind $private(this) <Key-p>      { ::FullScreen::loadPreviousItem }
      bind $private(this) <Key-Up>     { ::FullScreen::loadPreviousItem }
      
      bind $private(this) <MouseWheel> { 
         if { %D > 0 } {
            ::FullScreen::loadNextItem     
         } else {
            ::FullScreen::loadPreviousItem
         }
      }
      
      bind $private(this) <Key-Escape> { ::FullScreen::close }
      bind $private(this) <Key-space>  { ::FullScreen::close }
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
      set confResult [::confGenerique::run "$audace(base).configfullscreen" "::FullScreen::config"]
      #if { $confResult == 1 } {
      #   $private(hCanvas) configure -bg $conf(FullScreen,color)
      #}
      raise $private(this)
      focus $private(this)
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
   proc confToWidget { } {   
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
   proc widgetToConf { } {   
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
   proc fillConfigPage { frm } {
      variable widget 
      variable widgetEnableExtension
      global caption
      global conf

      #--- je memorise la reference de la frame 
      set widget(frm) $frm

      #--- j'initialise les variables des widgets
      confToWidget

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

