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
     set captionspc(print_on) "Imprimer avec "
     set captionspc(quitspc) "Quitter la fenêtre SpcAudace"

     #--- Menu Géométrie ---#
     set captionspc(spc_geometrie) "Géométrie"
     set captionspc(spc_register_w) "Appariement d'une série de spectres 2D"
     set captionspc(spc_rot180) "Rotation de 180°"
     set captionspc(spc_tiltauto) "Rotation automatique"
     set captionspc(spc_tilt_w) "Rotation manuelle"
     set captionspc(spc_slant_w) "Correction du slant"
     set captionspc(spc_smile_w) "Correction du smile"

     #--- Menu Profil de raies ---#
     set captionspc(spc_profil) "Profil de raies"
     set captionspc(spc_open_fitfile) "Créer le profil d'une zone"
     set captionspc(spc_profil_w) "Créer le profil automatiue d'un spectre"
     set captionspc(spc_traitea_w) "Prétraitement et profil automatique d'une série"
     set captionspc(spc_select_w) "Découpage d'une zone de profil"

     #--- Menu Mesures ---#
     set captionspc(spc_mesures) "Mesures"
     set captionspc(spc_centergrav_w) "Centre de gravité d'une raie"
     set captionspc(spc_centergauss_w) "Centre gaussien d'une raie"
     set captionspc(spc_fwhm_w) "Largeur à mi-hauteur d'une raie"
     set captionspc(spc_ew_w) "Largeur équivalente d'une raie"
     set captionspc(spc_intensity_w) "Intensité d'une raie"

     #--- Menu Calibration ---#
     set captionspc(spc_calibration) "Calibration"
     set captionspc(cali_lambda) "Étalonnage en lambda"
     set captionspc(cali_flux) "Étalonnage en flux (appliquer la RI)"
     set captionspc(spc_norma) "Normalisation"
     set captionspc(spc_rinstrum_w) "Calcul de la réponse instrumentale RI"

     #--- Menu Analyse ---#
     set captionspc(spc_analyse) "Analyse"
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
