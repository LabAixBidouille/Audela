#
# Fichier : sn_tarot.tcl
# Description : Visualisation des images de la nuit et comparaison avec des images de reference
# Auteur : Alain KLOTZ et Raymond ZACHANTKE
# Mise à jour $Id:
#

#--- Conventions pour ce script :
#--- Les indices 1 se rapportent a l'image de gauche
#--- Les indices 2 se rapportent a l'image de droite

proc ::sn_tarot::confTarotVisu { } {
   # =======================================
   # === Initialisation of the variables
   # === Initialisation des variables
   # =======================================

   #--- Definition of global variables (arrays)
   #--- Definition des variables globales (arrays)
   global zone       #--- Window name of usefull screen parts
   global info_image #--- Some infos on the current image
   global audace conf snvisu snconfvisu num caption color rep panneau

   #--- Chargement de la configuration
   if { ![ info exists conf(sn_tarot) ] } {
      #--   creation de la variable par defaut
      set conf(sn_tarot) [ list motion 250 5 0 no ]
   }
   lassign $conf(sn_tarot) snconfvisu(cuts_change) snconfvisu(delai_blink) \
      snconfvisu(nb_blink) snconfvisu(auto_blink) snconfvisu(gzip)
   set snconfvisu(zoom_normal) 4

   if { ![ info exists conf(sn_tarot,last_archive) ]} {
      set conf(sn_tarot,last_archive) "-"
   }
   if { $conf(sn_tarot,last_archive) ni $rep(list_archives) } {
      set snconfvisu(archive) "-"
    } else {
      set snconfvisu(archive) $conf(sn_tarot,last_archive)
   }

   lassign [ list "" "0" "1" "0" ] rep(blink,last) snvisu(blink_go) \
      snvisu(exit_blink) snconfvisu(pers_or_dss)
   set snvisu(afflog) 1 ; #--- Pour un affichage des images en mode logarithme
   set snvisu(dss) 0 ; #-- pour signaler le telechargement

   set rep(name2) "$panneau(sn_tarot,references)" ; # chemin du repertoire images de reference refgaltarot

   #--   lancee au démarage et au changement de fichier images de la nuit
   set rep(index1) -1  ; #--indice de l'image affichee dans night ; -1 si pas d'image
   set rep(index2) -1  ; #--indice de l'image dans references ; -1 si pas d'image
   set rep(index3) -1  ; #--indice de l'image dans dss  ; -1 si pas d'image

   set rep(gz) "$snconfvisu(gzip)"
   set gnaxis 308 ; # = 4 * naxis

   # =========================================
   # === Setting the graphic interface
   # === Met en place l'interface graphique
   # =========================================

   #--- Hide the window root
   #--- Cache la fenetre racine
   wm focusmodel . passive
   wm withdraw .

   #--- Create the toplevel window .snvisu
   #--- Cree la fenetre .snvisu de niveau le plus haut

   if { [ winfo exists $audace(base).snvisu ] } {
      wm withdraw $audace(base).snvisu
      wm deiconify $audace(base).snvisu
      return
   }

   if { ![ info exists conf(sn_tarot,geometry) ] } {
      set conf(sn_tarot,geometry) "660x548+150+70"
   }

   toplevel $audace(base).snvisu -class Toplevel
   wm geometry $audace(base).snvisu $conf(sn_tarot,geometry)
   wm resizable $audace(base).snvisu 0 0
   wm title $audace(base).snvisu $caption(sn_tarot,main_title)
   wm protocol $audace(base).snvisu WM_DELETE_WINDOW "::sn_tarot::snDelete"

   label $audace(base).snvisu.lab -text [ format $caption(sn_tarot,title) $snconfvisu(archive) ]
   pack $audace(base).snvisu.lab -pady 5

   #--- Create frames
   #--- Cree des frames
   foreach fr [ list fr1 fr2 fr3 fr4 fr5 ] {
      set $fr $audace(base).snvisu.$fr
      frame [ set $fr ] -borderwidth 0 -cursor arrow
      pack [ set $fr ] -anchor n -side top -fill x
   }

   #--- First frame : time and name
   #--- Premier frame : les heures et le nom de l'image
   foreach lab [ list labelh1 label1 labelh2 ] {
      set zone($lab) $fr1.$lab
      label $zone($lab) -text "" -borderwidth 0 -relief flat -width 22
      pack $zone($lab) -padx 5 -pady 10
   }
   pack configure $zone(labelh1) -side left -anchor nw
   pack configure $zone(label1) -side left -padx 100
   pack configure $zone(labelh2) -side right -anchor ne

   #--- Create the canvas for the image 1 and 2 in the second frame
   #--- Cree le canevas pour l'image 1 et 2 dans le frame 2
   foreach imgNo [ list 1 2 ] {
      set zone(image$imgNo) $fr2.image$imgNo
      canvas $zone(image$imgNo) -width $gnaxis -height $gnaxis
      $zone(image$imgNo) configure -cursor crosshair
      pack $zone(image$imgNo) -expand 1 -fill x -side left -anchor e -padx 10
   }

   #--- Scales are in the third frame
   #--- Les glissieres sont dans le troisieme
   set gnaxis1scale $gnaxis
   foreach sca [ list sh1 sh2 ] cmd [ list ::sn_tarot::changeHiCut1 ::sn_tarot::changeHiCut2 ] {
      set zone($sca) $fr3.$sca
      scale $zone($sca) -orient horizontal -to 32767 -from -10000 \
         -length $gnaxis1scale -background $audace(color,cursor_blue) \
         -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
         -activebackground $audace(color,cursor_blue_actif) \
         -relief raised -command $cmd
      pack $zone($sca) -anchor s -side left -expand 1 -fill x -padx 10
   }

   #--- Buttons are in the fourth frame
   #--- Les boutons sont dans le quatrieme
   #--- Create the button 'Previous', 'Next', 'Go to', 'Sky Background', 'Start Blink', 'Save'
   #--- Cree le bouton 'Precedente', 'Suivante', 'Aller a, 'Fond du ciel', 'GO Blink', 'Enregistrer'
   set button_list [ list prev next goto background blink_go save ]
   set cmd_list [ list "incrImage -1" "incrImage" gotoImage snSubSky snBlinkImage confirmSave ]
   foreach but $button_list cmd $cmd_list {
      set i [lsearch -exact $button_list $but ]
      button $fr4.but_$but -text $caption(sn_tarot,$but) -borderwidth 2 \
         -command "::sn_tarot::$cmd"
      grid $fr4.but_$but -row 0 -column $i -ipadx 5 -ipady 5 -sticky ns
   }

   #--- Create the radio-buttons
   #--- Cree les radio-boutons
   #--- Bouton radio 1 "Dossier de reference perso"
   radiobutton $fr4.but_rad0 -text $caption(sn_tarot,perso) \
      -variable snconfvisu(pers_or_dss) -value 0 \
      -command "::sn_tarot::displayImages"
   incr i
   grid $fr4.but_rad0 -row 0 -column $i -ipadx 5 -sticky ns
   #--- Bouton radio 2 "Dossier de reference DSS"
   radiobutton $fr4.but_rad1 -text $caption(sn_tarot,dss) \
      -variable snconfvisu(pers_or_dss) -value 1 \
      -command "::sn_tarot::displayImages"
   incr i
   grid $fr4.but_rad1 -row 0 -column $i -ipadx 5 -sticky ns
   $fr4.but_rad1 configure -state disabled

   grid columnconfigure $fr4 { 0 1 2 3 4 5 6 7 8 } -weight 1 -pad 5

   #--- Create a console for status returned
   #--- Cree la console de retour d'etats
   set zone(status_list) $audace(base).snvisu.lst1
   listbox $zone(status_list) -height 3 -borderwidth 1 -relief sunken \
      -yscrollcommand [ list $zone(status_list).scr1 set ]
   pack $zone(status_list) -fill x -anchor ne -padx 3 -pady 3

   #--- Create a vertical scrollbar for the status listbox
   #--- Cree un ascenseur vertical pour la console de retour d'etats
   scrollbar $zone(status_list).scr1 -orient vertical -takefocus 1 -borderwidth 1 \
      -command [ list $zone(status_list) yview ]
   pack $zone(status_list).scr1 -in $zone(status_list) -fill y -side right -anchor ne

   #--   Create the command SetUp Help and Exit
   pack configure $fr5 -side bottom
   foreach but [ list configuration exit aide ] cmd [ list snSetup snDelete "snHelp sn_visu" ] {
      button $fr5.but_$but -text "$caption(sn_tarot,$but)" \
         -width 10 -borderwidth 2 -command "::sn_tarot::$cmd"
      pack $fr5.but_$but -side right -padx 10 -pady 5 -ipadx 5 -ipady 5
   }
   pack $fr5.but_configuration -side left

   label $fr5.lab -text "$caption(sn_tarot,select)"
   pack $fr5.lab -side left -padx 10 -pady 5 -ipadx 5 -ipady 5

   ComboBox $fr5.select -height 10 -relief sunken -width 25 \
      -textvariable snconfvisu(night) \
      -values $rep(list_archives) \
      -modifycmd "::sn_tarot::snSelect"
   pack $fr5.select -side left
   set k [ lsearch $rep(list_archives) $snconfvisu(night) ]
   if { $k == -1 } { set k 0 }
   $fr5.select setvalue @$k

   #--- La fenetre est active
   focus $audace(base).snvisu

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).snvisu
   $audace(base).snvisu.lab configure -font "{MS Sans Serif} 8 bold"

   # =========================================
   # === Setting the binding
   # === Met en place les liaisons
   # =========================================

   bind $audace(base).snvisu <Key-space> { ::sn_tarot::::sn_tarot::incrImage }
   bind $audace(base).snvisu <Key-F1> { ::sn_tarot::incrImage }
   bind $audace(base).snvisu <Key-F2> { ::sn_tarot::snSubSky }
   bind $audace(base).snvisu <Key-F3> {
      set snvisu(exit_blink) "1"
      if { $snvisu(blink_go) == "0" } {
         ::sn_tarot::snBlinkImage
      }
   }
   bind $audace(base).snvisu <Key-F4> { ::sn_tarot::confirmSave }
   bind $audace(base).snvisu <Key-F5> { ::sn_tarot::snHeader $num(buffer1) }
   bind $audace(base).snvisu <Key-F6> { ::sn_tarot::snHeader $num(buffer2) }
   bind $audace(base).snvisu <Key-F7> { ::sn_tarot::noCosmic }

   if { [ string tolower "$snconfvisu(cuts_change)" ] == "motion" } {
      set cmd Motion
   } else {
      set cmd ButtonRelease
   }
   bind $zone(sh1) <$cmd> { visu$num(visu1) disp }
   bind $zone(sh2) <$cmd> { visu$num(visu2) disp }

   # ========================================
   # === Setting the astronomical devices ===
   # ========================================

   foreach b [ list buffer1 buffer1b buffer2 buffer2b ] {
      #--- Declare a new buffer in memory to place images
      set num($b) [::buf::create]
      buf$num($b) extension $conf(extension,defaut)
      if { $conf(fichier,compres) == "0" } {
         buf$num($b) compress "none"
      } else {
         buf$num($b) compress "gzip"
      }
      if { $conf(format_fichier_image) == "0" } {
         buf$num($b) bitpix ushort
      } else {
         buf$num($b) bitpix float
      }
   }

   #--- Image visu100 et visu200
   set num(visu1) [::visu::create $num(buffer1) 100 ]
   set num(visu2) [::visu::create $num(buffer2) 200 ]

   visu$num(visu1) zoom $snconfvisu(zoom_normal)
   visu$num(visu2) zoom $snconfvisu(zoom_normal)

   #--- Create a widget image in a canvas to display that of the visu space
   $zone(image1) create image 0 0 -image imagevisu100 -anchor nw -tag display
   $zone(image2) create image 0 0 -image imagevisu200 -anchor nw -tag display

   #--  Create a popup menu in Image 1 display
   set menu [ winfo toplevel $zone(image1) ].menuButton3
   menu $menu -tearoff no
      $menu add command -label "$caption(sn_tarot,galaxy_center)" \
         -command "::sn_tarot::snGalaxyCenter"
      $menu add command -label "$caption(sn_tarot,star_ref)" \
         -command "::sn_tarot::snStarRef"
      $menu add command -label "$caption(sn_tarot,star_pos)" \
         -command "::sn_tarot::snCandidate"
      $menu add command -label "$caption(sn_tarot,star_id) " \
         -command "::sn_tarot::snCreateCandidateId"
   $zone(image1) bind display <ButtonPress-3> { set snvisu(candidate,xy) [list %x [expr [$zone(image1) cget -height]-%y]] ; tk_popup [ winfo toplevel $zone(image1) ].menuButton3 %X %Y}

   #--   liste les fichiers presents dans night, references et dss
   for { set i 1 } { $i <=3 } { incr i } {
      set rep(x$i) [ lsort -dictionary [ glob -nocomplain -type f -dir $rep(name$i) *$conf(extension,defaut) ] ]
      set rep(sum$i) [ llength $rep(x$i) ]
      if { $rep(sum$i) != 0 } {
         set rep(index$i) 0
      }
   }

   #--   on cherche l'indice de l'image
   ::sn_tarot::searchGalaxy

   #--   s'il y a une image on l'affiche
   if { $rep(index1) != "-1" } {
      ::sn_tarot::displayImages
   }
}

#-----------------------------------------------------
#  changeHiCut1
#  Mise a jour des seuils de visualisation de l'image 1
#  Commande de la glissiere
#-----------------------------------------------------
proc ::sn_tarot::changeHiCut1 { foo } {
   global num snvisu

   set sbh [visu$num(visu1) cut]
   visu$num(visu1) cut [list $foo [lindex $sbh 1]]
   set snvisu(seuil_g_haut) $foo
   set snvisu(seuil_g_bas)  [lindex $sbh 1]
}

#-----------------------------------------------------
#  changeHiCut2
#  Mise a jour des seuils de visualisation de l'image 2
#  Commande de la glissiere
#-----------------------------------------------------
proc ::sn_tarot::changeHiCut2 { foo } {
   global num snvisu

   set sbh [visu$num(visu2) cut]
   visu$num(visu2) cut [list $foo [lindex $sbh 1]]
   set snvisu(seuil_d_haut) $foo
   set snvisu(seuil_d_bas)  [lindex $sbh 1]
}

#-----------------------------------------------------
#  incrImage
#  Commande du bouton 'Suivante' & 'Precedente'
#-----------------------------------------------------
proc ::sn_tarot::incrImage { { incr 1 } } {
   global rep snconfvisu

   set rep(blink,last) ""
   set old_index $rep(index1)

   #--   Traitement des limites : bloqué sur 0 ou $rep(sum1)
   set sup [ expr {$rep(sum1)-1} ]
   switch -exact $incr {
      "1"   {  if { $rep(index1) >= 0 && $rep(index1) < $sup } {
                  incr rep(index1) $incr
               }
            }
      "-1"  {  if { $rep(index1) > 0 && $rep(index1) <= $sup } {
                  incr rep(index1) $incr
               }
            }
   }

   #--   arrete si les index sont identiques
   if { $rep(index1) == $old_index } {
      return
   }

   ::sn_tarot::searchGalaxy
   ::sn_tarot::displayImages

   if { $snconfvisu(auto_blink) == "1" } {
      ::sn_tarot::snBlinkImage
   }
}

#-----------------------------------------------------
#  displayImages
#  proc lancee par nextImage et prevImage
#-----------------------------------------------------
proc ::sn_tarot::displayImages { {subsky 0} } {
   variable console_msg
   global caption rep zone num snvisu snconfvisu

   #--- Initialisation
   set afflog  "$snvisu(afflog)"

   #--- Nettoyage des 2 canvas avant affichage
   catch {
      #--- Du canvas de l'image 1
      visu$num(visu1)   clear
      buf$num(buffer1)  clear
      buf$num(buffer1b) clear
      #--- Du canvas de l'image 2
      visu$num(visu2)   clear
      buf$num(buffer2)  clear
      buf$num(buffer2b) clear
   }

   #---
   if { $afflog==0 } {
      visu$num(visu1) buf $num(buffer1)
      visu$num(visu2) buf $num(buffer2)
   } else {
      visu$num(visu1) buf $num(buffer1b)
      visu$num(visu2) buf $num(buffer2b)
   }

   #---
   set filename [ lindex $rep(x1) $rep(index1) ]
   set snvisu(name) [ file tail $filename ]

   set a [catch {buf$num(buffer1) load $filename} result]
   if {$a==1} {
      return
   }

   #-- Effectue une eventuelle correction de fond de ciel
   if {$subsky==1} {
      set back_threshold 0.2
      set back_kernel 15
      buf$num(buffer1) imaseries "BACK sub back_kernel=$back_kernel back_threshold=$back_threshold"
   }

   #--   Met a jour la ligne de titre
   $zone(labelh1) configure -text [lindex [buf$num(buffer1) getkwd DATE-OBS] 1]
   $zone(label1) configure -text "$snvisu(name)    [expr $rep(index1)+1]/$rep(sum1)"

   #---  regle la glissiere du buffer1
   lassign  [ buf$num(buffer1) stat ] sh sb scalemax scalemin
   visu$num(visu1) cut [ list $sh $sb ]

   #--- Affichage en mode logarithme
   if { $afflog==1 } {
      visu$num(visu1) cut [ ::sn_tarot::snBufLog $num(buffer1) $num(buffer1b) ]
   }

   visu$num(visu1) disp

   #--   configure la reglette de la visu1 selon le mode log/pas log
   ::sn_tarot::configScale 1

   set user [lindex [buf$num(buffer1) getkwd USER] 1]
   if {$user!=""} {
      set user "(user=[string trim ${user}])"
   }
   set name [lindex [buf$num(buffer1) getkwd NAME] 1]
   if {$name!=""} {
      set name "(name=[string trim ${name}])"
   }
   set gren_ha [lindex [buf$num(buffer1) getkwd GREN_HA] 1]
   set gren_dec [lindex [buf$num(buffer1) getkwd DEC] 1]
   set gren_alt [lindex [buf$num(buffer1) getkwd GREN_ALT] 1]
   set fwhm [lindex [buf$num(buffer1) getkwd FWHM] 1]
   set complus ""
   if {($gren_ha!="")&&($gren_dec!="")&&($gren_alt!="")&&($fwhm!="")} {
      set complus " (ha=[string trim ${gren_ha}] dec=[string trim ${gren_dec}] elev=[string trim ${gren_alt}] fwhm=[string trim ${fwhm}])"
   }
   set console_msg "[ format $caption(sn_tarot,image1) [ ::sn_tarot::shortPath $filename 7 ] $result [::sn_tarot::snCenterRaDec $num(buffer1)] $user $name $complus ]"
   ::sn_tarot::afficheConsole

   #--   charge l'image dans la visu 2 selon le choix Personnel ou DSS
   set filename ""
   if { $snconfvisu(pers_or_dss) == 0 && $rep(index2) != "-1" } {
      set filename [ lindex $rep(x2) $rep(index2) ]
   } elseif { $snconfvisu(pers_or_dss) == 1 && $rep(index3) != "-1" && $rep(sum3) != 0} {
      set filename [ lindex $rep(x3) $rep(index3) ]
   } else {
      set filename [ lindex $rep(x2) $rep(index2) ]
   }

   set result ""
   set a [catch { buf$num(buffer2) load $filename } result]
   if { $a == 1 } {
      #--   Met a jour la ligne de titre
      $zone(labelh2) configure -text "-"
      return
   }

   set console_msg "[ format $caption(sn_tarot,image2) [ ::sn_tarot::shortPath $filename 7 ] $result ]"
   ::sn_tarot::afficheConsole

   #-- Effectue une eventuelle correction de fond de ciel
   if {$subsky==1} {
      buf$num(buffer2) imaseries "BACK sub back_kernel=$back_kernel back_threshold=$back_threshold"
   }

   #--   Met a jour la ligne de titre
   $zone(labelh2) configure -text [lindex [buf$num(buffer2) getkwd DATE-OBS] 1]

   #---
   catch {
      lassign [ buf$num(buffer2) stat ] sh sb
      visu$num(visu2) cut [ list $sh $sb ]
   }

   #--- Affichage en mode logarithme
   if {$afflog==1} {
      visu$num(visu2) cut [ ::sn_tarot::snBufLog $num(buffer2) $num(buffer2b) ]
   }

   visu$num(visu2) disp

   if {$result==""} {
      #--   configure la reglette de la visu2 selon le mode log/pas log
      ::sn_tarot::configScale 2
   } else {
      if {$afflog==0} {
         set seuil [lindex [::sn_tarot::getSeuils $num(buffer2)] 0]
      } else {
         set seuil [lindex [::sn_tarot::getSeuils $num(buffer2b)] 0]
      }
      $zone(sh2) set $seuil
      $zone(labelh2) configure -text ""
   }
   set snvisu(candidate,starref_coords) ""
   set snvisu(candidate,host_coords) ""
   set snvisu(candidate,sn_coords) ""
}

#-----------------------------------------------------
#  gotoImage
#  Commande du bouton 'Aller a'
#-----------------------------------------------------
proc ::sn_tarot::gotoImage { } {
   global audace caption zone info_image

   set fram $audace(base).snvisu_1

   #---
   if { [ winfo exists $fram ] } {
      wm withdraw $fram
      wm deiconify $fram
      focus $fram.but_cancel
      return
   }

   #--- Create the toplevel window .snvisu_1
   #--- Cree la fenetre .snvisu_1 de niveau le plus haut
   toplevel $fram -class Toplevel
   wm title $fram $caption(sn_tarot,secondary_title)
   set posx_snvisu_1 [ lindex [ split [ wm geometry $audace(base).snvisu ] "+" ] 1 ]
   set posy_snvisu_1 [ lindex [ split [ wm geometry $audace(base).snvisu ] "+" ] 2 ]
   wm geometry $fram +[ expr $posx_snvisu_1 + 490 ]+[ expr $posy_snvisu_1 + 160 ]

   wm resizable $fram 0 0
   wm transient $fram $audace(base).snvisu
   wm protocol $fram WM_DELETE_WINDOW { set command_line2 "" ; destroy $audace(base).snvisu_1 }

   #--- Create the label and the command line
   #--- Cree l'etiquette et la ligne de commande
   frame $fram.frame1 -borderwidth 0 -relief raised
      label $fram.frame1.label -text $caption(sn_tarot,image_numero) \
         -borderwidth 0 -relief flat
      pack $fram.frame1.label -fill x -side left -padx 5 -pady 5
      entry $fram.frame1.command_line -textvariable command_line2 \
         -borderwidth 1 -relief groove -takefocus 1 -width 8
      pack $fram.frame1.command_line -fill x -side right -padx 5 -pady 5
   pack $fram.frame1 -side top -fill both -expand 1

   #--- Je place le focus immediatement dans la zone de saisie
   focus $fram.frame1.command_line

   #--- Create the button 'GO'
   #--- Cree le bouton 'GO'
   button $fram.but_go -text $caption(sn_tarot,go) -borderwidth 2 -width 10 \
      -command {
         if { $command_line2 != "" } {
            set rep(index1) [ expr {$command_line2-1} ]
            ::sn_tarot::searchGalaxy
            ::sn_tarot::displayImages
            destroy $audace(base).snvisu_1
         }
      }
   pack $fram.but_go -side left -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5

   #--- Create the button 'Cancel'
   #--- Cree le bouton 'Annuler'
   button $fram.but_cancel -text $caption(sn_tarot,cancel) -borderwidth 2  -width 10 \
      -command { set command_line2 "" ; destroy $audace(base).snvisu_1 }
   pack $fram.but_cancel -side right -anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5

   #--- La touche Return est equivalente au bouton "but_go"
   bind $fram <Key-Return>  { $audace(base).snvisu_1.but_go invoke }

   #--- La touche Escape est equivalente au bouton "but_cancel"
   bind $fram <Key-Escape>  { $audace(base).snvisu_1.but_cancel invoke }

   $fram.frame1.command_line selection range 0 end

   #--- La fenetre est active
   focus $fram

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fram
}

#-----------------------------------------------------
#  snSubSky
#  Commande du bouton 'Fond du ciel'
#-----------------------------------------------------
proc ::sn_tarot::snSubSky { } {
   variable console_msg
   global audace

   set w $audace(base).snvisu.fr4.but_background

   #--- Gestion du bouton 'background'
   $w configure -relief groove -state disabled
   update

   ::sn_tarot::displayImages 1

   #--- Gestion du bouton 'background'
   $w configure -relief raised -state normal
   update
}

#-----------------------------------------------------
#  snBlinkImage
#  Commande du bouton 'Blink'
#-----------------------------------------------------
proc ::sn_tarot::snBlinkImage { } {
   global audace caption conf num snconfvisu snvisu zone rep panneau

   #--- Execute le blink uniquement s'il y a une image dans le canvas 1
   if { [ buf$num(buffer2) imageready ] == "0" } {
      return
   }

   #--- Animation en cours
   set snvisu(blink_go) "1"

   #--- Initialisation
   set rep(blink,last) ""
   set afflog          "$snvisu(afflog)"

   #---
   if {$afflog==0} {
      visu$num(visu1) buf $num(buffer1)
      visu$num(visu2) buf $num(buffer2)
   } else {
      visu$num(visu1) buf $num(buffer1b)
      visu$num(visu2) buf $num(buffer2b)
   }

   #--- Recentrage de l'image de reference
   set b [::buf::create]
   set ext $conf(extension,defaut)
   buf$b extension "$ext"
   set compress [buf$audace(bufNo) compress]
   buf$b compress "$compress"
   set bitpix [buf$audace(bufNo) bitpix]
   buf$b bitpix "$bitpix"
   set filename [lindex $rep(x1) $rep(index1)]
   set dir $panneau(init_dir)
   if {$rep(blink,last)!=$filename} {
      set rep(blink,last) "$filename"
      buf$num(buffer2) copyto $b
      set dimx [lindex [buf$num(buffer1) getkwd NAXIS1 ] 1]
      set dimy [lindex [buf$num(buffer1) getkwd NAXIS2 ] 1]
      buf$b window [list 1 1 $dimx $dimy]
      buf$b            save [ file join $dir dummy2 ]
      buf$num(buffer1) save [ file join $dir dummy1 ]
      set objefile "__dummy__"
      set error [ catch {
         set wcs1 [::sn_tarot::snVerifWCS $num(buffer1)]
         set wcs2 [::sn_tarot::snVerifWCS $b]
         if {($wcs1==0)||($wcs2==0)} {
            ttscript2 "IMA/SERIES \"$dir\" \"dummy\" 1 2 \"$ext\" \"$dir\" \"$objefile\" 1 \"$ext\" STAT objefile"
            ttscript2 "IMA/SERIES \"$dir\" \"$objefile\" 1 2 \"$ext\" \"$dir\" \"dummyb\" 1 \"$ext\" REGISTER translate=never"
            ttscript2 "IMA/SERIES \"$dir\" \"$objefile\" 1 2 \"$ext\" \"$dir\" \"$objefile\" 1 \"$ext\" DELETE"
         } else {
            ttscript2 "IMA/SERIES \"$dir\" \"dummy\" 1 2 \"$ext\" \"$dir\" \"dummyb\" 1 \"$ext\" REGISTER matchwcs"
         }
      } msg ]
      #--- Interception de l'erreur
      if { $error == "1" } {
         tk_messageBox -title "$caption(sn_tarot,attention)" -type ok -message "$msg \n"
         #--- Detruit les fichiers intermediaires
         file delete [ file join $dir dummy1$ext ]
         file delete [ file join $dir dummy2$ext ]
         file delete [ file join $dir dummyb2$ext ]
         catch { file delete [ file join $rep(name1) __dummy__1$ext ] }
         file delete [ file join [pwd] com.lst ]
         file delete [ file join [pwd] dif.lst ]
         file delete [ file join [pwd] eq.lst ]
         file delete [ file join [pwd] in.lst ]
         file delete [ file join [pwd] ref.lst ]
         file delete [ file join [pwd] xy.lst ]
         #---
         return
      }
      buf$b load [ file join $dir dummyb2 ]
      #--- Affichage en mode logarithme
      if {$afflog==1} {
         set shsb [::sn_tarot::snBufLog $b $b]
      } else {
         set shsb [visu$num(visu2) cut]
      }
      #---
      set text0 "[buf$b getkwd MIPS-LO]"
      set text0 [lreplace $text0 1 1 [lindex $shsb 1]]
      buf$b setkwd $text0
      set text0 "[buf$b getkwd MIPS-HI]"
      set text0 [lreplace $text0 1 1 [lindex $shsb 0]]
      buf$b setkwd $text0
      buf$b save [ file join $dir dummyb2 ]
      ttscript2 "IMA/SERIES \"$dir\" \"dummyb\" 1 1 \"$ext\" \"$dir\" \"$objefile\" 1 \"$ext\" DELETE"
   } else {
      catch { buf$b load [ file join $dir dummyb2 ] }
   }

   #--- Gestion du bouton 'blink'
   $audace(base).snvisu.fr4.but_blink_go configure -text $caption(sn_tarot,blink_stop) -command { set snvisu(exit_blink) "0" }
   update

   #--- Creation de la Tk_photoimage pour le blink
   catch { image delete imagevisu101 }
   ::visu::create $b 101 101
   image create photo imagevisu101
   visu101 zoom $snconfvisu(zoom_normal)
   visu101 disp [ list $snvisu(seuil_d_haut) $snvisu(seuil_d_bas) ]

   #--- Animation
   for { set t 1 } { $t <= $snconfvisu(nb_blink) } { incr t } {
      catch {
         $zone(image1) itemconfigure display -image imagevisu100
         update
         after $snconfvisu(delai_blink)
         $zone(image1) itemconfigure display -image imagevisu101
         update
         after $snconfvisu(delai_blink)
      }
      if { $snvisu(exit_blink) == "0" } {
         break
      }
   }

   #--- Detruit les visu et les Tk_photoimage
   ::visu::delete 101
   catch { image delete imagevisu101 }
   ::buf::delete $b

   #--- Detruit les fichiers intermediaires
   file delete [ file join $dir dummy1$ext ]
   file delete [ file join $dir dummy2$ext ]
   file delete [ file join $dir dummyb2$ext ]
   catch { file delete [ file join $dir __dummy__1$ext ] }
   file delete [ file join [pwd] com.lst ]
   file delete [ file join [pwd] dif.lst ]
   file delete [ file join [pwd] eq.lst ]
   file delete [ file join [pwd] in.lst ]
   file delete [ file join [pwd] ref.lst ]
   file delete [ file join [pwd] xy.lst ]

   #--- Reconfigure pour Aud'ACE normal
   catch {$zone(image1) itemconfigure display -image imagevisu100}
   update

   #--- Gestion du bouton 'blink'
   $audace(base).snvisu.fr4.but_blink_go configure -text $caption(sn_tarot,blink_go) -command { set snvisu(exit_blink) "1" ; ::sn_tarot::snBlinkImage }
   update

   #--- Animation terminee
   set snvisu(blink_go) "0"
}

#-----------------------------------------------------
#  saveImage
#  Sauve la nouvelle image de reference
#-----------------------------------------------------
proc ::sn_tarot::saveImage { } {
   variable console_msg
   global caption num rep

   #---
   set rep(blink,last) ""

   #--- on recharge l'image originale car on a pu enlever le ciel entre temps
   set filename [lindex $rep(x1) $rep(index1)]
   set a [catch {buf$num(buffer1) load $filename} result]
   if {$a==1} {
      return
   }
   if { $filename != "" } {
      set name [file tail $filename]
      set shortname [string range $name 0 [expr [string last - $name]-1]]
      if { $shortname != "" } {
         set filename [ file join $rep(name2) ${shortname}[file extension $name] ]
      } else {
         set filename [ file join $rep(name2) $name ]
      }
      #--- Destruction des eventuels fichiers existants deja
      catch { file delete $filename }
      catch { file delete $filename.gz }
      #---
      if { $rep(gz) == "yes" } {
         set result [ buf$num(buffer1) save $filename ]
         gzip $filename
         set console_msg "$caption(sn_tarot,newref) -> $filename.gz"
      } else {
         set result [ buf$num(buffer1) save $filename ]
         set console_msg "$caption(sn_tarot,newref) -> [ ::sn_tarot::shortPath "" 7 ]"
      }
      set k [ lsearch $rep(x2) $filename ]
      if {$k==-1} {
         lappend rep(x2) $filename
      }
      ::sn_tarot::searchGalaxy
      ::sn_tarot::afficheConsole
      #--- Mise a jour de l'affichage avec la nouvelle image de reference
      ::sn_tarot::displayImages
   } else {
      set console_msg "$caption(sn_tarot,0image)"
      ::sn_tarot::afficheConsole
   }
}

#-----------------------------------------------------
#  snSelect
#  Commande de la combobox de selection du dossier a traiter
#-----------------------------------------------------
proc ::sn_tarot::snSelect { } {
   global audace caption conf snconfvisu rep snvisu

   set w $audace(base).snvisu.fr4

   ::sn_tarot::unzipFile [ file join $rep(archives) $snconfvisu(night).zip ] $rep(name1)

   #--   rafraichit la liste des fichiers presents (chemin complet) dans night
   set rep(x1) [ lsort -dictionary [ glob -nocomplain -type f -dir $rep(name1) *$conf(extension,defaut) ] ]
   set rep(sum1) [ llength $rep(x1) ]

   #--   liste les images DSS manquantes
   set file_to_load ""
   foreach file $rep(x1) {
      set img [ file tail $file ]
      if { ![ file exists [ file join $rep(name3) $img ] ] } {
         lappend file_to_load $img
      }
   }

   #--
   if { $file_to_load ne "" } {
      set answer [tk_messageBox -title $caption(sn_tarot_go,attention) \
                     -icon info -type yesno \
                     -message [format $caption(sn_tarot_go,dss_download) $file_to_load ]]
      if { $answer eq "yes" } {
         #--  bascule vers 'Personnel'
         if { $snconfvisu(pers_or_dss) == 1 } {
            set snconfvisu(pers_or_dss) 0
         }

         #--   inhibe le radiobouton DSS
         $w.but_rad1 configure -state disabled

         #--   ote l'extension pour ne garder que les noms courts
         regsub -all ".fit" $file_to_load "" file_to_load
         set total [ llength $file_to_load ]

         #set t0 [ clock seconds ]

         #set n [ ::sn_tarot::listRequest $file_to_load ]
         ::sn_tarot::listRequest $file_to_load

         #--   signale la fin du chargement
         #set t1 [ clock seconds ]
         #set t [ expr { $t1-$t0} ]
         #tk_messageBox -icon info -type ok \
         #   -message "[ format $caption(sn_tarot,dss_end) $n $total $t]"

         #--   met a jour la liste des fichiers et leur nombre
         set rep(x3) [ lsort -dictionary [ glob -nocomplain -type f -dir $rep(name3) *$conf(extension,defaut) ] ]
         set rep(sum3) [ llength $rep(x3) ]

         if { $rep(sum3) != 0 } {
            #--   desinhibe le radiobouton DSS
            $w.but_rad1 configure -state normal
         }
      }
   } else {
      #--   si pas de fichiers manquants
      tk_messageBox -title $caption(sn_tarot_go,attention) \
         -icon info  -type ok \
         -message "$caption(sn_tarot_go,no_dss_download)"
   }

   #--   affiche le nom de l'archive dans le titre
   set snconfvisu(archive) $snconfvisu(night)
   $audace(base).snvisu.lab configure -text [ format $caption(sn_tarot,title) $snconfvisu(archive) ]

   #--   selectionne la premiere image de la nouvelle serie
   set rep(index1) 0
   ::sn_tarot::searchGalaxy
   ::sn_tarot::displayImages
}

#-----------------------------------------------------
#  snDelete
#  Commande du bouton 'Quitter'
#-----------------------------------------------------
proc ::sn_tarot::snDelete { } {
   global num audace conf snvisu snconfvisu rep panneau

   #--- On ne ferme SnVisu que s'il n'y a pas de blink en cours
   if { $snvisu(blink_go) == "1" || $snvisu(dss) == "1" } {
      return
   }

   set conf(sn_tarot,geometry) "[ wm geometry $audace(base).snvisu ]"

   #--- Supprime les images
   image delete imagevisu100
   image delete imagevisu200

   #--- Supprime les visu
   ::visu::delete $num(visu1)
   ::visu::delete $num(visu2)

   #--- Supprime les buffer
   foreach b [ list buffer1 buffer1b buffer2 buffer2b ] {
      ::buf::delete $num($b)
   }

   #--- Efface les fenetres gotoImage, htmImage et snSetup si elles existent
   foreach fen [ list snvisu_1 snvisu_2 snvisu_3 ] {
      if { [ winfo exists $audace(base).$fen ] } {
         destroy $audace(base).$fen
      }
   }

   #---
   destroy $audace(base).snvisu

   #--- Nettoyage des eventuels fichiers crees
   foreach file [ list filter filter2 filter3 ] {
      set f [ file join $rep(name1) $file$conf(extension,defaut) ]
      if { [ file exist $f ] } {
         file delete $f
      }
   }

   #--   memorise le nom du telescope et fichier selectionne
   set conf(sn_tarot,last_archive) "$snconfvisu(night)"
}

#--------------- bindings sans boutons -----------------

#-----------------------------------------------------
#  snHeader
#  Commande de binding associe a <Key-F5> et <Key-F6>
#   Parametre : N° du buffer 1 ou 2 selon cote
#-----------------------------------------------------
proc ::sn_tarot::snHeader { bufnum } {
   global audace caption color num snvisu

   #--   raccourci
   set w $audace(base).snheader

   if { [ winfo exists $w ] } {
      destroy $w
   }

   if { [ buf$bufnum imageready ] == "1" } {
      if { $bufnum == "$num(buffer1)" } {
         set title "$caption(sn_tarot,fits_header) : $snvisu(name)     [ lindex [ buf$num(buffer1) getkwd DATE-OBS ] 1 ]"
      } elseif { $bufnum == "$num(buffer2)" } {
         set title "$caption(sn_tarot,fits_header) - $caption(sn_tarot,reference) : \
            $snvisu(name)      [ lindex [ buf$num(buffer2) getkwd DATE-OBS ] 1 ]"
      }
   } else {
      if { $bufnum == "$num(buffer1)" } {
         set title "$caption(sn_tarot,fits_header)"
      } elseif { $bufnum == "$num(buffer2)" } {
         set title "$caption(sn_tarot,fits_header) - $caption(sn_tarot,reference)"
      }
   }

   toplevel $w
   wm transient $w $audace(base).snvisu
   if { [ buf$bufnum imageready ] == "1" } {
      wm minsize $w 632 303
   }
   wm resizable $w 1 1
   wm title $w "$title"
   wm geometry $w 632x303+3+75

   Scrolled_Text $w.slb -width 150 -height 20
   pack $w.slb -fill y -expand true

   if { [ buf$bufnum imageready ] == "1" } {
      $w.slb.list tag configure keyw -foreground $color(blue)
      $w.slb.list tag configure egal -foreground $color(black)
      $w.slb.list tag configure valu -foreground $color(red)
      $w.slb.list tag configure comm -foreground $color(green1)
      $w.slb.list tag configure unit -foreground $color(orange)
      foreach kwd [ lsort -dictionary [ buf$bufnum getkwds ] ] {
         set liste [ buf$bufnum getkwd $kwd ]
         #--- je fais une boucle pour traiter les mots cles a valeur multiple
         foreach { name value type comment unit } $liste {
            $w.slb.list insert end "[format "%8s" $name] " keyw
            $w.slb.list insert end "= "                    egal
            $w.slb.list insert end "$value "               valu
            $w.slb.list insert end "$comment "             comm
            $w.slb.list insert end "$unit\n"               unit
         }
      }
   } else {
      $w.slb.list insert end "$caption(sn_tarot,header,noimage)"
   }

   #--- La nouvelle fenetre est active
   focus $w

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#-----------------------------------------------------
#  noCosmic
#  Applique un filtre median sur l'image de la nuit pour eliminer les cosmiques
#  Commande de binding associe a <Key-F7>
#-----------------------------------------------------
proc ::sn_tarot::noCosmic { } {
   global conf rep

   if { $rep(index1) != "-1" } {
      set ext $conf(extension,defaut)
      set src [ lindex $rep(x1) $rep(index1) ]
      set name [ file rootname [ file tail $src ] ]
      ttscript2 "IMA/SERIES \"$rep(name1)\" \"$name\" . . $ext \"$rep(name1)\" filter . $ext FILTER kernel_type=med kernel_width=3 kernel_coef=1.2"
      ::sn_tarot::afficheImg $src filter$ext 1
   }
}

#-----------------sous-proc --------------------------

#-----------------------------------------------------
#  snBufLog
#  Mode log
#  sous-proc de displayImages et snBlinkImage
#  Parametres :
#-----------------------------------------------------
proc ::sn_tarot::snBufLog { numbuf bufno } {

   set n1 [buf$numbuf getpixelswidth]
   if {$n1==0} {
      return [list 0 0]
   }
   if {$numbuf!=$bufno} {
      buf$numbuf copyto $bufno
   }
   lassign   [ lrange [buf$bufno stat] 6 7 ] fond sigma
   set seuil [expr $fond-3.*$sigma]
   buf$bufno log 1000 [expr -1.*$seuil]
   lassign   [ lrange [buf$bufno stat] 6 7 ] fond sigma
   set sb    [expr $fond-5.*$sigma]
   set n1    [buf$bufno getpixelswidth]
   set n2    [buf$bufno getpixelsheight]
   set d     4
   set x1    [expr $n1/2-$d]
   set x2    [expr $n1/2+$d]
   set y1    [expr $n2/2-$d]
   set y2    [expr $n2/2+$d]
   set box   [list $x1 $y1 $x2 $y2]
   set res   [buf$bufno stat $box]
   set maxi  [lindex $res 2]
   set sh    [expr 1.*$maxi]
   if {$sh<=$sb} {
      set sh [expr $sb+10.*$sigma]
   }
   buf$bufno setkwd  [list MIPS-LO [expr int($sb)] int "seuil bas" ""]
   buf$bufno setkwd  [list MIPS-HI [expr int($sh)] int "seuil haut" ""]
   buf$numbuf setkwd [list MIPS-LO [expr int($sb)] int "seuil bas" ""]
   buf$numbuf setkwd [list MIPS-HI [expr int($sh)] int "seuil haut" ""]
   return [list $sh $sb]
}

#-----------------------------------------------------
#  confirmSave
#  Commande du bouton 'Enregistrer'
#-----------------------------------------------------
proc ::sn_tarot::confirmSave { } {
   global audace caption num

   if { [ buf$num(buffer1) imageready ] == "1" } {
      set choix [ tk_messageBox -type yesno -icon warning \
         -title "$caption(sn_tarot,save1)" \
         -message "$caption(sn_tarot,confirm)" ]
      if { [ winfo exists $audace(base).snvisu ] } {
         if { $choix == "yes" } {
            ::sn_tarot::saveImage
         }
         focus $audace(base).snvisu
      }
   }
}

#-----------------------------------------------------
#  setSeuils
#  Routine de lecture des seuils
#  Recherche d'abord kwd1 puis kwd2 sinon fixe une valeur
#-----------------------------------------------------
proc ::sn_tarot::setSeuils { numbuf } {

   foreach { v kwd1 kwd2 val } [ list hi MIPS-HI DATAMAX nf lo MIPS-LO DATAMIN nf ] {
      set $v [ lindex [ buf$numbuf getkwd $kwd1 ] 1 ]
      if { [ set $v ] == "" } {
         set $v [ lindex [ buf$numbuf getkwd $kwd1 ] 1 ]
      }
      if { [ set $v ] == "" } {
         set $v $val
      }
   }

   if { $hi=="nf" || $lo=="nf" } {
      set hi [ lindex [ buf$numbuf getkwd MIPS-HI ] 1 ]
      set lo [ lindex [ buf$numbuf getkwd MIPS-LO ] 1 ]
   }
   visu$numbuf cut [ list $hi $lo ]
}

#-----------------------------------------------------
#  configScale
#  sous-proc de displayImages
#  Paremtre :  1 ou 2 selon le cote
#-----------------------------------------------------
proc ::sn_tarot::configScale { visu } {
   global snvisu zone num

   set afflog $snvisu(afflog)

   if {$afflog==0} {
      set nume $num(buffer${visu})
   } else {
      set nume $num(buffer${visu}b)
   }

   set scalecut [ lindex [ ::sn_tarot::getSeuils $nume ] 0 ]
   set err [ catch { buf$nume stat } s ]
   if { $err == "0" } {
      set scalemax [ lindex $s 2 ]
      set scalemin [ lindex $s 3 ]
      if {($scalecut>=$scalemin)&&($scalecut<=$scalemax)} {
         set ds1 [expr $scalemax-$scalecut]
         set ds2 [expr $scalecut-$scalemin]
         if {$ds1>$ds2} {
            set scalemin [expr $scalecut-$ds1]
         } else {
            set scalemax [expr $scalecut+$ds2]
         }
      }
      $zone(sh${visu}) configure -to $scalemax -from $scalemin
   }
   $zone(sh${visu}) set $scalecut
   update
}

#-----------------------------------------------------
#  getSeuils
#  Routine de lecture des seuils
#  Recherche d'abord kwd1 puis kwd2 sinon fixe une valeur
#  Parametre : N° du buffer
#-----------------------------------------------------
proc ::sn_tarot::getSeuils { numbuf } {

   foreach { v kwd1 kwd2 val } [ list hi MIPS-HI DATAMAX 32768 lo MIPS-LO DATAMIN 32768 ] {
      set $v [ lindex [ buf$numbuf getkwd $kwd1 ] 1 ]
      if { [ set $v ] == "" } {
         set $v [ lindex [ buf$numbuf getkwd $kwd1 ] 1 ]
      }
      if { [ set $v ] == "" } {
         set $v $val
      }
   }
   return [ list $hi $lo ]
}

#-----------------------------------------------------
#  afficheImg
#  Affiche une image filtree
#  Sous-proc de noCosmic et de snSubSky
#  Parametres : chemin du fichier source, nom de l'image filtree
#  et 1 ou 2 selon le cote
#-----------------------------------------------------
proc ::sn_tarot::afficheImg { src filter_file i } {
   variable console_msg
   global caption num zone rep

   #--   toutes les images 'filter' sont dans rep(name1)
   set file [ file join $rep(name1) $filter_file ]

   set result [ buf$num(buffer$i) load $file ]
   visu$num(visu$i) disp
   $zone(sh$i) set [ lindex [ ::sn_tarot::getSeuils $num(buffer$i) ] 0 ]

   set console_msg "[ format $caption(sn_tarot,filter) [ ::sn_tarot::shortPath $src 7 ] \
      [ ::sn_tarot::shortPath $file 7 ] $result ]"
   ::sn_tarot::afficheConsole
}

#------------------------------------------------------------
# shortPath
#     Retourne le nom du repertoire a partir de Mes Documents/....
# Utilisée pour avoir une longueur de fichier raisonnable
# n=3 Mes Documents/.... n=4 audela/... n=6 tarot/...
#------------------------------------------------------------
proc ::sn_tarot::shortPath { dir n } {

   set rep  [ lrange [ split $dir / ] $n end ]
   set f [ lindex $rep 0 ]
   foreach dos [ lrange $rep 1 end ] {
      set f [ file join $f $dos ]
   }
   return $f
}
#-----------------------------------------------------
#  afficheConsole
#  Affiche un message dans la mini-console
#  Sous-proc de afficheImg et de displayImages
#-----------------------------------------------------
#  Affiche dans la console de retour d'etats
proc ::sn_tarot::afficheConsole { } {
   variable console_msg
   global audace

   $audace(base).snvisu.lst1 insert end $console_msg
   $audace(base).snvisu.lst1 yview moveto 1.0

   #--- Disparition du sautillement des widgets inferieurs
   pack $audace(base).snvisu.lst1.scr1 -fill y -side right -anchor ne
}

#-----------------------------------------------------
#  searchGalaxy
#  Cherche l'existence de la galaxie dans references et dss
#  Configure les radioboutons en fonction de l'existence
#  Sous-proc de confTarotVisu, de incrImage, de snSelect et de gotoImage
#-----------------------------------------------------
proc ::sn_tarot::searchGalaxy { } {
   global audace rep snvisu

   #--   isole le nom court de l'image
   set snvisu(name) [ file tail [ lindex $rep(x1)  $rep(index1) ] ]

   foreach { rep_name f index but } [ list name2 x2 index2 but_rad0 name3 x3 index3 but_rad1 ] {
      set state disabled
      set rep($index) -1
      set reference_name [ file join $rep($rep_name) $snvisu(name) ]
      if { [ file exists $reference_name ] == 1 } {
         set rep($index) [ lsearch $rep($f) $reference_name ]
         set state normal
      }
      $audace(base).snvisu.fr4.$but configure -state normal
   }
}

#------- toutes les proc Configuration ---------------

#-----------------------------------------------------
#  snSetup
#  Commande du bouton 'Configuration'
#-----------------------------------------------------
proc ::sn_tarot::snSetup { } {
   global audace caption conf snconfvisu

   #--   raccourci
   set fconf $audace(base).snvisu_3

   if { [ winfo exists $fconf ] } {
      wm withdraw $fconf
      wm deiconify $fconf
      #focus $fconf.but_cancel
      return
   }

   #--- Create the toplevel window .snvisu_3
   #--- Cree la fenetre .snvisu_3 de niveau le plus haut
   toplevel $fconf -class Toplevel
   wm title $fconf $caption(sn_tarot,config_title)
   regsub -all {[\+|x]} [ wm geometry $audace(base).snvisu ]  " " pos
   wm geometry $fconf +[expr {[ lindex $pos 1 ] + 165 } ]+[ expr {[ lindex $pos 2 ] + 100} ]
   wm resizable $fconf 0 0
   wm transient $fconf $audace(base).snvisu
   wm protocol $fconf WM_DELETE_WINDOW { set command_line2 "" ; destroy $fconf }

   #--- Create the label and the radiobutton
   #--- Cree l'etiquette et les radiobuttons
   frame $fconf.frame1 -borderwidth 0 -relief raised
      #--- Label
      label $fconf.frame1.label -text $caption(sn_tarot,rafraich_images) \
         -borderwidth 0 -relief flat
      pack $fconf.frame1.label -fill x -side left -padx 5 -pady 5
      #--- Bouton radio 1 - Option "motion"
      radiobutton $fconf.frame1.but_rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text $caption(sn_tarot,motion) -value "motion" -variable snconfvisu(cuts_change) \
         -command "::sn_tarot::confBindCuts"
      pack $fconf.frame1.but_rad0 -side left -anchor center -padx 5 -pady 5
      #--- Bouton radio 2 - Option "release"
      radiobutton $fconf.frame1.but_rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text $caption(sn_tarot,release) -value "release" -variable snconfvisu(cuts_change) \
         -command "::sn_tarot::confBindCuts"
      pack $fconf.frame1.but_rad1 -side left -anchor center -padx 5 -pady 5
   pack $fconf.frame1 -side top -fill both -expand 1

   #--- Create the label and the command lines
   #--- Cree l'etiquette et les lignes de commande
   frame $fconf.frame2 -borderwidth 0 -relief raised
      #--- Label
      label $fconf.frame2.label -text $caption(sn_tarot,blink_delai) \
         -borderwidth 0 -relief flat
      pack $fconf.frame2.label -fill x -side left -padx 5 -pady 5
      #--- Entry
      entry $fconf.frame2.command_line -textvariable snconfvisu(delai_blink) \
         -borderwidth 1 -relief groove -takefocus 1 -width 8 -justify center
      pack $fconf.frame2.command_line -fill x -side left -padx 5 -pady 5
      #--- Label
      label $fconf.frame2.label1 -text $caption(sn_tarot,blink_nbre) \
         -borderwidth 0 -relief flat
      pack $fconf.frame2.label1 -fill x -side left -padx 5 -pady 5
      #--- Entry
      entry $fconf.frame2.command_line_1 -textvariable snconfvisu(nb_blink) \
         -borderwidth 1 -relief groove -takefocus 1 -width 8 -justify center
      pack $fconf.frame2.command_line_1 -fill x -side left -padx 5 -pady 5
      #--- Label
      label $fconf.frame2.label2 -text $caption(sn_tarot,auto_blink) \
         -borderwidth 0 -relief flat
      pack $fconf.frame2.label2 -fill x -side left -padx 5 -pady 5

      #--- Checkbutton
      checkbutton $fconf.frame2.auto -text "$caption(sn_tarot,auto_blink)" \
         -highlightthickness 0 -variable snconfvisu(auto_blink)
      pack $fconf.frame2.auto -anchor center -side left \
        -padx 5 -pady 5

   pack $fconf.frame2 -side top -fill both -expand 1

   #--- Create the label and the radiobutton
   #--- Cree l'etiquette et les radiobuttons
   frame $fconf.frame4 -borderwidth 0 -relief raised
      #--- Label
      label $fconf.frame4.label -text $caption(sn_tarot,image_gzip) \
         -borderwidth 0 -relief flat
      pack $fconf.frame4.label -fill x -side left -padx 5 -pady 5
      #--- Bouton radio 1 - Option enregistrement image non compressee
      radiobutton $fconf.frame4.but_rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$conf(extension,defaut)" -value "no" -variable snconfvisu(gzip) \
         -command { set rep(gz) "$snconfvisu(gzip)" }
      pack $fconf.frame4.but_rad0 -side left -anchor center -padx 5 -pady 5
      #--- Bouton radio 2 - Option enregistrement image compressee
      radiobutton $fconf.frame4.but_rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$conf(extension,defaut).gz" -value "yes" -variable snconfvisu(gzip) \
         -command { set rep(gz) "$snconfvisu(gzip)" }
      pack $fconf.frame4.but_rad1 -side left -anchor center -padx 5 -pady 5
   pack $fconf.frame4 -side top -fill both -expand 1

   #--- Create the button 'GO'
   #--- Cree le bouton 'GO'
   button $fconf.but_go -text $caption(sn_tarot,go) \
      -borderwidth 2 -width 8 -command "::sn_tarot::snSaveConfig"
   pack $fconf.but_go -side left -anchor w -padx 5 -pady 5

   #--- Create the button 'Cancel'
   #--- Cree le bouton 'Annuler'
   button $fconf.but_cancel -text $caption(sn_tarot,cancel) -width 8 \
      -borderwidth 2 -command "destroy $audace(base).snvisu_3"
   pack $fconf.but_cancel -side right -anchor w -padx 5 -pady 5

   #--- Create the button 'Help'
   #--- Cree le bouton 'Aide'
   button $fconf.but_help -text $caption(sn_tarot,aide) \
      -borderwidth 2 -width 8 -command "::sn_tarot::snHelp sn_config"
   pack $fconf.but_help -side right -anchor w -padx 5 -pady 5

   #--- La touche Escape est equivalente au bouton "but_cancel"
   bind $fconf <Key-Escape> { $audace(base).snvisu_3.but_cancel invoke }

   #--- La touche Return est equivalente au bouton "but_go"
   bind $fconf <Key-Return> { $audace(base).snvisu_3.but_go invoke }

   #--- La fenetre est active
   focus $fconf

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fconf
}

#-----------------------------------------------------
#  confBindCuts
#  Commande associée aux radiobutton de selection dans Configuration
#-----------------------------------------------------
proc ::sn_tarot::confBindCuts { } {
   global zone num snconfvisu

   if { [ string tolower "$snconfvisu(cuts_change)" ] == "motion" } {
      set cmd Motion
   } else {
      set cmd ButtonRelease
   }
   bind $zone(sh1) <$cmd> { visu$num(visu1) disp }
   bind $zone(sh2) <$cmd> { visu$num(visu2) disp }
}

#-----------------------------------------------------
#  snSaveConfig
#  Commande du bouton 'Go' de la Configuration
#  Les valeurs sont sauvees sous forme de liste
#-----------------------------------------------------
proc ::sn_tarot::snSaveConfig { } {
   global audace conf caption snconfvisu

   set conf(sn_tarot) [ list \
      "$snconfvisu(cuts_change)" \
      "$snconfvisu(delai_blink)" \
      "$snconfvisu(nb_blink)" \
      "$snconfvisu(auto_blink)" \
      "$snconfvisu(gzip)" ]

   destroy $audace(base).snvisu_3
   tk_messageBox -message "$caption(sn_tarot,alerte)" \
      -icon warning -title "$caption(sn_tarot,attention)"
}

#------------------  utilitaires ----------------------------

#------------------------------------------------------------
# unzipFile
#     Decompresse le fichier zip (nom cmplet) vers le dossier (destination)
# Liee a proc ::sn_tarot::snSelect
#------------------------------------------------------------
proc ::sn_tarot::unzipFile { fullfile_zip path } {
   global audace conf caption

   set ext $conf(extension,defaut)

   #--   nettoie le dossier de destination
   set fics [ glob -nocomplain -type f -tails -dir $path *$ext ]
   set nb [ llength $fics ]
   if { $nb != 0 } {
      ttscript2 "IMA/SERIES \"$path\" \"$fics\" * * . . . . . DELETE"
   }

   #--   chemin de unzip.exe
   set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]
   #--   decompresse les images vers le dossier de destination
   exec $tarot_unzip -d $path $fullfile_zip

   #--   informe utilisateur
   set nb [ llength [ glob -nocomplain -type f -tails -dir $path *$ext ] ]
   set raccourci [ ::sn_tarot::shortPath $path 3 ]
   tk_messageBox -icon info -type ok \
      -message [ format $caption(sn_tarot_go,unzip) [ file tail $fullfile_zip ] $nb $raccourci ]
}

#------------------------------------------------------------
# createProgressBar
# Marque la porgression du téléchargement des images DSS
# Liee a proc ::sn_tarot::listRequest
#------------------------------------------------------------
proc ::sn_tarot::createProgressBar { } {
   global audace caption snvisu

   set fconf $audace(base).snvisu_4
   toplevel $fconf -class Toplevel
   wm title $fconf "$caption(sn_tarot,dss_title)"
   regsub -all {[\+|x]} [ wm geometry $audace(base).snvisu ]  " " pos
   lassign $pos -> -> x y
   incr x 100
   incr y 250
   wm geometry $fconf "420x38+$x+$y"
   wm resizable $fconf 0 0
   wm transient $fconf $audace(base).snvisu
   wm protocol $fconf WM_DELETE_WINDOW ""

   pack [ frame $fconf.fr ]
   ttk::progressbar $fconf.fr.p -orient horizontal -length 400 -mode determinate \
      -maximum 100.0 -variable snvisu(progress)
   pack $fconf.fr.p -padx 10 -pady 10
   set snvisu(progress) 0.0

   return $fconf
}

