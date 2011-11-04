#
# Fichier : meteosensor_tools.tcl
# Description : Read data from various meteo sensors
# Auteur : Alain KLOTZ
# Mise � jour $Id: meteosensor_tools.tcl 7736 2011-11-02 11:39:06Z alainklotz $
#
# source "$audace(rep_install)/gui/audace/meteosensor_tools.tcl"
#
# This tool is based on three basic actions: open, get data, close
#
# --- Reference guide
# meteosensor_open $type $port $name ?$parameters?
#    type : AAG WXT520 ARDUINO1 VANTAGEPRO BOLTWOOD LACROSSE SIMULATION
#    port : com1, etc.
#    name : a word to identify the connection opened
#  return the name if opening is OK
# meteosensor_get $name
#    name : identifier of the connection opened
#  return a list of measurements. For each list element:
#    index 0 : Name of the parameter measured
#    index 1 : Value of the parameter measured
#    index 2 : Units of the parameter measured
#    index 3 : Comment of the parameter measured
# meteosensor_getstandard $name
#    name : identifier of the connection opened
#  return a list of measurements as for meteosensor_get
#  but elements are the same whatever the meteo sensor.
#  Some elements can be undefined.
# meteosensor_close $name
#    name : identifier of the connection opened
#  return nothing is closing is OK
#
# --- Example 1
# meteosensor_open AAG com1 cs1
# # cs1
# meteosensor_get cs1
# # {SkyTemperature 20.83 Celcius {Sky temperature measured by an infrared sensor}} {SkyCover VeryCloudy text {A word that describes sky conditions}} {CloudSensorTemperature 24.73 Celcius Warm} {LDR 1535.3 kohms {Light Dependent Resistor}} {Brightness Light text {A word that describes brightness conditions}} {RainSensorTemperature 26.24 Warm} {PrecipitableWater Dry text {Rain or Wet or Dry}}
# meteosensor_close cs1
# #
#
# --- Example 2
# meteosensor_open ARDUINO com4 myarduino1
# # myarduino1
# meteosensor_get myarduino1
# # {RainSensorTime 2011-11-04T17:58:57.965 ISO8601 "Date"} {Rain 1 logical "1=Dry 0=Rain"} {RainAnalog 0.64 V ""} {RainState Dry text ""} {RainLastChange 32.00 sec ""} {RainLastState Unknown text "Symbol of the previous state"} {RainLastReboot 32.00 sec ""} {RainAnalogADU 132 ADU ""} {SensorModel Kemo_M152 text "Sensor model"}
# meteosensor_close myarduino1
# #

proc meteosensor_open { type port name {parameters ""} } {
	global audace
	if {[info exists audace(cloudsensor,private,$name,channel)]==1} {
		catch { meteosensor_close }
	}	
	set typeu [string trim [string toupper $type]]	
	set portu [string trim [string toupper $port]]
	set key [string range $portu 0 2]
	if {($key=="COM")&&($::tcl_platform(os) == "Linux")} {
		# tester les /etc/...
	}
	if {($typeu=="AAG")||($typeu=="ARDUINO1")} {
		set f [open $port w+]
		fconfigure $f  -mode 9600,n,8,1 -buffering none -blocking 0		
		set audace(cloudsensor,private,$name,channel) $f
		set audace(cloudsensor,private,$name,typeu) $typeu
	} elseif {$typeu=="WXT520"} {
		set f [open $port w+]
		fconfigure $f  -mode 19200,n,8,1 -buffering none -translation {binary binary} -blocking 0
		set audace(cloudsensor,private,$name,channel) $f
		set audace(cloudsensor,private,$name,typeu) $typeu
	} elseif {$typeu=="VANTAGEPRO"} {
		if {$portu=="NPORT"} {			
			set ip1 [lindex $parameters 0]
			set port1 [lindex $parameters 1]
			set ip2 [lindex $parameters 2]
			set port2 [lindex $parameters 3]
			if {$ip1==""} {
				error "Parameters must be a list of 4 elements: ip1 port1 ip2 port2"
			}
			set res [vantagepronport_open $ip1 $port1 $ip2 $port2]
			set audace(cloudsensor,private,$name,channel) [lindex $res 0]
			set audace(cloudsensor,private,$name,channelg) [lindex $res 1]
		} else {
			ros_meteo open vantage
			set audace(cloudsensor,private,$name,channel) undefined
		}
		set audace(cloudsensor,private,$name,typeu) $typeu
	} elseif {$typeu=="BOLTWOOD"} {
		set filename [lindex $parameters 0]
		boltwood_open $filename
		set audace(cloudsensor,private,$name,channel) undefined
		set audace(cloudsensor,private,$name,typeu) $typeu
	} elseif {$typeu=="LACROSSE"} {
		fetch3600_open $port
		set audace(cloudsensor,private,$name,channel) undefined
		set audace(cloudsensor,private,$name,typeu) $typeu
	} elseif {$typeu=="SIMULATION"} {
		simulationmeteo_open
		set audace(cloudsensor,private,$name,channel) undefined
		set audace(cloudsensor,private,$name,typeu) $typeu
	} else {
		error "Type not supported. Valid types are: AAG, WXT520, ARDUINO1, VANTAGEPRO, BOLTWOOD, LACROSSE"
	}
	return $name
}

proc meteosensor_channel { name } {
	global audace
	if {[info exists audace(cloudsensor,private,$name,channel)]==0} {
		error "Cloudsensor connection not opened. Use meteosensor_open before"
	}
	set ress $audace(cloudsensor,private,$name,channel)
	if {[info exists audace(cloudsensor,private,$name,channelg)]==1} {
		lappend ress $audace(cloudsensor,private,$name,channelg)
	}
	return $ress
}

proc meteosensor_get { name } {
	global audace
	if {[info exists audace(cloudsensor,private,$name,channel)]==0} {
		error "Cloudsensor connection not opened. Use meteosensor_open before"
	}
	set typeu $audace(cloudsensor,private,$name,typeu)
	if {$typeu=="AAG"} {
		set res [aag_read $audace(cloudsensor,private,$name,channel)]
	} elseif {$typeu=="WXT520"} {
		set res [wxt520_read $audace(cloudsensor,private,$name,channel)]
	} elseif {$typeu=="ARDUINO1"} {
		set res [arduino1_rainsensor_read $audace(cloudsensor,private,$name,channel)]
	} elseif {$typeu=="VANTAGEPRO"} {
		if {[info exists audace(cloudsensor,private,$name,channelg)]==1} {
			set res [vantagepronport_read $audace(cloudsensor,private,$name,channel) $audace(cloudsensor,private,$name,channelg)]
		} else {
			set res [ros_meteo read vantage]
		}
	} elseif {$typeu=="BOLTWOOD"} {
		set res [boltwood_read]
	} elseif {$typeu=="LACROSSE"} {
		set res [fetch3600_read]
	} elseif {$typeu=="SIMULATION"} {
		set res [simulationmeteo_read]
	}
	return $res
}

proc meteosensor_getstandard { name } {
	global audace
	set ps [meteosensor_get $name]
	set keystandards "SkyCover          SkyTemp        OutTemp                 WinDir WinSpeed Water"
	set typeu $audace(cloudsensor,private,$name,typeu)
	if {$typeu=="AAG"} {
		set keys      "SkyCover          SkyTemperature CloudSensorTemperature  -      -        PrecipitableWater"
	} elseif {$typeu=="WXT520"} {
		set keys      "-                 -              OutsideTemp             WinDir WinSpeed PrecipitableWater"
	} elseif {$typeu=="ARDUINO1"} {
		set keys      "-                 -              -                       -      -        RainState"
	} elseif {$typeu=="VANTAGEPRO"} {
		set keys      "-                 -              OutsideTemp             WinDir WinSpeed PrecipitableWater"
	} elseif {$typeu=="BOLTWOOD"} {
		set keys      "CloudSkyCondition CloudSkyTemp   CloudOutsideTemp        -      -        CloudWetFlag"
	} elseif {$typeu=="LACROSSE"} {
		set keys      "-                 -              OutsideTemp             WinDir WinSpeed PrecipitableWater"
	} elseif {$typeu=="SIMULATION"} {
		set keys      "SkyCover          SkyTemp        OutTemp                 WinDir WinSpeed Water"
	}
	set restot ""
	set k1 0
	foreach keystandards $keystandards {
		set key [lindex $keys $k1]
		set val undefined
		set unit undefined
		set com undefined
		if {$key=="-"} {
			set key undefined
		} else {
			foreach p $ps {
				set keyp [lindex $p 0]
				if {$keyp==$key} {
					set val [lindex $p 1]
					set unit [lindex $p 2]
					set com [lindex $p 3]
					break
				}
			}
		}
		lappend restot [list $keystandards $val $unit $com]
		incr k1		
	}
	return $restot
}

proc meteosensor_close { name } {
	global audace
	if {[info exists audace(cloudsensor,private,$name,channel)]==0} {
		error "Cloudsensor connection not opened. Use meteosensor_open before"
	}
	set typeu $audace(cloudsensor,private,$name,typeu)
	if {($typeu=="AAG")||($typeu=="WXT520")||($typeu=="ARDUINO1")} {
		close $audace(cloudsensor,private,$name,channel)
		unset audace(cloudsensor,private,$name,channel)
		unset audace(cloudsensor,private,$name,typeu)
	}
	if {($typeu=="VANTAGEPRO")} {
		if {([info exists audace(cloudsensor,private,$name,channelg)]==1)} {
			close $audace(cloudsensor,private,$name,channel)
			unset audace(cloudsensor,private,$name,channel)
			unset audace(cloudsensor,private,$name,typeu)
			close $audace(cloudsensor,private,$name,channelg)
			unset audace(cloudsensor,private,$name,channelg)
		} else {
			ros_meteo close vantage
			close $audace(cloudsensor,private,$name,channel)
			unset audace(cloudsensor,private,$name,channel)
			unset audace(cloudsensor,private,$name,typeu)
		}
	}
	if {($typeu=="BOLTWOOD")||($typeu=="LACROSSE")||($typeu=="SIMULATION")} {
		unset audace(cloudsensor,private,$name,channel)
		unset audace(cloudsensor,private,$name,typeu)
	}
}

# ===========================================================================
# ===========================================================================
# ====== AAG Cloudwatcher
# ===========================================================================
# ===========================================================================

proc aag_ascii2num { ascii } {
	for { set k 0 } { $k<256 } {incr k} {
		if {$ascii==[format %c $k]} {
			return $k
		}
	}
	return -1
}

proc aag_send { channel commande } {
	set response [read -nonewline $channel]
	after 10
	puts -nonewline $channel "${commande}!"
	set car [string index $commande 0]
	set tempo 50
	if {$car=="C"} { set tempo 100 }
	if {$car=="D"} { set tempo 100 }
	if {$car=="E"} { set tempo 300 }
	after $tempo
	set response [read -nonewline $channel]
	if {$response==""} {
		error "Pb connection for command $commande\n"
	}
	set ress ""
	set sortie 0
	set k1 0
	while {$sortie==0} {
		set k2 [expr $k1+14]
		set resp [string range $response $k1 $k2]
		set begininfo [string range $resp 0 0]
		if {$begininfo!="!"} {
			error "Pb first ! not found for command $commande"
		}
		set key [string index $resp 1]
		#console::affiche_resultat "resp=<$resp>\n"		
		if {$key==[format %c 17]} { 
			break
	   } elseif {$key=="K"} { 
			set infocontent [string range $resp 2 13]
			lappend ress [list SerialNumber [string trim $infocontent]]		   
	   } elseif {$key=="M"} { 
		   set kc 2
		   set c1 [aag_ascii2num [string index $resp $kc]] ; incr kc
		   set c2 [aag_ascii2num [string index $resp $kc]] ; incr kc
		   set val [expr (256*$c1+$c2)/100.]
			lappend ress [list ZenerVoltage $val]		   
		   set c1 [aag_ascii2num [string index $resp $kc]] ; incr kc
		   set c2 [aag_ascii2num [string index $resp $kc]] ; incr kc
		   set val [expr (256*$c1+$c2)/1.]
			lappend ress [list LDRMaxResistance $val]		   
		   set c1 [aag_ascii2num [string index $resp $kc]] ; incr kc
		   set c2 [aag_ascii2num [string index $resp $kc]] ; incr kc
		   set val [expr (256*$c1+$c2)/10.]
			lappend ress [list LDRPullUpResistance $val]		   
		   set c1 [aag_ascii2num [string index $resp $kc]] ; incr kc
		   set c2 [aag_ascii2num [string index $resp $kc]] ; incr kc
		   set val [expr (256*$c1+$c2)/1.]
			lappend ress [list RainBeta $val]
		   set c1 [aag_ascii2num [string index $resp $kc]] ; incr kc
		   set c2 [aag_ascii2num [string index $resp $kc]] ; incr kc
		   set val [expr (256*$c1+$c2)/10.]
			lappend ress [list RainResAt25 $val]
		   set c1 [aag_ascii2num [string index $resp $kc]] ; incr kc
		   set c2 [aag_ascii2num [string index $resp $kc]] ; incr kc
		   set val [expr (256*$c1+$c2)/10.]
			lappend ress [list RainPullUpResistance $val]
		} else {
			set infonature [string range $resp 1 2]
			set infocontent [string range $resp 3 14]
			lappend ress [list [string trim $infonature] [string trim $infocontent]]
		}
		set k1 [expr $k2+1]
		if {$k1>100} { break }
	}
	return $ress
}

proc aag_read { channel } {
	set ress [aag_send $channel M]
	foreach res $ress {
		set key [lindex $res 0]
		set val [lindex $res 1]
		set aag($key) $val
		#console::affiche_resultat "aag($key) = $val\n"
	}
	set ress ""
	# --- SkyTemp (small size sensor)
	set res [aag_send $channel S]
	set val [lindex [lindex $res 0] 1]
	set val [expr $val/100.]
	if {$val<-8} {
		set com Clear
	} elseif {$val<0} {
		set com Cloudy
	} else {
		set com VeryCloudy
	}
	set units Celcius
	lappend ress [list SkyTemperature $val $units "Sky temperature measured by an infrared sensor"]
	lappend ress [list SkyCover $com text "A word that describes sky conditions"]
	# --- SensorTemp (small size sensor)
	set res [aag_send $channel T]
	set val [lindex [lindex $res 0] 1]
	set val [expr $val/100.]
	if {$val<10} {
		set com Cold
	} elseif {$val<30} {
		set com Warm
	} elseif {$val<40} {
		set com Hot
	} else {
		set com VeryHot
	}	
	set units Celcius
	lappend ress [list CloudSensorTemperature $val $units "$com"]
	# --- Light Dependent Resistor (medium size sensor)
	set res [aag_send $channel C]
	set val [lindex [lindex $res 1] 1]
	if {$val>1022} { set val 1022 }
	if {$val<1} { set val 1 }
	set LDR [expr $aag(LDRPullUpResistance) / ( (1023./$val)-1 )]
	if {$LDR>2000} {
		set com Dark
	} elseif {$LDR>6} {
		set com Light
	} else {
		set com VeryLight
	}
	set units kohms
	lappend ress [list LDR [format %.1f $LDR] $units "Light Dependent Resistor"]
	lappend ress [list Brightness $com text "A word that describes brightness conditions"]
	# --- Ambiant temperature from the rain sensor (large sensor)
	set val [lindex [lindex $res 2] 1]
	if {$val>1022} { set val 1022 }
	if {$val<1} { set val 1 }
	set r [expr $aag(RainPullUpResistance) / ( (1023./$val)-1 )]
	set r [expr log($r/$aag(RainResAt25))]
	set ABSZERO 273.15
	set TRain [expr 1. / ($r / $aag(RainBeta) + 1. / ( $ABSZERO + 25 )) - $ABSZERO]
	if {$TRain<10} {
		set com Cold
	} elseif {$TRain<30} {
		set com Warm
	} elseif {$TRain<40} {
		set com Hot
	} else {
		set com VeryHot
	}
	set units Celcius
	lappend ress [list RainSensorTemperature [format %.2f $TRain] "$com"]
	# --- Rain (large sensor)
	set res [aag_send $channel E]
	set val [lindex [lindex $res 0] 1]
	if {$val<400} {
		set com Unknown
	} elseif {$val<1700} {
		set com Rain
	} elseif {$val<2000} {
		set com Wet
	} else {
		set com Dry
	}
	set units Frequency
	#lappend ress [list RainSensorFrequency $val $units "Rain frequency counter"]
	lappend ress [list PrecipitableWater $com text "Rain or Wet or Dry"]
	# --- return results
	return $ress
}

# ===========================================================================
# ===========================================================================
# ====== Vaisala WXT520
# ===========================================================================
# ===========================================================================

proc wxt520_envoi { channel msg } {
	set f $channel
   puts -nonewline $f "$msg[format %c 13][format %c 10]" ; after 10 ; flush $f
   #::console::affiche_resultat "ENVOIE <$msg>\n"
   set t0 [clock seconds]
   set msgtot ""
   set sortie 0
   while {$sortie==0} {
	   after 100
	   set msg [read $f]
	   set n [string length $msg]
	   if {$n>0} {
		   append msgtot $msg
	   }
	   set k [string first [format %c 10] $msgtot]
	   if {$k>=0} {
		   set sortie 1
		   break
	   }
	   set dt [expr [clock seconds]-$t0]
	   if {$dt>5} {
		   set sortie 2
		   break
	   }
   }
	set msg $msgtot
   set k [string first [format %c 13] $msg]
   if {$k<0} {set k 1 }
   set msg [string range $msg 0 [expr $k-1]]
   #::console::affiche_resultat "RECOIT <$msg>\n"		   
   return $msg
}

proc wxt520_decode { reponse } {
	set ress [split $reponse ,]
   #::console::affiche_resultat "ress <$ress>\n"
   set reps ""
   foreach res $ress {
		set res [split $res =]
	   set key [lindex $res 0]
	   set val [lindex $res 1]
	   set v [string trimleft [string range $val 0 end-1] 0]
	   if {$v==""} { set v 0 }
	   set u [string range $val end end]
	   if {$val==""} {
		   continue
	   }
	   # --- 
	   if {$key=="A"} {lappend reps "Address $val"}
	   if {$key=="M"} {lappend reps "Protocol $val"}
	   if {$key=="T"} {lappend reps "Test-param $val"}
	   if {$key=="C"} {
		   set val1 "Unknown"
		   if {$val=="1"} { set val1 SDI-12 }
		   if {$val=="2"} { set val1 RS-232 }
		   if {$val=="3"} { set val1 RS-485 }
		   if {$val=="4"} { set val1 RS-422 }
		   lappend reps "Interface $val1"
		}
	   if {$key=="I"} {lappend reps "Repet-interval $val"}
	   if {$key=="B"} {lappend reps "Baud $val"}
	   if {$key=="D"} {lappend reps "Data-bits $val"}
	   if {$key=="P"} {lappend reps "Parity $val"}
	   if {$key=="S"} {lappend reps "Stop-bits $val"}
	   if {$key=="L"} {lappend reps "RS-485-Line-delay $val"}
	   if {$key=="N"} {lappend reps "Name $val"}
	   if {$key=="V"} {lappend reps "Software-version $val"}
	   # --- M1
	   if {$key=="Dn"} {lappend reps "Wind_dir_mini $v $u"}
	   if {$key=="Dx"} {lappend reps "Wind_dir_maxi $v $u"}
	   if {$key=="Dm"} {lappend reps "Wind_dir_mean $v $u"}
	   if {$key=="Sn"} {lappend reps "Wind_vel_mini $v $u"}
	   if {$key=="Sx"} {lappend reps "Wind_vel_maxi $v $u"}
	   if {$key=="Sm"} {lappend reps "Wind_vel_mean $v $u"}
	   # --- M2
	   if {$key=="Ta"} {lappend reps "Temperature_ext $v $u"}
	   if {$key=="Tp"} {lappend reps "Temperature_int $v $u"}
	   if {$key=="Ua"} {lappend reps "Humidity $v $u"}
	   if {$key=="Pa"} {lappend reps "Pressure $v $u"}
	   # --- M3
	   if {$key=="Rc"} {lappend reps "Cumulative_rain $v $u"}
	   if {$key=="Rd"} {lappend reps "Duration_rain $v $u"}
	   if {$key=="Ri"} {lappend reps "Rate_rain $v $u"}
	   if {$key=="Hc"} {lappend reps "Cumulative_hail $v $u"}
	   if {$key=="Hd"} {lappend reps "Duration_hail $v $u"}
	   if {$key=="Hi"} {lappend reps "Rate_hail $v $u"}
	   if {$key=="Rp"} {lappend reps "MaxRate_rain $v $u"}
	   if {$key=="Hp"} {lappend reps "MaxRate_hail $v $u"}
	   # --- M5
	   if {$key=="Th"} {lappend reps "Temp_heating $v $u"}
	   if {$key=="Vh"} {lappend reps "Voltage_heating $v $u"}
	   if {$key=="Vs"} {lappend reps "Voltage_power $v $u"}
	   if {$key=="Vr"} {lappend reps "Voltage_reference $v $u"}
   }
   return $reps
}

proc wxt520_read { channel } {
   set commande "?"
   set res [wxt520_envoi $commande]
   if {$res!="0"} {
		error "Pb connection\n"
   }
   set commande "0R1"
   set res0 [wxt520_envoi $commande]
   set res [wxt520_decode $res0]
   set k [lsearch -regexp $res Wind_dir_mean]
   if {$k>=0} { set dirvent [lindex [lindex $res $k] 1] }
   if {[catch {expr $dirvent}]==1} {
	   error "Pb dirvent=$dirvent ($res)"
   }		         
   set k [lsearch -regexp $res Wind_vel_mean]
   if {$k>=0} { set vitvent [lindex [lindex $res $k] 1] }
   set commande "0R2"
   set res0 [wxt520_envoi $commande]
   set res [wxt520_decode $res0]
   set k [lsearch -regexp $res Temperature_ext]
   if {$k>=0} { set tempext [lindex [lindex $res $k] 1] ; set tempint [lindex [lindex $res $k] 1] }
   set k [lsearch -regexp $res Temperature_int]
   if {$k>=0} { set tempint [lindex [lindex $res $k] 1] }
   set k [lsearch -regexp $res Humidity]
   if {$k>=0} { set humext [lindex [lindex $res $k] 1] ; set humint [lindex [lindex $res $k] 1] }
   set k [lsearch -regexp $res Pressure]
   if {$k>=0} { set pression [lindex [lindex $res $k] 1] }
   set commande "0R3"
   set res0 [wxt520_envoi $commande]
   set res [wxt520_decode $res0]
   set k [lsearch -regexp $res Rate_rain]
   if {$k>=0} { set rainrate [lindex [lindex $res $k] 1] }
   set k [lsearch -regexp $res Rate_hail]
   if {$k>=0} { set hailrate [lindex [lindex $res $k] 1] }	
   # --- calcule de la temperature de rosee par la formule de Magnus-Tetens
   #set humidity_taux [expr $humext/100.]
   #set f [expr 17.271*$tempext/(237.7+$tempext) + log($humidity_taux)]
   #set dewtemp [expr 237.7*$f/(17.271-$f)]	
   # et rajoute 5% a RH et 0.5deg a T pour incertitude de mesure sur la station vaisala 
   set humidity_taux [expr ($humext+5)/100.]
   set f [expr 17.271*($tempext+0.5)/(237.7+$tempext+0.5) + log($humidity_taux)]
   set dewtemp [expr 237.7*$f/(17.271-$f)]	         
   #
   #set dewtemp [expr pow($humext/100.,1./8.)*(112.+(0.9*$tempext))+(0.1*$tempext)-112.]
   if {$dirvent<22.5} {
      set pcard "S"
   } elseif { $dirvent< 67.5} {
      set pcard "SW"
   } elseif { $dirvent<112.5} {
      set pcard "W"
   } elseif { $dirvent<157.5} {
      set pcard "NW"
   } elseif { $dirvent<202.5} {
      set pcard "N"
   } elseif { $dirvent<247.5} {
      set pcard "NE"
   } elseif { $dirvent<292.5} {
      set pcard "E"
   } elseif { $dirvent<337.5} {
      set pcard "SE"
   } else {
      set pcard "S"
   }
   set dirvent [expr $dirvent+180]
   if {$dirvent>360} {
      set dirvent [expr $dirvent-360]
   }
   set resultat ""
   set er [catch {
      set res [mc_date2ymdhms now]
      set month [lindex $res 1]
      set day [lindex $res 2]
      set year [lindex $res 0]
      set hour [lindex $res 3]
      set min [lindex $res 4]
      set res "$month $day $year $hour $min"
		set date "[format %04d $year]-[format %02d $month]-[format %02d $day]T[format %02d $hour]:[format %02d $min]:00"
      lappend resultat [list StationTime $date ISO8601 "Date of the last measurement"]
      lappend resultat [list OutsideTemp [format %.1f $tempext] Celcius ""]
      lappend resultat [list InsideTemp [format %.1f $tempint] Celcius ""]
      lappend resultat [list OutsideHumidity [format %.1f $humext] Percent ""]
      lappend resultat [list HailRate [format %.1f $hailrate] impatcs/hour ""]
      lappend resultat [list Barometer [format %.1f $pression] mbar ""]
      lappend resultat [list RainRate  [format %.1f $rainrate] mm/hour ""]
      lappend resultat [list WindSpeed [format %.1f $vitvent] m/s ""]
      lappend resultat [list WindDir [format %.1f $dirvent] deg "N=0, E=90"]
      lappend resultat [list WindDirCardinal $pcard text "Cadinal symbol of wind direction"]
      lappend resultat [list DewPt [format %.1f $dewtemp] Celcius "Dew point"]
   } ms ]
   if {$er==1} {
      error "Meteo problem ($ms)"
   }
	#gren_info "[mc_date2iso8601 now] $thisproc : resultat=$resultat"
   return $resultat
}
		
# ===========================================================================
# ===========================================================================
# ====== Arduino rainsensors (Vaisala DRD11 or Kemo M152)
# ===========================================================================
# ===========================================================================
# The following code is programmed in the Arduino
# /*
#  * detecteur de pluie KEMO_M152 ou VAISALA_DRD11 en fonction du #define
#  *
# # code Tcl qui fait marcher tout cela
# set f [open com4 w+]
# fconfigure $f  -mode 9600,n,8,1 -buffering none -blocking 0
# puts -nonewline $f get\n ; after 200 ; read -nonewline $f
# close $f
#  */
# 
# // --- LEDs that indicate rain or not
# int ledPinRed =  7;    // RED LED connected to digital pin 7
# int ledPinGreen =  6;    // GREEN LED connected to digital pin 6
# 
# // --- wire from/to sensor
# int sensorPin = 5; // analog pin 5
# int rainPin =  2;  // digital pin 2
# 
# #define KEMO_M152
# // Sensor : Kemo M152
# // Analog pin 5 : white (dry<5V, wet=5V)
# // GND pin : yellow
# // Vin pin : brown (12V DC)
# // 5V pin : green
# 
# //#define VAISALA_DRD11
# // Sensor : Vaiasala DRD11A
# // Analog pin 5 : yellow (dry=3V, wet=1V, off<0.5V) analog pin 5
# // Digital pin 2 : blue (Rain) digital pin 2
# // GND pin : black and brown
# // Vin pin : red (12V DC)
# 
# float sensorValue = 0;
# int rainValue = 0; 
# int mode = 0; //=0 normal =1 debug
# char command[128];
# int command_complete = 0;
# int stateLedRed = 0;
# unsigned long time = 0;
# unsigned long time0 = 0;
# char state0[20];
# char state00[20];
# unsigned long time1 = 0;
# char state[20];
# 
# void setup()                    // run once, when the sketch starts
# {
#   // initialize the digital pin as an output or input
#   pinMode(ledPinRed, OUTPUT);     
#   pinMode(ledPinGreen, OUTPUT);     
#   pinMode(rainPin, INPUT);     
#   mode = 0;
#   command_complete = 0;
#   strcpy(command,"");
#   stateLedRed = 0;
#   time0 = millis();
#   time1 = 0;
#   strcpy(state0,"");
#   strcpy(state00,"Unknown");
#   digitalWrite(ledPinRed, LOW);   // set the RED LED off
#   digitalWrite(ledPinGreen, LOW);   // set the GREEN LED off
#   Serial.begin(9600);           // set up Serial library at 9600 bps
#   Serial.println("");  
# }
# 
# void loop()  
#  {  
#   int val;
#   char key;
#   double dt=0,dtboot=0;
#   rainValue = digitalRead(rainPin);
#   val = analogRead(sensorPin);
#   sensorValue = val/1024.*5.;
#   time = millis();
#   if (time<time0) {
#     time1=time1+pow(2,32)/1000;
#     time0=0;
#   }
#   if (mode==0) {
# #if defined KEMO_M152
#     /* --- KEMO_M152 rainsensor ---*/
#     if (val<1020) {
#       rainValue=1;
#       digitalWrite(ledPinRed, LOW);   // set the red LED off
#       digitalWrite(ledPinGreen, HIGH);   // set the green LED on
#       strcpy(state,"Dry");
#     } else {
#       rainValue=0;
#       digitalWrite(ledPinRed, HIGH);   // set the red LED on
#       digitalWrite(ledPinGreen, LOW);   // set the green LED off
#       strcpy(state,"Rain");
#     }
# #endif
# #if defined VAISALA_DRD11
#     /* --- Vaisala rainsensor ---*/
#     if ((sensorValue<1.2)&&(rainValue==1)) {
#       digitalWrite(ledPinRed, HIGH);   // set the red LED on
#       digitalWrite(ledPinGreen, HIGH);   // set the green LED on
#       strcpy(state,"Problem");
#     } else {
#       if ((sensorValue>2.5)&&(rainValue==0)) {
#           digitalWrite(ledPinRed, LOW);   // set the red LED off
#           digitalWrite(ledPinGreen, HIGH);   // set the green LED on
#           strcpy(state,"Drying...");
#        } else {
#           if ((rainValue==1)&&(sensorValue>2.5)) {
#             digitalWrite(ledPinRed, LOW);   // set the red LED off
#             digitalWrite(ledPinGreen, HIGH);   // set the green LED on
#             strcpy(state,"Dry");
#        } else {
#           digitalWrite(ledPinRed, HIGH);   // set the red LED on
#           digitalWrite(ledPinGreen, LOW);   // set the green LED off
#           strcpy(state,"Rain");
#         } 
#       }
#     }
# #endif
#     if (strcmp(state0,state)!=0) {
#       strcpy(state00,state0);
#       time0=time;
#       strcpy(state0,state);
#     }
#   }
#   dt=((time-time0)/1000)+time1;
#   dtboot=(time/1000)+time1;
#   while (Serial.available()) {  
#      key = Serial.read();
#      if ((key=='\n')||(key=='\r')) {
#         command_complete=-1;
#         if (strcmp(command,"?")==0) {
#           mode = 0;
#           Serial.println("Flag_rain(0=Rain) Voltage(Volts) State(Dry|Rain|Problem) Last_change(sec) Previous_State(Dry|Rain|Problem|Unknown) Last_boot(sec) Voltage(ADU)");
#         } else if (strcmp(command,"get")==0) {
#           mode = 0;
#           if (strcmp(state00,"")==0) {
#             strcpy(state00,"Unknown");
#           }
#           Serial.print(rainValue);       
#           Serial.print(" ");
#           Serial.print(sensorValue);       
#           Serial.print(" ");
#           Serial.print(state);       
#           Serial.print(" ");
#           Serial.print(dt);
#           Serial.print(" ");
#           Serial.print(state00);       
#           Serial.print(" ");
#           Serial.print(dtboot);
#           Serial.print(" ");
#           Serial.print(val);       
# #if defined VAISALA_DRD11
#           Serial.print(" Vaisala_DRD11A");
# #endif
# #if defined KEMO_M152
#           Serial.print(" Kemo_M152");
# #endif
#           Serial.println(" ");       
#         } else if (strcmp(command,"red 0")==0) {
#           mode = 1;
#           digitalWrite(ledPinRed, LOW);   // set the red LED off
#           Serial.println("Debug : red led off");
#         } else if (strcmp(command,"red 1")==0) {
#           mode = 1;
#           digitalWrite(ledPinRed, HIGH);   // set the red LED off
#           Serial.println("Debug : red led on");
#         } else if (strcmp(command,"green 0")==0) {
#           mode = 1;
#           digitalWrite(ledPinGreen, LOW);   // set the green LED off
#           Serial.println("Debug : green led off");
#         } else if (strcmp(command,"green 1")==0) {
#           mode = 1;
#           digitalWrite(ledPinGreen, HIGH);   // set the green LED off
#           Serial.println("Debug : green led on");
#         } else if (strcmp(command,"")!=0) {
#           Serial.print("commande ");  
#           Serial.print(command);  
#           Serial.println(" non reconnue parmi ?, get, red 0, red 1, green 0, green 1.");  
#         }
#         Serial.flush();
#         strcpy(command,"");
#         command_complete=0;
#      } else {
#         command[command_complete]=key;
#         command_complete++;
#         command[command_complete]='\0';
#      }
#    }   
# }
# ===========================================================================

proc arduino1_rainsensor_envoi { channel msg } {
	flush $channel
   puts -nonewline $channel "$msg\n"
   after 200
   set msg [read -nonewline $channel]
   return $msg
}
		
proc arduino1_rainsensor_read { channel } {
	set reponse [arduino1_rainsensor_envoi $channel get]
	if {$reponse==""} {
		error "Pb connection"
	}
	set rep ""
	lappend rep "RainSensorTime [mc_date2iso8601 now] ISO8601 \"Date\""
	set SensorModel [lindex $reponse 7]
	set RainAnalog [lindex $reponse 1]
	set RainLastChange [lindex $reponse 3]
	set RainLastReboot [lindex $reponse 5]
	set Pluie [lindex $reponse 0]
	if {$SensorModel=="Vaisala_DRD11A"} {
		if {($RainAnalog>2.9)&&($RainLastChange>180)} {
			# --- ruse pour eviter de voir de la pluie quand il n'y en a pas !!!
			set Pluie 1
		}
	} else {
		if {($Pluie==1)&&($RainLastChange<120)&&($RainLastReboot>120)} {
			# --- Temporisation dans le cas d'une pluie goute � goute
			set Pluie 0
		}
	}
	lappend rep "Rain $Pluie logical \"1=Dry 0=Rain\""
	lappend rep "RainAnalog [lindex $reponse 1] V \"\""
	lappend rep "RainState [lindex $reponse 2] text \"\""
	lappend rep "RainLastChange [lindex $reponse 3] sec \"\""
	lappend rep "RainLastState [lindex $reponse 4] text \"Symbol of the previous state\""
	lappend rep "RainLastReboot [lindex $reponse 5] sec \"\""
	lappend rep "RainAnalogADU [lindex $reponse 6] ADU \"\""
	lappend rep "SensorModel [lindex $reponse 7] text \"Sensor model\""
   return $rep
}

# ===========================================================================
# ===========================================================================
# ====== Vantage Pro coupled to Nport IP modules
# ===========================================================================
# ===========================================================================
# vantagepronport_open 192.168.10.58 966 192.168.10.58 950

proc vantagepronport_open { ip1 port1 ip2 port2 } {
	set f [socket $ip1 $port1]
	set g [socket $ip2 $port2]
	fconfigure $f -blocking 0 -buffering none -buffersize 100000 -translation {binary binary}
	fconfigure $g -blocking 0 -buffering none -buffersize 100000 -translation {binary binary}
	# --------------------------------------------------------------
	set EthCmd "[binary format H2H2H2H2H2H2H2H2H2H2H2H2H2H2H2H2H2H2H2H2H2 2C 13 07 03 01 01 00 00 00 00 54 41 52 4F 54 43 48 49 4C 49 31]"
	binary scan $EthCmd H* chaine
	puts -nonewline $f "$EthCmd"
	after 25
	set res [read -nonewline $f]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set EthCmd "[binary format H2H2H2 30 01 10]"
	binary scan $EthCmd H* chaine
	puts -nonewline $f "$EthCmd"
	after 25
	set res [read -nonewline $f]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set EthCmd "[binary format H2H2H2H2 18 02 00 00]"
	binary scan $EthCmd H* chaine
	puts -nonewline $f "$EthCmd"
	after 25
	set res [read -nonewline $f]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set EthCmd "[binary format H2H2H2H2 10 02 07 03]"
	binary scan $EthCmd H* chaine
	puts -nonewline $f "$EthCmd"
	after 25
	set res [read -nonewline $f]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set EthCmd "[binary format H2H2H2H2 12 02 01 01]"
	binary scan $EthCmd H* chaine
	puts -nonewline $f "$EthCmd"
	after 25
	set res [read -nonewline $f]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set EthCmd "[binary format H2H2H2H2 12 02 01 01]"
	binary scan $EthCmd H* chaine
	puts -nonewline $f "$EthCmd"
	after 25
	set res [read -nonewline $f]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set EthCmd "[binary format H2H2H2H2 10 02 07 03]"
	binary scan $EthCmd H* chaine
	puts -nonewline $f "$EthCmd"
	after 25
	set res [read -nonewline $f]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set EthCmd "[binary format H2H2H2H2H2H2 11 04 00 00 00 00]"
	binary scan $EthCmd H* chaine
	puts -nonewline $f "$EthCmd"
	after 25
	set res [read -nonewline $f]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set EthCmd "[binary format H2H2H2H2 18 02 00 00]"
	binary scan $EthCmd H* chaine
	puts -nonewline $f "$EthCmd"
	after 25
	set res [read -nonewline $f]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set EthCmd "[binary format H2H2H2 32 01 00]"
	binary scan $EthCmd H* chaine
	puts -nonewline $f "$EthCmd"
	after 25
	set res [read -nonewline $f]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set EthCmd "[binary format H2H2H2H2 12 02 01 01]"
	binary scan $EthCmd H* chaine
	puts -nonewline $f "$EthCmd"
	after 25
	set res [read -nonewline $f]
	binary scan $res H* chaine
	return [list $f $g]
}

proc vantagepronport_read { f g } {
	# --------------------------------------------------------------
	# Debut Lecture de info meteo
	# --------------------------------------------------------------
	after 50
	# --------------------------------------------------------------
	set EthCmd "[binary format H2 0a]"
	binary scan $EthCmd H* chaine
	puts -nonewline $g "$EthCmd"
	after 50
	set res [read -nonewline $g]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set EthCmd "[binary format H2 0a]"
	binary scan $EthCmd H* chaine
	puts -nonewline $g "$EthCmd"
	after 50
	set res [read -nonewline $g]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set EthCmd "[binary format H2H2H2H2H2H2H2 4c 4f 4f 50 20 31 0a]"
	binary scan $EthCmd H* chaine
	puts -nonewline $g "$EthCmd"
	after 3000
	set res [read -nonewline $g]
	binary scan $res H* chaine
	# --------------------------------------------------------------
	set tempint -1000
	set tempext -1000
	set pression -1000
	set humext -1000
	set dewtemp -1000
	set dirvent -1000
	set pcard -1000
	set calcul -1000
	binary scan $res H6a1a1a1c1c1s1s1s1c1s1c1c1s1c7c4c4c1H* x x0 x1 x2 x3 x4 x5 pression tempint humint tempext vitvent x6 dirvent x7 x8 x9 humext ch
	if {[info exists x0]==0} {
	   error "x0 does not exists."
	}            
	if {$x0!="L"} { 
	   error "x0=\"$x0\" instead L."
	}            
	set er [catch {
	   set tempint [expr ($tempint/10. -32)*5./9.]
	   set tempext [expr ($tempext/10. -32)*5./9.]
	   set pression [expr $pression*0.0338640344967]
	   set calcul "expr pow($humext/100.,1./8.)*(112.+(0.9*$tempext))+(0.1*$tempext)-112."
	   set dewtemp [expr pow($humext/100.,1./8.)*(112.+(0.9*$tempext))+(0.1*$tempext)-112.]
	   if {$dirvent<22.5} {
	      set pcard "S"
	   } elseif { $dirvent< 67.5} {
	      set pcard "SW"
	   } elseif { $dirvent<112.5} {
	      set pcard "W"
	   } elseif { $dirvent<157.5} {
	      set pcard "NW"
	   } elseif { $dirvent<202.5} {
	      set pcard "N"
	   } elseif { $dirvent<247.5} {
	      set pcard "NE"
	   } elseif { $dirvent<292.5} {
	      set pcard "E"
	   } elseif { $dirvent<337.5} {
	      set pcard "SE"
	   } else {
	      set pcard "S"
	   }
	   set dirvent [expr $dirvent+180]
	   if {$dirvent>360} {
	      set dirvent [expr $dirvent-360]
	   }
	} ms ]
	if {$er==1} {
	   error "Bad read ($ms)"
	}
	set resultat ""
	set er [catch {
	   set res [mc_date2ymdhms now]
	   set month [lindex $res 1]
	   set day [lindex $res 2]
	   set year [lindex $res 0]
	   set hour [lindex $res 3]
	   set min [lindex $res 4]
	   set res "$month $day $year $hour $min"
		set date "[format %04d $year]-[format %02d $month]-[format %02d $day]T[format %02d $hour]:[format %02d $min]:00"
	   lappend resultat [list StationTime $date ISO8601 "Date of the last measurement"]
	   lappend resultat [list OutsideTemp [format %.1f $tempext] Celcius ""]
	   lappend resultat [list InsideTemp [format %.1f $tempint] Celcius ""]
	   lappend resultat [list OutsideHumidity [format %.1f $humext] Percent ""]
	   lappend resultat [list Barometer [format %.1f $pression] mbar ""]
	   lappend resultat [list WindSpeed [format %.1f $vitvent] m/s ""]
	   lappend resultat [list WindDir [format %.1f $dirvent] deg "N=0, E=90"]
	   lappend resultat [list WindDirCardinal $pcard text "Cadinal symbol of wind direction"]
	   lappend resultat [list DewPt [format %.1f $dewtemp] Celcius "Dew point"]
	} ms ]
	if {$er==1} {
	   error "Bad date ($ms)"
	}
	return $resultat
}

# ===========================================================================
# ===========================================================================
# ====== Boltwood Cloud Sensor driven by Clarity.exe
# ===========================================================================
# ===========================================================================
# Install the software Clarity.exe and configure it to generate a text file

proc boltwood_open { } {
   set process_name "Clarity.exe"
   package require twapi
   set res [twapi::get_process_ids -glob -name "$process_name"]
   if {[llength $res]==0} {
      after 100
      set priority normal
      set texte "eval \{package require twapi ;  set path \"C:/Program Files/BoltwoodSystems/Clarity\" ; set res \[twapi::create_process \"\${path}/$process_name\" -startdir \"\${path}\" -detached 1 -showwindow normal -priority $priority \]\}"
      set err [catch {eval $texte} msg]
   }
}

proc boltwood_read { filename } {
	set err [catch {file copy -force -- "$filename" cloudsensor.txt} msg]
	if {$err==1} {
	   gren_info "[mc_date2iso8601 now] $thisproc : ERROR $msg"
   }
	set err [catch {
		set f [open cloudsensor.txt r]
		set datas [read $f]
		close $f
	} msg ]
	if {$err==0} {
		# 2008-10-11 10:30:15 C  -22.6  23.4  30.4   0 0 00004 039732.43767 1
		# set datas {2008-10-14 20:30:30 C  -19.1  12.2  16.1   3 0 00004 039735.85451 2}
	   #gren_info "[mc_date2iso8601 now] $thisproc : datas=$datas"
		set textes ""
		set texte "CloudStationTime [lindex $datas 0]T[lindex $datas 1] ISO8601 \"Date of the last measurement\""
		lappend textes $texte		
		set texte "CloudSkyTemp [lindex $datas 3] Celcius \"\""
		lappend textes $texte
		set texte "CloudInsideTemp [lindex $datas 4] Celcius \"\""
		lappend textes $texte		
		set texte "CloudOutsideTemp [lindex $datas 5] Celcius \"\""
		lappend textes $texte		
		set texte "Heater [lindex $datas 6] percent \"\""
		lappend textes $texte
		if {[lindex $datas 7]==0} {
			set texte "CloudWetFlag Wet text \"A word that describes water conditions\""
		} else {
			set texte "CloudWetFlag Dry text \"A word that describes water conditions\""
		}
		lappend textes $texte
		set res [string trimleft [lindex $datas 8] 0]
		if {$res==""} {
			set res 0
		}
		set texte "CloudSinceValid $res logical \"=1 if data are valid\""
		lappend textes $texte
		set skycond [lindex $datas 10]
		if {$skycond==0} {
			set texte "CloudSkyCondition Unknown text \"A word that describes sky conditions\""
		} elseif {$skycond==1} {
			set texte "CloudSkyCondition Clear text \"A word that describes sky conditions\""
		} elseif {$skycond==2} {
			set texte "CloudSkyCondition Cloudy text \"A word that describes sky conditions\""
		} elseif {$skycond==3} {
			set texte "CloudSkyCondition VeryCloudy text \"A word that describes sky conditions\""
		} elseif {$skycond==4} {
			set texte "CloudSkyCondition Rain text \"A word that describes sky conditions\""
		}
		lappend textes $texte
		set msg $textes
		set err 0
   }
   return $textes
}

# ===========================================================================
# ===========================================================================
# ====== Lacrosse driver by fetch3600
# ===========================================================================
# ===========================================================================
# Install the software fetch3600 in the bin folder of AudeLA

proc fetch3600_open { port } {
	global audace
	if {($::tcl_platform(os) != "Linux")} {
		# --- We kill the instance of the software HeavyWeather if it exists
		set pids [twapi::get_process_ids]
		set exe "HeavyWeather.exe"
		foreach pid $pids {
			set res [twapi::get_process_info $pid -name]
			set name [lindex $res 1 end]
			set k [lsearch -exact "${exe}" $name]
			if {$k>=0} {
				twapi::end_process $pid -force
			   gren_info "[mc_date2iso8601 now] $thisproc : Delete $exe (PID=$pid)"
			}
		}
	}
	# === On rempli la liste ros(gardien,private,val_status)
	# --- meteo
	set ext .exe
	if { $::tcl_platform(os) == "Linux" } {
		set ext ""
	}
	#
	set textes ""
	append textes "# open3600.conf\n"
	append textes "#\n"
	append textes "# Configuration files for open3600 weather station tools\n"
	append textes "#\n"
	append textes "# Default locations in which the programs will search for this file: \n"
	append textes "# Programs search in this sequence:\n"
	append textes "#  1. Path to config file including filename given as parameter (not supported by all tools)\n"
	append textes "#  2. ./open3600.conf (current working directory)\n"
	append textes "#  3. /usr/local/etc/open3600.conf (typical Linux location)\n"
	append textes "#  4. /etc/open3600.conf (typical Linux location)\n"
	append textes "#\n"
	append textes "# All names are case sensitive!!!\n"
	append textes "\n"
	append textes "\n"
	append textes "# Set to your serial port and time zone\n"
	append textes "# For Windows use COM1, COM2, COM2 etc\n"
	append textes "# For Linux use /dev/ttyS0, /dev/ttyS1 etc\n"
	append textes "\n"
	append textes "SERIAL_DEVICE                 $port	  # /dev/ttyS0, /dev/ttyS1, COM1, COM2 etc\n"
	append textes "TIMEZONE                      1           # Hours Relative to UTC. East is positive, west is negative\n"
	append textes "\n"
	append textes "\n"
	append textes "# Units of measure (set them to your preference)\n"
	append textes "# The units of measure are ignored by wu3600 and cw3600 because both requires specific units\n"
	append textes "\n"
	append textes "WIND_SPEED                    km/h         # select MPH (miles/hour), m/s, or km/h\n"
	append textes "TEMPERATURE                   C           # Select C or F\n"
	append textes "RAIN                          mm          # Select mm or IN\n"
	append textes "PRESSURE                      hPa         # Select hPa, mb or INHG\n"
	append textes "\n"
	append textes "# Debug level\n"
	append textes "LOG_LEVEL 1				  # 0 - no debug output, 5 - most debug output\n"
	append textes " \n"
	append textes "#### Citizens Weather variables (used only by cw3600)\n"
	append textes "# Format for latitude is\n"
	append textes "# \[2 digit degrees\]\[2 digit minutes\].\[2 decimals minutes - NOT seconds\]\[N for north or S for south\]\n"
	append textes "# Format for longitude is\n"
	append textes "# \[3 digit degrees\]\[2 digit minutes\].\[2 decimals minutes - NOT seconds\]\[E for east or W for west\]\n"
	append textes "# Use leading zeros to get the format ####.##N (lat) and #####.##E (long)\n"
	append textes "\n"
	append textes "#CITIZEN_WEATHER_ID            CW0000      # CW0000 should be replaced by HAM call or actual CW number\n"
	append textes "#CITIZEN_WEATHER_LATITUDE      5540.12N    # DDMM.mmN or S - example 55 deg, 40.23 minutes north\n"
	append textes "#CITIZEN_WEATHER_LONGITUDE     01224.60E   # DDDMM.mmE or W - example 12 deg, 24.60 minutes east\n"
	append textes "\n"
	append textes "#APRS_SERVER   aprswest.net         23     # These are the APRS servers and ports for\n"
	append textes "#APRS_SERVER   indiana.aprs2.net    23     # Citizens Weather reporting.\n"
	append textes "#APRS_SERVER   newengland.aprs2.net 23     # They they are tried in the entered order\n"
	append textes "#APRS_SERVER   aprsca.net           23     # you may enter up to 5 alternate servers\n"
	append textes "\n"
	append textes "\n"
	append textes "#### WEATHER UNDERGROUND variables (used only by wu3600)\n"
	append textes "\n"
	append textes "#WEATHER_UNDERGROUND_ID        WUID        # ID received from Weather Underground\n"
	append textes "#WEATHER_UNDERGROUND_PASSWORD  WUPASSWORD  # Password for Weather Underground\n"
	append textes "\n"
	append textes "\n"
	append textes "### MYSQL Settings (only used by mysql3600)\n"
	append textes "\n"
	append textes "MYSQL_HOST              localhost         # Localhost or IP address/host name\n"
	append textes "MYSQL_USERNAME          open3600          # Name of the MySQL user that has access to the database\n"
	append textes "MYSQL_PASSWORD          mysql3600         # Password for the MySQL user\n"
	append textes "MYSQL_DATABASE          open3600          # Named of your database\n"
	append textes "MYSQL_PORT              0                 # TCP/IP Port number. Zero means default\n"
	append textes "\n"
	append textes "#PGSQL_CONNECT		hostaddr='127.0.0.1'dbname='open3600'user='postgres'password='sql' # Connection string\n"
	append textes "#PGSQL_TABLE		weather           # Table name\n"
	append textes "#PGSQL_STATION		open3600          # Unique station id\n"
	append textes "	\n"
	set f [open $audace(rep_install)/open3600.conf w]
	puts -nonewline $f $textes
	close $f
	return ""
}	
	
proc fetch3600_read { } {
	global audace
	# --- We kill the current instance of the software fetch if needed
	if {($::tcl_platform(os) != "Linux")} {
		set pids [twapi::get_process_ids]
		set exe "fetch3600${ext}"
		foreach pid $pids {
			set res [twapi::get_process_info $pid -name]
			set name [lindex $res 1 end]
			set k [lsearch -exact "${exe}" $name]
			if {$k>=0} {
				twapi::end_process $pid -force
			   gren_info "[mc_date2iso8601 now] $thisproc : Delete $exe (PID=$pid)"
			}
		}
	}
	#
	set exe $audace(rep_install)/bin/fetch3600${ext}
	set err [catch {exec $exe} msg]
	if {$msg=="Unable to open serial device"} {
		return ""
	}
	set keyword [lindex $msg 0]
	if {$keyword=="Date"} {
		set err 0
	}
	if {($err==0)&&($msg!="")} {
		set lignes [split $msg \n]
		set textes ""
		set liste $ros(gardien,private,desc_status)
		foreach desc_status $liste {
			set meteo [lindex $desc_status 1] 
			if {$meteo!="meteo"} {
	   		continue
			}
			set desc [lindex $desc_status 0] 
			foreach ligne $lignes {
				set keyword [lindex $ligne 0]
				set value [lindex $ligne 1]
				if {$keyword=="Tendency"} {
	   			set ligne [lrange $ligne 1 end]
	   			set keyword [lindex $ligne 0]
	   			set value [lindex $ligne 1]
		      }
				#gren_info "key=$keyword value=$value"
				if {($keyword=="Date")&&($desc=="StationTime")} {
					regsub -all -- "-" "${value}" " " date
					set j [string trimleft [lindex $date 0] 0]
					set m [string trimleft [lindex $date 1] 0]
					set a [lindex $date 2]
					if {$m=="Jan"} { set mm 1 }
					if {$m=="Feb"} { set mm 2 }
					if {$m=="Mar"} { set mm 3 }
					if {$m=="Apr"} { set mm 4 }
					if {$m=="May"} { set mm 5 }
					if {$m=="Jun"} { set mm 6 }
					if {$m=="Jul"} { set mm 7 }
					if {$m=="Aug"} { set mm 8 }
					if {$m=="Sep"} { set mm 9 }
					if {$m=="Oct"} { set mm 10 }
					if {$m=="Nov"} { set mm 11 }
					if {$m=="Dec"} { set mm 12 }
					set texte "StationTime [format %04d $a]-[format %02d $mm]-[format %02d $j]"
					continue
				}
				if {($keyword=="Time")&&($desc=="StationTime")} {
					append texte "T${value}"
					lappend textes $texte
					break
				}
				if {($keyword=="Ti")&&($desc=="InsideTemp")} {
					set texte "InsideTemp ${value}"
					lappend textes $texte
					break
				}
				if {($keyword=="DTimin")&&($desc=="InsideTemp")} {
					if {$value=="00-00-2000"} {
						set n [llength $textes]
						set newkey [lindex [lindex $textes [expr $n-1]] 0]
						set textes [lrange $textes 0 [expr $n-2]]
						set texte "$newkey -1"
						lappend textes $texte
	   				break
					}
				}
				if {($keyword=="To")&&($desc=="OutsideTemp")} {
					set texte "OutsideTemp ${value}"
					lappend textes $texte
	   			break
			   }
				if {($keyword=="DTomin")&&($desc=="OutsideTemp")} {
					if {$value=="00-00-2000"} {
						set n [llength $textes]
						set newkey [lindex [lindex $textes [expr $n-1]] 0]
						set textes [lrange $textes 0 [expr $n-2]]
						set texte "$newkey -1"
						lappend textes $texte
	   				break
					}
				}
				if {($keyword=="RHi")&&($desc=="InsideHumidity")} {
					set texte "InsideHumidity ${value}"
					lappend textes $texte
	   			break
				}
				if {($keyword=="DRHimin")&&($desc=="InsideHumidity")} {
					if {$value=="00-00-2000"} {
						set n [llength $textes]
						set newkey [lindex [lindex $textes [expr $n-1]] 0]
						set textes [lrange $textes 0 [expr $n-2]]
						set texte "$newkey -1"
						lappend textes $texte
	   				break
					}
				}
				if {($keyword=="RHo")&&($desc=="OutsideHumidity")} {
	   			set errv [catch {expr -1*$value} msgv ]
	   			if {$errv==1} {
	   			   set value 50 ; # for tests
				   } else {
	   			   if {($value<0)||($value>100)} {
	      			   set value 50 ; # for tests
	   			   }
				   }
					set texte "OutsideHumidity ${value}"
					lappend textes $texte
	   			break
				}
				if {($keyword=="DRHomin")&&($desc=="OutsideHumidity")} {
					if {$value=="00-00-2000"} {
						set n [llength $textes]
						set newkey [lindex [lindex $textes [expr $n-1]] 0]
						set textes [lrange $textes 0 [expr $n-2]]
						set texte "$newkey -1"
						lappend textes $texte
	   				break
					}
				}
				if {($keyword=="WS")&&($desc=="WindSpeed")} {
	   			# x=[153 256 356] ; y=[1.4 5.0 9.3] ; p=polyfit(x,y,1)
	   			set errv [catch {expr 0.0389*$value-4.6853} msgv ]
	   			if {$errv==1} {
	   			   set value 0 ; # for tests
				   } else {
	   			   set value $msgv
	   			   if {$value<0} {
	      			   set value 0
	   			   }
				   }
					set texte "WindSpeed ${value}"
					lappend textes $texte
	   			break
				}
				if {($keyword=="DIRtext")&&(($desc=="WindDir")||($desc=="WindDirCardinal"))} {
					set wind_dir "Unknown"
					if {$value=="N"}   { set wind_dir 0 }
					if {$value=="NNE"} { set wind_dir [expr 360./16*1] }
					if {$value=="NE"}  { set wind_dir [expr 360./16*2] }
					if {$value=="ENE"} { set wind_dir [expr 360./16*3] }
					if {$value=="E"}   { set wind_dir [expr 360./16*4] }
					if {$value=="ESE"} { set wind_dir [expr 360./16*5] }
					if {$value=="SE"}  { set wind_dir [expr 360./16*6] }
					if {$value=="SSE"} { set wind_dir [expr 360./16*7] }
					if {$value=="S"}   { set wind_dir [expr 360./16*8] }
					if {$value=="SSW"} { set wind_dir [expr 360./16*9] }
					if {$value=="SW"}  { set wind_dir [expr 360./16*10] }
					if {$value=="WSW"} { set wind_dir [expr 360./16*11] }
					if {$value=="W"}   { set wind_dir [expr 360./16*12] }
					if {$value=="WNW"} { set wind_dir [expr 360./16*13] }
					if {$value=="NW"}  { set wind_dir [expr 360./16*14] }
					if {$value=="NNW"} { set wind_dir [expr 360./16*15] }
					if {($desc=="WindDir")} {
	   				set texte "WindDir $wind_dir"
	   				lappend textes $texte
	   				break
					}
					if {($desc=="WindDirCardinal")} {
	   				set texte "WindDirCardinal ${value}"
	   				lappend textes $texte		
	   				break
				   }
				}	
				if {($keyword=="RP")&&($desc=="Barometer")} {
					set texte "Barometer ${value}"
					lappend textes $texte		
	   			break
				}				
				if {($keyword=="R1h")&&($desc=="RainRate")} {
					set texte "RainRate ${value}"
					lappend textes $texte
	   			break
				}
			}
		}
		#set value 0
		#set texte "RainRate ${value}"
		#lappend textes $texte		
		set msg $textes
		#gren_info "textes=$textes"
		set err 0
	}
	return $msg
}

# ===========================================================================
# ===========================================================================
# ====== Simulation
# ===========================================================================
# ===========================================================================
proc simulationmeteo_open { } {
	return ""
}

proc simulationmeteo_read { } {
	set SkyCover Clear
	set SkyTemp -20
	set OutTemp 10
	set WinDir 0
	set WinSpeed 2
	set Water Dry
	set textes ""
	set texte "SkyCover $SkyCover text \"Sky cover\""
	lappend textes $texte		
	set texte "SkyTemp $SkyTemp Celcius \"Sky temperature\""
	lappend textes $texte		
	set texte "OutTemp $OutTemp Celcius \"Outside temperature\""
	lappend textes $texte		
	set texte "WinDir $WinDir deg \"0=North 90=east\""
	lappend textes $texte		
	set texte "WinSpeed $WinSpeed m/s \"Wind speed\""
	lappend textes $texte		
	set texte "Water $Water text \"Dry or Wet or Rain\""
	lappend textes $texte		
	return $textes
}
