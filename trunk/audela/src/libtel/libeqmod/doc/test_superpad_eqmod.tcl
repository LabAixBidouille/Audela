# source C:/srv/develop/audela/src/libtel/libeqmod/doc/test_superpad_eqmod.tcl

source C:/srv/develop/audela/gui/audace/telescope.tcl

set res [tel1 readparams]
foreach re $res {
	console::affiche_resultat "$re\n"
}

tel::create eqmod com8 -west -point north_pole -gps $conf(posobs,observateur,gps)
after 100
set res [tel1 readparams]
foreach re $res {
	console::affiche_resultat "$re\n"
}

# tel1 gotoblocking 1
# tel1 radec goto [name2coord vega]

# --- HEQ5 PRO juste apres init (moteurs ON)
# a1 9024000 {ADU/360deg} {microsteps/360deg}
# a2 9024000 {ADU/360deg} {microsteps/360deg}
# b1 64935 {ADU/sec} {velocity parameter}
# b2 64935 {ADU/sec} {velocity_parameter}
# e1 67585 {ADU} {unknown parameter (67585)}
# e2 67585 {ADU} {unknown parameter (67585)}
# f1 273 {binary} {motorRA state 0|1= 0|1= 0|1=}
# f2 272 {binary} {motorDEC state 0|1= 0|1= 0|1=}
# g1 16 {binary} {0|1=hemis(S|N) 0|1=track(+|-)}
# g2 16 {binary} {0|1=hemis(S|N) 0|1=track(+|-)}
# s1 66844 {ADU/turn} {microsteps to a complete turnover of worm}
# s2 66844 {ADU/turn} {microsteps to a complete turnover of worm}
# speed_track_ra 0.004178 {deg/s} {motorRA track speed}
# speed_track_dec 0.000000 {deg/s} {motorDEC track speed}
# speed_slew_ra 3.000000 {deg/s} {motorRA slew speed}
# speed_slew_dec 3.000000 {deg/s} {motorDEC slew speed}
# radec_speed_dec_conversion 0.000000 {ADU/(deg/s)} {motorRA and motorDEC speed conversion}
# radec_position_conversion 25066.666667 {ADU/deg} {motorRA and motorDEC position conversion}
# track_diurnal 0.004178 {deg/s} {motorRA theoretical diurnal track}
# stop_w_uc 250666 {ADU} {motorRA western stop}
# stop_e_uc -250666 {ADU} {motorRA eastern stop}
# radec_move_rate_max 1.000000 {deg/s} {motorRA and motorDEC maximum authorized slew speed}
# slew_axis 0 {integer} {motorRA and motorDEC motion states. 0: none, 1: RA, 2: DEC, 3: RA+DEC}
# tubepos 0 {binary} {0|1=tube_position(W|E)}
# ha_pointing 0 {binary} {motorRA 0|1=pointing_mode(RA|HA)}
# gotodead_ms 900 {ms} {waiting delay for a complete slew}
# gotoread_ms 350 {ms} {waiting delay for a answer}
# dead_delay_slew 1.800000 {s} {delay for a GOTO at the same place}

# --- EQ6
# a1 9024000 {ADU/360deg} {microsteps/360deg}
# a2 9024000 {ADU/360deg} {microsteps/360deg}
# b1 64935 {ADU/sec} {velocity parameter}
# b2 64935 {ADU/sec} {velocity_parameter}
# e1 1026 {ADU} {unknown parameter (67585)}
# e2 1026 {ADU} {unknown parameter (67585)}
# f1 272 {binary} {motorRA state 0|1= 0|1= 0|1=}
# f2 272 {binary} {motorDEC state 0|1= 0|1= 0|1=}
# g1 16 {binary} {0|1=hemis(S|N) 0|1=track(+|-)}
# g2 16 {binary} {0|1=hemis(S|N) 0|1=track(+|-)}
# s1 50133 {ADU/turn} {microsteps to a complete turnover of worm}
# s2 50133 {ADU/turn} {microsteps to a complete turnover of worm}
# speed_track_ra 0.004178 {deg/s} {motorRA track speed}
# speed_track_dec 0.000000 {deg/s} {motorDEC track speed}
# speed_slew_ra 3.000000 {deg/s} {motorRA slew speed}
# speed_slew_dec 3.000000 {deg/s} {motorDEC slew speed}
# radec_position_conversion 25066.666667 {ADU/deg} {motorRA and motorDEC position conversion}
# track_diurnal 0.004178 {deg/s} {motorRA theoretical diurnal track}
# stop_w_uc 250666 {ADU} {motorRA western stop}
# stop_e_uc -250666 {ADU} {motorRA eastern stop}
# radec_move_rate_max 1.000000 {deg/s} {motorRA and motorDEC maximum authorized move speed}
# slew_axis 0 {integer} {motorRA and motorDEC motion states. 0: none, 1: RA, 2: DEC, 3: RA+DEC}
# tubepos 0 {binary} {0|1=tube_position(W|E)}
# gotodead_ms 900 {ms} {waiting delay for a complete slew}
# gotoread_ms 350 {ms} {waiting delay for a answer}
# dead_delay_slew 1.800000 {s} {delay for a GOTO at the same place}
# tempo 100 {ms} {delay before to read a command}
# ha_park -90.000000 {deg} {motorRA Parking hour angle}
# dec_park 89.999990 {deg} {motorDEC Parking declination}
# gotoblocking 0 {binary} {default GOTO blocking 0|1=non_blocking|blocking}

# ===========================================================================

proc envoi { f msg } {
   puts -nonewline $f "$msg\r" ; flush $f
   ::console::affiche_resultat "ENVOIE <$msg>\n"
   after 100
   set msg [read $f]
   ::console::affiche_resultat "RECOIT <$msg>\n"
   return $msg
}

proc decode { hexa } {
   set nn [string length $hexa]
   set n [expr $nn/2]
   #set bb ""
   set integ 0
   for {set k 0} {$k<$n} {incr k} {
      set hex [string range $hexa [expr $k*2] [expr $k*2+1]]
      set ligne "binary scan \\x$hex c1 b"
      eval $ligne
      if {$b<0} { incr b 256 }
      set integ [expr $integ+pow(2,[expr $k*8])*$b]
      #::console::affiche_resultat "hex=$hex => b=$b integ=$integ\n"
      #append bb "$b "
   }
   return $integ
}

proc encode { integ } {   
   set n 3
   set bb ""
   for {set k 0} {$k<$n} {incr k} {
      set kk [expr $n-$k-1]
      set base [expr pow(2,[expr $kk*8])]
      set b [expr int(floor($integ/$base))]
      binary scan [format %c $b] H* h
      set h [string toupper $h]
      #::console::affiche_resultat "integ=$integ base=$base => b=$b h=$h\n"
      set integ [expr $integ-$base*$b]
      set bb "$h${bb}"
   }
   return $bb
}

# set f [open com1 w+]
# fconfigure $f -mode "9600,n,8,1" -buffering none -translation {binary binary} -blocking 0
# set sortie 0
# set k 0
# while {$sortie==0} {
# 	set res [envoi $f ":e1"] ; # 67585
# 	::console::affiche_resultat "$k $res\n"
# 	if {($res!="")} {
# 		tk_messageBox
# 	}
# 	if {($res!="")||($k>40)} {
# 		set sortie 1
# 	}
# 	incr k
# 	after 500
# }
# close $f

set a1 [tel1 decode [tel1 put ":a1"]]
set b1 [tel1 decode [tel1 put ":b1"]]

set j1 [tel1 decode [tel1 put ":j1"]]

set position_conversion [expr 1.0 * $a1 / 360.] ; # ADU/deg

set ha [expr $j1/$position_conversion]


