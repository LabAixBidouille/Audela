####################################################################
# Spécification des variables utilisées par spcaudace
# 
####################################################################


#----------------------------------------------------------------------------------#
#--- Initialisation des variables d'environnement d'SpcAudace :
global audela audace
global spcaudace

#--- Version d'SpcAudace :
set spcaudace(version) "04a-03-2007"
# ::audace::date_sys2ut ?Date?
#set spcaudace(version) [ file mtime $spcaudace(repspc) ]

#--- Extension des fichiers :
set spcaudace(extdat) ".dat"
set spcaudace(exttxt) ".txt"
set spcaudace(extvspec) ".spc"

#--- Répertoire d'SpcAudace :
if { [regexp {1.3.0} $audela(version) match resu ] } {
    set spcaudace(repspc) [ file join $audace(rep_scripts) spcaudace ]
} else {
    set spcaudace(repspc) [ file join $audace(rep_plugin) tool spectro spcaudace ]
}

#--- Répertoire de Gnuplot :
set spcaudace(repgp) [ file join $spcaudace(repspc) gp ]

#--- Répertoire des données chimiques :
set spcaudace(repchimie) [ file join $spcaudace(repspc) data chimie ]

#--- Répertoire de la bibliothèque spectrale :
set spcaudace(rep_spcbib) [ file join $spcaudace(repspc) data bibliotheque_spectrale ]

#--- Valeur de paramètres des euristhiques algorithmiques :
#-- Hauteur max d'un spectre 2D pour ne considérer que du slant :
set spcaudace(hmax) 300



#----------------------------------------------------------------------------------#
# Couleurs et répertoires : (pris dans spc_cap.tcl et toujours présent -> migration à terminer)

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

