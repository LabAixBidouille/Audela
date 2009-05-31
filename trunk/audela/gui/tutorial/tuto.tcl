#
# Mise a jour $Id: tuto.tcl,v 1.10 2009-05-31 08:25:41 robertdelmas Exp $
#

#!/bin/sh
# the next line restarts using wish \
#exec wish "$0" "$@"

proc int {value} {
   set a [expr ceil($value)]
   set point [expr [string first . $a]-1]
   set value [string range $a 0 $point]
}

proc caption_def { langage } {
   global texte caption
   #--- definition of captions
   if {[string compare $langage english] ==0 } {
      set caption(main_title) "Tuto : A Tutorial for CCD Beginners"
      set caption(tuto_about) "About..."
      set caption(tuto_quit)  "Quit"
      set caption(tuto_tools) "Tools"
      set texte(tuto_1)    "CCD Imagery for Beginners"
      set texte(tuto_2)    "This tutorial helps you shoot your first images with your CCD camera.  It was created with the AudeLA software."
      set texte(tuto_3)    "Plug and Test the Audine Camera"
      set texte(tuto_4)    "Connect the Camera."
      set texte(tuto_5)    "Electronic Tests for Audine."
      set texte(tuto_6)    "First Dark Frame with Camera Uncooled."
      set texte(tuto_7)    "First Image with Camera Uncooled."
      set texte(tuto_8)    "Cooling the Camera."
      set texte(tuto_9)    "Make Dark and Bias Reference Frames."
      set texte(tuto_10_0) "Fit the CCD Camera to a Telescope"
      set texte(tuto_10)   "Adapter Ring to fit the Audine Camera to an Eyepiece Holder."
      set texte(tuto_11)   "Mechanical Installation on an Eyepiece Holder."
      set texte(tuto_12)   "Aligning the Telescope."
      set texte(tuto_13)   "Aiming at Celestial Objects."
      set texte(tuto_14_0) "First Images of the Sky"
      set texte(tuto_14)   "Focusing on a Bright Star."
      set texte(tuto_15)   "Focusing on a Globular Cluster."
      set texte(tuto_16)   "Acquisition of Images through Practice."
      set texte(tuto_about0) "Audine Tutorial"
      set texte(tuto_about1) "Tutorial for the Audine Camera\n\n\Aude (c) 1999\n\nIn order to change the language, you must edit the file langage.tcl and write another language.\n"
   }
   if {[string compare $langage french] ==0 } {
      set caption(main_title) "Tuto : Un tutorial pour les débutants en CCD"
      set caption(tuto_about) "A propos..."
      set caption(tuto_quit)  "Quitter"
      set caption(tuto_tools) "Outils"
      set texte(tuto_1)    "Initiation à l'imagerie CCD"
      set texte(tuto_2)    "Ce tutorial vous permettra de réaliser vos premières images avec une caméra CCD. Il a été réalisé avec le logiciel AudeLA."
      set texte(tuto_3)    "Brancher et tester la caméra Audine"
      set texte(tuto_4)    "Connexion des câbles de la caméra."
      set texte(tuto_5)    "Tests électroniques pour le kit Audine."
      set texte(tuto_6)    "Première image dans le noir, caméra non-refroidie."
      set texte(tuto_7)    "Première lumière, caméra non-refroidie."
      set texte(tuto_8)    "Refroidissement de la caméra."
      set texte(tuto_9)    "Réaliser des images dark et bias de référence."
      set texte(tuto_10_0) "Installer la caméra CCD sur un télescope"
      set texte(tuto_10)   "Bague pour adapter Audine sur un porte-oculaire."
      set texte(tuto_11)   "Adaptation mécanique sur le porte-oculaire."
      set texte(tuto_12)   "Mise en station du télescope."
      set texte(tuto_13)   "Pointage des objets célestes."
      set texte(tuto_14_0) "Premières images sur le ciel"
      set texte(tuto_14)   "Focalisation sur une étoile brillante."
      set texte(tuto_15)   "Focalisation sur un amas globulaire."
      set texte(tuto_16)   "L'acquisition par la pratique."
      set texte(tuto_about0) "Tutorial Audine"
      set texte(tuto_about1) "Tutorial pour la camera Audine\n\n\Aude (c) 1999\n\nIn order to change the language, you must edit the file langage.tcl and write another language.\n"
   }
}

# widget --
# This script demonstrates the various widgets provided by Tk,
# along with many of the features of the Tk toolkit.  This file
# only contains code to generate the main window for the
# application, which invokes individual demonstrations.  The
# code for the actual demonstrations is contained in separate
# ".tcl" files is this directory, which are sourced by this script
# as needed.
#
# SCCS: @(#) widget 1.35 97/07/19 15:42:22

global texte caption

#--- si la fenetre secondaire existe deja, je la detruis
if { [winfo exists .second] } {
   destroy .second
}

#--- si la fenetre principale existe deja, je la deiconifie et je sors du script
if { [winfo exists .main] } {
   wm deiconify .main
   focus .main
   return
}

#--- selection of language
if {[info exists langage] == "0"} {
   set langage english
}
if {[string compare $langage english] ==0 } {
} elseif {[string compare $langage french] ==0 } {
} else {
   set langage english
}
caption_def $langage

# ========================================
# === Setting the astronomical devices ===
# ========================================
#--- definition of global variables
global lpt       # name of the audine port
set lpt "lpt1"

#--- declare a new buffer in memory to place images
set num(buf1) [buf::create]

#--- je charge le package Thread  si Audela est compile avec l'otion multithread
if { [info exists ::tcl_platform(threaded)] } {
   if { $::tcl_platform(threaded)==1 } {
      #--- Je charge le package Thread
      #--- La version minimale 2.6.5.1 pour disposer de la commande thread::copycommand
      package require Thread 2.6.5.1
   }
}

#--- declare a new camera
set num(cam1) [cam::create audine $lpt]

#--- declare a new visu space to display the buffer
set num(visu1) [visu::create $num(buf1) 100 ]

#--- declare a new image
set num(image1) $num(visu1)

wm withdraw .
if {[info command .main] == "" } {
   toplevel .main -class Toplevel
}
wm title .main $texte(tuto_1)
set screenwidth [int [expr [winfo screenwidth .main]*.85]]
set screenheight [int [expr [winfo screenheight .main]*.85]]
wm geometry .main ${screenwidth}x${screenheight}+0+0
wm maxsize .main [winfo screenwidth .main] [winfo screenheight .main]
wm minsize .main ${screenwidth} ${screenheight}
wm resizable .main 1 1
wm protocol .main WM_DELETE_WINDOW tuto_exit
set widgetDemo 1

#----------------------------------------------------------------
# The code below create the main window, consisting of a menu bar
# and a text widget that explains how to use the program, plus lists
# all of the demos as hypertext items.
#----------------------------------------------------------------

set font {Helvetica 12 bold}
if {[info command .main.menuBar] == "" } {
   menu .main.menuBar -tearoff 0
   .main.menuBar add cascade -menu .main.menuBar.file -label $caption(tuto_tools) -underline 0
   menu .main.menuBar.file -tearoff 0
   # On the Mac use the specia .apple menu for the about item
   if {$::tcl_platform(platform) == "macintosh"} {
      .main.menuBar add cascade -menu .menuBar.apple
      menu .main.menuBar.apple -tearoff 0
      .main.menuBar.apple add command -label $caption(tuto_about) -command "aboutBox"
   } else {
      .main.menuBar.file add command -label $caption(tuto_about) -command "aboutBox" \
         -underline 0 -accelerator "<F1>"
      .main.menuBar.file add sep
   }
   .main.menuBar.file add command -label $caption(tuto_quit) -command "tuto_exit" -underline 0 \
       -accelerator "Meta-Q"
   .main configure -menu .main.menuBar
   bind .main <F1> aboutBox
}

if {[info command .main.statusBar] == "" } {
   frame .main.statusBar
   label .main.statusBar.lab -text "   " -relief sunken -bd 1 \
       -font -*-Helvetica-Medium-R-Normal--*-120-*-*-*-*-*-* -anchor w
   label .main.statusBar.foo -width 8 -relief sunken -bd 1 \
       -font -*-Helvetica-Medium-R-Normal--*-120-*-*-*-*-*-* -anchor w
}
pack .main.statusBar.lab -side left -padx 2 -expand yes -fill both
pack .main.statusBar.foo -side left -padx 2
pack .main.statusBar -side bottom -fill x -pady 2

if {[info command .main.textFrame] == "" } {
   frame .main.textFrame
   scrollbar .main.s -orient vertical -command {.main.t yview} -highlightthickness 0 \
       -takefocus 1
   text .main.t -yscrollcommand {.main.s set} -wrap word -font $font
   #\
   #    -setgrid 1 -highlightthickness 0 -padx 4 -pady 2 -takefocus 0
}
pack .main.s -in .main.textFrame -side right -fill y
pack .main.t -in .main.textFrame -expand yes -fill both -padx 1
pack .main.textFrame -expand yes -fill both

# Create a bunch of tags to use in the text widget, such as those for
# section titles and demo descriptions.  Also define the bindings for
# tags.

.main.t tag configure title -font {Helvetica 14 bold}

# We put some "space" characters to the left and right of each demo description
# so that the descriptions are highlighted only when the mouse cursor
# is right over them (but not when the cursor is to their left or right)
#
.main.t tag configure demospace -lmargin1 1c -lmargin2 1c

if {[winfo depth .main] == 1} {
   .main.t tag configure demo -lmargin1 1c -lmargin2 1c \
      -underline 1
   .main.t tag configure visited -lmargin1 1c -lmargin2 1c \
      -underline 1
   .main.t tag configure hot -background black -foreground white
} else {
   .main.t tag configure demo -lmargin1 1c -lmargin2 1c \
      -foreground blue -underline 1
   .main.t tag configure visited -lmargin1 1c -lmargin2 1c \
      -foreground #303080 -underline 1
   .main.t tag configure hot -foreground red -underline 1
}
.main.t tag bind demo <ButtonRelease-1> {
   invoke [.main.t index {@%x,%y}] .main
}
set lastLine ""
.main.t tag bind demo <Enter> {
   set lastLine [.main.t index {@%x,%y linestart}]
   .main.t tag add hot "$lastLine +1 chars" "$lastLine lineend -1 chars"
   .main.t config -cursor hand2
   #showStatus [.main.t index {@%x,%y}]
}
.main.t tag bind demo <Leave> {
   .main.t tag remove hot 1.0 end
   .main.t config -cursor xterm
   .main.statusBar.lab config -text ""
}
.main.t tag bind demo <Motion> {
   set newLine [.main.t index {@%x,%y linestart}]
   if {[string compare $newLine $lastLine] != 0} {
      .main.t tag remove hot 1.0 end
      set lastLine $newLine

      set tags [.main.t tag names {@%x,%y}]
      set i [lsearch -glob $tags demo-*]
      if {$i >= 0} {
         .main.t tag add hot "$lastLine +1 chars" "$lastLine lineend -1 chars"
      }
   }
   #showStatus [.main.t index {@%x,%y}]
}

# Create the text for the text widget.

.main.t insert end "$texte(tuto_1)\n\n" title
.main.t insert end "$texte(tuto_2)\n\n"

.main.t insert end "$texte(tuto_3)" title
.main.t insert end " \n " {demospace}
.main.t insert end "1. $texte(tuto_4)" {demo demo-plugcam}
.main.t insert end " \n " {demospace}
.main.t insert end "2. $texte(tuto_5)" {demo demo-testcam}
.main.t insert end " \n " {demospace}
.main.t insert end "3. $texte(tuto_6)" {demo demo-firstdark}
.main.t insert end " \n " {demospace}
.main.t insert end "4. $texte(tuto_7)" {demo demo-firstlight}
.main.t insert end " \n " {demospace}
.main.t insert end "5. $texte(tuto_8)" {demo demo-cool}
.main.t insert end " \n " {demospace}
.main.t insert end "6. $texte(tuto_9)" {demo demo-biasdark}
.main.t insert end " \n " {demospace}

.main.t insert end \n {} "$texte(tuto_10_0)" title
.main.t insert end " \n " {demospace}
.main.t insert end "1. $texte(tuto_10)" {demo demo-bague}
.main.t insert end " \n " {demospace}
.main.t insert end "2. $texte(tuto_11)" {demo demo-portoc}
.main.t insert end " \n " {demospace}
.main.t insert end "3. $texte(tuto_12)" {demo demo-station}
.main.t insert end " \n " {demospace}
.main.t insert end "4. $texte(tuto_13)" {demo demo-pointage}
.main.t insert end " \n " {demospace}

.main.t insert end \n {} "$texte(tuto_14_0)" title
.main.t insert end " \n " {demospace}
.main.t insert end "1. $texte(tuto_14)" {demo demo-etoile}
.main.t insert end " \n " {demospace}
.main.t insert end "2. $texte(tuto_15)" {demo demo-amasglo}
.main.t insert end " \n " {demospace}
.main.t insert end "3. $texte(tuto_16)" {demo demo-audace}
.main.t insert end " \n " {demospace}

.main.t insert end " \n " {demospace}

.main.t configure -state disabled
focus .main.s

# invoke --
# This procedure is called when the user clicks on a demo description.
# It is responsible for invoking the demonstration.
#
# Arguments:
# index - The index of the character that the user clicked on.

proc invoke {index base} {
   global tk_library
   set tags [$base.t tag names $index]
   set i [lsearch -glob $tags demo-*]
   if {$i < 0} {
      return
   }
   set cursor [$base.t cget -cursor]
   $base.t configure -cursor watch
   update
   set demo [string range [lindex $tags $i] 5 end]

   #uplevel [list source [file join $tk_library demos $demo.tcl]]
   #--- nettoie la zone
   #.main.t insert end \n {} "tutu\n" title
   #destroy .main
   #foreach w [winfo children .main] {
   #   .main.t insert end \n {} "$w\n" title
   #   pack forget $w
   #   destroy $w
   #}
   #.main.t configure -state disabled
   if {$base == ".second" } {
      wm deiconify .main
      destroy .second
   }
   if {[string compare $demo "exit"] == 0 } {
      #uplevel [list source tuto.tcl]
      focus -force .main
   } else {
      uplevel [list source tuto.$demo.tcl]
      focus -force .second
   }
   update
   if {$base == ".main" } {
      $base.t configure -cursor $cursor
      $base.t tag add visited "$index linestart +1 chars" "$index lineend -1 chars"
   }
}

# showStatus --
#
# Show the name of the demo program in the status bar. This procedure
# is called when the user moves the cursor over a demo description.
#
proc showStatus index {
   global tk_library
   set tags [.main.t tag names $index]
   set i [lsearch -glob $tags demo-*]
   set cursor [.main.t cget -cursor]
   if {$i < 0} {
      .main.statusBar.lab config -text " "
      set newcursor xterm
   } else {
      set demo [string range [lindex $tags $i] 5 end]
      .main.statusBar.lab config -text "Run the \"$demo\" sample program"
      set newcursor hand2
   }
   if [string compare $cursor $newcursor] {
      .main.t config -cursor $newcursor
   }
}

# aboutBox --
#
# Pops up a message box with an "about" message
#
proc aboutBox {} {
   global texte
   tk_messageBox -icon info -type ok -title $texte(tuto_about0) -message $texte(tuto_about1)
}

proc tuto_exit { } {
   global audace num
   ::buf::delete $num(buf1)
   ::visu::delete $num(visu1)
   if { [ info exists num(cam1) ] == "1" } {
      ::cam::delete $num(cam1)
      unset num(cam1)
   }
   catch {
      image delete image11
      image delete image100
      unset texte
   }
   if { [ info exists audace ] == "1" } {
      if { [ winfo exists .main ] } {
         if { [ winfo exists .second ] } {
            destroy .second
         }
         destroy .main
      }
      cd [ file join $audace(rep_audela) ]
   } else {
      destroy .
      exit
   }
}

