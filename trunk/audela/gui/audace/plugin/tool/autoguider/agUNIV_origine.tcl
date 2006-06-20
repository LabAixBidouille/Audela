#
# Fichier : agjaz.tcl
# Description : Panneau pour executer l'autoguidage d'un telescope
# Auteur : Pierre THIERRY
# Mise a jour $Id: agUNIV_origine.tcl,v 1.2 2006-06-20 20:47:54 robertdelmas Exp $
# tension d'alimentation des moteurs 5V
# VITESSE 1 im sec en binning 2x2 webcam longue pose � 0.5 sec de pose
# Le pc d'acquisition du ciel profond envoie au pc d'autoguidage 
# un bit 1 (d�but de pose) et 0 (fin depose) sur le bit 6 du port com


global conf
global caption
global color
global infos
set caption(acqcolor,interro)		"?"
#--- Definition des couleurs 
  set color(back)       #56789A
  set color(text)       #FFFFFF 
  set color(back_image) #123456 
  set color(rectangle)  #0000EF 
  set color(scroll)     #BBBBBB 

   set caption(acqcolor,fonc_titre3)	"AUTOGUIDAGE BINNING 2x2 1 image/sec"
   set caption(acqcolor,fonc_comment5)	"avant de lancer ce script acqu�rir une image bin 2x2 et tracer un large cadre autour de l'etoile guide"
   set caption(acqcolor,fonc_focale_guide)	"Focale de guidage 1600 ou 1200"
   set caption(acqcolor,fonc_focale_imagerie)	"Focale d'imagerie 200 800 1600"
   set caption(acqcolor,fonc_distance_equat)	"Multiplicateur des rappels en alpha base 2 4 6 "
   set caption(acqcolor,fonc_rappels_delta)	"Multiplicateur des rappels en delta base 2 5 9 "
   set caption(acqcolor,fonc_executer)	"Ex�cuter"
   set caption(acqcolor,fonc_decallage_images)	"nombre de pixels de d�callage images finales "
   set caption(acqcolor,fonc_tol�rance)	"nombre de pixels de tol�rance de guidage =+/- "
   
   #--- Initialisation des variables
set infos(decallage)		"2"
set infos(focale_guide)		"3200"
set infos(focale_acq)   	"1600"
set infos(asc_droite)   	"5" 
set infos(declinaison) 		"8" 
set infos(tol�rance) 		".4" 

#--- Cree la fenetre .test5 de niveau le plus haut 
if [ winfo exists .test5 ] {
   wm withdraw .test5
   wm deiconify .test5
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
      -text "$caption(acqcolor,fonc_tol�rance)" -bg $color(back) -fg $color(text)
   pack .test5.frame6.lab \
      -in .test5.frame6 -side left -anchor center \
      -padx 3 -pady 3  

   #--- Cree l'entry
   entry .test5.frame6.ent \
      -textvariable infos(tol�rance) -width 10
   pack .test5.frame6.ent \
      -in .test5.frame6 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3  
 
     
#--- Cree le bouton 'Validation' 
button .test5.but_valid \
   -text "$caption(acqcolor,fonc_executer)" -borderwidth 4 \
   -command { 




#Pour le centroid dans une boite draguee sur l'ecran :
#-----------------------------------------------------
#set res [buf1 centro $audace(box)]
# 298.55 384.53 0.65

#Pour recuperer x et y :
#-----------------------
#set x [lindex $res 0]
#set y [lindex $res 1]


# on commence par une seule acquisition
# acq 1 2
# apres l'acqisition tu dragues la boite sur l'ecran
set box $audace(box)
# la variable box contient les coord. de la boite draguee



# --- position initiale
set res [buf1 centro $box]
set x0 [lindex $res 0]
set y0 [lindex $res 1]
set n0 [expr $infos(decallage)*$infos(focale_guide)/$infos(focale_acq)/2]
#::console::affiche_resultat "x0=$x0 y0=$y0"
::console::disp "=======> x0=$x0 y0=$y0 n0=$n0 \n"
# variables de d�callage des poses

# a nombre de poses lanc�es par le pc acq
# b acteur de changement de sens 
# c valeur du prochain chagement de sens en alpha
# d valeur duprochain changement de sens en delta
# w valeur du bit combit 1.6 du pc autoguidage en debut de correction
# w1 valeur du bit combit 1.6 du pc autoguidage en millieu de correction
# w2 variable de changement d'�tat du bit combit 1.6 du pc autoguidage
# u et v  valeurs n0  ou -n0 � ajouter � x0 et y0 pour d�caller les poses entre chaque prise de vue.
# n nombre de pixels de d�callage du guidage en fonction de la focale de prise de vue,
		#de la focale de guidage,et dunombre de pixels sur l'image finale
# k1 variable d'arr�t du script si aucune pose d'acquisition n'est lanc�e au bout de 30 secondes
# m coefficient multiplicateur de dur�es de rappel delta
# m1 m2 m3 dur�e des rappels en delta
# P coefficient multiplicateur de dur�es de rappel alpha 
	#en fonction de la d�clinaison  la loi theorique est la suivante: de 0 (equateur) � 30� P=1 de 31 � 50 P=1.3 de 51 � 65 P=2 	
	# de 66 � 75 p=3 de 76 � 81 P=6 de 82 � 84 P=8 de 85 � 87 P=15 88 et plus P=30
# p1 p2 p3 dur�e des rappels en alpha
# e demi tol�rance de guidage 
# e1 e2 e3 demi tol�rance des rappels
# e1 = e * foc guid/foc acq/fact bining
# x1 abcisse de chaque pose
# y1 ordonn�e de chaque pose

# initialisation des variables
set a 1
set b 1
set c 2
set d 3
set e $infos(tol�rance)
set e1 [expr $infos(tol�rance)*$infos(focale_guide)/$infos(focale_acq)/2]
set e2 [expr $e1*2]
set e3 [expr $e1*4]
set e4 [expr $e1*5]
set u $n0
set v -$n0
set x1 $x0
set y1 $y0
set w 0 
set w1 0
set k1 100000
set m $infos(declinaison)
set m1 [expr 2*$m]
set m2 [expr 4*$m]
set m3 [expr 7*$m]
set m4 [expr 10*$m]

#if {$infos(dec)<71}  {

#}
#attention de 0 � 70� c'est le nombre "$infos(dec)" qui est pris comme coefficient
#if {70<$infos(dec)<81}  {
#set p 3
#}
#if {80<$infos(dec)<84}  {
#set p 4
#}
#if {83<$infos(dec)<87}  {
#set p 6
#}
#if {86<$infos(dec)<89}  {
#set p 12
#}
set p $infos(asc_droite)
set p1 [expr 1*$p]
set p2 [expr 5*$p]
set p3 [expr 7*$p]
set p4 [expr 9*$p]
set pp1 [expr 1*$p]
set pp2 [expr 5*$p]
set pp3 [expr 7*$p]
set pp4 [expr 9*$p]


# boucle d'autoguidage
for {set k 1} {$k<100000} {incr k} {
acq .1 2
   
# mesure de la variable d'�tat du bit 1 6
set w "[combit [string range $conf(telcom,port) 3 3 ] 6]"
set w2 [expr $w1-$w]
#  0-0=0 rien......0-1=-1debut de pose ....1-1=0 pose.....1-0=1 fin de pose

# Incr�mentation du compteur de pose et d�callage de la pose 
if {$w2==1}  {
set a [expr $a+1]
set k1 $k
set x1 [expr $x1+$u]
set y1 [expr $y1+$v]
#::console::affiche_resultat "x1=$x1 y1=$y1"
::console::disp "x1=$x1 y1=$y1 u=$u  v=$v "
}
# proc�dure d'arr�t  au bout  de 30 secondes sans nouvelle pose


if {$w2==-1}  {
set k1 100000
}

if {[expr $k-$k1]>50}  {
 set k  100000
}
# Calcul des nouvelles positions des poses en spirale ( illimit�)

if {$a==$c}  {

set u -$u  
set  c [expr $c+2*$b] 
}
if {$a==$d}  {

set v -$v  
set  d [expr $d+2*$b+1] 
set b [expr $b+1]
}


set res [buf1 centro $box]
set x [lindex $res 0]
set y [lindex $res 1]
set dx [expr $x-$x1]
set dy [expr $y-$y1]
#::console::affiche_resultat "dx=$dx dy=$dy \n"
::console::disp  "dx=$dx dy=$dy  ...$e1 ...$e2 ...$e3 ...$e4 \n"

         if { $dx > $e1 } {

		combit [string range $conf(telcom,port) 3 3 ] 7 0
            combit [string range $conf(telcom,port) 3 3 ] 4 1 	           
after $p1
  		combit [string range $conf(telcom,port) 3 3 ] 4 0 
		combit [string range $conf(telcom,port) 3 3 ] 7 0

	}
         if { $dx > $e2 } {

		combit [string range $conf(telcom,port) 3 3 ] 7 0
            combit [string range $conf(telcom,port) 3 3 ] 4 1 	           
after $p2
  		combit [string range $conf(telcom,port) 3 3 ] 4 0 
		combit [string range $conf(telcom,port) 3 3 ] 7 0
	
	}

	    if { $dx > $e3 } {

		combit [string range $conf(telcom,port) 3 3 ] 7 0
            combit [string range $conf(telcom,port) 3 3 ] 4 1 	           
after $p3
  		combit [string range $conf(telcom,port) 3 3 ] 4 0 
		combit [string range $conf(telcom,port) 3 3 ] 7 0

	}
	    if { $dx > $e4 } {

		combit [string range $conf(telcom,port) 3 3 ] 7 0
            combit [string range $conf(telcom,port) 3 3 ] 4 1 	           
after $p4
  		combit [string range $conf(telcom,port) 3 3 ] 4 0 
		combit [string range $conf(telcom,port) 3 3 ] 7 0

	}


         if { $dy < -$e1 } {

		combit [string range $conf(telcom,port) 3 3 ] 7 1  
		combit [string range $conf(telcom,port) 3 3 ] 3 1        
after $m1

		combit [string range $conf(telcom,port) 3 3 ] 3 0
		combit [string range $conf(telcom,port) 3 3 ] 7 0
	}

 
         if { $dy < -$e2 } {

		combit [string range $conf(telcom,port) 3 3 ] 7 1  
		combit [string range $conf(telcom,port) 3 3 ] 3 1        
after $m2

		combit [string range $conf(telcom,port) 3 3 ] 3 0
		combit [string range $conf(telcom,port) 3 3 ] 7 0
	}

         if { $dy < -$e3 } {


		combit [string range $conf(telcom,port) 3 3 ] 7 1  
		combit [string range $conf(telcom,port) 3 3 ] 3 1        
after $m3

		combit [string range $conf(telcom,port) 3 3 ] 3 0
		combit [string range $conf(telcom,port) 3 3 ] 7 0
	}

         if { $dy < -$e4 } {


		combit [string range $conf(telcom,port) 3 3 ] 7 1  
		combit [string range $conf(telcom,port) 3 3 ] 3 1        
after $m4

		combit [string range $conf(telcom,port) 3 3 ] 3 0
		combit [string range $conf(telcom,port) 3 3 ] 7 0
	}

 set w1 "[combit [string range $conf(telcom,port) 3 3 ] 6]"
set w2 [expr $w-$w1]
#  0-0=0 rien......0-1=-1debut de pose ....1-1=0 pose.....1-0=1 fin de pose

# Incr�mentation du compteur de pose et d�callage de la pose 
if {$w2==1}  {
set a [expr $a+1]
set k1 $k
set x1 [expr $x1+$u]
set y1 [expr $y1+$v]
#::console::affiche_resultat "x1=$x1 y1=$y1"
::console::disp "x1=$x1 y1=$y1 u=$u  v=$v "

}
# proc�dure d'arr�t  au bout  de 30 secondes sans nouvelle pose


if {$w2==-1}  {
set k1 100000
}

if {[expr $k-$k1]>10}  {
 set k  100000
}
# Calcul des nouvelles positions des poses en spirale ( illimit�)

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

  
  destroy .test5
   }
pack .test5.but_valid \
   -in .test5 -side bottom -anchor center \
   -padx 3 -pady 3 

#--- Detruit la fenetre avec la croix en haut a droite 
bind .test5 <Destroy> { destroy .test5 } 


