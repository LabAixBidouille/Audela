#
# Fichier : correctionfc.tcl
# Description : Fonction pour nettoyer mes images (portions de lignes verticales mauvaises)
# Auteur : Francois COCHARD
# Mise a jour $Id: correctionfc.tcl,v 1.2 2006-06-21 18:50:27 robertdelmas Exp $
#
# Attention : Je n'ai fait la modif que pour le binning 2
#

#--------------------------------------------------
proc corrigefc {} {
# Cette procedure est utilisée par le panneau de pretraitement

# Je dois regarder quelle est la taille de l'image. Je ne traite que les cas Bin 1 et 2.
set taille_X [lindex [buf1 getkwd NAXIS1] 1]
set taille_Y [lindex [buf1 getkwd NAXIS2] 1]
set bin 0
if {$taille_X == 384 && $taille_Y == 256} {
   set bin 2
# tk_messageBox -title "Go" -type ok -message "Ok: Bin 2 !!"
   }
if {$taille_X == 768 && $taille_Y == 512} {
   set bin 1
# tk_messageBox -title "Go" -type ok -message "Ok: Bin 1 !!"
   }
if {$bin == 0} {
   Message "Correction cosmétique impossible: format inconnu\n"
   return
   }

# Il y a trois défauts à corriger:
# Valable uniquement si les images sont faites avec Audela, et conformes au fond du ciel
# (= Miroir X selon config du 25 aout 2001)
# La colonne de gauche (bin 1: X=97, y=231 à 512 - bin2: X=50, y=116 à 256)
# La colonne du milieu (bin 1: X=310, y=453 à 512 - bin2: X=156, y=227 à 256)
# La colonne de droite (bin 1: X=480, y=387 à 512 - bin2: X=241, y=193 à 256)
if {$bin == 1} {
   # Correction colonne gauche
   for {set y 231} {$y <= 512} {incr y} {
      set pixel_droit [buf1 getpix [list 96 $y]]
      set pixel_gauche [buf1 getpix [list 98 $y]]
      buf1 setpix [list 97 $y] [expr ($pixel_droit + $pixel_gauche) / 2]
      }
   # Correction colonne milieu
   for {set y 453} {$y <= 512} {incr y} {
      set pixel_droit [buf1 getpix [list 311 $y]]
      set pixel_gauche [buf1 getpix [list 309 $y]]
      buf1 setpix [list 310 $y] [expr ($pixel_droit + $pixel_gauche) / 2]
      }
   # Correction colonne droite
   for {set y 387} {$y <= 512} {incr y} {
      set pixel_droit [buf1 getpix [list 481 $y]]
      set pixel_gauche [buf1 getpix [list 479 $y]]
      buf1 setpix [list 480 $y] [expr ($pixel_droit + $pixel_gauche) / 2]
      }
   }

if {$bin == 2} {
   # Correction colonne gauche
   for {set y 116} {$y <= 256} {incr y} {
      set pixel_droit [buf1 getpix [list 50 $y]]
      set pixel_gauche [buf1 getpix [list 48 $y]]
      buf1 setpix [list 49 $y] [expr ($pixel_droit + $pixel_gauche) / 2]
      }
   # Correction colonne milieu
   for {set y 226} {$y <= 256} {incr y} {
      set pixel_droit [buf1 getpix [list 156 $y]]
      set pixel_gauche [buf1 getpix [list 154 $y]]
      buf1 setpix [list 155 $y] [expr ($pixel_droit + $pixel_gauche) / 2]
      }
   # Correction colonne droite
   for {set y 193} {$y <= 256} {incr y} {
      set pixel_droit [buf1 getpix [list 241 $y]]
      set pixel_gauche [buf1 getpix [list 239 $y]]
      buf1 setpix [list 240 $y] [expr ($pixel_droit + $pixel_gauche) / 2]
      }
   }
visu1 disp [lrange [buf1 stat] 0 1]
}
#--------------------------------------------------

