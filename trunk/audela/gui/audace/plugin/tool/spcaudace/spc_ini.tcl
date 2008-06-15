

# Mise a jour $Id: spc_ini.tcl,v 1.2 2008-06-15 09:49:27 robertdelmas Exp $


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

   global audace spcaudace
   global conf
   global audela

   if { [regexp {1.3.0} $audela(version) match resu ] } {
      source [ file join $audace(rep_scripts) spcaudace plugins bess_module bess_module.tcl ]
   } else {
      set repspc [ file join $audace(rep_plugin) tool spcaudace ]
      source [ file join $spcaudace(repspc) plugins bess_module bess_module.tcl ]
      ::bess::Principal ""
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

