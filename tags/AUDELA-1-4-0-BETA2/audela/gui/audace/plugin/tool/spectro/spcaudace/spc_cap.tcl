# Cr�ation : 2003
# Modification : 08/12/2005

global spcaudace

#--- definition of captions
#--- definition des legendes


#----------------- Version anglaise --------------------------------------#
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


#----------------- Version francaise --------------------------------------#
if {[string compare $langage french] ==0 } {
     set captionspc(main_title) "SpcAud'ACE : analyseur de spectres"
     set captionspc(acq) "Acquisition CCD"
     #--- Divers ---#
     set captionspc(pixel) "Position (pixel)"
     set captionspc(angstrom) "Angstrom"
     set captionspc(angstroms) "Longueur d'onde (Angstrom)"
     set captionspc(intensity) "Intensit� (ADU)"
     set captionspc(adu) "ADU"
     set captionspc(spc_profile) "profil SPC"
     set captionspc(wait) "En cours..."
     set captionspc(parcourir) "...."
     #set captionspc(savespc) "Sauver un profil de raie"

     #--- Menu File ---#
     set captionspc(file) "Fichier"
     set captionspc(spc_file_space) "----------------------------------------------"
     set captionspc(loadspcfit) "Charger un profil de raie fits"
     set captionspc(loadspctxt) "Charger un profil de raie dat"
     set captionspc(spc_repconf) "Configuration du r�pertoire de travail"
     set captionspc(spc_spc2png_w) "Exporter un profil en image png"
     set captionspc(spc_spc2png2_w) "Exporter un profil en image png (r�glages fins)"
     set captionspc(writeps) "Exporter un profil en postscript"
     set captionspc(spc_fits2dat_w) "Conversion de profil fits vers dat"
     set captionspc(spc_dat2fits_w) "Conversion de profil dat vers fits"
     set captionspc(spc_spc2fits_w) "Conversion de profil spc vers fits"
     set captionspc(spc_spcs2fits_w) "Conversion d'un r�pertoire de profils spc vers fits"
     set captionspc(spc_bessmodule_w) "Export de fichier au format base BeSS"
     set captionspc(print_on) "Imprimer avec "
     set captionspc(quitspc) "Quitter la fen�tre SpcAudace"

     #--- Menu G�om�trie ---#
     set captionspc(spc_geometrie) "G�om�trie"
     set captionspc(spc_pretraitementfc_w) "Pr�traitement de spectres 2D"
     set captionspc(spc_register_w) "Appariement d'une s�rie de spectres 2D"
     set captionspc(spc_rot180_w) "Inversion gauche-droite (2D/1D)"
     set captionspc(spc_tiltauto_w) "Rotation automatique (2D)"
     set captionspc(spc_tilt_w) "Rotation manuelle"
     set captionspc(spc_slant_w) "Correction du slant (2D)"
     set captionspc(spc_smilex_w) "Correction du smile d'axe X (2D)"
     set captionspc(spc_smiley_w) "Correction du smile d'axe Y (2D)"

     #--- Menu Profil de raies ---#
     set captionspc(spc_profil) "Profil de raies"
     set captionspc(spc_profil_w) "Cr�er le profil automatique d'un spectre"
     set captionspc(spc_traitea_w) "Pr�traitement d'une s�rie et profil automatique"
     set captionspc(spc_extract_zone_w) "Cr�er un profil � partir d'une zone"

     #--- Menu Mesures ---#
     set captionspc(spc_mesures) "Mesures"
     set captionspc(spc_centergrav_w) "Centre de gravit� d'une raie"
     set captionspc(spc_centergauss_w) "Centre gaussien d'une raie"
     set captionspc(spc_fwhm_w) "Largeur � mi-hauteur d'une raie"
     set captionspc(spc_ew_w) "Largeur �quivalente d'une raie"
     set captionspc(spc_intensity_w) "Intensit� d'une raie"


     #--- Menu Calibration ---#
     set captionspc(spc_calibration) "Calibration"
     set captionspc(spc_calibre2file_w) "�talonnage en longeur d'onde"
     set captionspc(spc_calibre2loifile_w) "�talonnage en lambda avec lampe �talon"
     set captionspc(spc_calibre_space) "---------------------------------------------------------------------------"
     set captionspc(spc_rinstrum_w) "Calcul de la r�ponse instrumentale"
     set captionspc(spc_rinstrumcorr_w) "Correction de la r�ponse instrumentale"
     set captionspc(spc_calibre_space) "---------------------------------------------------------------------------"
     set captionspc(spc_norma_w) "Normalisation"


     #--- Menu Pipelines ---#
     set captionspc(spc_pipelines) "Pipelines"
     set captionspc(spc_pipelines_space) "---------------------------------------------------------------------------"
     set captionspc(spc_traite2rinstrum_w) "1) Calcul de la r�ponse instrumentale"
     set captionspc(spc_lampe2calibre_w) "2) Calibrations d'une lampe spectrale"
     set captionspc(spc_traite2srinstrum_w) "3) Application des calibrations aux spectres"
     set captionspc(spc_traite2scalibre_w) "Pr�traitement -> calibration (application � d'autres spectres)"
     # set captionspc(spc_traitesimple2calibre_w) "Pr�traitement simple -> calibration"
     # set captionspc(spc_traitesimple2rinstrum_w) "Pr�traitement simple -> r�ponse instrumentale"
     set captionspc(spc_geom2calibre_w) "Corrections g�om�triques -> calibration"
     set captionspc(spc_geom2rinstrum_w) "Corrections g�om�triques -> correction instrumentale"
     set captionspc(spc_specLhIII_w) "R�duction des spectres Lhires III (vide)"

     #--- Menu Astrophysique ---#
     set captionspc(spc_analyse) "Astrophysique"
     set captionspc(spc_chimie) "Rep�rage des esp�ces atomiques"
     set captionspc(spc_vradiale_w) "Vitesse radiale"
     set captionspc(spc_vexp_w) "Vitesse d'expension"
     set captionspc(spc_vrot_w) "Vitesse de rotation"
     set captionspc(spc_npte_w) "Temp�rature �lectronique"
     set captionspc(spc_npne_w) "Densit� �lectronique"
     set captionspc(spc_ewcourbe_w) "Courbe EW=f(t) d'une s�rie"

     #--- Menu Aide ---#
     set captionspc(spc_aide) "Aide"
     set captionspc(spc_version_w) "Version $spcaudace(version)"
     set captionspc(spc_help) "Liste des fonctions d'SpcAudACE"
     set captionspc(spc_about_w) "Auteur : Benjamin MAUCLAIRE"
     set captionspc(spc_contrib_w) "Contributeurs : $spcaudace(contribs)."
}

set presentation "SpcAudACE - version $spcaudace(version) @$spcaudace(author)\n"
return $presentation
