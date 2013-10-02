# Mise a jour $Id$


###########################################################################
# Procedure pour changer un mot cle dans un header fits
# entrees : nom du fichier fits a changer, nom du mot cle, nouvelle valeur
# sortie : valeur donnee au nouveau mot cle
# NB : le nouveau fichier fits ecrase l'ancien...
# exemple pl_changekeywd fichier CRVAL1 6500.
###########################################################################

proc spc_selectstronglines { args } {
   global audace conf spcaudace
   set coeff_min 0.1

   #-- listeraie = { {x I} ... }
   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set listeraies [ lindex $args 0 ]
      set coeff_min 0.1
   } elseif { $nbargs==2 } {
      set listeraies [ lindex $args 0 ]
      set coeff_min [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_selectstronglines liste_couples_x_I ?pourcent_iraie_continuum(0.1)?\n"
      return ""
   }

   set listeraies [ lsort -increasing -real -index 0 $listeraies ]
   set imax_cal [ expr $coeff_min*[ lindex [ lindex $listeraies 0 ] 1 ] ]
   set listeraies_out [ list ]
   foreach raie $listeraies {
      if { [ lindex $raie 1 ]>=$imax_cal } {
         lappend listeraies_out $raie
      } else {
         continue
      }
   }
   return $listeraies_out
}
#************************************************************************#


###########################################################################
# Procedure pour changer un mot cle dans un header fits
# entrees : nom du fichier fits a changer, nom du mot cle, nouvelle valeur
# sortie : valeur donnee au nouveau mot cle
# NB : le nouveau fichier fits ecrase l'ancien...
# exemple pl_changekeywd fichier CRVAL1 6500.
###########################################################################

proc pl_changekeywd { args } {
  global audace conf spcaudace

  if { [ llength $args ] == 3 } {
     set nomfich [ lindex $args 0 ]
     set keyword [ lindex $args 1 ]
     set valeur [ lindex $args 2 ]
     buf$audace(bufNo) load $nomfich
     set listemotsclef [ buf$audace(bufNo) getkwds ]
     if { [ lsearch $listemotsclef $keyword ] !=-1 } {
        set motcle [ buf$audace(bufNo) getkwd $keyword ]
        set motcle [ lreplace $motcle 1 1 $valeur ]
        buf$audace(bufNo) delkwd $keyword
        buf$audace(bufNo) setkwd $motcle
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save $nomfich
        return [ lindex [ buf$audace(bufNo) getkwd $keyword ] 1 ]
     } else {
      	::console::affiche_erreur "pl_changekeywd : le mot cle $keyword n'est pas present dans le fichier $nomfich et celui ci reste inchange\n\n"
      	return 0
     }
  } else {
     ::console::affiche_erreur "Usage: pl_changekeywd : nom_fich nom_keywd valeur\n\n"
     return 0
  }
}
#************************************************************************#
