
# Procédures liées à 'linterface graphique et au tracé des profils de raies. 


################################################                                           # Ouverture d'un fichier fit 
# ---------------------------------------------
# Auteur : Alain KLOTZ
# Date de creation : 17-08-2003
# Modification : Benjamin Mauclaire
# Date de mise à jour : 26-04-2004
# Argument : fichier fits du spectre spatial
################################################


proc open_fitfile { {filenamespc_spatial ""} } {
	## Chargement : source $audace(rep_scripts)/profil_raie.tcl
	## Les var nommees audace_* sont globales
	global audace
        global captionspc
	## flag audace
	global conf
	global flag_ok
	set extsp "dat"

        global caption

   ## === Interfacage de l'ouverture du fichier profil de raie ===
   if {$filenamespc_spatial==""} {
      # set idir ./
      # set ifile *.spc
      set idir $audace(rep_images)
      #set conf(extension,defaut) fit
      # $conf(extension,defaut) contient le point
      set ifile *$conf(extension,defaut)
      
      if {[info exists profilspc(initialdir)] == 1} {
         set idir "$profilspc(initialdir)"
      }
      if {[info exists profilspc(initialfile)] == 1} {
         set ifile "$profilspc(initialfile)"
      }
      ## set filenamespc [tk_getOpenFile -title $captionspc(loadspc) -filetypes [list [list "$captionspc(spc_profile)" {.spc}]] -initialdir $idir -initialfile $ifile ]
      #set filenamespc_spatial [tk_getOpenFile -title $captionspc(open_fitfile) -filetypes [list [list "$captionspc(spc_profile)" {.fit}]] -initialdir $idir -initialfile $ifile ]
      set filenamespc_spacial [tk_getOpenFile -title "$captionspc(open_fitfile)" -filetypes [list [list "$caption(fichier,image,fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ]

### Debut modif Robert (supprime le bug de la fermeture par la croix (x) de la fenetre "Charger un profil de raie")
      if {[string compare $filenamespc_spacial ""] == 0 } {
         return 0
      }
### Fin modif Robert

      #::console::affiche_resultat "Fichier : $filenamespc_spacial\n"
      #if {[string compare $filenamespc_spatial ""] == 0 } {
      #   return 0
      #}
   }
   ::console::affiche_resultat "Fichier ouvert : $filenamespc_spacial\n"
   ::spc_extract_profil_zone $filenamespc_spacial
   ### Debut modif Robert (affichage immediat du profil cree, evite une seconde manipulation)
   # ::loadspc [ file rootname $filenamespc_spacial ].dat
   ### Fin modif Robert

}


proc spc_winini { } {
############################################################################
# Initialise la fenêtre de visualisation des profils
############################################################################
   global profilspc
   global printernames
   global captionspc
   global colorspc

   # === On cree une nouvelle fenetre ===
   wm withdraw .
   if {[info command .spc] == "" } {
      toplevel .spc -class Toplevel
   }
   wm title .spc "$captionspc(main_title) : $profilspc(initialfile)"   
   wm geometry .spc 640x480+0+100
   wm maxsize .spc [winfo screenwidth .spc] [winfo screenheight .spc]
   wm minsize .spc 320 200
   wm resizable .spc 1 1

   # === On remplit la fenetre ===
   if {[info command .spc.g] == "" } { 
      # --- zone d'informations ---
      frame .spc.frame1 \
         -borderwidth 0 -cursor arrow -bg $colorspc(back_infos)
      pack .spc.frame1 \
         -in .spc -anchor s -side bottom -expand 0 -fill x
      label .spc.frame1.label1 \
         -font [list {Arial} 10 bold ] -text "" \
         -borderwidth 0 -relief flat -bg $colorspc(back_infos) \
         -fg $colorspc(fore_infos)
      pack .spc.frame1.label1 \
         -in .spc.frame1 -side bottom -anchor center \
         -padx 3 -pady 3
      # --- imprimantes disponibles ---
      # set printernames [blt::printer names]
      set printernames "hplj"
      set nbprinters [llength $printernames]
      # --- menu File ---
      menu .spc.menuBar -tearoff 0
      .spc.menuBar add cascade -menu .spc.menuBar.file -label $captionspc(file) -underline 0
      menu .spc.menuBar.file -tearoff 0
      .spc.menuBar.file add command -label $captionspc(open_fitfile) -command "open_fitfile" -underline 0 -accelerator "Ctrl-N"
      .spc.menuBar.file add command -label $captionspc(loadspcfit) -command "spc_loadfit" -underline 0 -accelerator "Ctrl-O"
      .spc.menuBar.file add command -label $captionspc(loadspctxt) -command "spc_loaddat" -underline 0 -accelerator "Ctrl-T"
      .spc.menuBar.file add command -label $captionspc(writeps) -command "spc_postscript" -underline 0 -accelerator "Ctrl-E"
      if {$nbprinters>0} {
         for {set k 0} {$k<$nbprinters} {incr k} {
	     # .spc.menuBar.file add command -label "$captionspc(print_on) [lindex $printernames $k]" -command "spc_print $k" -underline 0 -accelerator "Ctrl-P" -state disabled
	     .spc.menuBar.file add command -label "$captionspc(print_on) [lindex $printernames $k]" -command "spc_print $k" -underline 0 -accelerator "Ctrl-P"
         }
      }

      .spc.menuBar.file add command -label $captionspc(quitspc) -command "destroy .spc" -underline 0 -accelerator "Ctrl-Q"
      .spc configure -menu .spc.menuBar
      bind .spc <Control-N> open_fitfile
      bind .spc <Control-O> spc_loadfit
      bind .spc <Control-A> spc_loaddat
      bind .spc <Control-P> spc_print
      bind .spc <Control-E> spc_postscript
      bind .spc <Control-Q> { destroy .spc }
      bind .spc <Control-n> open_fitfile
      bind .spc <Control-o> spc_loadfit
      bind .spc <Control-a> spc_loaddat
      bind .spc <Control-p> spc_print
      bind .spc <Control-e> spc_postscript
      bind .spc <Control-q> { destroy .spc }
      #bind .spc <F1> aboutBox


      # --- Menu Calibration ---
      .spc.menuBar add cascade -menu .spc.menuBar.calibration -label $captionspc(calibration) -underline 0
      menu .spc.menuBar.calibration -tearoff 0
      .spc.menuBar.calibration add command -label $captionspc(cali_lambda) -command "cali_lambda" -underline 0 -accelerator "Ctrl-L"
      .spc.menuBar.calibration add command -label $captionspc(cali_flux) -command "cali_flux" -underline 0 -accelerator "Ctrl-F"
      .spc configure -menu .spc.menuBar
      bind .spc <Control-L> cali_lambda
      bind .spc <Control-l> cali_lambda
      bind .spc <Control-F> cali_flux
      bind .spc <Control-f> cali_flux


      # --- Menu Mesures ---
      .spc.menuBar add cascade -menu .spc.menuBar.mesures -label $captionspc(mesures) -underline 0
      menu .spc.menuBar.mesures -tearoff 0
      .spc.menuBar.mesures add command -label $captionspc(mes_especes) -command "mes_especes" -underline 0 -accelerator "Ctrl-E"
      .spc.menuBar.mesures add command -label $captionspc(mes_TE) -command "mes_TE" -underline 0 -accelerator "Ctrl-T"
      .spc.menuBar.mesures add command -label $captionspc(mes_DE) -command "mes_DE" -underline 0 -accelerator "Ctrl-D"
      .spc configure -menu .spc.menuBar
      bind .spc <Control-A> mes_especes
      bind .spc <Control-a> mes_especes
      bind .spc <Control-T> mes_TE
      bind .spc <Control-t> mes_TE
      bind .spc <Control-D> mes_DE
      bind .spc <Control-d> mes_DE


      # --- graphe BLT ---
      blt::graph .spc.g -plotbackground $colorspc(plotbackground)
      pack .spc.g -in .spc
      pvisutools
   }
   .spc.g configure \
      -font [list {Arial} 10 bold ] \
      -plotrelief flat \
      -width 1024 \
      -height 768 \
      -background $colorspc(back_graphborder)
}

proc pvisutools {} {
############################################################################
# Outils d'affichage
############################################################################
   global profilspc
   global captionspc
   global colorspc

   .spc.g element create line1 -symbol none -xdata {0 1} -ydata {0 1} -smooth natural
   .spc.g axis configure x2 y2 -hide no
   .spc.g element configure line1 -color $colorspc(plotbackground)
   set lx [.spc.g axis limits x]
   set ly [.spc.g axis limits y]
   .spc.g axis configure x2 -min [lindex $lx 0] -max [lindex $lx 1]
   .spc.g axis configure y2 -min [lindex $ly 0] -max [lindex $ly 1]
   .spc.g legend configure -hide yes

   .spc.g crosshairs on
   .spc.g crosshairs configure -color red -dashes 2

   bind .spc.g <Motion> {
      set x %x
      set y %y
      set x [.spc.g axis invtransform x $x]
      set y [.spc.g axis invtransform y $y]
      set lx [string length $x]
      if {$lx>8} { set x [string range $x 0 7] }
      set ly [string length $y]
      if {$ly>8} { set y [string range $y 0 7] }
      .spc.g crosshairs configure -position @%x,%y 
      .spc.frame1.label1 configure -text "$x $profilspc(xunit)   $y $profilspc(yunit)"
   }

   scrollbar .spc.hs -command {.spc.g axis view x } -orient horizontal
   scrollbar .spc.vs -command {.spc.g axis view y } -orient vertical
   .spc.g axis configure x -scrollcommand { .spc.hs set }
   .spc.g axis configure y -scrollcommand { .spc.vs set }

   bind .spc.g <ButtonPress-1> { spc_RegionStart %W %x %y }
   bind .spc.g <B1-Motion> { spc_RegionMotion %W %x %y }
   bind .spc.g <ButtonRelease-1> { spc_RegionEnd %W %x %y }
   bind .spc.g <ButtonRelease-3> { spc_Unzoom %W }

}


############################################################################
# Charge un profil au format .spc et l'affiche dans la fenetre
#
# Date de creation : ? Alain Klotz
# Date de modification : 18-02-2005 Benjamin Mauclaire
############################################################################

proc pvisu { } {

   global profilspc
   global printernames
   global captionspc
   global colorspc
   global audace

   set extsp "dat"

   # === On cree la fenetre si elle n'existe pas ===
   wm withdraw .
   if {[info command .spc] == "" } {
      spc_winini
   }

   # === On modifie la fenetre ($filenamespc) ===
   .spc.g configure -title $profilspc(object)

   ## === Lecture du fichier de donnees du profil de raie ===
   #catch {unset profilspc} {}
   #set profilspc(initialdir) [file dirname $audace(rep_images)]
   #set profilspc(initialfile) [file tail $filenamespc]
   #set input [open "$audace(rep_images)/$filenamespc" r]
   #set contents [split [read $input] \n]
   #close $input

   ## === MOI : Extraction des numeros des pixels et des intensites ===
   ##::console::affiche_resultat "ICI :\n $contents.\n"
   #set profilspc(naxis2) [expr [llength $contents]-2]
   ##::console::affiche_resultat "$profilspc(naxis2)\n"
   #set offset 1
   #for {set k 1} {$k <= $profilspc(naxis2)} {incr k} {
   #   set ligne [lindex $contents $offset]
   #   append profilspc(pixels) "[lindex $ligne 0] "
   #   append profilspc(intensite) "[lindex $ligne 1] "
   #   incr offset
   #}
   #::console::affiche_resultat "$profilspc(pixels)\n"

   # === On prepare les vecteurs a afficher ===
   set len [llength $profilspc(pixels)]
   set pp ""
   set yy ""
   set kk 0
   # for {set k 1} {$k<=$len} {incr k} {} # Boucle originale Klotz
   for {set k 0} {$k<$len} {incr k} {
         append pp " [lindex $profilspc(pixels) $k]"
         append yy " [lindex $profilspc(intensite) $k]"
         incr kk         
   }
   #::console::affiche_resultat "$pp\n"
   blt::vector create vx
   blt::vector create vy


   ## Tracer du profil de raie
   #toplevel .spc
   # .spc.g -title "Profil de raie spatial de $profilspc(object)"
   # === Affichage du profil ===
   set xdepart [lindex $profilspc(pixels) 0]
   if {$xdepart == 0 || $xdepart == 1} {
      vx set $pp
      .spc.g axis configure x -title $captionspc(pixel)
      set profilspc(xunit) $captionspc(pixel)
   } else {
      vx set $pp
      .spc.g axis configure x -title $captionspc(angstroms)
      set profilspc(xunit) $captionspc(angstroms)
   }
   vy set $yy
   .spc.g axis configure y -title $captionspc(intensity)
   set profilspc(yunit) $captionspc(adu)
   .spc.g element delete line1
   .spc.g element create line1 -symbol none -xdata vx -ydata vy -smooth natural
   .spc.g element configure line1 -color $colorspc(profile)
   .spc.g axis configure x2 y2 -hide no
   set lx [.spc.g axis limits x]
   set ly [.spc.g axis limits y]
   .spc.g axis configure x2 -min [lindex $lx 0] -max [lindex $lx 1]
   .spc.g axis configure y2 -min [lindex $ly 0] -max [lindex $ly 1]

   .spc.g configure -width 7.87i -height 5.51i
   .spc.g legend configure -hide yes
   pack .spc.g -in .spc 
   vx set $pp
   vy set $yy
   ### Bogue ICI   
   #.spc.g element create "Profil spatial" -symbol none -xdata vx -ydata vy -smooth natural

   set div_x 10
   set div_y 5
   #set echellex [expr $len/10]
   set echellex [expr int($len/($div_x*10))*10]
   .spc.g axis configure x -stepsize $echellex
   #scrollbar .hors -command {.spc.g axis view x } -orient horizontal
   #.spc.g axis configure x -stepsize $echellex -scrollcommand { .hors set }

   set tmp_i [lsort -real -decreasing $profilspc(intensite)]
   set i_max [lindex $tmp_i 0]
   #set echelley [expr $i_max/5]
   ## Petit bug ICI
   set echelley [expr int($i_max/($div_y*10))*10]
   .spc.g axis configure y -stepsize $echelley

}



#****************************************************************#

##########################################                                        
#  Procedures d'oprations geometriques  
# 
# Arguments : fichier .dat du profil de raie                                  
##########################################


proc spc_Zoom { graph x1 y1 x2 y2 } {
   if { $x1 > $x2 } {
      $graph axis configure x -min $x2 -max $x1
   } elseif { $x1 < $x2 } {
      $graph axis configure x -min $x1 -max $x2
   }
   if { $y1 > $y2 } {
      $graph axis configure y -min $y2 -max $y1
   } elseif { $y1 < $y2 } {
      $graph axis configure y -min $y1 -max $y2
   }
} 

proc spc_Unzoom { graph } {
   $graph axis configure x y -min {} -max {}
}

proc spc_RegionStart { graph x y } {
   global x0 y0
   set x [$graph axis invtransform x $x]
   set y [$graph axis invtransform y $y]
   $graph marker create line -coords {} -name myLine \
      -dashes dash -xor yes
   set x0 $x ; set y0 $y
}

proc spc_RegionMotion { graph x y } {
   global x0 y0
   set x [$graph axis invtransform x $x]
   set y [$graph axis invtransform y $y]
   $graph marker configure myLine -coords \
      "$x0 $y0 $x0 $y $x $y $x $y0 $x0 $y0"
}

proc spc_RegionEnd { graph x y } {
   global x0 y0
   $graph marker delete myLine
   set x [$graph axis invtransform x $x]
   set y [$graph axis invtransform y $y]
   spc_Zoom $graph $x0 $y0 $x $y
}

proc spc_print { k } {
   global printernames
   global captionspc
   global colorspc
   set k 0
   set printername [lindex $printernames $k]
   # blt::printer -> invalid command name
   set pid [blt::printer open "$printername"]
   .spc.frame1.label1 configure -text "$caption(print_on) $printername (pid=$pid)"
   .spc.g print2 $pid
   printer close $pid
}

proc spc_postscript {} {
   global profilspc
   global captionspc
   global colorspc
   .spc.g postscript configure -landscape yes -maxpect yes -decorations no
   set ind [string last . $profilspc(initialfile)]
   if {$ind==-1} { set ind end }
   set filename "$profilspc(initialdir)/"
   append filename [string range $profilspc(initialfile) 0 $ind]
   append filename "ps"
   .spc.frame1.label1 configure -text "Post Script : $filename"
   #.spc.g postscript output $filename.ps
   .spc.g postscript output $filename
}

spc_winini




