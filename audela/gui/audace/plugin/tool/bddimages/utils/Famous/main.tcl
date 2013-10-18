### source [ file join $audace(rep_plugin) tool bddimages utils Famous main.tcl]
gren_info "lecture du fichier\n"
set racine [ file join $audace(rep_plugin) tool bddimages utils Famous]

source  [ file join $racine funcs.formule.tcl]
source  [ file join $racine funcs.affiche.tcl]


set file_solu  [ file join $racine sol.dat]
set f [open $file_solu "r"]
set solu ""
while {![eof $f]} {
   append solu [gets $f]
}
close $f
gren_info "solu = $solu\n"

set solu [create_formule $solu]
affiche_solu $solu
