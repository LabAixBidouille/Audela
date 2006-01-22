#
# Fichier : agUNIV.tcl
# Description : Panneau pour executer l'autoguidage d'un telescope
# Auteur : Pierre THIERRY
# $Id: agUNIV.tcl,v 1.3 2006-01-22 14:32:59 michelpujol Exp $
# tension d'alimentation des moteurs 5V
# VITESSE 1 im sec en binning 2x2 webcam longue pose à 0.5 sec de pose
# Le pc d'acquisition du ciel profond envoie au pc d'autoguidage 
# un bit 1 (début de pose) et 0 (fin depose) sur le bit 6 du port com


global conf
global caption
global color
global infos
set caption(acqcolor,interro)      "?"
#--- Definition des couleurs 
  set color(back)       #56789A
  set color(text)       #FFFFFF 
  set color(back_image) #123456 
  set color(rectangle)  #0000EF 
  set color(scroll)     #BBBBBB 

   set caption(acqcolor,fonc_titre3)   "AUTOGUIDAGE BINNING 2x2 1 image/sec"
   set caption(acqcolor,fonc_comment5)   "avant de lancer ce script acquérir une image bin 2x2 et tracer un large cadre autour de l'etoile guide"
   set caption(acqcolor,fonc_focale_guide)   "Focale de guidage 1600 ou 1200"
   set caption(acqcolor,fonc_focale_imagerie)   "Focale d'imagerie 200 800 1600"
   set caption(acqcolor,fonc_distance_equat)   "Multiplicateur des rappels en alpha base 2 4 6 "
   set caption(acqcolor,fonc_rappels_delta)   "Multiplicateur des rappels en delta base 2 5 9 "
   set caption(acqcolor,fonc_executer)   "Exécuter"
   set caption(acqcolor,fonc_decallage_images)   "nombre de pixels de décallage images finales "
   set caption(acqcolor,fonc_tolerance)   "nombre de pixels de tolerance de guidage =+/- "

# --- position initiale
#set res [buf1 centro $box]
#set x0 [lindex $res 0]
#set y0 [lindex $res 1]
#set n0 [expr $infos(decallage)*$infos(focale_guide)/$infos(focale_acq)/2]
#::console::affiche_resultat "x0=$x0 y0=$y0"
# variables de décallage des poses

# a nombre de poses lancées par le pc acq
# b acteur de changement de sens 
# c valeur du prochain chagement de sens en alpha
# d valeur duprochain changement de sens en delta
# w valeur du bit combit 1.6 du pc autoguidage en debut de correction
# w1 valeur du bit combit 1.6 du pc autoguidage en millieu de correction
# w2 variable de changement d'état du bit combit 1.6 du pc autoguidage
# u et v  valeurs n0  ou -n0 à ajouter à x0 et y0 pour décaller les poses entre chaque prise de vue.
# n nombre de pixels de décallage du guidage en fonction de la focale de prise de vue,
      #de la focale de guidage,et dunombre de pixels sur l'image finale
# k1 variable d'arrêt du script si aucune pose d'acquisition n'est lancée au bout de 30 secondes
# m coefficient multiplicateur de durées de rappel delta
# m1 m2 m3 durée des rappels en delta
# P coefficient multiplicateur de durées de rappel alpha 
   #en fonction de la déclinaison  la loi theorique est la suivante: de 0 (equateur) à 30° P=1 de 31 à 50 P=1.3 de 51 à 65 P=2    
   # de 66 à 75 p=3 de 76 à 81 P=6 de 82 à 84 P=8 de 85 à 87 P=15 88 et plus P=30
# p1 p2 p3 durée des rappels en alpha
# e demi tolerance de guidage 
# e1 e2 e3 demi tolerance des rappels
# e1 = e * foc guid/foc acq/fact bining
# x1 abcisse de chaque pose
# y1 ordonnée de chaque pose

# initialisation des variables
   #   set a 1
   #   set b 1
   #   set c 2
   #   set d 3
   #   set u $n0
   #   set v -$n0
   #   set x1 $x0
   #   set y1 $y0
   #   set w 0 
   #   set w1 0
   #   set k1 100000
   
namespace eval ::agUNIV {
   global infos
   
}   
   
proc ::agUNIV::init { } {
   global infos
   set infos(decallage)      "2"
   set infos(focale_guide)   "1900.0"
   set infos(focale_acq)     "1900.0"
   set infos(asc_droite)     "1.0" 
   set infos(declinaison)    "1.0" 
   set infos(tolerance)      "0.7" 


   set infos(dx)      "0"     
   set infos(dy)      "0"     
}
  
proc ::agUNIV::suivi { dx dy } {
   global infos

   set e $infos(tolerance)
   set e1 [expr $infos(tolerance)*$infos(focale_guide)/$infos(focale_acq)/2]
   set e2 [expr $e1*1.0]
   set e3 [expr $e1*3.0]
   set e4 [expr $e1*7.0]

   set p [expr $infos(asc_droite) * abs($dx) + 2 ]
   set p1 [expr 0.3 * $p]
   set p2 [expr 0.8 * $p]
   set p3 [expr 0.8 * $p]
   set p4 [expr 1.0 * $p]

   set m [expr $infos(declinaison) * abs($dy) + 2 ]
   set m1 [expr 0.3 * $m]
   set m2 [expr 0.4 * $m]
   set m3 [expr 0.5 * $m]
   set m4 [expr 0.5 * $m]

##console::disp "dx=$dx e1=$e1 p1=$p1 dy=$dy e2=$e2 m1=$m1  "  

   set delay 0
  
   if { $dx > 0 && $infos(dx) > 0 } {
      if { $dx > $e4 } {
         set delay $p4
      } elseif { $dx > $e3 } {
         set delay $p3
      } elseif { $dx > $e2 } {
         set delay $p2
      } elseif { $dx > $e1 } {
         set delay $p1
      }
      console::disp "del=$delay " 
      if { $delay > 0 } {
         console::disp "=>w " 
         ::telescope::move w  
         after [expr int($delay)]
         ::telescope::stop w
      } 
   } 
   if { $dx < 0 && $infos(dx) < 0 } {
      if { $dx < -$e4 } {
         set delay $p4
      } elseif { $dx < -$e3 } {
         set delay $p3
      } elseif { $dx < -$e2 } {
         set delay $p2
      } elseif { $dx < -$e1 } {
         set delay $p1
      }
      console::disp "del=$delay " 
      if { $delay > 0 } {
         console::disp "=>e " 
         ::telescope::move e
         after [expr  int($delay)]
         ::telescope::stop e
      }
   }

   set infos(dx) $dx
   
   set delay 0
   if { $dy > 0 && $infos(dy) >0 } {
      if { $dy > $e4 } {
         set delay $m4
      } elseif { $dy > $e3 } {
         set delay $m3
      } elseif { $dy > $e2 } {
         set delay $m2
      } elseif { $dy > $e1 } {
         set delay $m1
      }
      console::disp "del=$delay " 
      if { $delay > 0 } {
         console::disp "=>s " 
         ::telescope::move s  
         after [expr int($delay)]
         ::telescope::stop s
      } 
   } 
   
   if { $dy < 0 && $infos(dy) < 0 } {
      if { $dy < -$e4 } {
         set delay $m4
      } elseif { $dy < -$e3 } {
         set delay $m3
      } elseif { $dy < -$e2 } {
         set delay $m2
      } elseif { $dy < -$e1 } {
         set delay $m1
      }
      console::disp "del=$delay " 
      if { $delay > 0 } {
         console::disp "=>n " 
         ::telescope::move n
         after [expr int($delay)]
         ::telescope::stop n
      }
   }
   console::disp "\n" 

   set infos(dy) $dy
   
   ##if { $decalage == "1" } {
   ##   ::Autoguider::decaler 
   ##}

}
proc ::Autoguider::decaler { } {

      # Incrémentation du compteur de pose et décallage de la pose 
      if {$w2==1}  {
         set a [expr $a+1]
         set k1 $k
         set x1 [expr $x1+$u]
         set y1 [expr $y1+$v]
         #::console::affiche_resultat "x1=$x1 y1=$y1"
         ::console::disp "x1=$x1 y1=$y1 u=$u  v=$v "
      }
   
      # Calcul des nouvelles positions des poses en spirale ( illimité)
      if {$a==$c}  {
         set u -$u  
         set  c [expr $c+2*$b] 
      }

      if {$a==$d}  {
         set v -$v  
         set  d [expr $d+2*$b+1] 
         set b [expr $b+1]
      }
   
   # Incrémentation du compteur de pose et décallage de la pose 
   if {$w2==1}  {
      set a [expr $a+1]
      set k1 $k
      set x1 [expr $x1+$u]
      set y1 [expr $y1+$v]
      ::console::disp "x1=$x1 y1=$y1 u=$u  v=$v "
   }

   # procédure d'arrêt  au bout  de 30 secondes sans nouvelle pose
   if {$w2==-1}  {
      set k1 100000
   }

   if {[expr $k-$k1]>10}  {
      set k  100000
   }
   # Calcul des nouvelles positions des poses en spirale ( illimité)
   if {$a==$c}  {
      set u -$u  
      set  c [expr $c+2*$b] 
   }
   if {$a==$d}  {
      set v -$v  
      set  d [expr $d+2*$b+1] 
      set b [expr $b+1]
   }

   if { $dx < -$e1 } {

      combit [string range $conf(telcom,port) 3 3 ] 7 0
      combit [string range $conf(telcom,port) 3 3 ] 3 1               
      after $pp1
        combit [string range $conf(telcom,port) 3 3 ] 3 0 
      combit [string range $conf(telcom,port) 3 3 ] 7 0

   }

   if { $dx < -$e2 } {

      combit [string range $conf(telcom,port) 3 3 ] 7 0
      combit [string range $conf(telcom,port) 3 3 ] 3 1               
      after $pp2
      combit [string range $conf(telcom,port) 3 3 ] 3 0 
      combit [string range $conf(telcom,port) 3 3 ] 7 0

   }

   if { $dx < -$e3 } {
      combit [string range $conf(telcom,port) 3 3 ] 7 0
      combit [string range $conf(telcom,port) 3 3 ] 3 1               
      after $pp3
      combit [string range $conf(telcom,port) 3 3 ] 3 0 
      combit [string range $conf(telcom,port) 3 3 ] 7 0

   }

   if { $dx < -$e4 } {
      combit [string range $conf(telcom,port) 3 3 ] 7 0
      combit [string range $conf(telcom,port) 3 3 ] 3 1               
      after $pp4
      combit [string range $conf(telcom,port) 3 3 ] 3 0 
      combit [string range $conf(telcom,port) 3 3 ] 7 0
   }

   if { $dy > $e1 } {
      combit [string range $conf(telcom,port) 3 3 ] 7 1
      combit [string range $conf(telcom,port) 3 3 ] 4 1           
      after $m1
      combit [string range $conf(telcom,port) 3 3 ] 4 0
      combit [string range $conf(telcom,port) 3 3 ] 7 0
   }
 
   if { $dy > $e2 } {
      combit [string range $conf(telcom,port) 3 3 ] 7 1
      combit [string range $conf(telcom,port) 3 3 ] 4 1           
      after $m2
      combit [string range $conf(telcom,port) 3 3 ] 4 0
      combit [string range $conf(telcom,port) 3 3 ] 7 0
   }
   
   if { $dy > $e3 } {
      combit [string range $conf(telcom,port) 3 3 ] 7 1
      combit [string range $conf(telcom,port) 3 3 ] 4 1           
      after $m3
      combit [string range $conf(telcom,port) 3 3 ] 4 0
      combit [string range $conf(telcom,port) 3 3 ] 7 0
   }

   if { $dy > $e4 } {
      combit [string range $conf(telcom,port) 3 3 ] 7 1
      combit [string range $conf(telcom,port) 3 3 ] 4 1           
      after $m4
      combit [string range $conf(telcom,port) 3 3 ] 4 0
      combit [string range $conf(telcom,port) 3 3 ] 7 0

   }


}

proc ::agUNIV::configure { } {
   #--- Cree la fenetre .test5 de niveau le plus haut 
   if [ winfo exists .test5 ] {
      wm withdraw .test5
      wm    deiconify .test5
      focus .test5
      return
   }
   toplevel .test5 -class Toplevel -bg $color(back) 
   wm geometry .test5 480x210+240+190 
   wm title .test5 $caption(acqcolor,fonc_titre3)
   
   #--- La nouvelle fenetre est active
   focus .test5
   
   #--- Cree un frame en haut a gauche pour les canvas d'affichage
   frame .test5.frame0 \
      -borderwidth 0 -cursor arrow -bg $color(back) 
   pack .test5.frame0 \
      -in .test5 -anchor nw -side top -expand 0 -fill x

   #--- Cree le label 'titre' 
   label .test5.frame0.lab \
      -text "$caption(acqcolor,fonc_comment5)" -bg $color(back) -fg $color(text)
   pack .test5.frame0.lab \
      -in .test5.frame0 -side top -anchor center \
      -padx 3 -pady 3  

   #--- Cree un frame 
   frame .test5.frame1 \
      -borderwidth 0 -cursor arrow -bg $color(back) 
   pack .test5.frame1 \
      -in .test5 -anchor center -side top -expand 0 -fill x
   
   #--- Cree le label
   label .test5.frame1.lab \
      -text "$caption(acqcolor,fonc_decallage_images)" -bg $color(back) -fg $color(text)
   pack .test5.frame1.lab \
      -in .test5.frame1 -side left -anchor center \
      -padx 3 -pady 3  

   #--- Cree l'entry
   entry .test5.frame1.ent \
      -textvariable infos(decallage) -width 10
   pack .test5.frame1.ent \
      -in .test5.frame1 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3  

   #--- Cree un frame 
   frame .test5.frame2 \
      -borderwidth 0 -cursor arrow -bg $color(back) 
   pack .test5.frame2 \
      -in .test5 -anchor center -side top -expand 0 -fill x
   
   #--- Cree le label
   label .test5.frame2.lab \
      -text "$caption(acqcolor,fonc_focale_guide)" -bg $color(back) -fg $color(text)
   pack .test5.frame2.lab \
      -in .test5.frame2 -side left -anchor center \
      -padx 3 -pady 3  

   #--- Cree l'entry
   entry .test5.frame2.ent \
      -textvariable infos(focale_guide) -width 10
   pack .test5.frame2.ent \
      -in .test5.frame2 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3  

   #--- Cree un frame 
   frame .test5.frame3 \
      -borderwidth 0 -cursor arrow -bg $color(back) 
   pack .test5.frame3 \
      -in .test5 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label .test5.frame3.lab \
      -text "$caption(acqcolor,fonc_focale_imagerie)" -bg $color(back) -fg $color(text)
   pack .test5.frame3.lab \
      -in .test5.frame3 -side left -anchor center \
      -padx 3 -pady 3  

   #--- Cree l'entry
   entry .test5.frame3.ent \
      -textvariable infos(focale_acq) -width 10
   pack .test5.frame3.ent \
      -in .test5.frame3 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3  

   #--- Cree un frame 
   frame .test5.frame4 \
      -borderwidth 0 -cursor arrow -bg $color(back) 
   pack .test5.frame4 \
      -in .test5 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label .test5.frame4.lab \
      -text "$caption(acqcolor,fonc_distance_equat)" -bg $color(back) -fg $color(text)
   pack .test5.frame4.lab \
      -in .test5.frame4 -side left -anchor center \
      -padx 3 -pady 3  

   #--- Cree l'entry
   entry .test5.frame4.ent \
      -textvariable infos(asc_droite) -width 10
   pack .test5.frame4.ent \
      -in .test5.frame4 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3  

   #--- Cree un frame 
   frame .test5.frame5 \
      -borderwidth 0 -cursor arrow -bg $color(back) 
   pack .test5.frame5 \
      -in .test5 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label .test5.frame5.lab \
      -text "$caption(acqcolor,fonc_rappels_delta)" -bg $color(back) -fg $color(text)
   pack .test5.frame5.lab \
      -in .test5.frame5 -side left -anchor center \
      -padx 3 -pady 3  

   #--- Cree l'entry
   entry .test5.frame5.ent \
      -textvariable infos(declinaison) -width 10
   pack .test5.frame5.ent \
      -in .test5.frame5 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3  
   ##############
   #--- Cree un frame 
   frame .test5.frame6 \
      -borderwidth 0 -cursor arrow -bg $color(back) 
   pack .test5.frame6 \
      -in .test5 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label .test5.frame6.lab \
      -text "$caption(acqcolor,fonc_tolerance)" -bg $color(back) -fg $color(text)
   pack .test5.frame6.lab \
      -in .test5.frame6 -side left -anchor center \
      -padx 3 -pady 3  

   #--- Cree l'entry
   entry .test5.frame6.ent \
      -textvariable infos(tolerance) -width 10
   pack .test5.frame6.ent \
      -in .test5.frame6 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3  
 
     
   #--- Cree le bouton 'Validation' 
   button .test5.but_valid \
      -text "$caption(acqcolor,fonc_executer)" -borderwidth 4 \
      -command { }

}
  

::agUNIV::init