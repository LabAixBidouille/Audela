#
# Fichier : superpad.tcl
# Description : Super raquette virtuelle
# Auteur : Michel PUJOL
# Mise a jour $Id: superpad.tcl,v 1.11 2007-02-12 12:39:27 robertdelmas Exp $
#

package provide superpad 1.0

#==============================================================
# Procedures generiques obligatoires (pour configurer tous les drivers camera, telescope, equipement) :
#     init              : initialise le namespace (appelee pendant le chargement de ce source)
#     getLabel          : retourne le nom affichable du driver
#     getHelp           : retourne la documentation htm associee
#     getDriverType     : retourne le type de driver (pour classer le driver dans le menu principal)
#     initConf          : initialise les parametres de configuration s'il n'existe pas dans le tableau conf()
#     fillConfigPage    : affiche la fenetre de configuration de ce driver
#     confToWidget      : copie le tableau conf() dans les variables des widgets
#     widgetToConf      : copie les variables des widgets dans le tableau conf()
#     configureDriver   : configure le driver
#     stopDriver        : arrete le driver et libere les ressources occupees
#     isReady           : informe de l'etat de fonctionnement du driver
#
# Procedures specifiques a ce driver :
#     run               : affiche la raquette
#
#==============================================================

namespace eval ::superpad {

   #==============================================================
   # Procedures generiques de configuration des drivers
   #==============================================================

   #------------------------------------------------------------
   #  init (est lance automatiquement au chargement de ce fichier tcl)
   #     initialise le driver
   #
   #  return namespace name
   #------------------------------------------------------------
   proc init { } {
      global audace

      #--- charge le fichier caption
      source [ file join $audace(rep_plugin) pad superpad superpad.cap ]

      #--- cree les variables dans conf(..) si elles n'existent pas
      initConf

      #--- j'initialise les variables widget(..)
      confToWidget

      return [namespace current]
   }

   #------------------------------------------------------------
   #  getDriverType
   #     retourne le type de driver
   #
   #  return "pad"
   #------------------------------------------------------------
   proc getDriverType { } {
      return "pad"
   }

   #------------------------------------------------------------
   #  getLabel
   #     retourne le label du driver
   #
   #  return "Titre de l'onglet (dans la langue de l'utilisateur)"
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(superpad,titre)"
   }

   #------------------------------------------------------------
   #  getHelp
   #     retourne la documentation du driver
   #
   #  return "nom_driver.htm"
   #------------------------------------------------------------
   proc getHelp { } {
      return "superpad.htm"
   }

   #------------------------------------------------------------
   #  initConf
   #     initialise les parametres dans le tableau conf()
   #
   #  return rien
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      if { ! [ info exists conf(superpad,padsize) ] }      { set conf(superpad,padsize)      "0.5" }
      if { ! [ info exists conf(superpad,centerspeed) ] }  { set conf(superpad,centerspeed)  "140" }
      if { ! [ info exists conf(superpad,visible) ] }      { set conf(superpad,visible)      "1" }
      if { ! [ info exists conf(superpad,position) ] }     { set conf(superpad,position)     "100+100" }
      if { ! [ info exists conf(superpad,focuserLabel) ] } { set conf(superpad,focuserLabel) "focuserjmi" }

      return
   }

   #------------------------------------------------------------
   #  confToWidget
   #     copie les parametres du tableau conf() dans les variables des widgets
   #
   #  return rien
   #------------------------------------------------------------
   proc confToWidget { } {
      variable widget
      global conf

      set widget(padsize)      $conf(superpad,padsize)
      set widget(visible)      $conf(superpad,visible)
      set widget(centerspeed)  $conf(superpad,centerspeed)
      set widget(focuserLabel) $conf(superpad,focuserLabel)
   }

   #------------------------------------------------------------
   #  widgetToConf
   #     copie les variables des widgets dans le tableau conf()
   #
   #  return rien
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(superpad,padsize)      $widget(padsize)
      set conf(superpad,visible)      $widget(visible)
      set conf(superpad,centerspeed)  $widget(centerspeed)
      set conf(superpad,focuserLabel) $widget(focuserLabel)
   }

   #------------------------------------------------------------
   #  fillConfigPage
   #     fenetre de configuration du driver
   #
   #  return nothing
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      variable private
      global caption

      #--- je memorise la reference de la frame
      set widget(frm) $frm

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 0

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 0

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill both -expand 0

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side top -fill both -expand 0

      #--- Label pad size
      label $frm.labSize -text "$caption(superpad,pad_size)"
      pack $frm.labSize -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

      #--- Definition de la taille de la raquette
      set list_combobox [ list 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 ]
      ComboBox $frm.taille \
         -width 7          \
         -height [llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable ::superpad::widget(padsize) \
         -values $list_combobox
      pack $frm.taille -in $frm.frame1 -anchor nw -side left -padx 10 -pady 10

      #--- Definition centerspeed
      label $frm.labcenterspeed -text "$caption(superpad,center_speed)"
      pack $frm.labcenterspeed -in $frm.frame2 -anchor nw -side left -padx 10 -pady 10

      #--- Entry centerspeed
      entry $frm.entrycenterspeed -relief groove -width 5 -textvariable ::superpad::widget(centerspeed) -justify center
      pack $frm.entrycenterspeed -in $frm.frame2 -anchor nw -side left -padx 10 -pady 10

      #--- Frame focuser
      ::confEqt::createFrameFocuser $frm.frame3.focuser ::superpad::widget(focuserLabel)
      pack $frm.frame3.focuser -in $frm.frame3 -anchor nw -side left -padx 10 -pady 10

      #--- Raquette toujours visible
      checkbutton $frm.visible -text "$caption(superpad,pad_visible)" -highlightthickness 0 \
         -variable ::superpad::widget(visible) -onvalue 1 -offvalue 0
      pack $frm.visible -in $frm.frame4 -anchor nw -side left -padx 10 -pady 10
   }

   #------------------------------------------------------------
   #  configureDriver
   #     configure le driver
   #
   #  return nothing
   #------------------------------------------------------------
   proc configureDriver { } {
      global conf

      #--- affiche la raquette
      run $conf(superpad,padsize) $conf(superpad,position)

      return
   }

   #------------------------------------------------------------
   #  stopDriver
   #     sauvegarde les parametres courants
   #     et libere les ressources occupees
   #
   #  return nothing
   #------------------------------------------------------------
   proc stopDriver { } {
      global conf

      if { [ winfo exists .superpad ] } {
         #--- enregistre la position de la raquette
         set geom [wm geometry .superpad]
         set deb [expr 1+[string first + $geom ]]
         set fin [string length $geom]
         set conf(superpad,position) "[string range  $geom $deb $fin]"

         #--- supprime la raquette
         catch { destroy .superpad }
      }

      return
   }

   #------------------------------------------------------------
   #  isReady
   #     informe de l'etat de fonctionnement du driver
   #
   #  return 0 (ready) , 1 (not ready)
   #------------------------------------------------------------
   proc isReady { } {
      return 0
   }

   #==============================================================
   # Procedures specifiques du driver
   #==============================================================

   proc run { {zoom .4} {positionxy 0+0} } {
      if { [ string length [ info commands .superpad.display* ] ] != "0" } {
         destroy .superpad
      }

      if { $zoom <= "0" } {
         destroy .superpad
         return
      }

      # =======================================
      # === Initialisation of the variables
      # === Initialisation des variables
      # =======================================

      #--- Definition of global variables (arrays)
      #--- Definition des variables globales (arrays)
      variable widget
      global caption       #--- Texts of captions
      global geompad       #--- geompad size of widgets
      global langage
      global statustel
      global conf
      global audace
      global colorpad
      global color

      #--- Definition of colorpads
      #--- Definition des couleurs
      set colorpad(backkey)  $color(gray_pad)
      set colorpad(backpad)  $color(blue_pad)
      set colorpad(backdisp) $color(red_pad)
      set colorpad(textkey)  $color(white)
      set colorpad(green)    $color(green)

      #--- Definition des geompadetries
      #--- Definition of geometry
      set geompad(larg)       [ expr int(340*$zoom+10) ]
      set geompad(long)       [ expr int(600*$zoom+40) ]
      set geompad(fontsize50) [ expr int(36*$zoom) ]
      set geompad(fontsize25) [ expr int(25*$zoom) ]
      set geompad(fontsize20) [ expr int(20*$zoom) ]
      set geompad(fontsize16) [ expr int(16*$zoom) ]
      set geompad(fontsize14) [ expr int(14*$zoom) ]
      set geompad(fontsize10) [ expr int(10*$zoom) ]
      set geompad(10pixels)   [ expr int(10*$zoom) ]
      set geompad(20pixels)   [ expr int(20*$zoom) ]
      set geompad(larg2)      [ expr int(85*$zoom) ]
      set geompad(haut2)      [ expr int(65*$zoom) ]
      set geompad(haut)       [ expr int(70*$zoom) ]
      set geompad(linewidth0) [ expr int(3*$zoom) ]
      set geompad(linewidth)  [ expr int($geompad(linewidth0)+1) ]
      set geompad(lightx1)    [ expr int(10*$zoom) ]
      set geompad(lighty1)    [ expr int(30*$zoom) ]
      set geompad(lightx2)    [ expr int(20*$zoom) ]
      set geompad(lighty2)    [ expr int(40*$zoom) ]
      if { $geompad(linewidth0) <= "1" } { set geompad(textthick) "" } else { set geompad(textthick) "bold" }

      # =========================================
      # === Setting main window
      # =========================================

      #--- Create the toplevel window .superpad
      #--- Cree la fenetre .superpad de niveau le plus haut
      if { [ winfo exists .superpad ] } {
         destroy .superpad
      }
      toplevel .superpad -class Toplevel -bg $colorpad(backpad)
      wm geometry .superpad $geompad(larg)x$geompad(long)+$positionxy
      wm resizable .superpad 0 0
      wm title .superpad $caption(superpad,titre)

      #--- Destroy the toplevel window with the upper right cross
      #--- Detruit la fenetre principale avec la croix en haut a droite
      bind .superpad <Destroy> {
         ::superpad::stopDriver
      }

      # =========================================
      # === Setting subwindows
      # =========================================

      #--- add frame with manual motion buttons
      ::telescopePad::addFrame .superpad $zoom

      #--- add frame with alignment buttons (goto, center, ...)
      ::AlignManager::addFrame .superpad

      #--- add frame to manage focus
      ::FrameFocusManager::addFrame .superpad $zoom

      #--- Initialisation de la position du telescope
      ::telescopePad::init

      #--- La fenetre est active
      focus .superpad

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind .superpad <Key-F1> { ::console::GiveFocus }

   }

}

###################################################################
#      MovePad                                                    #
###################################################################

namespace eval ::telescopePad {
   variable This

   array set private {
      telescopeRa    ""
      telescopeDec   ""
   }

   proc init { } {
      displayCoord
      update
   }

   #------------------------------------------------------------
   #  displayCoord
   #     affiche les coordonn�es fournies par skysensor
   #------------------------------------------------------------
   proc displayCoord { } {
      variable private
      global caption
      global audace

      if {[::tel::list]!=""} {
         set radec [ tel$audace(telNo) radec coord ]
         #--- affiche les coordonnees
         set private(telescopeRa)  [lindex $radec  0]
         set private(telescopeDec) [lindex $radec  1]
     } else {
         #--- display error
         set private(telescopeRa)  "$caption(superpad,telescope)"
         set private(telescopeDec) "$caption(superpad,non_connecte)"
      }
      update
   }

   #------------------------------------------------------------
   #  addFrame
   #      add a frame with move button
   #------------------------------------------------------------
   proc addFrame { parentFrame zoom } {
      variable This
      variable private
      global audace
      global panneau
      global caption
      global colorpad
      global geompad
      global statustel

      set This $parentFrame.movepad
      set statustel(speed) 1

      frame $This -borderwidth 0  -bg $colorpad(backpad) -borderwidth 2 -relief groove

      #--- Frame des boutons de deplacement manuel

      #--- Create a frame for the cardinal buttons
      #--- Cree un espace pour les boutons cardinaux
      frame $This.card -height 150 -borderwidth 0 -relief flat -bg $colorpad(backpad)
      pack $This.card -in $This -side top -fill x -padx 2

      #--- Frame for speed choice
      frame $This.card.speed -width $geompad(20pixels) \
         -bg $colorpad(backpad)
      pack $This.card.speed -in $This.card -side left -fill y -expand 1

      radiobutton $This.card.speed.4 -indicatoron 0 \
         -font [ list {Arial} $geompad(fontsize16) $geompad(textthick) ] \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -selectcolor $colorpad(backdisp) \
         -text "4" -value 4 -variable audace(telescope,speed) \
         -command { ::telescope::setSpeed "4" }

      radiobutton $This.card.speed.3 -indicatoron 0 \
         -font [ list {Arial} $geompad(fontsize16) $geompad(textthick) ] \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -selectcolor $colorpad(backdisp) \
         -highlightcolor $colorpad(green) \
         -text "3" -value 3 -variable audace(telescope,speed) \
         -command { ::telescope::setSpeed "3" }

      radiobutton $This.card.speed.2  -indicatoron 0 \
         -font [ list {Arial} $geompad(fontsize16) $geompad(textthick) ] \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -selectcolor $colorpad(backdisp) \
         -text "2" -value 2 -variable audace(telescope,speed) \
         -command { ::telescope::setSpeed "2" }

      radiobutton $This.card.speed.1 -indicatoron 0 \
         -font [ list {Arial} $geompad(fontsize16) $geompad(textthick) ] \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -selectcolor $colorpad(backdisp) \
         -text "1" -value 1 -variable audace(telescope,speed) \
         -command { ::telescope::setSpeed "1" }

      pack $This.card.speed.4 -in $This.card.speed  -fill y -expand 1
      pack $This.card.speed.3 -in $This.card.speed  -fill y -expand 1
      pack $This.card.speed.2 -in $This.card.speed  -fill y -expand 1
      pack $This.card.speed.1 -in $This.card.speed  -fill y -expand 1

      button  $This.card.w -borderwidth 4 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text "W" \
         -width 2 \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -anchor center \
         -relief ridge

      frame $This.card.ns \
         -width $geompad(larg2) \
         -borderwidth 0 -relief flat -bg $colorpad(backpad)

      button  $This.card.ns.n -borderwidth 4 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text "N" \
         -width 2 \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -anchor center \
         -relief ridge

      button  $This.card.ns.s -borderwidth 4 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text "S" \
         -width 2 \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -anchor center \
         -relief ridge

      button  $This.card.e -borderwidth 4 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text "E" \
         -width 2 \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -anchor center \
         -relief ridge

      pack $This.card.e -in $This.card -side left -expand 1 -padx 2 -pady 2
      pack $This.card.ns -in $This.card -side left -expand 1 -fill x
      pack $This.card.ns.n -in $This.card.ns -side top  -padx 2 -pady 2
      pack $This.card.ns.s -in $This.card.ns -side bottom  -padx 2 -pady 2
      pack $This.card.w  -in $This.card -side right -expand 1 -padx 2 -pady 2

      pack $This.card -in $This -fill both -expand 1

      #--- Frame des coordonnees
      frame $This.frameCoord -borderwidth 1  -relief groove -bg $colorpad(backpad)

      #--- Label pour RA
      label  $This.frameCoord.labelRa \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable audace(telescope,getra) -bg $colorpad(backpad) -fg $colorpad(textkey) -relief groove -width 10
      pack   $This.frameCoord.labelRa -in $This.frameCoord -anchor center -fill x  -side left

      #--- Label pour DEC
      label  $This.frameCoord.labelDec \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable audace(telescope,getdec) -bg $colorpad(backpad) -fg $colorpad(textkey) -relief groove -width 10
      pack   $This.frameCoord.labelDec -in $This.frameCoord -anchor center -fill x

      pack $This.frameCoord -in $This  -fill x

      pack $This -in $parentFrame  -fill both -expand 1

      #--- bind Cardinal move button
      bind $This.card.e <ButtonPress-1>      { ::telescope::move e }
      bind $This.card.e <ButtonRelease-1>    { ::telescope::stop e }
      bind $This.card.w <ButtonPress-1>      { ::telescope::move w }
      bind $This.card.w <ButtonRelease-1>    { ::telescope::stop w }
      bind $This.card.ns.s <ButtonPress-1>   { ::telescope::move s }
      bind $This.card.ns.s <ButtonRelease-1> { ::telescope::stop s }
      bind $This.card.ns.n <ButtonPress-1>   { ::telescope::move n }
      bind $This.card.ns.n <ButtonRelease-1> { ::telescope::stop n }

      #--- bind display zone
      bind $This.frameCoord <ButtonPress-1>            { ::telescope::afficheCoord }
      bind $This.frameCoord.labelRa <ButtonPress-1>    { ::telescope::afficheCoord }
      bind $This.frameCoord.labelDec <ButtonPress-1>   { ::telescope::afficheCoord }

   }

}

###################################################################
#      AlignManager                                               #
###################################################################

namespace eval ::AlignManager {
   array set private {
      This        ""
      targetRa    ""
      targetDec   ""
      targetName  ""
      mountSide   "e"
   }

   #------------------------------------------------------------
   #  cmdAlign
   #     aligne le telescope sur les coordonnees l'objet cible
   #------------------------------------------------------------
   proc cmdAlign { } {
      variable private

      ::telescope::match [list $private(targetRa) $private(targetDec)]
   }

   #------------------------------------------------------------
   #  cmdCenterStar
   #
   #------------------------------------------------------------
   proc cmdCenterStar { } {
      centerStar
      ::telescopePad::displayCoord
   }

   #------------------------------------------------------------
   #  centerStar
   #  deplace le telescope pour centre l'�toile s�lectionn�e au milieu de l'image
   #  s'il n'existe pas de fenetre de s�lection, c'est l'�toile la plus brillante
   #  de l'image qui est ramen�e au centre
   #------------------------------------------------------------
   proc centerStar { } {
      variable private
      global audace
      global caption
      global conf

      if {[info exists audace(picture,w)]!=1} {
         tk_messageBox -type ok -icon warning -title $caption(superpad,ErrorMessageTitle) \
            -message "$caption(superpad,CenterStarErrMsg)"
         return
      }

      #--- get selected box
      if {[info exists audace(box)]==1} {
         #--- use selected box
         set box $audace(box)
      } else {
         #--- else, use all picture
         tk_messageBox -type ok -icon warning -title $caption(superpad,ErrorMessageTitle) \
            -message "$caption(superpad,CenterStarErrMsg)"
         return
      }

      #--- abort if black picture
      set average [lindex [stat] 5]
      if { $average == 0 } {
         return
      }

      #--- disable center button
      $private(This).fraAlign.butCenter configure -state disabled

      #--- get coordinates of the brigtest point of the box
      set buffer buf$audace(bufNo)
      set starCoord [$buffer centro $box 3]
      set x [expr round([lindex $starCoord 0])]
      set y [expr round([lindex $starCoord 1])]

      #--- get distance from center
      set deltax [expr $x - $audace(picture,w)/2 ]
      set deltay [expr $y - $audace(picture,h)/2 ]

      set binning [lindex [buf$audace(bufNo) getkwd "BIN1"] 1]

      #--- evalate moving time in milliseconds for RA
      if { [expr $deltax ]>0 } {
         set moveTime [expr int($deltax * $conf(superpad,centerspeed) ) ]
      } else {
         set moveTime [expr int($deltax * $conf(superpad,centerspeed) * -1) ]
      }
      set moveTime [expr int($moveTime * $binning / 4 ) ]
      set camNo $::confCam(A,camNo)
      set mirx [cam$camNo mirrorx]
      set miry [cam$camNo mirrory]

      if {    (([expr $deltax] >0 ) && ($mirx==0) && ($private(mountSide)=="e" )) 
           || (([expr $deltax] <0 ) && ($mirx==1) && ($private(mountSide)=="e" )) 
           || (([expr $deltax] <0 ) && ($mirx==0) && ($private(mountSide)=="w" )) 
           || (([expr $deltax] >0 ) && ($mirx==1) && ($private(mountSide)=="w" ))} {
          console::disp "move $moveTime ms\nto est \n"
          set direction "e"
      } else {
         console::disp "move $moveTime ms\nto west \n"
          set direction "w"
      }

      #--- if necessary use medium speed
      if { [expr $moveTime] > 3000 } {
         ::telescope::setSpeed "3"
         #logInfo "telss2k.centerStar moveTime=[expr ($moveTime -2)/4 ] ms to $direction \n "
         ::telescope::move $direction
         after [expr ($moveTime -2500)/16 ]
         ::telescope::stop $direction
         set moveTime  2000
      }

      #--- use low speed
      if { [expr $moveTime] > 100 } {
         ::telescope::setSpeed "2"
         ::telescope::move $direction
         #logInfo "telss2k.centerStar moveTime=$moveTime ms to $direction \n "
         after $moveTime
         ::telescope::stop $direction
      }

      set binning [lindex [buf$audace(bufNo) getkwd "BIN2"] 1]

      #--- evalate moving time in milliseconds for DEC
      if { [expr $deltay ]>0 } {
         set moveTime [expr int($deltay * $conf(superpad,centerspeed) ) ]
      } else {
        set moveTime [expr int($deltay * $conf(superpad,centerspeed) * -1) ]
      }
      set moveTime [expr int($moveTime * $binning / 4 ) ]

      if {    (([expr $deltay ]>0) && ($miry==0) && ($private(mountSide)=="e" )) 
           || (([expr $deltay ]<0) && ($miry==1) && ($private(mountSide)=="e" )) 
           || (([expr $deltay ]<0) && ($miry==0) && ($private(mountSide)=="w" )) 
           || (([expr $deltay ]>0) && ($miry==1) && ($private(mountSide)=="w" )) } {
          console::disp "move $moveTime ms\nto north \n"
          set direction "n"
      } else {
          console::disp "move $moveTime ms\nto south \n"
          set direction "s"
      }

      #--- if necessary use medium speed
      if { [expr $moveTime] > 3000 } {
         ::telescope::setSpeed "3"
         ::telescope::move $direction
         #logInfo "telss2k.centerStar moveTime=[expr ($moveTime -2)/4 ] ms to $direction \n "
         after [expr ($moveTime -2500)/16 ]
         ::telescope::stop $direction
         set moveTime  2000
      }

      #--- use low speed
      if { [expr $moveTime] > 100 } {
         ::telescope::setSpeed "2"
         ::telescope::move $direction
         after $moveTime
         ::telescope::stop $direction
      }

      #--- restore speed=Low
      ::telescope::setSpeed "2"

      #-- enable center button
      $private(This).fraAlign.butCenter configure -state normal
   }

   #------------------------------------------------------------
   #  cmdChangeMountSide
   #
   #------------------------------------------------------------
   proc cmdChangeMountSide { } {
      variable private

      if { $private(mountSide) == "w" } {
         set private(mountSide) "e"
      } else {
         set private(mountSide) "w"
      }

      update
   }

   #------------------------------------------------------------
   #  cmdStartGoto
   #     pointe l'objet cible
   #------------------------------------------------------------
   proc cmdStartGoto { } {
      variable This
      variable private

      ::telescope::goto [list $private(targetRa) $private(targetDec)] "0" $This.frameGoto.buttonStartGoto
   }

   #------------------------------------------------------------
   #  cmdSelectStar
   #     show dialog window DlgSelectStar
   #     display name, ra, dec of selected star in the frame
   #------------------------------------------------------------
   proc cmdSelectStar { } {
      variable private

      set coord [::DlgSelectStar::run]
      if { [string compare $coord ""]==0 } {
         #--- if no star selected, do nothing
         return
      }
      set private(targetRa)   "[lindex $coord 0]"
      set private(targetDec)  "[lindex $coord 1]"
      set private(targetName) "[lindex $coord 3]"
      update
   }

   #------------------------------------------------------------
   #  cmdSkyMap
   #     recupere et affiche les coordonn�es dans une carte
   #     si les donnees ne sont pas obtenues , l'affichage n'est pas modifie
   #------------------------------------------------------------
   proc cmdSkyMap { } {
      variable private

      set result [::carte::getSelectedObject]
      if { [llength $result] == 3 } {

         set now now
         catch {set now [::audace::date_sys2ut now]}
         set listv [modpoi_catalogmean2apparent [lindex $result 0] [lindex $result 1] J2000.0 $now]
         set ra [lindex $listv 0]
         set ra [mc_angle2hms $ra 360 nozero 1 auto string]
         set ra [string range $ra 0 [string first "s" "$ra" ] ]

         set dec [lindex $listv 1]
         set dec [mc_angle2dms $dec 90 nozero 0 + string]
         set dec [string range $dec 0 [string first "s" "$dec" ] ]

         set private(targetRa)   "$ra"
         set private(targetDec)  "$dec"
         set private(targetName) "[ lindex $result 2 ]"
         update
      }
   }

   #------------------------------------------------------------
   # modpoi_catalogmean2apparent
   #  Input
   # rae,dece : coordinates J2000.0 (degrees)
   # Output
   # rav,decv : true coordinates (degrees)
   # Hv : true hour angle (degrees)
   # hv : true altitude altaz coordinate (degrees)
   # azv : true azimut altaz coodinate (degrees)
   #------------------------------------------------------------
   proc modpoi_catalogmean2apparent { rae dece equinox date } {
      global audace modpoi

      set modpoi(pi) 3.1415926535897
      set modpoi(deg2rad) [expr $modpoi(pi)/180.]
      set modpoi(rad2deg) [expr 180./$modpoi(pi)]

      if {[info exists modpoi(var,home)]==0} {
         if {[info exists audace(posobs,observateur,gps)]==1} {
            set modpoi(var,home) $audace(posobs,observateur,gps)
         } else {
            set modpoi(var,home) "GPS 1 E 43 0"
         }
      }
      set pi $modpoi(pi)
      set deg2rad $modpoi(deg2rad)
      set rad2deg $modpoi(rad2deg)
      #--- aberration annuelle
      set radec [mc_aberrationradec annual [list $rae $dece] $date ]
      #--- correction de precession
      set radec [mc_precessradec $radec $equinox $date]
      #--- correction de nutation
      set radec [mc_nutationradec $radec $date]
      #--- aberration de l'aberration diurne
      set radec [mc_aberrationradec diurnal $radec $date $modpoi(var,home)]
      #--- calcul de l'angle horaire et de la hauteur vraie
      set rav [lindex $radec 0]
      set decv [lindex $radec 1]
      set dummy [mc_radec2altaz ${rav} ${decv} $modpoi(var,home) $date]
      set azv [lindex $dummy 0]
      set hv [lindex $dummy 1]
      set Hv [lindex $dummy 2]
      #--- return
      return [list $rav $decv $Hv $hv $azv]
   }

   #------------------------------------------------------------
   #  addFrame
   #      add a frame with align button
   #------------------------------------------------------------
   proc addFrame { parentFrame } {
      variable This
      variable private
      global audace
      global caption
      global colorpad
      global geompad

      set private(This) $parentFrame.frameAlign
      set This $private(This)

      frame $This -borderwidth 2 -bg $colorpad(backpad) -borderwidth 2 -relief groove

      #--- Frame du pointage
      frame $This.frameGoto -borderwidth 1 -relief groove -bg $colorpad(backpad)

      #--- Frame de selection de l'objet a pointer
      frame $This.frameGoto.frameSelect -borderwidth 1 -relief groove -bg $colorpad(backpad)

      #--- Button targetName
      button  $This.frameGoto.frameSelect.buttargetName -borderwidth 1 -bg $colorpad(backkey) -width 14\
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable ::AlignManager::private(targetName) \
         -command { ::AlignManager::cmdSelectStar }
      pack $This.frameGoto.frameSelect.buttargetName -in $This.frameGoto.frameSelect -anchor center -fill x -side left

      #--- Button carte
      button  $This.frameGoto.frameSelect.butSkyMap -borderwidth 1 -bg $colorpad(backkey) -width 6\
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text $caption(superpad,buttonSkyMap) \
         -command { ::AlignManager::cmdSkyMap }
      pack   $This.frameGoto.frameSelect.butSkyMap -in $This.frameGoto.frameSelect -anchor center -fill x

      pack $This.frameGoto.frameSelect -in $This.frameGoto -fill x

      #--- Frame des coordonnees
      frame $This.frameTargetCoord -borderwidth 1  -relief groove -bg $colorpad(backpad)

      #--- Entry Ascension droite
      entry  $This.frameTargetCoord.targetRa -bg $colorpad(backdisp) -relief groove -width 11 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable ::AlignManager::private(targetRa)
      pack   $This.frameTargetCoord.targetRa -in $This.frameTargetCoord -anchor center -fill x -side left

      #--- Entry Declinaison
      entry  $This.frameTargetCoord.targetDec -bg $colorpad(backdisp) -relief groove -width 11 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable ::AlignManager::private(targetDec)
      pack   $This.frameTargetCoord.targetDec -in $This.frameTargetCoord -anchor center -fill x

      pack $This.frameTargetCoord -in $This.frameGoto -fill x

      #--- Frame Goto
      #--- button StartGOTO
      button  $This.frameGoto.buttonStartGoto -borderwidth 1 -bg $colorpad(backkey) -width 14\
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text $caption(superpad,buttonGoto) \
         -relief ridge \
         -command { ::AlignManager::cmdStartGoto }
      pack   $This.frameGoto.buttonStartGoto -in $This.frameGoto -anchor center -fill x -side left

      #--- button StopGOTO
      button  $This.frameGoto.buttonStopGoto -borderwidth 1 -bg $colorpad(backkey) -width 6 \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text $caption(superpad,buttonStopGoto) \
         -relief ridge \
         -command { ::telescope::stopGoto }
      pack   $This.frameGoto.buttonStopGoto -in $This.frameGoto -anchor center -fill x

      pack $This.frameGoto -in $This  -fill x

      #--- Frame du pointage
      frame $This.fraAlign -borderwidth 1 -relief groove -bg $colorpad(backpad)

      #--- button MOUNTSIDE
      button  $This.fraAlign.butMountSide -borderwidth 1 -bg $colorpad(backkey) \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -textvariable  ::AlignManager::private(mountSide) \
         -relief ridge \
         -command { ::AlignManager::cmdChangeMountSide }
      pack $This.fraAlign.butMountSide -in $This.fraAlign -fill x -side left

      #--- button CENTER
      button  $This.fraAlign.butCenter -borderwidth 1 -bg $colorpad(backkey)  \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text $caption(superpad,buttonCenter) \
         -relief ridge \
         -command { ::AlignManager::cmdCenterStar }
      pack   $This.fraAlign.butCenter -in $This.fraAlign -fill x -side left

      #--- button ALIGN
      button  $This.fraAlign.butAlign -borderwidth 1 -bg $colorpad(backkey) \
         -font [ list {Arial} $geompad(fontsize20) $geompad(textthick) ] \
         -text $caption(superpad,buttonAlign) \
         -relief ridge \
         -command { ::AlignManager::cmdAlign }
      pack   $This.fraAlign.butAlign -in $This.fraAlign -fill x

      pack $This.fraAlign -in $This -fill x

      pack $This -in $parentFrame -fill x

   }

}

###################################################################
#      FocusManager                                               #
###################################################################

namespace eval FrameFocusManager {
   array set private {
      This   ""
      speed  "2"
   }

   #------------------------------------------------------------
   #  cmdFocusSpeed
   #      change speed of focus motor
   #------------------------------------------------------------
   proc cmdFocusSpeed { {value " "} } {
      ::focus::incrementSpeed $::conf(superpad,focuserLabel) pad
   }

   #------------------------------------------------------------
   #  getFrame
   #     returns current frame
   #------------------------------------------------------------
   proc getFrame { } {
      variable private

      return $private(This)
   }

   #------------------------------------------------------------
   #  addFrame
   #      adds a frame with focus buttons
   #------------------------------------------------------------
   proc addFrame { parentFrame zoom } {
      variable private
      global audace
      global caption
      global conf
      global colorpad
      global geompad
      global panneau

      set private(This) "$parentFrame.frameFocusManager"
      set This $private(This)

      #--- create frame to display focus buttons
      frame $This -borderwidth 1 -relief groove -bg $colorpad(backpad)

      #--- create frame of the buttons
      frame $This.we \
         -width $geompad(larg2) -height $geompad(haut2) \
         -borderwidth 0 -relief flat -bg $colorpad(backpad)
      pack $This.we \
         -in $This -side top -fill x

      button  $This.we.buttonMoins -borderwidth 4 \
         -font [ list {Courier} $geompad(fontsize50) $geompad(textthick) ] \
         -text "-" \
         -width 2 \
         -anchor center \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -relief ridge
      pack $This.we.buttonMoins -in $This.we -expand 0 -side left -padx 4 -pady 8

      #--- write the label of speed
      label $This.we.lab \
         -font [ list {Courier} $geompad(fontsize50) $geompad(textthick) ] \
         -textvariable audace(focus,labelspeed) \
         -borderwidth 0 -relief groove -bg $colorpad(backpad) \
         -fg $colorpad(textkey) \
         -width 2
      pack $This.we.lab -in $This.we -side left -expand 1 -fill x -padx 2 -pady 8

      button  $This.we.buttonPlus -borderwidth 4 \
         -font [ list {Courier} $geompad(fontsize50) $geompad(textthick) ] \
         -text "+" \
         -width 2 \
         -bg $colorpad(backkey) \
         -fg $colorpad(textkey) \
         -anchor center \
         -relief ridge
      pack $This.we.buttonPlus -in $This.we  -expand 0 -side left -padx 4 -pady 8

      set zone(moins) $This.we.buttonMoins
      set zone(plus)  $This.we.buttonPlus

      pack $This -in $parentFrame -fill x

      #--- toggles speed
      bind $This.we.lab <ButtonPress-1> { ::FrameFocusManager::cmdFocusSpeed }

      #--- focus move
      bind $zone(moins) <ButtonPress-1> {
         ::focus::move $::conf(superpad,focuserLabel) "-"
         [::FrameFocusManager::getFrame].we.buttonMoins configure -bg $colorpad(backpad)
      }
      bind $zone(moins) <ButtonRelease-1> {
         ::focus::move $::conf(superpad,focuserLabel) "stop"
         [::FrameFocusManager::getFrame].we.buttonMoins configure -bg $colorpad(backkey)
      }

      bind $zone(plus) <ButtonPress-1> {
         ::focus::move $::conf(superpad,focuserLabel) "+"
         [::FrameFocusManager::getFrame].we.buttonPlus configure -bg $colorpad(backpad)
      }
      bind $zone(plus) <ButtonRelease-1> {
         ::focus::move $::conf(superpad,focuserLabel) "stop"
         [::FrameFocusManager::getFrame].we.buttonPlus configure -bg $colorpad(backkey)
      }

   }
}

###################################################################
#      exemple de mini catalogue                                  #
#      a remplacer par un appel a un catalogue confcat            #
###################################################################

namespace eval DlgSelectStar {
   variable This
   variable selectedStar

   #
   # DlgSelectStar::run this args
   #   Cree la fenetre de configuration du type de fenetre
   #   this = chemin de la fenetre
   #
   proc run { { this ".selectStar" } } {
      variable This
      variable result ""
      global caption

      set This $this
      createDialog
      #tkwait visibility $This
      tkwait window $This
      return $result
   }

   #
   # DlgSelectStar::ok
   #   Fonction appellee lors de l'appui sur le bouton 'OK' pour
   #   appliquer la configuration, et fermer la fenetre de
   #   configuration du type de fenetre
   #
   proc select { starname } {
      variable This
      variable result
      global stars

      set coord [split $stars($starname)]
      set result "$coord $starname"

      destroy $This
   }

   proc createDialog { } {
      variable This
      variable startname
      global conf
      global caption
      global stars
      global audace

      set stars(Achernar)       {01h37m47s -57d13m31s 01 }
      set stars(Acrux)          {12h26m39s -63d06m33s 02}
      set stars(AlNa\'ir)       {22h08m21s -46d57m09s 03}
      set stars(Albireo)        {19h30m48s +27d57m54s 04}
      set stars(Aldebaran)      {04h36m00s +16d30m43s 05}
      set stars(Alphard)        {09h27m38s -08d39m46s 06}
      set stars(Alphecca)       {15h34m45s +26d42m52s 07}
      set stars(Alpheratz)      {00h08m28s +29d05m49s 08}
      set stars(Altair)         {19h50m52s +08d52m26s 09}
      set stars(Antares)        {16h29m30s -26d26m07s 10}
      set stars(Arcturus)       {14h15m43s +19d10m44s 11}
      set stars(Betelgeuse)     {05h55m14s +07d24m30s 12}
      set stars(Canopus)        {06h23m57s -52d41m34s 13}
      set stars(Capella)        {05h16m46s +46d59m49s 14}
      set stars(Deneb)          {20h41m30s +45d17m11s 15}
      set stars(Denebola)       {11h49m07s +14d34m02s 16}
      set stars(Diphda)         {00h43m40s -17d58m36s 17}
      set stars(Dubhe)          {11h03m46s +61d44m51s 18}
      set stars(Fomalhaut)      {22h57m45s -29d36m45s 19}
      set stars(Hamal)          {02h07m15s +23d28m04s 20}
      set stars(Markab)         {23h04m51s +15d12m47s 21}
      set stars(Mirfak)         {03h24m25s +49d51m45s 22}
      set stars(Mizar)          {13h23m58s +54d55m25s 23}
      set stars(Nunki)          {18h55m22s -26d17m41s 24}
      set stars(Pollux)         {07h45m22s +28d01m25s 25}
      set stars(Procyon)        {07h40m10s +05d13m46s 26}
      set stars(Rasalhague)     {17h35m01s +12d33m42s 27}
      set stars(Regulus)        {10h08m25s +11d57m46s 28}
      set stars(Rigel)          {05h14m35s -08d11m53s 29}
      set stars(RigelKentaurus) {14h39m42s -60d50m35s 30}
      set stars(Schedar)        {00h40m36s +56d32m29s 31}
      set stars(Sirius)         {06h45m11s -16d42m57s 32}
      set stars(Spica)          {13h25m15s -11d10m02s 33}
      set stars(Suhail)         {09h08m01s -43d26m13s 34}
      set stars(Vega)           {18h37m00s +38d47m18s 35}

      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      #--- cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm geometry $This 310x130+150+100
      wm title $This $caption(superpad,StarWindowTitle)

      #--- cree un frame pour y mettre des boutons
      frame $This.frameButton -borderwidth 1 -relief raised

      #--- cree les boutons des etoiles
      set c 0
      set r 0
      set searchId [array startsearch stars]
      while { [array anymore stars $searchId] == 1 } {
         set value [array nextelement stars $searchId]
        # ::console::affiche_resultat "value = $value $This.frameButton.button$value\n"
         button $This.frameButton.button$value -text $value -borderwidth 2 -command "::DlgSelectStar::select $value"
         grid configure $This.frameButton.button$value -column $c -row $r -sticky we -in $This.frameButton
         incr c
         if { $c == 5 } {
            incr r
            set c 0
         }
      }
      array donesearch stars $searchId
      update
      set size [grid bbox $This.frameButton]
      wm geometry $This "[lindex $size 2]x[lindex $size 3]"

      pack $This.frameButton -side top -fill both -expand 1
   }

}

::superpad::init

