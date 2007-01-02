# Création : 2003
# Modification : 08/12/2005

#--- definition of captions
#--- definition des legendes
if {[string compare $langage english] ==0 } {
     set captionspc(main_title) "SpcAud'ACE : spectrum analyser"
     set captionspc(acq) "CCD Acquisition"
     set captionspc(open_fitfile) "Create a ray profile"
     set captionspc(loadspcfit) "Load a fits ray profile"
     set captionspc(loadspctxt) "Load a text ray profile"
     set captionspc(savespc) "Save a ray profile"
     set captionspc(pixel) "Position (pixel)"
     set captionspc(angstrom) "Angstrom"
     set captionspc(angstroms) "Wavalenght (Angstrom)"
     set captionspc(intensity) "Intensity (ADU)"
     set captionspc(adu) "ADU"
     set captionspc(spc_profile) "SPC profile"
     set captionspc(writeps) "Export to Postscript"
     set captionspc(file) "File"
     set captionspc(print_on) "Print with "
     set captionspc(parcourir) "...."


     set captionspc(spc_bessmodule_w) "File exportation to BeSS format"
     #--- Menu Profil de raies ---#


     #--- Menu Calibration ---#
     set captionspc(calibration) "Calibration"
     set captionspc(cali_lambda) "Wavelength calibration"
     set captionspc(cali_flux) "Flux calibration"

     #--- Menu Mesures ---#
     set captionspc(mesures) "Measures"
     set captionspc(mes_especes) "Atomic speces finding"
     set captionspc(mes_TE) "Electronic temperature"
     set captionspc(mes_DE) "Electronique density"

     set captionspc(wait) "Wait..."
     set captionspc(quitspc) "Quit SpcAudace workspace"
}


if {[string compare $langage french] ==0 } {
     set captionspc(main_title) "SpcAud'ACE : analyseur de spectres"
     set captionspc(acq) "Acquisition CCD"
     #--- Divers ---#
     set captionspc(pixel) "Position (pixel)"
     set captionspc(angstrom) "Angstrom"
     set captionspc(angstroms) "Longueur d'onde (Angstrom)"
     set captionspc(intensity) "Intensité (ADU)"
     set captionspc(adu) "ADU"
     set captionspc(spc_profile) "profil SPC"
     set captionspc(wait) "En cours..."
     set captionspc(parcourir) "...."
     #set captionspc(savespc) "Sauver un profil de raie"

     #--- Menu File ---#
     set captionspc(file) "Fichier"
     set captionspc(loadspcfit) "Charger un profil de raie fits"
     set captionspc(loadspctxt) "Charger un profil de raie dat"
     set captionspc(spc_spc2png_w) "Exporter un profil en image png"
     set captionspc(spc_spc2png2_w) "Exporter un profil en image png (réglages fins)"
     set captionspc(writeps) "Exporter un profil en postscript"
     set captionspc(spc_fits2dat_w) "Conversion de profil fits vers dat"
     set captionspc(spc_dat2fits_w) "Conversion de profil dat vers fits"
     set captionspc(spc_spc2fits_w) "Conversion de profil spc vers fits"
     set captionspc(spc_spcs2fits_w) "Conversion d'un répertoire de profils spc vers fits"
     set captionspc(spc_bessmodule_w) "Export de fichier au format base BeSS"
     set captionspc(print_on) "Imprimer avec "
     set captionspc(quitspc) "Quitter la fenêtre SpcAudace"

     #--- Menu Géométrie ---#
     set captionspc(spc_geometrie) "Géométrie"
     set captionspc(spc_pretraitementfc_w) "Prétraitement de spectres 2D"
     set captionspc(spc_register_w) "Appariement d'une série de spectres 2D"
     set captionspc(spc_rot180_w) "Rotation de 180° (2D/1D)"
     set captionspc(spc_tiltauto_w) "Rotation automatique (2D)"
     set captionspc(spc_tilt_w) "Rotation manuelle"
     set captionspc(spc_slant_w) "Correction du slant (2D)"
     set captionspc(spc_smilex_w) "Correction du smile d'axe X (2D)"
     set captionspc(spc_smiley_w) "Correction du smile d'axe Y (2D)"

     #--- Menu Profil de raies ---#
     set captionspc(spc_profil) "Profil de raies"
     set captionspc(spc_profil_w) "Créer le profil automatique d'un spectre"
     set captionspc(spc_traitea_w) "Prétraitement d'une série et profil automatique"
     set captionspc(spc_extract_zone_w) "Créer un profil à partir d'une zone"

     #--- Menu Mesures ---#
     set captionspc(spc_mesures) "Mesures"
     set captionspc(spc_centergrav_w) "Centre de gravité d'une raie"
     set captionspc(spc_centergauss_w) "Centre gaussien d'une raie"
     set captionspc(spc_fwhm_w) "Largeur à mi-hauteur d'une raie"
     set captionspc(spc_ew_w) "Largeur équivalente d'une raie"
     set captionspc(spc_intensity_w) "Intensité d'une raie"


     #--- Menu Calibration ---#
     set captionspc(spc_calibration) "Calibration"
     set captionspc(spc_calibre2file_w) "Étalonnage en lambda avec 2 raies"
     set captionspc(spc_calibre2loifile_w) "Étalonnage en lambda avec lampe étalon"
     set captionspc(spc_calibre_space) "---------------------------------------------------------------------------"
     set captionspc(spc_rinstrum_w) "Calcul de la réponse instrumentale"
     set captionspc(spc_rinstrumcorr_w) "Correction de la réponse instrumentale"
     set captionspc(spc_calibre_space) "---------------------------------------------------------------------------"
     set captionspc(spc_norma_w) "Normalisation"


     #--- Menu Pipelines ---#
     set captionspc(spc_pipelines) "Pipelines"
     set captionspc(spc_traite2rinstrum_w) "1) Prétraitement -> réponse instrumentale"
     set captionspc(spc_traite2srinstrum_w) "2) Prétraitement -> correction instrumentale (application à d'autres spectres)"
     set captionspc(spc_traite2calibre_w) "1bis) Prétraitement -> calibration"
     set captionspc(spc_traite2scalibre_w) "2bis) Prétraitement -> calibration (application à d'autres spectres)"
     set captionspc(spc_pipelines_space) "---------------------------------------------------------------------------"
     # set captionspc(spc_traitesimple2calibre_w) "Prétraitement simple -> calibration"
     # set captionspc(spc_traitesimple2rinstrum_w) "Prétraitement simple -> réponse instrumentale"
     set captionspc(spc_geom2calibre_w) "Corrections géométriques -> calibration"
     set captionspc(spc_geom2rinstrum_w) "Corrections géométriques -> correction instrumentale"
     set captionspc(spc_specLhIII_w) "Réduction des spectres Lhires III (vide)"

     #--- Menu Astrophysique ---#
     set captionspc(spc_analyse) "Astrophysique"
     set captionspc(spc_chimie) "Repérage des espèces atomiques"
     set captionspc(spc_vradiale_w) "Vitesse radiale"
     set captionspc(spc_vexp_w) "Vitesse d'expension"
     set captionspc(spc_vrot_w) "Vitesse de rotation"
     set captionspc(spc_npte_w) "Température électronique"
     set captionspc(spc_npne_w) "Densité électronique"
     set captionspc(spc_ewcourbe_w) "Courbe EW=f(t) d'une série"

     #--- Menu Aide ---#
     set captionspc(spc_aide) "Aide"
     set captionspc(spc_about_w) "Auteur : Benjamin MAUCLAIRE"

}

#--- definition of colors
#--- definition des couleurs
set colorspc(back) #123456
set colorspc(back_infos) #FFCCDD
set colorspc(fore_infos) #000000
set colorspc(back_graphborder) #CCCCCC
set colorspc(plotbackground) #FFFFFF
set colorspc(profile) #000088

#--- definition of variables
#--- definition des variables
if { [info exists profilspc(initialfile)] == 0 } {
   set profilspc(initialfile) " "
}
if { [info exists profilspc(xunit)] == 0 } {
   set profilspc(xunit) "screen coord"
}
if { [info exists profilspc(yunit)] == 0 } {
   set profilspc(yunit) "screen coord"
}
