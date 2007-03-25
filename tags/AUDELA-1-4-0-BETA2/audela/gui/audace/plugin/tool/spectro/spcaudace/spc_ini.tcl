


#----------------------------------------------------------------------------------#
## ***** Chargement de la lib BLT *****
package require BLT


#--- Version d'SpcAudace :
proc spc_version {} {

    global spcaudace conf
    global caption

    ::console::affiche_resultat "SpcAudACE version $spcaudace(version)\n"
    tk_messageBox -title "Version d'SpcAudACE" -icon error -message "SpcAudACE version $spcaudace(version)"
}


#----------------------------------------------------------------------------------#
proc spc_goodrep {} {
   global audace

   set repdflt [pwd]
   cd $audace(rep_images)
   return $repdflt
}


#----------------------------------------------------------------------------------#
#**** Fonctions de chargement des des plugins *********
proc spc_bessmodule {} {

    global audace
    global conf
    global audela

    if { [regexp {1.3.0} $audela(version) match resu ] } {
	source [ file join $audace(rep_scripts) spcaudace plugins bess_module bess_module.tcl ]
    } else {
	set repspc [ file join $audace(rep_plugin) tool spectro spcaudace ]
	source [ file join $repspc plugins bess_module bess_module.tcl ]
    }
}



#--- Amorcage d'initialisation de vecteurs pour la fonction BLT::spline qui bug :
proc spc_vectorini {} {
   blt::vector x(10) y(10) sy(10)
   for {set i 10} {$i>0} {incr i -1} { 
      set x($i-1) [expr $i*$i]
      set y($i-1) [expr sin($i*$i*$i)]
   }
   x sort y
   x populate sx 10
   blt::spline natural x y sx sy
}

spc_vectorini
#*********************************************************#


#--- Lancement du navigateur internet pour consulter la documentation d'SpcAudace
proc spc_help {} {

    global spcaudace conf

    if { $conf(editsite_htm)!="" } {
	if { [ file exists $spcaudace(spcdoc) ] } {
	    set answer [ catch { exec $conf(editsite_htm) $spcaudace(spcdoc) & } ]
	} else {
	    set answer [ catch { exec $conf(editsite_htm) $spcaudace(sitedoc) & } ]
	}
    } else {
	::console::affiche_resultat "Configurer \"Editeurs/Navigateur web\" pour permettre l'affichage de la documentation d'SpcAudACE\n"
    }
}
#*********************************************************#