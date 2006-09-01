#
# Fichier : test.tcl
# Description : Script pour lancer une application de test a partir d'AudeLA
# Mise a jour $Id: test.tcl,v 1.6 2006-09-01 22:38:33 robertdelmas Exp $
#

#--- definition des variables globales
global caption
global color
global zone
global infos

#--- initialisation des variables d'infos
set infos(MouseState) rien
set infos(box)        {1 1 1 1}

#--- description du texte a placer sur l'ecran
set caption(main_title) "Test"
set caption(acq)        "Acquisition"
set caption(load)       "Ouvrir"
set caption(save)       "Enregistrer"
set caption(exit)       "Quitter"
set caption(wait)       "En cours..."

#--- definition des couleurs
set color(back)       #123456
set color(back_image) #000000
set color(rectangle)  #0000EE
set color(scroll)     #BBBBBB

#--- initialisation des variables de zone
set zone(naxis1) 0
set zone(naxis2) 0

#--- charge des proc utilitaires pour Tk
source tkutil.tcl

#--- cache la fenetre racine
   wm withdraw .

#--- cree la fenetre .test de niveau le plus haut
   toplevel .test -class Toplevel -bg $color(back)
   wm geometry .test 600x400+0+0
   wm resizable .test 1 1
   wm minsize .test 600 400
   wm maxsize .test 1024 768
   wm title .test $caption(main_title)
   focus -force .test

#--- cree la ligne de commande
   entry .test.command_line \
      -font {{Arial}  8 bold} -textvariable command_line \
      -borderwidth 1 -relief groove
   pack .test.command_line \
      -in .test -fill x -side bottom \
      -padx 3 -pady 3
   set zone(command_line) .test.command_line

#--- cree la console de retour d'etats
   listbox .test.lst1 \
      -height 3 \
      -borderwidth 1 -relief sunken
   pack .test.lst1 \
      -in .test -fill x -side bottom \
      -padx 3 -pady 3
   set zone(status_list) .test.lst1

#--- cree un acsenseur vertical pour la console de retour d'etats
   scrollbar .test.lst1.scr1 -orient vertical \
      -command {.test.lst1 yview}
   pack .test.lst1.scr1 \
      -in .test.lst1 -side right -fill y
   set zone(status_scrl) .test.lst1.scr1

#--- cree un frame pour y mettre des boutons
   frame .test.frame1 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .test.frame1 \
      -in .test -anchor s -side bottom -expand 0 -fill x

#--- cree le bouton 'acquisition'
   button .test.frame1.but_acq \
      -text $caption(acq) -borderwidth 4 \
      -command { testacq }
   pack .test.frame1.but_acq \
      -in .test.frame1 -side left -anchor w \
      -padx 3 -pady 3
   set zone(acq) .test.frame1.but_acq

#--- cree le bouton 'ouvrir'
   button .test.frame1.but_load \
      -text $caption(load) -borderwidth 4 \
      -command { testload }
   pack .test.frame1.but_load \
      -in .test.frame1 -side left -anchor w \
      -padx 3 -pady 3
   set zone(load) .test.frame1.but_load

#--- cree le bouton 'enregistrer'
   button .test.frame1.but_save \
      -text $caption(save) -borderwidth 4 \
      -command { testsave }
   pack .test.frame1.but_save \
      -in .test.frame1 -side left -anchor w \
      -padx 3 -pady 3
   set zone(save) .test.frame1.but_save

#--- cree le bouton 'quitter'
   button .test.frame1.but_exit \
      -text $caption(exit) -borderwidth 4 \
      -command { testexit }
   pack .test.frame1.but_exit \
      -in .test.frame1 -side left -anchor w \
      -padx 3 -pady 3
   set zone(exit) .test.frame1.but_exit

#--- cree un frame pour y mettre des glissieres
frame .test.frame2 \
   -borderwidth 0 -cursor arrow -bg $color(back)
pack .test.frame2 \
   -in .test -anchor s -side bottom -expand 0 -fill x

#--- cree la glissiere de seuil bas
scale .test.frame2.sca1 -orient horizontal -from 0 -to 32767 -length 200 \
   -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
   -troughcolor $color(back) -background $color(back) \
   -relief raised -activebackground $color(back) -command changeLoCut1
pack .test.frame2.sca1 \
   -in .test.frame2 -anchor s -side left -expand 0 -padx 10 -pady 3
set zone(sb1) .test.frame2.sca1

#--- cree la glissiere de seuil haut
scale .test.frame2.sca2 -orient horizontal -from 0 -to 32767 -length 200 \
   -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
   -troughcolor $color(back) -background $color(back) \
   -relief raised -activebackground $color(back) -command changeHiCut1
pack .test.frame2.sca2 \
   -in .test.frame2 -anchor s -side right -expand 0 -padx 10 -pady 3
set zone(sh1) .test.frame2.sca2

#--- cree le nouveau canevas pour l'image
   Scrolled_Canvas .test.image1 -borderwidth 0 -relief flat \
      -width 300 -height 200 -scrollregion {0 0 0 0} -cursor crosshair
   pack .test.image1 \
      -in .test -expand 1 -side top -anchor center -fill both
   .test.image1.canvas configure -bg $color(back_image)
   .test.image1.canvas configure -borderwidth 0
   .test.image1.canvas configure -relief flat
   .test.image1 configure -bg $color(scroll)
   set zone(image1) .test.image1.canvas

#--- detruit la fenetre principale avec la croix en haut a droite
bind .test <Destroy> { destroy .test; exit }

bind $zone(image1) <ButtonPress-1> {
     global infos
     if { [string compare $infos(MouseState) rien] == 0 } {
        set liste [screen2Canvas [list %x %y]]
        if {[info exists zone(naxis1)]==1} {
           if {[lindex $liste 0]<$zone(naxis1) && [lindex $liste 1]<$zone(naxis2)} {
              boxBegin [list %x %y]
              set infos(MouseState) dragging
           }
        }
     } else {
        if { [string compare $infos(MouseState) context] == 0 } {
           # [MenuGet "$caption(audace,menu,analyse)"] unpost
           set infos(MouseState) rien
        }
     }
  }

  bind $zone(image1) <B1-Motion> {
     global infos
     if { [string compare $infos(MouseState) dragging] == 0 } {
        #--- Affichage des coordonnees
        # displayCursorCoord [list %x %y]
        #--- On n'oublie pas de dragger eventuellement la boite
        boxDrag [list %x %y]
     }
  }

  bind $zone(image1) <ButtonRelease-1> {
     global infos
     if { [string compare $infos(MouseState) dragging] == 0 } {
        set infos(MouseState) rien
        catch { boxEnd [list %x %y] }
     }
  }

#--- re-affiche l'image si on relache les curseurs des glissieres
bind $zone(sh1) <ButtonRelease> {catch {visu1 disp}}
bind $zone(sb1) <ButtonRelease> {catch {visu1 disp}}

#--- execute une commande a partir de la ligne de commande
bind $zone(command_line) <Key-Return> {
   set resultat [eval $command_line]
   if { [string compare $resultat ""] != 0 } {
      $zone(status_list) insert end "$resultat"
   }
   set $command_line ""
}

#--- affiche la valeur du pixel pointe dans l'image
bind $zone(image1) <Motion> {
   global zone
   #--- Transforme les coordonnees de la souris (%x,%y) en coordonnees canvas (x,y)
   set xy [screen2Canvas [list %x %y]]
   #--- Transforme les coordonnees canvas (x,y) en coordonnees image (xi,yi)
   set xyi [canvas2Picture $xy]
   set xi [lindex $xyi 0]
   set yi [lindex $xyi 1]
   #--- Intens contiendra l'intensite du pixel pointe
   set intens -
   catch { set intens [ lindex [ buf1 getpix [ list $xi $yi ] ] 1 ] }
   #--- Affichage des coordonnees
   wm title .test "Test : ($xi,$yi) = $intens    "
}

#--- declare un buffer pour placer les images en memoire
   buf::create 1
#--- declare une connexion avec une camera Audine sur LPT1
   cam::create audine lpt1 1
#--- declare un nouvel objet de visualisation pour afficher le contenu du buffer
   visu::create 1 1
#--- cree un widget image dans un canvas pour afficher l'objet de visualisation
   $zone(image1) create image 0 0 -image image1 -anchor nw -tag img1

proc testacq { } {
   #--- acquisition de l'image
   cam1 exptime 15
   cam1 bin {2 2}
   cam1 acq
   vwait status_cam1
   #--- statistiques pour calculer les seuils de visu
   set mystatistics [buf1 stat]
   set mycuts [lrange $mystatistics 0 1]
   #--- seuils de visu et affichage
   visu1 cut $mycuts
   testvisu
}

proc testload { } {
   global caption
   set filename [tk_getOpenFile -title $caption(load) \
      -filetypes {{{Images FITS} {.fit}}} \
      -initialdir [ file join .. .. images ] ]
   if {$filename!=""} {
      buf1 load $filename
      visu1 clear
      testvisu
   }
}

proc testvisu { } {
   global zone
   set zone(naxis1) [lindex [buf1 getkwd NAXIS1] 1]
   set zone(naxis2) [lindex [buf1 getkwd NAXIS2] 1]
   $zone(image1) configure -scrollregion [list 0 0 $zone(naxis1) $zone(naxis2)]
   visu1 disp
   #--- place les curseurs des barres de seuil au bon endroit
   set shb [testgetseuils]
   $zone(sb1) set [lindex $shb 1]
   $zone(sh1) set [lindex $shb 0]
   #--- definit les limites de seuils bas et haut
   set hi [buf1 getkwd MIPS-HI]
   set lo [buf1 getkwd MIPS-LO]
   buf1 stat
   set maxi [lindex [buf1 getkwd DATAMAX] 1]
   set mini [lindex [buf1 getkwd DATAMIN] 1]
   set range [expr $maxi-$mini]
   set mini [expr $mini-$range]
   set maxi [expr $maxi+$range]
   $zone(sb1) configure -from $mini -to $maxi
   $zone(sh1) configure -from $mini -to $maxi
   if {[lindex $hi 1]!=""} { buf1 setkwd $hi }
   if {[lindex $lo 1]!=""} { buf1 setkwd $lo }
}

proc testgetseuils { } {
   #--- retourne un liste contenant le seuil haut et bas de l'image
   global zone
   #--- on recherche la valeur du mot cle MIPS-HI
   set hi [lindex [buf1 getkwd MIPS-HI] 1]
   if {$hi==""} {
      #--- sinon on recherche la valeur du mot cle DATAMAX
      set hi [lindex [buf1 getkwd DATAMAX] 1]
   }
   if {$hi==""} {
      #--- sinon on fait une stat sur l'image
      buf1 stat
      set hi [lindex [buf1 getkwd MIPS-HI] 1]
      set lo [lindex [buf1 getkwd MIPS-LO] 1]
   }
   #--- on recherche la valeur du mot cle MIPS-LO
   set lo [lindex [buf1 getkwd MIPS-LO] 1]
   if {$lo==""} {
      #--- sinon on recherche la valeur du mot cle DATAMIN
      set lo [lindex [buf1 getkwd DATAMIN] 1]
   }
   if {$lo==""} {
      set lo 0
   }
   return [list $hi $lo]
}

proc testsave { } {
   global caption
   set filename [tk_getSaveFile -title $caption(load) \
      -filetypes {{{Images FITS} {.fit}}} \
      -initialdir [ file join .. .. images ] ]
   if {$filename!=""} {
      buf1 save $filename
   }
}

proc testexit { } {
   destroy .test
   exit
}

