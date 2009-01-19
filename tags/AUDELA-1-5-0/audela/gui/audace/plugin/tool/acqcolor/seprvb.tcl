#
# Fichier : seprvb.tcl
# Description : Outil pour la separation des plans couleur
# Auteur : Pierre THIERRY
# Mise a jour $Id: seprvb.tcl,v 1.7 2008-11-16 21:19:52 robertdelmas Exp $
#

global audace caption conf infos

#--- Chargement des captions
source [ file join $audace(rep_plugin) tool acqcolor seprvb.cap ]

#--- Initialisation des variables
set infos(nom_image)   "$caption(seprvb,interro)"
set infos(nbre_images) "$caption(seprvb,interro)"

#--- Cree la fenetre .test1 de niveau le plus haut
if [ winfo exists $audace(base).test1 ] {
   wm withdraw $audace(base).test1
   wm deiconify $audace(base).test1
   focus $audace(base).test1
   return
}
toplevel $audace(base).test1 -class Toplevel
wm geometry $audace(base).test1 +400+150
wm title $audace(base).test1 $caption(seprvb,titre)

#--- La nouvelle fenetre est active
focus $audace(base).test1

#--- Cree un frame en haut a gauche pour les canvas d'affichage
frame $audace(base).test1.frame0 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test1.frame0 \
   -in $audace(base).test1 -anchor nw -side top -expand 0 -fill x

   #--- Cree le label 'commentaire'
   label $audace(base).test1.frame0.lab \
      -text "$caption(seprvb,comment)"
   pack $audace(base).test1.frame0.lab \
      -in $audace(base).test1.frame0 -side top -anchor center \
      -padx 3 -pady 3

#--- Cree un frame
frame $audace(base).test1.frame1 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test1.frame1 \
   -in $audace(base).test1 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label $audace(base).test1.frame1.lab \
      -text "$caption(seprvb,rep_images)"
   pack $audace(base).test1.frame1.lab \
      -in $audace(base).test1.frame1 -side left -anchor center \
      -padx 3 -pady 3

   #--- Cree l'entry
   entry $audace(base).test1.frame1.ent \
      -textvariable infos(dir) -width 50
   pack $audace(base).test1.frame1.ent \
      -in $audace(base).test1.frame1 -side left -anchor center -expand 1 \
      -padx 10 -pady 3

   #--- Cree le bouton parcourir
   button $audace(base).test1.frame1.explore -text "$caption(seprvb,parcourir)" -width 1 \
      -command {
         set initialdir $infos(dir)
         set title $caption(seprvb,rep_images)
         set infos(dir_images) [ tk_chooseDirectory -title "$title" -initialdir "$initialdir" \
            -parent "$audace(base).test1" ]
         if { $infos(dir_images) == "" } {
            set infos(dir_images) "$initialdir"
         }
         set infos(dir) "$infos(dir_images)"
         $audace(base).test1.frame1.ent configure -textvariable infos(dir)
      }
   pack $audace(base).test1.frame1.explore -side left -padx 10 -pady 5 -ipady 5

#--- Cree un frame
frame $audace(base).test1.frame2 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test1.frame2 \
   -in $audace(base).test1 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label $audace(base).test1.frame2.lab \
      -text "$caption(seprvb,nom_images)"
   pack $audace(base).test1.frame2.lab \
      -in $audace(base).test1.frame2 -side left -anchor center \
      -padx 3 -pady 3

   #--- Cree l'entry
   entry $audace(base).test1.frame2.ent \
      -textvariable infos(nom_image)
   pack $audace(base).test1.frame2.ent \
      -in $audace(base).test1.frame2 -side left -anchor center -expand 1 -fill x \
      -padx 10 -pady 3

   #--- Cree le bouton charger le nom d'une image
   button $audace(base).test1.frame2.explore -text "$caption(seprvb,parcourir)" -width 1 \
      -command {
         #--- Fenetre parent
         set fenetre "$audace(base).test1"
         #--- Ouvre la fenetre de choix des images
         set filename [ ::tkutil::box_load $fenetre $infos(dir) $audace(bufNo) "1" ]
         #--- Extraction du nom
         set infos(nom_image) [ file rootname [ file tail $filename ] ]
         $audace(base).test1.frame2.ent configure -textvariable infos(nom_image)
      }
   pack $audace(base).test1.frame2.explore -side left -padx 10 -pady 5 -ipady 5

#--- Cree un frame
frame $audace(base).test1.frame3 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test1.frame3 \
   -in $audace(base).test1 -anchor center -side top -expand 0 -fill x

   #--- Cree le label
   label $audace(base).test1.frame3.lab \
      -text "$caption(seprvb,nbre_images)"
   pack $audace(base).test1.frame3.lab \
      -in $audace(base).test1.frame3 -side left -anchor center \
      -padx 3 -pady 3

   #--- Cree l'entry
   entry $audace(base).test1.frame3.ent \
      -textvariable infos(nbre_images) -width 6
   pack $audace(base).test1.frame3.ent \
      -in $audace(base).test1.frame3 -side left -anchor center \
      -padx 10 -pady 10

#--- Cree le bouton 'Validation'
button $audace(base).test1.but_valid \
   -text "$caption(seprvb,executer)" -borderwidth 2 \
   -command {
      catch {
         set infos(type_image) "couleur"
         set nom [ file join $infos(dir) $infos(nom_image) ]
         for { set k 1 } { $k <= $infos(nbre_images) } { incr k } {
            #--- Chargement des images
            buf1000 load "${nom}$k$conf(extension,defaut)"
            #--- Fixe NAXIS a 2
            set kwdNaxis [ buf1000 getkwd NAXIS ]
            set kwdNaxis [ lreplace $kwdNaxis 1 1 "2" ]
            buf1000 setkwd $kwdNaxis
            #--- Creation dans le buffer du mot-cles RGBFILTR pour le plan rouge
            buf1000 setkwd [list RGBFILTR R string "Color extracted (Red)" ""]
            #--- Sauvegarde du plan rouge
            buf1000 save3d "${nom}r$k$conf(extension,defaut)" 3 1 1
            #--- Creation dans le buffer du mot-cles RGBFILTR pour le plan vert
            buf1000 setkwd [list RGBFILTR G string "Color extracted (Green)" ""]
            #--- Sauvegarde du plan vert
            buf1000 save3d "${nom}v$k$conf(extension,defaut)" 3 2 2
            #--- Creation dans le buffer du mot-cles RGBFILTR pour le plan bleu
            buf1000 setkwd [list RGBFILTR B string "Color extracted (Blue)" ""]
            #--- Sauvegarde du plan bleu
            buf1000 save3d "${nom}b$k$conf(extension,defaut)" 3 3 3
            #--- Suppression du mot-cles RGBFILTR
            buf1000 delkwd "RGBFILTR"
         }
         #--- Ferme la boite de dialogue
         destroy $audace(base).test1
      }
   }
pack $audace(base).test1.but_valid \
   -in $audace(base).test1 -side bottom -anchor center \
   -padx 3 -pady 5 -ipadx 5 -ipady 3

#--- Detruit la fenetre avec la croix en haut a droite
bind $audace(base).test1 <Destroy> { destroy $audace(base).test1 }

#--- Mise a jour dynamique des couleurs
::confColor::applyColor $audace(base).test1

