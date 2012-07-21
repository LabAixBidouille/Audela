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
   package require BLT
   #load libBLT.2.4[info sharedlibextension]
} else {
   ## la lib BLT24.dll reste dans "lib" pas besoin qu'elle soit dans "system32"
   package require BLT
}


#----------------------------------------------------------------------------------#
set extsp "dat"
set extdflt "fit"


#----------------------------------------------------------------------------------#
