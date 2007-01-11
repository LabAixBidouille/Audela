####################################################################
# Specification des varibles utilisees par spcaudace
# et chargement des librairies
####################################################################


#----------------------------------------------------------------------------------#
global audace
global conf

#----------------------------------------------------------------------------------#
## ***** Chargement de la lib BLT *****
## Il a ete necessaire que je fasse un lien symbolique : ln -s /usr/lib/libBLT.2.4.so.8.3 /usr/lib/libBLT.2.4.so
#::console::affiche_resultat "$tcl_platform(os)\n"
if {[string compare $tcl_platform(os) "Linux"] == 0 } {
   ##load libBLT.2.4[info sharedlibextension]
   package require BLT
   load libBLT.2.4[info sharedlibextension].$tcl_version

   #package require BLT
   #load $audace(rep_install)/lib/blt2.4/BLT24[info sharedlibextension]

} else {
   ## la lib BLT24.dll reste dans "lib" pas besoin qu'elle soit dans "system32"
   package require BLT
   load BLT24
}


#----------------------------------------------------------------------------------#
set extsp "dat"
set extdflt "fit"




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



#----------------------------------------------------------------------------------#

