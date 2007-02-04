####################################################################
# Sp�cification des variables utilis�es par spcaudace
# 
####################################################################


#----------------------------------------------------------------------------------#
#--- Initialisation des variables d'environnement d'SpcAudace :
global audela audace
global spcaudace

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
if { [regexp {1.3.0} $audela(version) match resu ] } {
    set spcaudace(repgp) [ file join $audace(rep_scripts) spcaudace gp ]
} else {
    set spcaudace(repgp) [ file join $audace(rep_plugin) tool spectro spcaudace gp ]
}
#--- R�pertoire des donn�es chimiques :
if { [regexp {1.3.0} $audela(version) match resu ] } {
    set spcaudace(repchimie) [ file join $audace(rep_scripts) spcaudace data chimie ]
} else {
    set spcaudace(repchimie) [ file join $audace(rep_plugin) tool spectro spcaudace data chimie ]
}


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

