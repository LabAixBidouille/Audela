#
# Date de mise a jour : 04 fevrier 2006
#

#!/bin/sh
# the next line restarts using wish \
#exec wish "$0" "$@"

proc caption_def_plugcam { langage } {
   global texte caption
#--- definition of captions
if {[string compare $langage french] ==0 } {
   set texte(firstdark_1) "Tutorial pour les utilisateurs de l'EthernAude"
   set texte(firstdark_2) "Reprogrammer le microcontr�leur Ethernet."
   set texte(firstdark_3) "\
Dans le bo�tier EthernAude, la carte �lectronique sup�rieure\
contient le logiciel interne de transmission Ethernet. Il\
est possible de t�l�charger les mises � jour de ce logiciel\
(http://www.astrosurf.com/ethernaude). Pour charger le logiciel\
dans la carte EthernAude, il faut relier la sortie s�rie de l'ordinateur\
� une carte de programmation SX-Blitz ou cl� SX\
(http://www.parallax.com/sx/programming_kits.asp).\n\
\n\
Sur la photo du haut, deux cavaliers sont entour�s par un rectangle rouge.\
Pour reprogrammer le microcontr�leur, il faut enlever ces deux\
cavaliers. Introduire, ensuite, la cl� SX dans les broches\
entour�es d'un rectangle orange.\n\
\n\
Sur la photo du bas, on voit la cl� SX enfich�e dans le connecteur.\
"
   set texte(firstdark_exit) " Retour � la page principale."
} else {
   set texte(firstdark_1) "Tutorial for EthernAude Users"
   set texte(firstdark_2) "Updating the Microcontroller Software for Ethernet."
   set texte(firstdark_3) "\
In an EthernAude device, the upper electronic card\
contains an internal software for Ethernet transmissions. It\
is possible to download updates\
(http://www.astrosurf.com/ethernaude).  To upload the software\
into the EthernAude card, you must link the serial port of the\
computer to an SX-Blitz or SX-Key card\
(http://www.parallax.com/sx/programming_kits.asp).\n\
\n\
On the photo above, two jumpers are identified by a red rectangle.\
To reload the microcontroller software, remove these two\
jumpers.  Plug the SX key in the pins identified by an orange rectangle.\n\
\n\
On the photo below, you can see the SK key plugged.\
"
   set texte(firstdark_exit) " Return to the Main Page."
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

toplevel .second -class Toplevel
wm title .second "$texte(tuto_1) (visu$num(visu1))"
set screenwidth [int [expr [winfo screenwidth .second]*.85]]
set screenheight [int [expr [winfo screenheight .second]*.85]]
wm geometry .second ${screenwidth}x${screenheight}+0+0
wm maxsize .second [winfo screenwidth .second] [winfo screenheight .second]
wm minsize .second ${screenwidth} ${screenheight}
wm resizable .second 1 1
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

.second.menuBar.file add command -label $caption(tuto_quit) -command "tuto_exit" -underline 0 \
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

catch {image delete $num(imageNo)}
image create photo $num(imageNo)
if {[info exists audace]==1} {
   set rep [ file join $audace(rep_plugin) link ethernaude tutorial ]
} else {
   set rep "."
}
$num(imageNo) configure -file [ file join $rep sxkeyio.gif ]
image create photo image21
set width [image width $num(imageNo)]
set height [image height $num(imageNo)]
set winwidth [int [expr [winfo screenwidth .second]*.85/1.7]]
set winheight [int [expr [winfo screenheight .second]*0.95]]
if {$width > $winwidth} {
   image21 copy $num(imageNo) -subsample 2 2
} elseif {$height > $winheight} {
   image21 copy $num(imageNo) -subsample 2 2
} else {
   image21 copy $num(imageNo)
}
label .second.photo1 -image image21
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
