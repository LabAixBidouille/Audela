#--- definition of captions
#--- definition des legendes
if {[string compare $langage english] ==0 } {
     set captionspc(main_title) "Aud'ACE spectrum analyser"
     set captionspc(acq) "CCD Acquisition"
     set captionspc(open_fitfile) "Create a ray profile"
     set captionspc(loadspcfit) "Load a fits ray profile"
     set captionspc(loadspctxt) "Load a text ray profile"
     set captionspc(savespc) "Save a ray profile"
     set captionspc(pixel) "Pixel"
     set captionspc(angstrom) "Angstrom"
     set captionspc(angstroms) "Angstroms"
     set captionspc(intensity) "Intensity"
     set captionspc(adu) "ADU"
     set captionspc(spc_profile) "SPC profile"
     set captionspc(writeps) "Export to Postscript"
     set captionspc(file) "File"
     set captionspc(print_on) "Print with "

     #--- Menu Etalon ---#
     set captionspc(calibration) "Calibration"
     set captionspc(cali_lambda) "Wavelength calibration"
     set captionspc(cali_flux) "Flux calibration"

     #--- Menu Mesures ---#
     set captionspc(mesures) "Measures"
     set captionspc(mes_especes) "Atomic speces finding"
     set captionspc(mes_TE) "Electronic temperature"
     set captionspc(mes_DE) "Electronique density"

     set captionspc(wait) "Wait..."
     set captionspc(quitspc) "Quit SPC workspace"
}


if {[string compare $langage french] ==0 } {
     set captionspc(main_title) "Aud'ACE analyseur de spectres "
     set captionspc(acq) "Acquisition CCD"
     #--- Menu File ---#
     set captionspc(open_fitfile) "Créer un profil de raie"
     set captionspc(loadspcfit) "Charger un profil de raie fits"
     set captionspc(loadspctxt) "Charger un profil de raie texte"
     set captionspc(savespc) "Sauver un profil de raie"
     set captionspc(pixel) "Pixel"
     set captionspc(angstrom) "Angstrom"
     set captionspc(angstroms) "Angstroms"
     set captionspc(intensity) "Intensite"
     set captionspc(adu) "ADU"
     set captionspc(spc_profile) "profil SPC"
     set captionspc(writeps) "Exporter en Postscript"
     set captionspc(file) "Fichier"
     set captionspc(print_on) "Imprimer avec "

     #--- Menu Etalon ---#
     set captionspc(calibration) "Calibration"
     set captionspc(cali_lambda) "Étalonnage en lambda"
     set captionspc(cali_flux) "Étalonnage en flux"

     #--- Menu Mesures ---#
     set captionspc(mesures) "Mesures"
     set captionspc(mes_especes) "Repérage des espèces atomiques"
     set captionspc(mes_TE) "Température électronique"
     set captionspc(mes_DE) "Densité électronique"

     set captionspc(wait) "En cours..."
     set captionspc(quitspc) "Quitter la fenetre SPC"
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
