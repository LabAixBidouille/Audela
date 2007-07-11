#
# Fichier : trichro.tcl
# Description : Outil pour importer une trichromie
# Auteur : Pierre THIERRY
# Mise a jour $Id: trichro.tcl,v 1.6 2007-05-16 18:14:00 robertdelmas Exp $
#

global audace caption conf infos

#--- Chargement des captions
source [ file join $audace(rep_plugin) tool acqcolor trichro.cap ]

#--- Initialisation des variables
set infos(image_r)   "$caption(trichro,interro)"
set infos(image_v)   "$caption(trichro,interro)"
set infos(image_b)   "$caption(trichro,interro)"
set infos(image_rvb) "$caption(trichro,interro)"

#--- Cree la fenetre .test3 de niveau le plus haut
if [ winfo exists $audace(base).test3 ] {
   wm withdraw $audace(base).test3
   wm deiconify $audace(base).test3
   focus $audace(base).test3
   return
}
toplevel $audace(base).test3 -class Toplevel
wm geometry $audace(base).test3 +440+190
wm title $audace(base).test3 $caption(trichro,titre)

#--- La nouvelle fenetre est active
focus $audace(base).test3

#--- Cree un frame en haut a gauche pour les canvas d'affichage
frame $audace(base).test3.frame0 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test3.frame0 \
   -in $audace(base).test3 -anchor nw -side top -expand 0 -fill x

   #--- Cree le label 'titre'
   label $audace(base).test3.frame0.lab \
      -text "$caption(trichro,comment)"
   pack $audace(base).test3.frame0.lab \
      -in $audace(base).test3.frame0 -side top -anchor center \
      -padx 3 -pady 3

#--- Cree un frame
frame $audace(base).test3.frame1 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test3.frame1 \
   -in $audace(base).test3 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label $audace(base).test3.frame1.lab \
      -text "$caption(trichro,rep_images)"
   pack $audace(base).test3.frame1.lab \
      -in $audace(base).test3.frame1 -side left -anchor center \
      -padx 3 -pady 3

   #--- Cree l'entry
   entry $audace(base).test3.frame1.ent \
      -textvariable infos(dir) -width 45
   pack $audace(base).test3.frame1.ent \
      -in $audace(base).test3.frame1 -side left -anchor center -expand 1 \
      -padx 10 -pady 3

   #--- Cree le bouton parcourir
   button $audace(base).test3.frame1.explore -text "$caption(trichro,parcourir)" -width 1 \
      -command {
         set initialdir $infos(dir)
         set title $caption(trichro,rep_images)
         set infos(dir_images) [ tk_chooseDirectory -title "$title" -initialdir "$initialdir" \
            -parent "$audace(base).test3" ]
         if { $infos(dir_images) == "" } {
            set infos(dir_images) "$initialdir"
         }
         set infos(dir) "$infos(dir_images)"
         $audace(base).test3.frame1.ent configure -textvariable infos(dir)
      }
   pack $audace(base).test3.frame1.explore -side left -padx 10 -pady 5 -ipady 5

#--- Cree un frame
frame $audace(base).test3.frame2 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test3.frame2 \
   -in $audace(base).test3 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label $audace(base).test3.frame2.lab \
      -text "$caption(trichro,image_r)"
   pack $audace(base).test3.frame2.lab \
      -in $audace(base).test3.frame2 -side left -anchor center \
      -padx 3 -pady 3

   #--- Cree l'entry
   entry $audace(base).test3.frame2.ent \
      -textvariable infos(image_r)
   pack $audace(base).test3.frame2.ent \
      -in $audace(base).test3.frame2 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3

   #--- Cree le bouton charger le nom d'une image
   button $audace(base).test3.frame2.explore -text "$caption(trichro,parcourir)" -width 1 \
      -command {
         #--- Fenetre parent
         set fenetre "$audace(base).test3"
         #--- Ouvre la fenetre de choix des images
         set filename [ ::tkutil::box_load $fenetre $infos(dir) $audace(bufNo) "1" ]
         #--- Extraction du nom
         set infos(image_r) [ file rootname [ file tail $filename ] ]
         $audace(base).test3.frame2.ent configure -textvariable infos(image_r)
      }
   pack $audace(base).test3.frame2.explore -side left -padx 10 -pady 5 -ipady 5

#--- Cree un frame
frame $audace(base).test3.frame3 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test3.frame3 \
   -in $audace(base).test3 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label $audace(base).test3.frame3.lab \
      -text "$caption(trichro,image_v)"
   pack $audace(base).test3.frame3.lab \
      -in $audace(base).test3.frame3 -side left -anchor center \
      -padx 3 -pady 3

   #--- Cree l'entry
   entry $audace(base).test3.frame3.ent \
      -textvariable infos(image_v)
   pack $audace(base).test3.frame3.ent \
      -in $audace(base).test3.frame3 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3

   #--- Cree le bouton charger le nom d'une image
   button $audace(base).test3.frame3.explore -text "$caption(trichro,parcourir)" -width 1 \
      -command {
         #--- Fenetre parent
         set fenetre "$audace(base).test3"
         #--- Ouvre la fenetre de choix des images
         set filename [ ::tkutil::box_load $fenetre $infos(dir) $audace(bufNo) "1" ]
         #--- Extraction du nom
         set infos(image_v) [ file rootname [ file tail $filename ] ]
         $audace(base).test3.frame3.ent configure -textvariable infos(image_v)
      }
   pack $audace(base).test3.frame3.explore -side left -padx 10 -pady 5 -ipady 5

#--- Cree un frame
frame $audace(base).test3.frame4 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test3.frame4 \
   -in $audace(base).test3 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label $audace(base).test3.frame4.lab \
      -text "$caption(trichro,image_b)"
   pack $audace(base).test3.frame4.lab \
      -in $audace(base).test3.frame4 -side left -anchor center \
      -padx 3 -pady 3

   #--- Cree l'entry
   entry $audace(base).test3.frame4.ent \
      -textvariable infos(image_b)
   pack $audace(base).test3.frame4.ent \
      -in $audace(base).test3.frame4 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3

   #--- Cree le bouton charger le nom d'une image
   button $audace(base).test3.frame4.explore -text "$caption(trichro,parcourir)" -width 1 \
      -command {
         #--- Fenetre parent
         set fenetre "$audace(base).test3"
         #--- Ouvre la fenetre de choix des images
         set filename [ ::tkutil::box_load $fenetre $infos(dir) $audace(bufNo) "1" ]
         #--- Extraction du nom
         set infos(image_b) [ file rootname [ file tail $filename ] ]
         $audace(base).test3.frame4.ent configure -textvariable infos(image_b)
      }
   pack $audace(base).test3.frame4.explore -side left -padx 10 -pady 5 -ipady 5

#--- Cree un frame
frame $audace(base).test3.frame5 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test3.frame5 \
   -in $audace(base).test3 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label $audace(base).test3.frame5.lab \
      -text "$caption(trichro,nom_image)"
   pack $audace(base).test3.frame5.lab \
      -in $audace(base).test3.frame5 -side left -anchor center \
      -padx 3 -pady 3

   #--- Cree l'entry
   entry $audace(base).test3.frame5.ent \
      -textvariable infos(image_rvb)
   pack $audace(base).test3.frame5.ent \
      -in $audace(base).test3.frame5 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3

#--- Cree le bouton 'Validation'
button $audace(base).test3.but_valid \
   -text "$caption(trichro,executer)" -borderwidth 2 \
   -command {
      catch {
         #--- Noms des images des plans rouge, vert et bleu
         set nomr [ file join $infos(dir) $infos(image_r) ]
         set nomv [ file join $infos(dir) $infos(image_v) ]
         set nomb [ file join $infos(dir) $infos(image_b) ]
         #--- Changement temporaire du nom des images pour utiliser la fonction fitsconvert3d
         file copy $nomr$conf(extension,defaut) [ file join $infos(dir) tmp_1 ]$conf(extension,defaut)
         file copy $nomv$conf(extension,defaut) [ file join $infos(dir) tmp_2 ]$conf(extension,defaut)
         file copy $nomb$conf(extension,defaut) [ file join $infos(dir) tmp_3 ]$conf(extension,defaut)
         #--- Nom de l'image RVB
         set filename [ file join $infos(dir) $infos(image_rvb) ]
         #--- Conversion R+V+B --> RVB
         fitsconvert3d [ file join $infos(dir) "tmp_" ] 3 $conf(extension,defaut) $filename
         #--- Suppression des images temporaires
         file delete [ file join $infos(dir) tmp_1$conf(extension,defaut) ]
         file delete [ file join $infos(dir) tmp_2$conf(extension,defaut) ]
         file delete [ file join $infos(dir) tmp_3$conf(extension,defaut) ]
         #--- Affiche l'image RVB
         set infos(type_image) "couleur"
         buf1000 load $filename
         testvisu
         #--- Supprime le mot-cles RGBFILTR et enregistre l'image RVB
         buf1000 delkwd "RGBFILTR"
         buf1000 save $filename
         #--- Ferme la boite de dialogue
         destroy $audace(base).test3
      }
   }
pack $audace(base).test3.but_valid \
   -in $audace(base).test3 -side bottom -anchor center \
   -padx 3 -pady 5 -ipadx 5 -ipady 3

#--- Detruit la fenetre avec la croix en haut a droite
bind $audace(base).test3 <Destroy> { destroy $audace(base).test3 }

#--- Mise a jour dynamique des couleurs
::confColor::applyColor $audace(base).test3

