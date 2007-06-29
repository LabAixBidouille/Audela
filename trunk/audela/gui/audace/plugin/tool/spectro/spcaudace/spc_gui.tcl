
# Procédures liées à 'linterface graphique et au tracé des profils de raies. 


################################################                                           # Ouverture d'un fichier fit 
# ---------------------------------------------
# Auteur : Alain KLOTZ
# Date de creation : 17-08-2003
# Modification : Benjamin Mauclaire
# Date de mise à jour : 25-02-2005
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
#--- Debut modif Robert
      set filenamespc_spacial [tk_getOpenFile -title "$captionspc(spc_open_fitfile)" -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ]
#--- Fin modif Robert

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
   wm title .spc "$captionspc(main_title) - $profilspc(initialfile)"   
   #wm geometry .spc 640x480+0+100
   wm geometry .spc 640x513+0-68
   wm maxsize .spc [winfo screenwidth .spc] [winfo screenheight .spc]
   wm minsize .spc 320 200
   wm resizable .spc 1 1
   # A ameliorer : lorsqu'un graphe est affiche et que la fenetre est elargie, la fenetre du graphe ne prend pas toute la place.

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


      #--- Menu Fichier ---#
      menu .spc.menuBar -tearoff 0
      .spc.menuBar add cascade -menu .spc.menuBar.file -label $captionspc(file) -underline 0
      menu .spc.menuBar.file -tearoff 0
      .spc.menuBar.file add command -label $captionspc(loadspcfit) -command "spc_loadfit" -underline 0 -accelerator "Ctrl-O"
      .spc.menuBar.file add command -label $captionspc(loadspctxt) -command "spc_loaddat" -underline 0 -accelerator "Ctrl-T"
      .spc.menuBar.file add command -label $captionspc(spc_file_space)
      .spc.menuBar.file add command -label $captionspc(spc_repconf) -command { ::cwdWindow::run "$audace(base).cwdWindow" } -underline 0
      .spc.menuBar.file add command -label $captionspc(spc_file_space)
      .spc.menuBar.file add command -label $captionspc(spc_spc2png_w) -command "spc_export2png" -underline 0
      .spc.menuBar.file add command -label $captionspc(spc_spc2png2_w) -command "spc_fit2pngopt" -underline 0
      .spc.menuBar.file add command -label $captionspc(writeps) -command "spc_postscript" -underline 0 -accelerator "Ctrl-E"
      .spc.menuBar.file add command -label $captionspc(spc_file_space)
      .spc.menuBar.file add command -label $captionspc(spc_fits2dat_w) -command "spc_fits2dat" -underline 0
      .spc.menuBar.file add command -label $captionspc(spc_file_space)
      .spc.menuBar.file add command -label $captionspc(spc_dat2fits_w) -command "spc_dat2fits" -underline 0
      .spc.menuBar.file add command -label $captionspc(spc_spc2fits_w) -command "spc_spc2fits" -underline 0
      .spc.menuBar.file add command -label $captionspc(spc_spcs2fits_w) -command "spc_spcs2fits" -underline 0
      .spc.menuBar.file add command -label $captionspc(spc_file_space)
      .spc.menuBar.file add command -label $captionspc(spc_bessmodule_w) -command "spc_bessmodule" -underline 0
      .spc.menuBar.file add command -label $captionspc(spc_file_space)
      .spc.menuBar.file add command -label $captionspc(spc_simbad) -command "spc_simbad" -underline 0
      .spc.menuBar.file add command -label $captionspc(spc_bess) -command "spc_bess" -underline 0
      .spc.menuBar.file add command -label $captionspc(spc_uves) -command "spc_uves" -underline 0
      .spc.menuBar.file add command -label $captionspc(spc_file_space)
      if {$nbprinters>0} {
         for {set k 0} {$k<$nbprinters} {incr k} {
	     # .spc.menuBar.file add command -label "$captionspc(print_on) [lindex $printernames $k]" -command "spc_print $k" -underline 0 -accelerator "Ctrl-P" -state disabled
	     .spc.menuBar.file add command -label "$captionspc(print_on) [lindex $printernames $k]" -command "spc_print $k" -underline 0 -accelerator "Ctrl-P"
         }
      }

      .spc.menuBar.file add command -label $captionspc(quitspc) -command "destroy .spc" -underline 0 -accelerator "Ctrl-Q"
      .spc configure -menu .spc.menuBar
      #-- Raccourcis calviers :
      bind .spc <Control-O> spc_loadfit
      bind .spc <Control-T> spc_loaddat
      bind .spc <Control-P> spc_print
      bind .spc <Control-E> spc_postscript
      bind .spc <Control-Q> { destroy .spc }
      bind .spc <Control-o> spc_loadfit
      bind .spc <Control-t> spc_loaddat
      bind .spc <Control-p> spc_print
      bind .spc <Control-e> spc_postscript
      bind .spc <Control-q> { destroy .spc }
      #bind .spc <F1> aboutBox


      #--- Menu Géométrie ---#
      .spc.menuBar add cascade -menu .spc.menuBar.geometrie -label $captionspc(spc_geometrie) -underline 0
      menu .spc.menuBar.geometrie -tearoff 0
      # .spc configure -menu .spc.menuBar
      .spc.menuBar.geometrie add command -label $captionspc(spc_pretraitementfc_w) -command "spc_pretraitementfc_w" -underline 0
      .spc.menuBar.geometrie add command -label $captionspc(spc_register_w) -command "spc_register" -underline 0
      .spc.menuBar.geometrie add command -label $captionspc(spc_rot180_w) -command "spc_flip" -underline 0
      .spc.menuBar.geometrie add command -label $captionspc(spc_tiltauto_w) -command "spc_tiltauto" -underline 0
      .spc.menuBar.geometrie add command -label $captionspc(spc_tilt_w) -command "spc_tilt" -underline 0
      .spc.menuBar.geometrie add command -label $captionspc(spc_slant_w) -command "spc_slant" -underline 0
      .spc.menuBar.geometrie add command -label $captionspc(spc_smilex_w) -command "spc_smilex" -underline 0
      .spc.menuBar.geometrie add command -label $captionspc(spc_smiley_w) -command "spc_smiley" -underline 0


      #--- Menu Profil de raies ---#
      .spc.menuBar add cascade -menu .spc.menuBar.profil -label $captionspc(spc_profil) -underline 0
      menu .spc.menuBar.profil -tearoff 0
      # .spc.menuBar.profil add command -label $captionspc(spc_open_fitfile) -command "open_fitfile" -underline 0 -accelerator "Ctrl-n"
      .spc.menuBar.profil add command -label $captionspc(spc_profil_w) -command "spc_profil" -underline 0
      .spc.menuBar.profil add command -label $captionspc(spc_traitea_w) -command "spc_traitea" -underline 0
      .spc.menuBar.profil add command -label $captionspc(spc_extract_zone_w) -command "spc_extract_profil_zone" -underline 0
      #.spc.menuBar.profil add command -label $captionspc(spc_extract_zone_w) -command "spc_profil_zone" -underline 0
      #.spc.menuBar.profil add command -label $captionspc(spc_extract_zone_w) -command "spc_profil_zone" -underline 0
      .spc configure -menu .spc.menuBar
      #-- Raccourcis calviers :
      #bind .spc <Control-N> spc_open_fitfile
      #bind .spc <Control-n> spc_open_fitfile


      #--- Menu Mesures ---#
      .spc.menuBar add cascade -menu .spc.menuBar.mesures -label $captionspc(spc_mesures) -underline 0
      menu .spc.menuBar.mesures -tearoff 0
      # .spc configure -menu .spc.menuBar
      .spc.menuBar.mesures add command -label $captionspc(spc_centergrav_w) -command "spc_centergrav" -underline 0
      .spc.menuBar.mesures add command -label $captionspc(spc_centergauss_w) -command "spc_centergauss" -underline 0
      .spc.menuBar.mesures add command -label $captionspc(spc_fwhm_w) -command "spc_fwhm" -underline 0
      .spc.menuBar.mesures add command -label $captionspc(spc_ew_w) -command "spc_autoew" -underline 0
      .spc.menuBar.mesures add command -label $captionspc(spc_intensity_w) -command "spc_intensity" -underline 0


      #--- Menu Calibration ---#
      .spc.menuBar add cascade -menu .spc.menuBar.calibration -label $captionspc(spc_calibration) -underline 0
      menu .spc.menuBar.calibration -tearoff 0
      # .spc.menuBar.calibration add command -label $captionspc(cali_lambda) -command "cali_lambda" -underline 0 -accelerator "Ctrl-L"
      .spc.menuBar.calibration add command -label $captionspc(spc_calibre2file_w) -command "spc_calibre" -underline 0 -accelerator "Ctrl-L"
      #.spc.menuBar.calibration add command -label $captionspc(spc_calibre2file_w) -command "spc_calibre2file_w" -underline 0 -accelerator "Ctrl-L"
      .spc.menuBar.calibration add command -label $captionspc(spc_calibre2loifile_w) -command "spc_calibre2loifile_w" -underline 0 -accelerator "Ctrl-M"
      .spc.menuBar.calibration add command -label $captionspc(spc_calibre_space)
      .spc.menuBar.calibration add command -label $captionspc(spc_rinstrum_w) -command "spc_rinstrum" -underline 0
      .spc.menuBar.calibration add command -label $captionspc(spc_rinstrumcorr_w) -command "spc_rinstrumcorr" -underline 0 -accelerator "Ctrl-I"
      .spc.menuBar.calibration add command -label $captionspc(spc_calibre_space)
      .spc.menuBar.calibration add command -label $captionspc(spc_norma_w) -command "spc_autonorma" -underline 0
      .spc configure -menu .spc.menuBar
      #-- Raccourcis calviers :
      bind .spc <Control-L> cali_lambda
      bind .spc <Control-l> cali_lambda
      bind .spc <Control-F> cali_flux
      bind .spc <Control-f> cali_flux

      #--- Menu Pipelines ---#
      .spc.menuBar add cascade -menu .spc.menuBar.pipelines -label $captionspc(spc_pipelines) -underline 0
      menu .spc.menuBar.pipelines -tearoff 0
      # .spc.menuBar.pipelines add command -label $captionspc(spc_geom2calibre_w) -command "spc_geom2calibre_w" -underline 0 -accelerator "Ctrl-1"
      .spc.menuBar.pipelines add command -label $captionspc(spc_traite2rinstrum_w) -command "::param_spc_audace_traite2rinstrum::run" -underline 0 -accelerator "Ctrl-1"
      .spc.menuBar.pipelines add command -label $captionspc(spc_lampe2calibre_w) -command "::param_spc_audace_lampe2calibre::run" -underline 0 -accelerator "Ctrl-2"
      .spc.menuBar.pipelines add command -label $captionspc(spc_traite2srinstrum_w) -command "::param_spc_audace_traite2srinstrum::run" -underline 0 -accelerator "Ctrl-3"
      .spc.menuBar.pipelines add command -label $captionspc(spc_pipelines_space)
      .spc.menuBar.pipelines add command -label $captionspc(spc_traitestellaire) -command "::param_spc_audace_traitestellaire::run" -underline 0 -accelerator "Ctrl-4"
      .spc.menuBar.pipelines add command -label $captionspc(spc_pipelines_space)
      .spc.menuBar.pipelines add command -label $captionspc(spc_traite2scalibre_w) -command "::param_spc_audace_traite2scalibre::run" -underline 0 -accelerator "Ctrl-5"
      .spc.menuBar.pipelines add command -label $captionspc(spc_pipelines_space)
      # .spc.menuBar.pipelines add command -label $captionspc(spc_traitesimple2calibre_w) -command "::param_spc_audace_traitesimple2calibre::run" -underline 0 -accelerator "Ctrl-0"
      # .spc.menuBar.pipelines add command -label $captionspc(spc_traitesimple2rinstrum_w) -command "::param_spc_audace_traitesimple2rinstrum::run" -underline 0 -accelerator "Ctrl-1"
      .spc.menuBar.pipelines add command -label $captionspc(spc_geom2calibre_w) -command "::param_spc_audace_geom2calibre::run" -underline 0 -accelerator "Ctrl-6"
      .spc.menuBar.pipelines add command -label $captionspc(spc_geom2rinstrum_w) -command "::param_spc_audace_geom2rinstrum::run" -underline 0 -accelerator "Ctrl-7"
      #.spc.menuBar.pipelines add command -label $captionspc(spc_pipelines_space)
      #.spc.menuBar.pipelines add command -label $captionspc(spc_specLhIII_w) -command "::spbmfc::fenetreSpData" -underline 0 -accelerator "Ctrl-8"
      .spc configure -menu .spc.menuBar
      #-- Raccourcis calviers :
      #bind .spc <Control-0> ::param_spc_audace_traitesimple2calibre::run
      #bind .spc <Control-1> ::param_spc_audace_traitesimple2rinstrum::run
      #bind .spc <Control-2> ::param_spc_audace_geom2calibre::run
      bind .spc <Control-2> ::param_spc_audace_geom2rinstrum::run
      bind .spc <Control-4> ::param_spc_audace_traite2calibre::run
      bind .spc <Control-3> ::param_spc_audace_traite2srinstrum::run
      bind .spc <Control-1> ::param_spc_audace_traite2rinstrum::run
      #bind .spc <Control-7> ::spcmfc::Demarragespbmfc

      #--- Menu Astrophysique ---#
      .spc.menuBar add cascade -menu .spc.menuBar.analyse -label $captionspc(spc_analyse) -underline 0
      menu .spc.menuBar.analyse -tearoff 0
      #.spc.menuBar.analyse add command -label $captionspc(spc_chimie) -command "spc_chimie" -underline 0 -accelerator "Ctrl-A"
      .spc.menuBar.analyse add command -label $captionspc(spc_surveys) -command "spc_surveys" -underline 0
      .spc.menuBar.analyse add command -label $captionspc(spc_bebuil) -command "spc_bebuil" -underline 0
      .spc.menuBar.analyse add command -label $captionspc(spc_file_space)
      .spc.menuBar.analyse add command -label $captionspc(spc_vradiale_w) -command "spc_vradiale" -underline 0
      #.spc.menuBar.analyse add command -label $captionspc(spc_vexp_w) -command "spc_vexp" -underline 0
      #.spc.menuBar.analyse add command -label $captionspc(spc_vrot_w) -command "spc_vrot" -underline 0
      .spc.menuBar.analyse add command -label $captionspc(spc_file_space)
      .spc.menuBar.analyse add command -label $captionspc(spc_ew_w) -command "spc_autoew" -underline 0
      .spc.menuBar.analyse add command -label $captionspc(spc_ewcourbe_w) -command "spc_ewcourbe" -underline 0
      .spc.menuBar.analyse add command -label $captionspc(spc_file_space)
      .spc.menuBar.analyse add command -label $captionspc(spc_npte_w) -command "spc_npte" -underline 0 -accelerator "Ctrl-E"
      .spc.menuBar.analyse add command -label $captionspc(spc_npne_w) -command "spc_npne" -underline 0 -accelerator "Ctrl-D"
      .spc.menuBar.analyse add command -label $captionspc(spc_file_space)
      .spc.menuBar.analyse add command -label $captionspc(spc_spectrum) -command "spc_spectrum" -underline 0
      .spc configure -menu .spc.menuBar
      #-- Raccourcis calviers :
      bind .spc <Control-A> mes_especes
      bind .spc <Control-a> mes_especes
      bind .spc <Control-E> spc_npte_w
      bind .spc <Control-e> spc_npte_w
      bind .spc <Control-D> spc_npne_w
      bind .spc <Control-d> spc_npne_w


      #--- Menu À propos/Aide ---#
      .spc.menuBar add cascade -menu .spc.menuBar.aide -label $captionspc(spc_aide) -underline 0
      menu .spc.menuBar.aide -tearoff 0
      # .spc.menuBar.aide add command -label $captionspc(spc_version_w) -command "spc_version" -underline 0
      .spc.menuBar.aide add command -label $captionspc(spc_version_w)
      .spc.menuBar.aide add command -label $captionspc(spc_help) -command "spc_help"
      .spc.menuBar.aide add command -label $captionspc(spc_about_w)
      .spc.menuBar.aide add command -label $captionspc(spc_contrib_w)
      .spc configure -menu .spc.menuBar
      #bind .spc <Control-A> spc_about_w

      #--- Fenêtre de graphe BLT ---#
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

   #- 060317
   #set profilspc(initialfile) $profilspc(object)

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
   #::console::affiche_resultat "$profilspc(intensite)\n"

   # === On prepare les vecteurs a afficher ===
   set len [llength $profilspc(pixels)]
   blt::vector create vx
   blt::vector create vy
   vx set $profilspc(pixels)
   vy set $profilspc(intensite)
   #for {set i 0} {$i<$len} {incr i} {
   #    set vx($i) [ lindex $profilspc(pixels) $i ]
   #    set vy($i) [ lindex $profilspc(intensite) $i ]
   #}

   ## Tracer du profil de raie
   #toplevel .spc
   # .spc.g -title "Profil de raie spatial de $profilspc(object)"
   # === Affichage du profil ===

   #--- Preparation des vecteurs :
   set xdepart [lindex $profilspc(pixels) 0]
   if {$xdepart == 0 || $xdepart == 1} {
      .spc.g axis configure x -title $captionspc(pixel)
      set profilspc(xunit) $captionspc(pixel)
   } else {
      .spc.g axis configure x -title $captionspc(angstroms)
      set profilspc(xunit) $captionspc(angstroms)
   }

   #--- Affichage du graphique :
   .spc.g configure -title $profilspc(object)
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


   ### Bogue ICI   
   #.spc.g element create "Profil spatial" -symbol none -xdata vx -ydata vy -smooth natural

   set div_x 10
   set div_y 5
   #set echellex [expr $len/10]

   #set echellex [expr int($len/($div_x*10))*10]
   #.spc.g axis configure x -stepsize $echellex

   set echellex [expr int($len/($div_x*10))*10]
   if { [expr $vx(end) < $vx(0) ] } {
       set echellex [expr $echellex * -1 ]
   }
   .spc.g axis configure x -stepsize $echellex

   #scrollbar .hors -command {.spc.g axis view x } -orient horizontal
   #.spc.g axis configure x -stepsize $echellex -scrollcommand { .hors set }

   #-- Meth 1 :
   #set tmp_i [ lsort -real -decreasing $profilspc(intensite) ]
   #set imax [ lindex $tmp_i 0 ]
   ##set echelley [expr $i_max/5]
   ## Petit bug ICI
   #set echelley [ expr 10*int($imax/($div_y*10)) ]
   #.spc.g axis configure y -stepsize $echelley

   #-- Meth 2 :
   #set echelley [ expr 10*int($vy(max)/($div_y*10)) ]
   #-- Meth 3 :
   set echelley [ expr 10*int(($vy(max)-$vy(min)/($div_y*10))) ]
   return ""
}
#****************************************************************#


############################################################################
# Charge un profil au format .spc et l'affiche dans la fenetre
#
# Date de creation : ? Alain Klotz
# Date de modification : 18-02-2005 Benjamin Mauclaire
############################################################################

proc pvisu_050218 { } {

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
       #-- Gestion des valeurs "nan" de l'intensite
       # set valy [lindex $profilspc(intensite) $k]
       #if { $valy == "nan" } {
       #   append yy " 0"
       # } else {
       #   append yy " $valy"
       #}
       incr kk         
   }
   #::console::affiche_resultat "$pp\n"
   blt::vector create vx
   blt::vector create vy
   vy set $yy

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

   set tmp_i [ lsort -real -decreasing $profilspc(intensite) ]
   set imax [ lindex $tmp_i 0 ]
   #set echelley [expr $i_max/5]
   ## Petit bug ICI
   set echelley [ expr 10*int($imax/($div_y*10)) ]
   .spc.g axis configure y -stepsize $echelley

}
#****************************************************************#



############################################################################
# Charge un profil au format .spc et l'affiche dans la fenetre
#
# Date de creation : ? Alain Klotz
# Date de modification : 18-02-2005 Benjamin Mauclaire
############################################################################

proc pvisu2 { args } {

   global profilspc
   global printernames
   global captionspc
   global colorspc
   global audace

   set extsp "dat"
   set intensites [ lindex $args 0 ]
   ::console::affiche_resultat "$intensites\n"
   # === On cree la fenetre si elle n'existe pas ===
   wm withdraw .
   if {[info command .spc] == "" } {
      spc_winini
   }

   # === On modifie la fenetre ($filenamespc) ===
   .spc.g configure -title $profilspc(object)

   # === On prepare les vecteurs a afficher ===
   set len [ llength $intensites ]
   set pp ""
   set yy ""
   set kk 0
   # for {set k 1} {$k<=$len} {incr k} {} # Boucle originale Klotz
   for {set k 0} {$k<$len} {incr k} {
       append pp " [lindex $profilspc(pixels) $k]"
       append yy " [lindex $intensites $k]"
       #-- Gestion des valeurs "nan" de l'intensite
       # set valy [lindex $profilspc(intensite) $k]
       #if { $valy == "nan" } {
       #   append yy " 0"
       # } else {
       #   append yy " $valy"
       #}
       incr kk         
   }
   #::console::affiche_resultat "$pp\n"
   blt::vector create vx($len)
   blt::vector create vy($len)

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

   #vy set $yy
   #vy set $intensites
   #::console::affiche_resultat "$intensites\n"
   for {set i 0} {$i<$len} {incr i} { 
       set vy($i) [ lindex $intensites $i ]
   }
   

   #--- Préparation de l'affichage du graphe :
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

   #-- Meth 1 :
   #set tmp_i [ lsort -real -decreasing $intensites ]
   #set imax [ lindex $tmp_i 0 ]
   ##set echelley [expr $i_max/5]
   ## Petit bug ICI
   #set echelley [ expr 10*int($imax/($div_y*10)) ]
   #.spc.g axis configure y -stepsize $echelley

   #-- Meth 2 :
   #set echelley [ expr 10*int($vy(max)/($div_y*10)) ]
   #-- Meth 3 :
   set echelley [ expr 10*int(($vy(max)-$vy(min)/($div_y*10))) ]
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




