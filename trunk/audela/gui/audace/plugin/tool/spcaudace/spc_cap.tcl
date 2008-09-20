#
# Cr�ation : 2003
# Modification : 08/12/2005
#

# Mise a jour $Id: spc_cap.tcl,v 1.2 2008-09-20 17:20:05 bmauclaire Exp $


global caption langage

# *************** Version anglaise ****************************

   set caption(spcaudace,gui,main_title)                         "SpcAud'ACE: spectrum analyser"
   set caption(spcaudace,gui,acq)                                "CCD acquisition"
   set caption(spcaudace,gui,erreur,saisie)                      "Entry error"

   #--- Divers ---#
   set caption(spcaudace,gui,pixel)                              "Position (pixel)"
   set caption(spcaudace,gui,angstrom)                           "Angstrom"
   set caption(spcaudace,gui,angstroms)                          "Wavelength (Angstrom)"
   set caption(spcaudace,gui,intensity)                          "Intensity (ADU)"
   set caption(spcaudace,gui,adu)                                "ADU"
   set caption(spcaudace,gui,spc_profile)                        "SPC profil"
   set caption(spcaudace,gui,wait)                               "Wait..."
   set caption(spcaudace,gui,parcourir)                          "...."
   # set caption(spcaudace,gui,savespc)                            "Sauver un profil de raie"

   #--- Menu File ---#
   set caption(spcaudace,gui,file)                               "File"
   set caption(spcaudace,gui,spc_file_space)                     "----------------------------------------------"
   set caption(spcaudace,gui,loadspcfit)                         "Load a FITS lines profil"
   set caption(spcaudace,gui,loadspctxt)                         "Load a DAT lines profile"
   set caption(spcaudace,gui,spc_load)                            "Load a FITS or DAT lines profil"
   set caption(spcaudace,gui,gloadmore)                          "Load more FITS lines profile"
   set caption(spcaudace,gui,gdelete)                            "Erase one lines profile ploted"
   set caption(spcaudace,gui,gdeleteall)                         "Erase all lines profile ploted"
   set caption(spcaudace,gui,spc_simbad)                         "Go to Simbad web data base"
   set caption(spcaudace,gui,spc_bess)                           "Go to BeSS web data base"
   set caption(spcaudace,gui,spc_arasbeam)                       "Go to ArasBeam web data base"
   set caption(spcaudace,gui,spc_uves)                           "Go to UVES web data base"
   set caption(spcaudace,gui,print_on)                           "Print with "
   set caption(spcaudace,gui,quitspc)                            "Exit SpcAud'ACE's window"

   #--- Menu Conversions ---#
   set caption(spcaudace,gui,conv)                               "Conversions"
   set caption(spcaudace,gui,spc_repconf)                        "Working directory configuration"
   set caption(spcaudace,gui,spc_spc2png_w)                      "Export a profil to PNG picture"
   set caption(spcaudace,gui,spc_spc2png2_w)                     "Export a profil to PNG picture (tough setup)"
   set caption(spcaudace,gui,writeps)                            "Screenshot to Postscript file"
   set caption(spcaudace,gui,writegif)                           "Screenshot to GIF file"
   set caption(spcaudace,gui,spc_fit2ps)                         "Export a profil to Postscript file"
   set caption(spcaudace,gui,spc_fits2dat_w)                     "Export FITS profils to dat"
   set caption(spcaudace,gui,spc_dat2fits_w)                     "Export DAT profil to FITS"
   set caption(spcaudace,gui,spc_spc2fits_w)                     "Export SPC profil to FITS"
   set caption(spcaudace,gui,spc_spcs2fits_w)                    "Export an entire directory of SPC profils to FITS"
   set caption(spcaudace,gui,spc_bessmodule_w)                   "Export a profil to BeSS's format"


   #--- Menu G�om�trie ---#
   set caption(spcaudace,gui,spc_geometrie)                      "Geometry"
   set caption(spcaudace,gui,spc_pretraitementfc_w)              "2D spectrum processing"
   set caption(spcaudace,gui,spc_pretrait)                       "2D spectrum expert processing"
   set caption(spcaudace,gui,spc_register_w)                     "Register a 2D spectrum serie"
   set caption(spcaudace,gui,spc_rot180_w)                       "Invert left-right (2D/1D)"
   set caption(spcaudace,gui,spc_tiltauto_w)                     "Automatic tilt (2D)"
   set caption(spcaudace,gui,spc_tilt_w)                         "Manual tilt"
   set caption(spcaudace,gui,spc_slant_w)                        "Slant correction (2D)"
   set caption(spcaudace,gui,spc_smilex_w)                       "X axis smile correction (2D)"
   set caption(spcaudace,gui,spc_smiley_w)                       "Y axis smile correction (2D)"
   set caption(spcaudace,gui,spc_findtilt)                       "Automatic compution of TITL angle"
   set caption(spcaudace,gui,spc_tilt2)                          "TILT correction with angle and center" 


   #--- Menu Profil de raies ---#
   set caption(spcaudace,gui,spc_profil)                         "Lines profil"
   set caption(spcaudace,gui,spc_profil_w)                       "Automatic lines profil creation"
   set caption(spcaudace,gui,spc_traitea_w)                      "Sequence preprocessing and automatic profile creation"
   set caption(spcaudace,gui,spc_extract_zone_w)                 "Create a profil from a selected area"
   set caption(spcaudace,gui,spc_smooth)                         "Smooth with low passband filter"
   set caption(spcaudace,gui,spc_smooth2)                        "Smooth with non-linear filter"
   set caption(spcaudace,gui,spc_div)                            "Dividing two lines profile"
   set caption(spcaudace,gui,spc_extractcont)                    "Extract continuum"
   set caption(spcaudace,gui,spc_dry)                            "Remove telluric lines"
   set caption(spcaudace,gui,spc_calibre_space)                  "---------------------------------------------------------------------------"
   set caption(spcaudace,gui,spc_norma_w)                        "Normalisation by continuum extraction"
   set caption(spcaudace,gui,spc_rescalecont_w)                  "Rescaling continuum to value 1"


   #--- Menu Mesures ---#
   set caption(spcaudace,gui,spc_mesures)                        "Measures"
   set caption(spcaudace,gui,spc_centergrav_w)                   "Line's gravity center"
   set caption(spcaudace,gui,spc_centergauss_w)                  "Line's gaussian center"
   set caption(spcaudace,gui,spc_fwhm_w)                         "Line's FWHM"
   set caption(spcaudace,gui,spc_ew_w)                           "Line's equivalent width (EW)"
   set caption(spcaudace,gui,spc_ew1_w)                           "Line's equivalent width (EW) of a complex spectrum"
   set caption(spcaudace,gui,spc_intensity_w)                    "Line's intensity"
   set caption(spcaudace,gui,spc_imax)                           "Line's maximum"
   set caption(spcaudace,gui,spc_icontinuum)                     "Compute continuum intensity"
   set caption(spcaudace,gui,spc_snr)                            "SNR of a lines profile"

   #--- Menu Calibration ---#
   set caption(spcaudace,gui,spc_calibration)                    "Calibration"
   set caption(spcaudace,gui,spc_loadneon)                       "Load neon lines profile"
   set caption(spcaudace,gui,spc_calibre2file_w)                 "Wavelength calibration"
   set caption(spcaudace,gui,spc_calibre2loifile_w)              "Wavelength calibration with a spectral reference lamp"
   set caption(spcaudace,gui,spc_calibredecal)                   "Wavelength shifting"
   set caption(spcaudace,gui,spc_linearcal)                      "Linearisation of calibration law"
   set caption(spcaudace,gui,spc_corrvhelio)                     "Heliocentric velocity correction"
   set caption(spcaudace,gui,spc_calibretelluric)                "Wavelength calibration with telluric lines"
   set caption(spcaudace,gui,spc_calobilan)                      "Wavelength calibration diagnostic with telluric lines"
   set caption(spcaudace,gui,spc_caloverif)                      "Wavelength calibration checking with telluric lines"
   set caption(spcaudace,gui,spc_loadmh2o)                       "Superpose tellruic lines profile"

   set caption(spcaudace,gui,spc_calibre_space)                  "---------------------------------------------------------------------------"
   set caption(spcaudace,gui,spc_rinstrum_w)                     "Compute instrumental response (RI)"
   set caption(spcaudace,gui,spc_rinstrumcorr_w)                 "Correction for instrumental response"
   set caption(spcaudace,gui,spc_divri)                          "Dividing by instrumental response"

   #--- Menu Pipelines ---#
   set caption(spcaudace,gui,spc_pipelines)                      "Pipelines"
   set caption(spcaudace,gui,spc_pipelines_space)                "---------------------------------------------------------------------------"
   set caption(spcaudace,gui,spc_traite2rinstrum_w)              "1) Compute instrumental response (RI)"
   set caption(spcaudace,gui,spc_lampe2calibre_w)                "Spectral lamp calibration"
   set caption(spcaudace,gui,spc_traite2srinstrum_w)             "Incorporating calibration corrections to spectra (expert mode)"
   set caption(spcaudace,gui,spc_traitestellaire)                "2a) Stellar spectrum processing (simple mode)"
   set caption(spcaudace,gui,spc_traitenebula)                   "2b) Non stellar spectrum processing"
   set caption(spcaudace,gui,spc_traite2scalibre_w)              "Incorporating calibration corrections (without RI) to spectra"
   # set caption(spcaudace,gui,spc_traitesimple2calibre_w)         "Pr�traitement simple -> Calibration"
   # set caption(spcaudace,gui,spc_traitesimple2rinstrum_w)        "Pr�traitement simple -> R�ponse instrumentale"
   set caption(spcaudace,gui,spc_geom2calibre_w)                 "Geometrics corrections -> Wavelength calibration"
   set caption(spcaudace,gui,spc_geom2rinstrum_w)                "Geometrics corrections -> Intrsunmental reposne correction"
   set caption(spcaudace,gui,spc_specLhIII_w)                    "LhiresIII spectral preprocessing (empty)"

   #--- Menu Astrophysique ---#
   set caption(spcaudace,gui,spc_analyse)                        "Astrophysic"
   set caption(spcaudace,gui,spc_surveys)                        "Web site for surveys prepration"
   set caption(spcaudace,gui,spc_bebuil)                         "Be list web site"
   set caption(spcaudace,gui,spc_chimie)                         "Find chemical components"
   set caption(spcaudace,gui,spc_vradiale_w)                     "Radial velocity"
   set caption(spcaudace,gui,spc_vhelio)                         "Heliocentric velocity"
   set caption(spcaudace,gui,spc_vradialecorr_w)                 "Radial velocity corrected from Vhelio"
   set caption(spcaudace,gui,spc_vrmes_w)                        "Compute V over R line ratio"
   set caption(spcaudace,gui,spc_vexp_w)                         "Expension velocity"
   set caption(spcaudace,gui,spc_vrot_w)                         "Rotation velocity"
   set caption(spcaudace,gui,spc_ewcourbe_w)                     "EW=f(time) graph for a group of files"
   set caption(spcaudace,gui,spc_ewdirw)                         "EW extraction with info in asciifile of a group of files"
   set caption(spcaudace,gui,spc_te)                             "Electronic temperature (automatic)"
   set caption(spcaudace,gui,spc_ne)                             "Electronic density (automatic)"
   set caption(spcaudace,gui,spc_npte_w)                         "Electronic temperature of a nebula"
   set caption(spcaudace,gui,spc_npne_w)                         "Electronic density of a nebula"
   set caption(spcaudace,gui,spc_normahbeta)                     "Normalisation with H-beta line"
   set caption(spcaudace,gui,spc_spectrum)                       "SPECTRUM: Launch synthetic spectra software"

   #--- Menu Aide ---#
   set caption(spcaudace,gui,spc_aide)                           "Help"
   set caption(spcaudace,gui,spc_version_w)                      "Version $spcaudace(version)"
   set caption(spcaudace,gui,spc_help)                           "SpcAudACE's funtions list"
   set caption(spcaudace,gui,spc_site)                           "SpcAudACE's webpage"
   set caption(spcaudace,gui,spc_about_w)                        "Author: Benjamin MAUCLAIRE"
   set caption(spcaudace,gui,spc_contrib_w)                      "Contributors: $spcaudace(contribs)."


# *************** Version fran�aise ***************************
if { [string compare $langage "french"] == "0" } {

     set caption(spcaudace,gui,main_title)                    "SpcAud'ACE : analyseur de spectres"
     set caption(spcaudace,gui,acq)                           "Acquisition CCD"
     set caption(spcaudace,gui,erreur,saisie)                 "Erreur de saisie"

     #--- Divers ---#
     set caption(spcaudace,gui,pixel)                         "Position (pixel)"
     set caption(spcaudace,gui,angstrom)                      "Angstr�m"
     set caption(spcaudace,gui,angstroms)                     "Longueur d'onde (Angstr�m)"
     set caption(spcaudace,gui,intensity)                     "Intensit� (ADU)"
     set caption(spcaudace,gui,adu)                           "ADU"
     set caption(spcaudace,gui,spc_profile)                   "profil SPC"
     set caption(spcaudace,gui,wait)                          "En cours..."
     set caption(spcaudace,gui,parcourir)                     "...."
    # set caption(spcaudace,gui,savespc)                       "Sauver un profil de raie"

     #--- Menu File ---#
     set caption(spcaudace,gui,file)                          "Fichier"
     set caption(spcaudace,gui,spc_file_space)                "----------------------------------------------"
     set caption(spcaudace,gui,loadspcfit)                    "Charger un profil de raie fits"
     set caption(spcaudace,gui,loadspctxt)                    "Charger un profil de raie dat"
     set caption(spcaudace,gui,spc_load)                      "Charger un profil de raies FITS ou DAT"
     set caption(spcaudace,gui,gloadmore)                     "Afficher d'autres profils de raies FITS"
     set caption(spcaudace,gui,gdelete)                       "Effacer un profil de raies affich�"
     set caption(spcaudace,gui,gdeleteall)                    "Effacer tous les profils de raies affich�s"
     set caption(spcaudace,gui,spc_repconf)                   "Configuration du r�pertoire de travail"
     set caption(spcaudace,gui,spc_simbad)                    "Acc�s au site de la base Simbad"
     set caption(spcaudace,gui,spc_bess)                      "Acc�s au site de la base BeSS"
     set caption(spcaudace,gui,spc_arasbeam)                  "Acc�s au site ArasBeam"
     set caption(spcaudace,gui,spc_uves)                      "Acc�s au site de la base UVES"
     set caption(spcaudace,gui,print_on)                      "Imprimer avec "
     set caption(spcaudace,gui,quitspc)                       "Quitter la fen�tre SpcAud'ACE"


     #--- Menu Conversions ---#
     set caption(spcaudace,gui,conv)                          "Conversions"
     set caption(spcaudace,gui,spc_spc2png_w)                 "Exporter un profil en image PNG"
     set caption(spcaudace,gui,spc_spc2png2_w)                "Exporter un profil en image PNG (r�glages fins)"
     set caption(spcaudace,gui,writeps)                       "Fait une capture d'�cran au format Postscript"
     set caption(spcaudace,gui,writegif)                      "Fait une capture d'�cran au format GIF"
     set caption(spcaudace,gui,spc_fit2ps)                    "Exporter un profil en Postscript"
     set caption(spcaudace,gui,spc_fits2dat_w)                "Conversion de profil FITS vers DAT"
     set caption(spcaudace,gui,spc_dat2fits_w)                "Conversion de profil DAT vers FITS"
     set caption(spcaudace,gui,spc_spc2fits_w)                "Conversion de profil SPC vers FITS"
     set caption(spcaudace,gui,spc_spcs2fits_w)               "Conversion d'un r�pertoire de profils SPC vers FITS"
     set caption(spcaudace,gui,spc_bessmodule_w)              "Export de fichier au format base BeSS"

     #--- Menu G�om�trie ---#
     set caption(spcaudace,gui,spc_geometrie)                 "G�om�trie"
     set caption(spcaudace,gui,spc_pretraitementfc_w)         "Pr�traitement de spectres 2D"
     set caption(spcaudace,gui,spc_pretrait)                  "Pr�traitement expert de spectres 2D"
     set caption(spcaudace,gui,spc_register_w)                "Appariement d'une s�rie de spectres 2D"
     set caption(spcaudace,gui,spc_rot180_w)                  "Inversion gauche-droite (2D/1D)"
     set caption(spcaudace,gui,spc_tiltauto_w)                "Rotation automatique (2D)"
     set caption(spcaudace,gui,spc_tilt_w)                    "Rotation manuelle"
     set caption(spcaudace,gui,spc_slant_w)                   "Correction du slant (2D)"
     set caption(spcaudace,gui,spc_smilex_w)                  "Correction du smile d'axe X (2D)"
     set caption(spcaudace,gui,spc_smiley_w)                  "Correction du smile d'axe Y (2D)"
     set caption(spcaudace,gui,spc_findtilt)                  "Calcul automatique de l'angle de TILT"
     set caption(spcaudace,gui,spc_tilt2)                     "Correction du TILT avec l'angle et le centre" 

     #--- Menu Profil de raies ---#
     set caption(spcaudace,gui,spc_profil)                    "Profil de raies"
     set caption(spcaudace,gui,spc_profil_w)                  "Cr�er le profil automatique d'un spectre"
     set caption(spcaudace,gui,spc_traitea_w)                 "Pr�traitement d'une s�rie et profil automatique"
     set caption(spcaudace,gui,spc_extract_zone_w)            "Cr�er un profil � partir d'une zone"
     set caption(spcaudace,gui,spc_smooth)                    "Adoucissement par filtrage passe bas"
     set caption(spcaudace,gui,spc_smooth2)                   "Adoucissement par filtrage non-lin�aire"
     set caption(spcaudace,gui,spc_div)                       "Division de deux profils de raies"
     set caption(spcaudace,gui,spc_extractcont)               "Extraction du continuum"
     set caption(spcaudace,gui,spc_dry)                       "Retrait des raies telluriques"
     set caption(spcaudace,gui,spc_calibre_space)             "---------------------------------------------------------------------------"
     set caption(spcaudace,gui,spc_norma_w)                   "Normalisation par extraction du continuum"
     set caption(spcaudace,gui,spc_rescalecont_w)             "Mise � l'�chelle � 1 du continuum"


     #--- Menu Mesures ---#
     set caption(spcaudace,gui,spc_mesures)                   "Mesures"
     set caption(spcaudace,gui,spc_centergrav_w)              "Centre de gravit� d'une raie"
     set caption(spcaudace,gui,spc_centergauss_w)             "Centre gaussien d'une raie"
     set caption(spcaudace,gui,spc_fwhm_w)                    "Largeur � mi-hauteur d'une raie"
     set caption(spcaudace,gui,spc_ew_w)                      "Largeur �quivalente d'une raie"
     set caption(spcaudace,gui,spc_ew1_w)                      "Largeur �quivalente d'une raie d'un spectre complexe"
     set caption(spcaudace,gui,spc_intensity_w)               "Intensit� d'une raie"
     set caption(spcaudace,gui,spc_imax)                      "Valeur maximum d'une raie"
     set caption(spcaudace,gui,spc_icontinuum)                "Intensit� du continuum"
     set caption(spcaudace,gui,spc_snr)                       "SNR d'un profil de raies"


     #--- Menu Calibration ---#
     set caption(spcaudace,gui,spc_calibration)               "Calibration"
     set caption(spcaudace,gui,spc_loadneon)                  "Visualiser le profil de raies du n�on "
     set caption(spcaudace,gui,spc_calibre2file_w)            "Etalonnage en longueur d'onde"
     set caption(spcaudace,gui,spc_calibre2loifile_w)         "Etalonnage en longueur d'onde avec lampe �talon"
     set caption(spcaudace,gui,spc_calibredecal)              "D�calage du spectre en longueur d'onde"
     set caption(spcaudace,gui,spc_linearcal)                 "Lin�arise la loi de calibration"
     set caption(spcaudace,gui,spc_corrvhelio)                "Correction de la vitesse h�liocentrique"
     set caption(spcaudace,gui,spc_calibretelluric)           "Etalonnage avec les raies telluriques"
     set caption(spcaudace,gui,spc_calobilan)                 "Bilan de la calibration avec les raies telluriques"
     set caption(spcaudace,gui,spc_caloverif)                 "V�rifie la calibration avec les raies telluriques"
     set caption(spcaudace,gui,spc_loadmh2o)                  "Superposer le profil de raies de l'eau"
     set caption(spcaudace,gui,spc_calibre_space)             "---------------------------------------------------------------------------"
     set caption(spcaudace,gui,spc_rinstrum_w)                "Calcul de la r�ponse instrumentale"
     set caption(spcaudace,gui,spc_rinstrumcorr_w)            "Correction de la r�ponse instrumentale"
     set caption(spcaudace,gui,spc_divri)                     "Division par la r�ponse intrumentale"


     #--- Menu Pipelines ---#
     set caption(spcaudace,gui,spc_pipelines)                 "Pipelines"
     set caption(spcaudace,gui,spc_pipelines_space)           "---------------------------------------------------------------------------"
     set caption(spcaudace,gui,spc_traite2rinstrum_w)         "1) Calcul de la r�ponse instrumentale"
     set caption(spcaudace,gui,spc_lampe2calibre_w)           "Calibrations d'une lampe spectrale"
     set caption(spcaudace,gui,spc_traite2srinstrum_w)        "Application des calibrations aux spectres (mode expert)"
     set caption(spcaudace,gui,spc_traitestellaire)           "2a) R�duction de spectres stellaires (mode simple)"
     set caption(spcaudace,gui,spc_traitenebula)              "2b) R�duction de spectres non stellaires"
     set caption(spcaudace,gui,spc_traite2scalibre_w)         "Application des calibrations (sans RI) aux spectres"
    # set caption(spcaudace,gui,spc_traitesimple2calibre_w)    "Pr�traitement simple -> Calibration"
    # set caption(spcaudace,gui,spc_traitesimple2rinstrum_w)   "Pr�traitement simple -> R�ponse instrumentale"
     set caption(spcaudace,gui,spc_geom2calibre_w)            "Corrections g�om�triques -> Calibration"
     set caption(spcaudace,gui,spc_geom2rinstrum_w)           "Corrections g�om�triques -> Correction instrumentale"
     set caption(spcaudace,gui,spc_specLhIII_w)               "R�duction des spectres Lhires III (vide)"

     #--- Menu Astrophysique ---#
     set caption(spcaudace,gui,spc_analyse)                   "Astrophysique"
     set caption(spcaudace,gui,spc_surveys)                   "Site Internet pour la pr�paration de surveys"
     set caption(spcaudace,gui,spc_bebuil)                    "Site Internet de liste d'�toiles Be"
     set caption(spcaudace,gui,spc_chimie)                    "Rep�rage des esp�ces atomiques"
     set caption(spcaudace,gui,spc_vradiale_w)                "Vitesse radiale"
     set caption(spcaudace,gui,spc_vhelio)                    "Vitesse h�liocentrique"
     set caption(spcaudace,gui,spc_vradialecorr_w)            "Vitesse radiale corrig�e de Vh�lio"
     set caption(spcaudace,gui,spc_vrmes_w)                   "Calculer le rapport V/R d'une raie"
     set caption(spcaudace,gui,spc_vexp_w)                    "Vitesse d'expension"
     set caption(spcaudace,gui,spc_vrot_w)                    "Vitesse de rotation"
     set caption(spcaudace,gui,spc_te)                        "Temp�rature �lectronique (automatique)"
     set caption(spcaudace,gui,spc_ne)                        "Densit� �lectronique (automatique)"
     set caption(spcaudace,gui,spc_npte_w)                    "Temp�rature �lectronique"
     set caption(spcaudace,gui,spc_npne_w)                    "Densit� �lectronique"
     set caption(spcaudace,gui,spc_ewcourbe_w)                "Courbe EW=f(t) d'une s�rie"
     set caption(spcaudace,gui,spc_ewdirw)                    "Extraction de EW avec des infos dans un fichier d'une s�rie"
     set caption(spcaudace,gui,spc_normahbeta)                "Normalisation par rapport � l'intensit� de la raie H-beta"
     set caption(spcaudace,gui,spc_spectrum)                  "SPECTRUM : Synth�se de spectres"

     #--- Menu Aide ---#
     set caption(spcaudace,gui,spc_aide)                      "Aide"
     set caption(spcaudace,gui,spc_version_w)                 "Version $spcaudace(version)"
     set caption(spcaudace,gui,spc_help)                      "Liste des fonctions de SpcAudACE"
     set caption(spcaudace,gui,spc_site)                      "Site Internet de SpcAudACE"
     set caption(spcaudace,gui,spc_about_w)                   "Auteur : Benjamin MAUCLAIRE"
     set caption(spcaudace,gui,spc_contrib_w)                 "Contributeurs : $spcaudace(contribs)."

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
#   Fin de la d�claration des textes localis�s (internationalisation)
#================================================================================

#================================================================================#
set presentation "SpcAudACE - version $spcaudace(version) @$spcaudace(author)\n"
return $presentation
#================================================================================#

