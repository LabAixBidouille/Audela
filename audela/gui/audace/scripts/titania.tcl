#
# Occultation de HD205829 par Titania (satellite d'Uranus)
# Le 08 Septembre 2001 a 2h TU environ
# Auteur : Alain KLOTZ
#

global audace

set debut now
# Attention heure en TU --> Ordinateur cale sur l'heure TU
set debut 2001-09-08T01:49:30
# Largeur du scan (en pixels)
set w 190
# Longueur du scan (en pixels)
set h 4500
# Binning 1x1
set bin 1
# Temps d'integration interligne (en ms) apres calibration
set dt 200.
# Indice du premier photosite de la largeur de l'image 
set firstpix 270 ; # valeur à adapter en temps réel
# Nombre de boucles
set speed 20429

set datejd [mc_date2jd $debut]
while {[mc_date2jd now]<$datejd} {
   after 1000
   ::console::affiche_resultat "attente [mc_date2ymdhms now]\n"
}
set name [mc_date2ymdhms now]
set name [format "%04d%02d%02d%02d%02d" [lindex $name 0] [lindex $name 1] [lindex $name 2] [lindex $name 3] [lindex $name 4]]

::console::affiche_resultat "Scan en cours\n"
#--- Acquisition et gestion de l'obturateur
catch {cam$audace(camNo) shutter opened}
cam$audace(camNo) scan $w $h $bin $dt -firstpix $firstpix -fast $speed -tmpfile 
bell
catch {cam$audace(camNo) shutter synchro}
#--- Visualisation de l'image
visu 
# --- Enregistrement du fichier FITS
buf$audace(bufNo) save "titania_$name"
buf$audace(bufNo) save "i0_$name"
::console::affiche_resultat "scan fini\n"

