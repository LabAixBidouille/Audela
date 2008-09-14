#
# Fichier : confcolor.tcl
# Description : Selection et mise a jour en direct des couleurs de l'interface Aud'ACE
# Auteurs : Denis MARCHAIS
# Mise a jour $Id: confcolor.tcl,v 1.19 2008-09-14 22:00:02 robertdelmas Exp $
#

namespace eval confColor {
   global audace

   #--- Charge le fichier caption
   source [ file join $audace(rep_caption) confcolor.cap ]

   proc init { } {
      global audace color conf

      #--- Creation des variables si elles n'exitaitent pas
      if { ! [ info exists conf(confcolor,position) ] }                { set conf(confcolor,position)                "+150+75" }
      if { ! [ info exists conf(confcolor,appearance) ] }              { set conf(confcolor,appearance)              "day" }
      if { ! [ info exists conf(confcolor,menu_night_vision) ] }       { set conf(confcolor,menu_night_vision)       "0" }

      #--- Couleurs diurnes
      if { ! [ info exists conf(confcolor,day,entryBackColor) ] }      { set conf(confcolor,day,entryBackColor)      "#FFFFFF" }
      if { ! [ info exists conf(confcolor,day,entryBackColor2) ] }     { set conf(confcolor,day,entryBackColor2)     "#E9E9E9" }
      if { ! [ info exists conf(confcolor,day,entryTextColor) ] }      { set conf(confcolor,day,entryTextColor)      "#808080" }
      if { ! [ info exists conf(confcolor,day,backColor) ] }           { set conf(confcolor,day,backColor)           "#ECE9D8" }
      if { ! [ info exists conf(confcolor,day,backColor2) ] }          { set conf(confcolor,day,backColor2)          "#ECE9D9" }
      if { ! [ info exists conf(confcolor,day,textColor) ] }           { set conf(confcolor,day,textColor)           "#000000" }
      if { ! [ info exists conf(confcolor,day,activeTextColor)] }      { set conf(confcolor,day,activeTextColor)     "#00C0C0" }
      if { ! [ info exists conf(confcolor,day,activeBackColor)] }      { set conf(confcolor,day,activeBackColor)     "#0000A0" }
      if { ! [ info exists conf(confcolor,day,disabledTextColor) ] }   { set conf(confcolor,day,disabledTextColor)   "#999999" }

      if { ! [ info exists conf(confcolor,day,canvas) ] }              { set conf(confcolor,day,canvas)              "#006886" }
      if { ! [ info exists conf(confcolor,day,listBox) ] }             { set conf(confcolor,day,listBox)             "#DDDDFF" }
      if { ! [ info exists conf(confcolor,day,drag_rectangle) ] }      { set conf(confcolor,day,drag_rectangle)      "#0000EF" }

      #--- Couleurs nocturnes
      if { ! [ info exists conf(confcolor,night,entryBackColor)] }     { set conf(confcolor,night,entryBackColor)    "#BB0923" }
      if { ! [ info exists conf(confcolor,night,entryBackColor2) ] }   { set conf(confcolor,night,entryBackColor2)   "#F93956" }
      if { ! [ info exists conf(confcolor,night,entryTextColor) ] }    { set conf(confcolor,night,entryTextColor)    "#400040" }
      if { ! [ info exists conf(confcolor,night,backColor) ] }         { set conf(confcolor,night,backColor)         "#5E061F" }
      if { ! [ info exists conf(confcolor,night,backColor2) ] }        { set conf(confcolor,night,backColor2)        "#8F071F" }
      if { ! [ info exists conf(confcolor,night,textColor) ] }         { set conf(confcolor,night,textColor)         "#FFFFFF" }
      if { ! [ info exists conf(confcolor,night,activeTextColor) ] }   { set conf(confcolor,night,activeTextColor)   "#0000A0" }
      if { ! [ info exists conf(confcolor,night,activeBackColor)] }    { set conf(confcolor,night,activeBackColor)   "#00C0C0" }
      if { ! [ info exists conf(confcolor,night,disabledTextColor) ] } { set conf(confcolor,night,disabledTextColor) "#555555" }

      if { ! [ info exists conf(confcolor,night,canvas) ] }            { set conf(confcolor,night,canvas)            "#004559" }
      if { ! [ info exists conf(confcolor,night,listBox) ] }           { set conf(confcolor,night,listBox)           "#C40627" }
      if { ! [ info exists conf(confcolor,night,drag_rectangle) ] }    { set conf(confcolor,night,drag_rectangle)    "#0000EF" }

      #--- Je copie les couleurs conf() dans audace() en fonction de l'apparence choisie
      set appearance $conf(confcolor,appearance)
      foreach {key value} [array get conf confcolor,$appearance,*] {
         if { "$value" == "" } continue
         set colorType [lindex [split $key ,] 2]
         set audace(color,$colorType) $value
      }

      #--- Couleurs des glissieres independantes de l'apparence
      set audace(color,cursor_rgb_red)    "red"
      set audace(color,cursor_rgb_green)  "green"
      set audace(color,cursor_rgb_blue)   "blue"
      set audace(color,cursor_rgb_actif)  "white"
      set audace(color,cursor_blue)       "#006688"
      set audace(color,cursor_blue_actif) "#64A9BF"

      #--- Autres couleurs independantes de l'apparence
      set color(black)      "black"
      set color(gray_pad)   #808080
      set color(white)      "white"
      set color(blue)       "blue"
      set color(blue_pad)   #123456
      set color(green)      "green"
      set color(green1)     #005500
      set color(lightgreen) #AAFFAA
      set color(red)        "red"
      set color(red_pad)    #ED4E59
      set color(lightred)   #FFAAAA
      set color(infra-red)  #A51005
      set color(orange)     #FF8000
      set color(yellow)     "yellow"
      set color(magenta)    "magenta"
      set color(cyan)       "cyan"
      set color(violet)     "violet"
      set color(purple)     #DD00FF
   }

   #------------------------------------------------------------
   #  ::confColor::switchDayNight
   #  bascule l'apparance jour <=> nuit
   #------------------------------------------------------------
   proc switchDayNight { } {
      global audace conf

      #--- Je change l'apparence
      if { $conf(confcolor,appearance) == "day" } {
         set conf(confcolor,appearance) "night"
         set conf(confcolor,menu_night_vision) "1"
      } else {
         set conf(confcolor,appearance) "day"
         set conf(confcolor,menu_night_vision) "0"
      }

      #--- J'applique le changement
      #--- Je copie les couleurs de l'apparence choisi dans audace (color,*)
      foreach {key value} [array get conf confcolor,$conf(confcolor,appearance),*] {
         set colorType [lindex [split $key ,] 2]
         set audace(color,$colorType) $value
      }

      #--- J'affiche les couleurs
      foreach visuNo [ ::visu::list ] {
         set base [ ::confVisu::getBase $visuNo ]
         ::confColor::applyColor $base
      }
      ::confColor::applyColor $audace(Console)
   }

   #------------------------------------------------------------
   #  ::confColor::run
   #  ouverture de la fenetre de configuration
   #------------------------------------------------------------
   proc run { visuNo } {
      global audace

      ::confGenerique::run $visuNo $audace(base).select_color "::confColor" -modal 0
   }

   #------------------------------------------------------------
   #  ::confColor::getLabel
   #  retourne le nom de la fenetre de configuration
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(confcolor,title)"
   }

   #------------------------------------------------------------
   #  ::confColor::showHelp
   #  affiche l'aide de la fenetre de configuration
   #------------------------------------------------------------
   proc showHelp { } {
      global help

      ::audace::showHelpItem "$help(dir,config)" "1110apparence.htm"
   }

   #------------------------------------------------------------
   #  ::confColor::confToWidget { }
   #     copie les parametres du tableau conf() dans les variables des widgets
   #------------------------------------------------------------
   proc confToWidget { visuNo } {
      variable widget
      global conf

      set widget(position) "$conf(confcolor,position)"

      #--- Je copie les couleurs  de conf() dans widget() en fonction de l'apparence choisie
      set widget(appearance) $conf(confcolor,appearance)
      foreach {key value} [array get conf confcolor,*,*] {
         set appearance [lindex [split $key ,] 1]
         set colorType [lindex [split $key ,] 2]
         set widget(color,$appearance,$colorType) $value
      }
   }

   #------------------------------------------------------------
   #  ::confColor::apply { }
   #  copie les variable des widgets dans le tableau conf()
   #------------------------------------------------------------
   proc apply { visuNo } {
      variable widget
      global audace conf

      #--- Je sauvegarde les couleurs  de widget() dans conf()
      set appearance $conf(confcolor,appearance)
      foreach {key value} [array get widget color,*,*] {
         set appearance [lindex [split $key ,] 1]
         set colorType  [lindex [split $key ,] 2]
         set conf(confcolor,$appearance,$colorType) $value
      }

      #--- Je mets en coherence les 2 variables
      set conf(confcolor,appearance) $widget(appearance)
      if { $conf(confcolor,appearance) == "day" } {
         set conf(confcolor,menu_night_vision) "0"
      } else {
         set conf(confcolor,menu_night_vision) "1"
      }

      #--- Je copie les couleurs  de l'apparence en cours dans audace()
      foreach {key value} [array get conf confcolor,$conf(confcolor,appearance),*] {
         set colorType [lindex [split $key ,] 2]
         set audace(color,$colorType) $value
      }

      #--- Je mets la position actuelle de la fenetre dans conf()
      set geom [ winfo geometry [winfo toplevel $widget(frm) ] ]
      set deb [ expr 1 + [ string first + $geom ] ]
      set fin [ string length $geom ]
      set conf(confcolor,position) "+[ string range $geom $deb $fin ]"

      #--- J'affiche les couleurs
      foreach visuNo [ ::visu::list ] {
         set base [ ::confVisu::getBase $visuNo ]
         ::confColor::applyColor $base
      }
      ::confColor::applyColor $audace(Console)
   }

   #------------------------------------------------------------
   #  ::confColor::fillConfigPage { }
   #  fenetre de configuration
   #
   #------------------------------------------------------------
   proc fillConfigPage { frm visuNo } {
      variable widget
      global caption conf

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- Je position la fenetre
      wm geometry [ winfo toplevel $widget(frm) ] $conf(confcolor,position)

      #--- J'initialise les variables des widgets
      confToWidget $visuNo

      #--- Je place les radiobuttons de selection de l'apparence
      frame $frm.select -borderwidth 1 -relief groove
      label $frm.select.title_label  -text "$caption(confcolor,vision)"
      #--- Radiobutton day
      radiobutton $frm.select.rb_day -text "$caption(confcolor,diurne)" \
         -variable ::confColor::widget(appearance) -value "day" \
         -command  { ::confColor::chooseAppearance }
      #--- Radiobutton night
      radiobutton $frm.select.rb_night -text "$caption(confcolor,nocturne)" \
         -variable ::confColor::widget(appearance) -value "night" \
         -command  { ::confColor::chooseAppearance }
      #--- Button restore
      button $frm.select.restore -text "$caption(confcolor,button_restore)" -borderwidth 2 \
         -command { ::confColor::restoreFactoryColor }

      grid $frm.select.title_label $frm.select.rb_day $frm.select.rb_night $frm.select.restore -ipadx 5 -ipady 5
      pack $frm.select -fill x -expand 1 -anchor n -side top

      #--- J'ajoute les button par type de couleur dans une grille a deux colonnes
      frame $frm.but -borderwidth 1 -relief groove
      foreach {key } [lsort [array names widget -glob color,day,*] ] {
         set i [lindex [split $key ,] 2]
         label $frm.but.l$i -text "$i"
         button $frm.but.b_color_invariant$i -command "::confColor::chooseColor $i $frm.but.b_color_invariant$i" \
            -width 20 -bg $widget(color,$widget(appearance),$i) -activebackground $widget(color,$widget(appearance),$i)
         grid $frm.but.l$i $frm.but.b_color_invariant$i -sticky w
      }
      pack $frm.but -fill both -expand 1 -anchor n -side top
   }

   #------------------------------------------------------------
   #  ::confColor::closeWindow
   #  est appele quand on ferme la fenetre sans sauvegarder les modifications
   #
   #  param : aucun
   #------------------------------------------------------------
   proc closeWindow { visuNo } {
      variable widget
      global audace conf

      #--- Je restore les couleurs precedentes
      if { $widget(appearance) != $conf(confcolor,appearance) } {
         #--- Je copie les couleurs initiales dans audace (color,*)
         foreach {key value} [array get conf confcolor,$conf(confcolor,appearance),*] {
            set colorType [lindex [split $key ,] 2]
            set audace(color,$colorType) $value
         }
         #--- J'applique les couleurs precedentes
         foreach visuNo [ ::visu::list ] {
            set base [ ::confVisu::getBase $visuNo ]
            ::confColor::applyColor $base
         }
         ::confColor::applyColor $audace(Console)
      }
   }

   #------------------------------------------------------------
   #  ::confColor::chooseAppearance
   #  est appele quand on change d'apparence jour/nuit
   #
   #  param : type de couleur  ( background, foreground, ...)
   #------------------------------------------------------------
   proc chooseAppearance { } {
      variable widget
      global audace

      #--- Je recupere l'apparence qui vient d'etre choisie
      set appearance $widget(appearance)

      #--- Je copie les couleurs  de l'apparence choisi dans audace (color,*)
      foreach {key value} [array get widget color,$appearance,*] {
         set colorType [lindex [split $key ,] 2]
         set audace(color,$colorType) $value
      }

      #--- J'affiche les couleurs avec l'apparence qui vient d'etre choisie
      foreach visuNo [ ::visu::list ] {
         set base [ ::confVisu::getBase $visuNo ]
         ::confColor::applyColor $base
      }
      ::confColor::applyColor $audace(Console)

      #--- Je met a jour la couleur des boutons de la fenetre de configuration
      foreach {key value} [array get widget color,$appearance,*] {
         set i [lindex [split $key ,] 2]
         $widget(frm).but.b_color_invariant$i configure -fg $widget(color,$widget(appearance),$i) \
            -bg $widget(color,$widget(appearance),$i)
      }
   }

   #------------------------------------------------------------
   #  ::confColor::chooseColor
   #  est appelle quand on clique sur un bouton d'une couleur
   #
   #  param : type de couleur ( background, foreground, ...)
   #------------------------------------------------------------
   proc chooseColor { colorType buttonName } {
      variable widget
      global audace caption

      #--- Je recupere l'apparence qui vient d'etre choisie
      set appearance $widget(appearance)

      #--- Montre que le bouton est enfonce
      $buttonName configure -relief groove

      set a [ tk_chooseColor -initialcolor $widget(color,$appearance,$colorType) \
         -title "$caption(confcolor,selection) $colorType" \
         -parent "$audace(base).select_color" ]
      if { [ llength $a ] > "0" } {
         set widget(color,$appearance,$colorType) $a
         set audace(color,$colorType) $a
         $buttonName configure -fg $widget(color,$appearance,$colorType) -bg $widget(color,$appearance,$colorType)
      }

      #--- Montre que le bouton est relache
      $buttonName configure -relief raised

      #--- J'affiche les couleurs avec l'apparence qui vient d'etre choisie
      foreach visuNo [ ::visu::list ] {
         set base [ ::confVisu::getBase $visuNo ]
         ::confColor::applyColor $base
      }
      ::confColor::applyColor $audace(Console)
   }

   #------------------------------------------------------------
   #  ::confColor::applyColor
   #     est appele apres avoir choisi une nouvelle couleur
   #     et applique la couleur en fonction de la charte des couleurs de Audace (voir doc de programmation)
   #
   #  w : window parent des resources qui doivent changer de couleur
   #------------------------------------------------------------
   proc applyColor { w } {
      global audace color

      switch -exact -- [ winfo class $w ] {
         Canvas {
            if { "[ winfo class [ winfo parent $w ] ]" == "Tree"
              || "[ winfo class [ winfo parent $w ] ]" == "NoteBook" } {
               $w configure -bg $audace(color,backColor)
            } elseif { "[ winfo class [ winfo parent $w ] ]" != "ArrowButton" } {
               if { [ string first color_invariant $w ] == -1 } {
                  $w configure -bg $audace(color,canvas)
               } else {
                  ::bermasaude::representationRoueAFiltres
               }
            }
         }
         Toplevel {
            $w configure -bg $audace(color,backColor)
         }
         Frame {
            if { [ string first color_invariant $w ] == -1 } {
               $w configure -bg $audace(color,backColor)
            }
         }
         Label {
            if { [ string first labURL $w ] == -1 } {
               if { [ string first color_invariant $w ] == -1 } {
                  $w configure -bg $audace(color,backColor) -fg $audace(color,textColor)
               }
            } else {
               $w configure -bg $audace(color,backColor)
               if { [ string first labURLRed $w ] == -1 } {
               } else {
                  if { [ $w cget -fg ] != $color(red) } {
                     $w configure -bg $audace(color,backColor) -fg $audace(color,textColor)
                  } else {
                     $w configure -bg $audace(color,backColor)
                  }
               }
            }
         }
         LabelFrame {
            $w configure -bg $audace(color,backColor) -fg $audace(color,textColor)
         }
         Entry {
            $w configure -bg $audace(color,entryBackColor) -fg $audace(color,entryTextColor) \
               -disabledbackground $audace(color,entryBackColor2) \
               -disabledforeground $audace(color,disabledTextColor) \
               -selectbackground $audace(color,activeBackColor)  \
               -selectforeground $audace(color,activeTextColor)

               ##-selectbackground "SystemHighlight"
               ##-selectforeground SystemHighlightText
         }
         LabelEntry {
            $w configure -bg $audace(color,entryBackColor) -fg $audace(color,entryTextColor) \
               -disabledbackground $audace(color,entryBackColor2) \
               -disabledforeground $audace(color,disabledTextColor)
         }
         Button {
            if { [ string first color_invariant $w ] == -1 } {
               $w configure -bg $audace(color,backColor) -activebackground $audace(color,backColor) \
                  -fg $audace(color,textColor) -activeforeground $audace(color,activeTextColor)
            }
         }
         Checkbutton {
            $w configure -bg $audace(color,backColor) -activebackground $audace(color,backColor) \
               -fg $audace(color,textColor) -activeforeground $audace(color,textColor) \
               -disabledforeground $audace(color,disabledTextColor) \
               -selectcolor $audace(color,backColor) -highlightbackground $audace(color,backColor)
         }
         Radiobutton {
            $w configure -fg $audace(color,textColor) -bg $audace(color,backColor) \
               -activeforeground $audace(color,textColor) -disabledforeground $audace(color,disabledTextColor) \
               -selectcolor $audace(color,backColor) -highlightbackground $audace(color,backColor)
         }
         ArrowButton {
            $w configure -bg $audace(color,backColor2) -fg $audace(color,textColor)
         }
         Menubutton {
            $w configure -bg $audace(color,backColor) -activebackground $audace(color,textColor) \
               -fg $audace(color,textColor) -activeforeground $audace(color,backColor) \
               -highlightbackground $audace(color,backColor)
         }
         Menu {
            $w configure -bg $audace(color,backColor2) -activebackground $audace(color,textColor) \
               -fg $audace(color,textColor) -activeforeground $audace(color,backColor)
         }
         Scale {
            if { [ string first variant $w ] == -1 } {
               $w configure -fg $audace(color,textColor) -troughcolor $audace(color,backColor2) \
                  -highlightbackground $audace(color,backColor)
            } else {
               $w configure -fg $audace(color,textColor) -troughcolor $audace(color,backColor2) \
                  -highlightbackground $audace(color,backColor) -background $audace(color,entryBackColor2) \
                  -activebackground $audace(color,entryBackColor)
            }
         }
         Listbox {
            $w configure -bg $audace(color,listBox) -fg $audace(color,textColor)
         }
         ListBox {
            #--- listbox de Bwidget
            $w configure -bg $audace(color,listBox) -fg $audace(color,textColor)
         }
         Scrollbar {
            $w configure -activebackground $audace(color,backColor) \
               -background $audace(color,backColor) \
               -highlightbackground $audace(color,backColor) \
               -highlightcolor $audace(color,backColor) \
               -troughcolor $audace(color,backColor)
         }
         Tablelist {
            #--- Couleur des lignes selectionnes de cette listbox
            $w configure -selectbackground $audace(color,activeBackColor) -selectforeground $audace(color,activeTextColor)
            #--- Couleur des lignes paires de cette listbox
            $w configure -stripebackground $audace(color,backColor) -stripeforeground $audace(color,textColor)
         }
         Text {
            $w configure -bg $audace(color,listBox) -fg $audace(color,textColor)
         }
         Message {
            $w configure -bg $audace(color,backColor) -fg $audace(color,textColor)
         }
         Graph {
            $w configure -bg $audace(color,backColor) -fg $audace(color,textColor) \
               -plotbackground $audace(color,entryTextColor)
            $w axis configure x  -hide no -color $audace(color,textColor) -titlecolor $audace(color,textColor)
            $w axis configure x2 -hide no -color $audace(color,textColor) -titlecolor $audace(color,textColor)
            $w axis configure y  -hide no -color $audace(color,textColor) -titlecolor $audace(color,textColor)
            $w axis configure y2 -hide no -color $audace(color,textColor) -titlecolor $audace(color,textColor)
         }
         ComboBox {
            #--- Couleur de la valeur selectionnee dans l'entry de la combobox
            $w configure -selectbackground $audace(color,entryBackColor) -selectforeground $audace(color,entryTextColor)
         }
         default {
            #--- Trace pour faire apparaitre les widget non traites
           ### console::disp "Defaut ==> w=$w class=[ winfo class $w ]\n"
         }
      }
      foreach i [ winfo children $w ] {
         ::confColor::applyColor $i
      }
   }

   #------------------------------------------------------------
   #  ::confColor::restoreFactoryColor
   #  restaure les couleur usine
   #------------------------------------------------------------
   proc restoreFactoryColor { } {
      variable widget
      global audace caption conf

      set choice [tk_messageBox \
         -message "$caption(confcolor,confirmation)" \
         -title "$caption(confcolor,couleur_defaut)" \
         -icon question \
         -type yesno ]

      if {"$choice"=="no"} {
         return
      }

      #--- Je recupere l'apparence en cours
      if { $::confColor::widget(appearance) == "day" } {
         set conf(confcolor,appearance) "day"
         set conf(confcolor,menu_night_vision) "0"
      } else {
         set conf(confcolor,appearance) "night"
         set conf(confcolor,menu_night_vision) "1"
      }

      #--- Je recupere l'apparence qui vient d'etre choisie
      set appearance $conf(confcolor,appearance)

      #--- Je supprime les variable conf(confcolor,$appearance,*)
      foreach {key value} [array get conf confcolor,$appearance,*] {
         unset conf($key)
      }

      #--- Je recree les variables supprimees avec les valeurs par defaut
      confColor::init

      #--- Je mets a jour les couleurs de la fenetre audace
      foreach visuNo [ ::visu::list ] {
         set base [ ::confVisu::getBase $visuNo ]
         ::confColor::applyColor $base
      }
      ::confColor::applyColor $audace(Console)

      #--- Je mets a jour les couleurs de la fenetre de configuration
      foreach {key value} [array get widget color,$appearance,*] {
         set i [lindex [split $key ,] 2]
         set widget(color,$appearance,$i) $conf(confcolor,$appearance,$i)
         $widget(frm).but.b_color_invariant$i configure -fg $widget(color,$appearance,$i) \
            -bg $widget(color,$appearance,$i)
      }
   }
}

#--- Initialisation des couleurs
::confColor::init

