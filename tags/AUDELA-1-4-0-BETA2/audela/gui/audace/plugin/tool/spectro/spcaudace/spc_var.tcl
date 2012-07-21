####################################################################
# Sp�cification des variables utilis�es par spcaudace
# 
####################################################################


#----------------------------------------------------------------------------------#
#--- Initialisation des variables d'environnement d'SpcAudace :
global audela audace
global spcaudace

#--- Version d'SpcAudace :
set spcaudace(version) "20b-03-2007"
# ::audace::date_sys2ut ?Date?
#set spcaudace(version) [ file mtime $spcaudace(repspc) ]

#--- Liste des contributeurs au d�veloppement d'SpcAudace :
set spcaudace(author) "Benjamin MAUCLAIRE"
set spcaudace(contribs) "Alain Klotz, Michel Pujol, Patrick Lailly"


#--- Extension des fichiers :
set spcaudace(extdat) ".dat"
set spcaudace(exttxt) ".txt"
set spcaudace(extvspec) ".spc"

#--- R�pertoire d'SpcAudace :
if { [regexp {1.3.0} $audela(version) match resu ] } {
    set spcaudace(repspc) [ file join $audace(rep_scripts) spcaudace ]
} else {
    set spcaudace(repspc) [ file join $audace(rep_plugin) tool spectro spcaudace ]
}

#--- R�pertoire de Gnuplot :
set spcaudace(repgp) [ file join $spcaudace(repspc) gp ]

#--- R�pertoire des donn�es chimiques :
set spcaudace(repchimie) [ file join $spcaudace(repspc) data chimie ]

#--- R�pertoire de la biblioth�que spectrale :
set spcaudace(rep_spcbib) [ file join $spcaudace(repspc) data bibliotheque_spectrale ]

#--- R�pertoire de la calibration-chimie :
set spcaudace(rep_spccal) [ file join $spcaudace(repspc) data calibration_lambda ]

#--- R�pertoire de la calibration-chimie :
set spcaudace(motsheader) [ list "OBJNAME" "OBSERVER" "ORIGIN" "TELESCOP" "EQUIPMEN" ]
set spcaudace(motsheaderdef) [ list "Current name of the object" "Observer name" "Origin place of FITS image" "Telescop" "System which created data via the camera" ]

#--- Lieu de la documentation d'SpcAudACE :
set spcaudace(spcdoc) [ file join $spcaudace(repspc) doc liste_fonctions.html ]
set spcaudace(sitedoc) "http://bmauclaire.free.fr/astronomie/softs/audela/spcaudace/liste_fonctions.html"


#--- Valeur de param�tres des euristhiques algorithmiques :
#-- Hauteur max d'un spectre 2D pour ne consid�rer que du slant :
set spcaudace(hmax) 300



#----------------------------------------------------------------------------------#
# Couleurs et r�pertoires : (pris dans spc_cap.tcl et toujours pr�sent -> migration � terminer)

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




#----------------------------------------------------------------------------------#
