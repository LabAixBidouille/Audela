####################################################################
# Spécification des variables utilisées par spcaudace
#
####################################################################

# Mise a jour $Id: spc_var.tcl,v 1.10 2009-07-13 00:20:21 bmauclaire Exp $


#----------------------------------------------------------------------------------#
#--- Initialisation des variables d'environnement d'SpcAudace :
global audela audace
global spcaudace

#--- Version d'SpcAudace :
set spcaudace(version) "1.5.3 - 13/06/2009"
# ::audace::date_sys2ut ?Date?
#set spcaudace(version) [ file mtime $spcaudace(repspc) ]


#--- Liste des contributeurs au développement d'SpcAudace :
set spcaudace(author) "Benjamin MAUCLAIRE"
set spcaudace(contribs) "Alain Klotz, Michel Pujol, Patrick Lailly, François Cochard"


#--- Extension des fichiers :
set spcaudace(extdat) ".dat"
set spcaudace(exttxt) ".txt"
set spcaudace(extvspec) ".spc"

#--- Répertoire d'SpcAudace :
if { [regexp {1.3.0} $audela(version) match resu ] } {
   set spcaudace(rep_spc) [ file join $audace(rep_scripts) spcaudace ]
} else {
   set spcaudace(rep_spc) [ file join $audace(rep_plugin) tool spcaudace ]
}


#--- Chemin des répertoires :
#-- Répertoire des outils : Gnuplot, Spectrum... :
set spcaudace(repgp) [ file join $spcaudace(rep_spc) gp ]
set spcaudace(spectrum) [ file join $spcaudace(rep_spc) plugins spectrum ]

#-- Répertoire des données chimiques :
set spcaudace(repchimie) [ file join $spcaudace(rep_spc) data chimie ]
set spcaudace(reptelluric) [ file join $spcaudace(rep_spc) data telluric ]
set spcaudace(filetelluric) "$spcaudace(reptelluric)/h2o_calibrage.txt"
#set spcaudace(filetelluric) "$spcaudace(reptelluric)/h2o_calibrage_140b.txt"
#-- Liste des methodes de calibrations telluriques :
set spcaudace(calo_meths) { 1 2 4 5 6 }
#- 1 : spectre initial juste linearise ; toutes configs ; ne pas enlever de la liste.
#- 2 : decalage d'une valeur egale au decalage moyen mean_shift mesure ; toutes configs.
#- 3 : recallibrage de degre 3 avec les raies telluriques, puis decalage de RMS et linearisation ; que kaf1600.
#- 4 : recallibrage de degre 2 avec les raies telluriques, reechantillonne et linearisation a la volee ; que kaf400.
#- 5 : decalage d'une valeur egale au RMS mesure des raies ; toutes configs.
#- 6 : decalage d'une valeur egale au RMS*0.5 mesure des raies ; kaf1600.
#- 7 : Recalage progressif par iterations pour minimiser le RMS mesure ; kaf1600 optionnel.

#-- Effacement des profils des differentes methodes de calibration tellurique :
set spcaudace(flag_rmcalo) "o"

#-- Superflat binne et normalise :
set spcaudace(binned_flat) "n"

#-- Répertoire de la bibliothèque spectrale :
set spcaudace(rep_spcbib) [ file join $spcaudace(rep_spc) data bibliotheque_spectrale ]

#-- Répertoire de la calibration-chimie :
set spcaudace(rep_spccal) [ file join $spcaudace(rep_spc) data calibration_lambda ]


#--- Fichiers tulisés :
set spcaudace(sp_eau) "h2o_6500_6700.fit"


#--- Répertoire de la calibration-chimie :
#set spcaudace(motsheader) [ list "OBJNAME" "OBSERVER" "ORIGIN" "TELESCOP" "EQUIPMEN" ]
#set spcaudace(motsheaderdef) [ list "Current name of the object" "Observer name" "Origin place of FITS image" "Telescop" "System which created data via the camera" ]
set spcaudace(motsheader) [ list "OBJNAME" "TELESCOP" "EQUIPMEN" ]
set spcaudace(motsheaderdef) [ list "Current name of the object" "Telescop" "System which created data via the camera" ]


#--- Lieu de la documentation d'SpcAudACE :
set spcaudace(spcdoc) [ file join $spcaudace(rep_spc) doc liste_fonctions.html ]
set spcaudace(sitedoc) "http://bmauclaire.free.fr/spcaudace/fonctions.html"


#--- Site de bases de données :
set spcaudace(webpage) "http://bmauclaire.free.fr/spcaudace/"
set spcaudace(sitebess) "http://basebe.obspm.fr/basebe/"
set spcaudace(siteuves) "http://www.sc.eso.org/santiago/uvespop/interface.html"
set spcaudace(sitesimbad) "http://simbad.u-strasbg.fr/simbad/sim-fid"
set spcaudace(sitesurveys) "http://bmauclaire.free.fr/astronomie/research/"
set spcaudace(sitebebuil) "http://astrosurf.com/buil/us/becat.htm"
set spcaudace(sitearasbeam) "http://arasbeam.free.fr/"


#--- Option prédéfinies dans les pipelines :
set spcaudace(methsel) "moy"
set spcaudace(methreg) "spc"
set spcaudace(methsky) "med"
set spcaudace(methbin) "rober"


#--- Valeur de paramètres des euristhiques algorithmiques :
#-- Degré du polynome pour l'extraction du continuum :
set spcaudace(degpoly_cont) 5
#-- Fraction des bords ignorés dans certains calculs (spc_divri...) pour la détermination du Imax du profil :
set spcaudace(pourcent_bord) 0.15
#-- Taux de croissance de l'intensité pour considérer que l'on passe du bord (proche de 0) au continuum :
set spcaudace(croissbord) 0.2
#-- Tolérence sur l'écart à l'intensité maximale (spc_divri) : 5%
set spcaudace(imax_tolerence) 1.05
#-- Largeur spectrale considérée comme basse résolution :
set spcaudace(bande_br) 1000.0
#-- Fraction des bords ignorés dans la détermination de l'angle de TILT :
set spcaudace(pourcent_bordt) 0.10
#-- Fraction des bords mis à 0 du résultat de la division avant lissage pour la RI :
#- 0.0127 - 0.04
set spcaudace(bordsnuls) 0.04
#-- Dispersion maximale pour un spectre haute résolution (extraction continuum) :
set spcaudace(dmax) 0.5
#-- Bande spectrale considérée comme basse résolution 500 A :
set spcaudace(bp_br) 500.
#-- Hauteur max d'un spectre 2D pour ne considérer que du slant :
set spcaudace(hmax) 300
#-- Pourcentage de l'intensité moyenne en deça de laquelle il y a mise a 0 (spc_pwl*) :
set spcaudace(nulpcent) 0.6
#-- Epaisseur de binning en cas de sélection manuelle de raie de calibration :
set spcaudace(epaisseur_bin) 100.
#-- Nombde de coupes verticales pour les detections de profil :
#set spcaudace(nb_coupes) 5
set spcaudace(nb_coupes) 10
#-- Epaisseur de detection (verticale, latérale) pour les tranches de détection lors de spc_findtilt, spc_detect (5% de naxis2) :
set spcaudace(epaisseur_detect) 0.05
#-- Epaisseur binning par défaut :
set spcaudace(largeur_binning) 7
#-- Angle limite en degrès autorisé pour un tilt :
#set spcaudace(tilt_limit) 0.746
#set spcaudace(tilt_limit) 1.5
#set spcaudace(tilt_limit) 2.
set spcaudace(tilt_limit) 4.
#-- Rapport limit de I_moy_fond_de_ciel/I_moy pour détectivité de l'angle... : NON UTILISE
#set spcaudace(rapport_imoy) 0.97
#-- Linéarisation automatique de la loi de calibration en longueur d'onde :
set spcaudace(linear_cal) "o"
#-- Elimination des bords "nuls" :
set spcaudace(rm_edges) "o"
#-- Largeur du filtrage SavGol pour la recherche des raies telluriques :
set spcaudace(largeur_savgol) 28
#-- Demi-largeur (anstroms) de plage de recherche des raies telluriques (spc_calibretelluric) :
set spcaudace(dlargeur_eau) 0.5
#-- Coefficient de uncosmic
set spcaudace(uncosmic) 0.85
#-- Largeur des raies detectees (spc_findbiglines) : 10 ; 8
set spcaudace(largeur_raie_detect) 8


#----------------------------------------------------------------------------------#
# Couleurs et répertoires : (pris dans spc_cap.tcl et toujours présent -> migration à terminer)
#--- Liste des couleurs disponibles pour les graphes :
set spcaudace(lgcolors) [ list "darkblue" "green" "lightblue" "red" "blue" "yellow" ]
#-- Indice de la couleur par defaut (darkblue) :
set spcaudace(gcolor) 0
#-- Liste de noms des profils affichés :
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

