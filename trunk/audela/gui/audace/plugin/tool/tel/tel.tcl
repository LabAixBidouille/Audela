#
# Fichier : tel.tcl
# Description : Outil pour le controle des montures
# Compatibilite : Montures LX200, AudeCom, etc.
# Auteurs : Alain KLOTZ, Robert DELMAS et Philippe KAUFFMANN
# Mise a jour $Id: tel.tcl,v 1.11 2007-04-07 00:38:36 robertdelmas Exp $
#

#============================================================
# Declaration du namespace tlscp
#    initialise le namespace
#============================================================
namespace eval ::tlscp {
   package provide tel 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] tel.cap ]

}

#------------------------------------------------------------
# ::tlscp::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::tlscp::getPluginTitle { } {
   global caption

   return "$caption(tel,telescope)"
}

#------------------------------------------------------------
# ::tlscp::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::tlscp::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::tlscp::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::tlscp::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "acquisition" }
      multivisu    { return 1 }
   }
}

#------------------------------------------------------------
# ::tlscp::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::tlscp::initPlugin{ } {

}

#------------------------------------------------------------
# ::tlscp::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::tlscp::createPluginInstance { { in "" } { visuNo 1 } } {
   variable private
   global audace caption conf

   #--- Initialisation des variables
   set private($visuNo,This)        "[::confVisu::getBase $visuNo].tlscp"
   set private($visuNo,exptime)     "2"
   set private($visuNo,choix_bin)   "1x1 2x2 4x4"
   set private($visuNo,binning)     "2x2"
   set private($visuNo,menu)        "$caption(tel,coord)"
   set private($visuNo,nomObjet)    ""

   #--- Coordonnees J2000.0 de M104
   set private($visuNo,getobj)      "12h40m0 -11d37m22"

   #--- Frame principal
   frame $private($visuNo,This) -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $private($visuNo,This).fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $private($visuNo,This).fra1.but -borderwidth 1 -text $caption(tel,telescope) \
            -command "::audace::showHelpPlugin tool tel tel.htm"
         pack $private($visuNo,This).fra1.but -in $private($visuNo,This).fra1 -anchor center -expand 1 \
            -fill both -side top -ipadx 5
         DynamicHelp::add $private($visuNo,This).fra1.but -text $caption(tel,help_titre)

      pack $private($visuNo,This).fra1 -side top -fill x

      #--- Frame du pointage
      frame $private($visuNo,This).fra2 -borderwidth 1 -relief groove

         #--- Frame pour choisir un catalogue
         ::cataGoto::createFrameCatalogue $private($visuNo,This).fra2.catalogue $::tlscp::private($visuNo,getobj) $visuNo "::tlscp"
         pack $private($visuNo,This).fra2.catalogue -in $private($visuNo,This).fra2 -anchor nw -side top -padx 4 -pady 1

         #--- Label de l'objet choisi
         label $private($visuNo,This).fra2.lab1 -textvariable ::tlscp::private($visuNo,nomObjet) -relief flat
         pack $private($visuNo,This).fra2.lab1 -in $private($visuNo,This).fra2 -anchor center -padx 2 -pady 2

         #--- Entry pour les coordonnes de l'objet
         entry $private($visuNo,This).fra2.ent1 -font $audace(font,arial_8_b) \
            -textvariable ::tlscp::private($visuNo,getobj) -relief groove -width 16
         pack $private($visuNo,This).fra2.ent1 -in $private($visuNo,This).fra2 -anchor center -padx 2 -pady 2

         bind $private($visuNo,This).fra2.ent1 <Enter> "::tlscp::FormatADDec $visuNo"
         bind $private($visuNo,This).fra2.ent1 <Leave> "destroy [::confVisu::getBase $visuNo].formataddec"

         frame $private($visuNo,This).fra2.fra1a

            #--- Checkbutton chemin le plus long
            checkbutton $private($visuNo,This).fra2.fra1a.check1 -highlightthickness 0 \
               -variable conf(audecom,gotopluslong) -command "::tlscp::PlusLong $visuNo"
            pack $private($visuNo,This).fra2.fra1a.check1 -in $private($visuNo,This).fra2.fra1a -side left \
               -fill both -anchor center -pady 1

            #--- Bouton MATCH
            button $private($visuNo,This).fra2.fra1a.match -borderwidth 2 -text $caption(tel,match) \
               -command "::tlscp::cmdMatch $visuNo"
            pack $private($visuNo,This).fra2.fra1a.match -in $private($visuNo,This).fra2.fra1a -side right -expand 1 \
               -fill both -anchor center -pady 1

         pack $private($visuNo,This).fra2.fra1a -in $private($visuNo,This).fra2 -expand 1 -fill both

         frame $private($visuNo,This).fra2.fra2a

            #--- Bouton Coord. / Stop GOTO
            button $private($visuNo,This).fra2.fra2a.but2 -borderwidth 2 -text $caption(tel,coord) \
               -font $audace(font,arial_8_b) -command { ::telescope::afficheCoord }
            pack $private($visuNo,This).fra2.fra2a.but2 -in $private($visuNo,This).fra2.fra2a -side left \
               -fill both -anchor center -pady 1

            #--- Bouton GOTO
            button $private($visuNo,This).fra2.fra2a.but1 -borderwidth 2 -text $caption(tel,goto) \
               -command "::tlscp::cmdGoto $visuNo"
            pack $private($visuNo,This).fra2.fra2a.but1 -in $private($visuNo,This).fra2.fra2a -side right -expand 1 \
               -fill both -anchor center -pady 1

            #--- Bouton Stop GOTO
            button $private($visuNo,This).fra2.fra2a.but3 -borderwidth 2 -text $caption(tel,stop_goto) \
               -font $audace(font,arial_10_b) -command { ::telescope::stopGoto }
            pack $private($visuNo,This).fra2.fra2a.but3 -in $private($visuNo,This).fra2.fra2a -side left \
               -fill y -anchor center -pady 1

         pack $private($visuNo,This).fra2.fra2a -in $private($visuNo,This).fra2 -expand 1 -fill both

         #--- Bouton Initialisation Telescope
         button $private($visuNo,This).fra2.but3 -borderwidth 2 -textvariable audace(telescope,inittel) \
            -command "::tlscp::cmdInitTel $visuNo"
         pack $private($visuNo,This).fra2.but3 -in $private($visuNo,This).fra2 -side bottom -anchor center \
            -fill x -pady 1

      pack $private($visuNo,This).fra2 -side top -fill x

      #--- Frame des coordonnees
      frame $private($visuNo,This).fra3 -borderwidth 1 -relief groove

         #--- Label pour RA
         label $private($visuNo,This).fra3.ent1 -font $audace(font,arial_10_b) \
            -textvariable audace(telescope,getra) -relief flat
         pack $private($visuNo,This).fra3.ent1 -in $private($visuNo,This).fra3 -anchor center -fill none -pady 1

         #--- Label pour DEC
         label $private($visuNo,This).fra3.ent2 -font $audace(font,arial_10_b) \
            -textvariable audace(telescope,getdec) -relief flat
         pack $private($visuNo,This).fra3.ent2 -in $private($visuNo,This).fra3 -anchor center -fill none -pady 1

      pack $private($visuNo,This).fra3 -side top -fill x
      set zone(radec) $private($visuNo,This).fra3

      bind $zone(radec) <ButtonPress-1> { ::telescope::afficheCoord }
      bind $zone(radec).ent1 <ButtonPress-1> { ::telescope::afficheCoord }
      bind $zone(radec).ent2 <ButtonPress-1> { ::telescope::afficheCoord }

      #--- Frame des boutons manuels
      frame $private($visuNo,This).fra4 -borderwidth 1 -relief groove

         #--- Create the button 'N'
         frame $private($visuNo,This).fra4.n -width 27 -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.n -in $private($visuNo,This).fra4 -side top -fill x

         #--- Button-design
         button $private($visuNo,This).fra4.n.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(tel,nord)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $private($visuNo,This).fra4.n.canv1 -in $private($visuNo,This).fra4.n -expand 0 \
            -side top -padx 2 -pady 0

         #--- Create the buttons 'E W'
         frame $private($visuNo,This).fra4.we -width 27 -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.we -in $private($visuNo,This).fra4 -side top -fill x

         #--- Button-design 'E'
         button $private($visuNo,This).fra4.we.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(tel,est)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $private($visuNo,This).fra4.we.canv1 \
            -in $private($visuNo,This).fra4.we -expand 1 -side left -padx 0 -pady 0

         #--- Write the label of speed
         label $private($visuNo,This).fra4.we.lab \
            -font [ list {Arial} 12 bold ] -textvariable audace(telescope,labelspeed) \
            -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.we.lab \
            -in $private($visuNo,This).fra4.we -expand 1 -side left

         #--- Button-design 'W'
         button $private($visuNo,This).fra4.we.canv2 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(tel,ouest)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $private($visuNo,This).fra4.we.canv2 \
            -in $private($visuNo,This).fra4.we -expand 1 -side right -padx 0 -pady 0

         #--- Create the button 'S'
         frame $private($visuNo,This).fra4.s -width 27 -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.s -in $private($visuNo,This).fra4 -side top -fill x

         #--- Button-design
         button $private($visuNo,This).fra4.s.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(tel,sud)" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $private($visuNo,This).fra4.s.canv1 \
            -in $private($visuNo,This).fra4.s -expand 0 -side top -padx 2 -pady 0

         set zone(n) $private($visuNo,This).fra4.n.canv1
         set zone(e) $private($visuNo,This).fra4.we.canv1
         set zone(w) $private($visuNo,This).fra4.we.canv2
         set zone(s) $private($visuNo,This).fra4.s.canv1

         #--- Ecrit l'etiquette du controle du suivi : Suivi on ou off
         label $private($visuNo,This).fra4.s.lab1 -font $audace(font,arial_10_b) \
            -textvariable audace(telescope,controle) -borderwidth 0 -relief flat
         pack $private($visuNo,This).fra4.s.lab1 -in $private($visuNo,This).fra4.s -expand 1 -side left

      pack $private($visuNo,This).fra4 -side top -fill x

      bind $private($visuNo,This).fra4.we.lab <ButtonPress-1> { ::tlscp::cmdSpeed }
      bind $private($visuNo,This).fra4.s.lab1 <ButtonPress-1> { ::tlscp::cmdCtlSuivi }

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
      frame $private($visuNo,This).fra6 -borderwidth 1 -relief groove

         #--- Frame invisible pour le temps de pose
         frame $private($visuNo,This).fra6.fra1

            #--- Entry pour l'objet a entrer
            entry $private($visuNo,This).fra6.fra1.ent1 -font $audace(font,arial_8_b) \
               -textvariable ::tlscp::private($visuNo,exptime) -relief groove -width 5 -justify center
            pack $private($visuNo,This).fra6.fra1.ent1 -in $private($visuNo,This).fra6.fra1 -side left \
               -fill none -padx 4 -pady 2

            label $private($visuNo,This).fra6.fra1.lab1 -text $caption(tel,seconde) -relief flat
            pack $private($visuNo,This).fra6.fra1.lab1 -in $private($visuNo,This).fra6.fra1 -side left \
               -fill none -padx 1 -pady 1

         pack $private($visuNo,This).fra6.fra1 -in $private($visuNo,This).fra6 -side top -fill x

         #--- Menu pour binning
         frame $private($visuNo,This).fra6.optionmenu1 -borderwidth 0 -relief groove
            menubutton $private($visuNo,This).fra6.optionmenu1.but_bin -text $caption(tel,binning) \
               -menu $private($visuNo,This).fra6.optionmenu1.but_bin.menu -relief raised
            pack $private($visuNo,This).fra6.optionmenu1.but_bin -in $private($visuNo,This).fra6.optionmenu1 \
               -side left -fill none
            set m [ menu $private($visuNo,This).fra6.optionmenu1.but_bin.menu -tearoff 0 ]
            foreach valbin $private($visuNo,choix_bin) {
               $m add radiobutton -label "$valbin" \
                  -indicatoron "1" \
                  -value "$valbin" \
                  -variable ::tlscp::private($visuNo,binning) \
                  -command { }
            }
            entry $private($visuNo,This).fra6.optionmenu1.lab_bin -width 3 -font {arial 10 bold} -relief groove \
              -textvariable ::tlscp::private($visuNo,binning) -justify center -state disabled
            pack $private($visuNo,This).fra6.optionmenu1.lab_bin -in $private($visuNo,This).fra6.optionmenu1 \
               -side left -fill both -expand true
         pack $private($visuNo,This).fra6.optionmenu1 -anchor n -fill x -expand 0 -pady 2

         #--- Bouton GO
         button $private($visuNo,This).fra6.but1 -borderwidth 2 -text $caption(tel,goccd) \
            -command "::tlscp::cmdGo $visuNo"
         pack $private($visuNo,This).fra6.but1 -in $private($visuNo,This).fra6 -fill none \
            -anchor center -pady 1 -ipadx 17

      pack $private($visuNo,This).fra6 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $private($visuNo,This)
}

#------------------------------------------------------------
# ::tlscp::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::tlscp::deletePluginInstance { visuNo } {
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

   if { $conf(telescope) == "audecom" } {
      pack $private($visuNo,This).fra2.fra1a.check1 -in $private($visuNo,This).fra2.fra1a -side left \
         -fill both -anchor center -pady 1
      #--- Evolution du script tant que la fonctionnalite "Stop Goto" sous AudeCom ne fonctionne pas
      #--- pack $private($visuNo,This).fra2.fra2a.but2 -in $private($visuNo,This).fra2.fra2a -side right \
      #---    -fill both -anchor center -pady 1
      pack forget $private($visuNo,This).fra2.fra2a.but2
      #--- Fin de l'evolution
      pack forget $private($visuNo,This).fra2.fra2a.but3
      pack $private($visuNo,This).fra2.but3 -in $private($visuNo,This).fra2 -side bottom -anchor center -fill x -pady 1
      pack $private($visuNo,This).fra4.s.lab1 -in $private($visuNo,This).fra4.s -expand 1 -side left
   } elseif { $conf(telescope) == "temma" } {
      if { $conf(temma,modele) == "2" } {
         pack forget $private($visuNo,This).fra2.fra1a.check1
         pack forget $private($visuNo,This).fra2.fra2a.but2
         pack $private($visuNo,This).fra2.fra2a.but3 -side left -fill y -anchor center -pady 1
         pack forget $private($visuNo,This).fra2.but3
         pack $private($visuNo,This).fra4.s.lab1 -in $private($visuNo,This).fra4.s -expand 1 -side left
      } else {
         pack forget $private($visuNo,This).fra2.fra1a.check1
         pack forget $private($visuNo,This).fra2.fra2a.but2
         pack $private($visuNo,This).fra2.fra2a.but3 -side left -fill y -anchor center -pady 1
         pack forget $private($visuNo,This).fra2.but3
         pack forget $private($visuNo,This).fra4.s.lab1
      }
   } else {
      #--- C'est un telescope compatible LX200
      pack forget $private($visuNo,This).fra2.fra1a.check1
      pack forget $private($visuNo,This).fra2.fra2a.but2
      pack $private($visuNo,This).fra2.fra2a.but3 -side left -fill y -anchor center -pady 1
      pack forget $private($visuNo,This).fra2.but3
      pack forget $private($visuNo,This).fra4.s.lab1
   }
   if { [ ::telescope::possedeGoto ] == "0" } {
      $private($visuNo,This).fra2.fra1a.match configure -relief groove -state disabled
      $private($visuNo,This).fra2.fra2a.but1 configure -relief groove -state disabled
      $private($visuNo,This).fra2.fra2a.but2 configure -relief groove -state disabled
      $private($visuNo,This).fra2.fra2a.but3 configure -relief groove -state disabled
   } else {
      $private($visuNo,This).fra2.fra1a.match configure -relief raised -state normal
      $private($visuNo,This).fra2.fra2a.but1 configure -relief raised -state normal
      $private($visuNo,This).fra2.fra2a.but2 configure -relief raised -state normal
      $private($visuNo,This).fra2.fra2a.but3 configure -relief raised -state normal
   }
}

#------------------------------------------------------------
# ::tlscp::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::tlscp::startTool { visuNo } {
   variable private

   trace add variable ::conf(telescope) write "::tlscp::adaptPanel $visuNo"
   trace add variable ::confTel(temma,modele) write "::tlscp::adaptPanel $visuNo"
   pack $private($visuNo,This) -side left -fill y
   ::tlscp::adaptPanel $visuNo

   #--- Je refraichis l'affichage des coordonnees
   ::telescope::afficheCoord
}

#------------------------------------------------------------
# ::tlscp::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
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
   global audace caption cataGoto catalogue

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

proc ::tlscp::setRaDec { visuNo listRaDec nomObjet } {
   variable private

   set private($visuNo,getobj)   $listRaDec
   set private($visuNo,nomObjet) $nomObjet
}

proc ::tlscp::PlusLong { visuNo } {
   global audace caption conf

   set This "[::confVisu::getBase $visuNo].pluslong"
   if { $conf(audecom,gotopluslong) == "0" } {
      catch { tel$audace(telNo) slewpath short }
      destroy $This
   } else {
      catch { tel$audace(telNo) slewpath long }
      if [ winfo exists $This ] {
         destroy $This
      }

      #---
      toplevel $This
      wm transient $This [::confVisu::getBase $visuNo]
      wm resizable $This 0 0
      wm title $This "$caption(tel,attention)"
      set posx_pluslong [ lindex [ split [ wm geometry [::confVisu::getBase $visuNo] ] "+" ] 1 ]
      set posy_pluslong [ lindex [ split [ wm geometry [::confVisu::getBase $visuNo] ] "+" ] 2 ]
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
   ::telescope::initTel $private($visuNo,This).fra2.but3 $visuNo
}

proc ::tlscp::FormatADDec { visuNo } {
   global caption

   set This "[::confVisu::getBase $visuNo].formataddec"

   if [ winfo exists $This ] {
      destroy $This
   }

   #---
   toplevel $This
   wm transient $This [::confVisu::getBase $visuNo]
   wm title $This "$caption(tel,attention)"
   set posx_formataddec [ lindex [ split [ wm geometry [::confVisu::getBase $visuNo] ] "+" ] 1 ]
   set posy_formataddec [ lindex [ split [ wm geometry [::confVisu::getBase $visuNo] ] "+" ] 2 ]
   wm geometry $This +[ expr $posx_formataddec + 120 ]+[ expr $posy_formataddec + 90 ]
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

proc ::tlscp::cmdCtlSuivi { { value " " } } {
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
   global audace caption

   #--- Verifie que le temps de pose est bien un réel positif
   if { [ ::tlscp::TestReel $private($visuNo,exptime) ] == "0" } {
      tk_messageBox -title $caption(tel,probleme) -type ok -message $caption(tel,entier_positif)
      return
   }

   #---
   set camNo [::confVisu::getCamNo $visuNo]
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
   #--- Petits raccourcis
   set camera cam$camNo
   set buffer buf[::confVisu::getBufNo $visuNo]

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

