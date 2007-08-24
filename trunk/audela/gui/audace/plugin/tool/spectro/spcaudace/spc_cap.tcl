#
# Création : 2003
# Modification : 08/12/2005
#

global spcaudace langage

# *************** Version anglaise ****************************

set captionspc(main_title)                         "SpcAud'ACE: Spectrum analyser"
set captionspc(acq)                                "CCD acquisition"

#--- Divers ---#
set captionspc(pixel)                              "Position (pixel)"
set captionspc(angstrom)                           "Angstrom"
set captionspc(angstroms)                          "Wavelength (Angstrom)"
set captionspc(intensity)                          "Intensity (ADU)"
set captionspc(adu)                                "ADU"
set captionspc(spc_profile)                        "SPC profil"
set captionspc(wait)                               "Wait..."
set captionspc(parcourir)                          "...."
# set captionspc(savespc)                            "Sauver un profil de raie"

#--- Menu File ---#
set captionspc(file)                               "File"
set captionspc(spc_file_space)                     "----------------------------------------------"
set captionspc(loadspcfit)                         "Load a FITS lines profil"
set captionspc(loadspctxt)                         "Load a DAT lines profile"
set captionspc(spc_repconf)                        "Working directory configuration"
set captionspc(spc_spc2png_w)                      "Export a profil to png picture"
set captionspc(spc_spc2png2_w)                     "Export a profil to png picture (tough setup)"
set captionspc(writeps)                            "Export a profil to postscript"
set captionspc(spc_fits2dat_w)                     "Export FITS profils to dat"
set captionspc(spc_dat2fits_w)                     "Export DAT profil to FITS"
set captionspc(spc_spc2fits_w)                     "Export SPC profil to FITS"
set captionspc(spc_spcs2fits_w)                    "Export an entire directory of SPC profils to FITS"
set captionspc(spc_simbad)                         "Go to Simbad web data base"
set captionspc(spc_bess)                           "Go to BeSS web data base"
set captionspc(spc_uves)                           "Go to UVES web data base"
set captionspc(spc_bessmodule_w)                   "Export a profil to BeSS's format"
set captionspc(print_on)                           "Print with "
set captionspc(quitspc)                            "Exit SpcAud'ACE's window"

#--- Menu Géométrie ---#
set captionspc(spc_geometrie)                      "Geometry"
set captionspc(spc_pretraitementfc_w)              "2D spectrum processing"
set captionspc(spc_register_w)                     "Register a 2D spectrum serie"
set captionspc(spc_rot180_w)                       "Invert left-right (2D/1D)"
set captionspc(spc_tiltauto_w)                     "Automatic tilt (2D)"
set captionspc(spc_tilt_w)                         "Manual tilt"
set captionspc(spc_slant_w)                        "Slant correction (2D)"
set captionspc(spc_smilex_w)                       "X axis smile correction (2D)"
set captionspc(spc_smiley_w)                       "Y axis smile correction (2D)"

#--- Menu Profil de raies ---#
set captionspc(spc_profil)                         "Lines profil"
set captionspc(spc_profil_w)                       "Automatic lines profil creation"
set captionspc(spc_traitea_w)                      "Sequence preprocessing and automatic profile creation"
set captionspc(spc_extract_zone_w)                 "Create a profil from a selected area"

#--- Menu Mesures ---#
set captionspc(spc_mesures)                        "Measures"
set captionspc(spc_centergrav_w)                   "Line's gravity center"
set captionspc(spc_centergauss_w)                  "Line's gaussian center"
set captionspc(spc_fwhm_w)                         "Line's FWHM"
set captionspc(spc_ew_w)                           "Line's equivalent width (EW)"
set captionspc(spc_intensity_w)                    "Line's intensity"

#--- Menu Calibration ---#
set captionspc(spc_calibration)                    "Calibration"
set captionspc(spc_calibre2file_w)                 "Wavelength calibration"
set captionspc(spc_calibre2loifile_w)              "Wavelength calibration with a spectral reference lamp"
set captionspc(spc_calibre_space)                  "---------------------------------------------------------------------------"
set captionspc(spc_rinstrum_w)                     "Compute instrumental response (RI)"
set captionspc(spc_rinstrumcorr_w)                 "Correction for instrumental response"
set captionspc(spc_calibre_space)                  "---------------------------------------------------------------------------"
set captionspc(spc_norma_w)                        "Normalisation"

#--- Menu Pipelines ---#
set captionspc(spc_pipelines)                      "Pipelines"
set captionspc(spc_pipelines_space)                "---------------------------------------------------------------------------"
set captionspc(spc_traite2rinstrum_w)              "1) Compute instrumental response (RI)"
set captionspc(spc_lampe2calibre_w)                "2) Spectral lamp calibration"
set captionspc(spc_traite2srinstrum_w)             "3) Incorporating calibration corrections to spectra"
set captionspc(spc_traitestellaire)                "Stellar spectrum processing (fusion of 2+3 & no options)"
set captionspc(spc_traitenebula)                   "Non stellar spectrum processing"
set captionspc(spc_traite2scalibre_w)              "Incorporating calibration corrections (without RI) to spectra"
# set captionspc(spc_traitesimple2calibre_w)         "Prétraitement simple -> Calibration"
# set captionspc(spc_traitesimple2rinstrum_w)        "Prétraitement simple -> Réponse instrumentale"
set captionspc(spc_geom2calibre_w)                 "Geometrics corrections -> Wavelength calibration"
set captionspc(spc_geom2rinstrum_w)                "Geometrics corrections -> Intrsunmental reposne correction"
set captionspc(spc_specLhIII_w)                    "LhiresIII spectral preprocessing (empty)"

#--- Menu Astrophysique ---#
set captionspc(spc_analyse)                        "Astrophysic"
set captionspc(spc_surveys)                        "Web site for surveys prepration"
set captionspc(spc_bebuil)                         "Be list web site"
set captionspc(spc_chimie)                         "Find chemical components"
set captionspc(spc_vradiale_w)                     "Radial velocity"
set captionspc(spc_vexp_w)                         "Expension velocity"
set captionspc(spc_vrot_w)                         "Rotation velocity"
set captionspc(spc_npte_w)                         "Electronic temperature of a nebula"
set captionspc(spc_npne_w)                         "Electronic density of a nebula"
set captionspc(spc_ewcourbe_w)                     "EW=f(time) graph for a group of files"
set captionspc(spc_spectrum)                       "SPECTRUM: Launch synthetic spectra software"

#--- Menu Aide ---#
set captionspc(spc_aide)                           "Help"
set captionspc(spc_version_w)                      "Version $spcaudace(version)"
set captionspc(spc_help)                           "SpcAudACE's funtions list"
set captionspc(spc_about_w)                        "Author: Benjamin MAUCLAIRE"
set captionspc(spc_contrib_w)                      "Contributors: $spcaudace(contribs)."

# *************** Version française ***************************
if { [string compare $langage "french"] == "0" } {

     set captionspc(main_title)                    "SpcAud'ACE : Analyseur de spectres"
     set captionspc(acq)                           "Acquisition CCD"

     #--- Divers ---#
     set captionspc(pixel)                         "Position (pixel)"
     set captionspc(angstrom)                      "Angström"
     set captionspc(angstroms)                     "Longueur d'onde (Angström)"
     set captionspc(intensity)                     "Intensité (ADU)"
     set captionspc(adu)                           "ADU"
     set captionspc(spc_profile)                   "profil SPC"
     set captionspc(wait)                          "En cours..."
     set captionspc(parcourir)                     "...."
    # set captionspc(savespc)                       "Sauver un profil de raie"

     #--- Menu File ---#
     set captionspc(file)                          "Fichier"
     set captionspc(spc_file_space)                "----------------------------------------------"
     set captionspc(loadspcfit)                    "Charger un profil de raie fits"
     set captionspc(loadspctxt)                    "Charger un profil de raie dat"
     set captionspc(spc_repconf)                   "Configuration du répertoire de travail"
     set captionspc(spc_spc2png_w)                 "Exporter un profil en image png"
     set captionspc(spc_spc2png2_w)                "Exporter un profil en image png (réglages fins)"
     set captionspc(writeps)                       "Exporter un profil en postscript"
     set captionspc(spc_fits2dat_w)                "Conversion de profil fits vers dat"
     set captionspc(spc_dat2fits_w)                "Conversion de profil dat vers fits"
     set captionspc(spc_spc2fits_w)                "Conversion de profil spc vers fits"
     set captionspc(spc_spcs2fits_w)               "Conversion d'un répertoire de profils spc vers fits"
     set captionspc(spc_simbad)                    "Accès au site de la base Simbad"
     set captionspc(spc_bess)                      "Accès au site de la base BeSS"
     set captionspc(spc_uves)                      "Accès au site de la base UVES"
     set captionspc(spc_bessmodule_w)              "Export de fichier au format base BeSS"
     set captionspc(print_on)                      "Imprimer avec "
     set captionspc(quitspc)                       "Quitter la fenêtre SpcAud'ACE"

     #--- Menu Géométrie ---#
     set captionspc(spc_geometrie)                 "Géométrie"
     set captionspc(spc_pretraitementfc_w)         "Prétraitement de spectres 2D"
     set captionspc(spc_register_w)                "Appariement d'une série de spectres 2D"
     set captionspc(spc_rot180_w)                  "Inversion gauche-droite (2D/1D)"
     set captionspc(spc_tiltauto_w)                "Rotation automatique (2D)"
     set captionspc(spc_tilt_w)                    "Rotation manuelle"
     set captionspc(spc_slant_w)                   "Correction du slant (2D)"
     set captionspc(spc_smilex_w)                  "Correction du smile d'axe X (2D)"
     set captionspc(spc_smiley_w)                  "Correction du smile d'axe Y (2D)"

     #--- Menu Profil de raies ---#
     set captionspc(spc_profil)                    "Profil de raies"
     set captionspc(spc_profil_w)                  "Créer le profil automatique d'un spectre"
     set captionspc(spc_traitea_w)                 "Prétraitement d'une série et profil automatique"
     set captionspc(spc_extract_zone_w)            "Créer un profil à partir d'une zone"

     #--- Menu Mesures ---#
     set captionspc(spc_mesures)                   "Mesures"
     set captionspc(spc_centergrav_w)              "Centre de gravité d'une raie"
     set captionspc(spc_centergauss_w)             "Centre gaussien d'une raie"
     set captionspc(spc_fwhm_w)                    "Largeur à mi-hauteur d'une raie"
     set captionspc(spc_ew_w)                      "Largeur équivalente d'une raie"
     set captionspc(spc_intensity_w)               "Intensité d'une raie"

     #--- Menu Calibration ---#
     set captionspc(spc_calibration)               "Calibration"
     set captionspc(spc_calibre2file_w)            "Etalonnage en longueur d'onde"
     set captionspc(spc_calibre2loifile_w)         "Etalonnage en lambda avec lampe étalon"
     set captionspc(spc_calibre_space)             "---------------------------------------------------------------------------"
     set captionspc(spc_rinstrum_w)                "Calcul de la réponse instrumentale"
     set captionspc(spc_rinstrumcorr_w)            "Correction de la réponse instrumentale"
     set captionspc(spc_calibre_space)             "---------------------------------------------------------------------------"
     set captionspc(spc_norma_w)                   "Normalisation"

     #--- Menu Pipelines ---#
     set captionspc(spc_pipelines)                 "Pipelines"
     set captionspc(spc_pipelines_space)           "---------------------------------------------------------------------------"
     set captionspc(spc_traite2rinstrum_w)         "1) Calcul de la réponse instrumentale"
     set captionspc(spc_lampe2calibre_w)           "2) Calibrations d'une lampe spectrale"
     set captionspc(spc_traite2srinstrum_w)        "3) Application des calibrations aux spectres"
     set captionspc(spc_traitestellaire)           "Réduction de spectres stellaires (fusion 2+3 & sans options)"
     set captionspc(spc_traitenebula)           "Réduction de spectres non stellaires"
     set captionspc(spc_traite2scalibre_w)         "Application des calibrations (sans RI) aux spectres"
    # set captionspc(spc_traitesimple2calibre_w)    "Prétraitement simple -> Calibration"
    # set captionspc(spc_traitesimple2rinstrum_w)   "Prétraitement simple -> Réponse instrumentale"
     set captionspc(spc_geom2calibre_w)            "Corrections géométriques -> Calibration"
     set captionspc(spc_geom2rinstrum_w)           "Corrections géométriques -> Correction instrumentale"
     set captionspc(spc_specLhIII_w)               "Réduction des spectres Lhires III (vide)"

     #--- Menu Astrophysique ---#
     set captionspc(spc_analyse)                   "Astrophysique"
     set captionspc(spc_surveys)                   "Site Internet pour la préparation de surveys"
     set captionspc(spc_bebuil)                    "Site Internet de liste d'étoiles Be"
     set captionspc(spc_chimie)                    "Repérage des espèces atomiques"
     set captionspc(spc_vradiale_w)                "Vitesse radiale"
     set captionspc(spc_vexp_w)                    "Vitesse d'expension"
     set captionspc(spc_vrot_w)                    "Vitesse de rotation"
     set captionspc(spc_npte_w)                    "Température électronique"
     set captionspc(spc_npne_w)                    "Densité électronique"
     set captionspc(spc_ewcourbe_w)                "Courbe EW=f(t) d'une série"
     set captionspc(spc_spectrum)                  "SPECTRUM : Synthèse de spectres"

     #--- Menu Aide ---#
     set captionspc(spc_aide)                      "Aide"
     set captionspc(spc_version_w)                 "Version $spcaudace(version)"
     set captionspc(spc_help)                      "Liste des fonctions de SpcAudACE"
     set captionspc(spc_about_w)                   "Auteur : Benjamin MAUCLAIRE"
     set captionspc(spc_contrib_w)                 "Contributeurs : $spcaudace(contribs)."

# *************** Version italienne ***************************
} elseif { [string compare $langage "italian"] == "0" } {



# *************** Version espagnole ***************************
} elseif { [string compare $langage "spanish"] == "0" } {



# *************** Version allemande ***************************
} elseif { [string compare $langage "german"] == "0" } {



# *************** Version portugaise **************************
} elseif { [ string compare $langage "portuguese" ] == "0" } {



# *************** Version danoise *****************************
} elseif { [string compare $langage "danish"] == "0" } {



}

#================================================================================
#   Fin de la déclaration des textes localisés (internationalisation)
#================================================================================

#================================================================================#
set presentation "SpcAudACE - version $spcaudace(version) @$spcaudace(author)\n"
return $presentation
#================================================================================#


#----------------- Version anglaise_toto --------------------------------------#
if {[string compare $langage toto] ==0 } {
   set captionspc(main_title) "SpcAud'ACE: Spectrum analyser"
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

