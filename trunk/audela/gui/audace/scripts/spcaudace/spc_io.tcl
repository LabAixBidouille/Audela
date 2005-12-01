####################################################################################
#
# Procedures d'entree-sortie gérant des spectres
# Auteur : Benjamin MAUCLAIRE
# Date de création : 31-01-2005
# Date de mise a jour : 21-02-2005
# Chargement en script : source $audace(rep_scripts)/spcaudace/spc_io.tcl
#
#####################################################################################


# Remarque (par Benoît) : il faut mettre remplacer toutes les variables textes par des variables caption(mauclaire,...)
# qui seront initialisées dans le fichier cap_mauclaire.tcl
# et renommer ce fichier mauclaire.tcl ;-)

global audace


####################  Liste des fonctions ###############################
#
# spc2png : converti un profil de raies format fits en une image format png avec gnuplot
#
#######################################################


#######################################################
#  Procedure d'ouverture de fichiers
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : nom du fichier
########################################################

proc openfile { {filename ""} } {
   global conf
   global audace

   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $audace(rep_images)]
   set profilspc(initialfile) [file tail $filenamespc]
   set input [open "$audace(rep_images)/$filenamespc" r]
   close input
   return $input
}
#****************************************************************#


#######################################################
#  Procedure d'ouverture de fichiers .dat avec interface graphique
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : nom du fichier
########################################################

proc openfileg { {filename ""} } {
   global conf
   global audace
   global captionspc

   ## === Interfacage de l'ouverture du fichier profil de raie ===
   if {$filename==""} {
      # set idir ./
      # set ifile *.spc
      set idir $audace(rep_images)
      set ifile $conf(extension,defaut)

      if {[info exists profilspc(initialdir)] == 1} {
         set idir "$profilspc(initialdir)"
      }
      if {[info exists profilspc(initialfile)] == 1} {
         set ifile "$profilspc(initialfile)"
      }
      set filenamespc [tk_getOpenFile -title $captionspc(loadspctxt) -filetypes [list [list "$captionspc(spc_profile)" {.dat .$conf(extension,defaut)}]] -initialdir $idir -initialfile $ifile ]
      if {[string compare $filenamespc ""] == 0 } {
         return 0
      }
   }
   return $filenamespc
}
#****************************************************************#


#######################################################
#  Procedure d'ouverture de spectre au format fits
#
# Auteur : Benjamin MAUCLAIRE
# Date création : 15-02-2005
# Date modification : 15-02-2005
# Arguments : nom du fichier
# Sortie : 
#  Si calibré : liste contenant la liste des valeurs de l'intensité, NAXIS1, CRVAL1, CDELT1, CRPIX1, CTYPE1.
#  Si non calibre : liste contenant la liste des valeurs de l'intensité, NAXIS1
########################################################

proc openspc { {filenamespc ""} } {
   global conf
   global audace

   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $audace(rep_images)]
   set profilspc(initialfile) [file tail $filenamespc]
   #buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   buf$audace(bufNo) load "$filenamespc"

   # Determine si c'est un spectre etalonne ou non etalonne en longueur d'onde
   set mot ""
   set flagcalib 0
   set motsheader [buf$audace(bufNo) getkwds]
   set len [llength $motsheader]
   for {set k 0} {$k<$len} {incr k} {
       set mot [lindex $motsheader $k]
       if { [string compare $mot "CRVAL1"] == 0 } {
	   set flagcalib 1
           break
       } else {
	   set flagcalib 0
       }
   }

   if { $flagcalib == 0 } {
       ::console::affiche_resultat "Ouverture d'un spectre non calibré $filenamespc\n"
       openspcncal "$filenamespc"
   } else {
       ::console::affiche_resultat "Ouverture d'un spectre calibré $filenamespc\n"
       openspccal "$filenamespc"
   }
}
#****************************************************************#


#######################################################
#  Procedure d'ouverture de spectre non calibré (lambda) au format fits
#
# Auteur : Benjamin MAUCLAIRE
# Date création : 15-02-2005
# Date modification : 15-02-2005
# Arguments : nom du fichier
# Sortie : liste contenant la liste des valeurs de l'intensité, NAXIS1
########################################################

proc openspcncal { {filenamespc ""} } {
   global conf
   global audace

   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $audace(rep_images)]
   #set profilspc(initialfile) [file tail $filenamespc]
   #buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   buf$audace(bufNo) load "$filenamespc"

   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]

   for {set k 1} {$k<=$naxis1} {incr k} {
       # Lit la valeur des elements du fichier fit
       lappend intensites [buf$audace(bufNo) getpix [list $k 1]]
   }
   set spectre [list $intensites $naxis1]
   return $spectre
}
#****************************************************************#



#######################################################
#  Procedure d'ouverture de spectre calibré (lambda) au format fits
#
# Auteur : Benjamin MAUCLAIRE
# Date création : 15-02-2005
# Date modification : 15-02-2005
# Arguments : nom du fichier
# Sortie : liste contenant la liste des valeurs de l'intensité, NAXIS1, CRVAL1, CDELT1, CRPIX1, CTYPE1.
########################################################

proc openspccal { {filenamespc ""} } {
   global conf
   global audace

   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $audace(rep_images)]
   #set profilspc(initialfile) [file tail $filenamespc]
   #buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   buf$audace(bufNo) load "$filenamespc"

   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
   # Valeur minimale de l'abscisse : =0 si profil non étalonné
   set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
   # Dispersion du spectre : =1 si profil non étalonné
   set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
   # Pixel de l'abscisse centrale
   set xcenter [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
   # Type de spectre : LINEAR ou NONLINEAR
   set dtype [lindex [buf$audace(bufNo) getkwd "CTYPE1"] 1]

   for {set k 1} {$k<=$naxis1} {incr k} {
       # Lit la valeur des elements du fichier fit
       lappend intensites [buf$audace(bufNo) getpix [list $k 1]]
   }
   set spectre [list $intensites $naxis1 $xdepart $xincr $xcenter "$dtype"]
   return $spectre
}
#****************************************************************#






###################################################################
#  Procedure de conversion de fichier profil de raies .dat en .fit
# 
# Auteur : Benjamin MAUCLAIRE
# Date creation : 31-01-2005
# Date modification : 15-02-2005
# Arguments : fichier .dat du profil de raie
###################################################################

proc dat2fits { {filenamespc ""} } {

   global conf
   global audace
   global profilspc
   global captionspc
   global colorspc
   set extsp "dat"

   ## === Lecture du fichier de donnees du profil de raie ===
   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $audace(rep_images)]
   set profilspc(initialfile) [file tail $filenamespc]
   set input [open "$audace(rep_images)/$filenamespc" r]
   set contents [split [read $input] \n]
   close $input

   ## === Extraction des numeros des pixels et des intensites ===
   #::console::affiche_resultat "ICI :\n $contents.\n"
   #set profilspc(naxis1) [expr [llength $contents]-2]
   set profilspc(naxis1) [ expr [llength $contents]-1]
   #::console::affiche_resultat "$profilspc(naxis1)\n"
   set offset 1
   # Une liste commence à 0
   for {set k -1} {$k < $profilspc(naxis1)} {incr k} {
      set ligne [lindex $contents $k]
      append profilspc(pixels) "[lindex $ligne 0] "
      append profilspc(intensite) "[lindex $ligne 1] "
      #incr $k
   }
   #::console::affiche_resultat "$profilspc(pixels)\n"

   # === On prepare les vecteurs a afficher ===
   # len : longueur du profil (NAXIS1)
   #set len [llength $profilspc(pixels)]
   set len $profilspc(naxis1)
   set intensites ""
   for {set k 0} {$k<=$len} {incr k} {
         append intensites " [lindex $profilspc(intensite) $k]"
   }

   # Initialisation à blanc d'un fichier fits
   #buf$audace(bufNo) format $len 1
   buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_USHORT COMPRESS_NONE 0

   set intensite 0
   #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
   # Une liste commence à 0 ; Un vecteur fits commence à 1
   for {set k 0} {$k<$len} {incr k} {
   	append intensite [lindex $intensites $k]
	#::console::affiche_resultat "$intensite\n"
	buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
	set intensite 0
   }

   set profilspc(xunit) "Position"
   set profilspc(yunit) "ADU"
   #------- Affecte une valeur aux mots cle liés à la spectroscopie ----------
   # buf$audace(bufNo) setkwd [list "INSTRU" "T310" string "mon télescope" ""]
   buf$audace(bufNo) setkwd [list "NAXIS1" "$len" int "" ""]
   buf$audace(bufNo) setkwd [list "NAXIS2" "1" int "" ""]
   # Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
   set xdepart [lindex $profilspc(pixels) 0]
   buf$audace(bufNo) setkwd [list "CRVAL1" "$xdepart" int "" ""]
   # Valeur de la longueur d'onde/pixel central(e)
   set xdernier [lindex $profilspc(pixels) [expr $profilspc(naxis1)-1]]
   ::console::affiche_resultat "Xdep : $xdepart ; Xfin : $xdernier\n"
   set xcentre [expr int(0.5*($xdernier-$xdepart))]
   buf$audace(bufNo) setkwd [list "CRPIX1" "$xcentre" int "" ""]
   # Dispersion du spectre : =1 si profil non étalonné
   set l1 [lindex $profilspc(pixels) 1]
   set l2 [lindex $profilspc(pixels) [expr int($len/10)]]
   set l3 [lindex $profilspc(pixels) [expr int(2*$len/10)]]
   set l4 [lindex $profilspc(pixels) [expr int(3*$len/10)]]
   set dl1 [expr ($l2-$l1)/(int($len/10)-1)]
   set dl2 [expr ($l4-$l3)/(int($len/10)-1)]
   set xincr [expr 0.5*($dl2+$dl1)]
   # Meth2 : erreur si spectre de moins de 4 pixels
   #set l2 [lindex $profilspc(pixels) 4]
   #set l3 [lindex $profilspc(pixels) [expr 1+int($len/2)]]
   #set l4 [lindex $profilspc(pixels) [expr 4+int($len/2)]]
   #set dl1 [expr ($l2-$l1)/3]
   #set dl2 [expr ($l4-$l3)/3]
   #set xincr [expr 0.5*($dl2+$dl1)]

   ::console::affiche_resultat "Dispersion : $xincr\n"
   buf$audace(bufNo) setkwd [list "CDELT1" "$xincr" float "" ""]
   # Type de dispersion : LINEAR, NONLINEAR
   if { [expr abs($dl2-$dl1)] <= 0.001 } {
       buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]
   } elseif { [expr abs($dl2-$dl1)] > 0.001 } {
       buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]
   }

   # Sauve le fichier fits ainsi constitué 
   buf$audace(bufNo) bitpix float
   buf$audace(bufNo) save ${filenamespc}_fit$conf(extension,defaut)
   ::console::affiche_resultat "$len lignes affectées\n"
   ::console::affiche_resultat "Fichier dat exporté sous $profilspc(initialfile)$conf(extension,defaut)\n"
}
#****************************************************************#



####################################################################
#  Procedure de conversion de fichier profil de raie spatial .fit en .dat
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 16-05-2005
# Arguments : fichier .fit du profil de raie
####################################################################

proc fits2dat { {filenamespc ""} } {

   global conf
   global audace
   global profilspc
   global captionspc
   global colorspc
   set extsp ".dat"

   #buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   buf$audace(bufNo) load $filenamespc
   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
   # Valeur minimale de l'abscisse : =0 si profil non étalonné
   set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
   # Dispersion du spectre : =1 si profil non étalonné
   set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
   # Pixel de l'abscisse centrale
   set xcenter [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
   # Type de spectre : LINEAR ou NONLINEAR (elinine les espaces dans la valeur du mot cle.
   set dtype [string trim [lindex [buf$audace(bufNo) getkwd "CTYPE1"] 1]]
   if { $dtype != "LINEAR" || $dtype == "" } {
       ::console::affiche_resultat "Le spectre ne possède pas une disersion linéaire. Pas de conversion possible.\n"
       exit
   }
   set len [expr int($naxis1/$xincr)]
   ::console::affiche_resultat "$naxis1 intensités à traiter\n"

   if { $xdepart != 1 } {
       set fileetalonnespc [ file rootname $filenamespc ]
       #set filename ${fileetalonnespc}_dat$extsp
       set filename ${fileetalonnespc}$extsp
       set file_id [open "$audace(rep_images)/$filename" w+]

       ## Une liste commence à 0 ; Un vecteur fits commence à 1
       for {set k 0} {$k<$naxis1} {incr k} {
	   # Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
	   set lambda [expr $xdepart+($k)*$xincr*1.0]
	   # Lit la valeur des elements du fichier fit
	   set intensite [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
	   ##lappend profilspc(intensite) $intensite
	   # Ecrit les couples "Lambda Intensite" dans le fichier de sortie
	   puts $file_id "$lambda\t$intensite"
       }
       close $file_id
   } else {
       # Retire l'extension .dat du nom du fichier
       set filespacialspc [ file rootname $filenamespc ]
       #buf$audace(bufNo) imaseries "PROFILE filename=${filespacialspc}_dat$extsp direction=x offset=1"
       buf$audace(bufNo) imaseries "PROFILE filename=${filespacialspc}$extsp direction=x offset=1"
       ::console::affiche_resultat "Fichier fits exporté sous ${filespacialspc}$extsp\n"
   }
   
}
#****************************************************************#



####################################################################
#  Procedure de conversion de fichier profil de raie spatial .fit en .dat
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : fichier .fit du profil de raie
####################################################################

proc fits2dat0 { {filenamespc ""} } {

   global conf
   global audace
   global profilspc
   global captionspc
   global colorspc
   set extsp ".dat"

   #buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   buf$audace(bufNo) load $filenamespc
   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
   # Valeur minimale de l'abscisse : =0 si profil non étalonné
   set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
   # Dispersion du spectre : =1 si profil non étalonné
   set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
   # Pixel de l'abscisse centrale
   set xcenter [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
   # Type de spectre : LINEAR ou NONLINEAR (elinine les espaces dans la valeur du mot cle.
   set dtype [string trim [lindex [buf$audace(bufNo) getkwd "CTYPE1"] 1]]
   if { $dtype != "LINEAR" || $dtype == "" } {
       ::console::affiche_resultat "Le spectre ne possède pas une disersion linéaire. Pas de conversion possible.\n"
       exit
   }
   set len [expr int($naxis1/$xincr)]
   ::console::affiche_resultat "$len intensités à traiter\n"

   if { $xdepart != 1 } {
       set fileetalonnespc [ file rootname $filenamespc ]
       #set filename ${fileetalonnespc}_dat$extsp
       set filename ${fileetalonnespc}$extsp
       set file_id [open "$audace(rep_images)/$filename" w+]

   ## Une liste commence à 0 ; Un vecteur fits commence à 1
   #for {set k 0} {$k<$len} {incr k} {
   #	append intensite [lindex $intensites $k]
	#::console::affiche_resultat "$intensite\n"
	# buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
	# set intensite 0
   #}

       for {set k 1} {$k<=$len} {incr k} {
	   # Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
	   set lambda [expr int($xdepart+($k-1)*$xincr)]
	   ##lappend profilspc(pixels) $lambda
	   #set lambda 0

	   # Lit la valeur des elements du fichier fit
	   set intensite [buf$audace(bufNo) getpix [list $k 1]]
	   ##lappend profilspc(intensite) $intensite
	   #set intensite 0

	   # Ecrit les couples "Lambda Intensite" dans le fichier de sortie
	   ::console::affiche_resultat "$lambda\t$intensite\n"
	   puts $file_id "$lambda\t$intensite"
       }
       close $file_id
   } else {
       # Retire l'extension .dat du nom du fichier
       set filespacialspc [ file rootname $filenamespc ]
       #buf$audace(bufNo) imaseries "PROFILE filename=${filespacialspc}_dat$extsp direction=x offset=1"
       buf$audace(bufNo) imaseries "PROFILE filename=${filespacialspc}$extsp direction=x offset=1"
       ::console::affiche_resultat "Fichier fits exporté sous $profilspc(initialfile).dat\n"
   }
   
}
#****************************************************************#



####################################################################
#  Procedure de conversion de fichier profil de raie .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 14-08-2005
# Date modification : 14-08-2005
# Arguments : fichier .fit du profil de raie, légende axe X, légende axe Y, pas
####################################################################

proc spc2png { args } {
   global audace
   global conf

   if {[llength $args] == 5} {
     set fichier [ lindex $args 0 ]
     set titre [ lindex $args 1 ]
     set legendex [ lindex $args 2 ]
     set legendey [ lindex $args 3 ]
     set pas [ lindex $args 4 ]
     set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
     set ext ".dat"

     #if {[string compare $tcl_platform(os) "Linux"] == 0 } {
       fits2dat $fichier
       # Retire l'extension .fit du nom du fichier
       set spcfile [ file rootname $fichier ]
       exec echo "call \"${repertoire_gp}/gp_spc.cfg\" \"${spcfile}$ext\" \"$titre\" * * * * $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
       exec gnuplot $repertoire_gp/run_gp
       exec rm -f $repertoire_gp/run_pg
     #} else {
#	 exec gnuplot call "${repertoire_gp}/gpwin32.cfg" "$spcfile" "$titre" * * * * $pas "${spcfile}.png" "$legendex" "$legendey"
#     }
     ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
   } else {
       ::console::affiche_erreur "Usage: spc2png fichier_fits titre légende_axeX légende_axeY intervalle_graduations\n\n"
   }
}
####################################################################



####################################################################
#  Procedure de conversion de fichier profil de raie calibré .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 14-08-2005
# Date modification : 14-08-2005
# Arguments : fichier .fit du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc2pngb { args } {
   global audace
   global conf

   if { [llength $args] <= 4 } {
       if { [llength $args] == 2 } {
	   set fichier [ lindex $args 0 ]
	   set titre [ lindex $args 1 ]
	   #set xdeb "*"
	   #set xfin "*"
	   buf$audace(bufNo) load $fichier       
	   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
	   set largeur [ expr 0.03*$naxis1 ]
	   set xdeb [ expr [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1] -$largeur ]
	   set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
	   set xfin [ expr $naxis1*$xincr+$xdeb+2*$largeur ]
       } elseif { [llength $args] == 4 } {
	   set fichier [ lindex $args 0 ]
	   set titre [ lindex $args 1 ]
	   set xdeb [ lindex $args 2 ]
	   set xfin [ lindex $args 3 ]
       } else {
	   ::console::affiche_erreur "Usage: spc2pngb fichier_fits titre intervalle_graduations\n\n"
	   exit 0
       }

       set legendey "Intensity (ADU)"
       set legendex "Wavelength (A)"
       set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
       set ext ".dat"

       fits2dat $fichier
       # Retire l'extension .fit du nom du fichier
       set spcfile [ file rootname $fichier ]
       #exec echo "call \"${repertoire_gp}/gpx11.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
       exec echo "call \"${repertoire_gp}/gp_spc.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin * \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
       exec gnuplot $repertoire_gp/run_gp
       exec rm -f $repertoire_gp/run_pg
       ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
   } else {
       ::console::affiche_erreur "Usage: spc2pngb fichier_fits ?xdébut xfin?\n\n"
   }
}
####################################################################


####################################################################
#  Procedure de crééation du fichier batch pour gnuplot afin de convertir un fichier profil de raie calibré .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-09-2005
# Date modification : 03-09-2005
# Arguments : fichier .fit du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc2pngc { args } {
   global audace
   global conf

   if { [llength $args] <= 4 } {
       if { [llength $args] == 2 } {
	   set fichier [ lindex $args 0 ]
	   set titre [ lindex $args 1 ]
	   #set xdeb "*"
	   #set xfin "*"
	   buf$audace(bufNo) load $fichier       
	   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
	   set largeur [ expr 0.03*$naxis1 ]
	   set xdeb [ expr [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1] -$largeur ]
	   set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
	   set xfin [ expr $naxis1*$xincr+$xdeb+2*$largeur ]
       } elseif { [llength $args] == 4 } {
	   set fichier [ lindex $args 0 ]
	   set titre [ lindex $args 1 ]
	   set xdeb [ lindex $args 2 ]
	   set xfin [ lindex $args 3 ]
       } else {
	   ::console::affiche_erreur "Usage: spc2pngb fichier_fits titre intervalle_graduations\n\n"
	   exit 0
       }

       set legendey "Intensity (ADU)"
       set legendex "Wavelength (A)"
       set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
       set ext ".dat"

       fits2dat $fichier
       # Retire l'extension .fit du nom du fichier
       set spcfile [ file rootname $fichier ]
       #exec echo "call \"${repertoire_gp}/gpx11.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
       set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
       puts $file_id "call \"${repertoire_gp}/gp_spc.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin * \"${spcfile}.png\" \"$legendex\" \"$legendey\" "
       close $file_id
       set file_id [open "$audace(rep_images)/trace_gp.bat" w+]
       puts $file_id "gnuplot \"${spcfile}.gp\" "
       close $file_id
       # exec gnuplot $repertoire_gp/run_gp
       ::console::affiche_resultat "Exécuter dans un terminal : trace_gp.bat\n"
   } else {
       ::console::affiche_erreur "Usage: spc2pngb fichier_fits ?xdébut xfin?\n\n"
   }
}
####################################################################






