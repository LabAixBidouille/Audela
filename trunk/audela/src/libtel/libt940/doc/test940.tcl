::tel::create t940 -mode 0

tel::create t940 PCI -mode 1
after 1000

tel1 appcoord
tel1 hadec coord

tel1 extradrift radec 
set m 7 ; ::console::affiche_resultat "[tel1 get_register_s 0 M $m] [tel1 get_register_s 1 M $m] [tel1 get_register_s 2 M $m]\n"

#set m 11 ; ::console::affiche_resultat "[tel1 get_register_s 0 M $m] [tel1 get_register_s 1 M $m] [tel1 get_register_s 2 M $m]\n"
#set m 15 ; ::console::affiche_resultat "[tel1 get_register_s 0 M $m] [tel1 get_register_s 1 M $m] [tel1 get_register_s 2 M $m]\n"

set k 210 ; ::console::affiche_resultat "[tel1 get_register_s 0 K $k] [tel1 get_register_s 1 K $k] [tel1 get_register_s 2 K $k]\n"
set k 211 ; ::console::affiche_resultat "[tel1 get_register_s 0 K $k] [tel1 get_register_s 1 K $k] [tel1 get_register_s 2 K $k]\n"
set k 212 ; ::console::affiche_resultat "[tel1 get_register_s 0 K $k] [tel1 get_register_s 1 K $k] [tel1 get_register_s 2 K $k]\n"

#set m 6 ; ::console::affiche_resultat "[tel1 get_register_s 0 M $m] [tel1 get_register_s 1 M $m] [tel1 get_register_s 2 M $m]\n"
#set m 10 ; ::console::affiche_resultat "[tel1 get_register_s 0 M $m] [tel1 get_register_s 1 M $m] [tel1 get_register_s 2 M $m]\n"
#set m 14 ; ::console::affiche_resultat "[tel1 get_register_s 0 M $m] [tel1 get_register_s 1 M $m] [tel1 get_register_s 2 M $m]\n"

set x 13 ; ::console::affiche_resultat "[tel1 get_register_s 0 X $m] [tel1 get_register_s 1 X $x] [tel1 get_register_s 2 X $x]\n"

set via 1000
tel1 set_register_s 0 X 13 0 [expr abs($via)]
if {$via<0} {
   tel1 execute_command_x_s 0 26 1 0 0 71
} else {
   tel1 execute_command_x_s 0 26 1 0 0 72
}



set radec [tel1 radec coord]
::console::affiche_resultat "radec=$radec\n"
set ra  [lindex $radec 0]
set dec [lindex $radec 1]
set ra2 [expr [mc_angle2deg $ra]-0]
set dec2 [expr [mc_angle2deg $dec 90]-1.0]
set radec2 [list $ra2 $dec2]
::console::affiche_resultat "radec2=$radec2\n"
tel1 radec goto $radec2

set radec [tel1 radec coord]
::console::affiche_resultat "radec=$radec\n"
set ra  [lindex $radec 0]
set dec [lindex $radec 1]
set ra2 [expr [mc_angle2deg $ra]-10]
set dec2 [expr [mc_angle2deg $dec 90]+1.0]
set radec2 [list $ra2 $dec2]
::console::affiche_resultat "radec2=$radec2\n"
tel1 radec goto $radec2

set sens s
tel1 action move_${sens}
after 4000
tel1 action move_${sens}_stop


tel1 radec motor on
tel1 appcoord

tel1 radec goto {330 10}

tel1 get_register_s 1 M 7


set radec [list [mc_date2lst now $audace(posobs,observateur,gps) -format deg] [lindex $audace(posobs,observateur,gps) 3]]
set radec [mc_precessradec $radec J2000 now]
google_earth_radec_goto [lindex $radec 0] [lindex $radec 1]

1048575655

tel1 execute_command_x_s 0 26 1 0 0 79

tel::create t940 pci
tel1 execute_command_x_s 1 26 1 0 0 79
tel::create t940 pci
::console::affiche_resultat "[tel1 get_register_s 0 M 7] [tel1 get_register_s 1 M 7] [tel1 get_register_s 2 M 7]\n"

tel1 execute_command_x_s 1 26 1 0 0 79
tel1 execute_command_x_s 1 26 1 0 0 79
after 500
tel1 get_register_s 1 M 7
after 500
tel1 get_register_s 1 M 7

tel1 set_register_s 0 X 13 0 900
tel1 execute_command_x_s 0 26 1 0 0 71


tel::create t940 pci
after 1000
tel1 radec motor on
for {set k 0} {$k<3} {incr k} {
::console::affiche_resultat "[tel1 get_register_s 0 M 7] [tel1 get_register_s 1 M 7] [tel1 get_register_s 2 M 7]\n"
after 1000
}
::console::affiche_resultat "[tel1 get_register_s 0 M 7] [tel1 get_register_s 1 M 7] [tel1 get_register_s 2 M 7]\n"

set sens s
tel1 action move_${sens}
after 4000
tel1 action move_${sens}_stop
