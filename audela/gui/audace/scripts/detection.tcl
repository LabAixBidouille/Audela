#
# D�tection
#
# Date de mise a jour : 09 octobre 2004
#
# Pour contacter l'auteur : vincentcotrez@yahoo.fr
#
# Encha�ne une s�rie d'acquisition sur les champs d�finis dans le fichier obj_detection.txt
# Les images sont enregistr�es dans le r�pertoire images
# Le fichier obj_detection.txt doit se trouver dans le r�pertoire scripts/detection

# Il contient les lignes :

# binning		      1			indiquez 1,2,... pour d�finir le binning d'acquisition des images
# waitbeforeexposure	10			indiquez le temps d'attente en secondes avant chaque acquisition
# timeexposure		30			indiquez le temps d'exposition des images en secondes
# numberexposure	      2			indiquez le nombre d'acquisition � r�aliser sur chaque champ point�
# iteration		      2			indiquez le nombre de s�ries de pointage des champs, si vous indiquez 2 par exemple, le t�lescope pointera les champs A,B,C puis de nouveau A,B,C une seconde fois
# waitbeforeserie       10			indiquez le temps d'attente en secondes entre chaque s�rie
# headingname		detect031010	indiquez l'ent�te des noms des fichiers images, si vous indiquez "detect031010" par exemple, le premier fichier image portera le nom detect031010_1231_N0530_1_1.xxx : detect031010 est l'ent�te, 1231 est la coordonn�es en alpha (12h31m) N0530 est la coordonn�es en delta (+05�30') _1 est le num�ro de la s�rie, _1 et le num�ro de la pose dans la s�rie

# Les lignes suivantes renseignent les coordonn�es des champs � pointer, par exemple : 12 31 +05 30 pour 12h31' 05�30' Nord (indiquez + pour Nord et - pour Sud)
# Une ligne de coordonn�es pr�c�d�e d'un caract�re '*' sera point�e mais aucune acquisition ne sera r�alis�e sur ce champ (exemple : * 21 41 +05 10)
# Une ligne de coordonn�es peut comporter des champs suppl�mentaires : binning, time exposure, number exposures et heading name. Dans ce cas, pour ce champ, ceux sont ces param�tres qui sont pris en compte � la place des param�tres par d�faut d�crits ci-dessus (exemple : 01 49 +67 39 1 10 2 SAO12000, pointe champ 01h49 +67�39 binning=1 timeexposure=10 numberexposure=2 headingname=SAO12000)

# Consultez le fichier 'obj_detection.txt' pour un exemple de programmation

################################################################################

# Ici commence le script

global audace
source [file join $audace(rep_scripts) detection detection.cap]

# Lignes ent�te
set numligne_binning 1
set numligne_waitbeforeexposure 2
set numligne_timeexposure 3
set numligne_numberexposure 4
set numligne_iteration 5
set numligne_waitbeforeserie 6
set numligne_headingname 7

# Premi�re ligne contenant des coordonn�es
set numligne_coord1 8

set entete_ligne_console "# "

#--------------------------------------------------------------------------#
#  Message                                                                 #
#--------------------------------------------------------------------------#
#  Permet l'affichage de messages format�s dans la console                 #
#                                                                          #
#  Param�tres d'entr�e :                                                   #
#  - niveau :                                                              #
#     console : affichage dans la console                                  #
#     test : mode debug                                                    #
#                                                                          #
# Param�tres de sortie : Aucun                                             #
#                                                                          #
# Algorithme :                                                             #
#  si niveau console, affichage, puis attente que toutes les t�ches soient #
#   �x�cut�es                                                              #
#--------------------------------------------------------------------------#
proc Message {niveau args} {
		switch -exact -- $niveau {
		console {
			::console::disp [eval [concat {format} $args]]
			update idletasks
		}
	}
}
#---Fin de Message---------------------------------------------------------#


Message console "${entete_ligne_console}$caption(detection,start_detection)\n"

# On lit le fichier obj_detection.txt

set input [open ".\\scripts\\detection\\obj_detection.txt" r] 
set contents [split [read $input] \n] 
close $input

# lecture des param�tres d'acquisition (les premi�res lignes du fichier)

set numligne 0
foreach obj $contents { 
 set numligne [expr $numligne+1]

 # binning
 if {$numligne==$numligne_binning} {
  set binningdef [lindex $obj 1]
  Message console "${entete_ligne_console}$caption(detection,binning) : ${binningdef}x${binningdef}\n"
 }

 # waitbeforeexposure
 if {$numligne==$numligne_waitbeforeexposure} {
  set waitbeforeexposuredef [lindex $obj 1]
  Message console "${entete_ligne_console}$caption(detection,wait_before_exposure) : ${waitbeforeexposuredef} $caption(detection,seconds)\n"
 }

 # timeexposure
 if {$numligne==$numligne_timeexposure} {
  set timeexposuredef [lindex $obj 1]
  Message console "${entete_ligne_console}$caption(detection,time_exposure) : ${timeexposuredef} $caption(detection,seconds)\n"
 }

 # numberexposure
 if {$numligne==$numligne_numberexposure} {
  set numberexposuredef [lindex $obj 1]
  Message console "${entete_ligne_console}$caption(detection,number_exposures) : ${numberexposuredef}\n"
 }

 # iteration
 if {$numligne==$numligne_iteration} {
  set iterationdef [lindex $obj 1]
  Message console "${entete_ligne_console}$caption(detection,iteration) : ${iterationdef}\n"
 }

 # waitbeforeserie
 if {$numligne==$numligne_waitbeforeserie} {
  set waitbeforeseriedef [lindex $obj 1]
  Message console "${entete_ligne_console}$caption(detection,wait_before_serie) : ${waitbeforeseriedef} $caption(detection,seconds)\n"
 }

 # headingname
 if {$numligne==$numligne_headingname} {
  set headingnamedef [lindex $obj 1]
  Message console "${entete_ligne_console}$caption(detection,heading_name) : '${headingnamedef}'\n"
 }

 if {$numligne>=$numligne_coord1} {
  # On ne fait rien ici
 }
}

# Pointage et acquisition

for {set i 1} {$i<=$iterationdef} {incr i} {
 #waitbeforeserie (pas de wait before serie avant la premi�re s�rie)
 if {$i>1 & $waitbeforeseriedef!=0} {
  Message console "${entete_ligne_console}$caption(detection,wait_before_serie) ${waitbeforeseriedef} $caption(detection,seconds)...\n"
  after [expr $waitbeforeseriedef*1000]
 }

 Message console "${entete_ligne_console}------------------------------ $caption(detection,serie) : ${i}\n"
 set numligne 0
 foreach obj $contents { 
  set numligne [expr $numligne+1]

  if {$numligne>=$numligne_coord1} {
   if {[lindex $obj 0]!="*"} {
    set rah [lindex $obj 0] 
    set ram [lindex $obj 1] 
    set decd [lindex $obj 2] 
    set decm [lindex $obj 3] 
    # Les champs suivants ne sont peut �tre pas renseign�s (prise en compte des param�tres de l'ent�te)
    set binningspec [lindex $obj 4]
    set timeexposurespec [lindex $obj 5]
    set numberexposurespec [lindex $obj 6]
    set headingnamespec [lindex $obj 7]
   } else {
    # ligne pr�c�d�e d'un caract�re "*"
    set rah [lindex $obj 1] 
    set ram [lindex $obj 2] 
    set decd [lindex $obj 3] 
    set decm [lindex $obj 4] 
    # Les champs suivants ne sont peut �tre pas renseign�s (prise en compte des param�tres de l'ent�te)
    set binningspec [lindex $obj 5]
    set timeexposurespec [lindex $obj 6]
    set numberexposurespec [lindex $obj 7]
    set headingnamespec [lindex $obj 8]
   }

   set ra "${rah}h${ram}m" 
   set dec "${decd}d${decm}m" 

   if {($binningspec!="") & ($timeexposurespec!="") & ($numberexposurespec!="") & ($headingnamespec!="")} {
    # On prend les param�tres sp�cifiques � la ligne
    set binning $binningspec;
    set timeexposure $timeexposurespec;
    set numberexposure $numberexposurespec;
    set headingname $headingnamespec;
   } else {
    # On prend les param�tres de la ligne
    set binning $binningdef;
    set timeexposure $timeexposuredef;
    set numberexposure $numberexposuredef;
    set headingname $headingnamedef;
   }

   # Pour ne pas tenir compte des lignes vides
   if {$rah!=""} {
    Message console "${entete_ligne_console}$caption(detection,goto_position) : ${ra} ${dec} ($caption(detection,serie) ${i})\n"
    tel$audace(telNo) radec goto [list $ra $dec]

    # La ligne n'est pas pr�c�d�e d'un caract�re "*", on lance les acquisitions
    if {[lindex $obj 0]!="*"} {
     for {set j 1} {$j<=$numberexposure} {incr j} {
      if {$waitbeforeexposuredef!=0} {
       Message console "${entete_ligne_console}$caption(detection,wait_before_exposure) ${waitbeforeexposuredef} $caption(detection,seconds)...\n"
       after [expr $waitbeforeexposuredef*1000]
      }
      Message console "${entete_ligne_console}$caption(detection,acq_position) : ${ra} ${dec} ($caption(detection,serie) ${i}) ($caption(detection,number) ${j})\n"
      acq $timeexposure $binning

      if {[string index $decd 0]=="+"} {set hemisphere "N"} else {set hemisphere "S"}
      set dizaine_decd [string index $decd 1]
      set unite_decd [string index $decd 2]
      set nomfichier "${headingname}_${rah}${ram}_${hemisphere}${dizaine_decd}${unite_decd}${decm}_${i}_${j}"
      Message console "${entete_ligne_console}$caption(detection,save_image_file) : ${nomfichier}\n"
      saveima $nomfichier
     }
    }
   }
  }
 }
}

# That's all !
Message console "${entete_ligne_console}$caption(detection,detection_complete)\n"