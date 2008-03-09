
# Proc�dures li�es � 'linterface graphique et au trac� des profils de raies.

# Mise a jour $Id: spc_gui.tcl,v 1.18 2008-03-09 21:10:45 bmauclaire Exp $



proc spc_winini { } {

############################################################################
# Initialise la fen�tre de visualisation des profils
############################################################################
   global profilspc
   global printernames
   global caption
   global colorspc
   global spcaudace

   # === On cree une nouvelle fenetre ===
   wm withdraw .
   if {[info command .spc] == "" } {
      toplevel .spc -class Toplevel
   }
   # wm title .spc "$caption(spcaudace,gui,main_title) - $profilspc(initialfile)"
   wm title .spc "$caption(spcaudace,gui,main_title) $spcaudace(version)"
   #wm geometry .spc 640x480+0+100
   #wm geometry .spc 640x513+0-68
   wm geometry .spc 680x513+0-68
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
      menu .spc.menuBar -tearoff 0 -bg $colorspc(backmenu)
      .spc.menuBar add cascade -menu .spc.menuBar.file -label $caption(spcaudace,gui,file) -underline 0
      menu .spc.menuBar.file -tearoff 0 -bg $colorspc(backmenu)
      .spc.menuBar.file add command -label $caption(spcaudace,gui,loadspcfit) -command "spc_loadfit" -underline 0 -accelerator "Ctrl-O"
      .spc.menuBar.file add command -label $caption(spcaudace,gui,loadspctxt) -command "spc_loaddat" -underline 0 -accelerator "Ctrl-T"
      #.spc.menuBar.file add command -label $caption(spcaudace,gui,spc_load) -command "spc_load" -underline 0 -accelerator "Ctrl-O"
      .spc.menuBar.file add command -label $caption(spcaudace,gui,gloadmore) -command "spc_loadmore" -underline 0 -accelerator "Ctrl-E"
      .spc.menuBar.file add command -label $caption(spcaudace,gui,gdelete) -command "spc_gdelete" -underline 0 -accelerator "Ctrl-K"
      .spc.menuBar.file add command -label $caption(spcaudace,gui,gdeleteall) -command "spc_gdeleteall" -underline 0 -accelerator "Ctrl-D"
      .spc.menuBar.file add command -label $caption(spcaudace,gui,spc_file_space)
      .spc.menuBar.file add command -label $caption(spcaudace,gui,spc_repconf) -command { ::cwdWindow::run "$audace(base).cwdWindow" } -underline 0
      .spc.menuBar.file add command -label $caption(spcaudace,gui,spc_file_space)
      .spc.menuBar.file add command -label $caption(spcaudace,gui,spc_simbad) -command "spc_simbad" -underline 0
      .spc.menuBar.file add command -label $caption(spcaudace,gui,spc_bess) -command "spc_bess" -underline 0
      .spc.menuBar.file add command -label $caption(spcaudace,gui,spc_uves) -command "spc_uves" -underline 0
      .spc.menuBar.file add command -label $caption(spcaudace,gui,spc_file_space)
      if {$nbprinters>0} {
         for {set k 0} {$k<$nbprinters} {incr k} {
	     # .spc.menuBar.file add command -label "$caption(spcaudace,gui,print_on) [lindex $printernames $k]" -command "spc_print $k" -underline 0 -accelerator "Ctrl-P" -state disabled
	     .spc.menuBar.file add command -label "$caption(spcaudace,gui,print_on) [lindex $printernames $k]" -command "spc_print $k" -underline 0 -accelerator "Ctrl-P"
         }
      }

      .spc.menuBar.file add command -label $caption(spcaudace,gui,quitspc) -command "destroy .spc" -underline 0 -accelerator "Ctrl-Q"
      .spc configure -menu .spc.menuBar
      #-- Raccourcis calviers :
      bind .spc <Control-O> spc_loadfit
      bind .spc <Control-T> spc_loaddat
      bind .spc <Control-E> spc_loadmore
      bind .spc <Control-K> spc_gdelete
      bind .spc <Control-D> spc_gdeleteall
      bind .spc <Control-P> spc_print
      bind .spc <Control-L> spc_postscript
      bind .spc <Control-Q> { destroy .spc }
      bind .spc <Control-o> spc_loadfit
      bind .spc <Control-t> spc_loaddat
      bind .spc <Control-e> spc_loadmore
      bind .spc <Control-k> spc_gdelete
      bind .spc <Control-d> spc_gdeleteall
      bind .spc <Control-p> spc_print
      bind .spc <Control-l> spc_postscript
      bind .spc <Control-q> { destroy .spc }
      #bind .spc <F1> aboutBox


      #--- Menu Conversions ---#
      .spc.menuBar add cascade -menu .spc.menuBar.conv -label $caption(spcaudace,gui,conv) -underline 0
      menu .spc.menuBar.conv -tearoff 0 -bg $colorspc(backmenu)
      .spc.menuBar.conv add command -label $caption(spcaudace,gui,spc_spc2png_w) -command "spc_export2png" -underline 0
      .spc.menuBar.conv add command -label $caption(spcaudace,gui,spc_spc2png2_w) -command "spc_fit2pngopt" -underline 0
      # .spc.menuBar.conv add command -label $caption(spcaudace,gui,writeps) -command "spc_postscript" -underline 0
      .spc.menuBar.conv add command -label $caption(spcaudace,gui,writegif) -command "spc_scgif" -underline 0
      .spc.menuBar.conv add command -label $caption(spcaudace,gui,spc_fit2ps) -command "spc_fit2ps" -underline 0
      .spc.menuBar.conv add command -label $caption(spcaudace,gui,spc_file_space)
      .spc.menuBar.conv add command -label $caption(spcaudace,gui,spc_fits2dat_w) -command "spc_fits2dat" -underline 0
      .spc.menuBar.conv add command -label $caption(spcaudace,gui,spc_file_space)
      .spc.menuBar.conv add command -label $caption(spcaudace,gui,spc_dat2fits_w) -command "spc_dat2fits" -underline 0
      .spc.menuBar.conv add command -label $caption(spcaudace,gui,spc_spc2fits_w) -command "spc_spc2fits" -underline 0
      .spc.menuBar.conv add command -label $caption(spcaudace,gui,spc_spcs2fits_w) -command "spc_spcs2fits" -underline 0
      .spc.menuBar.conv add command -label $caption(spcaudace,gui,spc_file_space)
      .spc.menuBar.conv add command -label $caption(spcaudace,gui,spc_bessmodule_w) -command "spc_bessmodule" -underline 0


      #--- Menu G�om�trie ---#
      .spc.menuBar add cascade -menu .spc.menuBar.geometrie -label $caption(spcaudace,gui,spc_geometrie) -underline 0 -background $colorspc(backmenu)
      menu .spc.menuBar.geometrie -tearoff 0 -background $colorspc(backmenu)
      # .spc configure -menu .spc.menuBar
      .spc.menuBar.geometrie add command -label $caption(spcaudace,gui,spc_pretraitementfc_w) -command "spc_pretraitementfc_w" -underline 0
      .spc.menuBar.geometrie add command -label $caption(spcaudace,gui,spc_pretrait) -command "spc_pretrait" -underline 0
      .spc.menuBar.geometrie add command -label $caption(spcaudace,gui,spc_register_w) -command "spc_register" -underline 0
      .spc.menuBar.geometrie add command -label $caption(spcaudace,gui,spc_rot180_w) -command "spc_flip" -underline 0
      .spc.menuBar.geometrie add command -label $caption(spcaudace,gui,spc_tiltauto_w) -command "spc_tiltauto" -underline 0
      .spc.menuBar.geometrie add command -label $caption(spcaudace,gui,spc_tilt_w) -command "spc_tilt" -underline 0
      .spc.menuBar.geometrie add command -label $caption(spcaudace,gui,spc_slant_w) -command "spc_slant" -underline 0
      .spc.menuBar.geometrie add command -label $caption(spcaudace,gui,spc_smilex_w) -command "spc_smilex" -underline 0
      .spc.menuBar.geometrie add command -label $caption(spcaudace,gui,spc_smiley_w) -command "spc_smiley" -underline 0
      .spc.menuBar.geometrie add command -label $caption(spcaudace,gui,spc_findtilt) -command "spc_findtilt" -underline 0
      .spc.menuBar.geometrie add command -label $caption(spcaudace,gui,spc_tilt2) -command "spc_tilt2" -underline 0


      #--- Menu Profil de raies ---#
      .spc.menuBar add cascade -menu .spc.menuBar.profil -label $caption(spcaudace,gui,spc_profil) -underline 0 -background $colorspc(backmenu)
      menu .spc.menuBar.profil -tearoff 0 -background $colorspc(backmenu)
      # .spc.menuBar.profil add command -label $caption(spcaudace,gui,spc_open_fitfile) -command "open_fitfile" -underline 0 -accelerator "Ctrl-n"
      .spc.menuBar.profil add command -label $caption(spcaudace,gui,spc_profil_w) -command "spc_profil" -underline 0
      .spc.menuBar.profil add command -label $caption(spcaudace,gui,spc_traitea_w) -command "spc_traitea" -underline 0
      .spc.menuBar.profil add command -label $caption(spcaudace,gui,spc_extract_zone_w) -command "spc_extract_profil_zone" -underline 0
      #.spc.menuBar.profil add command -label $caption(spcaudace,gui,spc_extract_zone_w) -command "spc_profil_zone" -underline 0
      #.spc.menuBar.profil add command -label $caption(spcaudace,gui,spc_extract_zone_w) -command "spc_profil_zone" -underline 0
      .spc.menuBar.profil add command -label $caption(spcaudace,gui,spc_smooth) -command "spc_smooth" -underline 0
      .spc.menuBar.profil add command -label $caption(spcaudace,gui,spc_smooth2) -command "spc_smooth2" -underline 0
      .spc.menuBar.profil add command -label $caption(spcaudace,gui,spc_div) -command "spc_div" -underline 0
      .spc configure -menu .spc.menuBar
      #-- Raccourcis calviers :
      #bind .spc <Control-N> spc_open_fitfile
      #bind .spc <Control-n> spc_open_fitfile


      #--- Menu Mesures ---#
      .spc.menuBar add cascade -menu .spc.menuBar.mesures -label $caption(spcaudace,gui,spc_mesures) -underline 0 -background $colorspc(backmenu)
      menu .spc.menuBar.mesures -tearoff 0 -background $colorspc(backmenu)
      # .spc configure -menu .spc.menuBar
      .spc.menuBar.mesures add command -label $caption(spcaudace,gui,spc_centergrav_w) -command "spc_centergrav" -underline 0
      .spc.menuBar.mesures add command -label $caption(spcaudace,gui,spc_centergauss_w) -command "spc_centergauss" -underline 0
      .spc.menuBar.mesures add command -label $caption(spcaudace,gui,spc_fwhm_w) -command "spc_fwhm" -underline 0
      .spc.menuBar.mesures add command -label $caption(spcaudace,gui,spc_ew_w) -command "spc_autoew" -underline 0
      .spc.menuBar.mesures add command -label $caption(spcaudace,gui,spc_intensity_w) -command "spc_intensity" -underline 0
      .spc.menuBar.mesures add command -label $caption(spcaudace,gui,spc_imax) -command "spc_imax" -underline 0
      .spc.menuBar.mesures add command -label $caption(spcaudace,gui,spc_icontinuum) -command "spc_icontinuum" -underline 0
      .spc.menuBar.mesures add command -label $caption(spcaudace,gui,spc_snr) -command "spc_snr" -underline 0


      #--- Menu Calibration ---#
      .spc.menuBar add cascade -menu .spc.menuBar.calibration -label $caption(spcaudace,gui,spc_calibration) -underline 0 -background $colorspc(backmenu)
      menu .spc.menuBar.calibration -tearoff 0 -background $colorspc(backmenu)
      # .spc.menuBar.calibration add command -label $caption(spcaudace,gui,cali_lambda) -command "cali_lambda" -underline 0 -accelerator "Ctrl-L"
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_loadneon) -command "spc_loadneon" -underline 0
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_calibre2file_w) -command "spc_calibre" -underline 0 -accelerator "Ctrl-L"
      #.spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_calibre2file_w) -command "spc_calibre2file_w" -underline 0 -accelerator "Ctrl-L"
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_calibre2loifile_w) -command "spc_calibre2loifile_w" -underline 0 -accelerator "Ctrl-M"
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_calibredecal) -command "spc_calibredecal" -underline 0
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_linearcal) -command "spc_linearcal" -underline 0
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_corrvhelio) -command "spc_corrvhelio" -underline 0
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_calibre_space)
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_calibretelluric) -command "spc_calibretelluric" -underline 0 -accelerator "Ctrl-T"
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_calobilan) -command "spc_calobilan" -underline 0 -accelerator "Ctrl-B"
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_caloverif) -command "spc_caloverif" -underline 0 -accelerator "Ctrl-V"
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_loadh2o) -command "spc_loadh2o" -underline 0
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_calibre_space)
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_rinstrum_w) -command "spc_rinstrum" -underline 0
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_rinstrumcorr_w) -command "spc_rinstrumcorr" -underline 0 -accelerator "Ctrl-I"
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_calibre_space)
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_norma_w) -command "spc_autonorma" -underline 0
      .spc.menuBar.calibration add command -label $caption(spcaudace,gui,spc_divri) -command "spc_divri" -underline 0
      .spc configure -menu .spc.menuBar
      #-- Raccourcis calviers :
      bind .spc <Control-L> cali_lambda
      bind .spc <Control-l> cali_lambda
      bind .spc <Control-F> cali_flux
      bind .spc <Control-f> cali_flux
      bind .spc <Control-t> spc_calibretelluric
      bind .spc <Control-b> spc_calobilan
      bind .spc <Control-v> spc_caloverif

      #--- Menu Pipelines ---#
      .spc.menuBar add cascade -menu .spc.menuBar.pipelines -label $caption(spcaudace,gui,spc_pipelines) -underline 0 -background $colorspc(backmenu)
      menu .spc.menuBar.pipelines -tearoff 0 -background $colorspc(backmenu)
      # .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_geom2calibre_w) -command "spc_geom2calibre_w" -underline 0 -accelerator "Ctrl-1"
      .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_traite2rinstrum_w) -command "::param_spc_audace_traite2rinstrum::run" -underline 0 -accelerator "Ctrl-i"
      .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_traitestellaire) -command "::param_spc_audace_traitestellaire::run" -underline 0 -accelerator "Ctrl-s"
      .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_traitenebula) -command "::param_spc_audace_traitenebula::run" -underline 0 -accelerator "Ctrl-n"
      .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_pipelines_space)
      .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_lampe2calibre_w) -command "::param_spc_audace_lampe2calibre::run" -underline 0 -accelerator "Ctrl-c"
      .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_traite2srinstrum_w) -command "::param_spc_audace_traite2srinstrum::run" -underline 0 -accelerator "Ctrl-a"
      .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_pipelines_space)
      .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_traite2scalibre_w) -command "::param_spc_audace_traite2scalibre::run" -underline 0 -accelerator "Ctrl-t-c"
      .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_pipelines_space)
      # .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_traitesimple2calibre_w) -command "::param_spc_audace_traitesimple2calibre::run" -underline 0 -accelerator "Ctrl-0"
      # .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_traitesimple2rinstrum_w) -command "::param_spc_audace_traitesimple2rinstrum::run" -underline 0 -accelerator "Ctrl-1"
      .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_geom2calibre_w) -command "::param_spc_audace_geom2calibre::run" -underline 0 -accelerator "Ctrl-g-c"
      .spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_geom2rinstrum_w) -command "::param_spc_audace_geom2rinstrum::run" -underline 0 -accelerator "Ctrl-g-a"
      #.spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_pipelines_space)
      #.spc.menuBar.pipelines add command -label $caption(spcaudace,gui,spc_specLhIII_w) -command "::spbmfc::fenetreSpData" -underline 0 -accelerator "Ctrl-8"
      .spc configure -menu .spc.menuBar
      #-- Raccourcis calviers :
      bind .spc <Control-i> ::param_spc_audace_traite2rinstrum::run
      bind .spc <Control-v> ::param_spc_audace_lampe2calibre::run
      bind .spc <Control-a> ::param_spc_audace_traite2srinstrum::run
      bind .spc <Control-s> ::param_spc_audace_traitestellaire::run
      bind .spc <Control-n> ::param_spc_audace_traitenebula::run
      #bind .spc <Control-t-c> ::param_spc_audace_traite2scalibre::run
      #bind .spc <Control-g-c> ::param_spc_audace_geom2calibre::run
      #bind .spc <Control-g-a> ::param_spc_audace_geom2rinstrum::run
      #bind .spc <Control-7> ::spcmfc::Demarragespbmfc

      #--- Menu Astrophysique ---#
      .spc.menuBar add cascade -menu .spc.menuBar.analyse -label $caption(spcaudace,gui,spc_analyse) -underline 0 -background $colorspc(backmenu)
      menu .spc.menuBar.analyse -tearoff 0 -background $colorspc(backmenu)
      #.spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_chimie) -command "spc_chimie" -underline 0 -accelerator "Ctrl-A"
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_surveys) -command "spc_surveys" -underline 0
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_bebuil) -command "spc_bebuil" -underline 0
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_file_space)
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_vradiale_w) -command "spc_vradiale" -underline 0
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_vhelio) -command "spc_vhelio" -underline 0
      #.spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_vexp_w) -command "spc_vexp" -underline 0
      #.spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_vrot_w) -command "spc_vrot" -underline 0
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_file_space)
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_ew_w) -command "spc_autoew" -underline 0
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_ewcourbe_w) -command "spc_ewcourbe" -underline 0
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_ewdirw) -command "spc_ewdirw" -underline 0
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_file_space)
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_te) -command "spc_te" -underline 0 -accelerator "Ctrl-T"
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_ne) -command "spc_ne" -underline 0 -accelerator "Ctrl-N-E"
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_npte_w) -command "spc_npte" -underline 0
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_npne_w) -command "spc_npne" -underline 0
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_normahbeta) -command "spc_normahbeta" -underline 0
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_file_space)
      .spc.menuBar.analyse add command -label $caption(spcaudace,gui,spc_spectrum) -command "spc_spectrum" -underline 0
      .spc configure -menu .spc.menuBar
      #-- Raccourcis calviers :
      bind .spc <Control-A> mes_especes
      bind .spc <Control-a> mes_especes
      #bind .spc <Control-T> spc_npte
      #bind .spc <Control-t> spc_npte
      #bind .spc <Control-N-E> spc_npne
      #bind .spc <Control-n-e> spc_npne


      #--- Menu � propos/Aide ---#
      .spc.menuBar add cascade -menu .spc.menuBar.aide -label $caption(spcaudace,gui,spc_aide) -underline 0 -background $colorspc(backmenu)
      menu .spc.menuBar.aide -tearoff 0 -background $colorspc(backmenu)
      # .spc.menuBar.aide add command -label $caption(spcaudace,gui,spc_version_w) -command "spc_version" -underline 0
      .spc.menuBar.aide add command -label $caption(spcaudace,gui,spc_version_w)
      .spc.menuBar.aide add command -label $caption(spcaudace,gui,spc_help) -command "spc_help"
      .spc.menuBar.aide add command -label $caption(spcaudace,gui,spc_site) -command "spc_webpage"
      .spc.menuBar.aide add command -label $caption(spcaudace,gui,spc_about_w)
      .spc.menuBar.aide add command -label $caption(spcaudace,gui,spc_contrib_w)
      .spc configure -menu .spc.menuBar
      #bind .spc <Control-A> spc_about_w

      #--- Fen�tre de graphe BLT ---#
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
#*********************************************************************************#



################################################                                           # Ouverture d'un fichier fit
# ---------------------------------------------
# Auteur : Alain KLOTZ
# Date de creation : 17-08-2003
# Modification : Benjamin Mauclaire
# Date de mise � jour : 25-02-2005
# Argument : fichier fits du spectre spatial
################################################


proc open_fitfile { {filenamespc_spatial ""} } {
	## Chargement : source $audace(rep_scripts)/profil_raie.tcl
	## Les var nommees audace_* sont globales
	global audace
        global caption
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
      ## set filenamespc [tk_getOpenFile -title $caption(spcaudace,gui,loadspc) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" {.spc}]] -initialdir $idir -initialfile $ifile ]
      #set filenamespc_spatial [tk_getOpenFile -title $caption(spcaudace,gui,open_fitfile) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" {.fit}]] -initialdir $idir -initialfile $ifile ]
#--- Debut modif Robert
      set filenamespc_spacial [tk_getOpenFile -title "$caption(spcaudace,gui,spc_open_fitfile)" -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ]
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
#*********************************************************************************#



proc pvisutools {} {
############################################################################
# Outils d'affichage
############################################################################
   global profilspc
   global caption
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






#########################################################
# Superpose un profil suppl�mentaire dans la fen�tre d'affichage de SpcAudace
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 19-09-2007
# Date de mise � jour : 19-09-2007
# Arguments : profil_raies_fits ?color?
##########################################################

proc spc_loadmore { args } {
    global profilspc spcaudace conf caption audace

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
	if { $nbargs == 1 } {
	    set rep_et_filename [ lindex $args 0 ]
	    set filename [ file rootname [ file tail $rep_et_filename ] ]
	    set lineColor [ lindex $spcaudace(lgcolors) [ spc_setgcolor ] ]
	    regsub -all {[^a-z0-9]} "$filename" "" lineName
	    set filedir [ file dirname $rep_et_filename ]
	    if { $filedir == "." } {
		set filedir "$audace(rep_images)"
	    }
	} elseif { $nbargs == 2 } {
	    set rep_et_filename [ lindex $args 0 ]
	    set filename [ file rootname [ file tail $rep_et_filename ] ]
	    set lineColor [ lindex $args 1 ]
	    regsub -all {[^a-z0-9]} "$filename" "" lineName
	    set filedir [ file dirname $rep_et_filename ]
	    if { $filedir == "." } {
		set filedir "$audace(rep_images)"
	    }
	} elseif { $nbargs == 0 } {
	    if {[info exists profilspc(initialdir)] == 1} {
		set idir "$profilspc(initialdir)"
	    }
	    if {[info exists profilspc(initialfile)] == 1} {
		set ifile "$profilspc(initialfile)"
	    }
	    set rep_et_filename [ tk_getOpenFile -title $caption(spcaudace,gui,loadspcfit) -filetypes [list [list "$caption(spcaudace,gui,spc_profile)" [ list $conf(extension,defaut) ] ]] -initialdir $idir -initialfile $ifile ]
	    if {[ string compare $rep_et_filename "" ] == 0 } {
		return 0
	    } else {
		set filename [ file rootname [ file tail "$rep_et_filename" ] ]
		set filedir [ file dirname "$rep_et_filename" ]
		set profilspc(initialdir) "$filedir"
		set lineColor [ lindex $spcaudace(lgcolors) [ spc_setgcolor ] ]
		regsub -all {[^a-z0-9]} "$filename" "" lineName
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_loadmore profil_raies_fits ?color (green, red,...)?\n\n"
	    return ""
	}

	#--- G�n�re la liste lambda, intensit�s :
	#if { "${filedir}/" != "$audace(rep_images)" }
	set flag_notpresent 0
	if { [ catch { glob -dir $audace(rep_images) -tails $filename$conf(extension,defaut) } ] } {
	    file copy -force "$filedir/$filename$conf(extension,defaut)" "$audace(rep_images)/$filename$conf(extension,defaut)"
	    set flag_notpresent 1
	}
	set spectre_data [ spc_fits2data "$filename" ]
	#if { "${filedir}/" != "$audace(rep_images)" } 
	if { $flag_notpresent } {
	    file delete -force "$audace(rep_images)/$filename$conf(extension,defaut)"
	}
	set xlist [ lindex $spectre_data 0 ]
	set ylist [ lindex $spectre_data 1 ]
	set ymax [ lindex [ lsort -decreasing -real $ylist ] 0 ]
	set ymin [ lindex [ lsort -increasing -real $ylist ] 0 ]

	#--- Cr�ee les vecteurs BLT � tracer :
	set len [ llength $xlist ]
	blt::vector create gx$lineName
	blt::vector create gy$lineName
	
	#--- je copie les listes dans les vecteurs :
	gx$lineName set $xlist
	gy$lineName set $ylist
	
	#--- si la courbe existe deja, je la supprime :
	if { [ .spc.g element exists $lineName ] } {
	    .spc.g element delete $lineName
	}

	#--- je dessine la courbe :
	if { [ llength $spcaudace(gloaded) ] == 0 } {
	    .spc.g configure -title "$filename"
	    .spc.g axis configure x2 -min [lindex $xlist 0] -max [ lindex $xlist [ expr $len-1 ] ]
	    .spc.g axis configure y2 -min $ymin -max $ymax
	    .spc.g axis configure x -min [lindex $xlist 0] -max [ lindex $xlist [ expr $len-1 ] ]
	    .spc.g axis configure y -min $ymin -max $ymax
	}
	.spc.g element create $lineName -symbol none -xdata gx$lineName -ydata gy$lineName -smooth natural -color $lineColor

	#--- Traitement du r�sultat :
	::console::affiche_resultat "Nom du profil affich� de couleur $lineColor : $lineName\n Nom � utiliser avec spc_gdelete.\n"
	lappend spcaudace(gloaded) "$lineName"
	return "$lineName"
    } else {
	::console::affiche_erreur "Usage: spc_loadmore profil_raies_fits ?color (green, red,...)?\n\n"
    }
}
#****************************************************************#



#########################################################
# Efface de l'affichage un profil 
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 19-09-2007
# Date de mise � jour : 19-09-2007
# Arguments : nom_profil_raies
##########################################################

proc spc_gdelete { args } {
    global profilspc spcaudace

    if { [ llength $args ] == 1 } {
	set nom_profil [ lindex $args 0 ]

	#--- si la courbe existe deja, je la supprime :
	if { [ .spc.g element exists $nom_profil ] } {
	    .spc.g element delete $nom_profil
	    #-- G�re � d�faut, les couleurs comme une lifo : PAS TOP
	    # set spcaudace(gcolor) [ expr $spcaudace(gcolor)-1 ]
	    if { $spcaudace(gcolor) < 0 } {
		set spcaudace(gcolor) 0
	    }
	} else {
	    ::console::affiche_resultat "Ce profil ne correspond � aucun nom de profil trac�.\n"
	}
    } else {
	::console::affiche_erreur "Usage: spc_gdelete nom_profil_raies\n\n"
    }
}
#****************************************************************#


###############################################################################
# Proc�dure de l'attribution automatique de la coulr des graphes
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation :  22-09-2007
# Date de mise � jour : 22-09-2007
################################################################################

proc spc_setgcolor {} {

    global spcaudace
    set nbcolors [ expr [ llength $spcaudace(lgcolors) ]-1 ]

    if { [ llength $spcaudace(gloaded) ] == 0 } {
	set spcaudace(gcolor) 0
	return $spcaudace(gcolor)
    } else {
	if { $spcaudace(gcolor) < $nbcolors } { 
	    set spcaudace(gcolor) [ expr $spcaudace(gcolor) + 1 ]
	    return $spcaudace(gcolor)
	} else {
	    #-- Couleur s�lectionn�e est la premi�re :
	    set spcaudace(gcolor) 0
	    return $spcaudace(gcolor)
	}
    }
}
#*********************************************************#



#########################################################
# Efface tous les profils de l'affichage
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 21-09-2007
# Date de mise � jour : 21-09-2007
# Arguments : AUCUN
##########################################################


proc spc_gdeleteall { args } {
    global profilspc spcaudace

    if { [ llength $args ] == 0 } {
	#--- Si aucune courbe trac�e, ne fait rien :
	if { [ llength $spcaudace(gloaded) ] ==  0 } {
	    return ""
	}
	set nb_profils 0
	foreach nom_profil $spcaudace(gloaded) {
	    if { [ .spc.g element exists $nom_profil ] } {
		.spc.g element delete $nom_profil
		#set spcaudace(gcolor) [ expr $spcaudace(gcolor)-1 ]
		if { $spcaudace(gcolor) < 0 } {
		    set spcaudace(gcolor) 0
		}
		incr nb_profils
	    } else {
		::console::affiche_resultat "Ce profil ne correspond � aucun nom de profil trac�.\n"
	    }
	}
	set spcaudace(gcolor) 0
	set spcaudace(gloaded) [ list ]
	.spc.g configure -title ""
	::console::affiche_resultat "$nb_profils profil(s) effac�(s).\n"
	return $nb_profils
    } else {
	::console::affiche_erreur "Usage: spc_gdeleteall\n\n"
    }
}
#****************************************************************#



############################################################################
# Charge un profil au format .spc et l'affiche dans la fenetre
#
# Date de creation : ? Alain Klotz
# Date de modification : 18-02-2005 Benjamin Mauclaire
############################################################################

proc pvisu { } {

   global profilspc
   global printernames
   global caption
   global colorspc
   global audace spcaudace

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
      .spc.g axis configure x -title $caption(spcaudace,gui,pixel)
      set profilspc(xunit) $caption(spcaudace,gui,pixel)
   } else {
      .spc.g axis configure x -title $caption(spcaudace,gui,angstroms)
      set profilspc(xunit) $caption(spcaudace,gui,angstrom)
   }

   #--- Affichage du graphique :
   .spc.g configure -title $profilspc(object)
   .spc.g axis configure y -title $caption(spcaudace,gui,intensity)
   set profilspc(yunit) $caption(spcaudace,gui,adu)
   if { [ .spc.g element exists "line1" ] } {
       .spc.g element delete line1
   }
   #-- Ajoute � la liste des profils trac�s le profil charg� avec spc_load (pvisu) s'appelle line1 :

   #-- Trace le profil :
   .spc.g element create line1 -symbol none -xdata vx -ydata vy -smooth natural
   if { [ llength $spcaudace(gloaded) ] == 0 } {
       .spc.g element configure line1 -color $colorspc(profile)
       lappend spcaudace(gloaded) "line1"
   } elseif { [ llength $spcaudace(gloaded) ] == 1 && [ lindex $spcaudace(gloaded) 0 ] == "line1" } {
       .spc.g element configure line1 -color $colorspc(profile)
   } else {
       #-- Future gestions de plusieurs profils affich�s ici ?
       # .spc.g element configure line1 -color [ lindex $spcaudace(lgcolors) [ spc_setgcolor ] ]
       .spc.g element configure line1 -color $colorspc(profile)

   }
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
   global caption
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
      .spc.g axis configure x -title $caption(spcaudace,gui,pixel)
      set profilspc(xunit) $caption(spcaudace,gui,pixel)
   } else {
      vx set $pp
      .spc.g axis configure x -title $caption(spcaudace,gui,angstroms)
      set profilspc(xunit) $caption(spcaudace,gui,angstroms)
   }

   .spc.g axis configure y -title $caption(spcaudace,gui,intensity)
   set profilspc(yunit) $caption(spcaudace,gui,adu)
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
   global caption
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
      .spc.g axis configure x -title $caption(spcaudace,gui,pixel)
      set profilspc(xunit) $caption(spcaudace,gui,pixel)
   } else {
      vx set $pp
      .spc.g axis configure x -title $caption(spcaudace,gui,angstroms)
      set profilspc(xunit) $caption(spcaudace,gui,angstroms)
   }

   #vy set $yy
   #vy set $intensites
   #::console::affiche_resultat "$intensites\n"
   for {set i 0} {$i<$len} {incr i} {
       set vy($i) [ lindex $intensites $i ]
   }


   #--- Pr�paration de l'affichage du graphe :
   .spc.g axis configure y -title $caption(spcaudace,gui,intensity)
   set profilspc(yunit) $caption(spcaudace,gui,adu)
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
#*********************************************************************************#

proc spc_Unzoom { graph } {
   $graph axis configure x y -min {} -max {}
}
#*********************************************************************************#

proc spc_RegionStart { graph x y } {
   global x0 y0
   set x [$graph axis invtransform x $x]
   set y [$graph axis invtransform y $y]
   $graph marker create line -coords {} -name myLine \
      -dashes dash -xor yes
   set x0 $x ; set y0 $y
}
#*********************************************************************************#

proc spc_RegionMotion { graph x y } {
   global x0 y0
   set x [$graph axis invtransform x $x]
   set y [$graph axis invtransform y $y]
   $graph marker configure myLine -coords \
      "$x0 $y0 $x0 $y $x $y $x $y0 $x0 $y0"
}
#*********************************************************************************#

proc spc_RegionEnd { graph x y } {
   global x0 y0
   $graph marker delete myLine
   set x [$graph axis invtransform x $x]
   set y [$graph axis invtransform y $y]
   spc_Zoom $graph $x0 $y0 $x $y
}
#*********************************************************************************#


proc spc_print { k } {
   global printernames
   global caption
   global colorspc
   set k 0
   set printername [lindex $printernames $k]
   # blt::printer -> invalid command name
   set pid [blt::printer open "$printername"]
   .spc.frame1.label1 configure -text "$caption(print_on) $printername (pid=$pid)"
   .spc.g print2 $pid
   printer close $pid
}
#*********************************************************************************#


proc spc_postscript {} {
   global profilspc
   global caption
   global colorspc

   #.spc.g element configure line1 -linewidth 1
   .spc.g postscript configure -landscape yes -maxpect yes -decorations no
   set ind [string last . $profilspc(initialfile)]
   if {$ind==-1} { set ind end }
   set filename "$profilspc(initialdir)/screenshot.ps"
   #append filename [string range $profilspc(initialfile) 0 $ind]
   #append filename "ps"
   .spc.frame1.label1 configure -text "Post Script : $filename"
   #.spc.g postscript output $filename.ps
   .spc.g postscript output $filename
   ::console::affiche_resultat "Capture d'�cran postscript sauv�e sous $filename\n"
}
#*********************************************************************************#


proc spc_scgif {} {
   global audace conf

   set image [ image create photo ]
   .spc.g snap $image
   set filename "$audace(rep_images)/screenshot.gif"
   $image write $audace(rep_images)/screenshot.gif -format GIF
   ::console::affiche_resultat "Capture d'�cran sauv�e sous $filename\n"
}
#*********************************************************************************#


#---- D�marre l'interface grphisque -----------#
spc_winini




