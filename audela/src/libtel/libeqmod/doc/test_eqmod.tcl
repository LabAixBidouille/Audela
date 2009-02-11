# TCL Test for EQ_MOD protocol

proc envoi { f msg } {
   puts -nonewline $f "$msg\r" ; flush $f
   ::console::affiche_resultat "ENVOIE <$msg>\n"
   after 200
   set msg [read $f]
   ::console::affiche_resultat "RECOI <$msg>\n"
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

set f [open com1 w+]
fconfigure $f -mode "9600,n,8,1" -buffering none -translation {binary binary} -blocking 0
envoi $f ":e1" ; # 67585
envoi $f ":e2" ; # 67585
set res [envoi $f ":a1"] ; # 9024000.0 micropas pour 360°
set radec_position_conversion [expr [decode [string range $res 1 6]]/360.] ; ::console::affiche_resultat "CODEURS = $radec_position_conversion (ADU/deg)\n"
envoi $f ":a2" ; # 9024000.0 micropas pour 360°
envoi $f ":b1" ; # 64935 (special)
envoi $f ":b2" ; # 64935
envoi $f ":g1" ; # 10 (1=hemis-N 0=track+)
envoi $f ":g2" ; # 10 (1=hemis-N 0=track+)
envoi $f ":s1" ; # 67585 (worm) => micropas pour un tour de roue (environ 2.5°)
envoi $f ":s2" ; # 67585

# --- Init le codeur RA = 0
envoi $f ":K1" ; # Kill le mouvement du moteur RA(=1)
envoi $f ":f1" ; # Lecture etat du moteur
envoi $f ":E1[encode 0]"
set res [envoi $f ":j1"]
set res [decode [string range $res 1 6]] ; ::console::affiche_resultat "CODEUR = $res ADU ([expr $res/$radec_position_conversion] deg)\n"
envoi $f ":F1" ; # Puissance sur le moteur

# --- Mouvement incrémental sur le codeur RA = +10° (=sens diurne) avec pente à 70% du chemin.
envoi $f ":K1"
set res [envoi $f ":f1"]
set res [envoi $f ":j1"]
set res [decode [string range $res 1 6]] ; ::console::affiche_resultat "CODEUR = $res ADU ([expr $res/$radec_position_conversion] deg)\n"
envoi $f ":G120" ; # Setup : [1] 1=Ra 2=DEC [2]=1 MOVE lent, [2]=2 GO-OFFSET, [2]=1 MOVE rapide, [3] 0=hemis-N et +, 1=hemis-N et -, 2=hemis-S et +, 3=hemis-S et -
envoi $f ":H1[encode [expr int($radec_position_conversion*10)]]" ; # offset de position a effectuer
envoi $f ":M1[encode 70]" ; # acceleration
envoi $f ":J1" ; # start the motion
set t0 [clock seconds]
set sortie 0
while {$sortie==0} {
   after 1000
   set res [envoi $f ":j1"]
   set res [decode [string range $res 1 6]] ; ::console::affiche_resultat "CODEUR = $res ADU ([expr $res/$radec_position_conversion] deg)\n"
   set res [envoi $f ":f1"]
   set ismoving [string index $res 2]
   if {$ismoving==0} {
      set sortie 1
   }
   set dt [expr [clock seconds]-$t0]
   if {$dt>30} {
      set sortie 2
   }
}

