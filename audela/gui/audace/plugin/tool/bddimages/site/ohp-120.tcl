proc dateobs {tabkey} {

  #	  0         1         2   
  #       0123456789012345678901
  # date <2006-06-23T20:22:36.08>

  foreach keyval $tabkey {

    set key [lindex $keyval 0]
    set val [lindex [lindex $keyval 1] 1]
    
    
    switch $key {
          "DATE-OBS" {
	    set dateobs $val
	    }
          "TM-START" {
	    set duree [string trim $val]
 	    }
          default {
 	    }
	  }
          # fin switch
      }
      # fin foreach

    set annee   [string range $dateobs 6 9]
    set mois    [string range $dateobs 3 4]
    set jour    [string range $dateobs 0 1]
    set heure   [expr int($duree / 3600)]
    set minute  [expr int($duree / 60 - $heure * 60)]
    set seconde [expr $duree - $heure * 3600 - $minute * 60]

    set dateiso "$annee-$mois-$jour\T$heure:$minute:$seconde"

return [list 0 $dateiso]
}


