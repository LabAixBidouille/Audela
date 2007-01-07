####################################################################################
#
# Procedures d'entree-sortie gérant des spectres
# Auteur : Benjamin MAUCLAIRE
# Date de création : 31-01-2005
# Date de mise a jour : 21-02-2005
# Chargement en script : 
# A130 : source $audace(rep_scripts)/spcaudace/spc_io.tcl
# A140 : source [ file join $audace(rep_plugin) tool spectro spcaudace spc_io.tcl ]
#
#####################################################################################


# Remarque (par Benoît) : il faut mettre remplacer toutes les variables textes par des variables caption(mauclaire,...)
# qui seront initialisées dans le fichier cap_mauclaire.tcl
# et renommer ce fichier mauclaire.tcl ;-)

#global audace


####################  Liste des fonctions ###############################
#
# spc_spc2png : converti un profil de raies format fits en une image format png avec gnuplot
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

proc openfile { args } {
   global conf
   global audace

 if {[llength $args] == 1} {
   set filenamespc [ lindex $args 0 ]
   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $audace(rep_images)]
   set profilspc(initialfile) [file tail $filenamespc]
   set input [open "$audace(rep_images)/$filenamespc" r]
   close input
   return $input
 } else {
   ::console::affiche_erreur "Usage: openfile fichier.fit\n\n"
 }
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
# Date modification : 15-02-2005 / 17-12-2005 / 20-12-2005
# Arguments : nom du repertoire/fichier
# Sortie : 
#  Si calibré : liste contenant la liste des valeurs de l'intensité, NAXIS1, CRVAL1, CDELT1, CRPIX1, CTYPE1.
#  Si non calibre : liste contenant la liste des valeurs de l'intensité, NAXIS1
# Remarque : fonction appelée par spc_loadfit (spc_profil.tcl)
########################################################

proc openspc { args } {
    global conf
    global audace
    #global profilspc

 if {[llength $args] == 1} {
   set filenamespc [ lindex $args 0 ]
   catch {unset profilspc} {}
   #set profilspc(initialdir) [file dirname $audace(rep_images)]
   #set profilspc(initialfile) [file tail $filenamespc]
   #set repertoire [file dirname $audace(rep_images)]
   #- Modif bug le 051221 : FIN BUG !
   set repertoire [file dirname $filenamespc]
   set fichier [file tail $filenamespc]

   #-- Remis le 16/12/2005
   #buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   #-- Remis le 15/02/2005
   #buf$audace(bufNo) load "$filenamespc"
   #-- Mis le 17/12/2005
   #cd $repertoire
   #loadima $filenamespc -nodisp
   #-- Mis le 20/12/2005
   buf$audace(bufNo) load $repertoire/$fichier

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
       set spectre [openspcncal $repertoire $fichier]
   } else {
       ::console::affiche_resultat "Ouverture d'un spectre calibré $filenamespc\n"
       set spectre [openspccal $repertoire $fichier]
   }
   return $spectre
 } else {
   ::console::affiche_erreur "Usage: openspc fichier_profil.fit\n\n"
 }
}
#****************************************************************#


#######################################################
#  Procedure d'ouverture de spectre non calibré (lambda) au format fits
#
# Auteur : Benjamin MAUCLAIRE
# Date création : 15-02-2005
# Date modification : 20-12-2005
# Arguments : nom du répertoire, nom du fichier
# Sortie : liste contenant la liste des valeurs de l'intensité, NAXIS1
########################################################

proc openspcncal { args } {
   global conf
   global audace

 if {[llength $args] == 2} {
   set repertoire [ lindex $args 0 ]
   set filenamespc [ lindex $args 1 ]
   #catch {unset profilspc} {}
   #set profilspc(initialdir) [file dirname $audace(rep_images)]
   #set profilspc(initialfile) [file tail $filenamespc]
   buf$audace(bufNo) load $repertoire/$filenamespc
   #buf$audace(bufNo) load $filenamespc

   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]

   for {set k 1} {$k<=$naxis1} {incr k} {
       # Lit la valeur des elements du fichier fit
       lappend intensites [buf$audace(bufNo) getpix [list $k 1]]
   }
   set spectre [list $intensites $naxis1]
   return $spectre
 } else {
   ::console::affiche_erreur "Usage: openspcncal répertoire fichier_profil.fit\n\n"
 }
}
#****************************************************************#



#######################################################
#  Procedure d'ouverture de spectre calibré (lambda) au format fits
#
# Auteur : Benjamin MAUCLAIRE
# Date création : 15-02-2005
# Date modification : 15-02-2005
# Arguments : répertoire nom du fichier
# Sortie : liste contenant la liste des valeurs de l'intensité, NAXIS1, CRVAL1, CDELT1, CRPIX1, CTYPE1.
########################################################

proc openspccal { args } {
   global conf
   global audace

 if {[llength $args] == 2} {
   set repertoire [ lindex $args 0 ]
   set filenamespc [ lindex $args 1 ]
   #catch {unset profilspc} {}
   #set profilspc(initialdir) [file dirname $audace(rep_images)]
   ##set profilspc(initialfile) [file tail $filenamespc]
   ##buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   #buf$audace(bufNo) load "$filenamespc"
   buf$audace(bufNo) load $repertoire/$filenamespc

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
       #-- Lit la valeur des elements du fichier fit
       # lappend intensites [buf$audace(bufNo) getpix [list $k 1]]
       #-- Gestion des valeurs "nan" de l'intensite
       set ival [ buf$audace(bufNo) getpix [list $k 1] ]
       #if { $ival == "nan" } {
   #   lappend intensites 0
   #   ::console::affiche_resultat "Cas nan : $ival\n"
       #} else {
      lappend intensites $ival
       #}
   }
   set spectre [list $intensites $naxis1 $xdepart $xincr $xcenter "$dtype"]
   return $spectre
 } else {
   ::console::affiche_erreur "Usage: openspccal répertoire fichier_profil.fit\n\n"
 }
}
#****************************************************************#



#######################################################
#  Procedure d'ouverture d'un profil spectral au format fits
#
# Auteur : Benjamin MAUCLAIRE
# Date création : 11-12-2005
# Date modification : 11-12-2005
# Arguments : nom du fichier profil de raies calibré
# Sortie : liste contenant la liste des valeurs des abscisses et intensités
########################################################

proc spc_openspcfits { args } {

    global conf
    global audace

    if {[llength $args] == 1} {
   set filenamespc [ lindex $args 0 ]
   set erreur [ lindex $args 1 ]
   buf$audace(bufNo) load $audace(rep_images)/$filenamespc
   #buf$audace(bufNo) load $filenamespc
   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
   #--- Valeur minimale de l'abscisse : =0 si profil non étalonné
   set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
   #--- Dispersion du spectre : =1 si profil non étalonné
   set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
   ::console::affiche_resultat "$naxis1 points à traiter\n"
   
       #--- Une liste commence à 0 ; Un vecteur fits commence à 1
      for {set k 0} {$k<$naxis1} {incr k} {
      #--- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
      lappend abscisses [expr $xdepart+($k)*$xincr*1.0]
      #--- Lit la valeur (intensite) des elements du fichier fit
      lappend ordonnees [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
       }

   set sortie [list $abscisses $ordonnees]
   return $sortie
    } else {
   ::console::affiche_erreur "Usage: spc_openspcfits fichier_profil.fit\n\n"
    }
}
#****************************************************************#


###################################################################
#  Procedure de conversion de fichier profil de raies .dat en .fit
# 
# Auteur : Benjamin MAUCLAIRE
# Date creation : 31-01-2005
# Date modification : 15-02-2005/27-04-2006
# Arguments : fichier .dat du profil de raie ?fichier_sortie.fit?
###################################################################

proc spc_dat2fits { args } {

    global conf
    global audace
    set extsp ".dat"
    #set nbunit "float"
    set nbunit "double"
    set precision 0.05
    
    if { [llength $args] <= 2 } {
   if { [llength $args] == 1 } {
       set filenamespc [ lindex $args 0 ]
   } elseif { [llength $args] == 2 } {
       set filenamespc [ lindex $args 0 ]
       set filenameout [ lindex $args 1 ]
   } else {
       ::console::affiche_erreur "Usage: spc_dat2fits fichier_profil.dat ?fichier_sortie.fit?\n\n"
   }
   ## === Lecture du fichier de donnees du profil de raie ===
   set input [open "$audace(rep_images)/$filenamespc" r]
   set contents [split [read $input] \n]
   close $input
   ## === Extraction des numeros des pixels et des intensites ===
   #::console::affiche_resultat "ICI :\n $contents.\n"
   #set profilspc(naxis1) [expr [llength $contents]-2]
   set naxis1 [ expr [llength $contents]-1 ]
   #::console::affiche_resultat "$profilspc(naxis1)\n"
   set offset 1
   # Une liste commence à 0
   for {set k -1} {$k < $naxis1} {incr k} {
       set ligne [lindex $contents $k]
       append pixels "[lindex $ligne 0] "
       append intensites "[lindex $ligne 1] "
       #incr $k
   }
   #::console::affiche_resultat "$profilspc(pixels)\n"
   
   # === On prepare les vecteurs a afficher ===
   # len : longueur du profil (NAXIS1)
   #set len [llength $profilspc(pixels)]
   set nintensites ""
   for {set k 0} {$k<=$naxis1} {incr k} {
       append nintensites " [lindex $intensites $k]"
   }
   
   #--- Initialisation à blanc d'un fichier fits
   buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 1 FORMAT_FLOAT COMPRESS_NONE 0
###--- Modif Michel
   buf$audace(bufNo) setkwd [ list NAXIS 1 int "" "" ]
   buf$audace(bufNo) setkwd [ list NAXIS1 $naxis1 int "" "" ]
###--- Modif Michel
   
   #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
   # Une liste commence à 0 ; Un vecteur fits commence à 1
   set intensite 0
   for {set k 0} {$k<$naxis1} {incr k} {
       append intensite [lindex $nintensites $k]
       #::console::affiche_resultat "$intensite\n"
       if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
      buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
      set intensite 0
       }
   }
   
   #=============================
   
   set flag 0
   if { $flag == 1 } {
       #--- Type de dispersion : LINEAR, NONLINEAR
       
       #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
       # Une liste commence à 0 ; Un vecteur fits commence à 1
       set intensite 0
       for {set k 0} {$k<$naxis1} {incr k} {
      append intensite [lindex $nintensites $k]
      #::console::affiche_resultat "$intensite\n"
      if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
          buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
          set intensite 0
      }
       }
   }
   #==============================
   
   #------- Affecte une valeur aux mots cle liés à la spectroscopie ----------
   #-- buf$audace(bufNo) setkwd [list "INSTRU" "T310" string "mon télescope" ""]
   #buf$audace(bufNo) setkwd [list "NAXIS1" "$len" int "" ""]
   #buf$audace(bufNo) setkwd [list "NAXIS2" "1" int "" ""]
   #--- Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
   set xdepart [ expr 0.0+1.0*[lindex $pixels 0] ]
   buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart $nbunit "" ""]
   
   #--- Valeur de la longueur d'onde/pixel de fin ***** naxis1ici-1=naxis1-2 A VERFIFIER ****
   set xdernier [lindex $pixels [expr $naxis1-1]]
   ::console::affiche_resultat "Xdep : $xdepart ; Xfin : $xdernier\n"
   #set xcentre [expr int(0.5*($xdernier-$xdepart))]
   #buf$audace(bufNo) setkwd [list "CRPIX1" "$xcentre" double "" ""]
   
   #--- Dispersion du spectre :
   #-- Calcul dans le cas d'une dispersion non linéaire
   set l1 [lindex $pixels 1]
   set l2 [lindex $pixels [expr int($naxis1/10)]]
   set l3 [lindex $pixels [expr int(2*$naxis1/10)]]
   set l4 [lindex $pixels [expr int(3*$naxis1/10)]]
   set dl1 [expr ($l2-$l1)/(int($naxis1/10)-1.0)]
   set dl2 [expr ($l4-$l3)/(int($naxis1/10)-1.0)]
   set dispersion [expr 0.5*($dl2+$dl1)]
   #-- Mesure de la dispersion supposée linéaire
   set l1 [lindex $pixels 1]
   set l2 [lindex $pixels 2]
   set dispersion [expr 1.0*abs($l2-$l1)]
   
   #-- Meth2 : erreur si spectre de moins de 4 pixels
   #set l2 [lindex $profilspc(pixels) 4]
   #set l3 [lindex $profilspc(pixels) [expr 1+int($len/2)]]
   #set l4 [lindex $profilspc(pixels) [expr 4+int($len/2)]]
   #set dl1 [expr ($l2-$l1)/3]
   #set dl2 [expr ($l4-$l3)/3]
   #set xincr [expr 0.5*($dl2+$dl1)]
   
   #-- Ecriture du mot clef
   ::console::affiche_resultat "Dispersion : $dispersion\n"
   if { $xdepart == 1.0 } {
       buf$audace(bufNo) setkwd [list "CDELT1" $dispersion $nbunit "" "pixel"]
   } else {
       buf$audace(bufNo) setkwd [list "CDELT1" $dispersion $nbunit "" "Angstrom/pixel"]
   }
   
   #--- Type de dispersion : LINEAR, NONLINEAR
   
   #--- Sauve le fichier fits ainsi constitué 
   ::console::affiche_resultat "$naxis1 lignes affectées\n"
   buf$audace(bufNo) bitpix float
   if {[llength $args] == 1} {
       set nom [ file rootname $filenamespc ]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/${nom}$conf(extension,defaut)"
       ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${nom}$conf(extension,defaut)\n"
       return ${nom}
   } elseif {[llength $args] == 2} {
       set nom [ file rootname $filenameout ]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/${filenameout}$conf(extension,defaut)"
       ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${filenameout}$conf(extension,defaut)\n"
       return ${filenameout}
   }
   #buf$audace(bufNo) bitpix short
    } else {
   ::console::affiche_erreur "Usage: spc_dat2fits fichier_profil.dat ?fichier_sortie.fit?\n\n"
    }
}
#****************************************************************#




####################################################################
#  Procedure de conversion de fichier profil de raie spatial .fit en .dat
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 16-05-2005/20-09-06
# Arguments : fichier .fit du profil de raie ?fichier_sortie.dat?\
####################################################################

proc spc_fits2dat { args } {

  global conf
  global audace
  #global profilspc
  # global captionspc
  global colorspc
  set extsp ".dat"

  if {[llength $args] <= 2} {
     if  {[llength $args] == 1} {
    set filenamespc [ lindex $args 0 ]
     } elseif {[llength $args] == 2} {
    set filenamespc [ lindex $args 0 ]
    set filenameout [ lindex $args 1 ]
     } else {
    ::console::affiche_erreur "Usage: spc_fits2dat fichier_profil.fit ?fichier_sortie.dat?\n\n"
    return 0
     }

 
     buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
     set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
     set listemotsclef [ buf$audace(bufNo) getkwds ]
     if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
    set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
     }
     if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
    set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
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

     #--- Type de spectre : LINEAR ou NONLINEAR (elinine les espaces dans la valeur du mot clef.
     # set dtype [string trim [lindex [buf$audace(bufNo) getkwd "CTYPE1"] 1]]
     #::console::affiche_resultat "Ici 1\n"
     #if { $dtype != "LINEAR" || $dtype == "" } {
    #    ::console::affiche_resultat "Le spectre ne possède pas une disersion linéaire. Pas de conversion possible.\n"
    #    break
     #}
     #::console::affiche_resultat "Ici 2\n"
     set len [expr int($naxis1/$dispersion)]
     ::console::affiche_resultat "$naxis1 intensités à traiter\n"

     if {[llength $args] == 1} {
    set fileetalonnespc [ file rootname $filenamespc ]
    set fileout ${fileetalonnespc}$extsp
    set file_id [open "$audace(rep_images)/$fileout" w+]
     } elseif {[llength $args] == 2} {
    set fileout $filenameout
    set file_id [open "$audace(rep_images)/$fileout" w+]
     } else {
    ::console::affiche_erreur "Usage: spc_fits2dat fichier_profil_fit ?fichier_sortie.dat?\n\n"
    return 0
     }

     if { $lambda0 != 1 } {
    if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
        #-- Calibration non-linéaire :
        for {set k 0} {$k<$naxis1} {incr k} {
       set lambda [ expr $spc_a*$k*$k+$spc_b*$k+$spc_c ]
       set intensite [ buf$audace(bufNo) getpix [list [expr $k+1] 1] ]
       puts $file_id "$lambda\t$intensite"
        }
    } else {
        #-- Calibration linéaire :
        #-- Une liste commence à 0 ; Un vecteur fits commence à 1
        for {set k 0} {$k<$naxis1} {incr k} {
       #-- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
       set lambda [ expr $lambda0+($k)*$dispersion*1.0 ]
       #-- Lit la valeur des elements du fichier fit
       set intensite [ buf$audace(bufNo) getpix [list [expr $k+1] 1] ]
       ##lappend profilspc(intensite) $intensite
       #-- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
       puts $file_id "$lambda\t$intensite"
        }
    }
     } else {
    #-- Profil non calibré :
    for {set k 0} {$k<$naxis1} {incr k} {
        set pixel [expr $k+1]
        set intensite [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
        puts $file_id "$pixel\t$intensite"
    }
     }
     close $file_id
     ::console::affiche_resultat "Fichier fits exporté sous $audace(rep_images)/$fileout\n"
  } else {
     ::console::affiche_erreur "Usage: spc_fits2dat fichier_profil_fit ?fichier_sortie.dat?\n\n"
  }
}
#****************************************************************#





####################################################################
# Procedure de création d'un fichier profil de raie fits à partir des données x et y
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 15-12-2005
# Arguments : nom fichier fit de sortie, une liste de coordonnées x puis y, unité des données
####################################################################

proc spc_data2fits { args } {
    global audace
    global conf
    set precision 0.0001
    #set nbunit "float"
    #set nbunit "double"

  if { [llength $args] <= 3 } {
    if { [llength $args] == 3 } {
   #set nom_fichier [ file rootname [lindex 0] ]
   set nom_fichier [lindex $args 0]
   set coordonnees [lindex $args 1]
   set nbunit [lindex $args 2]
    } elseif { [llength $args] == 2 } {
   set nom_fichier [lindex $args 0]
   set coordonnees [lindex $args 1]
   set nbunit "float"
    } else {
   ::console::affiche_erreur "Usage: spc_data2fits nom_fichier_fits_sortie liste_coordonnées_x_et_y unitées_coordonnées (float/double)\n\n"
    }

   set abscisses [lindex $coordonnees 0]
   set intensites [lindex $coordonnees 1]
   set len [llength $abscisses]

   #--- Création du fichier fits
   buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
   buf$audace(bufNo) setkwd [list "NAXIS1" $len int "" ""]
   # buf$audace(bufNo) setkwd [list "NAXIS2" 1 int "" ""]

   #--- Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
   set xdepart [expr 1.0*[lindex $abscisses 0] ]
   buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart $nbunit "" "Angstrom"]

   #--- Calcul d'une dispersion moyenne :
   set l1 [lindex $abscisses 1]
   set l2 [lindex $abscisses 2]
   set disp1 [expr 1.0*abs($l2-$l1)]
   set l1 [lindex $abscisses [expr int($len/2)] ]
   set l2 [lindex $abscisses [expr int($len/2)+1] ]
   set disp2 [expr 1.0*abs($l2-$l1)]
   if { [ expr abs($disp2- $disp1) ] <= $precision } {
       #-- Mesure de la dispersion suposée linéaire
       set dispersion $disp1
   } else {
       #-- Mesure de la dispersion suposée non-linéaire
       #set dispersion [spc_dispersion_moy $abscisses]
       set l1 [lindex $abscisses 1]
       set l2 [lindex $abscisses [expr int($len/10)]]
       set l3 [lindex $abscisses [expr int(2*$len/10)]]
       set l4 [lindex $abscisses [expr int(3*$len/10)]]
       set dl1 [expr ($l2-$l1)/(int($len/10)-1)]
       set dl2 [expr ($l4-$l3)/(int($len/10)-1)]
       set dispersion [expr 0.5*($dl2+$dl1)]
       #set dispersion $disp1
   }

   #--- Calcul de la dispersion par régression linéaire :
   for {set k 1} {$k<=$len} {incr k} {
       lappend xpos $k
   }
   set listevals [ list $abscisses $xpos ]
   set coeffsdeg1 [ spc_reglin $listevals ]
   set dispersion [ expr 1.0/[ lindex $coeffsdeg1 0 ] ]

   
   #--- Mise à jour fichier fits
   buf$audace(bufNo) setkwd [list "CDELT1" $dispersion $nbunit "" "Angstrom/pixel"]

   #--- Type de dispersion : LINEAR, NONLINEAR
   #if { [expr abs($dl2-$dl1)] <= $precision } {
   #    buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]
   #} elseif { [expr abs($dl2-$dl1)] > $precision } {
   #    buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]
   #}

   #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
   # Une liste commence à 0 ; Un vecteur fits commence à 1
   set intensite 0
   for {set k 0} {$k<$len} {incr k} {
       append intensite [lindex $intensites $k]
       #::console::affiche_resultat "$intensite\n"
       if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
      buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
      set intensite 0
       }
   }

   #--- Sauvegarde du fichier fits ainsi créé
   if { $nbunit == "double" || $nbunit == "float" } {
       buf$audace(bufNo) bitpix float
   } elseif { $nbunit == "int" } {
       buf$audace(bufNo) bitpix short
   }
   buf$audace(bufNo) save "$audace(rep_images)/$nom_fichier$conf(extension,defaut)"
   return $nom_fichier
    } else {
       ::console::affiche_erreur "Usage: spc_data2fits nom_fichier_fits_sortie liste_coordonnées_x_et_y unitées_coordonnées (float/double)\n\n"
    }
}
#**********************************************************************#




####################################################################
#  Procedure de conversion de fichier profil de raie fits en une liste contenant les listes valeurs X et Y.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-12-2005
# Date modification : 20-12-2005/20-09-06
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_fits2data { args } {

 global conf
 global audace

 if {[llength $args] == 1} {
     set filenamespc [ lindex $args 0 ]

     buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
     set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
     set listemotsclef [ buf$audace(bufNo) getkwds ]
     if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
    set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
     }
     if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
    set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
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
    set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
     }
     #--- Valeur minimale de l'abscisse : =0 si profil non étalonné
     ::console::affiche_resultat "$naxis1 intensités à traiter...\n"

     #--- Spectre calibré en lambda
     if { $lambda0 != 1 } {
    #-- Calibration non-linéaire :
    if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
        for {set k 0} {$k<$naxis1} {incr k} {
       #- Une liste commence à 0 ; Un vecteur fits commence à 1
       lappend abscisses [ expr $spc_a*$k*$k+$spc_b*$k+$spc_c ]
       lappend intensites [ buf$audace(bufNo) getpix [list [expr $k+1] 1] ]
        }
        #-- Calibration linéaire :
    } else {
        for {set k 0} {$k<$naxis1} {incr k} {
       lappend abscisses [ expr $lambda0+($k)*$dispersion*1.0 ]
       lappend intensites [ buf$audace(bufNo) getpix [list [expr $k+1] 1] ]
        }
    }
     } else {
    #--- Spectre non calibré en lambda :         
    for {set k 0} {$k<$naxis1} {incr k} {
        lappend abscisses [ expr $k+1 ]
        lappend intensites [ buf$audace(bufNo) getpix [list [expr $k+1] 1] ]
    }
     }
     set coordonnees [list $abscisses $intensites]
     return $coordonnees
 } else {
     ::console::affiche_erreur "Usage: spc_fits2data fichier_fits_profil.fit\n\n"
 }
}
#****************************************************************#


####################################################################
#  Procedure de conversion de fichier profil de raie fits en une liste contenant les listes valeurs X et Y.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 24-09-2006
# Date modification : 20-12-2005/24-09-06
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_fits2datadlin { args } {

 global conf
 global audace

 if {[llength $args] == 1} {
     set filenamespc [ lindex $args 0 ]

     buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
     set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
     set listemotsclef [ buf$audace(bufNo) getkwds ]
     if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
    set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
     }
     if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
    set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
     }
     #--- Valeur minimale de l'abscisse : =0 si profil non étalonné
     ::console::affiche_resultat "$naxis1 intensités à traiter...\n"

     #--- Spectre calibré en lambda de dispersion imposée linéaire :
     if { $lambda0 != 1 } {
    for {set k 0} {$k<$naxis1} {incr k} {
        lappend abscisses [ expr $lambda0+($k)*$dispersion*1.0 ]
        lappend intensites [ buf$audace(bufNo) getpix [list [expr $k+1] 1] ]
    }
     } else {
    #--- Spectre non calibré en lambda :         
    for {set k 0} {$k<$naxis1} {incr k} {
        lappend abscisses [ expr $k+1 ]
        lappend intensites [ buf$audace(bufNo) getpix [list [expr $k+1] 1] ]
    }
     }
     set coordonnees [list $abscisses $intensites]
     return $coordonnees
 } else {
     ::console::affiche_erreur "Usage: spc_fits2datadlin fichier_fits_profil.fit\n\n"
 }
}
#****************************************************************#



####################################################################
#  Procedure de conversion de fichier profil de raie .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 14-08-2005
# Date modification : 26-04-2006
# Arguments : fichier .fit du profil de raie, légende axe X, légende axe Y, pas
####################################################################

proc spc_fit2pngman { args } {
    global audace
    global conf

    if { [llength $args] == 5 } {
   set fichier [ lindex $args 0 ]
   set titre [ lindex $args 1 ]
   set legendex [ lindex $args 2 ]
   set legendey [ lindex $args 3 ]
   set pas [ lindex $args 4 ]
   set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
   set ext ".dat"
   spc_fits2dat $fichier
   # Retire l'extension .fit du nom du fichier
   set spcfile [ file rootname $fichier ]

   #--- Prepare le script pour gnuplot
   set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
   put $file_id "call \"${repertoire_gp}/gp_spc.cfg\" \"${spcfile}$ext\" \"$titre\" * * * * $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" "
   close $file_id

   #--- Execute Gnuplot pour l'export en png
   if { $tcl_platform(os)=="Linux" } {
       set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
       ::console::affiche_resultat "$answer\n"
   } else {
       set answer [ catch { exec ${repertoire_gp}/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
       ::console::affiche_resultat "$answer\n"
   }
   ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
   } else {
       ::console::affiche_erreur "Usage: spc_fit2pngman fichier_fits titre légende_axeX légende_axeY intervalle_graduations\n\n"
   }
}
####################################################################



####################################################################
#  Procedure de conversion de fichier profil de raie calibré .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 14-08-2005
# Date modification : 26-04-2006
# Arguments : fichier .fit du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc_fit2png { args } {
    global audace
    global conf
    global tcl_platform
    #-- 3%=0.03
    set lpart 0

    if { [llength $args] == 4 || [llength $args] == 2 } {
   if { [llength $args] == 2 } {
       set fichier [ lindex $args 0 ]
       set titre [ lindex $args 1 ]
       #set xdeb "*"
       #set xfin "*"
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       #-- Demarre et fini le graphe en deçca de 3% des limites pour l'esthetique
       set largeur [ expr $lpart*$naxis1 ]
       set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
       set xdeb [ expr $xdeb0+$largeur ]
       set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
   } elseif { [llength $args] == 4 } {
       set fichier [ lindex $args 0 ]
       set titre [ lindex $args 1 ]
       set xdeb [ lindex $args 2 ]
       set xfin [ lindex $args 3 ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
   }

   #--- Adapte la légende de l'abscisse
   if { $xdeb0 == 1.0 } {
       set legendex "Position (Pixel)"
   } else {
       set legendex "Wavelength (A)"
   }
       
   set legendey "Intensity (ADU)"
   set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
   set ext ".dat"
   
   spc_fits2dat $fichier
   #-- Retire l'extension .fit du nom du fichier
   set spcfile [ file rootname $fichier ]
   
   #--- Créée le fichier script pour gnuplot :
   ## exec echo "call \"${repertoire_gp}/gpx11.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
   # exec echo "call \"${repertoire_gp}/gp_novisu.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin * \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
   set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
   puts $file_id "call \"${repertoire_gp}/gp_novisu.cfg\" \"$audace(rep_images)/${spcfile}$ext\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/${spcfile}.png\" \"$legendex\" \"$legendey\" "
   close $file_id

   #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
   #exec gnuplot "$audace(rep_images)/${spcfile}.gp"
   # exec gnuplot $repertoire_gp/run_gp
   # exec rm -f $repertoire_gp/run_pg
   if { $tcl_platform(os)=="Linux" } {
       # set gnuplotex "/usr/bin/gnuplot"
       # catch { exec $gnuplotex "$audace(rep_images)/${spcfile}.gp" }
       set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
       ::console::affiche_resultat "$answer\n"
   } else {
       # set gnuplotex "C:\Programms Files\gnuplot\gnuplot.exe"
       # exec $gnuplotex "$audace(rep_images)/${spcfile}.gp"
       # exec gnuplot "$audace(rep_images)/${spcfile}.gp"
       #-- wgnuplot et pgnuplot doivent etre dans le rep gp de spcaudace
       set answer [ catch { exec ${repertoire_gp}/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
       ::console::affiche_resultat "$answer\n"
   }

   ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
    } else {
   ::console::affiche_erreur "Usage: spc_fit2png fichier_fits \"Titre\" ?xdébut xfin?\n\n"
    }
}
####################################################################


####################################################################
#  Procedure de création du fichier batch pour gnuplot afin de convertir un fichier profil de raie calibré .fit en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-09-2005
# Date modification : 03-09-2005
# Arguments : fichier .fit du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc_fit2pngbat { args } {
   global audace
   global conf
   set ecart 0.005

   if { [llength $args] == 4 || [llength $args] == 2 } {
       if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      #set xdeb "*"
      #set xfin "*"
      buf$audace(bufNo) load "$audace(rep_images)/$fichier"
      set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
      #-- Demarre et fini le graphe en deçca de 3% des limites pour l'esthetique
      set largeur [ expr $ecart*$naxis1 ]
      set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
      set xdeb [ expr $xdeb0+$largeur ]
      set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
      #set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
      set xfin [ expr $naxis1*$xincr+$xdeb0-1*$largeur ]
       } elseif { [llength $args] == 4 } {
      set fichier [ lindex $args 0 ]
      set titre [ lindex $args 1 ]
      set xdeb [ lindex $args 2 ]
      set xfin [ lindex $args 3 ]
      buf$audace(bufNo) load "$audace(rep_images)/$fichier"
      set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
       }

       #--- Adapte la légende de l'abscisse
       if { $xdeb0 == 1.0 } {
      set legendex "Position (Pixel)"
       } else {
      set legendex "Wavelength (A)"
       }
       set legendey "Intensity (ADU)"

       set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
       set ext ".dat"

       spc_fits2dat $fichier
       # Retire l'extension .fit du nom du fichier
       set spcfile [ file rootname $fichier ]
       #exec echo "call \"${repertoire_gp}/gpx11.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
       set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
       puts $file_id "call \"${repertoire_gp}/gp_visu.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin * \"${spcfile}.png\" \"$legendex\" \"$legendey\" "
       close $file_id
       set file_id [open "$audace(rep_images)/trace_gp.bat" w+]
       puts $file_id "gnuplot \"${spcfile}.gp\" "
       close $file_id
       # exec gnuplot $repertoire_gp/run_gp
       ::console::affiche_resultat "Exécuter dans un terminal : trace_gp.bat\n"
   } else {
       ::console::affiche_erreur "Usage: spc_fit2pngbat fichier_fits \"Titre\" ?xdébut xfin?\n\n"
   }
}
####################################################################



####################################################################
#  Procedure de conversion de fichier profil de raie calibré .dat en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-04-2006
# Date modification : 27-04-2006
# Arguments : fichier .dat du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc_dat2png { args } {
    global audace
    global conf
    global tcl_platform

    if { [llength $args] == 4 || [llength $args] == 2 } {
   if { [llength $args] == 2 } {
       set fichier [ lindex $args 0 ]
       set titre [ lindex $args 1 ]
       #set xdeb "*"
       #set xfin "*"
       set fichierfit [ spc_dat2fits $fichier ${fichier}_fittmp ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichierfit"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       #-- Demarre et fini le graphe en deçca de 3% des limites pour l'esthetique
       set largeur [ expr 0.03*$naxis1 ]
       set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
       set xdeb [ expr $xdeb0+$largeur ]
       set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
   } elseif { [llength $args] == 4 } {
       set fichier [ lindex $args 0 ]
       set titre [ lindex $args 1 ]
       set xdeb [ lindex $args 2 ]
       set xfin [ lindex $args 3 ]
       set fichierfit [ spc_dat2fits $fichier ${fichier}_fittmp ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichierfit"
       set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
   }

   #--- Adapte la légende de l'abscisse
   if { $xdeb0 == 1.0 } {
       set legendex "Position (Pixel)"
   } else {
       set legendex "Wavelength (A)"
   }
   set legendey "Intensity (ADU)"

   set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
   set ext ".dat"
   
   #spc_fits2dat $fichier
   #-- Retire l'extension .fit du nom du fichier
   set spcfile [ file rootname $fichier ]
   
   #--- Créée le fichier script pour gnuplot :
   set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
   puts $file_id "call \"${repertoire_gp}/gp_novisu.cfg\" \"$audace(rep_images)/${spcfile}$ext\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/${spcfile}.png\" \"$legendex\" \"$legendey\" "
   close $file_id

   #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
   if { $tcl_platform(os)=="Linux" } {
       set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
       ::console::affiche_resultat "$answer\n"
   } else {
       set answer [ catch { exec ${repertoire_gp}/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
       ::console::affiche_resultat "$answer\n"
   }

   ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
    } else {
   ::console::affiche_erreur "Usage: spc_dat2png fichier_fits \"Titre\" ?xdébut xfin?\n\n"
    }
}
####################################################################



####################################################################
#  Procedure de conversion de fichier profil de raie .dat en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-04-2006
# Date modification : 26-04-2006
# Arguments : fichier .dat du profil de raie, légende axe X, légende axe Y, pas
####################################################################

proc spc_dat2pngman { args } {
    global audace
    global conf

    if { [llength $args] == 5 } {
   set fichier [ lindex $args 0 ]
   set titre [ lindex $args 1 ]
   set legendex [ lindex $args 2 ]
   set legendey [ lindex $args 3 ]
   set pas [ lindex $args 4 ]
   set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]

   set ext ".dat"
   # Retire l'extension .fit du nom du fichier
   set spcfile [ file rootname $fichier ]

   #--- Prepare le script pour gnuplot
   set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
   put $file_id "call \"${repertoire_gp}/gp_spc.cfg\" \"${spcfile}$ext\" \"$titre\" * * * * $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" "
   close $file_id

   #--- Execute Gnuplot pour l'export en png
   if { $tcl_platform(os)=="Linux" } {
       set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
       ::console::affiche_resultat "$answer\n"
   } else {
       set answer [ catch { exec ${repertoire_gp}/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
       ::console::affiche_resultat "$answer\n"
   }
   ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
   } else {
       ::console::affiche_erreur "Usage: spc_dat2pngman fichier_fits \"titre\" \"légende_axeX\" \"légende_axeY\" intervalle_graduations\n\n"
   }
}
####################################################################




###################################################################
#  Procedure de conversion de fichier profil de raies .spc (VisualSpec) en .fit
# 
# Auteur : Benjamin MAUCLAIRE
# Date creation : 09-12-2005
# Date modification : 09-12-2005
# Arguments : fichier .spc du profil de raie
###################################################################
proc spc_spc2fits { args } {

 global conf
 global audace
 #global profilspc
 global captionspc
 global colorspc

#    set profilspc(xunit) "Position"
#    set profilspc(yunit) "ADU"

 if {[llength $args] == 1} {
   set filenamespc [ lindex $args 0 ]
   ## === Lecture du fichier de donnees du profil de raie ===
   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $audace(rep_images)]
   set profilspc(initialfile) [file tail $filenamespc]
   set input [open "$audace(rep_images)/$filenamespc" r]

   #--- Charge le contenu du fichier et enleve l'entête
   #-- Retourne une chaîne
   set contents [split [read $input] \n]
   close $input
   set profilspc(naxis1) [expr [lindex $contents 2]]
   set profilspc(exptime) [expr [lindex $contents 2]]
   set dateobs [lindex $contents 4]
   set profilspc(object) [lindex $contents 7]
   #set offset [expr [lindex $contents 1]+3]
   set offset [expr [lindex $contents 1]+15]

   ## === Extraction des numeros des pixels et des intensites ===
   for {set k 1} {$k <= $profilspc(naxis1)} {incr k} {
      set ligne [lindex $contents $offset]
      append profilspc(pixels) "[lindex $ligne 1] "
      #append profilspc(lambda) "[lindex $ligne 1] "
      append profilspc(intensite) "[lindex $ligne 2] "
      #append profilspc(argon1) "[lindex $ligne 3] "
      #append profilspc(argon2) "[lindex $ligne 4] "
      #append profilspc(noir) "[lindex $ligne 5] "
      #append profilspc(repere) "[lindex $ligne 6] "
      incr offset
   }
   #::console::affiche_resultat "ICI :\n $contents\n"
   #::console::affiche_resultat "ICI :\n $profilspc(pixels)\n"
   #::console::affiche_resultat "ICI :\n $profilspc(intensite)\n"

   # === On prepare les vecteurs a afficher ===
   # len : longueur du profil (NAXIS1)
   set len $profilspc(naxis1)

   # Initialisation à blanc d'un fichier fits
   buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
###--- Modif Michel
   buf$audace(bufNo) setkwd [ list NAXIS 1 int "" "" ]
   buf$audace(bufNo) setkwd [ list NAXIS1 $len int "" "" ]
###--- Modif Michel

   set intensite 0
   #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
   # Une liste commence à 0 ; Un vecteur fits commence à 1
   for {set k 0} {$k<$len} {incr k} {
       append intensite [lindex $profilspc(intensite) $k]
       #::console::affiche_resultat "$intensite\n"
       #--- Vérifie que l'intensité est bien un nombre
       if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
      buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
      set intensite 0
       }
   }

   #------- Affecte une valeur aux mots cle liés à la spectroscopie ----------
   #- Modele :  buf$audace(bufNo) setkwd [list "INSTRU" "T310" string "mon télescope" ""]
   buf$audace(bufNo) setkwd [list "NAXIS1" $len int "" ""]
   buf$audace(bufNo) setkwd [list "NAXIS2" 1 int "" ""]
   buf$audace(bufNo) setkwd [list "OBJNAME" "$profilspc(object)" string "" ""]
   buf$audace(bufNo) setkwd [list "DATE-OBS" "$dateobs" string "" ""]
   #- ::console::affiche_resultat "mot : $dateobs\n"
   #--- Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné, DOUBLE ?
   set xdepart [expr 1.0*[lindex $profilspc(pixels) 0] ]
   buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart float "" "Angstrom"]
   #--- Valeur de la longueur d'onde/pixel central(e)
   set xdernier [lindex $profilspc(pixels) [expr $profilspc(naxis1)-1]]
   ::console::affiche_resultat "Xdep : $xdepart ; Xfin : $xdernier\n"
   #set xcentre [expr int(0.5*($xdernier-$xdepart))]
   #buf$audace(bufNo) setkwd [list "CRPIX1" "$xcentre" double "" "Angstrom"]
   #--- Dispersion du spectre :
   set l1 [lindex $profilspc(pixels) 1]
   set l2 [lindex $profilspc(pixels) [expr int($len/10)]]
   set l3 [lindex $profilspc(pixels) [expr int(2*$len/10)]]
   set l4 [lindex $profilspc(pixels) [expr int(3*$len/10)]]
   set dl1 [expr ($l2-$l1)/(int($len/10)-1)]
   set dl2 [expr ($l4-$l3)/(int($len/10)-1)]
   set xincr [expr 0.5*($dl2+$dl1)]
   #--- Meth2 : erreur si spectre de moins de 4 pixels
   #set l2 [lindex $profilspc(pixels) 4]
   #set l3 [lindex $profilspc(pixels) [expr 1+int($len/2)]]
   #set l4 [lindex $profilspc(pixels) [expr 4+int($len/2)]]
   #set dl1 [expr ($l2-$l1)/3]
   #set dl2 [expr ($l4-$l3)/3]
   #set xincr [expr 0.5*($dl2+$dl1)]

   ::console::affiche_resultat "Dispersion : $xincr\n"
   buf$audace(bufNo) setkwd [list "CDELT1" $xincr float "" "Angstrom/pixel"]
   #--- Type de dispersion : LINEAR, NONLINEAR --> heuristique hasardeuse
   #if { [expr abs($dl2-$dl1)] <= 0.001 } {
   #    buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]
   #} elseif { [expr abs($dl2-$dl1)] > 0.001 } {
   #    buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]
   #}

   #--- Sauve le fichier fits ainsi constitué 
   buf$audace(bufNo) bitpix float
   set filename [file root $filenamespc]
   buf$audace(bufNo) save $audace(rep_images)/${filename}$conf(extension,defaut)
   ::console::affiche_resultat "$len lignes affectées\n"
   ::console::affiche_resultat "Fichier spc exporté sous ${filename}$conf(extension,defaut)\n"
 } else {
   ::console::affiche_erreur "Usage: spc_spc2fits fichier_spc\n\n"
 }
}
#****************************************************************#


proc spc_spc2fits2 { args } {

 global conf
 global audace
 global profilspc
 global captionspc
 global colorspc
 set extsp "dat"

 if {[llength $args] == 1} {
   set filenamespc [ lindex $args 0 ]
   ## === Lecture du fichier de donnees du profil de raie ===
   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $audace(rep_images)]
   set profilspc(initialfile) [file tail $filenamespc]
   set input [open "$audace(rep_images)/$filenamespc" r]

   #--- Charge le contenu du fichier et enleve l'entête
   #-- Retourne une chaîne
   set total_contents [read $input]
   set contents [regexp {(.+)repere\r\n(.+)$} $total_contents match]
   set liste_lignes [split $contents \n]
   close $input
   #::console::affiche_resultat "ICI :\n $contents\n"
   ## === Extraction des numeros des pixels et des intensites ===
   ##set profilspc(naxis1) [expr [llength $contents]-2]
   set profilspc(naxis1) [ expr [llength $liste_lignes]-1]
   #::console::affiche_resultat "$profilspc(naxis1)\n"
   set offset 1
   #--- Une liste commence à 0
   for {set k -1} {$k < $profilspc(naxis1)} {incr k} {
      set ligne [lindex $liste_lignes $k]
      append profilspc(pixels) "[lindex $ligne 1] "
      append profilspc(intensite) "[lindex $ligne 2] "
      #incr $k
   }
   ::console::affiche_resultat "$profilspc(pixels)\n"
   #::console::affiche_resultat "ICI :\n $profilspc(intensite)\n"

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
   buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
###--- Modif Michel
   buf$audace(bufNo) setkwd [ list NAXIS 1 int "" "" ]
   buf$audace(bufNo) setkwd [ list NAXIS1 $len int "" "" ]
###--- Modif Michel
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
   set xdepart [ expr 1.0*[lindex $profilspc(pixels) 0] ]
   buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart float "" ""]
   # Valeur de la longueur d'onde/pixel central(e)
   set xdernier [lindex $profilspc(pixels) [expr $profilspc(naxis1)-1]]
   ::console::affiche_resultat "Xdep : $xdepart ; Xfin : $xdernier\n"
   #set xcentre [expr int(0.5*($xdernier-$xdepart))]
   #buf$audace(bufNo) setkwd [list "CRPIX1" "$xcentre" int "" ""]
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
   buf$audace(bufNo) setkwd [list "CDELT1" $xincr float "" ""]
   # Type de dispersion : LINEAR, NONLINEAR
   #if { [expr abs($dl2-$dl1)] <= 0.001 } {
   #    buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]
   #} elseif { [expr abs($dl2-$dl1)] > 0.001 } {
   #    buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]
   #}

   # Sauve le fichier fits ainsi constitué 
   buf$audace(bufNo) bitpix float
   buf$audace(bufNo) save ${filenamespc}_fit$conf(extension,defaut)
   ::console::affiche_resultat "$len lignes affectées\n"
   ::console::affiche_resultat "Fichier spc exporté sous $profilspc(initialfile)$conf(extension,defaut)\n"
 } else {
   ::console::affiche_erreur "Usage: spc_spc2fits fichier_spc\n\n"
 }
}
###########################################################################


###################################################################
#  Procedure de conversion d'une série defichiers profil de raies .spc (VisualSpec) en .fit
# 
# Auteur : Benjamin MAUCLAIRE
# Date creation : 09-12-2005
# Date modification : 02-04-2006
# Arguments : répertoire contenant les fichiers .spc
###################################################################
proc spc_spcs2fits { args } {

    global conf
    global audace
    set extvspec ".spc"

    if {[llength $args] == 1} {
   set repertoire [ lindex $args 0 ]
   set rep_img_dflt $audace(rep_images)
   set rep_courant [ pwd ]
   set audace(rep_images) $repertoire
   cd $repertoire
   set liste_fichiers [ lsort -dictionary [ glob *$extvspec ] ]
   foreach fichier $liste_fichiers {
       ::console::affiche_resultat "$fichier\n"
       spc_spc2fits $fichier
       ::console::affiche_resultat "\n"
   }
   set audace(rep_images) $rep_img_dflt
   cd $rep_courant
    } else {
   ::console::affiche_erreur "Usage: spc_spcs2fits chemin_du_répertoire\n\n"
    }
}
###########################################################################


###################################################################
# Procedure de conversion d'une série de fichiers profil de raies .dat en .fit
# 
# Auteur : Benjamin MAUCLAIRE
# Date creation : 02-04-2006
# Date modification : 02-04-2006
# Arguments : répertoire contenant les fichiers .dat
###################################################################
proc spc_dats2fits { args } {

    global conf
    global audace
    set extspec ".dat"

    if {[llength $args] == 1} {
   set repertoire [ lindex $args 0 ]
   set rep_img_dflt $audace(rep_images)
   set rep_courant [ pwd ]
   set audace(rep_images) $repertoire
   cd $repertoire
   set liste_fichiers [ lsort -dictionary [ glob *$extspec ] ]
   foreach fichier $liste_fichiers {
       ::console::affiche_resultat "$fichier\n"
       spc_dat2fits $fichier
       ::console::affiche_resultat "\n"
   }
   set audace(rep_images) $rep_img_dflt
   cd $rep_courant
    } else {
   ::console::affiche_erreur "Usage: spc_dats2fits chemin_du_répertoire\n\n"
    }
}
#**********************************************************************************#



###################################################################
# Lecture des fichiers contenant le nom et la longueur d'onde d'especes chimiques
# 
# Auteur : Benjamin MAUCLAIRE
# Date creation : 17-09-2006
# Date modification : 17-09-2006
# Arguments : aucun
###################################################################
proc spc_readchemfiles { args } {

    global conf
    global audace
    set extdata ".txt"
    set fileelements "spcaudace/data/chimie/stellar_lines.txt"
    set fileneon "spcaudace/data/chimie/neon.txt"
    set fileeau "spcaudace/data/chimie/h2o.txt"

    if { [ llength $args ] <= 1 } {
   if { [ llength $args ] == 1 } {
       set repertoire [ lindex $args 0 ]
   } elseif { [ llength $args ] == 0 } {
       set repertoire ""
   } else {
       ::console::affiche_erreur "Usage: spc_readchemfiles ?répertoire des catalogues chimiques?\n\n"
   }

   #--- Lecture du fichier des raies stellaires
   set input [open "$audace(rep_scripts)/$fileelements" r]
   set contents [split [read $input] \n]
   close $input
   foreach ligne $contents {
       set element [ lindex $ligne 0 ]
       set lambda [ lindex $ligne 1 ]
       append listelambdaschem "$element:$lambda "
       # lappend listelambdaschem "$ligne"
   }

   #--- Lecture du fichier des raies de l'eau
   set input [open "$audace(rep_scripts)/$fileeau" r]
   set contents [split [read $input] \n]
   close $input
   foreach ligne $contents {
       set element [ lindex $ligne 0 ]
       set lambda [ lindex $ligne 1 ]
       append listelambdaschem "$element:$lambda "
       # lappend listelambdaschem "$ligne"
   }

   #--- Lecture du fichier des raies du neon
   set input [open "$audace(rep_scripts)/$fileneon" r]
   set contents [split [read $input] \n]
   close $input
   foreach ligne $contents {
       set element [ lindex $ligne 0 ]
       set lambda [ lindex $ligne 1 ]
       append listelambdaschem "$element:$lambda "
       # lappend listelambdaschem "$ligne"
   }

   #--- Fin du script :
   set listelambdaschem [ split $listelambdaschem " " ]
   return $listelambdaschem
    } else {
   ::console::affiche_erreur "Usage: spc_readchemfiles ?répertoire des catalogues chimiques?\n\n"
    }
}
#**********************************************************************************#


















#==============================================================================#
#==============================================================================#
#"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""#
#  Ancienne implémentation des fonction 
#
#"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""#
#==============================================================================#
#==============================================================================#

####################################################################
#  Procedure de conversion de fichier profil de raie calibré .dat en .png
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-04-2006
# Date modification : 27-04-2006
# Arguments : fichier .dat du profil de raie, titre, ?xdeb, xfin?
####################################################################

proc spc_dat2png_27042006 { args } {
    global audace
    global conf
    global tcl_platform

    if { [llength $args] == 4 || [llength $args] == 2 } {
   if { [llength $args] == 2 } {
       set fichier [ lindex $args 0 ]
       set titre [ lindex $args 1 ]
       #set xdeb "*"
       #set xfin "*"
       set fichierfit [ spc_dat2fits $fichier ${fichier}_fittmp ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichierfit"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       #-- Demarre et fini le graphe en deçca de 3% des limites pour l'esthetique
       set largeur [ expr 0.03*$naxis1 ]
       set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
       set xdeb [ expr $xdeb0+$largeur ]
       set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set xfin [ expr $naxis1*$xincr+$xdeb-2*$largeur ]
   } elseif { [llength $args] == 4 } {
       set fichier [ lindex $args 0 ]
       set titre [ lindex $args 1 ]
       set xdeb [ lindex $args 2 ]
       set xfin [ lindex $args 3 ]
       set fichierfit [ spc_dat2fits $fichier ${fichier}_fittmp ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichierfit"
       set xdeb0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
   }

   #--- Adapte la légende de l'abscisse
   if { $xdeb0 == 1.0 } {
       set legendex "Position (Pixel)"
   } else {
       set legendex "Wavelength (A)"
   }
   set legendey "Intensity (ADU)"

   set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
   set ext ".dat"
   
   #spc_fits2dat $fichier
   #-- Retire l'extension .fit du nom du fichier
   set spcfile [ file rootname $fichier ]
   
   #--- Créée le fichier script pour gnuplot :
   set file_id [open "$audace(rep_images)/${spcfile}.gp" w+]
   puts $file_id "call \"${repertoire_gp}/gp_novisu.cfg\" \"$audace(rep_images)/${spcfile}$ext\" \"$titre\" * * $xdeb $xfin * \"$audace(rep_images)/${spcfile}.png\" \"$legendex\" \"$legendey\" "
   close $file_id

   #--- Détermine le chemin de l'executable Gnuplot selon le système d'exploitation :
   if { $tcl_platform(os)=="Linux" } {
       set answer [ catch { exec gnuplot $audace(rep_images)/${spcfile}.gp } ]
       ::console::affiche_resultat "$answer\n"
   } else {
       set answer [ catch { exec ${repertoire_gp}/gpwin32/pgnuplot.exe $audace(rep_images)/${spcfile}.gp } ]
       ::console::affiche_resultat "$answer\n"
   }

   ::console::affiche_resultat "Profil de raie exporté sous ${spcfile}.png\n"
    } else {
   ::console::affiche_erreur "Usage: spc_dat2png fichier_fits \"Titre\" ?xdébut xfin?\n\n"
    }
}
####################################################################



####################################################################
#  Procedure de conversion de fichier profil de raie spatial .fit en .dat
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_fits2dat0 { {filenamespc ""} } {

   global conf
   global audace
   global profilspc
   #global captionspc
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
   #set dtype [string trim [lindex [buf$audace(bufNo) getkwd "CTYPE1"] 1]]
   #if { $dtype != "LINEAR" || $dtype == "" } {
   #    ::console::affiche_resultat "Le spectre ne possède pas une disersion linéaire. Pas de conversion possible.\n"
   #    break
   #}
   set len [expr int($naxis1/$xincr)]
   ::console::affiche_resultat "$len intensités à traiter\n"

   if { $xdepart != 1 } {
       set fileetalonnespc [ file rootname $filenamespc ]
       #set filename ${fileetalonnespc}_dat$extsp
       set filename ${fileetalonnespc}$extsp
       set file_id [open "$audace(rep_images)/$filename" w+]

   ## Une liste commence à 0 ; Un vecteur fits commence à 1
   #for {set k 0} {$k<$len} {incr k} 
   #        append intensite [lindex $intensites $k]
   #::console::affiche_resultat "$intensite\n"
   # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
   # set intensite 0
   #

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
       ::console::affiche_resultat "Fichier fits exporté sous $profilspc(initialfile)$extsp\n"
   }
   
}
#****************************************************************#



###################################################################
#  Procedure de conversion de fichier profil de raies .dat en .fit
# 
# Auteur : Benjamin MAUCLAIRE
# Date creation : 31-01-2005
# Date modification : 15-02-2005/27-04-2006
# Arguments : fichier .dat du profil de raie ?fichier_sortie.fit?
###################################################################

proc spc_dat2fits_150205 { args } {

 global conf
 global audace
 global profilspc
 #global captionspc
 global colorspc
 set extsp ".dat"
 set nbunit "float"
 #set nbunit "double"
 set precision 0.05

 if { [llength $args] <= 2 } {
     if {[llength $args] == 1} {
    set filenamespc [ lindex $args 0 ]
     } elseif { [llength $args] == 2 } {
    set filenamespc [ lindex $args 0 ]
    set filenameout [ lindex $args 1 ]
     }
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
     buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
###--- Modif Michel
     buf$audace(bufNo) setkwd [ list NAXIS 1 int "" "" ]
     buf$audace(bufNo) setkwd [ list NAXIS1 $len int "" "" ]
###--- Modif Michel
     
     set intensite 0
     #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
     # Une liste commence à 0 ; Un vecteur fits commence à 1
     for {set k 0} {$k<$len} {incr k} {
    append intensite [lindex $intensites $k]
    #::console::affiche_resultat "$intensite\n"
    if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
        buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
        set intensite 0
    }
     }
     
     set profilspc(xunit) "Position"
     set profilspc(yunit) "ADU"
     #------- Affecte une valeur aux mots cle liés à la spectroscopie ----------
     #-- buf$audace(bufNo) setkwd [list "INSTRU" "T310" string "mon télescope" ""]
     #buf$audace(bufNo) setkwd [list "NAXIS1" "$len" int "" ""]
     #buf$audace(bufNo) setkwd [list "NAXIS2" "1" int "" ""]
     #--- Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
     set xdepart [ expr 0.0+1.0*[lindex $profilspc(pixels) 0] ]
     buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart $nbunit "" ""]
     #--- Valeur de la longueur d'onde/pixel central(e)
     set xdernier [lindex $profilspc(pixels) [expr $profilspc(naxis1)-1]]
     ::console::affiche_resultat "Xdep : $xdepart ; Xfin : $xdernier\n"
     #set xcentre [expr int(0.5*($xdernier-$xdepart))]
     #buf$audace(bufNo) setkwd [list "CRPIX1" "$xcentre" double "" ""]
     #--- Dispersion du spectre :
     #-- Calcul dans le cas d'une dispersion non linéaire
     set l1 [lindex $profilspc(pixels) 1]
     set l2 [lindex $profilspc(pixels) [expr int($len/10)]]
     set l3 [lindex $profilspc(pixels) [expr int(2*$len/10)]]
     set l4 [lindex $profilspc(pixels) [expr int(3*$len/10)]]
     set dl1 [expr ($l2-$l1)/(int($len/10)-1.0)]
     set dl2 [expr ($l4-$l3)/(int($len/10)-1.0)]
     set xincr [expr 0.5*($dl2+$dl1)]
     #-- Mesure de la dispersion supposée linéaire
     set l1 [lindex $profilspc(pixels) 1]
     set l2 [lindex $profilspc(pixels) 2]
     set xincr [expr 1.0*abs($l2-$l1)]
     
     #-- Meth2 : erreur si spectre de moins de 4 pixels
     #set l2 [lindex $profilspc(pixels) 4]
     #set l3 [lindex $profilspc(pixels) [expr 1+int($len/2)]]
     #set l4 [lindex $profilspc(pixels) [expr 4+int($len/2)]]
     #set dl1 [expr ($l2-$l1)/3]
     #set dl2 [expr ($l4-$l3)/3]
     #set xincr [expr 0.5*($dl2+$dl1)]
     
     ::console::affiche_resultat "Dispersion : $xincr\n"
     buf$audace(bufNo) setkwd [list "CDELT1" $xincr $nbunit "" ""]
     #--- Type de dispersion : LINEAR, NONLINEAR
     
     #--- Sauve le fichier fits ainsi constitué 
     ::console::affiche_resultat "$len lignes affectées\n"
     buf$audace(bufNo) bitpix float
     if {[llength $args] == 1} {
    set nom [ file rootname $filenamespc ]
    buf$audace(bufNo) save "$audace(rep_images)/${nom}$conf(extension,defaut)"
    ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${nom}$conf(extension,defaut)\n"
     } elseif {[llength $args] == 2} {
    set nom [ file rootname $filenameout ]
    buf$audace(bufNo) save "$audace(rep_images)/${filenameout}$conf(extension,defaut)"
    ::console::affiche_resultat "Fichier fits sauvé sous $audace(rep_images)/${filenameout}$conf(extension,defaut)\n"
     }
 } else {
     ::console::affiche_erreur "Usage: spc_dat2fits fichier_profil.dat ?fichier_sortie.fit?\n\n"
 }
}
#****************************************************************#



proc spc_fits2dat_160505 { args } {

 global conf
 global audace
 global profilspc
 #global captionspc
 global colorspc
 set extsp ".dat"

 if {[llength $args] == 1} {
   set filenamespc [ lindex $args 0 ]
   buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   #buf$audace(bufNo) load $filenamespc
   set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
   #--- Valeur minimale de l'abscisse : =0 si profil non étalonné
   set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
   #--- Dispersion du spectre : =1 si profil non étalonné
   set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
   #--- Pixel de l'abscisse centrale
   set xcenter [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
   #--- Type de spectre : LINEAR ou NONLINEAR (elinine les espaces dans la valeur du mot cle.
   set dtype [string trim [lindex [buf$audace(bufNo) getkwd "CTYPE1"] 1]]
   #::console::affiche_resultat "Ici 1\n"
   #if { $dtype != "LINEAR" || $dtype == "" } {
   #    ::console::affiche_resultat "Le spectre ne possède pas une disersion linéaire. Pas de conversion possible.\n"
   #    break
   #}
   #::console::affiche_resultat "Ici 2\n"
   set len [expr int($naxis1/$xincr)]
   ::console::affiche_resultat "$naxis1 intensités à traiter\n"

   if { $xdepart != 1 } {
       set fileetalonnespc [ file rootname $filenamespc ]
       #set filename ${fileetalonnespc}_dat$extsp
       set filename ${fileetalonnespc}$extsp
       set file_id [open "$audace(rep_images)/$filename" w+]

       #--- Une liste commence à 0 ; Un vecteur fits commence à 1
       for {set k 0} {$k<$naxis1} {incr k} {
      #-- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
      set lambda [expr $xdepart+($k)*$xincr*1.0]
      #-- Lit la valeur des elements du fichier fit
      set intensite [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
      ##lappend profilspc(intensite) $intensite
      #-- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
      puts $file_id "$lambda\t$intensite"
       }
       close $file_id
       ::console::affiche_resultat "Fichier fits exporté sous $audace(rep_images)/${fileetalonnespc}$extsp\n"
   } else {
       #--- Retire l'extension .dat du nom du fichier
       set filespacialspc [ file rootname $filenamespc ]
       #buf$audace(bufNo) imaseries "PROFILE filename=${filespacialspc}_dat$extsp direction=x offset=1"
       buf$audace(bufNo) imaseries "PROFILE filename=$audace(rep_images)/${filespacialspc}$extsp direction=x offset=1"
       ::console::affiche_resultat "Fichier fits exporté sous $audace(rep_images)/${filespacialspc}$extsp\n"
   }
 } else {
   ::console::affiche_erreur "Usage: spc_fits2dat fichier_profil.fit\n\n"
 }
}
#****************************************************************#



proc spc_data2fits_051219a { args } {
    global audace
    global conf
    set precision 0.05
    set nbunit "float"
    #set nbunit "double"

    if { [llength $args] == 2 } {
   #set nom_fichier [ file rootname [lindex 0] ]
   set nom_fichier [lindex $args 0]
   set coordonnees [lindex $args 1]
   set abscisses [lindex $coordonnees 0]
   set intensites [lindex $coordonnees 1]
   set len [llength $abscisses]

   #--- Création du fichier fits
   buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
   buf$audace(bufNo) setkwd [list "NAXIS1" $len int "" ""]
   buf$audace(bufNo) setkwd [list "NAXIS2" 1 int "" ""]
   #-- Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
   set xdepart [expr 1.0*[lindex $abscisses 0] ]
   buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart $nbunit "" "Angstrom"]
   #-- Dispersion
   #set dispersion [spc_dispersion_moy $abscisses]
   set l1 [lindex $abscisses 1]
   set l2 [lindex $abscisses [expr int($len/10)]]
   set l3 [lindex $abscisses [expr int(2*$len/10)]]
   set l4 [lindex $abscisses [expr int(3*$len/10)]]
   set dl1 [expr ($l2-$l1)/(int($len/10)-1)]
   set dl2 [expr ($l4-$l3)/(int($len/10)-1)]
   set dispersion [expr 0.5*($dl2+$dl1)]
   buf$audace(bufNo) setkwd [list "CDELT1" $dispersion $nbunit "" "Angstrom/pixel"]

   #--- Type de dispersion : LINEAR, NONLINEAR
   #if { [expr abs($dl2-$dl1)] <= $precision } {
   #    buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]
   #} elseif { [expr abs($dl2-$dl1)] > $precision } {
   #    buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]
   #}

   #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
   # Une liste commence à 0 ; Un vecteur fits commence à 1
   set intensite 0
   for {set k 0} {$k<$len} {incr k} {
       append intensite [lindex $intensites $k]
       #::console::affiche_resultat "$intensite\n"
       if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
      buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
      set intensite 0
       }
   }

   #--- Sauvegarde du fichier fits ainsi créé
   buf$audace(bufNo) bitpix float
   buf$audace(bufNo) save "$audace(rep_images)/$nom_fichier"
   return $nom_fichier
    } else {
       ::console::affiche_erreur "Usage: spc_data2fits nom_fichier_fits_sortie liste_coordonnées_x_et_y\n\n"
    }
}
#**********************************************************************#


proc spc_data2fits_051215a { args } {
    global audace
    global conf
    set precision 0.05
    set nbunit "float"
    #set nbunit "double"

    if { [llength $args] == 2 } {
   #set nom_fichier [ file rootname [lindex 0] ]
   set nom_fichier [lindex $args 0]
   set coordonnees [lindex $args 1]
   set abscisses [lindex $coordonnees 0]
   set intensites [lindex $coordonnees 1]
   set len [llength $abscisses]

   #--- Création du fichier fits
   buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
   buf$audace(bufNo) setkwd [list "NAXIS1" $len int "" ""]
   buf$audace(bufNo) setkwd [list "NAXIS2" 1 int "" ""]
   #-- Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
   set xdepart [ expr 1.0*[lindex $abscisses 0]]
   buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart $nbunit "" "Angstrom"]
   #-- Dispersion
   #set dispersion [spc_dispersion_moy $abscisses]
   set l1 [lindex $abscisses 1]
   set l2 [lindex $abscisses [expr int($len/10)]]
   set l3 [lindex $abscisses [expr int(2*$len/10)]]
   set l4 [lindex $abscisses [expr int(3*$len/10)]]
   set dl1 [expr ($l2-$l1)/(int($len/10)-1)]
   set dl2 [expr ($l4-$l3)/(int($len/10)-1)]
   set dispersion [expr 0.5*($dl2+$dl1)]
   buf$audace(bufNo) setkwd [list "CDELT1" $dispersion $nbunit "" "Angstrom/pixel"]

   #--- Type de dispersion : LINEAR, NONLINEAR
   #if { [expr abs($dl2-$dl1)] <= $precision } {
   #    buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]
   #} elseif { [expr abs($dl2-$dl1)] > $precision } {
   #    buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]
   #}

   #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
   # Une liste commence à 0 ; Un vecteur fits commence à 1
   set intensite 0
   for {set k 0} {$k<$len} {incr k} {
       append intensite [lindex $intensites $k]
       #::console::affiche_resultat "$intensite\n"
       if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {
      buf$audace(bufNo) setpix [list [expr $k+1] 1] $mintensite
      set intensite 0
       }
   }

   #--- Sauvegarde du fichier fits ainsi créé
   buf$audace(bufNo) bitpix float
   buf$audace(bufNo) save $audace(rep_images)/$nom_fichier
   return $nom_fichier
    } else {
       ::console::affiche_erreur "Usage: spc_data2fits nom_fichier_fits_sortie liste_coordonnées_x_et_y\n\n"
    }
}
#****************************************************************#
