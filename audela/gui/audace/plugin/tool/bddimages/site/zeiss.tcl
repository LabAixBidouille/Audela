proc dateobs {tabkey} {

  #	  0         1         2   
  #       0123456789012345678901
  # date <2006-06-23T20:22:36.08>

  foreach keyval $tabkey {

    set key [lindex $keyval 0]
    set val [lindex [lindex $keyval 1] 1]
    
    switch $key {
          "DATE" {
	    set dateobs $val
	    }
          default {
 	    }
	  }
          # fin switch
      }
      # fin foreach

    set annee	[string range $dateobs 0 3]
    set mois	[string range $dateobs 5 6]
    set jour	[string range $dateobs 8 9]
    set heure	[string range $dateobs 11 12]
    set minute	[string range $dateobs 14 15]
    set seconde  [string range $dateobs 17 end]

    set dateiso "$annee-$mois-$jour\T$heure:$minute:$seconde"

return [list 0 $dateiso]
}


