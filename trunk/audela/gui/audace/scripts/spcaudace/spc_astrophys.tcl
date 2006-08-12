
# Proc�dures d'exploitation astrophysique des spectes
# source $audace(rep_scripts)/spcaudace/spc_astrophys.tcl

#************* Liste des focntions **********************#
#
# spc_vradiale : calcul la vitesse radiale � partir de la FWHM de la raie mod�lis�e par une gaussienne
# spc_vexp : calcul la vitesse d'expansion � partir de la FWHM de la raie mod�lis�e par une gaussienne
# spc_vrot : calcul la vitesse de rotation � partir de la FWHM de la raie mod�lis�e par une gaussienne
# spc_npte : calcul la temp�rature �lectronique d'une n�buleuse
# spc_npne : calcul la densit� �lectronique d'une n�buleuse
# spc_ne : calcul de la densit� �lectronique. Fonction applicable pour les n�buleuses � spectre d'�mission.
# spc_te : calcul de la temp�rature �lectronique. Fonction applicable pour les n�buleuses � spectre d'�mission.
#
##########################################################



##########################################################
# Procedure de determination de la vitesse radiale en km/s � l'aide du d�calage d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 13-07-2006
# Date de mise � jour : 13-07-2006
# Arguments : delta_lambda lambda
##########################################################

proc spc_vradiale { args } {

   global audace
   global conf

   if { [llength $args] == 2 } {
       set delta_lambda [ lindex $args 0 ]
       set lambda [lindex $args 1 ]
       
       set vrad [ expr 299792.458*$delata_lambda/lambda ]
       ::console::affiche_resultat "La vitesse radiale de l'objet est : $vrad km/s\n"
       return $vrad
   } else {
       ::console::affiche_erreur "Usage: spc_vradiale delta_lambda lambda\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la temp�rature �lectronique d'une n�buleuse � raies d'�mission
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 13-08-2005
# Date de mise � jour : 13-08-2005
# Arguments : I_5007 I_4959 I_4363
# Mod�le utilis� : A. Acker, Astronomie, m�thodes et calculs, MASSON, p.104.
##########################################################

proc spc_npte { args } {

   global audace
   global conf

   if {[llength $args] == 3} {
     set I_5007 [ lindex $args 0 ]
     set I_4959 [ expr int([lindex $args 1 ]) ]
     set I_4363 [ expr int([lindex $args 2]) ]

     set R [ expr ($I_5007+$I_4959)/$I_4363 ]
     set Te [ expr (3.29*1E4)/(log($R/8.30)) ]
     ::console::affiche_resultat "Le temp�rature �lectronique de la n�buleuse est : $Te Kelvin\n"
     return $Te
   } else {
     ::console::affiche_erreur "Usage: spc_npte I_5007 I_4959 I_4363\n\n"
   }

}
#*******************************************************************************#


##########################################################
# Procedure de determination de la temp�rature �lectronique d'une n�buleuse � raies d'�mission
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 13-08-2005
# Date de mise � jour : 13-08-2005
# Arguments : Te I_6584 I_6548 I_5755
# Mod�le utilis� : Practical Amateur Spectroscopy,�Stephen F. TONKIN, Springer, p.164.
##########################################################

proc spc_npne { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set Te [ lindex $args 0 ]
     set I_6584 [ lindex $args 1 ]
     set I_6548 [ expr int([lindex $args 2 ]) ]
     set I_5755 [ expr int([lindex $args 3]) ]

     set R [ expr ($I_6584+$I_6548)/$I_5755 ]
     set Ne [ expr 1/(2.9*1E(-3))*((8.5*sqrt($Te)*10^(10800/$Te))/$R-1) ]
     ::console::affiche_resultat "Le densit� �lectronique de la n�buleuse est : $Ne Kelvin\n"
     return $Ne
   } else {
     ::console::affiche_erreur "Usage: spc_npne Te I_6584 I_6548 I_5755\n\n"
   }

}
#*******************************************************************************#




##########################################################
# Procedure de tracer de largeur �quivalente pour une s�rie de spectres
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 04-08-2005
# Date de mise � jour : 10-05-2006
# Arguments : nom g�n�rique des profils de raies normalis�s � 1, longueur d'onde de la raie (A), largeur de la raie (A), type de raie (a/e)
##########################################################

proc spc_ewcourbe { args } {

    global audace
    global conf
	global tcl_platform
    set ewfile "ewcourbe"
	set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
	set ext ".dat"

    if {[llength $args] == 4} {
	set nom_generic [ lindex $args 0 ]
	set lambda [lindex $args 1 ]
	set largeur_raie [lindex $args 2 ]
	set type_raie [lindex $args 3 ]

	set ldates ""
	set list_ew ""
	set intensite_raie 1
	set fileliste [ glob -dir $audace(rep_images) ${nom_generic}*$conf(extension,defaut) ]

	foreach fichier $fileliste {
	    set fichier [ file tail $fichier ]
	    ::console::affiche_resultat "\nTraitement de $fichier\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    set date [ lindex [buf$audace(bufNo) getkwd "MJD-OBS"] 1 ]
	    # Ne tient que des 4 premi�res d�cimales du jour julien et retranche 50000 jours juliens
	    lappend ldates [ expr int($date*10000.)/10000.-50000. ]
	    # lappend ldates [ expr $date-50000. ]
	    set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
	    set ldeb [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
	    set disp [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]

	    set ldeb [ expr $lambda-0.5*$largeur_raie ]
	    set lfin [ expr $lambda+0.5*$largeur_raie ]
	    lappend list_ew [ spc_ew $fichier $ldeb $lfin $type_raie ]
	}

	#--- Cr�ation du fichier de donn�es
	# ::console::affiche_resultat "$ldates \n $list_ew\n"
	set file_id1 [open "$audace(rep_images)/${ewfile}.dat" w+]
	foreach sdate $ldates ew $list_ew {
	    puts $file_id1 "$sdate\t$ew"
	}
	close $file_id1

	#--- Cr�ation du script de tracage avec gnuplot
	set titre "Evolution de la largeur equivalente au cours du temps"
	set legendey "Largeur equivalente (A)"
	set legendex "Date (JD-50000)"
	set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
	#exec echo "call \"${repertoire_gp}/gpx11.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
	set file_id2 [open "$audace(rep_images)/${ewfile}.gp" w+]
	puts $file_id2 "call \"${repertoire_gp}/gp_points.cfg\" \"$audace(rep_images)/${ewfile}.dat\" \"$titre\" * * * * * \"$audace(rep_images)/ew_courbe.png\" \"$legendex\" \"$legendey\" "
	close $file_id2
	if { $tcl_platform(os)=="Linux" } {	
	    set answer [ catch { exec gnuplot $audace(rep_images)/${ewfile}.gp } ]
	    ::console::affiche_resultat "$answer\n"
	} else {
	    #-- wgnuplot et pgnuplot doivent etre dans le rep gp de spcaudace
	    set answer [ catch { exec ${repertoire_gp}/gpwin32/pgnuplot.exe $audace(rep_images)/${ewfile}.gp } ]
	    ::console::affiche_resultat "$answer\n"
	}
	#set file_id3 [open "$audace(rep_images)/trace_gp.bat" w+]
	#puts $file_id3 "gnuplot \"${ewfile}.gp\" "
	#close $file_id3
	## exec gnuplot $repertoire_gp/run_gp
	#::console::affiche_resultat "\nEx�cuter dans un terminal : trace_gp.bat\n"

    } else {
	::console::affiche_erreur "Usage: spc_ewcourbe nom_g�n�rique_profils_normalis�s_fits lambda_raie largeur_raie a/e (absorption/�mission)\n\n"
    }
}
#*******************************************************************************#




