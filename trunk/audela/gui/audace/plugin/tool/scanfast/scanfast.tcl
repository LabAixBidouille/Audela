#
# Fichier : scanfast.tcl
# Description : Outil pour l'acquisition en mode scan rapide
# Compatibilite : Montures LX200, AudeCom et Ouranos avec camera Audine
# Auteur : Alain KLOTZ
# Mise a jour $Id: scanfast.tcl,v 1.4 2006-06-20 21:23:48 robertdelmas Exp $
#

package provide scanfast 1.0

proc prescanfast { largpix hautpix dt { firstpix 1 } { bin 1 } } {
   #--- largpix  : Largeur de l'image (en pixels)
   #--- hautpix  : Hauteur de l'image (en pixels)
   #--- dt       : Temps d'integration interligne (en millisecondes)
   #--- firstpix : Indice du premier photosite de la largeur de l'image (commence a 1)
   #--- bin      : Binning du scan (le meme sur les deux axes)
   global audace
   global caption

   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,comment1)\n"
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,comment2) [ expr int($hautpix*$dt*3/1000.) ] $caption(scanfast,secondes)\n"
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,comment3)\n"
   cam$audace(camNo) scan $largpix $hautpix $bin 0 -fast 0 -firstpix $firstpix -tmpfile 
   set tmort [ expr 1000.*[ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ] ]
   ::console::affiche_resultat "   $caption(scanfast,comment4) = $tmort $caption(scanfast,ms/ligne)\n"
   set dt0 [ expr $dt-$tmort ]
   if { $dt0 < "0" } {
      ::console::affiche_erreur "$caption(scanfast,comment5) dt=$dt $caption(scanfast,ms)\n"
      return [ list 0 0 ]
   }
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,comment6)\n"
   ::console::affiche_resultat "\n"
   set speed [ cam$audace(camNo) scanloop ]
   ::console::affiche_resultat "$caption(scanfast,iteration) 0 :\n"
   ::console::affiche_resultat "$caption(scanfast,comment7) [ expr int($hautpix*$dt/1000.) ] $caption(scanfast,secondes) $caption(scanfast,comment7a)\n"
   cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -fast $speed -firstpix $firstpix -tmpfile
   set dteff [ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ]
   ::console::affiche_resultat "   $caption(scanfast,comment8) = $speed ([ expr 1000*$dteff ] $caption(scanfast,ms/ligne))\n"
   set speed [ expr $dt/$dteff/1000.*$speed ];
   ::console::affiche_resultat "      $caption(scanfast,comment9) = $speed\n"
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,iteration) 1 :\n"
   ::console::affiche_resultat "$caption(scanfast,comment7) [ expr int($hautpix*$dt/1000.) ] $caption(scanfast,secondes) $caption(scanfast,comment7a)\n"
   cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -fast $speed -firstpix $firstpix -tmpfile
   set dteff [ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ]
   ::console::affiche_resultat "   $caption(scanfast,comment8) = $speed ([ expr 1000*$dteff ] $caption(scanfast,ms/ligne))\n"
   set speed [ expr $dt/$dteff/1000.*$speed ];
   ::console::affiche_resultat "      $caption(scanfast,comment9) = $speed\n"
   ::console::affiche_resultat "\n"
   if { [ expr int($hautpix*$dt/1000.) ] < "20" } {
      ::console::affiche_resultat "$caption(scanfast,iteration) 2 :\n"
      ::console::affiche_resultat "$caption(scanfast,comment7) [ expr int($hautpix*$dt/1000.) ] $caption(scanfast,secondes) $caption(scanfast,comment7a)\n"
      cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -fast $speed -firstpix $firstpix -tmpfile
      set dteff [ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ]
      ::console::affiche_resultat "   $caption(scanfast,comment8) = $speed ([ expr 1000*$dteff ] $caption(scanfast,ms/ligne))\n"
      set speed [ expr $dt/$dteff/1000.*$speed ];
      ::console::affiche_resultat "      $caption(scanfast,comment9) = $speed\n"
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "$caption(scanfast,iteration) 3 :\n"
      ::console::affiche_resultat "$caption(scanfast,comment7) [ expr int($hautpix*$dt/1000.) ] $caption(scanfast,secondes) $caption(scanfast,comment7a)\n"
      cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -fast $speed -firstpix $firstpix -tmpfile
      set dteff [ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ]
      ::console::affiche_resultat "   $caption(scanfast,comment8) = $speed ([ expr 1000*$dteff ] $caption(scanfast,ms/ligne))\n"
      set speed [ expr $dt/$dteff/1000.*$speed ];
      ::console::affiche_resultat "      $caption(scanfast,comment9) = $speed\n"
      ::console::affiche_resultat "\n"
   }
   ::console::affiche_resultat "$caption(scanfast,comment10)\n"
   ::console::affiche_resultat "cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -fast $speed -firstpix $firstpix -tmpfile\n"
   ::console::affiche_resultat "\n"
   return [ list $dt0 $speed ]
}

namespace eval ::Scanfast {
   variable This
   variable parametres
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool scanfast scanfast.cap ]

   proc init { { in "" } } {
      createPanel $in.scanfast
   }

   proc createPanel { this } {
      variable This
      global panneau
      global caption

      set This $this
      #---
      set panneau(Scanfast,choix_bin) "1x1 2x2 4x4"
      set panneau(Scanfast,binning)   "2x2"
      set panneau(menu_name,Scanfast) "$caption(scanfast,scanfast)"
      set panneau(Scanfast,aide)      "$caption(scanfast,help_titre)"
      set panneau(Scanfast,col)       "$caption(scanfast,colonnes)"
      set panneau(Scanfast,lig)       "$caption(scanfast,lignes)"
      set panneau(Scanfast,interlig)  "$caption(scanfast,interligne)"
      set panneau(Scanfast,bin)       "$caption(scanfast,binning)"
      set panneau(Scanfast,calcul)    "$caption(scanfast,calcul)"
      set panneau(Scanfast,ms)        "$caption(scanfast,milliseconde)"
      set panneau(Scanfast,calib)     "$caption(scanfast,calibration)"
      set panneau(Scanfast,loops)     "$caption(scanfast,boucles)"
      set panneau(Scanfast,acq)       "$caption(scanfast,acquisition)"
      set panneau(Scanfast,go0)       "$caption(scanfast,goccd)"
      set panneau(Scanfast,go1)       "$caption(scanfast,en_cours)"
      set panneau(Scanfast,go2)       "$caption(scanfast,visu)"
      set panneau(Scanfast,go)        "$panneau(Scanfast,go0)"
      ScanfastBuildIF $This
   }

   proc Chargement_Var { } {
      variable parametres
      global audace

      #--- Ouverture du fichier de paramètres
      set fichier [ file join $audace(rep_plugin) tool scanfast scanfast.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }
      if { ! [ info exists parametres(Scanfast,col1) ] }       { set parametres(Scanfast,col1)      "1" }
      if { ! [ info exists parametres(Scanfast,col2) ] }       { set parametres(Scanfast,col2)      "768" }
      if { ! [ info exists parametres(Scanfast,lig1) ] }       { set parametres(Scanfast,lig1)      "1500" }
      if { ! [ info exists parametres(Scanfast,interlig1) ] }  { set parametres(Scanfast,interlig1) "100" }
      if { ! [ info exists parametres(Scanfast,dt) ] }         { set parametres(Scanfast,dt)        "40" }
      if { ! [ info exists parametres(Scanfast,speed) ] }      { set parametres(Scanfast,speed)     "8000" }
   }

   proc Enregistrement_Var { } {
      variable parametres
      global audace
      global panneau

      set parametres(Scanfast,col1)      $panneau(Scanfast,col1)
      set parametres(Scanfast,col2)      $panneau(Scanfast,col2)
      set parametres(Scanfast,lig1)      $panneau(Scanfast,lig1)
      set parametres(Scanfast,interlig1) $panneau(Scanfast,interlig1)
      set parametres(Scanfast,dt)        $panneau(Scanfast,dt)
      set parametres(Scanfast,speed)     $panneau(Scanfast,speed)

      #--- Sauvegarde des parametres
      catch {
         set nom_fichier [ file join $audace(rep_plugin) tool scanfast scanfast.ini ]
         if [ catch { open $nom_fichier w } fichier ] {
            #---
         } else {
            foreach { a b } [ array get parametres ] { 
               puts $fichier "set parametres($a) \"$b\"" 
            }
            close $fichier
         }
      }
   }

   proc startTool { visuNo } {
      variable This

      ::Scanfast::Chargement_Var
      pack $This -side left -fill y
   }

   proc stopTool { visuNo } {
      variable This

      ::Scanfast::Enregistrement_Var
      pack forget $This
   }

   proc int { value } {
      set a [ expr ceil($value) ]
      set index [ string first . $a ]
      if { $index != "-1" } {
         set point [ expr $index-1 ]
         set value [ string range $a 0 $point ]
      }
      return $value
   }

   proc cmdGo { { motor motoron } } {
      variable This
      global conf
      global audace
      global panneau
      global caption

      if { [ ::cam::list ] != "" } {
         $This.fra4.but1 configure -relief groove -text $panneau(Scanfast,go1) -state disabled
         update
         set bin 4
         if { $panneau(Scanfast,binning) == "4x4" } { set bin 4 }
         if { $panneau(Scanfast,binning) == "2x2" } { set bin 2 }
         if { $panneau(Scanfast,binning) == "1x1" } { set bin 1 }
         set w [ ::Scanfast::int [ expr ($panneau(Scanfast,col2)-$panneau(Scanfast,col1)+1) ] ]
         set h [ ::Scanfast::int $panneau(Scanfast,lig1) ]
         set o [ ::Scanfast::int [ expr ($panneau(Scanfast,col1)-1) ] ]
         set temps_mort 10 ; #--- Estimation du temps mort a 10 ms par ligne
         set duree [ expr ($panneau(Scanfast,dt)+$temps_mort)*$h/1000./86400. ]
         #--- Gestion du moteur d'A.D.
         if { $motor == "motoroff" } {
            if { [ ::tel::list ] != "" } {
               #--- Arret du moteur d'AD
               tel$audace(telNo) radec motor off
            }
         }
         #--- Temporisation ou non entre l'arret moteur et le debut de la pose
         if { [ info exists conf(tempo_scan,active) ] == "0" } {
            set conf(tempo_scan,active) "1"
            set conf(tempo_scan,delai)  "3"
         }
         if { $conf(tempo_scan,active) == "1" } {
            #--- Decompte du temps d'attente
            set attente $conf(tempo_scan,delai)
            if { $conf(tempo_scan,delai) > "0" } {
               while { $conf(tempo_scan,delai) > "0" } {
                  ::camera::Avancement_scan "-10" $panneau(Scanfast,lig1)
                  update
                  after 1000	
                  incr conf(tempo_scan,delai) "-1"
               }
            }
            set conf(tempo_scan,delai) $attente
         }
         #--- Gestion de l'obturateur
         catch { cam$audace(camNo) shutter opened }
         #--- Calcul de l'heure TU de debut et de l'heure TU previsionnelle de fin du scan
         set date_beg [ ::audace::date_sys2ut now ]
         set sec [ expr int(floor([ lindex $date_beg 5 ])) ]
         set date_beg [ lreplace $date_beg 5 5 $sec ]
         set date_beg1 [ format "%02d/%02d/%2s %02d:%02d:%02.0f $caption(scanfast,tempsuniversel)" [ lindex $date_beg 2 ] [ lindex $date_beg 1 ] [ string range [ lindex $date_beg 0 ] 2 3 ] [ lindex $date_beg 3 ] [ lindex $date_beg 4 ] [ lindex $date_beg 5 ] ]
         set date_end [ mc_date2ymdhms [ mc_datescomp $date_beg + $duree ] ]
         set sec [ expr int(floor([ lindex $date_end 5 ])) ]
         set date_end [ lreplace $date_end 5 5 $sec ]
         set date_end1 [ format "%02d/%02d/%2s %02d:%02d:%02.0f $caption(scanfast,tempsuniversel)" [ lindex $date_end 2 ] [ lindex $date_end 1 ] [ string range [ lindex $date_end 0 ] 2 3 ] [ lindex $date_end 3 ] [ lindex $date_end 4 ] [ lindex $date_end 5 ] ]
         #--- Effacement de la fenetre indiquant l'attente si elle existe
         if [ winfo exists $audace(base).progress_scan ] {
            destroy $audace(base).progress_scan
         }
         #--- Creation d'une fenetre pour l'affichage des heures de debut et de fin du scan
         if [ winfo exists $audace(base).wintimeaudace ] {
            destroy $audace(base).wintimeaudace
         }
         toplevel $audace(base).wintimeaudace
         wm transient $audace(base).wintimeaudace $audace(base)
         wm resizable $audace(base).wintimeaudace 0 0
         wm title $audace(base).wintimeaudace "$caption(scanfast,scanfast)"
         set posx_wintimeaudace [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
         set posy_wintimeaudace [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
         wm geometry $audace(base).wintimeaudace +[ expr $posx_wintimeaudace  + 350 ]+[ expr $posy_wintimeaudace  + 75 ]
         label $audace(base).wintimeaudace.lab_beg -text "\n$caption(scanfast,debut) $date_beg1"
         pack $audace(base).wintimeaudace.lab_beg -padx 10 -pady 5
         label $audace(base).wintimeaudace.lab_end -text "$caption(scanfast,fin) $date_end1\n"
         pack $audace(base).wintimeaudace.lab_end -padx 10 -pady 5
         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $audace(base).wintimeaudace
         #---
         update
         focus $audace(base).wintimeaudace
         #--- Acquisition
         if { $o == "0" } {
            cam$audace(camNo) scan $w $h $bin $panneau(Scanfast,dt) -fast $panneau(Scanfast,speed) -tmpfile
         } else {
            cam$audace(camNo) scan $w $h $bin $panneau(Scanfast,dt) -firstpix $o -fast $panneau(Scanfast,speed) -tmpfile 
         }
         catch { cam$audace(camNo) shutter synchro }
         #--- Graphisme du panneau
         $This.fra4.but1 configure -relief groove -text $panneau(Scanfast,go2) -state disabled
         update
         #--- Visualisation de l'image
         ::audace::autovisu $audace(visuNo)
         #--- Destruction de l'affichage des heures de debut et de fin du scan
         destroy $audace(base).wintimeaudace
         #--- Gestion du moteur d'A.D.
         if { $motor == "motoroff" } {
            if { [ ::tel::list ] != "" } {
               #--- Remise en marche moteur A.D. LX200
               tel$audace(telNo) radec motor on
            }
         }
         #--- Graphisme du panneau
         $This.fra4.but1 configure -relief raised -text $panneau(Scanfast,go0) -state normal
         update
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   }

   proc cmdCalcul { } {
      variable This
      global audace
      global panneau
      global caption

      if { [ ::cam::list ] != "" } {
         $This.fra33.but1 configure -relief groove -state disabled
         update
         set bin 4
         if { $panneau(Scanfast,binning) == "4x4" } { set bin 4 }
         if { $panneau(Scanfast,binning) == "2x2" } { set bin 2 }
         if { $panneau(Scanfast,binning) == "1x1" } { set bin 1 }
         set w [ ::Scanfast::int [ expr ($panneau(Scanfast,col2)-$panneau(Scanfast,col1))/$bin ] ]
         set h [ ::Scanfast::int $panneau(Scanfast,lig1) ]
         set o [ ::Scanfast::int [ expr ($panneau(Scanfast,col1)-0)/$bin ] ]
         set results [ prescanfast $w $h $panneau(Scanfast,interlig1) $o $bin ]
         set panneau(Scanfast,dt) [ lindex $results 0 ]
         set panneau(Scanfast,speed) [ lindex $results 1 ]
         $This.fra33.fra1.ent1 configure -textvariable panneau(Scanfast,dt)
         $This.fra33.fra2.ent1 configure -textvariable panneau(Scanfast,speed)
         $This.fra33.but1 configure -relief raised -state normal
         update
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   }

   proc InfoCam { } {
      variable This
      variable parametres
      global audace
      global panneau

      catch {
         set parametres(Scanfast,col2) "[ lindex [ cam$audace(camNo) nbcells ] 0 ]"
         set panneau(Scanfast,col2) "$parametres(Scanfast,col2)"
         $This.fra2.fra1.ent2 configure -textvariable panneau(Scanfast,col2)  
         update
         ::Scanfast::cmdCalcul
      }
   }

   proc cmdVisib { } {
      variable parametres
      global panneau

      #--- Initialisation des variables du panneau
      set panneau(Scanfast,col1)       "$parametres(Scanfast,col1)"
      set panneau(Scanfast,col2)       "$parametres(Scanfast,col2)"
      set panneau(Scanfast,lig1)       "$parametres(Scanfast,lig1)"
      set panneau(Scanfast,interlig1)  "$parametres(Scanfast,interlig1)"
      set panneau(Scanfast,dt)         "$parametres(Scanfast,dt)"
      set panneau(Scanfast,speed)      "$parametres(Scanfast,speed)"
   }
}

proc ScanfastBuildIF { This } {
   global audace
   global panneau
   global caption

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,Scanfast) \
            -command {
               ::audace::showHelpPlugin tool scanfast scanfast.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(Scanfast,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame des colonnes et des lignes
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour colonnes
         label $This.fra2.lab1 -text $panneau(Scanfast,col) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Frame des 2 entries de colonnes
         frame $This.fra2.fra1 -borderwidth 1 -relief flat

            #--- Entry pour la colonne de debut
            entry $This.fra2.fra1.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Scanfast,col1) \
               -relief groove -width 5 -justify center
            pack $This.fra2.fra1.ent1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 2

            #--- Entry pour la colonne de fin
            entry $This.fra2.fra1.ent2 -font $audace(font,arial_8_b) -textvariable panneau(Scanfast,col2) \
               -relief groove -width 5 -justify center
            pack $This.fra2.fra1.ent2 -in $This.fra2.fra1 -side right -fill none -padx 4 -pady 2

         pack   $This.fra2.fra1 -in $This.fra2 -anchor center -fill none

         #--- Label pour lignes
         label $This.fra2.lab2 -text $panneau(Scanfast,lig) -relief flat
         pack $This.fra2.lab2 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Entry pour lignes
         entry $This.fra2.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Scanfast,lig1) \
            -relief groove -width 5 -justify center
         pack $This.fra2.ent1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 2

      pack $This.fra2 -side top -fill x

      #--- Binding sur la zone des infos de la camera
      set zone(camera) $This.fra2
      bind $zone(camera) <ButtonPress-1> { ::Scanfast::InfoCam }
      bind $zone(camera).lab1 <ButtonPress-1> { ::Scanfast::InfoCam }
      bind $zone(camera).lab2 <ButtonPress-1> { ::Scanfast::InfoCam }

      #--- Frame de l'interligne
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Label pour interligne
         label $This.fra3.lab1 -text $panneau(Scanfast,interlig) -relief flat
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1

         #--- Menu pour binning
         frame $This.fra3.bin -borderwidth 0 -relief groove
            menubutton $This.fra3.bin.but_bin -text $panneau(Scanfast,bin) -menu $This.fra3.bin.but_bin.menu \
               -relief raised
            pack $This.fra3.bin.but_bin -in $This.fra3.bin -side left -fill none
            set m [ menu $This.fra3.bin.but_bin.menu -tearoff 0 ]
            foreach valbin $panneau(Scanfast,choix_bin) {
               $m add radiobutton -label "$valbin" \
                  -indicatoron "1" \
                  -value "$valbin" \
                  -variable panneau(Scanfast,binning) \
                  -command { }
            }
            entry $This.fra3.bin.lab_bin -width 2 -font {arial 10 bold}  -relief groove \
              -textvariable panneau(Scanfast,binning) -justify center -state disabled
            pack $This.fra3.bin.lab_bin -in $This.fra3.bin -side left -fill both -expand true
         pack $This.fra3.bin -anchor n -fill x -expand 0 -pady 2

         #--- Frame des entry & label
         frame $This.fra3.fra1 -borderwidth 1 -relief flat

            #--- Entry pour les millisecondes
            entry $This.fra3.fra1.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Scanfast,interlig1) \
               -relief groove -width 6 -justify center
            pack $This.fra3.fra1.ent1 -in $This.fra3.fra1 -side left -fill none -padx 4 -pady 2

            #--- Label pour l'unite
            label $This.fra3.fra1.ent2 -text $panneau(Scanfast,ms) -relief flat
            pack $This.fra3.fra1.ent2 -in $This.fra3.fra1 -side left -fill none -padx 2 -pady 2

         pack $This.fra3.fra1 -in $This.fra3 -anchor center -fill none

      pack $This.fra3 -side top -fill x

      #--- Frame de la calibration
      frame $This.fra33 -borderwidth 1 -relief groove

         #--- Label pour calibrations
         label $This.fra33.lab1 -text $panneau(Scanfast,calib) -relief flat
         pack $This.fra33.lab1 -in $This.fra33 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton Calcul
         button $This.fra33.but1 -borderwidth 2 -text $panneau(Scanfast,calcul) \
            -command { ::Scanfast::cmdCalcul }
         pack $This.fra33.but1 -in $This.fra33 -anchor center -fill none -ipadx 13 -pady 1

         #--- Frame des entry & label de DT
         frame $This.fra33.fra1 -borderwidth 1 -relief flat

            #--- Entry pour DT
            entry $This.fra33.fra1.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Scanfast,dt) \
               -relief groove -width 6
            pack $This.fra33.fra1.ent1 -in $This.fra33.fra1 -side left -fill none -padx 2 -pady 2

            #--- Label pour les ms
            label $This.fra33.fra1.ent2 -text $panneau(Scanfast,ms) -relief flat
            pack $This.fra33.fra1.ent2 -in $This.fra33.fra1 -side left -fill none -padx 2 -pady 2

         pack $This.fra33.fra1 -in $This.fra33 -anchor center -fill none

         #--- Frame des entry & label de SPEED
         frame $This.fra33.fra2 -borderwidth 1 -relief flat

            #--- Entry pour SPEED
            entry $This.fra33.fra2.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Scanfast,speed) \
               -relief groove -width 6
            pack $This.fra33.fra2.ent1 -in $This.fra33.fra2 -side left -fill none -padx 2 -pady 2

            #--- Label pour les boucles
            label $This.fra33.fra2.ent2 -text $panneau(Scanfast,loops) -relief flat
            pack $This.fra33.fra2.ent2 -in $This.fra33.fra2 -side left -fill none -padx 2 -pady 2

         pack $This.fra33.fra2 -in $This.fra33 -anchor center -fill none

      pack $This.fra33 -side top -fill x

      #--- Frame de l'acquisition
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Label pour GO
         label $This.fra4.lab1 -text $panneau(Scanfast,acq) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton GO
         button $This.fra4.but1 -borderwidth 2 -text $panneau(Scanfast,go) \
            -command { ::Scanfast::cmdGo motoroff }
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill x -padx 5 -ipadx 10 -ipady 3

      pack $This.fra4 -side top -fill x

   bind $This.fra4.but1 <ButtonPress-3> { ::Scanfast::cmdGo motoron }
   bind $This <Visibility> { ::Scanfast::cmdVisib }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

global audace

::Scanfast::init $audace(base)

