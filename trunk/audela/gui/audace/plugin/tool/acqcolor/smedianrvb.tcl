#
# Fichier : smedianrvb.tcl
# Description : Outil pour calculer la mediane d'une pile d'images
# Auteur : Pierre THIERRY
# Mise a jour $Id: smedianrvb.tcl,v 1.4 2007-01-20 10:51:57 robertdelmas Exp $
#

global audace caption conf infos

#--- Chargement des captions
uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqcolor smedianrvb.cap ]\""

#--- Initialisation des variables
set infos(nom_image)   "$caption(smedianrvb,interro)" 
set infos(nbre_images) "$caption(smedianrvb,interro)" 
set infos(nom_mediane) "$caption(smedianrvb,interro)" 

#--- Cree la fenetre .test2 de niveau le plus haut 
if [ winfo exists $audace(base).test2 ] {
   wm withdraw $audace(base).test2
   wm deiconify $audace(base).test2
   focus $audace(base).test2
   return
}
toplevel $audace(base).test2 -class Toplevel
wm geometry $audace(base).test2 +420+170 
wm title $audace(base).test2 $caption(smedianrvb,titre)

#--- La nouvelle fenetre est active
focus $audace(base).test2

#--- Cree un frame en haut a gauche pour les canvas d'affichage
frame $audace(base).test2.frame0 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test2.frame0 \
   -in $audace(base).test2 -anchor nw -side top -expand 0 -fill x

   #--- Cree le label 'commentaire' 
   label $audace(base).test2.frame0.lab1 \
      -text "$caption(smedianrvb,comment1)"
   pack $audace(base).test2.frame0.lab1 \
      -in $audace(base).test2.frame0 -side top -anchor center \
      -padx 3 -pady 3  

   #--- Cree le label 'commentaire' 
   label $audace(base).test2.frame0.lab2 \
      -text "$caption(smedianrvb,comment2)"
   pack $audace(base).test2.frame0.lab2 \
      -in $audace(base).test2.frame0 -side top -anchor center \
      -padx 3 -pady 3  

#--- Cree un frame 
frame $audace(base).test2.frame1 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test2.frame1 \
   -in $audace(base).test2 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label $audace(base).test2.frame1.lab \
      -text "$caption(smedianrvb,rep_images)"
   pack $audace(base).test2.frame1.lab \
      -in $audace(base).test2.frame1 -side left -anchor center \
      -padx 3 -pady 3

   #--- Cree le bouton parcourir
   button $audace(base).test2.frame1.explore -text "$caption(smedianrvb,parcourir)" -width 1 \
      -command {
         set initialdir $infos(dir)
         set title $caption(smedianrvb,rep_images)
         set infos(dir_images) [ tk_chooseDirectory -title "$title" -initialdir "$initialdir" \
            -parent "$audace(base).test2" ]
         if { $infos(dir_images) == "" } {
            set infos(dir_images) "$initialdir"
         }
         set infos(dir) "$infos(dir_images)"
         $audace(base).test2.frame1.ent configure -textvariable infos(dir)
      }
   pack $audace(base).test2.frame1.explore -side left -padx 10 -pady 5 -ipady 5

   #--- Cree l'entry
   entry $audace(base).test2.frame1.ent \
      -textvariable infos(dir) -width 45
   pack $audace(base).test2.frame1.ent \
      -in $audace(base).test2.frame1 -side left -anchor center -expand 1 \
      -padx 10 -pady 3

#--- Cree un frame 
frame $audace(base).test2.frame2 \
   -borderwidth 0 -cursor arrow 
pack $audace(base).test2.frame2 \
   -in $audace(base).test2 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label $audace(base).test2.frame2.lab \
      -text "$caption(smedianrvb,nom_images)"
   pack $audace(base).test2.frame2.lab \
      -in $audace(base).test2.frame2 -side left -anchor center \
      -padx 3 -pady 3

   #--- Cree le bouton charger le nom d'une image
   button $audace(base).test2.frame2.explore -text "$caption(smedianrvb,parcourir)" -width 1 \
      -command {
         #--- Fenetre parent
         set fenetre "$audace(base).test2"
         #--- Ouvre la fenetre de choix des images
         set filename [ ::tkutil::box_load $fenetre $infos(dir) $audace(bufNo) "1" ]
         #--- Extraction du nom
         set infos(nom_image) [ file rootname [ file tail $filename ] ]
         $audace(base).test2.frame2.ent configure -textvariable infos(nom_image)
      }
   pack $audace(base).test2.frame2.explore -side left -padx 10 -pady 5 -ipady 5

   #--- Cree l'entry
   entry $audace(base).test2.frame2.ent \
      -textvariable infos(nom_image)
   pack $audace(base).test2.frame2.ent \
      -in $audace(base).test2.frame2 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3

#--- Cree un frame 
frame $audace(base).test2.frame3 \
   -borderwidth 0 -cursor arrow 
pack $audace(base).test2.frame3 \
   -in $audace(base).test2 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label $audace(base).test2.frame3.lab \
      -text "$caption(smedianrvb,nbre_images)"
   pack $audace(base).test2.frame3.lab \
      -in $audace(base).test2.frame3 -side left -anchor center \
      -padx 3 -pady 3  

   #--- Cree l'entry
   entry $audace(base).test2.frame3.ent \
      -textvariable infos(nbre_images) -width 6
   pack $audace(base).test2.frame3.ent \
      -in $audace(base).test2.frame3 -side left -anchor center \
      -padx 10 -pady 3  

#--- Cree un frame 
frame $audace(base).test2.frame4 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test2.frame4 \
   -in $audace(base).test2 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label $audace(base).test2.frame4.lab \
      -text "$caption(smedianrvb,nom_med)"
   pack $audace(base).test2.frame4.lab \
      -in $audace(base).test2.frame4 -side left -anchor center \
      -padx 3 -pady 3  

   #--- Cree l'entry
   entry $audace(base).test2.frame4.ent \
      -textvariable infos(nom_mediane)
   pack $audace(base).test2.frame4.ent \
      -in $audace(base).test2.frame4 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3 
 
#--- Cree un frame 
frame $audace(base).test2.frame5 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test2.frame5 \
   -in $audace(base).test2 -anchor center -side top -expand 0 -fill x

   #--- Cree le label du commentaire
   label $audace(base).test2.frame5.lab \
      -text "$caption(smedianrvb,comment3)"
   pack $audace(base).test2.frame5.lab \
      -in $audace(base).test2.frame5 -side top -anchor center \
      -padx 3 -pady 3  

#--- Cree le bouton 'Validation' 
button $audace(base).test2.but_valid \
   -text "$caption(smedianrvb,executer)" -borderwidth 2 \
   -command { 
      catch {
         set nom "$infos(nom_image)"
         set nom1 "$infos(nom_mediane)" 
         set nb "$infos(nbre_images)"    
         set infos(type_image) "couleur"
         #--- Separe les couleurs
         for { set k 1 } { $k <= $infos(nbre_images) } { incr k } {
            loadima "${nom}$k$conf(extension,defaut);1"
            saveima "${nom}r$k$conf(extension,defaut)"
            loadima "${nom}$k$conf(extension,defaut);2"
            saveima "${nom}v$k$conf(extension,defaut)"
            loadima "${nom}$k$conf(extension,defaut);3"
            saveima "${nom}b$k$conf(extension,defaut)"
         }
         #--- Execute la mediane de chaque couleur
         smedian ${nom}r ${nom1}r ${nb}
         smedian ${nom}v ${nom1}v ${nb}
         smedian ${nom}b ${nom1}b ${nb}
         #--- Charge l'image dans 3 fichiers
         set nom1r [ file join $infos(dir) $infos(nom_mediane)r ]
         set nom1v [ file join $infos(dir) $infos(nom_mediane)v ]
         set nom1b [ file join $infos(dir) $infos(nom_mediane)b ]
         rgb_load {$nom1r$conf(extension,defaut)} {$nom1v$conf(extension,defaut)} {$nom1b$conf(extension,defaut)}
         #--- Affiche l'image
         set infos(type_image) "couleur"
         testvisu
         #--- Sauve l'image dans un seul fichier
         set filename [ file join $infos(dir) ${nom1} ]
         rgb_save $filename$conf(extension,defaut)
         #--- Detruit les fichiers intermediaires
         delete2 ${nom}r ${nb}
         delete2 ${nom}v ${nb}
         delete2 ${nom}b ${nb}
         #--- Detruit la fenêtre devant l'image  
         destroy $audace(base).test2
      }
   } 
pack $audace(base).test2.but_valid \
   -in $audace(base).test2 -side bottom -anchor center \
   -padx 3 -pady 5 -ipadx 5 -ipady 3

#--- Detruit la fenetre avec la croix en haut a droite 
bind $audace(base).test2 <Destroy> { destroy $audace(base).test2 } 

#--- Mise a jour dynamique des couleurs
::confColor::applyColor $audace(base).test2

