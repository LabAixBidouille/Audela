#
# Mise à jour $Id: tuto.plugcam.tcl,v 1.9 2010-05-27 06:33:05 robertdelmas Exp $
#

#!/bin/sh
# the next line restarts using wish \
#exec wish "$0" "$@"

proc caption_def_plugcam { langage } {
   global texte caption
   #--- definition of captions
   if {[string compare $langage english] ==0 } {
      set caption(main_title) "Snapshot:  First Steps in the CCD World"
      set caption(description) "Push the red button to shoot an image of"
      set caption(go) "START"
      set caption(wait) "Wait..."
      set caption(compute) "Compute..."
      set caption(exit) "Exit"
      set caption(thermlevel) "Thermal Level ="
      set caption(max_zero) "Connection Problem"
      set caption(satured) "Some pixels are saturated"
      set caption(maxdark) "Maximum Value ="

      set texte(firstdark_1) "CCD Imagery for Beginners"
      set texte(firstdark_2) "Connect the Camera"
      set texte(firstdark_3) "Your Audine camera has 2 cables.  Plug the multicolored one between the computer and the CCD camera.\
Plug the other between the supply box and the camera.\
Don't forget to switch on the supply box.\
Push the +15 -15 V button on the supply box. Two leds should be\
now on (one yellow, one red).\
You are ready...\n"
      set texte(firstdark_exit) " Return to the main page."
   }
   if {[string compare $langage french] ==0 } {
      set caption(main_title) "Snapshot : Premiers pas dans le monde du CCD"
      set caption(description) "Appuyer sur le bouton rouge pour faire une image de"
      set caption(go) "DEMARRER"
      set caption(wait) "En cours..."
      set caption(compute) "Analyse..."
      set caption(exit) "Quitter"
      set caption(thermlevel) "Niveau thermique ="
      set caption(max_zero) "Problème de connexion"
      set caption(satured) "Des pixels sont saturés"
      set caption(maxdark) "Valeur maximum ="

      set texte(firstdark_1) "Initiation à l'imagerie CCD"
      set texte(firstdark_2) "Connexion des câbles de la caméra"
      set texte(firstdark_3) "Sur cette photo, la caméra Audine est posée sur son boîtier d'alimentation (vue face arrière).\
L'ordinateur (en-dessous) est connecté à la caméra via le câble en nappe multicolore sur le port imprimante (sortie parallèle LPT).\
La caméra est reliée à son boîtier d'alimentation via un câble rond (prises jaune et rouge).\
Enfin, le boîtier d'alimentation est branché sur le secteur (220V 50Hz).\n"
      set texte(firstdark_exit) " Retour à la page principale."
   }
}

proc tuto_plugcam_exit { } {
   wm deiconify .main
   destroy .second
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

#--- definition of global variables (associative arrays)
global num       # index for devices
global caption   # texts of captions
global zone      # window name of usefull screen parts

#--- selection of langage
caption_def_plugcam $langage

#--- definition of colors
set color(back)       #101040
set color(go)         #FF0000
set color(text)       #FFFF00
set color(back_image) #000000

#----------------------------------------------------------------
# The code below create the main window, consisting of a menu bar
# and a text widget that explains how to use the program, plus lists
# all of the demos as hypertext items.
#----------------------------------------------------------------

#--- si la fenetre secondaire existe deja, je la deiconifie et je sors du script
if { [winfo exists .second] } {
   wm deiconify .second
   focus .second
   return
}

toplevel .second -class Toplevel
wm title .second $texte(tuto_1)
set screenwidth [int [expr [winfo screenwidth .second]*.85]]
set screenheight [int [expr [winfo screenheight .second]*.85]]
wm geometry .second ${screenwidth}x${screenheight}+0+0
wm maxsize .second [winfo screenwidth .second] [winfo screenheight .second]
wm minsize .second ${screenwidth} ${screenheight}
wm resizable .second 1 1
wm protocol .second WM_DELETE_WINDOW tuto_plugcam_exit
set widgetDemo 1

#----------------------------------------------------------------
# The code below create the main window, consisting of a menu bar
# and a text widget that explains how to use the program, plus lists
# all of the demos as hypertext items.
#----------------------------------------------------------------

set font {Helvetica 12 bold}
menu .second.menuBar -tearoff 0
.second.menuBar add cascade -menu .second.menuBar.file -label $caption(tuto_tools)  -underline 0
menu .second.menuBar.file -tearoff 0

# On the Mac use the specia .apple menu for the about item
if {$::tcl_platform(platform) == "macintosh"} {
   .second.menuBar add cascade -menu .menuBar.apple
   menu .second.menuBar.apple -tearoff 0
   .second.menuBar.apple add command -label $caption(tuto_about)  -command "aboutBox"
} else {
   .second.menuBar.file add command -label $caption(tuto_about)  -command "aboutBox" \
      -underline 0 -accelerator "<F1>"
   .second.menuBar.file add sep
}

.second.menuBar.file add command -label $caption(tuto_quit) -command "exit" -underline 0 \
   -accelerator "Meta-Q"
.second configure -menu .second.menuBar
bind .second <F1> aboutBox

frame .second.statusBar
label .second.statusBar.lab -text "   " -relief sunken -bd 1 \
   -font -*-Helvetica-Medium-R-Normal--*-120-*-*-*-*-*-* -anchor w
label .second.statusBar.foo -width 8 -relief sunken -bd 1 \
   -font -*-Helvetica-Medium-R-Normal--*-120-*-*-*-*-*-* -anchor w
pack .second.statusBar.lab -side left -padx 2 -expand yes -fill both
pack .second.statusBar.foo -side left -padx 2
pack .second.statusBar -side bottom -fill x -pady 2

catch {image delete image$num(image1)}
image create photo image$num(image1)
image$num(image1) configure -file a1.gif -format gif
image create photo image11
set width [image width image$num(image1)]
set height [image height image$num(image1)]
set winwidth [int [expr [winfo screenwidth .second]*.85/1.7]]
set winheight [int [expr [winfo screenheight .second]*.85]]
if {$width > $winwidth} {
   image11 copy image$num(image1) -subsample 2 2
} elseif {$height > $winheight} {
   image11 copy image$num(image1) -subsample 2 2
} else {
   image11 copy image$num(image1)
}
label .second.photo1 -image image11
pack .second.photo1 -side right

frame .second.textFrame
pack .second.textFrame -expand yes -fill both
scrollbar .second.s -orient vertical -command {.second.t yview} -highlightthickness 0 \
   -takefocus 1
pack .second.s -in .second.textFrame -side right -fill y
text .second.t -yscrollcommand {.second.s set} -wrap word -font $font
#\
#   -setgrid 1 -highlightthickness 0 -padx 4 -pady 2 -takefocus 0
pack .second.t -in .second.textFrame -expand yes -fill both -padx 1

# Create a bunch of tags to use in the text widget, such as those for
# section titles and demo descriptions.  Also define the bindings for
# tags.

.second.t tag configure title -font {Helvetica 14 bold}

# We put some "space" characters to the left and right of each demo description
# so that the descriptions are highlighted only when the mouse cursor
# is right over them (but not when the cursor is to their left or right)
#
.second.t tag configure demospace -lmargin1 1c -lmargin2 1c

if {[winfo depth .second] == 1} {
   .second.t tag configure demo -lmargin1 1c -lmargin2 1c \
      -underline 1
   .second.t tag configure visited -lmargin1 1c -lmargin2 1c \
      -underline 1
   .second.t tag configure hot -background black -foreground white
} else {
   .second.t tag configure demo -lmargin1 1c -lmargin2 1c \
      -foreground blue -underline 1
   .second.t tag configure visited -lmargin1 1c -lmargin2 1c \
      -foreground #303080 -underline 1
   .second.t tag configure hot -foreground red -underline 1
}
.second.t tag bind demo <ButtonRelease-1> {
   invoke [.second.t index {@%x,%y}] .second
}
set lastLine ""
.second.t tag bind demo <Enter> {
   set lastLine [.second.t index {@%x,%y linestart}]
   .second.t tag add hot "$lastLine +1 chars" "$lastLine lineend -1 chars"
   .second.t config -cursor hand2
   #showStatus [.second.t index {@%x,%y}]
}
.second.t tag bind demo <Leave> {
   .second.t tag remove hot 1.0 end
   .second.t config -cursor xterm
   .second.statusBar.lab config -text ""
}
.second.t tag bind demo <Motion> {
   set newLine [.second.t index {@%x,%y linestart}]
   if {[string compare $newLine $lastLine] != 0} {
      .second.t tag remove hot 1.0 end
      set lastLine $newLine

      set tags [.second.t tag names {@%x,%y}]
      set i [lsearch -glob $tags demo-*]
     if {$i >= 0} {
         .second.t tag add hot "$lastLine +1 chars" "$lastLine lineend -1 chars"
      }
   }
   #showStatus [.second.t index {@%x,%y}]
}

# Create the text for the text widget.

# ====================
# === Setting text ===
# ====================

.second.t insert end "$texte(firstdark_1)\n" title
.second.t insert end "$texte(firstdark_2)\n\n" title
.second.t insert end "$texte(firstdark_3)\n\n"

.second.t insert end "$texte(firstdark_exit)" {demo demo-exit}
.second.t insert end " \n " {demospace}
.second.t insert end " \n " {demospace}

.second.t configure -state disabled
focus .second.s
wm withdraw .main

