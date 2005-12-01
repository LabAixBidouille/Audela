
# Procédures d'exploitation astrophysique des spectes
# source $audace(rep_scripts)/spcaudace/spc_astrophys.tcl

#************* Liste des focntions **********************#
#
# vradial : calcul la vitesse radiale à partir de la FWHM de la raie modélisée par une gaussienne
# vexp : calcul la vitesse d'epansion à partir de la FWHM de la raie modélisée par une gaussienne
# npte : calcul la température électronique d'une nébuleuse
# npne : calcul la densité électronique d'une nébuleuse
# spcne : calcul de la densité électronique. Fonction applicable pour les nébuleuses à spectre d'émission.
# spcte : calcul de la température électronique. Fonction applicable pour les nébuleuses à spectre d'émission.
#
##########################################################


##########################################################
#  Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-08-2005
# Date de mise à jour : 13-08-2005
# Arguments : I_5007 I_4959 I_4363
# Modèle utilisé : A. Acker, Astronomie, méthodes et calculs, MASSON, p.104.
##########################################################

proc npte { args } {

   global audace
   global conf

   if {[llength $args] == 3} {
     set I_5007 [ lindex $args 0 ]
     set I_4959 [ expr int([lindex $args 1 ]) ]
     set I_4363 [ expr int([lindex $args 2]) ]

     set R [ expr (I_5007+I_4959)/I_4363 ]
     set Te [ expr (3.29*1E4)/(log(R/8.30)) ]
     ::console::affiche_resultat "Le température électronique de la nébuleuse est : $Te Kelvin\n"
     return $Te
   } else {
     ::console::affiche_erreur "Usage: npte I_5007 I_4959 I_4363\n\n"
   }

}
##########################################################


##########################################################
#  Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-08-2005
# Date de mise à jour : 13-08-2005
# Arguments : Te I_6584 I_6548 I_5755
# Modèle utilisé : Practical Amateur Spectroscopy, Stephen F. TONKIN, Springer, p.164.
##########################################################

proc npne { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set Te [ lindex $args 0 ]
     set I_6584 [ lindex $args 1 ]
     set I_6548 [ expr int([lindex $args 2 ]) ]
     set I_5755 [ expr int([lindex $args 3]) ]

     set R [ expr (I_6584+I_6548)/I_5755 ]
     set Ne [ expr 1/(2.9*1E(-3))*((8.5*sqrt(Te)*10^(10800/Te))/R-1) ]
     ::console::affiche_resultat "Le densité électronique de la nébuleuse est : $Ne Kelvin\n"
     return $Ne
   } else {
     ::console::affiche_erreur "Usage: npne Te I_6584 I_6548 I_5755\n\n"
   }

}
##########################################################




##########################################################
#  Procedure de tracer de largeur équivalente pour une série de spectres
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 04-08-2005
# Date de mise à jour : 04-08-2005
# Arguments : nom générique des profils de raies normalisés à 1, longueur d'onde de la raie (A), largeur de la raie (A), type de raie (a/e)
##########################################################

proc ewcourbe { args } {

    global audace
    global conf

    if {[llength $args] == 4} {
	set nom_generic [ lindex $args 0 ]
	set lambda [lindex $args 1 ]
	set largeur [lindex $args 2 ]
	set type_raie [lindex $args 3 ]

	set ldates ""
	set list_ew ""
	set intensite_raie 1
	set fileliste [ glob ${nom_generic}*$conf(extension,defaut) ]

	foreach fichier $fileliste {
	    buf$audace(bufNo) load $fichier
	    set date [ lindex [buf$audace(bufNo) getkwd "MJD-OBS"] 1 ]
	    # Ne tient que des 4 premières décimales du jour julien et retranche 50000 jours juliens
	    lappend $ldates [ expr int($date*10000)/10000-50000 ]
	    set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
	    set ldeb [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
	    set disp [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]

	    set ldeb [ expr $lambda-0.5*$largeur_raie ]
	    set lfin [ expr $lambda+0.5*$largeur_raie ]
	    lappend $list_ew [ spcew $fichier $ldeb $lfin $type_raie ]
	}

	# Création du fichier de données
	set file_id [open "$audace(rep_images)/$filename" w+]
	#for {set k 0} {$k<$len} {incr k}
	foreach sdate $ldates ew $list_ew {
	    puts $file_id "$sdate\t$ew"
	}
	close $file_id

	# Création du script de tracage avec gnuplot
	set titre "Évolution de la largeur équivalente au cours du temps"
	set legendey "Largeur équivalente (A)"
	set legendex "Date (jours juliens-50000)"
	set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
	#exec echo "call \"${repertoire_gp}/gpx11.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
	set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
	puts $file_id "call \"${repertoire_gp}/gp_points.cfg\" \"${largeurs_equivalentes}.dat\" \"$titre\" * * * * * \"largeurs_equivalentes.png\" \"$legendex\" \"$legendey\" "
	close $file_id
	set file_id [open "$audace(rep_images)/trace_gp.bat" w+]
	puts $file_id "gnuplot \"${spcfile}.gp\" "
	close $file_id
	# exec gnuplot $repertoire_gp/run_gp
	::console::affiche_resultat "Exécuter dans un terminal : trace_gp.bat\n"

    } else {
	::console::affiche_erreur "Usage: centerg nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
    }
}
#****************************************************************#







