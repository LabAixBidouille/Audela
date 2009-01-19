#
# Mise a jour $Id: tuto.portoc.tcl,v 1.6 2008-04-23 21:02:52 robertdelmas Exp $
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
      set texte(firstdark_2) "Mechanical Installation on an Eyepiece Holder"
      set texte(firstdark_3) "This photograph shows the Audine camera placed in the eyepiece holder of the scope.\
This simple assembly enables you to easily shoot your first images.  You just have to aim the scope\
with an eyepiece and then, once the object is visually centered, you replace the eyepiece with the camera.\n
It must be noted however that this assembly has two drawbacks. The first one is that focusing\
is different between the eyepiece and the camera. You will have to adjust focusing\
so that the camera produces a sharp image (see below) then to position an eyepiece that also produces a focused image\
without changing the focusing adjustment (sometimes a ring must be added).\n
The second drawback is that you lose the \"flat field correction\" between each image. We think this problem\
is not essential when you shoot your first images. Ultimately you will have to adapt this procedure in order to\
keep the camera in place for the whole observing session. For advice and additional information\
you can subscribe to the Aude or the Audine mailing lists.\n"
      set texte(firstdark_exit) " Return to the Main Page."
   }
   if {[string compare $langage french] ==0 } {
      set caption(main_title) "Snapshot : Premiers pas dans le monde du CCD"
      set caption(description) "Appuyer sur le bouton rouge pour faire une image de"
      set caption(go) "DEMARRER"
      set caption(wait) "En cours..."
      set caption(compute) "Analyse..."
      set caption(exit) "Quitter"
      set caption(thermlevel) "Niveau thermique ="
      set caption(max_zero) "Probl�me de connexion"
      set caption(satured) "Des pixels sont satur�s"
      set caption(maxdark) "Valeur maximum ="

      set texte(firstdark_1) "Initiation � l'imagerie CCD"
      set texte(firstdark_2) "Adaptation m�canique sur le porte-oculaire"
      set texte(firstdark_3) "Sur cette photo, la cam�ra Audine est plac�e dans le porte-oculaire du t�lescope.\
Ce montage simpliste permet de r�aliser facilement les premi�res images puisqu'il suffit de pointer\
avec un oculaire puis, une fois centr� � l'oeil, de remplacer l'oculaire par la cam�ra.\n
On notera, toutefois, que ce montage pr�sente deux inconv�nients. Le premier est que la mise au point\
(la focalisation) est diff�rente entre l'oculaire et la cam�ra. On s'arrangera pour r�gler la focalisation\
de fa�on � avoir une image nette sur la cam�ra (cf. plus loin) puis de placer l'oculaire pour avoir une image\
nette sans bouger la mise au point (il faut parfois ajouter une bague m�canique).\n
Le deuxi�me inconv�nient est que l'on perd le \"flat\" entre chaque image. Nous consid�rons que ce probl�me\
est mineur lorsque l'on r�alise ses premi�res images. Il faudra ensuite penser � modifier le montage pour\
garder la cam�ra en place pendant toute la dur�e de l'observation. Nous vous rappelons que de nombreux\
conseils peuvent vous �tre donn�s en vous inscrivant � la liste Aude ou Audine sur Internet.\n"
      set texte(firstdark_exit) " Retour � la page principale."
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

#--- definition of global variables (associative arrays)
global num       # index for devices
global caption   # texts of captions
global zone      # window name of usefull screen parts

#--- definition of global variables
global lpt       # name of the audine port
set lpt "lpt1"

#--- selection of language
caption_def_plugcam $langage

#--- definition of colors
set color(back)       #101040
set color(go)         #FF0000
set color(text)       #FFFF00
set color(back_image) #000000

#----------------------------------------------------------------
# The code below creates the main window, consisting of a menu bar
# and a text widget that explains how to use the program, plus lists
# all of the demos as hypertext items.
#----------------------------------------------------------------

#--- si la fenetre principale existe deja, je la deiconifie et je sors du script
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
set widgetDemo 1

#----------------------------------------------------------------
# The code below creates the main window, consisting of a menu bar
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
image$num(image1) configure -file a4.gif -format gif
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

bind .second <Destroy> {
   wm deiconify .main
   destroy .second
}

