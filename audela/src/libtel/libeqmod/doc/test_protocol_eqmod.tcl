# source C:/srv/develop/audela/src/libtel/libeqmod/doc/test_protocol_eqmod.tcl

package require math::statistics

proc encode { valdec } {
	set valhex [tel1 encode $valdec]
	::console::affiche_resultat "${valdec} -> ${valhex}\n"
	return $valhex
}

proc execute { command {comment ""} } {
	set car [string index $command 0]
	if {$car==":"} {
		set valhex [tel1 putread "${command}"]
		if {($command==":a1")||($command==":a2")} {
			set signe +
		} else {
			set signe -
		}
		set err [catch {tel1 decode $valhex $signe} valdec]
		if {$err==1} {
			set valdec $valhex
		}
		::console::affiche_resultat "${command}=${valhex}=${valdec} $comment\n"
	} else {
		set valdec [eval $command]
		::console::affiche_resultat "${command}=${valdec} $comment\n"
	}
	return $valdec
}

::console::affiche_resultat "============================ initialisations ===\n"
set a1 [execute ":a1"]
set b1 [execute ":b1"]
set e1 [execute ":e1"]
set position_conversion [expr 1.0 * $a1 / 360.] ; # ADU/deg
::console::affiche_resultat "position_conversion=$position_conversion ADU/deg\n"

tel::create eqmod com8 -west -point south -gps $conf(posobs,observateur,gps)
after 100
tel1 hadec coords
tel1 speedtrack 0 0
proc modpoi_cat2tel { radec } { return $radec }
proc modpoi_tel2cat { radec } { return $radec }
tel1 model modpoi_cat2tel modpoi_tel2cat
set radec [tel1 radec coord]
tel1 radec init $radec



tel::create eqmod com8 -west -point north_pole -gps $conf(posobs,observateur,gps)
after 100
set res [tel1 readparams]
foreach re $res {
	console::affiche_resultat "$re\n"
}
set ra [lindex [tel1 radec coord] 0]

tel1 speedtrack 0 0
proc modpoi_cat2tel { radec } { return $radec }
proc modpoi_tel2cat { radec } { return $radec }
tel1 model modpoi_cat2tel modpoi_tel2cat
set radec [tel1 radec coord]
console::affiche_resultat "$radec\n"
tel1 radec init $radec -mountside E


tel1 speedtrack 0 0
proc modpoi_cat2tel { radec } { return $radec }
proc modpoi_tel2cat { radec } { return $radec }
tel1 model modpoi_cat2tel modpoi_tel2cat
tel1 hadec goto {0h 0d} -blocking 1
console::affiche_resultat "j1=[tel1 decode [tel1 putread :j1]]\n"
console::affiche_resultat "j2=[tel1 decode [tel1 putread :j2]]\n"
set ra [mc_angle2deg [lindex [tel1 radec coord] 0]]
console::affiche_resultat "ra=$ra\n"
set ra [expr $ra+0]
console::affiche_resultat "ra=$ra [mc_angle2hms $ra]\n"
tel1 radec goto [list $ra 0d] -blocking 1
after 5000
console::affiche_resultat "j1=[tel1 decode [tel1 putread :j1]]\n"
console::affiche_resultat "j2=[tel1 decode [tel1 putread :j2]]\n"
tel1 hadec coord


tel1 speedtrack 0 0
tel1 radec goto [list 6h 0d] -blocking 1
tel1 radec coord

mc_date2iso8601 now
# 2012-07-14T13:45:34.601

clock format [clock seconds] -gmt 1
# Sat Jul 14 11:45:35 GMT 2012

mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm

set off 10000
::console::affiche_resultat "\n============================ G100 offset $off ===\n"
execute ":j1"
execute ":f1"
execute ":G100"
execute ":H1[encode $off]"
execute ":J1"
execute ":f1"
execute "after 3000"
execute ":j1"
execute ":f1"

set off -10000
::console::affiche_resultat "\n============================ G100 offset $off ===\n"
execute ":j1"
execute ":f1"
execute ":G100"
execute ":H1[encode $off]"
execute ":J1"
execute ":f1"
execute "after 3000"
execute ":j1"
execute ":f1"

set off 10000
::console::affiche_resultat "\n============================ G101 offset $off ===\n"
execute ":j1"
execute ":f1"
execute ":G101"
execute ":H1[encode $off]"
execute ":J1"
execute ":f1"
execute "after 3000"
execute ":j1"
execute ":f1"

set off -10000
::console::affiche_resultat "\n============================ G101 offset $off ===\n"
execute ":j1"
execute ":f1"
execute ":G101"
execute ":H1[encode $off]"
execute ":J1"
execute ":f1"
execute "after 3000"
execute ":j1"
execute ":f1"

set off 10000
::console::affiche_resultat "\n============================ G200 offset $off ===\n"
execute ":j2"
execute ":f2"
execute ":G200"
execute ":H2[encode $off]"
execute ":J2"
execute ":f2"
execute "after 3000"
execute ":j2"
execute ":f2"

set off -10000
::console::affiche_resultat "\n============================ G200 offset $off ===\n"
execute ":j2"
execute ":f2"
execute ":G200"
execute ":H2[encode $off]"
execute ":J2"
execute ":f2"
execute "after 3000"
execute ":j2"
execute ":f2"

set off 10000
::console::affiche_resultat "\n============================ G201 offset $off ===\n"
execute ":j2"
execute ":f2"
execute ":G201"
execute ":H2[encode $off]"
execute ":J2"
execute ":f2"
execute "after 3000"
execute ":j2"
execute ":f2"

set off -10000
::console::affiche_resultat "\n============================ G201 offset $off ===\n"
execute ":j2"
execute ":f2"
execute ":G201"
execute ":H2[encode $off]"
execute ":J2"
execute ":f2"
execute "after 3000"
execute ":j2"
execute ":f2"

::console::affiche_resultat "\n============================ Fin des tests ===\n"

pppppppppppppppppppppppppppppppppppppppppppppppppppp

set off 40
::console::affiche_resultat "\n============================ G131 offset $off ===\n"
execute ":j1"
execute ":f1"
execute ":g1"
execute ":G131"
execute ":H1[encode $off]"
execute ":J1"
execute ":f1"
execute ":g1"
execute "after 3000"
execute ":K1"
execute "after 3000"
execute ":j1"
execute ":f1"
execute ":g1"

set g G130
::console::affiche_resultat "\n============================ $g calibration loop ===\n"
set xs ""
set ys ""
for {set i1 10} {$i1<50} {set i1 [expr $i1+10]} {

	set off 5000
	::console::affiche_resultat "---------------------------- $g i1=$i1 ADU, after $off ---\n"
	set pos1 [execute ":j1"]
	execute ":f1"
	execute ":$g"
	execute ":I1[encode $i1]"
	execute ":J1"
	execute ":f1"
	execute "after $off"
	execute ":K1"
	after 3000
	set pos2 [execute ":j1"]
	execute ":f1"
	set dpos  [execute "expr ($pos2-$pos1)/($off/1000.)" "(ADU/sec)"]
	set drift [execute "expr abs($dpos/$position_conversion)" "(deg/sec)"]
	lappend xs [expr 360.0 / $drift / $a1 ] ; # sec/ADU
	lappend ys $i1
}
set res [::math::statistics::linear-model $xs $ys]
set slope [lindex $res 1]
::console::affiche_resultat "COEFF i1 = $slope * (360.0 / drift / a1)\n"
::console::affiche_resultat "$slope  A COMPARER A b1 = $b1\n"
::plotxy::plot $xs $ys


set off 3000
set drift 0.1
::console::affiche_resultat "\n============================ G110 drift $drift °/sec, after $off ===\n"
set pos1 [execute ":j1"]
execute ":f1"
execute ":G110"
set i1 [execute "expr int($b1 * 360.0 / $drift / $a1)" "(set i1)"]
execute ":I1[encode $i1]"
execute ":J1"
execute ":f1"
execute "after $off"
execute ":K1"
set pos2 [execute ":j1"]
execute ":f1"
set dpos [execute "expr $pos2-$pos1" "(ADU)"]
set ddeg [execute "expr $dpos/$position_conversion" "(deg)"]
