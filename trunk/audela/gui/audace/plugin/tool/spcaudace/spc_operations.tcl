####################################################################################
#
# Procedures d'opérations sur les spectres
# Auteur : Benjamin MAUCLAIRE
# Date de création : 01-04-2006
# Chargement en script : source $audace(rep_scripts)/spcaudace/spc_operations.tcl
#
#####################################################################################

# Mise a jour $Id: spc_operations.tcl,v 1.17 2009-07-18 18:24:41 bmauclaire Exp $




################################################################################################
# Procedure pour reechantilloner un profil spectral suivant un profil spectral modele
# Auteur : Patrick LAILLY
# Date de crÃ©ation : 1-09-08
# Date de modification : 17-07-2009
# Cette procÃ©dure rÃ©Ã©chantillone un profil de raies (fichier fits) avec le meme pas 
# d'echantillonage qu'un fichier modÃ¨le : le fichier de sortie est limitÃ© Ã  l'intervalle
# de longueurs d'ondes du fichier de dÃ©part. Les deux fichiers sont censÃ©s Ãªtre calibrÃ©s
# linÃ©airement. Le fichier de sortie est crÃ©Ã© avec le suffixe _newsamp. En option on peut
# spÃ©cifier la longueur d'onde de dÃ©part (crval1) du fichier rÃ©Ã©chantillonnÃ©.
# Exemple spc_echantmodel profile_model.fit profile_data.fit
# Exemple spc_echantmodel profile_model.fit profile_data.fit 6563.
#################################################################################################
proc spc_echantmodel { args } {
   global audace
   set nbargs [ llength $args ]
   if { $nbargs == 2 || $nbargs == 3 } {
      set nom_fich_input [ lindex $args 1 ]
      set nom_fich_input [ file rootname $nom_fich_input ]
      set nom_fich_model [ lindex $args 0 ]
      set nom_fich_model [ file rootname $nom_fich_model ]
	
      #set nbunit "float"
      set nbunit "double"
      set precision 0.05
      #set oversampling 2
		#--- CaractÃ©ristiques du profil modÃ¨le:
      buf$audace(bufNo) load "$audace(rep_images)/$nom_fich_model"
   	#-- Renseigne sur les parametres de l'image :
      set naxis1mod [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set crval1mod [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set newsamplingrate [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      ::console::affiche_resultat "caractÃ©ristiques fichier modÃ¨le cdelt1= $newsamplingrate naxis1= $naxis1mod crval1= $crval1mod \n"
      buf$audace(bufNo) delkwds
      buf$audace(bufNo) clear
      if { $nbargs == 3 } {
      	set crvalnew [ lindex $args 2 ]
      	set nom_fich_output [ spc_echantdelt $nom_fich_input $newsamplingrate $crvalnew ]
      } else {
      	set nom_fich_output [ spc_echantdelt $nom_fich_input $newsamplingrate ]
      }
      return $nom_fich_output

   } else {
      ::console::affiche_erreur "Usage: spc_echantmodel profile_model.fits?  profile_a_reechantillonner.fits?\n\n"
      return 0
   }
}
#*****************************************************************#


###########################################################################################
# Procedure pour reechantilloner un profil spectral suivant un pas d'echantillonage passe en 
# argument  
# Auteur : Patrick LAILLY
# Date de crÃ©ation : 12-12-08
# Date de modification : 17-07-09
# Cette procÃ©dure rÃ©Ã©chantillone un profil de raies (fichier fits) avec un pas d'echantillonnage
# spÃ©cifiÃ© en argument et exprimÃ© en Angstroems. En option on peut changer le lambda de dÃ©part
# mais l'argument, exprimÃ© en angstroems, est contraint Ã  etre situÃ© dans l'intervalle des
# longueurs d'ondes couvert par le profil d'entrÃ©e.
# Le profil data est censÃ© Ãªtre calibrÃ© linÃ©airement. Le fichier de sortie est crÃ©Ã© avec le 
# suffixe _newsampl
# Exemples 
# spc_echantdelt profile_data.fit .001
# spc_echantdelt profile_data.fit 10.
# spc_echantdelt profile_data.fit 10. 6563.
##############################################################################################
proc spc_echantdelt { args } {
   #global conf
  	global audace
   set nbargs [ llength $args ]
   if { $nbargs == 2 || $nbargs == 3} {
      set nom_fich_input [ lindex $args 0 ]
      set nom_fich_input [ file rootname $nom_fich_input ]
      set newsamplingrate [ lindex $args 1 ]	
      #set nbunit "float"
      set nbunit "double"

	# AccÃ¨s au fichier data
      buf$audace(bufNo) load "$audace(rep_images)/$nom_fich_input"
		#-- Renseigne sur les parametres de l'image :
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      set crvalnew $crval1
      if { $nbargs == 3} { 
      	set crvalnew [ lindex $args 2 ]
      }
      set contenu [ spc_fits2data $nom_fich_input ]
      set abscisses [ lindex $contenu 0 ]
      set ordonnees [ lindex $contenu 1 ]
      
      ::console::affiche_resultat "caractÃ©ristiques fichier data cdelt1= $cdelt1 naxis1= $naxis1 crval1= $crval1 \n"
      # RÃ©Ã©chantillonnage
      set result [ spc_resample $abscisses $ordonnees $newsamplingrate $crvalnew ]
      set profile [ lindex $result 1 ]
      ::console::affiche_resultat "longueur nouveau profil = [ llength $profile ] \n"
      set newnaxis1 [ llength $profile ]
      #set lambda [ list ]
      #for { set i 0 } { $i< $newnaxis1 } { incr i } {
	 	#	set lambdai [ expr $crval1 + $i *$newsamplingrate ]
	 #lappend lambda $lambdai
     # }
     	set crval1 $crvalnew
      set lambdamin $crval1
      set lambdamax [ expr $crval1 + $newsamplingrate* ($newnaxis1 - 1) ]
      # creation du nouveau fichier 
      set nbunit "float"
      set nbunit1 "double"
      buf$audace(bufNo) setpixels CLASS_GRAY $newnaxis1 1 FORMAT_FLOAT COMPRESS_NONE 0
      buf$audace(bufNo) setkwd [ list "NAXIS" 1 int "" "" ]
      buf$audace(bufNo) setkwd [list "NAXIS1" $newnaxis1 int "" ""]
      buf$audace(bufNo) setkwd [list "NAXIS2" 1 int "" ""]
      #-- Valeur minimale de l'abscisse (xdepart) : =0 si profil non Ã©talonnÃ©
      #set xdepart [ expr 1.0*[lindex $lambda 0]]
      buf$audace(bufNo) setkwd [list "CRVAL1" $crval1 $nbunit1 "" "Angstrom"]
      #-- Dispersion
      buf$audace(bufNo) setkwd [list "CDELT1" $newsamplingrate $nbunit1 "" "Angstrom/pixel"]
      #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
      # Une liste commence Ã  0 ; Un vecteur fits commence Ã  1
      #set intensite [ list ]
      ::console::affiche_resultat " lambdamin= $lambdamin  lambdamax= $lambdamax \n"
      for {set k 0} { $k < $newnaxis1 } {incr k} {
	 		#append intensite [lindex $profileref $k]
	 		#::console::affiche_resultat "$intensite\n"
	 		#if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {}
	 		buf$audace(bufNo) setpix [list [expr $k+1] 1] [lindex $profile $k ]
         #set intensite 0
      }
      #--- Sauvegarde du fichier fits ainsi crÃ©Ã©
      buf$audace(bufNo) bitpix float
      set suff _newsampl
      set nom_fich_output "$nom_fich_input$suff"
      buf$audace(bufNo) save "$audace(rep_images)/$nom_fich_output"
      ::console::affiche_resultat " nom fichier sortie $nom_fich_output \n"
      buf$audace(bufNo) bitpix short
      return $nom_fich_output 
      
   } else {
	 ::console::affiche_erreur "Usage: spc_echantdelt profil_a_reechantillonner.fits?  newsampl?\n\n"
	 return 0
   }
}
#*****************************************************************#




####################################################################
# Procedure pour merger 2 spectres ayant un recouvrement et gere le niveau du continuum
#
# Auteurs : Benjamin MAUCLAIRE et Patrick LAILLY
# Date creation : 2008-12-10
# Date modification : 2009-07-16
# Arguments : spectre1 spectre2
####################################################################

proc spc_merge { args } {
   global audace spcaudace
   global conf caption
   set spcaudace(maxdiff_icont) .05
   set increment 400
   set epsilon .00001

   if { [ llength $args ] == 2 } {
      set spectre1 [ lindex $args 0 ]
      set spectre1 [ file rootname $spectre1 ]
      set spectre2 [ lindex $args 1 ]
      set spectre2 [ file rootname $spectre2 ]
      set nom_fich_output $spectre1

      #--- DÃ©termine les parametres de chaque spectre :
      buf$audace(bufNo) load "$audace(rep_images)/$spectre1"
      set naxis1_a [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set crval1_a [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set cdelt1_a [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      set lfin_a [ expr $crval1_a+($naxis1_a-1)*$cdelt1_a ]
      buf$audace(bufNo) load "$audace(rep_images)/$spectre2"
      set naxis1_b [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set crval1_b [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set cdelt1_b [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      set lfin_b [ expr $crval1_b+($naxis1_b-1)*$cdelt1_b ]          

       #--- Selection du spectre le plus rouge et de la plage de recouvrement :
       # ne devrait on pas s'assurer d'une largeur de recouvrement minimum (remarque Pat)
      if { $lfin_a >= $crval1_b && $crval1_a <= $crval1_b } {
	 		set spectre_bleu "$spectre1"
	 		set spectre_rouge "$spectre2"
	 		#set lc_deb $crval1_b
	 		set lc_fin $lfin_a
	 		set naxisbleu $naxis1_a
	 		set naxisrouge $naxis1_b
	 		set crvalrouge $crval1_b
	 		set crvalbleu $crval1_a
      } elseif { $lfin_b >= $crval1_a && $crval1_a >= $crval1_b } {
	 		set spectre_bleu "$spectre2"
	 		set spectre_rouge "$spectre1"
	 		#set lc_deb $lfin_b
	 		set lc_fin $lfin_b
	 		set naxisrouge $naxis1_a
	 		set naxisbleu $naxis1_b
	 		set crvalbleu $crval1_b
	 		set crvalrouge $crval1_a
      } else {
	 		::console::affiche_erreur "Aucune plage commune de longueur d'onde.\n"
	 		return ""
      }
      set lc_deb $crvalrouge

      # a changer !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
      #--- Mise au meme niveau du continuum des deux spectres : A CHANGER !! vomme au tel
      #-- C le spectre rouge qui sera multipliÃ© car c'est toujours le moins bruitÃ© :
      # commentaire Pat : pour moi qui n'ai rien changÃ©, c'est OK
      set ic_bleu [ spc_icontinuum $spectre_bleu ]
      set ic_rouge [ spc_icontinuum $spectre_rouge ]
      if { $ic_rouge > 0 } {
	 		if { [ expr abs($ic_bleu-$ic_rouge)/$ic_bleu ] >= $spcaudace(maxdiff_icont) } {
	    		set ic_coeff [ expr $ic_bleu/$ic_rouge ]
	   		set spectre_rouge_mult [ spc_mult $spectre_rouge $ic_coeff ]
	 		} else {
	    		set spectre_rouge_mult "$spectre_rouge"
	 		}
  		} else {
	 		set spectre_rouge_mult "$spectre_rouge"
	 		::console::affiche_erreur "Pas de rescaling du continuum possible.\n"
  		}

   	#  uniformisation de l'echantillonnage des spectres
   	set newnaxisbleu [ expr $naxisbleu + $increment ] 
  		set cdeltnew [ expr ( $crvalrouge - $crvalbleu )/ ( $newnaxisbleu -1 ) ]
  		set newbleu [ spc_echantdelt $spectre_bleu $cdeltnew ]
  		set newrouge [ spc_echantdelt $spectre_rouge_mult $cdeltnew ]
  		buf$audace(bufNo) load "$audace(rep_images)/$newbleu"
  		set naxis1b [ lindex [ buf$audace(bufNo) getkwd NAXIS1 ] 1 ]
  		buf$audace(bufNo) imaseries "PROFILE offset=1 direction=x filename=bleu.dat"
  		buf$audace(bufNo) load "$audace(rep_images)/$newrouge"
  		buf$audace(bufNo) imaseries "PROFILE offset=1 direction=x filename=rouge.dat"
 		# determination du NÂ° d' echantillon de debut de la zone commune
		set ndebrouge [ expr int( ( $crvalrouge -$crvalbleu + $epsilon ) / $cdeltnew) + 1 ]
   	#::console::affiche_resultat " ndebrouge = $ndebrouge\n"
	   
		## === Extraction des numeros des pixels et des intensites bleu===
   	set inputfile [ open "$audace(rep_gui)/bleu.dat" r ]
  		set contents [split [read $inputfile] \n]
  		close $inputfile
  		set abscissesbleu [ list ]
 		set intensitebleu [ list ]
  		set kk 0
 		foreach ligne $contents {
	 		#::console::affiche_resultat " $ligne \n"
	 		if { $kk != 0 } {
	    		lappend abscissesbleu [ lindex $ligne 0 ]	
	    		lappend intensitebleu [ lindex $ligne 1 ]
	 		}
	 		incr kk
  		}
 		set longbleu [ llength $abscissesbleu ]
  		## === Extraction des numeros des pixels et des intensites rouge===
		set inputfile [ open "$audace(rep_gui)/rouge.dat" r ]
  		set contents [split [read $inputfile] \n]
  		close $inputfile
  		set abscissesrouge [ list ]
  		set intensiterouge [ list ]
  		set kk 0
   	foreach ligne $contents {
			#::console::affiche_resultat " $ligne \n"
	 		if { $kk != 0 } {
	    		lappend abscissesrouge [ lindex $ligne 0 ]	
	    		lappend intensiterouge [ lindex $ligne 1 ]
	 		}
	 		incr kk
  		}
  		set longrouge [ llength $abscissesrouge ] 
 		::console::affiche_resultat " longueur des profils apres reechantillonage bleu = $longbleu rouge = $longrouge \n"
 		#merge des listes
 		set ndebrouge_2 [ expr $ndebrouge - 2 ]
		set ndebrouge_1 [ expr $ndebrouge - 1 ]
 		set intensite [ lrange $intensitebleu 0 $ndebrouge_2 ]
		set newnaxisbleu [ llength $abscissesbleu ]
		# traitement de la zone commune
 		set erreurlambda1 [ expr $lc_deb - $crvalbleu- $cdeltnew * $ndebrouge_1 ]
 		set erreurlambda2 [ expr $lc_fin - $crvalbleu- $cdeltnew * ($newnaxisbleu-1) ]
  		::console::affiche_resultat " erreur arrondis= $erreurlambda1 cdeltnew= $cdeltnew \n"
  		::console::affiche_resultat " erreur secondaire (controle) = $erreurlambda2 cdeltnew= $cdeltnew \n"
  		::console::affiche_resultat " naxis1b = $naxis1b newnaxisbleu= $newnaxisbleu \n"
 		# commentaire Pat :je ne comprends pas pourquoi newnaxisbleu est != de naxis1b
  		set newnaxisbleu $naxis1b
 		for { set i $ndebrouge_1 } { $i < $newnaxisbleu } { incr i } { 
	 		set intensite_bleu [ lindex $intensitebleu $i ]
	 		set intensite_rouge [ lindex $intensiterouge [ expr $i -$ndebrouge_1 ] ]
	 		set nbechant [ expr $newnaxisbleu - $ndebrouge_1 ]
	 		set nbechant_1 [ expr $nbechant-1 ]
	 		set coefrouge [ expr ($i - $ndebrouge_1)*1. / ( $nbechant_1 * 1. ) ]
	 		set coefbleu [ expr ( $newnaxisbleu- 1 -$i )*1. / ( $nbechant_1 * 1. ) ]
	 		lappend intensite [ expr $coefrouge * $intensite_rouge + $coefbleu * $intensite_bleu ]
 		}
		set longrouge_2 [ expr $longrouge -2 ]
  		set debrouge [ expr $newnaxisbleu -$ndebrouge_1 ]
 		#::console::affiche_resultat " debrouge= $debrouge longrouge_2= $longrouge_2 \n"
		#::console::affiche_resultat " long =  [llength $intensite ]\n"
  		set intensite_suite [ lrange $intensiterouge $debrouge $longrouge_2 ]
 		#::console::affiche_resultat " long =  [llength $intensite_suite ]\n"
  		set intensite [ concat $intensite $intensite_suite ]
 		set newnaxis1 [ llength $intensite ]
	
		# creation du nouveau fichier 
 		set nbunit "float"
 		set nbunit1 "double"
 		buf$audace(bufNo) setpixels CLASS_GRAY $newnaxis1 1 FORMAT_FLOAT COMPRESS_NONE 0
  		buf$audace(bufNo) setkwd [ list "NAXIS" 1 int "" "" ]
 		buf$audace(bufNo) setkwd [list "NAXIS1" $newnaxis1 int "" ""]
 		buf$audace(bufNo) setkwd [list "NAXIS2" 1 int "" ""]
  		buf$audace(bufNo) setkwd [list "CRVAL1" $crvalbleu $nbunit1 "" "Angstrom"]
  		#-- Dispersion
  		buf$audace(bufNo) setkwd [list "CDELT1" $cdeltnew $nbunit1 "" "Angstrom/pixel"]
 		#--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
		# Une liste commence Ã  0 ; Un vecteur fits commence Ã  1
  		#set intensite [ list ]
 		for {set k 0} { $k < $newnaxis1 } {incr k} {
	 		#if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {}
	 		buf$audace(bufNo) setpix [list [expr $k+1] 1] [lindex $intensite $k ]  
  		}
  		#--- Sauvegarde du fichier fits ainsi crÃ©Ã©
      buf$audace(bufNo) bitpix float
      set suff _merged
      set nom_fich_output "$nom_fich_output$suff"
      buf$audace(bufNo) save "$audace(rep_images)/$nom_fich_output"
      ::console::affiche_resultat " nom fichier sortie $nom_fich_output \n"
      buf$audace(bufNo) bitpix short
      return $nom_fich_output 
   } else {
   	::console::affiche_erreur "Usage : spc_merge spectre1 spectre2\n\n"
   }
}
#*****************************************************************#



####################################################################
# Procedure d'élimination des bords dont les intensites sont nulles
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2008-07-08
# Date modification : 2008-12-18
# Arguments : fichier .fit du profil de raies (calibré linéairement) ?fraction de continuum (0.85)?
####################################################################

proc spc_rmedges { args } {

    global audace spcaudace
    global conf caption

    set nb_args [ llength $args ]
    if { $nb_args <= 2 } {
       if { $nb_args == 1 } {
          set spectre [ file rootname [ lindex $args 0 ] ]
          set frac_conti 0.85
       } elseif { $nb_args == 2 } {
          set spectre [ file rootname [ lindex $args 0 ] ]
          set frac_conti [ lindex $args 1 ]
       } else {
          ::console::affiche_erreur "Usage : spc_rmedges nom_profil_de_raies (calibré linéairement) ?fraction de continuum (0.85)?\n\n"
          return ""
       }

       #--- Chargement des paramètres du spectre :
       set conti_min [ expr $frac_conti*[ spc_icontinuum $spectre ] ]
       buf$audace(bufNo) load "$audace(rep_images)/$spectre"
       set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
       set dnaxis1 [ expr int(0.5*$naxis1) ]
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
          set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
          #-- Recupere la totalite des mots clef :
          set keywords ""
          foreach keywordName [ buf$audace(bufNo) getkwds ] {
             lappend keywords [ buf$audace(bufNo) getkwd $keywordName ]
          }
       } else {
          ::console::affiche_erreur "Le spectre doit être calibré et avec une loi linéaire.\n"
          return ""
       }
       set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]

       #--- Lecture des intensites :
       for { set i 1 } { $i <= $naxis1 } { incr i } {
          lappend intensites [ lindex [ buf$audace(bufNo) getpix [ list $i 1 ] ] 1 ]
       }

       #--- Détermine lambda_min et lambda_max :
       set xlistdeb1 0
       for { set i 1 } { $i<$dnaxis1 } { incr i } {
          set intA [ lindex $intensites $i ]
          set intB [ lindex $intensites [ expr $i+4 ] ]
          set pente [ expr (abs($intB)-abs($intA))/4. ]
          #-- Teste si il y a une pente assez croissante :
          if { $pente >= $spcaudace(croissbord) } {
             #-- Gestion des pentes douces (met de la souplesse a spcaudace(croissbord)) :
             if { [ lindex $intensites [ expr $i+2 ] ] >= $conti_min } {
                set xlistdeb1 [ expr $i+2 ]
                break
             } elseif { [ lindex $intensites [ expr $i+3 ] ] >= $conti_min } {
                set xlistdeb1 [ expr $i+3 ]
                break
             }
          }
       }
       set xlistfin1 [ expr $naxis1-1 ]
       for { set i [ expr $naxis1-1 ] } { $i>$dnaxis1 } { incr i -1 } {
          set intA [ lindex $intensites [ expr $i-4 ] ]
          set intB [ lindex $intensites $i ]
          set pente [ expr abs(abs($intA)-abs($intB))/4. ]
          #-- Teste si il y a une pente assez croissante :
          if { $pente >= $spcaudace(croissbord) } {
             #-- Gestion des pentes douces (met de la souplesse a spcaudace(croissbord)) :
             if { [ lindex $intensites [ expr $i-2 ] ] >= $conti_min } {
                set xlistfin1 [ expr $i-2 ]
                break
             } elseif { [ lindex $intensites [ expr $i-3 ] ] >= $conti_min }  {
                set xlistfin1 [ expr $i-3 ]
                break
             }
          }
       }
       #::console::affiche_resultat "$conti_min ; $xlistdeb -> ([ expr $crval1+$cdelt1*$xlistdeb ], [ lindex $intensites $xlistdeb ]) ; $xlistfin -> ([ expr $crval1+$cdelt1*$xlistfin ], [ lindex $intensites $xlistfin ]) \n"

       #--- Seconde passe pour effacer les irréductibles échantillons vraiment nuls :
       set xlistdeb $xlistdeb1
       for { set i $xlistdeb1 } { $i <= $dnaxis1 } { incr i } {
          if { [ lindex $intensites $i ] != 0.} {
             set xlistdeb [ expr $i ]
             break
          }
       }
       set xlistfin $xlistfin1
       for { set i $xlistdeb1 } { $i >= $dnaxis1 } { incr i -1 } {
          if { [ lindex $intensites $i ] != 0. } {
             set xlistfin [ expr $i ]
             break
          }
       }

       #--- Decoupage des bords du profil de raies :
       set new_longueur [ expr $xlistfin-$xlistdeb+1 ]
       #set lambda_deb [ expr $crval1+$cdelt1*($xlistdeb-1) ]
       set lambda_deb [ expr $crval1+$cdelt1*$xlistdeb ]

       #--- Creation du nouveau profil de raies :
       buf$audace(bufNo) load "$audace(rep_images)/$spectre"
       set newBufNo [ buf::create ]
       buf$newBufNo setpixels CLASS_GRAY $new_longueur 1 FORMAT_FLOAT COMPRESS_NONE 0
       foreach keyword $keywords {
          buf$newBufNo setkwd $keyword
       }
       buf$newBufNo setkwd [ list "NAXIS" 1 int "" "" ]
       buf$newBufNo setkwd [ list "NAXIS1" $new_longueur int "" "" ]
       #-- k=compteur des pixels ; i=index des intensites a prendre dans la liste de selection.
       set k 1
       for { set i $xlistdeb } { $i <= $xlistfin } { incr i } {
          # buf$newBufNo setpix [ list $k 1 ] [ lindex $intensites $i ]
          buf$newBufNo setpix [ list $k 1 ] [ lindex [ buf$audace(bufNo) getpix [ list [ expr $i+1 ] 1 ] ] 1 ]
          incr k
       }
       buf$newBufNo setkwd [ list "CRVAL1" $lambda_deb double "" "" ]
       buf$newBufNo bitpix float
       buf$newBufNo save "$audace(rep_images)/${spectre}_sel"
       buf::delete $newBufNo
       ::console::affiche_resultat "Spectre nettoyé des bords sauvé sous ${spectre}_sel\n"
       return ${spectre}_sel
    } else {
        ::console::affiche_erreur "Usage : spc_rmedges nom_profil_de_raies (calibré linéairement) ?fraction de continuum (0.85)?\n\n"
    }
}
#*****************************************************************#




###############################################################################
# Descirption : effectue le prétraitement d'une série d'images brutes
#
# Auteur : Benjamin MAUCLAIRE
# Date création : 27-08-2005
# Date de mise à jour : 21-12-2005/2007-01-03/2007-07-10/2007-08-01
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu effacement des masters (O/n) ?liste_coordonnées_fenêtre_étude?
# Méthode : par soustraction du noir et sans offset.
# Bug : Il faut travailler dans le rep parametre d'Audela, donc revoir toutes les operations !!
###############################################################################

proc spc_pretrait { args } {

   global audace spcaudace
   global conf

   set nbargs [ llength $args ]
   if {$nbargs <= 7} {
       if { $nbargs== 4} {
           #--- On se place dans le répertoire d'images configuré dans Audace
           set repdflt [ spc_goodrep ]
           set nom_stellaire [ file rootname [ file tail [ lindex $args 0 ] ] ]
           set nom_dark [ file rootname [ file tail [ lindex $args 1 ] ] ]
           set nom_flat [ file rootname [ file tail [ lindex $args 2 ] ] ]
           set nom_darkflat [ file rootname [ file tail [ lindex $args 3 ] ] ]
           set nom_offset "none"
           set flag_rmmaster "o"
           set flag_nonstellaire 0
       } elseif {$nbargs == 5} {
           #--- On se place dans le répertoire d'images configuré dans Audace
           set repdflt [ spc_goodrep ]
           set nom_stellaire [ file rootname [ file tail [ lindex $args 0 ] ] ]
           set nom_dark [ file rootname [ file tail [ lindex $args 1 ] ] ]
           set nom_flat [ file rootname [ file tail [ lindex $args 2 ] ] ]
           set nom_darkflat [ file rootname [ file tail [ lindex $args 3 ] ] ]
           set nom_offset [ file rootname [ file tail [ lindex $args 4 ] ] ]
           set flag_rmmaster "o"
           set flag_nonstellaire 0
       } elseif {$nbargs == 6} {
           #--- On se place dans le répertoire d'images configuré dans Audace
           set repdflt [ spc_goodrep ]
           set nom_stellaire [ file rootname [ file tail [ lindex $args 0 ] ] ]
           set nom_dark [ file rootname [ file tail [ lindex $args 1 ] ] ]
           set nom_flat [ file rootname [ file tail [ lindex $args 2 ] ] ]
           set nom_darkflat [ file rootname [ file tail [ lindex $args 3 ] ] ]
           set nom_offset [ file rootname [ file tail [ lindex $args 4 ] ] ]
           set flag_rmmaster [ lindex $args 5 ]
           set flag_nonstellaire 0
       } elseif {$nbargs == 7} {
           #--- On se place dans le répertoire d'images configuré dans Audace
           set repdflt [ spc_goodrep ]
           set nom_stellaire [ file rootname [ file tail [ lindex $args 0 ] ] ]
           set nom_dark [ file rootname [ file tail [ lindex $args 1 ] ] ]
           set nom_flat [ file rootname [ file tail [ lindex $args 2 ] ] ]
           set nom_darkflat [ file rootname [ file tail [ lindex $args 3 ] ] ]
           set nom_offset [ file rootname [ file tail [ lindex $args 4 ] ] ]
           set flag_rmmaster [ lindex $args 5 ]
           set spc_windowcoords [ lindex $args 6 ]
           set flag_nonstellaire 1
       } else {
           ::console::affiche_erreur "Usage: spc_pretrait nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu ?nom_offset (none)? ?effacement des masters (o/n)? ?liste_coordonnées_fenêtre_étude?\n\n"
           return ""
       }


       #--- Compte les images :
       ## Renumerote chaque série de fichier
       #renumerote $nom_stellaire
       #renumerote $nom_dark
       #renumerote $nom_flat
       #renumerote $nom_darkflat

       ## Détermine les listes de fichiers de chasue série
       #set dark_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_dark}\[0-9\]*$conf(extension,defaut) ] ]
       #set nb_dark [ llength $dark_liste ]
       #set flat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_flat}\[0-9\]*$conf(extension,defaut) ] ]
       #set nb_flat [ llength $flat_liste ]
       #set darkflat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_darkflat}\[0-9\]*$conf(extension,defaut) ] ]
       #set nb_darkflat [ llength $darkflat_liste ]
       #---------------------------------------------------------------------------------#
       if { 1==0 } {
       set stellaire_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut)${nom_stellaire}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut)  ] ]
       set nb_stellaire [ llength $stellaire_liste ]
       #-- Gestion du cas des masters au lieu d'une série de fichier :
       if { [ catch { glob -dir $audace(rep_images) ${nom_dark}\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]$conf(extension,defaut) } ] } {
           set dark_list [ list $nom_dark ]
           set nb_dark 1
       } else {
           set dark_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_dark}\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_dark [ llength $dark_liste ]
       }
       if { [ catch { glob -dir $audace(rep_images) ${nom_flat}\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]$conf(extension,defaut) } ] } {
           set flat_list [ list $nom_flat ]
           set nb_flat 1
       } else {
           set flat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_flat}\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_flat [ llength $flat_liste ]
       }
       if { [ catch { glob -dir $audace(rep_images) ${nom_darkflat}\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]$conf(extension,defaut) } ] } {
           set darkflat_list [ list $nom_darkflat ]
           set nb_darkflat 1
       } else {
           set darkflat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_darkflat}\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_darkflat [ llength $darkflat_liste ]
       }
       }
       #---------------------------------------------------------------------------------#

       #--- Compte les images :
       if { [ file exists "$audace(rep_images)/$nom_stellaire$conf(extension,defaut)" ] } {
           set stellaire_liste [ list $nom_stellaire ]
           set nb_stellaire 1
       } elseif { [ catch { glob -dir $audace(rep_images) ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
           renumerote $nom_stellaire
           set stellaire_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_stellaire [ llength $stellaire_liste ]
       } else {
           ::console::affiche_erreur "Le(s) fichier(s) $nom_stellaire n'existe(nt) pas.\n"
           return ""
       }
       if { [ file exists "$audace(rep_images)/$nom_dark$conf(extension,defaut)" ] } {
           set dark_liste [ list $nom_dark ]
           set nb_dark 1
       } elseif { [ catch { glob -dir $audace(rep_images) ${nom_dark}\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
           renumerote $nom_dark
           set dark_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_dark}\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_dark [ llength $dark_liste ]
       } else {
           ::console::affiche_erreur "Le(s) fichier(s) $nom_dark n'existe(nt) pas.\n"
           return ""
       }
       if { [ file exists "$audace(rep_images)/$nom_flat$conf(extension,defaut)" ] } {
           set flat_list [ list $nom_flat ]
           set nb_flat 1
       } elseif { [ catch { glob -dir $audace(rep_images) ${nom_flat}\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
           renumerote $nom_flat
           set flat_list [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_flat}\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_flat [ llength $flat_list ]
       } else {
           ::console::affiche_erreur "Le(s) fichier(s) $nom_flat n'existe(nt) pas.\n"
           return ""
       }
       if { [ file exists "$audace(rep_images)/$nom_darkflat$conf(extension,defaut)" ] } {
           set darkflat_list [ list $nom_darkflat ]
           set nb_darkflat 1
       } elseif { [ catch { glob -dir $audace(rep_images) ${nom_darkflat}\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
           renumerote $nom_darkflat
           set darkflat_list [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_darkflat}\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_darkflat [ llength $darkflat_list ]
       } else {
           ::console::affiche_erreur "Le(s) fichier(s) $nom_darkflat n'existe(nt) pas.\n"
           return ""
       }
       if { $nom_offset!="none" } {
           if { [ file exists "$audace(rep_images)/$nom_offset$conf(extension,defaut)" ] } {
               set offset_list [ list $nom_offset ]
               set nb_offset 1
           } elseif { [ catch { glob -dir $audace(rep_images) ${nom_offset}\[0-9\]$conf(extension,defaut) ${nom_offset}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_offset}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
               renumerote $nom_offset
               set offset_list [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_offset}\[0-9\]$conf(extension,defaut) ${nom_offset}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_offset}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
               set nb_offset [ llength $offset_list ]
           } else {
               ::console::affiche_erreur "Le(s) fichier(s) $nom_offset n'existe(nt) pas.\n"
               return ""
           }
       }


       #--- Isole le préfixe des noms de fichiers dans le cas ou ils possedent un "-" avant le n° :
       set pref_stellaire ""
       set pref_dark ""
       set pref_flat ""
       set pref_darkflat ""
       set pref_offset ""
       regexp {(.+)\-?[0-9]+} $nom_stellaire match pref_stellaire
       regexp {(.+)\-?[0-9]+} $nom_dark match pref_dark
       regexp {(.+)\-?[0-9]+} $nom_flat match pref_flat
       regexp {(.+)\-?[0-9]+} $nom_darkflat match pref_darkflat
       regexp {(.+)\-?[0-9]+} $nom_offset match pref_offset
       #-- En attendant de gerer le cas des fichiers avec des - au milieu du nom de fichier
       set pref_stellaire $nom_stellaire
       set pref_dark $nom_dark
       set pref_flat $nom_flat
       set pref_darkflat $nom_darkflat
       set pref_offset $nom_offset

       ::console::affiche_resultat "brut=$pref_stellaire, dark=$pref_dark, flat=$pref_flat, df=$pref_darkflat, offset=$pref_offset\n"
       #-- La regexp ne fonctionne pas bien pavec des noms contenant des "_"
       if {$pref_stellaire == ""} {
           set pref_stellaire $nom_stellaire
       }
       if {$pref_dark == ""} {
           set pref_dark $nom_dark
       }
       if {$pref_flat == ""} {
           set pref_flat $nom_flat
       }
       if {$pref_darkflat == ""} {
           set pref_darkflat $nom_darkflat
       }
       if {$pref_offset == ""} {
           set pref_offset $nom_offset
       }
       # ::console::affiche_resultat "Corr : b=$pref_stellaire, d=$pref_dark, f=$pref_flat, df=$pref_darkflat\n"


       #--- Prétraitement des flats :
       #-- Somme médiane des dark, dark_flat et offset :
       if { $nb_dark == 1 } {
           ::console::affiche_resultat "L'image de dark est $nom_dark$conf(extension,defaut)\n"
           set pref_dark $nom_dark
           file copy -force $nom_dark$conf(extension,defaut) ${pref_dark}-smd$nb_dark$conf(extension,defaut)
       } else {
           ::console::affiche_resultat "Somme médiane de $nb_dark dark(s)...\n"
           smedian "$nom_dark" "${pref_dark}-smd$nb_dark" $nb_dark
       }
       if { $nb_darkflat == 1 } {
           ::console::affiche_resultat "L'image de dark de flat est $nom_darkflat$conf(extension,defaut)\n"
           set pref_darkflat "$nom_darkflat"
           file copy -force $nom_darkflat$conf(extension,defaut) ${pref_darkflat}-smd$nb_darkflat$conf(extension,defaut)
       } else {
           ::console::affiche_resultat "Somme médiane de $nb_darkflat dark(s) associé(s) aux flat(s)...\n"
           smedian "$nom_darkflat" "${pref_darkflat}-smd$nb_darkflat" $nb_darkflat
       }
       if { $nom_offset!="none" } {
           if { $nb_offset == 1 } {
               ::console::affiche_resultat "L'image de offset est $nom_offset$conf(extension,defaut)\n"
               set pref_offset $nom_offset
               file copy -force $nom_offset$conf(extension,defaut) ${pref_offset}-smd$nb_offset$conf(extension,defaut)
           } else {
               ::console::affiche_resultat "Somme médiane de $nb_offset offset(s)...\n"
               smedian "$nom_offset" "${pref_offset}-smd$nb_offset" $nb_offset
           }
       }

       #-- Soustraction du master_dark aux images de flat :
       if { $nom_offset=="none" } {
           ::console::affiche_resultat "Soustraction des noirs associés aux plus...\n"
           if { $nb_flat == 1 } {
               set pref_flat $nom_flat
               buf$audace(bufNo) load "$nom_flat"
               buf$audace(bufNo) sub "${pref_darkflat}-smd$nb_darkflat" 0
               buf$audace(bufNo) save "${pref_flat}-smd$nb_flat"
           } else {
               sub2 "$nom_flat" "${pref_darkflat}-smd$nb_darkflat" "${pref_flat}_moinsnoir-" 0 $nb_flat
               set flat_moinsnoir_1 [ lindex [ lsort -dictionary [ glob ${pref_flat}_moinsnoir-\[0-9\]*$conf(extension,defaut) ] ] 0 ]
               #set flat_traite_1 [ lindex [ glob ${pref_flat}_moinsnoir-*$conf(extension,defaut) ] 0 ]
           }
       } else {
           ::console::affiche_resultat "Optimisation des noirs associés aux plus...\n"
           if { $nb_flat == 1 } {
               set pref_flat $nom_flat
               buf$audace(bufNo) load "$nom_flat"
               buf$audace(bufNo) opt "${pref_darkflat}-smd$nb_darkflat" "${pref_offset}-smd$nb_offset"
               buf$audace(bufNo) save "${pref_flat}-smd$nb_flat"
           } else {
               opt2 "$nom_flat" "${pref_darkflat}-smd$nb_darkflat" "${pref_offset}-smd$nb_offset" "${pref_flat}_moinsnoir-" $nb_flat
               set flat_moinsnoir_1 [ lindex [ lsort -dictionary [ glob ${pref_flat}_moinsnoir-\[0-9\]*$conf(extension,defaut) ] ] 0 ]
           }
       }

       #-- Harmonisation des flats et somme médiane :
       if { $nb_flat == 1 } {
           # Calcul du niveau moyen de la première image
           #buf$audace(bufNo) load "${pref_flat}_moinsnoir-1"
           #set intensite_moyenne [lindex [stat] 4]
           ## Mise au même niveau de toutes les images de PLU
           #::console::affiche_resultat "Mise au même niveau de l'image de PLU...\n"
           #ngain $intensite_moyenne
           #buf$audace(bufNo) save "${pref_flat}-smd$nb_flat"
           #file copy ${pref_flat}_moinsnoir-$nb_flat$conf(extension,defaut) ${pref_flat}-smd$nb_flat$conf(extension,defaut)
           ::console::affiche_resultat "Le flat prétraité est ${pref_flat}-smd$nb_flat\n"
       } else {
           # Calcul du niveau moyen de la première image
           buf$audace(bufNo) load "$flat_moinsnoir_1"
           set intensite_moyenne [ lindex [stat] 4 ]
           # Mise au même niveau de toutes les images de PLU
           ::console::affiche_resultat "Mise au même niveau de toutes les images de PLU...\n"
           ngain2 "${pref_flat}_moinsnoir-" "${pref_flat}_auniveau-" $intensite_moyenne $nb_flat
           ::console::affiche_resultat "Somme médiane des flat prétraités...\n"
           smedian "${pref_flat}_auniveau-" "${pref_flat}-smd$nb_flat" $nb_flat
           #file delete [ file join [ file rootname ${pref_flat}_auniveau-]$conf(extension,defaut) ]
           delete2 "${pref_flat}_auniveau-" $nb_flat
           delete2 "${pref_flat}_moinsnoir-" $nb_flat
       }

       #-- Normalisation et binning des flats pour les spectres sur la bande horizontale (naxis1) d'étude :
       if { $spcaudace(binned_flat) == "o" } {
          if { $flag_nonstellaire==1 } {
             #- Ne pas faire de superflat normalisé ? A tester.
             set hauteur [ expr [ lindex $spc_windowcoords 3 ] - [ lindex $spc_windowcoords 1 ] ]
             set ycenter [ expr round(0.5*$hauteur)+[ lindex $spc_windowcoords 1 ] ]
             set flatnorma [ spc_normaflat "${pref_flat}-smd$nb_flat" $ycenter $hauteur ]
             file rename -force "$audace(rep_images)/$flatnorma$conf(extension,defaut)" "$audace(rep_images)/${pref_flat}-smd$nb_flat$conf(extension,defaut)"
          } else {
             set fmean [ bm_smean $nom_stellaire ]
             set spc_params [ spc_detect $fmean ]
             set ycenter [ lindex $spc_params 0 ]
             set hauteur [ lindex $spc_params 1 ]
             if { $hauteur <= $spcaudace(largeur_binning) } {
                # set fpretraitbis [ bm_pretrait "$nom_stellaire" "${pref_dark}-smd$nb_dark" "$nom_flat" "${pref_darkflat}-smd$nb_darkflat" ]
                # set fsmean [ bm_smean "$fpretraitbis" ]
                # set hauteur [ lindex [ spc_detect "$fsmean" ] 1 ]
                # delete2 "fpretraitbis" $nb_stellaire
                # file delete -force "$audace(rep_images)/$fsmean$conf(extension,defaut)"
                #-- Met a 21 pixels la hauteur de binning du flat :
                set hauteur [ expr 3*$spcaudace(largeur_binning) ]
             }
             file delete -force "$audace(rep_images)/$fmean$conf(extension,defaut)"
             set flatnorma [ spc_normaflat "${pref_flat}-smd$nb_flat" $ycenter $hauteur ]
             file rename -force "$audace(rep_images)/$flatnorma$conf(extension,defaut)" "$audace(rep_images)/${pref_flat}-smd$nb_flat$conf(extension,defaut)"
          }
       } elseif { $spcaudace(binned_flat) == "n" } {
          buf$audace(bufNo) load "$audace(rep_images)/${pref_flat}-smd$nb_flat"
          set intensite_moy [ lindex [ buf$audace(bufNo) stat ] 4 ]
          buf$audace(bufNo) mult [ expr 1./$intensite_moy ]
          buf$audace(bufNo) bitpix float
          buf$audace(bufNo) save "$audace(rep_images)/${pref_flat}-smd$nb_flat"
          buf$audace(bufNo) bitpix short
       }

       #--- Prétraitement des images stellaires :
       #-- Soustraction du noir des images stellaires :
       ::console::affiche_resultat "Soustraction du noir des images stellaires...\n"
       if { $nom_offset=="none" } {
           ::console::affiche_resultat "Soustraction des noirs associés aux images stellaires...\n"
           if { $nb_stellaire==1 } {
               set pref_stellaire "$nom_stellaire"
               buf$audace(bufNo) load "$nom_stellaire"
               buf$audace(bufNo) sub "${pref_dark}-smd$nb_dark" 0
               buf$audace(bufNo) save "${pref_stellaire}_moinsnoir"
           } else {
               sub2 "$nom_stellaire" "${pref_dark}-smd$nb_dark" "${pref_stellaire}_moinsnoir-" 0 $nb_stellaire
           }
       } else {
           ::console::affiche_resultat "Optimisation des noirs associés aux images stellaires...\n"
           if { $nb_stellaire==1 } {
               set pref_stellaire "$nom_stellaire"
               buf$audace(bufNo) load "$nom_stellaire"
               buf$audace(bufNo) opt "${pref_dark}-smd$nb_dark" "${pref_offset}-smd$nb_offset"
               buf$audace(bufNo) save "${pref_stellaire}_moinsnoir"
           } else {
               opt2 "$nom_stellaire" "${pref_dark}-smd$nb_dark" "${pref_offset}-smd$nb_offset" "${pref_stellaire}_moinsnoir-" $nb_stellaire
           }
       }

       #-- Calcul du niveau moyen de la PLU traitée :
       buf$audace(bufNo) load "${pref_flat}-smd$nb_flat"
       set intensite_moyenne [ lindex [stat] 4 ]

       #-- Division des images stellaires par la PLU :
       ::console::affiche_resultat "Division des images stellaires par la PLU normalisée...\n"
       div2 "${pref_stellaire}_moinsnoir-" "${pref_flat}-smd$nb_flat" "${pref_stellaire}-t-" $intensite_moyenne $nb_stellaire
       set image_traite_1 [ lindex [ lsort -dictionary [ glob ${pref_stellaire}-t-\[0-9\]*$conf(extension,defaut) ] ] 0 ]


       #--- Affichage et netoyage :
       loadima "$image_traite_1"
       ::console::affiche_resultat "Affichage de la première image prétraitée\n"
       delete2 "${pref_stellaire}_moinsnoir-" $nb_stellaire
       # if { $flag_rmmaster == "o" } {
           #-- Le 06/02/19 :
           # file delete -force "${pref_dark}-smd$nb_dark$conf(extension,defaut)"
           # file delete -force "${pref_flat}-smd$nb_flat$conf(extension,defaut)"
           file rename -force "$audace(rep_images)/${pref_flat}-smd$nb_flat$conf(extension,defaut)" "$audace(rep_images)/${pref_flat}-obtained-smd$nb_flat$conf(extension,defaut)"
           # file delete -force "${pref_darkflat}-smd$nb_darkflat$conf(extension,defaut)"
       # }

       #-- Effacement des fichiers copie des masters dark, flat et dflat dus a la copie automatique de pretrait :
       if { [ regexp {.+-smd[0-9]+-smd[0-9]+} ${pref_dark}-smd$nb_dark match resul ] } {
           file delete -force "${pref_dark}-smd$nb_dark$conf(extension,defaut)"
       }
       if { [ regexp {.+-smd[0-9]+-smd[0-9]+} ${pref_flat}-smd$nb_flat match resul ] } {
           file delete -force "${pref_flat}-smd$nb_flat$conf(extension,defaut)"
       }
       if { [ regexp {.+-smd[0-9]+-smd[0-9]+} ${pref_darkflat}-smd$nb_darkflat match resul ] } {
           file delete -force "${pref_darkflat}-smd$nb_darkflat$conf(extension,defaut)"
       }


       #--- Retour dans le répertoire de départ avnt le script
       return ${pref_stellaire}-t-
   } else {
       ::console::affiche_erreur "Usage: spc_pretrait nom_generique_images_objet (sans extension fit) nom_dark nom_plu nom_dark_plu ?nom_offset (none)? ?effacement des masters (o/n)? ?liste_coordonnées_fenêtre_étude?\n\n"
   }
}
#****************************************************************************#


###############################################################################
# Description : Effectue la somme dédiée spectroscopie d'une serie d'images appariees
# Auteur : Benjamin MAUCLAIRE
# Date creation : 09-09-2007
# Date de mise a jour : 09-09-2007
# Argument : nom_generique_fichier (sans extension) ?methode somme?
###############################################################################

proc spc_somme { args } {
   global audace
   global conf

   set nb_args [ llength $args]
   if { $nb_args <= 2 } {
      if { $nb_args == 1 } {
         set nom_generique [ file tail [ file rootname [ lindex $args 0 ] ] ]
         set methsomme "moy"
         # faire une var globalle
      } elseif { $nb_args == 2 } {
         set nom_generique [ file tail [ file rootname [ lindex $args 0 ] ] ]
         set methsomme [ lindex $args 1 ]
      } else {
         ::console::affiche_erreur "Usage: spc_somme nom_generique_fichier ?méthode somme (add/moy)?\n\n"
         return ""
      }

       set liste_fichiers [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_generique}\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
       set nb_file [ llength $liste_fichiers ]

       #--- Gestion de la durée totale d'exposition :
       buf$audace(bufNo) load [ lindex $liste_fichiers 0 ]
       #-- Pour contrecarer l'influence de smean sur date-obs 20081004 :
       set dateobs_img1 [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "EXPOSURE" ] !=-1 } {
           set unit_exposure [ lindex [ buf$audace(bufNo) getkwd "EXPOSURE" ] 1 ]
       } elseif { [ lsearch $listemotsclef "EXPTIME" ] !=-1 } {
           set unit_exposure [ lindex [ buf$audace(bufNo) getkwd "EXPTIME" ] 1 ]
       } else {
           set unit_exposure 0
       }
       set exposure [ expr $unit_exposure*$nb_file ]

       #--- Somme :
       ::console::affiche_resultat "Somme de $nb_file images...\n"
       renumerote "$nom_generique"
      if { $methsomme == "add" } {
         sadd "$nom_generique" "${nom_generique}-s$nb_file" $nb_file
         # in out number first_index "bitpix=32"
      } elseif { $methsomme == "moy" } {
         smean "$nom_generique" "${nom_generique}-s$nb_file" $nb_file
      }

       #--- Calcul de EXPTIME et MID-HJD :
       #-- Extime :
       set exptime [ bm_exptime $nom_generique ]

       #-- Recuperation de la date de la derniere image :
       buf$audace(bufNo) load [ lindex $liste_fichiers [ expr $nb_file-1 ] ]
       set dateobsend [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
       set mjdobsend [ mc_date2jd $dateobsend ]
       set mjdobsend [ expr $mjdobsend+$unit_exposure/86400. ]

       #-- Récuperation de la date de début des poses :
       buf$audace(bufNo) load "$audace(rep_images)/${nom_generique}-s$nb_file"
       set dateobs [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
       set mjdobsdeb [ mc_date2jd $dateobs ]

       #-- Création de MID-HJD :
       #- Calcul a revoir car il doit etre tenu compte de  date julienne heliocentrique qui tient compte de la position de la terre sur son orbite et la ramène au soleil.
       set midhjd [ expr 0.5*($mjdobsend+$mjdobsdeb) ]
       # ::console::affiche_resultat "end=$mjdobsend ; deb=$mjdobsdeb ; mid=$midhjd\n"
       buf$audace(bufNo) setkwd [ list "MID-JD" $midhjd double "Heliocentric Julian Date at mid-exposure" "day" ]
       if { [ lsearch $listemotsclef "DATE-END" ] !=-1 } {
           buf$audace(bufNo) delkwd "DATE-END"
       }
       #--- Mise a jour du motclef EXPTIME : calcul en fraction de jour
       buf$audace(bufNo) setkwd [ list "EXPTIME" $exptime float "Total duration: dobsN-dobs1+1 exposure" "second" ]
       buf$audace(bufNo) setkwd [ list "EXPOSURE" $exposure float "Total time of exposure" "second" ]
       #-- Corrige l'influence de smean sur dateobs 20081004 :
       buf$audace(bufNo) setkwd [ list "DATE-OBS" $dateobs_img1 string "" "" ]
       buf$audace(bufNo) save "$audace(rep_images)/${nom_generique}-s$nb_file"

       #--- Traitement du resultat :
       ::console::affiche_resultat "Somme sauvées sous ${nom_generique}-s$nb_file\n"
       return "${nom_generique}-s$nb_file"
   } else {
       ::console::affiche_erreur "Usage: spc_somme nom_generique_fichier ?méthode somme (add/moy)?\n\n"
   }
}
#-----------------------------------------------------------------------------#


###############################################################################
# Description : Effectue la somme dédiée spectroscopie d'une serie d'images appariees
# Auteur : Benjamin MAUCLAIRE
# Date creation : 09-09-2007
# Date de mise a jour : 09-09-2007
# Argument : nom_generique_fichier (sans extension)
###############################################################################

proc spc_uncosmic { args } {
    global audace spcaudace
    global conf

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
        if { $nbargs == 1 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set coefcos $spcaudace(uncosmic)
        } elseif { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set coefcos [ lindex ârgs 1 ]
        } else {
            ::console::affiche_erreur "Usage: spc_uncosmic image_fits_2D ?coef (0.85)?\n\n"
        }

        #--- Effectue uncosmic :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        uncosmic $coefcos
        uncosmic $coefcos
        buf$audace(bufNo) save "$audace(rep_images)/$filename"
        return "$filename"
   } else {
       ::console::affiche_erreur "Usage: spc_uncosmic image_fits_2D ?coef (0.85)?\n\n"
   }
}
#-----------------------------------------------------------------------------#



####################################################################
# Procedure de normalisation automatique de profil de raies
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 7-09-2007
# Date modification : 7-09-2007
# Arguments : fichier .fit du profil de raies, nombre
####################################################################

proc spc_mult { args } {

    global audace
    global conf caption

    if { [llength $args] == 2 } {
        set fichier [ file rootname [ lindex $args 0 ] ]
        set coef [ lindex $args 1 ]

        #--- Multiplie les intensités une à une :
        set intensites [ lindex [ spc_fits2data "$fichier" ] 1 ]
        buf$audace(bufNo) load "$audace(rep_images)/$fichier"
        set i 1
        foreach intensite $intensites {
            buf$audace(bufNo) setpix [ list $i 1 ] [ expr $intensite*$coef ]
            incr i
        }

        #-- Traitement des résultats :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${fichier}_mult"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Profil multiplié sauvé sous ${fichier}_mult\n"
        return "${fichier}_mult"
    } else {
        ::console::affiche_erreur "Usage : spc_mult nom_profil_de_raies nombre\n\n"
    }
}
#*****************************************************************#



##########################################################
# Procedure de normalisation de profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 15-08-2005
# Date de mise à jour : 15-08-2005
# Arguments : fichier .fit du profil de raie, largeur de raie (optionnelle)
##########################################################

proc spc_norma { args } {

   global audace caption
   global conf
   set pourcent 0.95

   if {[llength $args] <= 2} {
       if {[llength $args] == 2} {
           set fichier [ file rootname [ lindex $args 0 ] ]
           set lraie [lindex $args 1 ]
       } elseif {[llength $args] == 1} {
           set fichier [ lindex $args 0 ]
           set lraie 20
       } elseif { [llength $args]==0 } {
           set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
           if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
               set fichier $spctrouve
               set lraie 20
           } else {
               ::console::affiche_erreur "Usage : spc_norma nom_fichier ?largeur de raie?\n\n"
               return 0
           }
       } else {
           ::console::affiche_erreur "Usage : spc_norma nom_fichier ?largeur de raie?\n\n"
           return 0
       }

       #--- Filtrage d'élimination des raies :
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent div"
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/${fichier}_norm$conf(extension,defaut)"
       buf$audace(bufNo) bitpix short
       ::console::affiche_resultat "Profil normalisé sauvé sous ${fichier}_norm$conf(extension,defaut)\n"
   } else {
       ::console::affiche_erreur "Usage : spc_norma nom_fichier ?largeur de raie?\n\n"
   }
}
#*****************************************************************#




##########################################################
# Normalisation d'un profil sur le continuum au voisinage d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 24-03-2006
# Date de mise à jour : 24-03-2006
# Arguments : fichier .fit du profil de raie, x_debut (wavelength), x_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_normaraie { args } {

   global audace
   global conf
   #set coeffajust 1.1848
   set coeffajust 1.0924


   if {[llength $args] == 4} {
     set fichier [ file rootname [ lindex $args 0 ] ]
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
         # Inverse de nouveau le spectre pour le rendre comme l'original
         # buf$audace(bufNo) mult -1.0
     } elseif { [string compare $type "e"] == 0 } {
         set lreponse [buf$audace(bufNo) fitgauss $listcoords]
     }
     #--- Le n°3 rendu par fitgauss est la valeur de fond selon X :
     # set continuum [lindex $lreponse 3]
     #--- Le n°7 rendu par fitgauss est la valeur de fond selon Y :
     set continuum [lindex $lreponse 7]
     #set centre [ expr $xcentre*$cdelt+$crval ]
     set continuum [ expr $continuum/$coeffajust ]
     ::console::affiche_resultat "Le continuum vaut $continuum\n"

     #--- Meth 1 : division de chaque valeur du profil par la valeur du continuum
     #set coords [ spc_fits2data $fichier ]
     #set lambdas [ lindex $coords 0 ]
     #set intensites [ lindex $coords 1 ]
     #foreach intensite $intensites {
         #lappend newintensites [ expr $intensite/$continuum ]
     #}
     #set pref_fichier [ file rootname $fichier ]
     #set newcoords [ list $lambdas $newintensites ]
     #set ${pref_fichier}_lnorm [ spc_data2fits ${pref_fichier}_lnorm $newcoords double ]

     #--- Meth 2 (approuvé Buil) : coefmult=1/continuum
     set coeff [ expr 1./$continuum ]
     ::console::affiche_resultat "Coéfficient de normalisation : $coeff\n"
     buf$audace(bufNo) mult $coeff
     buf$audace(bufNo) setkwd [ list "BSS_NORM" "Scaled on continuum closed to main line" string "Method used for normalisation" ""]
     buf$audace(bufNo) bitpix float
     buf$audace(bufNo) save "$audace(rep_images)/${fichier}_lnorm"
     buf$audace(bufNo) bitpix short
     #--- Fin du script :
     ::console::affiche_resultat "Profil localement normalisé sauvé sous ${fichier}_lnorm.\n"
     return ${fichier}_lnorm
   } else {
     ::console::affiche_erreur "Usage: spc_normaraie nom_fichier (de type fits) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#



####################################################################
# Procedure de mise à l'échelle du conitnuum à 1
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-03-2007
# Date modification : 18-03-2007 ; 20-09-2008
# Arguments : fichier .fit du profil de raies
####################################################################

proc spc_rescalecont { args } {

    global audace
    global conf caption

    if { [llength $args]<=1 } {
       if { [llength $args] == 1 } {
           set fichier [ file rootname [ lindex $args 0 ] ]
       } elseif { [llength $args]==0 } {
           set spctrouve [ file rootname [ file tail [ tk_getOpenFile -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
           if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
               set fichier $spctrouve
           } else {
               ::console::affiche_erreur "Usage : spc_rescalecont nom_profil_de_raies\n\n"
               return 0
           }
       } else {
           ::console::affiche_erreur "Usage : spc_rescalecont nom_profil_de_raies\n\n"
          return 0
       }
        #--- Détermination de la valeur du continuum :
        set icont [ spc_icontinuum $fichier ]
        if { $icont == 0 } {
            ::console::affiche_erreur "Continuum trouvé égal à 0. Le spectre ne sera pas normalisé.\n"
            return "$fichier"
        } else {
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            buf$audace(bufNo) mult [ expr 1./$icont ]
            buf$audace(bufNo) setkwd [ list "SPC_NORM" "Rescaling local middle continuum" string "Process used for transforming the continuum" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${fichier}_norm"
            buf$audace(bufNo) bitpix short
            ::console::affiche_resultat "Profil normalisé sauvé sous ${fichier}_norm\n"
            return "${fichier}_norm"
        }
    } else {
        ::console::affiche_erreur "Usage : spc_rescalecont nom_profil_de_raies\n\n"
    }
}
#*****************************************************************#



####################################################################
# Procedure de normalisation automatique de profil de raies par exctraction du continuum
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 04-04-2008
# Date modification : 04-04-2008
# Arguments : fichier .fit du profil de raies
####################################################################

proc spc_autonorma { args } {

    global audace
    global conf caption spcaudace

    if { [llength $args]<=2 } {
       if { [llength $args] == 1 } {
          set fichier [ file rootname [ lindex $args 0 ] ]
          set flag_rm 1
       } elseif { [llength $args] == 2 } {
          set fichier [ file rootname [ lindex $args 0 ] ]
          if { [ lindex $args 1 ] == "n" } {
             set flag_rm 0
          } else {
             set flag_rm 1
          }
       } elseif { [llength $args]==0 } {
           set spctrouve [ file rootname [ file tail [ tk_getOpenFile -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
           if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
              set fichier $spctrouve
              set flag_rm 1
           } else {
               ::console::affiche_erreur "Usage : spc_autonorma nom_profil_de_raies ?effacer fichier continuum (O/n)\n\n"
               return 0
           }
       } else {
           ::console::affiche_erreur "Usage : spc_autonorma nom_profil_de_raies ?effacer fichier continuum (O/n)\n\n"
       }

       #--- Extraction du continuum :
       set sp_continuum [ spc_extractcont "$fichier" $spcaudace(degpoly_cont) "n" ]
       #-- Normalisation par division de fitting de continuum :
       set sp_norma [ spc_div "$fichier" "$sp_continuum" ]

       #--- Traitement du resultat :
       buf$audace(bufNo) load "$audace(rep_images)/$sp_norma"
       buf$audace(bufNo) setkwd [ list "BSS_NORM" "Dividing by continuum polynome extracted" string "Technic used for normalisation" "" ]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/${fichier}_norm"
       buf$audace(bufNo) bitpix short

       #--- Affiche resultat :
       if { $flag_rm } {
          file delete -force "$audace(rep_images)/$sp_continuum$conf(extension,defaut)"
       }
       file delete -force "$audace(rep_images)/$sp_norma$conf(extension,defaut)"
       ::console::affiche_resultat "Profil normalisé sauvé sous ${fichier}_norm\n"
       return "${fichier}_norm"
    } else {
        ::console::affiche_erreur "Usage : spc_autonorma nom_profil_de_raies ?effacer fichier continuum (O/n)\n\n"
    }
}
#*****************************************************************#




##########################################################
# Normalisation automatique d'un profil sur le continuum au voisinage d'une raie
# en tenant compte de la totalite du profil
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 26-08-2006
# Date de mise à jour : 26-08-2006
# Arguments : fichier .fit du profil de raies, type de raie
##########################################################

proc spc_autonormaraie { args } {

    global audace
    global conf
    #-- Ecart de 10 A sur les bords d'un profil couvrant 180 A : 5,56%
    set ecart 0.056

    if { [llength $args] == 2 } {
       set fichier [ file rootname [ lindex $args 0 ] ]
       set typeraie [ lindex $args 1 ]

       #--- Ramasse des renseignements :
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set crval [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       set cdelt [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]

       #-- CAlcul Lambda deb et fin écartés du 10 A du bord
       set ldeb [ expr $crval ]
       set lfin [ expr $crval+$cdelt*$naxis1 ]
       set ecartzone [ expr $ecart*($lfin-$ldeb) ]
       set ldeb [ expr $ldeb+$ecartzone ]
       set lfin [ expr $lfin-$ecartzone ]

       #-- Normalise sur cette zone :
       set fileout [ spc_normaraie $fichier $ldeb $lfin $typeraie ]
       return $fileout
    } else {
        ::console::affiche_erreur "Usage: spc_autonormaraie profil_de_raies type_raie (e/a)\n\n"
    }
}
#****************************************************************#





##########################################################
# Procedure de sélection et découpage (crop) d'une partie d'un profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 02-09-2005
# Date de mise à jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, lambda_deb, lambda_fin
##########################################################

proc spc_select { args } {

   global audace audela
   global conf

   if {[llength $args] == 3} {
       set infichier [ lindex $args 0 ]
       set xdeb [ lindex $args 1 ]
       set xfin [ lindex $args 2 ]
       set fichier [ file rootname $infichier ]

       #--- Linéarise la calibration avant cette operation :
       set spectre_lin [ spc_linearcal "$fichier" ]

       #--- Récupére les mots clefs nécessaires au calcul :
       buf$audace(bufNo) load "$audace(rep_images)/$spectre_lin"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       #-- Valeur minimale de l'abscisse : =0 si profil non étalonné
       set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       #-- Dispersion du spectre : =1 si profil non étalonné
       set disper [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]

       #--- Extrait les longueurs d'onde et les intensites :
       set abscisses ""
       set intensites ""
       #-- Audela 130 :
       if { [regexp {1.3.0} $audela(version) match resu ] } {
           for {set k 0} {$k<$naxis1} {incr k} {
               #- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
               lappend abscisses [expr $xdepart+($k)*$disper*1.0]
               #- Lit la valeur des elements du fichier fit
               lappend intensites [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
               ##lappend profilspc(intensite) $intensite
           }
       #-- Audela 140 :
       } else {
           for {set k 0} {$k<$naxis1} {incr k} {
               #- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
               lappend abscisses [expr $xdepart+($k)*$disper*1.0]
               #- Lit la valeur des elements du fichier fit
               lappend intensites [ lindex [buf$audace(bufNo) getpix [list [expr $k+1] 1]] 1 ]
               ##lappend profilspc(intensite) $intensite
           }
       }

       #--- Sélection des longueurs d'onde à découper
       #set diff1 [ expr abs($xdeb-[ lindex $abscisses 0 ]) ]
       #set diff2 [ expr abs($xfin-[ lindex $abscisses 0 ]) ]
       set nabscisses ""
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
                   lappend nabscisses $abscisse
                   lappend nintensites $intensite
                   # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
                   incr k
               }
           }
       }

       set len $k
       ::console::affiche_resultat "$k intensités sélectionnées entre $xdebl et $xfinl.\n"
       #--- Initialisation à blanc d'un fichier fits :
       #buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       ##buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_USHORT COMPRESS_NONE 0
       buf1 load "$audace(rep_images)/$spectre_lin"
       buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
       buf$audace(bufNo) copykwd 1
       buf$audace(bufNo) setkwd [ list "NAXIS" 1 int "" "" ]
       buf$audace(bufNo) setkwd [ list "NAXIS1" $len int "" "" ]

       for {set k 0} {$k<$len} {incr k} {
           set intens [ lindex $nintensites $k ]
           buf$audace(bufNo) setpix [list [expr $k+1] 1] [ lindex $nintensites $k ]
           #::console::affiche_resultat "Intensité $k : $intens\n"
       }

       #--- Initatialisation de l'entête
       set xdepart [ lindex $nabscisses 0 ]
       buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart float "" ""]
       set xfin [ lindex $nabscisses $len ]
       buf$audace(bufNo) setkwd [list "CDELT1" $disper float "" ""]

       #--- Enregistrement du fichier fits final
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save1d "$audace(rep_images)/${fichier}_sel$conf(extension,defaut)"
       buf$audace(bufNo) bitpix short
       file delete -force "$audace(rep_images)/$spectre_lin$conf(extension,defaut)"
       ::console::affiche_resultat "Sélection sauvée sous $audace(rep_images)/${fichier}_sel$conf(extension,defaut)\n"
       return ${fichier}_sel
   } else {
       ::console::affiche_erreur "Usage: spc_select nom_fichier (de type fits) x_début x_fin\n\n"
   }
}
##########################################################


# 2008-01-14
proc spc_select2 { args } {

   global audace audela
   global conf

   if {[llength $args] == 3} {
       set infichier [ lindex $args 0 ]
       set ldeb [ lindex $args 1 ]
       set lfin [ lindex $args 2 ]
       set fichier [ file rootname $infichier ]

       #--- Linéarise la calibration avant cette operation :
       #set spectre_lin [ spc_linearcal "$fichier" ]

       #--- Récupére les mots clefs nécessaires au calcul :
       #buf$audace(bufNo) load "$audace(rep_images)/$spectre_lin"
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       #-- Valeur minimale de l'abscisse : =0 si profil non étalonné
       set crval1 [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       #-- Dispersion du spectre : =1 si profil non étalonné
       set disper [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]


       #--- Calcul de xdeb et xfin :
       set xdeb [ expr int(ceil(($ldeb-$crval1)/$disper)) ]
       set xfin [ expr int(floor(($lfin-$crval1)/$disper)) ]
       #-- Gestion de mauvaises longueurs d'onde donnes en argument :
       if { $xdeb<0 || $xfin<0 } {
           ::console::affiche_resultat "Sélection hors des limites du spectre.\n"
           return ""
       }
       #-- Gestion de la longueur d'onde finale a prendre en compte :
       set nlfin [ expr ($crval1+$xdeb*$disper)+$xfin*$disper ]
       if { $nlfin > $lfin } {
           set xfin [ expr $xfin-1 ]
       }
       set nnaxis1 [ expr $xfin-$xdeb+1 ]

#::console::affiche_resultat "$nnaxis1 intensités à sélectionnéer entre les pixels $xdeb et $xfin.\n"

       #--- Selectionne les intensités dans le spectre initial :
       set nintensites [ list ]
       set len 0
       for { set k [ expr $xdeb-1 ] } { $k<$xfin } {incr k} {
           lappend nintensites [ lindex [buf$audace(bufNo) getpix [list [expr $k+1] 1]] 1 ]
           incr len
       }

       #--- Créée le fichier fits de sortie :
       ::console::affiche_resultat "$len ($nnaxis1) intensités sélectionnées entre les pixels $xdeb et $xfin.\n"
       #--- Initialisation à blanc d'un fichier fits :
       #buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       ##buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_USHORT COMPRESS_NONE 0

       #buf1 load "$audace(rep_images)/$spectre_lin"
       buf1 load "$audace(rep_images)/$fichier"
       buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
       buf$audace(bufNo) copykwd 1
       buf$audace(bufNo) setkwd [ list "NAXIS" 1 int "" "" ]
       buf$audace(bufNo) setkwd [ list "NAXIS1" $len int "" "" ]

       for {set k 0} {$k<$len} {incr k} {
           set intens [ lindex $nintensites $k ]
           buf$audace(bufNo) setpix [list [expr $k+1] 1] [ lindex $nintensites $k ]
           #::console::affiche_resultat "Intensité $k : $intens\n"
       }

       #--- Initatialisation de l'entête
       set ldepart [ expr $crval1+$xdeb*$disper ]
       buf$audace(bufNo) setkwd [list "CRVAL1" $ldepart float "" ""]
       buf$audace(bufNo) setkwd [list "CDELT1" $disper float "" ""]

       #--- Enregistrement du fichier fits final
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save1d "$audace(rep_images)/${fichier}_sel$conf(extension,defaut)"
       buf$audace(bufNo) bitpix short
       ::console::affiche_resultat "Sélection sauvée sous $audace(rep_images)/${fichier}_sel$conf(extension,defaut)\n"
       return ${fichier}_sel
   } else {
       ::console::affiche_erreur "Usage: spc_select2 nom_fichier (de type fits) lambda_début lambda_fin\n\n"
   }
}
##########################################################



proc spc_select0 { args } {

   global audace audela
   global conf

   if {[llength $args] == 3} {
       set infichier [ lindex $args 0 ]
       set xdeb [ lindex $args 1 ]
       set xfin [ lindex $args 2 ]
       set fichier [ file rootname $infichier ]

       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       #--- Valeur minimale de l'abscisse : =0 si profil non étalonné
       set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       #--- Dispersion du spectre : =1 si profil non étalonné
       set disper [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]

       set abscisses ""
       set intensites ""
       set nabscisses ""
       set nintensites ""
       #---- Audela 130 :
       if { [regexp {1.3.0} $audela(version) match resu ] } {
           for {set k 0} {$k<$naxis1} {incr k} {
               #--- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
               set abscisse [expr $xdepart+($k)*$disper*1.0]
               lappend abscisses $abscisse
               #--- Lit la valeur des elements du fichier fit
               set intensite [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
               lappend intensites $intensite
               #--- Alimente le nouveau spectre

               if { $abscisse >= $xdeb && $abscisse <= $xfin } {
                   lappend nabscisses $abscisse
                   lappend nintensites $intensite
                   # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
                   incr k
               }
           }
       #---- Audela 140 :
       } else {
           for {set k 0} {$k<$naxis1} {incr k} {
               #--- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
               set abscisse [expr $xdepart+($k)*$disper*1.0]
               lappend abscisses $abscisse
               #--- Lit la valeur des elements du fichier fit
               set intensite [ lindex [buf$audace(bufNo) getpix [list [expr $k+1] 1]] 1 ]
               lappend intensites $intensite
               #--- Alimente le nouveau spectre

               if { $abscisse >= $xdeb && $abscisse <= $xfin } {
                   lappend nabscisses $abscisse
                   lappend nintensites $intensite
                   # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
                   incr k
               }
           }
       }

       set longr [ llength $nabscisses ]
       ::console::affiche_resultat "Selection : $longr\n"
       #--- Sélection des longueurs d'onde à découper
       #set diff1 [ expr abs($xdeb-[ lindex $abscisses 0 ]) ]
       #set diff2 [ expr abs($xfin-[ lindex $abscisses 0 ]) ]
       set nabscisses ""
       set nintensites ""
       set k 0
       foreach abscisse $abscisses intensite $intensites {
           #-- 060224 : gestion de lambda debut plus proche par defaut
           set diff [ expr abs($xdeb-$abscisse) ]
           if { $diff < $disper } {
               set xdebl [ expr $xdeb-$disper ]
           } else {
               set xdebl $xdeb
           }

           if { $abscisse >= $xdebl && $abscisse <= $xfin } {
               lappend nabscisses $abscisse
               lappend nintensites $intensite
               # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
               incr k
           }
       }
       set len $k


       ::console::affiche_resultat "$k intensités sélectionnées.\n"
       #--- Initialisation à blanc d'un fichier fits
       #buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_USHORT COMPRESS_NONE 0
       buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0

       for {set k 0} {$k<$len} {incr k} {
           set intens [ lindex $nintensites $k ]
           buf$audace(bufNo) setpix [list [expr $k+1] 1] [ lindex $nintensites $k ]
           ::console::affiche_resultat "Intensité $k : $intens\n"
       }

       #--- Initatialisation de l'entête
       buf$audace(bufNo) setkwd [list "NAXIS1" "$len" int "" ""]
       set xdepart [ lindex $nabscisses 0 ]
       buf$audace(bufNo) setkwd [list "CRVAL1" "$xdepart" float "" ""]
       set xfin [ lindex $nabscisses $len ]
       buf$audace(bufNo) setkwd [list "CDELT1" "$disper" float "" ""]

       #--- Enregistrement du fichier fits final
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/${fichier}_sel$conf(extension,defaut)"
       buf$audace(bufNo) bitpix short
       ::console::affiche_resultat "Sélection sauvée sous $audace(rep_images)/${fichier}_sel$conf(extension,defaut)\n"
       return ${fichier}_sel$conf(extension,defaut)
   } else {
       ::console::affiche_erreur "Usage: spc_select nom_fichier (de type fits) x_début x_fin\n\n"
   }
}
##########################################################




####################################################################
#  Procedure de rééchantillonnage par spline
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-12-2005
# Date modification : 26-11-2006/060102
# Arguments : profil.fit à rééchantillonner, profil_modele.fit modèle d'échantilonnage
# Algo : spline cubique appliqué au contenu d'un fichier fits
# Bug : a la premiere execution "# x vector "x" must be monotonically increasing"
####################################################################

proc spc_echant { args } {
    global conf
    global audace

    if { [llength $args] == 2 } {
       set fichier_a_echant [ file rootname [ lindex $args 0 ] ]
       set fichier_modele [ file rootname [ lindex $args 1 ] ]

       #--- Chargement des parametres du spectre a echantillonner :
       buf$audace(bufNo) load "$audace(rep_images)/$fichier_a_echant"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
          set flag_spccal 1
          set crval1_orig [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
          set cdelt1_orig [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
          set naxis1_orig [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
          #-- Recupere la totalite des mots clef :
          set keywords ""
          foreach keywordName [ buf$audace(bufNo) getkwds ] {
             lappend keywords [ buf$audace(bufNo) getkwd $keywordName ]
          }
          #-- Lecture des intensites :
          for { set i 1 } { $i <= $naxis1_orig } { incr i } {
             lappend intensites_a_echant [ lindex [ buf$audace(bufNo) getpix [ list $i 1 ] ] 1 ]
          }
          #-- Calcul des lambdas :
          for { set i 0 } { $i < $naxis1_orig } { incr i } {
             lappend lambdas_a_echant [ expr $crval1_orig+$cdelt1_orig*$i ]
          }
       } else {
          ::console::affiche_erreur "Le spectre $fichier_a_echant doit etre calibre et avec une loi lineaire.\n"
          return ""
       }

       #--- Recupere CDELT1, NAXIS1 et CRVAL1 de spectre modele :
       buf$audace(bufNo) load "$audace(rep_images)/$fichier_modele"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
          set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
          set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
          set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
          #-- Calcul des lambdas :
          for { set i 0 } { $i < $naxis1 } { incr i } {
             lappend lambdas_modele [ expr $crval1+$cdelt1*$i ]
          }
       } else {
          ::console::affiche_erreur "Le spectre $fichier_modele doit etre calibre et avec une loi lineaire.\n"
          return ""
       }

       #-- Interpolation-extrapolation pour deteminer les intensites reechantillonnees :
       set new_intensites [ lindex  [ spc_spline $lambdas_a_echant $intensites_a_echant $lambdas_modele n ] 1 ]


       #--- Crée le fichier FITS :
       set newBufNo [ buf::create ]
       buf$newBufNo setpixels CLASS_GRAY $naxis1 1 FORMAT_FLOAT COMPRESS_NONE 0
       foreach keyword $keywords {
          buf$newBufNo setkwd $keyword
       }
       #-- Initalise les intensites :
       if { $flag_spccal } {
          #-- Profil calibré en longueur d'onde :
          for {set k 1} {$k<=$naxis1} {incr k} {
             buf$newBufNo setpix [list $k 1] [ lindex $new_intensites [ expr $k-1 ] ]
          }
       } else {
          #-- Profil non calibré en longueur d'onde :
          for {set k 1} {$k<=$naxis1} {incr k} {
             buf$newBufNo setpix [list $k 1] [ lindex $good_intensites [ expr $k-1 ] ]
          }
       }

       #--- Sauve le fichier fits ainsi constitué :
       set fichier_a_echant2 [ file rootname $fichier_a_echant ]
       buf$newBufNo bitpix float
       buf$newBufNo setkwd [ list "NAXIS1" $naxis1 int "" "" ]
       buf$newBufNo setkwd [ list "CRVAL1" $crval1 double "" "Angstrom" ]
       buf$newBufNo setkwd [ list "CDELT1" $cdelt1 double "" "Angstrom/pixel" ]
       buf$newBufNo save "$audace(rep_images)/${fichier_a_echant2}_ech$conf(extension,defaut)"
       buf$newBufNo bitpix short
       ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${fichier_a_echant2}_ech$conf(extension,defaut)\n"
       buf::delete $newBufNo
       return ${fichier_a_echant2}_ech
    } else {
        ::console::affiche_erreur "Usage: spc_echant profil_a_reechantillonner.fit profil_modele_echantillonnage.fit\n\n"
    }
}
#****************************************************************#



proc spc_echant0 { args } {
    global conf
    global audace

    #set args [ list $fichier1 $fichier2 ]
    if {[llength $args] == 2} {
        set fichier_a_echant [ file rootname [ lindex $args 0 ] ]
        set fichier_modele [ file rootname [ lindex $args 1 ] ]
        #set fichier_a_echant [ file rootname $fichier1 ]
        #set fichier_modele [ file rootname $fichier2 ]

        #--- Boucle a vide preventive ??? :
        set flag 0
        if { $flag } {
        blt::vector x(10) y(10)
        for {set i 10} {$i>0} {incr i -1} {
            set x($i-1) [expr $i*$i]
            set y($i-1) [expr sin($i*$i*$i)]
        }
        x sort y
        x populate sx 10
        blt::spline natural x y sx sy
        ::console::affiche_resultat "Premier spline passé...\n"
        }


        #--- Récupération des coordonnées des points à interpoler :
        #set contenu [ spc_fits2datadlin $fichier_a_echant ]
        #- 20070227 : fits2data nécessaire pour la bonne calibration du spectre etoile ref cat.
        set contenu [ spc_fits2data $fichier_a_echant ]
        set abscisses [lindex $contenu 0]
        set ordonnees [lindex $contenu 1]
        set len [llength $abscisses]

        #--- Création des vecteurs abscisses et ordonnées des points à interpoler :
        #-- Une liste commence à 0 ; Un vecteur fits commence à 1
        #blt::vector x($len) y($len)
        #for {set i 0} {$i<$len} {incr i} {
        #    set x($i) [lindex $abscisses $i]
        #    set y($i) [lindex $ordonnees $i]
        #}
        #x sort y

        blt::vector create x
        blt::vector create y
        x set $abscisses
        y set $ordonnees

        ##for {set i $len} {$i>0} {incr i -1} {
        ##    set x($i-1) [lindex $abscisses [expr $i-1] ]
        ##    set y($i-1) [lindex $ordonnees [expr $i-1] ]
        ##}
        ##x sort y

        #--- Création des abscisses des points interpolés :
        #set nabscisses [ lindex [ spc_fits2datadlin $fichier_modele ] 0]
        #- 20070227 : fits2data nécessaire pour la bonne calibration du spectre etoile ref cat : sans effet ici.
        set nabscisses [ lindex [ spc_fits2data $fichier_modele ] 0]
        set nlen [ llength $nabscisses ]
        #blt::vector sx($nlen)
        #for {set i 0} {$i<$nlen} {incr i} {
        #    set sx($i) [lindex $nabscisses $i]
        #}
        blt::vector create sx
        sx set $nabscisses


        #--- Spline ---------------------------------------#
        #blt::vector sy($len) # Modifié le 25/11/2006
        blt::vector create sy($nlen)
        #x sort y
        blt::spline natural x y sx sy
        # The spline command computes a spline fitting a set of data points (x and y vectors) and produces a vector of the interpolated images (y-coordinates) at a given set of x-coordinates.
        #blt::spline quadratic x y sx sy


        #--- Exportation des vecteurs coordonnées interpolées en liste puis fichier dat
        for {set i 1} {$i <= $nlen} {incr i} {
            lappend nordonnees $sy($i-1)
        }
        set ncoordonnees [ list $nabscisses $nordonnees ]
        ::console::affiche_resultat "Exportation au format fits des données interpolées sous ${fichier_a_echant}_ech\n"
        #::console::affiche_resultat "$nabscisses\n"
        spc_data2fits ${fichier_a_echant}_ech $ncoordonnees float

        #--- Affichage
        #destroy .testblt
        #toplevel .testblt
        #blt::graph .testblt.g
        #pack .testblt.g -in .testblt
        #.testblt.g element create line1 -symbol none -xdata sx -ydata sy -smooth natural
        #-- Meth2
        set flag 0
        if { $flag==1 } {
        destroy .testblt
        toplevel .testblt
        blt::graph .testblt.g
        pack .testblt.g -in .testblt
        set ly [lsort $ordonnees]
        .testblt.g legend configure -position bottom
        .testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
        .testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
        .testblt.g element create original -symbol none -x x -y y -color blue
        .testblt.g element create spline -symbol none -x sx -y sy -color red
        }
        #blt::table . .testblt
        return ${fichier_a_echant}_ech
    } else {
        ::console::affiche_erreur "Usage: spc_echant profil_a_reechantillonner.fit profil_modele_echantillonnage.fit\n\n"
    }
}
#****************************************************************#



##########################################################
# Procedure de mise à 0 des bords
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 30-09-2007
# Date de mise à jour : 30-09-2007
# Arguments : profil de raies
# Rermarque : bords gauche 3x moins reduit
##########################################################

proc spc_bordsnuls { args } {

    global audace spcaudace
    global conf

    if { [llength $args] == 1 } {
        set filename [ file rootname [ lindex $args 0 ] ]

        #--- Détermine les limites à mettre à 0 :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
        set xinf [ expr round($spcaudace(bordsnuls)*$naxis1/3.) ]
        set xsup [ expr round((1.-$spcaudace(bordsnuls))*$naxis1) ]

        #--- Met à zero les pixels des bords :
        #-- Bord gauche :
        for { set k 1 } { $k<=$naxis1 } { incr k } {
            if { $k <= $xinf } {
                buf$audace(bufNo) setpix [ list $k 1 ] 0.
            }
        }
        #-- Bord droit :
        for { set k $naxis1 } { $k>=1 } { incr k -1 } {
            if { $k >= $xsup } {
                buf$audace(bufNo) setpix [ list $k 1 ] 0.
            }
        }

        #--- Sauvegarde :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_bn"
        buf$audace(bufNo) bitpix short
        return "${filename}_bn"
    } else {
        ::console::affiche_erreur "Usage: spc_bordsnuls profil_de_raies\n\n"
    }
}
#****************************************************************#



##########################################################
# Procedure de division de 2 profils de raies
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 30-03-2006
# Date de mise à jour : 30-03-2006
# Arguments : profil de raies 1, profil de raies 2
##########################################################

proc spc_div { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
        set numerateur [ lindex $args 0 ]
        set denominateur [lindex $args 1 ]
        set fichier [ file tail [ file rootname $numerateur ] ]

        #--- Vérification de la compatibilité des 2 profils de raies : lambda_i, lambda_f et dispersion identiques
        if { [ spc_compare $numerateur $denominateur ] == 1 } {
            #--- Création des listes de valeur :
            set contenu1 [ spc_fits2data $numerateur ]
            set contenu2 [ spc_fits2data $denominateur ]
            set abscisses [ lindex $contenu1 0 ]
            set ordonnees1 [ lindex $contenu1 1 ]
            set ordonnees2 [ lindex $contenu2 1 ]

            #--- Division :
            #-- Meth2 : division simple sans gestion des valeurs devenues gigantesques :
            buf$audace(bufNo) load "$audace(rep_images)/$numerateur"
            set i 1
            set nbdivz 0
            foreach ordo1 $ordonnees1 ordo2 $ordonnees2 {
                   if { $ordo2 == 0.0 } {
                       buf$audace(bufNo) setpix [list $i 1] 0.0
                       incr i
                       incr nbdivz
                   } else {
                       buf$audace(bufNo) setpix [list $i 1] [ expr 1.0*$ordo1/$ordo2 ]
                       incr i
                   }
            }
            ::console::affiche_resultat "Fin de la division : $nbdivz divisions par 0.\n"


            #--- Fin du script :
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${fichier}_div"
            buf$audace(bufNo) bitpix short
            ::console::affiche_resultat "Division des 2 profils sauvée sous ${fichier}_div$conf(extension,defaut)\n"
            return ${fichier}_div
        } else {
            ::console::affiche_resultat "\nLes 2 profils de raies ne sont pas divisibles.\n"
            return 0
        }
    } else {
        ::console::affiche_erreur "Usage : spc_div profil_de_raies_numérateur_fits profil_de_raies_dénominateur_fits\n\n"
    }
}
#*********************************************************************#


##########################################################
# Procedure de division de 2 profils de raies
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 30-03-2006
# Date de mise à jour : 18-03-2007
# Arguments : profil de raies 1, profil de raies 2
##########################################################

proc spc_divbrut { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
        set numerateur [ lindex $args 0 ]
        set denominateur [lindex $args 1 ]
        set fichier [ file tail [ file rootname $numerateur ] ]

        #--- Ne vérification de la compatibilité des 2 profils de raies : lambda_i, lambda_f et dispersion identiques

            #--- Création des listes de valeur :
            set contenu1 [ spc_fits2data $numerateur ]
            set contenu2 [ spc_fits2data $denominateur ]
            set abscisses [ lindex $contenu1 0 ]
            set ordonnees1 [ lindex $contenu1 1 ]
            set ordonnees2 [ lindex $contenu2 1 ]

            #--- Division :
            #-- Meth2 : division simple sans gestion des valeurs devenues gigantesques :
            buf$audace(bufNo) load "$audace(rep_images)/$numerateur"
            set i 1
            set nbdivz 0
            foreach ordo1 $ordonnees1 ordo2 $ordonnees2 {
                if { $ordo2 == 0.0 } {
                    buf$audace(bufNo) setpix [list $i 1] 0.0
                    incr i
                    incr nbdivz
                } else {
                    buf$audace(bufNo) setpix [list $i 1] [ expr 1.0*$ordo1/$ordo2 ]
                    incr i
                }
            }
            ::console::affiche_resultat "Fin de la division : $nbdivz divisions par 0.\n"


            #--- Fin du script :
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${fichier}_div"
            buf$audace(bufNo) bitpix short
            ::console::affiche_resultat "Division des 2 profils sauvée sous ${fichier}_div$conf(extension,defaut)\n"
            return ${fichier}_div
    } else {
        ::console::affiche_erreur "Usage : spc_divbrut profil_de_raies_numérateur_fits profil_de_raies_dénominateur_fits\n\n"
    }
}
#*********************************************************************#



##########################################################
# Procedure de division de 2 profils de raies et les effets de bords (intensités anormalement importantes par rapport à 1.0).
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 21-10-2006
# Date de mise à jour : 21-10-2006
# Arguments : profil de raies 1, profil de raies 2
##########################################################

proc spc_divri { args } {

    global audace spcaudace
    global conf

    if { [ llength $args ] == 2 } {
        set numerateur [ lindex $args 0 ]
        set denominateur [lindex $args 1 ]
        set fichier [ file tail [ file rootname $numerateur ] ]

        #--- Rééchantillonne la réponse intrumentale sur le spectre à corriger :
        # set denominateur_ech $denominateur
        # set denominateur_ech [ spc_echant $denominateur $numerateur ]
        set denominateur_ech [ spc_calibreloifile $numerateur $denominateur ]


        #--- Vérification de la compatibilité des 2 profils de raies : lambda_i, lambda_f et dispersion identiques
        if { [ spc_compare $numerateur $denominateur_ech ] == 1 } {
            #--- Création des listes de valeur :
            set contenu1 [ spc_fits2data $numerateur ]
            set contenu2 [ spc_fits2data $denominateur_ech ]
            set abscisses [ lindex $contenu1 0 ]
            set ordonnees1 [ lindex $contenu1 1 ]
            set ordonnees2 [ lindex $contenu2 1 ]

            #--- Division pour déterminer le maximum :
            set lresult_div [ list ]
            buf$audace(bufNo) load "$audace(rep_images)/$numerateur"
            foreach ordo1 $ordonnees1 ordo2 $ordonnees2 {
                if { $ordo2 <= 0.0 } {
                    lappend lresult_div 0.0
                } else {
                    lappend lresult_div [ expr 1.0*$ordo1/$ordo2 ]
                }
            }

            #-- Détermination de Imax sur la zone découpée des bords à 15% :
            set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            set xdeb [ expr round($naxis1*$spcaudace(pourcent_bord)) ]
            set xfin [ expr round($naxis1*(1.-$spcaudace(pourcent_bord))) ]
            set lresult_div_cut [ lrange $lresult_div $xdeb $xfin ]
            #-- Calcul la valeur maximale :
            set i_max [ lindex [ lsort -real -decreasing $lresult_div_cut ] 0 ]

            #-- Calcul la valeur moyenne de la zone de travail :
            #set windowcoords [ $xdeb 1 $xfin 1 ]
            #buf$audace(bufNo) window
            #set i_infos [ buf$audace(bufNo) stat ]


            #--- Division avec les mises à zéro nécéssaires :
            #buf$audace(bufNo) load "$audace(rep_images)/$numerateur"
            set i 1
            set nbdivz 0
            foreach ordo1 $ordonnees1 ordo2 $ordonnees2 {
                if { $ordo2 <= 0.0 } {
                    buf$audace(bufNo) setpix [list $i 1] 0.0
                    incr nbdivz
                } else {
                    set resultat_div [ expr 1.0*$ordo1/$ordo2 ]
                    if { $cdelt1>=0.7 } {
                        if { $i<=$xdeb || $i>=$xfin } {
                           if { $resultat_div >= [ expr $i_max*$spcaudace(imax_tolerence) ] } {
                                buf$audace(bufNo) setpix [list $i 1] 0.
                            } else {
                                buf$audace(bufNo) setpix [list $i 1] $resultat_div
                            }
                        } else {
                            buf$audace(bufNo) setpix [list $i 1] $resultat_div
                        }
                    } else {
                        buf$audace(bufNo) setpix [list $i 1] $resultat_div
                    }
                }
                incr i
            }
            ::console::affiche_resultat "Fin de la division : $nbdivz divisions par 0.\n"


            #--- Fin du script :
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${fichier}_ricorr"
            buf$audace(bufNo) bitpix short
            file delete -force "$audace(rep_images)/$denominateur_ech$conf(extension,defaut)"
            ::console::affiche_resultat "Division du profil par la réponse intrumentale sauvée sous ${fichier}_ricorr$conf(extension,defaut)\n"
            return ${fichier}_ricorr
        } else {
            ::console::affiche_resultat "\nLes 2 profils de raies ne sont pas divisibles.\n"
            return 0
        }
    } else {
        ::console::affiche_erreur "Usage : spc_divri profil_de_raies_objet_fits profil_de_raies_réponse_instrumentale_fits\n\n"
    }
}
#*********************************************************************#








####################################################################
# Procédure de calcul de la dérivée d'un profil de raies
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : nom_profil_raies
####################################################################

proc spc_derive { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
        set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
        set listevals [ spc_fits2data $filename ]
        set listevalsdervie [ spc_derivation $listevals ]
        set filederive [ spc_data2fits ${filename}_deriv $listevalsdervie ]
        ::console::affiche_resultat "Dérivée du profil de raies sauvée sous $filederive\n"
        return $filederive
    } else {
        ::console::affiche_erreur "Usage: spc_derive nom_profil_raies\n"
    }
}
#***************************************************************************#


####################################################################
# Procédure de normalisation de flat 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 01-08-2007
# Date modification : 01-08-2007
# Arguments : nom_profil_raies ycenter hauteur_binning
####################################################################

proc spc_normaflat { args } {
    global conf
    global audace spcaudace

    if { [llength $args] == 3 } {
        set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
        set ycenter [ lindex $args 1 ]
        set hauteur [ lindex $args 2 ]

        #--- Binning :
        set fbin [ spc_profily $filename $ycenter $hauteur ]

        #--- Extrait le continuum d'information :
        set fpbas [ spc_passebas $fbin ]
        set fconti [ spc_div $fbin $fpbas ]
        # set fconti [ spc_passebas $fconti1 14 ]
        # set fconti [ spc_bigsmooth2 $fconti1 0.3 ]

        #--- Obtention du flat normalisé :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set naxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
        set flatnorma [ spc_1dto2d $fconti $naxis2 ]

        #--- Traitement des résultats :
        file rename -force "$audace(rep_images)/$flatnorma$conf(extension,defaut)" "$audace(rep_images)/${filename}-norma$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$fbin$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$fpbas$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$fconti$conf(extension,defaut)"
        ::console::affiche_resultat "Flat 2D normalisé sauvé sauvée sous ${filename}-norma\n"
        return "${filename}-norma"
    } else {
        ::console::affiche_erreur "Usage: spc_normaflat nom_profil_raies ycenter hauteur_binning\n"
    }
}
#***************************************************************************#



####################################################################
# Procédure de normalisation de flat
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 01-08-2007
# Date modification : 01-08-2007
# Arguments : nom_profil_raies hauteur
####################################################################

proc spc_1dto2d { args } {
    global conf
    global audace

    if { [llength $args] == 2 } {
        set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
        set hauteur [ lindex $args 1 ]

        #--- Elargissement en hauteur :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        buf$audace(bufNo) scale [ list 1 $hauteur ] 1
        buf$audace(bufNo) setkwd [ list NAXIS 2 int "" "" ]
        buf$audace(bufNo) setkwd [ list NAXIS2 $hauteur int "" "" ]

        #--- Traitement des résultats :
        # Les nuances sont tres faibles, donc exceptionnellement spectre 2D en 32 bits.
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_2d"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Profil élargi en 2D sauvé sauvée sous ${filename}_2d\n"
        return "${filename}_2d"
    } else {
        ::console::affiche_erreur "Usage: spc_1dto2d nom_profil_raies hauteur\n"
    }
}
#***************************************************************************#


####################################################################
# Procédure de dérougissement des intensités d'un profil de raies nébulaire
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 05-08-2007
# Date modification : 05-08-2007
# Arguments : nom_profil_raies largeur_raie
####################################################################

proc spc_derougi { args } {
    global conf
    global audace

    if { [llength $args] == 2 } {
        set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
        set largeur [ lindex $args 1 ]

        #--- Mesure l'amplitude des raies de Ha et Hb :
        set i_ha [ lindex [ spc_imax $filename 6563 $largeur ] 0 ]
        set i_hb [ lindex [ spc_imax $filename 4861 $largeur ] 0 ]
        #set i_hb 100.

        #--- Calcul de c(beta) :
        set cbeta [ expr log($i_ha/($i_hb*2.85))/0.325 ]
        ::console::affiche_resultat "c(beta)=$cbeta\n"

        #--- Obtention des lambda et intensites :
        set coordonnees [ spc_fits2data $filename ]
        set lambdas [ lindex $coordonnees 0 ]
        set intensites [ lindex $coordonnees 1 ]

        #--- Calcul des nouvelles intensites :
        set nintensites [ list ]
        foreach lambda $lambdas intensite $intensites {
            if { $intensite==0 } {
                lappend nintensites 0.0
            } else {
                lappend nintensites [ expr pow(10,log($intensite)+$cbeta/3.65*(2580.0-0.005*$lambda)) ]
            }
        }

        #--- Création du fichier fits de sortie :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
        for { set i 0 } { $i<$naxis1 } { incr i } {
            buf$audace(bufNo) setpix [ list [ expr $i+1 ] 1 ] [ lindex $nintensites $i ]
        }


        #--- Traitement des résultats :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_derougi"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Profil dérougi sauvé sauvée sous ${filename}_derougi\n"
        return "${filename}_derougi"
    } else {
        ::console::affiche_erreur "Usage: spc_derougi nom_profil_raies largeur_raie\n"
    }
}
#***************************************************************************#




####################################################################
# Procédure de normalisation d'un profil pour que I(Hbeta)=100
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2007-08-08
# Date modification : 2007-08-08
# Arguments : nom_profil_raies largeur_raie
####################################################################

proc spc_normahbeta { args } {
    global conf
    global audace

    set ihbeta_final 100.

    if { [llength $args] == 2 } {
        set fichier [ file rootname [ file tail [ lindex $args 0 ] ] ]
        set largeur [ lindex $args 1 ]

        #--- Détermine les paramètres de calibration :
        buf$audace(bufNo) load "$audace(rep_images)/$fichier"
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        set disp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
        set lambda0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
        if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
            set flag_nonlin 1
            set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
            set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
            set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
            set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
        } else {
            set flag_nonlin 0
        }

        #--- Mesure I_max de la raie H_beta à 4861 A :
        set lambda 4861.
        #-- Calcul des limites de l'ajustement pour une dispersion linéaire :
        set xdeb [ expr round(($lambda-0.5*$largeur-$lambda0)/$disp) ]
        set xfin [ expr round(($lambda+0.5*$largeur-$lambda0)/$disp) ]
        #-- Ajustement gaussien:
        set gaussparams [ buf$audace(bufNo) fitgauss [ list $xdeb 1 $xfin 1 ] ]
        set xcentre [ lindex $gaussparams 1 ]
        set imax [ lindex $gaussparams 0 ]
        set icont [ lindex $gaussparams 3 ]
        #-- Converti le pixel en longueur d'onde :
        if { $flag_nonlin==1 } {
            set lcentre [ expr $spc_a+$spc_b*$xcentre+$spc_c*pow($xcentre,2)+$spc_d*pow($xcentre,3) ]
        } else {
            set lcentre [ expr $disp*$xcentre+$lambda0 ]
        }
        set ihbeta [ expr $imax+$icont ]
        set coefnorma [ expr $ihbeta_final/$ihbeta ]

        #--- Normalisation du spectre tel que I_max(Hbeta)=100 :
        buf$audace(bufNo) mult $coefnorma

        #--- Traitement des résultats :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${fichier}_normab"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Le profil de raies est normé (x$coefnorma) tel que la raie centrée en $lcentre vallant $imax soit à 100.\n"
        return ${fichier}_normab
    } else {
        ::console::affiche_erreur "Usage: spc_normahbeta nom_profil_raies longueur_d_onde_raie largeur\n"
    }
}
#***************************************************************************#
























#================================================================================#
# Anciennes versions
#================================================================================#


####################################################################
# Procedure de normalisation automatique de profil de raies
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 15-12-2005
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_autonorma_15122005 { args } {

    global audace
    global conf
    set extsp ".dat"

    if {[llength $args] == 1} {
        set fichier [ lindex $args 0 ]
        set nom_fichier [ file rootname $fichier ]
        #::console::affiche_resultat "F : $fichier ; NF : $nom_fichier\n"
        #--- Ajustement de degré 2 pour déterùiner un continuum
        set coordonnees [ spc_ajust $fichier 1 ]
        #-- vspc_data2fits retourne juste le nom de fichier créé
        #set nom_continuum [ spc_data2fits ${nom_fichier}_conti $coordonnees "double" ]
        set nom_continuum [ spc_data2fits ${nom_fichier}_conti $coordonnees "float" ]

        #--- Retablissemnt d'une dispersion identique entre continuum et le profil aà normaliser
        buf$audace(bufNo) load $audace(rep_images)/$fichier
        set liste_dispersion [buf$audace(bufNo) getkwd "CDELT1"]
        set dispersion [lindex $liste_dispersion 1]
        set nbunit [lindex $liste_dispersion 2]
        #set unite [lindex $liste_dispersion 3]
        buf$audace(bufNo) load $audace(rep_images)/$nom_continuum
        buf$audace(bufNo) setkwd [list "CDELT1" "$dispersion" $nbunit "" "Angstrom/pixel"]
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save $audace(rep_images)/$nom_continuum

        #--- Normalisation par division
        buf$audace(bufNo) load $audace(rep_images)/$fichier
        buf$audace(bufNo) div $audace(rep_images)/$nom_continuum 1
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save $audace(rep_images)/${nom_fichier}_norm
        buf$audace(bufNo) bitpix short
        #-- Effacement des fichiers temporaires
        #file delete $audace(rep_images)/${nom_fichier}_continuum$conf(extension,defaut)
        return ${nom_fichier}_norm
    } else {
        ::console::affiche_erreur "Usage : spc_autonorma nom_profil_de_raies\n\n"
    }
}
#*****************************************************************#

proc spc_autonorma_051215b { args } {

    global audace
    global conf
    set extsp ".dat"

    if {[llength $args] == 1} {
        set fichier [ lindex $args 0 ]
        set nom_fichier [ file rootname $fichier ]
        #--- Ajustement de degré 2 pour déterùiner un continuum
        set coordonnees [spc_ajust $fichier 1]
        set nom_continuum [ spc_data2fits ${nom_fichier}_conti $coordonnees ]

        #set nx [llength [lindex $coordonnees 0]]
        #set ny [llength [lindex $coordonnees 1]]
        #::console::affiche_resultat "Nb points x : $nx ; y : $ny\n"

        #--- Normalisation par division
        buf$audace(bufNo) load $audace(rep_images)/$fichier
        buf$audace(bufNo) div $audace(rep_images)/$nom_continuum 1
        #buf$audace(bufNo) bitpix float
        #buf$audace(bufNo) save $audace(rep_images)/${nom_fichier}_norm

        #-- Effacement des fichiers temporaires
        #file delete $audace(rep_images)/${nom_fichier}_continuum$conf(extension,defaut)
    } else {
        ::console::affiche_erreur "Usage : spc_autonorma nom_profil_de_raies\n\n"
    }
}
#*****************************************************************#

proc spc_autonorma_131205 { args } {

    global audace
    global conf
    set extsp ".dat"

    if {[llength $args] == 1} {
        set fichier [ lindex $args 0 ]

        # Ajustement de degré 2 pour déterùiner un continuum
        set coordonnees [spc_ajust $fichier 1]
        set lambdas [lindex $coordonnees 0]
        set intensites [lindex $coordonnees 1]
        set len [llength $lambdas]

        #--- Enregistrement du continuum au format fits
        set filename [ file rootname $fichier ]
        ##set filename ${fileetalonnespc}_dat$extsp
        set fichier_conti ${filename}_conti$extsp
        set file_id [open "$audace(rep_images)/$fichier_conti" w+]
        for {set k 0} {$k<$len} {incr k} {
            set lambda [lindex $lambdas $k]
            set intensite [lindex $intensites $k]
            #--- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
            puts $file_id "$lambda\t$intensite"
        }
        close $file_id
        #--- Conversion en fits
        spc_dat2fits $fichier_conti
        #-- Bisarrerie : le continuum fits est inverse gauche-droite
        buf$audace(bufNo) load $audace(rep_images)/${filename}_conti_fit
        buf$audace(bufNo) mirrorx
        buf$audace(bufNo) save $audace(rep_images)/${filename}_conti_fit

        #--- Normalisation par division
        buf$audace(bufNo) load $audace(rep_images)/$fichier
        buf$audace(bufNo) div $audace(rep_images)/${filename}_conti_fit 1
        buf$audace(bufNo) save $audace(rep_images)/${filename}_norm

        #-- Effacement des fichiers temporaires
        file delete $audace(rep_images)/$fichier_conti$extsp
        file delete $audace(rep_images)/${filename}_conti_fit$conf(extension,defaut)
    } else {
        ::console::affiche_erreur "Usage : spc_autonorma nom_profil_de_raies\n\n"
    }
}
#*****************************************************************#




##########################################################
# Procedure de division de 2 profils de raies et les effets de bords (intensités anormalement importantes par rapport à 1.0).
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 21-10-2006
# Date de mise à jour : 21-10-2006
# Arguments : profil de raies 1, profil de raies 2
##########################################################

proc spc_divri_21102006 { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
        set numerateur [ lindex $args 0 ]
        set denominateur [lindex $args 1 ]
        set fichier [ file tail [ file rootname $numerateur ] ]

        #--- Rééchantillonne la réponse intrumentale sur le spectre à corriger :
        # set denominateur_ech $denominateur
        # set denominateur_ech [ spc_echant $denominateur $numerateur ]
        set denominateur_ech [ spc_calibreloifile $numerateur $denominateur ]


        #--- Vérification de la compatibilité des 2 profils de raies : lambda_i, lambda_f et dispersion identiques
        if { [ spc_compare $numerateur $denominateur_ech ] == 1 } {
            #--- Récupération des mots clef de l'entéte FITS :
            buf$audace(bufNo) load "$audace(rep_images)/$numerateur"
            set dateobs [lindex [buf$audace(bufNo) getkwd "DATE-OBS"] 1]
            set mjdobs [lindex [buf$audace(bufNo) getkwd "MJD-OBS"] 1]
            set exposure [lindex [buf$audace(bufNo) getkwd "EXPOSURE"] 1]
            set listemotsclef [ buf$audace(bufNo) getkwds ]
            if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
                set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            }
            if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
                set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            }
            if { [ lsearch $listemotsclef "SPC_DEC" ] !=-1 } {
                set spc_desc [ lindex [ buf$audace(bufNo) getkwd "SPC_DESC" ] 1 ]
            }
            if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
                set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
            }
            if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
                set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
            }
            if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
                set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
            }
            if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
                set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
            }
            if { [ lsearch $listemotsclef "SPC_RMS" ] !=-1 } {
                set spc_rms [ lindex [ buf$audace(bufNo) getkwd "SPC_RMS" ] 1 ]
            }
        #foreach mot $listemotsclef {
        #    set valeur_mot [ lindex [ buf$audace(bufNo) getkwd "$mot" ] 1 ]
        #    if { [ regexp {\s99\s} $valeur_mot match resul ] } {
        #        set nombre_poses [ llength $valeur_mot ]
        #    }
        #}

            #--- Création des listes de valeur :
            set contenu1 [ spc_fits2data $numerateur ]
            set contenu2 [ spc_fits2data $denominateur_ech ]
            set abscisses [ lindex $contenu1 0 ]
            set ordonnees1 [ lindex $contenu1 1 ]
            set ordonnees2 [ lindex $contenu2 1 ]

            #--- Division :
            #-- Meth1 : gestion pixels oscillants :
            if {1==0} {
            set nordos ""
            set i 0
            foreach ordo1 $ordonnees1 ordo2 $ordonnees2 {
                if { $ordo2 == 0.0 } {
                    lappend nordos 0.0
                    #::console::affiche_resultat "Val = $ordo2\n"
                    incr i
                } else {
                    set rapport [ expr 1.0*$ordo1/$ordo2 ]
                    #-- Gere les bords qui sont oscillants et de tres grande valeur :
                    if { $rapport>= 1. } {
                        lappend nordos 0.0
                        incr i
                    } else {
                        lappend nordos $rapport
                    }
                }
            }
            ::console::affiche_resultat "Fin de la division : $i division(s) par 0 ou mise(s) à 0.\n"
            }
            #-- Meth2 : division simple :
            set nordos [ list ]
            set i 0
            foreach ordo1 $ordonnees1 ordo2 $ordonnees2 {
                if { $ordo2 == 0.0 } {
                    lappend nordos 0.0
                    #::console::affiche_resultat "Val = $ordo2\n"
                    incr i
                } else {
                    lappend nordos [ expr 1.0*$ordo1/$ordo2 ]
                }
            }
            ::console::affiche_resultat "Fin de la division : $i divisions par 0.\n"


            #--- Enregistrement du resultat au format fits
            set ncontenu [ list $abscisses $nordos ]
            set lenl [ llength $nordos ]
            ::console::affiche_resultat "$lenl valeurs traitées.\n"
            set fichier_out [ spc_data2fits ${fichier}_ricorr $ncontenu ]

            #--- Réintégration des mots clef FITS
            buf$audace(bufNo) load "$audace(rep_images)/$fichier_out"
            buf$audace(bufNo) setkwd [ list "DATE-OBS" "$dateobs" string "Start of exposure. FITS standard" "Iso 8601" ]
            buf$audace(bufNo) setkwd [ list "MJD-OBS" "$mjdobs" double "Start of exposure" "d" ]
            buf$audace(bufNo) setkwd [ list "EXPOSURE" "$exposure" double "Total time of exposure" "s" ]
            if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
                buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
            }
            if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
                buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "" "angstrom"]
            }
            if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
                buf$audace(bufNo) setkwd [list "CDELT1" $dispersion double "" "angstrom"]
            }
            if { [ lsearch $listemotsclef "SPC_DESC" ] !=-1 } {
                buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+A.x.x+B.x+C" string "" ""]
            }
            if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
                buf$audace(bufNo) setkwd [list "SPC_A" $spc_a double "" "angstrom.angstrom/pixel.pixel"]
            }
            if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
                buf$audace(bufNo) setkwd [list "SPC_B" $spc_b double "" "angstrom/pixel"]
            }
            if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
                buf$audace(bufNo) setkwd [list "SPC_C" $spc_c double "" "angstrom"]
            }
            if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
                buf$audace(bufNo) setkwd [list "SPC_D" $spc_d double "" "angstrom.angstrom.a/pixel.pixel.p"]
            }
            if { [ lsearch $listemotsclef "SPC_RMS" ] !=-1 } {
                buf$audace(bufNo) setkwd [list "SPC_RMS" $spc_rms double "" "angstrom"]
            }
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/$fichier_out"
            buf$audace(bufNo) bitpix short

            #--- Fin du script :
            file delete -force "$audace(rep_images)/$denominateur_ech$conf(extension,defaut)"
            ::console::affiche_resultat "Division du profil par la réponse intrumentale sauvée sous $fichier_out$conf(extension,defaut)\n"
            return $fichier_out
        } else {
            ::console::affiche_resultat "\nLes 2 profils de raies ne sont pas divisibles.\n"
            return 0
        }
    } else {
        ::console::affiche_erreur "Usage : spc_divri profil_de_raies_objet_fits profil_de_raies_réponse_instrumentale_fits\n\n"
    }
}
#*********************************************************************#




####################################################################
#  Procedure de rééchantillonnage par spline
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-12-2005
# Date modification : 28-03-2006
# Arguments : profil.fit à rééchantillonner, profil_modele.fit modèle d'échantilonnage
# Algo : spline cubique appliqué au contenu d'un fichier fits
# Bug : a la premiere execution "# x vector "x" must be monotonically increasing"
####################################################################

proc spc_echant_060328 { args } {
    global conf
    global audace

    if {[llength $args] == 2} {
        set fichier_a_echant [ file rootname [ lindex $args 0 ] ]
        set fichier_modele [ file rootname [ lindex $args 1 ] ]
        ##set contenu [spc_openspcfits $filenamespc]
        #set contenu [ lindex $args 0 ]
        set contenu [ spc_fits2datadlin $fichier_a_echant ]

        set abscisses [lindex $contenu 0]
        set ordonnees [lindex $contenu 1]
        set len [llength $ordonnees]

        #--- Une liste commence à 0 ; Un vecteur fits commence à 1
        blt::vector x($len) y($len)
        for {set i $len} {$i>0} {incr i -1} {
            set x($i-1) [lindex $abscisses $i]
            set y($i-1) [lindex $ordonnees $i]
        }
        x sort y

        #for {set i $len} {$i>0} {incr i -1} {
        #    set x($i-1) [lindex $abscisses [expr $i-1] ]
        #    set y($i-1) [lindex $ordonnees [expr $i-1] ]
        #}
        #x sort y

        #--- Création des abscisses des coordonnees interpolées
        set nabscisses [ lindex [ spc_fits2datadlin $fichier_modele ] 0]
        set nlen [ llength $nabscisses ]
        blt::vector sx($nlen)
        blt::vector sy($nlen)
        for {set i 1} {$i <= $nlen} {incr i} {
            set sx($i-1) [lindex $nabscisses $i]
        }

        #--- Spline ---------------------------------------#
        #blt::vector sy($len) # Modifié le 25/11/2006
        #blt::vector sy($nlen)
        blt::spline natural x y sx sy
        # The spline command computes a spline fitting a set of data points (x and y vectors) and produces a vector of the interpolated images (y-coordinates) at a given set of x-coordinates.
        #blt::spline quadratic x y sx sy

        #--- Exportation des vecteurs coordonnées interpolées en liste puis fichier dat
        for {set i 1} {$i <= $nlen} {incr i} {
            lappend nordonnees $sy($i-1)
        }
        set ncoordonnees [ list $nabscisses $nordonnees ]
        ::console::affiche_resultat "Exportation au format fits des données interpolées sous ${fichier_a_echant}_ech\n"
        #::console::affiche_resultat "$nabscisses\n"
        spc_data2fits ${fichier_a_echant}_ech $ncoordonnees float

        #--- Affichage
        #destroy .testblt
        #toplevel .testblt
        #blt::graph .testblt.g
        #pack .testblt.g -in .testblt
        #.testblt.g element create line1 -symbol none -xdata sx -ydata sy -smooth natural
        #-- Meth2
        set flag 0
        if { $flag==1 } {
        destroy .testblt
        toplevel .testblt
        blt::graph .testblt.g
        pack .testblt.g -in .testblt
        set ly [lsort $ordonnees]
        .testblt.g legend configure -position bottom
        .testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
        .testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
        .testblt.g element create original -symbol none -x x -y y -color blue
        .testblt.g element create spline -symbol none -x sx -y sy -color red
        }
        #blt::table . .testblt
        return ${fichier_a_echant}_ech
    } else {
        ::console::affiche_erreur "Usage: spc_echant profil_a_reechantillonner.fit profil_modele_echantillonnage.fit\n\n"
    }
}
#****************************************************************#


proc spc_echant_060328 { args } {
    global conf
    global audace

    if {[llength $args] == 2} {
        set fichier [ file rootname [ lindex $args 0 ] ]
        set fichier_abscisses [ lindex $args 1 ]
        ##set contenu [spc_openspcfits $filenamespc]
        #set contenu [ lindex $args 0 ]
        set contenu [ spc_fits2data $fichier ]

        set abscisses [lindex $contenu 0]
        set ordonnees [lindex $contenu 1]
        set len [llength $ordonnees]

        #--- Une liste commence à 0 ; Un vecteur fits commence à 1
        blt::vector x($len) y($len)
        for {set i $len} {$i > 0} {incr i -1} {
            set x($i-1) [lindex $abscisses $i]
            set y($i-1) [lindex $ordonnees $i]
        }
        x sort y

        #--- Création des abscisses des coordonnees interpolées
        set nabscisses [ lindex [ spc_fits2data $fichier_abscisses ] 0]
        set nlen [ llength $nabscisses ]
        blt::vector sx($nlen)
        for {set i 1} {$i <= $nlen} {incr i} {
            set sx($i-1) [lindex $nabscisses $i]
        }

        #--- Spline ---------------------------------------#
        blt::vector sy($len)
        # blt::spline natural x y sx sy
        # The spline command computes a spline fitting a set of data points (x and y vectors) and produces a vector of the interpolated images (y-coordinates) at a given set of x-coordinates.
        #blt::spline quadratic x y sx sy
        blt::spline natural x y sx sy

        #--- Exportation des vecteurs coordonnées interpolées en liste puis fichier dat
        for {set i 1} {$i <= $nlen} {incr i} {
            lappend nordonnees $sy($i-1)
        }
        set ncoordonnees [ list $nabscisses $nordonnees ]
        ::console::affiche_resultat "Exportation au format fits des données interpolées sous ${fichier}_ech\n"
        #::console::affiche_resultat "$nabscisses\n"
        spc_data2fits ${fichier}_ech $ncoordonnees float

        #--- Affichage
        #destroy .testblt
        #toplevel .testblt
        #blt::graph .testblt.g
        #pack .testblt.g -in .testblt
        #.testblt.g element create line1 -symbol none -xdata sx -ydata sy -smooth natural
        #-- Meth2
        set flag 0
        if { $flag==1 } {
        destroy .testblt
        toplevel .testblt
        blt::graph .testblt.g
        pack .testblt.g -in .testblt
        set ly [lsort $ordonnees]
        .testblt.g legend configure -position bottom
        .testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
        .testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
        .testblt.g element create original -symbol none -x x -y y -color blue
        .testblt.g element create spline -symbol none -x sx -y sy -color red
        }
        #blt::table . .testblt
        return ${fichier}_ech
    } else {
        ::console::affiche_erreur "Usage: spc_echant profil_a_reechantillonner.fit profil_modele_echantillonnage.fit\n\n"
    }
}
#****************************************************************#

proc spc_spline_051211 { args } {
    global conf
    global audace

    if {[llength $args] == 1} {
        set fichier [ lindex $args 0 ]
        ##set contenu [spc_openspcfits $filenamespc]
        #set contenu [ lindex $args 0 ]
        set contenu [ spc_fits2data $fichier ]

        set abscisses [lindex $contenu 0]
        set ordonnees [lindex $contenu 1]
        set len [llength $ordonnees]

        #--- Une liste commence à 0 ; Un vecteur fits commence à 1
        blt::vector x($len) y($len)
        for {set i $len} {$i > 0} {incr i -1} {
            set x($i-1) [lindex $abscisses $i]
            set y($i-1) [lindex $ordonnees $i]
        }

        #--- Spline ---------------------------------------#
        x sort y
        x populate sx $len
        blt::vector sy($len)
        # blt::spline natural x y sx sy
        # The spline command computes a spline fitting a set of data points (x and y vectors) and produces a vector of the interpolated images (y-coordinates) at a given set of x-coordinates.
        #blt::spline quadratic x y sx sy
        blt::spline natural x y sx sy

        #--- Affichage
        #destroy .testblt
        #toplevel .testblt
        #blt::graph .testblt.g
        #pack .testblt.g -in .testblt
        #.testblt.g element create line1 -symbol none -xdata sx -ydata sy -smooth natural
        #-- Meth2
        destroy .testblt
        toplevel .testblt
        blt::graph .testblt.g
        pack .testblt.g -in .testblt
        set ly [lsort $ordonnees]
        .testblt.g legend configure -position bottom
        .testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
        .testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
        .testblt.g element create original -symbol none -x x -y y -color blue
        .testblt.g element create spline -symbol none -x sx -y sy -color red
        #blt::table . .testblt

    } else {
        ::console::affiche_erreur "Usage: spc_spline fichier_profil.fit\n\n"
    }
}
#****************************************************************#



##########################################################
# Procedure de rééchantillonage d'un profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 15-08-2005
# Date de mise à jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, nouvelle dispersion
##########################################################

# Arguments : fichier .fit du profil de raie, nbpixels, lambda0, nouvelle dispersion
proc spc_echant_21122005 { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
       #--- Initialisation des variables de travail
       set infichier [ lindex $args 0 ]
       set nbpix [ lindex $args 1 ]
       set lambda0 [ lindex $args 2 ]
       set newdisp [ lindex $args 3 ]
       set fichier [ file tail $infichier ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set olddisp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
       set facteur [ expr $newdisp/$olddisp ]
       set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
       set lambdadeb [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
       set lambdafin [ expr $lambdadeb+$olddisp*$naxis1 ]

       #--- Création de la liste des longueurs d'onde à obtenir
       for {set k 0} {$k<$nbpix} {incr k} {
           lappend lambdasfinal[ expr lamdda0+$k*$newdisp ]
       }

       #--- Création de la liste des valeurs de l'intensite
       #-- Meth 1 :
       set coordonnees [ spc_fits2data $fichier ]
       set lambdas [ lindex $coordonnes 1 ]
       set intensites [ lindex $coordonnes 1 ]
       #-- Meth 2 :
       set falg 0
       if { $flag == 1 } {
       if { $lambdadeb != 1 } {
           #-- Dispersion du spectre : =1 si profil non étalonné
           set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
           #-- Pixel de l'abscisse centrale
           set xcenter [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
           #-- Type de spectre : LINEAR ou NONLINEAR (elinine les espaces dans la valeur du mot cle.
           #set dtype [string trim [lindex [buf$audace(bufNo) getkwd "CTYPE1"] 1]]
           #::console::affiche_resultat "Ici 1\n"
           #if { $dtype != "LINEAR" || $dtype == "" } {
           #    ::console::affiche_resultat "Le spectre ne possède pas une dispersion linéaire. Pas de conversion possible.\n"
           #    break
           #}
           #-- Une liste commence à 0 ; Un vecteur fits commence à 1
           for {set k 0} {$k<$naxis1} {incr k} {
               lappend lambdas [expr $xdepart+($k)*$xincr*1.0]
               lappend intensites [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
           }
           #-- Spectre non calibré en lambda
       } else {
           for {set k 0} {$k<$naxis1} {incr k} {
               lappend lambdas [expr $k+1]
               lappend intensites [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
           }
       }
   }

       #--- Calcul les valeurs rééchantillonnées
       foreach lambda $lambdas intensite $intensites {
       }

       #--- Sauvegarde du spectre rééchantillonné
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save $audace(rep_images)/${fichier}_ech$conf(extension,defaut)
       buf$audace(bufNo) bitpix short
       ::console::affiche_resultat "Profil rééchantillonné sauvé sous $audace(rep_images)/${fichier}_ech$conf(extension,defaut)\n"
       return ${fichier}_ech
   } else {
       ::console::affiche_erreur "Usage: s)c_echant nom_fichier (de type fits) nouvelle_dispersion\n\n"
   }
}
##########################################################

# Ne fonctionne pas : la bande passante est diminuée lorsque l'on passe par exemple de 5 à 2.2
proc spc_echant0 { args } {

   global audace
   global conf

   if {[llength $args] == 2} {
       set infichier [ lindex $args 0 ]
       set newdisp [ lindex $args 1 ]
       set fichier [ file tail $infichier ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       #buf$audace(bufNo) load $fichier
       set olddisp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
       set facteur [ expr $newdisp/$olddisp ]
       # rééchantillone selon l'axe X, donc facteur_y=1.
       # normaflux=1 permet de garder la dynamique initiale.
       set lfactor [ list $facteur 1 ]
       buf$audace(bufNo) scale  $lfactor 1
       buf$audace(bufNo) setkwd [list "CDELT1" "$newdisp" float "" ""]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/${fichier}_ech$conf(extension,defaut)"
       buf$audace(bufNo) bitpix short
       ::console::affiche_resultat "Profil rééchantillonné sauvé sous $audace(rep_images)/${fichier}_ech$conf(extension,defaut)\n"
       return ${fichier}_ech
   } else {
       ::console::affiche_erreur "Usage: spc_echant nom_fichier (de type fits) nouvelle_dispersion\n\n"
   }
}
##########################################################



proc spc_echant-26-11-2006 { args } {
    global conf
    global audace

    #set args [ list $fichier1 $fichier2 ]
    if {[llength $args] == 2} {
        set fichier_a_echant [ file rootname [ lindex $args 0 ] ]
        set fichier_modele [ file rootname [ lindex $args 1 ] ]
        #set fichier_a_echant [ file rootname $fichier1 ]
        #set fichier_modele [ file rootname $fichier2 ]

        #--- Boucle a vide preventive ??? :
        set flag 0
        if { $flag } {
        blt::vector x(10) y(10)
        for {set i 10} {$i>0} {incr i -1} {
            set x($i-1) [expr $i*$i]
            set y($i-1) [expr sin($i*$i*$i)]
        }
        x sort y
        x populate sx 10
        blt::spline natural x y sx sy
        ::console::affiche_resultat "Premier spline passé...\n"
        }


        #--- Récupération des coordonnées des points à interpoler :
        set contenu [ spc_fits2datadlin $fichier_a_echant ]
        set abscisses [lindex $contenu 0]
        set ordonnees [lindex $contenu 1]
        set len [llength $abscisses]

        #--- Création des vecteurs abscisses et ordonnées des points à interpoler :
        #-- Une liste commence à 0 ; Un vecteur fits commence à 1
        blt::vector x($len) y($len)
        for {set i 0} {$i<$len} {incr i} {
            set x($i) [lindex $abscisses $i]
            set y($i) [lindex $ordonnees $i]
        }
        x sort y

        ##for {set i $len} {$i>0} {incr i -1} {
        ##    set x($i-1) [lindex $abscisses [expr $i-1] ]
        ##    set y($i-1) [lindex $ordonnees [expr $i-1] ]
        ##}
        ##x sort y

        #--- Création des abscisses des points interpolés :
        set nabscisses [ lindex [ spc_fits2datadlin $fichier_modele ] 0]
        set nlen [ llength $nabscisses ]
        blt::vector sx($nlen)
        for {set i 0} {$i<$nlen} {incr i} {
            set sx($i) [lindex $nabscisses $i]
        }

        #--- Spline ---------------------------------------#
        #blt::vector sy($len) # Modifié le 25/11/2006
        blt::vector sy($nlen)
        blt::spline natural x y sx sy
        # The spline command computes a spline fitting a set of data points (x and y vectors) and produces a vector of the interpolated images (y-coordinates) at a given set of x-coordinates.
        #blt::spline quadratic x y sx sy

        #--- Exportation des vecteurs coordonnées interpolées en liste puis fichier dat
        for {set i 1} {$i <= $nlen} {incr i} {
            lappend nordonnees $sy($i-1)
        }
        set ncoordonnees [ list $nabscisses $nordonnees ]
        ::console::affiche_resultat "Exportation au format fits des données interpolées sous ${fichier_a_echant}_ech\n"
        #::console::affiche_resultat "$nabscisses\n"
        spc_data2fits ${fichier_a_echant}_ech $ncoordonnees float

        #--- Affichage
        #destroy .testblt
        #toplevel .testblt
        #blt::graph .testblt.g
        #pack .testblt.g -in .testblt
        #.testblt.g element create line1 -symbol none -xdata sx -ydata sy -smooth natural
        #-- Meth2
        set flag 0
        if { $flag==1 } {
        destroy .testblt
        toplevel .testblt
        blt::graph .testblt.g
        pack .testblt.g -in .testblt
        set ly [lsort $ordonnees]
        .testblt.g legend configure -position bottom
        .testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
        .testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
        .testblt.g element create original -symbol none -x x -y y -color blue
        .testblt.g element create spline -symbol none -x sx -y sy -color red
        }
        #blt::table . .testblt
        return ${fichier_a_echant}_ech
    } else {
        ::console::affiche_erreur "Usage: spc_echant profil_a_reechantillonner.fit profil_modele_echantillonnage.fit\n\n"
    }
}
#****************************************************************#





