
# Procédures d'exploitation astrophysique des spectres

# Mise a jour $Id$



#************* Liste des focntions **********************#
#
# spc_periodogram : cree un periodogram a partir d'un fichier texte a 2 colonnes.
# spc_vdoppler : determination de la vitesse radiale en km/s à l'aide du décalage d'une raie
# spc_vhelio : calcul de la vitesse héliocentrique pour une correction de la vitesse radiale
# spc_vradiale : calcul la vitesse radiale à partir de la FWHM de la raie modélisée par une gaussienne
# spc_vradialecorr : determination de la vitesse radiale en km/s a l'aide du décalage d'une raie
# spc_vexp : calcul la vitesse d'expansion à partir de la FWHM de la raie modélisée par une gaussienne
# spc_vrot : calcul la vitesse de rotation à partir de la FWHM de la raie modélisée par une gaussienne
# spc_npte : calcul la température électronique d'une nébuleuse
# spc_npne : calcul la densité électronique d'une nébuleuse
# spc_ne : calcul de la densité électronique. Fonction applicable pour les nébuleuses à spectre d'émission.
# spc_te : calcul de la température électronique. Fonction applicable pour les nébuleuses à spectre d'émission.
# spc_ewcourbe : tracer de largeur équivalente pour une série de spectres dans le répertoire de travail
# spc_ewcourbe_opt : tracer de largeur équivalente pour une série de spectres dans le répertoire de travail
# spc_ewdirw : tracer de largeur équivalente pour une série de spectres dans le répertoire de travail
# spc_ew : calcul de la largeur équivalente d'une raie (fait appel à l'algorithme spc_ew3)
# spc_ew1 : détermination de la largeur équivalente d'une raie spectrale modelisee par une gaussienne.
# spc_ew2 : calcul de la largeur équivalente d'une raie par calcul d'air et avec calcul d'erreur
# spc_ew3 : calcul de la largeur équivalente d'une raie avec determination des limites par intersection au continuum d'une gaussienne
# spc_autoew4 : calcul la largeur equivalenbte d'une raie autmatique avec determiantion des limites et normalisation
# spc_autoew3 : calcul automatique de la largeur equivalente et determine ldeb et lfin par intersection du spectre filtre passe bas avec la valeur icont du spectre normalisé.
# spc_autoew2 : calcul automatique de la largeur equivalente avec intersection au continuum et algo spc_ew3
# spc_autoew1 : calcul automatique de la largeur equivalente avec intersection a 1.0
# spc_autoew : calcul automatique de la largeur equivalente avec l'algo spc_autoew3
# spc_vrmes : calcul du rapport V/R d'intensités d'une raie à deux pics.
#
##########################################################



#############################################################################################

# Auteur : Patrick LAILLY
# Date de création : 1-09-10
# Date de modification : 10-06-11
# cette procédure calcule le  periodogramme associé à la mesure d'une quantité physique en fonction du temps calendaire  
# 3 arguments  d'entree obligatoires : le nom du fichier dat contenant les donnees mesurees, l'unite utilisee pour la
# mesure du temps calendaire, nature de la quantite physique mesuree
# 4 arguments d'entree facultatifs :  nombres de periodes plausibles qui seront affichees a la console (valeur par défaut : 10),  borne inferieure a la periode recherchée (valeur par défaut : 0.), periode maximum (valeur par defaut : duree d'enregistrement des mesures), estimation d'une borne inférieure au pas d'echantillonage du periodogramme (valeur par defaut =(pe#riod_max-period_min) /(nb_data*30 ). 
# la procedure retourne le nom du fichier contenant les echantillons du periodogramme et cree un fichier png donnant le graphique du
# periodogramme
# L'algorithme utilise est celui decrit par Scargle (Astrophys. J., 263:835-853, 1982)
# Exemple : spc_periodogram data.dat "jours juliens" "vitesse radiale (m/s)"
# Exemple : spc_periodogram data.dat jour "vitesse radiale (m/s)"
# Exemple : spc_periodogram data.dat jour "vitesse radiale (m/s)" 19
# Exemple : spc_periodogram data.dat jour "vitesse radiale (m/s)" 19 2.
# Exemple : spc_periodogram data.dat jour "vitesse radiale (m/s)" 19 2. 5.
# Exemple : spc_periodogram data.dat jour "vitesse radiale (m/s)" 19 2. 5. .01
###########################################################################################

proc spc_periodogram { args } {
   global audace spcaudace
   ###########variable environnement
   set precision .1
   set fileout periodogram.dat
   set nargs [ llength $args ]
   if { $nargs <=7 && $nargs >2 } {
      set nom_dat [ lindex $args 0 ]
      set unit_temps [ lindex $args 1 ]
      set measured_quantity [ lindex $args 2 ]
      set nb_printed_period 10
      set period_min 0.01
      
      if { $nargs >= 4 } {
	 set nb_printed_period [ lindex $args 3 ]
      }
      if { $nargs >= 5 } {
	 set period_min [ lindex $args 4 ]
      }
      if { $nargs >= 6 } {
         set period_max [ lindex $args 5 ]
      }
      if { $nargs == 7 } {
         set sample_min [ lindex $args 6 ]
      }
      # regler ici le pb de la chronologie des donnees entrees
      #set periodog_filename [ spc_periodog $nom_dat $unit_temps $nb_period ]
      # lecture du fichier dat
      set input [open "$audace(rep_images)/$nom_dat" r]
      set contents [split [read $input] \n]
      close $input
      set nb_echant [llength $contents]
      # modification ad hoc : a comprendre !!!!!!!!!!!!!!!!!!!!!!!!
      set nb_echant [ expr $nb_echant -1 ]
      set nb_echant_1 [ expr $nb_echant - 1 ] 
      set abscisses [ list ]
      set ordonnees_orig [ list ]
      for {set k 0} { $k < $nb_echant } {incr k} {
	 set ligne [lindex $contents $k]
	 set x [lindex $ligne 0]
	 set y [lindex $ligne 1]
	 #::console::affiche_resultat " x= $x   y= $y \n"
	 lappend abscisses [lindex $ligne 0] 
	 lappend ordonnees_orig [lindex $ligne 1] 
      }
      set temps_max [ expr [ lindex $abscisses $nb_echant_1 ] - [ lindex $abscisses 0 ] ]
      # elimination de la composante continue
      set dc 0.
      for {set k 0} { $k < $nb_echant } {incr k} {
	 set dc [ expr $dc + [ lindex $ordonnees_orig $k ] ]
      }
      set dc [ expr $dc / $nb_echant ]
      set ordonnees [ list ]
      for {set k 0} { $k < $nb_echant } {incr k} {
	 lappend ordonnees [ expr [ lindex $ordonnees_orig $k ] - $dc ]	
      }
      if { $nargs < 6 } {
	 set period_max [ expr $temps_max * .5 ]
      }
      if { $period_min > $period_max } {
	 ::console::affiche_erreur "spc_periodogram : la periode minimale $period_min est plus grande que la periode maximale $period_max \n\n"
         return ""
      }
      set larg_interv [ expr ( $period_max - $period_min ) * 1. ]
      if { $nargs < 7 } {
	 set sample_min [ expr $larg_interv / (30 * $nb_echant) ]
      }
      # fin des entrees
      # recherche du nombre maximum (sous forme de puissance de 2 ) de subdivisions de l'intervalle des periodes considerees
      for { set n 0 } { $n < 20 } { incr n } {
	 set nn $n
	 if { [ expr $larg_interv / ( 2**$n ) ] < $sample_min } {
	    #::console::affiche_resultat "on ne raffine plus l'echantillonage : le seuil bas est atteint pour n= $n, sample_min= $sample_min\n\n"
	    #if { $n == 8 } {
	    #set last_period $period_max
	    #}
	    break
      	}
      }
      set nn [ expr $nn + 1 ]
      if { $nn < 8 } {
      # dans ce cas sample_min apparait trop grossier
	 ::console::affiche_erreur "spc_periodogram : la valeur specifiee pour le pas d'echantillonage $sample_min apparait trop grossiere : le programme va la changer  \n\n"
	 set nn 8
      }
      set llperiod [ list ] 
      set lldensity [ list ]
      #premier echantillonage avec n=8
      set n 8
      while { $n < 20 } {
	 if { $period_min > $period_max } {
	    ::console::affiche_erreur "spc_periodogram : la periode minimale $period_min est plus grande que la periode maximale $period_max \n\n"
	    return ""
	 }
	 #::console::affiche_resultat "n= $n  \n\n"
	 set lperiodog [ spc_calperiodog $abscisses $ordonnees $period_min $period_max $n $unit_temps]
	 set lperiod [ lindex $lperiodog 0 ]
	 set ldensity [ lindex $lperiodog 1 ]
	 set ll [ llength $lperiod ]
	 #parcours du periodogramme en sens inverse pour voir jusqu'ou l'echantillonage est suffisamment representatif
	 # on n'examine que les noeuds interieurs et il y en a ll-2
	 set last_period indefini
	 for { set i 2 } { $i < $ll } { incr i } {
	    set ni [ expr $ll - $i ]
	    #test sur la representativite de la representation echantillonnee
	    # le test ci-dessous verifie la pertinence d'un developpement de taylor au 1er ordre
	    set y2 [ lindex $ldensity $ni ]
	    #::console::affiche_resultat "ni= $ni period= [ lindex $lperiod $ni ] y2= $y2 \n\n"
	    set y3 [ lindex $ldensity [ expr $ni -1 ] ]
	    set y1 [ lindex $ldensity [ expr $ni +1 ] ]
	    if { [ expr abs ( 1. - .5 * ( $y1 + $y3 ) / $y2 ) > $precision ] } {
	       break
	    }
	    # ni est alors l'indice de la liste pour lequel le test s'est avere negatif pour la premiere fois  
	 }
	 set curr_sampling [ expr [ lindex $lperiod [ expr $ni +1 ] ] - [ lindex $lperiod $ni ] ]
      	
	 if { $ni != 1 && $curr_sampling  > $sample_min } {
	    #::console::affiche_resultat " test precision negatif pour ni= $ni  \n\n"
	    set last_period [ lindex $lperiod $ni ]
	    ::console::affiche_resultat "test precision negatif pour periode $last_period $unit_temps\n\n"
	    set period_max [ lindex $lperiod [ expr $ni +1 ] ]
	    # sauvegarde des bonnes valeurs des listes constituant le periodogramme
	    set last [ expr [ llength $lperiod ] -1 ]
	    #set llperiod [ concat [ lrange $lperiod [ expr $ni + 1 ] $last ] $llperiod ]
	    set llperiod [ concat [ lrange $lperiod [ expr $ni +2 ] $last ] $llperiod ]
	    #set lldensity [ concat [ lrange $ldensity [ expr $ni + 1 ] $last ] $llperiod ]
	    set lldensity [ concat [ lrange $ldensity [ expr $ni + 2 ] $last ] $lldensity ]     			
	    set n [ expr $n + 1 ]
	 } else {
	    break
	 }
      }
      if {$last_period == "indefini"} {
	 ::console::affiche_resultat "spc_periodogram :  ou bien la période minimale est atteinte ou bien le calcul n'a pas pu etre poursuivi car le pas d'echantillonage specifie (7eme parametre) $sample_min est trop grand : diminuez sa valeur si vous voulez poursuivre \n\n"
      } else {
	 ::console::affiche_resultat "spc_periodogram : $last_period est la plus petite periode pour laquelle la precision demandee $precision a ete satisfaite. Pour trouver des resultats pertinents aux periodes inferieures, il faut specifier un pas d'echantillonage (7 eme argument) plus petit \n\n"
      }
      #post processing
      # ecriture des points constituant le periodogramme sous forme de fichier dat
      set file_id [open "$audace(rep_images)/$fileout" w+]
      #--- configure le fichier de sortie avec les fin de ligne "xODx0A"
      #-- independamment du systeme LINUX ou WINDOWS
      fconfigure $file_id -translation crlf
      for { set k 0 } { $k < [ llength $llperiod ] } { incr k } {
	 set x [ lindex $llperiod $k ]
	 set y [ lindex $lldensity $k ]
         puts $file_id "$x\t$y"
      }
      close $file_id
      ::console::affiche_resultat " le fichier $fileout a ete cree \n"
      set fich_png [ spc_txt2png $fileout "Periodogram" "period ($unit_temps)" "pseudo-density" o ]
      set labscisses_max [ spc_maxsearch $fileout $nb_printed_period ]
      return $fileout
   } else {
      ::console::affiche_erreur "Usage: spc_periodogram data_filename.dat time_unit measured_quantity ?nb_periodes_plausibles (10)? ?period_min (0.)? ?period_max (=duree enregistrement des mesures)? ?valeur minimum autorisee pour le pas d'echantillonage du periodogramme?\n\n"
      return ""
   }
}
#***************************************************************************************************************#

#################################################################################################################
#Procedure pour calculer un periodogramme sur un intervalle de periodes specifiees à partir de donnees liste 
#d'abscisses et liste d'ordonnees, l'echantillonage etant obtenu en subdivisant l'intervalle de periodes considérées
#par un nombre qui sera une puissance de 2. 
# Auteur : Patrick LAILLY
# Date de création : 23-03-11
# Date de modification : 23-03-11
# entrees : liste d'abscisses (temps) , liste d'ordonnees (mesures associees a ces temps), periode min, periode max, puissance a 
# laquelle sera elevee le nombre 2 pour definir le nombre des sous intervalles, unite_temps.
# exemple  : spc_calperiodog $abscisses $ordonnees $period_min $period_max 9
#################################################################################################################
proc spc_calperiodog { args } {
   if { [ llength $args ] == 6 } {
      set abscisses [ lindex $args 0 ]
      set ordonnees [ lindex $args 1 ]
      set period_min [ lindex $args 2 ]
      set period_max [ lindex $args 3 ]
      set exposant [ lindex $args 4 ]
      set time_unit [ lindex $args 5 ]
      set pi [ expr acos(-1.) ]
      set nb_echant [ llength $abscisses ] 
      if { $period_min > $period_max } {
	 ::console::affiche_erreur "spc_calperiodog : la periode minimale $period_min est plus grande que la periode max $period_max ! \n\n"
         return ""
      }
      set nb_sample_periodog_1 [ expr pow(2,$exposant) ]
      set nb_sample_periodog [ expr $nb_sample_periodog_1 + 1 ] 
      set period_samplingrate [ expr ( $period_max - $period_min ) / $nb_sample_periodog_1 ]
      ::console::affiche_resultat "on [ clock format [ clock seconds ] -locale LOCALE ], the period sampling rate (subdivision of the interval to be explored in 2^$exposant intervals) is $period_samplingrate\n"
      #calcul des echantillons du periodogramme
      set lperiod [ list ]
      set ldensity  [ list ]
      for { set k 0 } { $k < $nb_sample_periodog } { incr k } {
	 set period [ expr $period_min + $k * $period_samplingrate ]
	 lappend lperiod $period
	 set omega [ expr 2. *$pi / $period ]
	 set num 0.
	 set den 0.
	 for { set j 0 } { $j < $nb_echant } { incr j } {
	    set phase [ expr 2. * $omega * [ lindex $abscisses $j ] ]
	    set num [ expr $num + sin($phase) ]
	    set den [ expr $den + cos($phase) ]
	 }
	 set ratio [ expr $num / $den ]
	 set tau [ expr atan($ratio) ]
	 set tau [ expr .5 * $tau / $omega ]
	 set numa 0.
	 set dena 0.
	 set numb 0.
	 set denb 0.
	 # on pourrait gagner du CPU en programmant via gsl la boucle ci-dessous
	 for { set j 0 } { $j < $nb_echant } { incr j } {
	    set phase [ expr $omega * ( [ lindex $abscisses $j ] -$tau ) ]
	    set co [ expr cos($phase) ]
	    set si [ expr sin($phase) ]
	    set numa [ expr $numa + $co * [ lindex $ordonnees $j ] ]
	    set dena [ expr $dena + $co * $co ]
	    set numb [ expr $numb + $si * [ lindex $ordonnees $j ] ]
	    set denb [ expr $denb + $si * $si ]
	 }
	 set result [ expr .5 * ( $numa * $numa / $dena + $numb * $numb / $denb ) ]
	 #::console::affiche_resultat " $k $result \n"
	 lappend ldensity $result
      }
     
      set lperiodog [ list ]
      lappend lperiodog $lperiod
      lappend lperiodog $ldensity
      return $lperiodog
   } else {
      ::console::affiche_erreur "Usage: spc_calperiodog list_abscisses list_ordonnees period_min period_max exposant \n\n"
      return ""
   }
}

#***************************************************************************#


## Fonction periodog associee a preiodogram : note qu'elle a un echantillonnage qui est adpate a l'etude de hd57682, soit duree_obs/1000 ou quelque chose comme cela et le temps de calcul est suportable
# modif qui reste a faire
###########################################################################
proc spc_periodog_old { args } {
   global audace

   set nbargs [ llength $args ]
   if { $nbargs<=3 } {
      if { $nbargs==1 } {
	 ::console::affiche_erreur "Usage: spc_periodog data_filename.dat time_unit ?period_number?\n"
	 return ""
      } elseif { $nbargs==2 } {
         set nom_dat [ lindex $args 0 ]
         set unit_temps [ lindex $args 1 ]
         set nb_period 2
      } elseif { $nbargs==3 } {
         set nom_dat [ lindex $args 0 ]
         set unit_temps [ lindex $args 1 ]
	 set nb_period [ lindex $args 2 ]
      } else {
	 ::console::affiche_erreur "Usage: spc_periodog_old data_filename.dat time_unit ?period_number?\n"
	 return ""
      }
      # lecture du fichier dat
      set input [open "$audace(rep_images)/$nom_dat" r]
      set contents [split [read $input] \n]
      close $input
      set nb_echant [llength $contents]
      # modification ad hoc : a comprendre !!!!!!!!!!!!!!!!!!!!!!!!
      set nb_echant [ expr $nb_echant -1 ]
      set nb_echant_1 [ expr $nb_echant - 1 ] 
      #::console::affiche_resultat " donnees spc_periodog : $nom_dat $unit_temps $nb_period \n"
      set abscisses [ list ]
      set ordonnees_orig [ list ]
      for {set k 0} { $k < $nb_echant } {incr k} {
	 set ligne [lindex $contents $k]
	 set x [lindex $ligne 0]
	 set y [lindex $ligne 1]
	 #::console::affiche_resultat " x= $x   y= $y \n"
	 lappend abscisses [lindex $ligne 0] 
	 lappend ordonnees_orig [lindex $ligne 1] 
      }
      set temps_max [ expr [ lindex $abscisses $nb_echant_1 ] - [ lindex $abscisses 0 ] ]
      set inv_nb_period [ expr 1./ $nb_period ]
      # elimination de la composante continue
      set dc 0.
      for {set k 0} { $k < $nb_echant } {incr k} {
	 set dc [ expr $dc + [ lindex $ordonnees_orig $k ] ]
      }
      set dc [ expr $dc / $nb_echant ]
      set ordonnees [ list ]
      for {set k 0} { $k < $nb_echant } {incr k} {
	 lappend ordonnees [ expr [ lindex $ordonnees_orig $k ] - $dc ]	
      }
		
      # gestion de l'echelle des temps sur le peridogramme
      set period_max [ expr $temps_max *$inv_nb_period ]
      #set nb_sample_periodog [ expr $nb_echant * 3 /4 ]
      set nb_sample_periodog [ expr $nb_echant * 30 ]
      set nb_sample_periodog_1 [ expr $nb_sample_periodog - 1 ] 
      set period_samplingrate [ expr $period_max / $nb_sample_periodog_1 ]
      #calcul des echantillons du periodogramme
      ::console::affiche_resultat "Nombre d'echantillons de donnees : $nb_echant\n"
      set pi [ expr acos(-1.) ]
      set lperiod [ list ]
      set ldensity  [ list ]
      for { set k 1 } { $k <= $nb_sample_periodog } { incr k } {
	 set period [ expr $k * $period_samplingrate ]
	 lappend lperiod $period
	 set omega [ expr 2. *$pi / $period ]
	 set num 0.
	 set den 0.
	 for { set j 0 } { $j < $nb_echant } { incr j } {
	    set phase [ expr 2. * $omega * [ lindex $abscisses $j ] ]
	    set num [ expr $num + sin($phase) ]
	    set den [ expr $den + cos($phase) ]
	 }
	 set ratio [ expr $num / $den ]
	 set tau [ expr atan($ratio) ]
	 set tau [ expr .5 * $tau / $omega ]
	 set numa 0.
	 set dena 0.
	 set numb 0.
	 set denb 0.
	 # on pourrait gagner du CPU en programmant via gsl la boucle ci-dessous
	 for { set j 0 } { $j < $nb_echant } { incr j } {
	    set phase [ expr $omega * ( [ lindex $abscisses $j ] -$tau ) ]
	    set co [ expr cos($phase) ]
	    set si [ expr sin($phase) ]
	    set numa [ expr $numa + $co * [ lindex $ordonnees $j ] ]
	    set dena [ expr $dena + $co * $co ]
	    set numb [ expr $numb + $si * [ lindex $ordonnees $j ] ]
	    set denb [ expr $denb + $si * $si ]
	 }
	 set result [ expr .5 * ( $numa * $numa / $dena + $numb * $numb / $denb ) ]
	 #::console::affiche_resultat " $k $result \n"
	 lappend ldensity $result
      }
      #-- Representation graphique :
      ::plotxy::clf
      #::plotxy::plot $abscisses $int ob 0   
      ::plotxy::plot $lperiod $ldensity r 1
      #::plotxy::hold on
      #::plotxy::plot $abscisses $newintens b 1
      ::plotxy::plotbackground #FFFFFF
      ::plotxy::xlabel "Period ($unit_temps)"
      ::plotxy::ylabel " Pseudo-density"
      ::plotxy::title "Periodogram for data $nom_dat\n "
      # ecriture des points constituant le periodogramme sous forme de fichier dat
      set fileout periodogram.dat
      set file_id [open "$audace(rep_images)/$fileout" w+]
      #--- configure le fichier de sortie avec les fin de ligne "xODx0A"
      #-- independamment du systeme LINUX ou WINDOWS
      fconfigure $file_id -translation crlf
      for { set k 0 } { $k < $nb_sample_periodog } { incr k } {
	 set x [ lindex $lperiod $k ]
	 set y [ lindex $ldensity $k ]
         puts $file_id "$x\t$y"
      }
      close $file_id
      return periodogram.dat
   } else {
      ::console::affiche_erreur "Usage: spc_periodog_old data_filename.dat time_unit ?period_number?\n"
   }
}
#***************************************************************************#



###########################################################################################
# Auteur : Patrick LAILLY
# Date de création : 23-02-11
# Date de modification : 23-02-11
# La procedure analyse le fit des donnees avec la fonction sinusoidale associee a la periode (on calcule au passage le dephasage optimal : cette analyse est menee en visualisant les données en fonction de la phase (export PNG) et les donnees en fonction du temps en superposition avec la sinusoide associee (plotxy).  Le decalage temporel caracterisant la sinusoide est affiche a la console.
# 4 paramètres obligatoires : nom du fichier dat donnant l'evolution de la quantite physique en fonction du temps calendaire, unite de temps utilisee, nature de la quantite physique mesuree, periode sur laquelle l'utilisateur veut mener l'analyse 
# La procedure retourne le nom du fichier .png representant les donnees en fonction de la phase.
# Exemple : spc_phaseplot data.dat "julian days" "radial velocity (m/s)" 7.84
###########################################################################################
proc spc_phaseplot { args } {
   global audace
   set nb_args [ llength $args ]
   if { $nb_args ==4 } {
      set fileout data_phase.dat 
      set nom_dat [ lindex $args 0 ]
      set unit_temps [ lindex $args 1 ]
      set measured_quantity [ lindex $args 2 ]
      set period [ lindex $args 3 ]
      set sine_caract [ spc_sinefit $nom_dat $unit_temps $measured_quantity $period ]
      set amplit [ lindex $sine_caract 0 ]
      set time_shift [ lindex $sine_caract 1 ]
      if { $amplit < 0. } {
	 set time_shift [ expr $time_shift - .5 * $period ] 
      }
      #lecture du fichier dat
      set input [open "$audace(rep_images)/$nom_dat" r]
      set contents [split [read $input] \n]
      close $input
      set nb_echant [llength $contents]
      # modification ad hoc : a comprendre !!!!!!!!!!!!!!!!!!!!!!!!
      set nb_echant [ expr $nb_echant -1 ]
      set nb_echant_1 [ expr $nb_echant - 1 ] 
      #::console::affiche_resultat " donnees spc_sinefit : $nom_dat $unit_temps $period \n"
      set pi [ expr acos(-1.) ]
      set abscisses [ list ]
      set ordonnees [ list ]
      for {set k 0} { $k < $nb_echant } {incr k} {
	 set ligne [lindex $contents $k]
	 #set x [lindex $ligne 0]
	 #set y [lindex $ligne 1]
	 #::console::affiche_resultat " x= $x   y= $y \n"
	 lappend abscisses [lindex $ligne 0] 
	 lappend ordonnees [lindex $ligne 1] 
      }
      set temps_deb [ lindex $abscisses 0 ]
      #set temps_max [ expr [ lindex $abscisses $nb_echant_1 ] - [ lindex $abscisses 0 ] ]
      set omega [ expr 2. *$pi / $period ]
      # classement des donnees en fonction de la phase
      set phase [ list ]
      for {set k 0} { $k < $nb_echant } {incr k} {
	 set phi [ expr  [ lindex $abscisses $k ] - $time_shift ]
	 set nbperiod [ expr int ($phi/$period) ]
	 set phi [ expr ( $phi - $nbperiod * $period ) / $period ]
	 lappend phase $phi
      }
      # classement par phase croissante
      set resultat [ list ]
      for { set k 0 } { $k < $nb_echant } { incr k } {
	 set couple [list ] 
	 set x [ lindex $phase $k ]
	 set y [ lindex $ordonnees $k ]
	 set couple " $x $y "
	 lappend resultat $couple
      }
      set resultat [ lsort -increasing -real -index 0 $resultat ]
      # ecriture des points de mesure en fonction de la phase sous forme de fichier dat
      set file_id [open "$audace(rep_images)/$fileout" w+]
      #--- configure le fichier de sortie avec les fin de ligne "xODx0A"
      #-- independamment du systeme LINUX ou WINDOWS
      #set result [list ]
      fconfigure $file_id -translation crlf
      for { set k 0 } { $k < $nb_echant } { incr k } {
	 set couple [ lindex $resultat $k ]
	 set x [ lindex $couple 0 ]
	 set y [ lindex $couple 1 ]
	 #::console::affiche_resultat " x= $x y=$y  \n"
         puts $file_id "$x\t$y"
      }
      close $file_id
      ::console::affiche_resultat " le fichier $fileout a ete cree \n"
      # creation du fichier png
      set fich_png [ spc_txt2png $fileout "Measured quantity versus phase" "Phase" $measured_quantity n ]
      return $fich_png
   } else {
      ::console::affiche_erreur "Usage: spc_phaseplot data_filename.dat time_unit  measured_quantity periode etudiee \n\n"
      return ""
   }
}
#***************************************************************************#





###########################################################################################
# Auteur : Patrick LAILLY
# Date de création : 23-02-11
# Date de modification : 09-06-11
# La procedure analyse le fit des donnees avec la fonction sinusoidale associee a la periode (on calcule au passage le dephasage optimal : cette analyse est menee en visualisant les données en fonction de la phase (export PNG) et les donnees en fonction du temps en superposition avec la sinusoide associee (plotxy).  Le decalage temporel caracterisant la sinusoide est affiche a la console.
# 4 paramètres obligatoires : nom du fichier dat donnant l'evolution de la quantite physique en fonction du temps calendaire, unite de temps utilisee, nature de la quantite physique mesuree, periode sur laquelle l'utilisateur veut mener l'analyse 
# La procedure retourne le nom du fichier .png representant les donnees en fonction de la phase.
# La procedure spc_phaseplot_err se distingue de spc_phaseplot par la possibilite de gerer une 3eme colonne dans le fichier dat, cette colonne donnant les incertitudes sur les mesures realisees. Dans la version actuelle la gestion des incertudes ne porte que sur la représentation graphique du résultat.
# Exemple : spc_phaseplot_err data.dat "julian days" "radial velocity (m/s)" 7.84
###########################################################################################
proc spc_phaseplot_err { args } {
   global audace
   set nb_args [ llength $args ]
   if { $nb_args ==4 } {
      set fileout data_phase.dat 
      set nom_dat [ lindex $args 0 ]
      set unit_temps [ lindex $args 1 ]
      set measured_quantity [ lindex $args 2 ]
      set period [ lindex $args 3 ]
      set sine_caract [ spc_sinefit $nom_dat $unit_temps $measured_quantity $period ]
      set amplit [ lindex $sine_caract 0 ]
      set time_shift [ lindex $sine_caract 1 ]
      if { $amplit < 0. } {
	 set time_shift [ expr $time_shift - .5 * $period ] 
      }
      #lecture du fichier dat
      set input [open "$audace(rep_images)/$nom_dat" r]
      set contents [split [read $input] \n]
      close $input
      set nb_echant [llength $contents]
      # modification ad hoc : a comprendre !!!!!!!!!!!!!!!!!!!!!!!!
      set nb_echant [ expr $nb_echant -1 ]
      set nb_echant_1 [ expr $nb_echant - 1 ] 
      #::console::affiche_resultat " donnees spc_sinefit : $nom_dat $unit_temps $period \n"
      set pi [ expr acos(-1.) ]
      set abscisses [ list ]
      set ordonnees [ list ]
      for {set k 0} { $k < $nb_echant } {incr k} {
	 set ligne [lindex $contents $k]
	 #set x [lindex $ligne 0]
	 #set y [lindex $ligne 1]
	 #::console::affiche_resultat " x= $x   y= $y \n"
	 lappend abscisses [lindex $ligne 0] 
	 lappend ordonnees [lindex $ligne 1]
	 lappend yerrors [lindex $ligne 2] 
      }
      set temps_deb [ lindex $abscisses 0 ]
      #set temps_max [ expr [ lindex $abscisses $nb_echant_1 ] - [ lindex $abscisses 0 ] ]
      set omega [ expr 2. *$pi / $period ]
      # classement des donnees en fonction de la phase
      set phase [ list ]
      for {set k 0} { $k < $nb_echant } {incr k} {
	 set phi [ expr  [ lindex $abscisses $k ] - $time_shift ]
	 set nbperiod [ expr int ($phi/$period) ]
	 set phi [ expr ( $phi - $nbperiod * $period ) / $period ]
	 lappend phase $phi
      }
      # classement par phase croissante
      set resultat [ list ]
      for { set k 0 } { $k < $nb_echant } { incr k } {
	 set couple [list ] 
	 set x [ lindex $phase $k ]
	 set y [ lindex $ordonnees $k ]
	 set z [ lindex $yerrors $k ]
	 set couple " $x $y $z"
	 lappend resultat $couple
      }
      set resultat [ lsort -increasing -real -index 0 $resultat ]
      # ecriture des points de mesure en fonction de la phase sous forme de fichier dat
      set file_id [open "$audace(rep_images)/$fileout" w+]
      #--- configure le fichier de sortie avec les fin de ligne "xODx0A"
      #-- independamment du systeme LINUX ou WINDOWS
      #set result [list ]
      fconfigure $file_id -translation crlf
      for { set k 0 } { $k < $nb_echant } { incr k } {
	 set couple [ lindex $resultat $k ]
	 set x [ lindex $couple 0 ]
	 set y [ lindex $couple 1 ]
	 set z [ lindex $couple 2 ]
	 #::console::affiche_resultat " x= $x y=$y  \n"
         puts $file_id "$x\t$y\t$z"
      }
      close $file_id
      ::console::affiche_resultat " le fichier $fileout a ete cree \n"
      # creation du fichier png
      set fich_ps [ spc_txt2pserr $fileout "Measured quantity versus phase" "Phase" $measured_quantity ]
      #spc_txt2pserr fichier_data \"Titre\" \"Légende axe x\" \"Légende axe y\" ?xdébut xfin? ?ydeb yfin?\n"
      return $fich_ps
   } else {
      ::console::affiche_erreur "Usage: spc_phaseplot_err data_filename.dat time_unit  measured_quantity periode etudiee \n\n"
      return ""
   }
}
#***************************************************************************#



##########################################################
# Procedure de determination de la vitesse radiale en km/s à l'aide du décalage d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-07-2006
# Date de mise à jour : 13-07-2006
# Arguments : delta_lambda lambda
##########################################################

proc spc_vdoppler { args } {

   global audace
   global conf

   if { [llength $args] == 2 } {
       set delta_lambda [ lindex $args 0 ]
       set lambda [lindex $args 1 ]

       set vrad [ expr 299792.458*$delta_lambda/$lambda ]
       ::console::affiche_resultat "La vitesse Doppler de l'objet est : $vrad km/s\n"
       return $vrad
   } else {
       ::console::affiche_erreur "Usage: spc_vdoppler delta_lambda lambda_raie_référence\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de la vitesse héliocentrique pour une correction de la vitesse radiale
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 08-02-2007
# Date de mise à jour : 08-02-2007 ; 16/05/2010
# Arguments : profil_raies_étalonné lambda_raie_approché lambda_réf ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?
# Explication : la correciton héliocentrique possède déjà le bon signe tandis que la vitesse héliocentrique non.
#  La mesure de vitesse radiale nécessite d'être corrigée de la vitesse héliocentrique même si la calibration a été faite sur les raies telluriques car le centre du référentiel n'est pas la Terre mais le barycentre du Système Solaire.
##########################################################

proc spc_vhelio { args } {

   global audace
   global conf

   set lambda_ref 6562.82
   set precision 1000.

   if { [llength $args] == 1 || [llength $args] == 7 || [llength $args] == 10 } {
       if { [llength $args] == 1 } {
	   set spectre [ lindex $args 0 ]
       } elseif { [llength $args] == 7 } {
	   set spectre [ lindex $args 0 ]
	   set ra_h [ lindex $args 1 ]
	   set ra_m [ lindex $args 2 ]
	   set ra_s [ lindex $args 3 ]
	   set dec_d [ lindex $args 4 ]
	   set dec_m [ lindex $args 5 ]
	   set dec_s [ lindex $args 6 ]
       } elseif { [llength $args] == 10 } {
	   set spectre [ lindex $args 0 ]
	   set ra_h [ lindex $args 1 ]
	   set ra_m [ lindex $args 2 ]
	   set ra_s [ lindex $args 3 ]
	   set dec_d [ lindex $args 4 ]
	   set dec_m [ lindex $args 5 ]
	   set dec_s [ lindex $args 6 ]
	   set jj [ lindex $args 7 ]
	   set mm [ lindex $args 8 ]
	   set aaaa [ lindex $args 9 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_vhelio profil_raies_étalonné ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
	   return 0
       }

       #--- Charge les mots clefs :
       buf$audace(bufNo) load "$audace(rep_images)/$spectre"
       set listemotsclef [ buf$audace(bufNo) getkwds ]

       #--- Détermine les paramètres de date et de coordonnées si nécessaire :
       # mc_baryvel {2006 7 22} {19h24m58.00s} {11d57m00.0s} J2000.0
       if { [llength $args] == 1 } {
	   # OBJCTRA = '00 16 42.089'
	   if { [ lsearch $listemotsclef "OBJCTRA" ] !=-1 } {
	       set ra [ lindex [buf$audace(bufNo) getkwd "OBJCTRA" ] 1 ]
	       set ra_h [ lindex $ra 0 ]
	       set ra_m [ lindex $ra 0 ]
	       set ra_s [ lindex $ra 0 ]
	       set raf [ list "${ra_h}h${ra_m}m${ra_s}s" ]
           } elseif { [ lsearch $listemotsclef "RA" ] !=-1 } {
               set raf [ lindex [buf$audace(bufNo) getkwd "RA" ] 1 ]
               if { [ regexp {\s+} $raf match resul ] } { 
                 ::console::affiche_erreur "Aucune coordonnée trouvée.\n"
                 return ""
               }
	   } else {
	       ::console::affiche_erreur "Aucune coordonnée trouvée.\n"
	       return ""
	   }
	   # OBJCTDEC= '-05 23 52.444'
	   if { [ lsearch $listemotsclef "OBJCTDEC" ] !=-1 } {
	       set dec [ lindex [buf$audace(bufNo) getkwd "OBJCTDEC" ] 1 ]
	       set dec_d [ lindex $dec 0 ]
	       set dec_m [ lindex $dec 0 ]
	       set dec_s [ lindex $dec 0 ]
	       set decf [ list "${dec_d}d${dec_m}m${dec_s}s" ]
           } elseif { [ lsearch $listemotsclef "DEC" ] !=-1 } {
               set decf [ lindex [buf$audace(bufNo) getkwd "DEC" ] 1 ]
	   }
	   # DATE-OBS : 2005-11-26T20:47:04
	   if { [ lsearch $listemotsclef "DATE-OBS" ] !=-1 } {
	       set ladate [ lindex [buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
	       set ldate [ mc_date2ymdhms $ladate ]
	       set y [ lindex $ldate 0 ]
	       set mo [ lindex $ldate 1 ]
	       set d [ lindex $ldate 2 ]
	       set datef [ list $y $mo $d ]
	   }
       } elseif { [llength $args] == 7 } {
	   # DATE-OBS : 2005-11-26T20:47:04
	   if { [ lsearch $listemotsclef "DATE-OBS" ] !=-1 } {
	       set ladate [ lindex [buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
	       set ldate [ mc_date2ymdhms $ladate ]
	       set y [ lindex $ldate 0 ]
	       set mo [ lindex $ldate 1 ]
	       set d [ lindex $ldate 2 ]
	       set datef [ list $y $mo $d ]
	   }
	   set raf [ list "${ra_h}h${ra_m}m${ra_s}s" ]
	   set decf [ list "${dec_d}d${dec_m}m${dec_s}s" ]
       } elseif { [llength $args] == 10 } {
	   set raf [ list "${ra_h}h${ra_m}m${ra_s}s" ]
	   set decf [ list "${dec_d}d${dec_m}m${dec_s}s" ]
	   set datef [ list $aaaa $mm $jj ]
       }

       #--- Calcul de la vitesse héliocentrique :
       set vhelio [ lindex [ mc_baryvel $datef $raf $decf J2000.0 ] 0 ]
       set deltal [ expr round($vhelio*$lambda_ref/299792.458*$precision)/$precision ]
       #--- Recherche la dispersion :
       if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	   set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
	   set erreurv [ expr round($precision*$dispersion*299792.458/$lambda_ref)/$precision ]
           # Delta v=2*v/c*Delta(lmabda)
       } else {
	   set erreurv 0.
       }


       #--- Formatage du résultat :
       #::console::affiche_resultat "La vitesse héliocentrique pour l'objet $raf ; $decf à la date du $datef vaut :\n$vhelio±$erreurv km/s=$deltal±$dispersion A\n"
       ::console::affiche_resultat "La vitesse héliocentrique pour l'objet $raf ; $decf à la date du $datef vaut :\n$vhelio km/s +/- $erreurv km/s <-> $deltal A\n"
       return $vhelio
   } else {
	   ::console::affiche_erreur "Usage: spc_vhelio profil_raies_étalonné ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
   }
}
#*******************************************************************************#



##########################################################
# Procedure de determination de la vitesse radiale en km/s à l'aide du décalage d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 08-02-2007
# Date de mise à jour : 08-02-2007
# Arguments : profil_raies_étalonné, lambda_raie_approché, ?
##########################################################

proc spc_vradiale { args } {

   global audace
   global conf

   if { [llength $args] == 4 } {
      set spectre [ lindex $args 0 ]
      set typeraie [ lindex $args 1 ]
      set lambda_approchee [lindex $args 2 ]
      set lambda_ref [lindex $args 3 ]

      #--- Recupere le jour julien :
      buf$audace(bufNo) load "$audace(rep_images)/$spectre"
      if { [ lindex [ buf$audace(bufNo) getkwd "MJD-OBS" ] 1 ] != "" } {
         # set jd [ expr [ lindex [ buf$audace(bufNo) getkwd "MJD-OBS" ] 1 ] +2400000.5 ]
         set jd [ expr [ lindex [ buf$audace(bufNo) getkwd "MJD-OBS" ] 1 ] +2400000 ]
      }

      #--- Détermine l'erreur sur la mesure :
      set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]

      #--- Centre gaussien de la raie étudié :
      set lambda_centre [ spc_autocentergaussl $spectre $lambda_approchee $typeraie ]

      #--- Calcul la vitesse radiale : Acker p.101 Dunod 2005.
      set delta_lambda [ expr $lambda_centre-$lambda_ref ]
      set vrad [ expr 299792.458*$delta_lambda/$lambda_ref ]
      #-- The correction hc has to apply to the measured radial velocity: Vrad, real = Vrad,measured + hc.
      #set vradcorrigee [ expr $vrad+$vhelio ]
      #-- Erreur sur le calcul :
      set vraderr [ expr 299792.458*$dispersion/$lambda_ref ]

      #--- Formatage du résultat :
      ::console::affiche_resultat "La vitesse radiale de l'objet le $jd JJ à la longueur d'onde $lambda_centre A :\n\# Vrad=$vrad +- $vraderr km/s\n"
      return $vrad
   } else {
       ::console::affiche_erreur "Usage: spc_vradiale profil_raies_étalonné type_raie (e/a) lambda_raie_approché lambda_réf\n\n"
   }
}
#*******************************************************************************#



##########################################################
# Procedure de determination de la vitesse radiale en km/s à l'aide du décalage d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 08-02-2007
# Date de mise à jour : 08-02-2007
# Arguments : profil_raies_étalonné, lambda_raie_approché, ?
##########################################################

proc spc_vradialecorr { args } {

   global audace
   global conf
   #-- Precision de la mesure d'une longueur d'onde a +- 1/4 de pixel :
   set precision 0.25

   if { [llength $args] == 4 || [llength $args] == 10 || [llength $args] == 13 } {
       if { [llength $args] == 4 } {
	   set spectre [ lindex $args 0 ]
	   set typeraie [ lindex $args 1 ]
	   set lambda_approchee [lindex $args 2 ]
	   set lambda_ref [lindex $args 3 ]
       } elseif { [llength $args] == 10 } {
	   set spectre [ lindex $args 0 ]
	   set typeraie [ lindex $args 1 ]
	   set lambda_approchee [lindex $args 2 ]
	   set lambda_ref [lindex $args 3 ]
	   set ra_h [ lindex $args 4 ]
	   set ra_m [ lindex $args 5 ]
	   set ra_s [ lindex $args 6 ]
	   set dec_d [ lindex $args 7 ]
	   set dec_m [ lindex $args 8 ]
	   set dec_s [ lindex $args 9 ]
       } elseif { [llength $args] == 13 } {
	   set spectre [ lindex $args 0 ]
	   set typeraie [ lindex $args 1 ]
	   set lambda_approchee [lindex $args 2 ]
	   set lambda_ref [lindex $args 3 ]
	   set ra_h [ lindex $args 4 ]
	   set ra_m [ lindex $args 5 ]
	   set ra_s [ lindex $args 6 ]
	   set dec_d [ lindex $args 7 ]
	   set dec_m [ lindex $args 8 ]
	   set dec_s [ lindex $args 9 ]
	   set jj [ lindex $args 10 ]
	   set mm [ lindex $args 12 ]
	   set aaaa [ lindex $args 12 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_vradialecorr profil_raies_étalonné type_raie (e/a) lambda_raie_approché lambda_réf ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
	   return 0
       }


       #--- Calcul la correction héliocentrique :
       # mc_baryvel {2006 7 22} {19h24m58.00s} {11d57m00.0s} J2000.0
       buf$audace(bufNo) load "$audace(rep_images)/$spectre"
       set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       if { [llength $args] == 4 } {
          if { [ lindex [ buf$audace(bufNo) getkwd "OBJCTRA" ] 1 ] == "" && [ lindex [ buf$audace(bufNo) getkwd "RA" ] 1 ] == ""  } {
             ::console::affiche_erreur "Il manque les coordonnées RA-DEC e l'objet.\nUsage: spc_vradialecorr profil_raies_étalonné type_raie (e/a) lambda_raie_approché lambda_réf ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
             return 0
          } else {
             set vhelio [ spc_vhelio $spectre ]
          }
       } elseif { [llength $args] == 10 } {
	   set vhelio [ spc_vhelio $spectre $ra_h $ra_m $ra_s $dec_d $dec_m $dec_s ]
       } elseif { [llength $args] == 13 } {
	   set vhelio [ spc_vhelio $spectre $ra_h $ra_m $ra_s $dec_d $dec_m $dec_s $dd $mm $aaaa ]
       } else {
	   ::console::affiche_erreur "Impossible de calculer vhélio ; Usage: spc_vradiale profil_raies_étalonné type_raie (e/a) lambda_raie_approché lambda_réf ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
	   return 0
       }
       ::console::affiche_resultat "\n"

       #--- Centre gaussien de la raie étudié :
       set lambda_centre [ spc_autocentergaussl $spectre $lambda_approchee $typeraie ]

       #--- Calcul la vitesse radiale : Acker p.101 Dunod 2005.
       set delta_lambda [ expr $lambda_centre-$lambda_ref ]
       set vrad [ expr 299792.458*$delta_lambda/$lambda_ref ]
       set delta_vrad [ expr 299792.458*$precision*$cdelt1/$lambda_ref ]
       #-- The correction hc has to apply to the measured radial velocity: Vrad, real = Vrad,measured + hc.
       set vradcorrigee [ expr $vrad+$vhelio ]

       #--- Formatage du résultat :
       ::console::affiche_resultat "(Vdoppler=$vrad km/s, Vhelio=$vhelio km/s)\n\# La vitesse radiale de l'objet est :\n\# Vrad=$vradcorrigee +- $delta_vrad km/s\n"
       set results [ list $vradcorrigee $delta_vrad $vhelio $vrad ]
       return $results
   } else {
       ::console::affiche_erreur "Usage: spc_vradialecorr profil_raies_étalonné type_raie (e/a) lambda_raie_approché lambda_réf ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
   }
}
#*******************************************************************************#



##########################################################
# Procedure de determination de la vitesse radiale en km/s à l'aide du décalage d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 08-02-2007
# Date de mise à jour : 08-02-2007
# Arguments : profil_raies_étalonné, lambda_raie_approché, ?
##########################################################

proc spc_vradialecorraccur { args } {

   global audace
   global conf
   #-- Precision de la mesure d'une longueur d'onde a +- 1/4 de pixel :
   set precision 0.25

   if { [llength $args] == 5 || [llength $args] == 11 || [llength $args] == 14 } {
       if { [llength $args] == 5 } {
	   set spectre [ lindex $args 0 ]
	   set typeraie [ lindex $args 1 ]
	   set lambda_approchee [ lindex $args 2 ]
	   set lambda_ref [lindex $args 3 ]
	   set ylevel [lindex $args 4 ]
       } elseif { [llength $args] == 11 } {
	   set spectre [ lindex $args 0 ]
	   set typeraie [ lindex $args 1 ]
	   set lambda_approchee [ lindex $args 2 ]
	   set lambda_ref [lindex $args 3 ]
	   set ylevel [lindex $args 4 ]
	   set ra_h [ lindex $args 5 ]
	   set ra_m [ lindex $args 6 ]
	   set ra_s [ lindex $args 7 ]
	   set dec_d [ lindex $args 8 ]
	   set dec_m [ lindex $args 9 ]
	   set dec_s [ lindex $args 10 ]
       } elseif { [llength $args] == 14 } {
	   set spectre [ lindex $args 0 ]
	   set typeraie [ lindex $args 1 ]
	   set lambda_approchee [ lindex $args 2 ]
	   set lambda_ref [lindex $args 3 ]
	   set ylevel [lindex $args 4 ]
	   set ra_h [ lindex $args 5 ]
	   set ra_m [ lindex $args 6 ]
	   set ra_s [ lindex $args 7 ]
	   set dec_d [ lindex $args 8 ]
	   set dec_m [ lindex $args 9 ]
	   set dec_s [ lindex $args 10 ]
	   set jj [ lindex $args 11 ]
	   set mm [ lindex $args 12 ]
	   set aaaa [ lindex $args 13 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_vradialecorraccur profil_raies_étalonné type_raie (e/a) lambda_approchée lambda_réf intensity_around_line_center ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
	   return 0
       }


       #--- Calcul la correction héliocentrique :
       # mc_baryvel {2006 7 22} {19h24m58.00s} {11d57m00.0s} J2000.0
       buf$audace(bufNo) load "$audace(rep_images)/$spectre"
       set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
       set jd [ mc_date2jd $ladate ]
       if { [llength $args] == 5 } {
          if { [ lindex [ buf$audace(bufNo) getkwd "OBJCTRA" ] 1 ] == "" && [ lindex [ buf$audace(bufNo) getkwd "RA" ] 1 ] == ""  } {
             ::console::affiche_erreur "Il manque les coordonnées RA-DEC e l'objet.\nUsage: spc_vradialecorr profil_raies_étalonné type_raie (e/a) lambda_raie_approché lambda_réf intensity_around_line_center ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
             return 0
          } else {
             set vhelio [ spc_vhelio $spectre ]
          }
       } elseif { [llength $args] == 11 } {
	   set vhelio [ spc_vhelio $spectre $ra_h $ra_m $ra_s $dec_d $dec_m $dec_s ]
       } elseif { [llength $args] == 14 } {
	   set vhelio [ spc_vhelio $spectre $ra_h $ra_m $ra_s $dec_d $dec_m $dec_s $dd $mm $aaaa ]
       } else {
	   ::console::affiche_erreur "Impossible de calculer vhélio ; Usage: spc_vradialecorr profil_raies_étalonné type_raie (e/a) lambda_raie_approchée lambda_réf intensity_around_line_center ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
	   return 0
       }
       ::console::affiche_resultat "\n"

       #--- Centre gaussien de la raie étudié :
       set linfos [ spc_findlinelimits $spectre $lambda_approchee $ylevel ]
       set lambda_begin [ lindex $linfos 0 ]
       set lambda_end [ lindex $linfos 1 ]
       set lambda_centre [ spc_centergaussl $spectre $lambda_begin $lambda_end $typeraie ]

       #--- Calcul la vitesse radiale : Acker p.101 Dunod 2005.
       set delta_lambda [ expr $lambda_centre-$lambda_ref ]
       set vrad [ expr 0.0001*round(10000*299792.458*$delta_lambda/$lambda_ref) ]
       set delta_vrad [ expr 0.0001*round(10000*299792.458*$precision*$cdelt1/$lambda_ref) ]
       #-- The correction hc has to apply to the measured radial velocity: Vrad, real = Vrad,measured + hc.
       set vradcorrigee [ expr 0.0001*round(10000*($vrad+$vhelio)) ]

       #--- Formatage du résultat :
       ::console::affiche_resultat "(Vdoppler=$vrad km/s, Vhelio=$vhelio km/s)\n\# La vitesse radiale de l'objet au $jd est :\n\# Vrad=$vradcorrigee +/- $delta_vrad km/s\n"
       set results [ list $vradcorrigee $delta_vrad $vhelio $vrad ]
       return $results
   } else {
       ::console::affiche_erreur "Usage: spc_vradialecorraccur profil_raies_étalonné type_raie (e/a) lambda_approchée lambda_réf intensity_around_line_center ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
   }
}
#*******************************************************************************#




##########################################################
# Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-08-2005
# Date de mise à jour : 13-08-2005
# Arguments : I_5007 I_4959 I_4363
# Modèle utilisé : A. Acker, Astronomie, méthodes et calculs, MASSON, p.104.
##########################################################

proc spc_npte { args } {

   global audace
   global conf

   if { [llength $args] == 3 || [llength $args] == 6 } {
     if {[llength $args] == 3} {
	 set I_5007 [ lindex $args 0 ]
	 set I_4959 [ expr [lindex $args 1 ] ]
	 set I_4363 [ expr [lindex $args 2] ]
     } elseif {[llength $args] == 6} {
	 set I_5007 [ lindex $args 0 ]
	 set I_4959 [ expr [lindex $args 1 ] ]
	 set I_4363 [ expr [lindex $args 2] ]
	 set dI1 [ lindex $args 3 ]
	 set dI2 [ lindex $args 4 ]
	 set dI3 [ lindex $args 5 ]
     } else {
	 ::console::affiche_erreur "Usage: spc_npte I_5007 I_4959 I_4363 ?dI1 dI2 dI3?\n\n"
	 return 0
     }

     #--- Calcul de la température :
     set R [ expr ($I_5007+$I_4959)/$I_4363 ]
     set Te [ expr (3.29*1E4)/(log($R/8.30)) ]

     #--- Calcul de l'erreur sur le calcul :
     if {[llength $args] == 6} {
	 set dTe [ expr $Te/(log($R)-log(8.32))*(($dI1+$dI2)/($I_5007+$I_4959)+$dI3/$I_4363) ]
     } else {
	 ::console::affiche_resultat "Pas de calcul de dTe\n"
	 set dTe 0
     }

     #--- Affichage du resultat :
     ::console::affiche_resultat "Le température électronique de la nébuleuse est : $Te Kelvin ; dTe=$dTe\nR(OIII)=$R\n"
     set resul [ list $Te $dTe $R ]
     return $resul
   } else {
     ::console::affiche_erreur "Usage: spc_npte I_5007 I_4959 I_4363 ?dI1 dI2 dI3?\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-08-2005
# Date de mise à jour : 23-01-2007
# Arguments : profil_de_raies_etalonne largeur_raie
# Modèle utilisé : A. Acker, Astronomie, méthodes et calculs, MASSON, p.104.
##########################################################

proc spc_te { args } {

   global audace
   global conf

   if {[llength $args] == 2} {
       set fichier [ lindex $args 0 ]
       set largeur [ lindex $args 1 ]
       set dlargeur [ expr $largeur/2. ]

       #--- Détermination de la valeur du continuum de la raie :
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	   set disp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
       } else {
	   set disp 1.
       }
       if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
	   set lambda0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
       } else {
	   set lambda 1.
       }
       if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
	   set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1 ]
       } else {
	   set crpix1 1
       }
       #-- Raie 1 :
       set ldeb1 [ expr 5006.8-$dlargeur ]
       set lfin1 [ expr 5006.8+$dlargeur ]
       set xdeb [ expr round(($ldeb1-$lambda0)/$disp)+$crpix1 ]
       set xfin [ expr round(($lfin1-$lambda0)/$disp)+$crpix1 ]
       set continuum1 [ lindex [ buf$audace(bufNo) fitgauss [ list $xdeb 1 $xfin 1 ] ] 3 ]
       #-- Raie 2 :
       set ldeb2 [ expr 4958.9-$dlargeur ]
       set lfin2 [ expr 4958.9+$dlargeur ]
       set xdeb [ expr round(($ldeb2-$lambda0)/$disp)+$crpix1 ]
       set xfin [ expr round(($lfin2-$lambda0)/$disp)+$crpix1 ]
       set continuum2 [ lindex [ buf$audace(bufNo) fitgauss [ list $xdeb 1 $xfin 1 ] ] 3 ]
       #-- Le continuum est choisi comme la plus petite des 2 valeurs :
       if { $continuum1<=$continuum2 } {
	   set continuum $continuum1
       } else {
	   set continuum $continuum2
       }
       #set continuum [ expr 0.5*($continuum1+$continuum2) ]
       ::console::affiche_resultat "Le continuum trouvé pour ($continuum1 ; $continuum2) vaut $continuum\n"


       #--- Calcul de l'intensite des raies [OIII] :
       set I_5007 [ spc_integratec $fichier $ldeb1 $lfin1 $continuum ]
       set I_4959 [ spc_integratec $fichier $ldeb2 $lfin2 $continuum ]
       set dlargeur4363 [ expr 0.5625*$dlargeur ]
       set ldeb [ expr 4363-$dlargeur4363 ]
       set lfin [ expr 4363+$dlargeur4363 ]
       set I_4363 [ spc_integratec $fichier $ldeb $lfin $continuum ]

       #--- Calcul de la tempéreture électronique :
       set R [ expr ($I_5007+$I_4959)/$I_4363 ]
       set Te [ expr (3.29*1E4)/(log($R/8.30)) ]
       ::console::affiche_resultat "Le température électronique de la nébuleuse est : $Te Kelvin\nR(OIII)=$R\n"
       set resul [ list $Te $R ]
       return $resul
   } else {
     ::console::affiche_erreur "Usage: spc_te profil_de_raies_etalonne largeur_raie\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-08-2005
# Date de mise à jour : 13-08-20052007-01-20
# Arguments : Te I_6584 I_6548 I_5755
# Modèle utilisé : Practical Amateur Spectroscopy, Stephen F. TONKIN, Springer, p.164.
#        set Ne [ expr 1/(2.9*1E(-3))*((8.5*sqrt($Te)*10^(10800/$Te))/$R-1) ]
# Nouveau modele : Astrnomie astrophysique, A. Acker, Dunod, 2005, p.278.
# REmarque importante : les raies de l'azote sont utilisées pour le calcul de Te et pas Ne. Donc cette focntion n'est pas utilisée pour l'instant.
##########################################################

proc spc_npne2 { args } {

   global audace
   global conf

   if {[llength $args] == 4 ||[llength $args] == 8 } {
       if {[llength $args] == 4 } {
	   set Te [ lindex $args 0 ]
	   set I_6584 [ lindex $args 1 ]
	   set I_6548 [ expr int([lindex $args 2 ]) ]
	   set I_5755 [ expr int([lindex $args 3]) ]
       } elseif {[llength $args] == 8 } {
	   set Te [ lindex $args 0 ]
	   set I_6584 [ lindex $args 1 ]
	   set I_6548 [ expr int([lindex $args 2 ]) ]
	   set I_5755 [ expr int([lindex $args 3]) ]
	   set dTe [ lindex $args 4 ]
	   set dI1 [ lindex $args 4 ]
	   set dI2 [ lindex $args 4 ]
	   set dI3 [ lindex $args 4 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_npne Te I_6584 I_6548 I_5755 ?dTe dI1 dI2 dI3?\n\n"
	   return 0
       }

       #--- Calcul du rapport des raies et de la densite électronique :
       set R [ expr ($I_6584+$I_6548)/$I_5755 ]
       set Ne [ expr sqrt($Te)*1E4/25*(6.91*exp(25000/$Te)/$R-1) ]

       #--- Calcul de l'erreur sur la densité Ne :
       if {[llength $args] == 8} {
	   set dNe [ expr $Ne*(0.5*$dTe/$Te+(1/$R*(($dI1+$dI2)/($I_6584+$I_6548)+$dI3/$I_5755)+$dTe*25000/($R*$Te))*6.91*exp(25000/$Te)/(6.91/$R*exp(25000/$Te)-1)) ]
       } else {
	   ::console::affiche_resultat "Pas de calcul de dNe\n"
	   set dNe 0
       }


       #--- Affichage et formatage des resultats :
       ::console::affiche_resultat "Le densité électronique de la nébuleuse est : $Ne e-/cm^3 ; dNe=$dNe\nR(NII)=$R\n"
       set resul [ list $Ne $dNe $R ]
       return $resul
   } else {
     ::console::affiche_erreur "Usage: spc_npne2 Te I_6584 I_6548 I_5755 ?dTe dI1 dI2 dI3?\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-08-2005
# Date de mise à jour : 23-01-2007
# Arguments : Te I_6584 I_6548 I_5755
# Modèle utilisé : Practical Amateur Spectroscopy, Stephen F. TONKIN, Springer, p.164.
##########################################################

proc spc_npne { args } {

   global audace
   global conf

   if { [llength $args] == 3 || [llength $args] == 6 } {
       if { [llength $args] == 3 } {
	   set Te [ lindex $args 0 ]
	   set I_6717 [ lindex $args 1 ]
	   set I_6731 [ lindex $args 2 ]
       } elseif { [llength $args] == 6 } {
	   set Te [ lindex $args 0 ]
	   set I_6717 [ lindex $args 1 ]
	   set I_6731 [ lindex $args 2 ]
	   set dTe [ lindex $args 3 ]
	   set dI_6717 [ lindex $args 4 ]
	   set dI_6731 [ lindex $args 5 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_npne Te I_6717 I_6731 ?dTe dI6717 dI6731?\n\n"
       }

       #--- Calcul du rapport des raies et de la densité électronique :
       set R [ expr $I_6717/$I_6731 ]
       set Ne [ expr 100*sqrt($Te)*($R-1.49)/(5.617-12.8*$R) ]

       #--- Calcul de l'incertitude sur Ne :
       if { [llength $args] == 6 } {
	   set dNe [ expr $Ne*(0.5*$dTe/$Te+$R*($dI_6717/$I_6717-$dI_6731/$I_6731)*(12.8/abs(5.617-12.8*$R)+1/abs($R-1.49))) ]
       } else {
	   set dNe 0.
       }

       #--- Formatage et affichage du résultat :
       ::console::affiche_resultat "Le densité électronique de la nébuleuse est : $Ne e-/cm^3 ; R(SII)=$R ; dNe=$dNe\n"
       set resul [ list $Ne $dNe $R ]
       return $resul
   } else {
	   ::console::affiche_erreur "Usage: spc_npne Te I_6717 I_6731 ?dTe dI6717 dI6731?\n\n"
   }
}
#*******************************************************************************#



##########################################################
# Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 23-01-2007
# Date de mise à jour : 23-01-2007
# Arguments :
# Modèle utilisé : A. Acker, Astronomie, méthodes et calculs, MASSON, p.105.
##########################################################

proc spc_ne { args } {

   global audace
   global conf

   if {[llength $args] == 3} {
       set fichier [ lindex $args 0 ]
       set Te [ lindex $args 1 ]
       set largeur [ lindex $args 2 ]
       set dlargeur [ expr $largeur/2. ]

       #--- Détermination de la valeur du continuum de la raie :
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	   set disp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
       } else {
	   set disp 1.
       }
       if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
	   set lambda0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
       } else {
	   set lambda 1.
       }
       if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
	   set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1 ]
       } else {
	   set crpix1 1
       }
       #-- Raie 1 :
       set ldeb1 [ expr 6717-$dlargeur ]
       set lfin1 [ expr 6717+$dlargeur ]
       set xdeb [ expr round(($ldeb1-$lambda0)/$disp)+$crpix1 ]
       set xfin [ expr round(($lfin1-$lambda0)/$disp)+$crpix1 ]
       set continuum1 [ lindex [ buf$audace(bufNo) fitgauss [ list $xdeb 1 $xfin 1 ] ] 3 ]
       #-- Raie 2 :
       set ldeb2 [ expr 6731-$dlargeur ]
       set lfin2 [ expr 6731+$dlargeur ]
       set xdeb [ expr round(($ldeb2-$lambda0)/$disp)+$crpix1 ]
       set xfin [ expr round(($lfin2-$lambda0)/$disp)+$crpix1 ]
       set continuum2 [ lindex [ buf$audace(bufNo) fitgauss [ list $xdeb 1 $xfin 1 ] ] 3 ]
       #-- Le continuum est choisi comme la plus petite des 2 valeurs :
       if { $continuum1<=$continuum2 } {
	   set continuum $continuum1
       } else {
	   set continuum $continuum2
       }
       #set continuum [ expr 0.5*($continuum1+$continuum2) ]
       ::console::affiche_resultat "Le continuum trouvé pour ($continuum1 ; $continuum2) vaut $continuum\n"

       #--- Calcul de l'intensite des raies [OIII] :
       set I_6717 [ spc_integratec $fichier $ldeb1 $lfin1 $continuum ]
       set I_6731 [ spc_integratec $fichier $ldeb2 $lfin2 $continuum ]

       #--- Calcul de la tempéreture électronique :
       set R [ expr $I_6717/$I_6731 ]
       set Ne [ expr 100*sqrt($Te)*($R-1.49)/(5.617-12.8*$R) ]
       ::console::affiche_resultat "La densité électronique de la nébuleuse est : $Ne e-/cm^3 ; R(SII)=$R ; \n"
       set resul [ list $Ne $R ]
       return $resul
   } else {
     ::console::affiche_erreur "Usage: spc_ne profil_de_raies_etalonne Te largeur_raie\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-08-2005
# Date de mise à jour : 13-08-2005
# Arguments : Te I_6584 I_6548 I_5755
# Modèle utilisé : Practical Amateur Spectroscopy, Stephen F. TONKIN, Springer, p.164.
##########################################################

proc spc_ne2 { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set Te [ lindex $args 0 ]
     set I_6584 [ lindex $args 1 ]
     set I_6548 [ expr int([lindex $args 2 ]) ]
     set I_5755 [ expr int([lindex $args 3]) ]

     set R [ expr ($I_6584+$I_6548)/$I_5755 ]
     set Ne [ expr 1/(2.9*1E(-3))*((8.5*sqrt($Te)*10^(10800/$Te))/$R-1) ]
     ::console::affiche_resultat "Le densité électronique de la nébuleuse est : $Ne Kelvin\n"
     return $Ne
   } else {
     ::console::affiche_erreur "Usage: spc_ne Te I_6584 I_6548 I_5755\n\n"
   }

}
#*******************************************************************************#




#-- CAlcul incertitude sur EW
#- le choix de lambda1 et lambda 2 est critique car il conditionne tout : largeur equivalente et incertitude;
#-idem pour les parametres de lissage qui te permettent de separer signal et bruit


####################################################################
# Calcul la largeur equivalenbte d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 04-04-2008
# Date modification : 04-04-2008
# Arguments : nom_profil_raies lambda_raie
####################################################################

proc spc_autoew { args } {
   global conf
   global audace

   set nb_args [ llength $args ]
   if { $nb_args == 2 || $nb_args == 3 || $nb_args == 4 } {
      if { $nb_args==2 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_raie [ lindex $args 1 ]
      } elseif { $nb_args==3 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_deb [ lindex $args 1 ]
         set lambda_fin [ lindex $args 2 ]
      } elseif { $nb_args==4 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_deb [ lindex $args 1 ]
         set lambda_fin [ lindex $args 2 ]
         set taux_doucissage [ lindex $args 3 ]
      } else {
         ::console::affiche_erreur "Usage: spc_autoew nom_profil_raies lambda_raie/lambda_deb lambda_fin ?taux_doucissage_continuum?\n"
         return ""
      }

      #--- Mesure EW par intersection a I=1 :
      if { $nb_args==2 } {
         set results_ew [ spc_autoew4 "$filename" $lambda_raie ]
      } elseif  { $nb_args==3 } {
         set results_ew [ spc_autoew4 "$filename" $lambda_deb $lambda_fin ]
      } elseif  { $nb_args==4 } {
         set results_ew [ spc_autoew4 "$filename" $lambda_deb $lambda_fin $taux_doucissage ]
      }

      #--- Traitement des resultats :
      return $results_ew
   } else {
      ::console::affiche_erreur "Usage: spc_autoew nom_profil_raies lambda_raie/lambda_deb lambda_fin ?taux_doucissage_continuum (0.-10.)?\n"
   }
}
#***************************************************************************#




####################################################################
# Calcul la largeur equivalenbte d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 9-10-2010
# Date modification : 9-10-2010
# Arguments : nom_profil_raies ?lambda_raie/ldeb lfin? ?taux_adoucissage_continuum?
# Algo : determine ldeb et lfin par intersection du spectre filtre passe-bas avec les valeurs du continuum du spectre normalise (2 normalisations necessaires)
####################################################################

proc spc_autoew4 { args } {
   global conf
   global audace spcaudace
   set precision 0.001
   #- largeur en angstroms des raies a eliminer par passebas :
   set largeur 10
   #- largeur en pixels des motifs a gommer par passe bas :
   set largeur_pbas 10
   #- deg polynome du continuum :
   set degp_conti 2

   set nb_args [ llength $args ]
   if { $nb_args == 2 || $nb_args == 3 || $nb_args == 4} {
      if { $nb_args == 2 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_raie [ lindex $args 1 ]
         set lambda_deb [ expr $lambda_raie-20 ]
         set lambda_fin [ expr $lambda_raie+20 ]
         set taux_doucissage $spcaudace(taux_doucissage)
      } elseif { $nb_args == 3 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_deb [ lindex $args 1 ]
         set lambda_fin [ lindex $args 2 ]
         set taux_doucissage $spcaudace(taux_doucissage)
      } elseif { $nb_args == 4 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_deb [ lindex $args 1 ]
         set lambda_fin [ lindex $args 2 ]
         set taux_doucissage [ lindex $args 3 ]
      } else {
         ::console::affiche_erreur "Usage: spc_autoew4 nom_profil_raies_normalisé lambda_raie/lambda_deb lambda_fin ?taux_doucissage_continuum (0.10.)?\n"
         return ""
      }

      #--- Cas avec recherche des longueurs d'onde :
      if { $nb_args == 2 } {
         #-- Extraction des valeurs :
         buf$audace(bufNo) load "$audace(rep_images)/$filename"
         set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]

         #-- Extraction du continuum du spectre :
         set filename_conti [ spc_extractcontew "$filename" $taux_doucissage ]
         set icontis [ lindex [ spc_fits2data $filename_conti ] 1 ]

         #-- Calcul un profil lisse (passe-bas) :
         set largeur_raie [ expr 10*$cdelt1 ]
         set filename_pbas [ spc_passebas $filename $largeur_pbas ]
         set listevals [ spc_fits2data $filename_pbas ]
         set lambdas [ lindex $listevals 0 ]
         set intensities [ lindex $listevals 1 ]
         set len [ llength $lambdas ]
         #-- Trouve l'indice de la raie recherche dans la liste
         set i_lambda [ lsearch -glob $lambdas ${lambda_raie}* ]

         #-- Recherche la longueur d'onde d'intersection du bord rouge de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i<$len } { incr i } {
	    set yval [ lindex $intensities $i ]
            set ycont [ lindex $icontis $i ]
	    if { [ expr abs($yval-$ycont) ] <= $precision } {
               set lambda_fin [ lindex $lambdas $i ]
               break
	    }
         }

         #-- Recherche la longueur d'onde d'intersection du bord bleu de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i>=0 } { set i [ expr $i-1 ] } {
	    set yval [ lindex $intensities $i ]
            set ycont [ lindex $icontis $i ]
	    if { [ expr abs($yval-$ycont) ] <= $precision } {
               set lambda_deb [ lindex $lambdas $i ]
               break
	    }
         }
         file delete -force "$audace(rep_images)/$filename_conti$conf(extension,defaut)"
         file delete -force "$audace(rep_images)/$filename_pbas$conf(extension,defaut)"
         ::console::affiche_prompt "Limites d'intégration trouvees : $lambda_deb $lambda_fin\n\n"
      }


      #--- Détermination de la largeur équivalente :
      set lamesure [ spc_ew $filename $lambda_deb $lambda_fin $taux_doucissage ]
      set deltal [ expr abs($lambda_fin-$lambda_deb) ]
      set ew [ lindex $lamesure 0 ]
      set sigma [ lindex $lamesure 1 ]
      set snr [ lindex $lamesure 2 ]
      set jd [ lindex $lamesure 3 ]
      set ew_largeur [ lindex $lamesure 4 ]
      set results [ list $ew $sigma $snr $jd "$ew_largeur" ]
      return $results
   } else {
      ::console::affiche_erreur "Usage: spc_autoew4 nom_profil_raies lambda_raie/lambda_deb lambda_fin ?taux_doucissage_continuum (0.-10.)?\n"
   }
}
#***************************************************************************#



####################################################################
# Calcul la largeur equivalenbte d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2008-05-31
# Date modification : 2008-06-1
# Arguments : nom_profil_raies ?lambda_raie/ldeb lfin?
# Algo : determine ldeb et lfin par intersection du spectre filtre passe-bas avec les valeurs du continuum du spectre normalise (2 normalisations necessaires)
####################################################################

proc spc_autoew3b { args } {
   global conf
   global audace
   set precision 0.001
   #- largeur en angstroms des raies a eliminer par passebas :
   set largeur 10
   #- largeur en pixels des motifs a gommer par passe bas :
   set largeur_pbas 10
   #- deg polynome du continuum :
   set degp_conti 4

   set nb_args [ llength $args ]
   if { $nb_args == 2 || $nb_args == 3} {
      if { $nb_args == 2 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_raie [ lindex $args 1 ]
         set lambda_deb [ expr $lambda_raie-20 ]
         set lambda_fin [ expr $lambda_raie+20 ]
      } elseif { $nb_args == 3 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_deb [ lindex $args 1 ]
         set lambda_fin [ lindex $args 2 ]
      } else {
         ::console::affiche_erreur "Usage: spc_autoew3b nom_profil_raies_normalisé lambda_raie/lambda_deb lambda_fin\n"
         return ""
      }

      #--- Date JD :
      buf$audace(bufNo) load "$audace(rep_images)/$filename"
      set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
      set jd [ mc_date2jd $ladate ]

      #--- Calculs :
      set filename_norma [ spc_autonorma $filename ]
      if { $nb_args == 2 } {
         #--- Extraction des valeurs :
         buf$audace(bufNo) load "$audace(rep_images)/$filename"
         set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]

         #--- Creation d'un continuum du spectre normalise :
         set filename_norm_conti [ spc_extractcont $filename_norma $degp_conti ]
         set iconti [ lindex [ spc_fits2data $filename_norm_conti ] 1 ]

         #--- Calcul un profil lisse :
         set largeur_raie [ expr 10*$cdelt1 ]
         set filename_norma_pbas [ spc_passebas $filename_norma $largeur_pbas ]
         set listevals [ spc_fits2data $filename_norma_pbas ]
         set lambdas [ lindex $listevals 0 ]
         set intensities [ lindex $listevals 1 ]
         set len [ llength $lambdas ]
         #--- Trouve l'indice de la raie recherche dans la liste
         set i_lambda [ lsearch -glob $lambdas ${lambda_raie}* ]

         #--- Recherche la longueur d'onde d'intersection du bord rouge de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i<$len } { incr i } {
	    set yval [ lindex $intensities $i ]
            set ycont [ lindex $iconti $i ]
	    if { [ expr abs($yval-$ycont) ] <= $precision } {
               set lambda_fin [ lindex $lambdas $i ]
               break
	    }
         }

         #--- Recherche la longueur d'onde d'intersection du bord bleu de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i>=0 } { set i [ expr $i-1 ] } {
	    set yval [ lindex $intensities $i ]
            set ycont [ lindex $iconti $i ]
	    if { [ expr abs($yval-$ycont) ] <= $precision } {
               set lambda_deb [ lindex $lambdas $i ]
               break
	    }
         }
      }
      ::console::affiche_resultat "Limites trouvees : $lambda_deb $lambda_fin\n"

      #--- Détermination de la largeur équivalente :
      set ew [ spc_ew $filename_norma $lambda_deb $lambda_fin ]
      set deltal [ expr abs($lambda_fin-$lambda_deb) ]

      #--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollmann) :
      set snr [ spc_snr $filename ]
      set rapport [ expr $ew/$deltal ]
      if { $rapport>=1.0 } {
         set deltal [ expr $ew+0.1 ]
         ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
      }
      if { $snr != 0 } {
         set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
         #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
      } else {
         ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n"
         set sigma 0
      }

   if { 1==0 } {
      #--- Effacement des fichiers temporaires :
      file delete -force "$audace(rep_images)/$filename_norma$conf(extension,defaut)"
      if { $nb_args == 2 } {
         file delete -force "$audace(rep_images)/$filename_norma_pbas$conf(extension,defaut)"
         file delete -force "$audace(rep_images)/$filename_norm_conti$conf(extension,defaut)"
      }
   }
      #--- Formatage des résultats :
      set l_fin [ expr 0.01*round($lambda_fin*100) ]
      set l_deb [ expr 0.01*round($lambda_deb*100) ]
      set delta_l [ expr 0.01*round($deltal*100) ]
      set ew_short [ expr 0.01*round($ew*100) ]
      set sigma_ew [ expr 0.01*round($sigma*100) ]
      set snr_short [ expr round($snr) ]

      #--- Affichage des résultats :
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short A.\n"
      ::console::affiche_resultat "Sigma(EW)=$sigma_ew A.\n"
      ::console::affiche_resultat "SNR=$snr_short.\n\n"
      #set resultats [ list $ew $sigma_ew ]
      #return $ew
      set results [ list $ew_short $sigma_ew $snr_short $jd "EW($delta_l=$l_deb-$l_fin)" ]
      return $results
   } else {
      ::console::affiche_erreur "Usage: spc_autoew3b nom_profil_raies_normalisé lambda_raie/lambda_deb lambda_fin\n"
   }
}
#***************************************************************************#



####################################################################
# Calcul la largeur equivalenbte d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2008-05-31
# Date modification : 2008-05-31
# Arguments : nom_profil_raies ?lambda_raie/ldeb lfin?
# Algo : determine ldeb et lfin par intersection du spectre filtre passe bas avec la valeur icont du spectre normalisé.
####################################################################

proc spc_autoew3 { args } {
   global conf
   global audace
   set precision 0.001
   #- largeur en angstroms des raies a eliminer par passebas :
   set largeur 10

   set nb_args [ llength $args ]
   if { $nb_args==2 || $nb_args==3 || $nb_args==4 } {
      if { $nb_args==2 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_raie [ lindex $args 1 ]
         set lambda_deb [ expr $lambda_raie-20 ]
         set lambda_fin [ expr $lambda_raie+20 ]
      } elseif { $nb_args==3 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_deb [ lindex $args 1 ]
         set lambda_fin [ lindex $args 2 ]
      } elseif { $nb_args==4 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_deb [ lindex $args 1 ]
         set lambda_fin [ lindex $args 2 ]
         set taux_doucissage [ lindex $args 3 ]
      } else {
         ::console::affiche_erreur "Usage: spc_autoew3 nom_profil_raies lambda_raie/lambda_deb lambda_fin ?taux_doucissage_continuum?\n"
         return ""
      }

      #--- Normalisation :
      set filename_norma [ spc_autonorma $filename ]

      #--- Determine la date en jours Juliens :
      buf$audace(bufNo) load "$audace(rep_images)/$filename"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "MID-JD" ] !=-1 } {
         set jd [ lindex [ buf$audace(bufNo) getkwd "MID-JD" ] 1 ]
      } else {
         set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
         set jd [ mc_date2jd $ladate ]
      }


      if { $nb_args == 2 } {
         #--- Extraction des mots clef :
         set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]

         #--- Caleur moyenne du continuum :
         set icont [ spc_icontinuum $filename_norma ]
         #set icont [ spc_icontinuum ${filename}_conti $lambda_raie ]

         #--- Calcul un profil lisse :
         set largeur_raie [ expr 10*$cdelt1 ]
         set filename_norma_pbas [ spc_passebas $filename_norma $largeur ]
         set listevals [ spc_fits2data $filename_norma_pbas ]
         set lambdas [ lindex $listevals 0 ]
         set intensities [ lindex $listevals 1 ]
         set len [ llength $lambdas ]
         #--- Trouve l'indice de la raie recherche dans la liste
         set i_lambda [ lsearch -glob $lambdas ${lambda_raie}* ]

         #--- Recherche la longueur d'onde d'intersection du bord rouge de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i<$len } { incr i } {
	    set yval [ lindex $intensities $i ]
	    if { [ expr abs($yval-$icont) ] <= $precision } {
               set lambda_fin [ lindex $lambdas $i ]
               break
	    }
         }

         #--- Recherche la longueur d'onde d'intersection du bord bleu de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i>=0 } { set i [ expr $i-1 ] } {
	    set yval [ lindex $intensities $i ]
	    if { [ expr abs($yval-$icont) ] <= $precision } {
               set lambda_deb [ lindex $lambdas $i ]
               break
	    }
         }
      }

      #--- Détermination de la largeur équivalente :
      if { $nb_args<=3 } {
         set ew [ spc_ew $filename_norma $lambda_deb $lambda_fin ]
      } elseif { $nb_args==4 } {
         set ew [ spc_ew $filename_norma $lambda_deb $lambda_fin $taux_doucissage ]
      }
      set deltal [ expr abs($lambda_fin-$lambda_deb) ]


      #--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollmann) :
      set snr [ spc_snr $filename ]
      set rapport [ expr $ew/$deltal ]
      if { $rapport>=1.0 } {
         set deltal [ expr $ew+0.1 ]
         ::console::affiche_prompt "Attention : largeur d'intégration<EW !\n"
      }
      if { $snr != 0 } {
         set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
         #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
      } else {
         ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n"
         set sigma 0
      }

      #--- Effacement des fichiers temporaires :
      file delete -force "$audace(rep_images)/$filename_norma$conf(extension,defaut)"
      if { $nb_args == 2 } {
         file delete -force "$audace(rep_images)/$filename_norma_pbas$conf(extension,defaut)"
         # file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"
      }

      #--- Formatage des résultats :
      set l_fin [ expr 0.01*round($lambda_fin*100) ]
      set l_deb [ expr 0.01*round($lambda_deb*100) ]
      set delta_l [ expr 0.01*round($deltal*100) ]
      set ew_short [ expr 0.01*round($ew*100) ]
      set sigma_ew [ expr 0.01*round($sigma*100) ]
      set snr_short [ expr round($snr) ]

      #--- Affichage des résultats :
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short A.\n"
      ::console::affiche_resultat "Sigma(EW)=$sigma_ew A.\n"
      ::console::affiche_resultat "SNR=$snr_short.\n\n"
      #set resultats [ list $ew $sigma_ew ]
      #return $ew
      set results [ list $ew_short $sigma_ew $snr_short "EW($delta_l=$l_deb-$l_fin)" $jd ]
      return $results
   } else {
      ::console::affiche_erreur "Usage: spc_autoew3 nom_profil_raies lambda_raie/lambda_deb lambda_fin ?taux_doucissage_continuum?\n"
   }
}
#***************************************************************************#



####################################################################
# Calcul la largeur equivalenbte d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-03-2007
# Date modification : 18-03-2007
# Arguments : nom_profil_raies lambda_raie
####################################################################

proc spc_autoew2 { args } {
    global conf
    global audace
    set precision 0.01

    if { [llength $args] == 2 } {
	set filename [ file rootname [ lindex $args 0 ] ]
	set lambda_raie [ lindex $args 1 ]

	#--- Valeur par defaut des bornes :
	set lambda_deb [ expr $lambda_raie-20 ]
	set lambda_fin [ expr $lambda_raie+20 ]

	#--- Extraction des valeurs :
	set listevals [ spc_fits2data $filename ]
	set lambdas [ lindex $listevals 0 ]
	set intensities [ lindex $listevals 1 ]
	set len [ llength $lambdas ]

	#--- Trouve l'indice de la raie recherche dans la liste
	set i_lambda [ lsearch -glob $lambdas ${lambda_raie}* ]
	# ::console::affiche_resultat "Indice de la raie : $i_lambda\n"


	#--- Déterminiation de la valeur du continuum :
	# set icont 1.0
	set icont [ spc_icontinuum $filename ]

	#--- Recherche la longueur d'onde d'intersection du bord rouge de la raie avec le continuum normalisé à 1 :
	for { set i $i_lambda } { $i<$len } { incr i } {
	    set yval [ lindex $intensities $i ]
	    if { [ expr $yval-$icont ]<=$precision } {
		set lambda_fin [ lindex $lambdas $i ]
		break
	    }
	}

	#--- Recherche la longueur d'onde d'intersection du bord bleu de la raie avec le continuum normalisé à 1 :
	for { set i $i_lambda } { $i>=0 } { set i [ expr $i-1 ] } {
	    set yval [ lindex $intensities $i ]
	    if { [ expr $yval-$icont ]<=$precision } {
		set lambda_deb [ lindex $lambdas $i ]
		break
	    }
	    #::console::affiche_resultat "$diff\n"
	}

	#--- Détermination de la largeur équivalente :
	set ew [ spc_ew3 $filename $lambda_deb $lambda_fin ]
	set deltal [ expr abs($lambda_fin-$lambda_deb) ]


	#--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollmann) :
	set snr [ spc_snr $filename ]
	set rapport [ expr $ew/$deltal ]
	if { $rapport>=1.0 } {
	    set deltal [ expr $ew+0.1 ]
	    ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
	}
	if { $snr != 0 } {
	    set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
	    #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
	} else {
	    ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n"
	    set sigma 0
	}

        #--- Formatage des résultats :
	set l_fin [ expr 0.01*round($lambda_fin*100) ]
	set l_deb [ expr 0.01*round($lambda_deb*100) ]
	set delta_l [ expr 0.01*round($deltal*100) ]
	set ew_short [ expr 0.01*round($ew*100) ]
	set sigma_ew [ expr 0.01*round($sigma*100) ]
	set snr_short [ expr round($snr) ]

	#--- Affichage des résultats :
	#::console::affiche_resultat "\n"
	#::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short anstrom(s).\n"
	#::console::affiche_resultat "SNR=$snr_short.\n"
	#::console::affiche_resultat "Sigma(EW)=$sigma_ew angstrom.\n\n"
	set results [ list $ew_short $sigma_ew $snr_short "EW($delta_l=$l_deb-$l_fin)" ]
	return $results
    } else {
	::console::affiche_erreur "Usage: spc_autoew2 nom_profil_raies_normalisé lambda_raie\n"
    }
}
#***************************************************************************#



####################################################################
# Calcul la largeur equivalenbte d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : nom_profil_raies lambda_raie
####################################################################

proc spc_autoew1 { args } {
   global conf
   global audace
   set precision 0.01

   set nb_args [ llength $args ]
   if { $nb_args == 2 || $nb_args == 3} {
      if { $nb_args == 2 } {
         set filename_in [ file rootname [ lindex $args 0 ] ]
         set lambda_raie [ lindex $args 1 ]
         set lambda_deb [ expr $lambda_raie-20 ]
         set lambda_fin [ expr $lambda_raie+20 ]
      } elseif { $nb_args == 3 } {
         set filename_in [ file rootname [ lindex $args 0 ] ]
         set lambda_deb [ lindex $args 1 ]
         set lambda_fin [ lindex $args 2 ]
      } else {
         ::console::affiche_erreur "Usage: spc_autoew1 nom_profil_raies lambda_raie/lambda_deb lambda_fin\n"
         return ""
      }

      set filename [ spc_autonorma "$filename_in" ]
      if { $nb_args == 2 } {
         #--- Extraction des valeurs :
         set listevals [ spc_fits2data $filename ]
         set lambdas [ lindex $listevals 0 ]
         set intensities [ lindex $listevals 1 ]
         set len [ llength $lambdas ]

         #--- Trouve l'indice de la raie recherche dans la liste
         set i_lambda [ lsearch -glob $lambdas ${lambda_raie}* ]
         # ::console::affiche_resultat "Indice de la raie : $i_lambda\n"

         #--- Déterminiation de la valeur du continuum :
         # set icont 1.0
         set icont [ spc_icontinuum $filename ]

         #--- Recherche la longueur d'onde d'intersection du bord rouge de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i<$len } { incr i } {
	    set yval [ lindex $intensities $i ]
	    if { [ expr abs($yval-$icont) ] <= $precision } {
               set lambda_fin [ lindex $lambdas $i ]
               break
	    }
         }

         #--- Recherche la longueur d'onde d'intersection du bord bleu de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i>=0 } { set i [ expr $i-1 ] } {
	    set yval [ lindex $intensities $i ]
	    if { [ expr abs($yval-$icont) ] <= $precision } {
               set lambda_deb [ lindex $lambdas $i ]
               break
	    }
	    #::console::affiche_resultat "$diff\n"
         }
      }

      #--- Détermination de la largeur équivalente :
      set ew [ spc_ew $filename $lambda_deb $lambda_fin ]
      set deltal [ expr abs($lambda_fin-$lambda_deb) ]


      #--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollmann) :
      set snr [ spc_snr $filename ]
      set rapport [ expr $ew/$deltal ]
      if { $rapport>=1.0 } {
         set deltal [ expr $ew+0.1 ]
         ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
      }
      if { $snr != 0 } {
         set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
         #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
      } else {
         ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n"
         set sigma 0
      }

      #--- Formatage des résultats :
      set l_fin [ expr 0.01*round($lambda_fin*100) ]
      set l_deb [ expr 0.01*round($lambda_deb*100) ]
      set delta_l [ expr 0.01*round($deltal*100) ]
      set ew_short [ expr 0.01*round($ew*100) ]
      set sigma_ew [ expr 0.01*round($sigma*100) ]
      set snr_short [ expr round($snr) ]

      #--- Affichage des résultats :
      file delete -force "$audace(rep_images)/$filename$conf(extension,defaut)"
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short A.\n"
      ::console::affiche_resultat "Sigma(EW)=$sigma_ew A.\n"
      ::console::affiche_resultat "SNR=$snr_short.\n\n"
      #set resultats [ list $ew $sigma_ew ]
      #return $ew
      set results [ list $ew_short $sigma_ew $snr_short "EW($delta_l=$l_deb-$l_fin)" ]
      return $results
   } else {
      ::console::affiche_erreur "Usage: spc_autoew1 nom_profil_raies lambda_raie/lambda_deb lambda_fin\n"
   }
}
#***************************************************************************#




####################################################################
# Procédure de calcul de la largeur équivalente d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26/05/2007
# Date modification : 26/05/2007
# Arguments : nom_profil_raies lambda_deb lambda_fin
####################################################################

proc spc_ew { args } {
   global conf
   global audace spcaudace

   set nbargs [ llength $args ]
   if { $nbargs==3 } {
      set filename [ lindex $args 0 ]
      set lambda_deb [ lindex $args 1 ]
      set lambda_fin [ lindex $args 2 ]
      set taux_doucissage $spcaudace(taux_doucissage)
   } elseif { $nbargs==4 } {
      set filename [ lindex $args 0 ]
      set lambda_deb [ lindex $args 1 ]
      set lambda_fin [ lindex $args 2 ]
      set taux_doucissage [ lindex $args 3 ]
   } else {
      ::console::affiche_erreur "Usage: spc_ew nom_profil_raies_calibré lamba_debut lambda_fin ?taux_doucissage_continuum (0.-10.)?\n"
      return ""
   }

   #--- Calcul de EW :
   set results [ spc_ew4 $filename $lambda_deb $lambda_fin $taux_doucissage ]
   return $results
}
#***************************************************************************#



####################################################################
# Procédure de calcul de la largeur équivalente d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 02-10-2010
# Date modification : 02-10-2010
# Arguments : nom_profil_raies lanmba_dep lambda_fin degre_polynomes_continuum
####################################################################

proc spc_ew4 { args } {
   global conf
   global audace spcaudace

   set nbargs [ llength $args ]
   if { $nbargs==3 } {
      set filename [ lindex $args 0 ]
      set xdeb [ lindex $args 1 ]
      set xfin [ lindex $args 2 ]
      set taux_doucissage $spcaudace(taux_doucissage)
      set degpoly $spcaudace(degpoly_cont)
      set rmconti "o"
   } elseif { $nbargs==4 } {
      set filename [ lindex $args 0 ]
      set xdeb [ lindex $args 1 ]
      set xfin [ lindex $args 2 ]
      set taux_doucissage [ lindex $args 3 ]
      set degpoly $spcaudace(degpoly_cont)
      set rmconti "o"
   } elseif { $nbargs==5 } {
      set filename [ lindex $args 0 ]
      set xdeb [ lindex $args 1 ]
      set xfin [ lindex $args 2 ]
      set taux_doucissage [ lindex $args 3 ]
      set rmconti [ lindex $args 4 ]
      set degpoly $spcaudace(degpoly_cont)
   } elseif { $nbargs==6 } {
      set filename [ lindex $args 0 ]
      set xdeb [ lindex $args 1 ]
      set xfin [ lindex $args 2 ]
      set taux_doucissage [ lindex $args 3 ]
      set rmconti [ lindex $args 4 ]
      set degpoly [ lindex $args 5 ]
   } else {
      ::console::affiche_erreur "Usage: spc_ew4 nom_profil_raies lambda_deb lambda_fin ?taux_doucissage_continuum (1-\[1000000\]00)? ?efface_continuum(o)? ?degré_polynomes_continuum_methode_pbas(2)?\n"
      return ""
   }


   #--- Détermination de la date :
   buf$audace(bufNo) load "$audace(rep_images)/$filename"
   set dispersion_locale [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
   # set jd [ expr 2400000.5+ [ lindex [ buf$audace(bufNo) getkwd "MJD-OBS" ] 1 ] ]
   set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
   set jd [ mc_date2jd $ladate ]


   #--- Conversion des données en liste :
   #-- Spectre astre :
   set listevals [ spc_fits2data $filename ]
   set xvals0 [ lindex $listevals 0 ]
   set yvals0 [ lindex $listevals 1 ]
   # set lmin [ lindex $xvals 0 ]
   # set lmax [ lindex $xvals [ expr [ llength $xvals ] -1 ] ]
   # set nbech [ llength $xvals ]
   #-- Spectre continuum :
   if { $nbargs==6 } {
      if { $degpoly!=0 } {
         set spectre_conti [ spc_extractcont $filename $degpoly ]
      } elseif { $degpoly==0 } {
         set spectre_conti [ spc_syntherule $filename 1. ]
      }
   } else {
      set spectre_conti [ spc_extractcontew $filename $taux_doucissage ]
   }
   set listevals [ spc_fits2data $spectre_conti ]
   set ycvals0 [ lindex $listevals 1 ]
   # set lcmin [ lindex $xvals 0 ]
   # set lcmax [ lindex $xvals [ expr [ llength $xvals ] -1 ] ]
   if { $rmconti=="o" } {
      file delete -force "$audace(rep_images)/$spectre_conti$conf(extension,defaut)"
   }

   #-- Sélection des échantillons :
   set xvals [ list ]
   set yvals [ list ]
   set ycvals [ list ]
   foreach xval $xvals0 yval $yvals0 ycval $ycvals0 {
      if { $xval>=$xdeb && $xval<=$xfin } {
         lappend xvals $xval
         lappend yvals $yval
         lappend ycvals $ycval
      }
   }
   set nbech [ llength $xvals ]


   #--- Calcul la largeur équivalente :
   #-- Methode avec definition :
   if { 1==1 } {
   set aire 0.
   foreach xval $xvals yval $yvals ycval $ycvals {
      if { $xval>=$xdeb && $xval<=$xfin } {
         set aire [ expr $aire+($yval-$ycval)/$ycval ]
      }
   }
   set ew [ expr -1.*$aire*$dispersion_locale ]
   }
   #-- Methode trapezes :
   if { 1==0 } {
   set aires 0.
   set airec 0.
   for {set i 0} { $i<$nbech } {incr i} {
      set xi [ lindex $xvals $i ]
      set xii [ lindex $xvals [ expr $i+1 ] ]
      set yi [ lindex $yvals $i ]
      set yii [ lindex $yvals [ expr $i+1 ] ]
      set yci [ lindex $ycvals $i ]
      set ycii [ lindex $ycvals [ expr $i+1 ] ]
      # set aire [ expr $aire+($xii-$xi)*0.5*($yii-$ycii+$yi-$yci) ]
      set aires [ expr $aires+($xii-$xi)*0.5*($yii+$yi) ]
      set airec [ expr $airec+($xii-$xi)*0.5*($ycii+$yci) ]
   }
   #set ew [ expr ($aire-($xfin-$xdeb))*$dispersion_locale ]
   #set ew [ expr $aire-($xfin-$xdeb) ]
   set ew [ expr $aires-$airec-($xfin-$xdeb) ]
   }

   
   #--- Détermine le type de raie : émission ou absorption et donne un signe à EW
   if { 1==0 } {
      set valsselect [ list $xsel $ysel ]
      set intensity [ spc_aire $valsselect ]
      if { $intensity>=1 } {
         set ew [ expr -1.*$ew ]
      }
   }
   
   #--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollman) :
   set deltal [ expr abs($xfin-$xdeb) ]
   set snr [ spc_snr $filename ]
   set rapport [ expr $ew/$deltal ]
   if { $rapport>=1.0 } {
      set deltal [ expr $ew+0.1 ]
      ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
   }
   if { $snr != 0 } {
      set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
      #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
   } else {
      ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n"
      set sigma 0
   }


   #--- Affichage du spectre et du continuum s'il n'a pa ete efface :
   if { $rmconti=="n" } {
      spc_gdeleteall
      spc_load "$filename"
      spc_loadmore "$spectre_conti" green
   }

   
   #--- Formatage des résultats :
   set l_fin [ expr 0.01*round($xfin*100) ]
   set l_deb [ expr 0.01*round($xdeb*100) ]
   set delta_l [ expr 0.01*round($deltal*100) ]
   set ew_short [ expr 0.01*round($ew*100) ]
   set sigma_ew [ expr 0.01*round($sigma*100) ]
   set snr_short [ expr round($snr) ]
   set jd_short [ expr 0.001*round($jd*1000) ]
   set ew_large "EW($delta_l=$l_deb-$l_fin)=$ew_short\ A."
   set lamesure [ list $ew_short $sigma_ew $snr_short $jd_short $ew_large ]
   
   #--- Affichage des résultats :
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "Date: $ladate\n"
   ::console::affiche_resultat "JD: $jd_short\n"
   ::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short A.\n"
   ::console::affiche_resultat "Sigma(EW)=$sigma_ew A.\n"
   ::console::affiche_resultat "SNR=$snr_short.\n\n"
   return $lamesure
}
#***************************************************************************#



####################################################################
# Procédure de calcul de la largeur équivalente d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-03-2007
# Date modification : 18-03-2007
# Arguments : nom_profil_raies lanmba_dep lambda_fin
####################################################################

proc spc_ew3 { args } {
    global conf
    global audace

    if { [llength $args] == 3 } {
       set filename [ lindex $args 0 ]
       set xdeb [ lindex $args 1 ]
       set xfin [ lindex $args 2 ]
       
       #--- Conversion des données en liste :
       set listevals [ spc_fits2data $filename ]
       set xvals [ lindex $listevals 0 ]
       set yvals [ lindex $listevals 1 ]
       set lmin [ lindex $xvals 0 ]
       set lmax [ lindex $xvals [ expr [ llength $xvals ] -1 ] ]

       #--- Déterminiation de la valeur du continuum :
       #-- intervalles de calcul :  6655,  6640 6660, 6605 6671, 6645 6655, 6587 6661
       #set icont [ spc_icontinuum $filename ]
       set spectre_cont [ spc_extractcont $filename ]
       if { 6605 >= $lmin && 6605 <= $lmax && 6671 >= $lmin && 6671 <= $lmax } {
          set icont [ spc_icontinuum $spectre_cont 6605 6671 ]
       } elseif { 6587 >= $lmin && 6587 <= $lmax && 6661 >= $lmin && 6661 <= $lmax } {
          set icont [ spc_icontinuum $spectre_cont 6587 6661 ]
       } elseif { 6555 >= $lmin && 6555 <= $lmax } {
          set icont [ spc_icontinuum $spectre_cont 6555 ]
       } else {
          set icont [ spc_icontinuum $spectre_cont ]
       }
       file delete -force "$audace(rep_images)/$spectre_cont$conf(extension,defaut)"
       

	#--- Calcul de l'aire sous la raie :
	set aire 0.
	foreach xval $xvals yval $yvals {
	    if { $xval>=$xdeb && $xval<=$xfin } {
		lappend xsel $xval
		set aire [ expr $aire+$yval-$icont ]
		lappend ysel $yval
	    }
	}
	::console::affiche_resultat "L'aire sans le continuum vaut $aire\n"

	#--- Calcul la largeur équivalente :
	#set deltal [ expr abs($xfin-$xdeb) ]
	#set dispersion_locale [ expr 1.*$deltal/[ llength $xsel ] ]
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	set dispersion_locale [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        #set jd [ expr 2400000.5+ [ lindex [ buf$audace(bufNo) getkwd "MJD-OBS" ] 1 ] ]
        set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
        set jd [ mc_date2jd $ladate ]
	set ew [ expr -1.*$aire*$dispersion_locale/$icont ]

	#--- Détermine le type de raie : émission ou absorption et donne un signe à EW
	if { 1==0 } {
	  set valsselect [ list $xsel $ysel ]
	  set intensity [ spc_aire $valsselect ]
	  if { $intensity>=1 } {
	    set ew [ expr -1.*$ew ]
	  }
	}

	#--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollman) :
	set deltal [ expr abs($xfin-$xdeb) ]
	set snr [ spc_snr $filename ]
	set rapport [ expr $ew/$deltal ]
	if { $rapport>=1.0 } {
	    set deltal [ expr $ew+0.1 ]
	    ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
	}
	if { $snr != 0 } {
	    set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
	    #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
	} else {
	    ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n" ]
	    set sigma 0
	}

        #--- Formatage des résultats :
	set l_fin [ expr 0.01*round($xfin*100) ]
	set l_deb [ expr 0.01*round($xdeb*100) ]
	set delta_l [ expr 0.01*round($deltal*100) ]
	set ew_short [ expr 0.01*round($ew*100) ]
	set sigma_ew [ expr 0.01*round($sigma*100) ]
	set snr_short [ expr round($snr) ]
        set lamesure [ list $ew_short $sigma_ew $snr_short $jd "EW($delta_l=$l_deb-$l_fin)" ]

	#--- Affichage des résultats :
	::console::affiche_resultat "\n"
        ::console::affiche_resultat "Date: $ladate\n"
        ::console::affiche_resultat "JD: $jd\n"
	::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short A.\n"
	::console::affiche_resultat "Sigma(EW)=$sigma_ew A.\n"
	::console::affiche_resultat "SNR=$snr_short.\n\n"
	return $lamesure
    } else {
	::console::affiche_erreur "Usage: spc_ew3 nom_profil_raies_normalisé lanmba_dep lambda_fin\n"
    }
}
#***************************************************************************#



####################################################################
# Procédure de calcul de la largeur équivalente d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : nom_profil_raies lambda_deb lambda_fin
####################################################################

proc spc_ew2 { args } {
    global conf
    global audace

    if { [llength $args] == 3 } {
	set filename [ lindex $args 0 ]
	set xdeb [ lindex $args 1 ]
	set xfin [ lindex $args 2 ]

	#--- Conversion des données en liste :
	set listevals [ spc_fits2data $filename ]
	set xvals [ lindex $listevals 0 ]
	set yvals [ lindex $listevals 1 ]

	foreach xval $xvals yval $yvals {
	    if { $xval>=$xdeb && $xval<=$xfin } {
		lappend xsel $xval
		lappend ysel $yval
	    }
	}

	#--- Calcul de l'aire sous la raie :
	set valsselect [ list $xsel $ysel ]
	set intensity [ spc_aire $valsselect ]
	set ew [ expr $intensity-($xfin-$xdeb) ]
	#--- Détermine le type de raie : émission ou absorption et donne un signe à EW
	if { $intensity>=1 } {
	    set ew [ expr -1.*$ew ]
	}

	#--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollman) :
	set deltal [ expr abs($xfin-$xdeb) ]
	set snr [ spc_snr $filename ]
	set rapport [ expr $ew/$deltal ]
	if { $rapport>=1.0 } {
	    set deltal [ expr $ew+0.1 ]
	    ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
	}
	if { $snr != 0 } {
	    set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
	    #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
	} else {
	    ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n" ]
	    set sigma 0
	}

        #--- Formatage des résultats :
	set l_fin [ expr 0.01*round($xfin*100) ]
	set l_deb [ expr 0.01*round($xdeb*100) ]
	set delta_l [ expr 0.01*round($deltal*100) ]
	set ew_short [ expr 0.01*round($ew*100) ]
	set sigma_ew [ expr 0.01*round($sigma*100) ]
	set snr_short [ expr round($snr) ]
        set lamesure [ list $ew_short $sigma_ew $snr_short $jd "EW($delta_l=$l_deb-$l_fin)" ]

	#--- Affichage des résultats :
	::console::affiche_resultat "\n"
	::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short anstrom(s).\n"
	::console::affiche_resultat "SNR=$snr_short.\n"
	::console::affiche_resultat "Sigma(EW)=$sigma_ew angstrom.\n\n"
	return $lamesure
    } else {
	::console::affiche_erreur "Usage: spc_ew2 nom_profil_raies_normalisé lanmba_dep lambda_fin\n"
    }
}
#***************************************************************************#



##########################################################
# Procedure de détermination de la largeur équivalente d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 12-08-2005
# Date de mise à jour : 21/12/2005-18/04/2006
# Arguments : fichier .fit du profil de raie, l_debut (wavelength), l_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_ew1 { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
       set fichier [ lindex $args 0 ]
       set ldeb [ expr int([lindex $args 1 ]) ]
       set lfin [ expr int([lindex $args 2]) ]
       set type [ lindex $args 3 ]

       #--- Conversion des longeurs d'onde/pixels en pixels
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set crval [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       set cdelt [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set crpix1 [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
       set xdeb [ expr int(($ldeb-$crval)/$cdelt)+$crpix1 ]
       set xfin [ expr int(($lfin-$crval)/$cdelt)+$crpix1 ]
       #-- coords contient : { x1 y1 x2 y2 }
	##  -----------B
	##  |          |
	##  A-----------
       set hauteur 1
       #-- pas mal : 26
       buf$audace(bufNo) scale [list 1 $hauteur]
       set listcoords [list $xdeb 1 $xfin $hauteur]

       #--- Mesure de la FWHM, I_continuum et de Imax
       if { [string compare $type "a"] == 0 } {
	   # fitgauss ne fonctionne qu'avec les raies d'emission, on inverse donc le spectre d'absorption
	   buf$audace(bufNo) mult -1.0
	   set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	   # Inverse de nouveau le spectre pour le rendre comme l'original
	   buf$audace(bufNo) mult -1.0
	   set fwhm [ expr $cdelt*[ lindex $lreponse 2 ] ]
	   set icontinuum [ lindex $lreponse 3 ]
	   set imax [ lindex $lreponse 0 ]
       } elseif { [string compare $type "e"] == 0 } {
	   set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	   set fwhm [ expr $cdelt*[ lindex $lreponse 2 ] ]
	   set icontinuum [ lindex $lreponse 3 ]
	   set imax [ expr $icontinuum+[ lindex $lreponse 0 ] ]
       }
       set sigma [ expr $fwhm/sqrt(8.0*log(2.0)) ]
       ::console::affiche_resultat "Imax=$imax, Icontinuum=$icontinuum, FWHM=$fwhm, sigma=$sigma.\n"

       #--- Calcul de EW
       #set aeqw [ expr sqrt(acos(-1.0)/log(2.0))*0.5*$fwhm ]
       # set aeqw [ expr sqrt((acos(-1.0)*$fwhm)/(8.0*sqrt(log(2.0))))*$i_continuum ]
       #- 1.675x-0.904274 : coefficent de réajustement par rapport a Midas.
       #set aeqw [ expr sqrt((acos(-1.0)*$fwhm)/(8.0*sqrt(log(2.0))))*1.6751-1.15 ]
       # Klotz : 060416, A=imax*sqrt(pi)*sigma, GOOD
       set aeqw [ expr sqrt(acos(-1.0)/(8.0*log(2.0)))*$fwhm*$imax ]
       # A=sqrt(sigma*pi)
       #set aeqw [ expr sqrt(acos(-1.0)*$fwhm/(sqrt(8.0*log(2.0)))) ]
       # A=sqrt(sigma*pi/2) car exp(-x/sigma)^2 et non exp(-x^2/2*sigma^2)
       #set aeqw [ expr sqrt(acos(-1.0)*$fwhm/(2*sqrt(8.0*log(2.0)))) ]
       # A=sqrt(pi/2)*sigma, vérité calculé pour exp(-x/sigma)^2
       #set aeqw [ expr sqrt(acos(-1.0)/(16.0*log(2.0)))*$fwhm ]

       if { [string compare $type "a"] == 0 } {
	   set eqw $aeqw
       } elseif { [string compare $type "e"] == 0 } {
	   set eqw [ expr (-1.0)*$aeqw ]
       }
       ::console::affiche_resultat "La largeur équivalente de la raie est : $eqw angstroms\n"
       return $eqw
   } else {
       ::console::affiche_erreur "Usage: spc_ew1 nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#



##########################################################
# Procedure de tracer de largeur équivalente pour une série de spectres dans le répertoire de travail
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 04-08-2005
# Date de mise à jour : 24-03-2007
# Arguments : nom générique des profils de raies normalisés à 1, longueur d'onde de la raie (A), largeur de la raie (A), type de raie (a/e)
##########################################################

proc spc_ewcourbe { args } {

   global audace spcaudace
   global conf
   global tcl_platform
   
   set ewfile "ewcourbe"
   set ext ".dat"
   
   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set lambda [ lindex $args 0 ]
   } elseif { $nbargs==2 } {
      set ldeb [ lindex $args 0 ] 
      set lfin [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_ewcourbe lambda_raie/lambda_deb lambda_fin\n\n"
      return ""
   }
   
   set ldates ""
   set list_ew ""
   set intensite_raie 1
   set fileliste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails *$conf(extension,defaut) ] ]
   
   foreach fichier $fileliste {
      ::console::affiche_prompt "\nTraitement de $fichier...\n"
      buf$audace(bufNo) load "$audace(rep_images)/$fichier"
      #set date [ lindex [buf$audace(bufNo) getkwd "MJD-OBS"] 1 ]
      set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
      if { [ string length $ladate ]<=10 } {
         set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE" ] 1 ]
      }
      set date [ mc_date2jd $ladate ]
      #- Ne tient que des 4 premières décimales du jour julien et retranche 50000 jours juliens
      ## lappend ldates [ expr int($date*10000.)/10000.-50000.+0.5 ]
      ## lappend ldates [ expr round($date*10000.)/10000.-2400000.5 ]
      # lappend ldates [ expr int(($date-2400000.5)*10000.)/10000. ]
      lappend ldates [ expr int(($date-2400000.)*10000.)/10000. ]
      if { $nbargs==1 } {
         set results [ spc_autoew $fichier $lambda ]
      } elseif { $nbargs==2 } {
         set results [ spc_autoew $fichier $ldeb $lfin ]
         #set results [ spc_ew4 $fichier $ldeb $lfin 1000000 n 2 ]
      }
      lappend list_ew [ lindex $results 0 ]
      lappend list_sigmaew [ lindex $results 1 ]
      lappend list_snr [ lindex $results 2 ]
   }
   
   #--- Création du fichier de données
   # ::console::affiche_resultat "$ldates \n $list_ew\n"
   set file_id1 [open "$audace(rep_images)/${ewfile}.dat" w+]
   foreach sdate $ldates ew $list_ew sew $list_sigmaew snr $list_snr {
      puts $file_id1 "$sdate\t$ew\t$sew\t$snr"
   }
   close $file_id1
   
   #--- Création du script de tracage avec gnuplot :
   set ew0 [ lindex $list_ew 0 ]
   if { $ew0<0 } {
      set invert_opt "reverse"
   } else {
      set invert_opt "noreverse"
   }
   if { $nbargs==2 } {
      set titre "Equivalent width EW ($ldeb-$lfin A) variations within time"
   } else {
      set titre "Equivalent width EW variations within time"
   }
   set legendey "Equivalent width EW (A)"
   set legendex "Date (JD-2400000)"
   set file_id2 [open "$audace(rep_images)/${ewfile}.gp" w+]
   puts $file_id2 "call \"$spcaudace(repgp)/gp_points_err.cfg\" \"$audace(rep_images)/${ewfile}.dat\" \"$titre\" * * * * $invert_opt \"$audace(rep_images)/ew_courbe.png\" \"$legendex\" \"$legendey\" "
   close $file_id2
   if { $tcl_platform(os)=="Linux" } {
      set answer [ catch { exec gnuplot $audace(rep_images)/${ewfile}.gp } ]
      ::console::affiche_resultat "$answer\n"
   } else {
      #-- wgnuplot et pgnuplot doivent etre dans le rep gp de spcaudace
      set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${ewfile}.gp } ]
      ::console::affiche_resultat "$answer\n"
   }
   
   #--- Affichage du graphe PNG :
   if { $conf(edit_viewer)!="" } {
      set answer [ catch { exec $conf(edit_viewer) "$audace(rep_images)/ew_courbe.png" & } ]
   } else {
      ::console::affiche_resultat "Configurer \"Editeurs/Visualisateur d'images\" pour permettre l'affichage du graphique\n"
   }
     
   #--- Traitement du résultat :
   return "ew_courbe.png"
}
#*******************************************************************************#


##########################################################
# Procedure de tracer de largeur équivalente pour une série de spectres dans le répertoire de travail
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 04-08-2005
# Date de mise à jour : 10-05-2006
# Arguments : nom générique des profils de raies normalisés à 1, longueur d'onde de la raie (A), largeur de la raie (A), type de raie (a/e)
##########################################################

proc spc_ewcourbe_opt { args } {

    global audace spcaudace
    global conf
    global tcl_platform

    set ewfile "ewcourbe"
    set ext ".dat"

    if { [llength $args]==3 } {
	set nom_generic [ lindex $args 0 ]
	set lambda [ lindex $args 1 ]
	set largeur_raie [ lindex $args 2 ]

	set ldates ""
	set list_ew ""
	set intensite_raie 1
	set fileliste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_generic}*$conf(extension,defaut) ] ]

	foreach fichier $fileliste {
	    set fichier [ file tail $fichier ]
	    ::console::affiche_resultat "\nTraitement de $fichier\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
	    set date [ mc_date2jd $ladate ]
	    # Ne tient que des 4 premières décimales du jour julien et retranche 50000 jours juliens
	    ##lappend ldates [ expr int($date*10000.)/10000.-50000.+0.5 ]
	    # lappend ldates [ expr int(($date-2400000.5)*10000.)/10000. ]
	    lappend ldates [ expr int(($date-2400000)*10000.)/10000. ]
	    # lappend ldates [ expr $date-50000. ]
	    set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	    set ldeb [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
	    set disp [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	    set ldeb [ expr $lambda-0.5*$largeur_raie ]
	    set lfin [ expr $lambda+0.5*$largeur_raie ]
	    lappend list_ew [ spc_ew $fichier $ldeb $lfin ]
	}

	#--- Création du fichier de données
	# ::console::affiche_resultat "$ldates \n $list_ew\n"
	set file_id1 [open "$audace(rep_images)/${ewfile}.dat" w+]
	foreach sdate $ldates ew $list_ew {
	    puts $file_id1 "$sdate\t$ew"
	}
	close $file_id1

	#--- Création du script de tracage avec gnuplot :
	set ew0 [ lindex $list_ew 0 ]
	if { $ew0<0 } {
	    set invert_opt "reverse"
	} else {
	    set invert_opt "noreverse"
	}
        set titre "Equivalent width EW variations within time"
	set legendey "Equivalent width (A)"
	set legendex "Date (JD-2400000)"
	set file_id2 [open "$audace(rep_images)/${ewfile}.gp" w+]
	puts $file_id2 "call \"$spcaudace(repgp)/gp_points.cfg\" \"$audace(rep_images)/${ewfile}.dat\" \"$titre\" * * * * $invert_opt \"$audace(rep_images)/ew_courbe.png\" \"$legendex\" \"$legendey\" "
	close $file_id2
	if { $tcl_platform(os)=="Linux" } {
	    set answer [ catch { exec gnuplot $audace(rep_images)/${ewfile}.gp } ]
	    ::console::affiche_resultat "$answer\n"
	} else {
	    #-- wgnuplot et pgnuplot doivent etre dans le rep gp de spcaudace
	    set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${ewfile}.gp } ]
	    ::console::affiche_resultat "$answer\n"
	}

	#--- Affichage du graphe PNG :
	if { $conf(edit_viewer)!="" } {
	    set answer [ catch { exec $conf(edit_viewer) "$audace(rep_images)/ew_courbe.png" & } ]
	} else {
	    ::console::affiche_resultat "Configurer \"Editeurs/Visualisateur d'images\" pour permettre l'affichage du graphique\n"
	}

	#--- Traitement du résultat :
	return "ew_courbe.png"
    } else {
	::console::affiche_erreur "Usage: spc_ewcourbe_opt nom_générique_profils_fits lambda_raie largeur_raie\n\n"
    }
}
#*******************************************************************************#




##########################################################
# Procedure de tracer de largeur équivalente pour une série de spectres dans le répertoire de travail
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 18-03-2007
# Date de mise à jour : 18-03-2007
# Arguments : longueur d'onde de la raie (A), largeur de la raie (A)
##########################################################

proc spc_ewdirw { args } {

    global audace
    global conf
    global tcl_platform
    set ewfile "ewcalculs.txt"
    set ext ".txt"

    if {[llength $args] == 1} {
	#set repertoire [ lindex $args 0 ]
	set lambda [lindex $args 0 ]
	set fileliste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails *$conf(extension,defaut) ] ]

	#--- Crée le fichier des résultats :
	set file_id1 [open "$audace(rep_images)/$ewfile" w+]
	puts $file_id1 "NAME\tMJD date\tEW(wavelength's range)\tSigma(EW)\tSNR\r"
	foreach fichier $fileliste {
	    ::console::affiche_resultat "\nTraitement de $fichier\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    if { 1==0 } {
	    set listemotsclef [ buf$audace(bufNo) getkwds ]
	    if { [ lsearch $listemotsclef "MJD-OBS" ] !=-1 } {
		set date [ lindex [ buf$audace(bufNo) getkwd "MJD-OBS" ] 1 ]
		#- Ne tient que des 4 premières décimales du jour julien
		#set jddate [ expr int($date*10000.)/10000.+2400000.5 ]
		set jddate [ expr int($date*10000.)/10000.+2400000 ]
	    } elseif { [ lsearch $listemotsclef "DATE-OBS" ] !=-1 } {
		set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
		set date [ mc_date2jd $ladate ]
		set jddate [ expr int($date*10000.)/10000. ]
	    } elseif { [ lsearch $listemotsclef "DATE" ] !=-1 } {
		set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE" ] 1 ]
		set date [ mc_date2jd $ladate ]
		set jddate [ expr int($date*10000.)/10000. ]
	    }
	    }
	    #- 070707 :
	    set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
	    set date [ mc_date2jd $ladate ]
	    # set jddate [ expr int(($date-2400000.5)*10000.)/10000. ]
	    set jddate [ expr int(($date-2400000.)*10000.)/10000. ]
	    #--
	    set mesure [ spc_autoew $fichier $lambda ]
	    set ew [ lindex $mesure 0 ]
	    set sigma_ew [ lindex $mesure 1 ]
	    set snr [ lindex $mesure 2 ]
	    set largeur_mes [ lindex $mesure 3 ]
	    puts $file_id1 "$fichier\t$jddate\t$largeur_mes=$ew A\t$sigma_ew A\t$snr\r"
	}
	close $file_id1

	#--- Fin de script :
	::console::affiche_resultat "Fichier des résultats sauvé sous $ewfile\n"
	return $ewfile
    } else {
	::console::affiche_erreur "Usage: spc_ewdirw lambda_raie \n\n"
    }
}
#*******************************************************************************#




####################################################################
# Procédure de calcul d'intensité d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 24-02-2008
# Date modification : 24-02-2008
# Arguments : nom_profil_raies lambda_raie_1 lambda_raie_2 largeur_raie
####################################################################

proc spc_vrmes { args } {
    global conf
    global audace
    set precision 0.01
    set nbargs [llength $args]
    if { $nbargs <= 5 } {
	if { $nbargs == 5 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set lambda_raie_1 [ lindex $args 1 ]
	    set lambda_raie_2 [ lindex $args 2 ]
	    set largeur [ lindex $args 3 ]
	    set prms [ lindex $args 4 ]
	} elseif { $nbargs == 4 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set lambda_raie_1 [ lindex $args 1 ]
	    set lambda_raie_2 [ lindex $args 2 ]
	    set largeur [ lindex $args 3 ]
	    set prms 150
	} else {
           ::console::affiche_erreur "Usage: spc_vrmes nom_profil_raies lambda_raie_Violet lambda_raie_Rouge largeur_raie ?pourcent_RMS_rejet (150)?\n"
           return ""
	}

	#--- Recuperation des infos du spectre :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
	set disper [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]

        #--- Extraction des donnees :
        set contenu [ spc_fits2data $filename ]
        set abscisses [ lindex $contenu 0 ]
        set intensites [ lindex $contenu 1 ]

	#--- Creation des donnees de la premiere raie :
	set xdeb [ expr $lambda_raie_1-0.5*$largeur ]
	set xfin [ expr $lambda_raie_1+0.5*$largeur ]
	set nabscisses1 ""
	set nintensites1 ""
	set k 0
	foreach abscisse $abscisses intensite $intensites {
	    #-- 060224 : gestion de lambda debut plus proche par defaut
	    set diff [ expr abs($xdeb-$abscisse) ]
	    if { $diff < $disper } {
		set xdebl [ expr $xdeb-$disper ]
	    } else {
		set xdebl $xdeb
	    }
	    #-- 060326 : gestion de lambda fin plus proche par exces
	    set diff [ expr abs($xfin-$abscisse) ]
	    if { $diff < $disper } {
		set xfinl [ expr $xfin+$disper ]
	    } else {
		set xfinl $xfin
	    }

	    #if { $abscisse >= $xdebl && $abscisse <= $xfin } {
	    #    lappend nabscisses $abscisse
	    #    lappend nintensites $intensite
	    #    # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
	    #    incr k
	    #}
	    if { $abscisse >= $xdebl } {
		if { $abscisse <= $xfinl } {
		    lappend nabscisses1 $abscisse
		    lappend nintensites1 $intensite
		    # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
		    incr k
		}
	    }
	}
	set len1 $k

	#--- Creation des donnees de la seconde raie :
	set xdeb [ expr $lambda_raie_2-0.5*$largeur ]
	set xfin [ expr $lambda_raie_2+0.5*$largeur ]
	set nabscisses2 ""
	set nintensites2 ""
	set k 0
	foreach abscisse $abscisses intensite $intensites {
	    #-- 060224 : gestion de lambda debut plus proche par defaut
	    set diff [ expr abs($xdeb-$abscisse) ]
	    if { $diff < $disper } {
		set xdebl [ expr $xdeb-$disper ]
	    } else {
		set xdebl $xdeb
	    }
	    #-- 060326 : gestion de lambda fin plus proche par exces
	    set diff [ expr abs($xfin-$abscisse) ]
	    if { $diff < $disper } {
		set xfinl [ expr $xfin+$disper ]
	    } else {
		set xfinl $xfin
	    }

	    #if { $abscisse >= $xdebl && $abscisse <= $xfin } {
	    #    lappend nabscisses $abscisse
	    #    lappend nintensites $intensite
	    #    # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
	    #    incr k
	    #}
	    if { $abscisse >= $xdebl } {
		if { $abscisse <= $xfinl } {
		    lappend nabscisses2 $abscisse
		    lappend nintensites2 $intensite
		    # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
		    incr k
		}
	    }
	}
	set len2 $k

	#--- Détermination du maximum de la raie 1 par parabole :
	set coefs [ lindex [ spc_ajustdeg2 $nabscisses1 $nintensites1 1. ] 0 ]
	set a [ lindex $coefs 0 ]
	set b [ lindex $coefs 1 ]
	set c [ lindex $coefs 2 ]
	set xm1 [ expr -$b/(2.*$c) ]
	set imax1 [ expr $a+$b*$xm1+$c*$xm1*$xm1 ]

	#--- Détermination du maximum de la raie 2 par parabole :
        set coefs [ lindex [ spc_ajustdeg2 $nabscisses2 $nintensites2 1. ] 0 ]
	set a [ lindex $coefs 0 ]
	set b [ lindex $coefs 1 ]
	set c [ lindex $coefs 2 ]
	set xm2 [ expr -$b/(2.*$c) ]
	set imax2 [ expr $a+$b*$xm2+$c*$xm2*$xm2 ]

	#--- Utilisation des résultats :
	#-- Raie V :
	set ldeb1 [ lindex $nabscisses1 0 ]
	set lfin1 [ lindex $nabscisses1 [ expr $len1-1 ] ]
	set xc1 [ expr $xm1*($lfin1-$ldeb1)+$ldeb1 ]

	#-- Raie R :
	set ldeb2 [ lindex $nabscisses2 0 ]
	set lfin2 [ lindex $nabscisses2 [ expr $len2-1 ] ]
	set xc2 [ expr $xm2*($lfin2-$ldeb2)+$ldeb2 ]

	#-- V/R :
	set vr [ expr $imax1/$imax2 ]
	::console::affiche_resultat "\n\# Raie V de centre $xc1 et d'intensité $imax1.\n"
	::console::affiche_resultat "Raie R de centre $xc2 et d'intensité $imax2.\n"
	::console::affiche_resultat "V/R=$vr.\n"
 	return $vr
    } else {
	::console::affiche_erreur "Usage: spc_vrmes nom_profil_raies lambda_raie_Violet lambda_raie_Rouge largeur_raie ?pourcent_RMS_rejet (150)?\n"
    }
}
#***************************************************************************#


##########################################################
# Procedure de tracer de largeur équivalente pour une série de spectres dans le répertoire de travail
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 04-08-2005
# Date de mise à jour : 24-03-2007
# Arguments : nom générique des profils de raies normalisés à 1, longueur d'onde de la raie (A), largeur de la raie (A), type de raie (a/e)
##########################################################

proc spc_vrcourbe { args } {

    global audace spcaudace
    global conf
    global tcl_platform

    set ewfile "vrcourbe"
    set ext ".dat"

    if { [llength $args]==3 } {
	set lambdaV [lindex $args 0 ]
	set lambdaR [lindex $args 1 ]
	set largeur [lindex $args 2 ]

	set ldates ""
	set list_ew ""
	set intensite_raie 1
	set fileliste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails *$conf(extension,defaut) ] ]

	foreach fichier $fileliste {
	    ::console::affiche_resultat "\nTraitement de $fichier\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    #set date [ lindex [buf$audace(bufNo) getkwd "MJD-OBS"] 1 ]
	    set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
	    if { [ string length $ladate ]<=10 } {
		set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE" ] 1 ]
	    }
	    set date [ mc_date2jd $ladate ]
	    #- Ne tient que des 4 premières décimales du jour julien et retranche 50000 jours juliens
	    ##lappend ldates [ expr int($date*10000.)/10000.-50000.+0.5 ]
	    ##lappend ldates [ expr round($date*10000.)/10000.-2400000.5 ]
	    #lappend ldates [ expr int(($date-2400000.5)*10000.)/10000. ]
	    lappend ldates [ expr int(($date-2400000)*10000.)/10000. ]
	    lappend list_ew [ spc_vrmes $fichier $lambdaV $lambdaR $largeur ]
	}

	#--- Création du fichier de données
	# ::console::affiche_resultat "$ldates \n $list_ew\n"
	set file_id1 [open "$audace(rep_images)/${ewfile}.dat" w+]
	foreach sdate $ldates ew $list_ew {
	    puts $file_id1 "$sdate\t$ew"
	}
	close $file_id1

	#--- Création du script de tracage avec gnuplot :
	set ew0 [ lindex $list_ew 0 ]
	if { $ew0<0 } {
	    set invert_opt "reverse"
	} else {
	    set invert_opt "noreverse"
	}
	set titre "Evolution du rapport V/R au cours du temps"
	set legendey "V/R"
	set legendex "Date (JD-2450000)"
	set file_id2 [open "$audace(rep_images)/${ewfile}.gp" w+]
	puts $file_id2 "call \"$spcaudace(repgp)/gp_points_err.cfg\" \"$audace(rep_images)/${ewfile}.dat\" \"$titre\" * * * * $invert_opt \"$audace(rep_images)/vr_courbe.png\" \"$legendex\" \"$legendey\" "
	close $file_id2
	if { $tcl_platform(os)=="Linux" } {
	    set answer [ catch { exec gnuplot $audace(rep_images)/${ewfile}.gp } ]
	    ::console::affiche_resultat "$answer\n"
	} else {
	    #-- wgnuplot et pgnuplot doivent etre dans le rep gp de spcaudace
	    set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${ewfile}.gp } ]
	    ::console::affiche_resultat "$answer\n"
	}

	#--- Affichage du graphe PNG :
	if { $conf(edit_viewer)!="" } {
	    set answer [ catch { exec $conf(edit_viewer) "$audace(rep_images)/vr_courbe.png" & } ]
	} else {
	    ::console::affiche_resultat "Configurer \"Editeurs/Visualisateur d'images\" pour permettre l'affichage du graphique\n"
	}


	#--- Traitement du résultat :
	return "vr_courbe.png"
    } else {
	::console::affiche_erreur "Usage: spc_vrcourbe lambda_raie_R lambda_raie_V largeur_raie\n\n"
    }
}
#*******************************************************************************#


#------- Debut spc_ajustplanck -----------------------------------------------#
##########################################################
# Procedure d'ajustement d'un continuum extrait par une fonction de Planck pour la détermination de la température
#
# Auteur : Patrick LAILLY, Benjamin MAUCLAIRE
# Date de création : 18-12-2009
# Date de mise à jour : 19-01-2010
# Arguments : fichier .fit du profil de raie,increment pour le calcul de la temperature (1000)
##########################################################

proc spc_ajustplanck { args } {

   global audace
   global conf

   set tmin 1000
   set tmax 50000
   set tpas 200
   set abscissemin 800
   # le parametre beta definit la ponderation entre les 2 termes apparaissant
   # dans la definition de la norme H1
   set beta 1.

   set nbargs [ llength $args ] 
   if { $nbargs==1 } {
      set fichier [ file rootname [ lindex $args 0 ] ]
      set tpas 1000
   } elseif { $nbargs==2 } {
      set fichier [ file rootname [ lindex $args 0 ] ]
      set tpas [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_ajustplanck nom_profil_calibré ?pas du calcul (1000)?\n\n"
      return ""
   }
   #--- pretraitements
   set coords [ spc_fits2data $fichier ]
   set abscisses [ lindex $coords 0 ]
   set intensites [ lindex $coords 1 ]
   set limits [ spc_findnnul $intensites ]
   set i_inf [ lindex $limits 0 ]
   set i_sup [ lindex $limits 1 ]
   set abscisses [ lrange $abscisses $i_inf $i_sup ]
   set lintens [ lrange $intensites $i_inf $i_sup ]
   set len [ llength $lintens ]
   set len_1 [ expr $len -1 ]
   set ldiff [ list ]
   for { set i 0 } { $i < $len_1 } { incr i } {
      set ip1 [ expr $i + 1 ]
      set diff [ expr [ lindex $lintens $ip1 ] - [ lindex $lintens $i ] ]
      lappend ldiff $diff
   }
      
   #-- calcul de la norme l2 et de la semi norme h1 des intensites
   set mintens [ list ]
   lappend mintens $lintens
   set mdiff [ list ]
   lappend mdiff $ldiff
   set tintens [ gsl_mtranspose $mintens ]
   set tdiff [ gsl_mtranspose $mdiff ]
   set l2 [ gsl_mindex [ gsl_mmult $mintens $tintens ] 1 1 ] 
   set h1 [ gsl_mindex [ gsl_mmult $mdiff $tdiff ] 1 1 ]
   # ci-dessous ratio est calcule de facon a rendre le poids de la seminorme h1 beta fois plus grand 
   # que la norme l2
   # on definit ainsi le produit  scalaire h1
   ::console::affiche_resultat "l2= $l2, h1= $h1, len=$len ; "
   set ratio [ expr $beta * $l2 / $h1 ]
   set norm2 [ expr $l2 + $ratio * $h1 ]
   ::console::affiche_resultat "norm2= $norm2 ; "
   #--- Effectue l'ajustement par moindre carres d'une focntion de Planck :
   ::console::affiche_resultat "Calcul de l'ajustement...\n"
   set i 1
   set rmss [ list ]
   for { set tempe $tmin } { $tempe<=$tmax } { set tempe [ expr $tempe+$tpas ] } {
      ::console::affiche_resultat "T=$tempe ; "
      set lplanck [ list ]
      #set corr 0.
      #-- calcul des echant de la courbe de planck
      foreach abscisse $abscisses {
	 set iplanck [ spc_planckval $tempe $abscisse ]
	 lappend lplanck $iplanck
      }
      #-- calcul du coefficient multiplicatif des intensites qui permet le meilleur 
      #-- ajustement sur la courbe de Planck pour la temperature consideree
      set corr [ spc_scalh1 $lintens $lplanck $ratio ]
      set alpha3 [ expr $corr / $norm2 ]
      #-- calcul de l'ecart quadratique entre planck et les intensites renormalisees
      set diff2 [ spc_quad $lintens $lplanck $alpha3 $ratio ]
         
      if { $i==1 } {
	 lappend rmss [ expr sqrt($diff2)/$len ]
	 set tempe [ expr $tempe+$tpas ]
	 ::console::affiche_resultat "T=$tempe ; "
	 set lplanck [ list ]
	 #set corr 0.
	 #-- calcul des echant de la courbe de planck
	 foreach abscisse $abscisses {
	    set iplanck [ spc_planckval $tempe $abscisse ]
	    lappend lplanck $iplanck
	 }
	 #-- calcul du coefficient multiplicatif des intensites qui permet le meilleur 
	 #-- ajustement sur la courbe de Planck pour la temperature consideree
	 set corr [ spc_scalh1 $lintens $lplanck $ratio ]
	 set alpha2 [ expr $corr / $norm2 ]
	 #-- calcul de l'ecart quadratique entre planck et les intensites renormalisees
	 set diff2 [ spc_quad $lintens $lplanck $alpha2 $ratio ]
	 set rms [ expr sqrt($diff2)/$len ]
	 lappend rmss $rms
	 set tempe [ expr $tempe+$tpas ]
	 ::console::affiche_resultat "T=$tempe, RMS=$rms ; "
	 set lplanck [ list ]
	 #set corr 0.
	 #-- calcul des echant de la courbe de planck
	 foreach abscisse $abscisses {
	    set iplanck [ spc_planckval $tempe $abscisse ]
	    lappend lplanck $iplanck
	 }
	 #-- calcul du coefficient multiplicatif des intensites qui permet le meilleur 
	 #-- ajustement sur la courbe de Planck pour la temperature consideree
	 set corr [ spc_scalh1 $lintens $lplanck $ratio ]
	 set alpha3 [ expr $corr / $norm2 ]
	 #-- calcul de l'ecart quadratique entre planck et les intensites renormalisees
	 set diff2 [ spc_quad $lintens $lplanck $alpha3 $ratio ]
	 lappend rmss [ expr sqrt($diff2)/$len ]
	 set i 3
      } else {
	 set rms1 [ lindex $rmss 0 ]
	 set rms2 [ lindex $rmss 1 ]
	 set rms3 [ lindex $rmss 2 ]            
	 set rmss [ lreplace $rmss 0 0 $rms2 ]
	 set rmss [ lreplace $rmss 1 1 $rms3 ]
	 set rms [ expr sqrt($diff2)/$len ]
	 set rmss [ lreplace $rmss 2 2 $rms ]
	 ::console::affiche_resultat "RMS=$rms ; "
      }

      #-- Comparaison :
      set rms1 [ lindex $rmss 0 ]
      set rms2 [ lindex $rmss 1 ]
      set rms3 [ lindex $rmss 2 ]
      #- ::console::affiche_resultat "RMSS=$rmss\n"
      if { $rms2<$rms1 && $rms2<$rms3 } {
	 ::console::affiche_resultat "\n"
	 ::console::affiche_resultat "Température déterminée : $rms1>RMS=$rms2<$rms3\n"
	 set tempe [ expr $tempe-$tpas ]
	 break
         }
      set lastalpha $alpha3
   }

   #--- Traitement du résultat :
   #-- normalisation des intensités
   set newintens [ list ]
   for { set i 0 } { $i < $len } { incr i } {
      set newint [ expr $lastalpha * [ lindex $lintens $i ] ]
      lappend newintens $newint
   }
   #-- Complement en longueur d'ondes jusqu'a 800 A pour l'affichage :
   ::console::affiche_resultat "Calcul de la courbe de Planck de l'UV au rouge...\n"
   set lmin [ lindex $abscisses 0 ]
   set lmax [ lindex $abscisses [ expr $len-1 ] ]
   set cdelt1 [ expr ($lmax-$lmin)/($len-1) ]
   set crpix1 1
   set nabscisses [ list ]
   set iplancks [ list ]
   set kmax [ expr round(($lmax-$abscissemin)/$cdelt1) ]
   for { set k 1 } { $k<=$kmax } { incr k } {
      set nabscisse [ spc_calpoly $k $crpix1 $abscissemin $cdelt1 0 0 ]
      lappend nabscisses $nabscisse
      lappend iplancks [ spc_planckval $tempe $nabscisse ]
   }

      
      

   #-- Representation graphique :
   ::plotxy::clf
   #::plotxy::plot $abscisses $intensites ob 0
      
   ::plotxy::plot $nabscisses $iplancks r 1
   ::plotxy::hold on
   ::plotxy::plot $abscisses $newintens b 1
   ::plotxy::plotbackground #FFFFFF
   ::plotxy::xlabel "Lambda (A)                                 made by SpcAudace"
   ::plotxy::ylabel "Relative intensity"
   ::plotxy::title "- Bleu : continuum stellaire de $fichier\n- Rouge : courbe de Planck (T=$tempe K)\n"
   #-- Renvois :
   ::console::affiche_resultat "Température trouvée : $tempe K\n"
   return $tempe
}
#****************************************************************#


##########################################################
#
# Calcul de l'ecart quadratique h1 entre planck et les intensites renormalisees par coeff :
# Auteur : P. Lailly
# Date : 03-01-2010
#
##########################################################

proc spc_quad { args } {
   set lintens [ lindex $args 0 ]
   set lplanck [ lindex $args 1 ]
   set coeff [ lindex $args 2 ]
   set ratio [ lindex $args 3 ]
   set len [ llength $lintens ]
   set coeff2 [ expr $coeff * $coeff ]
   if { $coeff2 == 0.0 } {
      ::console::affiche_erreur "\n spc_ajustplanck : coeff2= $coeff2 , le calcul ne peut etre effectue ; augmenter tmin \n ; "
      return 0
   }
   # calcul de la difference entre planck et le profil renormalise
   set ldiff [ list ]
   for { set i 0 } { $i < $len } { incr i } {
      set in [ lindex $lintens $i ]
      set pl [ lindex $lplanck $i ]
      set diff [ expr $coeff * $in - $pl ]
      lappend ldiff $diff
   }
   set quad [ spc_scalh1 $ldiff $ldiff $ratio ]
   set quad [ expr $quad / $coeff2 ]
   return $quad
}	
#*****************************************************************#


##########################################################
#
# Cette proc calcule le produit scalaire h1 (pondéré par ratio) de deux vecteurs transmis sous forme de liste
# Auteur : P. Lailly
# Date : 03-01-2010
#
##########################################################

proc spc_scalh1 { args } {

   set list1 [ lindex $args 0 ]
   set list2 [ lindex $args 1 ]
   set ratio [ lindex $args 2 ]
   set len [ llength $list1 ]
   set len_1 [ expr $len -1 ]
   set ldiff1 [ list ]
   set ldiff2 [ list ]
   for { set i 0 } { $i < $len_1 } { incr i } {
      set ip1 [ expr $i + 1 ]
      set diff1 [ expr [ lindex $list1 $ip1 ] - [ lindex $list1 $i ] ]
      set diff2 [ expr [ lindex $list2 $ip1 ] - [ lindex $list2 $i ] ]
      lappend ldiff1 $diff1
      lappend ldiff2 $diff2
   }
   set m1 [ list ]
   set m2 [ list ]
   set mdiff1 [ list ]
   set mdiff2 [ list ]
   lappend m1 $list1  
   lappend m2 $list2 
   lappend mdiff1 $ldiff1 
   lappend mdiff2 $ldiff2 
   #set t1 [ gsl_mtranspose $m1 ]
   set t2 [ gsl_mtranspose $m2 ]
   #set tdiff1 [ gsl_mtranspose $mdiff1 ]
   set tdiff2 [ gsl_mtranspose $mdiff2 ]
   set l2 [ gsl_mindex [ gsl_mmult $m1 $t2 ] 1 1 ] 
   set h1 [ gsl_mindex [ gsl_mmult $mdiff1 $tdiff2 ] 1 1 ]
   #::console::affiche_resultat "dim matrice [ gsl_mlength [ gsl_mmult $mdiff1 $tdiff2 ] ] ; "
   set prodscal [ expr $l2 + $ratio * $h1 ]
   #::console::affiche_resultat "prodscal= $prodscal \n ; "
   return $prodscal
}
#*****************************************************************#


##########################################################
# Procedure de calcul de l'intensité de la courbe de Planck pour une température et une longueur d'onde données.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 3-01-2010
# Date de mise à jour : 3-01-2010
# Arguments : temperature, longueur d'onde
##########################################################

proc spc_planckval { args } {

   #- set coefnorm 4.0E-15
   #- set coefnorm 4.5E-15
   set coefnorm 4.6E-15

   if {[llength $args] == 2} {
      set tempe [ lindex $args 0 ]
      set abscisse [ lindex $args 1 ]

      return [ expr $coefnorm*1.191043934E-16/pow($abscisse*1E-10,5)*1/(exp(1.438768660E-2/($abscisse*1E-10*$tempe))-1) ]
   } else {
      ::console::affiche_erreur "Usage: spc_planckval temperature longueur_d_onde\n"
   }
}
#****************************************************************#
#------- Fin spc_ajustplanck -----------------------------------------------#





#==========================================================================#
#           Acnciennes implémentations                                     #
#==========================================================================#

proc spc_ew_170406 { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
       set fichier [ lindex $args 0 ]
       set ldeb [ expr int([lindex $args 1 ]) ]
       set lfin [ expr int([lindex $args 2]) ]
       set type [ lindex $args 3 ]

       #--- Mesure de la FWHM, I_continuum et de Imax
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set crval [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       set cdelt [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set xdeb [ expr int(($ldeb-$crval)/$cdelt) ]
       set xfin [ expr int(($lfin-$crval)/$cdelt) ]
       set listcoords [list $xdeb 1 $xfin 1]
       if { [string compare $type "a"] == 0 } {
	   # fitgauss ne fonctionne qu'avec les raies d'emission, on inverse donc le spectre d'absorption
	   buf$audace(bufNo) mult -1.0
	   set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	   # Inverse de nouveau le spectre pour le rendre comme l'original
	   buf$audace(bufNo) mult -1.0
	   set fwhm [ expr $cdelt*[ lindex $lreponse 2 ] ]
	   set icontinuum [ lindex $lreponse 3 ]
	   set imax [ lindex $lreponse 0 ]
       } elseif { [string compare $type "e"] == 0 } {
	   set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	   set fwhm [ expr $cdelt*[ lindex $lreponse 2 ] ]
	   set icontinuum [ lindex $lreponse 3 ]
	   set imax [ expr $icontinuum+[ lindex $lreponse 0 ] ]
       }
       set sigma [ expr $fwhm/sqrt(8.0*log(2.0)) ]
       ::console::affiche_resultat "Imax=$imax, Icontinuum=$icontinuum, FWHM=$fwhm, sigma=$sigma.\n"

       #--- Calcul de EW
       #set aeqw [ expr sqrt(acos(-1.0)/log(2.0))*0.5*$fwhm ]
       # set aeqw [ expr sqrt((acos(-1.0)*$fwhm)/(8.0*sqrt(log(2.0))))*$i_continuum ]
       #- 1.675x-0.904274 : coefficent de réajustement par rapport a Midas.
       #set aeqw [ expr sqrt((acos(-1.0)*$fwhm)/(8.0*sqrt(log(2.0))))*1.6751-1.15 ]
       # Klotz : 060416, A=imax*sqrt(pi)*sigma, GOOD
       set aeqw [ expr sqrt(acos(-1.0)/(8.0*log(2.0)))*$fwhm*$imax ]
       # A=sqrt(sigma*pi)
       #set aeqw [ expr sqrt(acos(-1.0)*$fwhm/(sqrt(8.0*log(2.0)))) ]
       # A=sqrt(sigma*pi/2) car exp(-x/sigma)^2 et non exp(-x^2/2*sigma^2)
       #set aeqw [ expr sqrt(acos(-1.0)*$fwhm/(2*sqrt(8.0*log(2.0)))) ]
       # A=sqrt(pi/2)*sigma, vérité calculé pour exp(-x/sigma)^2
       #set aeqw [ expr sqrt(acos(-1.0)/(16.0*log(2.0)))*$fwhm ]

       if { [string compare $type "a"] == 0 } {
	   set eqw $aeqw
       } elseif { [string compare $type "e"] == 0 } {
	   set eqw [ expr (-1.0)*$aeqw ]
       }
       ::console::affiche_resultat "La largeur équivalente de la raie est : $eqw angstroms\n"
       return $eqw
   } else {
       ::console::affiche_erreur "Usage: spc_ew nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#

proc spc_ew_211205 { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set fichier [ lindex $args 0 ]
     set ldeb [ expr int([lindex $args 1 ]) ]
     set lfin [ expr int([lindex $args 2]) ]
     set type [ lindex $args 3 ]

     buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     #buf$audace(bufNo) load $fichier
     set crval [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
     set cdelt [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
     set xdeb [ expr int(($ldeb-$crval)/$cdelt) ]
     set xfin [ expr int(($lfin-$crval)/$cdelt) ]

     set listcoords [list $xdeb 1 $xfin 1]
     if { [string compare $type "a"] == 0 } {
	 # fitgauss ne fonctionne qu'avec les raies d'emission, on inverse donc le spectre d'absorption
	 buf$audace(bufNo) mult -1.0
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	 set flag 1
	 # Inverse de nouveau le spectre pour le rendre comme l'original
	 buf$audace(bufNo) mult -1.0
     } elseif { [string compare $type "e"] == 0 } {
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	 set flag 0
     }
     set I_continum [ lindex $lreponse 7 ]
     # Attention, $lreponse 2 est en pixels
     set if0 [ expr ([ lindex $lreponse 2 ]*$cdelt+$crval)*.601*sqrt(acos(-1)) ]
     set intensity [ expr [ lindex $lreponse 0 ]*$if0 ]
     if { $flag == 1 } {
	 set eqw [ expr (-1.0)*$intensity/$I_continum ]
     } else {
	 set eqw [ expr $intensity/$I_continum ]
     }
     ::console::affiche_resultat "La largeur équivalente de la raie est : $eqw angstroms\n"
     return $eqw

   } else {
     ::console::affiche_erreur "Usage: spc_ew nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#
