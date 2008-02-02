####################################################################
# Sp�cification des variables utilis�es par spcaudace
# 
####################################################################

# Mise a jour $Id: spc_var.tcl,v 1.19 2008-02-02 21:53:30 bmauclaire Exp $


#----------------------------------------------------------------------------------#
#--- Initialisation des variables d'environnement d'SpcAudace :
global audela audace
global spcaudace

#--- Version d'SpcAudace :
set spcaudace(version) "1.2.1 - 29/12/2007"
#set spcaudace(version) "1.2.0 - 10/10/2007"
# ::audace::date_sys2ut ?Date?
#set spcaudace(version) [ file mtime $spcaudace(repspc) ]


#--- Liste des contributeurs au d�veloppement d'SpcAudace :
set spcaudace(author) "Benjamin MAUCLAIRE"
set spcaudace(contribs) "Alain Klotz, Michel Pujol, Patrick Lailly, Fran�ois Cochard"


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


#--- R�pertoire des outils : Gnuplot, Spectrum... :
set spcaudace(repgp) [ file join $spcaudace(repspc) gp ]
set spcaudace(spectrum) [ file join $spcaudace(repspc) plugins spectrum ]

#--- R�pertoire des donn�es chimiques :
set spcaudace(repchimie) [ file join $spcaudace(repspc) data chimie ]
set spcaudace(reptelluric) [ file join $spcaudace(repspc) data telluric ]
# set spcaudace(filetelluric) "$spcaudace(reptelluric)/h2o_calibrage_temp.txt"
set spcaudace(filetelluric) "$spcaudace(reptelluric)/h2o_calibrage.txt"

#--- R�pertoire de la biblioth�que spectrale :
set spcaudace(rep_spcbib) [ file join $spcaudace(repspc) data bibliotheque_spectrale ]

#--- R�pertoire de la calibration-chimie :
set spcaudace(rep_spccal) [ file join $spcaudace(repspc) data calibration_lambda ]


#--- R�pertoire de la calibration-chimie :
#set spcaudace(motsheader) [ list "OBJNAME" "OBSERVER" "ORIGIN" "TELESCOP" "EQUIPMEN" ]
#set spcaudace(motsheaderdef) [ list "Current name of the object" "Observer name" "Origin place of FITS image" "Telescop" "System which created data via the camera" ]
set spcaudace(motsheader) [ list "OBJNAME" "TELESCOP" "EQUIPMEN" ]
set spcaudace(motsheaderdef) [ list "Current name of the object" "Telescop" "System which created data via the camera" ]


#--- Lieu de la documentation d'SpcAudACE :
set spcaudace(spcdoc) [ file join $spcaudace(repspc) doc liste_fonctions.html ]
set spcaudace(sitedoc) "http://bmauclaire.free.fr/astronomie/softs/audela/spcaudace/liste_fonctions.html"


#--- Site de bases de donn�es :
set spcaudace(sitebess) "http://basebe.obspm.fr/basebe/"
set spcaudace(siteuves) "http://www.sc.eso.org/santiago/uvespop/interface.html"
set spcaudace(sitesimbad) "http://simbad.u-strasbg.fr/simbad/sim-fid"
set spcaudace(sitesurveys) "http://bmauclaire.free.fr/astronomie/research/"
set spcaudace(sitebebuil) "http://astrosurf.com/buil/us/becat.htm"


#--- Valeur de param�tres des euristhiques algorithmiques :
#-- Fraction des bords ignor�s dans certains calculs (spc_divri...) pour la d�termination du Imax du profil :
set spcaudace(pourcent_bord) 0.15
#-- Tol�rence sur l'�cart � l'intensit� maximale (spc_divri) : 5%
set spcaudace(imax_tolerence) 1.05
#-- Fraction des bords ignor�s dans la d�termination de l'angle de TILT :
set spcaudace(pourcent_bordt) 0.10
#-- Fraction des bords mis � 0 du r�sultat de la division avant lissage pour la RI :
#- 0.0127 - 0.04
set spcaudace(bordsnuls) 0.04
#-- Dispersion maximale pour un spectre haute r�solution (extraction continuum) :
set spcaudace(dmax) 0.5
#-- Bande spectrale consid�r�e comme basse r�solution 500 A :
set spcaudace(bp_br) 500.
#-- Hauteur max d'un spectre 2D pour ne consid�rer que du slant :
set spcaudace(hmax) 300
#-- Pourcentage de l'intensit� moyenne en de�a de laquelle il y a mise a 0 (spc_pwl*) :
set spcaudace(nulpcent) 0.6
#-- Epaisseur de binning en cas de s�lection manuelle de raie de calibration :
set spcaudace(epaisseur_bin) 100.
#-- Nombde de coupes verticales pour les detections de profil :
#set spcaudace(nb_coupes) 5
set spcaudace(nb_coupes) 10
#-- Epaisseur de detection (verticale, lat�rale) pour les tranches de d�tection lors de spc_findtilt, spc_detect (5% de naxis2) :
set spcaudace(epaisseur_detect) 0.05
#-- Epaisseur binning par d�faut :
set spcaudace(largeur_binning) 7
#-- Angle limit en degr�s autoris� pour un tilt :
#set spcaudace(tilt_limit) 0.746
#set spcaudace(tilt_limit) 1.5
#set spcaudace(tilt_limit) 2.
set spcaudace(tilt_limit) 4.
#-- Rapport limit de I_moy_fond_de_ciel/I_moy pour d�tectivit� de l'angle... : NON UTILISE
#set spcaudace(rapport_imoy) 0.97
#-- Lin�arisation automatique de la loi de calibration en longueur d'onde :
set spcaudace(linear_cal) "o"
#-- Largeur du filtrage SavGol pour la recherche des raies telluriques :
set spcaudace(largeur_savgol) 28
#-- Demi-largeur (anstroms) de plage de recherche des raies telluriques (spc_calibretelluric) :
set spcaudace(dlargeur_eau) 0.5
#-- Coefficient de uncosmic
set spcaudace(uncosmic) 0.85

#----------------------------------------------------------------------------------#
# Couleurs et r�pertoires : (pris dans spc_cap.tcl et toujours pr�sent -> migration � terminer)
#--- Liste des couleurs disponibles pour les graphes :
set spcaudace(lgcolors) [ list "darkblue" "green" "lightblue" "red" "blue" "yellow" ]
#-- Indice de la couleur par defaut (darkblue) :
set spcaudace(gcolor) 0
#-- Liste de noms des profils affich�s :
set spcaudace(gloaded) [ list ]


#--- definition of colors
#--- definition des couleurs
set colorspc(back) #123456
#-- Ancien fond des menus : #D9D9D9
set colorspc(backmenu) #ECE9D8
set colorspc(back_infos) #FFCCDD
set colorspc(fore_infos) #000000
#-- Ancien fond du contour graphe : #CCCCCC, #DCDAD5
set colorspc(back_graphborder) #DCDAD5
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

