#
# Fichier : hermione.tcl
# Description : Script a placer dans le repertoire scripts, optimise pour une Audine Kaf-0400
# Date de mise a jour : 05 mai 2005
#

global audace

#--- Petits raccourcis
set camera cam$audace(camNo)
set visu visu$audace(visuNo)
set buffer buf$audace(bufNo)

#--- Inverser le "yes" et le "no" au moment de l'observation reelle de l'occultation
#--- Simulation du script
set simulation "yes"
#--- Observation reelle de l'occultation sur le ciel
### set simulation "no"

set astername  "hermione"
set debut      "2004-02-16T22:28:00"

#--- firstpix : Valeur du pixel de gauche de la fenetre du scan sur l'image
#--- A adapter en temps reel juste avant de lancer le script
set firstpix "300"

if { $simulation == "yes" } {
   set h "520"
} else {
   set h "6000"
}

#--- Fenetre de 250 pixels de large
set w   "250"
set bin "1"

#--- Parametres definis apres les calibrations avec l'outil Scan rapide
set dt    "100.0" ; # millisecondes
set speed "6200"  ; # boucles

#--- Ne rien toucher a ce qui suit
if { $simulation == "yes" } {
   set datejd [ mc_date2jd [ ::audace::date_sys2ut now ] ]
} else {
   set datejd [ mc_date2jd $debut ]
}

while { [ mc_date2jd [ ::audace::date_sys2ut now ] ] < $datejd } {
   after 1000
   ::console::affiche_resultat "Attente [ mc_date2ymdhms [ ::audace::date_sys2ut now ] ] \n"
}
set name [ mc_date2ymdhms [ ::audace::date_sys2ut ] ]
set name [ format "%04d%02d%02d%02d%02d" [lindex $name 0] [lindex $name 1] [lindex $name 2] [lindex $name 3] [lindex $name 4] ]
::console::affiche_resultat "\n"
::console::affiche_resultat "Scan en cours...\n"
::console::affiche_resultat "\n"

#--- Acquisition et gestion de l'obturateur
catch { $camera shutter opened }
$camera scan $w $h $bin $dt -firstpix $firstpix -fast $speed -tmpfile
$buffer save "i0_$name"
bell
catch { $camera shutter synchro }

#--- Visualisation de l'image
::audace::autovisu $visu

#--- Enregistrement du fichier FITS
$buffer save "${astername}_$name"
::console::affiche_resultat "\n"
::console::affiche_resultat "Scan termin�.\n"
::console::affiche_resultat "\n"

#--- Fin du fichier script

