#
# Fichier : tel.tcl
# Description : Outil pour le controle des montures
# Compatibilite : Montures LX200, AudeCom, etc.
# Auteurs : Alain KLOTZ, Robert DELMAS et Philippe KAUFFMANN
# Mise a jour $Id: tel.tcl,v 1.7 2007-02-23 23:35:20 michelpujol Exp $
#



namespace eval ::tlscp {
}

proc ::tlscp::Init { { in "" } { visuNo 1 }  } {
   variable private
   
   package provide tel 1.0
   #--- Chargement des captions
   source [ file join $::audace(rep_plugin) tool tel tel.cap ]

   #---
   set ::panneau(menu_name,tlscp)   "$caption(tel,telescope)"

   createPanel $visuNo
}

proc ::tlscp::createPanel { visuNo } {
   variable private
   global caption
   global catalogue
   global conf
   global audace

   set private($visuNo,This) "[::confVisu::getBase $visuNo].tlscp"
   
   set private($visuNo,exptime)     "2"

   set private($visuNo,choix_bin)   "1x1 2x2 4x4"
   set private($visuNo,binning)     "2x2"
   set private($visuNo,menu)        "$caption(tel,coord)"
   set private($visuNo,cata_coord)  "$caption(tel,coord) $caption(tel,planete) $caption(tel,asteroide) \
      $caption(tel,etoile) $caption(tel,messier) $caption(tel,ngc) $caption(tel,ic) $caption(tel,utilisateur) \
      $caption(tel,zenith)"

   set This $private($visuNo,This)
   #--- Coordonnees J2000.0 de M104
   set private($visuNo,getobj)      "12h40m0 -11d37m22"
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $caption(tel,telescope) \
            -command {
               ::audace::showHelpPlugin tool tel tel.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $caption(tel,help_titre)

      pack $This.fra1 -side top -fill x

      #--- Frame du pointage
      frame $This.fra2 -borderwidth 1 -relief groove

         ComboBox $This.fra2.optionmenu1 \
            -width 12         \
            -height [ llength $private($visuNo,cata_coord) ]  \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable ::tlscp::private($visuNo,menu) \
            -modifycmd "::tlscp::Gestion_Cata $visuNo" \
            -values $private($visuNo,cata_coord)
         pack $This.fra2.optionmenu1 -in $This.fra2 -anchor center -padx 2 -pady 2

         #--- Bind (clic droit) pour ouvrir la fenetre sans avoir a selectionner dans la listbox
         bind $This.fra2.optionmenu1.e <ButtonPress-3> " ::tlscp::Gestion_Cata $visuNo"

         #--- Entry pour l'objet a entrer
         entry $This.fra2.ent1 -font $audace(font,arial_8_b) -textvariable ::tlscp::private($visuNo,getobj) \
            -relief groove -width 16
         pack $This.fra2.ent1 -in $This.fra2 -anchor center -padx 2 -pady 2

         bind $This.fra2.ent1 <Enter> "::tlscp::FormatADDec $visuNo"
         bind $This.fra2.ent1 <Leave> "destroy [::confVisu::getBase $visuNo].formataddec"

         frame $This.fra2.fra1a

            #--- Checkbutton chemin le plus long
            checkbutton $This.fra2.fra1a.check1 -highlightthickness 0 -variable conf(audecom,gotopluslong) \
               -command "::tlscp::PlusLong $visuNo"
            pack $This.fra2.fra1a.check1 -in $This.fra2.fra1a -side left -fill both -anchor center -pady 1

            #--- Bouton MATCH
            button $This.fra2.fra1a.match -borderwidth 2 -text $caption(tel,match) -command "::tlscp::cmdMatch $visuNo"
            pack $This.fra2.fra1a.match -in $This.fra2.fra1a -side right -expand 1 -fill both -anchor center -pady 1

         pack $This.fra2.fra1a -in $This.fra2 -expand 1 -fill both

         frame $This.fra2.fra2a

            #--- Bouton Coord. / Stop GOTO
            button $This.fra2.fra2a.but2 -borderwidth 2 -text $caption(tel,coord) \
               -font $audace(font,arial_8_b) -command { ::telescope::afficheCoord }
            pack $This.fra2.fra2a.but2 -in $This.fra2.fra2a -side left -fill both -anchor center -pady 1

            #--- Bouton GOTO
            button $This.fra2.fra2a.but1 -borderwidth 2 -text $caption(tel,goto) -command "::tlscp::cmdGoto $visuNo"
            pack $This.fra2.fra2a.but1 -in $This.fra2.fra2a -side right -expand 1 -fill both -anchor center -pady 1

            #--- Bouton Stop GOTO
            button $This.fra2.fra2a.but3 -borderwidth 2 -text $caption(tel,stop_goto) -font $audace(font,arial_10_b) \
               -command { ::telescope::stopGoto }
            pack $This.fra2.fra2a.but3 -in $This.fra2.fra2a -side left -fill y -anchor center -pady 1

         pack $This.fra2.fra2a -in $This.fra2 -expand 1 -fill both

         #--- Bouton Initialisation Telescope
         button $This.fra2.but3 -borderwidth 2 -textvariable audace(telescope,inittel) -command "::tlscp::cmdInitTel $visuNo"
         pack $This.fra2.but3 -in $This.fra2 -side bottom -anchor center -fill x -pady 1

      pack $This.fra2 -side top -fill x

      #--- Frame des coordonnees
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Label pour RA
         label $This.fra3.ent1 -font $audace(font,arial_10_b) -textvariable audace(telescope,getra) -relief flat
         pack $This.fra3.ent1 -in $This.fra3 -anchor center -fill none -pady 1

         #--- Label pour DEC
         label $This.fra3.ent2 -font $audace(font,arial_10_b) -textvariable audace(telescope,getdec) -relief flat
         pack $This.fra3.ent2 -in $This.fra3 -anchor center -fill none -pady 1

      pack $This.fra3 -side top -fill x
      set zone(radec) $This.fra3

      bind $zone(radec) <ButtonPress-1> { ::telescope::afficheCoord }
      bind $zone(radec).ent1 <ButtonPress-1> { ::telescope::afficheCoord }
      bind $zone(radec).ent2 <ButtonPress-1> { ::telescope::afficheCoord }

      #--- Frame des boutons manuels
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Create the button 'N'
         frame $This.fra4.n -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.n -in $This.fra4 -side top -fill x

         #--- Button-design
         button $This.fra4.n.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(tel,nord)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $This.fra4.n.canv1 -in $This.fra4.n -expand 0 -side top -padx 2 -pady 0

         #--- Create the buttons 'E W'
         frame $This.fra4.we -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.we -in $This.fra4 -side top -fill x

         #--- Button-design 'E'
         button $This.fra4.we.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(tel,est)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $This.fra4.we.canv1 -in $This.fra4.we -expand 1 -side left -padx 0 -pady 0

         #--- Write the label of speed
         label $This.fra4.we.lab \
            -font [ list {Arial} 12 bold ] -textvariable audace(telescope,labelspeed) \
            -borderwidth 0 -relief flat
         pack $This.fra4.we.lab \
            -in $This.fra4.we -expand 1 -side left

         #--- Button-design 'W'
         button $This.fra4.we.canv2 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(tel,ouest)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $This.fra4.we.canv2 -in $This.fra4.we -expand 1 -side right -padx 0 -pady 0

         #--- Create the button 'S'
         frame $This.fra4.s -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.s -in $This.fra4 -side top -fill x

         #--- Button-design
         button $This.fra4.s.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(tel,sud)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $This.fra4.s.canv1 -in $This.fra4.s -expand 0 -side top -padx 2 -pady 0

         set zone(n) $This.fra4.n.canv1
         set zone(e) $This.fra4.we.canv1
         set zone(w) $This.fra4.we.canv2
         set zone(s) $This.fra4.s.canv1

         #--- Ecrit l'etiquette du controle du suivi : Suivi on ou off
         label $This.fra4.s.lab1 -font $audace(font,arial_10_b) -textvariable audace(telescope,controle) \
            -borderwidth 0 -relief flat
         pack $This.fra4.s.lab1 -in $This.fra4.s -expand 1 -side left

      pack $This.fra4 -side top -fill x

      bind $This.fra4.we.lab <ButtonPress-1> { ::tlscp::cmdSpeed }
      bind $This.fra4.s.lab1 <ButtonPress-1> { ::tlscp::cmdCtlSuivi }

      #--- Cardinal moves
      bind $zone(e) <ButtonPress-1> { ::tlscp::cmdMove e }
      bind $zone(e) <ButtonRelease-1> { ::tlscp::cmdStop e }
      bind $zone(w) <ButtonPress-1> { ::tlscp::cmdMove w }
      bind $zone(w) <ButtonRelease-1> { ::tlscp::cmdStop w }
      bind $zone(s) <ButtonPress-1> { ::tlscp::cmdMove s  }
      bind $zone(s) <ButtonRelease-1> { ::tlscp::cmdStop s }
      bind $zone(n) <ButtonPress-1> { ::tlscp::cmdMove n }
      bind $zone(n) <ButtonRelease-1> { ::tlscp::cmdStop n }

      #--- Frame de l'image
      frame $This.fra6 -borderwidth 1 -relief groove

         #--- Frame invisible pour le temps de pose
         frame $This.fra6.fra1

            #--- Entry pour l'objet a entrer
            entry $This.fra6.fra1.ent1 -font $audace(font,arial_8_b) -textvariable ::tlscp::private($visuNo,exptime) \
               -relief groove -width 5 -justify center
            pack $This.fra6.fra1.ent1 -in $This.fra6.fra1 -side left -fill none -padx 4 -pady 2

            label $This.fra6.fra1.lab1 -text $caption(tel,seconde) -relief flat  
            pack $This.fra6.fra1.lab1 -in $This.fra6.fra1 -side left -fill none -padx 1 -pady 1

         pack $This.fra6.fra1 -in $This.fra6 -side top -fill x

         #--- Menu pour binning
         frame $This.fra6.optionmenu1 -borderwidth 0 -relief groove
            menubutton $This.fra6.optionmenu1.but_bin -text $caption(tel,binning) \
               -menu $This.fra6.optionmenu1.but_bin.menu -relief raised
            pack $This.fra6.optionmenu1.but_bin -in $This.fra6.optionmenu1 -side left -fill none
            set m [ menu $This.fra6.optionmenu1.but_bin.menu -tearoff 0 ]
            foreach valbin $private($visuNo,choix_bin) {
               $m add radiobutton -label "$valbin" \
                  -indicatoron "1" \
                  -value "$valbin" \
                  -variable ::tlscp::private($visuNo,binning) \
                  -command { }
            }
            entry $This.fra6.optionmenu1.lab_bin -width 3 -font {arial 10 bold}  -relief groove \
              -textvariable ::tlscp::private($visuNo,binning) -justify center -state disabled
            pack $This.fra6.optionmenu1.lab_bin -in $This.fra6.optionmenu1 -side left -fill both -expand true
         pack $This.fra6.optionmenu1 -anchor n -fill x -expand 0 -pady 2

         #--- Bouton GO
         button $This.fra6.but1 -borderwidth 2 -text $caption(tel,goccd) -command "::tlscp::cmdGo $visuNo"
         pack $This.fra6.but1 -in $This.fra6 -fill none -anchor center -pady 1 -ipadx 17

      pack $This.fra6 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

}

#------------------------------------------------------------
# ::tlscp::deletePanel
#    supprime la fenetre de l'outil
# 
#------------------------------------------------------------
proc ::tlscp::deletePanel { visuNo } {
   variable private

   #--- je detruis le panel
   destroy $private($visuNo,This)
}

#------------------------------------------------------------
# ::tlscp::adaptPanel
#    adapte l'affichage des boutons en fonction de la camera
#    
# parametres
#   visuNo  : numero de la visu
#   varName : nom de la variable surveillee
#   varIndex: index de la variable surveillee si c'est un array
#   operation: operation declencheuse (array read write unset)
#------------------------------------------------------------

proc ::tlscp::adaptPanel { visuNo { varName "" } { varIndex "" } { operation "" } } {
   variable private 
   global conf
   global caption

   set This $private($visuNo,This)
   
   if { $conf(telescope) == "audecom" } {
      pack $This.fra2.fra1a.check1 -in $This.fra2.fra1a -side left -fill both -anchor center -pady 1
      #--- Evolution du script tant que la fonctionnalite "Stop Goto" sous AudeCom ne fonctionne pas
      #--- pack $This.fra2.fra2a.but2 -in $This.fra2.fra2a -side right -fill both -anchor center -pady 1
      pack forget $This.fra2.fra2a.but2
      #--- Fin de l'evolution
      pack forget $This.fra2.fra2a.but3
      pack $This.fra2.but3 -in $This.fra2 -side bottom -anchor center -fill x -pady 1
      pack $This.fra4.s.lab1 -in $This.fra4.s -expand 1 -side left
   } elseif { $conf(telescope) == "temma" } {
      if { $conf(temma,modele) == "2" } {
         pack forget $This.fra2.fra1a.check1
         pack forget $This.fra2.fra2a.but2
         pack $This.fra2.fra2a.but3 -side left -fill y -anchor center -pady 1
         pack forget $This.fra2.but3
         pack $This.fra4.s.lab1 -in $This.fra4.s -expand 1 -side left
      } else {
         pack forget $This.fra2.fra1a.check1
         pack forget $This.fra2.fra2a.but2
         pack $This.fra2.fra2a.but3 -side left -fill y -anchor center -pady 1
         pack forget $This.fra2.but3
         pack forget $This.fra4.s.lab1
      }
   } else {
      #--- C'est un telescope compatible LX200
      pack forget $This.fra2.fra1a.check1
      pack forget $This.fra2.fra2a.but2
      pack $This.fra2.fra2a.but3 -side left -fill y -anchor center -pady 1
      pack forget $This.fra2.but3
      pack forget $This.fra4.s.lab1
   }
   if { [ ::telescope::possedeGoto ] == "0" } {
      $This.fra2.fra1a.match configure -relief groove -state disabled
      $This.fra2.fra2a.but1 configure -relief groove -state disabled
      $This.fra2.fra2a.but2 configure -relief groove -state disabled
      $This.fra2.fra2a.but3 configure -relief groove -state disabled
   } else {
      $This.fra2.fra1a.match configure -relief raised -state normal
      $This.fra2.fra2a.but1 configure -relief raised -state normal
      $This.fra2.fra2a.but2 configure -relief raised -state normal
      $This.fra2.fra2a.but3 configure -relief raised -state normal
   }
}

proc ::tlscp::startTool { visuNo } {
   variable private

   trace add variable ::conf(telescope) write "::tlscp::adaptPanel $visuNo"
   trace add variable ::confTel(temma,modele) write "::tlscp::adaptPanel $visuNo"
   pack $private($visuNo,This) -side left -fill y
   ::tlscp::adaptPanel $visuNo
   #--- Je refraichis l'affichage des coordonnees
   ::telescope::afficheCoord

}

proc ::tlscp::stopTool { visuNo } {
   variable private

   trace remove variable ::conf(telescope) write "::tlscp::adaptPanel $visuNo"
   trace remove variable ::confTel(temma,modele) write "::tlscp::adaptPanel $visuNo"
   pack forget $private($visuNo,This)
}

proc ::tlscp::cmdMatch { visuNo } {
   variable private

   $private($visuNo,This).fra2.fra1a.match configure -relief groove -state disabled
   update
   ::telescope::match $private($visuNo,getobj)
   $private($visuNo,This).fra2.fra1a.match configure -relief raised -state normal
   update
}

proc ::tlscp::cmdGoto { visuNo } {
   variable private
   global audace
   global caption
   global catalogue
   global cataGoto

   #--- Gestion graphique des boutons GOTO et Stop
   $private($visuNo,This).fra2.fra2a.but1 configure -relief groove -state disabled
   $private($visuNo,This).fra2.fra2a.but2 configure -text $caption(tel,stop_goto)) -font $audace(font,arial_8_b) \
      -command "::tlscp::cmdStopGoto $visuNo"
   update

   #--- Affichage de champ dans une carte. Parametres : nom_objet, ad, dec, zoom_objet, avant_plan
   if { $cataGoto(carte,validation) == "1" } {
      ::carte::gotoObject $cataGoto(carte,nom_objet) $cataGoto(carte,ad) $cataGoto(carte,dec) $cataGoto(carte,zoom_objet) $cataGoto(carte,avant_plan)
   }

   #--- Cas particulier si le premier pointage est en mode coordonnees
   if { $private($visuNo,menu) == "$caption(tel,coord)" } {
      set private($visuNo,list_radec) $private($visuNo,getobj)
   }

   #--- Prise en compte des corrections de precession, de nutation et d'aberrations (annuelle et diurne)
   if { $private($visuNo,menu) != "$caption(tel,coord)" && $private($visuNo,menu) != "$caption(tel,planete)" \
      && $private($visuNo,menu) != "$caption(tel,asteroide)" && $private($visuNo,menu) != "$caption(tel,zenith)" } {
      #--- Initialisation du temps
      set now now
      catch {
         set now [::audace::date_sys2ut now]
      }
      #--- Calcul des corrections et affichage dans la Console
      set ad_objet_cata  [ lindex $private($visuNo,list_radec) 0 ]
      set dec_objet_cata [ lindex $private($visuNo,list_radec) 1 ]
      ::console::disp "\n"
      ::console::disp "$caption(tel,coord_catalogue) \n"
      ::console::disp "$caption(tel,ad) $ad_objet_cata \n"
      ::console::disp "$caption(tel,dec) $dec_objet_cata \n"
      set ad_dec_vrai    [ ::tkutil::coord_eph_vrai $ad_objet_cata $dec_objet_cata J2000.0 $now ]
      set ad_objet_vrai  [ lindex $ad_dec_vrai 0 ]
      set dec_objet_vrai [ lindex $ad_dec_vrai 1 ]
      ::console::disp "$caption(tel,coord_corrigees) \n"
      ::console::disp "$caption(tel,ad) $ad_objet_vrai \n"
      ::console::disp "$caption(tel,dec) $dec_objet_vrai \n"
      set private($visuNo,list_radec) "$ad_objet_vrai $dec_objet_vrai"
   }

   #--- Goto
   ::telescope::goto $private($visuNo,list_radec) "0" $private($visuNo,This).fra2.fra2a.but1 $private($visuNo,This).fra2.fra1a.match

   #--- Affichage des coordonnees pointees par le telescope dans la Console
   if { $private($visuNo,menu) != "$caption(tel,coord)" && $private($visuNo,menu) != "$caption(tel,planete)" \
      && $private($visuNo,menu) != "$caption(tel,asteroide)" && $private($visuNo,menu) != "$caption(tel,zenith)" } {
      ::telescope::afficheCoord
      ::console::disp "$caption(tel,coord_pointees) \n"
      ::console::disp "$caption(tel,ad) $audace(telescope,getra) \n"
      ::console::disp "$caption(tel,dec) $audace(telescope,getdec) \n"
      ::console::disp "\n"
   }

   #--- Gestion graphique du bouton Stop
   $private($visuNo,This).fra2.fra2a.but2 configure -relief raised -state normal -text $caption(tel,coord) \
      -font $audace(font,arial_8_b) -command { ::telescope::afficheCoord }
   update

}

proc ::tlscp::Gestion_Cata { visuNo { type_objets "" } } {
   variable private
   global conf
   global audace
   global caption
   global catalogue

   #--- Force le type d'objets
   if { $type_objets != "" } {
      set private($visuNo,menu) "$type_objets" 
   }

   #--- Gestion des catalogues
   if { $private($visuNo,menu) == "$caption(tel,coord)" } {
      ::cataGoto::Nettoyage
      set private($visuNo,list_radec) $private($visuNo,getobj)
   } elseif { $private($visuNo,menu) == "$caption(tel,planete)" } {
      ::cataGoto::GotoPlanete
      vwait catalogue(validation)
      if { $catalogue(validation) == "1" } {
         set private($visuNo,list_radec) "$catalogue(planete_ad) $catalogue(planete_dec)"
      } else {
         set private($visuNo,list_radec) $private($visuNo,getobj)
      }
      set private($visuNo,getobj) $private($visuNo,list_radec)
      $private($visuNo,This).fra2.ent1 configure -textvariable ::tlscp::private($visuNo,getobj)
      update
   } elseif { $private($visuNo,menu) == "$caption(tel,asteroide)" } {
      ::cataGoto::CataAsteroide
      vwait catalogue(validation)
      if { $catalogue(validation) == "1" } {
         set private($visuNo,list_radec) "$catalogue(asteroide_ad) $catalogue(asteroide_dec)"
      } else {
         set private($visuNo,list_radec) $private($visuNo,getobj)
      }
      set private($visuNo,getobj) $private($visuNo,list_radec)
      $private($visuNo,This).fra2.ent1 configure -textvariable ::tlscp::private($visuNo,getobj) 
      update
   } elseif { $private($visuNo,menu) == "$caption(tel,etoile)" } {
      ::cataGoto::CataEtoiles
      vwait catalogue(validation)
      if { $catalogue(validation) == "1" } {    
         set private($visuNo,list_radec) "$catalogue(etoile_ad) $catalogue(etoile_dec)"
      } else {
         set private($visuNo,list_radec) $private($visuNo,getobj)
      }
      set private($visuNo,getobj) $private($visuNo,list_radec)
      $private($visuNo,This).fra2.ent1 configure -textvariable ::tlscp::private($visuNo,getobj) 
      update
   } elseif { $private($visuNo,menu) == "$caption(tel,messier)" } {
      ::cataGoto::CataObjet $private($visuNo,menu)
      vwait catalogue(validation)
      if { $catalogue(validation) == "1" } {    
         set private($visuNo,list_radec) "$catalogue(objet_ad) $catalogue(objet_dec)"
      } else {
         set private($visuNo,list_radec) $private($visuNo,getobj)
      }
      set private($visuNo,getobj) $private($visuNo,list_radec)
      $private($visuNo,This).fra2.ent1 configure -textvariable ::tlscp::private($visuNo,getobj) 
      update
   } elseif { $private($visuNo,menu) == "$caption(tel,ngc)" } {
      ::cataGoto::CataObjet $private($visuNo,menu)
      vwait catalogue(validation)
      if { $catalogue(validation) == "1" } {    
         set private($visuNo,list_radec) "$catalogue(objet_ad) $catalogue(objet_dec)"
      } else {
         set private($visuNo,list_radec) $private($visuNo,getobj)
      }
      set private($visuNo,getobj) $private($visuNo,list_radec)
      $private($visuNo,This).fra2.ent1 configure -textvariable ::tlscp::private($visuNo,getobj) 
      update
   } elseif { $private($visuNo,menu) == "$caption(tel,ic)" } {
      ::cataGoto::CataObjet $private($visuNo,menu)
      vwait catalogue(validation)
      if { $catalogue(validation) == "1" } {    
         set private($visuNo,list_radec) "$catalogue(objet_ad) $catalogue(objet_dec)"
      } else {
         set private($visuNo,list_radec) $private($visuNo,getobj)
      }
      set private($visuNo,getobj) $private($visuNo,list_radec)
      $private($visuNo,This).fra2.ent1 configure -textvariable ::tlscp::private($visuNo,getobj)
      update
   } elseif { $private($visuNo,menu) == "$caption(tel,utilisateur)"  } {
      if { $catalogue(autre_catalogue) == "2" } {
         ::cataGoto::CataObjetUtilisateur_Choix
      } else {
         ::cataGoto::CataObjetUtilisateur
      }
      if { $catalogue(utilisateur) != "" } {
         vwait catalogue(validation)
         if { $catalogue(validation) == "1" } {    
            set private($visuNo,list_radec) "$catalogue(objet_utilisateur_ad) $catalogue(objet_utilisateur_dec)"
         } else {
            set private($visuNo,list_radec) $private($visuNo,getobj)
         }
         set private($visuNo,getobj) $private($visuNo,list_radec)
         $private($visuNo,This).fra2.ent1 configure -textvariable ::tlscp::private($visuNo,getobj) 
         update
      } else {
         set catalogue(validation) "2"
      }
   } else {
      ::cataGoto::Nettoyage
      set lat_zenith [ mc_angle2dms [ lindex $conf(posobs,observateur,gps) 3 ] 90 nozero 0 auto string ]
      set private($visuNo,list_radec) "$audace(tsl,format,zenith) $lat_zenith"
      set private($visuNo,getobj) $private($visuNo,list_radec)
      $private($visuNo,This).fra2.ent1 configure -textvariable ::tlscp::private($visuNo,getobj) 
      update
   }
   if { $catalogue(validation) == "1" } {
      ::tlscp::Gestion_Cata $visuNo
   }
}

proc ::tlscp::PlusLong { visuNo } {
   global conf
   global audace
   global caption

   set This "[::confVisu::getBase $visuNo].pluslong"
   if { $conf(audecom,gotopluslong) == "0" } {
      catch { tel$audace(telNo) slewpath short }
      destroy $This
   } else {
      catch { tel$audace(telNo) slewpath long }
      if [ winfo exists $This ] {
         destroy $This
      }
      toplevel $This
      wm transient $This [::confVisu::getBase $visuNo]
      wm resizable $This 0 0
      wm title $This "$caption(tel,attention)"
      set posx_pluslong [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_pluslong [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_pluslong + 120 ]+[ expr $posy_pluslong + 105 ]

      #--- Cree l'affichage du message
      label $This.lab1 -text "$caption(tel,pluslong1)"
      pack $This.lab1 -padx 10 -pady 2
      label $This.lab2 -text "$caption(tel,pluslong2)"
      pack $This.lab2 -padx 10 -pady 2
      label $This.lab3 -text "$caption(tel,pluslong3)"
      pack $This.lab3 -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }
}

proc ::tlscp::cmdStopGoto { visuNo } {
   variable private

   $private($visuNo,This).fra2.fra2a.but2 configure -relief groove -state disabled
   update
   ::telescope::stopGoto $private($visuNo,This).fra2.fra2a.but2
}

proc ::tlscp::cmdInitTel { visuNo } {
   variable private

   $private($visuNo,This).fra2.but3 configure -relief groove -state disabled
   update
   ::telescope::initTel $private($visuNo,This).fra2.but3 
}

proc ::tlscp::FormatADDec { visuNo } {
   global audace
   global caption

   set This "[::confVisu::getBase $visuNo].formataddec"

   if [ winfo exists $This ] {
      destroy $This
   }

   toplevel $This
   wm transient $This [::confVisu::getBase $visuNo]
   wm title $This "$caption(tel,attention)"
   set posx_formataddec [ lindex [ split [ wm geometry [::confVisu::getBase $visuNo] ] "+" ] 1 ]
   set posy_formataddec [ lindex [ split [ wm geometry [::confVisu::getBase $visuNo] ] "+" ] 2 ]
   wm geometry $This +[ expr $posx_formataddec + 120 ]+[ expr $posy_formataddec + 105 ]
   wm resizable $This 0 0

   #--- Cree l'affichage du message
   label $This.lab1 -text "$caption(tel,formataddec1)"
   pack $This.lab1 -padx 10 -pady 2
   label $This.lab2 -text "$caption(tel,formataddec2)"
   pack $This.lab2 -padx 10 -pady 2
   label $This.lab3 -text "$caption(tel,formataddec3)"
   pack $This.lab3 -padx 10 -pady 2
   label $This.lab4 -text "$caption(tel,formataddec4)"
   pack $This.lab4 -padx 10 -pady 2
   label $This.lab5 -text "$caption(tel,formataddec5)"
   pack $This.lab5 -padx 10 -pady 2

   #--- La nouvelle fenetre est active
   focus $This

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

proc ::tlscp::cmdCtlSuivi { {value " "} } {
   ::telescope::controleSuivi $value
}

proc ::tlscp::cmdMove { direction } {
   ::telescope::move $direction
}

proc ::tlscp::cmdStop { direction } {
   ::telescope::stop $direction
}

proc ::tlscp::cmdSpeed { } {
   ::telescope::incrementSpeed
}

proc ::tlscp::cmdGo { visuNo } {
   variable private
   global audace
   global caption

   #--- Verifie que le temps de pose est bien un réel positif
   if { [ ::tlscp::TestReel $private($visuNo,exptime) ] == "0" } {
      tk_messageBox -title $caption(tel,probleme) -type ok -message $caption(tel,entier_positif)
      return
   }

   #---
   set camNo [confVisu::getCamNo $visuNo]
   if { $camNo != "0" } {
      #--- Gestion graphiue du bouton
      $private($visuNo,This).fra6.but1 configure -relief groove -state disabled
      update

      #--- 
      if { ( $audace(telescope,getra) == "$caption(tel,camera)" ) && \
            ( $audace(telescope,getdec) == "$caption(tel,non_connectee)" ) } {
         ::telescope::afficheCoord
      }

      #--- Facteur de binning
      set bin 4
      if { $private($visuNo,binning) == "4x4" } { set bin "4" }
      if { $private($visuNo,binning) == "2x2" } { set bin "2" }
      if { $private($visuNo,binning) == "1x1" } { set bin "1" }

      #--- Initialisation du fenetrage
      catch {
         set n1n2 [ cam$camNo nbcells ]
         cam$camNo window [ list 1 1 [ lindex $n1n2 0 ] [ lindex $n1n2 1 ] ]
      }

      #--- Appel a la fonction d'acquisition
      ::tlscp::acq $visuNo $camNo $private($visuNo,exptime) $bin

      #--- Gestion du graphisme du panneau
      $private($visuNo,This).fra6.but1 configure -relief raised -state normal
      update
   } else {
      set audace(telescope,getra)  "$caption(tel,camera)"
      set audace(telescope,getdec) "$caption(tel,non_connectee)"
      ::confCam::run 
      tkwait window $audace(base).confCam
      if { [ ::cam::list ] != "" } {
         ::telescope::afficheCoord
      }
   }
}

proc ::tlscp::acq { visuNo camNo exptime binning } {
   variable private
   global conf
   global audace
   global caption

   #--- Petits raccourcis
   set camera cam$camNo
   set buffer buf[confVisu::getBufNo $visuNo]

   #--- La commande exptime permet de fixer le temps de pose de l'image
   $camera exptime $exptime

   #--- La commande bin permet de fixer le binning.
   $camera bin [ list $binning $binning ]

   #--- Cas des petites poses : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
   if { $exptime >= "0" && $exptime < "2" } {
      ::camera::Avancement_pose "1"
   }

   #--- Declenchement de l'acquisition
   $camera acq

   #--- Alarme sonore de fin de pose
   ::camera::alarme_sonore $exptime

   #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
   ::camera::gestionPose $exptime 1 $camera $buffer

   #--- Visualisation de l'image
   ::audace::autovisu $visuNo
}

proc ::tlscp::TestReel { valeur } {
   #--- Vérifie que la chaine passée en argument décrit bien un réel
   #--- Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un reel
   set test 1
   for { set i 0 } { $i < [ string length $valeur ] } { incr i } {
      set a [ string index $valeur $i ]
      if { ! [ string match {[0-9.]} $a ] } {
         set test 0
      }
   }
   return $test
}

::tlscp::Init $::audace(base)

